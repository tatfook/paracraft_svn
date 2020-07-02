--[[
Title: save a collection of objects on the construction site
It will give a preview of bill of materials(BOM) in a separate window, allowing author to edit name, description and price. 
Author(s): LiXizhi
Date: 2008/1/14
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/BlueprintApp/SaveBom.lua");
SaveBom.ShowWnd(_app);
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");

commonlib.setfield("Map3DSystem.App.Blueprint.SaveBom", {});

-- create and show a sub window of a given application 
-- @param _app: the os.app object.
function Map3DSystem.App.Blueprint.ShowWnd(_app)
	local _wnd = _app:FindWindow("SaveBom") or _app:RegisterWindow("SaveBom", nil, Map3DSystem.App.Blueprint.SaveBom.MSGProc);
	
	local _wndFrame = _wnd:GetWindowFrame();
	if(not _wndFrame) then
		_wndFrame = _wnd:CreateWindowFrame{
			icon = "Texture/3DMapSystem/common/disk.png",
			iconSize = 16,
			text = "保存工程图",
			initialWidth = 160,
			maximumSizeX = 800,
			maximumSizeY = 700,
			minimumSizeX = 360,
			minimumSizeY = 300,
			allowDrag = true,
			allowResize = true,
			initialPosX = 160,
			initialPosY = 80,
			initialWidth = 560,
			initialHeight = 420,
			ShowUICallback = Map3DSystem.App.Blueprint.SaveBom.Show,
		};
	end
	_wnd:ShowWindowFrame(true);
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
-- @param _parent: parent window inside which the content is displayed. it can be nil.
function Map3DSystem.App.Blueprint.SaveBom.Show(bShow, _parent, parentWindow)
	local _this;
	Map3DSystem.App.Blueprint.SaveBom.parentWindow = parentWindow;
	
	_this=ParaUI.GetUIObject("SaveBom_cont");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		if(_parent==nil) then
			_this=ParaUI.CreateUIObject("container","SaveBom_cont","_lt",0,50, 150, 300);
			_this:AttachToRoot();
		else
			_this = ParaUI.CreateUIObject("container", "SaveBom_cont", "_fi",0,0,0,0);
			_this.background = ""
			_parent:AddChild(_this);
		end	
		_parent = _this;

		_this = ParaUI.CreateUIObject("text", "label1", "_lt", 3, 9, 84, 14)
		_this.text = "工程图名称:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label4", "_lt", 3, 38, 42, 14)
		_this.text = "描述:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label2", "_lt", 3, 68, 70, 14)
		_this.text = "价值(P$):";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label3", "_lt", 175, 68, 70, 14)
		_this.text = "价值(E$):";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "preViewBtn", "_lb", 1, -26, 72, 23)
		_this.text = "保存";
		_this.onclick = ";Map3DSystem.App.Blueprint.SaveBom.OnSave();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "cancel", "_lb", 93, -26, 72, 23)
		_this.text = "取消";
		_this.onclick = ";Map3DSystem.App.Blueprint.SaveBom.OnCancel();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("editbox", "priceP", "_lt", 93, 64, 56, 23)
		_this.text = "0";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("editbox", "priceE", "_lt", 262, 64, 56, 23)
		_this.text = "0";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("imeeditbox", "name", "_lt", 93, 6, 170, 23)
		_this.text = "我的工程图";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("imeeditbox", "description", "_mt", 93, 35, 3, 23)
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("container", "preview", "_fi", 0, 93, 0, 32)
		_parent:AddChild(_this);
		_this.onmousedown = string.format(";Map3DSystem.App.Blueprint.SaveBom.OnMouseDown(%q);", "");
		_this.onmouseup = string.format(";Map3DSystem.App.Blueprint.SaveBom.OnMouseUp(%q);", "");
		_this.onmousemove = string.format(";Map3DSystem.App.Blueprint.SaveBom.OnMouseMove(%q);", "");
		_this.onmousewheel = string.format(";Map3DSystem.App.Blueprint.SaveBom.OnMouseWheel(%q);", "");
		
	else
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		--_this.visible = bShow;
		_parent = _this;
	end	
	if(bShow) then
		local bom = Map3DSystem.App.Blueprint.BomWnd.CurBom;
		if(bom ~= nil) then
			-- update miniscene to display the blueprint preview. 
			-------------------------
			local scene = ParaScene.GetMiniSceneGraph("blueprint_preview_UI");
			------------------------------------
			-- init render target
			------------------------------------
			-- set size
			scene:SetRenderTargetSize(256, 128);
			-- reset scene, in case this is called multiple times
			scene:Reset();
			-- enable camera and create render target
			scene:EnableCamera(true);
			-- render it each frame automatically. 
			scene:EnableActiveRendering(true);
			
			local att = scene:GetAttributeObject();
			scene:SetBackGroundColor("128 128 255 128") -- blue background
			--att:SetField("BackgroundColor", {0.5, 0.5, 1});  
			att:SetField("ShowSky", false);
			att:SetField("EnableFog", false);
			----att:SetField("EnableFog", false);
			--att:SetField("FogColor", {1, 1, 1}); -- red fog
			--att:SetField("FogStart", 8);
			--att:SetField("FogEnd", 30);
			--att:SetField("FogDensity", 1);
			att:SetField("EnableLight", false)
			att:SetField("EnableSunLight", false)
			scene:SetTimeOfDaySTD(0.3);
			------------------------------------
			-- init camera
			------------------------------------
			scene:CameraSetLookAtPos(0,1,0);
			scene:CameraSetEyePosByAngle(0, 0.3, bom.radius*1.3);
			
			------------------------------------
			-- init scene content
			------------------------------------
			local bom = Map3DSystem.App.Blueprint.BomWnd.CurBom;
			if(bom~=nil and bom.objects~=nil) then
				local i, objParam
				for i, objParam in ipairs(bom.objects) do
					local obj = ObjEditor.CreateObjectByParams(objParam);
					if(obj~=nil and obj:IsValid()) then
						scene:AddChild(obj);
					end
				end
			end
		
			-- the mesh grid
			local asset = ParaAsset.LoadStaticMesh("","model/common/blueprint_meshgrid/blueprint_meshgrid.x")
			obj = ParaScene.CreateMeshPhysicsObject("", asset, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
			obj:SetPosition(0, 0, 0);
			obj:GetAttributeObject():SetField("progress",1);
			scene:AddChild(obj);
			
			----local obj,player, asset;
			--asset = ParaAsset.LoadParaX("","character/v3/Pet/MGBB/mgbb.xml");
			--obj = ParaScene.CreateCharacter("player", asset, "", true, 0.35, 0.5, 1);
			--obj:SetPosition(0, 0, 0);
			--obj:SetScaling(2.5);
			--obj:SetFacing(2);
			--scene:AddChild(obj);
			
			------------------------------------
			-- canvas
			------------------------------------
			_this = _parent:GetChild("preview");
			_this:SetBGImage(scene:GetTexture());
			
			-- register a timer for animation
			NPL.SetTimer(129, 0.03, ";Map3DSystem.App.Blueprint.SaveBom.OnTimer();");
		end			
	else
		Map3DSystem.App.Blueprint.SaveBom.OnDestory();
	end
end

-- destory the control
function Map3DSystem.App.Blueprint.SaveBom.OnDestory()
	ParaUI.Destroy("SaveBom_cont");
	-- kill timer
	NPL.KillTimer(129);
	-- delete mini scene graph
	ParaScene.DeleteMiniSceneGraph("blueprint_preview_UI");	
end

function Map3DSystem.App.Blueprint.SaveBom.MSGProc(window, msg)
	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		window:DestroyWindowFrame()
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		
	end
end


----------------------------------------------------
-- window events 
----------------------------------------------------

-- mouse down position
Map3DSystem.App.Blueprint.SaveBom.lastMouseDown = {x = 0, y=0}
Map3DSystem.App.Blueprint.SaveBom.lastMousePos = {x = 0, y=0}
-- whether mouse button is down
Map3DSystem.App.Blueprint.SaveBom.IsMouseDown = false;

function Map3DSystem.App.Blueprint.SaveBom.OnMouseDown()
	Map3DSystem.App.Blueprint.SaveBom.lastMouseDown.x = mouse_x;
	Map3DSystem.App.Blueprint.SaveBom.lastMouseDown.y = mouse_y;
	Map3DSystem.App.Blueprint.SaveBom.IsMouseDown = true;
	Map3DSystem.App.Blueprint.SaveBom.lastMousePos.x = mouse_x;
	Map3DSystem.App.Blueprint.SaveBom.lastMousePos.y = mouse_y;
end

function Map3DSystem.App.Blueprint.SaveBom.OnMouseMove()
	if(Map3DSystem.App.Blueprint.SaveBom.IsMouseDown) then
		local mouse_dx, mouse_dy = mouse_x-Map3DSystem.App.Blueprint.SaveBom.lastMousePos.x, mouse_y-Map3DSystem.App.Blueprint.SaveBom.lastMousePos.y;
		if(mouse_dx~=0 or mouse_dy~=0) then
			local scene = ParaScene.GetMiniSceneGraph("blueprint_preview_UI");
			if(scene:IsValid()) then
				local fRotY, fLiftupAngle, fCameraObjectDist = scene:CameraGetEyePosByAngle();
				fRotY = fRotY+mouse_dx*0.004; --how many degrees per pixel movement
				fLiftupAngle = fLiftupAngle + mouse_dy*0.004; --how many degrees per pixel movement
				if(fLiftupAngle>1.3) then
					fLiftupAngle = 1.3;
				end
				if(fLiftupAngle<0.1) then
					fLiftupAngle = 0.1;
				end
				scene:CameraSetEyePosByAngle(fRotY, fLiftupAngle, fCameraObjectDist);
			end
		end	
	end
	Map3DSystem.App.Blueprint.SaveBom.lastMousePos.x = mouse_x;
	Map3DSystem.App.Blueprint.SaveBom.lastMousePos.y = mouse_y;
end

function Map3DSystem.App.Blueprint.SaveBom.OnMouseUp()
	if(not Map3DSystem.App.Blueprint.SaveBom.IsMouseDown) then
		return 
	end
	Map3DSystem.App.Blueprint.SaveBom.IsMouseDown = false;
	local dragDist = (math.abs(Map3DSystem.App.Blueprint.SaveBom.lastMousePos.x-Map3DSystem.App.Blueprint.SaveBom.lastMouseDown.x) + math.abs(Map3DSystem.App.Blueprint.SaveBom.lastMousePos.y-Map3DSystem.App.Blueprint.SaveBom.lastMouseDown.y));
	if(dragDist<=2) then
		-- this is mouse click event if mouse down and mouse up distance is very small.
	end
	Map3DSystem.App.Blueprint.SaveBom.lastMousePos.x = mouse_x;
	Map3DSystem.App.Blueprint.SaveBom.lastMousePos.y = mouse_y;
end


function Map3DSystem.App.Blueprint.SaveBom.OnMouseWheel()
	local scene = ParaScene.GetMiniSceneGraph("blueprint_preview_UI");
	if(scene:IsValid()) then
		local fRotY, fLiftupAngle, fCameraObjectDist = scene:CameraGetEyePosByAngle();
		fCameraObjectDist = fCameraObjectDist*math.pow(1.1, -mouse_wheel); --how many scales per wheel delta movement
		if(fCameraObjectDist>40) then
			fCameraObjectDist = 40;
		end
		if(fCameraObjectDist<2) then
			fCameraObjectDist = 2;
		end
		scene:CameraSetEyePosByAngle(fRotY, fLiftupAngle, fCameraObjectDist);
	end
end

function Map3DSystem.App.Blueprint.SaveBom.OnTimer()
	local _this=ParaUI.GetUIObject("SaveBom_cont");
	if(not _this:IsValid()) then
		Map3DSystem.App.Blueprint.SaveBom.OnDestory()
	elseif(not Map3DSystem.App.Blueprint.SaveBom.IsMouseDown) then
		-- some camera animations for the camera goes on here. 
		local scene = ParaScene.GetMiniSceneGraph("blueprint_preview_UI");
		if(scene:IsValid()) then
			local fRotY, fLiftupAngle, fCameraObjectDist = scene:CameraGetEyePosByAngle();
			fRotY = fRotY+0.001; --how many degrees per frame
			scene:CameraSetEyePosByAngle(fRotY, fLiftupAngle, fCameraObjectDist);
		end
	end
end

function Map3DSystem.App.Blueprint.SaveBom.OnCancel()
	Map3DSystem.App.Blueprint.SaveBom.parentWindow:ShowWindowFrame(false);
end

-- save the current to a file and call the inventory give function.  
function Map3DSystem.App.Blueprint.SaveBom.OnSave()
	local bom = Map3DSystem.App.Blueprint.BomWnd.CurBom;
	if(bom~=nil and bom.objects~=nil) then
		-- create a file in the application's local directory. 
		
		local _parent=ParaUI.GetUIObject("SaveBom_cont");
		if(_parent:IsValid()) then
			local _this;
			_this = _parent:GetChild("name");
			bom.name = _this.text;
			
			_this = _parent:GetChild("description");
			bom.description = _this.text;
			
			-- TODO: do some validation on number
			_this = _parent:GetChild("priceE");
			bom.priceE = tonumber(_this.text);
			_this = _parent:GetChild("priceP");
			bom.priceP = tonumber(_this.text);
		end
			
		if(bom.name~=nil and bom.name~="") then
			-- Create File (bom.name)
			local filename = string.gsub(bom.name, "[%s/\\:]", "")
			filename = filename..".bom"; -- add file extension 
			local file = Map3DSystem.App.Blueprint.app:openfile(commonlib.Encoding.Utf8ToDefault(filename),"w");
			if(file ~= nil and file:IsValid()) then
				-- write bom to the file. 
				commonlib.serializeToFile(file, bom);
				file:close();
				
				-- close window
				Map3DSystem.App.Blueprint.SaveBom.OnCancel()
				
				_guihelper.MessageBox("保存成功: "..bom.name);	
				-- TODO: 通过GiveBox 放入玩家的背包中
				-- TODO: Map3DSystem.App.IO.Inventory.give();
				-- TODO: Map3DSystem.App.IO.Inventory.BeginGive();Map3DSystem.App.IO.Inventory.EndGive();
				-- TODO: Map3DSystem.App.IO.Inventory.ShowGiveBox();
			else
				_guihelper.MessageBox("无法保存 "..bom.name.."\n文件名无效");	
			end
		end
	end
	
end

