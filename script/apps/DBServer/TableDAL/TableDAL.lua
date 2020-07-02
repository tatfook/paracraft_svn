--[[
Title: Main Entry class
Author: LiXizhi
Date: 2013/2/20
Desc: 
-----------------------------------------------
NPL.load("(gl)script/apps/DBServer/TableDAL/TableDAL.lua");
local TableDAL = commonlib.gettable("DBServer.TableDAL");
TableDAL.Init();
-----------------------------------------------
]]
NPL.load("(gl)script/apps/DBServer/TableDAL/DAL_reader.lua");
NPL.load("(gl)script/apps/DBServer/TableDAL/DAL_router.lua");
NPL.load("(gl)script/apps/DBServer/TableDAL/DAL_dirty_table.lua");
local DAL_dirty_table = commonlib.gettable("DBServer.TableDAL.DAL_dirty_table");
local DAL_reader = commonlib.gettable("DBServer.TableDAL.DAL_reader");
local DAL_router = commonlib.gettable("DBServer.TableDAL.DAL_router");

local TableDAL = commonlib.gettable("DBServer.TableDAL");

TableDAL.main_loop_timer_interval = 1000;

-- call this only once
function TableDAL.Init(params)
	if(TableDAL.is_inited) then
		return
	end
	TableDAL.is_inited = true;
	TableDAL.mytimer = TableDAL.mytimer or commonlib.Timer:new({callbackFunc = function(timer)
		TableDAL.OnFrameMove(timer);
	end})

	TableDAL.mytimer:Change(TableDAL.main_loop_timer_interval, TableDAL.main_loop_timer_interval);
end

-- start a read query
-- @param key:
-- @param params: 
-- @param callbackFunc:  a callback function(msg) end.  
--function TableDAL.Select(nid, key, params, callbackFunc)
	--if(DAL_router.IsLocalData(nid)) then
		---- TODO: DAL_reader.Select;
	--else
		---- TODO: need to ask other machine
		--DAL_router.SendRequest(nid, key, params, callbackFunc);
	--end
--end

-- coroutine version DAL_router.select()
-- @param co: the coroutine object. 
-- @return msg;
function TableDAL.select(pTbKey, pCommand, co)
	local has_data;
	local msg;
	DAL_router.select(pTbKey, pCommand, function(returned_msg)
		has_data = true;
		if(co) then
			coroutine.resume(co, returned_msg);
		else
			msg = returned_msg;
		end
	end);
	if(has_data) then
		co = nil;
	else
		msg = coroutine.yield();
	end
	return msg;
end

function TableDAL.IsLocalData(nid)
	-- TODO:
	return true;
end


function TableDAL.Update(key, params, callbackFunc)
end

function TableDAL.Insert(key, params, callbackFunc)
end

-- main loop timer 
function TableDAL.OnFrameMove()
	DAL_dirty_table.OnFrameMove();
	DAL_router.OnFrameMove();
end