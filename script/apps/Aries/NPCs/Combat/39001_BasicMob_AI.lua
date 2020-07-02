--[[ 
Title: BasicMob AI
Author: WangTian
Date: 2009/7/22
Desc: BasicMob AI

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/Combat/39001_BasicMob_AI.lua");
------------------------------------------------------------	
]]
NPL.load("(gl)script/apps/Aries/Quest/NPCAIMemory.lua");
NPL.load("(gl)script/ide/headon_speech.lua");
NPL.load("(gl)script/apps/Aries/Player/GossipAI.lua");
local GossipAI = commonlib.gettable("MyCompany.Aries.Quest.NPCAI.GossipAI");

local NPCAIMemory = commonlib.gettable("MyCompany.Aries.Quest.NPCAIMemory");
local NPC = commonlib.gettable("MyCompany.Aries.Quest.NPC");
local MsgHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
local ObjectManager = commonlib.gettable("MyCompany.Aries.Combat.ObjectManager");

local math_mod = math.mod
local math_random = math.random
local ParaScene_GetObject = ParaScene.GetObject;
local ParaGlobal_GetGameTime = ParaGlobal.GetGameTime
local LOG = LOG;
-- create class
local libName = "BasicMob_AI";
local BasicMob_AI = commonlib.gettable("MyCompany.Aries.Quest.NPCAI.BasicMob_AI");

function BasicMob_AI.OnLoadMobTalkData()
end

