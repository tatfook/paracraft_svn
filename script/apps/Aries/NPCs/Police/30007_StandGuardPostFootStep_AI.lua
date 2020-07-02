--[[ StandGuardPostFootStep AI
Author: WangTian
Date: 2009/7/22
Desc: StandGuardPostFootStep AI

script/apps/Aries/NPCs/Dragon/30007_StandGuardPostFootStep_AI.lua
	
]]

NPL.load("(gl)script/apps/Aries/Quest/NPCAIMemory.lua");

-- create class
local libName = "StandGuardPostFootStep_AI";
local StandGuardPostFootStep_AI = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCAI.StandGuardPostFootStep_AI", StandGuardPostFootStep_AI);

-- StandGuardPostFootStep AI framemove
local count = 0;
function StandGuardPostFootStep_AI.On_FrameMove()

	local StandGuardPostFootStep = ParaScene.GetObject(sensor_name);
	local player = ParaScene.GetPlayer();
	
	if(StandGuardPostFootStep:IsValid() == true and player:IsValid() == true) then
		local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30007);
		local NPC_id, instance = MyCompany.Aries.Quest.NPC.GetNpcIDAndInstanceFromCharacter(StandGuardPostFootStep);
		-- each instance has its own memory
		if(instance) then
			memory[instance] = memory[instance] or {};
			memory = memory[instance];
			
			-- call the on framemove function at 1/10 rate
			memory.count = memory.count or 0;
			if(memory.count < 5) then
				memory.count = memory.count + 1;
				return;
			else
				memory.count = 0;
			end
		end
		
		local dist = StandGuardPostFootStep:DistanceTo(player);
		if(memory.dist and memory.dist > 5 and dist <= 5) then
			if(memory.isDestroyed ~= true and commonlib.getfield("MyCompany.Aries.Quest.NPCs.StandGuardPost.TriggerStep")) then
				MyCompany.Aries.Quest.NPCs.StandGuardPost.TriggerStep(instance);
				memory.isDestroyed = true;
			end
		end
		memory.dist = dist;
	end
end