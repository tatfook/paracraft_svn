--[[
Title: Trade server
Author(s): LiXizhi
Date: 2011/10/12
Desc: 
-----------------------------------------------
NPL.load("(gl)script/apps/GameServer/TradeService/GSL_TradeServer.lua");
local server = Map3DSystem.GSL.Trade.GSL_TradeServer:new();
-----------------------------------------------
]]
NPL.load("(gl)script/ide/timer.lua");
NPL.load("(gl)script/apps/GameServer/TradeService/GSL_TradeData.lua");
NPL.load("(gl)script/kids/3DMapSystemItem/PowerItemManager.lua");
local PowerItemManager = commonlib.gettable("Map3DSystem.Item.PowerItemManager");
local trade_transaction = commonlib.gettable("Map3DSystem.GSL.Trade.trade_transaction");
local trade_container = commonlib.gettable("Map3DSystem.GSL.Trade.trade_container");
local TradeMSG = commonlib.gettable("Map3DSystem.GSL.Trade.TradeMSG")

local tostring = tostring;
local format = format;
-- create class
local GSL_TradeServer = commonlib.inherit(nil, commonlib.gettable("Map3DSystem.GSL.Trade.GSL_TradeServer"))

-- whether to output log by default. 
local enable_debug_log = false;
-- the global instance, because there is only one instance of this object
local g_singleton;

-- mapping from user nid string to the trade_transaction. please note that both users are added. 
local users_to_trades_map = {};

------------------------
--  TradeServer class: static NPC method
------------------------
local TradeServer = {};
Map3DSystem.GSL.config:RegisterNPCTemplate("trade", TradeServer)
function TradeServer.CreateInstance(self, revision)
	-- overwrite virtual functions
	self.OnNetReceive = TradeServer.OnNetReceive;
	self.OnFrameMove = TradeServer.OnFrameMove;

	TradeServer.server = self;
	LOG.std(nil, "info","TradeServer", "CreateInstance");
end

-- whenever an instance of this server agent has received a real time message from client (from_nid) in gridnode, this function will be called.  
function TradeServer:OnNetReceive(from_nid, gridnode, msg, revision)
	if(from_nid and gridnode) then
		TradeServer.server = self;

		-- received a new message. 
		GSL_TradeServer.GetSingleton():OnReceiveMessage(from_nid, msg);
	end
end

-- This function is called by gridnode at normal update interval. One can update persistent data fields in this functions. 
function TradeServer:OnFrameMove(curTime, revision)
end

------------------------
--  GSL_TradeServer class
------------------------
function GSL_TradeServer:ctor()
	-- enable debugging here
	self.debug_stream = self.debug_stream or enable_debug_log;
end

-- get the global singleton.
function GSL_TradeServer.GetSingleton()
	if(not g_singleton) then
		g_singleton = GSL_TradeServer:new();
	end
	return g_singleton;
end

-- do some one time init here
-- @param msg: {debug_stream="true"}
function GSL_TradeServer:init(msg)
	msg = msg or {};
	-- maximum time of trade operation, since start.  
	self.trade_start_timeout_interval = msg.trade_start_timeout_interval or 360000;
	self.timer_interval = msg.timer_interval or 5000;
	if(msg.debug_stream == "true") then
		self.debug_stream = true;
	end

	self.timer = self.timer or commonlib.Timer:new({callbackFunc = function(timer)
		self:OnTimer(timer);
	end})
	self.timer:Change(self.timer_interval, self.timer_interval)
end

--@param nid: user nid string
-- @return the trade_transaction by user nid, it may return nil if not found.
function GSL_TradeServer:GetTradeByUser(nid)
	if(nid) then
		return users_to_trades_map[nid];
	end
end

