--[[
Title: A wizard to Create a new game world 
Author(s): WangTian
Date: 2008/1/7
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/NewWorld/NewWorldWnd.lua");
Map3DSystem.App.NewWorld.NewWorldWnd.ShowWnd(_app)
Map3DSystem.App.NewWorld.NewWorldWnd.Show(bShow, _parent, parentWindow)
-------------------------------------------------------
]]
-- create class
commonlib.setfield("Map3DSystem.App.NewWorld.NewWorldWnd", {});

-- display the main inventory window for the current user.
function  Map3DSystem.App.NewWorld.NewWorldWnd.ShowWnd(_app)
	NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
	local _wnd = _app:FindWindow("NewWorldWnd") or _app:RegisterWindow("NewWorldWnd", nil, Map3DSystem.App.NewWorld.NewWorldWnd.MSGProc);
	
	local _appName, _wndName, _document, _frame;
	_frame = Map3DSystem.UI.Windows.GetWindowFrame(_wnd.app.name, _wnd.name);
	if(_frame) then
		_appName = _frame.wnd.app.name;
		_wndName = _frame.wnd.name;
		_document = ParaUI.GetUIObject(_appName.."_".._wndName.."_window_document");
	else
		local param = {
			wnd = _wnd,
			--isUseUI = true,
			icon = "Texture/3DMapSystem/MainBarIcon/NewWorld_1.png",
			iconSize = 48,
			text = "新建世界向导",
			style = Map3DSystem.UI.Windows.Style[1],
			maximumSizeX = 800,
			maximumSizeY = 800,
			minimumSizeX = 600,
			minimumSizeY = 600,
			isShowIcon = true,
			--opacity = 100, -- [0, 100]
			isShowMaximizeBox = false,
			isShowMinimizeBox = false,
			isShowAutoHideBox = false,
			allowDrag = true,
			allowResize = false,
			initialPosX = 112,
			initialPosY = 50,
			initialWidth = 800,
			initialHeight = 600,
			
			ShowUICallback = Map3DSystem.App.NewWorld.NewWorldWnd.Show,
		};
		_appName, _wndName, _document, _frame = Map3DSystem.UI.Windows.RegisterWindowFrame(param);
	end
	Map3DSystem.UI.Windows.ShowWindow(true, _appName, _wndName);
end

