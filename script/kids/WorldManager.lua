--[[
Title: world manager for kids movie
Author(s): LiXizhi
Date: 2007/4/11
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/WorldManager.lua");
WorldManager.Show();
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/kids/newworld.lua");
NPL.load("(gl)script/kids/loadworld.lua");
NPL.load("(gl)script/ide/FileDialog.lua");

local L = CommonCtrl.Locale("KidsUI");
KidsUI.DefaultLoadWorld = L("tutorial1","path");

if(not WorldManager) then WorldManager={}; end

-- appearance
WorldManager.main_bg = "Texture/kidui/worldmanager/bg.png"
WorldManager.pagetab_bg = "Texture/kidui/worldmanager/tab_unselected.png"
WorldManager.pagetab_selected_bg = "Texture/kidui/worldmanager/tab_selected.png"
WorldManager.panel_bg = "Texture/whitedot.png;0 0 0 0";
WorldManager.panel_sub_bg = "Texture/kidui/explorer/panel_sub_bg.png"
WorldManager.button_bg = "Texture/kidui/explorer/button.png"
WorldManager.listbox_bg = "Texture/kidui/explorer/listbox_bg.png"
WorldManager.dropdownarrow_bg = "Texture/kidui/explorer/dropdown_arrow.png"
WorldManager.dropdownlist_cont_bg = "Texture/kidui/explorer/editbox256x32.png"
WorldManager.editbox_bg = "Texture/kidui/explorer/editbox128x32.png"
WorldManager.editbox_long_bg = "Texture/kidui/explorer/editbox256x32.png"

-- tab pages
WorldManager.tabpages = {[1] = "tabPageLoadWorld", [2] = "tabPageNewWorld", [3] = "tabPageNewWorldCreated", };
WorldManager.tabbuttons = {[1] = "tabPageLoadWorld_TabBtn", [2] = "tabPageNewWorld_TabBtn", };

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function WorldManager.Show(bShow)
	local _this,_parent;
	local left, top, width, height;

	_this=ParaUI.GetUIObject("WorldManager");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		
		width, height = 480, 512
		-- WorldManager
		_this = ParaUI.CreateUIObject("container", "WorldManager", "_ct", -width/2, -height/2, width, height)
		_this.background=WorldManager.main_bg;
		_this:SetTopLevel(true);
		_this:AttachToRoot();
		_parent = _this;
		
		-- tabControl1
		NPL.load("(gl)script/ide/gui_helper.lua");
		_this = ParaUI.CreateUIObject("container", "tabControl1", "_fi", 24, 45, 24, 20);
		_this.background="Texture/whitedot.png;0 0 0 0";
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("button", "tabPageLoadWorld_TabBtn", "_lt", 0, 0, 150, 32)
		_this.text = L"Load World";
		_this.background=WorldManager.pagetab_bg;
		_this.onclick = [[;WorldManager.SwitchTabWindow(1);]];
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("button", "tabPageNewWorld_TabBtn", "_lt", 150, 0, 150, 32)
		_this.text = L"New World";
		_this.background=WorldManager.pagetab_bg;
		_this.onclick = [[;WorldManager.SwitchTabWindow(2);]];
		_parent:AddChild(_this);

		_parent = ParaUI.GetUIObject("tabControl1");
		-- tabPageLoadWorld
		_this = ParaUI.CreateUIObject("container", "tabPageLoadWorld", "_fi", 0, 32, 0, 0)
		_this.background=WorldManager.panel_bg;
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("text", "label1", "_lt", 3, 11, 440, 16)
		_this.text = L"Select world from the list below and click Load button";
		_this:GetFont("text").color = "65 105 225";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label7", "_lt", 8, 43, 88, 16)
		_this.text = L"World Path";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("editbox", "WM_LOAD_WorldPath", "_mt", 102, 40, 18, 26)
		_this.background=WorldManager.editbox_long_bg;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("listbox", "WM_LOAD_WorldList", "_fi", 6, 72, 18, 63)
		_this.wordbreak = false;
		_this.background = WorldManager.listbox_bg;
		_this.itemheight = 18;
		_this.onselect=";WorldManager.WM_LOAD_WorldList_Select();";
		_this.ondoubleclick=";WorldManager.On_WM_LOAD_OKBtn();";
		_this.font = "System;13;norm";
		_this.scrollbarwidth = 20;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "WM_LOAD_OKBtn", "_lb", 6, -41, 105, 26)
		_this.text = L"Load";
		_this.onclick=";WorldManager.On_WM_LOAD_OKBtn();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "WM_LOAD_CancelBtn", "_rb", -123, -41, 105, 26)
		_this.text = L"Cancel";
		_this.onclick=";WorldManager.OnDestory();"
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "WM_LOAD_DeleteWorldBtn", "_lb", 130, -41, 105, 26)
		_this.text = L"Delete";
		_this.onclick=";WorldManager.On_WM_DeleteWorldBtn();";
		_parent:AddChild(_this);

		-- tabPageNewWorld
		_this = ParaUI.CreateUIObject("container", "tabPageNewWorld", "_fi", 0, 32, 0, 0)
		_this.background=WorldManager.panel_bg;
		_parent = ParaUI.GetUIObject("tabControl1");
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("text", "label2", "_lt", 10, 13, 296, 16)
		_this.text = L"Enter world name and click OK button";
		_this:GetFont("text").color = "65 105 225";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "WM_NEW_OKBtn", "_lb", 13, -39, 105, 26)
		_this.text = L"OK";
		_this.onclick=";WorldManager.On_WM_NEW_OKBtn();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "WM_NEW_CancelBtn", "_lb", 139, -39, 105, 26)
		_this.text = L"Cancel";
		_this.onclick=";WorldManager.OnDestory();"
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label3", "_lt", 10, 40, 88, 16)
		_this.text = L"World Name";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label4", "_lt", 10, 72, 96, 16)
		_this.text = L"Author Name";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("imeeditbox", "WM_NEW_WorldName", "_lt", 113, 37, 167, 26)
		_this.background=WorldManager.editbox_bg;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("imeeditbox", "WM_NEW_AuthorName", "_lt", 113, 69, 167, 26)
		_this.background=WorldManager.editbox_bg;
		_parent:AddChild(_this);

		-- panel1
		_this = ParaUI.CreateUIObject("container", "WM_Panel", "_fi", 3, 102, 3, 45)
		_this.background=WorldManager.panel_sub_bg;
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("listbox", "WM_NEW_BaseWorldList", "_fi", 52, 138, 16, 10)
		_this.background = WorldManager.listbox_bg;
		_this.wordbreak = false;
		_this.itemheight = 18;
		_this.onselect=";WorldManager.NewWorld_OnParentWorldListSelect();";
		_this.font = "System;13;norm";
		_this.scrollbarwidth = 20;
		_parent:AddChild(_this);

		-- list all sub directories in the User directory.
		CommonCtrl.InitFileDialog(ParaIO.GetCurDirectory(0)..kids_db.worlddir,"*.", 0, 150, _this);
			
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
			text = L"Create a world based on an existing world",
			--oncheck = WorldManager.OnCheckNewWorldUseBaseWorld,
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
			text = L"Create an empty world",
			--oncheck = WorldManager.OnCheckNewWorldUseEmptyWorld,
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
			text = L"Use scene objects in the base world",
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
			text = L"Use characters in the base world",
		};
		ctl:Show();

		-- tabPageNewWorldCreated
		_this = ParaUI.CreateUIObject("container", "tabPageNewWorldCreated", "_fi", 0, 32, 0, 0)
		_this.background=WorldManager.panel_bg;
		_parent = ParaUI.GetUIObject("tabControl1");
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("text", "label5", "_lt", 6, 16, 144, 16)
		_this.text = L"Congratulations!";
		_this:GetFont("text").color = "220 20 60";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label6", "_lt", 34, 42, 368, 16)
		_this.text = L"You have successfully created a new world at:";
		_this:GetFont("text").color = "65 105 225";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "WM_NEWC_OKButton", "_lb", 9, -39, 125, 26)
		_this.background=WorldManager.button_bg;
		_this.text = L"Start World";
		_this.onclick = ";WorldManager.On_WM_NEWC_StartButton();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "WM_NEWC_StartButton", "_lb", 131, -303, 112, 26)
		_this.text = L"Start World";
		_this.background=WorldManager.button_bg;
		_this.onclick = ";WorldManager.On_WM_NEWC_StartButton();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "WM_NEWC_CancelBtn", "_rb", -118, -39, 105, 26)
		_this.text = L"Cancel";
		_this.onclick=";WorldManager.OnDestory();"
		_this.background=WorldManager.button_bg;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "WM_NEWC_worldpath", "_lt", 34, 71, 144, 16)
		_parent:AddChild(_this);

		-- switch to a tab page
		WorldManager.SwitchTabWindow(1);

	else
		if(bShow == nil) then
			bShow = (_this.visible == false);
		end
		_this.visible = bShow;
		if(bShow == true) then
			_this:SetTopLevel(true);
		end
	end	
	if(bShow) then
		KidsUI.PushState({name="WorldManager", OnEscKey = WorldManager.OnDestory});
		WorldManager.OnRefreshDirectories();
	else
		KidsUI.PopState("WorldManager");
	end
