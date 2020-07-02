--[[ mount pet AI template
author: WangTian
date: 2009/6/18
desc: Follow a given character at radius and angle, and face tracking nearby character. 
usage:
==On_Load==
;NPL.load("(gl)script/apps/Aries/Pet/MountPet_IndoorFlyAI.lua");MyCompany.Aries.Pet.MountPet_IndoorFlyAI.On_Load();

==On_Perception==[alternative]
;NPL.load("(gl)script/apps/Aries/Pet/MountPet_IndoorFlyAI.lua");MyCompany.Aries.Pet.MountPet_IndoorFlyAI.On_Perception();
	
]]

-- create class
local libName = "MountPet_IndoorFlyAI";
local MountPet_IndoorFlyAI = {};
commonlib.setfield("MyCompany.Aries.Pet.MountPet_IndoorFlyAI", MountPet_IndoorFlyAI);

MountPet_IndoorFlyAI.LastRadius = 2;
MountPet_IndoorFlyAI.LastAngle = 1.57;

-- a table holding temporary memory of characters. e.g. MountPet_IndoorFlyAI.memory["PlayeName"] = {sequence_number = 1,Task1 = "Done"};
MountPet_IndoorFlyAI.memory = {}; 

-- get temperary memory of a given character. By its name.
function MountPet_IndoorFlyAI.GetMemory(name)
	local mem = MountPet_IndoorFlyAI.memory[name];
	if(mem == nil) then
		mem = {};
		MountPet_IndoorFlyAI.memory[name] = mem;
	end
	return mem;
end

--[[
@param targetName: if nil, it will be the main player's name
@param radius, angle: if nil, it will be random.between [1, 2] and [-3.14,3.14]
]]
function MountPet_IndoorFlyAI.On_Load(targetName, radius, angle)
	local player = ParaScene.GetObject(sensor_name);
	if(player:IsValid() == true) then 
		if(targetName == nil) then
			targetName = ParaScene.GetPlayer().name;
		end
		if(radius == nil) then
			MountPet_IndoorFlyAI.LastRadius = MountPet_IndoorFlyAI.LastRadius + 0.2;
			if(MountPet_IndoorFlyAI.LastRadius >= 2) then
				MountPet_IndoorFlyAI.LastRadius = 1;
			end
			radius = MountPet_IndoorFlyAI.LastRadius;
		end
		if(angle == nil) then
			MountPet_IndoorFlyAI.LastAngle = MountPet_IndoorFlyAI.LastAngle + 0.4;
			if(MountPet_IndoorFlyAI.LastAngle >= 3.1416) then
				MountPet_IndoorFlyAI.LastAngle = -3.1416;
			end
			angle = MountPet_IndoorFlyAI.LastAngle;
		end

		local playerChar = player:ToCharacter();
		playerChar:AssignAIController("face", "true");
		playerChar:AssignAIController("follow", targetName.." "..radius.." "..angle);
	end
end

-- follow the object, teleport to the object if object is not insight
function MountPet_IndoorFlyAI.On_Perception()
	local player = ParaScene.GetObject(sensor_name);
	if(player:IsValid() == true) then 
		
		local mem = _AI.GetMemory(sensor_name);
		-- circle target
		local targetname = string.gsub(player.name, "%+mountpet%-circle", "");
		local _target = ParaScene.GetCharacter(targetname);
		if(_target and _target:IsValid() == true) then
			mem.LastAngle = mem.LastAngle or 0;
			mem.LastAngle = mem.LastAngle + 0.05;
			-- target object is not in perceived region, teleport to the target
			local x, y, z = _target:GetPosition();
			local facing = _target:GetFacing();
			player:SetPosition(x + math.sin(mem.LastAngle), y + 0.4, z + math.cos(mem.LastAngle));
			player:SetFacing(facing);
		end
	end
end