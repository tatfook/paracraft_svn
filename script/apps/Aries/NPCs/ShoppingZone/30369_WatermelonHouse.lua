--[[
Title: WatermelonHouse
Author(s): Leio
Date: 2010/03/15

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/ShoppingZone/30369_WatermelonHouse.lua
------------------------------------------------------------
]]
-- create class
local libName = "WatermelonHouse";
local WatermelonHouse = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.WatermelonHouse", WatermelonHouse);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- WatermelonHouse.main
function WatermelonHouse.main()
end
function WatermelonHouse.PreDialog()
	local self = WatermelonHouse;
end
---return true if the user has watermelon house
function WatermelonHouse.HasHouse()
	local self = WatermelonHouse;
	return hasGSItem(30128);
end
function WatermelonHouse.ItemSatisfied()
	local self = WatermelonHouse;
	return hasGSItem(30122) and hasGSItem(30123) and hasGSItem(30124) and hasGSItem(30125);
end
function WatermelonHouse.DoFinished()
	local self = WatermelonHouse;
	if(self.HasHouse() or not self.ItemSatisfied())then return end
	--¶Ò»»
	commonlib.echo("========before extend watermelon house");
	ItemManager.ExtendedCost(383, nil, nil,function(msg) end, function(msg) 
		commonlib.echo("========after extend watermelon house");
		commonlib.echo(msg);
	end);
end