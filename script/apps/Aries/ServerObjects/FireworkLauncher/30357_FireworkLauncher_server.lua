--[[
Title: Server agent template class
Author(s): 
Date: 2009/11/15
Desc: Project Aries app_main
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/FireworkLauncher/30357_FireworkLauncher_server.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/GameServer/GSL_config.lua");

-------------------------------------
-- a special server NPC that just echos whatever received. 
-------------------------------------
local FireworkLauncher_server = {}

Map3DSystem.GSL.config:RegisterNPCTemplate("fireworklauncher", FireworkLauncher_server)

-- firework launcher setup
local instance_joybean_count_per_launcher = 20;
local launcher_count = 3;
-- joybean instances
local instances_joybean = {};
local instances_joybean_range = {1, instance_joybean_count_per_launcher * launcher_count};

-- hit count
local hit_count = 0;

-- reset all joybean instances
local i;
for i = instances_joybean_range[1], instances_joybean_range[2] do
	instances_joybean[i] = 0;
end

-- clear interval after respawn
local clear_interval = 600000;
local fire_interval = 900000;
--local clear_interval = 6000;
--local fire_interval = 12000;

-- last fire times
local last_fire_times = {};

-- reset last_fire_times
local i;
for i = 1, launcher_count do
	last_fire_times[i] = 0;
end

local current_time = 0;

function FireworkLauncher_server.CreateInstance(self, revision)
	-- overwrite virtual functions
	self.OnNetReceive = FireworkLauncher_server.OnNetReceive;
	self.OnFrameMove = FireworkLauncher_server.OnFrameMove;
	-- uncomment to overwrite default AddRealtimeMessage implementation, such as adding a message compression layer.
	-- self.AddRealtimeMessage = FireworkLauncher_server.AddRealtimeMessage;
	
	-- set init value for each firework launcher
	self:SetValue("joybeans", FireworkLauncher_server.GetJoybeanValue(), revision);
end

-- whenever an instance of this server agent has received a real time message from client (from_nid) in gridnode, this function will be called.  
function FireworkLauncher_server:OnNetReceive(from_nid, gridnode, msg, revision)
	if(from_nid and gridnode) then
	
		if(string.find(msg.body, "%[Aries%]") == 1) then
			local instance_id = string.match(msg.body, "^%[Aries%]%[ServerObject30357%]TryPickJoybean:(%d+)$");
			if(instance_id) then
				instance_id = tonumber(instance_id);
				if(instances_joybean[instance_id] == 1) then
					-- not picked this gift round
					if(instance_id >= instances_joybean_range[1] and instance_id <= instances_joybean_range[2]) then
						instances_joybean[instance_id] = 0;
						-- update the value
						self:SetValue("joybeans", FireworkLauncher_server.GetJoybeanValue(), revision);
						-- boardcast to all hosting clients
						local msg = "[Aries][ServerObject30357]DestroyJoybean:"..instance_id;
						self:AddRealtimeMessage(msg);
						-- tell the user to receive joybean
						local msg = "[Aries][ServerObject30357]RecvJoybean";
						self:SendRealtimeMessage(from_nid, msg);
					end
				end
			end
			local nLauncher = string.match(msg.body, "^%[Aries%]%[ServerObject30357%]TryLaunch:(%d+)$");
			if(nLauncher) then
				nLauncher = tonumber(nLauncher);
				--if(tonumber(from_nid) == 46650264) then
					---- multi-snow appender
					--count = tonumber(count);
				--else
					--count = 1;
				--end
				
				if((nLauncher < 1) or (nLauncher > launcher_count)) then
					-- launcher count out of range
					return;
				end
				
				if((current_time - last_fire_times[nLauncher]) > fire_interval) then
					-- set the last fire launch time
					last_fire_times[nLauncher] = current_time;
					-- respawn joybean
					FireworkLauncher_server.RespawnJoybean(nLauncher);
					-- boardcast to all hosting clients
					local msg = "[Aries][ServerObject30357]PopJoybeans:"..nLauncher;
					self:AddRealtimeMessage(msg);
					-- update the value
					self:SetValue("joybeans", FireworkLauncher_server.GetJoybeanValue(), revision);
				else
					-- tell the user to launcher is not ready
					local msg = "[Aries][ServerObject30357]NotReady";
					self:SendRealtimeMessage(from_nid, msg);
				end
			end
		end
	end
	
	---- echo real time message to client
	--self:AddRealtimeMessage(msg)
end

-- clear joybean
function FireworkLauncher_server.ClearJoybean(nLauncher)
	local from = (nLauncher - 1) * instance_joybean_count_per_launcher + 1;
	local to = nLauncher * instance_joybean_count_per_launcher;
	local i;
	for i = from, to do
		instances_joybean[i] = 0;
	end
end

-- respawn joybean
function FireworkLauncher_server.RespawnJoybean(nLauncher)
	local from = (nLauncher - 1) * instance_joybean_count_per_launcher + 1;
	local to = nLauncher * instance_joybean_count_per_launcher;
	local i;
	for i = from, to do
		instances_joybean[i] = 1;
	end
end

-- get "joybeans" value
function FireworkLauncher_server.GetJoybeanValue()
	local i;
	local value = "";
	for i = instances_joybean_range[1], instances_joybean_range[2] do
		value = value..instances_joybean[i]..",";
	end
	return value;
end

-- This function is called by gridnode at normal update interval. One can update persistent data fields in this functions. 
function FireworkLauncher_server:OnFrameMove(curTime, revision)
	current_time = curTime;
	
	local i;
	for i = 1, launcher_count do
		if((current_time - last_fire_times[i]) > clear_interval) then
			-- clear joybean
			FireworkLauncher_server.ClearJoybean(i)
			-- update the value
			self:SetValue("joybeans", FireworkLauncher_server.GetJoybeanValue(), revision);
		end
	end
end
