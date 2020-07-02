--[[
Title:  GSL Grid Node
Author(s): LiXizhi
Date: 2008/8/3
Desc: GSL_gridnode is responsible for simulation of a portion or all of a given game world. 
GSL_grid and GSL_homegrid are two grid nodes managers, they allocate instances of GSL_gridnode on demand according to different rules. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/GameServer/GSL_gridnode.lua");
local GridNode = commonlib.gettable("Map3DSystem.GSL.GridNode");
GridNode:HandleMessage(msg, curTime)
GridNode:OnFrameMove(curTime)
GridNode:OnTimer(curTime)
-----------------------------------------------------------
]]
NPL.load("(gl)script/apps/GameServer/GSL.lua");
NPL.load("(gl)script/apps/GameServer/GSL_msg_def.lua");
NPL.load("(gl)script/apps/GameServer/GSL_history.lua");
NPL.load("(gl)script/apps/GameServer/GSL_serveragent.lua");
NPL.load("(gl)script/apps/GameServer/GSL_gridnode_handlers.lua");
NPL.load("(gl)script/apps/GameServer/GSL_gridnode_cells.lua");

local CellManager = commonlib.gettable("Map3DSystem.GSL.CellManager");
local GSL = commonlib.gettable("Map3DSystem.GSL");
local GSL_msg = commonlib.gettable("Map3DSystem.GSL.GSL_msg");
local agentstate = commonlib.gettable("Map3DSystem.GSL.agentstate");
local GridNode = commonlib.gettable("Map3DSystem.GSL.GridNode");
local GridNodeHandlers = commonlib.gettable("Map3DSystem.GSL.GridNodeHandlers");
local gateway = commonlib.gettable("Map3DSystem.GSL.gateway");
local LOG = LOG;
local type = type;
NPL.load("(gl)script/apps/GameServer/GSL_opcode.lua");

-- default neuron files for client and server. 
local DefaultClientFile = "script/apps/GameServer/GSL_client.lua";


------------------------------
-- Grid Node
------------------------------

-- a grid node is responsible for simulation of a portion or all of a given game world. 
commonlib.partialcopy(GridNode, {
	-- OBSOLETED session key not needed now: server session key, it is regenerated each time a grid node is created or reset, or the underlying game world changes.
	sk = ParaGlobal.GenerateUniqueID(), 
	-- grid node id
	id = nil,
	-- url string is the unique search key of this grid node, such as "self.worldpath?x=self.x&y=self.y[&][nid=self.nid]"
	url = nil,
	-- the world path that this grid node is hosting.
	worldpath = nil,
	-- grid tile pos, it marks the simulation region within the self.worldpath. 
	-- from (x*size, y*size) to (x*size+size, y*size+size)
	x=nil,
	y=nil,
	-- grid tile size, if nil, it means infinite size. we always return the smallest sized grid server 
	size=nil,
	-- the default role assigned to any incoming users. 
	UserRole="guest",
	-- server version
	ServerVersion = 1,
	-- required client version
	ClientVersion = 1,
	-- grid configuration file
	configfile = nil,
	
	-- Map3DSystem.GSL.history: contains all client and server agent creation and environmental action history. 
	history = nil,
	-- clear the history when the creation has reached this number of times. If this is nil, all history are kept. 
	clear_history_count = 30,
	
	-- max number of creations in a message
	max_creations_per_msg = 5,
	-- max number of env updates in a message
	max_env_per_msg = 5,
	-- VIP ATTRIBUTE: max number of connected users allowed in this grid, this is total number of agents and observers. 
	-- TODO:  when there are more than GSL_homegrid.max_users on a single server, and when a nid client leaves a such a over crowded grid node and reenters again. the client will receive nothing. 
	max_users = 500,
	
	-- if a client is not sending us any message in 10 seconds, we will make it inactive user and remove from active user list. 
	ClientTimeOut = 30000,
	-- a new character will be located at radius = miniSpawnRadius+math.sqrt(OnlineUserNum+1)*3;
	miniSpawnRadius = 5,
	-- When the server has broadcasted this number of objects, the server will be automatically restarted; this is usually the setting for testing public server.
	RestartOnCreateNum = tonumber(ParaEngine.GetAppCommandLineByParam("RestartOnCreateNum", "0")),
	
	-- we will recover at most maxrecoversize number of intact client agent request at a time. 
	maxrecoversize = 5,
	
	-- mapping from server object id(string) to server object(usually derived class of GSL_serveragent) table. 
	-- For each grid node, we need to load NPC within the region, currently NPC in a given world is described in GSL.config.xml rule files.  
	-- For NPC, creatures and dropped items, they are treated as a special kind of agent(GSL_serveragent) in ServerObjects table. 
	-- Please see, GSL_serveragent for more information. 
	ServerObjects = nil,
	
	-- client agents or observers on server, where agents[nid] = {agent}.
	agents = {},
	-- current agent count including both timed out or active. 
	agent_count = 0,
	
	-- increased by one each time a normal update is replied, this is sometimes called revision number in other code. 
	timeid = 1,
	
	-- a pool of real time messages. Each time the server receives a real time message from an agent, it will append the message string to realtime_msg[agent.nid]. 
	-- during the next server real time update interval, the server just boardcasts all real time messages to all agents in the world. 
	realtime_msg = {},
	-- number of combined nid messages in realtime_msg
	realtime_msgcount = 0,
	
	--realtime_msg_history = nil,
	--realtime_msg_history_count = 10,
	
	-- node statistics 
	statistics = {
		-- strange: LXZ 2008.12.25: ParaGlobal.GetDateFormat(nil) returns invalid XML char code. just ignore it for now. 
		StartTime = nil, -- commonlib.Encoding.DefaultToUtf8(ParaGlobal.GetDateFormat(nil)..ParaGlobal.GetTimeFormat(nil)),
		OnlineUserNum = 0,
		VisitsSinceStart = 0,
		NumObjectCreated = 0,
	},
	-- increased by one when framemove is called. usually there is one tick every 0.33 seconds. 
	tick_count = 0,
	-- increased by one only when server is empty. 
	empty_tick_count = 0,
	-- how many ticks to wait until a timeout check is performed. (timeout_check_ticks * GSL_grid.TimeInterval) is the actual inteval.
	timeout_check_ticks = 10, 
	-- how many ticks to wait until a frame move of all server objects are performed. (timeout_check_ticks * GSL_grid.TimeInterval) is the actual inteval.
	framemove_check_ticks = 5, 
	-- close the server if it has been empty for this number of ticks. 
	close_server_ticks = 100,
	-- if true, onframemove will always return true, so that this gridnode will never be closed even if close_server_ticks has passed. 
	is_persistent = nil,
});

