--[[
Title: 
Author(s): Leio
Date: 2011/02/18
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/CombatRoom/CombatRoomClient.lua");
------------------------------------------------------------
]]
-- create class
local CombatRoomClient = {};
Map3DSystem.GSL.client.config:RegisterNPCTemplate("combatroom", CombatRoomClient)

NPL.load("(gl)script/apps/Aries/ServerObjects/CombatRoom/CombatRoomClientLogics.lua");
local CombatRoomClientLogics = commonlib.gettable("MyCompany.Aries.ServerObjects.CombatRoomClientLogics");

local string_find = string.find;
local string_match = string.match;

function CombatRoomClient.DoFunction(msg)
	local self = CombatRoomClient;
	if(not msg)then return end	
	local func_str,args_str = string_match(msg, "^%[Aries%]%[CombatRoom%]%[(.-)%]%[(.-)%]$");
	LOG.std("", "info","CombatRoomClient.DoFunction",{func_str = func_str, args_str = args_str});
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
function CombatRoomClient.MsgProc(msg)
	local self = CombatRoomClient;
	if(not msg)then return end
	if(string_find(msg, "%[Aries%]%[CombatRoom%]") == 1) then
		self.DoFunction(msg);
	end
end
function CombatRoomClient.CreateInstance(self)
	self.OnNetReceive = CombatRoomClient.OnNetReceive;
	-- uncomment to overwrite default AddRealtimeMessage implementation, such as adding a message compression layer.
	-- self.AddRealtimeMessage = MyEchoNPC_server.AddRealtimeMessage;
end

-- whenever an instance of this server agent calls AddRealtimeMessage() on the server side(from_nid), the client will receive it via this event callback. 
-- if msg is nil, it means that client has received a normal update of this agent from server and some data fields of the agent have been updated. 
function CombatRoomClient:OnNetReceive(client, msgs)
	-- the following are only debug purpose loads, the aries related files are loaded right after startup
	if(client and msgs) then
		local _, msg;
		for _, msg in ipairs(msgs) do
			
			CombatRoomClient.MsgProc(msg);		
		end
	elseif(msgs == nil) then
		
	end
end