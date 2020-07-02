--[[ mount pet in homeland AI
author: WangTian
date: 2009.8.12
desc: Walks randomly in a region with centered at (x,y) and radius "radius". If it is blocked by an object, a new random direction will be chosen.
usage:
]]

local math_random = math.random;
local _AI_templates = commonlib.gettable("_AI_templates");

if(not _AI_templates.MountPet_HomelandAI) then 
	-- set seed
	_AI_templates.MountPet_HomelandAI={};
	math.randomseed(ParaGlobal.GetGameTime()); 
end

-- face tracking
function _AI_templates.MountPet_HomelandAI.On_Load(facing, radius, waitlength)
	local player = ParaScene.GetObject(sensor_name);
	if(player:IsValid() == true) then 
		local playerChar = player:ToCharacter();
		playerChar:AssignAIController("face", "true");
	end
end

--[[
@param radius: region radius. if nil, it is 20
@param x: region center x, if nil, it is the current player position
@param y: region center y, if nil, it is the current player position
]]
function _AI_templates.MountPet_HomelandAI.On_FrameMove_Idle(radius, x,y)
	-- if user selected this character stop it. 
	local selectObj = System.obj.GetObjectParams("selection");
	if(selectObj and selectObj.name == sensor_name) then
		-- stop walking
		local player = ParaScene.GetObject(sensor_name);
		local playerChar = player:ToCharacter();
		playerChar:Stop();
		return;
	end

	local mem = _AI.GetMemory(sensor_name);
	if(mem) then 
		local nTime = ParaGlobal.GetGameTime();

		-- improve the pet idle random walk pace from fixed to random
		-- changes direction every 3-13 seconds.
		local redirection_interval = 100*(30 + math_random()* 100);
		
		if((nTime-(mem.LastWalkTime or 0)) > (redirection_interval)) then
			-- select a new target randomly
			local player = ParaScene.GetObject(sensor_name);
			if(player:IsValid()) then 
				local px, py, pz = player:GetPosition();
				if(radius == nil) then
					radius = 20;
				end
				if(mem.born_x==nil) then
					if(x~=nil) then
						mem.born_x = x;
					else
						mem.born_x = px;
					end
				end
				if(mem.born_y==nil) then
					if(y~=nil) then
						mem.born_y = y;
					else
						mem.born_y = pz;
					end
				end

				local playerChar = player:ToCharacter();
				playerChar:AssignAIController("face", "true");
				playerChar:AssignAIController("follow", "");

				local s = playerChar:GetSeqController();
				x = (math_random()*2-1)*radius + mem.born_x-px;
				y = (math_random()*2-1)*radius + mem.born_y-pz;
				--log(x..", "..y..", "..mem.born_x..", "..mem.born_y.."\r\n");
				s:WalkTo(x,0,y);
			end
			-- save to memory
			mem.LastWalkTime = nTime;
		end
	end
end

-- follow ai
function _AI_templates.MountPet_HomelandAI.On_FrameMove_Follow(radius, x,y)
	local player = ParaScene.GetObject(sensor_name);
	if(player:IsValid() == true) then 
		
		--player:SetScale(0.5);
		player:ToCharacter():SetSpeedScale(1.5);
		
		local memory = _AI.GetMemory(sensor_name);
		memory.lastWalkTime = memory.lastWalkTime or ParaGlobal.GetGameTime() + math_random(0, 2000);
		-- follow target
		local _target = ParaScene.GetPlayer();
		if(_target and _target:IsValid() == true) then
			local x, y, z = _target:GetPosition();
			local elev = ParaTerrain.GetElevation(x,z);
			if(y > elev + 10) then
				player:SetVisible(false);
				player:SetPosition(x, y + 1000, z);
				return;
			else
				player:SetVisible(true);
			end
			
			--local _effect = ParaScene.GetCharacter(player.name.."-effect");
			--if(_effect and _effect:IsValid() == true) then
				--local assetname = player:GetPrimaryAsset():GetKeyName();
				--if(assetname == "character/v3/PurpleDragonMajor/Female/PurpleDragonMajorFemale.x") then
					--_effect:SetScale(1.5);
				--end
			--end
			
			--local _borneffect = ParaScene.GetCharacter(player.name.."-borneffect");
			--if(_borneffect and _borneffect:IsValid() == true) then
				--local x, y, z = player:GetPosition();
				--_borneffect:SetPosition(x, y, z);
			--end
			
			-- follow target
			local playerChar = player:ToCharacter();
			playerChar:AssignAIController("face", "true");
			playerChar:AssignAIController("follow", _target.name.." 0.01 0");
			
			local dist = _target:DistanceTo(player);
			if(dist > 100) then
				-- target object is not in perceived region, teleport to the target
				local x, y, z = _target:GetPosition();
				player:SetPosition(x, y, z);
				player:ToCharacter():FallDown();
			end
			
			if(dist < 0.1) then
				-- after teleport or new spawn
				local x, y, z = _target:GetPosition();
				local angle = math_random(0, 100);
				x = x + 1.0 * math.sin(angle);
				z = z + 1.0 * math.cos(angle);
				player:ToCharacter():Stop();
				player:SetPosition(x, y, z);
				player:ToCharacter():FallDown();
				--player:SnapToTerrainSurface(0);
			elseif(memory.dist and memory.dist >= 0.8 and dist < 0.8 
				or (memory.lastWalkTime and (ParaGlobal.GetGameTime() - memory.lastWalkTime) > 8000)) then
				-- target object is too near, walk some steps away
				local x, y, z = _target:GetPosition();
				local s = player:ToCharacter():GetSeqController();
				local r1 = math_random()*0.1 - 1.0 * math.cos(math_random(10));
				local r2 = math_random()*0.1 - 1.0 * math.sin(math_random(10));
				player:ToCharacter():Stop();
				s:WalkTo(r1, y, r2);
				memory.lastWalkTime = ParaGlobal.GetGameTime();
			end
			memory.dist = dist;
		end
	end
end