--[[
Author: spring
Date: 2011-7-5
Desc: test for payserver from http response
-----------------------------------------------
NPL.load("(gl)script/apps/WebServer/test/testpay.lua");
-----------------------------------------------
]]
NPL.load("(gl)script/apps/PayServer/PayServer.lua");
local function activate()
	local msg=msg;
	local seq_id = msg.seq; 	
	LOG.std(nil, "system", "WebServer", "recv msg from PayServer: %s", commonlib.serialize_compact(msg));

	PayServer.requests_pool[seq_id].result=msg;
	PayServer.requests_pool[seq_id].has_result=true;
end
NPL.this(activate)