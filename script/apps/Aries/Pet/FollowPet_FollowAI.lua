--[[ follow pet AI template
author: WangTian
date: 2009/6/18
desc: Follow a given character at radius and angle, and face tracking nearby character. 
usage:
==On_Load==
;NPL.load("(gl)script/apps/Aries/Pet/FollowPet_FollowAI.lua");MyCompany.Aries.Pet.FollowPet_FollowAI.On_Load();

==On_Perception==[alternative]
;NPL.load("(gl)script/apps/Aries/Pet/FollowPet_FollowAI.lua");MyCompany.Aries.Pet.FollowPet_FollowAI.On_Perception();
	
]]

-- create class
local libName = "FollowPet_FollowAI";
local FollowPet_FollowAI = commonlib.gettable("MyCompany.Aries.Pet.FollowPet_FollowAI");
local TimerManager = commonlib.gettable("commonlib.TimerManager")
local math_random = math.random;

-- smallest distance between target and this object
local dist_nearest = 1.5;
-- player will wander between dist_nearest and wander_dist
local wander_dist = dist_nearest+1.5;
local too_far_teleport_dist = wander_dist+15;
-- time idle before we pick the next random position. 
local idle_time_length = 8000;

-- a table holding temporary memory of characters. e.g. FollowPet_FollowAI.memory["PlayeName"] = {sequence_number = 1,Task1 = "Done"};
FollowPet_FollowAI.memory = {}; 

-- get temperary memory of a given character. By its name.
function FollowPet_FollowAI.GetMemory(name)
	local mem = FollowPet_FollowAI.memory[name];
	if(mem == nil) then
		mem = {};
		FollowPet_FollowAI.memory[name] = mem;
	end
	return mem;
end

--[[
@param targetName: if nil, it will be the main player's name
@param radius, angle: if nil, it will be random.between [1, 2] and [-3.14,3.14]
]]
function FollowPet_FollowAI.On_Load(targetName, radius, angle)
end

function FollowPet_FollowAI.On_LeaveSentientArea(player)
	local player = player or ParaScene.GetObject(sensor_name);
	if(player:IsValid() == true) then
		-- follow target
		local targetname = string.gsub(player.name, "%+followpet", "");
		local _target = ParaScene.GetCharacter(targetname);
		if(_target and _target:IsValid() == true) then

			-- tricky: this fix a bug where pet moves suddenly when on arena. 
			if(not _target:GetDynamicField("IsInCombat", false)) then
				local x, y, z = _target:GetPosition();
				player:SetPosition(x, y, z);
				player:UpdateTileContainer();
			end
		end	
	end	
end

-- follow the object, teleport to the object if object is not insight
-- called every 0.5 seconds
function FollowPet_FollowAI.On_Perception()
	local memory = FollowPet_FollowAI.GetMemory(sensor_name);
	local curTime = TimerManager.GetCurrentTime();
	
	local player = ParaScene.GetObject(sensor_name);
	if(player:IsValid() == true) then 
		memory.lastWalkTime = memory.lastWalkTime or (curTime + math_random(0, idle_time_length));
		-- follow target
		local targetname = string.gsub(player.name, "%+followpet", "");
		local _target = ParaScene.GetObject(targetname);
		if(_target and _target:IsSentient() == true) then
			local x, y, z = _target:GetPosition();
			local elev = ParaTerrain.GetElevation(x,z);
			-- NOTE 2010/4/12: original implementation is 7 meters above terrain surface,
			-- raise a little bit higher(35) to support mount pet follow in candy homeland model surface
			-- NOTE 2010/5/25:
			-- raise much higher(100) to support mount pet follow in environmental homeland model surface
			
			-- for owner is in combat, position the follow pet at the right position by the side of the player. 
			local bInCombat = _target:GetDynamicField("IsInCombat", false);
			local bInCombat_followpet = player:GetDynamicField("IsInCombat", false);

			--if(y > 3000 and y < 5000) then
				---- this is a typical in the air indoor height
				--player:SetVisible(true);
			if(bInCombat_followpet) then
				player:SetVisible(true);
			elseif(y > 19000 and y < 21000) then
				player:SetVisible(true);
			elseif(y > elev + 5) then
				local scene_player = ParaScene.GetPlayer();
				if(scene_player:equals(_target) == true) then
					local animID = _target:GetAnimation();
					-- 37  JUMPSTART
					-- 38  JUMP
					-- 39  JUMPEND
					if(animID == 37 or animID == 38) then
						-- make it invisible when target player is in air. 
						player:SetVisible(false);
						return;
					else
						player:SetVisible(true);
					end
				else
					-- make it invisible when target player is in air. 
					player:SetVisible(false);
					return;
				end
			else
				player:SetVisible(true);
			end

			--if(bInCombat == false) then
				--bInCombat_followpet = false;
			--end

			if(System.options.version == "kids") then
				bInCombat_followpet = false;
			end

			player:SetField("SkipPicking", true);

			if(bInCombat and not bInCombat_followpet) then
				local x, y, z = _target:GetPosition();
				local facing = _target:GetFacing();
				player:ToCharacter():Stop();
				local delta_x = - 3 * math.cos(facing);
				local delta_z = 3 * math.sin(facing);
				if(delta_x > 0) then
					delta_x = delta_x - 3;
				else
					delta_x = delta_x + 3;
				end
				player:SetPosition(x + delta_x, y, z + delta_z);
				player:SetFacing(facing);

				if(memory.sync_speed) then
					memory.sync_speed = nil;
					if(memory.last_speedscale) then
						player:SetField("Speed Scale", 1);
					end
				end
				return;
			end

			if(bInCombat_followpet) then
				-- cancel skip picking
				player:SetField("SkipPicking", false);
				-- force reset speed scale
				player:SetField("Speed Scale", 1);
				-- skip follow AI
				return;
			end

			-- follow target
			local dist = _target:DistanceTo(player);
			
			if(dist > too_far_teleport_dist and not bInCombat and not bInCombat_followpet) then
				-- target object is not in perceived region, teleport to the target
				local x, y, z = _target:GetPosition();
				player:SetPosition(x, y, z);
				player:UpdateTileContainer();
				-- player:ToCharacter():FallDown();
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
				if( dist <= wander_dist or (memory.dist or 0)<= dist ) then
					player:ToCharacter():Stop();
					s:WalkTo(r1+x-px, y - py, r2+z-pz);
					memory.lastWalkTime = curTime;
				end
			end
			memory.dist = dist;
		end
	end
end