--[[
Title: template: windows form or modeless dialog
Author(s): [your name], original template by LiXizhi
Date: 2007/2/7
Parameters:
	EBook_MediaMenu: it needs to be a valid name, such as MyDialog
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/EBook/EBook_MediaMenu.lua");
EBook_MediaMenu.Show();
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/kids/3DMapSystemUI/EBook/EBook.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/EBook/EBook_db.lua");
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/ide/FileDialog.lua");

local L = CommonCtrl.Locale("ParaWorld");

if(not EBook_MediaMenu) then EBook_MediaMenu={}; end
-- properties
EBook_MediaMenu.NeedsRefresh = true;

-- appearance
EBook_MediaMenu.main_bg = "Texture/kidui/explorer/bg.png"
EBook_MediaMenu.pagetab_bg = "Texture/kidui/explorer/pagetab.png"
EBook_MediaMenu.pagetab_selected_bg = "Texture/kidui/explorer/pagetab_selected.png"
EBook_MediaMenu.panel_bg = "Texture/kidui/explorer/panel_bg.png"
EBook_MediaMenu.panel_sub_bg = "Texture/kidui/explorer/panel_sub_bg.png"
EBook_MediaMenu.button_bg = "Texture/kidui/explorer/button.png"
EBook_MediaMenu.listbox_bg = "Texture/kidui/explorer/listbox_bg.png"
EBook_MediaMenu.dropdownarrow_bg = "Texture/kidui/explorer/dropdown_arrow.png"
EBook_MediaMenu.dropdownlist_cont_bg = "Texture/kidui/explorer/editbox256x32.png"
EBook_MediaMenu.editbox_bg = "Texture/kidui/explorer/editbox128x32.png"
EBook_MediaMenu.editbox_long_bg = "Texture/kidui/explorer/editbox256x32.png"

-- tab pages
EBook_MediaMenu.tabpages = {"EB_MMenuPage_3DWorld", "EB_MMenuPage_Files", "EB_MMenuPage_Network", "EB_MMenuPage_Audio", };
EBook_MediaMenu.tabbuttons = {"EB_MMenuPage_3DWorld_TabBtn", "EB_MMenuPage_Files_TabBtn", "EB_MMenuPage_Network_TabBtn", "EB_MMenuPage_Audio_TabBtn", };

EBook_MediaMenu.worldtabpages = {"EB_MMenu_LoadWorld", "EB_MMenu_NewWorld", "EB_MMenu_NewWorldCreated", };
EBook_MediaMenu.worldtabbuttons = {"EB_MMenu_LoadWorld_TabBtn", "EB_MMenu_NewWorld_TabBtn", };

EBook_MediaMenu.filestabbuttons = {"EB_MMenu_Files_ScreenshotTabBtn", "EB_MMenu_Files_MovieTabBtn", "EB_MMenu_Files_OthersTabBtn", };

-- @param nIndex
function EBook_MediaMenu.SwitchFilesTabs(nIndex)
	_guihelper.CheckRadioButtonsByIndex(EBook_MediaMenu.filestabbuttons, nIndex);
	if(nIndex == 1) then
		-- screen shots
		local _this = ParaUI.GetUIObject("EB_MMenu_Files_FileList");
		if(_this:IsValid()) then
			-- refill all items
			_this:RemoveAll();
			-- list all sub directories in the book's worlds directory.
			CommonCtrl.InitFileDialog(ParaIO.GetCurDirectory(0)..EBook_db.book.media_path, {"*.jpg", "*.png"}, 0, 150, _this);
		end
	elseif(nIndex == 2) then
		-- flash movie files
		local _this = ParaUI.GetUIObject("EB_MMenu_Files_FileList");
		if(_this:IsValid()) then
			-- refill all items
			_this:RemoveAll();
			-- list all sub directories in the book's worlds directory.
			CommonCtrl.InitFileDialog(ParaIO.GetCurDirectory(0)..EBook_db.book.media_path, {"*.swf", "*.flv",}, 0, 150, _this);
		end
	elseif(nIndex == 3) then
		-- all other files (flash included)
		local _this = ParaUI.GetUIObject("EB_MMenu_Files_FileList");
		if(_this:IsValid()) then
			-- refill all items
			_this:RemoveAll();
			-- list all sub directories in the book's worlds directory.
			CommonCtrl.InitFileDialog(ParaIO.GetCurDirectory(0)..EBook_db.book.media_path,"*.*", 0, 150, _this);
		end
	end
end

-- @param nIndex: 1-4
function EBook_MediaMenu.SwitchMainTabs(nIndex)
	_guihelper.SwitchVizGroupByIndex(EBook_MediaMenu.tabpages, nIndex);
	_guihelper.CheckRadioButtonsByIndex(EBook_MediaMenu.tabbuttons, nIndex);
	if(nIndex == 1) then
		local page = EBook_db.GetCurrentPage();
		if(not page) then return end
		-- World manager
		if(EBook_MediaMenu.NeedsRefresh) then
			
			if(page.worldpath~=nil) then
				ParaUI.GetUIObject("EB_MMenu_WorldPath").text = page.worldpath;
			end	
			
			-- refresh EB_MMenu_LoadWorld_WorldList
			local _this = ParaUI.GetUIObject("EB_MMenu_LoadWorld_WorldList");
			if(_this:IsValid()) then
				-- refill all items
				_this:RemoveAll();
				-- list all sub directories in the book's worlds directory.
				CommonCtrl.InitFileDialog(ParaIO.GetCurDirectory(0)..EBook_db.book.worlds_path,"*.", 0, 150, _this);
			end	
			
			-- give a suggestive new world name based on the page title 
			if(page.pagetitle~=nil) then
				local newWorldName = string.gsub(page.pagetitle, "([%s%.%$%*%?%+%-%$%%%^\r\n!#&])", "_");
				if(not newWorldName) then newWorldName = "world"..page.pageid end
				ParaUI.GetUIObject("EB_MMenu_NEW_WorldName").text = newWorldName;
			end	
			
			-- refresh EB_MMenu_NewWorld_BaseWorld_comboBox
			local ComboxBaseworld = CommonCtrl.GetControl("EB_MMenu_NewWorld_BaseWorld_comboBox");
			if(ComboxBaseworld~=nil)then
				ComboxBaseworld.items = {};
				commonlib.SearchFiles(ComboxBaseworld.items, ParaIO.GetCurDirectory(0)..EBook_db.book.worlds_path, "*.", 0, 50, true);	
				ComboxBaseworld:RefreshListBox();
			end
		end
		local CheckBoxAutoSave = CommonCtrl.GetControl("EB_MMenu_AutoSavePlayerPos_CheckBox");
		if(CheckBoxAutoSave~=nil) then
			CheckBoxAutoSave:SetCheck(page.autosave_world);
		end
	elseif(nIndex == 2) then
		-- File manager
		EBook_MediaMenu.SwitchFilesTabs(1); -- switch to the file tab by default
	elseif(nIndex == 3) then
		-- Network
	elseif(nIndex == 4) then
		-- Audio
		local page = EBook_db.GetCurrentPage();
		if(not page) then return end
		
		-- refresh check boxes
		local CheckBoxFromFile = CommonCtrl.GetControl("EB_MMenu_Audio_FromFile_checkBox");
		if(CheckBoxFromFile~=nil)then
			CheckBoxFromFile:SetCheck(page.music_file~=nil and page.music_file~="");
		end	
		local CheckBoxUseVoice = CommonCtrl.GetControl("EB_MMenu_Audio_MyVoice_checkBox");
		if(CheckBoxUseVoice~=nil)then
			CheckBoxUseVoice:SetCheck(page.voice_file~=nil and page.voice_file~="");
		end	
		
		-- refresh EB_MMenu_Audio_WaveFile_comboBox
		local ComboMusics = CommonCtrl.GetControl("EB_MMenu_Audio_WaveFile_comboBox");
		if(ComboMusics~=nil)then
			if(page.music_file == nil) then
				ComboMusics:SetText("");
			else
				ComboMusics:SetText(page.music_file);
			end	
			ComboMusics.items = {};
			commonlib.SearchFiles(ComboMusics.items, ParaIO.GetCurDirectory(0)..EBook_db.book.media_path, "*.wav", 0, 50, true);	
			ComboMusics:RefreshListBox();
		end
	end
end

-- @param nIndex: 1-3
function EBook_MediaMenu.SwitchWorldTabs(nIndex)
	_guihelper.SwitchVizGroupByIndex(EBook_MediaMenu.worldtabpages, nIndex);
	_guihelper.CheckRadioButtonsByIndex(EBook_MediaMenu.worldtabbuttons, nIndex);
	if(nIndex == 1) then
		-- load world
	elseif(nIndex == 2) then
		-- new world
	elseif(nIndex == 3) then
		-- new world created
		if(EBook_MediaMenu.NewWorldPath~=nil) then
			ParaUI.GetUIObject("EB_MMenu_NEWC_worldpath").text = EBook_MediaMenu.NewWorldPath;
		end	
	end
end

-- show a top level recorder window
function EBook_MediaMenu.ShowRecorder(bShow, left, top)
	local _this,_parent;
	_this=ParaUI.GetUIObject("EBook_MediaMenu_Recorder_Cont");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		
		if(not left) then left = 366 end
		if(not top) then top = 266 end
		local width, height = 300, 150;
		
		-- EBook_MediaMenu_Recorder_Cont recorder
		_this = ParaUI.CreateUIObject("container", "EBook_MediaMenu_Recorder_Cont", "_lt", left, top, width, height)
		_this.background=EBook_MediaMenu.panel_sub_bg;
		_this:SetTopLevel(true);
		_this:AttachToRoot();
		_parent = _this;

		_this = ParaUI.CreateUIObject("text", "s", "_lt", 8, 10, width-16, 20)
		_this.text = L"Your voice is now being recorded. Please speak in front of your microphone";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "EB_MMenu_Recorder_Stop_btn", "_lb", 100, -50, 80, 42)
		_this.text = L"Stop";
		_this.onclick=[[;ParaUI.Destroy("EBook_MediaMenu_Recorder_Cont");EBook_MediaMenu.OnClickAudio_stop();]];
		_parent:AddChild(_this);
	else
		if(bShow~=true) then
			ParaUI.Destroy("EBook_MediaMenu_Recorder_Cont");
		end
	end
end
--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function EBook_MediaMenu.Show(bShow, left, top)
	local _this,_parent;
	
	if(EBook_db.book == nil or EBook_db.book.book_path == nil) then return end
	
	_this=ParaUI.GetUIObject("EBook_MediaMenu");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		EBook_MediaMenu.NeedsRefresh = true;
		
		if(not left) then left = 366 end
		if(not top) then top = 266 end
		local width, height = 556, 300
		
		-- EBook_MediaMenu
		_this = ParaUI.CreateUIObject("container", "EBook_MediaMenu", "_lt", left, top, width, height)
		_this.background="Texture/EBook/menu_bg.png";
		_this.onmouseup=";EBook_MediaMenu.OnClose();";
		_this:SetTopLevel(true);
		_this:AttachToRoot();
		_parent = _this;

		-- EB_MediaMenu_RightCont
		NPL.load("(gl)script/ide/gui_helper.lua");
		_this = ParaUI.CreateUIObject("container", "EB_MediaMenu_RightCont", "_fi", 155, 17, 12, 17)
		_this.background = "Texture/whitedot.png;0 0 0 0";
		_parent:AddChild(_this);
		_parent = _this;

		_parent = ParaUI.GetUIObject("EB_MediaMenu_RightCont");
		-- EB_MMenuPage_3DWorld
		_this = ParaUI.CreateUIObject("container", "EB_MMenuPage_3DWorld", "_fi", 4, 4, 4, 4)
		_this.background = "Texture/whitedot.png;0 0 0 0";
		_parent:AddChild(_this);
		_parent = _this;

		-- EB_MMenu_3DWorld_tabcont
		NPL.load("(gl)script/ide/gui_helper.lua");
		_this = ParaUI.CreateUIObject("container", "EB_MMenu_3DWorld_tabcont", "_fi", 3, 3, 0,0)
		_this.background = "Texture/whitedot.png;0 0 0 0";
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("button", "EB_MMenu_LoadWorld_TabBtn", "_lt", 0, 0, 100, 32)
		_this.text = L"Load World";
		_this.onclick = ";EBook_MediaMenu.SwitchWorldTabs(1);";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("button", "EB_MMenu_NewWorld_TabBtn", "_lt", 100, 0, 100, 32)
		_this.text = L"New World";
		_this.onclick = ";EBook_MediaMenu.SwitchWorldTabs(2);";
		_parent:AddChild(_this);
		
		_parent = ParaUI.GetUIObject("EB_MMenu_3DWorld_tabcont");
		-- EB_MMenu_LoadWorld
		_this = ParaUI.CreateUIObject("container", "EB_MMenu_LoadWorld", "_fi", 4, 36, 4, 4)
		_this.background = "Texture/whitedot.png;0 0 0 0";
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("listbox", "EB_MMenu_LoadWorld_WorldList", "_fi", 6, 39, 18, 73)
		_this.background = EBook_MediaMenu.listbox_bg;
		_this.scrollable = true;
		_this.wordbreak = false;
		_this.itemheight = 18;
		_this.onselect=";EBook_MediaMenu.OnSelectLoadWorld_WorldList();";
		_this.ondoubleclick=";EBook_MediaMenu.On_LOAD_OKBtn();";
		_this.font = "System;13;norm";
		_this.scrollbarwidth = 20;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "EB_MMenu_LOAD_OKBtn", "_lb", 6, -29, 105, 26)
		_this.text = L"Load";
		_this.onclick=";EBook_MediaMenu.On_LOAD_OKBtn();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "EB_MMenu_LOAD_DeleteWorldBtn", "_lb", 130, -29, 105, 26)
		_this.text = L"Delete";
		_this.onclick=";EBook_MediaMenu.On_LOAD_DeleteWorldBtn();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("imeeditbox", "EB_MMenu_WorldPath", "_mt", 102, 7, 84, 26)
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label7", "_lt", 8, 10, 88, 16)
		_this.text = L"World Path";
		_parent:AddChild(_this);

		NPL.load("(gl)script/ide/CheckBox.lua");
		local ctl = CommonCtrl.checkbox:new{
			name = "EB_MMenu_AutoSavePlayerPos_CheckBox",
			alignment = "_lt",
			left = 11,
			top = 157,
			width = 227,
			height = 20,
			parent = _parent,
			isChecked = true,
			text = L"Auto save player position",
			oncheck = EBook_MediaMenu.OnCheckAutoSaveWorld,
		};
		ctl:Show();

		_this = ParaUI.CreateUIObject("button", "EB_MMenu_LoadWorld_ClearBtn", "_rt", -76, 7, 58, 26)
		_this.text = L"Clear";
		_this.onclick = ";EBook_MediaMenu.OnClickLoadWorld_ClearBtn();"
		_parent:AddChild(_this);

		-- EB_MMenu_NewWorld
		_this = ParaUI.CreateUIObject("container", "EB_MMenu_NewWorld", "_fi", 4, 36, 4, 4)
		_this.background = "Texture/whitedot.png;0 0 0 0";
		_parent = ParaUI.GetUIObject("EB_MMenu_3DWorld_tabcont");
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("button", "EB_MMenu_NEW_OKBtn", "_lb", 3, -32, 81, 26)
		_this.text = L"OK";
		_this.onclick=";EBook_MediaMenu.OnClickNEW_OKBtn();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label3", "_lt", 3, 4, 88, 16)
		_this.text = L"World Name";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("imeeditbox", "EB_MMenu_NEW_WorldName", "_mt", 107, 1, 16, 26)
		_this.background = EBook_MediaMenu.editbox_long_bg;
		_parent:AddChild(_this);

		-- panel2
		_this = ParaUI.CreateUIObject("container", "panel2", "_fi", 3, 30, 2, 50)
		_this.background=EBook.panel_sub_bg;
		_parent:AddChild(_this);
		_parent = _this;

		NPL.load("(gl)script/ide/RadioBox.lua");
		local ctl = CommonCtrl.radiobox:new{
			name = "EB_MMenu_NEW_Radio_UseBaseWorld",
			alignment = "_lt",
			left = 3,
			top = 29,
			width = 354,
			height = 20,
			parent = _parent,
			isChecked = false,
			text = L"Create a world based on an existing world",
			oncheck = EBook_MediaMenu.OnCheckNewWorldUseBaseWorld,
		};
		ctl:Show();

		NPL.load("(gl)script/ide/RadioBox.lua");
		local ctl = CommonCtrl.radiobox:new{
			name = "EB_MMenu_NEW_Radio_CreateEmptyWorld",
			alignment = "_lt",
			left = 3,
			top = 3,
			width = 194,
			height = 20,
			parent = _parent,
			isChecked = true,
			text = L"Create an empty world",
			oncheck = EBook_MediaMenu.OnCheckNewWorldUseEmptyWorld,
		};
		ctl:Show();

		NPL.load("(gl)script/ide/CheckBox.lua");
		local ctl = CommonCtrl.checkbox:new{
			name = "EB_MMenu_NEW_Check_UseSceneObject",
			alignment = "_lt",
			left = 52,
			top = 85,
			width = 307,
			height = 20,
			parent = _parent,
			isChecked = true,
			text = L"Use scene objects in the base world",
		};
		ctl:Show();

		NPL.load("(gl)script/ide/CheckBox.lua");
		local ctl = CommonCtrl.checkbox:new{
			name = "EB_MMenu_NEW_Check_UseBaseWorldNPC",
			alignment = "_lt",
			left = 52,
			top = 111,
			width = 283,
			height = 20,
			parent = _parent,
			isChecked = false,
			text = L"Use characters in the base world",
		};
		ctl:Show();

		NPL.load("(gl)script/ide/dropdownlistbox.lua");
		NPL.load("(gl)script/ide/commonlib.lua");
		local ctl = CommonCtrl.dropdownlistbox:new{
			name = "EB_MMenu_NewWorld_BaseWorld_comboBox",
			alignment = "_mt",
			left = 52,
			top = 55,
			width = 25,
			height = 24,
			dropdownheight = 106,
 			parent = _parent,
 			container_bg = EBook_MediaMenu.dropdownlist_cont_bg,
			editbox_bg = "Texture/whitedot.png;0 0 0 0",
			dropdownbutton_bg = EBook_MediaMenu.dropdownarrow_bg,
			listbox_bg = EBook_MediaMenu.listbox_bg,
			text = "",
			items = {},
			FuncTextFormat = EBook_MediaMenu.AppendBookWorldPath,
		};
		ctl:Show();
		-- default to use empty world
		EBook_MediaMenu.OnCheckNewWorldUseEmptyWorld(true);
		
		-- EB_MMenu_NewWorldCreated
		_this = ParaUI.CreateUIObject("container", "EB_MMenu_NewWorldCreated", "_fi", 4, 36, 4, 4)
		_this.background = "Texture/whitedot.png;0 0 0 0";
		_parent = ParaUI.GetUIObject("EB_MMenu_3DWorld_tabcont");
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("text", "label10", "_lt", 6, 16, 144, 16)
		_this.text = L"Congratulations!";
		_this:GetFont("text").color = "220 20 60";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label9", "_lt", 21, 39, 368, 16)
		_this.text = "You have successfully created a new world at:";
		_this:GetFont("text").color = "65 105 225";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "EB_MMenu_NEWC_OKButton", "_lb", 9, -39, 125, 26)
		_this.text = L"Start World";
		_this.onclick = ";EBook_MediaMenu.OnClickNewWorldCreatedOKBtn();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "EB_MMenu_NEWC_worldpath", "_lt", 21, 64, 250, 16)
		_this.text = "worlds/mynewworld";
		_parent:AddChild(_this);

		-- switch to a tab page
		EBook_MediaMenu.SwitchWorldTabs(1);
		
		-- EB_MMenuPage_Files
		_this = ParaUI.CreateUIObject("container", "EB_MMenuPage_Files", "_fi", 4, 4, 4, 4)
		_this.background = "Texture/whitedot.png;0 0 0 0";
		_parent = ParaUI.GetUIObject("EB_MediaMenu_RightCont");
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("listbox", "EB_MMenu_Files_FileList", "_fi", 0, 65, 11, 74)
		_this.background = EBook_MediaMenu.listbox_bg;
		_this.scrollable = true;
		_this.wordbreak = false;
		_this.itemheight = 18;
		_this.onselect = ";EBook_MediaMenu.OnSelectFiles_FileList();";
		--_this.ondoubleclick = ";";
		_this.font = "System;13;norm";
		_this.scrollbarwidth = 20;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "EB_MMenu_Files_ScreenshotTabBtn", "_lt", 0, 42, 92, 23)
		_this.text = L"Screen Shot";
		_this.onclick = ";EBook_MediaMenu.SwitchFilesTabs(1);";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "EB_MMenu_Files_MovieTabBtn", "_lt", 98, 42, 92, 23)
		_this.text = L"Movies";
		_this.onclick = ";EBook_MediaMenu.SwitchFilesTabs(2);";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "EB_MMenu_Files_OthersTabBtn", "_lt", 196, 42, 92, 23)
		_this.text = L"All";
		_this.onclick = ";EBook_MediaMenu.SwitchFilesTabs(3);";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "EB_MMenu_Files_ClearBtn", "_rt", -69, 10, 58, 26)
		_this.text = L"Clear";
		_this.onclick = ";EBook_MediaMenu.OnClickFiles_ClearBtn();";
		
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("editbox", "EB_MMenu_Files_MediaFilePath", "_mt", 100, 10, 76, 26)
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label1", "_lt", 6, 13, 88, 16)
		_this.text = L"Media Path";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "EB_MMenu_Files_OKbtn", "_lb", 3, -29, 105, 26)
		_this.text = L"OK";
		_this.onclick = ";EBook_MediaMenu.OnClickFiles_OKbtn();";
		_parent:AddChild(_this);

		NPL.load("(gl)script/ide/CheckBox.lua");
		local ctl = CommonCtrl.checkbox:new{
			name = "EB_MMenu_Files_AspectRatio_CheckBox",
			alignment = "_lt",
			left = 3,
			top = 195,
			width = 195,
			height = 20,
			parent = _parent,
			isChecked = true,
			text = L"Maintain Aspect Ratio",
		};
		ctl:Show();

		-- EB_MMenuPage_Network
		_this = ParaUI.CreateUIObject("container", "EB_MMenuPage_Network", "_fi", 4, 4, 4, 4)
		_this.background = "Texture/whitedot.png;0 0 0 0";
		_parent = ParaUI.GetUIObject("EB_MediaMenu_RightCont");
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("text", "label4", "_lt", 12, 9, 352, 16)
		_this.text = L"- Embed some body else's world in your book";
		_this:GetFont("text").color = "65 105 225";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label5", "_lt", 12, 31, 344, 16)
		_this.text = L"- Corperatively build 3D world with others";
		_this:GetFont("text").color = "65 105 225";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label6", "_lt", 12, 56, 360, 16)
		_this.text = L"- Invite friends to help building your world";
		_this:GetFont("text").color = "65 105 225";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label8", "_lt", 50, 114, 240, 16)
		_this.text = L"Function is now in alpha test";
		_this:GetFont("text").color = "199 21 133";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "EB_MMenu_Network_ParticipateBtn", "_lt", 215, 153, 162, 23)
		_this.text = L"I want to participate!";
		_parent:AddChild(_this);

		-- EB_MMenuPage_Audio
		_this = ParaUI.CreateUIObject("container", "EB_MMenuPage_Audio", "_fi", 4, 4, 4, 4)
		_this.background = "Texture/whitedot.png;0 0 0 0";
		_parent = ParaUI.GetUIObject("EB_MediaMenu_RightCont");
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("button", "EB_MMenu_Audio_record", "_lt", 49, 49, 63, 26)
		_this.text = L"Record";
		_this.onclick = ";EBook_MediaMenu.OnClickAudio_record();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "EB_MMenu_Audio_play", "_rt", -103, 49, 67, 26)
		_this.text = L"Play";
		_this.onclick = ";EBook_MediaMenu.OnClickAudio_play();";
		_parent:AddChild(_this);

		--_this = ParaUI.CreateUIObject("button", "EB_MMenu_Audio_stop", "_lt", 118, 49, 59, 26)
		--_this.text = "End";
		--_this.onclick = ";EBook_MediaMenu.OnClickAudio_stop();";
		--_parent:AddChild(_this);

		NPL.load("(gl)script/ide/CheckBox.lua");
		local ctl = CommonCtrl.checkbox:new{
			name = "EB_MMenu_Audio_MyVoice_checkBox",
			alignment = "_lt",
			left = 25,
			top = 14,
			width = 323,
			height = 20,
			parent = _parent,
			isChecked = true,
			text = L"Play my own voice (need a microphone)",
		};
		ctl:Show();

		NPL.load("(gl)script/ide/CheckBox.lua");
		local ctl = CommonCtrl.checkbox:new{
			name = "EB_MMenu_Audio_FromFile_checkBox",
			alignment = "_lt",
			left = 25,
			top = 87,
			width = 203,
			height = 20,
			parent = _parent,
			isChecked = false,
			text = L"Play sound from a file",
		};
		ctl:Show();

		_this = ParaUI.CreateUIObject("editbox", "EB_MMenu_Audio_VoiceLength_EditBox", "_lt", 185, 49, 43, 26)
		_this.text = "0";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label11", "_lt", 234, 52, 32, 16)
		_this.text = L"sec";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "EB_MMenu_Audio_OKbtn", "_lb", 21, -32, 105, 26)
		_this.text = L"OK";
		_this.onclick = ";EBook_MediaMenu.OnClickAudio_OKbtn();";
		_parent:AddChild(_this);

		NPL.load("(gl)script/ide/dropdownlistbox.lua");
		local ctl = CommonCtrl.dropdownlistbox:new{
			name = "EB_MMenu_Audio_WaveFile_comboBox",
			alignment = "_mt",
			left = 49,
			top = 113,
			width = 36,
			height = 24,
			dropdownheight = 106,
 			parent = _parent,
			text = "",
			items = {},
			container_bg = EBook_MediaMenu.dropdownlist_cont_bg,
			editbox_bg = "Texture/whitedot.png;0 0 0 0",
			dropdownbutton_bg = EBook_MediaMenu.dropdownarrow_bg,
			listbox_bg = EBook_MediaMenu.listbox_bg,
			FuncTextFormat = EBook_MediaMenu.AppendBookMediaPath,
		};
		ctl:Show();

		NPL.load("(gl)script/ide/CheckBox.lua");
		local ctl = CommonCtrl.checkbox:new{
			name = "EB_MMenu_Audio_WaveFile_Loop_checkbox",
			alignment = "_lt",
			left = 49,
			top = 146,
			width = 107,
			height = 20,
			parent = _parent,
			isChecked = true,
			text = L"Loop music",
		};
		ctl:Show();
		
		-- EB_MediaMenu_LeftCont
		_this = ParaUI.CreateUIObject("container", "EB_MediaMenu_LeftCont", "_lt", 15, 27, 128, 256)
		_parent = ParaUI.GetUIObject("EBook_MediaMenu");
		_this.background = "Texture/whitedot.png;0 0 0 0";
		_parent:AddChild(_this);
		_parent = _this;

		height = 32;
		top = 0;
		local spacing = 5;
		_this = ParaUI.CreateUIObject("button", "EB_MMenuPage_3DWorld_TabBtn", "_mt", 0, top, 0, height)
		_guihelper.SetVistaStyleButton(_this, L"Texture/EBook/menu_3dworlds.png", "Texture/EBook/button_bg_layer.png");
		_this.onclick = ";EBook_MediaMenu.SwitchMainTabs(1);";
		--_this.onmouseenter = ";EBook_MediaMenu.SwitchMainTabs(1);";
		_parent:AddChild(_this);
		top = top + height+spacing;

		_this = ParaUI.CreateUIObject("button", "EBook_MMenu_Drawing_btn", "_mt", 0, top, 0, height)
		_guihelper.SetVistaStyleButton(_this, L"Texture/EBook/menu_drawing.png", "Texture/EBook/button_bg_layer.png");
		--_this.onmouseenter = ";EBook_MediaMenu.SwitchMainTabs(0);";
		_this.onclick = ";EBook_MediaMenu.OnClickDrawing();";
		_parent:AddChild(_this);
		top = top + height+spacing;

		_this = ParaUI.CreateUIObject("button", "EB_MMenuPage_Files_TabBtn", "_mt", 0, top, 0, height)
		_guihelper.SetVistaStyleButton(_this, L"Texture/EBook/menu_files.png", "Texture/EBook/button_bg_layer.png");
		_this.onclick = ";EBook_MediaMenu.SwitchMainTabs(2);";
		--_this.onmouseenter = ";EBook_MediaMenu.SwitchMainTabs(2);";
		_parent:AddChild(_this);
		top = top + height+spacing;

		_this = ParaUI.CreateUIObject("button", "EB_MMenuPage_Network_TabBtn", "_mt", 0, top, 0, height)
		_guihelper.SetVistaStyleButton(_this, L"Texture/EBook/menu_networking.png", "Texture/EBook/button_bg_layer.png");
		_this.onclick = ";EBook_MediaMenu.SwitchMainTabs(3);";
		--_this.onmouseenter = ";EBook_MediaMenu.SwitchMainTabs(3);";
		_parent:AddChild(_this);
		top = top + height+spacing;

		_this = ParaUI.CreateUIObject("button", "EB_MMenuPage_Audio_TabBtn", "_mt", 0, top, 0, height)
		_guihelper.SetVistaStyleButton(_this, L"Texture/EBook/menu_audio.png", "Texture/EBook/button_bg_layer.png");
		_this.onclick = ";EBook_MediaMenu.SwitchMainTabs(4);";
		--_this.onmouseenter = ";EBook_MediaMenu.SwitchMainTabs(4);";
		_parent:AddChild(_this);
		top = top + height+spacing;

		_this = ParaUI.CreateUIObject("button", "EBook_MMenu_Back_btn", "_mb", 0, 0, 0, height)
		_guihelper.SetVistaStyleButton(_this, L"Texture/EBook/menu_back.png", "Texture/EBook/button_bg_layer.png");
		_this.onclick=";EBook_MediaMenu.OnClose();";
		--_this.onmouseenter = ";EBook_MediaMenu.SwitchMainTabs(0);";
		_parent:AddChild(_this);

		-- switch to a tab page
		EBook_MediaMenu.SwitchMainTabs(0);
	else
		if(bShow == nil) then
			if(_this.visible == true) then
				_this.visible = false;
			else
				_this.visible = true;
			end
		else
			_this.visible = bShow;
		end
		if(_this.visible == true) then
			EBook_MediaMenu.NeedsRefresh = true;
			EBook_MediaMenu.SwitchMainTabs(0);
			_this:SetTopLevel(true);
		end
	end	
