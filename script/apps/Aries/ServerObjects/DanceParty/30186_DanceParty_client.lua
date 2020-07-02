--[[
Title: 
Author(s):  WangTian
Date: 2009/4/7
Desc: Project Aries app_main
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/DanceParty/30186_DanceParty_client.lua");
------------------------------------------------------------
]]


-------------------------------------
-- a special client NPC on behalf of a server agent, it just shows what is received.
-------------------------------------
local DanceParty_client = {};

Map3DSystem.GSL.client.config:RegisterNPCTemplate("danceparty", DanceParty_client)

--local instances = {};
--local instance_range = {1, 18};
local arenas = {
			[1] = {current_nid = 0, nextclear_time = nil, last_nid = nil, }, -- robot dancer
			[2] = {current_nid = 0, nextclear_time = nil, last_nid = nil},
			[3] = {current_nid = 0, nextclear_time = nil, last_nid = nil},
			[4] = {current_nid = 0, nextclear_time = nil, last_nid = nil},
			[5] = {current_nid = 0, nextclear_time = nil, last_nid = nil},
			[6] = {current_nid = 0, nextclear_time = nil, last_nid = nil},
			[7] = {current_nid = 0, nextclear_time = nil, last_nid = nil},
			[8] = {current_nid = 0, nextclear_time = nil, last_nid = nil},
			[9] = {current_nid = 0, nextclear_time = nil, last_nid = nil},
			[10] = {current_nid = 0, nextclear_time = nil, last_nid = nil},
			[11] = {current_nid = 0, nextclear_time = nil, last_nid = nil}, -- twist dancer
			[12] = {current_nid = 0, nextclear_time = nil, last_nid = nil},
			[13] = {current_nid = 0, nextclear_time = nil, last_nid = nil},
			[14] = {current_nid = 0, nextclear_time = nil, last_nid = nil},
			[15] = {current_nid = 0, nextclear_time = nil, last_nid = nil},
			[16] = {current_nid = 0, nextclear_time = nil, last_nid = nil},
			[17] = {current_nid = 0, nextclear_time = nil, last_nid = nil}, -- thomas dancer
			[18] = {current_nid = 0, nextclear_time = nil, last_nid = nil},
		};
local arena_count = #arenas;

local dance_duration = 60000;
local dance_interval = 60000;


function DanceParty_client.CreateInstance(self)
	self.OnNetReceive = DanceParty_client.OnNetReceive;
	-- uncomment to overwrite default AddRealtimeMessage implementation, such as adding a message compression layer.
	-- self.AddRealtimeMessage = MyEchoNPC_server.AddRealtimeMessage;
	
	-- TODO: add your proviate per instance data here
	self.private_data = {some_per_instance_data_here};
end

-- whenever an instance of this server agent calls AddRealtimeMessage() on the server side(from_nid), the client will receive it via this event callback. 
-- if msg is nil, it means that client has received a normal update of this agent from server and some data fields of the agent have been updated. 
function DanceParty_client:OnNetReceive(client, msgs)
	
	-- the following are only debug purpose loads, the aries related files are loaded right after startup
	NPL.load("(gl)script/apps/Aries/app_main.lua");
	NPL.load("(gl)script/apps/Aries/Quest/NPC.lua");
	NPL.load("(gl)script/apps/Aries/Pet/main.lua");
	NPL.load("(gl)script/apps/Aries/Scene/EffectManager.lua");
	NPL.load("(gl)script/apps/Aries/NPCs/FriendshipPark/30186_DanceParty.lua");
	
	
	
	if(MyCompany.Aries.Quest.NPCs.DanceParty.inited ~= true) then
		MyCompany.Aries.Quest.NPCs.DanceParty.inited = true;
		MyCompany.Aries.Quest.NPCs.DanceParty.main();
	end
	
	
	
	if(client and msgs) then
		local _, msg;
		for _, msg in ipairs(msgs) do
			if(string.find(msg, "%[Aries%]") == 1) then
				-- update the arena value
				local arenas_value = string.match(msg, "^%[Aries%]%[ServerObject30186%]arenas:([,01]+)$");
				if(arenas_value) then
					local start = 1;
					local finish = #arenas;
					local index = start;
					local exist;
					for exist in string.gfind(arenas_value, "([^,]+)") do
						local DanceParty = commonlib.getfield("MyCompany.Aries.Quest.NPCs.DanceParty");
						if(DanceParty) then
							if(exist == "1") then
								DanceParty.RefreshDancingAura(index);
							elseif(exist == "0") then
								DanceParty.RefreshEmptyAura(index);
							end
						end
						index = index + 1;
						if(index > finish) then
							break;
						end
					end
				end
				-- dance on arena
				local arena_id = string.match(msg, "^%[Aries%]%[ServerObject30186%]startdance:(%d+)$");
				if(arena_id) then
					arena_id = tonumber(arena_id);
					local DanceParty = commonlib.getfield("MyCompany.Aries.Quest.NPCs.DanceParty");
					if(DanceParty) then
						DanceParty.StartDance(arena_id);
					end
				end
				-- walk off the arena if the dance is cancelled
				local arena_id = string.match(msg, "^%[Aries%]%[ServerObject30186%]walkoff:(%d+)$");
				if(arena_id) then
					arena_id = tonumber(arena_id);
					local DanceParty = commonlib.getfield("MyCompany.Aries.Quest.NPCs.DanceParty");
					if(DanceParty) then
						DanceParty.CancelDance(arena_id);
					end
				end
				-- walk off the arena and receive reward
				local arena_id = string.match(msg, "^%[Aries%]%[ServerObject30186%]walkoffandrecvreward:(%d+)$");
				if(arena_id) then
					arena_id = tonumber(arena_id);
					local DanceParty = commonlib.getfield("MyCompany.Aries.Quest.NPCs.DanceParty");
					if(DanceParty) then
						DanceParty.WalkoffAndRecvReward(arena_id);
					end
				end
				-- already other dancer on floor
				local bDancerOnFloor = string.find(msg, "^%[Aries%]%[ServerObject30186%]danceronfloor$");
				if(bDancerOnFloor) then
					local DanceParty = commonlib.getfield("MyCompany.Aries.Quest.NPCs.DanceParty");
					if(DanceParty) then
						DanceParty.DancerAlreadyOnFloor();
					end
				end
			end
		end
	elseif(msgs == nil) then
		local arenas_value = self:GetValue("arenas");
		local start = 1;
		local finish = #arenas;
		local index = start;
		local exist;
		for exist in string.gfind(arenas_value, "([^,]+)") do
			local DanceParty = commonlib.getfield("MyCompany.Aries.Quest.NPCs.DanceParty");
			if(DanceParty) then
				if(exist == "1") then
					DanceParty.RefreshDancingAura(index);
				elseif(exist == "0") then
					DanceParty.RefreshEmptyAura(index);
				end
			end
			index = index + 1;
			if(index > finish) then
				break;
			end
		end
	end
	
	-- self:AddRealTimeMessage(self.id, msg);
	
	-- one can send real time message to self.id on the server side. 
	-- self:GetValue();
end

--function DanceParty_client.TryPickObject(instance_id)
	--client:AddRealtimeMessage("[Aries][ServerObject30186]TryPickObj:"..instance_id);
--end