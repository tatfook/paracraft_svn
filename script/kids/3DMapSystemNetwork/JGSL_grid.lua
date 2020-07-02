--[[
Title:  JGSL Grid (grid server)
Author(s): LiXizhi
Date: 2008/8/3
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL_grid.lua");
Map3DSystem.JGSL_grid.Restart();
Map3DSystem.JGSL_grid.activate();
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL.lua");
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL_msg_def.lua");
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL_history.lua");

if(not Map3DSystem.JGSL_grid) then Map3DSystem.JGSL_grid={}; end

local JGSL_grid = Map3DSystem.JGSL_grid;
local JGSL_server = Map3DSystem.JGSL_server;
local JGSL = Map3DSystem.JGSL;
local config = Map3DSystem.JGSL.config;
local JGSL_msg = Map3DSystem.JGSL_msg;

-- an array of active grid nodes. 
JGSL_grid.nodes = {};

-- timer ID
JGSL_grid.TimerID = 18;
-- if true, we will create a new instance if a previous one is full or non existant for a given world and tile position. 
JGSL_grid.AutoSpawn = true;
-- a timer that is enabled when there are active client connected to this server.
-- should be smaller or equal to Map3DSystem.JGSL.client.NormalUpdateInterval to prevent duplicate group2 info to be sent for the same client.
JGSL_grid.TimerInterval = 3000
-- if true, the game server is a dedicated server usually without any user interface. Pure server will use a different restart function. 
JGSL_grid.IsPureServer = nil;

------------------------------
-- Grid Node
------------------------------

-- a grid node is a single piece of JGSL server, it is similar to JGSL_server, but without loading game world specific data
-- JGSL_grid adds, deletes, maintains many active grid nodes at the same time. 
local GridNode = {
	-- server session key, it is regenerated each time a grid node is created or reset, or the underlying game world changes.
	sk = ParaGlobal.GenerateUniqueID(), 
	-- grid node id
	id = nil,
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
	
	-- Map3DSystem.JGSL.history: contains all client and server agent creation and environmental action history. 
	history = nil,
	-- clear the history when the creation has reached this number of times. If this is nil, all history are kept. 
	clear_history_count = 30,
	
	-- max number of creations in a message
	max_creations_per_msg = 5,
	-- max number of env updates in a message
	max_env_per_msg = 5,
	-- VIP ATTRIBUTE: max number of connected users allowed in this grid, this is total number of agents and observers. 
	-- TODO:  when there are more than JGSL_grid.max_users on a single server, and when a jid client leaves a such a over crowded grid node and reenters again. the client will receive nothing. 
	max_users = 500,
	
	-- a timer that is enabled when there are active client connected to this server.
	-- should be smaller or equal to Map3DSystem.JGSL.client.NormalUpdateInterval to prevent duplicate group2 info to be sent for the same client.
	TimerInterval = 3000,
	-- if a client is not responding in 20 seconds, we will make it inactive user and remove from active user list. 
	ClientTimeOut = 20000,
	-- a new character will be located at radius = miniSpawnRadius+math.sqrt(OnlineUserNum+1)*3;
	miniSpawnRadius = 5,
	-- When the server has broadcasted this number of objects, the server will be automatically restarted; this is usually the setting for testing public server.
	RestartOnCreateNum = tonumber(ParaEngine.GetAppCommandLineByParam("RestartOnCreateNum", "0")),
	
	-- we will recover at most maxrecoversize number of intact client agent request at a time. 
	maxrecoversize = 5,
	
	--
	-- TODO: for Andy. For each grid node, we need to load NPC within the region and work with Quest server for the world self.worldpath
	-- Multiple grid nodes for the same self.worldpath may need to share the same server DB. 
	-- For NPC, creatures and dropped items, they should be treated as a special kind of agent in GameObjects table. 
	-- this part is not implemented yet. 
	--
	GameObjects = {},
	
	-- client agents or observers on server, where agents[jid] = {agent}.
	agents = {},
	
	-- increased by one eact time a normal update is replied
	timeid = 1,
	
	-- node statistics 
	statistics = {
		-- strange: LXZ 2008.12.25: ParaGlobal.GetDateFormat(nil) returns invalid XML char code. just ignore it for now. 
		StartTime = nil, -- commonlib.Encoding.DefaultToUtf8(ParaGlobal.GetDateFormat(nil)..ParaGlobal.GetTimeFormat(nil)),
		OnlineUserNum = 0,
		VisitsSinceStart = 0,
		NumObjectCreated = 0,
	},
};
JGSL_grid.GridNode = GridNode;

-- state of the agent 
local agentstate = {
	agent = 1,
	observer = 2,
}
------------------------------
-- public function
------------------------------

-- check whether this grid node allow users to edit the world
-- @param rule: if nil, it means  editing right. 
function GridNode:CanEdit()
	return (self.UserRole~="guest");
end

function GridNode:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	
	o.history = Map3DSystem.JGSL.history:new();
	o.timeid = 1;
	o:Reset();
	return o
end

-- release a grid node. 
function GridNode:Release()
end

-- output log
function GridNode:log(...)
	commonlib.log(...)
end

-- regenerate session and become a new server. This is usually called by Map3DSystem.JGSL.Reset()
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
	
	-- jid is the current JGSL server's jid
	self.jid = JGSL.GetJID();
	
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

-- TODO: close the node, if there are no agents or observers in it and is not active for a good period of time. 
function GridNode:CheckClose()
	if(#(self.agents) == 0) then
		-- TODO: we will never close grid node in this release. unless there are too many 
		-- self:Reset();
		--commonlib.log("closing so soon?");
	end
end

-- load the grid node from a config structure, but does not reset 
-- @param config: a table of {worldpath, x,y,size, UserRole,}
function GridNode:Load(config)
	if(config.worldpath) then
		self.worldpath = config.worldpath;
	end
	if(config.x and config.y and config.size) then
		self.x, self.y, self.size = config.x, config.y, config.size;
		-- compute the others. 
		self.from_x= self.x * self.size;
		self.from_y= self.y * self.size;
		self.to_x= self.from_x + self.size;
		self.to_y= self.from_y + self.size;
	end
	if(config.UserRole) then
		self.UserRole = config.UserRole;
	end
end

------------------------------
-- private functions
------------------------------

-- it will create the agent structure if it does not exist
function GridNode:GetAgent(jid)
	if(not jid) then return end
	local agent = self.agents[jid];
	if(not agent) then
		agent = self:CreateAgent(jid)
	end
	return agent;
end

-- create an agent. it will overwrite existing one, if any, with a newly created one. 
function GridNode:CreateAgent(jid)
	local agent = JGSL.agent:new{jid = jid};
	self.agents[jid] = agent;
	return agent;
end

-- whether the grid node has reached maximum number of connected users allowed. 
function GridNode:IsFull()
	return (#(self.agents) >= self.max_users)
end

-- whether the grid node is empty. 
function GridNode:IsEmpty()
	return (#(self.agents) == 0) and (self.worldpath == nil);
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
-- @param jid: the jid of a client. If this is nil. Messages is sent to all active clients.
-- @param neuronfile: if nil, the DefaultClientFile is used
-- @return true if successfully send
function GridNode:SendToClient(jid, msg, neuronfile)
	if(JGSL.dump_server_msg) then
		commonlib.log(msg);
	end
	local jc = JGSL.GetJC()
	if(jc~=nil) then
		-- inject session key to packet. 
		msg.sk = msg.sk or self.sk;
		-- send server time
		msg.st = self.timeid;
			
		if(jid~=nil) then
			jc:activate(jid..":"..(neuronfile or JGSL.DefaultClientFile), msg);
		else
			local _, agent;
			for _, agent in pairs(self.agents) do
				-- TODO: does jabber:XMPP has a group chat function, which performs better than this simple enumeration?
				jc:activate(agent.jid..":"..(neuronfile or JGSL.DefaultClientFile), msg);
				agent:tickSend();
			end
		end
		return true;
	end
end

-- handle server messages
function GridNode:HandleMessage(msg)
	-- check if session key is valid
	if(msg.sk ~= self.sk) then
		--commonlib.log("warning: jgsl grid node ignored an invalid session key %s from jid %s\n", tostring(msg.sk), msg.from)
		return;
	end
		
	-- msg.from may be of format "name@server/resource", so we need to remove resource
	local jid = string.gsub(msg.from, "/.*$", "");
	
	-- update the client agent on server
	local agent_from = self:GetAgent(jid);
	if(agent_from==nil) then return end

	if(msg.type == JGSL_msg.CS_ObserverUpdate or msg.type == JGSL_msg.CS_NormalUpdate) then
		if(msg.type == JGSL_msg.CS_ObserverUpdate) then
			-- mark agent as observer
			agent_from.state = agentstate.observer;
		else
			-- mark as agent 
			agent_from.state = agentstate.agent;
		end
		
		--log("-------server received normal update\n")
		--commonlib.echo(msg)
		
		local out_msg = {
			type = JGSL_msg.SC_NormalUpdate, 
			agents = {},
			ct = msg.ct, -- forward client time
		};

		if(self:CanEdit() and msg.agent and msg.type == JGSL_msg.CS_NormalUpdate) then
			-- get all creations since last update feedback
			out_msg.creations = self.history:GetCreationsForClientAgent(agent_from, self.max_creations_per_msg)
			-- get all env updates since last update feedback
			out_msg.env = self.history:GetEnvsForClientAgent(agent_from, self.max_env_per_msg)
			
			-- update any object creations contained in the client update. 
			self.history:AddCreations(msg.agent.creations, jid);
			
			-- update any object env updates contained in the client update. 
			self.history:AddEnvs(msg.agent.env, jid);
		end	
			
		agent_from:tick();
		agent_from:tickReceive();
		if (msg.agent and msg.agent.data) then
			-- increased by one each time the server side agents are changed
			self.timeid = self.timeid + 1;
		
			-- actually the following line is not necessary, if server grid does not render the agent. 
			agent_from.gx, agent_from.gz = self.from_x, self.from_y;
			agent_from:UpdateFromStream(msg.agent.data, self.timeid);
			
			--commonlib.log("----------------- update from stream.\n")
			--commonlib.log(msg.agent.data)
			--agent_from:print_history();
		end	
		
		if(msg.type == JGSL_msg.CS_NormalUpdate) then
			if( not agent_from:IsIntact() ) then
				-- losing client info, so instead of forward msg.ct, we will sent nil back to client.
				out_msg.ct = nil;
				-- commonlib.log("warning: intact client %s is found, let us set the ct to nil\n", jid);
			end
		end	
			
		-- only send other agents if the client is not dummy(for lightweighted emulation users)
		if(not msg.dummy) then
			-- send all client agents updates to client
			local opcode_jid = Map3DSystem.JGSL.opcode.opcode_jid;
			local _, agent;
			local index = 1;
			local st = tonumber(msg.st);
			for _, agent in pairs(self.agents) do
				-- skip the sender, observer or logged out agent
				if(agent.jid~=jid and agent.state==agentstate.agent) then
					--commonlib.log("----------------- generate stream.\n")
					--commonlib.echo(st)
					--agent:print_history();
					
					local agentdata = agent:GenerateUpdateStream(st);
					
					local jidname = opcode_jid:write(agent.jid);
					if(jidname) then
						if(agentdata) then
							out_msg.agents[jidname] = agentdata;
						else
							-- Note: if agentdata is nil, add to msg.ping="jid,jid,jid"
							if(out_msg.ping == nil) then
								out_msg.ping = jidname;
							else
								out_msg.ping = string.format("%s,%s", out_msg.ping, jidname)
							end
						end	
					end	
					index = index + 1;
				end	
			end
			-- recover some agents on clients' request.
			if(type(msg.recover) == "string") then
				local count=0;
				local jidname
				for jidname in string.gmatch(msg.recover, "[^,]+") do	
					count = count+1;
					if(count<=self.maxrecoversize) then
						local jid = opcode_jid:read(jidname);
						local agent = self.agents[jid];
						if(agent) then
							local agentdata = agent:GenerateUpdateStream(0);
							if(agentdata) then
								out_msg.agents[jidname] = agentdata;
								-- commonlib.log(string.format("agent %s is recovered %s\n", jidname, agentdata))
							end
						end	
					else
						break;	
					end	
				end
			end
		end	
		
		-- reply to client.
		if(self:SendToClient(jid, out_msg)) then
			agent_from:tickSend();
		end
	elseif(msg.type == JGSL_msg.CS_Logout) then
		-- mark as logout 
		agent_from.state = 3;
	end	
end

-- this function is called periodically.
function GridNode:OnTimer(curTime)
	curTime = curTime or ParaGlobal.GetGameTime();
	local _, agent;
	local count = 0;
	local TimedOutAgents;
	-- check for any client agent that is not active
	for _, agent in pairs(self.agents) do
		if(agent:CheckTimeOut(curTime, self.ClientTimeOut)) then
			-- if the agent is timed out, remove character and make inactive 
			-- node:log(string.format("User %s left grid node(%s:%s)\n", agent.jid, tostring(node.jid), tostring(node.id)));
			
			agent:cleanup(true);
			-- Mark the agent jid to be deleted after the iteration
			TimedOutAgents = TimedOutAgents or {};
			TimedOutAgents[agent.jid] = true;
		else	
			count = count +1;
		end
	end
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
	
	-- check close the server, if there are no more agents
	self:CheckClose();
end

------------------------------
-- Grid Manager related
------------------------------

-- shut down all server grid node
function JGSL_grid.Reset()
	JGSL_grid.nodes = {};
end

-- get a gridnode by id and sessionkey of the grid node
function JGSL_grid.GetGridNode(id, sk)
	local node = JGSL_grid.nodes[id];
	if (node and node.sk == sk) then
		return node;
	end
end

-- get available server grid node for a given world path. 
-- @param worldpath: the world that the grid node is in. 
-- @param x, y, z: a position that the grid node contains. 
-- @param IsObserver: true if we are just getting for an observer node. 
function JGSL_grid.GetBestGridNode(worldpath, x, y, z, IsObserver)
	local index, node
	for index, node in ipairs(JGSL_grid.nodes) do
		if(node:Contains(worldpath, x, y, z) and (not node:IsFull())) then
			return node;
		end
	end
end

-- Get the best grid node for a given world path. if no suitable node is found, we will spawn a new one. 
-- @return: return a grid node structure. 
function JGSL_grid.CreateGetBestGridNode(worldpath, x, y, z, IsObserver)
	if(not worldpath) then 
		--log("JGSL_grid.CreateGetBestGridNode worldpath is nil \n")
		return;
	end
	local node = JGSL_grid.GetBestGridNode(worldpath, x, y, z, IsObserver);
	if(not node) then
		if (JGSL_grid.AutoSpawn) then
			local _, rule, bestrule; 
			for _, rule in ipairs(config.GridNodeRules) do
				if(not rule.worldfilter or string.match(worldpath, rule.worldfilter)) then
					if (rule.gridsize) then
						if (not rule.fromx or (x and z and rule.fromx<=x and rule.fromy<=z and rule.tox>=x and rule.toy>=z) ) then
							bestrule = rule;
							break;	
						end
					else
						bestrule = rule;
						break;	
					end
				end
			end
			node = JGSL_grid.CreateGridNode(worldpath);
			if(bestrule and bestrule.gridsize) then
				node:Load({
					worldpath=worldpath, 
					size=bestrule.gridsize, 
					UserRole = bestrule.UserRole,
					x=math.floor(x/bestrule.gridsize), 
					y=math.floor(z/bestrule.gridsize), 
				});
			end	
		end	
	end
	
	return node;
end

-- create a new grid node of world path
-- it will reuse empty grid node, if there is none, it will create a new one at the end.
-- @return: the grid node created or reused are returned. 
function JGSL_grid.CreateGridNode(worldpath)
	local newNode;
	local index, node
	for index, node in ipairs(JGSL_grid.nodes) do
		if(node:IsEmpty()) then
			newNode = node;
			break;
		end
	end
	if(not newNode) then
		newNode = GridNode:new();
		newNode.id = #(JGSL_grid.nodes) + 1;
		JGSL_grid.nodes[newNode.id] = newNode;
		commonlib.log("JGN: New grid node is spawned at id (%d), sk (%s) for world (%s)\n", newNode.id, newNode.sk, tostring(worldpath));
	end
	newNode.worldpath = worldpath;
	return newNode;
end

-- restart the grid server
-- @param configfile: nil or config file path.
function JGSL_grid.Restart(configfile)
	JGSL_grid.Reset()
	
	if(configfile) then
		JGSL_grid.configfile = configfile;
	end
	if(JGSL_grid.configfile) then
		-- TODO: load from configuration file.
	end
	
	-- set the server timer for each login.
	NPL.SetTimer(JGSL_grid.TimerID, JGSL_grid.TimerInterval/1000, ";Map3DSystem.JGSL_grid.OnTimer()");
	JGSL.IsGrid = true;
end
		
-- a very slowly kicked timer that periodically check user status
function JGSL_grid.OnTimer()
	local curTime = ParaGlobal.GetGameTime();
	
	local index, node
	for index, node in ipairs(JGSL_grid.nodes) do
		node:OnTimer(curTime);
	end
end

local function activate()
	if(JGSL.dump_server_msg) then
		commonlib.echo(msg);
	end
	
	------------------------------------
	-- a client sends us (grid node) a normal update
	------------------------------------
	-- get the server grid node if any.
	local gridnode = JGSL_grid.GetGridNode(msg.id, msg.sk);
	if(gridnode) then
		gridnode:HandleMessage(msg);
	else	
		-- no server is found
		if(JGSL.dump_server_msg) then
			commonlib.log("grid server not found for user %s\n", msg.from)
		end	
	end
end
JGSL_grid.activate = activate;
NPL.this(activate);
