--[[
Title:  GSL Cell based Grid Node Handlers 
Author(s): LiXizhi
Date: 2010/3/25
Desc: cell based message handlers for GSL_gridnode. Use GSL_gridnode_handlers.lua if one wants to use gridnode without cells. 
There is no need to use cells for small worlds like one or two hundred meters wide.   
We will only send real time and normal update to the 9 neighbouring cells where the current agent locates. 
Whenever agent revisit a cell, it will resend all cell revisions, this simplifies the code a lot 
at the cost of sending some duplicated updates within a short time.
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/GameServer/GSL_gridnode_handlers.lua");
-----------------------------------------------------------
]]
NPL.load("(gl)script/apps/GameServer/GSL.lua");
NPL.load("(gl)script/apps/GameServer/GSL_msg_def.lua");
NPL.load("(gl)script/apps/GameServer/GSL_history.lua");
NPL.load("(gl)script/apps/GameServer/GSL_serveragent.lua");

local GSL = commonlib.gettable("Map3DSystem.GSL");
local GSL_msg = commonlib.gettable("Map3DSystem.GSL.GSL_msg");
local agentstate = commonlib.gettable("Map3DSystem.GSL.agentstate");
local GridNode = commonlib.gettable("Map3DSystem.GSL.GridNode");

local GridNodeCellHandlers = commonlib.gettable("Map3DSystem.GSL.GridNodeCellHandlers");

NPL.load("(gl)script/apps/GameServer/GSL_opcode.lua");

-- real time message, we only update (do not reply)
function GridNodeCellHandlers.HandleCS_RealtimeUpdate(self, agent_from, msg)
	local nid = msg.nid;
	self.timeid = self.timeid + 1;
	if (type(msg.agent) == "table" and type(msg.agent.rt) == "string") then
		self:AddRealtimeMessage(nid, msg.agent.rt);
	end	
	if (type(msg.so) == "table") then
		local id, rt_msg;
		for id, rt_msg in pairs(msg.so) do
			local serverobj = self.ServerObjects[id];
			if(serverobj) then
				serverobj:OnNetReceive(nid, self, rt_msg, self.timeid);
			end
		end
	end
end

