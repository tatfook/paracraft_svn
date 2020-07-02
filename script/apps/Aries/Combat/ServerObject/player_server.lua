--[[
Title: combat system player server for Aries App
Author(s): WangTian
Date: 2009/4/7
Area: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Combat/ServerObject/player_server.lua");

NOTE: player_server object is valid and only valid when the player is in combat on one arena
		the player_server object is destroyed immediately after player fled from the arena or finish the combat(victory or defeated)
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/GoldRankingList/ranking_server.lua");
local RankingServer = commonlib.gettable("MyCompany.Aries.GoldRankingList.RankingServer");

local format = format;
-- create class
local libName = "AriesCombat_Server_Player";
local Player = commonlib.gettable("MyCompany.Aries.Combat_Server.Player");

-- combat server
local combat_server = commonlib.gettable("MyCompany.Aries.Combat_Server.combat_server");
-- card server
local Card = commonlib.gettable("MyCompany.Aries.Combat_Server.Card");
-- arena class
local Arena = commonlib.gettable("MyCompany.Aries.Combat_Server.Arena");
-- mob server object
local Mob = commonlib.gettable("MyCompany.Aries.Combat_Server.Mob");

NPL.load("(gl)script/kids/3DMapSystemItem/PowerItemManager.lua");
local PowerItemManager = commonlib.gettable("Map3DSystem.Item.PowerItemManager");

local GSL_gateway = commonlib.gettable("Map3DSystem.GSL.gateway");

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

local LOG = LOG;
local string_format = string.format;
local table_insert = table.insert;
local string_lower = string.lower;
local math_ceil = math.ceil;
local math_floor = math.floor;
	
-- all players
local players = {};

-- max player pips
local maximum_player_pips_count = 7;

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

-- max player resist
local maximum_player_resist = 70;

-- heart arrest time out, if user is away from heart beat for 20 seconds the player is then tagged timed out
local heartarrest_timeout = 20000;

-- base hp after unit revive
local REVIVE_BASE_HP = 500;

-- max pvp arena rounds
local MAX_ROUNDS_PVP_ARENA = 100;
-- max pvp arena rounds
local MAX_ROUNDS_PVP_ARENA_BATTLEFIELD = 10000;

-- max count of switching to followpet
local MAX_SWITCHING_COUNT_FOLLOWPET_TEEN = 5;

-- default speak duration
local DEFAULT_SPEAK_DURATION = 1000;

-- the max idle rounds for kids version
local nMaxIdleRounds = 5;
--  the max accumulate idle rounds for kids version
local maxAccumulateIdleRounds = 10;
-- idle rounds note for kids
local idleRoundsNote = {
	["nIdleRounds"] = {
		[2] = true,
		[4] = true,
	},
	["accumulateIdleRounds"] = {
		[3] = true,
		[5] = true,
		[7] = true,
		[9] = true,
	}
};

local deck_struct_rune_all = {};

local function LoadRuneStruct()
	if(next(deck_struct_rune_all)) then
		return;
	end
	local filename = "config/Aries/Cards/RuneList.xml";
	if(System.options.version == "teen") then
		filename = "config/Aries/Cards/RuneList.teen.xml";
	end
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(xmlRoot) then
		local node;
		for node in commonlib.XPath.eachNode(xmlRoot, "/runelist/rune") do
			if(node.attr and node.attr.gsid and node.attr.gsid ~= "") then
				local gsid = tonumber(node.attr.gsid);
				local key = Card.Get_cardkey_from_rune_gsid(gsid);
				--local _,guid,_,copies=hasGSItem(gsid)
				--local rune = {gsid = gsid, guid = guid, copies = copies or 0};
				--table.insert(MyCardsManager.runeList,rune);
				deck_struct_rune_all[key] = true;
			end
		end
	end
end

local function GetRuneStruct()
	if(not next(deck_struct_rune_all)) then
		LoadRuneStruct()
	end
	return deck_struct_rune_all;
end

-- init the player constants if not
local bInitConstants = false;
function Player.InitConstantsIfNot()
	if(not bInitConstants) then
		if(System.options.version == "teen") then
			maximum_player_pips_count = 14;
			-- clear vip stats for teen
			vip_bonus_hp = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
			vip_bonus_damage = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
			vip_bonus_resist = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
			--vip_bonus_heal_output = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
			--vip_bonus_heal_input = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
			vip_bonus_accuracy = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
			vip_bonus_output_heal = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
			vip_bonus_input_heal = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
			REVIVE_BASE_HP = 525;
			MAX_ROUNDS_PVP_ARENA = 80;
		else
			maximum_player_pips_count = 7;
			REVIVE_BASE_HP = 2000;
			MAX_ROUNDS_PVP_ARENA = 100;
		end
		LoadRuneStruct();
	end
	bInitConstants = true;
end

-- constructor
-- @param o: typical player params including:
--		current_hp
--		max_hp
--		phase
function Player:new(o)
	Player.InitConstantsIfNot();
	o = o or {}; -- new table
	if(not o.current_hp or not o.max_hp) then
		LOG.std(nil, "error", "combatplayer", "nil health point got in function Player:new(o)");
		return;
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
	-- stance
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
	-- reflection shield amount
	o.reflect_amount = 0;
	-- pips
	o.pips_normal = 0;
	o.pips_power = 0;
	-- card history
	-- record all successfully used cards
	o.card_history = {};
	-- record all combat mode follow pet guids
	o.followpet_combatmode_history = {};
	-- record all cooldown records
	o.cooldown_record = {};
	-- last heart beat time
	o.nLastHeartBeatTime = combat_server.GetCurrentTime();
	-- last heart beat fail while try to pick card (pacemaker)
	o.nHeartPaceMakeFailCounter = 0;
	-- idle rounds, record the player finish the turn with no card picking
	o.nIdleRounds = 0;
	-- accumulate idle rounds for kids version, record the player finish the turn with no card picking
	o.accumulateIdleRounds = 0;
	-- keep a reference of the combat player object
	o.idleRoundsNote = commonlib.deepcopy(idleRoundsNote);
	players[o.nid] = o;
	-- check for current health point validity
	if(o.current_hp > o.max_hp) then
		LOG.std(nil, "error", "combatplayer", "current_hp exceeds max_hp");
		o.current_hp = o.max_hp;
	end
	-- check for current phase validity
	o:ValidatePlayerPhase();
	if(not o.phase) then
		o.phase = "storm";
	else
		o.phase = string.lower(o.phase);
		if(o.phase == "fire" or o.phase == "ice" or o.phase == "storm" or o.phase == "life" or o.phase == "death") then
			-- known phase
		else
			LOG.std(nil, "error", "combatplayer", "unknown phase:".. o.phase);
		end
	end
	-- TODO: check deck validity
	--o.deck_gsid;
	--o.deck_struct;
	-- deck and deck card construction
	-- generete deck card sequence, this sequence is to sort all deck cards in random order
	o.deck_card_sequence = {};
	-- each card in sequence has a tag marking the card status
	-- 0: un-used cards
	-- 1: avaiable cards at hand, 8 at maximum
	-- -1: discarded or used cards
	o.deck_card_mapping = {};

	-- remedy for deadlyAttack and absoluteDefense
	o.remedy={
		deadlyAttack_protect_rounds = 0,
		absoluteDefense_protect_rounds = 0,
	};
	
	-- as the deck card sequence and mapping, difference is the card source
	o.deck_followpet_card_sequence = {};
	o.deck_followpet_card_mapping = {};

	-- shuffle the deck cards
	o:ShuffleDeck();
	-- shuffle the follow pet cards
	o:ShuffleFollowPetCards();

	-- set itemset id if not
	o:SetItemSetInfoIfNot();
	
	-- TODO: validity check
	-- pass 1: equips
	-- pass 2: deck cards
	-- pass 3: gems
	-- pass 4: set id
	o.afk = false;
	o.deck_struct_rune = deck_struct_rune_all;
	return o;
end

-- on destroy
function Player:OnDestroy()
	-- remove player
	players[self:GetID()] = nil;
end

-- get arena side
-- @return: near or far
function Player:GetSide()
	return self.side;
end

-- get ranking point
-- @param stage: 1v1 or 2v2
function Player:GetRanking(stage)
	--if(stage == "1v1") then
	if(stage and string.match(stage,"1v1")) then
		return self:GetRanking_1v1(stage);
	elseif(stage and string.match(stage,"2v2")) then
		return self:GetRanking_2v2(stage);
	elseif(stage == "3v3") then
		return self:GetRanking_3v3();
	end
end

-- get checked ranking point, validate ranking point item
-- @param stage: 1v1 or 2v2
function Player:GetCheckedRanking(stage)
	local is_update_to_date, rank_date = self:CheckRankingItems(stage);
	if(is_update_to_date) then
		return self:GetRanking(stage);
	else
		return 1000;
	end
end

-- call this function once before arena begins. and once before summiting ranking score loots. and only summit if this function returns true. 
-- @param bNoDelete: if true, it will ignore deleting expired items. it will delete them by default. 
-- return is_update_to_date, rank_date:  is_update_to_date is true if items are all update to date, false if there are expired items. 
function Player:CheckRankingItems(stage, bNoDelete)
	
	if(System.options.version == "kids" and stage and stage == "3v3") then
		return self:CheckRankingItems_3v3(stage, bNoDelete);
	end

	local win_count_gsid, lose_count_gsid;
	local rank_name;
	if(stage == "1v1") then
		win_count_gsid, lose_count_gsid = 20046, 20047
		rank_name = "pk1v1"
	else -- if(stage == "2v2") then
		win_count_gsid, lose_count_gsid = 20048, 20049
		rank_name = "pk2v2"
	end

	if(System.options.version == "kids" and stage and (string.match(stage,"1v1") or string.match(stage,"2v2"))) then
		win_count_gsid = Arena.GetPVPPointGSID(stage,"win");
		lose_count_gsid = Arena.GetPVPPointGSID(stage,"lose");
		rank_name = "pk"..stage;
	end

	local rank_data = RankingServer.GetRankByName(rank_name);
	if(rank_data) then
		self.rankitem_serverdata = rank_data.rankitem_serverdata;
		local user_nid = self:GetNID();
		local updates;
		local item_gsid = win_count_gsid;
		local bOwn, guid, bag, copies = PowerItemManager.IfOwnGSItem(user_nid, item_gsid);

		if(guid) then
			local item = PowerItemManager.GetItemByGUID(user_nid, guid);
			if(item and (item.serverdata and item.serverdata~="" and item.serverdata~=rank_data.rankitem_serverdata)) then
				local _, _, _, lose_count = PowerItemManager.IfOwnGSItem(user_nid, lose_count_gsid);
				
				-- tricky: we will perserve the score if score is smaller than strict_pvp_score
				local strict_pvp_score = if_else(System.options.version == "teen", 1000, 1800);
				local score = copies - (lose_count or 0);

				if(score > 0) then
					score = math.floor(score/100) * 100;
					if(score >= (strict_pvp_score -1000)) then
						score = (strict_pvp_score - 1000);
					end
					if(copies > score) then
						copies = copies - score;
					else
						copies = 0;
					end
				end
				
				updates = string.format("%s%d~-%d~%s~NULL|", updates or "", guid, copies, rank_data.rankitem_serverdata);
			end
		end
		item_gsid = lose_count_gsid;
		bOwn, guid, bag, copies = PowerItemManager.IfOwnGSItem(user_nid, item_gsid);
		if(guid) then
			local item = PowerItemManager.GetItemByGUID(user_nid, guid);
			if(item and (item.serverdata and item.serverdata~="" and item.serverdata~=rank_data.rankitem_serverdata)) then
				updates = string.format("%s%d~-%d~%s~NULL|", updates or "", guid, copies, rank_data.rankitem_serverdata);
			end
		end
		if(updates) then
			if(not bNoDelete) then
				self.rankitem_resetting = true;
				-- remove any gsid that does not match the current ranking server date. 
				PowerItemManager.ChangeItem(user_nid, nil, updates, function(msg)
					LOG.std(nil, "info", "CheckRankingItems", "ranking items reset for user %d, %s", user_nid, updates);
					if(msg.issuccess) then
						---- TODO: update the gear with new serverdata
					else
						LOG.std(nil, "error", "PowerItemManager", "PowerItemManager.DestroyCardToMagicDirt callback function got error msg: "..commonlib.serialize_compact(msg));
					end
					self.rankitem_resetting = nil;
				end);
			end
			return false;
		end
	else
		self.rankitem_serverdata = nil;
	end
	self.rankitem_resetting = nil;
	return true;
end

-- this only call in check pvp 3v3 in "kids" version
-- call this function once before arena begins. and once before summiting ranking score loots. and only summit if this function returns true. 
-- @param bNoDelete: if true, it will ignore deleting expired items. it will delete them by default. 
-- return is_update_to_date, rank_date:  is_update_to_date is true if items are all update to date, false if there are expired items. 
function Player:CheckRankingItems_3v3(stage, bNoDelete)
	local score_gsid = 20091;
	local rank_name = "pk3v3";
	local rank_data = RankingServer.GetRankByName(rank_name);
	if(rank_data) then
		self.rankitem_serverdata = rank_data.rankitem_serverdata;
		local user_nid = self:GetNID();
		local updates;
		local item_gsid = score_gsid;
		local bOwn, guid, bag, copies = PowerItemManager.IfOwnGSItem(user_nid, item_gsid);

		if(guid) then
			local item = PowerItemManager.GetItemByGUID(user_nid, guid);
			if(item and (item.serverdata and item.serverdata~="" and item.serverdata~=rank_data.rankitem_serverdata)) then
				if(not copies) then
					copies = 0;
				end
				updates = string.format("%s%d~-%d~%s~NULL|", updates or "", guid, copies, rank_data.rankitem_serverdata);
			end
		end
		local pvp_3v3_get_times_per_day_tag_gsid = 50420;
		bOwn, guid, bag, copies = PowerItemManager.IfOwnGSItem(user_nid, pvp_3v3_get_times_per_day_tag_gsid);
		if(guid) then
			local item = PowerItemManager.GetItemByGUID(user_nid, guid);
			if(item and (item.serverdata and item.serverdata~="" and item.serverdata~=rank_data.rankitem_serverdata)) then
				if(not copies) then
					copies = 0;
				end
				updates = string.format("%s%d~-%d~%s~NULL|", updates or "", guid, copies, rank_data.rankitem_serverdata);
			end
		end

		if(updates) then
			if(not bNoDelete) then
				self.rankitem_resetting = true;
				-- remove any gsid that does not match the current ranking server date. 
				PowerItemManager.ChangeItem(user_nid, nil, updates, function(msg)
					LOG.std(nil, "info", "CheckRankingItems", "ranking items reset for user %d, %s", user_nid, updates);
					if(msg.issuccess) then
						---- TODO: update the gear with new serverdata
					else
						LOG.std(nil, "error", "PowerItemManager", "PowerItemManager.DestroyCardToMagicDirt callback function got error msg: "..commonlib.serialize_compact(msg));
					end
					self.rankitem_resetting = nil;
				end);
			end
			return false;
		end
	else
		self.rankitem_serverdata = nil;
	end
	self.rankitem_resetting = nil;
	return true;
end

-- submit current score.
function Player:SubmitScore(stage)
	local rank_name;
	if(stage and string.match(stage,"1v1")) then
		rank_name = "pk1v1"
		if(System.options.version == "kids") then
			rank_name = "pk"..stage;
		end
	elseif(stage and string.match(stage,"2v2")) then
		rank_name = "pk2v2"
		if(System.options.version == "kids") then
			rank_name = "pk"..stage;
		end
	elseif(stage and stage == "3v3") then
		rank_name = "pk3v3"
	else -- if(stage == "2v2") then
		rank_name = "pk2v2"
	end
	local ranking = self:GetRanking(stage)
	-- score should be at least 1100 in order to submit. 
	-- fixed: just in case the user logs off and there is no score to fetch, the GetRanking will return 1000, we will ignore it in such case. 
	if(ranking and ranking~=1000) then -- ranking>1100
		if(self:CheckRankingItems(stage, true)) then
			local user_nid = self:GetNID();
			RankingServer.SubmitScore(rank_name, user_nid, nil, ranking, function(msg) 
				if(msg and msg.score and msg.score<ranking) then
					-- TODO: A new score on rank is born, shall we inform the client about it?
				end
			end, nil, self:GetPhase());
			if(System.options.version == "teen") then
				RankingServer.SubmitScore(rank_name, user_nid, nil, ranking, function(msg) 
					if(msg and msg.score and msg.score<ranking) then
						-- TODO: A new score on rank is born, shall we inform the client about it?
					end
				end, nil, "all");
			end
		end
	end
end

-- get loot object to change score
-- @param bIsWin: true for winning
function Player:GetRankingLoot(bIsWin)
	if(not self.rankitem_resetting) then
		local count = 0;
		if(bIsWin) then
			count = self.win_ranking_point_count;
		else
			count = self.lose_ranking_point_count;
		end
		if(self.rankitem_serverdata) then
			return {count = count, serverdata = self.rankitem_serverdata};
		else
			return count;
		end
	else
		-- return nil if rankitem is not reset. 
	end
end

-- get base loss weight
function Player:GetBaseLossWeight_kids(stage)
	local ranking = self:GetCheckedRanking(stage);
	if(ranking) then
		if(ranking <= 800) then
			return 0;
		elseif(ranking <= 1000) then
			return 4;
		elseif(ranking <= 1200) then
			return 6;
		elseif(ranking <= 1400) then
			return 8;
		elseif(ranking <= 1600) then
			return 10;
		elseif(ranking <= 1800) then
			return 12;
		elseif(ranking <= 2000) then
			return 15;
		elseif(ranking <= 2200) then
			return 18;
		elseif(ranking <= 3000) then
			return 20;
		else
			return 20;
		end
	end
end

-- get base loss weight
function Player:GetBaseLossWeight_teen(stage)
	local ranking = self:GetCheckedRanking(stage);
	if(ranking) then
		if(ranking <= 800) then
			return 0;
		elseif(ranking <= 1000) then
			return 6;
		elseif(ranking <= 1200) then
			return 10;
		elseif(ranking <= 1400) then
			return 14;
		elseif(ranking <= 1600) then
			return 16;
		elseif(ranking <= 1800) then
			return 18;
		elseif(ranking <= 2000) then
			return 19;
		elseif(ranking <= 2200) then
			return 20;
		elseif(ranking <= 3000) then
			return 20;
		else
			return 20;
		end
	end
end

-- 20046_RedMushroomPvP_1v1_PositiveRankingPoints
-- 20047_RedMushroomPvP_1v1_NegativeRankingPoints
-- get ranking point 1v1
function Player:GetRanking_1v1(stage)
	local ranking = 1000;
	local ranking_positive = 0;
	local ranking_negative = 0;
	local win_point_gsid = 20046;
	if(System.options.version == "kids") then
		win_point_gsid = Arena.GetPVPPointGSID(stage,"win");
	end
	--local bOwn, guid, bag, copies = PowerItemManager.IfOwnGSItem(self:GetNID(), 20046);
	local bOwn, guid, bag, copies = PowerItemManager.IfOwnGSItem(self:GetNID(), win_point_gsid);
	if(copies) then
		ranking_positive = copies;
	end
	local lose_point_gsid = 20047;
	if(System.options.version == "kids") then
		lose_point_gsid = Arena.GetPVPPointGSID(stage,"lose");
	end
	local bOwn, guid, bag, copies = PowerItemManager.IfOwnGSItem(self:GetNID(), lose_point_gsid);
	if(copies) then
		ranking_negative = copies;
	end
	return ranking + ranking_positive - ranking_negative;
end
-- don't require player object
function Player.GetRanking_1v1_from_nid(nid)
	local ranking = 1000;
	local ranking_positive = 0;
	local ranking_negative = 0;
	if(nid) then
		local bOwn, guid, bag, copies = PowerItemManager.IfOwnGSItem(nid, 20046);
		if(copies) then
			ranking_positive = copies;
		end
		local bOwn, guid, bag, copies = PowerItemManager.IfOwnGSItem(nid, 20047);
		if(copies) then
			ranking_negative = copies;
		end
	end
	return ranking + ranking_positive - ranking_negative;
end

-- 20048_RedMushroomPvP_2v2_PositiveRankingPoints
-- 20049_RedMushroomPvP_2v2_NegativeRankingPoints
-- get ranking point 2v2
function Player:GetRanking_2v2(ranking_stage)
	local win_gsid = if_else(System.options.version == "teen",20048,Arena.GetPVPPointGSID(ranking_stage,"win"));
	local lose_gsid = if_else(System.options.version == "teen",20049,Arena.GetPVPPointGSID(ranking_stage,"lose"));
	local ranking = 1000;
	local ranking_positive = 0;
	local ranking_negative = 0;
	local bOwn, guid, bag, copies = PowerItemManager.IfOwnGSItem(self:GetNID(), win_gsid);
	if(copies) then
		ranking_positive = copies;
	end
	local bOwn, guid, bag, copies = PowerItemManager.IfOwnGSItem(self:GetNID(), lose_gsid);
	if(copies) then
		ranking_negative = copies;
	end
	return ranking + ranking_positive - ranking_negative;
end
-- don't require player object
function Player.GetRanking_2v2_from_nid(nid)
	local ranking = 1000;
	local ranking_positive = 0;
	local ranking_negative = 0;
	if(nid) then
		local bOwn, guid, bag, copies = PowerItemManager.IfOwnGSItem(nid, 20048);
		if(copies) then
			ranking_positive = copies;
		end
		local bOwn, guid, bag, copies = PowerItemManager.IfOwnGSItem(nid, 20049);
		if(copies) then
			ranking_negative = copies;
		end
	end
	return ranking + ranking_positive - ranking_negative;
end

function Player:GetRanking_3v3()
	local ranking_score;
	local bOwn, guid, bag, copies = PowerItemManager.IfOwnGSItem(self:GetNID(), 20091);
	if(copies) then
		ranking_score = copies;
	else
		ranking_score = 0;
	end
	return ranking_score;
end

-- get threat id, index into the threat list
-- NOTE: if the unit side is far, the range is still from 1 to 4, 
--		associated with the arena slot id from 5 to 8
-- @return: 1 to 4
function Player:GetThreatID()
	if(not self.threat_id) then
		self.threat_id = math.mod((self.arrow_cast_position - 1), 4) + 1;
	end
	return self.threat_id;
end

-- NOTE: each server data is parsed to a table and reuse every time needed
-- e.x. ServerDataParseMapping[46650264]["{1,2,3,4,5}"] = {1,2,3,4,5};
local ServerDataParseMapping = {};

-- clear the serverdata -> parse table mapping
function Player.ClearServerDataParseMapping(nid)
	ServerDataParseMapping[nid] = nil;
end

-- shuffle the deck structure to a pile of random card sequence
function Player:ShuffleDeck()
	-- clear card sequence
	self.deck_card_sequence = {};
	self.deck_card_mapping = {};
	-- reshuffle each deck card with random weight
	local deck_struct = self.deck_struct;
	local single_cards = {};
	local key, cnt;
	for key, cnt in pairs(deck_struct) do
		local i = 1;
		for i = 1, cnt do
			table.insert(single_cards, {key = key, weight = math.random(1, 999999)});
		end
	end
	local deck_struct_equip = self.deck_struct_equip;
	local key, cnt;
	for key, cnt in pairs(deck_struct_equip) do
		local i = 1;
		for i = 1, cnt do
			table.insert(single_cards, {key = key, weight = math.random(1, 999999)});
		end
	end
	-- sort the card pile with weight
	table.sort(single_cards, function(a, b)
				return (a.weight > b.weight);
			end);
	-- record the sequence
	local _, card;
	for _, card in ipairs(single_cards) do
		table.insert(self.deck_card_sequence, card.key);
		table.insert(self.deck_card_mapping, 0);
	end
end

-- shuffle the follow pet cards to a pile of random card sequence
function Player:ShuffleFollowPetCards()
	-- clear card sequence
	self.deck_followpet_card_sequence = {};
	self.deck_followpet_card_mapping = {};
	-- reshuffle each deck card with random weight
	local deck_struct_pet = self.deck_struct_pet;
	local single_cards = {};
	local key, cnt;
	for key, cnt in pairs(deck_struct_pet) do
		local i = 1;
		for i = 1, cnt do
			table.insert(single_cards, {key = key, weight = math.random(1, 999999)});
		end
	end
	if(System.options.version ~= "teen") then
		-- sort the card pile with weight
		table.sort(single_cards, function(a, b)
					return (a.weight > b.weight);
				end);
	end
	-- record the sequence
	local _, card;
	for _, card in ipairs(single_cards) do
		table.insert(self.deck_followpet_card_sequence, card.key);
		table.insert(self.deck_followpet_card_mapping, 1); -- all cards are ready at start
	end
end

-- prepare card
-- in each advance turn, each user is generated 8 cards at most from the card sequence
function Player:PrepareCard()
	-- pick at most 8 cards from the card sequence for use to pick
	local card_in_hand_count = 0;
	local _, status;
	for _, status in ipairs(self.deck_card_mapping) do
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
				self.deck_card_mapping[_] = 1;
				card_in_hand_count = card_in_hand_count + 1;
			end
		end
		if(card_in_hand_count == 8) then
			break;
		end
	end
end

-- get card keys in hand in order
function Player:GetCardsInHand()
	local cards = {};
	local _, status;
	for _, status in ipairs(self.deck_card_mapping) do
		if(status == 1 or status == -1) then
			table.insert(cards, {
				seq = _,
				key = self.deck_card_sequence[_],
				status = status,
			});
		end
	end
	local cards_followpet = {};
	local _, status;
	for _, status in ipairs(self.deck_followpet_card_mapping) do
		if(status == 1) then
			table.insert(cards_followpet, {
				seq = _,
				key = self.deck_followpet_card_sequence[_],
			});
		end
	end
	return cards, self.deck_struct_rune, cards_followpet;
end

function Player:GetDeckRemainingAndTotalCount()
	
	local remaining_count = 0;
	local total_count = 0;

	local discarded_cards_index = {};
	local _, status;
	for _, status in ipairs(self.deck_card_mapping) do
		if(status == 1) then
			-- 1: avaiable cards at hand, 8 at maximum
			remaining_count = remaining_count + 1;
			total_count = total_count + 1;
		elseif(status == -1) then
			-- -1: discarded cards
			remaining_count = remaining_count + 1;
			total_count = total_count + 1;
		elseif(status == -2) then
			-- -2: used cards
			total_count = total_count + 1;
		elseif(status == -3) then
			-- -3: fizzled cards, NOTE: additional card is already pushed to the tail of card_mapping
		elseif(status == 0) then
			-- 0: un-used cards
			remaining_count = remaining_count + 1;
			total_count = total_count + 1;
		end
	end

	return remaining_count, total_count;
end

-- discard card
-- before each play turn, player has the right to discard the card in his deck to allow new cards coming in hand next round
-- @param card_key: card key
-- @param card_seq: card sequence in deck
-- @return true
function Player:DiscardCard(card_key, card_seq)
	if(not card_key or not card_seq) then
		LOG.std(nil, "error", "combatplayer", "Player:DiscardCard got invalid input:".. commonlib.serialize({card_key, card_seq}));
		return;
	end
	if(self:IfPickedCard()) then
		LOG.std(nil, "error", "combatplayer", "Player:DiscardCard:  one can't discard card while card is picked");
		return;
	end
	if(self.deck_card_sequence[card_seq] == card_key and self.deck_card_mapping[card_seq] == 1) then
		-- marked as discarded
		self.deck_card_mapping[card_seq] = -1;
		-- clear picked card
		self:ClearPickedCard();
		return true;
	end
end

-- restore discarded card
-- before each play turn, player has the right to discard the card in his deck to allow new cards coming in hand next round
-- @param card_key: card key
-- @param card_seq: card sequence in deck
-- @return true
function Player:RestoreDiscardedCard(card_key, card_seq)
	if(not card_key or not card_seq) then
		LOG.std(nil, "error", "combatplayer", "Player:RestoreDiscardedCard got invalid input:".. commonlib.serialize({card_key, card_seq}));
		return;
	end
	if(self:IfPickedCard()) then
		LOG.std(nil, "error", "combatplayer", "Player:RestoreDiscardedCard:  one can't discard card while card is picked");
		return;
	end
	if(self.deck_card_sequence[card_seq] == card_key and self.deck_card_mapping[card_seq] == -1) then
		-- marked as normal card
		self.deck_card_mapping[card_seq] = 1;
		-- clear picked card
		self:ClearPickedCard();
		return true;
	end
end

-- get max remaining switching follow pet count
function Player:GetRemainingSwitchFollowPetCount()
	if(System.options.version == "teen") then
		if(not self.remaing_switching_followpet_count) then
			self.remaing_switching_followpet_count = MAX_SWITCHING_COUNT_FOLLOWPET_TEEN;
		end
		return self.remaing_switching_followpet_count;
	end
	return 100;
end

-- switch to follow pet
-- @param guid: follow pet guid
-- @return: true if switch success
function Player:SwitchToFollowPet(guid)
	if(System.options.version == "teen") then
		if(not self.remaing_switching_followpet_count) then
			self.remaing_switching_followpet_count = MAX_SWITCHING_COUNT_FOLLOWPET_TEEN;
		end
		if(self.remaing_switching_followpet_count <= 0) then
			return false;
		elseif(self.remaing_switching_followpet_count) then
			self.remaing_switching_followpet_count = self.remaing_switching_followpet_count - 1;
		end
	end
	local pet_obj = PowerItemManager.GetItemByGUID(self:GetNID(), guid);
	if(pet_obj and pet_obj.guid > 0 and pet_obj.GetCurLevelCards) then
		-- mark in history
		self.followpet_history[guid] = true;
		-- get pet cards
		local deck_cards_pet_all = {};
		local cards = pet_obj:GetCurLevelCards(true);
		if(cards) then
			local _, gsid
			for _, gsid in pairs(cards) do
				local key = Card.Get_cardkey_from_gsid(gsid);
				if(key) then
					deck_cards_pet_all[key] = (deck_cards_pet_all[key] or 0) + 1;
				else
					key = Card.Get_cardkey_from_rune_gsid(gsid);
					if(key) then
						deck_cards_pet_all[key] = (deck_cards_pet_all[key] or 0) + 1;
					end
				end
			end
		end
		-- modify the follow pet
		self.current_followpet_guid = guid;
		self.deck_struct_pet = deck_cards_pet_all;
		-- reshuffle the pet cards
		self:ShuffleFollowPetCards();

		-- get follow pet combat unit
		local followpet_minion = Player.GetPlayerCombatObj(-self:GetNID());
		if(followpet_minion) then
			followpet_minion.current_followpet_guid = guid;
			-- mark follow pet combat mode history
			self:MarkFollowPetCombatModeHistory(guid);
			-- update stats
			local max_hp_system = followpet_minion:GetUpdatedMaxHP();
			if(max_hp_system) then
				followpet_minion.current_hp = max_hp_system;
				followpet_minion.max_hp = max_hp_system;
			end
			local level_info = pet_obj:GetLevelsInfo(true);
			if(level_info and level_info.cur_level) then
				followpet_minion.petlevel = level_info.cur_level;
			end
			-- school
			local school_short_gsid = pet_obj:GetSchool(true);
			if(school_short_gsid == 6) then
				followpet_minion.phase = "fire";
			elseif(school_short_gsid == 7) then
				followpet_minion.phase = "ice";
			elseif(school_short_gsid == 8) then
				followpet_minion.phase = "storm";
			elseif(school_short_gsid == 9) then
				followpet_minion.phase = "myth";
			elseif(school_short_gsid == 10) then
				followpet_minion.phase = "life";
			elseif(school_short_gsid == 11) then
				followpet_minion.phase = "death";
			elseif(school_short_gsid == 12) then
				followpet_minion.phase = "balance";
			end
			-- get AI cards
			local ai_cards = pet_obj:GetCurLevelAICards();
			--return 实体卡片 cur_entity_cards_list ={ {gsid = gsid, ai_key = ai_key}, {gsid = gsid, ai_key = ai_key}, }
			if(ai_cards) then
				followpet_minion.ai_modules = {};
				local _, each_card;
				for _, each_card in ipairs(ai_cards) do
					-- {gsid = gsid, ai_key = ai_key, count = count}
					local cardkey = Card.Get_cardkey_from_gsid(each_card.gsid);
					local ai_key = each_card.ai_key;
					local count = each_card.count;
					if(not cardkey) then
						cardkey = Card.Get_cardkey_from_rune_gsid(each_card.gsid);
					end
					if(cardkey and ai_key and count) then
						local ai_module = {};
						ai_module.key = cardkey;
						ai_module.action = ai_key;
						ai_module.count_cur = count;
						ai_module.count_total = count;
						table.insert(followpet_minion.ai_modules, ai_module);
					end
				end
			end
			-- clear picked card
			followpet_minion:ClearPickedCard();
		end
		return true, pet_obj.gsid;
	end
	return false;
end

-- try catch follow pet
-- @param mob_obj: mob object
-- @return: true if switch success
function Player:TryCatchPet(mob_obj, base_weight, weight)
	local mob = mob_obj;
	if(mob and mob:IsAlive() and mob.arena_id and mob.arena_id == self.arena_id) then
		if(mob:IsEnraged()) then
			return false;
		end
		local catch_pet_gsid = mob:GetStatByField("catch_pet");
		if(catch_pet_gsid) then
			catch_pet_gsid = tonumber(catch_pet_gsid);
		end
		if(catch_pet_gsid) then
			local level = mob:GetLevel();
			local chance = -1;
			if(System.options.version == "teen") then
				----李宇(李宇) 18:14:24
				----1.1-mlv/100
				--chance = 1.1 - level / 100;
				if(weight == "power" or weight == "super") then
					chance = 10000;
				else
					---- 捕捉成功率=130% / 開根號(1+(怪物等級-1)*0.15) -0.3 + (玩家等級-怪物等級)*0.5%+5%
					--chance = 1.3 / math.sqrt(1+(mob:GetLevel()-1)*0.15) - 0.3 + (self:GetLevel()-mob:GetLevel())*0.005 + 0.05;

					--蒲东宏(Leon) 11:17:03
					--捕捉成功率=Min(1/sqrt(怪物等级)*1.5/剩余血量百分比,100%)
					chance = 1 / math.sqrt(mob:GetLevel()) * 1.5 / (mob:GetCurrentHP() / mob:GetMaxHP());
					
				end
			else
				if(not base_weight) then
					base_weight = 2;
				end
				-- 王瑞(阿水) 11:16:03
				---- (0.5-宠物血量百分比) + (玩家等级 - 宠物等级)/100
				-- 1、保证想抓一个宠物，必须要将宠物的血量减至50%以下
				-- 2、保证抓宠有绝对的代价，等级只是一个补充的作用
				-- 3、对高级宠物的珍惜程度会有绝对的保护作用
				--chance = (0.5 - mob:GetCurrentHP() / mob:GetMaxHP()) + (self:GetLevel() - level) / 100;

				--王瑞(阿水) 15:42:27
				--新公式：2*(1-怪物血量%)+(玩家等级 -怪物等级)/80
				chance = base_weight * (1 - mob:GetCurrentHP() / mob:GetMaxHP()) + (self:GetLevel() - level) / 80;
			end

			local chance_multi_1000 = chance * 1000;

			local catch_pet_force_chance_percent = mob:GetStatByField("catch_pet_force_chance_percent");
			if(catch_pet_force_chance_percent) then
				catch_pet_force_chance_percent = tonumber(catch_pet_force_chance_percent);
				chance_multi_1000 = catch_pet_force_chance_percent * 10;
				if(System.options.version == "teen") then
					if(weight == "power" or weight == "super") then
						chance = 10000;
						chance_multi_1000 = 10000;
					end
				end
			end

			--if(System.options.version == "teen") then
				--if(level < 5) then
					--chance_multi_1000 = 10000; -- low level pets are 100% catchable
				--end
			--end
			
			---- NOTE: TEST catch pet chance
			--local arena_id = self.arena_id;
			--if(arena_id) then
				--local arena = Arena.GetArenaByID(arena_id)
				--if(arena) then
					--combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, self:GetNID(), "ClientMSG:CatchPetChance_"..tostring(chance_multi_1000 / 10));
				--end
			--end

			local r = math.random(0, 1000);
			if(r <= chance_multi_1000) then
				-- check if own the pet
				local bOwn, guid = PowerItemManager.IfOwnGSItem(self:GetNID(), catch_pet_gsid);
				if(not bOwn) then
					mob.nid_catchpet = self:GetNID();
					return true;
				end
			end
		end
	end
	return false;
end

-- try enrage pet
-- @param mob_obj: mob object
-- @return: true if enrage success
function Player:TryEnrage(mob_obj)
	local mob = mob_obj;
	if(mob and mob:IsAlive() and mob.arena_id and mob.arena_id == self.arena_id) then
		if(mob:CanBeEnraged() and not mob:IsEnraged()) then
			return mob:EnrageBy(self);
		end
	end
	return false;
end

-- return the used card history 
function Player:GetCardHistory()
	return self.card_history;
end

-- mark follow pet combat mode history
function Player:MarkFollowPetCombatModeHistory(guid)
	if(guid) then
		self.followpet_combatmode_history[guid] = true;
	end
end

-- mark follow pet combat mode history
function Player:IsFollowPetCombatModeInHistory(guid)
	if(guid and self.followpet_combatmode_history[guid]) then
		return true;
	end
	return false;
end

-- get player object
function Player.GetPlayerCombatObj(nid)
	return players[nid];
end

-- destroy player object
function Player.DestroyPlayer(nid)
	players[nid] = nil;
end

-- get normal update value, including:
--		hp, max_hp, pips, power_pips, charms, shields, dots
function Player:GetValue_normal_update()
	local value = "";
	value = format("%s,%s,%d,%s,%d,%d,%d,%d,%d,%d#%s#%s#%s#%s", 
		tostring(self:IsMob()),
		tostring(self:GetNID()),
		self:GetArrowPosition_id(),
		self:GetPhase(), 
		self:GetFollowPetGSID(), 
		self:GetCurrentHP(), 
		self:GetMaxHP(), 
		self:GetPetLevel(),
		self:GetPipsCount(), 
		self:GetPowerPipsCount(),
		self:GetCharmsValue(),
		self:GetWardsValue(),
		self:GetMiniAuraValue(),
		self:GetOverTimeValue()
	);
	return value;
end

-- get player id, (nid)
function Player:GetID()
	return self:GetNID();
end

-- get is mob
function Player:IsMob()
	return false;
end

-- get is minion
function Player:IsMinion()
	if(self.is_minion) then
		return true;
	end
	return false;
end

-- get master player nid
function Player:GetMasterPlayerNID()
	return 0;
end

local minionTemplates = {};
function Player.CreateGetMinionTemplate(key)
	if(key) then
		if(minionTemplates[key]) then
			return minionTemplates[key];
		end
		local sequence_explicit_rounds = {};
		local sequence_formula_rounds = {};
		local xmlRoot = ParaXML.LuaXML_ParseFile(key);
		if(xmlRoot) then
			local each_round;
			for each_round in commonlib.XPath.eachNode(xmlRoot, "/miniontemplate/sequence/round") do
				if(each_round and each_round.attr) then
					local round = each_round.attr.round;
					local card = each_round.attr.card;
					local target = each_round.attr.target;
					local speak = each_round.attr.speak;
					if(speak) then
						speak = Mob.GetTransWordFromOriginalWord(key, speak) or speak;
					end
					if(round and card and target) then
						if(tonumber(round)) then
							-- explicit round
							round = tonumber(round);
							sequence_explicit_rounds[round] = {
								card = card,
								target = target,
								speak = speak,
							};
						else
							-- formula round
							sequence_formula_rounds[round] = {
								card = card,
								target = target,
								speak = speak,
							};
						end
					end
				end
			end
		end
		-- new template
		local template = {
			key = key,
			sequence_explicit_rounds = sequence_explicit_rounds,
			sequence_formula_rounds = sequence_formula_rounds,
		};
		minionTemplates[key] = template;
		return template;
	end
end
function Player.GetMinionTemplate(key)
	if(key) then
		return minionTemplates[key];
	end
end

function Player.GetCardFromAction(caster, key, type)
	if(caster and key and type) then
		local side = caster:GetSide();
		-- get arena
		local arena_id = caster.arena_id;
		if(arena_id) then
			local arena = Arena.GetArenaByID(arena_id)
			if(arena) then
				-- get caster friendly and hostile units
				local friendlys, hostiles = arena:GetFriendlyAndHostileUnits(side);
				-- choose card key for each ai type
				if(type == "breakshield_attack") then
					-- get card and target from action breakshield_attack
					-- 给策划提示  对方有盾就出的牌 破盾  breakshield_attack
					local card_template = Card.GetCardTemplate(key);
					if(card_template) then
						local damage_school = card_template.params.damage_school;
						if(damage_school) then
							-- get unit with shield
							local _, unit;
							for _, unit in ipairs(hostiles) do
								local unit = Arena.GetCombatUnit(unit.isMob, unit.id)
								if(unit and unit:IsAlive()) then
									if(unit:IfHasShield(damage_school)) then
										return key, unit:IsMob(), unit:GetID();
									end
								end
							end
						end
					end
				elseif(type == "generic_shield") then
					-- get card and target from action generic_shield
					-- 给策划提示  通用防御 当对方魔力点达到6的时候出的盾 优先主人 然后自己 generic_shield
					local _, unit;
					for _, unit in ipairs(hostiles) do
						local unit = Arena.GetCombatUnit(unit.isMob, unit.id)
						if(unit and unit:IsAlive()) then
							local unit_pip_count = unit:GetPipsCount() + unit:GetPowerPipsCount() * 2;
							if(unit_pip_count >= 6) then
								if(caster:IsMinion()) then
									local player = Player.GetPlayerCombatObj(-caster:GetID());
									if(player and player:IsAlive()) then
										if(not player:IfHasShield(unit:GetPhase())) then
											return key, false, -caster:GetID();
										end
										if(not caster:IfHasShield(unit:GetPhase())) then
											return key, false, caster:GetID();
										end
										return key, false, -caster:GetID();
									else
										return key, false, caster:GetID();
									end
								else
									return key, caster:IsMob(), caster:GetID();
								end
							end
						end
					end
				elseif(type == "heavy_attack") then
					-- get card and target from action heavy_attack
					-- 给策划提示  魔力点足够时出的牌 优先无盾的目标 其次主人仇恨高的目标 heavy_attack
					local card_template = Card.GetCardTemplate(key);
					if(card_template) then
						local damage_school = card_template.params.damage_school;
						if(damage_school) then
							-- get unit with shield
							local _, unit;
							for _, unit in ipairs(hostiles) do
								local unit = Arena.GetCombatUnit(unit.isMob, unit.id)
								if(unit and unit:IsAlive()) then
									if(not unit:IfHasShield(damage_school)) then
										return key, unit:IsMob(), unit:GetID();
									end
								end
							end
							if(caster:IsMinion()) then
								local highest_mob_threat = 0;
								local highest_mob_ismob = nil;
								local highest_mob_id = nil;
								local master_threat_id = nil;
								local player = Player.GetPlayerCombatObj(-caster:GetNID());
								if(player and player:IsAlive()) then
									master_threat_id = player:GetThreatID();
								end
								local _, unit;
								for _, unit in ipairs(hostiles) do
									local unit = Arena.GetCombatUnit(unit.isMob, unit.id)
									if(unit and unit:IsAlive() and unit:IsMob()) then
										local master_threat = unit:GetThreatFromThreatID(master_threat_id);
										if(master_threat >= highest_mob_threat) then
											highest_mob_threat = master_threat;
											highest_mob_ismob = unit:IsMob();
											highest_mob_id = unit:GetID();
										end
									end
								end
								if(highest_mob_ismob ~= nil and highest_mob_id ~= nil) then
									return key, highest_mob_ismob, highest_mob_id;
								end
							end
							local _, unit;
							for _, unit in ipairs(hostiles) do
								local unit = Arena.GetCombatUnit(unit.isMob, unit.id)
								if(unit and unit:IsAlive()) then
									return key, unit:IsMob(), unit:GetID();
								end
							end
						end
					end
				elseif(type == "generic_debuff") then
					-- get card and target from action generic_debuff
					-- 给策划提示  通用debuff 优先主人仇恨高的怪 generic_debuff
					local card_template = Card.GetCardTemplate(key);
					if(card_template) then
						if(caster:IsMinion()) then
							local highest_mob_threat = 0;
							local highest_mob_ismob = nil;
							local highest_mob_id = nil;
							local master_threat_id = nil;
							local player = Player.GetPlayerCombatObj(-caster:GetNID());
							if(player and player:IsAlive()) then
								master_threat_id = player:GetThreatID();
							end
							local _, unit;
							for _, unit in ipairs(hostiles) do
								local unit = Arena.GetCombatUnit(unit.isMob, unit.id)
								if(unit and unit:IsAlive() and unit:IsMob()) then
									local master_threat = unit:GetThreatFromThreatID(master_threat_id);
									if(master_threat >= highest_mob_threat) then
										highest_mob_threat = master_threat;
										highest_mob_ismob = unit:IsMob();
										highest_mob_id = unit:GetID();
									end
								end
							end
							if(highest_mob_ismob ~= nil and highest_mob_id ~= nil) then
								return key, highest_mob_ismob, highest_mob_id;
							end
						end
						local _, unit;
						for _, unit in ipairs(hostiles) do
							local unit = Arena.GetCombatUnit(unit.isMob, unit.id)
							if(unit and unit:IsAlive()) then
								return key, unit:IsMob(), unit:GetID();
							end
						end
					end
				elseif(type == "generic_buff") then
					-- get card and target from action generic_buff
					-- 给策划提示  通用buff 随机主人和自己 generic_buff
					if(caster:IsMinion()) then
						local r = math.random(0, 1000);
						if(r <= 700) then
							return key, false, -caster:GetID();
						else
							return key, false, caster:GetID();
						end
					else
						return key, caster:IsMob(), caster:GetID();
					end
				elseif(type == "school_buff") then
					-- get card and target from action school_buff
					-- 给策划提示  系别buff 给卡牌系别相符的主人加 系别不符加给自己 school_buff
					local card_template = Card.GetCardTemplate(key);
					if(card_template) then
						if(caster:IsMinion()) then
							local player = Player.GetPlayerCombatObj(-caster:GetNID());
							if(player and player:IsAlive()) then
								if(card_template.spell_school == player:GetPhase()) then
									return key, false, -caster:GetID();
								end
							end
						end
					end
					return key, caster:IsMob(), caster:GetID();
				end
			end
		end
		return "Pass", 0, caster:IsMob(), caster:GetID();
	end
end

-- pick minion card
function Player:PickMinionCard()

	if(self:GetNID() < 0) then
		
		-- item:GetCurLevelAICards
		--名字 function Item_FollowPet:GetName_client()
		--系别 function Item_FollowPet:GetSchool(isServer)

		-- reset ai_module index
		self.ai_module_index = nil;

		-- follow pet minion
		local arena_id = self.arena_id;
		if(arena_id) then
			local arena = Arena.GetArenaByID(arena_id)
			if(arena) then
				local ai_modules = self.ai_modules or {}
				local candidates = {};
				local _, ai_module;
				for _, ai_module in ipairs(ai_modules) do
					local action = ai_module.action;
					local key = ai_module.key;
					local target_ismob, target_id;
					if(self:CanCastSpell(key, true) and ai_module.count_cur and ai_module.count_cur > 0) then
						if(action == "breakshield_attack") then
							key, target_ismob, target_id = Player.GetCardFromAction(self, key, "breakshield_attack");
						elseif(action == "generic_shield") then
							key, target_ismob, target_id = Player.GetCardFromAction(self, key, "generic_shield");
						elseif(action == "heavy_attack") then
							key, target_ismob, target_id = Player.GetCardFromAction(self, key, "heavy_attack");
						elseif(action == "generic_debuff") then
							key, target_ismob, target_id = Player.GetCardFromAction(self, key, "generic_debuff");
						elseif(action == "generic_buff") then
							key, target_ismob, target_id = Player.GetCardFromAction(self, key, "generic_buff");
						elseif(action == "school_buff") then
							key, target_ismob, target_id = Player.GetCardFromAction(self, key, "school_buff");
						end
						if(key and target_ismob ~= nil and target_id) then
							ai_module.count_cur = ai_module.count_cur - 1;
							self.ai_module_index = _;
							-- normal card
							self:PickCard(key, 0, target_ismob, target_id);
							return key, 0, target_ismob, target_id;
						end
					end
				end
			end
		end

		self:PickCard("Pass", 0, false, self:GetID());
		return "Pass", 0, false, self:GetID();
	end

	local function GetTargetFromMinionRoundTarget(target)
		local arena_id = self.arena_id;
		if(arena_id) then
			local arena = Arena.GetArenaByID(arena_id)
			if(arena) then
				if(target) then
					target_number = tonumber(target);
					if(target_number) then
						return arena:GetCombatUnitBySlotID(target_number);
					else
						local each_target;
						for each_target in string.gmatch(target, "([%d]+)") do
							each_target = tonumber(each_target);
							if(each_target) then
								local unit = arena:GetCombatUnitBySlotID(each_target);
								if(unit) then
									return unit;
								end
							end
						end
					end
				end
			end
		end
	end

	local arena_id = self.arena_id;
	if(arena_id) then
		local arena = Arena.GetArenaByID(arena_id)
		if(arena) then
			local nExecutedRounds = arena:GetRoundTag() or 1;
			nExecutedRounds = nExecutedRounds + 1;
			if(self.nid == 27001) then
				-- 27001_Kafuka
				local remaining = math.mod(nExecutedRounds, 4);
				if(remaining == 0 or remaining == 3) then
					local id;
					for _, id in ipairs(arena.mob_ids) do
						local mob = Mob.GetMobByID(id);
						if(mob and mob:IsAlive() and (mob:GetArrowPosition_id() == 6 or mob:GetArrowPosition_id() == 7)) then
							-- get second or third mob
							if(remaining == 0) then
								self:PickCard("Storm_Rune_SingleAttack_Kafuka", 0, true, id);
								return "Storm_Rune_SingleAttack_Kafuka", 0, true, id;
							elseif(remaining == 3) then
								self:PickCard("Storm_StormDamageTrap_Blue", 0, true, id);
								return "Storm_StormDamageTrap_Blue", 0, true, id;
							end
							return;
						end
					end
					local id;
					for _, id in ipairs(arena.mob_ids) do
						local mob = Mob.GetMobByID(id);
						if(mob and mob:IsAlive() and (mob:GetArrowPosition_id() == 5 or mob:GetArrowPosition_id() == 8)) then
							-- get first or fourth mob
							if(remaining == 0) then
								self:PickCard("Storm_Rune_SingleAttack_Kafuka", 0, true, id);
								return "Storm_Rune_SingleAttack_Kafuka", 0, true, id;
							elseif(remaining == 3) then
								self:PickCard("Storm_StormDamageTrap_Blue", 0, true, id);
								return "Storm_StormDamageTrap_Blue", 0, true, id;
							end
							return;
						end
					end
				elseif(remaining == 1) then
					self:PickCard("Balance_GlobalShield_Blue", 0, false, self:GetID());
					return "Balance_GlobalShield_Blue", 0, false, self:GetID();
				elseif(remaining == 2) then
					self:PickCard("Storm_StormDamageBlade_Blue", 0, false, self:GetID());
					return "Storm_StormDamageBlade_Blue", 0, false, self:GetID();
				end
			elseif(self.nid == 27002) then
				-- 27002
				local minion_key = self.minion_key;
				if(minion_key) then
					local template = Player.GetMinionTemplate(minion_key);
					if(template) then
						local rounds = template.sequence_explicit_rounds;
						if(rounds) then
							local round = rounds[nExecutedRounds];
							if(round) then
								local target = GetTargetFromMinionRoundTarget(round.target)
								if(target) then
									self:PickCard(round.card, 0, target:IsMob(), target:GetID(), nil, round.speak);
									return round.card, 0, target:IsMob(), target:GetID();
								end
							end
						end
					end
				end
				if(true) then
					--随机卡包
					--（23421，30）（23422,20）（23423,30）（22124,50）（22130,50）（22333,30）（42135,20）（42142,30）
					--Storm_Rune_SingleAttack_KaiEn
					--Balance_Rune_AreaDamageBlade_KaiEn
					--Storm_Rune_BoostDodgeChance
					--Storm_StormDamageTrap
					--Storm_StormDamageBlade
					--Storm_StormDamageTrap_Standing
					--Storm_SingleAttack_Level6_Blue
					--Balance_GlobalShield_Blue

					local nonzero_cost_cardkey = {
						"Storm_Rune_SingleAttack_KaiEn",
						"Balance_Rune_AreaDamageBlade_KaiEn",
						"Storm_Rune_BoostDodgeChance",
						"Storm_StormDamageTrap_Standing",
						"Storm_SingleAttack_Level6_Blue",
					};
					local zero_cost_cardkey = {
						"Storm_StormDamageTrap",
						"Storm_StormDamageBlade",
						"Balance_GlobalShield_Blue",
					};

					local random_nonzero_cost_cardkey = nonzero_cost_cardkey[math.random(#nonzero_cost_cardkey)];
					local random_zero_cost_cardkey = zero_cost_cardkey[math.random(#zero_cost_cardkey)];

					if(random_nonzero_cost_cardkey) then
						if(self:CanCastSpell(random_nonzero_cost_cardkey, true)) then
							if(random_nonzero_cost_cardkey == "Storm_Rune_BoostDodgeChance"
								or random_nonzero_cost_cardkey == "Balance_Rune_AreaDamageBlade_KaiEn") then
								self:PickCard(random_nonzero_cost_cardkey, 0, false, self:GetID());
								return random_nonzero_cost_cardkey, 0, false, self:GetID();
							else
								local target = GetTargetFromMinionRoundTarget("6,5,7,8");
								if(target) then
									self:PickCard(random_nonzero_cost_cardkey, 0, target:IsMob(), target:GetID());
									return random_nonzero_cost_cardkey, 0, target:IsMob(), target:GetID();
								end
							end
						end
					end
					if(random_zero_cost_cardkey) then
						if(self:CanCastSpell(random_zero_cost_cardkey, true)) then
							if(random_zero_cost_cardkey == "Storm_StormDamageTrap") then
								local target = GetTargetFromMinionRoundTarget("6,5,7,8");
								if(target) then
									self:PickCard(random_zero_cost_cardkey, 0, target:IsMob(), target:GetID());
									return random_zero_cost_cardkey, 0, target:IsMob(), target:GetID();
								end
							else
								self:PickCard(random_zero_cost_cardkey, 0, false, self:GetID());
								return random_zero_cost_cardkey, 0, false, self:GetID();
							end
						end
					end
				end
			end
			--Balance_Rune_AreaDamageBlade_KaiEn
		end
	end
	self:PickCard("Pass", 0, false, self:GetID());
	return "Pass", 0, false, self:GetID();
end

-- get player nid
function Player:GetNID()
	return self.nid;
end

-- get arrow position id on the arena 1 to 8
function Player:GetArrowPosition_id()
	return self.arrow_cast_position;
end

-- get player phase
function Player:GetPhase()
	return self.phase;
end

-- get current follow pet gsid
function Player:GetFollowPetGSID()
	local followpet_guid = self.current_followpet_guid;
	if(followpet_guid and followpet_guid > 0) then
		local pet_obj = PowerItemManager.GetItemByGUID(self:GetID(), followpet_guid);
		if(pet_obj and pet_obj.guid > 0 and pet_obj.GetCurLevelProps) then
			return pet_obj.gsid;
		end
	end
	return 0;
end

-- get current player hp point
function Player:GetCurrentHP()
	return self.current_hp;
end

-- get pet level
function Player:GetLevel()
	return self.petlevel;
end

-- get pet level
function Player:GetPetLevel()
	return self.petlevel;
end

-- get max player hp point
function Player:GetMaxHP()
	local arena_id = self.arena_id;
	if(arena_id) then
		local arena = Arena.GetArenaByID(arena_id)
		if(arena) then
			local key = "max_hp_"..string.lower(self:GetPhase());
			if(arena[key]) then
				self.max_hp = arena[key];
				if(self.current_hp >= self.max_hp) then
					self.current_hp = self.max_hp;
				end
				return arena[key];
			end
		end
	end

	return self.max_hp;
end

-- get updated max hp from user items
function Player:GetUpdatedMaxHP()
	
	-- update the hp by school and level
	local hp = 400;
	local school = self:GetPhase();
	local level = self:GetLevel();
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
		local school = self:GetPhase();
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
		hp = math.ceil(hp + hp * 3.14 * self:GetStatsSum({242}) / 100);
	
	elseif(System.options.version == "teen") then
		-- 242 add_maximum_hp_percent(CG) 增加用户HP基础上限百分比(青年版用这个) 
		hp = math.ceil(hp * (100 + self:GetStatsSum({242})) / 100);
	end

	-- vip bonus
	if(System.options.version == "kids") then
		local nid = self:GetID();
		if(PowerItemManager.IsVIP(nid)) then
			local m_level = PowerItemManager.GetMagicStarLevel(nid);
			local bonus = vip_bonus_hp[m_level + 1] or 0;
			hp = math.ceil(hp * (100 + bonus) / 100);
		end
	end

	if((tonumber(self:GetNID()) or 0) < 0) then
		hp = 0;
	end

	hp = hp + self:GetStatsSum({101});

	return hp;
end

-- get current pips count
function Player:GetPipsCount()
	return self.pips_normal;
end

-- get current power pips count
function Player:GetPowerPipsCount()
	return self.pips_power;
end

-- 184 initial_normal_pips_count(CG) 战斗初始pips数  
-- 185 initial_power_pips_count(CG) 战斗初始powerpips数  
-- set startup pips
function Player:SetStartupPips()
	self.pips_normal = self:GetStatsSum({184});
	self.pips_power = self:GetStatsSum({185});
	if(System.options.version == "teen") then
		self.pips_normal = self.pips_power * 2 + self.pips_normal;
		self.pips_power = 0;
		----NOTE: set startup pips full
		--self.pips_normal = 14;
		----NOTE: set startup pips 0
		--self.pips_normal = 2;
	end
	if(self.pips_normal >= maximum_player_pips_count) then
		self.pips_normal = maximum_player_pips_count;
	end
	if(self.pips_normal <= 0) then
		self.pips_normal = 0;
	end
	if(self.pips_power >= maximum_player_pips_count) then
		self.pips_power = maximum_player_pips_count;
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
function Player:CanCastSpell(spell_key, bFollowPetCard)
	if(self:GetCoolDown(spell_key) > 0) then
		return false;
	end
	local card_template = Card.GetCardTemplate(spell_key);
	if(card_template) then
		-- 2020.4.27: 梦龙极光 在儿童版的PVP模式下无法使用
		if(card_template.key == "Balance_Rune_SingleAttack_Dragon" and System.options.version == "kids") then
			if(self.arena_id) then
				local arena = Arena.GetArenaByID(self.arena_id)
				if(arena and arena.mode == "free_pvp") then
					return false;
				end
			end
		end

		if(card_template.require_level and card_template.require_level > self:GetPetLevel()) then
			if(bFollowPetCard and System.options.version == "teen") then
				-- always pass follow pet card require level test
			else
				return false;
			end
		end
		if(card_template.spell_school == self:GetPhase()) then
			-- own school spell
			if(card_template.pipcost <= (self.pips_normal + self.pips_power * 2)) then
				return true;
			end
		else
			if(card_template.type == "Stance") then
				if(self:GetPhase() ~= card_template.spell_school and card_template.spell_school ~= "balance") then
					return false;
				end
			end
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
		LOG.std(nil, "error", "combatplayer", "unknown card template with spell_key:".. spell_key);
	end
	return false;
end

-- get remaining cooldown rounds
-- @return: cooldown round, if not in cooldown return 0
function Player:GetCoolDown(spell_key)
	if(self.cooldown_record[spell_key]) then
		return self.cooldown_record[spell_key];
	end
	return 0;
end

-- validate cool down rounds
function Player:ValidateCoolDown()
	local key, cd;
	for key, cd in pairs(self.cooldown_record) do
		if(cd > 0) then
			self.cooldown_record[key] = cd - 1;
		end
	end
end

-- validate discarded cards
function Player:ValidateDiscardedCards()
	local discarded_cards_index = {};
	local _, status;
	for _, status in ipairs(self.deck_card_mapping) do
		if(status == -1) then
			table.insert(discarded_cards_index, _);
		end
	end
	
	local _, index;
	for _, index in ipairs(discarded_cards_index) do
		-- -2 stands for used cards
		self.deck_card_mapping[index] = -2;
	end
end

-- generate pip for each round
-- @params bForcePowerPip: force generate powerpip
function Player:GeneratePip(bForcePowerPip, bForceNormalPip)
	local r = math.random(1, 100);
	if(not bForceNormalPip and (bForcePowerPip or r <= self:GetPowerPipChance())) then
		-- this is a power pip
		if(System.options.version == "teen") then
			self.pips_normal = self.pips_normal + 2;
			if((self.pips_normal + self.pips_power) > maximum_player_pips_count) then
				self.pips_normal = maximum_player_pips_count - self.pips_power;
			end
		else
			self.pips_power = self.pips_power + 1;
			if((self.pips_normal + self.pips_power) > maximum_player_pips_count) then
				self.pips_power = maximum_player_pips_count - self.pips_normal;
			end
		end
	else
		-- this is a normal pip
		self.pips_normal = self.pips_normal + 1;
		if((self.pips_normal + self.pips_power) > maximum_player_pips_count) then
			self.pips_normal = maximum_player_pips_count - self.pips_power;
		end
	end
end

-- cost pips
-- @param pip_count: pip count
-- @param school: spell school
-- @return: the real cost pips, this is useful when costing X pips
function Player:CostPips(pip_count, school)
	local realcost = 0;
	if(pip_count < 0) then
		-- this is an x pip cost, cost as much as possible
		pip_count = -pip_count;
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
function Player:ResetPips()
	self.pips_normal = 0;
	self.pips_power = 0;
end

-- get bonus hp from equips
-- @return: hp pts
function Player:GetHPBonus()
	-- 101 add_maximum_hp(CG)
	return self:GetStatsSum({101});
end

-- get power pip chance
-- @return: 10 means 10% power pip chance
function Player:GetPowerPipChance()
	local powerpip_bonus = 0;
	local is_force_powerpipchance = false;
	local stat_force_powerpipchance = nil;
	local arena_id = self.arena_id;
	if(arena_id) then
		local arena = Arena.GetArenaByID(arena_id)
		if(arena) then
			if(arena.force_powerpipchance) then
				is_force_powerpipchance = true;
				stat_force_powerpipchance = arena.force_powerpipchance;
			end
			-- balance global aura bonus 
			local GlobalAura, GlobalAura_boost_damage, GlobalAura_boost_school, GlobalAura_boost_heal, GlobalAura_boost_powerpip, GlobalAura_icon_gsid = arena:GetAura();
			if(GlobalAura_boost_powerpip) then
				powerpip_bonus = GlobalAura_boost_powerpip;
			end
		end
	end
	
	-- update the power pip chance by level
	local nid = self:GetID();
	local level = 1;
	local userdragoninfo = PowerItemManager.GetUserAndDragonInfoInMemory(nid);
	if(userdragoninfo and userdragoninfo.dragon.combatlel) then
		level = userdragoninfo.dragon.combatlel;
	else
		level = self.petlevel;
	end
	local chance_level = 0;
	if(level < 10) then
		chance_level = 0;
	else
		chance_level = math_floor((40 - 10) * (level - 10) / 40 + 10);
	end

	if(System.options.version == "teen") then
		chance_level = level / 2;
	end

	if(not is_force_powerpipchance) then
		powerpip_bonus = powerpip_bonus + chance_level;
	end

	-- get stats from mini aura
	if(self.miniaura and self.miniaura_rounds and self.miniaura_rounds > 0) then
		local miniaura_template = Card.GetMiniAuraTemplate(self.miniaura);
		if(miniaura_template) then
			powerpip_bonus = powerpip_bonus + (miniaura_template.stats[102] or 0);
		end
	end

	if(is_force_powerpipchance) then
		return self:GetStatsSum({102}, true) + stat_force_powerpipchance + powerpip_bonus;
	else
		-- 102 add_power_pip_percent(CG)
		return self:GetStatsSum({102}) + powerpip_bonus;
	end
end

-- get accuracy boost
-- @param school: fire ice etc.
-- @return: 10 means 10% accuracy boost
function Player:GetAccuracyBoost(school)
	local arena_id = self.arena_id;
	if(arena_id) then
		local arena = Arena.GetArenaByID(arena_id)
		if(arena) then
			if(arena.force_accuracyboost) then
				return arena.force_accuracyboost;
			end
		end
	end
	--103 add_accuracy_overall_percent(CG)
	--104 add_accuracy_fire_percent(CG)
	--105 add_accuracy_ice_percent(CG)
	--106 add_accuracy_storm_percent(CG)
	--107 add_accuracy_myth_percent(CG)
	--108 add_accuracy_life_percent(CG)
	--109 add_accuracy_death_percent(CG)
	--110 add_accuracy_balance_percent(CG)
	local stats_ids = {};
	table.insert(stats_ids, 103);
	local school_lower = string.lower(school);
	if(school_lower == "fire") then
		table.insert(stats_ids, 104);
	elseif(school_lower == "ice") then
		table.insert(stats_ids, 105);
	elseif(school_lower == "storm") then
		table.insert(stats_ids, 106);
	elseif(school_lower == "myth") then
		table.insert(stats_ids, 107);
	elseif(school_lower == "life") then
		table.insert(stats_ids, 108);
	elseif(school_lower == "death") then
		table.insert(stats_ids, 109);
	elseif(school_lower == "balance") then
		table.insert(stats_ids, 110);
	end
	-- vip bonus
	local stat = self:GetStatsSum(stats_ids);
	if(PowerItemManager.IsVIPAndActivated(self:GetID())) then
		local m_level = PowerItemManager.GetMagicStarLevel(self:GetID());
		stat = stat + (vip_bonus_accuracy[m_level + 1] or 0);
	end
	
	-- get stats from mini aura
	if(self.miniaura and self.miniaura_rounds and self.miniaura_rounds > 0) then
		local miniaura_template = Card.GetMiniAuraTemplate(self.miniaura);
		if(miniaura_template) then
			local _, stat_type;
			for _, stat_type in ipairs(stats_ids) do
				stat = stat + (miniaura_template.stats[stat_type] or 0);
			end
		end
	end

	return stat;
end

-- get damage boost
-- @param school: fire ice etc.
-- @return: 10 means 10% damage boost
function Player:GetDamageBoost(school)
	local arena_id = self.arena_id;
	if(arena_id) then
		local arena = Arena.GetArenaByID(arena_id)
		if(arena) then
			if(arena.force_damageboost) then
				return arena.force_damageboost;
			end
		end
	end
	--111 add_damage_overall_percent(CG)
	--112 add_damage_fire_percent(CG)
	--113 add_damage_ice_percent(CG)
	--114 add_damage_storm_percent(CG)
	--115 add_damage_myth_percent(CG)
	--116 add_damage_life_percent(CG)
	--117 add_damage_death_percent(CG)
	--118 add_damage_balance_percent(CG)
	local stats_ids = {};
	table.insert(stats_ids, 111);
	local school_lower = string.lower(school);
	if(school_lower == "fire") then
		table.insert(stats_ids, 112);
	elseif(school_lower == "ice") then
		table.insert(stats_ids, 113);
	elseif(school_lower == "storm") then
		table.insert(stats_ids, 114);
	elseif(school_lower == "myth") then
		table.insert(stats_ids, 115);
	elseif(school_lower == "life") then
		table.insert(stats_ids, 116);
	elseif(school_lower == "death") then
		table.insert(stats_ids, 117);
	elseif(school_lower == "balance") then
		table.insert(stats_ids, 118);
	end
	-- vip bonus
	local stat = self:GetStatsSum(stats_ids);
	if(PowerItemManager.IsVIPAndActivated(self:GetID())) then
		local m_level = PowerItemManager.GetMagicStarLevel(self:GetID());
		stat = stat + (vip_bonus_damage[m_level + 1] or 0);
	end
	-- pvp arena damage boost according to remaining rounds
	-- every 6% per full round
	local arena_id = self.arena_id;
	if(arena_id) then
		local arena = Arena.GetArenaByID(arena_id)
		if(arena and arena.mode == "pve") then
			stat = stat + arena:GetArenaDamageBoost();
		elseif(arena and arena.mode == "free_pvp") then
			stat = stat + arena:GetArenaDamageBoost();
		end
	end

	if(self.remaining_round_weakbuff_base and self.remaining_round_weakbuff_delta) then
		local arena_id = self.arena_id;
		if(arena_id) then
			local arena = Arena.GetArenaByID(arena_id)
			if(arena and arena.mode == "free_pvp") then
				if(arena.nRemainingRounds and arena.nRemainingRounds > 0) then
					-- NOTE: minor half round fix for far side players
					local weakbuff_bonus = self.remaining_round_weakbuff_base + self.remaining_round_weakbuff_delta * math_floor((MAX_ROUNDS_PVP_ARENA - arena.nRemainingRounds - 1) / 2)
					if(weakbuff_bonus > 0) then
						stat = stat + weakbuff_bonus;
					end
				end
			end
		end
	end

	return stat;
end

-- get damage boost absolute
-- @param school: fire ice etc.
-- @return: 10 means 10 damage boost absolute
function Player:GetDamageBoost_absolute(school)
	local arena_id = self.arena_id;
	if(arena_id) then
		local arena = Arena.GetArenaByID(arena_id)
		if(arena) then
			if(arena.force_damageboost_absolute) then
				return arena.force_damageboost_absolute;
			end
		end
	end
	--151 add_damage_overall_absolute(CG)
	--152 add_damage_fire_absolute(CG)
	--153 add_damage_ice_absolute(CG)
	--154 add_damage_storm_absolute(CG)
	--155 add_damage_myth_absolute(CG)
	--156 add_damage_life_absolute(CG)
	--157 add_damage_death_absolute(CG)
	--158 add_damage_balance_absolute(CG)  
	local stats_ids = {};
	table.insert(stats_ids, 151);
	local school_lower = string.lower(school);
	if(school_lower == "fire") then
		table.insert(stats_ids, 152);
	elseif(school_lower == "ice") then
		table.insert(stats_ids, 153);
	elseif(school_lower == "storm") then
		table.insert(stats_ids, 154);
	elseif(school_lower == "myth") then
		table.insert(stats_ids, 155);
	elseif(school_lower == "life") then
		table.insert(stats_ids, 156);
	elseif(school_lower == "death") then
		table.insert(stats_ids, 157);
	elseif(school_lower == "balance") then
		table.insert(stats_ids, 158);
	end
	local stat = self:GetStatsSum(stats_ids);
	-- vip bonus
	--if(PowerItemManager.IsVIPAndActivated(self:GetID())) then
		--local m_level = PowerItemManager.GetMagicStarLevel(self:GetID());
		--stat = stat + (vip_bonus_damage[m_level + 1] or 0);
	--end
	---- pvp arena damage boost according to remaining rounds
	---- every 1% per full round
	--local arena_id = self.arena_id;
	--if(arena_id) then
		--local arena = Arena.GetArenaByID(arena_id)
		--if(arena and arena.mode == "free_pvp") then
			--if(arena.nRemainingRounds and arena.nRemainingRounds > 0) then
				--stat = stat + 2 * math_floor((MAX_ROUNDS_PVP_ARENA - arena.nRemainingRounds) / 2);
			--end
		--end
	--end

	--226 add_damage_overall_absolute_bonus_percent(CG)
	--227 add_damage_fire_absolute_bonus_percent(CG)
	--228 add_damage_ice_absolute_bonus_percent(CG)
	--229 add_damage_storm_absolute_bonus_percent(CG)
	--230 add_damage_myth_absolute_bonus_percent(CG)
	--231 add_damage_life_absolute_bonus_percent(CG)
	--232 add_damage_death_absolute_bonus_percent(CG)
	--233 add_damage_balance_absolute_bonus_percent(CG) 
	local stats_ids = {};
	table.insert(stats_ids, 226);
	local school_lower = string.lower(school);
	if(school_lower == "fire") then
		table.insert(stats_ids, 227);
	elseif(school_lower == "ice") then
		table.insert(stats_ids, 228);
	elseif(school_lower == "storm") then
		table.insert(stats_ids, 229);
	elseif(school_lower == "myth") then
		table.insert(stats_ids, 230);
	elseif(school_lower == "life") then
		table.insert(stats_ids, 231);
	elseif(school_lower == "death") then
		table.insert(stats_ids, 232);
	elseif(school_lower == "balance") then
		table.insert(stats_ids, 233);
	end
	-- bonus
	local stat_percent = self:GetStatsSum(stats_ids);

	stat = math.ceil(stat * (100 + stat_percent) / 100);
	
	if(System.options.version == "teen") then
		local level = self:GetLevel();
		local phase = self:GetPhase();
		if(level) then
			stat = stat + level * 1;
		end
	end

	return stat;
end

-- get resist
-- @param school: fire ice etc.
-- @return: -10 means 10% resist, if 100 pts damage is taken, 90 pts is applied
function Player:GetResist(school)
	local arena_id = self.arena_id;
	if(arena_id) then
		local arena = Arena.GetArenaByID(arena_id)
		if(arena) then
			if(arena.force_resist) then
				return arena.force_resist;
			end
		end
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
	-- vip bonus
	local stat = 0;
	
	--local arena_id = self.arena_id;
	--if(arena_id) then
		--local arena = Arena.GetArenaByID(arena_id)
		--if(arena and arena.is_battlefield) then
			---- base 30% resist for battle field arenas
			--stat = 30;
		--end
	--end

	stat = stat + self:GetStatsSum(stats_ids);

	if(PowerItemManager.IsVIPAndActivated(self:GetID())) then
		local m_level = PowerItemManager.GetMagicStarLevel(self:GetID());
		stat = stat + (vip_bonus_resist[m_level + 1] or 0);
	end
	-- max 100% resist
	if(stat >= maximum_player_resist) then
		stat = maximum_player_resist;
	end

	-- additional 80% damage resist for freezed targets
	if(self.freeze_rounds > 0) then
		stat = 100 - (100 - stat) * (100 - 80) / 100;
	end

	return -stat;
end

-- get resist absolute
-- @param school: fire ice etc.
-- @return: -10 means 10 resist absolute, if 100 pts damage is taken, 90 pts is applied
function Player:GetResist_absolute(school)
	local arena_id = self.arena_id;
	if(arena_id) then
		local arena = Arena.GetArenaByID(arena_id)
		if(arena) then
			if(arena.force_resist_absolute) then
				return arena.force_resist_absolute;
			end
		end
	end
	--159 add_resist_overall_absolute(CG)
	--160 add_resist_fire_absolute(CG)
	--161 add_resist_ice_absolute(CG)
	--162 add_resist_storm_absolute(CG)
	--163 add_resist_myth_absolute(CG)
	--164 add_resist_life_absolute(CG)
	--165 add_resist_death_absolute(CG)
	--166 add_resist_balance_absolute(CG)
	local stats_ids = {};
	table.insert(stats_ids, 159);
	local school_lower = string.lower(school);
	if(school_lower == "fire") then
		table.insert(stats_ids, 160);
	elseif(school_lower == "ice") then
		table.insert(stats_ids, 161);
	elseif(school_lower == "storm") then
		table.insert(stats_ids, 162);
	elseif(school_lower == "myth") then
		table.insert(stats_ids, 163);
	elseif(school_lower == "life") then
		table.insert(stats_ids, 164);
	elseif(school_lower == "death") then
		table.insert(stats_ids, 165);
	elseif(school_lower == "balance") then
		table.insert(stats_ids, 166);
	end
	local stat = self:GetStatsSum(stats_ids);
	-- vip bonus
	--if(PowerItemManager.IsVIPAndActivated(self:GetID())) then
		--local m_level = PowerItemManager.GetMagicStarLevel(self:GetID());
		--stat = stat + (vip_bonus_resist[m_level + 1] or 0);
	--end
	---- max 100% resist
	--if(stat >= maximum_player_resist) then
		--stat = maximum_player_resist;
	--end
--
	---- get stats from mini aura
	--if(self.miniaura and self.miniaura_rounds and self.miniaura_rounds > 0) then
		--local miniaura_template = Card.GetMiniAuraTemplate(self.miniaura);
		--if(miniaura_template) then
			--local extra_weight = 0;
			--local _, stat_type;
			--for _, stat_type in ipairs(stats_ids) do
				--extra_weight = extra_weight + (miniaura_template.stats[stat_type] or 0);
			--end
			---- recalculate resist with extra ward applied
			--stat = 100 - (100 - stat) * (100 - extra_weight) / 100
		--end
	--end
--
	---- additional 80% damage resist for freezed targets
	--if(self.freeze_rounds > 0) then
		--stat = 100 - (100 - stat) * (100 - 80) / 100;
	--end

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
	local stat_percent = self:GetStatsSum(stats_ids);

	stat = math.ceil(stat * (100 + stat_percent) / 100);
	
	if(System.options.version == "teen") then
		local level = self:GetLevel();
		local phase = self:GetPhase();
		if(level) then
			stat = stat + level * 1;
		end
	end

	if(System.options.version == "teen") then
		if(PowerItemManager.GetGlobalExpScaleAcc() == 1) then -- double global exp buff
			stat = stat + 3;
		end
	end

	if(self.pierce_freeze_buffs and self.pierce_freeze_rounds) then
		local _;
		for _ = 1, self.pierce_freeze_buffs do
			--李宇(Liyu) 10:19:11
			--机制都不动，数值 20-》10
			stat = math_ceil(stat * (1 - 0.1));
		end
		if(stat < 0) then
			stat = 0;
		end
	end

	return -stat;
end

-- get critical strike
-- @param school: fire ice etc.
-- @return: 10 means 10% critical strike
function Player:GetCriticalStrike(school)
	local arena_id = self.arena_id;
	if(arena_id) then
		local arena = Arena.GetArenaByID(arena_id)
		if(arena) then
			if(arena.force_criticalstrike) then
				return arena.force_criticalstrike;
			end
		end
	end
	-- 196 add_critical_strike_overall_percent(CG) 增加用户所有系魔法的暴击百分比  
	-- 197 add_critical_strike_fire_percent(CG) 增加用户火系魔法的暴击百分比  
	-- 198 add_critical_strike_ice_percent(CG) 增加用户冰系魔法的暴击百分比  
	-- 199 add_critical_strike_storm_percent(CG) 增加用户风暴系魔法的暴击百分比  
	-- 200 add_critical_strike_myth_percent(CG) 增加用户神秘系魔法的暴击百分比  
	-- 201 add_critical_strike_life_percent(CG) 增加用户生命系魔法的暴击百分比  
	-- 202 add_critical_strike_death_percent(CG) 增加用户死亡系魔法的暴击百分比  
	-- 203 add_critical_strike_balance_percent(CG) 增加用户平衡系魔法的暴击百分比  
	local stats_ids = {};
	table.insert(stats_ids, 196);
	local school_lower = string.lower(school);
	if(school_lower == "fire") then
		table.insert(stats_ids, 197);
	elseif(school_lower == "ice") then
		table.insert(stats_ids, 198);
	elseif(school_lower == "storm") then
		table.insert(stats_ids, 199);
	elseif(school_lower == "myth") then
		table.insert(stats_ids, 200);
	elseif(school_lower == "life") then
		table.insert(stats_ids, 201);
	elseif(school_lower == "death") then
		table.insert(stats_ids, 202);
	elseif(school_lower == "balance") then
		table.insert(stats_ids, 203);
	end

	local stat = self:GetStatsSum(stats_ids);
	
	-- get stats from mini aura
	if(self.miniaura and self.miniaura_rounds and self.miniaura_rounds > 0) then
		local miniaura_template = Card.GetMiniAuraTemplate(self.miniaura);
		if(miniaura_template) then
			local _, stat_type;
			for _, stat_type in ipairs(stats_ids) do
				stat = stat + (miniaura_template.stats[stat_type] or 0);
			end
		end
	end
	
	-- 254 add_critical_strike_overall_percent_10times(CG) 增加用户所有系魔法的暴击百分比 1:10 当数值为15时代表1.5% 并且和stat196叠加 
	stat = stat + self:GetStatsSum({254});

	-- 224 add_critical_strike_overall_rating(CG)
	local stat_rating = self:GetStatsSum({224});

	stat = stat + 100 * stat_rating / (50 + 50 * self:GetPetLevel());

	if(System.options.version == "kids") then
		local arena_id = self.arena_id;
		if(arena_id) then
			local side = self:GetSide();
			local arena = Arena.GetArenaByID(arena_id)
			if(arena) then
				local friendlys, hostiles = arena:GetFriendlyAndHostileUnits(side);
				local _, unit_struct;
				for _, unit_struct in ipairs(friendlys) do
					local unit = Arena.GetCombatUnit(unit_struct.isMob, unit_struct.id)
					-- 风暴形态： 暴击率 +20%
					if(unit and unit:GetStance() == "storm_kids") then
						stat = stat + 20;
						-- only apply one siblin effect
						break;
					end
				end
			end
		end
	end
	
	if(System.options.version == "teen") then
		-- use absolute value for teen version
		if(stat > 30) then
			stat = 30;
		end
	end

	return stat;
end

-- get critical strike in dot
-- @param school: fire ice etc.
-- @return: 10 means 10% critical strike
function Player:GetCriticalStrike_DOT(school)
	if(self:GetStance() == "blazing") then
		return 10000; -- 10000% must critical strike
	end
	return 0;
end

-- get critical strike damage ratio bonus
-- bonus is added to base damage ratio
function Player:GetCriticalStrikeDamageRatioBonus()
	-- 376 暴击额外伤害加成 84中配置为1代表0.1%的额外暴击伤害
	local stat = self:GetStatsSum({376});
	return stat * 0.001;
end

-- get resilience
-- @param school: fire ice etc.
-- @return: 10 means 10% resilience
function Player:GetResilience(school)
	local arena_id = self.arena_id;
	if(arena_id) then
		local arena = Arena.GetArenaByID(arena_id)
		if(arena) then
			if(arena.force_resilience) then
				return arena.force_resilience;
			end
		end
	end
	-- 204 add_resilience_overall_percent(CG) 增加用户所有系魔法的韧性百分比  
	-- 205 add_resilience_fire_percent(CG) 增加用户火系魔法的韧性百分比  
	-- 206 add_resilience_ice_percent(CG) 增加用户冰系魔法的韧性百分比  
	-- 207 add_resilience_storm_percent(CG) 增加用户风暴系魔法的韧性百分比  
	-- 208 add_resilience_myth_percent(CG) 增加用户神秘系魔法的韧性百分比  
	-- 209 add_resilience_life_percent(CG) 增加用户生命系魔法的韧性百分比  
	-- 210 add_resilience_death_percent(CG) 增加用户死亡系魔法的韧性百分比  
	-- 211 add_resilience_balance_percent(CG) 增加用户平衡系魔法的韧性百分比  
	local stats_ids = {};
	table.insert(stats_ids, 204);
	local school_lower = string.lower(school);
	if(school_lower == "fire") then
		table.insert(stats_ids, 205);
	elseif(school_lower == "ice") then
		table.insert(stats_ids, 206);
	elseif(school_lower == "storm") then
		table.insert(stats_ids, 207);
	elseif(school_lower == "myth") then
		table.insert(stats_ids, 208);
	elseif(school_lower == "life") then
		table.insert(stats_ids, 209);
	elseif(school_lower == "death") then
		table.insert(stats_ids, 210);
	elseif(school_lower == "balance") then
		table.insert(stats_ids, 211);
	end

	local stat = self:GetStatsSum(stats_ids);
	
	-- get stats from mini aura
	if(self.miniaura and self.miniaura_rounds and self.miniaura_rounds > 0) then
		local miniaura_template = Card.GetMiniAuraTemplate(self.miniaura);
		if(miniaura_template) then
			local _, stat_type;
			for _, stat_type in ipairs(stats_ids) do
				stat = stat + (miniaura_template.stats[stat_type] or 0);
			end
		end
	end

	if(System.options.version == "kids") then
		-- 队友增加20%的韧性
		local arena_id = self.arena_id;
		if(arena_id) then
			local side = self:GetSide();
			local arena = Arena.GetArenaByID(arena_id)
			if(arena) then
				local friendlys, hostiles = arena:GetFriendlyAndHostileUnits(side);
				local _, unit_struct;
				for _, unit_struct in ipairs(friendlys) do
					local unit = Arena.GetCombatUnit(unit_struct.isMob, unit_struct.id)
					if(unit and unit:GetStance() == "death_kids") then
						stat = stat + 20;
						-- only apply one siblin effect
						break;
					end
				end
			end
		end
	end

	if(self:GetPetLevel() == 0) then
		return stat;
	end
	
	-- 255 add_resilience_overall_percent_10times(CG) 增加用户所有系魔法的韧性百分比 1:10 当数值为15时代表1.5% 并且和stat204叠加  
	stat = stat + self:GetStatsSum({255});
	
	-- 225 add_resilience_overall_rating(CG)
	local stat_rating = self:GetStatsSum({225});
	
	stat = stat + 100 * stat_rating / (50 + 50 * self:GetPetLevel());

	return stat;
end

-- get resilience in dot
-- @param school: fire ice etc.
-- @return: 10 means 10% resilience
function Player:GetResilience_DOT(school)
	return 0;
end

-- get hitchance
-- @param school: fire ice etc.
-- @return: 10 means 10% hitchance
function Player:GetHitChance(school)
	-- 243 add_hitchance_overall_percent(CG) 增加用户所有系魔法的命中百分比 此命中非儿童版的命中概念，不再是判断是否施放技能成败，而是判断是否偏斜；命中造成100%伤害，偏斜造成50%伤害  

	local stat = self:GetStatsSum({243}) / 10;

	if(System.options.version == "kids") then
		-- 队友增加10%的命中
		local arena_id = self.arena_id;
		if(arena_id) then
			local side = self:GetSide();
			local arena = Arena.GetArenaByID(arena_id)
			if(arena) then
				local friendlys, hostiles = arena:GetFriendlyAndHostileUnits(side);
				for _, unit_struct in ipairs(friendlys) do
					local unit = Arena.GetCombatUnit(unit_struct.isMob, unit_struct.id)
					if(unit and unit:GetStance() == "death_kids") then
						stat = stat + 10;
						-- only apply one siblin effect
						break;
					end
				end
			end
		end
	end

	-- 244 add_hitchance_overall_rating(CG) 增加用户所有系魔法的命中强度 此命中非儿童版的命中概念，不再是判断是否施放技能成败，而是判断是否偏斜；命中造成100%伤害，偏斜造成50%伤害
	
	local stat_rating = self:GetStatsSum({244});

	
	-- 人打怪：   命中率 = 装备宝石药丸等提供的单方命中率-目标的单方闪避率-(目标等级-攻击者等级）*5%
	-- 人打人/怪打人： 命中率= 装备宝石药丸等提供的单方命中率-目标的单方闪避率-(目标等级-攻击者等级）*1%

	-- 单方命中率=装备提供的命中强度/(人物等级*K+C)+宝石坐骑药丸提供的命中率
	--     即：装备提供的命中强度/（人物等级×50+50）+宝石坐骑药丸提供的命中率
	-- 单方闪避率与此类似，即：装备提供的闪避强度/(人物等级*50+50)+宝石坐骑药丸提供的闪避率

	local level = self:GetLevel();

	stat = stat_rating / (level * 50 + 50) + stat;

	return stat;
end

-- get dodge
-- @param school: fire ice etc.
-- @return: 10 means 10% dodge
function Player:GetDodge(school)
	--188 add_dodge_overall_percent(CG) 增加用户所有系魔法的闪避百分比  
	--189 add_dodge_fire_percent(CG) 增加用户火系魔法的闪避百分比  
	--190 add_dodge_ice_percent(CG) 增加用户冰系魔法的闪避百分比  
	--191 add_dodge_storm_percent(CG) 增加用户风暴系魔法的闪避百分比  
	--192 add_dodge_myth_percent(CG) 增加用户神秘系魔法的闪避百分比  
	--193 add_dodge_life_percent(CG) 增加用户生命系魔法的闪避百分比  
	--194 add_dodge_death_percent(CG) 增加用户死亡系魔法的闪避百分比  
	--195 add_dodge_balance_percent(CG) 增加用户平衡系魔法的闪避百分比 
	local stats_ids = {};
	table.insert(stats_ids, 188);
	local school_lower = string.lower(school);
	if(school_lower == "fire") then
		table.insert(stats_ids, 189);
	elseif(school_lower == "ice") then
		table.insert(stats_ids, 190);
	elseif(school_lower == "storm") then
		table.insert(stats_ids, 191);
	elseif(school_lower == "myth") then
		table.insert(stats_ids, 192);
	elseif(school_lower == "life") then
		table.insert(stats_ids, 193);
	elseif(school_lower == "death") then
		table.insert(stats_ids, 194);
	elseif(school_lower == "balance") then
		table.insert(stats_ids, 195);
	end

	local stat = self:GetStatsSum(stats_ids) / 10;

	-- 245 add_dodge_overall_rating(CG) 增加用户所有系魔法的闪避强度 
	local stat_rating = self:GetStatsSum({245});
	
	-- 人打怪：   命中率 = 装备宝石药丸等提供的单方命中率-目标的单方闪避率-(目标等级-攻击者等级）*5%
	-- 人打人/怪打人： 命中率= 装备宝石药丸等提供的单方命中率-目标的单方闪避率-(目标等级-攻击者等级）*1%

	-- 单方命中率=装备提供的命中强度/(人物等级*K+C)+宝石坐骑药丸提供的命中率
	--     即：装备提供的命中强度/（人物等级×50+50）+宝石坐骑药丸提供的命中率
	-- 单方闪避率与此类似，即：装备提供的闪避强度/(人物等级*50+50)+宝石坐骑药丸提供的闪避率
	
	local level = self:GetLevel();

	stat = stat_rating / (level * 50 + 50) + stat;

	return stat;
end

-- get spell peneration
-- @param school: fire ice etc.
-- @return: 10 means 10% spell peneration which modify to resist(negative)
function Player:GetSpellPenetration(school)
	--212 add_spell_penetration_overall_percent(CG) 增加用户所有系魔法的法术穿透百分比  
	--213 add_spell_penetration_fire_percent(CG) 增加用户火系魔法的法术穿透百分比  
	--214 add_spell_penetration_ice_percent(CG) 增加用户冰系魔法的法术穿透百分比  
	--215 add_spell_penetration_storm_percent(CG) 增加用户风暴系魔法的法术穿透百分比  
	--216 add_spell_penetration_myth_percent(CG) 增加用户神秘系魔法的法术穿透百分比  
	--217 add_spell_penetration_life_percent(CG) 增加用户生命系魔法的法术穿透百分比  
	--218 add_spell_penetration_death_percent(CG) 增加用户死亡系魔法的法术穿透百分比  
	--219 add_spell_penetration_balance_percent(CG) 增加用户平衡系魔法的法术穿透百分比  
	local stats_ids = {};
	table.insert(stats_ids, 212);
	local school_lower = string.lower(school);
	if(school_lower == "fire") then
		table.insert(stats_ids, 213);
	elseif(school_lower == "ice") then
		table.insert(stats_ids, 214);
	elseif(school_lower == "storm") then
		table.insert(stats_ids, 215);
	elseif(school_lower == "myth") then
		table.insert(stats_ids, 216);
	elseif(school_lower == "life") then
		table.insert(stats_ids, 217);
	elseif(school_lower == "death") then
		table.insert(stats_ids, 218);
	elseif(school_lower == "balance") then
		table.insert(stats_ids, 219);
	end

	local stat = self:GetStatsSum(stats_ids);
	
	-- get stats from mini aura
	if(self.miniaura and self.miniaura_rounds and self.miniaura_rounds > 0) then
		local miniaura_template = Card.GetMiniAuraTemplate(self.miniaura);
		if(miniaura_template) then
			local _, stat_type;
			for _, stat_type in ipairs(stats_ids) do
				stat = stat + (miniaura_template.stats[stat_type] or 0);
			end
		end
	end
	
	if(System.options.version == "kids") then
		local arena_id = self.arena_id;
		if(arena_id) then
			local side = self:GetSide();
			local arena = Arena.GetArenaByID(arena_id)
			if(arena) then
				local friendlys, hostiles = arena:GetFriendlyAndHostileUnits(side);
				local _, unit_struct;
				for _, unit_struct in ipairs(friendlys) do
					local unit = Arena.GetCombatUnit(unit_struct.isMob, unit_struct.id)
					if(unit and unit:GetStance() == "life_kids") then
						stat = stat + 15;
						-- only apply one siblin effect
						break;
					end
				end
			end
		end
	end

	return stat;
end

-- get receive spell peneration
-- @param school: fire ice etc.
-- @return: 10 means 10% spell peneration
function Player:GetSpellPenetrationReceive(school)
	-- 247 add_spell_penetration_storm_percent(CG) 增加用户风暴系魔法的*被*法术穿透百分比 (儿童版) 
	if(school == "storm") then
		local stat = self:GetStatsSum({247});
		return stat;
	end
	return 0;
end

-- 182 output_heal_percent(CG) 输出治疗加成百分比  
-- 183 input_heal_percent(CG) 输入治疗加成百分比  
-- get output heal boost percent
-- @return: 10 means 10% heal boost
function Player:GetOutputHealBoost()
	local arena_id = self.arena_id;
	if(arena_id) then
		local arena = Arena.GetArenaByID(arena_id)
		if(arena) then
			if(arena.force_outputhealboost) then
				return arena.force_outputhealboost;
			end
		end
	end
	local stats_ids = {};
	table.insert(stats_ids, 182);
	-- vip bonus
	local stat = self:GetStatsSum(stats_ids);
	if(System.options.version == "kids") then
		if(PowerItemManager.IsVIPAndActivated(self:GetID())) then
			local m_level = PowerItemManager.GetMagicStarLevel(self:GetID());
			stat = stat + (vip_bonus_output_heal[m_level + 1] or 0);
		end
	end
	return stat;
end

-- 182 output_heal_percent(CG) 输出治疗加成百分比  
-- 183 input_heal_percent(CG) 输入治疗加成百分比  
-- get output heal boost percent
-- @return: 10 means 10% heal boost
function Player:GetInputHealBoost()
	local arena_id = self.arena_id;
	if(arena_id) then
		local arena = Arena.GetArenaByID(arena_id)
		if(arena) then
			if(arena.force_inputhealboost) then
				local stat = self:GetStatsSum({183}, true);
				return arena.force_inputhealboost + stat;
			end
		end
	end
	local stats_ids = {};
	table.insert(stats_ids, 183);
	-- vip bonus
	local stat = self:GetStatsSum(stats_ids);
	if(System.options.version == "kids") then
		if(PowerItemManager.IsVIPAndActivated(self:GetID())) then
			local m_level = PowerItemManager.GetMagicStarLevel(self:GetID());
			stat = stat + (vip_bonus_input_heal[m_level + 1] or 0);
		end
	end
	return stat;
end

-- get double attack chance
-- @param school: fire ice etc.
-- @return: 10 means 10% double attack chance
function Player:GetDoubleAttackChance(school)
	local stat = 0;
	-- 256 add_double_attack_chance(CG) 增加用户所有系魔法双倍攻击的百分比(儿童版第一次使用，把死亡形态的双倍攻击效果公开为stat) 
	if(System.options.version == "kids") then
		local stats_ids = {};
		table.insert(stats_ids, 256);
		-- stats bonus
		stat = stat + self:GetStatsSum(stats_ids);
		-- get from stance
		--[[ 增加队友30%致命一击概率
		local arena_id = self.arena_id;
		if(arena_id) then
			local side = self:GetSide();
			local arena = Arena.GetArenaByID(arena_id)
			if(arena) then
				local friendlys, hostiles = arena:GetFriendlyAndHostileUnits(side);
				local _, unit_struct;
				for _, unit_struct in ipairs(friendlys) do
					local unit = Arena.GetCombatUnit(unit_struct.isMob, unit_struct.id)
					if(unit and unit:GetStance() == "death_kids") then
						stat = stat + 30;
						-- only apply one siblin effect
						break;
					end
				end
			end
		end
		]]
	end

	return stat;
end

-- validate the set id
function Player:ValidateSetID()
end

-- get history gear score, if not exist, we will use current gear score. 
function Player:GetHistoryGearScore()
	local _, _, _, copies = PowerItemManager.IfOwnGSItem(self:GetNID(), 965);
	return copies or self:GetGearScoreV2();
end

-- get the minimum ranking score if any. 
function Player:GetMiniRankingScore()
	local gs_score = self:GetHistoryGearScore();
	gs_score = 1000 + math_floor(gs_score/100)*100;
	return gs_score;
end

-- get the virtual ranking score
-- 1000 + gearscore. 
-- @param stage: 1v1 or 2v2
function Player:GetVirtualRankingScore(stage)
	local gs_score = 1000 + self:GetHistoryGearScore();
	local rank_pt = self:GetRanking(stage);
	if(rank_pt and rank_pt > gs_score) then
		return rank_pt;
	else
		return gs_score;
	end
end

-- this is the more accurate version of combat ability. 
-- Revised score: (Attack + Defense + HP/20 + ...) * 0.6
--  Attack, defense and hp are primary factors, other factors are ignored since they may be automatically balanced when the sum of primary factors are same. 
-- think of this score as total damage dealt with 100 card on a dummy puppet plus the required damage so that 100 damage can be taken on this player. 
-- gs = PowerPipPercentage + max_attack_value_of_five_school + average_resist_of_five_school
-- for example: user with 0 attack, 0 resist has a gs of 100
--              user with 80% max attack, 30% average resist has a gs of 80+ 100/(1-30%) = 222
--              user with 160% max attack, 50% average resist has a gs of 160+ 100/(1-50%) = 360
--              user with 160% max attack, 70% average resist has a gs of 160+ 100/(1-70%) = 493
-- @param bRecalculate: true to recalculate
function Player:GetGearScoreV2(bRecalculate)
	

	if(not bRecalculate and self.gs_v2) then
		return self.gs_v2;
	end
	local gearscore = 0;


	-- attack damage on no-defense object of 100 base attack point. 
	local max_attack_abs = math.max(
		(100 + self:GetDamageBoost("fire")) * (1 + self:GetDamageBoost_absolute("fire") / 100), 
		(100 + self:GetDamageBoost("ice")) * (1 + self:GetDamageBoost_absolute("ice") / 100), 
		(100 + self:GetDamageBoost("storm")) * (1 + self:GetDamageBoost_absolute("storm") / 100), 
		(100 + self:GetDamageBoost("life")) * (1 + self:GetDamageBoost_absolute("life") / 100), 
		(100 + self:GetDamageBoost("death")) * (1 + self:GetDamageBoost_absolute("death") / 100)
		);
	gearscore = gearscore + max_attack_abs;
	
	-- attack needed to cast 100 damage on me
	local resist_average = 100 / (1 - (
			- self:GetResist("fire")
			- self:GetResist("ice")
			- self:GetResist("storm")
			- self:GetResist("life")
			- self:GetResist("death")
		) / 500) * (1 - ((self:GetResist_absolute("fire") 
			+ self:GetResist_absolute("ice") 
			+ self:GetResist_absolute("storm") 
			+ self:GetResist_absolute("life") 
			+ self:GetResist_absolute("death")
		) / 5) / 100);
	gearscore = gearscore + resist_average;

	-- HP/20 makes HP a large factor in gs
	gearscore = gearscore + self:GetMaxHP()/20;

	-- minor adjustment on powerpips
	gearscore = gearscore + self:GetPowerPipChance();
	
	-- minor adjustment on heal over 60%
	local heal_total = (100+self:GetInputHealBoost())*(100+self:GetOutputHealBoost())/10000;
	if(heal_total > 169) then
		gearscore = gearscore + heal_total;
	end
	
	if(System.options.version == "teen") then
		-- 加入暴击 韧性 命中 闪避
		gearscore = gearscore + self:GetCriticalStrike(self:GetPhase());
		gearscore = gearscore + self:GetResilience(self:GetPhase());
		gearscore = gearscore + self:GetHitChance(self:GetPhase());
		gearscore = gearscore + self:GetDodge(self:GetPhase());
	end
	
	
	-- Finally 0.6 making the value in [0-1200] range. 
	gearscore = gearscore * 0.6;

	self.gs_v2 = math.floor(gearscore);
	
	-- echo({"11111111111111111111111", gearscore, resist_average, max_attack_abs, self:GetMaxHP()/20, heal_total, self:GetPowerPipChance()})

	return gearscore;
end

-- NOTE: player inventory and userinfo MUST be validated BEFORE gearscore
-- @return: player gear score
function Player:GetGearScore(bRecalculate)
	if(not bRecalculate and self.gs) then
		return self.gs;
	end

	local gearscore = 0;

	gearscore = gearscore + self:GetPetLevel() * 100;

	gearscore = gearscore + self:GetPowerPipChance() * 25;
				
	gearscore = gearscore + self:GetDamageBoost("fire") * 5;
	gearscore = gearscore + self:GetDamageBoost("ice") * 5;
	gearscore = gearscore + self:GetDamageBoost("storm") * 5;
	gearscore = gearscore + self:GetDamageBoost("life") * 5;
	gearscore = gearscore + self:GetDamageBoost("death") * 5;
				
	gearscore = gearscore + self:GetDamageBoost_absolute("fire") * 5;
	gearscore = gearscore + self:GetDamageBoost_absolute("ice") * 5;
	gearscore = gearscore + self:GetDamageBoost_absolute("storm") * 5;
	gearscore = gearscore + self:GetDamageBoost_absolute("life") * 5;
	gearscore = gearscore + self:GetDamageBoost_absolute("death") * 5;
				
	gearscore = gearscore - self:GetResist("fire") * 5;
	gearscore = gearscore - self:GetResist("ice") * 5;
	gearscore = gearscore - self:GetResist("storm") * 5;
	gearscore = gearscore - self:GetResist("life") * 5;
	gearscore = gearscore - self:GetResist("death") * 5;
				
	gearscore = gearscore + self:GetResist_absolute("fire") * 5;
	gearscore = gearscore + self:GetResist_absolute("ice") * 5;
	gearscore = gearscore + self:GetResist_absolute("storm") * 5;
	gearscore = gearscore + self:GetResist_absolute("life") * 5;
	gearscore = gearscore + self:GetResist_absolute("death") * 5;

	self.gs = gearscore;
	return gearscore;
end

-- all item set effect, id as key and stats table as value
local all_item_set_effect = nil;

-- id as key and component item gsid table as value
local all_item_set_components = nil;

-- init all item sets
function Player.InitAllItemSetIfNot()
	-- parse all item set effects if not parsed before
	if(not all_item_set_effect) then
		all_item_set_effect = {};
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
				return (a.item_count > b.item_count);
			end);
			all_item_set_effect[set_id] = item_set_effect;
		end
		-- parse all item set components if not parsed before
		if(not all_item_set_components) then
			all_item_set_components = {};
			local gsid = 1001;
			for gsid = 1001, 8999 do
				local gsItem = PowerItemManager.GetGlobalStoreItemInMemory(gsid);
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

-- consume player pill and food buff if not
function Player:ConsumePillAndFoodBuffIfNot()
	
	do return end

	-- must resync combat items before buff validate
	if(not self.bConsumePillAndFoodBuff and self.bResyncCombatItems) then
		local item_list = PowerItemManager.GetItemsInBagInMemory(self:GetNID(), 0);
		local items_buff = nil;
		local items_lastone_str = "";
		if(item_list) then
			local guids = {};
			local k, guid;
			for k, guid in ipairs(item_list) do
				local item = PowerItemManager.GetItemByGUID(self:GetNID(), guid);
				if(item and item.guid > 0) then
					-- pill buff or food buff position
					if((item.position >= 90 and item.position <= 105) or (item.position >= 111 and item.position <= 125)) then
						items_buff = items_buff or {};
						-- append to delete list
						items_buff[item.guid] = 1;
						if(item.copies == 1) then
							-- append to items_lastone_str
							items_lastone_str = items_lastone_str..item.gsid..",";
						end
					end
				end
			end
		end
		-- destroy buff items
		if(items_buff) then
			local player_nid_str = tostring(self:GetNID());
			PowerItemManager.DestroyItemBatch(self:GetNID(), items_buff, function(msg)
				if(msg.issuccess == true) then
					-- tell the user, these are the last pills
					if(items_lastone_str and items_lastone_str ~= "") then
						---- tell the client of the mount gem process
						local gridnode = GSL_gateway:GetPrimGridNode(player_nid_str);
						if(gridnode) then
							local server_object = gridnode:GetServerObject("sPowerAPI");
							if(server_object) then
								-- tell the user of the mount gem return message
								server_object:SendRealtimeMessage(player_nid_str, "[Aries][PowerAPI]LastPills:"..items_lastone_str);
							end
						end
					end
				end
			end);
		end
		self.bConsumePillAndFoodBuff = true;
	end
end

-- validate player phase
function Player:ValidatePlayerPhase()
	if(not self.phase) then
		self.phase = PowerItemManager.GetUserSchool(self:GetNID());
	end
end

function Player:ResetItemSetInfo()
	self.current_itemset_info = nil;
	self:SetItemSetInfoIfNot();
end

function Player:SetItemSetInfoIfNot()
	if(not self.current_itemset_info) then
		-- init item set if not
		Player.InitAllItemSetIfNot();
		-- setid and component count
		local setid_component_count = {};
		-- traverse all item set ids
		local itemsetid, gsid_table;
		for itemsetid, gsid_table in pairs(all_item_set_components) do
			local this_itemset_id = nil;
			local gsid, _;
			for gsid, _ in pairs(gsid_table) do
				local is_gsid_equiped = false;
				local __, equip_gsid;
				for __, equip_gsid in pairs(self.equips) do
					if(gsid == equip_gsid) then
						is_gsid_equiped = true;
						break;
					end
				end
				if(is_gsid_equiped) then
					if(PowerItemManager.IfOwnGSItem(self:GetNID(), gsid)) then
						setid_component_count[itemsetid] = (setid_component_count[itemsetid] or 0) + 1;
					end
				end
			end
		end
		self.current_itemset_info = setid_component_count;
	end
end

-- if player equiped item
function Player:IfEquipItemInEnterCombat(gsid)
	if(gsid) then
		local _, equip_gsid;
		for _, equip_gsid in ipairs(self.equips) do
			if(equip_gsid == gsid) then
				return true;
			end
		end
	end
	return false;
end

-- get stats sum 
-- NOTE: stat type please refer to wiki page http://pedn/KidsDev/ItemSystemDesign
-- @param stats_ids: {102, 103, ...}
-- @return: stat value sum of the given stat types
function Player:GetStatsSum(stats_ids, bSkipEquips)
	if(System.options.version == "teen") then
		local master_nid = self:GetID();
		if(master_nid and master_nid < 0) then
			local value = 0;
			-- follow pet minion
			master_nid = -master_nid;
			local followpet_guid = self.current_followpet_guid;
			if(followpet_guid and followpet_guid > 0) then
				local pet_obj = PowerItemManager.GetItemByGUID(master_nid, followpet_guid);
				if(pet_obj and pet_obj.guid > 0 and pet_obj.GetCurLevelProps) then
					local _, followpet_stats = pet_obj:GetCurLevelProps(true);
					if(followpet_stats) then
						local _, stat_type;
						for _, stat_type in pairs(stats_ids) do
							value = value + (followpet_stats[stat_type] or 0);
						end
					end
				end
			end
			return value;
		end
	end
	
	Player.InitAllItemSetIfNot();

	local value = 0;

	if(not bSkipEquips) then
		-- get stats from equips
		local _, gsid;
		for _, gsid in ipairs(self.equips) do
			local gsItem = PowerItemManager.GetGlobalStoreItemInMemory(gsid)
			if(gsItem) then
				local stats = gsItem.template.stats;
				local _, stat_type;
				for _, stat_type in ipairs(stats_ids) do
					value = value + (stats[stat_type] or 0);
				end
			end
		end
		-- addon level stats
		-- 111 add_damage_overall_percent(CG) 增加用户所有系魔法的附加攻击百分比  
		local _, stat_type;
		for _, stat_type in ipairs(stats_ids) do
			if(stat_type == 111) then
				value = value + self.addonlevel_damage_percent;
			end
		end
		-- addon level stats
		-- 151 add_damage_overall_absolute(CG) 增加用户所有系魔法的附加伤害绝对值(青年版用这个) 
		-- 159 add_resist_overall_absolute(CG) 增加用户所有系魔法的附加抗性绝对值(青年版用这个) 
		local _, stat_type;
		for _, stat_type in ipairs(stats_ids) do
			if(stat_type == 151) then
				value = value + self.addonlevel_damage_absolute;
			elseif(stat_type == 159) then
				value = value + self.addonlevel_resist_absolute;
			end
		end
		-- addon level stats
		-- 101 add_maximum_hp(CG) 增加用户HP上限
		local _, stat_type;
		for _, stat_type in ipairs(stats_ids) do
			if(stat_type == 101) then
				value = value + self.addonlevel_hp_absolute;
			end
		end
		-- 196 add_critical_strike_overall_percent(CG) 增加用户所有系魔法的暴击百分比 
		local _, stat_type;
		for _, stat_type in ipairs(stats_ids) do
			if(stat_type == 196) then
				value = value + (self.addonlevel_criticalstrike_percent or 0);
			end
		end
		-- 204 add_resilience_overall_percent(CG) 增加用户所有系魔法的韧性百分比 
		local _, stat_type;
		for _, stat_type in ipairs(stats_ids) do
			if(stat_type == 204) then
				value = value + (self.addonlevel_resilience_percent or 0);
			end
		end
		-- get stats from gems
		local _, gsid;
		for _, gsid in ipairs(self.gems) do
			local gsItem = PowerItemManager.GetGlobalStoreItemInMemory(gsid)
			if(gsItem) then
				local stats = gsItem.template.stats;
				local _, stat_type;
				for _, stat_type in ipairs(stats_ids) do
					value = value + (stats[stat_type] or 0);
				end
			end
		end
		-- get stats from follow pet
		local followpet_guid = self.current_followpet_guid;
		if(followpet_guid and followpet_guid > 0) then
			local master_nid = self:GetID();
			if(master_nid and master_nid > 0) then
				-- player
				local pet_obj = PowerItemManager.GetItemByGUID(master_nid, followpet_guid);
				if(pet_obj and pet_obj.guid > 0 and pet_obj.GetCurLevelProps) then
					local stats = pet_obj:GetCurLevelProps(true);
					if(stats) then
						local _, stat_type;
						for _, stat_type in pairs(stats_ids) do
							value = value + (stats[stat_type] or 0);
						end
					end
				end
			end
		end
		-- get stats from item set
		if(self.current_itemset_info) then
			if(self.current_itemset_info and all_item_set_effect) then
				local itemset_id, count;
				for itemset_id, count in pairs(self.current_itemset_info) do
					local item_set_effect = all_item_set_effect[itemset_id];
					local _, item_set_stats_group;
					for _, item_set_stats_group in ipairs(item_set_effect) do
						if(count >= item_set_stats_group.item_count) then
							local _, stat_type;
							for _, stat_type in pairs(stats_ids) do
								value = value + (item_set_stats_group[stat_type] or 0);
							end
						end
					end
				end
			end
		end
		-- get stats from user team aura
		local arena_id = self.arena_id;
		if(arena_id) then
			local arena = Arena.GetArenaByID(arena_id);
			if(arena) then
				local side = self:GetSide();
				local from, to;
				if(side == "near") then
					from = 1;
					to = 4;
				elseif(side == "far") then
					from = 5;
					to = 8;
				end
				local effected_team_aura = {};
				-- each player unit
				if(from and to) then
					local i;
					for i = from, to do
						local nid = arena.player_nids[i];
						if(nid) then
							local player = Player.GetPlayerCombatObj(nid)
							if(player and player.user_team_aura) then
								if(not effected_team_aura[player.user_team_aura]) then
									local gsItem = PowerItemManager.GetGlobalStoreItemInMemory(player.user_team_aura);
									if(gsItem) then
										local stats = gsItem.template.stats;
										local _, stat_type;
										for _, stat_type in ipairs(stats_ids) do
											value = value + (stats[stat_type] or 0);
										end
									end
									effected_team_aura[player.user_team_aura] = true;
								end
							end
						end
					end
				end
			end
		end
	end
	-- get stats from standing wards
	for i = 1, #self.standing_wards do
		local each_ward = self.standing_wards[i];
		if(each_ward and each_ward.id and each_ward.id ~= 0 and each_ward.rounds and each_ward.rounds > 0) then
			local wardTemplate = Card.GetWardTemplate(each_ward.id)
			if(wardTemplate and wardTemplate.stats) then
				local _, stat_type;
				for _, stat_type in pairs(stats_ids) do
					value = value + (wardTemplate.stats[stat_type] or 0);
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
						value = value + (globalauraTemplate.stats[stat_type] or 0);
					end
				end
			end
		end
	end

	-- get stats from dragon totem
	local profession_gsid = self.dragon_totem_profession_gsid;
	local exp_gsid = self.dragon_totem_exp_gsid;
	local exp_cnt = self.dragon_totem_exp_cnt;
	if(profession_gsid and profession_gsid > 0 and exp_gsid and exp_gsid > 0 and exp_cnt and exp_cnt >= 0) then
		-- get stats
		local stats = Card.GetStatsFromDragonTotemProfessionAndExp(profession_gsid, exp_gsid, exp_cnt);
		if(stats) then
			local _, stat_type;
			for _, stat_type in pairs(stats_ids) do
				value = value + (stats[stat_type] or 0);
			end
		end
	end

	if(System.options.version == "teen") then
		if(self.isoverweight) then
			value = math_ceil(value / 2);
		end
	end

	if(System.options.version == "kids") then
		for _, stat_type in pairs(stats_ids) do
			-- 376: 暴击伤害+20%
			if(stat_type == 376) then
				local arena_id = self.arena_id;
				if(arena_id) then
					local side = self:GetSide();
					local arena = Arena.GetArenaByID(arena_id)
					if(arena) then
						local friendlys, hostiles = arena:GetFriendlyAndHostileUnits(side);
						local _, unit_struct;
						for _, unit_struct in ipairs(friendlys) do
							local unit = Arena.GetCombatUnit(unit_struct.isMob, unit_struct.id)
							-- 风暴形态 +20%
							if(unit and unit:GetStance() == "storm_kids") then
								value = value + 200;
								-- only apply one siblin effect
								break;
							end
						end
					end
				end
			end
		end
	end

	return value;
end

-- get durable items
function Player:GetDurableItems()
	if(System.options.version == "kids") then
		-- return nil for kids version, no durable items for kids version
		return;
	end
	-- get stats from equips
	local bAvailableItems = false;
	local ret = {};
	local _, gsid;
	for _, gsid in ipairs(self.equips) do
		local gsItem = PowerItemManager.GetGlobalStoreItemInMemory(gsid)
		if(gsItem) then
			local stats = gsItem.template.stats;
			if(stats[222]) then
				local has, guid = PowerItemManager.IfOwnGSItem(self:GetNID(), gsid);
				if(has) then
					bAvailableItems = true;
					table.insert(ret, guid);
				end
			end
		end
	end
	if(bAvailableItems) then
		return ret;
	end
end

-- is player alive
function Player:IsAlive()
	if(self:GetCurrentHP() > 0) then
		return true;
	end
	return false;
end

-- take damage
function Player:TakeDamage(points)
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
		-- stance
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
		-- reset shield amount
		self.reflect_amount = 0;
		-- reset pips
		self.pips_normal = 0;
		self.pips_power = 0;
		-- clear picked card
		self:ClearPickedCard();
		-- reset protect rounds for deadlyattack and absolutedefense
		self.remedy.deadlyAttack_protect_rounds = 0;
		self.remedy.absoluteDefense_protect_rounds = 0;
		-- reset threat
		local arena_id = self.arena_id;
		if(arena_id) then
			local arena = Arena.GetArenaByID(arena_id)
			if(arena) then
				local id;
				for _, id in ipairs(arena.mob_ids) do
					local mob = Mob.GetMobByID(id);
					mob:ClearThreat(self:GetThreatID());
				end
			end
		end
	end
end

-- revive player
function Player:Revive()
	self:TakeDamage(9999999); -- kill unit with very large damage and reset
	self:TakeHeal(REVIVE_BASE_HP);
	self.bWithGuardian = false; -- reset with guardian
end

-- take heal
function Player:TakeHeal(points)
	self.current_hp = self.current_hp + points;
	if(self.current_hp > self:GetMaxHP()) then
		self.current_hp = self:GetMaxHP();
	end
end

-- append charm
function Player:AppendCharm(charm_id)
	table.insert(self.charms, charm_id);
end

-- append ward
function Player:AppendWard(ward_id)
	table.insert(self.wards, ward_id);
end

-- append reflection shield
function Player:AppendReflectionShield(amount)
	self.reflect_amount = self.reflect_amount + amount;
end

-- append standing ward
function Player:AppendStandingWard(ward_id, rounds)
	table.insert(self.standing_wards, {id = ward_id, rounds = rounds});
end

-- append absorb
function Player:AppendAbsorb(absorb_pts, ward_id)
	table.insert(self.wards, ward_id);
	self.absorbs[#self.wards] = absorb_pts;
end

-- pop charm id. if charm exist, remove the charm id and return true, if not return false
function Player:PopCharm(id)
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
function Player:PopRandomCharm(only_positive_or_negative, isLast, isFirst)
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
function Player:PopLastCharm(only_positive_or_negative)
	return self:PopRandomCharm(only_positive_or_negative, true);
end

-- pop first charm
-- @param only_positive_or_negative: true, only positive charm, false only negative charm, nil any random charm
-- @return: charm id or nil for no charms available
function Player:PopFirstCharm(only_positive_or_negative)
	return self:PopRandomCharm(only_positive_or_negative, nil, true);
end

-- if unit has positive charm
function Player:HasPositiveCharm()
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
function Player:HasNegativeCharm()
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
function Player:ProcessStatAgainstCharms(buffs, stat_name, school, buffs2)
	if(not buffs or not stat_name or not school) then
		LOG.std(nil, "error", "player_server", "Player:ProcessHitChanceAgainstCharms got invalid input: "..commonlib.serialize({buffs, stat_name, school}));
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
function Player:ProcessAccuracyAgainstCharms(buffs, school)
	return self:ProcessStatAgainstCharms(buffs, "boost_accuracy", school);
end

-- process hitchance with charms
function Player:ProcessHitChanceAgainstCharms(buffs, school)
	return self:ProcessStatAgainstCharms(buffs, "boost_hitchance", school);
end

-- process damage with charms
function Player:ProcessDamageAgainstCharms(buffs, school, buffs2)
	return self:ProcessStatAgainstCharms(buffs, "boost_damage", school, buffs2);
end

-- process heal with charms
function Player:ProcessHealAgainstCharms(buffs)
	return self:ProcessStatAgainstCharms(buffs, "boost_heal", "skipschool");
end

-- pop ward id. if ward exist, remove the ward id and return true, if not return false
function Player:PopWard(id)
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
function Player:PopStandingWardIfExist(id)
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
function Player:ProcessDamageAgainstWards(buffs, damage_school)
	if(not buffs or not damage_school) then
		LOG.std(nil, "error", "player_server", "Player:ProcessDamageAgainstWards got invalid input: "..commonlib.serialize({buffs, damage_school}));
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
function Player:PopRandomWardForManipulate(only_positive_or_negative, isLast, isFirst)
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
function Player:PopLastWardForManipulate(only_positive_or_negative)
	return self:PopRandomWardForManipulate(only_positive_or_negative, true)
end

-- pop random ward
-- @param only_positive_or_negative: true, only positive ward, false only negative ward, nil any random ward
-- @return: ward id or nil for no wards available
function Player:PopFirstWardForManipulate(only_positive_or_negative)
	return self:PopRandomWardForManipulate(only_positive_or_negative, nil, true)
end

-- if unit has specified ward
function Player:HasWard(id, bIncludeQuality)
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
function Player:HasPositiveWardForManipulate()
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
function Player:HasNegativeWardForManipulate()
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
function Player:AppendDoT(sequence)
	if(sequence) then
		table.insert(self.DOTs, sequence);
	end
end

-- pop all dot damage in sequence with damage schools
-- @return: {{damage = 10, damage_school = "fire"}, {damage = 20, damage_school = "wood"}}
function Player:PopDoT()
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
function Player:PopExplodeDotsIfExist()
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
function Player:AppendHoT(sequence)
	if(sequence) then
		table.insert(self.HOTs, sequence);
	end
end

-- pop all hot heal in sequence with damage schools
-- @return: {{heal = 10}, {heal = 20}}
function Player:PopHoT()
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
function Player:PopAllNegativeEffects()
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

-- get charm value string
-- NOTE: latest applied charm comes first
function Player:GetCharmsValue()
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
function Player:GetWardsValue()
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
	-- append stance wards value
	if(self.stance == "defensive") then
		value = ice_defensivestance_ward_id..","..value;
	elseif(self.stance == "healing") then
		value = life_healingstance_ward_id..","..value;
	elseif(self.stance == "blazing") then
		value = fire_blazingstance_ward_id..","..value;
	elseif(self.stance == "electric") then
		value = storm_electricstance_ward_id..","..value;
		--if(self.electric_rounds) then
			--local rounds = self.electric_rounds;
			--if(rounds > 0) then
				--local i;
				--for i = 1, rounds do
					--value = storm_electricstance_even_mode_ward_id..","..value;
				--end
			--elseif(rounds < 0) then
				--rounds = -rounds;
				--local i;
				--for i = 1, rounds do
					--value = storm_electricstance_odd_mode_ward_id..","..value;
				--end
			--end
		--end
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

	if(self.control_rounds and self.control_rounds > 0) then
		local i;
		for i = 1, self.control_rounds do
			value = balance_rune_areacontrol_devil_ward_id..","..value;
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
function Player:GetMiniAuraValue()
	local value = tostring(self.miniaura or 0);
	if(self.bStunned) then
		value = value..",stun";
	end
	if(self.control_rounds and self.control_rounds > 0) then
		value = value..",control";
	end
	if(self.stance == "healing") then
		value = value..",healing";
	elseif(self.stance == "blazing") then
		value = value..",blazing";
	elseif(self.stance == "electric") then
		value = value..",electric";
	elseif(self.stance == "vampire") then
		value = value..",vampire";
	elseif(self.stance == "pierce") then
		value = value..",pierce";
	elseif(self.stance == "fire_kids") then
		value = value..",fire_kids";
	elseif(self.stance == "ice_kids") then
		value = value..",ice_kids";
	elseif(self.stance == "storm_kids") then
		value = value..",storm_kids";
	elseif(self.stance == "life_kids") then
		value = value..",life_kids";
	elseif(self.stance == "death_kids") then
		value = value..",death_kids";
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
function Player:SetMiniAura(aura_id, rounds)
	self.miniaura = aura_id;
	self.miniaura_rounds = rounds;
end

-- validate mini aura rounds
function Player:ValidateMiniAura()
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
function Player:SetStance(stance, rounds)
	self.stance = stance;
	self.stance_rounds = rounds;
end

-- get the stance and validate rounds
-- @return: stance and round
function Player:GetStance()
	return self.stance, self.stance_rounds;
end

-- validate stance rounds
function Player:ValidateStance()
	if(self.stance_rounds and self.stance_rounds > 0) then
		self.stance_rounds = self.stance_rounds - 1;
		-- reset stance if no remaining rounds available
		if(self.stance_rounds == 0) then
			self.stance = nil;
			self.stance_rounds = nil;
		end
	end
end

-- is player immune to dispel
function Player:IsImmuneToDispel()
	-- player never immune to dispel
	return false;
end

-- is mob immune to stun
function Player:IsImmuneToStun()
	return false;
end

-- is mob immune to freeze
function Player:IsImmuneToFreeze()
	return false;
end

-- is player stealth
function Player:IsStealth()
	return (self.stealth == true);
end

-- set the stealth and validate rounds
--@param round: validate rounds, nil for always valid
function Player:SetStealthRounds(rounds)
	self.stealth = true;
	self.stealth_rounds = rounds;
end

-- leave stealth status
function Player:LeaveStealth()
	self.stealth = false;
	self.stealth_rounds = nil;
end

-- validate stealth rounds
function Player:ValidateStealthRounds()
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
function Player:AppendPierceFreezeRounds(rounds)
	if(self.pierce_freeze_buffs) then
		self.pierce_freeze_buffs = self.pierce_freeze_buffs + 1;
	else
		self.pierce_freeze_buffs = 1;
	end
	self.pierce_freeze_rounds = rounds;
end

-- validate pierce freeze rounds
function Player:ValidatePierceFreezeRounds()
	if(self.pierce_freeze_rounds and self.pierce_freeze_rounds > 0) then
		self.pierce_freeze_rounds = self.pierce_freeze_rounds - 1;
		-- reset stealth if no remaining rounds available
		if(self.pierce_freeze_rounds == 0) then
			self.pierce_freeze_buffs = nil;
			self.pierce_freeze_rounds = nil;
		end
	end
end

-- validate protect rounds rounds for deadly attack and absolute defend
function Player:ValidateProtectRoundsForDeadlyAttackAndAbsoluteDefend()
	if(self.remedy and System.options.version == "kids") then
		if(self.remedy.deadlyAttack_protect_rounds > 0) then
			self.remedy.deadlyAttack_protect_rounds = self.remedy.deadlyAttack_protect_rounds - 1;
		end
		if(self.remedy.absoluteDefense_protect_rounds > 0) then
			self.remedy.absoluteDefense_protect_rounds = self.remedy.absoluteDefense_protect_rounds - 1;
		end
	end
end

-- get final output heal weight
function Player:GetOutputHealFinalWeight()
	if(self.stance == "healing") then
		return 1.3;
	end
	return 1;
end

-- get final output damage weight
function Player:GetOutputDamageFinalWeight()
	local weight = 1;
	if(self.stance == "defensive") then
		if(System.options.version == "teen") then
			weight = 0.8;
		end
		weight = 0.75;
	elseif(self.stance == "vampire") then
		local hp_percent = self:GetCurrentHP() / self:GetMaxHP();
		weight = 1 + (1 - hp_percent) / 2;
	elseif(self.stance == "electric") then
		--if(self.electric_rounds) then
			--if(self.electric_rounds) then
				--weight = 1 + 0.05 * math.abs(self.electric_rounds);
			--end
		--end
		--王田(Andy) 17:09:05
		--改为，提升风暴攻击力20%  是一直提升攻击力么
		--李宇(Liyu) 17:08:58
		--是的
		--李宇(Liyu) 17:09:09
		--开形态就有 形态没了就没了
		--李宇(Liyu) 17:09:40
		--就是开形态，获得一个5回合的buff

		--李宇(Liyu) 09:46:25
		--hi，andy，风暴形态的那个20%的数值是配置的还是你程序写死的
		--王田(Andy) 09:46:31
		--写死
		--李宇(Liyu) 09:48:22
		--哦，那帮我先写22% 谢谢

		weight = 1 + 0.22;

	elseif(self.stance == "ice_kids") then
		weight = 0.9;
	end

	if(System.options.version == "kids") then
		local arena_id = self.arena_id;
		if(arena_id) then
			local side = self:GetSide();
			local arena = Arena.GetArenaByID(arena_id)
			if(arena) then
				local friendlys, hostiles = arena:GetFriendlyAndHostileUnits(side);
				local _, unit_struct;
				for _, unit_struct in ipairs(friendlys) do
					local unit = Arena.GetCombatUnit(unit_struct.isMob, unit_struct.id)
					if(unit and unit:GetStance() == "fire_kids") then
						weight = weight * 1.15;
						-- only apply one siblin effect
						break;
					end
				end
			end
		end
	end

	return weight;
end

-- get final receive damage weight
function Player:GetReceiveDamageFinalWeight(school)
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
		local extra_weight = 0;
		if(System.options.version == "teen") then
			extra_weight = 0.3;
		else
			extra_weight = 0.25;
		end
		-- recalculate receive damage weight with extra defence applied
		weight = weight * (1 - extra_weight);
		if(weight < 0) then
			-- prevent negative resist
			weight = 0;
		end
	elseif(self.stance == "fire_kids" or self.stance == "storm_kids" or self.stance == "life_kids" or self.stance == "death_kids") then
		local extra_weight = 1.1;
		-- recalculate receive damage weight with extra damage applied
		weight = weight * extra_weight;
		if(weight < 0) then
			-- prevent negative resist
			weight = 0;
		end
	end

	if(System.options.version == "kids") then
		local arena_id = self.arena_id;
		if(arena_id) then
			local side = self:GetSide();
			local arena = Arena.GetArenaByID(arena_id)
			if(arena) then
				local friendlys, hostiles = arena:GetFriendlyAndHostileUnits(side);
				local _, unit_struct;
				for _, unit_struct in ipairs(friendlys) do
					local unit = Arena.GetCombatUnit(unit_struct.isMob, unit_struct.id)
					if(unit and unit:GetStance() == "ice_kids") then
						weight = weight * 0.9;
						-- only apply one siblin effect
						break;
					end
				end
			end
		end
	end
	return weight;
end

-- get threat generation final weight
function Player:GetGenerateThreatFinalWeight()
	if(self.stance == "defensive") then
		if(System.options.version == "teen") then
			return 2;
		end
		return 3;
	elseif(self.stance == "taunt") then
		return 5;
	end
	return 1;
end

-- validate freeze rounds
function Player:ValidateFreezeRounds()
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

-- validate freeze rounds
function Player:ValidateControlRounds()
	if(self.control_rounds and self.control_rounds > 0) then
		self.control_rounds = self.control_rounds - 1;
	end
end

-- validate standing effect rounds, including charms, wards and overtime effects
function Player:ValidateStandingEffects()
	local i;
	for i = 1, #self.standing_wards do
		local each_ward = self.standing_wards[i];
		if(each_ward and each_ward.id and each_ward.id ~= 0 and each_ward.rounds and each_ward.rounds > 0) then
			each_ward.rounds = each_ward.rounds - 1;
			if(System.options.version == "kids" and each_ward.id == reflection_shield_id and each_ward.rounds == 0) then
				self.reflect_amount = 0;
			end
		end
	end
end

-- get over time effect value string, including DoT and HoT
-- NOTE: latest applied over time effect comes first
function Player:GetOverTimeValue()
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
	if((tonumber(self:GetNID()) or 0) < 0 and self.turns_played and self.turns_played >= 2) then
		-- immune to kickpet
		value = "immunekickpet_"..self.turns_played.."_0,"..value;
	end
	if(System.options.version == "teen") then
		local __, equip_gsid;
		for __, equip_gsid in pairs(self.equips) do
			local gsItem = PowerItemManager.GetGlobalStoreItemInMemory(equip_gsid);
			if(gsItem) then
				local position = gsItem.template.inventorytype;
				if(position >= 91 and position <= 129) then
					value = "pill_1_"..equip_gsid..","..value;
				end
			end
		end
	end
	if(System.options.version == "kids") then
		-- ward:86
		if(self.remedy.deadlyAttack_protect_rounds > 0) then
			value = "deadlyattackprotectrounds_"..self.remedy.deadlyAttack_protect_rounds.."_0,"..value;
		end
		-- ward:87
		if(self.remedy.absoluteDefense_protect_rounds > 0) then
			value = "absolutedefenseprotectrounds_"..self.remedy.absoluteDefense_protect_rounds.."_0,"..value;
		end
	end
	if(System.options.version == "kids") then
		if(self.remaining_round_weakbuff_base and self.remaining_round_weakbuff_delta) then
			local arena_id = self.arena_id;
			if(arena_id) then
				local arena = Arena.GetArenaByID(arena_id)
				if(arena and arena.mode == "free_pvp") then
					-- NOTE: minor half round fix for far side players
					local damageboost = self.remaining_round_weakbuff_base + self.remaining_round_weakbuff_delta * math_floor((MAX_ROUNDS_PVP_ARENA - arena.nRemainingRounds - 1) / 2);
					if(damageboost > 0) then
						value = "remainingroundweakbuff_"..damageboost.."_0,"..value;
					end
				end
			end
		end
	end
	return value;
end

-- get the absorb order list
-- @return: {[10] = 300, [15] = 450}
function Player:GetAbsorbs()
	return self.absorbs;
end

-- get obsorb point of the given ordered absorb
-- @param order: index into self.absorb, nil if no absorb exist
function Player:GetAbsorbPtsByOrder(order)
	return self.absorbs[order];
end

-- set obsorb point of the given ordered absorb
-- @param order: index into self.absorb
-- @param absorb_pts_new: new absorb points
function Player:SetAbsorbPtsByOrder(order, absorb_pts_new)
	if(self.absorbs[order] and self.wards[order] and self.wards[order] > 0) then
		self.absorbs[order] = absorb_pts_new;
	else
		LOG.std(nil, "error", "player_server", "Player:SetAbsorbPtsByOrder got invalid input: "..commonlib.serialize({order, absorb_pts_new}));
		LOG.std(nil, "error", "player_server", "Player:SetAbsorbPtsByOrder with absorbs: "..commonlib.serialize({self.absorbs}));
	end
end

-- pop absorb ward by order
-- NOTE: both the absorbs and ward will be removed
-- @param order: index into self.absorb
function Player:PopAbsorbByOrder(order)
	if(self.absorbs[order] and self.wards[order] and self.wards[order] > 0) then
		self.wards[order] = 0;
		self.absorbs[order] = nil;
	else
		LOG.std(nil, "error", "player_server", "Player:PopAbsorbByOrder got invalid input: "..commonlib.serialize({order, absorb_pts_new}));
		LOG.std(nil, "error", "player_server", "Player:PopAbsorbByOrder with absorbs: "..commonlib.serialize({self.absorbs}));
	end
end

---- is player prismed
--function Player:IsPrismed()
	--local i;
	--for i = 1, #self.charms do
		--if(self.charms[i] > 0) then
			--local charm_template = Card.GetCharmTemplate(self.charms[i]);
			--if(charm_template.focus_prism == true or charm_template.focus_prism == "true") then
				--return true;
			--end
		--end
	--end
	--return false;
--end

-- active combat
function Player:ActiveCombat()
	if(self.bCombatActive ~= true and not self.bResyncCombatItems and self.nid and (tonumber(self.nid) or 0) > 0) then
		log("error: sync combat items after combat active player nid:"..tostring(self.nid).."\n")
	end
	self.bCombatActive = true;
end

-- if the combat is active
function Player:IsCombatActive()
	if(self.bCombatActive == true) then
		return true;
	end
	return false;
end

-- on heart beat
function Player:OnHeartBeat()
	-- set last hear beat time
	self.nLastHeartBeatTime = combat_server.GetCurrentTime();
	-- reset heart pace fail counter
	self.nHeartPaceMakeFailCounter = 0;
end

-- is heart arrest
function Player:IsHeartArrest()
	if((combat_server.GetCurrentTime() - self.nLastHeartBeatTime) > heartarrest_timeout) then
		if(self.last_isheartarrest == false) then
			-- post log for heart arrest player
			combat_server.AppendPostLog( {
				action = "user_heartarrest", 
				nid = self:GetNID(),
				duration = combat_server.GetCurrentTime() - self.nLastHeartBeatTime,
			});
		end
		self.last_isheartarrest = true;
		return true;
	end
	self.last_isheartarrest = false;
	return false;
end

-- if player picked card
function Player:IfPickedCard()
	if(self.picked_card_key) then
		return true;
	end
	return false;
end

-- if player has shield against damage_school
-- NOTE: damage_school could be nil, means only check global shields
function Player:IfHasShield(damage_school, bSkipGlobalShield)
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
function Player:GetSpecificCharmCount(type, school)
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
function Player:GetSpecificWardCount(type, school)
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

-- if player has defend miniaura
function Player:IfHasDefendMiniaura(damage_school)
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

-- pick card
function Player:PickCard(card_key, card_seq, isMob, id, isAutoAICard, speakword)
	self.picked_card_key = card_key;
	self.picked_card_seq = card_seq;
	self.picked_card_target_ismob = isMob;
	self.picked_card_target_id = id;
	self.picked_card_speakword = speakword;

	if(isAutoAICard) then
		local arena_id = self.arena_id;
		if(arena_id) then
			local arena = Arena.GetArenaByID(arena_id)
			if(arena and arena.AutoCombatNIDs) then
				arena.AutoCombatNIDs[self:GetID()] = true;
			end
		end
	end
end

-- get picked card
function Player:GetPickedCard()
	return self.picked_card_key, self.picked_card_seq, self.picked_card_target_ismob, self.picked_card_target_id;
end

-- clear picked card
function Player:ClearPickedCard()
	self.picked_card_key = nil;
	self.picked_card_seq = nil;
	self.picked_card_target_ismob = nil;
	self.picked_card_target_id = nil;
	self.picked_card_speakword = nil;
	
	local arena_id = self.arena_id;
	if(arena_id) then
		local arena = Arena.GetArenaByID(arena_id)
		if(arena and arena.AutoCombatNIDs) then
			arena.AutoCombatNIDs[self:GetID()] = nil;
		end
	end
end

-- if finished play turn
function Player:IfFinishedPlayTurn()
	if(self.isPlayTurnFinished) then
		return true;
	end
	return false;
end

-- finish play turn
function Player:FinishPlayTurn()
	self.isPlayTurnFinished = true;
end

-- clear picked card
function Player:ClearFinishPlayTurn()
	self.isPlayTurnFinished = nil;
end

-- clear picked card
function Player:IsCardAvailableInDeck(spell_key, card_seq)
	if(not spell_key or not card_seq) then
		return false;
	end
	-- check rune card
	if(card_seq == 0) then
		if(System.options.version == "teen") then
			-- all rune allow use in combat 2015.3.17
			-- 2016.6.16  LiXizhi: THIS IS REALLY WRONG, needs to check player's bag to see if it is a rune card owned by the user
			return true;
		else
			if(self.deck_struct_rune and self.deck_struct_rune[spell_key]) then
				return true;
			end
			return false;
		end
	end
	-- check deck and followpet cards
	if(card_seq >= 10000) then
		card_seq = card_seq - 10000;
		if(self.deck_followpet_card_sequence[card_seq] == spell_key and self.deck_followpet_card_mapping[card_seq] == 1) then
			return true;
		end
	else
		if(self.deck_card_sequence[card_seq] == spell_key and self.deck_card_mapping[card_seq] == 1) then
			return true;
		end
	end
	return false;
end

-- use card to generate damage or heal, 
-- @param arena: arena object
-- @param sequence: spell play sequence of the turn, each spell play is appended to the table
-- @return: bCasted
function Player:UseCard(arena, sequence)
	local picked_card_key = self.picked_card_key;
	local picked_card_seq = self.picked_card_seq;
	if(not picked_card_key) then
		return false;
	end
	-- break stealth if pick any valid card
	if(string_lower(tostring(picked_card_key)) ~= "pass") then
		self.stealth = nil;
	end
	
	-- player speak word
	if(self.picked_card_speakword) then
		local spell_str = "speak:"..self.arena_id..",false,"..self:GetID()..","..self:GetPhase().."[]".."["..self.picked_card_speakword.."]";
		table_insert(sequence, spell_str);
		sequence.duration = sequence.duration + DEFAULT_SPEAK_DURATION;
	end

	-- user the player card
	local bCasted, pips_realcost = Card.UseCard(
					picked_card_key,
					picked_card_seq,
					arena,
					{
						isMob = false,
						id = self:GetNID(),
					}, 
					{
						isMob = self.picked_card_target_ismob,
						id = self.picked_card_target_id,
					}, 
					sequence);
	if(bCasted and (picked_card_key == "CatchPet_12055" or picked_card_key == "CatchPet_12056")) then
		local catchpetitem_gsid;
		if(picked_card_key == "CatchPet_12055") then
			catchpetitem_gsid = 12055;
		elseif(picked_card_key == "CatchPet_12056") then
			catchpetitem_gsid = 12056;
		end
		if(catchpetitem_gsid) then
			local has_item, guid_item = PowerItemManager.IfOwnGSItem(self:GetNID(), catchpetitem_gsid);
			if(has_item) then
				-- destroy catch pet item if available
				local items = {[guid_item] = 1};
				PowerItemManager.DestroyItemBatch(self:GetNID(), items, function(msg) end);
			end
		end
	elseif(bCasted and pips_realcost) then
		table.insert(self.card_history, {
			key = picked_card_key,
			pips_realcost = pips_realcost,
			target_ismob = self.picked_card_target_ismob,
			target_id = self.picked_card_target_id,
		});
		local isFromEquipDeck = false;
		local isFromPetDeck = false;
		if(picked_card_seq) then
			if(self.deck_card_sequence[picked_card_seq] == picked_card_key) then
				-- marked as used
				self.deck_card_mapping[picked_card_seq] = -2;
				isFromEquipDeck = true;
			elseif(self.deck_followpet_card_sequence[picked_card_seq - 10000] == picked_card_key) then
				-- marked as used
				self.deck_followpet_card_mapping[picked_card_seq - 10000] = -1;
				isFromPetDeck = true;
			end
		end

		-- NOTE: use shared cooldown among card keys with the same spellname for teen
		-- NOTE: use shared cooldown among card keys with the same spellname AND specified in share_cooldown_card_keys_for_kids for kids
		local card_keys = Card.GetSharedCoolDownCardKeys(picked_card_key);
		if(not card_keys) then
			if(picked_card_key) then
				card_keys = {[picked_card_key] = true};
			end
		end
		if(card_keys) then
			local key, _;
			for key, _ in pairs(card_keys) do
				local card_template = Card.GetCardTemplate(key);
				if(card_template) then
					if(type(card_template.params.cooldown) == "number") then
						self.cooldown_record[key] = card_template.params.cooldown + 1;
					end
				end
			end
		end
		
		---- electric buff rounds
		--if(self:GetStance() == "electric" and string.find(string.lower(picked_card_key), "attack") and self.electric_rounds) then
			--if(self.electric_rounds == 0) then
				---- init
				--if(math.mod(pips_realcost, 2) == 0) then
					--self.electric_rounds = 1;
				--else
					--self.electric_rounds = -1;
				--end
			--elseif(self.electric_rounds > 0) then
				---- last spell is even cost spell
				--if(math.mod(pips_realcost, 2) ~= 0) then
					--self.electric_rounds = -self.electric_rounds - 1;
				--end
			--elseif(self.electric_rounds < 0) then
				---- last spell is odd cost spell
				--if(math.mod(pips_realcost, 2) == 0) then
					--self.electric_rounds = -self.electric_rounds + 1;
				--end
			--end
		--end
		--
		--if(self:GetStance() ~= "electric") then
			--self.electric_rounds = 0;
		--end

		-- cost the card if successfully casted
		if(string.find(string.lower(picked_card_key), "rune") and isFromEquipDeck == false and isFromPetDeck == false) then
			local gsid = Card.Get_rune_gsid_from_cardkey(picked_card_key)
			if(gsid) then
				local has_rune, guid_rune = PowerItemManager.IfOwnGSItem(self:GetNID(), gsid);
				if(has_rune) then
					-- destroy rune card if available
					local items = {[guid_rune] = 1};
					PowerItemManager.DestroyItemBatch(self:GetNID(), items, function(msg) end);
				end
			end
		end
	else
		if(picked_card_seq) then
			if(self.deck_card_sequence[picked_card_seq] == picked_card_key) then
				-- marked as fizzled
				self.deck_card_mapping[picked_card_seq] = -3;
				-- pend the key to the tail of the deck sequence for future use
				table.insert(self.deck_card_sequence, picked_card_key);
				table.insert(self.deck_card_mapping, 0);
			end
		end
	end
	
	-- post use card process
	Card.UseCard_post(
		picked_card_key,
		arena,
		{
			isMob = false,
			id = self:GetNID(),
		}, 
		{
			isMob = self.picked_card_target_ismob,
			id = self.picked_card_target_id,
		}, 
		sequence);
	return bCasted;
end

function Player:BeAFK()
	if(self.nIdleRounds >= nMaxIdleRounds or self.accumulateIdleRounds >= maxAccumulateIdleRounds) then
		self.afk = true;
		return true;
	else
		self.afk = false;
		return false;
	end
end

function Player:HasReachMaxIdleRounds()
	if(self.nIdleRounds >= nMaxIdleRounds) then
		return true;
	else
		return false;
	end
end

function Player:HasReachMaxAccumulateIdleRounds()
	if(self.accumulateIdleRounds >= maxAccumulateIdleRounds) then
		return true;
	else
		return false;
	end
end

function Player:GetMaxIdleRounds()
	return nMaxIdleRounds or 3;
end

function Player:GetMaxAccumulateIdleRounds()
	return maxAccumulateIdleRounds or 3;
end

-- the warning only note one times;
function Player:NeedSendIdleRoundsWarning()
	if(self.idleRoundsNote["nIdleRounds"][self.nIdleRounds] ~= nil and self.idleRoundsNote["nIdleRounds"][self.nIdleRounds] == true) then
		self.idleRoundsNote["nIdleRounds"][self.nIdleRounds] = false;
		return true;
	end
	return false;
end
-- the warning only note one times;
function Player:NeedSendAccumulateIdleRoundsWarning()
	if(self.idleRoundsNote["accumulateIdleRounds"][self.accumulateIdleRounds] ~= nil and self.idleRoundsNote["accumulateIdleRounds"][self.accumulateIdleRounds] == true) then
		self.idleRoundsNote["accumulateIdleRounds"][self.accumulateIdleRounds] = false;
		return true;
	end
	return false;
end
