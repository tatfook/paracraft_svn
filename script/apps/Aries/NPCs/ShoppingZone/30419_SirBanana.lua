--[[
Title: SirBanana
Author(s): Leio
Date: 2011/02/14

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/ShoppingZone/30419_SirBanana.lua
------------------------------------------------------------
]]
-- create class
local libName = "SirBanana";
local SirBanana = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.SirBanana", SirBanana);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

function SirBanana.main()
end
function SirBanana.PreDialog()
end