--[[ FleaChick AI
Author: WangTian
Date: 2009/8/25
Desc: FleaChick AI

script/apps/Aries/NPCs/FollowPets/30202_FleaChick_AI.lua
	
]]

NPL.load("(gl)script/apps/Aries/Quest/NPCAIMemory.lua");

-- create class
local libName = "FleaChick_AI";
local FleaChick_AI = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCAI.FleaChick_AI", FleaChick_AI);

-- FleaChick_AI framemove
function FleaChick_AI.On_FrameMove()
	
	local chick = ParaScene.GetObject(sensor_name);
	local player = ParaScene.GetPlayer();
	
	if(chick:IsValid() == true and player:IsValid() == true) then
		local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30202);
		local NPC_id, instance = MyCompany.Aries.Quest.NPC.GetNpcIDAndInstanceFromCharacter(chick);
		-- each instance has its own memory
		if(instance) then
			memory[instance] = memory[instance] or {};
			memory = memory[instance];
			
			-- call the on framemove function at 1/10 rate
			memory.count = memory.count or 0;
			if(memory.count < 10) then
				memory.count = memory.count + 1;
				return;
			else
				memory.count = 0;
			end
		end
		
		local dx, dy, dz = chick:GetPosition();
		local px, py, pz = player:GetPosition();
		
		local targetNPC_id = MyCompany.Aries.Desktop.TargetArea.TargetNPC_id;
		local targetNPC_instance = MyCompany.Aries.Desktop.TargetArea.TargetNPC_instance;
		
		local dist = chick:DistanceTo(player);
		if(memory.dist and memory.dist > 5 and dist <= 5) then
			
			if(targetNPC_id == 30202 and targetNPC_instance ~= instance) then
				-- skip the bark and facing if the dog is not the selected instance
			else
				-- say some gossip when enter 5 meter range
				
				-- walk to the player a little step, automatically face the player
				local chickChar = chick:ToCharacter();
				local s = chickChar:GetSeqController();
				chickChar:Stop();
				s:WalkTo((px - dx)/10, 0, (pz - dz)/10);
			end
		end
		memory.dist = dist;
		
		if(dist <= 5) then
			-- skip random walk
			if(targetNPC_id == 30202 and targetNPC_instance ~= instance) then
				-- continue the random walk if the dog is not the selected instance
			else
				return;
			end
		end
		
		local radius = 10;
		
		if(memory.born_x == nil) then
			memory.born_x = dx;
		end
		if(memory.born_z == nil) then
			memory.born_z = dz;
		end
		
		if(memory.LastWalkTime == nil) then
			memory.LastWalkTime = 0;
		end
		
		local chickChar = chick:ToCharacter();
		local nTime = ParaGlobal.GetGameTime();
		
		-- changes direction every [3, 5] seconds.
		if((nTime - memory.LastWalkTime) > 1000 * math.random(3,5)) then
			-- select a new target randomly
			local s = chickChar:GetSeqController();
			x = (math.random()*2-1)*radius + memory.born_x - dx;
			z = (math.random()*2-1)*radius + memory.born_z - dz;
			--log(x..", "..z..", "..memory.born_x..", "..memory.born_z.."\r\n");
			chickChar:Stop();
			s:WalkTo(x, 0, z);
			-- save to memory
			memory.LastWalkTime = nTime;
		end
	end
end