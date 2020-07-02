--[[
Title: Battle NPC server
Author(s): LiXizhi
Date: 2011/10/12
Desc: 
-----------------------------------------------
NPL.load("(gl)script/apps/GameServer/BattlefieldService/GSL_BattleServer.lua");
local battle_server = my_gridnode:GetServerObject("battle");
if(battle_server and battle_server.battle_field) then
	local bf = battle_server.battle_field;

	if(bf:has_begun()) then
		-- adding score
		bf:add_score("nid_string", nil, 10000);

		-- get nid side: return 0, 1, or nil.
		local side = bf:get_player_side(nid);
	
		-- set balance number on 1-5 resource point
		local rp = bf:get_resource_point(1)
		if(rp) then
			rp:set_balance_num(1);
		end
	end
end
-----------------------------------------------
]]
NPL.load("(gl)script/ide/timer.lua");
NPL.load("(gl)script/apps/GameServer/BattlefieldService/GSL_BattleData.lua");
NPL.load("(gl)script/kids/3DMapSystemItem/PowerItemManager.lua");
local PowerItemManager = commonlib.gettable("Map3DSystem.Item.PowerItemManager");
NPL.load("(gl)script/apps/GameServer/BattlefieldService/GSL_BattleData.lua");
local battlefield = commonlib.gettable("Map3DSystem.GSL.Battle.battlefield");
local BattleMSG = commonlib.gettable("Map3DSystem.GSL.Battle.BattleMSG")
local resource_point = commonlib.gettable("Map3DSystem.GSL.Battle.resource_point");

local tostring = tostring;
local tonumber = tonumber;
local format = format;
local type = type;
-- create class
local GSL_BattleServer = commonlib.inherit(nil, commonlib.gettable("Map3DSystem.GSL.Battle.GSL_BattleServer"))

-- whether to output log by default. 
local enable_debug_log = false;

-- the global instance, because there is only one instance of this object
local g_singleton;

-- we will check if any player leaves or joins the battle every this interval from the gridnode's active agents. 
local check_player_interval = 5000; 
-- if player is not active for this interval we will remove it from the battle, so that new player can fill its position. 
local player_left_interval = 90000;

------------------------
--  BattleServer class: static NPC method
------------------------
local BattleServer = {};
Map3DSystem.GSL.config:RegisterNPCTemplate("battle", BattleServer)
function BattleServer.CreateInstance(self, revision)
	-- overwrite virtual functions
	self.OnNetReceive = BattleServer.OnNetReceive;
	self.OnFrameMove = BattleServer.OnFrameMove;
	self.OnActivate = BattleServer.OnActivate;

	self.battle_field = battlefield:new();

	-- keeps a global reference
	BattleServer.server = self; 
	LOG.std(nil, "info","BattleServer", "CreateInstance");
end

-- this function is called whenever the parent gridnode is made from unactive to active mode or vice versa. 
-- A gridnode is made inactive by its gridnode manager whenever all client agents are left, so it calls this 
-- function and put the gridnode to cache pool for reuse later on. 
-- Whenever a gridnode is first loaded or activated again, this function will also be called. 
-- @param bActivate: true if gridnode is active or false if unactive. 
function BattleServer:OnActivate(bActivate)
	self.gridnode.is_started = false;
	self.gridnode.combat_is_started = false;
	self.battle_field:reset();
	self:RemoveAllValues();
end

-- whenever an instance of this server agent has received a real time message from client (from_nid) in gridnode, this function will be called.  
function BattleServer:OnNetReceive(from_nid, gridnode, msg, revision)
	if(from_nid and gridnode) then
		-- update the global reference until the next net receive call.
		BattleServer.server = self;

		if(type(msg) == "table") then
			-- this is not only used for debugging. 
			if(msg.type == "StartGame") then
				local bf = self.battle_field;
				if(not bf.is_started) then
					bf.is_started = true;
					if(System.options.version == "kids") then
						self.gridnode.combat_is_started = true;
					end
				end
			end
		end
	end
end

