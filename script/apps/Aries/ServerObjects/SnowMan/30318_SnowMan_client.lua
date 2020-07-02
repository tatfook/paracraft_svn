--[[
Title: 
Author(s):  WangTian
Date: 2009/4/7
Desc: Project Aries app_main
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/SnowMan/30318_SnowMan_client.lua");
------------------------------------------------------------
]]

-------------------------------------
-- a special client NPC on behalf of a server agent, it just shows what is received.
-------------------------------------
local SnowMan_client = {};

Map3DSystem.GSL.client.config:RegisterNPCTemplate("snowman", SnowMan_client)

-- gift instances
local instances_gift = {};
local instances_gift_range = {1, 45};
local instances_gift_update_count = 30;

-- joybean instances
local instances_joybean = {};
local instances_joybean_range = {1, 45};
local instances_joybean_update_count = 30;

local SnowMan_ids = {};

function SnowMan_client.CreateInstance(self)
	self.OnNetReceive = SnowMan_client.OnNetReceive;
	-- uncomment to overwrite default AddRealtimeMessage implementation, such as adding a message compression layer.
	-- self.AddRealtimeMessage = MyEchoNPC_server.AddRealtimeMessage;
	
	SnowMan_ids[self.id] = self;
	
	-- TODO: add your proviate per instance data here
	self.private_data = {some_per_instance_data_here};
end

