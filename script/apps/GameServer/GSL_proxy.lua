--[[
Title: forward everything it receives to another destination (dest can be nested tables) 
Author(s): LiXizhi
Date: 2009/10/6
Desc: GSL_proxy: forward everything it receives to another destination (dest can be nested tables) 
{ 
	dest={addr="", dest={addr="", dest={...},}}, file="", msg={...}
}
A GSL_proxy message contain 3 fields namely {dest, file, msg}, where the dest field is optional.
Whenever the GSL_proxy receives a message, it first checks if its dest field has an inner dest field. if it has inner dest field, it will unbox one level of the dest field, 
and forward the message(with the same file and msg fields) to the next GSL_proxy by nid. If it does not contains the inner dest field, 
it will deliver the message(==msg==) to the ==file== directly.

Note: GSL_proxy will establish connection on demand. it will use 10 seconds timeout. if it has timed out before, the proxy will remember it and will not use time out the second time. 
Note: proxy will by default accept any request from anonymous connections. TODO: Find a safer way, since GSL_proxy is only public on Intranet, we shall tolerate this. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/GameServer/GSL_proxy.lua");
Map3DSystem.GSL.GSL_proxy:Init();
Map3DSystem.GSL.GSL_proxy:SendMessage({addr="(w1)gateway1", dest="client_nid"}, "script/apps/GameServer/GSL_client.lua", {the_message_body_here})
Map3DSystem.GSL.GSL_proxy:SendMessage({addr="(h1)home1"}, "script/apps/GameServer/GSL_homegrid.lua", {the_message_body_here})
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/GameServer/GSL_stringmap.lua");
local GSL = commonlib.gettable("Map3DSystem.GSL");
local GSL_msg = commonlib.gettable("Map3DSystem.GSL.GSL_msg");
local GSL_proxy = commonlib.gettable("Map3DSystem.GSL.GSL_proxy");
local format = format;
local type = type;
-- this file
local proxy_file = "script/apps/GameServer/GSL_proxy.lua";

local proxy_timeout_default = 10;
local proxy_timeouts = {};
local local_address = {};

-- proxy files are encoded using stringmap. 
local proxy_files = nil;

function GSL_proxy:Init(my_nid)
	self.my_nid = my_nid;
	self.thread_name = "("..__rts__:GetName()..")";
	proxy_files = Map3DSystem.GSL.stringmap.proxy_files;
end

-- send a message to destination via this proxy object
-- @param dest: a table of {addr="", dest={addr="", dest={...},}}, where dest can be a nested table. 
--    example: {addr="(w1)gateway1", dest="client_nid"}. if this is nil, the local file will be activated. 
-- @param file: the file to be activated on the remote computer. If the file is remote, it needs to be listed in the public NPL file list. 
-- @param msg: the message to be sent. Please note that msg.nid and msg.tid may be overwritten during message transportation. 
function GSL_proxy:SendMessage(dest, file, msg)
	if(GSL.dump_server_msg) then
		LOG.std(nil, "trace", "GSL_proxy SendMessage", {dest, file, msg});
	end
	
	if(not file) then
		return
	end
	
	if(type(dest) == "table" and type(dest.addr)=="string") then
		
		local addr = dest.addr;
		local dest_timeout = proxy_timeouts[addr];

		local dest_thread, dest_nid = addr:match("^(%([^%)]*%))(.*)$");
		local is_local;
		if(dest_nid and dest_nid == self.my_nid) then
			is_local = true;
			-- remove nid from local message.
			if(self.thread_name == dest_thread) then
				addr = "";
			else
				addr = dest_thread;
			end
			--LOG.std(nil, "debug", "GSL_proxy", { "111111111111111", addr, dest})
		end

		if(type(dest.dest) == "table") then
			-- dest has inner destination, forward to the next proxy
			local res;
			if(not is_local) then
				res = NPL.activate_async_with_timeout(dest_timeout or proxy_timeout_default, format("%s:%s", addr, proxy_file), {dest=dest.dest, file=proxy_files:ConvertToID(file) or file, msg=msg});
			else
				res = NPL.activate(format("%s%s", addr, proxy_file), {dest=dest.dest, file=proxy_files:ConvertToID(file) or file, msg=msg});
			end
			if(res ~= 0) then
				-- this prevent us to use timeout if it has timed out before. 
				proxy_timeouts[addr] = 0;
				LOG.std(nil, "warn", "GSL_proxy", "GSL_proxy can not route message to address %s, perhaps connection not valid.", addr)
			elseif(dest_timeout) then
				proxy_timeouts[addr] = nil;
			end
		else
			-- dest has no inner destination, forward to the file directly
			file = proxy_files:ConvertToString(file);
			if(file) then
				local res;
				if(not is_local) then
					res = NPL.activate_async_with_timeout(dest_timeout or proxy_timeout_default, format("%s:%s", addr, file), msg);
				else
					res = NPL.activate(format("%s%s", addr, file), msg);
				end
				if(res ~= 0) then
					-- this prevent us to use timeout if it has timed out before. 
					proxy_timeouts[addr] = 0;
					LOG.std(nil, "warn", "GSL_proxy", "GSL_proxy can not route message to address %s, perhaps connection not valid.", addr)
				elseif(dest_timeout) then
					proxy_timeouts[addr] = nil;
				end
			else
				LOG.std(nil, "warn", "GSL_proxy", "GSL_proxy can not route message to address %s, because the dest file is unknown.", addr)
			end	
		end
	else
		-- no destination, but has file, it is a local message. just activate the file
		NPL.activate(file, msg);
	end
end

local function activate()
	if(GSL.dump_server_msg) then
		LOG.std(nil, "trace", "GSL_proxy trace", msg);
	end

	if(msg.dest) then
		GSL_proxy:SendMessage(msg.dest, msg.file, msg.msg);
	else
		LOG.std(nil, "warn", "GSL_proxy", "proxy get a message without destination");
	end
end
NPL.this(activate);