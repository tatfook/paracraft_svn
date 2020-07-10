--[[
Title: Teacher Panel
Author(s): Chenjinxian
Date: 2020/7/6
Desc: 
use the lib:
-------------------------------------------------------
local StudentPanel = NPL.load("(gl)script/apps/Aries/Creator/Game/Network/Admin/ClassManager/StudentPanel.lua");
StudentPanel.ShowPage(true)
-------------------------------------------------------
]]
local StudentPanel = NPL.export()

StudentPanel.IsLocked = false;

local page;
function StudentPanel.OnInit()
	page = document:GetPageCtrl();
end

function StudentPanel.ShowPage(bShow)
	local params = {
			url = "script/apps/Aries/Creator/Game/Network/Admin/ClassManager/StudentPanel.html", 
			name = "StudentPanel.ShowPage", 
			isShowTitleBar = false,
			DestroyOnClose = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = false,
			bShow = bShow,
			zorder = 0,
			click_through = false, 
			app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key, 
			directPosition = true,
				align = "_mt",
				x = 0,
				y = 0,
				width = 0,
				height = 100,
		};
	System.App.Commands.Call("File.MCMLWindowFrame", params);

	GameLogic.GetEvents():AddEventListener("DesktopMenuShow", StudentPanel.MoveDown, StudentPanel, "StudentPanel");
end

function StudentPanel.OnClose()
	GameLogic.GetEvents():RemoveEventListener("DesktopMenuShow", StudentPanel.MoveDown, StudentPanel);
	page:CloseWindow();
end

function StudentPanel:MoveDown(event)
	if (event.bShow) then
		StudentPanel.ShowPage(nil, 0, 32);
	else
		StudentPanel.ShowPage(nil, 0, 0);
	end
end

function StudentPanel.OpenChat()
end

function StudentPanel.ShareUrl()
	StudentPanel.OnClose();
end
