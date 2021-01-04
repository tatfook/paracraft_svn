--[[
Title: Macro Recorder
Author(s): LiXizhi
Date: 2021/1/4
Desc: Macro Recorder page

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Macros/MacroRecorder.lua");
local MacroRecorder = commonlib.gettable("MyCompany.Aries.Game.Tasks.MacroRecorder");
MacroRecorder.ShowPage();
-------------------------------------------------------
]]
local Macros = commonlib.gettable("MyCompany.Aries.Game.GameLogic.Macros")
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local MacroRecorder = commonlib.inherit(nil, commonlib.gettable("MyCompany.Aries.Game.Tasks.MacroRecorder"));
local page;

function MacroRecorder.OnInit()
	page = document:GetPageCtrl();
	GameLogic.GetFilters():add_filter("Macro_EndRecord", MacroRecorder.OnMacroStopped);
end

-- @param duration: in seconds
function MacroRecorder.ShowPage(bShow)
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/Creator/Game/Macros/MacroRecorder.html", 
			name = "MacroRecorderTask.ShowPage", 
			app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key, 
			isShowTitleBar = false,
			bShow = bShow,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1000,
			allowDrag = true,
			directPosition = true,
				align = "_lt",
				x = 10,
				y = 10,
				width = 48,
				height = 48,
		});
end

function MacroRecorder.OnMacroStopped()
	MacroRecorder.CloseWindow();
end

function MacroRecorder.CloseWindow()
	if(page) then
		page:CloseWindow();
		page = nil;
	end
end

function MacroRecorder.OnStop()
	MacroRecorder.CloseWindow();
	Macros:Stop();
end