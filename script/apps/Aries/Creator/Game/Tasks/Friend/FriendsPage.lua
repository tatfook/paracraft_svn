--[[
Title: FriendsPage
Author(s): 
Date: 2020/7/3
Desc:  
Use Lib:
-------------------------------------------------------
local FriendsPage = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Friend/FriendsPage.lua");
FriendsPage.Show();
--]]
local FriendsPage = NPL.export();


local page;


function FriendsPage.OnInit()
	page = document:GetPageCtrl();
end

function FriendsPage.Show()
    local params = {
			url = "script/apps/Aries/Creator/Game/Tasks/Friend/FriendsPage.html",
			name = "FriendsPage.Show", 
			isShowTitleBar = false,
			DestroyOnClose = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			enable_esc_key = true,
			zorder = -1,
			app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key, 
			directPosition = true,
				align = "_lt",
				x = 10,
				y = 10/2,
				width = 300,
				height = 500,
		};
	System.App.Commands.Call("File.MCMLWindowFrame", params);
end
