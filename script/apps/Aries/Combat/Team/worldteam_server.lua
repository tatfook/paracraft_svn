--[[
Title: server file for per world temporary team 
Author(s):  LiXizhi
Date: 2010/11/24
Desc: When a user joins an instance world, it immediately become a team member of that specific world. 
The first user joining the team is usually the team leader. 
The team leader is able to declare start of the level. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Combat/Team/worldteam_server.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/GameServer/GSL_config.lua");

local format = format;
local type = type;
local tonumber, tostring = tonumber, tostring;
local LOG = LOG;
-- create class
local worldteam_server = {};

-- register NPC template
Map3DSystem.GSL.config:RegisterNPCTemplate("aries_worldteam_system", worldteam_server);
function worldteam_server.CreateInstance(self, revision)
	-- overwrite virtual functions
	self.OnNetReceive = worldteam_server.OnNetReceive;
	self.OnFrameMove = worldteam_server.OnFrameMove;
	self.OnActivate = worldteam_server.OnActivate;
	self.OnDestroy = worldteam_server.OnDestroy;
end
-- whenever an instance of this server agent has received a real time message from client (from_nid) in gridnode, this function will be called.  
function worldteam_server:OnNetReceive(from_nid, gridnode, msg, revision)
	if(from_nid and gridnode and type(msg) == "table") then
		if(msg.type == "StartGame") then
			if(not self:GetValue("IsStarted")) then
				worldteam_server.StartGame(self, revision);
			end
		end
	end
end

function worldteam_server:StartGame(revision)
	self.gridnode.is_started = true;
	self:SetValue("IsStarted", true, revision);
end

-- This function is called by gridnode at normal update interval. One can update persistent data fields in this functions. 
function worldteam_server:OnFrameMove(curTime, revision)
	if(not self.nextupdate_time or curTime > self.nextupdate_time) then
		-- at least five seconds. 
		self.nextupdate_time = curTime + 5000;
		local gridnode = self.gridnode;

		local agent_count = gridnode:GetAgentCount();

		if(not gridnode.is_started and gridnode.MaxStartUser) then
			if(agent_count>=1 and agent_count <gridnode.MinStartUser) then
				-- tell the user that there is not enough player, so wait. 
				self:AddRealtimeMessage({type="TickWait", agent_count = agent_count });
			elseif(agent_count>=gridnode.MinStartUser) then
				if(agent_count < gridnode.MaxStartUser) then
					-- inform the team leader to start or wait. 
					-- tell all user that game is started. 
					self:AddRealtimeMessage({type="TickStart", agent_count = agent_count });
				else
					-- force start the level, since the team is full.
					worldteam_server.StartGame(self, revision);
				end
			end
		end
	end
end

-- this function is called whenever the parent gridnode is made from unactive to active mode or vice versa. 
-- A gridnode is made inactive by its gridnode manager whenever all client agents are left, so it calls this 
-- function and put the gridnode to cache pool for reuse later on. 
-- Whenever a gridnode is first loaded or activated again, this function will also be called. 
-- @param bActivate: true if gridnode is active or false if unactive. 
function worldteam_server:OnActivate(bActivate)
	if(not bActivate) then
		-- when there is no user, make not started.
		self.gridnode.is_started = false;
		self:RemoveValue("IsStarted");
		-- LOG.std(nil, "debug", "worldteam", "gridnode is set to not started.")
	end
end

-- This function is called by gridnode before the server object is actually destroyed and set to nil
function worldteam_server:OnDestroy()
end
