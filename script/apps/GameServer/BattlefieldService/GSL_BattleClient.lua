--[[
Title: Battle client
Author(s): LiXizhi
Date: 2011/12/9
Desc: "normal_update" event is fired when a battle transaction changes.
the message format is {type="normal_update", }
-----------------------------------------------
NPL.load("(gl)script/apps/GameServer/BattlefieldService/GSL_BattleClient.lua");
local client = Map3DSystem.GSL.Battle.GSL_BattleClient.GetSingleton();
-----------------------------------------------
]]
NPL.load("(gl)script/ide/EventDispatcher.lua");
NPL.load("(gl)script/apps/GameServer/BattlefieldService/GSL_BattleData.lua");
local BattleMSG = commonlib.gettable("Map3DSystem.GSL.Battle.BattleMSG")

local tostring = tostring;
local GSL_BattleClient = commonlib.inherit(nil, commonlib.gettable("Map3DSystem.GSL.Battle.GSL_BattleClient"))

------------------------------
-- BattleClient: NPC client class
------------------------------
local BattleClient = {};
Map3DSystem.GSL.client.config:RegisterNPCTemplate("battle", BattleClient)

function BattleClient.CreateInstance(self)
	self.OnNetReceive = BattleClient.OnNetReceive;
	LOG.std(nil, "system", "BattleClient",  "BattleClient.CreateInstance");
end


-- whenever an instance of this server agent calls AddRealtimeMessage() on the server side(from_nid), the client will receive it via this event callback. 
-- if msg is nil, it means that client has received a normal update of this agent from server and some data fields of the agent have been updated. 
function BattleClient:OnNetReceive(client_, msgs)
	local client = GSL_BattleClient.GetSingleton()
	if(not client) then 
		return 
	end
	
	if(msgs) then
		-- process server message
		local _, msg;
		for _, msg in ipairs(msgs) do
			client:OnReceiveMessage(msg);		
		end
	elseif(msgs == nil) then
		client:OnNormalUpdateMessage(self);
	end
end

------------------------------
-- GSL_BattleClient class
------------------------------

-- whether to output log by default. 
local enable_debug_log = true;
-- the global instance, because there is only one instance of this object
local g_singleton;

-- constructor
function GSL_BattleClient:ctor()
	-- enable debugging here
	self.debug_stream = self.debug_stream or enable_debug_log;
	self.events = commonlib.EventDispatcher:new();
	self.callbacks = {};
	
	self:Reset();
	-- each battle client must be associated with a gsl client object, even if none is provided.
	self:SetClient();
end

function GSL_BattleClient:OnTimer()
end

-- get the global singleton.
function GSL_BattleClient.GetSingleton()
	if(not g_singleton) then
		g_singleton = GSL_BattleClient:new();
	end
	return g_singleton;
end

-- set the gsl client object
-- @param client: if nil it is the global default client object. 
function GSL_BattleClient:SetClient(client)
	self.client = client or commonlib.gettable("Map3DSystem.GSL_client");
end

function GSL_BattleClient:GetClient()
	return self.client;
end

-- clear all battle field data, so that a new battle can begin. 
function GSL_BattleClient:Reset()
	NPL.load("(gl)script/apps/GameServer/BattlefieldService/GSL_BattleData.lua");
	local battlefield = commonlib.gettable("Map3DSystem.GSL.Battle.battlefield");
	self.bf = battlefield:new();
	self.raw_bf = {};
end

-- get the Battle.battlefield class object. 
function GSL_BattleClient:GetBattleField()
	return self.bf;
end

-- add a NPL call back script to a given even listener
-- there can only be one listener per type per instance. 
-- @param ListenerType: string. Currently, only "on_battle_update" is supported. 
-- @param callbackScript: the function to be called when the listener event is raised. Usually parameters are stored in a NPL parameter called "msg".
-- @param self_this: the first parameter to be passed to the callback. if nil, it will be GSL_BattleClient(self). 
function GSL_BattleClient:AddEventListener(ListenerType, callbackScript, self_this)
	self.events:AddEventListener(ListenerType, callbackScript, self_this or self);
end

-- remove a NPL call back script from a given even listener
-- @param ListenerType: string 
-- @param callbackScript: if nil, all callback of the type is removed. the script or function to be called when the listener event is raised. Usually parameters are stored in a NPL parameter called "msg".
function GSL_BattleClient:RemoveEventListener(ListenerType, callbackScript)
	self.events:RemoveEventListener(ListenerType);
