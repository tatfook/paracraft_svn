--[[
Title: mini map for paraworld
Author(s): WangTian
Date: 2008/1/14, updated LXZ 2006.6.22. removed timer with framemove and added to mini map app via MiniMapPage. 
Desc: mini map version one consists of a fixed size square map zone plus an expandable portal list
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MiniMap/MiniMapWnd.lua");
Map3DSystem.UI.MiniMapWnd.Show(bShow, parentUI)
Map3DSystem.UI.MiniMapWnd.SetMapFixed(true)
Map3DSystem.UI.MiniMapWnd.IsMapFixed()
Map3DSystem.UI.MiniMapWnd.OnLoadMiniMap = function(MiniMapWnd)
	-- log(MiniMapWnd.minimap_filePath)
end
Map3DSystem.UI.MiniMapWnd.OnUpdateMark = function(MiniMapWnd, angle)
	-- angle is the character angle. 
end
------------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemUI/MiniMap/MiniMapManager.lua");


if(not Map3DSystem.UI.MiniMapWnd) then Map3DSystem.UI.MiniMapWnd = {}; end

local MiniMapWnd = Map3DSystem.UI.MiniMapWnd;

-- function of function(MiniMapWnd) end, it is called when a minimap is just loaded. usually needs update according to MiniMapWnd.minimap_filePath
MiniMapWnd.OnLoadMiniMap = nil;

-- function of function(MiniMapWnd) end, it is called when need to update the marks on the map
MiniMapWnd.OnUpdateMark = nil;

-- the image file path
MiniMapWnd.minimap_filePath = nil;
MiniMapWnd.MainMenuHeight = 22;
MiniMapWnd.CanvasWidth = 200;
MiniMapWnd.CanvasHeight = 200;
-- update every 0.1 second
MiniMapWnd.updateInterval = 0.2;
MiniMapWnd.RenderSize = 128;

-- mouse wheel zoom range in meters
MiniMapWnd.MinZoomDistance = 20
MiniMapWnd.MaxZoomDistance = 500
-- initial zoom distance 
MiniMapWnd.DefaultZoomDistance = 200; 
-- how many mouse delta steps to zoom between min and max, a log step size maybe better than linear one like this. 
MiniMapWnd.ZoomStepCount = 50;

-- when character changes position, whether to rotate map or rotate character. 
MiniMapWnd.bIsMapFixed = true;
-- in case MiniMapWnd.bIsMapFixed is true, this is the angle to rotation, it is automatically set according to current character facing. 
MiniMapWnd.mapRotation = 0;

-- objects location and size on the minimap are scaled by this to prevent camera culling when zooming. 
local unit_scale = 0.1;

-- whether to draw using 3D camera or not 
MiniMapWnd.Use3DCamera = false
-- whether to draw using 3D avatar or not 
MiniMapWnd.Use3DAvatar = false
-- whether to show tooltip when mouse over map objects. 
MiniMapWnd.ShowTooltip = false
-- whether show the coordinate
MiniMapWnd.ShowCoordinate = true

local DefaultSettings = {
	MinZoomDistance = 20,
	MaxZoomDistance = 500,
	DefaultZoomDistance = 300,
	ZoomStepCount = 50,
	
	ShowCoordinate = true,
	bIsMapFixed = true,
	
	-- left top map position in world coordinates
	minimap_x = 0,
	minimap_y = 0, 
	-- minimap size
	minimap_size = 533.333,
};
commonlib.partialcopy(MiniMapWnd, DefaultSettings);

-- @param bShow: show or hide the mini map
-- @param parentUI: parent container inside which the content is displayed. it can be nil.
function MiniMapWnd.Show(bShow, parentUI)

	local _this, _parent;
	_this = ParaUI.GetUIObject("MiniMapWnd");
	
	if(_this:IsValid() == false) then
		-- main window of mini map
		local _minimapWnd
		if(parentUI==nil) then
			_minimapWnd = ParaUI.CreateUIObject("container", "MiniMapWnd", "_rt", 
					-MiniMapWnd.CanvasWidth, 
					MiniMapWnd.MainMenuHeight, 
					MiniMapWnd.CanvasWidth, 
					MiniMapWnd.CanvasHeight);
			_minimapWnd.background = "";
			_minimapWnd:AttachToRoot();
		else
			_minimapWnd = ParaUI.CreateUIObject("container", "MiniMapWnd", "_fi", 0, 0, 0, 0);
			_minimapWnd.background = "";
			parentUI:AddChild(_minimapWnd);
		end	
		
		_minimapWnd.onframemove = ";Map3DSystem.UI.MiniMapWnd.OnFramemove();"
		
		
		-- map view
		local _mapCanvas = ParaUI.CreateUIObject("container", "MiniMapCanvas", "_fi", 0, 0, 0, 0);
		_mapCanvas.background="";
		_mapCanvas.onmousewheel = ";Map3DSystem.UI.MiniMapWnd.OnMouseWheel();";
		_mapCanvas.onmousemove = ";Map3DSystem.UI.MiniMapWnd.OnMouseMove();";
		_minimapWnd:AddChild(_mapCanvas);
		
		if(not MiniMapWnd.Use3DAvatar) then
			local size = 16;
			local arrowFile = "Texture/3DMapSystem/common/arrow_up.png";
			if(ParaIO.DoesFileExist("Texture/Aquarius/Desktop/Minimap_AvatarArrow_32bits.png", true) == true) then
				size = 32;
				arrowFile = "Texture/Aquarius/Desktop/Minimap_AvatarArrow_32bits.png";
			end
			-- using 2D UI for avatar and camera display, added by LiXizhi 2008.6.29
			_this = ParaUI.CreateUIObject("button", "avatar", "_ct", -size/2, -size/2, size, size);
			_this.background = arrowFile;
			_this.enabled = false;
			_guihelper.SetUIColor(_this, "255 255 255");
			_mapCanvas:AddChild(_this);
		end
		
		-- text coordiates
		if(MiniMapWnd.ShowCoordinate) then
			_this = ParaUI.CreateUIObject("text", "coordinates", "_lt", 0, 0, 120, 18);
			_this.enabled = false;
			_this.shadow = true;
			_guihelper.SetFontColor(_this, "#808080");
			_mapCanvas:AddChild(_this);
		end	
		
		-- mouse tooltip
		local _minimapTooltip = ParaUI.CreateUIObject("button", "MiniMapTooltip", "_lt", 0, 0, 20, 20);
		_minimapTooltip.enable = false;
		_minimapTooltip.visible = false;
		--_minimapTooltip.background = "";
		_minimapWnd:AddChild(_minimapTooltip);
	end
	
	if(bShow or bShow == nil) then
		MiniMapWnd.InitMiniSceneGraph();
	end	
end

function MiniMapWnd.OnMouseWheel()
	-- calculate the new distance between the camera and object
	local dist = MiniMapWnd.cameraObjectDist;
	dist = dist - mouse_wheel * (MiniMapWnd.MaxZoomDistance-MiniMapWnd.MinZoomDistance)/MiniMapWnd.ZoomStepCount;
	-- limit the distance in [20, 100]
	if(dist > MiniMapWnd.MaxZoomDistance) then
		dist = MiniMapWnd.MaxZoomDistance;
	elseif(dist < MiniMapWnd.MinZoomDistance) then
		dist = MiniMapWnd.MinZoomDistance;
	end
	MiniMapWnd.cameraObjectDist = dist;
	
	-- set the new distance, the liftup angle is always vertical
	local scene = MiniMapWnd.GetScene();
	scene:CameraSetEyePosByAngle(Map3DSystem.UI.MiniMapManager.northDir+MiniMapWnd.mapRotation, 1.57, dist*unit_scale);
end

function MiniMapWnd.OnMouseMove()
	if(MiniMapWnd.ShowTooltip) then
		local _minimapWnd = ParaUI.GetUIObject("MiniMapWnd");
		local _minimapCanvas = _minimapWnd:GetChild("MiniMapCanvas");
		-- pick the object in mini map
		local scene = MiniMapWnd.GetScene();
		local x, y, _, __ = _minimapCanvas:GetAbsPosition();
		local pickX = (mouse_x - x) * 256 / MiniMapWnd.CanvasWidth;
		local pickY = (mouse_y - y) * 256 / MiniMapWnd.CanvasHeight;
		local objPick = scene:MousePick(pickX*unit_scale, pickY*unit_scale, 150*unit_scale, "anyobject");
		
		local objname = "";
		if(objPick:IsValid() == true) then
			objname = objPick:GetName();
		end
		
		if(MiniMapWnd.lastPickObjName == objname) then
			-- skip the tooltip update if latest two pick object is the same
			--return;
		end
		MiniMapWnd.lastPickObjName = objname;
		
		-- currently only the object name is shown on tooltip
		-- TODO: show the object description and interaction info in tool tip form
		local _minimapTooltip = _minimapWnd:GetChild("MiniMapTooltip");
		_minimapTooltip.text = objname;
		
		if(objname == "") then
			_minimapTooltip.visible = false;
		else
			_minimapTooltip.visible = true;
			
			local textWidth = _guihelper.GetTextWidth(_minimapTooltip.text) + 5;
			_minimapTooltip.width = textWidth;
			
			-- limit the mouse tool tip in the screen
			local _, _, resWidth, resHeight = ParaUI.GetUIObject("root"):GetAbsPosition();
			if(mouse_x + _minimapTooltip.width > resWidth) then
				_minimapTooltip.translationx = resWidth - textWidth - x;
				_minimapTooltip.translationy = mouse_y + 16 - y;
			else
				_minimapTooltip.translationx = mouse_x - x;
				_minimapTooltip.translationy = mouse_y + 16 - y;
			end
		end
	end
end


-- create and initialize the mini map mini scene graph
-- NOTE: one time init
function MiniMapWnd.InitMiniSceneGraph()
	--
	-- check minimap.xml, for advanced config files 
	-- please see: script/test/minimap.xml for an example.
	--
	commonlib.partialcopy(MiniMapWnd, DefaultSettings);
	
	local minimap_filePath = ParaWorld.GetWorldDirectory().."minimap.png";
	
	local minimap_configfile = ParaWorld.GetWorldDirectory().."minimap.xml";
	if(ParaIO.DoesFileExist(minimap_configfile, true)) then
		local xmlRoot = ParaXML.LuaXML_ParseFile(minimap_configfile);
		local node;
		for node in commonlib.XPath.eachNode(xmlRoot, "/minimap") do
			if(node.attr) then
				if(node.attr["ShowCoordinate"]) then
					MiniMapWnd.ShowCoordinate = not ( node.attr["ShowCoordinate"] == "false")
				end
				if(node.attr["IsMapFixed"]) then
					MiniMapWnd.bIsMapFixed = not ( node.attr["IsMapFixed"] == "false")
				end
				if(node.attr["MinZoomDistance"]) then
					MiniMapWnd.MinZoomDistance = tonumber(node.attr["MinZoomDistance"])
				end
				if(node.attr["MaxZoomDistance"]) then
					MiniMapWnd.MaxZoomDistance = tonumber(node.attr["MaxZoomDistance"])
				end
				if(node.attr["ZoomStepCount"]) then
					MiniMapWnd.ZoomStepCount = tonumber(node.attr["ZoomStepCount"])
				end
				if(node.attr["DefaultZoomDistance"]) then
					MiniMapWnd.DefaultZoomDistance = tonumber(node.attr["DefaultZoomDistance"])
				end
			end
		end
		
		for node in commonlib.XPath.eachNode(xmlRoot, "/minimap/tile") do
			-- just use the first tile, since we only support a single file at the moment. 
			if(node.attr) then
				local centerx = tonumber(node.attr["centerx"])
				local centery = tonumber(node.attr["centery"])
				local radius = tonumber(node.attr["radius"])
				if(centerx and centery and radius) then
					MiniMapWnd.minimap_x = centerx - radius;
					MiniMapWnd.minimap_y = centery - radius;
					MiniMapWnd.minimap_size = radius*2;
				end
			end
		end
	end
	
	-------------------------
	-- a simple 3d scene using mini scene graph
	-------------------------
	local scene = ParaScene.GetMiniSceneGraph("minimap");
	
	------------------------------------
	-- init render target
	------------------------------------
	-- set size
	scene:SetRenderTargetSize(MiniMapWnd.RenderSize, MiniMapWnd.RenderSize);
	-- reset scene, in case this is called multiple times
	scene:Reset();
	-- enable camera and create render target
	scene:EnableCamera(true);
	-- render it each frame by timer
	-- Note: If content is static, one should disable this, and call scene:draw() in a script timer.
	scene:EnableActiveRendering(false);
	-- Set minimap mask
	--scene:SetMaskTexture(ParaAsset.LoadTexture("", "Texture/Aquarius/Desktop/Minimap_Mask_32bits.png", 1));
	
	local att = scene:GetAttributeObject();
	att:SetField("ShowSky", false);
	att:SetField("EnableFog", false);
	att:SetField("EnableLight", false);
	att:SetField("EnableSunLight", false);
	scene:SetTimeOfDaySTD(0);
	-- set the mini map scene to semitransparent background color
	--scene:SetBackGroundColor("255 255 255 100");
	
	------------------------------------
	-- init camera
	------------------------------------
	
	scene:CameraSetLookAtPos(0,0,0);
	scene:CameraSetEyePosByAngle(Map3DSystem.UI.MiniMapManager.northDir+MiniMapWnd.mapRotation, 1.57, MiniMapWnd.DefaultZoomDistance*unit_scale);
	MiniMapWnd.cameraObjectDist = MiniMapWnd.DefaultZoomDistance;
	
	------------------------------------
	-- init mini map default assets and object content
	------------------------------------
	
	local manager = Map3DSystem.UI.MiniMapManager;
	manager.InitDefaultAssets();
	
	if(MiniMapWnd.Use3DAvatar) then
		manager.RegisterAvatarObject()
	end	;
	if(MiniMapWnd.Use3DCamera) then
		manager.RegisterCameraObject();
	end	
	
	--manager.RegisterOPCObject("OPC1");
	--manager.RegisterOPCObject("OPC2");
	--manager.RegisterOPCObject("OPC3");
	--
	--manager.RegisterPortalObject("Portal1");
	--manager.RegisterPortalObject("Portal2");
	--manager.RegisterPortalObject("Portal3");
	
	--
	-- display the minimap.png(or jpg) in the root world directory. 
	--
	if(not ParaIO.DoesFileExist(minimap_filePath, true)) then
		minimap_filePath = ParaWorld.GetWorldDirectory().."minimap.jpg";
		if(not ParaIO.DoesFileExist(minimap_filePath, true)) then
			minimap_filePath = nil;
		end
	end
	
	if(minimap_filePath) then
		local _asset = ParaAsset.LoadStaticMesh("", Map3DSystem.UI.MiniMapManager.AssetListDefault["ground"]);
		local _ground = ParaScene.CreateMeshPhysicsObject("ground", _asset, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
		if( _ground:IsValid())then
			-- commonlib.echo({MiniMapWnd.minimap_x, MiniMapWnd.minimap_y, MiniMapWnd.minimap_size})
			_ground:SetPosition((MiniMapWnd.minimap_x+MiniMapWnd.minimap_size/2)*unit_scale,0,(MiniMapWnd.minimap_y+MiniMapWnd.minimap_size/2)*unit_scale);
			_ground:SetScale(MiniMapWnd.minimap_size*unit_scale);
			_ground:GetAttributeObject():SetField("progress", 1);
			_ground:SetReplaceableTexture(1,ParaAsset.LoadTexture("",minimap_filePath,1));
			scene:AddChild(_ground);
		end
		MiniMapWnd.minimap_filePath = minimap_filePath;
		if(type(MiniMapWnd.OnLoadMiniMap) == "function") then
			MiniMapWnd.OnLoadMiniMap(MiniMapWnd);
		end
	end	
	
	------------------------------------
	-- assign the texture to UI
	------------------------------------
	local _minimapWnd = ParaUI.GetUIObject("MiniMapWnd");
	local _minimapCanvas = _minimapWnd:GetChild("MiniMapCanvas");
	
	if(_minimapCanvas:IsValid()) then
		_minimapCanvas:SetBGImage(scene:GetTexture());
	end
end

function MiniMapWnd.GetScene()
	return ParaScene.GetMiniSceneGraph("minimap");
end

-- private
local _elapsedtime = 0;
function MiniMapWnd.OnFramemove()
	_elapsedtime = _elapsedtime + deltatime;
	if(_elapsedtime >= MiniMapWnd.updateInterval ) then
		_elapsedtime = _elapsedtime - MiniMapWnd.updateInterval;
		
		-- update each mini scene object position and direction
		MiniMapWnd.UpdateCamera();
		MiniMapWnd.UpdatePortal();
		MiniMapWnd.UpdateAvatar();
		MiniMapWnd.UpdateOPC();
		
		-- draw the scene in the mini map scene timer.
		MiniMapWnd.OnTimerDraw();
	end	
end

function MiniMapWnd.OnTimerDraw()
	-- draw the scene in the mini map scene timer.
	local scene = MiniMapWnd.GetScene();
	scene:Draw(0.05);
end

-- update camera object position and direction
function MiniMapWnd.UpdateCamera()
	if(MiniMapWnd.Use3DCamera) then
		-- adjust camera
		local scene = MiniMapWnd.GetScene();
		local att = ParaCamera.GetAttributeObject();
		--local pos = att:GetField("Eye position", {1, 1, 1});
		local eyePos = att:GetField("Eye position", {1, 1, 1});
		local lookatPos = att:GetField("Lookat position", {1, 1, 1});
		--scene:CameraSetLookAtPos(eyePos[1] - 255, 1, eyePos[3] - 255);
		
		-- update the camera object position
		local _camera = scene:GetObject("camera_minimap");
		--_camera:SetPosition(eyePos[1] - 255, 3, eyePos[3] - 255);
		_camera:SetPosition(lookatPos[1], Map3DSystem.UI.MiniMapManager.cameraPosY, lookatPos[3]);
		
		-- calculate the facing angle
		local dx = lookatPos[1] - eyePos[1];
		local dz = - lookatPos[3] + eyePos[3];
		local angle = math.acos(dx / math.sqrt(dx * dx + dz * dz));
		if(dz < 0) then
			angle = 6.28 - angle;
		end
		
		-- update the camera object direction
		_camera:SetFacing(angle);
	else
		
	end
end

-- update portal object position
function MiniMapWnd.UpdatePortal()
	local scene = MiniMapWnd.GetScene();
	
	-- traverse through the Portal list and update each position
	local k, v;
	for k, v in pairs(Map3DSystem.UI.MiniMapManager.PortalList) do
		local _portal = ParaScene.GetObject(v.name);
		local x, y, z = _portal:GetPosition();
		local obj = scene:GetObject("Portal_"..v.name);
		obj:SetPosition(x*unit_scale, Map3DSystem.UI.MiniMapManager.portalPosY*unit_scale, z*unit_scale);
	end
end

-- update avatar object position
function MiniMapWnd.UpdateAvatar()
	local scene = MiniMapWnd.GetScene();
	
	-- set mini scene camera position. 
	local x, y, z = ParaScene.GetPlayer():GetPosition();
	scene:CameraSetLookAtPos(x*unit_scale, 0, z*unit_scale);
	
	
	-- get camera facing angle
	local angle = 0
	do
		local att = ParaCamera.GetAttributeObject();
		local eyePos = att:GetField("Eye position", {1, 1, 1});
		local lookatPos = att:GetField("Lookat position", {1, 1, 1});
		
		-- calculate the facing angle
		local dx = lookatPos[1] - eyePos[1];
		local dz = - lookatPos[3] + eyePos[3];
		angle = math.acos(dx / math.sqrt(dx * dx + dz * dz));
		if(dz < 0) then
			angle = 6.28 - angle;
		end
	end	
	
	-- NOTE by andy 2009/1/19: get charater facing angle
	angle = ParaScene.GetPlayer():GetFacing();
			
	if(MiniMapWnd.IsMapFixed()) then
		MiniMapWnd.mapRotation = 0;
	else
		MiniMapWnd.mapRotation = angle+1.57;
	end
	scene:CameraSetEyePosByAngle(Map3DSystem.UI.MiniMapManager.northDir+MiniMapWnd.mapRotation, 1.57, MiniMapWnd.cameraObjectDist*unit_scale);
	
	-- update player cooridate text
	local _Cord= ParaUI.GetUIObject("MiniMapWnd"):GetChild("MiniMapCanvas"):GetChild("coordinates");
	if(MiniMapWnd.ShowCoordinate) then
		if(_Cord:IsValid()) then
			_Cord.text = string.format("%.0f, %.0f", x, z);
		end
	end	
		
	-- update player avatar display	either by 3D or 2D UI.
	if(MiniMapWnd.Use3DAvatar) then
		-- update the avatar object position
		local _avatar = scene:GetObject("avatar_minimap");
		local x, y, z = ParaScene.GetObject(Map3DSystem.UI.MiniMapManager.AvatarName):GetPosition();
		_avatar:SetPosition(x*unit_scale, Map3DSystem.UI.MiniMapManager.avatarPosY*unit_scale, z*unit_scale);
	else
		local _avatar = ParaUI.GetUIObject("MiniMapWnd"):GetChild("MiniMapCanvas"):GetChild("avatar");
		if(_avatar:IsValid()) then
			-- update the avatar direction
			_avatar.rotation = 1.57+angle-MiniMapWnd.mapRotation
		end
		--------------------------------------
		-- LXZ: Hi, andy, this take me ages to find the code, related to MyCompany.Aquarius.Desktop.LocalMap
		-- move this code to a callback in Aquarius.Desktop.LocalMap
		--------------------------------------
		if(type(MiniMapWnd.OnUpdateMark) == "function") then
			MiniMapWnd.OnUpdateMark(MiniMapWnd, angle);
		end
	end	
end

-- update opc object position
function MiniMapWnd.UpdateOPC()
	local scene = MiniMapWnd.GetScene();
	
	local opcnames = {};
	-- traverse through the OPC list and update each position
	local k, v;
	for k, v in pairs(Map3DSystem.UI.MiniMapManager.OPCList) do
		local _OPC = ParaScene.GetObject(v.name);
		local x, y, z = _OPC:GetPosition();
		local obj = scene:GetObject("OPC_"..v.name);
		obj:SetPosition(x*unit_scale, Map3DSystem.UI.MiniMapManager.OPCPosY, z*unit_scale);
		obj:SetScale(1.5);
		
		local _localmapcanvas = ParaUI.GetUIObject("LocalMapCanvas");
		if(_localmapcanvas:IsValid() == true) then
			local _opc = _localmapcanvas:GetChild("OPC_"..v.name);
			local size = 16;
			if(_opc:IsValid() == false) then
				-- using 2D UI for avatar and camera display, added by LiXizhi 2008.6.29
				_opc = ParaUI.CreateUIObject("button", "OPC_"..v.name, "_lt", -size/2, -size/2, size, size);
				_opc.tooltip = v.name;
				_localmapcanvas:AddChild(_opc);
			end
			_opc.background = v.texturename;
			
			local _, __, width, height = _localmapcanvas:GetAbsPosition();
			_opc.x = (x - MiniMapWnd.minimap_x) / MiniMapWnd.minimap_size * width  -size/2;
			_opc.y = height - ((z - MiniMapWnd.minimap_y) / MiniMapWnd.minimap_size * height)  -size/2;
			
			opcnames["OPC_"..v.name] = true;
		end
	end
	local _localmapcanvas = ParaUI.GetUIObject("LocalMapCanvas");
	if(_localmapcanvas:IsValid() == true) then
		
		local nCount = _localmapcanvas:GetChildCount();
		-- traverse all children in a container
		-- pay attention the GetChildAt function indexed in C++ form which begins at index 0
		for i = 0, nCount - 1 do
			local _opc = _localmapcanvas:GetChildAt(i);
			if(opcnames[_opc.name] ~= true and string.find(_opc.name, "OPC_") == 1) then
				-- TODO: perform self destroy
				ParaUI.Destroy(_opc.name);
			end
		end
	end
end

----------------------------
-- public functions
----------------------------

-- when character changes position, whether to rotate map or rotate character. 
function MiniMapWnd.IsMapFixed()
	return MiniMapWnd.bIsMapFixed;
end

-- when character changes position, whether to rotate map or rotate character. 
function MiniMapWnd.SetMapFixed(bCheck)
	MiniMapWnd.bIsMapFixed = bCheck;
	MiniMapWnd.OnFramemove()
end
