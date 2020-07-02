--[[
Title: MoveHouseCar
Author(s): Leio
Date: 2010/02/01

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/TownSquare/30349_MoveHouseCar.lua
------------------------------------------------------------
]]

-- create class
local libName = "MoveHouseCar";
local MoveHouseCar = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.MoveHouseCar", MoveHouseCar);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- MoveHouseCar.main
function MoveHouseCar.main()
end
function MoveHouseCar.PreDialog(npc_id, instance)
	NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30349_MoveHouseCar_panel.lua");
	MyCompany.Aries.Quest.NPCs.MoveHouseCar_panel.ShowPage();
	return false;
end