-- This function is called by gridnode at normal update interval. One can update persistent data fields in this functions. 
function BattleServer:OnFrameMove(curTime, revision)
	local elapsed_time = curTime - (self.last_time or curTime);
	self.last_time = curTime;
	if(elapsed_time > 10000) then
		elapsed_time = 10000;
	end
	if(not self.last_player_tick or (curTime - self.last_player_tick) > check_player_interval) then
		self.last_player_tick = curTime;
		BattleServer.OnCheckPlayer(self);
	end
	local bf = self.battle_field;
	bf:framemove(elapsed_time, self);
	if(System.options.version == "kids") then
		bf:update_players_score();
		bf:update_fighting_spirit_value();
	end
	if(not bf.is_started) then
		self:UpdateValue("start_count_down", bf.start_count_down, revision);
		-- comma separated nid strings of each side
		self:UpdateValue("side0", bf:get_side_string(0), revision);
		self:UpdateValue("side1", bf:get_side_string(1), revision);
		
	elseif(not bf.is_finished) then
		-- score of both sides. 
		self:UpdateValue("score0", bf.score_side0, revision);
		self:UpdateValue("score1", bf.score_side1, revision);

		-- comma separated nid strings of each side
		self:UpdateValue("side0", bf:get_side_string(0), revision);
		self:UpdateValue("side1", bf:get_side_string(1), revision);

		-- resource point cursor location
		-- TODO: shall we support variable resource point? currently it is just 5. 
		self:UpdateValue("rp1", bf:get_resource_point(1):tostring(), revision);
		self:UpdateValue("rp2", bf:get_resource_point(2):tostring(), revision);
		self:UpdateValue("rp3", bf:get_resource_point(3):tostring(), revision);
		self:UpdateValue("rp4", bf:get_resource_point(4):tostring(), revision);
		self:UpdateValue("rp5", bf:get_resource_point(5):tostring(), revision);
		if(System.options.version == "kids") then
			self:UpdateValue("battle_stat", bf.battle_stat, revision);
			self:UpdateValue("battle_fighting_spirit_stat", bf.battle_fighting_spirit_stat, revision);
		end
	else
		self:UpdateValue("winning_side", bf.winning_side, revision);
		self:UpdateValue("battle_stat", bf.battle_stat, revision);
		self:UpdateValue("score0", bf.score_side0, revision);
		self:UpdateValue("score1", bf.score_side1, revision);
		-- this will prevent any user from joining this world again. 
		
		self.gridnode.is_started = true;

		if(System.options.version == "kids") then
			self:UpdateValue("battle_stat", bf.battle_stat, revision);
			self:UpdateValue("finished_fighting_spirit_stat", bf.finished_fighting_spirit_stat, revision);
		end
	end
	self:UpdateValue("is_started", bf.is_started, revision);
	self:UpdateValue("is_finished", bf.is_finished, revision);
	self:UpdateValue("winning_score", bf.winning_score, revision);
end


-- get the strength by level. 
-- TODO: use a more accurate gs function. 
local function get_player_strength_by_level(level)
	local strength;
	if(level) then
		strength = level;
		if(level>=50)  then
			strength = level*3;
		elseif(level>45)  then
			strength = level*2.5;
		elseif(level>40)  then
			strength = level*2;
		elseif(level>30)  then
			strength = level*1.5;
		elseif(level>20)  then
			strength = level;
		end
	end
	return strength;
end 

