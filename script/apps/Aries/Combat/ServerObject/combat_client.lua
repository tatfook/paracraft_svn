--[[
Title: 
Author(s):  WangTian
Date: 2010/4/20
Desc: Project Aries app_main
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Combat/ServerObject/combat_client.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Combat/MsgHandler.lua");
local MsgHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");
			
-------------------------------------
-- a special client NPC on behalf of a server agent, it just shows what is received.
-------------------------------------
local combat_client = {};

Map3DSystem.GSL.client.config:RegisterNPCTemplate("aries_combat_system", combat_client);

local instances = {};
local instance_range = {1, 60};
local machines = {  {range = {1, 10}, update_count = 5, update_interval = 300000, clear_afterupdate = 240000, },
					{range = {11, 20}, update_count = 5, update_interval = 300000, clear_afterupdate = 240000, },
					{range = {21, 30}, update_count = 5, update_interval = 300000, clear_afterupdate = 240000, },
					{range = {31, 40}, update_count = 5, update_interval = 360000, clear_afterupdate = 300000, },
					{range = {41, 50}, update_count = 5, update_interval = 360000, clear_afterupdate = 300000, },
					{range = {51, 60}, update_count = 5, update_interval = 360000, clear_afterupdate = 300000, },
				};
local machine_count = #machines;

local bubblemachine_ids = {};

function combat_client.CreateInstance(self)
	self.OnNetReceive = combat_client.OnNetReceive;
	-- uncomment to overwrite default AddRealtimeMessage implementation, such as adding a message compression layer.
	-- self.AddRealtimeMessage = MyEchoNPC_server.AddRealtimeMessage;
	
	if(System.SystemInfo.GetField("name") == "Taurus") then
		NPL.load("(gl)script/apps/Aries/Combat/ObjectManager.lua");
		local ObjectManager = commonlib.gettable("MyCompany.Aries.Combat.ObjectManager");
		ObjectManager.SyncEssentialCombatResource(function() end);
	end
	
	-- TODO: add your proviate per instance data here
	self.private_data = {some_per_instance_data_here};
end

function combat_client:OnDestroy()
	
end

-- whenever an instance of this server agent calls AddRealtimeMessage() on the server side(from_nid), the client will receive it via this event callback. 
-- if msg is nil, it means that client has received a normal update of this agent from server and some data fields of the agent have been updated. 
function combat_client:OnNetReceive(client, msgs)
	
	-- the following are only debug purpose loads, the aries related files are loaded right after startup
	--NPL.load("(gl)script/apps/Aries/app_main.lua");
	--NPL.load("(gl)script/apps/Aries/Quest/NPC.lua");
	--NPL.load("(gl)script/apps/Aries/Pet/main.lua");
	--NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30301_BubbleMachine.lua");
	if(client and msgs) then
		local _, msg;
		for _, msg in ipairs(msgs) do
			
			MsgHandler.MsgProc_combat_client(msg);
			
			--if(string.find(msg, "%[Aries%]") == 1) then
				--local machine_id, instances = string.match(msg, "^%[Aries%]%[ServerObject30301%]machine(%d+):([,01]+)$");
				--if(machine_id and instances) then
					--machine_id = tonumber(machine_id);
					--local start = machines[machine_id].range[1];
					--local finish = machines[machine_id].range[2];
					--local index = start;
					--local exist;
					--for exist in string.gfind(instances, "([^,]+)") do
						--local BubbleMachine = commonlib.getfield("MyCompany.Aries.Quest.NPCs.BubbleMachine");
						--if(BubbleMachine) then
							--if(exist == "1") then
								--BubbleMachine.GenerateBubble(index);
								--BubbleMachine.CreateGiftBox(index, -10000);
							--elseif(exist == "0") then
								--BubbleMachine.DestroyGiftBox(index);
							--end
						--end
						--index = index + 1;
						--if(index > finish) then
							--break;
						--end
					--end
				--end
				--local instance_id = string.match(msg, "^%[Aries%]%[ServerObject30301%]DestroyInstance:(%d+)$");
				--if(instance_id) then
					--instance_id = tonumber(instance_id);
					--local BubbleMachine = commonlib.getfield("MyCompany.Aries.Quest.NPCs.BubbleMachine");
					--if(BubbleMachine) then
						--BubbleMachine.DestroyGiftBox(instance_id);
					--end
				--end
				--local bRecvGift = string.find(msg, "^%[Aries%]%[ServerObject30301%]RecvGift$");
				--if(bRecvGift) then
					--local BubbleMachine = commonlib.getfield("MyCompany.Aries.Quest.NPCs.BubbleMachine");
					--if(BubbleMachine) then
						--BubbleMachine.OnRecvGift();
					--end
				--end
			--end
		end
	elseif(msgs == nil) then
		MsgHandler.OnArenaNormalUpdate(self);
		--local machine_id;
		--for machine_id = 1, machine_count do
			--local instances = self:GetValue("machine"..machine_id);
			--if(instances) then
				--local start = machines[machine_id].range[1];
				--local finish = machines[machine_id].range[2];
				--local index = start;
				--local exist;
				--for exist in string.gfind(instances, "([^,]+)") do
					--local BubbleMachine = commonlib.getfield("MyCompany.Aries.Quest.NPCs.BubbleMachine");
					--if(BubbleMachine) then
						--if(exist == "1") then
							--BubbleMachine.CreateGiftBox(index);
						--elseif(exist == "0") then
							--BubbleMachine.DestroyGiftBox(index);
						--end
					--end
					--index = index + 1;
					--if(index > finish) then
						--break;
					--end
				--end
			--end
		--end
	end
	
	-- self:AddRealTimeMessage(self.id, msg);
	
	-- one can send real time message to self.id on the server side. 
	-- self:GetValue();
end

--function combat_client.TryPickObject(instance_id)
	--client:AddRealtimeMessage("[Aries][ServerObject30301]TryPickObj:"..instance_id);
--end