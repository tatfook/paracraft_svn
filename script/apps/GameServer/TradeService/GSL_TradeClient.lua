--[[
Title: Trade client
Author(s): LiXizhi
Date: 2011/10/17
Desc: "on_trade_update" event is fired when a trade transaction changes.
the message format is {type="on_trade_update", trad_trans={}, is_cancel=boolean, is_complete=boolean, is_failed=boolean}
-----------------------------------------------
NPL.load("(gl)script/apps/GameServer/TradeService/GSL_TradeClient.lua");
local trade_container = commonlib.gettable("Map3DSystem.GSL.Trade.trade_container");
local tradeclient = Map3DSystem.GSL.Trade.GSL_TradeClient.GetSingleton();
tradeclient:AddEventListener("on_trade_update", function(msg)
	if(msg.trad_trans) then
		-- this is the trade_transaction class instance, one can call its methods. 
	elseif(msg.is_cancel) then
		-- trade canceled
	elseif(msg.is_complete) then
		-- trade completed
	elseif(msg.is_started) then
		-- trade started
	elseif(msg.is_failed) then
		-- trade failed
	end
end);
tradeclient:AddEventListener("on_trade_request", function(msg)
	if(msg.from_nid) then
		tradeclient:AcceptTrade(); 
		-- or tradeclient:RejectTrade();
	end
end);

local trad_cont = trade_container:new();
tradeclient:SendItemsUpdate(trad_cont);
-----------------------------------------------
]]
NPL.load("(gl)script/ide/EventDispatcher.lua");
NPL.load("(gl)script/apps/GameServer/TradeService/GSL_TradeData.lua");
local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");
local TradeMSG = commonlib.gettable("Map3DSystem.GSL.Trade.TradeMSG")
local trade_transaction = commonlib.gettable("Map3DSystem.GSL.Trade.trade_transaction");
local trade_container = commonlib.gettable("Map3DSystem.GSL.Trade.trade_container");

local tostring = tostring;

local GSL_TradeClient = commonlib.inherit(nil, commonlib.gettable("Map3DSystem.GSL.Trade.GSL_TradeClient"))


------------------------------
-- TradeClient: NPC client class
------------------------------
local TradeClient = {};
Map3DSystem.GSL.client.config:RegisterNPCTemplate("trade", TradeClient)

function TradeClient.CreateInstance(self)
	self.OnNetReceive = TradeClient.OnNetReceive;
	LOG.std(nil, "system", "TradeClient",  "TradeClient.CreateInstance");
end


-- whenever an instance of this server agent calls AddRealtimeMessage() on the server side(from_nid), the client will receive it via this event callback. 
-- if msg is nil, it means that client has received a normal update of this agent from server and some data fields of the agent have been updated. 
function TradeClient:OnNetReceive(client, msgs)
	local client = GSL_TradeClient.GetSingleton()
	if(client and msgs) then
		local _, msg;
		for _, msg in ipairs(msgs) do
			client:OnReceiveMessage(msg);		
		end
	elseif(msgs == nil) then
		
	end
end

------------------------------
-- GSL_TradeClient class
------------------------------

-- whether to output log by default. 
local enable_debug_log = true;
-- the global instance, because there is only one instance of this object
local g_singleton;
-- default timeout for request
local default_timeout = 5000;
local heartbeat_interval = 15000;
-- constructor
function GSL_TradeClient:ctor()
	-- enable debugging here
	self.debug_stream = self.debug_stream or enable_debug_log;
	self.events = commonlib.EventDispatcher:new();
	self.callbacks = {};
	self.timer = self.timer or commonlib.Timer:new({callbackFunc = function(timer)
		self:OnTimer(timer);
	end})
	self.timer:Change(heartbeat_interval, heartbeat_interval);
	
	-- each trade client must be associated with a gsl client object, even if none is provided.
	self:SetClient();
end

function GSL_TradeClient:OnTimer()
	-- send heart beat to the server at heartbeat_interval 
	if(self.trad_trans) then
		-- self:SendMessage("heart_beat", {}, nil, nil);
	end
end

