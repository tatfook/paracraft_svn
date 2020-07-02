--[[
Title: 
Author(s):  WangTian
Date: 2009/4/7
Desc: Project Aries app_main
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/EarthQuake/30021_EarthQuake_client.lua");
------------------------------------------------------------
]]


-------------------------------------
-- a special client NPC on behalf of a server agent, it just shows what is received.
-------------------------------------
local EarthQuake_client = {};

Map3DSystem.GSL.client.config:RegisterNPCTemplate("earthquake", EarthQuake_client)

function EarthQuake_client.CreateInstance(self)
	self.OnNetReceive = EarthQuake_client.OnNetReceive;
	-- uncomment to overwrite default AddRealtimeMessage implementation, such as adding a message compression layer.
	-- self.AddRealtimeMessage = MyEchoNPC_server.AddRealtimeMessage;
	
	-- TODO: add your proviate per instance data here
	self.private_data = {some_per_instance_data_here};
end

-- whenever an instance of this server agent calls AddRealtimeMessage() on the server side(from_nid), the client will receive it via this event callback. 
-- if msg is nil, it means that client has received a normal update of this agent from server and some data fields of the agent have been updated. 
function EarthQuake_client:OnNetReceive(client, msgs)
	
	-- the following are only debug purpose loads, the aries related files are loaded right after startup
	NPL.load("(gl)script/apps/Aries/app_main.lua");
	NPL.load("(gl)script/apps/Aries/Quest/NPC.lua");
	NPL.load("(gl)script/apps/Aries/Pet/main.lua");
	NPL.load("(gl)script/apps/Aries/Scene/EffectManager.lua");
	NPL.load("(gl)script/apps/Aries/NPCs/Environment/30021_EarthQuake.lua");
	
	if(client and msgs) then
		local _, msg;
		for _, msg in ipairs(msgs) do
			if(string.find(msg, "%[Aries%]") == 1) then
				-- already other dancer on floor
				local bShakeTownAss = string.find(msg, "^%[Aries%]%[ServerObject30021%]shaketownass$");
				if(bShakeTownAss) then
					local EarthQuake = commonlib.getfield("MyCompany.Aries.Quest.NPCs.EarthQuake");
					if(EarthQuake) then
						EarthQuake.ShakeTownAss();
					end
				end
			end
		end
	elseif(msgs == nil) then
	end
	
	-- self:AddRealTimeMessage(self.id, msg);
	
	-- one can send real time message to self.id on the server side. 
	-- self:GetValue();
end

--function DanceParty_client.TryPickObject(instance_id)
	--client:AddRealtimeMessage("[Aries][ServerObject30186]TryPickObj:"..instance_id);
--end