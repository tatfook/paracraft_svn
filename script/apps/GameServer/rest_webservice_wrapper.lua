--[[
Author: LiXizhi
Date: 2009-7-22
Revision: 
 2009.9.2: change by Andy: originalMsg added to postFunc params.
 2009.9.25: LiXizhi refactored. time out is supported. 
Desc: a wrapper class to emulate HTTP REST interface on the client side but using the game server interface
-----------------------------------------------
NPL.load("(gl)script/apps/GameServer/rest_webservice_wrapper.lua");
-- create REST once and for all. It will time out 20000 milliseconds by default.
GameServer.rest.client.CreateRESTJsonWrapper("test.auth.AuthUser", "AuthUser")

-- create RPC wrapper that will by default timeout after 1 second. 
GameServer.rest.client.CreateRESTJsonWrapper("test.auth.AuthUser", "AuthUser",nil,nil,nil,nil, 1000, function(msg, callbackParams)
	commonlib.echo("RPC is timed out")
end)

-- invoke API. the second parameter is rpc instance name. There can be one ongoing activation per instance. repeated calls will be ignored. 
test.auth.AuthUser({username="LiXizhi1", password="1234567"}, "test", function(msg)  
	commonlib.echo(msg)
end)

-- Call RPC with time out that overwrite default settings. 
test.auth.AuthUser({username="LiXizhi1", password="1234567"}, "test", function(msg, callbackParams)  
	commonlib.echo({msg=msg, callbackParams})
end, {data="this is some additional callback params"}, 1000, function(inputMsg, callbackParams)
	commonlib.echo({time_out_callback = inputMsg, callbackParams})
end)
-----------------------------------------------
]]
NPL.load("(gl)script/ide/timer.lua");
local client = commonlib.gettable("GameServer.rest.client")
local rest_local = commonlib.gettable("GameServer.rest_local");
local gateway = commonlib.gettable("Map3DSystem.GSL.gateway");
local LOG = LOG;
local type = type;
local string_gsub = string.gsub;

----------------------------------------------
-- web service wrapper functions 
----------------------------------------------

-- various error code of this rest_client. This is a subset of paraworld.errorcode;
local errorcode = {
	-- An unknown error occurred. Please try again later
	unknown = nil, 
	-- The service is not available at this time. 
	ServiceNotAvailable = 1,
	-- The application has reached the maximum number of requests allowed. More requests are allowed once the time window has completed. 
	MaxAppRequestsReached = 2,
	-- returned when calling the same RPC twice with the same id, if the previous one does not response. 
	RepeatCall = 3,	
};