-- reset trade transaction. 
function GSL_TradeClient:ResetTradeTrans()
	self.trad_trans = trade_transaction:new();
	self.trad_trans:add_player(tostring(System.User.nid));
end

-- create get the trade transaction object. 
function GSL_TradeClient:get_trad_trans()
	if(not self.trad_trans) then
		self:ResetTradeTrans();
	end
	return self.trad_trans;
end

-- return my and the other person's trade container. 
-- @return my_cont, other_cont. note it may return nil. 
function GSL_TradeClient:get_containers()
	local trans = self:get_trad_trans();
	if(trans) then
		return trans:get_container_by_nid(tostring(System.User.nid));
	end
end

-- get the global singleton.
function GSL_TradeClient.GetSingleton()
	if(not g_singleton) then
		g_singleton = GSL_TradeClient:new();
	end
	return g_singleton;
end

-- set the gsl client object
-- @param client: if nil it is the global default client object. 
function GSL_TradeClient:SetClient(client)
	self.client = client or commonlib.gettable("Map3DSystem.GSL_client");
end

function GSL_TradeClient:GetClient()
	return self.client;
end

-- add a NPL call back script to a given even listener
-- there can only be one listener per type per instance. 
-- @param ListenerType: string. Currently, only "on_trade_update" is supported. 
-- @param callbackScript: the function to be called when the listener event is raised. Usually parameters are stored in a NPL parameter called "msg".
-- @param self_this: the first parameter to be passed to the callback. if nil, it will be GSL_TradeClient(self). 
function GSL_TradeClient:AddEventListener(ListenerType, callbackScript, self_this)
	self.events:AddEventListener(ListenerType, callbackScript, self_this or self);
end

-- remove a NPL call back script from a given even listener
-- @param ListenerType: string 
-- @param callbackScript: if nil, all callback of the type is removed. the script or function to be called when the listener event is raised. Usually parameters are stored in a NPL parameter called "msg".
function GSL_TradeClient:RemoveEventListener(ListenerType, callbackScript)
	self.events:RemoveEventListener(ListenerType);
end

-- clear all registered event listeners
function GSL_TradeClient:ResetAllEventListeners()
	self.events:ClearAllEvents();
end

-- fire a given event with a given msg
-- @param event. it is always a table of {type=string, ...}, where the type is the event_name, other fields will sent as they are. 
function GSL_TradeClient:FireEvent(event)
	self.events:DispatchEvent(event, self)
end

-- fire a given event with a given msg
-- @param event. it is always a table of {type=string, ...}, where the type is the event_name, other fields will sent as they are. 
function GSL_TradeClient:FireEventByType(event_type, event)
	self.events:DispatchEventByType(event_type, event, self)
end

-- send a message to server
function GSL_TradeClient:SendMessage(msg_type, msg_data)
	if(not self.client) then
		LOG.std(nil, "error", "tradeclient", "no gsl client is found");
		return
	else
		msg_data = msg_data or {};
		msg_data.type = msg_type;
		self.client:SendRealtimeMessage("trade", msg_data);
	end
end

-- public: send trade client update. 
-- @param trad_cont: should be instance of trade_container. if nil, it is the current container. 
function GSL_TradeClient:SendItemsUpdate(trad_cont)
	if(not trad_cont) then
		trad_cont = self:get_containers()
	end
	-- secretely inject server data
	if(trad_cont) then
		local _, item;
		for _, item in ipairs(trad_cont.items) do
			local guid = item[1];
			if( guid ) then
				local my_item = ItemManager.GetItemByGUID(guid);
				if(my_item and my_item.serverdata) then
					item[4] = my_item.serverdata;
				end
			end
		end
	end
	local revision;
	if(self.trad_trans) then
		revision = self.trad_trans.revision;
	end
	self:SendMessage(TradeMSG.TRADE_ITEM_UPDATE, {trad_cont=trad_cont, revision=revision});
end

-- public: requesting to trade with a given user by nid. 
-- @param callbackFunc: function(bSucceed) end. please note this function may never be called. 
function GSL_TradeClient:RequestTradeWith(target_nid, callbackFunc)
	-- TODO: check distance on client as well.
	self:ResetTradeTrans();
	self:SendMessage(TradeMSG.TRADE_REQUEST, {target_nid=target_nid});
	self.expecting_nid = target_nid;
	self.trade_response_callback = callbackFunc
