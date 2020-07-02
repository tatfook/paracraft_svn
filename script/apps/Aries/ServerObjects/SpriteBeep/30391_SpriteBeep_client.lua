--[[
Title: 
Author(s):  Leio
Date: 2010/04/24
Desc: Project Aries app_main
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/SpriteBeep/30391_SpriteBeep_client.lua");
------------------------------------------------------------
]]


-------------------------------------
-- a special client NPC on behalf of a server agent, it just shows what is received.
-------------------------------------
local SpriteBeep_client = {};

Map3DSystem.GSL.client.config:RegisterNPCTemplate("spritebeep", SpriteBeep_client)

local static_hole_num = 6;

function SpriteBeep_client.CreateInstance(self)
	self.OnNetReceive = SpriteBeep_client.OnNetReceive;
	-- uncomment to overwrite default AddRealtimeMessage implementation, such as adding a message compression layer.
	-- self.AddRealtimeMessage = MyEchoNPC_server.AddRealtimeMessage;
end

-- whenever an instance of this server agent calls AddRealtimeMessage() on the server side(from_nid), the client will receive it via this event callback. 
-- if msg is nil, it means that client has received a normal update of this agent from server and some data fields of the agent have been updated. 
function SpriteBeep_client:OnNetReceive(client, msgs)
	
	-- the following are only debug purpose loads, the aries related files are loaded right after startup
	NPL.load("(gl)script/apps/Aries/app_main.lua");
	NPL.load("(gl)script/apps/Aries/Quest/NPC.lua");
	NPL.load("(gl)script/apps/Aries/Pet/main.lua");
	NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30391_SpriteBeep.lua");
	
	if(client and msgs) then
		local _, msg;
		for _, msg in ipairs(msgs) do
			if(string.find(msg, "%[Aries%]") == 1) then
				local id,place_index,tooltip_index = string.match(msg, "^%[Aries%]%[ServerObject30391%]CreateSpriteImmde:(%d+):(%d+):(%d+)$");
				id = tonumber(id);
				place_index = tonumber(place_index);
				tooltip_index = tonumber(tooltip_index);
				if(id and place_index and tooltip_index)then
					local SpriteBeep = commonlib.getfield("MyCompany.Aries.Quest.NPCs.SpriteBeep");
					if(SpriteBeep) then
						SpriteBeep.CreateSprite(id,place_index,tooltip_index)
					end
				end
				local id,place_index = string.match(msg, "^%[Aries%]%[ServerObject30391%]DestroyInstance:(%d+):(%d+)$");
				local SpriteBeep = commonlib.getfield("MyCompany.Aries.Quest.NPCs.SpriteBeep");
				id = tonumber(id);
				place_index = tonumber(place_index);
				if(SpriteBeep) then
					SpriteBeep.DestroyInstance(id,place_index);
				end
				
			end
		end
	elseif(msgs == nil) then
		local k;
		for k = 1 ,35 do
			SpriteBeep_client.CreateSprite(self,k,static_hole_num);
		end
	end
end
function SpriteBeep_client.CreateSprite(client,place_square,len)
	if(not client or not place_square or not len)then return end
	local place_index;
	for place_index = 1, len do
		local item = client:GetValue("CreateSprite:"..place_square..":"..place_index);
		if(item) then
			local SpriteBeep = commonlib.getfield("MyCompany.Aries.Quest.NPCs.SpriteBeep");
			if(SpriteBeep)then
				local tooltip_index = item.tooltip_index;
				SpriteBeep.CreateSprite(place_square,place_index,tooltip_index);
			end
		end
	end
end
