--[[ MysteryButton AI
Author: Leio
Date: 2009/11/30
Desc: MysteryButton AI

script/apps/Aries/NPCs/Police/30101_MysteryButton_AI.lua
	
]]

NPL.load("(gl)script/apps/Aries/Quest/NPCAIMemory.lua");

-- create class
local libName = "MysteryButton_AI";
local MysteryButton_AI = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCAI.MysteryButton_AI", MysteryButton_AI);

local BOLD = headon_speech.GetBoldTextMCML;

function MysteryButton_AI.On_FrameMove()
	-- 0.3s interval
	local mysteryButton = ParaScene.GetObject(sensor_name);
	local player = ParaScene.GetPlayer();
	
	if(mysteryButton:IsValid() == true and player:IsValid() == true) then 
		local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30106);
		
		--local dist = mysteryButton:DistanceTo(player);
		--if(memory.dist and memory.dist > 5 and dist <= 5) then
			---- say some gossip when enter 5 meter range
			--headon_speech.Speek(mysteryButton.name, BOLD("我发光了！"), 3, true);
		--end
		--memory.dist = dist;
		
		local NPC_id, instance = MyCompany.Aries.Quest.NPC.GetNpcIDAndInstanceFromCharacter(mysteryButton);
		local npcModel = MyCompany.Aries.Quest.NPC.GetNpcModelFromIDAndInstance(NPC_id, instance);
		
		local dist = mysteryButton:DistanceTo(player);
		if(dist <= 5) then
			-- flashing when enter 5 meter range
			if(npcModel and npcModel:IsValid() == true) then
				local render_tech = npcModel:GetField("render_tech", nil);
				if(render_tech == 3) then
					npcModel:SetField("render_tech", 10); -- TECH_SIMPLE_MESH_NORMAL_SELECTED
				end
			end
		elseif(dist > 5) then
			if(npcModel and npcModel:IsValid() == true) then
				local render_tech = npcModel:GetField("render_tech", nil);
				if(render_tech == 10) then
					npcModel:SetField("render_tech", 3); -- TECH_SIMPLE_MESH_NORMAL
				end
			end
		end
	end	
end