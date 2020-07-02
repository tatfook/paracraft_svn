--[[
Title: GreatIceBear
Author(s): Leio
Date: 2011/01/26

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/ShoppingZone/30418_GreatIceBear.lua
------------------------------------------------------------
]]
-- create class
local libName = "GreatIceBear";
local GreatIceBear = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.GreatIceBear", GreatIceBear);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

function GreatIceBear.main()
end
function GreatIceBear.PreDialog()
end