-- @param bShow: show or hide the panel 
-- @param _parent: parent window inside which the content is displayed. it can be nil.
function Map3DSystem.App.NewWorld.NewWorldWnd.Show(bShow, _parent, parentWindow)
	
	local _this;
	local left, top, width, height;

	Map3DSystem.App.NewWorld.NewWorldWnd.parentWindow = parentWindow;

	_this=ParaUI.GetUIObject("Map3DSystem.App.NewWorld.NewWorldWnd");
	if(_this:IsValid() == true) then
		_this.visible = bShow;
		if(not bShow) then
			Map3DSystem.App.NewWorld.NewWorldWnd.OnDestroy()
		end
	else
		if(bShow == false) then return	end
		
		width, height = 680, 480;
		-- Map3DSystem.App.NewWorld.NewWorldWnd
		local _wizard = ParaUI.CreateUIObject("container", "Map3DSystem.App.NewWorld.NewWorldWnd", "_ct", -width/2, -height/2, width, height);
		--_wizard.background = "" -- Map3DSystem.App.NewWorld.NewWorldWnd.window_BG;
		if(_parent == nil) then
			_wizard:AttachToRoot();
		else
			_parent:AddChild(_wizard);
		end
		
		-------------------------------------
		-- First level interface
		-------------------------------------
		
		-- please select base world
		local _pleaseSelect = ParaUI.CreateUIObject("text", "PleaseSelect", "_lt", 10, 10, 350, 24);
		_pleaseSelect.text = "请从下面列表中选择新建世界的样式:";
		_wizard:AddChild(_pleaseSelect);
		
		-- Category box
		local _categoryBox = ParaUI.CreateUIObject("container", "CategoryBox", "_ml", 10, 40, 150, 64);
		--_categoryBox.background = ""; -- Map3DSystem.App.NewWorld.NewWorldWnd.categoryBox_BG;
		_wizard:AddChild(_categoryBox);
		
		-- Template icons box
		local _templateViewBox = ParaUI.CreateUIObject("container", "TemplateViewBox", "_ml", 170, 40, 250, 64);
		--_templateViewBox.background = ""; -- Map3DSystem.App.NewWorld.NewWorldWnd.templateViewBox_BG;
		_wizard:AddChild(_templateViewBox);
		
		-- Preview box
		local _previewBox = ParaUI.CreateUIObject("container", "PreviewBox", "_ml", 420, 40, 250, 64);
		--_previewBox.background = ""; -- Map3DSystem.App.NewWorld.NewWorldWnd.previewBox_BG;
		_wizard:AddChild(_previewBox);
		
		
		Map3DSystem.App.NewWorld.NewWorldWnd.toggleAdvanced_Opened_BG = "Texture/Themes/Original/NewWorldWizard/AdvancedUp.png";
		Map3DSystem.App.NewWorld.NewWorldWnd.toggleAdvanced_Closed_BG = "Texture/Themes/Original/NewWorldWizard/AdvancedDown.png";
		
		-- Advanced options
		local _toggleAdvanced = ParaUI.CreateUIObject("button", "ToggleAdvanced", "_lb", 15, -50, 24, 24);
		_toggleAdvanced.background = Map3DSystem.App.NewWorld.NewWorldWnd.toggleAdvanced_Closed_BG;
		_wizard:AddChild(_toggleAdvanced);
		local _toggleAdvancedText = ParaUI.CreateUIObject("text", "ToggleAdvancedText", "_lb", 50, -40, 50, 16);
		_toggleAdvancedText.text = "高级";
		_wizard:AddChild(_toggleAdvancedText);
		
		-- World name
		local _worldNameText = ParaUI.CreateUIObject("text", "WorldNameText", "_lb", 120, -40, 80, 16);
		_worldNameText.text = "世界名称:";
		_wizard:AddChild(_worldNameText);
		local _worldName = ParaUI.CreateUIObject("editbox", "WorldName", "_mb", 200, 20, 220, 28);
		_wizard:AddChild(_worldName);
		
		-- Create world
		local _createWorld = ParaUI.CreateUIObject("button", "CreateWorld", "_rb", -200, -50, 80, 32);
		_createWorld.text = "创建";
		_createWorld.onclick = ";Map3DSystem.App.NewWorld.NewWorldWnd.OnCreateWorld();";
		_wizard:AddChild(_createWorld);
		
		-- Cancel
		local _cancel = ParaUI.CreateUIObject("button", "Cancel", "_rb", -100, -50, 80, 32);
		_cancel.text = "取消";
		_cancel.onclick = ";Map3DSystem.App.NewWorld.NewWorldWnd.OnCancel();";
		_wizard:AddChild(_cancel);
		
		
		-------------------------------------
		-- Category box
		-------------------------------------
		
		NPL.load("(gl)script/ide/TreeView.lua");
		local ctl = CommonCtrl.TreeView:new{
			name = "NewWorldWizard.CategoryBox",
			alignment = "_fi",
			left = 0,
			top = 0,
			width = 0,
			height = 0,
			parent = _categoryBox,
			DrawNodeHandler = nil,
		};
		local node = ctl.RootNode;
		node:AddChild(CommonCtrl.TreeNode:new({Text = "Category1", Name = "Category1"}));
		node:AddChild(CommonCtrl.TreeNode:new({Text = "Category2", Name = "Category2"}));
		node:AddChild(CommonCtrl.TreeNode:new({Text = "Category3", Name = "Category3"}));
		node:AddChild(CommonCtrl.TreeNode:new({Text = "Category4", Name = "Category4"}));
		node:AddChild(CommonCtrl.TreeNode:new({Text = "Empty World", Name = "Empty"}));
		node:AddChild(CommonCtrl.TreeNode:new({Text = "-----------", Name = "Separator"}));
		node:AddChild(CommonCtrl.TreeNode:new({Text = "Online1", Name = "Online1"}));
		node:AddChild(CommonCtrl.TreeNode:new({Text = "Online2", Name = "Online2"}));
		node:AddChild(CommonCtrl.TreeNode:new({Text = "Online3", Name = "Online3"}));
		node:AddChild(CommonCtrl.TreeNode:new({Text = "Online4", Name = "Online4"}));
		
		ctl:Show();
		
		-------------------------------------
		-- Template icons box
		-------------------------------------
		
		--NPL.load("(gl)script/ide/TreeView.lua");
		--local ctl = CommonCtrl.TreeView:new{
			--name = "NewWorldWizard.TemplateViewBox",
			--alignment = "_fi",
			--left = 0,
			--top = 0,
			--width = 0,
			--height = 0,
			--parent = _templateViewBox,
			--DrawNodeHandler = nil,
		--};
		--
		---- list all files in the world directory.
		--local search_result = ParaIO.SearchFiles(ParaIO.GetCurDirectory(0)..Map3DSystem.worlddir, "*.", "", 0, 150, 0);
		--local nCount = search_result:GetNumOfResult();
		--local i;
		--local node = ctl.RootNode;
		--for i = 0, nCount - 1 do 
			--node:AddChild(CommonCtrl.TreeNode:new({
					--Text = search_result:GetItem(i), 
					--Name = search_result:GetItem(i)
					--}));
		--end
		--search_result:Release();
		--
		--ctl:Show();
		
		
		-- world list box
		local _worldList = ParaUI.CreateUIObject("listbox", "NewWorldWizard.WorldList", "_fi", 0, 0, 0, 0);
		_worldList.wordbreak = false;
		_worldList.itemheight = 18;
		_worldList.onselect = ";Map3DSystem.App.NewWorld.NewWorldWnd.OnWorldSelect();";
		_worldList.font = "System;13;norm";
		_worldList.scrollbarwidth = 20;
		_templateViewBox:AddChild(_worldList);
		
		
		-- list all files in the world directory.
		local search_result = ParaIO.SearchFiles(ParaIO.GetCurDirectory(0)..Map3DSystem.worlddir, "*.", "", 0, 150, 0);
		local nCount = search_result:GetNumOfResult();
		local i;
		local node = ctl.RootNode;
		for i = 0, nCount - 1 do 
			_worldList:AddTextItem(search_result:GetItem(i));
		end
		search_result:Release();
				
		-------------------------------------
		-- Preview box
		-------------------------------------
		
		Map3DSystem.App.NewWorld.NewWorldWnd.previewDefaultImage = "Texture/Themes/Original/NewWorldWizard/WorldPreviewDefault.png";
		
		-- preview image
		local _previewImage = ParaUI.CreateUIObject("container", "NewWorldWizard.PreviewImage", "_lt", 60, 30, 128, 128);
		_previewImage.enable = false;
		_previewImage.background = Map3DSystem.App.NewWorld.NewWorldWnd.previewDefaultImage;
		_previewBox:AddChild(_previewImage);
		
		NPL.load("(gl)script/ide/TreeView.lua");
		local ctl = CommonCtrl.TreeView:new{
			name = "NewWorldWizard.PreviewDesc",
			alignment = "_fi",
			left = 0,
			top = 170,
			width = 0,
			height = 0,
			parent = _previewBox,
			DrawNodeHandler = nil,
		};
		local node = ctl.RootNode;
		node:AddChild(CommonCtrl.TreeNode:new({Text = "Name:", Name = "Name"}));
		node:AddChild(CommonCtrl.TreeNode:new({Text = "Author:", Name = "Author"}));
		node:AddChild(CommonCtrl.TreeNode:new({Text = "Applications:", Name = "Applications"}));
		node:AddChild(CommonCtrl.TreeNode:new({Text = "Created:", Name = "Created"}));
		node:AddChild(CommonCtrl.TreeNode:new({Text = "Tag:", Name = "Tag"}));
		node:AddChild(CommonCtrl.TreeNode:new({Text = "Desc:", Name = "Desc"}));
		
		ctl:Show();
		
		
		
