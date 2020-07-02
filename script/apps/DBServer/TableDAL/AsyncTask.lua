--[[
Title: An async task with callback
Author: LiXizhi
Date: 2013/2/20
Desc: 
-----------------------------------------------
NPL.load("(gl)script/apps/DBServer/TableDAL/AsyncTask.lua");
local AsyncTask = commonlib.gettable("DBServer.TableDAL.AsyncTask");
local task = AsyncTask:new({time_out=3000, callbackFunc=function(msg)   end })
task:Run();
-----------------------------------------------
]]
NPL.load("(gl)script/apps/DBServer/TableDAL/DAL_db_task.lua");
local DAL_db_task = commonlib.gettable("DBServer.TableDAL.DAL_db_task");

local AsyncTask = commonlib.inherit(nil, commonlib.gettable("DBServer.TableDAL.AsyncTask"));

local filename = "(db)script/apps/DBServer/TableDAL/AsyncTask.lua";
local filename_format = "(%s)script/apps/DBServer/TableDAL/AsyncTask.lua";
local g_rts = __rts__:GetName();

--default time out time
AsyncTask.time_out = 2000;

local seq = 1;

local request_pool = {};

local function GetNextSeq()
	seq = seq + 1;
	return seq;
end

function AsyncTask:ctor()
	self.is_finished = 0;
end

function AsyncTask:Run()
	local seq = GetNextSeq();

	-- add to request pool
	request_pool[seq] = self;
	
	-- send request to one of the db threads. 
	NPL.activate(filename, {
			type = "request", 
			seq = seq,
			msg = self.msg,
			-- runtime state name
			rts = g_rts, 
		})

end

function AsyncTask:InvokeCallback(msg)
	if(self.callbackFunc) then
		self.callbackFunc(msg)
	end
end

local function activate()
	local msg = msg;
	
	if(msg.type == "request") then
		-- request from main thread
		local task = DAL_db_task:new(msg.msg);
		local result = task:Run();

		-- send response to game thread. 
		NPL.activate(format(filename_format, msg.rts or "main"), {
			type = "response", 
			seq = msg.seq,
			msg = result,
		})
	else
		-- response from db processor thread
		local task = request_pool[msg.seq];
		if(task) then
			request_pool[msg.seq] = nil;
			task:InvokeCallback(msg.msg);
		end
	end
end

NPL.this(activate)