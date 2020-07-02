--[[
Title: combat system Entry for Aries App
Author(s): WangTian
Date: 2009/4/7
Area: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Combat/main.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
NPL.load("(gl)script/apps/Aries/VIP/main.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
-- create class
local Combat = commonlib.gettable("MyCompany.Aries.Combat");

NPL.load("(gl)script/apps/Aries/Combat/SpellCast.lua");
NPL.load("(gl)script/apps/Aries/Combat/BattleComment.lua");
NPL.load("(gl)script/apps/Aries/Player/main.lua");
local Player = commonlib.gettable("MyCompany.Aries.Player");
local ItemManager = commonlib.gettable("System.Item.ItemManager");
local ProfileManager = commonlib.gettable("System.App.profiles.ProfileManager");
local VIP = commonlib.gettable("MyCompany.Aries.VIP");

NPL.load("(gl)script/apps/Aries/Combat/ServerObject/card_server.lua");
local Card = commonlib.gettable("MyCompany.Aries.Combat_Server.Card");

-- two-way gsid and card key mapping
local cardkey_to_gsid = {};
local gsid_to_cardkey = {};

-- two-way gsid and rune card key mapping
local rune_cardkey_to_gsid = {};
local gsid_to_rune_cardkey = {};

-- school gsid to gsids mapping
local cardgsids_by_school = {};

-- 6火 7冰 8风暴 9神秘 10生命 11死亡 12平衡 
-- 986_CombatSchool_Fire
-- 987_CombatSchool_Ice
-- 988_CombatSchool_Storm
-- 989_CombatSchool_Myth
-- 990_CombatSchool_Life
-- 991_CombatSchool_Death
-- 992_CombatSchool_Balance
local shortid_to_gsid = {
	[6] = 986,
	[7] = 987,
	[8] = 988,
	[9] = 989,
	[10] = 990,
	[11] = 991,
	[12] = 992,
};
local gsid_to_shortid = {
	[986] = 6,
	[987] = 7,
	[988] = 8,
	[989] = 9,
	[990] = 10,
	[991] = 11,
	[992] = 12,
};

-- this only be used in "kids" version
local pvp_arena_ranking_point_gsid = {};

local function loadPVPPointGSIDForConfigFile()
	local file = "config/Aries/Combat/PVPGrearScoreRankPointGSID.xml";
	local xmlRoot = ParaXML.LuaXML_ParseFile(file);
	if(xmlRoot) then
		local each_type;
		for each_type in commonlib.XPath.eachNode(xmlRoot, "/pointgsids/type") do
			if(each_type.attr and each_type.attr.name) then
				local type = each_type.attr.name;
				pvp_arena_ranking_point_gsid[type] = {};
				local type_table = pvp_arena_ranking_point_gsid[type];
				local each_item;
				for each_item in commonlib.XPath.eachNode(each_type, "/gsid") do
					local win_gsid = each_item.attr.win_gsid;
					local lose_gsid = each_item.attr.lose_gsid;
					local gs_region = {};
					if(win_gsid and lose_gsid) then
						gs_region.win_gsid = tonumber(win_gsid);
						gs_region.lose_gsid = tonumber(lose_gsid);
						if(each_item.attr.min_gs) then
							gs_region.min_gs = tonumber(each_item.attr.min_gs);
						else
							gs_region.min_gs = nil;
						end
						if(each_item.attr.max_gs) then
							gs_region.max_gs = tonumber(each_item.attr.max_gs);
						else
							gs_region.max_gs = nil;
						end
						table.insert(type_table,gs_region);
					end
				end
			end
		end
	end
end

function Combat.GetPVPPointGSID(type,gearscore,result)
	local beWinner;
	if(result == "win") then
		beWinner = true;
	elseif(result == "lose") then
		beWinner = false;
	end
	local gsid;
	if(not next(pvp_arena_ranking_point_gsid)) then
		loadPVPPointGSIDForConfigFile();
	end
	local type_table = pvp_arena_ranking_point_gsid[type];
	for i=1,#type_table do
		local item = type_table[i];
		if((not item.min_gs) or (item.min_gs and gearscore >= item.min_gs)) then
			if((not item.max_gs) or (item.max_gs and gearscore <= item.max_gs)) then
				if(item.win_gsid and item.lose_gsid) then
					gsid = if_else(beWinner,item.win_gsid,item.lose_gsid)
					break;
				end
			end	
		end		
	end
	return gsid or 20079;
end

function Combat.GetPVPPointList(type,list)
	list["win"] = {};
	list["lose"] = {};
	if(not next(pvp_arena_ranking_point_gsid)) then
		loadPVPPointGSIDForConfigFile();
	end
	local type_table = pvp_arena_ranking_point_gsid[type]; 
	if(type_table) then
		for i=1,#type_table do
			local item = type_table[i];
			if(item.win_gsid) then
				list["win"][item.win_gsid] = true;
			end
			if(item.lose_gsid) then
				list["lose"][item.lose_gsid] = true;
			end
		end
	end
end

-- vip bonus
-- start from level 0
local vip_bonus_hp = {5, 5, 5, 6, 6, 6, 7, 7, 7, 8, 10};
local vip_bonus_damage = {5, 5, 6, 7, 8, 9, 10, 12, 14, 17, 20};
local vip_bonus_resist = {4, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9};
--local vip_bonus_heal_output = {0, 3, 4, 4, 4, 5, 5, 6, 6, 6, 8};
--local vip_bonus_heal_input = {0, 3, 3, 3, 5, 5, 6, 6, 7, 7, 8};
local vip_bonus_accuracy = {2, 2, 3, 3, 4, 4, 4, 5, 5, 5, 6};
local vip_bonus_output_heal = {2, 3, 4, 4, 4, 5, 5, 6, 6, 6, 8};
local vip_bonus_input_heal = {2, 3, 3, 3, 5, 5, 6, 6, 7, 7, 8};

-- NOTE: invoked after all global store items are synced
function Combat.Init_OnGlobalStoreLoaded()
	if(Combat.isCardLoaded) then
		return
	end
	Combat.isCardLoaded = true;
	-- NOTE: activate the key and gsid name mapping in combat tutorial stage
	-- init card key and gsid mapping
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
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(i);
				if(gsItem) then
					local gsid, key = string.match(gsItem.assetkey, "^(%d-)_(.+)$");
					if(gsid and key) then
						gsid = tonumber(gsid);
						if(i == gsid) then
							cardkey_to_gsid[key] = gsid;
							gsid_to_cardkey[gsid] = key;
							local school_gsid = gsItem.template.stats[136];
							if(school_gsid) then
								local school_gsid = shortid_to_gsid[school_gsid];
								if(school_gsid) then
									cardgsids_by_school[school_gsid] = cardgsids_by_school[school_gsid] or {};
									table.insert(cardgsids_by_school[school_gsid], gsid);
								end
							end
						end
					end
				end
			end
		end
	end
	if(not gsid_to_cardkey[22101]) then
		LOG.std(nil, "error", "combat", "Combat.Init_OnGlobalStoreLoaded() got empty global store item templates");
	end

	-- rune card region
	local regions = {
		{23101, 23999}, -- kids version cards
	};
	local _, region_from_to;
	for _, region_from_to in ipairs(regions) do
		if(region_from_to[1] and region_from_to[2]) then
			local i;
			for i = region_from_to[1], region_from_to[2] do
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(i);
				if(gsItem) then
					local gsid, key = string.match(gsItem.assetkey, "^(%d-)_(.+)$");
					if(gsid and key) then
						gsid = tonumber(gsid);
						if(i == gsid) then
							rune_cardkey_to_gsid[key] = gsid;
							gsid_to_rune_cardkey[gsid] = key;
						end
					end
				end
			end
		end
	end

	if(System.options.version == "kids") then
		Card.InitDragonTotemStatsConfigFromFile("config/Aries/Combat/DragonTotemStats.xml");
	elseif(System.options.version == "teen") then
		Card.InitDragonTotemStatsConfigFromFile("config/Aries/Combat/DragonTotemStats.teen.xml");
	end
end

-- Combat.init()
function Combat.Init()
	NPL.load("(gl)script/apps/Aries/Combat/MsgHandler.lua");
	MyCompany.Aries.Combat.MsgHandler.Init();
	
	-- init item set
	Combat.InitAllItemSetIfNot();

	-- clear vip stats for teen
	if(System.options.version == "teen") then
		vip_bonus_hp = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
		vip_bonus_damage = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
		vip_bonus_resist = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
		--vip_bonus_heal_output = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
		--vip_bonus_heal_input = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
		vip_bonus_accuracy = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
		vip_bonus_output_heal = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
		vip_bonus_input_heal = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
	end
	if(System.options.version == "kids") then
		loadPVPPointGSIDForConfigFile();
	end
end

function Combat.OnWorldLoad()
	NPL.load("(gl)script/apps/Aries/Combat/MsgHandler.lua");
	MyCompany.Aries.Combat.MsgHandler.OnWorldLoad();
end

-- get card key from gsid and vice versa
function Combat.Get_gsid_from_cardkey(key)
	return cardkey_to_gsid[key];
end
function Combat.Get_cardkey_from_gsid(gsid)
	if(gsid == 0) then
		return "Pass";
	end
	return gsid_to_cardkey[gsid];
end

-- get card key from gsid and vice versa
function Combat.Get_gsid_from_rune_cardkey(key)
	return rune_cardkey_to_gsid[key];
end
function Combat.Get_rune_cardkey_from_gsid(gsid)
	if(gsid == 0) then
		return "Pass";
	end
	return gsid_to_rune_cardkey[gsid];
end

-- get school gsid from short id and vice versa
function Combat.Get_school_gsid_from_short_id(short_gsid)
	return shortid_to_gsid[short_gsid];
end
function Combat.Get_short_gsid_from_school_id(school_gsid)
	return gsid_to_shortid[school_gsid];
end

function Combat.IsSameSchoolGSIDAndShortID(school_gsid, short_id)
	if(school_gsid and short_id) then
		if(shortid_to_gsid[short_id] == school_gsid) then
			return true;
		end
	end
	return false;
end

-- get dragon totem stats
-- @profession_gsid: profession gsid 50351 ~ 50354
-- @exp_gsid: default 50359
-- @exp_count: item count
-- @return: stats({[101] = 10, [102] = 70} or nil if invalid), total_level, cur_level, cur_level_exp, cur_level_total_exp
function Combat.GetStatsFromDragonTotemProfessionAndExp(profession_gsid, exp_gsid, exp_count)
	exp_gsid = exp_gsid or 50359;
	return Card.GetStatsFromDragonTotemProfessionAndExp(profession_gsid, exp_gsid, exp_count);
end
-- get dragon totem stats
-- @profession_gsid: profession gsid 50351 ~ 50354
-- @level: level
-- @return {[101] = 10, [102] = 70} or nil if invalid
function Combat.GetStatsFromDragonTotemProfessionAndLevel(profession_gsid, level)
	return Card.GetStatsFromDragonTotemProfessionAndLevel(profession_gsid, level);
end
-- get dragon totem stats
-- @profession_gsid: profession gsid 50351 ~ 50354
-- @return {[101] = 10, [102] = 70} or nil if invalid
function Combat.GetMaxLevelFromDragonTotemProfession(profession_gsid)
	return Card.GetMaxLevelFromDragonTotemProfession(profession_gsid);
end

-- teen version uses shared cooldown among card keys with the same spellname
-- returns the table with all card keys including the card_key itself
-- e.x. {["Death_DeathGreatShield"] = true , ["Balance_GlobalShield"] = true, }
function Combat.GetSharedCoolDownCardKeys(card_key_or_gsid)
	if(type(card_key_or_gsid) == "number") then
		card_key_or_gsid = Combat.Get_cardkey_from_gsid(card_key_or_gsid);
	end
	return Card.GetSharedCoolDownCardKeys(card_key_or_gsid);
end

-- if two cards share the same cooldown
function Combat.IsSharedCoolDownByGSID(gsid1, gsid2)
	if(gsid1 and gsid2) then
		local key1 = Combat.Get_cardkey_from_gsid(gsid1);
		local key2 = Combat.Get_cardkey_from_gsid(gsid2);
		local shared_cooldown_keys = Card.GetSharedCoolDownCardKeys(key1);
		if(shared_cooldown_keys) then
			if(shared_cooldown_keys[key2]) then
				return true;
			end
		end
	end
	return false;
end

-- if two cards share the same cooldown
function Combat.IsSharedCoolDownByKey(key1, key2)
	if(key1 and key2) then
		local shared_cooldown_keys = Card.GetSharedCoolDownCardKeys(key1);
		if(shared_cooldown_keys) then
			if(shared_cooldown_keys[key2]) then
				return true;
			end
		end
	end
	return false
end

-- enter Combat mode
function Combat.OnEnterCombatMode()
end

-- leave Combat mode
function Combat.OnLeaveCombatMode()
end

-- 986_CombatSchool_Fire
-- 987_CombatSchool_Ice
-- 988_CombatSchool_Storm
-- 989_CombatSchool_Myth
-- 990_CombatSchool_Life
-- 991_CombatSchool_Death
-- 992_CombatSchool_Balance
local school = nil;
-- get user combat school
-- @param nid: other player nid, if nil means myself
-- @return: lower case school name: fire, ice, storm, ..., if other player character it may return "unknown" if the school item is absent
function Combat.GetSchool(nid)
	if(not nid) then
		-- calculate only once
		if(not school) then
			local userinfo = ProfileManager.GetUserInfoInMemory();
			if(userinfo) then
				if(userinfo.combatschool == 986) then
					school = "fire";
				elseif(userinfo.combatschool == 987) then
					school = "ice";
				elseif(userinfo.combatschool == 988) then
					school = "storm";
				--elseif(userinfo.combatschool == 989) then
					--school = "myth";
				elseif(userinfo.combatschool == 990) then
					school = "life";
				elseif(userinfo.combatschool == 991) then
					school = "death";
				--elseif(userinfo.combatschool == 992) then
					--school = "balance";
				end
			end
		end
		return school or "storm";
	else
		local userinfo = ProfileManager.GetUserInfoInMemory(nid);
		if(userinfo) then
			if(userinfo.combatschool == 986) then
				return "fire";
			elseif(userinfo.combatschool == 987) then
				return "ice";
			elseif(userinfo.combatschool == 988) then
				return "storm";
			--elseif(userinfo.combatschool == 989) then
				--return "myth";
			elseif(userinfo.combatschool == 990) then
				return "life";
			elseif(userinfo.combatschool == 991) then
				return "death";
			--elseif(userinfo.combatschool == 992) then
				--return "balance";
			end
		end
		return "unknown";
	end
end

-- 986_CombatSchool_Fire
-- 987_CombatSchool_Ice
-- 988_CombatSchool_Storm
-- 989_CombatSchool_Myth
-- 990_CombatSchool_Life
-- 991_CombatSchool_Death
-- 992_CombatSchool_Balance
local school_displayname = nil;
-- get user combat school gsid
-- @param nid: other player nid, if nil means myself
-- @return: school gsid, nil if unavailable
function Combat.GetSchoolGSID(nid)
	local userinfo = ProfileManager.GetUserInfoInMemory(nid);
	if(userinfo) then
		return userinfo.combatschool;
	end
end

-- get user combat secondary school gsid
-- @param nid: other player nid, if nil means myself
-- @return: secondary school gsid, nil if unavailable
--		969_CombatSecondarySchool_Fire
--		970_CombatSecondarySchool_Ice
--		971_CombatSecondarySchool_Storm
--		972_CombatSecondarySchool_Myth
--		973_CombatSecondarySchool_Life
--		974_CombatSecondarySchool_Death
--		975_CombatSecondarySchool_Balance
function Combat.GetSecondarySchoolGSID(nid)
	-- 26 Combat SecondarySchool? 辅修职业 青年版 
	local item;
	if(not nid) then
		item = ItemManager.GetItemByBagAndPosition(0, 26);
	else
		item = ItemManager.GetOPCItemByBagAndPosition(nid, 0, 26);
	end
	if(item and item.guid ~= 0) then
		return item.gsid;
	end
end

-- has user picked combat school
-- @return: true or false
function Combat.HasPickedSchool()
	local userinfo = ProfileManager.GetUserInfoInMemory();
	if(userinfo and userinfo.combatschool) then
		return (userinfo.combatschool>=986 and userinfo.combatschool<=991)
	end
	return false;
end

-- get user combat level
function Combat.GetMyCombatLevel()
	local level = 1;
	-- get the level information from memory
	local bean = MyCompany.Aries.Pet.GetBean();
	if(bean) then
		level = bean.combatlel or 1;
	elseif(Combat.localuser) then
		level = Combat.localuser.combatlel or level;
	end
	return level;
end

-- get user combat level
function Combat.GetCombatLevelInMemory(nid)
	-- get the level information from memory
	if(not nid or nid == ProfileManager.GetNID()) then
		return Combat.GetMyCombatLevel();
	else
		local combatlevel = 0;
		-- default value for other player is 0
		local userinfo = ProfileManager.GetUserInfoInMemory(nid);
		if(userinfo) then
			combatlevel = userinfo.combatlel or 0;
		end
		return combatlevel;
	end
end

-- @param type: "1v1" "2v2"
-- @return: nil if not valid
function Combat.GetMyPvPRanking(type)
	local base;
	if(type == "1v1") then
		base = 20046;
	elseif(type == "2v2") then
		base = 20048;
	else
		return;
	end

	local hasGSItem = ItemManager.IfOwnGSItem;
	local bhas, _, __, count1 = hasGSItem(base);
	if(not bhas or not count1) then
		count1 = 0;
	end
	local bhas, _, __, count2 = hasGSItem(base + 1);
	if(not bhas or not count2) then
		count2 = 0;
	end

	return (1000 + count1 - count2);
end
 
-- @param type: "1v1" "2v2"
-- @return: nil if not valid
function Combat.GetOtherUserPvPRanking(nid, type)
	local base;
	if(type == "1v1") then
		base = 20046;
	elseif(type == "2v2") then
		base = 20048;
	else
		return;
	end

	local hasGSItem = ItemManager.IfOPCOwnGSItem;
	local bhas, _, __, count1 = hasGSItem(nid, base);
	if(not bhas or not count1) then
		count1 = 0;
	end
	local bhas, _, __, count2 = hasGSItem(nid, base + 1);
	if(not bhas or not count2) then
		count2 = 0;
	end

	return (1000 + count1 - count2);
end

-- this is the more accurate version of combat ability. 
-- think of this score as total damage dealt with 0 damage card on a dummy puppet plus the required damage so that 100 damage can be taken on this player. 
-- gs = PowerPipPercentage + max_attack_value_of_five_school + average_resist_of_five_school
-- for example: user with 0 attack, 0 resist has a gs of 0
--              user with 80% max attack, 30% average resist has a gs of 80+ 100/(1-30%) = 222
--              user with 160% max attack, 50% average resist has a gs of 160+ 100/(1-50%) = 360
--              user with 160% max attack, 70% average resist has a gs of 160+ 100/(1-70%) = 493
function Combat.GetGearScoreV2(nid)
	local gearscore = 0;

	gearscore = gearscore + Combat.GetPowerPipChance(nil, nid);

	local max_attack_abs = math.max(
		(100 + Combat.GetStats("fire", "damage", nid)) * (1 + Combat.GetStats("fire", "damage_absolute_base", nid) / 100), 
		(100 + Combat.GetStats("ice", "damage", nid)) * (1 + Combat.GetStats("ice", "damage_absolute_base", nid) / 100), 
		(100 + Combat.GetStats("storm", "damage", nid)) * (1 + Combat.GetStats("storm", "damage_absolute_base", nid) / 100), 
		(100 + Combat.GetStats("life", "damage", nid))  * (1 + Combat.GetStats("life", "damage_absolute_base", nid) / 100), 
		(100 + Combat.GetStats("death", "damage", nid))  * (1 + Combat.GetStats("death", "damage_absolute_base", nid) / 100) 
		);
	gearscore = gearscore + max_attack_abs;

	local resist_average = 
		100 / ( 1 - 0.01 * (
			Combat.GetStats("fire", "resist", nid) + 
			Combat.GetStats("ice", "resist", nid) + 
			Combat.GetStats("storm", "resist", nid) + 
			Combat.GetStats("life", "resist", nid) + 
			Combat.GetStats("death", "resist", nid)
		) / 5 ) * (1 + (
			Combat.GetStats("fire", "resist_absolute_base", nid) + 
			Combat.GetStats("ice", "resist_absolute_base", nid) + 
			Combat.GetStats("storm", "resist_absolute_base", nid) + 
			Combat.GetStats("life", "resist_absolute_base", nid) + 
			Combat.GetStats("death", "resist_absolute_base", nid)
		) / 5 / 100);
	gearscore = gearscore + resist_average;
	
	return math.ceil(gearscore);
end

-- get gear score
-- @param bIngoreLevel: if true, we will ignore combat level and use 
function Combat.GetGearScore(nid, bIngoreLevel)
	
	local gearscore = 0;
	local combatlevel = 0;
	
	-- get the level information from memory
	if(not nid) then
		local bean = MyCompany.Aries.Pet.GetBean();
		if(bean) then
			combatlevel = bean.combatlel or 1;
		else
			combatlevel = 1;
		end
	else
		-- default value for other player is 0
		local userinfo = ProfileManager.GetUserInfoInMemory(nid);
		if(userinfo) then
			combatlevel = userinfo.combatlel or 0;
		else
			combatlevel = 0;
		end
	end

	if(not bIngoreLevel) then
		gearscore = gearscore + combatlevel * 100;
	end

	gearscore = gearscore + Combat.GetPowerPipChance(nil, nid) * 25;

	gearscore = gearscore + Combat.GetStats("fire", "damage", nid) * 5;
	gearscore = gearscore + Combat.GetStats("ice", "damage", nid) * 5;
	gearscore = gearscore + Combat.GetStats("storm", "damage", nid) * 5;
	gearscore = gearscore + Combat.GetStats("life", "damage", nid) * 5;
	gearscore = gearscore + Combat.GetStats("death", "damage", nid) * 5;

	gearscore = gearscore + Combat.GetStats("fire", "resist", nid) * 5;
	gearscore = gearscore + Combat.GetStats("ice", "resist", nid) * 5;
	gearscore = gearscore + Combat.GetStats("storm", "resist", nid) * 5;
	gearscore = gearscore + Combat.GetStats("life", "resist", nid) * 5;
	gearscore = gearscore + Combat.GetStats("death", "resist", nid) * 5;

	gearscore = gearscore + math.ceil(Combat.GetStats("fire", "damage_absolute_base", nid) * (100 + Combat.GetStats("fire", "damage_absolute_percent", nid)) / 100) * 5;
	gearscore = gearscore + math.ceil(Combat.GetStats("ice", "damage_absolute_base", nid) * (100 + Combat.GetStats("ice", "damage_absolute_percent", nid)) / 100) * 5;
	gearscore = gearscore + math.ceil(Combat.GetStats("storm", "damage_absolute_base", nid) * (100 + Combat.GetStats("storm", "damage_absolute_percent", nid)) / 100) * 5;
	gearscore = gearscore + math.ceil(Combat.GetStats("life", "damage_absolute_base", nid) * (100 + Combat.GetStats("life", "damage_absolute_percent", nid)) / 100) * 5;
	gearscore = gearscore + math.ceil(Combat.GetStats("death", "damage_absolute_base", nid) * (100 + Combat.GetStats("death", "damage_absolute_percent", nid)) / 100) * 5;
	
	gearscore = gearscore + math.ceil(Combat.GetStats("fire", "resist_absolute_base", nid) * (100 + Combat.GetStats("fire", "resist_absolute_percent", nid)) / 100) * 5;
	gearscore = gearscore + math.ceil(Combat.GetStats("ice", "resist_absolute_base", nid) * (100 + Combat.GetStats("ice", "resist_absolute_percent", nid)) / 100) * 5;
	gearscore = gearscore + math.ceil(Combat.GetStats("storm", "resist_absolute_base", nid) * (100 + Combat.GetStats("storm", "resist_absolute_percent", nid)) / 100) * 5;
	gearscore = gearscore + math.ceil(Combat.GetStats("life", "resist_absolute_base", nid) * (100 + Combat.GetStats("life", "resist_absolute_percent", nid)) / 100) * 5;
	gearscore = gearscore + math.ceil(Combat.GetStats("death", "resist_absolute_base", nid) * (100 + Combat.GetStats("death", "resist_absolute_percent", nid)) / 100) * 5;
	
	return gearscore;
end


-- @param gsid:
--		986_CombatSchool_Fire
--		987_CombatSchool_Ice
--		988_CombatSchool_Storm
--		989_CombatSchool_Myth
--		990_CombatSchool_Life
--		991_CombatSchool_Death
--		992_CombatSchool_Balance
function Combat.GSID_SchoolToSecondarySchool(gsid)
	if(gsid and gsid >= 986 and gsid <= 992) then
		return gsid - 17;
	end
end

-- @param gsid:
--		969_CombatSecondarySchool_Fire
--		970_CombatSecondarySchool_Ice
--		971_CombatSecondarySchool_Storm
--		972_CombatSecondarySchool_Myth
--		973_CombatSecondarySchool_Life
--		974_CombatSecondarySchool_Death
--		975_CombatSecondarySchool_Balance
function Combat.GSID_SecondarySchoolToSchool(gsid)
	if(gsid and gsid >= 969 and gsid <= 975) then
		return gsid + 17;
	end
end

-- NOTE: teen version ONLY
-- some spell don't require combat school or secondary school match
local SchoolIrrelevant_GSIDs = {
	[22120] = true, -- 22120_Fire_FireGreatShield
	[22157] = true, -- 22157_Ice_IceGreatShield
	[22138] = true, -- 22138_Storm_StormGreatShield
	[22180] = true, -- 22180_Life_LifeGreatShield
	[22199] = true, -- 22199_Death_DeathGreatShield
	[22142] = true, -- 22142_Balance_GlobalShield
};

-- NOTE: at certain combat level, not all qualified card from level 0
-- NOTE: return both main school and secondary school qualified cards gsids
function Combat.GetMyQualifiedCardGSIDsAtLevel(level)
	if(not level) then
		LOG.std(nil, "error", "Combat", "Combat.GetMyQualifiedCardGSIDsAtLevel got invalid input: "..commonlib.serialize({level}));
		return;
	end

	if(System.options.version == "kids") then
		LOG.std(nil, "error", "Combat", "Combat.GetMyQualifiedCardGSIDsAtLevel is not for kids");
		return;
	end
	
	local qualified_gsids = {};

	-- primary school
	local school_gsid = Combat.GetSchoolGSID();
	if(school_gsid) then
		local gsids = cardgsids_by_school[school_gsid];
		if(gsids) then
			local _, gsid;
			for _, gsid in ipairs(gsids) do
				if(not SchoolIrrelevant_GSIDs[gsid]) then
					local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
					-- 138 combatlevel_requirement(CG) 
					-- 249 card_can_learn(CG) 用户可以靠系别或者辅修得到的技能 主要是白卡 以及配置是在xml文件中 (青年版) 
					if(gsItem and gsItem.template.stats[138] and gsItem.template.stats[249]) then
						if(gsItem.template.stats[138] == level) then
							table.insert(qualified_gsids, gsid);
						end
					end
				end
			end
		end
	end
	
	-- secondary school
	local school_gsid = Combat.GetSecondarySchoolGSID();
	if(school_gsid) then
		local gsids = cardgsids_by_school[school_gsid];
		if(gsids) then
			local _, gsid;
			for _, gsid in ipairs(gsids) do
				if(not SchoolIrrelevant_GSIDs[gsid]) then
					local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
					-- 138 combatlevel_requirement(CG) 
					-- 249 card_can_learn(CG) 用户可以靠系别或者辅修得到的技能 主要是白卡 以及配置是在xml文件中 (青年版) 
					if(gsItem and gsItem.template.stats[138] and gsItem.template.stats[249]) then
						if(gsItem.template.stats[138] == level) then
							table.insert(qualified_gsids, gsid);
						end
					end
				end
			end
		end
	end
	
	-- school irrelevant
	local gsid, _;
	for gsid, _ in pairs(SchoolIrrelevant_GSIDs) do
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
		-- don't check balance school
		-- 136 school_card_or_qualification(C) 卡片或卷轴的属性 6火 7冰 8风暴 9神秘 10生命 11死亡 12平衡
		if(gsItem.template.stats[136] ~= 12) then
			-- 138 combatlevel_requirement(CG) 
			-- 249 card_can_learn(CG) 用户可以靠系别或者辅修得到的技能 主要是白卡 以及配置是在xml文件中 (青年版) 
			if(gsItem and gsItem.template.stats[138] and gsItem.template.stats[249]) then
				if(gsItem.template.stats[138] == level) then
					table.insert(qualified_gsids, gsid);
				end
			end
		end
	end

	-- Balance school
	-- 992_CombatSchool_Balance
	local school_gsid = 992;
	local gsids = cardgsids_by_school[school_gsid];
	if(gsids) then
		local _, gsid;
		for _, gsid in ipairs(gsids) do
			local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
			-- 138 combatlevel_requirement(CG) 
			-- 249 card_can_learn(CG) 用户可以靠系别或者辅修得到的技能 主要是白卡 以及配置是在xml文件中 (青年版) 
			if(gsItem and gsItem.template.stats[138] and gsItem.template.stats[249]) then
				if(gsItem.template.stats[138] == level) then
					table.insert(qualified_gsids, gsid);
				end
			end
		end
	end
	
	return qualified_gsids;
end

-- NOTE: teen version ONLY!
--		 user cards are qualified by combat level and school
-- @param school_gsid:
--		986_CombatSchool_Fire
--		987_CombatSchool_Ice
--		988_CombatSchool_Storm
--		989_CombatSchool_Myth
--		990_CombatSchool_Life
--		991_CombatSchool_Death
--		992_CombatSchool_Balance
-- @param level: combat level
function Combat.GetQualifiedCardGSIDsBySchoolAndLevel(school_gsid, level)
	if(not school_gsid or not level) then
		LOG.std(nil, "error", "Combat", "Combat.GetQualifiedCardGSIDsBySchoolAndLevel got invalid input: "..commonlib.serialize({school_gsid, level}));
		return;
	end
	
	local qualified_gsids = {};
	local gsids = cardgsids_by_school[school_gsid];
	if(System.options.version == "kids") then
		return gsids;
	end
	if(gsids) then
		local _, gsid;
		for _, gsid in ipairs(gsids) do
			local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
			-- 138 combatlevel_requirement(CG) 
			-- 249 card_can_learn(CG) 用户可以靠系别或者辅修得到的技能 主要是白卡 以及配置是在xml文件中 (青年版) 
			if(gsItem and gsItem.template.stats[138] and gsItem.template.stats[249]) then
				if(gsItem.template.stats[138] <= level) then
					table.insert(qualified_gsids, gsid);
				end
			end
		end
	end
	return qualified_gsids;
end

-- NOTE: teen version ONLY!
-- get user qualified cards by any given combat level
-- @param level: combat level
function Combat.GetMyQualifiedCardGSIDsByGivenLevel(combat_level)
	if(not combat_level) then
		LOG.std(nil, "error", "Combat", "Combat.GetMyQualifiedCardGSIDsByLevel got invalid input: "..tostring(combat_level));
		return;
	end
	-- pending faked negative guid card items
	local school_gsid = Combat.GetSchoolGSID();
	local secondaryschool_gsid = Combat.GetSecondarySchoolGSID();
	local qualified_gsids = {};
	if(school_gsid and combat_level) then
		local gsids = Combat.GetQualifiedCardGSIDsBySchoolAndLevel(school_gsid, combat_level);
		local _, gsid;
		for _, gsid in ipairs(gsids) do
			qualified_gsids[gsid] = true;
		end
	end
	if(secondaryschool_gsid and combat_level) then
		local school_gsid = Combat.GSID_SecondarySchoolToSchool(secondaryschool_gsid)
		if(school_gsid) then
			local gsids = Combat.GetQualifiedCardGSIDsBySchoolAndLevel(school_gsid, combat_level);
			local _, gsid;
			for _, gsid in ipairs(gsids) do
				qualified_gsids[gsid] = true;
			end
		end
	end
	if(qualified_gsids) then
		local gsid, _;
		for gsid, _ in pairs(SchoolIrrelevant_GSIDs) do
			local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
			if(gsItem) then
				local require_level = gsItem.template.stats[138];
				if(not require_level or require_level <= combat_level) then
					qualified_gsids[gsid] = true;
				end
			end
		end
	end
	return qualified_gsids;
end


-- is player over weight, if over weight the player will receive a half attribute penetration
--return: is_over_weight,e,total_count,capacity_count
function Combat.IsOverWeight()
	return Player.IsBagTooHeavy();
end

-- 
function Combat.HasZeroDurability()
	local itemlist = ItemManager.GetItemsInBagInMemory(0);
	local _, guid;
	for _, guid in pairs(itemlist) do
		local item = ItemManager.GetItemByGUID(guid);
		if(item and item.guid > 0) then
			local gsItem = ItemManager.GetGlobalStoreItemInMemory(item.gsid);
			if(gsItem) then
				-- 222 装备耐久度
				if(gsItem.template.stats[222]) then
					if(item:GetDurability() == 0) then
						return true;
					end
				end
			end
		end
	end
	return false;
end

-- get lowest durability in percent 0 ~ 100
-- for durability debuff tooltip
function Combat.GetLowestDurabilityPercent()
	local lowest_durabilitypercent = 100;
	local itemlist = ItemManager.GetItemsInBagInMemory(0);
	local _, guid;
	for _, guid in pairs(itemlist) do
		local item = ItemManager.GetItemByGUID(guid);
		if(item and item.guid > 0) then
			local gsItem = ItemManager.GetGlobalStoreItemInMemory(item.gsid);
			if(gsItem) then
				-- 222 装备耐久度
				local full_durability = gsItem.template.stats[222];
				if(full_durability) then
					local current_durability = item:GetDurability();
					if(current_durability and full_durability) then
						local this_percent = math.ceil(current_durability * 100 / full_durability);
						if(this_percent < lowest_durabilitypercent) then
							lowest_durabilitypercent = this_percent;
						end
					end
				end
			end
		end
	end
	return lowest_durabilitypercent;
end

-- 
function Combat.GetDurabilityTooltip()
	local tooltip = "";
	local itemlist = ItemManager.GetItemsInBagInMemory(0);
	local _, guid;
	for _, guid in pairs(itemlist) do
		local item = ItemManager.GetItemByGUID(guid);
		if(item and item.guid > 0) then
			local gsItem = ItemManager.GetGlobalStoreItemInMemory(item.gsid);
			if(gsItem) then
				-- 222 装备耐久度
				if(gsItem.template.stats[222]) then
					if(item:GetDurability() == 0) then
						if(tooltip ~= "") then
							tooltip = tooltip..",";
						end
						if(item.position == 1) then
							tooltip = tooltip.."帽子";
						elseif(item.position == 8) then
							tooltip = tooltip.."背部";
						elseif(item.position == 5) then
							tooltip = tooltip.."衣服";
						elseif(item.position == 9) then
							tooltip = tooltip.."手套";
						elseif(item.position == 7) then
							tooltip = tooltip.."鞋子";
						elseif(item.position == 11) then
							tooltip = tooltip.."主手武器";
						elseif(item.position == 17) then
							tooltip = tooltip.."项链";
						elseif(item.position == 14) then
							tooltip = tooltip.."耳环";
						elseif(item.position == 15) then
							tooltip = tooltip.."手镯";
						elseif(item.position == 16) then
							tooltip = tooltip.."戒指";
						elseif(item.position == 12) then
							tooltip = tooltip.."护腕";
						elseif(item.position == 10) then
							tooltip = tooltip.."副手武器";
						end
					end
				end
			end
		end
	end
	if(tooltip ~= "") then
		tooltip = "装备耐久损失:\n你的"..tooltip.."损坏了，修理之后才能发挥作用";
	end
	return tooltip;
end

-- get school name by gsid
-- 986_CombatSchool_Fire
-- 987_CombatSchool_Ice
-- 988_CombatSchool_Storm
-- 989_CombatSchool_Myth
-- 990_CombatSchool_Life
-- 991_CombatSchool_Death
-- 992_CombatSchool_Balance
function Combat.GetSchoolNameByGSID(gsid)
	local item_school_name = nil;
	local item_school = nil;
	if(gsid == 986) then
		item_school_name = "烈火";
		item_school = "fire";
	elseif(gsid == 987) then
		item_school_name = "寒冰";
		item_school = "ice";
	elseif(gsid == 988) then
		item_school_name = "风暴";
		item_school = "storm";
	elseif(gsid == 989) then
		item_school_name = "神秘";
		item_school = "myth";
	elseif(gsid == 990) then
		item_school_name = "生命";
		item_school = "life";
	elseif(gsid == 991) then
		item_school_name = "死亡";
		item_school = "death";
	elseif(gsid == 992) then
		item_school_name = "平衡";
		item_school = "balance";
	end
	return item_school_name;
end

-- get stats sum 
-- NOTE: stat type please refer to wiki page http://pedn/KidsDev/ItemSystemDesign
-- @param stats_ids: {102, 103, ...}
-- @return: stat value sum of the given stat types
local function GetStatsSum(stats_ids, nid)
	local value = 0;
	if(nid == ProfileManager.GetNID()) then
		nid = nil;
	end
	-- update the stat sum by equips
	local itemlist;
	if(not nid) then
		itemlist = ItemManager.GetItemsInBagInMemory(0);
	else
		itemlist = ItemManager.GetOPCItemsInBagInMemory(nid, 0) or {};
	end

	if(not itemlist) then
		return 0;
	end
	local _, guid;
	for _, guid in pairs(itemlist) do
		local item;
		if(not nid) then
			 item = ItemManager.GetItemByGUID(guid);
		else
			 item = ItemManager.GetOPCItemByGUID(nid, guid);
		end
		if(item and item.guid > 0) then
			local isValidItem = true;
			if(item.IsDurable and item:IsDurable() and item.GetDurability and item:GetDurability() <= 0) then
				isValidItem = false;
			end

			-- check ranking valid
			if(item.IsRankingValid and not item:IsRankingValid()) then
				isValidItem = false;
			end

			if(isValidItem) then
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(item.gsid);
				if(gsItem) then
					local stats = gsItem.template.stats;
					local _, stat_type;
					for _, stat_type in ipairs(stats_ids) do
						-- add stat from equips
						value = value + (stats[stat_type] or 0);
					end
					local bWithSocket = false;
					if(System.options.version == "kids") then
						-- 36 Item_Socket_Count(CS)
						if(stats[36] and stats[36] > 0) then
							bWithSocket = true;
						end
					elseif(System.options.version == "teen") then
						-- check function existance for teen version
						if(item.PrepareSocketedGemsIfNot and item.GetSocketedGems) then
							bWithSocket = true;
						end
					end
					if(bWithSocket) then
						-- item with gem sockets
						item:PrepareSocketedGemsIfNot();
						local gems = item:GetSocketedGems();
						if(gems) then
							local bWithMetaResist = false;
							if(System.options.version == "teen") then
								--王田(Andy) 09:45:40
								--42 这个stat  多彩是21    其他防御宝石分别是多少
								--李龙(李龙) 09:45:55
								--骚等
								--李龙(李龙) 09:46:56
								--火抗 11
								--冰抗 12
								--风暴抗 13
								--生命抗 14
								--死亡抗 15
								local _, gsid;
								for _, gsid in pairs(gems) do
									local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
									if(gsItem) then
										local stat_42 = gsItem.template.stats[42];
										if(stat_42 == 21) then
											bWithMetaResist = true;
											break;
										end
									end
								end
							end
							local _, gsid;
							for _, gsid in pairs(gems) do
								local bValidGem = true;
								local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
								if(gsItem) then
									if(bWithMetaResist) then
										local stat_42 = gsItem.template.stats[42];
										if(stat_42 == 11 or stat_42 == 12 or stat_42 == 13 or stat_42 == 14 or stat_42 == 15) then
											bValidGem = false;
										end
									end
									if(bValidGem) then
										local stats = gsItem.template.stats;
										local _, stat_type;
										for _, stat_type in ipairs(stats_ids) do
											-- add stat from gems
											value = value + (stats[stat_type] or 0);
										end
									end
								end
							end
						end
					end
					if(item.GetAddonAttackPercentage) then
						local damage_percent = item:GetAddonAttackPercentage() or 0;
						local _, stat_type;
						for _, stat_type in ipairs(stats_ids) do
							-- add stat from addon
							-- 111 add_damage_overall_percent(CG) 增加用户所有系魔法的附加攻击百分比  
							if(stat_type == 111) then
								value = value + damage_percent;
							end
						end
					end
					if(item.GetAddonAttackAbsolute) then
						local damage_absolute = item:GetAddonAttackAbsolute() or 0;
						local _, stat_type;
						for _, stat_type in ipairs(stats_ids) do
							-- add stat from addon
							-- 151 add_damage_overall_absolute(CG) 增加用户所有系魔法的附加伤害绝对值(青年版用这个) 
							if(stat_type == 151) then
								value = value + damage_absolute;
							end
						end
					end
					if(item.GetAddonResistAbsolute) then
						local resist_absolute = item:GetAddonResistAbsolute() or 0;
						local _, stat_type;
						for _, stat_type in ipairs(stats_ids) do
							-- add stat from addon
							-- 159 add_resist_overall_absolute(CG) 增加用户所有系魔法的附加抗性绝对值(青年版用这个) 
							if(stat_type == 159) then
								value = value + resist_absolute;
							end
						end
					end
					if(item.GetAddonHpAbsolute) then
						local HP_absolute = item:GetAddonHpAbsolute() or 0;
						local _, stat_type;
						for _, stat_type in ipairs(stats_ids) do
							-- add stat from addon
							-- 151 add_damage_overall_absolute(CG) 增加用户所有系魔法的附加伤害绝对值(青年版用这个) 
							if(stat_type == 101) then
								value = value + HP_absolute;
							end
						end
					end
					if(item.GetResiliencePercent) then
						local resilience_percentage = item:GetResiliencePercent() or 0;
						local _, stat_type;
						for _, stat_type in ipairs(stats_ids) do
							-- add stat from addon
							if(stat_type == 204) then
								value = value + resilience_percentage;
							end
						end
					end
					if(item.GetCriticalStrikePercent) then
						local critical_strick_percent = item:GetCriticalStrikePercent() or 0;
						local _, stat_type;
						for _, stat_type in ipairs(stats_ids) do
							-- add stat from addon
							if(stat_type == 196) then
								value = value + critical_strick_percent;
							end
						end
					end

				end
			end
		end
	end
	
	-- get stats from dragon totem
	local profession_gsid = 0;
	local exp_gsid = 0;
	local exp_cnt = 0;
	--52 巨龙之“牙”、“爪”，“鳞”，“心”标记 儿童版第一次使用  
	--53 巨龙图腾经验值标记 儿童版第一次使用 
	local item_profession;
	if(not nid) then
		item_profession = ItemManager.GetItemByBagAndPosition(0, 52);
	else
		item_profession = ItemManager.GetOPCItemByBagAndPosition(nid, 0, 52);
	end
	local item_exp;
	if(not nid) then
		item_exp = ItemManager.GetItemByBagAndPosition(0, 53);
	else
		item_exp = ItemManager.GetOPCItemByBagAndPosition(nid, 0, 53);
	end
	if(item_profession and item_profession.guid ~= 0 and item_exp and item_exp.guid ~= 0) then
		profession_gsid = item_profession.gsid;
		exp_gsid = item_exp.gsid;
		exp_cnt = item_exp.copies;
	elseif(item_profession and item_profession.guid ~= 0) then
		if(System.options.version == "kids" and item_profession.gsid and item_profession.gsid >= 50351 and item_profession.gsid <= 50354) then
			profession_gsid = item_profession.gsid;
			exp_gsid = 50359;
			exp_cnt = 0;
		elseif(System.options.version == "teen" and item_profession.gsid and item_profession.gsid >= 50377 and item_profession.gsid <= 50385) then
			profession_gsid = item_profession.gsid;
			exp_gsid = 50389;
			exp_cnt = 0;
		end
	end
	local stats = Card.GetStatsFromDragonTotemProfessionAndExp(profession_gsid, exp_gsid, exp_cnt);
	if(stats) then
		local _, stat_type;
		for _, stat_type in pairs(stats_ids) do
			value = value + (stats[stat_type] or 0);
		end
	end
	
	-- get stats from item set, myself or other player
	local itemset_stats = Combat.GetCurrentItemSetStats(nid);
	if(itemset_stats) then
		local _, stat_type;
		for _, stat_type in pairs(stats_ids) do
			value = value + (itemset_stats[stat_type] or 0);
		end
	end

	-- get stats from combat pet
	local myfollowpet_guid = 0;
	local item;
	if(not nid) then
		item = ItemManager.GetItemByBagAndPosition(0, 32);
	else
		item = ItemManager.GetOPCItemByBagAndPosition(nid, 0, 32);
	end
	if(item and item.guid ~= 0) then
		if(item.GetCurLevelProps) then
			local stats = item:GetCurLevelProps();
			if(stats) then
				local _, stat_type;
				for _, stat_type in pairs(stats_ids) do
					value = value + (stats[stat_type] or 0);
				end
			end
		end
	end

	--111 add_damage_overall_percent(CG) 增加用户所有系魔法的附加攻击百分比  
	--112 add_damage_fire_percent(CG) 增加用户火系魔法的附加攻击百分比  
	--113 add_damage_ice_percent(CG) 增加用户冰系魔法的附加攻击百分比  
	--114 add_damage_storm_percent(CG) 增加用户风暴系魔法的附加攻击百分比  
	--115 add_damage_myth_percent(CG) 增加用户神秘系魔法的附加攻击百分比  
	--116 add_damage_life_percent(CG) 增加用户生命系魔法的附加攻击百分比  
	--117 add_damage_death_percent(CG) 增加用户死亡系魔法的附加攻击百分比  
	--118 add_damage_balance_percent(CG) 增加用户平衡系魔法的附加攻击百分比  

	if(type == "damage") then
	end

	if(Combat.IsOverWeight() and not nid) then
		value = math.ceil(value / 2);
	end

	return value;
end

-- get the updated max hp
-- @param level: user level provided, if not provided, use local version
function Combat.GetUpdateMaxHP(level, nid)
	-- return the tutorial hp
	local CombatTutorial = commonlib.gettable("MyCompany.Aries.Quest.NPCs.CombatTutorial");
	if(CombatTutorial and CombatTutorial.IsInTutorial and CombatTutorial.IsInTutorial()) then
		return 300;
	end

	if(not level) then
		-- get the level information from memory
		if(not nid) then
			level = Combat.GetMyCombatLevel();
		else
			local userinfo = ProfileManager.GetUserInfoInMemory(nid);
			if(userinfo) then
				level = userinfo.combatlel or 1;
			else
				level = 1;
			end
		end
	end

	-- update the hp by school and level
	local hp = 400;
	local school = Combat.GetSchool(nid);
	if(school == "fire") then
		hp = math.ceil((1500 - 415) * (level - 1) / 49 + 415);
	elseif(school == "ice") then
		hp = math.ceil((2025 - 500) * (level - 1) / 49 + 500);
	elseif(school == "storm") then
		hp = math.ceil((1200 - 400) * (level - 1) / 49 + 400);
	--elseif(school == "myth") then
		--hp = math.ceil((1500 - 425) * (level - 1) / 49 + 425);
	elseif(school == "life") then
		hp = math.ceil((1800 - 460) * (level - 1) / 49 + 460);
	elseif(school == "death") then
		hp = math.ceil((1650 - 450) * (level - 1) / 49 + 450);
	--elseif(school == "balance") then
		--hp = math.ceil((1800 - 480) * (level - 1) / 49 + 480);
	else
		hp = math.ceil((1200 - 400) * (level - 1) / 49 + 400);
	end

	if(System.options.version == "teen") then
		-- update the hp by school and level for teen
		local school = Combat.GetSchool(nid);
		if(school == "fire") then
			hp = math.ceil(36 * (level - 1) + 450);
		elseif(school == "ice") then
			hp = math.ceil(48 * (level - 1) + 600);
		elseif(school == "storm") then
			hp = math.ceil(34 * (level - 1) + 425);
		--elseif(school == "myth") then
			--hp = math.ceil(120 * (level - 1) + 415);
		elseif(school == "life") then
			hp = math.ceil(42 * (level - 1) + 540);
		elseif(school == "death") then
			hp = math.ceil(40 * (level - 1) + 500);
		--elseif(school == "balance") then
			--hp = math.ceil(120 * (level - 1) + 415);
		else
			hp = math.ceil(34 * (level - 1) + 425);
		end
	end

	if(System.options.version == "kids") then
		--王瑞(阿水) 10:34:30
		--(1+10%)*基础血量*3.14
		-- 242 add_maximum_hp_percent(CG) 增加用户HP基础上限百分比(青年版用这个) 
		hp = math.ceil(hp + hp * 3.14 * GetStatsSum({242}, nid) / 100);
	
	elseif(System.options.version == "teen") then
		-- 242 add_maximum_hp_percent(CG) 增加用户HP基础上限百分比(青年版用这个) 
		hp = math.ceil(hp * (100 + GetStatsSum({242}, nid)) / 100);
	end
	
	-- only kids version with vip HP bonus
	if(System.options.version == "kids") then
		if(not nid) then
			-- vip bonus
			if(VIP.IsVIP()) then
				local m_level = VIP.GetMagicStarLevel();
				local bonus = vip_bonus_hp[m_level + 1] or 0;
				hp = math.ceil(hp * (100 + bonus) / 100);
			end
		else
			-- vip bonus
			if(VIP.IsUserVIPInMemory(nid)) then
				local m_level = VIP.GetUserMagicStarLevelInMemory(nid);
				local bonus = vip_bonus_hp[m_level + 1] or 0;
				hp = math.ceil(hp * (100 + bonus) / 100);
			end
		end
	end

	hp = hp + GetStatsSum({101}, nid);

	if(Combat.localuser) then
		hp = hp + (Combat.localuser.addonlevel_hp_absolute or 0)
	end
	return hp;
end

-- get power pip chance
-- @return: power pip chance in percent, if return 10, means 10% percent
function Combat.GetPowerPipChance(level, nid)
	if(not level) then
		-- get the level information from memory
		if(not nid) then
			level = Combat.GetMyCombatLevel();
		else
			local userinfo = ProfileManager.GetUserInfoInMemory(nid);
			if(userinfo) then
				level = userinfo.combatlel or 1;
			else
				level = 1;
			end
		end
	end

	-- update the power pip chance by level
	local chance = 10;
	if(level < 10) then
		chance = 0;
	else
		chance = math.floor((40 - 10) * (level - 10) / 40 + 10);
	end

	if(System.options.version == "teen") then
		chance = level / 2;
	end
	
	chance = chance + GetStatsSum({102}, nid);

	return chance;
end

-- get power pip chance
-- @param school: fire, ice, storm, ...
-- @param type: accuracy, damage, resist
-- @param nid: other player nid, if nil means myself
-- @return: power pip chance in percent, if return 10, means 10% percent
function Combat.GetStats(school, type, nid)
	if(not school or not type) then
		LOG.std(nil, "error", "Combat", "Combat.GetStats got invalid input: "..commonlib.serialize({school, type}));
		return;
	end

	local stat = 0;
	local base_stat_type = nil;
	local stat_ids = {};
	if(type == "accuracy") then
		--103 add_accuracy_overall_percent(CG)
		--104 add_accuracy_fire_percent(CG)
		--105 add_accuracy_ice_percent(CG)
		--106 add_accuracy_storm_percent(CG)
		--107 add_accuracy_myth_percent(CG)
		--108 add_accuracy_life_percent(CG)
		--109 add_accuracy_death_percent(CG)
		--110 add_accuracy_balance_percent(CG)
		base_stat_type = 103;
	elseif(type == "damage") then
		--111 add_damage_overall_percent(CG)
		--112 add_damage_fire_percent(CG)
		--113 add_damage_ice_percent(CG)
		--114 add_damage_storm_percent(CG)
		--115 add_damage_myth_percent(CG)
		--116 add_damage_life_percent(CG)
		--117 add_damage_death_percent(CG)
		--118 add_damage_balance_percent(CG)
		base_stat_type = 111;
	elseif(type == "resist") then
		--119 add_resist_overall_percent(CG)
		--120 add_resist_fire_percent(CG)
		--121 add_resist_ice_percent(CG)
		--122 add_resist_storm_percent(CG)
		--123 add_resist_myth_percent(CG)
		--124 add_resist_life_percent(CG)
		--125 add_resist_death_percent(CG)
		--126 add_resist_balance_percent(CG)
		base_stat_type = 119;
	elseif(type == "damage_absolute_base") then
		--151 add_damage_overall_absolute(CG)
		--152 add_damage_fire_absolute(CG)
		--153 add_damage_ice_absolute(CG)
		--154 add_damage_storm_absolute(CG)
		--155 add_damage_myth_absolute(CG)
		--156 add_damage_life_absolute(CG)
		--157 add_damage_death_absolute(CG)
		--158 add_damage_balance_absolute(CG)
		base_stat_type = 151;
	elseif(type == "resist_absolute_base") then
		--159 add_resist_overall_absolute(CG)
		--160 add_resist_fire_absolute(CG)
		--161 add_resist_ice_absolute(CG)
		--162 add_resist_storm_absolute(CG)
		--163 add_resist_myth_absolute(CG)
		--164 add_resist_life_absolute(CG)
		--165 add_resist_death_absolute(CG)
		--166 add_resist_balance_absolute(CG)
		base_stat_type = 159;
	elseif(type == "damage_absolute_percent") then
		--226 add_damage_overall_absolute_bonus_percent(CG)
		--227 add_damage_fire_absolute_bonus_percent(CG)
		--228 add_damage_ice_absolute_bonus_percent(CG)
		--229 add_damage_storm_absolute_bonus_percent(CG)
		--230 add_damage_myth_absolute_bonus_percent(CG)
		--231 add_damage_life_absolute_bonus_percent(CG)
		--232 add_damage_death_absolute_bonus_percent(CG)
		--233 add_damage_balance_absolute_bonus_percent(CG)
		base_stat_type = 226;
	elseif(type == "resist_absolute_percent") then 
		--234 add_resist_overall_absolute_bonus_percent(CG)
		--235 add_resist_fire_absolute_bonus_percent(CG)
		--236 add_resist_ice_absolute_bonus_percent(CG)
		--237 add_resist_storm_absolute_bonus_percent(CG)
		--238 add_resist_myth_absolute_bonus_percent(CG)
		--239 add_resist_life_absolute_bonus_percent(CG)
		--240 add_resist_death_absolute_bonus_percent(CG)
		--241 add_resist_balance_absolute_bonus_percent(CG)
		base_stat_type = 234; 
	end
	
	if(base_stat_type) then
		if(school == "fire") then
			table.insert(stat_ids, base_stat_type);
			table.insert(stat_ids, base_stat_type + 1);
		elseif(school == "ice") then
			table.insert(stat_ids, base_stat_type);
			table.insert(stat_ids, base_stat_type + 2);
		elseif(school == "storm") then
			table.insert(stat_ids, base_stat_type);
			table.insert(stat_ids, base_stat_type + 3);
		--elseif(school == "myth") then
			--table.insert(stat_ids, base_stat_type);
			--table.insert(stat_ids, base_stat_type + 4);
		elseif(school == "life") then
			table.insert(stat_ids, base_stat_type);
			table.insert(stat_ids, base_stat_type + 5);
		elseif(school == "death") then
			table.insert(stat_ids, base_stat_type);
			table.insert(stat_ids, base_stat_type + 6);
		elseif(school == "balance") then
			table.insert(stat_ids, base_stat_type);
			table.insert(stat_ids, base_stat_type + 7);
		end
	end

	stat = GetStatsSum(stat_ids, nid);
	
	-- vip bonus
	if(not nid) then
		-- myself
		if(VIP.IsVIP(nid)) then
			local m_level = VIP.GetMagicStarLevel(nid);
			if(type == "accuracy") then
				stat = stat + (vip_bonus_accuracy[m_level + 1] or 0);
			elseif(type == "damage") then
				stat = stat + (vip_bonus_damage[m_level + 1] or 0);
			elseif(type == "resist") then
				stat = stat + (vip_bonus_resist[m_level + 1] or 0);
			end
		end
	else
		-- other player
		if(VIP.IsUserVIPInMemory(nid)) then
			local m_level = VIP.GetUserMagicStarLevelInMemory(nid);
			if(type == "accuracy") then
				stat = stat + (vip_bonus_accuracy[m_level + 1] or 0);
			elseif(type == "damage") then
				stat = stat + (vip_bonus_damage[m_level + 1] or 0);
			elseif(type == "resist") then
				stat = stat + (vip_bonus_resist[m_level + 1] or 0);
			end
		end
	end

	if(type == "resist" and stat >= 70) then
		stat = 70;
	end

	if(System.options.version == "teen") then
		NPL.load("(gl)script/apps/Aries/Combat/MsgHandler.lua");
		if(MyCompany.Aries.Combat.MsgHandler.GetGlobalExpScaleAcc() == 1) then
			-- double global exp buff
			if(type == "resist_absolute_base") then
				stat = stat + 3; -- additional resist bonus
			end
		end
	end
	
	-- get additional damage absolute from combat level
	if(System.options.version == "teen") then
		if(type == "damage_absolute_base") then
			local bonus_from_level = 0;
			local level = Combat.GetCombatLevelInMemory(nid);
			local school_name = Combat.GetSchool(nid);
			if(level) then
				bonus_from_level = level * 1;
			end
			if(Combat.IsOverWeight() and not nid) then
				bonus_from_level = math.ceil(bonus_from_level / 2);
			end
			stat = stat + bonus_from_level;
		elseif(type == "resist_absolute_base") then
			local bonus_from_level = 0;
			local level = Combat.GetCombatLevelInMemory(nid);
			local school_name = Combat.GetSchool(nid);
			if(level) then
				bonus_from_level = level * 1;
			end
			if(Combat.IsOverWeight() and not nid) then
				bonus_from_level = math.ceil(bonus_from_level / 2);
			end
			stat = stat + bonus_from_level;
		end
	end

	return stat;
end

-- 182 output_heal_percent(CG) 输出治疗加成百分比  
-- 183 input_heal_percent(CG) 输入治疗加成百分比  
-- get output heal boost percent
-- @return: 10 means 10% heal boost
function Combat.GetOutputHealBoost(nid)
	local stat = 0;
	local base_stat_type = nil;
	local stat_ids = {};
	table.insert(stat_ids, 182);

	-- get base stats sum
	stat = GetStatsSum(stat_ids, nid);
	
	-- vip bonus
	if(not nid) then
		-- myself
		if(VIP.IsVIP(nid)) then
			local m_level = VIP.GetMagicStarLevel(nid);
			stat = stat + (vip_bonus_output_heal[m_level + 1] or 0);
		end
	else
		-- other player
		if(VIP.IsUserVIPInMemory(nid)) then
			local m_level = VIP.GetUserMagicStarLevelInMemory(nid);
			stat = stat + (vip_bonus_output_heal[m_level + 1] or 0);
		end
	end
	return stat;
end

-- 182 output_heal_percent(CG) 输出治疗加成百分比  
-- 183 input_heal_percent(CG) 输入治疗加成百分比  
-- get output heal boost percent
-- @return: 10 means 10% heal boost
function Combat.GetInputHealBoost(nid)
	local stat = 0;
	local base_stat_type = nil;
	local stat_ids = {};
	table.insert(stat_ids, 183);

	-- get base stats sum
	stat = GetStatsSum(stat_ids, nid);
	
	-- vip bonus
	if(not nid) then
		-- myself
		if(VIP.IsVIP(nid)) then
			local m_level = VIP.GetMagicStarLevel(nid);
			stat = stat + (vip_bonus_input_heal[m_level + 1] or 0);
		end
	else
		-- other player
		if(VIP.IsUserVIPInMemory(nid)) then
			local m_level = VIP.GetUserMagicStarLevelInMemory(nid);
			stat = stat + (vip_bonus_input_heal[m_level + 1] or 0);
		end
	end
	return stat;
end

-- 220 add_agility_rating(CG)
-- get agility
-- @return: agility stat
function Combat.GetAgility(nid)
	local stat = GetStatsSum({220}, nid);
	return stat;
end

-- 196 add_critical_strike_overall_percent(CG) 
-- 224 add_critical_strike_overall_rating(CG)
function Combat.GetCriticalStrikeChance(nid)
	local stat = 0;
	stat = stat + GetStatsSum({196}, nid);
	
	-- 254 add_critical_strike_overall_percent_10times(CG) 增加用户所有系魔法的暴击百分比 1:10 当数值为15时代表1.5% 并且和stat196叠加 
	stat = stat + GetStatsSum({254}, nid) / 10;
	
	if(Combat.GetCombatLevelInMemory(nid) == 0) then
		return stat;
	end
	
	local critical_rating = GetStatsSum({224}, nid);
	stat = stat + 100 * critical_rating / (50 + Combat.GetCombatLevelInMemory(nid) * 50);

	return stat;
end

-- 224 add_critical_strike_overall_rating(CG)
function Combat.GetCriticalStrikeRatingSum(nid)
	return GetStatsSum({224}, nid);
end

-- 204 add_resilience_overall_percent(CG) 
-- 225 add_resilience_overall_rating(CG) 
function Combat.GetResilienceChance(nid)
	local stat = 0;
	stat = stat + GetStatsSum({204}, nid);
	
	-- 255 add_resilience_overall_percent_10times(CG) 增加用户所有系魔法的韧性百分比 1:10 当数值为15时代表1.5% 并且和stat204叠加  
	stat = stat + GetStatsSum({255}, nid) / 10;

	if(Combat.GetCombatLevelInMemory(nid) == 0) then
		return stat;
	end
	
	local resilience_rating = GetStatsSum({225}, nid);
	stat = stat + 100 * resilience_rating / (50 + Combat.GetCombatLevelInMemory(nid) * 50);

	return stat;
end
-- 225 add_resilience_overall_rating(CG) 
function Combat.GetResilienceRatingSum(nid)
	return GetStatsSum({225}, nid);
end

-- 243 add_hitchance_overall_percent(CG)
-- 244 add_hitchance_overall_rating(CG) 增加用户所有系魔法的命中强度
function Combat.GetHitChance(nid)
	local stat = GetStatsSum({243}, nid) / 10;
	local stat_rating = GetStatsSum({244, nid});

	local level = Combat.GetCombatLevelInMemory(nid);
	stat = stat_rating * 100 / (level * 50 + 50) + stat;

	return stat;
end

-- 188 add_dodge_overall_percent(CG)
-- 245 add_dodge_overall_rating(CG) 增加用户所有系魔法的闪避强度 
function Combat.GetDodgeChance(nid)
	local stat = GetStatsSum({188}, nid) / 10;
	local stat_rating = GetStatsSum({245});
	
	local level = Combat.GetCombatLevelInMemory(nid);
	stat = stat_rating / (level * 50 + 50) + stat;

	return stat;
end

-- 376 暴击额外伤害加成 84中配置为1代表0.1%的额外暴击伤害
function Combat.GetCriticalStrikeDamageBonus(nid)
	local stat = GetStatsSum({376}, nid) / 10;

	return stat;
end

-- 212 add_spell_penetration_overall_percent(CG)
-- get agility
-- @return: agility stat
function Combat.GetSpellPenetrationChance(nid)
	local stat = GetStatsSum({212}, nid);
	return stat;
end

-- 151 add_damage_overall_absolute(CG) 增加用户所有系魔法的附加伤害绝对值
function Combat.GetDamageAbsoluteBaseChance(nid)
	local stat = GetStatsSum({151}, nid);
	return stat;
end

-- 159 add_resist_overall_absolute(CG) 增加用户所有系魔法的附加抗性绝对值
function Combat.GetResistAbsoluteBaseChance(nid)
	local stat = GetStatsSum({159}, nid);
	return stat;
end

-- get equip cards
-- @return: gsid and count pairs, {[22200] = 6, [22201] = 1 } means equiped cards contains 6 gsid 22200 cards and 1 gsid 22201 card
function Combat.GetEquipCards()
	local EquipCards = {};
	-- get equip card from appreal
	local itemlist = ItemManager.GetItemsInBagInMemory(0);
	local _, guid;
	for _, guid in pairs(itemlist) do
		local item = ItemManager.GetItemByGUID(guid);
		if(item and item.guid > 0) then
			local gsItem = ItemManager.GetGlobalStoreItemInMemory(item.gsid);
			if(gsItem) then
				local stats = gsItem.template.stats;
				-- 139 ~ 150 additional_card(CG)
				for key, value in pairs(stats) do
					if(key >= 139 and key <= 150) then
						EquipCards[value] = (EquipCards[value] or 0) + 1;
					end
				end
			end
		end
	end
	return EquipCards;
end

-- get follow pet cards
-- @return: gsid and count pairs, {[22200] = 6, [22201] = 1 } means equiped cards contains 6 gsid 22200 cards and 1 gsid 22201 card
function Combat.GetPetCards()
	local PetCards = {};
	-- get equip card from combat pet
	local myfollowpet_guid = 0;
	local item = ItemManager.GetItemByBagAndPosition(0, 32);
	if(item and item.guid ~= 0) then
		if(item.GetCurLevelCards) then
			local cards = item:GetCurLevelCards();
			if(cards) then
				local _, gsid
				for _, gsid in pairs(cards) do
					PetCards[gsid] = (PetCards[gsid] or 0) + 1;
				end
			end
		end
	end
	return PetCards;
end

-- get equip deck gsid
-- @return: deck gsid, nil if invalid or not equiped
function Combat.GetEquipDeckGSID()
	local item = ItemManager.GetItemByBagAndPosition(0, 24); -- position 24 is combat deck
	if(item and item.guid > 0) then
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(item.gsid);
		if(gsItem) then
			if(gsItem.template.class == 19 and gsItem.template.subclass == 1) then
				-- combat deck
				return item.gsid;
			end
		end
	end
end

-- get equip armor gsid
-- NOTE: "armor" includes wand
-- @return: gsids table
function Combat.GetEquipArmorGSIDs()
	local gsids = {};
	-- update the power pip chance by equips
	local itemlist = ItemManager.GetItemsInBagInMemory(0);
	local _, guid;
	for _, guid in pairs(itemlist) do
		local item = ItemManager.GetItemByGUID(guid);
		if(item and item.guid > 0 and item.gsid > 1000) then -- skip the combat school tag
			local gsItem = ItemManager.GetGlobalStoreItemInMemory(item.gsid);
			if(gsItem) then
				if(string.find(string.lower(gsItem.category), "combat")) then
					table.insert(gsids, item.gsid);
				end
			end
		end
	end
	return gsids;
end

-- get equip armor gsid with durability
-- NOTE: "armor" includes wand
-- @return: gsids table
function Combat.GetEquipArmorGSIDs_with_durability()
	local gsids = {};
	-- update the power pip chance by equips
	local itemlist = ItemManager.GetItemsInBagInMemory(0);
	local _, guid;
	for _, guid in pairs(itemlist) do
		local item = ItemManager.GetItemByGUID(guid);
		if(item and item.guid > 0 and item.gsid > 1000) then -- skip the combat school tag
			local isValidItem = true;
			if(item.IsDurable and item:IsDurable() and item.GetDurability and item:GetDurability() <= 0) then
				isValidItem = false;
			end
			if(isValidItem) then
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(item.gsid);
				if(gsItem) then
					if(string.find(string.lower(gsItem.category), "combat")) then
						table.insert(gsids, item.gsid);
					end
				end
			end
		end
	end
	return gsids;
end

-- get equip armor gem gsid
-- NOTE: "armor" includes wand
-- @return: gsids table
function Combat.GetEquipArmorGemGSIDs()
	local gsids = {};
	-- update the power pip chance by equips
	local itemlist = ItemManager.GetItemsInBagInMemory(0);
	local _, guid;
	for _, guid in pairs(itemlist) do
		local item = ItemManager.GetItemByGUID(guid);
		if(item and item.guid > 0) then
			local gsItem = ItemManager.GetGlobalStoreItemInMemory(item.gsid);
			if(gsItem) then
				if(string.find(string.lower(gsItem.category), "combat")) then
					if(item.PrepareSocketedGemsIfNot) then
						-- in case of combat deck object
						item:PrepareSocketedGemsIfNot()
						local gems = item:GetSocketedGems();
						if(gems) then
							local _, gsid;
							for _, gsid in pairs(gems) do
								table.insert(gsids, gsid);
							end
						end
					end
				end
			end
		end
	end
	return gsids;
end

-- get equip armor gem gsid with durability
-- NOTE: "armor" includes wand
-- @return: gsids table
function Combat.GetEquipArmorGemGSIDs_with_durability()
	local gsids = {};
	-- update the power pip chance by equips
	local itemlist = ItemManager.GetItemsInBagInMemory(0);
	local _, guid;
	for _, guid in pairs(itemlist) do
		local item = ItemManager.GetItemByGUID(guid);
		if(item and item.guid > 0) then
			local isValidItem = true;
			if(item.IsDurable and item:IsDurable() and item.GetDurability and item:GetDurability() <= 0) then
				isValidItem = false;
			end
			if(isValidItem) then
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(item.gsid);
				if(gsItem) then
					if(string.find(string.lower(gsItem.category), "combat")) then
						if(item.PrepareSocketedGemsIfNot) then
							-- in case of combat deck object
							item:PrepareSocketedGemsIfNot()
							local gems = item:GetSocketedGems();
							if(gems) then
								local _, gsid;
								for _, gsid in pairs(gems) do
									table.insert(gsids, gsid);
								end
							end
						end
					end
				end
			end
		end
	end
	return gsids;
end

-- get my pvp stats
-- GetMyPvPStats("1v1", "win_count")
-- GetMyPvPStats("2v2", "winning_rate")
-- GetMyPvPStats("2v2", "rating")
function Combat.GetMyPvPStats(arena, type)
	
	if(System.options.version == "kids" or System.options.version == "teen") then
		return Combat.GetMyPvPStats_New(arena, type);
	end

	--20032_RedMushroomPvP_1v1_WinningCount
	--20033_RedMushroomPvP_1v1_LosingCount
	--20034_RedMushroomPvP_2v2_WinningCount
	--20035_RedMushroomPvP_2v2_LosingCount
	--20036_RedMushroomPvP_3v3_WinningCount
	--20037_RedMushroomPvP_3v3_LosingCount
	--20038_RedMushroomPvP_4v4_WinningCount
	--20039_RedMushroomPvP_4v4_LosingCount
	local hasGSItem = ItemManager.IfOwnGSItem;
	local base = 20032;
	local base_offset = 0;
	if(arena == "1v1") then
		base = 20032;
	elseif(arena == "2v2") then
		base = 20034;
	elseif(arena == "3v3") then
		base = 20036;
	elseif(arena == "4v4") then
		base = 20038;
	end
	if(type == "win_count") then
		base_offset = 0;
	elseif(type == "lose_count") then
		base_offset = 1;
	elseif(type == "winning_rate") then
		base_offset = nil;
	elseif(type == "rating") then
		base_offset = nil;
	end

	local rating_revise = 1;
	local my_level = Combat.GetMyCombatLevel();
	if(my_level >= 50) then
		rating_revise = 1;
	elseif(my_level >= 40) then
		rating_revise = 0.5;
	elseif(my_level >= 30) then
		rating_revise = 0.25;
	elseif(my_level >= 20) then
		rating_revise = 0.125;
	else
		rating_revise = 0.1;
	end

	if(base_offset == 0 or base_offset == 1) then
		local bhas,_,__,count = hasGSItem(base + base_offset);
		if(not bhas or not count)then
			count = 0;
		end
		return count;
	elseif(base_offset == nil) then
		
		local bhas,_,__,count1 = hasGSItem(base);
		if(not bhas or not count1)then
			count1 = 0;
		end
		local bhas,_,__,count2 = hasGSItem(base + 1);
		if(not bhas or not count2)then
			count2 = 0;
		end
		if(count1 == 0 and count2 == 0 and (count1 + count2) == 0) then
			return 0;
		end
				
		if(type == "winning_rate") then
			return math.ceil(100 * count1 / ((count1 + count2)));
		elseif(type == "rating") then
			return math.ceil(rating_revise * count1 * 10 * count1 / ((count1 + count2)));
		end
	end
	return 0;
end

-- get my pvp stats
-- GetMyPvPStats("1v1", "win_count")
-- GetMyPvPStats("2v2", "winning_rate")
-- GetMyPvPStats("2v2", "rating")
function Combat.GetMyPvPStats_New(arena, type)
	--20032_RedMushroomPvP_1v1_WinningCount
	--20033_RedMushroomPvP_1v1_LosingCount
	--20034_RedMushroomPvP_2v2_WinningCount
	--20035_RedMushroomPvP_2v2_LosingCount
	--20036_RedMushroomPvP_3v3_WinningCount
	--20037_RedMushroomPvP_3v3_LosingCount
	--20038_RedMushroomPvP_4v4_WinningCount
	--20039_RedMushroomPvP_4v4_LosingCount
	local hasGSItem = ItemManager.IfOwnGSItem;
	local base = 20032;
	local base_offset = 0;
	if(arena == "1v1") then
		base = 20032;
	elseif(arena == "2v2") then
		base = 20034;
	elseif(arena == "3v3") then
		base = 20036;
	elseif(arena == "4v4") then
		base = 20038;
	end
	if(type == "win_count") then
		base_offset = 0;
	elseif(type == "lose_count") then
		base_offset = 1;
	elseif(type == "winning_rate") then
		base_offset = nil;
	elseif(type == "rating") then
		if(arena == "1v1") then
			base = 20046;
		elseif(arena == "2v2") then
			base = 20048;
		end
		if(System.options.version == "kids" and (arena == "1v1" or arena == "2v2")) then
			local gearScore = Player.GetGearScore();
			base = Combat.GetPVPPointGSID(arena,gearScore,"win");
		end
		base_offset = nil;
	end

	local rating_revise = 1;
	local my_level = Combat.GetMyCombatLevel();
	if(my_level >= 50) then
		rating_revise = 1;
	elseif(my_level >= 40) then
		rating_revise = 0.5;
	elseif(my_level >= 30) then
		rating_revise = 0.25;
	elseif(my_level >= 20) then
		rating_revise = 0.125;
	else
		rating_revise = 0.1;
	end

	if(base_offset == 0 or base_offset == 1) then
		local bhas,_,__,count = hasGSItem(base + base_offset);
		if(not bhas or not count)then
			count = 0;
		end
		return count;
	elseif(base_offset == nil) then
		
		local bhas,_,__,count1 = hasGSItem(base);
		if(not bhas or not count1)then
			count1 = 0;
		end
		local bhas,_,__,count2 = hasGSItem(base + 1);
		if(not bhas or not count2)then
			count2 = 0;
		end
		if(type == "winning_rate" and count1 == 0 and count2 == 0 and (count1 + count2) == 0) then
			return 0;
		end
				
		if(type == "winning_rate") then
			return math.ceil(100 * count1 / ((count1 + count2)));
		elseif(type == "rating") then
			--return math.ceil(rating_revise * count1 * 10 * count1 / ((count1 + count2)));
			return 1000 + count1 - count2;
		end
	end
	return 0;
end

-- current item set id, if no item set available nil
local current_item_set_effect = {};
local current_item_set_effect_other_players = {};

-- all item set effect, id as key and stats table as value
local all_item_set_effect = nil;

-- all item set name, id as key and name as value
local all_item_set_name = nil;

-- id as key and component item gsid table as value
local all_item_set_components = nil;

-- prepare item set all
-- traverse through all items in global store and sort out the item set ids
function Combat.InitAllItemSetIfNot()
	-- parse all item set effects if not parsed before
	if(not all_item_set_effect) then
		all_item_set_effect = {};
		all_item_set_name = {};
		local xmlRoot;
		if(System.options.version == "teen") then
			xmlRoot = ParaXML.LuaXML_ParseFile("config/Aries/ItemSet/AllItemSetAttr_Teen.xml");
		else
			xmlRoot = ParaXML.LuaXML_ParseFile("config/Aries/ItemSet/AllItemSetAttr.xml");
		end
		local each_itemset;
		for each_itemset in commonlib.XPath.eachNode(xmlRoot, "/ItemSetAttr/itemset") do
			local set_id = tonumber(each_itemset.attr.id);
			local item_set_effect = {};
			local each_stat_group;
			for each_stat_group in commonlib.XPath.eachNode(each_itemset, "/stat_group") do
				local item_count = tonumber(each_stat_group.attr.items);
				local stats = {};
				stats.item_count = item_count;
				local each_stat;
				for each_stat in commonlib.XPath.eachNode(each_stat_group, "/stat") do
					local type = tonumber(each_stat.attr.type);
					local value = tonumber(each_stat.attr.value);
					stats[type] = value;
				end
				table.insert(item_set_effect, stats);
			end
			table.sort(item_set_effect, function(a, b)
				return (a.item_count < b.item_count);
			end);
			all_item_set_effect[set_id] = item_set_effect;
			all_item_set_name[set_id] = tostring(each_itemset.attr.name or "套装"..set_id);
		end
		-- parse all item set components if not parsed before
		if(not all_item_set_components) then
			all_item_set_components = {};
			local gsid = 1001;
			for gsid = 1001, 8999 do
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
				if(gsItem) then
					local itemsetid = gsItem.template.itemsetid;
					if(all_item_set_effect[itemsetid]) then
						all_item_set_components[itemsetid] = all_item_set_components[itemsetid] or {};
						all_item_set_components[itemsetid][gsid] = true;
					end
				end
			end
		end
		--aaaaaaaaaaaaaaa-----------
		--echo:{{[101]=100,[102]=10,},{[101]=200,[102]=20,},}
		--echo:{{[1415]=true,[1370]=true,[1430]=true,[1385]=true,[1400]=true,},{[1401]=true,[1416]=true,[1371]=true,[1431]=true,[1386]=true,},}
	end
end

-- perpare the item set info in bag 0, this function will be called on every bag 0 update
-- @param nid: other player character nid, if nil myself
function Combat.PrepareItemSet(nid)
	-- init item set if not
	Combat.InitAllItemSetIfNot()
	-- reset the current item set effect id
	if(not nid) then
		current_item_set_effect = {};
	else
		current_item_set_effect_other_players[nid] = {};
	end
	local gsids = {};
	-- record all item gsids
	if(not nid) then
		local itemlist = ItemManager.GetItemsInBagInMemory(0);
		local _, guid;
		for _, guid in pairs(itemlist) do
			local item = ItemManager.GetItemByGUID(guid);
			if(item and item.guid > 0) then
				local isValidItem = true;
				if(item.IsDurable and item:IsDurable() and item.GetDurability and item:GetDurability() <= 0) then
					isValidItem = false;
				end
				if(isValidItem) then
					gsids[item.gsid] = true;
				end
			end
		end
	else
		local itemlist = ItemManager.GetOPCItemsInBagInMemory(nid, 0) or {};
		local _, guid;
		for _, guid in pairs(itemlist) do
			local item = ItemManager.GetOPCItemByGUID(nid, guid);
			if(item and item.guid > 0) then
				local isValidItem = true;
				if(item.IsDurable and item:IsDurable() and item.GetDurability and item:GetDurability() <= 0) then
					isValidItem = false;
				end
				if(isValidItem) then
					gsids[item.gsid] = true;
				end
			end
		end
	end

	-- check all item set components
	local setid_component_count = {};
	local itemset_id, components;
	for itemset_id, components in pairs(all_item_set_components) do
		local is_full_geared = true;
		local component_gsid, _;
		for component_gsid, _ in pairs(components) do
			if(gsids[component_gsid]) then
				setid_component_count[itemset_id] = (setid_component_count[itemset_id] or 0) + 1;
			end
		end
	end
	if(not nid) then
		current_item_set_effect = setid_component_count;
	else
		current_item_set_effect_other_players[nid] = setid_component_count;
	end
end

-- get current item set id
function Combat.GetCurrentItemSetID(nid)
	if(not nid) then
		return current_item_set_effect;
	else
		return current_item_set_effect_other_players[nid];
	end
end

-- get current item set stats
function Combat.GetCurrentItemSetStats(nid)
	local stats = {};
	local current_item_set_effect_thisfunc = nil;
	if(not nid) then
		current_item_set_effect_thisfunc = current_item_set_effect;
	else
		current_item_set_effect_thisfunc = current_item_set_effect_other_players[nid];
	end
	if(current_item_set_effect_thisfunc and all_item_set_effect) then
		local itemset_id, count;
		for itemset_id, count in pairs(current_item_set_effect_thisfunc) do
			local item_set_effect = all_item_set_effect[itemset_id];
			local _, item_set_stats_group;
			for _, item_set_stats_group in ipairs(item_set_effect) do
				if(count >= item_set_stats_group.item_count) then
					local stat_type, stat_value;
					for stat_type, stat_value in pairs(item_set_stats_group) do
						if(stat_type ~= item_count and type(stat_type) == "number") then
							stats[stat_type] = (stats[stat_type] or 0) + stat_value;
						end
					end
				end
			end
		end
	end
	return stats;
end

-- get item set components
function Combat.GetItemSetComponents(id)
	if(id and all_item_set_components) then
		return all_item_set_components[id];
	end
end

-- get item set stats
function Combat.GetItemSetStats(id)
	if(id and all_item_set_effect) then
		return all_item_set_effect[id];
	end
end

-- get item set name
function Combat.GetItemSetName(id)
	if(id and all_item_set_name) then
		return all_item_set_name[id];
	end
end

function Combat.GetStatMap(stat_id)
	NPL.load("(gl)script/apps/Aries/Desktop/GenericTooltip.lua");
	if(CommonCtrl.GenericTooltip) then
		return CommonCtrl.GenericTooltip.GetStatMap(stat_id)
	end
end

function Combat.GetStatWord_OfTypeValue(type, value)
    if(type and value) then
        if(type == 101) then
			return string.format("HP+%d",value);
        elseif(type == 102) then
			if(System.options.version == "teen") then
				return "双倍魔力+"..value.."%";
			else
				return "超魔+"..value.."%";
			end
        elseif(type == 103) then
            return "通用命中率+"..value.."%";
        elseif(type == 104) then
            return "烈火命中率+"..value.."%";
        elseif(type == 105) then
            return "寒冰命中率+"..value.."%";
        elseif(type == 106) then
            return "风暴命中率+"..value.."%";
        elseif(type == 107) then
            return "神秘命中率+"..value.."%";
        elseif(type == 108) then
            return "生命命中率+"..value.."%";
        elseif(type == 109) then
            return "死亡命中率+"..value.."%";
        elseif(type == 110) then
            return "平衡命中率+"..value.."%";
        elseif(type == 111) then
            return "通用攻击+"..value.."%";
        elseif(type == 112) then
            return "烈火攻击+"..value.."%";
        elseif(type == 113) then
            return "寒冰攻击+"..value.."%";
        elseif(type == 114) then
            return "风暴攻击+"..value.."%";
        elseif(type == 115) then
            return "神秘攻击+"..value.."%";
        elseif(type == 116) then
            return "生命攻击+"..value.."%";
        elseif(type == 117) then
            return "死亡攻击+"..value.."%";
        elseif(type == 118) then
            return "平衡攻击+"..value.."%";
        elseif(type == 119) then
            return "通用防御+"..value.."%";
        elseif(type == 120) then
            return "烈火防御+"..value.."%";
        elseif(type == 121) then
            return "寒冰防御+"..value.."%";
        elseif(type == 122) then
            return "风暴防御+"..value.."%";
        elseif(type == 123) then
            return "神秘防御+"..value.."%";
        elseif(type == 124) then
            return "生命防御+"..value.."%";
        elseif(type == 125) then
            return "死亡防御+"..value.."%";
        elseif(type == 126) then
            return "平衡防御+"..value.."%";

		elseif(type == 151) then
			if(CommonClientService.IsTeenVersion())then
				return "通用攻击+"..value.. "%";
			else
				return "伤害+"..value.. "%";
			end
		elseif(type == 152) then
            return "烈火攻击+"..value.. "%";
		elseif(type == 153) then
            return "寒冰攻击+"..value.. "%";
		elseif(type == 154) then
            return "风暴攻击+"..value.. "%";
		elseif(type == 155) then
            return "神秘攻击+"..value.. "%";
		elseif(type == 156) then
            return "生命攻击+"..value.. "%";
		elseif(type == 157) then
            return "死亡攻击+"..value.. "%";
		elseif(type == 158) then
            return "平衡攻击+"..value.. "%";
		elseif(type == 159) then
			if(CommonClientService.IsTeenVersion())then
				return "通用防御+"..value.. "%";
			else
				return "受到伤害-"..value.. "%";
			end
		elseif(type == 160) then
            return "烈火防御+"..value.. "%";
		elseif(type == 161) then
            return "寒冰防御+"..value.. "%";
		elseif(type == 162) then
            return "风暴防御+"..value.. "%";
		elseif(type == 163) then
            return "神秘防御+"..value.. "%";
		elseif(type == 164) then
            return "生命防御+"..value.. "%";
		elseif(type == 165) then
            return "死亡防御+"..value.. "%";
		elseif(type == 166) then
            return "平衡防御+"..value.. "%";
        elseif(type == 182) then
            return "治疗+"..value.."%";
        elseif(type == 183) then
            return "被治疗+"..value.."%";
		 elseif(type == 188) then
			local s;
			if(System.options.version == "teen") then
				s = string.format("闪避+%.2f%%",value / 10);
			elseif(System.options.version == "kids") then
				s = string.format("绝对防御+%.2f%%",value / 10);
			end
			
            return s;
        elseif(type == 196) then
            return "暴击+"..value.."%";
        elseif(type == 204) then
            return "韧性+"..value.."%";
		elseif(type == 254) then
			if(value <= 0)then
				return "暴击+"..value.."%";
			else
				return string.format("暴击+%.2f%%",value / 10);
			end
        elseif(type == 255) then
			if(value <= 0)then
				return "韧性+"..value.."%";
			else
				return string.format("韧性+%.2f%%",value / 10);
			end
        elseif(type == 212) then
            return "魔法穿透率+"..value.."%";
		elseif(type == 224) then
            return "暴击等级+"..value;
		elseif(type == 225) then
            return "韧性等级+"..value;
		elseif(type == 226) then
            return "通用攻击+"..value .. "%";
		elseif(type == 227) then
            return "烈火攻击+"..value .. "%";
		elseif(type == 228) then
            return "寒冰攻击+"..value .. "%";
		elseif(type == 229) then
            return "风暴攻击+"..value .. "%";
		elseif(type == 230) then
            return "神秘攻击+"..value .. "%";
		elseif(type == 231) then
            return "生命攻击+"..value .. "%";
		elseif(type == 232) then
            return "死亡攻击+"..value .. "%";
		elseif(type == 233) then
            return "平衡攻击+"..value .. "%";
		elseif(type == 234) then
            return "通用防御+"..value .. "%";
		elseif(type == 235) then
            return "烈火防御+"..value .. "%";
		elseif(type == 236) then
            return "寒冰防御+"..value .. "%";
		elseif(type == 237) then
            return "风暴防御+"..value .. "%";
		elseif(type == 238) then
            return "神秘防御+"..value .. "%";
		elseif(type == 239) then
            return "生命防御+"..value .. "%";
		elseif(type == 240) then
            return "死亡防御+"..value .. "%";
		elseif(type == 241) then
            return "平衡防御+"..value .. "%";
		elseif(type == 242) then
            return "血量+"..value.."%";
		elseif(type == 243) then
			local s = string.format("命中+%.2f%%",value / 10);
            return s;-- 增加用户所有系魔法的命中百分比 此命中非儿童版的命中概念，不再是判断是否施放技能成败，而是判断是否偏斜；命中造成100%伤害，偏斜造成50%伤害
		elseif(type == 244) then
            return "通用命中+"..value;
		elseif(type == 245) then
            return "通用闪避+"..value;
		elseif(type == 256) then
            return "致命一击+"..value.."%";
        end
    end
end

function Combat.GetPVP3V3WinRate(nid)
	if(System.options.version ~= "kids") then
		return 0;
	end
	-- 20036:3v3 win tage
	-- 20037:3v3 lose tage
	local win_count,lose_count;
	
	if(not nid or nid == ProfileManager.GetNID()) then
		
		hasGSItem = ItemManager.IfOwnGSItem;	
		local bhas;
		bhas, _, __, win_count = hasGSItem(20036);
		if(not bhas or not win_count) then
			win_count = 0;
		end
		bhas, _, __, lose_count = hasGSItem(20037);
		if(not bhas or not lose_count) then
			lose_count = 0;
		end
	else
		hasGSItem = ItemManager.IfOPCOwnGSItem()
		local bhas;
		bhas, _, __, win_count = hasGSItem(nid,20036);
		if(not bhas or not win_count) then
			win_count = 0;
		end
		bhas, _, __, lose_count = hasGSItem(nid,20037);
		if(not bhas or not lose_count) then
			lose_count = 0;
		end
	end

	local rate;
	--if(win_count + lose_count <= 300) then
		--rate = 50;
	--else
		--rate = win_count/(win_count + lose_count);
		----rate = rate = math.floor(rate*100);
		--if(math.floor(rate*1000)%10 >= 5) then
			--rate = math.floor(rate*100) + 1;
		--else
			--rate = math.floor(rate*100);
		--end
	--end
	rate = win_count/(win_count + lose_count);
	--if(rate > 60) then
		--rate = 60;
	--elseif(rate < 40) then
		--rate = 40;
	--end
	return rate;
end