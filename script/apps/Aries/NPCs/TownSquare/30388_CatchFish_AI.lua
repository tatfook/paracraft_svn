--[[ CatchFish AI
Author: Leio
Date: 2010/05/20
Desc: CatchFish AI

script/apps/Aries/NPCs/TownSquare/30388_CatchFish_AI.lua
	
]]

NPL.load("(gl)script/apps/Aries/Quest/NPCAIMemory.lua");
NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30388_CatchFish.lua");

-- create class
local CatchFish_AI = commonlib.gettable("MyCompany.Aries.Quest.NPCAI.CatchFish_AI");
local NPCAIMemory = commonlib.gettable("MyCompany.Aries.Quest.NPCAIMemory");
local TargetArea = commonlib.gettable("MyCompany.Aries.Desktop.TargetArea");

local WalkPositions = {
	{ 20076.2109375, -3, 19451.64453125},
	{ 20075.814453125, -3, 19442.966796875},
	{ 20086.466796875, -3, 19433.572265625},
	{ 20079.529296875, -3, 19466.03125},
	{ 20070.638671875, -3, 19452.05859375},
	--{ 20090.517578125, -3, 19447.26171875},
	--{ 20069.517578125, -3, 19434.9453125},
	--{ 20085.455078125, -3, 19434.28515625},
	--{ 20083.978515625, -3, 19444.1171875},
	--{ 20103.716796875, -3, 19441.5},
};
function CatchFish_AI.On_FrameMove()
	local thisNPC = ParaScene.GetObject(sensor_name);
	if(thisNPC:IsValid()) then 
		-- walk randomly to some predefined locations, and stops when user select it. 
		local memory = NPCAIMemory.GetMemory(30388);
		
		local att = thisNPC:GetAttributeObject();
		att:SetField("MovementStyle", 4)
		
		--local level = ParaScene.GetGlobalWaterLevel();
		--local x, y, z = thisNPC:GetPosition();
		--ParaScene.AddWaterRipple(x, level, z)
		
		MyCompany.Aries.Quest.NPCs.CatchFish.OnHitNet(thisNPC)
		
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