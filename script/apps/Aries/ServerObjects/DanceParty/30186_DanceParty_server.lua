--[[
Title: Server agent template class
Author(s): 
Date: 2009/11/15
Desc: Project Aries app_main
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/DanceParty/30186_DanceParty_server.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/GameServer/GSL_config.lua");

-------------------------------------
-- a special server NPC that just echos whatever received. 
-------------------------------------
local DanceParty_server = {}

Map3DSystem.GSL.config:RegisterNPCTemplate("danceparty", DanceParty_server)

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

---- reset all instances
--local i;
--for i = instance_range[1], instance_range[2] do
	--instances[i] = 0;
--end

local currentTime = 0;

function DanceParty_server.CreateInstance(self, revision)
	-- overwrite virtual functions
	self.OnNetReceive = DanceParty_server.OnNetReceive;
	self.OnFrameMove = DanceParty_server.OnFrameMove;
	-- uncomment to overwrite default AddRealtimeMessage implementation, such as adding a message compression layer.
	-- self.AddRealtimeMessage = DanceParty_server.AddRealtimeMessage;
	
	-- set init value for each arena
	local i;
	for i = 1, arena_count do
		self:SetValue("arenas", DanceParty_server.GetArenaValue(), revision);
	end
end

-- whenever an instance of this server agent has received a real time message from client (from_nid) in gridnode, this function will be called.  
function DanceParty_server:OnNetReceive(from_nid, gridnode, msg, revision)
	if(from_nid and gridnode) then
		if(string.find(msg.body, "%[Aries%]") == 1) then
			local arena_id = string.match(msg.body, "^%[Aries%]%[ServerObject30186%]TryDance:(%d+)$");
			if(arena_id) then
				arena_id = tonumber(arena_id);
				local arena = arenas[arena_id];
				if(arena.current_nid == 0) then
					-- dance on the arena
					arena.current_nid = tonumber(from_nid);
					-- update the next cleartime
					arena.nextclear_time = currentTime + dance_duration;
					-- update the value
					self:SetValue("arenas", DanceParty_server.GetArenaValue(), revision);
					-- boardcast to all hosting clients
					local msg = "[Aries][ServerObject30186]arenas:"..DanceParty_server.GetArenaValue();
					self:AddRealtimeMessage(msg);
					-- tell the user to dance on the arena
					local msg = "[Aries][ServerObject30186]startdance:"..arena_id;
					self:SendRealtimeMessage(from_nid, msg);
				else
					-- tell the user the arena is already on
					local msg = "[Aries][ServerObject30186]danceronfloor";
					self:SendRealtimeMessage(from_nid, msg);
				end
			end
			local bCancelDance = string.find(msg.body, "^%[Aries%]%[ServerObject30186%]CancelDance$");
			if(bCancelDance) then
				local i;
				for i = 1, #arenas do
					local arena = arenas[i];
					if(arena.current_nid == tonumber(from_nid)) then
						-- clear the instances and broadcast to all hosting clients
						-- clear instance first
						DanceParty_server.ClearArena(i);
						-- update the value
						self:SetValue("arenas", DanceParty_server.GetArenaValue(), revision);
						-- boardcast to all hosting clients
						local msg = "[Aries][ServerObject30186]arenas:"..DanceParty_server.GetArenaValue(i);
						self:AddRealtimeMessage(msg);
						-- tell the user to walk off the arena
						local msg = "[Aries][ServerObject30186]walkoff:"..i;
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
function DanceParty_server:OnFrameMove(curTime, revision)
	currentTime = curTime;
	-- update persistent data and let normal update to broadcast to all agents. 
	local i;
	for i = 1, #arenas do
		local arena = arenas[i];
		if(not arena.nextclear_time) then
			-- do nothing to the arena
		elseif(arena.nextclear_time <= curTime) then
			-- record the dancer nid
			local to_nid = arena.current_nid;
			-- clear the instances and broadcast to all hosting clients
			-- clear instance first
			DanceParty_server.ClearArena(i);
			-- update the value
			self:SetValue("arenas", DanceParty_server.GetArenaValue(), revision);
			-- boardcast to all hosting clients
			local msg = "[Aries][ServerObject30186]arenas:"..DanceParty_server.GetArenaValue(i);
			self:AddRealtimeMessage(msg);
			-- tell the user to walk off the arena
			local msg = "[Aries][ServerObject30186]walkoffandrecvreward:"..i;
			self:SendRealtimeMessage(tostring(to_nid), msg);
		end
	end
	
	--local old_value = self:GetValue("versioned_data");
	--old_value.nCount = old_value.nCount + 1;
	--self:SetValue("versioned_data", old_value, revision);
end

function DanceParty_server.ClearArena(i)
	arenas[i].current_nid = 0;
	arenas[i].nextclear_time = nil;
end

function DanceParty_server.GetArenaValue()
	local i;
	local value = "";
	for i = 1, #arenas do
		local arena = arenas[i];
		if(arena.current_nid > 0) then
			value = value.."1,";
		else
			value = value.."0,";
		end
	end
	return value;
end