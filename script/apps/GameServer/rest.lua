--[[
Author: LiXizhi
Date: 2009-7-20
Desc: REST interface of game server
The (rest) state runs inside a game server.  It sends REST requests to NPLRouter, which in turn sends to DBServer, 
the DBServer processes the message and replies to NPLRouter which in turn forward to this file again. 
-----------------------------------------------
NPL.load("(gl)script/apps/GameServer/rest.lua");
GameServer.rest:init();
-----------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua"); -- many sub dependency included
NPL.load("(gl)script/apps/GameServer/rest_API.lua");
NPL.load("(gl)script/apps/GameServer/rest_local.lua");
NPL.load("(gl)script/apps/GameServer/GSL_uac.lua");
NPL.load("(gl)script/ide/Json.lua");
NPL.load("(gl)script/ide/Network/StreamRateController.lua");
local StreamRateController = commonlib.gettable("commonlib.Network.StreamRateController");


if(not paraworld or not paraworld.PostServerLog) then
	commonlib.setfield("paraworld.PostServerLog", function() end);
end

local rest = commonlib.gettable("GameServer.rest");
local rest_local = commonlib.gettable("GameServer.rest_local");
local format = format;
local LOG = LOG;

-- a template message from game server to npl router to the db server of user_nid
-- e.g. {ver="1.0",result=0,msg="",my_nid=2001,game_nid=2001,user_nid=10089,data_table={name1="value1",name2="value2",},}
rest.output_msg = {
	ver = "1.0",
	game_nid = 2001, 
	g_rts = __rts__:GetName(),
	dest = "db",
	-- send a message to its (d)ispatcher thread
	-- d_rts = "d",
	data_table = {url="AuthUser", req={name1="value1",}}
};
-- a template message from game server to npl router to randomly picked db server
rest.random_msg= {
	ver = "1.0",
	game_nid = 2001, 
	g_rts = __rts__:GetName(),
	dest = "random",
	data_table = {url="AuthUser", req={name1="value1",}}
};
-- whether this is the rest thread. 
-- to change the rest_thread_name, one can assign rest_thread_name prior to calling this function
local is_rest_thread = ((rest_thread_name or "rest") == __rts__:GetName());

-- total number of messages sent
rest.outmsg_count = 0;

local reply_file = "script/apps/GameServer/rest_client.lua";
local reply_file_pre = ":"..reply_file;
local router_nid = "router1";
local imserver_nid = "IMServer1";
rest.api_file = "config/WebAPI.config.xml";
-- total number of request handled
rest.request_count = 0;
-- do some one time init here
function rest:init(input)
	if(self.is_inited) then
		return;
	end
	self.is_inited = true;

	NPL.load("(gl)script/kids/3DMapSystemApp/API/AriesPowerAPI/AriesServerPowerAPI.lua");
	self.output_msg.game_nid = tonumber(input.gameserver_nid);
	self.random_msg.game_nid = tonumber(input.gameserver_nid);
	self.my_nid = input.gameserver_nid;
	self.nid = input.gameserver_nid;
	
	self.router_script = input.router_script; -- "router1:script/apps/NPLRouter/NPLRouter.lua"
	router_nid = self.router_script:match("^(.-):");
	if(not router_nid) then
		router_nid = "router1"
	end

	self.router_dll = input.router_dll; -- "router1:NPLRouter.dll"
	self.router_states = input.router_states or {""};
	self.router_states_count = #(self.router_states);
	local i
	for i = 1, self.router_states_count do
		if(self.router_states[i] ~= "" and not self.router_states[i]:match("^%(")) then
			self.router_states[i] = "("..self.router_states[i]..")";
		end
	end
	
	if(input.logger_config) then
		NPL.load("(gl)script/apps/GameServer/LogService/GSL_LogClient.lua");
		self.logger = Map3DSystem.GSL.GSL_LogClient.GetSingleton();
		self.logger:init(input.logger_config);
	end
			
	reply_file = input.reply_file or reply_file; -- "to which client file to reply"
	reply_file_pre = ":"..reply_file;
	self.api_file = input.api_file or self.api_file; -- "the API web config file if any"
	
	-- read all web API from api config file
	
	local api_root = ParaXML.LuaXML_ParseFile(self.api_file);
	if(not api_root) then
		LOG.std(nil, "error", "REST", "failed loading config file %s", self.api_file);
	else
		local node;
		for node in commonlib.XPath.eachNode(api_root, "/WebAPI/web_services/service") do
			if(node.attr and node.attr.provider and node.attr.provider=="gameserver" and node.attr.shortname) then
				local service_desc = self.API[node.attr.shortname] or {};
				if(node.attr.allow_anonymous and node.attr.allow_anonymous=="true") then
					service_desc.allow_anonymous = true;
				else
					service_desc.allow_anonymous = nil;
				end
				
				if(node.attr.uac) then
					local uac = Map3DSystem.GSL.GSL_uac:new();
					uac:SetUAC(node.attr.uac)
					service_desc.uac = uac;
				end
				self.API[node.attr.shortname] = service_desc;
			end	
		end	
	end	
	self.is_inited = true;

	self.gc_timer = self.gc_timer or commonlib.Timer:new({callbackFunc = function(timer)
		self:TickUserControllers(timer);
	end})
	self.gc_timer:Change(0, 10000);

	LOG.std(nil, "system", "REST", "REST interface on game server is initialized. Is Rest thread:%s", tostring(is_rest_thread));
end

-- get next router address based on rest.outmsg_count
function rest:GetRouterAddress()
	self.outmsg_count = self.outmsg_count + 1;
	local index = self.outmsg_count % self.router_states_count + 1
	--commonlib.echo((self.router_states[index] or "")..self.router_dll)
	return (self.router_states[index] or "")..self.router_dll
end

-- whenever we can not sent message to router or we received a message from unknown router. we will try to reconnect with router. 
-- @param timeoutSeconds: how many seconds to time out. 
function rest:ReconnectRouter(timeoutSeconds)
	LOG.std(nil, "system", "REST", {"reconnecting to router...", rest.router_script, rest.nid, });
	while(NPL.activate(rest.router_script, {my_nid = rest.nid,}) ~= 0) do 
		ParaEngine.Sleep(0.1);
		if(timeoutSeconds) then
			timeoutSeconds = timeoutSeconds - 0.1;
			if(timeoutSeconds<0) then
				LOG.std(nil, "warning", "REST", {"failed to reconnect with router(timed out)...", rest.router_script, rest.nid});
				return false;
			end
		end
	end
	LOG.std(nil, "system", "REST", {"connection reestablished with router...", rest.router_script, rest.nid, });
	return true;
end

-- send a url request to NPL router, which in turn forward to DBServer for processing
function rest:SendRequest(url, req, seq, user_nid)
	if(not self.is_inited) then
		LOG.std(nil, "warning", "REST", "rest is not inited. message is dropped");
		return;
	end
	local out_msg = self.output_msg;
	out_msg.data_table.url = url;
	out_msg.data_table.req = req;
	out_msg.data_table.seq = seq;
	out_msg.user_nid = tonumber(user_nid);
	--LOG.std(nil, "debug", "REST", {"rest:SendRequest to router", out_msg});


	local nRes = NPL.activate(rest:GetRouterAddress(), out_msg);
	if( nRes ~=0 ) then
		-- unable to reach NPL router. 
		LOG.std(nil, "warning", "REST", "unable to reach NPL router"..LOG.tostring(rest:GetRouterAddress())..LOG.tostring(out_msg));
		if(self:ReconnectRouter(1)) then
			LOG.std(nil, "warning", "REST", "router connection reestablished. and message is resent.");
			nRes = NPL.activate(rest:GetRouterAddress(), out_msg);
		else
			LOG.std(nil, "warning", "REST", "failed to reconnect with router. and message is dropped");
		end
	end
	return nRes;
end

-- send a one way request to NPL router, which in turn forward to a random DBServer for processing
-- @param user_nid: can be nil. 
function rest:SendRequestRandomDB(url, req, seq, user_nid)
	local msg = {
		url = url,
		req = req,
		nid = user_nid,
		seq = seq,
	}
	-- LOG.std(nil, "debug", "REST", {"rest:SendRequestRandomDB to router", msg});
	if( NPL.activate("(rest)script/apps/GameServer/rest.lua", msg) ~=0 ) then
		-- unable to reach NPL router. 
		LOG.std(nil, "warning", "REST", "unable to reach NPL router");
	end
end

local users = {};

-- get rest user controller by nid for limiting rest call rate. 
function rest:GetUserController(nid)
	if(nid) then
		local user = users[nid];
		if(not user) then
			user = StreamRateController:new({name=format("rest_%s", nid), 
				-- only history for 20 seconds
				history_length = 40, 
				-- 2 message/second
				max_msg_rate=4,
			});
			users[nid] = user;
		end
		return user;
	end
end

-- called every 10 seconds, to remove expired users.
function rest:TickUserControllers(timer)
	-- remove if no messages in last 60 seconds
	local expire_time = 60000;
	local expire_time_blacklist = 60000*10; -- 10 minutes
	local cur_time = commonlib.TimerManager.GetCurrentTime();
	local expired_users;
	for nid, user in pairs(users) do
		if(not user.IsInBlackList) then
			if((cur_time - user:GetLastMessageTime()) > expire_time) then
				expired_users = expired_users or {};
				expired_users[nid] = true;
			end
		else
			-- for back list
			if((cur_time - user:GetLastMessageTime()) > expire_time_blacklist) then
				user.IsInBlackList = false;
				LOG.std(nil, "info", "blacklist", "removed nid %s from blacklist.", tostring(nid));
			end
		end
	end
	if(expired_users) then
		for nid, _ in pairs(expired_users) do
			users[nid] = nil;
		end
		LOG.std(nil, "info", "rest_removed_users", expired_users);
	end
end

local in_blacklist_reply_msg = {data_table={data = "{\"issuccess\":false,\"errorcode\":413}"}};

-- return true to allow rest query for given nid. 
function rest:CheckQueryRate(msg)
	local nid = msg.nid;
	if(nid) then
		local user = self:GetUserController(nid);
		if(user) then
			if(user.IsInBlackList) then
				LOG.std(nil, "warn", "blacklist_rest", "rejected request because nid %s is still in blacklist", msg.nid);
				return false;
			end
			if(not user:AddMessage(1)) then
				local ip = NPL.GetIP(nid);
				if(ip and (ip:match("^192%.168") or ip:match("^10%.") or ip:match("^127%."))) then
					-- allow for fast connection for local network. 
				else
					-- mark the user in black list, so that it can never query for an 10 minutes. 
					user.IsInBlackList = true;
					LOG.std(nil, "warn", "blacklist_rest", "rejected request because nid %s is calling too fast today", msg.nid);
					return false;
				end
			end
		end
	end
	return true;
end

-- handle a REST request. it sends to NPLRouter for processing
function rest:handle_request(msg)
	-- if message contains key word "url", it is REST request
	local handler = rest.API[msg.url];
	-- commonlib.echo({msg, handler, rest.API["Ping"], rest.API["AuthUser"]});

	if(handler and (handler.allow_anonymous or msg.nid)) then
		if(handler.uac) then
			if(not handler.uac:check_nid(msg.nid)) then
				LOG.std(nil, "warn", "rest", "rest request ignore because nid %s does not have right to call the url %s", msg.nid or "", msg.url);
				return;
			end
		end
	
		self.request_count = self.request_count	+ 1;
		if(not self:CheckQueryRate(msg)) then
			NPL.reject(msg.nid);
			return;
		end

		-- this is request from client to game server, we will just forward the request to NPLRouter, which in turn forwards to DBServer. 
		if(not handler.handler_func) then
			if(handler.allow_anonymous) then
				-- secretely inject the temp connection id to request field, so that message can send back to user
				if(msg.req) then
					msg.req.nid = msg.nid or msg.tid
				end	
			end
			--commonlib.applog("Game Server is sending REST request to router ...")
			rest:SendRequest(msg.url, msg.req, msg.seq, msg.nid);
		else
			handler.handler_func(msg);
		end	
	else
		-- NOTE option1: we can actively close connection instead of letting the client close. 
		-- NPL.reject(msg.nid or msg.tid);
		-- NOTE option2: we do not actively close even auth fails, instead we can develop a timeout on server side.
	end
end

-- make response and invoke self:handle_response(). 
-- @param msg_in: the input message, where the sequence id and nid is read
-- @param msg_out: nil or the output message table. in|out params. 
-- @param msg_json_data: json string or a table that will be converted to json. 
-- @return msg_out
function rest:send_json_response(msg_in, msg_out, msg_json_data)
	msg_out = msg_out or {};
	msg_out.user_nid = msg_in.nid or msg_in.tid;
	msg_out.data_table = msg_out.data_table or {};
	msg_out.data_table.seq = msg_in.seq
	if(type(msg_json_data) == "table") then
		msg_out.data_table.data = commonlib.Json.Encode(msg_json_data)
	elseif(msg_json_data) then
		msg_out.data_table.data = msg_json_data;
	end
	self:handle_response(msg_out);
	return msg_out;
end

-- handle a reply msg from the NPLRouter
function rest:handle_response(msg)
	-- this is reply from DBServer-->NPLRouter to game server, we will just forward back to client
	-- e.g. {ver="1.0",result=0,msg="",my_nid=1901,game_nid=2001,user_nid=10089,data_table={name1="value1",name2="value2",},}
	-- commonlib.applog("game server got REST reply "..__rts__:GetName());	commonlib.echo(msg);

	if(msg.user_nid ~= 0) then
		-- authenticated calls: just send back. {data="json string", seq=sequence_number}
		NPL.activate(msg.user_nid..reply_file_pre, msg.data_table);
		
	elseif(msg.data_table and msg.data_table.last_nid and msg.data_table.new_nid) then
		-- the database server 
		if(msg.data_table.new_nid > 0) then
			msg.user_nid = msg.data_table.new_nid;
			
			-- check query rate
			msg.nid = tostring(msg.data_table.new_nid);
			if(self:CheckQueryRate(msg)) then
				LOG.std(nil, "system", "REST", msg.data_table.new_nid.." is authenticated");
				NPL.accept(tostring(msg.data_table.last_nid), tostring(msg.data_table.new_nid));
				NPL.activate(msg.user_nid..reply_file_pre, msg.data_table);
			else
				-- in black list now
				LOG.std(nil, "system", "blacklist", "rejected authenticated of %s because it is in blacklist", msg.user_nid);
				msg.data_table.data = in_blacklist_reply_msg.data_table.data;
				NPL.activate(msg.data_table.last_nid..reply_file_pre, msg.data_table);
			end
		else
			-- NOTE option1: we can actively close connection instead of letting the client close. 
			-- NPL.reject(msg.data_table.last_nid);
			-- NOTE option2: we do not actively close even auth fails, instead we can develop a timeout on server side.
			NPL.activate(msg.data_table.last_nid..reply_file_pre, msg.data_table);
		end	
	end
end

local function activate()
	local msg = msg;
	--LOG.std(nil, "debug", "REST", msg);

	if(msg.url) then
		-- handle rest request
		rest:handle_request(msg)
	elseif(msg.user_nid) then
		-- handle rest response from rounter
		
		-- Security Note: it is possible for client to cheat, so we shall check nid to ensure it is from NPLRouter, instead of client. 
		if(msg.nid == router_nid or msg.nid == imserver_nid) then
			if(is_rest_thread) then
				rest:handle_response(msg)
			else
				-- this is mostly reply to rest_local in virtual world server thread. Power API replies
				rest_local:handle_response(msg);
			end
		elseif(msg.tid)then
			-- perhaps the router just restarted, so we will drop the message and try to re-authenticate with router. 
			LOG.std(nil, "warning", "REST", "unknown router message received. try to re-authenticate with router");
			local ip = NPL.GetIP(msg.tid);
			if(ip and (ip:match("^192%.168") or ip:match("^10%."))) then
				-- if ip is intranet, we will trust it and try to reconnect. 
				if(rest:ReconnectRouter(1)) then
					-- Security note: it is still dangerous if a foreign pc is in the intranet. 
					-- in which case, we should totally drop following message handling
					if(is_rest_thread) then
						rest:handle_response(msg)
					else
						-- this is mostly reply to rest_local in virtual world server thread. Power API replies
						rest_local:handle_response(msg);
					end
				else
					LOG.std(nil, "warning", "REST", "reconnect with router failed, so message is droped");
				end
			else
				-- someone try to attack us to be like a router
				LOG.std(nil, "warning", "REST", "unknown message attack from ip %s (%s), which try to emulate the router. Connection closed", ip, msg.tid);
				NPL.reject(msg.tid);
			end
		else
			LOG.std(nil, "warning", "REST", "unknown msg from nid %s is received. Drop it", tostring(msg.nid));
		end	
		
	elseif(msg.type == "init" and msg.nid==nil and msg.tid==nil) then	
		-- the above ensures that only local files can activate the following code. 
		rest:init(msg);
	end
end
NPL.this(activate)