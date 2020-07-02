--[[
Title: Bills Of Materials window for a given blueprint
3dvia.com (dassalt systems) partners with virtual earth. And In our bluepring application, we can also partner with a third party model developer
like 3dvia and sketchup to allow users to create and upload any models directly in a popup window. Of course, a plug-in is also needed for professionals. 
Author(s): LiXizhi
Date: 2008/1/12
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/BlueprintApp/BomWnd.lua");

-- to create a bom
local bom --  = {radius= 10, center = {x,y,z}};
bom = Map3DSystem.App.Blueprint.CreateNewBom(bom);
Map3DSystem.App.Blueprint.SelectBom(bom);

-- to open a bom
local bom = Map3DSystem.App.Blueprint.LoadBomFromFile(filename);
if(bom~=nil) then
	bom.center.x, bom.center.y,bom.center.z = ParaScene.GetPlayer():GetPosition();
	Map3DSystem.App.Blueprint.SelectBom(bom);
else
	_guihelper.MessageBox("无法打开工程图文件:"..filename);
end
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");

local BomWnd = {}
commonlib.setfield("Map3DSystem.App.Blueprint.BomWnd", BomWnd);

BomWnd.BomStatus = {
	-- a newly created empty bom, 
	Empty = nil, 
	-- a bom that is being designed. 
	Designing = 1,
	-- a bom that is being built by user manually. 
	Building = 2,
	-- a bom that is being automatically deployed. 
	Deploying = 3,
	-- a bom that is being previewed in miniscenegraph, user needs to decide whether to build it themselves or buy it. 
	Preview = 4,
};

-- a single bom template
BomWnd.Bom = {
	-- item GUID string. if this is nil, the item is never uploaded before. 
	id = nil,
	author = nil, 
	name = nil,
	description = nil, 
	-- E price and P price. 
	priceE = nil,
	priceP = nil,
	
	-- array of objects {} in building order
	objects = nil,
	-------------------------------------------
	-- per instance
	-------------------------------------------
	-- point of reference {x, y, z}
	center = nil,
	-- the radius of the building site. this determines how large we should rendering the construction spot. 
	radius = 10,
	-- facing 
	facing = 0,
	-- status of type BomWnd.BomStatus
	status = nil,
	-- the number of steps (objects) that have been deployed during automatic deploy or build.
	-- if this number equals to the size of Bom.objects, then the building is finished. 
	BuildingStep = 0,
	-- whether to ignore wrong object creation
	bIgnoreWrongCreation = nil, 
};

-- TODO: a list of active boms in the scene.
BomWnd.Boms = {};

-- the currently selected bom that the current BomWnd is bind to. 
BomWnd.CurBom = nil;

-- create a new bom
function BomWnd.Bom:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o	
end

-- clear all objects
function BomWnd.Bom:ClearAll()
	self.objects = nil;
end

-- add a new object to the bom list. 
-- it is usually the table returned from ObjEditor.GetObjectParams(). 
-- however, one needs to manually assign an optional field called cmdName, which contains information about command button (Icon to display, etc)
-- if objParam.cmdName is nil, the icon in the BomWnd for this object will be a question mark, indicating that it will only be deployed when user is implementing manually. 
function BomWnd.Bom:AddObject(objParam)
	self.objects = self.objects or {};
	self.objects[table.getn(self.objects)+1] = objParam;
end

function BomWnd.Bom:ClearAll()
	self.objects = {};
end

-- create a new bom. One can later call SelectBom to select it by UI. 
-- @param bom: partial class of BomWnd.Bom. if bom is nil, a default one at the current player position will be created. 
--  otherwise, the caller can specify where to create the bom and how big is the construction site. 
-- @return return the bom object created.
function Map3DSystem.App.Blueprint.CreateNewBom(bom)
	bom = BomWnd.Bom:new(bom);
	if(bom.center == nil) then
		bom.center = {};
		bom.center.x, bom.center.y,bom.center.z = ParaScene.GetPlayer():GetPosition();
	end
	bom.status = nil;
	return bom;
end

-- load bom from file. it returned the bom object. it may return nil if failed. 
function Map3DSystem.App.Blueprint.LoadBomFromFile(filename)
	local bom = commonlib.LoadTableFromFile(filename)
	if(bom~=nil) then
		bom = BomWnd.Bom:new(bom);
		bom.status = BomWnd.BomStatus.Preview;
	end
	return bom;
end

-- select all things in the bom region to bom's object list
function BomWnd.SelectAllToBom()
	local bom = BomWnd.CurBom;
	if(bom~=nil) then
		local nGroupID = 1;
		ParaSelection.ClearGroup(nGroupID);
		ParaSelection.SetMaxItemNumberInGroup(nGroupID, 1000);
		local nCount = ParaScene.SelectObject(nGroupID, bom.center.x, bom.center.y,bom.center.z,bom.radius, "mesh");
		
		if(nCount == 0) then
			_guihelper.MessageBox("在工程图的有效范围内没有发现任何物体. 你需要首先创建一些物体");
		else
			bom:ClearAll();
			local nIndex, obj, objParams;
			for nIndex = 0, nCount-1 do
				obj = ParaSelection.GetObject(nGroupID, nIndex);
				objParams = ObjEditor.GetObjectParams(obj);
				if(objParams~=nil and not objParams.IsCharacter) then
					local cmdName = obj:GetAttributeObject():GetDynamicField("CreateCommandName", "");
					if(cmdName~=nil and cmdName~= "") then
						-- save the creation command name, if there is no creation command, 
						-- it will be a secret object that is only created when user is building by its own. 
						objParams.cmdName = cmdName;
						-- add object to bom. 
					end
					-- use relative to bom center position
					objParams.x = objParams.x - bom.center.x;
					objParams.y = objParams.y - bom.center.y;
					objParams.z = objParams.z - bom.center.z;
					bom:AddObject(objParams);
				end
			end	
			BomWnd.UpdateTreeView()
		end
		
	end	
end

-- private: update the BOM tree view according to the curren bom list's objects
function BomWnd.UpdateTreeView()
	local bom = BomWnd.CurBom;
	if(bom~=nil) then
		local ctl = CommonCtrl.GetControl("BomWnd_treeViewBOMList");
		if(ctl~=nil)then
			local node = ctl.RootNode;
			node:ClearAllChildren();
			if(bom.objects~=nil) then
				local i, objParam;
				for i, objParam in ipairs(bom.objects) do
					local bHasCmd;
					if(objParam.cmdName~=nil) then
						local cmd = Map3DSystem.App.Commands.GetCommand(objParam.cmdName)
						if(cmd~=nil) then
							node:AddChild( CommonCtrl.TreeNode:new({Text = cmd.ButtonText, Name = cmd.name, Icon = cmd.icon, objParams = objParam, cmd = cmd}) );
							bHasCmd = true;
						end
					end
					if( not bHasCmd ) then
						local DisplayName;
						if(objParam.name ~= nil and objParam.name ~= "") then
							DisplayName = objParam.name;
						else
							local _,_, name = string.find(objParam.AssetFile, ".*[/\\]([^/\\]+)%..*$");
							if(name == nil) then
								name = "未知"
							end
							DisplayName = name;
						end
						
						node:AddChild( CommonCtrl.TreeNode:new({Text = DisplayName, Name = "secret", 
							Icon = nil, -- TODO: use a question mark
							objParams = objParam}) );
					end
				end
			end	
			
			ctl:Update();
		end
	end
end

-- select a bom as the current bom and display its BomWnd. 
-- when a bom is (de)selected, it will (un)hook object creation events. 
-- @param bom: the bom object to be selected. if nil, nothing will be selected. 
function Map3DSystem.App.Blueprint.SelectBom(bom)
	BomWnd.CurBom = bom;
	if(bom == nil) then
		-- unhook 
		--CommonCtrl.os.hook.UnhookWindowsHook({hookName="BomHook", hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC})
		-- delete mini scene graph 
		ParaScene.DeleteMiniSceneGraph("blueprint");
	else
		-- hook into the "scene" app's "object" window, so that we can detect all object creation and modification messages in the scene. 
		--CommonCtrl.os.hook.SetWindowsHook({hookType=CommonCtrl.os.hook.HookType.WH_CALLWNDPROC, callback = Map3DSystem.App.Blueprint.BomHookProc, 
			--hookName = "BomHook", appName="scene", wndName = "object"});

		-- show the bom window.	
		Map3DSystem.App.Blueprint.ShowBomWnd(Map3DSystem.App.Blueprint.app._app);
		
		-- show the miniscenegraph
		Map3DSystem.App.Blueprint.UpdateScenegraphHelper(bom);
	end
end

-- update the 3d helper in the miniscenegraph.
function Map3DSystem.App.Blueprint.UpdateScenegraphHelper(bom)
	if(bom== nil) then	
		bom = BomWnd.CurBom
	end
	
	local scene = ParaScene.GetMiniSceneGraph("blueprint");
	
	-- reset scene, in case this is called multiple times
	scene:Reset();
	-- show display
	scene:ShowHeadOnDisplay(true);
	------------------------------------
	-- init scene content
	------------------------------------
	local obj,player, asset;
	
	local scale = bom.radius/10;
	
	-- the mesh grid
	local asset = ParaAsset.LoadStaticMesh("","model/common/blueprint_meshgrid/blueprint_meshgrid.x")
	obj = ParaScene.CreateMeshPhysicsObject("blueprint_meshgrid", asset, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
	obj:SetPosition(bom.center.x, bom.center.y+0.03, bom.center.z);
	obj:SetScaling(scale);
	obj:GetAttributeObject():SetField("progress",1);
	scene:AddChild(obj);
	
	local asset = ParaAsset.LoadStaticMesh("","model/common/blueprint_center/blueprint_center.x")
	obj = ParaScene.CreateMeshPhysicsObject("blueprint_center", asset, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
	obj:SetPosition(bom.center.x, bom.center.y, bom.center.z);
	obj:GetAttributeObject():SetField("progress",1);
	--obj:SetHeadOnText("工程图: 施工中心",0);
	scene:AddChild(obj);
	
	local asset = ParaAsset.LoadStaticMesh("","model/common/blueprint_walls/blueprint_walls.x")
	obj = ParaScene.CreateMeshPhysicsObject("blueprint_walls", asset, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
	obj:SetPosition(bom.center.x, bom.center.y, bom.center.z);
	obj:GetAttributeObject():SetField("progress",1);
	obj:SetScaling(scale);
	scene:AddChild(obj);	
end

-- display the bom window. It will rebuilt bom each time it is called. 
function Map3DSystem.App.Blueprint.ShowBomWnd(_app)
	local _wnd = _app:FindWindow("BomWnd") or _app:RegisterWindow("BomWnd", nil, BomWnd.MSGProc);
	
	_wnd:DestroyWindowFrame();
	local _wndFrame = _wnd:GetWindowFrame();
	if(not _wndFrame) then
		_wndFrame = _wnd:CreateWindowFrame{
			icon = "Texture/3DMapSystem/common/package_add.png",
			text = "新建工程图",
			allowDrag = true,
			allowResize = true,
			initialPosX = 846,
			initialPosY = 170,
			initialWidth = 170,
			initialHeight = 400,
			ShowUICallback = BomWnd.Show,
		};
	end
	_wnd:ShowWindowFrame(true);
end

-- hook procedure to detect what object the user has created.  
function Map3DSystem.App.Blueprint.BomHookProc(nCode, appName, msg)
	-- return the nCode to be passed to the next hook procedure in the hook chain. 
	-- in most cases, if nCode is nil, the hook procedure should do nothing. 
	if(nCode==nil) then return end
	
	-- TODO: do your code here
	--_guihelper.MessageBox("hook called "..msg.wndName.."\n");
	
	return nCode;
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
-- @param _parent: parent window inside which the content is displayed. it can be nil.
function BomWnd.Show(bShow, _parent, parentWindow)
	local _this;
	BomWnd.parentWindow = parentWindow;
	
	_this=ParaUI.GetUIObject("BomWnd_cont");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		if(_parent==nil) then
			_this=ParaUI.CreateUIObject("container","BomWnd_cont","_lt",0,50, 150, 300);
			_this:AttachToRoot();
		else
			_this = ParaUI.CreateUIObject("container", "BomWnd_cont", "_fi",3,0,3,5);
			_this.background = ""
			_parent:AddChild(_this);
		end	
		_parent = _this;
		local _parentCont = _parent;

		_this = ParaUI.CreateUIObject("text", "title", "_lt", 3, 9, 63, 14)
		_this.text = "进度: 0%";
		_guihelper.SetUIFontFormat(_this, 36); -- single lined vertical centered text. 
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "price", "_lb", 0, -41, 91, 14)
		_this.text = "价值: 0 E$";
		_guihelper.SetUIFontFormat(_this, 36); -- single lined vertical centered text. 
		_parent:AddChild(_this);
		
		-- preview mode container
		_this = ParaUI.CreateUIObject("container", "preview_cont", "_mt",0,26,0,22);
		_this.background = ""
		_parent:AddChild(_this);
		_parent = _this;
		
		_this = ParaUI.CreateUIObject("button", "b", "_mt",0,0,80,20);
		_this.text = "预览"
		_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/btn_bg_highlight.png: 4 4 4 4";
		_this.onclick = ";Map3DSystem.App.Blueprint.BomWnd.OnClickPreviewInPlace();"
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "b", "_rt",-76,0,76,20);
		_this.text = "重定位"
		_this.onclick = ";Map3DSystem.App.Blueprint.BomWnd.OnClickPreviewRelocateCenter();"
		_parent:AddChild(_this);
		
		_parent = _parentCont;
		
		-- new blueprint mode container
		_this = ParaUI.CreateUIObject("container", "new_cont", "_mt",0,26,0,22);
		_this.background = ""
		_parent:AddChild(_this);
		
		_parent = _this;
		
		_this = ParaUI.CreateUIObject("text", "label3", "_lt", 3, 3, 42, 14)
		_this.text = "大小:";
		_parent:AddChild(_this);

		NPL.load("(gl)script/ide/dropdownlistbox.lua");
		local ctl = CommonCtrl.dropdownlistbox:new{
			name = "comboBoxBlueprintSize",
			alignment = "_lt",
			left = 51,
			top = 0,
			width = 80,
			height = 22,
			dropdownheight = 106,
 			parent = _parent,
			text = "10",
			AllowUserEdit = false,
			items = {"10", "20", "30", "50", "100", },
			onselect = BomWnd.OnSizeChangeBlueprint,
		};
		ctl:Show();

		_parent = _parentCont;
		
		-- bottom bar
		NPL.load("(gl)script/ide/progressbar.lua");
		local ctl = CommonCtrl.progressbar:new{
			name = "BomWnd_progressBarBom",
			alignment = "_mt",
			left = 0,
			top = 28,
			width = 0,
			height = 15,
 			parent = _parent,
			Minimum = 0,
			Maximum = 100,
			Step = 10,
			Value = 10,
			block_color = "10 36 106 190",
		};
		ctl:Show();

		NPL.load("(gl)script/ide/TreeView.lua");
		local ctl = CommonCtrl.TreeView:new{
			name = "BomWnd_treeViewBOMList",
			alignment = "_fi",
			left = 0,
			top = 49,
			width = 0,
			height = 44,
			parent = _parent,
			container_bg = "Texture/3DMapSystem/common/ThemeLightBlue/container_bg.png: 4 4 4 4",
			DefaultIndentation = 0,
			DefaultNodeHeight = 16,
		};
		local node = ctl.RootNode;
		ctl:Show();

		_this = ParaUI.CreateUIObject("button", "b1", "_lb", 0, -24, 50, 23)
		--_this.text = "预览";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "b2", "_lb", 50, -24, 50, 23)
		--_this.text = "施工";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "c", "_lb", 100, -24, 50, 23)
		_this.text = "关闭";
		_this.onclick = ";Map3DSystem.App.Blueprint.BomWnd.OnClickClose();"
		_parent:AddChild(_this);
	else
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		_parent = _this;
	end	
	if(bShow) then
		if(BomWnd.CurBom ~= nil) then
			-- manage hide and show controls according to the current status of the bom 
			local bom = BomWnd.CurBom;
			if(bom.status == BomWnd.BomStatus.Empty or 
				bom.status == BomWnd.BomStatus.Designing) then
				_this = _parent:GetChild("b1");
				_this.text = "打包"
				_this.onclick = ";Map3DSystem.App.Blueprint.BomWnd.SelectAllToBom();"
				_this = _parent:GetChild("b2");
				_this.text = "保存"
				_this.onclick = ";Map3DSystem.App.Blueprint.BomWnd.SaveBom();"
				_this = _parent:GetChild("title");
				_this.text = "点击打包,创建工程图"
				
				_parent:GetChild("preview_cont").visible = false;
				_parent:GetChild("new_cont").visible = true;
				local ctl= CommonCtrl.GetControl("BomWnd_progressBarBom");
				if(ctl~=nil)then
					ctl:Show(false);
				end
	
			elseif(bom.status == BomWnd.BomStatus.Preview) then
				_this = _parent:GetChild("b1");
				_this.text = "购买"
				_this.onclick = ";Map3DSystem.App.Blueprint.BomWnd.BuyBom();"
				_this = _parent:GetChild("b2");
				_this.text = "DIY"	
				_this.onclick = ";Map3DSystem.App.Blueprint.BomWnd.DIYBom();"
				_this = _parent:GetChild("title");
				_this.text = "预览工程图"
				_parent:GetChild("preview_cont").visible = true;
				
				_parent:GetChild("new_cont").visible = false;
				local ctl= CommonCtrl.GetControl("BomWnd_progressBarBom");
				if(ctl~=nil)then
					ctl:Show(false);
				end
				
			elseif(bom.status == BomWnd.BomStatus.Building or 
					bom.status == BomWnd.BomStatus.Deploying) then
				_this = _parent:GetChild("b1");
				_this.text = "预览"
				_this.onclick = ";Map3DSystem.App.Blueprint.BomWnd.PreviewBom();"
				_this = _parent:GetChild("b2");
				_this.text = "竣工"
				_this.onclick = ";Map3DSystem.App.Blueprint.BomWnd.FinishBom();"
				_this = _parent:GetChild("title");
				_this.text = "进度: 0%"
				
				_parent:GetChild("preview_cont").visible = false;
				_parent:GetChild("new_cont").visible = false;
				local ctl= CommonCtrl.GetControl("BomWnd_progressBarBom");
				if(ctl~=nil)then
					ctl:Show(true);
				end
			end
			-- update view
			BomWnd.UpdateTreeView();
		end
	else
		BomWnd.OnDestroy()
	end
end

-- destory the control
function BomWnd.OnDestroy()
	ParaUI.Destroy("BomWnd_cont");
	-- deselect bom 
	Map3DSystem.App.Blueprint.SelectBom(nil);
	-- remove selection
	ParaSelection.ClearGroup(1);
end

-- save the bom to file and optional publish it to app server. 
function BomWnd.SaveBom()
	NPL.load("(gl)script/kids/3DMapSystemApp/BlueprintApp/SaveBom.lua");
	Map3DSystem.App.Blueprint.ShowWnd(Map3DSystem.App.Blueprint.app._app);
end

-- Purchase the bom
function BomWnd.BuyBom()
	-- TODO: charge the user for the use of the bom. 
	
	local bom = BomWnd.CurBom;
	if(bom~=nil and bom.objects~=nil) then
		_guihelper.MessageBox(string.format("你确定购买使用此工程图么?\n您的开销为:%dP$, %dE$", bom.priceP or 0, bom.priceE or 0), function ()
			-- quit bom window. 
			BomWnd.OnClickClose()
			
			------------------------------------
			-- init scene content
			------------------------------------
			-- TODO: use a special shader that let each object falls down in a timer in the creation sequence 
			-- here I just simply create them all at once. 
			local i, objParam
			for i, objParam in ipairs(bom.objects) do
				local x,y,z = objParam.x, objParam.y, objParam.z;
				objParam = commonlib.MetaClone(objParam);
				objParam.x = bom.center.x + x;
				objParam.y = bom.center.y + y;
				objParam.z = bom.center.z + z;
				local obj = ObjEditor.CreateObjectByParams(objParam);
				if(obj~=nil and obj:IsValid()) then
					ParaScene.Attach(obj);
				end
			end
		end);
	end
end

-- TODO: save the bom to file and optional publish it to app server. 
function BomWnd.DIYBom()
	_guihelper.MessageBox("暂时不可用");
end

-- TODO: switch to preview mode
function BomWnd.PreviewBom()
	
end

-- TODO: finish DIY building 
function BomWnd.FinishBom()
end

-- when the user changes the size of the miniscene graph. 
function BomWnd.OnSizeChangeBlueprint(sCtrlName)
	local ctl = CommonCtrl.GetControl(sCtrlName);
	if(ctl~=nil)then
		local radius = tonumber(ctl:GetText());
		if(radius~=nil) then
			local bom = BomWnd.CurBom;
			if(bom~=nil) then
				bom.radius = radius;
				Map3DSystem.App.Blueprint.UpdateScenegraphHelper(bom)
			end
		end
	end
end

-- preview a ready-made blueprint in the current 3D scene using miniscenegraph. 
function BomWnd.OnClickPreviewInPlace()
	local bom = BomWnd.CurBom;
	if(bom~=nil and bom.objects~=nil) then
		-- TODO: use a special shader that let each object falls down in a timer in the creation sequence 
		-- here I just simply create them all at once. 
		------------------------------------
		-- init scene content
		------------------------------------
		Map3DSystem.App.Blueprint.UpdateScenegraphHelper(bom)
		local scene = ParaScene.GetMiniSceneGraph("blueprint");	
		local i, objParam
		for i, objParam in ipairs(bom.objects) do
			local x,y,z = objParam.x, objParam.y, objParam.z;
			objParam = commonlib.MetaClone(objParam);
			objParam.x = bom.center.x + x;
			objParam.y = bom.center.y + y;
			objParam.z = bom.center.z + z;
			local obj = ObjEditor.CreateObjectByParams(objParam);
			if(obj~=nil and obj:IsValid()) then
				scene:AddChild(obj);
			end
		end
	end
end

-- relocate the center position of the construction site at the current player location
-- @param x,y,z: if nil, the current player position is used. 
function BomWnd.OnClickPreviewRelocateCenter(x,y,z)
	if(x == nil or y == nil or z == nil) then
		x,y,z = ParaScene.GetPlayer():GetPosition();
	end
	
	-- relocate the center position. 
	local bom = BomWnd.CurBom;
	if(bom~=nil and bom.objects~=nil) then
		bom.center.x, bom.center.y, bom.center.z = x,y,z;
		Map3DSystem.App.Blueprint.UpdateScenegraphHelper(bom)
	end
end

-- close
function BomWnd.OnClickClose()
	if(BomWnd.parentWindow) then
		BomWnd.parentWindow:SendMessage(nil, {type = CommonCtrl.os.MSGTYPE.WM_CLOSE});
	end	
end

-- normal windows messages here
function BomWnd.MSGProc(window, msg)
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		BomWnd.OnDestroy();
		window:DestroyWindowFrame();
	end
end