--[[ FarmlandShop AI
Author: Leio
Date: 2009/11/30
Desc: FarmlandShop AI

script/apps/Aries/NPCs/Farm/30367_FarmlandShop_AI.lua
	
]]

NPL.load("(gl)script/apps/Aries/Quest/NPCAIMemory.lua");

-- create class
local libName = "FarmlandShop_AI";
local FarmlandShop_AI = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCAI.FarmlandShop_AI", FarmlandShop_AI);

local BOLD = headon_speech.GetBoldTextMCML;
local count = 0;
function FarmlandShop_AI.On_FrameMove()
	
	local plant = ParaScene.GetObject(sensor_name);
	local player = ParaScene.GetPlayer();
	
	if(plant:IsValid() == true and player:IsValid() == true) then 
		
		local NPC_id, instance = MyCompany.Aries.Quest.NPC.GetNpcIDAndInstanceFromCharacter(plant);
		local npcModel = MyCompany.Aries.Quest.NPC.GetNpcModelFromIDAndInstance(NPC_id, instance);
		
		local dist = plant:DistanceTo(player);
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