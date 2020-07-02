--[[ PoliceMedalDisplayBox AI
Author: WangTian
Date: 2009/7/26
Desc: PoliceMedalDisplayBox AI

script/apps/Aries/NPCs/Police/30003_PoliceMedalDisplayBox_AI.lua
	
]]

NPL.load("(gl)script/apps/Aries/Quest/NPCAIMemory.lua");

-- create class
local libName = "PoliceMedalDisplayBox_AI";
local PoliceMedalDisplayBox_AI = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCAI.PoliceMedalDisplayBox_AI", PoliceMedalDisplayBox_AI);

-- Chief Hilton AI framemove
local count = 0;
function PoliceMedalDisplayBox_AI.On_FrameMove()
	-- call the on framemove function at 1/10 rate
	if(count < 10) then
		count = count + 1;
		return;
	else
		count = 0;
	end
	
	local policeMedalDisplayBox = ParaScene.GetObject(sensor_name);
	local player = ParaScene.GetPlayer();
	
	if(policeMedalDisplayBox:IsValid() == true and player:IsValid() == true) then
		local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30003);
		local NPC_id, instance = MyCompany.Aries.Quest.NPC.GetNpcIDAndInstanceFromCharacter(policeMedalDisplayBox);
		local npcModel = MyCompany.Aries.Quest.NPC.GetNpcModelFromIDAndInstance(NPC_id, instance);
		
		local dist = policeMedalDisplayBox:DistanceTo(player);
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