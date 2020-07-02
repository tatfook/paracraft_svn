--[[
Title: HeartOfFlyingDragon
Author(s): WangTian
Date: 2009/7/30

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/30112_HeartOfFlyingDragon.lua
------------------------------------------------------------
]]

-- create class
local libName = "HeartOfFlyingDragon";
local HeartOfFlyingDragon = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.HeartOfFlyingDragon", HeartOfFlyingDragon);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- HeartOfFlyingDragon.main
function HeartOfFlyingDragon.main()
end