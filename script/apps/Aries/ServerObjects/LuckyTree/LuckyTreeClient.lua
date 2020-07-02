--[[
Title: 
Author(s): Leio
Date: 2010/12/21
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/LuckyTree/LuckyTreeClient.lua");
------------------------------------------------------------
]]
-- create class
local LuckyTreeClient = {};
Map3DSystem.GSL.client.config:RegisterNPCTemplate("luckytree", LuckyTreeClient)

NPL.load("(gl)script/apps/Aries/ServerObjects/LuckyTree/LuckyTreeClientLogics.lua");
local LuckyTreeClientLogics = commonlib.gettable("MyCompany.Aries.ServerObjects.LuckyTreeClientLogics");

local string_find = string.find;
local string_match = string.match;

function LuckyTreeClient.DoFunction(msg)
	local self = LuckyTreeClient;
	if(not msg)then return end	
	local func_str,args_str = string_match(msg, "^%[Aries%]%[LuckyTree%]%[(.-)%]%[(.-)%]$");
	LOG.std("", "info","LuckyTreeClient.DoFunction",{func_str = func_str, args_str = args_str});
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
function LuckyTreeClient.MsgProc(msg)
	local self = LuckyTreeClient;
	if(not msg)then return end
	if(string_find(msg, "%[Aries%]%[LuckyTree%]") == 1) then
		self.DoFunction(msg);
	end
end
function LuckyTreeClient.CreateInstance(self)
	self.OnNetReceive = LuckyTreeClient.OnNetReceive;
	-- uncomment to overwrite default AddRealtimeMessage implementation, such as adding a message compression layer.
	-- self.AddRealtimeMessage = MyEchoNPC_server.AddRealtimeMessage;
end

-- whenever an instance of this server agent calls AddRealtimeMessage() on the server side(from_nid), the client will receive it via this event callback. 
-- if msg is nil, it means that client has received a normal update of this agent from server and some data fields of the agent have been updated. 
function LuckyTreeClient:OnNetReceive(client, msgs)
	-- the following are only debug purpose loads, the aries related files are loaded right after startup
	if(client and msgs) then
		local _, msg;
		for _, msg in ipairs(msgs) do
			
			LuckyTreeClient.MsgProc(msg);		
		end
	elseif(msgs == nil) then
		
	end
end