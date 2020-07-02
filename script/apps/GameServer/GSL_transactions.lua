--[[
Title: a per user transaction on game server
Author(s): LiXizhi
Date: 2011/2/28
Desc: This is software emulated transactions, internally it will push all transactions to a queue and execute them one by one. 
The primiary goal of transaction is to garuantee that there is no nested transactions and they are always executed in sequence.
In many game server logic unit, the client may invoke a command on the server, server will then initiate an transaction to process the request. 
Note1: if the transaction itself is asynchronous, then we need to ensure that it must end with a specified time. 
We do not use a timeout timer, instead we will check the last unfinished transaction for timeout whenever a new transaction is pushed to the per user transaction queue.
Note2: if used with gsl_gateway, there is no need to manage(create/delete) per user transaction queue.When user logs out, its nid queue will be cleared automatically. 
-----------------------------------------------
NPL.load("(gl)script/apps/GameServer/GSL_transaction.lua");
local GSL_transaction = commonlib.gettable("Map3DSystem.GSL.GSL_transaction");
GSL_transaction:enable_log(true);
local nid = "123";
GSL_transaction:create_queue(nid);

GSL_transaction:begin_trans(nid, "some_name_for_logging", nil, function()
	-- do your logics here

	-- if logics is asynchrounous, end_trans() should be called in the callback.
	GSL_transaction:end_trans(nid, "some_name_for_logging")
end)
-- More info please see test_GSL_transaction.lua
-----------------------------------------------
]]
local tostring = tostring;
local gateway = commonlib.gettable("Map3DSystem.GSL.gateway");
local TimerManager = commonlib.gettable("commonlib.TimerManager");
local GSL_transaction = commonlib.gettable("Map3DSystem.GSL.GSL_transaction");
-- true to enable log
local enable_log = false;
-- max concurrent transactions in the queue
local max_concurrent_trans = 200;

-- 3 seconds is the max timeout
local default_timeout = 3000;

-- get the transaction queue associated with the given user. 
-- currently transaction queue is only created for users in the GSL_gateway. 
function GSL_transaction:get_queue(nid)
	nid = tostring(nid);
	local user = gateway:FindUser(nid);
	if(user) then
		if(not user.trans_queue) then
			user.trans_queue = commonlib.List:new();
			user.trans_queue.nid = nid;
		end
		return user.trans_queue;
	end
end

-- call this function to create a queue of a given nid. 
function GSL_transaction:create_queue(nid)
	nid = tostring(nid);
	local user = gateway:GetUser(nid);
	if(user)then
		return self:get_queue(nid);
	end
end

-- whether to enable log.
function GSL_transaction:enable_log(bEnabled)
	enable_log = bEnabled;
end

-- set max concurrent transactions per queue.
function GSL_transaction:set_max_concurrent_trans(nCount)
	max_concurrent_trans = nCount;
end

-- begin a transaction by pushing it to the queue.
-- nested begin_trans/end_trans pairs will always be executed in sequence. 
-- The primiary goal of transaction is to garuantee that there is no nested transactions and they are always executed in sequence.
-- @param nid: the nid of the queue
-- @param trans_name: this parameter is used for log tracking only. pass in any string or nil. 
-- @param timeout: in milliseconds. if nil, it is the default_timeout(which is 5000)
-- @param trans_func: the transaction function to call when it is ready to call. If this is nil, we will try to start the next unstarted transaction. 
-- @return true if successfully pushed to the queue. 
function GSL_transaction:begin_trans(nid, trans_name, timeout, trans_func, ...)
	nid = tostring(nid);
	local queue = self:get_queue(nid);
	if(not queue) then
		LOG.std(nil, "warn", "GSL_trans", "no transaction queue found for (nid %s)", tostring(nid));
		return
	end
	local cur_time = TimerManager.GetCurrentTime();

	local trans;

	if(trans_func) then
		-- Tricky: fixed for varargs syntax in lua5.1 and luajit2. There can be nils in the varargs, we will keep the argument count in args.n. 
		local args;
		local args_count = select('#', ...);
		if(args_count > 0) then
			args = {...};
			args.n = args_count;
		end

		trans = {
			timeout = timeout or default_timeout,
			start_time = nil,
			name = trans_name,
			func = trans_func,
			args = args,
		};
	end
	
	-- push transaction to queue. 
	if(max_concurrent_trans <= queue:size()) then
		trans = queue:first();
		LOG.std(nil, "warn", "GSL_trans", "max transaction %s reached for nid %s, the front transaction of %s will be canceled.", max_concurrent_trans, tostring(nid), trans.name or "");
		-- remove the front transaction, since it may be stalling the queue. 
		self:remove_trans(queue,trans);
	end
	queue:addtail(trans);
	

	-- now find the first unfinished node. 
	trans = queue:first();
	if (trans) then
		if(not trans.start_time) then
			-- this is an unstarted trans, let us begin it. 
		elseif( (trans.start_time + trans.timeout) <  cur_time) then
			-- warn: trans is timed out, remove it
			trans = self:remove_trans(queue,trans)
		else
			-- we have to wait for the previous transaction to finish before starting a new one. 
			trans = nil;
		end
	end

	-- start the transaction
	self:start_trans(queue, trans, cur_time);
end

-- start a given transaction. 
-- @param queue: the queue object.  
function GSL_transaction:start_trans(queue, trans, cur_time)
	cur_time = cur_time or TimerManager.GetCurrentTime();
	if(trans and not trans.start_time) then
		-- start the trans immediately. 
		trans.start_time = cur_time;
		if(trans.func) then
			--queue.nested_count = (queue.nested_count or 0) + 1;
			if(enable_log) then
				LOG.std(nil, "debug", "GSL_trans", "begin transaction (nid %s):%s ", tostring(queue.nid), trans.name or "");
			end
			if(trans.args) then
				trans.func(unpack(trans.args, 1, trans.args.n))
			else
				trans.func();
			end
		end
	end
end

-- remove a transaction from the queue. 
function GSL_transaction:remove_trans(queue,trans)
	--if(trans.start_time and queue.nested_count and queue.nested_count>0) then
		--queue.nested_count = queue.nested_count - 1;
	--end
	trans = queue:remove(trans);
	return trans;
end


-- stop the current transaction. 
-- @param nid: the nid of the queue
-- @param trans_name: this parameter is used for log tracking only. pass in any string or nil. 
function GSL_transaction:end_trans(nid, trans_name)
	nid = tostring(nid);
	local queue = self:get_queue(nid);
	if(not queue) then
		LOG.std(nil, "warn", "GSL_trans", "no transaction to end(nid %s). No transaction queue is found", tostring(nid));
		return
	end
	
	-- now start the next transaction in the queue
	local trans = queue:first();
	if (trans) then
		if(trans.start_time) then
			if(enable_log) then
				LOG.std(nil, "debug", "GSL_trans", "end transaction (nid %s):%s", tostring(nid), trans.name or "");
			end
			-- this is an trans, let us end it. 
			trans = self:remove_trans(queue,trans);
			if(trans) then
				self:start_trans(queue, trans);
			end
		else
			trans = nil;
			LOG.std(nil, "warn", "GSL_trans", "we are ending a transaction (nid %s):%s that is not started", tostring(nid), trans.name or "");
		end
	end
end