------------------------------
-- public function
------------------------------

function GridNode:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	
	o.history = Map3DSystem.GSL.history:new();
	o.timeid = 1;
	o.msg_handlers = {};
	o:Reset();
	return o
end

-- release a grid node. 
function GridNode:Release()
end

-- check whether this grid node allow users to edit the world
-- @param rule: if nil, it means  editing right. 
function GridNode:CanEdit()
	return (self.UserRole~="guest");
end

-- output log
function GridNode:log(...)
	commonlib.log(...)
end

-- regenerate session and become a new server. This is usually called by Map3DSystem.GSL.Reset()
-- call this to reset the server to inital disconnected state where there is a new session key, no history, no timer, no agents. 
function GridNode:Reset()
	-- regenerate session key 
	self.sk = ParaGlobal.GenerateUniqueID();
	-- clear agents
	self.agents = {};
	-- clear world path to make it empty. 
	self.worldpath = nil;
	-- simulation region within the self.worldpath. 
	self.x, self.y, self.size = nil,nil,nil;
	-- these are computed on demand
	self.from_x, self.from_y, self.to_x, self.to_y = nil,nil,nil,nil;
	-- the current runtime name is the world server id. 
	self.ws_id = __rts__:GetName();
	
	self.ServerObjects = {};
	self.realtime_msg = {};
	self.realtime_msgcount = 0;
	self.tick_count = 0;
	self.empty_tick_count = 0;
	self.agent_count = 0;
	-- clear history
	self.history:clear();
	-- only send creation messages from this time. 
	self.LastCreationHistoryTime = nil;
	-- only send env messages from this time. 
	self.LastEnvHistoryTime = nil;
	self.statistics = {
		StartTime = nil,
		OnlineUserNum = 0,
		VisitsSinceStart = 0,
		NumObjectCreated = 0,
	};
end

