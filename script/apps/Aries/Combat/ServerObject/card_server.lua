--[[
Title: combat system card server for Aries App
Author(s): WangTian
Date: 2009/4/7
Area: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Combat/ServerObject/card_server.lua");
------------------------------------------------------------
]]

local pairs = pairs
local ipairs = ipairs
local tostring = tostring
local tonumber = tonumber
local type = type
local string_format = string.format;
local table_insert = table.insert;
local string_lower = string.lower;
local math_ceil = math.ceil;
local format = format;

NPL.load("(gl)script/kids/3DMapSystemItem/PowerItemManager.lua");
local PowerItemManager = commonlib.gettable("Map3DSystem.Item.PowerItemManager");

local combat_server = commonlib.gettable("MyCompany.Aries.Combat_Server.combat_server");
-- mob server object
local Mob = commonlib.gettable("MyCompany.Aries.Combat_Server.Mob");
-- player server object
local Player = commonlib.gettable("MyCompany.Aries.Combat_Server.Player");

-- create class
local Card = commonlib.gettable("MyCompany.Aries.Combat_Server.Card");

-- arena server object
local Arena = commonlib.gettable("MyCompany.Aries.Combat_Server.Arena");

-- threat config
local threat_config = {};

-- card templates
local card_templates = {};

-- charm and ward
local charms = {};
local wards = {};
local miniauras = {};
local globalauras = {};

-- charms with dispel
local charms_with_dispel = {};

-- charm and ward
local debug_never_fizzles = false;

-- charm and ward
local debug_always_fizzles = false;

-- standard stun absorb ward id, if stunned four of these wards will be appended in case of chain stunning
local stunabsorb_ward_id = 31;

-- globalshield ward id
local globalshield_ward_id = 27;

-- splash damage to siblin unit ratio
local splash_damage_siblin_ratio = 0.83;

-- max spell_penetration
local MAX_SPELL_PENETRATION = 70;

-- max reflect damage
local MAX_REFLECT_DAMAGE = 5000;

-- splash damage threat ratio
local splash_damage_threat_ratio = 0.2;

-- splash manipulation threat ratio
local splash_manipulation_threat_ratio = 0.2;

-- area heal threat ratio
local areaheal_threat_ratio = 0.2;

-- ice area attack threat ratio
local ice_areaattack_threat_ratio = 2;

-- damage threat ratio
local damage_threat_ratio_fire = 0.7;
local damage_threat_ratio_ice = 2.0;
local damage_threat_ratio_storm = 0.65;
local damage_threat_ratio_life = 1.0;
local damage_threat_ratio_death = 0.8;

-- heal threat ratio
local heal_threat_ratio = 0.3;

-- critical strike damage ratio
local critical_strike_damage_ratio = 1.3;

-- dodge damage ratio
local dodge_damage_ratio = 0.5;

-- 致命一击和绝对防御保护回合，触发效果后，在指定的protect_rounds_for_remedy回合内，不会再次触发效果
local protect_rounds_for_remedy = 6;

-- 风暴印记 儿童版第一次使用
local storm_charging_wards = {93, 94, 95, 96, 97};

-- revivable card key name
local base_revivable_card_name = {
	["Life_SingleHeal_ForLife_Level2"] = true,
	["Life_SingleHealWithHOT_Level5"] = true,
	["Life_SingleHeal_LevelX"] = true,
	["Life_Pet_SingleHeal_Nymphora"] = true,
	["Life_Pet_SingleHeal_Level4"] = true,
	["Death_SingleHealWithImmolate_Level3"] = true,
	["Balance_Rune_SingleHeal_Level2"] = true,
	["Balance_AreaHeal_DragonLight"] = true,
	["Balance_SingleHealWithHOT_Snake"] = true,
	["Balance_Rune_SingleHeal_LongCD"] = true,
};
-- this card can't kill target,the target remain 1 point hp at least
local non_lethal_card_name = {
	["Balance_Rune_AreaAttackWithImmolate_Lv5"] = true,
	["Balance_Rune_SingleAttackWithStun_Lv5"] = true,
	["Balance_Rune_SingleAttackWithSelfStun_Lv5"] = true,
}

local revivable_card_name = {};
local base_name, _;
for base_name, _ in pairs(base_revivable_card_name) do
	revivable_card_name[base_name] = true;
	revivable_card_name[base_name.."_Green"] = true;
	revivable_card_name[base_name.."_Blue"] = true;
	revivable_card_name[base_name.."_Purple"] = true;
	revivable_card_name[base_name.."_Orange"] = true;
end

-- NOTE: this is only valid for mob units
-- mob revivable card key name
local base_mob_revivable_card_name = {
	["Death_AreaHeal_BlackReborn"] = true,
};

local mob_revivable_card_name = {};
local base_name, _;
for base_name, _ in pairs(base_mob_revivable_card_name) do
	mob_revivable_card_name[base_name] = true;
	mob_revivable_card_name[base_name.."_Green"] = true;
	mob_revivable_card_name[base_name.."_Blue"] = true;
	mob_revivable_card_name[base_name.."_Purple"] = true;
	mob_revivable_card_name[base_name.."_Orange"] = true;
end

-- two-way gsid and card key mapping
local cardkey_to_gsid = {};
local gsid_to_cardkey = {};

-- two-way rune gsid and card key mapping
local cardkey_to_rune_gsid = {};
local rune_gsid_to_cardkey = {};

-- card key to keys that share the same cooldown
local shared_cooldown_key_to_spellname = {};
local shared_cooldown_spellname_to_keys = {};

-- share cooldown cardkeys for kids, MUST share the same spell
local share_cooldown_card_keys_for_kids = {};

-- get card key from gsid and vice versa
function Card.Get_gsid_from_cardkey(key)
	return cardkey_to_gsid[key];
end
function Card.Get_cardkey_from_gsid(gsid)
	if(gsid == 0) then
		return "Pass";
	end
	return gsid_to_cardkey[gsid];
end

-- get card key from rune gsid and vice versa
function Card.Get_rune_gsid_from_cardkey(key)
	return cardkey_to_rune_gsid[key];
end
function Card.Get_cardkey_from_rune_gsid(gsid)
	if(gsid == 0) then
		return "Pass";
	end
	return rune_gsid_to_cardkey[gsid];
end

function Card.InitConstants()
	if(System.options.version == "kids") then
		MAX_REFLECT_DAMAGE = 4500;
		dodge_damage_ratio = 0.00001;
	end
	
	if(System.options.version == "teen") then
		splash_damage_siblin_ratio = 1;
	end
end

-- Init CardKey and gsid mapping
function Card.InitCardKey_gsid_mapping()
	-- different card quality region
	local regions = {
		{22101, 22999}, -- kids version cards
		{41101, 41999}, -- green
		{42101, 42999}, -- blue
		{43101, 43999}, -- purple
		{44101, 44999}, -- orange
	};
	if(System.options.version == "teen") then
		regions = {
			{22101, 22999}, -- white
			{41101, 41999}, -- green
			{42101, 42999}, -- blue
			{43101, 43999}, -- purple
			{44101, 44999}, -- orange
		};
	end
	local _, region_from_to;
	for _, region_from_to in ipairs(regions) do
		if(region_from_to[1] and region_from_to[2]) then
			local i;
			for i = region_from_to[1], region_from_to[2] do
				local gsItem = PowerItemManager.GetGlobalStoreItemInMemory(i);
				if(gsItem) then
					local gsid, key = string.match(gsItem.assetkey, "^(%d-)_(.+)$");
					if(gsid and key) then
						gsid = tonumber(gsid);
						if(i == gsid) then
							cardkey_to_gsid[key] = gsid;
							gsid_to_cardkey[gsid] = key;
							-- LiXizhi: for printing all cards for Haqi Blockly editor
							-- log(format('{"%s", "%s"},\n', gsItem.template.name, gsid))
						end
					end
				end
			end
		end
	end
	
	-- rune gsid and key mapping
	local i;
	for i = 23101, 23999 do
		local gsItem = PowerItemManager.GetGlobalStoreItemInMemory(i);
		if(gsItem) then
			local gsid, key = string.match(gsItem.assetkey, "^(%d-)_(.+)$");
			if(gsid and key) then
				gsid = tonumber(gsid);
				if(i == gsid) then
					cardkey_to_rune_gsid[key] = gsid;
					rune_gsid_to_cardkey[gsid] = key;
					-- LiXizhi: for printing all cards for Haqi Blockly editor
					-- log(format('{"%s", "%s"},\n', gsItem.template.name, gsid))
				end
			end
		end
	end

	if(not gsid_to_cardkey[22101]) then
		LOG.std(nil, "error", "card_server", "Card.InitCardKey_gsid_mapping() got empty global store item templates");
	end
end

local deck_ai_style_templates = {};