end

-- destory the control
function EBook_MediaMenu.OnDestory()
	ParaUI.Destroy("EBook_MediaMenu");
end

-- just hide the window
function EBook_MediaMenu.OnClose()
	EBook_MediaMenu.Show(false);
end

------------------------------------
-- world page 
------------------------------------

function EBook_MediaMenu.OnSelectLoadWorld_WorldList()
	local tmp = ParaUI.GetUIObject("EB_MMenu_LoadWorld_WorldList");
	if(tmp:IsValid() == true) then 
		local sName = tmp.text;
		tmp = ParaUI.GetUIObject("EB_MMenu_WorldPath");
		if(tmp:IsValid() == true) then 
			tmp.text = EBook_db.book.worlds_path..sName;
		end
	end
end

function EBook_MediaMenu.On_LOAD_OKBtn()
	local worldpath = ParaUI.GetUIObject("EB_MMenu_WorldPath").text;
	if(worldpath == nil or  worldpath == "") then
		local page = EBook_db.GetCurrentPage();
		if(not page) then return end
		if(page.worldpath~=nil) then
			_guihelper.MessageBox(string.format(L"Are you sure you want to remove the associated world %s from this page?", page.worldpath), function ()
				page.worldpath = nil;
				EBook.UpdatePageMedia();
				EBook_MediaMenu.OnClose();
			end);
		else
			_guihelper.MessageBox(L"Please select a world from the list first");
		end	
		return
	end
	
	-- disable network, so that it is local.
	ParaNetwork.EnableNetwork(false, "","");
	Map3DSystem.bShowTipsIcon = nil;
	
	local res = Map3DSystem.LoadWorld(worldpath);
	if(res==true) then
		-- Do something after the load	
		EBook.ResetBookWorld(true);
		if(Map3DSystem.World.readonly) then
			Map3DSystem.User.SetRole("poweruser");
		else
			Map3DSystem.User.SetRole("administrator");
		end
	elseif(type(res) == "string") then
		-- show the error message
		_guihelper.MessageBox(res);
	end
