--[[
Title: The game client
Author(s): LiXizhi
Date: 2009/7/30
Desc: When a client receives a server message, it will extract sub messages for each GSL_server_agent. 
And for each agent, it will create such a character if it has not been done before. 
It will also carry out the action sequence immediately. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/GameServer/GSL.lua");
-- singleton usage
Map3DSystem.GSL_client:Dump()
Map3DSystem.GSL_client:AddRealtimeMessage({name="chat", value="hello world"})
Map3DSystem.GSL_client:AddEventListener("OnLoginNode", function(client, proxy)
	log("we have logged in to grid node")
end)
Map3DSystem.GSL_client:SendChat("hello world!");

-- for multiple user emulation, create multiple gameserver nids mapping to the same game server. and create a client for each server nid. 
local client = Map3DSystem.GSL.client:new({IsEmulated=true});
client:LoginServer(nid, ws_id, worldpath, homeworld_nid)
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/timer.lua");
NPL.load("(gl)script/apps/GameServer/GSL_clientconfig.lua");
NPL.load("(gl)script/apps/GameServer/GSL.lua");
NPL.load("(gl)script/apps/GameServer/GSL_msg_def.lua");
NPL.load("(gl)script/apps/GameServer/GSL_serverproxy.lua");
NPL.load("(gl)script/apps/GameServer/GSL_serveragent.lua");
NPL.load("(gl)script/ide/Debugger/NPLProfiler.lua");

local GSL_server = commonlib.gettable("Map3DSystem.GSL_server");
local GSL_client = commonlib.gettable("Map3DSystem.GSL_client");
local GSL = commonlib.gettable("Map3DSystem.GSL");
local GSL_msg = commonlib.gettable("Map3DSystem.GSL.GSL_msg");
local npl_profiler = commonlib.gettable("commonlib.npl_profiler");

local pairs = pairs
local ipairs = ipairs
local tostring = tostring
local tonumber = tonumber
local type = type
local table_insert = table.insert

NPL.load("(gl)script/apps/GameServer/GSL_opcode.lua");

-- private: client state
local clientstate = {
	-- client has been reset
	none = nil,
	-- contacting gateway
	gateway = 1,
	-- sending normal update with grid server
	normalupdate = 2,
	-- disconnected from server, because of time out.
	-- disconnected = 3,
}

-- the GSL.client class template
local client = commonlib.inherit(nil, 
{
	-- client session key, it is regenerated each time we are connecting to a user server. 
	sessionkey = ParaGlobal.GenerateUniqueID(),
	-- client version
	ClientVersion = 1,
	-- required server version
	ServerVersion = 1,
	-- player agent. 
	playeragent = nil,
	-- server agents on client, where agents[jid] = {agent}.
	agents = {},
	-- number of active agent in the scene
	agentcount = 0,
	-- a pool of timed out agents
	timeoutagents = {},
	-- the nid of this client.
	nid = nil,
	-- game server nid that this client is connecting
	gameserver_nid = nil,
	-- world server id that this client is connecting. 
	worldserver_id = nil,
	-- whether this client is emulated. 
	IsEmulated = nil,
	-- LoginServer will be forced to login to this world regardless the current world.
	EmuUser_worldpath = nil,
	-- private: keep a reference to the world path. this is sent automatically and should not be modified by users.
	worldpath = nil,
	-- if a client shall only send a message to the server every 3 seconds and after it receives the last server message. 
	-- if the client does not receive message from server within this time, it will continue to wait until ServerTimeOut
	NormalUpdateInterval = 3000,
	-- interval to check for avatar changes with this interval. 
	RealTimeInterval = 300,
	-- How many ms to send pos interval. This can be nil, if position is only sent via normal update. if not nil, we will send position update as real time message, so that position are synced more precisely. 
	-- The recommended value for a small world is 500. 
	RealtimePositionUpdateInterval = nil,
	-- internally used. Only used when RealtimePositionUpdateInterval is not nil.
	TimeLeftForNextPositionUpdate = 0,
	-- if true, we will send CS_RealtimeUpdate messages to server at RealTimeInterval
	-- TODO: when set to true, there is bug, where the normal update must be send once prior to real time message, otherwise player info are not synced. 
	bSendRealTimeMessage = true,
	-- private: this is for sending the normal update during the real time interval. 
	TimeLeftForNextNormalUpdate = 0,
	-- OBSOLETED since we use persistent connection now: if the client does not receive any messages from the server for 10 seconds. It will send the normal update again. it is usually twice of NormalUpdateInterval.
	MaxNormalUpdateInterval = 6000,
	-- OBSOLETED since we use persistent connection now: if the server is not responding in 10 seconds, we will report to user about connecion lost or unsuccessful. 
	ServerTimeOut = 10000,
	-- if an agent is not active for this time, it will be removed from the scene
	AgentTimeOut = 10000,
	-- the gate way server proxy object 
	gatewayProxy = nil, 
	-- the grid node server proxies. mapping from grid node id to proxy object
	gridnodeProxies = nil,
	-- we will need to connect to all grid node servers within 30 meters, as agent or observers.
	sense_radius = 30,
	state = clientstate.none,
	-- increased by one eact time a normal update is sent
	timeid = 1,
	-- the client session id is increased by 1 everytime we signin a world. 
	-- The grid node server will remember it when it receives the CS_Login message and forward this id in all its subsequent messages. 
	-- the client therefore can use this id to identify if the a received server message is from a valid session. 
	-- we usually refer this id as cid on the server side. 
	client_session_id=nil,
	-- boolean: if true, we will send realtime updates to the server even there is only one player in the scene. Default is false, where no real time messages are sent if there is only a single player. 
	-- setting this to nil can save lot of bandwidth, especially for less crowded worlds like private home world. 
	EnableMonoSend = true,
	-- a mapping from handler name to handler instance, it allows third party to extend GSL_client functionalities
	handlers = nil,
	-- a table mapping from handler name to function. Known handlers are below 
	-- OnLoginNode: callback whenever a new grid node is found.function(client, proxy) end
	-- OnLogoutNode: callback whenever we log out a grid node. function(client, proxy) end
	-- OnAgentLeave: callback function whenever an agent leaves the world. function(client, agent) end, where client is this GSL_client and agent is the GSL_agent table. 
	-- OnAgentJoin: callback function whenever an agent joins the world. function(client, agent) end, where client is this GSL_client and agent is the GSL_agent table. 
	--		this function may be called many times on the first normal update receive, since all agents will join on start up.
	callbacks = nil,
	bCanReceive = true,
})
GSL.client = client;

-- all known clients, mapping from game_server_nid to client object. 
-- There can only be one client connecting to one server nid. For multiple user emulations. One can use multiple game_server_nid mapping to the same physical game server. 
local clients = {};

-- class constructor 
-- if there is only one instance, just use the default GSL_client object without calling new() method.
-- @param o: if emulated, use new({IsEmulated=true, nid=nid})
function client:ctor ()
	-- force emulation. 
	if(self.nid) then
		-- TODO: authenticate as nid. 
	end
	if(self.nid) then
		self.nid = tostring(self.nid);
	end
	-- create gateway
	self.gatewayProxy = Map3DSystem.GSL.ServerProxy:new({
			DefaultFile = "script/apps/GameServer/GSL_gateway.lua",
			MaxTimeOutRetry = 0,
		});
	-- create player agent		
	if(self.nid) then	
		self.playeragent = GSL.agent:new({nid = self.nid});
	end	
	self.agents = {};
	self.ServerObjects = {};
	-- this is not reset during self:Reset().
	self.timeoutagents = {}; 
	self.timeid = 1;
	self.handlers = {};
	self.callbacks = {};
	
	Map3DSystem.GSL.client.config:load(commonlib.getfield("Map3DSystem.options.clientconfig_file"))
end
client.config = commonlib.gettable("Map3DSystem.GSL.clientconfig");
--------------------------
-- public functions
--------------------------

-- register a handler. it is like a plugin architecture for message handling for a given GSL_client. 
-- please see muc_handler.lua for multi user chat handler. 
-- @param handler_name: it can be any string as key. It will replace handler with the same name. 
-- @param handler: the handler class object, it must implement certain function. 
function client:RegisterHandler(handler_name, handler)
	if(handler and handler_name) then
		self:log(string.format("GSL_client registered handler: %s", tostring(handler_name)));
		self.handlers[handler_name] = handler;
		if(handler.OnRegisterHandler) then
			handler:OnRegisterHandler(self);
		end
	end	
end

-- unregister handler. 
function client:UnRegisterHandler(handler_name)
	local handler = self.handlers[handler_name];
	if(handler) then
		self.handlers[handler_name] = nil;
		if(handler.Reset) then
			handler:Reset();
		end	
	end	
end

-- register a handler. it is like a plugin architecture for message handling for a given GSL_client. 
-- please see muc_handler.lua for multi user chat handler. 
-- @param handler_name: it can be any string as key. It will replace handler with the same name. 
-- @param handler: the call back function (client, ...)  end
function client:AddEventListener(event_name, handler)
	if(handler and event_name) then
		self:log(string.format("GSL_client added event listener: %s", tostring(event_name)));
		self.callbacks[event_name] = handler;
	end	
end

-- unregister handler. 
function client:RemoveEventListener(event_name)
	local handler = self.callbacks[event_name];
	if(handler) then
		self:log(string.format("GSL_client removed event listener: %s", tostring(event_name)));
		self.handlers[event_name] = nil;
	end	
end

-- fire a given event
function client:FireEvent(event_name, ...)
	local handler = self.callbacks[event_name];
	if(handler) then
		handler(self, ...);
	end
end

-- whether this client is signed in 
function client:IsSignedIn()
	return self.state ~= clientstate.none;
end

-- logout any active gridnode and stop receiving any messages from server. 
-- call this function whenever we are trying to load a new world without breaking the current gateway connection. 
-- whether we will receive any message from the server
function client:EnableReceive(bCanReceive)
	self.bCanReceive = bCanReceive;

	if(not bCanReceive) then
		-- send CS_Logout packets to not touched proxies in the last frame. 
		if(self.activeProxies) then
			local key, _;
			for key, _ in pairs(self.activeProxies) do
				local proxy = self.gridnodeProxies[key];
				if(proxy) then
					self:log("logging out grid node: (%s, %s)", tostring(proxy.nid), tostring(proxy:GetKey()))
					-- logout proxy, but do not delete it since we may reuse it again. 
					proxy:Logout();
					self:FireEvent("OnLogoutNode", proxy);
				end	
			end
		end

		-- close normal update timer, so that position update are no longer sent.
		if(self.timer) then
			self.timer:Change();
		end
	end
end

-- regenerate session and become a unconnected client. This is usually called by GSL.Reset() 
function client:Reset()
	self:log(" client is reset")
	
	self:InvokeHandler("Reset");
	
	-- reset all handlers. 
	local key, handler 
	for key, handler in pairs(self.handlers) do
		if(handler.Reset) then
			handler:Reset();
		end
	end
	
	-- regenerate session
	self.sessionkey = ParaGlobal.GenerateUniqueID();
	
	self.state = clientstate.none;
	
	self:ResetWorld();
	
	-- close timer
	if(self.timer) then
		self.timer:Change();
	end
		
	-- break connections with gateway server proxy
	if(	self.gatewayProxy) then
		self.gatewayProxy:Reset();
	end
	
	-- break connections with grid server proxies if any. 
	if(self.gridnodeProxies) then
		local _, gridProxy
		for _, gridProxy in pairs(self.gridnodeProxies) do
			gridProxy:Reset();
		end
	end	
	self.gridnodeProxies = {};
	
	self.state = clientstate.none;
end

-- clean up world related objects, such as agents, server object.
function client:ResetWorld()
	-- make all agents to timeout queue for later reuse. 
	local key, agent;
	for key, agent in pairs(self.agents) do
		agent:Renew();
		self.timeoutagents[key] = agent;
	end
	
	-- create player agent		
	if(self.nid) then	
		self.playeragent = GSL.agent:new({nid = self.nid});
	end	
	
	self.agents = {};
	self.agentcount = 0;

	if(self.ServerObjects) then
		-- call on destroy for client side server object. 
		local key, server_object
		for key, server_object in pairs(self.ServerObjects) do
			if(server_object.OnDestroy) then
				server_object:OnDestroy();
			end
		end
	end
	self.ServerObjects = {};
	-- self.timeid = 1;
	
	self.TimeLeftForNextNormalUpdate = 0;
end

-- tricky: the first id is based on current time. 
local client_session_id=(math.floor(ParaGlobal.timeGetTime()/1000/60))%100;
-- get next session id: there is still a very slight chance that session is same between client logins. 
-- we will ignore it anyway. 
function client:GetNextSessionID()
	client_session_id = client_session_id + 1;
	return client_session_id;
end

-- output a log message
function client:log(...)
	LOG.std("", "user", "GSL", tostring(self.nid)..":"..LOG.tostring(...));
end

-- dump the current GSL status. 
function client:Dump()
	self:log("Dumping GSL client of (%s):", tostring(self.nid))
	commonlib.log("   state: %s\n", tostring(self.state));
	commonlib.log("   sessionkey: %s\n", tostring(self.sessionkey));
	commonlib.log("   gateway: %s\n", tostring(self.gatewayProxy.nid));
	commonlib.log("   agents: \n");
	local agentCount=0;
	local _, agent
	for _, agent in pairs(self.agents) do
		agentCount = agentCount+1;
		log("    -->");agent:Dump();
	end
	commonlib.log("   #agents: %d\n", agentCount);
	
	commonlib.log("   timeoutagents: \n");
	agentCount=0;
	for _, agent in pairs(self.timeoutagents) do
		agentCount = agentCount+1;
		log("    --> ");agent:Dump();
	end
	commonlib.log("   #timeoutagents: %d\n", agentCount);
	
	commonlib.log("   gridnodeProxies: \n");
	local key, proxy
	for key, proxy in pairs(self.gridnodeProxies) do
		log("    --> ");proxy:Dump();
	end
end

-- it will create the agent structure if it does not exist
-- it will revive and reuse the self.timeoutagents if it exist. 
function client:GetAgent(nid)
	if(not nid) then return end
	local agent = self.agents[nid];
	if(not agent) then
		if(self.nid == nid) then
			return self:GetPlayerAgent();
		end
		agent = self.timeoutagents[nid];
		if(agent) then
			-- revive from timeout agent pool
			self.agents[nid] = agent;
			self.timeoutagents[nid] = nil;
		else
			-- create a new one. 
			agent = GSL.agent:new{nid = nid};
			self.agents[nid] = agent;
		end
		self.agentcount = self.agentcount + 1;
		self:FireEvent("OnAgentJoin", agent)
	end	
	return agent;
end

-- Find user by nid
-- @param nid: should be string. 
-- @return nil or the agent object.
function client:FindAgent(nid)
	if(not nid or self.nid == nid) then
		return self:GetPlayerAgent();
	else
		return self.agents[nid];
	end
end

-- return iterator of nid, agent pair
function client:EachAgent()
	return pairs(self.agents);
end

-- Find user by nid
-- @param nid: should be string. 
function client:HasAgent(nid)
	local agent = self.agents[nid];
	if(agent) then
		return true;
	elseif(nid==self.nid) then
		return true;
	end
end

-- get the agent count
function client:GetAgentCount()
	return self.agentcount;
end

-- login to a server with a known nid name, please note an authenticated connection with the game server must be established prior to this call. 
-- if we have a previous connection with the same gateway, all grid nodes sessions are reused. and the function returns immediately.
-- @param nid: should be game server nid. if this is "localuser" and ws_id is "", we will use current thread for debugging
-- @param ws_id: the world id inside a game server.
-- @param worldpath: if nil, the current world path ParaWorld.GetWorldDirectory() is used. 
-- @param params: additional params to be passed to remote server. it also be a string or number, in which case it will be treated as nid. 
--  nid: if nil or "", homegrid is disabled. Otherwise it is the nid of the world path. Each nid of the same world path has a single grid node instance on the server side. 
--  is_local_instance: boolean, whether the game world is on the same world server when user switches world. 
function client:LoginServer(nid, ws_id, worldpath, params)
	self:EnableReceive(true);
	Map3DSystem.GSL.client.config:CheckLoad();

	worldpath = worldpath or self.EmuUser_worldpath or ParaWorld.GetWorldDirectory()
	
	local params_type = type(params);
	local gridrule_id;
	if(params_type == "number" or params_type == "string") then
		params = {nid = tostring(params)};
	elseif(params_type == "table") then
		gridrule_id = params.gridrule_id;
	end
	
	if(params and params.nid) then
		if(System.options.isAB_SDK)then
			if(params.force_sdk_nid) then
				LOG.std("","debug", "GSL", "Note we are ignoring nid %s when isAB_SDK is false. This is easy to debug.", params.nid)
				params.force_sdk_nid = nil;
				params.nid = nil;
			elseif(params.force_sdk_nid == false) then
				params.force_sdk_nid = nil;
			else
				_guihelper.MessageBox("SDK版本: 是否用GameServer代替HomeServer？", function(res)
					if(res and res == _guihelper.DialogResult.Yes) then
						params.force_sdk_nid = true;
					else
						params.force_sdk_nid = false;
					end
					self:LoginServer(nid, ws_id, worldpath, params)
				end, _guihelper.MessageBoxButtons.YesNoCancel);
				return;
			end
		end
		if(params.nid) then
			local nid_random = string.match(tostring(params.nid), "#(%d+)");
			if(nid_random) then
				params.nid = tostring(math.random(1,nid_random)+1);
				LOG.std("","debug", "GSL", "using a random nid %s from [1,%d]+1", params.nid, nid_random)
			end
			worldpath = format("%s?nid=%s", worldpath, tostring(params.nid));
		end
	end
	if(params) then
		if(params.match_info and params.match_info.teams) then
			-- clean up match_info struct to make it more compact. 
			params.match_info = commonlib.deepcopy(params.match_info);
			local _, team
			for _, team in ipairs(params.match_info.teams) do
				team.match_info = nil;
			end
		end
	end
	if(self.gameserver_nid and nid ~= self.gameserver_nid) then
		-- remove from client pool
		clients[self.gameserver_nid] = nil;
	end
	clients[nid] = self;
	
	-- game server nid. 
	self.gameserver_nid = nid;
	self.worldserver_id = ws_id;
	self.login_params = params;
	
	-- keep the world path. 
	self.worldpath = worldpath;
	
	-- get the local user's nid
	self.nid = GSL.GetNID();
	if(self.nid) then
		self.nid = tostring(self.nid);
	end
	
	-- regenerate session id. 
	self.client_session_id = self:GetNextSessionID();

	LOG.std("", "system", "GSL", "GSL_client(session %d) login to world %s with params: %s", self.client_session_id, tostring(worldpath), commonlib.serialize_compact(params));
	
	

	-- if a different gateway is found, logout the current gateway. 
	if(self.gatewayProxy.nid~=nid or self.gatewayProxy.ws_id~=ws_id) then
		self:LogoutServer();
		-- reset client since we are connecting again. 
		self:Reset();
		
		-- inform user we are connecting to server
		--GSL.Log("正在连接 GSL server "..nid);
		LOG.std("", "system", "GSL", "connecting to GSL gateway %s(%s)", nid, ws_id);
		
		self.gridrule_id = gridrule_id;

		-- set to the new server
		self.gatewayProxy:Init(nid, ws_id, worldpath);
		
	elseif(self.state ~= clientstate.none) then	
		-- since we have gridnode in home server, we shall not reuse gridnode even if world path are the same. 
		local bReuseGridNode = false;
		-- if we have a previous connection with the same gateway, all grid nodes sessions are reused.
		if(not bReuseGridNode or self.gatewayProxy.worldpath ~= worldpath or self.gridrule_id ~= gridrule_id) then
			self.gatewayProxy.worldpath = worldpath
			
			-- we shall also log out previous grid node server
			if(self.gridnodeProxies) then
				local alienworlds;
				for key, gridProxy in pairs(self.gridnodeProxies) do
					-- Note: we will logout all regardless of whether it is different from current, since some proxy may have same worldpath and id but internally different servers.
					if(not bReuseGridNode or gridProxy.worldpath ~= worldpath or self.gridrule_id ~= gridrule_id) then
						alienworlds = alienworlds or {};
						alienworlds[key] = true;
					end
				end
				if(alienworlds) then
					for key, _ in pairs(alienworlds) do
						local proxy = self.gridnodeProxies[key];
						if(proxy) then
							self:log("logging out and remove grid node: (%s, %s)", tostring(proxy.nid), tostring(proxy:GetKey()))
							proxy:Logout();
							self:FireEvent("OnLogoutNode", proxy);
							self.gridnodeProxies[key] = nil;
						end
					end
				end
			end	
			
			self.gridrule_id = gridrule_id

			-- clear world related entities
			self:ResetWorld();
		end	
	end
	
	-- set the timer to send client normal update to server
	self.timer = self.timer or commonlib.Timer:new({callbackFunc = function(timer)
		self:OnTimer();
	end})
	self.timer:Change(300, self.RealTimeInterval);
	self.state = clientstate.normalupdate;
	
	-- we have setup the gateway, so send the first agent normal update packet to the world server
	self:SendNormalUpdate();
end

-- logout the current connected gateway and grid servers
-- @param bSilent: if true, we shall inform the UI. 
function client:LogoutServer(bSilent)
	local nid;
	if(self.gatewayProxy) then
		nid = self.gatewayProxy.nid;
	end
	self:Reset();
	if(not bSilent) then
		-- send game event 
		Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_GSL_SIGNEDOUT, serverNID=nid})
	end