end

-- destory the control
function WorldManager.OnDestory()
	ParaUI.Destroy("WorldManager");
	KidsUI.PopState("WorldManager");
end

---------------------------------------------------------
-- private functions
---------------------------------------------------------
-- @param nIndex: 1 or 2 or 3
function WorldManager.SwitchTabWindow(nIndex)
	if(WorldManager.tabpages~=nil and WorldManager.tabbuttons~=nil) then
		_guihelper.SwitchVizGroupByIndex(WorldManager.tabpages, nIndex);
		_guihelper.CheckRadioButtonsByIndex(WorldManager.tabbuttons, nIndex, "255 255 255", WorldManager.pagetab_selected_bg, WorldManager.pagetab_bg);
		if(nIndex == 3) then
			-- new world created
			if(WorldManager.NewWorldPath~=nil) then
				ParaUI.GetUIObject("WM_NEWC_worldpath").text = WorldManager.NewWorldPath;
			end	
		end
	end	
end

---------------------------
-- for tab page: load world 
---------------------------

-- called to load the local world
function WorldManager.On_WM_LOAD_OKBtn()
	-- disable network, so that it is local.
	ParaNetwork.EnableNetwork(false, "","");
	KidsUI.bShowTipsIcon = nil;
	
	local tmp = ParaUI.GetUIObject("WM_LOAD_WorldPath");
	if(tmp:IsValid() == true) then 
		local sName = tmp.text;
		if(sName == "") then
			_guihelper.MessageBox(L"world name can not be empty");
		else
			local res = KidsUI.LoadWorldImmediate(sName);
			if(res==true) then
				-- Do something after the load	
				
				if(kids_db.world.readonly) then
					kids_db.User.SetRole("poweruser");
				else
					kids_db.User.SetRole("administrator");
				end
			elseif(type(res) == "string") then
				-- show the error message
				_guihelper.MessageBox(res);
			end
		end
	end
