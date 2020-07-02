--[[
Title: load default UI theme for teen version
Author(s): WangTian
Date: 2008/12/2
Desc: load the default theme for the ui objects and common controls
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/DefaultTheme.teen.lua");
MyCompany.Aries.Theme.Default:Load();
------------------------------------------------------------
]]
local pairs = pairs
local ipairs = ipairs
local tostring = tostring
local tonumber = tonumber
local type = type
local string_find = string.find;
local string_format = string.format;
local string_gsub = string.gsub;
local string_lower = string.lower
local string_match = string.match;
local table_getn = table.getn;
local DefaultTheme = commonlib.gettable("MyCompany.Aries.Theme.Default");

-- 0 will use unlit biped selection effect. 1 will use yellow border style. 
DefaultTheme.BipedSelectionEffect = 0;
function DefaultTheme:Load_Theme()
	local theme_path = "config/Aries/Theme/theme_teen_blue.xml";
	local xmlRoot = ParaXML.LuaXML_ParseFile(theme_path);
	NPL.load("(gl)script/ide/XPath.lua");
	local node = commonlib.XPath.selectNode(xmlRoot, "/pe:mcml/pe:div");
	if(not node)then
		return
	end
	local other_attr = {
		"Normal_BG","MouseOver_BG","Pressed_BG",--rich button
		"SelectedMenuItemBG","UnSelectedMenuItemBG","SelectedTextColor","TextColor","ItemSpacing","TextFont",--tab item
	}
	
	-- whether to select server automatically
	System.options.auto_select_server = true;

	--NOTE:忽略margin-left margin-top position
	local function LoadStyle(mcml_node,style)
		if(not mcml_node or not style)then return end
		local style_code = mcml_node.attr.style;
		if(style_code) then
			local name, value;
			for name, value in string.gfind(style_code, "([%w%-]+)%s*:%s*([^;]*)[;]?") do
				name = string_lower(name);
				value = string_gsub(value, "%s*$", "");
				if(name == "height" or name == "left" or name == "top" or name == "width" or name == "font-size" or 
					string_find(name,"^margin") or string_find(name,"^padding")) then
					local _, _, cssvalue = string_find(value, "([%+%-]?%d+)");
					if(cssvalue~=nil) then
						value = tonumber(cssvalue);
					else
						value = nil;
					end
				elseif(string_match(name, "^background[2]?$") or name == "background-image") then
					value = string_gsub(value, "url%((.*)%)", "%1");
					value = string_gsub(value, "#", ";");
				end
				style[name] = value;
			end
		end
		local __,key;
		for __,key in ipairs(other_attr) do
			local value = mcml_node.attr[key];
			if(value and value ~= "")then
				style[key] = value;
			end
		end
		style["margin-left"] = nil;
		style["margin-top"] = nil;
		style["position"] = nil;
	end
	local style_lib = {};
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "//pe:div") do
		local classname = node.attr.classname;
		if(classname and classname ~= "")then
			local style = {};
			style_lib[classname] = style;
			LoadStyle(node,style)
		end
	end
	for node in commonlib.XPath.eachNode(xmlRoot, "//pe:button") do
		local classname = node.attr.classname;
		if(classname and classname ~= "")then
			local style = {};
			style_lib[classname] = style;
			LoadStyle(node,style)
		end
	end
	for node in commonlib.XPath.eachNode(xmlRoot, "//pe:block") do
		local classname = node.attr.classname;
		if(classname and classname ~= "")then
			local style = {};
			style_lib[classname] = style;
			LoadStyle(node,style)
		end
	end
	local pe_css = commonlib.gettable("Map3DSystem.mcml_controls.pe_css");
	if(pe_css.default)then
		local k,v;
		for k,v in pairs(style_lib) do
			pe_css.default[k] = v;
		end
	else
		pe_css.default = style_lib;
	end
