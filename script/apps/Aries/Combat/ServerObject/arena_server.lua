--[[
Title: combat system arena server for Aries App
Author(s): WangTian
Date: 2009/4/7
Area: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Combat/ServerObject/arena_server.lua");
------------------------------------------------------------
]]
local format = format;
local pairs = pairs;
local ipairs = ipairs;
local tostring = tostring;
local tonumber = tonumber;
local type = type
local table_insert = table.insert;
local log = log;
local LOG = LOG;
local math_mod = math.mod;
local math_floor = math.floor;
local math_min = math.min;
local math_max = math.max;

-- create class
local Arena = commonlib.gettable("MyCompany.Aries.Combat_Server.Arena");

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

local GSL_gateway = commonlib.gettable("Map3DSystem.GSL.gateway");

NPL.load("(gl)script/kids/3DMapSystemItem/PowerItemManager.lua");
local PowerItemManager = commonlib.gettable("Map3DSystem.Item.PowerItemManager");

NPL.load("(gl)script/apps/Aries/Quest/QuestProvider.lua");
local QuestServerLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestServerLogics");

NPL.load("(gl)script/apps/GameServer/BattlefieldService/GSL_BattleServer.lua");

NPL.load("(gl)script/apps/GameServer/GSL_system.lua");

NPL.load("(gl)script/ide/MotionEx/MotionXmlToTable.lua");
local MotionXmlToTable = commonlib.gettable("MotionEx.MotionXmlToTable");

NPL.load("(gl)script/apps/Aries/GoldRankingList/ranking_server.lua");
local RankingServer = commonlib.gettable("MyCompany.Aries.GoldRankingList.RankingServer");

NPL.load("(gl)script/apps/GameServer/LobbyService/GSL_LobbySharedLoot.lua");
local SharedLoot = commonlib.gettable("Map3DSystem.GSL.Lobby.SharedLoot");

-- base arena id
local base_arena_id = 1001;

-- max player count per arena
local max_player_count_per_arena = 4;

-- max unit count on each arena side
local max_unit_count_per_side_arena = 4;

-- max pick card time out time
local pickcard_timeout_time = 30000;

-- max pick card time out time for pvp arena
local pickcard_timeout_time_pvp = 30000;

-- max spell play time
local spellplay_timeout_time = 60000;

-- max spell play time per spell
local spellplay_timeout_time_per_spell = 6000;

-- move arrow spell duration
local movearrow_spell_duration = 200;

-- base per turn delay
local base_per_turn_delay = 5000;

-- the times can get 3v3 score per day 
--local pvp_3v3_score_times_per_day;

-- prepare time of first arena turn
local arenastart_prepare_time_pve_single = 1000;
local arenastart_prepare_time_pve_teamed = 5000;
local arenastart_prepare_time_pvp = 5000;

-- max pvp arena rounds
local MAX_ROUNDS_PVP_ARENA = 100;
-- max pvp arena rounds
local MAX_ROUNDS_PVP_ARENA_BATTLEFIELD = 10000;

-- rune card and spell offset
local RUNE_SPELL_OFFSET = 1000;

-- starting achievement round
local STARTING_ACHIEVEMENT_ROUND = 10000;

-- maximum rune count per user   
-- now we allow use all rune in combat   --- 2015.3.18 lipeng
local MAX_RUNE_COUNT = 8;

-- default playturn motion duration
local DEFAULT_PLAYTURN_MOTION_DURATION = 10000;

-- default halt milliseconds
local DEFAULT_HALT_MILLISECONDS = 1000;

-- default speak duration
local DEFAULT_SPEAK_DURATION = 1000;

-- plain addition loot 
local PlainAdditionalLootWhiteList = {};

-- mob ai names
local MobAINames = {};

-- all arenas
local arenas = {};

-- debug purpose
-- NOTE: debug every frame of the combat state machine
local debug_dump_arena_id = 1001;
-- NOTE: debug every core step of the combat state machine
local debug_dump_every_step = true;
-- NOTE: debug every frame of the combat state machine
local debug_dump_per_frame = false;
-- NOTE: debug keep comabt alive if only minion players left
local DEBUG_KEEPCOMBAT_ALIVE_IF_ONLY_MINION_LEFT = false;

-- NOTE: teen version ONLY
-- some spell don't require combat school or secondary school match
local SchoolIrrelevant_GSIDs = {
	[22120] = true, -- 22120_Fire_FireGreatShield
	[22157] = true, -- 22157_Ice_IceGreatShield
	[22138] = true, -- 22138_Storm_StormGreatShield
	[22180] = true, -- 22180_Life_LifeGreatShield
	[22199] = true, -- 22199_Death_DeathGreatShield
	[22142] = true, -- 22142_Balance_GlobalShield

	[41120] = true, -- 41120_Fire_FireGreatShield_Green
	[41157] = true, -- 41157_Ice_IceGreatShield_Green
	[41138] = true, -- 41138_Storm_StormGreatShield_Green
	[41180] = true, -- 41180_Life_LifeGreatShield_Green
	[41199] = true, -- 41199_Death_DeathGreatShield_Green
	[41142] = true, -- 41142_Balance_GlobalShield_Green

	[42120] = true, -- 42120_Fire_FireGreatShield_Blue
	[42157] = true, -- 42157_Ice_IceGreatShield_Blue
	[42138] = true, -- 42138_Storm_StormGreatShield_Blue
	[42180] = true, -- 42180_Life_LifeGreatShield_Blue
	[42199] = true, -- 42199_Death_DeathGreatShield_Blue
	[42142] = true, -- 42142_Balance_GlobalShield_Blue

	[43120] = true, -- 43120_Fire_FireGreatShield_Purple
	[43157] = true, -- 43157_Ice_IceGreatShield_Purple
	[43138] = true, -- 43138_Storm_StormGreatShield_Purple
	[43180] = true, -- 43180_Life_LifeGreatShield_Purple
	[43199] = true, -- 43199_Death_DeathGreatShield_Purple
	[43142] = true, -- 43142_Balance_GlobalShield_Purple

	[44120] = true, -- 44120_Fire_FireGreatShield_Orange
	[44157] = true, -- 44157_Ice_IceGreatShield_Orange
	[44138] = true, -- 44138_Storm_StormGreatShield_Orange
	[44180] = true, -- 44180_Life_LifeGreatShield_Orange
	[44199] = true, -- 44199_Death_DeathGreatShield_Orange
	[44142] = true, -- 44142_Balance_GlobalShield_Orange
};

-- self only keys
local base_self_only_keys_kids = {
	["Ice_ReflectionShield"] = true,
	["Ice_Rune_ReflectionShield"] = true,
	["Ice_Absorb_LevelX"] = true,
	["Ice_DefensiveStance"] = true,
	["Ice_Rune_DefensiveStance"] = true,
	["Balance_Rune_TauntStance"] = true,
	["Life_FuryStance"] = true,

	["Life_HealingStance"] = true,
	["Fire_BlazingStance"] = true,
	["Storm_ElectricStance"] = true,
	["Ice_PierceStance"] = true,
	["Death_VampireStance"] = true,
};

-- self only keys
local base_self_only_keys_teen = {
	["Ice_Absorb_LevelX"] = true,
	["Ice_DefensiveStance"] = true,
	["Ice_Rune_DefensiveStance"] = true,
	["Balance_Rune_TauntStance"] = true,
	["Life_FuryStance"] = true,

	["Life_HealingStance"] = true,
	["Fire_BlazingStance"] = true,
	["Storm_ElectricStance"] = true,
	["Ice_PierceStance"] = true,
	["Death_VampireStance"] = true,
};

local self_only_keys_kids = {};
local base_name, _;
for base_name, _ in pairs(base_self_only_keys_kids) do
	self_only_keys_kids[base_name] = true;
end

local self_only_keys_teen = {};
local base_name, _;
for base_name, _ in pairs(base_self_only_keys_teen) do
	self_only_keys_teen[base_name] = true;
	self_only_keys_teen[base_name.."_Green"] = true;
	self_only_keys_teen[base_name.."_Blue"] = true;
	self_only_keys_teen[base_name.."_Purple"] = true;
	self_only_keys_teen[base_name.."_Orange"] = true;
end

-- 3v3 tickets
local tickets_3v3 = {50420,52109};

-- pvp forbidden keys
local pvp_forbidden_keys = {
};

-- instance forbidden keys
local instance_forbidden_keys = {
};
-- only can use in battlefield 
local forbidden_keys_expect_battlefield = {
};
-- prior auto ai card
local prior_auto_ai_card_lower_areaattack_weight = {
};

-- this only be used in "kids" version
local pvp_arena_ranking_point_gsid = {};

local function loadPVPPointGSIDForConfigFile()
	local file = "config/Aries/Combat/PVPGrearScoreRankPointGSID.xml";
	local xmlRoot = ParaXML.LuaXML_ParseFile(file);
	if(not xmlRoot) then
	    LOG.std(nil, "error", "arena_server", "file %s does not exist", file);
	else
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

function Arena.GetPVPPointGSID(arena_rank_stage,result)
	local beWinner;
	if(result == "win") then
		beWinner = true;
	elseif(result == "lose") then
		beWinner = false;
	end
	local point_gsid;
	if(not next(pvp_arena_ranking_point_gsid)) then
		loadPVPPointGSIDForConfigFile();
	end
	local type,gearscore = string.match(arena_rank_stage,"(.*)_(%d*)");
	if(gearscore and type) then
		gearscore = tonumber(gearscore);
		local type_table = pvp_arena_ranking_point_gsid[type];
		for i=1,#type_table do
			local item = type_table[i];
			if((not item.min_gs) or (item.min_gs and gearscore >= item.min_gs)) then
				if((not item.max_gs) or (item.max_gs and gearscore <= item.max_gs)) then
					if(item.win_gsid and item.lose_gsid) then
						point_gsid = if_else(beWinner,item.win_gsid,item.lose_gsid)
						break;
					end
				end	
			end		
		end
	end
	if(not point_gsid) then
		point_gsid = if_else(beWinner,20079,20080)
	end
	return point_gsid;
end

local bInitConstants = false;
function Arena.InitConstantsIfNot()
	if(not bInitConstants) then
		if(System.options.version == "teen") then
			MAX_ROUNDS_PVP_ARENA = 80;
			STARTING_ACHIEVEMENT_ROUND = 100000000;
		else
			MAX_ROUNDS_PVP_ARENA = 100;
			
			pvp_forbidden_keys = {
				["Balance_Rune_AreaAttackCard_Elementary"] = true,
				["Balance_Rune_AreaAttackCard_Middle"] = true,
				["Balance_Rune_AreaAttackCard_High"] = true,
			};
			instance_forbidden_keys = {
			};
			forbidden_keys_expect_battlefield = {
				["Balance_Rune_SingleHealWithCleanse_Lv4"] = true,
				["Balance_Rune_AreaAttackWithImmolate_Lv5"] = true,
				["Balance_Rune_SingleAttackWithStun_Lv5"] = true,
				["Balance_Rune_SingleAttackWithSelfStun_Lv5"] = true,
			};
			prior_auto_ai_card_lower_areaattack_weight = {
				["balance_rune_areaattackcard_elementary"] = 1001,
				["balance_rune_areaattackcard_middle"] = 1002,
				["balance_rune_areaattackcard_high"] = 1003,
			};
		end

		PlainAdditionalLootWhiteList = {};
		local config_file = "config/Aries/PlainAdditionalLootWhiteList.xml";
		if(System.options.version == "teen") then
			config_file = "config/Aries/PlainAdditionalLootWhiteList.teen.xml";
		end
		local xmlRoot = ParaXML.LuaXML_ParseFile(config_file);
		if(not xmlRoot) then
			LOG.std(nil, "error", "arena_server", "file %s does not exist", config_file);
		else
			for each_item in commonlib.XPath.eachNode(xmlRoot, "/whitelist/item") do
				local gsid = each_item.attr.gsid;
				if(gsid) then
					gsid = tonumber(gsid);
					PlainAdditionalLootWhiteList[gsid] = true;
				end
			end
		end

		MobAINames = {};
		local config_file;
		if(System.options.version == "teen") then
			config_file = "config/Aries/Combat/MobAINames.teen.xml";
		end
		if(config_file) then
			local xmlRoot = ParaXML.LuaXML_ParseFile(config_file);
			if(not xmlRoot) then
				LOG.std(nil, "error", "arena_server", "file %s does not exist", config_file);
			else
				local each_item;
				for each_item in commonlib.XPath.eachNode(xmlRoot, "/MobAINames/ainame") do
					local name = each_item.attr.name;
					if(name) then
						table.insert(MobAINames, name);
					end
				end
			end
		end
		if(System.options.version == "kids") then
			loadPVPPointGSIDForConfigFile();
		end
	end
	bInitConstants = true;
end

-- get base player param
local function GetBasePlayerParam()
	return {
		nid = 100,
		current_hp = 1234,
		max_hp = 1234,
		phase = "death",
		petlevel = 10,
		deck_gsid = 0,
		deck_struct = {},
		deck_struct_equip = {},
		deck_struct_rune = {},
		deck_struct_pet = {},
		equips = {},
		gems = {},
		current_followpet_guid = 0,
		followpet_history = {},
		loot_scale = 1,
		isoverweight = false,
		addonlevel_damage_percent = 0,
		addonlevel_damage_absolute = 0,
		addonlevel_resist_absolute = 0,
		addonlevel_hp_absolute = 0,
		addonlevel_criticalstrike_percent = 0,
		addonlevel_resilience_percent = 0,
		dragon_totem_profession_gsid = 0,
		dragon_totem_exp_gsid = 0,
		dragon_totem_exp_cnt = 0,
		user_team_aura = nil,
	};
end

-- constructor
-- @param o: typical arena params including:
--			position: x, y, z
--			ai_module: AI_Module object
function Arena:new(o)
	
	Arena.InitConstantsIfNot();
	
	-- each arena is running in one of the the following modes:
	--		pve: default mode, the includes 4 mobs and 4 players on maximum on each side
	--		free_pvp: free pvp mode, allows random number of players on each side

	o = o or {};   -- create object if user does not provide one
	if(not o.mode) then
		o.mode = "pve"; -- default pve mode arena
	end

	-- init each side of player or mobs
	if(not o.mob_ids) then
		o.mob_ids = {};
	end
	if(not o.player_nids) then
		o.player_nids = {};
	end

	-- automatically set the arena id
	o.id = base_arena_id;
	base_arena_id = base_arena_id + 1;
	setmetatable(o, self);
	self.__index = self;
	-- keep a mob reference
	arenas[o.id] = o;
	return o
end

-- get arena by id
function Arena.GetArenaByID(id)
	return arenas[id];
end

-- get arena id
function Arena:GetID()
	return self.id;
end

-- dump arena data to log file
function Arena:Dump(tag,key,before_or_after)
	LOG.std(nil, "user","arena","arena_id=%d|tag:%s",self:GetID(),commonlib.serialize_compact(tag));
	if(self:IsPlayerSlotEmpty()) then
		--log("============ arena "..self:GetID().." dump empty players ============\n");
		--LOG.std(nil, "user","arena","arena_id=%d|dump empty players", self:GetID());
	else
		--commonlib.echo(tag);
		if(key and before_or_after) then
			LOG.std(nil, "user","arena","arena_id=%d|%s %s",self:GetID(),before_or_after,key);
		end

		local curTime = combat_server.GetCurrentTime();
		local progress = "";
		if(not self.nCombatStartTime) then
			progress = "just_enter_combat";
		else
			if(self.PickCardTimeOutTime and not self.PlayTurnTimeOutTime) then
				progress = "pickcard_remining_"..(self.PickCardTimeOutTime - curTime);
			elseif(not self.PickCardTimeOutTime and self.PlayTurnTimeOutTime) then
				progress = "playturn_remining_"..(self.PlayTurnTimeOutTime - curTime);
			elseif(self.nCombatStartTime and not self.PickCardTimeOutTime and not self.PlayTurnTimeOutTime) then
				progress = "waiting_to_start";
			else
				progress = "UNKNOWN_"..format("nCombatStartTime=%s,PickCardTimeOutTime=%s,PlayTurnTimeOutTime=%s", tostring(self.nCombatStartTime), tostring(self.PickCardTimeOutTime), tostring(self.PlayTurnTimeOutTime));
			end
		end

		-- recursive grid node reference will cause dump
		local gridnode = self.gridnode;
		self.gridnode = nil;
		local log_msg = format("seq=%d,MobFirst=%s,fled_slots=%s,%s,respawn_interval=%d,___raw==%s", 
			self.seq or -1,
			tostring(self.isNearArenaFirst),
			commonlib.serialize_compact(self.fled_slots),
			progress,
			self.respawn_interval or -1,
			commonlib.serialize_compact(self)
		);
		self.gridnode = gridnode;

		--log("============ arena "..self:GetID().." dump info ============\n")
		--log("current time: "..combat_server.GetCurrentTime().."\n");
		LOG.std(nil, "user","arena","arena_id=%d|arena:%s",self:GetID(),log_msg);

		--log("+++++ mobs: +++++\n");
		local index, id;
		for index, id in ipairs(self.mob_ids) do
			local mob = Mob.GetMobByID(id);
			local log_msg = format("id=%d,pips_n=%d,pips_p=%d,pos=%d,hp=%s,phase=%s,charms=%s,wards=%s,DOTs=%s,HOTs=%s,template_key=%s,___raw==%s", 
				mob.id or -1,
				mob.pips_normal or -1,
				mob.pips_power or -1,
				mob.arrow_cast_position or -1,
				(mob.current_hp or -1).."/"..(mob:GetMaxHP() or -1),
				mob:GetPhase() or "~",
				commonlib.serialize_compact(mob.charms),
				commonlib.serialize_compact(mob.wards),
				commonlib.serialize_compact(mob.DOTs),
				commonlib.serialize_compact(mob.HOTs),
				mob.template_key or "~",
				commonlib.serialize_compact(mob)
			);
			LOG.std(nil, "user","arena","arena_id=%d|mob:%s",self:GetID(),log_msg);
		end
		--log("+++++ players: +++++\n");
		local slot_id = 1;
		for slot_id = 1, max_player_count_per_arena * 2 do
			local player = self:GetPlayerCombatObjBySlotID(slot_id);
			if(player) then
				local log_msg = format("nid=%s,pips_n=%d,pips_p=%d,pos=%d,hp=%s,phase=%s,charms=%s,wards=%s,DOTs=%s,HOTs=%s,petlevel=%d,HeartBeat %d ago failed %d times,turns_played=%d,___raw==%s", 
					tostring(player.nid) or "-1",
					player.pips_normal or -1,
					player.pips_power or -1,
					player.arrow_cast_position or -1,
					(player.current_hp or -1).."/"..(player.max_hp or -1),
					player.phase or "~",
					commonlib.serialize_compact(player.charms),
					commonlib.serialize_compact(player.wards),
					commonlib.serialize_compact(player.DOTs),
					commonlib.serialize_compact(player.HOTs),
					player.petlevel or -1,
					curTime - (player.nLastHeartBeatTime or -1),
					player.nHeartPaceMakeFailCounter or -1,
					player.turns_played or -1,
					commonlib.serialize_compact(player)
				);
				LOG.std(nil, "user","arena","arena_id=%d|player:%s",self:GetID(),log_msg);
			end
		end
	end
end

function Arena:DebugDumpData(tag)
	--if(debug_dump_every_step and self:GetID() == debug_dump_arena_id) then
	if(debug_dump_every_step) then
		self:Dump(tag);
	end
end

function Arena:DebugDumpDataPerFrame(tag)
	--if(debug_dump_per_frame and self:GetID() == debug_dump_arena_id) then
	if(debug_dump_per_frame) then
		self:Dump(tag);
	end
end

function Arena.GetObtainsFromMSG(msg, nid, obtains)
	if(msg.updates) then
		local _, update;
		for _, update in pairs(msg.updates) do
			if( (update.guid and update.guid<=0) or (update.gsid and update.gsid<=0) ) then
				local gsid = update.gsid or update.guid;
				if(gsid == 0 and update.copies) then
					obtains[0] = (obtains[0] or 0) + update.copies;
				elseif(gsid == -19 and update.copies) then
					obtains[-19] = (obtains[-19] or 0) + update.copies;
				elseif(gsid == -20 and update.copies) then
					obtains[-20] = (obtains[-20] or 0) + update.copies;
				end
			elseif(update.guid == -1) then
			elseif(update.guid > 0 and update.gsid and update.gsid > 0) then
				obtains[update.gsid] = (obtains[update.gsid] or 0) + update.cnt;
			else
				local item = PowerItemManager.GetItemByGUID(nid, update.guid);
				if(item and item.gsid and update.cnt) then
					obtains[item.gsid] = (obtains[item.gsid] or 0) + update.cnt;
				end
			end
		end
	end
	if(msg.adds) then
		local _, add;
		for _, add in pairs(msg.adds) do 
			if(add.gsid and add.cnt) then
				obtains[add.gsid] = (obtains[add.gsid] or 0) + add.cnt;
			end
		end
	end
	if(msg.stats) then
		local _, stat;
		for _, stat in pairs(msg.stats) do
			if(stat.gsid == 0 and stat.cnt) then
				obtains[0] = (obtains[0] or 0) + stat.cnt;
			elseif(stat.gsid == -19 and stat.cnt) then
				obtains[-19] = (obtains[-19] or 0) + stat.cnt;
			elseif(stat.gsid == -20 and stat.cnt) then
				obtains[-20] = (obtains[-20] or 0) + stat.cnt;
			end
		end
	end
end

-- get combat unit
-- @param isMob: true for mob, false for player
-- @param id: mob id or player nid
function Arena.GetCombatUnit(isMob, id)
	if(isMob == false) then
		return Player.GetPlayerCombatObj(id);
	elseif(isMob == true) then
		return Mob.GetMobByID(id);
	end
end

-- get combat unit by slot id
-- @param id: 1 to 8
function Arena:GetCombatUnitBySlotID(slot_id)
	local id = self.player_nids[slot_id];
	if(id) then
		return Player.GetPlayerCombatObj(id);
	end
	if(slot_id >= 1 and slot_id <= max_unit_count_per_side_arena) then
		local id = self.mob_ids[slot_id + max_unit_count_per_side_arena];
		if(id) then
			return Mob.GetMobByID(id);
		end
	elseif(slot_id >= (max_unit_count_per_side_arena + 1) and slot_id <= max_unit_count_per_side_arena * 2) then
		local id = self.mob_ids[slot_id - max_unit_count_per_side_arena];
		if(id) then
			return Mob.GetMobByID(id);
		end
	end
end

-- add treasure box
function Arena:AddTreasureBox(treasurebox_table)
	if(self.mode == "pve") then
		self.treasurebox = treasurebox_table;
	else
		LOG.std(nil, "error", "arena", "Arena:AddTreasureBox to non pve arena");
	end
end

-- add match item
function Arena:AddMatchItem(gsid, count)
	if(self.mode == "pve") then
		self.match_items = self.match_items or {};
		table.insert(self.match_items, {gsid = gsid, count = count});
	else
		LOG.std(nil, "error", "arena", "Arena:AddMatchItem to non pve arena");
	end
end

-- add mob object
function Arena:AddMob_pve(mob)
	if(self.mode == "pve") then
		table_insert(self.mob_ids, mob:GetID());
		-- keep arrow cast position
		mob.arrow_cast_position = #(self.mob_ids) + max_player_count_per_arena;
		-- keep an arena id reference
		mob.arena_id = self:GetID();
	else
		LOG.std(nil, "error", "arena", "Arena:AddMob_pve to non pve arena");
	end
end

-- add player object
-- player try to enter pve arena
function Arena:AddPlayer_pve(player, nPreferSlot)
	if(self.mode == "pve") then
		local nEmptySlot = nil;
		if(nPreferSlot and nPreferSlot >= 1 and nPreferSlot <= max_unit_count_per_side_arena) then
			local nid = self.player_nids[nPreferSlot];
			if(not nid and not self.fled_slots[nPreferSlot]) then
				nEmptySlot = nPreferSlot;
			end
		end

		local first_player_followpet_combat_unit_cankick_nid;
		local first_player_followpet_combat_unit_cankick_slotid;
		
		local i;
		for i = 1, max_unit_count_per_side_arena do
			if(not first_player_followpet_combat_unit_cankick_nid and not first_player_followpet_combat_unit_cankick_slotid) then
				local nid = self.player_nids[i];
				if(type(nid)=="number" and nid < 0) then
					local player_followpet = Player.GetPlayerCombatObj(nid);
					if(player_followpet) then
						local turns_played = player_followpet.turns_played or 0;
						if(turns_played < 2) then
							first_player_followpet_combat_unit_cankick_nid = -nid;
							first_player_followpet_combat_unit_cankick_slotid = i;
						end
					end
				end
			end
		end
		
		if(not nEmptySlot) then
			local i;
			for i = 1, max_unit_count_per_side_arena do
				local nid = self.player_nids[i];
				if(not nid and not self.fled_slots[i]) then
					nEmptySlot = i;
					break;
				end
			end
		end
		
		if(self.players_max) then
			local player_and_fled_unit_count = 0;
			local i;
			for i = 1, max_unit_count_per_side_arena do
				if(self.player_nids[i]) then
					player_and_fled_unit_count = player_and_fled_unit_count + 1;
				elseif(self.fled_slots[i]) then
					player_and_fled_unit_count = player_and_fled_unit_count + 1;
				end
			end
			if(player_and_fled_unit_count >= self.players_max) then
				nEmptySlot = nil; -- ArenaSlotsFull
			end
		end

		if(nEmptySlot) then
			-- empty player slot
			self.player_nids[nEmptySlot] = player:GetNID();
			-- keep arrow cast position
			player.arrow_cast_position = nEmptySlot;
			-- keep an arena id reference
			player.arena_id = self:GetID();
			-- reset the lootables
			player.lootables = nil;
			-- reset played turns
			player.turns_played = 0;
			-- set the arena side
			player.side = "near";
			return true;
		else
			if(self.PickCardTimeOutTime and not self.PlayTurnTimeOutTime) then
				-- arena is during pick card period
				if(first_player_followpet_combat_unit_cankick_nid and first_player_followpet_combat_unit_cankick_slotid) then
					-- this pet follow mode
					self:RemovePlayer(-first_player_followpet_combat_unit_cankick_nid, true); -- true for bSkipFleeSlot
					-- tell this player
					combat_server.AppendRealTimeMessageToNID(self.combat_server_uid, first_player_followpet_combat_unit_cankick_nid, "MyCombatPetKicked:1");
					-- empty player slot
					self.player_nids[first_player_followpet_combat_unit_cankick_slotid] = player:GetNID();
					-- keep arrow cast position
					player.arrow_cast_position = first_player_followpet_combat_unit_cankick_slotid;
					-- keep an arena id reference
					player.arena_id = self:GetID();
					-- reset the lootables
					player.lootables = nil;
					-- reset played turns
					player.turns_played = 0;
					-- set the arena side
					player.side = "near";
					-- refresh buddy pick card
					Arena.OnReponse_TellBuddyPickCard(player)
					return true;
				end
			end

			return false, "ArenaSlotsFull";
		end
		return false;
	else
		LOG.std(nil, "error", "arena", "Arena:AddPlayer_pve to non pve arena");
		return false;
	end
end

-- add player object
-- player try to enter pvp arena
-- @param player: player object
-- @param side: arena side "near" or "far"
function Arena:AddPlayer_pvp(player, side, nPreferSlot)
	if(not player or not player.nid) then
		return false;
	end
	if(self.players_max) then
		local i;
		local player_count_near = 0;
		local player_count_far = 0;
		for i = 1, max_unit_count_per_side_arena do
			local nid = self.player_nids[i];
			if(nid) then
				local player = Player.GetPlayerCombatObj(nid);
				-- NOTE 2014/7/14: including non-alive players
				if(player) then
					player_count_near = player_count_near + 1;
				end
			end
			if(self.fled_slots[i]) then
				player_count_near = player_count_near + 1;
			end
		end
		for i = max_unit_count_per_side_arena + 1, max_unit_count_per_side_arena * 2 do
			local nid = self.player_nids[i];
			if(nid) then
				local player = Player.GetPlayerCombatObj(nid);
				-- NOTE 2014/7/14: including non-alive players
				if(player) then
					player_count_far = player_count_far + 1;
				end
			end
			if(self.fled_slots[i]) then
				player_count_far = player_count_far + 1;
			end
		end
		if((player_count_near + player_count_far) >= self.players_max) then
			LOG.std(nil, "error", "arena", "Arena:AddPlayer_pvp exceed max player count");
			return false;
		end
		if(self.players_max_eachside) then
			if(side == "near") then
				if(player_count_near >= self.players_max_eachside) then
					LOG.std(nil, "error", "arena", "Arena:AddPlayer_pvp exceed max each side player near count");
					return false;
				end
			elseif(side == "far") then
				if(player_count_far >= self.players_max_eachside) then
					LOG.std(nil, "error", "arena", "Arena:AddPlayer_pvp exceed max each side player far count");
					return false;
				end
			end
		end
	end
	if(self.mode == "free_pvp") then
		-- check match_info
		if(self.match_info) then
			if(not self.match_info_team1[player.nid] and not self.match_info_team2[player.nid]) then
				LOG.std(nil, "error", "arena", "Arena:AddPlayer_pvp  enter with malicious player that is not in the match_info players");
				return false;
			end
		end
		local lower_region = 1;
		local upper_region = max_unit_count_per_side_arena;
		if(side == "near") then
			lower_region = 1;
			upper_region = max_unit_count_per_side_arena;
		elseif(side == "far") then
			lower_region = max_unit_count_per_side_arena + 1;
			upper_region = max_unit_count_per_side_arena * 2;
		else
			LOG.std(nil, "error", "arena", "Arena:AddPlayer_pvp to invalid side:"..tostring(side));
			return false;
		end
		if(self.entercombat_cost == "RedMushroomArena") then
			local has_12005, guid_12005 = PowerItemManager.IfOwnGSItem(player.nid, 12005);
			local has_12006, guid_12006 = PowerItemManager.IfOwnGSItem(player.nid, 12006);
			local has_40004, guid_40004 = PowerItemManager.IfOwnGSItem(player.nid, 40004);
			if(not has_12005 and not has_12006) then
				-- doesn't have the arena credential
				return false;
			end
			if(not has_40004) then
				-- doesn't have the arena remaining count
				return false;
			end
		elseif(self.entercombat_cost == "RedMushroomArena_Practice") then
			local has_40004, guid_40004 = PowerItemManager.IfOwnGSItem(player.nid, 40004);
			if(not has_40004) then
				-- doesn't have the arena remaining count
				return false;
			end
		elseif(self.entercombat_cost == "TrialOfChampions") then
			-- empty enter combat cost
			-- nothing
		end
		if(self.fled_nids[player.nid]) then
			return false;
		end
		local nEmptySlot = nil;
		if(nPreferSlot) then
			if(side == "far") then
				nPreferSlot = nPreferSlot + max_unit_count_per_side_arena;
			end
		end
		if(nPreferSlot and nPreferSlot >= lower_region and nPreferSlot <= upper_region) then
			local nid = self.player_nids[nPreferSlot];
			if(not nid and not self.fled_slots[nPreferSlot]) then
				nEmptySlot = nPreferSlot;
			end
		end
		if(not nEmptySlot) then
			local i;
			for i = lower_region, upper_region do
				local nid = self.player_nids[i];
				if(not nid and not self.fled_slots[i]) then
					nEmptySlot = i;
					break;
				end
			end
		end

		if(nEmptySlot) then
			-- empty player slot
			self.player_nids[nEmptySlot] = player:GetNID();
			-- keep arrow cast position
			player.arrow_cast_position = nEmptySlot;
			-- keep an arena id reference
			player.arena_id = self:GetID();
			-- reset played turns
			player.turns_played = 0;
			-- set the arena side
			player.side = side;
			-- entercombat cost
			if(self:IsBothSideWithAliveUnit() and self:IsProperPlayerCount()) then
				if(self.entercombat_cost == "RedMushroomArena") then
					-- check all players if cost credential yet
					local slot_id = 1;
					for slot_id = 1, max_unit_count_per_side_arena * 2 do
						local player = self:GetPlayerCombatObjBySlotID(slot_id);
						if(player and player.nid and not player.bCostCredential) then
							-- 12005_ArenaFreeTicket
							-- 12006_ForSaleArenaPvPTicket
							-- 40004_RedMushroomArenaCombatCountRemaining
							local has_12005, guid_12005 = PowerItemManager.IfOwnGSItem(player.nid, 12005);
							local has_12006, guid_12006 = PowerItemManager.IfOwnGSItem(player.nid, 12006);
							local has_40004, guid_40004 = PowerItemManager.IfOwnGSItem(player.nid, 40004);
							if(has_12005) then
								-- mark has cost credential
								player.bCostCredential = true;
								-- destroy free ticket if available
								local items = {[guid_12005] = 1};
								if(has_40004) then
									items[guid_40004] = 1;
								end
								PowerItemManager.DestroyItemBatch(player.nid, items, function(msg) 
									-- tell the client to update hp
									local gridnode = GSL_gateway:GetPrimGridNode(tostring(player.nid));
									if(gridnode) then
										local server_object = gridnode:GetServerObject("sPowerAPI");
										if(server_object) then
											server_object:SendRealtimeMessage(tostring(player.nid), "[Aries][PowerAPI]FullHPAfterPvPTickerCost:1");
										end
									end
								end);
							elseif(has_12006) then
								-- mark has cost credential
								player.bCostCredential = true;
								-- destroy on sale ticket if available
								local items = {[guid_12006] = 1};
								if(has_40004) then
									items[guid_40004] = 1;
								end
								PowerItemManager.DestroyItemBatch(player.nid, items, function(msg) 
									-- tell the client to update hp
									local gridnode = GSL_gateway:GetPrimGridNode(tostring(player.nid));
									if(gridnode) then
										local server_object = gridnode:GetServerObject("sPowerAPI");
										if(server_object) then
											server_object:SendRealtimeMessage(tostring(player.nid), "[Aries][PowerAPI]FullHPAfterPvPTickerCost:1");
										end
									end
								end);
							end
						end
					end
				elseif(self.entercombat_cost == "RedMushroomArena_Practice") then
					-- check all players if cost credential yet
					local slot_id = 1;
					for slot_id = 1, max_unit_count_per_side_arena * 2 do
						local player = self:GetPlayerCombatObjBySlotID(slot_id);
						if(player and player.nid and not player.bCostCredential) then
							-- 40004_RedMushroomArenaCombatCountRemaining
							local has_40004, guid_40004 = PowerItemManager.IfOwnGSItem(player.nid, 40004);
							if(has_40004) then
								-- mark has cost credential
								player.bCostCredential = true;
								-- destroy count
								local items = {[guid_40004] = 1};
								PowerItemManager.DestroyItemBatch(player.nid, items, function(msg) 
									-- tell the client to update hp
									local gridnode = GSL_gateway:GetPrimGridNode(tostring(player.nid));
									if(gridnode) then
										local server_object = gridnode:GetServerObject("sPowerAPI");
										if(server_object) then
											server_object:SendRealtimeMessage(tostring(player.nid), "[Aries][PowerAPI]FullHPAfterPvPCountCost:1");
										end
									end
								end);
							end
						end
					end
				elseif(self.entercombat_cost == "TrialOfChampions") then
					-- empty enter combat cost
					-- nothing
				elseif(self.entercombat_cost == "RedMushroomArena_NoTicket") then
					-- check all players if cost credential yet
					local slot_id = 1;
					for slot_id = 1, max_unit_count_per_side_arena * 2 do
						local player = self:GetPlayerCombatObjBySlotID(slot_id);
						if(player and player.nid) then
							local gridnode = GSL_gateway:GetPrimGridNode(tostring(player.nid));
							if(gridnode) then
								local server_object = gridnode:GetServerObject("sPowerAPI");
								if(server_object) then
									server_object:SendRealtimeMessage(tostring(player.nid), "[Aries][PowerAPI]FullHPAfterPvPTickerCost:1");
								end
							end
						end
					end
				end
			end
			return true;
		end
		return false;
	else
		LOG.std(nil, "error", "arena", "Arena:AddPlayer_pvp to non pvp arena");
		return false;
	end
end

-- add arena minion object
-- minion try to enter pve arena
function Arena:AddArenaMinion_pve(minion, nPreferSlot)
	if(self.mode == "pve") then
		local nEmptySlot = nil;
		if(nPreferSlot and nPreferSlot >= 1 and nPreferSlot <= max_unit_count_per_side_arena) then
			local nid = self.player_nids[nPreferSlot];
			if(not nid and not self.fled_slots[nPreferSlot]) then
				nEmptySlot = nPreferSlot;
			end
		end
		
		if(self.players_max) then
			local player_and_fled_unit_count = 0;
			local i;
			for i = 1, max_unit_count_per_side_arena do
				if(self.player_nids[i]) then
					player_and_fled_unit_count = player_and_fled_unit_count + 1;
				elseif(self.fled_slots[i]) then
					player_and_fled_unit_count = player_and_fled_unit_count + 1;
				end
			end
			if(player_and_fled_unit_count >= self.players_max) then
				return false, "ArenaSlotsFull";
			end
		end
		
		if(not nEmptySlot) then
			local i;
			for i = 1, max_unit_count_per_side_arena do
				local nid = self.player_nids[i];
				if(not nid and not self.fled_slots[i]) then
					nEmptySlot = i;
					break;
				end
			end
		end
		if(nEmptySlot) then
			-- empty player slot
			self.player_nids[nEmptySlot] = minion:GetNID();
			-- keep arrow cast position
			minion.arrow_cast_position = nEmptySlot;
			-- keep an arena id reference
			minion.arena_id = self:GetID();
			-- reset the lootables
			minion.lootables = nil;
			-- reset played turns
			minion.turns_played = 0;
			-- set the arena side
			minion.side = "near";
			return true;
		else
			return false, "ArenaSlotsFull";
		end
		return false;
	else
		LOG.std(nil, "error", "arena", "Arena:AddArenaMinion_pve to non pve arena");
		return false;
	end
end

-- add follow pet minion object
-- follow pet try to enter pve arena
function Arena:AddFollowPetMinion_pve(minion, nPreferSlot)
	if(self.mode == "pve") then
		local nEmptySlot = nil;
		if(nPreferSlot and nPreferSlot >= 1 and nPreferSlot <= max_unit_count_per_side_arena) then
			local nid = self.player_nids[nPreferSlot];
			if(not nid and not self.fled_slots[nPreferSlot]) then
				nEmptySlot = nPreferSlot;
			end
		end
		
		if(self.players_max) then
			local player_and_fled_unit_count = 0;
			local i;
			for i = 1, max_unit_count_per_side_arena do
				if(self.player_nids[i]) then
					player_and_fled_unit_count = player_and_fled_unit_count + 1;
				elseif(self.fled_slots[i]) then
					player_and_fled_unit_count = player_and_fled_unit_count + 1;
				end
			end
			if(player_and_fled_unit_count >= self.players_max) then
				return false, "ArenaSlotsFull";
			end
		end
		
		if(not nEmptySlot) then
			local i;
			for i = 1, max_unit_count_per_side_arena do
				local nid = self.player_nids[i];
				if(not nid and not self.fled_slots[i]) then
					nEmptySlot = i;
					break;
				end
			end
		end
		if(nEmptySlot) then
			-- empty player slot
			self.player_nids[nEmptySlot] = minion:GetNID();
			-- keep arrow cast position
			minion.arrow_cast_position = nEmptySlot;
			-- keep an arena id reference
			minion.arena_id = self:GetID();
			-- reset the lootables
			minion.lootables = nil;
			-- reset played turns
			minion.turns_played = 0;
			-- set the arena side
			minion.side = "near";
			return true;
		else
			return false, "ArenaSlotsFull";
		end
		return false;
	else
		LOG.std(nil, "error", "arena", "Arena:AddFollowPetMinion_pve to non pve arena");
		return false;
	end
end

-- remove player and followpet from arena
function Arena:RemovePlayerAndFollowPet(player_nid)
	if(player_nid) then
		self:RemovePlayer(player_nid);
		self:RemovePlayer(-(tonumber(player_nid) or 0));
	end
end

-- remove player from arena
-- player try to flee from the combat
function Arena:RemovePlayer(player_nid, bSkipFleeSlot)
	local i;
	for i = 1, max_unit_count_per_side_arena * 2 do
		local nid = self.player_nids[i];
		if(nid == player_nid) then
			-- mark nid
			self.player_nids[i] = nil;
			if(not bSkipFleeSlot) then
				-- mark fled
				self.fled_slots[i] = true;
				self.fled_nids[nid] = i;
				-- record fled player level
				local player = Player.GetPlayerCombatObj(player_nid);
				if(player) then
					self.fled_slots_level[i] = player:GetPetLevel();
				end
				if(self.fled_slot_life) then
					self.fled_slots[i] = self.fled_slot_life;
				end
			end
			-- destroy player
			Player.DestroyPlayer(player_nid);
			return;
		end
	end
end

-- reset all control tags
function Arena:ResetControlTags()
	-- reset common tags
	self.seq = 1;
	-- reset pve relates tags
	self.isNearArenaFirst = nil;
	self.nCombatStartTime = nil;
	self.nRemainingRounds = nil;
	self.nExecutedRounds = nil;
	self.PickCardTimeOutTime = nil;
	self.PlayTurnTimeOutTime = nil;
	self.PlayTurnMinTime = nil;
	self.fled_slots = {};
	self.fled_nids = {};
	self.fled_slots_level = {};
	-- reset pvp related tags
	self.currentPlayingSide = nil;
	-- reset auto combat nids
	self.AutoCombatNIDs = {};
	-- reset both side combat unit list string
	self.nearside_active_unit_list_str = nil;
	self.farside_active_unit_list_str = nil;
	-- reset leader nid
	self.locked_for_teamleaderid = nil;
	self.locked_for_teamleaderid_time = nil;
	-- reset lootable players
	if(self.treasurebox) then
		self.treasurebox.lootable_nids = nil;
	end
	-- reset all player ranking sync tag
	self.bAllPlayerResyncedRankingPoints = nil;
	self:ClearAura();
	self:ClearAura2();
end

-- clear aura
function Arena:ClearAura()
	self.GlobalAura = nil;
	self.GlobalAura_boost_damage = nil;
	self.GlobalAura_boost_school = nil;
	self.GlobalAura_boost_heal = nil;
	self.GlobalAura_boost_powerpip = nil;
	self.GlobalAura_gsid = nil;
end

-- clear aura2
function Arena:ClearAura2()
	self.GlobalAura2 = nil;
	self.GlobalAura2_icon_gsid = nil;
end

-- on destroy
function Arena:OnDestroy()
	-- remove mob
	local id;
	for _, id in ipairs(self.mob_ids) do
		local mob = Mob.GetMobByID(id);
		if(mob) then
			mob:OnDestroy();
		end
	end
	-- remove player
	local i;
	for i = 1, max_unit_count_per_side_arena * 2 do
		local nid = self.player_nids[i];
		if(nid) then
			local player = Player.GetPlayerCombatObj(nid);
			if(player) then
				player:OnDestroy();
			end
		end
	end
	-- remove arena
	arenas[self:GetID()] = nil;
end

-- set aura
function Arena:SetAura(GlobalAura, GlobalAura_boost_damage, GlobalAura_boost_school, GlobalAura_boost_heal, GlobalAura_boost_powerpip, GlobalAura_gsid)
	self.GlobalAura = GlobalAura;
	self.GlobalAura_boost_damage = GlobalAura_boost_damage;
	self.GlobalAura_boost_school = GlobalAura_boost_school;
	self.GlobalAura_boost_heal = GlobalAura_boost_heal;
	self.GlobalAura_boost_powerpip = GlobalAura_boost_powerpip;
	self.GlobalAura_gsid = GlobalAura_gsid;
end

-- get aura
function Arena:GetAura()
	return  self.GlobalAura, 
			self.GlobalAura_boost_damage, 
			self.GlobalAura_boost_school, 
			self.GlobalAura_boost_heal, 
			self.GlobalAura_boost_powerpip,
			self.GlobalAura_gsid;
end

-- NOTE: aura2 has the same effect as aura, the difference is 
--		aura can replace aura effect
--		aura2 can replace aura2 effect
-- set aura2
function Arena:SetAura2(globalaura_id, icon_gsid)
	self.GlobalAura2 = globalaura_id;
	self.GlobalAura2_icon_gsid = icon_gsid;
end

-- get aura2
function Arena:GetAura2()
	return self.GlobalAura2, self.GlobalAura2_icon_gsid;
end

-- respawn all related mobs
function Arena:RespawnAll_pve()
	if(self.mode == "pve") then
		-- reset all mobs related
		local id;
		for _, id in ipairs(self.mob_ids) do
			local mob = Mob.GetMobByID(id);
			mob:Respawn();
		end
		-- reset control tags
		self:ResetControlTags();
		-- append to the normal update queue 
		self:AppendToNormalUpdateQueue();
	else
		LOG.std(nil, "error", "arena", "Arena:RespawnAll_pve to non pve arena");
	end
end

-- reset pvp arena 
function Arena:Reset_pvp()
	if(self.mode == "free_pvp") then
		-- reset control tags
		self:ResetControlTags();
		-- append to the normal update queue 
		self:AppendToNormalUpdateQueue();
	else
		LOG.std(nil, "error", "arena", "Arena:Reset_pvp to non pvp arena");
	end
end

-- reset and kill all related mobs
function Arena:ResetAndKillAll_pve()
	if(self.mode == "pve") then
		-- reset all mobs related
		local id;
		for _, id in ipairs(self.mob_ids) do
			local mob = Mob.GetMobByID(id);
			mob:Suicide();
		end
		-- reset control tags
		self:ResetControlTags();
		-- append to the normal update queue 
		self:AppendToNormalUpdateQueue();
	else
		LOG.std(nil, "error", "arena", "Arena:ResetAndKillAll_pve to non pve arena");
	end
end

-- get round tag
-- pve arena: 0 or positive executed rounds
-- pvp arena: 0 or positive remaining rounds
-- if round tag is 0, check the arena mode in client
function Arena:GetRoundTag()
	if(self.mode == "pve") then
		if(self.nExecutedRounds) then
			return self.nExecutedRounds or 0;
		end
	elseif(self.mode == "free_pvp") then
		if(self.nRemainingRounds) then
			return self.nRemainingRounds or 0;
		end
	end
end

function Arena:IsArenaAllPlayerFromLifeSchool()
	-- check if each player is life school
	local i;
	for i = 1, max_unit_count_per_side_arena * 2 do
		local nid = self.player_nids[i];
		if(nid) then
			local player = Player.GetPlayerCombatObj(nid);
			if(player and player:IsAlive() and not player:IsMinion()) then
				local phase = player:GetPhase();
				if(phase ~= "life") then
					return false;
				end
			end
		end
	end
	return true;
end

-- NOTE: only for kids version, red mushroom arena and battlefield
-- get arena damage boost
-- @return: damage boost in percent
function Arena:GetArenaDamageBoost()
	if(System.options.version ~= "teen") then
		-- don't apply per round damage boost for teen version
		if(self.mode == "pve") then
			if(not self.isinstance) then
				local count = self:GetPlayerCount(0);
				if(count) then
					if(count == 1) then
						return 0;
					elseif(count == 2) then
						return 10;
					elseif(count == 3) then
						return 20;
					elseif(count == 4) then
						return 30;
					end
				end
			end
		elseif(self.mode == "free_pvp") then
			if(self.nRemainingRounds and self.nRemainingRounds >= 0) then
				local EveryRoundDamageBoost = 4;
				if(self:IsArenaAllPlayerFromLifeSchool()) then
					EveryRoundDamageBoost = self.AllLifeEveryRoundDamageBoost or 2;
				end
				if(self.ranking_stage and self.ranking_stage and string.match(self.ranking_stage,"3v3")) then
					EveryRoundDamageBoost = 8;
				end
				if(self.is_battlefield) then
					return EveryRoundDamageBoost * math.floor((MAX_ROUNDS_PVP_ARENA_BATTLEFIELD - self.nRemainingRounds) / 2);
				else
					return EveryRoundDamageBoost * math.floor((MAX_ROUNDS_PVP_ARENA - self.nRemainingRounds) / 2);
				end
			end
		end
	elseif(System.options.version == "teen") then
		if(self.bIncreasingDamage == true) then
			if(self.mode == "pve") then
				local nExecutedRounds = self.nExecutedRounds or 0;
				local EveryRoundDamageBoost = 2;
				return EveryRoundDamageBoost * nExecutedRounds;
			elseif(self.mode == "free_pvp") then
				if(self.nRemainingRounds and self.nRemainingRounds >= 0) then
					local EveryRoundDamageBoost = 2;
					if(self.is_battlefield) then
						return EveryRoundDamageBoost * math.floor((MAX_ROUNDS_PVP_ARENA_BATTLEFIELD - self.nRemainingRounds) / 2);
					else
						return EveryRoundDamageBoost * math.floor((MAX_ROUNDS_PVP_ARENA - self.nRemainingRounds) / 2);
					end
				end
			end
		end
	end
	return 0;
end

-- NOTE: only for kids version
-- get arena heal penalty
-- @return: heal penalty in percent
function Arena:GetArenaHealPenalty()
	if(System.options.version ~= "teen") then
		-- don't apply heal penalty for teen version
		if(self.mode == "free_pvp") then
			if(self.OpenAllLifeHealPenalty) then
				if(self:IsArenaAllPlayerFromLifeSchool()) then
					return 50;
				end
			end
		end
	end
	return 0;
end

-- append value message
function Arena:AppendToNormalUpdateQueue()
	-- combat server server object
	combat_server.AppendNormalUpdateMessage(self.combat_server_uid, self:GetKey_normal_update(), self:GetValue_normal_update());
	combat_server.AppendNormalUpdateMessage(self.combat_server_uid, self:GetInactivePlayerKey_normal_update(), self:GetInactivePlayerValue_normal_update());
end

-- is player nid in arena nid list
function Arena:IsPlayerInArena(nid)
	local i;
	for i = 1, max_unit_count_per_side_arena * 2 do
		if(self.player_nids[i] == nid) then
			return true;
		end
	end
	return false;
end

-- is mob id in arena mob list
function Arena:IsMobInArena(mob_id)
	if(self.mode == "pve") then
		local _, id;
		for _, id in ipairs(self.mob_ids) do
			if(mob_id == id) then
				return true;
			end
		end
		return false;
	else
		-- for pvp
	end
end

-- get player nid by slot id
-- @param slot_id: from 1 to max_player_count_per_arena
function Arena:GetPlayerNIDBySlotID_pve(slot_id)
	if(self.mode == "pve") then
		return self.player_nids[slot_id];
	else
		LOG.std(nil, "error", "arena", "Arena:GetPlayerNIDBySlotID_pve to non pve arena");
	end
end

-- get combat player combat object by slot id
-- @param slot_id: from 1 to max_player_count_per_arena
function Arena:GetPlayerCombatObjBySlotID(slot_id)
	local nid = self.player_nids[slot_id];
	if(nid) then
		return Player.GetPlayerCombatObj(nid);
	end
end

-- get mob ids
function Arena:GetMobIDs()
	return self.mob_ids;
end

-- get player nids
function Arena:GetPlayerNIDs()
	return commonlib.deepcopy(self.player_nids);
end

-- lock arrow position
function Arena:LockCurrentSequenceArrowPosition(position_id)
	self.nLockedCurrentSequenceArrowPosition = position_id;
end

-- release lock arrow position
function Arena:UnLockCurrentSequenceArrowPosition()
	self.nLockedCurrentSequenceArrowPosition = nil;
end

-- get current sequence arrow position
-- @return: 1 to 8, if 0 means the arena is the sequence is not decided yet
function Arena:GetCurrentSequenceArrowPosition()
	if(self.nLockedCurrentSequenceArrowPosition) then
		return self.nLockedCurrentSequenceArrowPosition;
	end
	local position = 0;
	if(self.mode == "pve") then
		if(self.isNearArenaFirst == false) then
			local index, id;
			for index, id in ipairs(self.mob_ids) do
				local mob = Mob.GetMobByID(id);
				if(mob:IsAlive()) then
					position = max_unit_count_per_side_arena + index;
					break;
				end
			end
		elseif(self.isNearArenaFirst == true) then
			local slot_id = 1;
			for slot_id = 1, max_unit_count_per_side_arena * 2 do
				local player = self:GetPlayerCombatObjBySlotID(slot_id);
				if(player) then
					if(player:IsAlive()) then
						position = slot_id;
						break;
					end
				end
			end
		end
	elseif(self.mode == "free_pvp") then
		if(self.currentPlayingSide == "near") then
			local slot_id = 1;
			for slot_id = 1, max_unit_count_per_side_arena do
				local unit = self:GetCombatUnitBySlotID(slot_id);
				if(unit) then
					if(unit:IsAlive()) then
						position = slot_id;
						break;
					end
				end
			end
		elseif(self.currentPlayingSide == "far") then
			local slot_id = 1;
			for slot_id = max_unit_count_per_side_arena + 1, max_unit_count_per_side_arena * 2 do
				local unit = self:GetCombatUnitBySlotID(slot_id);
				if(unit) then
					if(unit:IsAlive()) then
						position = slot_id;
						break;
					end
				end
			end
		end
	end
	return position;
end

-- get the normal update key
function Arena:GetKey_normal_update()
	return "arena_"..self:GetID();
end

-- get the normal update inactive player key
function Arena:GetInactivePlayerKey_normal_update()
	return "arena_inactiveplayer_"..self:GetID();
end

-- get the normal update value
-- Note for Andy by Xizhi: using table.concat where appropriate. 
function Arena:GetValue_normal_update()
	local value = "";
	-- append value message
	-- including: arena_id, position, {mob, hp, pips, charms, shields, dots}, {player, hp, pips, charms, shields, dots}
	-- TODO:
	-- section1: arena status
	--local section1 = format("%d,%f,%f,%f,%d", self:GetID(), self.position.x, self.position.y, self.position.z, self:GetCurrentSequenceArrowPosition());
	local section1 = format("%d,%s,%f,%f,%f,%d", self:GetID(), self.mode, self.position.x, self.position.y, self.position.z, self:GetCurrentSequenceArrowPosition());
	-- section2: mob status or far arena side units
	local section2 = "";
	-- mob status
	local _, id;
	for _, id in ipairs(self.mob_ids) do
		local mob = Mob.GetMobByID(id);
		if(mob) then
			section2 = section2.."["..mob:GetValue_normal_update().."]";
		end
	end
	
	-- section3: player status or near arena side units
	local section3 = "";
	local slot_id = 1;
	if(self:IsPlayerSlotEmpty()) then
		section3 = "[][][][][][][][]";
	else
		for slot_id = 1, max_unit_count_per_side_arena * 2 do
			local player = self:GetPlayerCombatObjBySlotID(slot_id);
			if(player and player:IsCombatActive()) then
				section3 = section3.."["..player:GetValue_normal_update().."]";
			elseif(self.fled_slots[slot_id]) then
				section3 = section3.."[0]";
			else
				section3 = section3.."[]";
			end
		end
	end
	
	-- section4: pips counts
	-- section5: power pips counts
	local section4 = "";
	local section5 = "";
	local slot_id = 1;
	for slot_id = 1, max_unit_count_per_side_arena * 2 do
		local unit = self:GetCombatUnitBySlotID(slot_id);
		if(unit) then
			section4 = section4..unit:GetPipsCount()..",";
			section5 = section5..unit:GetPowerPipsCount()..",";
		else
			section4 = section4.."0,";
			section5 = section5.."0,";
		end
	end
	
	-- section6: global aura
	local global_aura_str = tostring(self.GlobalAura or "");
	if(self.GlobalAura_gsid) then
		global_aura_str = global_aura_str.."_"..self.GlobalAura_gsid;
	end
	local global_aura2_str = tostring(self.GlobalAura2 or "");
	if(self.GlobalAura2_icon_gsid) then
		global_aura2_str = global_aura2_str.."_"..self.GlobalAura2_icon_gsid;
	end
	local section6 = global_aura_str..","..global_aura2_str;

	-- section7: door lock
	local section7 = tostring(self.door_lock or "");

	-- section8: treasure box
	local section8 = "";
	if(self.treasurebox) then
		section8 = commonlib.serialize_compact(self.treasurebox);
	end
	
	-- section9: arena params
	local section9 = "";
	section9 = tostring(self:GetArenaDamageBoost())..","..tostring(self:GetArenaHealPenalty());
	
	-- section10 and section11: near arena user team aura
	local section10 = "";
	local section11 = "";
	local i;
	for i = 1, max_unit_count_per_side_arena * 2 do
		local nid = self.player_nids[i];
		if(nid) then
			local player = Player.GetPlayerCombatObj(nid)
			if(player and player:IsCombatActive() and player.user_team_aura) then
				local gsItem = PowerItemManager.GetGlobalStoreItemInMemory(player.user_team_aura);
				if(gsItem) then
					if(i >= 1 and i <= max_unit_count_per_side_arena) then
						section10 = section10..player.user_team_aura..",";
					elseif(i >= (max_unit_count_per_side_arena + 1) and i <= (max_unit_count_per_side_arena * 2)) then
						section11 = section11..player.user_team_aura..",";
					end
				end
			end
		end
	end
	
	-- section12: arena appearance
	local section12 = "";
	if(self.appearance) then
		section12 = tostring(self.appearance);
	end

	-- return all sections
	return format("%s{%s}{%s}{%s}{%s}{%s}{%s}{%s}{%s}{%s}{%s}{%s}", section1, section2, section3, section4, section5, section6, section7, section8, section9, section10, section11, section12);
end

-- get the normal update in active player value
-- NOTE 2010/8/17: when player enter combat while the spells are playing the newly joined player will be poped out of the arena
--					we need another normal update value to update the joined but inactive players
function Arena:GetInactivePlayerValue_normal_update()
	local value = "";
	
	-- inactive player status
	local value = "";
	local slot_id = 1;
	for slot_id = 1, max_unit_count_per_side_arena * 2 do
		local player = self:GetPlayerCombatObjBySlotID(slot_id);
		if(player and not player:IsCombatActive()) then
			value = value.."["..player:GetValue_normal_update().."]";
		else
			value = value.."[]";
		end
	end
	
	-- return all sections
	return value;
end

-- keep all reference of the the xml root of the config file
local arena_and_mobs_config_file_pairs_xmlroot = {};

-- keep all reference of the the xml root of the config file
local mobkey_dumpedlootline_mapping = {};

function Arena.UnloadAllConfigFiles()
	arena_and_mobs_config_file_pairs_xmlroot = {};
end

-- load arena and mob from config file
-- @return arena ids table
function Arena.InitArenaAndMobFromFile(config_file, isinstance, combat_server_uid, gridnode, explicitXMLRoot)
	if(not config_file) then
		commonlib.applog("error: server loaded arena and mob with nil config file: %s", tostring(config_file));
		return;
	end
	local xmlRoot = arena_and_mobs_config_file_pairs_xmlroot[config_file];
	if(not xmlRoot) then
		if(explicitXMLRoot) then
			commonlib.log("info: loading arena and mob config from explicitXMLRoot: %s\n", config_file);
			xmlRoot = explicitXMLRoot;
		else
			xmlRoot = ParaXML.LuaXML_ParseFile(config_file);
		end
	end
	if(not xmlRoot) then
		commonlib.log("error: failed loading arena and mob config file: %s\n", config_file);
		return;
	end
	arena_and_mobs_config_file_pairs_xmlroot[config_file] = xmlRoot;
	LOG.std(nil,"debug", "GSL", "server loaded arena and mob config file %s", config_file);
	
	-- NOTE: we assume the world file is in format:
	--		 .../%%worldname%.Arenas_Mobs.xml
	local worldname = string.match(config_file, [[/([^/]-)%.Arenas_Mobs%.xml$]])
	if(worldname) then
		combat_server.AppendNormalUpdateMessage(combat_server_uid, "arena_start_"..string.lower(worldname), tostring(base_arena_id));
	else
		LOG.std(nil, "error", "arena", "fatal error: world config file in invalid format");
		return;
	end

	local difficulty_modifier;
	if(isinstance) then
		local each_modifier;
		for each_modifier in commonlib.XPath.eachNode(xmlRoot, "/arenas/difficulty_modifier/modifier") do
			local mode = each_modifier.attr.mode;
			if(mode) then
				difficulty_modifier = difficulty_modifier or {};
				difficulty_modifier[mode] = {
					hp = tonumber(each_modifier.attr.hp or 1),
					damage = tonumber(each_modifier.attr.damage or 1),
					resist = tonumber(each_modifier.attr.resist or 1),
					output_heal_percent = tonumber(each_modifier.attr.output_heal_percent or 1),
				};
			end
		end
	end

	-- arena ids
	local arena_ids = {};
	-- infile id and arena id mapping
	local file_id_arena_id_mapping = {};
	-- last arena in config file to mark the last instance arena
	local last_arena;
	-- create each arena object and associated mobs
	local each_arena;
	for each_arena in commonlib.XPath.eachNode(xmlRoot, "/arenas/arena") do
		local position = each_arena.attr.position;
		local ai_module = each_arena.attr.ai_module;
		local door_lock = each_arena.attr.door_lock;
		local id = each_arena.attr.id; -- this is not the real arena id, just the id in this arena mobs file
		local respawn_interval = each_arena.attr.respawn_interval or 30000; -- default 30 seconds
		if(position and ai_module and respawn_interval and id) then
			respawn_interval = tonumber(respawn_interval);
			local x, y, z = string.match(position, "(.+),(.+),(.+)");
			if(x and y and z) then
				x = tonumber(x);
				y = tonumber(y);
				z = tonumber(z);
			end
			local ai_module = each_arena.attr.ai_module;
			--if(ai_module == "") then
				--ai_module = "Simple_Attacker"; -- default simple attacker
			--end
			--ai_module = ai_module or "Simple_Attacker";

			-- all mobs default genes attacker
			if(ai_module == "Deck_Attacker") then
				ai_module = "Deck_Attacker";
			else
				ai_module = "Genes_Attacker";
			end
			local module = AI_Module.GetAIModule(ai_module)
			if(not module) then
				module = AI_Module.CreateAIModule(ai_module);
			end

			local difficulty = "normal";
			if(gridnode and gridnode.mode == 1) then
				difficulty = "easy";
				local respawn_interval_easy = each_arena.attr.respawn_interval_easy;
				if(respawn_interval_easy) then
					respawn_interval_easy = tonumber(respawn_interval_easy);
					if(respawn_interval_easy) then
						respawn_interval = respawn_interval_easy;
					end
				end
			elseif(gridnode and gridnode.mode == 2) then
				difficulty = "normal";
			elseif(gridnode and gridnode.mode == 3) then
				difficulty = "hard";
				local respawn_interval_hard = each_arena.attr.respawn_interval_hard;
				if(respawn_interval_hard) then
					respawn_interval_hard = tonumber(respawn_interval_hard);
					if(respawn_interval_hard) then
						respawn_interval = respawn_interval_hard;
					end
				end
			elseif(gridnode and gridnode.mode == 4) then
				difficulty = "hero";
				local respawn_interval_hero = each_arena.attr.respawn_interval_hero;
				if(respawn_interval_hero) then
					respawn_interval_hero = tonumber(respawn_interval_hero);
					if(respawn_interval_hero) then
						respawn_interval = respawn_interval_hero;
					end
				end
			elseif(gridnode and gridnode.mode == 5) then
				difficulty = "nightmare";
				local respawn_interval_nightmare = each_arena.attr.respawn_interval_nightmare;
				if(respawn_interval_nightmare) then
					respawn_interval_nightmare = tonumber(respawn_interval_nightmare);
					if(respawn_interval_nightmare) then
						respawn_interval = respawn_interval_nightmare;
					end
				end
			end

			-- explicit arena appearance
			local appearance = each_arena.attr.appearance;

			-- create arena object
			local arena = Arena:new({
				position = {x = x, y = y, z = z},
				ai_module = module,
				respawn_interval = respawn_interval,
				door_lock = door_lock,
				world_config_file = config_file,
				combat_server_uid = combat_server_uid,
				isinstance = isinstance,
				gridnode = gridnode,
				difficulty = difficulty,
				appearance = appearance,
			});
			-- create mobs
			local mob;
			for mob in commonlib.XPath.eachNode(each_arena, "/mob") do
				if(mob.attr.mob_template and mob.attr.mob_template ~= "" and mob.attr.mob_template ~= "nil") then
					
					local schools = {"fire","ice","storm","life","death"};
					local school = schools[math.random(1, #schools)];
					local gearscore;

					if(config_file == "config/Aries/WorldData_Teen/HaqiTown_RedMushroomArena_AI_1v1.Arenas_Mobs.xml") then
						local match_info = gridnode.match_info;
						if(match_info) then
							if(match_info.teams and match_info.teams[1] and match_info.teams[1].players) then
								local near_team_players = match_info.teams[1].players;
								if(near_team_players) then
									local nid_str, info;
									for nid_str, info in pairs(near_team_players) do
										local gs = info.score;
										if(gs) then
											mob.attr.mob_template = "config/Aries/Mob_Teen/HaqiTown_RedMushroomArena_AI_1v1/MobTemplate_test.xml".."@"..tostring(nid_str);
											gearscore = gs;
										end
									end
								end
							end
						end
					end
					-- create mob object
					local mob_obj = Mob:new(mob, mob.attr.explicitXMLRoot);
					if(mob_obj) then
						mob_obj.side = "far";
						mob_obj.difficulty = arena:GetDifficulty();
						mob_obj.difficulty_modifier = difficulty_modifier;
						arena:AddMob_pve(mob_obj);
						
						if(gearscore and config_file == "config/Aries/WorldData_Teen/HaqiTown_RedMushroomArena_AI_1v1.Arenas_Mobs.xml") then
							local randomname = MobAINames[math.random(1, #MobAINames)];
							if(randomname) then
								mob_obj:SetDisplayName(randomname);
							end
							mob_obj:SetPhase(school);
							mob_obj:SetAssetFromGearScore(school, gearscore); -- set asset
							mob_obj:SetAIDeckFromGearScore(school, gearscore); -- set deck_attacker_style and deckcards
							mob_obj:SetStatsFromGearScore(school, gearscore); -- set stats
						end

						--if(not mobkey_dumpedlootline_mapping[mob_obj:GetTemplateKey()]) then
							--mobkey_dumpedlootline_mapping[mob_obj:GetTemplateKey()] = true;
							--mob_obj:DumpLootLineToLog();
						--end
					end
				end
			end

			-- record minions
			local minion;
			for minion in commonlib.XPath.eachNode(each_arena, "/minion") do
				if(minion and minion.attr.gsid) then
					local gsid = tonumber(minion.attr.gsid);
					if(gsid) then
						local gsItem = PowerItemManager.GetGlobalStoreItemInMemory(gsid);
						if(gsItem and gsItem.template.stats and gsItem.template.class == 22) then
							-- 22 is the minion class
							arena.minion_gsid = gsid;
							if(minion.attr.minion_template) then
								local minionTemplate = Player.CreateGetMinionTemplate(minion.attr.minion_template);
								if(minionTemplate and minionTemplate.key) then
									arena.minion_key = minionTemplate.key;
								end
							end
						end
					end
				end
			end
			
			-- create treasure box
			local treasurebox;
			for treasurebox in commonlib.XPath.eachNode(each_arena, "/treasurebox") do
				if(treasurebox.attr and treasurebox.attr.loot_id and treasurebox.attr.position and treasurebox.attr.facing) then
					-- create treasure box object
					local x, y, z = string.match(treasurebox.attr.position, "(.+),(.+),(.+)");
					if(x and y and z) then
						x = tonumber(x);
						y = tonumber(y);
						z = tonumber(z);
					end
					local treasurebox_obj = {
						loot_id = treasurebox.attr.loot_id,
						position = {x = x, y = y, z = z},
						facing = tonumber(treasurebox.attr.facing),
					};
					if(treasurebox_obj) then
						arena:AddTreasureBox(treasurebox_obj);
					end
				end
			end

			-- match item sections
			local match_item;
			for match_item in commonlib.XPath.eachNode(each_arena, "/match_item") do
				if(match_item.attr and match_item.attr.gsid and match_item.attr.count) then
					local gsid = tonumber(match_item.attr.gsid);
					local count = tonumber(match_item.attr.count);
					if(gsid and count) then
						arena:AddMatchItem(gsid, count);
					end
				end
			end
			
			-- playturn motions
			arena.playturn_motions = {};
			local motion;
			for motion in commonlib.XPath.eachNode(each_arena, "/playturn_motions/motion") do
				if(motion.attr and motion.attr.round and motion.attr.path) then
					local round = tonumber(motion.attr.round);
					local path = motion.attr.path;
					if(round and path) then
						arena.playturn_motions[round] = path;
					end
				end
			end
			
			local exchange_keys = {
				"bonus_exchange",
			};

			local _, key;
			for _, key in ipairs(exchange_keys) do
				if(each_arena.attr[key]) then
					local exchange_gsid, exchange_loots = string.match(each_arena.attr[key], "^(.-)%+(.-)$")
					if(exchange_gsid and exchange_loots) then
						exchange_gsid = tonumber(exchange_gsid);
						local loots = {};
						local loot_gsid_count_pair;
						for loot_gsid_count_pair in string.gmatch(exchange_loots, "([^%(^%)]+)") do
							local gsid, count = string.match(loot_gsid_count_pair, "^(%d-),(%d-)$");
							if(gsid and count) then
								gsid = tonumber(gsid);
								count = tonumber(count);
								loots[gsid] = count;
							end
						end
						arena[key] = {exchange_gsid = exchange_gsid, loots = loots};
					end
				end
			end
			
			if(each_arena.attr.end_motion_id) then
				arena.end_motion_id = each_arena.attr.end_motion_id;
			end
			
			if(each_arena.attr.boss_id) then
				arena.boss_id = each_arena.attr.boss_id;
			end
			
			if(each_arena.attr.boss_round_achievement_normal_gsid) then
				arena.boss_round_achievement_normal_gsid = tonumber(each_arena.attr.boss_round_achievement_normal_gsid);
			end
			if(each_arena.attr.boss_round_achievement_hard_gsid) then
				arena.boss_round_achievement_hard_gsid = tonumber(each_arena.attr.boss_round_achievement_hard_gsid);
			end
			if(each_arena.attr.boss_round_achievement_hero_gsid) then
				arena.boss_round_achievement_hero_gsid = tonumber(each_arena.attr.boss_round_achievement_hero_gsid);
			end
			if(each_arena.attr.boss_round_achievement_nightmare_gsid) then
				arena.boss_round_achievement_nightmare_gsid = tonumber(each_arena.attr.boss_round_achievement_nightmare_gsid);
			end

			if(each_arena.attr.is_single_fight == "true") then
				arena.is_single_fight = true;
			end

			if(each_arena.attr.is_postlog_usecard == "true" and each_arena.attr.key_postlog_usecard) then
				arena.is_postlog_usecard = true;
				arena.key_postlog_usecard = each_arena.attr.key_postlog_usecard;
			end
			
			if(each_arena.attr.is_always_mob_first == "true") then
				arena.is_always_mob_first = true;
			end
			if(each_arena.attr.is_always_player_first == "true") then
				arena.is_always_player_first = true;
			end
			
			if(each_arena.attr.can_refresh_with_gsid) then
				arena.can_refresh_with_gsid = tonumber(each_arena.attr.can_refresh_with_gsid);
			end
			
			if(each_arena.attr.players_max) then
				arena.players_max = tonumber(each_arena.attr.players_max);
			end
			
			if(each_arena.attr.stamina_cost) then
				arena.stamina_cost = tonumber(each_arena.attr.stamina_cost);
			end
			
			if(each_arena.attr.fake_min_pickcard_time and each_arena.attr.fake_max_pickcard_time) then
				arena.fake_min_pickcard_time = tonumber(each_arena.attr.fake_min_pickcard_time);
				arena.fake_max_pickcard_time = tonumber(each_arena.attr.fake_max_pickcard_time);
			end
			
			if(each_arena.attr.bIncreasingDamage == "true") then
				arena.bIncreasingDamage = true;
			end

			if(each_arena.attr.dayofweek) then
				arena.dayofweek = each_arena.attr.dayofweek;
			end
			
			if(each_arena.attr.bonus_pips_starting_defensive_units) then
				arena.bonus_pips_starting_defensive_units = tonumber(each_arena.attr.bonus_pips_starting_defensive_units);
			end

			-- mark last gained reward nids and counts
			arena.last_gained_reward_nids_and_counts = {};
			
			if(each_arena.attr.equip_exchange) then
				local equip_exchange_from, equip_exchange_to = string.match(each_arena.attr.equip_exchange, "^(%d+)%+(%d+)$")
				if(equip_exchange_from and equip_exchange_to) then
					equip_exchange_from = tonumber(equip_exchange_from);
					equip_exchange_to = tonumber(equip_exchange_to);
					if(equip_exchange_from and equip_exchange_to) then
						arena.equip_exchange = {
							equip_exchange_from = equip_exchange_from, 
							equip_exchange_to = equip_exchange_to
						};
					end
				end
			end
			
			if(each_arena.attr.item_pair_exchange) then
				local item_pair_exchange_from_1, item_pair_exchange_from_2, item_pair_exchange_to = string.match(each_arena.attr.item_pair_exchange, "^(%d+)%+(%d+)%=(%d+)$")
				if(item_pair_exchange_from_1 and item_pair_exchange_from_2 and item_pair_exchange_to) then
					item_pair_exchange_from_1 = tonumber(item_pair_exchange_from_1);
					item_pair_exchange_from_2 = tonumber(item_pair_exchange_from_2);
					item_pair_exchange_to = tonumber(item_pair_exchange_to);
					if(item_pair_exchange_from_1 and item_pair_exchange_from_2 and item_pair_exchange_to) then
						arena.item_pair_exchange = {
							item_pair_exchange_from_1 = item_pair_exchange_from_1, 
							item_pair_exchange_from_2 = item_pair_exchange_from_2, 
							item_pair_exchange_to = item_pair_exchange_to
						};
					end
				end
			end
			
			
			if(each_arena.attr.entercombat_hots) then
				local icon_gsid, hot_amount, hot_ticks = string.match(each_arena.attr.entercombat_hots, "^(%d-)%+(%d-)%+(%d-)$");
				if(icon_gsid and hot_amount and hot_ticks) then
					local icon_gsid = tonumber(icon_gsid);
					local hot_amount = tonumber(hot_amount);
					local hot_ticks = tonumber(hot_ticks);
					local hot_sequence = {
						icon_gsid = icon_gsid,
					};
					local _;
					for _ = 1, hot_ticks do
						table_insert(hot_sequence, hot_amount);
					end
					arena.entercombat_hots = hot_sequence;
				end
			end

			-- respawn all related mobs
			arena:RespawnAll_pve();
			
			if(arena.dayofweek) then
				local today_dayofweek = "";
                local today_date = ParaGlobal.GetDateFormat("yyyy-MM-dd");
                local year, month, day = string.match(today_date, "^(%d+)%-(%d+)%-(%d+)$");
		        if(year and month and day) then
			        year = tonumber(year)
			        month = tonumber(month)
			        day = tonumber(day)
                    if(year and month and day) then
						local _;
						_, today_dayofweek = PowerItemManager.GetDayOfWeek(day, month, year);
					end
				end
				if(not string.find(string.lower(arena.dayofweek), string.lower(today_dayofweek))) then
					arena:ResetAndKillAll_pve();
					arena.timeofday = nil;
					arena.timeofday_close = nil;
				else
					if(each_arena.attr.timeofday) then
						local timeofday_number = string.gsub(each_arena.attr.timeofday, ":", "");
						timeofday_number = tonumber(timeofday_number);
						if(timeofday_number) then
							arena.timeofday = timeofday_number;
							arena.is_last_current_time_test_smaller = true;
						end
					end
			
					if(each_arena.attr.timeofday_close) then
						local timeofday_close_number = string.gsub(each_arena.attr.timeofday_close, ":", "");
						timeofday_close_number = tonumber(timeofday_close_number);
						if(timeofday_close_number) then
							arena.timeofday_close = timeofday_close_number;
							arena.is_last_current_time_close_test_smaller = true;
						end
					end

					if(arena.timeofday) then
						arena:ResetAndKillAll_pve();
					end
					if(arena.timeofday_close) then
						arena:ResetAndKillAll_pve();
					end

					--if(arena.timeofday) then
						--local current_time = ParaGlobal.GetTimeFormat("HH:mm:ss");
						--local hour, minute = string.match(arena.timeofday, "^(%d+):(%d+)$");
						--local hour_c, minute_c, second_c = string.match(current_time, "^(%d+):(%d+):(%d+)$");
						--if(hour and minute and hour_c and minute_c and second_c) then
							--hour = tonumber(hour);
							--minute = tonumber(minute);
							--hour_c = tonumber(hour_c);
							--minute_c = tonumber(minute_c);
							--second_c = tonumber(second_c);
							--local remaining_seconds = (hour * 60 * 60 + minute * 60) - (hour_c * 60 * 60 + minute_c * 60 + second_c);
							--if(remaining_seconds > 0) then
								--arena:ResetAndKillAll_pve();
								--arena.force_next_respawn_interval = remaining_seconds * 1000;
							--else
								--arena:ResetAndKillAll_pve();
							--end
						--end
					--end
				end
			end

			-- mark last arena object
			last_arena = arena;
			-- append the arena ids
			table.insert(arena_ids, arena:GetID());
			-- append infile id and arena id mapping
			file_id_arena_id_mapping[id] = arena:GetID();
		end
	end
	-- mark last arena
	if(last_arena and isinstance) then
		last_arena.is_last_arena_in_instance = true;
	end
	-- create each arena locks
	local arena_locks = {};
	local each_arena_lock;
	for each_arena_lock in commonlib.XPath.eachNode(xmlRoot, "/arenas/inter_arena_locks") do
		-- create lock
		local lock;
		for lock in commonlib.XPath.eachNode(each_arena_lock, "/lock") do
			local unlock_id = lock.attr.unlock_id;
			unlock_id = file_id_arena_id_mapping[unlock_id]
			local unlock_arena = Arena.GetArenaByID(unlock_id);
			if(unlock_arena) then
				local rule = {};
				local key_id;
				for key_id in string.gmatch(lock.attr.key_ids, "[^,]+") do
					key_id = file_id_arena_id_mapping[key_id]
					local key_arena = Arena.GetArenaByID(key_id);
					if(key_arena) then
						key_arena:SetArenaLockID(unlock_id);
						table.insert(rule, key_id);
					end
				end
				unlock_arena:AppendArenaKeyRule(rule);
				unlock_arena:ResetAndKillAll_pve();
			end
		end
	end
	-- create pvp arena object
	local each_pvp_arena;
	for each_pvp_arena in commonlib.XPath.eachNode(xmlRoot, "/arenas/pvp_arena") do
		local position = each_pvp_arena.attr.position;
		--local ai_module = each_pvp_arena.attr.ai_module;
		--local door_lock = each_pvp_arena.attr.door_lock;
		--local id = each_pvp_arena.attr.id; -- this is not the real arena id, just the id in this arena mobs file
		if(position) then
			local x, y, z = string.match(position, "(.+),(.+),(.+)");
			if(x and y and z) then
				x = tonumber(x);
				y = tonumber(y);
				z = tonumber(z);
			end
			
			-- explicit arena appearance
			local appearance = each_pvp_arena.attr.appearance;

			local least_card_number_for_award = tonumber(each_pvp_arena.attr.least_card_number_for_award or 0);
			local least_round_number_for_award = tonumber(each_pvp_arena.attr.least_round_number_for_award or 0);

			-- create arena object
			local arena = Arena:new({
				mode = "free_pvp",
				position = {x = x, y = y, z = z},
				world_config_file = config_file,
				combat_server_uid = combat_server_uid,
				gridnode = gridnode,
				appearance = appearance,
				least_card_number_for_award = least_card_number_for_award,
				least_round_number_for_award = least_round_number_for_award,
			});
			
			-- get winner and loser loots
			local winner_loots = each_pvp_arena.attr.winner_loots;
			local loser_loots = each_pvp_arena.attr.loser_loots;
			local flee_loots = each_pvp_arena.attr.flee_loots;
			if(winner_loots and winner_loots ~= "") then
				local loots = {};
				local loot_gsid_count_pair;
				for loot_gsid_count_pair in string.gmatch(winner_loots, "([^%(^%)]+)") do
					local gsid, count = string.match(loot_gsid_count_pair, "^(%d-),(%d-)$");
					if(gsid and count) then
						gsid = tonumber(gsid);
						count = tonumber(count);
						loots[gsid] = count;
					end
				end
				arena.winner_loots = loots;
			end
			if(loser_loots and loser_loots ~= "") then
				local loots = {};
				local loot_gsid_count_pair;
				for loot_gsid_count_pair in string.gmatch(loser_loots, "([^%(^%)]+)") do
					local gsid, count = string.match(loot_gsid_count_pair, "^(%d-),(%d-)$");
					if(gsid and count) then
						gsid = tonumber(gsid);
						count = tonumber(count);
						loots[gsid] = count;
					end
				end
				arena.loser_loots = loots;
			end
			if(flee_loots and flee_loots ~= "") then
				local loots = {};
				local loot_gsid_count_pair;
				for loot_gsid_count_pair in string.gmatch(flee_loots, "([^%(^%)]+)") do
					local gsid, count = string.match(loot_gsid_count_pair, "^(%d-),(%d-)$");
					if(gsid and count) then
						gsid = tonumber(gsid);
						count = tonumber(count);
						loots[gsid] = count;
					end
				end
				arena.flee_loots = loots;
			end

			if(each_pvp_arena.attr.is_single_fight == "true") then
				arena.is_single_fight = true;
			end

			if(each_pvp_arena.attr.is_postlog_usecard == "true" and each_pvp_arena.attr.key_postlog_usecard) then
				arena.is_postlog_usecard = true;
				arena.key_postlog_usecard = each_pvp_arena.attr.key_postlog_usecard;
			end

			if(each_pvp_arena.attr.exp_formula) then
				arena.exp_formula = each_pvp_arena.attr.exp_formula;
			end
			
			if(each_pvp_arena.attr.entercombat_cost) then
				arena.entercombat_cost = each_pvp_arena.attr.entercombat_cost;
			end
			
			if(each_pvp_arena.attr.entercombat_is_full_health == "true") then
				arena.entercombat_is_full_health = true;
			end
			
			if(each_pvp_arena.attr.max_pvp_waiting_time) then
				arena.max_pvp_waiting_time = tonumber(each_pvp_arena.attr.max_pvp_waiting_time) * 1000; -- second to millisecond
			end
			
			if(each_pvp_arena.attr.apply_temp_anti_freeze_rounds_for_partners == "true") then
				arena.apply_temp_anti_freeze_rounds_for_partners = true;
			end
			
			if(each_pvp_arena.attr.prepare_time_pvp) then
				arena.prepare_time_pvp = tonumber(prepare_time_pvp);
			end
			
			local insurance_keys = {
				"insurance_and_loser_loots",
				"insurance_and_winner_loots",
				"prior_insurance_and_loser_loots",
				"prior_insurance_and_winner_loots",
				"prior_prior_insurance_and_loser_loots",
				"prior_prior_insurance_and_winner_loots",
				"prior_prior_prior_insurance_and_loser_loots",
				"prior_prior_prior_insurance_and_winner_loots",
			};

			local _, key;
			for _, key in ipairs(insurance_keys) do
				if(each_pvp_arena.attr[key]) then
					local insurance_gsid, insurance_loots = string.match(each_pvp_arena.attr[key], "^(.-)%+(.-)$")
					if(insurance_gsid and insurance_loots) then
						insurance_gsid = tonumber(insurance_gsid);
						local loots = {};
						local loot_gsid_count_pair;
						for loot_gsid_count_pair in string.gmatch(insurance_loots, "([^%(^%)]+)") do
							local gsid, count = string.match(loot_gsid_count_pair, "^(%d-),(%d-)$");
							if(gsid and count) then
								gsid = tonumber(gsid);
								count = tonumber(count);
								loots[gsid] = count;
							end
						end
						loots[insurance_gsid] = -1;
						arena[key] = {insurance_gsid = insurance_gsid, loots = loots};
					end
				end
			end
			
			if(each_pvp_arena.attr.players_atleast) then
				arena.players_atleast = tonumber(each_pvp_arena.attr.players_atleast);
			end
			
			if(each_pvp_arena.attr.players_max) then
				arena.players_max = tonumber(each_pvp_arena.attr.players_max);
			end
			
			if(each_pvp_arena.attr.players_max_eachside) then
				arena.players_max_eachside = tonumber(each_pvp_arena.attr.players_max_eachside);
			end

			if(each_pvp_arena.attr.ranking_stage) then
				arena.ranking_stage = each_pvp_arena.attr.ranking_stage;
				if(each_pvp_arena.attr.ranking_stage_score_from_level) then
					arena.ranking_stage_score_from_level = tonumber(each_pvp_arena.attr.ranking_stage_score_from_level);
				end
			end

			if(each_pvp_arena.attr.is_battlefield == "true") then
				arena.is_battlefield = true;
			end

			if(each_pvp_arena.attr.resource_id) then
				arena.resource_id = tonumber(each_pvp_arena.attr.resource_id);
			end

			if(each_pvp_arena.attr.fled_slot_life) then
				arena.fled_slot_life = tonumber(each_pvp_arena.attr.fled_slot_life) * 2; -- each advance turn
			end
			
			if(each_pvp_arena.attr.max_hp_fire and each_pvp_arena.attr.max_hp_ice and each_pvp_arena.attr.max_hp_storm and 
				each_pvp_arena.attr.max_hp_life and each_pvp_arena.attr.max_hp_death) then
				-- specific max_hp for each school
				arena.max_hp_fire = tonumber(each_pvp_arena.attr.max_hp_fire);
				arena.max_hp_ice = tonumber(each_pvp_arena.attr.max_hp_ice);
				arena.max_hp_storm = tonumber(each_pvp_arena.attr.max_hp_storm);
				arena.max_hp_life = tonumber(each_pvp_arena.attr.max_hp_life);
				arena.max_hp_death = tonumber(each_pvp_arena.attr.max_hp_death);
			end
			if(each_pvp_arena.attr.force_powerpipchance) then
				arena.force_powerpipchance = tonumber(each_pvp_arena.attr.force_powerpipchance);
			end
			if(each_pvp_arena.attr.force_accuracyboost) then
				arena.force_accuracyboost = tonumber(each_pvp_arena.attr.force_accuracyboost);
			end
			if(each_pvp_arena.attr.force_damageboost) then
				arena.force_damageboost = tonumber(each_pvp_arena.attr.force_damageboost);
			end
			if(each_pvp_arena.attr.force_resist) then
				arena.force_resist = tonumber(each_pvp_arena.attr.force_resist);
			end
			if(each_pvp_arena.attr.force_damageboost_absolute) then
				arena.force_damageboost_absolute = tonumber(each_pvp_arena.attr.force_damageboost_absolute);
			end
			if(each_pvp_arena.attr.force_resist_absolute) then
				arena.force_resist_absolute = tonumber(each_pvp_arena.attr.force_resist_absolute);
			end
			if(each_pvp_arena.attr.force_criticalstrike) then
				arena.force_criticalstrike = tonumber(each_pvp_arena.attr.force_criticalstrike);
			end
			if(each_pvp_arena.attr.force_resilience) then
				arena.force_resilience = tonumber(each_pvp_arena.attr.force_resilience);
			end
			if(each_pvp_arena.attr.force_outputhealboost) then
				arena.force_outputhealboost = tonumber(each_pvp_arena.attr.force_outputhealboost);
			end
			if(each_pvp_arena.attr.force_inputhealboost) then
				arena.force_inputhealboost = tonumber(each_pvp_arena.attr.force_inputhealboost);
			end
			if(each_pvp_arena.attr.force_skip_startup_pips == "true") then
				arena.force_skip_startup_pips = true;
			end
			
			if(each_pvp_arena.attr.OpenAllLifeHealPenalty == "true") then
				arena.OpenAllLifeHealPenalty = true;
			end
			if(each_pvp_arena.attr.AllLifeEveryRoundDamageBoost) then
				arena.AllLifeEveryRoundDamageBoost = tonumber(each_pvp_arena.attr.AllLifeEveryRoundDamageBoost);
			end
			
			if(each_pvp_arena.attr.bIncreasingDamage == "true") then
				arena.bIncreasingDamage = true;
			end
			
			if(each_pvp_arena.attr.bApplyWeakBuff == "true") then
				arena.bApplyWeakBuff = true;
			end
			
			if(each_pvp_arena.attr.bonus_pips_starting_defensive_units) then
				arena.bonus_pips_starting_defensive_units = tonumber(each_pvp_arena.attr.bonus_pips_starting_defensive_units);
			end
			
			-- reset pvp arena
			arena:Reset_pvp();
			-- append the arena ids
			table.insert(arena_ids, arena:GetID());
		end
	end
	return arena_ids;
end

-- set match info to prevent malicious player, only valid to red mushroom arenas
-- this function is invoked immediately after the arena is inited
function Arena.SetMatchInfo(arena_ids, match_info)
	local match_info_team1 = {};
	local match_info_team2 = {};
	local client_gearscore_map = {};
	if(match_info) then
		if(match_info.teams and match_info.teams[1] and match_info.teams[1].players and match_info.teams[1].owner_nid) then
			local near_team_players = match_info.teams[1].players;
			if(near_team_players) then
				local order = 2;
				local nid_str, player_info;
				for nid_str, player_info in pairs(near_team_players) do
					local nid = tonumber(nid_str);
					if(nid) then
						client_gearscore_map[nid] = player_info["gear_score"];
						if(match_info.teams[1].owner_nid == nid_str) then
							match_info_team1[nid] = 1;
						else
							match_info_team1[nid] = order;
							order = order + 1;
						end
					end
				end
			end
		end
		if(match_info.teams and match_info.teams[2] and match_info.teams[2].players and match_info.teams[2].owner_nid) then
			local far_team_players = match_info.teams[2].players;
			if(far_team_players) then
				local order = 2;
				local nid_str, player_info;
				for nid_str, player_info in pairs(far_team_players) do
					local nid = tonumber(nid_str);
					if(nid) then
						client_gearscore_map[nid] = player_info["gear_score"];
						if(match_info.teams[2].owner_nid == nid_str) then
							match_info_team2[nid] = 1;
						else
							match_info_team2[nid] = order;
							order = order + 1;
						end
					end
				end
			end
		end
	end
	local arena_id;
	for _, arena_id in ipairs(arena_ids) do
		-- singleton pvp arena
		if(arena_id) then
			local arena = Arena.GetArenaByID(arena_id);
			if(arena and arena.mode == "free_pvp") then
				arena.match_info = match_info;
				arena.client_gearscore_map = client_gearscore_map;
				arena.match_info_team1 = match_info_team1;
				arena.match_info_team2 = match_info_team2;
			end
		end
	end
end

-- DEPRACATED  2012/2/14
-- auto append the players onto the singleton pvp arena
-- this function is invoked immediately after the arena is inited
function Arena.AutoJoinPvPArena(arena_ids, match_info)
	-- we only join the first arena
	
	---- sample match_info:
	--commonlib.echo(match_info.teams[1].players)
	--commonlib.echo(match_info.teams[2].players)
	--echo:{["172545123"]={nid="172545123",serverid="191.",level=50,rank_index=1,},}
	--echo:{["46650264"]={nid="46650264",serverid="191.",level=50,rank_index=1,},}

	-- parse math_info
	local team_near = {};
	local is_team_near_empty = true;
	local team_far = {};
	local is_team_far_empty = true;
	if(match_info) then
		if(match_info.teams and match_info.teams[1] and match_info.teams[1].players) then
			local near_team_players = match_info.teams[1].players;
			if(near_team_players) then
				local nid_str, _;
				for nid_str, _ in pairs(near_team_players) do
					local nid = tonumber(nid_str);
					if(nid) then
						table.insert(team_near, nid);
						is_team_near_empty = false;
					end
				end
			end
		end
		if(match_info.teams and match_info.teams[2] and match_info.teams[2].players) then
			local far_team_players = match_info.teams[2].players;
			if(far_team_players) then
				local nid_str, _;
				for nid_str, _ in pairs(far_team_players) do
					local nid = tonumber(nid_str);
					if(nid) then
						table.insert(team_far, nid);
						is_team_far_empty = false;
					end
				end
			end
		end
	end

	-- push the players into arena
	if(not is_team_near_empty and not is_team_far_empty) then
		local arena_id;
		for _, arena_id in ipairs(arena_ids) do
		end
		-- singleton pvp arena
		if(arena_id) then
			local arena = Arena.GetArenaByID(arena_id);
			if(arena and arena.mode == "free_pvp") then
				local _, nid;
				for _, nid in ipairs(team_near) do
					Arena.OnReponse_TryEnterCombat(nid, arena_id, "near", petlevel, current_hp, max_hp, phase, deck_gsid, followpet_guid, deck_cards, deck_cards_rune, equipped_items, equipped_gems)
				end
				local _, nid;
				for _, nid in ipairs(team_far) do
					Arena.OnReponse_TryEnterCombat(nid, arena_id, "far", petlevel, current_hp, max_hp, phase, deck_gsid, followpet_guid, deck_cards, deck_cards_rune, equipped_items, equipped_gems)
				end
			end
		end
	end
end

-- append arena key rules
function Arena:AppendArenaKeyRule(rule)
	self.arena_key_rules = self.arena_key_rules or {};
	table.insert(self.arena_key_rules, rule);
end

-- set arena lock id
function Arena:SetArenaLockID(id)
	self.arena_lock_id = id;
end

-- get difficulty
function Arena:GetDifficulty()
	return self.difficulty;
end

-- is combat active
-- NOTE: combat is active only when at least one player is active
function Arena:IsCombatActive()
	local i;
	for i = 1, max_unit_count_per_side_arena * 2 do
		local nid = self.player_nids[i];
		if(nid) then
			local player = Player.GetPlayerCombatObj(nid)
			if(player and player:IsCombatActive()) then
				return true;
			end
		end
	end
	return false;
end

-- is player slot empty
function Arena:IsPlayerSlotEmpty()
	--[[
	local i;
	for i = 1, max_player_count_per_arena do
		local nid = self.player_nids[i];
		if(nid) then
			return false;
		end
	end
	return true;
	]]
	-- Note LiXizhi: following is a highly optimized code, since the profiler shows that this function ranks top 10 on game server. So let us do the optimization.
	local player_nids = self.player_nids;
	--return not (player_nids[1] or player_nids[2] or player_nids[3] or player_nids[4]);
	return not (player_nids[1] or player_nids[2] or player_nids[3] or player_nids[4] or player_nids[5] or player_nids[6] or player_nids[7] or player_nids[8]);
end

-- for all arenas, check each side validity, return true if and only if both side have at least one alive combat unit
function Arena:IsBothSideWithAliveUnit()
	local bNearArenaWithAliveUnit = false;
	local bFarArenaWithAliveUnit = false;

	local i;
	-- check near arena combat units
	if(not bNearArenaWithAliveUnit) then
		for i = 1, max_unit_count_per_side_arena do
			local nid = self.player_nids[i];
			if(nid) then
				local player = Player.GetPlayerCombatObj(nid);
				if(player and player:IsAlive()) then
					bNearArenaWithAliveUnit = true;
					break;
				end
			end
			local id = self.mob_ids[max_unit_count_per_side_arena * 2 + 1 - i];
			if(id) then
				local mob = Mob.GetMobByID(id);
				if(mob and mob:IsAlive()) then
					bNearArenaWithAliveUnit = true;
					break;
				end
			end
		end
	end
	-- check far arena combat units
	if(not bFarArenaWithAliveUnit) then
		for i = max_unit_count_per_side_arena + 1, max_unit_count_per_side_arena * 2 do
			local nid = self.player_nids[i];
			if(nid) then
				local player = Player.GetPlayerCombatObj(nid);
				if(player and player:IsAlive()) then
					bFarArenaWithAliveUnit = true;
					break;
				end
			end
			local id = self.mob_ids[max_unit_count_per_side_arena * 2 + 1 - i];
			if(id) then
				local mob = Mob.GetMobByID(id);
				if(mob and mob:IsAlive()) then
					bFarArenaWithAliveUnit = true;
					break;
				end
			end
		end
	end
	
	return bNearArenaWithAliveUnit and bFarArenaWithAliveUnit;
end

-- NOTE 2011/9/21: special fix for 2v2 pvp arena
-- check player count for arena with players_atleast attribute
-- @return true if player count is correct
function Arena:IsProperPlayerCount()
	if(not self.players_atleast) then
		return true;
	end
	local i;
	local player_count = 0;
	for i = 1, max_unit_count_per_side_arena * 2 do
		local nid = self.player_nids[i];
		if(nid) then
			local player = Player.GetPlayerCombatObj(nid);
			if(player and player:IsAlive()) then
				player_count = player_count + 1;
			end
		end
	end
	if(player_count >= self.players_atleast) then
		return true;
	end
	return false;
end

-- if all players pick their cards
function Arena:IfAllPlayerPickedCard()
	-- first check if arena contains only one valid player
	-- one player don't require heart arrest test
	local player_count = 0;
	local i;
	for i = 1, max_player_count_per_arena do
		local nid = self.player_nids[i];
		if(nid) then
			local player = Player.GetPlayerCombatObj(nid);
			if(player and player:IsCombatActive()) then
				player_count = player_count + 1;
			end
		end
	end
	-- if player_count is 1, don't require heart arrest test
	local i;
	for i = 1, max_player_count_per_arena do
		local nid = self.player_nids[i];
		if(nid) then
			local player = Player.GetPlayerCombatObj(nid);
			if(player and player:IsCombatActive()) then
				if(player_count == 1) then
					if(not player:IfPickedCard()) then
						return false;
					end
				else
					if(player:IsAlive() and not player:IsHeartArrest() and not player:IfPickedCard()) then
						return false;
					end
				end
			end
		end
	end
	return true;
end

-- if all players pick their cards
function Arena:IfAllPlayerPickedCard_v()
	-- first check if arena contains only one valid player
	-- one player don't require heart arrest test
	local player_count = 0;
	local friendlys, hostiles = self:GetFriendlyAndHostileUnits(self.currentPlayingSide);
	if(friendlys) then
		local _, unit;
		for _, unit in ipairs(friendlys) do
			if(not unit.isMob) then
				local player = Player.GetPlayerCombatObj(unit.id);
				if(player and player:IsCombatActive()) then
					player_count = player_count + 1;
				end
			end
		end
		-- if player_count is 1, don't require heart arrest test
		local _, unit;
		for _, unit in ipairs(friendlys) do
			if(not unit.isMob) then
				local player = Player.GetPlayerCombatObj(unit.id);
				if(player and player:IsCombatActive()) then
					if(player_count == 1) then
						if(not player:IfPickedCard()) then
							return false;
						else
							return true;
						end
					else
						if(player:IsAlive() and not player:IsHeartArrest() and not player:IfPickedCard()) then
							return false;
						end
					end
				end
			end
		end
		return true;
	end
	return false;
end

-- pick default pass card for players that didn't choose card before timeout
function Arena:PickPassForNonPickedPlayer()
	local i;
	for i = 1, max_player_count_per_arena do
		local nid = self.player_nids[i];
		if(nid) then
			local player = Player.GetPlayerCombatObj(nid);
			if(System.options.version == "teen") then
				if(player and player:IsCombatActive()) then
					if(player:IfPickedCard()) then
						player.nIdleRounds = 0;
					else
						player.nIdleRounds = (player.nIdleRounds or 0) + 1;
					end
				end
			end
			if(player and not player:IfPickedCard()) then
				player:PickCard("Pass", 0, false, player:GetID());
			end
		end
	end
end

-- added by LiXizhi 2012.1.31 for battle field 
-- return 0 if player is on the near side, or 1 if player is on far side, or nil if not found on arena. 
-- @param nid: the nid number
function Arena:GetPlayerSide_v(nid)
	local i;
	for i = 1, max_unit_count_per_side_arena * 2 do
		if(nid == self.player_nids[i]) then
			if(i<=max_unit_count_per_side_arena) then
				return 0
			else
				return 1
			end
		end
	end
end

-- added by LiXizhi 2012.1.31 for battle field 
-- return iterator of index, nid of players of the given side, where index is self.player_nids[i] and nid is number.
-- @param arena_side: 0 if near side, 1 if far side. nil, if both sides. 
function Arena:ForEachPlayer(arena_side)
	local from, to;
	if(arena_side == 0) then
		from = 1;
		to = max_unit_count_per_side_arena;
	elseif(arena_side == 1) then
		from = max_unit_count_per_side_arena+1;
		to = max_unit_count_per_side_arena * 2;
	else
		from = 1;
		to = max_unit_count_per_side_arena * 2;
	end
	local i = from;
	return function()
		for i = from, to do
			local nid = self.player_nids[i];
			if(nid) then
				from = i+1;
				return i, nid
			end
		end
	end
end

-- added by LiXizhi 2012.1.31 for battle field 
-- get player count
-- @param arena_side: 0 if near side, 1 if far side. nil, if both sides. 
function Arena:GetPlayerCount(arena_side)
	local from, to;
	if(arena_side == 0) then
		from = 1;
		to = max_unit_count_per_side_arena;
	elseif(arena_side == 1) then
		from = max_unit_count_per_side_arena+1;
		to = max_unit_count_per_side_arena * 2;
	else
		from = 1;
		to = max_unit_count_per_side_arena * 2;
	end
	local count = 0;
	local i;
	for i = from, to do
		local nid = self.player_nids[i];
		if(nid) then
			count = count + 1;
		end
	end
	return count;
end

-- pick default pass card for players that didn't choose card before timeout
function Arena:PickPassForNonPickedPlayer_v()
	if(System.options.version == "kids" and self.ranking_stage and string.match(self.ranking_stage,"3v3")) then
		if(not self.currentPlayingSide) then
			-- setup init playing side
			if(self.isNearArenaFirst == true) then
				self.currentPlayingSide = "near";
			elseif(self.isNearArenaFirst == false) then
				self.currentPlayingSide = "far";
			end
		end

		local friendlys, hostiles = self:GetFriendlyAndHostileUnits(self.currentPlayingSide);

		local _, unit;
		for _, unit in ipairs(friendlys) do
			if(not unit.isMob) then
				local player = Player.GetPlayerCombatObj(unit.id);
				if(player and player.current_hp <= 0) then
							player.nIdleRounds = 0;
							player.accumulateIdleRounds = 0;
				elseif (player and player:IsCombatActive()) then
					if (player:IfPickedCard()) then
						player.nIdleRounds = 0;
					else
						if((not player.bStunned) and (player.freeze_rounds == 0)) then
							player.nIdleRounds = (player.nIdleRounds or 0) + 1;
							player.accumulateIdleRounds = (player.accumulateIdleRounds or 0) + 1;
						end
					end
				end
			end
		end
	end
	local i;
	for i = 1, max_unit_count_per_side_arena * 2 do
		local nid = self.player_nids[i];
		if(nid) then
			local player = Player.GetPlayerCombatObj(nid);
			
			if(player and player:IsCombatActive() and not player:IfPickedCard()) then
				player:PickCard("Pass", 0, false, player:GetID());
			end
		end
	end
end

-- if all players finished play turn
function Arena:IfAllPlayerFinishedPlayTurn()
	-- first check if arena contains only one valid player
	-- one player don't require heart arrest test
	local player_count = 0;
	local i;
	for i = 1, max_unit_count_per_side_arena * 2 do
		local nid = self.player_nids[i];
		if(nid) then
			local player = Player.GetPlayerCombatObj(nid);
			if(player and player:IsCombatActive() and not player:IsMinion()) then
				player_count = player_count + 1;
			end
		end
	end
	-- if player_count is 1, don't require heart arrest test
	local i;
	for i = 1, max_unit_count_per_side_arena * 2 do
		local nid = self.player_nids[i];
		if(nid) then
			local player = Player.GetPlayerCombatObj(nid);
			if(player and player:IsCombatActive() and not player:IsMinion()) then
				if(player_count == 1) then
					if(not player:IfFinishedPlayTurn()) then
						return false;
					end
				else
					if(not player:IsHeartArrest() and not player:IfFinishedPlayTurn()) then
						return false;
					end
				end
			end
		end
	end
	return true;
end

-- check if the combat is finished
-- NOTE: either side (mob or player) object health point is all 0 means defeated
function Arena:IsCombatFinished()
	local bPlayerDefeated = true;
	local bMobDefeated = true;
	-- check if each player is alive
	local i;
	for i = 1, max_player_count_per_arena do
		local nid = self.player_nids[i];
		if(nid) then
			local player = Player.GetPlayerCombatObj(nid);
			if(player and player:IsAlive() and (DEBUG_KEEPCOMBAT_ALIVE_IF_ONLY_MINION_LEFT or not player:IsMinion())) then
				bPlayerDefeated = false;
				break;
			end
		end
	end
	-- check if each mob is alive
	local index, id;
	for index, id in ipairs(self.mob_ids) do
		local mob = Mob.GetMobByID(id);
		if(mob and mob:IsAlive()) then
			bMobDefeated = false;
			break;
		end
	end
	return bPlayerDefeated or bMobDefeated;
end

-- check if the combat is finished
-- NOTE: either side (mob or player) object health point is all 0 means defeated
function Arena:IsCombatFinished_v()
	local friendlys, hostiles = self:GetFriendlyAndHostileUnits("near");

	local bNearSideDefeated = true;
	local bFarSideDefeated = true;
	-- check if each player is alive
	local _, unit;
	for _, unit in ipairs(friendlys) do
		local unit = Arena.GetCombatUnit(unit.isMob, unit.id)
		if(unit and unit:IsAlive()) then
			bNearSideDefeated = false;
			break;
		end
	end
	local _, unit;
	for _, unit in ipairs(hostiles) do
		local unit = Arena.GetCombatUnit(unit.isMob, unit.id)
		if(unit and unit:IsAlive()) then
			bFarSideDefeated = false;
			break;
		end
	end
	return bNearSideDefeated or bFarSideDefeated;
end

-- call a given function(func_) for each active and alive combat units, including mobs and players
-- @param func_: a function(unit) end
function Arena:DoEachActiveAndAliveCombatUnits(func_)
	-- get all active player units
	local i;
	for i = 1, max_unit_count_per_side_arena * 2 do
		local nid = self.player_nids[i];
		if(nid) then
			-- pass 3.1: set all current available players active
			local player = Player.GetPlayerCombatObj(nid);
			if(player and player:IsCombatActive() and player:IsAlive()) then
				func_(player);
			end
		end
	end
	-- get all active mob units
	local index, id;
	for index, id in ipairs(self.mob_ids) do
		local mob = Mob.GetMobByID(id);
		if(mob and mob:IsAlive()) then
			func_(mob);
		end
	end
end

-- get all active and alive combat units, including mobs and players
function Arena:GetActiveAndAliveCombatUnits()
	local units = {};
	-- get all active player units
	local i;
	for i = 1, max_unit_count_per_side_arena * 2 do
		local nid = self.player_nids[i];
		if(nid) then
			-- pass 3.1: set all current available players active
			local player = Player.GetPlayerCombatObj(nid);
			if(player and player:IsCombatActive() and player:IsAlive()) then
				table_insert(units, player);
			end
		end
	end
	-- get all active mob units
	local index, id;
	for index, id in ipairs(self.mob_ids) do
		local mob = Mob.GetMobByID(id);
		if(mob and mob:IsAlive()) then
			table_insert(units, mob);
		end
	end
	return units;
end

-- get friendly and hostile units, NOT INCLUDING inactive players
-- @return friendlys, hostiles: example: {{isMob = false, id = nid}, {isMob = true, id = id}, ...}
function Arena:GetFriendlyAndHostileUnits(side)
	local friendlys = {};
	local hostiles = {};
	local i;
	for i = 1, max_unit_count_per_side_arena do
		local nid = self.player_nids[i];
		if(nid) then
			local player = Player.GetPlayerCombatObj(nid);
			if(player and player:IsCombatActive()) then
				table.insert(friendlys, {isMob = false, id = nid});
			end
		end
		local id = self.mob_ids[max_unit_count_per_side_arena * 2 + 1 - i];
		if(id) then
			local mob = Mob.GetMobByID(id);
			if(mob) then
				table.insert(friendlys, {isMob = true, id = id});
			end
		end
	end
	for i = max_unit_count_per_side_arena + 1, max_unit_count_per_side_arena * 2 do
		local nid = self.player_nids[i];
		if(nid) then
			local player = Player.GetPlayerCombatObj(nid);
			if(player and player:IsCombatActive()) then
				table.insert(hostiles, {isMob = false, id = nid});
			end
		end
		local id = self.mob_ids[max_unit_count_per_side_arena * 2 + 1 - i];
		if(id) then
			local mob = Mob.GetMobByID(id);
			if(mob) then
				table.insert(hostiles, {isMob = true, id = id});
			end
		end
	end
	if(side == "near") then
		return friendlys, hostiles;
	elseif(side == "far") then
		return hostiles, friendlys;
	end
end

-- update the arena data to client
-- @param nid:  if nid is provided, send the data only to specific player
--				if nid is not provided, send the data to hosting clients
function Arena:UpdateToClient(nid)
	local key, value = self:GetKey_normal_update(), self:GetValue_normal_update();
	local inactive_key, inactive_value = self:GetInactivePlayerKey_normal_update(), self:GetInactivePlayerValue_normal_update();
	if(not key or not value or not inactive_key or not inactive_value) then
		return;
	end
	-- real time update
	local realtime_msg = format("ArenaUpdate:%s+%s+%s+%s", key, value, inactive_key, inactive_value);
	if(nid) then
		combat_server.AppendRealTimeMessageToNID(self.combat_server_uid, nid, realtime_msg);
	else
		combat_server.AppendRealTimeMessage(self.combat_server_uid, realtime_msg);
	end
	-- normal update
	combat_server.AppendNormalUpdateMessage(self.combat_server_uid, key, value);
	combat_server.AppendNormalUpdateMessage(self.combat_server_uid, inactive_key, inactive_value);
end

-- update the arena data to client
-- @param nid:  if nid is provided, send the data only to specific player
function Arena:UpdateToClient_EnterCombat(nid)
	local key, value = self:GetKey_normal_update(), self:GetValue_normal_update();
	local inactive_key, inactive_value = self:GetInactivePlayerKey_normal_update(), self:GetInactivePlayerValue_normal_update();
	if(not key or not value or not inactive_key or not inactive_value) then
		return;
	end
	-- real time update
	local realtime_msg = format("ArenaUpdate_EnterCombat:%s+%s+%s+%s+%s+%s", key, value, inactive_key, inactive_value, self.mode, tostring(self:GetDifficulty()));
	if(nid) then
		combat_server.AppendRealTimeMessageToNID(self.combat_server_uid, nid, realtime_msg);
	else
		combat_server.AppendRealTimeMessage(self.combat_server_uid, realtime_msg);
	end

	if(nid) then
		local player = Player.GetPlayerCombatObj(nid);
		if(player) then
			if(player and not player:IsCombatActive()) then
				if(self.PickCardTimeOutTime) then
					local remaining_time = self.PickCardTimeOutTime - combat_server.GetCurrentTime();
					if(remaining_time > 0) then
						local realtime_msg = format("PickYourCard_idle:%d,%s,%d", remaining_time, self.mode, self:GetRoundTag());
						combat_server.AppendRealTimeMessageToNID(self.combat_server_uid, nid, realtime_msg);
					end
				elseif(not self.nCombatStartTime or (self.nCombatStartTime and (combat_server.GetCurrentTime() < self.nCombatStartTime))) then
					local realtime_msg = "PickYourCard_waiting_for_start:"..self.mode;
					combat_server.AppendRealTimeMessageToNID(self.combat_server_uid, nid, realtime_msg);
				end
			end
		end
	end
	
	-- normal update
	combat_server.AppendNormalUpdateMessage(self.combat_server_uid, key, value);
	combat_server.AppendNormalUpdateMessage(self.combat_server_uid, inactive_key, inactive_value);
end

-- on frame move arena objects
-- @param curTime: current game server time in milli-seconds
function Arena.OnFrameMove_for_serverobject(curTime, arena_ids)
	if(debug_dump_per_frame) then
		LOG.std(nil, "user","arena","begin frame move all");
	end
	--commonlib.applog("Arena.OnFrameMove_all %d", curTime);
	--log("------------------------------------ begin frame move all ------------------------------------\n");
	local _, arena_id;
	for _, arena_id in pairs(arena_ids) do
		local arena = Arena.GetArenaByID(arena_id);
		if(arena) then
			arena:OnFrameMove(curTime);
		end
	end
	if(debug_dump_per_frame) then
		LOG.std(nil, "user","arena","end frame move all");
	end
	--log("------------------------------------ end frame move all ------------------------------------\n");
end

-- on frame move for nid related arena object
-- @param nid: on frame move for nid
-- @param curTime: current game server time in milli-seconds
function Arena.OnFrameMove_for_nid(nid, curTime)
	local player = Player.GetPlayerCombatObj(nid);
	if(player) then
		local arena_id = player.arena_id;
		if(arena_id) then
			local arena = Arena.GetArenaByID(arena_id)
			if(arena) then
				arena:OnFrameMove(curTime);
			end
		end
	end
end


-- on frame move each arena object
-- NOTE: a complete process of one turn is:
-- 1. arena is not active and at least one player is added to the arena
-- 2. waiting for other player to join, 5 seconds
-- 3. StartCombat() after 5 seconds
-- {
-- 4. AdvanceOneTurn(): PickCardTimeOutTime = 30000 + current
--						PlayTurnTimeOutTime = nil
-- 5. waiting for player cards until 6. or 7.
-- 6. if times out all player choose default "Pass" action goto 8.
-- 7. if all player cards choosed goto 8.
-- 8. PlayOneTurn():   PickCardTimeOutTime = nil
--					PlayTurnTimeOutTime = max_spell_play_time + current
-- 9. waiting for player finish playing the spells until 6. or 7.
-- 10. if times out goto 12.
-- 11. if all player finished playing goto 12.
-- 12. FinishOneTurn(): Normal Update Arena data, if either side has object alive, go back to 4.
-- 13. if all entities died on any side or both side, goto 14.
-- }
-- 14. FinishCombat()
-- @param curTime: current game server time in milli-seconds
function Arena:OnFrameMove(curTime)
	self:DebugDumpDataPerFrame("------------------ begin frame move ------------------");
	
	if(self.locked_for_teamleaderid and self.locked_for_teamleaderid > 0) then
		if((combat_server.GetCurrentTime() - self.locked_for_teamleaderid_time) > 5000) then
			self.locked_for_teamleaderid = 0;
		end
	end

	if(self.is_battlefield) then
		local near_count = 0;
		local far_count = 0;
		local i;
		for i = 1, max_unit_count_per_side_arena * 2 do
			local nid = self.player_nids[i];
			if(nid) then
				local player = Player.GetPlayerCombatObj(nid);
				if(player and player:IsAlive()) then
					if(player.side == "near") then
						near_count = near_count + 1;
					elseif(player.side == "far") then
						far_count = far_count + 1;
					end
				end
			end
		end
		Arena.UpdateResourcePoint(self, near_count, far_count)
	end

	if(self.timeofday) then
		local current_time = ParaGlobal.GetTimeFormat("HH:mm");
		local current_time_number = string.gsub(current_time, ":", "");
		current_time_number = tonumber(current_time_number);
		if(current_time_number) then
			if(current_time_number >= self.timeofday) then
				if(self.is_last_current_time_test_smaller) then
					if(self.respawn_time == nil) then
						self.respawn_time = combat_server.GetCurrentTime() + 1000;
						return;
					end
				end
				self.is_last_current_time_test_smaller = false;
			else
				self.is_last_current_time_test_smaller = true;
			end
		end
	end
	
	if(self.timeofday_close) then
		local current_time = ParaGlobal.GetTimeFormat("HH:mm");
		local current_time_number = string.gsub(current_time, ":", "");
		current_time_number = tonumber(current_time_number);
		if(current_time_number) then
			if(current_time_number >= self.timeofday_close) then
				self.respawn_time = nil;
				if(not self:IsCombatActive() and self:IsPlayerSlotEmpty()) then
					self:ResetAndKillAll_pve();
				end
			end
		end
	end

	if(self.respawn_time) then
		if(self.respawn_time < curTime) then
			self.respawn_time = nil;
			-- respawn all related mobs
			self:RespawnAll_pve();
			return;
		else
			return;
		end
	end
	---- NOTE: combat_server.GetCurrentTime() is not valid until the next frame move
	---- respawn_time is not updated immediately in init process
	---- respawn_time is updated in the first frame move
	--if(self.force_next_respawn_interval) then
		--self.respawn_time = combat_server.GetCurrentTime() + self.force_next_respawn_interval;
		--self.force_next_respawn_interval = nil;
	--end

	
	if(self.timeofday) then
		local current_time = ParaGlobal.GetTimeFormat("HH:mm");
		if(current_time == self.timeofday) then
			self.respawn_time = combat_server.GetCurrentTime() + 1000;
			self.timeofday = nil;
		end
	end

	if(self:IsPlayerSlotEmpty()) then
		return;
	end
	-- at least one player on arena slot
	local isActive = self:IsCombatActive();
	if(isActive == false) then
		-- wait for 5 seconds to start
		if(not self.nCombatStartTime) then
			if(self.mode == "pve") then
				if(self.locked_for_teamleaderid) then
					self.nCombatStartTime = curTime + arenastart_prepare_time_pve_teamed;
					self.nCombatStartTime_first = curTime + arenastart_prepare_time_pve_teamed;
				else
					self.nCombatStartTime = curTime + arenastart_prepare_time_pve_single;
					self.nCombatStartTime_first = curTime + arenastart_prepare_time_pve_single;
				end
			elseif(self.mode == "free_pvp") then
				self.nCombatStartTime = curTime + (self.prepare_time_pvp or arenastart_prepare_time_pvp);
				self.nCombatStartTime_first = curTime + (self.prepare_time_pvp or arenastart_prepare_time_pvp);
			end
		end
		if(self.nCombatStartTime < curTime) then
			if(self.mode == "pve") then
				-- setup basic params
				self:StartCombat();
				-- advance one turn
				self:AdvanceOneTurn();
			elseif(self.mode == "free_pvp") then
				-- wait until both side has available combat units
				if(self:IsBothSideWithAliveUnit() and self:IsProperPlayerCount()) then
					-- setup basic params and start immediately
					self:StartCombat_v();
					-- advance one turn
					self:AdvanceOneTurn_v();
				else
					-- wait for another 5 seconds to start
					self.nCombatStartTime = curTime + (self.prepare_time_pvp or arenastart_prepare_time_pvp);
					if(self.max_pvp_waiting_time and (self.nCombatStartTime - self.nCombatStartTime_first) > self.max_pvp_waiting_time) then
						-- finish combat, skip the start process(which will win if opposite player is absent)
						self:FinishCombat_v();
						---- NOTE: little tricky to start combat and finish immediately
						--self:StartCombat_v();
						--self:AdvanceOneTurn_v();
						---- finish combat
						--self:FinishCombat_v();
					end
					-- inform all valid players waiting for start
					self:InformWaitingForStart_v();
				end
			end
		end
	else
		if(self.mode == "pve") then
			if(self.PickCardTimeOutTime and not self.PlayTurnTimeOutTime) then
				if(self.PickCardTimeOutTime < curTime) then
					-- pick card times out all player choose default "Pass" action
					self:PickPassForNonPickedPlayer();
					self:PlayOneTurn();
				elseif(self:IfAllPlayerPickedCard()) then
					-- pick card times out all player choose default "Pass" action
					-- NOTE: player maybe offline due to heart arrest
					self:PickPassForNonPickedPlayer();
					-- waiting for the player card pick
					-- check if all player cards chosen
					-- play one turn
					self:PlayOneTurn();
				end
			elseif(not self.PickCardTimeOutTime and self.PlayTurnTimeOutTime) then
				if(self.PlayTurnTimeOutTime < curTime) then
					-- finish one turn
					self:FinishOneTurn();
				elseif(self.PlayTurnMinTime > curTime) then
					-- do nothing, haven't exceed the min play turn time
				elseif(self:IfAllPlayerFinishedPlayTurn()) then
					-- waiting for the player to play turn spells
					-- check if all player finished playing this turn
					-- finish one turn
					self:FinishOneTurn();
				end
			end
		elseif(self.mode == "free_pvp") then
			
			-- check the ranking point on every arena frame move
			-- update the player winning and losing point change after all player data is refreshed
			self:CheckSyncAllPlayersRankingPoint()

			if(self.PickCardTimeOutTime and not self.PlayTurnTimeOutTime) then
				if(self.PickCardTimeOutTime < curTime) then
					-- pick card times out all player choose default "Pass" action
					self:PickPassForNonPickedPlayer_v();
					self:PlayOneTurn_v();
				elseif(self:IfAllPlayerPickedCard_v()) then
					-- pick card times out all player choose default "Pass" action
					-- NOTE: player maybe offline due to heart arrest
					self:PickPassForNonPickedPlayer_v();
					-- waiting for the player card pick
					-- check if all player cards chosen
					-- play one turn
					self:PlayOneTurn_v();
				end
			elseif(not self.PickCardTimeOutTime and self.PlayTurnTimeOutTime) then
				if(self.PlayTurnTimeOutTime < curTime) then
					-- finish one turn
					self:FinishOneTurn_v();
				elseif(self.PlayTurnMinTime > curTime) then
					-- do nothing, haven't exceed the min play turn time
				elseif(self:IfAllPlayerFinishedPlayTurn()) then
					-- waiting for the player to play turn spells
					-- check if all player finished playing this turn
					-- finish one turn
					self:FinishOneTurn_v();
				end
			end
		end
	end
	self:DebugDumpDataPerFrame("------------------ end frame move ------------------");
end

function Arena:CheckSyncAllPlayersRankingPoint()
	if(self.bAllPlayerResyncedRankingPoints) then
		return true;
	end

	local bAllPlayerResynced = true;
	for i = 1, max_unit_count_per_side_arena * 2 do
		local nid = self.player_nids[i];
		if(nid) then
			-- pass 3.1: set all current available players active
			local player = Player.GetPlayerCombatObj(nid);
			if(player) then
				if(not player.bResyncCombatItems) then
					bAllPlayerResynced = false;
					break;
				end
			end
		end
	end
	if(bAllPlayerResynced) then
		self.bAllPlayerResyncedRankingPoints = true;
		return true;
	end
end

function Arena:GetCombatElapsedTime()
	return self.nCombatStartTime and (combat_server.GetCurrentTime() - self.nCombatStartTime) or 0;
end

-- calculate the ranking points
-- update the player winning and losing point change after all player data is refreshed
function Arena:CalculateWinningAndLosingRankingPoint()
	if(not self:CheckSyncAllPlayersRankingPoint()) then
		return;
	end
	local combatElapsedTime = self:GetCombatElapsedTime();
	-- calculate each player winning and losing ranking points
		
	-- calculate avarage arena player ranking
	local near_arena_ranking_sum = 0;
	local far_arena_ranking_sum = 0;
	local near_arena_ranking_count = 0;
	local far_arena_ranking_count = 0;
	local avg_near_arena_ranking = 0;
	local avg_far_arena_ranking = 0;
	local max_near_arena_ranking = 0;
	local max_far_arena_ranking = 0;
	local i;
	local player_sides = {near = {},far = {},};
	--if(System.options.version == "kids" and self.ranking_stage and self.ranking_stage == "3v3") then
		---- 3v3 pvp can't calculate these above value,because the score value is defined beforehand;
		--if(not pvp_3v3_score_times_per_day) then
			---- 50420 3v3积分每天可以获得次数标记
			--local gsItem = PowerItemManager.GetGlobalStoreItemInMemory(50420);
			--if(gsItem) then
				--pvp_3v3_score_times_per_day = gsItem.template.maxcount;
			--end
		--end
	--else
	if(true) then
		for i = 1, max_unit_count_per_side_arena do
			-- near side units
			local nid = self.player_nids[i];
			if(nid) then
				local player_object = Player.GetPlayerCombatObj(nid);
				if(player_object) then
					player_sides.near[nid] = true;
					local is_update_to_date, rank_date = player_object:CheckRankingItems(self.ranking_stage);
					--local ranking = player_object:GetVirtualRankingScore(self.ranking_stage);
					--if(System.options.version == "kids") then
						--ranking = player_object:GetRanking(self.ranking_stage);
					--end
					local ranking = player_object:GetRanking(self.ranking_stage);
					--if(is_update_to_date) then
						--ranking = player_object:GetRanking(self.ranking_stage);
					--else
						--ranking = 1000;
					--end
					if(ranking) then
						near_arena_ranking_sum = near_arena_ranking_sum + ranking;
						near_arena_ranking_count = near_arena_ranking_count + 1;
						if(ranking > max_near_arena_ranking) then
							max_near_arena_ranking = ranking;
						end
					end
				end
			end
		end
		for i = max_unit_count_per_side_arena + 1, max_unit_count_per_side_arena * 2 do
			-- far side units
			local nid = self.player_nids[i];
			if(nid) then
				local player_object = Player.GetPlayerCombatObj(nid);
				if(player_object) then
					player_sides.far[nid] = true;
					local is_update_to_date, rank_date = player_object:CheckRankingItems(self.ranking_stage);
					--local ranking = player_object:GetVirtualRankingScore(self.ranking_stage);
					--if(System.options.version == "kids") then
						--ranking = player_object:GetRanking(self.ranking_stage);
					--end
					local ranking = player_object:GetRanking(self.ranking_stage);
					--if(is_update_to_date) then
						--ranking = player_object:GetRanking(self.ranking_stage);
					--else
						--ranking = 1000;
					--end
					if(ranking) then
						far_arena_ranking_sum = far_arena_ranking_sum + ranking;
						far_arena_ranking_count = far_arena_ranking_count + 1;
						if(ranking > max_far_arena_ranking) then
							max_far_arena_ranking = ranking;
						end
					end
				end
			end
		end
	end
		
		
	
	-- average ranking score on arena
	local arena_ranking_avg_score;
	if(System.options.version == "kids" and self.ranking_stage and self.ranking_stage == "3v3") then
		for i = 1, max_unit_count_per_side_arena * 2 do
			local nid = self.player_nids[i];
			if(nid) then
				local player = Player.GetPlayerCombatObj(nid);
				if(player) then
					local is_update_to_date, rank_date = player:CheckRankingItems(self.ranking_stage);
					local server_gs = player:GetHistoryGearScore();
					local client_gs = self.client_gearscore_map[nid];
					local str_gs = string.format("nid [%s] client_gs [%d] server_gs [%d]", nid, client_gs, server_gs);
					local beGearscoreAbnormal = false;
					if(server_gs ~= client_gs) then
						beGearscoreAbnormal = true;
						LOG.std(nil, "user", "MarkWinningAndLosingRankingPoint", "%d client gearscore is different from server gearscore in %s", nid, self.ranking_stage);

						combat_server.AppendPostLog( {
							action = "arena_gearscore_abnormal_log", 
							pvp_stage = self.ranking_stage,
							client_gs = client_gs, 
							server_gs = server_gs,
							nid = nid,
							reason = "error",
						});
					end

					player.win_ranking_point_gsid = 20091;
					player.lose_ranking_point_gsid = 20091;
					--local bHas, _, __, copies = PowerItemManager.IfOwnGSItem(nid, 50420);
					--if(not copies or copies < pvp_3v3_score_times_per_day) then
					if(player.canGet3v3Award) then
						if(player.canGetMore3v3Award) then
							player.win_ranking_point_count = 50;
							player.lose_ranking_point_count = 20;
						else
							player.win_ranking_point_count = 10;
							player.lose_ranking_point_count = 0;
						end
					else
						player.win_ranking_point_count = 0;
						player.lose_ranking_point_count = 0;
					end
					--if(beGearscoreAbnormal) then
						--player.win_ranking_point_count = 0;
						--player.lose_ranking_point_count = 0;
					--end
				end
			end
		end
	elseif(System.options.version == "teen" and self.ranking_stage and self.ranking_stage == "1v1") then
		for i = 1, max_unit_count_per_side_arena * 2 do
			local nid = self.player_nids[i];
			if(nid) then
				local win_ranking_point_gsid = nil;
				local win_ranking_point_count = nil;
				local lose_ranking_point_gsid = nil;
				local lose_ranking_point_count = nil;

				local self_socre,opposite_score;

				local player = Player.GetPlayerCombatObj(nid);
				if(player) then
					local is_update_to_date, rank_date = player:CheckRankingItems(self.ranking_stage);
						
					if(player_sides.near[nid]) then
						self_score = near_arena_ranking_sum;
						opposite_score = far_arena_ranking_sum;
					elseif(player_sides.far[nid]) then
						self_score = far_arena_ranking_sum;
						opposite_score = near_arena_ranking_sum;
					end
					win_ranking_point_count = math.floor(math.min(math.max((20*(1+2*(opposite_score-self_score)/self_score)),1),50))
					lose_ranking_point_count = math.floor(math.max((1500-self_score)/50*((2*self_score)/(self_score+opposite_score)),-50));
				end

				if(self.ranking_stage == "1v1") then
					if(win_ranking_point_count >= 0) then
						-- 20046_RedMushroomPvP_1v1_PositiveRankingPoints			
						win_ranking_point_gsid = 20046;
					else
						win_ranking_point_gsid = 20047;
						win_ranking_point_gsid = -win_ranking_point_gsid;
					end
						
				elseif(self.ranking_stage == "2v2" and win_ranking_point_count >= 0) then
					-- 20048_RedMushroomPvP_2v2_PositiveRankingPoints
					win_ranking_point_gsid = 20048;
				end
							
				if(self.ranking_stage == "1v1") then
					if(lose_ranking_point_count >= 0) then
						-- 20046_RedMushroomPvP_1v1_PositiveRankingPoints			
						lose_ranking_point_gsid = 20046;
					else
						lose_ranking_point_gsid = 20047;
						lose_ranking_point_count = -lose_ranking_point_count;
					end
				elseif(self.ranking_stage == "2v2" and lose_ranking_point_count >= 0) then
					-- 20049_RedMushroomPvP_2v2_NegativeRankingPoints
					lose_ranking_point_gsid = 20049;
				end

				-- 20054_FamilyWinnerCountForPvp
				-- 20055_FamilyWinnerCountForPvp_Binding
				local winning_final_score = player:GetRanking(self.ranking_stage) + win_ranking_point_count;
				local badge_count = math.ceil(winning_final_score / 100) * math.ceil(winning_final_score / 100);
				player.win_ranking_additional_loots = {
					[20054] = badge_count,
					[20055] = badge_count,
				};
						
				if(self.ranking_stage_score_from_level) then
					local level = player:GetLevel();
					if(level < self.ranking_stage_score_from_level) then
						--win_ranking_point_count = 0;
						--lose_ranking_point_count = 0;
						player.win_ranking_additional_loots = nil;
					end
				end

				player.win_ranking_point_gsid = win_ranking_point_gsid;
				player.lose_ranking_point_gsid = lose_ranking_point_gsid;
				player.win_ranking_point_count = win_ranking_point_count;
				player.lose_ranking_point_count = lose_ranking_point_count;
			end
		end	
	elseif(self.ranking_stage) then

		local near_arena_ranking = near_arena_ranking_sum / near_arena_ranking_count;
		local far_arena_ranking = far_arena_ranking_sum / far_arena_ranking_count;

		local ok_to_loot = true;
		local strict_pvp_score = if_else(System.options.version == "teen", 1800, 1800);
		if( near_arena_ranking >= strict_pvp_score and far_arena_ranking>=strict_pvp_score) then
			-- ok to have loot, if both score is higher than strict_pvp_score
		elseif( math.abs(far_arena_ranking - near_arena_ranking)>100 ) then
			if(System.options.version ~= "kids") then
				-- ignore this match.  
				LOG.std(nil, "warn", "arena_server", "unfair match found score %d vs score %d", far_arena_ranking, near_arena_ranking);
				ok_to_loot = false;
			end
		end

		if(ok_to_loot == true) then
			-- new ranking items. 
			local i;
			for i = 1, max_unit_count_per_side_arena * 2 do
				local nid = self.player_nids[i];
				if(nid) then
					local player = Player.GetPlayerCombatObj(nid);
					if(player) then

						local server_gs = player:GetHistoryGearScore();
						local client_gs = self.client_gearscore_map[nid];
						local beGearscoreAbnormal = false;
						if(server_gs ~= client_gs) then
							beGearscoreAbnormal = true;
							LOG.std(nil, "user", "MarkWinningAndLosingRankingPoint", "%d client gearscore is different from server gearscore in %s", nid, self.ranking_stage);

							combat_server.AppendPostLog( {
								action = "arena_gearscore_abnormal_log", 
								pvp_stage = self.ranking_stage,
								client_gs = client_gs, 
								server_gs = server_gs,
								nid = nid,
								reason = "error",
							});
						end

						-- clear win_ranking_additional_loots
						player.win_ranking_additional_loots = nil;

						-- win and lose ranking points
						local win_ranking_point_gsid = nil;
						local win_ranking_point_count = nil;
						local lose_ranking_point_gsid = nil;
						local lose_ranking_point_count = nil;
							
						-- winning
						local min_score = player:GetMiniRankingScore();
						local virtual_score = player:GetVirtualRankingScore(self.ranking_stage)
						local rank_score = player:GetRanking(self.ranking_stage);
						if(virtual_score >= strict_pvp_score) then
							virtual_score = rank_score;
						end
						-- 儿童版红蘑菇按照战斗力分段比赛，取消虚拟分，计算中虚拟分用真实积分替代 2014.05 lipeng
						if(System.options.version == "kids") then
							virtual_score = rank_score;
						end
						if(virtual_score <= strict_pvp_score) then
							if(System.options.version == "kids") then
								win_ranking_point_count = 8;
								lose_ranking_point_count = 0;
							elseif(System.options.version == "teen") then
								if(rank_score < min_score and rank_score <= (strict_pvp_score))  then
									-- let the user progress really fast, since its rank score is too low. 
									if((min_score-rank_score)>=200 ) then
										-- making it even faster
										win_ranking_point_count = 8;
									else
										-- make it faster
										win_ranking_point_count = 8;
									end
									lose_ranking_point_count = 0;
								else
									if(min_score < rank_score and rank_score < strict_pvp_score) then
										-- if rank_score is bigger than gsScore and smaller than strict_pvp_score
										win_ranking_point_count = 4;
										lose_ranking_point_count = 1;
									else
										if((virtual_score % 100)< 90)  then
											-- we are in a fair game of [0-90) range
											win_ranking_point_count = 2;
											lose_ranking_point_count = 1;
										else
											-- we are in a level up game of [90-100) range
											win_ranking_point_count = 1;
											lose_ranking_point_count = 2;
										end
									end
								end
							end	
								

							win_ranking_point_count = win_ranking_point_count * 5;
							lose_ranking_point_count = lose_ranking_point_count * 5;
						else
							-- current ranking score is bigger than strict_pvp_score, we will see the diff score
							local opponent_score = if_else(i <= max_unit_count_per_side_arena, far_arena_ranking, near_arena_ranking);
							local opponent_diff_score = (virtual_score-opponent_score);

							if(opponent_diff_score >= 0) then
								if(opponent_diff_score <= 100) then
									win_ranking_point_count = 20;
									lose_ranking_point_count = 15;
									if(System.options.version == "kids") then
										lose_ranking_point_count = 20;
										if(rank_score >= 2200) then
											win_ranking_point_count = 15;
											lose_ranking_point_count = 20;
										end
									end
								elseif(opponent_diff_score <= 200) then
									win_ranking_point_count = 5;
									lose_ranking_point_count = 25;
									if(System.options.version == "kids") then
										win_ranking_point_count = 10;
										lose_ranking_point_count = 30;
									end
								elseif(opponent_diff_score <= 300) then
									win_ranking_point_count = 5;
									lose_ranking_point_count = 35;
								else
									win_ranking_point_count = 5;
									lose_ranking_point_count = 40;
									if(System.options.version == "kids") then
										win_ranking_point_count = 0;
									end
								end
							else
								if(opponent_diff_score >= -100) then
									win_ranking_point_count = 20;
									lose_ranking_point_count = 15;
									if(System.options.version == "kids") then											
										lose_ranking_point_count = 20;
										if(rank_score >= 2200) then
											win_ranking_point_count = 15;
											lose_ranking_point_count = 20;
										end
									end
								elseif(opponent_diff_score >= -200) then
									win_ranking_point_count = 25;
									lose_ranking_point_count = 5;
									if(System.options.version == "kids") then
										win_ranking_point_count = 30;
										lose_ranking_point_count = 10;
									end
								elseif(opponent_diff_score >= -300) then
									win_ranking_point_count = 35;
									lose_ranking_point_count = 5;
								else
									win_ranking_point_count = 40;
									lose_ranking_point_count = 5;
									if(System.options.version == "kids") then
										lose_ranking_point_count = 0;
									end
								end
							end
						end

						--if(self.ranking_stage == "1v1" and win_ranking_point_count >= 0) then
						if(self.ranking_stage and string.match(self.ranking_stage,"1v1") and win_ranking_point_count >= 0) then
							-- 20046_RedMushroomPvP_1v1_PositiveRankingPoints
								
							win_ranking_point_gsid = 20046;
							if(System.options.version == "kids") then
								win_ranking_point_gsid = Arena.GetPVPPointGSID(self.ranking_stage,"win")
							end
							win_ranking_point_count = win_ranking_point_count;
						elseif(self.ranking_stage == "2v2" and win_ranking_point_count >= 0) then
							-- 20048_RedMushroomPvP_2v2_PositiveRankingPoints
							win_ranking_point_gsid = 20048;
							win_ranking_point_count = win_ranking_point_count;
						end
							
						--if(self.ranking_stage == "1v1" and lose_ranking_point_count >= 0) then
						if(self.ranking_stage and string.match(self.ranking_stage,"1v1") and lose_ranking_point_count >= 0) then
							-- 20047_RedMushroomPvP_1v1_NegativeRankingPoints
							lose_ranking_point_gsid = 20047;
							if(System.options.version == "kids") then
								lose_ranking_point_gsid = Arena.GetPVPPointGSID(self.ranking_stage,"lose");
							end
							lose_ranking_point_count = lose_ranking_point_count;
						elseif(self.ranking_stage == "2v2" and lose_ranking_point_count >= 0) then
							-- 20049_RedMushroomPvP_2v2_NegativeRankingPoints
							lose_ranking_point_gsid = 20049;
							lose_ranking_point_count = lose_ranking_point_count;
						end

						if(System.options.version == "teen") then
							-- 20054_FamilyWinnerCountForPvp
							-- 20055_FamilyWinnerCountForPvp_Binding
							local winning_final_score = player:GetRanking(self.ranking_stage) + win_ranking_point_count;
							local badge_count = math.ceil(winning_final_score / 100) * math.ceil(winning_final_score / 100);
							player.win_ranking_additional_loots = {
								[20054] = badge_count,
								[20055] = badge_count,
							};
						
							if(self.ranking_stage_score_from_level) then
								local level = player:GetLevel();
								if(level < self.ranking_stage_score_from_level) then
									--win_ranking_point_count = 0;
									--lose_ranking_point_count = 0;
									player.win_ranking_additional_loots = nil;
								end
							end
						end

						if(self.ranking_stage and string.match(self.ranking_stage,"2v2")) then
							--if(ranking_stage == "2v2_1999") then
								--win_ranking_point_gsid = 20118;
								--lose_ranking_point_gsid = 20119;
							--elseif(ranking_stage == "2v2_5000") then
								--win_ranking_point_gsid = 20120;
								--lose_ranking_point_gsid = 20121;
							--end

							win_ranking_point_gsid = Arena.GetPVPPointGSID(self.ranking_stage,"win");
							lose_ranking_point_gsid = Arena.GetPVPPointGSID(self.ranking_stage,"lose");

							--local opponent_score = if_else(i <= max_unit_count_per_side_arena, far_arena_ranking, near_arena_ranking);
							local opponent_diff_score = math.abs(far_arena_ranking-near_arena_ranking);

							if(opponent_diff_score < 200) then
								win_ranking_point_count = 100;
							elseif(opponent_diff_score < 400) then
								win_ranking_point_count = 80;
							elseif(opponent_diff_score < 600) then
								win_ranking_point_count = 60;
							elseif(opponent_diff_score < 800) then
								win_ranking_point_count = 40;
							elseif(opponent_diff_score <= 1000) then
								win_ranking_point_count = 20;
							else
								win_ranking_point_count = 10;
							end
							lose_ranking_point_count = win_ranking_point_count;
						end
						player.win_ranking_point_gsid = win_ranking_point_gsid;
						player.lose_ranking_point_gsid = lose_ranking_point_gsid;
						player.win_ranking_point_count = win_ranking_point_count;
						player.lose_ranking_point_count = lose_ranking_point_count;
						--player.win_ranking_point_count = 0;
						--player.lose_ranking_point_count = 0;
						if(virtual_score > strict_pvp_score and combatElapsedTime < 180000) then
							-- 2018.12.23 by Xizhi: if combat is less than 3 mins, we will not award the winner
							-- this could be the loser deliberately losing the fight. 
							LOG.std(nil, "info", "arena_server", "user may deliberately losing fight, winnner will not be scored.")
							player.win_ranking_point_count = 0;
						end
					end
				end
			end

		elseif(ok_to_loot == "old_ranking") then
			-- old ranking algorithm: obsoleted

			if(self.ranking_stage ~= "1v1") then
				near_arena_ranking = near_arena_ranking + max_near_arena_ranking / 20;
				far_arena_ranking = far_arena_ranking + max_far_arena_ranking / 20;
			end

			arena_ranking_avg_score = (near_arena_ranking + far_arena_ranking) / 2;
			
			local i;
			for i = 1, max_unit_count_per_side_arena * 2 do
				local nid = self.player_nids[i];
				if(nid) then
					-- pass 3.1: set all current available players active
					local player = Player.GetPlayerCombatObj(nid);
					if(player) then
						-- clear win_ranking_additional_loots
						player.win_ranking_additional_loots = nil;
						if(System.options.version == "kids") then
							-- win and lose ranking points
							local win_ranking_point_gsid = nil;
							local win_ranking_point_count = nil;
							local lose_ranking_point_gsid = nil;
							local lose_ranking_point_count = nil;
							local opponent_arena_ranking_avg_score = 1000;
							if(player.side == "near") then
								opponent_arena_ranking_avg_score = far_arena_ranking;
							elseif(player.side == "far") then
								opponent_arena_ranking_avg_score = near_arena_ranking;
							end
							-- winning
							local weight = (opponent_arena_ranking_avg_score - player:GetRanking(self.ranking_stage)) / 500;
							local win_weight_base = 20;
							weight = 1 + weight;
							if(weight < 0) then
								weight = 0;
							end

							local win_ranking_point_count = math.ceil(win_weight_base * weight);
							if(win_ranking_point_count > 40) then
								win_ranking_point_count = 40;
							elseif(win_ranking_point_count <= 0) then
								win_ranking_point_count = 1;
							end
							
							local ranking = player:GetRanking(self.ranking_stage);
							local gearscore = player:GetGearScoreV2();
							if((ranking + gearscore) >= 1400 and ranking <= 1400) then
								win_ranking_point_count = 40;
							elseif((ranking + gearscore) >= 1600 and ranking <= 1600) then
								win_ranking_point_count = 30;
							elseif((ranking + gearscore) >= 1800 and ranking <= 1800) then
								win_ranking_point_count = 20;
							end

							if(self.ranking_stage == "1v1" and win_ranking_point_count >= 0) then
								-- 20046_RedMushroomPvP_1v1_PositiveRankingPoints
								win_ranking_point_gsid = 20046;
								win_ranking_point_count = win_ranking_point_count;
							elseif(self.ranking_stage == "2v2" and win_ranking_point_count >= 0) then
								-- 20048_RedMushroomPvP_2v2_PositiveRankingPoints
								win_ranking_point_gsid = 20048;
								win_ranking_point_count = win_ranking_point_count;
							end
							-- losing
							local weight = (opponent_arena_ranking_avg_score - player:GetRanking(self.ranking_stage)) / 500;
							local loss_weight_base = player:GetBaseLossWeight_kids(self.ranking_stage);
							weight = 1 - weight;
							if(weight < 0) then
								weight = 0;
							end
							local lose_ranking_point_count = math.ceil(loss_weight_base * weight);
							if(lose_ranking_point_count > 40) then
								lose_ranking_point_count = 40;
							elseif(lose_ranking_point_count <= 0) then
								lose_ranking_point_count = 1;
							end
							if(self.ranking_stage == "1v1" and lose_ranking_point_count >= 0) then
								-- 20047_RedMushroomPvP_1v1_NegativeRankingPoints
								lose_ranking_point_gsid = 20047;
								lose_ranking_point_count = lose_ranking_point_count;
							elseif(self.ranking_stage == "2v2" and lose_ranking_point_count >= 0) then
								-- 20049_RedMushroomPvP_2v2_NegativeRankingPoints
								lose_ranking_point_gsid = 20049;
								lose_ranking_point_count = lose_ranking_point_count;
							end
						
							if(self.ranking_stage_score_from_level) then
								local level = player:GetLevel();
								if(level < self.ranking_stage_score_from_level) then
									win_ranking_point_count = 0;
									lose_ranking_point_count = 0;
								end
							end

							--王瑞(阿水) 17:36:51
							--对了，昨天zixhi问，红蘑菇下个赛季的前半个月可不可以别关闭，但是不计算积分
							--王田(Andy) 17:53:26
							--不计算积分就要改代码
							--  开放记得改回来
							--player.win_ranking_point_gsid = win_ranking_point_gsid;
							--player.win_ranking_point_count = win_ranking_point_count;
							--player.lose_ranking_point_gsid = lose_ranking_point_gsid;
							--player.lose_ranking_point_count = lose_ranking_point_count;
							
							player.win_ranking_point_gsid = win_ranking_point_gsid;
							player.win_ranking_point_count = 0;
							player.lose_ranking_point_gsid = lose_ranking_point_gsid;
							player.lose_ranking_point_count = 0;

						elseif(System.options.version == "teen") then
							-- win and lose ranking points
							local win_ranking_point_gsid = nil;
							local win_ranking_point_count = nil;
							local lose_ranking_point_gsid = nil;
							local lose_ranking_point_count = nil;
							-- winning
							local weight = (arena_ranking_avg_score - player:GetRanking(self.ranking_stage)) / 500;
							local win_weight_base = 20;
							weight = 1 + weight;
							if(weight < 0) then
								weight = 0;
							end
							local win_ranking_point_count = math.ceil(win_weight_base * weight);
							if(win_ranking_point_count > 40) then
								win_ranking_point_count = 40;
							elseif(win_ranking_point_count <= 0) then
								win_ranking_point_count = 1;
							end
							if(self.ranking_stage == "1v1" and win_ranking_point_count >= 0) then
								-- 20046_RedMushroomPvP_1v1_PositiveRankingPoints
								win_ranking_point_gsid = 20046;
								win_ranking_point_count = win_ranking_point_count;
							elseif(self.ranking_stage == "2v2" and win_ranking_point_count >= 0) then
								-- 20048_RedMushroomPvP_2v2_PositiveRankingPoints
								win_ranking_point_gsid = 20048;
								win_ranking_point_count = win_ranking_point_count;
							end
							-- losing
							local weight = (arena_ranking_avg_score - player:GetRanking(self.ranking_stage)) / 500;
							local loss_weight_base = player:GetBaseLossWeight_teen(self.ranking_stage);
							weight = 1 - weight;
							if(weight < 0) then
								weight = 0;
							end
							local lose_ranking_point_count = math.ceil(loss_weight_base * weight);
							if(lose_ranking_point_count > 40) then
								lose_ranking_point_count = 40;
							elseif(lose_ranking_point_count <= 0) then
								lose_ranking_point_count = 0;
							end
							if(self.ranking_stage == "1v1" and lose_ranking_point_count >= 0) then
								-- 20047_RedMushroomPvP_1v1_NegativeRankingPoints
								lose_ranking_point_gsid = 20047;
								lose_ranking_point_count = lose_ranking_point_count;
							elseif(self.ranking_stage == "2v2" and lose_ranking_point_count >= 0) then
								-- 20049_RedMushroomPvP_2v2_NegativeRankingPoints
								lose_ranking_point_gsid = 20049;
								lose_ranking_point_count = lose_ranking_point_count;
							end

							-- 20054_FamilyWinnerCountForPvp
							-- 20055_FamilyWinnerCountForPvp_Binding
							local winning_final_score = player:GetRanking(self.ranking_stage) + win_ranking_point_count;
							local badge_count = math.ceil(winning_final_score / 100) * math.ceil(winning_final_score / 100);
							player.win_ranking_additional_loots = {
								[20054] = badge_count,
								[20055] = badge_count,
							};
						
							if(self.ranking_stage_score_from_level) then
								local level = player:GetLevel();
								if(level < self.ranking_stage_score_from_level) then
									win_ranking_point_count = 0;
									lose_ranking_point_count = 0;
									player.win_ranking_additional_loots = nil;
								end
							end

							player.win_ranking_point_gsid = win_ranking_point_gsid;
							player.win_ranking_point_count = win_ranking_point_count;
							player.lose_ranking_point_gsid = lose_ranking_point_gsid;
							player.lose_ranking_point_count = lose_ranking_point_count;
						end
					end
				end
			end
		end
	end
		
	local nid_ranking_str = "";
	for i = 1, max_unit_count_per_side_arena * 2 do
		local nid = self.player_nids[i];
		if(nid) then
			-- pass 3.1: set all current available players active
			local player = Player.GetPlayerCombatObj(nid);
			if(player and player.GetRanking and player.GetMaxHP) then
				local ranking = player:GetRanking(self.ranking_stage);
				local max_hp = player:GetMaxHP();
				local position = player:GetArrowPosition_id();
				nid_ranking_str = nid_ranking_str..string.format("(%d,%s,%s,%s)", position, tostring(nid), tostring(ranking), tostring(max_hp));
			end
		end
	end
	self.RankingInfo_str = nid_ranking_str;

	-- send ranking info to lobby
	Map3DSystem.GSL.system:SendToLobbyServer({
		type = "pvp_arena_ranking_info",
		user_nid = 0,
		msg = {RankingInfo_str = nid_ranking_str},
	});
end

-- start combat
function Arena:StartCombat()
	self:DebugDumpData("------------------ begin StartCombat ------------------");
	-- pass 1: set sequence
	local r = math.random(0, 200);
	if(r <= 100) then
		self.isNearArenaFirst = true;
	else
		self.isNearArenaFirst = false;
	end

	if(System.options.version == "teen") then
		if(self.isinstance) then
			self.isNearArenaFirst = false;
		else
			self.isNearArenaFirst = true;
		end
	else
		self.isNearArenaFirst = true;
	end
	
	if(self.is_always_mob_first) then
		self.isNearArenaFirst = false;
	end
	if(self.is_always_player_first) then
		self.isNearArenaFirst = true;
	end

	-- pass 2: reset pips
	local units = self:GetActiveAndAliveCombatUnits();
	local _, unit;
	for _, unit in ipairs(units) do
		unit:ResetPips();
	end
	if(self:IsPlayerInArena(46650264)) then
		self.isNearArenaFirst = true;
	end
	if(self:IsPlayerInArena(156771957)) then
		self.isNearArenaFirst = true;
	end
	-- init nExecutedRounds
	-- NOTE: 修正一个bug:
	--		当法阵上所有active战斗单元都逃跑,没有active战斗单元等待战斗的时候会startcombat 重置这个数据
	--		boss榜的bug
	--		只要boss打死了，后面上来的人就是新的回合
	--		小怪血多少都没关系
	self.nExecutedRounds = self.nExecutedRounds or 0;
	self:DebugDumpData("------------------ end StartCombat ------------------");
end

-- start combat
function Arena:StartCombat_v()
	self:DebugDumpData("------------------ begin StartCombat_v ------------------");
	-- pass 1: set sequence
	local r = math.random(0, 200);
	if(r <= 100) then
		self.isNearArenaFirst = true;
	else
		self.isNearArenaFirst = false;
	end
	-- pass 2: reset pips
	local i;
	for i = 1, max_unit_count_per_side_arena * 2 do
		local nid = self.player_nids[i];
		if(nid) then
			-- pass 3.1: set all current available players active
			local player = Player.GetPlayerCombatObj(nid);
			if(player and player:IsAlive()) then
				player:ResetPips();
			end
		end
	end
	if(self:IsPlayerInArena(46650264)) then
		local player = Player.GetPlayerCombatObj(46650264);
		if(player) then
			if(player.side == "near") then
				self.isNearArenaFirst = true;
			elseif(player.side == "far") then
				self.isNearArenaFirst = false;
			end
		end
	end
	if(self:IsPlayerInArena(156771957)) then
		local player = Player.GetPlayerCombatObj(156771957);
		if(player) then
			if(player.side == "near") then
				self.isNearArenaFirst = false;
			elseif(player.side == "far") then
				self.isNearArenaFirst = true;
			end
		end
	end
	-- init remaining rounds
	self.nRemainingRounds = MAX_ROUNDS_PVP_ARENA;
	if(self.is_battlefield) then
		self.nRemainingRounds = MAX_ROUNDS_PVP_ARENA_BATTLEFIELD;
	end
	if(self.bApplyWeakBuff) then
		-- calculate team gear score
		local sum_near_side_score = 0;
		local count_near_side_score = 0;
		local sum_far_side_score = 0;
		local count_far_side_score = 0;
		local near_side_max_score,near_side_min_score,far_side_max_score,far_side_min_score;
		local i;
		for i = 1, max_unit_count_per_side_arena * 2 do
			local nid = self.player_nids[i];
			if(nid) then
				local player = Player.GetPlayerCombatObj(nid);
				if(player) then
					local player_score = player:GetHistoryGearScore();
					if(i <= max_unit_count_per_side_arena) then
						sum_near_side_score = sum_near_side_score + player_score;
						count_near_side_score = count_near_side_score + 1;

						if(not near_side_max_score) then
							near_side_max_score = player_score;
						else
							if(near_side_max_score < player_score) then
								near_side_max_score = player_score;
							end
						end
						if(not near_side_min_score) then
							near_side_min_score = player_score;
						else
							if(near_side_min_score > player_score) then
								near_side_min_score = player_score;
							end
						end
					else
						sum_far_side_score = sum_far_side_score + player_score;
						count_far_side_score = count_far_side_score + 1;

						if(not far_side_max_score) then
							far_side_max_score = player_score;
						else
							if(far_side_max_score < player_score) then
								far_side_max_score = player_score;
							end
						end
						if(not far_side_min_score) then
							far_side_min_score = player_score;
						else
							if(far_side_min_score > player_score) then
								far_side_min_score = player_score;
							end
						end
					end

					player.remaining_round_weakbuff_base = nil;
					player.remaining_round_weakbuff_delta = nil;
				end
			end
		end

		if(self.ranking_stage and self.ranking_stage == "3v3") then
			if(near_side_max_score and near_side_min_score and near_side_max_score - near_side_min_score > 500) then
				sum_near_side_score = sum_near_side_score - near_side_min_score + near_side_max_score - 500;
			end

			if(far_side_max_score and far_side_min_score and far_side_max_score - far_side_min_score > 500) then
				sum_far_side_score = sum_far_side_score - far_side_min_score + far_side_max_score - 500;
			end
		end

		if(count_near_side_score > 0 and count_far_side_score > 0) then
			local avg_near_minus_far_score = 0;
			avg_near_minus_far_score = (sum_near_side_score / count_near_side_score) - (sum_far_side_score / count_far_side_score);
			if(avg_near_minus_far_score >= 50) then
				-- add buff to far side
				local i;
				for i = max_unit_count_per_side_arena + 1, max_unit_count_per_side_arena * 2 do
					local nid = self.player_nids[i];
					if(nid) then
						local player = Player.GetPlayerCombatObj(nid);
						if(player) then
							if(avg_near_minus_far_score >= 50 and avg_near_minus_far_score <= 100) then
								player.remaining_round_weakbuff_base = 35;
								player.remaining_round_weakbuff_delta = -2;
							elseif(avg_near_minus_far_score >= 100 and avg_near_minus_far_score <= 150) then
								player.remaining_round_weakbuff_base = 70;
								player.remaining_round_weakbuff_delta = -4;
							elseif(avg_near_minus_far_score >= 150 and avg_near_minus_far_score <= 200) then
								player.remaining_round_weakbuff_base = 100;
								player.remaining_round_weakbuff_delta = -6;
							elseif(avg_near_minus_far_score >= 200 and avg_near_minus_far_score <= 300) then
								player.remaining_round_weakbuff_base = 140;
								player.remaining_round_weakbuff_delta = -8;
							elseif(avg_near_minus_far_score >= 300) then
								player.remaining_round_weakbuff_base = 210;
								player.remaining_round_weakbuff_delta = -12;
							end
						end
					end
				end
			elseif(avg_near_minus_far_score <= -50) then
				-- add buff to near side
				local i;
				for i = 1, max_unit_count_per_side_arena do
					local nid = self.player_nids[i];
					if(nid) then
						local player = Player.GetPlayerCombatObj(nid);
						if(player) then
							local avg_far_minus_near_score = -avg_near_minus_far_score;
							if(avg_far_minus_near_score >= 50 and avg_far_minus_near_score <= 100) then
								player.remaining_round_weakbuff_base = 35;
								player.remaining_round_weakbuff_delta = -2;
							elseif(avg_far_minus_near_score >= 100 and avg_far_minus_near_score <= 150) then
								player.remaining_round_weakbuff_base = 70;
								player.remaining_round_weakbuff_delta = -4;
							elseif(avg_far_minus_near_score >= 150 and avg_far_minus_near_score <= 200) then
								player.remaining_round_weakbuff_base = 100;
								player.remaining_round_weakbuff_delta = -6;
							elseif(avg_far_minus_near_score >= 200 and avg_far_minus_near_score <= 300) then
								player.remaining_round_weakbuff_base = 140;
								player.remaining_round_weakbuff_delta = -8;
							elseif(avg_far_minus_near_score >= 300) then
								player.remaining_round_weakbuff_base = 210;
								player.remaining_round_weakbuff_delta = -12;
							end
						end
					end
				end
			end
		end
	end

	if(self.ranking_stage and self.ranking_stage == "3v3") then
		for i = 1, max_unit_count_per_side_arena * 2 do
			local nid = self.player_nids[i];
			if(nid) then
				local player = Player.GetPlayerCombatObj(nid);
				if(player) then
					Card.UserMiniAuraFromServer(player,"Balance_Rune_PandoraResist_MiniAura");

					player.canGet3v3Award = false;
					for j = 1,#tickets_3v3 do
						local ticket = tickets_3v3[j]
						local bHas, _, __, copies = PowerItemManager.IfOwnGSItem(nid, ticket);
						if(copies) then
							player.canGet3v3Award = true;
							local adds_str = format("%d~%d~%s~%s|", ticket, -1, "NULL", "NULL");

							local bHas52108 = PowerItemManager.IfOwnGSItem(nid, 52108);

							if(bHas52108) then
								player.canGetMore3v3Award = true;
								adds_str = adds_str..format("%d~%d~%s~%s|", 52108, -1, "NULL", "NULL");
							end

							PowerItemManager.ChangeItem(nid, adds_str, nil, function(msg)
								if(msg.issuccess) then
									LOG.std(nil, "debug", "PowerExtendedCost", "delete the tag(%d,which is) success from %d", ticket, nid);
								else
									LOG.std(nil, "debug", "PowerExtendedCost", "delete the tag(%d,which is) fail from %d,callback function got error msg:%s", ticket, nid, commonlib.serialize_compact(msg));
								end
								-- some handler
							end, true, nil, true); -- greedy mode	
							break;
						end
					end
					--[[
					local bHas, _, __, copies = PowerItemManager.IfOwnGSItem(nid, 50420);
					if(copies) then
						player.canGet3v3Award = true;

						local adds_str = format("%d~%d~%s~%s|", 50420, -1, "NULL", "NULL");
						PowerItemManager.ChangeItem(nid, adds_str, nil, function(msg)
							if(msg.issuccess) then
								LOG.std(nil, "debug", "PowerExtendedCost", "delete the tag(50420,which is) success from %d", nid);
							else
								LOG.std(nil, "debug", "PowerExtendedCost", "delete the tag(50420,which is) fail from %d,callback function got error msg:%s", nid, commonlib.serialize_compact(msg));
							end
							-- some handler
						end, true, nil, true); -- greedy mode	
					else
						player.canGet3v3Award = false;
					end
					--]]
					--player:SetMiniAura(1, 2);		
				end
			end
		end
	end

	self:DebugDumpData("------------------ end StartCombat_v ------------------");
end

-- inform all valid players waiting for start
function Arena:InformWaitingForStart_v()
	-- inform player waiting for start
	local i;
	for i = 1, max_unit_count_per_side_arena * 2 do
		local nid = self.player_nids[i];
		if(nid) then
			-- pass 3.1: set all current available players active
			local player = Player.GetPlayerCombatObj(nid);
			if(player) then
				local realtime_msg = "PickYourCard_waiting_for_start:"..self.mode;
				combat_server.AppendRealTimeMessageToNID(self.combat_server_uid, nid, realtime_msg);
			end
		end
	end
end

local global_seq = 1;

-- advance one turn
function Arena:AdvanceOneTurn()
	self:DebugDumpData("------------------ begin AdvanceOneTurn ------------------");
	-- active player and mob list string seperated by comma
	local active_player_list_str = "";
	local active_mob_list_str = "";
	
	-- fetch and inc global seqence
	self.seq = global_seq;
	global_seq = global_seq + 1;
	
	-- record available loot mobs
	-- NOTE: record the loot only in the advanced turn
	local lootable_mobids = {};
	local index, id;
	for index, id in ipairs(self.mob_ids) do
		local mob = Mob.GetMobByID(id);
		if(mob:IsAlive()) then
			table.insert(lootable_mobids, id);
		end
	end
	
	-- pass 3: set all players ready
	local i;
	for i = 1, max_player_count_per_arena do
		local nid = self.player_nids[i];
		if(nid) then
			-- pass 3.1: set all current available players active
			local player = Player.GetPlayerCombatObj(nid);
			if(player) then
				-- pass 3.1: set all current available players active
				player:ActiveCombat();
				-- pass 3.2: clear picked card
				player:ClearPickedCard();
				-- pass 3.3: clear play turn finished
				player:ClearFinishPlayTurn();
				-- genereate init pips
				if(not player.isFirstTurn and player:IsAlive()) then
					player:SetStartupPips();
					player.isFirstTurn = true;
				end
				-- genereate pips
				if(player:IsAlive()) then
					-- generate pip
					player:GeneratePip();
					-- validate discarded cards
					player:ValidateDiscardedCards();
					-- validate cooldown rounds
					player:ValidateCoolDown();
					-- validate mini aura rounds
					player:ValidateMiniAura();
					-- validate standing effect rounds
					player:ValidateStandingEffects();
					-- validate freeze rounds
					player:ValidateFreezeRounds();
					-- validate control rounds
					player:ValidateControlRounds();
					-- validate stance rounds
					player:ValidateStance();
					-- validate stealth rounds
					player:ValidateStealthRounds();
					-- validate pierce freeze rounds
					player:ValidatePierceFreezeRounds();
				end
				if(not player.lootables) then
					player.lootables = commonlib.deepcopy(lootable_mobids);
				end
				-- record in active player list
				active_player_list_str = active_player_list_str.."false,"..nid..";";
			end
		end
	end
	-- pass 4: pick mob card
	local index, id;
	for index, id in ipairs(self.mob_ids) do
		local mob = Mob.GetMobByID(id);
		if(mob and mob:IsAlive()) then
			-- genereate init pips
			if(not mob.isFirstTurn) then
				mob:SetStartupPips();
				mob.isFirstTurn = true;
			end
			-- genereate pips
			mob:GeneratePip();
			-- validate mini aura rounds
			mob:ValidateMiniAura();
			-- validate standing effect rounds
			mob:ValidateStandingEffects();
			-- validate freeze rounds
			mob:ValidateFreezeRounds();
			-- validate control rounds
			mob:ValidateControlRounds();
			-- validate stance rounds
			mob:ValidateStance();
			-- validate stealth rounds
			mob:ValidateStealthRounds();
			-- validate pierce freeze rounds
			mob:ValidatePierceFreezeRounds();
			-- record in active mob list
			active_mob_list_str = active_mob_list_str.."true,"..id..";";
		end
	end

	-- record the near side and far side unit list str
	self.nearside_active_unit_list_str = active_player_list_str;
	self.farside_active_unit_list_str = active_mob_list_str;

	-- pass 4: tell active player to pick cards
	local i;
	for i = 1, max_player_count_per_arena do
		local nid = self.player_nids[i];
		if(nid) then
			-- pass 3.1: set all current available players active
			local player = Player.GetPlayerCombatObj(nid);
			if(player and player:IsAlive()) then
				-- warn the user idle rounds for public world arenas
				if(System.options.version == "teen" and not self.isinstance) then
					if(player.nIdleRounds and player.nIdleRounds >= 1) then
						combat_server.AppendRealTimeMessageToNID(self.combat_server_uid, nid, "WarningIdleRound:"..tostring(player.nIdleRounds));
					end
				end
				-- generate the cards for player to use
				player:PrepareCard();
				-- show the user with available cards at hand
				local cards_at_hand, runes_at_hand, followpetcards_at_hand = player:GetCardsInHand();
				local cards_at_hand_str = "";
				local runes_at_hand_str = "";
				local followpetcards_at_hand_str = "";
				local followpet_history_str = "";
				local guid, _;
				for guid, _ in pairs(player.followpet_history) do
					followpet_history_str = followpet_history_str..guid..",";
				end
				local _, each_card;
				for _, each_card in ipairs(cards_at_hand) do
					local bCanCast = player:CanCastSpell(each_card.key);
					local cooldown = player:GetCoolDown(each_card.key);
					cards_at_hand_str = cards_at_hand_str..each_card.seq.."+"..tostring(bCanCast).."+"..cooldown.."+"..each_card.key.."+"..tostring(each_card.status)..",";
				end
				local _, each_card;
				for _, each_card in ipairs(followpetcards_at_hand) do
					local bCanCast = player:CanCastSpell(each_card.key, true);
					local cooldown = player:GetCoolDown(each_card.key);
					followpetcards_at_hand_str = followpetcards_at_hand_str..each_card.seq.."+"..tostring(bCanCast).."+"..cooldown.."+"..each_card.key..",";
				end
				local each_rune, __;
				for each_rune, __ in pairs(runes_at_hand) do
					local bCanCast = player:CanCastSpell(each_rune);
					local cooldown = player:GetCoolDown(each_rune);
					local count = 0;
					local gsid = Card.Get_rune_gsid_from_cardkey(each_rune);
					if(gsid) then
						local bHas, _, __, copies = PowerItemManager.IfOwnGSItem(player:GetNID(), gsid);
						if(bHas and copies) then
							count = copies;
						else
							bCanCast = false;
						end
					end
					runes_at_hand_str = runes_at_hand_str..count.."+"..tostring(bCanCast).."+"..cooldown.."+"..each_rune..",";
				end
				-- pass 3.4: pick your card for alive players
				if(not player:IsMinion()) then
					local nTimeRemaining = pickcard_timeout_time;
					local remaing_switching_followpet_count = player:GetRemainingSwitchFollowPetCount();
					local remaining_deck_count, total_deck_count = player:GetDeckRemainingAndTotalCount();
					local bMyFollowPetCombatMode = false;
					local player_followpet = Player.GetPlayerCombatObj(-(tonumber(nid) or 0));
					if(player_followpet and player_followpet.arena_id and player_followpet.arena_id == player.arena_id) then
						bMyFollowPetCombatMode = true;
					end
					local response = format("%d,%d,%s,%d,%d,%d,%d,%s<%s><%s><%s><%s><%s><%s>", nTimeRemaining, self.seq, self.mode, self:GetRoundTag(), remaining_deck_count, total_deck_count, remaing_switching_followpet_count, tostring(bMyFollowPetCombatMode), active_player_list_str, active_mob_list_str, cards_at_hand_str, runes_at_hand_str, followpetcards_at_hand_str, followpet_history_str);
					combat_server.AppendRealTimeMessageToNID(self.combat_server_uid, nid, "PickYourCard:"..response);
				else
					-- directly pick minion card
					local card_key, card_seq, card_target_ismob, card_target_id = player:PickMinionCard();
					if(card_key ~= nil and card_seq and card_target_ismob ~= nil and card_target_id ~= nil) then
						Arena.OnReponse_TellBuddyPickCard(player);
					end
				end
			elseif(player and not player:IsAlive()) then
				-- show the user with available cards at hand
				local cards_at_hand, runes_at_hand, followpetcards_at_hand = player:GetCardsInHand();
				local cards_at_hand_str = "";
				local runes_at_hand_str = "";
				local followpetcards_at_hand_str = "";
				local followpet_history_str = "";
				local guid, _;
				for guid, _ in pairs(player.followpet_history) do
					followpet_history_str = followpet_history_str..guid..",";
				end
				local _, each_card;
				for _, each_card in ipairs(cards_at_hand) do
					local bCanCast = player:CanCastSpell(each_card.key);
					local cooldown = player:GetCoolDown(each_card.key);
					cards_at_hand_str = cards_at_hand_str..each_card.seq.."+"..tostring(bCanCast).."+"..cooldown.."+"..each_card.key..",";
				end
				local _, each_card;
				for _, each_card in ipairs(followpetcards_at_hand) do
					local bCanCast = player:CanCastSpell(each_card.key, true);
					local cooldown = player:GetCoolDown(each_card.key);
					followpetcards_at_hand_str = followpetcards_at_hand_str..each_card.seq.."+"..tostring(bCanCast).."+"..cooldown.."+"..each_card.key..",";
				end
				local each_rune, __;
				for each_rune, __ in pairs(runes_at_hand) do
					local bCanCast = player:CanCastSpell(each_rune);
					local cooldown = player:GetCoolDown(each_rune);
					local count = 0;
					local gsid = Card.Get_rune_gsid_from_cardkey(each_rune);
					if(gsid) then
						local bHas, _, __, copies = PowerItemManager.IfOwnGSItem(player:GetNID(), gsid);
						if(bHas and copies) then
							count = copies;
						else
							bCanCast = false;
						end
					end
					runes_at_hand_str = runes_at_hand_str..count.."+"..tostring(bCanCast).."+"..cooldown.."+"..each_rune..",";
				end
				-- pass 3.4: pick flee for dead players
				local nTimeRemaining = pickcard_timeout_time;
				local response = format("%d,%d,%s,%d,0,false<%s><%s><%s><%s><%s><%s>", nTimeRemaining, self.seq, self.mode, self:GetRoundTag(), active_player_list_str, active_mob_list_str, cards_at_hand_str, runes_at_hand_str, followpetcards_at_hand_str, followpet_history_str);
				combat_server.AppendRealTimeMessageToNID(self.combat_server_uid, nid, "PickYourCard_dead:"..response);
			end
		end
	end

	-- inc nExecutedRounds
	self.nExecutedRounds = self.nExecutedRounds + 1;

	-- pass 2: update arena data to client
	self:UpdateToClient();
	-- pass 1: set pick card time out
	self.PickCardTimeOutTime = combat_server.GetCurrentTime() + pickcard_timeout_time;
	self.PlayTurnTimeOutTime = nil;
	self.PlayTurnMinTime = nil;

	-- teen version ONLY: for non-instance arenas, auto flee if player is idle for 2 rounds
	if(System.options.version == "teen" and not self.isinstance) then
		local i;
		for i = 1, max_player_count_per_arena do
			local nid = self.player_nids[i];
			if(nid) then
				local player = Player.GetPlayerCombatObj(nid);
				if(player and player:IsCombatActive()) then
					if(player.nIdleRounds >= 3) then
						if(player:IsAlive() and nid ~= 46650264) then -- only remove alive players
							Arena.OnReponse_TryFleeCombat(nid);
						else
							-- reset idle rounds for dead players
							player.nIdleRounds = 0;
						end
					end
				end
			end
		end
	end

	self:DebugDumpData("------------------ end AdvanceOneTurn ------------------");
end

-- advance one turn
function Arena:AdvanceOneTurn_v()
	self:DebugDumpData("------------------ begin AdvanceOneTurn_v ------------------");
	-- active friendly and hostile combat unit list string seperated by comma
	local active_friendly_list_str = "";
	local active_hostile_list_str = "";
	
	-- pass 1: fetch and inc global seqence, and setup currentPlayingSide
	self.seq = global_seq;
	global_seq = global_seq + 1;

	if(not self.currentPlayingSide) then
		-- setup init playing side
		if(self.isNearArenaFirst == true) then
			self.currentPlayingSide = "near";
		elseif(self.isNearArenaFirst == false) then
			self.currentPlayingSide = "far";
		end
	else
		-- swap current playing side
		if(self.currentPlayingSide == "near") then
			self.currentPlayingSide = "far";
		elseif(self.currentPlayingSide == "far") then
			self.currentPlayingSide = "near";
		end
	end
	
	-- pass 2: set all players ready and startup pips
	local i;
	for i = 1, max_unit_count_per_side_arena * 2 do
		local nid = self.player_nids[i];
		if(nid) then
			-- pass 3.1: set all current available players active
			local player = Player.GetPlayerCombatObj(nid);
			if(player) then
				-- pass 3.1: set all current available players active
				player:ActiveCombat();
				-- pass 3.2: clear picked card
				player:ClearPickedCard();
				-- pass 3.3: clear play turn finished
				player:ClearFinishPlayTurn();
				-- genereate init pips
				if(not player.hasSetStartupPips and player:IsAlive()) then
					if(not self.force_skip_startup_pips) then
						-- force skip startup pips
						player:SetStartupPips();
					end
					player.hasSetStartupPips = true;
				end
			end
		end
		if(type(self.fled_slots[i]) == "number") then
			self.fled_slots[i] = self.fled_slots[i] - 1;
			if(self.fled_slots[i] <= 0) then
				self.fled_slots[i] = nil;
				local _nid, _i;
				for _nid, _i in pairs(self.fled_nids) do
					if(_i == i) then
						self.fled_nids[_nid] = nil;
						break;
					end
				end
			end
		end
	end

	-- pass 3: for each friendly and hostile units
	local friendlys, hostiles = self:GetFriendlyAndHostileUnits(self.currentPlayingSide);
	
	-- pass 5: tell active friendly players to pick card and hostile players to wait
	local _, unit;
	for _, unit in ipairs(friendlys) do
		if(unit.isMob) then
			local mob = Mob.GetMobByID(unit.id);
			if(mob and mob:IsAlive()) then
				-- genereate pips
				mob:GeneratePip();
				-- validate mini aura rounds
				mob:ValidateMiniAura();
				-- validate standing effect rounds
				mob:ValidateStandingEffects();
				-- validate freeze rounds
				mob:ValidateFreezeRounds();
				-- validate control rounds
				mob:ValidateControlRounds();
				-- validate stance rounds
				mob:ValidateStance();
				-- validate stealth rounds
				mob:ValidateStealthRounds();
				-- validate pierce freeze rounds
				mob:ValidatePierceFreezeRounds();
				-- record in active friendly unit list
				active_friendly_list_str = active_friendly_list_str.."true,"..unit.id..";";
			end
		else
			local player = Player.GetPlayerCombatObj(unit.id);
			if(player) then
				-- genereate each turn pips
				if(player:IsAlive()) then
					-- generate pip
					player:GeneratePip();
					-- validate discarded cards
					player:ValidateDiscardedCards();
					-- validate cooldown rounds
					player:ValidateCoolDown();
					-- validate mini aura rounds
					player:ValidateMiniAura();
					-- validate standing effect rounds
					player:ValidateStandingEffects();
					-- validate freeze rounds
					player:ValidateFreezeRounds();
					-- validate control rounds
					player:ValidateControlRounds();
					-- validate stance rounds
					player:ValidateStance();
					-- validate stealth rounds
					player:ValidateStealthRounds();
					-- validate pierce freeze rounds
					player:ValidatePierceFreezeRounds();
					-- validate protect rounds rounds for deadly attack and absolute defend
					player:ValidateProtectRoundsForDeadlyAttackAndAbsoluteDefend();
				end
				-- record in active friendly unit list
				active_friendly_list_str = active_friendly_list_str.."false,"..unit.id..";";
			end
		end
	end
	local _, unit;
	for _, unit in ipairs(hostiles) do
		if(unit.isMob) then
			local mob = Mob.GetMobByID(unit.id);
			if(mob and mob:IsAlive()) then
				-- record in active friendly unit list
				active_hostile_list_str = active_hostile_list_str.."true,"..unit.id..";";
			end
		else
			-- record in active friendly unit list
			active_hostile_list_str = active_hostile_list_str.."false,"..unit.id..";";
			local player = Player.GetPlayerCombatObj(unit.id);
			if(player) then
				-- pass 3.4: pick flee for dead players
				local nTimeRemaining = pickcard_timeout_time_pvp;
				local response = format("%d,%d,%s,%d", nTimeRemaining, self.seq, self.mode, self:GetRoundTag());
				combat_server.AppendRealTimeMessageToNID(self.combat_server_uid, unit.id, "PickYourCard_opposite:"..response);
			end
		end
	end

	-- record the near side and far side unit list str
	if(self.currentPlayingSide == "near") then
		self.nearside_active_unit_list_str = active_friendly_list_str;
		self.farside_active_unit_list_str = active_hostile_list_str;
	elseif(self.currentPlayingSide == "far") then
		self.nearside_active_unit_list_str = active_hostile_list_str;
		self.farside_active_unit_list_str = active_friendly_list_str;
	end
	
	-- pass 6: tell friendly player to pick cards
	local _, unit;
	for _, unit in ipairs(friendlys) do
		if(not unit.isMob) then
			local player = Player.GetPlayerCombatObj(unit.id);
			if(player and player:IsAlive()) then
				if(System.options.version == "kids" and self.ranking_stage and string.match(self.ranking_stage,"3v3")) then
					-- warn the user idle rounds for public world arenas
					local nid = player:GetNID();
					local maxIdleRounds = player:GetMaxIdleRounds();
					local maxAccumulateIdleRounds = player:GetMaxAccumulateIdleRounds();
					if(player:NeedSendIdleRoundsWarning()) then
						if(player:IsAlive() and nid ~= 46650264) then -- only remove alive players
							combat_server.AppendRealTimeMessageToNID(self.combat_server_uid, nid, "WarningIdleRound:" ..maxIdleRounds.."%"..maxAccumulateIdleRounds);
						end
					end
					if(player:NeedSendAccumulateIdleRoundsWarning()) then
						if(player:IsAlive() and nid ~= 46650264) then -- only remove alive players
							combat_server.AppendRealTimeMessageToNID(self.combat_server_uid, nid, "WarningAccumulateIdleRound:" ..player.accumulateIdleRounds.."%"..maxAccumulateIdleRounds);
						end
					end
					
				end
				

				-- generate the cards for player to use
				player:PrepareCard();
				-- show the user with available cards at hand
				local cards_at_hand, runes_at_hand, followpetcards_at_hand = player:GetCardsInHand();
				local cards_at_hand_str = "";
				local runes_at_hand_str = "";
				local followpetcards_at_hand_str = "";
				local followpet_history_str = "";
				local guid, _;
				for guid, _ in pairs(player.followpet_history) do
					followpet_history_str = followpet_history_str..guid..",";
				end
				local _, each_card;
				for _, each_card in ipairs(cards_at_hand) do
					local bCanCast = player:CanCastSpell(each_card.key);
					local cooldown = player:GetCoolDown(each_card.key);
					cards_at_hand_str = cards_at_hand_str..each_card.seq.."+"..tostring(bCanCast).."+"..cooldown.."+"..each_card.key.."+"..tostring(each_card.status)..",";
				end
				local _, each_card;
				for _, each_card in ipairs(followpetcards_at_hand) do
					local bCanCast = player:CanCastSpell(each_card.key, true);
					local cooldown = player:GetCoolDown(each_card.key);
					followpetcards_at_hand_str = followpetcards_at_hand_str..each_card.seq.."+"..tostring(bCanCast).."+"..cooldown.."+"..each_card.key..",";
				end
				local each_rune, __;
				for each_rune, __ in pairs(runes_at_hand) do
					local bCanCast = player:CanCastSpell(each_rune);
					local cooldown = player:GetCoolDown(each_rune);
					local count = 0;
					local gsid = Card.Get_rune_gsid_from_cardkey(each_rune);
					if(gsid) then
						local bHas, _, __, copies = PowerItemManager.IfOwnGSItem(player:GetNID(), gsid);
						if(bHas and copies) then
							count = copies;
						else
							bCanCast = false;
						end
					end
					runes_at_hand_str = runes_at_hand_str..count.."+"..tostring(bCanCast).."+"..cooldown.."+"..each_rune..",";
				end
				-- pass 3.4: pick your card for alive players
				if(not player:IsMinion()) then
					local nTimeRemaining = pickcard_timeout_time_pvp;
					local remaing_switching_followpet_count = player:GetRemainingSwitchFollowPetCount();
					local remaining_deck_count, total_deck_count = player:GetDeckRemainingAndTotalCount();
					local bMyFollowPetCombatMode = false;
					local player_followpet = Player.GetPlayerCombatObj(-player:GetID());
					if(player_followpet and player_followpet.arena_id and player_followpet.arena_id == player.arena_id) then
						bMyFollowPetCombatMode = true;
					end
					local response = format("%d,%d,%s,%d,%d,%d,%d,%s<%s><%s><%s><%s><%s><%s>", nTimeRemaining, self.seq, self.mode, self:GetRoundTag(), remaining_deck_count, total_deck_count, remaing_switching_followpet_count, tostring(bMyFollowPetCombatMode), active_friendly_list_str, active_hostile_list_str, cards_at_hand_str, runes_at_hand_str, followpetcards_at_hand_str, followpet_history_str);
					combat_server.AppendRealTimeMessageToNID(self.combat_server_uid, player:GetID(), "PickYourCard:"..response);
				else
					---- directly pick minion card
					--local card_key, card_seq, card_target_ismob, card_target_id = player:PickMinionCard();
					--if(card_key ~= nil and card_seq and card_target_ismob ~= nil and card_target_id ~= nil) then
						--Arena.OnReponse_TellBuddyPickCard(player);
					--end
				end
			elseif(player and not player:IsAlive()) then
				-- show the user with available cards at hand
				local cards_at_hand, runes_at_hand, followpetcards_at_hand = player:GetCardsInHand();
				local cards_at_hand_str = "";
				local runes_at_hand_str = "";
				local followpetcards_at_hand_str = "";
				local followpet_history_str = "";
				local guid, _;
				for guid, _ in pairs(player.followpet_history) do
					followpet_history_str = followpet_history_str..guid..",";
				end
				local _, each_card;
				for _, each_card in ipairs(cards_at_hand) do
					local bCanCast = player:CanCastSpell(each_card.key);
					local cooldown = player:GetCoolDown(each_card.key);
					cards_at_hand_str = cards_at_hand_str..each_card.seq.."+"..tostring(bCanCast).."+"..cooldown.."+"..each_card.key..",";
				end
				local _, each_card;
				for _, each_card in ipairs(followpetcards_at_hand) do
					local bCanCast = player:CanCastSpell(each_card.key, true);
					local cooldown = player:GetCoolDown(each_card.key);
					followpetcards_at_hand_str = followpetcards_at_hand_str..each_card.seq.."+"..tostring(bCanCast).."+"..cooldown.."+"..each_card.key..",";
				end
				local each_rune, __;
				for each_rune, __ in pairs(runes_at_hand) do
					local bCanCast = player:CanCastSpell(each_rune);
					local cooldown = player:GetCoolDown(each_rune);
					local count = 0;
					local gsid = Card.Get_rune_gsid_from_cardkey(each_rune);
					if(gsid) then
						local bHas, _, __, copies = PowerItemManager.IfOwnGSItem(player:GetNID(), gsid);
						if(bHas and copies) then
							count = copies;
						else
							bCanCast = false;
						end
					end
					runes_at_hand_str = runes_at_hand_str..count.."+"..tostring(bCanCast).."+"..cooldown.."+"..each_rune..",";
				end
				-- pass 3.4: pick flee for dead players
				local nTimeRemaining = pickcard_timeout_time_pvp;
				local response = format("%d,%d,%s,%d,0,false<%s><%s><%s><%s><%s><%s>", nTimeRemaining, self.seq, self.mode, self:GetRoundTag(), active_friendly_list_str, active_hostile_list_str, cards_at_hand_str, runes_at_hand_str, followpetcards_at_hand_str, followpet_history_str);
				combat_server.AppendRealTimeMessageToNID(self.combat_server_uid, player:GetID(), "PickYourCard_dead:"..response);
			end
		end
	end
	
	-- minus nRemainingRounds
	self.nRemainingRounds = self.nRemainingRounds - 1;

	-- pass 2: update arena data to client
	self:UpdateToClient();
	-- pass 1: set pick card time out
	self.PickCardTimeOutTime = combat_server.GetCurrentTime() + pickcard_timeout_time_pvp;
	self.PlayTurnTimeOutTime = nil;
	self.PlayTurnMinTime = nil;

	if(System.options.version == "kids" and self.ranking_stage and string.match(self.ranking_stage,"3v3")) then
		local _, unit;
		for _, unit in ipairs(friendlys) do
			if(not unit.isMob) then
				local player = Player.GetPlayerCombatObj(unit.id);
				local nid = player:GetNID();
				if(player and nid) then
					if(player:IsCombatActive()) then
						if(player:BeAFK()) then
							if(player:IsAlive() and nid ~= 46650264) then -- only remove alive players
								Arena.OnReponse_TryFleeCombat(nid);
							else
								-- reset idle rounds for dead players
								player.nIdleRounds = 0;
								player.accumulateIdleRounds = 0;
							end
						end
					end
				end
			end
		end
	end

	self:DebugDumpData("------------------ end AdvanceOneTurn_v ------------------");
end

-- play one turn
function Arena:PlayOneTurn()
	self:DebugDumpData("------------------ begin PlayOneTurn ------------------");
	-- TODO:
	
	local i;
	for i = 1, max_player_count_per_arena do
		local nid = self.player_nids[i];
		if(nid) then
			local player = Player.GetPlayerCombatObj(nid);
			if(player and player.control_rounds and player.control_rounds > 0) then
				if(System.options.version == "teen") then
					if(nid > 0) then
						-- pick auto AI card for player
						Arena.OnReponse_PickAICardForPlayer(nid, true, self.seq);
					elseif(nid < 0) then
						-- pick auto AI card for follow pet minion
						player:PickMinionCard();
					end
				end
			end
		end
	end
	
	-- pass 4: pick card for each mob
	local pre_cast_speaks = {};

	-- pass 2: play card
	local TurnSpellSequence = {};
	TurnSpellSequence.duration = 0;

	-- first update the arena value
	local key, value = self:GetKey_normal_update(), self:GetValue_normal_update();
	local spell_str = format("update_arena:%s+%s", key, value);
	table_insert(TurnSpellSequence, spell_str);

	local arrow_position = self:GetCurrentSequenceArrowPosition();

	-- play mob cards
	local function PlayMobCards(bBeforeRoundBonus, bAfterRoundBonus, fake_pickcard_time_spell_str)
		local placed_fake_pickcard_time_spell_str = false;
		local index, id;
		for index, id in ipairs(self.mob_ids) do
			local mob = Mob.GetMobByID(id);
			if(mob and mob:IsAlive()) then
				local bPlayThisMobCard = true;
				if(bBeforeRoundBonus or bAfterRoundBonus) then
					if(not mob:GetPickedCardKey() or mob:GetPickedCardKey() == "pass" or mob:GetPickedCardKey() == "Pass") then
						bPlayThisMobCard = false;
					end
				end
				if(bPlayThisMobCard) then
					local motion = mob:GetPickCardMotion();
					if(motion) then
						local InMotionSpellSequence = {duration = 0};
						-- move arrow
						local spell_str = format("movearrow:%d+%d+%d", self:GetID(), arrow_position, mob:GetArrowPosition_id());
						table_insert(InMotionSpellSequence, spell_str);
						InMotionSpellSequence.duration = InMotionSpellSequence.duration + movearrow_spell_duration;
						if(not placed_fake_pickcard_time_spell_str) then
							placed_fake_pickcard_time_spell_str = true;
							if(fake_pickcard_time_spell_str) then
								table_insert(InMotionSpellSequence, fake_pickcard_time_spell_str);
							end
						end
						-- lock and unlock the arrow position to prevent wrong arrow position in usecard call
						self:LockCurrentSequenceArrowPosition(mob:GetArrowPosition_id());
						local speak_word = pre_cast_speaks[mob:GetID()];
						if(speak_word) then
							local spell_str = "speak:"..self:GetID()..",true,"..mob:GetID()..","..mob:GetPhase().."["..mob:GetDisplayName().."]".."["..speak_word.."]";
							table_insert(InMotionSpellSequence, spell_str);
							InMotionSpellSequence.duration = InMotionSpellSequence.duration + DEFAULT_SPEAK_DURATION;
						end
						mob:UseCard(self, InMotionSpellSequence);
						self:UnLockCurrentSequenceArrowPosition();
						arrow_position = mob:GetArrowPosition_id();
						-- play motion with InMotionSpellSequence
						local playturn_str = "motion_with_spell:"..self.position.x..","..self.position.y..","..self.position.z..","..motion..",";
						local _, str;
						for _, str in ipairs(InMotionSpellSequence) do
							playturn_str = playturn_str..""..str.."@@";
						end
						table_insert(TurnSpellSequence, playturn_str);
						-- reset camera after motion_with_spell
						local spell_str = format("resetcamera:%d", self:GetID());
						table_insert(TurnSpellSequence, spell_str);
						local duration = MotionXmlToTable.GetMovieDuration(motion) or DEFAULT_PLAYTURN_MOTION_DURATION;
						TurnSpellSequence.duration = TurnSpellSequence.duration + duration;
					else
						-- move arrow
						local spell_str = format("movearrow:%d+%d+%d", self:GetID(), arrow_position, mob:GetArrowPosition_id());
						table_insert(TurnSpellSequence, spell_str);
						TurnSpellSequence.duration = TurnSpellSequence.duration + movearrow_spell_duration;
						if(not placed_fake_pickcard_time_spell_str) then
							placed_fake_pickcard_time_spell_str = true;
							if(fake_pickcard_time_spell_str) then
								table_insert(TurnSpellSequence, fake_pickcard_time_spell_str);
							end
						end
						-- lock and unlock the arrow position to prevent wrong arrow position in usecard call
						self:LockCurrentSequenceArrowPosition(mob:GetArrowPosition_id());
						local speak_word = pre_cast_speaks[mob:GetID()];
						if(speak_word) then
							local spell_str = "speak:"..self:GetID()..",true,"..mob:GetID()..","..mob:GetPhase().."["..mob:GetDisplayName().."]".."["..speak_word.."]";
							table_insert(TurnSpellSequence, spell_str);
							TurnSpellSequence.duration = TurnSpellSequence.duration + DEFAULT_SPEAK_DURATION;
						end
						mob:UseCard(self, TurnSpellSequence);
						self:UnLockCurrentSequenceArrowPosition();
						arrow_position = mob:GetArrowPosition_id();
					end
				end
			end
			if(self:IsCombatFinished()) then
				-- stop playing cards immediately if combat is finished
				break;
			end
		end
	end
	-- play player cards
	local function PlayPlayerCards()
		local slot_id = 1;
		for slot_id = 1, max_player_count_per_arena do
			local player = self:GetPlayerCombatObjBySlotID(slot_id);
			if(player and player:IsAlive() and player:IsCombatActive()) then
				-- move arrow
				local spell_str = format("movearrow:%d+%d+%d", self:GetID(), arrow_position, player:GetArrowPosition_id());
				table_insert(TurnSpellSequence, spell_str);
				TurnSpellSequence.duration = TurnSpellSequence.duration + movearrow_spell_duration;
				-- lock and unlock the arrow position to prevent wrong arrow position in usecard call
				self:LockCurrentSequenceArrowPosition(player:GetArrowPosition_id());
				player:UseCard(self, TurnSpellSequence);
				self:UnLockCurrentSequenceArrowPosition();
				arrow_position = player:GetArrowPosition_id();
			end
			if(self:IsCombatFinished()) then
				-- stop playing cards immediately if combat is finished
				break;
			end
		end
	end
	
	-- play before round bonus
	pre_cast_speaks = self.ai_module.PickCardForEachMob(self, true, nil); -- bBefore, bAfter
	PlayMobCards(true, nil);
	pre_cast_speaks = {}; -- clear pre cast speak
	-- play all cards
	if(self.isNearArenaFirst == false) then
		pre_cast_speaks = self.ai_module.PickCardForEachMob(self);
		PlayMobCards();
		PlayPlayerCards();
	elseif(self.isNearArenaFirst == true) then
		PlayPlayerCards();
		local fake_pickcard_time_spell_str;
		if(not self:IsCombatFinished()) then
			if(self.fake_min_pickcard_time and self.fake_max_pickcard_time) then
				-- halt for fake pick card time
				local idle_second = math.random(self.fake_min_pickcard_time, self.fake_max_pickcard_time);
				fake_pickcard_time_spell_str = "halt:"..idle_second * 1000;
				TurnSpellSequence.duration = TurnSpellSequence.duration + idle_second * 1000;
			end
		end
		pre_cast_speaks = self.ai_module.PickCardForEachMob(self);
		PlayMobCards(nil, nil, fake_pickcard_time_spell_str);
	end
	-- play after round bonus
	pre_cast_speaks = self.ai_module.PickCardForEachMob(self, nil, true); -- bBefore, bAfter
	PlayMobCards(nil, true);
	pre_cast_speaks = {}; -- clear pre cast speak
	
	-- pass 3: set all players ready and inc played turns count
	local i;
	for i = 1, max_player_count_per_arena do
		local nid = self.player_nids[i];
		if(nid) then
			-- pass 3.1: set all current available players active
			local player = Player.GetPlayerCombatObj(nid);
			if(player) then
				-- pass 3.3: clear play turn finished
				player:ClearFinishPlayTurn();
				player.turns_played = (player.turns_played or 0) + 1;
			end
		end
	end
	
	-- play spell
	-- TODO: add arena specific 
	
	-- update the arena value when finished
	local key, value = self:GetKey_normal_update(), self:GetValue_normal_update();
	local spell_str = format("update_arena:%s+%s", key, value);
	table_insert(TurnSpellSequence, spell_str);

	-- append active players
	local playturn_str = "";
	local active_player_nids = "";
	local inactive_player_nids = "";
	local autocombat_player_nids = "";
	local i;
	for i = 1, max_player_count_per_arena do
		local nid = self.player_nids[i];
		if(nid) then
			local player = Player.GetPlayerCombatObj(nid);
			if(player and player:IsCombatActive()) then
				active_player_nids = active_player_nids..nid..",";
				if(self.AutoCombatNIDs and self.AutoCombatNIDs[nid]) then
					autocombat_player_nids = autocombat_player_nids..nid..",";
				end
			elseif(player and not player:IsCombatActive()) then
				inactive_player_nids = inactive_player_nids..nid..",";
			end
		end
	end

	-- clear auto combat nids
	self.AutoCombatNIDs = {};

	--log(playturn_str.."\n");
	LOG.std(nil, "user","arena","arena_id=%d|playturn_str:%s",self:GetID(),playturn_str);
	-- append play turn sequence
	local _, str;
	for _, str in ipairs(TurnSpellSequence) do
		playturn_str = playturn_str.."<"..str..">";
		--log(str.."\n");
		LOG.std(nil, "user","arena","arena_id=%d|%s",self:GetID(),str);
	end
	
	-- check if all mob dead
	local isAllMobDead = true;
	local index, id;
	for index, id in ipairs(self.mob_ids) do
		local mob = Mob.GetMobByID(id);
		if(mob and mob:IsAlive()) then
			isAllMobDead = false;
			break;
		end
	end

	local nExecutedRounds = self:GetRoundTag() or 0;
	local motion_path = self.playturn_motions[nExecutedRounds];
	if(motion_path) then
		if(isAllMobDead == false) then
			-- play motion
			local position_str = self.position.x..","..self.position.y..","..self.position.z;
			local spell_str = "playturnmotion:"..position_str..","..motion_path;
			playturn_str = playturn_str.."<"..spell_str..">";
			local duration = MotionXmlToTable.GetMovieDuration(motion_path) or DEFAULT_PLAYTURN_MOTION_DURATION;
			TurnSpellSequence.duration = TurnSpellSequence.duration + duration;
			-- update arena
			local key, value = self:GetKey_normal_update(), self:GetValue_normal_update();
			local spell_str = format("update_arena:%s+%s", key, value);
			playturn_str = playturn_str.."<"..spell_str..">";
		end
	end
	
	if(isAllMobDead == true) then
		-- play halt motion
		local spell_str = "halt:"..DEFAULT_HALT_MILLISECONDS;
		playturn_str = playturn_str.."<"..spell_str..">";
		local duration = DEFAULT_HALT_MILLISECONDS;
		TurnSpellSequence.duration = TurnSpellSequence.duration + duration;
		-- update arena
		local key, value = self:GetKey_normal_update(), self:GetValue_normal_update();
		local spell_str = format("update_arena:%s+%s", key, value);
		playturn_str = playturn_str.."<"..spell_str..">";
	end
	
	combat_server.AppendRealTimeMessage(self.combat_server_uid, "PlayTurn:"..self.seq.."?"..active_player_nids.."?"..inactive_player_nids.."?"..autocombat_player_nids.."?"..playturn_str);

	-- NOTE 2010/7/22 andy: skip the hp setting through separate message, mix the hp setting into the normal value update
	--
	---- set hp point
	---- NOTE: this is not the actual hp point displayed in the lower part of the hp slots
	----		it will directly set the player's current hp
	--local i;
	--for i = 1, max_player_count_per_arena do
		--local nid = self.player_nids[i];
		--if(nid) then
			--local player = Player.GetPlayerCombatObj(nid);
			--if(player and player:IsCombatActive()) then
				--combat_server.AppendRealTimeMessageToNID(self.combat_server_uid, nid, "SyncHP:"..player:GetCurrentHP());
			--end
		--end
	--end

	-- set play turn time out time
	self.PickCardTimeOutTime = nil;

	---- original implementation to use spell sequence count as the timeout time base
	--self.PlayTurnTimeOutTime = combat_server.GetCurrentTime() + spellplay_timeout_time_per_spell * #TurnSpellSequence;
	---- new implementation uses a calculated sum of spell duration count
	self.PlayTurnTimeOutTime = combat_server.GetCurrentTime() + TurnSpellSequence.duration + base_per_turn_delay;
	self.PlayTurnMinTime = combat_server.GetCurrentTime() + math_floor(TurnSpellSequence.duration * 0.9);
	
	self:DebugDumpData("------------------ end PlayOneTurn ------------------");
end

-- play one turn
function Arena:PlayOneTurn_v()
	self:DebugDumpData("------------------ begin PlayOneTurn_v ------------------");
	-- TODO:
	
	---- pass 4: pick card for each mob
	--local pre_cast_speaks = self.ai_module.PickCardForEachMob(self);

	-- pass 2: play card
	local TurnSpellSequence = {};
	TurnSpellSequence.duration = 0;

	-- first update the arena value
	local key, value = self:GetKey_normal_update(), self:GetValue_normal_update();
	local spell_str = format("update_arena:%s+%s", key, value);
	table_insert(TurnSpellSequence, spell_str);

	local arrow_position = self:GetCurrentSequenceArrowPosition();

	-- pass 1: play the friendly unit cards
	local lower_region = 1;
	local upper_region = 4;
	if(self.currentPlayingSide == "near") then
		lower_region = 1;
		upper_region = 4;
	elseif(self.currentPlayingSide == "far") then
		lower_region = 5;
		upper_region = 8;
	end

	local i;
	for i = lower_region, upper_region do
		local unit = self:GetCombatUnitBySlotID(i);
		if(unit and unit:IsMob()) then
			local mob = unit;
			--if(mob and mob:IsAlive()) then
				---- move arrow
				--local spell_str = format("movearrow:%d+%d+%d", self:GetID(), arrow_position, mob:GetArrowPosition_id());
				--table_insert(TurnSpellSequence, spell_str);
				--TurnSpellSequence.duration = TurnSpellSequence.duration + movearrow_spell_duration;
				---- lock and unlock the arrow position to prevent wrong arrow position in usecard call
				--self:LockCurrentSequenceArrowPosition(mob:GetArrowPosition_id());
				--local speak_word = pre_cast_speaks[mob:GetID()];
				--if(speak_word) then
					--local spell_str = "speak:"..self:GetID()..",true,"..mob:GetID().."["..speak_word.."]";
					--table_insert(TurnSpellSequence, spell_str);
				--end
				--mob:UseCard(self, TurnSpellSequence);
				--self:UnLockCurrentSequenceArrowPosition();
				--arrow_position = mob:GetArrowPosition_id();
			--end
		elseif(unit and not unit:IsMob()) then
			local player = unit;
			if(player and player:IsAlive() and player:IsCombatActive()) then
				-- move arrow
				local spell_str = format("movearrow:%d+%d+%d", self:GetID(), arrow_position, player:GetArrowPosition_id());
				table_insert(TurnSpellSequence, spell_str);
				TurnSpellSequence.duration = TurnSpellSequence.duration + movearrow_spell_duration;
				-- lock and unlock the arrow position to prevent wrong arrow position in usecard call
				self:LockCurrentSequenceArrowPosition(player:GetArrowPosition_id());
				player:UseCard(self, TurnSpellSequence);
				self:UnLockCurrentSequenceArrowPosition();
				arrow_position = player:GetArrowPosition_id();
			end
		end
	end
	
	-- pass 3: set all players ready and inc played turns count
	local playturn_str = "";
	local active_player_nids = "";
	local inactive_player_nids = "";
	local autocombat_player_nids = "";
	local i;
	for i = 1, max_unit_count_per_side_arena * 2 do
		local nid = self.player_nids[i];
		if(nid) then
			-- pass 3.1: set all current available players active
			local player = Player.GetPlayerCombatObj(nid);
			if(player) then
				-- pass 3.3: clear play turn finished
				player:ClearFinishPlayTurn();
				player.turns_played = (player.turns_played or 0) + 1;
				-- append active players
				if(player:IsCombatActive()) then
					active_player_nids = active_player_nids..nid..",";
					if(self.AutoCombatNIDs and self.AutoCombatNIDs[nid]) then
						autocombat_player_nids = autocombat_player_nids..nid..",";
					end
				elseif(not player:IsCombatActive()) then
					inactive_player_nids = inactive_player_nids..nid..",";
				end
			end
		end
	end
	
	-- clear auto combat nids
	self.AutoCombatNIDs = {};

	-- update the arena value when finished
	local key, value = self:GetKey_normal_update(), self:GetValue_normal_update();
	local spell_str = format("update_arena:%s+%s", key, value);
	table_insert(TurnSpellSequence, spell_str);
	
	--log(playturn_str.."\n");
	LOG.std(nil, "user","arena","arena_id=%d|playturn_str:%s",self:GetID(),playturn_str);
	-- append play turn sequence
	local _, str;
	for _, str in ipairs(TurnSpellSequence) do
		playturn_str = playturn_str.."<"..str..">";
		--log(str.."\n");
		LOG.std(nil, "user","arena","arena_id=%d|%s",self:GetID(),str);
	end
	
	combat_server.AppendRealTimeMessage(self.combat_server_uid, "PlayTurn:"..self.seq.."?"..active_player_nids.."?"..inactive_player_nids.."?"..autocombat_player_nids.."?"..playturn_str);

	-- set play turn time out time
	self.PickCardTimeOutTime = nil;

	---- original implementation to use spell sequence count as the timeout time base
	--self.PlayTurnTimeOutTime = combat_server.GetCurrentTime() + spellplay_timeout_time_per_spell * #TurnSpellSequence;
	---- new implementation uses a calculated sum of spell duration count
	self.PlayTurnTimeOutTime = combat_server.GetCurrentTime() + TurnSpellSequence.duration + base_per_turn_delay;
	self.PlayTurnMinTime = combat_server.GetCurrentTime() + math_floor(TurnSpellSequence.duration * 0.9);
	
	self:DebugDumpData("------------------ end PlayOneTurn_v ------------------");
end

-- finish one turn
function Arena:FinishOneTurn()
	self:DebugDumpData("------------------ begin FinishOneTurn ------------------");
	-- reset all time out time
	self.PickCardTimeOutTime = nil;
	self.PlayTurnTimeOutTime = nil;
	self.PlayTurnMinTime = nil;
	
	-- pending list for killing from the arena
	local pending_kill_list = {};
	-- pass 2: count heart arrest players and kill them if timedout to many times
	local i;
	for i = 1, max_player_count_per_arena do
		local nid = self.player_nids[i];
		if(nid) then
			-- pass 3.1: check if the player is heart arrest, inc the counter
			local player = Player.GetPlayerCombatObj(nid);
			if(player and player:IsHeartArrest() and not player:IsMinion()) then
				player.nHeartPaceMakeFailCounter = player.nHeartPaceMakeFailCounter + 1;
				if(player.nHeartPaceMakeFailCounter > 3) then
					-- kill player from arena
					table_insert(pending_kill_list, nid);
				end
			end
			-- pass 3.2: consume pill and food buff if not
			local player = Player.GetPlayerCombatObj(nid);
			if(player) then
				-- consume pill and food buff
				player:ConsumePillAndFoodBuffIfNot();
			end
		end
	end
	
	-- kill timedout players
	local _, nid;
	for _, nid in pairs(pending_kill_list) do
		local player = Player.GetPlayerCombatObj(nid);
		if(player) then
			-- process durability
			local durable_items = player.current_combat_durable_items;
			if(durable_items) then
				-- only cost durability on player dead
				local self_combat_server_uid = self.combat_server_uid;
				PowerItemManager.CostDurablity(nid, durable_items, true, function()
					combat_server.AppendRealTimeMessageToNID(self_combat_server_uid, nid, "UpdateEquipBags:1");
				end);
			end
		end
		self:RemovePlayerAndFollowPet(nid);
	end

	if(self.world_config_file == "config/Aries/WorldData_Teen/HaqiTown_RedMushroomArena_AI_1v1.Arenas_Mobs.xml") then
		if(self:GetRoundTag() > (MAX_ROUNDS_PVP_ARENA / 2)) then
			-- kill all mobs
			local index, id;
			for index, id in ipairs(self.mob_ids) do
				local mob = Mob.GetMobByID(id);
				if(mob and mob:IsAlive()) then
					mob:TakeDamage(99999999);
				end
			end
		end
	end

	-- if fight finished?
	if(self:IsCombatFinished()) then
		-- finish the combat
		self:FinishCombat();
	else
		-- advance one turn
		self:AdvanceOneTurn();
	end
	self:DebugDumpData("------------------ end FinishOneTurn ------------------");
end

-- finish one turn
function Arena:FinishOneTurn_v()
	self:DebugDumpData("------------------ begin FinishOneTurn_v ------------------");
	-- reset all time out time
	self.PickCardTimeOutTime = nil;
	self.PlayTurnTimeOutTime = nil;
	self.PlayTurnMinTime = nil;
	
	-- pending list for killing from the arena
	local pending_kill_list = {};
	-- pass 2: count heart arrest players and kill them if timedout to many times
	local i;
	for i = 1, max_unit_count_per_side_arena * 2 do
		local nid = self.player_nids[i];
		if(nid) then
			-- pass 3.1: check if the player is heart arrest, inc the counter
			local player = Player.GetPlayerCombatObj(nid);
			if(player and player:IsHeartArrest()) then
				player.nHeartPaceMakeFailCounter = player.nHeartPaceMakeFailCounter + 1;
				if(player.nHeartPaceMakeFailCounter > 3) then
					-- kill player from arena
					table_insert(pending_kill_list, nid);
				end
			end
			-- pass 3.2: consume pill and food buff if not
			local player = Player.GetPlayerCombatObj(nid);
			if(player) then
				-- consume pill and food buff
				player:ConsumePillAndFoodBuffIfNot();
			end
		end
	end
	
	-- kill timedout players
	local _, nid;
	for _, nid in pairs(pending_kill_list) do
		-- loser loot for pvp arena lose
		local loots = nil;
		if(self.insurance_and_loser_loots) then
			local insurance_gsid = self.insurance_and_loser_loots.insurance_gsid;

			local has_insurance, guid_insurance = PowerItemManager.IfOwnGSItem(nid, insurance_gsid);
			if(has_insurance) then
				-- insurance loots
				loots = self.insurance_and_loser_loots.loots;
			else
				-- loser loots
				loots = self.loser_loots;
			end
		end
		if(self.prior_insurance_and_loser_loots) then
			local insurance_gsid = self.prior_insurance_and_loser_loots.insurance_gsid;

			local has_insurance, guid_insurance = PowerItemManager.IfOwnGSItem(nid, insurance_gsid);
			if(has_insurance) then
				-- prior insurance loots
				loots = self.prior_insurance_and_loser_loots.loots;
			end
		end
		if(self.prior_prior_insurance_and_loser_loots) then
			local insurance_gsid = self.prior_prior_insurance_and_loser_loots.insurance_gsid;

			local has_insurance, guid_insurance = PowerItemManager.IfOwnGSItem(nid, insurance_gsid);
			if(has_insurance) then
				-- prior prior insurance loots
				loots = self.prior_prior_insurance_and_loser_loots.loots;
			end
		end
		if(self.prior_prior_prior_insurance_and_loser_loots) then
			local insurance_gsid = self.prior_prior_prior_insurance_and_loser_loots.insurance_gsid;

			local has_insurance, guid_insurance = PowerItemManager.IfOwnGSItem(nid, insurance_gsid);
			if(has_insurance) then
				-- prior prior prior insurance loots
				loots = self.prior_prior_prior_insurance_and_loser_loots.loots;
			end
		end
		if(not loots) then
			-- loser loots
			loots = self.loser_loots;
		end
		-- ranking points
		local player;
		if(self.ranking_stage) then
			
			player = Player.GetPlayerCombatObj(nid);
			if(player) then
				-- a loots copy
				loots = commonlib.deepcopy(loots) or {};

				if(player.lose_ranking_point_gsid and player.lose_ranking_point_count) then
					loots[player.lose_ranking_point_gsid] = player:GetRankingLoot(false);

					-- ranking stage post log
					combat_server.AppendPostLog( {
						action = "pvp_arena_ranking_point_log", 
						gsid = player.lose_ranking_point_gsid, 
						count = player.lose_ranking_point_count,
						nid = nid,
						reason = "timedout",
						nRemainingRounds = self.nRemainingRounds,
						ranking_stage = self.ranking_stage,
						ranking_info = self.RankingInfo_str,
						isNearArenaFirst = tostring(self.isNearArenaFirst),
					});
					
					-- send pvp ranking point info to lobby
					Map3DSystem.GSL.system:SendToLobbyServer({
						type = "pvp_arena_ranking_point_change",
						user_nid = 0,
						msg = {
							gsid = player.lose_ranking_point_gsid, 
							count = player.lose_ranking_point_count,
							nid = nid,
							reason = "timedout",
						},
					});
				end
			end
		end
		if(loots) then
			-- combat loots
			if(System.options.version == "kids" and self.ranking_stage and string.match(self.ranking_stage,"3v3")) then
				local adds_str = format("%d~%d~%s~%s|", 20091, -100, "NULL", "NULL");
				PowerItemManager.ChangeItem(nid, adds_str, nil, function(msg)
					if(msg.issuccess) then
						LOG.std(nil, "debug", "PowerExtendedCost", "%d connect timedout for 3v3 combat to deduct score：100", nid);
						if(self.ranking_stage and player) then
							player:SubmitScore(self.ranking_stage);
						end
					else
						LOG.std(nil, "debug", "PowerExtendedCost", "%d connect timedout for 3v3 combat to deduct score,callback function got error msg:%s", nid, commonlib.serialize_compact(msg));
					end
					-- some handler
				end, true, nil, true); -- greedy mode	
			else
				PowerItemManager.AddExpJoybeanLoots(nid, 0, nil, loots, function(msg) 
					if(self.ranking_stage and player) then
						player:SubmitScore(self.ranking_stage);
					end
				end);	
			end
			
			-- loots for quest server logics
			QuestServerLogics.DoAddValue_ByLoots(nid, loots);
		end

		self:RemovePlayerAndFollowPet(nid);
	end

	-- if fight finished?
	if(self:IsCombatFinished_v()) then
		-- finish the combat
		self:FinishCombat_v();
	else
		if(self.nRemainingRounds <= 0) then
			-- no remaining rounds
			-- finish the combat
			self:FinishCombat_v();
		else
			-- advance one turn
			self:AdvanceOneTurn_v();
		end
	end
	self:DebugDumpData("------------------ end FinishOneTurn_v ------------------");
end



local pipcost_contribution_mapping = {
	[0] = 2,
	[1] = 4,
	[2] = 10,
	[3] = 20,
	[4] = 34,
	[5] = 52,
	[6] = 74,
	[7] = 100,
	[8] = 130,
	[9] = 164,
	[10] = 202,
	[11] = 244,
	[12] = 290,
	[13] = 340,
	[14] = 394,
};

-- finish the combat
function Arena:FinishCombat()
	self:DebugDumpData("------------------ begin FinishCombat ------------------");
	--TODO:
	-- TODO: set back the player health point

	local nCombatStartTime = self.nCombatStartTime;

	-- respawn mob 
	-- if all mobs are dead
	-- check if each mob is alive
	local isAllMobDead = true;
	local index, id;
	for index, id in ipairs(self.mob_ids) do
		local mob = Mob.GetMobByID(id);
		if(mob and mob:IsAlive()) then
			isAllMobDead = false;
			break;
		end
	end
	
	-- catch pet nid and gsid mapping
	local catch_pet_nid_gsid_mapping = {};
	local index, id;
	for index, id in ipairs(self.mob_ids) do
		local mob = Mob.GetMobByID(id);
		if(mob and not mob:IsAlive()) then
			local nid, gsid = mob:GetCatchPet_nid_gsid();
			if(nid and gsid) then
				if(catch_pet_nid_gsid_mapping[nid]) then
					table.insert(catch_pet_nid_gsid_mapping[nid], gsid);
				else
					catch_pet_nid_gsid_mapping[nid] = {gsid};
				end
			end
		end
	end

	if(isAllMobDead) then
		if(not self.is_single_fight) then
			-- respawn all in an amount of time
			self.respawn_time = combat_server.GetCurrentTime() + self.respawn_interval;
		end

		if(self.arena_lock_id) then
			local locked_arena = Arena.GetArenaByID(self.arena_lock_id);
			if(locked_arena) then
				if(locked_arena.arena_key_rules) then
					local bRespawn = false;
					local _, each_rule;
					for _, each_rule in pairs(locked_arena.arena_key_rules) do
						local isAllLockArenaAllMobDead = true;
						local _, a_id;
						for _, a_id in pairs(each_rule) do
							local key_arena = Arena.GetArenaByID(a_id);
							if(key_arena) then
								-- check if all mob dead
								local isAllMobDead = true;
								local index, id;
								for index, id in ipairs(key_arena.mob_ids) do
									local mob = Mob.GetMobByID(id);
									if(mob and mob:IsAlive()) then
										isAllMobDead = false;
										break;
									end
								end
								if(isAllMobDead == false) then
									isAllLockArenaAllMobDead = false;
									break;
								end
							end
						end
						if(isAllLockArenaAllMobDead) then
							bRespawn = true;
							break;
						end
					end
					
					-- if all key arena mob dead respawn the lock arena
					if(bRespawn) then
						locked_arena:RespawnAll_pve();
					end
				end
			end
		end

	else
		-- respawn all related mobs, if not single fight
		if(self.is_single_fight) then
			-- kill all
			self:ResetAndKillAll_pve();
			---- play motion id for players
			--if(self.end_motion_id) then
				--local position_str = self.position.x..","..self.position.y..","..self.position.z;
				--local slot_id = 1;
				--for slot_id = 1, max_player_count_per_arena do
					--local player = self:GetPlayerCombatObjBySlotID(slot_id);
					--local nid = self.player_nids[slot_id];
					--if(nid and player) then
						--combat_server.AppendRealTimeMessageToNID(self.combat_server_uid, nid, "PlayMotion:"..position_str..","..self.end_motion_id);
					--end
				--end
			--end
		else
			-- respawn all mobs in pve arena
			self:RespawnAll_pve();
		end
	end
	
	-- check if any active player is alive
	local isAllPlayerDead = true;
	local slot_id = 1;
	for slot_id = 1, max_player_count_per_arena do
		local player = self:GetPlayerCombatObjBySlotID(slot_id);
		local nid = self.player_nids[slot_id];
		if(nid and player and player:IsCombatActive() and player:IsAlive() and not player:IsMinion()) then
			isAllPlayerDead = false;
			break;
		end
	end

	-- record each and all pip cost
	local contributions = {};
	local joybean_loots = {};
	local item_loots = {};
	local stamina_costs = {};
	local insufficient_stamina_nids = {};
	local lootable_mobs_quest = {};
	local lootable_mobs_quest_keystruct = {};
	local all_contribution = 0;
	local active_player_count = 0;
	local player_turns_played = {};
	local max_turns_played = 0;
	local max_card_pipcost = 0;
	local used_card_counts = {};
	local max_used_card_count = 0;
	
	-- get max card pipcost
	local slot_id = 1;
	for slot_id = 1, max_player_count_per_arena do
		local player = self:GetPlayerCombatObjBySlotID(slot_id);
		local nid = self.player_nids[slot_id];
		if(nid and player and player:IsCombatActive()) then
			-- for active players calculate the contribution
			local history = player:GetCardHistory();
			if(history) then
				local _, played_card;
				for _, played_card in pairs(history) do
					local card_key = played_card.key;
					local pips_realcost = played_card.pips_realcost;
					local cardTemplate = Card.GetCardTemplate(card_key)
					if(cardTemplate and pips_realcost) then
						if(max_card_pipcost < pips_realcost) then
							max_card_pipcost = pips_realcost;
						end
					end
				end
			end
		end
	end

	-- calculate exp
	local slot_id = 1;
	for slot_id = 1, max_player_count_per_arena do
		local player = self:GetPlayerCombatObjBySlotID(slot_id);
		local nid = self.player_nids[slot_id];
		if(nid and player and player:IsCombatActive() and not player:IsMinion()) then
			-- inc active player count
			active_player_count = active_player_count + 1;
			-- record each player played turns
			player_turns_played[nid] = player.turns_played;
			-- record max turns played
			if(max_turns_played < player.turns_played) then
				max_turns_played = player.turns_played;
			end
			-- for active players calculate the contribution
			local history = player:GetCardHistory();
			if(history) then
				local this_contribution = 0;
				local this_used_card_count = 0;
				local _, played_card;
				for _, played_card in pairs(history) do
					this_used_card_count = this_used_card_count + 1;
				end
				if(this_used_card_count > max_used_card_count) then
					max_used_card_count = this_used_card_count;
				end
				used_card_counts[nid] = this_used_card_count;
				--local _, played_card;
				--for _, played_card in pairs(history) do
					--this_used_card_count = this_used_card_count + 1;
					--local card_key = played_card.key;
					--local target_ismob = played_card.target_ismob;
					--local target_id = played_card.target_id;
					--local pips_realcost = played_card.pips_realcost;
					--local cardTemplate = Card.GetCardTemplate(card_key)
					--if(cardTemplate and pips_realcost) then
						--local base_contribution = pipcost_contribution_mapping[pips_realcost];
						--if(target_ismob == false and target_id == nid) then
							---- himself, cut the contribution to half if casted on himself
							--this_contribution = this_contribution + math.ceil(base_contribution / 2);
						--else
							--this_contribution = this_contribution + base_contribution;
						--end
					--end
				--end
				--
				--this_contribution = this_contribution + player.turns_played * (max_card_pipcost + 1)/2;
				--
				--all_contribution = all_contribution + this_contribution;
				--contributions[nid] = this_contribution;
			end

			-- for active players calculate the lootable joybeans
			local this_joybean_loot = 0;
			local _, id;
			for _, id in ipairs(player.lootables) do
				local mob = Mob.GetMobByID(id);
				if(mob) then
					local this_mob_joybean = mob:GetJoybean(player.loot_scale, player:GetLevel());
					this_joybean_loot = this_joybean_loot + this_mob_joybean;
					-- mob loot joybean log
					combat_server.AppendPostLog( {
						action = "mob_joybean_src", 
						joybean = this_mob_joybean,
						nid = player:GetNID(),
						mob_key = mob:GetKey(),
						reason = "via_joybean_loot",
					});
				end
			end
			joybean_loots[nid] = this_joybean_loot;
			
			-- quest lootable mobs
			local this_lootable_mobs_quest = "";
			local this_lootable_mobs_quest_keystruct = {};
			local _, id;
			for _, id in ipairs(player.lootables) do
				local mob = Mob.GetMobByID(id);
				if(mob) then
					if(mob:GetKey()) then
						this_lootable_mobs_quest_keystruct[mob:GetKey()] = (this_lootable_mobs_quest_keystruct[mob:GetKey()] or 0) + 1;
					end
					this_lootable_mobs_quest = this_lootable_mobs_quest..(mob:GetKey() or "").."#";
				end
			end
			lootable_mobs_quest[nid] = this_lootable_mobs_quest;
			lootable_mobs_quest_keystruct[nid] = this_lootable_mobs_quest_keystruct;
			
			-- no energy cost for easy difficulty
			if(self.stamina_cost) then
				--if(self:GetDifficulty() ~= "easy") then
				if(self:GetDifficulty() ~= "easy" or System.options.version == "teen") then
					local userdragoninfo = PowerItemManager.GetUserAndDragonInfoInMemory(nid);
					if(userdragoninfo and userdragoninfo.dragon.stamina) then
						if(userdragoninfo.dragon.stamina <= 0) then
							-- clear loots if stamina is insufficient
							insufficient_stamina_nids[nid] = true;
							combat_server.AppendRealTimeMessageToNID(self.combat_server_uid, nid, "InsufficientStamina:");
						else
							stamina_costs[nid] = self.stamina_cost;
						end
					end
				end
			end
			
			local appended_singleton_gsids = {};

			-- for active players calculate the lootable joybeans
			local this_item_loot = "";
			local this_item_loot_list = {};
			-- bonus exchange
			if(self.bonus_exchange) then
				local exchange_gsid = self.bonus_exchange.exchange_gsid;
				if(exchange_gsid) then
					local has_exchange, guid_exchange = PowerItemManager.IfOwnGSItem(nid, exchange_gsid);
					if(has_exchange) then
						-- destroy exchange item
						-- cost exchange_gsid log
						combat_server.AppendPostLog( {
							action = "cost_exchange_gsid", 
							guid = guid_exchange, 
							gsid = exchange_gsid, 
							nid = nid,
						});
						PowerItemManager.DestroyItemBatch(nid, {[guid_exchange] = 1}, function(msg) end);
						-- exchange loots
						local bonus_exchange_loots = self.bonus_exchange.loots;
						local gsid, count;
						for gsid, count in pairs(bonus_exchange_loots) do
							this_item_loot_list[gsid] = (this_item_loot_list[gsid] or 0) + count;
						end
					end
				end
			end
			-- equip exchange
			if(self.equip_exchange and player:IsAlive()) then
				local equip_exchange_from = self.equip_exchange.equip_exchange_from;
				local equip_exchange_to = self.equip_exchange.equip_exchange_to;
				if(equip_exchange_from and equip_exchange_to) then
					-- marked in the enter combat equips
					if(player:IfEquipItemInEnterCombat(equip_exchange_from)) then
						local has_exchange, guid_exchange = PowerItemManager.IfOwnGSItem(nid, equip_exchange_from);
						-- user own the exchange item
						if(has_exchange) then
							-- equip exchange log
							combat_server.AppendPostLog( {
								action = "arena_equip_exchange", 
								equip_exchange_from = equip_exchange_from, 
								equip_exchange_to = equip_exchange_to,
								nid = nid,
							});
							-- destroy exchange item
							PowerItemManager.DestroyItemBatch(nid, {[guid_exchange] = 1}, function(msg) end);
							-- NOTE 2013/2/4: unknown bug for unexecuted loots
							PowerItemManager.AddExpJoybeanLoots(nid, 0, 0, {[equip_exchange_to] = 1}, function(msg) end);
							-- exchange loots
							this_item_loot_list[equip_exchange_to] = (this_item_loot_list[equip_exchange_to] or 0) + 1;
						end
					end
				end
			end
			-- equip pair exchange
			if(self.item_pair_exchange and player:IsAlive()) then
				local item_pair_exchange_from_1 = self.item_pair_exchange.item_pair_exchange_from_1;
				local item_pair_exchange_from_2 = self.item_pair_exchange.item_pair_exchange_from_2;
				local item_pair_exchange_to = self.item_pair_exchange.item_pair_exchange_to;
				if(item_pair_exchange_from_1 and item_pair_exchange_from_2 and item_pair_exchange_to) then
					-- user own the exchange item
					local has_exchange_1, guid_exchange_1 = PowerItemManager.IfOwnGSItem(nid, item_pair_exchange_from_1);
					local has_exchange_2, guid_exchange_2 = PowerItemManager.IfOwnGSItem(nid, item_pair_exchange_from_2);
					if(has_exchange_1 and has_exchange_2) then
						-- equip exchange log
						combat_server.AppendPostLog( {
							action = "arena_item_pair_exchange", 
							item_pair_exchange_from_1 = item_pair_exchange_from_1, 
							item_pair_exchange_from_2 = item_pair_exchange_from_2, 
							item_pair_exchange_to = item_pair_exchange_to,
							guid_exchange_1 = guid_exchange_1,
							guid_exchange_2 = guid_exchange_2,
							nid = nid,
						});
						-- destroy exchange item
						PowerItemManager.DestroyItemBatch(nid, {[guid_exchange_1] = 1, [guid_exchange_2] = 1}, function(msg) end);
						-- NOTE 2013/2/4: unknown bug for unexecuted loots
						PowerItemManager.AddExpJoybeanLoots(nid, 0, 0, {[item_pair_exchange_to] = 1}, function(msg) end);
						-- exchange loots
						this_item_loot_list[item_pair_exchange_to] = (this_item_loot_list[item_pair_exchange_to] or 0) + 1;
					end
				end
			end



			-- lootable mobs
			local _, id;
			for _, id in ipairs(player.lootables) do
				local mob = Mob.GetMobByID(id);
				if(mob) then
					local this_postlog_mob_loots_gsids = "";
					local this_postlog_mob_loots_gsids_list = {};
					local this_postlog_mob_loots_esellprice = 0;
					-- 12010_WishStone_DarklyCombatBack
					local must_drop_gsid_if_available = nil;
					-- if 
					local success_WishStone = false;
					local wish_loot = {};

					local exChangeList = {
						[1713] = {from_gsid = 12010, to_gsid = 1713},
						--12010_WishStone_DarklyCombatBack , 1713_DarklyCombatBack
						[17222] = {from_gsid = 12021, to_gsid = 17222},
						--12021_WishStone_Pet_Bonfire_Boss , 17222_Pet_Bonfire_BossStone
						[17532] = {from_gsid = 17533, to_gsid = 17532},
						--17533_WishStone_Pet_BonIce_Boss , 17532_Pet_MagmaFireBon_BossStone
					};
					local beHas,from_guid;

					if(System.options.version == "kids") then
						if(not isAllPlayerDead) then
							local k,v;
							for k,v in pairs(exChangeList) do
								beHas,from_guid = PowerItemManager.IfOwnGSItem(nid, v["from_gsid"]);
								if(beHas) then
									must_drop_gsid_if_available = v["to_gsid"];
									v["from_guid"] = from_guid;
									v["beHas"] = beHas;
									local loots_gsid, shared_loot = mob:GetLoot(must_drop_gsid_if_available, player.loot_scale, nid, player:GetPhase(), player:GetLevel());
									if(loots_gsid and loots_gsid[1] == must_drop_gsid_if_available) then
										success_WishStone = true;
										v["needDestroy"] = true;
										table.insert(wish_loot,must_drop_gsid_if_available);
									end
								end	
							end
						end
					end
					if(not insufficient_stamina_nids[nid]) then
						local loots_gsid, shared_loot;

						if(success_WishStone) then
							loots_gsid = wish_loot;
						else
							loots_gsid, shared_loot = mob:GetLoot(nil, player.loot_scale, nid, player:GetPhase(), player:GetLevel());
						end

						-- process shared loot
						if(shared_loot) then
							local _, loot_name;
							for _, loot_name in pairs(shared_loot) do
								
								if(SharedLoot.CheckLoot(loot_name) and player:IsAlive()) then
									Map3DSystem.GSL.system:TryGetSharedLoot(nid, loot_name);
								end
							end
						end
						if(loots_gsid) then
							if(catch_pet_nid_gsid_mapping[nid]) then
								local _, gsid;
								for _, gsid in pairs(catch_pet_nid_gsid_mapping[nid]) do
									table.insert(loots_gsid, gsid);
								end
							end
							local _, gsid;
							for _, gsid in pairs(loots_gsid) do
								-- NOTE: 8999 is the largest available equip items
								-- 10101 ~ 10999  follow pet
								if(gsid and ((gsid >= 1001 and gsid < 8999) or (gsid >= 10101 and gsid < 10999))) then
									-- NOTE: since the bags_live_update includes both bag 0 and bag 1, if item is an equipment, don't loot if exist
									-- NOTE: since the bags_live_update includes both bag 0 and bag 10010, if item is a follow pet, don't loot if exist
									if(not PowerItemManager.IfOwnGSItem(nid, gsid) and not appended_singleton_gsids[gsid]) then
										-- don't have the item and not appended in this arena loot before
										this_item_loot_list[gsid] = (this_item_loot_list[gsid] or 0) + 1;
										this_postlog_mob_loots_gsids_list[gsid] = (this_postlog_mob_loots_gsids_list[gsid] or 0) + 1;
										local gsItem = PowerItemManager.GetGlobalStoreItemInMemory(gsid);
										if(gsItem and gsItem.esellprice) then
											this_postlog_mob_loots_esellprice = this_postlog_mob_loots_esellprice + gsItem.esellprice;
										end
										-- 1713_DarklyCombatBack wish stone
										appended_singleton_gsids[gsid] = true;
										if(exChangeList[gsid]) then
											local item = exChangeList[gsid];
											if(item["beHas"] and item["needDestroy"]) then
												local guid = item["from_guid"];
												PowerItemManager.DestroyItemBatch(nid, {[guid] = 1}, function(msg) end);
											end
										end

										--if(gsid == 1713 and bHas_12010 and guid_12010) then
											--PowerItemManager.DestroyItemBatch(nid, {[guid_12010] = 1}, function(msg) end);
											---- force loot wing
											----PowerItemManager.AddExpJoybeanLoots(nid, 0, 0, {[1713] = 1}, function(msg) end);
										--end
									end
								elseif(gsid) then
									this_item_loot_list[gsid] = (this_item_loot_list[gsid] or 0) + 1;
									this_postlog_mob_loots_gsids_list[gsid] = (this_postlog_mob_loots_gsids_list[gsid] or 0) + 1;
									local gsItem = PowerItemManager.GetGlobalStoreItemInMemory(gsid);
									if(gsItem and gsItem.esellprice) then
										this_postlog_mob_loots_esellprice = this_postlog_mob_loots_esellprice + gsItem.esellprice;
									end
									local beHas,_,_,copies = PowerItemManager.IfOwnGSItem(nid, gsid);
									if(exChangeList[gsid] and ((copies or 0) < gsItem.template.maxcount)) then
										local item = exChangeList[gsid];
										if(item["beHas"] and item["needDestroy"]) then
											local guid = item["from_guid"];
											
											local assetkey;
											if(gsItem) then
												assetkey = gsItem.assetkey;
											else
												assetkey = "assetkey_unknown";
											end

											local action = "cost_"..assetkey;
											combat_server.AppendPostLog({
												action = action, 
												guid = guid, 
												nid = nid,
											});
											PowerItemManager.DestroyItemBatch(nid, {[guid] = 1}, function(msg) end);
										end
									end


									--if(gsid == 17222 and bHas_12021 and guid_12021) then
										---- cost 12021_WishStone_Pet_Bonfire_Boss log
										--combat_server.AppendPostLog( {
											--action = "cost_12021_WishStone_Pet_Bonfire_Boss", 
											--guid_12021 = guid_12021, 
											--nid = nid,
										--});
										--PowerItemManager.DestroyItemBatch(nid, {[guid_12021] = 1}, function(msg) end);
									--end
								end
							end
						end
					end

					
					if(mob:GetKey()) then
						this_postlog_mob_loots_gsids = "";
						local gsid, count;
						for gsid, count in pairs(this_postlog_mob_loots_gsids_list) do
							this_postlog_mob_loots_gsids = this_postlog_mob_loots_gsids ..gsid.."#"..count.."##";
						end
						-- mob loot joybean log
						combat_server.AppendPostLog( {
							action = "mob_joybean_src", 
							joybean = this_postlog_mob_loots_esellprice,
							gsids = this_postlog_mob_loots_gsids,
							nid = player:GetNID(),
							mob_key = mob:GetKey(),
							reason = "via_items_loot",
						});
					end
				end
			end
			
			-- NOTE: reset the this_item_loot with new gsid+count format, instead of gsid list
			this_item_loot = "";
			local gsid, count;
			for gsid, count in pairs(this_item_loot_list) do
				this_item_loot = this_item_loot ..gsid.."#"..count.."##";
			end
			item_loots[nid] = this_item_loot;
		end
	end
	
	-- all buddy experience
	local all_buddy_exp = "";
	-- expend all experiences
	local each_nid, used_card_count;
	for each_nid, used_card_count in pairs(used_card_counts) do
		local this_exp = 0;
		local player = Player.GetPlayerCombatObj(each_nid);
		if(player and player:IsCombatActive()) then
			local _, id;
			for _, id in ipairs(player.lootables) do
				local mob = Mob.GetMobByID(id);
				if(mob) then
					this_exp = this_exp + mob:GetExp(player.loot_scale, player:GetLevel());
				end
			end
		end
		-- send to each client
		local original_exp = 0;
		if(max_used_card_count and max_used_card_count > 0) then
			original_exp = math.ceil(this_exp * (1 - math_min((max_used_card_count - used_card_count) * 0.1, 0.5)));
		end
		local exp_scale_acc = PowerItemManager.GetExpScaleAcc(each_nid);
		local exp_scale_acc_buff, tobe_destroyed_buff_guids;
		-- apply buffed exp scale only when the original exp is positive
		if(original_exp > 0) then
			exp_scale_acc_buff, tobe_destroyed_buff_guids = PowerItemManager.GetExpScaleAcc_buff(each_nid);
			exp_scale_acc = exp_scale_acc + exp_scale_acc_buff;
		end
		local gained_exp = math.ceil(original_exp * (1 + exp_scale_acc));
		all_buddy_exp = all_buddy_exp.."("..each_nid..","..gained_exp..","..original_exp..","..(1 + exp_scale_acc)..")";
	end
	
	-- all buddy joybeans
	local all_buddy_joybeans = "";
	-- max player turns played
	local player_turns_played_max = 0;
	-- max arena turns played
	-- NOTE 2012/2/18: fix bug: player_turns is reset after flee
	local arena_turns_played_max = self:GetRoundTag() or 1000;
	local nid_list = "";
	local nid_list_table = {};
	-- expend all joybeans
	local each_nid, each_turns_played;
	for each_nid, each_turns_played in pairs(player_turns_played) do
		-- send to each client
		local gained_joybean = math.ceil(joybean_loots[each_nid] * each_turns_played / max_turns_played);
		all_buddy_joybeans = all_buddy_joybeans.."("..each_nid..","..gained_joybean..")";
		-- record max player turns played and nid list for server post log
		nid_list = nid_list..each_nid..",";
		table.insert(nid_list_table, each_nid);
		if(each_turns_played > player_turns_played_max) then
			player_turns_played_max = each_turns_played;
		end
	end

	local submit_score;
	local elapsed_seconds = math.ceil((combat_server.GetCurrentTime() - (nCombatStartTime or 99999)) / 1000);

	if(System.options.version == "kids") then
		submit_score = STARTING_ACHIEVEMENT_ROUND - arena_turns_played_max;
	else
		submit_score = STARTING_ACHIEVEMENT_ROUND - (elapsed_seconds + arena_turns_played_max * 100000);
	end

	if(self.boss_id and not isAllPlayerDead) then
		local difficulty = tostring(self:GetDifficulty());
		-- we will only post to remote server if difficulty is "hard"
		combat_server.AppendPostLog( {
				action = "user_kill_boss_pve", 
				player_turns_played_max = arena_turns_played_max,
				boss_id = self.boss_id,
				nid_list = nid_list,
				difficulty = difficulty,
				elapsed_seconds = elapsed_seconds,
			}, (difficulty == "easy" or difficulty == "normal") );
	end

	local difficulty = tostring(self:GetDifficulty());
	if(difficulty == "normal" and self.boss_round_achievement_normal_gsid and not isAllPlayerDead) then
		-- post log user achievement
		combat_server.AppendPostLog( {
				action = "user_achievement_boss_round", 
				player_turns_played_max = arena_turns_played_max,
				gsid = self.boss_round_achievement_normal_gsid,
				nid_list = nid_list,
				difficulty = difficulty,
			} );
		-- user achievement item
		local gsid = self.boss_round_achievement_normal_gsid;
		local _, nid;
		for _, nid in pairs(nid_list_table) do
			if(not PowerItemManager.IsInSpecialList(nid)) then
				local player = Player.GetPlayerCombatObj(nid);
				if(player and player:IsCombatActive() and not player:IsMinion()) then
					PowerItemManager.SetItemCountIfEmptyOrMore(nid, gsid, arena_turns_played_max, function(msg) end);
					RankingServer.SubmitScore("Achievement_"..gsid, nid, nil, submit_score, function(msg) end, nil, player:GetPhase());
				end
			end
		end
	elseif(difficulty == "hard" and self.boss_round_achievement_hard_gsid and not isAllPlayerDead) then
		-- post log user achievement
		combat_server.AppendPostLog( {
				action = "user_achievement_boss_round", 
				player_turns_played_max = arena_turns_played_max,
				gsid = self.boss_round_achievement_hard_gsid,
				nid_list = nid_list,
				difficulty = difficulty,
			} );
		-- user achievement item
		local gsid = self.boss_round_achievement_hard_gsid;
		local _, nid;
		for _, nid in pairs(nid_list_table) do
			if(not PowerItemManager.IsInSpecialList(nid)) then
				local player = Player.GetPlayerCombatObj(nid);
				if(player and player:IsCombatActive() and not player:IsMinion()) then
					PowerItemManager.SetItemCountIfEmptyOrMore(nid, gsid, arena_turns_played_max, function() end);
					RankingServer.SubmitScore("Achievement_"..gsid, nid, nil, submit_score, function(msg) end, nil, player:GetPhase());
				end
			end
		end
	elseif(difficulty == "hero" and self.boss_round_achievement_hero_gsid and not isAllPlayerDead) then
		-- post log user achievement
		combat_server.AppendPostLog( {
				action = "user_achievement_boss_round", 
				player_turns_played_max = arena_turns_played_max,
				gsid = self.boss_round_achievement_hero_gsid,
				nid_list = nid_list,
				difficulty = difficulty,
			} );
		-- user achievement item
		local gsid = self.boss_round_achievement_hero_gsid;
		local _, nid;
		for _, nid in pairs(nid_list_table) do
			if(not PowerItemManager.IsInSpecialList(nid)) then
				local player = Player.GetPlayerCombatObj(nid);
				if(player and player:IsCombatActive() and not player:IsMinion()) then
					PowerItemManager.SetItemCountIfEmptyOrMore(nid, gsid, arena_turns_played_max, function() end);
					RankingServer.SubmitScore("Achievement_"..gsid, nid, nil, submit_score, function(msg) end, nil, player:GetPhase());
				end
			end
		end
	elseif(difficulty == "nightmare" and self.boss_round_achievement_nightmare_gsid and not isAllPlayerDead) then
		-- post log user achievement
		combat_server.AppendPostLog( {
				action = "user_achievement_boss_round", 
				player_turns_played_max = arena_turns_played_max,
				gsid = self.boss_round_achievement_nightmare_gsid,
				nid_list = nid_list,
				difficulty = difficulty,
			} );
		-- user achievement item
		local gsid = self.boss_round_achievement_nightmare_gsid;
		local _, nid;
		for _, nid in pairs(nid_list_table) do
			if(not PowerItemManager.IsInSpecialList(nid)) then
				local player = Player.GetPlayerCombatObj(nid);
				if(player and player:IsCombatActive() and not player:IsMinion()) then
					PowerItemManager.SetItemCountIfEmptyOrMore(nid, gsid, arena_turns_played_max, function() end);
					RankingServer.SubmitScore("Achievement_"..gsid, nid, nil, submit_score, function(msg) end, nil, player:GetPhase());
				end
			end
		end
	end
	
	-- all buddy loots
	local all_buddy_loots = "";
	-- expend all joybeans
	local each_nid, each_loot;
	for each_nid, each_loot in pairs(item_loots) do
		-- send to each client
		all_buddy_loots = all_buddy_loots.."("..each_nid..","..each_loot..")";
	end

	-- reset lootable players
	if(self.treasurebox) then
		self.treasurebox.lootable_nids = {};
	end
	
	-- expend all experience
	local each_nid, used_card_count;
	for each_nid, used_card_count in pairs(used_card_counts) do
		-- send to each client
		local this_exp = 0;
		local player = Player.GetPlayerCombatObj(each_nid);
		if(player and player:IsCombatActive()) then
			local _, id;
			for _, id in ipairs(player.lootables) do
				local mob = Mob.GetMobByID(id);
				if(mob) then
					this_exp = this_exp + mob:GetExp(player.loot_scale, player:GetLevel());
				end
			end
		end
		if(not player:IsMinion() and each_nid ~= "localuser") then -- not minion
			local original_exp = 0;
			if(max_used_card_count and max_used_card_count > 0) then
				original_exp = math.ceil(this_exp * (1 - math_min((max_used_card_count - used_card_count) * 0.1, 0.5)));
			end
			local exp_scale_acc = PowerItemManager.GetExpScaleAcc(each_nid);
			-- apply buffed exp scale only when the original exp is positive
			local exp_scale_acc_buff, tobe_destroyed_buff_guids;
			if(original_exp > 0) then
				exp_scale_acc_buff, tobe_destroyed_buff_guids = PowerItemManager.GetExpScaleAcc_buff(each_nid);
				exp_scale_acc = exp_scale_acc + exp_scale_acc_buff;
			end
			local gained_exp = math.ceil(original_exp * (1 + exp_scale_acc));
			local gained_joybean = math.ceil(joybean_loots[each_nid] * player_turns_played[each_nid] / max_turns_played);
			local gained_loot = item_loots[each_nid] or "";
			local gained_lootable_mobs_quest = lootable_mobs_quest[each_nid] or "";
			local gained_lootable_mobs_quest_keystruct = lootable_mobs_quest_keystruct[each_nid];
			local rewards_str = string.format("%d~%d~%f~%s~%s~%s~%s~%s~%s", 
					gained_exp, original_exp, 1 + exp_scale_acc, all_buddy_exp, gained_joybean, all_buddy_joybeans, gained_loot, all_buddy_loots, gained_lootable_mobs_quest);
			local each_player_result_str = string.format("%s~%d~%d~%f~%s~%s", 
					tostring(each_nid), gained_exp, original_exp, 1 + exp_scale_acc, gained_joybean, gained_loot);
			local player = Player.GetPlayerCombatObj(each_nid);
			local process_reward = false;
			local process_durability_isdead = true;
			local pet_exp = 0;
			local PlayMotion_str;
			--每次击杀后，可进行loot的次数与魔法星等级挂钩。
			--0:1次
			--1~3:2
			--4~6:3
			--7~9:4
			--10:5
			local m_level = PowerItemManager.GetMagicStarLevel(each_nid);
			local additional_loot_count = 1;
			if(m_level) then
				-- NOTE 2014/9/10:
				--李宇(Liyu) 09:38:19
				--调整为 vip等级+1
				--李宇(Liyu) 09:40:42
				--cnt=mlel+1
				additional_loot_count = m_level + 1;
				--if(m_level <= 0) then
					--additional_loot_count = 1;
				--elseif(m_level <= 3) then
					--additional_loot_count = 2;
				--elseif(m_level <= 6) then
					--additional_loot_count = 3;
				--elseif(m_level <= 9) then
					--additional_loot_count = 4;
				--elseif(m_level <= 10) then
					--additional_loot_count = 5;
				--elseif(m_level > 10) then
					--additional_loot_count = 5;
				--end
			end
			if(player and player:IsCombatActive() and player:IsAlive()) then
				local followpet_guid = player.current_followpet_guid;
				-- check if follow pet is dead
				local bFollowPetMinionDead = false;
				if(type(each_nid) == "number") then
					local player_followpet = Player.GetPlayerCombatObj(-each_nid);
					if(player_followpet and player_followpet.arena_id and player_followpet.arena_id == player.arena_id) then
						if(player_followpet:IsCombatActive() and not player_followpet:IsAlive()) then
							bFollowPetMinionDead = true;
						end
					end
				end
				if(not bFollowPetMinionDead) then
					pet_exp = Arena.AddExpForPlayerFollowPet(each_nid, followpet_guid, gained_exp);
				else
					-- 0 pet exp for dead follow pet minion
					pet_exp = 0;
				end
				-- alive player
				combat_server.AppendRealTimeMessageToNID(self.combat_server_uid, each_nid, "GainExp:"..rewards_str);
				combat_server.AppendRealTimeMessage(self.combat_server_uid, "CombatResult:"..each_player_result_str.."~"..pet_exp.."~"..player.loot_scale);
				if(self.is_last_arena_in_instance) then
					combat_server.AppendRealTimeMessageToNID(self.combat_server_uid, each_nid, "DefeatLastArenaInInstance:1");
				end
				-- play motion id for winners
				if(self.end_motion_id) then
					PlayMotion_str = self.position.x..","..self.position.y..","..self.position.z;
					PlayMotion_str = PlayMotion_str..","..self.end_motion_id;
					PlayMotion_str = PlayMotion_str..","..tostring(self.world_config_file)..","..self:GetDifficulty();
					if(self.stamina_cost) then
						PlayMotion_str = PlayMotion_str..","..self.stamina_cost;
					else
						PlayMotion_str = PlayMotion_str..",0";
					end
				end
				-- mark last gained reward nids and counts
				if(stamina_costs[each_nid]) then
					self.last_gained_reward_nids_and_counts[each_nid] = additional_loot_count;
				end
				-- handle pvp win in quest logics
				if(self.world_config_file == "config/Aries/WorldData_Teen/HaqiTown_RedMushroomArena_AI_1v1.Arenas_Mobs.xml") then
					-- we use entercombat_cost as an identifier of RedMushroom arena
					--Leio(疯狂石头蛋) 10:33:57
					--打机器人 你调的是这个函数 
					--如果胜利 就把is_win=true 传过来就可以了
					--王田(Andy) 10:34:04
					--我加个true
					--Leio(疯狂石头蛋) 10:34:12
					--嗯
					QuestServerLogics.PvP_Successful_Handler_By_Worldname(each_nid, "HaqiTown_RedMushroomArena", true);
				end
				-- process reward
				process_reward = true;
				process_durability_isdead = false;
			elseif(player and player:IsCombatActive() and not player:IsAlive()) then
				-- dead player
				if(not isAllPlayerDead) then
					local followpet_guid = player.current_followpet_guid;
					-- check if follow pet is dead
					local bFollowPetMinionDead = false;
					if(type(each_nid) == "number") then
						local player_followpet = Player.GetPlayerCombatObj(-each_nid);
						if(player_followpet and player_followpet.arena_id and player_followpet.arena_id == player.arena_id) then
							if(player_followpet:IsCombatActive() and not player_followpet:IsAlive()) then
								bFollowPetMinionDead = true;
							end
						end
					end
					if(not bFollowPetMinionDead) then
						pet_exp = Arena.AddExpForPlayerFollowPet(each_nid, followpet_guid, gained_exp);
					else
						-- 0 pet exp for dead follow pet minion
						pet_exp = 0;
					end
					if(self.isinstance) then
						combat_server.AppendRealTimeMessageToNID(self.combat_server_uid, each_nid, "GainExpButDefeatedInInstance:"..rewards_str);
						if(self.is_last_arena_in_instance) then
							combat_server.AppendRealTimeMessageToNID(self.combat_server_uid, each_nid, "DefeatLastArenaInInstance:1");
						end
					else
						combat_server.AppendRealTimeMessageToNID(self.combat_server_uid, each_nid, "GainExpButDefeated:"..rewards_str);
					end
					combat_server.AppendRealTimeMessage(self.combat_server_uid, "CombatResult:"..each_player_result_str.."~"..pet_exp.."~"..player.loot_scale);
					-- play motion id for dead winners
					if(self.end_motion_id) then
						PlayMotion_str = self.position.x..","..self.position.y..","..self.position.z;
						PlayMotion_str = PlayMotion_str..","..self.end_motion_id;
						PlayMotion_str = PlayMotion_str..","..tostring(self.world_config_file)..","..self:GetDifficulty();
						if(self.stamina_cost) then
							PlayMotion_str = PlayMotion_str..","..self.stamina_cost;
						else
							PlayMotion_str = PlayMotion_str..",0";
						end
					end
					-- mark last gained reward nids and counts
					if(stamina_costs[each_nid]) then
						self.last_gained_reward_nids_and_counts[each_nid] = additional_loot_count;
					end
					-- process reward
					process_reward = true;
				else
					combat_server.AppendRealTimeMessageToNID(self.combat_server_uid, each_nid, "Defeated:1");
				end
				process_durability_isdead = true;
			end
			-- process durability
			local durable_items = player.current_combat_durable_items;
			if(durable_items) then
				if(process_durability_isdead == true) then
					-- only cost durability on player dead
					local self_combat_server_uid = self.combat_server_uid;
					PowerItemManager.CostDurablity(each_nid, durable_items, process_durability_isdead, function()
						combat_server.AppendRealTimeMessageToNID(self_combat_server_uid, each_nid, "UpdateEquipBags:1");
					end);
				end
			end
			
			-- process reward with joybean exp_pts and loots
			if(process_reward) then
				local loots = {};
				local gsid, count;
				for gsid, count in string.gmatch(gained_loot, "(%d+)#(%d+)##") do
					gsid = tonumber(gsid);
					count = tonumber(count);
					if(gsid) then
						loots[gsid] = loots[gsid] or 0;
						loots[gsid] = loots[gsid] + count;
					end
				end

				if(self.match_items) then
					local _, t;
					for _, t in pairs(self.match_items) do
						local gsid = t.gsid;
						local count = t.count;
						local appended_count_postlog = 0;
						local gsItem = PowerItemManager.GetGlobalStoreItemInMemory(gsid);
						if(gsItem) then
							local bagfamily = gsItem.template.bagfamily;
							local bHas, guid, bag, copies = PowerItemManager.IfOwnGSItem(each_nid, gsid, bagfamily);
							if(bHas == true) then
								if(count > copies) then
									loots[gsid] = loots[gsid] or 0;
									loots[gsid] = loots[gsid] + (count - copies);
									appended_count_postlog = count - copies;
								end
							elseif(bHas == false) then
								loots[gsid] = loots[gsid] or 0;
								loots[gsid] = loots[gsid] + count;
								appended_count_postlog = count;
							end
						end
						-- post log match_item record
						combat_server.AppendPostLog( {
							action = "arena_match_items", 
							gsid = gsid,
							count = count, 
							appended_count_postlog = appended_count_postlog,
							nid = each_nid,
						});
					end
				end
				-- exp, joybean and item loots
				PowerItemManager.AddExpJoybeanLoots(each_nid, gained_exp, gained_joybean, loots, function(msg)
					
					if(self.world_config_file == "config/Aries/WorldData_Teen/HaqiTown_RedMushroomArena_AI_1v1.Arenas_Mobs.xml") then
						if(player) then
							player:SubmitScore("1v1");
						end
					end

					local obtains = {};
					
					Arena.GetObtainsFromMSG(msg, each_nid, obtains);

					obtains[0] = nil;
					
					local real_gained_loot = "";
					local gsid, cnt;
					for gsid, cnt in pairs(obtains) do
						real_gained_loot = real_gained_loot..gsid..","..cnt.."+";
					end

					local full_loot_str = string.format("%s~%s~%s~%d~%d~%f~%d~%d~%s~%s~%d", 
						tostring(self:GetID()), self.mode, tostring(each_nid), gained_exp, original_exp, 1 + exp_scale_acc, pet_exp, gained_joybean, "nil", real_gained_loot, player.loot_scale);

					combat_server.AppendRealTimeMessageToNID(self.combat_server_uid, each_nid, "MyGainedLoots:"..full_loot_str);
					combat_server.AppendRealTimeMessage(self.combat_server_uid, "BuddyGainedLoots:"..full_loot_str);
					
					if(PlayMotion_str) then
						if(System.options.version == "kids") then
							combat_server.AppendRealTimeMessageToNID(self.combat_server_uid, each_nid, "PlayMotion:"..PlayMotion_str.."[]");
						else
							if(self.last_gained_reward_nids_and_counts[each_nid]) then
								combat_server.AppendRealTimeMessageToNID(self.combat_server_uid, each_nid, "PlayMotion:"..PlayMotion_str.."["..full_loot_str.."]");
							else
								combat_server.AppendRealTimeMessageToNID(self.combat_server_uid, each_nid, "PlayMotion:"..PlayMotion_str.."[]");
							end
						end
					end
				end);
				-- loots for quest server logics
				QuestServerLogics.DoAddValue_ByLoots(each_nid, loots);
				-- exp buff scale items destroy
				if(tobe_destroyed_buff_guids) then
					local self_combat_server_uid = self.combat_server_uid;
					PowerItemManager.DestroyItemBatch(each_nid, tobe_destroyed_buff_guids, function(msg)
						combat_server.AppendRealTimeMessageToNID(self_combat_server_uid, each_nid, "UpdateExpBuffArea:1");
					end);
				end
				-- NOTE: for leio
				-- this is the mobs beaten by user after each combat 
				-- each_nid, gained_lootable_mobs_quest_keystruct
				-- {[key] = count, [key] = count}
				-- quest kill message handler
				QuestServerLogics.Kill_Handler(each_nid, gained_lootable_mobs_quest_keystruct, self:GetDifficulty());
				-- insert into the available loots
				if(self.treasurebox) then
					self.treasurebox.lootable_nids[each_nid] = true;
					combat_server.AppendRealTimeMessageToNID(self.combat_server_uid, each_nid, "TreasureBoxResponse_CanOpenTreasureBox:1");
				end
				-- cost stamina
				if(stamina_costs[each_nid]) then
					PowerItemManager.CostStamina(each_nid, stamina_costs[each_nid], function(msg) end);
				end
			end
		end
	end

	-- destory all players
	local i;
	for i = 1, max_player_count_per_arena do
		local nid = self.player_nids[i];
		if(nid) then
			-- destroy player
			Player.DestroyPlayer(nid);
		end
	end
	-- clear player nids
	self.player_nids = {};
	-- append to the normal update queue
	self:UpdateToClient();
	
	self:DebugDumpData("------------------ end FinishCombat ------------------");
end

-- finish the combat
function Arena:FinishCombat_v()
	self:DebugDumpData("------------------ begin FinishCombat_v ------------------");
	
	self:CalculateWinningAndLosingRankingPoint();

	local winning_side = nil;
	local winning_weight = 0;
	-- calculate avarage arena player level
	local near_arena_level_sum = 0;
	local far_arena_level_sum = 0;
	local near_arena_level_count = 0;
	local far_arena_level_count = 0;
	local avg_near_arena_level = 0;
	local avg_far_arena_level = 0;
	local max_near_arena_level = 0;
	local max_far_arena_level = 0;
	local i;
	for i = 1, max_unit_count_per_side_arena do
		-- near side units
		local nid = self.player_nids[i];
		if(nid) then
			local player_object = Player.GetPlayerCombatObj(nid);
			if(player_object) then
				local level = player_object:GetPetLevel();
				if(level) then
					near_arena_level_sum = near_arena_level_sum + level;
					near_arena_level_count = near_arena_level_count + 1;
					if(level > max_near_arena_level) then
						max_near_arena_level = level;
					end
				end
			end
			if(player_object and player_object:IsCombatActive() and player_object:IsAlive()) then
				winning_side = player_object:GetSide();
				winning_weight = winning_weight + math.ceil((10 + player_object:GetCurrentHP() / player_object:GetMaxHP()) * 1000);
			end
		--else
			--local level = self.fled_slots_level[i];
			--if(level) then
				--near_arena_level_sum = near_arena_level_sum + level;
				--near_arena_level_count = near_arena_level_count + 1;
				--if(level > max_near_arena_level) then
					--max_near_arena_level = level;
				--end
			--end
		end
	end
	for i = max_unit_count_per_side_arena + 1, max_unit_count_per_side_arena * 2 do
		-- far side units
		local nid = self.player_nids[i];
		if(nid) then
			local player_object = Player.GetPlayerCombatObj(nid);
			if(player_object) then
				local level = player_object:GetPetLevel();
				if(level) then
					far_arena_level_sum = far_arena_level_sum + level;
					far_arena_level_count = far_arena_level_count + 1;
					if(level > max_far_arena_level) then
						max_far_arena_level = level;
					end
				end
			end
			if(player_object and player_object:IsCombatActive() and player_object:IsAlive()) then
				if(winning_side and winning_side ~= player_object:GetSide()) then
					winning_weight = winning_weight - math.ceil((10 + player_object:GetCurrentHP() / player_object:GetMaxHP()) * 1000);
					if(winning_weight < 0) then
						winning_side = player_object:GetSide();
					elseif(winning_weight == 0) then
						if(self.isNearArenaFirst == true) then
							winning_side = "far";
						else
							winning_side = "near";
						end
						if(System.options.version == "kids") then
							winning_side = "draw";
						end
					end
				else
					winning_side = player_object:GetSide();
				end
			end
		--else
			--local level = self.fled_slots_level[i];
			--if(level) then
				--far_arena_level_sum = far_arena_level_sum + level;
				--far_arena_level_count = far_arena_level_count + 1;
				--if(level > max_far_arena_level) then
					--max_far_arena_level = level;
				--end
			--end
		end
	end
	if(near_arena_level_count > 0) then
		avg_near_arena_level = near_arena_level_sum / near_arena_level_count;
	end
	if(far_arena_level_count > 0) then
		avg_far_arena_level = far_arena_level_sum / far_arena_level_count;
	end
	
	local least_card_number_for_award = self.least_card_number_for_award;
	local least_round_number_for_award = self.least_round_number_for_award;

	local spendRounds;
	if(self.nRemainingRounds and self.nRemainingRounds > 0) then
		if(self.is_battlefield) then
			spendRounds = math.floor((MAX_ROUNDS_PVP_ARENA_BATTLEFIELD - self.nRemainingRounds) / 2);
		else
			spendRounds = math.floor((MAX_ROUNDS_PVP_ARENA - self.nRemainingRounds) / 2);
		end
	else
		spendRounds = 0;
	end
	

	-- destory all players
	local i;
	for i = 1, max_unit_count_per_side_arena * 2 do
		local nid = self.player_nids[i];
		if(nid) then
			local player_object = Player.GetPlayerCombatObj(nid);
			if(player_object) then
				if(player_object:IsCombatActive()) then
					local gained_exp = 0;
					local original_exp = 0;
					local pet_exp = 0;
					local loots = nil;
					local loots_str = "";
					local used_card_count = 0;
					local history = player_object:GetCardHistory();
					if(history) then
						local _, played_card;
						for _, played_card in pairs(history) do
							used_card_count = used_card_count + 1;
						end
					end


					local player_is_winner = false;
					--local BeAwarded = if_else(used_card_count >= least_card_number_for_award, true, false);
					if(used_card_count < least_card_number_for_award and spendRounds < least_round_number_for_award) then
						BeAwarded = false;
					else
						BeAwarded = true;
					end

					if(System.options.version == "teen") then
						BeAwarded = true;
					end
					-- exp scale
					local exp_scale_acc = PowerItemManager.GetExpScaleAcc(nid);
					local exp_scale_acc_buff;
					local tobe_destroyed_buff_guids;
					if(winning_side == "draw" and System.options.version == "kids") then
						-- draw game
						gained_exp = 0;
						-- ranking stage post log
						combat_server.AppendPostLog( {
							action = "pvp_arena_draw_game_log", 
							nid = nid,
							reason = "draw_game",
						});

						if(self.ranking_stage) then
							combat_server.AppendPostLog( {
								action = "pvp_arena_ranking_point_log", 
								gsid = 0, 
								count = 0,
								nid = nid,
								reason = "draw_game",
								nRemainingRounds = self.nRemainingRounds,
								ranking_stage = self.ranking_stage,
								ranking_info = self.RankingInfo_str,
								isNearArenaFirst = tostring(self.isNearArenaFirst),
							});
							-- send pvp ranking point info to lobby
							Map3DSystem.GSL.system:SendToLobbyServer({
								type = "pvp_arena_ranking_point_change",
								user_nid = 0,
								msg = {
									gsid = 0, 
									count = 0,
									nid = nid,
									reason = "draw_game",
								},
							});
						end

						pet_exp = 0;
						original_exp = 0;
						combat_server.AppendRealTimeMessageToNID(self.combat_server_uid, nid, "DrawGame_pvp:"..self:GetID());
						if(BeAwarded) then
							combat_server.AppendRealTimeMessage(self.combat_server_uid, "CombatResult_pvp:"..nid.."~"..gained_exp.."~"..original_exp.."~"..(1 + exp_scale_acc).."~"..loots_str.."~"..pet_exp.."~draw~"..player_object.loot_scale);
						end
					elseif(winning_side == player_object:GetSide()) then -- if(player_object:IsAlive()) then
						player_is_winner = true;
						local side = player_object:GetSide();
						-- bonus hostile combat level exp
						if(side == "far") then
							gained_exp = math_floor(used_card_count / (used_card_count + 10) * ((max_near_arena_level - player_object:GetPetLevel()) / 100 + 1) * (10 + player_object:GetPetLevel()) * 20);
						elseif(side == "near") then
							gained_exp = math_floor(used_card_count / (used_card_count + 10) * ((max_far_arena_level - player_object:GetPetLevel()) / 100 + 1) * (10 + player_object:GetPetLevel()) * 20);
						end
						if(self.exp_formula == "TrialOfChampions") then
							if(side == "far") then
								gained_exp = math_floor(used_card_count / (used_card_count + 10) * ((max_near_arena_level - player_object:GetPetLevel()) / 100 + 1) * player_object:GetPetLevel() * 70);
							elseif(side == "near") then
								gained_exp = math_floor(used_card_count / (used_card_count + 10) * ((max_far_arena_level - player_object:GetPetLevel()) / 100 + 1) * player_object:GetPetLevel() * 70);
							end
						elseif(self.exp_formula == "TrialOfChampions_Teen") then
							if(side == "far") then
								gained_exp = math_floor(used_card_count / (used_card_count + 10) * ((max_near_arena_level - player_object:GetPetLevel()) / 100 + 1) * (10 + player_object:GetPetLevel()) * 10);
							elseif(side == "near") then
								gained_exp = math_floor(used_card_count / (used_card_count + 10) * ((max_far_arena_level - player_object:GetPetLevel()) / 100 + 1) * (10 + player_object:GetPetLevel()) * 10);
							end
						elseif(self.exp_formula == "Practice") then
							gained_exp = 0;
						end
						-- winner loots
						if(self.insurance_and_winner_loots) then
							local insurance_gsid = self.insurance_and_winner_loots.insurance_gsid;

							local has_insurance, guid_insurance = PowerItemManager.IfOwnGSItem(nid, insurance_gsid);
							if(has_insurance) then
								-- insurance loots
								loots = self.insurance_and_winner_loots.loots;
							else
								-- winner loots
								loots = self.winner_loots;
							end
						end
						if(self.prior_insurance_and_winner_loots) then
							local insurance_gsid = self.prior_insurance_and_winner_loots.insurance_gsid;

							local has_insurance, guid_insurance = PowerItemManager.IfOwnGSItem(nid, insurance_gsid);
							if(has_insurance) then
								-- prior insurance loots
								loots = self.prior_insurance_and_winner_loots.loots;
							end
						end
						if(self.prior_prior_insurance_and_winner_loots) then
							local insurance_gsid = self.prior_prior_insurance_and_winner_loots.insurance_gsid;

							local has_insurance, guid_insurance = PowerItemManager.IfOwnGSItem(nid, insurance_gsid);
							if(has_insurance) then
								-- prior prior insurance loots
								loots = self.prior_prior_insurance_and_winner_loots.loots;
							end
						end
						if(self.prior_prior_prior_insurance_and_winner_loots) then
							local insurance_gsid = self.prior_prior_prior_insurance_and_winner_loots.insurance_gsid;

							local has_insurance, guid_insurance = PowerItemManager.IfOwnGSItem(nid, insurance_gsid);
							if(has_insurance) then
								-- prior prior prior insurance loots
								loots = self.prior_prior_prior_insurance_and_winner_loots.loots;
							end
						end
						if(not loots) then
							-- winner loots
							loots = self.winner_loots;
						end
						
						-- ranking points
						if(self.ranking_stage) then
							
							-- a loots copy
							loots = commonlib.deepcopy(loots);

							if(player_object.win_ranking_point_gsid and player_object.win_ranking_point_count) then
								
								loots[player_object.win_ranking_point_gsid] = player_object:GetRankingLoot(true);

								if(player_object.win_ranking_additional_loots) then
									local gsid, count;
									for gsid, count in pairs(player_object.win_ranking_additional_loots) do
										loots[gsid] = count;
									end
								end
								
								-- ranking stage post log
								combat_server.AppendPostLog( {
									action = "pvp_arena_ranking_point_log", 
									gsid = player_object.win_ranking_point_gsid, 
									count = player_object.win_ranking_point_count,
									nid = nid,
									reason = "win",
									nRemainingRounds = self.nRemainingRounds,
									ranking_stage = self.ranking_stage,
									ranking_info = self.RankingInfo_str,
									isNearArenaFirst = tostring(self.isNearArenaFirst),
								});
								-- send pvp ranking point info to lobby
								Map3DSystem.GSL.system:SendToLobbyServer({
									type = "pvp_arena_ranking_point_change",
									user_nid = 0,
									msg = {
										gsid = player_object.win_ranking_point_gsid, 
										count = player_object.win_ranking_point_count,
										nid = nid,
										reason = "win",
									},
								});
							end
						end

						if(loots) then
							local gsid, count;
							for gsid, count in pairs(loots) do
								if(type(count) == "table") then
									count = count.count or 0;
								end
								local i;
								for i = 1, count do
									loots_str = loots_str..gsid.."#";
								end
							end
						end
						if((self.exp_formula ~= "TrialOfChampions" and self.exp_formula ~= "TrialOfChampions_Teen") and used_card_count < 3) then
							gained_exp = 0;
						end
						if(self.exp_formula == "Practice") then
							gained_exp = 0;
						end
						original_exp = gained_exp;
						-- loot scale
						original_exp = math.ceil(original_exp * player_object.loot_scale);
						-- apply buffed exp scale only when the original exp is positive
						if(gained_exp > 0) then
							exp_scale_acc_buff, tobe_destroyed_buff_guids = PowerItemManager.GetExpScaleAcc_buff(nid);
							exp_scale_acc = exp_scale_acc + exp_scale_acc_buff;
						end
						-- exp scale
						gained_exp = math.ceil(gained_exp * (1 + exp_scale_acc));
						-- pet exp
						pet_exp = 0;
						local followpet_guid = player_object.current_followpet_guid;
						-- check if follow pet is dead
						local bFollowPetMinionDead = false;
						if(type(nid) == "number") then
							local player_followpet = Player.GetPlayerCombatObj(-nid);
							if(player_followpet and player_followpet.arena_id and player_followpet.arena_id == player.arena_id) then
								if(player_followpet:IsCombatActive() and not player_followpet:IsAlive()) then
									bFollowPetMinionDead = true;
								end
							end
						end
						if(not bFollowPetMinionDead) then
							pet_exp = Arena.AddExpForPlayerFollowPet(nid, followpet_guid, gained_exp);
						else
							-- 0 pet exp for dead follow pet minion
							pet_exp = 0;
						end
						combat_server.AppendRealTimeMessageToNID(self.combat_server_uid, nid, "Winner_pvp:"..self:GetID());
						if(BeAwarded) then
							combat_server.AppendRealTimeMessage(self.combat_server_uid, "CombatResult_pvp:"..nid.."~"..gained_exp.."~"..original_exp.."~"..(1 + exp_scale_acc).."~"..loots_str.."~"..pet_exp.."~true~"..player_object.loot_scale);
						end
						-- handle pvp win in quest logics
						if(self.entercombat_cost == "RedMushroomArena" or self.entercombat_cost == "RedMushroomArena_NoTicket") then
							-- we use entercombat_cost as an identifier of RedMushroom arena
							QuestServerLogics.PvP_Successful_Handler_By_Worldname(nid, "HaqiTown_RedMushroomArena");
						elseif(self.entercombat_cost == "TrialOfChampions") then
							-- we use entercombat_cost as an identifier of TrialOfChampions arena
							QuestServerLogics.PvP_Successful_Handler_By_Worldname(nid, "HaqiTown_TrialOfChampions");
						elseif(self.resource_id) then
							-- we use resource_id as an identifier of battle field arenas
							QuestServerLogics.PvP_Successful_Handler_By_Worldname(nid, "BattleField_ChampionsValley");
						end
					else
						gained_exp = math_floor(used_card_count / (used_card_count + 10) * (10 + player_object:GetPetLevel()) * 8);
						if(self.exp_formula == "TrialOfChampions") then
							gained_exp = math_floor(used_card_count / (used_card_count + 10) * player_object:GetPetLevel() * 35);
						elseif(self.exp_formula == "TrialOfChampions_Teen") then
							gained_exp = math_floor(used_card_count / (used_card_count + 10) * (10 + player_object:GetPetLevel()) * 2);
						elseif(self.exp_formula == "Practice") then
							gained_exp = 0;
						end
						-- loser loots
						if(self.insurance_and_loser_loots) then
							local insurance_gsid = self.insurance_and_loser_loots.insurance_gsid;

							local has_insurance, guid_insurance = PowerItemManager.IfOwnGSItem(nid, insurance_gsid);
							if(has_insurance) then
								-- insurance loots
								loots = self.insurance_and_loser_loots.loots;
							else
								-- loser loots
								loots = self.loser_loots;
							end
						end
						if(self.prior_insurance_and_loser_loots) then
							local insurance_gsid = self.prior_insurance_and_loser_loots.insurance_gsid;

							local has_insurance, guid_insurance = PowerItemManager.IfOwnGSItem(nid, insurance_gsid);
							if(has_insurance) then
								-- prior insurance loots
								loots = self.prior_insurance_and_loser_loots.loots;
							end
						end
						if(self.prior_prior_insurance_and_loser_loots) then
							local insurance_gsid = self.prior_prior_insurance_and_loser_loots.insurance_gsid;

							local has_insurance, guid_insurance = PowerItemManager.IfOwnGSItem(nid, insurance_gsid);
							if(has_insurance) then
								-- prior prior insurance loots
								loots = self.prior_prior_insurance_and_loser_loots.loots;
							end
						end
						if(self.prior_prior_prior_insurance_and_loser_loots) then
							local insurance_gsid = self.prior_prior_prior_insurance_and_loser_loots.insurance_gsid;

							local has_insurance, guid_insurance = PowerItemManager.IfOwnGSItem(nid, insurance_gsid);
							if(has_insurance) then
								-- prior prior prior insurance loots
								loots = self.prior_prior_prior_insurance_and_loser_loots.loots;
							end
						end
						if(not loots) then
							-- loser loots
							loots = self.loser_loots;
						end

						-- ranking points
						if(self.ranking_stage) then
							
							-- a loots copy
							loots = commonlib.deepcopy(loots) or {};

							if(player_object.lose_ranking_point_gsid and player_object.lose_ranking_point_count) then
								loots[player_object.lose_ranking_point_gsid] = player_object:GetRankingLoot(false);
							end
							
							-- ranking stage post log
							combat_server.AppendPostLog( {
								action = "pvp_arena_ranking_point_log", 
								gsid = player_object.lose_ranking_point_gsid, 
								count = player_object.lose_ranking_point_count,
								nid = nid,
								reason = "loss",
								nRemainingRounds = self.nRemainingRounds,
								ranking_stage = self.ranking_stage,
								ranking_info = self.RankingInfo_str,
								isNearArenaFirst = tostring(self.isNearArenaFirst),
							});

							-- send pvp ranking point info to lobby
							Map3DSystem.GSL.system:SendToLobbyServer({
								type = "pvp_arena_ranking_point_change",
								user_nid = 0,
								msg = {
									gsid = player_object.lose_ranking_point_gsid, 
									count = player_object.lose_ranking_point_count,
									nid = nid,
									reason = "loss",
								},
							});
						end

						if(loots) then
							local gsid, count;
							for gsid, count in pairs(loots) do
								if(type(count) == "table") then
									count = count.count or 0;
								end
								if(count > 0) then
									local i;
									for i = 1, count do
										loots_str = loots_str..gsid.."#";
									end
								elseif(count < 0) then
									local i;
									for i = 1, -count do
										loots_str = loots_str.."-"..gsid.."#";
									end
								end
							end
						end

						if((self.exp_formula ~= "TrialOfChampions" and self.exp_formula ~= "TrialOfChampions_Teen") and used_card_count < 3) then
							gained_exp = 0;
						end
						if(self.exp_formula == "Practice") then
							gained_exp = 0;
						end
						original_exp = gained_exp;
						-- loot scale
						original_exp = math.ceil(original_exp * player_object.loot_scale);
						-- apply buffed exp scale only when the original exp is positive
						if(gained_exp > 0) then
							exp_scale_acc_buff, tobe_destroyed_buff_guids = PowerItemManager.GetExpScaleAcc_buff(nid);
							exp_scale_acc = exp_scale_acc + exp_scale_acc_buff;
						end
						-- exp scale
						gained_exp = math.ceil(gained_exp * (1 + exp_scale_acc));
						-- pet exp
						pet_exp = 0;
						local followpet_guid = player_object.current_followpet_guid;
						-- check if follow pet is dead
						local bFollowPetMinionDead = false;
						if(type(nid) == "number") then
							local player_followpet = Player.GetPlayerCombatObj(-nid);
							if(player_followpet and player_followpet.arena_id and player_followpet.arena_id == player.arena_id) then
								if(player_followpet:IsCombatActive() and not player_followpet:IsAlive()) then
									bFollowPetMinionDead = true;
								end
							end
						end
						if(not bFollowPetMinionDead) then
							pet_exp = Arena.AddExpForPlayerFollowPet(nid, followpet_guid, gained_exp);
						else
							-- 0 pet exp for dead follow pet minion
							pet_exp = 0;
						end
						combat_server.AppendRealTimeMessageToNID(self.combat_server_uid, nid, "Defeated_pvp:"..gained_exp);
						if(BeAwarded) then
							combat_server.AppendRealTimeMessage(self.combat_server_uid, "CombatResult_pvp:"..nid.."~"..gained_exp.."~"..original_exp.."~"..(1 + exp_scale_acc).."~"..loots_str.."~"..pet_exp.."~false~"..player_object.loot_scale);
						end
					end
					if(System.options.version == "kids") then
						if(self.ranking_stage) then
							if(string.match(self.ranking_stage,"1v1")) then
								if(not player_is_winner) then
									BeAwarded = true;
								end
							end
						else
							BeAwarded = true;
						end
					end
					

					-- exp gained
					if(gained_exp and BeAwarded) then
						-- combat loots
						PowerItemManager.AddExpJoybeanLoots(nid, gained_exp, nil, loots, function(msg) 
							if(self.ranking_stage) then
								player_object:SubmitScore(self.ranking_stage);
							end

							local obtains = {};
					
							Arena.GetObtainsFromMSG(msg, nid, obtains);

							obtains[0] = nil;
					
							local real_gained_loot = "";
							local gsid, cnt;
							for gsid, cnt in pairs(obtains) do
								real_gained_loot = real_gained_loot..gsid..","..cnt.."+";
							end

							local isWinner = "";
							if(winning_side == "draw" and System.options.version == "kids") then
								isWinner = "draw";
							elseif(winning_side == player_object:GetSide()) then
								isWinner = "true";
							else
								isWinner = "false";
							end
							
							local full_loot_str = string.format("%s~%s~%s~%d~%d~%f~%d~%d~%s~%s~%d", 
								tostring(self:GetID()), self.mode, tostring(nid), gained_exp, original_exp, 1 + exp_scale_acc, pet_exp, 0, isWinner, real_gained_loot, player_object.loot_scale);

							combat_server.AppendRealTimeMessageToNID(self.combat_server_uid, nid, "MyGainedLoots:"..full_loot_str);
							combat_server.AppendRealTimeMessage(self.combat_server_uid, "BuddyGainedLoots:"..full_loot_str);
						end);
						-- loots for quest server logics
						QuestServerLogics.DoAddValue_ByLoots(nid, loots);
						-- exp buff scale items destroy
						if(tobe_destroyed_buff_guids) then
							local self_combat_server_uid = self.combat_server_uid;
							PowerItemManager.DestroyItemBatch(nid, tobe_destroyed_buff_guids, function(msg)
								combat_server.AppendRealTimeMessageToNID(self_combat_server_uid, nid, "UpdateExpBuffArea:1");
							end);
						end
					elseif(not BeAwarded) then
						combat_server.AppendRealTimeMessageToNID(self.combat_server_uid, nid, "NotUseEnoughCardAndRound:"..tostring(least_card_number_for_award).."%"..tostring(least_round_number_for_award));
					end
				else
					combat_server.AppendRealTimeMessageToNID(self.combat_server_uid, nid, "InActivePlayer_pvp:");
				end
			end
			-- destroy player
			Player.DestroyPlayer(nid);
		end
	end
	-- clear player nids
	self.player_nids = {};
	-- reset pvp arena
	self:Reset_pvp();
	-- if single fight pvp arena mark the arena with no further entry
	if(self.is_single_fight) then
		self:LockArenaEntrance();
		-- prevent user to join an expired gridnode in trial of champions instance
		if(self.gridnode) then
			self.gridnode.is_started = true;
		end
	end
	-- append to the normal update queue
	self:UpdateToClient();
	
	self:DebugDumpData("------------------ end FinishCombat_v ------------------");
end

-- add exp handler for player follow pet
-- @return pet_exp
function Arena.AddExpForPlayerFollowPet(nid, followpet_guid, gained_exp)
	if(nid and gained_exp) then
		if(System.options.version == "teen") then
			-- NOTE: teen version is follow pet independent
			local follow_pet_gained_exp = QuestServerLogics.AddExpToFollowPet(nid, gained_exp);
			return follow_pet_gained_exp or 0;
		else
			if(followpet_guid and followpet_guid > 0) then
				local pet_obj = PowerItemManager.GetItemByGUID(nid, followpet_guid);
				if(pet_obj and pet_obj.guid > 0 and pet_obj.OnCombatComplete_server) then
					-- NOTE: for leio
					-- this is the user gain exp and invoke the follow pet combat finish handler
					return pet_obj:OnCombatComplete_server(gained_exp) or 0;
				end
			end
			return 0;
		end
	end
	return gained_exp or 0;
end

-- lock arena enter combat entrance
function Arena:LockArenaEntrance()
	self.islocked_entrance = true;
end

-- unlock arena enter combat entrance
function Arena:UnLockArenaEntrance()
	self.islocked_entrance = false;
end

function Arena.GetUserSide(arena, nid)
	if(arena and arena.gridnode and arena.resource_id) then
		local battle_server = arena.gridnode:GetServerObject("battle");
		if(battle_server and battle_server.battle_field) then
			local bf = battle_server.battle_field;
			-- get player side
			return bf:get_player_side(nid);
		end
	end

	--- NOTE: some test codes
	--if(math.mod(nid, 2) == 0) then
		--return 0;
	--end
	--return 1;
end

function Arena.Attack(arena, nid, value, postpone_time, caster_nid ,can_get_fighting_spirit_value)
	if(arena and arena.gridnode and arena.resource_id) then
		local battle_server = arena.gridnode:GetServerObject("battle");
		if(battle_server and battle_server.battle_field) then
			local bf = battle_server.battle_field;
			-- adding score
			-- LOG.std(nil, "debug", "arena", "=====battle attack ===== arena id%d nid(%d) value(%d) posttime:%d r_id:%d", arena:GetID(), nid, value, postpone_time or 0, arena.resource_id)
			-- please node nid is the player that is taking the attack, not casting the attack. so we use add_attack instead of add_score
			bf:add_attack(nid, nil, value, postpone_time, arena ,caster_nid, can_get_fighting_spirit_value);
		end
	end
end

function Arena.OnBattleField_ReceiveHeal(arena, nid, value, postpone_time, caster_nid, can_get_fighting_spirit_value)
	if(arena and arena.gridnode and arena.resource_id) then
		local battle_server = arena.gridnode:GetServerObject("battle");
		if(battle_server and battle_server.battle_field) then
			local bf = battle_server.battle_field;
			-- adding score
			-- LOG.std(nil, "debug", "arena", "=====battle attack ===== arena id%d nid(%d) value(%d) posttime:%d r_id:%d", arena:GetID(), nid, value, postpone_time or 0, arena.resource_id)
			-- please node nid is the player that is taking the attack, not casting the attack. so we use add_attack instead of add_score
			bf:add_heal(nid, nil, value, postpone_time, arena, caster_nid, can_get_fighting_spirit_value);
		end
	end
end

function Arena.OnBattleField_Death(arena, nid, postpone_time)
	if(arena and arena.gridnode and arena.resource_id) then
		local battle_server = arena.gridnode:GetServerObject("battle");
		if(battle_server and battle_server.battle_field) then
			local bf = battle_server.battle_field;
			-- adding score
			-- LOG.std(nil, "debug", "arena", "=====battle attack ===== arena id%d nid(%d) value(%d) posttime:%d r_id:%d", arena:GetID(), nid, value, postpone_time or 0, arena.resource_id)
			-- please node nid is the player that is taking the attack, not casting the attack. so we use add_attack instead of add_score
			bf:add_death(nid, nil, nil, postpone_time, arena);
		end
	end
end

function Arena.UpdateResourcePoint(arena, near_count, far_count)
	if(arena and arena.gridnode and arena.resource_id) then
		local battle_server = arena.gridnode:GetServerObject("battle");
		if(battle_server and battle_server.battle_field) then
			local bf = battle_server.battle_field;
			-- set balance number on 1-5 resource point
			local rp = bf:get_resource_point(arena.resource_id);
			if(rp) then
				-- LOG.std(nil, "debug", "arena", "=====battle update resource point===== arena id%d (%d:%d) r_id:%d", arena:GetID(), near_count, far_count, arena.resource_id)
				rp:set_balance_num(far_count - near_count); -- far side is side1, near side is side0
			end
		end
	end
end

-- 多彩宝石和防御宝石互斥
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
--
-- filter invalid gems
-- @params: item socketed gems
-- @return: filtered gems
function Arena.FilterInvalidGems(gems)
	local bWithMetaResist = false;
	local filtered_gems = {};
	if(System.options.version == "teen") then
		if(gems) then
			local _, gsid;
			for _, gsid in pairs(gems) do
				local gsItem = PowerItemManager.GetGlobalStoreItemInMemory(gsid);
				if(gsItem) then
					local stat_42 = gsItem.template.stats[42];
					if(stat_42 == 21) then
						bWithMetaResist = true;
						break;
					end
				end
			end
		end
	end
	if(gems) then
		local _, gsid;
		for _, gsid in pairs(gems) do
			local bValidGem = true;
			if(bWithMetaResist) then
				local gsItem = PowerItemManager.GetGlobalStoreItemInMemory(gsid);
				if(gsItem) then
					local stat_42 = gsItem.template.stats[42];
					if(stat_42 == 11 or stat_42 == 12 or stat_42 == 13 or stat_42 == 14 or stat_42 == 15) then
						bValidGem = false;
					end
				end
			end
			if(bValidGem) then
				table.insert(filtered_gems, gsid);
			end
		end
	end
	return filtered_gems;
end

-- try enter combat
-- @param nid: player nid
-- @param arena_id: arena id
-- @param current_hp: current health point
-- @param max_hp: max health point
-- @param phase: user phase
-- @param deck_gsid: deck gsid
-- @param deck_cards: deck cards, format: spell,cnt+spell,cnt+spell,cnt
function Arena.OnReponse_TryEnterCombat(nid, arena_id, side, petlevel, current_hp, max_hp, phase, deck_gsid, followpet_guid, itemset_id, loot_scale, leadernid, isoverweight, is_follow_pet_joincombat, dragon_totem_str, deck_cards, equip_cards, deck_cards_rune, deck_cards_pet, equipped_items, equipped_gems)
	if(not nid or not arena_id) then
		log("error: nil nid or nil arena_id got in function Arena.OnReponse_TryEnterCombat\n");
		return;
	end
	if(not current_hp or current_hp <= 0) then
		log("error: nil current_hp or negative current_hp got in function Arena.OnReponse_TryEnterCombat\n");
		return;
	end
	if(not deck_gsid) then
		log("error: nil deck_gsid got in function Arena.OnReponse_TryEnterCombat\n");
		return;
	end
	if(side ~= "near" and side ~= "far") then
		log("error: invalid side got in function Arena.OnReponse_TryEnterCombat\n");
		return;
	end

	if(System.options.version ~= "teen") then
		is_follow_pet_joincombat = false;
	end

	local arena = Arena.GetArenaByID(arena_id);
	if(arena and arena.gridnode) then
		-- added by LiXizhi: 2013.6.2. Double check ticket when enter arena
		if(not arena.gridnode:UserHasTicket(nid)) then
			-- if arena is locked for player entrance
			combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "EntranceLocked:");
			return;
		end
	end

	local function ProcEnterCombat(bCombatItemsSynced)
		-- start entercombat
		local arena = Arena.GetArenaByID(arena_id);
		if(not arena) then
			log("error: nil arena:"..tostring(arena_id).." got in function Arena.OnReponse_TryEnterCombat\n");
			return;
		end
		
		arena:DebugDumpData("------------------ begin TryEnterCombat ------------------ "..tostring(nid).." "..tostring(arena_id));
		LOG.std(nil, "user", "arena", "arena_id=%d|TryEnterCombat %s", arena_id, tostring(nid));

		if(arena.islocked_entrance) then
			-- if arena is locked for player entrance
			combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "EntranceLocked:");
			return;
		end
	
		local player_object = Player.GetPlayerCombatObj(nid);
		if(player_object) then
			-- TODO: this is bug that a play object is not deleted from the player object list but removed from the arena player list
			-- we double check the player validity and remove the unwanted player object
			local player_arena_id = player_object.arena_id;
			if(player_arena_id) then
				local player_arena = Arena.GetArenaByID(player_arena_id)
				if(player_arena) then
					if(not player_arena:IsPlayerInArena(nid)) then
						log("error: destroy unwanted player object "..nid..", due to invalid player object in Arena.OnReponse_TryEnterCombat() r1\n");
						-- player_object is invalid
						Player.DestroyPlayer(nid);
					else
						if(player_arena_id ~= arena_id) then
							if(player_arena.mode ~= "free_pvp") then
								Arena.OnReponse_TryFleeCombat(nid, true); -- true for bSkipMessage
							end
						end
						-- if player_object is alreay exist, the player is already joined a fight in an arena
						combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "YouAreAlreadyInCombat:");
						return;
					end
				else
					log("error: destroy unwanted player object"..nid..", due to invalid player object in Arena.OnReponse_TryEnterCombat() r2\n");
					-- player_object is invalid
					Player.DestroyPlayer(nid);
				end
			else
				log("error: destroy unwanted player object"..nid..", due to invalid player object in Arena.OnReponse_TryEnterCombat() r3\n");
				-- player_object is invalid
				Player.DestroyPlayer(nid);
			end
		end
	
		--if(arena.mode == "free_pvp") then
			--if(arena.is_cost_pvp_ticket) then
				---- 12003_FreePvPTicket
				---- 12004_ForSalePvPTicket
				--local has_12003 = PowerItemManager.IfOwnGSItem(nid, 12003);
				--local has_12004 = PowerItemManager.IfOwnGSItem(nid, 12004);
				--if(not has_12003 and not has_12004) then
					---- if player doesn't have tickets
					--combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "NoTicket:");
					--return;
				--end
			--end
		--end

		--commonlib.echo({nid, arena_id, petlevel, current_hp, max_hp, phase})
		if(arena.mode == "pve") then
			-- check if each mob is alive
			local isAllMobDead = true;
			local index, id;
			for index, id in ipairs(arena.mob_ids) do
				local mob = Mob.GetMobByID(id);
				if(mob and mob:IsAlive()) then
					isAllMobDead = false;
					break;
				end
			end
			if(isAllMobDead) then
				-- all mob are dead
				combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "AllMobsDead:");
				return;
			end

			-- check for team leader id for non-instance pve arena
			if(not arena.isinstance and arena.locked_for_teamleaderid and arena.locked_for_teamleaderid > 0 and leadernid ~= arena.locked_for_teamleaderid) then
				-- if arena is locked for player entrance
				combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "EntranceLockedForOtherTeam:");
				return;
			end
		
			if(arena.stamina_cost) then
				if(arena:GetDifficulty() ~= "easy") then
					local userdragoninfo = PowerItemManager.GetUserAndDragonInfoInMemory(nid);
					if(userdragoninfo and userdragoninfo.dragon.stamina) then
						if(userdragoninfo.dragon.stamina <= 0) then
							combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "InsufficientStamina:");
						end
					end
				end
			end
		end
		-- parse deck cards for user nid
		local deck_cards_all = {};
		local pair_card;
		for pair_card in string.gmatch(deck_cards, "[^%+]+") do
			local key, cnt = string.match(pair_card, "^(.+),(%d+)$");
			if(key and cnt) then
				cnt = tonumber(cnt);
				if(not deck_cards_all[key]) then
					deck_cards_all[key] = cnt;
				else
					deck_cards_all[key] = deck_cards_all[key] + cnt;
				end
			end
		end
		-- parse equip cards for user nid
		local equip_cards_all = {};
		local pair_card;
		for pair_card in string.gmatch(equip_cards, "[^%+]+") do
			local key, cnt = string.match(pair_card, "^(.+),(%d+)$");
			if(key and cnt) then
				cnt = tonumber(cnt);
				if(not equip_cards_all[key]) then
					equip_cards_all[key] = cnt;
				else
					equip_cards_all[key] = equip_cards_all[key] + cnt;
				end
			end
		end
		-- parse rune cards for user nid
		-- from 2015.3.18 we allow use all rune in combat     2015.3.18   lipeng
		--local deck_cards_rune_all = {};
		--local rune_count = 0;
		local pair_card;
		--echo("deck_cards_rune");
		--echo(deck_cards_rune);
		--for key in string.gmatch(deck_cards_rune, "[^%+]+") do
			--rune_count = rune_count + 1;
			--if(rune_count <= MAX_RUNE_COUNT) then
				--deck_cards_rune_all[key] = true;
			--end
		--end
		-- get follow pet cards for user nid
		local followpet_history = {};
		---- NOTE: pet is not successfully obtained  occasionally, use client cards parsing instead
		--local deck_cards_pet_all = {};
		--local pet_obj = PowerItemManager.GetItemByGUID(nid, followpet_guid);
		--if(pet_obj and pet_obj.guid > 0 and pet_obj.GetCurLevelCards) then
			--followpet_history[pet_obj.gsid] = true;
			--local cards = pet_obj:GetCurLevelCards(true);
			--if(cards) then
				--local _, gsid
				--for _, gsid in pairs(cards) do
					--local key = Card.Get_cardkey_from_gsid(gsid);
					--deck_cards_pet_all[key] = (deck_cards_pet_all[key] or 0) + 1;
				--end
			--end
		--end
		-- parse deck follow pet cards for user nid
		local deck_cards_pet_all = {};
		local pair_card;
		followpet_history[followpet_guid] = true;
		for pair_card in string.gmatch(deck_cards_pet, "[^%+]+") do
			local key, cnt = string.match(pair_card, "^(.+),(%d+)$");
			if(key and cnt) then
				cnt = tonumber(cnt);
				if(not deck_cards_pet_all[key]) then
					deck_cards_pet_all[key] = cnt;
				else
					deck_cards_pet_all[key] = deck_cards_pet_all[key] + cnt;
				end
			end
		end
		
		-- parse equipped gems for user nid
		local equipped_gems_all = {};
		if(not bCombatItemsSynced) then
			-- use user provided gems for gems that is not synced before combat
			local gsid;
			for gsid in string.gmatch(equipped_gems, "[^,]+") do
				gsid = string.match(gsid, "^(%d+)$");
				if(gsid) then
					gsid = tonumber(gsid);
					table.insert(equipped_gems_all, gsid);
				end
			end
		end

		-- addon level damage
		local addonlevel_damage_percent = 0;
		local addonlevel_damage_absolute = 0;
		local addonlevel_resist_absolute = 0;
		local addonlevel_hp_absolute = 0;
		local addonlevel_criticalstrike_percent = 0;
		local addonlevel_resilience_percent = 0;
		-- parse equipped items for user nid
		local equipped_items_all = {};
		local equipped_items_positions = {};
		local equipped_items_gsids_checked = {};
		-- dragon totem
		local dragon_totem_profession_gsid = 0;
		local dragon_totem_exp_gsid = 0;
		local dragon_totem_exp_cnt = 0;
		-- user team aura
		local user_team_aura = nil;
		if(bCombatItemsSynced) then
			-- re-generate the equip cards
			equip_cards_all = {};
		end
		local gsid;
		if(nid == "localuser") then
			-- skip all equipment validation for local haqi users. 
			equipped_items = ""
			local localuser = MyCompany.Aries.Combat.localuser
			addonlevel_damage_percent = localuser.addonlevel_damage_percent or 0;
			addonlevel_damage_absolute = localuser.addonlevel_damage_absolute or 0;
			addonlevel_resist_absolute = localuser.addonlevel_resist_absolute or 0;
			addonlevel_hp_absolute = localuser.addonlevel_hp_absolute or 0;
			addonlevel_criticalstrike_percent = localuser.addonlevel_criticalstrike_percent or 0;
			addonlevel_resilience_percent = localuser.addonlevel_resilience_percent or 0;
		end
		for gsid in string.gmatch(equipped_items, "[^,]+") do
			gsid = string.match(gsid, "^(%d+)$");
			if(gsid) then
				gsid = tonumber(gsid);
				-- don't check multiple gsid items
				if(not equipped_items_gsids_checked[gsid]) then
					equipped_items_gsids_checked[gsid] = true;
					local gsItem = PowerItemManager.GetGlobalStoreItemInMemory(gsid);
					if(gsItem) then
						-- prevent multiple items applied to the same inventory position
						local position = gsItem.template.inventorytype;
						if(not equipped_items_positions[position]) then
							equipped_items_positions[position] = true;
							-- get stats form addon
							local has_item, guid_item = PowerItemManager.IfOwnGSItem(nid, gsid);
							-- validate the combat params
							if(bCombatItemsSynced) then
								if(has_item) then
									-- get equip cards
									local stats = gsItem.template.stats;
									local is_valid = true;
									-- 251 1v1_ranking_requirement(CG) 物品穿着必须1v1积分 青年版第一次使用
									-- 252 2v2_ranking_requirement(CG) 物品穿着必须2v2积分 青年版第一次使用
									-- 253 any_ranking_requirement(CG) 物品穿着必须任意pvp积分 1v1 2v2 有一个达到即可 青年版第一次使用 
									if(stats[251]) then
										if(Player.GetRanking_1v1_from_nid(nid) < stats[251]) then
											is_valid = false;
										end
									end
									if(stats[252]) then
										if(Player.GetRanking_2v2_from_nid(nid) < stats[252]) then
											is_valid = false;
										end
									end
									if(stats[253]) then
										if((Player.GetRanking_1v1_from_nid(nid) < stats[253]) and (Player.GetRanking_2v2_from_nid(nid) < stats[253])) then
											is_valid = false;
										end
									end

									-- 137 school_requirement(CG) 物品穿着必须系别 1金 2木 3水 4火 5土 6火 7冰 8风暴 9神秘 10生命 11死亡 12平衡 
									-- validate item school
									local phase_srv = PowerItemManager.GetUserSchool(nid);
									local stats_137 = stats[137];
									if(stats_137 == 6 and phase_srv ~= "fire") then
										is_valid = false;
									elseif(stats_137 == 7 and phase_srv ~= "ice") then
										is_valid = false;
									elseif(stats_137 == 8 and phase_srv ~= "storm") then
										is_valid = false;
									elseif(stats_137 == 9 and phase_srv ~= "myth") then
										is_valid = false;
									elseif(stats_137 == 10 and phase_srv ~= "life") then
										is_valid = false;
									elseif(stats_137 == 11 and phase_srv ~= "death") then
										is_valid = false;
									elseif(stats_137 == 12 and phase_srv ~= "balance") then
										is_valid = false;
									end

									if(is_valid) then
										-- 69 CombatBoostFoodByBattle? _Aura(G) 青年版大餐 value写1 有这个stat的marker会对队友生效 标记在marker里 
										-- 90 CombatBoostFoodByBattle? _Bonus 烹饪标记marker_宴席 
										if(position == 90 and gsItem.template.stats[69]) then
											-- TODO: some mark the aura in arena
											---table.insert(equipped_items_all, gsid);
											user_team_aura = gsid;
										else
											table.insert(equipped_items_all, gsid);
										end
										-- 139 ~ 150 additional_card(CG)
										local key, value;
										for key, value in pairs(stats) do
											if(key >= 139 and key <= 150) then
												local cardkey = Card.Get_cardkey_from_gsid(value);
												if(cardkey) then
													equip_cards_all[cardkey] = (equip_cards_all[cardkey] or 0) + 1;
												end
											end
										end
									end
								end
							else
								table.insert(equipped_items_all, gsid);
							end
							if(has_item) then
								local item_obj = PowerItemManager.GetItemByGUID(nid, guid_item);
								if(item_obj and item_obj.guid > 0) then
									if(item_obj.GetAddonAttackPercentage) then
										addonlevel_damage_percent = addonlevel_damage_percent + (item_obj:GetAddonAttackPercentage() or 0);
									end
									if(item_obj.GetAddonAttackAbsolute) then
										addonlevel_damage_absolute = addonlevel_damage_absolute + (item_obj:GetAddonAttackAbsolute() or 0);
									end
									if(item_obj.GetAddonResistAbsolute) then
										addonlevel_resist_absolute = addonlevel_resist_absolute + (item_obj:GetAddonResistAbsolute() or 0);
									end
									if(item_obj.GetAddonHpAbsolute) then
										addonlevel_hp_absolute = addonlevel_hp_absolute + (item_obj:GetAddonHpAbsolute() or 0);
									end
									if(item_obj.GetCriticalStrikePercent) then
										addonlevel_criticalstrike_percent = addonlevel_criticalstrike_percent + (item_obj:GetCriticalStrikePercent() or 0);
									end
									if(item_obj.GetResiliencePercent) then
										addonlevel_resilience_percent = addonlevel_resilience_percent + (item_obj:GetResiliencePercent() or 0);
									end
									if(bCombatItemsSynced) then
										-- use in-memory gem list for items that are synced before combat
										if(item_obj.GetSocketedGems) then
											local gems = item_obj:GetSocketedGems();
											if(gems) then
												gems = Arena.FilterInvalidGems(gems);
												local _, gsid;
												for _, gsid in pairs(gems) do
													table.insert(equipped_gems_all, gsid);
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end

		if(not loot_scale) then
			loot_scale = 1;
		elseif(loot_scale < 0 or loot_scale > 1) then
			loot_scale = 1;
		end
		
		-- validate the combat params
		if(bCombatItemsSynced) then
			-- validate combat level
			local petlevel_srv = PowerItemManager.GetUserCombatLevel(nid);
			if(petlevel_srv ~= petlevel) then
				combat_server.AppendPostLog({
					action = "UserEnterCombatWithIllegalParams", 
					nid = nid,
					reason = "combat_level",
					petlevel_srv = petlevel_srv,
					petlevel = petlevel,
				});
			end
			petlevel = petlevel_srv or petlevel;
			
			local phase_srv = PowerItemManager.GetUserSchool(nid);
			if(phase_srv ~= phase) then
				combat_server.AppendPostLog({
					action = "UserEnterCombatWithIllegalParams", 
					nid = nid,
					reason = "combat_phase",
					phase_srv = phase_srv,
					phase = phase,
				});
			end
			phase = phase_srv or phase;

			-- validate deck_gsid
			if(not PowerItemManager.IfOwnGSItem(nid, deck_gsid)) then
				-- panalty for illegal deck: clear all
				deck_gsid = 0;
				combat_server.AppendPostLog({
					action = "UserEnterCombatWithIllegalParams", 
					nid = nid,
					reason = "deck_gsid",
					deck_gsid = deck_gsid,
				});
			end
			-- validate deck_cards_all
			if(nid == "localuser") then
				-- skip deck cards validation
			elseif(not deck_gsid) then
				deck_cards_all = {};
			else
				local gsItem = PowerItemManager.GetGlobalStoreItemInMemory(deck_gsid);
				if(gsItem) then
					local gsItem_template_stats = gsItem.template.stats;
					-- 167 combatdeck_card_capacity(CG) 战斗deck的卡片总容量
					if(gsItem_template_stats[167]) then
						-- validate card counts
						-- 170 combatdeck_card_eachcapacity(CG) 战斗deck的单个卡片的最大容量  
						-- 171 combatdeck_card_fire_capacity(CG) 战斗deck的火系单个卡片的最大容量  
						-- 172 combatdeck_card_ice_capacity(CG) 战斗deck的冰系单个卡片的最大容量  
						-- 173 combatdeck_card_storm_capacity(CG) 战斗deck的风暴系单个卡片的最大容量  
						-- 174 combatdeck_card_myth_capacity(CG) 战斗deck的神秘系单个卡片的最大容量  
						-- 175 combatdeck_card_life_capacity(CG) 战斗deck的生命系单个卡片的最大容量  
						-- 176 combatdeck_card_death_capacity(CG) 战斗deck的死亡系单个卡片的最大容量  
						-- 177 combatdeck_card_balance_capacity(CG) 战斗deck的平衡系单个卡片的最大容量 
						local total_deck_card_count = 0;
						local each_shared_cooldown_count = {};
						local key, count;
						for key, count in pairs(deck_cards_all) do
							local gsid = Card.Get_gsid_from_cardkey(key);
							local cardTemplate = Card.GetCardTemplate(key);
							if(gsid and cardTemplate) then
								-- check deck card validity, only obtained card qualification can be used in deck
								local bQualified = false;
								local spell_school = cardTemplate.spell_school;
								if(System.options.version == "teen") then
									local gsItem = PowerItemManager.GetGlobalStoreItemInMemory(gsid);
									if(gsItem) then
										local user_primary_school = PowerItemManager.GetUserSchool(nid);
										local user_secondary_school = PowerItemManager.GetUserSecondarySchool(nid);
										local bSchoolIrrelevant = false;
										if(SchoolIrrelevant_GSIDs[gsid]) then
											bSchoolIrrelevant = true;
										end
										-- 250 qualitycard_regardless_of_white(CG) 不需要白卡(主修或辅修)也可以使用的品质卡片 (青年版) 
										if(gsItem.template.stats[250]) then
											bSchoolIrrelevant = true;
										end
										-- qualified if school or secondary school matches
										if(bSchoolIrrelevant or spell_school == user_primary_school or spell_school == user_secondary_school) then
											-- 221 apparel_quality(CG) 装备的品质 -1未知 0白 1绿 2蓝 3紫 4橙
											local quality = gsItem.template.stats[221];
											if(quality and quality >= 1) then
												-- green and the above cards check the item validity
												local bOwn, _, __, copies = PowerItemManager.IfOwnGSItem(nid, gsid);
												if(bOwn and copies) then
													if(copies >= count) then
														-- qualified if item copies reach the provided count
														bQualified = true;
													end
												end
											else
												-- white cards check the level and school
												local spell_school = cardTemplate.spell_school;
												local can_learn = cardTemplate.can_learn;
												local require_level = cardTemplate.require_level or 0;
												local user_level = PowerItemManager.GetUserCombatLevel(nid) or 0;
												if(require_level <= user_level and can_learn) then
													-- qualified if user level reaches required level
													bQualified = true;
												end
												-- NOTE: 5 stance card are not can_learn
												--		 the card item is granted from quest rewards
												local bOwn, _, __, copies = PowerItemManager.IfOwnGSItem(nid, gsid);
												if(bOwn and copies) then
													if(copies >= count) then
														-- qualified if item copies reach the provided count
														bQualified = true;
													end
												end
											end
										end
									end
								else
									if(PowerItemManager.IfOwnGSItem(nid, gsid)) then
										bQualified = true;
									end
								end
								if(bQualified) then
									-- check card capacity
									local eachcard_capacity = 0;
									local spell_name = cardTemplate.spell_name;
									each_shared_cooldown_count[spell_name] = each_shared_cooldown_count[spell_name] or 0;
									local spell_school = cardTemplate.spell_school;
									if(spell_school == "fire") then
										eachcard_capacity = math_max(gsItem_template_stats[170] or 0, gsItem_template_stats[171] or 0);
									elseif(spell_school == "ice") then
										eachcard_capacity = math_max(gsItem_template_stats[170] or 0, gsItem_template_stats[172] or 0);
									elseif(spell_school == "storm") then
										eachcard_capacity = math_max(gsItem_template_stats[170] or 0, gsItem_template_stats[173] or 0);
									elseif(spell_school == "myth") then
										eachcard_capacity = math_max(gsItem_template_stats[170] or 0, gsItem_template_stats[174] or 0);
									elseif(spell_school == "life") then
										eachcard_capacity = math_max(gsItem_template_stats[170] or 0, gsItem_template_stats[175] or 0);
									elseif(spell_school == "death") then
										eachcard_capacity = math_max(gsItem_template_stats[170] or 0, gsItem_template_stats[176] or 0);
									elseif(spell_school == "balance") then
										eachcard_capacity = math_max(gsItem_template_stats[170] or 0, gsItem_template_stats[177] or 0);
									end
									if(count > eachcard_capacity) then
										deck_cards_all[key] = eachcard_capacity;
										-- deck card key is not valid
										combat_server.AppendPostLog({
											action = "UserEnterCombatWithIllegalParams", 
											nid = nid,
											reason = "deck_card_exceed_deck_capacity",
											key = key,
											count = count,
											deck_gsid = deck_gsid,
										});
										total_deck_card_count = total_deck_card_count + eachcard_capacity;
									else
										if(System.options.version == "teen") then
											if((each_shared_cooldown_count[spell_name] + count) <= eachcard_capacity) then
												each_shared_cooldown_count[spell_name] = each_shared_cooldown_count[spell_name] + count;
												total_deck_card_count = total_deck_card_count + count;
											else
												-- NOTE: discard cards if reached the shared cooldown capacity
											end
										else
											total_deck_card_count = total_deck_card_count + count;
										end
									end
								else
									-- clear cards that has not learn yet
									deck_cards_all[key] = 0;
									-- deck card key is not valid
									combat_server.AppendPostLog({
										action = "UserEnterCombatWithIllegalParams", 
										nid = nid,
										reason = "deck_card_not_learn",
										key = key,
									});
								end
							else
								-- clear cards that has not valid template
								deck_cards_all[key] = 0;
								-- deck card key is not valid
								combat_server.AppendPostLog({
									action = "UserEnterCombatWithIllegalParams", 
									nid = nid,
									reason = "deck_card_key_not_valid",
									key = key,
								});
							end
						end
						
						-- 167 combatdeck_card_capacity(CG) 战斗deck的卡片总容量
						local deck_cards_capacity = gsItem_template_stats[167];
						if(deck_cards_capacity < total_deck_card_count) then
							deck_cards_all = {};
							combat_server.AppendPostLog({
								action = "UserEnterCombatWithIllegalParams", 
								nid = nid,
								reason = "deck_cards_capacity",
								deck_gsid = deck_gsid,
								deck_cards_capacity = deck_cards_capacity,
								total_deck_card_count = total_deck_card_count,
							});
						end
					else
						deck_cards_all = {};
					end
				else
					deck_cards_all = {};
				end
			end
			-- validate deck_cards_rune_all
			-- NOTE: deck_cards_rune_all is check with MAX_RUNE_COUNT

			-- validate deck_cards_pet_all, followpet_history, followpet_guid
			if(followpet_guid) then
				local pet_obj = PowerItemManager.GetItemByGUID(nid, followpet_guid);
				if(pet_obj and pet_obj.guid > 0 and pet_obj.GetCurLevelCards) then
					-- get pet cards
					local deck_cards_pet_all_srv = {};
					local cards = pet_obj:GetCurLevelCards(true);
					if(cards) then
						local _, gsid
						for _, gsid in pairs(cards) do
							local key = Card.Get_cardkey_from_gsid(gsid);
							if(key) then
								deck_cards_pet_all_srv[key] = (deck_cards_pet_all_srv[key] or 0) + 1;
							else
								local key = Card.Get_cardkey_from_rune_gsid(gsid);
								if(key) then
									deck_cards_pet_all_srv[key] = (deck_cards_pet_all_srv[key] or 0) + 1;
								end
							end
						end
					end
					-- set deck_cards_pet_all
					followpet_guid = followpet_guid;
					followpet_history = {[followpet_guid] = true};
					deck_cards_pet_all = deck_cards_pet_all_srv;
				else
					-- pet item is not valid
					combat_server.AppendPostLog({
						action = "UserEnterCombatWithIllegalParams", 
						nid = nid,
						reason = "followpet_guid",
						followpet_guid = followpet_guid,
						deck_cards_pet = deck_cards_pet,
					});
					-- reset deck_cards_pet_all
					followpet_guid = 0;
					followpet_history = {};
					deck_cards_pet_all = {};
				end
			end

			-- dragon totem string
			if(dragon_totem_str) then
				local profession_gsid, exp_gsid, exp_cnt = string.match(dragon_totem_str, "^(%d+),(%d+),(%d+)$");
				if(profession_gsid and exp_gsid and exp_cnt) then
					profession_gsid = tonumber(profession_gsid);
					exp_gsid = tonumber(exp_gsid);
					exp_cnt = tonumber(exp_cnt);
					if(profession_gsid and exp_gsid and exp_cnt) then
						local has_profession, guid_profession = PowerItemManager.IfOwnGSItem(nid, profession_gsid);
						if(has_profession) then
							dragon_totem_profession_gsid = profession_gsid;
							dragon_totem_exp_gsid = exp_gsid;
							dragon_totem_exp_cnt = 0;
							local has_exp, _, __, copies_exp = PowerItemManager.IfOwnGSItem(nid, exp_gsid);
							if(has_exp and copies_exp and copies_exp >= exp_cnt) then
								dragon_totem_profession_gsid = profession_gsid;
								dragon_totem_exp_gsid = exp_gsid;
								dragon_totem_exp_cnt = exp_cnt;
							end
						end
					end
				end
			end

			-- equipped_items_all, equipped_gems_all is synced in equipped_items parsing
		end

		-- create player
		local player = Player:new({
			nid = nid,
			current_hp = current_hp,
			max_hp = max_hp,
			phase = phase,
			petlevel = petlevel,
			deck_gsid = deck_gsid,
			deck_struct = deck_cards_all,
			deck_struct_equip = equip_cards_all,
			--deck_struct_rune = deck_cards_rune_all,
			deck_struct_pet = deck_cards_pet_all,
			equips = equipped_items_all,
			gems = equipped_gems_all,
			current_followpet_guid = followpet_guid,
			followpet_history = followpet_history,
			loot_scale = loot_scale,
			isoverweight = isoverweight,
			addonlevel_damage_percent = addonlevel_damage_percent,
			addonlevel_damage_absolute = addonlevel_damage_absolute,
			addonlevel_resist_absolute = addonlevel_resist_absolute,
			addonlevel_hp_absolute = addonlevel_hp_absolute,
			addonlevel_criticalstrike_percent = addonlevel_criticalstrike_percent,
			addonlevel_resilience_percent = addonlevel_resilience_percent,
			dragon_totem_profession_gsid = dragon_totem_profession_gsid,
			dragon_totem_exp_gsid = dragon_totem_exp_gsid,
			dragon_totem_exp_cnt = dragon_totem_exp_cnt,
			user_team_aura = user_team_aura,
		});

		-- kids:1277 teen:1118 用脸滚键盘吧
		local with_mighty_keyboard = false;
		local _, gsid;
		for _, gsid in ipairs(equipped_items_all) do
			if(gsid == 1277 and System.options.version == "kids") then
				with_mighty_keyboard = true;
				break;
			elseif(gsid == 1118 and System.options.version == "teen") then
				with_mighty_keyboard = true;
				break;
			end
		end
		
		if(not with_mighty_keyboard) then
			-- 965_GearScore_Tag
			PowerItemManager.SetItemCountIfEmptyOrLess(nid, 965, player:GetGearScoreV2(), function(msg)
			end)
		end

		if(arena.mode == "pve") then
			local minion_gsid = arena.minion_gsid;
			local minion_key = arena.minion_key;
			if(minion_gsid and arena:IsPlayerSlotEmpty()) then
				local gsItem = PowerItemManager.GetGlobalStoreItemInMemory(minion_gsid);
				if(gsItem and gsItem.template.stats and gsItem.template.class == 22) then
					local stats = gsItem.template.stats;
					-- 138 combatlevel_requirement(CG) 物品穿着必须战斗等级 
					local level = stats[138] or 50;
					-- 101 add_maximum_hp(CG) 增加用户HP上限 
					local max_hp = stats[101] or 1000;
					-- create default minion
					local minion = Player:new({
						is_minion = true,
						minion_key = minion_key,
						nid = minion_gsid,
						current_hp = max_hp,
						max_hp = max_hp,
						phase = "death",
						petlevel = level,
						deck_gsid = 0,
						deck_struct = {},
						deck_struct_equip = {},
						deck_struct_rune = {},
						deck_struct_pet = {},
						equips = {minion_gsid},
						gems = {},
						current_followpet_guid = 0,
						followpet_history = {},
						loot_scale = 1,
						isoverweight = false,
						addonlevel_damage_percent = 0,
						addonlevel_damage_absolute = 0,
						addonlevel_resist_absolute = 0,
						addonlevel_hp_absolute = 0,
						addonlevel_criticalstrike_percent = 0,
						addonlevel_resilience_percent = 0,
						dragon_totem_profession_gsid = 0,
						dragon_totem_exp_gsid = 0,
						dragon_totem_exp_cnt = 0,
						user_team_aura = nil,
					});
					if(minion_gsid == 27001) then
						minion.phase = "death";
					elseif(minion_gsid == 27002) then
						minion.phase = "storm";
					end
					local isSuccess, reason = arena:AddArenaMinion_pve(minion);
					if(isSuccess) then
						if(arena.entercombat_hots) then
							local entercombat_hots = commonlib.deepcopy(arena.entercombat_hots);
							minion:AppendHoT(entercombat_hots);
						end
					end
				end
			end
			-- add player to arena
			local isSuccess, reason = arena:AddPlayer_pve(player);
			if(isSuccess) then
				-- set locked_for_teamleaderid 
				if(leadernid > 0) then
					arena.locked_for_teamleaderid = leadernid;
					arena.locked_for_teamleaderid_time = combat_server.GetCurrentTime();
				end
				if(arena.entercombat_hots) then
					local entercombat_hots = commonlib.deepcopy(arena.entercombat_hots);
					player:AppendHoT(entercombat_hots);
				end
				if(is_follow_pet_joincombat and followpet_guid and followpet_guid > 0) then
					local pet_obj = PowerItemManager.GetItemByGUID(nid, followpet_guid);
					if(pet_obj and pet_obj.guid > 0 and pet_obj.GetCurLevelCards and pet_obj.GetLevelsInfo and pet_obj.GetSchool and pet_obj.GetCurLevelAICards) then
						local level = 50;
						-- create default minion
						local followpet_params = GetBasePlayerParam();
						followpet_params.is_minion = true;
						followpet_params.nid = -nid;
						followpet_params.current_hp = max_hp;
						followpet_params.max_hp = max_hp;
						followpet_params.petlevel = level;
						followpet_params.equips = {};
						-- follow pet guid
						followpet_params.current_followpet_guid = followpet_guid;
						local level_info = pet_obj:GetLevelsInfo(true);
						if(level_info and level_info.cur_level) then
							followpet_params.petlevel = level_info.cur_level;
						end
						-- school
						local school_short_gsid = pet_obj:GetSchool(true);
						if(school_short_gsid == 6) then
							followpet_params.phase = "fire";
						elseif(school_short_gsid == 7) then
							followpet_params.phase = "ice";
						elseif(school_short_gsid == 8) then
							followpet_params.phase = "storm";
						elseif(school_short_gsid == 9) then
							followpet_params.phase = "myth";
						elseif(school_short_gsid == 10) then
							followpet_params.phase = "life";
						elseif(school_short_gsid == 11) then
							followpet_params.phase = "death";
						elseif(school_short_gsid == 12) then
							followpet_params.phase = "balance";
						end
						-- get AI cards
						local ai_cards = pet_obj:GetCurLevelAICards();
						--return 实体卡片 cur_entity_cards_list ={ {gsid = gsid, ai_key = ai_key}, {gsid = gsid, ai_key = ai_key}, }
						if(ai_cards) then
							followpet_params.ai_modules = {};
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
									table.insert(followpet_params.ai_modules, ai_module);
								end
							end
						end

						-- incombat follow pet
						local minion = Player:new(followpet_params);
						local isSuccess, reason = arena:AddFollowPetMinion_pve(minion);
						if(isSuccess) then
							-- mark follow pet combat mode history
							player:MarkFollowPetCombatModeHistory(followpet_guid);
							if(arena.entercombat_hots) then
								local entercombat_hots = commonlib.deepcopy(arena.entercombat_hots);
								minion:AppendHoT(entercombat_hots);
							end
							local max_hp_system = minion:GetUpdatedMaxHP();
							if(max_hp_system) then
								minion.current_hp = max_hp_system;
								minion.max_hp = max_hp_system;
							end
						end
					end

					--followpet_params.ai_modules = {
						--{key = "Death_SingleAttack_Level0_120_adv", count_cur = 3, count_total = 5, action = "breakshield_attack"},
						--{key = "Balance_GlobalShield", count_cur = 3, count_total = 5, action = "generic_defense"},
						--{key = "Death_SingleAttackWithLifeTap_Level6", count_cur = 3, count_total = 5, action = "heavy_attack"},
						--{key = "Death_SingleAttackWithLifeTap_Level4", count_cur = 3, count_total = 5, action = "heavy_attack"},
						--{key = "Death_GlobalDamageTrap", count_cur = 3, count_total = 5, action = "generic_debuff"},
						--{key = "Death_DeathDamageBlade", count_cur = 3, count_total = 5, action = "school_buff"},
						--{key = "Fire_DeathDamageBlade", count_cur = 3, count_total = 5, action = "master_buff"},
						--{key = "Ice_DeathDamageBlade", count_cur = 3, count_total = 5, action = "followpet_buff"},
					--};
				end
				
				if(arena.world_config_file == "config/Aries/WorldData_Teen/HaqiTown_RedMushroomArena_AI_1v1.Arenas_Mobs.xml") then
					-- reset the mob with user gear score
					local gearscore = player:GetVirtualRankingScore("1v1") or 0;
					local id;
					for _, id in ipairs(arena.mob_ids) do
						local mob_obj = Mob.GetMobByID(id);
						if(mob_obj) then
							local ranking = player:GetCheckedRanking("1v1");
							if(not ranking or ranking >= 1600) then
								mob_obj:SkipLoot();
							end
							if(player:GetLevel() < 40) then
								mob_obj:SkipLoot();
							end
							mob_obj:SetLevel(petlevel);
							mob_obj:SetAIDeckFromGearScore(mob_obj:GetPhase(), gearscore); -- reset deck_attacker_style and deckcards
							mob_obj:SetStatsFromGearScore(mob_obj:GetPhase(), gearscore); -- reset stats
							mob_obj:TakeHeal(9999999);
						end
					end
				end

				-- tell the player to enter arena slot
				arena:UpdateToClient_EnterCombat(nid);
			elseif(not isSuccess and reason == "ArenaSlotsFull") then
				-- if the arena is full, player can't join fight
				combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "ArenaSlotsFull:");
				-- destroy the newly created player but not appended to the arena player list
				Player.DestroyPlayer(nid);
				return;
			end
		elseif(arena.mode == "free_pvp") then
			if(arena.is_battlefield) then
				-- join battle field arena with service specified side
				if(Arena.GetUserSide(arena, nid) == 0) then
					side = "near";
				elseif(Arena.GetUserSide(arena, nid) == 1) then
					side = "far";
				else
					-- if the arena is full, player can't join fight
					combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "ArenaSlotsFull:");
					-- destroy the newly created player but not appended to the arena player list
					Player.DestroyPlayer(nid);
					return;
				end
			end
			local nPreferSlot; -- for redmushroom arena prefer slot
			if(arena.match_info) then
				if(arena.match_info_team1 and arena.match_info_team2) then
					nPreferSlot = arena.match_info_team1[nid] or arena.match_info_team2[nid];
				end
			end
			-- add player to arena
			local isSuccess = arena:AddPlayer_pvp(player, side, nPreferSlot);
			if(isSuccess) then
				-- reset ranking point
				-- NOTE: if 2v1 status can start a 2v2 redmushroom combat, that later player will miss the ranking stage test
				--		 reset this tag on each player enter combat
				arena.bAllPlayerResyncedRankingPoints = nil;
				-- tell the player to enter arena slot
				arena:UpdateToClient_EnterCombat(nid);
				-- entercombat on pvp arena
				QuestServerLogics.PvP_WorldInstance_Actived_Handler(nid, arena.world_config_file);
			else
				-- if the arena is full, player can't join fight
				combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "ArenaSlotsFull:");
				-- destroy the newly created player but not appended to the arena player list
				Player.DestroyPlayer(nid);
				return;
			end
		end

		-- player combat items synced
		local player_object = Player.GetPlayerCombatObj(nid);
		if(player_object) then
			player_object.bResyncCombatItems = true;
			if(bCombatItemsSynced) then
				-- validate the combat params
				local max_hp_user = max_hp;
				local max_hp_system = player_object:GetUpdatedMaxHP();
				if(max_hp_user > max_hp_system) then
					-- reset the max_hp if illegal max_hp
					player_object.max_hp = max_hp_system;
					-- NOTE: fair_play arena max_hp is overwritten by the config
					-- so illegal max_hp will be overwritten by this max_hp_system and later by the arena config
					if(player_object.current_hp > max_hp_system) then
						player_object.current_hp = max_hp_system;
					end
					-- record the illegal users
					combat_server.AppendPostLog({
						action = "UserEnterCombatWithIllegalParams", 
						nid = nid,
						reason = "max_hp",
						max_hp_user = max_hp_user,
						max_hp_system = max_hp_system,
					});
				end
			end
			
			-- reset itemset_info
			player:ResetItemSetInfo();

			-- record the durable items after item sync or directly from newbie items
			player_object.current_combat_durable_items = player_object:GetDurableItems();
			-- skip durability cost for user with magic star above level 3
			local magicstar_level = PowerItemManager.GetMagicStarLevel(nid);
			if(magicstar_level >= 3) then
				player_object.current_combat_durable_items = nil;
			end
		end
		
		if(arena.entercombat_is_full_health) then
			player:TakeHeal(9999999);
		end

		arena:DebugDumpData("------------------ end TryEnterCombat ------------------");
	end
	
	local petlevel_memory;
	local userdragoninfo = PowerItemManager.GetUserAndDragonInfoInMemory(nid);
	if(userdragoninfo and userdragoninfo.dragon.combatlel) then
		petlevel_memory = userdragoninfo.dragon.combatlel;
	end

	-- NOTE: sync combat stats and items for all players
	if(false) then
		-- process enter combat without full combat item synced for player below level 10
		ProcEnterCombat(false); -- bCombatItemsSynced
	else
		-- sync user combat items
		if(nid == "localuser") then
			-- local users does not verify items
			ProcEnterCombat(true);
			return 
		end
		local invoketime = ParaGlobal.timeGetTime();
		PowerItemManager.SyncUserCombatItems(nid, function()
			-- sync user info
			local invoketime_userinfo = ParaGlobal.timeGetTime();
			PowerItemManager.GetUserAndDragonInfo(nid, function(msg)
				if(msg and msg.issuccess_webapi) then
					-- process enter combat with full combat item synced
					ProcEnterCombat(true); -- bCombatItemsSynced
				end
				if((ParaGlobal.timeGetTime() - invoketime_userinfo) > 2000) then
					combat_server.AppendPostLog({
						action = "SyncUserCombatUserInfo_reply_over_2seconds", 
						nid = nid,
						elapsedtime = ParaGlobal.timeGetTime() - invoketime_userinfo,
					});
				end
			end, function()
				combat_server.AppendPostLog({
					action = "SyncUserCombatUserInfo_timeout", 
					nid = nid,
					elapsedtime = ParaGlobal.timeGetTime() - invoketime_userinfo,
				});
			end)

			--local fake_equips_gsids = nil;
			--local _, gsid;
			--for _, gsid in ipairs(equipped_items_all) do
				--if(not PowerItemManager.IfOwnGSItem(nid, gsid)) then
					--fake_equips_gsids = fake_equips_gsids or {};
					--table.insert(fake_equips_gsids, gsid);
				--end
			--end
			--if(fake_equips_gsids) then
				--combat_server.AppendPostLog({
					--action = "fake_equips_gsids_entercombat", 
					--nid = nid,
					--fake_equips_gsids = fake_equips_gsids,
				--});
			--end
			if((ParaGlobal.timeGetTime() - invoketime) > 2000) then
				combat_server.AppendPostLog({
					action = "SyncUserCombatItems_reply_over_2seconds", 
					nid = nid,
					elapsedtime = ParaGlobal.timeGetTime() - invoketime,
				});
			end
		end, function()
			combat_server.AppendPostLog({
				action = "SyncUserCombatItems_timeout", 
				nid = nid,
				elapsedtime = ParaGlobal.timeGetTime() - invoketime,
			});
		end)
	end
end

-- pick card by player
-- @param nid: player nid
-- @param card_key: the card key to Cards and Spells
-- @param isMob: is mob or player
-- @param id: if the player is on mob
function Arena.OnReponse_PickCardByPlayer(nid, seq, card_key, card_seq, isMob, id, isAutoAICard)
	--log("Arena.OnReponse_PickCardByPlayer=========\n")
	--commonlib.echo({nid, seq, card_key, isMob, id})
	local player = Player.GetPlayerCombatObj(nid);
	if(player) then
		player.nIdleRounds = 0; -- reset the idle rounds
		local arena_id = player.arena_id;
		if(arena_id) then
			LOG.std(nil, "user", "arena", "arena_id=%d|OnReponse_PickCardByPlayer %s,%s", arena_id, tostring(nid), card_key);
			local arena = Arena.GetArenaByID(arena_id)
			if(arena and arena.seq == seq) then
				arena:DebugDumpData("------------------ begin PickCardByPlayer ------------------ "..tostring(nid).." "..tostring(card_key).." "..tostring(isMob).." "..tostring(id));

				local friendly_isfarside, hostile_isfarside = false, true;
				if(player.side == "near") then
					friendly_isfarside, hostile_isfarside = false, true;
				elseif(player.side == "far") then
					friendly_isfarside, hostile_isfarside = true, false;
				end

				local card_key_lower = string.lower(card_key);
				-- check for validity of the caster and target
				if(string.find(card_key_lower, "areaattack")) then
					-- continue
					-- -1 stands for all mobs for areaattack
					isMob = hostile_isfarside;
					id = -1;
				elseif(string.find(card_key_lower, "areataunt")) then
					-- continue
					-- -1 stands for all mobs for areataunt
					isMob = hostile_isfarside;
					id = -1;
				elseif(string.find(card_key_lower, "arenaattack")) then
					-- continue
					-- -1 stands for all mobs for areaattack
					isMob = hostile_isfarside;
					id = -1;
				elseif(string.find(card_key_lower, "areadotattack")) then
					-- continue
					-- -1 stands for all mobs for areadotattack
					isMob = hostile_isfarside;
					id = -1;
				elseif(string.find(card_key_lower, "areasingleattack")) then
					-- continue
					-- -1 stands for all mobs for areasingleattack
					isMob = hostile_isfarside;
					id = -1;
				elseif(string.find(card_key_lower, "areastunabsorb")) then
					-- continue
					-- -1 stands for all players for areastunabsorb
					isMob = friendly_isfarside;
					id = -1;
				elseif(string.find(card_key_lower, "areastun")) then
					-- continue
					-- -1 stands for all mobs for areastun
					isMob = hostile_isfarside;
					id = -1;
				elseif(string.find(card_key_lower, "areadamageweakness")) then
					-- continue
					-- -1 stands for all mobs for areadamageweakness
					isMob = hostile_isfarside;
					id = -1;
				elseif(string.find(card_key_lower, "areadamageshield")) then
					-- continue
					-- -1 stands for all players for areastunabsorb
					isMob = friendly_isfarside;
					id = -1;
				elseif(string.find(card_key_lower, "areaaccuracyweakness")) then
					-- continue
					-- -1 stands for all mobs for areaaccuracyweakness
					isMob = hostile_isfarside;
					id = -1;
				elseif(string.find(card_key_lower, "areadamagetrap")) then
					-- continue
					-- -1 stands for all mobs for areadamagetrap
					isMob = hostile_isfarside;
					id = -1;
				elseif(string.find(card_key_lower, "areaaccuracyblade")) then
					-- continue
					-- -1 stands for all players for areaaccuracyblade
					isMob = friendly_isfarside;
					id = -1;
				elseif(string.find(card_key_lower, "areaheal")) then
					-- continue
					-- -1 stands for all players for areaheal
					isMob = friendly_isfarside;
					id = -1;
				elseif(string.find(card_key_lower, "areacleanse")) then
					-- continue
					-- -1 stands for all players for areaheal
					isMob = friendly_isfarside;
					id = -1;
				elseif(string.find(card_key_lower, "areapowerpipboost")) then
					-- continue
					-- -1 stands for all players for areaheal
					isMob = friendly_isfarside;
					id = -1;
				elseif(isMob == false) then
					if(id == 0) then
						id = nid; -- 0 stands for user himself
					end
					-- player not in arena player list
					if(not arena:IsPlayerInArena(id)) then
						return;
					end
				elseif(isMob == true) then
					if(not arena:IsMobInArena(id)) then
						-- mob not in arena mob list
						return;
					end
				else
					return;
				end
				
				local bFollowPetCard = false;
				if(card_seq >= 10000) then
					-- this is from follow pet
					bFollowPetCard = true;

					-- 宠物卡牌无法在公平试炼场中使用
					if(arena.entercombat_cost == "TrialOfChampions") then
						-- repick your card
						Arena.OnReponse_CancelPickCardByPlayer(nid, seq);
						return;
					end
				end

				if(not player:CanCastSpell(card_key, bFollowPetCard)) then
					if(nid == 46650264) then -- andy
						-- test account
					elseif(nid == 172545123) then -- andy2
						-- test account
					--elseif(nid == 156771957) then -- andy3 tutorial
						-- test account
					else
						-- repick your card
						Arena.OnReponse_CancelPickCardByPlayer(nid, seq);
						return;
					end
				end
				if(string.find(card_key_lower, "miniaura")) then
					local unit = Arena.GetCombatUnit(isMob, id)
					if(unit) then
						if(unit.side ~= player.side) then
							-- miniaura on hostile units
							-- repick your card
							Arena.OnReponse_CancelPickCardByPlayer(nid, seq);
							return;
						end
					end
				end
				if(System.options.version == "kids" and self_only_keys_kids[card_key] and id ~= nid) then
					-- self only card keys
					-- repick your card
					Arena.OnReponse_CancelPickCardByPlayer(nid, seq);
					return;
				end
				if(System.options.version == "teen" and self_only_keys_teen[card_key] and id ~= nid) then
					-- self only card keys
					-- repick your card
					Arena.OnReponse_CancelPickCardByPlayer(nid, seq);
					return;
				end
				local unit = Arena.GetCombatUnit(isMob, id)
				if(unit and unit:IsCombatActive() and unit:IsStealth()) then
					if(card_key_lower ~= "pass") then
						if(not (System.options.version == "teen" and isMob == false and id == nid)) then
							if( not (string.find(card_key_lower, "area") or string.find(card_key_lower, "arena") or string.find(card_key_lower, "singleheal")) ) then
								-- single attack on stealth target
								-- repick your card
								Arena.OnReponse_CancelPickCardByPlayer(nid, seq);
								return;
							end
						end
					end
				end
				if(arena.mode == "free_pvp" and pvp_forbidden_keys[card_key]) then
					-- pvp forbidden card keys
					-- repick your card
					combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "CannotUseInPvP:");
					Arena.OnReponse_CancelPickCardByPlayer(nid, seq);
					return;
				end
				if( (not arena.is_battlefield) and forbidden_keys_expect_battlefield[card_key]) then
					-- pvp forbidden card keys
					-- repick your card
					combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "CannotUseExpectInBattlefield:");
					Arena.OnReponse_CancelPickCardByPlayer(nid, seq);
					return;
				end
				if(arena.mode == "pve" and arena.isinstance == true and instance_forbidden_keys[card_key]) then
					-- instance forbidden card keys
					-- repick your card
					combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "CannotUseInInstance:");
					Arena.OnReponse_CancelPickCardByPlayer(nid, seq);
					return;
				end
				

				-- check card validity in card deck and follow pet
				if(card_key ~= "pass" and card_key ~= "Pass") then
					if(nid ~= 46650264) then -- andy
						local bSpecialNonDeckKey = false;
						if(card_key == "CatchPet_12055") then
							bSpecialNonDeckKey = true;
						elseif(card_key == "CatchPet_12056") then
							bSpecialNonDeckKey = true;
						end
						if(not bSpecialNonDeckKey) then
							if(not player:IsCardAvailableInDeck(card_key, card_seq)) then
								-- card sequence and card key not match in deck struct or follow pet cards
								-- repick your card
								Arena.OnReponse_CancelPickCardByPlayer(nid, seq);
								return;
							end
						end
					end
				end
				
				-- check SingleGuardianWithImmolate target
				local cardTemplate = Card.GetCardTemplate(card_key);
				if(cardTemplate) then
					if(cardTemplate.type == "SingleGuardianWithImmolate") then
						local unit = Arena.GetCombatUnit(isMob, id);
						if(unit and not unit:IsMob() and unit:IsMinion()) then
							-- target is minion
							-- repick your card
							combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "TargetIsMinionOnGuardian:");
							Arena.OnReponse_CancelPickCardByPlayer(nid, seq);
							return;
						end
					end
				end
				
				if(System.options.version == "kids") then
					-- check CatchPet target
					local cardTemplate = Card.GetCardTemplate(card_key);
					if(cardTemplate) then
						if(cardTemplate.type == "CatchPet") then
							local unit = Arena.GetCombatUnit(isMob, id);
							if(unit and unit:IsMob()) then
								local pet_gsid = unit:GetCatchPetGSID();
								if(pet_gsid and pet_gsid > 0) then
									if(PowerItemManager.IfOwnGSItem(nid, pet_gsid)) then
										-- already own pet
										-- repick your card
										combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "AlreadyOwnPet_kids:");
										Arena.OnReponse_CancelPickCardByPlayer(nid, seq);
										return;
									end
								end
							else
								-- repick your card
								Arena.OnReponse_CancelPickCardByPlayer(nid, seq);
								return;
							end
						end
					end
				end
				
				-- check enrage target
				local cardTemplate = Card.GetCardTemplate(card_key);
				if(cardTemplate) then
					if(cardTemplate.type == "Enrage") then
						local unit = Arena.GetCombatUnit(isMob, id);
						if(unit and unit:IsMob() and unit:CanBeEnraged()) then
							if(unit:IsEnraged()) then
								-- target is already enraged
								-- repick your card
								combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "TargetAlreadyEnraged:");
								Arena.OnReponse_CancelPickCardByPlayer(nid, seq);
								return;
							end
							local can_enrage_minlevel = 0;
							local can_enrage_maxlevel = 0;
							if(cardTemplate.params.can_enrage_minlevel) then
								can_enrage_minlevel = tonumber(cardTemplate.params.can_enrage_minlevel);
							end
							if(cardTemplate.params.can_enrage_maxlevel) then
								can_enrage_maxlevel = tonumber(cardTemplate.params.can_enrage_maxlevel);
							end
							local level = unit:GetLevel();
							if(level > can_enrage_maxlevel) then
								-- can't enrage higher level mobs
								-- repick your card
								combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "TargetRequiresHigherEnrageCard:");
								Arena.OnReponse_CancelPickCardByPlayer(nid, seq);
								return;
							end
							if(level < can_enrage_minlevel) then
								-- can't enrage lower level mobs
								-- repick your card
								combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "TargetRequiresLowerEnrageCard:");
								Arena.OnReponse_CancelPickCardByPlayer(nid, seq);
								return;
							end
							if(unit:Rarity_normalupdate_str() == "b") then -- boss
								if(not cardTemplate.params.can_enrage_boss) then
									-- can't enrage boss if normal enrage card
									-- repick your card
									combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "TargetRequiresBossEnrageCard:");
									Arena.OnReponse_CancelPickCardByPlayer(nid, seq);
									return;
								end
							end
							local difficulty = arena:GetDifficulty();
							if(difficulty == "easy") then
								if(unit:GetStatByField("cannot_enrage_easy")) then
									-- can't enrage if easy difficulty
									-- repick your card
									combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "TargetCannotBeEnraged_Easy:");
									Arena.OnReponse_CancelPickCardByPlayer(nid, seq);
									return;
								end
							elseif(difficulty == "normal") then
								if(unit:GetStatByField("cannot_enrage_normal")) then
									-- can't enrage if normal difficulty
									-- repick your card
									combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "TargetCannotBeEnraged_Normal:");

									Arena.OnReponse_CancelPickCardByPlayer(nid, seq);
									return;
								end
							elseif(difficulty == "hard") then
								if(unit:GetStatByField("cannot_enrage_hard")) then
									-- can't enrage if hard difficulty
									-- repick your card
									combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "TargetCannotBeEnraged_Hard:");
									Arena.OnReponse_CancelPickCardByPlayer(nid, seq);
									return;
								end
							end
							
						else
							-- not valid target
							-- repick your card
							combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "TargetCannotBeEnraged:");
							Arena.OnReponse_CancelPickCardByPlayer(nid, seq);
							return;
						end
					end
				end
				
				if(System.options.version == "teen") then
					-- check CatchPet item
					if(card_key == "CatchPet_12055") then
						if(not PowerItemManager.IfOwnGSItem(nid, 12055)) then
							-- no catchpet item available
							-- repick your card
							combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "Insufficient_12055:");
							Arena.OnReponse_CancelPickCardByPlayer(nid, seq);
							return;
						end
					elseif(card_key == "CatchPet_12056") then
						if(not PowerItemManager.IfOwnGSItem(nid, 12056)) then
							-- no catchpet item available
							-- repick your card
							combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "Insufficient_12056:");
							Arena.OnReponse_CancelPickCardByPlayer(nid, seq);
							return;
						end
					end
				end

				-- player pick card
				player:PickCard(card_key, card_seq, isMob, id, isAutoAICard);
				-- respond to clients for team member card pick status
				local target_slotid = 0;
				if(isMob == true) then
					target_slotid = -2; -- far
				elseif(isMob == false) then
					target_slotid = -1; -- near
				end
				local unit = Arena.GetCombatUnit(isMob, id)
				if(unit) then
					target_slotid = unit:GetArrowPosition_id()
				end
				local pickcard_respond = format("BuddyPickCard:%s,%d,%s,%d,%s", 
					tostring(player:GetID()),
					player:GetArrowPosition_id(),
					card_key,
					target_slotid,
					tostring(isAutoAICard)
				);
				-- send this pickcard respond to each member of the active team member
				local upper_region = 1;
				local lower_region = max_unit_count_per_side_arena;
				if(player:GetSide() == "near") then
					upper_region = 1;
					lower_region = max_unit_count_per_side_arena;
				elseif(player:GetSide() == "far") then
					upper_region = max_unit_count_per_side_arena + 1;
					lower_region = max_unit_count_per_side_arena * 2;
				end
				local i;
				for i = upper_region, lower_region do
					local nid = arena.player_nids[i];
					if(nid and (tonumber(nid) or 1) > 0) then
						local player = Player.GetPlayerCombatObj(nid)
						if(player and player:IsCombatActive()) then
							combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, pickcard_respond);
						end
					end
				end
				-- inform waiting
				if(arena.PickCardTimeOutTime) then
					local remaining_time = arena.PickCardTimeOutTime - combat_server.GetCurrentTime();
					if(remaining_time > 0) then
						local realtime_msg = format("PickYourCard_already:%d,%s,%d", remaining_time, arena.mode, arena:GetRoundTag());
						combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, realtime_msg);
					end
				end
				arena:DebugDumpData("------------------ end PickCardByPlayer ------------------");
			end
		end
	end
end

function Arena.OnReponse_TellBuddyPickCard(player, isAutoAICard)
	if(player and player.GetPickedCard) then
		local key, _, isMob, id = player:GetPickedCard();
		local pickcard_respond;

		if(key == nil) then
			pickcard_respond = format("BuddyPickCard:%s,%d,%s,%d,false", 
				tostring(player:GetID()),
				player:GetArrowPosition_id(),
				"empty",
				"0"
			);
		end

		if(key ~= nil and isMob ~= nil and id ~= nil) then
			-- respond to clients for team member card pick status
			local target_slotid = 0;
			if(isMob == true) then
				target_slotid = -2; -- far
			elseif(isMob == false) then
				target_slotid = -1; -- near
			end
			if(not string.find(string.lower(key), "area")) then
				local unit = Arena.GetCombatUnit(isMob, id)
				if(unit) then
					target_slotid = unit:GetArrowPosition_id()
				end
			end
			if(player:GetNID()) then
				isAutoAICard = false;
			end
			pickcard_respond = format("BuddyPickCard:%s,%d,%s,%d,%s", 
				tostring(player:GetID()),
				player:GetArrowPosition_id(),
				key,
				target_slotid,
				tostring(isAutoAICard)
			);
		end

		if(pickcard_respond) then
			-- send this pickcard respond to each member of the active team member
			local upper_region = 1;
			local lower_region = max_unit_count_per_side_arena;
			if(player:GetSide() == "near") then
				upper_region = 1;
				lower_region = max_unit_count_per_side_arena;
			elseif(player:GetSide() == "far") then
				upper_region = max_unit_count_per_side_arena + 1;
				lower_region = max_unit_count_per_side_arena * 2;
			end
			
			local arena_id = player.arena_id;
			if(arena_id) then
				local arena = Arena.GetArenaByID(arena_id)
				if(arena) then
					local i;
					for i = upper_region, lower_region do
						local nid = arena.player_nids[i];
						if(nid and (tonumber(nid) or 1) > 0) then
							local player = Player.GetPlayerCombatObj(nid)
							if(player and player:IsCombatActive()) then
								combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, pickcard_respond);
							end
						end
					end
				end
			end
		end
	end
end

-- pick AI card for player
-- @param nid: player nid
function Arena.OnReponse_PickAICardForPlayer(nid, bSkipCostAICardPill, seq)
	--log("Arena.OnReponse_PickAICardForPlayer=========\n")
	--commonlib.echo({nid, seq})
	local player = Player.GetPlayerCombatObj(nid);
	if(player) then
		local arena_id = player.arena_id;
		if(arena_id) then
			LOG.std(nil, "user", "arena", "arena_id=%d|OnReponse_PickAICardForPlayer %s", arena_id, tostring(nid));
			local arena = Arena.GetArenaByID(arena_id)
			-- we only open ai card picking for pve arena
			if(arena and arena.seq == seq) then
				arena:DebugDumpData("------------------ begin PickAICardForPlayer ------------------ "..tostring(nid));

				local friendly_isfarside, hostile_isfarside = false, true;
				if(player.side == "near") then
					friendly_isfarside, hostile_isfarside = false, true;
				elseif(player.side == "far") then
					friendly_isfarside, hostile_isfarside = true, false;
				end
				
				local friendlys, hostiles = arena:GetFriendlyAndHostileUnits(player.side);

				-- get card at hand
				-- show the user with available cards at hand
				local cards_at_hand = player:GetCardsInHand();
				local card_key = nil;
				local picked_card_heal = nil;
				local picked_card_heal_seq = nil;
				local picked_card_heal_weight = -1;
				local picked_card = nil;
				local picked_card_seq = nil;
				local picked_card_weight = 0;
				local picked_card_buff = nil;
				local picked_card_buff_seq = nil;
				local picked_card_buff_count = 0;
				local picked_card_debuff = nil;
				local picked_card_debuff_seq = nil;
				local picked_card_debuff_count = 0;
				local picked_card_maxpip = nil;
				local picked_card_maxpip_seq = nil;
				local picked_card_maxpip_weight = -1;
				local picked_card_prior_areaattack = nil;
				local picked_card_prior_areaattack_seq = nil;
				local picked_card_prior_areaattack_weight = 0;

				local _, each_card;
				for _, each_card in ipairs(cards_at_hand) do
					local card_key = each_card.key;
					local card_key_lower = string.lower(card_key);
					local cardTemplate = Card.GetCardTemplate(card_key);
					local bForbidden = false;
					if(arena.mode == "free_pvp" and pvp_forbidden_keys[card_key]) then
						bForbidden = true;
					end
					if(arena.mode == "pve" and arena.isinstance == true and instance_forbidden_keys[card_key]) then
						bForbidden = true;
					end
					if(cardTemplate and not bForbidden) then
						if(string.find(card_key_lower, "attack") or 
							string.find(card_key_lower, "heal") or 
							string.find(card_key_lower, "absorb") or 
							string.find(card_key_lower, "blade") or 
							string.find(card_key_lower, "shield") or 
							string.find(card_key_lower, "weakness") or 
							string.find(card_key_lower, "trap")) then
							-- only check cards that are in the ai template
							local pip_count = cardTemplate.pipcost;
							-- this is an x pip cost, cost as much as possible
							if(pip_count >= 0) then
							elseif(pip_count < 0) then
								pip_count = -pip_count;
								--local pips_normal = player:GetPipsCount();
								--local pips_power = player:GetPowerPipsCount();
							end
							-- mark the max pip cost card and weith
							if(pip_count > picked_card_maxpip_weight) then
								if(string.find(card_key_lower, "attack")) then
									if(player:CanCastSpell(card_key)) then
										picked_card_maxpip = card_key;
										picked_card_maxpip_seq = each_card.seq;
										picked_card_maxpip_weight = pip_count;
									end
								end
							end
							-- mark the max pip cost heal card and weith
							if((pip_count > 0) and (pip_count > picked_card_heal_weight)) then
								if(string.find(card_key_lower, "heal") or string.find(card_key_lower, "absorb")) then
									if(player:CanCastSpell(card_key)) then
										picked_card_heal = card_key;
										picked_card_heal_seq = each_card.seq;
										picked_card_heal_weight = pip_count;
									end
								end
							end
							
							-- mark the prior card keys
							if(prior_auto_ai_card_lower_areaattack_weight[card_key_lower] and string.find(card_key_lower, "attack")) then
								if(player:CanCastSpell(card_key)) then
									if(prior_auto_ai_card_lower_areaattack_weight[card_key_lower] > picked_card_prior_areaattack_weight) then
										picked_card_prior_areaattack = card_key;
										picked_card_prior_areaattack_seq = each_card.seq;
										picked_card_prior_areaattack_weight = prior_auto_ai_card_lower_areaattack_weight[card_key_lower];
									end
								end
							end

							-- parse zero pip and 4 pip card
							local optimum_pips = 4;
							if(player:GetPetLevel() >= 10 and string.lower(player:GetPhase()) == "death" and player:GetPetLevel() < 16) then
								optimum_pips = 3;
							elseif(player:GetPetLevel() >= 10 and string.lower(player:GetPhase()) ~= "death" and player:GetPetLevel() < 22) then
								optimum_pips = 3;
							elseif(player:GetPetLevel() >= 5 and player:GetPetLevel() < 10) then
								optimum_pips = 2;
							elseif(player:GetPetLevel() < 5) then
								optimum_pips = 1;
							end
							if(pip_count >= 4 and string.find(card_key_lower, "attack")) then
								if(player:CanCastSpell(card_key)) then
									if(pip_count >= 14) then
										-- x pip card, count the real pip count
										pip_count = player:GetPipsCount() + player:GetPowerPipsCount() * 2;
									end
									if(pip_count > picked_card_weight) then
										-- mark the ai card and weith
										picked_card = card_key;
										picked_card_seq = each_card.seq;
										picked_card_weight = pip_count;
									end
								end
							else
								if(string.find(card_key_lower, "blade") or string.find(card_key_lower, "shield") or string.find(card_key_lower, "stunabsorb")) then
									if(player:CanCastSpell(card_key)) then
										-- pick random buff
										picked_card_buff_count = picked_card_buff_count + 1;
										if(100 >= math.random(0, picked_card_buff_count * 100)) then
											picked_card_buff = card_key;
											picked_card_buff_seq = each_card.seq;
										end
									end
								elseif(string.find(card_key_lower, "weakness") or string.find(card_key_lower, "trap")) then
									if(player:CanCastSpell(card_key)) then
										-- pick random debuff
										picked_card_debuff_count = picked_card_debuff_count + 1;
										if(100 >= math.random(0, picked_card_debuff_count * 100)) then
											picked_card_debuff = card_key;
											picked_card_debuff_seq = each_card.seq;
										end
									end
								end
							end
						else
							Arena.OnReponse_DiscardCardByPlayer(nid, seq, card_key, each_card.seq)
						end
					end
				end
				
				local first_alive_mob_id = nil;
				-- get first mob
				local id;
				for _, id in ipairs(arena.mob_ids) do
					local mob = Mob.GetMobByID(id);
					if(mob:IsAlive()) then
						first_alive_mob_id = id;
						break;
					end
				end

				local first_alive_hostile_ismob = nil;
				local first_alive_hostile_id = nil;

				local _, unit;
				for _, unit in ipairs(hostiles) do
					local unit_obj = Arena.GetCombatUnit(unit.isMob, unit.id)
					if(unit_obj and unit_obj:IsAlive()) then
						first_alive_hostile_ismob = unit.isMob;
						first_alive_hostile_id = unit.id;
						break;
					end
				end
				
				LOG.std(nil, "user", "arena", "arena_id=%d|OnReponse_PickAICardForPlayer ai key marker %s", arena_id, nid, 
					commonlib.serialize({
						picked_card_heal,
						picked_card,
						picked_card_buff,
						picked_card_debuff,
						picked_card_maxpip,
					}));

				local bHasCostAICardPill_original = player.bHasCostAICardPill;
				
				local current_hp = player:GetCurrentHP();
				local max_hp = player:GetMaxHP();
				if(max_hp == 0) then
					max_hp = 1;
				end
				
				if(picked_card_prior_areaattack and picked_card_prior_areaattack_seq and System.options.version == "kids") then
					-- try 0: prior area attack card
					player.bHasCostAICardPill = true;
					Arena.OnReponse_PickCardByPlayer(nid, seq, picked_card_prior_areaattack, picked_card_prior_areaattack_seq, first_alive_hostile_ismob, first_alive_hostile_id, true);
				elseif(picked_card_heal and ((current_hp / max_hp) < 0.5)) then
					-- try 1: heal self with max pip heal or absorb if below half hp
					player.bHasCostAICardPill = true;
					Arena.OnReponse_PickCardByPlayer(nid, seq, picked_card_heal, picked_card_heal_seq, false, player:GetID(), true);
				elseif(picked_card) then
					-- try 2: attack with best optimum attack card
					player.bHasCostAICardPill = true;
					Arena.OnReponse_PickCardByPlayer(nid, seq, picked_card, picked_card_seq, first_alive_hostile_ismob, first_alive_hostile_id, true);
				elseif(picked_card_buff) then
					-- try 3: buff self if available
					player.bHasCostAICardPill = true;
					Arena.OnReponse_PickCardByPlayer(nid, seq, picked_card_buff, picked_card_buff_seq, false, player:GetID(), true);
				elseif(picked_card_debuff and first_alive_mob_id) then
					-- try 4: debuff mob if available
					player.bHasCostAICardPill = true;
					Arena.OnReponse_PickCardByPlayer(nid, seq, picked_card_debuff, picked_card_debuff_seq, first_alive_hostile_ismob, first_alive_hostile_id, true);
				elseif(picked_card_maxpip) then
					-- try 5: try max pip spell
					local picked_card_maxpip_lower = string.lower(picked_card_maxpip);
					-- pay attension to the order: e.x. stunabsorb
					if(string.find(picked_card_maxpip_lower, "attack")) then
						player.bHasCostAICardPill = true;
						Arena.OnReponse_PickCardByPlayer(nid, seq, picked_card_maxpip, picked_card_maxpip_seq, first_alive_hostile_ismob, first_alive_hostile_id, true);
					else
						-- pick default card
						Arena.OnReponse_PickCardByPlayer(nid, seq, "Pass", 0, false, player:GetID(), true);
					end
				else
					-- pick default card if alive
					if(player:IsAlive()) then
						Arena.OnReponse_PickCardByPlayer(nid, seq, "Pass", 0, false, player:GetID(), true);
					end
				end

				if(not bHasCostAICardPill_original and player.bHasCostAICardPill) then
					if(bSkipCostAICardPill) then
						player.bHasCostAICardPill = true;
						combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "SkipCostAutomaticAICombatPill:1");
					else
						-- cost the ai card pill
						-- 12007_AutomaticCombatPills
						local bHas, guid, bag, copies = PowerItemManager.IfOwnGSItem(nid, 12007);
						if(bHas == true) then
							local pill_guid = {[guid] = 1};
							PowerItemManager.DestroyItemBatch(nid, pill_guid, function(msg)
								combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "CostAutomaticAICombatPill:1");
							end);
						end
					end
				end

				arena:DebugDumpData("------------------ end PickAICardForPlayer ------------------");
			end
		end
	end
end

-- cancel card by player
-- @param nid: player nid
function Arena.OnReponse_CancelPickCardByPlayer(nid, seq)
	--log("Arena.OnReponse_PickCardByPlayer=========\n")
	--commonlib.echo({nid, seq, card_key, isMob, id})
	local player = Player.GetPlayerCombatObj(nid);
	if(player and player:IsCombatActive()) then -- must be combat active to cancel pick card
		local arena_id = player.arena_id;
		if(arena_id) then
			LOG.std(nil, "user", "arena", "arena_id=%d|OnReponse_CancelPickCardByPlayer %s", arena_id, tostring(nid));
			local arena = Arena.GetArenaByID(arena_id)
			if(arena and arena.seq == seq) then
				arena:DebugDumpData("------------------ begin OnReponse_CancelPickCardByPlayer ------------------ "..tostring(nid));
				-- clear picked card
				player:ClearPickedCard()
				-- respond to clients for team member card pick status
				local target_slotid = 0;
				local unit = Arena.GetCombatUnit(isMob, id)
				if(unit) then
					target_slotid = unit:GetArrowPosition_id()
				end
				local pickcard_respond = format("BuddyPickCard:%s,%d,%s,%d,false", 
					tostring(player:GetID()),
					player:GetArrowPosition_id(),
					"empty",
					"0"
				);
				-- send this pickcard respond to each member of the active team member
				local i;
				for i = 1, max_player_count_per_arena do
					local nid = arena.player_nids[i];
					if(nid and (nid == "localuser" or nid > 0)) then
						local player = Player.GetPlayerCombatObj(nid)
						if(player and player:IsCombatActive()) then
							combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, pickcard_respond);
						end
					end
				end
				-- inform waiting
				if(arena.PickCardTimeOutTime) then
					local remaining_time = arena.PickCardTimeOutTime - combat_server.GetCurrentTime();
					if(remaining_time > 0) then
						-- show the user with available cards at hand
						local cards_at_hand, runes_at_hand, followpetcards_at_hand = player:GetCardsInHand();
						local cards_at_hand_str = "";
						local runes_at_hand_str = "";
						local followpetcards_at_hand_str = "";
						local followpet_history_str = "";
						local guid, _;
						for guid, _ in ipairs(player.followpet_history) do
							followpet_history_str = followpet_history_str..guid..",";
						end
						local _, each_card;
						for _, each_card in ipairs(cards_at_hand) do
							local bCanCast = player:CanCastSpell(each_card.key);
							local cooldown = player:GetCoolDown(each_card.key);
							cards_at_hand_str = cards_at_hand_str..each_card.seq.."+"..tostring(bCanCast).."+"..cooldown.."+"..each_card.key.."+"..tostring(each_card.status)..",";
						end
						local _, each_card;
						for _, each_card in ipairs(followpetcards_at_hand) do
							local bCanCast = player:CanCastSpell(each_card.key, true);
							local cooldown = player:GetCoolDown(each_card.key);
							followpetcards_at_hand_str = followpetcards_at_hand_str..each_card.seq.."+"..tostring(bCanCast).."+"..cooldown.."+"..each_card.key..",";
						end
						local each_rune, __;
						for each_rune, __ in pairs(runes_at_hand) do
							local bCanCast = player:CanCastSpell(each_rune);
							local cooldown = player:GetCoolDown(each_rune);
							local count = 0;
							local gsid = Card.Get_rune_gsid_from_cardkey(each_rune);
							if(gsid) then
								local bHas, _, __, copies = PowerItemManager.IfOwnGSItem(player:GetNID(), gsid);
								if(bHas and copies) then
									count = copies;
								else
									bCanCast = false;
								end
							end
							runes_at_hand_str = runes_at_hand_str..count.."+"..tostring(bCanCast).."+"..cooldown.."+"..each_rune..",";
						end
						-- pass 3.4: pick your card for alive players
						local nTimeRemaining = remaining_time;
						local friendly_unit_str = "";
						local hostile_unit_str = "";
						if(arena.mode == "pve") then
							friendly_unit_str = arena.nearside_active_unit_list_str;
							hostile_unit_str = arena.farside_active_unit_list_str;
						elseif(arena.mode == "free_pvp") then
							if(arena.currentPlayingSide == "near") then
								friendly_unit_str = arena.nearside_active_unit_list_str;
								hostile_unit_str = arena.farside_active_unit_list_str;
							elseif(arena.currentPlayingSide == "far") then
								hostile_unit_str = arena.nearside_active_unit_list_str;
								friendly_unit_str = arena.farside_active_unit_list_str;
							end
						end
						if(player:IsAlive()) then
							-- alive player
							local remaing_switching_followpet_count = player:GetRemainingSwitchFollowPetCount();
							local remaining_deck_count, total_deck_count = player:GetDeckRemainingAndTotalCount();
							local bMyFollowPetCombatMode = false;
							if(type(nid) == "number") then
								local player_followpet = Player.GetPlayerCombatObj(-nid);
								if(player_followpet and player_followpet.arena_id and player_followpet.arena_id == player.arena_id) then
									bMyFollowPetCombatMode = true;
								end
							end
							local response = format("%d,%d,%s,%d,%d,%d,%d,%s<%s><%s><%s><%s><%s><%s>", nTimeRemaining, arena.seq, arena.mode, arena:GetRoundTag(), remaining_deck_count, total_deck_count, remaing_switching_followpet_count, tostring(bMyFollowPetCombatMode), friendly_unit_str, hostile_unit_str, cards_at_hand_str, runes_at_hand_str, followpetcards_at_hand_str, followpet_history_str);
							combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "PickYourCard:"..response);
						else
							-- dead player
							local response = format("%d,%d,%s,%d,0,false<%s><%s><%s><%s><%s><%s>", nTimeRemaining, arena.seq, arena.mode, arena:GetRoundTag(), friendly_unit_str, hostile_unit_str, cards_at_hand_str, runes_at_hand_str, followpetcards_at_hand_str, followpet_history_str);
							combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "PickYourCard_dead:"..response);
						end
					end
				end
				arena:DebugDumpData("------------------ end OnReponse_CancelPickCardByPlayer ------------------");
			end
		end
	end
end

-- pick follow pet by player
-- @param nid: player nid
-- @param guid: follow pet guid
-- @param gsid: follow pet gsid
function Arena.OnReponse_PickPetByPlayer(nid, seq, guid, gsid)
	local bPickPetSuccess = false;
	local player = Player.GetPlayerCombatObj(nid);
	if(player) then
		local arena_id = player.arena_id;
		if(arena_id) then
			LOG.std(nil, "user", "arena", "arena_id=%d|OnReponse_PickPetByPlayer %s,%d,%d", arena_id, tostring(nid), guid, gsid);
			local arena = Arena.GetArenaByID(arena_id)
			if(arena and arena.seq == seq) then
				arena:DebugDumpData("------------------ begin OnReponse_PickPetByPlayer ------------------ "..tostring(nid).." "..tostring(guid).." "..tostring(gsid));
				
				if(System.options.version == "teen") then
					if(player:GetRemainingSwitchFollowPetCount() <= 0) then
						local realtime_msg = "exceed_max_switching_followpet_count:1";
						combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, realtime_msg);
						return;
					end
				end
				-- check for validity of the follow pet
				local pet_obj = PowerItemManager.GetItemByGUID(nid, guid);
				if(pet_obj and pet_obj.guid > 0 and pet_obj.GetCurLevelCards) then
					if(gsid == pet_obj.gsid) then
						local bVIPPet = false;
						local gsItem = PowerItemManager.GetGlobalStoreItemInMemory(pet_obj.gsid);
						if(gsItem and gsItem.template.stats[180]) then
							-- VIP pet
							bVIPPet = true;
						end

						if(not bVIPPet or PowerItemManager.IsVIP(nid)) then
							-- not picked before
							if(not player.followpet_history[guid]) then
								bPickPetSuccess = true;
								-- player pick card
								player:PickCard("PickPet", card_seq, false, guid);
								-- respond to clients for team member card pick status
								local target_slotid = player:GetArrowPosition_id();
								local pickcard_respond = format("BuddyPickCard:%s,%d,%s,%d,false", 
									tostring(player:GetID()),
									player:GetArrowPosition_id(),
									"PickPet",
									target_slotid
								);
								-- send this pickcard respond to each member of the active team member
								local upper_region = 1;
								local lower_region = max_unit_count_per_side_arena;
								if(player:GetSide() == "near") then
									upper_region = 1;
									lower_region = max_unit_count_per_side_arena;
								elseif(player:GetSide() == "far") then
									upper_region = max_unit_count_per_side_arena + 1;
									lower_region = max_unit_count_per_side_arena * 2;
								end
								local i;
								for i = upper_region, lower_region do
									local nid = arena.player_nids[i];
									if(nid) then
										local player = Player.GetPlayerCombatObj(nid)
										if(player and player:IsCombatActive()) then
											combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, pickcard_respond);
										end
									end
								end
								-- inform waiting
								if(arena.PickCardTimeOutTime) then
									local remaining_time = arena.PickCardTimeOutTime - combat_server.GetCurrentTime();
									if(remaining_time > 0) then
										local realtime_msg = format("PickYourCard_already:%d,%s,%d", remaining_time, arena.mode, arena:GetRoundTag());
										combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, realtime_msg);
									end
								end
							else
								local realtime_msg = "HasPickedThisPet_before:1";
								combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, realtime_msg);
							end
						else
							local realtime_msg = "ThisIsVIPPetAndYourNot:1";
							combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, realtime_msg);
						end
					end
				end
				-- repick your card
				if(bPickPetSuccess == false) then
					-- repick your card
					Arena.OnReponse_CancelPickCardByPlayer(nid, seq);
				end
				arena:DebugDumpData("------------------ end OnReponse_PickPetByPlayer ------------------");
			end
		end
	end
end

-- pick catch follow pet on target mob
-- @param nid: player nid
-- @param mob_id: mob id
function Arena.OnReponse_CatchPetOnTarget(nid, seq, mob_id)
	local player = Player.GetPlayerCombatObj(nid);
	if(player) then
		local arena_id = player.arena_id;
		if(arena_id) then
			LOG.std(nil, "user", "arena", "arena_id=%d|OnReponse_CatchPetOnTarget %s,%s", arena_id, tostring(nid), tostring(mob_id));
			local arena = Arena.GetArenaByID(arena_id)
			if(arena and arena.seq == seq) then
				arena:DebugDumpData("------------------ begin OnReponse_CatchPetOnTarget ------------------ "..tostring(nid).." "..tostring(mob_id));

				-- check validity of mob arena
				local mob = Mob.GetMobByID(mob_id);
				if(mob and mob:IsAlive() and mob.arena_id == arena_id) then
					local catch_pet_gsid = mob:GetStatByField("catch_pet");
					if(catch_pet_gsid) then
						catch_pet_gsid = tonumber(catch_pet_gsid);
					end
					if(catch_pet_gsid) then
						if(not mob.nid_catchpet) then
							local player_level = player:GetLevel();
							local mob_level = mob:GetLevel();
							if(player_level < mob_level and System.options.version == "teen") then
								local realtime_msg = "CatchPetHigherLevel:1";
								combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, realtime_msg);
								-- repick your card
								Arena.OnReponse_CancelPickCardByPlayer(nid, seq);
							else
								local bOwn, guid = PowerItemManager.IfOwnGSItem(nid, catch_pet_gsid);
								if(not bOwn) then
									-- player pick card
									player:PickCard("CatchPet", nil, true, mob_id);
									-- respond to clients for team member card pick status
									local target_slotid = 0;
									local unit = Arena.GetCombatUnit(true, mob_id);
									if(unit) then
										target_slotid = unit:GetArrowPosition_id()
									end
									local pickcard_respond = format("BuddyPickCard:%s,%d,%s,%d,false", 
										tostring(player:GetID()),
										player:GetArrowPosition_id(),
										"CatchPet",
										target_slotid
									);
									-- send this pickcard respond to each member of the active team member
									local upper_region = 1;
									local lower_region = max_unit_count_per_side_arena;
									if(player:GetSide() == "near") then
										upper_region = 1;
										lower_region = max_unit_count_per_side_arena;
									elseif(player:GetSide() == "far") then
										upper_region = max_unit_count_per_side_arena + 1;
										lower_region = max_unit_count_per_side_arena * 2;
									end
									local i;
									for i = upper_region, lower_region do
										local nid = arena.player_nids[i];
										if(nid) then
											local player = Player.GetPlayerCombatObj(nid)
											if(player and player:IsCombatActive()) then
												combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, pickcard_respond);
											end
										end
									end
									-- inform waiting
									if(arena.PickCardTimeOutTime) then
										local remaining_time = arena.PickCardTimeOutTime - combat_server.GetCurrentTime();
										if(remaining_time > 0) then
											local realtime_msg = format("PickYourCard_already:%d,%s,%d", remaining_time, arena.mode, arena:GetRoundTag());
											combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, realtime_msg);
										end
									end
								else
									local realtime_msg = "YouHaveAlreadyOwnThePet:1";
									combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, realtime_msg);
									-- repick your card
									Arena.OnReponse_CancelPickCardByPlayer(nid, seq);
								end
							end
						else
							local realtime_msg = "CatchPetAlreadyCaught:1";
							combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, realtime_msg);
							-- repick your card
							Arena.OnReponse_CancelPickCardByPlayer(nid, seq);
						end
					else
						local realtime_msg = "NotCatchablePetMob:1";
						combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, realtime_msg);
						-- repick your card
						Arena.OnReponse_CancelPickCardByPlayer(nid, seq);
					end
				else
					-- repick your card
					Arena.OnReponse_CancelPickCardByPlayer(nid, seq);
				end
				arena:DebugDumpData("------------------ end OnReponse_CatchPetOnTarget ------------------");
			end
		end
	end
end

-- discard card by player
-- @param nid: player nid
-- @param card_key: the card key to Cards and Spells
-- @param card_seq: card sequence in deck
function Arena.OnReponse_DiscardCardByPlayer(nid, seq, card_key, card_seq)
	local player = Player.GetPlayerCombatObj(nid);
	if(player) then
		local arena_id = player.arena_id;
		if(arena_id) then
			LOG.std(nil, "user", "arena", "arena_id=%d|OnReponse_DiscardCardByPlayer %s,%s,%d", arena_id, tostring(nid), card_key, card_seq);
			local arena = Arena.GetArenaByID(arena_id)
			if(arena and arena.seq == seq) then
				arena:DebugDumpData("------------------ begin OnReponse_DiscardCardByPlayer ------------------ "..tostring(nid).." "..tostring(card_key).." "..tostring(card_seq));
				-- check for validity of the caster and target
				if(not player:IfPickedCard()) then
					local bSuccessDiscarded = player:DiscardCard(card_key, card_seq)
					if(bSuccessDiscarded) then
						---- respond to clients for team member card pick status
						--local pickcard_respond = format("BuddyPickCard:%s,%d,%s,%d,false", 
							--tostring(player:GetID()),
							--player:GetArrowPosition_id(),
							--"empty",
							--0
						--);
						---- send this pickcard respond to each member of the active team member
						--local i;
						--for i = 1, max_player_count_per_arena do
							--local nid = arena.player_nids[i];
							--if(nid) then
								--local player = Player.GetPlayerCombatObj(nid)
								--if(player and player:IsCombatActive()) then
									--combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, pickcard_respond);
								--end
							--end
						--end
					end
				end
				arena:DebugDumpData("------------------ end OnReponse_DiscardCardByPlayer ------------------");
			end
		end
	end
end

-- restore discarded card by player
-- @param nid: player nid
-- @param card_key: the card key to Cards and Spells
-- @param card_seq: card sequence in deck
function Arena.OnReponse_RestoreDiscardedCardByPlayer(nid, seq, card_key, card_seq)
	local player = Player.GetPlayerCombatObj(nid);
	if(player) then
		local arena_id = player.arena_id;
		if(arena_id) then
			LOG.std(nil, "user", "arena", "arena_id=%d|OnReponse_DiscardCardByPlayer %s,%s,%d", arena_id, tostring(nid), card_key, card_seq);
			local arena = Arena.GetArenaByID(arena_id)
			if(arena and arena.seq == seq) then
				arena:DebugDumpData("------------------ begin OnReponse_DiscardCardByPlayer ------------------ "..tostring(nid).." "..tostring(card_key).." "..tostring(card_seq));
				-- check for validity of the caster and target
				if(not player:IfPickedCard()) then
					local bSuccessDiscarded = player:RestoreDiscardedCard(card_key, card_seq)
					if(bSuccessDiscarded) then
						---- respond to clients for team member card pick status
						--local pickcard_respond = format("BuddyPickCard:%s,%d,%s,%d,false", 
							--tostring(player:GetID()),
							--player:GetArrowPosition_id(),
							--"empty",
							--0
						--);
						---- send this pickcard respond to each member of the active team member
						--local i;
						--for i = 1, max_player_count_per_arena do
							--local nid = arena.player_nids[i];
							--if(nid) then
								--local player = Player.GetPlayerCombatObj(nid)
								--if(player and player:IsCombatActive()) then
									--combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, pickcard_respond);
								--end
							--end
						--end
					end
				end
				arena:DebugDumpData("------------------ end OnReponse_DiscardCardByPlayer ------------------");
			end
		end
	end
end

-- player finished play turn
function Arena.OnReponse_FinishPlayTurn(nid, seq)
	--log("Arena.OnReponse_FinishPlayTurn=========\n")
	--commonlib.echo({nid, seq})
	local arena_id=0;
	if(player) then
		arena_id = player.arena_id;
	end
	LOG.std(nil, "user","arena","arena_id=%d|FinishPlayTurn nid=%s,seq=%d",arena_id, tostring(nid), seq);
	local player = Player.GetPlayerCombatObj(nid);
	if(player) then
		local arena_id = player.arena_id;
		if(arena_id) then
			local arena = Arena.GetArenaByID(arena_id)
			if(arena and arena.seq == seq) then
				arena:DebugDumpData("------------------ begin FinishPlayTurn ------------------ "..tostring(nid));
				player:FinishPlayTurn();
				arena:DebugDumpData("------------------ end FinishPlayTurn ------------------");
			end
		end
	end
end

-- cancel my follow pet picked card
function Arena.OnReponse_CancelMyFollowPetPickedCard(nid, seq)
	--log("Arena.OnReponse_FinishPlayTurn=========\n")
	--commonlib.echo({nid, seq})
	local arena_id=0;
	if(player) then
		arena_id = player.arena_id;
	end
	LOG.std(nil, "user","arena","arena_id=%d|CancelMyFollowPetPickedCard nid=%s,seq=%d",arena_id, tostring(nid), seq);
	local player = Player.GetPlayerCombatObj(nid);
	if(player) then
		local arena_id = player.arena_id;
		if(arena_id) then
			local arena = Arena.GetArenaByID(arena_id)
			if(arena and arena.seq == seq) then
				arena:DebugDumpData("------------------ begin CancelMyFollowPetPickedCard ------------------ "..tostring(nid));
				Arena.OnReponse_PickCardByPlayer(-nid, seq, "Pass", 0, false, -nid);
				local player_followpet = Player.GetPlayerCombatObj(-nid);
				if(player_followpet) then
					-- increase current count for picked module
					local ai_module_index = player_followpet.ai_module_index;
					if(ai_module_index and player_followpet.ai_modules) then
						local picked_module = player_followpet.ai_modules[ai_module_index];
						if(picked_module and picked_module.count_cur) then
							picked_module.count_cur = picked_module.count_cur + 1;
						end
					end
				end
				arena:DebugDumpData("------------------ end CancelMyFollowPetPickedCard ------------------");
			end
		end
	end
end

-- switch my follow pet to combat mode
function Arena.OnReponse_OnFollowPet_FollowMode(nid, seq)
	local arena_id = 0;
	if(player) then
		arena_id = player.arena_id;
	end
	LOG.std(nil, "user","arena","arena_id=%d|%s OnReponse_OnFollowPet_FollowMode", arena_id, tostring(nid));
	local player = Player.GetPlayerCombatObj(nid);
	local player_followpet = Player.GetPlayerCombatObj(-nid);
	if(player and player_followpet) then
		local arena_id = player.arena_id;
		local arena_followpet = player_followpet.arena_id;
		if(arena_id and arena_followpet) then
			local arena = Arena.GetArenaByID(arena_id)
			if(arena) then
				if(arena.PickCardTimeOutTime and not arena.PlayTurnTimeOutTime) then
					arena:DebugDumpData("------------------ begin OnFollowPet_FollowMode ------------------ "..tostring(nid));
					arena:RemovePlayer(-nid, true); -- true for bSkipFleeSlot
					if(arena:IsPlayerSlotEmpty() and arena.mode == "pve") then
						if(arena.is_single_fight) then
							-- kill all
							arena:ResetAndKillAll_pve();
						else
							-- respawn all mobs in pve arena
							arena:RespawnAll_pve();
						end
					end
					if(arena:IsCombatFinished_v() and arena.mode == "free_pvp") then
						-- finish the combat
						arena:FinishCombat_v();
					end
					arena:DebugDumpData("------------------ end OnFollowPet_FollowMode ------------------");
					-- tell the hosting clients to update arena
					arena:UpdateToClient();
				elseif(not arena.PickCardTimeOutTime and not arena.PlayTurnTimeOutTime) then
					-- combat is not started yet
					arena:DebugDumpData("------------------ begin OnFollowPet_FollowMode 2 ------------------ "..tostring(nid));
					arena:RemovePlayer(-nid, true); -- true for bSkipFleeSlot
					if(arena:IsPlayerSlotEmpty() and arena.mode == "pve") then
						if(arena.is_single_fight) then
							-- kill all
							arena:ResetAndKillAll_pve();
						else
							-- respawn all mobs in pve arena
							arena:RespawnAll_pve();
						end
					end
					if(arena:IsPlayerSlotEmpty() and arena.mode == "free_pvp") then
						arena:Reset_pvp();
					end
					arena:DebugDumpData("------------------ end OnFollowPet_FollowMode 2 ------------------");
					-- tell the hosting clients to update arena
					arena:UpdateToClient();
				end
			end
		end
	end
	Arena.OnReponse_CancelPickCardByPlayer(nid, seq);
end

-- switch my follow pet to follow mode
function Arena.OnReponse_OnFollowPet_CombatMode(nid, seq)
	local arena_id = 0;
	if(player) then
		arena_id = player.arena_id;
	end
	LOG.std(nil, "user","arena","arena_id=%d|%s OnReponse_OnFollowPet_CombatMode", arena_id, tostring(nid));
	local player = Player.GetPlayerCombatObj(nid);
	local player_followpet = Player.GetPlayerCombatObj(-nid);
	if(player and not player_followpet) then
		local arena_id = player.arena_id;
		local followpet_guid = player.current_followpet_guid;
		if(arena_id and followpet_guid and followpet_guid > 0) then
			local arena = Arena.GetArenaByID(arena_id)
			if(arena) then
				if(player:IsFollowPetCombatModeInHistory(followpet_guid)) then
					combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "FollowPetBeenCombatBefore:");
					Arena.OnReponse_CancelPickCardByPlayer(nid, seq);
					return;
				end
				if(not arena.PlayTurnTimeOutTime) then
					arena:DebugDumpData("------------------ begin OnReponse_OnFollowPet_CombatMode ------------------ "..tostring(nid));

					local pet_obj = PowerItemManager.GetItemByGUID(nid, followpet_guid);
					if(pet_obj and pet_obj.guid > 0 and pet_obj.GetCurLevelCards and pet_obj.GetLevelsInfo and pet_obj.GetSchool and pet_obj.GetCurLevelAICards) then
						local level = 50;
						-- create default minion
						local followpet_params = GetBasePlayerParam();
						followpet_params.is_minion = true;
						followpet_params.nid = -nid;
						followpet_params.current_hp = 100;
						followpet_params.max_hp = 100;
						followpet_params.petlevel = level;
						followpet_params.equips = {};
						-- follow pet guid
						followpet_params.current_followpet_guid = followpet_guid;
						local level_info = pet_obj:GetLevelsInfo(true);
						if(level_info and level_info.cur_level) then
							followpet_params.petlevel = level_info.cur_level;
						end
						-- school
						local school_short_gsid = pet_obj:GetSchool(true);
						if(school_short_gsid == 6) then
							followpet_params.phase = "fire";
						elseif(school_short_gsid == 7) then
							followpet_params.phase = "ice";
						elseif(school_short_gsid == 8) then
							followpet_params.phase = "storm";
						elseif(school_short_gsid == 9) then
							followpet_params.phase = "myth";
						elseif(school_short_gsid == 10) then
							followpet_params.phase = "life";
						elseif(school_short_gsid == 11) then
							followpet_params.phase = "death";
						elseif(school_short_gsid == 12) then
							followpet_params.phase = "balance";
						end
						-- get AI cards
						local ai_cards = pet_obj:GetCurLevelAICards();
						--return 实体卡片 cur_entity_cards_list ={ {gsid = gsid, ai_key = ai_key}, {gsid = gsid, ai_key = ai_key}, }
						if(ai_cards) then
							followpet_params.ai_modules = {};
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
									table.insert(followpet_params.ai_modules, ai_module);
								end
							end
						end

						-- incombat follow pet
						local minion = Player:new(followpet_params);
						local isSuccess, reason = arena:AddFollowPetMinion_pve(minion);
						if(isSuccess) then
							-- mark follow pet combat mode history
							player:MarkFollowPetCombatModeHistory(followpet_guid);
							local max_hp_system = minion:GetUpdatedMaxHP();
							if(max_hp_system) then
								minion.current_hp = max_hp_system;
								minion.max_hp = max_hp_system;
							end
						end
					end
					if(arena:IsPlayerSlotEmpty() and arena.mode == "pve") then
						if(arena.is_single_fight) then
							-- kill all
							arena:ResetAndKillAll_pve();
						else
							-- respawn all mobs in pve arena
							arena:RespawnAll_pve();
						end
					end
					if(arena:IsCombatFinished_v() and arena.mode == "free_pvp") then
						-- finish the combat
						arena:FinishCombat_v();
					end
					arena:DebugDumpData("------------------ end OnReponse_OnFollowPet_CombatMode ------------------");
					-- tell the hosting clients to update arena
					arena:UpdateToClient();
				end
			end
		end
	end
	Arena.OnReponse_CancelPickCardByPlayer(nid, seq);
end

-- unlock arena
function Arena.OnReponse_UnlockArena(nid, arena_id)
	local locked_arena = Arena.GetArenaByID(arena_id);
	if(System.options.version == "kids" and locked_arena and locked_arena.mode == "pve") then
		local can_refresh_with_gsid = locked_arena.can_refresh_with_gsid;
		if(locked_arena.arena_key_rules and can_refresh_with_gsid) then
			-- check if with any player
			local isWithAnyPlayer = false;
			local _, __;
			for _, __ in pairs(locked_arena.player_nids) do
				isWithAnyPlayer = true;
				break;
			end
			-- check if all mob dead
			local isWithAnyAliveMob = false;
			local index, id;
			for index, id in ipairs(locked_arena.mob_ids) do
				local mob = Mob.GetMobByID(id);
				if(mob and mob:IsAlive()) then
					isWithAnyAliveMob = true;
					break;
				end
			end
			if(isWithAnyAliveMob == false and isWithAnyPlayer == false) then
				--can_refresh_with_gsid
				PowerItemManager.ChangeItem(nid, format("%d~-1~NULL~NULL|", can_refresh_with_gsid), nil, function(msg)
					if(msg and msg.issuccess) then
						local locked_arena = Arena.GetArenaByID(arena_id)
						if(locked_arena and locked_arena.mode == "pve") then
							locked_arena:RespawnAll_pve();
							combat_server.AppendRealTimeMessageToNID(locked_arena.combat_server_uid, nid, "UnlockingArena:1");
						end
					end
				end, false, format("%d~1|", can_refresh_with_gsid))
			end
		end
	end
end

-- request additional loot
function Arena.OnReponse_RequestAdditionalLoot(nid, arena_id, type)
	local arena = Arena.GetArenaByID(arena_id);
	if(nid and arena and arena.last_gained_reward_nids_and_counts and arena.stamina_cost) then
		local stamina_cost = arena.stamina_cost;
		local count = arena.last_gained_reward_nids_and_counts[nid];
		if(count and count > 0) then
			-- sync user and dragon info
			PowerItemManager.GetUserAndDragonInfo(nid, function(msg)
				if(msg and msg.issuccess_webapi) then
					-- check stamina
					local userdragoninfo = PowerItemManager.GetUserAndDragonInfoInMemory(nid);
					if(userdragoninfo and userdragoninfo.dragon.stamina) then
						if(userdragoninfo.dragon.stamina < stamina_cost) then
							-- insufficient stamina
							combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "InsufficientStaminaForAddtionalLoot:1");
							return;
						end
					end
					local pres_str = format("-19~%d|", stamina_cost);
					local adds_str;
					-- check key
					if(type == "Plain") then
						-- pres string
						-- pres GSID不能为负数
						--pres_str = format("-19~%d|", stamina_cost);
						pres_str = nil;
						-- calculate additional loot
						adds_str = format("-19~-%d~NULL~NULL|", stamina_cost);
					elseif(type == "Adv") then
						-- pres string
						-- pres GSID不能为负数
						--pres_str = format("-19~%d|12059~1|", stamina_cost);
						pres_str = format("12059~1|");
						-- calculate additional loot
						adds_str = format("-19~-%d~NULL~NULL|12059~-1~NULL~NULL|", stamina_cost);
						-- check key
						if(not PowerItemManager.IfOwnGSItem(nid, 12059)) then
							-- insufficient key
							combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "InsufficientKeyForAddtionalLoot:1");
							return;
						end
					end
					-- process additional loot
					if(adds_str) then
						-- arena mobs loots
						local total_loots = {};
						local appended_singleton_gsids = {};
						local _, id;
						for _, id in ipairs(arena.mob_ids) do
							local mob = Mob.GetMobByID(id);
							if(mob) then
								local school = PowerItemManager.GetUserSchool(nid) or "unknown";
								local level = PowerItemManager.GetUserCombatLevel(nid) or 1;
								local loots = mob:GetLoot(nil, 1, nid, school, level);
								local _, gsid;
								for _, gsid in pairs(loots) do
									-- NOTE: 8999 is the largest available equip items
									-- 10101 ~ 10999  follow pet
									if(gsid and ((gsid >= 1001 and gsid < 8999) or (gsid >= 10101 and gsid < 10999))) then
										-- NOTE: since the bags_live_update includes both bag 0 and bag 1, if item is an equipment, don't loot if exist
										-- NOTE: since the bags_live_update includes both bag 0 and bag 10010, if item is a follow pet, don't loot if exist
										if(not PowerItemManager.IfOwnGSItem(nid, gsid) and not appended_singleton_gsids[gsid]) then
											total_loots[gsid] = (total_loots[gsid] or 0) + 1;
											appended_singleton_gsids[gsid] = true;
										end
									elseif(gsid) then
										total_loots[gsid] = (total_loots[gsid] or 0) + 1;
									end
								end
							end
						end
						local gsid, count;
						for gsid, count in pairs(total_loots) do
							if(type == "Plain" and PlainAdditionalLootWhiteList[gsid]) then
								adds_str = adds_str .. format("%d~%d~NULL~NULL~1|", gsid, count);
							elseif(type == "Adv") then
								adds_str = adds_str .. format("%d~%d~NULL~NULL~1|", gsid, count);
							end
						end
						PowerItemManager.ChangeItem(nid, adds_str, nil, function(msg)
							if(msg and msg.issuccess) then
								local obtains = {};
					
								Arena.GetObtainsFromMSG(msg, nid, obtains);

								obtains[0] = nil;
					
								local real_gained_loot = "";
								local gsid, cnt;
								for gsid, cnt in pairs(obtains) do
									real_gained_loot = real_gained_loot..gsid..","..cnt.."+";
								end

								local full_loot_str = string.format("%s~%s~%s~%d~%d~%f~%d~%d~%s~%s~%d", 
									tostring(arena:GetID()), arena.mode, tostring(nid), 0, 0, 1, 0, 0, "nil", real_gained_loot, 1);

								local remaining_count = 0;
								if(arena and arena.last_gained_reward_nids_and_counts) then
									remaining_count = arena.last_gained_reward_nids_and_counts[nid];
								end

								combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "MyGainedAdditionalLoots:"..type..","..remaining_count.."["..full_loot_str.."]");
							end
						end, false, pres_str);
					end
				end
			end);
			-- mark reward cost
			arena.last_gained_reward_nids_and_counts[nid] = count - 1;
		end
	end
end

-- try flee from combat
-- NOTE: only waiting for card process can accept flee operation
function Arena.OnReponse_TryFleeCombat(nid, bSkipMessage)
	--log("Arena.OnReponse_TryFleeCombat=========\n")
	--commonlib.echo(nid)
	if(not nid or (tonumber(nid) or 0) < 0) then
		LOG.std(nil, "error", "arena_server", "Arena.OnReponse_TryFleeCombat got invalid input: "..commonlib.serialize({nid}));
		return;
	end
	local arena_id=0;
	if(player) then
		arena_id = player.arena_id;
	end
	LOG.std(nil, "user","arena","arena_id=%d|%s TryFleeCombat", arena_id, tostring(nid));
	local player = Player.GetPlayerCombatObj(nid);
	if(player) then
		local arena_id = player.arena_id;
		if(arena_id) then
			local arena = Arena.GetArenaByID(arena_id)
			if(arena) then
				if(arena.PickCardTimeOutTime and not arena.PlayTurnTimeOutTime) then
					arena:DebugDumpData("------------------ begin TryFleeCombat ------------------ "..tostring(nid));

					local least_round_number_for_award,least_card_number_for_award;
					local spendRounds = 0;
					local used_card_count = 0;
					
					--local BeAwarded = if_else(used_card_count >= least_card_number_for_award, true, false);
					local BeAwarded = true;
					if(System.options.version == "teen") then
						BeAwarded = true;
					elseif(System.options.version == "kids" and arena.mode == "free_pvp") then
						least_round_number_for_award = arena.least_round_number_for_award;
						if(arena.nRemainingRounds and arena.nRemainingRounds > 0) then
							if(arena.is_battlefield) then
								spendRounds = math.floor((MAX_ROUNDS_PVP_ARENA_BATTLEFIELD - arena.nRemainingRounds) / 2);
							else
								spendRounds = math.floor((MAX_ROUNDS_PVP_ARENA - arena.nRemainingRounds) / 2);
							end
						else
							spendRounds = 0;
						end
						

						least_card_number_for_award = arena.least_card_number_for_award;
						local history = player:GetCardHistory();
						if(history) then
							local _, played_card;
							for _, played_card in pairs(history) do
								used_card_count = used_card_count + 1;
							end
						end

						if(used_card_count < least_card_number_for_award and spendRounds < least_round_number_for_award) then
							BeAwarded = false;
						else
							BeAwarded = true;
						end

						if(arena.mode == "free_pvp" and arena.ranking_stage) then
							if(string.match(arena.ranking_stage,"1v1")) then
								BeAwarded = true;
							end
						else
							BeAwarded = true;
						end
					end

					local player_lose_ranking_point_gsid = player.lose_ranking_point_gsid;
					local player_lose_ranking_point_count = player.lose_ranking_point_count;
					arena:RemovePlayerAndFollowPet(nid);
					if(arena:IsPlayerSlotEmpty() and arena.mode == "pve") then
						if(arena.is_single_fight) then
							-- kill all
							arena:ResetAndKillAll_pve();
						else
							-- respawn all mobs in pve arena
							arena:RespawnAll_pve();
						end
					end
					if(arena:IsCombatFinished_v() and arena.mode == "free_pvp") then
						-- finish the combat
						arena:FinishCombat_v();
					end
					local loots = arena.flee_loots;
					
					-- ranking points
					if(arena.ranking_stage) then
						-- a loots copy
						loots = commonlib.deepcopy(loots) or {};

						if(player_lose_ranking_point_gsid and player_lose_ranking_point_count) then
							loots[player_lose_ranking_point_gsid] = player:GetRankingLoot(false);
							
							-- ranking stage post log
							combat_server.AppendPostLog( {
								action = "pvp_arena_ranking_point_log", 
								gsid = player_lose_ranking_point_gsid, 
								count = player_lose_ranking_point_count,
								nid = nid,
								reason = "flee",
								nRemainingRounds = arena.nRemainingRounds,
								ranking_stage = arena.ranking_stage,
								ranking_info = arena.RankingInfo_str,
								isNearArenaFirst = tostring(arena.isNearArenaFirst),
							});
							
							-- send pvp ranking point info to lobby
							Map3DSystem.GSL.system:SendToLobbyServer({
								type = "pvp_arena_ranking_point_change",
								user_nid = 0,
								msg = {
									gsid = player_lose_ranking_point_gsid, 
									count = player_lose_ranking_point_count,
									nid = nid,
									reason = "flee",
								},
							});
						end
					end
					--echo(BeAwarded);
					if(System.options.version == "kids" and arena.ranking_stage and string.match(arena.ranking_stage,"3v3")) then
						local count;
						if(player.afk) then
							local bHas, _, _, copies = PowerItemManager.IfOwnGSItem(nid, 20091);
							if(not bHas) then
								copies = 0;
							elseif(copies) then
								if(copies >= 200) then
									copies = 200;
								end
							end
							count = copies;
						else
							count = 100;
						end
						if(count > 0) then
							local adds_str = format("%d~%d~%s~%s|", 20091, -count, "NULL", "NULL");
							PowerItemManager.ChangeItem(nid, adds_str, nil, function(msg)
								if(msg.issuccess) then
									LOG.std(nil, "debug", "PowerExtendedCost", "%d Flee from 3v3 combat to deduct score：%d", nid, count);
									if(arena.ranking_stage) then
										player:SubmitScore(arena.ranking_stage);
									end
								else
									LOG.std(nil, "debug", "PowerExtendedCost", "%d Flee from 3v3 combat to deduct score,callback function got error msg:%s", nid, commonlib.serialize_compact(msg));
								end
								-- some handler
							end, true, nil, true); -- greedy mode
						end
					elseif(loots and BeAwarded) then
						PowerItemManager.AddExpJoybeanLoots(nid, nil, nil, loots, function(msg) 
							if(arena.ranking_stage) then
								player:SubmitScore(arena.ranking_stage);
							end

							--[[
							if(System.options.version == "kids") then
								if(arena.ranking_stage) then
									if(string.match(arena.ranking_stage,"1v1") or string.match(arena.ranking_stage,"3v3")) then
										local obtains = {};
										
										arena.GetObtainsFromMSG(msg, nid, obtains);

										obtains[0] = nil;
					
										local real_gained_loot = "";
										local gsid, cnt;
										for gsid, cnt in pairs(obtains) do
											real_gained_loot = real_gained_loot..gsid..","..cnt.."+";
										end

										local isWinner = "false";
										--echo("22222222222222");
							
										local full_loot_str = string.format("%s~%s~%s~%d~%d~%f~%d~%d~%s~%s~%d", 
											tostring(arena:GetID()), arena.mode, tostring(nid), 0, 0, 1, 0, 0, isWinner, real_gained_loot, player.loot_scale);

										combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "MyGainedLoots:"..full_loot_str);
										combat_server.AppendRealTimeMessage(arena.combat_server_uid, "BuddyGainedLoots:"..full_loot_str);
									end
								end
								
							end
							--]]

						end);
					end
					
					arena:DebugDumpData("------------------ end TryFleeCombat ------------------");
					-- tell the hosting clients to update arena
					arena:UpdateToClient();
					-- if the arena is full, player can't join fight
					if(not bSkipMessage) then
						combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "FleeFromArena:"..arena.mode);
						if(System.options.version == "kids" and arena.ranking_stage and string.match(arena.ranking_stage,"3v3")) then
							if(player.afk) then
								if(player:HasReachMaxIdleRounds()) then
									local maxIdleRounds = player:GetMaxIdleRounds();
									combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "DeductScoreForIdleRounds:"..tostring(maxIdleRounds));
								elseif(player:HasReachMaxAccumulateIdleRounds()) then
									local maxAccumulateIdleRounds = player:GetMaxAccumulateIdleRounds();
									combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "DeductScoreForAccumulateIdleRounds:"..tostring(maxAccumulateIdleRounds));
								end	
							else
								combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "DeductScoreForFlee3v3:");
							end
						else
							if(not BeAwarded) then
								combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "NotUseEnoughCardAndRound:"..tostring(least_card_number_for_award).."%"..tostring(least_round_number_for_award));
							end
						end
					end
					-- process durability
					local durable_items = player.current_combat_durable_items;
					if(durable_items and arena.mode == "pve") then
						-- only cost durability on player dead
						local self_combat_server_uid = arena.combat_server_uid;
						PowerItemManager.CostDurablity(nid, durable_items, true, function()
							combat_server.AppendRealTimeMessageToNID(self_combat_server_uid, nid, "UpdateEquipBags:1");
						end);
					end
				elseif(not arena.PickCardTimeOutTime and not arena.PlayTurnTimeOutTime) then
					-- combat is not started yet
					arena:DebugDumpData("------------------ begin TryFleeCombat 2 ------------------ "..tostring(nid));
					arena:RemovePlayerAndFollowPet(nid);
					if(arena:IsPlayerSlotEmpty() and arena.mode == "pve") then
						if(arena.is_single_fight) then
							-- kill all
							arena:ResetAndKillAll_pve();
						else
							-- respawn all mobs in pve arena
							arena:RespawnAll_pve();
						end
					end
					if(arena:IsPlayerSlotEmpty() and arena.mode == "free_pvp") then
						arena:Reset_pvp();
					end
					arena:DebugDumpData("------------------ end TryFleeCombat 2 ------------------");
					-- tell the hosting clients to update arena
					arena:UpdateToClient();
					-- if the arena is full, player can't join fight
					if(not bSkipMessage) then
						combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "FleeFromArena:"..arena.mode);
					end
					-- process durability
					local durable_items = player.current_combat_durable_items;
					if(durable_items and arena.mode == "pve") then
						-- only cost durability on player dead
						local self_combat_server_uid = arena.combat_server_uid;
						PowerItemManager.CostDurablity(nid, durable_items, true, function()
							combat_server.AppendRealTimeMessageToNID(self_combat_server_uid, nid, "UpdateEquipBags:1");
						end);
					end
				end
			end
		end
	end
end

-- heart beat from client
function Arena.OnReponse_HeartBeat(nid)
	--log("Arena.OnReponse_HeartBeat========= "..tostring(nid).."\n");
	LOG.std(nil, "user","arena","heartbeat:%s",nid);
	local player = Player.GetPlayerCombatObj(nid);
	if(player) then
		player:OnHeartBeat();
	end
end

local function GetRandomLevel1GemGSID()
	local rr = math.random(0, 1799);
	local i = math_floor(rr / 100);
	return (26000 + 1 + i * 5);
end

function Arena.OnReponse_IWannaLootTreasureBox(nid, arena_id)
	if(not nid or not arena_id) then
		LOG.std(nil, "error", "arena_server", "Arena.OnReponse_IWannaLootTreasureBox got invalid input: "..commonlib.serialize({nid, arena_id}));
		return;
	end
	LOG.std(nil, "user","arena","arena_id=%d|IWannaLootTreasureBox nid=%s,arena_id=%d", arena_id, tostring(nid), arena_id);
	local arena = Arena.GetArenaByID(arena_id)
	if(arena) then
		arena:DebugDumpData("------------------ begin IWannaLootTreasureBox ------------------ "..tostring(nid));

		if(arena.treasurebox) then
			if(arena.treasurebox.lootable_nids) then
				if(arena.treasurebox.lootable_nids[nid]) then
					
					if(arena.treasurebox.loot_id == "Global_CatTreasureHouse_Adv" and System.options.version == "kids") then
						arena.treasurebox.lootable_nids[nid] = false;
						combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "TreasureBoxResponse_GoExtendedcost:"..arena.treasurebox.loot_id);
						return;
					end
					
					-- generate loot
					local loot_gsid;
					if(arena.treasurebox.loot_id == "FireCavern" and System.options.version == "kids") then
						local r = math.random(0, 1000);
						if(r <= 200) then
							loot_gsid = 17121;
						elseif(r <= (200 + 50)) then
							loot_gsid = 17122;
						elseif(r <= (200 + 50 + 200)) then
							loot_gsid = 17131;
						elseif(r <= (200 + 50 + 200 + 50)) then
							loot_gsid = 17132;
						else
							local rr = math.random(0, 1599);
							local i = math_floor(rr / 100);
							loot_gsid = 26000 + 1 + i * 5;
						end
					elseif(arena.treasurebox.loot_id == "TheGreatTree" and System.options.version == "kids") then
						local r = math.random(0, 1000);
						if(r <= 200) then
							loot_gsid = 17122;
						elseif(r <= (200 + 100)) then
							loot_gsid = 17123;
						elseif(r <= (200 + 100 + 50)) then
							loot_gsid = 17124;
						elseif(r <= (200 + 100 + 50 + 100)) then
							loot_gsid = 17132;
						elseif(r <= (200 + 100 + 50 + 100 + 50)) then
							loot_gsid = 17133;
						else
							loot_gsid = GetRandomLevel1GemGSID();
						end
					end
					if(loot_gsid) then
						local loots = {};
						loots[loot_gsid] = 1;
						PowerItemManager.AddExpJoybeanLoots(nid, 0, 0, loots, function(msg) end);
						arena.treasurebox.lootable_nids[nid] = false;
						combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "TreasureBoxResponse_PickedLoot:"..arena_id.."+["..loot_gsid..",1]");
					else
						local loots = {};
						local r = math.random(0, 1000);
						if(arena.treasurebox.loot_id == "YYsDream_S2") then
							if(r <= 500) then
								loots[GetRandomLevel1GemGSID()] = 1;
								loots[17155] = 2;
								loots[26701] = 1;
							else
								loots[GetRandomLevel1GemGSID()] = 1;
								loots[17133] = 1;
							end
						elseif(arena.treasurebox.loot_id == "LightHouse_level7") then
							if(r <= 500) then
								loots[17155] = 1;
								loots[17133] = 1;
								loots[17152] = 1;
							else
								loots[17155] = 1;
								loots[17122] = 1;
								loots[17152] = 1;
							end
						elseif(arena.treasurebox.loot_id == "LightHouse_level15") then
							if(r <= 500) then
								loots[17155] = 2;
								loots[17123] = 1;
							else
								loots[17155] = 2;
								loots[17124] = 1;
							end
						elseif(arena.treasurebox.loot_id == "LightHouse_level25") then
							loots[GetRandomLevel1GemGSID()] = 1;
							loots[17155] = 2;
							loots[17153] = 1;
						elseif(arena.treasurebox.loot_id == "LightHouse_level35") then
							if(r <= 500) then
								loots[GetRandomLevel1GemGSID()] = 1;
								loots[17155] = 2;
								loots[17134] = 1;
							else
								loots[GetRandomLevel1GemGSID()] = 1;
								loots[17155] = 2;
								loots[17125] = 1;
							end
						elseif(arena.treasurebox.loot_id == "LightHouse_level45") then
							if(r <= 500) then
								loots[GetRandomLevel1GemGSID()] = 2;
								loots[17155] = 3;
								loots[17135] = 1;
							else
								loots[GetRandomLevel1GemGSID()] = 2;
								loots[17155] = 3;
								loots[17126] = 1;
							end
						elseif(arena.treasurebox.loot_id == "LightHouse_level60") then
							if(r <= 333) then
								loots[GetRandomLevel1GemGSID()] = 2;
								loots[17156] = 2;
								loots[17136] = 1;
								loots[17154] = 1;
							elseif(r <= 666) then
								loots[GetRandomLevel1GemGSID()] = 2;
								loots[17156] = 2;
								loots[17127] = 1;
								loots[17154] = 1;
							else
								loots[17156] = 2;
								loots[17154] = 1;
							end
						elseif(arena.treasurebox.loot_id == "LightHouse_level80") then
							if(r <= 333) then
								loots[GetRandomLevel1GemGSID()] = 2;
								loots[17157] = 2;
								loots[17137] = 1;
							elseif(r <= 666) then
								loots[GetRandomLevel1GemGSID()] = 2;
								loots[17157] = 2;
								loots[17128] = 1;
							else
								loots[17156] = 1;
							end
						elseif(arena.treasurebox.loot_id == "LightHouse_level100") then
							if(r <= 500) then
								loots[GetRandomLevel1GemGSID()] = 2;
								loots[17138] = 1;
							else
								loots[GetRandomLevel1GemGSID()] = 3;
								loots[17157] = 1;
								loots[17138] = 1;
							end
						elseif(arena.treasurebox.loot_id == "Global_HaqiTown_TreasureHouse") then
							if(r <= 200) then
								loots[17133] = 1;
								loots[17168] = 1;
							else
								loots[17133] = 1;
								loots[17168] = 1;
							end
						elseif(arena.treasurebox.loot_id == "Global_FlamingPhoenixIsland_TreasureHouse") then
							if(r <= 350) then
								loots[17134] = 1;
								loots[17168] = 2;
							else
								loots[17134] = 1;
								loots[17168] = 2;
							end
						elseif(arena.treasurebox.loot_id == "Global_FrostRoarIsland_TreasureHouse") then
							if(r <= 500) then
								loots[17135] = 1;
								loots[17168] = 3;
							else
								loots[17135] = 1;
								loots[17168] = 3;
							end
						elseif(arena.treasurebox.loot_id == "Global_AncientEgyptIsland_TreasureHouse") then
							if(r <= 800) then
								loots[17136] = 1;
								loots[17168] = 4;
							else
								loots[17136] = 1;
								loots[17168] = 4;
							end
						elseif(arena.treasurebox.loot_id == "FireCavern_Hero") then
							if(r <= 200 * 1) then
								loots[26007] = 1;
							elseif(r <= 200 * 2) then
								loots[26012] = 1;
							elseif(r <= 200 * 3) then
								loots[26017] = 1;
							elseif(r <= 200 * 4) then
								loots[26022] = 1;
							else
								loots[26027] = 1;
							end
						end

						if(System.options.version == "teen") then
							-- new config for treasure house instance treasure box
							loots = {}; --  reset kids loots
							if(arena.treasurebox.loot_id == "Global_HaqiTown_TreasureHouse") then
								loots[12016] = 1;
								loots[17168] = 1;
							elseif(arena.treasurebox.loot_id == "Global_FlamingPhoenixIsland_TreasureHouse") then
								if(r <= 500) then
									loots[26076] = 1;
									loots[17168] = 1;
								else
									loots[17168] = 1;
								end
							elseif(arena.treasurebox.loot_id == "Global_FrostRoarIsland_TreasureHouse") then
								if(r <= 500) then
									loots[26101] = 1;
									loots[17168] = 1;
								else
									loots[17168] = 1;
								end
							elseif(arena.treasurebox.loot_id == "Global_AncientEgyptIsland_TreasureHouse") then
								if(r <= 500) then
									loots[26091] = 1;
									loots[17168] = 2;
								else
									loots[17168] = 2;
								end
							elseif(arena.treasurebox.loot_id == "YYsDream_S2") then
								-- 26121_AllDamageGem01
								loots[26121] = 1;
							elseif(arena.treasurebox.loot_id == "FireCavern_Hero") then
								if(r <= 500) then
									loots[26001] = 1;
								else
									loots[26101] = 1;
								end
							elseif(arena.treasurebox.loot_id == "FireCavern") then
								-- 26001_HPGems01
								loots[26001] = 1;
							elseif(arena.treasurebox.loot_id == "TheGreatTree") then
								-- 26001_HPGems01
								loots[26001] = 1;
							end
						end
						local loot_string = "";
						if(loots) then
							local gsid, count;
							for gsid, count in pairs(loots) do
								loot_string = loot_string.."["..gsid..","..count.."]";
							end
						end
						PowerItemManager.AddExpJoybeanLoots(nid, 0, 0, loots, function(msg) end);
						arena.treasurebox.lootable_nids[nid] = false;
						combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "TreasureBoxResponse_PickedLoot:"..arena_id.."+"..loot_string);
					end
				else
					-- already picked loot
					combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "TreasureBoxResponse_AlreadyPickedLoot:");
				end
			else
				-- if player_object is alreay exist, the player is already joined a fight in an arena
				combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "TreasureBoxResponse_CombatNotFinished:");
			end
		end

		arena:DebugDumpData("------------------ end IWannaLootTreasureBox ------------------");
	end
end

-- force immediate update with player stats check 
-- @param nid: player nid
-- @param callbackFunc: callbackFunc(player) with item+userinfo valid player object
-- @return if player is already valid in combat or in other gameserver gridnodes
function Arena.OnReponse_CheckStats(nid, callbackFunc)

	local nid = tonumber(nid);

	local player_object = Player.GetPlayerCombatObj(nid);
	if(player_object) then
		-- player is in combat
		return;
	end
	
	PowerItemManager.SyncUserCombatItems(nid, function()
		-- step 2: sync user and dragon info
		PowerItemManager.GetUserAndDragonInfo(nid, function(msg)
			if(msg and msg.issuccess_webapi) then
				local player_object = Player.GetPlayerCombatObj(nid);
				if(player_object) then
					-- player is in combat
					return;
				end

				-- combat level
				local petlevel = 1;
				local phase = nil;
				local userdragoninfo = PowerItemManager.GetUserAndDragonInfoInMemory(nid);
				if(userdragoninfo and userdragoninfo.dragon.combatlel) then
					petlevel = userdragoninfo.dragon.combatlel;
				end
				if(userdragoninfo and userdragoninfo.dragon.combatschool) then
					local combatschool = userdragoninfo.dragon.combatschool;
					-- 986_CombatSchool_Fire
					-- 987_CombatSchool_Ice
					-- 988_CombatSchool_Storm
					-- 989_CombatSchool_Myth
					-- 990_CombatSchool_Life
					-- 991_CombatSchool_Death
					-- 992_CombatSchool_Balance
					if(combatschool == 986) then
						phase = "fire";
					elseif(combatschool == 987) then
						phase = "ice";
					elseif(combatschool == 988) then
						phase = "storm";
					elseif(combatschool == 989) then
						phase = "myth";
					elseif(combatschool == 990) then
						phase = "life";
					elseif(combatschool == 991) then
						phase = "death";
					elseif(combatschool == 992) then
						phase = "balance";
					end
				end

				local addonlevel_damage_percent = 0;
				local addonlevel_damage_absolute = 0;
				local addonlevel_resist_absolute = 0;
				local addonlevel_hp_absolute = 0;
				local addonlevel_criticalstrike_percent = 0;
				local addonlevel_resilience_percent = 0;
				local dragon_totem_profession_gsid = 0;
				local dragon_totem_exp_gsid = 0;
				local dragon_totem_exp_cnt = 0;

				-- equipped_items_all
				local equipped_items_all = {};
				-- equipped_gems_all
				local equipped_gems_all = {};
				-- followpet_guid
				local followpet_guid = 0;
				-- itemset_id
				local itemset_id = nil; -- set_id or 0;
				local item_list = PowerItemManager.GetItemsInBagInMemory(nid, 0);
				if(item_list) then
					local guids = {};
					local k, guid;
					for k, guid in ipairs(item_list) do
						local item = PowerItemManager.GetItemByGUID(nid, guid);
						if(item and item.guid > 0) then
							if(item.position == 32) then -- follow pet
								followpet_guid = item.guid;
							elseif(item.position == 52) then
								--52 巨龙之“牙”、“爪”，“鳞”，“心”标记 儿童版第一次使用  
								if(item.gsid > 0) then
									dragon_totem_profession_gsid = item.gsid;
									if(System.options.version == "kids" and dragon_totem_profession_gsid >= 50351 and dragon_totem_profession_gsid <= 50354) then
										if(dragon_totem_exp_gsid == 0 and dragon_totem_exp_cnt == 0) then
											dragon_totem_exp_gsid = 50359;
											dragon_totem_exp_cnt = 0;
										end
									elseif(System.options.version == "teen" and dragon_totem_profession_gsid >= 50377 and dragon_totem_profession_gsid <= 50385) then
										if(dragon_totem_exp_gsid == 0 and dragon_totem_exp_cnt == 0) then
											dragon_totem_exp_gsid = 50389;
											dragon_totem_exp_cnt = 0;
										end
									end
								end
							elseif(item.position == 53) then
								--53 巨龙图腾经验值标记 儿童版第一次使用 
								if(item.gsid > 0 and item.copies > 0) then
									dragon_totem_exp_gsid = item.gsid;
									dragon_totem_exp_cnt = item.copies;
								end
							else
								local isValidItem = true;
								if(item.IsDurable and item:IsDurable() and item.GetDurability and item:GetDurability() <= 0) then
									isValidItem = false;
								end
								if(isValidItem) then
									-- get equip items
									table.insert(equipped_items_all, item.gsid);
									-- get gems
									if(item.PrepareSocketedGemsIfNot and item.GetSocketedGems) then
										item:PrepareSocketedGemsIfNot();
										local gems = item:GetSocketedGems();
										if(gems) then
											gems = Arena.FilterInvalidGems(gems);
											local _, gsid;
											for _, gsid in pairs(gems) do
												table.insert(equipped_gems_all, gsid);
											end
										end
									end
									-- addon attack
									if(item.GetAddonAttackPercentage) then
										addonlevel_damage_percent = addonlevel_damage_percent + (item:GetAddonAttackPercentage() or 0);
									end
									if(item.GetAddonAttackAbsolute) then
										addonlevel_damage_absolute = addonlevel_damage_absolute + (item:GetAddonAttackAbsolute() or 0);
									end
									if(item.GetAddonResistAbsolute) then
										addonlevel_resist_absolute = addonlevel_resist_absolute + (item:GetAddonResistAbsolute() or 0);
									end
									if(item.GetAddonHpAbsolute) then
										addonlevel_hp_absolute = addonlevel_hp_absolute + (item:GetAddonHpAbsolute() or 0);
									end
									if(item.GetCriticalStrikePercent) then
										addonlevel_criticalstrike_percent = addonlevel_criticalstrike_percent + (item:GetCriticalStrikePercent() or 0);
									end
									if(item.GetResiliencePercent) then
										addonlevel_resilience_percent = addonlevel_resilience_percent + (item:GetResiliencePercent() or 0);
									end
								end
							end
						end
					end
				end

				-- create temp player
				local player = Player:new({
					nid = nid,
					current_hp = 1,
					max_hp = 1,
					phase = phase,
					petlevel = petlevel,
					deck_struct = {},
					deck_struct_equip = {};
					deck_struct_pet = {},
					equips = equipped_items_all,
					gems = equipped_gems_all,
					current_followpet_guid = followpet_guid,
					addonlevel_damage_percent = addonlevel_damage_percent,
					addonlevel_damage_absolute = addonlevel_damage_absolute,
					addonlevel_resist_absolute = addonlevel_resist_absolute,
					addonlevel_hp_absolute = addonlevel_hp_absolute,
					addonlevel_criticalstrike_percent = addonlevel_criticalstrike_percent,
					addonlevel_resilience_percent = addonlevel_resilience_percent,
					dragon_totem_profession_gsid = dragon_totem_profession_gsid,
					dragon_totem_exp_gsid = dragon_totem_exp_gsid,
					dragon_totem_exp_cnt = dragon_totem_exp_cnt,
					user_team_aura = nil,
				});

				if(callbackFunc) then
					callbackFunc(player);
				end

				-- destroy temp player
				Player.DestroyPlayer(nid);
			end
		end);
	end);
end

-- check internetcafe status
function Arena.OnReponse_CheckInternetCafeStatus(nid)
	local gridnode = GSL_gateway:GetPrimGridNode(tostring(nid));
	if(gridnode) then
		local server_object = gridnode:GetServerObject("sAriesCombat");
		if(server_object) then
			if(PowerItemManager.IsUserInInternetCafe(nid)) then
				server_object:SendRealtimeMessage(tostring(nid), "[Aries][combat_to_client]ImFromInternetCafe_zhTW:cafewow");
			else
				server_object:SendRealtimeMessage(tostring(nid), "[Aries][combat_to_client]ImFromInternetCafe_zhTW:normal");
			end
		end
	end
end

-- TEST gear score check
function Arena.OnReponse_CheckMyGearScore(nid, set_id)

	local nid = tonumber(nid);
	
	PowerItemManager.SyncUserCombatItems(nid, function()
		-- step 2: sync user and dragon info
		PowerItemManager.GetUserAndDragonInfo(nid, function(msg)
			if(msg and msg.issuccess_webapi) then
				local gearscore = 0;

				-- combat level
				local petlevel = 1;
				local userdragoninfo = PowerItemManager.GetUserAndDragonInfoInMemory(nid);
				if(userdragoninfo and userdragoninfo.dragon.combatlel) then
					petlevel = userdragoninfo.dragon.combatlel;
				end
				
				local addonlevel_damage_percent = 0;
				local addonlevel_damage_absolute = 0;
				local addonlevel_resist_absolute = 0;
				local addonlevel_hp_absolute = 0;
				local addonlevel_criticalstrike_percent = 0;
				local addonlevel_resilience_percent = 0;
				local dragon_totem_profession_gsid = 0;
				local dragon_totem_exp_gsid = 0;
				local dragon_totem_exp_cnt = 0;

				-- equipped_items_all
				local equipped_items_all = {};
				-- equipped_gems_all
				local equipped_gems_all = {};
				-- followpet_guid
				local followpet_guid = 0;
				-- itemset_id
				local itemset_id = nil; -- set_id or 0;
				local item_list = PowerItemManager.GetItemsInBagInMemory(nid, 0);
				if(item_list) then
					local guids = {};
					local k, guid;
					for k, guid in ipairs(item_list) do
						local item = PowerItemManager.GetItemByGUID(nid, guid);
						if(item and item.guid > 0) then
							if(item.position == 32) then -- follow pet
								followpet_guid = item.guid;
							elseif(item.position == 52) then
								--52 巨龙之“牙”、“爪”，“鳞”，“心”标记 儿童版第一次使用  
								if(item.gsid > 0) then
									dragon_totem_profession_gsid = item.gsid;
								end
							elseif(item.position == 53) then
								--53 巨龙图腾经验值标记 儿童版第一次使用 
								if(item.gsid > 0 and item.copies > 0) then
									dragon_totem_exp_gsid = item.gsid;
									dragon_totem_exp_cnt = item.copies;
								end
							else
								local isValidItem = true;
								if(item.IsDurable and item:IsDurable() and item.GetDurability and item:GetDurability() <= 0) then
									isValidItem = false;
								end
								if(isValidItem) then
									-- get equip items
									table.insert(equipped_items_all, item.gsid);
									-- get gems
									if(item.PrepareSocketedGemsIfNot and item.GetSocketedGems) then
										item:PrepareSocketedGemsIfNot();
										local gems = item:GetSocketedGems();
										if(gems) then
											gems = Arena.FilterInvalidGems(gems);
											local _, gsid;
											for _, gsid in pairs(gems) do
												table.insert(equipped_gems_all, gsid);
											end
										end
									end
									-- addon attack
									if(item.GetAddonAttackPercentage) then
										addonlevel_damage_percent = addonlevel_damage_percent + (item:GetAddonAttackPercentage() or 0);
									end
									if(item.GetAddonAttackAbsolute) then
										addonlevel_damage_absolute = addonlevel_damage_absolute + (item:GetAddonAttackAbsolute() or 0);
									end
									if(item.GetAddonResistAbsolute) then
										addonlevel_resist_absolute = addonlevel_resist_absolute + (item:GetAddonResistAbsolute() or 0);
									end
									if(item.GetAddonHpAbsolute) then
										addonlevel_hp_absolute = addonlevel_hp_absolute + (item:GetAddonHpAbsolute() or 0);
									end
									if(item.GetCriticalStrikePercent) then
										addonlevel_criticalstrike_percent = addonlevel_criticalstrike_percent + (item:GetCriticalStrikePercent() or 0);
									end
									if(item.GetResiliencePercent) then
										addonlevel_resilience_percent = addonlevel_resilience_percent + (item:GetResiliencePercent() or 0);
									end
								end
							end
						end
					end
				end

				-- create temp player
				local player = Player:new({
					nid = nid,
					current_hp = 1,
					max_hp = 1,
					petlevel = petlevel,
					deck_struct = {},
					deck_struct_equip = {},
					deck_struct_pet = {},
					equips = equipped_items_all,
					gems = equipped_gems_all,
					current_followpet_guid = followpet_guid,
					addonlevel_damage_percent = addonlevel_damage_percent,
					addonlevel_damage_absolute = addonlevel_damage_absolute,
					addonlevel_resist_absolute = addonlevel_resist_absolute,
					addonlevel_hp_absolute = addonlevel_hp_absolute,
					addonlevel_criticalstrike_percent = addonlevel_criticalstrike_percent,
					addonlevel_resilience_percent = addonlevel_resilience_percent,
					dragon_totem_profession_gsid = dragon_totem_profession_gsid,
					dragon_totem_exp_gsid = dragon_totem_exp_gsid,
					dragon_totem_exp_cnt = dragon_totem_exp_cnt,
					user_team_aura = nil,
				});

				---- validate the set id
				--player:ValidateSetID();

				-- calculate gearscore
				gearscore = player:GetGearScore();

				-- destroy temp player
				Player.DestroyPlayer(nid);

				-- check 
				local gridnode = GSL_gateway:GetPrimGridNode(tostring(nid));
				if(gridnode) then
					local server_object = gridnode:GetServerObject("sAriesCombat");
					if(server_object) then
						server_object:SendRealtimeMessage(tostring(nid), "[Aries][combat_to_client]GearScoreOnServer:"..gearscore);
					end
				end
			end
		end);
	end);
end

local bug_seq = 300;

-- mark debug point
function Arena.OnReponse_MarkDebugPoint(nid)
	--log("Arena.OnReponse_HeartBeat========= "..tostring(nid).."\n");
	LOG.std(nil, "debug","arena","!!!!!!!!!! Debug Point by %s seq %d !!!!!!!!!!", tostring(nid), bug_seq);
	--commonlib.applog("!!!!!!!!!! Debug Point by %d seq %d !!!!!!!!!!", nid, bug_seq);
	
	--combat_server.AppendRealTimeMessageToNID(arena.combat_server_uid, nid, "BugPointMarked:"..bug_seq);
	
	bug_seq = bug_seq + 1;
end