end

-- disconnect 
function client:Disconnect()
	if(self.gameserver_nid) then
		self.gameserver_nid = nil;
		Map3DSystem.User.IsRedirecting = true;
		NPL.reject(self.gameserver_nid);
	end	
end

-- get gateway round trip time for debugging purposes. 
function client:QueryGateway()
	self.gatewayProxy:Send({
		type = GSL_msg.CS_QUERY,
		fields = {"systime"},
		forward = tostring(ParaGlobal.timeGetTime()),
	})
end

-- send a global chat message to the server. the server may charge for the service. 
-- @param text: text string
-- @param is_bbs: true to send to users on all servers. if nil, it is a per thread message. 
-- @param callbackFunc: called when message is successfully sent
-- @param password: the gm password, usually nil.
function client:SendChat(text, is_bbs, callbackFunc, password )
	if(type(text) == "string" and #text<512) then
		text = text:gsub("\n", "");
		self.OnServerChatSucceedCallback = callbackFunc;
		self.gatewayProxy:Send({
			type = GSL_msg.CS_Chat,
			text = text,
			is_bbs = is_bbs,
			password = password, 
		})
	end
end

-- send a message to gateway. This allow us to send any message that can be processed by gateway. 
-- currently {type = GSL_msg.CS_IM, } is commonly used. 
-- @param msg: such as {}
function client:SendToGateway(msg)
	return self.gatewayProxy:Send(msg)
end

-- get a ready only copy of currently connected server info table. 
-- it will return nil if not connected yet. 
function client:GetServerInfo()
	if(self.gatewayProxy.SignedIn) then
		return self.gatewayProxy;
	end
end

--------------------------
-- private functions:
--------------------------

-- get the agent representing the current player. 
function client:GetPlayerAgent()
	if(not self.playeragent) then
		self.playeragent = GSL.agent:new({nid = self.nid,});
	end
	return self.playeragent;
end

-- invoke a function in all handlers
-- @param func_name: a string of function name 
-- @param ...: any params to pass to the function
-- @return: return true any of the handler has returned true and subsequent functions are not invoked if previous one returns true. 
function client:InvokeHandler(func_name, ...)
	local res;
	-- invoke all handlers. 
	local key, handler 
	for key, handler in pairs(self.handlers) do
		local func = handler[func_name];
		if(func) then
			res = func(handler, ...);
			if(res) then
				return true;
			end
		end
	end
	return;
end

-- a timer that periodically send messages 
function client:OnTimer()
	local curTime = ParaGlobal.timeGetTime();

	self.TimeLeftForNextNormalUpdate = self.TimeLeftForNextNormalUpdate+self.RealTimeInterval;
	local bSendPosUpdate_;
	if(self.RealtimePositionUpdateInterval) then
		self.TimeLeftForNextPositionUpdate = self.TimeLeftForNextPositionUpdate+self.RealTimeInterval;
		if(self.TimeLeftForNextPositionUpdate > self.RealtimePositionUpdateInterval) then
			self.TimeLeftForNextPositionUpdate = self.TimeLeftForNextPositionUpdate - self.RealtimePositionUpdateInterval;
			bSendPosUpdate_ = true;
		end
	end

	self:InvokeHandler("OnTimer", curTime, self.TimeLeftForNextNormalUpdate > self.NormalUpdateInterval);
	
	-- LOG.std(nil, "info", "GSL_client", {TimeLeftForNextNormalUpdate = self.TimeLeftForNextNormalUpdate, state = self.state})
	if(self.TimeLeftForNextNormalUpdate > self.NormalUpdateInterval) then
		--
		-- this is low frequency normal update timer
		--
		self.TimeLeftForNextNormalUpdate = self.TimeLeftForNextNormalUpdate - self.NormalUpdateInterval;
		self.HalfNormalUpdateCalled = false;
		
		if(self.state == clientstate.normalupdate) then
			-- send normal update to server
			self:SendNormalUpdate();
		else
			return
		end
		
		--
		-- check for any agent time out
		--
		local _, agent;
		local count = 0;
		local TimedOutAgents;
		for _, agent in pairs(self.agents) do
			if(self.nid ~= agent.nid) then
				if(agent:CheckTimeOut(curTime, self.AgentTimeOut)) then
					-- if the agent is timed out, remove character and make inactive 
					LOG.std("", "user", "GSL", "GSL(%s) user left us(%s) \n", agent.nid, tostring(self.nid));
				
					if(agent:cleanup()) then
						if(not self.IsEmulated) then
							-- send game event 
							Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_GSL_USER_LEAVE, user_nid=agent.nid})
						end
					
						-- Mark the agent nid to be deleted after the iteration
						TimedOutAgents = TimedOutAgents or {};
						TimedOutAgents[agent.nid] = true;
					end	
				else	
					count = count +1;
				end
			end
		end
		
		-- Note: currently, client agents are only moved from agents pool or loggedout agent pool,
		--  so they are never deleted from memory, even self:Reset() is called.
		if(TimedOutAgents~=nil) then
			local key, _;
			for key, _ in pairs(TimedOutAgents) do
				self.timeoutagents[key] = self.agents[key];
				self.agents[key] = nil;
				self.agentcount = self.agentcount - 1;
				self:FireEvent("OnAgentLeave", self.timeoutagents[key])
			end
		end
	end

	--
	-- this is high frequency real time timer	
	--
	if(self.state == clientstate.normalupdate and self.bSendRealTimeMessage) then
			
		if(not self.HalfNormalUpdateCalled and self.TimeLeftForNextNormalUpdate >= self.NormalUpdateInterval*0.5) then
			-- this is a half frequency timer. 
			self.HalfNormalUpdateCalled = true;
			-- TODO: add code that is executed at half the normal update interval.
		end

		if(bSendPosUpdate_) then
			-- send position update to server at higher frequency than normal update. 
			local agent = self:GetPlayerAgent();
			if(not self.IsEmulated and agent:IsIntact() and not agent.is_local) then
					
				local proxy = self:FindBestGridProxy(self.gatewayProxy.worldpath, agent.x, agent.y, agent.z)
				if(proxy) then
					-- NOTE: only update from real character when we are not emulating the client
					local x,y,z = self:GetCurrentPlayerPosition();
					local rx, ry, rz = agent:UpdatePosition(x,y,z,0.01);
					if(rx) then
						self:AddRealtimeMessage({name="rx", value=rx}, "data")
					end
					if(ry) then
						self:AddRealtimeMessage({name="y", value=ry}, "data")
					end
					if(rz) then
						self:AddRealtimeMessage({name="rz", value=rz}, "data")
					end
				end
			end
		end

		-- send real time update to server
		-- NOTE: we should only send queued command, like walk point, etc to target. 
		self:SendRealtimeUpdate(curTime);
	end