-- create deck attacker ai template
function Card.CreateDeckAttackerAITemplate(datafile)
	if(datafile) then
		local file = ParaIO.open(datafile, "r");
		if(file:IsValid() == true) then
			LOG.std(nil, "info", "card_server", "server loaded template file %s", tostring(datafile));
			-- read a line 
			local style_name;
			local template = {};
			local bFirstLine = true;
			local line = file:readline();
			while(line) do
				local sequence = {};
				local card_key;
				local bFirstNode = true;
				local node;
				if(line:sub(#line, #line) ~= ",") then
					line = line..","
				end
				for node in string.gmatch(line, "([^,]*),") do
					if(bFirstNode) then
						card_key = node;
						bFirstNode = false;
					else
						node = tonumber(node) or node; -- cast to number if possible
						table.insert(sequence, node);
					end
				end
				if(bFirstLine) then
					template["heads"] = sequence;
					style_name = card_key;
					bFirstLine = false;
				else
					template[card_key] = sequence;
				end
				-- read next line
				line = file:readline();
			end
			file:close();
			deck_ai_style_templates[style_name] = template;
		else
			LOG.std(nil, "error", "card_server", "server filed to load template file: %s", tostring(datafile));
		end
	end
end

-- get deck attcker target and weight
function Card.GetDeckAttackerAIWeightTarget(key, style, mob_obj, arena, myself, friendlys, hostiles)
	if(key and style and mob_obj and arena and myself and friendlys and hostiles) then
		local template = deck_ai_style_templates[style];
		if(template and template[key]) then
			local weight_sequence = template[key];
			local head_sequence = template["heads"];
			if(weight_sequence and head_sequence) then
				local target_type = weight_sequence[1]; -- assume the first element is target_type
				local target_units;
				if(target_type == "friendly") then
					target_units = friendlys;
				elseif(target_type == "hostile") then
					target_units = hostiles;
				elseif(target_type == "self") then
					target_units = myself;
				end
				local target_ismob;
				local target_id;
				local target_weight = -100000;
				if(target_units) then
					local this_weight = 1000;
					local _, each_target;
					for _, each_target in ipairs(target_units) do
						local unit = Arena.GetCombatUnit(each_target.isMob, each_target.id);
						if(unit) then
							local _ = 2;
							for _ = 2, #weight_sequence do
								local condition = head_sequence[_];
								local weight = weight_sequence[_];
								if(weight ~= 0 and type(weight) == "number") then -- don't test 0 weight conditions
									if(condition == "base_weight") then
										this_weight = weight;
									else
										if(Card.MatchCondition(mob_obj, arena, unit, condition)) then
											this_weight = this_weight + weight;
											LOG.std(nil, "info", "card_server", "====GetCardAndTarget_Deck_Attacker_helper====: card %s hit condition %s with weight %d", tostring(key), condition, weight);
										else
											LOG.std(nil, "info", "card_server", "====GetCardAndTarget_Deck_Attacker_helper====: card %s miss condition %s", tostring(key), condition);
										end
									end
								end
							end
							if(this_weight > target_weight) then
								target_ismob = unit:IsMob();
								target_id = unit:GetID();
								target_weight = this_weight;
							end
						end
					end
				end
				return target_weight, target_ismob, target_id;
			else
				return -1; -- no available template for key, negative weight to mark as discarded card
			end
		end
	end
end

-- match card condition
function Card.MatchCondition(caster, arena, target, condition)
	
	if(condition == "no_aura") then
		if(not arena.GlobalAura and not arena.GlobalAura2) then
			return true;
		end
	elseif(condition == "caster_school_damage_aura") then
		if(arena.GlobalAura_boost_school == caster:GetPhase()) then
			return true;
		end
	elseif(condition == "other_school_damage_aura") then
		if(arena.GlobalAura_boost_school ~= caster:GetPhase()) then
			return true;
		end
		
	elseif(condition == "target_is_fire") then
		if(target:GetPhase() == "fire") then
			return true;
		end
	elseif(condition == "target_is_ice") then
		if(target:GetPhase() == "ice") then
			return true;
		end
	elseif(condition == "target_is_storm") then
		if(target:GetPhase() == "storm") then
			return true;
		end
	elseif(condition == "target_is_myth") then
		if(target:GetPhase() == "myth") then
			return true;
		end
	elseif(condition == "target_is_life") then
		if(target:GetPhase() == "life") then
			return true;
		end
	elseif(condition == "target_is_death") then
		if(target:GetPhase() == "death") then
			return true;
		end
	elseif(condition == "target_is_balance") then
		if(target:GetPhase() == "balance") then
			return true;
		end

	elseif(condition == "caster_low_hp") then
		local rate = caster:GetCurrentHP() / caster:GetMaxHP();
		if(rate < 0.4) then
			return true;
		end
	elseif(condition == "caster_medium_hp") then
		local rate = caster:GetCurrentHP() / caster:GetMaxHP();
		if(rate >= 0.4 and rate < 0.7) then
			return true;
		end
	elseif(condition == "caster_high_hp") then
		local rate = caster:GetCurrentHP() / caster:GetMaxHP();
		if(rate >= 0.7) then
			return true;
		end
	elseif(condition == "caster_with_globalshield") then
		if(caster:IfHasShield(nil)) then
			return true;
		end
	elseif(condition == "caster_with_fire_shield") then
		if(caster:IfHasShield("fire", true)) then
			return true;
		end
	elseif(condition == "caster_with_ice_shield") then
		if(caster:IfHasShield("ice", true)) then
			return true;
		end
	elseif(condition == "caster_with_storm_shield") then
		if(caster:IfHasShield("storm", true)) then
			return true;
		end
	elseif(condition == "caster_with_myth_shield") then
		if(caster:IfHasShield("myth", true)) then
			return true;
		end
	elseif(condition == "caster_with_life_shield") then
		if(caster:IfHasShield("life", true)) then
			return true;
		end
	elseif(condition == "caster_with_death_shield") then
		if(caster:IfHasShield("death", true)) then
			return true;
		end
	elseif(condition == "caster_with_balance_shield") then
		if(caster:IfHasShield("balance", true)) then
			return true;
		end
	elseif(condition == "caster_with_target_shield") then
		if(caster:IfHasShield(target:GetPhase(), true)) then -- true for bSkipGlobalShield
			return true;
		end
	elseif(condition == "caster_with_target_defend_miniaura") then
		if(caster:IfHasDefendMiniaura(target:GetPhase())) then
			return true;
		end
	elseif(condition == "caster_with_1_damageboost") then
		local count, max_stacks = caster:GetSpecificCharmCount("damageboost", caster:GetPhase());
		if(count and count == 1) then
			return true;
		end
	elseif(condition == "caster_with_2+_damageboost") then
		local count, max_stacks = caster:GetSpecificCharmCount("damageboost", caster:GetPhase());
		if(count and count >= 2) then
			return true;
		end
	elseif(condition == "caster_with_1_damagetrap") then
		local count, max_stacks = caster:GetSpecificWardCount("damagetrap", target:GetPhase());
		if(count and count == 1) then
			return true;
		end
	elseif(condition == "caster_with_2+_damagetrap") then
		local count, max_stacks = caster:GetSpecificWardCount("damagetrap", target:GetPhase());
		if(count and count >= 2) then
			return true;
		end
	elseif(condition == "caster_with_1+_healboost") then
		local count, max_stacks = caster:GetSpecificCharmCount("healboost");
		if(count and count >= 1) then
			return true;
		end
	elseif(condition == "caster_with_1+_healweakness") then
		local count, max_stacks = caster:GetSpecificCharmCount("healweakness");
		if(count and count >= 1) then
			return true;
		end
	elseif(condition == "caster_with_1+_damageweakness") then
		local count, max_stacks = caster:GetSpecificCharmCount("damageweakness", caster:GetPhase());
		if(count and count >= 1) then
			return true;
		end
	elseif(condition == "caster_pips_10+") then
		local caster_pip_count = caster:GetPipsCount() + caster:GetPowerPipsCount() * 2;
		if(caster_pip_count >= 10) then
			return true;
		end


	elseif(condition == "target_low_hp") then
		local rate = target:GetCurrentHP() / target:GetMaxHP();
		if(rate < 0.4) then
			return true;
		end
	elseif(condition == "target_medium_hp") then
		local rate = target:GetCurrentHP() / target:GetMaxHP();
		if(rate >= 0.4 and rate < 0.7) then
			return true;
		end
	elseif(condition == "target_high_hp") then
		local rate = target:GetCurrentHP() / target:GetMaxHP();
		if(rate >= 0.7) then
			return true;
		end
	elseif(condition == "target_with_globalshield") then
		if(target:IfHasShield(nil)) then
			return true;
		end
	elseif(condition == "target_with_fire_shield") then
		if(target:IfHasShield("fire", true)) then
			return true;
		end
	elseif(condition == "target_with_ice_shield") then
		if(target:IfHasShield("ice", true)) then
			return true;
		end
	elseif(condition == "target_with_storm_shield") then
		if(target:IfHasShield("storm", true)) then
			return true;
		end
	elseif(condition == "target_with_myth_shield") then
		if(target:IfHasShield("myth", true)) then
			return true;
		end
	elseif(condition == "target_with_life_shield") then
		if(target:IfHasShield("life", true)) then
			return true;
		end
	elseif(condition == "target_with_death_shield") then
		if(target:IfHasShield("death", true)) then
			return true;
		end
	elseif(condition == "target_with_balance_shield") then
		if(target:IfHasShield("balance", true)) then
			return true;
		end
	elseif(condition == "target_with_caster_shield") then
		if(target:IfHasShield(caster:GetPhase(), true)) then -- true for bSkipGlobalShield
			return true;
		end
	elseif(condition == "target_with_fire_defend_miniaura") then
		if(target:IfHasDefendMiniaura("fire")) then
			return true;
		end
	elseif(condition == "target_with_ice_defend_miniaura") then
		if(target:IfHasDefendMiniaura("ice")) then
			return true;
		end
	elseif(condition == "target_with_storm_defend_miniaura") then
		if(target:IfHasDefendMiniaura("storm")) then
			return true;
		end
	elseif(condition == "target_with_myth_defend_miniaura") then
		if(target:IfHasDefendMiniaura("myth")) then
			return true;
		end
	elseif(condition == "target_with_life_defend_miniaura") then
		if(target:IfHasDefendMiniaura("life")) then
			return true;
		end
	elseif(condition == "target_with_death_defend_miniaura") then
		if(target:IfHasDefendMiniaura("death")) then
			return true;
		end
	elseif(condition == "target_with_balance_defend_miniaura") then
		if(target:IfHasDefendMiniaura("balance")) then
			return true;
		end
	elseif(condition == "target_with_caster_defend_miniaura") then
		if(target:IfHasDefendMiniaura(caster:GetPhase())) then
			return true;
		end
	elseif(condition == "target_with_1_damageboost") then
		local count, max_stacks = target:GetSpecificCharmCount("damageboost", target:GetPhase());
		if(count and count == 1) then
			return true;
		end
	elseif(condition == "target_with_2+_damageboost") then
		local count, max_stacks = target:GetSpecificCharmCount("damageboost", target:GetPhase());
		if(count and count >= 2) then
			return true;
		end
	elseif(condition == "target_with_1_damagetrap") then
		local count, max_stacks = target:GetSpecificWardCount("damagetrap", caster:GetPhase());
		if(count and count == 1) then
			return true;
		end
	elseif(condition == "target_with_2+_damagetrap") then
		local count, max_stacks = target:GetSpecificWardCount("damagetrap", caster:GetPhase());
		if(count and count >= 2) then
			return true;
		end
	elseif(condition == "target_with_1+_healboost") then
		local count, max_stacks = target:GetSpecificCharmCount("healboost");
		if(count and count >= 1) then
			return true;
		end
	elseif(condition == "target_with_1+_healweakness") then
		local count, max_stacks = target:GetSpecificCharmCount("healweakness");
		if(count and count >= 1) then
			return true;
		end
	elseif(condition == "target_with_1+_damageweakness") then
		local count, max_stacks = target:GetSpecificCharmCount("damageweakness", target:GetPhase());
		if(count and count >= 1) then
			return true;
		end
	elseif(condition == "target_pips_6+") then
		local target_pip_count = target:GetPipsCount() + target:GetPowerPipsCount() * 2;
		if(target_pip_count >= 6) then
			return true;
		end
	end

	return false;
end

-- create AI module
-- @param o: typical Card params including:
--			
function Card:CreateCardTemplate(datafile)
	local xmlRoot = ParaXML.LuaXML_ParseFile(datafile);
	if(not xmlRoot) then
		commonlib.log("error: failed loading card template file: %s\n", datafile);
		return;
	end
	-- LOG.std(nil, "debug", "card_server", "server loaded card template file %s", datafile);

	-- create card template object
	local o = {
		key = nil, -- card template key
		type = nil, -- card template type
		pipcost = nil, -- pip cost of the card
		accuracy = nil, -- accuracy in hundred percent
		spell_effect_name = nil, -- spell effect config file name
		battle_comment_name = nil, -- battle comment config file name
		params = {}, -- card specific params
	};
	local key;
	for key in commonlib.XPath.eachNode(xmlRoot, "/card/key") do
		o.key = key.attr.name;
	end
	local spell;
	for spell in commonlib.XPath.eachNode(xmlRoot, "/card/spell") do
		o.spell_name = spell.attr.name;
	end
	-- default spell name is the same as the card key
	if(not o.spell_name) then
		o.spell_name = o.key;
	end
	local basics;
	for basics in commonlib.XPath.eachNode(xmlRoot, "/card/basics") do
		o.target = basics.attr.target;
		o.type = basics.attr.type;
		o.pipcost = tonumber(basics.attr.pipcost);
		o.accuracy = tonumber(basics.attr.accuracy);
		if(System.options.version == "teen") then
			-- default card accuracy for teen version is 100%
			o.accuracy = 100;
		end
		if(basics.attr.hitchance) then
			o.hitchance = tonumber(basics.attr.hitchance) or 100;
		end
		if(basics.attr.spell_school) then
			o.spell_school = string.lower(basics.attr.spell_school);
		end
		o.require_level = tonumber(basics.attr.require_level);
		if(basics.attr.can_learn == "true") then
			o.can_learn = true;
		end
	end
	--local spell_effect;
	--for spell_effect in commonlib.XPath.eachNode(xmlRoot, "/card/spell_effect") do
		--o.spell_effect_name = spell_effect.attr.file;
	--end
	--local battle_comment;
	--for battle_comment in commonlib.XPath.eachNode(xmlRoot, "/card/battle_comment") do
		--o.battle_comment_name = battle_comment.attr.file;
	--end
	local params;
	for params in commonlib.XPath.eachNode(xmlRoot, "/card/params") do
		local key, value;
		for key, value in pairs(params.attr) do
			if(key == "spelllist") then
				-- just remove all non-character-number-comma-underline characters
				-- including /r, tab, space and newline
				value = string.gsub(value, "[^,^%a^%d^_]", "");
			end
			o.params[key] = tonumber(value) or value;
		end
	end

	if(not o.spell_school) then
		-- default balance school for cards with no explicit spell_school
		o.spell_school = "balance";
	end

	-- keep a template reference
	card_templates[o.key] = o;
	-- card class object
	setmetatable(o, self);
	self.__index = self;
	return o;
end

-- create AI module
-- @param o: typical Card params including:
--			
function Card:CreateCardTemplateFromTable(o)
	-- keep a template reference
	card_templates[o.key] = o;
	-- card class object
	setmetatable(o, self);
	self.__index = self;
	return o;
end

-- get card template module object
function Card.GetCardTemplate(key)
	return card_templates[key];
end

-- default spell duration
local default_spell_duration = 3000;

-- lower case card key and spell duration mapping
local card_lower_spellname_duration_mapping = {};
-- get spell duration
function Card.GetSpellDuration_from_card_spellname(key)
	if(not key) then
		LOG.std(nil, "error", "card_server", "Card.GetSpellDuration_from_card_key() got invalid card key:"..tostring(key));
		return;
	end
	local duration = card_lower_spellname_duration_mapping[string.lower(key)];
	if(key == "Dead" or key == "dead") then
		-- NOTE 2012/1/19: dead spell do not cost any time, and invoked on damage
		return 0;
	end
	if(not duration) then
		LOG.std(nil, "error", "card_server", "Card.GetSpellDuration_from_card_key() got invalid duration for spell key:"..tostring(key)..", default:"..default_spell_duration.." is used \n");
	end
	return duration or default_spell_duration;
end

-- init deck attacker ai templates
function Card.InitDeckAttackerAITemplates(config_file)
	local xmlRoot = ParaXML.LuaXML_ParseFile(config_file);
	if(not xmlRoot) then
		commonlib.log("error: failed loading deck attacker ai templates list file: %s\n", config_file);
		return;
	end
	LOG.std(nil, "info", "card_server", "server loaded deck attacker ai templates file: %s", config_file);
	-- all card datafiles
	local datafiles = {};
	-- create each card object
	local each_card;
	for each_card in commonlib.XPath.eachNode(xmlRoot, "/templatelist/template") do
		local file = each_card.attr.datafile;
		table_insert(datafiles, file);
	end
	-- for each data file create card template
	local _, datafile;
	for _, datafile in ipairs(datafiles) do
		-- create each deck attacker template
		Card.CreateDeckAttackerAITemplate(datafile);
	end
end

-- NOTE: deparacted
-- init card data from file
function Card.InitCardDataFromXML(config_file)
	local xmlRoot = ParaXML.LuaXML_ParseFile(config_file);
	if(not xmlRoot) then
		commonlib.log("error: failed loading card data list file: %s\n", config_file);
		return;
	end
	LOG.std(nil, "info", "card_server", "server loaded card data list file %s", config_file);
	-- all card datafiles
	local datafiles = {};
	-- create each card object
	local each_card;
	for each_card in commonlib.XPath.eachNode(xmlRoot, "/cardlist/card") do
		local file = each_card.attr.datafile;
		table_insert(datafiles, file);
	end
	-- for each data file create card template
	local _, datafile;
	for _, datafile in ipairs(datafiles) do
		-- create card template
		local cardTemplate = Card:CreateCardTemplate(datafile);
		-- init spell durations
		if(cardTemplate and cardTemplate.spell_name) then
			local spell_file = "config/Aries/Spells/"..cardTemplate.spell_name..".xml";

			local xmlRoot = ParaXML.LuaXML_ParseFile(spell_file);
			if(xmlRoot) then
				local spell_duration;
				local node;
				for node in commonlib.XPath.eachNode(xmlRoot, "/spell") do
					if(node.attr and node.attr.duration) then
						spell_duration = tonumber(node.attr.duration);
					end
				end
				if(not spell_duration) then
					LOG.std(nil, "error", "card_server", "Card.InitCardDataFromXML() got nil spell_duration for spell name: "..tostring(cardTemplate.spell_name));
					spell_duration = default_spell_duration;
				end
				card_lower_spellname_duration_mapping[string.lower(cardTemplate.spell_name)] = spell_duration;
			else
				commonlib.log("error: failed loading card spell file: %s\n", spell_file);
			end
		end
		if(cardTemplate and cardTemplate.spell_name and type(cardTemplate.params.cooldown) == "number") then
			-- parse card keys with the same spell share the same cooldown start
			shared_cooldown_key_to_spellname[cardTemplate.key] = cardTemplate.spell_name;
			if(not shared_cooldown_spellname_to_keys[cardTemplate.spell_name]) then
				shared_cooldown_spellname_to_keys[cardTemplate.spell_name] = {};
			end
			shared_cooldown_spellname_to_keys[cardTemplate.spell_name][cardTemplate.key] = true;
		end
	end
	-- find share cooldown keys for kids
	-- now kids use same mode in processing share cooldown  ---2015.3.26
	--[[
	if(System.options.version == "kids") then
		local each_share_CD_key;
		for each_share_CD_key in commonlib.XPath.eachNode(xmlRoot, "/cardlist/share_cooldown_card_keys_for_kids/key") do
			local key_name = each_share_CD_key.attr.name;
			if(key_name) then
				share_cooldown_card_keys_for_kids[key_name] = true;
			end
		end
	end
	]]
end

-- init threat config from xml file
function Card.InitThreatConfigFromFile(config_file)
	threat_config = {};
	local xmlRoot = ParaXML.LuaXML_ParseFile(config_file);
	if(not xmlRoot) then
	    LOG.std(nil, "error", "Card", "file %s does not exist", config_file);
	else
		for config in commonlib.XPath.eachNode(xmlRoot, "/CombatThreatConfig/config") do
			if(config.attr and config.attr.key and config.attr.value and tonumber(config.attr.value)) then
				threat_config[config.attr.key] = tonumber(config.attr.value);
			end
		end
	end

	-- splash damage threat ratio
	splash_damage_threat_ratio = threat_config["splash_damage_threat_ratio"] or 0.2;

	-- splash manipulation threat ratio
	splash_manipulation_threat_ratio = threat_config["splash_manipulation_threat_ratio"] or 0.2;

	-- area heal threat ratio
	areaheal_threat_ratio = threat_config["areaheal_threat_ratio"] or 0.2;

	-- ice area attack threat ratio
	ice_areaattack_threat_ratio = threat_config["ice_areaattack_threat_ratio"] or 2;

	-- damage threat ratio
	damage_threat_ratio_fire = threat_config["damage_threat_ratio_fire"] or 0.7;
	damage_threat_ratio_ice = threat_config["damage_threat_ratio_ice"] or 2.0;
	damage_threat_ratio_storm = threat_config["damage_threat_ratio_storm"] or 0.65;
	damage_threat_ratio_life = threat_config["damage_threat_ratio_life"] or 1.0;
	damage_threat_ratio_death = threat_config["damage_threat_ratio_death"] or 0.8;

	-- heal threat ratio
	heal_threat_ratio = threat_config["heal_threat_ratio"] or 0.3;
end

-- init card data from csv file
function Card.InitCardDataFromCSV(config_file)
	local file = ParaIO.open(config_file, "r");
	if(file:IsValid() ~= true) then
		commonlib.log("error: failed loading card data list file: %s\n", config_file);
		return;
	end
	LOG.std(nil, "info", "card_server", "server loaded card data list file %s", config_file);
	-- read each card line 
	local static_keys = {
		key = true,
		spell_name = true,
		type = true,
		accuracy = true,
		spell_school = true,
		pipcost = true,
		require_level = true,
	};
	local params_keys = {};
	local line = file:readline();
	if(line) then
		-- first line for keys
		local each_key;
		for each_key in string.gmatch(line, "[^,]*,") do
			local each_key = string.match(each_key, "^(.*),$");
			if(each_key and each_key ~= "") then
				table.insert(params_keys, each_key);
			end
		end
	end
	-- read next line
	line = file:readline();
	while(line) do
		-- process each card line
		local each_card = {params={}};
		local each_value;
		local seq = 1;
		for each_value in string.gmatch(line, "[^,]*,") do
			local each_value = string.match(each_value, "^(.*),$");
			if(each_value and each_value ~= "") then
				if(static_keys[params_keys[seq]]) then
					each_card[params_keys[seq]] = tonumber(each_value) or each_value;
				else
					each_card.params[params_keys[seq]] = tonumber(each_value) or each_value;
				end
				-- create card template
				local cardTemplate = Card:CreateCardTemplateFromTable(each_card);
				-- init spell durations
				if(cardTemplate and cardTemplate.spell_name) then
					local spell_file = "config/Aries/Spells/"..cardTemplate.spell_name..".xml";

					local xmlRoot = ParaXML.LuaXML_ParseFile(spell_file);
					if(xmlRoot) then
						local spell_duration;
						local node;
						for node in commonlib.XPath.eachNode(xmlRoot, "/spell") do
							if(node.attr and node.attr.duration) then
								spell_duration = tonumber(node.attr.duration);
							end
						end
						if(not spell_duration) then
							LOG.std(nil, "error", "card_server", "Card.InitCardDataFromCSV() got nil spell_duration for spell name: "..tostring(cardTemplate.spell_name));
							spell_duration = default_spell_duration;
						end
						card_lower_spellname_duration_mapping[string.lower(cardTemplate.spell_name)] = spell_duration;
					else
						commonlib.log("error: failed loading card spell file: %s\n", spell_file);
					end
				end
			end
			seq = seq + 1;
		end
		-- read next line
		line = file:readline();
	end
	file:close();
end

-- init charm and ward data from file
function Card.InitCharmAndWardDataFromFile(config_file)
	local xmlRoot = ParaXML.LuaXML_ParseFile(config_file);
	if(not xmlRoot) then
		commonlib.log("error: failed loading charm and ward data file: %s\n", config_file);
		return;
	end
	LOG.std(nil, "info", "card_server", "server loaded charm and ward data file: %s", config_file);
	-- check each charm data
	local each_charm;
	for each_charm in commonlib.XPath.eachNode(xmlRoot, "/list/charmlist/charm") do
		if(each_charm.attr) then
			local id = tonumber(each_charm.attr.id);
			local o = {};
			-- copy all attributes to charm data
			local key, value;
			for key, value in pairs(each_charm.attr) do
				if(key ~= "id") then
					if(value == "true") then
						o[key] = true;
					elseif(value == "false") then
						o[key] = false;
					else
						o[key] = tonumber(value) or value;
					end
				end
			end
			charms[id] = o;
			-- append to all dispel charms
			if(o.dispel_school) then
				charms_with_dispel[id] = o;
			end
		end
	end
	-- check each ward data
	local each_ward;
	for each_ward in commonlib.XPath.eachNode(xmlRoot, "/list/wardlist/ward") do
		if(each_ward.attr) then
			local id = tonumber(each_ward.attr.id);
			local o = {};
			-- copy all attributes to ward data
			local key, value;
			for key, value in pairs(each_ward.attr) do
				if(key ~= "id") then
					if(value == "true") then
						o[key] = true;
					elseif(value == "false") then
						o[key] = false;
					else
						o[key] = tonumber(value) or value;
					end
					if(key == "stats") then
						local k, v = string.match(value, "^%((.-),(.-)%)$")
						if(k and v) then
							k = tonumber(k);
							v = tonumber(v);
							o.stats = {[k] = v};
						end
					end
				end
			end
			wards[id] = o;
		end
	end
	-- check each mini aura data
	local each_miniaura;
	for each_miniaura in commonlib.XPath.eachNode(xmlRoot, "/list/miniauralist/miniaura") do
		if(each_miniaura.attr) then
			local id = tonumber(each_miniaura.attr.id);
			local o = {
				stats = {},
			};
			local stat_section;
			for stat_section in string.gmatch(each_miniaura.attr.stats, "([^%(^%)]+)") do
				local stat_type, stat_value = string.match(stat_section, "^(.-),(.-)$");
				if(stat_type and stat_value) then
					stat_type = tonumber(stat_type);
					stat_value = tonumber(stat_value);
					if(stat_type and stat_value) then
						o.stats[stat_type] = stat_value;
					end
				end
			end
			miniauras[id] = o;
		end
	end
	-- check each global aura data
	local each_globalaura;
	for each_globalaura in commonlib.XPath.eachNode(xmlRoot, "/list/globalauralist/globalaura") do
		if(each_globalaura.attr) then
			local id = tonumber(each_globalaura.attr.id);
			local o = {
				stats = {},
			};
			local stat_section;
			for stat_section in string.gmatch(each_globalaura.attr.stats, "([^%(^%)]+)") do
				local stat_type, stat_value = string.match(stat_section, "^(.-),(.-)$");
				if(stat_type and stat_value) then
					stat_type = tonumber(stat_type);
					stat_value = tonumber(stat_value);
					if(stat_type and stat_value) then
						o.stats[stat_type] = stat_value;
					end
				end
			end
			globalauras[id] = o;
		end
	end
end

-- dragon totem stats
local DragonTotemStats = {};
-- init dragon totem stats data from file
function Card.InitDragonTotemStatsConfigFromFile(config_file)
	local xmlRoot = ParaXML.LuaXML_ParseFile(config_file);
	if(not xmlRoot) then
		commonlib.log("error: failed loading dragon totem stats data file: %s\n", config_file);
		return;
	end
	LOG.std(nil, "info", "card_server", "server loaded dragon totem stats data file: %s", config_file);
	-- check each profession data
	local each_profession;
	for each_profession in commonlib.XPath.eachNode(xmlRoot, "/DragonTotemStats/profession") do
		if(each_profession.attr and each_profession.attr.gsid and each_profession.attr.exp_gsid) then
			local gsid = tonumber(each_profession.attr.gsid);
			local exp_gsid = tonumber(each_profession.attr.exp_gsid);
			if(gsid and exp_gsid) then
				local stats_group = {};
				local maxlevel;
				-- check each stats data
				local each_stats;
				for each_stats in commonlib.XPath.eachNode(each_profession, "/stats") do
					if(each_stats.attr and each_stats.attr.exp) then
						local exp = tonumber(each_stats.attr.exp);
						local level = tonumber(each_stats.attr.level);
						local current_level_exp = tonumber(each_stats.attr.current_level_exp);
						local value = each_stats.attr.value or "";
						local stats = {};
						local stat_pair;
						for stat_pair in string.gmatch(value, "%(([^%(^%)]+)%)") do
							local stat_key, stat_value = string.match(stat_pair, "(%d+),(%d+)");
							if(stat_key and stat_value) then
								stat_key = tonumber(stat_key);
								stat_value = tonumber(stat_value);
								stats[stat_key] = stat_value;
							end
						end
						if(exp and level and current_level_exp and stats) then
							table.insert(stats_group, {
								exp_gsid = exp_gsid,
								exp = exp,
								current_level_exp = current_level_exp,
								level = level,
								stats = stats,
							});
							if(not maxlevel) then
								maxlevel = level;
							else
								if(maxlevel < level) then
									maxlevel = level;
								end
							end
						end
					end
				end
				table.sort(stats_group, function(a, b) return a.exp > b.exp; end);
				stats_group.maxlevel = maxlevel;
				DragonTotemStats[gsid] = stats_group;
			end
		end
	end
end

-- get dragon totem stats
-- @profession_gsid: profession gsid 50351 ~ 50354
-- @exp_gsid: default 50359
-- @exp_count: item count
-- @return: stats({[101] = 10, [102] = 70} or nil if invalid), total_level, cur_level, cur_level_exp, cur_level_total_exp
function Card.GetStatsFromDragonTotemProfessionAndExp(profession_gsid, exp_gsid, exp_count)
	exp_gsid = exp_gsid or 50359;
	if(profession_gsid and type(exp_count) == "number") then
		local each_profession = DragonTotemStats[profession_gsid];
		if(each_profession) then
			local _, each_stage;
			for _, each_stage in ipairs(each_profession) do
				if(exp_gsid == each_stage.exp_gsid and exp_count >= each_stage.exp) then
					local cur_level = each_stage.level;
					local cur_level_exp = exp_count - each_stage.exp;
					local cur_level_total_exp = each_stage.current_level_exp;
					return each_stage.stats, each_profession.maxlevel, cur_level, cur_level_exp, cur_level_total_exp;
				end
			end
		end
	end
end

-- get dragon totem stats
-- @profession_gsid: profession gsid 50351 ~ 50354
-- @level: level
-- @return {[101] = 10, [102] = 70} or nil if invalid
function Card.GetStatsFromDragonTotemProfessionAndLevel(profession_gsid, level)
	if(profession_gsid and type(level) == "number") then
		local each_profession = DragonTotemStats[profession_gsid];
		if(each_profession) then
			local _, each_stage;
			for _, each_stage in ipairs(each_profession) do
				if(level == each_stage.level) then
					return each_stage.stats;
				end
			end
		end
	end
end

-- get dragon totem max level
-- @profession_gsid: profession gsid 50351 ~ 50354
function Card.GetMaxLevelFromDragonTotemProfession(profession_gsid)
	if(profession_gsid) then
		local each_profession = DragonTotemStats[profession_gsid];
		return each_profession.maxlevel;
	end
end

-- get charm template
function Card.GetCharmTemplate(id)
	return charms[id];
end

-- get ward template
function Card.GetWardTemplate(id)
	return wards[id];
end

-- get miniaura template
function Card.GetMiniAuraTemplate(id)
	return miniauras[id];
end

-- get globalaura template
function Card.GetGlobalAuraTemplate(id)
	return globalauras[id];
end

-- teen version uses shared cooldown among card keys with the same spellname
-- returns the table with all card keys including the card_key itself
function Card.GetSharedCoolDownCardKeys(card_key)
	if(card_key) then
		-- now kids use same mode in processing share cooldown  ---2015.3.26
		if(false) then
		--if(System.options.version == "kids") then
			if(share_cooldown_card_keys_for_kids[card_key]) then
				local spell_name = shared_cooldown_key_to_spellname[card_key];
				if(spell_name) then
					return shared_cooldown_spellname_to_keys[spell_name];
				end
			end
		else
			local spell_name = shared_cooldown_key_to_spellname[card_key];
			if(spell_name) then
				return shared_cooldown_spellname_to_keys[spell_name];
			end
		end
	end
end

-- get ward template
-- @param section: "100" means 100, "100p" means 100 multipied by real cost pips count
-- @param realcostpips: real cost pips count
-- @return value or nil if any error
function Card.GetNumericalValueFromSection(section, realcostpips)
	if(not section or (section and not realcostpips)) then
		LOG.std(nil, "error", "card_server", "Card.GetNumericalValueFromSection() got invalid input: "..commonlib.serialize({section, realcostpips}));
		return;
	end
	local value = tonumber(section)
	if(value) then
		return value;
	else
		-- X pips value
		local value_per_pip = string.match(section, "^(%d+)p$");
		if(value_per_pip) then
			value_per_pip = tonumber(value_per_pip);
			value = value_per_pip * realcostpips;
			return value;
		end
	end
end

local function AbsorbDamage(caster, damage)
	if(not caster or not damage) then
		LOG.std(nil, "error", "card_server", "AbsorbDamage got invalid input: "..commonlib.serialize({caster, damage}));
		return;
	end
	local absorb_orderlist = caster:GetAbsorbs();
	local order, absorb_pts;
	for order, absorb_pts in pairs(absorb_orderlist) do
		if((damage - absorb_pts) >= 0) then
			caster:PopAbsorbByOrder(order);
			damage = damage - absorb_pts;
		else
			caster:SetAbsorbPtsByOrder(order, absorb_pts - damage);
			damage = 0;
			break;
		end
	end
	return damage;
end

local function GetDamageThreat(damage, phase)
	if(phase == "fire") then
		return math.ceil(damage * damage_threat_ratio_fire);
	elseif(phase == "ice") then
		return math.ceil(damage * damage_threat_ratio_ice);
	elseif(phase == "storm") then
		return math.ceil(damage * damage_threat_ratio_storm);
	elseif(phase == "death") then
		return math.ceil(damage * damage_threat_ratio_death);
	elseif(phase == "life") then
		return math.ceil(damage * damage_threat_ratio_life);
	end
	return damage;
end

local function GetHealThreat(heal, phase)
	return math.ceil(heal * 0.3);
end

local function GetEffectThreat(effect)
	-- NOTE: user explicit threat amount, default 0 threat
	return threat_config[effect] or 0;
end

-- try critical strike against target
local function TryCriticalStrike(caster, target, base_criticalstrike, damage_school)
	
	if(not caster or not target) then
		return false;
	end
	local nResilience = target:GetResilience(damage_school);
	local nCriticalstrike = caster:GetCriticalStrike(damage_school);

	--if(caster:IsMob() == false) then
		--nCriticalstrike = 50;
	--end

	local ret = nCriticalstrike - nResilience;

	ret = ret + base_criticalstrike;

	if(ret < 0) then
		ret = 0;
	elseif(ret > 100) then
		ret = 100;
	end

	local r = math.random(0, 1000);
	if(r <= ret * 10) then
		return true;
	end

	return false;
end

local function TryDoubleAttack(caster, target, base_doubleattack, damage_school)
	
	if(System.options.version == "teen" or System.options.version == "kids") then
		return false;
	end
	if(not caster or not target) then
		return false;
	end
	
	local nDoubleAttck = caster:GetDoubleAttackChance(damage_school);
	local ret = nDoubleAttck;

	ret = ret + (base_doubleattack or 0);

	if(ret < 0) then
		ret = 0;
	elseif(ret > 100) then
		ret = 100;
	end

	if(ret <= 0) then
		return false;
	end

	local r = math.random(0, 1000);
	if(r <= ret * 10) then
		return true;
	end

	return false;
end

local function TryCriticalStrike_DOT(caster, target, damage_school)
	
	if(not caster or not target) then
		return false;
	end
	local nResilience = target:GetResilience_DOT(damage_school);
	local nCriticalstrike = caster:GetCriticalStrike_DOT(damage_school);

	local ret = nCriticalstrike - nResilience;

	if(ret < 0) then
		ret = 0;
	elseif(ret > 100) then
		ret = 100;
	end

	local r = math.random(0, 1000);
	if(r <= ret * 10) then
		return true;
	end

	return false;
end

-- try dodge attack for target
local function TryDodge(caster, target, base_spell_hitchance, damage_school)
	
	--if(System.options.version == "kids") then
		--return false; -- never dodge in kids version
	--end

	if(not caster) then
		return false;
	end
	if(not target) then
		return false;
	end

	local nHitChance = caster:GetHitChance(damage_school);
	local nDodge = target:GetDodge(damage_school);

	local hit_weight = 100;
	
	if(System.options.version == "teen") then
		-- 人打怪：   命中率 = 装备宝石药丸等提供的单方命中率-目标的单方闪避率-(目标等级-攻击者等级）*5%
		-- 人打人/怪打人： 命中率= 装备宝石药丸等提供的单方命中率-目标的单方闪避率-(目标等级-攻击者等级）*1%

		-- 单方命中率=装备提供的命中强度/(人物等级*K+C)+宝石坐骑药丸提供的命中率
		--     即：装备提供的命中强度/（人物等级×50+50）+宝石坐骑药丸提供的命中率
		-- 单方闪避率与此类似，即：装备提供的闪避强度/(人物等级*50+50)+宝石坐骑药丸提供的闪避率
		if(target:IsMob() == false) then
			hit_weight = (base_spell_hitchance + nHitChance - nDodge) + (caster:GetLevel() - target:GetLevel()) * 1;
		else
			hit_weight = (base_spell_hitchance + nHitChance - nDodge) + (caster:GetLevel() - target:GetLevel()) * 5;
		end
	elseif(System.options.version == "kids") then
		hit_weight = (base_spell_hitchance + nHitChance - nDodge);
	end

	if(hit_weight < 0) then
		hit_weight = 0;
	elseif(hit_weight >= 100) then
		hit_weight = 100 + 1;
	end

	-- pop caster hit chance charms
	local spell_school = damage_school;
	local buffs = {};
	caster:ProcessHitChanceAgainstCharms(buffs, spell_school);
	local _, weight;
	for _, weight in pairs(buffs) do
		hit_weight = hit_weight + weight;
	end

	local r = math.random(1, 10000);
	if(r <= hit_weight * 100) then
		return false;
	end

	return true;
end

local function above_min_boost(boost)
	boost = boost + 100;
	if(boost and boost > 50) then
		return boost;
	end
	return 50;
end

local function GetCriticalStrikeDamageRatio(unit)
	if(unit and unit.GetCriticalStrikeDamageRatioBonus) then
		return critical_strike_damage_ratio + unit:GetCriticalStrikeDamageRatioBonus();
	end
	return 0;
end

-- damage expression for normal process
-- @param base_damage: base damage
-- @param boost_absolute: boost absolute
-- @param buffs: all strategy buff table {}
local function damage_expression(base_damage, boost_absolute, buffs)
	
	local damage = base_damage;
	-- @param damage_percent: damage percent, 10 means 10% damage boost percent
	-- @param resist_percent: resist percent, -10 means 10% resist percent
	local damage_percent = buffs.damage_percent or 0;
	local resist_percent = buffs.resist_percent or 0;
	local spell_penetration = buffs.spell_penetration or 0;
	local spell_penetration_receive = buffs.spell_penetration_receive or 0;

	if(System.options.version == "kids") then
		damage = damage * (above_min_boost(boost_absolute) / 100);
		-- spell penetration
		if(spell_penetration > MAX_SPELL_PENETRATION) then
			spell_penetration = MAX_SPELL_PENETRATION;
		end
		resist_percent = math_ceil(resist_percent * (100 - spell_penetration - spell_penetration_receive) / 100);
		-- ignore absolute part of damage expression
		local _, boost;
		for _, boost in ipairs(buffs) do
			damage = math_ceil(damage * (100 + boost) / 100);
		end
		damage = math_ceil(damage * (100 + damage_percent) / 100);
		damage = math_ceil(damage * (100 + resist_percent) / 100);
	elseif(System.options.version == "teen") then
		damage = damage * (above_min_boost(boost_absolute) / 100);
		local buff_bonus = 0;
		local _, boost;
		for _, boost in ipairs(buffs) do
			if(boost > 0) then
				buff_bonus = buff_bonus + boost;
			end
		end
		local _, boost;
		for _, boost in ipairs(buffs) do
			if(boost < 0) then
				damage = damage * (100 + boost) / 100;
			end
		end
		damage = math_ceil(damage * (100 + buff_bonus) / 100);
		damage = math_ceil(damage * (100 + damage_percent) / 100);
		damage = math_ceil(damage * (100 + resist_percent) / 100);
	end
	return damage;
end

-- heal expression for normal process
-- @param base_heal: base heal
-- @param buffs: all strategy buff table {} plus input and output heal boost
local function heal_expression(base_heal, buffs)
	local heal = base_heal;
	if(System.options.version == "kids") then
		-- calculate heal
		local _, boost;
		for _, boost in ipairs(buffs) do
			heal = math_ceil(heal * (100 + boost) / 100);
		end
	elseif(System.options.version == "teen") then
		-- calculate heal
		--李宇(Liyu) 11:12:07
		--hi，andy，治疗专注的效果现在是加法，能帮我改成乘法么
		local _, boost;
		for _, boost in ipairs(buffs) do
			heal = heal * (100 + boost) / 100;
		end
		-- minimum of 1 hp point
		if(heal <= 0) then
			heal = 1;
		end
	end
	return heal;
end

-- process heal penalty
-- @return: real heal points
local function process_heal_penalty(arena, heal)
	if(arena and heal) then
		local heal_penalty = arena:GetArenaHealPenalty();
		if(heal_penalty and heal_penalty > 0) then
			heal = math_ceil(heal * (100 - heal_penalty) / 100);
		end
	end
	return heal;
end

-- using these cards in battlefield arena can't get the fighting_spirit_value
local invalid_card_key_for_fighting_spirit_value = {
	["Balance_Rune_SingleHealWithCleanse_Lv4"] = true,
	["Balance_Rune_SingleAttackWithSelfStun_Lv5"] = true,
	["Balance_Rune_SingleAttackWithStun_Lv5"] = true,
	["Balance_Rune_AreaAttackWithImmolate_Lv5"] = true,
};

local function CanGetFightingSpiritValueToUsingCard(key)
	if(key and invalid_card_key_for_fighting_spirit_value[key]) then
		return false;
	else
		return true;
	end
end

-- mark battlefield attack points
local function TryMarkBattleFieldAttack(arena, unit, damage, duration, caster, card_key)
	local can_get_fighting_spirit_value = nil;
	if(System.options.version == "kids") then
		can_get_fighting_spirit_value = CanGetFightingSpiritValueToUsingCard(card_key);
	end
	if(arena and arena.is_battlefield and unit and unit:IsMob() == false and caster and caster:IsMob() == false) then
		local unit_side = math.floor(unit:GetArrowPosition_id()/4);
		local caster_side = math.floor(caster:GetArrowPosition_id()/4);
		-- if the caster and target is in same side , not mark battle field;
		if(unit_side ~= caster_side) then
			Arena.Attack(arena, unit:GetID(), damage, duration, caster:GetID(), can_get_fighting_spirit_value);
		end
	end
end

-- mark battlefield heal points
local function TryMarkBattleFieldHeal(arena, unit, heal, duration, caster, card_key)
	local can_get_fighting_spirit_value = nil;
	if(System.options.version == "kids") then
		can_get_fighting_spirit_value = CanGetFightingSpiritValueToUsingCard(card_key);
	end
	if(arena and arena.is_battlefield and unit and unit:IsMob() == false and caster and caster:IsMob() == false) then

		Arena.OnBattleField_ReceiveHeal(arena, unit:GetID(), heal, duration, caster:GetID(), can_get_fighting_spirit_value);
	end
end

-- mark battlefield death
local function TryMarkBattleFieldDeath(arena, unit, duration)
	if(arena and arena.is_battlefield and unit and unit:IsMob() == false and not unit:IsAlive()) then
		Arena.OnBattleField_Death(arena, unit:GetID(), duration);
	end
end

-- try speak dead word
local function TrySpeakDeadWord(unit, arena_id, TurnSpellSequence)
	if(unit and unit:IsMob() and unit.GetStatByField) then
		local speak_dead = unit:GetStatByField("speak_dead");
		if(speak_dead) then
			local spell_str = "speak_dead:"..arena_id..",true,"..unit:GetID()..","..unit:GetPhase().."["..unit:GetDisplayName().."]".."["..speak_dead.."]";
			table_insert(TurnSpellSequence, spell_str);
		end
	end
end

-- get the card target if the param "card.template.target" is exist;
function Card.GetCardTargets(target_str,friendlys,hostiles)
	local targets;
	if(target_str and target_str ~= "") then
		targets = {};
		if(target_str == "friendly" or target_str == "all") then
			for _, unit in ipairs(friendlys) do
				if(not unit.isMob) then
					local player = Player.GetPlayerCombatObj(unit.id);
					if(player and player:IsAlive() and player:IsCombatActive()) then
						table_insert(targets, player);
					end
				else
					local mob = Mob.GetMobByID(unit.id);
					if(mob and mob:IsAlive()) then
						table_insert(targets, mob);
					end
				end
			end
		elseif(target_str == "hostile" or target_str == "all") then
			for _, unit in ipairs(hostiles) do
				if(not unit.isMob) then
					local player = Player.GetPlayerCombatObj(unit.id);
					if(player and player:IsAlive() and player:IsCombatActive()) then
						table_insert(targets, player);
					end
				else
					local mob = Mob.GetMobByID(unit.id);
					if(mob and mob:IsAlive()) then
						table_insert(targets, mob);
					end
				end
			end
		end
	end
	return targets;
end

-- NOTE: boost table is implemented as the resist
---- boost table of the spell
--local boost_table = {
	--["metal_wood"] = 20,
	--["wood_earth"] = 20,
	--["earth_water"] = 20,
	--["water_fire"] = 20,
	--["fire_metal"] = 20,
--};

-- use card of player or mob
-- @param key: card key name
-- @param arena: arena object
-- @param caster_data: {isMob, id}
-- @param target_data: {isMob, id}
-- @param sequence: spell play sequence of the turn, each spell play is appended to the table
-- @param original_key: original key for random generated spells
-- @return: true for successfully cast, false for fizzle or not success or pass or dead before cast
function Card.UseCard(key, card_seq, arena, caster_data, target_data, sequence, original_key)
	-- card template
	local template = Card.GetCardTemplate(key)
	if(not template) then
		log("error: invalid template key:"..tostring(key).." got in function Card.UseCard\n")
		return false;
	end
	
	if(template.type == "Random") then
		local spell_keys = {};
		local spell_key;
		for spell_key in string.gmatch(template.params.spelllist, "([^,]+)") do
			table.insert(spell_keys, spell_key);
		end
		local new_key = spell_keys[math.random(1, #spell_keys)];
		-- call the use card function again with the new key
		Card.UseCard(new_key, card_seq, arena, caster_data, target_data, sequence, key);
		return;
	end

	if(arena.is_postlog_usecard) then
		-- use card post log
		combat_server.AppendPostLog( {
			action = "arena_usecard_postlog", 
			key = arena.key_postlog_usecard, 
			nid = nid,
			caster_ismob = caster_data.isMob,
			caster_id = caster_data.id,
			target_ismob = target_data.isMob,
			target_id = target_data.id,
			card_key = key,
		});
	end
	
	-- caster and target object
	local caster, target;
	if(caster_data.isMob == true) then
		caster = Mob.GetMobByID(caster_data.id);
	elseif(caster_data.isMob == false) then
		caster = Player.GetPlayerCombatObj(caster_data.id);
	end
	if(target_data.isMob == true) then
		target = Mob.GetMobByID(target_data.id);
	elseif(target_data.isMob == false) then
		target = Player.GetPlayerCombatObj(target_data.id);
	end

	if(not caster) then
		log("error: invalid caster("..tostring(caster)..") got in function Card.UseCard\n")
		return false;
	end

	if(template.type == "PickPet") then
		-- same target and caster for pick pet
		target = caster;
	end
	
	-- pass 0.5: process caster mob pending threat
	if(caster:IsMob()) then
		caster:ProcessPendingThreatPerTurn();
	end

	local friendlys, hostiles = arena:GetFriendlyAndHostileUnits(caster:GetSide());

	if(template.type == "AreaAttack" or template.type == "ArenaAttack" or template.type == "AreaHeal" or 
		template.type == "AreaHealWithHOT" or template.type == "AreaTaunt" or 
		template.type == "AreaDOTAttack" or template.type == "AreaAttackWithDOT" or 
		template.type == "AreaPowerPipBoost" or template.type == "AreaCleanse" or template.type == "AreaControl" or 
		template.type == "AreaWard" or template.type == "AreaCharm" or 
		template.type == "AreaHealWithAbsorb" or template.type == "AreaAttackWithStun" or 
		template.type == "AreaAttackWithLifeTap" or template.type == "AreaStun" or 
		template.type == "AreaAttackWithImmolate" or template.type == "AreaAbsorb" or
		template.type == "AreaAttackWithExtraThreat") then
		-- if no target is available, pick the first alive object for area attack

		-- NOTE: if an area effect card is used, isMob stands for near or far arena units, NOT isMob itself
		local pickedSide;
		local lower_region;
		local upper_region;
		if(target_data.isMob == true) then
			pickedSide = "far";
			lower_region = 5;
			upper_region = 8;
		elseif(target_data.isMob == false) then
			pickedSide = "near";
			lower_region = 1;
			upper_region = 4;
		end
		if(pickedSide and lower_region and upper_region) then
			local i;
			for i = lower_region, upper_region do
				local unit = arena:GetCombatUnitBySlotID(i);
				if(unit and unit:IsAlive() and unit:IsCombatActive()) then
					target = unit;
					break;
				end
			end
		end
		--if(target_data.isMob == true) then
			---- target is mob
			--local mob_ids = arena:GetMobIDs();
			--local _, id;
			--for _, id in ipairs(mob_ids) do
				--local mob = Mob.GetMobByID(id);
				--if(mob and mob:IsAlive()) then
					--target = Mob.GetMobByID(id);
					--break;
				--end
			--end
		--elseif(target_data.isMob == false) then
			---- target is player
			--local player_nids = arena:GetPlayerNIDs();
			--local slot_id;
			--for slot_id = 1, 10 do -- we assume the maximum slot id is less than 10
				--local nid = player_nids[slot_id];
				--if(nid) then
					--local player = Player.GetPlayerCombatObj(nid);
					--if(player and player:IsAlive() and player:IsCombatActive()) then
						--target = Player.GetPlayerCombatObj(nid);
						--break;
					--end
				--end
			--end
		--end
		if(not target) then
			-- append pass if target is all dead
			local spell_str = "";
			local arrow_position = caster:GetArrowPosition_id();
			spell_str = format("pass:%s,%d,%s,%s", tostring(arena:GetID()), arrow_position, tostring(caster_data.isMob), caster_data.id);
			table_insert(sequence, spell_str);
			sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Pass");
			return false;
		end
	end
	
	if(not caster:IsMob()) then
		if(template.type == "Stance") then
			-- if caster stance school doesn't match, cancel card
			if(caster:GetPhase() ~= template.spell_school and template.spell_school ~= "balance") then
				-- append pass if caster stance school doesn't match
				local spell_str = "";
				local arrow_position = caster:GetArrowPosition_id();
				spell_str = format("pass:%s,%d,%s,%s", tostring(arena:GetID()), arrow_position, tostring(caster_data.isMob), caster_data.id);
				table_insert(sequence, spell_str);
				sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Pass");
				return false;
			end
		end
	end
	
	if(not target) then
		log("error: invalid target("..tostring(target)..") got in function Card.UseCard\n")
		return false;
	end
	
	-- get arena aura
	local GlobalAura, GlobalAura_boost_damage, GlobalAura_boost_school, GlobalAura_boost_heal, GlobalAura_boost_powerpip, GlobalAura_boost_powerpip = arena:GetAura();

	-- pass 1: DOTs (pop caster shields and traps)
	-- pop target shields and traps

	local caster_cur_hp = caster:GetCurrentHP();
	local caster_lost_hp = caster:GetMaxHP() - caster_cur_hp;
	local target_cur_hp = target:GetCurrentHP();
	local target_lost_hp = target:GetMaxHP() - target_cur_hp;
	local dot_damages = caster:PopDoT();
	local _, dot;
	for _, dot in ipairs(dot_damages) do
		-- dot basics
		local dot_damage = dot.damage;
		local dot_is_Critical = dot.bCritical;
		local dot_damage_school = dot.damage_school;
		local buffs_target = dot.buffs_target;
		local pips_realcost = dot.pips_realcost;
		local damage_boost_absolute = dot.damage_boost_absolute;
		local spell_penetration = dot.spell_penetration;
		local outputdamage_finalweight = dot.outputdamage_finalweight;
		local dot_caster = Player.GetPlayerCombatObj(dot.caster_id);
		if(dot_damage > 0) then
			local dot_buffs = commonlib.deepcopy(buffs_target);
			-- pop avaliable caster shield and traps
			dot_damage_school = caster:ProcessDamageAgainstWards(dot_buffs, dot_damage_school);
			-- damage school resist
			local resist = caster:GetResist(dot_damage_school);
			-- NOTE 2012/9/12: we comment the following line to use the dot.spell_penetration as caster spell_penetration
			--				   since spell_penetration is a school independent attribute, school test is not required
			--local spell_penetration = caster:GetSpellPenetration(dot_damage_school);
			local spell_penetration_receive = caster:GetSpellPenetrationReceive(dot_damage_school);
			dot_buffs.resist_percent = resist;
			dot_buffs.spell_penetration = spell_penetration;
			dot_buffs.spell_penetration_receive = spell_penetration_receive;
			-- check arena aura
			if(GlobalAura_boost_school == dot_damage_school and GlobalAura_boost_damage) then
				table_insert(dot_buffs, GlobalAura_boost_damage);
			end
			local resist_absolute = caster:GetResist_absolute(dot_damage_school);
			-- calculate dot damage
			dot_damage = damage_expression(dot_damage, damage_boost_absolute + resist_absolute, dot_buffs);
			-- final output and receive damage weight
			dot_damage = math_ceil(dot_damage * outputdamage_finalweight);
			dot_damage = math_ceil(dot_damage * caster:GetReceiveDamageFinalWeight(dot_damage_school));
			-- check avaliable absorbs
			dot_damage = AbsorbDamage(caster, dot_damage);
			-- reflect damage amount
			local isReflectShieldBreak = false;
			if(caster.reflect_amount > 0) then
				if(dot_damage >= caster.reflect_amount) then
					-- shield break
					dot_damage = dot_damage - caster.reflect_amount;
					caster.reflect_amount = 0;
					isReflectShieldBreak = true;
				else
					-- shield stand
					caster.reflect_amount = caster.reflect_amount - dot_damage;
					dot_damage = 0;
				end
			end

			--local caster_cur_hp = caster:GetCurrentHP();
			--local target_cur_hp = target:GetCurrentHP();
			if(arena.is_battlefield and dot_damage>caster_cur_hp) then
				dot_damage=caster_cur_hp;
			end
			-- take damage
			caster:TakeDamage(dot_damage);
			-- append dot spell play
			local spell_str = "";
			local damage_school = template.params.damage_school;
			local arrow_position = caster:GetArrowPosition_id();
			local dmg_mark = "";
			if(dot_is_Critical) then
				dmg_mark = "c";
			end
			spell_str = format("dot:%d,%d,%s,%s,%s,%s%d#%s", arena:GetID(), arrow_position, tostring(caster_data.isMob), caster_data.id, dot_damage_school, dmg_mark, dot_damage, caster:GetWardsValue());
			table_insert(sequence, spell_str);
			sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("DoT_"..dot_damage_school);
			-- mark battlefield attack points
			TryMarkBattleFieldAttack(arena, caster, dot_damage, sequence.duration, dot_caster);
			-- break freeze status if so
			if(caster.freeze_rounds > 0) then
				caster.freeze_rounds = 0;
				---- additional update to remove the ice block
				--local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
				--spell_str = format("update_arena:%s+%s", key, value);
				--table_insert(sequence, spell_str);
				---- play the break freeze spell
				--local arrow_position = caster:GetArrowPosition_id();
				--spell_str = format("%s:%s,%d,%d,%s,%d,%d,%s,%d,%d,%d,%d#%s#%s#%s#%s#%s#%s#%s#%s", 
							--"Ice_SingleFreeze_Break", "Ice_SingleFreeze_Break", arena:GetID(), arrow_position, 
							--tostring(caster_data.isMob), caster_data.id, caster:GetArrowPosition_id(), 
							--tostring(caster_data.isMob), caster_data.id, caster:GetArrowPosition_id(), 
							--0, 0, 
							--caster:GetCharmsValue(), caster:GetCharmsValue(), 
							--caster:GetCharmsValue(), caster:GetCharmsValue(), 
							--caster:GetWardsValue(), caster:GetWardsValue(), 
							--caster:GetOverTimeValue(), caster:GetOverTimeValue());
				--table_insert(sequence, spell_str);
				--sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Ice_SingleFreeze_Break");
			end
			-- play break shield spell if any
			if(isReflectShieldBreak) then
				local arrow_position = caster:GetArrowPosition_id();
				spell_str = format("%s:%s,%d,%d,%s,%s,%d,%s,%s,%d,%d,%d#%s#%s#%s#%s#%s#%s#%s#%s", 
							"Ice_ReflectionShield_shieldbreak", "Ice_ReflectionShield_shieldbreak", arena:GetID(), arrow_position, 
							tostring(caster_data.isMob), caster_data.id, caster:GetArrowPosition_id(), 
							tostring(caster_data.isMob), caster_data.id, caster:GetArrowPosition_id(), 
							0, 0, 
							caster:GetCharmsValue(), caster:GetCharmsValue(), 
							caster:GetCharmsValue(), caster:GetCharmsValue(), 
							caster:GetWardsValue(), caster:GetWardsValue(), 
							caster:GetOverTimeValue(), caster:GetOverTimeValue());
				table_insert(sequence, spell_str);
				sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Ice_ReflectionShield_shieldbreak");
			end
			-- append dead play if caster is dead
			if(not caster:IsAlive()) then
				-- try speak dead word
				TrySpeakDeadWord(caster, arena:GetID(), sequence);
				local spell_str = "";
				spell_str = format("dead:%d,%d,%s,%s", arena:GetID(), arrow_position, tostring(caster_data.isMob), caster_data.id);
				table_insert(sequence, spell_str);
				sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Dead");
				-- mark battlefield death
				TryMarkBattleFieldDeath(arena, caster, sequence.duration);
				-- update arena
				local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
				spell_str = format("update_arena:%s+%s", key, value);
				table_insert(sequence, spell_str);
				-- update value
				local value = caster:GetValue_normal_update();
				spell_str = format("update_value:%s", value);
				table_insert(sequence, spell_str);
				return false;
			end
			-- update arena
			local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
			spell_str = format("update_arena:%s+%s", key, value);
			table_insert(sequence, spell_str);
			-- update value
			local value = caster:GetValue_normal_update();
			spell_str = format("update_value:%s", value);
			table_insert(sequence, spell_str);
		elseif(dot_damage < 0) then
			-- this is a splash dot damage
			-- get friendly siblins
			local siblins = {};
			-- dot attack on siblins and caster
			table.insert(siblins, caster);
			local _, unit;
			for _, unit in ipairs(friendlys) do
				if(not unit.isMob) then
					local player = Player.GetPlayerCombatObj(unit.id);
					if(player and player:IsAlive() and player:IsCombatActive()) then
						if(player:GetArrowPosition_id() == (caster:GetArrowPosition_id() + 1)) then
							table.insert(siblins, player);
						elseif(player:GetArrowPosition_id() == (caster:GetArrowPosition_id() - 1)) then
							table.insert(siblins, player);
						end
					end
				else
					local mob = Mob.GetMobByID(unit.id);
					if(mob and mob:IsAlive() and mob:IsCombatActive()) then
						if(mob:GetArrowPosition_id() == (caster:GetArrowPosition_id() + 1)) then
							table.insert(siblins, mob);
						elseif(mob:GetArrowPosition_id() == (caster:GetArrowPosition_id() - 1)) then
							table.insert(siblins, mob);
						end
					end
				end
			end
			-- dot basics
			local base_dot_damage = math.abs(dot_damage);
			local base_dot_damage_school = dot_damage_school;
			-- damage blocks
			local ismob_id_damage_blocks = "";
			-- extra play appended to sequence if any target is dead or damaged
			local extra_play_seq = {};
			local last_caster_charms = caster:GetCharmsValue();
			-- unit attack points mapping
			local unit_damage_mapping = {};
			-- each dot attack 
			local _, unit;
			for _, unit in ipairs(siblins) do
				local last_target_wards = unit:GetWardsValue();
				local last_target_overtimes = unit:GetOverTimeValue();
				local dot_buffs = commonlib.deepcopy(buffs_target);
				local this_dot_damage = base_dot_damage;
				local this_dot_damage_school = base_dot_damage_school;
				-- pop avaliable caster shield and traps
				this_dot_damage_school = unit:ProcessDamageAgainstWards(dot_buffs, this_dot_damage_school);
				-- damage school resist
				local resist = caster:GetResist(this_dot_damage_school);
				-- NOTE 2012/9/12: we comment the following line to use the dot.spell_penetration as caster spell_penetration
				--				   since spell_penetration is a school independent attribute, school test is not required
				--local spell_penetration = caster:GetSpellPenetration(dot_damage_school);
				local spell_penetration_receive = caster:GetSpellPenetrationReceive(this_dot_damage_school);
				dot_buffs.resist_percent = resist;
				dot_buffs.spell_penetration = spell_penetration;
				dot_buffs.spell_penetration_receive = spell_penetration_receive;
				-- check arena aura
				if(GlobalAura_boost_school == this_dot_damage_school and GlobalAura_boost_damage) then
					table_insert(dot_buffs, GlobalAura_boost_damage);
				end
				-- absolute damage
				local resist_absolute = unit:GetResist_absolute(this_dot_damage_school);
				-- calculate dot damage
				this_dot_damage = damage_expression(this_dot_damage, damage_boost_absolute + resist_absolute, dot_buffs);
				-- check if siblin, apply portion of the base damage
				if((unit:IsMob() == caster:IsMob()) and (unit:GetID() == caster:GetID())) then
					this_dot_damage = this_dot_damage;
				else
					this_dot_damage = this_dot_damage * splash_damage_siblin_ratio;
				end
				-- final output and receive damage weight
				--this_dot_damage = math_ceil(this_dot_damage * outputdamage_finalweight);
				this_dot_damage = math_ceil(this_dot_damage * 1);
				this_dot_damage = math_ceil(this_dot_damage * unit:GetReceiveDamageFinalWeight(this_dot_damage_school));
				-- check avaliable absorbs
				this_dot_damage = AbsorbDamage(unit, this_dot_damage);
				-- reflect damage amount
				local isReflectShieldBreak = false;
				if(unit.reflect_amount > 0) then
					if(this_dot_damage >= unit.reflect_amount) then
						-- shield break
						this_dot_damage = this_dot_damage - unit.reflect_amount;
						unit.reflect_amount = 0;
						isReflectShieldBreak = true;
					else
						-- shield stand
						unit.reflect_amount = unit.reflect_amount - this_dot_damage;
						this_dot_damage = 0;
					end
				end

				--local caster_cur_hp = caster:GetCurrentHP();
				--local target_cur_hp = target:GetCurrentHP();
				local unit_cur_hp = unit:GetCurrentHP();
				if(arena.is_battlefield and this_dot_damage > unit_cur_hp) then
					this_dot_damage = unit_cur_hp;
				end

				-- take damage
				unit:TakeDamage(this_dot_damage);
				-- push unit damage mapping
				table.insert(unit_damage_mapping, {unit, this_dot_damage});
				-- break freeze status if so
				if(unit.freeze_rounds > 0) then
					unit.freeze_rounds = 0;
					---- additional update to remove the ice block
					--local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
					--spell_str = format("update_arena:%s+%s", key, value);
					--table_insert(sequence, spell_str);
					---- play the break freeze spell
					--local arrow_position = unit:GetArrowPosition_id();
					--spell_str = format("%s:%s,%d,%d,%s,%d,%d,%s,%d,%d,%d,%d#%s#%s#%s#%s#%s#%s#%s#%s", 
								--"Ice_SingleFreeze_Break", "Ice_SingleFreeze_Break", arena:GetID(), arrow_position, 
								--tostring(unit:IsMob()), unit:GetID(), unit:GetArrowPosition_id(), 
								--tostring(unit:IsMob()), unit:GetID(), unit:GetArrowPosition_id(), 
								--0, 0, 
								--unit:GetCharmsValue(), unit:GetCharmsValue(), 
								--unit:GetCharmsValue(), unit:GetCharmsValue(), 
								--unit:GetWardsValue(), unit:GetWardsValue(), 
								--unit:GetOverTimeValue(), unit:GetOverTimeValue());
					--table_insert(sequence, spell_str);
					--sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Ice_SingleFreeze_Break");
				end
				-- play break shield spell if any
				if(isReflectShieldBreak) then
					local arrow_position = unit:GetArrowPosition_id();
					spell_str = format("%s:%s,%d,%d,%s,%s,%d,%s,%s,%d,%d,%d#%s#%s#%s#%s#%s#%s#%s#%s", 
								"Ice_ReflectionShield_shieldbreak", "Ice_ReflectionShield_shieldbreak", arena:GetID(), arrow_position, 
								tostring(unit:IsMob()), unit:GetID(), unit:GetArrowPosition_id(), 
								tostring(unit:IsMob()), unit:GetID(), unit:GetArrowPosition_id(), 
								0, 0, 
								unit:GetCharmsValue(), unit:GetCharmsValue(), 
								unit:GetCharmsValue(), unit:GetCharmsValue(), 
								unit:GetWardsValue(), unit:GetWardsValue(), 
								unit:GetOverTimeValue(), unit:GetOverTimeValue());
					table_insert(extra_play_seq, spell_str);
					sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Ice_ReflectionShield_shieldbreak");
				end
				-- append dead play if target is dead
				if(not unit:IsAlive()) then
					-- try speak dead word
					TrySpeakDeadWord(unit, arena:GetID(), extra_play_seq);
					local spell_str = "";
					spell_str = format("dead:%d,%d,%s,%s", arena:GetID(), unit:GetArrowPosition_id(), tostring(unit:IsMob()), unit:GetID());
					table_insert(extra_play_seq, spell_str);
					sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Dead");
					-- mark battlefield death
					TryMarkBattleFieldDeath(arena, unit, sequence.duration);
				end
				-- append updated value
				local value = unit:GetValue_normal_update();
				spell_str = format("update_value:%s", value);
				table_insert(extra_play_seq, spell_str);

				local dmg_mark = "";
				if(dot_is_Critical) then
					dmg_mark = "c";
				end

				local ismob_id_damage = "";
				ismob_id_damage = format("(%s,%s,%d,%s%d#%s#%s#%s#%s#%s#%s)", tostring(unit:IsMob()), unit:GetID(), unit:GetArrowPosition_id(), dmg_mark, this_dot_damage, unit:GetCharmsValue(), unit:GetCharmsValue(), last_target_wards, unit:GetWardsValue(), last_target_overtimes, unit:GetOverTimeValue());
				ismob_id_damage_blocks = ismob_id_damage_blocks..ismob_id_damage;
			end

			-- get arrow position
			local arrow_position = caster:GetArrowPosition_id();
		
			-- append spell play
			local spell_str = "";
			spell_str = format("%s:%s,%d,%d,%s,%s+%s+%s+%s", "DoT_Fire_Splash", "DoT_Fire_Splash", arena:GetID(), arrow_position, tostring(caster_data.isMob), caster_data.id, last_caster_charms, caster:GetCharmsValue(), ismob_id_damage_blocks);
			table_insert(sequence, spell_str);
			sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("DoT_Fire_Splash");
			-- mark battlefield attack points
			local _, mapping;
			for _, mapping in ipairs(unit_damage_mapping) do
				TryMarkBattleFieldAttack(arena, mapping[1], mapping[2], sequence.duration, dot_caster);
			end
			-- append extra play sequence
			local _, seq;
			for _, seq in ipairs(extra_play_seq) do
				table_insert(sequence, seq);
			end
			-- update arena
			local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
			spell_str = format("update_arena:%s+%s", key, value);
			table_insert(sequence, spell_str);
			-- skip the card process if caster is dead
			if(not caster:IsAlive()) then
				return false;
			end
		end
	end

	-- pass 2: HOTs (pop caster shields and traps)
	local hot_heals = caster:PopHoT();
	local _, hot;
	for _, hot in ipairs(hot_heals) do
		-- hot basics
		local hot_heal = hot.heal;
		local hot_caster = Player.GetPlayerCombatObj(hot.caster_id);
		local hot_buffs = {};
		-- pop avaliable caster shield and traps
		local id, ward;
		for id, ward in pairs(wards) do
			if(ward.boost_heal) then
				if(caster:PopWard(id)) then
					table_insert(hot_buffs, ward.boost_heal);
				end
			end
		end
		-- check arena aura
		if(GlobalAura_boost_heal) then
			table_insert(hot_buffs, GlobalAura_boost_heal);
		end
		-- input heal boost
		local input_heal_boost = caster:GetInputHealBoost();
		table_insert(hot_buffs, input_heal_boost);
		-- calculate hot heal
		local _, boost;
		for _, boost in ipairs(hot_buffs) do
			hot_heal = math_ceil(hot_heal * (100 + boost) / 100);
		end
		-- arena heal penalty
		hot_heal = process_heal_penalty(arena, hot_heal);

		--local caster_lost_hp = caster:GetMaxHP() - caster_cur_hp;
		--local target_lost_hp = target:GetMaxHP() - target_cur_hp;
		if(arena.is_battlefield and hot_heal > caster_lost_hp) then
			hot_heal = caster_lost_hp;
		end

		-- take hot heal
		caster:TakeHeal(hot_heal);
		-- append hot spell play
		local spell_str = "";
		local arrow_position = caster:GetArrowPosition_id();
		spell_str = format("hot:%d,%d,%s,%s,%d#%s", arena:GetID(), arrow_position, tostring(caster_data.isMob), caster_data.id, hot_heal, caster:GetWardsValue());
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("HoT");
		-- take heal battle field mark
		TryMarkBattleFieldHeal(arena, caster, hot_heal, sequence.duration, hot_caster);
		-- append dead play if caster is dead
		if(not caster:IsAlive()) then
			-- try speak dead word
			TrySpeakDeadWord(caster, arena:GetID(), sequence);
			local spell_str = "";
			spell_str = format("dead:%d,%d,%s,%s", arena:GetID(), arrow_position, tostring(caster_data.isMob), caster_data.id);
			table_insert(sequence, spell_str);
			sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Dead");
			-- mark battlefield death
			TryMarkBattleFieldDeath(arena, caster, sequence.duration);
			-- update arena
			local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
			spell_str = format("update_arena:%s+%s", key, value);
			table_insert(sequence, spell_str);
			-- update value
			local value = caster:GetValue_normal_update();
			spell_str = format("update_value:%s", value);
			table_insert(sequence, spell_str);
			return false;
		end
		-- update arena
		local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
		spell_str = format("update_arena:%s+%s", key, value);
		table_insert(sequence, spell_str);
		-- update value
		local value = caster:GetValue_normal_update();
		spell_str = format("update_value:%s", value);
		table_insert(sequence, spell_str);
	end
	
	-- pass 3: check stun
	if(caster.bStunned == true) then
		caster.bStunned = false;
		-- append pass if caster is stunned
		local spell_str = "";
		local arrow_position = caster:GetArrowPosition_id();
		spell_str = format("pass:%s,%d,%s,%s", tostring(arena:GetID()), arrow_position, tostring(caster_data.isMob), caster_data.id);
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Pass");
		return false;
	end
	
	-- pass 3.2: check freeze rounds
	if(caster.freeze_rounds > 0) then
		---- NOTE 2011/11/30: freeze round validation moved to advance turn process
		--caster.freeze_rounds = caster.freeze_rounds - 1;

		-- append pass if caster is freezed
		local spell_str = "";
		local arrow_position = caster:GetArrowPosition_id();
		spell_str = format("pass:%s,%d,%s,%s", tostring(arena:GetID()), arrow_position, tostring(caster_data.isMob), caster_data.id);
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Pass");
		
		---- NOTE 2011/11/30: freeze round validation moved to advance turn process
		--if(caster.freeze_rounds == 0) then
			---- additional update to remove the ice block
			--local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
			--spell_str = format("update_arena:%s+%s", key, value);
			--table_insert(sequence, spell_str);
			---- play the break freeze spell
			--local arrow_position = caster:GetArrowPosition_id();
			--spell_str = format("%s:%s,%d,%d,%s,%d,%d,%s,%d,%d,%d,%d#%s#%s#%s#%s#%s#%s#%s#%s", 
						--"Ice_SingleFreeze_Break", "Ice_SingleFreeze_Break", arena:GetID(), arrow_position, 
						--tostring(caster_data.isMob), caster_data.id, caster:GetArrowPosition_id(), 
						--tostring(caster_data.isMob), caster_data.id, caster:GetArrowPosition_id(), 
						--0, 0, 
						--caster:GetCharmsValue(), caster:GetCharmsValue(), 
						--caster:GetCharmsValue(), caster:GetCharmsValue(), 
						--caster:GetWardsValue(), caster:GetWardsValue(), 
						--caster:GetOverTimeValue(), caster:GetOverTimeValue());
			--table_insert(sequence, spell_str);
			--sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Ice_SingleFreeze_Break");
		--end
		return false;
	end

	-- pass 4: check target validity
	if(template.type == "Pass" or (not target:IsAlive() and target:IsMob()) or (not target:IsAlive() and not string.find(template.type, "Heal"))) then
		-- append pass if uses pass card
		-- append pass if target mob is dead
		-- append pass if target dead player is not healed
		local spell_str = "";
		local arrow_position = caster:GetArrowPosition_id();
		spell_str = format("pass:%s,%d,%s,%s", tostring(arena:GetID()), arrow_position, tostring(caster_data.isMob), caster_data.id);
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Pass");
		return false;
	end

	-- pass 5: precheck if target has available charms or wards to steal or remove
	if( (template.type == "StealCharm" and not target:HasPositiveCharm()) or 
		(template.type == "RemovePositiveCharm" and not target:HasPositiveCharm()) or 
		(template.type == "RemoveNegativeCharm" and not target:HasNegativeCharm()) or 
		(template.type == "StealWard" and not target:HasPositiveWardForManipulate()) or 
		(template.type == "RemovePositiveWard" and not target:HasPositiveWardForManipulate()) or 
		(template.type == "RemoveNegativeWard" and not target:HasNegativeWardForManipulate()) ) then
			-- append pass if target has no available charm or ward
			local spell_str = "";
			local arrow_position = caster:GetArrowPosition_id();
			spell_str = format("pass:%s,%d,%s,%s", tostring(arena:GetID()), arrow_position, tostring(caster_data.isMob), caster_data.id);
			table_insert(sequence, spell_str);
			sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Pass");
			return false;
	end

	-- pass 6: precheck if target is dead and with reviveable spell cast
	if( (template.type == "SingleHeal" and not revivable_card_name[key] and not target:IsAlive()) or 
		(template.type == "SingleHealWithHOT" and not revivable_card_name[key] and not target:IsAlive()) or 
		(template.type == "SingleHealWithCleanse" and not revivable_card_name[key] and not target:IsAlive()) or 
		(template.type == "SingleHealWithImmolate" and not revivable_card_name[key] and not target:IsAlive()) ) then
			-- append pass if target is dead and cast with non_reviveable spell
			local spell_str = "";
			local arrow_position = caster:GetArrowPosition_id();
			spell_str = format("pass:%s,%d,%s,%s", tostring(arena:GetID()), arrow_position, tostring(caster_data.isMob), caster_data.id);
			table_insert(sequence, spell_str);
			sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Pass");
			return false;
	end

	-- precheck if target has stealth on single attacks
	local card_key_lower = string.lower(key);
	if(target:IsStealth()) then
		if( not (string.find(card_key_lower, "area") or string.find(card_key_lower, "arena") or string.find(card_key_lower, "singleheal")) ) then
			-- append pass if target has no available ward
			local spell_str = "";
			local arrow_position = caster:GetArrowPosition_id();
			spell_str = format("pass:%s,%d,%s,%s", tostring(arena:GetID()), arrow_position, tostring(caster_data.isMob), caster_data.id);
			table_insert(sequence, spell_str);
			sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Pass");
			return false;
		end
	end

	-- pass 7: precheck if target has available wards to converse
	if( (template.type == "ConversePositiveWard" and not target:HasWard(template.params.fromward, true)) ) then
		-- append pass if target has no available ward
		local spell_str = "";
		local arrow_position = caster:GetArrowPosition_id();
		spell_str = format("pass:%s,%d,%s,%s", tostring(arena:GetID()), arrow_position, tostring(caster_data.isMob), caster_data.id);
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Pass");
		return false;
	end

	-- pass 8: pick pet test
	if(template.type == "PickPet" and caster_data.isMob == false) then
		local guid = target_data.id; -- target id as follow pet guid
		local bSuccess, gsid = caster:SwitchToFollowPet(guid);
		if(bSuccess and gsid) then
			-- append pick pet spell play
			local spell_str = "";
			local spell_school = caster:GetPhase();
			local arrow_position = caster:GetArrowPosition_id();
			spell_str = format("pickpet:%d,%d,%s,%s,%d,%s,%s,%d,%s,%d,%d", 
						arena:GetID(), arrow_position, 
						tostring(caster_data.isMob), caster_data.id, caster:GetArrowPosition_id(), 
						tostring(caster_data.isMob), caster_data.id, caster:GetArrowPosition_id(), 
						spell_school, 
						gsid, 
						guid);
			table_insert(sequence, spell_str);
			sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("PickPet_"..spell_school);
			return false;
		end
	end

	-- pass 9: catch pet test
	if(template.type == "CatchPet" and caster_data.isMob == false and target_data.isMob == true) then
		local bSuccess = false;
		if(System.options.version == "teen") then
			bSuccess = caster:TryCatchPet(target, nil, template.params.weight);
		elseif(System.options.version == "kids") then
			bSuccess = caster:TryCatchPet(target, template.params.base_weight);
		end
		if(bSuccess) then
			-- append pick pet spell play
			local spell_str = "";
			local spell_school = caster:GetPhase();
			local arrow_position = caster:GetArrowPosition_id();
			spell_str = format("balance_catchpet_success:%d,%d,%s,%s,%d,%s,%s,%d,%s", 
						arena:GetID(), arrow_position, 
						tostring(caster_data.isMob), caster_data.id, caster:GetArrowPosition_id(), 
						tostring(target_data.isMob), target:GetID(), target:GetArrowPosition_id(), 
						spell_school);
			table_insert(sequence, spell_str);
			sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Balance_Catchpet_success");
			-- try speak dead word
			TrySpeakDeadWord(target, arena:GetID(), sequence);
			if(System.options.version ~= "teen") then
				local spell_str = "";
				local arrow_position = target:GetArrowPosition_id();
				spell_str = format("dead:%d,%d,%s,%s", arena:GetID(), arrow_position, tostring(target_data.isMob), target_data.id);
				table_insert(sequence, spell_str);
				sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Dead");
			end
			-- suiside pet
			target:TakeDamage(999999999);
			-- update arena
			local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
			spell_str = format("update_arena:%s+%s", key, value);
			table_insert(sequence, spell_str);
			-- card casted
			return true, 0;
		else
			-- append pick pet spell play
			local spell_str = "";
			local spell_school = caster:GetPhase();
			local arrow_position = caster:GetArrowPosition_id();
			spell_str = format("balance_catchpet_failed:%d,%d,%s,%s,%d,%s,%s,%d,%s", 
						arena:GetID(), arrow_position, 
						tostring(caster_data.isMob), caster_data.id, caster:GetArrowPosition_id(), 
						tostring(target_data.isMob), target:GetID(), target:GetArrowPosition_id(), 
						spell_school);
			table_insert(sequence, spell_str);
			sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Balance_Catchpet_failed");
			-- card casted
			return true, 0;
		end
	end

	-- pass 10: enrage
	if(template.type == "Enrage" and caster_data.isMob == false and target_data.isMob == true) then
		
		local can_enrage_minlevel = 0;
		local can_enrage_maxlevel = 0;
		if(template.params.can_enrage_minlevel) then
			can_enrage_minlevel = tonumber(template.params.can_enrage_minlevel);
		end
		if(template.params.can_enrage_maxlevel) then
			can_enrage_maxlevel = tonumber(template.params.can_enrage_maxlevel);
		end
		local level = target:GetLevel();
		if(level > can_enrage_maxlevel) then
			-- can't enrage higher level mobs
			return false;
		end
		if(level < can_enrage_minlevel) then
			-- can't enrage lower level mobs
			return false;
		end
		
		if(target:Rarity_normalupdate_str() == "b") then -- boss
			if(not template.params.can_enrage_boss) then
				return false;
			end
		end

		local difficulty = target:GetDifficulty();
		if(difficulty == "easy") then
			if(target:GetStatByField("cannot_enrage_easy")) then
				return false;
			end
		elseif(difficulty == "normal") then
			if(target:GetStatByField("cannot_enrage_normal")) then
				return false;
			end
		elseif(difficulty == "hard") then
			if(target:GetStatByField("cannot_enrage_hard")) then
				return false;
			end
		end

		local bSuccess = caster:TryEnrage(target);
		if(bSuccess) then
			-- auto full hp
			target:TakeHeal(99999999);
			-- append pick pet spell play
			local spell_str = "";
			local spell_school = caster:GetPhase();
			local spell_name = template.spell_name or "Balance_Rune_Enrage_Level1";
			local arrow_position = caster:GetArrowPosition_id();
			spell_str = format("%s:%d,%d,%s,%s,%d,%s,%s,%d,%s", 
						spell_name, arena:GetID(), arrow_position, 
						tostring(caster_data.isMob), caster_data.id, caster:GetArrowPosition_id(), 
						tostring(target_data.isMob), target:GetID(), target:GetArrowPosition_id(), 
						spell_school);
			table_insert(sequence, spell_str);
			sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname(spell_name);
			-- update arena
			local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
			spell_str = format("update_arena:%s+%s", key, value);
			table_insert(sequence, spell_str);
		else
			-- append pass if target has already been enraged
			local spell_str = "";
			local arrow_position = caster:GetArrowPosition_id();
			spell_str = format("pass:%s,%d,%s,%s", tostring(arena:GetID()), arrow_position, tostring(caster_data.isMob), caster_data.id);
			table_insert(sequence, spell_str);
			sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Pass");
			return false;
		end
	end

	-- TODO: pop caster blades if any modifications to accuracy
	local accuracy = template.accuracy;
	
	-- pop caster accuracy charms
	local spell_school = template.spell_school;
	local buffs = {};
	caster:ProcessAccuracyAgainstCharms(buffs, spell_school);
	local _, weight;
	for _, weight in pairs(buffs) do
		accuracy = accuracy + weight;
	end
	
	-- accuracy boost
	accuracy = accuracy + caster:GetAccuracyBoost(spell_school);
	local r = math.random(0, 100);

	-- debug purpose never fizzle mode
	if(debug_never_fizzles) then
		r = 0;
	end
	-- debug purpose always fizzle mode
	if(debug_always_fizzles) then
		r = 100;
	end
	
	-- get spell name
	local spell_name;
	local cardTemplate = Card.GetCardTemplate(key);
	if(cardTemplate) then
		spell_name = cardTemplate.spell_name;
	end
	
	-- pop caster dispel if exist and school match
	local with_dispel = false;
	local id, charm;
	for id, charm in pairs(charms_with_dispel) do
		if(charm.dispel_school) then
			if(string_lower(charm.dispel_school) == string_lower(template.spell_school)) then
				if(caster:PopCharm(id)) then
					with_dispel = true;
					break;
				end
			end
		end
	end
	
	if(r > accuracy or not spell_name) then
		-- fizzle
		-- append spell play
		local spell_str = "";
		local spell_school = template.spell_school;
		local arrow_position = caster:GetArrowPosition_id();
		spell_str = format("fizzle:%d,%d,%s,%s,%d,%s,%s,%d,%s", 
					arena:GetID(), arrow_position, 
					tostring(caster_data.isMob), caster_data.id, caster:GetArrowPosition_id(), 
					tostring(target_data.isMob), target:GetID(), caster:GetArrowPosition_id(), 
					spell_school);
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Fizzle_"..spell_school);
		return false;
	end

	-- cost pips
	-- NOTE: the returned pips_realcost is the real pips cost, if the spell is an X pips cost spell
	local pips_realcost = caster:CostPips(template.pipcost, template.spell_school);

	-- NOTE: the spell passed the accuracy test and pip cost and fizzle due to the dispel
	if(with_dispel == true and not caster:IsImmuneToDispel()) then
		-- fizzle
		-- append spell play
		local spell_str = "";
		local spell_school = template.spell_school;
		local arrow_position = caster:GetArrowPosition_id();
		spell_str = format("fizzle:%d,%d,%s,%s,%d,%s,%s,%d,%s", 
					arena:GetID(), arrow_position, 
					tostring(caster_data.isMob), caster_data.id, caster:GetArrowPosition_id(), 
					tostring(target_data.isMob), target:GetID(), caster:GetArrowPosition_id(), 
					spell_school);
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Fizzle_"..spell_school);
		return false;
	end
	
	---- NOTE: the original implementation is a expendable cards
	--if(caster_data.isMob == false) then
		--local nid = caster_data.id;
		---- cost card, if original_key is available use the original key
		--combat_server.AppendRealTimeMessageToNID(nid, "ExpendCard:"..(original_key or key));
	--end
	
	if(caster:IsMob() == false) then
		if(card_seq and card_seq >= 10000) then
			-- this is from pet card deck
			local gsid = caster:GetFollowPetGSID();
			if(gsid) then
				local spell_str = "";
				local arrow_position = caster:GetArrowPosition_id();
				spell_str = format("use_petcard:%d,%d,%s,%s,%s", arena:GetID(), arrow_position, tostring(caster_data.isMob), caster_data.id, tostring(gsid));
				table_insert(sequence, spell_str);
				sequence.duration = sequence.duration + 0;
			end
			-- next pet card is from pet cards, used as follow pet casting
			local spell_str = "";
			local arrow_position = caster:GetArrowPosition_id();
			spell_str = format("next_spell_is_from_petcard:%d,%d,%s,%s", arena:GetID(), arrow_position, tostring(caster_data.isMob), caster_data.id);
			table_insert(sequence, spell_str);
		end
	end

	if(template.type == "SingleAttackWithMultipleDamage") then
		
		local everyround_damage_equal = false;

		local base_damage;
		local damage_min,damage_max,damage_school,base_criticalstrike;
		if(template.params.damage_equal and (template.params.damage_equal == "true" or template.params.damage_equal == true)) then
			everyround_damage_equal = true;
			damage_min = Card.GetNumericalValueFromSection(template.params.damage_min, pips_realcost) or 0;
			damage_max = Card.GetNumericalValueFromSection(template.params.damage_max, pips_realcost) or 0;
			damage_school = template.params.damage_school;
			base_criticalstrike = tonumber(template.params.base_criticalstrike) or 0;
			base_damage = math.random(damage_min, damage_max);
		end

		--local damage = base_damage;
		
		-- record last value of the caster and target
		local last_caster_charms = caster:GetCharmsValue();

		local buffs_caster = {};
		local buffs_target = {};
		local buffs_absolute = 0;
		
		---- target damage school
		damage_school = if_else(damage_school,damage_school,template.params.damage_school_1);
		-- damage school boost
		local boost = caster:GetDamageBoost(damage_school);
		local boost_absolute = caster:GetDamageBoost_absolute(damage_school);

		buffs_target.damage_percent = boost;
		buffs_absolute = buffs_absolute + boost_absolute;

		-- pop caster blades and weaknesses
		caster:ProcessDamageAgainstCharms(buffs_caster, damage_school, buffs_target);
		
		local caster_arrow_position = caster:GetArrowPosition_id();
		local target_arrow_position = target:GetArrowPosition_id();

		local attack_times;
		if(template.params.random_times) then
			local min_times,max_times = string.match(template.params.random_times,"(%d+),(%d+)");
			local min_times = tonumber(min_times);
			local max_times = tonumber(max_times);
			attack_times = math.random(min_times,max_times);
		else
			attack_times = tonumber(template.params.times);
		end
		
		local i;
		for i = 1,attack_times do
			if(target:IsAlive()) then
				if(not everyround_damage_equal) then
					local time_suffix = "_"..tostring(i);
					damage_min = Card.GetNumericalValueFromSection(template.params["damage_min"..time_suffix], pips_realcost) or 0;
					damage_max = Card.GetNumericalValueFromSection(template.params["damage_max"..time_suffix], pips_realcost) or 0;
					damage_school = template.params["damage_school"..time_suffix];
					base_criticalstrike = tonumber(template.params["base_criticalstrike"..time_suffix]) or 0;
					base_damage = math.random(damage_min, damage_max);
				end		
				
				damage = base_damage;

				local everytime_buffs_target = {};
				commonlib.partialcopy(everytime_buffs_target,buffs_target);
				local last_target_wards = target:GetWardsValue();
				local last_target_overtimes = target:GetOverTimeValue();
				local last_caster_wards = caster:GetWardsValue();

				damage_school = target:ProcessDamageAgainstWards(everytime_buffs_target, damage_school);
				-- damage school boost
				local resist = target:GetResist(damage_school);
				local spell_penetration = caster:GetSpellPenetration(damage_school);
				local spell_penetration_receive = target:GetSpellPenetrationReceive(damage_school);
				-- added card spell penetration
				local base_spellpenetration = template.params.base_spellpenetration or 0;
				spell_penetration = spell_penetration + base_spellpenetration;
				local resist_absolute = target:GetResist_absolute(damage_school);
			
				-- skip target resist test on percental damage
				everytime_buffs_target.resist_percent = resist;
				everytime_buffs_target.spell_penetration = spell_penetration;
				everytime_buffs_target.spell_penetration_receive = spell_penetration_receive;
				buffs_absolute = buffs_absolute + resist_absolute;
			
		
				-- check arena aura
				if(GlobalAura_boost_school == damage_school and GlobalAura_boost_damage) then
					table_insert(everytime_buffs_target, GlobalAura_boost_damage);
				end

				-- calculate all damage modifiers
				damage = damage_expression(damage, buffs_absolute, everytime_buffs_target);
				local dmg_mark = "";

				local base_spell_hitchance = template.hitchance or 100;

				local base_doubleattack = template.params.base_doubleattack or 0;
				--local base_criticalstrike = template.params.base_criticalstrike or 0;
				if(System.options.version ~= "kids" or (System.options.version == "kids" and arena.mode ~= "free_pvp")) then
					if(TryDodge(caster, target, base_spell_hitchance, damage_school)) then
						damage = math_ceil(damage * dodge_damage_ratio);
						dmg_mark = "d"; -- for dodge, dodge will overwrite the critical mark	
					else
						if(TryDoubleAttack(caster, target, base_doubleattack, damage_school)) then
							damage = math_ceil(damage * 2);
							dmg_mark = "t"; -- for double attack
						else
							if(TryCriticalStrike(caster, target, base_criticalstrike, damage_school)) then
								damage = math_ceil(damage * GetCriticalStrikeDamageRatio(caster));
								if(template.params.extra_damage_if_critical) then
									local extra_damage = tonumber(template.params.extra_damage_if_critical);
									damage = damage*(1 + extra_damage);
								end
								dmg_mark = "c"; -- for critical
							end
						end
					end
				else
					if(target.remedy.absoluteDefense_protect_rounds <= 0 and TryDodge(caster, target, base_spell_hitchance, damage_school)) then
						dmg_mark = "d";
						damage = 1;
						target.remedy.absoluteDefense_protect_rounds = protect_rounds_for_remedy;
					else
						if(target.remedy.deadlyAttack_protect_rounds <= 0 and TryDoubleAttack(caster, target, base_doubleattack, damage_school)) then
							damage = math_ceil(damage * 2);
							dmg_mark = "t"; -- for double attack
							target.remedy.deadlyAttack_protect_rounds = protect_rounds_for_remedy;
						else
							if(TryCriticalStrike(caster, target, base_criticalstrike, damage_school)) then
								damage = math_ceil(damage * GetCriticalStrikeDamageRatio(caster));
								if(template.params.extra_damage_if_critical) then
									local extra_damage = tonumber(template.params.extra_damage_if_critical);
									damage = damage*(1 + extra_damage);
								end
								dmg_mark = "c"; -- for critical
							end
						end
					end
				end

				-- final output damage weight
				damage = math.ceil(damage * caster:GetOutputDamageFinalWeight());
		
				-- final receive damage weight AFTER max percent damage
				damage = math.ceil(damage * target:GetReceiveDamageFinalWeight(damage_school));


				-- append threat
				local _, unit;
				for _, unit in ipairs(hostiles) do
					if(unit.isMob) then
						local mob = Mob.GetMobByID(unit.id);
						if(mob and mob:IsAlive()) then
							local base_threat = GetDamageThreat(damage, caster:GetPhase());
							if((target:IsMob() == mob:IsMob()) and (target:GetID() == mob:GetID())) then
								mob:AppendThreat(caster, base_threat)
							else
								mob:AppendThreat(caster, math.ceil(base_threat * splash_damage_threat_ratio));
							end
						end
					end
				end
			
				-- check avaliable absorbs
				damage = AbsorbDamage(target, damage);

				local bShieldBreak = false;
				local ReflectDamage = 0;

				local additional_reflection_shield_sequence = {};
				if(target.reflect_amount > 0 and damage > 0) then
					ReflectDamage = damage;
					-- calculate damage and reflect_amount
					if(damage >= target.reflect_amount) then
						-- break the shield
						damage = damage - target.reflect_amount;
						target.reflect_amount = 0;
						bShieldBreak = true;
					else
						-- absorb all damage
						target.reflect_amount = target.reflect_amount - damage;
						damage = 0;
					end
				end
		
			
				--local caster_cur_hp = caster:GetCurrentHP();
				--local target_cur_hp = target:GetCurrentHP();
				if(arena.is_battlefield and damage > target_cur_hp) then
					damage = target_cur_hp;
				end
				target:TakeDamage(damage);
				-- append pierce freeze round
				if(caster:GetStance() == "pierce") then
					target:AppendPierceFreezeRounds(3);
				end

				local additional_reflection_shield_sequence = {};
				if(ReflectDamage > 0) then
					local reflect_buffs = {};
					-- pop avaliable caster shield and traps
					local reflect_damage = ReflectDamage;
					local reflect_damage_school = caster:ProcessDamageAgainstWards(reflect_buffs, damage_school);
					-- damage school resist
					local resist = caster:GetResist(reflect_damage_school);
					local spell_penetration = caster:GetSpellPenetration(reflect_damage_school);
					local spell_penetration_receive = caster:GetSpellPenetrationReceive(reflect_damage_school);
					local damageboost_absolute = caster:GetDamageBoost_absolute(reflect_damage_school);
					local resist_absolute = caster:GetResist_absolute(reflect_damage_school);
					reflect_buffs.resist_percent = resist;
					reflect_buffs.spell_penetration = spell_penetration;
					reflect_buffs.spell_penetration_receive = spell_penetration_receive;
					-- check arena aura
					if(GlobalAura_boost_school == reflect_damage_school and GlobalAura_boost_damage) then
						table_insert(reflect_buffs, GlobalAura_boost_damage);
					end
					-- calculate reflect damage
					-- NOTE 2012/1/24: cancel damageboost_absolute + resist_absolute for reflect damage
					reflect_damage = damage_expression(reflect_damage, 0, reflect_buffs);

					-- final output and receive damage weight
					reflect_damage = math.ceil(reflect_damage * caster:GetOutputDamageFinalWeight());
					reflect_damage = math.ceil(reflect_damage * caster:GetReceiveDamageFinalWeight(reflect_damage_school));

					-- check avaliable absorbs
					reflect_damage = AbsorbDamage(caster, reflect_damage);
					-- test reflect damage
					local caster_current_hp = caster:GetCurrentHP();
					if(reflect_damage >= MAX_REFLECT_DAMAGE) then
						-- max reflect damage
						reflect_damage = MAX_REFLECT_DAMAGE;
					end
					if(reflect_damage >= caster_current_hp) then
						-- reflect damage is not deathful
						reflect_damage = caster_current_hp - 1;
					end
					-- take damage
					caster:TakeDamage(reflect_damage);
					-- skip freeze test, because caster can't attack while freezed
					-- append reflection spell play
					local spell_str = "";
					local damage_school = template.params.damage_school;
					local arrow_position = caster:GetArrowPosition_id();
					spell_str = format("%s:%s,%d,%d,%s,%s,%d,%s,%s,%d,%d,%d#%s#%s#%s#%s#%s#%s#%s#%s", 
								"Ice_ReflectionShield_reflection", "Ice_ReflectionShield_reflection", arena:GetID(), arrow_position, 
								tostring(target_data.isMob), target_data.id, target:GetArrowPosition_id(), 
								tostring(caster_data.isMob), caster_data.id, caster:GetArrowPosition_id(), 
								reflect_damage, 0, 
								target:GetCharmsValue(), target:GetCharmsValue(), 
								caster:GetCharmsValue(), caster:GetCharmsValue(), 
								caster:GetWardsValue(), caster:GetWardsValue(), 
								caster:GetOverTimeValue(), caster:GetOverTimeValue());
					table_insert(additional_reflection_shield_sequence, spell_str);
					sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Ice_ReflectionShield_reflection");
					-- mark battlefield attack points
					TryMarkBattleFieldAttack(arena, caster, reflect_damage, sequence.duration, target);
					-- append dead play if caster is dead
					if(not caster:IsAlive()) then
						-- try speak dead word
						TrySpeakDeadWord(caster, arena:GetID(), additional_reflection_shield_sequence);
						local spell_str = "";
						spell_str = format("dead:%d,%d,%s,%s", arena:GetID(), arrow_position, tostring(caster_data.isMob), caster_data.id);
						table_insert(additional_reflection_shield_sequence, spell_str);
						sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Dead");
						-- mark battlefield death
						TryMarkBattleFieldDeath(arena, caster, sequence.duration);
						-- update arena
						local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
						spell_str = format("update_arena:%s+%s", key, value);
						table_insert(additional_reflection_shield_sequence, spell_str);
						-- update value
						local value = caster:GetValue_normal_update();
						spell_str = format("update_value:%s", value);
						table_insert(additional_reflection_shield_sequence, spell_str);
						return false;
					end
					-- update arena
					local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
					spell_str = format("update_arena:%s+%s", key, value);
					table_insert(additional_reflection_shield_sequence, spell_str);
					-- update value
					local value = caster:GetValue_normal_update();
					spell_str = format("update_value:%s", value);
					table_insert(additional_reflection_shield_sequence, spell_str);
					-- calculate damage and reflect_amount
					if(bShieldBreak) then
						-- play break shield spell
						local arrow_position = caster:GetArrowPosition_id();
						spell_str = format("%s:%s,%d,%d,%s,%s,%d,%s,%s,%d,%d,%d#%s#%s#%s#%s#%s#%s#%s#%s", 
									"Ice_ReflectionShield_shieldbreak", "Ice_ReflectionShield_shieldbreak", arena:GetID(), arrow_position, 
									tostring(target_data.isMob), target_data.id, target:GetArrowPosition_id(), 
									tostring(caster_data.isMob), caster_data.id, caster:GetArrowPosition_id(), 
									0, 0, 
									target:GetCharmsValue(), target:GetCharmsValue(), 
									caster:GetCharmsValue(), caster:GetCharmsValue(), 
									caster:GetWardsValue(), caster:GetWardsValue(), 
									caster:GetOverTimeValue(), caster:GetOverTimeValue());
						table_insert(additional_reflection_shield_sequence, spell_str);
						sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Ice_ReflectionShield_shieldbreak");
					end
				end

				-- break freeze status if so
				if(target.freeze_rounds > 0) then
					target.freeze_rounds = 0;
				end

				-- secondary damage or heal
				local secondary_param = 0;

				-- get arrow position
				--local arrow_position = caster:GetArrowPosition_id();
		
				-- append spell play
				local spell_str = "";
				if(i == 1) then
					spell_str = format("%s:%s,%d,%d,%s,%s,%d,%s,%s,%d,%s,%d#%s#%s#%s#%s#%s#%s#%s#%s", spell_name, key, arena:GetID(), caster_arrow_position, 
							tostring(caster_data.isMob), caster_data.id, caster:GetArrowPosition_id(), 
							tostring(target_data.isMob), target_data.id, target:GetArrowPosition_id(), 
							(dmg_mark or "")..damage, secondary_param, 
							last_caster_charms, caster:GetCharmsValue(), 
							target:GetCharmsValue(), target:GetCharmsValue(), 
							last_target_wards, target:GetWardsValue(), 
							last_target_overtimes, target:GetOverTimeValue());
					table_insert(sequence, spell_str);
					sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname(spell_name);
				else
					arrow_position = target:GetArrowPosition_id();
					spell_str = format("dot:%d,%d,%s,%s,%s,%s%d#%s", arena:GetID(), target_arrow_position, tostring(target_data.isMob), target_data.id, damage_school, dmg_mark, damage, target:GetWardsValue());
					table_insert(sequence, spell_str);
					sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("DoT_"..damage_school);
				end
		
				-- mark battlefield attack points
				TryMarkBattleFieldAttack(arena, target, damage, sequence.duration, caster, key);
		
				-- append dead play if caster is dead
				if(not caster:IsAlive()) then
					-- try speak dead word
					TrySpeakDeadWord(caster, arena:GetID(), sequence);
					local spell_str = "";
					spell_str = format("dead:%d,%d,%s,%s", arena:GetID(), caster:GetArrowPosition_id(), tostring(caster_data.isMob), caster_data.id);
					table_insert(sequence, spell_str);
					sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Dead");
					-- mark battlefield death
					TryMarkBattleFieldDeath(arena, caster, sequence.duration);
				end
				-- append dead play if target is dead
				if(not target:IsAlive()) then
					-- try speak dead word
					TrySpeakDeadWord(target, arena:GetID(), sequence);
					local spell_str = "";
					spell_str = format("dead:%d,%d,%s,%s", arena:GetID(), target:GetArrowPosition_id(), tostring(target_data.isMob), target_data.id);
					table_insert(sequence, spell_str);
					sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Dead");
					-- mark battlefield death
					TryMarkBattleFieldDeath(arena, target, sequence.duration);
				end
				-- update arena
				local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
				spell_str = format("update_arena:%s+%s", key, value);
				table_insert(sequence, spell_str);
				-- update value
				local value = target:GetValue_normal_update();
				spell_str = format("update_value:%s", value);
				table_insert(sequence, spell_str);

				-- append additional reflection shield sequence
				local _, spell_line;
				for _, spell_line in ipairs(additional_reflection_shield_sequence) do
					table_insert(sequence, spell_line);
				end
			end
		end		
	elseif(template.type == "SingleAttack" or template.type == "SingleAttackWithDOT" or 
		template.type == "SingleAttackWithStandingWards" or template.type == "SingleAttackWithTrap" or 
		template.type == "SingleAttackWithExplode" or template.type == "SingleAttackWithLifeTap" or 
		template.type == "SingleAttackWithImmolate" or template.type == "SingleAttackWithPercent" or 
		template.type == "SingleAttackWithStun" or template.type == "SingleAttackWithSelfStun" or template.type == "SingleAttackWithLifeTapAndStandingWards") then
		-- base damage
		local damage_min = Card.GetNumericalValueFromSection(template.params.damage_min, pips_realcost) or 0;
		local damage_max = Card.GetNumericalValueFromSection(template.params.damage_max, pips_realcost) or 0;
		if(template.type == "SingleAttackWithPercent") then
			local damage_percent = template.params.damage_percent;
			local damage_percent_real = math.ceil(target:GetCurrentHP() * damage_percent / 100);
			damage_min = Card.GetNumericalValueFromSection(damage_percent_real, pips_realcost) or 0;
			damage_max = Card.GetNumericalValueFromSection(damage_percent_real, pips_realcost) or 0;
		end
		if(template.type == "SingleAttackWithExplode") then
			-- check dots with negative damage
			local bExist = target:PopExplodeDotsIfExist();
			if(bExist) then
				damage_min = Card.GetNumericalValueFromSection(template.params.damage_min_explode, pips_realcost) or 0;
				damage_max = Card.GetNumericalValueFromSection(template.params.damage_max_explode, pips_realcost) or 0;
			end
		end
		local base_damage = math.random(damage_min, damage_max);
		
		local damage = base_damage;
		
		-- record all the buff and debuffs
		local buffs_caster = {};
		local buffs_target = {};
		local buffs_absolute = 0;
		
		-- record last value of the caster and target
		local last_caster_charms = caster:GetCharmsValue();
		local last_caster_wards = caster:GetWardsValue();
		local last_target_wards = target:GetWardsValue();
		local last_target_overtimes = target:GetOverTimeValue();
		
		-- caster damage school
		if(template.type == "SingleAttackWithImmolate" or template.type == "SingleAttackWithPercent") then
			local immolate_damage_school = template.params.immolate_damage_school;
			-- immolate school boost
			local boost = caster:GetDamageBoost(immolate_damage_school);
			if(template.type ~= "SingleAttackWithPercent") then
				buffs_caster.damage_percent = boost;
			end
		end

		-- target damage school
		local damage_school = template.params.damage_school;
		-- damage school boost
		local boost = caster:GetDamageBoost(damage_school);
		local boost_absolute = caster:GetDamageBoost_absolute(damage_school);
		if(template.type ~= "SingleAttackWithPercent") then
			buffs_target.damage_percent = boost;
			buffs_absolute = buffs_absolute + boost_absolute;
		end
		
		-- pop caster blades and weaknesses
		caster:ProcessDamageAgainstCharms(buffs_caster, damage_school, buffs_target);

		local dot_threats;
		local dot_threats_splash;

		-- for single attack with dot, only charm part will be effective
		if(template.type == "SingleAttackWithDOT") then
			local dots_str = template.params.dots;
			local damage_school = template.params.damage_school;
			local damage_boost_absolute = caster:GetDamageBoost_absolute(damage_school);
			local dot_sequence = {
				icon_gsid = template.params.icon_gsid, -- could be nil
				damage_school = damage_school,
				buffs_target = commonlib.deepcopy(buffs_target),
				pips_realcost = pips_realcost,
				damage_boost_absolute = damage_boost_absolute,
				spell_penetration = caster:GetSpellPenetration(damage_school),
				outputdamage_finalweight = caster:GetOutputDamageFinalWeight(),
				caster_id = caster_data.id,
			};
			local dots_damage_school = {};
			local dots_school_str = template.params.dots_damage_school;
			local isDotDamageSchoolDifferent = false;
			if(dots_school_str) then
				isDotDamageSchoolDifferent = true;
				local dot_damage_school;
				for dot_damage_school in string.gmatch(dots_school_str, "([^,]+)") do
					table.insert(dots_damage_school,dot_damage_school);
				end
			end

			dot_threats = {}; --  clear dot threats
			dot_threats_splash = {}; --  clear dot splash threats
			local dot_round = 1;
			local dmg;
			for dmg in string.gmatch(dots_str, "([^,]+)") do
				--local dot_damage_school, renmainPart = string.match(dots_damage_school,"([^,]+)(.*)");
				--dots_damage_school = renmainPart;
				if(isDotDamageSchoolDifferent) then
					damage_school = dots_damage_school[dot_round];
					damage_boost_absolute = caster:GetDamageBoost_absolute(damage_school);
					spell_penetration = caster:GetSpellPenetration(damage_school);
				end
				dmg = tonumber(dmg);
				local bCritical = false;
				if(TryCriticalStrike_DOT(caster, target, damage_school)) then
					dmg = math_ceil(dmg * GetCriticalStrikeDamageRatio(caster));
					bCritical = true;
				end
				-- append to dot sequence queue
				table_insert(dot_sequence, {dmg = dmg, bCritical = bCritical, damage_school = damage_school, damage_boost_absolute = damage_boost_absolute, spell_penetration = spell_penetration});
				-- calculate dot damage
				local _, boost;
				for _, boost in ipairs(buffs_target) do
					dmg = math_ceil(dmg * (100 + boost) / 100);
				end
				local base_threat = GetDamageThreat(dmg, caster:GetPhase());
				table_insert(dot_threats, base_threat);
				table_insert(dot_threats_splash, math.ceil(base_threat * splash_damage_threat_ratio));
				dot_round = dot_round + 1;
			end
			-- append dot sequence
			target:AppendDoT(dot_sequence);
			last_target_overtimes = "0,"..last_target_overtimes;
		elseif(template.type == "SingleAttackWithStandingWards" or template.type == "SingleAttackWithLifeTapAndStandingWards") then
			-- append standing wards
			--------------------------------------------------------------------------
			---- NOTE: pay attention to the standing ward pop out before append
			---- first pop standing ward if exist
			--target:PopStandingWardIfExist(tonumber(ward));
			--------------------------------------------------------------------------
			local ward;
			for ward in string.gmatch(template.params.wards, "([^,]+)") do
				local rounds = template.params.rounds;
				if(arena.mode == "pve") then -- pve arena
					rounds = rounds + 1;
				end
				target:AppendStandingWard(tonumber(ward), rounds);
				last_target_wards = "0,"..last_target_wards;
			end
		end

		if(template.params.bCharging == true or template.params.bCharging == "true") then
			-- pop standing wards if exist
			local charging_wards = storm_charging_wards;
			local highest_level;
			local i = 1;
			for i = 1, #charging_wards do
				local bExist = target:PopStandingWardIfExist(charging_wards[i]);
				if(bExist) then
					highest_level = i;
				end
			end
			local this_ward = charging_wards[1];
			if(highest_level) then
				this_ward = charging_wards[highest_level + 1] or charging_wards[#charging_wards];
			end
			-- reset the charging ward to 1 round
			if(this_ward) then
				local rounds = 1;
				if(arena.mode == "pve") then -- pve arena
					rounds = 2;
				end
				if(arena.mode == "free_pvp") then -- pvp arena
					rounds = 2;
				end
				target:AppendStandingWard(this_ward, rounds);
				last_target_wards = "0,"..last_target_wards;
			end
		end
		
		if(template.type == "SingleAttackWithStun") then
			-- check if target immune to stun
			if(not target:IsImmuneToStun()) then
				-- if stun is absorbed
				local absorbed = false;
				-- pop target stun absorb if exist
				local id, ward;
				for id, ward in pairs(wards) do
					if(ward.stunabsorb == "true" or ward.stunabsorb == true) then
						if(target:PopWard(id)) then
							absorbed = true;
							break;
						end
					end
				end
				if(absorbed == false) then
					-- stun each target
					target.bStunned = true;
					if(not template.params.do_not_generate_absorb) then
						-- append four stun absorb in case of chain absorb
						target:AppendWard(stunabsorb_ward_id);
						target:AppendWard(stunabsorb_ward_id);
						if(System.options.version ~= "teen") then
							target:AppendWard(stunabsorb_ward_id);
							target:AppendWard(stunabsorb_ward_id);
						end
					end
					-- append threat
					if(target:IsMob()) then
						target:AppendThreat(caster, GetEffectThreat("stun"));
					end
				end
			end
		end
		
		-- pop avaliable caster shield and traps
		damage_school = target:ProcessDamageAgainstWards(buffs_target, damage_school);
		-- damage school boost
		local resist = target:GetResist(damage_school);
		local spell_penetration = caster:GetSpellPenetration(damage_school);
		local spell_penetration_receive = target:GetSpellPenetrationReceive(damage_school);
		-- added card spell penetration
		local base_spellpenetration = template.params.base_spellpenetration or 0;
		spell_penetration = spell_penetration + base_spellpenetration;
		local resist_absolute = target:GetResist_absolute(damage_school);
		if(template.type ~= "SingleAttackWithPercent") then
			-- skip target resist test on percental damage
			buffs_target.resist_percent = resist;
			buffs_target.spell_penetration = spell_penetration;
			buffs_target.spell_penetration_receive = spell_penetration_receive;
			buffs_absolute = buffs_absolute + resist_absolute;
		end
		
		-- check arena aura
		if(GlobalAura_boost_school == damage_school and GlobalAura_boost_damage) then
			table_insert(buffs_target, GlobalAura_boost_damage);
		end

		-- calculate all damage modifiers
		damage = damage_expression(damage, buffs_absolute, buffs_target);

		local dmg_mark;

		local base_spell_hitchance = template.hitchance or 100;

		local base_doubleattack = template.params.base_doubleattack or 0;
		local base_criticalstrike = template.params.base_criticalstrike or 0;
		if(System.options.version ~= "kids" or (System.options.version == "kids" and arena.mode ~= "free_pvp")) then
			if(TryDodge(caster, target, base_spell_hitchance, damage_school)) then
				damage = math_ceil(damage * dodge_damage_ratio);
				dmg_mark = "d"; -- for dodge, dodge will overwrite the critical mark	
			else
				if(TryDoubleAttack(caster, target, base_doubleattack, damage_school)) then
					damage = math_ceil(damage * 2);
					dmg_mark = "t"; -- for double attack
				else
					if(TryCriticalStrike(caster, target, base_criticalstrike, damage_school)) then
						damage = math_ceil(damage * GetCriticalStrikeDamageRatio(caster));
						if(template.params.extra_damage_if_critical) then
							local extra_damage = tonumber(template.params.extra_damage_if_critical);
							damage = damage*(1 + extra_damage);
						end
						dmg_mark = "c"; -- for critical
					end
				end
			end
		else
			if(target.remedy.absoluteDefense_protect_rounds <= 0 and TryDodge(caster, target, base_spell_hitchance, damage_school)) then
				dmg_mark = "d";
				damage = 1;
				target.remedy.absoluteDefense_protect_rounds = protect_rounds_for_remedy;
			else
				if(target.remedy.deadlyAttack_protect_rounds <= 0 and TryDoubleAttack(caster, target, base_doubleattack, damage_school)) then
					damage = math_ceil(damage * 2);
					dmg_mark = "t"; -- for double attack
					target.remedy.deadlyAttack_protect_rounds = protect_rounds_for_remedy;
				else
					if(TryCriticalStrike(caster, target, base_criticalstrike, damage_school)) then
						damage = math_ceil(damage * GetCriticalStrikeDamageRatio(caster));
						if(template.params.extra_damage_if_critical) then
							local extra_damage = tonumber(template.params.extra_damage_if_critical);
							damage = damage*(1 + extra_damage);
						end
						dmg_mark = "c"; -- for critical
					end
				end
			end
		end

		-- final output damage weight
		damage = math.ceil(damage * caster:GetOutputDamageFinalWeight());
		
		-- final receive damage weight AFTER max percent damage
		damage = math.ceil(damage * target:GetReceiveDamageFinalWeight(damage_school));

		-- max damage for SingleAttackWithPercent
		if(template.type == "SingleAttackWithPercent") then
			local this_damage_max = template.params.damage_max;
			if(target:IsMob()) then
				this_damage_max = template.params.damage_max_mob or this_damage_max;
			else
				this_damage_max = template.params.damage_max_player or this_damage_max;
			end
			if(damage >= this_damage_max) then
				damage = this_damage_max;
			end
		end
		
		-- append threat
		local _, unit;
		for _, unit in ipairs(hostiles) do
			if(unit.isMob) then
				local mob = Mob.GetMobByID(unit.id);
				if(mob and mob:IsAlive()) then
					local base_threat = GetDamageThreat(damage, caster:GetPhase());
					if((target:IsMob() == mob:IsMob()) and (target:GetID() == mob:GetID())) then
						mob:AppendThreat(caster, base_threat, dot_threats)
					else
						mob:AppendThreat(caster, math.ceil(base_threat * splash_damage_threat_ratio), dot_threats_splash);
					end
				end
			end
		end

		-- don't check absorb for life tap spells and damage with percent
		--if(template.type ~= "SingleAttackWithLifeTap" and template.type ~= "SingleAttackWithPercent") then
		if(template.type ~= "SingleAttackWithPercent") then
			-- check avaliable absorbs
			damage = AbsorbDamage(target, damage);
		end

		local bShieldBreak = false;
		local ReflectDamage = 0;

		local additional_reflection_shield_sequence = {};
		if(target.reflect_amount > 0 and damage > 0) then
			ReflectDamage = damage;
			-- calculate damage and reflect_amount
			if(damage >= target.reflect_amount) then
				-- break the shield
				damage = damage - target.reflect_amount;
				target.reflect_amount = 0;
				bShieldBreak = true;
			else
				-- absorb all damage
				target.reflect_amount = target.reflect_amount - damage;
				damage = 0;
			end
		end
		
		-- take damage
		--if(caster_data.id == 46650264) then
			--damage = math.random(9000, 15000);
		--end


		-- the card which name or key is "Balance_Rune_SingleAttackWithStun_Lv5" or "Balance_Rune_SingleAttackWithSelfStun_Lv5" can't kill target
		if(non_lethal_card_name[key]) then
			if(damage > target_cur_hp) then
				damage = target_cur_hp - 1;
			end
		end

		--local caster_cur_hp = caster:GetCurrentHP();
		--local target_cur_hp = target:GetCurrentHP();
		if(arena.is_battlefield and damage > target_cur_hp) then
			damage = target_cur_hp;
		end
		target:TakeDamage(damage);
		-- append pierce freeze round
		if(caster:GetStance() == "pierce") then
			target:AppendPierceFreezeRounds(3);
		end

		local additional_reflection_shield_sequence = {};
		if(ReflectDamage > 0) then
			local reflect_buffs = {};
			-- pop avaliable caster shield and traps
			local reflect_damage = ReflectDamage;
			local reflect_damage_school = caster:ProcessDamageAgainstWards(reflect_buffs, damage_school);
			-- damage school resist
			local resist = caster:GetResist(reflect_damage_school);
			local spell_penetration = caster:GetSpellPenetration(reflect_damage_school);
			local spell_penetration_receive = caster:GetSpellPenetrationReceive(reflect_damage_school);
			local damageboost_absolute = caster:GetDamageBoost_absolute(reflect_damage_school);
			local resist_absolute = caster:GetResist_absolute(reflect_damage_school);
			reflect_buffs.resist_percent = resist;
			reflect_buffs.spell_penetration = spell_penetration;
			reflect_buffs.spell_penetration_receive = spell_penetration_receive;
			-- check arena aura
			if(GlobalAura_boost_school == reflect_damage_school and GlobalAura_boost_damage) then
				table_insert(reflect_buffs, GlobalAura_boost_damage);
			end
			-- calculate reflect damage
			-- NOTE 2012/1/24: cancel damageboost_absolute + resist_absolute for reflect damage
			reflect_damage = damage_expression(reflect_damage, 0, reflect_buffs);

			-- final output and receive damage weight
			reflect_damage = math.ceil(reflect_damage * caster:GetOutputDamageFinalWeight());
			reflect_damage = math.ceil(reflect_damage * caster:GetReceiveDamageFinalWeight(reflect_damage_school));

			-- check avaliable absorbs
			reflect_damage = AbsorbDamage(caster, reflect_damage);
			-- test reflect damage
			local caster_current_hp = caster:GetCurrentHP();
			if(reflect_damage >= MAX_REFLECT_DAMAGE) then
				-- max reflect damage
				reflect_damage = MAX_REFLECT_DAMAGE;
			end
			if(reflect_damage >= caster_current_hp) then
				-- reflect damage is not deathful
				reflect_damage = caster_current_hp - 1;
			end
			-- take damage
			caster:TakeDamage(reflect_damage);
			-- skip freeze test, because caster can't attack while freezed
			-- append reflection spell play
			local spell_str = "";
			local damage_school = template.params.damage_school;
			local arrow_position = caster:GetArrowPosition_id();
			spell_str = format("%s:%s,%d,%d,%s,%s,%d,%s,%s,%d,%d,%d#%s#%s#%s#%s#%s#%s#%s#%s", 
						"Ice_ReflectionShield_reflection", "Ice_ReflectionShield_reflection", arena:GetID(), arrow_position, 
						tostring(target_data.isMob), target_data.id, target:GetArrowPosition_id(), 
						tostring(caster_data.isMob), caster_data.id, caster:GetArrowPosition_id(), 
						reflect_damage, 0, 
						target:GetCharmsValue(), target:GetCharmsValue(), 
						caster:GetCharmsValue(), caster:GetCharmsValue(), 
						caster:GetWardsValue(), caster:GetWardsValue(), 
						caster:GetOverTimeValue(), caster:GetOverTimeValue());
			table_insert(additional_reflection_shield_sequence, spell_str);
			sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Ice_ReflectionShield_reflection");
			-- mark battlefield attack points
			TryMarkBattleFieldAttack(arena, caster, reflect_damage, sequence.duration, target);
			-- append dead play if caster is dead
			if(not caster:IsAlive()) then
				-- try speak dead word
				TrySpeakDeadWord(caster, arena:GetID(), additional_reflection_shield_sequence);
				local spell_str = "";
				spell_str = format("dead:%d,%d,%s,%s", arena:GetID(), arrow_position, tostring(caster_data.isMob), caster_data.id);
				table_insert(additional_reflection_shield_sequence, spell_str);
				sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Dead");
				-- mark battlefield death
				TryMarkBattleFieldDeath(arena, caster, sequence.duration);
				-- update arena
				local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
				spell_str = format("update_arena:%s+%s", key, value);
				table_insert(additional_reflection_shield_sequence, spell_str);
				-- update value
				local value = caster:GetValue_normal_update();
				spell_str = format("update_value:%s", value);
				table_insert(additional_reflection_shield_sequence, spell_str);
				return false;
			end
			-- update arena
			local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
			spell_str = format("update_arena:%s+%s", key, value);
			table_insert(additional_reflection_shield_sequence, spell_str);
			-- update value
			local value = caster:GetValue_normal_update();
			spell_str = format("update_value:%s", value);
			table_insert(additional_reflection_shield_sequence, spell_str);
			-- calculate damage and reflect_amount
			if(bShieldBreak) then
				-- play break shield spell
				local arrow_position = caster:GetArrowPosition_id();
				spell_str = format("%s:%s,%d,%d,%s,%s,%d,%s,%s,%d,%d,%d#%s#%s#%s#%s#%s#%s#%s#%s", 
							"Ice_ReflectionShield_shieldbreak", "Ice_ReflectionShield_shieldbreak", arena:GetID(), arrow_position, 
							tostring(target_data.isMob), target_data.id, target:GetArrowPosition_id(), 
							tostring(caster_data.isMob), caster_data.id, caster:GetArrowPosition_id(), 
							0, 0, 
							target:GetCharmsValue(), target:GetCharmsValue(), 
							caster:GetCharmsValue(), caster:GetCharmsValue(), 
							caster:GetWardsValue(), caster:GetWardsValue(), 
							caster:GetOverTimeValue(), caster:GetOverTimeValue());
				table_insert(additional_reflection_shield_sequence, spell_str);
				sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Ice_ReflectionShield_shieldbreak");
			end
		end

		-- break freeze status if so
		if(target.freeze_rounds > 0) then
			target.freeze_rounds = 0;
			---- additional update to remove the ice block
			--local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
			--spell_str = format("update_arena:%s+%s", key, value);
			--table_insert(sequence, spell_str);
			---- play the break freeze spell
			--local arrow_position = target:GetArrowPosition_id();
			--spell_str = format("%s:%s,%d,%d,%s,%d,%d,%s,%d,%d,%d,%d#%s#%s#%s#%s#%s#%s#%s#%s", 
						--"Ice_SingleFreeze_Break", "Ice_SingleFreeze_Break", arena:GetID(), arrow_position, 
						--tostring(target_data.isMob), target_data.id, target:GetArrowPosition_id(), 
						--tostring(target_data.isMob), target_data.id, target:GetArrowPosition_id(), 
						--0, 0, 
						--target:GetCharmsValue(), target:GetCharmsValue(), 
						--target:GetCharmsValue(), target:GetCharmsValue(), 
						--target:GetWardsValue(), target:GetWardsValue(), 
						--target:GetOverTimeValue(), target:GetOverTimeValue());
			--table_insert(sequence, spell_str);
			--sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Ice_SingleFreeze_Break");
		end

		-- secondary damage or heal
		local secondary_param = 0;
		
		local immulate_unit;
		local immulate_damage_pts;
		
		if(template.type == "SingleAttackWithLifeTap" or template.type == "SingleAttackWithLifeTapAndStandingWards") then
			-- convert the damage to life
			local convert_rate = template.params.convert_rate or 0;
			local life_converted = math.ceil(damage * convert_rate / 100);
			-- arena heal penalty
			life_converted = process_heal_penalty(arena, life_converted);

			--local caster_lost_hp = caster:GetMaxHP() - caster_cur_hp;
			--local target_lost_hp = target:GetMaxHP() - target_cur_hp;
			if(arena.is_battlefield and life_converted > caster_lost_hp) then
				life_converted = caster_lost_hp;
			end

			caster:TakeHeal(life_converted);
			secondary_param = life_converted;
		elseif(template.type == "SingleAttackWithImmolate" or template.type == "SingleAttackWithPercent") then
		
			local immolate_damage_school = template.params.immolate_damage_school;
			-- pop avaliable caster shield and traps
			immolate_damage_school = caster:ProcessDamageAgainstWards(buffs_caster, immolate_damage_school);
			-- damage school boost
			local resist = caster:GetResist(immolate_damage_school);
			local spell_penetration = caster:GetSpellPenetration(immolate_damage_school);
			local spell_penetration_receive = caster:GetSpellPenetrationReceive(immolate_damage_school);
			local immolate_buffs_absolute = 0;
			local boost_absolute = caster:GetDamageBoost_absolute(immolate_damage_school);
			local resist_absolute = caster:GetResist_absolute(immolate_damage_school);
			if(template.type ~= "SingleAttackWithPercent") then
				buffs_caster.resist_percent = resist;
				buffs_caster.spell_penetration = spell_penetration;
				buffs_caster.spell_penetration_receive = spell_penetration_receive;
				immolate_buffs_absolute = immolate_buffs_absolute + boost_absolute + resist_absolute;
			end
		
			-- calculate other damage modifiers
			local immolate_damage_min = template.params.immolate_damage_min;
			local immolate_damage_max = template.params.immolate_damage_max;
			if(template.type == "SingleAttackWithPercent") then
				local immolate_damage_percent = template.params.immolate_damage_percent
				immolate_damage_min = math.ceil(caster:GetCurrentHP() * immolate_damage_percent / 100);
				immolate_damage_max = math.ceil(caster:GetCurrentHP() * immolate_damage_percent / 100);
			end
			local immolate_base_damage = math.random(immolate_damage_min, immolate_damage_max);
			local damage_caster = immolate_base_damage;
			
			-- check arena aura
			if(GlobalAura_boost_school == immolate_damage_school and GlobalAura_boost_damage) then
				table_insert(buffs_caster, GlobalAura_boost_damage);
			end

			-- calculate immulate damage
			damage_caster = damage_expression(damage_caster, immolate_buffs_absolute, buffs_caster);
			
			-- final output and receive damage weight
			damage_caster = math.ceil(damage_caster * caster:GetOutputDamageFinalWeight());
			damage_caster = math.ceil(damage_caster * caster:GetReceiveDamageFinalWeight(immolate_damage_school));

			-- max damage for SingleAttackWithPercent
			if(template.type == "SingleAttackWithPercent") then
				local this_damage_max = template.params.damage_max;
				if(caster:IsMob()) then
					this_damage_max = template.params.damage_max_mob or this_damage_max;
				else
					this_damage_max = template.params.damage_max_player or this_damage_max;
				end
				if(damage_caster >= this_damage_max) then
					damage_caster = this_damage_max;
				end
			else
				-- check avaliable absorbs
				damage_caster = AbsorbDamage(caster, damage_caster);
			end
			
			--local caster_cur_hp = caster:GetCurrentHP();
			--local target_cur_hp = target:GetCurrentHP();
			if(arena.is_battlefield and damage_caster > caster_cur_hp) then
				damage_caster = caster_cur_hp;
			end

			-- take damage
			caster:TakeDamage(damage_caster);

			-- record battlefield unit and attack points
			immulate_unit = caster;
			immulate_damage_pts = damage_caster;

			-- skip freeze test, because caster can't attack while freezed
			secondary_param = damage_caster;
		end

		if(template.type == "SingleAttackWithSelfStun") then
			caster.bStunned = true;
		end

		if(template.type == "SingleAttackWithTrap") then
			target:AppendWard(tonumber(template.params.target_wards));
			last_target_wards = "0,"..last_target_wards;
		end
		
		-- get arrow position
		local arrow_position = caster:GetArrowPosition_id();
		
		-- append spell play
		local spell_str = "";
		spell_str = format("%s:%s,%d,%d,%s,%s,%d,%s,%s,%d,%s,%d#%s#%s#%s#%s#%s#%s#%s#%s", spell_name, key, arena:GetID(), arrow_position, 
					tostring(caster_data.isMob), caster_data.id, caster:GetArrowPosition_id(), 
					tostring(target_data.isMob), target_data.id, target:GetArrowPosition_id(), 
					(dmg_mark or "")..damage, secondary_param, 
					last_caster_charms, caster:GetCharmsValue(), 
					target:GetCharmsValue(), target:GetCharmsValue(), 
					last_target_wards, target:GetWardsValue(), 
					last_target_overtimes, target:GetOverTimeValue());
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname(spell_name);
		if(template.type == "SingleAttackWithLifeTap" or template.type == "SingleAttackWithLifeTapAndStandingWards") then
			-- take heal battle field mark
			TryMarkBattleFieldHeal(arena, caster, secondary_param, sequence.duration, caster, key);
		end
		-- mark battlefield attack points
		TryMarkBattleFieldAttack(arena, target, damage, sequence.duration, caster, key);
		if(immulate_unit and immulate_damage_pts) then
			-- mark battlefield attack points
			TryMarkBattleFieldAttack(arena, immulate_unit, immulate_damage_pts, sequence.duration);
		end
		
		-- append dead play if caster is dead
		if(not caster:IsAlive()) then
			-- try speak dead word
			TrySpeakDeadWord(caster, arena:GetID(), sequence);
			local spell_str = "";
			spell_str = format("dead:%d,%d,%s,%s", arena:GetID(), caster:GetArrowPosition_id(), tostring(caster_data.isMob), caster_data.id);
			table_insert(sequence, spell_str);
			sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Dead");
			-- mark battlefield death
			TryMarkBattleFieldDeath(arena, caster, sequence.duration);
		end
		-- append dead play if target is dead
		if(not target:IsAlive()) then
			-- try speak dead word
			TrySpeakDeadWord(target, arena:GetID(), sequence);
			local spell_str = "";
			spell_str = format("dead:%d,%d,%s,%s", arena:GetID(), target:GetArrowPosition_id(), tostring(target_data.isMob), target_data.id);
			table_insert(sequence, spell_str);
			sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Dead");
			-- mark battlefield death
			TryMarkBattleFieldDeath(arena, target, sequence.duration);
		end
		-- update arena
		local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
		spell_str = format("update_arena:%s+%s", key, value);
		table_insert(sequence, spell_str);
		-- update value
		local value = target:GetValue_normal_update();
		spell_str = format("update_value:%s", value);
		table_insert(sequence, spell_str);

		-- append additional reflection shield sequence
		local _, spell_line;
		for _, spell_line in ipairs(additional_reflection_shield_sequence) do
			table_insert(sequence, spell_line);
		end

	elseif(template.type == "SingleAttackHP") then
		-- base damage
		local damage_min = Card.GetNumericalValueFromSection(template.params.damage_min, pips_realcost) or 0;
		local damage_max = Card.GetNumericalValueFromSection(template.params.damage_max, pips_realcost) or 0;
		local base_damage = math.random(damage_min, damage_max);
		
		local damage = base_damage;
		
		-- calculate all damage modifiers
		--damage = damage_expression(damage, 0, {});

		--local caster_cur_hp = caster:GetCurrentHP();
		--local target_cur_hp = target:GetCurrentHP();
		if(arena.is_battlefield and damage > target_cur_hp) then
			damage = target_cur_hp;
		end

		target:TakeDamage(damage);

		-- get arrow position
		local arrow_position = caster:GetArrowPosition_id();
		
		-- append spell play
		local spell_str = "";
		spell_str = format("%s:%s,%d,%d,%s,%s,%d,%s,%s,%d,%s,%d#%s#%s#%s#%s#%s#%s#%s#%s", spell_name, key, arena:GetID(), arrow_position, 
					tostring(caster_data.isMob), caster_data.id, caster:GetArrowPosition_id(), 
					tostring(target_data.isMob), target_data.id, target:GetArrowPosition_id(), 
					""..damage, 0, 
					caster:GetCharmsValue(), caster:GetCharmsValue(), 
					target:GetCharmsValue(), target:GetCharmsValue(), 
					target:GetWardsValue(), target:GetWardsValue(), 
					target:GetOverTimeValue(), target:GetOverTimeValue());
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname(spell_name);

		-- append dead play if target is dead
		if(not target:IsAlive()) then
			-- try speak dead word
			TrySpeakDeadWord(target, arena:GetID(), sequence);
			local spell_str = "";
			spell_str = format("dead:%d,%d,%s,%d", arena:GetID(), target:GetArrowPosition_id(), tostring(target_data.isMob), target_data.id);
			table_insert(sequence, spell_str);
			sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Dead");
			-- mark battlefield death
			TryMarkBattleFieldDeath(arena, target, sequence.duration);
		end
		-- update arena
		local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
		spell_str = format("update_arena:%s+%s", key, value);
		table_insert(sequence, spell_str);
		-- update value
		local value = target:GetValue_normal_update();
		spell_str = format("update_value:%s", value);
		table_insert(sequence, spell_str);

	elseif(template.type == "SingleHeal" or template.type == "SingleHealWithHOT" or template.type == "SingleHealWithImmolate" or template.type == "SingleHealWithCleanse") then
		-- base damage
		local heal_min = Card.GetNumericalValueFromSection(template.params.heal_min, pips_realcost) or 0;
		local heal_max = Card.GetNumericalValueFromSection(template.params.heal_max, pips_realcost) or 0;
		local base_heal = math.random(heal_min, heal_max);
		
		local heal = base_heal;
		
		-- record all the buff and debuffs
		local buffs = {};
		
		local last_caster_charms = caster:GetCharmsValue();
		local last_target_wards = target:GetWardsValue();
		local last_target_overtimes = target:GetOverTimeValue();
		
		-- pop caster blades and weaknesses
		caster:ProcessHealAgainstCharms(buffs);

		-- output heal boost
		local output_heal_boost = caster:GetOutputHealBoost();
		table_insert(buffs, output_heal_boost);
		
		-- secondary damage or heal
		local secondary_param = 0;
		
		local hot_threats;

		local immulate_unit;
		local immulate_damage_pts;

		-- for single heal with hot, only charm part will be effective
		if(template.type == "SingleHealWithHOT") then
			
			local hots_str = template.params.hots;
			local hot_sequence = {
				icon_gsid = template.params.icon_gsid, -- could be nil
				caster_id = caster_data.id,
			};
			hot_threats = {}; --  clear dot threats
			local heal;
			for heal in string.gmatch(hots_str, "([^,]+)") do
				heal = tonumber(heal);
				
				-- calculate hot heal
				heal = heal_expression(heal, buffs);
				-- output heal final weight
				heal = math.ceil(heal * caster:GetOutputHealFinalWeight());
				-- append to hot sequence queue
				table_insert(hot_sequence, heal);
				table_insert(hot_threats, GetHealThreat(heal, caster:GetPhase()));
			end
				
			-- append hot sequence
			target:AppendHoT(hot_sequence);
			last_target_overtimes = "0,"..last_target_overtimes;
		elseif(template.type == "SingleHealWithImmolate") then
			
			-- target damage school
			local buffs_caster = {};
			local immolate_damage_school = template.params.immolate_damage_school;
			-- damage school boost
			local boost = caster:GetDamageBoost(immolate_damage_school);
			buffs_caster.damage_percent = boost;
		
			-- pop caster blades and weaknesses
			caster:ProcessDamageAgainstCharms(buffs_caster, immolate_damage_school);

			-- pop avaliable caster shield and traps
			immolate_damage_school = caster:ProcessDamageAgainstWards(buffs_caster, immolate_damage_school);
			-- damage school boost
			local resist = caster:GetResist(immolate_damage_school);
			local spell_penetration = caster:GetSpellPenetration(immolate_damage_school);
			local spell_penetration_receive = caster:GetSpellPenetrationReceive(immolate_damage_school);
			buffs_caster.resist_percent = resist;
			buffs_caster.spell_penetration = spell_penetration;
			buffs_caster.spell_penetration_receive = spell_penetration_receive;
			
			local immolate_buffs_absolute = 0;
			local boost_absolute = caster:GetDamageBoost_absolute(immolate_damage_school);
			local resist_absolute = caster:GetResist_absolute(immolate_damage_school);
			immolate_buffs_absolute = immolate_buffs_absolute + boost_absolute + resist_absolute;
		
			-- calculate other damage modifiers
			local immolate_damage_min = template.params.immolate_damage_min;
			local immolate_damage_max = template.params.immolate_damage_max;
			local immolate_base_damage = math.random(immolate_damage_min, immolate_damage_max);
			local damage_caster = immolate_base_damage;
			
			-- check arena aura
			if(GlobalAura_boost_school == immolate_damage_school and GlobalAura_boost_damage) then
				table_insert(buffs_caster, GlobalAura_boost_damage);
			end
			
			-- calculate immulate damage
			damage_caster = damage_expression(damage_caster, immolate_buffs_absolute, buffs_caster);

			-- final output and receive damage weight
			damage_caster = math.ceil(damage_caster * caster:GetOutputDamageFinalWeight());
			damage_caster = math.ceil(damage_caster * caster:GetReceiveDamageFinalWeight(immolate_damage_school));

			-- check avaliable absorbs
			damage_caster = AbsorbDamage(caster, damage_caster);
			
			--local caster_cur_hp = caster:GetCurrentHP();
			--local target_cur_hp = target:GetCurrentHP();
			if(arena.is_battlefield and damage_caster > caster_cur_hp) then
				damage_caster = caster_cur_hp;
			end

			-- take damage
			caster:TakeDamage(damage_caster);
			
			-- record battlefield unit and attack points
			immulate_unit = caster
			immulate_damage_pts = damage_caster;

			-- skip freeze test, because caster can't heal while freezed
			secondary_param = damage_caster;
		end

		-- pop target shields and traps
		local id, ward;
		for id, ward in pairs(wards) do
			if(ward.boost_heal) then
				if(target:PopWard(id)) then
					table_insert(buffs, ward.boost_heal);
					--last_target_wards = "0,"..last_target_wards;
				end
			end
		end
		
		-- check arena aura
		if(GlobalAura_boost_heal) then
			table_insert(buffs, GlobalAura_boost_heal);
		end
		
		-- input heal boost
		local input_heal_boost = target:GetInputHealBoost();
		table_insert(buffs, input_heal_boost);

		-- calculate other damage modifiers
		heal = heal_expression(heal, buffs);

		-- append threat
		local _, unit;
		for _, unit in ipairs(hostiles) do
			if(unit.isMob) then
				local mob = Mob.GetMobByID(unit.id);
				if(mob and mob:IsAlive()) then
					local base_threat = GetHealThreat(heal, caster:GetPhase());
					mob:AppendThreat(caster, base_threat, hot_threats);
				end
			end
		end
		
		-- arena heal penalty
		heal = process_heal_penalty(arena, heal);
		
		-- output heal final weight
		heal = math.ceil(heal * caster:GetOutputHealFinalWeight());

		--local caster_lost_hp = caster:GetMaxHP() - caster_cur_hp;
		--local target_lost_hp = target:GetMaxHP() - target_cur_hp;
		if(arena.is_battlefield and heal > target_lost_hp) then
			heal = target_lost_hp;
		end

		-- take heal
		target:TakeHeal(heal);

		if(template.type == "SingleHealWithCleanse") then
			-- pop all negative effects: charms, wards, dots etc.
			target:PopAllNegativeEffects();
		end
		
		-- get arrow position
		local arrow_position = caster:GetArrowPosition_id();
		
		-- append spell play
		local spell_str = "";
		spell_str = format("%s:%s,%d,%d,%s,%s,%d,%s,%s,%d,%d,%d#%s#%s#%s#%s#%s#%s#%s#%s", spell_name, key, arena:GetID(), arrow_position, 
					tostring(caster_data.isMob), caster_data.id, caster:GetArrowPosition_id(), 
					tostring(target_data.isMob), target_data.id, target:GetArrowPosition_id(), 
					heal, secondary_param, 
					last_caster_charms, caster:GetCharmsValue(), 
					target:GetCharmsValue(), target:GetCharmsValue(), 
					last_target_wards, target:GetWardsValue(), 
					last_target_overtimes, target:GetOverTimeValue());
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname(spell_name);
		-- take heal battle field mark
		TryMarkBattleFieldHeal(arena, target, heal, sequence.duration, caster, key);
		if(immulate_unit and immulate_damage_pts) then
			-- mark battlefield attack points
			TryMarkBattleFieldAttack(arena, immulate_unit, immulate_damage_pts, sequence.duration);
		end
		-- update arena
		local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
		spell_str = format("update_arena:%s+%s", key, value);
		table_insert(sequence, spell_str);
		-- update value
		local value = target:GetValue_normal_update();
		spell_str = format("update_value:%s", value);
		table_insert(sequence, spell_str);
		
	elseif(template.type == "SingleGuardianWithImmolate") then
		
		-- record all the buff and debuffs
		local buffs = {};
		
		local last_caster_charms = caster:GetCharmsValue();
		local last_target_wards = target:GetWardsValue();
		local last_target_overtimes = target:GetOverTimeValue();
		
		local hot_threats;

		local immulate_unit;
		local immulate_damage_pts;

		-- target damage school
		local buffs_caster = {};
		local immolate_damage_school = template.params.immolate_damage_school;
		-- damage school boost
		local boost = 0; -- caster:GetDamageBoost(immolate_damage_school);
		buffs_caster.damage_percent = 0; --boost;
		
		-- pop caster blades and weaknesses
		caster:ProcessDamageAgainstCharms(buffs_caster, immolate_damage_school);

		-- pop avaliable caster shield and traps
		immolate_damage_school = caster:ProcessDamageAgainstWards(buffs_caster, immolate_damage_school);
		-- damage school boost
		local resist = 0; -- caster:GetResist(immolate_damage_school);
		buffs_caster.resist_percent = 0; -- resist;
		buffs_caster.spell_penetration = 0;
		buffs_caster.spell_penetration_receive = 0;
		
		local immolate_buffs_absolute = 0;
		local boost_absolute = caster:GetDamageBoost_absolute(immolate_damage_school);
		local resist_absolute = caster:GetResist_absolute(immolate_damage_school);
		immolate_buffs_absolute = immolate_buffs_absolute + boost_absolute + resist_absolute;
		
		-- calculate other damage modifiers
		local immolate_damage_min = template.params.immolate_damage_min;
		local immolate_damage_max = template.params.immolate_damage_max;
		local immolate_base_damage = math.random(immolate_damage_min, immolate_damage_max);
		local damage_caster = immolate_base_damage;
			
		-- check arena aura
		if(GlobalAura_boost_school == immolate_damage_school and GlobalAura_boost_damage) then
			table_insert(buffs_caster, GlobalAura_boost_damage);
		end
			
		-- calculate damage
		damage_caster = damage_expression(damage_caster, immolate_buffs_absolute, buffs_caster);

		-- final output and receive damage weight
		damage_caster = math.ceil(damage_caster * caster:GetOutputDamageFinalWeight());
		damage_caster = math.ceil(damage_caster * caster:GetReceiveDamageFinalWeight(immolate_damage_school));

		-- check avaliable absorbs
		damage_caster = AbsorbDamage(caster, damage_caster);
			
		--local caster_cur_hp = caster:GetCurrentHP();
		--local target_cur_hp = target:GetCurrentHP();
		if(arena.is_battlefield and damage_caster > caster_cur_hp) then
			damage_caster = caster_cur_hp;
		end
		-- take damage
		caster:TakeDamage(damage_caster);
			
		-- record battlefield unit and attack points
		immulate_unit = caster;
		immulate_damage_pts = damage_caster;

		-- append threat
		local _, unit;
		for _, unit in ipairs(hostiles) do
			if(unit.isMob) then
				local mob = Mob.GetMobByID(unit.id);
				if(mob and mob:IsAlive()) then
					mob:AppendThreat(caster, GetEffectThreat("areaward"));
				end
			end
		end

		-- target with guardian
		target.bWithGuardian = true;
		
		-- get arrow position
		local arrow_position = caster:GetArrowPosition_id();
		
		-- append spell play
		local spell_str = "";
		spell_str = format("%s:%s,%d,%d,%s,%s,%d,%s,%s,%d,%d,%d#%s#%s#%s#%s#%s#%s#%s#%s", spell_name, key, arena:GetID(), arrow_position, 
					tostring(caster_data.isMob), caster_data.id, caster:GetArrowPosition_id(), 
					tostring(target_data.isMob), target_data.id, target:GetArrowPosition_id(), 
					immulate_damage_pts, 0, 
					last_caster_charms, caster:GetCharmsValue(), 
					target:GetCharmsValue(), target:GetCharmsValue(), 
					last_target_wards, target:GetWardsValue(), 
					last_target_overtimes, target:GetOverTimeValue());
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname(spell_name);
		if(immulate_unit and immulate_damage_pts) then
			-- mark battlefield attack points
			TryMarkBattleFieldAttack(arena, immulate_unit, immulate_damage_pts, sequence.duration);
		end
		
		-- append dead play if caster is dead
		if(not caster:IsAlive()) then
			-- try speak dead word
			TrySpeakDeadWord(caster, arena:GetID(), sequence);
			local spell_str = "";
			spell_str = format("dead:%d,%d,%s,%d", arena:GetID(), caster:GetArrowPosition_id(), tostring(caster_data.isMob), caster_data.id);
			table_insert(sequence, spell_str);
			sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Dead");
			-- mark battlefield death
			TryMarkBattleFieldDeath(arena, caster, sequence.duration);
		end

		-- update arena
		local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
		spell_str = format("update_arena:%s+%s", key, value);
		table_insert(sequence, spell_str);
		-- update value
		local value = target:GetValue_normal_update();
		spell_str = format("update_value:%s", value);
		table_insert(sequence, spell_str);

	elseif(template.type == "DOTAttack" or template.type == "DOTAttackWithHOT") then
		-- record all the buff and debuffs
		local buffs_caster_heal = {};
		local buffs_target_damage = {};

		-- record last value of the caster and target
		local last_caster_charms = caster:GetCharmsValue();
		local last_caster_wards = caster:GetWardsValue();
		local last_caster_overtimes = target:GetOverTimeValue();
		local last_target_wards = target:GetWardsValue();
		local last_target_overtimes = target:GetOverTimeValue();
		
		-- target damage school
		local damage_school = template.params.damage_school;
		-- damage school boost
		local boost = caster:GetDamageBoost(damage_school);
		buffs_target_damage.damage_percent = boost;
		--local resist = target:GetResist(damage_school);
		--table_insert(buffs_target_damage, resist);
		
		-- pop caster blades and weaknesses
		caster:ProcessDamageAgainstCharms(buffs_target_damage, damage_school);
		
		local dots_str = template.params.dots;
		local damage_school = template.params.damage_school;
		local damage_boost_absolute = caster:GetDamageBoost_absolute(damage_school);
		local dot_sequence = {
			icon_gsid = template.params.icon_gsid, -- could be nil
			damage_school = damage_school,
			buffs_target = commonlib.deepcopy(buffs_target_damage),
			pips_realcost = pips_realcost,
			damage_boost_absolute = damage_boost_absolute,
			spell_penetration = caster:GetSpellPenetration(damage_school),
			outputdamage_finalweight = caster:GetOutputDamageFinalWeight(),
			caster_id = caster_data.id,
		};

		local dots_damage_school = {};
		local dots_school_str = template.params.dots_damage_school;
		local isDotDamageSchoolDifferent = false;
		if(dots_school_str) then
			isDotDamageSchoolDifferent = true;
			local dot_damage_school;
			for dot_damage_school in string.gmatch(dots_school_str, "([^,]+)") do
				table.insert(dots_damage_school,dot_damage_school);
			end
		end

		local dot_round = 1;
		local dmg;
		local dot_threats = {};
		local dot_threats_splash = {};
		for dmg in string.gmatch(dots_str, "([^,]+)") do
			if(isDotDamageSchoolDifferent) then
				damage_school = dots_damage_school[dot_round];
				damage_boost_absolute = caster:GetDamageBoost_absolute(damage_school);
				spell_penetration = caster:GetSpellPenetration(damage_school);
			end
			-- damage
			dmg = Card.GetNumericalValueFromSection(dmg, pips_realcost) or 0;
			local bCritical = false;
			if(TryCriticalStrike_DOT(caster, target, damage_school)) then
				dmg = math_ceil(dmg * GetCriticalStrikeDamageRatio(caster));
				bCritical = true;
			end
			-- append to dot sequence queue
			table_insert(dot_sequence, {dmg = dmg, bCritical = bCritical, damage_school = damage_school, damage_boost_absolute = damage_boost_absolute, spell_penetration = spell_penetration});

			-- NOTE: if dot damage is negative, means splash damage
			
			-- calculate dot damage
			local _, boost;
			for _, boost in ipairs(buffs_target_damage) do
				dmg = math_ceil(dmg * (100 + boost) / 100);
			end

			local base_threat = GetDamageThreat(math.abs(dmg), caster:GetPhase());
			table_insert(dot_threats, base_threat);
			table_insert(dot_threats_splash, math.ceil(base_threat * splash_damage_threat_ratio));
			dot_round = dot_round + 1;
		end
				
		-- append dot sequence
		target:AppendDoT(dot_sequence);
		last_target_overtimes = "0,"..last_target_overtimes;

		-- append threat
		local _, unit;
		for _, unit in ipairs(hostiles) do
			if(unit.isMob) then
				local mob = Mob.GetMobByID(unit.id);
				if(mob and mob:IsAlive()) then
					if((target:IsMob() == mob:IsMob()) and (target:GetID() == mob:GetID())) then
						mob:AppendThreat(caster, 0, dot_threats)
					else
						mob:AppendThreat(caster, 0, dot_threats_splash);
					end
				end
			end
		end

		if(template.type == "DOTAttackWithHOT") then
			-- pop caster heal blades and weaknesses
			caster:ProcessHealAgainstCharms(buffs_caster_heal);
			-- hot
			local hots_str = template.params.hots;
			local hot_sequence = {
				icon_gsid = template.params.icon_gsid, -- could be nil
				caster_id = caster_data.id,
			};
			local hot_threats = {};
			local heal;
			for heal in string.gmatch(hots_str, "([^,]+)") do
				heal = tonumber(heal);
				-- calculate hot heal
				heal = heal_expression(heal, buffs_caster_heal);
				-- output heal final weight
				heal = math.ceil(heal * caster:GetOutputHealFinalWeight());
				-- append to hot sequence queue
				table_insert(hot_sequence, heal);
				table_insert(hot_threats, GetHealThreat(heal, caster:GetPhase()));
			end
				
			-- append hot sequence
			caster:AppendHoT(hot_sequence);
			last_target_overtimes = "0,"..last_target_overtimes;
			
			-- append threat
			local _, unit;
			for _, unit in ipairs(hostiles) do
				if(unit.isMob) then
					local mob = Mob.GetMobByID(unit.id);
					if(mob and mob:IsAlive()) then
						mob:AppendThreat(caster, 0, hot_threats);
					end
				end
			end
		end

		-- get arrow position
		local arrow_position = caster:GetArrowPosition_id();
		
		-- append spell play
		local spell_str = "";
		spell_str = format("%s:%s,%d,%d,%s,%s,%d,%s,%s,%d,%d,%d#%s#%s#%s#%s#%s#%s#%s#%s", spell_name, key, arena:GetID(), arrow_position, 
					tostring(caster_data.isMob), caster_data.id, caster:GetArrowPosition_id(), 
					tostring(target_data.isMob), target_data.id, target:GetArrowPosition_id(), 
					0, 0, 
					last_caster_charms, caster:GetCharmsValue(), 
					target:GetCharmsValue(), target:GetCharmsValue(), 
					last_target_wards, target:GetWardsValue(), 
					last_target_overtimes, target:GetOverTimeValue());
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname(spell_name);
		
		-- update arena
		local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
		spell_str = format("update_arena:%s+%s", key, value);
		table_insert(sequence, spell_str);
		-- update value
		local value = target:GetValue_normal_update();
		spell_str = format("update_value:%s", value);
		table_insert(sequence, spell_str);
		
	elseif(template.type == "AreaAttack" or template.type == "ArenaAttack" or template.type == "AreaDOTAttack" or template.type == "AreaAttackWithDOT" or template.type == "AreaAttackWithStun" or template.type == "AreaAttackWithImmolate" or template.type == "AreaAttackWithExtraThreat") then
		-- base damage
		local damage_min = Card.GetNumericalValueFromSection(template.params.damage_min or "0", pips_realcost) or 0;
		local damage_max = Card.GetNumericalValueFromSection(template.params.damage_max or "0", pips_realcost) or 0;
		local base_damage = math.random(damage_min, damage_max);
		local damage_school = template.params.damage_school;

		-- basic buffs including the caster blades and weaknesses
		local basic_buffs = {};
		basic_buffs.boost_damage_absolute = 0;
		
		local last_caster_charms = caster:GetCharmsValue();
		
		-- damage school boost
		local boost = caster:GetDamageBoost(damage_school);
		local boost_absolute = caster:GetDamageBoost_absolute(damage_school);
		basic_buffs.damage_percent = boost;
		basic_buffs.boost_damage_absolute = basic_buffs.boost_damage_absolute + boost_absolute;

		-- pop caster blades and weaknesses
		caster:ProcessDamageAgainstCharms(basic_buffs, damage_school);

		-- record each targets
		local targets = {};

		-- record buffs to each target
		local target_buffs = {};
		
		-- collect all information to the targets and buffs
		local pickedSide;
		local lower_region;
		local upper_region;
		if(target_data.isMob == true) then
			pickedSide = "far";
			lower_region = 5;
			upper_region = 8;
		elseif(target_data.isMob == false) then
			pickedSide = "near";
			lower_region = 1;
			upper_region = 4;
		end
		if(pickedSide and lower_region and upper_region) then
			local i;
			for i = lower_region, upper_region do
				local unit = arena:GetCombatUnitBySlotID(i);
				if(unit and unit:IsAlive() and unit:IsCombatActive()) then
					table_insert(targets, unit);
					table_insert(target_buffs, commonlib.deepcopy(basic_buffs));
				end
			end
			if(template.type == "ArenaAttack") then
				local self_lower_region = (1 + 5) - lower_region;
				local self_upper_region = (4 + 8) - upper_region;
				local i;
				for i = self_lower_region, self_upper_region do
					local unit = arena:GetCombatUnitBySlotID(i);
					if(unit and unit:IsAlive() and unit:IsCombatActive()) then
						table_insert(targets, unit);
						table_insert(target_buffs, commonlib.deepcopy(basic_buffs));
					end
				end
			end

			if(template.type == "AreaAttackWithImmolate") then
				i = caster:GetArrowPosition_id();
				local unit = arena:GetCombatUnitBySlotID(i);
				table_insert(targets, unit);
				table_insert(target_buffs, commonlib.deepcopy(basic_buffs));
			end

		end

		-- damage blocks
		local ismob_id_damage_blocks = "";

		-- extra play appended to sequence if any target is dead or damaged or speak dead word
		local extra_play_seq = {};
		-- extra dead record
		local extra_dead_record = {};

		-- additional reflection shield sequence
		local additional_reflection_shield_sequence = {};
		
		-- unit attack points mapping
		local unit_damage_mapping = {};

		local base_criticalstrike = template.params.base_criticalstrike or 0;
		local base_spellpenetration = template.params.base_spellpenetration or 0;

		-- calculate each target damage
		local i;
		for i = 1, #targets do
			-- damage
			local each_damage = base_damage;
			-- each target data
			local each_target = targets[i];
			local each_target_buff = target_buffs[i];
			
			local last_target_wards = each_target:GetWardsValue();
			local last_target_overtimes = each_target:GetOverTimeValue();
			
			-- DOT part of the attack only charms will be effective
			if(template.type == "AreaDOTAttack" or template.type == "AreaAttackWithDOT") then
				local dots_str = template.params.dots;
				local damage_school = template.params.damage_school;
				local damage_boost_absolute = caster:GetDamageBoost_absolute(damage_school);
				local dot_sequence = {
					icon_gsid = template.params.icon_gsid, -- could be nil
					damage_school = damage_school,
					buffs_target = each_target_buff,
					pips_realcost = pips_realcost,
					damage_boost_absolute = damage_boost_absolute,
					spell_penetration = caster:GetSpellPenetration(damage_school),
					outputdamage_finalweight = caster:GetOutputDamageFinalWeight(),
					caster_id = caster_data.id,
				};
				local dots_damage_school = {};
				local dots_school_str = template.params.dots_damage_school;
				local isDotDamageSchoolDifferent = false;
				if(dots_school_str) then
					isDotDamageSchoolDifferent = true;
					local dot_damage_school;
					for dot_damage_school in string.gmatch(dots_school_str, "([^,]+)") do
						table.insert(dots_damage_school,dot_damage_school);
					end
				end

				local dot_round = 1;
				local dmg;
				local dot_threats = {};
				for dmg in string.gmatch(dots_str, "([^,]+)") do
					if(isDotDamageSchoolDifferent) then
						damage_school = dots_damage_school[dot_round];
						damage_boost_absolute = caster:GetDamageBoost_absolute(damage_school);
						spell_penetration = caster:GetSpellPenetration(damage_school);
					end
					-- damage
					dmg = Card.GetNumericalValueFromSection(dmg, pips_realcost) or 0;
					
					local bCritical = false;
					if(TryCriticalStrike_DOT(caster, each_target, damage_school)) then
						dmg = math_ceil(dmg * GetCriticalStrikeDamageRatio(caster));
						bCritical = true;
					end
					-- append to dot sequence queue
					table_insert(dot_sequence, {dmg = dmg, bCritical = bCritical, damage_school = damage_school, damage_boost_absolute = damage_boost_absolute, spell_penetration = spell_penetration});

					-- calculate dot damage
					local _, boost;
					for _, boost in ipairs(each_target_buff) do
						dmg = math_ceil(dmg * (100 + boost) / 100);
					end

					local base_threat = GetDamageThreat(dmg, caster:GetPhase());
					table_insert(dot_threats, base_threat);
					dot_round = dot_round + 1;
				end
				
				-- append dot sequence
				each_target:AppendDoT(dot_sequence);
				last_target_overtimes = "0,"..last_target_overtimes;
				if(each_target:IsMob()) then
					each_target:AppendThreat(caster, 0, dot_threats)
				end
			end
			
			local dmg_mark;

			if(template.type == "AreaAttack" or template.type == "AreaAttackWithDOT" or template.type == "ArenaAttack" or template.type == "AreaAttackWithStun" or template.type == "AreaAttackWithImmolate" or template.type == "AreaAttackWithExtraThreat") then
				-- damage school
				local damage_school = template.params.damage_school;

				local bArenaAttackAndWithDoubleDamageTrap = false;
				if(template.type == "ArenaAttack") then
					if(each_target:HasWard(21, true)) then -- 21: Fire_FireDamageTrap
						bArenaAttackAndWithDoubleDamageTrap = true;
					end
					if(each_target:HasWard(47, true)) then -- 47: Fire_Pet_FireDamageTrap_OrangeBaby
						bArenaAttackAndWithDoubleDamageTrap = true;
					end
				end
				
				-- pop avaliable caster shield and traps
				damage_school = each_target:ProcessDamageAgainstWards(each_target_buff, damage_school);
				-- damage school boost
				local resist = each_target:GetResist(damage_school);
				local spell_penetration = caster:GetSpellPenetration(damage_school);
				local spell_penetration_receive = each_target:GetSpellPenetrationReceive(damage_school);
				local resist_absolute = each_target:GetResist_absolute(damage_school);
				each_target_buff.resist_percent = resist;
				each_target_buff.spell_penetration = spell_penetration + base_spellpenetration;
				each_target_buff.spell_penetration_receive = spell_penetration_receive;
				each_target_buff.boost_damage_absolute = each_target_buff.boost_damage_absolute + resist_absolute;
				
				-- check arena aura
				if(GlobalAura_boost_school == damage_school and GlobalAura_boost_damage) then
					table_insert(each_target_buff, GlobalAura_boost_damage);
				end

				-- calculate all damage modifiers
				each_damage = damage_expression(each_damage, each_target_buff.boost_damage_absolute, each_target_buff);
				
				local base_spell_hitchance = template.hitchance or 100;
				local base_doubleattack = template.params.base_doubleattack or 0;
				local base_criticalstrike = template.params.base_criticalstrike or 0;
				if(System.options.version ~= "kids" or (System.options.version == "kids" and arena.mode ~= "free_pvp")) then
					if(TryDodge(caster, each_target, base_spell_hitchance, damage_school)) then
						each_damage = math_ceil(each_damage * dodge_damage_ratio);
						dmg_mark = "d"; -- for dodge, dodge will overwrite the critical mark	
					else
						if(TryDoubleAttack(caster, each_target, base_doubleattack, damage_school)) then
							each_damage = math_ceil(each_damage * 2);
							dmg_mark = "t"; -- for double attack
						else
							if(TryCriticalStrike(caster, each_target, base_criticalstrike, damage_school)) then
								each_damage = math_ceil(each_damage * GetCriticalStrikeDamageRatio(caster));
								dmg_mark = "c"; -- for critical
							end
						end
					end
				else
					if(each_target.remedy.absoluteDefense_protect_rounds <= 0 and TryDodge(caster, each_target, base_spell_hitchance, damage_school)) then
						dmg_mark = "d";
						each_damage = 1;
						each_target.remedy.absoluteDefense_protect_rounds = protect_rounds_for_remedy;
					else
						if(each_target.remedy.deadlyAttack_protect_rounds <= 0 and TryDoubleAttack(caster, each_target, base_doubleattack, damage_school)) then
							each_damage = math_ceil(each_damage * 2);
							dmg_mark = "t"; -- for double attack
							each_target.remedy.deadlyAttack_protect_rounds = protect_rounds_for_remedy;
						else
							if(TryCriticalStrike(caster, each_target, base_criticalstrike, damage_school)) then
								each_damage = math_ceil(each_damage * GetCriticalStrikeDamageRatio(caster));
								dmg_mark = "c"; -- for critical
							end
						end
					end
				end

				if(template.type == "ArenaAttack") then
					if(bArenaAttackAndWithDoubleDamageTrap) then
						each_damage = each_damage * 2;
					end
				end

				if(template.type == "ArenaAttack" and caster:GetSide() == each_target:GetSide()) then
					-- half damage for mob alaias
					--王田(Andy) 10:15:01
					--确定? 那就是所有友方 一半?
					--蒲东宏(Leon) 10:15:29
					--对
					each_damage = math.ceil(each_damage / 2);
				end

				-- append threat
				if(each_target:IsMob()) then
					local caster_threat = caster:GetPhase();
					local each_threat = GetDamageThreat(each_damage, caster_threat);
					-- special ice area attack threat ratio
					if(template.type == "AreaAttack" and caster_threat == "ice") then
						each_threat = math_ceil(each_threat * ice_areaattack_threat_ratio);
					elseif(template.type == "AreaAttackWithExtraThreat") then
						local threat_ratio = tonumber(template.params.threat_ratio) or 1;
						each_threat = math_ceil(each_threat * threat_ratio);
					end
					each_target:AppendThreat(caster, each_threat);
				end

				-- final output and receive damage weight
				each_damage = math.ceil(each_damage * caster:GetOutputDamageFinalWeight());
				each_damage = math.ceil(each_damage * each_target:GetReceiveDamageFinalWeight(damage_school));

				-- check avaliable absorbs
				each_damage = AbsorbDamage(each_target, each_damage);
				
				-- reflection shield
				if(each_target.reflect_amount > 0 and each_damage > 0) then
					local reflect_buffs = {};
					-- pop avaliable caster shield and traps
					local reflect_damage = each_damage;
					local reflect_damage_school = caster:ProcessDamageAgainstWards(reflect_buffs, damage_school);
					-- damage school resist
					local resist = caster:GetResist(reflect_damage_school);
					local spell_penetration = caster:GetSpellPenetration(reflect_damage_school);
					local spell_penetration_receive = caster:GetSpellPenetrationReceive(reflect_damage_school);
					local damageboost_absolute = caster:GetDamageBoost_absolute(reflect_damage_school);
					local resist_absolute = caster:GetResist_absolute(reflect_damage_school);
					reflect_buffs.resist_percent = resist;
					reflect_buffs.spell_penetration = spell_penetration;
					reflect_buffs.spell_penetration_receive = spell_penetration_receive;
					-- check arena aura
					if(GlobalAura_boost_school == reflect_damage_school and GlobalAura_boost_damage) then
						table_insert(reflect_buffs, GlobalAura_boost_damage);
					end
					-- calculate reflect damage
					-- NOTE 2012/1/24: cancel damageboost_absolute + resist_absolute for reflect damage
					reflect_damage = damage_expression(reflect_damage, 0, reflect_buffs);

					-- final output and receive damage weight
					reflect_damage = math.ceil(reflect_damage * caster:GetOutputDamageFinalWeight());
					reflect_damage = math.ceil(reflect_damage * caster:GetReceiveDamageFinalWeight(reflect_damage_school));

					-- check avaliable absorbs
					reflect_damage = AbsorbDamage(caster, reflect_damage);
					-- test reflect damage
					local caster_current_hp = caster:GetCurrentHP();
					if(reflect_damage >= MAX_REFLECT_DAMAGE) then
						-- max reflect damage
						reflect_damage = MAX_REFLECT_DAMAGE;
					end
					if(reflect_damage >= caster_current_hp) then
						-- reflect damage is not deathful
						reflect_damage = caster_current_hp - 1;
					end
					-- take damage
					caster:TakeDamage(reflect_damage);
					-- push unit damage mapping
					table.insert(unit_damage_mapping, {caster, reflect_damage});
					-- skip freeze test, because caster can't attack while freezed
					-- append reflection spell play
					local spell_str = "";
					local damage_school = template.params.damage_school;
					local arrow_position = caster:GetArrowPosition_id();
					spell_str = format("%s:%s,%d,%d,%s,%s,%d,%s,%s,%d,%d,%d#%s#%s#%s#%s#%s#%s#%s#%s", 
								"Ice_ReflectionShield_reflection", "Ice_ReflectionShield_reflection", arena:GetID(), arrow_position, 
								tostring(each_target:IsMob()), each_target:GetID(), each_target:GetArrowPosition_id(), 
								tostring(caster_data.isMob), caster_data.id, caster:GetArrowPosition_id(), 
								reflect_damage, 0, 
								each_target:GetCharmsValue(), each_target:GetCharmsValue(), 
								caster:GetCharmsValue(), caster:GetCharmsValue(), 
								caster:GetWardsValue(), caster:GetWardsValue(), 
								caster:GetOverTimeValue(), caster:GetOverTimeValue());
					table_insert(additional_reflection_shield_sequence, spell_str);
					sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Ice_ReflectionShield_reflection");
					-- append dead play if caster is dead
					if(not caster:IsAlive()) then
						-- try speak dead word
						TrySpeakDeadWord(caster, arena:GetID(), additional_reflection_shield_sequence);
						local spell_str = "";
						spell_str = format("dead:%d,%d,%s,%d", arena:GetID(), arrow_position, tostring(caster_data.isMob), caster_data.id);
						table_insert(additional_reflection_shield_sequence, spell_str);
						sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Dead");
						-- mark battlefield death
						TryMarkBattleFieldDeath(arena, caster, sequence.duration);
						-- update arena
						local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
						spell_str = format("update_arena:%s+%s", key, value);
						table_insert(additional_reflection_shield_sequence, spell_str);
						-- update value
						local value = caster:GetValue_normal_update();
						spell_str = format("update_value:%s", value);
						table_insert(additional_reflection_shield_sequence, spell_str);
						return false;
					end
					-- update arena
					local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
					spell_str = format("update_arena:%s+%s", key, value);
					table_insert(additional_reflection_shield_sequence, spell_str);
					-- update value
					local value = caster:GetValue_normal_update();
					spell_str = format("update_value:%s", value);
					table_insert(additional_reflection_shield_sequence, spell_str);
					-- calculate damage and reflect_amount
					if(each_damage >= each_target.reflect_amount) then
						-- break the shield
						each_damage = each_damage - each_target.reflect_amount;
						each_target.reflect_amount = 0;
						-- play break shield spell
						local arrow_position = caster:GetArrowPosition_id();
						spell_str = format("%s:%s,%d,%d,%s,%s,%d,%s,%s,%d,%d,%d#%s#%s#%s#%s#%s#%s#%s#%s", 
									"Ice_ReflectionShield_shieldbreak", "Ice_ReflectionShield_shieldbreak", arena:GetID(), arrow_position, 
									tostring(each_target:IsMob()), each_target:GetID(), each_target:GetArrowPosition_id(), 
									tostring(caster_data.isMob), caster_data.id, caster:GetArrowPosition_id(), 
									0, 0, 
									each_target:GetCharmsValue(), each_target:GetCharmsValue(), 
									caster:GetCharmsValue(), caster:GetCharmsValue(), 
									caster:GetWardsValue(), caster:GetWardsValue(), 
									caster:GetOverTimeValue(), caster:GetOverTimeValue());
						table_insert(additional_reflection_shield_sequence, spell_str);
						sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Ice_ReflectionShield_shieldbreak");
					else
						-- absorb all damage
						each_target.reflect_amount = each_target.reflect_amount - each_damage;
						each_damage = 0;
					end
				end

				-- take damage
				--if(caster_data.id == 46650264) then
					--each_damage = math.random(9000, 15000);
				--end
				
				-- the card which name or key is "Balance_Rune_AreaAttackWithImmolate_Lv5" can't kill target
				if(non_lethal_card_name[key]) then
					target_cur_hp = each_target:GetCurrentHP();
					if(each_damage > target_cur_hp) then
						each_damage = target_cur_hp - 1;
					end
				end


				--local caster_cur_hp = caster:GetCurrentHP();
				--local target_cur_hp = target:GetCurrentHP();
				local each_target_cur_hp = each_target:GetCurrentHP();
				if(arena.is_battlefield and each_damage > each_target_cur_hp) then
					each_damage = each_target_cur_hp;
				end

				each_target:TakeDamage(each_damage);
				-- append pierce freeze round
				if(caster:GetStance() == "pierce") then
					each_target:AppendPierceFreezeRounds(3);
				end
				-- push unit damage mapping
				table.insert(unit_damage_mapping, {each_target, each_damage});
				-- break freeze status if so
				if(each_target.freeze_rounds > 0) then
					each_target.freeze_rounds = 0;
					---- additional update to remove the ice block
					--local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
					--spell_str = format("update_arena:%s+%s", key, value);
					--table_insert(sequence, spell_str);
					---- play the break freeze spell
					--local arrow_position = each_target:GetArrowPosition_id();
					--spell_str = format("%s:%s,%d,%d,%s,%d,%d,%s,%d,%d,%d,%d#%s#%s#%s#%s#%s#%s#%s#%s", 
								--"Ice_SingleFreeze_Break", "Ice_SingleFreeze_Break", arena:GetID(), arrow_position, 
								--tostring(each_target:IsMob()), each_target:GetID(), each_target:GetArrowPosition_id(), 
								--tostring(each_target:IsMob()), each_target:GetID(), each_target:GetArrowPosition_id(), 
								--0, 0, 
								--each_target:GetCharmsValue(), each_target:GetCharmsValue(), 
								--each_target:GetCharmsValue(), each_target:GetCharmsValue(), 
								--each_target:GetWardsValue(), each_target:GetWardsValue(), 
								--each_target:GetOverTimeValue(), each_target:GetOverTimeValue());
					--table_insert(sequence, spell_str);
					--sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Ice_SingleFreeze_Break");
				end
			end

			if(template.type == "AreaAttackWithStun") then
				-- check if target immune to stun
				if(not each_target:IsImmuneToStun()) then
					-- if stun is absorbed
					local absorbed = false;
					-- pop target stun absorb if exist
					local id, ward;
					for id, ward in pairs(wards) do
						if(ward.stunabsorb == "true" or ward.stunabsorb == true) then
							if(each_target:PopWard(id)) then
								absorbed = true;
								break;
							end
						end
					end
					if(absorbed == false) then
						-- stun each target
						each_target.bStunned = true;
						if(not template.params.do_not_generate_absorb) then
							-- append four stun absorb in case of chain absorb
							each_target:AppendWard(stunabsorb_ward_id);
							each_target:AppendWard(stunabsorb_ward_id);
							if(System.options.version ~= "teen") then
								each_target:AppendWard(stunabsorb_ward_id);
								--each_target:AppendWard(stunabsorb_ward_id);
							end
						end
						-- append threat
						if(each_target:IsMob()) then
							each_target:AppendThreat(caster, GetEffectThreat("stun"));
						end
					end
				end
			end
				
			-- append dead play if target is dead
			if(not each_target:IsAlive()) then
				-- try speak dead word
				TrySpeakDeadWord(each_target, arena:GetID(), extra_play_seq);
				-- append dead spell
				local spell_str = "";
				spell_str = format("dead:%d,%d,%s,%d", arena:GetID(), each_target:GetArrowPosition_id(), tostring(each_target:IsMob()), each_target:GetID());
				table_insert(extra_play_seq, spell_str);
				sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Dead");
				-- mark battlefield death
				TryMarkBattleFieldDeath(arena, each_target, sequence.duration);
			end
			-- append updated value
			local value = each_target:GetValue_normal_update();
			spell_str = format("update_value:%s", value);
			table_insert(extra_play_seq, spell_str);

			local ismob_id_damage = "";
			ismob_id_damage = format("(%s,%s,%d,%s#%s#%s#%s#%s#%s#%s)", 
					tostring(each_target:IsMob()), each_target:GetID(), each_target:GetArrowPosition_id(), 
					(dmg_mark or "")..each_damage, 
					each_target:GetCharmsValue(), each_target:GetCharmsValue(), 
					last_target_wards, each_target:GetWardsValue(), 
					last_target_overtimes, each_target:GetOverTimeValue());
			ismob_id_damage_blocks = ismob_id_damage_blocks..ismob_id_damage;
		end

		-- get arrow position
		local arrow_position = caster:GetArrowPosition_id();
		
		-- append spell play
		local spell_str = "";
		spell_str = format("%s:%s,%d,%d,%s,%s+%s+%s+%s", spell_name, key, arena:GetID(), arrow_position, tostring(caster_data.isMob), caster_data.id, last_caster_charms, caster:GetCharmsValue(), ismob_id_damage_blocks);
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname(spell_name);
		-- mark battlefield attack points
		local _, mapping;
		for _, mapping in ipairs(unit_damage_mapping) do
			TryMarkBattleFieldAttack(arena, mapping[1], mapping[2], sequence.duration, caster, key);
		end
		-- append extra play sequence
		local _, seq;
		for _, seq in ipairs(extra_play_seq) do
			table_insert(sequence, seq);
		end
		-- update arena
		local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
		spell_str = format("update_arena:%s+%s", key, value);
		table_insert(sequence, spell_str);
		
		-- append additional reflection shield sequence
		local _, spell_line;
		for _, spell_line in ipairs(additional_reflection_shield_sequence) do
			table_insert(sequence, spell_line);
		end

	elseif(template.type == "AreaPowerPipBoost") then
		
		local last_caster_charms = caster:GetCharmsValue();

		-- record each targets
		local targets = {};

		-- record buffs to each target
		local target_buffs = {};
		
		-- collect all information to the targets and buffs
		local pickedSide;
		local lower_region;
		local upper_region;
		if(target_data.isMob == true) then
			pickedSide = "far";
			lower_region = 5;
			upper_region = 8;
		elseif(target_data.isMob == false) then
			pickedSide = "near";
			lower_region = 1;
			upper_region = 4;
		end
		if(pickedSide and lower_region and upper_region) then
			local i;
			for i = lower_region, upper_region do
				local unit = arena:GetCombatUnitBySlotID(i);
				if(unit and unit:IsCombatActive()) then
					if(unit:IsAlive()) then -- NOTE: AreaHeal can revive player anymore
						table_insert(targets, unit);
						table_insert(target_buffs, commonlib.deepcopy(basic_buffs));
					end
				end
			end
		end

		-- heal blocks
		local ismob_id_heal_blocks = "";

		-- extra play appended to sequence if any target is dead or healed
		local extra_play_seq = {};

		-- total heal threat
		local total_threat = 0;

		-- calculate each target cleanse
		local i;
		for i = 1, #targets do
			-- heal
			local heal = 0;
			-- each target data
			local each_target = targets[i];
			local each_target_buff = target_buffs[i];
			
			local last_target_wards = target:GetWardsValue();
			local last_target_overtimes = target:GetOverTimeValue();
			
			-- count threat
			total_threat = total_threat + GetEffectThreat("areapowerpipboost");

			-- generate powerpips
			local i = 1;
			for i = 1, template.params.powerpips do
				each_target:GeneratePip(true); -- true for bForcePowerPip
			end

			-- append updated value
			local value = each_target:GetValue_normal_update();
			spell_str = format("update_value:%s", value);
			table_insert(extra_play_seq, spell_str);

			local ismob_id_heal = "";
			ismob_id_heal = format("(%s,%s,%d,%d#%s#%s#%s#%s#%s#%s)", tostring(each_target:IsMob()), each_target:GetID(), each_target:GetArrowPosition_id(), heal, each_target:GetCharmsValue(), each_target:GetCharmsValue(), last_target_wards, each_target:GetWardsValue(), last_target_overtimes, each_target:GetOverTimeValue());
			ismob_id_heal_blocks = ismob_id_heal_blocks..ismob_id_heal;
		end
		
		-- append threat
		local _, unit;
		for _, unit in ipairs(hostiles) do
			if(unit.isMob) then
				local mob = Mob.GetMobByID(unit.id);
				if(mob and mob:IsAlive()) then
					mob:AppendThreat(caster, total_threat);
				end
			end
		end

		-- get arrow position
		local arrow_position = caster:GetArrowPosition_id();
		
		-- append spell play
		local spell_str = "";
		spell_str = format("%s:%s,%d,%d,%s,%s+%s+%s+%s", spell_name, key, arena:GetID(), arrow_position, tostring(caster_data.isMob), caster_data.id, last_caster_charms, caster:GetCharmsValue(), ismob_id_heal_blocks);
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname(spell_name);
		-- append extra play sequence
		local _, seq;
		for _, seq in ipairs(extra_play_seq) do
			table_insert(sequence, seq);
		end
		-- update arena
		local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
		spell_str = format("update_arena:%s+%s", key, value);
		table_insert(sequence, spell_str);
		
	elseif(template.type == "SingleCleanse") then
		-- get arrow position
		local arrow_position = caster:GetArrowPosition_id();
		-- pop all negative effects: charms, wards, dots etc.
		target:PopAllNegativeEffects();
		-- append threat
		local _, unit;
		for _, unit in ipairs(hostiles) do
			if(unit.isMob) then
				local mob = Mob.GetMobByID(unit.id);
				if(mob and mob:IsAlive()) then
					local base_threat = GetEffectThreat("singlecleanse");
					if((target:IsMob() == mob:IsMob()) and (target:GetID() == mob:GetID())) then
						mob:AppendThreat(caster, base_threat);
					else
						mob:AppendThreat(caster, math.ceil(base_threat * splash_manipulation_threat_ratio));
					end
				end
			end
		end
		local spell_str = "";
		spell_str = format("%s:%s,%d,%d,%s,%s,%d,%s,%s,%d,%d,%d#%s#%s#%s#%s#%s#%s#%s#%s", 
			spell_name, 
			key, 
			arena:GetID(), 
			arrow_position, 
			tostring(caster_data.isMob), 
			caster_data.id, 
			caster:GetArrowPosition_id(), 
			tostring(target_data.isMob), 
			target_data.id,
			target:GetArrowPosition_id(), 
			0, 0, 
			caster:GetCharmsValue(), caster:GetCharmsValue(), 
			target:GetCharmsValue(), target:GetCharmsValue(), 
			target:GetWardsValue(), target:GetWardsValue(), 
			target:GetOverTimeValue(), target:GetOverTimeValue()
		);
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname(spell_name);
		-- update arena
		local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
		spell_str = format("update_arena:%s+%s", key, value);
		table_insert(sequence, spell_str);

	elseif(template.type == "AreaCleanse") then
		
		local last_caster_charms = caster:GetCharmsValue();

		-- record each targets
		local targets = {};

		-- record buffs to each target
		local target_buffs = {};
		
		-- collect all information to the targets and buffs
		local pickedSide;
		local lower_region;
		local upper_region;
		if(target_data.isMob == true) then
			pickedSide = "far";
			lower_region = 5;
			upper_region = 8;
		elseif(target_data.isMob == false) then
			pickedSide = "near";
			lower_region = 1;
			upper_region = 4;
		end
		if(pickedSide and lower_region and upper_region) then
			local i;
			for i = lower_region, upper_region do
				local unit = arena:GetCombatUnitBySlotID(i);
				if(unit and unit:IsCombatActive()) then
					if(unit:IsAlive()) then -- NOTE: AreaHeal can revive player anymore
						table_insert(targets, unit);
						table_insert(target_buffs, commonlib.deepcopy(basic_buffs));
					end
				end
			end
		end

		-- heal blocks
		local ismob_id_heal_blocks = "";

		-- extra play appended to sequence if any target is dead or healed
		local extra_play_seq = {};

		-- total heal threat
		local total_threat = 0;

		-- calculate each target cleanse
		local i;
		for i = 1, #targets do
			-- each target data
			local each_target = targets[i];
			local each_target_buff = target_buffs[i];
			
			local last_target_wards = each_target:GetWardsValue();
			local last_target_overtimes = each_target:GetOverTimeValue();
			
			-- count threat
			total_threat = total_threat + GetEffectThreat("areacleanse");

			-- pop all negative effects: charms, wards, dots etc.
			each_target:PopAllNegativeEffects();

			-- append updated value
			local value = each_target:GetValue_normal_update();
			spell_str = format("update_value:%s", value);
			table_insert(extra_play_seq, spell_str);

			local ismob_id_heal = "";
			ismob_id_heal = format("(%s,%s,%d,%d#%s#%s#%s#%s#%s#%s)", tostring(each_target:IsMob()), each_target:GetID(), each_target:GetArrowPosition_id(), 0, each_target:GetCharmsValue(), each_target:GetCharmsValue(), last_target_wards, each_target:GetWardsValue(), last_target_overtimes, each_target:GetOverTimeValue());
			ismob_id_heal_blocks = ismob_id_heal_blocks..ismob_id_heal;
		end
		
		-- append threat
		local _, unit;
		for _, unit in ipairs(hostiles) do
			if(unit.isMob) then
				local mob = Mob.GetMobByID(unit.id);
				if(mob and mob:IsAlive()) then
					mob:AppendThreat(caster, total_threat);
				end
			end
		end

		-- get arrow position
		local arrow_position = caster:GetArrowPosition_id();
		
		-- append spell play
		local spell_str = "";
		spell_str = format("%s:%s,%d,%d,%s,%s+%s+%s+%s", spell_name, key, arena:GetID(), arrow_position, tostring(caster_data.isMob), caster_data.id, last_caster_charms, caster:GetCharmsValue(), ismob_id_heal_blocks);
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname(spell_name);
		-- append extra play sequence
		local _, seq;
		for _, seq in ipairs(extra_play_seq) do
			table_insert(sequence, seq);
		end
		-- update arena
		local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
		spell_str = format("update_arena:%s+%s", key, value);
		table_insert(sequence, spell_str);
		

	elseif(template.type == "AreaHeal" or template.type == "AreaHealWithAbsorb" or template.type == "AreaHealWithHOT") then
		-- base heal
		local heal_min = Card.GetNumericalValueFromSection(template.params.heal_min, pips_realcost) or 0;
		local heal_max = Card.GetNumericalValueFromSection(template.params.heal_max, pips_realcost) or 0;
		local base_heal = math.random(heal_min, heal_max);
			
		-- basic buffs including the caster blades and weaknesses
		local basic_buffs = {};
		
		local last_caster_charms = caster:GetCharmsValue();

		-- pop caster heal blades and weaknesses
		caster:ProcessHealAgainstCharms(basic_buffs);

		-- record each targets
		local targets = {};

		-- record buffs to each target
		local target_buffs = {};
		
		-- collect all information to the targets and buffs
		local pickedSide;
		local lower_region;
		local upper_region;
		if(target_data.isMob == true) then
			pickedSide = "far";
			lower_region = 5;
			upper_region = 8;
		elseif(target_data.isMob == false) then
			pickedSide = "near";
			lower_region = 1;
			upper_region = 4;
		end
		if(pickedSide and lower_region and upper_region) then
			local i;
			for i = lower_region, upper_region do
				local unit = arena:GetCombatUnitBySlotID(i);
				if(unit and unit:IsCombatActive()) then
					if(unit:IsAlive()) then -- NOTE: AreaHeal can revive player anymore
						table_insert(targets, unit);
						table_insert(target_buffs, commonlib.deepcopy(basic_buffs));
					elseif(not unit:IsAlive() and unit:IsMob() and mob_revivable_card_name[key]) then
						-- NOTE 2012/11/29: mob unit can be revived if card key is in mob_revivable_card_name
						table_insert(targets, unit);
						table_insert(target_buffs, commonlib.deepcopy(basic_buffs));
					elseif(not unit:IsAlive() and not unit:IsMob() and revivable_card_name[key]) then
						-- NOTE 2012/12/11: player unit can be revived if card key is in revivable_card_name
						table_insert(targets, unit);
						table_insert(target_buffs, commonlib.deepcopy(basic_buffs));
					end
				end
			end
		end

		-- heal blocks
		local ismob_id_heal_blocks = "";

		-- extra play appended to sequence if any target is dead or healed
		local extra_play_seq = {};

		-- total heal threat
		local total_threat = 0;
		-- total hot heal threat
		local total_threat_hot = {};

		-- unit heal mapping
		local unit_heal_mapping = {};

		-- calculate each target heal
		local i;
		for i = 1, #targets do
			-- heal
			local heal = base_heal;
			-- each target data
			local each_target = targets[i];
			local each_target_buff = target_buffs[i];
			
			local last_target_wards = target:GetWardsValue();
			local last_target_overtimes = target:GetOverTimeValue();
			
			-- output heal boost
			local output_heal_boost = caster:GetOutputHealBoost();
			table_insert(each_target_buff, output_heal_boost);

			if(template.type == "AreaHealWithHOT") then

				local hots_str = template.params.hots;
				local hot_sequence = {
					icon_gsid = template.params.icon_gsid, -- could be nil
					caster_id = caster_data.id,
				};
				local heal;
				local count = 1;
				for heal in string.gmatch(hots_str, "([^,]+)") do
					heal = tonumber(heal);

					-- calculate hot heal
					heal = heal_expression(heal, each_target_buff);
					
					-- output heal final weight
					heal = math.ceil(heal * caster:GetOutputHealFinalWeight());
					
					-- append to hot sequence queue
					table_insert(hot_sequence, heal);
					local this_hot_threat = math.ceil(heal * areaheal_threat_ratio);
					total_threat_hot[count] = total_threat_hot[count] or 0;
					total_threat_hot[count] = total_threat_hot[count] + GetHealThreat(this_hot_threat, caster:GetPhase());
					count = count + 1;
				end
				
				-- append hot sequence
				each_target:AppendHoT(hot_sequence);
				last_target_overtimes = "0,"..last_target_overtimes;
			end
			
			-- pop each target shields and traps
			local id, ward;
			for id, ward in pairs(wards) do
				if(ward.boost_heal) then
					if(each_target:PopWard(id)) then
						table_insert(each_target_buff, ward.boost_heal);
						--last_target_wards = "0,"..last_target_wards;
					end
				end
			end

			-- check arena aura
			if(GlobalAura_boost_heal) then
				table_insert(each_target_buff, GlobalAura_boost_heal);
			end

			-- input heal boost
			local input_heal_boost = each_target:GetInputHealBoost();
			table_insert(each_target_buff, input_heal_boost);


			-- calculate other heal modifiers
			heal = heal_expression(heal, each_target_buff);
			
			-- count threat
			total_threat = total_threat + GetDamageThreat(heal, caster:GetPhase());
			
			-- arena heal penalty
			heal = process_heal_penalty(arena, heal);

			-- output heal final weight
			heal = math.ceil(heal * caster:GetOutputHealFinalWeight());
			
					
					commonlib.echo(heal)

			--local caster_lost_hp = caster:GetMaxHP() - caster_cur_hp;
			--local target_lost_hp = target:GetMaxHP() - target_cur_hp;
			local each_target_lost_hp = each_target:GetMaxHP() - each_target:GetCurrentHP();
			if(arena.is_battlefield and heal > each_target_lost_hp) then
				heal = each_target_lost_hp;
			end

			-- take heal
			each_target:TakeHeal(heal);
			
			-- push unit heal mapping
			table.insert(unit_heal_mapping, {each_target, heal});
			
			if(template.type == "AreaHealWithAbsorb") then
				-- append absorb
				local absorb_pts = Card.GetNumericalValueFromSection(template.params.absorb_pts, pips_realcost) or 0;
				each_target:AppendAbsorb(absorb_pts, tonumber(template.params.ward));
				
				-- count threat
				total_threat = total_threat + GetEffectThreat("absorb");
			end
				
			-- append dead play if target is dead
			if(not each_target:IsAlive()) then
				-- try speak dead word
				TrySpeakDeadWord(each_target, arena:GetID(), extra_play_seq);
				local spell_str = "";
				spell_str = format("dead:%d,%d,%s,%s", arena:GetID(), each_target:GetArrowPosition_id(), tostring(each_target:IsMob()), each_target:GetID());
				table_insert(extra_play_seq, spell_str);
				sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Dead");
				-- mark battlefield death
				TryMarkBattleFieldDeath(arena, each_target, sequence.duration);
			end
			-- append updated value
			local value = each_target:GetValue_normal_update();
			spell_str = format("update_value:%s", value);
			table_insert(extra_play_seq, spell_str);

			local ismob_id_heal = "";
			ismob_id_heal = format("(%s,%s,%d,%d#%s#%s#%s#%s#%s#%s)", tostring(each_target:IsMob()), each_target:GetID(), each_target:GetArrowPosition_id(), heal, each_target:GetCharmsValue(), each_target:GetCharmsValue(), last_target_wards, each_target:GetWardsValue(), last_target_overtimes, each_target:GetOverTimeValue());
			ismob_id_heal_blocks = ismob_id_heal_blocks..ismob_id_heal;
		end
		
		-- append threat
		local _, unit;
		for _, unit in ipairs(hostiles) do
			if(unit.isMob) then
				local mob = Mob.GetMobByID(unit.id);
				if(mob and mob:IsAlive()) then
					mob:AppendThreat(caster, math.ceil(total_threat * areaheal_threat_ratio), total_threat_hot);
				end
			end
		end

		-- get arrow position
		local arrow_position = caster:GetArrowPosition_id();
		
		-- append spell play
		local spell_str = "";
		spell_str = format("%s:%s,%d,%d,%s,%s+%s+%s+%s", spell_name, key, arena:GetID(), arrow_position, tostring(caster_data.isMob), caster_data.id, last_caster_charms, caster:GetCharmsValue(), ismob_id_heal_blocks);
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname(spell_name);
		-- mark battlefield heal points
		local _, mapping;
		for _, mapping in ipairs(unit_heal_mapping) do
			TryMarkBattleFieldHeal(arena, mapping[1], mapping[2], sequence.duration, caster, key);
		end
		-- append extra play sequence
		local _, seq;
		for _, seq in ipairs(extra_play_seq) do
			table_insert(sequence, seq);
		end
		-- update arena
		local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
		spell_str = format("update_arena:%s+%s", key, value);
		table_insert(sequence, spell_str);
		
	elseif(template.type == "Global") then
		local icon_gsid = template.params.icon_gsid; -- could be nil
		if(template.params.boost_damage) then
			if(template.spell_school == "death") then
				arena:SetAura("death_damage", template.params.boost_damage, template.params.school, nil, nil, icon_gsid);
			else
				arena:SetAura(template.spell_school, template.params.boost_damage, template.params.school, nil, nil, icon_gsid);
			end
		elseif(template.params.boost_heal) then
			arena:SetAura(template.spell_school, nil, nil, template.params.boost_heal, nil, icon_gsid);
		elseif(template.params.boost_powerpip) then
			arena:SetAura(template.spell_school, nil, nil, nil, template.params.boost_powerpip, icon_gsid);
		end
		
		-- append threat
		local _, unit;
		for _, unit in ipairs(hostiles) do
			if(unit.isMob) then
				local mob = Mob.GetMobByID(unit.id);
				if(mob and mob:IsAlive()) then
					mob:AppendThreat(caster, GetEffectThreat("global"));
				end
			end
		end

		-- get arrow position
		local arrow_position = caster:GetArrowPosition_id();
		
		-- append spell play
		local spell_str = "";
		spell_str = format("%s:%s,%d,%d,%s,%s,%d,%s,%s,%d,%d,%d#%s#%s#%s#%s#%s#%s#%s#%s", spell_name, key, arena:GetID(), arrow_position, 
					tostring(caster_data.isMob), caster_data.id, caster:GetArrowPosition_id(), 
					tostring(target_data.isMob), target_data.id, target:GetArrowPosition_id(), 
					0, 0, 
					caster:GetCharmsValue(), caster:GetCharmsValue(), 
					target:GetCharmsValue(), target:GetCharmsValue(), 
					target:GetWardsValue(), target:GetWardsValue(), 
					target:GetOverTimeValue(), target:GetOverTimeValue());
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname(spell_name);
		-- update arena
		local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
		spell_str = format("update_arena:%s+%s", key, value);
		table_insert(sequence, spell_str);
		-- update value
		local value = target:GetValue_normal_update();
		spell_str = format("update_value:%s", value);
		table_insert(sequence, spell_str);
		
	elseif(template.type == "Global2") then
		
		local icon_gsid = template.params.icon_gsid; -- could be nil
		arena:SetAura2(template.params.globalaura, icon_gsid);
		
		-- append threat
		local _, unit;
		for _, unit in ipairs(hostiles) do
			if(unit.isMob) then
				local mob = Mob.GetMobByID(unit.id);
				if(mob and mob:IsAlive()) then
					mob:AppendThreat(caster, GetEffectThreat("global"));
				end
			end
		end

		-- get arrow position
		local arrow_position = caster:GetArrowPosition_id();
		
		-- append spell play
		local spell_str = "";
		spell_str = format("%s:%s,%d,%d,%s,%s,%d,%s,%s,%d,%d,%d#%s#%s#%s#%s#%s#%s#%s#%s", spell_name, key, arena:GetID(), arrow_position, 
					tostring(caster_data.isMob), caster_data.id, caster:GetArrowPosition_id(), 
					tostring(target_data.isMob), target_data.id, target:GetArrowPosition_id(), 
					0, 0, 
					caster:GetCharmsValue(), caster:GetCharmsValue(), 
					target:GetCharmsValue(), target:GetCharmsValue(), 
					target:GetWardsValue(), target:GetWardsValue(), 
					target:GetOverTimeValue(), target:GetOverTimeValue());
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname(spell_name);
		-- update arena
		local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
		spell_str = format("update_arena:%s+%s", key, value);
		table_insert(sequence, spell_str);
		-- update value
		local value = target:GetValue_normal_update();
		spell_str = format("update_value:%s", value);
		table_insert(sequence, spell_str);
		
	elseif(template.type == "MiniAura") then
		-- get arrow position
		local arrow_position = caster:GetArrowPosition_id();
		local mini_aura_id = template.params.miniaura;
		local rounds = template.params.rounds;
		target:SetMiniAura(tonumber(mini_aura_id), tonumber(rounds));
		-- append threat
		local _, unit;
		for _, unit in ipairs(hostiles) do
			if(unit.isMob) then
				local mob = Mob.GetMobByID(unit.id);
				if(mob and mob:IsAlive()) then
					local base_threat = GetEffectThreat("miniaura");
					if((target:IsMob() == mob:IsMob()) and (target:GetID() == mob:GetID())) then
						mob:AppendThreat(caster, base_threat);
					else
						mob:AppendThreat(caster, math.ceil(base_threat * splash_manipulation_threat_ratio));
					end
				end
			end
		end
		local spell_str = "";
		spell_str = format("%s:%s,%d,%d,%s,%s,%d,%s,%s,%d,%d,%d#%s#%s#%s#%s#%s#%s#%s#%s", 
			spell_name, 
			key, 
			arena:GetID(), 
			arrow_position, 
			tostring(caster_data.isMob), 
			caster_data.id, 
			caster:GetArrowPosition_id(), 
			tostring(target_data.isMob), 
			target_data.id,
			target:GetArrowPosition_id(), 
			0, 0, 
			caster:GetCharmsValue(), caster:GetCharmsValue(), 
			target:GetCharmsValue(), target:GetCharmsValue(), 
			target:GetWardsValue(), target:GetWardsValue(), 
			target:GetOverTimeValue(), target:GetOverTimeValue()
		);
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname(spell_name);
		-- update arena
		local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
		spell_str = format("update_arena:%s+%s", key, value);
		table_insert(sequence, spell_str);

	elseif(template.type == "StealCharm" or template.type == "RemovePositiveCharm" or template.type == "RemoveNegativeCharm") then
		-- get arrow position
		local arrow_position = caster:GetArrowPosition_id();
		local last_caster_charms = caster:GetCharmsValue();
		local last_target_charms = target:GetCharmsValue();
		local this_caster_charms = caster:GetCharmsValue();
		local this_target_charms = target:GetCharmsValue();
		if(template.params.remove_count == 1 or template.params.steal_count == 1) then
			local charm_id;
			if(template.type == "RemovePositiveCharm") then
				charm_id = target:PopFirstCharm(true);
			elseif(template.type == "RemoveNegativeCharm") then
				charm_id = target:PopFirstCharm(false);
			elseif(template.type == "StealCharm") then
				charm_id = target:PopFirstCharm(true);
			end
			if(charm_id) then
				if(template.type == "StealCharm") then
					caster:AppendCharm(tonumber(charm_id));
					this_caster_charms = charm_id..","..this_caster_charms;
					last_caster_charms = "0,"..last_caster_charms;
				end
				-- charm poped
				this_target_charms = "0,"..target:GetCharmsValue();
				last_target_charms = charm_id..","..target:GetCharmsValue();
			else
				-- we ensure we have available charm to steal
			end
		end
		
		-- append threat
		local _, unit;
		for _, unit in ipairs(hostiles) do
			if(unit.isMob) then
				local mob = Mob.GetMobByID(unit.id);
				if(mob and mob:IsAlive()) then
					if(template.type == "RemovePositiveCharm") then
						local base_threat = GetEffectThreat("removepositivecharm");
						if((target:IsMob() == mob:IsMob()) and (target:GetID() == mob:GetID())) then
							mob:AppendThreat(caster, base_threat);
						else
							mob:AppendThreat(caster, math.ceil(base_threat * splash_manipulation_threat_ratio));
						end
					elseif(template.type == "RemoveNegativeCharm") then
						mob:AppendThreat(caster, GetEffectThreat("removenegativecharm"))
					elseif(template.type == "StealCharm") then
						local base_threat = GetEffectThreat("stealcharm");
						if((target:IsMob() == mob:IsMob()) and (target:GetID() == mob:GetID())) then
							mob:AppendThreat(caster, base_threat);
						else
							mob:AppendThreat(caster, math.ceil(base_threat * splash_manipulation_threat_ratio));
						end
					end
				end
			end
		end

		local spell_str = "";
		spell_str = format("%s:%s,%d,%d,%s,%s,%d,%s,%s,%d,%d,%d#%s#%s#%s#%s#%s#%s#%s#%s", 
			spell_name, 
			key, 
			arena:GetID(), 
			arrow_position, 
			tostring(caster_data.isMob), 
			caster_data.id, 
			caster:GetArrowPosition_id(), 
			tostring(target_data.isMob), 
			target_data.id,
			target:GetArrowPosition_id(), 
			0, 0, 
			last_caster_charms, this_caster_charms, 
			last_target_charms, this_target_charms, 
			target:GetWardsValue(), target:GetWardsValue(), 
			target:GetOverTimeValue(), target:GetOverTimeValue()
		);
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname(spell_name);
		-- update arena
		local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
		spell_str = format("update_arena:%s+%s", key, value);
		table_insert(sequence, spell_str);
		
	elseif(template.type == "StealWard" or template.type == "RemovePositiveWard" or template.type == "RemoveNegativeWard") then
		-- get arrow position
		local arrow_position = caster:GetArrowPosition_id();
		local last_caster_wards = caster:GetWardsValue();
		local last_target_wards = target:GetWardsValue();
		local this_caster_wards = caster:GetWardsValue();
		local this_target_wards = target:GetWardsValue();
		if(template.params.remove_count == 1 or template.params.steal_count == 1) then
			local ward_id;
			if(template.type == "RemovePositiveWard") then
				ward_id = target:PopFirstWardForManipulate(true);
			elseif(template.type == "RemoveNegativeWard") then
				ward_id = target:PopFirstWardForManipulate(false);
			elseif(template.type == "StealWard") then
				if(System.options.version == "kids") then
					ward_id = target:PopRandomWardForManipulate(true);
				else
					ward_id = target:PopFirstWardForManipulate(true);
				end
			end
			if(ward_id) then
				if(template.type == "StealWard") then
					caster:AppendWard(tonumber(ward_id));
					this_caster_wards = ward_id..","..this_caster_wards;
					last_caster_wards = "0,"..last_caster_wards;
				end
				-- ward poped
				this_target_wards = "0,"..target:GetWardsValue();
				last_target_wards = ward_id..","..target:GetWardsValue();
			else
				-- we ensure we have available ward to steal
			end
		end
		
		-- append threat
		local _, unit;
		for _, unit in ipairs(hostiles) do
			if(unit.isMob) then
				local mob = Mob.GetMobByID(unit.id);
				if(mob and mob:IsAlive()) then
					if(template.type == "RemovePositiveWard") then
						local base_threat = GetEffectThreat("removepositiveward");
						if((target:IsMob() == mob:IsMob()) and (target:GetID() == mob:GetID())) then
							mob:AppendThreat(caster, base_threat);
						else
							mob:AppendThreat(caster, math.ceil(base_threat * splash_manipulation_threat_ratio));
						end
					elseif(template.type == "RemoveNegativeWard") then
						mob:AppendThreat(caster, GetEffectThreat("removenegativeward"))
					elseif(template.type == "StealWard") then
						local base_threat = GetEffectThreat("stealward");
						if((target:IsMob() == mob:IsMob()) and (target:GetID() == mob:GetID())) then
							mob:AppendThreat(caster, base_threat);
						else
							mob:AppendThreat(caster, math.ceil(base_threat * splash_manipulation_threat_ratio));
						end
					end
				end
			end
		end

		local spell_str = "";
		spell_str = format("%s:%s,%d,%d,%s,%s,%d,%s,%s,%d,%d,%d#%s#%s#%s#%s#%s#%s#%s#%s", 
			spell_name, 
			key, 
			arena:GetID(), 
			arrow_position, 
			tostring(caster_data.isMob), 
			caster_data.id, 
			caster:GetArrowPosition_id(), 
			tostring(target_data.isMob), 
			target_data.id,
			target:GetArrowPosition_id(), 
			0, 0, 
			caster:GetCharmsValue(), caster:GetCharmsValue(), 
			target:GetCharmsValue(), target:GetCharmsValue(), 
			last_target_wards, this_target_wards, 
			target:GetOverTimeValue(), target:GetOverTimeValue()
		);
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname(spell_name);
		-- update arena
		local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
		spell_str = format("update_arena:%s+%s", key, value);
		table_insert(sequence, spell_str);
		
	elseif(template.type == "Absorb") then
		-- get arrow position
		local arrow_position = caster:GetArrowPosition_id();
		local last_target_wards = target:GetWardsValue();
		-- append absorb
		local absorb_pts = Card.GetNumericalValueFromSection(template.params.absorb_pts, pips_realcost) or 0;
		target:AppendAbsorb(absorb_pts, tonumber(template.params.ward));
		last_target_wards = "0,"..last_target_wards;
		
		-- append threat
		local _, unit;
		for _, unit in ipairs(hostiles) do
			if(unit.isMob) then
				local mob = Mob.GetMobByID(unit.id);
				if(mob and mob:IsAlive()) then
					mob:AppendThreat(caster, GetEffectThreat("absorb"))
				end
			end
		end

		-- make spell string
		local spell_str = "";
		spell_str = format("%s:%s,%d,%d,%s,%s,%d,%s,%s,%d,%d,%d#%s#%s#%s#%s#%s#%s#%s#%s", 
			spell_name, 
			key, 
			arena:GetID(), 
			arrow_position, 
			tostring(caster_data.isMob), 
			caster_data.id, 
			caster:GetArrowPosition_id(), 
			tostring(target_data.isMob), 
			target_data.id,
			target:GetArrowPosition_id(), 
			0, 0, 
			caster:GetCharmsValue(), caster:GetCharmsValue(), 
			target:GetCharmsValue(), target:GetCharmsValue(), 
			last_target_wards, target:GetWardsValue(), 
			target:GetOverTimeValue(), target:GetOverTimeValue()
		);
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname(spell_name);
		-- update arena
		local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
		spell_str = format("update_arena:%s+%s", key, value);
		table_insert(sequence, spell_str);
		
	elseif(template.type == "Absorb_Adv") then
		-- get arrow position
		local arrow_position = caster:GetArrowPosition_id();
		local last_target_wards = target:GetWardsValue();

		-- append absorb
		local base_absorb_pts = template.params.base_absorb_pts or 0;
		local scale_absorb_pts = template.params.scale_absorb_pts or 1;
		local boost_absolute = caster:GetDamageBoost_absolute(template.spell_school);

		local total_absorb_pts = math.ceil(base_absorb_pts + scale_absorb_pts * boost_absolute);

		target:AppendAbsorb(total_absorb_pts, tonumber(template.params.ward));
		last_target_wards = "0,"..last_target_wards;
		
		-- append threat
		local _, unit;
		for _, unit in ipairs(hostiles) do
			if(unit.isMob) then
				local mob = Mob.GetMobByID(unit.id);
				if(mob and mob:IsAlive()) then
					mob:AppendThreat(caster, GetEffectThreat("absorb"))
				end
			end
		end

		-- make spell string
		local spell_str = "";
		spell_str = format("%s:%s,%d,%d,%s,%s,%d,%s,%s,%d,%d,%d#%s#%s#%s#%s#%s#%s#%s#%s", 
			spell_name, 
			key, 
			arena:GetID(), 
			arrow_position, 
			tostring(caster_data.isMob), 
			caster_data.id, 
			caster:GetArrowPosition_id(), 
			tostring(target_data.isMob), 
			target_data.id,
			target:GetArrowPosition_id(), 
			0, 0, 
			caster:GetCharmsValue(), caster:GetCharmsValue(), 
			target:GetCharmsValue(), target:GetCharmsValue(), 
			last_target_wards, target:GetWardsValue(), 
			target:GetOverTimeValue(), target:GetOverTimeValue()
		);
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname(spell_name);
		-- update arena
		local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
		spell_str = format("update_arena:%s+%s", key, value);
		table_insert(sequence, spell_str);
		
	elseif(template.type == "SingleStun") then
		-- get arrow position
		local arrow_position = caster:GetArrowPosition_id();
		local last_target_wards = target:GetWardsValue();
		local this_target_wards = target:GetWardsValue();
		-- check if target immune to stun
		if(not target:IsImmuneToStun()) then
			-- if stun is absorbed
			local absorbed = false;
			-- pop target stun absorb if exist
			local id, ward;
			for id, ward in pairs(wards) do
				if(ward.stunabsorb == "true" or ward.stunabsorb == true) then
					if(target:PopWard(id)) then
						absorbed = true;
						break;
					end
				end
			end
			if(absorbed == false) then
				-- stun the target
				target.bStunned = true;
				if(not template.params.do_not_generate_absorb) then
					-- append four stun absorb in case of chain absorb
					target:AppendWard(stunabsorb_ward_id);
					target:AppendWard(stunabsorb_ward_id);
					last_target_wards = "0,0,"..last_target_wards;
					if(System.options.version ~= "teen") then
						target:AppendWard(stunabsorb_ward_id);
						target:AppendWard(stunabsorb_ward_id);
						last_target_wards = "0,0,"..last_target_wards;
					end
				end
			else
				-- stun absorbed
				this_target_wards = "0,"..target:GetWardsValue();
				-- test double stun
				if(template.params.bDoubleStun) then
					-- if stun is absorbed
					local doublestun_absorbed = false;
					-- pop target stun absorb if exist
					local id, ward;
					for id, ward in pairs(wards) do
						if(ward.stunabsorb == "true" or ward.stunabsorb == true) then
							if(target:PopWard(id)) then
								doublestun_absorbed = true;
								break;
							end
						end
					end
					if(doublestun_absorbed == false) then
						-- stun the target
						target.bStunned = true;
						if(not template.params.do_not_generate_absorb) then
							-- append four stun absorb in case of chain absorb
							target:AppendWard(stunabsorb_ward_id);
							target:AppendWard(stunabsorb_ward_id);
							last_target_wards = "0,0,"..last_target_wards;
							if(System.options.version ~= "teen") then
								target:AppendWard(stunabsorb_ward_id);
								target:AppendWard(stunabsorb_ward_id);
								last_target_wards = "0,0,"..last_target_wards;
							end
						end
					else
						-- stun doublestun absorbed
						this_target_wards = "0,"..target:GetWardsValue();
					end
				end
			end
		end
		-- append threat
		local _, unit;
		for _, unit in ipairs(hostiles) do
			if(unit.isMob) then
				local mob = Mob.GetMobByID(unit.id);
				if(mob and mob:IsAlive()) then
					local base_threat = GetEffectThreat("stun");
					if((target:IsMob() == mob:IsMob()) and (target:GetID() == mob:GetID())) then
						mob:AppendThreat(caster, base_threat);
					else
						mob:AppendThreat(caster, math.ceil(base_threat * splash_manipulation_threat_ratio));
					end
				end
			end
		end
		-- make spell string
		local spell_str = "";
		spell_str = format("%s:%s,%d,%d,%s,%s,%d,%s,%s,%d,%d,%d#%s#%s#%s#%s#%s#%s#%s#%s", 
			spell_name, 
			key, 
			arena:GetID(), 
			arrow_position, 
			tostring(caster_data.isMob), 
			caster_data.id, 
			caster:GetArrowPosition_id(), 
			tostring(target_data.isMob), 
			target_data.id,
			target:GetArrowPosition_id(), 
			0, 0, 
			caster:GetCharmsValue(), caster:GetCharmsValue(), 
			target:GetCharmsValue(), target:GetCharmsValue(), 
			last_target_wards, this_target_wards, 
			target:GetOverTimeValue(), target:GetOverTimeValue()
		);
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname(spell_name);
		-- update arena
		local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
		spell_str = format("update_arena:%s+%s", key, value);
		table_insert(sequence, spell_str);

	elseif(template.type == "AreaStun") then
		-- record each targets
		local targets = {};
		-- collect all information to the targets and buffs
		local pickedSide;
		local lower_region;
		local upper_region;
		if(target_data.isMob == true) then
			pickedSide = "far";
			lower_region = 5;
			upper_region = 8;
		elseif(target_data.isMob == false) then
			pickedSide = "near";
			lower_region = 1;
			upper_region = 4;
		end
		if(pickedSide and lower_region and upper_region) then
			local i;
			for i = lower_region, upper_region do
				local unit = arena:GetCombatUnitBySlotID(i);
				if(unit and unit:IsAlive() and unit:IsCombatActive()) then
					table_insert(targets, unit);
				end
			end
		end

		-- damage blocks
		local ismob_id_blocks = "";

		-- append each target charm
		local charm = template.params.charm;
		local i;
		for i = 1, #targets do
			local each_target = targets[i];
			
			-- get arrow position
			local last_target_wards = each_target:GetWardsValue();
			local this_target_wards = each_target:GetWardsValue();
			-- check if target immune to stun
			if(not each_target:IsImmuneToStun()) then
				-- if stun is absorbed
				local absorbed = false;
				-- pop target stun absorb if exist
				local id, ward;
				for id, ward in pairs(wards) do
					if(ward.stunabsorb == "true" or ward.stunabsorb == true) then
						if(each_target:PopWard(id)) then
							absorbed = true;
							break;
						end
					end
				end
				if(absorbed == false) then
					-- stun the target
					each_target.bStunned = true;
					if(not template.params.do_not_generate_absorb) then
						-- append four stun absorb in case of chain absorb
						each_target:AppendWard(stunabsorb_ward_id);
						each_target:AppendWard(stunabsorb_ward_id);
						last_target_wards = "0,0,"..last_target_wards;
						if(System.options.version ~= "teen") then
							each_target:AppendWard(stunabsorb_ward_id);
							--each_target:AppendWard(stunabsorb_ward_id);
							last_target_wards = "0,0,"..last_target_wards;
						end
					end
				else
					-- stun absorbed
					this_target_wards = "0,"..each_target:GetWardsValue();
					-- test double stun
					if(template.params.bDoubleStun) then
						-- if double stun is absorbed
						local doublestun_absorbed = false;
						-- pop target stun absorb if exist
						local id, ward;
						for id, ward in pairs(wards) do
							if(ward.stunabsorb == "true" or ward.stunabsorb == true) then
								if(each_target:PopWard(id)) then
									doublestun_absorbed = true;
									break;
								end
							end
						end
						if(doublestun_absorbed == false) then
							-- stun the target
							each_target.bStunned = true;
							if(not template.params.do_not_generate_absorb) then
								-- append four stun absorb in case of chain absorb
								each_target:AppendWard(stunabsorb_ward_id);
								each_target:AppendWard(stunabsorb_ward_id);
								last_target_wards = "0,0,"..last_target_wards;
								if(System.options.version ~= "teen") then
									each_target:AppendWard(stunabsorb_ward_id);
									--each_target:AppendWard(stunabsorb_ward_id);
									last_target_wards = "0,0,"..last_target_wards;
								end
							end
						else
							-- stun doublestun absorbed
							this_target_wards = "0,"..each_target:GetWardsValue();
						end
					end
				end
			end
			
			-- append threat
			if(each_target:IsMob()) then
				each_target:AppendThreat(caster, GetEffectThreat("stun"));
			end

			local ismob_id = "";
			ismob_id = format("(%s,%s,%d,0#%s#%s#%s#%s#%s#%s)", tostring(each_target:IsMob()), each_target:GetID(), each_target:GetArrowPosition_id(), 
				each_target:GetCharmsValue(), each_target:GetCharmsValue(), last_target_wards, this_target_wards, each_target:GetOverTimeValue(), each_target:GetOverTimeValue());
			ismob_id_blocks = ismob_id_blocks..ismob_id;
		end

		-- get arrow position
		local arrow_position = caster:GetArrowPosition_id();
		
		-- append spell play
		local spell_str = "";
		spell_str = format("%s:%s,%d,%d,%s,%s+%s+%s+%s", spell_name, key, arena:GetID(), arrow_position, tostring(caster_data.isMob), caster_data.id, caster:GetCharmsValue(), caster:GetCharmsValue(), ismob_id_blocks);
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname(spell_name);
		-- update arena
		local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
		spell_str = format("update_arena:%s+%s", key, value);
		table_insert(sequence, spell_str);

	elseif(template.type == "AreaControl") then
	--elseif(template.type == "AreaControl" and caster:IsMob()) then
		-- record each targets
		local targets = {};
		-- collect all information to the targets and buffs
		local pickedSide;
		local lower_region;
		local upper_region;
		if(target_data.isMob == true) then
			pickedSide = "far";
			lower_region = 5;
			upper_region = 8;
		elseif(target_data.isMob == false) then
			pickedSide = "near";
			lower_region = 1;
			upper_region = 4;
		end
		if(pickedSide and lower_region and upper_region) then
			local i;
			for i = lower_region, upper_region do
				local unit = arena:GetCombatUnitBySlotID(i);
				if(unit and unit:IsAlive() and unit:IsCombatActive()) then
					table_insert(targets, unit);
				end
			end
		end

		-- damage blocks
		local ismob_id_blocks = "";

		local i;
		for i = 1, #targets do
			local each_target = targets[i];
			
			-- get arrow position
			local last_target_wards = each_target:GetWardsValue();
			local this_target_wards = each_target:GetWardsValue();
			-- if stun is absorbed
			local absorbed = false;
			-- pop target stun absorb if exist
			local id, ward;
			for id, ward in pairs(wards) do
				if(ward.controlabsorb == "true" or ward.controlabsorb == true) then
					if(each_target:PopWard(id)) then
						absorbed = true;
						break;
					end
				end
			end
			if(absorbed == false) then
				-- control the target
				--each_target.control_rounds = template.params.rounds + 1;
				each_target.control_rounds = template.params.rounds;
			else
				-- control absorbed
				this_target_wards = "0,"..each_target:GetWardsValue();
			end

			local ismob_id = "";
			ismob_id = format("(%s,%s,%d,0#%s#%s#%s#%s#%s#%s)", tostring(each_target:IsMob()), each_target:GetID(), each_target:GetArrowPosition_id(), 
				each_target:GetCharmsValue(), each_target:GetCharmsValue(), last_target_wards, this_target_wards, each_target:GetOverTimeValue(), each_target:GetOverTimeValue());
			ismob_id_blocks = ismob_id_blocks..ismob_id;
		end

		-- get arrow position
		local arrow_position = caster:GetArrowPosition_id();
		
		-- append spell play
		local spell_str = "";
		spell_str = format("%s:%s,%d,%d,%s,%s+%s+%s+%s", spell_name, key, arena:GetID(), arrow_position, tostring(caster_data.isMob), caster_data.id, caster:GetCharmsValue(), caster:GetCharmsValue(), ismob_id_blocks);
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname(spell_name);
		-- update arena
		local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
		spell_str = format("update_arena:%s+%s", key, value);
		table_insert(sequence, spell_str);
		
	elseif(template.type == "SingleFreeze") then
		-- get arrow position
		local arrow_position = caster:GetArrowPosition_id();
		local last_target_wards = target:GetWardsValue();
		local this_target_wards = target:GetWardsValue();
		-- play spell name
		local this_spell_name = spell_name;
		-- check if target immune to freeze
		if(not target:IsImmuneToFreeze()) then
			-- freeze the target
			if(target.anti_freeze_rounds <= 0 and target.anti_freeze_rounds_sibling <= 0) then
				if(arena.apply_temp_anti_freeze_rounds_for_partners and System.options.version ~= "teen") then
					-- record each targets
					local targets = {};
					-- collect all information to the targets and buffs
					local pickedSide;
					local lower_region;
					local upper_region;
					local target_side = target:GetSide();
					if(target_side == "far") then
						pickedSide = "far";
						lower_region = 5;
						upper_region = 8;
					elseif(target_side == "near") then
						pickedSide = "near";
						lower_region = 1;
						upper_region = 4;
					end
					if(pickedSide and lower_region and upper_region) then
						local i;
						for i = lower_region, upper_region do
							local unit = arena:GetCombatUnitBySlotID(i);
							if(unit and unit:IsAlive() and unit:IsCombatActive()) then
								table_insert(targets, unit);
							end
						end
					end
					local i;
					for i = 1, #targets do
						local each_target = targets[i];
						each_target.anti_freeze_rounds_sibling = 3;
					end
				end
				-- freeze the target and anti_freeze_rounds
				target.freeze_rounds = template.params.rounds + 1;
				target.anti_freeze_rounds = 8 + 1;
				target.anti_freeze_rounds_sibling = 0;
				if(arena.mode == "pve" and arena.isNearArenaFirst) then -- pve and player first
					-- NOTE: the mob spell is blocked this round but not calculate the freeze_rounds
					target.freeze_rounds = template.params.rounds;
					target.anti_freeze_rounds = 8;
					target.anti_freeze_rounds_sibling = 0;
				end
				if(System.options.version == "teen") then
					target.anti_freeze_rounds = 0; -- don't apply anti freeze rounds for teen version
					target.anti_freeze_rounds_sibling = 0; -- don't apply anti freeze rounds for teen version
				end
				if(System.options.version ~= "teen") then
					-- NOTE 2012/5/22: don't apply global shield ward for teen version
					-- append global shield ward
					target:AppendWard(globalshield_ward_id);
					last_target_wards = "0,"..last_target_wards;
				end
				this_spell_name = spell_name;
			else
				this_spell_name = string.gsub(spell_name, "SingleFreeze", "SingleFreeze_Fail");
			end
		else
			this_spell_name = string.gsub(spell_name, "SingleFreeze", "SingleFreeze_Fail");
		end
		-- append threat
		local _, unit;
		for _, unit in ipairs(hostiles) do
			if(unit.isMob) then
				local mob = Mob.GetMobByID(unit.id);
				if(mob and mob:IsAlive()) then
					local base_threat = GetEffectThreat("singlefreeze");
					if((target:IsMob() == mob:IsMob()) and (target:GetID() == mob:GetID())) then
						mob:AppendThreat(caster, base_threat);
					else
						mob:AppendThreat(caster, math.ceil(base_threat * splash_manipulation_threat_ratio));
					end
				end
			end
		end
		-- make spell string
		local spell_str = "";
		spell_str = format("%s:%s,%d,%d,%s,%s,%d,%s,%s,%d,%d,%d#%s#%s#%s#%s#%s#%s#%s#%s", 
			this_spell_name, 
			key, 
			arena:GetID(), 
			arrow_position, 
			tostring(caster_data.isMob), 
			caster_data.id, 
			caster:GetArrowPosition_id(), 
			tostring(target_data.isMob), 
			target_data.id,
			target:GetArrowPosition_id(), 
			0, 0, 
			caster:GetCharmsValue(), caster:GetCharmsValue(), 
			target:GetCharmsValue(), target:GetCharmsValue(), 
			last_target_wards, this_target_wards, 
			target:GetOverTimeValue(), target:GetOverTimeValue()
		);
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname(spell_name);
		-- update arena
		local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
		spell_str = format("update_arena:%s+%s", key, value);
		table_insert(sequence, spell_str);
		
	elseif(template.type == "SingleStealth") then
		-- get arrow position
		local arrow_position = caster:GetArrowPosition_id();
		local last_target_wards = target:GetWardsValue();
		local this_target_wards = target:GetWardsValue();
		-- stealth the target
		local rounds = template.params.rounds;
		target:SetStealthRounds(tonumber(rounds));
		-- append threat
		local _, unit;
		for _, unit in ipairs(hostiles) do
			if(unit.isMob) then
				local mob = Mob.GetMobByID(unit.id);
				if(mob and mob:IsAlive()) then
					local base_threat = GetEffectThreat("stun");
					if((target:IsMob() == mob:IsMob()) and (target:GetID() == mob:GetID())) then
						mob:AppendThreat(caster, base_threat);
					else
						mob:AppendThreat(caster, math.ceil(base_threat * splash_manipulation_threat_ratio));
					end
				end
			end
		end
		-- make spell string
		local spell_str = "";
		spell_str = format("%s:%s,%d,%d,%s,%s,%d,%s,%s,%d,%d,%d#%s#%s#%s#%s#%s#%s#%s#%s", 
			spell_name, 
			key, 
			arena:GetID(), 
			arrow_position, 
			tostring(caster_data.isMob), 
			caster_data.id, 
			caster:GetArrowPosition_id(), 
			tostring(target_data.isMob), 
			target_data.id,
			target:GetArrowPosition_id(), 
			0, 0, 
			caster:GetCharmsValue(), caster:GetCharmsValue(), 
			target:GetCharmsValue(), target:GetCharmsValue(), 
			last_target_wards, this_target_wards, 
			target:GetOverTimeValue(), target:GetOverTimeValue()
		);
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname(spell_name);
		-- update arena
		local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
		spell_str = format("update_arena:%s+%s", key, value);
		table_insert(sequence, spell_str);
		
	elseif(template.type == "SingleTaunt") then
		-- get arrow position
		local arrow_position = caster:GetArrowPosition_id();
		-- taunt
		if(target:IsMob() and target:IsAlive() and target:IsCombatActive()) then
			target:SetHighestThreat(caster:GetThreatID(), template.params.additional_threat);
		end
		local spell_str = "";
		spell_str = format("%s:%s,%d,%d,%s,%s,%d,%s,%s,%d,%d,%d#%s#%s#%s#%s#%s#%s#%s#%s", 
			spell_name, 
			key, 
			arena:GetID(), 
			arrow_position, 
			tostring(caster_data.isMob), 
			caster_data.id, 
			caster:GetArrowPosition_id(), 
			tostring(target_data.isMob), 
			target_data.id,
			target:GetArrowPosition_id(), 
			0, 0, 
			caster:GetCharmsValue(), caster:GetCharmsValue(), 
			target:GetCharmsValue(), target:GetCharmsValue(), 
			target:GetWardsValue(), target:GetWardsValue(), 
			target:GetOverTimeValue(), target:GetOverTimeValue()
		);
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname(spell_name);
		-- update arena
		local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
		spell_str = format("update_arena:%s+%s", key, value);
		table_insert(sequence, spell_str);
		
	elseif(template.type == "AreaTaunt") then
		-- record each targets
		local targets = {};
		-- collect all information to the targets
		local pickedSide;
		local lower_region;
		local upper_region;
		if(target_data.isMob == true) then
			pickedSide = "far";
			lower_region = 5;
			upper_region = 8;
		elseif(target_data.isMob == false) then
			pickedSide = "near";
			lower_region = 1;
			upper_region = 4;
		end
		if(pickedSide and lower_region and upper_region) then
			local i;
			for i = lower_region, upper_region do
				local unit = arena:GetCombatUnitBySlotID(i);
				if(unit and unit:IsAlive() and unit:IsCombatActive()) then
					table_insert(targets, unit);
				end
			end
		end

		-- unit blocks
		local ismob_id_blocks = "";
		
		-- taunt each target
		local charm = template.params.charm;
		local i;
		for i = 1, #targets do
			local each_target = targets[i];
			
			-- append threat
			if(each_target:IsMob()) then
				if(each_target:IsAlive() and each_target:IsCombatActive()) then
					each_target:SetHighestThreat(caster:GetThreatID(), template.params.additional_threat);
				end
			end

			local ismob_id = "";
			ismob_id = format("(%s,%s,%d,0#%s#%s#%s#%s#%s#%s)", tostring(each_target:IsMob()), each_target:GetID(), each_target:GetArrowPosition_id(), 
				each_target:GetCharmsValue(), each_target:GetCharmsValue(), each_target:GetWardsValue(), each_target:GetWardsValue(), each_target:GetOverTimeValue(), each_target:GetOverTimeValue());
			ismob_id_blocks = ismob_id_blocks..ismob_id;
		end

		-- get arrow position
		local arrow_position = caster:GetArrowPosition_id();
		
		-- append spell play
		local spell_str = "";
		spell_str = format("%s:%s,%d,%d,%s,%s+%s+%s+%s", spell_name, key, arena:GetID(), arrow_position, tostring(caster_data.isMob), caster_data.id, caster:GetCharmsValue(), caster:GetCharmsValue(), ismob_id_blocks);
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname(spell_name);
		-- update arena
		local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
		spell_str = format("update_arena:%s+%s", key, value);
		table_insert(sequence, spell_str);
		
	elseif(template.type == "Stance") then
		-- get arrow position
		local arrow_position = caster:GetArrowPosition_id();
		local last_target_wards = target:GetWardsValue();
		local this_target_wards = target:GetWardsValue();
		-- stance rounds
		local stance = template.params.stance;
		local rounds = template.params.rounds;
		caster:SetStance(stance, tonumber(rounds));
		-- append threat
		local _, unit;
		for _, unit in ipairs(hostiles) do
			if(unit.isMob) then
				local mob = Mob.GetMobByID(unit.id);
				if(mob and mob:IsAlive()) then
					local base_threat = GetEffectThreat("stun");
					if((target:IsMob() == mob:IsMob()) and (target:GetID() == mob:GetID())) then
						mob:AppendThreat(caster, base_threat);
					else
						mob:AppendThreat(caster, math.ceil(base_threat * splash_manipulation_threat_ratio));
					end
				end
			end
		end
		-- make spell string
		local spell_str = "";
		spell_str = format("%s:%s,%d,%d,%s,%s,%d,%s,%s,%d,%d,%d#%s#%s#%s#%s#%s#%s#%s#%s", 
			spell_name, 
			key, 
			arena:GetID(), 
			arrow_position, 
			tostring(caster_data.isMob), 
			caster_data.id, 
			caster:GetArrowPosition_id(), 
			tostring(target_data.isMob), 
			target_data.id,
			target:GetArrowPosition_id(), 
			0, 0, 
			caster:GetCharmsValue(), caster:GetCharmsValue(), 
			target:GetCharmsValue(), target:GetCharmsValue(), 
			last_target_wards, this_target_wards, 
			target:GetOverTimeValue(), target:GetOverTimeValue()
		);
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname(spell_name);
		-- update arena
		local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
		spell_str = format("update_arena:%s+%s", key, value);
		table_insert(sequence, spell_str);

	elseif(template.type == "ConversePositiveWard") then
		
		-- get arrow position
		local arrow_position = caster:GetArrowPosition_id();
		local last_target_wards = target:GetWardsValue();
		local this_target_wards = target:GetWardsValue();
		--if(target:PopWard(template.params.fromward)) then
			--last_target_wards = template.params.fromward..","..target:GetWardsValue();
			--this_target_wards = template.params.toward..","..target:GetWardsValue();
			--target:AppendWard(template.params.toward);
		--elseif(System.options.version == "teen") then
		if(true) then
			if(target:PopWard(template.params.fromward + 1000)) then
				last_target_wards = template.params.fromward..","..target:GetWardsValue();
				this_target_wards = template.params.toward..","..target:GetWardsValue();
				target:AppendWard(template.params.toward);
			elseif(target:PopWard(template.params.fromward + 2000)) then
				last_target_wards = template.params.fromward..","..target:GetWardsValue();
				this_target_wards = template.params.toward..","..target:GetWardsValue();
				target:AppendWard(template.params.toward);
			elseif(target:PopWard(template.params.fromward + 3000)) then
				last_target_wards = template.params.fromward..","..target:GetWardsValue();
				this_target_wards = template.params.toward..","..target:GetWardsValue();
				target:AppendWard(template.params.toward);
			elseif(target:PopWard(template.params.fromward + 4000)) then
				last_target_wards = template.params.fromward..","..target:GetWardsValue();
				this_target_wards = template.params.toward..","..target:GetWardsValue();
				target:AppendWard(template.params.toward);
			end
		end
		-- append threat
		local _, unit;
		for _, unit in ipairs(hostiles) do
			if(unit.isMob) then
				local mob = Mob.GetMobByID(unit.id);
				if(mob and mob:IsAlive()) then
					local base_threat = GetEffectThreat("conversepositiveward");
					if((target:IsMob() == mob:IsMob()) and (target:GetID() == mob:GetID())) then
						mob:AppendThreat(caster, base_threat);
					else
						mob:AppendThreat(caster, math.ceil(base_threat * splash_manipulation_threat_ratio));
					end
				end
			end
		end
		local spell_str = "";
		spell_str = format("%s:%s,%d,%d,%s,%s,%d,%s,%s,%d,%d,%d#%s#%s#%s#%s#%s#%s#%s#%s", 
			spell_name, 
			key, 
			arena:GetID(), 
			arrow_position, 
			tostring(caster_data.isMob), 
			caster_data.id, 
			caster:GetArrowPosition_id(), 
			tostring(target_data.isMob), 
			target_data.id,
			target:GetArrowPosition_id(), 
			0, 0, 
			caster:GetCharmsValue(), caster:GetCharmsValue(), 
			target:GetCharmsValue(), target:GetCharmsValue(), 
			last_target_wards, this_target_wards, 
			target:GetOverTimeValue(), target:GetOverTimeValue()
		);
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname(spell_name);
		-- update arena
		local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
		spell_str = format("update_arena:%s+%s", key, value);
		table_insert(sequence, spell_str);
		
	elseif(template.type == "Charms") then
		-- get arrow position
		local arrow_position = caster:GetArrowPosition_id();
		local last_target_charms = target:GetCharmsValue();
		local charm;
		for charm in string.gmatch(template.params.charms, "([^,]+)") do
			target:AppendCharm(tonumber(charm));
			last_target_charms = "0,"..last_target_charms;
		end
		-- append threat
		local _, unit;
		for _, unit in ipairs(hostiles) do
			if(unit.isMob) then
				local mob = Mob.GetMobByID(unit.id);
				if(mob and mob:IsAlive()) then
					local base_threat = GetEffectThreat("charms");
					if((target:IsMob() == mob:IsMob()) and (target:GetID() == mob:GetID())) then
						mob:AppendThreat(caster, base_threat);
					else
						mob:AppendThreat(caster, math.ceil(base_threat * splash_manipulation_threat_ratio));
					end
				end
			end
		end
		local spell_str = "";
		spell_str = format("%s:%s,%d,%d,%s,%s,%d,%s,%s,%d,%d,%d#%s#%s#%s#%s#%s#%s#%s#%s", 
			spell_name, 
			key, 
			arena:GetID(), 
			arrow_position, 
			tostring(caster_data.isMob), 
			caster_data.id, 
			caster:GetArrowPosition_id(), 
			tostring(target_data.isMob), 
			target_data.id,
			target:GetArrowPosition_id(), 
			0, 0, 
			caster:GetCharmsValue(), caster:GetCharmsValue(), 
			last_target_charms, target:GetCharmsValue(), 
			target:GetWardsValue(), target:GetWardsValue(), 
			target:GetOverTimeValue(), target:GetOverTimeValue()
		);
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname(spell_name);
		-- update arena
		local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
		spell_str = format("update_arena:%s+%s", key, value);
		table_insert(sequence, spell_str);
		
	elseif(template.type == "AreaCharm") then
		-- record each targets
		local targets = {};
		-- collect all information to the targets and buffs
		local pickedSide;
		local lower_region;
		local upper_region;
		if(target_data.isMob == true) then
			pickedSide = "far";
			lower_region = 5;
			upper_region = 8;
		elseif(target_data.isMob == false) then
			pickedSide = "near";
			lower_region = 1;
			upper_region = 4;
		end
		if(pickedSide and lower_region and upper_region) then
			local i;
			for i = lower_region, upper_region do
				local unit = arena:GetCombatUnitBySlotID(i);
				if(unit and unit:IsAlive() and unit:IsCombatActive()) then
					table_insert(targets, unit);
				end
			end
		end

		-- damage blocks
		local ismob_id_blocks = "";

		-- append each target charm
		local charm = template.params.charm;
		local i;
		for i = 1, #targets do
			local each_target = targets[i];
			local last_target_charms = each_target:GetCharmsValue();
			each_target:AppendCharm(charm);
			last_target_charms = "0,"..last_target_charms;
			local ismob_id = "";
			ismob_id = format("(%s,%s,%d,0#%s#%s#%s#%s#%s#%s)", tostring(each_target:IsMob()), each_target:GetID(), each_target:GetArrowPosition_id(), last_target_charms, each_target:GetCharmsValue(), each_target:GetWardsValue(), each_target:GetWardsValue(), each_target:GetOverTimeValue(), each_target:GetOverTimeValue());
			ismob_id_blocks = ismob_id_blocks..ismob_id;
		end
		
		-- append threat
		local _, unit;
		for _, unit in ipairs(hostiles) do
			if(unit.isMob) then
				local mob = Mob.GetMobByID(unit.id);
				if(mob and mob:IsAlive()) then
					mob:AppendThreat(caster, GetEffectThreat("areacharm"));
				end
			end
		end

		-- get arrow position
		local arrow_position = caster:GetArrowPosition_id();
		
		-- append spell play
		local spell_str = "";
		spell_str = format("%s:%s,%d,%d,%s,%s+%s+%s+%s", spell_name, key, arena:GetID(), arrow_position, tostring(caster_data.isMob), caster_data.id, caster:GetCharmsValue(), caster:GetCharmsValue(), ismob_id_blocks);
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname(spell_name);
		-- update arena
		local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
		spell_str = format("update_arena:%s+%s", key, value);
		table_insert(sequence, spell_str);
		
	elseif(template.type == "ReflectionShield") then
		-- get arrow position
		local arrow_position = caster:GetArrowPosition_id();
		local last_target_wards = target:GetWardsValue();
		if(System.options.version == "kids") then
			local ward;
			for ward in string.gmatch(template.params.wards, "([^,]+)") do
				-- first pop standing ward if exist
				target:PopStandingWardIfExist(tonumber(ward));
			end
			last_target_wards = target:GetWardsValue();
			for ward in string.gmatch(template.params.wards, "([^,]+)") do
				-- first pop standing ward if exist
				target:AppendStandingWard(tonumber(ward), template.params.rounds);
				last_target_wards = "0,"..last_target_wards;
			end
			target:AppendReflectionShield(tonumber(template.params.reflect_amount));
		else
			-- append reflection amount
			target:AppendReflectionShield(tonumber(template.params.reflect_amount));
			last_target_wards = "0,"..last_target_wards;
		end
		-- append threat
		local _, unit;
		for _, unit in ipairs(hostiles) do
			if(unit.isMob) then
				local mob = Mob.GetMobByID(unit.id);
				if(mob and mob:IsAlive()) then
					local base_threat = GetEffectThreat("reflectionshield");
					if((target:IsMob() == mob:IsMob()) and (target:GetID() == mob:GetID())) then
						mob:AppendThreat(caster, base_threat);
					else
						mob:AppendThreat(caster, math.ceil(base_threat * splash_manipulation_threat_ratio));
					end
				end
			end
		end
		local spell_str = "";
		spell_str = format("%s:%s,%d,%d,%s,%s,%d,%s,%s,%d,%d,%d#%s#%s#%s#%s#%s#%s#%s#%s", 
			spell_name, 
			key, 
			arena:GetID(), 
			arrow_position, 
			tostring(caster_data.isMob), 
			caster_data.id, 
			caster:GetArrowPosition_id(), 
			tostring(target_data.isMob), 
			target_data.id,
			target:GetArrowPosition_id(), 
			0, 0, 
			caster:GetCharmsValue(), caster:GetCharmsValue(), 
			target:GetCharmsValue(), target:GetCharmsValue(), 
			last_target_wards, target:GetWardsValue(), 
			target:GetOverTimeValue(), target:GetOverTimeValue()
		);
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname(spell_name);
		-- update arena
		local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
		spell_str = format("update_arena:%s+%s", key, value);
		table_insert(sequence, spell_str);

	elseif(template.type == "Wards") then
		-- get arrow position
		local arrow_position = caster:GetArrowPosition_id();
		local last_target_wards = target:GetWardsValue();
		local ward;
		for ward in string.gmatch(template.params.wards, "([^,]+)") do
			target:AppendWard(tonumber(ward));
			last_target_wards = "0,"..last_target_wards;
		end
		-- append threat
		local _, unit;
		for _, unit in ipairs(hostiles) do
			if(unit.isMob) then
				local mob = Mob.GetMobByID(unit.id);
				if(mob and mob:IsAlive()) then
					local base_threat = GetEffectThreat("wards");
					if((target:IsMob() == mob:IsMob()) and (target:GetID() == mob:GetID())) then
						mob:AppendThreat(caster, base_threat);
					else
						mob:AppendThreat(caster, math.ceil(base_threat * splash_manipulation_threat_ratio));
					end
				end
			end
		end
		local spell_str = "";
		spell_str = format("%s:%s,%d,%d,%s,%s,%d,%s,%s,%d,%d,%d#%s#%s#%s#%s#%s#%s#%s#%s", 
			spell_name, 
			key, 
			arena:GetID(), 
			arrow_position, 
			tostring(caster_data.isMob), 
			caster_data.id, 
			caster:GetArrowPosition_id(), 
			tostring(target_data.isMob), 
			target_data.id,
			target:GetArrowPosition_id(), 
			0, 0, 
			caster:GetCharmsValue(), caster:GetCharmsValue(), 
			target:GetCharmsValue(), target:GetCharmsValue(), 
			last_target_wards, target:GetWardsValue(), 
			target:GetOverTimeValue(), target:GetOverTimeValue()
		);
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname(spell_name);
		-- update arena
		local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
		spell_str = format("update_arena:%s+%s", key, value);
		table_insert(sequence, spell_str);
		
	elseif(template.type == "StandingWards") then
		-- get arrow position
		local arrow_position = caster:GetArrowPosition_id();
		local last_target_wards = target:GetWardsValue();
		local ward;
		for ward in string.gmatch(template.params.wards, "([^,]+)") do
			-- first pop standing ward if exist
			target:PopStandingWardIfExist(tonumber(ward));
		end
		last_target_wards = target:GetWardsValue();
		for ward in string.gmatch(template.params.wards, "([^,]+)") do
			-- first pop standing ward if exist
			target:AppendStandingWard(tonumber(ward), template.params.rounds);
			last_target_wards = "0,"..last_target_wards;
		end
		-- append threat
		local _, unit;
		for _, unit in ipairs(hostiles) do
			if(unit.isMob) then
				local mob = Mob.GetMobByID(unit.id);
				if(mob and mob:IsAlive()) then
					local base_threat = GetEffectThreat("wards");
					if((target:IsMob() == mob:IsMob()) and (target:GetID() == mob:GetID())) then
						mob:AppendThreat(caster, base_threat);
					else
						mob:AppendThreat(caster, math.ceil(base_threat * splash_manipulation_threat_ratio));
					end
				end
			end
		end
		local spell_str = "";
		spell_str = format("%s:%s,%d,%d,%s,%s,%d,%s,%s,%d,%d,%d#%s#%s#%s#%s#%s#%s#%s#%s", 
			spell_name, 
			key, 
			arena:GetID(), 
			arrow_position, 
			tostring(caster_data.isMob), 
			caster_data.id, 
			caster:GetArrowPosition_id(), 
			tostring(target_data.isMob), 
			target_data.id,
			target:GetArrowPosition_id(), 
			0, 0, 
			caster:GetCharmsValue(), caster:GetCharmsValue(), 
			target:GetCharmsValue(), target:GetCharmsValue(), 
			last_target_wards, target:GetWardsValue(), 
			target:GetOverTimeValue(), target:GetOverTimeValue()
		);
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname(spell_name);
		-- update arena
		local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
		spell_str = format("update_arena:%s+%s", key, value);
		table_insert(sequence, spell_str);
		
	elseif(template.type == "GainPips") then
		-- get arrow position
		local arrow_position = caster:GetArrowPosition_id();

		local pips = template.params.pips;
		if(pips) then
			local _ = 1;
			for _ = 1, pips do
				target:GeneratePip(nil, true);
			end
		end

		local powerpips = template.params.powerpips;
		if(powerpips) then
			local _ = 1;
			for _ = 1, powerpips do
				target:GeneratePip(true);
			end
		end

		-- append threat
		local _, unit;
		for _, unit in ipairs(hostiles) do
			if(unit.isMob) then
				local mob = Mob.GetMobByID(unit.id);
				if(mob and mob:IsAlive()) then
					local base_threat = GetEffectThreat("wards");
					if((target:IsMob() == mob:IsMob()) and (target:GetID() == mob:GetID())) then
						mob:AppendThreat(caster, base_threat);
					else
						mob:AppendThreat(caster, math.ceil(base_threat * splash_manipulation_threat_ratio));
					end
				end
			end
		end
		local spell_str = "";
		spell_str = format("%s:%s,%d,%d,%s,%s,%d,%s,%d,%s,%d,%d#%s#%s#%s#%s#%s#%s#%s#%s", 
			spell_name, 
			key, 
			arena:GetID(), 
			arrow_position, 
			tostring(caster_data.isMob), 
			caster_data.id, 
			caster:GetArrowPosition_id(), 
			tostring(target_data.isMob), 
			target_data.id,
			target:GetArrowPosition_id(), 
			0, 0, 
			caster:GetCharmsValue(), caster:GetCharmsValue(), 
			target:GetCharmsValue(), target:GetCharmsValue(), 
			target:GetWardsValue(), target:GetWardsValue(), 
			target:GetOverTimeValue(), target:GetOverTimeValue()
		);
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname(spell_name);
		-- update arena
		local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
		spell_str = format("update_arena:%s+%s", key, value);
		table_insert(sequence, spell_str);
		
	elseif(template.type == "SymmetryWards") then
		-- get arrow position
		local arrow_position = caster:GetArrowPosition_id();
		local last_target_wards = target:GetWardsValue();
		local last_caster_wards = caster:GetWardsValue();
		local ward;
		for ward in string.gmatch(template.params.target_wards, "([^,]+)") do
			target:AppendWard(tonumber(ward));
			last_target_wards = "0,"..last_target_wards;
		end
		for ward in string.gmatch(template.params.caster_wards, "([^,]+)") do
			caster:AppendWard(tonumber(ward));
			last_caster_wards = "0,"..last_caster_wards;
		end
		-- append threat
		local _, unit;
		for _, unit in ipairs(hostiles) do
			if(unit.isMob) then
				local mob = Mob.GetMobByID(unit.id);
				if(mob and mob:IsAlive()) then
					local base_threat = GetEffectThreat("symmetrywards");
					if((target:IsMob() == mob:IsMob()) and (target:GetID() == mob:GetID())) then
						mob:AppendThreat(caster, base_threat);
					else
						mob:AppendThreat(caster, math.ceil(base_threat * splash_manipulation_threat_ratio));
					end
				end
			end
		end
		local spell_str = "";
		spell_str = format("%s:%s,%d,%d,%s,%s,%d,%s,%s,%d,%d,%d#%s#%s#%s#%s#%s#%s#%s#%s", 
			spell_name, 
			key, 
			arena:GetID(), 
			arrow_position, 
			tostring(caster_data.isMob), 
			caster_data.id, 
			caster:GetArrowPosition_id(), 
			tostring(target_data.isMob), 
			target_data.id,
			target:GetArrowPosition_id(), 
			0, 0, 
			caster:GetCharmsValue(), caster:GetCharmsValue(), 
			target:GetCharmsValue(), target:GetCharmsValue(), 
			last_target_wards, target:GetWardsValue(), 
			target:GetOverTimeValue(), target:GetOverTimeValue()
		);
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname(spell_name);
		-- update arena
		local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
		spell_str = format("update_arena:%s+%s", key, value);
		table_insert(sequence, spell_str);
		
	elseif(template.type == "AreaWard" or template.type == "AreaAbsorb") then
		-- record each targets
		local targets = {};
		-- collect all information to the targets and buffs
		local pickedSide;
		local lower_region;
		local upper_region;
		if(target_data.isMob == true) then
			pickedSide = "far";
			lower_region = 5;
			upper_region = 8;
		elseif(target_data.isMob == false) then
			pickedSide = "near";
			lower_region = 1;
			upper_region = 4;
		end
		if(pickedSide and lower_region and upper_region) then
			local i;
			for i = lower_region, upper_region do
				local unit = arena:GetCombatUnitBySlotID(i);
				if(unit and unit:IsAlive() and unit:IsCombatActive()) then
					table_insert(targets, unit);
				end
			end
		end

		local absorb_pts;
		if(template.type == "AreaAbsorb") then
			absorb_pts = Card.GetNumericalValueFromSection(template.params.absorb_pts, pips_realcost) or 0;
		end
		targets = Card.GetCardTargets(template.target,friendlys,hostiles) or targets;
		-- damage blocks
		local ismob_id_blocks = "";

		-- append each target charm
		local ward = template.params.ward;
		local owner_ward,other_ward;
		local absorb_pts_owner,absorb_pts_other;
		if(System.options.version == "kids" and template.type == "AreaAbsorb") then
			owner_ward = ward;
			other_ward = template.params.other_ward or ward;
			absorb_pts_owner = absorb_pts;
			local other_ward_template = Card.GetWardTemplate(other_ward)
			local other_absorb_scale = tonumber(other_ward_template.absorb_scale or 100);
			absorb_pts_other = absorb_pts_owner * other_absorb_scale * 0.01;
		end
		local i;
		for i = 1, #targets do
			local each_target = targets[i];
			local last_target_wards = each_target:GetWardsValue();
			if(template.type == "AreaAbsorb") then
				if(System.options.version == "teen") then
					each_target:AppendAbsorb(absorb_pts, tonumber(template.params.ward));
				elseif(System.options.version == "kids") then
					if(caster:GetID() == each_target:GetID()) then
						each_target:AppendAbsorb(absorb_pts_owner, tonumber(owner_ward));
					else
						each_target:AppendAbsorb(absorb_pts_other, tonumber(other_ward));
					end
				end
				
			end
			if(template.type == "AreaWard") then
				each_target:AppendWard(ward);
			end			
			last_target_wards = "0,"..last_target_wards;
			local ismob_id = "";
			ismob_id = format("(%s,%s,%d,0#%s#%s#%s#%s#%s#%s)", tostring(each_target:IsMob()), each_target:GetID(), each_target:GetArrowPosition_id(), 
				each_target:GetCharmsValue(), each_target:GetCharmsValue(), last_target_wards, each_target:GetWardsValue(), each_target:GetOverTimeValue(), each_target:GetOverTimeValue());
			ismob_id_blocks = ismob_id_blocks..ismob_id;
		end
		
		-- append threat
		local _, unit;
		for _, unit in ipairs(hostiles) do
			if(unit.isMob) then
				local mob = Mob.GetMobByID(unit.id);
				if(mob and mob:IsAlive()) then
					mob:AppendThreat(caster, GetEffectThreat("areaward"));
				end
			end
		end

		-- get arrow position
		local arrow_position = caster:GetArrowPosition_id();
		
		-- append spell play
		local spell_str = "";
		spell_str = format("%s:%s,%d,%d,%s,%s+%s+%s+%s", spell_name, key, arena:GetID(), arrow_position, tostring(caster_data.isMob), caster_data.id, caster:GetCharmsValue(), caster:GetCharmsValue(), ismob_id_blocks);
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname(spell_name);
		-- update arena
		local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
		spell_str = format("update_arena:%s+%s", key, value);
		table_insert(sequence, spell_str);
	end
	return true, pips_realcost;
end

-- post use card of player or mob
-- @param key: card key name
-- @param arena: arena object
-- @param caster_data: {isMob, id}
-- @param target_data: {isMob, id}
-- @param sequence: spell play sequence of the turn, each spell play is appended to the table
-- @return: true for successfully cast, false for fizzle or not success or pass or dead before cast
function Card.UseCard_post(key, arena, caster_data, target_data, sequence, original_key)
	-- card template
	local template = Card.GetCardTemplate(key)
	if(not template) then
		log("error: invalid template key:"..tostring(key).." got in function Card.UseCard\n")
		return false;
	end

	-- caster and target object
	local caster, target;
	if(caster_data.isMob == true) then
		caster = Mob.GetMobByID(caster_data.id);
	elseif(caster_data.isMob == false) then
		caster = Player.GetPlayerCombatObj(caster_data.id);
	end
	if(target_data.isMob == true) then
		target = Mob.GetMobByID(target_data.id);
	elseif(target_data.isMob == false) then
		target = Player.GetPlayerCombatObj(target_data.id);
	end

	if(not caster) then
		log("error: invalid caster("..tostring(caster)..") got in function Card.UseCard\n")
		return false;
	end

	local friendlys, hostiles = arena:GetFriendlyAndHostileUnits(caster:GetSide());

	-- check revival guardian
	local i;
	for i = 1, 8 do
		local unit = arena:GetCombatUnitBySlotID(i);
		if(unit and not unit:IsAlive() and unit.bWithGuardian and unit:IsCombatActive()) then
			-- append revive
			local spell_str = "";
			local arrow_position = unit:GetArrowPosition_id();
			spell_str = format("revive:%d,%d,%s,%s", arena:GetID(), arrow_position, tostring(unit:IsMob()), unit:GetID());
			table_insert(sequence, spell_str);
			sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Revive");
			-- revive unit
			unit:Revive();
			-- update arena
			local key, value = arena:GetKey_normal_update(), arena:GetValue_normal_update();
			spell_str = format("update_arena:%s+%s", key, value);
			table_insert(sequence, spell_str);
			-- append revive post
			local spell_str = "";
			local arrow_position = unit:GetArrowPosition_id();
			spell_str = format("revive_post:%d,%d,%s,%s", arena:GetID(), arrow_position, tostring(unit:IsMob()), unit:GetID());
			table_insert(sequence, spell_str);
			sequence.duration = sequence.duration + Card.GetSpellDuration_from_card_spellname("Revive_Post");
		end
	end

	return false;
end

function Card.UserMiniAuraFromServer(target,key)
	local template = Card.GetCardTemplate(key);
	if(not template) then
		log("error: invalid template key:"..tostring(key).." got in function Card.UseCard\n")
		return false;
	end
	local mini_aura_id = template.params.miniaura;
	local rounds = template.params.rounds;
	target:SetMiniAura(tonumber(mini_aura_id), tonumber(rounds));
	--player:SetMiniAura(1, 2);		
end