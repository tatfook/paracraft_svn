--[[ mount pet AI template
author: WangTian
date: 2009/6/18
desc: Follow a given character at radius and angle, and face tracking nearby character. 
usage:
==On_Load==
;NPL.load("(gl)script/apps/Aries/Pet/MountPet_FollowAI.lua");MyCompany.Aries.Pet.MountPet_FollowAI.On_Load();

==On_Perception==[alternative]
MyCompany.Aries.Pet.MountPet_FollowAI.On_Perception();
	
]]

-- create class
local libName = "MountPet_FollowAI";
local MountPet_FollowAI = commonlib.gettable("MyCompany.Aries.Pet.MountPet_FollowAI");
local TimerManager = commonlib.gettable("commonlib.TimerManager")
local math_random = math.random;

-- smallest distance between target and this object
local dist_nearest = 2;
-- player will wander between dist_nearest and wander_dist
local wander_dist = dist_nearest+1.5;
local too_far_teleport_dist = wander_dist+15;
-- time idle before we pick the next random position. 
local idle_time_length = 16000;

-- a table holding temporary memory of characters. e.g. MountPet_FollowAI.memory["PlayeName"] = {sequence_number = 1,Task1 = "Done"};
MountPet_FollowAI.memory = {}; 

-- get temperary memory of a given character. By its name.
function MountPet_FollowAI.GetMemory(name)
	local mem = MountPet_FollowAI.memory[name];
	if(mem == nil) then
		mem = {};
		MountPet_FollowAI.memory[name] = mem;
	end
	return mem;
end

--[[
@param targetName: if nil, it will be the main player's name
@param radius, angle: if nil, it will be random.between [1, 2] and [-3.14,3.14]
]]
function MountPet_FollowAI.On_Load(targetName, radius, angle)
end

-- NOT used
function MountPet_FollowAI.On_EnterSentientArea()
end

function MountPet_FollowAI.On_LeaveSentientArea()
	local player = ParaScene.GetObject(sensor_name);
	if(player:IsValid() == true) then
		-- follow target
		local targetname = string.gsub(sensor_name, "%+mountpet%-follow", "");
		local _target = ParaScene.GetCharacter(targetname);
		if(_target and _target:IsValid() == true) then
		 	local x, y, z = _target:GetPosition();
			-- LOG.show(targetname.."Leave", {x, y, z})
			-- _guihelper.MessageBox({targetname, x, y, z});

			player:SetPosition(x, y, z);
			player:UpdateTileContainer();
		end	
	end	
end

-- follow the object, teleport to the object if object is not insight
-- called every 0.4 seconds
function MountPet_FollowAI.On_Perception()
	local memory = MountPet_FollowAI.GetMemory(sensor_name);
	local curTime = TimerManager.GetCurrentTime();
	
	local player = ParaScene.GetObject(sensor_name);
	if(player:IsValid() == true) then 
		memory.lastWalkTime = memory.lastWalkTime or (curTime + math_random(0, idle_time_length));
		-- follow target
		local targetname = string.gsub(sensor_name, "%+mountpet%-follow", "");
		local _target = ParaScene.GetCharacter(targetname);
		if(_target and _target:IsSentient() == true) then
			local x, y, z = _target:GetPosition();
			-- LOG.show(targetname, {curTime,targetname, x, y, z})

			local elev = ParaTerrain.GetElevation(x,z);
			-- NOTE 2010/4/12: original implementation is 7 meters above terrain surface,
			-- raise a little bit higher(35) to support mount pet follow in candy homeland model surface
			-- NOTE 2010/5/25:
			-- raise much higher(100) to support mount pet follow in environmental homeland model surface
			if(y > 19000) then
				-- instance and cave indoor
				player:SetVisible(true);
			elseif(y > (elev + 100)) then
				player:SetVisible(false);
				player:SetPosition(x, y + 1000, z);
				player:UpdateTileContainer();
				return;
			else
				player:SetVisible(true);
			end
			
			-- follow target
			local dist = _target:DistanceTo(player);
			if(dist > too_far_teleport_dist) then
				-- target object is not in perceived region, teleport to the target
				local x, y, z = _target:GetPosition();
				player:SetPosition(x, y, z);
				player:UpdateTileContainer();
				--player:ToCharacter():FallDown();
				dist = 0;
			end
			
			if( (dist > wander_dist) or (dist < dist_nearest) or 
				(memory.dist and memory.dist >= wander_dist and dist < wander_dist 
					or (memory.lastWalkTime and (curTime - memory.lastWalkTime) > idle_time_length))) then
				-- target object is too near or be standing for too long, walk to a new random position. 
				local x, y, z = _target:GetPosition();
				local px,py,pz = player:GetPosition();

				local s = player:ToCharacter():GetSeqController();
				local wander_dist_radius = dist_nearest + (wander_dist - dist_nearest)* math_random();
				if(dist > wander_dist) then
					-- automatically accelarate the speed to the same of current player. 
					if(not memory.sync_speed) then
						memory.sync_speed = true;
						local max_speed = player:GetField("WalkSpeed", 0);
						if(max_speed>0.1) then
							local max_speed_target = _target:GetField("WalkSpeed", 0);
							if(max_speed_target>0.1) then
								memory.last_speedscale = 1;
								player:SetField("Speed Scale", max_speed_target/max_speed);
							end
						end
					end
					wander_dist_radius = 0;
				else
					if(memory.sync_speed) then
						memory.sync_speed = nil;
						if(memory.last_speedscale) then
							player:SetField("Speed Scale", 1);
						end
					end
				end
				local angle = math_random(10);
				local r1 = wander_dist_radius * math.cos(angle);
				local r2 = wander_dist_radius * math.sin(angle);
				player:ToCharacter():Stop();
				s:WalkTo(r1+x-px, y - py, r2+z-pz);
				memory.lastWalkTime = curTime;
			end
			memory.dist = dist;
		end
	end
end