-- this function is called periodically to check to see if any player joins or leaves the battle. 
function BattleServer.OnCheckPlayer(self)
	-- forward the message to all other agents immediately
	local bf = self.battle_field;
	local gridnode = self.gridnode;

	if(System.options.version == "kids") then
		player_left_interval = 4000;
	end

	-- assign players to side if not
	local last_pending_nid, last_pending_strength;
	local nid, agent;
	for nid, agent in pairs(gridnode.agents) do
		-- skip logged out agents
		if( (agent.state~=3)) then	
			if(not bf:get_player_side(nid)) then
				if(System.options.version == "kids") then
					--PowerItemManager.ChangeItem(nid,1857);
					--local sets_str = "50415~500|23452~0|23453~0|23454~0|23455~0";
					local sets_str = "50415~500|";
					--PowerItemManager.ChangeItem(nid, nil, nil, function(msg)
						--if(callbackFunc) then
							--callbackFunc(msg);
						--end
					--end, nil, nil, nil, sets_str);

					PowerItemManager.ChangeItem(tonumber(nid), nil, nil, function(msg) 
						if(msg and msg.issuccess) then
							--LOG.std(nil, "debug", "PowerItemManager", "PowerItemManager.ChangeItem for adding the battlefield goods is succeed with %s", nid, updates);	
						else
							LOG.std(nil, "debug", "PowerItemManager", "PowerItemManager.ChangeItem for adding the battlefield goods with callback function got error msg:%s", nid, commonlib.serialize_compact(msg));	
						end
					end, nil, nil, nil, sets_str);
				end
				

				local strength;
				if(System.options.version == "kids") then
					local _,_,_,copies = PowerItemManager.IfOwnGSItem(tonumber(nid),965)
					strength = if_else(copies,copies,250);
				else
					local level = PowerItemManager.GetUserCombatLevel(tonumber(nid));
					strength = get_player_strength_by_level(level)
				end
				if(strength) then
					-- bf:add_player(nid, nil, agent);
					if(last_pending_nid) then
						local side1, side2 = bf:add_player_pair_by_level(last_pending_nid, nid, last_pending_strength, strength);
						if(not side2) then
							last_pending_nid, last_pending_strength = nid, strength;
						elseif(side1) then
							last_pending_nid, last_pending_strength = nil, nil;
						end
					else
						local side = bf:add_player_pair_by_level(nid, nil, strength, nil);
						if(not side) then
							last_pending_nid, last_pending_strength = nid, strength;
						end
					end
					-- update will be sent via normal update. 
				end
			end
		end
	end
	
	-- remove non-exist agent
	local left_players;
	local nid, player;
	for nid, player in bf:each_player() do

		agent = gridnode:FindAgent(nid);
		if (agent and agent.state~=3) then
			if(not player.is_active) then
				player.is_active = true;
				player.left_countdown = nil;
			end
		else
			if(player.is_active) then
				player.left_countdown = 0;
				player.is_active = false;
			else

				player.left_countdown = (player.left_countdown or 0) + check_player_interval;

				if(player.left_countdown > player_left_interval) then
					left_players = left_players or {};
					left_players[nid] = player;
				end
			end
		end
	end

	if(left_players) then
		local nid, player;
		for nid, player in pairs(left_players) do
			-- function PowerItemManager.ChangeItem(nid, adds, updates, callbackFunc, isgreedy, pres, logevent, sets)
			-- adds_str = adds_str..format("%d~%d~%s~%s|", loot.get[i].gsid, loot.get[i].count, "NULL", "NULL");
			--local updates = "";
			--local destroylist = {50415,50416,23452,23453,23454,23455};
			--local i;
			--for i = 1,#destroylist do
				--local gsid = destroylist[i];
				--echo("777777777");
				--echo(gsid);
				--local beHas,guid,_,copies = PowerItemManager.IfOwnGSItem(nid,gsid)
				--if(beHas) then
					--echo("6666666666");
					--updates = updates..format("%d~%d~%s~%s|", guid, copies, "NULL", "NULL");
				--end
				--
			--end
			--local beHas,guid,_,copies = PowerItemManager.IfOwnGSItem(nid,17213)
			--echo(copies);
			----updates = updates..format("%d~%d~%s~%s|", 50416, 1, "NULL", "NULL");
			--echo("222222222222");
			--echo(updates);
			--if(updates ~= "") then
				--PowerItemManager.ChangeItem(tonumber(nid), "", updates, function(msg) 
					--if(msg and msg.issuccess) then
						----LOG.std(nil, "debug", "PowerItemManager", "PowerItemManager.ChangeItem for destroying the battlefield goods is succeed with %s", nid, updates);	
					--else
						--LOG.std(nil, "debug", "PowerItemManager", "PowerItemManager.ChangeItem for destroying the battlefield goods with callback function got error msg:%s", nid, commonlib.serialize_compact(msg));	
					--end
				--end, true, "", true)
			--end
			if(System.options.version == "kids") then
				local sets_str = "50415~0|23452~0|23453~0|23454~0|23455~0";


				PowerItemManager.ChangeItem(tonumber(nid), nil, nil, function(msg) 
					if(msg and msg.issuccess) then
						--LOG.std(nil, "debug", "PowerItemManager", "PowerItemManager.ChangeItem for adding the battlefield goods is succeed with %s", nid, updates);	
					else
						LOG.std(nil, "debug", "PowerItemManager", "PowerItemManager.ChangeItem for adding the battlefield goods with callback function got error msg:%s", nid, commonlib.serialize_compact(msg));	
					end
				end, nil, nil, nil, sets_str);

				--local adds_str = "";
				--local add_list = {
					--[23452] = -999,
					--[23453] = -999,
					--[23454] = -999,
					--[23455] = -999,
				--};
				--local gsid,count;
				--for gsid,count in pairs(add_list) do
					--adds_str = adds_str..format("%d~%d~%s~%s|", gsid, count, "NULL", "NULL");
				--end
