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
		app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key, 
		directPosition = true,
		align = "_ct",
		x = -730 / 2,
		y = -520 / 2,
		width = 730,
		height = 520,
	};
	System.App.Commands.Call("File.MCMLWindowFrame", params);
end

function ChatRoomPage.OnClose()
	page:CloseWindow();
end

function ChatRoomPage.GetClassList()
	local classes = {}
	return classes;
end

function ChatRoomPage.OnSelectClass()
end

function ChatRoomPage.OnOK()
	page:CloseWindow();
end
