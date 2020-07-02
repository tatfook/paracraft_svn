--[[
Title: The dock page
Author(s): LiXizhi
Date: 2012/12/28
Desc:  
There dock has 2 mode: one for editor and one for creator
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/mobile/paracraft/Areas/SystemMenuPage.lua");
local SystemMenuPage = commonlib.gettable("ParaCraft.Mobile.Desktop.SystemMenuPage");
SystemMenuPage.ShowPage()
-------------------------------------------------------
]]
--NPL.load("(gl)script/ide/headon_speech.lua");
--NPL.load("(gl)script/apps/Aries/Creator/Game/API/UserProfile.lua");
--NPL.load("(gl)script/apps/Aries/Creator/Game/API/ExpTable.lua");
--NPL.load("(gl)script/apps/Aries/Creator/Game/API/UserProfile.lua");
--NPL.load("(gl)script/apps/Aries/Creator/Game/Effects/ObtainItemEffect.lua");
--local ObtainItemEffect = commonlib.gettable("MyCompany.Aries.Game.Effects.ObtainItemEffect");
--local UserProfile = commonlib.gettable("MyCompany.Aries.Creator.Game.API.UserProfile");
--local ExpTable = commonlib.gettable("MyCompany.Aries.Creator.Game.API.ExpTable");
--local UserProfile = commonlib.gettable("MyCompany.Aries.Creator.Game.API.UserProfile");
--local Desktop = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop");
--local SystemMenuPage = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop.SystemMenuPage");
--local ItemClient = commonlib.gettable("MyCompany.Aries.Game.Items.ItemClient");
--local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
--local names = commonlib.gettable("MyCompany.Aries.Game.block_types.names")
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local MainLogin = commonlib.gettable("ParaCraft.Mobile.MainLogin");
local SystemMenuPage = commonlib.gettable("ParaCraft.Mobile.Desktop.SystemMenuPage");

local page;
function SystemMenuPage.OnInit()
	page = document:GetPageCtrl();
	SystemMenuPage.open_sound = SystemMenuPage.open_sound or if_else(ParaAudio.GetVolume()>0,true,false);
end

SystemMenuPage.bExpanded = false;

function SystemMenuPage.ShowPage(bShow)
	local x,y,width,height;
	x = -762;
	y = 0;
	width = 762;
	height = 90;
	--if(SystemMenuPage.bExpanded) then
		--x = -742;
		--y = 0;
		--width = 742;
		--height = 370;
	--else
		--x = -117;
		--y = 0;
		--width = 117;
		--height = 100;
	--end
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/mobile/paracraft/Areas/SystemMenuPage.html", 
			name = "SystemMenuPage.ShowPage", 
			isShowTitleBar = false,
			DestroyOnClose = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = false,
			bShow = bShow,
			zorder = -2,
			click_through = true,
			directPosition = true,
				align = "_rt",
				x = x,
				y = y,
				width = width,
				height = height,
		});
end

function SystemMenuPage.ShowMenuPage(bExpanded)
	SystemMenuPage.bExpanded = bExpanded or false;
	SystemMenuPage.ShowPage();
end

function SystemMenuPage.SwitchMenuPage()
	SystemMenuPage.bExpanded = not SystemMenuPage.bExpanded;
	SystemMenuPage.Refresh();
end

function SystemMenuPage.Refresh()
	if(page) then
		page:Refresh(0.01);
	end
end

function SystemMenuPage.OnClickEnableSound()
	SystemMenuPage.open_sound = not SystemMenuPage.open_sound;
	if(SystemMenuPage.open_sound) then
		local key = "Paracraft_System_Sound_Volume";
		local sound_volume = Game.PlayerController:LoadLocalData(key,1,true);
		ParaAudio.SetVolume(sound_volume);
	else
		ParaAudio.SetVolume(0);
	end

	local key = "Paracraft_System_Sound_State";
	MyCompany.Aries.Player.SaveLocalData(key,SystemMenuPage.open_sound,true);

	if(page) then
		SystemMenuPage.Refresh();
	end
end

function SystemMenuPage.SaveWorld()
	GameLogic.QuickSave();	
end

function SystemMenuPage.Exit()
	GameLogic.RunCommand("/menu file.exit");
end