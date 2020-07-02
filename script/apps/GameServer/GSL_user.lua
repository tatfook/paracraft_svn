--[[
Title:  GSL user
Author(s): LiXizhi
Date: 2013/4/15 
Desc: GSL_user is used by GSL_gateway. Each connection (nid) is a user object. the user object is responsible for per connection data keeping of a given user. 
The most important function is rate limiting for certain kind of messages like (normal updates, real time update, IM messages. )
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/GameServer/GSL_user.lua");
local user_class = commonlib.gettable("Map3DSystem.GSL.user_class");
local user = user_class:new({nid=nid});
if(user:RateLimitCheck()) then
	-- go on
end
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/STL.lua");
NPL.load("(gl)script/apps/GameServer/GSL.lua");
NPL.load("(gl)script/apps/GameServer/GSL_msg_def.lua");
NPL.load("(gl)script/apps/GameServer/GSL_history.lua");
NPL.load("(gl)script/apps/GameServer/GSL_gridnode.lua");
NPL.load("(gl)script/apps/GameServer/GSL_gridnode_manager.lua");
NPL.load("(gl)script/ide/Network/StreamRateController.lua");
local StreamRateController = commonlib.gettable("commonlib.Network.StreamRateController");

local user_class = commonlib.inherit(nil, commonlib.gettable("Map3DSystem.GSL.user_class"));

-- @param nid; this is set when client first login.
-- @param gridnode: the primary grid node that this user belongs to. 
function user_class:ctor()
	self.start_time = nil;
	self.rate_controller = StreamRateController:new({name=format("GSL_%s", tostring(self.nid) or ""), 
		-- only history for 3 seconds
		history_length = 3, 
		-- 3 additional messages/second
		max_msg_rate=3,
	})
end

-- add a message to the data size. 
-- @param nSize: data size of the message. default to 1. 
-- @return res, reason: res is true if message can be processed immediately. otherwise it is false. and the second parameter contains the error message.  
--	reason is "pending"(NOT implemented yet) if message can not be processed now but in a pending queue 
--  reason is "full", if message is not allowed to be processed. 
function user_class:RateLimitCheck(nSize)
	return self.rate_controller:AddMessage(nSize);
end
