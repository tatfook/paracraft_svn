--[[
Title: Sky in main bar for 3D Map system
Author(s): WangTian, LiXizhi
Date: 2007/9/17
Desc: Show the Sky panel in game UI
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Env/Sky.lua");
------------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

local L = CommonCtrl.Locale("KidsUI");

Map3DSystem.UI.Sky.skyboxes = {
	[1] = {name = "skybox1", file = "model/Skybox/Skybox1/Skybox1.x", bg = "Texture/kidui/middle/sky/btn_sky1.png"},
	[2] = {name = "skybox2", file = "model/Skybox/skybox2/skybox2.x", bg = "Texture/kidui/middle/sky/btn_sky2.png"},
	[3] = {name = "skybox3", file = "model/Skybox/Skybox3/Skybox3.x", bg = "Texture/kidui/middle/sky/btn_sky3.png"},
	[4] = {name = "skybox4", file = "model/Skybox/skybox4/skybox4.x", bg = "Texture/kidui/middle/sky/btn_sky4.png"},
	[5] = {name = "skybox5", file = "model/Skybox/Skybox5/Skybox5.x", bg = "Texture/kidui/middle/sky/btn_sky5.png"},
};

-- display the sky panel.
function Map3DSystem.UI.Sky.ShowWnd(_app)
	NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
	local _wnd = _app:FindWindow("SkyWnd") or _app:RegisterWindow("SkyWnd", nil, Map3DSystem.UI.Sky.MSGProc);
	
	local _appName, _wndName, _document, _frame;
	_frame = Map3DSystem.UI.Windows.GetWindowFrame(_wnd.app.name, _wnd.name);
	if(_frame) then
		_appName = _frame.wnd.app.name;
		_wndName = _frame.wnd.name;
	else
		local param = {
			wnd = _wnd,
			text = "天空",
			initialWidth = 400,
			initialHeight = 160,
			alignment = "Bottom",
			ShowUICallback =Map3DSystem.UI.Sky.Show,
		};
		_appName, _wndName = Map3DSystem.UI.Windows.RegisterWindowFrame(param);
	end
	Map3DSystem.UI.Windows.ShowWindow(true, _appName, _wndName);
	
	
	
	
	NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
	local _wnd = _app:FindWindow("SkyWnd") or _app:RegisterWindow("SkyWnd", nil, Map3DSystem.UI.Sky.MSGProc);
	
	local _frame = Map3DSystem.UI.Windows.GetWindowFrame(_wnd.app.name, _wnd.name);
	if(not _frame) then
		_frame = Map3DSystem.UI.Windows.CreateWindowFrame{
			wnd = _wnd,
			text = "天空",
			initialWidth = 400,
			initialHeight = 160,
			alignment = "Bottom",
			ShowUICallback =Map3DSystem.UI.Sky.Show,
		};
	end
	_frame:Show(true);
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
-- @param _parent: parent window inside which the content is displayed. it can be nil.
function Map3DSystem.UI.Sky.Show(bShow, _parent, parentWindow)
	local _this;
	Map3DSystem.UI.Sky.parentWindow = parentWindow;
	
end	

function Map3DSystem.UI.Sky.MSGProc(window, msg)
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		-- Do your code
		--_guihelper.MessageBox("SkyWnd recv MSG WM_CLOSE.\n");
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		-- Do your code
		--_guihelper.MessageBox("SkyWnd recv MSG WM_SIZE.\n");
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		-- Do your code
		--_guihelper.MessageBox("SkyWnd recv MSG WM_HIDE.\n");
		Map3DSystem.UI.Sky.CloseUI();
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		-- Do your code
		--_guihelper.MessageBox("SkyWnd recv MSG WM_SHOW.\n");
		Map3DSystem.UI.Sky.ShowUI();
	elseif(msg.type == Map3DSystem.msg.MAINPANEL_Sky_Show) then
		-- show or hide the sky panel, nil to toggle current setting
		Map3DSystem.UI.Sky.Show(msg.bShow);
	end
end

function Map3DSystem.UI.Sky.InitMessageSystem(app, mainWndName)

	Map3DSystem.UI.Sky.WndObject = app:RegisterWindow(
		"SkyWnd", mainWndName, Map3DSystem.UI.Sky.MSGProc);
	
end

-- show or hide the sky panel, bShow == nil, toggle current setting
function Map3DSystem.UI.Sky.Show(bShow)
	Map3DSystem.UI.MainPanel.ShowPanel(8, bShow);
end

function Map3DSystem.UI.Sky.ShowUI()

	local _panel = ParaUI.GetUIObject("MainBar_panel");
	
	--local _icon = ParaUI.GetUIObject("MainBar_icons_8"); --  the main bar sky icon
	local _icon = Map3DSystem.UI.MainBar.GetItemUIContainer("apps", "Creator.Sky");
	local x, y, width, height = _icon:GetAbsPosition();
	
	Map3DSystem.UI.MainPanel.SendMeMessage(
			{type = Map3DSystem.msg.MAINPANEL_SetPosX,
			posX = x});
	
	if(_panel:IsValid() == true) then
	
		local _sub_panel = _panel:GetChild("_sub_panel_sky");
		if(_sub_panel:IsValid() == false) then
			-- Sky sub panel for the first run
			local _sub_panel = ParaUI.CreateUIObject("container", "_sub_panel_sky", "_lt",
				Map3DSystem.UI.MainPanel.SubPanelOffsetX, Map3DSystem.UI.MainPanel.SubPanelOffsetY, 
				Map3DSystem.UI.MainPanel.SubPanelWidth, Map3DSystem.UI.MainPanel.SubPanelHeight);
			_sub_panel.background = "";
			_panel:AddChild(_sub_panel);
			
			---- test button
			--local _temp = ParaUI.CreateUIObject("button", "testButton", "_lt", 10, 10, 128, 32);
			--_temp.text = "sky";
			--_sub_panel:AddChild(_temp);
			
			
			local left,top = 65, 0;
			_this=ParaUI.CreateUIObject("text","static","_lt",0,top + 10,80,25);
			_sub_panel:AddChild(_this);
			_this.text=L"lighting:";
			
			-- TODO: the reason why create an additional background is the slider background don't support the 
			--		"***.png: * * * * " form background
			_this=ParaUI.CreateUIObject("container","Map3DSystem_s_light_slider_BG","_lt",left-10,top,280,32);
			_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/slider_background.png: 8 14 8 14";
			_this.enable = false;
			_sub_panel:AddChild(_this);
			
			_this=ParaUI.CreateUIObject("slider","Map3DSystem_s_light_slider","_lt",left-10,top,280,32);
			_sub_panel:AddChild(_this);
			_this.background = "";
			_this.button = "Texture/3DMapSystem/common/ThemeLightBlue/slider_button.png";
			_this.value = (ParaScene.GetTimeOfDaySTD()/2+0.5)*100;
			_this.onchange=";Map3DSystem.UI.Sky.OnTimeSliderChanged()";

			top = top + 40;
			btn_width = 32;
			_this=ParaUI.CreateUIObject("text","static","_lt",0,top,120,25);
			_sub_panel:AddChild(_this);
			_this.text=L"sky background:";
			
			local skyboxes = Map3DSystem.UI.Sky.skyboxes;
			
			for i=1, table.getn(skyboxes) do
				local item = skyboxes[i];
				_this=ParaUI.CreateUIObject("button","kidui_s_skybtn"..i,"_lt",left,top,btn_width,btn_width);
				_sub_panel:AddChild(_this);
				_this.background = item.bg;
				_this.animstyle = 12;
				_this.onclick=string.format([[;Map3DSystem.UI.Sky.OnChangeSkybox(%d)]],i);
				left = left+btn_width+5;
			end

			-- sky color
			local left, top = 0, 90;
			width = 70;
			_this=ParaUI.CreateUIObject("text","static","_lt",left, top, width, 25);
			_sub_panel:AddChild(_this);
			_this.text=L"sky color:";
			left=left+width+1;
			
			left = 55;
			local ColorSliderWidth, ColorSliderHeight = 120, 16;
			local _this = ParaUI.CreateUIObject("container", "Map3DSystem_s_skycolor_red_BG","_lt", 
						left, top, ColorSliderWidth, ColorSliderHeight);
			_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/slider_background_16.png: 4 8 4 7";
			_this.enable = false;
			_sub_panel:AddChild(_this);
			_this = ParaUI.CreateUIObject("container", "Map3DSystem_s_skycolor_green_BG","_lt", 
						left, top + 16, ColorSliderWidth, ColorSliderHeight);
			_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/slider_background_16.png: 4 8 4 7";
			_this.enable = false;
			_sub_panel:AddChild(_this);
			_this = ParaUI.CreateUIObject("container", "Map3DSystem_s_skycolor_blue_BG","_lt", 
						left, top + 32, ColorSliderWidth, ColorSliderHeight);
			_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/slider_background_16.png: 4 8 4 7";
			_this.enable = false;
			_sub_panel:AddChild(_this);
			--_this = ParaUI.GetUIObject("Map3DSystem_s_skycolor_green");
			--_this.button = "Texture/3DMapSystem/common/ThemeLightBlue/slider_button_16.png";
			--_this = ParaUI.GetUIObject("Map3DSystem_s_skycolor_blue");
			--_this.button = "Texture/3DMapSystem/common/ThemeLightBlue/slider_button_16.png";
			
			width = 180;
			local ctl = CommonCtrl.CCtrlColorEditor:new {
				name = "Map3DSystem_s_skycolor",
				parent = _sub_panel,
				width = width,
				height = height,
				left = left, top = top, 
				r = 255,g = 255,b = 255,
				onchange = "Map3DSystem.UI.Sky.OnSkyColorChanged();",
			};
			ctl:Show();
			
			local _this = ParaUI.GetUIObject("Map3DSystem_s_skycolor_red");
			_this.button = "Texture/3DMapSystem/common/ThemeLightBlue/slider_button_16.png";
			_this.background = "";
			_this = ParaUI.GetUIObject("Map3DSystem_s_skycolor_green");
			_this.button = "Texture/3DMapSystem/common/ThemeLightBlue/slider_button_16.png";
			_this.background = "";
			_this = ParaUI.GetUIObject("Map3DSystem_s_skycolor_blue");
			_this.button = "Texture/3DMapSystem/common/ThemeLightBlue/slider_button_16.png";
			_this.background = "";
			
			-- fog color
			left = 245;
			_this=ParaUI.CreateUIObject("text","static","_lt",left, top, width, 25);
			_sub_panel:AddChild(_this);
			_this.text=L"fog color:";
			
			left = 300;
			local ColorSliderWidth, ColorSliderHeight = 120, 16;
			local _this = ParaUI.CreateUIObject("container", "Map3DSystem_s_fogcolor_red_BG","_lt", 
						left, top, ColorSliderWidth, ColorSliderHeight);
			_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/slider_background_16.png: 4 8 4 7";
			_this.enable = false;
			_sub_panel:AddChild(_this);
			_this = ParaUI.CreateUIObject("container", "Map3DSystem_s_fogcolor_green_BG","_lt", 
						left, top + 16, ColorSliderWidth, ColorSliderHeight);
			_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/slider_background_16.png: 4 8 4 7";
			_this.enable = false;
			_sub_panel:AddChild(_this);
			_this = ParaUI.CreateUIObject("container", "Map3DSystem_s_fogcolor_blue_BG","_lt", 
						left, top + 32, ColorSliderWidth, ColorSliderHeight);
			_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/slider_background_16.png: 4 8 4 7";
			_this.enable = false;
			_sub_panel:AddChild(_this);
			
			local ctl = CommonCtrl.CCtrlColorEditor:new {
				name = "Map3DSystem_s_fogcolor",
				parent = _sub_panel,
				width = width,
				height = height,
				left = left, top = top, 
				r = 255,g = 255,b = 255,
				onchange = "Map3DSystem.UI.Sky.OnFogColorChanged();",
			};
			ctl:Show();
			
			local _this = ParaUI.GetUIObject("Map3DSystem_s_fogcolor_red");
			_this.button = "Texture/3DMapSystem/common/ThemeLightBlue/slider_button_16.png";
			_this.background = "";
			_this = ParaUI.GetUIObject("Map3DSystem_s_fogcolor_green");
			_this.button = "Texture/3DMapSystem/common/ThemeLightBlue/slider_button_16.png";
			_this.background = "";
			_this = ParaUI.GetUIObject("Map3DSystem_s_fogcolor_blue");
			_this.button = "Texture/3DMapSystem/common/ThemeLightBlue/slider_button_16.png";
			_this.background = "";
			
		else
			-- show Sky sub panel
			_sub_panel.visible = true;
		end
	else
		log("MainBar panel container is not yet initialized.\r\n");
	end
end

function Map3DSystem.UI.Sky.CloseUI()
	
	local _panel = ParaUI.GetUIObject("MainBar_panel");
	
	if(_panel:IsValid() == true) then
	
		local _sub_panel = _panel:GetChild("_sub_panel_sky");
		if(_sub_panel:IsValid() == false) then
			log("Sky panel container is not yet initialized.\r\n");
		else
			-- show Sky sub panel
			_sub_panel.visible = false;
			
			--NPL.load("(gl)script/ide/UIAnim/UIAnimManager.lua");
			--local fileName = "script/UIAnimation/CommonPanel.lua.table";
			--UIAnimManager.PlayUIAnimationSequence(_sub_panel, fileName, "Hide", false);
		end
	else
		log("MainBar panel container is not yet initialized.\r\n");
	end
end

----------------------------------------------------------
-- functions
----------------------------------------------------------

-- called when the sky box need to be changed
function Map3DSystem.UI.Sky.OnChangeSkybox(nIndex)
	local item = Map3DSystem.UI.Sky.skyboxes[nIndex];
	if(item ~= nil) then
	
		Map3DSystem.Animation.SendMeMessage({
				type = Map3DSystem.msg.ANIMATION_Character,
				obj_params = nil, --  <player>
				animationName = "ModifyNature",
				});
				
		Map3DSystem.SendMessage_env({type = Map3DSystem.msg.SKY_SET_Sky, skybox = item.file,  skybox_name = item.name})
	end
end

-- called when the fog color changes
function Map3DSystem.UI.Sky.OnFogColorChanged()
	local ctl = CommonCtrl.GetControl("Map3DSystem_s_fogcolor");
	if(ctl~=nil) then
		Map3DSystem.SendMessage_env({type = Map3DSystem.msg.SKY_SET_Sky, fog_r = ctl.r/255, fog_g = ctl.g/255, fog_b = ctl.b/255,})
	end
end

-- called when the sky color changes
function Map3DSystem.UI.Sky.OnSkyColorChanged()
	local ctl = CommonCtrl.GetControl("Map3DSystem_s_skycolor");
	if(ctl~=nil) then
		Map3DSystem.SendMessage_env({type = Map3DSystem.msg.SKY_SET_Sky, sky_r = ctl.r/255, sky_g = ctl.g/255, sky_b = ctl.b/255,})
	end
end

-- UI handler 
function Map3DSystem.UI.Sky.OnTimeSliderChanged()
	local temp = ParaUI.GetUIObject("Map3DSystem_s_light_slider");
	if (temp:IsValid() == true) then
		local fTime=(temp.value/100-0.5)*2;
		Map3DSystem.SendMessage_env({type = Map3DSystem.msg.SKY_SET_Sky, timeofday = fTime})
	end	
end

-- update time slider UI
function Map3DSystem.UI.Sky.UpdateTimeSliderUI()
	local _light = ParaUI.GetUIObject("Map3DSystem_s_light_slider");
	if(_light:IsValid() == true) then
		_light.value = (ParaScene.GetTimeOfDaySTD()/2+0.5)*100;
	end
end

-- update fog color UI
function Map3DSystem.UI.Sky.UpdateFogColorUI()
	local ctl = CommonCtrl.GetControl("Map3DSystem_s_fogcolor");
	if(ctl~=nil) then
		local att = ParaScene.GetAttributeObject();
		if(att~=nil) then
			local color = att:GetField("FogColor", {1, 1, 1});
			ctl:SetRGB(color[1]*255, color[2]*255, color[3]*255);
		end
	end
end

-- update sky color UI
function Map3DSystem.UI.Sky.UpdateSkyColorUI()
	local ctl = CommonCtrl.GetControl("Map3DSystem_s_skycolor");
	if(ctl~=nil) then
		local att = ParaScene.GetAttributeObject();
		if(att~=nil) then
			local color = att:GetField("SkyColor", {1, 1, 1});
			ctl:SetRGB(color[1]*255, color[2]*255, color[3]*255);
		end
	end
end

function Map3DSystem.UI.Sky.OnMouseEnter()
end

function Map3DSystem.UI.Sky.OnMouseLeave()
end