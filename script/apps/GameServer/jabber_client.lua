--[[
Title: jabber client(server) class
Author: LiXizhi
Date: 2009-11-5
Desc: a wrapper class to the raw NPL jabber client interface. 
A jabber client is usually used for peer-to-peer communication, such as IM and PvP mini games. 
In a MMO game, it can also be used to query non-critical information from another player, such as player location. 
We allows creating multiple instances of jabber client, each with a district connection to the server. 
However, there is usually one instance in a game, unless for user emulation stress test. 
   * note: Auto reconnection is implemented.
-----------------------------------------------
NPL.load("(gl)script/apps/GameServer/jabber_client.lua");

-- the following shows how to develop a basic IM class using jabber_client
local ChatIM_Class = commonlib.inherit();
function ChatIM_Class:ctor()
	-- create a jabber client and register event
	self.jabber_client = GameServer.jabber.client:new({})
	self.jabber_client:AddEventListener("OnConnect", ChatIM_Class.JE_OnConnect, self);
	self.jabber_client:AddEventListener("OnAuthenticate", ChatIM_Class.JE_OnAuthenticate, self);
	self.jabber_client:AddEventListener("OnDisconnect", ChatIM_Class.JE_OnDisconnect, self);
	self.jabber_client:AddEventListener("OnAuthError", ChatIM_Class.JE_OnAuthError, self);
	self.jabber_client:AddEventListener("OnError", ChatIM_Class.JE_OnError, self);
	self.jabber_client:AddEventListener("OnSendFail", ChatIM_Class.JE_OnSendFail, self);
	
	-- Create a custom RPC style p2p service, remember to add service to "config/JabberAPI.config.xml" to make it public. 
	self.jabber_client:AddEventListener("OnPing", ChatIM_Class.OnPing_RPC_handler, self);
end

function ChatIM_Class:log(...)
	commonlib.echo(...)
end

-- a custom RPC p2p event handler
-- @param event: the event table. event.type is the url of the request; event.req contains the request table. 
-- @return the response data table. 
function ChatIM_Class:OnPing_RPC_handler(event)
	return {time=ParaGlobal.timeGetTime()};
end

function ChatIM_Class:JE_OnConnect(event)
	self:log(event)
end

function ChatIM_Class:JE_OnAuthenticate(event)
	self:log(event)
	
	-- demostrating send an IM request message to self.jid (or any jid who is running the same handler)
	self.jabber_client:SendRequest(self.jid, "ping", {}, function(jabber_client, jid_from, body) 
		commonlib.log("hi, I am online %s\n", jid_from)
		commonlib.echo(body)
	end)
end

function ChatIM_Class:JE_OnDisconnect(event)
	self:log(event)
end

function ChatIM_Class:JE_OnAuthError(event)
	self:log(event)
end

function ChatIM_Class:JE_OnError(event)
	self:log(event)
end

-- OnSendFail: subtype=8192 is received. this is an invalid message posted back by server to the sender, because the receiver is not online.  
function ChatIM_Class:JE_OnSendFail(event)
	self:log(event)
end

function ChatIM_Class:JE_OnMessage(event)
	self:log(event)
end

function ChatIM_Class:start(jid, password)
	self.jid = jid;
	self.jabber_client:start(jid, password)
end

-- now create an instance of that class and connect
local myIM = ChatIM_Class:new();
myIM:start("20527@test.pala5.cn", "8213225652864")

-- set to true to write all stream to log/jabber*.log
myIM.debug_stream = true
-----------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua"); 
NPL.load("(gl)script/ide/EventDispatcher.lua");

-- define a base class with constructor
local client = commonlib.inherit(nil, commonlib.gettable("GameServer.jabber.client"))
local LOG = LOG;
-- set to true to output all IO to log
client.debug_stream = client.debug_stream or false;

-- dump file
client.dumpfile = "log/jabber"

-- private: 
client.LastConnectionTime = 0;
-- connect timer
client.ConnectTimer = -100000;
-- only reconnect every 20 seconds
client.ConnectPeriod = 20000; -- 20000 milliseconds
-- once ondisconnected, we will try to Auto reconnect by 2 times before waiting until the next ConnectPeriod
client.AutoConnectCount = 2;
client.ReconnectCount_ = 0; 

-- connection time out in seconds 
client.conn_timeout = 10;

-- a mapping from url to {shortname, provider, }
client.API = client.API or {};

client.config = {
	api_file = "config/JabberAPI.config.xml",
	ChatDomain = nil, 
	-- ususally defaults to 8080
	ChatPort = nil,
}


-- all known clients, mapping from server_nid to client object. 
-- There can only be one client connecting to one server nid. For multiple user emulations. One can use multiple game_server_nid mapping to the same physical game server. 
local clients = {};

-- get client instance by jid
local function GetClient(jid)
	return clients[jid];
end

-- constructor
function client:ctor()
	-- jid of this client. it is usually same as NPL's nid, if the jabber server supports NPL authentication. 
	self.jid = "";
	self.pending_requests = {};
	self.events = commonlib.EventDispatcher:new();
	self.mytimer = commonlib.Timer:new({
		callbackFunc = function(timer)
			self:connect();
		end});
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
	
	-- load from file. 
	filename = filename or "config/GameClient.config.xml"
	-- filename = "script/apps/GameServer/test/local.GameClient.config.xml"
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(not xmlRoot) then
		LOG.std("", "error", "JC", "failed loading game server config file %s", filename);
		return;
	end	
	
	local chat_domain
	local node;
	node = commonlib.XPath.selectNodes(xmlRoot, "/GameClient/chat_server_addresses")[1];
	if(node and node.attr) then
		chat_domain = node.attr.domain;
		self.config.ChatDomain = chat_domain;
		self.config.api_file = node.attr.api_file or self.config.api_file;
	end
	
	self.config.ChatServers = {};
	self.ServerIndex = 1;
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/GameClient/chat_server_addresses/address") do
		if(node.attr and node.attr.host and node.attr.port) then
			self.config.ChatServers[#(self.config.ChatServers) + 1] = node.attr;
			if(not chat_domain) then
				self.config.ChatDomain = node.attr.host;
				self.config.ChatPort = tonumber(node.attr.port);
			end
		end	
	end
	
	-- read all web API from api config file
	local api_root = ParaXML.LuaXML_ParseFile(self.config.api_file);
	if(not api_root) then
		LOG.std("", "error", "JC", "failed loading config file %s", self.config.api_file);
	else
		local node;
		for node in commonlib.XPath.eachNode(api_root, "/JabberAPI/jabber_services/service") do
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
				service_desc.handler = node.attr.handler;
				
				self.API[node.attr.url] = service_desc;
			end
		end
	end
end

-- Get the jabber client. It does not open a connection immediately.
function client:GetClient()
	return self.jc;
end

-- get the currently connected client. return nil, if connection is not valid
function client:GetConnectedClient()
	local jc = self:GetClient();
	if(jc and jc:GetIsAuthenticated()) then
		return jc;
	end
end

-- this function will return true if nMilliSecondsPassed is passed since last timer of timerName is set
-- @param timerName: such as "ConnectTimer"
-- @param nMilliSecondsPassed: such as 20000 milliseconds
-- @param bUpdateIfTrue: whether it will update last connection time if true.
function client:CheckLastTime(timerName, nMilliSecondsPassed, bUpdateIfTrue)
	local nTime = ParaGlobal.GetGameTime();
	if((nTime - self[timerName]) > nMilliSecondsPassed ) then -- 20000 milliseconds
		if(bUpdateIfTrue) then
			self[timerName] = nTime;
		end	
		return true;
	end
end


-- connect to jabber server. If already connected, it will do nothing. 
-- @param jid: such as "123@paraengine.com". it can be nil where the value of the last call is used. 
-- @param password: "". it can be nil where the value of the last call is used. 
-- @return nil if failed. true if connecting or already connected.
function client:connect(jid, password)
	
	if(not self.jc) then
		self.jid = jid;
		self.password = password;
		-- commonlib.echo({self.jid, self.password, self.config.ChatPort})
		local jc = JabberClientManager.CreateJabberClient(self.jid);
		self.jc = jc;
		jc.Password = self.password;
		
		local address = self.config.ChatServers[self.ServerIndex];
		if(address) then
			if(address.host) then	
				jc.Server = address.host;
			end
			if(address.port) then	
				jc.Port = tonumber(address.port);
			end
		else
			if(self.config.ChatPort) then	
				jc.Port = tonumber(self.config.ChatPort);
			end
		end
		
		jc:ResetAllEventListeners();
		-- bind event
		jc:AddEventListener("JE_OnConnect", "GameServer.jabber.client.JE_OnConnect()");
		jc:AddEventListener("JE_OnAuthenticate", "GameServer.jabber.client.JE_OnAuthenticate()");
		jc:AddEventListener("JE_OnDisconnect", "GameServer.jabber.client.JE_OnDisconnect()");
		jc:AddEventListener("JE_OnAuthError", "GameServer.jabber.client.JE_OnAuthError()");
		jc:AddEventListener("JE_OnError", "GameServer.jabber.client.JE_OnError()");
		
		jc:AddEventListener("JE_OnStanzaMessageChat", "GameServer.jabber.client.JE_OnStanzaMessageChat()");
		
		jc:AddEventListener("JE_OnRoster", "GameServer.jabber.client.JE_OnRoster()");
		jc:AddEventListener("JE_OnSubscriptionRequest", "GameServer.jabber.client.JE_OnSubscriptionRequest()");
		jc:AddEventListener("JE_OnUnsubscriptionRequest", "GameServer.jabber.client.JE_OnUnsubscriptionRequest()");
		
		jc:AddEventListener("JE_OnSelfPresence", "GameServer.jabber.client.JE_OnSelfPresence()");
		jc:AddEventListener("JE_OnRosterPresence", "GameServer.jabber.client.JE_OnRosterPresence()");
		
		-- this will also track dropped messages, where the receiver is not online. 
		jc:AddEventListener("JE_OnMessage", "GameServer.jabber.client.JE_OnMessage()");
		
		-- two default event handlers
		self:AddEventListener("OnPing", self.OnPing, self);
		self:AddEventListener("OnEcho", self.OnEcho, self);
	end
	if(not self.jc:GetIsAuthenticated()) then
	
		if(self.AllowRetry or  self:CheckLastTime("ConnectTimer", self.ConnectPeriod, true)) then -- 20000 milliseconds
			self.AllowRetry = nil;
			if(not self.jc:Connect()) then
				LOG.std("", "warning", "JC", "cannot make connection for %s (%s:%s)", self.jid, self.jc.Server, self.jc.Port);
				return
			else
				LOG.std("", "system", "JC", "connecting to JC %s (%s:%s)... ", self.jid, self.jc.Server, self.jc.Port);
				-- add to active clients pool. 
				clients[self.jid] = self;
				-- start the timer after ConnectPeriod milliseconds, and signal every ConnectPeriod millisecond
				self.mytimer:Change(self.ConnectPeriod, self.ConnectPeriod)
			end
		else
			self:log("you can not connect when you have just making a connection attempt a while ago");
		end	
	end
end

-- call this function just once when the game starts. It will connect to the jabber server, after loading configuration files. 
-- it is safe to call multiple times, only the first time does the work. 
-- @param jid: such as "123@paraengine.com"
-- @param password: ""
-- @return nil if failed. true if connecting or already connected.
function client:start(jid, password)
	if(not self.is_started) then
		self.is_started = true;
		
		-- load configuration files. 
		self:load_config(Map3DSystem.options.clientconfig_file);
	end	
	-- connect 
	return self:connect(jid, password);
end

-- write to service log with self.jid 
function client:log(...)
	commonlib.servicelog(self.dumpfile, ":> %s", self.jid);
	commonlib.servicelog(self.dumpfile, ...);
end
-- write to service log without jid 
function client:dump(...)
	commonlib.servicelog(self.dumpfile, ...);
end

-- register event and call back function. Currently only one callback is supported per event type and per client. 
-- @param event_name: It can be 
--		"OnConnect", 
--		"OnAuthenticate", 
--		"OnDisconnect", 
--		"OnAuthError", "OnError", 
--		"JE_OnRoster", "JE_OnSubscriptionRequest","JE_OnUnsubscriptionRequest", "JE_OnSelfPresence", "JE_OnRosterPresence", "JE_OnStanzaMessageChat", 
--		"OnMessage": normal chat message
--		"OnSendFail": subtype=8192 is received. this is an invalid message posted back by server to the sender, because the receiver is not online.  
--		"[JabberAPI.config.xml]": it can also be the handler name as defined in JabberAPI.config.xml, whose provider type is "event"
-- @param func: the callback function(funcHolder, event, jabber_client)  end, where event is  a table of {type, from, body}, where the type is the event_name, from is the caller, body is the message body. 
--   jabber_client is this receiver jabber client who dispatched the event. 
-- @param funcHolder: this is an object that is passed as the first parameter to the callback function. It is usually the self in self:func() end, 
function client:AddEventListener(event_name, func, funcHolder)
	self.events:AddEventListener(event_name, func, funcHolder)
end

-- remove all handlers of a given name
function client:RemoveEventListener(event_name)
	self.events:RemoveEventListener(event_name)
end

-- dispatch a given event, this function will be called automatically. 
-- @param event. it is always a table of {type, from, body}, where the type is the event_name, from is the caller, body is the message body. 
-- @return: the callback return value is also returned. 
function client:DispatchEvent(event)
	return self.events:DispatchEvent(event, self)
end

---------------------------------
-- jabber event callback functions: private 
---------------------------------

-- one can overwrite this event handler
function client:OnPing(event)
	return {time=ParaGlobal.timeGetTime()};
end

-- one can overwrite this event handler
function client:OnEcho(event)
	return event.body;
end

function client.JE_OnConnect()
	local self = GetClient(msg.jckey);
	if(self) then
		self:log("Connection established");
		msg.type = "OnConnect";
		self:DispatchEvent(msg);
		-- kill reconnection timer
		self.mytimer:Change();
	end
end
function client.JE_OnAuthenticate()
	local self = GetClient(msg.jckey);
	if(self) then
		self:log("JC authenticated");
		msg.type = "OnAuthenticate";
		self:DispatchEvent(msg);
		-- once connected, reset reconnect count. 
		self.ReconnectCount_ = 0;
	end
end
function client.JE_OnDisconnect()
	local self = GetClient(msg.jckey);
	if(self) then
		self:log("Disconnected");
		msg.type = "OnDisconnect";
		if(not self:DispatchEvent(msg)) then
			if(not self.jc) then
				return
			end
			-- shall we do auto reconnect, if custom handler does not handle it or returns nil. 
			if (self.ReconnectCount_ < self.AutoConnectCount) then
				self.ReconnectCount_ = self.ReconnectCount_ +1;
				self:log("JC: auto reconnecting on the %d times\n", self.ReconnectCount_)
				self.AllowRetry = true; -- this will bypass the connectperiod check and reconnect immediately. 
				self:connect();
			else
				self:log("JC: we shall wait %d milliseconds before trying again.\n", self.ConnectPeriod)
				self.mytimer:Change(self.ConnectPeriod, self.ConnectPeriod);
			end
		end
	end
end
function client.JE_OnAuthError()
	local self = GetClient(msg.jckey);
	if(self) then
		self:log("Auth Error!");
		msg.type = "OnAuthError";
		self:DispatchEvent(msg);
	end
end
function client.JE_OnError()
	local self = GetClient(msg.jckey);
	if(self) then
		self:log("Error!"); commonlib.echo(msg);
		msg.type = "OnError";
		self:DispatchEvent(msg);
	end
end


function client.JE_OnStanzaMessageChat()
	local self = GetClient(msg.jckey);
	if(self) then
		if(self.debug_stream) then 	self:log(msg);	end
		msg.type = "OnStanzaMessageChat";
		self:DispatchEvent(msg);
	end
end

function client.JE_OnRoster()
	local self = GetClient(msg.jckey);
	if(self) then
		if(self.debug_stream) then 	self:log(msg);	end
		msg.type = "OnRoster";
		self:DispatchEvent(msg);
	end
end

function client.JE_OnSubscriptionRequest()
	local self = GetClient(msg.jckey);
	if(self) then
		if(self.debug_stream) then 	self:log(msg);	end
		msg.type = "OnSubscriptionRequest";
		self:DispatchEvent(msg);
	end
end

function client.JE_OnUnsubscriptionRequest()
	local self = GetClient(msg.jckey);
	if(self) then
		if(self.debug_stream) then 	self:log(msg);	end
		msg.type = "OnUnsubscription";
		self:DispatchEvent(msg);
	end
end

function client.JE_OnSelfPresence()
	local self = GetClient(msg.jckey);
	if(self) then
		if(self.debug_stream) then 	self:log(msg);	end
		msg.type = "OnSelfPresence";
		self:DispatchEvent(msg);
	end
end

function client.JE_OnRosterPresence()
	local self = GetClient(msg.jckey);
	if(self) then
		if(self.debug_stream) then 	self:log(msg);	end
		msg.type = "OnRosterPresence";
		self:DispatchEvent(msg);
	end
end

function client.JE_OnMessage()
	local self = GetClient(msg.jckey);
	if(self) then
		if(self.debug_stream) then
			self:dump("%s received msg from %s", self.jid, msg.from);
			self:dump(msg);
		end
		
		if(msg.subtype) then
			if( msg.subtype == 2 or msg.subtype == 32 or msg.subtype == 8192) then
				-- the client msg.from is possibly offline, since we received an invalid message, here. 
				-- because server is epoll style, we do nothing about it. 
				msg.type = "OnSendFail";
				self:DispatchEvent(msg);
				return
			end
		end
	
		local body = NPL.LoadTableFromString(msg.body);
		if (body) then
			if (body.type=="IQ" and body.seq) then
				-- process IQ(RPC style request message)
				if(body.url and body.req) then
					-- this is an request
					local service_desc = self.API[body.url];
					if(service_desc) then
						msg.type = service_desc.handler;
						local reply = self:DispatchEvent(msg);
						if(reply) then
							local out_msg = {type="IQ", seq = body.seq, data = reply}
							if(self.jc) then
								self.jc:Message(msg.from, commonlib.serialize_compact(out_msg));
							else
								self:log("unable to send IQ reply");
							end	
						end
					else
						self:log("this peer(server) does not support IQ request of %s", body.url);	
					end
				else
					-- this is an reply
					local request = self:GetRequestByID(body.seq);
					if(type(request) == "table") then
						if(request.timer) then
							-- now kill the timer.
							request.timer:Change();
						end
						
						if(type(request.callback_func) == "function") then
							request.callback_func(self, msg.from, body.data);
						end
					end
				end	
			end
		else
			-- ordinary text message, forward to default handler
			self:log("ordinary text message received");
			self:log(msg);
			msg.type = "OnMessage";
			self:DispatchEvent(msg);
		end
	end
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

---------------------------------------------
-- RPC Request based supporting functions. 
---------------------------------------------
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

-- send a request via the rest interface. Call this function if one wants to directly call remote rest interface without using a REST wrapper. 
-- @param jid: the receiver jid to send to. 
-- @param url: string. It should be one of the API short name. see "config/JabberAPI.config.xml"
-- @param request: a table of name value pairs
-- @param callback_func: function(jabber_client, jid_from, body)  end, where the body contains the message body output after converting string to npl msg table.
-- @param timer: if nil, no time out callback, otherwise it is a virtual commonlib.Timer object. we will stop the timer when a request is received. 
--   in jabber service wrapper, we usually create a timer per url or per pool, and use the timer for request time out. 
function client:SendRequest(jid, url, request, callback_func, timer)
	if(not self.is_started or not self.jc) then
		self:log("rest client is not initialized.\n")
		return
	end
	
	local seq = self:AddPendingRequest({callback_func = callback_func, url=url, req=request, timer=timer});
	
	local body = {type="IQ", url = url, req = request, seq=seq}
	
	if(self.debug_stream) then
		self:dump("SendRequest from %s to %s", self.jid, jid);
		self:dump(body);
	end
	
	return self.jc:Message(jid, commonlib.serialize_compact(body));
end
