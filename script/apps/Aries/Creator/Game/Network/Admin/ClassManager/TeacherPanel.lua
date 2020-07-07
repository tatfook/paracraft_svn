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

TeacherPanel.IsLocked = false;

local page;
function TeacherPanel.OnInit()
	page = document:GetPageCtrl();
end

function TeacherPanel.ShowPage(bShow)
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
				y = 0,
				width = 0,
				height = 100,
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
		TeacherPanel.ShowPage(nil, 0, 32);
	else
		TeacherPanel.ShowPage(nil, 0, 0);
	end
end

function TeacherPanel.SelectClass()
	local ClassListPage = NPL.load("(gl)script/apps/Aries/Creator/Game/Network/Admin/ClassManager/ClassListPage.lua");
	ClassListPage.ShowPage();
end

function TeacherPanel.Lock()
	--TeacherPanel.IsLocked = true;
	--if (page) then
		--page:Refresh(0);
	--end
	TeacherPanel.OnClose();
end

function TeacherPanel.UnLock()
	TeacherPanel.IsLocked = false;
	if (page) then
		page:Refresh(0);
	end
end

function TeacherPanel.OpenChat()
end

function TeacherPanel.ConnectClass()
end

function TeacherPanel.ShareUrl()
end
