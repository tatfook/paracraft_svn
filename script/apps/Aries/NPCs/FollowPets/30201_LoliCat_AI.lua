--[[ Lolicat AI
Author: WangTian
Date: 2009/8/25
Desc: Lolicat AI

script/apps/Aries/NPCs/FollowPets/30201_LoliCat_AI.lua
	
]]

NPL.load("(gl)script/apps/Aries/Quest/NPCAIMemory.lua");

-- create class
local libName = "LoliCat_AI";
local LoliCat_AI = commonlib.gettable("MyCompany.Aries.Quest.NPCAI.LoliCat_AI");

local NPCAIMemory = commonlib.gettable("MyCompany.Aries.Quest.NPCAIMemory");

-- LoliCat_AI framemove
function LoliCat_AI.On_FrameMove()
	-- 0.3s interval
	local memory = NPCAIMemory.GetMemory(30201);
	local cat = ParaScene.GetObject(sensor_name);
	local player = ParaScene.GetPlayer();
	
	if(cat:IsValid() == true and player:IsValid() == true) then
		
		local dx, dy, dz = cat:GetPosition();
		local px, py, pz = player:GetPosition();
		
		local targetNPC_id = MyCompany.Aries.Desktop.TargetArea.TargetNPC_id;
		local targetNPC_instance = MyCompany.Aries.Desktop.TargetArea.TargetNPC_instance;
		
		local dist = cat:DistanceTo(player);
		if(memory.dist and memory.dist > 3 and dist <= 3) then
			if(memory.startedHiding == nil) then
				-- say some gossip when enter 3 meter range
				local catChar = cat:ToCharacter();
				catChar:Stop();
				--headon_speech.Speek(cat.name, headon_speech.GetBoldTextMCML("我是萝莉猫，我们来玩藏猫猫吧，喵～"), 3);
				
				-- walk to the player a little step, automatically face the player
				local catChar = cat:ToCharacter();
				local s = catChar:GetSeqController();
				catChar:Stop();
				s:WalkTo((px - dx)/10, 0, (pz - dz)/10);
			end
		end
		
		if(memory.startedHiding == true and memory.dist and memory.dist > 7 and dist <= 7) then
			local r = math.random(0, 100);
			if(memory.mustHideCount) then
				memory.mustHideCount = memory.mustHideCount - 1;
				r = 101;
				if(memory.mustHideCount == 0) then
					memory.mustHideCount = nil;
				end
			end
			if(r >= 101) then
				-- not caught
				memory.lockcatCount = 15;
				local uncaughtWord = "";
				local r = math.random(0, 100);
				if(r < 20) then
					uncaughtWord = "没找到，嘿嘿～";
				elseif(r < 40) then
					uncaughtWord = "躲咯躲咯，再来找呀～";
				elseif(r < 60) then
					uncaughtWord = "眼神真好，可是我躲的更快～";
				elseif(r < 80) then
					uncaughtWord = "哎呀没地方躲咯～";
				elseif(r <= 100) then
					uncaughtWord = "想找着我可没那么容易，来找我呀哈哈。";
				end
				headon_speech.Speek(cat.name, headon_speech.GetBoldTextMCML(uncaughtWord), 1, true);
			else
				memory.isCaught = true;
				-- auto speek to and select cat
				MyCompany.Aries.Desktop.TargetArea.TalkToNPC(30201, nil, true);
			end
		end
		memory.dist = dist;
		
		if(memory.startedHiding == true) then
			-- stop the random walk AI script while cat is hiding
			return;
		end
		if(dist <= 3) then
			-- skip random walk
			return;
		end
		
		local radius = 5;
		
		if(memory.bornPos == nil) then
			memory.bornPos = {dx, dy, dz};
		end
		
		if(memory.LastWalkTime == nil) then
			memory.LastWalkTime = 0;
		end
		
		local catChar = cat:ToCharacter();
		local nTime = ParaGlobal.GetGameTime();
		
		-- changes direction every [3, 5] seconds.
		if((nTime - memory.LastWalkTime) > 1000 * math.random(3,5)) then
			-- select a new target randomly
			local s = catChar:GetSeqController();
			x = (math.random()*2-1)*radius + memory.bornPos[1] - dx;
			z = (math.random()*2-1)*radius + memory.bornPos[3] - dz;
			--log(x..", "..z..", "..memory.born_x..", "..memory.born_z.."\r\n");
			catChar:Stop();
			s:WalkTo(x, 0, z);
			-- save to memory
			memory.LastWalkTime = nTime;
		end
	end
end