end

-- when some remote user creations are received by this computer, it will be applied in this world, however, without writing into the history. 
function client:ApplyCreations(creations)
	if(creations==nil) then return end
	
	for i = 1, table.getn(creations) do
		-- create without writing to history
		local new_msg = {
			SkipHistory = true,
		}
		commonlib.partialcopy(new_msg, creations[i]);
		Map3DSystem.SendMessage_obj(new_msg);
	end
end

-- when some remote user env updates are received by this computer, it will be applied in this world, however, without writing into the history. 
function client:ApplyEnvs(env)
	if(env==nil) then return end
	
	for i = 1, table.getn(env) do
		-- create without writing to history
		local new_msg = {
			SkipHistory = true,
		}
		commonlib.partialcopy(new_msg, env[i]);
		Map3DSystem.SendMessage_env(new_msg);
	end
end

-- get available best server grid proxy for a given world path. 
-- a best grid proxy is a proxy that is smallest in size. 
-- @param worldpath: the world that the grid node is in. 
-- @param x, y, z: a position that the grid node contains. 
-- @param IsObserver: true if we are just getting for an observer node. 
function client:FindBestGridProxy(worldpath, x, y, z)
	local candidate = nil;
	local key, proxy
	for key, proxy in pairs(self.gridnodeProxies) do
		if(proxy:Contains(worldpath, x, y, z)) then
			if(not candidate or not candidate.size or (proxy.size and proxy.size<candidate.size)) then
				candidate = proxy
			end
		end	
	end
	return candidate;