end

function EBook_MediaMenu.On_LOAD_DeleteWorldBtn()
	local tmp = ParaUI.GetUIObject("EB_MMenu_LoadWorld_WorldList");
	if(tmp:IsValid() == true and tmp.text~="") then 
		local sName = tmp.text;
		local dirPath = string.gsub(EBook_db.book.worlds_path..sName, "/", "\\");
		if(dirPath)then
			_guihelper.MessageBox(string.format(L"Are you sure you want to delete %s?\n Deleted files will be moved to %s.", dirPath, "temp\\"..dirPath), 
				string.format([[EBook_MediaMenu.On_LOAD_DeleteWorldBtn_imp(%q)]], dirPath));
		end
	end
end

function EBook_MediaMenu.On_LOAD_DeleteWorldBtn_imp(worldpath)
	local targetDir = "temp\\"..worldpath;
	if(ParaIO.CreateDirectory(targetDir) and ParaIO.MoveFile(worldpath, targetDir)) then  
		-- refresh folder
		EBook_MediaMenu.NeedsRefresh = true;
		EBook_MediaMenu.SwitchMainTabs(1);
	else
		_guihelper.MessageBox(L"Unable to delete. Perhaps you do not have enough access rights"); 
	end
end

function EBook_MediaMenu.OnClickLoadWorld_ClearBtn()
	ParaUI.GetUIObject("EB_MMenu_WorldPath").text = "";
