--[[
Title: 
Author(s):  Leio
Date: 2010/03/22
Desc: Project Aries app_main
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/OddEgg/30371_OddEgg_client.lua");
------------------------------------------------------------
]]


-------------------------------------
-- a special client NPC on behalf of a server agent, it just shows what is received.
-------------------------------------
local OddEgg_client = {};

Map3DSystem.GSL.client.config:RegisterNPCTemplate("oddegg", OddEgg_client)

local holes_num = 20;

function OddEgg_client.CreateInstance(self)
	self.OnNetReceive = OddEgg_client.OnNetReceive;
	-- uncomment to overwrite default AddRealtimeMessage implementation, such as adding a message compression layer.
	-- self.AddRealtimeMessage = MyEchoNPC_server.AddRealtimeMessage;
end

-- whenever an instance of this server agent calls AddRealtimeMessage() on the server side(from_nid), the client will receive it via this event callback. 
-- if msg is nil, it means that client has received a normal update of this agent from server and some data fields of the agent have been updated. 
function OddEgg_client:OnNetReceive(client, msgs)
	
	-- the following are only debug purpose loads, the aries related files are loaded right after startup
	NPL.load("(gl)script/apps/Aries/app_main.lua");
	NPL.load("(gl)script/apps/Aries/Quest/NPC.lua");
	NPL.load("(gl)script/apps/Aries/Pet/main.lua");
	NPL.load("(gl)script/apps/Aries/NPCs/Playground/30371_OddEgg.lua");
	if(client and msgs) then
		local _, msg;
		for _, msg in ipairs(msgs) do
			if(string.find(msg, "%[Aries%]") == 1) then
				--create egg by sever msg
				local instance_id,egg_type,gift_type = string.match(msg, "^%[Aries%]%[ServerObject30371%]CreateEggByServerMsg(%d+):(%d+):(%d+)$");
				if(instance_id and egg_type and gift_type)then
					instance_id = tonumber(instance_id);
					egg_type = tonumber(egg_type);
					gift_type = tonumber(gift_type);
					local OddEgg = commonlib.getfield("MyCompany.Aries.Quest.NPCs.OddEgg");
					if(OddEgg) then
						local args = {
							instance_id = instance_id,
							egg_type = egg_type,
							gift_type = gift_type,
						}
						OddEgg.CreateEgg(args);
					end
				end
				-- destroy instance
				local instance_id = string.match(msg, "^%[Aries%]%[ServerObject30371%]DestroyInstance:(%d+)$");
				if(instance_id) then
					instance_id = tonumber(instance_id);
					local OddEgg = commonlib.getfield("MyCompany.Aries.Quest.NPCs.OddEgg");
					if(OddEgg) then
						OddEgg.DeleteEgg(instance_id);
					end
				end
				-- rece egg
				local bRecvEgg = string.match(msg, "^%[Aries%]%[ServerObject30371%]RecvEgg$");
				if(bRecvEgg) then
					local OddEgg = commonlib.getfield("MyCompany.Aries.Quest.NPCs.OddEgg");
					if(OddEgg) then
						OddEgg.OnRecvEgg();
					end
				end
				-- can pick
				local canPick,index = string.match(msg, "^%[Aries%]%[ServerObject30371%]CanPickObj:(.+):(%d+)$");
				if(canPick and index) then
					local OddEgg = commonlib.getfield("MyCompany.Aries.Quest.NPCs.OddEgg");
					if(OddEgg) then
						OddEgg.CanPickObj(canPick,index);
					end
				end
			end
		end
	elseif(msgs == nil) then
		local index;
		for index = 1, holes_num do
			local result = self:GetValue("CreateEgg"..index);
			if(result) then
				local OddEgg = commonlib.getfield("MyCompany.Aries.Quest.NPCs.OddEgg");
				if(OddEgg)then
					if(type(result) == "table")then
						local args = {
							instance_id = result.index,
							egg_type = result.egg_type,
							gift_type = result.gift_type,
						}
						OddEgg.CreateEgg(args);
					elseif(result == "false")then
						OddEgg.DeleteEgg(index);
					end
				end
			end
		end
	end
end

--[[
Map3DSystem.GSL_client:SendRealtimeMessage("s30371", {body="[Aries][ServerObject30371]CheckCanPickObj:1"});
Map3DSystem.GSL_client:SendRealtimeMessage("s30371", {body="[Aries][ServerObject30371]TryPickObj:2"});
--]]