--[[
Title: genes attacker ai module server for Aries App
Author(s): WangTian
Date: 2011/3/9
Area: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Combat/ServerObject/AI_Modules/Genes_Attacker.lua");
------------------------------------------------------------
]]

-- create class
local libName = "AriesCombat_Server_Genes_Attacker";
local Genes_Attacker = commonlib.gettable("MyCompany.Aries.Combat_Server.AIModuleObjects.Genes_Attacker");

-- mob server object
local Mob = commonlib.gettable("MyCompany.Aries.Combat_Server.Mob");
-- player server object
local Player = commonlib.gettable("MyCompany.Aries.Combat_Server.Player");
-- ai module server
local AI_Module = commonlib.gettable("MyCompany.Aries.Combat_Server.AI_Module");
-- card server
local Card = commonlib.gettable("MyCompany.Aries.Combat_Server.Card");
-- arena
local Arena = commonlib.gettable("MyCompany.Aries.Combat_Server.Arena");
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
			log("error: card not valid for key:"..tostring(card_key).." in function Genes_Attacker.PickCardForEachMob\n")
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
-- @params bBefore: mob receive a bonus round to play specific card BEFORE or AFTER the round
-- @params bAfter: mob receive a bonus round to play specific card BEFORE or AFTER the round
function Genes_Attacker.PickCardForEachMob(arena, bBefore, bAfter)
	if(not arena) then
		log("error: Genes_Attacker.PickCardForEachMob got invalid arena: "..tostring(arena).."\n")
		return {};
	end
	local pre_cast_speaks = {};

	local friendlys, hostiles = arena:GetFriendlyAndHostileUnits("far");

	-- check if all players dead
	local isAllHostilesDead = true;
	local _, unit;
	for _, unit in ipairs(hostiles) do
		local unit = Arena.GetCombatUnit(unit.isMob, unit.id)
		if(unit and unit:IsAlive()) then
			isAllHostilesDead = false;
			break;
		end
	end

	--local _, unit;
	--for _, unit in ipairs(hostiles) do
		--if(not unit.isMob) then
			--local player = Player.GetPlayerCombatObj(unit.id);
			--if(player) then
			--end
		--end
		--
		--local unit = Arena.GetCombatUnit(unit.isMob, unit.id)
		--if(unit and unit:IsAlive()) then
			--bFarSideDefeated = false;
			--break;
		--end
	--end
	
	-- pass 4: pick mob card
	local index, id;
	for index, id in ipairs(arena.mob_ids) do
		local mob = Mob.GetMobByID(id);
		if(mob and mob:IsAlive()) then
			-- clear pick card
			mob:ClearPickedCard();
			-- get mob pips count
			local pipscount = mob:GetPipsCount();
			local pipscount_power = mob:GetPowerPipsCount();
			-- pick cards
			local picked_card = "Pass";
			local target_hostile, target_friendly, speak, motion, force_pip_cost;
			local accuracy_boost = 0;
			if(not bBefore and not bAfter) then
				picked_card, target_hostile, target_friendly, accuracy_boost, speak, motion, force_pip_cost = mob:GetCardAndTarget_genes_attacker();
			elseif(bBefore) then
				picked_card, target_hostile, target_friendly, accuracy_boost, speak, motion, force_pip_cost = mob:GetCardAndTarget_genes_attacker_bonus_round(true, nil);
			elseif(bAfter) then
				picked_card, target_hostile, target_friendly, accuracy_boost, speak, motion, force_pip_cost = mob:GetCardAndTarget_genes_attacker_bonus_round(nil, true);
			end
			pre_cast_speaks[mob:GetID()] = speak;

			local template = Card.GetCardTemplate(picked_card);
			if(not template) then
				log("error: card not valid for key:"..tostring(picked_card).." in function Genes_Attacker.PickCardForEachMob\n")
				mob:PickCard("Pass", 0, true, mob:GetID());
			elseif(picked_card and type(target_hostile) == "boolean" and type(target_friendly) == "number") then
				-- this is a fixed target from ai
				local ismob = target_hostile;
				local id = target_friendly;
				mob:PickCard(picked_card, 0, ismob, id, accuracy_boost, motion, force_pip_cost);
			else
				-- get hostile target object
				local is_pickedcard_attack = false;
				if(string.find(string.lower(picked_card), "attack")) then
					is_pickedcard_attack = true;
				end
				target_hostile = mob:GetHostileTarget_genes_attacker(target_hostile, template.params.damage_school, is_pickedcard_attack);
				target_friendly = mob:GetFriendlyTarget_genes_attacker(target_friendly);
				
				-- choose target according to target
				local picked_card_lower = string.lower(picked_card);
				if(not target_hostile) then
					mob:PickCard("Pass", 0, true, mob:GetID());
				elseif(not target_friendly) then
					mob:PickCard("Pass", 0, true, mob:GetID());
				elseif(string.find(picked_card_lower, "attack")) then
					-- pick card
					if(string.find(picked_card_lower, "areaattack")) then
						mob:PickCard(picked_card, 0, false, target_hostile:GetID(), accuracy_boost, motion, force_pip_cost);
					elseif(string.find(picked_card_lower, "areadotattack")) then
						mob:PickCard(picked_card, 0, false, target_hostile:GetID(), accuracy_boost, motion, force_pip_cost);
					elseif(string.find(picked_card_lower, "attack")) then
						mob:PickCard(picked_card, 0, target_hostile:IsMob(), target_hostile:GetID(), accuracy_boost, motion, force_pip_cost);
					end
				elseif(string.find(picked_card_lower, "blade")) then
					mob:PickCard(picked_card, 0, target_friendly:IsMob(), target_friendly:GetID(), accuracy_boost, motion, force_pip_cost);
				elseif(string.find(picked_card_lower, "shield")) then
					mob:PickCard(picked_card, 0, target_friendly:IsMob(), target_friendly:GetID(), accuracy_boost, motion, force_pip_cost);
				elseif(string.find(picked_card_lower, "trap")) then
					mob:PickCard(picked_card, 0, target_hostile:IsMob(), target_hostile:GetID(), accuracy_boost, motion, force_pip_cost);
				elseif(string.find(picked_card_lower, "weakness")) then
					mob:PickCard(picked_card, 0, target_hostile:IsMob(), target_hostile:GetID(), accuracy_boost, motion, force_pip_cost);
				elseif(string.find(picked_card_lower, "absorb")) then
					mob:PickCard(picked_card, 0, target_friendly:IsMob(), target_friendly:GetID(), accuracy_boost, motion, force_pip_cost);
				elseif(string.find(picked_card_lower, "heal")) then
					mob:PickCard(picked_card, 0, target_friendly:IsMob(), target_friendly:GetID(), accuracy_boost, motion, force_pip_cost);
				elseif(string.find(picked_card_lower, "pass")) then
					mob:PickCard(picked_card, 0, true, mob:GetID(), accuracy_boost, motion, force_pip_cost);
				elseif(string.find(picked_card_lower, "globalaura")) then
					mob:PickCard(picked_card, 0, true, mob:GetID());
				elseif(string.find(picked_card_lower, "resist_miniaura")) then
					mob:PickCard(picked_card, 0, target_friendly:IsMob(), target_friendly:GetID(), accuracy_boost, motion, force_pip_cost);
				elseif(string.find(picked_card_lower, "singlestun")) then
					mob:PickCard(picked_card, 0, target_hostile:IsMob(), target_hostile:GetID(), accuracy_boost, motion, force_pip_cost);
				elseif(string.find(picked_card_lower, "singlefreeze")) then
					mob:PickCard(picked_card, 0, target_hostile:IsMob(), target_hostile:GetID(), accuracy_boost, motion, force_pip_cost);
				elseif(string.find(picked_card_lower, "areastunabsorb")) then
					mob:PickCard(picked_card, 0, target_friendly:IsMob(), target_friendly:GetID(), accuracy_boost, motion, force_pip_cost);
				elseif(string.find(picked_card_lower, "areastun")) then
					mob:PickCard(picked_card, 0, false, target_hostile:GetID(), accuracy_boost, motion, force_pip_cost);
				elseif(string.find(picked_card_lower, "areacontrol")) then
					mob:PickCard(picked_card, 0, false, target_hostile:GetID(), accuracy_boost, motion, force_pip_cost);
				elseif(string.find(picked_card_lower, "areacleanse")) then
					mob:PickCard(picked_card, 0, target_friendly:IsMob(), target_friendly:GetID(), accuracy_boost, motion, force_pip_cost);
				elseif(string.find(picked_card_lower, "prism")) then
					mob:PickCard(picked_card, 0, target_hostile:IsMob(), target_hostile:GetID(), accuracy_boost, motion, force_pip_cost);
				elseif(string.find(picked_card_lower, "removepositivecharm")) then
					mob:PickCard(picked_card, 0, target_hostile:IsMob(), target_hostile:GetID(), accuracy_boost, motion, force_pip_cost);
				elseif(string.find(picked_card_lower, "removepositiveward")) then
					mob:PickCard(picked_card, 0, target_hostile:IsMob(), target_hostile:GetID(), accuracy_boost, motion, force_pip_cost);
				elseif(string.find(picked_card_lower, "steal")) then
					mob:PickCard(picked_card, 0, target_hostile:IsMob(), target_hostile:GetID(), accuracy_boost, motion, force_pip_cost);
				elseif(string.find(picked_card_lower, "removenegativeward")) then
					mob:PickCard(picked_card, 0, target_friendly:IsMob(), target_friendly:GetID(), accuracy_boost, motion, force_pip_cost);
				elseif(string.find(picked_card_lower, "removenegativecharm")) then
					mob:PickCard(picked_card, 0, target_friendly:IsMob(), target_friendly:GetID(), accuracy_boost, motion, force_pip_cost);
				elseif(string.find(picked_card_lower, "boostpowerpipchance")) then
					mob:PickCard(picked_card, 0, target_friendly:IsMob(), target_friendly:GetID(), accuracy_boost, motion, force_pip_cost);
				elseif(string.find(picked_card_lower, "areahealweakness")) then
					mob:PickCard(picked_card, 0, false, target_hostile:GetID(), accuracy_boost, motion, force_pip_cost);
				elseif(string.find(picked_card_lower, "healweakness")) then
					mob:PickCard(picked_card, 0, target_hostile:IsMob(), target_hostile:GetID(), accuracy_boost, motion, force_pip_cost);
				else
					log("error: no card target matching the key:"..tostring(picked_card).." in Genes_Attacker.PickCardForEachMob\n")
					mob:PickCard("Pass", 0, true, mob:GetID());
				end
			end
		end
	end
	return pre_cast_speaks;
end