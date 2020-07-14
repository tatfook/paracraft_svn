--[[
Title: Class List 
Author(s): Chenjinxian
Date: 2020/7/6
Desc: 
use the lib:
-------------------------------------------------------
local ChatRoomPage = NPL.load("(gl)script/apps/Aries/Creator/Game/Network/Admin/ClassManager/ChatRoomPage.lua");
ChatRoomPage.ShowPage()
-------------------------------------------------------
]]
local TeacherPanel = NPL.load("(gl)script/apps/Aries/Creator/Game/Network/Admin/ClassManager/TeacherPanel.lua");
local ChatRoomPage = NPL.export()

local page;

function ChatRoomPage.OnInit()
	page = document:GetPageCtrl();
end

function ChatRoomPage.ShowPage()
	local params = {
		url = "script/apps/Aries/Creator/Game/Network/Admin/ClassManager/ChatRoomPage.html", 
		name = "ChatRoomPage.ShowPage", 
		isShowTitleBar = false,
		DestroyOnClose = true,
		style = CommonCtrl.WindowFrame.ContainerStyle,
		allowDrag = true,
		enable_esc_key = true,
		click_through = false, 
		app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key, 
		directPosition = true,
		align = "_ct",
		x = -750 / 2,
		y = -533 / 2,
		width = 750,
		height = 533,
	};
	System.App.Commands.Call("File.MCMLWindowFrame", params);
end

function ChatRoomPage.OnClose()
	page:CloseWindow();
end

function ChatRoomPage.GetClassName()
	--return TeacherPanel.CurrentClassName;
	return L"编程1班";
end

function ChatRoomPage.GetClassPeoples()
	return L"班级成员 10/20";
end

function ChatRoomPage.InviteAll()
end

function ChatRoomPage.ClassItems()
	local items = {{name="张晓", teacher=true, online=true},
		{name="张飞", teacher=false, online=false},
		{name="赵云", teacher=false, online=true}};
	return items;
end

function ChatRoomPage.ChatItems()
end

function ChatRoomPage.SendMessage()
end
