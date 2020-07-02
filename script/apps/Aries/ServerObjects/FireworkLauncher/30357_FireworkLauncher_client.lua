--[[
Title: 
Author(s):  WangTian
Date: 2009/4/7
Desc: Project Aries app_main
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/FireworkLauncher/30357_FireworkLauncher_client.lua");
------------------------------------------------------------
]]


-------------------------------------
-- a special client NPC on behalf of a server agent, it just shows what is received.
-------------------------------------
local FireworkLauncher_client = {};

Map3DSystem.GSL.client.config:RegisterNPCTemplate("fireworklauncher", FireworkLauncher_client)

-- firework launcher setup
local instance_joybean_count_per_launcher = 20;
local launcher_count = 3;
-- joybean instances
local instances_joybean = {};
local instances_joybean_range = {1, instance_joybean_count_per_launcher * launcher_count};

---- joybean instances
--local instances_joybean = {};
--local instances_joybean_range = {1, 80};
--local instances_joybean_update_count = 30;


function FireworkLauncher_client.CreateInstance(self)
	self.OnNetReceive = FireworkLauncher_client.OnNetReceive;
	-- uncomment to overwrite default AddRealtimeMessage implementation, such as adding a message compression layer.
	-- self.AddRealtimeMessage = MyEchoNPC_server.AddRealtimeMessage;
	
	-- TODO: add your proviate per instance data here
	self.private_data = {some_per_instance_data_here};
end

-- whenever an instance of this server agent calls AddRealtimeMessage() on the server side(from_nid), the client will receive it via this event callback. 
-- if msg is nil, it means that client has received a normal update of this agent from server and some data fields of the agent have been updated. 
function FireworkLauncher_client:OnNetReceive(client, msgs)
	
	-- the following are only debug purpose loads, the aries related files are loaded right after startup
	NPL.load("(gl)script/apps/Aries/app_main.lua");
	NPL.load("(gl)script/apps/Aries/Quest/NPC.lua");
	NPL.load("(gl)script/apps/Aries/Pet/main.lua");
	NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30357_FireworkLauncher.lua");
	
	--local param = {
		--name = "Ñ©ÈË",
		--position = { 20115.630859375, 0.37529653310776, 19743.923828125 },
		--facing = 2.9565315246582,
		--scaling = 1,
		--scaling_char = 0.001,
		--scaling_model = 1,
		--directscaling = true,
		--isalwaysshowheadontext = false,
		--assetfile_char = "character/common/dummy/cube_size/cube_size.x",
		--assetfile_model = "model/06props/v5/03quest/SnowMen/SnowMan_Yellow.x",
		--main_script = "script/apps/Aries/NPCs/TownSquare/30318_SnowMan.lua",
		--main_function = "MyCompany.Aries.Quest.NPCs.SnowMan.main();",
		--on_timer = ";MyCompany.Aries.Quest.NPCs.SnowMan.On_Timer();",
		--selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
		--isdummy = true,
	--};
	--
	--local gift = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30318);
	--if(gift and gift:IsValid() == true) then
	--else
		--local box, boxModel = MyCompany.Aries.Quest.NPC.CreateNPCCharacter(30318, param);
	--end
	--
	if(client and msgs) then
		local _, msg;
		for _, msg in ipairs(msgs) do
			if(string.find(msg, "%[Aries%]") == 1) then
				local instance_id = string.match(msg, "^%[Aries%]%[ServerObject30357%]DestroyJoybean:(%d+)$");
				if(instance_id) then
					instance_id = tonumber(instance_id);
					local FireworkLauncher = commonlib.getfield("MyCompany.Aries.Quest.NPCs.FireworkLauncher");
					if(FireworkLauncher) then
						FireworkLauncher.DestroyJoybean(instance_id);
					end
				end
				local bRecvJoybean = string.find(msg, "^%[Aries%]%[ServerObject30357%]RecvJoybean$");
				if(bRecvJoybean) then
					local FireworkLauncher = commonlib.getfield("MyCompany.Aries.Quest.NPCs.FireworkLauncher");
					if(FireworkLauncher) then
						FireworkLauncher.OnRecvJoybean();
					end
				end
				local bNotReady = string.find(msg, "^%[Aries%]%[ServerObject30357%]NotReady$");
				if(bNotReady) then
					local FireworkLauncher = commonlib.getfield("MyCompany.Aries.Quest.NPCs.FireworkLauncher");
					if(FireworkLauncher) then
						FireworkLauncher.OnNotReady();
					end
				end
				local nLauncher = string.match(msg, "^%[Aries%]%[ServerObject30357%]PopJoybeans:(%d+)$");
				if(nLauncher) then
					nLauncher = tonumber(nLauncher);
					local FireworkLauncher = commonlib.getfield("MyCompany.Aries.Quest.NPCs.FireworkLauncher");
					if(FireworkLauncher) then
						FireworkLauncher.LaunchFirework(nLauncher);
						local start = instance_joybean_count_per_launcher * (nLauncher - 1) + 1;
						local finish = instance_joybean_count_per_launcher * nLauncher;
						local index;
						for index = start, finish do
							FireworkLauncher.CreateJoybean(index);
							FireworkLauncher.ThrowJoybean(index);
						end
					end
				end
			end
		end
	elseif(msgs == nil) then
		local FireworkLauncher = commonlib.getfield("MyCompany.Aries.Quest.NPCs.FireworkLauncher");
		if(FireworkLauncher) then
			local instances_joybean = self:GetValue("joybeans");
			if(instances_joybean) then
				local start = instances_joybean_range[1];
				local finish = instances_joybean_range[2];
				local index = start;
				local exist;
				for exist in string.gfind(instances_joybean, "([^,]+)") do
					if(exist == "1") then
						FireworkLauncher.CreateJoybean(index);
					elseif(exist == "0") then
						FireworkLauncher.DestroyJoybean(index);
					end
					index = index + 1;
					if(index > finish) then
						break;
					end
				end
			end
		end
	end
	
	-- self:AddRealTimeMessage(self.id, msg);
	
	-- one can send real time message to self.id on the server side. 
	-- self:GetValue();
end

--function FireworkLauncher_client.TryPickObject(instance_id)
	--client:AddRealtimeMessage("[Aries][ServerObject30357]TryPickObj:"..instance_id);
--end