--
		---- tabPageNewWorld
		--_this = ParaUI.CreateUIObject("container", "tabPageNewWorld", "_fi", 0, 32, 0, 0)
		--_this.background=Map3DSystem.UI.CreateWorldWnd.panel_bg;
		--_parent = ParaUI.GetUIObject("Map3DSystem.UI.CreateWorldWnd");
		--_parent:AddChild(_this);
		--_parent = _this;
--
		--_this = ParaUI.CreateUIObject("text", "label2", "_lt", 10, 13, 296, 16)
		--_this.text = "Enter world name and click OK button";
		--_this:GetFont("text").color = "65 105 225";
		--_parent:AddChild(_this);
--
		--_this = ParaUI.CreateUIObject("button", "WM_NEW_OKBtn", "_lb", 13, -39, 105, 26)
		--_this.text = "OK";
		--_this.onclick=";Map3DSystem.UI.CreateWorldWnd.On_WM_NEW_OKBtn();";
		--_parent:AddChild(_this);
--
		--_this = ParaUI.CreateUIObject("button", "WM_NEW_CancelBtn", "_lb", 139, -39, 105, 26)
		--_this.text = "Cancel";
		--_this.onclick=";Map3DSystem.UI.CreateWorldWnd.OnClose();"
		--_parent:AddChild(_this);