end

-- remove grid proxy
function client:RemoveGridProxy(proxy)
	if(proxy) then
		self.gridnodeProxies[proxy:GetKey()] = nil;
	end	
end

-- Create a connected grid node server proxy, each grid node is responsible for simulating a specific region in the world.
-- @param msg: the reply NPL message from SC_Login_Reply. It should contain grid node session key and info {gk, gnid, gx,gy,gsize, worldpath}
-- @return: return the proxy object if succeeded
function client:CreateGridNodeProxy(msg)
	local proxy = Map3DSystem.GSL.ServerProxy:new({DefaultFile="script/apps/GameServer/GSL_grid.lua",
		id = msg.gid,
		UserRole = msg.Role,
		x = msg.gx, y=msg.gy, size=msg.gsize,
		proxy = msg.proxy,
	});
	proxy:Init(self.gatewayProxy.nid, self.gatewayProxy.ws_id, msg.worldpath);

	-- remove identical one
	self.gridnodeProxies[proxy:GetKey()] = proxy;
	
	proxy:MakeReady();
	self:log(" new gridnode found: %s(%s) at %s(%s, %s)", tostring(proxy.npl_addr_prefix), tostring(proxy:GetKey()), tostring(proxy.worldpath), tostring(proxy.x), tostring(proxy.y));

	self:Dump(); -- let us examine the state for this release. 
	
	self:FireEvent("OnLoginNode", proxy);
	return proxy;
