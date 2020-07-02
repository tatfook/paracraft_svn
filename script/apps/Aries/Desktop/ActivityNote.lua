--[[
Title: 
Author(s): zrf
Date: 2010/12/23
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/ActivityNote.lua");
MyCompany.Aries.Desktop.ActivityNote.ShowMainWnd();
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local ActivityNote = commonlib.gettable("MyCompany.Aries.Desktop.ActivityNote");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");

function ActivityNote.Init()
	ActivityNote.page = document:GetPageCtrl();
end

function ActivityNote.ShowMainWnd()
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);

    System.App.Commands.Call("File.MCMLWindowFrame", {
        url = "script/apps/Aries/Desktop/ActivityNote.html", 
        app_key = MyCompany.Aries.app.app_key, 
        name = "ActivityNote.ShowMainWnd", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
        style = style,
        zorder = 2,
        allowDrag = false,
		isTopLevel = true,
        directPosition = true,
            align = "_ct",
            x = -596/2,
            y = -440/2,
            width = 596,
            height = 440,
    });
end

function ActivityNote.GotoTree()
	local cpos = {8.86,0.36,2.70};
	local pos = {20032.66,2.56,19714.00};

	local insame_world = QuestHelp.InSameWorldByNum(0);
	if(not insame_world)then
		_guihelper.MessageBox("<div style='margin-left:15px;margin-top:35px;text-align:center'>不在当前岛屿，无法传送！</div>");
		return;
	end

	local msg = { aries_type = "OnMapTeleport", 
			position = pos, 
			camera = cpos, 
			wndName = "map", 
		};
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
	if(ActivityNote.page)then
		ActivityNote.page:CloseWindow();
	end
end

function ActivityNote.GotoTower()
	local cpos = {8.86,0.25,2.20};
	local pos = {19864.02,3.78,19522.23};

	local insame_world = QuestHelp.InSameWorldByNum(0);
	if(not insame_world)then
		_guihelper.MessageBox("<div style='margin-left:15px;margin-top:35px;text-align:center'>不在当前岛屿，无法传送！</div>");
		return;
	end

	local msg = { aries_type = "OnMapTeleport", 
			position = pos, 
			camera = cpos, 
			wndName = "map", 
		};
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
	if(ActivityNote.page)then
		ActivityNote.page:CloseWindow();
	end
end

function ActivityNote.GotoGongZhu()
	local cpos = {8.29,0.68,-0.24};
	local pos = {19934.43,6.59,20025.19};

	local insame_world = QuestHelp.InSameWorldByNum(0);
	if(not insame_world)then
		_guihelper.MessageBox("<div style='margin-left:15px;margin-top:35px;text-align:center'>不在当前岛屿，无法传送！</div>");
		return;
	end

	local msg = { aries_type = "OnMapTeleport", 
			position = pos, 
			camera = cpos, 
			wndName = "map", 
		};
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
	if(ActivityNote.page)then
		ActivityNote.page:CloseWindow();
	end
end