--
		--_this = ParaUI.CreateUIObject("text", "label3", "_lt", 10, 40, 88, 16)
		--_this.text = "World Name";
		--_parent:AddChild(_this);
--
		--_this = ParaUI.CreateUIObject("text", "label4", "_lt", 10, 72, 96, 16)
		--_this.text = "Author Name";
		--_parent:AddChild(_this);
--
		--_this = ParaUI.CreateUIObject("imeeditbox", "WM_NEW_WorldName", "_lt", 113, 37, 167, 26)
		--_parent:AddChild(_this);
--
		--_this = ParaUI.CreateUIObject("imeeditbox", "WM_NEW_AuthorName", "_lt", 113, 69, 167, 26)
		--_parent:AddChild(_this);
--
		---- panel1
		--_this = ParaUI.CreateUIObject("container", "WM_Panel", "_fi", 3, 102, 3, 45)
		--_this.background=Map3DSystem.UI.CreateWorldWnd.panel_sub_bg;
		--_parent:AddChild(_this);
		--_parent = _this;
--
		--_this = ParaUI.CreateUIObject("listbox", "WM_NEW_BaseWorldList", "_fi", 52, 138, 16, 10)
		--_this.wordbreak = false;
		--_this.itemheight = 18;
		--_this.onselect=";Map3DSystem.UI.CreateWorldWnd.NewWorld_OnParentWorldListSelect();";
		--_this.font = "System;13;norm";
		--_this.scrollbarwidth = 20;
		--_parent:AddChild(_this);
--
		---- list all sub directories in the User directory.
		--CommonCtrl.InitFileDialog(ParaIO.GetCurDirectory(0)..Map3DSystem.worlddir,"*.", 0, 150, _this);
			--
		--NPL.load("(gl)script/ide/RadioBox.lua");
		--local ctl = CommonCtrl.radiobox:new{
			--name = "WM_NEW_Radio_UseBaseWorld",
			--alignment = "_lt",
			--left = 21,
			--top = 42,
			--width = 354,
			--height = 20,
			--parent = _parent,
			--isChecked = false,
			--checked_bg = "Texture/3DMapSystem/common/ThemeLightBlue/radiobox.png",
			--unchecked_bg = "Texture/3DMapSystem/common/ThemeLightBlue/unradiobox.png",
			--text = "Create a world based on an existing world",
			----oncheck = Map3DSystem.UI.CreateWorldWnd.OnCheckNewWorldUseBaseWorld,
		--};
		--ctl:Show();
--
		--NPL.load("(gl)script/ide/RadioBox.lua");
		--local ctl = CommonCtrl.radiobox:new{
			--name = "WM_NEW_Radio_CreateEmptyWorld",
			--alignment = "_lt",
			--left = 21,
			--top = 16,
			--width = 194,
			--height = 20,
			--parent = _parent,
			--isChecked = true,
			--checked_bg = "Texture/3DMapSystem/common/ThemeLightBlue/radiobox.png",
			--unchecked_bg = "Texture/3DMapSystem/common/ThemeLightBlue/unradiobox.png",
			--text = "Create an empty world",
			----oncheck = Map3DSystem.UI.CreateWorldWnd.OnCheckNewWorldUseEmptyWorld,
		--};
		--ctl:Show();