end
-- load the default theme or style for the following ui objects and common controls
--		Cursor: default cursor
--		Day Length:
--		Default ui objects: scroll bar, button, text, editbox .etc
--		Font: default font
--		MessageBox: background
--		WindowFrame: frame background and close button
--		World Loader: background, logo, progress bar and text
function DefaultTheme:Load()
	-- ParaUI.SetUseSystemCursor(true);
	local default_cursor = {file = "Texture/Aries/Cursor/default_cursor_teen.tga", hot_x=1,hot_y=1};
	NPL.load("(gl)script/kids/3DMapSystemUI/Desktop/Cursor.lua");
	local Cursor = commonlib.gettable("Map3DSystem.UI.Cursor");
	Cursor.SetDefaultCursor(default_cursor);
	Cursor.ApplyCursor("default");

	-- max user level
	System.options.max_user_level = 70;
	System.options.tradable_bag_family = {0,1,3,23,24,25,26,12,13,14};
	System.options.auction_bag_family = {12, 14, 24,25};

	System.options.haqi_RMB_Currency="金币";
    System.options.haqi_GameCurrency="银币";

	local root_ = ParaUI.GetUIObject("root");
	if(root_.SetCursor) then
		root_:SetCursor(default_cursor.file, default_cursor.hot_x, default_cursor.hot_y);
	else
		root_.cursor = default_cursor.file;
	end
	
	-- use geomipmapload for all teen version. 
	ParaTerrain.GetAttributeObject():SetField("UseGeoMipmapLod",true);

	_guihelper.SetDefaultMsgBoxMCMLTemplate("script/apps/Aries/Desktop/GUIHelper/Aries_DefaultMessageBox.teen.html");
	
	-- NOTE: choose a font carefully for Aquarius
	
	--System.DefaultFontFamily = "Tahoma"; -- Windows default font (Not supporting Thai very well)
	--System.DefaultFontFamily = "helvetica"; -- Macintosh default font
	--System.DefaultFontFamily = "Verdana"; -- famous microsoft font (Recommended)
	--System.DefaultFontFamily = "Georgia"
	System.DefaultFontFamily = "System";
	System.DefaultFontSize = 12;
	System.DefaultFontWeight = "norm";
	
	-- replace all system font with default font, please edit script/config.lua and edit "GUI_font_mapping" attribute. 
	-- ParaAsset.AddFontName("System", System.DefaultFontFamily);

	local fontStr = string.format("%s;%d;%s", 
				System.DefaultFontFamily, 
				System.DefaultFontSize, 
				System.DefaultFontWeight);
	local fontEditerStr = string.format("%s;%d;%s", 
				System.DefaultFontFamily, 
				13, 
				System.DefaultFontWeight);
	
	-- TODO: artist should design the font family, size and bold type combination to utilize different text appearance
	-- SUGGESTION: use font with only alphabetical letter and number(not including Chinese characters) for pure visual(not informitive) text
	System.DefaultFontString = format("%s;%d;norm", System.DefaultFontFamily, System.DefaultFontSize);
	System.DefaultBoldFontString = format("%s;%d;bold", System.DefaultFontFamily, System.DefaultFontSize);
	System.DefaultLargeFontString = format("%s;%d;norm", System.DefaultFontFamily, System.DefaultFontSize+2);
	System.DefaultLargeBoldFontString = format("%s;%d;bold", System.DefaultFontFamily, System.DefaultFontSize+2);
				
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
			texture.texture="Texture/Aries/Common/Teen/chat/chat_edit_32bits.png;3 3 3 3";
			texture=_this:GetTexture("up_left");
			texture.texture="Texture/Aries/Common/Teen/chat/arrow_up_32bits.png";
			texture=_this:GetTexture("down_right");
			texture.texture="Texture/Aries/Common/Teen/chat/arrow_down_32bits.png";
			texture=_this:GetTexture("thumb");
			texture.texture="Texture/Aries/Common/Teen/chat/scrollbar_32bits.png;0 0 16 29";
		end
		_this.fixedthumb = false;
		_this.background = "Texture/Aries/Common/Teen/chat/scrollbar_32bits.png;0 0 16 29:3 3 3 4";
	end
	UpdateScrollBar_(_this);
	
	_this=ParaUI.GetDefaultObject("button");
	_this.font = fontStr;
	--_this.background = "Texture/Aries/Common/ThemeTeen/btn_32bits.png:8 8 8 8";
	--_this.background = "Texture/Aries/Common/ThemeTeen/btn2_32bits.png;0 0 16 24:5 5 5 5";
	_this.background = "Texture/Aries/Common/Teen/control/default_btn_32bits.png;0 0 75 26:10 10 10 10";
	-- _this:SetField("Spacing", 6);
	--_guihelper.SetButtonFontColor(_this, "#88eeeb");
	_guihelper.SetButtonFontColor(_this, "#ffffff");
	--_this:SetField("TextOffsetY", -2);
	

	_this=ParaUI.GetDefaultObject("listbox");
	_this.font = fontStr;
	_this.background = "Texture/Aries/Common/ThemeTeen/dropdown_bg.png:3 3 3 3";
	_guihelper.SetFontColor(_this, "#52dff4");
	UpdateScrollBar_(_this:GetChild("vscrollbar"));

	_this=ParaUI.GetDefaultObject("container");
	_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/container_bg.png: 4 4 4 4";
	UpdateScrollBar_(_this:GetChild("vscrollbar"));

	_this=ParaUI.GetDefaultObject("editbox");
	_this.font = fontEditerStr;
	_this.background = "Texture/Aries/Common/ThemeTeen/editbox_32bits.png;0 0 16 22: 7 7 7 7";
	_this.spacing = 2;
	_this:GetAttributeObject():SetField("CaretColor", _guihelper.ColorStr_TO_DWORD("#ff52dff4"));
	_guihelper.SetFontColor(_this, "#52dff4");
	
	
	_this=ParaUI.GetDefaultObject("imeeditbox");
	_this.font = fontEditerStr;
	_this.background = "Texture/Aries/Common/ThemeTeen/editbox_32bits.png;0 0 16 22: 7 7 7 7";
	_this:GetAttributeObject():SetField("CaretColor", _guihelper.ColorStr_TO_DWORD("#ff52dff4"));
	_this.spacing = 2;
	_font = _this:GetFont(4); -- "candidate_text"
	_font.font = fontStr;
	_font = _this:GetFont(6); -- "composition_text"
	_font.font = fontStr;
	_guihelper.SetFontColor(_this, "#52dff4");

	_this=ParaUI.GetDefaultObject("text");
	_this.font = fontStr;
	
	_this=ParaUI.GetDefaultObject("slider");
	_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/slider_background_16.png: 4 8 4 7"; 
	_this.button = "Texture/3DMapSystem/common/ThemeLightBlue/slider_button_16.png";
	
	-- 2d tooltip
	_this=ParaUI.GetDefaultObject("tooltip");
	_this.background = "Texture/Aries/Common/ThemeTeen/tooltip_bg_32bits.png:2 2 2 2"; 
	-- _this.colormask = "255 255 255 204";
	_this:SetField("Spacing", 4);
	_guihelper.SetFontColor(_this, "#9df9fd");

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
	local pe_editor = commonlib.gettable("Map3DSystem.mcml_controls.pe_editor");
	pe_editor.default_button_offset_y = -2;

	local pe_editor_radio = commonlib.gettable("Map3DSystem.mcml_controls.pe_editor_radio");
	pe_editor_radio.checked_bg = "Texture/Aries/Common/ThemeTeen/radio_selected_32bits.png";
	pe_editor_radio.unchecked_bg = "Texture/Aries/Common/ThemeTeen/radio_32bits.png";
	pe_editor_radio.iconSize = 16;

	local pe_editor_checkbox = commonlib.gettable("Map3DSystem.mcml_controls.pe_editor_checkbox");
	pe_editor_checkbox.checked_bg = "Texture/Aries/Common/ThemeTeen/checkbox_32bits.png";
	pe_editor_checkbox.unchecked_bg = "Texture/Aries/Common/ThemeTeen/uncheckbox_32bits.png";
	pe_editor_checkbox.iconSize = 16;

	local pe_select = commonlib.gettable("Map3DSystem.mcml_controls.pe_select");
	pe_select.dropdownBtn_bg = "Texture/Aries/Common/ThemeTeen/dropdown_btn_32bits.png";
	pe_select.editbox_bg = "";
	pe_select.container_bg = "Texture/Aries/Common/ThemeTeen/editbox_32bits.png;0 0 16 22: 7 7 7 7";
	pe_select.listbox_bg = "Texture/Aries/Common/ThemeTeen/editbox_32bits.png;0 0 16 22: 7 7 7 7";
	pe_select.dropdownbutton_width = 16;
	pe_select.dropdownbutton_height = 16;

	local pe_aries_map = commonlib.gettable("MyCompany.Aries.mcml_controls.pe_aries_map");
	pe_aries_map.default_player_icon = "Texture/Aries/WorldMaps/common/maparrow_32bits.png"
	pe_aries_map.default_camera_icon = "Texture/Aries/WorldMaps/common/camera_arrow.png"

	System.mcml_controls.pe_progressbar.Default_blockimage = "Texture/Aries/Common/ThemeTeen/progress_bar_32bits.png;0 0 16 10: 7 4 7 4"
	System.mcml_controls.pe_progressbar.Default_background = "Texture/Aries/Common/ThemeTeen/progress_bar_bg_32bits.png: 7 7 7 7"
	System.mcml_controls.pe_progressbar.Default_height = 16;

	--local pe_html_css = commonlib.gettable("Map3DSystem.mcml_controls.pe_html.css");
	--pe_html_css["pe:tabs"] = {
		--["SelectedMenuItemBG"]="Texture/Aries/Common/ThemeTeen/tab_btn_on_32bits.png;0 0 53 20:15 8 15 8",
		--["UnSelectedMenuItemBG"]="Texture/Aries/Common/ThemeTeen/tab_btn_off_32bits.png;0 0 53 20:15 8 15 8",
		--["SelectedTextColor"]="#52dff4",
		--["TextColor"]="#52dff4",
		--["ItemSpacing"]="0",
		--["TextFont"]="System;12;norm",
		--["margin-left"] = 10, 
		--["padding-top"] = 28, 
	--};
	--pe_html_css["pe:tab-item"] = {
		--["width"] = 60,
	--};
	NPL.load("(gl)script/ide/SliderBar.lua");
	CommonCtrl.SliderBar.background = "Texture/Aries/Common/ThemeTeen/sliderbar_bg.png:2 2 2 2";
	CommonCtrl.SliderBar.button_bg = "Texture/Aries/Common/ThemeTeen/sliderbar_btn_32bits.png;0 0 23 16";
	CommonCtrl.SliderBar.button_width = 23;
	CommonCtrl.SliderBar.button_height = 16;
	CommonCtrl.SliderBar.background_margin_top = 6;
	CommonCtrl.SliderBar.background_margin_bottom = 6;

	local pe_css = commonlib.gettable("Map3DSystem.mcml_controls.pe_css");

	-- local high_light_btn_bg = "Texture/Aries/Common/ThemeTeen/btn2_highlight_32bits.png;0 0 16 24:5 5 5 5";
	local high_light_btn_bg = "Texture/Aries/Common/ThemeTeen/btn3_highlight_32bits.png;0 0 32 24:11 10 11 8";
	local high_light_btn_bg = "Texture/Aries/Common/Teen/control/highlight_btn_32bits.png;0 0 75 26:10 10 10 10";
	-- local high_light_btn_color = "#98fffc";
	--local high_light_btn_color = "#88eeeb";
	local high_light_btn_color = "#ffffff";

	pe_css.default = {
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
		["expbar"] = {
			["background"] = "Texture/Aries/Login/Login/teen/loading_gray_32bits.png:7 7 8 8",
			["blockimage"] = "Texture/Aries/Login/Login/teen/loading_green_32bits.png:7 7 8 8",
			["height"] = 20,
		},
		--[[
			textbox style.
			["small_textbox"] for 80*18 sized textbox
		--]]
		["small_textbox"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/textfield_bg_32bits.png;0 0 16 22:7 7 7 7",
			["color"] = "#52dff4",
			["font-size"] = 12,
			["height"] = 18,
			["width"] = 80,
		},
		["tooltip"] = {
			["color"] = "#9df9fd", -- "#52dff4",
			["font-size"] = 12,
			["padding"] = 8,
			["background"] = "Texture/Aries/Common/ThemeTeen/tooltip_bg_32bits.png:2 2 2 2",
		},
		["tooltip_text_highlight"] = {
			["color"] = "#ccee00",
		},
		["bordertext"] = {
			["shadow-quality"] = 8,
			["shadow-color"] = "#2a2a2e27",
			["text-shadow"] = "true",
			["text-offset-y"]=-2,
		},
		["autoborder"] = {
			["shadow-quality"] = 8,
			["text-shadow"] = "true",
			["text-offset-y"]=-2,
		},
		["bordertext linkbutton2"] = {
			["shadow-quality"] = 8,
			["shadow-color"] = "#2a2a2e27",
			["text-shadow"] = "true",
			["text-offset-y"]=-2,
			["background"] = "",
			["background2"] = "Texture/Aries/Common/underline_white_32bits.png:3 3 3 3",
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
		["container"] = {
			["background"] = "Texture/3DMapSystem/common/ThemeLightBlue/container_bg.png: 4 4 4 4",
		},
		--[[
			button style.
			["small_button"] for 45*25 sized button
		--]]
		["small_button"] = {
			["background"] = high_light_btn_bg,
			["font-size"] = 12,
			["color"] = high_light_btn_color,
			["height"] = 25,
			["width"] = 45,
		},
		["button_lightgrey"] = {
			-- ["background"] = "Texture/Aries/Common/ThemeKid/button_lightgrey_32bits.png;0 0 32 25:5 5 5 5",
			["background"] = "Texture/Aries/Common/ThemeTeen/button_grey_bg_32bits.png;0 0 16 23:7 8 7 8",
			["font-size"] = 12,
			["color"] = "#c8c8c8",
			["text-offset-y"] = -1,
		},
		["tab_static"] = {
			["background"]="Texture/Aries/Common/Teen/control/tab_btn_selected_32bits.png;0 0 86 23:10 10 10 10",
			["ItemSpacing"]= 2,
			["ButtonWidth"] = 86, 
			["ButtonHeight"] = 23, 
			["color"] = "#ffffff",
			["SelectedTextColor"] = "#ffffff",
			["shadow-quality"] = 8,
			["shadow-color"] = "#2a2a2e27",
			["text-shadow"] = "true",
		},
		["pe:togglebuttons"] = {
			--["SelectedMenuItemBG"]="Texture/Aries/Common/ThemeTeen/tab_btn_on_32bits.png;0 0 63 20:25 8 25 8",
			--["UnSelectedMenuItemBG"]="Texture/Aries/Common/ThemeTeen/tab_btn_off_32bits.png;0 0 53 20:15 8 15 8",
			--["ItemSpacing"]= 5,
			--["ButtonWidth"] = 60, 
			--["ButtonHeight"] = 25, 
			["SelectedMenuItemBG"]="Texture/Aries/Common/Teen/control/tab_btn_selected_32bits.png;0 0 86 23:10 10 10 10",
			["UnSelectedMenuItemBG"]="Texture/Aries/Common/Teen/control/tab_btn_32bits.png;0 0 86 23:10 10 10 10",
			["ItemSpacing"]= 2,
			["ButtonWidth"] = 86, 
			["ButtonHeight"] = 23, 
			["color"] = "#ffffff",
			["SelectedTextColor"] = "#ffffff",
			["shadow-quality"] = 8,
			["shadow-color"] = "#2a2a2e27",
			["text-shadow"] = "true",
		},
		["tabs_blue"] = {
			["background"] = "",
			["SelectedMenuItemBG"]="Texture/Aries/Common/Teen/control/tab_btn_selected_32bits.png;0 0 86 23:10 10 10 10",
			["UnSelectedMenuItemBG"]="Texture/Aries/Common/Teen/control/tab_btn_32bits.png;0 0 86 23:10 10 10 10",
			["SelectedTextColor"]="#ffffff",
			["TextColor"]="#ffffff",
			["ItemSpacing"]="0",
			["TextFont"]="System;12;norm",
			["margin-left"] = 10, 
			["padding-top"] = 23, 
			["color"] = "#ffffff",
			["shadow-quality"] = 8,
			["shadow-color"] = "#2a2a2e27",
			["text-shadow"] = "true",
		},
		
		--tabs
		["default_tabs"] = {
			["background"] = "",
			["SelectedMenuItemBG"]="Texture/Aries/Common/Teen/control/tab_btn_selected_32bits.png;0 0 86 23:10 10 10 10",
			["UnSelectedMenuItemBG"]="Texture/Aries/Common/Teen/control/tab_btn_32bits.png;0 0 86 23:10 10 10 10",
			["SelectedTextColor"]="#ffffff",
			["TextColor"]="#ffffff",
			["ItemSpacing"]="0",
			["TextFont"]="System;12;norm",
			["margin-left"] = 10, 
			["padding-top"] = 28, 
		},
		
		["default_tabs_bottom"] = {
			["background"] = "",
			["SelectedMenuItemBG"]="Texture/Aries/Common/ThemeTeen/tab_btn_on_bottom_32bits.png;0 0 63 20:25 8 25 8",
			["UnSelectedMenuItemBG"]="Texture/Aries/Common/ThemeTeen/tab_btn_off_bottom_32bits.png;0 0 53 20:15 8 15 8",
			["SelectedTextColor"]="#99ffff",
			["TextColor"]="#99ffff",
			["ItemSpacing"]="0",
			["TextFont"]="System;12;norm",
			["margin-left"] = 10, 
			["padding-top"] = 28, 
		},

		["default_tab_item"] = {
			["background"] = "",
			["width"] = 60,
		},
		--shop tabs
		["shoptabs"] = {
			["background"] = "",
			["SelectedMenuItemBG"]="Texture/Aries/Common/ThemeTeen/tab_btn_on_32bits.png;0 0 63 20:25 8 25 8",
			["UnSelectedMenuItemBG"]="Texture/Aries/Common/ThemeTeen/tab_btn_off_32bits.png;0 0 53 20:15 8 15 8",
			["SelectedTextColor"]="#99ffff",
			["TextColor"]="#99ffff",
			["ItemSpacing"]="2",
			["TextFont"]="System;12;norm",
			["margin-left"] = 5, 
			["padding-top"] = 28, 
		},
		--skill tabs
		["skill_tabs"] = {
			["background"] = "",
			["SelectedMenuItemBG"]="Texture/Aries/Common/ThemeTeen/skill_tab_on_32bits.png;0 0 183 32: 5 5 3 3",
			["UnSelectedMenuItemBG"]="Texture/Aries/Common/ThemeTeen/skill_tab_off_32bits.png;0 0 2 32",
			["SelectedTextColor"]="#99ffff",
			["TextColor"]="#99ffff",
			["ItemSpacing"]="0",
			["TextFont"]="System;12;norm",
			["margin-left"] = 0, 
			["padding-top"] = 34,
			["shadow-quality"] = 8,
			["shadow-color"] = "#802a2e27",
			["text-shadow"] = "true",			 
		},

		--skill tabs
		["skill_subtabs"] = {
			["background"] = "",
			["SelectedMenuItemBG"] = "Texture/Aries/Common/ThemeTeen/subtab_on_32bits.png;0 0 54 25:2 2 2 2",
			["UnSelectedMenuItemBG"]="",
			["SelectedTextColor"]="#ffff00",
			["TextColor"]="#99ffff",
			["ItemSpacing"]="0",
			["TextFont"]="System;12;norm",
			["margin-left"] = 10, 
			["padding-top"] = 22, 
		},

		["rename_div"] = {			
			["background"] = "Texture/Aries/Common/Teen/control/rename_bg_32bits.png;0 0 256 23: 62 6 46 1",
			["color"] = "#ffffff",
			["shadow-quality"] = 12,
			["shadow-color"] = "#802a2e27",
			["text-shadow"] = "true",
			["text-offset-y"]=-2;
			["font-size"]= 14,
		},
		--buttons
		["default_button"] = {
			["background"] = high_light_btn_bg,
			["font-size"] = 12,
			["color"] = high_light_btn_color,
			["width"] = 85,
			["height"] = 25,
		},

		["lightgreen_btn_5530"] = {
			--[[["Normal_BG"] = "texture/aries/common/themeteen/diag/bg_lightgreen_32bits.png;0 0 32 29:10 10 10 10",
			["MouseOver_BG"] = "texture/aries/common/themeteen/diag/bg_hllightgreen_32bits.png;0 0 32 29:10 10 10 10",
			["Pressed_BG"] = "texture/aries/common/themeteen/diag/bg_hllightgreen_32bits.png;0 0 32 29:10 10 10 10",]]
			["background"] = "texture/aries/common/themeteen/diag/bg_hllightgreen_32bits.png;0 0 32 29:10 10 10 10",
			["font-size"] = 14,
			["font-weight"] = "bold",
			["color"] = "#e9fdc9",
			["width"] = 55,
			["height"] = 30,
		},
		
		["oriange_btn_5530"] = {
			--[[["Normal_BG"] = "texture/aries/common/themeteen/diag/bg_oriange_32bits.png;0 0 32 29:10 10 10 10",
			["MouseOver_BG"] = "texture/aries/common/themeteen/diag/bg_hloriange_32bits.png;0 0 32 29:10 10 10 10",
			["Pressed_BG"] = "texture/aries/common/themeteen/diag/bg_hloriange_32bits.png;0 0 32 29:10 10 10 10",]]
			["background"] = "texture/aries/common/themeteen/diag/bg_hloriange_32bits.png;0 0 32 29:10 10 10 10",
			["font-size"] = 14,
			["font-weight"] = "bold",
			["color"] = "#fde6b0",
			["width"] = 55,
			["height"] = 30,

		},
	
		["deepbluebutton"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/others/deepblue_bg_32bits.png;0 0 32 25:12 10 12 10",
			["font-size"] = 12,
			["color"] = "#7ac8ef",
		},

		["orangebutton"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/others/button_orange_bg_32bits.png;0 0 32 19:7 8 7 8",
			["font-size"] = 12,
			["color"] = "#7ac8ef",
		},

		["greybutton"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/button_grey_bg_32bits.png;0 0 16 23:7 8 7 8",
			["font-size"] = 12,
			["color"] = "#c8c8c8",
			["text-offset-y"] = -1,
		},
		["greyroundbtn"] = {
			["background"] = "Texture/Aries/Login/Login/teen/loading_gray_32bits.png:7 7 8 8",
			["text-offset-y"] = -1,
		},
		["helptip"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/rookiehelp_bg_32bits.png: 6 6 6 6",
		},
		["highlightbutton"] = {
			["background"] = high_light_btn_bg,
			["font-size"] = 12,
			["color"] = high_light_btn_color,
		},
		["button"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/btn2_32bits.png;0 0 16 24:5 5 5 5",
			["font-size"] = 12,
			["color"] = high_light_btn_color,
		},
		["defaultbutton"] = {
			["background"] = high_light_btn_bg,
			["font-size"] = 12,
			["color"] = high_light_btn_color,
			["shadow-quality"] = 8,
			["shadow-color"] = "#802a2e27",
			["text-shadow"] = "true",
			["text-offset-y"] = -2,
		},
		["defaultbutton_unselected"] = {
			["Normal_BG"] = "",
			["MouseOver_BG"] = "Texture/Aries/Common/ThemeTeen/btn_hl_32bits.png;8 8 8 8",
			["Pressed_BG"] = "Texture/Aries/Common/ThemeTeen/btn_hl_32bits.png;8 8 8 8",
			["background"] = "",
			["color"] = "#52dff4",
			["font-size"] = 12,
			["height"] = 22,
		},
		["yellowbutton"] = {
			["background"] = "Texture/Aries/Common/Button_Trial_HL_32bits.png;0 0 16 20: 2 2 2 2",
			["font-size"] = 12,
			["color"] = "#000000",
		},
		["numbgbutton"] = {
			["background"] = "Texture/Aries/Common/Teen/control/number_bg_32bits.png;0 0 23 24",
			["font-size"] = 12,
			["color"] = "#000000",
		},
		["highlightboldbutton"] = {
			["background"] = high_light_btn_bg,
			["font-size"] = 14,
			["color"] = high_light_btn_color,
			--["font-weight"] = "bold",
			["shadow-quality"] = 8,
			["shadow-color"] = "#802a2e27",
			["text-shadow"] = "true",
			["text-offset-y"] = -2,
		},
		["linkbutton"] = {
			["color"] = "#ffff00",
			["background-color"] = "#ffff00",
			["background"] = "Texture/Aries/Common/underline_white_32bits.png:3 3 3 3",
		},
		["linkbutton_yellow"] = {
			["color"] = "#f0f000",
			["background-color"] = "#f0f000",
			["background"] = "Texture/Aries/Common/underline_white_32bits.png:3 3 3 3",
		},
		["linkbutton2"] = {
			["color"] = "#ffff00",
			["background-color"] = "#ffff00",
			["background"] = "",
			["background2"] = "Texture/Aries/Common/underline_white_32bits.png:3 3 3 3",
		},
		["titlebutton"] = {
			["background"] = "",
			["color"] = "#52dff4",
			["font-size"] = 12,
			["height"] = 25,
		},
		["labelbutton"] = {
			["background"] = "",
			["color"] = "#52dff4",
			["font-size"] = 12,
			["height"] = 25,
		},
		["textfieldbutton"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/textfield_bg_32bits.png;0 0 16 16:7 7 7 7",
			["color"] = "#52dff4",
			["font-size"] = 12,
			["height"] = 25,
		},
		["closebutton"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/close_32bits.png;0 0 42 20",
			["width"] = 42,
			["height"] = 20,
			["margin-top"] = 2,
		},
		["helpbutton"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/helpico_32bits.png;0 0 25 19",
			["width"] = 25,
			["height"] = 19,
			["margin-top"] = 2,
		},

		["gift_30m_button_cn"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/ElfGift/30min_btn_32bits.png;0 0 75 36",
			["width"] = 75,
			["height"] = 36,
			["margin-top"] = 0,
		},
		["gift_60m_button_cn"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/ElfGift/60min_btn_32bits.png;0 0 75 36",
			["width"] = 75,
			["height"] = 36,
			["margin-top"] = 0,
		},
		["gift_90m_button_cn"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/ElfGift/90min_btn_32bits.png;0 0 75 36",
			["width"] = 75,
			["height"] = 36,
			["margin-top"] = 0,
		},
		["gift_120m_button_cn"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/ElfGift/120min_btn_32bits.png;0 0 75 36",
			["width"] = 75,
			["height"] = 36,
			["margin-top"] = 0,
		},

		["gift_button_cn"] = {
			--["background"] = "Texture/Aries/Common/ThemeTeen/ElfGift/getgift_btn_32bits.png;0 0 64 26",
			["background"] = "Texture/Aries/Common/ThemeTeen/newBtn_32bits.png;0 0 75 26: 3 3 3 3",
			["width"] = 75,
			["height"] = 26,
			["margin-top"] = 3,
			["color"] = "#ffffff",
			["shadow-quality"] = 8,
			["shadow-color"] = "#802a2e27",
			["text-shadow"] = "true",
			["text-offset-y"]=-2;
			--["font-weight"] = "bold",
			["font-size"]= 14,
		},

		["gift_vipget_button_cn"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/ElfGift/vip_btn_32bits.png;0 0 75 26",
			["width"] = 75,
			["height"] = 26,
			["margin-top"] = 0,
		},
		["gift_not_button_cn"] = {
			--["background"] = "Texture/Aries/Common/ThemeTeen/ElfGift/novip_btn_32bits.png;0 0 75 26",
			["background"] = "Texture/Aries/Common/ThemeTeen/newBtn_gray_32bits.png;0 0 75 26",
			["width"] = 75,
			["height"] = 26,
			["margin-top"] = 3,
			["color"] = "#ffffff",
			["shadow-quality"] = 8,
			["shadow-color"] = "#802a2e27",
			["text-shadow"] = "true",
			["text-offset-y"]=-2;
			["font-size"]= 14,
		},
		["gift_got_button_cn"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/ElfGift/gotgift_btn_32bits.png;0 0 64 26",
			["width"] = 64,
			["height"] = 26,
			["margin-top"] = 0,
		},

		["gold_button_cn"] = {			
			["background"] = "Texture/Aries/Common/ThemeTeen/goldBtn_32bits.png;0 0 75 26",
			["width"] = 75,
			["height"] = 26,
			["margin-top"] = 3,
			["color"] = "#ffffff",
			["shadow-quality"] = 8,
			["shadow-color"] = "#802a2e27",
			["text-shadow"] = "true",
			["text-offset-y"]=-2;
			["font-size"]= 14,
		},

		["listbutton_selected"] = {
			["Normal_BG"] = "Texture/Aries/Common/Teen/control/gridview_selected_32bits.png;0 0 194 20",
			["MouseOver_BG"] = "Texture/Aries/Common/Teen/control/gridview_selected_32bits.png;0 0 194 20",
			["Pressed_BG"] = "Texture/Aries/Common/Teen/control/gridview_selected_32bits.png;0 0 194 20",
			["background"] = "",
			["color"] = "#ffffff",
			["font-size"] = 12,
			["height"] = 20,
		},
		["listbutton_unselected"] = {
			["Normal_BG"] = "",
			["MouseOver_BG"] = "Texture/Aries/Common/Teen/control/gridview_selected_32bits.png;0 0 194 20",
			["Pressed_BG"] = "Texture/Aries/Common/Teen/control/gridview_selected_32bits.png;0 0 194 20",
			["background"] = "",
			["color"] = "#ffffff",
			["font-size"] = 12,
			["height"] = 20,
		},
		["menu"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/popupmenu_bg_32bits.png:5 5 7 7",
			["padding"] = 5,
			["padding-right"] = 7,
			["padding-bottom"] = 7,
		},
		["menuitem"] = {
			["background"] = "",
			["background2"] = "Texture/Aries/Common/Teen/control/gridview_selected_32bits.png;0 0 194 20",
		},
		["menuitem_bg"] = {
			--["background"] = "Texture/Aries/Common/ThemeTeen/list_mouse_default_bg_32bits.png",
			["background"] = "Texture/Aries/Common/Teen/control/border_bg7_32bits.png;0 0 8 26:3 10 3 10",
		},
		["preference_selected"] = {
			["Normal_BG"] = "Texture/Aries/Common/ThemeTeen/icon_border_32bits.png",
			["MouseOver_BG"] = "Texture/Aries/Common/ThemeTeen/icon_border_32bits.png",
			["Pressed_BG"] = "Texture/Aries/Common/ThemeTeen/icon_border_32bits.png",
			["background"] = "",
			["height"] = 48,
			["width"] = 48,
		},
		["preference_unselected"] = {
			["Normal_BG"] = "",
			["MouseOver_BG"] = "Texture/Aries/Common/ThemeTeen/icon_border2_32bits.png",
			["Pressed_BG"] = "Texture/Aries/Common/ThemeTeen/icon_border_32bits.png",
			["background"] = "",
			["height"] = 48,
			["width"] = 48,
		},
		["questbutton_selected"] = {
			["Normal_BG"] = "",
			["MouseOver_BG"] = "Texture/Aries/Common/ThemeTeen/list_mouse_selected_bg_32bits.png",
			["Pressed_BG"] = "Texture/Aries/Common/ThemeTeen/list_mouse_default_bg_32bits.png",
			["background"] = "",
			["color"] = "#52dff4",
			["font-size"] = 12,
			["height"] = 22,
		},
		["list_color"] = {
			["color"] = "#ffffff",
		},
		["div_selected"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/list_mouse_over_bg_32bits.png",
		},
		["checkboxbutton_checked"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/checkbox_32bits.png",
			["width"] = 16,
			["height"] = 16,
		},
		["checkboxbutton_unchecked"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/uncheckbox_32bits.png",
			["width"] = 16,
			["height"] = 16,
		},
		["change_name_button"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/others/changename_32bits.png",
			["font-size"] = 12,
			["width"] = 16,
			["height"] = 16,
		},
		["save_name_button"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/others/savename_32bits.png",
			["font-size"] = 12,
			["width"] = 16,
			["height"] = 16,
		},
		["blue_line"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/others/blue_line_32bits.png",
		},
		["black_line"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/others/black_line_32bits.png",
		},
		["title_line"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/others/title_line_32bits.png",
		},
		["vertical_line"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/others/vertical_line_32bits.png",
			["width"] = 1,
			["height"] = 32,
		},
		["header"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/tab_btn_on_32bits.png;0 0 63 20:25 8 25 8",
			["font-size"] = 12,
			["text-align"] = "center",
			["padding-left"] = 4,
			["padding-top"] = 2,
			["width"] = 63,
			["height"] = 25,
		},
		["tab_selected"] = {
			["background"] = "Texture/Aries/Common/Teen/control/tab_btn_selected_32bits.png;0 0 86 23:10 10 10 10",
		},
		["tab_unselected"] = {
			["background"] = "Texture/Aries/Common/Teen/control/tab_btn_32bits.png;0 0 86 23:10 10 10 10",
		},
		--treeview
		["defaulttreeview"] = {
			["background"] = "",
			["ItemOpenBG"] = "Texture/Aries/Common/ThemeTeen/can_close_32bits.png;0 0 14 14",
			["ItemCloseBG"] = "Texture/Aries/Common/ThemeTeen/can_open_32bits.png;0 0 14 14",
			["RememberScrollPos"] = true,
			["ItemToggleSize"] = 18,
			["DefaultNodeHeight"] = 22,
		},
		--gridview
		["pagerleft"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/arrow_left_32bits.png;0 0 23 25",
			["width"] = 23,
			["height"] = 25,
			["zorder"] = 2,
			["animstyle"] = 23,
		},
		["pagerright"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/arrow_right_32bits.png;0 0 23 25",
			["width"] = 23,
			["height"] = 25,
			["zorder"] = 2,
			["animstyle"] = 23,
			["margin-left"] = -2,
		},
		["pagertext"] = {
			["background"] = "",
			["width"] = 50,
			["height"] = 25,
			["color"] = "#52dff4",
			["font-size"] = 12,
			["margin"] = 4,
			["margin-top"] = 3,
			["text-align"] = "center",
		},
		--["pagerbuttonleft"] = {
			--["background"] = "Texture/Aries/Common/ThemeTeen/btn_32bits.png:8 8 8 8",
			--["width"] = 60,
			--["height"] = 25,
			--["zorder"] = 2,
		--},
		--["pagerbuttonright"] = {
			--["background"] = "Texture/Aries/Common/ThemeTeen/btn_32bits.png:8 8 8 8",
			--["width"] = 60,
			--["height"] = 25,
			--["zorder"] = 2,
		--},

		["pagerbuttonleft"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/btn2_32bits.png;0 0 16 24:5 5 5 5",
			["width"] = 60,
			["height"] = 25,
			["zorder"] = 2,
		},
		["pagerbuttonright"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/btn2_32bits.png;0 0 16 24:5 5 5 5",
			["width"] = 60,
			["height"] = 25,
			["zorder"] = 2,
		},

		["pagerbuttontext"] = {
			["background"] = "",
			["width"] = 50,
			["height"] = 25,
			["color"] = "#99ffff",
			["font-size"] = 12,
			["margin"] = 4,
			["margin-top"] = 2,
			["text-align"] = "center",
		},
		-- containers
		["window"]={
			["background"] = "Texture/Aries/Common/Teen/control/window_none_title_icon_32bits.png;0 0 256 164:80 50 120 50",
			["color"] = "#52dff4",
			--["padding-left"] = 5, 
			--["padding-right"] = 5, 
			--["padding-bottom"] = 6, 
		},
		["elfwindow"]={
			["background"] = "Texture/Aries/Common/ThemeTeen/ElfGift/elfwin_bg_32bits.png;0 0 512 128:110 72 134 11",
			["color"] = "#52dff4",
		},
		["blockpane"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/ElfGift/blockpane_bg_32bits.png:12 12 12 12",
			["color"] = "#74f9df",
			["font-size"] = 12,
		},
		["textpane"] = {
			--["background"] = "Texture/Aries/Common/ThemeTeen/others/textpane_bg_32bits.png:10 10 10 10",
			--["color"] = "#74f9df",
			["background"] = "",
			["color"] = "#ffffff",
			["font-size"] = 12,
		},
		["panel_window"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/panel_wnd_bg.png:7 7 7 7",
			["color"] = "#52dff4",
			["font-size"] = 12,
		},
		["titletext"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/wnd_titlebar_bg_32bits.png:31 16 31 16",
			["color"] = "#98fffc",
			["font-size"] = 14,
			["padding-left"] = "32",
			["padding-right"] = "32",
			["padding-top"] = "10",
			["height"] = 32,
		},
		["pane"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/pane_bg_32bits.png:7 7 7 7",
			["color"] = "#52dff4",
			["font-size"] = 12,
		},
		["pane_grey"] = {
			["background"] = "Texture/Aries/Common/Teen/control/big_window_bg_32bits.png:7 7 7 7",
			["color"] = "#52dff4",
			["font-size"] = 12,
		},
		["panel_buttonbg"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/btn_32bits.png:8 8 8 8",
			["color"] = "#52dff4",
			["font-size"] = 12,
		},
		["titlebar"] = {
			["height"] = 26,
			["margin-top"] = 4, 
		},
		["closewindow"] = {
			["background"] = "Texture/Aries/Common/Teen/control/close_32bits.png;0 0 20 20",
			["width"] = 20,
			["height"] = 20,
			["margin-right"] = 5,
			["align"] = "right",
			["position"] = "relative",
		},
		["closewindow_lite_tip"] = {
			["width"] = 32,
			["height"] = 24,
			["margin-top"] = -28,
			["margin-right"] = -5,
			["align"] = "right",
			["position"] = "relative",
		},
		["closewindow_tip"] = {
			["width"] = 32,
			["height"] = 24,
			["margin-top"] = 2,
			["margin-right"] = 0,
			["align"] = "right",
			["position"] = "relative",
		},
		["clientarea"] = {
			["color"] = "#52dff4",
			["font-size"] = 12,
			["margin-left"] = 10,
			["margin-right"] = 10,
			["margin-top"] = 3,
			["margin-bottom"] = 5,
		},
		["default"] = {
			["color"] = "#52dff4",
		},
		["subpane"] = {
			["background"] = "Texture/Aries/Common/Teen/control/border_bg1_32bits.png:7 7 7 7",
			["color"] = "#52dff4",
		},
		["grouppanel"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/grouppanel_bg_32bits.png:8 8 8 8",
			["color"] = "#52dff4",
			["font-size"] = 12,
		},
		["vipbar"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/ElfGift/vipbg_32bits.png:73 20 26 30",
			["color"] = "#52dff4",
			["font-size"] = 12,
		},

		["labeltitle"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/label_title_bg_32bits.png:31 16 31 16",
			["padding-left"] = "24",
			["padding-right"] = "24",
			["padding-top"] = "8",
			["color"] = "#98fffc",
			["font-size"] = 12,
			["height"] = 32;
		},
		["border"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/pane_border_32bits.png:7 7 7 7",
			["color"] = "#52dff4",
			["font-size"] = 12,
			["margin-left"]  = 5,
			["margin-top"]= 24,
		},
		["border2"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/pane_border_2_32bits.png:7 7 7 7",
			["color"] = "#52dff4",
			["font-size"] = 12,
			["margin-left"]  = 5,
			["margin-top"]= 24,
		},
		["inborder"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/pane_inborder_32bits.png:7 7 7 7",
			["color"] = "#52dff4",
			["font-size"] = 12,
			["margin-left"]  = 5,
		},
		["inborder_gradient"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/pane_inborder_gradient_frm_center_32bits.png;0 0 16 256:7 95 8 160",
			["color"] = "#52dff4",
			["font-size"] = 12,
		},
		["inborder_golden"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/pane_inborder_golden_32bits.png: 5 5 5 5",
			["color"] = "#52dff4",
			["font-size"] = 12,
			["margin-left"]  = 5,
		},
		["block"] = {
			--["background"] = "Texture/Aries/Common/ThemeTeen/block_32bits.png:7 15 7 15",
			["background"] = "Texture/Aries/Common/Teen/control/border_bg6_32bits.png:7 12 7 12",
			["width"] = 36,
			["height"] = 36,
			["margin-left"] = 2,
			["margin-top"] = 2,
			["color"] = "#52dff4",
			["font-size"] = 12,
		},
		["creator_dock_bg"] = {
			["background"] = "Texture/Aries/Creator/dock/dock_bg_32bits.teen.png;0 0 64 42:31 20 31 20",
		},
		["equip_bg"] = {
			["background"] = "Texture/Aries/NewProfile/bg_equip_32bits.png:10 10 10 10",
			["width"] = 48,
			["height"] = 48,
			["font-size"] = 12,
		},
		["static_block"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/block_static_32bits.png:3 10 3 10",
			["width"] = 36,
			["height"] = 36,
			["margin-left"] = 2,
			["margin-top"] = 2,
			["color"] = "#52dff4",
			["font-size"] = 12,
		},
		["static_block_2"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/block_static_2_32bits.png:7 7 7 7",
			["width"] = 36,
			["height"] = 36,
			["margin-left"] = 2,
			["margin-top"] = 2,
			["color"] = "#52dff4",
			["font-size"] = 12,
		},
		["lightblueblock"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/lightblueblock_32bits.png:5 5 5 5",
			["width"] = 36,
			["height"] = 36,
			["margin-left"] = 2,
			["margin-top"] = 2,
			["color"] = "#52dff4",
			["font-size"] = 12,
		},

		["tree_menu"] = {
			["background"] = "Texture/Aries/Common/Teen/control/border_bg3_32bits.png;0 0 8 30:3 3 3 3",
			["font-size"] = 12,
			["color"] = "#4BF4EC",
			["width"] = 85,
			["height"] = 25,
		},

		
		["sub_tree_menu"] = {
			["background"] = "Texture/Aries/Common/Teen/control/border_bg3_32bits.png;0 0 8 30:3 3 3 3",
			["font-size"] = 12,
			["color"] = "#4BF4EC",
			["width"] = 85,
			["height"] = 18,
		},
		["minikeyboard"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/minikeyboard_32bits.png:0 0 32 32",
			["width"] = 32,
			["height"] = 32,
			["margin-left"] = 8,
		},
		--textfield
		["defaulttextfield"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/editbox_32bits.png;0 0 16 22: 7 7 7 7",
			["color"] = "#52dff4",
			["font-size"] = 12,
			["height"] = 25,
			["CaretColor"] = "#ff52dff4",
			["textcolor"] = "#52dff4",

		},
		["defaultcolor"] = {
			["color"] = "#ffffff",
			["font-size"] = 12,
		},
		["highbluecolor"] = {
			["color"] = "#99ffff",
			["font-size"] = 12,
		},
		["yellow_text"] = {
			["color"] = "#ffff00",
			["font-size"] = 12,
		},
		["usernamecolor"] = {
			["color"] = "#02c647",
			["font-size"] = 12,
		},
		["windowtitle"] = {
			["color"] = "#ffffff",
			["text-align"] = "center",
			["height"] = 19,
			["margin-top"] = 2,
			["position"] = "relative",
		},
		["defaultstyle"] = {
			["color"] = "#52dff4",
			["font-size"] = 12,
		},
		["defaultstyle2"] = {
			["color"] = "#98fffc",
			["font-size"] = 14,
		},
		["windowicon"] = {
			["margin-left"] = -11,
			["margin-top"] = -10,
			["padding-left"] = 24,
			["padding-top"] = 2,
			["position"] = "relative",
			["width"] = 128,
			["height"] = 64,
			["background"] = "Texture/Aries/Common/ThemeTeen/wintitle/windowdeco_32bits.png",
		},
		["windowiconlabel"] = {
			["color"] = "#defef9",
			["text-align"] = "center",
			["margin-left"] = 10,
			["margin-top"] = 2,
			["position"] = "relative",
			["font-weight"] = "bold",
		},
		["inborder2"] = {
			["background"] = "Texture/Aries/Common/Teen/control/border_bg7_32bits.png;0 0 8 26:3 10 3 10",
		},
		["windowlabel"] = {
			["color"] = "#ffffff",
			["text-align"] = "center",
			["margin-right"] = 10,
			["margin-top"] = -1,
			["position"] = "relative",
			["font-weight"] = "bold",
			["shadow-quality"] = 8,
			["font-size"] = 14,
			["shadow-color"] = "#802a2e27",
			["text-shadow"] = true,
		},
		["spark_bg"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/combatpet/spark_bg_32bits.png:10 10 10 10",
			["width"] = 36,
			["height"] = 36,
			["color"] = "#52dff4",
			["font-size"] = 12,
		},
		["sharp_line_bg"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/combatpet/sharp_line_bg_32bits.png:7 7 7 7",
			["width"] = 36,
			["height"] = 36,
			["color"] = "#52dff4",
			["font-size"] = 12,
		},
		["deep_title_bg"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/combatpet/deep_title_bg_32bits.png;0 0 16 26:7 7 7 7",
			["width"] = 36,
			["height"] = 36,
			["color"] = "#52dff4",
			["font-size"] = 12,
		},
		["smooth_border_bg"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/combatpet/smooth_border_bg_32bits.png:7 7 7 7",
			["width"] = 36,
			["height"] = 36,
			["color"] = "#52dff4",
			["font-size"] = 12,
		},
		["star"] = {
			["width"] = 16,
			["height"] = 16,
			["background"] = "Texture/Aries/Common/ThemeTeen/shop/star_32bits.png",
		},
		["name"] = {
			["color"] = "#e8de7e",
			--["font-size"] = 14,
		},
		["boldname"] = {
			["color"] = "#e8de7e",
			--["font-size"] = 14,
			["font-weight"] = "bold",
		},
		["reward"] = {
			["color"] = "#ff0000",
			--["font-size"] = 14,
		},
		["guide"] = {
			["color"] = "#00ff00",
			--["font-size"] = 14,
		},
		["place"] = {
			["color"] = "#00ff00",
			--["font-size"] = 14,
		},
		["name12"] = {
			["color"] = "#e8de7e",
			["font-size"] = 12,
		},
		["boldname12"] = {
			["color"] = "#e8de7e",
			["font-size"] = 12,
			["font-weight"] = "bold",
		},
		["reward12"] = {
			["color"] = "#ff0000",
			["font-size"] = 12,
		},
		["guide12"] = {
			["color"] = "#00ff00",
			["font-size"] = 12,
		},
		["place12"] = {
			["color"] = "#00ff00",
			["font-size"] = 12,
		},
		-- html related
		["a"] = {
			["color"] = "#ffff00",
			["padding"] = 1,
			["background-color"] = "#ffff00",
			["background"] = "Texture/Aries/Common/underline_white_32bits.png:3 3 3 3",
		},
		-- input text style
		["pe:editor-text"] = {
			["margin-top"] = 0,
			["margin-bottom"] = 0,
			["lineheight"] = 24,
		},
		["pe:editor-button"] = {
			["margin-top"] = 0,
			["margin-bottom"] = 0,
			["height"] = 24,
		},
		["pe:tabs"] = {
			["background"] = "Texture/Aries/Common/Teen/control/border_bg2_32bits.png:3 3 3 3",
			["background_overdraw"] = 1,
			["SelectedMenuItemBG"]="Texture/Aries/Common/Teen/control/tab_btn_selected_32bits.png;0 0 86 23:10 10 10 10",
			["UnSelectedMenuItemBG"]="Texture/Aries/Common/Teen/control/tab_btn_32bits.png;0 0 86 23:10 10 10 10",
			["SelectedTextColor"]="#ffffff",
			["TextColor"]="#ffffff",
			["TextShadowQuality"]=8,
			["TextShadowColor"]="#2a2a2e27",
			["ItemSpacing"]="0",
			["TextFont"]="System;12;norm",
			["padding-left"] = 5, 
			["padding-top"] = 27, 
		},
		["pe:tab-item"] = {
			-- the tab button height plus some space, such as 20+1
			["padding-top"] = 5, 
		},
		["pe:editor-text"] = {
			["margin-top"] = 0,
			["margin-bottom"] = 2,
			["lineheight"] = 20,
			["textcolor"] = "#52dff4",
		},
		["CraftSlotCharm"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/others/CraftSlotCharm_32bits.png;0 0 47 32",
			["width"] = 64,
			["height"] = 64,
		},
		["stable_bean"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/others/silver_coin_32bits.png",
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
		["invalid_mask"] = {
			["background"] = "Texture/Aries/Desktop/ItemOutline/redmask_cannot_use_32bits.png: 7 7 7 7",
			["width"] = 64,
			["height"] = 64,
		},
		["quest_reward_item_selected"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/tip/tip_highlight_32bits.png:6 6 6 6",
			["width"] = 64,
			["height"] = 64,
		},
		["anchor_tooltip"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/tip/tip_bg_32bits.png;0 0 32 32: 10 10 10 10",
			["color"] = "#98fffc",
			["padding-top"] = 4,
			["padding"] = 8,
			["padding-bottom"] = 10,
		},
		["anchor_tooltip_bg"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/tip/tip_bg_32bits.png;0 0 32 32: 10 10 10 10",
			["color"] = "#98fffc",
			["padding"] = 8,
			["width"] = 150,
			["height"] = 70,
		},
		["anchor_tooltip_downarrow"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/tip/tip_arrow_rightdown_32bits.png",
			["width"] = 32,
			["height"] = 32,
		},
		["tip_arrow_leftdown"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/tip/tip_arrow_leftdown_32bits.png",
			["width"] = 32,
			["height"] = 32,
		},
		["anchor_tooltip_close"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/tip/tip_close_32bits.png;0 0 29 18",
			["width"] = 29,
			["height"] = 18,
		},
		["anchor_tooltip_highlight"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/tip/tip_highlight_32bits.png:6 6 6 6",
			["width"] = 24,
			["height"] = 38,
		},
		["upgrade_btn"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/others/extra_btn_32bits.png",
			["width"] = 16,
			["height"] = 16,
		},
		["animated_btn_overlay"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/animated/btn_anim_32bits_fps10_a012.png",
			["background-color"] = "#ffffffff",
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
		["animated_white_overlay"] = {
			["background"] = "Texture/Aries/Common/ThemeTeen/animated/white/anim_32bits_fps10_a007.png",
		},
	};
	

	NPL.load("(gl)script/ide/ContextMenu.lua");
	CommonCtrl.ContextMenu.DefaultStyle = {
		borderTop = 4,
		borderBottom = 4,
		borderLeft = 4,
		borderRight = 4,
				
		fillLeft = 0,
		fillTop = 0,
		fillWidth = 0,
		fillHeight = 0,
				
		titlecolor = "#03f8ff",
		level1itemcolor = "#03f8ff",
		level2itemcolor = "#03f8ff",
		mouseover_textcolor = "#a8d608", 
				
		iconsize_x = 24,
		iconsize_y = 21,
				
		menu_bg = "Texture/Aries/Common/ThemeTeen/tooltip_bg_32bits.png:2 2 2 2", -- Texture/Aries/Common/ThemeTeen/menu_bg_32bits.png:2 2 1 1",
		shadow_bg = nil,
		separator_bg = "Texture/Aries/Dock/menu_separator_32bits.png", -- : 1 1 1 4
		item_bg = "Texture/Aries/Common/ThemeTeen/others/menu_bg_32bits.png;0 0 2 21",
		expand_bg = "Texture/Aries/Dock/menu_expand_32bits.png; 0 0 34 34",
		expand_bg_mouseover = "Texture/Aries/Dock/menu_expand_mouseover_32bits.png; 0 0 34 34",

		menuitemHeight = 24,
		separatorHeight = 2,
		titleHeight = 24,
				
		titleFont = "System;12;bold";
	};
	CommonCtrl.ContextMenu.DefaultStyleThick = {
		borderTop = 5,
		borderBottom = 5,
		borderLeft = 7,
		borderRight = 7,
				
		fillLeft = 0,
		fillTop = 0,
		fillWidth = 0,
		fillHeight = 0,
				
		titlecolor = "#03f8ff",
		level1itemcolor = "#03f8ff",
		level2itemcolor = "#03f8ff",
		mouseover_textcolor = "#a8d608", 
				
		iconsize_x = 24,
		iconsize_y = 21,
				
		menu_bg = "Texture/Aries/Common/ThemeTeen/tooltip_bg_32bits.png:2 2 2 2", -- "Texture/Aries/Common/ThemeTeen/popupmenu_bg_32bits.png:5 5 7 7",
		shadow_bg = nil,
		separator_bg = "Texture/Aries/Dock/menu_separator_32bits.png", -- : 1 1 1 4
		item_bg = "Texture/Aries/Common/ThemeTeen/others/menu_bg_32bits.png;0 0 2 21",
		expand_bg = "Texture/Aries/Dock/menu_expand_32bits.png; 0 0 34 34",
		expand_bg_mouseover = "Texture/Aries/Dock/menu_expand_mouseover_32bits.png; 0 0 34 34",

		menuitemHeight = 24,
		separatorHeight = 2,
		titleHeight = 24,
				
		titleFont = "System;12;bold";
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

	-- set mount char scaling for teen version. 
	NPL.load("(gl)script/apps/Aries/Pet/main.lua");
	local Pet = commonlib.gettable("MyCompany.Aries.Pet");
	Pet.ResetDefaultScaling(0.8, 1.6105, 1.6105);

	local CamSetting = commonlib.gettable("MyCompany.Aries.mcml_controls.pe_player.CamSetting");
	CamSetting.ElfFemale = {
		LookAt = {0, 2.25, 0},
		EyePos = {3.1121213436127, 0.10053723305464, 9},
	};
	CamSetting.ElfFemaleHead = {
		LookAt = {0, 3.5, 0},
		EyePos = {3.1121213436127, 0.10053723305464, 3.6},
	};
	CamSetting.ElfFemaleFreezed = {
		LookAt = {0, 2.25, 0},
		EyePos = {3.36399102211, 0.35200002789497, 9},
	};

	-- Character customization system 
	self:RestoreDefaultCharacterRegionPaths()
	
	-- for headon display 
	self:LoadHeadDisplayStyle();

	Map3DSystem.App.MiniGames.SwfLoadingBarPage.url="script/apps/Aries/Login/SwfLoadingBarPage.teen.html";

	NPL.load("(gl)script/ide/progressbar.lua");
	CommonCtrl.progressbar.overlay_margin_top = 1;
	CommonCtrl.progressbar.overlay_margin_bottom = 1;
	CommonCtrl.progressbar.overlay_margin_left = 3;
	CommonCtrl.progressbar.overlay_margin_right = 3;

	NPL.load("(gl)script/ide/TooltipHelper.lua");
	local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");
	local default_stack = BroadcastHelper.GetSingletonTipsStack();
	default_stack.background = "Texture/Aries/Common/gradient_white_32bits.png";
	default_stack.background_color = "#1f3243";

	NPL.load("(gl)script/kids/3DMapSystemApp/Assets/AsyncLoaderProgressBar.lua");
	local AsyncLoaderProgressBar = commonlib.gettable("Map3DSystem.App.Assets.AsyncLoaderProgressBar");
	AsyncLoaderProgressBar.alignment = "_lb";
	AsyncLoaderProgressBar.left = 20;
	AsyncLoaderProgressBar.top = -420;
	AsyncLoaderProgressBar.width = 32;
	AsyncLoaderProgressBar.height = 160;

	local loader_bar = AsyncLoaderProgressBar.GetDefaultAssetBar()
	if(loader_bar) then
		loader_bar.image_layout.background = "Texture/Aries/Common/ThemeTeen/AssetLoader_32bits.png";
		loader_bar.text_layout.color = "#52dff4";
		loader_bar.text_layout.top = 62;
		loader_bar:RefreshStyle();
	end
	DefaultTheme:Load_Theme();
end

function DefaultTheme:RestoreDefaultCharacterRegionPaths()
-- set to the teen character path setting
	ParaScene.SetCharacterRegionPath(32, "character/v6/Item/Head/");
	ParaScene.SetCharacterRegionPath(34, "character/v6/Item/Weapon/");
	ParaScene.SetCharacterRegionPath(19, "character/v6/Item/ShirtTexture/");
	ParaScene.SetCharacterRegionPath(20, "character/v6/Item/ShirtTexture/");
	ParaScene.SetCharacterRegionPath(23, "character/v6/Item/FootTexture/");
	ParaScene.SetCharacterRegionPath(38, "character/v6/Item/WingTexture/");
	ParaScene.SetCharacterRegionPath(39, "character/v6/Item/Back/");

	local CharTexSize = 512; -- the recommended size is 256, however 512 is the original size of component textures, 2007.7.7 by LiXizhi
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
	local headon_text_color = "170 255 255"; -- ""; -- "3 142 52";
	MyCompany.Aries.Player.HeadOnDisplayColor = headon_text_color;
	MyCompany.Aries.Player.HeadOnDisplayColor_TownChiefRodd = "159 0 45";
	MyCompany.Aries.Player.HeadOnDisplayColor_Friend = "0 204 187"; -- "0 204 187"; --"255 121 85"; -- "64 249 66";
	MyCompany.Aries.Player.HeadOnDisplayColor_Ally = "64 249 66";
	MyCompany.Aries.Player.HeadOnDisplayColor_Opponent = "255 64 64";
	MyCompany.Aries.Player.FamilyDisplayColor = "255 255 0";

	MyCompany.Aries.Player.HeadOnDisplayColor_MobNormal = "238 3 98";
	MyCompany.Aries.Player.HeadOnDisplayColor_MobElite = "238 3 98"; -- "74 65 254";
	MyCompany.Aries.Player.HeadOnDisplayColor_MobBoss = "238 3 98"; -- "185 65 254";

	NPL.load("(gl)script/apps/GameServer/GSL_agent.lua");
	Map3DSystem.GSL.agent.SetDefaultAttribute("headon_color", headon_text_color);
	NPL.load("(gl)script/apps/Aries/Player/OPC.lua");
	Map3DSystem.GSL.agent.SetDefaultAttribute("on_avatar_created", MyCompany.Aries.OPC.on_avatar_created);
	NPL.load("(gl)script/apps/Aries/Desktop/AriesDesktop.lua");
	Map3DSystem.GSL.agent.SetDefaultAttribute("on_receive_chat_msg", MyCompany.Aries.Desktop.OnReceiveGSLChatMsg);
	Map3DSystem.GSL.agent.SetDefaultAttribute("IsAriesAgent", true);

	NPL.load("(gl)script/ide/headon_speech.lua");
	headon_speech.dialog_bg = "Texture/Aries/HeadOn/head_speak_teen_32bits.png:20 8 41 22";
	headon_speech.padding = 8;
	headon_speech.padding_bottom = 24;
	headon_speech.min_height = 20;
	headon_speech.min_width = 46;
	headon_speech.margin_bottom = 24;
end