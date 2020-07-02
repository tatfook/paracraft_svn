--[[
Title:  GSL Grid node manager 
Author(s): LiXizhi
Date: 2008/8/3, refactored to support GSL_homegrid 2009.10.8
Desc: GSL_grid and GSL_homegrid are two different managers (instances) of GSL_gridnode. They create GSL_gridnode on the user's demand. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/GameServer/gridnode_manager.lua");
local gridnode_manager = commonlib.gettable("Map3DSystem.GSL.gridnode_manager");
local GSL_grid = gridnode_manager:new(commonlib.gettable("Map3DSystem.GSL_grid"));
GSL_grid:Restart(config);
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/STL.lua");
NPL.load("(gl)script/apps/GameServer/GSL.lua");
NPL.load("(gl)script/apps/GameServer/GSL_msg_def.lua");
NPL.load("(gl)script/apps/GameServer/GSL_history.lua");
NPL.load("(gl)script/apps/GameServer/GSL_gridnode.lua");

local string_lower = string.lower;
local string_match = string.match;
local string_gsub = string.gsub;

local GSL = commonlib.gettable("Map3DSystem.GSL");
local config = commonlib.gettable("Map3DSystem.GSL.config");
local GSL_msg = commonlib.gettable("Map3DSystem.GSL.GSL_msg");
local GSL_proxy = commonlib.gettable("Map3DSystem.GSL.GSL_proxy");
local GridNode = commonlib.gettable("Map3DSystem.GSL.GridNode");
local gridnode_manager = commonlib.gettable("Map3DSystem.GSL.gridnode_manager");
------------------------------
-- Grid Manager related
------------------------------
function gridnode_manager:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	o:ctor();
	return o
end

-- constructor function
function gridnode_manager:ctor()
	-- a mapping from active grid node id to grid node. Only gridnode in active_node_list is in the map.
	self.nodes = {};
	-- mapping from active node's worldpath(name) to gridnode, for fast retrieval by worldpath. Only gridnode in active_node_list is in the map.
	-- however, not all active nodes are in this map, since some instanced world may share the same world path. 
	self.node_name_map = {};
	-- mapping from GSL rule's filter path to a table of cached (no-user) grid node. All nodes here are inactive but loaded. 
	self.cached_nodes_map = {};
	-- next grid node id to be assigned to newly created grid nodes
	self.next_id = 0;
	-- linked list of active nodes
	self.active_node_list = commonlib.List:new();

	-- if true, we will create a new instance if a previous one is full or non existant for a given world and tile position. 
	self.AutoSpawn = true;
	-- a timer all grid nodes. In the timer a grid node usually send cached real time messages as well as timeout agents and server. 
	-- it should be smaller or equal to Map3DSystem.GSL.client.NormalUpdateInterval to prevent duplicate group2 info to be sent for the same client.
	self.TimerInterval = 300;
	-- if true, the game server is a dedicated server usually without any user interface. Pure server will use a different restart function. 
	self.IsPureServer = nil;
	-- whether the grid server is started. 
	self.is_started = false;
	-- current time in milliseconds, this is updated once in every on timer frame move. 
	self.curTime = nil;
end

-- get next id to be assigned to new grid node. 
function gridnode_manager:GetNextID()
	self.next_id = self.next_id + 1;
	return self.next_id;
end

-- shut down all server grid node
function gridnode_manager:Reset()
	self.nodes = {};
	self.node_name_map= {};
	self.cached_nodes_map = {};
	self.next_id = 0;
	self.active_node_list:clear();
end

-- get a gridnode by id
function gridnode_manager:GetGridNode(id)
	return self.nodes[id];
end

-- get the total number of active user agents in all grid nodes. 
-- @node: the value returned may be larger than the total number of user TCP connections 
-- because the user may be logged in multiple gridnodes at the same time. 
-- However, this value is more meaningful to denote the total crowdness of a world server. 
function gridnode_manager:GetTotalAgentCount()
	local count = 0;
	local list = self.active_node_list;
	local node = list:first();
	while (node) do
		count = count + node:GetAgentCount();
		node = list:next(node);
	end
	return count;
end

-- Get all online user nids
-- @param bReturnTable: if true, it will return a table array each has a nid, otherwise it will return commar seperated string. 
-- @return: output, count: where output is string of commar seperated list, such as "1,2,3" without the trailing or get a table array if bReturnTable is true. 
function gridnode_manager:GetAllOnlineUsers(bReturnTable)
	local count = 0;
	local list = self.active_node_list;
	local node = list:first();
	local user_nids = {};
	
	while (node) do
		for _, agent in pairs(node.agents) do
			-- agent.state == 1, means online active agent. 
			if(agent and agent.state == 1) then
				count = count + 1;
				user_nids[count] = agent.nid;
			end
		end
		node = list:next(node);
	end
	
	if(not bReturnTable) then
		user_nids = table.concat(user_nids, ",");
	end
	return user_nids, count;
end

-- for each online user execute the function func(gridnode) end
function gridnode_manager:OnEachActiveGridNode(func)
	local list = self.active_node_list;
	if(list) then
		local node = list:first();
		while (node) do
			func(node);
			node = list:next(node);
		end
	end
end

-- for each online user execute the function func(agent, gridnode) end
function gridnode_manager:OnEachLiveUser(func)
	local list = self.active_node_list;
	local node = list:first();
	
	while (node) do
		for _, agent in pairs(node.agents) do
			-- agent.state == 1, means online active agent. 
			if(agent and agent.state == 1) then
				func(agent, node);
			end
		end
		node = list:next(node);
	end
end

-- retrieve a cached node
-- @param worldfilter: the cache pool key. internally cached nodes are saved in different pools. 
-- @param bCreateIfNotExist: true to create if not exit.
-- @return: gridnode, boolean: the first returned parameter is the gridnode if created or fetched from cache. 
-- the second parameter is true if it is a newly created node, otherwise it is from cache. 
function gridnode_manager:PopCachedNode(worldfilter, bCreateIfNotExist)
	worldfilter = worldfilter or "";
	local node;
	local cached_nodes = self.cached_nodes_map[worldfilter];
	if(cached_nodes) then
		local nSize = #cached_nodes;
		if( nSize >= 1) then
			node = cached_nodes[nSize];
			cached_nodes[nSize] = nil;
		end
	end

	local is_newly_created;
	if(not node and bCreateIfNotExist) then
		node = GridNode:new();
		node.id = self:GetNextID();
		node.worldfilter = worldfilter;
		is_newly_created = true;
	end
	return node, is_newly_created;
end

-- push a node to the cached pool so that it can be reused in future. 
-- one must make sure that the node is not already in the queue. 
function gridnode_manager:PushCachedNode(node)
	local worldfilter = node.worldfilter or "";
	local cached_nodes = self.cached_nodes_map[worldfilter];
	if(not cached_nodes) then
		cached_nodes = {}; 
		self.cached_nodes_map[worldfilter] = cached_nodes;
	end
	-- LOG.std(nil, "debug", "GSL", "Caching grid node id:%d for filter %s", node.id, node.worldfilter);
	cached_nodes[#cached_nodes + 1] = node;
end

-- find an exiting active gridnode by its world path. 
-- @param worldpath: be sure that the world path is already lower cased. 
function gridnode_manager:FindNode(worldpath)
	return self.node_name_map[worldpath]; 
end

-- make node active
-- add an exiting gridnode to the current active grid node list. 
-- one needs to make sure first that the gridnode is not already an active gridnode. 
-- @param node: the grid node created or reused are returned. 
function gridnode_manager:MakeNodeActive(node)
	if(not self.nodes[node.id]) then
		LOG.std(nil, "debug", "GSL", "grid node id(%d), worldpath %s(ruleid:%d) is activated", node.id, node.worldpath or "", node.gridrule_id or 0);
		self.node_name_map[node.worldpath or ""] = node;
		self.nodes[node.id] = node;
		-- add to active node list. 
		self.active_node_list:add(node);
		node:OnActivate(true);
	end
	return node;
end

-- remove a given node from simulation. It does not delete the node, which means that the same node may be reused in the future. 
-- it just stops its frame move timer on the server side. 
-- @return the next gridnode in the chain. 
function gridnode_manager:RemoveNode(node)
	if(self.nodes[node.id]) then
		node:OnActivate(false);
		self.nodes[node.id] = nil;
		self.node_name_map[node.worldpath or ""] = nil;
		local next_node = self.active_node_list:remove(node);
		-- move to cached nodes pool for reuse later on
		self:PushCachedNode(node);
		LOG.std(nil, "debug", "GSL", "grid node id(%d), worldpath %s is inactivated", node.id, node.worldpath or "");
		return next_node;
	else
		LOG.std(nil, "error", "GSL", "try to remove an non-existing grid node id(%d), worldpath %s", node.id, node.worldpath or "");
		return self.active_node_list:remove(node);
	end
end


-- private:create get grid node by according to worldpath, worldpath_host, and gridrule_id. all of them must match. 
-- this function is called by CreateGetBestGridNode().
function gridnode_manager:CreateGetGridNode(worldpath, worldpath_host, gridrule_id, x, y, z, IsObserver, params)
	local node;
	local _, rule, bestrule; 
	for _, rule in ipairs(config.GridNodeRules) do
		if( (gridrule_id and gridrule_id == rule.id) or
			(not gridrule_id and (not rule.worldfilter or string_match(worldpath_host, rule.worldfilter))) ) then
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
	if(bestrule) then
		local is_newly_created;
		node, is_newly_created = self:PopCachedNode(bestrule.worldfilter, true)

		node.gridrule_id = gridrule_id;
		
		if(gridrule_id) then
			-- Tricky: it is very important to not trust client to overwrite the worldpath. 
			-- Otherwise, some instanced world with wrong worldpath could overwrite worldname map in MakeNodeActive() and resulting in wrong node returned in FindNode()
			worldpath = "";
		end
		
		node.worldpath = worldpath; -- TODO: do not trust the worldpath. use fixed path instead. 
		
		node.room_key = nil;
		if(params) then
			if(params.room_key) then
				node.room_key = params.room_key;
			end
			node.match_info = params.match_info;
			node.mode = params.mode;
			--if(node.match_info) then
				--LOG.std(nil, "debug", "GSL_match_node_created",  node.match_info);
			--end
		else
			node.match_info = nil;
		end
			
		-- TODO: only load if not loaded before. 
		if(is_newly_created) then
			local params = {
				worldpath=worldpath, 
				npc_file = bestrule.npc_file,
			};
			setmetatable(params, bestrule)

			if(bestrule.gridsize) then
				params.size = bestrule.gridsize;
				params.x = math.floor(x/bestrule.gridsize); 
				params.y = math.floor(z/bestrule.gridsize);
			else
				params.x = bestrule.fromx;
				params.y = bestrule.fromx;
			end	
			node:Load(params);
			LOG.std(nil, "system", "GSL", "JGN: addr(%s) New grid node is spawned at id (%d) for world id(%d):(%s) is_persistent:%s", self.config.addr, node.id, gridrule_id or 0,worldpath, tostring(bestrule.is_persistent) );
		end
		-- add to active node list. 
		self:MakeNodeActive(node)
	else
		LOG.std(nil, "system", "GSL", "no grid node rule is defined for the world (%s)", worldpath);
		return;	
	end
	return node;
end

-- Get the best grid node for a given world path. if no suitable node is found, we will spawn a new one. 
-- it will automatically add the grid node to active grid list.
-- @param worldpath: the world that the grid node is in. 
--	e.g. "worlds/world_name/#instance?nid=user_nid&local=true"
-- please note, the string before '?' will be used for server worldfilter pattern matching. i.e. "worlds/world_name/#instance"
-- for standard public world: "worlds/world_name"
-- @param x, y, z: a position that the grid node contains. 
-- @param IsObserver: true if we are just getting for an observer node. 
-- @param params: nil or a table of additional params. {nid, is_local_instance, create_join, id, room_key}
--   id is the grid node rule id. It must match the grid node rule's id. 
--   room_key is any string key that all users must have in order to enter a given room. 
-- @return: return the grid node. remember to add an agent immediately after it is created, otherwise it may be made inactive again.  
function gridnode_manager:CreateGetBestGridNode(worldpath, x, y, z, IsObserver, params)
	if(not worldpath) then 
		return;
	end
	-- to lower case
	worldpath = string_lower(worldpath);
	local worldpath_host = string_gsub(worldpath, "%?.*", "");

	local node;
	local battlefield_node;
	local find_battlefield_node = false;
	local gridrule_id, create_join, room_key;
	if(params) then
		-- get the grid rule's id in case it is specified by the client(caller). 
		gridrule_id = params.gridrule_id;
		create_join = params.create_join;
		room_key = params.room_key;
		if(create_join and gridrule_id) then
			-- if create_join is true, we will prefer to join an existing unstarted world, and if there is no such world, we will try to create one, instead. 
			local list = self.active_node_list;
			local node_ = list:first();
			while (node_) do
				if(node_.gridrule_id == gridrule_id) then
					-- if room key is provided and not nil, we will surpass the CanJoin() function and always let the user with the key to login. 
					if(node_.room_key == room_key and (room_key or node_:CanJoin())) then
						--LOG.std(nil, "debug", "GSL", "CreateJoin:we are matching grid node"..tostring(gridrule_id));
						if(gridrule_id == 144 and System.options.version == "kids") then   -- gridrule_id is 144,express the worldname is "BattleField_ChampionsValley_Master"
							if(not find_battlefield_node) then
								battlefield_node = node_;
								find_battlefield_node = true;	
							end
							
							if(params.combat_is_started) then
								if(node_.combat_is_started) then
									node = node_;
									break;
								end
							else
								if(not node_.combat_is_started) then
									node = node_;
									break;
								end
							end
						else
							node = node_;
							break;
						end

					end
				end
				node_ = list:next(node_);
			end
			if(not node and gridrule_id == 144 and System.options.version == "kids") then 
				if(params.combat_is_started) then
					if(battlefield_node) then
						node = battlefield_node;
					end	
				end
			end
			
			-- if no unstarted active world is found, we will try to create one instead. 
			if(not node) then
				--LOG.std(nil, "debug", "GSL", "CreateJoin: creating grid node"..tostring(gridrule_id));
				node = self:CreateGetGridNode(worldpath, worldpath_host, gridrule_id, x, y, z, IsObserver, params);
			end
			return node;
		end
	end
	if(not node) then
		if(not gridrule_id) then
			node = self:FindNode(worldpath);
		end
	end
	
	if(not node) then
		if( not self.AutoSpawn) then 
			return 
		end
		node = self:CreateGetGridNode(worldpath, worldpath_host, gridrule_id, x, y, z, IsObserver, params)
	end
	
	return node;
end

-- This is called periodically to let all grid nodes to send messages back to clients
-- @param curTime: in milliseconds. if nil, the current system time is used. 
function gridnode_manager:OnFrameMove(curTime)
	local curTime = curTime or ParaGlobal.timeGetTime();
	self.curTime = curTime;
	gridnode_manager.srvtime = ParaGlobal.GetTimeFormat("HH:mm:ss");

	local list = self.active_node_list;
	local node = list:first();
	while (node) do
		if(not node:OnFrameMove(curTime)) then
			node = self:RemoveNode(node);
		else
			node = list:next(node);
		end
	end
end


-- restart the grid server
-- @param config: a table of {nid, ws_id}. 
--	where nid is the game server; ws_id is the global world server id. Both should be string. 
function gridnode_manager:Restart(config)
	self.is_started = true;
	self:Reset()
	
	if(type(config) == "table") then
		-- TODO load config 
		self.config = config;
	elseif(not self.config) then
		LOG.std(nil, "warn", "GSL", "grid server is started without config file");
		self.config = {};
	end
	config = self.config;

	-- load all NPC files after services are loaded. 
	local config_ = commonlib.gettable("Map3DSystem.GSL.config");
	local _, rule, bestrule; 
	for _, rule in ipairs(config_.GridNodeRules) do
		if(type(rule.npc_file) == "string") then
			rule.npc_file = config_:load_npc_file(rule.npc_file)
		end
	end

	-- set the server timer for each login.
	NPL.load("(gl)script/ide/timer.lua");
	self.mytimer = self.mytimer or commonlib.Timer:new({callbackFunc = function(timer)
		self:OnFrameMove();
	end})
	self.mytimer:Change(300, self.TimerInterval);

	-- register broadcast service 
	local BroadcastService = commonlib.gettable("Map3DSystem.GSL.Lobby.BroadcastService");
	if(BroadcastService.AddGridNodeManager) then
		BroadcastService.AddGridNodeManager(self);
	end

	LOG.std(nil, "system", "GSL", "grid server started on %s(%s)", tostring(config.nid), tostring(config.ws_id));
end

-- activate function of the standard GSL_grid
-- @param bProxy: if true, this can be a proxy.
function gridnode_manager:activate(msg, bProxy)
	if(GSL.dump_server_msg) then
		commonlib.applog("GSL received");
		commonlib.echo(msg);
	end

	local nid = msg.nid;

	if(bProxy) then
		if(msg.proxy) then
			msg.nid = msg.proxy.src;
		end
	
		-- TODO: find a safer way to accept connection formally. GSL_homegrid is only valid from intranet, so nid is not required. 
		if(not nid) then
			if(msg.tid) then
				local ip = NPL.GetIP(msg.tid);
				if(msg.gid and (ip:match("^192%.168") or ip:match("^127%.0") or ip:match("^10%.")) ) then
					nid = msg.gid;
					NPL.accept(msg.tid, msg.gid);
					LOG.std(nil, "system", "GSL", "proxy:connection tid %s is accepted as %s for user %s", tostring(msg.tid), msg.gid, tostring(msg.nid));
				else
					LOG.std(nil, "warn", "GSL", "proxy:unauthenticated message received from nid %s, ip:%s, gid %s Message is dropped", tostring(msg.tid), ip, tostring(msg.gid));
					--LOG.std(nil, "warn", "GSL", "proxy:unauthenticated message received from nid %s. Message is dropped", tostring(msg.tid));
					return
				end
			else
				-- let local message pass anyway
			end
		end
	end

	if(not self.is_started) then
		LOG.std(nil, "debug", "GSL", "grid server is not started. but we received a message from nid %s. Message is dropped", tostring(msg.nid));
		return;
	end

	if(not bProxy) then
		if(not nid) then
			return
		end
	
		if(msg.proxy) then
			local proxy = {addr=msg.proxy.addr}
			msg.proxy = {addr=self.config.addr, src=msg.nid};
			GSL_proxy:SendMessage(proxy, "script/apps/GameServer/GSL_homegrid.lua", msg)
			return
		end
	end
	

	if(msg.type == GSL_msg.CS_Login) then
		------------------------------------
		-- a client just request connection
		------------------------------------
		-- create the grid node if not exist. 
		local gridnode = self:CreateGetBestGridNode(msg.worldpath, msg.x, msg.y, msg.z, msg.IsObserver, msg.params);
		if(gridnode) then
			gridnode:HandleMessage(msg, self.curTime);
		else
			-- TODO: inform no grid node is found, 
			-- gridnode is not valid yet. -- gridnode:SendMessage(nid, {type = GSL_msg.SC_Login_Reply}, msg.proxy);
			LOG.std(nil, "debug", "GSL", "warning: no grid node is found for nid: %d of world path %s", nid, msg.worldpath)
		end
	else
		------------------------------------
		-- a client sends us (grid node) a normal update
		------------------------------------
		-- get the server grid node if any.
		local gridnode = self:GetGridNode(msg.id);
		if(gridnode) then
			gridnode:HandleMessage(msg, self.curTime);
		else	
			-- no server is found
			LOG.std(nil, "debug", "GSL", "warning: grid server id=%d not found for user %s. msg=%s.", tostring(msg.id), msg.nid, commonlib.serialize_compact(msg))

			-- let us inform the user that gridnode is closed only if this is not a proxy 
			if(not bProxy and msg.id) then
				GridNode.CloseClient(msg.id, (msg.nid or msg.tid));
			end
		end
	end	
end