end

-- get position for gsl update
function client:GetCurrentPlayerPosition()
	local player = ParaScene.GetObject(self.nid or "<player>");
	
	if(player:ToCharacter():IsMounted()) then
		local BeingMountedObj = player:GetRefObject(0);

		if(BeingMountedObj:IsValid()) then
			-- it has to be an nid string of number
			if( tonumber(BeingMountedObj.name)~=nil ) then 
				return BeingMountedObj:GetPosition();
			end
		end
	end
	return player:GetPosition();
end

-- send a normal update packet to the grid node containing the request location. 
-- if no grid node connection is available for the region, we will ask the gateway for it. 
function client:SendNormalUpdate()
	-- increase client time id. 
	self.timeid = self.timeid + 1;
	
	local agent = self:GetPlayerAgent();
	
	if(not self.IsEmulated) then
		agent.x,agent.y,agent.z = self:GetCurrentPlayerPosition();
	elseif(not (agent.x and agent.y and agent.z) ) then
		agent.x,agent.y,agent.z = 0,0,0;
	end
						
	-- check 5 points near the center of the player. Pos (7,9,5,1,3) on the numeric pad, where 5 is the player position. 
	local nIndex, rx, ry;
	local excludeList = {};
	
	local nToIndex = 4;
	
	local curTime = ParaGlobal.timeGetTime();
	for nIndex = 0,nToIndex do
		if(nIndex == 0) then
			rx, ry = 0,0;
		elseif(nIndex == 1) then
			rx, ry = self.sense_radius,self.sense_radius;
		elseif(nIndex == 2) then
			rx, ry = self.sense_radius,-self.sense_radius;
		elseif(nIndex == 3) then
			rx, ry = -self.sense_radius,-self.sense_radius;
		elseif(nIndex == 4) then
			rx, ry = -self.sense_radius,self.sense_radius;		
		end
		local x,y,z = agent.x+rx, agent.y, agent.z+ry
		
		local proxy = self:FindBestGridProxy(self.gatewayProxy.worldpath, x, y, z)
		if(proxy) then
			if(not excludeList[proxy:GetKey()]) then
				excludeList[proxy:GetKey()] = true;
				-- send agent or observer normal update to this grid node proxy server
				if(nIndex == 0) then
					-- request agent normal update. We no longer check for state now. 
					--if(proxy:CheckState(curTime)) then
						-- this will let us send relative position. 
						agent.gx, agent.gz= proxy.from_x, proxy.from_y;
						
						-- NOTE: only update from real character when we are not emulating the client
						if(not self.IsEmulated) then
							agent:UpdateFromPlayer(ParaScene.GetObject(self.nid or "<player>"), self.timeid);
						else
							agent:UpdateFromSelf(self.timeid);
						end	
						
						-- TODO: we need to find a way to send relative position. 
						local agentStream = {data = agent:GenerateUpdateStream(proxy.ct) }
						--commonlib.log("%s(%s): sending normal update:----------->\n", self.nid, proxy:GetJC().User);
						-- print(agentStream.data)
						
						--if(self.IsEmulated) then
							--commonlib.log("emu sent %s last time %s\n", tostring(curTime), tostring(proxy.LastSendTime))
						--end
						
						-- if proxy:CanEdit() then send creations related stuffs to server
						--if (proxy:CanEdit() and (not self.IsEmulated) ) then
							--agent:GenerateCreationStream(agentStream);
						--end
						
						-- normal update
						proxy:Send({
							type = GSL_msg.CS_NormalUpdate,
							-- client agent stream
							agent = agentStream,
							-- forward server time
							st = proxy.st,
							-- send client time
							ct = self.timeid,
							-- recover list if any
							recover = proxy.recoverlist,
							-- whether this is a dummy agent that will not receive other agents' updates. 
							dummy = agent.dummy,
							-- this id changes whenever we signin a new gridnode. It allows us to reject unused messages from server. 
							cid = if_else(self.add_cid, self.client_session_id, nil),
						});
						proxy.recoverlist = nil;
					--end
				else
					--if(proxy:CheckState(curTime)) then
						-- request observer agent update
						proxy:Send({
							type = GSL_msg.CS_ObserverUpdate,
							-- observing agent position, NOTE: they are not sent in this release
							-- x=x, y=y,z=z,
							-- forward server time
							st = proxy.st,
							-- send client time
							-- ct = self.timeid,
							-- recover list if any
							recover = proxy.recoverlist,
							-- this id changes whenever we signin a new gridnode. It allows us to reject unused messages from server. 
							cid = if_else(self.add_cid, self.client_session_id, nil),
						});
						proxy.recoverlist = nil;
					--end	
				end	
			end	
			--self:log("state %s, last sent time %s, curtime %s", tostring(proxy.state), tostring(proxy.LastSendTime), tostring(curTime));	
		else
			-- we do not have a proxy connection in the region, ask the gateway about it. 
			if(self.gatewayProxy:CheckState(curTime)) then
				LOG.std("", "system", "GSL", "connecting to gate way world path %s x:%f y:%f z:%f", self.gatewayProxy.worldpath, x,y,z);
				
				self.gatewayProxy:Send({
					type = GSL_msg.CS_Login,
					worldpath = self.gatewayProxy.worldpath,
					x = x,
					y = y,
					z = z,
					-- this id changes whenever we signin a new gridnode. It allows us to reject unused messages from server. 
					cid = self.client_session_id, 
					params = self.login_params,
				})
			end
		end
	end
	
	-- send CS_Logout packets to not touched proxies in the last frame. 
	if(self.activeProxies) then
		local key, _;
		for key, _ in pairs(self.activeProxies) do
			if(not excludeList[key]) then
				local proxy = self.gridnodeProxies[key];
				if(proxy) then
					self:log(" logging out grid node: (%s, %s)", tostring(proxy.nid), tostring(proxy:GetKey()))
					-- logout proxy, but do not delete it since we may reuse it again. 
					proxy:Logout();
					self:FireEvent("OnLogoutNode", proxy);
				end	
			end
		end
	end
	self.add_cid = nil;
	self.activeProxies = excludeList;
