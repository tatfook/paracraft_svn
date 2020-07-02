--[[
Author: LiXizhi
Date: 2009-7-30
Desc: accept any connection as msg.user_nid
-----------------------------------------------
NPL.load("(gl)script/apps/GameServer/test/accept_any.lua");
-----------------------------------------------
]]

-- accept any connection.
local function activate()
	if(not msg.nid) then
		-- NOTE: Should return, 
		local nid = msg.user_nid or "1234567";
		commonlib.applog("warning: anonymous connection %s is accepted as %s for debugging locally. Remove this in release build\n ", msg.tid, nid);
		NPL.accept(msg.tid, nid);
		
		if (type(msg.callback) == "string") then
			NPL.DoString(msg.callback);
		end
	end
end
NPL.this(activate);
