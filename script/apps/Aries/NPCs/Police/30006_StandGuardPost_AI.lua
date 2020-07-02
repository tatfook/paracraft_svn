--[[ StandGuardPost AI
Author: WangTian
Date: 2009/7/26
Desc: StandGuardPost AI

script/apps/Aries/NPCs/Police/30006_StandGuardPost_AI.lua
	
]]

NPL.load("(gl)script/apps/Aries/Quest/NPCAIMemory.lua");

-- create class
local libName = "StandGuardPost_AI";
local StandGuardPost_AI = commonlib.gettable("MyCompany.Aries.Quest.NPCAI.StandGuardPost_AI");

-- Chief Hilton AI framemove
function StandGuardPost_AI.On_FrameMove()
	-- 0.3s interval

	local standGuardPost = ParaScene.GetObject(sensor_name);
	local player = ParaScene.GetPlayer();
	
	if(standGuardPost:IsValid() == true and player:IsValid() == true) then
		local NPC_id, instance = MyCompany.Aries.Quest.NPC.GetNpcIDAndInstanceFromCharacter(standGuardPost);
		local npcModel = MyCompany.Aries.Quest.NPC.GetNpcModelFromIDAndInstance(NPC_id, instance);
		
		--local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30006);
		--if(memory.BeginGuard == true) then
			--if(NPC_id == memory.BeginGuard_npc_id and instance == memory.BeginGuard_instance) then
				---- reset the memory
				--memory.BeginGuard = nil;
				--memory.GuardTime = ParaGlobal.GetGameTime();
				--
				--local postx, posty, postz = standGuardPost:GetPosition();
				--player:SetPosition(postx, posty + (0.81538677215576 - 0.50028675794601), postz);
				--player:SetFacing(standGuardPost:GetFacing());
				--local x, y, z = player:GetPosition();
				--local facing = player:GetFacing();
				--memory.standx = x;
				--memory.standy = y;
				--memory.standz = z;
				--memory.standfacing = facing;
				--
				---- set the follow pet position
				--local _follow = MyCompany.Aries.Pet.GetUserFollowObj();
				--if(_follow and _follow:IsValid() == true) then
					--local facing = standGuardPost:GetFacing();
					--_follow:SetPosition(postx + 2*math.cos(facing + 3.14/6), posty, postz - 2*math.sin(facing + 3.14/6));
					--_follow:SetFacing(standGuardPost:GetFacing());
				--end
				--local _mount = MyCompany.Aries.Pet.GetUserMountObj();
				--if(_mount and _mount:IsValid() == true and not player:equals(_mount)) then
					--local facing = standGuardPost:GetFacing();
					--_mount:SetPosition(postx + 2*math.cos(facing - 3.14/6), posty, postz - 2*math.sin(facing - 3.14/6));
					--_mount:SetFacing(standGuardPost:GetFacing());
				--end
			--end
		--end
		--if(memory.GuardTime) then
			----if((ParaGlobal.GetGameTime() - memory.GuardTime) > 10000) then
			--if((ParaGlobal.GetGameTime() - memory.GuardTime) > 10000) then
				---- player finished the guarding time
				--memory.GuardTime = nil;
				--MyCompany.Aries.Quest.NPCs.StandGuardPost.EndGuard();
			--end
			--local player_x, player_y, player_z = player:GetPosition();
			--local player_facing = player:GetFacing();
			--if(memory.standx ~= player_x or memory.standy ~= player_y or memory.standz ~= player_z or memory.standfacing ~= player_facing) then
				---- player moved a little bit
				--memory.GuardTime = nil;
				--log("WARNING: player moved during guarding, need some text feedback?\n");
			--end
		--end
		
		local dist = standGuardPost:DistanceTo(player);
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