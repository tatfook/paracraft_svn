--[[
Title: 
Author(s):  Leio
Date: 2010/04/24
Desc: Project Aries app_main
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/CatchFish/30388_CatchFish_client.lua");
------------------------------------------------------------
]]


-------------------------------------
-- a special client NPC on behalf of a server agent, it just shows what is received.
-------------------------------------
local CatchFish_client = {};

Map3DSystem.GSL.client.config:RegisterNPCTemplate("catchfish", CatchFish_client)


function CatchFish_client.CreateInstance(self)
	self.OnNetReceive = CatchFish_client.OnNetReceive;
	-- uncomment to overwrite default AddRealtimeMessage implementation, such as adding a message compression layer.
	-- self.AddRealtimeMessage = MyEchoNPC_server.AddRealtimeMessage;
end

-- whenever an instance of this server agent calls AddRealtimeMessage() on the server side(from_nid), the client will receive it via this event callback. 
-- if msg is nil, it means that client has received a normal update of this agent from server and some data fields of the agent have been updated. 
function CatchFish_client:OnNetReceive(client, msgs)
	
	-- the following are only debug purpose loads, the aries related files are loaded right after startup
	NPL.load("(gl)script/apps/Aries/app_main.lua");
	NPL.load("(gl)script/apps/Aries/Quest/NPC.lua");
	NPL.load("(gl)script/apps/Aries/Pet/main.lua");
	NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30388_CatchFish.lua");
	if(client and msgs) then
		local _, msg;
		for _, msg in ipairs(msgs) do
			if(string.find(msg, "%[Aries%]") == 1) then
				local CatchFish = commonlib.getfield("MyCompany.Aries.Quest.NPCs.CatchFish");
				local state = string.match(msg, "^%[Aries%]%[ServerObject30388%]CheckStartRecv:(.+)$");
				if(state)then
					if(CatchFish) then
						CatchFish.CheckStartRecv(state);
					end
				end
				local state = string.match(msg, "^%[Aries%]%[ServerObject30388%]DoStartRecv:(.+)$");
				if(state)then
					if(CatchFish) then
						CatchFish.DoStartRecv(state);
					end
				end
				local state = string.match(msg, "^%[Aries%]%[ServerObject30388%]OnTimeover:(.+)$");
				if(state)then
					if(CatchFish) then
						CatchFish.OnTimeover(state);
					end
				end
				local sec = string.match(msg, "^%[Aries%]%[ServerObject30388%]OnFramemove:(.+)$");
				sec = tonumber(sec);
				if(sec)then
					if(CatchFish) then
						CatchFish.OnFramemove(sec);
					end
				end
				local state = string.match(msg, "^%[Aries%]%[ServerObject30388%]DoQuitRecv:(.+)$");
				if(state)then
					if(CatchFish) then
						CatchFish.DoQuitRecv(state);
					end
				end
				local state = string.match(msg, "^%[Aries%]%[ServerObject30388%]DoQuitInternalRecv:(.+)$");
				if(state)then
					if(CatchFish) then
						CatchFish.DoQuitInternalRecv(state);
					end
				end
				local state = string.match(msg, "^%[Aries%]%[ServerObject30388%]DoReStartRecv:(.+)$");
				if(state)then
					if(CatchFish) then
						CatchFish.DoReStartRecv(state);
					end
				end
				local state = string.match(msg, "^%[Aries%]%[ServerObject30388%]DoAutoFishingRecv:(.+)$");
				if(state)then
					if(CatchFish) then
						CatchFish.DoAutoFishingRecv(state);
					end
				end
			end
		end
	elseif(msgs == nil) then
		
	end
end