end

-- add a real time message to server on behalf of the current avatar.
-- It will be sent almost at real time to the server. 
-- The server will forward it to other connected player almost at real time too. 
-- the most common use of real time message is BBS chat room. 
-- e.g. client:AddRealtimeMessage({name="chat", value="hello world"})
-- @param msg: it is a table of {name, value}, name and value should be encoded with opcodes during transmission. 
-- @param queue_name: to which queue to add the message. "rt" or "data", if nil it will default to "rt". 
-- for supported item.name, please see GSL_opcodes.lua and Map3DSystem.GSL.rt_opcodes
function client:AddRealtimeMessage(msg, queue_name)
	if(self.state == clientstate.normalupdate and self.bSendRealTimeMessage) then
		if(self:InvokeHandler("AddRealtimeMessage", msg)) then
			return
		end
		
		local agent = self:GetPlayerAgent();
		if(agent) then
			if(not queue_name or queue_name == "rt") then
				agent:AddToRealtimeQueue(msg);
			elseif(queue_name == "data") then
				agent:AddToDataQueue(msg);
			end
		end	
	end	
end

-- send a most realtime message to a server object
-- internally, it will queue up messages and send together at quick interval. 
-- alternatively, one can call GetRealtimeMessageQueue(sid) and modify the queue directly. 
-- @param sid: server object id. 
-- @param msg: the message to send. 
-- @param channel_name: if not nil, msg[channel_name] is used to determine if message should be overriden.
function client:SendRealtimeMessage(sid, msg, channel_name)
	if(self:InvokeHandler("SendRealtimeMessage", msg)) then
		return
	end
	self.so = self.so or {};
	if(self.so[sid]) then
		if(not channel_name) then
			table_insert(self.so[sid], msg);
		else
			local so_msgs = self.so[sid];

			local i, is_overriden;
			local count = #so_msgs
			for i=1, count do
				local msg_ = so_msgs[i];
				if(msg_[channel_name] == msg[channel_name]) then
					so_msgs[i] = msg;
					is_overriden = true;
					break;
				end
			end
			if(not is_overriden) then
				so_msgs[count + 1] = msg;
			end
		end
	else
		self.so[sid] = {msg};
	end	
end

-- Over the realtime message queue of a server object. 
-- This give us full control of what is being sent during a given interval. 
-- One can also use client:GetRealtimeMessageQueue(sid) to get the queue and write to it directly. 
-- @param sid: server object id. 
-- @param msg: the message to send. 
function client:OverideLastRealtimeMessage(sid, msg)
	local msg_queue = self:GetRealtimeMessageQueue(sid)
	local nCount = #msg_queue;
	if(nCount > 0) then
		msg_queue[nCount] = msg
	else
		msg_queue[1] = msg;
	end
end

-- Get the realtime message queue of a server object for reading and writing. 
-- This give us full control of what is being sent during a given real time interval to a server object. 
-- @return always returns an table array for reading and writing. Each array item is a separate real time message. 
-- do not cache the returned table. it is temporary and will be dropped when the real time update flushes the queue to network
function client:GetRealtimeMessageQueue(sid)
	self.so = self.so or {};
	
	local msg_queue = self.so[sid]
	if(msg_queue) then
		return msg_queue
	else
		msg_queue = {};
		self.so[sid] = msg_queue;
		return msg_queue;
	end
end

-- send real time message if any. If no real time update, no messages are sent
-- please note real time messages are one directional. 
function client:SendRealtimeUpdate(curTime)
	local agent = self:GetPlayerAgent();
	if(not (agent.x and agent.y and agent.z) ) then
		agent.x,agent.y,agent.z = self:GetCurrentPlayerPosition();
	end
	
	local agentStream = {}
	if(not self.so and not agent:GenerateRealtimeStream(agentStream)) then
		return
	end
	
	-- increase client time id. 
	self.timeid = self.timeid + 1;
						
	curTime = curTime or ParaGlobal.timeGetTime();
	
	if(not self.so and not self.EnableMonoSend and self:GetAgentCount() == 0) then
		LOG.std("", "debug", "GSL", "GSL_client: ignored real time message to server because there is only one agent in the scene");
		LOG.std("", "debug", "GSL", agentStream);
		return;
	end
	
	local x,y,z = agent.x, agent.y, agent.z;
	local proxy = self:FindBestGridProxy(self.gatewayProxy.worldpath, x, y, z)
	if(proxy) then
		local so = self.so;
		self.so = nil;
		-- real time udpate
		proxy:Send({
				type = GSL_msg.CS_RealtimeUpdate,
				-- client agent stream
				agent = agentStream,
				so = so,
				-- forward server time
				st = proxy.st,
				-- send client time
				ct = self.timeid,
			}, nil, true);
	end
