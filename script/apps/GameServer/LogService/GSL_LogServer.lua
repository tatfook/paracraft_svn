--[[
Title: Log server
Author(s): LiXizhi
Date: 2011/7/25
Desc: Security note: this must be inside the firewall, since it will accept any incoming connection. 
-----------------------------------------------
NPL.load("(gl)script/apps/GameServer/LogService/GSL_LogServer.lua");
local logger = Map3DSystem.GSL.GSL_LogServer:new();
logger:init({my_nid=string, logserver_nid = string, logserver_thread_name=string, folder=string, force_flush=boolean, append_mode=boolean});
-----------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/timer.lua");

local tostring = tostring;
local format = format;
local type = type;
local GSL_LogServer = commonlib.inherit(nil, commonlib.gettable("Map3DSystem.GSL.GSL_LogServer"))

local client_reply_addr = "script/apps/GameServer/LogService/GSL_LogClient.lua";
-- the global instance, because there is only one instance of this object
local g_singleton;
local LogServer_nid = "log";

------------------------
--  GSL_LogServer class
------------------------
function GSL_LogServer:ctor()
	NPL.load("(gl)script/apps/GameServer/GSL_uac.lua");
	self.uac = Map3DSystem.GSL.GSL_uac:new();
	self.uac:SetUAC("intranet");
end

-- get the global singleton.
function GSL_LogServer.GetSingleton()
	if(not g_singleton) then
		g_singleton = GSL_LogServer:new();
	end
	return g_singleton;
end

-- do some one time init here
-- @param msg: {my_nid=string, logserver_nid = string, logserver_thread_name=string, folder=string, force_flush=boolean, append_mode=boolean} 
function GSL_LogServer:init(msg)
	if(msg.my_nid ~= msg.logserver_nid) then
		return
	end
	self.my_nid = msg.my_nid;
	self.my_thread_name = __rts__:GetName();
	self.folder = msg.folder or "log";
	self.append_mode = msg.append_mode;
	self.force_flush = msg.force_flush;
	if(self.folder) then
		if(not self.folder:match("/$")) then
			self.folder = self.folder.."/"
		end
		if(not self.folder:match("^/")) then
			ParaIO.CreateDirectory(self.folder);
		end
	end
	if(self.my_thread_name ~= msg.logserver_thread_name) then
		return
	end
	LOG.std(nil, "system","logserver", "Log server initialized. log file path:%s", self.folder);
end

local loggers = {};
function GSL_LogServer:GetLogger(name)
	name = name or "GSL";
	local logger = loggers[name];
	if(not logger) then
		logger = {};
		loggers[name] = logger;
		local logger_ = commonlib.servicelog.GetLogger(name);
		logger_:SetLogFile(self.folder..name.."_"..ParaGlobal.GetDateFormat("yyyyMMdd")..".log");
		logger_:SetAppendMode(self.append_mode ~= false);
		logger_:SetForceFlush(self.force_flush ~= false);
	end
	return true
end

local send_msg_template = {};
-- set the message to Log proxy to be forwarded back to client
function GSL_LogServer:SendMessage(reply_nid, user_thread, msg_type, msg_data, seq)
	local address;
	if(self.my_nid ~= reply_nid) then
		address = format("(%s)%s:%s", user_thread, reply_nid, client_reply_addr);
	else
		address = format("(%s)%s", user_thread, client_reply_addr);
	end
	send_msg_template.type = msg_type;
	send_msg_template.msg = msg_data;
	send_msg_template.seq = seq;

	if( NPL.activate(address, send_msg_template) ~=0 ) then
		-- connection to server may be lost
		LOG.std(nil, "warning", "LogServer", "unable to send message to "..proxy_address);
	end
end

-- Client send us a log message
-- @param logname: log file name. if nil, it defaults to "GSL"
-- @param sender_nid: sender_nid, usually same as game_id
function GSL_LogServer:Handle_SendLog(logname, sender_nid, sender_thread, msg_data, seq)
	-- TODO: write to log file
	-- 20110725 19:50:49| msg={id=60085,action="quest_accepted_successful",nid=117314640,}|112.24.246.30
	local name = "GSL"; -- the output file log
	if(type(msg_data) == "table") then
		name = logname or name;
	end
	if(self:GetLogger(name)) then
		commonlib.servicelog(name, "%s(%s)|msg=%s", sender_nid or "", sender_thread or "", commonlib.serialize_compact(msg_data));
		-- LOG.std(nil, "system","logger", "%s(%s)|%s", sender_nid or "", sender_thread or "", commonlib.serialize_compact(msg_data));
	end
end

-- we received a message from the Log server. 
function GSL_LogServer:OnReceiveMessage(msg)
	if(not msg) then return end
	local msg_type = msg.type;
	if(msg_type == "init") then
		self:init(msg);
	end

	local msg_data = msg.msg;
	local sender_nid = msg.nid;
	local game_id = msg.game_id;
	
	if(not sender_nid) then
		if(game_id and msg.tid) then
			LOG.std(nil, "system", "logserver", "connection %s is accepted as %s", msg.tid, game_id);
			NPL.accept(msg.tid, msg.game_id);
			sender_nid = game_id;
		else
			sender_nid = msg.tid or self.my_nid;
		end
	end

	
	if(msg_type == "log") then
		-- heart beat message. 
		if(msg_data) then
			self:Handle_SendLog(msg.logname, sender_nid, msg.thread, msg_data, msg.seq)
		end
	end
end

local function activate()
	local self = GSL_LogServer.GetSingleton();
	self:OnReceiveMessage(msg)
end
NPL.this(activate);