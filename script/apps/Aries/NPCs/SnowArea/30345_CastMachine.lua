--[[
Title: CastMachine
Author(s): Leio
Date: 2010/01/18

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/SnowArea/30345_CastMachine.lua
------------------------------------------------------------
]]

-- create class
local libName = "CastMachine";
local CastMachine = {
	selected_index = nil,
	page_state = 0,
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.CastMachine", CastMachine);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- CastMachine.main
function CastMachine.main()
	local self = CastMachine; 
end

function CastMachine.PreDialog(npc_id, instance)
	local self = CastMachine; 
	NPL.load("(gl)script/apps/Aries/NPCs/SnowArea/30345_CastMachine_panel.lua");
	MyCompany.Aries.Quest.NPCs.CastMachine_panel.ShowPage();
	return false;
end