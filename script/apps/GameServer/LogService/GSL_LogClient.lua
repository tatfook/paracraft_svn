--[[
Title: Log client
Author(s): LiXizhi
Date: 2011/7/25
Desc: one need to create an instance of this class before using it. 
-----------------------------------------------
NPL.load("(gl)script/apps/GameServer/LogService/GSL_LogClient.lua");
local logger = Map3DSystem.GSL.GSL_LogClient.GetSingleton();
logger:init({my_nid=string, logserver_nid = string, logserver_thread_name=string, });
-- post using default file "GSL"
paraworld.PostServerLog({action="test", any_data="hello"})
-- post log to specified file
paraworld.PostServerLog({action="test", any_data="hello"}, "FileName")
-- post log with callback from server (DO NOT USE CALLBACK unless you really mean it, it waste resource)
paraworld.PostServerLog({action="test", any_data="hello"}, nil, function()  echo("log success!")  end)

-- post log using logger, which is same as above.
logger:log({action="test", any_data="hello"}, "GSL", function() echo("success!") end)
-----------------------------------------------
]]
NPL.load("(gl)script/ide/timer.lua");
NPL.load("(gl)script/apps/GameServer/LogService/GSL_LogClient.lua");

local tostring = tostring;
local format = format;
local type = type;
local GSL_LogClient = commonlib.inherit(nil, commonlib.gettable("Map3DSystem.GSL.GSL_LogClient"))

local server_addr_template = "script/apps/GameServer/LogService/GSL_LogServer.lua";
-- the global instance, because there is only one instance of this object
local g_singleton;

------------------------
--  GSL_LogClient class
------------------------
function GSL_LogClient:ctor()
	
end

-- get the global singleton.
function GSL_LogClient.GetSingleton()
	if(not g_singleton) then
		g_singleton = GSL_LogClient:new();
	end
	return g_singleton;
end

-- do some one time init here
-- @param msg: a table or a string. if string, it is the url. 
-- if table,  it is {my_nid=string, logserver_nid = string, logserver_thread_name=string, }
function GSL_LogClient:init(msg)
	if(self.is_inited) then
		return
	else
		self.is_inited = true;
	end
	if(type(msg) == "table") then
		self.logserver_thread_name = msg.logserver_thread_name or "log";
		self.logserver_nid = msg.logserver_nid or "log";
		self.game_id = msg.my_nid;
		self.my_thread_name = __rts__:GetName();
		if(self.game_id ~= self.logserver_nid) then
			self.address = format("(%s)%s:%s", msg.logserver_thread_name, msg.logserver_nid, server_addr_template);
		else
			self.address = format("(%s)%s", msg.logserver_thread_name, server_addr_template);
		end
		
		self.log_msg_template = {
			type = "log",
			thread = self.my_thread_name,
			game_id = self.game_id,
			msg = nil,
			seq = nil,
		}
		commonlib.setfield("paraworld.PostServerLog", function(msg, queue_name, callbackFunc)
			self:log(msg, queue_name, callbackFunc)
		end)
		LOG.std(nil, "system", "logclient", "logger is set to (%s)%s", self.logserver_thread_name, self.logserver_nid)
		--paraworld.PostServerLog({action = "logger_init", msg = "start"})

		local test_me = false;
		if(test_me) then
			-- post using default file "GSL"
			paraworld.PostServerLog({action="test", any_data="hello"})
			-- post log to specified file
			paraworld.PostServerLog({action="test", any_data="hello"}, "FileName")
			-- post log with callback from server
			paraworld.PostServerLog({action="test", any_data="hello"}, nil, function()  echo("log success!")  end)
		end

	elseif(type(msg) == "string") then
		local url = msg;
		if(paraworld and paraworld.PostServerLog) then
			return
		elseif(not url or url=="") then
			commonlib.setfield("paraworld.PostServerLog", function()
				-- if no url is provided, we will use a dummy function. 
			end)
			return
		end
	
		NPL.load("(gl)script/kids/3DMapSystemApp/API/webservice_wrapper.lua");

		-- enable post log here 
		local bEnablePostLog = true;
		local nFailCountDown = 3;
		paraworld.CreateRESTJsonWrapper("paraworld.PostServerLog", url or "http://192.168.0.51:84/APIs/PostLog.ashx", 
			function (self, msg, id, callback_func, callbackParams, postMsgTranslator)
				if(bEnablePostLog) then
					-- msg.nid = System.User.nid;
					msg.format = nil;
					msg.thread = npl_thread_name;
					local plainstr = commonlib.serialize_compact2(msg) or "";
					LOG.std(nil, "system","PostLog", plainstr);
					plainstr = string.sub(plainstr, 2, -2);
		
					local keys = {};
					local k, v;
					for k, v in pairs(msg) do
						table.insert(keys, k);
					end
					local _, key;
					for _, key in pairs(keys) do
						msg[key] = nil;
					end
					msg.msg = plainstr;
				else
					local plainstr = commonlib.serialize_compact2(msg) or "";
					LOG.std(nil, "system","PostLog", "[local]: %s", plainstr);
					if(callbackFunc) then
						callbackFunc(nil, callbackParams)
					end	
					return true;
				end
			end,
			-- post process function
			function (self, msg)
				if(not msg) then
					if(nFailCountDown <=0) then
						LOG.std(nil,  "warn","PostLog", "post log failed. paraworld.PostLog is disabled. you will only see paraworld.PostLog [local]. but message is not sent to server.");
						bEnablePostLog = false;
					else
						LOG.std(nil, "warn","PostLog", "post log failed. we may retry %d times", nFailCountDown);
						nFailCountDown = nFailCountDown - 1;
					end
				else
					LOG.std(nil, "debug","PostLog", "successfully sent");
					nFailCountDown = 3;
				end
			end
		);
		-- paraworld.PostServerLog({action = "Post Log started"}, "server", function(msg) 	end);
	end