-- handle heart beat normal update received from client. 
function GridNodeCellHandlers.HandleCS_NormalUpdate(self, agent_from, msg)
	local nid = msg.nid;
	-- increased by one each time the server side agents are changed
	self.timeid = self.timeid + 1;
	
	if(msg.type == GSL_msg.CS_ObserverUpdate) then
		-- mark agent as observer
		agent_from.state = agentstate.observer;
	else
		-- mark as agent 
		agent_from.state = agentstate.agent;
	end
	-- add cid. this allows us to recover cid. 
	if(not agent_from.cid and msg.cid) then
		agent_from.cid = msg.cid;
	end

	--log("-------server received normal update\n")
	--commonlib.echo(msg)
	
	local out_msg = {
		type = GSL_msg.SC_NormalUpdate, 
		agents = {},
		ct = msg.ct, -- forward client time
	};

	-- Note: environment changes are ignored in this release
	--if(self:CanEdit() and msg.agent and msg.type == GSL_msg.CS_NormalUpdate) then
		---- get all creations since last update feedback
		--out_msg.creations = self.history:GetCreationsForClientAgent(agent_from, self.max_creations_per_msg)
		---- get all env updates since last update feedback
		--out_msg.env = self.history:GetEnvsForClientAgent(agent_from, self.max_env_per_msg)
		--
		---- update any object creations contained in the client update. 
		--self.history:AddCreations(msg.agent.creations, nid);
		--
		---- update any object env updates contained in the client update. 
		--self.history:AddEnvs(msg.agent.env, nid);
	--end	
		
	if (msg.agent and msg.agent.data) then
		-- actually the following line is not necessary, if server grid does not render the agent. 
		agent_from.gx, agent_from.gz = self.from_x, self.from_y;
		local old_x, old_y = agent_from.x, agent_from.y;
		agent_from:UpdateFromStream(msg.agent.data, self.timeid);
		
		if(old_x ~= agent_from.x or old_y ~= agent_from.y) then
			
		end
		--commonlib.log("----------------- update from stream.\n")
		--commonlib.log(msg.agent.data)
		--agent_from:print_history();
	end	
	
	if(msg.type == GSL_msg.CS_NormalUpdate) then
		if( not agent_from:IsIntact() ) then
			-- losing client info, so instead of forward msg.ct, we will sent nil back to client.
			out_msg.ct = nil;
			-- commonlib.log("warning: intact client %s is found, let us set the ct to nil\n", nid);
		end
	end	
		
	-- only send other agents if the client is not dummy(for lightweighted emulation users)
	if(not msg.dummy) then
		-- send all client agents updates to client
		local _, agent;
		local index = 1;
		local st = tonumber(msg.st);
		for _, agent in pairs(self.agents) do
			-- skip the sender, observer or logged out agent
			if(agent.nid~=nid and agent.state==agentstate.agent) then
				--commonlib.log("----------------- generate stream.\n")
				--commonlib.echo(st)
				--agent:print_history();
				
				local agentdata = agent:GenerateUpdateStream(st);
				
				local nid_name = agent.nid;
				if(nid_name) then
					if(agentdata) then
						out_msg.agents[nid_name] = agentdata;
					else
						-- Note: if agentdata is nil, add to msg.ping="nid,nid,nid"
						if(out_msg.ping == nil) then
							out_msg.ping = nid_name;
						else
							out_msg.ping = string.format("%s,%s", out_msg.ping, nid_name)
						end
					end	
				end	
				index = index + 1;
			end	
		end
		-- recover some agents on clients' request.
		if(type(msg.recover) == "string") then
			local count=0;
			local nid_name
			for nid_name in string.gmatch(msg.recover, "[^,]+") do	
				count = count+1;
				if(count<=self.maxrecoversize) then
					local agent = self.agents[nid_name];
					if(agent) then
						local agentdata = agent:GenerateUpdateStream(0);
						if(agentdata) then
							out_msg.agents[nid_name] = agentdata;
							-- commonlib.log(string.format("agent %s is recovered %s\n", nid_name, agentdata))
						end
					end	
				else
					break;	
				end	
			end
		end
		-- patch-send server objects to client
		local sid, serveragent
		for sid, serveragent in pairs(self.ServerObjects) do
			local patch_data = serveragent:GenerateNormalUpdateMessage(st);
			if(patch_data) then
				out_msg.so = out_msg.so or {};
				out_msg.so[sid] = patch_data;
			end
		end
	else
		-- for dummy agent, send all active agents ping to client
		out_msg.agents = nil;
		local _, agent;
		local index = 1;
		local st = tonumber(msg.st);
		for _, agent in pairs(self.agents) do
			-- skip the sender, observer or logged out agent
			if(agent.nid~=nid and agent.state==agentstate.agent) then
				local nid_name = agent.nid;
				if(nid_name) then
					-- Note: add to msg.ping="nid,nid,nid"
					if(out_msg.ping == nil) then
						out_msg.ping = nid_name;
					else
						out_msg.ping = string.format("%s,%s", out_msg.ping, nid_name)
					end
				end	
				index = index + 1;
			end	
		end
	end	
	
	-- reply to client.
	self:SendToClient(nid, out_msg, nil, msg.proxy);
end

-- CS_ObserverUpdate handler is the same as CS_NormalUpdate
GridNodeCellHandlers.HandleCS_ObserverUpdate = GridNodeCellHandlers.HandleCS_NormalUpdate;

-- handle logout
function GridNodeCellHandlers.HandleCS_Logout(self, agent_from, msg)
	-- mark as logout 
	agent_from:SignOut();
end

-- handle login: a client just request connection
function GridNodeCellHandlers.HandleCS_Login(self, agent_from, msg)
	local nid = msg.nid;
	if(not msg.worldpath) then return end
	
	local reply = {
		-- SC: InitGame: first and basic world information.
		type = GSL_msg.SC_Login_Reply, 
		worldpath = msg.worldpath,
		x=msg.x, y=msg.y, z=msg.z,
		-- forward the handler name
		handler = msg.handler,
		-- grid server nid
		gnid = self.nid,
		gid = self.id,
		-- grid tile pos
		gx = self.x, 
		gy = self.y,
		-- grid tile size
		gsize = self.size;
		Role = self.UserRole,
		OnlineUserNum = self.OnlineUserNum,
		StartTime = self.statistics.StartTime,
		VisitsSinceStart = self.statistics.VisitsSinceStart,
		ServerVersion = self.ServerVersion, 
		ClientVersion = self.ClientVersion, 
	}
	if(msg.proxy) then
		reply.proxy = {addr=GSL.gateway.config.addr}
	end
	-- sign in, so that we can send message to this agent. 
	agent_from:SignIn();
	-- remember the client id. 
	agent_from.cid = msg.cid;
	
	-- what will happen, if there is no valid connection to proxy.
	self:SendToClient(nid, reply, nil, msg.proxy);
end
