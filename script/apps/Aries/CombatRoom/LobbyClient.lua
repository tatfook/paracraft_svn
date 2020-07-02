--[[
Title: the client side logics
Author(s): LiXizhi
Date: 2011/3/17
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClient.lua");
local LobbyClient = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClient");
local lc = LobbyClient:GetClient();
local game_key_array = LobbyClient:GetGameKeysByUserLevel(10, "PvE", true);
LobbyClient:GetRoomListDataSource(game_key_array, true, function(result)
	log("results\n")
	commonlib.echo(result)
end)
LobbyClient.events.AddEventListener("on_game_update", function(msg)
	if(msg.game_info) then
		-- this is the game info class instace, one can call its methods. 
	end
end);
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyHelper.lua");
local LobbyHelper = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyHelper");
NPL.load("(gl)script/apps/Aries/Combat/MsgHandler.lua");
local MsgHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");
NPL.load("(gl)script/apps/GameServer/LobbyService/GSL_LobbyClient.lua");
NPL.load("(gl)script/ide/EventDispatcher.lua");
local Combat = commonlib.gettable("MyCompany.Aries.Combat");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
local Player = commonlib.gettable("MyCompany.Aries.Player");

local game_info = commonlib.gettable("Map3DSystem.GSL.Lobby.game_info");
local LobbyClient = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClient");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");

local ProfileManager = commonlib.gettable("System.App.profiles.ProfileManager");

-- local persistent games
LobbyClient.persistent_games_filename = nil;
-- refresh every 5 seconds for the same result. 
LobbyClient.auto_refresh_interval = 5000;

-- mapping from game key name to game template. only games in this table are allowed to be created. 
local game_templates = {};
-- mapping from key_array_string to {last_sync_time, is_fetching, data={}, formated_data={}}
local cached_results = {};
-- mapping from game_id to {last_sync_time, is_fetching, data={}, formated_data={}}
local game_details = {};

LobbyClient.match_info = nil;

function LobbyClient:SetMatchInfo(match_info)
	self.match_info = match_info;
end
function LobbyClient:GetMatchInfo()
	return self.match_info;
end
-- get the low level gsl client class
function LobbyClient:GetClient()
	if(not self.lobbyclient) then
		self:Init();
	end
	return self.lobbyclient;
end

function LobbyClient:LoadConfigFile()
	if(CommonClientService.IsTeenVersion())then
		return "config/Aries/LobbyService_Teen/aries.lobby_persistent_games.teen.xml";
	end
	return "config/Aries/LobbyService/aries.lobby_persistent_games.xml";
end
-- init game 
function LobbyClient:Init()
	self.lobbyclient = Map3DSystem.GSL.Lobby.GSL_LobbyClient.GetSingleton();
	LobbyClient.persistent_games_filename = LobbyClient:LoadConfigFile();
	local xmlRoot = ParaXML.LuaXML_ParseFile(self.persistent_games_filename);
	if(not xmlRoot) then
		LOG.std(nil, "error", "LobbyClient", "failed loading persistent world config file %s", self.persistent_games_filename);
	else
		local function get_bool(v)
			if(v and v == "true")then
				return true;
			end
			return false;
		end
		-- load all game template. 
		local node;
		for node in commonlib.XPath.eachNode(xmlRoot, "//game") do
			local game_tmpl = {
				name = node.attr.name,
				keyname = node.attr.keyname,
				worldname=node.attr.worldname,
				door_closed=node.attr.door_closed,
				is_persistent = true,
				min_level = tonumber(node.attr.min_level),
				max_level = tonumber(node.attr.max_level),
				game_type = node.attr.game_type,
				max_players = tonumber(node.attr.max_players),
				desc = node.attr.desc,
				pic = node.attr.pic,
				loots = node.attr.loots,
				goto_worldname = node.attr.goto_worldname,
				goto_pos = node.attr.goto_pos,
				hide_from_createpage = get_bool(node.attr.hide_from_createpage),
				mode_list = node.attr.mode_list,
				match_method = node.attr.match_method,
				pre_world_id = tonumber(node.attr.pre_world_id),
				force_worldteam = node.attr.force_worldteam,
			}
			
			game_tmpl.keyname = game_tmpl.keyname or game_tmpl.worldname;

			local worldinfo = WorldManager:GetWorldInfo(game_tmpl.worldname);
			if(worldinfo.name == game_tmpl.worldname and (not worldinfo.minlevel or worldinfo.minlevel==0 or worldinfo.minlevel>(game_tmpl.min_level or 0))) then
				-- set min level according to lobby config to prevent user to enter an instanced world when its level does not met. 
				worldinfo.min_level = (game_tmpl.min_level or 0);
			end
			if(game_templates[game_tmpl.keyname]) then
				LOG.std(nil, "warn", "LobbyClient", "game template %s is already added before.", game_tmpl.keyname);
			else
				game_templates[game_tmpl.keyname] = game_tmpl;
			end
		end
	end	
	-- event dispatcher for this class
	self.events = commonlib.EventSystem:new();
	self.lobbyclient:AddEventListener("on_handle_all_msg", self.OnHandleAllMsg, self);
	self.lobbyclient:AddEventListener("on_game_update", self.OnGameUpdate, self);

	LOG.std(nil, "system", "LobbyClient", "initialized from file %s", self.persistent_games_filename);
end
function LobbyClient:GetModeNode(modelist,mode)
	if(modelist and mode)then
		local k,v;
		for k,v in ipairs(modelist) do	
			if(v.mode == mode)then
				return v;
			end
		end
	end
end
function LobbyClient:LoadModeList_ByWorldName(worldname)
	if(not worldname)then
		return
	end
	local game_templates = LobbyClient:GetGameTemplates();
	if(game_templates)then
		local result = {};
		local temp = {};
		local k,template;
		for k,template in pairs(game_templates) do
			local _worldname = template.worldname;
			local _keyname = template.keyname;
			if(_worldname and _keyname and _worldname == worldname)then
				local mode_list = self:LoadModeList(_keyname);
				local __,v;
				for __,v in ipairs(mode_list) do
					if(v.mode and not temp[v.mode])then
						table.insert(result,v);
						temp[v.mode] = true;
					end
				end
			end
		end
		table.sort(result,function(a,b)
			if(a.mode and b.mode)then
				return a.mode < b.mode;
			end
		end)
		return result;
	end
end
--[[
返回 难度 和 人数上限
local mode_list = {
	{mode = 1, max_players = 4,},
	{mode = 2, max_players = 4,},
	{mode = 3, max_players = 4,},
}
--]]
function LobbyClient:LoadModeList(keyname)
	local game_templates = LobbyClient:GetGameTemplates();
	local template = game_templates[keyname];
	if(template)then
		local mode_list = template.mode_list or "1#4#4,2#4#4,3#4#4";
		mode_list = commonlib.split(mode_list,",");
		local result = {};
		local k,v;
		for k,v in ipairs(mode_list) do
			local line = commonlib.split(v,"#");
			local mode = tonumber(line[1]) or 1; 
			local recommend_players = tonumber(line[2]) or 4; 
			local max_players = tonumber(line[3]) or recommend_players or 4; 
			table.insert(result,{mode = mode,recommend_players = recommend_players, max_players = max_players});
		end
		return result;
	end
end
-- get the game_info that the user is current in. it may return nil if the user is not is any room. 
function LobbyClient:GetCurrentGame()
	local lc = self:GetClient();
	if(lc) then
		return lc:GetCurrentGame();
	end
end
function LobbyClient:OnHandleAllMsg(msg)
	self.events:DispatchEvent({type = "on_handle_all_msg",msg = msg});
end
-- called whenever the user room info is changed. 
function LobbyClient:OnGameUpdate(msg)
	
end
function LobbyClient:GetGameTemplates()
	return game_templates;
end
-- get my combat level 
function LobbyClient:GetMySchool()
	local school = MyCompany.Aries.Combat.GetSchool();
	return school;
end
-- get my combat level 
function LobbyClient:GetMyCombatLevel()
	combatlevel = 1;
	local bean = MyCompany.Aries.Pet.GetBean();
	if(bean) then
		combatlevel = bean.combatlel;
	end
	return combatlevel;
end

function LobbyClient:GetMyFamilyID()
	return MyCompany.Aries.Friends.GetMyFamilyID();
end

-- return nil or a table array of nids
function LobbyClient:GetMyBestFriends()
	local best_friends = MyCompany.Aries.Friends.GetMyBestFriends();
	if(best_friends and #best_friends>0) then
		return best_friends;
	end
end

-- modified by LiXizhi: the pvp score is further modified by gs_score.
-- @param game_mode: if nil, it is the summation of all scores. otherwise it could be "1v1", "2v2", "3v3", "4v4"
function LobbyClient:GetPvPScore(game_mode)
	
	local use_strict_score = true;
	if(use_strict_score) then
		-- use strict score
		local score;
		if(System.options.version == "kids") then
			score = Player.GetRankingScore(game_mode);
		else
			score = Player.GetVirtualRankingScore(game_mode)
		end
		return score;
	else
		-- non-used old scoring system. 
		local pvp_score;
		if(game_mode) then
			pvp_score = Combat.GetMyPvPStats(game_mode, "rating");
		end
		if(not pvp_score) then
			pvp_score = (Combat.GetMyPvPStats("1v1", "rating")+Combat.GetMyPvPStats("2v2", "rating")+Combat.GetMyPvPStats("3v3", "rating")+Combat.GetMyPvPStats("4v4", "rating"));
		end
		local bUseRawScore = true;
		if(bUseRawScore) then
			return pvp_score;
		else
			local gs_score = MyCompany.Aries.Combat.GetGearScoreV2();
			LOG.std(nil, "debug", "LobbyClient", "GetPvPScore(mode:%s): gs_score %d; pvp_score %d", tostring(game_mode), gs_score, pvp_score);

			if( (pvp_score + gs_score) < 1800 ) then
				return pvp_score + gs_score;
			else
				return math.max(1800, pvp_score);
			end
		end
	end
end

--战斗力
function LobbyClient:GetCombatStats(school,type)
	return Combat.GetStats(school,type);
end
--治疗加成
function LobbyClient:GetOutputHealBoost()
	return Combat.GetOutputHealBoost();
end
-- 魔法星等级 
function LobbyClient:GetMagicStarLevel()
	local level = -1;
	local bean = MyCompany.Aries.Pet.GetBean();
	if(bean) then
		level = bean.mlel;
	end
	return level;
end
--自己每个系的防御力
function LobbyClient:GetGuardMap()
	local map = {
		storm = self:GetCombatStats("storm","resist"),
		fire = self:GetCombatStats("fire","resist"),
		life = self:GetCombatStats("life","resist"),
		death = self:GetCombatStats("death","resist"),
		ice = self:GetCombatStats("ice","resist"),
	};
	return map;
end
--获取血量
function LobbyClient:GetMyHP()
	return MsgHandler.GetCurrentHP() or 0;
end

-- get all game keys that a user can join with a given user level
-- @param user_level: if nil, it will be the highest value. this is usually in range [1,50] according to game settings. 
-- @param game_type: "PvP" or "PvE", which game type to search. If nil, it means any type.
-- @param is_recommended_only: whether we return recommended games only. default to false, which we include all games that the user is allowed to join. But sorted with recommended in front. 
-- @param pve_include_max_level:pve 是否判断最大等级，默认不判断
-- @return an array of {key_name,key_name, ... }. it is sorted by min_level from most chanllenging to least chanllenging
function LobbyClient:GetGameKeysByUserLevel(user_level, game_type, is_recommended_only,pve_include_max_level)
	local lc = self:GetClient();
	local output = {};
	local game_key, game_tmpl
	for game_key, game_tmpl in pairs(game_templates) do
		if(not game_tmpl.force_worldteam and (not game_type or game_tmpl.game_type == game_type)) then
			if(not user_level or not game_tmpl.min_level or game_tmpl.min_level <= user_level) then
				--PvP判断最低等级 和 最高等级
				if(game_type and game_type == "PvP")then
					if(not is_recommended_only or (not user_level or not game_tmpl.max_level or game_tmpl.max_level >= user_level) ) then
						output[#output+1] = game_tmpl;
					end
				else
					--PvE判断最低等级 和 最高等级
					if(pve_include_max_level)then
						if(game_tmpl.max_level and game_tmpl.max_level >= user_level)then
							output[#output+1] = game_tmpl;
						end
					else
						--PvE只判断最低等级
						output[#output+1] = game_tmpl;
					end
				end
			end
		end
	end
	table.sort(output, function(left, right)
		return (left.min_level or 0) >(right.min_level or 0);
	end)

	-- convert to keys
	local i;
	for i = 1, #output do
		output[i] = output[i].keyname;
	end
	return output;
end

--[[ join an existing game 
@param game_setting = {
		game_id=int,
		school=string,
		level=int, 
		display_name=string,
		password=string
	};
]]
function LobbyClient:JoinGame(game_settings, func_callback, timeout)
	local lc = self:GetClient();
	if(lc and game_settings) then
		local game_mode
		if(game_settings.keyname) then
			game_mode = game_settings.keyname:match("(%dv%d)");
			--if(System.options.version == "kids") then
				--game_mode = game_settings.keyname:match("(%dv%d_?%d*)");
			--end
		end
		local attack;
		if(CommonClientService.IsTeenVersion())then
			attack = self:GetCombatStats(self:GetMySchool(),"damage_absolute_base");
		else
			attack = self:GetCombatStats(self:GetMySchool(),"damage");
		end
		lc:JoinGame({
			game_id = game_settings.game_id,
			school = self:GetMySchool(),
			level = self:GetMyCombatLevel(),
			score = self:GetPvPScore(game_mode),
			family_id = self:GetMyFamilyID(),
			best_friends = self:GetMyBestFriends(),
			display_name = "TestUserName",
			password = game_settings.password,

			magic_star_level = self:GetMagicStarLevel(),
			hp = self:GetMyHP(),
			attack = attack,
			hit = self:GetCombatStats(self:GetMySchool(),"accuracy"),
			cure = self:GetOutputHealBoost(),
			guard_map = self:GetGuardMap(),
			pvp_3v3_win_rate = self:GetPVP3V3WinRate(),
			gear_score = Player.GetGearScore(),
		}, func_callback, timeout);
	end
end

function LobbyClient:GetPVP3V3WinRate()
	--local nid = ProfileManager.GetNID();
	local rate = Combat.GetPVP3V3WinRate();
	return rate or 50;
end

--PvE 根据副本难度获得房间最大人数
function LobbyClient:GetMaxPlayerByMode(keyname,mode)
	local modelist = LobbyClient:LoadModeList(keyname)	
	local node = LobbyClient:GetModeNode(modelist,mode);
	local max_players = 4;
	if(node and node.max_players)then
		max_players = node.max_players;
	end
	return max_players;
end
--更改副本难度
--[[
@param game_setting = {
		id = game_info.id,
		mode = mode,
	};
]]
function LobbyClient:ResetGameMode(game_settings, func_callback, timeout)
	local lc = self:GetClient();
	if(lc) then
		if(CommonClientService.IsTeenVersion())then
			--青年版PvE根据难度判断最大人数
			game_settings.max_players = self:GetMaxPlayerByMode(game_settings.keyname,game_settings.mode);
		end
		lc:ResetGameMode(game_settings, func_callback, timeout);
	end
end
--[[ reset a game
@param game_setting = {
		id = game_info.id,
        name = name,
        leader_text = leader_text,
        min_level = min_level,
        max_level = max_level,
        max_players = max_players,
        password = password,
        requirement_tag = requirement_tag,
        magic_star_level = magic_star_level,
        hp = hp,
        attack = attack,
        hit = hit,
        cure = cure,
        guard_map = guard_map,
	};
]]
function LobbyClient:ResetGame(game_settings, func_callback, timeout)
	local lc = self:GetClient();
	if(lc) then
		lc:ResetGame(game_settings, func_callback, timeout);
	end
end
--[[ create a new game 
@param game_setting = {
		keyname = "",
		min_level = nil,
		max_level = nil,
		name = "",
		school = string,
		start_mode = "auto",
	};
]]
function LobbyClient:CreateGame(game_settings, func_callback, timeout)
	local lc = self:GetClient();
	if(lc) then
		if(game_settings)then
			local game_templates = self:GetGameTemplates();
			local keyname = game_settings.keyname;
			local game_type = game_settings.game_type;
			--副本难度
			local mode = game_settings.mode;
			local template = game_templates[keyname];
			if(template)then
				local game_mode = game_settings.keyname:match("(%dv%d)");
				--if(System.options.version == "kids") then
					--echo("22222222");
					--echo(game_settings.keyname);
					--echo(game_settings);
					--game_mode = game_settings.keyname:match("(%dv%d_?%d*)");
				--end
				game_settings.level = self:GetMyCombatLevel(game_mode);
				game_settings.family_id = self:GetMyFamilyID();
				game_settings.best_friends = self:GetMyBestFriends();
				game_settings.school = self:GetMySchool();
				game_settings.score = self:GetPvPScore(game_mode); -- replace this with pvp score
				local max_players = template.max_players;
				if(game_type and game_type == "PvE" and CommonClientService.IsTeenVersion())then
					--青年版PvE根据难度判断最大人数
					max_players = self:GetMaxPlayerByMode(keyname,mode);
				end
				game_settings.max_players = max_players;
				game_settings.pvp_3v3_win_rate = self:GetPVP3V3WinRate();
				game_settings.gear_score = Player.GetGearScore();
			end
		end
		lc:CreateGame(game_settings, func_callback, timeout);
	end
end

-- leave a given game. 
function LobbyClient:LeaveGame(game_id, func_callback, timeout)
	local lc = self:GetClient();
	if(lc and game_id) then
		lc:LeaveGame(game_id, func_callback, timeout);
	end
end

function LobbyClient:StartGame(game_id, func_callback, timeout)
	local lc = self:GetClient();
	if(lc and game_id) then
		lc:StartGame(game_id, func_callback, timeout);
	end
end
function LobbyClient:MatchMaking(game_id, func_callback, timeout)
	local lc = self:GetClient();
	if(lc and game_id) then
		lc:MatchMaking(game_id, func_callback, timeout);
	end
end
function LobbyClient:KickGame(game_settings, func_callback, timeout)
	local lc = self:GetClient();
	if(lc) then
		lc:KickGame(game_settings, func_callback, timeout);
	end
end
--[[
	local chat_msg = {
		game_id = game_id,
		chat_data = chat_data,
	}
--]]
function LobbyClient:SentChatMessage(chat_msg)
	local lc = self:GetClient();
	if(lc) then
		lc:SentChatMessage(chat_msg);
	end
end

-- send server chat message 
function LobbyClient:SendServerChatMessage(chat_msg)
	local lc = self:GetClient();
	if(lc) then
		if(type(chat_msg) == "string" ) then
			chat_msg = {chat_data = chat_msg};
		end
		lc:SendServerChatMessage(chat_msg);
	end
end

--[[
	local address_info = {
		game_id = game_id,
		nid = nid,
		address = address,
	}
--]]
function LobbyClient:CallUserToWorldAddress(address_info, func_callback, timeout)
	local lc = self:GetClient();
	if(lc) then
		lc:CallUserToWorldAddress(address_info, func_callback, timeout);
	end
end

-- return formatted game info. 
function LobbyClient:GetGameInfoInMemory(game_id)
	if(game_id) then
		local result = game_details[game_id];
		if(result and result.formated_data) then
			return result.formated_data;
		end
	end
end

-- get the game details of a given room list according to keys. 
-- @param game_id: the game id 
-- @param auto_refresh: if true, calling this function after 5 seconds with the same key will force another sync with the lobby server. 
-- @param callback_func: if the callback is not nil, we will also return the result via function(result, bIsOldData) end when data is available.
-- @param force_refresh:if true 强制刷新数据
--  if there is we are fetching data over the network, then we will invoke this function when data is available or timed out. bIsOldData is true, if there is already old data, and no network connection is used. 
-- @return {last_sync_time, is_fetching, data={}, formated_data={}}. if it is fetching then is_fetching is nil. data is the original data, formated_data is nicely formated for display in grid control. 
function LobbyClient:GetGameDetail(game_id, auto_refresh, callback_func,force_refresh)
	if(not game_id) then
		LOG.std(nil, "warn", "LobbyClient", "GetGameDetail game_id is nil");
		return {};
	end
	local result = game_details[game_id];
	local curTime = commonlib.TimerManager.GetCurrentTime();
	if(force_refresh or not result) then
		result = {};
		game_details[game_id] = result;
		result.last_sync_time = 0;
		auto_refresh = true;
	end
	if (auto_refresh and not result.is_fetching and (curTime - result.last_sync_time) > self.auto_refresh_interval) then
		result.is_fetching = true;
		result.callback_func = callback_func;
		local lc = self:GetClient();
		if(lc) then
			lc:GetGameDetail(game_id, function(msg)
				result.is_fetching = false;
				result.last_sync_time = commonlib.TimerManager.GetCurrentTime();
				if(type(msg)== "table" and msg.msg and msg.msg.msg) then
					local room_info = msg.msg.msg;
					result.data = room_info;
					result.formated_data = room_info;
					-- make formated data. 
					if(room_info.keyname) then
						local game_tmpl = game_templates[room_info.keyname];
						room_info.min_level = room_info.min_level or game_tmpl.min_level;
						room_info.max_level = room_info.max_level or game_tmpl.max_level;
					end
				end
				
				if(result.callback_func) then
					result.callback_func(result);
				end
			end)
		end
	else
		if(callback_func) then
			callback_func(result, true);
		end	
	end
	return result;
end


-- return an array of game templates that matches a given worldname
-- @param worldname: worldname as defined in aries game world config file. 
-- @param game_type: "PvP" or "PvE", which game type to search. If nil, it means any type.
-- @param user_level: nil or number in range [1,50] according to game settings. 
-- @param ignore_max_level:忽略最高等级
-- @return candidates, best_game_tmpl:   where candidates is empty table or an array of game templates {{keyname=string}, ...} 
-- closest_game_tmpl is the best game template that could be found. please note that even if there is no candiates, there can be a closest_game_tmpl whose min-level is closest to user_level.
function LobbyClient:GetGamesByWorldName(worldname, game_type, user_level,ignore_max_level)
	local output = {};
	local closest_game_tmpl;
	local game_key, game_tmpl;
	for game_key, game_tmpl in pairs(game_templates) do
		if( (not game_type or game_tmpl.game_type == game_type) and 
			((not worldname and not game_tmpl.force_worldteam) or game_tmpl.worldname == worldname)) then
			local min_level = game_tmpl.min_level or 0;
			local max_level = game_tmpl.max_level or 1000;
			if(not user_level or (user_level >= min_level and ignore_max_level) or (user_level >= min_level and user_level <= max_level )) then
				output[#output+1] = game_tmpl;
			else
				if(not closest_game_tmpl) then
					closest_game_tmpl = game_tmpl;
				elseif( user_level and math.abs(user_level - (game_tmpl.min_level or 0))<math.abs(user_level - min_level)) then
					closest_game_tmpl = game_tmpl;
				end
			end
		end
	end
	return output, closest_game_tmpl;
end


--[[ automatically find a group of rooms to join given a worldname. this is usually used in the in-game instance entry point. 
e.g.
NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClient.lua");
local lc = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClient");
local worldname = "FlamingPhoenixIsland_TheGreatTree";
lc:AutoFindRoom(worldname, "PvE", nil, function(candidate_rooms, games)
	if(not candidate_rooms) then
		-- use normal way to load the world
		LOG.std(nil, "system", "lobbyclient", "auto find room does not find any game with the world name:%s, we will just load the world using default config file", worldname);
	elseif(#candidate_rooms == 0) then
		local keyname = game[1].keyname;
		-- create a new room with keyname
		LOG.std(nil, "system", "lobbyclient", "no empty rooms found for worldname %s, we will create one by ourself", worldname);
	else
		local room = candidate_rooms[math.random(1,#candidate_rooms)];
		if(room.game_id) then
			-- randomly join a candidate
			LOG.std(nil, "system", "lobbyclient", "find a room (game_id:%d)to join ", room.game_id);
		end
	end
end)
]]
-- @param worldname: worldname as defined in aries game world config file. 
-- @param game_type: "PvP" or "PvE", which game type to search. If nil, it means any type.
-- @param user_level: nil or number in range [1,50] according to game settings. 
-- @param callback_func: function(candidate_rooms, games) end, candidate_rooms is nil if the worldname does not have a matching game. it is a table array of game rooms{{game_id=number, }, ...} 
-- please note if there is no matching rooms are found, #candidate_rooms is 0, and the second games parameters contains array of game templates that the caller may create {{keyname=string}, ...}. 
function LobbyClient:AutoFindRoom(worldname, game_type, user_level, callback_func)
	local games;
	if(game_type == "PvE")then
		games = self:GetGamesByWorldName(worldname, game_type, user_level, true);
	else
		--pvp严格判断等级
		games = self:GetGamesByWorldName(worldname, game_type, user_level);
	end
	if(#games == 0) then
		if(callback_func) then
			callback_func(nil);
		end
	else
		local _, game;
		local key_array = {};
		for _, game in ipairs(games) do
			key_array[#key_array+1] = game.keyname;
		end

		local player_count = 1;
		local candidates = {};
		
		local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");
		local is_share_team = ExternalUserModule:GetConfig().is_share_team;
		local region_id = ExternalUserModule:GetRegionID();

		-- find non-full rooms with most players(at least one)
		self:GetRoomListDataSource(key_array, true, function(result)
			if(result and result.formated_data) then
				-- game_id, count
				local index, room;
				for index, room in pairs(result.formated_data) do
					if(not room.needpassword)then
						-- room.game_id
						if(room.status~="started" and room.game_id and room.count < room.max_players and room.count >= player_count and room.owner_nid) then
							-- only include if owner is in the same region or the room owner and the current user both allow is_share_team
							if( (is_share_team and ExternalUserModule:GetConfigByNid(room.owner_nid).is_share_team) or
								(not is_share_team and ExternalUserModule:GetRegionIDFromNid(room.owner_nid) == region_id) ) then
								if(room.count == player_count) then
									candidates[#candidates+1] = room;
								else -- if(room.count > player_count) then
									player_count = room.count;
									candidates = {};
									candidates[#candidates+1] = room;
								end
							end
						end
					end
				end
				if(callback_func) then
					callback_func(candidates, games);
				end
			end
		end)
	end
end

-- get the data source of a given room list according to search keys. 
-- Note: This function can be called as often as possible, internally it will cache for the same search key combination for 5 seconds. 
-- @param key_array: this is usually array returned by self:GetGameKeysByUserLevel.
-- @param auto_refresh: if true, calling this function after 5 seconds with the same key will force another sync with the lobby server. 
-- @param callback_func: if the callback is not nil, we will also return the result via function(result, bIsOldData) end when data is available.
--  if there is we are fetching data over the network, then we will invoke this function when data is available or timed out. bIsOldData is true, if there is already old data, and no network connection is used. 
-- @return {last_sync_time, is_fetching, data={}, formated_data={}}. if it is fetching then is_fetching is nil. data is the original data, formated_data is nicely formated for display in grid control. 
function LobbyClient:GetRoomListDataSource(key_array, auto_refresh, callback_func)
	local key_array_string = table.concat(key_array,",");
	
	local result = cached_results[key_array_string];
	local curTime = commonlib.TimerManager.GetCurrentTime();
	if(not result) then
		result = {};
		cached_results[key_array_string] = result;
		result.last_sync_time = 0;
		auto_refresh = true;
	end

	if (auto_refresh and not result.is_fetching and (curTime - result.last_sync_time) > self.auto_refresh_interval) then
		result.is_fetching = true;
		result.callback_func = callback_func;
		local lc = self:GetClient();
		if(lc) then
			lc:FindGame(key_array, function(msg)
				result.is_fetching = false;
				result.last_sync_time = commonlib.TimerManager.GetCurrentTime();
				if(type(msg)== "table" and msg.msg and msg.msg.msg) then
					self:MakeFormattedRoomList(key_array, result, msg.msg.msg)
				end
				
				if(result.callback_func) then
					result.callback_func(result);
				end
			end)
		end
	else
		if(callback_func) then
			callback_func(result, true);
		end	
	end
	return result;
end

-- we will generate proper formatted data source into result.formated_data
-- the returned table is sorted first by the order in key_array, and then the local serverid first. 
-- @param key_array: the sorted key array
-- @param result: the cached result into which will assign the result to result.formated_data
-- @param roomlist: this is table returned from network. {TreasureHouse_1={fulldata="{[16]={c=0,n=\"宝箱世界哈奇小镇1\",},[17]={c=0,n=\"宝箱世界哈奇小镇2\",},}",},LightHouse_S1_10to20={fulldata="{[6]={c=0,n=\"试炼1-大家请进1\",},[7]={c=0,n=\"试炼1-大家请进2\",},}",},TheGreatTree_10to50={fulldata="{[4]={c=0,n=\"神木-高手请进\",},[5]={c=0,n=\"神木-高手练习赛\",},}",},TreasureHouse_2={fulldata="{[18]={c=0,n=\"宝箱世界火鸟岛1\",},[19]={c=0,n=\"宝箱世界火鸟岛2\",},}",},YYsDream_S1={fulldata="{[12]={c=0,n=\"梦幻火鸟岛1\",},[13]={c=0,n=\"梦幻火鸟岛2\",},}"
-- @return formated_data table. {{game_id=int, count=int, count_str=string, name=string, serverid=int}}
function LobbyClient:MakeFormattedRoomList(key_array, result, roomlist)
	LOG.std(nil, "debug", "LobbyClient", roomlist)
	local formated_data = {};
	local i, key_name;
	local WorldServerSeqId = Map3DSystem.User.WorldServerSeqId;
	local nNextLocalServerIndex = 1;
	for i, key_name in ipairs(key_array) do
		local data = roomlist[key_name];
		local game_tmpl = game_templates[key_name];
		if(game_tmpl and data and data.fulldata) then
			local rooms = NPL.LoadTableFromString(data.fulldata);
			if(rooms) then
				local game_id, game_setting
				for game_id, game_setting in pairs(rooms) do
					local room_info = {
						keyname = game_tmpl.keyname,
						game_name = game_tmpl.name,
						game_id = game_id,
						count = game_setting.c,
						name = game_setting.n,
						owner_nid = game_setting.onid,
						serverid = game_setting.sid,
						needpassword = game_setting.np,--need a  password
						max_players = game_setting.maxp,--max players
						worldname = game_setting.worldname,
						game_type = game_setting.game_type,
						min_level = game_setting.minl,
						max_level = game_setting.maxl,
						status = game_setting.s,
						mode = game_setting.mode,
						magic_star_level = game_setting.m_level,
						attack = game_setting.attack,
						count_str = format("%d/%d",  game_setting.c or 0,  (game_setting.maxp or game_tmpl.max_players or 4)),
					}
					-- this ensures that the local WorldServerSeqId is in front of the list. 
					if(room_info.serverid == WorldServerSeqId) then
						table.insert(formated_data, nNextLocalServerIndex, room_info);
						nNextLocalServerIndex = nNextLocalServerIndex + 1;
					else
						table.insert(formated_data, room_info);
					end
				end
			end
		end
	end
	if(result) then
		result.formated_data = formated_data;
	end
	return formated_data;
end