--[[
Title: A wizard to Create a new game world 
Author(s): LiXizhi
Date: 2007/4/11
Revised: 2007/10/6
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/CreateWorldWnd.lua");
Map3DSystem.UI.CreateWorldWnd.Show
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/ide/FileDialog.lua");

--KidsUI.DefaultLoadWorld = L("tutorial1","path");
KidsUI.DefaultLoadWorld = "";

if(not Map3DSystem.UI.CreateWorldWnd) then Map3DSystem.UI.CreateWorldWnd={}; end

-- appearance
Map3DSystem.UI.CreateWorldWnd.main_bg = "";
Map3DSystem.UI.CreateWorldWnd.panel_bg = "";
Map3DSystem.UI.CreateWorldWnd.panel_sub_bg = ""

Map3DSystem.UI.CreateWorldWnd.tabpages = {[1] = "tabPageNewWorld", [2] = "tabPageNewWorldCreated", };

-- @param bShow: show or hide the panel 
-- @param _parent: parent window inside which the content is displayed. it can be nil.
function Map3DSystem.UI.CreateWorldWnd.Show(bShow,_parent, parentWindow)
	local _this;
	local left, top, width, height;

	Map3DSystem.UI.CreateWorldWnd.parentWindow = parentWindow;

	_this=ParaUI.GetUIObject("Map3DSystem.UI.CreateWorldWnd");
	if(_this:IsValid()) then
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		_this.visible = bShow;
		if(bShow == false) then
			Map3DSystem.UI.CreateWorldWnd.OnDestory();
		end
	else
		if(bShow == false) then return	end
		
		width, height = 480, 512
		-- Map3DSystem.UI.CreateWorldWnd
		_this = ParaUI.CreateUIObject("container", "Map3DSystem.UI.CreateWorldWnd", "_ct", -width/2, -height/2, width, height)
		_this.background=Map3DSystem.UI.CreateWorldWnd.main_bg;
		if(_parent==nil) then
			_this:AttachToRoot();
		else
			_parent:AddChild(_this);
		end
		_parent = _this;
		

		-- tabPageNewWorld
		_this = ParaUI.CreateUIObject("container", "tabPageNewWorld", "_fi", 0, 32, 0, 0)
		_this.background=Map3DSystem.UI.CreateWorldWnd.panel_bg;
		_parent = ParaUI.GetUIObject("Map3DSystem.UI.CreateWorldWnd");
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("text", "label2", "_lt", 10, 13, 296, 16)
		_this.text = "Enter world name and click OK button";
		_this:GetFont("text").color = "65 105 225";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "WM_NEW_OKBtn", "_lb", 13, -39, 105, 26)
		_this.text = "OK";
		_this.onclick=";Map3DSystem.UI.CreateWorldWnd.On_WM_NEW_OKBtn();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "WM_NEW_CancelBtn", "_lb", 139, -39, 105, 26)
		_this.text = "Cancel";
		_this.onclick=";Map3DSystem.UI.CreateWorldWnd.OnClose();"
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label3", "_lt", 10, 40, 88, 16)
		_this.text = "World Name";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label4", "_lt", 10, 72, 96, 16)
		_this.text = "Author Name";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("imeeditbox", "WM_NEW_WorldName", "_lt", 113, 37, 167, 26)
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("imeeditbox", "WM_NEW_AuthorName", "_lt", 113, 69, 167, 26)
		_parent:AddChild(_this);

		-- panel1
		_this = ParaUI.CreateUIObject("container", "WM_Panel", "_fi", 3, 102, 3, 45)
		_this.background=Map3DSystem.UI.CreateWorldWnd.panel_sub_bg;
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("listbox", "WM_NEW_BaseWorldList", "_fi", 52, 138, 16, 10)
		_this.wordbreak = false;
		_this.itemheight = 18;
		_this.onselect=";Map3DSystem.UI.CreateWorldWnd.NewWorld_OnParentWorldListSelect();";
		_this.font = "System;13;norm";
		_this.scrollbarwidth = 20;
		_parent:AddChild(_this);

		-- list all sub directories in the User directory.
		CommonCtrl.InitFileDialog(ParaIO.GetCurDirectory(0)..Map3DSystem.worlddir,"*.", 0, 150, _this);
			
		NPL.load("(gl)script/ide/RadioBox.lua");
		local ctl = CommonCtrl.radiobox:new{
			name = "WM_NEW_Radio_UseBaseWorld",
			alignment = "_lt",
			left = 21,
			top = 42,
			width = 354,
			height = 20,
			parent = _parent,
			isChecked = false,
			checked_bg = "Texture/3DMapSystem/common/ThemeLightBlue/radiobox.png",
			unchecked_bg = "Texture/3DMapSystem/common/ThemeLightBlue/unradiobox.png",
			text = "Create a world based on an existing world",
			--oncheck = Map3DSystem.UI.CreateWorldWnd.OnCheckNewWorldUseBaseWorld,
		};
		ctl:Show();

		NPL.load("(gl)script/ide/RadioBox.lua");
		local ctl = CommonCtrl.radiobox:new{
			name = "WM_NEW_Radio_CreateEmptyWorld",
			alignment = "_lt",
			left = 21,
			top = 16,
			width = 194,
			height = 20,
			parent = _parent,
			isChecked = true,
			checked_bg = "Texture/3DMapSystem/common/ThemeLightBlue/radiobox.png",
			unchecked_bg = "Texture/3DMapSystem/common/ThemeLightBlue/unradiobox.png",
			text = "Create an empty world",
			--oncheck = Map3DSystem.UI.CreateWorldWnd.OnCheckNewWorldUseEmptyWorld,
		};
		ctl:Show();

		NPL.load("(gl)script/ide/CheckBox.lua");
		local ctl = CommonCtrl.checkbox:new{
			name = "WM_NEW_Check_UseSceneObject",
			alignment = "_lt",
			left = 52,
			top = 77,
			width = 307,
			height = 20,
			parent = _parent,
			isChecked = true,
			checked_bg = "Texture/3DMapSystem/common/ThemeLightBlue/checkbox.png",
			unchecked_bg = "Texture/3DMapSystem/common/ThemeLightBlue/uncheckbox.png",
			text = "Use scene objects in the base world",
		};
		ctl:Show();

		NPL.load("(gl)script/ide/CheckBox.lua");
		local ctl = CommonCtrl.checkbox:new{
			name = "WM_NEW_Check_UseBaseWorldNPC",
			alignment = "_lt",
			left = 52,
			top = 103,
			width = 283,
			height = 20,
			parent = _parent,
			isChecked = false,
			checked_bg = "Texture/3DMapSystem/common/ThemeLightBlue/checkbox.png",
			unchecked_bg = "Texture/3DMapSystem/common/ThemeLightBlue/uncheckbox.png",
			text = "Use characters in the base world",
		};
		ctl:Show();

		-- tabPageNewWorldCreated
		_this = ParaUI.CreateUIObject("container", "tabPageNewWorldCreated", "_fi", 0, 32, 0, 0)
		_this.background=Map3DSystem.UI.CreateWorldWnd.panel_bg;
		_parent = ParaUI.GetUIObject("Map3DSystem.UI.CreateWorldWnd");
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("text", "label5", "_lt", 6, 16, 144, 16)
		_this.text = "Congratulations!";
		_this:GetFont("text").color = "220 20 60";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label6", "_lt", 34, 42, 368, 16)
		_this.text = "You have successfully created a new world at:";
		_this:GetFont("text").color = "65 105 225";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "WM_NEWC_OKButton", "_lb", 9, -39, 125, 26)
		_this.text = "Start World";
		_this.onclick = ";Map3DSystem.UI.CreateWorldWnd.On_WM_NEWC_StartButton();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "WM_NEWC_StartButton", "_lb", 131, -303, 112, 26)
		_this.text = "Start World";
		_this.onclick = ";Map3DSystem.UI.CreateWorldWnd.On_WM_NEWC_StartButton();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "WM_NEWC_CancelBtn", "_rb", -118, -39, 105, 26)
		_this.text = "Cancel";
		_this.onclick=";Map3DSystem.UI.CreateWorldWnd.OnClose();"
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "WM_NEWC_worldpath", "_lt", 34, 71, 144, 16)
		_parent:AddChild(_this);

		-- switch to a tab page
		Map3DSystem.UI.CreateWorldWnd.SwitchTabWindow(1);
	end	
