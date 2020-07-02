--[[
Title:  GSL Grid Node Handlers
Author(s): LiXizhi
Date: 2008/8/3
Desc: default message handlers for GSL_gridnode.
One can register other gridnode handlers to define game specific behaviors. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/GameServer/GSL_gridnode_handlers.lua");
-----------------------------------------------------------
]]
NPL.load("(gl)script/apps/GameServer/GSL.lua");
NPL.load("(gl)script/apps/GameServer/GSL_msg_def.lua");
NPL.load("(gl)script/apps/GameServer/GSL_history.lua");
NPL.load("(gl)script/apps/GameServer/GSL_serveragent.lua");
local system = commonlib.gettable("Map3DSystem.GSL.system");

local GSL = commonlib.gettable("Map3DSystem.GSL");
local GSL_msg = commonlib.gettable("Map3DSystem.GSL.GSL_msg");
local agentstate = commonlib.gettable("Map3DSystem.GSL.agentstate");
local GridNode = commonlib.gettable("Map3DSystem.GSL.GridNode");
local GridNodeHandlers = commonlib.gettable("Map3DSystem.GSL.GridNodeHandlers");
local gateway = commonlib.gettable("Map3DSystem.GSL.gateway");
local gridnode_manager = commonlib.gettable("Map3DSystem.GSL.gridnode_manager");
local PowerItemManager = commonlib.gettable("Map3DSystem.Item.PowerItemManager");

local pairs = pairs
local ipairs = ipairs
local tostring = tostring
local tonumber = tonumber
local type = type
local string_format = string.format;
local format = format;

NPL.load("(gl)script/apps/GameServer/GSL_opcode.lua");

-- real time message, we only update (do not reply)
function GridNodeHandlers.HandleCS_RealtimeUpdate(self, agent_from, msg)
	local nid = msg.nid;
	local timeid = self.timeid + 1; 
	self.timeid = timeid;
	if (type(msg.agent) == "table") then
		-- in case there is agent update we will update the local struct
		if (msg.agent.data) then
			agent_from:UpdateFromStream(msg.agent.data, self.timeid);

			if(not self.is_persistent or agent_from:ServerValidate(self.timeid)) then
				-- only validate if not persistent
				self:AddRealtimeMessage(nid, msg.agent.data);
			end
		end	
		if (type(msg.agent.rt) == "string") then
			self:AddRealtimeMessage(nid, msg.agent.rt);
		end
	end	

	if (type(msg.so) == "table") then
		local id, rt_msg;
		for id, rt_msg in pairs(msg.so) do
			local serverobj = self.ServerObjects[id];
			if(serverobj) then
				local nCount = #rt_msg;
				if(nCount >= 1) then
					serverobj:OnNetReceive(nid, self, rt_msg[1], timeid);
					if(nCount >= 2) then
						local i;
						for i = 2, nCount do
							serverobj:OnNetReceive(nid, self, rt_msg[i], timeid);
						end
					end
				end
			end
		end
	end
end

-- get agent item data
function GridNodeHandlers.HandleCS_GetItem(self, agent_from, msg)
	--LOG.std(nil, "debug", "gridnode CS_GetItem ", msg);
	local nid = msg.nid;
	if(msg.agent_nid and msg.fields) then
		local agent = self:FindAgent(msg.agent_nid);
		if(agent) then
			local data = {};
			local _, keyname
			for _, keyname in pairs(msg.fields) do
				data[keyname] = agent:GetItem(keyname);
			end
			-- send back immediately. reply to client.
			self:SendToClient(nid, {
					agent_id = msg.agent_nid,
					type = GSL_msg.SC_GetItem, 
					data = data,
					ct = msg.ct,
					cid = msg.cid, -- forward client time
				}, nil, msg.proxy);
		end
	end
end

-- set agent item data
function GridNodeHandlers.HandleCS_SetItem(self, agent_from, msg)
	--LOG.std(nil, "debug", "gridnode CS_SetItem ", msg);
	local nid = msg.nid;
	if(msg.data) then
		local agent = self:FindAgent(nid);
		if(agent) then
			local name, value;
			for name, value in pairs(msg.data) do
				agent:SetItem(name, value);
			end
		end
	end
end

