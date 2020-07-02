--[[
Title: deck attacker ai module server for Aries App
Author(s): WangTian
Date: 2013/6/21
Changes: 
Area: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Combat/ServerObject/AI_Modules/Deck_Attacker.lua");
------------------------------------------------------------
]]

-- create class
local libName = "AriesCombat_Server_Deck_Attacker";
local Deck_Attacker = commonlib.gettable("MyCompany.Aries.Combat_Server.AIModuleObjects.Deck_Attacker");

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

-- @params arena: arena object
function Deck_Attacker.PickCardForEachMob(arena, bBefore, bAfter)
	if(not arena) then
		log("error: Deck_Attacker.PickCardForEachMob got invalid arena: "..tostring(arena).."\n")
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
			-- only accept normal round cards
			if(not bBefore and not bAfter) then
				-- get mob pips count
				local pipscount = mob:GetPipsCount();
				local pipscount_power = mob:GetPowerPipsCount();
				-- pick cards
				local picked_card, target_ismob, target_id = mob:GetCardAndTarget_Deck_Attacker();

				local template = Card.GetCardTemplate(picked_card);
				if(not template) then
					log("error: card not valid for key:"..tostring(picked_card).." in function Deck_Attacker.PickCardForEachMob\n")
					mob:PickCard("Pass", 0, true, mob:GetID());
				elseif(picked_card and type(target_ismob) == "boolean" and type(target_id) == "number") then
					mob:PickCard(picked_card, 0, target_ismob, target_id);
				end
			end
		end
	end
	return pre_cast_speaks;
end