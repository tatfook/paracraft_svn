--[[ UglyDuckling AI
Author: WangTian
Date: 2009/7/22
Desc: UglyDuckling AI

script/apps/Aries/NPCs/Police/30362_UglyDuckling_AI.lua
	
]]

NPL.load("(gl)script/apps/Aries/Quest/NPCAIMemory.lua");

-- create class
local libName = "UglyDuckling_AI";
local UglyDuckling_AI = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCAI.UglyDuckling_AI", UglyDuckling_AI);

-- Police dog AI framemove
function UglyDuckling_AI.On_FrameMove()
	-- 0.3s interval
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30362);
	if(not memory or memory.isFreeWaterSurfaceMove ~= true) then
		return;
	end
	
	local uglyDuckling = ParaScene.GetObject(sensor_name);
	local player = ParaScene.GetPlayer();
	
	if(uglyDuckling:IsValid() == true and player:IsValid() == true) then
		-- set movement style as OPC
		
		local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30362);
		local NPC_id, instance = MyCompany.Aries.Quest.NPC.GetNpcIDAndInstanceFromCharacter(uglyDuckling);
		
		local att = uglyDuckling:GetAttributeObject();
		att:SetField("MovementStyle", 4)

		local dx, dy, dz = uglyDuckling:GetPosition();
		local px, py, pz = player:GetPosition();
		
		local targetNPC_id = MyCompany.Aries.Desktop.TargetArea.TargetNPC_id;
		local targetNPC_instance = MyCompany.Aries.Desktop.TargetArea.TargetNPC_instance;
		
		local dist = uglyDuckling:DistanceTo(player);
		if(memory.dist and memory.dist > 5 and dist <= 5) then
			-- walk to the player a little step, automatically face the player
			local uglyDucklingChar = uglyDuckling:ToCharacter();
			local s = uglyDucklingChar:GetSeqController();
			uglyDucklingChar:Stop();
			s:WalkTo((px - dx)/10, 0, (pz - dz)/10);
		end
		memory.dist = dist;
		
		if(dist <= 10) then
			-- skip random walk
			if(targetNPC_id == 30362) then
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
			memory.LastWalkTime = 4500; -- random move after a short period of time
		end
		
		local uglyDucklingChar = uglyDuckling:ToCharacter();
		local nTime = ParaGlobal.GetGameTime();
		
		-- changes direction every [5,7] seconds.
		if((nTime - memory.LastWalkTime) > 1000 * math.random(5,7)) then
			-- select a new target randomly
			local s = uglyDucklingChar:GetSeqController();
			x = (math.random()*2-1)*radius + memory.born_x - dx;
			z = (math.random()*2-1)*radius + memory.born_z - dz;
			--log(x..", "..z..", "..memory.born_x..", "..memory.born_z.."\r\n");
			uglyDucklingChar:Stop();
			s:WalkTo(x, 0, z);
			-- save to memory
			memory.LastWalkTime = nTime;
		end
	end
end