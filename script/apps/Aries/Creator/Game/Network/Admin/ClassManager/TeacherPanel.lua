--[[
Title: Teacher Panel
Author(s): Chenjinxian
Date: 2020/7/6
Desc: 
use the lib:
-------------------------------------------------------
local TeacherPanel = NPL.load("(gl)script/apps/Aries/Creator/Game/Network/Admin/ClassManager/TeacherPanel.lua");
TeacherPanel.ShowPage(true)
-------------------------------------------------------
]]
local TeacherPanel = NPL.export()

TeacherPanel.InClass = false;
TeacherPanel.IsLocked = false;

local page;
function TeacherPanel.OnInit()
	page = document:GetPageCtrl();
end

function TeacherPanel.ShowPage(bShow, offsetY)
	if (page) then
		GameLogic.GetEvents():RemoveEventListener("DesktopMenuShow", TeacherPanel.MoveDown, TeacherPanel);
		page:CloseWindow();
	end
	local params = {
			url = "script/apps/Aries/Creator/Game/Network/Admin/ClassManager/TeacherPanel.html", 
			name = "TeacherPanel.ShowPage", 
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
				y = offsetY or 0,
				width = 0,
				height = 48,
		};
	System.App.Commands.Call("File.MCMLWindowFrame", params);

	GameLogic.GetEvents():AddEventListener("DesktopMenuShow", TeacherPanel.MoveDown, TeacherPanel, "TeacherPanel");
end

function TeacherPanel.OnClose()
	GameLogic.GetEvents():RemoveEventListener("DesktopMenuShow", TeacherPanel.MoveDown, TeacherPanel);
	page:CloseWindow();
end

function TeacherPanel:MoveDown(event)
	if (event.bShow) then
		TeacherPanel.ShowPage(nil, 32);
	else
		TeacherPanel.ShowPage(nil, 0);
	end
end

function TeacherPanel.SelectClass()
	local ClassListPage = NPL.load("(gl)script/apps/Aries/Creator/Game/Network/Admin/ClassManager/ClassListPage.lua");
	ClassListPage.ShowPage();
	page:CloseWindow();
end

function TeacherPanel.LeaveClass()
end

function TeacherPanel.GetClassName()
	return "编程1班";
end

function TeacherPanel.GetClassStudents()
	return "在课学生：10人";
end

function TeacherPanel.Lock()
	TeacherPanel.IsLocked = true;
	if (page) then
		page:Refresh(0);
	end
end

function TeacherPanel.UnLock()
	TeacherPanel.IsLocked = false;
	if (page) then
		page:Refresh(0);
	end
end

function TeacherPanel.OpenChat()
	local ChatRoomPage = NPL.load("(gl)script/apps/Aries/Creator/Game/Network/Admin/ClassManager/ChatRoomPage.lua");
	ChatRoomPage.ShowPage()
end

function TeacherPanel.ConnectClass()
end

function TeacherPanel.ShareUrl()
	local ShareUrlPage = NPL.load("(gl)script/apps/Aries/Creator/Game/Network/Admin/ClassManager/ShareUrlPage.lua");
	ShareUrlPage.ShowPage()
	TeacherPanel.OnClose();
end