end

function EBook_MediaMenu.AppendBookWorldPath(text)
	return EBook_db.book.worlds_path..text;
end

function EBook_MediaMenu.AppendBookMediaPath(text)
	return EBook_db.book.media_path..text;
end

function EBook_MediaMenu.OnClickNEW_OKBtn()
	local worldpath, BaseWorldPath;
	
	local RadioBoxUseBaseWorld = CommonCtrl.GetControl("EB_MMenu_NEW_Radio_UseBaseWorld");
	if(RadioBoxUseBaseWorld~=nil and RadioBoxUseBaseWorld:GetCheck()) then
		local ComboBoxBaseWorld = CommonCtrl.GetControl("EB_MMenu_NewWorld_BaseWorld_comboBox");
		if(ComboBoxBaseWorld~=nil) then
			BaseWorldPath = ComboBoxBaseWorld:GetText();
		end
	end	
				
	local tmp = ParaUI.GetUIObject("EB_MMenu_NEW_WorldName");
	if(tmp:IsValid() == true) then 
		local sName = tmp.text;
		if(sName == "") then
			_guihelper.MessageBox(L"world name can not be empty".."\n");
		elseif(sName == "_emptyworld") then
			_guihelper.MessageBox(L"_emptyworld presents an empty world. Please use another name.".."\n");
		else
			worldpath = EBook_db.book.worlds_path..sName;-- append the world dir name
			
			local CheckBoxUseBaseWorldNPC = CommonCtrl.GetControl("EB_MMenu_NEW_Check_UseBaseWorldNPC");
			local bInheriteNPC = (CheckBoxUseBaseWorldNPC~=nil and CheckBoxUseBaseWorldNPC:GetCheck());
			
			-- create a new world
			local res = Map3DSystem.CreateWorld(worldpath, BaseWorldPath, bInheriteNPC);
			if(res == true) then
				-- load success UI
				EBook_MediaMenu.NewWorldPath = worldpath;
				EBook_MediaMenu.SwitchWorldTabs(3); -- show the new world created page.
			elseif(type(res) == "string") then
				_guihelper.MessageBox(res);
			end
		end
	end
