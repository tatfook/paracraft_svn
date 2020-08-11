--[[
Title: UserBagPage
Author(s): 
Date: 2020/8/11
Desc:  
Use Lib:
-------------------------------------------------------
local UserBagPage = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/User/UserBagPage.lua");
UserBagPage.ShowPage();
--]]
local KeepWorkItemManager = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/KeepWorkItemManager.lua");

local UserBagPage = NPL.export()
local page
function UserBagPage.OnInit()
    page = document:GetPageCtrl();
end
function UserBagPage.ShowPage()
    UserBagPage.Current_Item_DS = KeepWorkItemManager.items;
	local params = {
			url = "script/apps/Aries/Creator/Game/Tasks/User/UserBagPage.html",
			name = "UserBagPage.ShowPage", 
			isShowTitleBar = false,
			DestroyOnClose = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			enable_esc_key = true,
			zorder = 100,
			--app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key, 
			directPosition = true,
				align = "_ct",
				x = -600/2,
				y = -500/2,
				width = 600,
				height = 500,
		};
	System.App.Commands.Call("File.MCMLWindowFrame", params);
end