end

-- public:accept trade
-- @param target_nid: if nil, it will be self.last_request_nid
function GSL_TradeClient:AcceptTrade(target_nid)
	target_nid = target_nid or self.last_request_nid;
	if(target_nid) then
		self:ResetTradeTrans();

		-- from client to server: a user either accept or reject the trade request {to_nid=string, accepted=boolean,}
		self:SendMessage(TradeMSG.TRADE_RESPONSE, {to_nid=target_nid, accepted=true});
	end
end

-- public:reject trade
-- @param target_nid: if nil, it will be self.last_request_nid
function GSL_TradeClient:RejectTrade(target_nid)
	target_nid = target_nid or self.last_request_nid;
	if(target_nid) then
		-- from client to server: a user either accept or reject the trade request {to_nid=string, accepted=boolean,}
		self:SendMessage(TradeMSG.TRADE_RESPONSE, {to_nid=target_nid, accepted=false});
	end
end

-- public:cancel the current trade
function GSL_TradeClient:CancelTrade()
	self:SendMessage(TradeMSG.TRADE_CANCEL, {});
end

-- we received a message from the trade server. 
function GSL_TradeClient:OnReceiveMessage(msg)
	if(not msg) then return end

	if(self.debug_stream) then
		LOG.std(nil, "debug", "tradeclient", "nid: %s received msg: %s", tostring(System.User.nid), commonlib.serialize_compact(msg));
	end	
	local msg_type = msg.type;

	if(msg.trad_trans) then
		msg.trad_trans = trade_transaction:new(msg.trad_trans);
	end

	-- this is a new translated message for "on_trade_update" event, if nil, the original message will be used. 
	local new_msg; 

	if(msg_type == TradeMSG.TRADE_ITEM_RESPONSE) then
		-- from server to client: the state of the trade changes. {trad_trans={}} to prevent data loss, the entire trade_transaction is sent back when data changes.
		self.trad_trans = msg.trad_trans;
		if(self.trad_trans) then
			local my_cont, other_cont = self.trad_trans:get_container_by_nid(tostring(System.User.nid));
			if(other_cont) then
				local _, item;
				for _, item in other_cont:each_item() do
					local new_item = {
						guid = item[1],
						gsid = item[3],
						serverdata = item[4],
					}
					if(new_item.guid and new_item.gsid) then
						ItemManager.SetOPCItemByGUID(tonumber(other_cont.nid), new_item, true)
					end
				end
			end
		end
	elseif(msg_type == TradeMSG.TRADE_REQUEST) then
		-- from server to client: ask a user to start trade from another user {from_nid = string}
		self.last_request_nid = msg.from_nid;
		self:FireEventByType("on_trade_request", msg);

	elseif(msg_type == TradeMSG.TRADE_RESPONSE) then
		-- from server to client: {from_nid=string, accepted=boolean,}
		if(msg.from_nid and msg.from_nid == self.expecting_nid) then
			if(self.trade_response_callback) then
				self.trade_response_callback(msg.accepted);
			end
		end
	elseif(msg_type == TradeMSG.TRADE_CANCEL) then
		-- from server to client: cancel trade
		msg.is_cancel = true;

		self.trad_trans = nil;
		self.last_request_nid = nil;
		self.expecting_nid = nil;
		
	elseif(msg_type == TradeMSG.TRADE_STARTED) then
		-- from server to client: trade is started and submmited to the db server. any user action should be locked, and client should wait for the TRADE_COMPLETE in the next moment. 
		msg.is_started = true;
	elseif(msg_type == TradeMSG.TRADE_COMPLETE) then
		-- from server to client: {issuccess=boolean}
		if(msg.issuccess or msg.succeed) then
			msg.is_complete = true;
		else
			msg.is_failed = true;
		end
		
		self.last_request_nid = nil;
		self.expecting_nid = nil;
		self.trad_trans = nil;
	end
	
	self:FireEventByType("on_trade_update", msg);
end
