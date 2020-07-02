--[[
Title: 
Author(s): Leio
Date: 2012/02/22
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/Gatherer/GathererClient.lua");
------------------------------------------------------------
]]
-- create class
local GathererClient = {};
Map3DSystem.GSL.client.config:RegisterNPCTemplate("gatherer", GathererClient)

NPL.load("(gl)script/apps/Aries/ServerObjects/Gatherer/GathererClientLogics.lua");
local GathererClientLogics = commonlib.gettable("MyCompany.Aries.ServerObjects.GathererClientLogics");

local string_find = string.find;
local string_match = string.match;

function GathererClient.DoFunction(msg)
	local self = GathererClient;
	if(not msg)then return end	
	local func_str,args_str = string_match(msg, "^%[Aries%]%[Gatherer%]%[(.-)%]%[(.-)%]$");
	LOG.std("", "info","GathererClient.DoFunction",{func_str = func_str, args_str = args_str});
	if(func_str)then
		local func = commonlib.getfield(func_str);
		if(func)then
			local args;
			if(args_str)then
				args = commonlib.LoadTableFromString(args_str);
			end
			func(args);
		end
	end
end
function GathererClient.MsgProc(msg)
	local self = GathererClient;
	if(not msg)then return end
	if(string_find(msg, "%[Aries%]%[Gatherer%]") == 1) then
		self.DoFunction(msg);
	end
end
function GathererClient.CreateInstance(self)
	self.OnNetReceive = GathererClient.OnNetReceive;
	-- uncomment to overwrite default AddRealtimeMessage implementation, such as adding a message compression layer.
	-- self.AddRealtimeMessage = MyEchoNPC_server.AddRealtimeMessage;
end

-- whenever an instance of this server agent calls AddRealtimeMessage() on the server side(from_nid), the client will receive it via this event callback. 
-- if msg is nil, it means that client has received a normal update of this agent from server and some data fields of the agent have been updated. 
function GathererClient:OnNetReceive(client, msgs)
	-- the following are only debug purpose loads, the aries related files are loaded right after startup
	if(client and msgs) then
		local _, msg;
		for _, msg in ipairs(msgs) do
			
			GathererClient.MsgProc(msg);		
		end
	elseif(msgs == nil) then
	end
end