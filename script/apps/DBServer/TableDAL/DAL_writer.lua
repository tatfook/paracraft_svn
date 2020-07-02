--[[
Title: handle update insert query
Author: LiXizhi
Date: 2013/2/20
Desc: 
-----------------------------------------------
NPL.load("(gl)script/apps/DBServer/TableDAL/DAL_writer.lua");
local DAL_writer = commonlib.gettable("DBServer.TableDAL.DAL_writer");
-----------------------------------------------
]]

local DAL_writer = commonlib.gettable("DBServer.TableDAL.DAL_writer");

-- start a read query
-- @param key:
-- @param params: 
-- @param callbackFunc:  a callback function(msg) end.  
function DAL_writer.Update(key, params, callbackFunc)
end

function DAL_writer.Insert(key, params, callbackFunc)
end