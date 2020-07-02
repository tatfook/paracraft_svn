--[[
Title: load default UI theme
Author(s): WangTian
Date: 2008/12/2
Desc: load the default theme for the ui objects and common controls
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/DefaultTheme.lua");
MyCompany.Aries.Theme.Default:Load();
------------------------------------------------------------
]]

local DefaultTheme = commonlib.gettable("MyCompany.Aries.Theme.Default");

-- 0 will use unlit biped selection effect. 1 will use yellow border style. 
DefaultTheme.BipedSelectionEffect = 0;

-- load the default theme or style for the following ui objects and common controls
--		Cursor: default cursor
--		Day Length:
--		Default ui objects: scroll bar, button, text, editbox .etc
--		Font: default font
--		MessageBox: background
--		WindowFrame: frame background and close button
--		World Loader: background, logo, progress bar and text
function DefaultTheme:Load()
	if(true or (System.options.isAB_SDK and ParaIO.DoesFileExist("aries.deproj", false))) then
		-- turn this on to enable new kids version ui. 2012.5.23.
		System.options.theme = "v2";
	end

	-- ParaUI.SetUseSystemCursor(true);
	local default_cursor = {file = "Texture/kidui/main/cursor.tga", hot_x=3,hot_y=4};
	NPL.load("(gl)script/kids/3DMapSystemUI/Desktop/Cursor.lua");
	local Cursor = commonlib.gettable("Map3DSystem.UI.Cursor");
	Cursor.SetDefaultCursor(default_cursor);
	Cursor.ApplyCursor("default");
	local root_ = ParaUI.GetUIObject("root");
	if(root_.SetCursor) then
		root_:SetCursor(default_cursor.file, default_cursor.hot_x, default_cursor.hot_y);
	else
		root_.cursor = default_cursor.file;
	end

	-- whether to select server automatically
	System.options.auto_select_server = true;

	-- max user level
	System.options.max_user_level = 55;
	System.options.tradable_bag_family = {0,1,3,23,24,25,12,13,14};

	local version = commonlib.getfield("System.options.version");
    System.options.haqi_RMB_Currency="魔豆";
    System.options.haqi_GameCurrency="奇豆";

	-- how many minutes are there in a day.
	-- ParaScene.SetDayLength(900);
	
	_guihelper.SetDefaultMsgBoxMCMLTemplate("script/apps/Aries/Desktop/GUIHelper/Aries_DefaultMessageBox.html");
	
	-- NOTE: choose a font carefully for Aquarius
	
	--System.DefaultFontFamily = "Tahoma"; -- Windows default font (Not supporting Thai very well)
	--System.DefaultFontFamily = "helvetica"; -- Macintosh default font
	--System.DefaultFontFamily = "Verdana"; -- famous microsoft font (Recommended)
	
	System.DefaultFontFamily = "System";
	System.DefaultFontSize = 14;
	System.DefaultFontWeight = "norm";
	

	local fontStr = string.format("%s;%d;%s", 
				System.DefaultFontFamily, 
				System.DefaultFontSize, 
				System.DefaultFontWeight);
	
	-- TODO: artist should design the font family, size and bold type combination to utilize different text appearance
	-- SUGGESTION: use font with only alphabetical letter and number(not including Chinese characters) for pure visual(not informitive) text
	System.DefaultFontString = format("%s;%d;norm", System.DefaultFontFamily, System.DefaultFontSize);
	System.DefaultBoldFontString = format("%s;%d;bold", System.DefaultFontFamily, System.DefaultFontSize);
	System.DefaultLargeFontString = format("%s;%d;norm", System.DefaultFontFamily, 16);
	System.DefaultLargeBoldFontString = format("%s;%d;bold", System.DefaultFontFamily, 16);

	NPL.load("(gl)script/ide/gui_helper.lua");
	_guihelper.SetDefaultFont(fontStr)
	
	local _this;
	local texture;
	local _font;
	_this = ParaUI.GetDefaultObject("scrollbar");

	local states = {[1] = "highlight", [2] = "pressed", [3] = "disabled", [4] = "normal"};
	local function UpdateScrollBar_(_this)
		local i;
		for i = 1, 4 do
			_this:SetCurrentState(states[i]);
			texture=_this:GetTexture("track");
			texture.texture="Texture/Aries/Common/ThemeKid/scroll_track_32bits.png;0 0 19 32";
			texture=_this:GetTexture("up_left");
			texture.texture="Texture/Aries/Common/ThemeKid/scroll_upleft_32bits.png;0 0 19 21";
			texture=_this:GetTexture("down_right");
			texture.texture="Texture/Aries/Common/ThemeKid/scroll_downright_32bits.png;0 0 19 19";
			texture=_this:GetTexture("thumb");
			texture.texture="Texture/Aries/Common/ThemeKid/scroll_thumb_32bits.png;0 0 16 22";
			
		end
		--_this.fixedthumb = false;
		--_this.background = "Texture/Aries/Common/ThemeKid/scroll_thumb_32bits.png;0 0 16 22:3 16 3 4";
	end
	UpdateScrollBar_(_this);
	
	_this=ParaUI.GetDefaultObject("button");
	_this.font = fontStr;
	_this.background = "Texture/Aries/Common/ThemeKid/button_32bits.png;0 0 32 20:12 9 12 9";

	_this=ParaUI.GetDefaultObject("listbox");
	_this.font = fontStr;
	_this.background = "Texture/Aries/Common/ThemeKid/dropdown_bg.png:3 3 3 3";
	UpdateScrollBar_(_this:GetChild("vscrollbar"));

	_this=ParaUI.GetDefaultObject("container");
	_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/container_bg.png: 4 4 4 4";
	UpdateScrollBar_(_this:GetChild("vscrollbar"));

	_this=ParaUI.GetDefaultObject("editbox");
	_this.font = fontStr;
	_this.background = "Texture/Aries/Common/ThemeKid/editbox_32bits.png: 5 5 5 5";
	_this.spacing = 2;
	_this:GetAttributeObject():SetField("CaretColor", _guihelper.ColorStr_TO_DWORD("#ff808080"));
	_guihelper.SetFontColor(_this, "#000000");
	
	_this=ParaUI.GetDefaultObject("imeeditbox");
	_this.font = fontStr;
	_this.background = "Texture/Aries/Common/ThemeKid/editbox_32bits.png: 5 5 5 5";
	_this.spacing = 2;
	_font = _this:GetFont(4); -- "candidate_text"
	_font.font = fontStr;
	_font = _this:GetFont(6); -- "composition_text"
	_font.font = fontStr;
	_guihelper.SetFontColor(_this, "#000000");
	
	_this=ParaUI.GetDefaultObject("text");
	_this.font = fontStr;
	
	_this=ParaUI.GetDefaultObject("slider");
	_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/slider_background_16.png: 4 8 4 7"; 
	_this.button = "Texture/3DMapSystem/common/ThemeLightBlue/slider_button_16.png";
	
	-- 2d tooltip
	_this=ParaUI.GetDefaultObject("tooltip");
	_this.background = "Texture/Aries/Creator/border_bg_32bits.png:2 2 2 2"; 
	--_this.colormask = "255 255 255 204";
	_this:SetField("Spacing", 4);
	_guihelper.SetFontColor(_this, "#000000");
	
	-- 3d mouse tooltip, usually same as 2d tooltip
	NPL.load("(gl)script/apps/Aries/EventHandler_Mouse.lua");
	local HandleMouse = commonlib.gettable("MyCompany.Aries.HandleMouse");
	HandleMouse.SetCursorTextStyle({background="Texture/Aries/Creator/border_bg_32bits.png:2 2 2 2", 
		bg_line1="Texture/Aries/Creator/border_bg_32bits.png;0 0 8 6:2 2 2 2", 
		bg_line2="Texture/Aries/Creator/border_bg_32bits.png;0 2 8 6:2 2 2 2", 
		colormask="255 255 255 255", Spacing=2}, true);

	-- replace the default messagebox background with Aries customization
	_guihelper.MessageBox_BG = "Texture/Aries/Login/MessageBox_32bits.png:15 15 15 15";
	-- default toplevel dialogbox bg
	_guihelper.DialogBox_BG = "Texture/Aries/Login/MessageBox_32bits.png:15 15 15 15";
	
	-- TODO: change the following background
	_guihelper.OK_BG = "Texture/Aries/Button_HighLight.png:8 8 7 7";
	
	_guihelper.Cancel_BG = "Texture/Aries/Button_Normal.png:8 8 7 7";
	
	_guihelper.QuestionMark_BG = "Texture/3DMapSystem/QuestionMark_BG.png";
	
	_guihelper.ExclamationMark_BG = "Texture/3DMapSystem/ExclamationMark_BG.png";
	
	-- mcml related theme
	local pe_editor_radio = commonlib.gettable("Map3DSystem.mcml_controls.pe_editor_radio");
	pe_editor_radio.checked_bg = "Texture/Aries/Common/ThemeKid/radio_selected_32bits.png";
	pe_editor_radio.unchecked_bg = "Texture/Aries/Common/ThemeKid/radio_32bits.png";
	pe_editor_radio.iconSize = 16;

	local pe_editor_checkbox = commonlib.gettable("Map3DSystem.mcml_controls.pe_editor_checkbox");
	pe_editor_checkbox.checked_bg = "Texture/Aries/Common/ThemeKid/checkbox2_32bits.png";
	pe_editor_checkbox.unchecked_bg = "Texture/Aries/Common/ThemeKid/uncheckbox2_32bits.png";
	pe_editor_checkbox.iconSize = 16;

	local pe_select = commonlib.gettable("Map3DSystem.mcml_controls.pe_select");
	pe_select.dropdownBtn_bg = "Texture/Aries/Common/ThemeKid/dropdown_btn_32bits.png;0 0 20 20:18 1 1 19";
	pe_select.editbox_bg = "";
	pe_select.container_bg = "Texture/Aries/Common/ThemeKid/dropdown_bg_32bits.png:5 5 5 5";
	pe_select.listbox_bg = "Texture/Aries/Common/ThemeKid/dropdown_bg.png:3 3 3 3";
	
	local pe_aries_map = commonlib.gettable("MyCompany.Aries.mcml_controls.pe_aries_map");
	pe_aries_map.default_player_icon = "Texture/Aries/WorldMaps/common/maparrow_32bits.png"
	pe_aries_map.default_camera_icon = "Texture/Aries/WorldMaps/common/camera_arrow.png"

	NPL.load("(gl)script/ide/SliderBar.lua");
	CommonCtrl.SliderBar.background = "Texture/Aries/Common/ThemeKid/sliderbar_bg_32bits.png:4 3 4 3";
	CommonCtrl.SliderBar.button_bg = "Texture/Aries/Common/ThemeKid/sliderbtn_32bits.png;0 0 16 14:6 6 6 6";
	CommonCtrl.SliderBar.button_width = 20;
	CommonCtrl.SliderBar.button_height = 14;
	CommonCtrl.SliderBar.background_margin_top = 6;
	CommonCtrl.SliderBar.background_margin_bottom = 6;

	local pe_css = commonlib.gettable("Map3DSystem.mcml_controls.pe_css");
	pe_css.default = {
		-- Mobile version UI Control style
		["mobile_button"] = {background = "Texture/Aries/Creator/Mobile/blocks_UI_32bits.png;1 1 34 34:12 12 12 12", },
		["mobile_button_white"] = {background = "Texture/Aries/Creator/Mobile/blocks_UI_32bits.png;240 2 32 32:12 12 12 12",textscale = 2,},
		["mobile_button_black"] = {background = "Texture/Aries/Creator/Mobile/blocks_UI_32bits.png;206 2 32 32:12 12 12 12", },
		["mobile_button_grey"] = {background = "Texture/Aries/Creator/Mobile/blocks_UI_32bits.png;172 2 32 32:12 12 12 12", },
		["mobile_panel"] = {background = "Texture/Aries/Creator/Mobile/blocks_UI_32bits.png;6 6 26 26:12 12 12 12",},
		["mobile_panel_blue"] = {background = "Texture/Aries/Creator/Mobile/blocks_UI_32bits.png;36 2 32 32:12 12 12 12",},
		["mobile_panel_green"] = {background = "Texture/Aries/Creator/Mobile/blocks_UI_32bits.png;70 2 32 32:12 12 12 12",},
		["mobile_panel_grey"] = {background = "Texture/Aries/Creator/Mobile/blocks_UI_32bits.png;276 4 28 28:12 12 12 12",},
		["mobile_panel_grey_black"] = {background = "Texture/Aries/Creator/Mobile/blocks_UI_32bits.png;104 2 32 32:12 12 12 12",},
		["mobile_panel_black"] = {background = "Texture/Aries/Creator/Mobile/blocks_UI_32bits.png;138 2 32 32:12 12 12 12",},
		["mobile_panel_white"] = {background = "Texture/Aries/Creator/Mobile/blocks_UI_32bits.png;2 36 6 6:2 2 2 2",},
		["mobile_line"] = {background = "Texture/Aries/Creator/Mobile/blocks_UI_32bits.png;20 36 1 1", },
		-- ModWorld UI Control style
		["mc_small_button"] = {background = "Texture/Aries/Creator/Theme/CommonControl_32bits.png;32 32 32 34:12 12 12 12", ["text-offset-y"] = -4, },
		["mc_small_button_mouse_over"] = {background = "Texture/Aries/Creator/Theme/CommonControl_32bits.png;67 32 32 30:12 12 12 12",},
		["mc_small_button_selected"] = {background = "Texture/Aries/Creator/Theme/CommonControl_32bits.png;102 32 32 34:12 12 12 12",},
		["mc_big_button"] = {background = "Texture/Aries/Creator/Theme/CommonControl_32bits.png;32 70 32 128:12 12 12 12", ["text-offset-y"] = -4, ["font-size"] = 14, height=32},
		-- ["mc_big_button"] = {background = "",Normal_BG = "Texture/Aries/Creator/Theme/CommonControl_32bits.png;32 70 32 128:12 12 12 12", MouseOver_BG = "Texture/Aries/Creator/Theme/CommonControl_32bits.png;67 70 32 124:12 12 12 12",["text-offset-y"] = -4, ["font-size"] = 14, height=32},
		["mc_grey_button"] = {background = "Texture/Aries/Creator/Theme/CommonControl_32bits.png;208 70 32 128:12 12 12 12", ["text-offset-y"] = -4, ["font-size"] = 14, height=32},
		["mc_close_button"] = {
			background = "Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;370 62 14 14",
			["width"] = 14,
			["height"] = 14,
			["margin-top"] = 6,
			["margin-right"] = 6,
			["align"] = "right",
			["position"] = "relative",
		},
		["mc_big_button_mouse_over"] = {background = "Texture/Aries/Creator/Theme/CommonControl_32bits.png;67 70 32 124:12 12 12 12",},
		["mc_big_button_selected"] = {background = "Texture/Aries/Creator/Theme/CommonControl_32bits.png;102 70 32 128:12 12 12 12",},
		["mc_outer_panel"] = {background = "Texture/Aries/Creator/Theme/CommonControl_32bits.png;140 32 64 64:24 24 24 24",},
		["mc_inner_panel"] = {background = "Texture/Aries/Creator/Theme/CommonControl_32bits.png;32 202 16 16:6 6 6 6",},
		["mc_inner_panel_selected"] = {background = "Texture/Aries/Creator/Theme/CommonControl_32bits.png;52 202 16 16:6 6 6 6",},
		["mc_paper_panel"] = {background = "Texture/blocks/ItemFrame.png:5 5 5 5", color="#000000"},
		["mc_panel"] = {background = "Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;267 89 34 34:8 8 8 8",},
		["mc_scroll_bar"] = {background = "Texture/Aries/Creator/Theme/CommonControl_32bits.png;72 202 24 22",},
		["mc_border"] = {background = "Texture/Aries/Creator/Desktop/Inventory_32bits.png;99 365 29 29:3 5 4 5",},
		["mc_button_grey"] = {background = "Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;179 89 21 21:8 8 8 8",color="#ffffff"},
		["mc_button_blue"] = {background = "Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;208 89 21 21:8 8 8 8",color="#ffffff"},
		["mc_button_black"] = {background = "Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;425 126 13 13:5 5 5 5",color="#ffffff"},
		["mc_button_orange"] = {background = "Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;236 89 26 26:8 8 8 8",color="#ffffff"},
		["mc_button_green"] = {background = "Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;384 199 36 14:5 5 5 5",color="#ffffff"},
		-- these buttons with fillet
		["mc_dark_grey_button_with_fillet"] = {background = "Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;382 129 40 18:8 8 8 8",color="#ffffff"},
		["mc_light_grey_button_with_fillet"] = {background = "Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;382 175 40 18:8 8 8 8",color="#ffffff"},
		["mc_blue_button_with_fillet"] = {background = "Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;382 152 40 18:8 8 8 8",},
		["mc_green_button_with_fillet"] = {background = "Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;382 197 40 18:8 8 8 8",},
		["mc_item"] = {background = "Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;308 89 34 34:8 8 8 8",},
		["mc_slot"] = {background2 = "Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;308 89 34 34:8 8 8 8",},
		-- a dot is 1 px, which is used to draw a line
		["mc_line"] = {background = "Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;344 66 1 1", },
		["mc_text"] = {background = "Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;430 177 20 14:8 6 8 6",},
		["mc_questbutton"] = {
			["Normal_BG"] = "",
			["MouseOver_BG"] = "Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;210 89 16 16",
			["Pressed_BG"] = "Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;210 89 16 16",
			["background"] = "",
			["text-offset-x"] = 10,
			["color"] = "#ffffff",
		},
		["defaultbutton"] = {background = "Texture/Aries/Common/ThemeKid/button_highlight_32bits.png;0 0 32 20:12 9 12 9",},
		["card_button"] = {background = "Texture/Aries/Common/ThemeKid/button_highlight_32bits.png;0 0 32 20:12 9 12 9",},
		
		--["button"] = {background = "Texture/Aries/Common/ThemeKid/std_button_32bits.png;0 0 64 25:15 7 13 11",color="#095700"},
		["button"] = {background = "Texture/Aries/Common/ThemeKid/btn_thick_s_32bits.png:7 7 7 7",color="#095700", 
			["text-offset-y"] = -1,
		},
		["button_highlight"] = {background = "Texture/Aries/Common/ThemeKid/btn_thick_hl_32bits.png:7 7 7 7",color="#095700",
			["text-offset-y"] = -1,
		},
		["button_thick"] = {background = "Texture/Aries/Common/ThemeKid/btn_thick_32bits.png:7 7 7 7",color="#095700"},
		["defaultbtn"] = {background = "Texture/Aries/Common/ThemeKid/std_button_default_32bits.png;0 0 64 25:15 7 13 11",color="#095700"},
		["button_lightgrey"] = {
			["background"] = "Texture/Aries/Common/ThemeKid/button_lightgrey_32bits.png;0 0 32 25:5 5 5 5",
		},
		["button_yellowgreen"] = {
			["color"] = "#601f01",
			["background"] = "Texture/Aries/Common/ThemeKid/button_yellowgreen_32bits.png;0 0 64 25:8 8 8 8",
		},
		["button_orange"] = {
			["color"] = "#601f01",
			["background"] = "Texture/Aries/Common/ThemeKid/button_orange_32bits.png;0 0 16 22:6 5 6 5",
		},
		["bordertext"] = {
			["shadow-quality"] = 8,
			["shadow-color"] = "#2a2a2e27",
			["text-shadow"] = "true",
		},
		["container"] = {
			["background"] = "Texture/3DMapSystem/common/ThemeLightBlue/container_bg.png: 4 4 4 4",
		},
		["autoborder"] = {
			["shadow-quality"] = 8,
			["text-shadow"] = "true",
			["text-offset-y"]=-2,
		},
		["bbs_text"] = {
			--["shadow-quality"] = 8,
			--["shadow-color"] = "#2a2a2e27",
			--["text-shadow"] = "true",
			["font-weight"] = "bold", 
			["background"] = "Texture/whitedot.png", 
			["background-color"] = "#00000080", 
		},
		["bbs_sys_text"] = {
			--["shadow-quality"] = 8,
			--["shadow-color"] = "#2a2a2e27",
			--["text-shadow"] = "true",
			["font-weight"] = "bold", 
			["background"] = "Texture/whitedot.png", 
			["background-color"] = "#80000080", 
		},
		["linkbutton"] = {
			["color"] = "#0000ff",
			["background-color"] = "#0000ff",
			["background"] = "Texture/Aries/Common/underline_white_32bits.png:3 3 3 3",
		},
		["linkbutton_yellow"] = {
			["color"] = "#f0f000",
			["background-color"] = "#f0f000",
			["background"] = "Texture/Aries/Common/underline_white_32bits.png:3 3 3 3",
		},
		["link"] = {
			["Normal_BG"] = "",
			["MouseOver_BG"] = "Texture/Aries/Common/underline_blue_32bits.png",
			["Pressed_BG"] = "",
			["background"] = "",
		},
		["tooltip"] = {
			["font-size"] = 12,
			["padding"] = 8,
			["background"] = "Texture/Aries/Creator/border_bg_tips_32bits.png:5 5 5 5",
		},
		["tooltip_text_highlight"] = {
			["font-weight"] = "bold",
		},
		["item"] = {
			["padding"] = 1,
			["background"] = "Texture/Aries/Common/bg_itemicon_32bits.png: 4 4 4 4;",
		},
		["menu"] = {
			["padding"] = 4,
			["background"] = "Texture/Aries/Common/ThemeKid/menu_bg_32bits.png:15 15 15 15",
		},
		["tab_selected"] = {
			["background"] = "Texture/Aries/Common/ThemeKid/tab_btn_selected_32bits.png;0 0 41 26:12 14 12 14",
			["font-size"] = 12,
			["color"] = "#464f45",
			["background-color"] = "#ffffffff",
		},
		["tab_unselected"] = {
			["background"] = "Texture/Aries/Common/ThemeKid/tab_btn_unselected_32bits.png;0 0 41 26:12 14 12 14",
			["font-size"] = 12,
			["color"] = "#464f45",
		},
		["tab_selected_red"] = {
			["background"] = "Texture/Aries/Common/ThemeKid/tab_btn_selected_32bits.png;0 0 41 26:12 14 12 14",
			["font-size"] = 12,
			["color"] = "#464f45",
			["background-color"] = "#ffffffff",
		},
		["tab_unselected_red"] = {
			["background"] = "Texture/Aries/Common/ThemeKid/tab_btn_unselected_32bits.png;0 0 41 26:12 14 12 14",
			["font-size"] = 12,
			["color"] = "#464f45",
		},
		["tabs"] = {
			["background"] = "Texture/Aries/Common/ThemeKid/pannel_bg2_32bits.png:5 5 8 8",
			["background_overdraw"] = 1,
			["SelectedMenuItemBG"]="Texture/Aries/Common/ThemeKid/tab_btn_selected_32bits.png;0 0 41 26:12 14 12 14",
			["UnSelectedMenuItemBG"]="Texture/Aries/Common/ThemeKid/tab_btn_unselected_32bits.png;0 0 41 26:12 14 12 14",
			["SelectedTextColor"]="#000000",
			["TextColor"]="#464f45",
			["ItemSpacing"]="5",
			["TextFont"]="System;12;norm",
			["padding-left"] = 5, 
			["padding-top"] = 27, 
		},
		["tabs_nobg"] = {
			["background"] = "",
			["background_overdraw"] = 1,
			["SelectedMenuItemBG"]="Texture/Aries/Common/ThemeKid/tab_btn_selected_32bits.png;0 0 41 26:12 14 12 14",
			["UnSelectedMenuItemBG"]="Texture/Aries/Common/ThemeKid/tab_btn_unselected_32bits.png;0 0 41 26:12 14 12 14",
			["SelectedTextColor"]="#000000",
			["TextColor"]="#464f45",
			["ItemSpacing"]="5",
			["TextFont"]="System;12;norm",
			["padding-left"] = 5, 
			["padding-top"] = 27, 
		},
		["tabs_red"] = {
			["background"] = "Texture/Aries/Common/ThemeKid/pannel_bg2_32bits.png:5 5 8 8",
			["background_overdraw"] = 1,
			["SelectedMenuItemBG"]="Texture/Aries/Common/ThemeKid/red_tab_btn_selected_32bits.png;0 0 41 26:12 14 12 14",
			["UnSelectedMenuItemBG"]="Texture/Aries/Common/ThemeKid/red_tab_btn_unselected_32bits.png;0 0 41 26:12 14 12 14",
			["SelectedTextColor"]="#000000",
			["TextColor"]="#464f45",
			["ItemSpacing"]="5",
			["TextFont"]="System;12;norm",
			["padding-left"] = 5, 
			["padding-top"] = 27, 
		},
		["tabs_nobg_red"] = {
			["background"] = "",
			["background_overdraw"] = 1,
			["SelectedMenuItemBG"]="Texture/Aries/Common/ThemeKid/red_tab_btn_selected_32bits.png;0 0 41 26:12 14 12 14",
			["UnSelectedMenuItemBG"]="Texture/Aries/Common/ThemeKid/red_tab_btn_unselected_32bits.png;0 0 41 26:12 14 12 14",
			["SelectedTextColor"]="#000000",
			["TextColor"]="#464f45",
			["ItemSpacing"]="5",
			["TextFont"]="System;12;norm",
			["padding-left"] = 5, 
			["padding-top"] = 27, 
		},
		--treeview
		["defaulttreeview"] = {
			["background"] = "",
			["ItemOpenBG"] = "Texture/Aries/Common/ThemeTeen/can_close_32bits.png;0 0 20 20",
			["ItemCloseBG"] = "Texture/Aries/Common/ThemeTeen/can_open_32bits.png;0 0 20 20",
			["RememberScrollPos"] = true,
			["ItemToggleSize"] = 18,
			["DefaultNodeHeight"] = 22,
		},
		--skill tabs
		["skill_subtabs"] = {
			["background"] = "",
			["SelectedMenuItemBG"] = "Texture/Aries/Common/ThemeKid/sliderbtn_32bits.png;0 0 16 14:6 6 6 6",
			["UnSelectedMenuItemBG"]="",
			["SelectedTextColor"]="#ffff00",
			["TextColor"]="#022a57",
			["ItemSpacing"]="0",
			["TextFont"]="System;12;norm",
			["margin-left"] = 10, 
			["padding-top"] = 22, 
		},

		--skill tabs
		["skill_subtabs_bg"] = {
			["background"] = "Texture/Aries/Common/ThemeKid/wnd_title.png:2 6 1 6",
			["font-size"] = 12,
			["margin-left"]  = 5,
		},
		["menuitem_bg"] = {
			["background"] = "Texture/Aries/Common/RowMouseHover.png;0 0 2 22",
		},
		["pe:tabs"] = {
			["background"] = "",
			["background_overdraw"] = 1,
			["SelectedMenuItemBG"]="Texture/Aries/HaqiShop/radiobg1_32bits.png:12 14 12 14",
			["UnSelectedMenuItemBG"]="Texture/Aries/HaqiShop/radiobg2_32bits.png:12 14 12 14",
			["SelectedTextColor"]="#000000",
			["TextColor"]="#000000",
			["ItemSpacing"]="5",
			["TextFont"]="System;12;norm",			
			["padding-left"] = 5, 
			["padding-top"] = 27, 
		},
		["pe:tab-item"] = {
			-- the tab button height plus some space, such as 20+1
			["padding-top"] = 5, 
		},
		["header"] = {
			["background"] = "Texture/Aries/LobbyService/header_bg2_32bits.png;0 0 16 25: 7 7 7 7",
			["font-size"] = 12,
			["text-align"] = "center",
			["padding-left"] = 4,
			["padding-top"] = 2,
			["width"] = 63,
			["height"] = 25,
		},
		["tab_inborder"] = {
			["background"] = "Texture/Aries/Common/ThemeKid/pannel_bg2_32bits.png:5 5 8 8",
			["color"] = "#022a57",
			["font-size"] = 12,
		},
		["panel"] = {
			["background"] = "Texture/Aries/Common/ThemeKid/pannel_bg2_32bits.png:5 5 8 8",
			["color"] = "#022a57",
			["font-size"] = 12,
		},
		["panel_red"] = {
			["background"] = "Texture/Aries/Common/ThemeKid/red_pannel_bg2_32bits.png:5 5 8 8",
			["color"] = "#022a57",
			["font-size"] = 12,
		},
		["pane"] = {
			["background"] = "Texture/Aries/Common/bg.png: 14 14 14 14",
			["font-size"] = 12,
		},
		["block_blue"]= {
			["background"] = "Texture/Aries/HaqiShop/bg.png;0 0 16 16:5 5 5 5",
			["color"] = "#022a57",
		},
		["inborder"] = {
			["background"] = "Texture/Aries/HaqiShop/bg4_32bits.png:20 20 20 20",
			["font-size"] = 12,
			["margin-left"]  = 5,
		},
		["inborder2"] = {
			["background"] = "Texture/Aries/LobbyService/box_bg_4_32bits.png: 7 7 7 7",
			["font-size"] = 12,
		},
		["inborder_golden"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/pane_inborder_golden_32bits.png: 5 5 5 5",
			-- ["color"] = "#52dff4",
			["font-size"] = 12,
			["margin-left"]  = 5,
		},
		["closebutton"] = {
			["background"] = "Texture/Aries/Common/Close_48_32bits.png;0 0 48 48",
			["width"] = 48,
			["height"] = 48,
		},
		["block"] = {
			["background"] = "Texture/Aries/HaqiShop/bg3_32bits.png:10 10 10 10",
			-- ["background"] = "Texture/Aries/NewProfile/bg_equip_32bits.png:10 10 10 10",
			["width"] = 48,
			["height"] = 48,
			["font-size"] = 12,
		},

		["lotterycard"] = {
			["background"] = "Texture/Aries/Common/ThemeKid/card_bg_32bits.png;0 0 63 80:6 6 6 6",
		},
		["lotterycard_selected"] = {
			["background"] = "Texture/Aries/Common/ThemeKid/card_selected_bg_32bits.png;0 0 63 80:6 6 6 6",
		},
		["creator_dock_bg"] = {
			["background"] = "Texture/Aries/Creator/dock/dock_bg_32bits.png;0 0 64 42:31 20 31 20",
		},
		["equip_bg"] = {
			["background"] = "Texture/Aries/NewProfile/bg_equip_32bits.png:10 10 10 10",
			["width"] = 48,
			["height"] = 48,
			["font-size"] = 12,
		},
		["static_block"] = {
			["background"] = "Texture/Aries/NewProfile/bg1_32bits.png: 10 10 10 10",
			["width"] = 48,
			["height"] = 48,
			["font-size"] = 12,
		},
		["pagerbuttonleft"] = {
			["background"] = "Texture/Aries/Common/ThemeKid/button_highlight_32bits.png;0 0 32 20:12 9 12 9",
			["width"] = 60,
			["height"] = 25,
			["font-size"] = 12,
			["zorder"] = 2,
		},
		["pagerbuttonright"] = {
			["background"] = "Texture/Aries/Common/ThemeKid/button_highlight_32bits.png;0 0 32 20:12 9 12 9",
			["width"] = 60,
			["height"] = 25,
			["font-size"] = 12,
			["zorder"] = 2,
		},
		["pagerbuttontext"] = {
			["background"] = "",
			["width"] = 50,
			["height"] = 25,
			["font-size"] = 12,
			["margin"] = 4,
			["margin-top"] = 2,
			["text-align"] = "center",
		},
		["helptip"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/rookiehelp_bg_32bits.png: 6 6 6 6",
		},
		["listbutton_selected"] = {
			["Normal_BG"] = "Texture/Aries/LobbyService/selected_bg_32bits.png",
			["MouseOver_BG"] = "Texture/Aries/LobbyService/selected_bg_32bits.png",
			["Pressed_BG"] = "Texture/Aries/LobbyService/selected_bg_32bits.png",
			["background"] = "",
			["font-size"] = 12,
			["height"] = 22,
		},
		["listbutton_unselected"] = {
			["Normal_BG"] = "",
			["MouseOver_BG"] = "Texture/Aries/LobbyService/selected_bg2_32bits.png",
			["Pressed_BG"] = "",
			["background"] = "",
			["font-size"] = 12,
			["height"] = 22,
		},
		["stable_bean"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/others/stable_bean_32bits.png",
			["width"] = 64,
			["height"] = 64,
		},
		["flow_bean"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/others/flow_bean_32bits.png",
			["width"] = 64,
			["height"] = 64,
		},
		["golden_bean"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/others/golden_bean_32bits.png",
			["width"] = 64,
			["height"] = 64,
		},
		["magic_bean"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/others/magic_bean_32bits.png",
			["width"] = 64,
			["height"] = 64,
		},
		["flaming_crystal"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/others/flaming_crystal_32bits.png",
			["width"] = 64,
			["height"] = 64,
		},
		["jade"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/others/jade_32bits.png",
			["width"] = 64,
			["height"] = 64,
		},
		["god_bean"] = {
			["background"] = "Texture/Aries/Item/17213_GodBean.png",
			["width"] = 64,
			["height"] = 64,
		},
		["doughnut"] = {
			["background"] = "Texture/Aries/Item/17168_doughnut.png",
			["width"] = 64,
			["height"] = 64,
		},
		-- containers
		["window_red"]={
			["background"] = "Texture/Aries/Common/ThemeKid/red_window_bg_32bits.png:10 10 10 10",
			["color"] = "#022a57",
		},
		["window"]={
			["background"] = "Texture/Aries/Common/ThemeKid/window_bg_32bits.png:10 10 10 10",
			["color"] = "#022a57",
		},
		["windowlabel"] = {
			["text-align"] = "left",
			["margin-left"] = 10,
			["margin-top"] = 2,
			["position"] = "relative",
			["font-weight"] = "bold",
			["shadow-quality"] = 8,
			["color"] = "#fcf73c",
			["font-size"] = 14,
			["shadow-color"] = "#8000468e",
			["text-shadow"] = true,
		},
		--["pane"] = {
			--["background"] = "Texture/Aries/Common/ThemeKid/pannel_bg2_32bits.png:7 7 7 7",
			--["height"] = 59,
		--},
		["closewindow"] = {
			["background"] = "Texture/Aries/Common/ThemeKid/close_btn_32bits.png;0 0 28 28",
			["width"] = 28,
			["height"] = 28,
			["margin-top"] = 1,
			["margin-right"] = 5,
			["align"] = "right",
			["position"] = "relative",
		},
		["titlebar"] = {
			["background"] = "Texture/Aries/Common/ThemeKid/wnd_title.png:2 6 1 6",
			["margin-top"] = 5,
			["margin-left"] = 5,
			["height"] = 27,
		},
		["image_title"]={
			["background"] = "Texture/Aries/Common/ThemeKid/image_title_32bits.png:252 20 252 20",
			["margin-top"] = -5,
			["height"] = 59,
		},
		["image_title_red"]={
			["background"] = "Texture/Aries/Common/ThemeKid/red_image_title_32bits.png:252 20 252 20",
			["margin-top"] = -5,
			["height"] = 59,
		},
		["clientarea"] = {
			["font-size"] = 12,
			["margin-left"] = 10,
			["margin-right"] = 10,
			["margin-top"] = 3,
			["margin-bottom"] = 5,
			["color"] = "#022a57",
		},
		["anchor_tooltip"] = {
			["background"] = "Texture/Aries/Common/ThemeKid/tip/tip_bg_32bits.png: 10 10 10 10",
			["padding"] = 4,
			["padding-bottom"] = 5,
		},
		["anchor_tooltip_bg"] = {
			["background"] = "Texture/Aries/Common/ThemeKid/tip/tip_bg_32bits.png: 10 10 10 10",
			["padding"] = 4,
		},
		["anchor_tooltip_downarrow"] = {
			["background"] = "Texture/Aries/Common/ThemeKid/tip/tip_arrow_rightdown_32bits.png",
			["width"] = 32,
			["height"] = 32,
		},
		["anchor_tooltip_close"] = {
			["background"] = "Texture/Aries/Common/ThemeKid/close_btn_32bits.png;0 0 28 28",
			["width"] = 28,
			["height"] = 28,
			["align"] = "right",
			["position"] = "relative",
		},
		["anchor_tooltip_highlight"] = {
			["background"] = "Texture/Aries/Common/ThemeKid/tip/tip_highlight_32bits.png;0 0 44 44",
			["width"] = 44,
			["height"] = 44,
		},
		["pet_icon"] = {
			["background2"] = "Texture/Aries/Common/ThemeKid/character/pet_icon_bg.png",
			["width"] = 32,
			["height"] = 32,
			["float"] = "left",
			["position"] = "relative",
		},
		["questbutton_selected"] = {
			["Normal_BG"] = "",
			["MouseOver_BG"] = "Texture/aries/quest/questlist/font_over_bg.png",
			["Pressed_BG"] = "Texture/aries/quest/questlist/font_pressed_bg.png",
			["background"] = "",
			["color"] = "#6e3001",
		},
		["animated_btn_overlay"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/animated/btn_anim_32bits_fps10_a012.png",
		},
		["animated_btn2_overlay"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/animated/UIefx_Yellow/UIefx_Yellow_32bits_fps12_a012.png",
		},
		["animated_btn3_overlay"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/animated/UIefx_Yellow_Rectangle/btn_rect_anim_32bits_fps10_a012.png",
		},
		["animated_upgrade_overlay"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/animated/UIefx_QiangHua_Red/UIefx_QiangHua_Red_64bits_fps10_a006.png",
		},
	}

	NPL.load("(gl)script/ide/ContextMenu.lua");
	CommonCtrl.ContextMenu.DefaultStyle = {
		borderTop = 4,
		borderBottom = 4,
		borderLeft = 0,
		borderRight = 0,
		
		fillLeft = -20,
		fillTop = -15,
		fillWidth = -19,
		fillHeight = -24,
		
		titlecolor = "#283546",
		level1itemcolor = "#283546",
		level2itemcolor = "#3e7320",
				
		menu_bg = "Texture/Aries/Dock/menu_lvl2_bg_32bits.png:39 30 24 30",
		shadow_bg = nil,
		separator_bg = "Texture/Aries/Dock/menu_separator_32bits.png", -- : 1 1 1 4
		item_bg = "Texture/Aries/Dock/menu_item_bg_32bits.png: 10 6 10 6",
		expand_bg = "Texture/Aries/Dock/menu_expand_32bits.png; 0 0 34 34",
		expand_bg_mouseover = "Texture/Aries/Dock/menu_expand_mouseover_32bits.png; 0 0 34 34",
		
		menuitemHeight = 30,
		separatorHeight = 2,
		titleHeight = 26,
		
		titleFont = "System;14;bold";
	};
	
	CommonCtrl.ContextMenu.DefaultStyleThick = {
				borderTop = 4,
				borderBottom = 4,
				borderLeft = 18,
				borderRight = 22,
				
				fillLeft = 0,
				fillTop = -15,
				fillWidth = 0,
				fillHeight = -24,
				
				titlecolor = "#283546",
				level1itemcolor = "#283546",
				level2itemcolor = "#3e7320",
				
				menu_bg = "Texture/Aries/Dock/menu_lvl2_bg_32bits.png:39 30 24 30", -- "Texture/Aries/Dock/menu_bg_32bits.png:39 30 24 30",
				menu_lvl2_bg = "Texture/Aries/Dock/menu_lvl2_bg_32bits.png:39 30 24 30",
				shadow_bg = nil,
				separator_bg = "Texture/Aries/Dock/menu_separator_32bits.png", -- : 1 1 1 4
				item_bg = "Texture/Aries/Dock/menu_item_bg_32bits.png: 10 6 10 6",
				expand_bg = "Texture/Aries/Dock/menu_expand_32bits.png; 0 0 34 34",
				expand_bg_mouseover = "Texture/Aries/Dock/menu_expand_mouseover_32bits.png; 0 0 34 34",
				
				menuitemHeight = 30,
				separatorHeight = 2,
				titleHeight = 26,
				
				titleFont = "System;14;bold";
			};
	-- replace the default window style with Aquarius customization
	CommonCtrl.WindowFrame.DefaultStyle = {
		name = "DefaultStyle",
		
		--window_bg = "Texture/Aquarius/Common/frame2_32bits.png:8 25 8 8",
		window_bg = "Texture/Aquarius/Common/Frame3_32bits.png:32 46 20 17",
		fillBGLeft = 0,
		fillBGTop = 0,
		fillBGWidth = 0,
		fillBGHeight = 0,
		
		shadow_bg = "Texture/Aquarius/Common/Frame3_shadow_32bits.png: 16 16 32 32",
		fillShadowLeft = -5,
		fillShadowTop = -4,
		fillShadowWidth = -9,
		fillShadowHeight = -10,
		
		titleBarHeight = 36,
		toolboxBarHeight = 48,
		statusBarHeight = 32,
		borderLeft = 1,
		borderRight = 1,
		borderBottom = 16,
		
		textfont = System.DefaultBoldFontString;
		textcolor = "35 35 35",
		
		iconSize = 16,
		iconTextDistance = 16, -- distance between icon and text on the title bar
		
		IconBox = {alignment = "_lt",
					x = 13, y = 12, size = 16,},
		TextBox = {alignment = "_lt",
					x = 32, y = 12, height = 16,},
					
		CloseBox = {alignment = "_rt",
					x = -24, y = 11, sizex = 17, sizey = 16, 
					icon = "Texture/Aquarius/Common/Frame_Close_32bits.png; 0 0 17 16",
					icon_over = "Texture/Aquarius/Common/Frame_Close_over_32bits.png; 0 0 17 16",
					icon_pressed = "Texture/Aquarius/Common/Frame_Close_pressed_32bits.png; 0 0 17 16",
					},
		MinBox = {alignment = "_rt",
					x = -60, y = 11, sizex = 17, sizey = 16, 
					icon = "Texture/Aquarius/Common/Frame_Min_32bits.png; 0 0 17 16",
					icon_over = "Texture/Aquarius/Common/Frame_Min_over_32bits.png; 0 0 17 16",
					icon_pressed = "Texture/Aquarius/Common/Frame_Min_pressed_32bits.png; 0 0 17 16",
					},
		MaxBox = {alignment = "_rt",
					x = -42, y = 11, sizex = 17, sizey = 16, 
					icon = "Texture/Aquarius/Common/Frame_Max_32bits.png; 0 0 17 16",
					icon_over = "Texture/Aquarius/Common/Frame_Max_over_32bits.png; 0 0 17 16",
					icon_pressed = "Texture/Aquarius/Common/Frame_Max_pressed_32bits.png; 0 0 17 16",
					},
		PinBox = {alignment = "_lt", -- TODO: pin box, set the pin box in the window frame style
					x = 2, y = 2, size = 20,
					icon_pinned = "Texture/3DMapSystem/WindowFrameStyle/1/autohide.png; 0 0 20 20",
					icon_unpinned = "Texture/3DMapSystem/WindowFrameStyle/1/autohide2.png; 0 0 20 20",},
		
		resizerSize = 24,
		resizer_bg = "Texture/3DMapSystem/WindowFrameStyle/1/resizer.png",
	};
	
	
	-- change the loader UI, remove following lines if u want to use default paraworld loader ui.
	--[[NPL.load("(gl)script/kids/3DMapSystemUI/InGame/LoaderUI.lua");
	System.UI.LoaderUI.items = {
		{name = "Aries.UI.LoaderUI.bg", type="container",bg="Texture/Aries/Login/UserSelect_BG2_32bits.png;0 0 1020 680", alignment = "_fi", left=0, top=0, width=0, height=0, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_motion.xml"},
		
		{name = "Aries.UI.LoaderUI.bg", type="container",bg="Texture/Aries/Loader/loading_bg_32bits.png;0 0 1020 680", alignment = "_fi", left=0, top=0, width=0, height=0, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_motion.xml"},
		{name = "Aries.UI.LoaderUI.logoTxt", type="container",bg="", alignment = "_rb", left=-320-20, top=-20-5, width=320, height=20, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
		{name = "Aries.UI.LoaderUI.logo", type="container",bg="", alignment = "_ct", left=-512/2, top=-290/2, width=512, height=128, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
		{name = "Aries.UI.LoaderUI.progressbar_bg", type="container",bg="Texture/Aries/Loader/loading_panel_32bits.png: 60 60 60 60", alignment = "_ct", left=-240, top=-90, width=480, height=128, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
		{name = "Aries.UI.LoaderUI.text", type="text", text="正在加载哈奇小镇...", color = "255 255 255", alignment = "_ct", left=-100+10, top=28, width=200, height=20, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
		{name = "Aries.UI.LoaderUI.gossip", type="text", texts={
			"dummy",


			}, alignment = "_ct", left=-200+10, top=-36, width=400, height=20, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
		-- this is a progressbar that increases in length from width to max_width
		{IsProgressBar=true, name = "Aries.UI.LoaderUI.progressbar_filled", type="container", bg="Texture/Aries/Loader/loading_slot_32bits.png;0 0 64 13: 20 6 20 6", alignment = "_ct", left=-204, top=-70, width=40, max_width=408, height=13, anim="script/kids/3DMapSystemUI/InGame/LoaderUI_2_motion.xml"},
	}]]

	self:RestoreDefaultCharacterRegionPaths();
	self:LoadHeadDisplayStyle();
	
	NPL.load("(gl)script/ide/TooltipHelper.lua");
	local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");
	local default_stack = BroadcastHelper.GetSingletonTipsStack();
	default_stack.background = "Texture/Aries/Common/gradient_white_32bits.png";
	default_stack.background_color = "#1f3243";

	NPL.load("(gl)script/kids/3DMapSystemApp/Assets/AsyncLoaderProgressBar.lua");
	local AsyncLoaderProgressBar = commonlib.gettable("Map3DSystem.App.Assets.AsyncLoaderProgressBar");
	AsyncLoaderProgressBar.alignment = "_lb";
	AsyncLoaderProgressBar.left = 20;
	AsyncLoaderProgressBar.top = -360;
	AsyncLoaderProgressBar.width = 32;
	AsyncLoaderProgressBar.height = 160;
	local loader_bar = AsyncLoaderProgressBar.GetDefaultAssetBar()
	if(loader_bar) then
		--loader_bar.image_layout.background = "Texture/Aries/Common/ThemeTeen/AssetLoader_32bits.png";
		--loader_bar.text_layout.color = "#52dff4";
		--loader_bar.text_layout.top = 62;
		loader_bar:RefreshStyle();
	end
end

function DefaultTheme:RestoreDefaultCharacterRegionPaths()
	ParaScene.SetCharacterRegionPath(32, "character/v3/Item/ObjectComponents/Head/");
	ParaScene.SetCharacterRegionPath(34, "character/v3/Item/ObjectComponents/Weapon/");
	ParaScene.SetCharacterRegionPath(19, "character/v3/Item/TextureComponents/AriesCharShirtTexture/");
	ParaScene.SetCharacterRegionPath(20, "character/v3/Item/TextureComponents/AriesCharShirtTexture/");
	ParaScene.SetCharacterRegionPath(23, "character/v3/Item/TextureComponents/AriesCharFootTexture/");
	ParaScene.SetCharacterRegionPath(38, "character/v3/Item/TextureComponents/AriesCharWingTexture/");
	ParaScene.SetCharacterRegionPath(39, "character/v3/Item/ObjectComponents/Back/");

	local CharTexSize = 256; -- the recommended size is 256, however 512 is the original size of component textures, 2007.7.7 by LiXizhi
	local FaceTexSize = 256; 
	if(System.options.IsTouchDevice) then
		CharTexSize = 128;
		FaceTexSize = 128;
	end

	local offset_scaling = FaceTexSize/256;
	local regions = {
		--
		-- character face regions: left, top, width, height
		--
		{0, 0, CharTexSize, CharTexSize},	-- base
		{0, 0, CharTexSize/2, CharTexSize/4},	-- arm upper
		{0, CharTexSize/4, CharTexSize/2, CharTexSize/4},	-- arm lower
		{0, CharTexSize/2, CharTexSize/2, CharTexSize/8},	-- hand
		{0, CharTexSize/8*5, CharTexSize/2, CharTexSize/8},	-- face upper
		{0, CharTexSize/8*6, CharTexSize/2, CharTexSize/4},	-- face lower
		{CharTexSize/2, 0, CharTexSize/2, CharTexSize/4},	-- torso upper
		{CharTexSize/2, CharTexSize/4, CharTexSize/2, CharTexSize/8},	-- torso lower
		{CharTexSize/2, CharTexSize/8*3, CharTexSize/2, CharTexSize/4}, -- leg upper
		{CharTexSize/2, CharTexSize/8*5, CharTexSize/2, CharTexSize/4},-- leg lower
		{CharTexSize/2, CharTexSize/8*7, CharTexSize/2, CharTexSize/8},	-- foot
		{0, CharTexSize/8*6, CharTexSize/2, CharTexSize/4},	-- wings

		--
		-- character face regions: center_x, center_y, default_width, default_height
		--
		{FaceTexSize/2, FaceTexSize/2, FaceTexSize, FaceTexSize},	-- face base
		{FaceTexSize/2, FaceTexSize/2, FaceTexSize, FaceTexSize},	-- wrinkle
		{FaceTexSize/2+30*offset_scaling, FaceTexSize/2, FaceTexSize/4, FaceTexSize/4},	-- eye right
		{FaceTexSize/2+33*offset_scaling, FaceTexSize/2-20*offset_scaling, FaceTexSize/4, FaceTexSize/4},	-- eye bow right
		{FaceTexSize/2, FaceTexSize/2+41*offset_scaling, FaceTexSize/4, FaceTexSize/4},	-- mouth
		{FaceTexSize/2, FaceTexSize/2+12*offset_scaling, FaceTexSize/4, FaceTexSize/4},	-- nose
		{FaceTexSize/2, FaceTexSize/2, FaceTexSize, FaceTexSize},	-- mark

		--
		-- aries character skin regions: left, top, width, height
		--
		{0, 0, CharTexSize, CharTexSize/2}, -- CR_ARIES_CHAR_SHIRT,
		{0, CharTexSize/2, CharTexSize, CharTexSize/2}, -- CR_ARIES_CHAR_SHIRT_OVERLAYER
		{CharTexSize/2, CharTexSize/2, CharTexSize/2, CharTexSize/2}, -- CR_ARIES_CHAR_PANT,
		{0, CharTexSize/2, CharTexSize/2, CharTexSize/8},	-- CR_ARIES_CHAR_HAND
		{0, CharTexSize/8*6, CharTexSize/2, CharTexSize/4},	-- CR_ARIES_CHAR_FOOT
		{0, CharTexSize/8*4, CharTexSize/2, CharTexSize/4}, -- CR_ARIES_CHAR_GLASS

		--
		-- aries pet skin regions: left, top, width, height
		--
		{0, 0, CharTexSize/2, CharTexSize/2}, -- CR_ARIES_PET_HEAD,
		{CharTexSize/2, 0, CharTexSize/2, CharTexSize}, -- CR_ARIES_PET_BODY,
		{CharTexSize/2, CharTexSize/2, CharTexSize/2, CharTexSize/2}, -- CR_ARIES_PET_TAIL,
		{0, CharTexSize/2, CharTexSize/2, CharTexSize/2}, -- CR_ARIES_PET_WING,

		{0, 0, CharTexSize, CharTexSize}, -- CR_ARIES_CHAR_SHIRT_TEEN,
	};
	ParaScene.SetCharTextureSize(CharTexSize, FaceTexSize);

	for nRegionIndex, coords in ipairs(regions) do
		ParaScene.SetCharRegionCoordinates(nRegionIndex-1, coords[1], coords[2], coords[3], coords[4]);
	end
end

function DefaultTheme:LoadHeadDisplayStyle()
	NPL.load("(gl)script/kids/3DMapSystemUI/HeadonDisplay.lua");
	local HeadonDisplay = commonlib.gettable("Map3DSystem.UI.HeadonDisplay")
	-- one can overwrite HeadonDisplay.headon_style before InitHeadOnTemplates is called.
	HeadonDisplay.headon_style = {
		-- some background
		-- text_bg = "Texture/3DMapSystem/HOD_Selected.png; 0 0 24 24: 11 11 11 11", -- some background
		text_bg = "",
		default_font = "System;14;bold",
		-- text color
		text_color = "0 160 0",
		-- whether there is text shadow
		use_shadow = true,
		-- any text scaling
		scaling = 1.05,
	
		-- Theame brighter: this is brighter as suggested by artist
		--default_font = "System;13;bold",
		--use_shadow = true,
		--scaling = 1.3,
	
		spacing = 2,
		height = 22,
		height_offset = -5,
	};
	
	local att = ParaScene.GetAttributeObject();
	att:SetField("HeadOn3DScalingEnabled", true);
	att:SetField("HeadOnUseGlobal3DScaling", true);
	att:SetField("HeadOnNearZoomDist", 15);
	att:SetField("HeadOnFarZoomDist", 70);
	att:SetField("HeadOnMinUIScaling", 0.5);
	att:SetField("HeadOnMaxUIScaling", 1);
	att:SetField("HeadOnAlphaFadePercentage", 0.3);

	HeadonDisplay.InitHeadOnTemplates(true);

	
	-- now default colors for player and OPC
	NPL.load("(gl)script/apps/Aries/Player/main.lua");
	local headon_text_color = "250 186 254"; -- "3 142 52";
	MyCompany.Aries.Player.HeadOnDisplayColor = headon_text_color;
	MyCompany.Aries.Player.HeadOnDisplayColor_TownChiefRodd = "159 0 45";
	MyCompany.Aries.Player.HeadOnDisplayColor_Friend = "102 204 255"; --"255 121 85"; -- "64 249 66";
	MyCompany.Aries.Player.HeadOnDisplayColor_Ally = "64 249 66";
	MyCompany.Aries.Player.HeadOnDisplayColor_Opponent = "255 64 64";
	MyCompany.Aries.Player.FamilyDisplayColor = "255 240 0";

	NPL.load("(gl)script/apps/GameServer/GSL_agent.lua");
	Map3DSystem.GSL.agent.SetDefaultAttribute("headon_color", headon_text_color);
	NPL.load("(gl)script/apps/Aries/Player/OPC.lua");
	Map3DSystem.GSL.agent.SetDefaultAttribute("on_avatar_created", MyCompany.Aries.OPC.on_avatar_created);
	NPL.load("(gl)script/apps/Aries/Desktop/AriesDesktop.lua");
	Map3DSystem.GSL.agent.SetDefaultAttribute("on_receive_chat_msg", MyCompany.Aries.Desktop.OnReceiveGSLChatMsg);
	Map3DSystem.GSL.agent.SetDefaultAttribute("IsAriesAgent", true);
	
	--local NPC = commonlib.gettable("MyCompany.Aries.Quest.NPC");
	--NPC.HeadOnDisplayColor = "12 245 5"; 
end