end

-- send a custom message to current gridnode that contains the player
function client:SendGridNodeMsg(msg)
	local agent = self:GetPlayerAgent();
	if(agent and agent.x) then
		local x,y,z = agent.x, agent.y, agent.z;
		local proxy = self:FindBestGridProxy(self.gatewayProxy.worldpath, x, y, z)
		if(proxy) then
			-- real time udpate
			proxy:Send(msg, nil, true);
		end
	end
end

-- get agent item. This allows us to get custom data stored on any other player. Custom data is not synced(even they changed) during normal update. 
-- This allows user to upload arbitrary temporary data to server that any other users can access. 
-- but data updated in this mode will not be broadcasted to the client automatically. instead other user fetch it on demand. 
-- @param agent_nid: the agent nid. 
-- @param fields: the fields can be string or an array of fields(TODO) to get. 
-- @param callbackFunc: the function(data) end, where data contains name value pairs. 
-- @param bForceRefresh: true to refetch from web. 
-- @return the field value, bAgentExist 
function client:GetAgentItem(agent_nid, fields, callbackFunc, bForceRefresh)
	if(type(fields) == "string" and agent_nid) then
		agent_nid = tostring(agent_nid);
		local local_agent = self:GetAgent(agent_nid);
		if(local_agent) then
			if(bForceRefresh) then
				self:SendGridNodeMsg({type = GSL_msg.CS_GetItem, agent_nid=agent_nid, fields={fields}})
			end
			return local_agent:GetItem(fields), true;
		end
	elseif(type(fields) == "table") then
		-- TODO: 
	end
end

-- set item name,value pair for the current player, so that other player can fetch it via client:GetAgentItem();
-- This allows user to upload arbitrary temporary data to server that any other users can access. 
-- but data updated in this mode will not be broadcasted to the client automatically. instead other user fetch it on demand. 
-- @param name: string key
-- @param value: anything but table and function. 
function client:SetAgentItem(name, value)
	self:SendGridNodeMsg({type = GSL_msg.CS_SetItem, data={[name]=value}})
end

-- create get a server object by its id
function client:CreateGetServerObject(sid)
	local sagent = self.ServerObjects[sid];
	if(not sagent) then
		-- TODO: create the server agent if not created before. 
		local npc = self.config:GetNPCTemplateBySID(sid);
		if (npc) then
			self:log("client npc (%s) is loaded", sid)
			sagent = npc:create()
			self.ServerObjects[sid] = sagent;
		end
	end
	return sagent;
end

-- get a server object by its id
function client:GetServerObject(sid)
	return self.ServerObjects[sid];
end

-- get the string or number key of the proxy in the message. 
function client:GetProxyKeyFromMsg(msg)
	return msg.id;
	--if(msg.id) then
		--if(msg.proxy and msg.proxy.addr) then
			--return (msg.proxy.addr.."/"..msg.id);
		--else	
			--return msg.id;
		--end
	--end
end

-- get grid node proxy from returned server message. 
function client:GetGridNodeProxyFromMsg(msg)
	if(msg.id) then
		return self.gridnodeProxies[msg.id];
		--if(msg.proxy and msg.proxy.addr) then
			--local key = msg.proxy.addr.."/"..msg.id;
			--return self.gridnodeProxies[key];
		--else	
			--return self.gridnodeProxies[msg.id];
		--end
	end
end

-- get most recent server time received in normal update in the format of ParaGlobal.GetTimeFormat("HH:mm:ss")
function client:GetServerTime()
	return self.svrtime;
end

