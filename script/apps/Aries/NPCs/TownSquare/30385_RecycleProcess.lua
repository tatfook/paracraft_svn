--[[
Title: RecycleProcess
Author(s): Leio
Date: 2010/02/01

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/TownSquare/30385_RecycleProcess.lua
------------------------------------------------------------
]]

-- create class
local libName = "RecycleProcess";
local RecycleProcess = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.RecycleProcess", RecycleProcess);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- RecycleProcess.main
function RecycleProcess.main()
end
function RecycleProcess.PreDialog(npc_id, instance)
	NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30385_RecycleProcess_panel.lua");
	MyCompany.Aries.Quest.NPCs.RecycleProcess_panel.ShowPage();
	return false;
end
