--[[
Title: Quest Client
Author(s): 
Date: 2010/8/21
Desc: This is the client side server object for communicating with the game server. It also provides data interface for client side UI and NPC rendering. 
QuestClient needs to translate some quest replies to standard rest API replies locally, so that the client item interface can be synchronized with the game server. 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Quest/QuestClient.lua");
------------------------------------------------------------
]]

-- create class
local QuestClient = commonlib.gettable("MyCompany.Aries.Quest.QuestClient");
Map3DSystem.GSL.client.config:RegisterNPCTemplate("quest", QuestClient)
NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
NPL.load("(gl)script/apps/Aries/UserBag/UserClientMemory.lua");
local UserClientMemory = commonlib.gettable("MyCompany.Aries.Inventory.UserClientMemory");

local string_find = string.find;
local string_match = string.match;

function QuestClient.DoFunction(msg)
	local self = QuestClient;
	if(not msg)then return end	
	local func_str,args_str = string_match(msg, "^%[Aries%]%[Quest%]%[(.-)%]%[(.-)%]$");
	LOG.std("", "info","QuestClient.DoFunction",{func_str = func_str, args_str = args_str});
	if(func_str)then
		local func = commonlib.getfield(func_str);
		if(func)then
			local args;
			if(args_str)then
				args = commonlib.LoadTableFromString(args_str);
			end
			func(args);
		else
			LOG.std("", "info","QuestClient.DoFunction func is nil",{func_str = func_str, args_str = args_str});
		end
	end
end
function QuestClient.MsgProc(msg)
	local self = QuestClient;
	if(not msg)then return end
	if(string_find(msg, "%[Aries%]%[Quest%]") == 1) then
		self.DoFunction(msg);
	end
end
function QuestClient.CreateInstance(self)
	self.OnNetReceive = QuestClient.OnNetReceive;
	commonlib.echo("=========QuestClient.CreateInstance");
	-- uncomment to overwrite default AddRealtimeMessage implementation, such as adding a message compression layer.
	-- self.AddRealtimeMessage = MyEchoNPC_server.AddRealtimeMessage;
end

-- whenever an instance of this server agent calls AddRealtimeMessage() on the server side(from_nid), the client will receive it via this event callback. 
-- if msg is nil, it means that client has received a normal update of this agent from server and some data fields of the agent have been updated. 
function QuestClient:OnNetReceive(client, msgs)
	
	-- the following are only debug purpose loads, the aries related files are loaded right after startup
	if(client and msgs) then
		local _, msg;
		for _, msg in ipairs(msgs) do
			QuestClient.MsgProc(msg);		
		end
	elseif(msgs == nil) then
		
	end
end