--[[ ChiefHilton AI
Author: WangTian
Date: 2009/7/22
Desc: ChiefHilton AI

script/apps/Aries/NPCs/Police/30001_ChiefHilton_AI.lua
	
]]

NPL.load("(gl)script/apps/Aries/Quest/NPCAIMemory.lua");

-- create class
local libName = "ChiefHilton_AI";
local ChiefHilton_AI = commonlib.gettable("MyCompany.Aries.Quest.NPCAI.ChiefHilton_AI");

-- Chief Hilton AI framemove
local count = 0;
-- 0.3s interval
function ChiefHilton_AI.On_FrameMove()
	local chiefHilton = ParaScene.GetObject(sensor_name);
	local player = ParaScene.GetPlayer();
	
	if(chiefHilton:IsValid() == true and player:IsValid() == true) then
		local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30001);
		local NPC_id, instance = MyCompany.Aries.Quest.NPC.GetNpcIDAndInstanceFromCharacter(chiefHilton);
		
		local dist = chiefHilton:DistanceTo(player);
		if(memory.dist and memory.dist > 5 and dist <= 5) then
			-- say some gossip when enter 5 meter range
			headon_speech.Speek(chiefHilton.name, headon_speech.GetBoldTextMCML("哈奇小镇警官招募中，欢迎勇敢聪明的小哈奇加入！"), 3);
		end
		memory.dist = dist;
	end
end