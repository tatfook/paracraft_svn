--[[
Title: combat system mob server for Aries App
Author(s): WangTian
Date: 2009/4/7
Area: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Combat/ServerObject/mob_server.lua");
------------------------------------------------------------
]]
local format = format;

-- create class
local libName = "AriesCombat_Server_Mob";
local Mob = commonlib.gettable("MyCompany.Aries.Combat_Server.Mob");
local Card = commonlib.gettable("MyCompany.Aries.Combat_Server.Card");
-- arena class
local Arena = commonlib.gettable("MyCompany.Aries.Combat_Server.Arena");
-- player class
local Player = commonlib.gettable("MyCompany.Aries.Combat_Server.Player");

NPL.load("(gl)script/kids/3DMapSystemItem/PowerItemManager.lua");
local PowerItemManager = commonlib.gettable("Map3DSystem.Item.PowerItemManager");

local LOG = LOG;
local string_format = string.format;
local table_insert = table.insert;
local string_lower = string.lower;
local math_ceil = math.ceil;

-- base mob id
local base_mob_id = 50001;

-- all mobs
local mobs = {};

-- max mob pip count
local maximum_mob_pips_count = 7;

-- reflection shield id
local reflection_shield_id = 54;

-- Ice_DefensiveStance ward id
local ice_defensivestance_ward_id = 58;
-- Storm_SingleStealth ward id
local storm_singlestealth_ward_id = 59;
-- Balance_Rune_AreaControl_Devil ward id
local balance_rune_areacontrol_devil_ward_id = 68;
-- Balance_Rune_TauntStance charm id
local balance_tauntstance_charm_id = 36;

-- 5 new stance ward id
local life_healingstance_ward_id = 69;
local fire_blazingstance_ward_id = 70;
local storm_electricstance_ward_id = 71;
local death_vampirestance_ward_id = 72;
local ice_piercestance_ward_id = 73;

-- 5 new stance ward id
local fire_stance_kids_ward_id = 81;
local ice_stance_kids_ward_id = 82;
local storm_stance_kids_ward_id = 83;
local life_stance_kids_ward_id = 84;
local death_stance_kids_ward_id = 85;

-- storm electric stance mode
local storm_electricstance_even_mode_ward_id = 74;
local storm_electricstance_odd_mode_ward_id = 75;

-- ice piercestance buff ward_id
local ice_piercestance_buff_ward_id = 76;

-- Death_SingleGuardianWithImmolate charm id
local death_singleguardianwithimmolate_charm_id = 30;

-- global mob exp bonus
local global_exp_bonus = 2;

-- max mob resist
local MAX_MOB_RESIST_PERCENT = 99;

-- base hp after unit revive
local REVIVE_BASE_HP = 500;

-- all mob templates
local MobTemplate = {};
MobTemplate.templates = MobTemplate.templates or {};

-- init the player constants if not
local bInitConstants = false;
function Mob.InitConstantsIfNot()
	if(not bInitConstants) then
		if(System.options.version == "teen") then
			maximum_mob_pips_count = 14;
			REVIVE_BASE_HP = 525;
		else
			maximum_mob_pips_count = 7;
			REVIVE_BASE_HP = 2000;
		end
	end
	bInitConstants = true;
end

function Mob.ClearTemplates()
	MobTemplate.templates = {};
end

local locale_word_groups = {};
-- init locale word for current locale
function Mob.InitLocaleWord(locale)
	local locale_file = nil;
	if(locale == "zhTW") then
		locale_file = "config/Aries/Mob_Teen/Locale/wordkey.zhTW.txt";
	elseif(locale == "thTH") then
		locale_file = "config/Aries/Mob_Teen/Locale/wordkey.thTH.txt";
	end
	if(locale_file) then
		local file = ParaIO.open(locale_file, "r");
		if(file:IsValid() == true) then
			LOG.std(nil, "info", "mob_server", "server loaded locale word file %s", locale_file);
			-- read a line 
			local line = file:readline();
			while(line) do
				--badwords[line] = true;
				local mob_file, original_word, trans_word = string.match(line, "^(.-)||(.-)||(.-)||");
				if(mob_file and original_word and trans_word) then
					mob_file = string.lower(mob_file);
					locale_word_groups[mob_file] = locale_word_groups[mob_file] or {};
					locale_word_groups[mob_file][original_word] = trans_word;
				end
				line = file:readline();
			end
			file:close();
		else
			LOG.std(nil, "error", "mob_server", "server filed to read locale word file %s", locale_file);
		end
	end
end

-- get translation word from original word
function Mob.GetTransWordFromOriginalWord(mob_file, original_word)
	if(mob_file and original_word) then
		mob_file = string.lower(mob_file);
		local group = locale_word_groups[mob_file];
		if(group) then
			return group[original_word];
		end
	end
end

-- init the global card loot if not
local GlobalCardLoot = nil;
function Mob.InitGlobalCardLootIfNot()
	if(not GlobalCardLoot) then
		if(true) then
			GlobalCardLoot = {};
			local path_GlobalCardLootConfig = "config/Aries/GlobalCardLoot.teen.xml";
			if(System.options.version == "kids") then
				path_GlobalCardLootConfig = "config/Aries/GlobalCardLoot.xml";
			end
			local xmlRoot = ParaXML.LuaXML_ParseFile(path_GlobalCardLootConfig);
			if(not xmlRoot) then
				LOG.std(nil, "error", "combatmob", "failed loading GlobalCardLoot config file");
				return;
			end
			-- fetch all global card loot configs
			local loot;
			for loot in commonlib.XPath.eachNode(xmlRoot, "/globalcardloot/loot") do
				-- parse all global card loot
				if(loot and loot.attr) then
					local priority = tonumber(loot.attr.priority or "1") or 1;
					local level_from = 0;
					local level_to = 0;
					local level = loot.attr.level;
					if(level) then
						local from, to = string.match(level, "^%[(.-),(.-)%]$")
						if(from and to) then
							from = tonumber(from);
							to = tonumber(to);
							if(from and to) then
								level_from = from;
								level_to = to;
							end
						end
					end
					local school = loot.attr.school or "all";
					local rarity = loot.attr.rarity or "normal";
					-- each loot rules
					table.insert(GlobalCardLoot, {
						priority = priority,
						level_from = level_from,
						level_to = level_to,
						school = school,
						rarity = rarity,
						roll_card_easy = loot.attr.roll_card_easy,
						roll_card = loot.attr.roll_card,
						roll_card_hard = loot.attr.roll_card_hard,
						roll_card_hero = loot.attr.roll_card_hero,
						roll_card_nightmare = loot.attr.roll_card_nightmare,
					});
				end
			end
			-- sort loots high priority comes first
			table.sort(GlobalCardLoot, function(a, b) return a.priority > b.priority; end);
		else
			-- don't apply global card loot for kids version
			GlobalCardLoot = {};
		end
	end
end

-- init the global item loot if not
local GlobalItemLoot = nil;
function Mob.InitGlobalItemLootIfNot()
	if(not GlobalItemLoot) then
		if(System.options.version == "teen") then
			GlobalItemLoot = {};
			local path_GlobalItemLootConfig = "config/Aries/GlobalItemLoot.teen.xml";
			local xmlRoot = ParaXML.LuaXML_ParseFile(path_GlobalItemLootConfig);
			if(not xmlRoot) then
				LOG.std(nil, "error", "combatmob", "failed loading GlobalItemLoot config file");
				return;
			end
			-- fetch all global card loot configs
			local loot;
			for loot in commonlib.XPath.eachNode(xmlRoot, "/globalitemloot/loot") do
				-- parse all global card loot
				if(loot and loot.attr) then
					local priority = tonumber(loot.attr.priority or "1") or 1;
					local level_from = 0;
					local level_to = 0;
					local level = loot.attr.level;
					if(level) then
						local from, to = string.match(level, "^%[(.-),(.-)%]$")
						if(from and to) then
							from = tonumber(from);
							to = tonumber(to);
							if(from and to) then
								level_from = from;
								level_to = to;
							end
						end
					end
					local school = loot.attr.school or "all";
					local rarity = loot.attr.rarity or "normal";
					-- each loot rules
					table.insert(GlobalItemLoot, {
						priority = priority,
						level_from = level_from,
						level_to = level_to,
						school = school,
						rarity = rarity,
						roll_item_easy = loot.attr.roll_item_easy,
						roll_item = loot.attr.roll_item,
						roll_item_hard = loot.attr.roll_item_hard,
						roll_item_hero = loot.attr.roll_item_hero,
						roll_item_nightmare = loot.attr.roll_item_nightmare,
					});
				end
			end
			-- sort loots high priority comes first
			table.sort(GlobalItemLoot, function(a, b) return a.priority > b.priority; end);
		else
			-- don't apply global item loot for kids version
			GlobalItemLoot = {};
		end
	end
end

-- init the enrage loot if not
local EnrageLoot = nil;
function Mob.InitEnrageLootIfNot()
	if(not EnrageLoot) then
		EnrageLoot = {};
		local path_EnrageLootConfig = "";
		if(System.options.version == "kids") then
			path_EnrageLootConfig = "config/Aries/EnrageLoot.xml";
		elseif(System.options.version == "teen") then
			path_EnrageLootConfig = "config/Aries/EnrageLoot.teen.xml";
		end
		local xmlRoot = ParaXML.LuaXML_ParseFile(path_EnrageLootConfig);
		if(not xmlRoot) then
			LOG.std(nil, "error", "combatmob", "failed loading EnrageLoot config file: "..tostring(path_EnrageLootConfig));
			return;
		end
		-- fetch all global card loot configs
		local loot;
		for loot in commonlib.XPath.eachNode(xmlRoot, "/EnrageLoot/loot") do
			-- parse enrage loot
			if(loot and loot.attr) then
				local key = loot.attr.key;
				-- each loot rules
				EnrageLoot[key] = {
					loot1_enrage_easy = loot.attr.loot1_enrage_easy,
					loot1_enrage = loot.attr.loot1_enrage,
					loot1_enrage_hard = loot.attr.loot1_enrage_hard,
					loot1_enrage_hero = loot.attr.loot1_enrage_hero,
					loot1_enrage_nightmare = loot.attr.loot1_enrage_nightmare,
					loot2_enrage_easy = loot.attr.loot2_enrage_easy,
					loot2_enrage = loot.attr.loot2_enrage,
					loot2_enrage_hard = loot.attr.loot2_enrage_hard,
					loot2_enrage_hero = loot.attr.loot2_enrage_hero,
					loot2_enrage_nightmare = loot.attr.loot2_enrage_nightmare,
					loot3_enrage_easy = loot.attr.loot3_enrage_easy,
					loot3_enrage = loot.attr.loot3_enrage,
					loot3_enrage_hard = loot.attr.loot3_enrage_hard,
					loot3_enrage_hero = loot.attr.loot3_enrage_hero,
					loot3_enrage_nightmare = loot.attr.loot3_enrage_nightmare,
				};
			end
		end
	end
end

-- init the enrage stats if not
local EnrageStats = nil;
function Mob.InitEnrageStatsIfNot()
	if(not EnrageStats) then
		EnrageStats = {};
		local path_EnrageStatsConfig = "";
		if(System.options.version == "kids") then
			path_EnrageStatsConfig = "config/Aries/EnrageStats.xml";
		elseif(System.options.version == "teen") then
			path_EnrageStatsConfig = "config/Aries/EnrageStats.teen.xml";
		end
		local xmlRoot = ParaXML.LuaXML_ParseFile(path_EnrageStatsConfig);
		if(not xmlRoot) then
			LOG.std(nil, "error", "combatmob", "failed loading EnrageStats config file: "..tostring(path_EnrageStatsConfig));
			return;
		end
		-- fetch all enrage stats group configs
		local base_stats_groups = {};
		local each_group;
		for each_group in commonlib.XPath.eachNode(xmlRoot, "/EnrageStats/stats_groups/group") do
			-- parse each stats group
			if(each_group and each_group.attr and each_group.attr.key) then
				local key = each_group.attr.key;
				local this_stats = {};
				local this_key, this_value;
				for this_key, this_value in pairs(each_group.attr) do
					if(key ~= "key") then
						this_stats[this_key] = tonumber(this_value) or this_value;
					end
				end
				base_stats_groups[key] = this_stats;
			end
		end
		-- make each mob enrage group configs
		local each_mob_group;
		for each_mob_group in commonlib.XPath.eachNode(xmlRoot, "/EnrageStats/mob_groups/group") do
			-- parse each stats group
			if(each_mob_group and each_mob_group.attr and each_mob_group.attr.key and each_mob_group.attr.stats_group_keys) then
				local key = each_mob_group.attr.key;
				local stats_group_keys = each_mob_group.attr.stats_group_keys;
				local this_stats = {};
				local each_group_key;
				for each_group_key in string.gmatch(stats_group_keys, "[^~]+") do
					-- mob_group stats_group_keys right key stats overwrites the left key stats
					if(base_stats_groups[each_group_key]) then
						local this_key, this_value;
						for this_key, this_value in pairs(base_stats_groups[each_group_key]) do
							this_stats[this_key] = this_value;
						end
					end
				end
				EnrageStats[key] = this_stats;
			end
		end
	end
end

-- init the enrage AI cards if not
local EnrageAICards = nil;
function Mob.InitEnrageAICardsIfNot()
	if(not EnrageAICards) then
		EnrageAICards = {};
		local path_EnrageAICardsConfig = "";
		if(System.options.version == "kids") then
			path_EnrageAICardsConfig = "config/Aries/EnrageAICards.xml";
		else
			path_EnrageAICardsConfig = "config/Aries/EnrageAICards.teen.xml";
		end
		local xmlRoot = ParaXML.LuaXML_ParseFile(path_EnrageAICardsConfig);
		if(not xmlRoot) then
			LOG.std(nil, "error", "combatmob", "failed loading EnrageAICards config file: "..tostring(path_EnrageAICardsConfig));
			return;
		end
		-- fetch all enrage ai cards templates
		local each_template;
		for each_template in commonlib.XPath.eachNode(xmlRoot, "/EnrageAICards/template") do
			-- parse each stats group
			if(each_template and each_template.attr and each_template.attr.name) then
				local key_name = each_template.attr.name;
				local template_data = {};
				local each_mob_template;
				for each_mob_template in commonlib.XPath.eachNode(each_template, "/mobtemplate") do
					if(each_mob_template and each_mob_template.attr) then
						local template_available_cards = each_mob_template.attr.available_cards;
						MobTemplate.ReadFrom_available_cards(template_available_cards, template_data);
					end
				end
				-- template card sets
				template_data.cardsets = {};
				MobTemplate.ReadFrom_cardsets(each_template, template_data.cardsets);
				-- template ai sets
				template_data.aisets = {};
				MobTemplate.ReadFrom_aisets(each_template, template_data.aisets);
				-- template genes
				template_data.sequences = {};
				template_data.sequences_bonus_round_before = {};
				template_data.sequences_bonus_round_after = {};
				MobTemplate.ReadFrom_sequences(each_template, template_data.sequences, template_data.sequences_bonus_round_before, template_data.sequences_bonus_round_after, path_EnrageAICardsConfig);
				-- template genes
				template_data.genes = {};
				MobTemplate.ReadFrom_genes(each_template, template_data.genes, path_EnrageAICardsConfig);
				-- full template data for key_name
				EnrageAICards[key_name] = template_data;
			end
		end
	end
end

-- constructor
-- @param o: typical mob params including:
--			mob_template
function Mob:new(mob_node, explicitXMLRoot)
	-- init the player constants if not
	Mob.InitConstantsIfNot();
	-- init the global card loot if not
	Mob.InitGlobalCardLootIfNot();
	-- init the global item loot if not
	Mob.InitGlobalItemLootIfNot();
	-- init the enrage stats if not
	Mob.InitEnrageStatsIfNot();
	-- init the enrage AI cards if not
	Mob.InitEnrageAICardsIfNot();
	-- init the enrage loot if not
	Mob.InitEnrageLootIfNot();
	-- mob object
	local o = {}; -- new table
	if(not mob_node.attr or not mob_node.attr.mob_template) then
		LOG.std(nil, "error", "combatmob", "template not provided in mob attributes, node:"..commonlib.serialize(mob_node));
		return;
	end
	-- set mob template if available
	if(mob_node.attr.mob_template) then
		local template_key = mob_node.attr.mob_template;
		local template = MobTemplate.GetTemplate(template_key);
		if(not template) then
			-- create mob template if not exist
			local mobTemplate = MobTemplate:new(template_key, explicitXMLRoot);
			if(not mobTemplate) then
				LOG.std(nil, "error", "combatmob", "mobTemplate create fail, template_key:"..tostring(template_key));
				return;
			end
		end
		o.template_key = template_key;
		o.id = base_mob_id;
		base_mob_id = base_mob_id + 1;
	end

	setmetatable(o, self);
	self.__index = self;
	-- DOTs and HOTs
	o.DOTs = {};
	o.HOTs = {};
	-- charms and wards
	o.charms = {};
	o.wards = {};
	o.absorbs = {};
	-- NOTE: standing effect always have a lasting round, not a single round effect and last forever if not triggered
	-- standing defects and buffs, corresponding to DOTs and HOTs
	o.standing_defects = {};
	o.standing_buffs = {};
	-- standing charms and wards
	o.standing_charms = {};
	o.standing_wards = {};
	-- mini aura
	o.miniaura = nil;
	o.miniaura_rounds = nil;
	-- stance
	o.stance = nil;
	o.stance_rounds = nil;
	-- stealth
	o.stealth = nil;
	o.stealth_rounds = nil;
	-- pierce freeze
	o.pierce_freeze_buffs = nil;
	o.pierce_freeze_rounds = nil;
	-- is stunned
	o.bStunned = false;
	-- is controlled
	o.control_rounds = 0;
	-- electric_rounds
	o.electric_rounds = 0;
	-- is with guardian
	o.bWithGuardian = false;
	-- is freeze
	o.freeze_rounds = 0;
	o.anti_freeze_rounds = 0;
	o.anti_freeze_rounds_sibling = 0;
	-- catched pet nid
	o.nid_catchpet = nil;
	-- enraged nid
	o.nid_enraged = nil;
	-- skip loot
	o.bSkipLoot = nil;
	-- reflection shield amount
	o.reflect_amount = 0;
	-- pips
	o.pips_normal = 0;
	o.pips_power = 0;
	-- threats
	o.threats = {};
	o.threats_pending = {};
	-- genes attacker memory
	o.genes_attacker_memory = {};
	-- deck attacker memory
	o.deck_attacker_memory = {};
	-- keep a mob reference
	mobs[o.id] = o;
	-- respawn the mob first
	o:Respawn();
	return o;
end

-- on destroy
function Mob:OnDestroy()
	-- remove mob
	mobs[self:GetID()] = nil;
end

-- get arena side
-- @return: near or far
function Mob:GetSide()
	return self.side;
end

-- get threat id, index into the threat list
-- NOTE: if the unit side is far, the range is still from 1 to 4, 
--		associated with the arena slot id from 5 to 8
-- @return: 1 to 4
function Mob:GetThreatID()
	if(not self.threat_id) then
		self.threat_id = math.mod((self.arrow_cast_position - 1), 4) + 1;
	end
	return self.threat_id;
end

-- get mob by id
function Mob.GetMobByID(id)
	return mobs[id];
end

-- get arrow position id on the arena 1 to 8
function Mob:GetArrowPosition_id()
	return self.arrow_cast_position;
end

-- respawn mob including:
--		reset mob hp
--		reset mob status
function Mob:Respawn()
	-- reset isFirstTurn
	self.isFirstTurn = nil;
	-- enraged nid
	-- NOTE 2012/1/28: reset enrage before setting current hp
	self.nid_enraged = nil;
	-- reset current hp to maximum
	self.current_hp = self:GetMaxHP();
	-- clear DOTs and HOTs
	self.DOTs = {};
	self.HOTs = {};
	-- clear charms and wards
	self.charms = {};
	self.wards = {};
	self.absorbs = {};
	-- clear standing defects and buffs
	self.standing_defects = {};
	self.standing_buffs = {};
	-- clear standing charms and wards
	self.standing_charms = {};
	self.standing_wards = {};
	-- mini aura
	self.miniaura = nil;
	self.miniaura_rounds = nil;
	-- stance
	self.stance = nil;
	self.stance_rounds = nil;
	-- stealth
	self.stealth = nil;
	self.stealth_rounds = nil;
	-- pierce freeze
	self.pierce_freeze_buffs = nil;
	self.pierce_freeze_rounds = nil;
	-- clear stunned
	self.bStunned = false;
	-- clear controlled
	self.control_rounds = 0;
	-- electric_rounds
	self.electric_rounds = 0;
	-- is with guardian
	self.bWithGuardian = false;
	-- clear freeze
	self.freeze_rounds = 0;
	self.anti_freeze_rounds = 0;
	self.anti_freeze_rounds_sibling = 0;
	-- catched pet nid
	self.nid_catchpet = nil;
	-- skip loot
	self.bSkipLoot = nil;
	-- reset shield amount
	self.reflect_amount = 0;
	-- reset pips
	self.pips_normal = 0;
	self.pips_power = 0;
	-- reset threats
	self.threats = {};
	self.threats_pending = {};
	-- reset genes attacker memory
	self.genes_attacker_memory = {};
	-- reset deck attacker memory
	self.deck_attacker_memory = {};
end

-- suicide mob including:
--		reset mob hp to 0
--		reset mob status
function Mob:Suicide()
	-- reset isFirstTurn
	self.isFirstTurn = nil;
	-- enraged nid
	-- NOTE 2012/1/28: reset enrage before setting current hp
	self.nid_enraged = nil;
	-- reset current hp to 0
	self.current_hp = 0;
	-- clear DOTs and HOTs
	self.DOTs = {};
	self.HOTs = {};
	-- clear charms and wards
	self.charms = {};
	self.wards = {};
	self.absorbs = {};
	-- clear standing defects and buffs
	self.standing_defects = {};
	self.standing_buffs = {};
	-- clear standing charms and wards
	self.standing_charms = {};
	self.standing_wards = {};
	-- mini aura
	self.miniaura = nil;
	self.miniaura_rounds = nil;
	-- stance
	self.stance = nil;
	self.stance_rounds = nil;
	-- stealth
	self.stealth = nil;
	self.stealth_rounds = nil;
	-- pierce freeze
	self.pierce_freeze_buffs = nil;
	self.pierce_freeze_rounds = nil;
	-- clear stunned
	self.bStunned = false;
	-- clear controlled
	self.control_rounds = 0;
	-- electric_rounds
	self.electric_rounds = 0;
	-- is with guardian
	self.bWithGuardian = false;
	-- clear freeze
	self.freeze_rounds = 0;
	self.anti_freeze_rounds = 0;
	self.anti_freeze_rounds_sibling = 0;
	-- catched pet nid
	self.nid_catchpet = nil;
	-- skip loot
	self.bSkipLoot = nil;
	-- reset shield amount
	self.reflect_amount = 0;
	-- reset pips
	self.pips_normal = 0;
	self.pips_power = 0;
	-- reset threats
	self.threats = {};
	self.threats_pending = {};
	-- reset genes attacker memory
	self.genes_attacker_memory = {};
	-- reset deck attacker memory
	self.deck_attacker_memory = {};
	
