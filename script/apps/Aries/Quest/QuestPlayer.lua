--[[
Title: Quest Player
Author(s): LXZ for leio
Date: 2010/8/21
Desc: Keeps per-player data and API for quest system. 
This is the main API class used by QuestServer. 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Quest/QuestPlayer.lua");
------------------------------------------------------------
]]

local QuestLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestLogics");

-- create class
local QuestPlayer = commonlib.gettable("MyCompany.Aries.Quest.QuestPlayer");
QuestPlayer.nid = nil;
function QuestPlayer:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	
	-- o.nid = tostring(o.nid);
	return o
end

-- this is usually indirectly called by the combat system to inform the player that it has just killed a monstor
function QuestPlayer:AddKillMonstor(monstor_id)
end

-- this is usually indirectly called by the combat system to inform the player that it has just collected some server objects 
function QuestPlayer:AddCollectObject(object_id)
end

function QuestPlayer:GetNID()
	return self.nid;
end
function QuestPlayer:SetNID(v)
	self.nid = v;
end
function QuestPlayer:GetQuestListByStartNpc(npcid)
	if(not npcid)then return end
	local list = QuestLogics.GetQuestListByStartNpc(self.nid,npcid);
	return list;
end