end

function EBook_MediaMenu.OnClickNewWorldCreatedOKBtn()
	local res = Map3DSystem.LoadWorld(Map3DSystem.World.name);
	if(res==true) then
		-- Do something after the load	
		EBook.ResetBookWorld(true);
		if(Map3DSystem.World.readonly) then
			Map3DSystem.User.SetRole("poweruser");
		else
			Map3DSystem.User.SetRole("administrator");
		end
	elseif(type(res) == "string") then
		-- show the error message
		_guihelper.MessageBox(res);
	end
end

function EBook_MediaMenu.OnCheckAutoSaveWorld(sCtrlName, checked)
	local page = EBook_db.GetCurrentPage();
	if(not page) then return end
	page.autosave_world = checked;
end

function EBook_MediaMenu.OnCheckNewWorldUseEmptyWorld()
	local ctl = CommonCtrl.GetControl("EB_MMenu_NewWorld_BaseWorld_comboBox");
	if(ctl~= nil)then
		ctl:SetEnabled(false);
	end
end

function EBook_MediaMenu.OnCheckNewWorldUseBaseWorld()
	local ctl = CommonCtrl.GetControl("EB_MMenu_NewWorld_BaseWorld_comboBox");
	if(ctl~= nil)then
		ctl:SetEnabled(true);
	end
