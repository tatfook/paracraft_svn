--[[ Beehive AI
Author: WangTian
Date: 2009/7/26
Desc: Beehive AI

script/apps/Aries/NPCs/Playground/30094_Beehive_AI.lua
	
]]

NPL.load("(gl)script/apps/Aries/Quest/NPCAIMemory.lua");

-- create class
local libName = "Beehive_AI";
local Beehive_AI = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCAI.Beehive_AI", Beehive_AI);

-- Chief Hilton AI framemove
function Beehive_AI.On_FrameMove()
	local beehive = ParaScene.GetObject(sensor_name);
	local player = ParaScene.GetPlayer();
	
	if(beehive:IsValid() == true and player:IsValid() == true) then
		local NPC_id, instance = MyCompany.Aries.Quest.NPC.GetNpcIDAndInstanceFromCharacter(beehive);
		local npcModel = MyCompany.Aries.Quest.NPC.GetNpcModelFromIDAndInstance(NPC_id, instance);
		
		local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30094);
		
		local dist = beehive:DistanceTo(player);
		if(dist <= 10) then
			-- flashing when enter 5 meter range
			if(npcModel and npcModel:IsValid() == true) then
				local render_tech = npcModel:GetField("render_tech", nil);
				if(render_tech == 3) then
					npcModel:SetField("render_tech", 10); -- TECH_SIMPLE_MESH_NORMAL_SELECTED
				end
			end
		elseif(dist > 10) then
			if(npcModel and npcModel:IsValid() == true) then
				local render_tech = npcModel:GetField("render_tech", nil);
				if(render_tech == 10) then
					npcModel:SetField("render_tech", 3); -- TECH_SIMPLE_MESH_NORMAL
				end
			end
		end
	end
end