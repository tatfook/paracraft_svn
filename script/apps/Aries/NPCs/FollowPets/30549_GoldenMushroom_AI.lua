--[[ GoldenMushroom AI
Author: WangTian
Date: 2009/8/25
Desc: GoldenMushroom AI

script/apps/Aries/NPCs/FollowPets/30549_GoldenMushroom_AI.lua
	
]]

NPL.load("(gl)script/apps/Aries/Quest/NPCAIMemory.lua");

-- create class
local libName = "GoldenMushroom_AI";
local GoldenMushroom_AI = commonlib.gettable("MyCompany.Aries.Quest.NPCAI.GoldenMushroom_AI");

-- GoldenMushroom_AI framemove
function GoldenMushroom_AI.On_FrameMove()
	
	local goldenMushroom = ParaScene.GetObject(sensor_name);
	local player = ParaScene.GetPlayer();
	
	if(goldenMushroom:IsValid() == true and player:IsValid() == true) then
		local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30549);
		local NPC_id, instance = MyCompany.Aries.Quest.NPC.GetNpcIDAndInstanceFromCharacter(goldenMushroom);
		
		-- pass 1: check if hit on the Mushroom instance itself
		if(memory.hit_gsid == 9507) then
			--local dx, dy, dz = GoldenMushroom:GetPosition();
			--if(math.abs(memory.hitpoint_x - dx) < 1 and 
				--math.abs(memory.hitpoint_y - dy) < 1 and 
				--math.abs(memory.hitpoint_z - dz) < 1) then
				---- hit on self
				--MyCompany.Aries.Quest.NPCs.GoldenMushroom.On_Hit(instance);
				---- reset the hit gsid in case of multiple hit response
				--memory.hit_gsid = nil;
			--end
			local _, name;
			for _, name in pairs(memory.hitObjNameList or {}) do
				if(name == goldenMushroom.name) then
					-- hit on self
					--echo("111111");
					MyCompany.Aries.Quest.NPCs.GoldenMushroom.On_Hit();
					-- reset the hit gsid in case of multiple hit response
					memory.hit_gsid = nil;
				end
			end
		end
				
		-- each instance has its own memory
		--if(instance) then
			--memory[instance] = memory[instance] or {};
			--memory = memory[instance];
			--
			---- call the on framemove function at 1/10 rate
			--memory.count = memory.count or 0;
			--if(memory.count < 10) then
				--memory.count = memory.count + 1;
				--return;
			--else
				--memory.count = 0;
			--end
		--end
		
		-- countdown if shrinking
		--if(memory.shrinkCountDown) then
			--if((ParaGlobal.GetGameTime() - memory.shrinkStartTime) > memory.shrinkCountDown) then
				--MyCompany.Aries.Quest.NPCs.GoldenMushroom.On_Shrink(instance);
			--end
		--end
		
		local dx, dy, dz = goldenMushroom:GetPosition();
		local px, py, pz = player:GetPosition();
		
		local targetNPC_id = MyCompany.Aries.Desktop.TargetArea.TargetNPC_id;
		local targetNPC_instance = MyCompany.Aries.Desktop.TargetArea.TargetNPC_instance;
		
		if(memory.isFull == true) then
			local dist = goldenMushroom:DistanceTo(player);
			if(memory.dist and memory.dist > 5 and dist <= 5) then
				
				if(targetNPC_id == 30549 and targetNPC_instance ~= instance) then
					-- skip the bark and facing if the dog is not the selected instance
				else
					-- say some gossip when enter 5 meter range
					
					-- walk to the player a little step, automatically face the player
					local goldenMushroomChar = goldenMushroom:ToCharacter();
					local s = goldenMushroomChar:GetSeqController();
					goldenMushroomChar:Stop();
					s:WalkTo((px - dx)/10, 0, (pz - dz)/10);
				end
			end
			memory.dist = dist;
			
			if(dist <= 5) then
				return;
				---- skip random walk
				--if(targetNPC_id == 30549 and targetNPC_instance ~= instance) then
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
		
		local goldenMushroomChar = goldenMushroom:ToCharacter();
		local nTime = ParaGlobal.GetGameTime();
		
		-- changes direction every [3, 5] seconds.
		if((nTime - memory.LastWalkTime) > 1000 * math.random(3,5)) then
			-- select a new target randomly
			local s = goldenMushroomChar:GetSeqController();
			x = (math.random()*2-1)*radius + memory.born_x - dx;
			z = (math.random()*2-1)*radius + memory.born_z - dz;
			--log(x..", "..z..", "..memory.born_x..", "..memory.born_z.."\r\n");
			goldenMushroomChar:Stop();
			s:WalkTo(x, 0, z);
			-- save to memory
			memory.LastWalkTime = nTime;
		end
	end
end