-- whenever an instance of this server agent calls AddRealtimeMessage() on the server side(from_nid), the client will receive it via this event callback. 
-- if msg is nil, it means that client has received a normal update of this agent from server and some data fields of the agent have been updated. 
function SnowMan_client:OnNetReceive(client, msgs)
	
	-- the following are only debug purpose loads, the aries related files are loaded right after startup
	NPL.load("(gl)script/apps/Aries/app_main.lua");
	NPL.load("(gl)script/apps/Aries/Quest/NPC.lua");
	NPL.load("(gl)script/apps/Aries/Pet/main.lua");
	NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30318_SnowMan.lua");
	
	local param = {
		name = "雪人",
		position = { 20115.630859375, 0.37529653310776, 19743.923828125 },
		facing = 2.9565315246582,
		scaling = 1,
		scaling_char = 0.001,
		scaling_model = 1,
		directscaling = true,
		isalwaysshowheadontext = false,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",
		assetfile_model = "model/06props/v5/03quest/SnowMen/SnowMan_Yellow.x",
		main_script = "script/apps/Aries/NPCs/TownSquare/30318_SnowMan.lua",
		main_function = "MyCompany.Aries.Quest.NPCs.SnowMan.main();",
		on_timer = ";MyCompany.Aries.Quest.NPCs.SnowMan.On_Timer();",
		selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
		isdummy = true,
	};
	
	local gift = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30318);
	if(gift and gift:IsValid() == true) then
	else
		local box, boxModel = MyCompany.Aries.Quest.NPC.CreateNPCCharacter(30318, param);
	end
	
	if(client and msgs) then
		local _, msg;
		for _, msg in ipairs(msgs) do
			if(string.find(msg, "%[Aries%]") == 1) then
				local instance_id = string.match(msg, "^%[Aries%]%[ServerObject30318%]DestroyGift:(%d+)$");
				if(instance_id) then
					instance_id = tonumber(instance_id);
					local SnowMan = commonlib.getfield("MyCompany.Aries.Quest.NPCs.SnowMan");
					if(SnowMan) then
						SnowMan.DestroyGift(instance_id);
					end
				end
				local instance_id = string.match(msg, "^%[Aries%]%[ServerObject30318%]DestroyJoybean:(%d+)$");
				if(instance_id) then
					instance_id = tonumber(instance_id);
					local SnowMan = commonlib.getfield("MyCompany.Aries.Quest.NPCs.SnowMan");
					if(SnowMan) then
						SnowMan.DestroyJoybean(instance_id);
					end
				end
				local recvGift_id = string.match(msg, "^%[Aries%]%[ServerObject30318%]RecvGift:(%d+)$");
				if(recvGift_id) then
					recvGift_id = tonumber(recvGift_id);
					local SnowMan = commonlib.getfield("MyCompany.Aries.Quest.NPCs.SnowMan");
					if(SnowMan) then
						SnowMan.OnRecvGift(recvGift_id);
					end
				end
				local bPickedThisRound = string.find(msg, "^%[Aries%]%[ServerObject30318%]PickedThisRound$");
				if(bPickedThisRound) then
					local SnowMan = commonlib.getfield("MyCompany.Aries.Quest.NPCs.SnowMan");
					if(SnowMan) then
						SnowMan.OnPickedThisRound();
					end
				end
				local bRecvJoybean = string.find(msg, "^%[Aries%]%[ServerObject30318%]RecvJoybean$");
				if(bRecvJoybean) then
					local SnowMan = commonlib.getfield("MyCompany.Aries.Quest.NPCs.SnowMan");
					if(SnowMan) then
						SnowMan.OnRecvJoybean();
					end
				end
				local stage, instances_joybean = string.match(msg, "^%[Aries%]%[ServerObject30318%]EnterStage:(%d+)%+joybeans:([,01]+)$");
				if(stage and instances_joybean) then
					local SnowMan = commonlib.getfield("MyCompany.Aries.Quest.NPCs.SnowMan");
					if(SnowMan) then
						local start = instances_joybean_range[1];
						local finish = instances_joybean_range[2];
						local index = start;
						local exist;
						for exist in string.gfind(instances_joybean, "([^,]+)") do
							if(exist == "1") then
								SnowMan.CreateJoybean(index);
								SnowMan.ThrowJoybean(index);
							elseif(exist == "0") then
								SnowMan.DestroyJoybean(index);
							end
							index = index + 1;
							if(index > finish) then
								break;
							end
						end
						-- enter stage
						SnowMan.EnterStage(tonumber(stage));
					end
				end
				local stage, instances_gift = string.match(msg, "^%[Aries%]%[ServerObject30318%]EnterStage:(%d+)%+gifts:([,01]+)$");
				if(stage and instances_gift) then
					local SnowMan = commonlib.getfield("MyCompany.Aries.Quest.NPCs.SnowMan");
					if(SnowMan) then
						local start = instances_gift_range[1];
						local finish = instances_gift_range[2];
						local index = start;
						local exist;
						for exist in string.gfind(instances_gift, "([^,]+)") do
							if(exist == "1") then
								SnowMan.CreateGift(index);
								SnowMan.ThrowGift(index);
							elseif(exist == "0") then
								SnowMan.DestroyGift(index);
							end
							index = index + 1;
							if(index > finish) then
								break;
							end
						end
						-- enter stage
						SnowMan.EnterStage(tonumber(stage));
					end
				end
			end
		end
	elseif(msgs == nil) then
		local SnowMan = commonlib.getfield("MyCompany.Aries.Quest.NPCs.SnowMan");
		if(SnowMan) then
			-- normal updates
			local instances_gift = self:GetValue("gifts");
			if(instances_gift) then
				local start = instances_gift_range[1];
				local finish = instances_gift_range[2];
				local index = start;
				local exist;
				for exist in string.gfind(instances_gift, "([^,]+)") do
					if(exist == "1") then
						SnowMan.CreateGift(index);
					elseif(exist == "0") then
						SnowMan.DestroyGift(index);
					end
					index = index + 1;
					if(index > finish) then
						break;
					end
				end
			end
			local instances_joybean = self:GetValue("joybeans");
			if(instances_joybean) then
				local start = instances_joybean_range[1];
				local finish = instances_joybean_range[2];
				local index = start;
				local exist;
				for exist in string.gfind(instances_joybean, "([^,]+)") do
					if(exist == "1") then
						SnowMan.CreateJoybean(index);
					elseif(exist == "0") then
						SnowMan.DestroyJoybean(index);
					end
					index = index + 1;
					if(index > finish) then
						break;
					end
				end
			end
			local stage_hitcount = self:GetValue("stage_hitcount");
			if(stage_hitcount) then
				local stage, hitcount = string.match(stage_hitcount, "(%d+)%+(%d+)");
				if(stage and hitcount) then
					stage = tonumber(stage);
					hitcount = tonumber(hitcount);
					-- TODO: set the stage scale and hitcount
					SnowMan.SetStage(stage);
					SnowMan.SetHitcount(hitcount);
				end
			end
			local stage_hitcount = self:GetValue("stage_hitcount_CampfireChallenge");
			if(stage_hitcount) then
				local stage, hitcount = string.match(stage_hitcount, "(%d+)%+(%d+)");
				if(stage and hitcount) then
					stage = tonumber(stage);
					hitcount = tonumber(hitcount);
					-- TODO: set the stage scale and hitcount
					SnowMan.SetStage_Campfire(stage);
					SnowMan.SetHitcount_Campfire(hitcount);
				end
			end
		end
	end
	
	-- self:AddRealTimeMessage(self.id, msg);
	
	-- one can send real time message to self.id on the server side. 
	-- self:GetValue();
end

--function SnowMan_client.TryPickObject(instance_id)
	--client:AddRealtimeMessage("[Aries][ServerObject30318]TryPickObj:"..instance_id);
--end