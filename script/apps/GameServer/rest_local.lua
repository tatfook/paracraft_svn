--[[
Author: LiXizhi
Date: 2009-8-21
Desc: REST interface of game server
The (rest) state runs inside a game server.  It sends REST requests to NPLRouter, which in turn sends to DBServer, 
the DBServer processes the message and replies to NPLRouter which in turn forward to this file again. 
-----------------------------------------------
NPL.load("(gl)script/apps/GameServer/rest_local.lua");
-----------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua"); -- many sub dependency included
NPL.load("(gl)script/apps/GameServer/rest_API.lua");

local rest_local = commonlib.gettable("GameServer.rest_local");
local rest = commonlib.gettable("GameServer.rest");
local format = format;
local LOG = LOG;

-- pending request. 
rest_local.pending_requests = {};

-- send a request via the rest interface. Call this function if one wants to directly call remote rest interface without using a REST wrapper. 
-- This function should only be called by authorized server side script, since it can be on behalf of any given user. 
-- @param user_nid: on behalf of a given nid string. If "0", it is a general server-side request. 
-- @param url: string
-- @param request: a table of name value pairs
-- @param callback_func: function(msg)  end, which contains the message output after converting json string to npl msg table. This can be nil.
-- @param raw_callback_func: function(msg, request) end, which contains the raw message from the activation call. This can be nil. 
--  If this is not nil, it will be called before the callback_func. request is a table that contains {url, req}
-- @param timer: if nil, no time out callback, otherwise it is a virtual commonlib.Timer object. we will stop the timer when a request is received. 
--   in web service wrapper, we usually create a timer per url or per pool, and use the timer for request time out. 
function rest_local:SendRequest(user_nid, url, request, callback_func, raw_callback_func, timer)
	local seq = self:AddPendingRequest({callback_func = callback_func, url=url, req=request, raw_callback_func = raw_callback_func, timer=timer});
	
	--LOG.std(nil, "debug", "rest_local", {url, request, seq, user_nid})

	if( rest:SendRequest(url, request, seq, user_nid)~=0 ) then
		self:RemoveRequestByID(seq);
		-- connection to self.rest_address may be lost
		LOG.std(nil, "info", "rest_local", "unable to send request.")
	end
end

-- handle reply from db server for gamesvr simulating a client to call it's self rest thread
function rest_local:handle_response(msg)
	-- this is reply from DBServer-->NPLRouter to game server, we will just forward back to client
	-- e.g. {ver="1.0",result=0,msg="",my_nid=1901,game_nid=2001,user_nid=10089,data_table={name1="value1",name2="value2",},}
	-- commonlib.applog("game server got REST reply "..__rts__:GetName());	commonlib.echo(msg);
	
	local user_nid = msg.user_nid;
	local msg = msg.data_table;

	--if(user_nid ~= 0) then 
		-- handle reply
		local request = rest_local:GetRequestByID(msg.seq);
		if(type(request) == "table") then
			if(request.timer) then
				if(request.timer:IsEnabled()) then
					-- now kill the timer.
					request.timer:Change();
				else
					--  If timer is already activated(disabled), meaning that time out is already be called
					--  we should avoid calling the callback any more. 
					return;
				end
			end
			if(type(request.raw_callback_func) == "function") then
				request.raw_callback_func(msg, request);
			end
			if(type(request.callback_func) == "function") then
				if(msg.data) then
					local out={};
					if(NPL.FromJson(msg.data, out)) then
						request.callback_func(out);
					end	
				end	
			end	
		end
	--end
end

---------------------------------
-- private functions
---------------------------------

-- @return the next request sequence id. 
function rest_local:GetNextSeqID()
	local pending_requests = self.pending_requests;
	
	local seq = 1;
	while(pending_requests[seq]) do
		seq = seq + 1;
	end
	return seq;
end

-- add a pending request to the request pool
-- @return the sequence id
function rest_local:AddPendingRequest(request)
	local seq = self:GetNextSeqID();
	self.pending_requests[seq] = request;
	return seq;
end

-- get a request by its sequence id. This function is called when the client receives a reply and needs to handle its callback. 
-- Once this function is called, the request will be removed from the seq. i.e. it will be considered already handled.
-- @param seq: the sequence id. 
function rest_local:GetRequestByID(seq)
	if(seq) then
		local request = self.pending_requests[seq];
		self.pending_requests[seq] = nil;
		return request;
	end	
end

-- remove request by its id. 
function rest_local:RemoveRequestByID(seq)
	if(seq) then
		self.pending_requests[seq] = nil;
	end	
end

-- this is a private file, so it is only used for testing from the main ui thread. 
local function activate()
	local msg = msg;
	
	if(msg.dostring) then
		-- handle request
		LOG.std(nil, "debug", "rest_local", {"testing begins ----------------------"});
		LOG.std(nil, "debug", "rest_local", msg.dostring);
		NPL.DoString(msg.dostring);
	end
end
NPL.this(activate)