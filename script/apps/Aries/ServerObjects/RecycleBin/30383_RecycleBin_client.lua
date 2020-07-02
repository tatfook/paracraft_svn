--[[
Title: 
Author(s):  Leio
Date: 2010/04/24
Desc: Project Aries app_main
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/RecycleBin/30383_RecycleBin_client.lua");
------------------------------------------------------------
]]


-------------------------------------
-- a special client NPC on behalf of a server agent, it just shows what is received.
-------------------------------------
local RecycleBin_client = {};

Map3DSystem.GSL.client.config:RegisterNPCTemplate("recyclebin", RecycleBin_client)


function RecycleBin_client.CreateInstance(self)
	self.OnNetReceive = RecycleBin_client.OnNetReceive;
	-- uncomment to overwrite default AddRealtimeMessage implementation, such as adding a message compression layer.
	-- self.AddRealtimeMessage = MyEchoNPC_server.AddRealtimeMessage;
end

-- whenever an instance of this server agent calls AddRealtimeMessage() on the server side(from_nid), the client will receive it via this event callback. 
-- if msg is nil, it means that client has received a normal update of this agent from server and some data fields of the agent have been updated. 
function RecycleBin_client:OnNetReceive(client, msgs)
	
	-- the following are only debug purpose loads, the aries related files are loaded right after startup
	NPL.load("(gl)script/apps/Aries/app_main.lua");
	NPL.load("(gl)script/apps/Aries/Quest/NPC.lua");
	NPL.load("(gl)script/apps/Aries/Pet/main.lua");
	NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30383_RecycleBin.lua");
	if(client and msgs) then
		local _, msg;
		for _, msg in ipairs(msgs) do
			if(string.find(msg, "%[Aries%]") == 1) then
				local place_square,place_index,prop,item_id = string.match(msg, "^%[Aries%]%[ServerObject30383%]CreateRubbishImmde:(%d+):(%d+):(%d+):(%d+)$");
				place_square = tonumber(place_square);
				place_index = tonumber(place_index);
				prop = tonumber(prop);
				item_id = tonumber(item_id);
				if(place_square and place_index and prop and item_id)then
					local RecycleBin = commonlib.getfield("MyCompany.Aries.Quest.NPCs.RecycleBin");
					if(RecycleBin) then
						RecycleBin.CreateRubbish(place_square,place_index,prop,item_id)
					end
				end
				local place_square,place_index = string.match(msg, "^%[Aries%]%[ServerObject30383%]DestroyInstance:(%d+):(%d+)$");
				local RecycleBin = commonlib.getfield("MyCompany.Aries.Quest.NPCs.RecycleBin");
				place_square = tonumber(place_square);
				place_index = tonumber(place_index);
				if(RecycleBin) then
					RecycleBin.DestroyInstance(place_square,place_index);
				end
				
				local args = string.match(msg, "^%[Aries%]%[ServerObject30383%]RecvCallBack:(.+)$");
				local RecycleBin = commonlib.getfield("MyCompany.Aries.Quest.NPCs.RecycleBin");
				if(RecycleBin) then
					RecycleBin.RecvCallBack(args);
				end
			end
		end
	elseif(msgs == nil) then
		RecycleBin_client.CreateRubbish(self,1,12);
		RecycleBin_client.CreateRubbish(self,2,12);
		RecycleBin_client.CreateRubbish(self,3,12);
	end
end
function RecycleBin_client.CreateRubbish(client,place_square,len)
	if(not client or not place_square or not len)then return end
	local place_index;
	for place_index = 1, len do
		local item = client:GetValue("CreateRubbish:"..place_square..":"..place_index);
		if(item) then
			local RecycleBin = commonlib.getfield("MyCompany.Aries.Quest.NPCs.RecycleBin");
			if(RecycleBin)then
				local prop = item.prop;
				local item_id = item.item_id;
				RecycleBin.CreateRubbish(place_square,place_index,prop,item_id)
			end
		end
	end
end
