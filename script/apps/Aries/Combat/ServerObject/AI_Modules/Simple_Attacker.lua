--[[
Title: simple attacker ai module server for Aries App
Author(s): WangTian
Date: 2009/4/7
Changes: 
-- 2011/4/18
--	simple_attacker is merged into the genes attacker
--		available_cards field is a default card pick field
Area: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Combat/ServerObject/AI_Modules/Simple_Attacker.lua");
------------------------------------------------------------
]]

-- create class
local libName = "AriesCombat_Server_Simple_Attacker";
local Simple_Attacker = commonlib.gettable("MyCompany.Aries.Combat_Server.AIModuleObjects.Simple_Attacker");

-- mob server object
local Mob = commonlib.gettable("MyCompany.Aries.Combat_Server.Mob");
-- player server object
local Player = commonlib.gettable("MyCompany.Aries.Combat_Server.Player");
-- ai module server
local AI_Module = commonlib.gettable("MyCompany.Aries.Combat_Server.AI_Module");
-- card server
local Card = commonlib.gettable("MyCompany.Aries.Combat_Server.Card");
-- combat server
local combat_server = commonlib.gettable("MyCompany.Aries.Combat_Server.combat_server");

-- max player count per arena
local max_player_count_per_arena = 4;

-- pick card from cards
-- @params cards: {{key, count},{key, count},{key, count}...}
-- @return: picked card key
local function PickFromCards(cards)
	local card_count = 0;
	local _, pair;
	for _, pair in ipairs(cards) do
		local card_key = pair[1];
		card_count = card_count + pair[2];
		local template = Card.GetCardTemplate(card_key)
		if(not template) then
			log("error: card not valid for key:"..tostring(card_key).." in function Simple_Attacker.PickCardForEachMob\n")
			return "Pass";
		end
	end
	local random_seq = math.random(0, card_count);
	local picked_card = "Pass";
	local _, pair;
	for _, pair in ipairs(cards) do
		random_seq = random_seq - pair[2];
		if(random_seq <= 0) then
			picked_card = pair[1];
			break;
		end
	end
	return picked_card;
end