-- This is a singleton function that is called periodically to clear up resources.
-- @note: SendMessage function should never be called in this function. 
function GSL_TradeServer:OnTimer(timer)
	-- check all trades and close timed out trades. 
	local trade_start_timeout_interval = self.trade_start_timeout_interval;
	local cur_time = ParaGlobal.timeGetTime();
	local cleared_trade;
	local user_nid, trad_trans;
	for user_nid, trad_trans in pairs(users_to_trades_map) do
		if( (trad_trans.start_time and (cur_time-trad_trans.start_time) > trade_start_timeout_interval) ) then
			-- remove the trade 
			trad_trans:clear();

			-- non-persistent trade trade will be removed completely. 
			cleared_trade = cleared_trade or {};
			cleared_trade[user_nid] = true;
		end
	end

	-- clear trades in the second pass
	if(cleared_trade) then
		local _;
		for user_nid, _ in pairs(cleared_trade) do
			users_to_trades_map[user_nid] = nil;
		end
	end
end

-- messages that should be sent using type channels
local use_channel_types = {
	[TradeMSG.TRADE_RESPONSE] = true,
	[TradeMSG.TRADE_COMPLETE] = true,
	[TradeMSG.TRADE_CANCEL] = true,
	[TradeMSG.TRADE_ITEM_UPDATE] = true,
}

-- set the message to trade client
function GSL_TradeServer:SendMessage(user_nid, msg_type, msg_data)
	local server = TradeServer.server;
	if(server)then
		msg_data = msg_data or {};
		msg_data.type = msg_type;
		server:SendRealtimeMessage(user_nid, msg_data, if_else(use_channel_types[msg_type], "type", nil));
	end
end

-- send trad updates to both users
function GSL_TradeServer:SendItemUpdate(trad_trans)
	if(trad_trans and trad_trans.is_modified) then
		trad_trans.is_modified = false;
		local nid1, nid2 = trad_trans:get_player_nids();
		local msg = {trad_trans = trad_trans};
		if(nid1) then
			self:SendMessage(nid1, TradeMSG.TRADE_ITEM_RESPONSE, msg);
		end
		if(nid2) then
			self:SendMessage(nid2, TradeMSG.TRADE_ITEM_RESPONSE, msg);
		end
	end
end

-- remove the given trades and send cancel message to both clients. 
function GSL_TradeServer:CancelTrade(trad_trans)
	if(trad_trans) then
		local nid1, nid2 = trad_trans:get_player_nids();
		if(nid1) then
			users_to_trades_map[nid1] = nil;
			self:SendMessage(nid1, TradeMSG.TRADE_CANCEL);
		end
		if(nid2) then
			users_to_trades_map[nid2] = nil;
			self:SendMessage(nid2, TradeMSG.TRADE_CANCEL);
		end
	end
end

-- start the trade, summit to data base user
function GSL_TradeServer:StartTrade(trad_trans)
	if(trad_trans and trad_trans:is_ok()) then
		local nid1, nid2 = trad_trans:get_player_nids();
		if(nid1 and nid2) then
			self:SendMessage(nid1, TradeMSG.TRADE_STARTED);
			self:SendMessage(nid2, TradeMSG.TRADE_STARTED);

			-- remove from trade table. 
			users_to_trades_map[nid1] = nil;
			users_to_trades_map[nid2] = nil;

			-- this will ensure that the same items are not traded both ways. 
			trad_trans:normalize();

			-- invoke the data base API in a callback and then send TRADE_COMPLETE message. 
			self:call_complete_trade(trad_trans, function(msg)
				--if(msg and msg.issuccess) then
					--msg = {succeed = true}
				--else
					--msg = {succeed = false}
				--end
				self:SendMessage(nid1, TradeMSG.TRADE_COMPLETE, msg);
				self:SendMessage(nid2, TradeMSG.TRADE_COMPLETE, msg);
			end);
		end
	end
end

-- invoke db api and then return the result
-- @param trad_trans: 
-- @param callbackFunc: function(msg)  end, where msg = {issuccess=bool, ...}, the other fields please refer to API. 
-- such as {nid0=string, nid1=string, "issuccess":true,"ups0":[{"guid":168,"copies":0}],"ups1":[],"adds0":[],"adds1":[{"guid":429,"gsid":23314,"bag":25,"pos":2,"copies":1,"svrdata":""}]}||
function GSL_TradeServer:call_complete_trade(trad_trans, callbackFunc)
	-- call db api here
	PowerItemManager.DoTransaction(trad_trans, callbackFunc)
end

