--[[ DrDoctor AI
Author: WangTian
Date: 2009/7/22
Desc: DrDoctor AI

script/apps/Aries/NPCs/Police/30101_DrDoctor_AI.lua
	
]]

NPL.load("(gl)script/apps/Aries/Quest/NPCAIMemory.lua");

-- create class
local libName = "DrDoctor_AI";
local DrDoctor_AI = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCAI.DrDoctor_AI", DrDoctor_AI);

-- Chief Hilton AI framemove
local count = 0;
function DrDoctor_AI.On_FrameMove()
	-- call the on framemove function at 1/10 rate
	if(count < 10) then
		count = count + 1;
		return;
	else
		count = 0;
	end
	
	local drDoctor = ParaScene.GetObject(sensor_name);
	local player = ParaScene.GetPlayer();
	
	if(drDoctor:IsValid() == true and player:IsValid() == true) then
		local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30101);
		if(memory.startcounttime) then
			if((ParaGlobal.GetGameTime() - memory.startcounttime) > 30000) then
				memory.startcounttime = nil;
			end
		end
		
		--local NPC_id, instance = MyCompany.Aries.Quest.NPC.GetNpcIDAndInstanceFromCharacter(drDoctor);
		--
		--local dist = drDoctor:DistanceTo(player);
		--if(memory.dist and memory.dist > 5 and dist <= 5) then
			---- say some gossip when enter 5 meter range
			--headon_speech.Speek(drDoctor.name, headon_speech.GetBoldTextMCML("I'm Dr. Doctor£¡--"), 3);
		--end
		--memory.dist = dist;
	end
end