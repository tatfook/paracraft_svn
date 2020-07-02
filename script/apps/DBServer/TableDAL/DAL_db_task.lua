--[[
Title: handle update insert query
Author: LiXizhi
Date: 2013/2/20
Desc: 
-----------------------------------------------
NPL.load("(gl)script/apps/DBServer/TableDAL/DAL_db_task.lua");
local DAL_db_task = commonlib.gettable("DBServer.TableDAL.DAL_db_task");
DAL_db_task:new();
-----------------------------------------------
]]
NPL.load("(gl)script/ide/mysql/mysql.lua");
local luasql = commonlib.luasql;

NPL.load("(gl)script/apps/DBServer/TableDAL/AsyncTask.lua");
local AsyncTask = commonlib.gettable("DBServer.TableDAL.AsyncTask");


local DAL_db_task = commonlib.inherit(AsyncTask, commonlib.gettable("DBServer.TableDAL.DAL_db_task"));

function DAL_db_task:ctor()
	
end

function DAL_db_task:Run(msg)
	-- TODO: do any query

end