-- handle server messages
function client:HandleMessage(msg, curTime)
	local nid = msg.nid;
	if(not nid) then return end
	
	if(not msg.cid) then
		-- no cid is provided, we will need to sign in again. 
		local proxy = self:GetGridNodeProxyFromMsg(msg);
		if(proxy) then
			LOG.std(nil, "warn", "GSL_client", "client receives a message with wrong client session id. should be %d but nil is seen. We will resend on next normal update", self.client_session_id or 0);
			-- we will include cid in the next messsage, in case the server has lost it. 
			self.add_cid = true;
		end
	elseif(self.client_session_id ~= msg.cid) then
		LOG.std(nil, "warn", "GSL_client", "client receives a message with wrong client session id. should be %d but %d is seen", self.client_session_id or 0, tonumber(msg.cid) or 0);
		return;
	end

	curTime = curTime or ParaGlobal.timeGetTime();
	
	if(self:InvokeHandler("HandleMessage", msg, curTime)) then
		return
	end
	
	if(msg.stime) then
		self.svrtime = msg.stime;
	end

	if(msg.type==GSL_msg.SC_RealtimeUpdate) then
		local proxy = self:GetGridNodeProxyFromMsg(msg);
		
		if(proxy) then
			proxy:OnRespond();
		else
			return
		end
				
		if (msg.agents) then
			-- update all agents
			local nid, stream;
			for nid, stream in pairs(msg.agents) do
				if(nid ~= self.nid) then
					local local_agent = self:GetAgent(nid);
					if(local_agent~=nil) then
						-- process real time message and tick the agent so that it is not timed out.
						local_agent:tick(curTime);
						if(local_agent:OnNetReceive(stream)) then
							local_agent:update_position(curTime);
						end
					end	
				end
			end
		end
		if (msg.so) then
			local sid, rt_msg
			for sid, rt_msg in pairs(msg.so) do
				local sagent = self:CreateGetServerObject(sid);
				if(sagent) then
					sagent:OnNetReceive(self, rt_msg, msg.st);
				end	
			end
		end
	elseif(msg.type==GSL_msg.SC_NormalUpdate) then
		--------------------------------
		-- grid node server send us agent update info 
		--------------------------------
		--commonlib.echo(msg);
		local proxy = self:GetGridNodeProxyFromMsg(msg);
		if(proxy) then
			proxy:OnRespond();
			proxy.ct = msg.ct;
			proxy.st = msg.st;
		else
			return
		end
		-- only update when client is not emulated. 
		if(msg.agents and not self.IsEmulated) then
			-- update all agents
			local nid, agent;
			for nid, agent in pairs(msg.agents) do
				if(nid ~= self.nid) then
					local local_agent = self:GetAgent(nid);
					if(local_agent~=nil) then
						-- set relative position origin before updating. 
						local_agent.gx, local_agent.gz = proxy.from_x, proxy.from_y;
						local_agent:UpdateFromStream(agent, msg.st);
						--commonlib.echo({"-------------\n", local_agent.x, local_agent.z})
					
						-- Note: only update if this proxy represent a region in the current world
						if(self.worldpath == proxy.worldpath) then
							local_agent:update(curTime);
						end	
					
						-- just provide the heart beat to local agent, so that they are not timed out. 
						local_agent:tick(curTime);
		
						if(not local_agent:IsIntact()) then
							if(proxy:AddToRecoverList(local_agent)) then
								LOG.std("", "warn", "GSL", "recovering intact agent %s", tostring(local_agent.nid));
							end
						end
					end
				end
			end
			if(msg.ping) then
				-- read ping CSV string to prevent agent time out on client. 
				for nid in string.gmatch(msg.ping, "[^,]+") do
					if(nid ~= self.nid) then
						local local_agent = self:GetAgent(nid);
						if(local_agent~=nil) then
							-- just provide the heart beat to local agent, so that they are not timed out. 
							local_agent:tick(curTime);
						
							if(self.worldpath == proxy.worldpath) then
								if(not local_agent:IsIntact()) then
									if(proxy:AddToRecoverList(local_agent)) then
										LOG.std("", "warn", "GSL", "recovering intact agent %s", tostring(local_agent.nid));
									end
								else
									if(not local_agent:has_avatar()) then
										-- Note: shall we revive if some player come and goes due to network connection. 
										-- we may postpone deleting an avatar if it is so frequently reappeared. 
										LOG.std("", "debug", "GSL", "ping revived %s", tostring(local_agent.nid));
										local_agent:update(curTime);
									end
								end
							end	
						end	
					end
				end
			end
			-- we do not send environment update in this release
			---- update all server creations in the message
			--self:ApplyCreations(msg.creations);
			---- update all environment update  in the messages
			--self:ApplyEnvs(msg.env);
		end	
		
		if (msg.so) then
			local sid, patch_msg
			for sid, patch_msg in pairs(msg.so) do
				local sagent = self:CreateGetServerObject(sid);
				if(sagent) then
					-- update normal update to server object
					sagent:UpdateFromMessage(patch_msg, msg.st);
					-- inform client about server object changes. 
					sagent:OnNetReceive(self, nil, msg.st);
				end	
			end
		end
	elseif(msg.type == GSL_msg.SC_GetItem) then	
		--------------------------------------
		-- gridnode replied with get item data
		--------------------------------------
		--LOG.std(nil, "debug", "gridnode SC_GetItem ", msg);
		if(type(msg.data) == "table") then
			local local_agent = self:GetAgent(msg.agent_id);
			if(local_agent) then
				local name, value;
				for name, value in pairs(msg.data) do
					local_agent:SetItem(name, value);
				end
			end
		end
	elseif(msg.type == GSL_msg.SC_Chat_REPLY) then	
		--------------------------------------
		-- gateway chat message is sent
		--------------------------------------
		if(self.OnServerChatSucceedCallback) then
			self.OnServerChatSucceedCallback();
		end

	elseif(msg.type == GSL_msg.SC_Login_Reply) then	
		--------------------------------------
		-- gateway server replied with a best grid server
		--------------------------------------
		self.gatewayProxy:OnRespond();
		
		if(msg.refused) then
			-- server rejected this client
			GSL.Log(string.format("%s 的GSL服务器拒绝了您的登陆请求", msg.from));
			self:log("grid node server %s refused us", msg.from);
			
			-- log out to prevent requesting server again like crazy.
			self:LogoutServer();
		else
			-- new grid node server accepted this client
			-- GSL.Log(string.format("您成功登陆了 %s 的Grid Node服务器", msg.from));
			LOG.std(nil, "debug", "GSL_client", "server gateway login succeed");
			-- check client and server version. 
			if(not msg.ClientVersion or not msg.ServerVersion or msg.ClientVersion >self.ClientVersion or msg.ServerVersion <self.ServerVersion) then
				-- client and server version does not match.
				GSL.Log("对不起，您的客户端的版本同游戏服务器的版本不兼容，请更新您的客户端");
				self:log("JC version with server not compatible. \nserver:(s:%s; c:%s);client:(s:%s; c:%s)\n", 
					tostring(msg.ClientVersion), tostring(msg.ServerVersion), tostring(self.ClientVersion), tostring(self.ServerVersion));
				-- log out to prevent requesting server again like crazy.
				self:LogoutServer();
				return;
			end

			if(msg.ticket_gsid) then
				if(msg.no_ticket) then
					_guihelper.MessageBox("没有门票不能进入这个世界");
					self:log("no ticket of %s", msg.ticket_gsid);
				else
					-- tell the user that ticket is removed. 
					self:log("server uses 1 ticket of %s", msg.ticket_gsid);
				end
			end

			self:CreateGridNodeProxy(msg)
		end
	elseif(msg.type == GSL_msg.SC_Login_Recover) then		
		--------------------------------------
		-- gridnode server recovered a login
		--------------------------------------
		self.gatewayProxy:OnRespond();
		if(msg.cid ~= self.client_session_id) then
			self.add_cid = true;
		end
		LOG.std(nil, "system", "GSL_client", "client received OnLoginNodeRecover from server");
		self:FireEvent("OnLoginNodeRecover", msg);

	elseif(msg.type == GSL_msg.SC_QUERY_REPLY) then	
		-- just send result to log for debugging purposes. 
		self:log("SC_QUERY_REPLY at time %d", ParaGlobal.timeGetTime());
		commonlib.echo(msg);
	elseif(msg.type == GSL_msg.SC_Closing) then	
		-- just send result to log for debugging purposes. 
		self:log("warning: SC_Closing received from gridnode %s, meaning the server is actively closing our gridnode.", tostring(msg.id));
		local key = self:GetProxyKeyFromMsg(msg);
		if(key) then
			local proxy = self.gridnodeProxies[key];
			if(proxy) then
				self:log("logging out and remove grid node: (%s, %s)", tostring(proxy.nid), tostring(proxy:GetKey()))
				-- proxy:Logout(); --since the server is actively closing the client, so there is no need to logout here, just remove from list. 
				self:FireEvent("OnLogoutNode", proxy);
				self.gridnodeProxies[key] = nil;
			end
		end
	end	
end

local function activate()
	local msg = msg;
	if(not msg.nid) then return end
	
	if(GSL.dump_client_msg) then
		GSL.dump("GSL_client received"..commonlib.serialize_compact(msg));
	end
	
	local game_client = clients[msg.nid];
	if(game_client and game_client.bCanReceive) then
		npl_profiler.perf_begin("GSL_client:HandleMessage")
		game_client:HandleMessage(msg)
		npl_profiler.perf_end("GSL_client:HandleMessage")
	else
		LOG.std("", "warn", "GSL", "warning: we ignored a message from nid %s", msg.nid);
	end
end
NPL.this(activate);

-- the current instance of GSL default client.
GSL_client = client:new(GSL_client);