--[[
Create an rpc wrapper function using closures. it will override existing one with identical name. 
@param fullName: by which name we name the RPC, it should contains at least one namespace. such as "paraworld.auth.AuthUser"
@param url: url of the RPC path, such as "AuthUser".
@param prepFunc: nil or an input message validation function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator) end 
 the function is called before making the RPC call to validate the input msg and preconditions. e.g. If user is not logged in, it will open a login window for user authentication. 
 the function should return nil if should continue with web service call, otherwise either true or a paraworld.errorcode is returned. If there is an error in preprocessing, the user callback is not called. and the error code is returned immediately from the rpc wrapper function. 
 One can create custom preprocessorFunc for each RPC wrapper, or use one of the predefined processor. 
 Another usage of prepFunc is that it can secretly translate input message to whatever the remote format message is. 
@param postFunc: nil or an output message validation function (self, msg, id) end 
 the function is called after the RPC returns to validate the output msg and then send the result to the user callback. e.g. It may report and handle certain common error, such as sesssion key expirations, etc. 
 the function should return nil if successful, otherwise a paraworld.errorcode is returned.  whether there is error or not the user callback is always called. 
@param preMsgTranslator: preprocessing msg input when activate is called. 
@param postMsgTranslator: postprocessing msg output when callback is called. 
@Note by LiXizhi: all resource of the rpc is kept in a closure and there is only one global table "fullname" created.  I overwrite the table's __call method to make it callable with ease. 
 -- For example: after calling 
	 paraworld.CreateRPCWrapper("paraworld.auth.AuthUser", "http://auth.paraengine.com/AuthUser.asmx");
 -- we can call the rpc via wrapper paraworld.auth.AuthUser like this
     paraworld.auth.AuthUser({username="", Password=""}, "test", function (msg, params)  log(commonlib.serialize(msg)) end, "ABC");
 -- The above call is identical to 
     paraworld.auth.AuthUser:activate(...);
 -- The url of the web service can be get/set via 
     local url = paraworld.auth.AuthUser.GetUrl() 
     paraworld.auth.AuthUser.SetUrl("anything here")
 -- tostring() can also be used like this
	 log(tostring(paraworld.auth.AuthUser).."\n")
@param default_timeout: the default timeout in milliseconds for all activations. if 0 or negative, timeout will be ignored. if nil, 20000 is used. 
	note: A user provided value may overwrite this during each activation
@param default_timeout_callback: the default time out callback function(inputMsg, callbackParams) end. it is called whenever request is timed out. inputMsg is the input request msg. 
	note: A user provided value may overwrite this during each activation
@param 	max_queue_size: max number of items in a request queue. default to 100
@example code: see "script/kids/3DMapSystemApp/API/test/paraworld.auth.test.lua"
]]
function client.CreateRPCWrapper(fullname, url_, prepFunc, postFunc, preMsgTranslator, postMsgTranslator, default_timeout, default_timeout_callback, max_queue_size)
	default_timeout = default_timeout or 20000
	local url = url_;
	local activateCount;
	local next_id = 0;
	-- max number of items in a pool
	max_queue_size = max_queue_size or 100;
	
	-- closures: fullname, url, namespace, rpcName
	local namespace = string_gsub(fullname, "%.%w+$", "");
	local _,_, rpcName = string.find(fullname, "%.(%w+)$");
	-- a table of callback pool of {id, callback} pairs
	local pool = {};
	local activate_next; -- predefine function

	local o = commonlib.getfield(fullname);
	if(o ~= nil) then 
		-- return if we already created it before.
		LOG.std(nil, "warn", "REST", "RPC %s is overriden by GameServer.rest.client.CreateRPCWrapper. Remove duplicate calls with the same name.", fullname);
	end
	
	-- return the callback {callback_func, callbackParams}. Otherwise return nil. 
	local function GetCallback(id)
		local callback = pool[id or "nil"];
		if(callback ~= nil and not (callback.IsRemoved)) then
			return callback;
		end
	end

	-- get the next free callback id to use
	local function GetNextID()
		next_id = next_id + 1;
		return next_id
	end

	-- remove a rpc call back. when an RPC returns it should call this to remove from the waiting pool so that the same function can be called again. 
	-- @param id: id is number or string or nil, the callback structure will be destroyed; 
	-- @return the next one in the queue. 
	local function RemoveCallback(id)
		--LOG.std(nil,"debug", "rest", "removed pool:"..tostring(id));
		local callback = pool[id or "nil"];
		if(callback) then
			if(callback.next_call) then
				pool[id or "nil"] = callback.next_call;
				return callback.next_call;
			else
				pool[id or "nil"] = nil;
			end
		end
	end
	
	-- add a new call back for a given RPC
	-- @param id, callbackFunc, callbackParams: are the same as defined in each RPC wrapper. 
	-- @param timeout: time out in milliseconds
	-- @param timeout_callback: in case timeout is provided, this is a callback function(inputMsg) end
	-- @return (bool, callback): it will return true if succeed. or paraworld.errorcode.RepeatCall. the second parameter is the callback object. 
	local function AddCallback(id, callback_func, callbackParams, inputMsg, originalMsg, timeout, timeout_callback)
		
		local callback = pool[id];
		local result = true; -- whether the callback should be immediately invoked(i.e. at the head of the queu)
		if(callback == nil) then
			-- create the callback entity if not exist. 
			callback = {callback_func = callback_func, callbackParams=callbackParams, inputMsg = inputMsg, originalMsg = originalMsg,
				timeout = timeout or default_timeout, timeout_callback = timeout_callback or default_timeout_callback,
			};
			pool[id] = callback;
			--LOG.std(nil,"debug", "rest", "created pool:"..tostring(id));
		else
			if(callback.IsRemoved or id=="nil") then
				callback.callback_func = callback_func;
				callback.callbackParams = callbackParams;
				callback.inputMsg = inputMsg;
				callback.originalMsg = originalMsg;
				callback.timeout = timeout or default_timeout;
				callback.timeout_callback = timeout_callback or default_timeout_callback;
				callback.IsRemoved = false;
			else
				-- append to tail
				local nCount = 0;
				while callback.next_call do
					callback = callback.next_call;
					nCount = nCount + 1;
				end
				if(nCount> max_queue_size) then
					LOG.std(nil, "warn", "REST", "pool(%s)%s is full(%d). msg dropped", id, url, max_queue_size);
					return errorcode.RepeatCall; -- note: shall we return queue_is_full code?
				end
				callback.next_call = {callback_func = callback_func, callbackParams=callbackParams, inputMsg = inputMsg, originalMsg = originalMsg,
					timeout = timeout or default_timeout, timeout_callback = timeout_callback or default_timeout_callback,
				};
				result = errorcode.RepeatCall;
				callback = callback.next_call;
			end
		end
		
		-- time out is supported via a timer object per request pool. timer is created on first use. 
		if(callback.timeout and callback.timeout>0) then
			if(not callback.timer) then
				callback.timer = commonlib.Timer:new({callbackFunc = function(timer)
					local old_callback = {
						callback_func = callback.callback_func,
						callbackParams = callback.callbackParams,
						inputMsg = callback.inputMsg,
						originalMsg = callback.originalMsg,
						timeout = callback.timeout,
						timeout_callback = callback.timeout_callback,
					}
					-- remove callback before calling time out callback, so that we can initiate another call within the callback.
					local next_request = RemoveCallback(id);
					
					LOG.std(nil, "warning", "REST", "rest request is timed out: pool(%s)%s", id, url);
					
					-- we inform the caller via the callback
					if(old_callback.timeout_callback) then
						old_callback.timeout_callback(old_callback.inputMsg, old_callback.callbackParams);
					end
					
					activate_next(id, next_request);
				end});
			end	
			if(result == true) then
				-- start the timer after callback.timeout milliseconds, and stop it immediately.
				callback.timer:Change(callback.timeout, nil)

			end
		else
			LOG.std(nil, "warn", "rest", "rest request should have a timeout specified");
		end	
		return result, callback;
	end
	
	---------------------------------------
	-- the callback function after the RPC returns. 
	-- @param bIgnoreCallback: default to nil. if true, it will ignore input msg params and the callback, and move on to next call.
	---------------------------------------
	local function callbackFunc(id, msg, bIgnoreCallback)
		local callback = GetCallback(id);
		if(callback ~= nil) then
			local next_request = RemoveCallback(id);
			callback.IsRemoved = true;

			if(not bIgnoreCallback and callback.callback_func~=nil) then
				-- make the input message the same format as the HTTP request. 
				msg.rcode = 200;
				msg.code = 0;

				local raw_msg = msg;
				if(postMsgTranslator) then
					msg = postMsgTranslator(msg, url);
				end
				if(postFunc~=nil) then
					local newMsg = postFunc(o, msg, id, callback.callback_func, callback.callbackParams, postMsgTranslator, raw_msg, callback.inputMsg, callback.originalMsg);
					if(newMsg) then
						msg = newMsg;
					end
				end
				
				callback.callback_func(msg, callback.callbackParams);
			end
			activate_next(id, next_request);
		end
	end
	
	---------------------------------------
	-- activate the next message in the pool
	---------------------------------------
	activate_next = function(id, next_request)
		if(next_request) then 
			if(next_request.timeout and next_request.timeout>0 and next_request.timer) then
				-- start the timer after callback.timeout milliseconds, and stop it immediately.
				next_request.timer:Change(next_request.timeout, nil)
			else
				LOG.std(nil, "warn", "rest", "rest request should have a timeout specified");
			end

			client:SendRequest(url, next_request.inputMsg, nil, function (msg, request)
				callbackFunc(id, msg);
			end, next_request.timer)
		end
	end

	---------------------------------------
	-- the activation function that calls the remote RPC
	-- @param msg: input message table, usually name value pairs
	-- @param id: the request pool name. only one concurrent request is allowed in a request pool, repeated calls with the same id will return go into a queue and the function returns errorcode.RepeatCall.
	--   but the request will be serviced after the previous call is finished (any pre_function is called immediately, so if there is local cache the function also returned immediately).
	--   The timeout value specified is counted when the request is sent to the server, so if there are repeated calls(as in a queue), later calls may take longer than the timeout value to finish. 
	--   the max number of request in a pool is 100 at the moment. 
	--	 if id "nil", repeated calls are ignored, and only the latest callback will be invoked once, although multiple requests will be made to the server.
	--   if id is nil, it will automatically generate a unique number id, so that errorcode.RepeatCall will never be called. This is the recommended way to activate unless one wants the repeatcall feature.
	-- @param callback_func: the callback function(msg, callbackParams) end, the callback function. msg may be empty table if request failed. 
	-- @param callbackParams: some additional parameter to be passsed to callback_func as second parameter. 
	-- @param timeout: the timeout in milliseconds of this activation. if 0 or negative timeout will be ignored. if nil, the default timeout is used. 
	-- @param timeout_callback: the time out callback function(inputMsg, callbackParams) end. it is called whenever request is timed out. inputMsg is the input request msg. 
	---------------------------------------
	local function activate(self, msg, id, callback_func, callbackParams, timeout, timeout_callback)
		if(id == nil) then
			id = GetNextID();
		end
		
		if(timeout and timeout<=0) then
			timeout = nil;
		end
		local originalMsg = commonlib.deepcopy(msg);
		if(preMsgTranslator) then
			msg = preMsgTranslator(msg);
		end
		if(not activateCount) then
			activateCount = 0;
			-- this allows use to parse url replaceables only when it is used. 
			url = client.TranslateURL(url);
		end
		activateCount = activateCount + 1;
		local res;
		
		if(type(id) == "function") then
			LOG.std(nil, "error", "REST", "error: "..url.." should be called with a string id. Have you missed it?");
		end

		local res;
		if(prepFunc~=nil) then
			res = prepFunc(self, msg, id, callback_func, callbackParams, postMsgTranslator);
		end
		if(res == nil) then
			local callback_;
			res, callback_ = AddCallback(id, callback_func, callbackParams, msg, originalMsg, timeout, timeout_callback);
			if(res==true) then
				if(callback_) then
					client:SendRequest(url, msg, nil, function (msg, request)
						callbackFunc(id, msg);
					end, callback_.timer)
				end
			elseif(res~=nil) then
				-- LOG.std(nil, "warning", "REST", "repeated rest call. result.code:%s, pool name:%s", res, id);
			end
		end
		return res;
	end
	
	-- expose RPC class via global environment.   	
	o = setmetatable({
		GetUrl = function() 
				if(not activateCount) then
					activateCount = 0;
					-- this allows use to parse url replaceables only when it is used. 
					url = client.TranslateURL(url);
				end
				return url 
			end,
		SetUrl = function(new_url) 
				activateCount = activateCount or 0;
				url = client.TranslateURL(new_url)
			end,
		activate = activate,
		callbackFunc = callbackFunc,
	}, {
		__call = activate,
		__tostring = function(self)
			return fullname..": (" ..url..")";
		end
	});
	commonlib.setfield(fullname, o);
