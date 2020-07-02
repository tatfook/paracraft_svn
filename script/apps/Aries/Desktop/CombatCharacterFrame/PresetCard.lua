--[[
Title: code behind for page PresetCard.html
Author(s): lipeng
Date: 2013/07/26
Desc:  script/apps/Aries/Desktop/CombatCharacterFrame/PresetCard.lua
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/PresetCard.lua");
local PresetCard = commonlib.gettable("MyCompany.Aries.Inventory.Cards.MyCardsManager.PresetCard");
PresetCard.ShowPage();
-------------------------------------------------------
]]

local PresetCard = commonlib.gettable("MyCompany.Aries.Inventory.Cards.MyCardsManager.PresetCard");


function PresetCard.ShowPage()
local params = {
		url = "script/apps/Aries/Desktop/CombatCharacterFrame/PresetCard.html",
		name = "PresetCard.ShowPage", 
		app_key=MyCompany.Aries.app.app_key, 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		enable_esc_key = true,
		style = CommonCtrl.WindowFrame.ContainerStyle,
		allowDrag = true,
		--zorder = 10,
		directPosition = true,
			align = "_ct",
			x = -600/2,
			y = -400/2,
			width = 600,
			height = 400,
	};
	System.App.Commands.Call("File.MCMLWindowFrame", params);	
end