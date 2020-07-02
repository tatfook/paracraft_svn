--[[
Title: 
Author(s):  WangTian
Date: 2009/4/7
Desc: Project Aries app_main
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/SkyWheel/30052_SkyWheel_client.lua");
------------------------------------------------------------
]]


-------------------------------------
-- a special client NPC on behalf of a server agent, it just shows what is received.
-------------------------------------
local SkyWheel_client = {};

Map3DSystem.GSL.client.config:RegisterNPCTemplate("skywheel", SkyWheel_client)

--local instances = {};
--local instance_range = {1, 18};
local slots = {
			[1] = {current_nid = 0, nextclear_time = nil, last_nid = nil},
			[2] = {current_nid = 0, nextclear_time = nil, last_nid = nil},
			[3] = {current_nid = 0, nextclear_time = nil, last_nid = nil},
			[4] = {current_nid = 0, nextclear_time = nil, last_nid = nil},
			[5] = {current_nid = 0, nextclear_time = nil, last_nid = nil},
			[6] = {current_nid = 0, nextclear_time = nil, last_nid = nil},
			[7] = {current_nid = 0, nextclear_time = nil, last_nid = nil},
			[8] = {current_nid = 0, nextclear_time = nil, last_nid = nil},
			[9] = {current_nid = 0, nextclear_time = nil, last_nid = nil},
			[10] = {current_nid = 0, nextclear_time = nil, last_nid = nil},
			[11] = {current_nid = 0, nextclear_time = nil, last_nid = nil},
			[12] = {current_nid = 0, nextclear_time = nil, last_nid = nil},
			--[13] = {current_nid = 0, nextclear_time = nil, last_nid = nil},
			--[14] = {current_nid = 0, nextclear_time = nil, last_nid = nil},
			--[15] = {current_nid = 0, nextclear_time = nil, last_nid = nil},
			--[16] = {current_nid = 0, nextclear_time = nil, last_nid = nil},
			--[17] = {current_nid = 0, nextclear_time = nil, last_nid = nil},
			--[18] = {current_nid = 0, nextclear_time = nil, last_nid = nil},
		};
local slot_count = #slots;

local single_duration = 3333;
local full_duration = single_duration * slot_count;


function SkyWheel_client.CreateInstance(self)
	self.OnNetReceive = SkyWheel_client.OnNetReceive;
	-- uncomment to overwrite default AddRealtimeMessage implementation, such as adding a message compression layer.
	-- self.AddRealtimeMessage = MyEchoNPC_server.AddRealtimeMessage;
	
	-- TODO: add your proviate per instance data here
	self.private_data = {some_per_instance_data_here};
end

