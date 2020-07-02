--[[
Title: Common functions for wisp client behavior
Author(s): Gosling, refactored by LiXizhi on 2011.5.29
Date: 2010/6/18
Desc: When the player is close enough to the wisp, automatically pick it. 
The wisp will move slowly around its born position within a small radius. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/Combat/30397_Wisp_AI.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Quest/NPCAIMemory.lua");
NPL.load("(gl)script/apps/Aries/NPCs/Combat/30397_Wisp.lua");
local Wisp = commonlib.gettable("MyCompany.Aries.Quest.NPCs.Wisp");
local NPCAIMemory = commonlib.gettable("MyCompany.Aries.Quest.NPCAIMemory");
local NPC = commonlib.gettable("MyCompany.Aries.Quest.NPC");
local MsgHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");
local GSL_client = commonlib.gettable("Map3DSystem.GSL_client");

local math_random = math.random
-- create class
local libName = "Wisp_AI";
local Wisp_AI = commonlib.gettable("MyCompany.Aries.Quest.NPCAI.Wisp_AI");

-- Wisp AI framemove
function Wisp_AI.On_FrameMove()
	local wisp = ParaScene.GetObject(sensor_name);
	
	if(wisp:IsValid()) then
		--local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30397);
		local NPC_id, instance = NPC.GetNpcIDAndInstanceFromCharacter(wisp);
		local memory = NPCAIMemory.GetMemory(NPC_id);
		-- each instance has its own memory
		if(instance) then
			memory[instance] = memory[instance] or {};
			memory = memory[instance];
		end
		
		local player = ParaScene.GetPlayer();
		local dx, dy, dz = wisp:GetPosition();
		local px, py, pz = player:GetPosition();
		
		-- automatically try picking the wisp when player is close enough to it. 
		local dist = ((px-dx)*(px-dx) + (pz-dz)*(pz-dz));
		if(dist < 3) then
			Wisp.TryPick(Wisp.ToWispId(NPC_id));
		end 
		
		--[[
		local radius = 4;
		local radius_y = 0.3;
		
		local ground_y = ParaTerrain.GetElevation(dx, dz)
		if(dy - ground_y < 0.5 ) then
			radius_y = dy - ground_y;
		end

		if(memory.born_x == nil) then
			memory.born_x, memory.born_y, memory.born_z = Wisp:GetWispPositionByInstID(Wisp.ToWispId(NPC_id))
		end
		
		local nTime = ParaGlobal.GetGameTime();
		
		if(memory.LastWalkTime == nil) then
			memory.target_x = (math_random()*2-1)*radius + memory.born_x;
			memory.target_y = (math_random()*2-1)*radius + memory.born_y;
			memory.target_z = (math_random()*2-1)*radius + memory.born_z;
			memory.LastWalkTime = nTime;
			memory.during_time = 1000 * math_random(3,5);
		end
		
		-- changes direction every [3, 5] seconds.
		if((nTime - memory.LastWalkTime) > memory.during_time) then
			-- select a new target randomly
			--local s = wispChar:GetSeqController();
			memory.target_x = (math_random()*2-1)*radius + memory.born_x;
			memory.target_y = (math_random()*2-1)*radius_y + memory.born_y;
			memory.target_z = (math_random()*2-1)*radius + memory.born_z;
			--commonlib.applog(string.format("Wisp_AI.On_FrameMove: %d",NPC_id));
			
			--wispChar:Stop();
			--s:WalkTo(x, 0, z);
			-- save to memory
			memory.LastWalkTime = nTime;
			memory.during_time = 1000 * math_random(3,5);
		end
		if(memory.last_elapsedTime == nil) then
			memory.last_elapsedTime = memory.LastWalkTime;
		end 
		local wx, wy, wz = wisp:GetPosition();
		local step_time = nTime - memory.last_elapsedTime;
		local step = step_time/(memory.during_time - (memory.last_elapsedTime - memory.LastWalkTime));
		memory.last_elapsedTime = nTime;
		local npx,npy,npz = wx+(memory.target_x-wx)*step, wy+(memory.target_y-wy)*step, wz+(memory.target_z-wz)*step
		--local angle = memory.LastAngle - (2*pi*step)
		wisp:SetPosition(npx,npy,npz);
		]]
	end
end