end

-- destory the control
function Map3DSystem.UI.CreateWorldWnd.OnDestory()
	ParaUI.Destroy("Map3DSystem.UI.CreateWorldWnd");
end

function Map3DSystem.UI.CreateWorldWnd.OnClose()
	if(Map3DSystem.UI.CreateWorldWnd.parentWindow~=nil) then
		-- send a message to its parent window to tell it to close. 
		Map3DSystem.UI.CreateWorldWnd.parentWindow:SendMessage(Map3DSystem.UI.CreateWorldWnd.parentWindow.name, CommonCtrl.os.MSGTYPE.WM_CLOSE);
	else
		ParaUI.Destroy("Map3DSystem.UI.CreateWorldWnd");
	end
end

---------------------------------------------------------
-- private functions
---------------------------------------------------------
-- @param nIndex: 1 or 2
function Map3DSystem.UI.CreateWorldWnd.SwitchTabWindow(nIndex)
	if(Map3DSystem.UI.CreateWorldWnd.tabpages~=nil) then
		_guihelper.SwitchVizGroupByIndex(Map3DSystem.UI.CreateWorldWnd.tabpages, nIndex);
		if(nIndex == 2) then
			-- new world created
			if(Map3DSystem.UI.CreateWorldWnd.NewWorldPath~=nil) then
				ParaUI.GetUIObject("WM_NEWC_worldpath").text = Map3DSystem.UI.CreateWorldWnd.NewWorldPath;
			end	
		end
	end	
