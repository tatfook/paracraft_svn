--[[
Title: A snail that walks randomly
Author(s): LiXizhi
Date: 2009.12.18
Desc: AI of NPC King Kong snail. It walks randomly in front of DrDoctor's lab, 
and stops when user select it. There is a NPC dialog associated with it,when user clicks it. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/Police/30376_CrystalBunny_AI.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Quest/NPCAIMemory.lua");

-- create class
local CrystalBunny_AI = commonlib.gettable("MyCompany.Aries.Quest.NPCAI.CrystalBunny_AI");
local NPCAIMemory = commonlib.gettable("MyCompany.Aries.Quest.NPCAIMemory");
local TargetArea = commonlib.gettable("MyCompany.Aries.Desktop.TargetArea");

local WalkPositions = {
	{ 19919.86328125, 8.8811407089233, 20091.171875 },
	{ 19921.287109375, 8.8811521530151, 20096.8671875 },
	{ 19914.30859375, 8.8809909820557, 20095.091796875 },
	{ 19912.94921875, 8.8811473846436, 20101.208984375 },
	{ 19908.07421875, 8.8809957504272, 20096.333984375 },
	{ 19912.8203125, 8.880989074707, 20092.853515625 },
	{ 19920.953125, 8.881178855896, 20090.99609375 },
	{ 19919.962890625, 8.8810749053955, 20083.876953125 },
};



function CrystalBunny_AI.On_FrameMove()
	local thisNPC = ParaScene.GetObject(sensor_name);
	if(thisNPC:IsValid()) then 
	
		-- walk randomly to some predefined locations, and stops when user select it. 
		local memory = NPCAIMemory.GetMemory(30376);
		
		-- call the on framemove function at 1/10 rate
		memory.count = memory.count or 0;
		if(memory.count < 10) then
			memory.count = memory.count + 1;
			return;
		else
			memory.count = 0;
		end
		
		local targetNPC_id = TargetArea.TargetNPC_id;
		local targetNPC_instance = TargetArea.TargetNPC_instance;
		
		local dist = thisNPC:DistanceTo(ParaScene.GetPlayer());
		
		if(dist <= 10) then
			-- stop the NPC, when user select it
			if(targetNPC_id == 30376) then
				thisNPC:ToCharacter():Stop();
				return;
			end
		end
		
		memory.LastWalkTime = memory.LastWalkTime or 0;
		
		local curTime = ParaGlobal.GetGameTime();
		-- changes direction every [3, 5] seconds.
		if((curTime - memory.LastWalkTime) > 1000 * math.random(3,6)) then
			-- pick a new target position randomly
			local old_x, old_y, old_z = thisNPC:GetPosition();
			local dest_point = WalkPositions[math.random(1,#WalkPositions)];
			
			thisNPC:ToCharacter():Stop();
			thisNPC:ToCharacter():MoveTo(dest_point[1] - old_x, 0, dest_point[3] - old_z);
			
			-- save to memory
			memory.LastWalkTime = curTime;
		end
	end	
end