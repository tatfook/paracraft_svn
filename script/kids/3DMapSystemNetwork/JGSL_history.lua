--[[
Title:  JGSL Grid (grid server)
Author(s): LiXizhi
Date: 2008/8/3
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL_history.lua");
local history = Map3DSystem.JGSL.history:new();
------------------------------------------------------------
]]
if(not Map3DSystem.JGSL) then Map3DSystem.JGSL={}; end
------------------------------
-- History class
------------------------------
local history = {
	creations = {},
	env = {},
};
Map3DSystem.JGSL.history = history

function history:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	
	o.creations = {};
	o.env = {};
	return o
end

-- clear all history. call this function when a server restart.
function history:clear()
	self.creations = {};
	self.env = {};
end

-- add the total number of creations and env changes. 
function history:GetTotalCount()
	return #(self.creations) + #(self.env)
end

-- when the server receives some client updates that contains creations, it will save all clients' creations
-- to an array. At normal update time, the server will broadcast previous creations to the clients.
-- @param creations: an array of creation history
-- @param fromJID: who added this creations. 
function history:AddCreations(creations, fromJID)
	if(creations and #creations>0) then 
		local nOldSize = #(self.creations)
		local i;
		for i = 1, #creations do
			if(fromJID~=nil) then
				-- secretly change the author anyway.
				creations[i].fromJID = fromJID
			end	
			self.creations[nOldSize+i] = creations[i];
		end
	end
end

-- when the server receives some client updates that contains env updates, it will save all clients' creations
-- to an array. At normal update time, the server will broadcast previous envs to the clients.
-- @param env: an array of env history
-- @param fromJID: who added this env. 
function history:AddEnvs(env, fromJID)
	if(env and #env>0) then 
		local nOldSize = #(self.env)
		local i;
		for i = 1, #(env) do
			if(fromJID~=nil) then
				-- secretly change the author anyway.
				env[i].fromJID = fromJID
			end	
			self.env[nOldSize+i] = env[i];
		end
	end	
end


-- get an array of creations from the server creation history.
-- @param agent:  the agent for whom creations will be retrieved. In fact, it will return all creations 
-- who time is larger than agent.LastCreationHistoryTime, and whose agent.fromJID is different from the one in creation history.
-- @param MaxCount: nil or max number of creations to return. This prevents sending too many in a single message. 
-- @return: return nil or an array of creations for sending back to the client agent
function history:GetCreationsForClientAgent(agent, MaxCount)
	agent.LastCreationHistoryTime = agent.LastCreationHistoryTime or 0;
	local i;
	local Count = #(self.creations) - agent.LastCreationHistoryTime;
	if(MaxCount~=nil and Count>MaxCount) then
		Count = MaxCount;
	end
	local creations;
	for i = 1, Count do
		local new_msg = self.creations[i+agent.LastCreationHistoryTime];
		if(new_msg.fromJID ~= agent.JID) then
			if(creations == nil) then
				creations = {};
			end
			creations[#creations+1] = new_msg
		end	
	end
	agent.LastCreationHistoryTime = agent.LastCreationHistoryTime+Count;
	
	return creations;
end


-- get an array of creations from the server creation history.
-- @param agent:  the agent for whom creations will be retrieved. In fact, it will return all creations 
-- who time is larger than agent.LastEnvHistoryTime, and whose agent.fromJID is different from the one in creation history.
-- @param MaxCount: nil or max number of creations to return. This prevents sending too many in a single message. 
-- @return: return nil or an array of creations for sending back to the client agent
function history:GetEnvsForClientAgent(agent, MaxCount)
	agent.LastEnvHistoryTime = agent.LastEnvHistoryTime or 0;
	local i;
	local Count = #(self.env) - agent.LastEnvHistoryTime;
	if(MaxCount~=nil and Count>MaxCount) then
		Count = MaxCount;
	end
	local env;
	for i = 1, Count do
		local new_msg = self.env[i+agent.LastEnvHistoryTime];
		if(new_msg.fromJID ~= agent.JID) then
			if(env == nil) then
				env = {};
			end
			env[#env+1] = new_msg
		end	
	end
	agent.LastEnvHistoryTime = agent.LastEnvHistoryTime+Count;
	
	return env;
end