end


---------------------------
-- for tab page: new world 
---------------------------

-- when the user new world button is clicked.
function Map3DSystem.UI.CreateWorldWnd.On_WM_NEW_OKBtn()
	local worldpath, BaseWorldPath;
	
	local RadioBoxUseBaseWorld = CommonCtrl.GetControl("WM_NEW_Radio_UseBaseWorld");
	if(RadioBoxUseBaseWorld~=nil and RadioBoxUseBaseWorld:GetCheck()) then
		BaseWorldPath = Map3DSystem.UI.CreateWorldWnd.BaseWorldPath;
		--local ComboBoxBaseWorld = CommonCtrl.GetControl("SOME_comboBox");
		--if(ComboBoxBaseWorld~=nil) then
			--BaseWorldPath = ComboBoxBaseWorld:GetText();
		--end	
	end
		
	local tmp = ParaUI.GetUIObject("WM_NEW_WorldName");
	if(tmp:IsValid() == true) then 
		local sName = tmp.text;
		if(sName == "") then
			_guihelper.MessageBox("world name can not be empty".."\n");
		elseif(sName == "_emptyworld") then
			_guihelper.MessageBox("_emptyworld presents an empty world. Please use another name.".."\n");
		else
			worldpath = Map3DSystem.worlddir..sName;-- append the world dir name
			
			local CheckBoxUseBaseWorldNPC = CommonCtrl.GetControl("WM_NEW_Check_UseBaseWorldNPC");
			local bInheriteNPC = (CheckBoxUseBaseWorldNPC~=nil and CheckBoxUseBaseWorldNPC:GetCheck());
			
			-- create a new world
			local res = Map3DSystem.CreateWorld(worldpath, BaseWorldPath, bInheriteNPC);
			if(res == true) then
				-- load success UI
				Map3DSystem.UI.CreateWorldWnd.NewWorldPath = worldpath;
				Map3DSystem.UI.CreateWorldWnd.NewWorldCreatedUI();
			elseif(type(res) == "string") then
				_guihelper.MessageBox(res);
			end
		end
	end
end

function Map3DSystem.UI.CreateWorldWnd.NewWorld_OnParentWorldListSelect()
	local tmp = ParaUI.GetUIObject("WM_NEW_BaseWorldList");
	if(tmp:IsValid() == true) then 
		local sName = tmp.text;
		Map3DSystem.UI.CreateWorldWnd.BaseWorldPath = Map3DSystem.worlddir..sName;
	end
end
---------------------------
-- for tab page: new world created
---------------------------
-- show another UI, whenever a new world has been successfully created.
function Map3DSystem.UI.CreateWorldWnd.NewWorldCreatedUI()
	Map3DSystem.UI.CreateWorldWnd.SwitchTabWindow(2);
end

function Map3DSystem.UI.CreateWorldWnd.On_WM_NEWC_StartButton()
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