end

-------------------------------------
-- drawing page
-------------------------------------
function EBook_MediaMenu.OnClickDrawing()
	EBook_MediaMenu.OnClose();
	local snapshot = EBook_db.GetPageScreenShotPath();
	if(snapshot~=nil) then
		local page = EBook_db.GetCurrentPage();
		if(not page) then return end
		if(page.mediafile==nil or ParaIO.DoesFileExist(snapshot)==false) then
			snapshot = "Texture/whitedot.png";
		end
		-- LXZ 2008.1.29. App enabled. 
		Map3DSystem.App.Commands.Call("File.Painter", {
			imagesize = 256,-- should be larger
			OnSaveCallBack = EBook_MediaMenu.OnClickSaveDrawing,
			LoadFromTexture = snapshot,
		});
	end
end

-- save drawing
function EBook_MediaMenu.OnClickSaveDrawing()
	local snapshot = EBook_db.GetPageScreenShotPath();
	if(snapshot~=nil) then
		if(Map3DSystem.UI.PainterManager.SaveAs(snapshot)) then
			ParaAsset.LoadTexture("",snapshot,1):UnloadAsset();
			local page = EBook_db.GetCurrentPage();
			if(not page) then return end
			page.mediafile = snapshot;
			EBook.UpdatePageMedia();
		else
			_guihelper.MessageBox("Unable to save the drawing. Maybe it is read-only");	
		end
	end
