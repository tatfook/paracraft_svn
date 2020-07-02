--[[
Author: LiXizhi
Date: 2009-7-22
Desc: a wrapper class to emulate HTTP REST interface on the client side but using the game server interface
This class can be used as a singleton or with many instances.
-----------------------------------------------
NPL.load("(gl)script/apps/GameServer/rest_client.lua");
GameServer.rest.client:start("script/apps/GameServer/test/local.GameClient.config.xml")
-- @note1: please conside using the rest_webservice_wrapper interface where possible.
-- @note2: When connection is authenticated, it is good habbit to set GameServer.rest.client.user_nid to nid.

-- use as many references. 
local client = GameServer.rest.client:new({})

-- we can change the game server we are connected to at runtime, by calling
GameServer.rest.client:connect({host="127.0.0.1", port="60001", nid="world1", world_id="1",}, timeout, function(msg) 
	if(msg.connected) then
		commonlib.echo(msg.world_server)
		if(msg.is_switch_connection) then
			-- TODO: authenticate again
		end
	end
end)
-----------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua"); 
NPL.load("(gl)script/apps/GameServer/rest_webservice_wrapper.lua");
NPL.load("(gl)script/ide/Network/StreamRateController.lua");
local StreamRateController = commonlib.gettable("commonlib.Network.StreamRateController");

-- define a base class with constructor
local client = commonlib.inherit(nil, commonlib.gettable("GameServer.rest.client"))

-- set to true to output all IO to log
client.debug_stream = client.debug_stream or false;

client.config = {
	host = "127.0.0.1",
	port = "0", -- if port is "0", we will not listen for incoming connection
	public_files = "config/NPLPublicFiles.xml",
	api_file = "config/WebAPI.config.xml",
	-- if true we will use game server instead of HTTP get whenever possible. 
	use_game_server = true,
};

-- all world server addresses. 
client.world_servers = {
--{host, port, nid, world_id}
}

-- current user nid, needs to fetch via AuthUser. This is not needed. But it is good habbit to assign it when connection is authenticated
client.user_nid = nil;

-- connection time out in seconds 
client.conn_timeout = 10;

-- keep alive interval. 
client.keepalive_interval = 20000;

-- a mapping from url to {shortname, provider, }
client.API = client.API or {};

-- pending request. 
client.pending_requests = {};

-- dump file
client.dumpfile = "log/rest"

-- if provided, we will use this port instead of the one provided in the config file.
client.preferred_port = nil;
-- if provided, we will use this nid to login if the nid is in the available server list. 
client.preferred_nid = nil;
-- max send queue size
client.max_queue_size = 15;

-- all known clients, mapping from server_nid to client object. 
-- There can only be one client connecting to one server nid. For multiple user emulations. One can use multiple game_server_nid mapping to the same physical game server. 
local clients = {};

-- whether to enable rate controller. 
client.bEnabledRateController = true;
client.send_queue = commonlib.Queue:new(); 

-- constructor
function client:ctor()
	self.pending_requests = {};
	self.cur_game_server_nid = "";
	self.send_queue = commonlib.Queue:new(); 
end

-- load config from a given file. 
-- @note: No many however many instances of this class, this function is only called once internally. i.e. All instances share the same configurations. 
-- @param filename: if nil, it will be "config/GameClient.config.xml"
function client:load_config(filename)
	if(client.config_loaded) then
		return
	else
		client.config_loaded = true;
	end
	filename = filename or "config/GameClient.config.xml"
	-- filename = "script/apps/GameServer/test/local.GameClient.config.xml"
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(not xmlRoot) then
		LOG.std("", "error", "REST", "failed loading game server config file %s", filename);
		return;
	end	
	
	local config_node = commonlib.XPath.selectNodes(xmlRoot, "/GameClient/config")[1];
	if(config_node and config_node.attr) then
		if(config_node.attr.use_game_server) then
			if(config_node.attr.use_game_server == "false") then
				config_node.attr.use_game_server = false;
			else
				config_node.attr.use_game_server = true;
			end
		end 
		commonlib.partialcopy(self.config, config_node.attr)
		
		if(System.options.is_client) then
			-- compress all messages to server. 
			LOG.std(nil, "debug", "REST", "NPL compression is on");
			NPL.SetUseCompression(true, true);
			local att = NPL.GetAttributeObject();
			att:SetField("CompressionLevel", -1);
			att:SetField("CompressionThreshold", 1);
		else
			if(self.config.use_compression and self.config.use_compression == "true") then
				NPL.SetUseCompression(true, true);
			end

			local att = NPL.GetAttributeObject();
			if(self.config.CompressionLevel) then
				att:SetField("CompressionLevel", tonumber(self.config.CompressionLevel));
			end
			if(self.config.CompressionThreshold) then
				att:SetField("CompressionThreshold", tonumber(self.config.CompressionThreshold));
			end
		end
		
		--if(self.config.force_binary and self.config.force_binary == "true") then
			---- compress all messages to server. 
			---- NPL.SetCompressionKey({key = "this can be nil", size = 64, UsePlainTextEncoding = 1});
			--NPL.SetCompressionKey({UsePlainTextEncoding = -1});
		--end
		
		-- read the debug settings
		local node = commonlib.XPath.selectNodes(config_node, "/npl_router_config")[1];
		if (node and node.attr and tostring(node.attr.is_enabled) == "true") then
			if(type(node[1]) == "string") then
				-- start the NPL router locally. 
				NPL.load("(gl)script/apps/NPLRouter/NPLRouter.lua");
				NPLRouter:Start(node[1]);
			end
		end
		
		local node = commonlib.XPath.selectNodes(config_node, "/db_server_config")[1];
		if (node and node.attr and tostring(node.attr.is_enabled) == "true") then
			if(type(node[1]) == "string") then
				-- start the NPL router locally. 
				NPL.load("(gl)script/apps/DBServer/DBServer.lua");
				DBServer:Start(node[1]);
			end
		end
		
		local node = commonlib.XPath.selectNodes(config_node, "/game_server_config")[1];
		if (node and node.attr and tostring(node.attr.is_enabled) == "true") then
			if(type(node[1]) == "string") then
				-- start the NPL router locally. 
				NPL.load("(gl)script/apps/GameServer/GameServer.lua");
				GameServer:Start(node[1]);
			end
		end
	end
	
	-- set using game server
	if (not self.config.use_game_server) then
		LOG.std("", "warning", "REST", "I see that you are turning use_game_server to false, you must edit file ParaworldAPI.lua and set paraworld.use_game_server = false manually.");
	end
	
	-- Usually port should be "0", so there is no need for client to listen to any port. 
	NPL.StartNetServer(self.config.host, self.config.port);
	LOG.std("", "system", "REST", "NPL Network Layer is started  %s:%s", tostring(self.config.host), tostring(self.config.port));
	
	-- add all public files
	NPL.LoadPublicFilesFromXML(self.config.public_files);
	
	-- read all web API from api config file
	local api_root = ParaXML.LuaXML_ParseFile(self.config.api_file);
	if(not api_root) then
		LOG.std("", "warning", "REST", "warning: failed loading config file %s", self.config.api_file);
	else
		local node;
		for node in commonlib.XPath.eachNode(api_root, "/WebAPI/web_services/service") do
			if(node.attr and node.attr.url) then
				local service_desc = self.API[node.attr.url] or {};
				if(node.attr.allow_anonymous and node.attr.allow_anonymous=="true") then
					service_desc.allow_anonymous = true;
				else
					service_desc.allow_anonymous = nil;
				end
				service_desc.url = node.attr.url;
				service_desc.shortname = node.attr.shortname;
				service_desc.provider = node.attr.provider;
				
				self.API[node.attr.url] = service_desc;
			end	
		end	
	end	
	
	-- 针对版署检查用，强制设定gamesvr 1003
	System.options.isPubchk = ParaIO.DoesFileExist("character/Animation/script/pubchk.lua", false)
	if (System.options.isPubchk) then
		self.world_servers={{host="125.39.236.100",port="8858",nid="1003",allow_login="true",},}
		self.login_servers={{host="125.39.236.100",port="8858",nid="1003",allow_login="true",},}
		--self.world_servers={{host="192.168.0.61",port="800",nid="1007",allow_login="true",},}
		--self.login_servers={{host="192.168.0.61",port="800",nid="1007",allow_login="true",},}
	else
		-- get array of world servers that allows login. 
		self.login_servers = {};
		-- get all game (world) server lists
		local node;
		for node in commonlib.XPath.eachNode(xmlRoot, "/GameClient/world_server_addresses/address") do
			if(not node.attr.version or node.attr.version == System.options.version) then
				self.world_servers[#(self.world_servers) + 1] = node.attr;
				-- add the known addresses. 
				-- NPL.AddNPLRuntimeAddress({host=node.attr.host, port=node.attr.port, nid=node.attr.nid});
				if(node.attr.allow_login and node.attr.allow_login=="true") then
					self.login_servers[#(self.login_servers) + 1] = node.attr;
				end
			end
		end
		-- if no login_servers are specified, we will use the first world server in the list as the login server. 
		if(#(self.login_servers) == 0) then
			self.login_servers[1] = self.world_servers[1];
		end
	end
end

-- get the current game server nid. 
function client:get_current_server_nid()
	return self.cur_game_server_nid;
end

-- get the secondary port number of the provided nid. 
-- @param nid: if nil, the first one with port2 is returned . 
function client:get_login_server_port2(nid)
	local w_index, w 
	for w_index, w in ipairs(self.login_servers) do
		if(not nid or w.nid == nid) then
			if(w.port2) then
				return tonumber(w.port2);
			end
		end
	end
end

function client:GetLoginServers()
	return self.login_servers;
end

-- calll this function when user network status is not fine. 
function client:ResetLastLoginServer()
	self.login_server_index = nil;
end

-- connect to a given world server, if we have already connected to a different world server. Disconnect from old server and connect to the new one. 
-- this function will return either the connection is established or default timeout is passed.
-- @param world_server: a table like {host="127.0.0.1", port="60001", nid="world1", world_id="1"}. If nil, it will automatically pick a world server to connect to.
--  world_id can be nil, if host and port is nil, we will search for nid in the GameClient.config.xml for a matching nid. 
-- @param timeout: the number of seconds to timeout. if 0, it will just ping once. 
-- @param callback_func: a function(msg) end.  If this function is provided, this function is asynchronous. If connection is established, 
--		msg.world_server will be assigned to input world_server. 
--		msg.connected is true. 
--		msg.is_switch_connection is true. if connection is switched. 
-- @return 0 if successfully connected to the game server. please note, the connection may not be authenticated, one need to call AuthUser to authenticate the connection immediately afterwards. 
-- if callback_func is a function, this function always returns 0. 
function client:connect(world_server, timeout, callback_func)
	if(not world_server) then
		-- automatically pick a world server to connect to. Currently method2 is used. 
		-- Method1: TODO: connect to the closest game server by IP
		-- Method2: self.preferred_nid is used if specified, otherwise randomly pick a game server with allow_login="true" for the first time and pick the next one for next call.  If no allow_login is specified, the first one is used. 
		if(not self.login_server_index) then
			-- pick first one for the first connection try
			-- self.login_server_index = 1;
			
			local whereipfrom = System.options.force_ipfrom or System.options.whereipfrom or "电信";

			-- find according to whereipfrom
			if(whereipfrom) then
				local function SelectLoginServerByIpFrom(whereipfrom)
					local w_index, w 
					for w_index, w in ipairs(self.login_servers) do
						if(w.whereipfrom == whereipfrom) then
							self.login_server_index = w_index;
							LOG.std("", "info", "REST", "using nid %s to login, according to whereipfrom %s", tostring(w.nid), whereipfrom);
							return true;
						end
					end
				end
				if(not SelectLoginServerByIpFrom(whereipfrom)) then
					-- if no server is selected, we will select "电信"
					SelectLoginServerByIpFrom("电信");
				end
			end
			-- find preferred_nid if whereipfrom also matches
			if(self.preferred_nid) then
				local w_index, w 
				for w_index, w in ipairs(self.login_servers) do
					if(w.nid == self.preferred_nid) then
						if( not (whereipfrom and self.login_server_index and (w.whereipfrom ~= whereipfrom )) ) then
							self.login_server_index = w_index;
							LOG.std("", "info", "REST", "using preferred nid %s to login", tostring(w.nid));
						end
						break;
					end
				end
			end
			if(not self.login_server_index) then
				-- pick randomly for the first connection try. 
				math.randomseed(ParaGlobal.timeGetTime())
				self.login_server_index = math.random(1, #(self.login_servers));
				LOG.std("", "warn", "REST", "no preferred nid is specified during login. We will randomly pick one.");
			end
		end
		self.login_server_index = ((self.login_server_index - 1) % (#(self.login_servers))) + 1;
		local best_world_server = self.login_servers[self.login_server_index];
		self.login_server_index = self.login_server_index + 1;
		
		if(best_world_server) then
			return self:connect(best_world_server, timeout, callback_func);
		else
			LOG.std("", "warning", "REST", "no server to connect to");
		end	
		return
	else
		-- if host and port are not provided, we will search in config file for it by nid. 
		if(not world_server.host or not world_server.port) then
			local _, w 
			for _, w in ipairs(self.world_servers) do
				if(w.nid == world_server.nid) then
					world_server.host = w.host;
					world_server.port = w.port;
					break;
				end
			end
		end	
		if(not world_server.host or not world_server.port) then
			LOG.std("", "warning", "REST", "world server host or port is not provided");
			if(callback_func) then
				callback_func({world_server = world_server, connected=false});
			end
			return;
		end
	end
	local is_switch_connection;
	if(self.cur_game_server_nid ~= world_server.nid and self.cur_game_server_nid and self.cur_game_server_nid~="") then
		-- we are already connected to another server. we shall disconnect the old server
		self:disconnect();
		is_switch_connection = true;
	end

	self.cur_game_server_nid = world_server.nid;
	self.cur_world_id = world_server.world_id;
	self.cur_world_server = world_server;
	-- we need to verify if the preferred port is available. 
	if(self.preferred_port) then
		local port = tostring(self.preferred_port);
		if(port ~= world_server.port) then
			if(port == world_server.port or port == world_server.port2 or port == world_server.port3) then
				LOG.std("", "info", "REST", "switching port from %s to %s", world_server.port, port);
				world_server.port = port;
			end
		end
	end
	-- world_server.port = self.preferred_port or world_server.port;
	NPL.AddNPLRuntimeAddress({host = world_server.host, port = world_server.port, nid = world_server.nid});
	LOG.std("", "system", "REST", "connecting to %s:%s nid:%s", world_server.host, tostring(world_server.port), tostring(world_server.nid));
	self.rest_address = string.format("(rest)%s:script/apps/GameServer/rest.lua", self.cur_game_server_nid);
	self.world_rest_address = self.rest_address;
	clients[self.cur_game_server_nid] = self;
	
	if(not callback_func) then
		-- if no call back function is provided, this function will be synchronous. 
		if( NPL.activate_with_timeout(timeout or self.conn_timeout, self.rest_address, {url = "ping",}) ~=0 ) then
			LOG.std("", "warning", "REST", "failed to connect to world server %s", world_server.nid);
			self.cur_game_server_nid = nil;
			System.User.IsRedirecting = nil;
		else
			LOG.std("", "warning", "REST", "connection with world server %s is established", world_server.nid);	
			Map3DSystem.User.gs_nid = world_server.nid;
			System.User.IsRedirecting = nil;
			self:ResetLastLoginServer();
			-- commonlib.echo(commonlib.debugstack(2, 10, 10))
			return 0;
		end
	else
		-- if call back function is provided, we will do asynchronous connect. 
		local intervals = {100, 300,500, 1000, 1000, 1000, 1000}; -- intervals to try
		local try_count = 0;
		local callback_func = callback_func;
				
		NPL.load("(gl)script/ide/timer.lua");
		self.mytimer = commonlib.Timer:new({callbackFunc = function(timer)
			try_count = try_count + 1;
			if(NPL.activate(self.rest_address, {url = "ping",}) ~=0) then
				if(intervals[try_count]) then
					timer:Change(intervals[try_count], nil);
				else
					self.is_started = false;
					self.cur_game_server_nid = nil;
					System.User.IsRedirecting = nil;
					-- timed out. 
					callback_func({world_server = world_server, connected=false, is_switch_connection = is_switch_connection});
				end	
			else
				-- connected 
				System.User.IsRedirecting = nil;
				self.is_connected = true;
				self:ResetLastLoginServer();
				callback_func({world_server = world_server, connected=true, is_switch_connection = is_switch_connection})
			end
		end})
		self.mytimer:Change(10, nil);
		return 0;
	end
end

-- disconnect 
function client:disconnect()
	if(self.cur_game_server_nid and self.cur_game_server_nid~="") then
		LOG.std(nil, "system", "rest_client", "connection disconnected. the old one %s is closed.", self.cur_game_server_nid);
		System.User.IsRedirecting = true;
		NPL.reject(tostring(self.cur_game_server_nid));
		self.cur_game_server_nid = nil;
	end
end

-- recover previous connection with rest game server. 
-- it just connect without authentication. 
-- @param callback_func: function (msg) end, where msg = {connected=boolean}
-- @return nil if failed. or 0 which means succeed or result will go to callback_func. 
function client:recover_connection(callback_func)
	if(not self.cur_game_server_nid or not self.rest_address) then
		return
	end
	LOG.std("", "system", "REST", "(Recover) rest connection with %s", self.cur_game_server_nid);
	
	if(not callback_func) then
		-- if no call back function is provided, this function will be synchronous. 
		if( NPL.activate_with_timeout(timeout or self.conn_timeout, self.rest_address, {url = "ping",}) ~=0 ) then
			LOG.std("", "warning", "REST", "warning: failed to (Recover)connect to world server %s", world_server.nid);
			System.User.IsRedirecting = nil;
		else	
			LOG.std("", "system", "REST", "(Recover)connection with world server %s is established", Map3DSystem.User.gs_nid);
			System.User.IsRedirecting = nil;
			self.is_started = true;
			self.is_connected = true;
			-- commonlib.echo(commonlib.debugstack(2, 10, 10))
			return 0;
		end
	else
		-- if call back function is provided, we will do asynchronous connect. 
		local intervals = {100, 300,500, 1000, 1000, 1000, 1000}; -- intervals to try
		local try_count = 0;
		local callback_func = callback_func;
		
		NPL.load("(gl)script/ide/timer.lua");
		self.mytimer = commonlib.Timer:new({callbackFunc = function(timer)
			try_count = try_count + 1;
			if(NPL.activate(self.rest_address, {url = "ping",}) ~=0) then
				if(intervals[try_count]) then
					timer:Change(intervals[try_count], nil);
				else
					self.is_started = false;
					LOG.std("", "warning", "REST", "(Recover) rest connection with %s failed", self.cur_game_server_nid);
					-- timed out. 
					callback_func({connected=false});
				end	
			else
				-- connected 
				self.is_started = true;
				LOG.std("", "system", "REST", "(Recover) rest connection with %s succeeded\n", self.cur_game_server_nid);
				System.User.IsRedirecting = nil;
				self.is_connected = true;
				callback_func({connected=true})
			end
		end})
		self.mytimer:Change(10, nil);
		return 0;
	end
end

-- call this function just once when the game starts. It will connect to default the game world after loading configuration files. 
-- Once server is started, we can call client:connect() to switch servers at later time. 
-- it is safe to call multiple times, only the first time does the work. 
-- @param filename: if nil, it will be "config/GameClient.config.xml"
-- @param timeout: the number of seconds to timeout. if 0, it will just ping once. 
-- @param callback_func: a function(msg) end.  If this function is provided, this function is asynchronous. If connection is established, msg.connected will be true. 
-- @param worldserver: nil or a table like {host="127.0.0.1", port="60001", nid="world1", world_id="1"}. If nil, it will automatically pick a world server to connect to.
-- @return 0 if successfully connected to the game server. please note, the connection may not be authenticated, one need to call AuthUser to authenticate the connection immediately afterwards. 
function client:start(filename, timeout, callback_func, worldserver)
	LOG.std(nil, "system", "REST", "rest client is started with gateway server nid %s", tostring( (worldserver and worldserver.nid) or "not specified") );
	if(not self.is_started) then
		self.is_started = true;
		
		-- load configuration files. 
		self:load_config(filename);
	end	
	-- connect to default game server. 
	return self:connect(worldserver, timeout, callback_func);
end


-- @return the next request sequence id. 
function client:GetNextSeqID()
	local pending_requests = self.pending_requests;
	
	local seq = 1;
	while(pending_requests[seq]) do
		seq = seq + 1;
	end
	return seq;
end

-- add a pending request to the request pool
-- @return the sequence id
function client:AddPendingRequest(request)
	local seq = self:GetNextSeqID();
	self.pending_requests[seq] = request;
	return seq;
end

-- get a request by its sequence id. This function is called when the client receives a reply and needs to handle its callback. 
-- Once this function is called, the request will be removed from the seq. i.e. it will be considered already handled.
-- @param seq: the sequence id. 
function client:GetRequestByID(seq)
	if(seq) then
		local request = self.pending_requests[seq];
		self.pending_requests[seq] = nil;
		return request;
	end	
end

-- remove request by its id. 
function client:RemoveRequestByID(seq)
	if(seq) then
		self.pending_requests[seq] = nil;
	end	
end

function client:EnableRateController(bEnabled)
	self.bEnabledRateController = bEnabled;
end

function client:GetRateController()
	if(not self.rateController) then
		self.rateController = StreamRateController:new({name="rest_client", 
			-- only history for 3 seconds
			history_length = 3, 
			-- 2 message/second
			max_msg_rate=2,
		})
	end
	return self.rateController;
end

-- check if we can send a message now by rate controller. 
function client:CheckCanSend()
	if(self.bEnabledRateController) then
		return self:GetRateController():AddMessage(1);
	else
		return true;
	end
end

-- send a request via the rest interface. Call this function if one wants to directly call remote rest interface without using a REST wrapper. 
-- @param url: string
-- @param request: a table of name value pairs
-- @param callback_func: function(msg)  end, which contains the message output after converting json string to npl msg table. This can be nil.
-- @param raw_callback_func: function(msg, request) end, which contains the raw message from the activation call. This can be nil. 
--  If this is not nil, it will be called before the callback_func. request is a table that contains {url, req}
-- @param timer: if nil, no time out callback, otherwise it is a virtual commonlib.Timer object. we will stop the timer when a request is received. 
--   in web service wrapper, we usually create a timer per url or per pool, and use the timer for request time out. 
function client:SendRequest(url, request, callback_func, raw_callback_func, timer)
	if(not self.is_started) then
		LOG.std(nil, "info", "REST", "rest client is not initialized.");
		return
	end
	local req = {callback_func = callback_func, url=url, req=request, raw_callback_func = raw_callback_func, timer=timer};
	if(self.send_queue:empty() and self:CheckCanSend()) then
		return self:SendRequest_Imp(req);	
	elseif(self.send_queue:size() > self.max_queue_size) then
		LOG.std(nil, "warning", "REST", "unable to send request because send queue is full.");
	else
		self.send_queue:push_back(req);
		LOG.std(nil, "debug", "rest", "request is queued by rate controller. queue size: %d", self.send_queue:size());
		self.send_timer = self.send_timer or commonlib.Timer:new({callbackFunc = function(timer)
			while(not self.send_queue:empty()) do
				if(self:CheckCanSend()) then
					LOG.std(nil, "debug", "rest", "send request in queue");
					self:SendRequest_Imp(self.send_queue:pop());	
				else
					break;
				end
			end
			if(self.send_queue:empty()) then
				timer:Change();
			end
		end})
		self.send_timer:Change(100, 200);
	end
end

-- private: send request immediately
-- @param request: a table of {callback_func = callback_func, url=url, req=request, raw_callback_func = raw_callback_func, timer=timer}
function client:SendRequest_Imp(request)
	local seq = self:AddPendingRequest(request);
	
	if(client.debug_stream) then
		commonlib.servicelog(client.dumpfile, "rest_client SendRequest:"..commonlib.serialize_compact({url = request.url, req = request.req, seq=seq}));
	end	
	
	-- remember the last send time. 
	self.last_send_time = commonlib.TimerManager.GetCurrentTime();
	
	if( NPL.activate(self.rest_address, {url = request.url, req = request.req, seq=seq}) ~=0 ) then
		self:RemoveRequestByID(seq);
		-- connection to self.rest_address may be lost
		LOG.std(nil, "warning", "REST", "unable to send request.")
	end
end

-- NOT USED: set the world address
function client:SetWorldAddress(world_id)
	if(not world_id) then 
		self.world_rest_address = self.rest_address;
	else
		self.world_rest_address = string.format("(%s)%s:script/apps/GameServer/rest.lua", tostring(world_id), self.cur_game_server_nid);
	end
end

-- NOT USED: send a rest request to the world thread instead of the global rest thread. 
function client:SendWorldRequest(url, request, callback_func, raw_callback_func, timer)
	if(not self.is_started) then
		LOG.std(nil, "info", "REST", "rest client is not initialized.");
		return
	end
	
	local seq = self:AddPendingRequest({callback_func = callback_func, url=url, req=request, raw_callback_func = raw_callback_func, timer=timer});
	
	if(client.debug_stream) then
		
		commonlib.servicelog(client.dumpfile, "client:SendRequest");
		commonlib.servicelog(client.dumpfile, {url = url, req = request, seq=seq});
	end	
	
	-- remember the last send time. 
	self.last_send_time = commonlib.TimerManager.GetCurrentTime();
	
	if( NPL.activate(self.world_rest_address, {url = url, req = request, seq=seq}) ~=0 ) then
		self:RemoveRequestByID(seq);
		-- connection to self.rest_address may be lost
		LOG.std(nil, "warning", "REST", "unable to send request.")
	end
end

-- whether to enable rest keep alive. we will send a ping message to rest thread every 60 second
-- this function must be called on each game world load, since timer may be destroyed between scene or ui reset . 
-- @param interval: in milliseconds. if nil, defaults to self.keepalive_interval
function client:EnableKeepAlive(bEnable, interval)
	if(not bEnable and not self.keepalive_timer) then
		return;
	end
	self.keepalive_timer = self.keepalive_timer or commonlib.Timer:new({callbackFunc = function(timer)
		self:OnKeepAliveTimer(timer);
	end})
	if(bEnable) then
		interval = interval or self.keepalive_interval;
		self.keepalive_interval = interval;
		LOG.std("", "system", "REST", "rest keep alive is started. interval is %d seconds", interval/1000);
		self.keepalive_timer:Change(interval, interval)
	else
		self.keepalive_timer:Change();
	end
end

-- keep alive timer callback
function client:OnKeepAliveTimer(timer)
	if( self.is_started) then
		local cur_time = commonlib.TimerManager.GetCurrentTime();
		if( (cur_time - (self.last_send_time or 0)) > self.keepalive_interval) then
			self.last_send_time = cur_time;
			if(NPL.activate(self.rest_address, {url = "ping"}) ~=0 ) then
				-- needs to reconnect
				LOG.std("", "info", "REST", "failed to send keep alive message");
			else
				LOG.std("", "debug", "REST", "rest keep alive message is sent");
			end
		end
	end
end

-- send a message to gateway. This allow us to send any message that can be processed by gateway. 
-- currently {type = GSL_msg.CS_IM, } is commonly used. 
-- @param msg: such as {}
-- @return true if successfully sent
function client:SendToGateway(msg)
	-- shall we cache imserver_address
	-- echo({"11111111", gsnid=Map3DSystem.User.gs_nid or "nil", wsnid = Map3DSystem.User.ws_id or "nil", msg, w = self.cur_world_id, g = self.cur_game_server_nid})
	self.imserver_address = string.format("(%s)%s:script/apps/GameServer/GSL_gateway.lua", Map3DSystem.User.ws_id or "r", Map3DSystem.User.gs_nid or self.cur_game_server_nid);
	
	if(NPL.activate(self.imserver_address, msg) ==0) then
		return true
	else
		log("warning: failed to send msg to gateway\n");
		commonlib.echo(msg);
	end
end

-- whether this client is signed in 
function client:IsSignedIn()
	return self.is_connected and Map3DSystem.User.IsAuthenticated;
end

function client:IsConnected()
	return self.is_connected;
end

-- toggle server profiler. 
-- e.g. GameServer.rest.client:ToggleServerProfiler("1")
-- @param npl_state_name: the npl runtime state name in the server to profiler. if nil, it will be the rest thread. 
-- some common value is "1"
function client:ToggleServerProfiler(npl_state_name)
	if(NPL.activate(self.rest_address, {url = "ToggleProfiler", req={npl_state_name=npl_state_name}}) ~=0) then
	end
end

local function activate()
	if(not msg.nid) then return end
	
	-- handle response from game server. 
	if (client.debug_stream) then
		commonlib.servicelog(client.dumpfile, "rest_client received:"..commonlib.serialize_compact(msg));
	end	
	
	local rest_client = clients[msg.nid];
	if(rest_client == nil) then
		LOG.std(nil, "warn", "rest_client", "invalid message received from %s", msg.nid);
		return;
	end
	
	local request = rest_client:GetRequestByID(msg.seq);
	if(type(request) == "table") then
		if(request.timer:IsEnabled()) then
			-- now kill the timer.
			request.timer:Change();
		else
			--  If timer is already activated(disabled), meaning that timeout has already been called
			--  we should avoid calling the callback any more. 
			return;
		end
		if(type(request.raw_callback_func) == "function") then
			request.raw_callback_func(msg, request);
		end
		if(type(request.callback_func) == "function") then
			if(msg.data) then
				local out={};
				if(NPL.FromJson(msg.data, out)) then
					request.callback_func(out);
				end	
			end	
		end	
	end
end
NPL.this(activate)