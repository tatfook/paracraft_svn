--[[
Title: Class List 
Author(s): Chenjinxian
Date: 2020/7/6
Desc: 
use the lib:
-------------------------------------------------------
local ClassListPage = NPL.load("(gl)script/apps/Aries/Creator/Game/Network/Admin/ClassManager/ClassListPage.lua");
ClassListPage.ShowPage()
-------------------------------------------------------
]]
local ClassListPage = NPL.export()

local page;

function ClassListPage.OnInit()
	page = document:GetPageCtrl();
end

function ClassListPage.ShowPage()
	local params = {
		url = "script/apps/Aries/Creator/Game/Network/Admin/ClassManager/ClassListPage.html", 
		name = "ClassListPage.ShowPage", 
		isShowTitleBar = false,
		DestroyOnClose = true,
		style = CommonCtrl.WindowFrame.ContainerStyle,
		allowDrag = true,
		enable_esc_key = true,
		app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key, 
		directPosition = true,
		align = "_ct",
		x = -400 / 2,
		y = -200 / 2,
		width = 400,
		height = 200,
	};
	System.App.Commands.Call("File.MCMLWindowFrame", params);
end

function ClassListPage.OnClose()
	page:CloseWindow();
end

function ClassListPage.GetClassList()
	local classes = {}
	return classes;
end

function ClassListPage.OnSelectClass()
end