end

local trace_uid_base = 100000;

-- this function is used to invoke RPC calls on the game server via rest_local interface. 
function rest_local.CreateRestLocalWrapper(fullname, url_, prepFunc, postFunc, preMsgTranslator, postMsgTranslator, default_timeout, default_timeout_callback, max_queue_size)
	-- the default time out is only 10 seconds, since it is intranet. 
	default_timeout = default_timeout or 10000
	local url = url_;
	local activateCount;
	local next_id = 0;
	-- max number of items in a pool
	max_queue_size = max_queue_size or 100;
	-- closures: fullname, url, namespace, rpcName
	local namespace = string_gsub(fullname, "%.%w+$", "");
	local _,_, rpcName = string.find(fullname, "%.(%w+)$");
	-- a table of callback pool of {id, callback} pairs
	local pool = {};
	local activate_next; -- predefine function

	local o = commonlib.getfield(fullname);
	if(o ~= nil) then 
		-- return if we already created it before.
		LOG.std(nil, "warning", "REST_local", "warning: RPC "..fullname.." is overriden by GameServer.rest.client.CreateRPCWrapper. Remove duplicate calls with the same name.");
	end
	
	-- return the callback {callback_func, callbackParams}. Otherwise return nil. 
	local function GetCallback(id)
		local callback = pool[id or "nil"];
		if(callback ~= nil and not (callback.IsRemoved)) then
			return callback;
		end
	end

	-- get the next free callback id to use
	local function GetNextID()
		next_id = next_id + 1;
		return next_id
	end

	-- remove a rpc call back. when an RPC returns it should call this to remove from the waiting pool so that the same function can be called again. 
	-- @note: id is number or string or nil, the callback structure will be destroyed; 
	local function RemoveCallback(id)
		--LOG.std(nil,"debug", "rest", "removed pool:"..tostring(id));
		local callback = pool[id or "nil"];
		if(callback) then
			if(callback.next_call) then
				pool[id or "nil"] = callback.next_call;
				return callback.next_call;
			else
				pool[id or "nil"] = nil;
			end
		end
	end
	
	-- add a new call back for a given RPC
	-- @param id, callbackFunc, callbackParams: are the same as defined in each RPC wrapper. 
	-- @param timeout: time out in milliseconds
	-- @param timeout_callback: in case timeout is provided, this is a callback function(inputMsg) end
	-- @return (bool, callback): it will return true if succeed. or paraworld.errorcode.RepeatCall. the second parameter is the callback object. 
	local function AddCallback(id, callback_func, callbackParams, inputMsg, originalMsg, timeout, timeout_callback)
		local callback = pool[id];
		local result = true;
		if(callback == nil) then
			-- create the callback entity if not exist. 
			callback = {callback_func = callback_func, callbackParams=callbackParams, inputMsg = inputMsg, originalMsg = originalMsg,
				timeout = timeout or default_timeout, timeout_callback = timeout_callback or default_timeout_callback,
			};
			pool[id] = callback;
			--LOG.std(nil,"debug", "rest", "created pool:"..tostring(id));
		else
			if(callback.IsRemoved or id=="nil") then
				callback.callback_func = callback_func;
				callback.callbackParams = callbackParams;
				callback.inputMsg = inputMsg;
				callback.originalMsg = originalMsg;
				callback.timeout = timeout or default_timeout;
				callback.timeout_callback = timeout_callback or default_timeout_callback;
				callback.IsRemoved = false;
			else
				-- append to tail
				local nCount = 0;
				while callback.next_call do
					callback = callback.next_call;
					nCount = nCount + 1;
				end
				if(nCount> max_queue_size) then
					LOG.std(nil, "warn", "REST_local", "pool(%s)%s is full(%d). msg dropped", id, url, max_queue_size);
					return errorcode.RepeatCall; -- note: shall we return queue_is_full code?
				end
				callback.next_call = {callback_func = callback_func, callbackParams=callbackParams, inputMsg = inputMsg, originalMsg = originalMsg,
					timeout = timeout or default_timeout, timeout_callback = timeout_callback or default_timeout_callback,
				};
				result = errorcode.RepeatCall;
				callback = callback.next_call;
			end
		end
		
		-- time out is supported via a timer object per request pool. timer is created on first use. 
		if(callback.timeout and callback.timeout>0) then
			if(not callback.timer) then
				callback.timer = commonlib.Timer:new({callbackFunc = function(timer)
					local old_callback = {
						callback_func = callback.callback_func,
						callbackParams = callback.callbackParams,
						inputMsg = callback.inputMsg,
						originalMsg = callback.originalMsg,
						timeout = callback.timeout,
						timeout_callback = callback.timeout_callback,
					}
					-- remove callback before calling time out callback, so that we can initiate another call within the callback.
					local next_request = RemoveCallback(id);
					
					LOG.std(nil, "warning", "REST_local", "rest request is timed out: pool(%s)%s msg:%s", id, url, commonlib.serialize(originalMsg));
					
					-- we inform the caller via the callback
					if(old_callback.timeout_callback) then
						old_callback.timeout_callback(old_callback.inputMsg, old_callback.callbackParams);
					end

					activate_next(id, next_request);
				end});
			end	
			if(result == true) then
				-- start the timer after callback.timeout milliseconds, and stop it immediately.
				callback.timer:Change(callback.timeout, nil)
			end
		end	
		return result, callback;
	end

	
	---------------------------------------
	-- the callback function after the RPC returns. 
	---------------------------------------
	local function callbackFunc(id, msg)
		local callback = GetCallback(id);
		if(callback ~= nil) then
			local next_request = RemoveCallback(id);
			callback.IsRemoved = true;
			if(callback.callback_func~=nil) then
				-- make the input message the same format as the HTTP request. 
				msg.rcode = 200;
				msg.code = 0;

				local raw_msg = msg;
				if(postMsgTranslator) then
					msg = postMsgTranslator(msg, url);
				end
				if(postFunc~=nil) then
					local newMsg = postFunc(o, msg, id, callback.callback_func, callback.callbackParams, postMsgTranslator, raw_msg, callback.inputMsg, callback.originalMsg);
					if(newMsg) then
						msg = newMsg;
					end
				end

				callback.callback_func(msg, callback.callbackParams);
			end
			activate_next(id, next_request);
		end
	end

	---------------------------------------
	-- activate the next message in the pool
	---------------------------------------
	activate_next = function(id, next_request)
		if(next_request) then 
			if(next_request.timeout and next_request.timeout>0) then
				-- start the timer after callback.timeout milliseconds, and stop it immediately.
				next_request.timer:Change(next_request.timeout, nil)
			end

			-- tricky: we will use msg.nid as the user_nid. 
			local msg = next_request.inputMsg;
			local user_nid = msg.nid or "0";
			if(not msg._nid) then
				msg.nid = nil;
			else
				msg.nid = msg._nid;
				msg._nid = nil;
			end

			rest_local:SendRequest(user_nid, url, next_request.inputMsg, nil, function (msg, request)
				callbackFunc(id, msg);
			end, next_request.timer)
		end
	end
	
	---------------------------------------
	-- the activation function that calls the remote RPC
	-- @param msg: input message table, usually name value pairs
	-- @param id: the request pool name. only one concurrent request is allowed in a request pool, repeated calls with the same id will return go into a queue and the function returns errorcode.RepeatCall.
	--   but the request will be serviced after the previous call is finished (any pre_function is called immediately, so if there is local cache the function also returned immediately).
	--   The timeout value specified is counted when the request is sent to the server, so if there are repeated calls(as in a queue), later calls may take longer than the timeout value to finish. 
	--   the max number of request in a pool is 100 at the moment. 
	--	 if id "nil", repeated calls are ignored, and only the latest callback will be invoked once, although multiple requests will be made to the server.
	--   if id is nil, it will automatically generate a unique number id, so that errorcode.RepeatCall will never be called. This is the recommended way to activate unless one wants the repeatcall feature.
	-- @param callback_func: the callback function(msg, callbackParams) end, the callback function. msg may be empty table if request failed. 
	-- @param callbackParams: some additional parameter to be passsed to callback_func as second parameter. 
	-- @param timeout: the timeout in milliseconds of this activation. if 0 or negative timeout will be ignored. if nil, the default timeout is used. 
	-- @param timeout_callback: the time out callback function(inputMsg, callbackParams) end. it is called whenever request is timed out. inputMsg is the input request msg. 
	---------------------------------------
	local function activate(self, msg, id, callback_func, callbackParams, timeout, timeout_callback)
		if(id == nil) then
			id = GetNextID();
		end
				
		-- debug purpose trace uid
		local npl_thread_name;
		if(gateway.GetThreadName) then
			npl_thread_name = gateway:GetThreadName();
		else
			npl_thread_name = "";
		end

		msg.trace_uid = npl_thread_name.."+"..trace_uid_base;
		trace_uid_base = trace_uid_base + 1;

		local originalMsg = commonlib.deepcopy(msg);
		if(preMsgTranslator) then
			msg = preMsgTranslator(msg);
		end
		if(not activateCount) then
			activateCount = 0;
			-- this allows use to parse url replaceables only when it is used. 
			-- Note: local_rest never translate url to increase speed
			-- url = client.TranslateURL(url);
		end
		activateCount = activateCount + 1;
		local res;
		if(prepFunc~=nil) then
			res = prepFunc(self, msg, id, callback_func, callbackParams, postMsgTranslator);
		end
		if(res == nil) then
			if(type(id) == "function") then
				LOG.std(nil, "error", "REST_local", "error: "..url.." should be called with a string id. Have you missed it?");
			end
			local callback_;
			res, callback_ = AddCallback(id, callback_func, callbackParams, msg, originalMsg, timeout, timeout_callback);
			if(res==true) then
				-- tricky: we will use msg.nid as the user_nid. 
				local user_nid = msg.nid or "0";
				if(not msg._nid) then
					msg.nid = nil;
				else
					msg.nid = msg._nid;
					msg._nid = nil;
				end

				rest_local:SendRequest(user_nid, url, msg, nil, function (msg, request)
					-- msg.user_nid keeps the returned user nid 
					callbackFunc(id, msg);
				end, callback_.timer)
			else
				-- LOG.std(nil, "warning", "REST_local", "repeated rest call. result.code:%s, pool name:%s", res, id);
			end
		end
		return res;
	end
	
	-- expose RPC class via global environment.   	
	o = setmetatable({
		GetUrl = function() 
				if(not activateCount) then
					activateCount = 0;
					-- this allows use to parse url replaceables only when it is used. 
					url = client.TranslateURL(url);
				end
				return url 
			end,
		SetUrl = function(new_url) 
				activateCount = activateCount or 0;
				url = client.TranslateURL(new_url)
			end,
		activate = activate,
		callbackFunc = callbackFunc,
	}, {
		__call = activate,
		__tostring = function(self)
			return fullname..": (" ..url..")";
		end
	});
	commonlib.setfield(fullname, o);
