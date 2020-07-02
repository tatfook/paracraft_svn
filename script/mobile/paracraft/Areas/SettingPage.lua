--[[
Title: The dock page
Author(s): LiXizhi
Date: 2012/12/28
Desc:  
There dock has 2 mode: one for editor and one for creator
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/mobile/paracraft/Areas/SettingPage.lua");
local SettingPage = commonlib.gettable("ParaCraft.Mobile.Desktop.SettingPage");
SettingPage.ShowPage(true)
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/Commands/CommandManager.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/game_logic.lua");
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local CommandManager = commonlib.gettable("MyCompany.Aries.Game.CommandManager");
local WorldCommon = commonlib.gettable("MyCompany.Aries.Creator.WorldCommon");
local SettingPage = commonlib.gettable("ParaCraft.Mobile.Desktop.SettingPage");

SettingPage.menuList = {
	{text = L"常用",url = "",index = 1,},
	{text = L"材质",url = "",index = 2,},
} 

SettingPage.select_menu_index = 1;

SettingPage.select_texture_index = 1;

local page;
function SettingPage.OnInit()
	SettingPage.page = document:GetPageCtrl();
	SettingPage.setting_ds = {};
end

function SettingPage.ShowPage(bShow)
	MyCompany.Aries.Creator.Game.Desktop.ShowMobileDesktop(false);

	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/mobile/paracraft/Areas/SettingPage.html", 
			name = "SettingPage.ShowPage", 
			isShowTitleBar = false,
			DestroyOnClose = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = false,
			bShow = bShow,
			zorder = -5,
			click_through = true, 
			directPosition = true,
				align = "_fi",
				x = 0,
				y = 0,
				width = 0,
				height = 0,
		});
	SettingPage.SetIframeSrc()
end

function SettingPage.ClosePage()
	if(SettingPage.page) then
		SettingPage.page:CloseWindow();
		GameLogic.options:Save();
		MyCompany.Aries.Creator.Game.Desktop.ShowMobileDesktop(true);
	end
end

function SettingPage.SetIframeSrc()
	if(SettingPage.page) then
		local index = SettingPage.select_menu_index;
		local frame = SettingPage.page:GetNode("view_set");
		if(frame and frame.pageCtrl)then
			if(index == 1) then
				frame:SetAttribute("src", "script/mobile/paracraft/Areas/GameSettingPage.html");
			elseif(index == 2) then
				frame:SetAttribute("src", "script/mobile/paracraft/Areas/TexturePage.html");
			end
		
		end
		SettingPage.Refresh()
	end
end

function SettingPage.Refresh()
	if(SettingPage.page) then
		SettingPage.page:Refresh(0.01);
	end
end

function SettingPage.OnClickEnableHideMainPlayer(bChecked)
	GameLogic.options:SetShowMainPlayer(not bChecked);
end

function SettingPage.OnTimeSliderChanged(value)
	if (value) then
		local time=(value/1000-0.5)*2;
		time = tostring(time);
		CommandManager:RunCommand("time", time);
	end	
end

function SettingPage.GetTimeOfDayStd()
	return (GameLogic.GetSim():GetTimeOfDayStd()+1)*1000/2;
end

function SettingPage.OnVolumeSliderChanged(value)
	GameLogic.options:SetVolume(value);
end

function SettingPage.OnCameraSliderChanged(value)
	GameLogic.options:SetCameraObjectDistance(value);
end

function SettingPage.OnMaxViewDistChanged(value)
	GameLogic.options:SetMaxViewDist(value);
end

-- open or close the mouse inverse
function SettingPage.OnClickEnableMouseInverse(bChecked)
	GameLogic.options:SetInvertMouse(bChecked);
end

function SettingPage.OnChangeSensitivity(value)
	GameLogic.options:SetSensitivity(value);
end

function SettingPage.OnChangeUIScaling(value)
	GameLogic.options:SetUIScaling(value);
end

function SettingPage.OnClickResetUIScaling()
	GameLogic.options:SetUIScaling(0);
	if(page) then
		page:SetValue("UI_Scaling", GameLogic.options:GetUIScaling());
	end
end

-- open or close the view bobbing
function SettingPage.OnToggleViewBobbing(bChecked)
	GameLogic.options:SetViewBobbing(bChecked);
end

function SettingPage.OnClickEnableVibration(bChecked)
	GameLogic.options:SetEnableVibration(bChecked);
end

function SettingPage.OnClickShowInfoWindow(bChecked)
	GameLogic.options:SetShowInfoWindow(bChecked);
end

function SettingPage.OnClickStereoMode(bChecked)
	GameLogic.options:EnableStereoMode(bChecked);
end

function SettingPage.OnStereoEyeDistChanged(value)
	GameLogic.options:SetStereoEyeSeparationDist(value);
end

function SettingPage.OnClickStereoController(value)
	GameLogic.options:SetStereoControllerEnabled(value);
end

function SettingPage.OnSuperRenderDistChanged(value)
	GameLogic.options:SetSuperRenderDist(value);
    if(value and value > GameLogic.options:GetRenderDist() and value>64) then
        GameLogic.options:SetFogEnd(value - 64);
    end
end