-- call this function is the framemove. 
-- close the node, if there are no agents or observers in it and it has been alive
-- @return true if grid node is still active. or nil if no agents in the grid node
function GridNode:TickClose()
	if(self.agent_count <= 0) then
		-- server is empty now
		if(not self.is_persistent) then
			if(self.empty_tick_count > self.close_server_ticks) then
				-- self:Reset();
				-- LOG.std(nil, "debug", "GSL", "grid node %s (%d) is empty, and may be closed",self.worldpath, self.id);
				return nil;
			else
				self.empty_tick_count = self.empty_tick_count + 1;
			end
		else
			-- for persistent world, no need to close
		end
		
	else
		-- server is NOT empty
		self.empty_tick_count = 0;	
	end
	return true;
end


-- load the grid node from a config structure, but does not reset 
-- @param config: a table of {worldpath, x,y,size, UserRole, npc_file, use_cell}
function GridNode:Load(config)
	if(config.worldpath) then
		self.worldpath = config.worldpath;
	end
	if(config.x and config.y) then
		if(config.size) then
			self.x, self.y, self.size = config.x, config.y, config.size;
			-- compute the others. 
			self.from_x= self.x * self.size;
			self.from_y= self.y * self.size;
			self.to_x= self.from_x + self.size;
			self.to_y= self.from_y + self.size;
		else
			self.x, self.y = config.x, config.y;
			self.from_x = self.x;
			self.from_y = self.y;
		end	
	end
	self.use_cell = config.use_cell;
	self.is_persistent = config.is_persistent;
	
	-- frame move ticks
	self.timeout_check_ticks = config.timeout_check_ticks or self.timeout_check_ticks;
	self.framemove_check_ticks = config.framemove_check_ticks or self.framemove_check_ticks;
	self.close_server_ticks = config.close_server_ticks or self.close_server_ticks;
	self.max_users = config.max_users or self.max_users;
	self.MinStartUser = config.MinStartUser; 
	self.MaxStartUser = config.MaxStartUser;
	if(self.MaxStartUser) then
		self.is_started = false;
	end
	self.ticket_gsid = config.ticket_gsid;

	if(self.use_cell) then
		-- use cell based handlers. 
		self.cell_manager = CellManager:new({gridnode = self, cellsize = 64,})
		self:RegisterMessageHandler(GSL_msg.CS_RealtimeUpdate, GridNodeCellHandlers.HandleCS_RealtimeUpdate);
		self:RegisterMessageHandler(GSL_msg.CS_NormalUpdate, GridNodeCellHandlers.HandleCS_NormalUpdate);
		self:RegisterMessageHandler(GSL_msg.CS_ObserverUpdate, GridNodeCellHandlers.HandleCS_ObserverUpdate);
		self:RegisterMessageHandler(GSL_msg.CS_Logout, GridNodeCellHandlers.HandleCS_Logout);
		self:RegisterMessageHandler(GSL_msg.CS_Login, GridNodeCellHandlers.HandleCS_Login);
	else
		self.cell_manager = nil;
		-- use standard handlers. 
		self:RegisterMessageHandler(GSL_msg.CS_RealtimeUpdate, GridNodeHandlers.HandleCS_RealtimeUpdate);
		self:RegisterMessageHandler(GSL_msg.CS_NormalUpdate, GridNodeHandlers.HandleCS_NormalUpdate);
		self:RegisterMessageHandler(GSL_msg.CS_ObserverUpdate, GridNodeHandlers.HandleCS_ObserverUpdate);
		self:RegisterMessageHandler(GSL_msg.CS_GetItem, GridNodeHandlers.HandleCS_GetItem);
		self:RegisterMessageHandler(GSL_msg.CS_SetItem, GridNodeHandlers.HandleCS_SetItem);
		self:RegisterMessageHandler(GSL_msg.CS_Logout, GridNodeHandlers.HandleCS_Logout);
		self:RegisterMessageHandler(GSL_msg.CS_Login, GridNodeHandlers.HandleCS_Login);
	end

	-- Load npc instances from npc_file
	if(config.npc_file) then
		for npc_id, npc in pairs(config.npc_file.npcs) do
			self:AddServerObject(npc_id, npc:create(self.timeid, self));
		end
	end
	if(config.UserRole) then
		self.UserRole = config.UserRole;
	end
end

-- see if user has ticket. For free world, this function always returns true. 
function GridNode:UserHasTicket(nid)
	if(not self.ticket_gsid or (self.user_tickets and self.user_tickets[tostring(nid)])) then
		return true;
	end
end