end

---------------------------------------------
-- message translators 
-- it translates the input msg={header, code, rcode, data} before it is passed to callbackFunc
---------------------------------------------
-- translate msg.data from json to npl table
-- @return the translated version
function client.JsonTranslator(msg, url)
	-- use C++ version of json parser. It is safer than lua version, since it will never call lua panic 
	local out={};
	if(not msg.data or NPL.FromJson(msg.data, out)) then
		return out;
	else
		LOG.std(nil, "warning", "REST", "can not translate message to json."..LOG.tostring("url: %s|", tostring(url))..LOG.tostring(msg.header)..LOG.tostring("|--> data|")..LOG.tostring(msg.data));
	end
end

-- make all table fields lower cased before sending out. 
function client.PreMsgLowerCased(msg)
	return commonlib.tolower(msg);
end

----------------------------------------------
-- REST (with json string as output) wrapper functions 
----------------------------------------------
--[[
-- create REST API once and for all
GameServer.rest.client.CreateRESTJsonWrapper("test.auth.AuthUser", "AuthUser")

-- invoke API. the second parameter is rpc instance name. There can be one ongoing activation per instance. repeated calls will be ignored. 
test.auth.AuthUser({username="LiXizhi1", password="1234567"}, "test", function(msg)  
	commonlib.echo(msg)
end)
]]
function client.CreateRESTJsonWrapper(fullname, url_, prepFunc, postFunc, preMsgTranslator, postMsgTranslator, default_timeout, default_timeout_callback, max_queue_size)
	client.CreateRPCWrapper(fullname, url_, prepFunc, postFunc, preMsgTranslator or client.PreMsgLowerCased, postMsgTranslator or client.JsonTranslator, default_timeout, default_timeout_callback, max_queue_size)
