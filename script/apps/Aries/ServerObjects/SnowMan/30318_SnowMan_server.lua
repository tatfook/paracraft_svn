--[[
Title: Server agent template class
Author(s): 
Date: 2009/11/15
Desc: Project Aries app_main
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/SnowMan/30318_SnowMan_server.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/GameServer/GSL_config.lua");

local string_find = string.find;
local string_match = string.match;
local table_insert = table.insert;
local math_random = math.random;
local math_floor = math.floor;

-------------------------------------
-- a special server NPC that just echos whatever received. 
-------------------------------------
local SnowMan_server = {}

Map3DSystem.GSL.config:RegisterNPCTemplate("snowman", SnowMan_server)

--local instances = {};
--local instance_range = {1, 60};
--local machines = {  {range = {1, 10}, update_count = 5, update_interval = 300000, clear_afterupdate = 240000, },
					--{range = {11, 20}, update_count = 5, update_interval = 300000, clear_afterupdate = 240000, },
					--{range = {21, 30}, update_count = 5, update_interval = 300000, clear_afterupdate = 240000, },
					--{range = {31, 40}, update_count = 5, update_interval = 360000, clear_afterupdate = 300000, },
					--{range = {41, 50}, update_count = 5, update_interval = 360000, clear_afterupdate = 300000, },
					--{range = {51, 60}, update_count = 5, update_interval = 360000, clear_afterupdate = 300000, },
				--};
--local machine_count = #machines;

---- reset all instances
--local i;
--for i = instance_range[1], instance_range[2] do
	--instances[i] = 0;
--end


-- gift instances
local instances_gift = {};
local instances_gift_range = {1, 45};
local instances_gift_update_count = 30;

-- joybean instances
local instances_joybean = {};
local instances_joybean_range = {1, 45};
local instances_joybean_update_count = 30;

-- hit count
local hit_count = 0;
local hit_count_CampfireChallenge = 0;

-- reset all gift instances
local i;
for i = instances_gift_range[1], instances_gift_range[2] do
	instances_gift[i] = 0;
end

-- reset all joybean instances
local i;
for i = instances_joybean_range[1], instances_joybean_range[2] do
	instances_joybean[i] = 0;
end

local stage = 0;
local stage_CampfireChallenge = 0;

local HIT_COUNT_CAMPFIRECHALLENGE_OPEN_INSTANCE_COUNT = 200;

local stages = {
	{10, 1}, -- hitcount and gift_type: 1 for joybean, 2 for snowman
	{20, 1},
	{30, 1},
	{50, 1},
	{100, 2},
};

-- clear interval after respawn
local clear_interval = 600000;
--local clear_interval = 60000;

local next_clear_gift_time = nil;
local current_time = 0;

local next_clear_gift_time_CampfireChallenge = nil;
local clear_interval_CampfireChallenge = 5 * 60 * 1000;

function SnowMan_server.CreateInstance(self, revision)
	-- overwrite virtual functions
	self.OnNetReceive = SnowMan_server.OnNetReceive;
	self.OnFrameMove = SnowMan_server.OnFrameMove;
	-- uncomment to overwrite default AddRealtimeMessage implementation, such as adding a message compression layer.
	-- self.AddRealtimeMessage = SnowMan_server.AddRealtimeMessage;
	
	-- set init value for each machine
	self:SetValue("gifts", SnowMan_server.GetGiftValue(), revision);
	self:SetValue("joybeans", SnowMan_server.GetJoybeanValue(), revision);
	self:SetValue("stage_hitcount", SnowMan_server.GetStageValue().."+"..SnowMan_server.GetHitCount(), revision);
	
	self:SetValue("stage_hitcount_CampfireChallenge", 
		SnowMan_server.GetStageValue_CampfireChallenge().."+"..SnowMan_server.GetHitCount_CampfireChallenge(), revision);
end

-- whenever an instance of this server agent has received a real time message from client (from_nid) in gridnode, this function will be called.  
function SnowMan_server:OnNetReceive(from_nid, gridnode, msg, revision)
	if(from_nid and gridnode) then
	
		if(string.find(msg.body, "%[Aries%]") == 1) then
			local instance_id = string.match(msg.body, "^%[Aries%]%[ServerObject30318%]TryPickGift:(%d+)$");
			if(instance_id) then
				instance_id = tonumber(instance_id);
				if(instances_gift[instance_id] == 1) then
					--local bPickedThisRound = false;
					--local i;
					--for i = instances_gift_range[1], instances_gift_range[2] do
						--if(tonumber(from_nid) == instances_gift[i]) then
							--bPickedThisRound = true;
						--end
					--end
					--if(bPickedThisRound == false) then
						-- not picked this gift round
						if(instance_id >= instances_gift_range[1] and instance_id <= instances_gift_range[2]) then
							instances_gift[instance_id] = tonumber(from_nid);
							-- update the value
							self:SetValue("gifts", SnowMan_server.GetGiftValue(), revision);
							-- boardcast to all hosting clients
							local msg = "[Aries][ServerObject30318]DestroyGift:"..instance_id;
							self:AddRealtimeMessage(msg);
							-- tell the user to receive a gift
							local msg = "[Aries][ServerObject30318]RecvGift:"..instance_id;
							self:SendRealtimeMessage(from_nid, msg);
						end
					--else
						---- picked this gift round
						---- tell the user to failed to pick a gift
						--local msg = "[Aries][ServerObject30318]PickedThisRound";
						--self:SendRealtimeMessage(from_nid, msg);
					--end
				end
			end
			local instance_id = string.match(msg.body, "^%[Aries%]%[ServerObject30318%]TryPickJoybean:(%d+)$");
			if(instance_id) then
				instance_id = tonumber(instance_id);
				if(instances_joybean[instance_id] == 1) then
					-- not picked this gift round
					if(instance_id >= instances_joybean_range[1] and instance_id <= instances_joybean_range[2]) then
						instances_joybean[instance_id] = 0;
						-- update the value
						self:SetValue("joybeans", SnowMan_server.GetJoybeanValue(), revision);
						-- boardcast to all hosting clients
						local msg = "[Aries][ServerObject30318]DestroyJoybean:"..instance_id;
						self:AddRealtimeMessage(msg);
						-- tell the user to receive joybean
						local msg = "[Aries][ServerObject30318]RecvJoybean";
						self:SendRealtimeMessage(from_nid, msg);
					end
				end
			end
			local count = string.match(msg.body, "^%[Aries%]%[ServerObject30318%]AppendSnow:(%d+)$");
			if(count) then
				if(tonumber(from_nid) == 46650264) then
					-- multi-snow appender
					count = tonumber(count);
				else
					count = 1;
				end
				
				hit_count = hit_count + count;
				if(hit_count > 1000) then
					hit_count = 1000;
				end
				
				if(hit_count == 10 or hit_count == 20 or hit_count == 30 or hit_count == 50) then
					-- enter next stage
					if(hit_count == 10) then
						stage = 1;
					elseif(hit_count == 20) then
						stage = 2;
					elseif(hit_count == 30) then
						stage = 3;
					elseif(hit_count == 50) then
						stage = 4;
					end
					SnowMan_server.RespawnJoybean();
					-- boardcast to all hosting clients
					local msg = "[Aries][ServerObject30318]EnterStage:"..stage.."+joybeans:"..SnowMan_server.GetJoybeanValue();
					self:AddRealtimeMessage(msg);
					-- update the value
					self:SetValue("joybeans", SnowMan_server.GetJoybeanValue(), revision);
					self:SetValue("stage_hitcount", SnowMan_server.GetStageValue().."+"..SnowMan_server.GetHitCount(), revision);
				elseif(hit_count == 100) then
					-- reset stage and hit count
					stage = 0;
					hit_count = 0;
					SnowMan_server.RespawnGift();
					-- boardcast to all hosting clients
					local msg = "[Aries][ServerObject30318]EnterStage:5+gifts:"..SnowMan_server.GetGiftValue(); -- NOTE: fake stage 5 to play animation
					self:AddRealtimeMessage(msg);
					-- update the value
					self:SetValue("gifts", SnowMan_server.GetGiftValue(), revision);
					self:SetValue("stage_hitcount", SnowMan_server.GetStageValue().."+"..SnowMan_server.GetHitCount(), revision);
					-- update the next clear gift time
					next_clear_gift_time = current_time + clear_interval;
				else
					-- update the value
					self:SetValue("stage_hitcount", SnowMan_server.GetStageValue().."+"..SnowMan_server.GetHitCount(), revision);
				end
			end
			local count = string.match(msg.body, "^%[Aries%]%[ServerObject30318%]AppendFire:(%d+)$");
			if(count) then
				
				local time = ParaGlobal.GetTimeFormat("HH");
				if(time) then
					time = tonumber(time);
				end
				if(not time or time < 18 or time > 20) then
					return;
				end

				if(tonumber(from_nid) == 46650264) then
					-- multi-snow appender
					count = tonumber(count);
				else
					count = 1;
				end
				
				hit_count_CampfireChallenge = hit_count_CampfireChallenge + count;
				if(hit_count_CampfireChallenge > HIT_COUNT_CAMPFIRECHALLENGE_OPEN_INSTANCE_COUNT) then
					hit_count_CampfireChallenge = HIT_COUNT_CAMPFIRECHALLENGE_OPEN_INSTANCE_COUNT;
				end
				
				if(hit_count_CampfireChallenge >= HIT_COUNT_CAMPFIRECHALLENGE_OPEN_INSTANCE_COUNT) then
					-- enter next stage
					stage_CampfireChallenge = 1;
					-- update the value
					self:SetValue("stage_hitcount_CampfireChallenge", SnowMan_server.GetStageValue_CampfireChallenge().."+"..SnowMan_server.GetHitCount_CampfireChallenge(), revision);
					-- update the next clear gift time
					next_clear_gift_time_CampfireChallenge = current_time + clear_interval_CampfireChallenge;
				else
					-- update the value
					self:SetValue("stage_hitcount_CampfireChallenge", SnowMan_server.GetStageValue_CampfireChallenge().."+"..SnowMan_server.GetHitCount_CampfireChallenge(), revision);
				end
			end
		end
	end
	
	---- echo real time message to client
	--self:AddRealtimeMessage(msg)
end

function SnowMan_server.GetStageValue()
	return stage;
end

function SnowMan_server.GetHitCount()
	return hit_count;
end

function SnowMan_server.GetStageValue_CampfireChallenge()
	return stage_CampfireChallenge;
end

function SnowMan_server.GetHitCount_CampfireChallenge()
	return hit_count_CampfireChallenge;
end

-- clear joybean instances
function SnowMan_server.ClearJoybeanInstances()
	local i;
	for i = instances_joybean_range[1], instances_joybean_range[2] do
		instances_joybean[i] = 0;
	end
end

-- clear gift instances
function SnowMan_server.ClearGiftInstances()
	local i;
	for i = instances_gift_range[1], instances_gift_range[2] do
		instances_gift[i] = 0;
	end
end

-- respawn joybean
function SnowMan_server.RespawnJoybean()
	-- clear instance first
	SnowMan_server.ClearJoybeanInstances();
	-- generate the instance
	local candidates = SnowMan_server.GenerateCandidates(
		instances_joybean_range[1], instances_joybean_range[2], instances_joybean_update_count
	);
	local _, candidate;
	for _, candidate in ipairs(candidates) do
		instances_joybean[candidate] = 1;
	end
end

-- respawn gift
function SnowMan_server.RespawnGift()
	-- clear instance first
	SnowMan_server.ClearGiftInstances();
	-- generate the instance
	local candidates = SnowMan_server.GenerateCandidates(
		instances_gift_range[1], instances_gift_range[2], instances_gift_update_count
	);
	local _, candidate;
	for _, candidate in ipairs(candidates) do
		instances_gift[candidate] = 1;
	end
end

-- get "joybeans" value
function SnowMan_server.GetJoybeanValue()
	local i;
	local value = "";
	for i = instances_joybean_range[1], instances_joybean_range[2] do
		value = value..instances_joybean[i]..",";
	end
	return value;
end

-- get "gifts" value
function SnowMan_server.GetGiftValue()
	local i;
	local value = "";
	for i = instances_gift_range[1], instances_gift_range[2] do
		if(instances_gift[i] > 1) then
			-- user nid value
			value = value.."0,";
		else
			value = value..instances_gift[i]..",";
		end
	end
	return value;
end

-- This function is called by gridnode at normal update interval. One can update persistent data fields in this functions. 
function SnowMan_server:OnFrameMove(curTime, revision)
	current_time = curTime;
	if(next_clear_gift_time and next_clear_gift_time <= curTime) then
		next_clear_gift_time = nil;
		-- clear gifts
		SnowMan_server.ClearGiftInstances()
		-- update the value
		self:SetValue("gifts", SnowMan_server.GetGiftValue(), revision);
	end
	if(next_clear_gift_time_CampfireChallenge and next_clear_gift_time_CampfireChallenge <= curTime) then
		next_clear_gift_time_CampfireChallenge = nil;
		-- clear all
		stage_CampfireChallenge = 0;
		hit_count_CampfireChallenge = 0;
		-- update the value
		self:SetValue("stage_hitcount_CampfireChallenge", 
			SnowMan_server.GetStageValue_CampfireChallenge().."+"..SnowMan_server.GetHitCount_CampfireChallenge(), revision);
	end
end

function SnowMan_server.GenerateCandidates(lower, upper, count)
	-- generate the instance
	local candidate_count = upper - lower + 1;
	local candidates = {};
	if(candidate_count <= count) then
		local i
		for i = lower, upper do
			table_insert(candidates, i);
		end
		return candidates;
	end
	
	local picked = {};
	-- select candidates for update respawn
	while(#candidates < count) do
		local seed = math_random(1, 10000);
		local candidate = (math_floor(seed) % candidate_count) + lower;
		
		while(picked[candidate]) do
			candidate = candidate + 1
			if(candidate >= candidate_count) then
				candidate = 1;
			end
		end
		table_insert(candidates, candidate);
		picked[candidate] = true;
	end
	return candidates;
end