-- handle heart beat normal update received from client. 
function GridNodeHandlers.HandleCS_NormalUpdate(self, agent_from, msg)
	local nid = msg.nid;

	-- check the primary grid node in case the server already signed out the user while the client thinks it is connected. 
	local grid_node = gateway:GetPrimGridNode(nid);
	if(grid_node ~= self) then
		if(grid_node == nil) then
			LOG.std(nil, "debug", "GSL", "gridnode found unsigned user %s during normal update", tostring(nid));
			-- tricky: we will reset client time to force client to send full user info the next time. 
			-- this will fix a bug where an agent lost its css info. 
			msg.ct = nil;
			-- we will signin the user once again. 
			local delay_reply = GridNodeHandlers.GridNodeLogin(self, agent_from, msg);
			if(delay_reply) then
				delay_reply.DoReply = function() 
					self:SendToClient(nid, {
							type = GSL_msg.SC_Login_Recover, 
							ct = msg.ct, -- forward client time
							cid = msg.cid,
						}, nil, msg.proxy);
					LOG.std(nil, "debug", "GSL", "gridnode resigned in client user %s", tostring(nid));
				end
			end
		else
			return
		end
	end

	-- increased by one each time the server side agents are changed
	self.timeid = self.timeid + 1;
	
	-- add cid. this allows us to recover cid. 
	if(not agent_from.cid and msg.cid) then
		agent_from.cid = msg.cid;
	end

	if(msg.type == GSL_msg.CS_ObserverUpdate) then
		-- mark agent as observer
		agent_from.state = agentstate.observer;
	else
		-- mark as agent 
		agent_from.state = agentstate.agent;
	end
	
	--log("-------server received normal update\n")
	--commonlib.echo(msg)
	
	local out_msg = {
		type = GSL_msg.SC_NormalUpdate, 
		agents = {},
		ct = msg.ct, -- forward client time
		stime = gridnode_manager.srvtime, -- send the server time(just for time keeping) 
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
		agent_from:UpdateFromStream(msg.agent.data, self.timeid);
		if(self.is_persistent) then
			-- only validate if not persistent
			agent_from:ServerValidate(self.timeid);
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
							out_msg.ping = format("%s,%s", out_msg.ping, nid_name)
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
							-- commonlib.log(format("agent %s is recovered %s\n", nid_name, agentdata))
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
						out_msg.ping = format("%s,%s", out_msg.ping, nid_name)
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
GridNodeHandlers.HandleCS_ObserverUpdate = GridNodeHandlers.HandleCS_NormalUpdate;

-- handle logout
function GridNodeHandlers.HandleCS_Logout(self, agent_from, msg)
	-- mark as logout 
	agent_from:SignOut();
	self:KickAgent(agent_from.nid);
	LOG.std(nil, "debug", "GSL", "user %s logs out gridnode %s gracefully", agent_from.nid, self.id);
end

-- handle login: a client just request connection
function GridNodeHandlers.HandleCS_Login(self, agent_from, msg)
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
		OnlineUserNum = self:GetAgentCount(),
		StartTime = self.statistics.StartTime,
		VisitsSinceStart = self.statistics.VisitsSinceStart,
		ServerVersion = self.ServerVersion, 
		ClientVersion = self.ClientVersion, 
		-- info the client whether the server is started. If not, the client game logics may stop the user 
		is_started = self.is_started,
	}
	if(msg.proxy) then
		reply.proxy = {addr=GSL.gateway.config.addr}
	end

	local function OnLoginFinished_()
		if(self.ticket_gsid) then
			if(self.user_tickets and self.user_tickets[nid]) then
				-- user already has ticket, so go on
				LOG.std(nil, "user", "gridnode", "ticket gsid %s is reused for user %s when login world %s", self.ticket_gsid, nid, msg.worldpath or "");
			else
				reply.ticket_gsid = self.ticket_gsid;
				local hasTicket, guid = PowerItemManager.IfOwnGSItem(nid, self.ticket_gsid);
				if(not hasTicket)then
					-- no ticket
					reply.no_ticket = true;
					LOG.std(nil, "user", "gridnode", "Refused: no ticket gsid %s for user %s when login world %s", self.ticket_gsid, nid, msg.worldpath or "");
				else
					-- destroy one ticket for each login, we do not need to wait for this function to return before allowing the user to login. 
					PowerItemManager.DestroyItem(nid, guid, 1, function(msg)
						if(msg and msg.issuccess) then
							LOG.std(nil, "user", "gridnode", "ticket gsid %s is destroyed for user %s when login world %s", self.ticket_gsid, nid, msg.worldpath or "");
							self.user_tickets = self.user_tickets or {};
							self.user_tickets[nid] = true;
						end
					end);
				end
			end
		end
		if(not reply.no_ticket) then
			-- sign in, so that we can send message to this agent. 
			agent_from:SignIn(); -- sign in as an agent, so that real time messages can be sent immediately. 
		end
		-- what will happen, if there is no valid connection to proxy.
		self:SendToClient(nid, reply, nil, msg.proxy);	
	end

	local delay_reply = GridNodeHandlers.GridNodeLogin(self, agent_from, msg);
	if(delay_reply) then
		delay_reply.DoReply = OnLoginFinished_;
	else
		OnLoginFinished_();
	end
end

local msg_OnUserLoginWorld = {type="OnUserLoginWorld", nid, worldpath}
-- call this function when a user first login a grid node or reconnected with a gridnode.
-- return nil or delay_reply table, where delay_reply.DoReply can be assigned with a callback function, 
-- which will be called when all services completed the login procedure. 
function GridNodeHandlers.GridNodeLogin(self, agent_from, msg)
	local nid = msg.nid;
	
	-- sign in, so that we can send message to this agent. 
	-- agent_from:SignIn(); -- sign in as an agent, so that real time messages can be sent immediately. 

	-- remember the client id. 
	agent_from.cid = msg.cid;
	
	-- keep the most recent logged in gridnode as primary grid node for the user in the gateway. 
	gateway:SetPrimGridNode(nid, self)

	-- fire a system message 
	msg_OnUserLoginWorld.nid = nid;
	msg_OnUserLoginWorld.worldpath= msg.worldpath;
	system:FireEvent(msg_OnUserLoginWorld);
	
	local delay_reply = msg_OnUserLoginWorld.delay_reply;
	msg_OnUserLoginWorld.delay_reply = nil;
	return delay_reply;
end