--
		--NPL.load("(gl)script/ide/CheckBox.lua");
		--local ctl = CommonCtrl.checkbox:new{
			--name = "WM_NEW_Check_UseSceneObject",
			--alignment = "_lt",
			--left = 52,
			--top = 77,
			--width = 307,
			--height = 20,
			--parent = _parent,
			--isChecked = true,
			--checked_bg = "Texture/3DMapSystem/common/ThemeLightBlue/checkbox.png",
			--unchecked_bg = "Texture/3DMapSystem/common/ThemeLightBlue/uncheckbox.png",
			--text = "Use scene objects in the base world",
		--};
		--ctl:Show();
--
		--NPL.load("(gl)script/ide/CheckBox.lua");
		--local ctl = CommonCtrl.checkbox:new{
			--name = "WM_NEW_Check_UseBaseWorldNPC",
			--alignment = "_lt",
			--left = 52,
			--top = 103,
			--width = 283,
			--height = 20,
			--parent = _parent,
			--isChecked = false,
			--checked_bg = "Texture/3DMapSystem/common/ThemeLightBlue/checkbox.png",
			--unchecked_bg = "Texture/3DMapSystem/common/ThemeLightBlue/uncheckbox.png",
			--text = "Use characters in the base world",
		--};
		--ctl:Show();
--
		---- tabPageNewWorldCreated
		--_this = ParaUI.CreateUIObject("container", "tabPageNewWorldCreated", "_fi", 0, 32, 0, 0)
		--_this.background=Map3DSystem.UI.CreateWorldWnd.panel_bg;
		--_parent = ParaUI.GetUIObject("Map3DSystem.UI.CreateWorldWnd");
		--_parent:AddChild(_this);
		--_parent = _this;
--
		--_this = ParaUI.CreateUIObject("text", "label5", "_lt", 6, 16, 144, 16)
		--_this.text = "Congratulations!";
		--_this:GetFont("text").color = "220 20 60";
		--_parent:AddChild(_this);
--
		--_this = ParaUI.CreateUIObject("text", "label6", "_lt", 34, 42, 368, 16)
		--_this.text = "You have successfully created a new world at:";
		--_this:GetFont("text").color = "65 105 225";
		--_parent:AddChild(_this);
--
		--_this = ParaUI.CreateUIObject("button", "WM_NEWC_OKButton", "_lb", 9, -39, 125, 26)
		--_this.text = "Start World";
		--_this.onclick = ";Map3DSystem.UI.CreateWorldWnd.On_WM_NEWC_StartButton();";
		--_parent:AddChild(_this);
--
		--_this = ParaUI.CreateUIObject("button", "WM_NEWC_StartButton", "_lb", 131, -303, 112, 26)
		--_this.text = "Start World";
		--_this.onclick = ";Map3DSystem.UI.CreateWorldWnd.On_WM_NEWC_StartButton();";
		--_parent:AddChild(_this);
--
		--_this = ParaUI.CreateUIObject("button", "WM_NEWC_CancelBtn", "_rb", -118, -39, 105, 26)
		--_this.text = "Cancel";
		--_this.onclick=";Map3DSystem.UI.CreateWorldWnd.OnClose();"
		--_parent:AddChild(_this);
--
		--_this = ParaUI.CreateUIObject("text", "WM_NEWC_worldpath", "_lt", 34, 71, 144, 16)
		--_parent:AddChild(_this);
--
	end	
end

-- destroy the control
function Map3DSystem.App.NewWorld.NewWorldWnd.OnDestroy()
	ParaUI.Destroy("Map3DSystem.App.NewWorld.NewWorldWnd");
end

