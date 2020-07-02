--[[
Author: LiXizhi
Date: 2009-7-20
Desc: REST interface of game server
-----------------------------------------------
NPL.load("(gl)script/apps/GameServer/GameServer.lua");
GameServer:Start();
-----------------------------------------------
]]
NPL.load("(gl)script/ide/event_mapping.lua");
NPL.load("(gl)script/apps/GameServer/rest.lua");
NPL.load("(gl)script/apps/IMServer/IMserver_broker.lua");

local NPLReturnCode = commonlib.gettable("NPLReturnCode");
if(not GameServer) then  GameServer = {} end

-- default config settings
GameServer.config = {
	host = "127.0.0.1",
	port = "60001",
	nid = "2001",
	public_files = "config/NPLPublicFiles.xml",
	rest = {reply_file = "script/apps/GameServer/test/test_client_rest.lua"},
	-- if it is pure server, router and rest interface will not be used. 
	IsPureServer = false,
};
-- default array of worker states and their attributes
GameServer.worker_states = {
-- this is both the runtime state name and the virtual world id
-- {name="1", },
};
GameServer.router_states = {};
GameServer.IMServer_states = {};

-- for login
GameServer.router_script = "router1:script/apps/NPLRouter/NPLRouter.lua"
-- for ordinary messages
GameServer.router_dll = "router1:NPLRouter.dll"

-- npl_http allow ip
GameServer.http_allowip={};

-- write service log
function GameServer.log(...)
	-- TODO: 
end