-- this function is called whenever the gridnode is made from unactive to active mode or vice versa. 
-- A gridnode is made inactive by its gridnode manager whenever all client agents are left, so it calls this 
-- function and put the gridnode to cache pool for reuse later on. 
-- Whenever the a gridnode is first loaded or activated again, this function will also be called. 
-- @param bActivate: true if gridnode is active or false if unactive. 
function GridNode:OnActivate(bActivate)
	-- clear all user tickets
	self.user_tickets = nil;

	-- inform all server objects. 
	if(self.ServerObjects) then
		local sid, serveragent
		for sid, serveragent in pairs(self.ServerObjects) do
			serveragent:OnActivate(bActivate);
		end
	end
end

-- add a server world object. 
-- @param npc_id: npc id
-- @param npc_object: the npc object. 
function GridNode:AddServerObject(npc_id, npc_object)
	self.ServerObjects = self.ServerObjects or {};
	self.ServerObjects[npc_id] = npc_object;	
	
	if(self.cell_manager) then
		self.cell_manager:RelocateServerObject(npc_object);
	end
end

-- get a server world object. 
-- @param npc_id: npc id
function GridNode:GetServerObject(npc_id)
	if(self.ServerObjects and npc_id) then
		return self.ServerObjects[npc_id]
	end
end

-- return true if there is still available slots for more users to join. 
function GridNode:CanJoin()
	if(self.MaxStartUser and not self.is_started) then
		return (self.agent_count < self.MaxStartUser);
	end
end
------------------------------
-- private functions
------------------------------

-- it will create the agent structure if it does not exist
function GridNode:GetAgent(nid)
	if(not nid) then return end
	local agent = self.agents[nid];
	if(not agent) then
		agent = self:CreateAgent(nid)
	end
	return agent;
end

-- Find agent by nid
-- @param nid: should be string. 
-- @return nil or the agent object.
function GridNode:FindAgent(nid)
	return self.agents[nid];
end

-- create an agent. it will overwrite existing one, if any, with a newly created one. 
function GridNode:CreateAgent(nid)
	local agent = GSL.agent:new{nid = nid};
	self.agents[nid] = agent;
	self.agent_count = self.agent_count + 1;
	return agent;
end

-- whether the grid node has reached maximum number of connected users allowed. 
function GridNode:IsFull()
	return (self.agent_count >= self.max_users)
end

-- whether the grid node is empty. 
function GridNode:IsEmpty()
	return (self.agent_count == 0) and (self.worldpath == nil);
end

-- get active agent count
function GridNode:GetAgentCount()
	return self.agent_count;
end

-- whether this grid node contains the 3d point x,y,z in worldpath
function GridNode:Contains(worldpath,x,y,z)
	if(self.worldpath == worldpath) then
		if(self.size and self.from_x) then
			return (self.from_x<=x and self.to_x>x and self.from_y<=z and self.to_y>z);
		else
			return true;
		end
	end
end

-- send a message to client
-- @param nid: the nid of a client. If this is nil. Messages is sent to all active clients.
-- @param neuronfile: if nil, the DefaultClientFile is used
-- @param proxy: this is ususlly nil. or it can be a table like {addr="(w1)server1"}, in which case messages are send to the nid via a given proxy server. 
--  please note, the proxy server must has an authenticated connection to nid in advance in order for the message to be sent successfully.
--  currently, chained proxies are not supported yet. we may support it in future. 
-- @return true if successfully send
function GridNode:SendToClient(nid, msg, neuronfile, proxy)
	if(GSL.dump_server_msg) then
		LOG.std("", "info", "GSL", "GridNode:SendToClient"..LOG.tostring(msg));
	end
	-- inject grid node id, to packet now. 
	msg.id = self.id;
	
	-- send server time (revision number)
	msg.st = self.timeid;
		
	if(nid~=nil) then
		local agent = self.agents[nid];
		if(agent) then
			agent:SendMessage(neuronfile or DefaultClientFile, msg, proxy);
		end
	else
		-- if no nid is provided, we shall broadcast to all users. 
		local _, agent;
		for _, agent in pairs(self.agents) do
			agent:SendMessage(neuronfile or DefaultClientFile, msg, proxy);
		end
	end
	return true;
end

-- this is a static function that actively close a given user_nid on behalf of a given gridnode. 
-- @param gridnode_id: the grid node or a gridnode id. 
function GridNode.CloseClient(gridnode_id, user_nid)
	if(type(gridnode_id) == "table") then
		gridnode_id = gridnode_id.id;
	end
	if(gridnode_id and user_nid) then
		NPL.activate(user_nid..":"..DefaultClientFile, {type = GSL_msg.SC_Closing, id = msg.id});
	end