function Map3DSystem.App.NewWorld.NewWorldWnd.OnCreateWorld()
	
	local worldpath, BaseWorldPath;
	
	BaseWorldPath = Map3DSystem.App.NewWorld.NewWorldWnd.BaseWorldPath;
	
	local _wizard = ParaUI.GetUIObject("Map3DSystem.App.NewWorld.NewWorldWnd");
	
	local tmp = _wizard:GetChild("WorldName");
	if(tmp:IsValid() == true) then 
		local sName = tmp.text;
		if(sName == "") then
			_guihelper.MessageBox("世界名称不能为空");
		elseif(sName == "_emptyworld") then
			_guihelper.MessageBox("_emptyworld是系统隐含世界，它代表一个空世界。请使用其他名字创建世界");
		else
			worldpath = Map3DSystem.worlddir..sName;-- append the world dir name
			
			--local CheckBoxUseBaseWorldNPC = CommonCtrl.GetControl("WM_NEW_Check_UseBaseWorldNPC");
			
			local bInheriteNPC = true; -- TODO: advanced UI to specify this tag
			
			-- create a new world
			local res = Map3DSystem.CreateWorld(worldpath, BaseWorldPath, bInheriteNPC);
			if(res == true) then
				
				-- TODO: load success UI
				-- TODO: option to enter newly created world
				_guihelper.MessageBox("新建世界\""..sName.."\"成功，你想进入刚刚创建好的世界么?", 
						Map3DSystem.App.NewWorld.NewWorldWnd.LoadNewlyCreatedWorld);
				
			elseif(type(res) == "string") then
				_guihelper.MessageBox(res);
			end
		end
	end
end

function Map3DSystem.App.NewWorld.NewWorldWnd.LoadNewlyCreatedWorld()
	--local worldName = Map3DSystem.App.NewWorld.NewWorldWnd.NewlyCreatedWorld;
	if(Map3DSystem.World.sConfigFile ~= "") then
		local res = Map3DSystem.LoadWorld(Map3DSystem.World.name);
		if(res==true) then
			-- TODO: show something when the world is created for the first time.
			Map3DSystem.User.SetRole("administrator");
		elseif(type(res) == "string") then
			-- show the error message
			_guihelper.MessageBox(res);
		end
	end
end

function Map3DSystem.App.NewWorld.NewWorldWnd.OnCancel()
	if(Map3DSystem.App.NewWorld.NewWorldWnd.parentWindow~=nil) then
		-- send a message to its parent window to tell it to close. 
		Map3DSystem.App.NewWorld.NewWorldWnd.parentWindow:SendMessage(Map3DSystem.App.NewWorld.NewWorldWnd.parentWindow.name, CommonCtrl.os.MSGTYPE.WM_CLOSE);
	else
		ParaUI.Destroy("Map3DSystem.App.NewWorld.NewWorldWnd");
	end
end

function Map3DSystem.App.NewWorld.NewWorldWnd.OnWorldSelect()
	--_guihelper.MessageBox("World Select\n");
	
	local tmp = ParaUI.GetUIObject("NewWorldWizard.WorldList");
	if(tmp:IsValid() == true) then 
		local sName = tmp.text;
		-- TODO: refresh the preview
		Map3DSystem.App.NewWorld.NewWorldWnd.BaseWorldPath = Map3DSystem.worlddir..sName;
		
		local ctl = CommonCtrl.GetControl("NewWorldWizard.PreviewDesc");
		
		if(ctl ~= nil) then
			local root = ctl.RootNode;
			
			-- update the preview information
			local node = root:GetChildByName("Name");
			node.Text = "Name: "..sName;
			
			ctl:Update();
			
			--local _previewImage = ParaUI.CreateUIObject("container", "NewWorldWizard.PreviewImage", "_lt", 60, 30, 128, 128);
			--node:AddChild(CommonCtrl.TreeNode:new({Text = "Name:", Name = "Name"}));
			--node:AddChild(CommonCtrl.TreeNode:new({Text = "Author:", Name = "Auther"}));
			--node:AddChild(CommonCtrl.TreeNode:new({Text = "Applications:", Name = "Applications"}));
			--node:AddChild(CommonCtrl.TreeNode:new({Text = "Created:", Name = "Created"}));
			--node:AddChild(CommonCtrl.TreeNode:new({Text = "Tag:", Name = "Tag"}));
			--node:AddChild(CommonCtrl.TreeNode:new({Text = "Desc:", Name = "Desc"}));
		end
		
	end
end

function Map3DSystem.App.NewWorld.NewWorldWnd.MSGProc(window, msg)

	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		Map3DSystem.UI.Windows.ShowWindow(false, Map3DSystem.App.NewWorld.NewWorldWnd.parentWindow.app.name, msg.wndName);
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_MINIMIZE) then
	end
end
