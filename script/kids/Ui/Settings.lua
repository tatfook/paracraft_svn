--[[
Title: game setting dialog
Author(s): LiXizhi
Date: 2006/12/4
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/ui/Settings.lua");
KidsUI.ShowSettings();
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/ParaEngineSettings.lua");
NPL.load("(gl)script/ide/integereditor_control.lua");

local L = CommonCtrl.Locale("KidsUI");
-- KidsUI: Kids UI library 
if(not KidsUI) then KidsUI={}; end
KidsUI.MusicVolumeMin = 0
KidsUI.MusicVolumeMax = 100
-- toggle the display of the quick Settings window
-- @param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function KidsUI.ShowSettings(bShow)
	local _this,_parent;
	
	local _this = ParaUI.GetUIObject("KidsUI_Settings_cont")
	if(_this:IsValid() == false) then 
		if(bShow == false) then return	end
		
		local width, height = 470,395
		_this=ParaUI.CreateUIObject("container","KidsUI_Settings_cont", "_ct",-width/2,-height/2-50,width, height);
		_this.background="Texture/net_bg.png;0 0 470 395";
		_this:SetTopLevel(true);
		_this:AttachToRoot();
		_parent = _this;
		
		local left, top, width, height = 35, 80, 110, 30;
		--Resolution : Full screen or Windowed
		_this=ParaUI.CreateUIObject("text","s", "_lt",left, top, width, height);
		_parent:AddChild(_this);
		_this.text = L"Display Mode";
		
		_this=ParaUI.CreateUIObject("button","b", "_lt",left+width, top, 100, 30);
		_this.text = L"FullScreen"
		_this.onclick=";ParaEngine.SetWindowedMode(false);";
		_parent:AddChild(_this);
		
		_this=ParaUI.CreateUIObject("button","b", "_lt",left+width+105, top, 100, 30);
		_this.text = L"Windowed"
		_this.onclick=";ParaEngine.SetWindowedMode(true);";
		_parent:AddChild(_this);
		
		top = top+height+10;
		-- graphics : low, medium, high, ultra high
		_this=ParaUI.CreateUIObject("text","s", "_lt",left, top, width, height);
		_parent:AddChild(_this);
		_this.text = L"Graphics";
		
		local size = 50;
		local left1 = left+width;
		_this=ParaUI.CreateUIObject("button","setting_graphic_poor", "_lt", left1, top, size, 30);
		_this.text = L"poor"
		_this.onclick=";KidsUI.OnChangeGraphicsSettings(1024);KidsUI.UpdateGraphicsSettings();";
		_parent:AddChild(_this);
		left1 = left1+size;
		
		_this=ParaUI.CreateUIObject("button","setting_graphic_low", "_lt",left1, top, size, 30);
		_this.text = L"low"
		_this.onclick=";KidsUI.OnChangeGraphicsSettings(-1);KidsUI.UpdateGraphicsSettings();";
		_parent:AddChild(_this);
		left1 = left1+size;
		
		_this=ParaUI.CreateUIObject("button","setting_graphic_med", "_lt",left1, top, size, 30);
		_this.text = L"med"
		_this.onclick=";KidsUI.OnChangeGraphicsSettings(0);KidsUI.UpdateGraphicsSettings();";
		_parent:AddChild(_this);
		left1 = left1+size;
		
		_this=ParaUI.CreateUIObject("button","setting_graphic_high", "_lt",left1, top, size, 30);
		_this.text = L"high"
		_this.onclick=";KidsUI.OnChangeGraphicsSettings(1);KidsUI.UpdateGraphicsSettings();";
		_parent:AddChild(_this);
		left1 = left1+size;
		
		_this=ParaUI.CreateUIObject("button","setting_graphic_super", "_lt",left1, top, size, 30);
		_this.text = L"super"
		_this.onclick=";KidsUI.OnChangeGraphicsSettings(2);KidsUI.UpdateGraphicsSettings();";
		_parent:AddChild(_this);
		
		top = top+height+10;
		-- Mouse : Inverse Pitch
		_this=ParaUI.CreateUIObject("text","s", "_lt",left, top, width, height);
		_parent:AddChild(_this);
		_this.text = L"Mouse";
		
		_this=ParaUI.CreateUIObject("button","setting_inversemouse_btn", "_lt",left+width, top, 120, 30);
		_this.text = L"Inverse Mouse"
		_this.onclick=";ParaSettingsUI.InverseMouse();KidsUI.OnUpdateInverseMouse();";
		_parent:AddChild(_this);
		KidsUI.OnUpdateInverseMouse();
		top = top+height+10;
		
		-- View Distance: 
		_this=ParaUI.CreateUIObject("text","s", "_lt",left, top, width, height);
		_parent:AddChild(_this);
		_this.text = L"View Distance";
		
		local ctl = CommonCtrl.CCtrlIntegerEditor:new{
			name = "SettingViewDistance",
			left=left+width, top=top,width = 200,
			maxvalue=400, minvalue=40,
			value = ParaCamera.GetAttributeObject():GetField("FarPlane", 120),
			parent = _parent,
			onchange = "KidsUI.OnViewDistanceChanged();",
			UseSlider = true,
		};
		ctl:Show();
		top = top+height+10;
		
		-- music volumes
		_this=ParaUI.CreateUIObject("text","s", "_lt",left, top, width, height);
		_parent:AddChild(_this);
		_this.text = L"Music Volume";
		
		_this=ParaUI.CreateUIObject("slider","music_volume_slider","_lt",left+width, top, 200, 25);
		_parent:AddChild(_this);
		_this:SetTrackRange(0,100);
		_this.value= (ParaAudio.GetBGMusicVolume()-KidsUI.MusicVolumeMin)/(KidsUI.MusicVolumeMax - KidsUI.MusicVolumeMin)*255;
		_this.onchange=";KidsUI.OnMusicVolumeSliderChange();";
		
		top = top+height+10;
		
		-- the save button
		_this=ParaUI.CreateUIObject("button","btn", "_rb",-230, -70,95, 36);
		_parent:AddChild(_this);
		_this.onclick=[[;KidsUI.OnSaveSettings();]];
		_this.text = L"Save";
		
		-- the close button
		_this=ParaUI.CreateUIObject("button","btn", "_rb",-130, -70,95, 36);
		_parent:AddChild(_this);
		_this.onclick=";KidsUI.ShowSettings(false);";
		_this.text = L"Close";
		_this = _parent;
	else
		if(bShow == nil) then
			_this.visible = not _this.visible;
		else
			_this.visible = bShow;
		end
	end
	
	if(_this.visible == true) then
		_this:SetTopLevel(true);
		KidsUI.PushState({name = "Settings", OnEscKey = "KidsUI.ShowSettings(false);"});
		KidsUI.UpdateGraphicsSettings();
	else
		KidsUI.PopState("Settings");
	end
end

--[[ call this function, when any of the setting state has been changed. 
function KidsUI.OnUpdateSettingsUI()
	local displayMode = {[1] = "kids_setting_FullScreen", [2] = "kids_setting_Windowed"}
	local nMode=1;
	_guihelper.CheckRadioButtons(displayMode,displayMode[1], "255 0 0" );
end]]

function KidsUI.OnSaveSettings()
	ParaEngine.WriteConfigFile("config/config.txt");
	KidsUI.ShowSettings(false);
	_guihelper.MessageBox(L"settings have been saved");
end

function KidsUI.UpdateGraphicsSettings()
	local s={[1024] = "setting_graphic_poor", [-1] = "setting_graphic_low", [0] = "setting_graphic_med", [1] = "setting_graphic_high", [2] = "setting_graphic_super",}
	local sel = s[ParaEngine.GetGameEffectSet()];
	_guihelper.CheckRadioButtons(s, sel, "255 0 0");		
end

function KidsUI.OnChangeGraphicsSettings(nLevel)
	ParaSettingsUI.SetGraphicsLevel(nLevel);
	local ctl= CommonCtrl.GetControl("SettingViewDistance");
	if(ctl~=nil)then
		if(nLevel==-1) then
			ctl:ChangeValue(50);
		elseif(nLevel==0) then
			ctl:ChangeValue(120);
		elseif(nLevel>=1) then
			-- retain user settings. 
		end	
	end
end

-- update the UI state according to the current mouse inverse state
function KidsUI.OnUpdateInverseMouse()
	if(ParaSettingsUI.IsInverseMouse()==true) then
		_guihelper.SetUIColor(ParaUI.GetUIObject("setting_inversemouse_btn"), "255 0 0");
	else
		_guihelper.SetUIColor(ParaUI.GetUIObject("setting_inversemouse_btn"), "255 255 255");
	end	
end

function KidsUI.OnMusicVolumeSliderChange()
	local _this=ParaUI.GetUIObject("music_volume_slider");
	if(_this:IsValid() == true)then 
		local value = _this.value/255*(KidsUI.MusicVolumeMax-KidsUI.MusicVolumeMin)+KidsUI.MusicVolumeMin;
		ParaSettingsUI.SetMusicVolume(value);
	end
end

function KidsUI.OnViewDistanceChanged()
	local ctl= CommonCtrl.GetControl("SettingViewDistance");
	if(ctl~=nil)then
		local FarPlane = ctl.value;
		local att = ParaScene.GetAttributeObject();
		att:SetField("FogEnd", FarPlane);
		local FogStart = att:GetField("FogStart", 50);
		if(FogStart>FarPlane-20) then
			att:SetField("FogStart", FarPlane-20);
		elseif(FogStart<50 and FarPlane>70)	then
			att:SetField("FogStart", 50);
		end
		
		ParaCamera.GetAttributeObject():SetField("FarPlane", FarPlane);
	else
		log("SettingViewDistance is not found\r\n");
	end
end