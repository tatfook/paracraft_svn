--[[
Title: PoliceMedalDisplayBox
Author(s): WangTian
Date: 2009/11/30

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/30003_PoliceMedalDisplayBox.lua
------------------------------------------------------------
]]

-- create class
local libName = "PoliceMedalDisplayBox";
local PoliceMedalDisplayBox = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.PoliceMedalDisplayBox", PoliceMedalDisplayBox);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- PoliceMedalDisplayBox.main
function PoliceMedalDisplayBox.main()
	PoliceMedalDisplayBox.RefreshStatus();
end

-- 50001_PoliceInauguralQuestAccept
-- 50002_PoliceInauguralQuestComplete

-- update the NPC quest status in quest area
function PoliceMedalDisplayBox.RefreshStatus()
end

function PoliceMedalDisplayBox.PreDialog()
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	style.shadow_bg = "texture/bg_black_20opacity.png";
	style.fillShadowLeft = -10000;
	style.fillShadowTop = -10000;
	style.fillShadowWidth = -10000;
	style.fillShadowHeight = -10000;
	System.App.Commands.Call("File.MCMLWindowFrame", {
		url = "script/apps/Aries/NPCs/Police/30003_PoliceMedalDisplayBox_dialog.html", 
		name = "Police_PoliceMedalDisplayBox", 
		app_key = MyCompany.Aries.app.app_key, 
		isShowTitleBar = false,
		--DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		style = style,
		zorder = 2,
		allowDrag = false,
		isTopLevel = true,
		directPosition = true,
			align = "_ct",
			x = -655/2,
			y = -552/2,
			width = 655,
			height = 512,
		DestroyOnClose = true,
	});
	return false;
end