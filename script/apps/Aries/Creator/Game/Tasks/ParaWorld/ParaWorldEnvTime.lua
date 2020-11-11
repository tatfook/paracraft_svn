--[[
Title: paraworld list
Author(s): chenjinxian
Date: 2020/9/8
Desc: 
use the lib:
------------------------------------------------------------
local ParaWorldEnvTime = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/ParaWorld/ParaWorldEnvTime.lua");
ParaWorldEnvTime.ShowPage();
-------------------------------------------------------
]]
local CommandManager = commonlib.gettable("MyCompany.Aries.Game.CommandManager");
local ParaWorldEnvTime = NPL.export();

local isEnvTimeShow = false;
local page;
function ParaWorldEnvTime.OnInit()
	page = document:GetPageCtrl();
end

function ParaWorldEnvTime.ShowPage()
	if (not isEnvTimeShow) then
		isEnvTimeShow = true;
		local params = {
			url = "script/apps/Aries/Creator/Game/Tasks/ParaWorld/ParaWorldEnvTime.html",
			name = "ParaWorldEnvTime.ShowPage", 
			isShowTitleBar = false,
			DestroyOnClose = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = false,
			enable_esc_key = true,
			app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key, 
			directPosition = true,
			align = "_rt",
			x = -260,
			y = 256,
			width = 220,
			height = 50,
		};
		System.App.Commands.Call("File.MCMLWindowFrame", params);

		params._page.OnClose = function()
			isEnvTimeShow = false;
		end
	else
		ParaWorldEnvTime.OnClose();
	end
end

function ParaWorldEnvTime.OnClose()
	if (page) then
		page:CloseWindow();
	end
end

function ParaWorldEnvTime.OnTimeSliderChanged(value)
	if (value) then
		local time=(value/1000-0.5)*2;
		time = tostring(time);
		CommandManager:RunCommand("time", time);
	end	
end