end

local seq = 0;
local msg_queue = {};
function GetNextSeq()
	seq = seq + 1;
	return seq;
end

-- set the message to log server
-- @param msg: a table like {action = "user_leave_combat", msg = "Reason_GainExp", mode = "pve"}
-- @param log_filename: to which log file on the server the log will write to. if nil, it will be "GSL"
-- @param callbackFunc: nil, or a callback function when log is confirmed on the server side. 
--  we recommend this to be nil in most occasions. 
-- @param timeout: in ms, defaults to 5000 milliseconds
function GSL_LogClient:SendMessage(msg, log_filename, callbackFunc, timeout)
	if(not msg) then return end
	local msg_out = self.log_msg_template;
	if(callbackFunc) then
		local seq = GetNextSeq();
		msg_out.seq = seq;
		local callback = {
			callbackFunc=callbackFunc, 
			timer = commonlib.Timer:new({callbackFunc = function(timer)
				msg_queue[seq] = nil;
				callbackFunc();
			end}),
		};
		msg_queue[seq] = callback;
		callback.timer:Change(timeout or 5000, nil);
	else
		msg_out.seq = nil
	end
	msg_out.logname = log_filename;
	msg_out.msg = msg;
	
	if( NPL.activate(self.address, msg_out) ~=0 ) then
	end
end

-- send a log message
-- @param msg: a table like {action = "user_leave_combat", msg = "Reason_GainExp", mode = "pve"}
-- @param log_filename: to which log file on the server the log will write to. if nil, it will be "GSL"
-- @param callbackFunc: nil, or a callback function when log is confirmed on the server side. 
--  we recommend this to be nil in most occasions. 
function GSL_LogClient:log(msg, log_filename, callbackFunc)
	self:SendMessage(msg, log_filename, callbackFunc);
end

-- activate the message
local function activate()
	local seq = msg.seq;
	if(seq) then
		local callback = msg_queue[seq];
		if(callback) then
			if(callback.callback) then
				callback.callback();
			end
			if(callback.timer) then
				callback.timer:Change();
			end
			msg_queue[seq] = nil;
		end
	end
end
NPL.this(activate);