end

-------------------------------------
-- files page
-------------------------------------

-- called when the selection changed
function EBook_MediaMenu.OnSelectFiles_FileList()
	local tmp = ParaUI.GetUIObject("EB_MMenu_Files_FileList");
	if(tmp:IsValid() == true) then 
		local sName = tmp.text;
		if(sName~=nil and sName~="") then
			ParaUI.GetUIObject("EB_MMenu_Files_MediaFilePath").text = EBook_db.book.media_path..sName;
		end	
	end
end

-- called to clear the text
function EBook_MediaMenu.OnClickFiles_ClearBtn()
	ParaUI.GetUIObject("EB_MMenu_Files_MediaFilePath").text = "";
end

-- called to submit the file
function EBook_MediaMenu.OnClickFiles_OKbtn()
	-- TODO: 
	local page = EBook_db.GetCurrentPage();
	if(page~=nil) then
		local filename = ParaUI.GetUIObject("EB_MMenu_Files_MediaFilePath").text;
		if(filename==nil or filename== "" or ParaIO.DoesFileExist(filename, true)) then
			-- set media file for the page and quit the menu
			page.mediafile = filename;
			EBook_MediaMenu.OnClose();
			EBook.UpdatePageMedia();
		else
			_guihelper.MessageBox(L"the file specified does not exist.");	
		end	
	end