end

--[[
-- create REST local API once and for all
GameServer.rest_local.CreateRESTLocalJsonWrapper("test.auth.AuthUser", "AuthUser")

-- invoke API. if the second parameter is nil to allow multiple invocations. 
test.auth.AuthUser({username="LiXizhi1", password="1234567"}, nil, function(msg)  
	commonlib.echo(msg)
end)
]]
function rest_local.CreateRESTLocalJsonWrapper(fullname, url_, prepFunc, postFunc, preMsgTranslator, postMsgTranslator, default_timeout, default_timeout_callback, max_queue_size)
	rest_local.CreateRestLocalWrapper(fullname, url_, prepFunc, postFunc, preMsgTranslator, postMsgTranslator or client.JsonTranslator, default_timeout, default_timeout_callback, max_queue_size)
end

-- translate url to internal one used by the game server. see "config/WebAPI.config.xml" and "rest_API.lua" for a list of all internal url strings. 
-- it will remove root domain and trailing .ashx extension first, and then search in self.API table to locate the url. if not found the input url itself is returned. 
-- e.g. 
--		client.TranslateURL("http://paraengine.com/API/Auth/AuthUser.ashx") --> AuthUser
-- @return the translated url. 
function client.TranslateURL(url)
	url = string_gsub(url, "^.-[^/:]+/", "");
	url = string_gsub(url, "%.ashx$", "");
	local service = client.API[url];
	if(service and service.shortname) then
		return service.shortname;
	end
	return url;
end
