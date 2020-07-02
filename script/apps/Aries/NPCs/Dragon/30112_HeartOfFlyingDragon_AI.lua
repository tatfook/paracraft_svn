--[[ HeartOfFlyingDragon AI
Author: WangTian
Date: 2009/7/22
Desc: HeartOfFlyingDragon AI

script/apps/Aries/NPCs/Dragon/30112_HeartOfFlyingDragon_AI.lua
	
]]

NPL.load("(gl)script/apps/Aries/Quest/NPCAIMemory.lua");

-- create class
local libName = "HeartOfFlyingDragon_AI";
local HeartOfFlyingDragon_AI = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCAI.HeartOfFlyingDragon_AI", HeartOfFlyingDragon_AI);

-- HeartOfFlyingDragon AI framemove
local count = 0;
function HeartOfFlyingDragon_AI.On_FrameMove()

	local heartOfFlyingDragon = ParaScene.GetObject(sensor_name);
	local player = ParaScene.GetPlayer();
	
	if(heartOfFlyingDragon:IsValid() == true and player:IsValid() == true) then
		local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30112);
		local NPC_id, instance = MyCompany.Aries.Quest.NPC.GetNpcIDAndInstanceFromCharacter(heartOfFlyingDragon);
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
		
		local dist = heartOfFlyingDragon:DistanceTo(player);
		if(memory.dist and memory.dist > 5 and dist <= 5) then
			if(memory.isDestroyed ~= true and commonlib.getfield("MyCompany.Aries.Quest.NPCs.WishLevel8.TriggerHeart")) then
				MyCompany.Aries.Quest.NPCs.WishLevel8.TriggerHeart(instance);
				memory.isDestroyed = true;
			end
		end
		memory.dist = dist;
	end
end