end

------------------------------------
-- audio page
------------------------------------
function EBook_MediaMenu.OnClickAudio_stop()
	ParaAudio.StopRecording();
end

function EBook_MediaMenu.OnClickAudio_play()
	--local teststr;
	--teststr = ParaAudio.GetRecordingDeviceEnum();
	--teststr = teststr.."\r\n";
	--teststr = teststr..ParaAudio.GetRecordingFormatEnum();
	--_guihelper.MessageBox(teststr);
	--log(teststr);
	local page = EBook_db.GetCurrentPage();
	if(page~=nil) then
		if(page.voice_file~=nil and ParaIO.DoesFileExist(page.voice_file, true))then
			ParaAudio.StopWaveFile(page.voice_file, true);
			ParaAudio.PlayWaveFile(page.voice_file, 0);
		end
	end
end

function EBook_MediaMenu.OnClickAudio_record()
	local page = EBook_db.GetCurrentPage();
	if(page~=nil) then
		page.voice_file = EBook_db.book.media_path.."myvoice"..page.pageid..".wav";
		-- ensure that the media directory exist
		ParaIO.CreateDirectory(page.voice_file);
		ParaAudio.SetRecordingOutput(page.voice_file, -1, -1);
		-- release last wave file
		ParaAudio.ReleaseWaveFile(page.voice_file);
		if(ParaAudio.BeginRecording()) then
			-- TODO: show top level control.
			-- your voice is now being recorded, please speak in front of your microphone.
			EBook_MediaMenu.ShowRecorder(true);
			local RadioBoxUseVoice = CommonCtrl.GetControl("EB_MMenu_Audio_MyVoice_checkBox");
			if(RadioBoxUseVoice~=nil) then
				RadioBoxUseVoice:SetCheck(true);
			end
		else
			_guihelper.MessageBox(L"You are not able to record sound. Please make sure you have a microphone installed on your computer. And that you have write permission on system disk.");
		end
	end
end

function EBook_MediaMenu.OnClickAudio_OKbtn()
	local page = EBook_db.GetCurrentPage();
	if(not page) then return end

	-- add voice wave file
	local RadioBoxUseVoice = CommonCtrl.GetControl("EB_MMenu_Audio_MyVoice_checkBox");
	if(RadioBoxUseVoice~=nil and RadioBoxUseVoice :GetCheck()) then
		-- page.voice_file is automatically saved at recording time.
	end	
	
	-- set music wave file
	local RadioBoxUseMusic = CommonCtrl.GetControl("EB_MMenu_Audio_FromFile_checkBox");
	if(RadioBoxUseMusic~=nil and RadioBoxUseMusic :GetCheck()) then
		local ComboBoxMusicFile = CommonCtrl.GetControl("EB_MMenu_Audio_WaveFile_comboBox");
		if(ComboBoxMusicFile~=nil) then
			page.music_file = ComboBoxMusicFile:GetText();
		end
	end	
	
	EBook.PlayPageAudio();
	EBook_MediaMenu.OnClose();
end