end

-- add an agent message to the pool of real time messages. Each time the server receives a real time message from an agent, it will append the message string to realtime_msg[agent.nid]. 
-- during the next server real time update interval, the server just boardcasts all real time messages to all agents in the world. 
-- @param fromNID: the string nid of the agent sending the message. 
-- @param msgData: the opcode encoded message string.  One can use Map3DSystem.GSL.SerializeToStream() to generate this string. 
function GridNode:AddRealtimeMessage(fromNID, msgData)
	local data = self.realtime_msg[fromNID]
	if(data) then
		-- append the message: shall we remove redundent ones?
		self.realtime_msg[fromNID] = data.."\n"..msgData;
	else
		-- add the message
		self.realtime_msg[fromNID] = msgData;
		self.realtime_msgcount =  self.realtime_msgcount + 1;
	end	
end

-- broadcast all real time messages to all active agents, automatically exclude message sent by the agent itself.
-- if an agent connection is broken, we will sign it out. It will use the last received proxy of the agent. 
-- @param neuronfile: if nil, the DefaultClientFile is used
function GridNode:BroadcastRealtimeMessage(neuronfile)
	-- get all queued server objects' real time message to client
	local so;
	local sid, sagent
	for sid, sagent in pairs(self.ServerObjects) do
		local rt_msg, per_user_msg = sagent:GenerateRealtimeMessage()
		if(rt_msg) then
			so = so or {};
			so[sid] = rt_msg;
		end	
		if(per_user_msg) then
			-- send any queued per user server real time message
			local i, user_msg
			for i, user_msg in ipairs(per_user_msg) do
				local agent = self.agents[user_msg.nid]
				-- skip logged out agents
				-- if(agent.state~=agentstate.loggedout) then
				if( agent and (agent.state~=3)) then	
					local out_msg = {
						type = GSL_msg.SC_RealtimeUpdate, 
						-- inject grid node id, to packet now. 
						id = self.id,
						so = { [sid] = {user_msg.msg}},
					}
					agent:SendMessage(neuronfile or DefaultClientFile, out_msg, agent.proxy);
				end
				-- LOG.std(nil, "debug", "GridNodeRealTimeSend", {nid=agent.nid, agent_state = agent.state or "nil",  sid, user_msg.msg})
			end
		end
	end
	
	-- and for all agent real time messages
	if(not so and self.realtime_msgcount == 0) then
		return;
	end
	local rt_msg = self.realtime_msg;
	local rt_count = self.realtime_msgcount;
	
	local out_msg = {
		type = GSL_msg.SC_RealtimeUpdate, 
		agents = rt_msg,
		-- inject grid node id, to packet now. 
		id = self.id,
		so = so,
	};
	if(GSL.dump_server_msg) then
		LOG.std("", "info", "GSL", "GridNode:BroadcastRealtimeMessage"..LOG.tostring(out_msg));
	end
			
	-- forward the message to all other agents immediately
	local nid, agent;
	for nid, agent in pairs(self.agents) do
		-- skip the sender and logged out agents
		-- if(agent.state~=agentstate.loggedout) then
		if( (agent.state~=3)) then	
			local tmp = rt_msg[nid];
			if( not tmp) then
				agent:SendMessage(neuronfile or DefaultClientFile, out_msg, agent.proxy);
			elseif(rt_count>1) then
				-- skip the agent
				rt_msg[nid] = nil;
				agent:SendMessage(neuronfile or DefaultClientFile, out_msg, agent.proxy);
				rt_msg[nid] = tmp;
			end
		end
	end
	
	-- clear all real time messages
	self.realtime_msgcount = 0;
	self.realtime_msg = {};
end

-- register a message handler for a given msg_type, please note there can only be one message handler for a given msg_type
-- @param msg_type: such as GSL_msg.CS_RealtimeUpdate
-- @param funcHandler: it should be a function(gridnode, agent_from, msg) end, if nil the function will be unregistered. 
function GridNode:RegisterMessageHandler(msg_type, funcHandler)
	self.msg_handlers[msg_type] = funcHandler;
end

-- invoke a given message handler
function GridNode:InvokeMessageHandler(msg_type, agent_from, msg)
	local handler = self.msg_handlers[msg_type];
	if(handler) then
		handler(self,agent_from, msg);
	else
		LOG.std(nil, "warn", "GSL", "GSL grid node does not have a handler for msg_type: %s", msg_type);
	end
