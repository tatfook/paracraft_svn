--[[
Title: The per thread GSL system
Author(s): LiXizhi
Date: 2009.7.29
Desc: This allows the current NPL runtime state to run as a world server instance in daemon mode. 
The system can be configured via xml (usually config/GSL.config.xml). 
It can also be extended by external modules(services), like below
	Map3DSystem.GSL.system:AddService("SampleServerModule", SampleServerModule)
All other modules can register system event, like below
	Map3DSystem.GSL.system:AddEventListener("OnDisconnect", function(self, msg) end);
the following events are supported:
	"OnUserDisconnect": {nid}, where nid is user nid(string)
	"OnUserLoginWorld":{nid, worldpath, ..}, same as GSL grid node login message.  
		Please note the same user may login several times to different worlds, and only disconnect once. 
Please note, other external system modules may fire custom events, like this.
	Map3DSystem.GSL.system:FireEvent("OnUserLoginWorld", {nid, worldpath});

Map3DSystem.GSL.system:SendChat(nid, text, is_bbs, callbackFunc);

Map3DSystem.GSL.system:TryGetSharedLoot(nid, loot_name)

use the lib:
------------------------------------------------------------
-- the main thread should activate this file to put current worker thread to run as a world server. 
NPL.load("(gl)script/apps/GameServer/GSL_system.lua");
local worker = NPL.CreateRuntimeState("world1", 0);
worker:Start();
NPL.activate("(world1)script/apps/GameServer/GSL_system.lua", {type="restart", config={nid="localhost", ws_id="world1"}});
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/apps/GameServer/GSL.lua");
NPL.load("(gl)script/ide/timer.lua");
NPL.load("(gl)script/ide/EventDispatcher.lua");
NPL.load("(gl)script/apps/GameServer/LobbyService/GSL_LobbySharedLoot.lua");
local SharedLoot = commonlib.gettable("Map3DSystem.GSL.Lobby.SharedLoot");
local BroadcastService = commonlib.gettable("Map3DSystem.GSL.Lobby.BroadcastService");
local PowerItemManager = commonlib.gettable("Map3DSystem.Item.PowerItemManager");
				
local type,tonumber = type,tonumber;
local gateway = commonlib.gettable("Map3DSystem.GSL.gateway");
local npl_thread_name = __rts__:GetName();

local system = commonlib.gettable("Map3DSystem.GSL.system");
commonlib.partialcopy(system, {
	-- host game server nid. 
	nid = "1001",
	ws_id = "1",
	ConnectTimer = -100000,
	-- only reconnect every 20 seconds
	ConnectPeriod = 20000, -- 20000 milliseconds
	AliveTimer = 0,
	-- check keep connected every 10 minutes
	AlivePeriod = 600000, -- 600000 milliseconds
	-- once ondisconnected, we will try to Auto reconnect by 2 times before waiting until the next ConnectPeriod
	AutoConnectCount = 2,
	ReconnectCount_ = 0, 
	-- usually configuration from game server
	config = nil,
	is_started = false,
});
system.event_cb_scripts = {};
system.events = commonlib.EventSystem:new();

-- all registered services.
local services = {};
local service_count = 0;
system.services = services;
local uninited_services = {};

-----------------------------
-- public function
-----------------------------

-- get the NID of parent game server hosting this world server. 
function system:GetNID()
	return self.nid;
end

-- get the world server id that this thread is servicing. 
function system:GetWorldServerID()
	return self.ws_id;
end

-- add a new service to the system. 
function system:AddService(name, service)
	-- LOG.std(nil, "system", "GameServer", "service %s is added", name);
	system.services[name] = service;
	if(service) then
		uninited_services[#uninited_services + 1] = service;
		-- start the init timer
		self.init_timer = self.init_timer or commonlib.Timer:new({callbackFunc = function(timer)
			self:LoadModules();
			if(self:IsLoaded()) then
				-- stop the timer if all loaded. 
				timer:Change();

				LOG.std(nil, "system", "GameServer", "all external modules and services loaded");

				self:OnAllServicesLoaded();
			end
		end})
		-- tick 200ms per seconds. 
		self.init_timer:Change(10, 200);
	end
end

-- get service by name. 
function system:GetService(name)
	return services[name];
end

-- load all modules
function system:LoadModules()
	if(#uninited_services > 0) then
		local new_uninited_pool = {};
		local _, service
		for _, service in ipairs(uninited_services) do
			if(service.Init and not service:Init(self)) then
				new_uninited_pool[#new_uninited_pool+1] = service;
			end
		end
		uninited_services = new_uninited_pool;
	end
end

-- whether all services are loaded. 
function system:IsLoaded()
	return (#uninited_services == 0);
end

-- this function is called when services are loaded. 
-- Note we will only start grid service after all other services are loaded. 
function system:OnAllServicesLoaded()	
	
	-- start grid node servers. 
	NPL.load("(gl)script/apps/GameServer/GSL_grid.lua");
	Map3DSystem.GSL_grid:Restart(self.config);

	-- start home grid node servers.	
	NPL.load("(gl)script/apps/GameServer/GSL_homegrid.lua");
	Map3DSystem.GSL_homegrid:Restart(self.config);

	LOG.std(nil, "system", "GameServer", "GSL grid service started. This thread is ready to go!");

	-- inform the game server that we have started
	NPL.activate("(main)script/apps/GameServer/GameServer.lua", {
		type = "worker_thread_inited", 
		ws_id = self:GetWorldServerID(),
		nid = self:GetNID(),
		npc_state_id = __rts__:GetName(),
	}) 
end

-- start the world server as a system service. 
-- @param config: a table of {nid, ws_id, homegrids, logger_config}.
--	where nid is the game server; ws_id is the global world server id. Both should be string. 
--  homegrids is a table of array of {address, id}
function system:StartWorldServer(config)
	self.config = config;
	self.nid = config.nid;
	self.ws_id = config.ws_id;
	commonlib.gettable("Map3DSystem.options");
	System = Map3DSystem;
	System.options.version = System.options.version or config.version;
	System.options.locale = System.options.locale or config.locale;

	self.events = self.events or commonlib.EventSystem:new();
	self.event_cb_scripts = self.event_cb_scripts or {};
	self.log_level = config.log_level or "INFO";
	self.is_started = true;
	self.lobbyproxy_file = config.lobbyproxy_file;
	LOG.SetLogLevel(self.log_level);
	self:InitLogger(config.logger_config)
	if(config.gm_uac) then
		NPL.load("(gl)script/apps/Aries/Debug/GMCmd_Server.lua");
		local GMCmd_Server = commonlib.createtable("MyCompany.Aries.GM.GMCmd_Server");
		if(GMCmd_Server.GetSingleton) then
			local gm_server = GMCmd_Server.GetSingleton();
			gm_server:SetUAC(config.gm_uac or "admin");
		end
	end

	LOG.std(nil, "system", "worldserver", "world server is started for %s(%s). log_level:%s", self.nid, self.ws_id, tostring(LOG.level));


	NPL.load("(gl)script/apps/GameServer/GSL.lua");
	if(config.debug) then
		Map3DSystem.GSL.dump_server_msg = true;
		Map3DSystem.GSL.dump_client_msg = true;
		log("Note: GSL.dump_server_msg is enabled. Edit gameserver.config's debug attribute to disable this\n\n");
	end
	
	-- grid node allocation rules
	NPL.load("(gl)script/apps/GameServer/GSL_config.lua");
	Map3DSystem.GSL.config:load(self.config.gsl_config_filename);

	-- start proxy
	NPL.load("(gl)script/apps/GameServer/GSL_proxy.lua");
	Map3DSystem.GSL.GSL_proxy:Init(self.nid);
	
	-- start game server gateway	
	NPL.load("(gl)script/apps/GameServer/GSL_gateway.lua");
	Map3DSystem.GSL.gateway:Restart(config);

	local _, service
	for _, service in Map3DSystem.GSL.config:EachModule() do
		NPL.load("(gl)"..service.src);
	end
end

-- init Post log function, such that paraworld.PostLog() is available on the server side. 
-- @param logger_config: a table or a string. if string, it is the url. if table it is input table to GSL_LogClient. 
-- e.g. 
--		paraworld.PostServerLog({action = "user_leave_combat", msg = "Reason_GainExp", mode = "pve"}, "any_send_queue_name");
--		paraworld.PostServerLog({action = "user_leave_combat", msg = "Reason_GainExp", mode = "pve"}, "user_leave_combat_log", function(msg)  end);
function system:InitLogger(logger_config)
	if(logger_config) then
		NPL.load("(gl)script/apps/GameServer/LogService/GSL_LogClient.lua");
		self.logger = Map3DSystem.GSL.GSL_LogClient.GetSingleton();
		self.logger:init(logger_config);
	else
		if(not paraworld or not paraworld.PostServerLog) then
			commonlib.setfield("paraworld.PostServerLog", function() end);
		end
	end
end

-- add a system call back script to a given even listener
-- @param ListenerType: one of known string in GSL_SYSTEM_MSG
-- @param callbackScript: the script or function to be called when the listener event is raised. Usually parameters are stored in a NPL parameter called "msg".
--   if callbacksScript is string and convertable to a global function such as "a.b.callback()", it will be saved as a function pointer. 
function system:AddEventListener(ListenerType, callbackScript)
	if(type(callbackScript) == "function") then
		self.events:AddEventListener(ListenerType, callbackScript, self);
	elseif(type(callbackScript) == "string") then
		-- commonlib.echo({"jc event registered", ListenerType, callbackScript})
		local funcCallback = commonlib.getfield(callbackScript);
		if(type(funcCallback) == "function") then
			callbackScript = funcCallback;
		end
		self.event_cb_scripts[ListenerType] = callbackScript;
	end
end

-- remove a call back script from a given even listener
-- @param ListenerType: one of known string in GSL_SYSTEM_MSG
-- @param callbackScript: if nil, all callback of the type is removed. the script or function to be called when the listener event is raised. Usually parameters are stored in a NPL parameter called "msg".
function system:RemoveEventListener(ListenerType, callbackScript)
	if(callbackScript == nil) then
		if(ListenerType ~= "") then
			self.events:RemoveEventListener(ListenerType);
			self.event_cb_scripts[ListenerType] = nil;
		end
	else
		-- TODO: remove only the given callback 
	end
end

-- clear all call back script from a given even listener
-- @param ListenerType: 
function system:ClearEventListener(ListenerType)
	return self:RemoveEventListener(ListenerType);
end

-- clear all registered event listeners
function system:ResetAllEventListeners()
	self.events:ClearAllEvents();
	self.event_cb_scripts = {};
end

-- fire a given event with a given msg
-- @param event. it is always a table of {type, ...}, where the type is the event_name or id, other fields will sent as they are. 
function system:FireEvent(event)
	self.events:DispatchEvent(event, self)
	
	local callbackFunc = self.event_cb_scripts[event.type];
	if(callbackFunc) then
		if(type(callbackFunc) == "function") then
			callbackFunc(event);
		elseif(type(callbackFunc) == "string") then
			msg = event;
			NPL.DoString(callbackFunc);
		end	
	end
end

-- called when receives garbage collection request 
-- input msg is like {type="gc", opt="step", args={}, reply_file="(main)"}
-- 
-- "stop": stops the garbage collector.
-- "restart": restarts the garbage collector. 
-- "collect": performs a full garbage-collection cycle. 
-- "step": performs a garbage-collection step. The step "size" is controlled by arg (larger values mean more steps) in a non-specified way. 
-- "setpause": The garbage-collector pause controls how long the collector waits before starting a new cycle. 
--    Larger values make the collector less aggressive. Values smaller than 100 mean the collector will not wait to start a new cycle. 
--    The default,200, means that the collector waits for the total memory in use to double before starting a new cycle.
-- "setstepmul": The step multiplier controls the relative speed of the collector relative to memory allocation. 
--    Larger values make the collector more aggressive but also increase the size of each incremental step. 
--    Values smaller than 100 make the collector too slow and can result in the collector never finishing a cycle. 
--    The default, 200, means that the collector runs at "twice" the speed of memory allocation. 
function system:OnGarbageCollect(msg)
	msg.args = msg.args or {};
	local tick_before = ParaGlobal.timeGetTime();
	local before_count = collectgarbage("count");
	local gc_result = collectgarbage(msg.opt, msg.args[1], msg.args[2]);
	local after_count = collectgarbage("count");
	local tick_after = ParaGlobal.timeGetTime();
	if(msg.reply_file) then
		NPL.activate(msg.reply_file, {type="gc_reply", before_count = before_count, gc_result = gc_result, after_count = after_count, rts = __rts__:GetName(), gc_time = tick_after - tick_before,})	
	end
end

-- handle reply from previous gc requests. 
-- msg is like {type="gc_reply", before_count = mem in KB, gc_result = true if finished a GC cycle, after_count = mem in KB, rts = thread name, gc_time = time used for the gc})	
function system:OnGarbageCollectReply(msg)
	self.gc_results = self.gc_results or {};
	self.gc_results[msg.rts] = msg;
	
end
	
-- print all GC results
function system:OnPrintGCResult()
	if(self.gc_results) then
		local total_before, total_after = 0,0;
		local rts_name, msg
		for rts_name, msg in pairs(self.gc_results) do
			total_before = total_before + msg.before_count;
			total_after = total_after + msg.after_count;
			LOG.std(nil, "system", "GC", "Thread: %7s | before: %8d KB | after %8d KB | finished cycle: %s | time used: %d", msg.rts, msg.before_count, msg.after_count, tostring(msg.gc_result), msg.gc_time);
		end
		LOG.std(nil, "system", "GC", "Total Mem | before: %8d KB | after %8d KB | ", total_before, total_after);
	end
end

-- send a server message to LobbyServer. 
-- @param msg: {type="fs_chat", user_nid=nid or 0, msg={chat_data=text}} where msg.type must be specified.
-- msg.user_nid can be a user or 0, msg.msg is a table containing msg data
-- e.g. system:SendToLobbyServer({type="pvp_result", user_nid = 0, msg={{nid, score_diff}, {nid, score_diff}}})
function system:SendToLobbyServer(msg)
	NPL.activate(system.lobbyproxy_file, msg);
end

-- shared loot
function system:TryGetSharedLoot(nid, loot_name)
	LOG.std(nil, "debug", "TryGetSharedLoot", "nid %d %s", nid, loot_name);
	NPL.activate(system.lobbyproxy_file, {type="fs_shared_loot", user_nid=nid, msg={loot_name = loot_name, user_nid = nid, threadname=npl_thread_name}});
end

-- send a global chat message to the server. the server may charge for the service. 
-- @param nid: may be nil. if nil, we will ignore substracting money from the caller nid. 
-- @param text: text string
-- @param is_bbs: true to send to users on all servers. if nil, it is a per thread message. 
-- @param callbackFunc: called when message is successfully sent
-- @param ignore_cost: true to ignore stone cost. only do this on server side
-- @param gm_password: a gm command can send unlimited message. 
function system:SendChat(nid, text, is_bbs, callbackFunc, gm_password)
	if(BroadcastService.PushMessage) then
		if(not is_bbs) then
			if(nid) then
				if(PowerItemManager.GetUserAndDragonInfoInMemory) then
					--local userdragoninfo = PowerItemManager.GetUserAndDragonInfoInMemory(tonumber(nid));
					--if(userdragoninfo and userdragoninfo.user and userdragoninfo.dragon) then
						if(System.options.version == "kids" ) then
							-- TODO: kids version server chat is disabled. 
						else
							-- teen: level >=20 and qidou -= 1000
							--if(PowerItemManager.ChangeItem and userdragoninfo.user.emoney>1000 and userdragoninfo.dragon.combatlel>=20) then
								PowerItemManager.ChangeItem(nid, "0~-500~NULL~NULL|", nil, function(msg)
									if(msg and msg.issuccess) then
										if(BroadcastService.PushMessage(text)) then
											if(callbackFunc) then
												callbackFunc();
											end
										end
									end
								end, false, "0~500|");
							--end
						end
					-- end
				end
				return;
			end
			-- this is a local message that is only broadcasted to all users on the local threads. 
			if(BroadcastService.PushMessage(text)) then
				if(callbackFunc) then
					callbackFunc();
				end
			end
		else
			if(system.lobbyproxy_file) then
				if(PowerItemManager.ChangeItem) then
					local function SendServerChat()
						NPL.activate(system.lobbyproxy_file, {type="fs_chat", user_nid=nid or 0, msg={chat_data=text}});
						if(callbackFunc) then
							callbackFunc();
						end
						paraworld.PostServerLog({action="bbs", content = text}, "bbs");
					end

					-- GM password is hardcoded here
					if(gm_password == "paraengine" or not nid) then
						SendServerChat();
						return
					else
						local broadcast_stone_gsid = 12023;
						if(System.options.version == "kids" ) then
							broadcast_stone_gsid = 12023;
							local bHas = PowerItemManager.IfOwnGSItem(nid, 12022);
							if(bHas) then
								broadcast_stone_gsid = 12022;
							end
						else
							broadcast_stone_gsid = 12018;
						end
						if(string.match(text,"lobby|(.+)|lobby"))then
							broadcast_stone_gsid = 12049;
						end
						PowerItemManager.ChangeItem(nid, format("%d~-1~NULL~NULL|", broadcast_stone_gsid), nil, function(msg)
							if(msg and msg.issuccess) then
								SendServerChat();
							end
						end, false, format("%d~1|", broadcast_stone_gsid))
					end
				end
			end
		end
	end
end

--[[
@param msg: a table of {type="restart", config={nid="1001", ws_id="1"}
where  nid is the game server; ws_id is the global world server id. Both should be string. 
]]
function system:Activate(msg)
	local msg_type = msg.type;

	if(msg_type=="s_chat") then
		if(BroadcastService.PushMessage and type(msg.msg) == "string") then
			if(BroadcastService.PushMessage(msg.msg)) then
			end
		end
	elseif(msg_type=="s_shared_loot") then
		local msg_data = msg.msg;
		local loot = SharedLoot.GetLoot(msg_data.loot_name);
		if(loot and loot.adds) then
			LOG.std(nil, "info", "s_shared_loot.begin", msg_data);
			PowerItemManager.ChangeItem(msg_data.user_nid, loot.adds, nil, function(msg)
				if(msg and msg.issuccess) then
					if(loot.is_bbs_to_all) then
						local name;
						if(PowerItemManager.GetUserAndDragonInfoInMemory) then
							local userdragoninfo = PowerItemManager.GetUserAndDragonInfoInMemory(tonumber(msg_data.user_nid));
							if(userdragoninfo and userdragoninfo.user and userdragoninfo.dragon) then
								name = userdragoninfo.user.nickname;
							end
						end

						local text = format("/shared_loot %s %s %d %s", tostring(msg_data.user_nid), msg_data.loot_name, 1, name or tostring(msg_data.user_nid) or "");
						self:SendChat(nil, text, true);
					end
				else
					LOG.std(nil, "error", "s_shared_loot", "failed");
				end
			end);
		end

	elseif(msg_type=="restart") then
		-- start server mode now.
		system:StartWorldServer(msg.config);
	elseif(msg_type=="gc") then
		-- do garbage collection now. input msg is like {type="gc", opt="step", args={}, reply_file="(main)script/apps/GameServer/GSL_system.lua"}
		system:OnGarbageCollect(msg);
	elseif(msg_type=="gc_reply") then
		-- handle reply from previous gc requests. 
		system:OnGarbageCollectReply(msg);
	--elseif(msg_type=="gc_print") then
		---- print result. 
		--system:OnPrintGCResult(msg);
	else
		-- fire event
		system:FireEvent(msg);	

		if(system.is_started and msg_type=="OnUserDisconnect") then
			gateway:RemoveUser(msg.nid);
		end
	end
end

local function activate()
	system:Activate(msg);
end
NPL.this(activate);