--[[ 
script/apps/Aries/NPCs/FollowPets/30211_YoYoDeer_Entity_AI.lua
]]

NPL.load("(gl)script/apps/Aries/Quest/NPCAIMemory.lua");

-- create class
local libName = "YoYoDeer_Entity_AI";
local YoYoDeer_Entity_AI = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCAI.YoYoDeer_Entity_AI", YoYoDeer_Entity_AI);

-- YoYoDeer_Entity_AI framemove
function YoYoDeer_Entity_AI.On_FrameMove()
	
	local deer = ParaScene.GetObject(sensor_name);
	local player = ParaScene.GetPlayer();
	
	if(deer:IsValid() == true and player:IsValid() == true) then
		local NPC_id, instance = MyCompany.Aries.Quest.NPC.GetNpcIDAndInstanceFromCharacter(deer);
		if(not NPC_id) then
			return;
		end
		local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(NPC_id);
		-- call the on framemove function at 1/10 rate
		memory.count = memory.count or 0;
		if(memory.count < 10) then
			memory.count = memory.count + 1;
			return;
		else
			memory.count = 0;
		end
		
		local dx, dy, dz = deer:GetPosition();
		--local px, py, pz = player:GetPosition();
		--
		--local targetNPC_id = MyCompany.Aries.Desktop.TargetArea.TargetNPC_id;
		--local targetNPC_instance = MyCompany.Aries.Desktop.TargetArea.TargetNPC_instance;
		--
		--local dist = deer:DistanceTo(player);
		--if(memory.dist and memory.dist > 5 and dist <= 5) then
			--
			---- walk to the player a little step, automatically face the player
			--local deerChar = deer:ToCharacter();
			--local s = deerChar:GetSeqController();
			--deerChar:Stop();
			--s:WalkTo((px - dx)/10, 0, (pz - dz)/10);
		--end
		--memory.dist = dist;
		
		--if(dist <= 5) then
			---- skip random walk
			--if(targetNPC_id == 30211 and targetNPC_instance ~= instance) then
				---- continue the random walk if the dog is not the selected instance
			--else
				--return;
			--end
		--end
		
		local radius = 5;
		
		if(memory.born_x == nil) then
			memory.born_x = dx;
		end
		if(memory.born_z == nil) then
			memory.born_z = dz;
		end
		
		if(memory.LastWalkTime == nil) then
			memory.LastWalkTime = 0;
		end
		
		local deerChar = deer:ToCharacter();
		local nTime = ParaGlobal.GetGameTime();
		
		-- changes direction every [3, 5] seconds.
		if((nTime - memory.LastWalkTime) > 1000 * math.random(3,5)) then
			-- select a new target randomly
			local s = deerChar:GetSeqController();
			x = (math.random()*2-1)*radius + memory.born_x - dx;
			z = (math.random()*2-1)*radius + memory.born_z - dz;
			--log(x..", "..z..", "..memory.born_x..", "..memory.born_z.."\r\n");
			deerChar:Stop();
			s:WalkTo(x, 0, z);
			-- save to memory
			memory.LastWalkTime = nTime;
		end
	end
end