-- load config from a given file. 
-- @param filename: if nil, it will be "config/GameServer.config.xml"
function GameServer:load_config(filename)
	filename = filename or "config/GameServer.config.xml"
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(not xmlRoot) then
		LOG.std(nil, "error", "GameServer", "failed loading game server config file %s", filename);
		return;
	end	
	LOG.std(nil, "system", "GameServer", "config file %s", filename);

	-- read config and start server
	local config_node = commonlib.XPath.selectNodes(xmlRoot, "/GameServer/config")[1];
	if(config_node and config_node.attr) then
		commonlib.partialcopy(self.config, config_node.attr)
		-- read the REST interface settings
		local rest_node = commonlib.XPath.selectNodes(config_node, "/rest")[1];
		if (rest_node and rest_node.attr) then
			commonlib.partialcopy(self.config.rest, rest_node.attr)
		end
	end
	
	NPL.load("(gl)script/apps/GameServer/GSL_config.lua");
	Map3DSystem.GSL.config:load(self.config.gsl_config_filename);

	-- garbage collection interval. 
	if(self.config.gc_interval) then
		self.config.gc_interval = tonumber(self.config.gc_interval);
	end
	if(self.config.gc_setpause) then
		self.config.gc_setpause = tonumber(self.config.gc_setpause);
	end
	if(self.config.gc_setstepmul) then
		self.config.gc_setstepmul = tonumber(self.config.gc_setstepmul);
	end

	-- set NPL attributes before starting the server. 
	local att = NPL.GetAttributeObject();
	if(self.config.TCPKeepAlive) then
		att:SetField("TCPKeepAlive", self.config.TCPKeepAlive=="true");
	end
	if(self.config.KeepAlive) then
		att:SetField("KeepAlive", self.config.KeepAlive=="true");
	end
	if(self.config.IdleTimeout) then
		att:SetField("IdleTimeout", self.config.IdleTimeout=="true");
	end
	if(self.config.IdleTimeoutPeriod) then
		att:SetField("IdleTimeoutPeriod", tonumber(self.config.IdleTimeoutPeriod));
	end
	if(self.config.imserver_heartbeat_interval) then
		self.config.imserver_heartbeat_interval = tonumber(self.config.imserver_heartbeat_interval);
	end
	if(self.config.print_gc_info) then
		self.print_gc_info = (self.config.print_gc_info == "true");
	end
	self.config.npl_queue_size = tonumber(self.config.npl_queue_size);
	local npl_queue_size = self.config.npl_queue_size;
	if(npl_queue_size) then
		NPL.activate("script/ide/config/NPLStateConfig.lua", {type="SetAttribute", attr={MsgQueueSize=npl_queue_size,}});
	end

	-- whether use compression on incoming connections, the current compression method is super light-weighted and is mostly for data encrption purposes. 
	local compress_incoming;
	if (self.config.compress_incoming and self.config.compress_incoming=="true") then
		compress_incoming = true;
	else
		compress_incoming = false;
	end
	NPL.SetUseCompression(compress_incoming, false);
	
	if(self.config.CompressionLevel) then
		att:SetField("CompressionLevel", tonumber(self.config.CompressionLevel));
	end
	if(self.config.CompressionThreshold) then
		att:SetField("CompressionThreshold", tonumber(self.config.CompressionThreshold));
	end
	
	-- add all NPL runtime addresses
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/GameServer/npl_runtime_addresses/address") do
		if(node.attr) then
			NPL.AddNPLRuntimeAddress(node.attr);
			--commonlib.echo(node.attr);
		end	
	end

	
	-- add all public files
	NPL.LoadPublicFilesFromXML(self.config.public_files);

	-- start the net server. 
	NPL.StartNetServer(self.config.host, self.config.port);
		
	-- read attributes of npl worker states
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/GameServer/npl_states/npl_state") do
		self.worker_states[#(self.worker_states) + 1] = node.attr;
	end
	LOG.std(nil, "system", "GameServer", "worker thread count %d", #(self.worker_states));

	-- get all home world servers 
	self.homegrids = {};
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/GameServer/homegrids/homegrid") do
		self.homegrids[#(self.homegrids) + 1] = node.attr;
	end
	LOG.std(nil, "system", "GameServer", {"home grids", self.homegrids})
		
	-- get all imserver runtime states names
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/GameServer/imserver_states/imserver_state") do
		if(node.attr and node.attr.name) then
			self.IMServer_states[#(self.IMServer_states) + 1] = node.attr.name;
		end	
	end
	
	-- get all router runtime states names
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/GameServer/router_states/router_state") do
		if(node.attr and node.attr.name) then
			self.router_states[#(self.router_states) + 1] = node.attr.name;
		end	
	end

	local debug_server;
	if (self.config.debug and self.config.debug=="true") then
		debug_server = true;
	end
	
	-- if log service is available, we will need to initialize them. 
	local node = commonlib.XPath.selectNodes(xmlRoot, "/GameServer/LogService")[1];
	if(node and node.attr) then
		local attr = node.attr;
		local logserver_thread_name = attr.thread_name or "log";
		self.logger_config = {type="init", my_nid = self.config.nid, 
				logserver_nid = attr.nid, logserver_thread_name = logserver_thread_name, 
				folder = attr.folder, 
				append_mode = if_else(attr.append_mode == "false", false, nil),
				force_flush = if_else(attr.force_flush == "false", false, nil),
			}
		if(tostring(self.logger_config.my_nid) == tostring(self.logger_config.logserver_nid)) then
			NPL.CreateRuntimeState(logserver_thread_name, 0):Start();
			NPL.activate(format("(%s)script/apps/GameServer/LogService/GSL_LogServer.lua", logserver_thread_name), self.logger_config)
		end
		NPL.load("(gl)script/apps/GameServer/LogService/GSL_LogClient.lua");
		self.logger = Map3DSystem.GSL.GSL_LogClient.GetSingleton();
		self.logger:init(self.logger_config);
	end

	-- if the server has npl_http allow_host, added by YanDongdong 2013.5.15
	local node = commonlib.XPath.selectNodes(xmlRoot, "/GameServer/NPL_http/allow_host")[1];
	if (node and node.attr) then
		local attr = node.attr;
		local _allow_ip = attr.ip or "ip";

		-- de-serialize string or table
		local function deserialize_data(data)
			if(type(data) == "string") then
				if(data:match("^{.*}$")) then
					data = NPL.LoadTableFromString(data);
				end
			end
			return data;
		end

		GameServer.http_allowip = deserialize_data(_allow_ip);
	end
				
	-- create the run time state for REST interface
	NPL.CreateRuntimeState("rest", 0):Start();
	if(npl_queue_size) then
		NPL.activate(format("(%s)script/ide/config/NPLStateConfig.lua", "rest"), {type="SetAttribute", attr={MsgQueueSize=npl_queue_size,}});
	end
	-- init the REST interface
	NPL.activate("(rest)script/apps/GameServer/rest.lua", {type="init", logger_config = self.logger_config, reply_file = self.config.rest.reply_file, gameserver_nid = self.config.nid, router_dll = self.router_dll, router_script = self.router_script, router_states = self.router_states, api_file = self.config.rest.api_file})

	

	-- if lobby service (server or proxy is hosted), we will need to initialize them. 
	local node = commonlib.XPath.selectNodes(xmlRoot, "/GameServer/LobbyService")[1];
	if(node) then
		local lobbyserver_node = commonlib.XPath.selectNodes(node, "//LobbyServer")[1];
		if(lobbyserver_node and lobbyserver_node.attr) then
			local lobbyserver_nid = lobbyserver_node.attr.nid;
			local LobbyServer_threadname = lobbyserver_node.attr.thread_name;
			if(lobbyserver_nid and node.attr.proxy_thread_name) then	
				-- init lobby proxy if any
				self.lobbyproxy_file = format("(%s)script/apps/GameServer/LobbyService/GSL_LobbyServerProxy.lua", node.attr.proxy_thread_name);
				NPL.activate(self.lobbyproxy_file, {type="init", my_nid = self.config.nid, lobbyserver_nid = lobbyserver_nid, 
						LobbyServer_threadname = LobbyServer_threadname, debug_stream = lobbyserver_node.attr.debug_stream,
					});
			end
			if(lobbyserver_nid == self.config.nid) then
				LobbyServer_threadname = LobbyServer_threadname or "1";
				NPL.CreateRuntimeState(LobbyServer_threadname, 0):Start();

				-- init the lobby server if the sever nid is the local nid. 
				NPL.activate(format("(%s)script/apps/GameServer/LobbyService/GSL_LobbyServer.lua", LobbyServer_threadname), {type="init", 
					my_nid = self.config.nid, lobbyserver_nid = lobbyserver_nid, 
					proxy_thread_name = node.attr.proxy_thread_name, 
					debug_stream = node.attr.debug_stream,
					LobbyServer_threadname=LobbyServer_threadname, 
					persistent_games = lobbyserver_node.attr.persistent_games,
					game_start_timeout_interval = tonumber(lobbyserver_node.attr.game_start_timeout_interval),
					timer_interval = tonumber(lobbyserver_node.attr.timer_interval),
					version = self.config.version or System.options.version,
					locale = self.config.locale or System.options.locale,
				})
			end
		end
	end

	-- start all world server worker states
	
	self:StartNextWorkerThread();

	-- get all world server name for stat and show
	-- no need now by gosling. set it right to db by web. 11.12
	--NPL.load("(gl)script/apps/GameServer/GSL_stat.lua");
	--Map3DSystem.GSL.GSL_stat:SetServerProperty();
	
	--commonlib.echo(self.config);
	--commonlib.echo(self.worker_states);
	--commonlib.echo(self.router_states);
end

-- start the next unstarted thread. 
-- return true if a new thread is started. if nil, it means no remaining thread to start
function GameServer:StartNextWorkerThread()
	local i;
	for i, node in ipairs(self.worker_states) do
		if(not node.is_started) then
			node.is_started = true;
			self:StartWorkerThread(i);
			return true;
		end
	end	
end

-- start the worker thread by index
function GameServer:StartWorkerThread(nIndex)
	local node  = self.worker_states[nIndex];
	if(node) then
		local worker = NPL.CreateRuntimeState(node.name, 0);
		worker:Start();
		local npl_queue_size = tonumber(self.config.npl_queue_size);
		if(npl_queue_size) then
			NPL.activate(format("(%s)script/ide/config/NPLStateConfig.lua", node.name), {type="SetAttribute", attr={MsgQueueSize=npl_queue_size,}});
		end

		-- make a string cache here. 
		node.gsl_system_file = "("..node.name..")script/apps/GameServer/GSL_system.lua";
		node.gsl_gateway_file = "("..node.name..")script/apps/GameServer/GSL_gateway.lua";
		-- start the worker as GSL server mode
		NPL.activate(node.gsl_system_file, {type="restart", 
			config = {
				nid = self.config.nid, 
				gsl_config_filename = self.config.gsl_config_filename,
				ws_id = node.name, 
				addr = string.format("(%s)%s", node.name, self.config.nid),
				homegrids = self.homegrids,
				debug = debug_server,
				log_level = self.config.log_level,
				logger_config = self.logger_config,
				gm_uac = self.config.gm_uac,
				lobbyproxy_file = self.lobbyproxy_file,
				version = self.config.version,
				locale = self.config.locale,
			}
		});
		NPL.activate("("..node.name..")script/apps/IMServer/IMserver_broker.lua", {type="init", gameserver_nid = self.config.nid, IMServer_states = self.IMServer_states})
		-- give some time to new thread to init. 
		-- TODO: fix me, remove this. 
		-- ParaEngine.Sleep(0.5);

		-- init rest_local
		NPL.activate("("..node.name..")script/apps/GameServer/rest.lua", {type="init", reply_file = self.config.rest.reply_file, gameserver_nid = self.config.nid, router_dll = self.router_dll, router_script = self.router_script, router_states = self.router_states, api_file = self.config.rest.api_file})
	end
end

-- start the database server
-- @param filename: if nil, it will be "config/GameServer.config.xml"
function GameServer:Start(filename)
	-- load config
	self:load_config(filename);
	LOG.std(nil, "system", "GameServer", "Game  Server is started");
	LOG.std(nil, "system", "GameServer", "current tick count: %s", tostring(ParaGlobal.timeGetTime()));

	-- note, connection to home grids are usually on demand. 
	local preconnect_homegrids = false;
	if(preconnect_homegrids) then
		local _, homegrid_info
		for _, homegrid_info in ipairs(self.homegrids) do
			if(NPL.activate_async_with_timeout(20, homegrid_info.address..":script/apps/GameServer/test/accept_any.lua", {user_nid = self.config.nid}) ~= 0) then
				LOG.std(nil, "error", "GameServer", "game server (%s) can not connect to homegrid server %s", self.config.nid, homegrid_info.address)
			else
				LOG.std(nil, "system", "GameServer", "game server (%s) is connected to homegrid server %s", self.config.nid, homegrid_info.address);
			end
		end
	end	
	
	if(not self.config.IsPureServer or self.config.IsPureServer=="false") then
		-- establish connection with the NPLRouter and send the first authentication message
		while( NPL.activate(self.router_script, {my_nid = self.config.nid,}) ~=0 ) do 
			ParaEngine.Sleep(0.1) 
		end
		LOG.std(nil, "system", "GameServer", "game server (%s) is connected to NPLRouter", self.config.nid)
	else
		LOG.std(nil, "warning", "GameServer", "warning: game server (%s) is started in pure server mode. REST and NPL router are not used. Remove IsPureServer option in gameserver.config.xml", self.config.nid)
	end	

	local imserver_interval = self.config.imserver_heartbeat_interval;
	if(imserver_interval and imserver_interval>0) then
		NPL.load("(gl)script/apps/IMServer/IMserver_broker.lua");	
		IMServer_broker:init({type="init", gameserver_nid = self.config.nid, IMServer_states = self.IMServer_states});
		IMServer_broker:StartSendingHeartBeat(imserver_interval)
	end	

	NPL.RegisterEvent(0, "_n_gameserver_network", ";GameServer.OnNetworkEvent();");
end

-- message templates
local msg_OnDisconnect = {type="OnUserDisconnect", nid = nil};

-- NPL event handler for game server. 
function GameServer.OnNetworkEvent()
	local msg = msg;
	local code = msg.code;
	if(code == NPLReturnCode.NPL_ConnectionDisconnected) then
		LOG.std(nil, "system", "user", "user %s disconnected", msg.nid);
		msg_OnDisconnect.nid = msg.nid;
		local i, node
		for i, node in ipairs(GameServer.worker_states) do
			NPL.activate(node.gsl_system_file, msg_OnDisconnect);
		end
		-- inform the rest thread as well.
		NPL.activate("(rest)script/apps/GameServer/GSL_system.lua", msg_OnDisconnect);
	end	
end

-- Start a garbage collection timer, that does a full garbage collection of all worker threads every few seconds. 
function GameServer:StartGarbageCollectTimer()
	if(self.config.gc_setpause) then
		self:BoardcastSysMessage({type="gc", opt="setpause", args={self.config.gc_setpause}, reply_file="(main)script/apps/GameServer/GSL_system.lua"});
		LOG.std(nil, "system", "GC", "garbage collection setpause: %d", self.config.gc_setpause);
	end
	if(self.config.gc_setstepmul) then
		self:BoardcastSysMessage({type="gc", opt="setstepmul", args={self.config.gc_setstepmul}, reply_file="(main)script/apps/GameServer/GSL_system.lua"});
		LOG.std(nil, "system", "GC", "garbage collection setstepmul: %d", self.config.gc_setstepmul);
	end
	
	if(self.config.gc_interval) then
		local interval = self.config.gc_interval;
		
		NPL.load("(gl)script/apps/GameServer/GSL_system.lua");
		local system = commonlib.gettable("Map3DSystem.GSL.system");
		local gc_msg = {type="gc", opt=self.config.gc_opt or "collect", args={}, reply_file="(main)script/apps/GameServer/GSL_system.lua"}
		
		--[[
Note: lxz 2010.10.8: still have not figured out why. 
No User: 9699
+ ximi_new: 10467
+ gosling: 10938
+ ximi_old: 11338
- ximi_old: 10953
- gosling: 10558
- ximi_new: 10139
		]]
		if(gc_msg.opt == "collect" or gc_msg.opt == "step" or gc_msg.opt == "count") then
			LOG.std(nil, "system", "GC", "garbage collection timer is started. GC interval is %d", interval);
			-- we will only start timer if operation is collect or step. 
			self.gc_timer = self.gc_timer or commonlib.Timer:new({callbackFunc = function(timer)
					-- whether to dump gc info to log periodically(at gc_interval) 
					if(self.print_gc_info) then
						system:OnPrintGCResult();
					end
					self:BoardcastSysMessage(gc_msg);
				end});
			self.gc_timer:Change(interval, interval);
		else
			LOG.std(nil, "system", "GC", "garbage collection timer is NOT started, because no gc_opt specified");
		end
	end
end

-- send a GSL_system file message to the main, rest, and all worker threads. 
function GameServer:BoardcastSysMessage(msg)
	NPL.activate("(main)script/apps/GameServer/GSL_system.lua", msg);
	NPL.activate("(rest)script/apps/GameServer/GSL_system.lua", msg);
	local i, node
	for i, node in ipairs(self.worker_states) do
		NPL.activate(node.gsl_system_file, msg);
	end
end

-- send server chat message
function GameServer:BoardcastServerChatMessage(msg)
	if(type(msg.msg) == "string") then
		LOG.std(nil, "system", "ServerChat", "server chat message: %s", msg.msg);
		local i, node
		for i, node in ipairs(self.worker_states) do
			NPL.activate(node.gsl_system_file, msg);
		end
	end
end

local function activate()
	if(msg.type == "worker_thread_inited") then
		LOG.std(nil, "system", "GameServer", "All services on NPL thread: %s are initialized and ready to go!", tostring(msg.npc_state_id));
		if(not GameServer:StartNextWorkerThread()) then
			LOG.std(nil, "system", "GameServer", "All threads on Game Server are initialized and ready to go!");
			GameServer:StartGarbageCollectTimer();
			GameServer.isReady = true;
		end
	elseif(msg.type == "s_chat") then
		GameServer:BoardcastServerChatMessage(msg);
	end
end
NPL.this(activate)