end

-- clear all registered event listeners
function GSL_BattleClient:ResetAllEventListeners()
	self.events:ClearAllEvents();
end

-- fire a given event with a given msg
-- @param event. it is always a table of {type=string, ...}, where the type is the event_name, other fields will sent as they are. 
function GSL_BattleClient:FireEvent(event)
	self.events:DispatchEvent(event, self)
end

-- fire a given event with a given msg
-- @param event. it is always a table of {type=string, ...}, where the type is the event_name, other fields will sent as they are. 
function GSL_BattleClient:FireEventByType(event_type, event)
	self.events:DispatchEventByType(event_type, event, self)
end

-- send a message to server
function GSL_BattleClient:SendMessage(msg_type, msg_data)
	if(not self.client) then
		LOG.std(nil, "error", "battleclient", "no gsl client is found");
		return
	else
		msg_data = msg_data or {};
		msg_data.type = msg_type;
		self.client:SendRealtimeMessage("battle", msg_data);
	end
end

-- we received a message from the battle server. 
function GSL_BattleClient:OnReceiveMessage(msg)
	if(not msg) then return end

	if(self.debug_stream) then
		LOG.std(nil, "debug", "battleclient", "nid: %s received msg: %s", tostring(System.User.nid), commonlib.serialize_compact(msg));
	end	
	local msg_type = msg.type;
	
	-- this is a new translated message for "normal_update" event, if nil, the original message will be used. 
	local new_msg; 

	if(msg_type == BattleMSG.BATTLE_REQUEST) then
		-- from server to client: 
	end
	self:FireEvent({type="realtime_update", msg = msg})
end

-- we received a message from the battle server. 
function GSL_BattleClient:OnNormalUpdateMessage(sagent)
	if(self.debug_stream) then
		LOG.std(nil, "debug", "battleclient", "normal update received");
	end	
	local bf = self.bf;
	local raw_bf = self.raw_bf;
	
	-- normal update from server
	raw_bf.score0 = sagent:GetValue("score0");
	bf.score_side0 = raw_bf.score0;
	raw_bf.score1 = sagent:GetValue("score1");
	bf.score_side1 = raw_bf.score1;

	-- comma separated nid strings of each side
	local side0 = sagent:GetValue("side0");
	local side1 = sagent:GetValue("side1");
	if(side0~=raw_bf.side0 or side1~=raw_bf.side1) then
		raw_bf.side0 = side0;
		raw_bf.side1 = side1;
		bf:from_side_string(side0, side1);
	end

	-- resource point cursor location
	raw_bf.rp1 = sagent:GetValue("rp1");
	raw_bf.rp2 = sagent:GetValue("rp2");
	raw_bf.rp3 = sagent:GetValue("rp3");
	raw_bf.rp4 = sagent:GetValue("rp4");
	raw_bf.rp5 = sagent:GetValue("rp5");
	bf:get_resource_point(1):from_data(raw_bf.rp1);
	bf:get_resource_point(2):from_data(raw_bf.rp2);
	bf:get_resource_point(3):from_data(raw_bf.rp3);
	bf:get_resource_point(4):from_data(raw_bf.rp4);
	bf:get_resource_point(5):from_data(raw_bf.rp5);
	bf:update_tower_count()
	raw_bf.is_started = sagent:GetValue("is_started");
	bf.is_started = raw_bf.is_started;
	raw_bf.start_count_down = sagent:GetValue("start_count_down");
	bf.start_count_down = raw_bf.start_count_down;
	raw_bf.is_finished = sagent:GetValue("is_finished");
	bf.is_finished = raw_bf.is_finished;
	raw_bf.winning_score = sagent:GetValue("winning_score");
	bf.winning_score = raw_bf.winning_score;
	raw_bf.battle_stat = sagent:GetValue("battle_stat");
	bf.battle_stat = raw_bf.battle_stat;
	if(System.options.version == "kids") then
		if(bf.is_finished) then
			raw_bf.finished_fighting_spirit_stat = sagent:GetValue("finished_fighting_spirit_stat");
			bf.finished_fighting_spirit_stat = raw_bf.finished_fighting_spirit_stat;
		else
			raw_bf.battle_fighting_spirit_stat = sagent:GetValue("battle_fighting_spirit_stat");
			bf.battle_fighting_spirit_stat = raw_bf.battle_fighting_spirit_stat;	
		end
	end

	self:FireEvent({type="normal_update", bf = bf, raw_bf = raw_bf})
end