-- AI framemove, every 0.3 seconds
function BasicMob_AI.On_FrameMove()
	local mob = ParaScene_GetObject(sensor_name);
	
	if(mob:IsValid() == true) then
		local memory = NPCAIMemory.GetMemory(39001);
		local NPC_id, instance = NPC.GetNpcIDAndInstanceFromCharacter(mob);
		memory[instance] = memory[instance] or {};
		memory = memory[instance];
		-- get the most recent mob data table
		local mob_data = MsgHandler.Get_mob_data_by_id(instance);
		if(not mob_data) then
			LOG.warn("can not find mob : %d from data", instance);
			return
		end
		local arena = MsgHandler.Get_arena_data_by_mob_id(instance);
		
		-- make it invisible if no hp. 
		if(mob_data.current_hp <= 0) then
			mob:SetVisible(false);
			mob:SetField("SkipPicking", true);
		else
			mob:SetVisible(true);
			mob:SetField("SkipPicking", false);
		end

		-- if mob is in combat 
		local bInCombat = arena.bIncludedAnyPlayer;
		if(bInCombat) then
			-- if not mounted, we will stop and mount the mob to an arena slot, and remove head on text 
			if(not memory.is_mounted) then
				memory.is_mounted = true;
				-- make it OPC movement style without physics, so that it will not fall down.
				mob:SetField("MovementStyle", 4);
				ObjectManager.MountNPCOnSlot(39001, mob_data.id, arena.arena_id, mob:GetDynamicField("slot_id", 5));
				-- NPC.ChangeHeadonText(39001, mob_data.id, "")
				mob:ToCharacter():Stop();
			end
			if(arena.bIncludedMyselfInArena and not memory.is_headon_hidden) then
				memory.is_headon_hidden = true;
				NPC.ChangeHeadonText(39001, mob_data.id, "")
			end
			-- reset memory.LastWalkTime on Combat
			-- at least walk after one step
			memory.LastWalkTime = 0;
			return;
		else
			if(mob_data.asset_ccs) then
				-- hide ccs mobs if not in combat
				local m_x, m_y, m_z = mob:GetPosition();
				mob:SetPosition(m_x, arena.p_y - 50, m_z);
				return;
			end

			local bHideIdleMobs = ObjectManager.GetIsHideIdleMobs();
			if(bHideIdleMobs) then
				local m_x, m_y, m_z = mob:GetPosition();
				mob:SetPosition(m_x, arena.p_y - 50, m_z);
				return;
			else
				local m_x, m_y, m_z = mob:GetPosition();
				if(m_y < arena.p_y - 50) then
					mob:SetPosition(m_x, arena.p_y, m_z);
				end
			end
			-- if mounted, we will show the head on text once again. 
			if(memory.is_mounted) then
				memory.is_mounted = false;
				mob:SetField("MovementStyle", mob:GetDynamicField("real_movementstyle", 0));
				ObjectManager.UnMountNPCFromSlot(39001, mob_data.id);
				if(memory.is_headon_hidden) then
					memory.is_headon_hidden = false;
					local displayname = mob_data.displayname.." "..mob_data.level.."级";
					NPC.ChangeHeadonText(39001, mob_data.id, displayname);
				end
			elseif(memory.has_talk ~= false) then
				local rule = GossipAI.GetRuleByName(mob_data.client_talk_ai_name) or GossipAI.GetRuleByName(mob_data.displayname)
				if(rule) then
					memory.has_talk = true;
					local random_gossip_index = 12345;
					local sentence = (rule:GetNextSentence(nil, mob_data.id));
					if(sentence and mob:IsVisible()) then
						headon_speech.Speek(sensor_name, sentence, 3);
					end
				else
					memory.has_talk = false;
					if(mob_data.client_talk_ai_name) then
						LOG.std(nil, "warn", "BasicMob_AI", "no gossip ai is found for mob(%s, %s)", tostring(mob_data.displayname), tostring(mob_data.client_talk_ai_name));
					end
				end
			end
		end
		
		-- prevent the mob drop before the land model asset is loaded
		-- especially useful for indoor mobs, like fire carven
		
		local m_x, m_y, m_z = mob:GetPosition();
		local center_y = arena.p_y or my;

		if(m_y < (center_y - 10)) then
			mob:SetPosition(m_x, center_y, m_z);
			m_y = center_y;
		end
		
		-- Xizhi: refactored to be more efficient
		local nTime = ParaGlobal_GetGameTime();
		local random_interval_second = 2 + math_mod(instance, 11) / 4;
		local LastWalkTime = memory.LastWalkTime or 0;
		
		-- changes direction every [3, 5] seconds.
		if((nTime - LastWalkTime) > 1000 * random_interval_second) then
			
			local radius = 12;
			if(System.options.mc) then
				local worldInfo = WorldManager:GetCurrentWorld()
				if(worldInfo.enter_combat_range) then
					radius = math.floor(worldInfo.enter_combat_range * 0.5);
				end
			end
			if(memory.born_x == nil) then
				memory.born_x = arena.p_x or m_x;
			end
			if(memory.born_z == nil) then
				memory.born_z = arena.p_z or m_z;
			end
			
			-- select a new target randomly
			local mobChar = mob:ToCharacter();
			local s = mobChar:GetSeqController();
			x = (math_random()*2-1)*radius + memory.born_x - m_x;
			z = (math_random()*2-1)*radius + memory.born_z - m_z;
			--log(x..", "..z..", "..memory.born_x..", "..memory.born_z.."\r\n");
			mobChar:Stop();
			s:WalkTo(x, 0, z);
			-- save to memory
			memory.LastWalkTime = nTime;
			
			-- face to player if enter combat zone
			if(System.options.version == "teen") then
				if(not bInCombat and LastWalkTime ~= 0) then
					-- at least walk after one step
					local dist = mob:DistanceToPlayerSq();
					--local last_dist = mob:GetField("LastDistanceToPlayerSq", 0);
					--mob:SetField("LastDistanceToPlayerSq", dist);
					if(dist < 1500) then
						local mobChar = mob:ToCharacter();
						mobChar:Stop();
						local cx, cy, cz = ParaScene.GetPlayer():GetPosition();
						Map3DSystem.App.CCS.CharacterFaceTarget(mob, cx, cy, cz);
						headon_speech.Speak(mob.name, [[<img src="Texture/Aries/HeadOn/exclamation_mob_alert_fps10_a003.png" style="margin-left:0px;margin-top:48px;width:64px;height:64px;"/>]], 
							1, true, true, nil, -1000, nil, 4);
						return;
					end
				end
			end
		end
	end
end