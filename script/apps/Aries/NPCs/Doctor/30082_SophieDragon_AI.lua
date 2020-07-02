--[[ SophieDragon AI
Author: WangTian
Date: 2009/7/22
Desc: SophieDragon AI

script/apps/Aries/NPCs/Police/30082_SophieDragon_AI.lua
	
]]

NPL.load("(gl)script/apps/Aries/Quest/NPCAIMemory.lua");

-- create class
local libName = "SophieDragon_AI";
local SophieDragon_AI = commonlib.gettable("MyCompany.Aries.Quest.NPCAI.SophieDragon_AI");

-- Police dog AI framemove
function SophieDragon_AI.On_FrameMove()
	-- 0.3s interval
	local sophieDragon = ParaScene.GetObject(sensor_name);
	local player = ParaScene.GetPlayer();
	
	if(sophieDragon:IsValid() == true and player:IsValid() == true) then
		local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30082);
		local NPC_id, instance = MyCompany.Aries.Quest.NPC.GetNpcIDAndInstanceFromCharacter(sophieDragon);
		
		local dx, dy, dz = sophieDragon:GetPosition();
		local px, py, pz = player:GetPosition();
		
		local targetNPC_id = MyCompany.Aries.Desktop.TargetArea.TargetNPC_id;
		local targetNPC_instance = MyCompany.Aries.Desktop.TargetArea.TargetNPC_instance;
		
		local dist = sophieDragon:DistanceTo(player);
		if(memory.dist and memory.dist > 5 and dist <= 5) then
			-- walk to the player a little step, automatically face the player
			local sophieDragonChar = sophieDragon:ToCharacter();
			local s = sophieDragonChar:GetSeqController();
			sophieDragonChar:Stop();
			s:WalkTo((px - dx)/10, 0, (pz - dz)/10);
		end
		memory.dist = dist;
		
		if(dist <= 10) then
			-- skip random walk
			if(targetNPC_id == 30082) then
				return;
			end
		end
		
		local radius = 3;
		
		if(memory.born_x == nil) then
			memory.born_x = dx;
		end
		if(memory.born_z == nil) then
			memory.born_z = dz;
		end
		
		if(memory.LastWalkTime == nil) then
			memory.LastWalkTime = 0;
		end
		
		local sophieDragonChar = sophieDragon:ToCharacter();
		local nTime = ParaGlobal.GetGameTime();
		
		-- changes direction every [3, 5] seconds.
		if((nTime - memory.LastWalkTime) > 1000 * math.random(3,5)) then
			-- select a new target randomly
			local s = sophieDragonChar:GetSeqController();
			x = (math.random()*2-1)*radius + memory.born_x - dx;
			z = (math.random()*2-1)*radius + memory.born_z - dz;
			--log(x..", "..z..", "..memory.born_x..", "..memory.born_z.."\r\n");
			sophieDragonChar:Stop();
			s:WalkTo(x, 0, z);
			-- save to memory
			memory.LastWalkTime = nTime;
		end
	end
end