-- whenever an instance of this server agent calls AddRealtimeMessage() on the server side(from_nid), the client will receive it via this event callback. 
-- if msg is nil, it means that client has received a normal update of this agent from server and some data fields of the agent have been updated. 
function SkyWheel_client:OnNetReceive(client, msgs)
	
	-- the following are only debug purpose loads, the aries related files are loaded right after startup
	NPL.load("(gl)script/apps/Aries/app_main.lua");
	NPL.load("(gl)script/apps/Aries/Quest/NPC.lua");
	NPL.load("(gl)script/apps/Aries/Pet/main.lua");
	NPL.load("(gl)script/apps/Aries/Scene/EffectManager.lua");
	NPL.load("(gl)script/apps/Aries/NPCs/Carnival/30052_SkyWheel.lua");
	
	
	
	if(MyCompany.Aries.Quest.NPCs.SkyWheel.inited ~= true) then
		MyCompany.Aries.Quest.NPCs.SkyWheel.inited = true;
		MyCompany.Aries.Quest.NPCs.SkyWheel.main();
	end
	
	
	
	if(client and msgs) then
		local _, msg;
		for _, msg in ipairs(msgs) do
			if(string.find(msg, "%[Aries%]") == 1) then
				-- update the slot value
				local slots_value = string.match(msg, "^%[Aries%]%[ServerObject30052%]slots:([,0123456789]+)$");
				if(slots_value) then
					local start = 1;
					local finish = slot_count;
					local index = start;
					local nid;
					for nid in string.gfind(slots_value, "([^,]+)") do
						local SkyWheel = commonlib.getfield("MyCompany.Aries.Quest.NPCs.SkyWheel");
						if(SkyWheel) then
							nid = tonumber(nid);
							if(nid == 0) then
								SkyWheel.RefreshEmptySlot(index);
							elseif(nid and nid > 0) then
								SkyWheel.RefreshMountedSlot(nid, index);
							end
						end
						index = index + 1;
						if(index > finish) then
							break;
						end
					end
				end
				-- mount on slot
				local slot_id = string.match(msg, "^%[Aries%]%[ServerObject30052%]StartMount:(%d+)$");
				if(slot_id) then
					slot_id = tonumber(slot_id);
					local SkyWheel = commonlib.getfield("MyCompany.Aries.Quest.NPCs.SkyWheel");
					if(SkyWheel) then
						SkyWheel.OnRecvStartMount(slot_id);
					end
				end
				-- already other user on slot
				local bAlreadyMounted = string.find(msg, "^%[Aries%]%[ServerObject30052%]AlreadyMounted$");
				if(bAlreadyMounted) then
					local SkyWheel = commonlib.getfield("MyCompany.Aries.Quest.NPCs.SkyWheel");
					if(SkyWheel) then
						SkyWheel.OnRecvAlreadyMounted();
					end
				end
				-- UnMount from the slot if the user is cancelled
				local slot_id = string.match(msg, "^%[Aries%]%[ServerObject30052%]UnMount:(%d+)$");
				if(slot_id) then
					slot_id = tonumber(slot_id);
					local SkyWheel = commonlib.getfield("MyCompany.Aries.Quest.NPCs.SkyWheel");
					if(SkyWheel) then
						SkyWheel.OnRecvUnMount(slot_id);
					end
				end
				-- walk off the slot and receive reward
				local slot_id = string.match(msg, "^%[Aries%]%[ServerObject30052%]UnMountAndRecvReward:(%d+)$");
				if(slot_id) then
					slot_id = tonumber(slot_id);
					local SkyWheel = commonlib.getfield("MyCompany.Aries.Quest.NPCs.SkyWheel");
					if(SkyWheel) then
						SkyWheel.OnRecvUnMountAndRecvReward(slot_id);
					end
				end
			end
		end
	elseif(msgs == nil) then
		local slots_value = self:GetValue("slots");
		if(slots_value) then
			local start = 1;
			local finish = slot_count;
			local index = start;
			local nid;
			for nid in string.gfind(slots_value, "([^,]+)") do
				local SkyWheel = commonlib.getfield("MyCompany.Aries.Quest.NPCs.SkyWheel");
				if(SkyWheel) then
					nid = tonumber(nid);
					if(nid == 0) then
						SkyWheel.RefreshEmptySlot(index);
					elseif(nid and nid > 0) then
						SkyWheel.RefreshMountedSlot(nid, index);
					end
				end
				index = index + 1;
				if(index > finish) then
					break;
				end
			end
		end
		
		local CurrentTime = self:GetValue("CurrentTime");
		local SkyWheel = commonlib.getfield("MyCompany.Aries.Quest.NPCs.SkyWheel");
		if(SkyWheel) then
			SkyWheel.OnUpdateCurrentTime(CurrentTime);
		end
		
		local remaining = self:GetValue("remaining");
		local SkyWheel = commonlib.getfield("MyCompany.Aries.Quest.NPCs.SkyWheel");
		if(SkyWheel) then
			SkyWheel.OnUpdateRemaining(remaining);
		end
	end
	
	-- self:AddRealTimeMessage(self.id, msg);
	
	-- one can send real time message to self.id on the server side. 
	-- self:GetValue();
end

--function SkyWheel_client.TryPickObject(instance_id)
	--client:AddRealtimeMessage("[Aries][ServerObject30052]TryPickObj:"..instance_id);
--end