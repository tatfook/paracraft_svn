--[[
Title: Aries quest NPC AI memory
Author(s): WangTian
Date: 2009/7/21

Desc: AI memories for NPC

use the lib:

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Quest/NPCAIMemory.lua");
------------------------------------------------------------
]]

NPL.load("(gl)script/apps/Aries/Quest/main.lua");

-- create class
local libName = "NPCAI";
local NPCAI = commonlib.gettable("MyCompany.Aries.Quest.NPCAI");

-- create class
local libName = "NPCAIMemory";
local NPCAIMemory = commonlib.gettable("MyCompany.Aries.Quest.NPCAIMemory");

-- a table holding temporary memory of NPCs. e.g. NPCAIMemory.memory[30004] = {sequence_number = 1,Task1 = "Done"};
NPCAIMemory.memory = {}; 

-- get temperary memory of a given NPC
-- @param npc_id: NPC id
-- @return: memory table
function NPCAIMemory.GetMemory(npc_id)
	local mem = NPCAIMemory.memory[npc_id];
	if(mem == nil) then
		mem = {};
		NPCAIMemory.memory[npc_id] = mem;
	end
	return mem;
end

-- get temperary memory of a given NPC
-- @param npc_id: NPC id
-- @return: memory table
function NPCAIMemory.ClearMemory(npc_id)
	NPCAIMemory.memory[npc_id] = {};
end