-- @params arena: arena object
function Simple_Attacker.PickCardForEachMob(arena)
	local pre_cast_speaks = {};
	-- record each kind of player
	local first_player_nid = nil;
	local last_player_nid = nil;
	local max_hp_player_nid = nil;
	local min_hp_player_nid = nil;
	local max_hp = 0;
	local min_hp = 999999;
	local i;
	local alive_and_active_nids = {};
	for i = 1, max_player_count_per_arena do
		local nid = arena.player_nids[i];
		if(nid) then
			local player = Player.GetPlayerCombatObj(nid);
			if(player and player:IsAlive() and player:IsCombatActive()) then
				table.insert(alive_and_active_nids, nid);
				if(not first_player_nid) then
					first_player_nid = nid;
				end
				last_player_nid = nid;
				if(player:GetCurrentHP() > max_hp) then
					max_hp = player:GetCurrentHP();
					max_hp_player_nid = nid;
				end
				if(player:GetCurrentHP() < min_hp) then
					min_hp = player:GetCurrentHP();
					min_hp_player_nid = nid;
				end
			end
		end
	end
	if(#alive_and_active_nids <= 0) then
		-- no alive and active nids available pick Pass
		local index, id;
		for index, id in ipairs(arena.mob_ids) do
			local mob = Mob.GetMobByID(id);
			if(mob and mob:IsAlive()) then
				mob:PickCard("Pass", 0, true, mob:GetID());
			end
		end
		return pre_cast_speaks;
	end
	local i = math.random(1, #alive_and_active_nids);
	local random_player_nid = alive_and_active_nids[i];
	
	-- record each kind of mob
	local max_lost_hp_mob_id = nil;
	local max_lost_hp = 0;
	local index, id;
	for index, id in ipairs(arena.mob_ids) do
		local mob = Mob.GetMobByID(id);
		if(mob and mob:IsAlive()) then
			local lost_hp = mob:GetMaxHP() - mob:GetCurrentHP();
			if(lost_hp > 0 and lost_hp > max_lost_hp) then
				max_lost_hp_mob_id = mob:GetID();
				max_lost_hp = lost_hp;
			end
		end
	end

	-- pass 4: pick mob card
	local index, id;
	for index, id in ipairs(arena.mob_ids) do
		local mob = Mob.GetMobByID(id);
		if(mob and mob:IsAlive()) then
			
			-- get mob pips count
			local pipscount = mob:GetPipsCount();
			local pipscount_power = mob:GetPowerPipsCount();
			-- pick cards
			local picked_card = "Pass";
			local nonzeropipcards, zeropipcards = mob:GetAvailableCards();
			local picked_nonzeropipcard = PickFromCards(nonzeropipcards);
			local picked_zeropipcard = PickFromCards(zeropipcards);
			if(picked_nonzeropipcard) then
				if(mob:CanCastSpell(picked_nonzeropipcard)) then
					picked_card = picked_nonzeropipcard;
				else
					picked_card = picked_zeropipcard;
				end
			end

			if(mob:GetTemplateKey() == "config/Aries/Mob/MobTemplate_FireRockyOgre02.xml") then
				mob.memory = mob.memory or {};
				if(mob.memory.last_pickcard_hp) then
					local max_hp = mob:GetMaxHP();
					local ratio_pre = mob.memory.last_pickcard_hp / max_hp;
					local ratio_this = mob:GetCurrentHP() / max_hp;
					if(ratio_pre > 0.6 and ratio_this <= 0.6) then
						-- pick special card for this boss
						mob:PickCard("Ice_GlobalShield", 0, true, mob:GetID());
						pre_cast_speaks[mob:GetID()] = "让你尝尝我的厉害!";
						mob.memory.last_pickcard_hp = mob:GetCurrentHP();
						return pre_cast_speaks;
					end
				end
				mob.memory.last_pickcard_hp = mob:GetCurrentHP();
			end
			
			if(mob:GetTemplateKey() == "config/Aries/Mob/YYsDream/MobTemplate_ShadowSmashBullYYsDream_S2.xml") then
				mob.memory = mob.memory or {};
				if(mob.memory.last_pickcard_hp) then
					local max_hp = mob:GetMaxHP();
					local ratio_pre = mob.memory.last_pickcard_hp / max_hp;
					local ratio_this = mob:GetCurrentHP() / max_hp;
					if(ratio_pre > 0.5 and ratio_this <= 0.5) then
						-- pick special card for this boss
						if(ratio_this <= 0.3) then
							mob:PickCard("Ice_AreaAttack_Level4_ShadowSmashBullYYsDream_S2", 0, false, min_hp_player_nid);
							pre_cast_speaks[mob:GetID()] = "你们彻底把我惹火了，接受我的狂暴攻击吧！";
							mob.memory.last_pickcard_hp = mob:GetCurrentHP();
							return pre_cast_speaks;
						else
							mob:PickCard("Ice_AreaAttack_Level4_ShadowSmashBullYYsDream_S2", 0, false, min_hp_player_nid);
							pre_cast_speaks[mob:GetID()] = "哼，我要把你们一网打尽！";
							mob.memory.last_pickcard_hp = mob:GetCurrentHP();
							return pre_cast_speaks;
						end
					end
				end
				mob.memory.last_pickcard_hp = mob:GetCurrentHP();
			end
			
			if(mob:GetTemplateKey() == "config/Aries/Mob/TreasureHouse/FlamingPhoenixIsland/MobTemplate_GreatIceBearLower.xml") then
				mob.memory = mob.memory or {};
				if(mob.memory.last_pickcard_hp) then
					local max_hp = mob:GetMaxHP();
					local ratio_pre = mob.memory.last_pickcard_hp / max_hp;
					local ratio_this = mob:GetCurrentHP() / max_hp;
					if(ratio_pre > 0.5 and ratio_this <= 0.5) then
						-- pick special card for this boss
						mob:PickCard("Fire_AreaAttack_Level4_1000Accuracy", 0, false, min_hp_player_nid);
						pre_cast_speaks[mob:GetID()] = "让你尝尝我的厉害!!";
						mob.memory.last_pickcard_hp = mob:GetCurrentHP();
						return pre_cast_speaks;
					end
				end
				mob.memory.last_pickcard_hp = mob:GetCurrentHP();
			end
			if(mob:GetTemplateKey() == "config/Aries/Mob/TreasureHouse/FrostRoarIsland/MobTemplate_GreatIceBearLower.xml") then
				mob.memory = mob.memory or {};
				if(mob.memory.last_pickcard_hp) then
					local max_hp = mob:GetMaxHP();
					local ratio_pre = mob.memory.last_pickcard_hp / max_hp;
					local ratio_this = mob:GetCurrentHP() / max_hp;
					if(ratio_pre > 0.4 and ratio_this <= 0.4) then
						-- pick special card for this boss
						mob:PickCard("Life_AreaHeal_Level3_1000Accuracy", 0, true, mob:GetID());
						--pre_cast_speaks[mob:GetID()] = "让你尝尝我的厉害!!";
						mob.memory.last_pickcard_hp = mob:GetCurrentHP();
						return pre_cast_speaks;
					end
					if(ratio_pre > 0.2 and ratio_this <= 0.2) then
						-- pick special card for this boss
						mob:PickCard("Ice_AreaAttack_Level4_1000Accuracy", 0, false, min_hp_player_nid);
						pre_cast_speaks[mob:GetID()] = "让你尝尝我的厉害!!";
						mob.memory.last_pickcard_hp = mob:GetCurrentHP();
						return pre_cast_speaks;
					end
				end
				mob.memory.last_pickcard_hp = mob:GetCurrentHP();
			end
			if(mob:GetTemplateKey() == "config/Aries/Mob/TreasureHouse/AncientEgyptIsland/MobTemplate_GreatIceBearLower.xml") then
				mob.memory = mob.memory or {};
				if(mob.memory.last_pickcard_hp) then
					local max_hp = mob:GetMaxHP();
					local ratio_pre = mob.memory.last_pickcard_hp / max_hp;
					local ratio_this = mob:GetCurrentHP() / max_hp;
					if(ratio_pre > 0.5 and ratio_this <= 0.5) then
						-- pick special card for this boss
						mob:PickCard("Storm_SingleAttack_WildBolt_Level2_1000Accuracy", 0, false, min_hp_player_nid);
						pre_cast_speaks[mob:GetID()] = "让你尝尝我的厉害!!";
						mob.memory.last_pickcard_hp = mob:GetCurrentHP();
						return pre_cast_speaks;
					end
					if(ratio_pre > 0.4 and ratio_this <= 0.4) then
						-- pick special card for this boss
						mob:PickCard("Life_AreaHeal_Level3_1000Accuracy", 0, true, mob:GetID());
						--pre_cast_speaks[mob:GetID()] = "让你尝尝我的厉害!!";
						mob.memory.last_pickcard_hp = mob:GetCurrentHP();
						return pre_cast_speaks;
					end
				end
				mob.memory.last_pickcard_hp = mob:GetCurrentHP();
			end

			-- choose target according to target
			local picked_card_lower = string.lower(picked_card);
			if(string.find(picked_card_lower, "attack")) then
				if(mob:GetTemplateKey() == "config/Aries/Mob/YYsDream/MobTemplate_ShadowSmashBullYYsDream_S2.xml") then
					local max_hp = mob:GetMaxHP();
					local ratio = mob:GetCurrentHP() / max_hp;
					if(ratio <= 0.3) then
						pre_cast_speaks[mob:GetID()] = "你们彻底把我惹火了，接受我的狂暴攻击吧！";
					end
				end
				if(string.find(picked_card_lower, "areaattack")) then
					mob:PickCard(picked_card, 0, false, first_player_nid);
				elseif(string.find(picked_card_lower, "attack")) then
					local r = math.random(0, 200);
					if(r < 100) then
						mob:PickCard(picked_card, 0, false, min_hp_player_nid);
					else
						mob:PickCard(picked_card, 0, false, random_player_nid);
					end
				end
			elseif(string.find(picked_card_lower, "blade")) then
				mob:PickCard(picked_card, 0, true, mob:GetID());
			elseif(string.find(picked_card_lower, "shield")) then
				mob:PickCard(picked_card, 0, true, mob:GetID());
			elseif(string.find(picked_card_lower, "trap")) then
				mob:PickCard(picked_card, 0, false, random_player_nid);
			elseif(string.find(picked_card_lower, "weakness")) then
				mob:PickCard(picked_card, 0, false, random_player_nid);
			elseif(string.find(picked_card_lower, "absorb")) then
				if(not max_lost_hp_mob_id) then
					mob:PickCard(picked_card, 0, true, mob:GetID());
				else
					mob:PickCard(picked_card, 0, true, max_lost_hp_mob_id);
				end
			elseif(string.find(picked_card_lower, "heal")) then
				if(not max_lost_hp_mob_id) then
					mob:PickCard("Pass", 0, true, mob:GetID());
				else
					mob:PickCard(picked_card, 0, true, max_lost_hp_mob_id);
				end
			elseif(string.find(picked_card_lower, "pass")) then
				mob:PickCard(picked_card, 0, true, mob:GetID());
			elseif(string.find(picked_card_lower, "singlestun")) then
				mob:PickCard(picked_card, 0, false, random_player_nid);
			else
				log("error: no card target matching the key:"..tostring(picked_card).." in Simple_Attacker.PickCardForEachMob\n")
				mob:PickCard("Pass", 0, true, mob:GetID());
			end
		end
	end
	return pre_cast_speaks;
end