end

-- called when select a world from the load world list box.
function WorldManager.WM_LOAD_WorldList_Select()
	local tmp = ParaUI.GetUIObject("WM_LOAD_WorldList");
	if(tmp:IsValid() == true) then 
		local sName = tmp.text;
		tmp = ParaUI.GetUIObject("WM_LOAD_WorldPath");
		if(tmp:IsValid() == true) then 
			tmp.text = kids_db.worlddir..sName;
		end
	end
end

function WorldManager.On_WM_DeleteWorldBtn()
	local tmp = ParaUI.GetUIObject("WM_LOAD_WorldList");
	if(tmp:IsValid() == true and tmp.text~="") then 
		local sName = tmp.text;
		local dirPath = string.gsub(kids_db.worlddir..sName, "/", "\\");
		if(dirPath)then
			_guihelper.MessageBox(string.format(L"Are you sure you want to delete %s?\n Deleted files will be moved to %s.", dirPath, "temp\\"..dirPath), 
				string.format([[WorldManager.On_WM_DeleteWorld_imp(%q)]], dirPath));
		end
	end
end

-- @param worldpath: which world to delete
function WorldManager.On_WM_DeleteWorld_imp(worldpath)
	local targetDir = "temp\\"..worldpath;
	if(ParaIO.CreateDirectory(targetDir) and ParaIO.MoveFile(worldpath, targetDir)) then  
		WorldManager.OnRefreshDirectories();
	else
		_guihelper.MessageBox(L"Unable to delete. Perhaps you do not have enough access rights"); 
	end