-- we received a message from the trade server. 
function GSL_TradeServer:OnReceiveMessage(from_nid, msg)
	if(not msg) then return end
	if(self.debug_stream) then
		LOG.std(nil, "debug", "tradeserver", "received msg:"..commonlib.serialize_compact(msg));
	end	
	
	-- local from_nid = msg.user_nid;
	if(not from_nid) then
		return;
	end
	local trad_trans = self:GetTradeByUser(from_nid);

	local msg_type = msg.type;
	
	if(msg_type == TradeMSG.TRADE_REQUEST) then
		-- from client to server: start trading with a given user {target_nid = string}
		if(trad_trans and trad_trans:is_valid()) then
			-- close previous trade if any
			self:CancelTrade(trad_trans);
			trad_trans = nil;
		end
		
		if(msg.target_nid) then
			-- create a new trade
			local new_trade = trad_trans or trade_transaction:new();
			new_trade:add_player(from_nid);
			new_trade.expecting_nid = msg.target_nid;
			users_to_trades_map[from_nid] = new_trade;

			self:SendMessage(msg.target_nid, TradeMSG.TRADE_REQUEST, {from_nid = from_nid});
		end
	elseif(msg_type == TradeMSG.TRADE_RESPONSE) then	
		-- from client to server: a user either accept or reject the trade request {accepted=boolean,}
		if(trad_trans) then
			-- close previous trade if any
			self:CancelTrade(trad_trans);
		end
		if(msg.accepted) then
			if(msg.to_nid) then
				local trad_trans = self:GetTradeByUser(msg.to_nid);
				if(trad_trans and trad_trans.expecting_nid == from_nid and trad_trans:add_player(from_nid)) then
					-- add trade
					users_to_trades_map[from_nid] = trad_trans;
					-- accepted, so we may wait for next TRADE_ITEM_UPDATE message. 
					self:SendMessage(msg.to_nid, TradeMSG.TRADE_RESPONSE, {from_nid=from_nid, accepted=true});
					self:SendItemUpdate(trad_trans);
				else
					-- the to_nid user is already involved in another trade, so automatically return unaccept. 
					self:SendMessage(msg.to_nid, TradeMSG.TRADE_RESPONSE, {from_nid=from_nid, accepted=false});
				end
			end
		elseif(msg.to_nid) then
			self:SendMessage(msg.to_nid, TradeMSG.TRADE_RESPONSE, {from_nid=from_nid, accepted=false});
		end
	elseif(msg_type == TradeMSG.TRADE_ITEM_UPDATE) then	
		-- from client to server: the client changes its trade items or money  {trad_cont={...}}
		if(trad_trans and trad_trans:has_player(from_nid)) then
			if(trad_trans:update_items(from_nid, msg.trad_cont, msg.revision)) then
				self:SendItemUpdate(trad_trans);
				-- cache update till the next update message. 
				if(trad_trans:is_ok()) then
					self:StartTrade(trad_trans);
				end
			end
		else
			self:SendMessage(from_nid, TradeMSG.TRADE_CANCEL);
		end
	elseif(msg_type == TradeMSG.TRADE_CANCEL) then	
		-- from client to server: cancel trade
		if(trad_trans) then
			self:CancelTrade(trad_trans);
		end
	elseif(msg_type == TradeMSG.TRADE_CONFIRM) then	
		-- obsoleted use TRADE_ITEM_UPDATE: from client to server: lock view: {is_confirmed=bool}
		if(trad_trans) then
			if(trad_trans:update_items(from_nid, {is_confirmed = msg.is_confirmed}, msg.revision)) then
				self:SendItemUpdate(trad_trans);
			end
		end
	elseif(msg_type == TradeMSG.TRADE_OK) then
		-- obsoleted use TRADE_ITEM_UPDATE: from client to server: say ok: {is_ok=bool}
		if(trad_trans) then
			trad_trans:update_items(from_nid, {is_ok = msg.is_ok}, msg.revision);
			if(trad_trans:is_ok()) then
				if(trad_trans:is_both_empty()) then
					self:StartTrade(trad_trans);
				else
					self:CancelTrade(trad_trans);
				end
			end
		end
	end
end
