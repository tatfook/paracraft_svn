--[[
Title: GSL server and client.
Author(s): LiXizhi
Date: 2011/6/23
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/GameServer/GSL_version.lua");
------------------------------------------------------------
]]

local GSL_version = commonlib.gettable("Map3DSystem.GSL.GSL_version");

-- increase by 1 each time anything changes on the server side. 
GSL_version.ver = 26;