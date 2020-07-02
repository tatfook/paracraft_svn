--[[ DirtyElk AI
Author: WangTian
Date: 2009/8/25
Desc: DirtyElk AI

script/apps/Aries/NPCs/FollowPets/30207_DirtyElk_AI.lua
	
]]

NPL.load("(gl)script/apps/Aries/Quest/NPCAIMemory.lua");

-- create class
local libName = "DirtyElk_AI";
local DirtyElk_AI = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCAI.DirtyElk_AI", DirtyElk_AI);

-- DirtyElk_AI framemove
function DirtyElk_AI.On_FrameMove()
	
	local dirtyElk = ParaScene.GetObject(sensor_name);
	local player = ParaScene.GetPlayer();
	
	if(dirtyElk:IsValid() == true and player:IsValid() == true) then
		local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30207);
		local NPC_id, instance = MyCompany.Aries.Quest.NPC.GetNpcIDAndInstanceFromCharacter(dirtyElk);
		
		-- call the on framemove function at 1/10 rate
		memory.count = memory.count or 0;
		if(memory.count < 10) then
			memory.count = memory.count + 1;
			return;
		else
			memory.count = 0;
		end
		
		
		local dx, dy, dz = dirtyElk:GetPosition();
		local px, py, pz = player:GetPosition();
		
		local targetNPC_id = MyCompany.Aries.Desktop.TargetArea.TargetNPC_id;
		local targetNPC_instance = MyCompany.Aries.Desktop.TargetArea.TargetNPC_instance;
		
		if(memory.isClean == true) then
			local dist = dirtyElk:DistanceTo(player);
			if(memory.dist and memory.dist > 5 and dist <= 5) then
				
				if(targetNPC_id == 30207) then
					-- say some gossip when enter 5 meter range
					
					-- walk to the player a little step, automatically face the player
					local dirtyElkChar = dirtyElk:ToCharacter();
					local s = dirtyElkChar:GetSeqController();
					dirtyElkChar:Stop();
					s:WalkTo((px - dx)/10, 0, (pz - dz)/10);
				end
			end
			memory.dist = dist;
			
			if(dist <= 5) then
				return;
				---- skip random walk
				--if(targetNPC_id == 30207 and targetNPC_instance ~= instance) then
					---- continue the random walk if the dog is not the selected instance
				--else
					--return;
				--end
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
		
		local dirtyElkChar = dirtyElk:ToCharacter();
		local nTime = ParaGlobal.GetGameTime();
		
		-- changes direction every [3, 5] seconds.
		if((nTime - memory.LastWalkTime) > 1000 * math.random(3,5)) then
			-- select a new target randomly
			local s = dirtyElkChar:GetSeqController();
			x = (math.random()*2-1)*radius + memory.born_x - dx;
			z = (math.random()*2-1)*radius + memory.born_z - dz;
			--log(x..", "..z..", "..memory.born_x..", "..memory.born_z.."\r\n");
			dirtyElkChar:Stop();
			s:WalkTo(x, 0, z);
			-- save to memory
			memory.LastWalkTime = nTime;
		end
	end
end