end

-- get normal update value, including:
--		id, asset, scale, hp, max_hp, pips, power_pips, charms, shields, dots
function Mob:GetValue_normal_update()
	local value = "";
	value = format("%s,%d,%d,%s,%d,%s,%s,%f,%s,%d,%d,%s,%d,%d#%s#%s#%s#%s#%s", 
		tostring(self:IsMob()),
		self:GetID(),
		self:GetArrowPosition_id(),
		self:GetDisplayName(),
		self:GetCatchPetGSID(),
		self:CanCatchPet_normalupdate_str()..self:GetPhase(), -- additional cancatchpet tag in phase field
		self:GetAssetFile(), 
		self:GetScale(), 
		self:GetTags(),
		self:GetCurrentHP(), 
		self:GetMaxHP(), 
		self:Rarity_normalupdate_str()..self:GetLevel(),
		self:GetPipsCount(), 
		self:GetPowerPipsCount(),
		self:GetCharmsValue(),
		self:GetWardsValue(),
		self:GetMiniAuraValue(),
		self:GetOverTimeValue(),
		self:GetThreatsValue()
	);
	return value;
end

-- get mob id
function Mob:GetID()
	return self.id;
end

-- get is mob
function Mob:IsMob()
	return true;
end

-- get is minion
function Mob:IsMinion()
	return false;
end

-- get is mob
function Mob:GetExp(loot_scale, player_level)

	if(System.options.version == "teen") then
		local mob_level = self:GetLevel() or 0;
		player_level = player_level or 0;
		if((player_level + 20) <= mob_level) then
			return 1;
		end
	end

	if(not loot_scale) then
		loot_scale = 1;
	elseif(loot_scale < 0 or loot_scale > 1) then
		loot_scale = 1;
	end
	if(System.options.version == "teen") then
		-- skip global experience bonus for teen version
		local experience_pts = math_ceil(tonumber(self:GetStatByField("experience_pts")) * loot_scale);
		local mob_level = self:GetLevel() or 0;
		player_level = player_level or 0;
		if(player_level and mob_level) then
			experience_pts = math_ceil(experience_pts * (1 - (player_level - mob_level) * 0.05));
			if(experience_pts <= 0) then
				experience_pts = 1;
			end
		end
		return experience_pts;
	else
		return math_ceil(tonumber(self:GetStatByField("experience_pts")) * global_exp_bonus * loot_scale);
	end
end

-- get mob joybean
function Mob:GetJoybean(loot_scale, player_level)
	
	if(System.options.version == "teen") then
		local mob_level = self:GetLevel() or 0;
		player_level = player_level or 0;
		if((player_level + 20) <= mob_level) then
			return 1;
		end
	end

	if(not loot_scale) then
		loot_scale = 1;
	elseif(loot_scale < 0 or loot_scale > 1) then
		loot_scale = 1;
	end

	local joybean_count = tonumber(self:GetStatByField("joybean_count"));
	if(joybean_count) then
		joybean_count = math_ceil(joybean_count * loot_scale);
		if(System.options.version == "teen") then
			local mob_level = self:GetLevel() or 0;
			player_level = player_level or 0;
			if(player_level and mob_level) then
				joybean_count = math_ceil(joybean_count * (1 - (player_level - mob_level) * 0.1));
			end
			if(joybean_count <= 0) then
				joybean_count = 1;
			end
		end
		return joybean_count;
	end
	
	return 2;
	--return tonumber(self:GetStatByField("joybean"));
end

-- get mob key
function Mob:GetKey()
	return self.template_key;
end

function Mob:GetTemplateKey()
	return self.template_key;
end

function Mob:GetDifficulty()
	return self.difficulty or "normal";
end

local available_loots = {
	["WaterBubble"] = {{30, 17114}, {10, 17131}},
	["DeathBubble"] = {{10, 17121}},
	["FireRockyOgre_01"] = {{10, 17132}},
	["TreeMonster"] = {{30, 17115}},
	["ForestSpikyOgreLower"] = {{10, 17122}},
	["ForestSpikyOgre"] = {{10, 1275}, {15, 17132}},
	["IronShell"] = {{10, 1276}, {10, 17123}},
	["IronBee"] = {{30, 17116}, {15, 1274}},
	["BlazeHairMonster"] = {{30, 17119}, {15, 1272}},
	["FireRockyOgre_02"] = {{15, 1273}},
	["GhostOctopus"] = {{20, 17117}},
	["GhostOctopus_Boss"] = {{10, 17133}},
	["PhoenixWarrior"] = {{20, 17123}},
	["RedCrabLower"] = {{30, 17120}},
	["RedCrab"] = {{10, 1311}},
	["EvilSnowman"] = {{20, 17118}},
	["IronBee_Boss"] = {{10, 17133}},
	["GreenDevouringRat"] = {{20, 17124}},
	["RedDevouringRat"] = {{10, 1333}},
	["ShadowOfPhoenix"] = {{10, 1322}},
	
	["SandScorpion"] = {{10, 17133}, {20, 17124}},
	["SandScorpion_Boss"] = {{10, 1356}, {5, 1344}, {10, 17124}},
	["StoneMonster"] = {{15, 17133}, {10, 17124}},
	["IceShrimpWarrior"] = {{15, 17133}, {15, 17124}},
	["DeadTreeMonster"] = {{10, 17134}},
	["FrostFang"] = {{15, 17124}},
	["FrostFang_Boss"] = {{10, 1357}, {10, 1345}},
	["UndeadMonkey"] = {{10, 17134}, {20, 17132}},
	["UndeadMonkey_Boss"] = {{10, 1368}, {10, 1357}, {15, 17134}},
	["ChillwindEagle"] = {{10, 17135}, {15, 17124}},
	["GreatIceBear"] = {{10, 1368}, {10, 1369}, {15, 17135}},


	--["ShadowSmashBull"] = {{10, 17119}, {15, 1272}},
	
	--["BlazeHairMonster"] = 6,
	--["StoneMonster"] = 6,
	--["ForestSpikyOgre"] = {20, 17117},
	--["DeadTreeMonster"] = 9,
	--["EvilSnowman"] = {20, 17118},
	--["IronShell"] = 11,
	--["SandScorpion"] = {10, 17119},
	--["RedCrab"] = {10, 17120},
	--["FireRockyOgre"] = 15,
	--["FireRockyOgre_02"] = 20,
};

function Mob:AppendSingleLootFromAttribute(attr_name, loots, loot_scale)
	local single_loots = self:GetStatByField(attr_name);
	if(single_loots) then
		-- get loot from mob template config
		local r = math.random(0, 10000);
		local loot_pair, chance;
		for loot_pair, chance in pairs(single_loots) do
			if(r < chance * 100) then
				local gsid, count = string.match(loot_pair, "^(.-),(.-)$")
				if(gsid and count) then
					gsid = tonumber(gsid);
					count = tonumber(count);
					count = math_ceil(count * loot_scale);
					if(gsid < 41000 or gsid > 44999) then
						local i;
						for i = 1, count do
							table.insert(loots, gsid);
						end
					end
				end
				break;
			else
				r = r - chance * 100;
			end
		end
	end
end

-- @param loots: in|out loot table, if nil, we will create one if there is loot. 
-- @param attr_name: if nil it is "shared_loot"
-- @return loots
function Mob:AppendSharedLootFromAttribute(attr_name, loots, loot_scale)
	local single_loots = self:GetStatByField(attr_name or "shared_loot");
	if(single_loots) then
		-- get loot from mob template config
		local r = math.random(0, 10000);
		local loot_pair, chance;
		for loot_pair, chance in pairs(single_loots) do
			if(r < chance * 100) then
				local gsid, count = string.match(loot_pair, "^(.-),(.-)$")
				if(gsid and count) then
					-- gsid = tonumber(gsid);
					count = tonumber(count);
					count = math_ceil(count * loot_scale);
					loots = loots or {}
					table.insert(loots, gsid);
				end
				if(chance < 100) then
					break;
				end
			else
				r = r - chance * 100;
			end
		end
	end
	return loots;
end

function Mob:AppendSingleLootFromRoll(attr_name, loots, loot_scale)
	local single_loots = self:GetStatByField(attr_name);
	if(single_loots) then
		-- get loot from mob template config
		local base_chance = single_loots.chance;
		if(base_chance) then
			-- base chance to gain roll
			local r = math.random(1, 10000);
			if(r > base_chance * 100) then
				return;
			end
			-- pick roll item with weight rather than percent
			local full_weight = single_loots.full_weight;
			if(not full_weight) then
				-- calculate the full weight for the first time
				full_weight = 0;
				local loot_pair, chance;
				for loot_pair, chance in pairs(single_loots) do
					if(loot_pair ~= "chance" and loot_pair ~= "full_weight") then
						full_weight = full_weight + chance;
					end
				end
				single_loots.full_weight = full_weight;
			end
			local r = math.random(0, full_weight * 10);
			local loot_pair, chance;
			for loot_pair, chance in pairs(single_loots) do
				if(loot_pair ~= "chance" and loot_pair ~= "full_weight") then
					if(r < chance * 10) then
						local gsid, count = string.match(loot_pair, "^(.-),(.-)$")
						if(gsid and count) then
							gsid = tonumber(gsid);
							count = tonumber(count);
							count = math_ceil(count * loot_scale);
							local i;
							for i = 1, count do
								table.insert(loots, gsid);
							end
						end
						break;
					else
						r = r - chance * 10;
					end
				end
			end
		end
	end
end

-- skip mob loot
function Mob:SkipLoot()
	self.bSkipLoot = true;
end

