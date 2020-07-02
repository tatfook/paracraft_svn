--[[
Author: LiXizhi
Date: 2009-7-22
Desc: Edit this file to expose new REST API for the game server
config/WebAPI.config.xml will merge settings with this file. 
-----------------------------------------------
NPL.load("(gl)script/apps/GameServer/rest_API.lua");
-----------------------------------------------
]]
local rest = commonlib.gettable("GameServer.rest");
NPL.load("(gl)script/ide/timer.lua");
NPL.load("(gl)script/apps/GameServer/GSL_version.lua");

local GSL_ver = Map3DSystem.GSL.GSL_version.ver;
-- To modify version number, do it here
local ping_reply_msg_templ = {data_table={data=format([[{"ver":%d}]],GSL_ver)}, }
local auth_wrong_ver_reply_msg_templ = {data_table={data=format([[{"ver":%d,"errorcode":474}]],GSL_ver)}}

-- a list of API. If an API allows anonymous access, specify  allow_anonymous = true
-- To handle API using a custom function, provide handler_func like in the "AuthUser". 
rest.API = {
["AuthUser"] = {
	allow_anonymous = true,
	handler_func = function(msg)
		if( msg.req.ver == GSL_ver) then
			-- secretely inject the connection id to request field. 
			msg.req.nid = msg.nid or msg.tid;
			-- secretely inject IP address
			msg.req.ip = NPL.GetIP(msg.req.nid);
		
			-- specify nil as user_nid, so it is sent to a random db for authentication
			rest:SendRequest(msg.url, msg.req, msg.seq, nil);
		else
			-- send back error code, because version does not match
			rest:send_json_response(msg, auth_wrong_ver_reply_msg_templ);
		end
		
		-- if req.username is a number string, we will use it as user_nid, so that login messages will be dispatched to different db servers 
		--if(string.match(msg.req.username, "^%d+$")) then
			--rest:SendRequest(msg.url, msg.req, msg.seq, msg.req.username);
		--else
			--rest:SendRequest(msg.url, msg.req, msg.seq, msg.nid);
		--end
	end
},
["Ping"] = {
	allow_anonymous = true,
	handler_func = function(msg)
		-- return IP address
		ping_reply_msg_templ.data_table.data=format([[{"ver":%d,"srvtime":"%s"}]],GSL_ver, ParaGlobal.GetTimeFormat("HH:mm:ss"));
		rest:send_json_response(msg, ping_reply_msg_templ);
	end
},
["Users.Registration"] = {
	allow_anonymous = true,
	handler_func = function(msg)
		-- secretely inject the connection id to request field. 
		msg.req.nid = msg.nid or msg.tid;
		-- secretely inject IP address
		msg.req.ip = NPL.GetIP(msg.req.nid);
		rest:SendRequest(msg.url, msg.req, msg.seq, msg.nid);
	end
},
["Posts.Add"] = {
	handler_func = function(msg)
		-- secretely inject the connection id to request field. 
		msg.req.nid = msg.nid or msg.tid;
		-- secretely inject IP address
		msg.req.ip = NPL.GetIP(msg.req.nid);
		rest:SendRequest(msg.url, msg.req, msg.seq, msg.nid);
	end
},

["RequireLogin"] = {},

-- toggle profiler, only used for debugging purposes, 
-- Note: may remove this in release build. 
["ToggleProfiler"] = {
	allow_anonymous = true,
	handler_func = function(msg)
		local ip = NPL.GetIP(msg.nid or msg.tid);
		local npl_state_name = "gl";
		if(msg.req and msg.req.npl_state_name) then
			npl_state_name = msg.req.npl_state_name;
		end
		-- only reply when ip is local or intranet addresses. 
		if(ip:match("^127%.0") or ip:match("^192%.168%.")) then -- or ip:match("^10%.")
			-- toggle profiling in the given npl runtime state. 
			NPL.activate("("..npl_state_name..")script/ide/profiler.lua");
		else
			LOG.std(nil, "warning", "rest", "IP %s is not allowed for ToggleProfiler", ip)
		end
	end
},

-- magic card consume
["MagicCard.Consume"] = {
	handler_func = function(msg)
		-- secretely inject the connection id to request field. 
		msg.req.nid = msg.nid or msg.tid;
		-- secretely inject IP address
		msg.req.ip = NPL.GetIP(msg.req.nid);
		rest:SendRequest(msg.url, msg.req, msg.seq, msg.nid);
	end
},

};
