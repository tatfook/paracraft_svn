--[[
Title: ChiefHilton
Author(s): WangTian
Date: 2009/7/22

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Police/30001_ChiefHilton.lua
------------------------------------------------------------
]]

-- create class
local libName = "ChiefHilton";
local ChiefHilton = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.ChiefHilton", ChiefHilton);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

function ChiefHilton.main()
	-- purchase the init medal if the user complete the police quest but not have the init medal
	if(hasGSItem(50002) and not hasGSItem(20015)) then
		ItemManager.PurchaseItem(20015, 1, function() end, function() end, nil, "none");
	end
	
	-- first refresh the hilton status
	ChiefHilton.RefreshStatus();
end

-- update the NPC quest status in quest area
function ChiefHilton.RefreshStatus()
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	local equipGSItem = ItemManager.IfEquipGSItem;
	if(hasGSItem(50001) and not hasGSItem(50002)) then
		-- append accept quest
		MyCompany.Aries.Desktop.QuestArea.AppendQuestStatus(
			"script/apps/Aries/NPCs/Police/30001_ChiefHilton_InauguralQuest_status.html",
			"medal", "", "我要成为一名警官", 50001);
	else
		-- delete quest status
		MyCompany.Aries.Desktop.QuestArea.DeleteQuestStatus(
			"script/apps/Aries/NPCs/Police/30001_ChiefHilton_InauguralQuest_status.html"
			);
	end
end