-- get mob loot
-- @params must_drop_gsid_if_available
-- @return local_loot, shared_loot: the shared_loot may nil nil or a table containing possible shared loot. 
function Mob:GetLoot(must_drop_gsid_if_available, loot_scale, nid, player_phase, player_level)
	
	if(self.bSkipLoot) then
		return {};
	end

	if(System.options.version == "teen") then
		local mob_level = self:GetLevel() or 0;
		player_level = player_level or 0;
		if((player_level + 20) <= mob_level) then
			return {};
		end
	end

	-- NOTE: only apply loot scale if loot_scale is 0
	if(not loot_scale) then
		loot_scale = 1;
	elseif(loot_scale ~= 0) then
		loot_scale = 1;
	end
	
	if(must_drop_gsid_if_available) then
		local loots1_str = self:GetStatByField_original("loot1");
		local loots2_str = self:GetStatByField_original("loot2");
		local loots3_str = self:GetStatByField_original("loot3");
		local loots4_str = self:GetStatByField_original("loot4");
		local loots5_str = self:GetStatByField_original("loot5");
		local loots6_str = self:GetStatByField_original("loot6");
		local loots7_str = self:GetStatByField_original("loot7");
		local loots8_str = self:GetStatByField_original("loot8");
		local loots9_str = self:GetStatByField_original("loot9");
		local loots10_str = self:GetStatByField_original("loot10");
		-- tricky code to find the string in the original loot config field
		if(loots1_str and string.find(loots1_str, "%["..must_drop_gsid_if_available..",")) then
			return {must_drop_gsid_if_available};
		end
		if(loots2_str and string.find(loots2_str, "%["..must_drop_gsid_if_available..",")) then
			return {must_drop_gsid_if_available};
		end
		if(loots3_str and string.find(loots3_str, "%["..must_drop_gsid_if_available..",")) then
			return {must_drop_gsid_if_available};
		end
		if(loots4_str and string.find(loots4_str, "%["..must_drop_gsid_if_available..",")) then
			return {must_drop_gsid_if_available};
		end
		if(loots5_str and string.find(loots5_str, "%["..must_drop_gsid_if_available..",")) then
			return {must_drop_gsid_if_available};
		end
		if(loots6_str and string.find(loots6_str, "%["..must_drop_gsid_if_available..",")) then
			return {must_drop_gsid_if_available};
		end
		if(loots7_str and string.find(loots7_str, "%["..must_drop_gsid_if_available..",")) then
			return {must_drop_gsid_if_available};
		end
		if(loots8_str and string.find(loots8_str, "%["..must_drop_gsid_if_available..",")) then
			return {must_drop_gsid_if_available};
		end
		if(loots9_str and string.find(loots9_str, "%["..must_drop_gsid_if_available..",")) then
			return {must_drop_gsid_if_available};
		end
		if(loots10_str and string.find(loots10_str, "%["..must_drop_gsid_if_available..",")) then
			return {must_drop_gsid_if_available};
		end
		
		local loots1_hard_str = self:GetStatByField_original("loot1_hard");
		local loots2_hard_str = self:GetStatByField_original("loot2_hard");
		local loots3_hard_str = self:GetStatByField_original("loot3_hard");
		local loots4_hard_str = self:GetStatByField_original("loot4_hard");
		local loots5_hard_str = self:GetStatByField_original("loot5_hard");
		local loots6_hard_str = self:GetStatByField_original("loot6_hard");
		local loots7_hard_str = self:GetStatByField_original("loot7_hard");
		local loots8_hard_str = self:GetStatByField_original("loot8_hard");
		local loots9_hard_str = self:GetStatByField_original("loot9_hard");
		local loots10_hard_str = self:GetStatByField_original("loot10_hard");
		-- tricky code to find the string in the original loot config field
		if(loots1_hard_str and string.find(loots1_hard_str, "%["..must_drop_gsid_if_available..",")) then
			return {must_drop_gsid_if_available};
		end
		if(loots2_hard_str and string.find(loots2_hard_str, "%["..must_drop_gsid_if_available..",")) then
			return {must_drop_gsid_if_available};
		end
		if(loots3_hard_str and string.find(loots3_hard_str, "%["..must_drop_gsid_if_available..",")) then
			return {must_drop_gsid_if_available};
		end
		if(loots4_hard_str and string.find(loots4_hard_str, "%["..must_drop_gsid_if_available..",")) then
			return {must_drop_gsid_if_available};
		end
		if(loots5_hard_str and string.find(loots5_hard_str, "%["..must_drop_gsid_if_available..",")) then
			return {must_drop_gsid_if_available};
		end
		if(loots6_hard_str and string.find(loots6_hard_str, "%["..must_drop_gsid_if_available..",")) then
			return {must_drop_gsid_if_available};
		end
		if(loots7_hard_str and string.find(loots7_hard_str, "%["..must_drop_gsid_if_available..",")) then
			return {must_drop_gsid_if_available};
		end
		if(loots8_hard_str and string.find(loots8_hard_str, "%["..must_drop_gsid_if_available..",")) then
			return {must_drop_gsid_if_available};
		end
		if(loots9_hard_str and string.find(loots9_hard_str, "%["..must_drop_gsid_if_available..",")) then
			return {must_drop_gsid_if_available};
		end
		if(loots10_hard_str and string.find(loots10_hard_str, "%["..must_drop_gsid_if_available..",")) then
			return {must_drop_gsid_if_available};
		end
	end

	local this_loots = {};
		
	-- added hard mode loot
	if(self:GetDifficulty() == "hard") then
		-- overwrite hard loot on normal loots for all versions
		self:AppendSingleLootFromAttribute("loot1_hard", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot2_hard", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot3_hard", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot4_hard", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot5_hard", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot6_hard", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot7_hard", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot8_hard", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot9_hard", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot10_hard", this_loots, loot_scale);
		self:AppendSingleLootFromRoll("roll_card_hard", this_loots, loot_scale);
		self:AppendSingleLootFromRoll("roll_item_hard", this_loots, loot_scale);
	elseif(self:GetDifficulty() == "easy") then
		-- overwrite easy loot on normal loots for all versions
		self:AppendSingleLootFromAttribute("loot1_easy", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot2_easy", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot3_easy", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot4_easy", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot5_easy", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot6_easy", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot7_easy", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot8_easy", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot9_easy", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot10_easy", this_loots, loot_scale);
		self:AppendSingleLootFromRoll("roll_card_easy", this_loots, loot_scale);
		self:AppendSingleLootFromRoll("roll_item_easy", this_loots, loot_scale);
	elseif(self:GetDifficulty() == "hero") then
		-- overwrite hero loot on normal loots for all versions
		self:AppendSingleLootFromAttribute("loot1_hero", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot2_hero", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot3_hero", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot4_hero", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot5_hero", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot6_hero", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot7_hero", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot8_hero", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot9_hero", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot10_hero", this_loots, loot_scale);
		self:AppendSingleLootFromRoll("roll_card_hero", this_loots, loot_scale);
		self:AppendSingleLootFromRoll("roll_item_hero", this_loots, loot_scale);
	elseif(self:GetDifficulty() == "nightmare") then
		-- overwrite nightmare loot on normal loots for all versions
		self:AppendSingleLootFromAttribute("loot1_nightmare", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot2_nightmare", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot3_nightmare", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot4_nightmare", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot5_nightmare", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot6_nightmare", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot7_nightmare", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot8_nightmare", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot9_nightmare", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot10_nightmare", this_loots, loot_scale);
		self:AppendSingleLootFromRoll("roll_card_nightmare", this_loots, loot_scale);
		self:AppendSingleLootFromRoll("roll_item_nightmare", this_loots, loot_scale);
	else
		-- get loot from mob template config
		self:AppendSingleLootFromAttribute("loot1", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot2", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot3", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot4", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot5", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot6", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot7", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot8", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot9", this_loots, loot_scale);
		self:AppendSingleLootFromAttribute("loot10", this_loots, loot_scale);
		self:AppendSingleLootFromRoll("roll_card", this_loots, loot_scale);
		self:AppendSingleLootFromRoll("roll_item", this_loots, loot_scale);
	end
	
	-- append enrage loot
	local enrage_nid = self:GetEnragePlayerNID();
	if(enrage_nid and enrage_nid == nid) then
		if(self:GetDifficulty() == "hard") then
			self:AppendSingleLootFromAttribute("loot1_enrage_hard", this_loots, loot_scale);
			self:AppendSingleLootFromAttribute("loot2_enrage_hard", this_loots, loot_scale);
			self:AppendSingleLootFromAttribute("loot3_enrage_hard", this_loots, loot_scale);
		elseif(self:GetDifficulty() == "easy") then
			self:AppendSingleLootFromAttribute("loot1_enrage_easy", this_loots, loot_scale);
			self:AppendSingleLootFromAttribute("loot2_enrage_easy", this_loots, loot_scale);
			self:AppendSingleLootFromAttribute("loot3_enrage_easy", this_loots, loot_scale);
		elseif(self:GetDifficulty() == "hero") then
			self:AppendSingleLootFromAttribute("loot1_enrage_hero", this_loots, loot_scale);
			self:AppendSingleLootFromAttribute("loot2_enrage_hero", this_loots, loot_scale);
			self:AppendSingleLootFromAttribute("loot3_enrage_hero", this_loots, loot_scale);
		elseif(self:GetDifficulty() == "nightmare") then
			self:AppendSingleLootFromAttribute("loot1_enrage_nightmare", this_loots, loot_scale);
			self:AppendSingleLootFromAttribute("loot2_enrage_nightmare", this_loots, loot_scale);
			self:AppendSingleLootFromAttribute("loot3_enrage_nightmare", this_loots, loot_scale);
		else
			self:AppendSingleLootFromAttribute("loot1_enrage", this_loots, loot_scale);
			self:AppendSingleLootFromAttribute("loot2_enrage", this_loots, loot_scale);
			self:AppendSingleLootFromAttribute("loot3_enrage", this_loots, loot_scale);
		end
	end

	-- append school loot
	if(player_phase) then
		local base_loot_key = string.lower("loot_"..tostring(player_phase));
		if(self:GetDifficulty() == "hard") then
			self:AppendSingleLootFromAttribute(base_loot_key.."_hard", this_loots, loot_scale);
		elseif(self:GetDifficulty() == "easy") then
			self:AppendSingleLootFromAttribute(base_loot_key.."_easy", this_loots, loot_scale);
		elseif(self:GetDifficulty() == "hero") then
			self:AppendSingleLootFromAttribute(base_loot_key.."_hero", this_loots, loot_scale);
		elseif(self:GetDifficulty() == "nightmare") then
			self:AppendSingleLootFromAttribute(base_loot_key.."_nightmare", this_loots, loot_scale);
		else
			self:AppendSingleLootFromAttribute(base_loot_key, this_loots, loot_scale);
		end
	end
	
	local shared_loots;
	shared_loots = self:AppendSharedLootFromAttribute("shared_loot", shared_loots, loot_scale);

	if(self:GetDifficulty() == "hard") then
		shared_loots = self:AppendSharedLootFromAttribute("shared_loot_hard", shared_loots, loot_scale);
	elseif(self:GetDifficulty() == "easy") then
		shared_loots = self:AppendSharedLootFromAttribute("shared_loot_easy", shared_loots, loot_scale);
	elseif(self:GetDifficulty() == "hero") then
		shared_loots = self:AppendSharedLootFromAttribute("shared_loot_hero", shared_loots, loot_scale);
	elseif(self:GetDifficulty() == "nightmare") then
		shared_loots = self:AppendSharedLootFromAttribute("shared_loot_nightmare", shared_loots, loot_scale);
	end
	
	return this_loots, shared_loots;
end

function Mob:GetCatchPetGSID()
	local catch_pet_gsid = self:GetStatByField("catch_pet");
	if(catch_pet_gsid) then
		catch_pet_gsid = tonumber(catch_pet_gsid);
		if(catch_pet_gsid) then
			return catch_pet_gsid;
		end
	end
	return 0;
end

function Mob:GetCatchPet_nid_gsid()
	-- return catched pet for nid
	if(self.nid_catchpet) then
		local catch_pet_gsid = self:GetStatByField("catch_pet");
		if(catch_pet_gsid) then
			catch_pet_gsid = tonumber(catch_pet_gsid);
			if(catch_pet_gsid) then
				local bOwn, guid = PowerItemManager.IfOwnGSItem(self.nid_catchpet, catch_pet_gsid);
				if(not bOwn) then
					return self.nid_catchpet, catch_pet_gsid;
				end
			end
		end
	end
end

function Mob:CanBeEnraged()
	local can_enrage = self:GetStatByField("enrage_enable");
	if(can_enrage == "true" or can_enrage == true) then
		return true;
	end
	return false;
end
function Mob:IsEnraged()
	if(self.nid_enraged) then
		return true;
	end
	return false;
end
function Mob:EnrageBy(player)
	if(player and player.nid) then
		if(self:IsAlive() and self.arena_id and self.arena_id == player.arena_id) then
			if(self:CanBeEnraged() and not self:IsEnraged()) then
				-- set enrage nid
				self.nid_enraged = player:GetNID();
				-- reset attacker memory
				self:ResetAttackerMemoryOnEnrage();
				-- reset the status
				if(System.options.version == "teen") then
					self:TakeDamage(99999999);
					self:TakeHeal(99999999);
				end
				return true;
			end
		end
	end
	return false;
end
function Mob:GetEnragePlayerNID()
	if(self:IsEnraged()) then
		return self.nid_enraged;
	end
end

function Mob:DumpLootLineToLog()
	local lootline = "";
	lootline = lootline..self:GetDisplayName()..",";
	local loots1 = self:GetStatByField("loot1");
	if(loots1) then
		-- get loot from mob template config
		local loot_pair, chance;
		for loot_pair, chance in pairs(loots1) do
			local gsid, count = string.match(loot_pair, "^(.-),(.-)$")
			local name = "";
			local gsItem = PowerItemManager.GetGlobalStoreItemInMemory(tonumber(gsid));
			if(gsItem) then
				name = gsItem.template.name;
			end
			lootline = lootline..name.."x"..count.." "..chance.."%,";
		end
	end
	-- secondary loot
	local loots2 = self:GetStatByField("loot2");
	if(loots2) then
		-- get loot from mob template config
		local loot_pair, chance;
		for loot_pair, chance in pairs(loots2) do
			local gsid, count = string.match(loot_pair, "^(.-),(.-)$")
			local name = "";
			local gsItem = PowerItemManager.GetGlobalStoreItemInMemory(tonumber(gsid));
			if(gsItem) then
				name = gsItem.template.name;
			end
			lootline = lootline..name.."x"..count.." "..chance.."%,";
		end
	end
	-- third loot
	local loots3 = self:GetStatByField("loot3");
	if(loots3) then
		-- get loot from mob template config
		local loot_pair, chance;
		for loot_pair, chance in pairs(loots3) do
			local gsid, count = string.match(loot_pair, "^(.-),(.-)$")
			local name = "";
			local gsItem = PowerItemManager.GetGlobalStoreItemInMemory(tonumber(gsid));
			if(gsItem) then
				name = gsItem.template.name;
			end
			lootline = lootline..name.."x"..count.." "..chance.."%,";
		end
	end
	lootline = lootline.."\n";
	log(commonlib.Encoding.Utf8ToDefault(lootline));
end

-- get mob display name
function Mob:GetDisplayName()
	return self:GetStatByField("displayname");
end

-- get can catch pet
function Mob:CanCatchPet()
	if(not self:IsEnraged()) then
		if(self:GetStatByField("catch_pet")) then
			return true;
			--local current_hp = self:GetCurrentHP();
			--local max_hp = self:GetMaxHP();
			--if(current_hp and max_hp) then
				--if((current_hp * 2) <= max_hp) then
					---- can catch pet on current hp below half max_hp
					--return true;
				--end
			--end
		end
	end
	return false;
end

-- get can catch pet normal update string
function Mob:CanCatchPet_normalupdate_str()
	if(self:CanCatchPet()) then
		return "-";
	end
	return "";
end

-- get rarity normal update
function Mob:Rarity_normalupdate_str()
	if(self:GetStatByField("rarity") == "elite") then
		return "e";
	elseif(self:GetStatByField("rarity") == "boss") then
		return "b";
	end
	return "";
end

local MobCCSAssetsByGearScore = {};
local MobAIDeckByGearScore = {};
local MobStatsByGearScore = {};

-- init auto pvp player essentials including: assets, ai_templates, stats
function Mob.InitAutobotEssential()
	local config_file = nil;
	if(System.options.version == "kids") then
		config_file = "config/Aries/Combat/MobCCSAssetsByGearScore.kids.xml";
	elseif(System.options.version == "teen") then
		config_file = "config/Aries/Combat/MobCCSAssetsByGearScore.teen.xml";
	end
	if(config_file) then
		commonlib.log("info: InitAutobotEssential MobCCSAssetsByGearScore config from: %s\n", tostring(config_file));
		local xmlRoot = ParaXML.LuaXML_ParseFile(config_file);
		if(not xmlRoot) then
			LOG.std(nil, "error", "Mob", "file %s does not exist", config_file);
		else
			local each_group;
			for each_group in commonlib.XPath.eachNode(xmlRoot, "/AssetsByGearScore/group") do
				local school = each_group.attr.school;
				local default_key;
				local keys = {};
				local each_asset;
				for each_asset in commonlib.XPath.eachNode(each_group, "/default_asset") do
					if(each_asset.attr.key) then
						default_key = each_asset.attr.key;
					end
				end
				local each_asset;
				for each_asset in commonlib.XPath.eachNode(each_group, "/asset") do
					if(each_asset.attr.key and each_asset.attr.gearscore_from and each_asset.attr.gearscore_to) then
						local gearscore_from = tonumber(each_asset.attr.gearscore_from);
						local gearscore_to = tonumber(each_asset.attr.gearscore_to);
						if(gearscore_from and gearscore_to) then
							table.insert(keys, {
								key = each_asset.attr.key,
								gearscore_from = gearscore_from,
								gearscore_to = gearscore_to,
							});
						end
					end
				end
				if(school and default_key) then
					keys.default_key = default_key;
					MobCCSAssetsByGearScore[school] = keys;
				end
			end
		end
	end

	local config_file = nil;
	if(System.options.version == "kids") then
		config_file = "config/Aries/Combat/MobAIDeckByGearScore.kids.xml";
	elseif(System.options.version == "teen") then
		config_file = "config/Aries/Combat/MobAIDeckByGearScore.teen.xml";
	end
	if(config_file) then
		commonlib.log("info: InitAutobotEssential MobAIDeckByGearScore config from: %s\n", tostring(config_file));
		local xmlRoot = ParaXML.LuaXML_ParseFile(config_file);

		if(not xmlRoot) then
			LOG.std(nil, "error", "Mob", "file %s does not exist", config_file);
		else
			local each_group;
			for each_group in commonlib.XPath.eachNode(xmlRoot, "/AIDeckByGearScore/group") do
				local school = each_group.attr.school;
				local keys = {};
				local each_deck;
				for each_deck in commonlib.XPath.eachNode(each_group, "/deck") do
					if(each_deck.attr.style and each_deck.attr.cards and each_deck.attr.gearscore_from and each_deck.attr.gearscore_to) then
						local gearscore_from = tonumber(each_deck.attr.gearscore_from);
						local gearscore_to = tonumber(each_deck.attr.gearscore_to);
						if(gearscore_from and gearscore_to) then
							table.insert(keys, {
								style = each_deck.attr.style,
								cards = each_deck.attr.cards,
								gearscore_from = gearscore_from,
								gearscore_to = gearscore_to,
							});
						end
					end
				end
				if(school) then
					MobAIDeckByGearScore[school] = keys;
				end
			end
		end
	end

	local config_file = nil;
	if(System.options.version == "kids") then
		config_file = "config/Aries/Combat/MobStatsByGearScore.kids.xml";
	elseif(System.options.version == "teen") then
		config_file = "config/Aries/Combat/MobStatsByGearScore.teen.xml";
	end
	if(config_file) then
		commonlib.log("info: InitAutobotEssential MobStatsByGearScore config from: %s\n", tostring(config_file));
		local xmlRoot = ParaXML.LuaXML_ParseFile(config_file);
		if(not xmlRoot) then
			LOG.std(nil, "error", "Mob", "file %s does not exist", config_file);
		else
			for each_group in commonlib.XPath.eachNode(xmlRoot, "/StatsByGearScore/group") do
				local school = each_group.attr.school;
				local keys = {};
				local each_stats;
				for each_stats in commonlib.XPath.eachNode(each_group, "/stats") do
					if(each_stats.attr.gearscore_from and each_stats.attr.gearscore_to) then
						local gearscore_from = tonumber(each_stats.attr.gearscore_from);
						local gearscore_to = tonumber(each_stats.attr.gearscore_to);
						if(gearscore_from and gearscore_to) then
							local stats = {};
							local k, v;
							for k, v in pairs(each_stats.attr) do
								if(k ~= "gearscore_from" and k ~= "gearscore_to") then
									stats[k] = tonumber(v);
								end
							end
							table.insert(keys, {
								stats = stats,
								gearscore_from = gearscore_from,
								gearscore_to = gearscore_to,
							});
						end
					end
				end
				if(school) then
					MobStatsByGearScore[school] = keys;
				end
			end
		end
	end
end

-- set asset from gear score
function Mob:SetAssetFromGearScore(school, gearscore)
	if(school and gearscore) then
		local keys = MobCCSAssetsByGearScore[school];
		if(keys) then
			local default_key = keys.default_key;
			local candidates = {};
			local _, key_struct;
			for _, key_struct in ipairs(keys) do
				if(gearscore >= key_struct.gearscore_from and gearscore <= key_struct.gearscore_to) then
					table.insert(candidates, key_struct.key);
				end
			end
			if(#candidates > 0) then
				local asset = candidates[math.random(1, #candidates)];
				if(not asset) then
					asset = default_key;
				end
				if(asset) then
					local template_key = self.template_key;
					if(template_key) then
						local template = MobTemplate.GetTemplate(template_key);
						if(template) then
							template.stats["asset"] = asset;
							return true;
						end
					end
				end
			end
		end
	end
	return false;
end

-- set AI deck from gear score
function Mob:SetAIDeckFromGearScore(school, gearscore)
	if(school and gearscore) then
		local keys = MobAIDeckByGearScore[school];
		if(keys) then
			local candidates = {};
			local _, key_struct;
			for _, key_struct in ipairs(keys) do
				if(gearscore >= key_struct.gearscore_from and gearscore <= key_struct.gearscore_to) then
					table.insert(candidates, _);
				end
			end
			if(#candidates > 0) then
				local index = candidates[math.random(1, #candidates)];
				if(index) then
					local key_struct = keys[index];
					local style = key_struct.style;
					local cards = key_struct.cards;
					if(style and cards) then
						local template_key = self.template_key;
						if(template_key) then
							local template = MobTemplate.GetTemplate(template_key);
							if(template) then
								template.stats["deck_attacker_style"] = style;
								template.stats["deckcards"] = cards;
								return true;
							end
						end
					end
				end
			end
		end
	end
	return false;
end

-- set stats from gear score
function Mob:SetStatsFromGearScore(school, gearscore)
	if(school and gearscore) then
		local keys = MobStatsByGearScore[school];
		if(keys) then
			local candidates = {};
			local _, key_struct;
			for _, key_struct in ipairs(keys) do
				if(gearscore >= key_struct.gearscore_from and gearscore <= key_struct.gearscore_to) then
					table.insert(candidates, key_struct.stats);
				end
			end
			if(#candidates > 0) then
				local key_stats = candidates[math.random(1, #candidates)];
				if(key_stats) then
					local template_key = self.template_key;
					if(template_key) then
						local template = MobTemplate.GetTemplate(template_key);
						if(template) then
							local k, v;
							for k, v in pairs(key_stats) do
								template.stats[k] = v;
							end
							return true;
						end
					end
				end
			end
		end
	end
	return false;
end

-- get mob phase
function Mob:GetPhase()
	return self:GetStatByField("phase");
end

function Mob:SetPhase(school)
	if(school) then
		local template_key = self.template_key;
		if(template_key) then
			local template = MobTemplate.GetTemplate(template_key);
			if(template and template.stats) then
				template.stats.phase = school;
			end
		end
	end
end
function Mob:SetDisplayName(name)
	if(name) then
		local template_key = self.template_key;
		if(template_key) then
			local template = MobTemplate.GetTemplate(template_key);
			if(template and template.stats) then
				template.stats.displayname = name;
			end
		end
	end
end
function Mob:SetLevel(level)
	if(level) then
		local template_key = self.template_key;
		if(template_key) then
			local template = MobTemplate.GetTemplate(template_key);
			if(template and template.stats) then
				template.stats.level = level;
			end
		end
	end
end

-- get mob asset file
function Mob:GetAssetFile()
	return self:GetStatByField("asset");
end

-- get mob scale
function Mob:GetScale()
	return self:GetStatByField("scale");
end

-- get mob tags
function Mob:GetTags()
	local tags_str = "";
	if(self:IsEnraged()) then
		tags_str = tags_str.."r"; -- r for enraged
	end
	if(self:CanBeEnraged()) then
		tags_str = tags_str.."c"; -- c for can be enraged
	end
	return tags_str;
end

-- get current mob hp point
function Mob:GetCurrentHP()
	return self.current_hp;
end

-- get current difficulty modifier
function Mob:GetCurrentDifficultyModifier()
	if(not self:IsEnraged()) then
		local difficulty = self:GetDifficulty();
		if(self.difficulty_modifier) then
			return self.difficulty_modifier[difficulty];
		end
	end
end

-- get max mob hp point
function Mob:GetMaxHP()
	local maxhp = tonumber(self:GetStatByField("hp"))

	local modifier = self:GetCurrentDifficultyModifier();
	if(modifier and modifier.hp) then
		maxhp = math_ceil(maxhp * modifier.hp);
	end

	return maxhp;
end

-- get mob level
function Mob:GetLevel()
	return tonumber(self:GetStatByField("level") or 1);
end

-- get current pips count
function Mob:GetPipsCount()
	return self.pips_normal;
end

-- get current power pips count
function Mob:GetPowerPipsCount()
	return self.pips_power;
end

-- set startup pips
function Mob:SetStartupPips()
	self.pips_normal = tonumber(self:GetStatByField("startup_pips_normal") or 0);
	self.pips_power = tonumber(self:GetStatByField("startup_pips_power") or 0);
	if(System.options.version == "teen") then
		self.pips_normal = self.pips_power * 2 + self.pips_normal;
		self.pips_power = 0;
	end
	if(self.pips_normal >= 7) then
		self.pips_normal = 7;
	end
	if(self.pips_normal <= 0) then
		self.pips_normal = 0;
	end
	if(self.pips_power >= 7) then
		self.pips_power = 7;
	end
	if(self.pips_power <= 0) then
		self.pips_power = 0;
	end
	-- teen version: additional 1 normal pip for last players  pvp arena only
	if(System.options.version == "teen") then
		local isNearArenaFirst = false;
		local bonus_pips_starting_defensive_units = 0;
		local arena_id = self.arena_id;
		if(arena_id) then
			local arena = Arena.GetArenaByID(arena_id)
			if(arena) then
				isNearArenaFirst = arena.isNearArenaFirst;
				bonus_pips_starting_defensive_units = arena.bonus_pips_starting_defensive_units;
			end
		end
		if(bonus_pips_starting_defensive_units and bonus_pips_starting_defensive_units > 0) then
			-- additional normal pip for defensive players
			local i;
			for i = 1, bonus_pips_starting_defensive_units do
				if(self.side == "near" and isNearArenaFirst == false) then
					self:GeneratePip(nil, true); -- true for bForceNormalPip
				elseif(self.side == "far" and isNearArenaFirst == true) then
					self:GeneratePip(nil, true); -- true for bForceNormalPip
				end
			end
		end
	end
end

-- if with enough pips to cast spell
-- @return: true or false
function Mob:CanCastSpell(spell_key)
	local card_template = Card.GetCardTemplate(spell_key);
	if(card_template) then
		if(card_template.spell_school == self:GetPhase()) then
			-- own school spell
			if(card_template.pipcost <= (self.pips_normal + self.pips_power * 2)) then
				return true;
			end
		else
			-- off school spell
			if(System.options.version == "teen") then
				if(card_template.spell_school == "balance") then
					-- balance school as own school spell
					if(card_template.pipcost <= (self.pips_normal + self.pips_power * 2)) then
						return true;
					end
				end
				-- cost double normal pips
				if((card_template.pipcost * 2) <= (self.pips_normal + self.pips_power)) then
					return true;
				end
			else
				-- take power pip as normal pips
				if(card_template.pipcost <= (self.pips_normal + self.pips_power)) then
					return true;
				end
			end
		end
	else
		LOG.std(nil, "error", "combatmob", "unknown card template with spell_key:".. spell_key);
	end
	return false;
end

-- generate pip for each round
-- @params bForcePowerPip: force generate powerpip
function Mob:GeneratePip(bForcePowerPip, bForceNormalPip)
	local r = math.random(0, 100);
	if(not bForceNormalPip and (bForcePowerPip or r <= self:GetPowerPipChance())) then
		-- this is a power pip
		if(System.options.version == "teen") then
			self.pips_normal = self.pips_normal + 2;
			if((self.pips_normal + self.pips_power) > maximum_mob_pips_count) then
				self.pips_normal = maximum_mob_pips_count - self.pips_power;
			end
		else
			self.pips_power = self.pips_power + 1;
			if((self.pips_normal + self.pips_power) > maximum_mob_pips_count) then
				self.pips_power = maximum_mob_pips_count - self.pips_normal;
			end
		end
	else
		-- this is a normal pip
		self.pips_normal = self.pips_normal + 1;
		if((self.pips_normal + self.pips_power) > maximum_mob_pips_count) then
			self.pips_normal = maximum_mob_pips_count - self.pips_power;
		end
	end
end

-- cost pips
-- @param pip_count: pip count
-- @param school: spell school
-- @return: the real cost pips, this is useful when costing X pips
function Mob:CostPips(pip_count, school)
	local realcost = 0;
	if(pip_count < 0) then
		-- this is an x pip cost, cost as much as possible
		pip_count = -pip_count;
	end
	if(self.picked_card_force_pip_cost) then
		pip_count = self.picked_card_force_pip_cost;
	end
	if(school == self:GetPhase() or (school == "balance" and System.options.version == "teen")) then
		-- own school spell, costing power pips as 2 pips
		-- balance school as own school spell in teen version
		while(pip_count > 0) do
			if(pip_count >= 2) then
				-- cost power pips as possible
				if(self.pips_power > 0) then
					self.pips_power = self.pips_power - 1;
					pip_count = pip_count - 2;
					realcost = realcost + 2;
				elseif(self.pips_normal > 0) then
					self.pips_normal = self.pips_normal - 1;
					pip_count = pip_count - 1;
					realcost = realcost + 1;
				else
					self.pips_normal = self.pips_normal - 1;
					pip_count = pip_count - 1;
				end
			else
				-- cost normal pips as possible
				if(self.pips_normal > 0) then
					self.pips_normal = self.pips_normal - 1;
					pip_count = pip_count - 1;
					realcost = realcost + 1;
				elseif(self.pips_power > 0) then
					self.pips_power = self.pips_power - 1;
					pip_count = pip_count - 1;
					realcost = realcost + 1;
				else
					self.pips_power = self.pips_power - 1;
					pip_count = pip_count - 1;
				end
			end
		end
	else
		if(System.options.version == "teen") then
			-- other school spell, double normal pips cost
			while(pip_count > 0) do
				-- cost normal pips as possible
				if(self.pips_normal >= 2) then
					self.pips_normal = self.pips_normal - 2;
					pip_count = pip_count - 1;
					realcost = realcost + 1;
				elseif(self.pips_normal == 1) then
					self.pips_normal = self.pips_normal - 1;
					pip_count = pip_count - 1;
					realcost = realcost + 0.5; -- half pip for the last normal pip
				elseif(self.pips_power > 0) then
					self.pips_power = self.pips_power - 1;
					pip_count = pip_count - 1;
					realcost = realcost + 1;
				else
					self.pips_normal = self.pips_normal - 2;
					pip_count = pip_count - 1;
				end
			end
		else
			-- other school spell, costing all pips as normal pips
			if(pip_count <= self.pips_normal) then
				self.pips_normal = self.pips_normal - pip_count;
				realcost = realcost + pip_count;
			else
				realcost = realcost + math.min(self.pips_power, (pip_count - self.pips_normal));
				self.pips_power = self.pips_power - (pip_count - self.pips_normal);
				realcost = realcost + self.pips_normal;
				self.pips_normal = 0;
			end
		end
	end
	-- make sure pips_power and pips_normal are all positive
	if(self.pips_power < 0) then
		self.pips_power = 0;
	end
	if(self.pips_normal < 0) then
		self.pips_normal = 0;
	end
	return realcost;
end

-- reset pips
function Mob:ResetPips()
	self.pips_normal = 0;
	self.pips_power = 0;
end

-- get power pip chance
-- @return: 10 means 10% power pip chance
function Mob:GetPowerPipChance()
	-- balance global aura bonus 
	local powerpip_bonus = 0;
	local arena_id = self.arena_id;
	if(arena_id) then
		local arena = Arena.GetArenaByID(arena_id)
		if(arena) then
			local GlobalAura, GlobalAura_boost_damage, GlobalAura_boost_school, GlobalAura_boost_heal, GlobalAura_boost_powerpip, GlobalAura_boost_powerpip = arena:GetAura();
			if(GlobalAura_boost_powerpip) then
				powerpip_bonus = GlobalAura_boost_powerpip;
			end
		end
	end
	
	-- get stats from mini aura
	if(self.miniaura and self.miniaura_rounds and self.miniaura_rounds > 0) then
		local miniaura_template = Card.GetMiniAuraTemplate(self.miniaura);
		if(miniaura_template) then
			powerpip_bonus = powerpip_bonus + (miniaura_template.stats[102] or 0);
		end
	end
	
	return tonumber(self:GetStatByField("power_pip_percent") or 0) + powerpip_bonus;
end

-- get accuracy boost
-- @param school: fire ice etc.
-- @return: 10 means 10% accuracy boost
function Mob:GetAccuracyBoost(school)
	local picked_card_accuracy_boost = 0;
	if(type(self.picked_card_accuracy_boost) == "number") then
		picked_card_accuracy_boost = self.picked_card_accuracy_boost;
	end
	return tonumber(self:GetStatByField("accuracy_"..school.."_percent") or 0) + picked_card_accuracy_boost;
end

-- get damage boost
-- @param school: fire ice etc.
-- @return: 10 means 10% damage boost
function Mob:GetDamageBoost(school)
	local boost = tonumber(self:GetStatByField("damage_"..school.."_percent") or 0);
	if(not boost) then
		LOG.std(nil, "error", "mob_server", "Mob:GetDamageBoost got invalid damage boost %s", tostring(self:GetKey()));
		boost = 0;
	end
	-- special boss damage boost
	if(self:GetTemplateKey() == "config/Aries/Mob/YYsDream/MobTemplate_ShadowSmashBullYYsDream_S2.xml") then
		local max_hp = self:GetMaxHP();
		local ratio = self:GetCurrentHP() / max_hp;
		if(ratio <= 0.3) then
			-- double damage boost
			boost = boost * 2 + 100;
		end
	end
	
	local modifier = self:GetCurrentDifficultyModifier();
	if(modifier and modifier.damage) then
		boost = math_ceil(boost * modifier.damage);
	end

	return boost;
end

-- get damage boost absolute
-- @param school: fire ice etc.
-- @return: 10 means 10 damage boost absolute
function Mob:GetDamageBoost_absolute(school)
	local boost = tonumber(self:GetStatByField("damage_"..school.."_absolute") or 0);
	boost = boost + tonumber(self:GetStatByField("damage_all_absolute") or 0);
	
	local modifier = self:GetCurrentDifficultyModifier();
	if(modifier and modifier.damage) then
		boost = math_ceil(boost * modifier.damage);
	end

	return boost;
end

-- get resist
-- @param school: fire ice etc.
-- @return: -10 means 10% resist, if 100 pts damage is taken, 90 pts is applied
function Mob:GetResist(school)
	local base_resist = tonumber(self:GetStatByField("resist_"..school.."_percent") or 0);
	
	local modifier = self:GetCurrentDifficultyModifier();
	if(modifier and modifier.resist) then
		base_resist = math_ceil(base_resist * modifier.resist);
	end

	--119 add_resist_overall_percent(CG)
	--120 add_resist_fire_percent(CG)
	--121 add_resist_ice_percent(CG)
	--122 add_resist_storm_percent(CG)
	--123 add_resist_myth_percent(CG)
	--124 add_resist_life_percent(CG)
	--125 add_resist_death_percent(CG)
	--126 add_resist_balance_percent(CG)
	local stats_ids = {};
	table.insert(stats_ids, 119);
	local school_lower = string.lower(school);
	if(school_lower == "fire") then
		table.insert(stats_ids, 120);
	elseif(school_lower == "ice") then
		table.insert(stats_ids, 121);
	elseif(school_lower == "storm") then
		table.insert(stats_ids, 122);
	elseif(school_lower == "myth") then
		table.insert(stats_ids, 123);
	elseif(school_lower == "life") then
		table.insert(stats_ids, 124);
	elseif(school_lower == "death") then
		table.insert(stats_ids, 125);
	elseif(school_lower == "balance") then
		table.insert(stats_ids, 126);
	end
	
	-- get stats from standing wards
	for i = 1, #self.standing_wards do
		local each_ward = self.standing_wards[i];
		if(each_ward and each_ward.id and each_ward.id ~= 0 and each_ward.rounds and each_ward.rounds > 0) then
			local wardTemplate = Card.GetWardTemplate(each_ward.id)
			if(wardTemplate and wardTemplate.stats) then
				local _, stat_type;
				for _, stat_type in pairs(stats_ids) do
					base_resist = base_resist + (wardTemplate.stats[stat_type] or 0);
				end
			end
		end
	end
	
	-- get stats from globalaura2
	local arena_id = self.arena_id;
	if(arena_id) then
		local arena = Arena.GetArenaByID(arena_id)
		if(arena) then
			local aura2, icon_gsid = arena:GetAura2();
			if(aura2) then
				local globalauraTemplate = Card.GetGlobalAuraTemplate(aura2)
				if(globalauraTemplate and globalauraTemplate.stats) then
					local _, stat_type;
					for _, stat_type in pairs(stats_ids) do
						base_resist = base_resist + (globalauraTemplate.stats[stat_type] or 0);
					end
				end
			end
		end
	end

	if(base_resist < 0) then
		-- prevent negative resist
		base_resist = 0;
	end
	
	-- additional 80% damage resist for freezed targets
	if(self.freeze_rounds > 0) then
		base_resist = 100 - (100 - base_resist) * (100 - 80) / 100;
	end

	if(base_resist > MAX_MOB_RESIST_PERCENT) then
		base_resist = MAX_MOB_RESIST_PERCENT;
	end
	
	return -base_resist;
end

-- get resist absolute
-- @param school: fire ice etc.
-- @return: -10 means 10 resist absolute, if 100 pts damage is taken, 90 pts is applied
function Mob:GetResist_absolute(school)
	local base_resist = tonumber(self:GetStatByField("resist_"..school.."_absolute") or 0);
	base_resist = base_resist + tonumber(self:GetStatByField("resist_all_absolute") or 0);

	local modifier = self:GetCurrentDifficultyModifier();
	if(modifier and modifier.resist) then
		base_resist = math_ceil(base_resist * modifier.resist);
	end
	
	if(self.pierce_freeze_buffs and self.pierce_freeze_rounds) then
		local _;
		for _ = 1, self.pierce_freeze_buffs do
			--李宇(Liyu) 10:19:11
			--机制都不动，数值 20-》10
			base_resist = math_ceil(base_resist * (1 - 0.1));
		end
		if(base_resist < 0) then
			base_resist = 0;
		end
	end
	
	if(System.options.version == "teen") then
		--234 add_resist_overall_absolute_bonus_percent(CG) 增加用户所有系魔法的附加抗性每魔力点绝对值百分比加成(青年版用这个)  
		--235 add_resist_fire_absolute_bonus_percent(CG) 增加用户火系魔法的附加抗性每魔力点绝对值百分比加成(青年版用这个)  
		--236 add_resist_ice_absolute_bonus_percent(CG) 增加用户冰系魔法的附加抗性每魔力点绝对值百分比加成(青年版用这个)  
		--237 add_resist_storm_absolute_bonus_percent(CG) 增加用户风暴系魔法的附加抗性每魔力点绝对值百分比加成(青年版用这个)  
		--238 add_resist_myth_absolute_bonus_percent(CG) 增加用户神秘系魔法的附加抗性每魔力点绝对值百分比加成(青年版用这个)  
		--239 add_resist_life_absolute_bonus_percent(CG) 增加用户生命系魔法的附加抗性每魔力点绝对值百分比加成(青年版用这个)  
		--240 add_resist_death_absolute_bonus_percent(CG) 增加用户死亡系魔法的附加抗性每魔力点绝对值百分比加成(青年版用这个)  
		--241 add_resist_balance_absolute_bonus_percent(CG) 增加用户平衡系魔法的附加抗性每魔力点绝对值百分比加成(青年版用这个)  
		local stats_ids = {};
		table.insert(stats_ids, 234);
		local school_lower = string.lower(school);
		if(school_lower == "fire") then
			table.insert(stats_ids, 235);
		elseif(school_lower == "ice") then
			table.insert(stats_ids, 236);
		elseif(school_lower == "storm") then
			table.insert(stats_ids, 237);
		elseif(school_lower == "myth") then
			table.insert(stats_ids, 238);
		elseif(school_lower == "life") then
			table.insert(stats_ids, 239);
		elseif(school_lower == "death") then
			table.insert(stats_ids, 240);
		elseif(school_lower == "balance") then
			table.insert(stats_ids, 241);
		end
		-- bonus
		local stat_percent = 0;
		
		-- get stats from standing wards
		for i = 1, #self.standing_wards do
			local each_ward = self.standing_wards[i];
			if(each_ward and each_ward.id and each_ward.id ~= 0 and each_ward.rounds and each_ward.rounds > 0) then
				local wardTemplate = Card.GetWardTemplate(each_ward.id)
				if(wardTemplate and wardTemplate.stats) then
					local _, stat_type;
					for _, stat_type in pairs(stats_ids) do
						stat_percent = stat_percent + (wardTemplate.stats[stat_type] or 0);
					end
				end
			end
		end

		base_resist = math.ceil(base_resist * (100 + stat_percent) / 100);
	end
	
	return -base_resist;
end

-- get critical strike
-- @param school: fire ice etc.
-- @return: 10 means 10% critical strike
function Mob:GetCriticalStrike(school)
	local boost = tonumber(self:GetStatByField("criticalstrike_"..school.."_percent") or 0);
	boost = boost + tonumber(self:GetStatByField("criticalstrike_all_percent") or 0);
	return boost;
end

-- get critical strike in dot
-- @param school: fire ice etc.
-- @return: 10 means 10% critical strike
function Mob:GetCriticalStrike_DOT(school)
	if(self:GetStance() == "blazing") then
		return 10000; -- 10000% must critical strike
	end
	return 0;
end

-- get critical strike damage ratio bonus
-- bonus is added to base damage ratio
function Mob:GetCriticalStrikeDamageRatioBonus()
	return 0;
end

-- get resilience
-- @param school: fire ice etc.
-- @return: 10 means 10% resilience
function Mob:GetResilience(school)
	local boost = tonumber(self:GetStatByField("resilience_"..school.."_percent") or 0);
	boost = boost + tonumber(self:GetStatByField("resilience_all_percent") or 0);
	return boost;
end

-- get resilience in dot
-- @param school: fire ice etc.
-- @return: 10 means 10% resilience
function Mob:GetResilience_DOT(school)
	return 0;
end

-- get hitchance
-- @param school: fire ice etc.
-- @return: 10 means 10% hitchance
function Mob:GetHitChance(school)
	local boost = tonumber(self:GetStatByField("hitchance_"..school.."_percent") or 0);
	boost = boost + tonumber(self:GetStatByField("hitchance_all_percent") or 0);
	return boost;
end

-- get dodge
-- @param school: fire ice etc.
-- @return: 10 means 10% dodge
function Mob:GetDodge(school)
	local boost = tonumber(self:GetStatByField("dodge_"..school.."_percent") or 0);
	boost = boost + tonumber(self:GetStatByField("dodge_all_percent") or 0);
	return boost;
end

-- get spell peneration
-- @param school: fire ice etc.
-- @return: 10 means 10% spell peneration which modify to resist(negative)
function Mob:GetSpellPenetration(school)
	local boost = tonumber(self:GetStatByField("spellpenetration_"..school.."_percent") or 0);
	boost = boost + tonumber(self:GetStatByField("spellpenetration_all_percent") or 0);
	return boost;
end

-- get receive spell peneration
-- @param school: fire ice etc.
-- @return: 10 means 10% spell peneration
function Mob:GetSpellPenetrationReceive(school)
	-- 247 add_spell_penetration_storm_percent(CG) 增加用户风暴系魔法的*被*法术穿透百分比 (儿童版) 
	if(school == "storm") then
		-- bonus
		local stat = 0;
		-- get stats from standing wards
		for i = 1, #self.standing_wards do
			local each_ward = self.standing_wards[i];
			if(each_ward and each_ward.id and each_ward.id ~= 0 and each_ward.rounds and each_ward.rounds > 0) then
				local wardTemplate = Card.GetWardTemplate(each_ward.id)
				if(wardTemplate and wardTemplate.stats) then
					stat = stat + (wardTemplate.stats[247] or 0);
				end
			end
		end
		return stat;
	end
	return 0;
end

-- get output heal boost percent
function Mob:GetOutputHealBoost()
	local output_heal_percent = tonumber(self:GetStatByField("output_heal_percent") or 0);

	local modifier = self:GetCurrentDifficultyModifier();
	if(modifier and modifier.output_heal_percent) then
		output_heal_percent = math_ceil(output_heal_percent * modifier.output_heal_percent);
	end

	return output_heal_percent;
end

-- get input heal boost percent
function Mob:GetInputHealBoost()
	
	local stat = tonumber(self:GetStatByField("input_heal_percent") or 0);
	-- get stats from standing wards
	for i = 1, #self.standing_wards do
		local each_ward = self.standing_wards[i];
		if(each_ward and each_ward.id and each_ward.id ~= 0 and each_ward.rounds and each_ward.rounds > 0) then
			local wardTemplate = Card.GetWardTemplate(each_ward.id)
			if(wardTemplate and wardTemplate.stats) then
				-- 183 input_heal_percent(CG) 输入治疗加成百分比  
				if(wardTemplate.stats[183]) then
					stat = stat + wardTemplate.stats[183];
				end
			end
		end
	end

	return stat;
end

-- get double attack chance
-- @param school: fire ice etc.
-- @return: 10 means 10% double attack chance
function Mob:GetDoubleAttackChance(school)
	return 0;
end

-- is mob alive
function Mob:IsAlive()
	if(self:GetCurrentHP() > 0) then
		return true;
	end
	return false;
end

-- take damage
function Mob:TakeDamage(points)
	self.current_hp = self.current_hp - points;
	if(self.current_hp < 0) then
		self.current_hp = 0;
	end
	if(System.options.version == "teen") then
		if(points > 0) then
			if(self:IsStealth()) then
				self:LeaveStealth();
			end
		end
	end
	if(self.current_hp == 0) then
		-- clear DOTs and HOTs
		self.DOTs = {};
		self.HOTs = {};
		-- clear charms and wards
		self.charms = {};
		self.wards = {};
		self.absorbs = {};
		-- clear standing defects and buffs
		self.standing_defects = {};
		self.standing_buffs = {};
		-- clear standing charms and wards
		self.standing_charms = {};
		self.standing_wards = {};
		-- mini aura
		self.miniaura = nil;
		self.miniaura_rounds = nil;
		-- stance
		self.stance = nil;
		self.stance_rounds = nil;
		-- stealth
		self.stealth = nil;
		self.stealth_rounds = nil;
		-- pierce freeze
		self.pierce_freeze_buffs = nil;
		self.pierce_freeze_rounds = nil;
		-- clear stunned
		self.bStunned = false;
		-- clear controlled
		self.control_rounds = 0;
		-- electric_rounds
		self.electric_rounds = 0;
		-- is with guardian
		self.bWithGuardian = self.bWithGuardian; -- NOTE: keep with guardian for revive
		-- clear freeze
		self.freeze_rounds = 0;
		self.anti_freeze_rounds = 0;
		self.anti_freeze_rounds_sibling = 0;
		-- catched pet nid
		self.nid_catchpet = self.nid_catchpet; -- NOTE: keep caught pet nid for loot
		-- enraged nid
		self.nid_enraged = self.nid_enraged; -- NOTE: keep enrage nid for loot
		-- skip loot
		self.bSkipLoot = nil;
		-- reset shield amount
		self.reflect_amount = 0;
		-- reset pips
		self.pips_normal = 0;
		self.pips_power = 0;
		-- reset threats
		self.threats = {};
		self.threats_pending = {};
		-- reset genes attacker memory
		self.genes_attacker_memory = {};
		-- reset deck attacker memory
		self.deck_attacker_memory = {};
	end
end

-- revive mob
function Mob:Revive()
	self:TakeDamage(9999999); -- kill unit with very large damage and reset
	self:TakeHeal(REVIVE_BASE_HP);
	self.bWithGuardian = false; -- reset with guardian
end

-- take heal
function Mob:TakeHeal(points)
	self.current_hp = self.current_hp + points;
	if(self.current_hp > self:GetMaxHP()) then
		self.current_hp = self:GetMaxHP();
	end
end

-- append charm
function Mob:AppendCharm(charm_id)
	table.insert(self.charms, charm_id);
end

-- append ward
function Mob:AppendWard(ward_id)
	table.insert(self.wards, ward_id);
end

-- append standing ward
function Mob:AppendStandingWard(ward_id, rounds)
	table.insert(self.standing_wards, {id = ward_id, rounds = rounds});
end

-- append reflection shield
function Mob:AppendReflectionShield(amount)
	self.reflect_amount = self.reflect_amount + amount;
end

-- append absorb
function Mob:AppendAbsorb(absorb_pts, ward_id)
	table.insert(self.wards, ward_id);
	self.absorbs[#self.wards] = absorb_pts;
end

-- pop charm id. if charm exist, remove the charm id and return true, if not return false
function Mob:PopCharm(id)
	local i;
	for i = 1, #self.charms do
		if(self.charms[i] == id) then
			self.charms[i] = 0;
			return true;
		end
	end
	return false;
end

-- pop random charm
-- @param only_positive_or_negative: true, only positive charm, false only negative charm, nil any random charm
-- @return: charm id or nil for no charms available
function Mob:PopRandomCharm(only_positive_or_negative, isLast, isFirst)
	local charm_index = {};
	local i;
	for i = 1, #self.charms do
		if(self.charms[i] > 0) then
			if(only_positive_or_negative == true) then
				local charm_template = Card.GetCharmTemplate(self.charms[i]);
				if(charm_template.positive == true or charm_template.positive == "true") then
					table.insert(charm_index, i);
				end
			elseif(only_positive_or_negative == false) then
				local charm_template = Card.GetCharmTemplate(self.charms[i]);
				if(charm_template.positive == false or charm_template.positive == "false") then
					table.insert(charm_index, i);
				end
			else
				table.insert(charm_index, i);
			end
		end
	end
	if(#charm_index <= 0) then
		-- no charms available
		return;
	end
	local i = math.random(1, #charm_index);
	if(isLast) then
		i = #charm_index;
	end
	if(isFirst) then
		i = 1;
	end
	local index = charm_index[i];
	local charm_id = self.charms[index];
	self.charms[index] = 0;
	return charm_id;
end

-- pop last charm
-- @param only_positive_or_negative: true, only positive charm, false only negative charm, nil any random charm
-- @return: charm id or nil for no charms available
function Mob:PopLastCharm(only_positive_or_negative)
	return self:PopRandomCharm(only_positive_or_negative, true);
end

-- pop first charm
-- @param only_positive_or_negative: true, only positive charm, false only negative charm, nil any random charm
-- @return: charm id or nil for no charms available
function Mob:PopFirstCharm(only_positive_or_negative)
	return self:PopRandomCharm(only_positive_or_negative, nil, true);
end

-- if unit has positive charm
function Mob:HasPositiveCharm()
	local i;
	for i = 1, #self.charms do
		if(self.charms[i] > 0) then
			local charm_template = Card.GetCharmTemplate(self.charms[i]);
			if(charm_template.positive == true or charm_template.positive == "true") then
				return true;
			end
		end
	end
	return false;
end

-- if unit has negative charm
function Mob:HasNegativeCharm()
	local i;
	for i = 1, #self.charms do
		if(self.charms[i] > 0) then
			local charm_template = Card.GetCharmTemplate(self.charms[i]);
			if(charm_template.positive == false or charm_template.positive == "false") then
				return true;
			end
		end
	end
	return false;
end

-- Process stats against charms
-- @param buffs: [in and out] the boost buffs
-- @param school: spell school
-- @param buffs2: [optional][in and out] the boost buffs appends
-- @return: spell school
function Mob:ProcessStatAgainstCharms(buffs, stat_name, school)
	if(not buffs or not stat_name or not school) then
		LOG.std(nil, "error", "mob_server", "Mob:ProcessHitChanceAgainstCharms got invalid input: "..commonlib.serialize({buffs, stat_name, school}));
		return;
	end
	-- processed charm ids
	local effected_charm_ids = {};
	-- process the charms from the back
	local i;
	local count = #self.charms;
	for i = 1, count do
		local order = count + 1 - i;
		local charm_id = self.charms[order];
		local charmTemplate = Card.GetCharmTemplate(charm_id);
		if(charmTemplate) then
			local base_charm_id = math.mod(charm_id, 1000); -- base white card charm id
			if(charmTemplate[stat_name]) then
				-- not effected before
				if(not effected_charm_ids[base_charm_id]) then
					-- stat boost
					if(school == "skipschool" or string_lower(charmTemplate.school) == string_lower(school) or string_lower(charmTemplate.school) == "all") then
						-- pop charm and append boost
						self.charms[order] = 0;
						table_insert(buffs, charmTemplate[stat_name]);
						if(buffs2) then
							table_insert(buffs2, charmTemplate[stat_name]);
						end
						effected_charm_ids[base_charm_id] = true;
					end
				end
			end
		end
	end
	return school;
end

-- process accuracy with charms
function Mob:ProcessAccuracyAgainstCharms(buffs, school)
	return self:ProcessStatAgainstCharms(buffs, "boost_accuracy", school);
end

-- process hitchance with charms
function Mob:ProcessHitChanceAgainstCharms(buffs, school)
	return self:ProcessStatAgainstCharms(buffs, "boost_hitchance", school);
end

-- process damage with charms
function Mob:ProcessDamageAgainstCharms(buffs, school, buffs2)
	return self:ProcessStatAgainstCharms(buffs, "boost_damage", school, buffs2);
end

-- process heal with charms
function Mob:ProcessHealAgainstCharms(buffs)
	return self:ProcessStatAgainstCharms(buffs, "boost_heal", "skipschool");
end

-- pop ward id. if ward exist, remove the ward id and return true, if not return false
function Mob:PopWard(id)
	-- NOTE: we assume standing wards don't overlap with oridary wards
	-- first check standing wards value
	local i;
	for i = 1, #self.standing_wards do
		local each_ward = self.standing_wards[i];
		if(each_ward and each_ward.id and each_ward.id ~= 0 and each_ward.rounds and each_ward.rounds > 0) then
			if(each_ward.id == id) then
				return true;
			end
		end
	end
	-- next pop ordinary ward
	local i;
	for i = 1, #self.wards do
		if(self.wards[i] == id) then
			self.wards[i] = 0;
			return true;
		end
	end
	return false;
end

-- pop standing ward id. if ward exist, remove the ward id and return true, if not return false
function Mob:PopStandingWardIfExist(id)
	local ret = false;
	local i;
	for i = 1, #self.standing_wards do
		local each_ward = self.standing_wards[i];
		if(each_ward and each_ward.id and each_ward.id ~= 0 and each_ward.rounds and each_ward.rounds > 0) then
			if(each_ward.id == id) then
				each_ward.rounds = 0;
				ret = true;
			end
		end
	end
	return ret;
end

-- Process damage against wards
-- NOTE: with the introduce of the convert prism, wards process is proceed from the back of the wards to the front
--		 pop boost damage ward and prism ward
-- @param buffs: [in and out] the boost damage buffs
-- @param damage_school: original boost damage school, it may be converted by internal wards process
-- @return: final damage_school
function Mob:ProcessDamageAgainstWards(buffs, damage_school)
	if(not buffs or not damage_school) then
		LOG.std(nil, "error", "mob_server", "Mob:ProcessDamageAgainstWards got invalid input: "..commonlib.serialize({buffs, damage_school}));
		return;
	end
	-- processed ward ids
	local effected_ward_ids = {};
	-- process the wards from the back
	local i;
	local count = #self.wards;
	for i = 1, count do
		local order = count + 1 - i;
		local ward_id = self.wards[order];
		local wardTemplate = Card.GetWardTemplate(ward_id);
		if(wardTemplate) then
			local base_ward_id = math.mod(ward_id, 1000); -- base white card ward id
			if(wardTemplate.boost_damage) then
				-- not effected before
				if(not effected_ward_ids[base_ward_id]) then
					-- damage boost
					if(string_lower(wardTemplate.school) == string_lower(damage_school) or string_lower(wardTemplate.school) == "all") then
						-- pop ward and append boost
						self.wards[order] = 0;
						table_insert(buffs, wardTemplate.boost_damage);
						effected_ward_ids[base_ward_id] = true;
					end
				end
			elseif(wardTemplate.prism_from and wardTemplate.prism_to) then
				-- prism
				if(string_lower(wardTemplate.prism_from) == string_lower(damage_school)) then
					-- pop ward and convert damage school
					self.wards[order] = 0;
					damage_school = string_lower(wardTemplate.prism_to);
				end
			end
		end
	end
	return damage_school;
end

-- pop random ward
-- @param only_positive_or_negative: true, only positive ward, false only negative ward, nil any random ward
-- @return: ward id or nil for no wards available
function Mob:PopRandomWardForManipulate(only_positive_or_negative, isLast, isFirst)
	local ward_index = {};
	local i;
	for i = 1, #self.wards do
		if(self.wards[i] > 0) then
			local ward_template = Card.GetWardTemplate(self.wards[i]);
			if(ward_template and ward_template.can_manipulate ~= false) then
				if(only_positive_or_negative == true) then
					if(ward_template.positive == true) then
						table.insert(ward_index, i);
					end
				elseif(only_positive_or_negative == false) then
					if(ward_template.positive == false) then
						table.insert(ward_index, i);
					end
				else
					table.insert(ward_index, i);
				end
			end
		end
	end
	if(#ward_index <= 0) then
		-- no wards available
		return;
	end
	local i = math.random(1, #ward_index);
	if(isLast) then
		i = #ward_index;
	end
	if(isFirst) then
		i = 1;
	end
	local index = ward_index[i];
	local ward_id = self.wards[index];
	self.wards[index] = 0;
	return ward_id;
end

-- pop random ward
-- @param only_positive_or_negative: true, only positive ward, false only negative ward, nil any random ward
-- @return: ward id or nil for no wards available
function Mob:PopLastWardForManipulate(only_positive_or_negative)
	return self:PopRandomWardForManipulate(only_positive_or_negative, true)
end

-- pop random ward
-- @param only_positive_or_negative: true, only positive ward, false only negative ward, nil any random ward
-- @return: ward id or nil for no wards available
function Mob:PopFirstWardForManipulate(only_positive_or_negative)
	return self:PopRandomWardForManipulate(only_positive_or_negative, nil, true)
end

-- if unit has specified ward
function Mob:HasWard(id, bIncludeQuality)
	if(id) then
		local i;
		for i = 1, #self.wards do
			local ward_id = self.wards[i];
			if(ward_id > 0) then
				if(ward_id == id) then
					return true;
				elseif(bIncludeQuality) then
					if(ward_id == (id + 1000)) then
						return true;
					elseif(ward_id == (id + 2000)) then
						return true;
					elseif(ward_id == (id + 3000)) then
						return true;
					elseif(ward_id == (id + 4000)) then
						return true;
					end
				end
			end
		end
	end
	return false;
end

-- if unit has positive ward for manipulate
function Mob:HasPositiveWardForManipulate()
	local i;
	for i = 1, #self.wards do
		if(self.wards[i] > 0) then
			local ward_template = Card.GetWardTemplate(self.wards[i]);
			if(ward_template.positive == true and ward_template.can_manipulate ~= false) then
				return true;
			end
		end
	end
	return false;
end

-- if unit has negative ward for manipulate
function Mob:HasNegativeWardForManipulate()
	local i;
	for i = 1, #self.wards do
		if(self.wards[i] > 0) then
			local ward_template = Card.GetWardTemplate(self.wards[i]);
			if(ward_template.positive == false and ward_template.can_manipulate ~= false) then
				return true;
			end
		end
	end
	return false;
end

-- append dot sequence
-- @param sequence: dot damage sequence like {40, 40, 40}
-- NOTE: damage take from the tail of the sequence
-- e.g. for sequence{10, 20, 30} take 30 damage in turn 1, 20 damage in turn 2 and 10 damage in turn 3
function Mob:AppendDoT(sequence)
	if(sequence) then
		table.insert(self.DOTs, sequence);
	end
end

-- pop all dot damage in sequence with damage schools
-- @return: {{damage = 10, damage_school = "fire"}, {damage = 20, damage_school = "wood"}}
function Mob:PopDoT()
	local applied_damages = {};
	-- splash damages comes first
	local _, sequence;
	for _, sequence in ipairs(self.DOTs) do
		local sequence_unit = sequence[#sequence];
		if(#sequence > 0 and sequence_unit and sequence_unit.dmg and sequence_unit.dmg < 0) then
			-- apply dot if sequence is not empty
			local dot = {};
			dot.damage_school = sequence_unit.damage_school or sequence.damage_school;
			dot.buffs_target = sequence.buffs_target;
			dot.pips_realcost = sequence.pips_realcost;
			dot.damage_boost_absolute = sequence_unit.damage_boost_absolute or sequence.damage_boost_absolute;
			dot.spell_penetration = sequence_unit.spell_penetration or sequence.spell_penetration;
			dot.outputdamage_finalweight = sequence.outputdamage_finalweight;
			dot.caster_id = sequence.caster_id;
			dot.damage = sequence_unit.dmg;
			dot.bCritical = sequence_unit.bCritical;
			sequence[#sequence] = nil;
			-- append in the applied damage queue
			table.insert(applied_damages, dot);
		end
	end
	-- then normal damages
	local _, sequence;
	for _, sequence in ipairs(self.DOTs) do
		local sequence_unit = sequence[#sequence];
		if(#sequence > 0 and sequence_unit and sequence_unit.dmg and sequence_unit.dmg >= 0) then
			-- apply dot if sequence is not empty
			local dot = {};
			dot.damage_school = sequence_unit.damage_school or sequence.damage_school;
			dot.buffs_target = sequence.buffs_target;
			dot.pips_realcost = sequence.pips_realcost;
			dot.damage_boost_absolute = sequence_unit.damage_boost_absolute or sequence.damage_boost_absolute;
			dot.spell_penetration = sequence_unit.spell_penetration or sequence.spell_penetration;
			dot.outputdamage_finalweight = sequence.outputdamage_finalweight;
			dot.caster_id = sequence.caster_id;
			dot.damage = sequence_unit.dmg;
			dot.bCritical = sequence_unit.bCritical;			
			sequence[#sequence] = nil;
			-- append in the applied damage queue
			table.insert(applied_damages, dot);
		end
	end
	return applied_damages;
end

-- pop a set of explode dot sequence if exist
-- @return: true if exist
function Mob:PopExplodeDotsIfExist()
	local _, sequence;
	for _, sequence in ipairs(self.DOTs) do
		local i;
		for i = 1, #sequence do
			if(sequence[i].dmg and sequence[i].dmg < 0) then
				-- any negative damage value, reset the sequence
				self.DOTs[_] = {damage_school = sequence.damage_school};
				return true;
			end
		end
	end
	return false;
end

-- append hot sequence
-- @param sequence: hot damage sequence like {40, 40, 40}
-- NOTE: damage take from the tail of the sequence
-- e.g. for sequence{10, 20, 30} take 30 heal in turn 1, 20 heal in turn 2 and 10 heal in turn 3
function Mob:AppendHoT(sequence)
	if(sequence) then
		table.insert(self.HOTs, sequence);
	end
end

-- pop all hot heal in sequence with damage schools
-- @return: {{heal = 10}, {heal = 20}}
function Mob:PopHoT()
	local applied_heals = {};
	local _, sequence;
	for _, sequence in ipairs(self.HOTs) do
		if(#sequence > 0) then
			-- apply hot if sequence is not empty
			local hot = {};
			hot.heal = sequence[#sequence];
			hot.caster_id = sequence.caster_id;
			sequence[#sequence] = nil;
			-- append in the applied heal queue
			table.insert(applied_heals, hot);
		end
	end
	return applied_heals;
end

-- pop all negative effects
function Mob:PopAllNegativeEffects()
	-- pop negative charms
	local i;
	for i = 1, #self.charms do
		local charm_template = Card.GetCharmTemplate(self.charms[i]);
		if(charm_template) then
			if(charm_template.positive == false or charm_template.positive == "false") then
				self.charms[i] = 0;
			end
		end
	end
	-- pop negative wards
	local i;
	for i = 1, #self.wards do
		local ward_template = Card.GetWardTemplate(self.wards[i]);
		if(ward_template and ward_template.can_manipulate ~= false) then
			if(ward_template.positive == false or ward_template.positive == "false") then
				self.wards[i] = 0;
			end
		end
	end
	-- pop negative standing wards
	for i = 1, #self.standing_wards do
		local each_ward = self.standing_wards[i];
		if(each_ward and each_ward.id and each_ward.id ~= 0 and each_ward.rounds and each_ward.rounds > 0) then
			local wardTemplate = Card.GetWardTemplate(each_ward.id)
			if(wardTemplate and wardTemplate.can_manipulate ~= false) then
				if(wardTemplate.positive == false or wardTemplate.positive == "false") then
					each_ward.rounds = 0;
				end
			end
		end
	end
	-- reset dots
	self.DOTs = {};
	-- reset freeze
	self.freeze_rounds = 0;
end

-- append threat
-- @param threat_id: threat id from 1 to 4, NOTE: if the opposite side is far, the range is still from 1 to 4, 
--						associated with the arena slot id from 5 to 8
-- @param unit: combat unit, player or mob
-- @param value: threat value
-- @param pending_values: pending threat values that will be appended to the threat list in the following turns
function Mob:AppendThreat(unit, value, pending_values)
	if(not unit or not value or not unit.GetThreatID or not unit.GetGenerateThreatFinalWeight) then
		LOG.std(nil, "error", "combatmob", "Mob:AppendThreat got invalid input:"..commonlib.serialize_compact({unit, value}));
		return;
	end

	local threat_id = unit:GetThreatID();
	local threat_weight = unit:GetGenerateThreatFinalWeight();

	-- append immediate threat
	self.threats[threat_id] = (self.threats[threat_id] or 0) + value * threat_weight;
	-- append pending threat
	self.threats_pending[threat_id] = self.threats_pending[threat_id] or {};
	if(pending_values) then
		local this_pending_values = pending_values;
		if(threat_weight ~= 1) then
			-- in case of different target share the same pending threats
			this_pending_values = {};
			local _, threat;
			for _, threat in ipairs(pending_values) do
				table.insert(this_pending_values, threat);
			end
		end
		table.insert(self.threats_pending[threat_id], this_pending_values);
	end
end

-- get threat amount from threat id
function Mob:GetThreatFromThreatID(threat_id)
	if(threat_id) then
		return self.threats[threat_id] or 0;
	end
	return 0;
end

-- set to highest threat plus bonus
function Mob:SetHighestThreat(threat_id, threat_bonus)
	local highest_threat = 0;
	local _, threat;
	for _, threat in pairs(self.threats) do
		if(threat > highest_threat) then
			highest_threat = threat;
		end
	end
	-- set highest threat with bonus
	highest_threat = highest_threat + (threat_bonus or 0);
	self.threats[threat_id] = highest_threat;
end

-- clear threat
function Mob:ClearThreat(threat_id)
	self.threats[threat_id] = nil;
	self.threats_pending[threat_id] = nil;
end

-- process pending threat and inc the threat list
function Mob:ProcessPendingThreatPerTurn()
	local arena;
	local arena_id = self.arena_id;
	if(arena_id) then
		arena = Arena.GetArenaByID(arena_id)
		if(not arena) then
			LOG.std(nil, "error", "combatmob", "invalid arena for Mob:ProcessPendingThreatPerTurn");
		end
	else
		LOG.std(nil, "error", "combatmob", "invalid arena_id for Mob:ProcessPendingThreatPerTurn");
	end
	local i;
	for i = 1, 4 do
		local threat = 0;
		local pending_values_s = self.threats_pending[i];
		if(pending_values_s) then
			local _, pending_values;
			for _, pending_values in pairs(pending_values_s) do
				local count = #pending_values;
				if(count > 0) then
					-- inc threat if sequence is not empty
					threat = threat + pending_values[count];
					pending_values[count] = nil;
					if(#pending_values == 0) then
						pending_values_s[_] = nil;
					end
				end
			end
		end
		self.threats[i] = (self.threats[i] or 0) + threat;
		-- if unit is dead, reset the threat
		local unit;
		if(self:GetSide() == "far" and arena) then
			unit = arena:GetCombatUnitBySlotID(i);
		elseif(self:GetSide() == "near" and arena) then
			unit = arena:GetCombatUnitBySlotID(i + 4);
		end
		if(unit and not unit:IsAlive()) then
			threat = 0;
		end
	end
end

-- get charm value string
-- NOTE: latest applied charm comes first
function Mob:GetCharmsValue()
	local value = "";
	-- append guardian charm value
	if(self.bWithGuardian) then
		value = death_singleguardianwithimmolate_charm_id..","..value;
	end
	if(self.stance == "taunt") then
		value = balance_tauntstance_charm_id..","..value;
	end
	local i;
	local nCount = #self.charms;
	for i = 1, nCount do
		local charm = self.charms[i];
		if(charm ~= 0) then
			value = charm..","..value;
		end
	end
	return value;
end

-- get ward value string
-- NOTE: latest applied ward comes first
function Mob:GetWardsValue()
	local value = "";
	-- first append standing wards value
	if(self.reflect_amount > 0) then
		if(System.options.version ~= "kids") then
			value = reflection_shield_id.."_"..self.reflect_amount..","..value;
		end
	else
		if(System.options.version == "kids") then
			self:PopStandingWardIfExist(reflection_shield_id);
		end
	end
	--if(self.reflect_amount > 0) then
		--value = reflection_shield_id.."_"..self.reflect_amount..","..value;
	--end
	-- append stance wards value
	if(self.stance == "defensive") then
		value = ice_defensivestance_ward_id..","..value;
	elseif(self.stance == "healing") then
		value = life_healingstance_ward_id..","..value;
	elseif(self.stance == "blazing") then
		value = fire_blazingstance_ward_id..","..value;
	elseif(self.stance == "electric") then
		value = storm_electricstance_ward_id..","..value;
	elseif(self.stance == "vampire") then
		value = death_vampirestance_ward_id..","..value;
	elseif(self.stance == "pierce") then
		value = ice_piercestance_ward_id..","..value;
	elseif(self.stance == "fire_kids") then
		value = fire_stance_kids_ward_id..","..value;
	elseif(self.stance == "ice_kids") then
		value = ice_stance_kids_ward_id..","..value;
	elseif(self.stance == "storm_kids") then
		value = storm_stance_kids_ward_id..","..value;
	elseif(self.stance == "life_kids") then
		value = life_stance_kids_ward_id..","..value;
	elseif(self.stance == "death_kids") then
		value = death_stance_kids_ward_id..","..value;
	end
	if(self.stealth) then
		value = storm_singlestealth_ward_id..","..value;
	end
	if(self.pierce_freeze_buffs and self.pierce_freeze_rounds) then
		local i;
		for i = 1, self.pierce_freeze_buffs do
			value = ice_piercestance_buff_ward_id.."_"..self.pierce_freeze_rounds..","..value;
		end
	end
	-- then append standing wards value
	local i;
	for i = 1, #self.standing_wards do
		local each_ward = self.standing_wards[i];
		if(each_ward and each_ward.id and each_ward.id ~= 0 and each_ward.rounds and each_ward.rounds > 0) then
			local wardTemplate = Card.GetWardTemplate(each_ward.id)
			if(wardTemplate) then
				if(not wardTemplate.force_overtime) then
					value = each_ward.id..","..value;
				end
			end
		end
	end
	-- next append ordinary wards value
	local i;
	local nCount = #self.wards;
	for i = 1, nCount do
		local ward = self.wards[i];
		if(ward ~= 0) then
			if(self.absorbs[i]) then
				value = ward.."_"..tostring(self.absorbs[i])..","..value;
			else
				value = ward..","..value;
			end
		end
	end
	return value;
end

-- get mini aura value string
function Mob:GetMiniAuraValue()
	if(System.options.version == "teen") then
		if(self.current_hp == 0) then
			if(not self.nid_catchpet) then
				return "dead";
			end
		end
	end
	local value = tostring(self.miniaura or 0);
	if(self.bStunned) then
		value = value..",stun";
	end
	if(self.control_rounds and self.control_rounds > 0) then
		value = value..",control";
	end
	if(self.freeze_rounds > 0) then
		return value..",freeze";
	end
	if(self.stance == "defensive") then
		return value..",defensive";
	elseif(self.stance == "taunt") then
		return value..",taunt";
	end
	if(self.stealth) then
		return value..",stealth";
	end
	return value;
end

-- set the mini aura and validate rounds
--@param aura_id: mini aura id
--@param round: validate rounds, nil for always valid
function Mob:SetMiniAura(aura_id, rounds)
	self.miniaura = aura_id;
	self.miniaura_rounds = rounds;
end

-- validate mini aura rounds
function Mob:ValidateMiniAura()
	if(self.miniaura_rounds and self.miniaura_rounds > 0) then
		self.miniaura_rounds = self.miniaura_rounds - 1;
		-- reset mini aura if no remaining rounds available
		if(self.miniaura_rounds == 0) then
			self.miniaura = nil;
			self.miniaura_rounds = nil;
		end
	end
end

-- set the stance and validate rounds
--@param stance: stance
--@param round: validate rounds, nil for always valid
function Mob:SetStance(stance, rounds)
	self.stance = stance;
	self.stance_rounds = rounds;
end

-- get the stance and validate rounds
-- @return: stance and round
function Mob:GetStance()
	return self.stance, self.stance_rounds;
end

-- validate stance rounds
function Mob:ValidateStance()
	if(self.stance_rounds and self.stance_rounds > 0) then
		self.stance_rounds = self.stance_rounds - 1;
		-- reset stance if no remaining rounds available
		if(self.stance_rounds == 0) then
			self.stance = nil;
			self.stance_rounds = nil;
		end
	end
end

-- is mob immune to dispel
function Mob:IsImmuneToDispel()
	local bImmuneToDispel = self:GetStatByField("is_immune_to_dispel");
	return (bImmuneToDispel == true or bImmuneToDispel == "true");
end

-- is mob immune to stun
function Mob:IsImmuneToStun()
	local bImmuneToStun = self:GetStatByField("is_immune_to_stun");
	return (bImmuneToStun == true or bImmuneToStun == "true");
end

-- is mob immune to freeze
function Mob:IsImmuneToFreeze()
	local bImmuneToFreeze = self:GetStatByField("is_immune_to_freeze");
	return (bImmuneToFreeze == true or bImmuneToFreeze == "true");
end

-- is mob stealth
function Mob:IsStealth()
	return (self.stealth == true);
end

-- set the stealth and validate rounds
--@param round: validate rounds, nil for always valid
function Mob:SetStealthRounds(rounds)
	self.stealth = true;
	self.stealth_rounds = rounds;
end

-- leave stealth status
function Mob:LeaveStealth()
	self.stealth = false;
	self.stealth_rounds = nil;
end

-- validate stealth rounds
function Mob:ValidateStealthRounds()
	if(self.stealth_rounds and self.stealth_rounds > 0) then
		self.stealth_rounds = self.stealth_rounds - 1;
		-- reset stealth if no remaining rounds available
		if(self.stealth_rounds == 0) then
			self.stealth = nil;
			self.stealth_rounds = nil;
		end
	end
end

-- append pierce freeze rounds
--@param round: validate rounds
function Mob:AppendPierceFreezeRounds(rounds)
	if(self.pierce_freeze_buffs) then
		self.pierce_freeze_buffs = self.pierce_freeze_buffs + 1;
	else
		self.pierce_freeze_buffs = 1;
	end
	self.pierce_freeze_rounds = rounds;
end

-- validate pierce freeze rounds
function Mob:ValidatePierceFreezeRounds()
	if(self.pierce_freeze_rounds and self.pierce_freeze_rounds > 0) then
		self.pierce_freeze_rounds = self.pierce_freeze_rounds - 1;
		-- reset stealth if no remaining rounds available
		if(self.pierce_freeze_rounds == 0) then
			self.pierce_freeze_buffs = nil;
			self.pierce_freeze_rounds = nil;
		end
	end
end

-- get final output heal weight
function Mob:GetOutputHealFinalWeight()
	if(self.stance == "healing") then
		return 1.3;
	end
	return 1;
end

-- get final output damage weight
function Mob:GetOutputDamageFinalWeight()
	if(self.stance == "defensive") then
		return 0.8;
	end
	return 1;
end

-- get final receive damage weight
function Mob:GetReceiveDamageFinalWeight(school)
	-- base weight
	local weight = 1;

	-- get stats from mini aura
	if(self.miniaura and self.miniaura_rounds and self.miniaura_rounds > 0) then
		-- stats according to school
		local stats_ids = {};
		table.insert(stats_ids, 119);
		local school_lower = string.lower(school);
		if(school_lower == "fire") then
			table.insert(stats_ids, 120);
		elseif(school_lower == "ice") then
			table.insert(stats_ids, 121);
		elseif(school_lower == "storm") then
			table.insert(stats_ids, 122);
		elseif(school_lower == "myth") then
			table.insert(stats_ids, 123);
		elseif(school_lower == "life") then
			table.insert(stats_ids, 124);
		elseif(school_lower == "death") then
			table.insert(stats_ids, 125);
		elseif(school_lower == "balance") then
			table.insert(stats_ids, 126);
		end

		local miniaura_template = Card.GetMiniAuraTemplate(self.miniaura);
		if(miniaura_template) then
			local extra_weight = 0;
			local _, stat_type;
			for _, stat_type in ipairs(stats_ids) do
				extra_weight = extra_weight + (miniaura_template.stats[stat_type] or 0);
			end
			-- recalculate receive damage weight with extra miniaura applied
			weight = weight * (100 - extra_weight) / 100
			if(weight < 0) then
				-- prevent negative resist
				weight = 0;
			end
		end
	end

	-- additional defensive weight
	if(self.stance == "defensive") then
		return weight * 0.7;
	end
	return weight;
end

-- get threat generation final weight
function Mob:GetGenerateThreatFinalWeight()
	if(self.stance == "defensive") then
		return 3;
	elseif(self.stance == "taunt") then
		return 5;
	end
	return 1;
end

-- validate freeze rounds
function Mob:ValidateFreezeRounds()
	if(self.freeze_rounds and self.freeze_rounds > 0) then
		self.freeze_rounds = self.freeze_rounds - 1;
	end
	if(self.anti_freeze_rounds and self.anti_freeze_rounds > 0) then
		self.anti_freeze_rounds = self.anti_freeze_rounds - 1;
	end
	if(self.anti_freeze_rounds_sibling and self.anti_freeze_rounds_sibling > 0) then
		self.anti_freeze_rounds_sibling = self.anti_freeze_rounds_sibling - 1;
	end
end

-- validate control rounds
function Mob:ValidateControlRounds()
	if(self.control_rounds and self.control_rounds > 0) then
		self.control_rounds = self.control_rounds - 1;
	end
end

-- validate standing effect rounds, including charms, wards and overtime effects
function Mob:ValidateStandingEffects()
	local i;
	for i = 1, #self.standing_wards do
		local each_ward = self.standing_wards[i];
		if(each_ward and each_ward.id and each_ward.id ~= 0 and each_ward.rounds and each_ward.rounds > 0) then
			each_ward.rounds = each_ward.rounds - 1;
		end
		if(System.options.version == "kids" and each_ward and each_ward.id and each_ward.id == reflection_shield_id and each_ward.rounds and each_ward.rounds == 0) then
			self.reflect_amount = 0;
		end
	end
end

-- get over time effect value string, including DoT and HoT
-- NOTE: latest applied over time effect comes first
function Mob:GetOverTimeValue()
	local value = "";
	local i;
	for i = 1, #self.standing_wards do
		local each_ward = self.standing_wards[i];
		if(each_ward and each_ward.id and each_ward.id ~= 0 and each_ward.rounds and each_ward.rounds > 0) then
			local wardTemplate = Card.GetWardTemplate(each_ward.id)
			if(wardTemplate) then
				if(wardTemplate.force_overtime) then
					--local icon_gsid = wardTemplate.icon_gsid or 0;
					local icon_gsid = 0;
					value = wardTemplate.force_overtime.."_"..each_ward.rounds.."_"..icon_gsid..","..value;
				end
			end
		end
	end
	local _, sequence;
	for _, sequence in ipairs(self.DOTs) do
		if(#sequence > 0) then
			local damage_school = sequence.damage_school;
			local icon_gsid = sequence.icon_gsid or 0;
			if(sequence[1] and sequence[1].dmg and sequence[1].dmg < 0) then
				value = damage_school.."splash_"..#sequence.."_"..icon_gsid..","..value;
			else
				value = damage_school.."_"..#sequence.."_"..icon_gsid..","..value;
			end
		end
	end
	local _, sequence;
	for _, sequence in ipairs(self.HOTs) do
		if(#sequence > 0) then
			local icon_gsid = sequence.icon_gsid or 0;
			value = "hot_"..#sequence.."_"..icon_gsid..","..value;
		end
	end
	if(self.anti_freeze_rounds > 0) then
		-- ward 60: anti_freeze
		value = "antifreeze_"..self.anti_freeze_rounds.."_0,"..value;
	end
	if(self.anti_freeze_rounds_sibling > 0) then
		-- ward 66: anti_freeze sibling
		value = "antifreezesibling_"..self.anti_freeze_rounds_sibling.."_0,"..value;
	end
	
	if(self:IsImmuneToDispel()) then
		-- immune to dispel
		value = "immunedispel_1_0,"..value;
	end
	if(self:IsImmuneToStun()) then
		-- immune to stun
		value = "immunestun_1_0,"..value;
	end
	if(self:IsImmuneToFreeze()) then
		-- immune to dispel
		value = "immunefreeze_1_0,"..value;
	end
	if(self:GetStatByField("is_ignore_threat")) then
		value = "ignorethreat_1_0,"..value;
	end
	return value;
end

-- get threat value string
-- NOTE: from 1 to 4
function Mob:GetThreatsValue()
	local value = "";
	local i;
	for i = 1, 4 do
		value = value..","..(self.threats[i] or 0);
	end
	return value;
end

-- get the absorb order list
-- @return: {[10] = 300, [15] = 450}
function Mob:GetAbsorbs()
	return self.absorbs;
end

-- get obsorb point of the given ordered absorb
-- @param order: index into self.absorb, nil if no absorb exist
function Mob:GetAbsorbPtsByOrder(order)
	return self.absorbs[order];
end

-- set obsorb point of the given ordered absorb
-- @param order: index into self.absorb
-- @param absorb_pts_new: new absorb points
function Mob:SetAbsorbPtsByOrder(order, absorb_pts_new)
	if(self.absorbs[order] and self.wards[order] and self.wards[order] > 0) then
		self.absorbs[order] = absorb_pts_new;
	else
		LOG.std(nil, "error", "mob_server", "Mob:SetAbsorbPtsByOrder got invalid input: "..commonlib.serialize({order, absorb_pts_new}));
		LOG.std(nil, "error", "mob_server", "Mob:SetAbsorbPtsByOrder with absorbs: "..commonlib.serialize({self.absorbs}));
	end
end

-- pop absorb ward by order
-- NOTE: both the absorbs and ward will be removed
-- @param order: index into self.absorb
function Mob:PopAbsorbByOrder(order)
	if(self.absorbs[order] and self.wards[order] and self.wards[order] > 0) then
		self.wards[order] = 0;
		self.absorbs[order] = nil;
	else
		LOG.std(nil, "error", "mob_server", "Mob:PopAbsorbByOrder got invalid input: "..commonlib.serialize({order, absorb_pts_new}));
		LOG.std(nil, "error", "mob_server", "Mob:PopAbsorbByOrder with absorbs: "..commonlib.serialize({self.absorbs}));
	end
end

-- if the combat is active, currently all mobs are active combat
function Mob:IsCombatActive()
	return true;
end

-- if mob picked card
function Mob:IfPickedCard()
	if(self.picked_card_key) then
		return true;
	end
	return false;
end

-- if Mob has shield against damage_school
-- NOTE: damage_school could be nil, means only check global shields
function Mob:IfHasShield(damage_school, bSkipGlobalShield)
	local i;
	for i = 1, #self.wards do
		local ward = self.wards[i]
		if(ward ~= 0) then
			local wardTemplate = Card.GetWardTemplate(ward)
			if(wardTemplate) then
				-- damage boost
				if(wardTemplate.boost_damage and wardTemplate.boost_damage < 0) then
					-- NOTE: some mob AI will pick card template with no damage_school
					--		 already tostring(damage_school)
					if(bSkipGlobalShield) then
						if(string_lower(wardTemplate.school) == string_lower(tostring(damage_school))) then
							return true;
						end
					else
						if(string_lower(wardTemplate.school) == string_lower(tostring(damage_school)) or string_lower(wardTemplate.school) == "all") then
							return true;
						end
					end
				end
			end
		end
	end
	return false;
end

-- get damage charm count
-- @param type: damageboost / healboost / damageweakness / healweakness
-- @param school: nil means any school
-- @return: count, max_stacks
function Mob:GetSpecificCharmCount(type, school)
	local count = 0;
	local max_stacks = 0;
	local stack_records = {};
	local i;
	for i = 1, #self.charms do
		local charm = self.charms[i]
		if(charm ~= 0) then
			local charmTemplate = Card.GetCharmTemplate(charm)
			if(charmTemplate) then
				local function ProcessOneCharm(id)
					local k = math.mod(id, 1000);
					stack_records[k] = (stack_records[k] or 0) + 1;
				end
				local bSchoolMatch = false;
				if(charmTemplate.school == school) then
					bSchoolMatch = true;
				elseif(charmTemplate.school == "all") then
					bSchoolMatch = true;
				elseif(not school) then
					bSchoolMatch = true;
				end
				if(type == "damageboost") then
					if(charmTemplate.boost_damage and charmTemplate.boost_damage > 0 and bSchoolMatch) then
						ProcessOneCharm(charm);
					end
				elseif(type == "healboost") then
					if(charmTemplate.boost_heal and charmTemplate.boost_heal > 0) then
						ProcessOneCharm(charm);
					end
				elseif(type == "damageweakness") then
					if(charmTemplate.boost_damage and charmTemplate.boost_damage < 0 and bSchoolMatch) then
						ProcessOneCharm(charm);
					end
				elseif(type == "healweakness") then
					if(charmTemplate.boost_heal and charmTemplate.boost_heal < 0) then
						ProcessOneCharm(charm);
					end
				end
			end
		end
	end
	local _, nStack;
	for _, nStack in pairs(stack_records) do
		count = count + 1;
		if(nStack > max_stacks) then
			max_stacks = nStack;
		end
	end
	return count, max_stacks;
end

-- get damage ward count
-- @param type: damageshield / damagetrap
-- @param school: nil means any school
-- @return: count, max_stacks
function Mob:GetSpecificWardCount(type, school)
	local count = 0;
	local max_stacks = 0;
	local stack_records = {};
	local i;
	for i = 1, #self.wards do
		local ward = self.wards[i]
		if(ward ~= 0) then
			local wardTemplate = Card.GetWardTemplate(ward)
			if(wardTemplate) then
				local function ProcessOneWard(id)
					local k = math.mod(id, 1000);
					stack_records[k] = (stack_records[k] or 0) + 1;
				end
				local bSchoolMatch = false;
				if(wardTemplate.school == school) then
					bSchoolMatch = true;
				elseif(wardTemplate.school == "all") then
					bSchoolMatch = true;
				elseif(not school) then
					bSchoolMatch = true;
				end
				if(type == "damageshield") then
					if(wardTemplate.boost_damage and wardTemplate.boost_damage > 0 and bSchoolMatch) then
						ProcessOneWard(ward);
					end
				elseif(type == "damageschool") then
					if(wardTemplate.boost_damage and wardTemplate.boost_damage < 0 and bSchoolMatch) then
						ProcessOneWard(ward);
					end
				end
			end
		end
	end
	local _, nStack;
	for _, nStack in pairs(stack_records) do
		count = count + 1;
		if(nStack > max_stacks) then
			max_stacks = nStack;
		end
	end
	return count, max_stacks;
end

-- if mob has defend miniaura
function Mob:IfHasDefendMiniaura(damage_school)
	if(self.miniaura and self.miniaura_rounds and self.miniaura_rounds > 0) then
		local miniaura_template = Card.GetMiniAuraTemplate(self.miniaura);
		if(miniaura_template) then
			--119 add_resist_overall_percent(CG) 增加用户所有系魔法的附加抗性百分比  
			--120 add_resist_fire_percent(CG) 增加用户火系魔法的附加抗性百分比  
			--121 add_resist_ice_percent(CG) 增加用户冰系魔法的附加抗性百分比  
			--122 add_resist_storm_percent(CG) 增加用户风暴系魔法的附加抗性百分比  
			--123 add_resist_myth_percent(CG) 增加用户神秘系魔法的附加抗性百分比  
			--124 add_resist_life_percent(CG) 增加用户生命系魔法的附加抗性百分比  
			--125 add_resist_death_percent(CG) 增加用户死亡系魔法的附加抗性百分比  
			--126 add_resist_balance_percent(CG) 增加用户平衡系魔法的附加抗性百分比 

			--159 add_resist_overall_absolute(CG) 增加用户所有系魔法的附加抗性绝对值(青年版用这个)  
			--160 add_resist_fire_absolute(CG) 增加用户火系魔法的附加抗性绝对值(青年版用这个)  
			--161 add_resist_ice_absolute(CG) 增加用户冰系魔法的附加抗性绝对值(青年版用这个)  
			--162 add_resist_storm_absolute(CG) 增加用户风暴系魔法的附加抗性绝对值(青年版用这个)  
			--163 add_resist_myth_absolute(CG) 增加用户神秘系魔法的附加抗性绝对值(青年版用这个)  
			--164 add_resist_life_absolute(CG) 增加用户生命系魔法的附加抗性绝对值(青年版用这个)  
			--165 add_resist_death_absolute(CG) 增加用户死亡系魔法的附加抗性绝对值(青年版用这个)  
			--166 add_resist_balance_absolute(CG) 增加用户平衡系魔法的附加抗性绝对值(青年版用这个)  

			if(miniaura_template.stats[119] or miniaura_template.stats[159]) then
				return true;
			end
			if(damage_school == "fire") then
				if(miniaura_template.stats[120] or miniaura_template.stats[160]) then
					return true;
				end
			elseif(damage_school == "ice") then
				if(miniaura_template.stats[121] or miniaura_template.stats[161]) then
					return true;
				end
			elseif(damage_school == "storm") then
				if(miniaura_template.stats[122] or miniaura_template.stats[162]) then
					return true;
				end
			elseif(damage_school == "myth") then
				if(miniaura_template.stats[123] or miniaura_template.stats[163]) then
					return true;
				end
			elseif(damage_school == "life") then
				if(miniaura_template.stats[124] or miniaura_template.stats[164]) then
					return true;
				end
			elseif(damage_school == "death") then
				if(miniaura_template.stats[125] or miniaura_template.stats[165]) then
					return true;
				end
			elseif(damage_school == "balance") then
				if(miniaura_template.stats[126] or miniaura_template.stats[166]) then
					return true;
				end
			end
		end
	end
	return false;
end

-- mob pick card
function Mob:PickCard(card_key, card_seq, isMob, id, accuracy_boost, motion, force_pip_cost)
	self.picked_card_key = card_key;
	self.picked_card_seq = card_seq;
	self.picked_card_target_ismob = isMob;
	self.picked_card_target_id = id;
	self.picked_card_accuracy_boost = accuracy_boost;
	self.picked_card_motion = motion;
	self.picked_card_force_pip_cost = force_pip_cost;
end

-- clear picked card
function Mob:ClearPickedCard()
	self.picked_card_key = nil;
	self.picked_card_seq = nil;
	self.picked_card_target_ismob = nil;
	self.picked_card_target_id = nil;
	self.picked_card_accuracy_boost = nil;
	self.picked_card_motion = nil;
	self.picked_card_force_pip_cost = nil;
end

-- get pick card motion
function Mob:GetPickCardMotion()
	return self.picked_card_motion;
end

-- get picked card key
function Mob:GetPickedCardKey()
	return self.picked_card_key;
end

-- use card to generate damage or heal, 
-- @param arena: arena object
-- @param sequence: spell play sequence of the turn, each spell play is appended to the table
function Mob:UseCard(arena, sequence)
	-- user the player card
	local bCasted, pips_realcost = Card.UseCard(
		self.picked_card_key,
		0,
		arena,
		{
			isMob = true,
			id = self:GetID(),
		}, 
		{
			isMob = self.picked_card_target_ismob,
			id = self.picked_card_target_id,
		}, 
		sequence);
		
	-- post use card process
	Card.UseCard_post(
		self.picked_card_key,
		arena,
		{
			isMob = true,
			id = self:GetID(),
		}, 
		{
			isMob = self.picked_card_target_ismob,
			id = self.picked_card_target_id,
		}, 
		sequence);
	return bCasted;
end

-- all mob template commons
local all_mob_commons = {};

-- init common attributes csv
function Mob.InitCommonAttributes_csv(config_file)
	local file = ParaIO.open(config_file, "r");
	if(file:IsValid() ~= true) then
		commonlib.log("error: failed loading common attribute list file: %s\n", config_file);
		return;
	end
	LOG.std(nil, "info", "mob_server", "server loaded common attribute list file %s", config_file);
	local params_keys = {};
	local line = file:readline();
	if(line) then
		-- first line for keys
		local each_key;
		for each_key in string.gmatch(line, "[^,]+") do
			local each_key = string.match(each_key, "^(.*)$");
			if(each_key and each_key ~= "") then
				table.insert(params_keys, each_key);
			end
		end
	end
	-- read next line
	line = file:readline();
	while(line) do
		-- process each card line
		local each_common_attribute = {};
		local each_value;
		local seq = 1;
		for each_value in string.gmatch(line, "[^,]+") do
			local each_value = string.match(each_value, "^(.*)$");
			if(each_value and each_value ~= "") then
				each_common_attribute[params_keys[seq]] = tonumber(each_value) or each_value;
			end
			seq = seq + 1;
		end
		if(each_common_attribute.name) then
			each_common_attribute.name = "config/Aries/Mob_Teen/"..each_common_attribute.name;
			all_mob_commons[each_common_attribute.name] = each_common_attribute;
		end
		-- read next line
		line = file:readline();
	end
	file:close();
end

-- init common loots csv
function Mob.InitCommonLoots_csv(config_file)
	local file = ParaIO.open(config_file, "r");
	if(file:IsValid() ~= true) then
		commonlib.log("error: failed loading common loot list file: %s\n", config_file);
		return;
	end
	LOG.std(nil, "info", "mob_server", "server loaded common loot list file %s", config_file);
	local params_keys = {};
	local line = file:readline();
	-- read next line
	line = file:readline();
	while(line) do
		-- process each card line
		local each_common_attribute = {};
		local each_value;
		local name;
		local loot_line;
		local loot_original = "{";
		local each_loot_pair_gsid;
		local each_loot_pair_count;
		local seq = 1;
		for each_value in string.gmatch(line, "[^,]+,?") do
			local each_value = string.match(each_value, "^([^,]+)");
			if(each_value and each_value ~= "") then
				each_value = tonumber(each_value) or each_value;
				if(seq == 1) then
					name = each_value; -- first value is mob template name
					name = "config/Aries/Mob_Teen/"..name;
					all_mob_commons[name] = all_mob_commons[name] or {};
				elseif(seq == 2) then
					if(each_value == 1 or each_value == 2 or each_value == 3) then
						loot_line = each_value; -- second value is the loot line index
					end
					all_mob_commons[name]["loot"..loot_line] = {};
				else
					if(math.mod(seq, 3) == 0) then
						each_loot_pair_gsid = each_value; -- loot gsid
					elseif(math.mod(seq, 3) == 1) then
						each_loot_pair_count = each_value; -- loot count
					elseif(math.mod(seq, 3) == 2) then
						local chance = each_value; -- loot chance
						-- mark the chance
						all_mob_commons[name]["loot"..loot_line][each_loot_pair_gsid..","..each_loot_pair_count] = chance;
						-- append the loot original string
						loot_original = loot_original.."["..each_loot_pair_gsid..","..each_loot_pair_count.."]="..chance..",";
						each_loot_pair_gsid = nil;
						each_loot_pair_count = nil;
					end
				end
			end
			seq = seq + 1;
		end
		-- record loot line original string
		loot_original = loot_original.."}";
		all_mob_commons[name]["loot"..loot_line.."_original"] = loot_original;
		-- read next line
		line = file:readline();
	end

	file:close();
end

local base_lootable_key_names = {
	["loot1"] = true,
	["loot2"] = true,
	["loot3"] = true,
	["loot4"] = true,
	["loot5"] = true,
	["loot6"] = true,
	["loot7"] = true,
	["loot8"] = true,
	["loot9"] = true,
	["loot10"] = true,
	["roll_card"] = true,
	["roll_item"] = true,
	["loot1_enrage"] = true,
	["loot2_enrage"] = true,
	["loot3_enrage"] = true,
	["loot_fire"] = true,
	["loot_ice"] = true,
	["loot_storm"] = true,
	["loot_life"] = true,
	["loot_death"] = true,
	["loot_myth"] = true,
	["shared_loot"] = true,
};

local lootable_key_names = {};

local base_key, _;
for base_key, _ in pairs(base_lootable_key_names) do
	lootable_key_names[base_key] = true;
	lootable_key_names[base_key.."_easy"] = true;
	lootable_key_names[base_key.."_hard"] = true;
	lootable_key_names[base_key.."_hero"] = true;
	lootable_key_names[base_key.."_nightmare"] = true;
end

-- get stats by field
-- @param fieldname: field name of the attributes
function Mob:GetStatByField(fieldname)
	local template_key = self.template_key;
	if(template_key) then
		-- check mob stats common attributes prior to mob_template stats
		local common_template = all_mob_commons[template_key];
		if(common_template) then
			local value = common_template[fieldname];
			if(value) then
				return value;
			end
		end
		local template = MobTemplate.GetTemplate(template_key);
		if(template and template.stats) then
			if(self:IsEnraged()) then
				local enrage_stats_key = template.stats.enrage_stats_key;
				if(enrage_stats_key) then
					local this_EnrageStats = EnrageStats[enrage_stats_key];
					if(this_EnrageStats) then
						local value = this_EnrageStats[fieldname];
						if(value) then
							return value;
						end
					end
				end
			end
			-- parse the field to table if available
			local value = template.stats[fieldname];
			if((lootable_key_names[fieldname]) and type(value) == "string") then
				local original_value = value;
				value = string.gsub(value, "%[", "[\"");
				value = string.gsub(value, "%]", "\"]");
				local loot = commonlib.LoadTableFromString(value);
				if(loot) then
					template.stats[fieldname] = loot;
					template.stats[fieldname.."_original"] = original_value;
				else
					template.stats[fieldname] = nil;
				end
			end
			return template.stats[fieldname];
		end
	end
end

-- get stats by field
-- @param fieldname: field name of the attributes
function Mob:GetStatByField_original(fieldname)
	local template_key = self.template_key;
	if(template_key) then
		-- check mob stats common attributes prior to mob_template stats
		local common_template = all_mob_commons[template_key];
		if(common_template) then
			local value = common_template[fieldname.."_original"] or common_template.stats[fieldname];
			if(value) then
				return value;
			end
		end
		local template = MobTemplate.GetTemplate(template_key);
		if(template and template.stats) then
			return template.stats[fieldname.."_original"] or template.stats[fieldname];
		end
	end
end

-- read AI cards form cardsets
function MobTemplate.ReadFrom_cardsets(xmlRoot, output)
	if(not xmlRoot or not output) then
		return;
	end
	-- fetch all card sets if available
	local cardsets;
	for cardsets in commonlib.XPath.eachNode(xmlRoot, "/mobtemplate/cardsets") do
		-- parse card set cards and weight
		local eachset;
		for eachset in commonlib.XPath.eachNode(cardsets, "/set") do
			local id = tonumber(eachset.attr.id);
			local cards = eachset.attr.cards;
			-- card set
			local cards_weight_nonzeropip = {};
			local cards_weight_zeropip = {};
			local eachset_available_cards = eachset.attr.cards;
			if(eachset_available_cards) then
				local card_gsid_weight_pair;
				for card_gsid_weight_pair in string.gmatch(eachset_available_cards, "([^%(^%)]+)") do
					local card_gsid, weight = string.match(card_gsid_weight_pair, "^(%d-),(.-)$");
					if(card_gsid and weight) then
						card_gsid = tonumber(card_gsid);
						weight = tonumber(weight);
						local key = Card.Get_cardkey_from_gsid(card_gsid) or Card.Get_cardkey_from_rune_gsid(card_gsid);
						local template = Card.GetCardTemplate(key);
						if(template and key) then
							local pipcost = template.pipcost;
							if(pipcost == 0) then
								table.insert(cards_weight_zeropip, {key, weight});
							else
								table.insert(cards_weight_nonzeropip, {key, weight});
							end
						end
					end
				end
			end
			-- record the card set in the mob template
			output[id] = {
				cards_weight_nonzeropip = cards_weight_nonzeropip,
				cards_weight_zeropip = cards_weight_zeropip,
			};
		end
	end
end

-- read AI cards form aisets
function MobTemplate.ReadFrom_aisets(xmlRoot, output)
	if(not xmlRoot or not output) then
		return;
	end
	-- fetch all card sets if available
	local aisets;
	for aisets in commonlib.XPath.eachNode(xmlRoot, "/mobtemplate/aisets") do
		-- parse card set cards and weight
		local eachset;
		for eachset in commonlib.XPath.eachNode(aisets, "/set") do
			local id = tonumber(eachset.attr.id);
			local cards = eachset.attr.cards;
			-- card set
			local cards_weight_nonzeropip = {};
			local cards_weight_zeropip = {};
			local cards_weight_ai_module = {};
			local eachset_available_cards = eachset.attr.cards;
			if(eachset_available_cards) then
				local card_gsid_weight_pair;
				for card_gsid_weight_pair in string.gmatch(eachset_available_cards, "([^%(^%)]+)") do
					local card_gsid, weight = string.match(card_gsid_weight_pair, "^(%d-),(.-)$");
					if(card_gsid and weight) then
						card_gsid = tonumber(card_gsid);
						weight = tonumber(weight);
						local key = Card.Get_cardkey_from_gsid(card_gsid) or Card.Get_cardkey_from_rune_gsid(card_gsid);
						local template = Card.GetCardTemplate(key);
						if(template and key) then
							local pipcost = template.pipcost;
							if(pipcost == 0) then
								table.insert(cards_weight_zeropip, {key, weight});
							else
								table.insert(cards_weight_nonzeropip, {key, weight});
							end
						end
					end
					local card_gsid, weight, ai_module = string.match(card_gsid_weight_pair, "^(%d-),(.-),(.-)$");
					if(card_gsid and weight and ai_module) then
						card_gsid = tonumber(card_gsid);
						weight = tonumber(weight);
						local key = Card.Get_cardkey_from_gsid(card_gsid) or Card.Get_cardkey_from_rune_gsid(card_gsid);
						local template = Card.GetCardTemplate(key);
						if(template and key) then
							table.insert(cards_weight_ai_module, {key, weight, ai_module});
						end
					end
				end
			end
			-- record the card set in the mob template
			output[id] = {
				cards_weight_nonzeropip = cards_weight_nonzeropip,
				cards_weight_zeropip = cards_weight_zeropip,
				cards_weight_ai_module = cards_weight_ai_module,
			};
		end
	end
end

-- read AI cards form sequences
function MobTemplate.ReadFrom_sequences(xmlRoot, sequences, sequences_bonus_round_before, sequences_bonus_round_after, template_key)
	if(not xmlRoot or not sequences or not sequences_bonus_round_before or not sequences_bonus_round_after) then
		return;
	end
	-- fetch all mob AI genes if available
	local sequence;
	for sequence in commonlib.XPath.eachNode(xmlRoot, "/mobtemplate/sequences/sequence") do
		local data_sequence = {};
		local data_sequence_bonus_round_before = {};
		local data_sequence_bonus_round_after = {};
		-- parse each AI genes
		local each_round;
		for each_round in commonlib.XPath.eachNode(sequence, "/round") do
			-- NOTE: round is a MUST have attributes, identifying which gene is applied to the next turn
			local data_round = commonlib.deepcopy(each_round.attr);
			local _, v;
			for _, v in pairs(data_round) do
				local template_key_lower = string.lower(template_key);
				local group = locale_word_groups[template_key_lower];
				if(group) then
					if(group[v]) then
						data_round[_] = group[v];
					end
				end
			end
			-- round
			if(not data_round.round) then
				LOG.std(nil, "error", "combatmob", "absent round field:round for template_key:"..tostring(template_key));
			end
			-- card
			if(data_round.card or data_round.card_set) then
				data_round.card_or_set = data_round.card or tonumber(data_round.card_set);
				data_round.card = nil;
				data_round.card_set = nil;
				if(tonumber(data_round.card_or_set)) then
					-- translate the card gsid to card key if available
					local gsid = tonumber(data_round.card_or_set);
					if(gsid) then
						local card_key = Card.Get_cardkey_from_gsid(gsid) or Card.Get_cardkey_from_rune_gsid(gsid);
						if(card_key) then
							data_round.card_or_set = card_key;
						end
					end
				end
			else
				LOG.std(nil, "error", "combatmob", "absent round field:card or card_set for template_key:"..tostring(template_key));
			end
			-- accuracy boost
			if(data_round.accuracy_boost) then
				data_round.accuracy_boost = tonumber(data_round.accuracy_boost);
			end
			if(data_round.force_pip_cost) then
				data_round.force_pip_cost = tonumber(data_round.force_pip_cost);
			end
			-- explicit motion
			if(data_round.motion) then
				data_round.motion = data_round.motion;
			end
			-- keep the data_round reference
			if(data_round.round) then
				local round, tag = string.match(data_round.round, "^(%d+)([%+%-]*)$");
				if(round and tag) then
					round = tonumber(round);
					if(tag == "") then
						data_sequence[round] = data_round;
					elseif(tag == "-") then
						data_sequence_bonus_round_before[round] = data_round;
					elseif(tag == "+") then
						data_sequence_bonus_round_after[round] = data_round;
					end
				end
			end
		end
		-- keep the sequence reference
		table.insert(sequences, data_sequence);
		table.insert(sequences_bonus_round_before, data_sequence_bonus_round_before);
		table.insert(sequences_bonus_round_after, data_sequence_bonus_round_after);
	end
end

-- read AI cards form genes
function MobTemplate.ReadFrom_genes(xmlRoot, output_genes, template_key)
	if(not xmlRoot or not output_genes) then
		return;
	end
	local max_priority = 0;
	-- fetch all mob AI genes if available
	local genes;
	for genes in commonlib.XPath.eachNode(xmlRoot, "/mobtemplate/genes") do
		-- parse each AI genes
		local each_gene;
		for each_gene in commonlib.XPath.eachNode(genes, "/gene") do
			-- NOTE: priority and hp condition are two MUST have attributes, identifying which gene is applied to the next turn
			local gene = commonlib.deepcopy(each_gene.attr);
			local _, v;
			for _, v in pairs(gene) do
				local template_key_lower = string.lower(template_key);
				local group = locale_word_groups[template_key_lower];
				if(group) then
					if(group[v]) then
						gene[_] = group[v];
					end
				end
			end
			-- priority and weight
			if(not gene.priority) then
				LOG.std(nil, "error", "combatmob", "absent gene field:priority for template_key:"..tostring(template_key));
			end
			gene.priority = tonumber(gene.priority);
			if(gene.priority > max_priority) then
				max_priority = gene.priority;
			end
			if(gene.priority_weight_percent) then
				gene.priority_weight_percent = tonumber(gene.priority_weight_percent);
			else
				gene.priority_weight_percent = 100; -- default 100% proc chance
			end
			-- card
			if(gene.card or (gene.card_set or gene.ai_set)) then
				gene.card_or_set = gene.card or tonumber(gene.card_set);
				if(tonumber(gene.ai_set)) then
					gene.card_or_set = -tonumber(gene.ai_set); -- negetive for ai_set
				end
				gene.card = nil;
				gene.card_set = nil;
				if(tonumber(gene.card_or_set)) then
					-- translate the card gsid to card key if available
					local gsid = tonumber(gene.card_or_set);
					if(gsid) then
						local card_key = Card.Get_cardkey_from_gsid(gsid) or Card.Get_cardkey_from_rune_gsid(gsid);
						if(card_key) then
							gene.card_or_set = card_key;
						end
					end
				end
			else
				LOG.std(nil, "error", "combatmob", "absent gene field:card or card_set for template_key:"..tostring(template_key));
			end
			-- HP
			if(gene.hp_drop) then
				gene.hp_drop = tonumber(gene.hp_drop);
			elseif(gene.hp_range) then
				local hp_range_lower, hp_range_upper = string.match(gene.hp_range, "^(%d-),(%d-)$");
				if(hp_range_lower and hp_range_upper) then
					gene.hp_range_lower = tonumber(hp_range_lower);
					gene.hp_range_upper = tonumber(hp_range_upper);
					gene.hp_range = nil;
				else
					LOG.std(nil, "error", "combatmob", "invalid gene field:hp_range for template_key:"..tostring(template_key));
				end
			else
				LOG.std(nil, "error", "combatmob", "absent gene field:hp_drop or hp_range for template_key:"..tostring(template_key));
			end
			-- accuracy boost
			if(gene.accuracy_boost) then
				gene.accuracy_boost = tonumber(gene.accuracy_boost) or 0;
			else
				gene.accuracy_boost = 0;
			end
			if(gene.force_pip_cost) then
				gene.force_pip_cost = tonumber(gene.force_pip_cost);
			end
			-- explicit motion
			if(gene.motion) then
				gene.motion = gene.motion;
			end
			-- keep the gene reference
			output_genes[gene.priority] = output_genes[gene.priority] or {};
			table.insert(output_genes[gene.priority], gene);
		end
	end
	-- record the maximum priority
	output_genes.max_priority = max_priority;
end


-- read AI cards form available_cards
function MobTemplate.ReadFrom_available_cards(available_cards_str, output)
	if(not available_cards_str or not output) then
		return;
	end
	local cards_weight_nonzeropip = {};
	local cards_weight_zeropip = {};
	local card_gsid_weight_pair;
	for card_gsid_weight_pair in string.gmatch(available_cards_str, "([^%(^%)]+)") do
		local card_gsid, weight = string.match(card_gsid_weight_pair, "^(%d-),(.-)$");
		if(card_gsid and weight) then
			card_gsid = tonumber(card_gsid);
			weight = tonumber(weight);
			local key = Card.Get_cardkey_from_gsid(card_gsid) or Card.Get_cardkey_from_rune_gsid(card_gsid);
			local template = Card.GetCardTemplate(key);
			if(template and key) then
				local pipcost = template.pipcost;
				if(pipcost == 0) then
					table.insert(cards_weight_zeropip, {key, weight});
				else
					table.insert(cards_weight_nonzeropip, {key, weight});
				end
			end
		end
	end
	
	output.cards_weight_nonzeropip = cards_weight_nonzeropip;
	output.cards_weight_zeropip = cards_weight_zeropip;
end

function MobTemplate:new(template_key, explicitXMLRoot)
	-- return the mob template if exist
	local template = MobTemplate.GetTemplate(template_key);
	if(template) then
		return template;
	end
	
	-- create new mob template
	local o = {}; -- new table
	-- read the mob template file
	local xmlRoot;
	if(explicitXMLRoot) then
		commonlib.log("info: loading mob config from explicitXMLRoot: %s\n", tostring(template_key));
		xmlRoot = explicitXMLRoot;
	else
		local config_file = template_key;
		local file = string.match(template_key, "^([^@]+)@")
		if(file) then
			-- ai pvp config files
			config_file = file;
		end
		xmlRoot = ParaXML.LuaXML_ParseFile(config_file);
	end
	if(not xmlRoot) then
		LOG.std(nil, "error", "combatmob", "failed loading mob template template_key:"..tostring(template_key));
		return;
	end
	-- fetch all mob template attributes
	local mob_template;
	for mob_template in commonlib.XPath.eachNode(xmlRoot, "/mobtemplate/mob") do
		-- copy all mob_template attributes to stats table
		o.stats = commonlib.deepcopy(mob_template.attr);
		local _, v;
		for _, v in pairs(o.stats) do
			local template_key_lower = string.lower(template_key);
			local group = locale_word_groups[template_key_lower];
			if(group) then
				if(group[v]) then
					o.stats[_] = group[v]
				end
			end
		end
	end

	-- available_cards
	local template_available_cards = o.stats.available_cards;
	MobTemplate.ReadFrom_available_cards(template_available_cards, o);

	-- template card sets
	o.cardsets = {};
	MobTemplate.ReadFrom_cardsets(xmlRoot, o.cardsets);
	
	-- template ai sets
	o.aisets = {};
	MobTemplate.ReadFrom_aisets(xmlRoot, o.aisets);
	
	-- template genes
	o.sequences = {};
	o.sequences_bonus_round_before = {};
	o.sequences_bonus_round_after = {};
	MobTemplate.ReadFrom_sequences(xmlRoot, o.sequences, o.sequences_bonus_round_before, o.sequences_bonus_round_after, template_key);

	-- template genes
	o.genes = {};
	MobTemplate.ReadFrom_genes(xmlRoot, o.genes, template_key);
	
	-- assert essetial fields
	local essential_field_names = {
		"displayname", "hp", "scale", "asset", "experience_pts", "level"
		--"displayname", "hp", "scale", "asset", "experience_pts", "available_cards", 
	};

	if(System.options.version == "teen") then
		essential_field_names = {
			"displayname", "hp", "scale", "asset", "level", "phase" -- remove experience_pts for teen version
		};
	end

	local _, name;
	for _, name in pairs(essential_field_names) do
		if(not o.stats[name]) then
			LOG.std(nil, "error", "combatmob", "absent field:"..name.." for template_key:"..tostring(template_key));
		end
	end

	-- force joybean and exp config from mob level for teen version
	if(System.options.version == "teen") then
		o.stats.joybean_count = math_ceil((o.stats.level or 1) * 0.4);
		local rarity = o.stats.rarity;
		local weight_exp_pts = 1;
		if(rarity == "boss") then
			weight_exp_pts = 5;
		elseif(rarity == "elite") then
			weight_exp_pts = 3;
		end
		o.stats.experience_pts = math_ceil(((o.stats.level or 1) * 10 + 0) * weight_exp_pts);
	end

	if(System.options.version == "kids") then
		o.stats.joybean_count = 0;
	end

	o.stats.phase = string.lower(o.stats.phase);
	if(o.stats.rarity) then
		o.stats.rarity = string.lower(o.stats.rarity);
	end

	-- apply global card loot for teen version
	if(true) then
		local level = tonumber(o.stats.level);
		local phase = string.lower(o.stats.phase or "all");
		local rarity = string.lower(o.stats.rarity or "normal");
		if(level and phase and rarity) then
			local _, each_globalloot;
			for _, each_globalloot in ipairs(GlobalCardLoot) do
				if(level >= each_globalloot.level_from and level <= each_globalloot.level_to) then
					if(phase == each_globalloot.school or each_globalloot.school == "all" or System.options.version == "kids") then
						if(rarity == each_globalloot.rarity or System.options.version == "kids") then
							-- assign the global card loot
							o.stats.roll_card_easy = each_globalloot.roll_card_easy;
							o.stats.roll_card = each_globalloot.roll_card;
							o.stats.roll_card_hard = each_globalloot.roll_card_hard;
							o.stats.roll_card_hero = each_globalloot.roll_card_hero;
							o.stats.roll_card_nightmare = each_globalloot.roll_card_nightmare;
							break;
						end
					end
				end
			end
			if(System.options.version == "teen") then
				local _, each_globalloot;
				for _, each_globalloot in ipairs(GlobalItemLoot) do
					if(level >= each_globalloot.level_from and level <= each_globalloot.level_to) then
						if(phase == each_globalloot.school or each_globalloot.school == "all") then
							if(rarity == each_globalloot.rarity) then
								-- assign the global card loot
								o.stats.roll_item_easy = each_globalloot.roll_item_easy;
								o.stats.roll_item = each_globalloot.roll_item;
								o.stats.roll_item_hard = each_globalloot.roll_item_hard;
								o.stats.roll_item_hero = each_globalloot.roll_item_hero;
								o.stats.roll_item_nightmare = each_globalloot.roll_item_nightmare;
								break;
							end
						end
					end
				end
			end
		end
	end
	
	-- apply enrage loot
	local enrage_loot_key = o.stats.enrage_loot_key;
	if(enrage_loot_key) then
		local enrage_loot = EnrageLoot[enrage_loot_key];
		if(enrage_loot) then
			-- assign the global card loot
			o.stats.loot1_enrage_easy = enrage_loot.loot1_enrage_easy;
			o.stats.loot1_enrage = enrage_loot.loot1_enrage;
			o.stats.loot1_enrage_hard = enrage_loot.loot1_enrage_hard;
			o.stats.loot1_enrage_hero = enrage_loot.loot1_enrage_hero;
			o.stats.loot1_enrage_nightmare = enrage_loot.loot1_enrage_nightmare;
			o.stats.loot2_enrage_easy = enrage_loot.loot2_enrage_easy;
			o.stats.loot2_enrage = enrage_loot.loot2_enrage;
			o.stats.loot2_enrage_hard = enrage_loot.loot2_enrage_hard;
			o.stats.loot2_enrage_hero = enrage_loot.loot2_enrage_hero;
			o.stats.loot2_enrage_nightmare = enrage_loot.loot2_enrage_nightmare;
			o.stats.loot3_enrage_easy = enrage_loot.loot3_enrage_easy;
			o.stats.loot3_enrage = enrage_loot.loot3_enrage;
			o.stats.loot3_enrage_hard = enrage_loot.loot3_enrage_hard;
			o.stats.loot3_enrage_hero = enrage_loot.loot3_enrage_hero;
			o.stats.loot3_enrage_nightmare = enrage_loot.loot3_enrage_nightmare;
		end
	end

	-- keep a reference
	MobTemplate.templates[template_key] = o;

	setmetatable(o, self);
	self.__index = self
	return o;
end

function MobTemplate.GetTemplate(template_key)
	return MobTemplate.templates[template_key];
end

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
			log("error: card not valid for key:"..tostring(card_key).." in function PickFromCards\n")
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

-- pick card from ai module cards
local function PickFromAiModuleCards(aiset, caster)
	if(aiset and caster and aiset.cards_weight_ai_module) then
		local all_results = {};
		local card_count = 0;
		local _, pair;
		for _, pair in ipairs(aiset.cards_weight_ai_module) do
			local template = Card.GetCardTemplate(pair[1])
			if(not template) then
				log("error: card not valid for key:"..tostring(pair[1]).." in function PickFromAiModuleCards\n")
				return "Pass";
			end
			
			if(caster:CanCastSpell(pair[1])) then
				local each_card, each_target_ismob, each_target_id = Player.GetCardFromAction(caster, pair[1], pair[3]);
				if(each_card and each_target_ismob ~= nil and each_target_id) then
					card_count = card_count + pair[2];
					table.insert(all_results, {each_card, each_target_ismob, each_target_id, pair[2]});
				end
			end
		end
		local random_seq = math.random(0, card_count);
		local picked_card = "Pass";
		local picked_card_ismob;
		local picked_card_id;
		local _, pair;
		for _, pair in ipairs(all_results) do
			random_seq = random_seq - pair[4];
			if(random_seq <= 0) then
				picked_card = pair[1];
				picked_card_ismob = pair[2];
				picked_card_id = pair[3];
				break;
			end
		end
		if(picked_card and picked_card_ismob ~= nil and picked_card_id) then
			return picked_card, picked_card_ismob, picked_card_id;
		end
	end
	return "Pass";
end

-- get friendly target from tag
function Mob:GetFriendlyTarget_genes_attacker(tag)
	-- get arena object
	local arena;
	local arena_id = self.arena_id;
	if(arena_id) then
		arena = Arena.GetArenaByID(arena_id)
		if(not arena) then
			LOG.std(nil, "error", "combatmob", "invalid arena for Mob:GetFriendlyTarget_genes_attacker");
		end
	else
		LOG.std(nil, "error", "combatmob", "invalid arena_id for Mob:GetFriendlyTarget_genes_attacker");
	end
	if(tag == "self") then
		return self;
	elseif(tag == "lowest_hp") then
		local friendlys, hostiles = arena:GetFriendlyAndHostileUnits(self:GetSide());
		local lowest_hp = 99999999;
		local lowest_hp_unit = nil;
		local _, unit;
		for _, unit in ipairs(friendlys) do
			local unit = Arena.GetCombatUnit(unit.isMob, unit.id)
			if(unit and unit:IsAlive()) then
				local current_hp = self:GetCurrentHP();
				if(current_hp < lowest_hp) then
					lowest_hp_unit = unit;
				end
			end
		end
		if(lowest_hp_unit) then
			return lowest_hp_unit;
		end
	elseif(tag == "max_max_hp") then
		local friendlys, hostiles = arena:GetFriendlyAndHostileUnits(self:GetSide());
		local max_max_hp = 0;
		local max_max_hp_unit = nil;
		local _, unit;
		for _, unit in ipairs(friendlys) do
			local unit = Arena.GetCombatUnit(unit.isMob, unit.id)
			if(unit and unit:IsAlive()) then
				local max_hp = unit:GetMaxHP();
				if(max_hp > max_max_hp) then
					max_max_hp_unit = unit;
					max_max_hp = max_hp;
				end
			end
		end
		if(max_max_hp_unit) then
			return max_max_hp_unit;
		end
	end

	-- by slot id sequence
	if(tag) then
		local each_target;
		for each_target in string.gmatch(tag, "([%d]+)") do
			each_target = tonumber(each_target);
			if(each_target) then
				local unit = arena:GetCombatUnitBySlotID(each_target);
				if(unit) then
					return unit;
				end
			end
		end
	end

	-- default random target
	local friendlys, hostiles = arena:GetFriendlyAndHostileUnits(self:GetSide());
	local i = math.random(1, #friendlys);
	if(i) then
		local unit_friendly = friendlys[i];
		if(unit_friendly) then
			local unit = Arena.GetCombatUnit(unit_friendly.isMob, unit_friendly.id)
			if(unit and unit:IsAlive()) then
				return unit;
			end
		end
	end

	-- default self
	return self;
end

-- get hostile target from tag
function Mob:GetHostileTarget_genes_attacker(tag, damage_school, is_pickedcard_attack)
	-- get arena object
	local arena;
	local arena_id = self.arena_id;
	if(arena_id) then
		arena = Arena.GetArenaByID(arena_id)
		if(not arena) then
			LOG.std(nil, "error", "combatmob", "invalid arena for Mob:GetHostileTarget_genes_attacker");
		end
	else
		LOG.std(nil, "error", "combatmob", "invalid arena_id for Mob:GetHostileTarget_genes_attacker");
	end
	-- parse different target according to target tag
	if(tag == "threat_highest" or tag == "threat_lowest") then
		local highest_threat = -1;
		local highest_threat_id = nil;
		local lowest_threat = 99999999;
		local lowest_threat_id = nil;
		local i;
		for i = 1, 4 do
			local unit;
			if(self:GetSide() == "far") then
				unit = arena:GetCombatUnitBySlotID(i);
			elseif(self:GetSide() == "near") then
				unit = arena:GetCombatUnitBySlotID(i + 4);
			end
			local threat = self.threats[i];
			if(not threat) then
				-- default 0 threat if object didn't generate any threat
				if(unit and unit:IsAlive() and unit:IsCombatActive()) then
					threat = 0;
				end
			end
			if(unit and unit:IsAlive() and unit:IsCombatActive() and not (is_pickedcard_attack and unit:IsStealth())) then
				if(threat and threat > highest_threat) then
					highest_threat = threat;
					highest_threat_id = i;
				end
				if(threat and threat < lowest_threat) then
					lowest_threat = threat;
					lowest_threat_id = i;
				end
			end
		end
		local threat_id_target = nil;
		if(tag == "threat_highest") then
			threat_id_target = highest_threat_id;
		elseif(tag == "threat_lowest") then
			threat_id_target = lowest_threat_id;
		end
		local target_obj;
		if(self:GetSide() == "far" and threat_id_target) then
			target_obj = arena:GetCombatUnitBySlotID(threat_id_target);
		elseif(self:GetSide() == "near" and threat_id_target) then
			target_obj = arena:GetCombatUnitBySlotID(threat_id_target + 4);
		end
		if(target_obj) then
			return target_obj;
		end
	elseif(tag == "noshield") then
		local friendlys, hostiles = arena:GetFriendlyAndHostileUnits(self:GetSide());
		local _, unit;
		for _, unit in ipairs(hostiles) do
			local unit = Arena.GetCombatUnit(unit.isMob, unit.id)
			if(unit and unit:IsAlive() and unit:IsCombatActive() and not (is_pickedcard_attack and unit:IsStealth())) then
				if(not unit:IfHasShield(damage_school)) then
					return unit;
				end
			end
		end
	elseif(tag == "withshield") then
		local friendlys, hostiles = arena:GetFriendlyAndHostileUnits(self:GetSide());
		local _, unit;
		for _, unit in ipairs(hostiles) do
			local unit = Arena.GetCombatUnit(unit.isMob, unit.id)
			if(unit and unit:IsAlive() and unit:IsCombatActive() and not (is_pickedcard_attack and unit:IsStealth())) then
				if(unit:IfHasShield(damage_school)) then
					return unit;
				end
			end
		end
	end

	if(tag) then
		-- by slot id sequence
		local each_target;
		for each_target in string.gmatch(tag, "([%d]+)") do
			each_target = tonumber(each_target);
			if(each_target) then
				local unit = arena:GetCombatUnitBySlotID(each_target);
				if(unit) then
					return unit;
				end
			end
		end
	end

	-- default random target which is not stealth if picked card is an attack card
	local friendlys, hostiles = arena:GetFriendlyAndHostileUnits(self:GetSide());
	local i = math.random(1, #hostiles);
	if(i) then
		local unit_hostile = hostiles[i];
		if(unit_hostile) then
			local unit = Arena.GetCombatUnit(unit_hostile.isMob, unit_hostile.id)
			if(unit and unit:IsAlive() and unit:IsCombatActive() and not (is_pickedcard_attack and unit:IsStealth())) then
				return unit;
			end
		end
	end

	-- default random target
	local friendlys, hostiles = arena:GetFriendlyAndHostileUnits(self:GetSide());
	local i = math.random(1, #hostiles);
	if(i) then
		local unit_hostile = hostiles[i];
		if(unit_hostile) then
			local unit = Arena.GetCombatUnit(unit_hostile.isMob, unit_hostile.id)
			if(unit and unit:IsAlive()) then
				return unit;
			end
		end
	end
end

-- reset attacker memory on mob enraged
function Mob:ResetAttackerMemoryOnEnrage()
	local genes_attacker_memory = self.genes_attacker_memory;
	local max_hp = self:GetMaxHP();
	genes_attacker_memory.last_pickcard_hp = max_hp;
	genes_attacker_memory.current_round = nil;
end

-- mob receive a bonus round to play specific card BEFORE or AFTER the round
-- only sequenced genes are applied
function Mob:GetCardAndTarget_genes_attacker_bonus_round(bBefore, bAfter)
	local template_key = self.template_key;
	local genes_attacker_memory = self.genes_attacker_memory;
	-- check last pick card hp
	local last_pickcard_hp = genes_attacker_memory.last_pickcard_hp;
	local current_hp = self:GetCurrentHP();
	local max_hp = self:GetMaxHP();
	if(not last_pickcard_hp) then
		-- we assume full health for init mob
		last_pickcard_hp = max_hp;
		genes_attacker_memory.last_pickcard_hp = max_hp;
	end

	local current_round = genes_attacker_memory.current_round or 0;
	if(bBefore) then
		-- current round is increased in the normal round attacker
		current_round = current_round + 1;
	end

	if(template_key and (bBefore or bAfter)) then
		--local template = MobTemplate.GetTemplate(template_key);
		--if(template) then
			--local sequences = template.sequences;
			local cardsets = self:GetAICardsets();
			local sequences = {};
			local sequences_bonus = {};
			local sequences_id_key;
			if(bBefore) then
				sequences_bonus = self:GetAISequences_bonus_round_before();
				sequences_id_key = "sequence_id_before";
			elseif(bAfter) then
				sequences_bonus = self:GetAISequences_bonus_round_after();
				sequences_id_key = "sequence_id_after";
			end
			if(sequences_bonus and #sequences_bonus > 0 and sequences_id_key) then
				local sequences_id = genes_attacker_memory[sequences_id_key];
				if(not sequences_id) then
					sequences_id = math.random(#sequences_bonus);
					genes_attacker_memory[sequences_id_key] = sequences_id;
				end
				local sequence = sequences_bonus[sequences_id];
				if(sequence) then
					local data_round = sequence[current_round];
					if(data_round) then
						local picked_card = "Pass";
						if(type(data_round.card_or_set) == "string") then
							-- explicit card
							picked_card = data_round.card_or_set;
						elseif(type(data_round.card_or_set) == "number") then
							local cardset = cardsets[data_round.card_or_set];
							-- explicit card set
							if(cardset) then
								local picked_nonzeropipcard = PickFromCards(cardset.cards_weight_nonzeropip)
								local picked_zeropipcard = PickFromCards(cardset.cards_weight_zeropip);
								if(picked_nonzeropipcard and picked_nonzeropipcard ~= "Pass") then
									if(self:CanCastSpell(picked_nonzeropipcard)) then
										picked_card = picked_nonzeropipcard;
									elseif(picked_zeropipcard) then
										picked_card = picked_zeropipcard;
									end
								elseif(picked_zeropipcard) then
									picked_card = picked_zeropipcard;
								end
							else
								LOG.std(nil, "error", "combatmob", "invalid card_set "..tostring(card_or_set).." for template_key:"..tostring(template_key));
							end
						else
							LOG.std(nil, "error", "combatmob", "invalid data_round field:card or card_set for template_key:"..tostring(template_key));
						end
						-- record the last pick card hp
						genes_attacker_memory.last_pickcard_hp = self:GetCurrentHP();
						local accuracy_boost;
						if(data_round.accuracy_boost) then
							accuracy_boost = tonumber(data_round.accuracy_boost);
						end
						local force_pip_cost;
						if(data_round.force_pip_cost) then
							force_pip_cost = tonumber(data_round.force_pip_cost);
						end
						return picked_card, data_round.target_hostile, data_round.target_friendly, accuracy_boost, data_round.speak, data_round.motion, force_pip_cost;
					end
				end
			end
		--end
	end
	-- NOTE: 2012/12/11: don't record the mob current_hp in bonus round, current_hp is updated every bonus turns
	-- TODO: 2012/12/11: record the current_hp if ai_module hit the genes or sequence ?
	-- 
	---- record the last pick card hp
	--genes_attacker_memory.last_pickcard_hp = self:GetCurrentHP();
	return "Pass", "random_hostile", "self", nil, nil;
end

function Mob:GetCardAndTarget_genes_attacker()
	local template_key = self.template_key;
	local genes_attacker_memory = self.genes_attacker_memory;
	-- check last pick card hp
	local last_pickcard_hp = genes_attacker_memory.last_pickcard_hp;
	local current_hp = self:GetCurrentHP();
	local max_hp = self:GetMaxHP();
	if(not last_pickcard_hp) then
		-- we assume full health for init mob
		last_pickcard_hp = max_hp;
		genes_attacker_memory.last_pickcard_hp = max_hp;
	end

	genes_attacker_memory.current_round = (genes_attacker_memory.current_round or 0) + 1;

	if(template_key) then
		--local template = MobTemplate.GetTemplate(template_key);
		--if(template) then
			--local sequences = template.sequences;
			local cardsets = self:GetAICardsets();
			local aisets = self:GetAIAIsets();
			local sequences = self:GetAISequences();
			if(sequences and #sequences > 0) then
				local sequences_id = genes_attacker_memory.sequence_id;
				if(not sequences_id) then
					sequences_id = math.random(#sequences);
					genes_attacker_memory.sequence_id = sequences_id;
				end
				local sequence = sequences[sequences_id];
				if(sequence) then
					local data_round = sequence[genes_attacker_memory.current_round];
					if(data_round) then
						local picked_card = "Pass";
						local picked_card_target_ismob = nil;
						local picked_card_target_id = nil;
						if(type(data_round.card_or_set) == "string") then
							-- explicit card
							picked_card = data_round.card_or_set;
						elseif(type(data_round.card_or_set) == "number") then
							local cardset = cardsets[data_round.card_or_set];
							-- explicit card set
							if(cardset) then
								local picked_nonzeropipcard = PickFromCards(cardset.cards_weight_nonzeropip)
								local picked_zeropipcard = PickFromCards(cardset.cards_weight_zeropip);
								if(picked_nonzeropipcard and picked_nonzeropipcard ~= "Pass") then
									if(self:CanCastSpell(picked_nonzeropipcard)) then
										picked_card = picked_nonzeropipcard;
									elseif(picked_zeropipcard) then
										picked_card = picked_zeropipcard;
									end
								elseif(picked_zeropipcard) then
									picked_card = picked_zeropipcard;
								end
							else
								LOG.std(nil, "error", "combatmob", "invalid card_set "..tostring(card_or_set).." for template_key:"..tostring(template_key));
							end
						else
							LOG.std(nil, "error", "combatmob", "invalid data_round field:card or card_set for template_key:"..tostring(template_key));
						end
						-- record the last pick card hp
						genes_attacker_memory.last_pickcard_hp = self:GetCurrentHP();
						local accuracy_boost;
						if(data_round.accuracy_boost) then
							accuracy_boost = tonumber(data_round.accuracy_boost);
						end
						local force_pip_cost;
						if(data_round.force_pip_cost) then
							force_pip_cost = tonumber(data_round.force_pip_cost);
						end
						if(picked_card and picked_card_target_ismob ~= nil and picked_card_target_id) then
							return picked_card, picked_card_target_ismob, picked_card_target_id, accuracy_boost, data_round.speak, data_round.motion, force_pip_cost;
						end
						return picked_card, data_round.target_hostile, data_round.target_friendly, accuracy_boost, data_round.speak, data_round.motion, force_pip_cost;
					end
				end
			end

			--local genes = template.genes;
			local genes = self:GetAIGenes();
			local max_priority = genes.max_priority;
			if(max_priority and max_priority > 0) then
				local i;
				for i = 1, max_priority do
					local each_priority = genes[i];
					if(each_priority) then
						local r = math.random(0, 100);
						local _, gene;
						for _, gene in ipairs(each_priority) do
							if(r <= gene.priority_weight_percent) then
								-- check hp validity
								if((gene.hp_drop and (last_pickcard_hp * 100 / max_hp) >= gene.hp_drop and (current_hp * 100 / max_hp) <= gene.hp_drop) or 
								   (gene.hp_range_lower and gene.hp_range_upper and (current_hp * 100 / max_hp) >= gene.hp_range_lower and (current_hp * 100 / max_hp) <= gene.hp_range_upper)) then
									-- hit weight chance
									local picked_card = "Pass";
									if(type(gene.card_or_set) == "string") then
										-- explicit card
										picked_card = gene.card_or_set;
									elseif(type(gene.card_or_set) == "number") then
										
										if(gene.card_or_set > 0) then
											local cardset = cardsets[gene.card_or_set];
											-- explicit card set
											if(cardset) then
												local picked_nonzeropipcard = PickFromCards(cardset.cards_weight_nonzeropip)
												local picked_zeropipcard = PickFromCards(cardset.cards_weight_zeropip);
												if(picked_nonzeropipcard and picked_nonzeropipcard ~= "Pass") then
													if(self:CanCastSpell(picked_nonzeropipcard)) then
														picked_card = picked_nonzeropipcard;
													elseif(picked_zeropipcard) then
														picked_card = picked_zeropipcard;
													end
												elseif(picked_zeropipcard) then
													picked_card = picked_zeropipcard;
												end
											else
												LOG.std(nil, "error", "combatmob", "invalid card_set "..tostring(card_or_set).." for template_key:"..tostring(template_key));
											end
										elseif(gene.card_or_set < 0) then
											local aiset = aisets[-gene.card_or_set];
											-- explicit ai set
											if(aiset) then
												picked_card, picked_card_target_ismob, picked_card_target_id = PickFromAiModuleCards(aiset, self);
											else
												LOG.std(nil, "error", "combatmob", "invalid card_set "..tostring(card_or_set).." for template_key:"..tostring(template_key));
											end
										end
									else
										LOG.std(nil, "error", "combatmob", "invalid gene field:card or card_set for template_key:"..tostring(template_key));
									end
									-- record the last pick card hp
									genes_attacker_memory.last_pickcard_hp = self:GetCurrentHP();
									local accuracy_boost;
									if(gene.accuracy_boost) then
										accuracy_boost = tonumber(gene.accuracy_boost);
									end
									local force_pip_cost;
									if(gene.force_pip_cost) then
										force_pip_cost = tonumber(gene.force_pip_cost);
									end
									return picked_card, gene.target_hostile, gene.target_friendly, accuracy_boost, gene.speak, gene.motion, force_pip_cost;
								end
								-- hp condition don't match proceed the next gene
								r = r - gene.priority_weight_percent;
							else
								-- chance don't hit preceed the next gene
								r = r - gene.priority_weight_percent;
							end
							
						end
					end
				end
			end
			-- no genes available
			-- probably a simple attacker mob
			local picked_card = "Pass";
			local nonzeropipcards, zeropipcards = self:GetAvailableCards();
			if(nonzeropipcards and zeropipcards) then
				local picked_nonzeropipcard = PickFromCards(nonzeropipcards);
				local picked_zeropipcard = PickFromCards(zeropipcards);
				if(picked_nonzeropipcard and picked_nonzeropipcard ~= "Pass") then
					if(self:CanCastSpell(picked_nonzeropipcard)) then
						picked_card = picked_nonzeropipcard;
					else
						picked_card = picked_zeropipcard;
					end
				elseif(picked_zeropipcard) then
					picked_card = picked_zeropipcard;
				end
				-- record the last pick card hp
				genes_attacker_memory.last_pickcard_hp = self:GetCurrentHP();
				-- pick from available_cards
				if(string.find(string.lower(picked_card), "heal")) then
					return picked_card, "threat_highest", "lowest_hp", nil, nil;
				else
					if(System.options.version == "teen") then
						-- NOTE: 2012/11/16 default self for available_cards friendly target
						return picked_card, "threat_highest", "self", nil, nil;
					else
						return picked_card, "threat_highest", "random_friendly", nil, nil;
					end
				end
			end
		--end
	end
	-- record the last pick card hp
	genes_attacker_memory.last_pickcard_hp = self:GetCurrentHP();
	return "Pass", "random_hostile", "self", nil, nil;
end

-- get card and target deck attacker
function Mob:GetCardAndTarget_Deck_Attacker()
	local memory = self.deck_attacker_memory;
	if(not memory.bShuffled) then
		-- clear card sequence
		memory.deck_card_sequence = {};
		memory.deck_card_mapping = {};
		memory.deck_card_runes = {};
		-- shuffle deck cards
		local single_cards = {};
		local deckcards = self:GetStatByField("deckcards");
		if(deckcards) then
			local card_gsid_count_pair;
			for card_gsid_count_pair in string.gmatch(deckcards, "([^%(^%)]+)") do
				local card_gsid, count = string.match(card_gsid_count_pair, "^(%d-)%+(%d-)$");
				if(card_gsid and count) then
					card_gsid = tonumber(card_gsid);
					count = tonumber(count);
					if(card_gsid and count) then
						if(count >= 100) then
							-- this is rune
							table.insert(memory.deck_card_runes, card_gsid);
						else
							-- this is ordinary cards
							local i = 1;
							for i = 1, count do
								table.insert(single_cards, {gsid = card_gsid, weight = math.random(1, 999999)});
							end
						end
					end
				end
			end
		end
		-- sort the card pile with weight
		table.sort(single_cards, function(a, b)
					return (a.weight > b.weight);
				end);
		-- record the sequence
		local _, card;
		for _, card in ipairs(single_cards) do
			table.insert(memory.deck_card_sequence, card.gsid);
			table.insert(memory.deck_card_mapping, 0);
		end
		-- marked shuffled
		memory.bShuffled = true;
	end
	-- prepare card
	local card_in_hand_count = 0;
	local _, status;
	for _, status in ipairs(memory.deck_card_mapping) do
		if(status == 1) then
			-- 1: avaiable cards at hand, 8 at maximum
			card_in_hand_count = card_in_hand_count + 1;
		elseif(status == -1) then
			-- -1: discarded cards
		elseif(status == -2) then
			-- -2: used cards
		elseif(status == 0) then
			-- 0: un-used cards
			if(card_in_hand_count < 8) then
				memory.deck_card_mapping[_] = 1;
				card_in_hand_count = card_in_hand_count + 1;
			end
		end
		if(card_in_hand_count == 8) then
			break;
		end
	end
	
	local arena;
	local arena_id = self.arena_id;
	if(arena_id) then
		arena = Arena.GetArenaByID(arena_id)
		if(not arena) then
			log("error: mob got invalid arena in function GetCardAndTarget_Deck_Attacker\n")
			return "Pass", true, self:GetID();
		end
	end

	LOG.std(nil, "info", "mob_server", "====GetCardAndTarget_Deck_Attacker_helper====: Mob pick card with executed_rounds %s", arena:GetRoundTag());

	local all_results = {};
	local card_count = 0;
	local pickcard_target_key;
	local pickcard_target_ismob;
	local pickcard_target_id;
	local pickcard_target_seq;
	local pickcard_target_weight = 0;

	local discarded_card_indexs = {};

	-- deck in hand
	local _, status;
	for _, status in ipairs(memory.deck_card_mapping) do
		local gsid = memory.deck_card_sequence[_];
		local key;
		if(gsid and status == 1) then
			-- available card
			key = Card.Get_cardkey_from_gsid(gsid);
			if(not key) then
				key = Card.Get_cardkey_from_rune_gsid(gsid);
			end
		end
		if(key) then
			local template = Card.GetCardTemplate(key);
			if(not template) then
				log("error: card not valid for key:"..tostring(key).." in function PickFromAiDeckCards\n")
				return "Pass", true, self:GetID();
			end
			if(self:CanCastSpell(key)) then
				local side = self:GetSide();
				-- get caster friendly and hostile units
				local friendlys, hostiles = arena:GetFriendlyAndHostileUnits(side);
				local myself = {{isMob = true, id = self:GetID()}};
				local style = self:GetStatByField("deck_attacker_style");
				local weight, target_ismob, target_id = Card.GetDeckAttackerAIWeightTarget(key, style, self, arena, myself, friendlys, hostiles);
				if(weight and target_ismob ~= nil and target_id and weight > pickcard_target_weight) then
					pickcard_target_key = key;
					pickcard_target_ismob = target_ismob;
					pickcard_target_id = target_id;
					pickcard_target_seq = _;
					pickcard_target_weight = weight;
				end
				LOG.std(nil, "info", "mob_server", "====GetCardAndTarget_Deck_Attacker_helper====: deck card %s with weight %s", key, tostring(weight));
				if(weight and weight < 0) then
					-- discard card
					LOG.std(nil, "info", "mob_server", "====GetCardAndTarget_Deck_Attacker_helper====: deck card %s discarded", key);
					table.insert(discarded_card_indexs, _);
				end
			else
				LOG.std(nil, "info", "mob_server", "====GetCardAndTarget_Deck_Attacker_helper====: deck card %s can't cast spell", key);
			end
		end
	end
	
	-- discard card
	local _, index;
	for _, index in ipairs(discarded_card_indexs) do
		memory.deck_card_mapping[index] = -1;
	end

	-- runes
	local _, gsid;
	for _, gsid in ipairs(memory.deck_card_runes) do
		local key;
		key = Card.Get_cardkey_from_gsid(gsid);
		if(not key) then
			key = Card.Get_cardkey_from_rune_gsid(gsid);
		end
		if(key) then
			local template = Card.GetCardTemplate(key);
			if(not template) then
				log("error: card not valid for key:"..tostring(key).." in function PickFromAiDeckCards\n")
				return "Pass", true, self:GetID();
			end
			if(self:CanCastSpell(key)) then
				local side = self:GetSide();
				-- get caster friendly and hostile units
				local friendlys, hostiles = arena:GetFriendlyAndHostileUnits(side);
				local myself = {{isMob = true, id = self:GetID()}};
				local style = self:GetStatByField("deck_attacker_style");
				local weight, target_ismob, target_id = Card.GetDeckAttackerAIWeightTarget(key, style, self, arena, myself, friendlys, hostiles);
				if(weight and target_ismob ~= nil and target_id and weight > pickcard_target_weight) then
					pickcard_target_key = key;
					pickcard_target_ismob = target_ismob;
					pickcard_target_id = target_id;
					pickcard_target_seq = _;
					pickcard_target_weight = weight;
				end
				LOG.std(nil, "info", "mob_server", "====GetCardAndTarget_Deck_Attacker_helper====: rune card %s with weight %d", key, tostring(weight));
			else
				LOG.std(nil, "info", "mob_server", "====GetCardAndTarget_Deck_Attacker_helper====: rune card %s can't cast spell", key);
			end
		end
	end

	if(pickcard_target_key and pickcard_target_ismob ~= nil and pickcard_target_id and pickcard_target_seq) then
		memory.deck_card_mapping[pickcard_target_seq] = -2;
		return pickcard_target_key, pickcard_target_ismob, pickcard_target_id;
	end
	return "Pass", true, self:GetID();
end

-- return the available cards
-- @return: non-zero pips cards and zero pips cards
function Mob:GetAvailableCards()
	local template_key = self.template_key;
	if(template_key) then
		local template = MobTemplate.GetTemplate(template_key);
		if(template) then
			if(self:IsEnraged()) then
				local enrage_ai_cards_key = template.stats.enrage_ai_cards_key;
				if(enrage_ai_cards_key) then
					local template_data = EnrageAICards[enrage_ai_cards_key];
					if(template_data) then
						return template_data.cards_weight_nonzeropip, template_data.cards_weight_zeropip;
					end
				end
			end
			return template.cards_weight_nonzeropip, template.cards_weight_zeropip;
		end
	end
	
	local assetfile = self:GetAssetFile();
	log("error: card Mob:GetAvailableCards no cards available for "..assetfile..", use default cards\n")

	-- default cards
	return 
	{
		--{"SingleAttackWithDOT_Level1_Fire", 10},
		--{"SingleAttackWithDOT_Level2_Fire", 20},
		--{"SingleAttackWithDOT_Level3_Fire", 30},
		--{"SingleAttack_Level1_Earth", 10},
		--{"AreaAttack_Level2_Wood", 20},
		--{"SingleAttack_Level3_Metal", 30},
	}, 
	{
		{"Pass", 10},
		--{"PowerEnhanceBlade_Wood", 30},
		--{"SingleHeal_Level1_Water", 30},
		--{"DamageShieldAndThorn_Level2_Earth", 30},
	};
end

-- get AI sequences
function Mob:GetAISequences()
	local template_key = self.template_key;
	if(template_key) then
		local template = MobTemplate.GetTemplate(template_key);
		if(template) then
			if(self:IsEnraged()) then
				local enrage_ai_cards_key = template.stats.enrage_ai_cards_key;
				if(enrage_ai_cards_key) then
					local template_data = EnrageAICards[enrage_ai_cards_key];
					if(template_data) then
						return template_data.sequences;
					end
				end
			end
			return template.sequences;
		end
	end
end

-- get AI sequences sequences_bonus_round_before
function Mob:GetAISequences_bonus_round_before()
	local template_key = self.template_key;
	if(template_key) then
		local template = MobTemplate.GetTemplate(template_key);
		if(template) then
			if(self:IsEnraged()) then
				local enrage_ai_cards_key = template.stats.enrage_ai_cards_key;
				if(enrage_ai_cards_key) then
					local template_data = EnrageAICards[enrage_ai_cards_key];
					if(template_data) then
						return template_data.sequences_bonus_round_before;
					end
				end
			end
			return template.sequences_bonus_round_before;
		end
	end
end

-- get AI sequences sequences_bonus_round_after
function Mob:GetAISequences_bonus_round_after()
	local template_key = self.template_key;
	if(template_key) then
		local template = MobTemplate.GetTemplate(template_key);
		if(template) then
			if(self:IsEnraged()) then
				local enrage_ai_cards_key = template.stats.enrage_ai_cards_key;
				if(enrage_ai_cards_key) then
					local template_data = EnrageAICards[enrage_ai_cards_key];
					if(template_data) then
						return template_data.sequences_bonus_round_after;
					end
				end
			end
			return template.sequences_bonus_round_after;
		end
	end
end

-- get AI genes
function Mob:GetAIGenes()
	local template_key = self.template_key;
	if(template_key) then
		local template = MobTemplate.GetTemplate(template_key);
		if(template) then
			if(self:IsEnraged()) then
				local enrage_ai_cards_key = template.stats.enrage_ai_cards_key;
				if(enrage_ai_cards_key) then
					local template_data = EnrageAICards[enrage_ai_cards_key];
					if(template_data) then
						return template_data.genes;
					end
				end
			end
			return template.genes;
		end
	end
end

-- get AI cardsets
function Mob:GetAICardsets()
	local template_key = self.template_key;
	if(template_key) then
		local template = MobTemplate.GetTemplate(template_key);
		if(template) then
			if(self:IsEnraged()) then
				local enrage_ai_cards_key = template.stats.enrage_ai_cards_key;
				if(enrage_ai_cards_key) then
					local template_data = EnrageAICards[enrage_ai_cards_key];
					if(template_data) then
						return template_data.cardsets;
					end
				end
			end
			return template.cardsets;
		end
	end
end

-- get AI aisets
function Mob:GetAIAIsets()
	local template_key = self.template_key;
	if(template_key) then
		local template = MobTemplate.GetTemplate(template_key);
		if(template) then
			if(self:IsEnraged()) then
				local enrage_ai_cards_key = template.stats.enrage_ai_cards_key;
				if(enrage_ai_cards_key) then
					local template_data = EnrageAICards[enrage_ai_cards_key];
					if(template_data) then
						return template_data.aisets;
					end
				end
			end
			return template.aisets;
		end
	end
end