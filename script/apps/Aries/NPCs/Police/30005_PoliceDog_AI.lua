--[[ PoliceDog AI
Author: WangTian
Date: 2009/7/22
Desc: PoliceDog AI

script/apps/Aries/NPCs/Police/30005_PoliceDog_AI.lua
	
]]
NPL.load("(gl)script/apps/Aries/Quest/NPCAIMemory.lua");

-- create class
local libName = "PoliceDog_AI";
local PoliceDog_AI = commonlib.gettable("MyCompany.Aries.Quest.NPCAI.PoliceDog_AI");

-- Police dog AI framemove
function PoliceDog_AI.On_FrameMove()
	-- 0.3s interval

	local policeDog = ParaScene.GetObject(sensor_name);
	local player = ParaScene.GetPlayer();
	
	if(policeDog:IsValid() == true and player:IsValid() == true) then
		local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30005);
		local NPC_id, instance = MyCompany.Aries.Quest.NPC.GetNpcIDAndInstanceFromCharacter(policeDog);
		-- each instance has its own memory
		if(instance) then
			memory[instance] = memory[instance] or {};
			memory = memory[instance];
		end
		
		local dx, dy, dz = policeDog:GetPosition();
		local px, py, pz = player:GetPosition();
		
		local targetNPC_id = MyCompany.Aries.Desktop.TargetArea.TargetNPC_id;
		local targetNPC_instance = MyCompany.Aries.Desktop.TargetArea.TargetNPC_instance;
		
		local dist = policeDog:DistanceTo(player);
		if(memory.dist and memory.dist > 5 and dist <= 5) then
			
			if(targetNPC_id == 30005 and targetNPC_instance ~= instance) then
				-- skip the bark and facing if the dog is not the selected instance
			else
				-- say some gossip when enter 5 meter range
				--headon_speech.Speek(policeDog.name, headon_speech.GetBoldTextMCML("旺旺，旺旺"), 3);
				
				--ParaAudio.PlayStatic3DSound("DogBark", "PoliceDogBark_"..ParaGlobal.GenerateUniqueID(), dx, dy, dz);
				local name = "Audio/Haqi/DogBark.wav";
				MyCompany.Aries.Scene.PlayGameSound(name);
				
				-- walk to the player a little step, automatically face the player
				local policeDogChar = policeDog:ToCharacter();
				local s = policeDogChar:GetSeqController();
				policeDogChar:Stop();
				s:WalkTo((px - dx)/10, 0, (pz - dz)/10);
			end
		end
		memory.dist = dist;
		
		if(dist <= 5) then
			-- skip random walk
			if(targetNPC_id == 30005 and targetNPC_instance ~= instance) then
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
		
		local policeDogChar = policeDog:ToCharacter();
		local nTime = ParaGlobal.GetGameTime();
		
		-- changes direction every [3, 5] seconds.
		if((nTime - memory.LastWalkTime) > 1000 * math.random(3,5)) then
			-- select a new target randomly
			local s = policeDogChar:GetSeqController();
			x = (math.random()*2-1)*radius + memory.born_x - dx;
			z = (math.random()*2-1)*radius + memory.born_z - dz;
			--log(x..", "..z..", "..memory.born_x..", "..memory.born_z.."\r\n");
			policeDogChar:Stop();
			s:WalkTo(x, 0, z);
			-- save to memory
			memory.LastWalkTime = nTime;
		end
	end
end