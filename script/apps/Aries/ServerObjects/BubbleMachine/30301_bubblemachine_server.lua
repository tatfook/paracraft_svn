--[[
Title: Server agent template class
Author(s): 
Date: 2009/11/15
Desc: Project Aries app_main
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/BubbleMachine/30301_bubblemachine_server.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/GameServer/GSL_config.lua");

NPL.load("(gl)script/kids/3DMapSystemItem/PowerItemManager.lua");
local PowerItemManager = commonlib.gettable("Map3DSystem.Item.PowerItemManager");

local string_find = string.find;
local string_match = string.match;
local table_insert = table.insert;
local math_random = math.random;
local math_floor = math.floor;
-------------------------------------
-- a special server NPC that just echos whatever received. 
-------------------------------------
local BubbleMachine_server = {}

Map3DSystem.GSL.config:RegisterNPCTemplate("bubblemachine", BubbleMachine_server)

local instances = {};
local instance_range = {1, 60};
local machines = {  {range = {1, 10}, update_count = 5, update_interval = 30 * 60 * 1000, clear_afterupdate = 25 * 60 * 1000, },
					{range = {11, 20}, update_count = 5, update_interval = 30 * 60 * 1000, clear_afterupdate = 25 * 60 * 1000, },
					{range = {21, 30}, update_count = 5, update_interval = 30 * 60 * 1000, clear_afterupdate = 25 * 60 * 1000, },
					{range = {31, 40}, update_count = 5, update_interval = 35 * 60 * 1000, clear_afterupdate = 30 * 60 * 1000, },
					{range = {41, 50}, update_count = 5, update_interval = 35 * 60 * 1000, clear_afterupdate = 30 * 60 * 1000, },
					{range = {51, 60}, update_count = 5, update_interval = 35 * 60 * 1000, clear_afterupdate = 30 * 60 * 1000, },
				};
local machine_count = #machines;

-- reset all instances
local i;
for i = instance_range[1], instance_range[2] do
	instances[i] = 0;
end

function BubbleMachine_server.CreateInstance(self, revision)
	-- overwrite virtual functions
	self.OnNetReceive = BubbleMachine_server.OnNetReceive;
	self.OnFrameMove = BubbleMachine_server.OnFrameMove;
	-- uncomment to overwrite default AddRealtimeMessage implementation, such as adding a message compression layer.
	-- self.AddRealtimeMessage = BubbleMachine_server.AddRealtimeMessage;
	
	-- set init value for each machine
	local i;
	for i = 1, machine_count do
		self:SetValue("machine"..i, BubbleMachine_server.GetMachineValue(i), revision);
	end
end

-- whenever an instance of this server agent has received a real time message from client (from_nid) in gridnode, this function will be called.  
function BubbleMachine_server:OnNetReceive(from_nid, gridnode, msg, revision)
	if(from_nid and gridnode) then
		if(string.find(msg.body, "%[Aries%]") == 1) then
			local instance_id = string.match(msg.body, "^%[Aries%]%[ServerObject30301%]TryPickObj:(%d+)$");
			if(instance_id) then
				instance_id = tonumber(instance_id);
				if(instances[instance_id] == 1) then
					instances[instance_id] = 0;
					-- find the machine
					local i;
					for i = 1, machine_count do
						local machine = machines[i];
						if(instance_id >= machine.range[1] and instance_id <= machine.range[2]) then
							-- update the value
							self:SetValue("machine"..i, BubbleMachine_server.GetMachineValue(i), revision);
							-- boardcast to all hosting clients
							local msg = "[Aries][ServerObject30301]DestroyInstance:"..instance_id;
							self:AddRealtimeMessage(msg);
							---- tell the user to receive a gift
							--local msg = "[Aries][ServerObject30301]RecvGift";
							--self:SendRealtimeMessage(from_nid, msg);
							-- tell the user to have received loots
							local gifts = {
								17284, -- 17284_BubbleMachinePack
							};
							local gift_gsid = gifts[math_random(1, #gifts)];
							local loots = {[gift_gsid] = 1};
							PowerItemManager.AddExpJoybeanLoots(tostring(from_nid), 0, nil, loots, function(msg) 
								if(msg.issuccess) then
									local guid = nil;
									local _, update;
									for _, update in pairs(msg.updates) do
										if(update.guid) then
											guid = update.guid;
										end
									end
									local _, add;
									for _, add in pairs(msg.adds) do
										if(add.guid) then
											guid = add.guid;
										end
									end
									if(guid) then
										-- tell the user to receive a gift
										local msg = "[Aries][ServerObject30301]RecvLoot:"..gift_gsid.."_"..guid.."_1";
										self:SendRealtimeMessage(from_nid, msg);
									end
								end
							end);
							break;
						end
					end
				end
			end
		end
	end
	
	---- echo real time message to client
	--self:AddRealtimeMessage(msg)
end

-- This function is called by gridnode at normal update interval. One can update persistent data fields in this functions. 
function BubbleMachine_server:OnFrameMove(curTime, revision)
	-- update persistent data and let normal update to broadcast to all agents. 
	local i;
	for i = 1, machine_count do
		local machine = machines[i];
		if(not machine.nextupdate_time and not machine.nextclear_time) then
			-- first framemove, set the update and clear time
			machine.nextupdate_time = curTime + machine.update_interval;
			machine.nextclear_time = curTime + machine.clear_afterupdate;
		elseif(machine.nextupdate_time <= curTime) then
			-- update the update and clear time
			machine.nextupdate_time = curTime + machine.update_interval;
			machine.nextclear_time = curTime + machine.clear_afterupdate;
			-- TODO: update the instances and broadcast to all hosting clients
			-- clear instance first
			BubbleMachine_server.ClearMachineInstance(i);
			-- generate the instance
			local candidates = BubbleMachine_server.GenerateCandidates(machine.range[1], machine.range[2], machine.update_count);
			local _, candidate;
			for _, candidate in ipairs(candidates) do
				instances[candidate] = 1;
			end
			-- update the value
			self:SetValue("machine"..i, BubbleMachine_server.GetMachineValue(i), revision);
			-- boardcast to all hosting clients
			local msg = "[Aries][ServerObject30301]machine"..i..":"..BubbleMachine_server.GetMachineValue(i);
			self:AddRealtimeMessage(msg);
		elseif(machine.nextclear_time <= curTime) then
			--add by gosling 2010-06-12,avoid repeating clear
			machine.nextclear_time = curTime + machine.update_interval;

			-- clear the instances and broadcast to all hosting clients
			-- clear instance first
			BubbleMachine_server.ClearMachineInstance(i);
			-- update the value
			self:SetValue("machine"..i, BubbleMachine_server.GetMachineValue(i), revision);
			-- boardcast to all hosting clients
			local msg = "[Aries][ServerObject30301]machine"..i..":"..BubbleMachine_server.GetMachineValue(i);
			self:AddRealtimeMessage(msg);
		end
	end
	
	--local old_value = self:GetValue("versioned_data");
	--old_value.nCount = old_value.nCount + 1;
	--self:SetValue("versioned_data", old_value, revision);
end

function BubbleMachine_server.ClearMachineInstance(machine_id)
	local i;
	local machine = machines[machine_id];
	for i = machine.range[1], machine.range[2] do
		instances[i] = 0;
	end
end

function BubbleMachine_server.GetMachineValue(machine_id)
	local i;
	local machine = machines[machine_id];
	local value = "";
	for i = machine.range[1], machine.range[2] do
		value = value..instances[i]..",";
	end
	return value;
end

function BubbleMachine_server.GenerateCandidates(lower, upper, count)
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