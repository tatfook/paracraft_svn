--[[
Title: handle update insert query
Author: LiXizhi
Date: 2013/2/20
Desc: 
-----------------------------------------------
NPL.load("(gl)script/apps/DBServer/TableDAL/DAL_dirty_table.lua");
local DAL_dirty_table = commonlib.gettable("DBServer.TableDAL.DAL_dirty_table");
-----------------------------------------------
]]

local DAL_dirty_table = commonlib.gettable("DBServer.TableDAL.DAL_dirty_table");
DAL_dirty_table.todolist = {};

-- in seconds
local slow_commit_interval = 60;

-- start a read query
-- @param key:
-- @param params: 
-- @param callbackFunc:  a callback function(msg) end.  
function DAL_dirty_table.MakeDirty(key, params)
end


local last_slow_ticks = 1;

-- called every 1 to flush dirty data to database.
function DAL_dirty_table.OnFrameMove(timer)
	last_slow_ticks = last_slow_ticks + 1;
	if(last_slow_ticks >  slow_commit_interval) then
		last_slow_ticks = 1;

		local _todolist = DAL_dirty_table.todolist;
		DAL_dirty_table.todolist = {};
		local _sqls = {};
		local _obj;
		for _, _v in pairs(_todolist) do
			_obj = _v.obj;
			if(_v.item.state == 2) then
				-- _v.obj:db_delete(_v.item.data);
				_sqls[#(_sqls) + 1] = _v.obj:gensql_delete(_v.item.data);
			elseif(_v.item.isnew) then
				_v.item.isnew = nil;
				-- _v.obj:db_insert(_v.item.data);
				_sqls[#(_sqls) + 1] = _v.obj:gensql_insert(_v.item.data);
			else
				-- _v.obj:db_update(_v.item.data);
				_sqls[#(_sqls) + 1] = _v.obj:gensql_update(_v.item.data);
			end
		end
		if(#(_sqls) > 0) then
			_obj:db_execMulSql(_sqls);
		end
	end
end



function DAL_dirty_table.put(pObj, pItem)
	local _data = pItem.data;
	local _key = pObj:getTableName(_data) .. "_" .. pObj:getPrimaryKeyIndex(_data);
	--if(not DAL_dirty_table.todolist[_key]) then
		DAL_dirty_table.todolist[_key] = {obj = pObj, item = pItem};
	--end
end