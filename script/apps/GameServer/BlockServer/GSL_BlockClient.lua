--[[
Title: Block Server client
Author(s): LiXizhi
Date: 2013/8/27
Desc:
-----------------------------------------------
NPL.load("(gl)script/apps/GameServer/BlockServer/GSL_BlockClient.lua");
-----------------------------------------------
]]
local tostring = tostring;
local format = format;
local type = type;

local GSL_BlockClient = commonlib.inherit(nil, commonlib.gettable("System.GSL.GSL_BlockClient"))

------------------------------
-- BlockClient: NPC client class
------------------------------
local BlockClient = {};
if(System.GSL and System.GSL.client and System.GSL.client.config) then
	System.GSL.client.config:RegisterNPCTemplate("creator", BlockClient);
end

function BlockClient.CreateInstance(self)
	self.OnNetReceive = BlockClient.OnNetReceive;
	LOG.std(nil, "system", "BlockClient",  "BlockClient.CreateInstance");
end


-- whenever an instance of this server agent calls AddRealtimeMessage() on the server side(from_nid), the client will receive it via this event callback. 
-- if msg is nil, it means that client has received a normal update of this agent from server and some data fields of the agent have been updated. 
function BlockClient:OnNetReceive(client, msgs)
	local client = GSL_BlockClient.GetSingleton()
	if(client and msgs) then
		local _, msg;
		for _, msg in ipairs(msgs) do
			client:OnReceiveMessage(msg);		
		end
	elseif(msgs == nil) then
		
	end
end

------------------------------
-- GSL_BlockClient class
------------------------------
local g_singleton;

function GSL_BlockClient:ctor()

	self.events = commonlib.EventDispatcher:new();
	-- each trade client must be associated with a gsl client object, even if none is provided.
	self:SetClient();
end

-- get the global singleton.
function GSL_BlockClient.GetSingleton()
	if(not g_singleton) then
		g_singleton = GSL_BlockClient:new();
	end
	return g_singleton;
end

-- set the gsl client object
-- @param client: if nil it is the global default client object. 
function GSL_BlockClient:SetClient(client)
	self.client = client or commonlib.gettable("System.GSL_client");
end

function GSL_BlockClient:GetClient()
	return self.client;
end


-- add a NPL call back script to a given even listener
-- there can only be one listener per type per instance. 
-- @param ListenerType: string. Currently, only "on_trade_update" is supported. 
-- @param callbackScript: the function to be called when the listener event is raised. Usually parameters are stored in a NPL parameter called "msg".
-- @param self_this: the first parameter to be passed to the callback. if nil, it will be GSL_BlockClient(self). 
function GSL_BlockClient:AddEventListener(ListenerType, callbackScript, self_this)
	self.events:AddEventListener(ListenerType, callbackScript, self_this or self);
end

-- remove a NPL call back script from a given even listener
-- @param ListenerType: string 
-- @param callbackScript: if nil, all callback of the type is removed. the script or function to be called when the listener event is raised. Usually parameters are stored in a NPL parameter called "msg".
function GSL_BlockClient:RemoveEventListener(ListenerType, callbackScript)
	self.events:RemoveEventListener(ListenerType);
end


-- clear all registered event listeners
function GSL_BlockClient:ResetAllEventListeners()
	self.events:ClearAllEvents();
end

-- fire a given event with a given msg
-- @param event. it is always a table of {type=string, ...}, where the type is the event_name, other fields will sent as they are. 
function GSL_BlockClient:FireEvent(event)
	self.events:DispatchEvent(event, self)
end

-- fire a given event with a given msg
-- @param event. it is always a table of {type=string, ...}, where the type is the event_name, other fields will sent as they are. 
function GSL_BlockClient:FireEventByType(event_type, event)
	self.events:DispatchEventByType(event_type, event, self)
end

-- send a message to server
function GSL_BlockClient:SendMessage(msg_type, msg_data)
	if(not self.client) then
		LOG.std(nil, "error", "tradeclient", "no gsl client is found");
		return
	else
		msg_data = msg_data or {};
		msg_data.type = msg_type;
		self.client:SendRealtimeMessage("trade", msg_data);
	end
end

-- we received a message from the trade server. 
function GSL_BlockClient:OnReceiveMessage(msg)
	if(not msg) then return end

	if(self.debug_stream) then
		LOG.std(nil, "debug", "GSL_BlockClient", "nid: %s received msg: %s", tostring(System.User.nid), commonlib.serialize_compact(msg));
	end	
	local msg_type = msg.type;

end

