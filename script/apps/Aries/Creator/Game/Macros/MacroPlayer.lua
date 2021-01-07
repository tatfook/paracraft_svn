--[[
Title: Macro Player
Author(s): LiXizhi
Date: 2021/1/4
Desc: Macro Player page

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Macros/MacroPlayer.lua");
local MacroPlayer = commonlib.gettable("MyCompany.Aries.Game.Tasks.MacroPlayer");
MacroPlayer.ShowPage();
-------------------------------------------------------
]]
local Macros = commonlib.gettable("MyCompany.Aries.Game.GameLogic.Macros")
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local MacroPlayer = commonlib.inherit(nil, commonlib.gettable("MyCompany.Aries.Game.Tasks.MacroPlayer"));
local page;

function MacroPlayer.OnInit()
	page = document:GetPageCtrl();
	GameLogic.GetFilters():add_filter("Macro_EndPlay", MacroPlayer.OnEndPlay);
	GameLogic.GetFilters():add_filter("Macro_PlayMacro", MacroPlayer.OnPlayMacro);
end

-- @param duration: in seconds
function MacroPlayer.ShowPage()
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/Creator/Game/Macros/MacroPlayer.html", 
			name = "MacroPlayerTask.ShowPage", 
			app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key, 
			isShowTitleBar = false,
			bShow = true,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1000,
			allowDrag = false,
			directPosition = true,
				align = "_fi",
				x = 0,
				y = 0,
				width = 0,
				height = 0,
		});
end

function MacroPlayer.OnPlayMacro(fromLine, macros)
	local progress = math.floor(fromLine / (#macros)*100 + 0.5);
	if(page) then
		page:SetValue("progress", progress);
	end
	return fromLine;
end

function MacroPlayer.OnEndPlay()
	MacroPlayer.CloseWindow();
end

function MacroPlayer.CloseWindow()
	if(page) then
		page:CloseWindow();
		page = nil;
	end
end

function MacroPlayer.OnClickStop()
	GameLogic.Macros:Stop()
end