--
				--PowerItemManager.ChangeItem(tonumber(nid), adds_str, "", function(msg) 
					--if(msg and msg.issuccess) then
						----LOG.std(nil, "debug", "PowerItemManager", "PowerItemManager.ChangeItem for adding the battlefield goods is succeed with %s", nid, updates);	
					--else
						--LOG.std(nil, "debug", "PowerItemManager", "PowerItemManager.ChangeItem for adding the battlefield goods with callback function got error msg:%s", nid, commonlib.serialize_compact(msg));	
					--end
				--end, true, "", true)	
			end
			bf:remove_player(nid);
		end
	end
	-- whether we will allow new users to join the battle.
	if(bf:can_join()) then
		self.gridnode.is_started = false;
	else
		self.gridnode.is_started = true;
	end
end

------------------------
--  GSL_BattleServer class: Not used. 
------------------------
function GSL_BattleServer:ctor()
	-- enable debugging here
	self.debug_stream = self.debug_stream or enable_debug_log;
end

-- get the global singleton.
function GSL_BattleServer.GetSingleton()
	if(not g_singleton) then
		g_singleton = GSL_BattleServer:new();
	end
	return g_singleton;
end

-- do some one time init here
-- @param msg: {debug_stream="true", max_players_side="15", etc.}
-- the params are module node attribute in modules GSL.config.xml
function GSL_BattleServer:init(msg)
	msg = msg or {};
	-- battle update inverval.  
	self.timer_interval = msg.timer_interval or 2000;
	if(msg.debug_stream == "true") then
		self.debug_stream = true;
	end
	self.load_version = msg.version;

	NPL.load("(gl)script/apps/GameServer/BattlefieldService/GSL_BattleData.lua");
	local battlefield = commonlib.gettable("Map3DSystem.GSL.Battle.battlefield");
	battlefield:SetRewardByVersion(self.load_version);

	battlefield.max_players_side = tonumber(msg.max_players_side) or battlefield.max_players_side;
	battlefield.can_start_players_count = tonumber(msg.can_start_players_count) or battlefield.can_start_players_count;
	battlefield.start_time_after_full = tonumber(msg.start_time_after_full) or battlefield.start_time_after_full;
	battlefield.winning_score = tonumber(msg.winning_score) or battlefield.winning_score;

	resource_point.occupation_threshold = tonumber(msg.occupation_threshold) or resource_point.occupation_threshold;
	resource_point.cursor_speed_per_player = tonumber(msg.cursor_speed_per_player) or resource_point.cursor_speed_per_player;
	resource_point.attack_basevalue = tonumber(msg.attack_basevalue) or resource_point.attack_basevalue;
end
