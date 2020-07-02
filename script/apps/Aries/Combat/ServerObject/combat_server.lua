--[[
Title: Server agent template class
Author(s): 
Date: 2010/4/20
Desc: Project Aries app_main
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Combat/ServerObject/combat_server.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/GameServer/GSL_config.lua");

local format = format;
local tonumber, tostring = tonumber, tostring;
local math_random = math.random;
local math_floor = math.floor;
local LOG = LOG;
-- create class
local Combat_Server = commonlib.gettable("MyCompany.Aries.Combat_Server");

-------------------------------------
-- a special server NPC that just echos whatever received. 
-------------------------------------
-- keep a reference of the combat_server
local combat_server = commonlib.gettable("MyCompany.Aries.Combat_Server.combat_server");

-- register NPC template
Map3DSystem.GSL.config:RegisterNPCTemplate("aries_combat_system", combat_server);

-- essential combat includes
NPL.load("(gl)script/apps/Aries/Combat/ServerObject/mob_server.lua");
NPL.load("(gl)script/apps/Aries/Combat/ServerObject/player_server.lua");
NPL.load("(gl)script/apps/Aries/Combat/ServerObject/ai_module_server.lua");
NPL.load("(gl)script/apps/Aries/Combat/ServerObject/card_server.lua");
NPL.load("(gl)script/apps/Aries/Combat/ServerObject/arena_server.lua");
NPL.load("(gl)script/apps/Aries/Combat/ServerObject/msg_handler_server.lua");

NPL.load("(gl)script/kids/3DMapSystemItem/PowerItemManager.lua");
local PowerItemManager = commonlib.gettable("Map3DSystem.Item.PowerItemManager");

local Mob = commonlib.gettable("MyCompany.Aries.Combat_Server.Mob");
local Player = commonlib.gettable("MyCompany.Aries.Combat_Server.Player");
local AI_Module = commonlib.gettable("MyCompany.Aries.Combat_Server.AI_Module");
local Card = commonlib.gettable("MyCompany.Aries.Combat_Server.Card");
local Arena = commonlib.gettable("MyCompany.Aries.Combat_Server.Arena");
local Msg_Handler_server = commonlib.gettable("MyCompany.Aries.Combat_Server.Msg_Handler_server");
local GSL_gateway = commonlib.gettable("Map3DSystem.GSL.gateway");
local table_insert = table.insert;

local isInitCard = false;
local isInitMobCommon = false;
local isInitLocaleWord = false;
local isInitAutobotEssential = false;

-- pending post log messages
local pending_messages_postlog = {};
-- pending normal update messages
local pending_messages_normal_update = {};
-- pending real time messages
local pending_messages_realtime_update = {};
-- pending real time messages to user nid
local pending_messages_realtime_update_to_nid = {};

-- some arena instance require a countdown process with entrance door opening, record the countdown time of eace server object
local instance_entrance_lock_countdown = {};
local instance_entrance_lock_countdown_time = 10000;

function combat_server.CreateInstance(self, revision)
	-- overwrite virtual functions
	self.OnNetReceive = combat_server.OnNetReceive;
	self.OnFrameMove = combat_server.OnFrameMove;
	self.OnActivate = combat_server.OnActivate;
	self.OnDestroy = combat_server.OnDestroy;

	-- uncomment to overwrite default AddRealtimeMessage implementation, such as adding a message compression layer.
	-- self.AddRealtimeMessage = combat_server.AddRealtimeMessage;
	
	-- init card related data
	if(not isInitCard) then
		--log("1111111cccccc\n")
		--commonlib.echo(combat_server.version)
		-- init card key and gsid mapping
		Card.InitCardKey_gsid_mapping();
		Card.InitConstants();

		if(System.options.version == "teen") then
			-- init deck attacker ai templates from file
			Card.InitDeckAttackerAITemplates("config/Aries/Combat/DeckAttackerAITemplates.teen.xml");
			-- init card data from file
			Card.InitCardDataFromXML("config/Aries/Cards/CardList.teen.xml");
			--Card.InitCardDataFromCSV("config/Aries/Cards/CardList_csv.kids.xml"); -- NOTE: 2011/9/8 return to normal xml implementation
			-- init charm and ward data from file
			Card.InitCharmAndWardDataFromFile("config/Aries/Cards/CharmWardList.teen.xml");
			-- init card data from file
			Card.InitThreatConfigFromFile("config/Aries/Cards/CombatThreatConfig.teen.xml");
			-- init dragon totem stats data from file
			Card.InitDragonTotemStatsConfigFromFile("config/Aries/Combat/DragonTotemStats.teen.xml");
		else
			-- init deck attacker ai templates from file
			Card.InitDeckAttackerAITemplates("config/Aries/Combat/DeckAttackerAITemplates.kids.xml");
			-- init card data from file
			Card.InitCardDataFromXML("config/Aries/Cards/CardList.xml");
			--Card.InitCardDataFromCSV("config/Aries/Cards/CardList_csv.kids.xml"); -- NOTE: 2011/9/8 return to normal xml implementation
			-- init charm and ward data from file
			Card.InitCharmAndWardDataFromFile("config/Aries/Cards/CharmWardList.xml");
			-- init card data from file
			Card.InitThreatConfigFromFile("config/Aries/Cards/CombatThreatConfig.xml");
			-- init dragon totem stats data from file
			Card.InitDragonTotemStatsConfigFromFile("config/Aries/Combat/DragonTotemStats.xml");
		end
		isInitCard = true;
	end

	--if(System.options.version == "teen") then
		--if(not isInitMobCommon) then
			--Mob.InitCommonAttributes_csv("config/Aries/Mob_Teen/Common_Attrbutes.csv")
			--Mob.InitCommonLoots_csv("config/Aries/Mob_Teen/Common_Loots.csv")
			--isInitMobCommon = true;
		--end
	--end
	
	if(System.options.version == "teen") then
		if(not isInitLocaleWord) then
			local locale = System.options.locale;
			Mob.InitLocaleWord(locale);
			--Arena.InitLocaleWord(locale);
			isInitLocaleWord = true;
		end
	end

	if(not isInitAutobotEssential) then
		Mob.InitAutobotEssential();
		isInitAutobotEssential = true;
	end

	-- read serverobject npc data
	local arenas_mobs_config;
	local arenas_mobs_isinstance;
	local arenas_mobs;
	for arenas_mobs in commonlib.XPath.eachNode(self.npc_node, "/arenas_mobs") do
		arenas_mobs_config = arenas_mobs.attr.config;
		arenas_mobs_isinstance = arenas_mobs.attr.isinstance;
		if(arenas_mobs_isinstance == true or arenas_mobs_isinstance == "true") then
			arenas_mobs_isinstance = true;
		else
			arenas_mobs_isinstance = nil;
		end
	end

	-- set the world config file, the config file works as key to each queue
	self.world_config_file = arenas_mobs_config;
	self.world_isinstance = arenas_mobs_isinstance;
	self.unique_id = ParaGlobal.GenerateUniqueID();
	-- load arena and mob from config file
	self.arena_ids = Arena.InitArenaAndMobFromFile(arenas_mobs_config, arenas_mobs_isinstance, self.unique_id, self.gridnode, self.explicitXMLRoot);

	if(arenas_mobs_config == "config/Aries/WorldData/HaqiTown_RedMushroomArena_1v1.Arenas_Mobs.xml" or 
		arenas_mobs_config == "config/Aries/WorldData/HaqiTown_RedMushroomArena_2v2.Arenas_Mobs.xml" or 
		arenas_mobs_config == "config/Aries/WorldData/HaqiTown_RedMushroomArena_3v3.Arenas_Mobs.xml" or 
		arenas_mobs_config == "config/Aries/WorldData/HaqiTown_RedMushroomArena_4v4.Arenas_Mobs.xml" or
		arenas_mobs_config == "config/Aries/WorldData/HaqiTown_LafeierCastle_PVP_Matcher.Arenas_Mobs.xml") then
		---- get match_info
		--local gridnode = self.gridnode;
		--local match_info;
		--if(gridnode) then
			--match_info = gridnode.match_info;
			---- autojoin pvp arena with arena info
			--if(match_info) then
				--Arena.AutoJoinPvPArena(self.arena_ids, match_info);
			--end
		--end
		-- set instance entrance lock count down time
		instance_entrance_lock_countdown[self.unique_id] = combat_server.GetCurrentTime();
		if(instance_entrance_lock_countdown[self.unique_id] == 0) then
			instance_entrance_lock_countdown[self.unique_id] = ParaGlobal.timeGetTime();
		end
	end
end

-- appending server post log message table
-- @param msg_table: a table or string. 
-- @param bLocalTextLogOnly: if true, we will only log locally to log.txt, otherwise defaults to post to remote log server. 
function combat_server.AppendPostLog(msg_table, bLocalTextLogOnly)
	if(bLocalTextLogOnly) then
		LOG.std(nil, "user","combat_server","AppendPostLog(LocalOnly):%s",commonlib.serialize_compact(msg_table));
	else
		LOG.std(nil, "user","combat_server","AppendPostLog:%s",commonlib.serialize_compact(msg_table));
		if(type(msg_table) == "table") then
			table.insert(pending_messages_postlog, msg_table);
		end
	end
end

-- appending normal update message
function combat_server.AppendNormalUpdateMessage(combat_server_uid, key, value)
	if(not pending_messages_normal_update[combat_server_uid]) then
		pending_messages_normal_update[combat_server_uid] = {};
	end
	table_insert(pending_messages_normal_update[combat_server_uid], {key = key, value = value});
end

-- appending real time message
-- NOTE: a combat prefix is automatically added: [Aries][combat_to_client]
function combat_server.AppendRealTimeMessage(combat_server_uid, msg)
	LOG.std(nil, "user","combat_server","AppendRealTimeMessage:%s",commonlib.serialize_compact(msg));
	if(not pending_messages_realtime_update[combat_server_uid]) then
		pending_messages_realtime_update[combat_server_uid] = {};
	end
	--commonlib.applog("combat_server.AppendRealTimeMessage");
	--log(msg.."\n");
	table_insert(pending_messages_realtime_update[combat_server_uid], "[Aries][combat_to_client]"..msg);
end

-- appending real time message to user nid
-- NOTE: a combat prefix is automatically added: [Aries][combat_to_client]
function combat_server.AppendRealTimeMessageToNID(combat_server_uid, nid, msg)
	LOG.std(nil, "user","combat_server","AppendRealTimeMessageToNID:%s,%s",tostring(nid),commonlib.serialize_compact(msg));
	if(not pending_messages_realtime_update_to_nid[combat_server_uid]) then
		pending_messages_realtime_update_to_nid[combat_server_uid] = {};
	end
	--commonlib.applog("combat_server.AppendRealTimeMessageToNID %d", nid);
	--log(msg.."\n");
	table_insert(pending_messages_realtime_update_to_nid[combat_server_uid], {nid = nid, msg = "[Aries][combat_to_client]"..msg});
end

-- try send pending message and normal update
-- @param revision: normal update revision
function combat_server.TrySendPendingAllMessages(server_obj, revision)
	if(not server_obj) then
		LOG.std(nil, "error", "combat_server", "error: nil server object got in combat_server.TrySendPendingAll");
		return;
	end
	-- world config file
	local combat_server_uid = server_obj.unique_id;

	-- check post log messages
	if(#pending_messages_postlog>0) then
		local _, o;
		for _, o in ipairs(pending_messages_postlog) do
			o.msg_src = "gameserver";
			paraworld.PostServerLog(o, "server_post_log");
		end
		-- clear post log messages
		pending_messages_postlog = {};
	end

	-- check normal update messages
	local _, o;
	for _, o in ipairs(pending_messages_normal_update[combat_server_uid] or {}) do
		server_obj:SetValue(o.key, o.value, revision);
	end
	-- clear normal update messages
	pending_messages_normal_update[combat_server_uid] = {};
	-- check real time messages
	local _, msg;
	for _, msg in ipairs(pending_messages_realtime_update[combat_server_uid] or {}) do
		server_obj:AddRealtimeMessage(msg);
	end
	-- clear normal update messages
	pending_messages_realtime_update[combat_server_uid] = {};
	-- check real time messages to nid
	local _, o;
	for _, o in ipairs(pending_messages_realtime_update_to_nid[combat_server_uid] or {}) do
		server_obj:SendRealtimeMessage(tostring(o.nid), o.msg);
	end
	-- clear normal update messages
	pending_messages_realtime_update_to_nid[combat_server_uid] = {};
end

-- whenever an instance of this server agent has received a real time message from client (from_nid) in gridnode, this function will be called.  
function combat_server:OnNetReceive(from_nid, gridnode, msg, revision)
	
	-- set current time
	current_time = ParaGlobal.timeGetTime();

	if(from_nid and gridnode) then
		LOG.std(nil, "user","combat_server","nid=%s|NetReceive:%s",from_nid,msg.body);
		Msg_Handler_server.MsgProc(from_nid, msg.body);		
	end

	-- additional framemove for nid
	from_nid = tonumber(from_nid);
	
	-- on frame move arena objects
	Arena.OnFrameMove_for_nid(from_nid, combat_server.GetCurrentTime());
	
	-- try sending all pending messages
	combat_server.TrySendPendingAllMessages(self, revision);
	
	---- echo real time message to client
	--self:AddRealtimeMessage(msg)
end

-- current game server time
local current_time = 0;
function combat_server.GetCurrentTime()
	return current_time;
end

-- This function is called by gridnode at normal update interval. One can update persistent data fields in this functions. 
function combat_server:OnFrameMove(curTime, revision)
	-- current time in milli-seconds
	-- cast the current time to integar
	curTime = math.floor(curTime);
	-- set current time
	current_time = curTime;
	
	-- on frame move arena objects
	Arena.OnFrameMove_for_serverobject(curTime, self.arena_ids);
	
	-- combat_server.AppendRealTimeMessage("heartbeat:"..curTime)

	-- update the exp scale acc
	self:SetValue("GlobalExpScaleAcc", PowerItemManager.GetGlobalExpScaleAcc(), revision);

	if(instance_entrance_lock_countdown[self.unique_id]) then
		-- send realtime message of the count down
		local remaining = 10000 + instance_entrance_lock_countdown[self.unique_id] - combat_server.GetCurrentTime();
		if(remaining > 0) then
			self:AddRealtimeMessage("[Aries][combat_to_client]InstanceEntranceLockCountdown:"..tostring(remaining));
		else
			instance_entrance_lock_countdown[self.unique_id] = nil;
			self:AddRealtimeMessage("[Aries][combat_to_client]InstanceEntranceLockOpen:1");
			self:SetValue("InstanceEntranceLockOpen", true, revision);
		end
	end
	
	-- try sending all pending messages
	combat_server.TrySendPendingAllMessages(self, revision);
	
	-- on check date
	PowerItemManager.OnCheckDate(self.unique_id);
end

-- this function is called whenever the parent gridnode is made from unactive to active mode or vice versa. 
-- A gridnode is made inactive by its gridnode manager whenever all client agents are left, so it calls this 
-- function and put the gridnode to cache pool for reuse later on. 
-- Whenever a gridnode is first loaded or activated again, this function will also be called. 
-- @param bActivate: true if gridnode is active or false if unactive. 
function combat_server:OnActivate(bActivate)
	if(not bActivate) then
		self:OnDestroy();
		LOG.std(nil, "debug", "combat_server", "combat server inactivated");
	else
		-- load arena and mob from config file
		self.arena_ids = Arena.InitArenaAndMobFromFile(self.world_config_file, self.world_isinstance, self.unique_id, self.gridnode, self.explicitXMLRoot);
		LOG.std(nil, "debug", "combat_server", "combat server Activated");
		if(self.world_config_file == "config/Aries/WorldData/HaqiTown_RedMushroomArena_1v1.Arenas_Mobs.xml" or 
			self.world_config_file == "config/Aries/WorldData/HaqiTown_RedMushroomArena_2v2.Arenas_Mobs.xml" or 
			self.world_config_file == "config/Aries/WorldData/HaqiTown_RedMushroomArena_3v3.Arenas_Mobs.xml" or 
			self.world_config_file == "config/Aries/WorldData/HaqiTown_RedMushroomArena_4v4.Arenas_Mobs.xml" or
			self.world_config_file == "config/Aries/WorldData/HaqiTown_RedMushroomArena_1v1_599.Arenas_Mobs.xml" or
			self.world_config_file == "config/Aries/WorldData/HaqiTown_RedMushroomArena_1v1_799.Arenas_Mobs.xml" or
			self.world_config_file == "config/Aries/WorldData/HaqiTown_RedMushroomArena_1v1_999.Arenas_Mobs.xml" or
			self.world_config_file == "config/Aries/WorldData/HaqiTown_RedMushroomArena_2v2_1999.Arenas_Mobs.xml" or
			self.world_config_file == "config/Aries/WorldData/HaqiTown_RedMushroomArena_2v2_5000.Arenas_Mobs.xml" or
			self.world_config_file == "config/Aries/WorldData/HaqiTown_LafeierCastle_PVP_Matcher.Arenas_Mobs.xml") then
			-- get match_info
			local gridnode = self.gridnode;
			local match_info;
			if(gridnode) then
				match_info = gridnode.match_info;
				if(match_info) then
					-- set match info to prevent malicious player
					Arena.SetMatchInfo(self.arena_ids, match_info);
					---- autojoin pvp arena with arena info
					--Arena.AutoJoinPvPArena(self.arena_ids, match_info);
				end
			end
			-- set instance entrance lock count down time
			instance_entrance_lock_countdown[self.unique_id] = combat_server.GetCurrentTime();
			if(instance_entrance_lock_countdown[self.unique_id] == 0) then
				instance_entrance_lock_countdown[self.unique_id] = ParaGlobal.timeGetTime();
			end
		end
	end
end

-- This function is called by gridnode before the server object is actually destroyed and set to nil
function combat_server:OnDestroy()
	local _, arena_id;
	for _, arena_id in pairs(self.arena_ids) do
		local arena = Arena.GetArenaByID(arena_id);
		if(arena) then
			arena:OnDestroy();
		end
	end
end