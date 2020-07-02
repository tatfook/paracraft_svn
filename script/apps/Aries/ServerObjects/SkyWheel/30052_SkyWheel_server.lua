--[[
Title: Server agent template class
Author(s): 
Date: 2009/11/15
Desc: Project Aries app_main
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/SkyWheel/30052_SkyWheel_server.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/GameServer/GSL_config.lua");

-------------------------------------
-- a special server NPC that just echos whatever received. 
-------------------------------------
local SkyWheel_server = {}

Map3DSystem.GSL.config:RegisterNPCTemplate("skywheel", SkyWheel_server)

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

---- reset all instances
--local i;
--for i = instance_range[1], instance_range[2] do
	--instances[i] = 0;
--end

local currentTime = 0;

function SkyWheel_server.CreateInstance(self, revision)
	-- overwrite virtual functions
	self.OnNetReceive = SkyWheel_server.OnNetReceive;
	self.OnFrameMove = SkyWheel_server.OnFrameMove;
	-- uncomment to overwrite default AddRealtimeMessage implementation, such as adding a message compression layer.
	-- self.AddRealtimeMessage = SkyWheel_server.AddRealtimeMessage;
	
	-- set init value for each slot
	self:SetValue("slots", SkyWheel_server.GetSlotValue(), revision);
end

-- whenever an instance of this server agent has received a real time message from client (from_nid) in gridnode, this function will be called.  
function SkyWheel_server:OnNetReceive(from_nid, gridnode, msg, revision)
	if(from_nid and gridnode) then
		if(string.find(msg.body, "%[Aries%]") == 1) then
			local slot_id = string.match(msg.body, "^%[Aries%]%[ServerObject30052%]TryMount:(%d+)$");
			if(slot_id) then
				local i;
				local nSlot = #slots
				for i = 1, nSlot do
					local slot = slots[i];
					if(slot.current_nid == tonumber(from_nid)) then
						-- tell the user the slot is already on
						local msg = "[Aries][ServerObject30052]AlreadyMounted";
						self:SendRealtimeMessage(from_nid, msg);
						return;
					end
				end
				slot_id = tonumber(slot_id);
				local slot = slots[slot_id];
				if(slot) then
					if(slot.current_nid == 0) then
						-- dance on the slot
						slot.current_nid = tonumber(from_nid);
						-- update the next cleartime
						slot.nextclear_time = (math.floor(currentTime / full_duration) + 1) * full_duration + (slot_id - 1 - 1) * single_duration;
						-- update the value
						self:SetValue("slots", SkyWheel_server.GetSlotValue(), revision);
						-- boardcast to all hosting clients
						local msg = "[Aries][ServerObject30052]slots:"..SkyWheel_server.GetSlotValue();
						self:AddRealtimeMessage(msg);
						-- tell the user to dance on the slot
						local msg = "[Aries][ServerObject30052]StartMount:"..slot_id;
						self:SendRealtimeMessage(from_nid, msg);
					else
						-- tell the user the slot is already on
						local msg = "[Aries][ServerObject30052]AlreadyMounted";
						self:SendRealtimeMessage(from_nid, msg);
					end
				end
			end
			local bCancelMount = string.find(msg.body, "^%[Aries%]%[ServerObject30052%]CancelMount$");
			if(bCancelMount) then
				local i;
				local nSlot = #slots
				for i = 1, #slots do
					local slot = slots[i];
					if(slot and slot.current_nid == tonumber(from_nid)) then
						-- clear the instances and broadcast to all hosting clients
						-- clear instance first
						SkyWheel_server.ClearSlot(i);
						-- update the value
						self:SetValue("slots", SkyWheel_server.GetSlotValue(), revision);
						-- boardcast to all hosting clients
						local msg = "[Aries][ServerObject30052]slots:"..SkyWheel_server.GetSlotValue();
						self:AddRealtimeMessage(msg);
						-- tell the user to walk off the slot
						local msg = "[Aries][ServerObject30052]UnMount:"..i;
						self:SendRealtimeMessage(from_nid, msg);
						break;
					end
				end
			end
		end
	end
	
	---- echo real time message to client
	--self:AddRealtimeMessage(msg)
end

-- This function is called by gridnode at normal update interval. One can update persistent data fields in this functions. 
function SkyWheel_server:OnFrameMove(curTime, revision)
	currentTime = curTime;
	-- update persistent data and let normal update to broadcast to all agents. 
	local i;
	for i = 1, #slots do
		local slot = slots[i];
		if(not slot.nextclear_time) then
			-- do nothing to the slot
		elseif(slot.nextclear_time <= curTime) then
			-- record the user nid
			local to_nid = slot.current_nid;
			-- clear the instances and broadcast to all hosting clients
			-- clear instance first
			SkyWheel_server.ClearSlot(i);
			-- update the value
			self:SetValue("slots", SkyWheel_server.GetSlotValue(), revision);
			-- boardcast to all hosting clients
			local msg = "[Aries][ServerObject30052]slots:"..SkyWheel_server.GetSlotValue();
			self:AddRealtimeMessage(msg);
			-- tell the user to walk off the slot
			local msg = "[Aries][ServerObject30052]UnMountAndRecvReward:"..i;
			self:SendRealtimeMessage(tostring(to_nid), msg);
		end
	end
	-- update the skywheel current time
	self:SetValue("CurrentTime", currentTime, revision);
	-- update the skywheel remaining time of the current round
	self:SetValue("remaining", math.mod(currentTime, full_duration), revision);
	
	--local old_value = self:GetValue("versioned_data");
	--old_value.nCount = old_value.nCount + 1;
	--self:SetValue("versioned_data", old_value, revision);
end

function SkyWheel_server.ClearSlot(i)
	slots[i].current_nid = 0;
	slots[i].nextclear_time = nil;
end

function SkyWheel_server.GetSlotValue()
	local i;
	local value = "";
	for i = 1, #slots do
		local slot = slots[i];
		if(slot.current_nid > 0) then
			value = value..slot.current_nid..",";
		else
			value = value.."0,";
		end
	end
	return value;
end