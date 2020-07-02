--[[
Title: 
Author(s): leio
Date: 2012/4/25
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/RankingHelperPage.lua");
local RankingHelperPage = commonlib.gettable("MyCompany.Aries.Inventory.RankingHelperPage");
RankingHelperPage.ShowPage();
-------------------------------------------------------
]]
local RankingHelperPage = commonlib.gettable("MyCompany.Aries.Inventory.RankingHelperPage");
function RankingHelperPage.ShowPage()
	local params = {
				url = "script/apps/Aries/Desktop/CombatCharacterFrame/RankingHelperPage.html", 
				name = "RankingHelperPage.ShowPage", 
				app_key=MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				enable_esc_key = true,
				style = CommonCtrl.WindowFrame.ContainerStyle,
				allowDrag = true,
				zorder = 2,
				isTopLevel = true,
				directPosition = true,
					align = "_ct",
					x = -760/2,
					y = (-470/2 - 25),
					width = 760,
					height = 470,
		}
	System.App.Commands.Call("File.MCMLWindowFrame", params);		
end