--[[
Title: ChiefHiltonDragon
Author(s): WangTian
Date: 2009/7/30

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/30014_ChiefHiltonDragon.lua
------------------------------------------------------------
]]

-- create class
local libName = "ChiefHiltonDragon";
local ChiefHiltonDragon = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.ChiefHiltonDragon", ChiefHiltonDragon);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- ChiefHiltonDragon.main
function ChiefHiltonDragon.main()
end
function ChiefHiltonDragon.CanShow()
	--龙宝宝4级成长任务接受
	return ( hasGSItem(50022) and not hasGSItem(50023) )
end