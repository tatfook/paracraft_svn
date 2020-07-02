--[[
Title: CandyHouse
Author(s): Leio
Date: 2010/01/04

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/TownSquare/30374_CandyHouse.lua
------------------------------------------------------------
]]

-- create class
local libName = "CandyHouse";
local CandyHouse = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.CandyHouse", CandyHouse);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;


function CandyHouse.main()
end

function CandyHouse.PreDialog()
end
--return true if user has a candyhouse
function CandyHouse.HasCandyHouse()
	return hasGSItem(30135);
end
--return true if user has four items
function CandyHouse.CanExchange()
	return  hasGSItem(30136) and hasGSItem(30137) and hasGSItem(30138) and hasGSItem(30139);
end
--¶Ò»»
function CandyHouse.DoExchange()
	if(CandyHouse.HasCandyHouse() or not CandyHouse.CanExchange())then return end
	
	System.Item.ItemManager.ExtendedCost(403, nil, nil, function(msg)end, function(msg) 
		log("========= extendedcost in  CandyHouse.DoExchange()=========\n")
		commonlib.echo(msg);
	end);
	
end