end

--  refresh the directories.
function WorldManager.OnRefreshDirectories()
	local tmp = ParaUI.GetUIObject("WM_LOAD_WorldList");
	if(tmp:IsValid() == true) then 
		tmp:RemoveAll();
		-- list all sub directories in the User directory.
		CommonCtrl.InitFileDialog(ParaIO.GetCurDirectory(0)..kids_db.worlddir,{"*.","*.zip",}, 0, 150, tmp);
	end
end

---------------------------
-- for tab page: new world 
---------------------------

-- when the user new world button is clicked.
function WorldManager.On_WM_NEW_OKBtn()
	local worldpath, BaseWorldPath;
	
	local RadioBoxUseBaseWorld = CommonCtrl.GetControl("WM_NEW_Radio_UseBaseWorld");
	if(RadioBoxUseBaseWorld~=nil and RadioBoxUseBaseWorld:GetCheck()) then
		BaseWorldPath = WorldManager.BaseWorldPath;
		--local ComboBoxBaseWorld = CommonCtrl.GetControl("SOME_comboBox");
		--if(ComboBoxBaseWorld~=nil) then
			--BaseWorldPath = ComboBoxBaseWorld:GetText();
		--end	
	end
		
	local tmp = ParaUI.GetUIObject("WM_NEW_WorldName");
	if(tmp:IsValid() == true) then 
		local sName = tmp.text;
		if(sName == "") then
			_guihelper.MessageBox(L"world name can not be empty".."\n");
		elseif(sName == "_emptyworld") then
			_guihelper.MessageBox(L"_emptyworld presents an empty world. Please use another name.".."\n");
		else
			worldpath = kids_db.worlddir..sName;-- append the world dir name
			
			local CheckBoxUseBaseWorldNPC = CommonCtrl.GetControl("WM_NEW_Check_UseBaseWorldNPC");
			local bInheriteNPC = (CheckBoxUseBaseWorldNPC~=nil and CheckBoxUseBaseWorldNPC:GetCheck());
			
			-- create a new world
			local res = KidsUI.CreateWorldImmediate(worldpath, BaseWorldPath, bInheriteNPC);
			if(res == true) then
				-- load success UI
				WorldManager.NewWorldPath = worldpath;
				WorldManager.NewWorldCreatedUI();
			elseif(type(res) == "string") then
				_guihelper.MessageBox(res);
			end
		end
	end
end

function WorldManager.NewWorld_OnParentWorldListSelect()
	local tmp = ParaUI.GetUIObject("WM_NEW_BaseWorldList");
	if(tmp:IsValid() == true) then 
		local sName = tmp.text;
		WorldManager.BaseWorldPath = kids_db.worlddir..sName;
	end
end
---------------------------
-- for tab page: new world created
---------------------------
-- show another UI, whenever a new world has been successfully created.
function WorldManager.NewWorldCreatedUI()
	WorldManager.SwitchTabWindow(3);
end

function WorldManager.On_WM_NEWC_StartButton()
	if(kids_db.world.sConfigFile ~= "") then
		local res = KidsUI.LoadWorldImmediate(kids_db.world.name);
		if(res==true) then
			-- TODO: show something when the world is created for the first time.
			kids_db.User.SetRole("administrator");
		elseif(type(res) == "string") then
			-- show the error message
			_guihelper.MessageBox(res);
		end
	end
end