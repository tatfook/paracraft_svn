--[[
Title: 
Author(s):  WangTian
Date: 2009/4/7
Desc: Project Aries app_main
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/WatermelonFarm/30192_WatermelonFarm_client.lua");
------------------------------------------------------------
]]


-------------------------------------
-- a special client NPC on behalf of a server agent, it just shows what is received.
-------------------------------------
local WatermelonFarm_client = {};

Map3DSystem.GSL.client.config:RegisterNPCTemplate("watermelonfarm", WatermelonFarm_client)

local holes_num = 20;

function WatermelonFarm_client.CreateInstance(self)
	self.OnNetReceive = WatermelonFarm_client.OnNetReceive;
	-- uncomment to overwrite default AddRealtimeMessage implementation, such as adding a message compression layer.
	-- self.AddRealtimeMessage = MyEchoNPC_server.AddRealtimeMessage;
end

-- whenever an instance of this server agent calls AddRealtimeMessage() on the server side(from_nid), the client will receive it via this event callback. 
-- if msg is nil, it means that client has received a normal update of this agent from server and some data fields of the agent have been updated. 
function WatermelonFarm_client:OnNetReceive(client, msgs)
	
	-- the following are only debug purpose loads, the aries related files are loaded right after startup
	NPL.load("(gl)script/apps/Aries/app_main.lua");
	NPL.load("(gl)script/apps/Aries/Quest/NPC.lua");
	NPL.load("(gl)script/apps/Aries/Pet/main.lua");
	NPL.load("(gl)script/apps/Aries/NPCs/Farm/30192_WatermelonFarm.lua");
	if(client and msgs) then
		local _, msg;
		for _, msg in ipairs(msgs) do
			if(string.find(msg, "%[Aries%]") == 1) then
				local index = string.match(msg, "^%[Aries%]%[ServerObject30192%]create_water_melon(%d+)$");
				if(index)then
					index = tonumber(index);
					local WatermelonFarm = commonlib.getfield("MyCompany.Aries.Quest.NPCs.WatermelonFarm");
					if(WatermelonFarm) then
						WatermelonFarm.CreateWatermelon(index)
					end
				end
				local instance_id = string.match(msg, "^%[Aries%]%[ServerObject30192%]DestroyInstance:(%d+)$");
				if(instance_id) then
					instance_id = tonumber(instance_id);
					local WatermelonFarm = commonlib.getfield("MyCompany.Aries.Quest.NPCs.WatermelonFarm");
					if(WatermelonFarm) then
						WatermelonFarm.DeleteWatermelon(instance_id);
					end
				end
				local bRecvWatermelon = string.find(msg, "^%[Aries%]%[ServerObject30192%]RecvWatermelon$");
				if(bRecvWatermelon) then
					local WatermelonFarm = commonlib.getfield("MyCompany.Aries.Quest.NPCs.WatermelonFarm");
					if(WatermelonFarm) then
						WatermelonFarm.OnRecvWatermelon();
					end
				end
			end
		end
	elseif(msgs == nil) then
		local index;
		for index = 1, holes_num do
			local result = self:GetValue("CreateWatermelon"..index);
			if(result and result == "true") then
				local WatermelonFarm = commonlib.getfield("MyCompany.Aries.Quest.NPCs.WatermelonFarm");
				if(WatermelonFarm)then
					WatermelonFarm.CreateWatermelon(index)
				end
			end
		end
	end
end

--Map3DSystem.GSL_client:SendRealtimeMessage("s30192", {body="[Aries][ServerObject30192]TryPickObj:1"});