--[[ CaiTou AI
Author: WangTian
Date: 2009/8/25
Desc: CaiTou AI

script/apps/Aries/NPCs/FollowPets/30163_CaiTou_AI.lua
	
]]

NPL.load("(gl)script/apps/Aries/Quest/NPCAIMemory.lua");

-- create class
local libName = "CaiTou_AI";
local CaiTou_AI = commonlib.gettable("MyCompany.Aries.Quest.NPCAI.CaiTou_AI");

-- CaiTou_AI framemove
function CaiTou_AI.On_FrameMove()
	-- 0.3s interval
	local mushroom = ParaScene.GetObject(sensor_name);
	local player = ParaScene.GetPlayer();
	
	if(mushroom:IsValid() == true and player:IsValid() == true) then
		local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30163);
		local NPC_id, instance = MyCompany.Aries.Quest.NPC.GetNpcIDAndInstanceFromCharacter(mushroom);
		
		-- each instance has its own memory
		if(instance) then
			memory[instance] = memory[instance] or {};
			memory = memory[instance];
		end
		
		local dx, dy, dz = mushroom:GetPosition();
		local px, py, pz = player:GetPosition();
		
		
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
		
		local mushroomChar = mushroom:ToCharacter();
		local nTime = ParaGlobal.GetGameTime();
		
		-- changes direction every [3, 5] seconds.
		if((nTime - memory.LastWalkTime) > 1000 * math.random(3,5)) then
			-- select a new target randomly
			local s = mushroomChar:GetSeqController();
			
			local centerx = 19882.87;
			local centerz = 19858.29;
			
			local deltax = 0;
			local deltaz = 0;
			while((deltax * deltax + deltaz * deltaz) < 100) do
				deltax = (math.random()*2-1)*radius + memory.born_x - centerx;
				deltaz = (math.random()*2-1)*radius + memory.born_z - centerz;
			end
			
			x = deltax + centerx - dx;
			z = deltaz + centerz - dz;
			--log(x..", "..z..", "..memory.born_x..", "..memory.born_z.."\r\n");
			mushroomChar:Stop();
			s:WalkTo(x, 0, z);
			-- save to memory
			memory.LastWalkTime = nTime;
		end
	end
end