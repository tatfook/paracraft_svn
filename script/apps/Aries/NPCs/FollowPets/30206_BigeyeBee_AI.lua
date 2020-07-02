--[[ BigeyeBee AI
Author: WangTian
Date: 2009/8/25
Desc: BigeyeBee AI

script/apps/Aries/NPCs/FollowPets/30206_BigeyeBee_AI.lua
	
]]

NPL.load("(gl)script/apps/Aries/Quest/NPCAIMemory.lua");

-- create class
local libName = "BigeyeBee_AI";
local BigeyeBee_AI = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCAI.BigeyeBee_AI", BigeyeBee_AI);

-- BigeyeBee_AI framemove
function BigeyeBee_AI.On_FrameMove()
	
	local bigeyeBee = ParaScene.GetObject(sensor_name);
	local player = ParaScene.GetPlayer();
	
	if(bigeyeBee:IsValid() == true and player:IsValid() == true) then
		local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30206);
		local NPC_id, instance = MyCompany.Aries.Quest.NPC.GetNpcIDAndInstanceFromCharacter(bigeyeBee);
		
		local dx, dy, dz = bigeyeBee:GetPosition();
		local px, py, pz = player:GetPosition();
		
		local dist = bigeyeBee:DistanceTo(player);
		if((memory.dist == nil or memory.dist > 5 ) and dist <= 5) then
			-- say some gossip when enter 5 meter range
			headon_speech.Speek(bigeyeBee.name, headon_speech.GetBoldTextMCML("呀，它们跑的好快呀，我掉队了！"), 3, true);
			
			-- walk to the player a little step, automatically face the player
			local bigeyeBeeChar = bigeyeBee:ToCharacter();
			local s = bigeyeBeeChar:GetSeqController();
			bigeyeBeeChar:Stop();
			s:WalkTo((px - dx)/100, 0, (pz - dz)/100);
		end
		memory.dist = dist;
	end
end