end

-- handle server messages, which in turn calls the message handler. 
function GridNode:HandleMessage(msg, curTime)
	local nid = msg.nid;
	-- check if authenticated
	if(not nid) then
		LOG.std(nil, "warn", "GSL", "GSL grid node ignored an invalid connection from %s", msg.tid);
		return;
	end
	
	-- update the client agent on server
	local agent_from = self:GetAgent(nid);
	if(not agent_from) then 
		LOG.std(nil, "warn", "GSL", "GSL grid node handles a message without agent, nid is %s", tostring(nid));
		return;
	end
	
	agent_from:tick(curTime);
	agent_from:tickReceive();
	-- save the last proxy for message reply. 
	agent_from.proxy = msg.proxy;
	
	local msg_type = msg.type
	if(msg_type == GSL_msg.CS_RealtimeUpdate) then
		local user = gateway:GetUser(nid);

		if(user and user:RateLimitCheck()) then
			-- LOG.std(nil, "debug", "GSL", "GSL grid node got msg nid %s, msg: %s", tostring(nid), commonlib.serialize_compact(msg));	
		else
			-- ignore this message if it does not pass the rate limiter
			-- LOG.std(nil, "debug", "GSL", "GSL grid node ignored msg nid %s, msg: %s", tostring(nid), commonlib.serialize_compact(msg));
			return;
		end
	end
	-- invoke the message handle
	self:InvokeMessageHandler(msg.type, agent_from, msg);
end

-- kick an agent either because that the connection is broken or other reasons.
function GridNode:KickAgent(nid)
	if(nid) then
		local agent = self.agents[nid];
		if(agent) then
			agent:SignOut();
			agent:cleanup(true);
			self.agents[nid] = nil;
			self.agent_count = self.agent_count - 1;

			-- remove from the gateway if self is the user's primary gridnode. 
			gateway:RemovePrimGridNode(nid, self);
		end
	end
end

-- check if any agents is timed out. 
-- @param curTime: current time in milliseconds
function GridNode:TimeOutCheck(curTime) 
	local _, agent;
	local count = 0;
	local TimedOutAgents;
	-- check for any client agent that is not active
	for _, agent in pairs(self.agents) do
		if(agent:CheckTimeOut(curTime, self.ClientTimeOut)) then
			-- if the agent is timed out, remove character and make inactive 
			-- node:log(string.format("User %s left grid node(%s:%s)\n", agent.nid, tostring(node.nid), tostring(node.id)));
			agent:SignOut();
			agent:cleanup(true);
			-- Mark the agent nid to be deleted after the iteration
			TimedOutAgents = TimedOutAgents or {};
			local nid = agent.nid;
			TimedOutAgents[nid] = true;

			-- remove from the gateway if self is the user's primary gridnode. 
			gateway:RemovePrimGridNode(nid, self);
		else	
			count = count + 1;
		end
	end
	self.agent_count = count;
	
	-- delete timed out agents
	if(TimedOutAgents~=nil) then
		local key, _;
		for key, _ in pairs(TimedOutAgents) do
			self.agents[key] = nil;
		end
	end
	
	-- clear history if it has reached an upper limit
	if(self.clear_history_count and self.history:GetTotalCount() >= self.clear_history_count) then
		-- TODO: shall we info all clients about this change?
		self.history:clear();
		--node:log("history cleared");
	end
end

-- this function is called periodically to let all grid nodes to send messages back to clients
-- @param curTime: current time in milliseconds
-- @return true if grid node is still active. or nil if no agents in the grid node for some time. 
function GridNode:OnFrameMove(curTime)
	self.tick_count = self.tick_count + 1;
	-- send pending real time messages. 
	self:BroadcastRealtimeMessage();
	
	if(self.tick_count % self.timeout_check_ticks == 0) then
		-- check time out
		self:TimeOutCheck(curTime);
	end	
	
	if(self.tick_count % self.framemove_check_ticks == 0) then
		self.timeid = self.timeid + 1;
		-- frame move all server objects. 
		local sid, serveragent
		for sid, serveragent in pairs(self.ServerObjects) do
			serveragent:OnFrameMove(curTime, self.timeid);
		end
	end	
	
	-- check close the server, if there are no more agents
	return self:TickClose() or self.is_persistent;
end

-- name alias
GridNode.OnTimer = GridNode.OnFrameMove;