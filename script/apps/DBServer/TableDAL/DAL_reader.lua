--[[
Title: handle update insert query
Author: LiXizhi
Date: 2013/2/20
Desc: 
-----------------------------------------------
NPL.load("(gl)script/apps/DBServer/TableDAL/DAL_reader.lua");
local DAL_reader = commonlib.gettable("DBServer.TableDAL.DAL_reader");
-----------------------------------------------
]]
NPL.load("(gl)script/apps/DBServer/TableDAL/DAL_mem_table.lua");
NPL.load("(gl)script/apps/DBServer/TableDAL/DAL_db_task.lua");
local DAL_mem_table = commonlib.gettable("DBServer.TableDAL.DAL_mem_table");
local DAL_db_task = commonlib.gettable("DBServer.TableDAL.DAL_db_task");

local DAL_reader = commonlib.gettable("DBServer.TableDAL.DAL_reader");

-- start a read query
-- @param key:
-- @param params: 
-- @param callbackFunc:  a callback function(msg) end.  
function DAL_reader.Select(key, params, callbackFunc)
	if(DAL_mem_table.HasKey(key)) then
		-- TODO: read from local memory table
	else
		-- TODO: start a db task
		local task = DAL_db_task:new({callbackFunc = function(msg)
			local out_msg = msg;
			---  TODO:
			if(callbackFunc) then
				callbackFunc(out_msg);
			end
		end})
		task:Run();
	end
end

function DAL_reader.Insert(key, params, callbackFunc)
end