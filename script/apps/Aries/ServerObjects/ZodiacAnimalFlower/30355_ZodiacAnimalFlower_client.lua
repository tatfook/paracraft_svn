--[[
Title: 
Author(s):  WangTian
Date: 2009/4/7
Desc: Project Aries app_main
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/ZodiacAnimalFlower/30355_ZodiacAnimalFlower_client.lua");
------------------------------------------------------------
]]


-------------------------------------
-- a special client NPC on behalf of a server agent, it just shows what is received.
-------------------------------------
local ZodiacAnimalFlower_client = {};

Map3DSystem.GSL.client.config:RegisterNPCTemplate("zodiacanimalflower", ZodiacAnimalFlower_client)

function ZodiacAnimalFlower_client.CreateInstance(self)
	self.OnNetReceive = ZodiacAnimalFlower_client.OnNetReceive;
	-- uncomment to overwrite default AddRealtimeMessage implementation, such as adding a message compression layer.
	-- self.AddRealtimeMessage = MyEchoNPC_server.AddRealtimeMessage;
	
	-- TODO: add your proviate per instance data here
	self.private_data = {some_per_instance_data_here};
end

-- whenever an instance of this server agent calls AddRealtimeMessage() on the server side(from_nid), the client will receive it via this event callback. 
-- if msg is nil, it means that client has received a normal update of this agent from server and some data fields of the agent have been updated. 
function ZodiacAnimalFlower_client:OnNetReceive(client, msgs)
	
	-- the following are only debug purpose loads, the aries related files are loaded right after startup
	NPL.load("(gl)script/apps/Aries/app_main.lua");
	NPL.load("(gl)script/apps/Aries/Quest/NPC.lua");
	NPL.load("(gl)script/apps/Aries/Pet/main.lua");
	NPL.load("(gl)script/apps/Aries/Scene/EffectManager.lua");
	NPL.load("(gl)script/apps/Aries/NPCs/RockyForest/30355_AnimalFlower.lua");
	
	if(client and msgs) then
		local _, msg;
		for _, msg in ipairs(msgs) do
			if(string.find(msg, "%[Aries%]") == 1) then
				-- flower open
				local random_animal = string.match(msg, "^%[Aries%]%[ServerObject30355%]FlowerOpen:(%d+)$");
				if(random_animal) then
					local ZodiacAnimalFlower = commonlib.getfield("MyCompany.Aries.Quest.NPCs.AnimalFlower");
					if(ZodiacAnimalFlower) then
						ZodiacAnimalFlower.FlowerOpen(random_animal);
					end
				end
				-- flower close
				local bFlowerClose = string.find(msg, "^%[Aries%]%[ServerObject30355%]FlowerClose$");
				if(bFlowerClose) then
					local ZodiacAnimalFlower = commonlib.getfield("MyCompany.Aries.Quest.NPCs.AnimalFlower");
					if(ZodiacAnimalFlower) then
						ZodiacAnimalFlower.FlowerClose();
					end
				end
			end
		end
	elseif(msgs == nil) then
		local bloomperiod_opentime = self:GetValue("bloomperiod_opentime");
		local ZodiacAnimalFlower = commonlib.getfield("MyCompany.Aries.Quest.NPCs.AnimalFlower");
		if(ZodiacAnimalFlower) then
			ZodiacAnimalFlower.Bloomperiod_Opentime(bloomperiod_opentime);
		end
		
		local random_animal = self:GetValue("random_animal");
		random_animal = tonumber(random_animal);
		local ZodiacAnimalFlower = commonlib.getfield("MyCompany.Aries.Quest.NPCs.AnimalFlower");
		if(ZodiacAnimalFlower and random_animal) then
			ZodiacAnimalFlower.SetRandomAnimal(random_animal);
		end
		
		-- NOTE: this is tricky that we assume the value of "bloomed" and "random_animal" are modified at the same time on the server
		local bBloomed = self:GetValue("bloomed");
		if(bBloomed == "true") then
			bBloomed = true;
		elseif(bBloomed == "false") then
			bBloomed = false;
		end
		local ZodiacAnimalFlower = commonlib.getfield("MyCompany.Aries.Quest.NPCs.AnimalFlower");
		if(ZodiacAnimalFlower) then
			ZodiacAnimalFlower.SetFlowerState(bBloomed);
		end
		
	end
	
	-- self:AddRealTimeMessage(self.id, msg);
	
	-- one can send real time message to self.id on the server side. 
	-- self:GetValue();
end

--function DanceParty_client.TryPickObject(instance_id)
	--client:AddRealtimeMessage("[Aries][ServerObject30186]TryPickObj:"..instance_id);
--end