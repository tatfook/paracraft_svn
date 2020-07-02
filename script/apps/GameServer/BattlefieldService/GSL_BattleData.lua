--[[
Title: Data structures used in battle service
Author(s): LiXizhi
Date: 2011/12/25
Desc: 
-----------------------------------------------
NPL.load("(gl)script/apps/GameServer/BattlefieldService/GSL_BattleData.lua");
local battlefield = commonlib.gettable("Map3DSystem.GSL.Battle.battlefield");
local bf = battlefield:new();
bf:add_score("nid_string", nil, 10000);

-- testing: add_player_pair_by_level
NPL.load("(gl)script/apps/GameServer/BattlefieldService/GSL_BattleData.lua");
local battlefield = commonlib.gettable("Map3DSystem.GSL.Battle.battlefield");
local bf = battlefield:new();
local agents={
	["10"] = 10,
	["20"] = 20,
	["13"] = 13,
	["23"] = 23,
	["25"] = 25,
	["50"] = 50,
	["27"] = 27,
	["22"] = 22,
}
-- assign players to side if not
local i;
for i = 1, 3 do
	local last_pending_nid, last_pending_strength;
	local nid, strength;
	for nid, strength in pairs(agents) do
		-- skip logged out agents
		if(not bf:get_player_side(nid)) then
			if(strength) then
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
echo({side0 = bf:get_side_string(0), side1 = bf:get_side_string(1)})
-- result is echo:{side0="23,22,27,25,",side1="20,13,50,10,",}
-----------------------------------------------
]]
local tostring = tostring;

-- max trade items in a trade container
local max_trade_item_count = 10;

local BattleMSG = commonlib.createtable("Map3DSystem.GSL.Battle.BattleMSG",{
	-- from client to server: start trading with a given user {target_nid = string}
	-- from server to client: ask a user to start trade from another user {from_nid = string}
	BATTLE_REQUEST = 1,
	-- from client to server: a user either accept or reject the trade request {to_nid=string, accepted=boolean,}
	-- from server to client: {from_nid=string, accepted=boolean,}
    BATTLE_RESPONSE = 2,
});

-----------------------
-- resource_point class: represent a battle
------------------------

local resource_point = commonlib.createtable("Map3DSystem.GSL.Battle.resource_point", {
	--------------------------------------
	-- const configuration values:  config via GSL.config.xml
	--------------------------------------
	-- how many seconds a single player should stand on the resource point before it is fully occupied. 
	occupation_threshold = 50, -- real value
	--occupation_threshold = 20, -- debug value, make it quick to end
	-- cursor speed per player per tick. 0.001 will move the cursor 1 step per second per player. 
	cursor_speed_per_player = 0.001,
	-- base attack rate per tick. how many resource this resource point generate per millisecond. 
	attack_basevalue = 0.05, -- real value
	--attack_basevalue = 1, -- debug value, make it quick to end
	-- position: not used in current version unless position should be verified in future. 
	pos_x = 0, pos_y = 0, pos_z = 0,
	--------------------------------------
	-- dynamic members
	--------------------------------------
	-- nil, 0, 1: owner(side) of this resource point
	owner = nil,
	-- a value between (-occupation_threshold, +occupation_threshold) means the resource point is neutrual. otherwise it is either side 0 or 1. 
	cursor_point = 0,
	-- a value between[-100, 100], only used on client side for display. Use cursor_point on server side. 
	cursor_percentage = nil,
	-- the difference between (num_players_side0-num_players_side1)
	balance_num = 0,
	-- last update time, we will update by time delta. during each tick. 
	last_tick_time = nil, 
	-- time for occupation. 
	occupied_duration = 0,
	-- total resource outout to side0, simply for bookkeeping 
	output_side0 = 0,
	-- total resource outout to side1, simply for bookkeeping
	output_side1 = 0,
});

function resource_point:new(o)
	o = o or {}   -- create object if user does not provide one
	o.owner = nil;
	o.cursor_point = 0;
	o.balance_num = 0;
	setmetatable(o, self)
	self.__index = self
	return o
end

-- time (ticks) elapsed since last update call. 
-- @return owner, score_delta: owner of the resource and score generated for the owner during elapsed_time. 
function resource_point:framemove(elapsed_time)
	local score_delta = 0;
	if(self.owner == 1) then
		if(self.balance_num >= 0) then
			-- generate resource for team 1
			self.occupied_duration = self.occupied_duration + elapsed_time;
			score_delta = self.attack_basevalue*elapsed_time;
			self.output_side1 = self.output_side1 + score_delta;
		else
			-- team 0 just broke the balance. 
			self.owner = nil;
			self.occupied_duration = 0;
			self.cursor_point = self.occupation_threshold;
		end
	elseif(self.owner == 0) then
		-- team 0 is occupied, so this resource will generate 
		if(self.balance_num <= 0) then
			-- generate resource for team 0
			self.occupied_duration = self.occupied_duration + elapsed_time;
			score_delta = self.attack_basevalue*elapsed_time;
			self.output_side0 = self.output_side0 + score_delta;
		else
			-- team 1 just broke the balance. 
			self.owner = nil;
			self.occupied_duration = 0;
			self.cursor_point = -self.occupation_threshold;
		end
	else
		-- neither party has occupied this resource. 
		if(self.balance_num ~= 0) then
			self.cursor_point = self.cursor_point + self.balance_num*self.cursor_speed_per_player*elapsed_time;
			if(self.cursor_point > self.occupation_threshold) then
				self.cursor_point = self.occupation_threshold;
				self.owner = 1;
			elseif(self.cursor_point < -self.occupation_threshold) then
				self.cursor_point = -self.occupation_threshold;
				self.owner = 0;
			end
		end
	end
	return self.owner, score_delta;
end

-- convert this resource point to string
-- @return "side1" means side1, "side0" means side 0. or an interger string between (-100,100)
function resource_point:tostring()
	if(self.owner==1) then
		return "side1";
	elseif(self.owner==0) then
		return "side0";
	else
		return math.floor(self.cursor_point/self.occupation_threshold*100+0.5);
	end
end

-- called by the client side to get data from tostring(). 
function resource_point:from_data(data)
	local data_type = type(data);
	if(data_type == "string") then
		if(data == "side0") then
			self.owner = 0;
			self.cursor_percentage = -100;
		elseif(data == "side1") then
			self.owner = 1;
			self.cursor_percentage = 100;
		else
			LOG.std(nil,"warn", "resource_point", "unknown data found");
		end
	elseif(data_type == "number") then
		self.owner = nil;
		-- a value between[-100, 100];
		self.cursor_percentage = data;
	end
end

-- the balance number between (num_players_side0-num_players_side1)
function resource_point:set_balance_num(balance_num)
	self.balance_num = balance_num;
end

-----------------------
-- battle_player class
------------------------
local battle_player = commonlib.createtable("Map3DSystem.GSL.Battle.battle_player", {
	-- score of this player. 
	score = 0,
	-- fighting_spirit_value of this player,this only for kids  2013.11.5
	fighting_spirit_value = 0,
	-- the damage record which exceeds 5000 or 8000,if it appear several times ,we will don't count it's fighting_spirit_value.     this only for kids  2013.11.9
	dam_over_5000_record = {},
	dam_over_8000_record = {},
	-- whether this player is active in its gridnode
	is_active = nil,
});

function battle_player:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end


-----------------------
-- battlefield class: represent a battle
------------------------
local battlefield = commonlib.createtable("Map3DSystem.GSL.Battle.battlefield", {
	-------------------------------------
	-- battle configuration
	-------------------------------------
	-- max number of players per side. 
	max_players_side = 15,
	-- if nil, this is twice of max_players_side. otherwise it can by total player count that a match begin. must be smaller then twice of max_players_side
	-- @note: DEBUG set to 1 to debug, or nil for release. 
	--can_start_players_count = 2,
	can_start_players_count = 12,
	-- if player number is less than 4 and is already started, we will prevent any players to join the battle.
	min_players_count = 4,
	-- milliseconds to start the game after player is full. 
	-- @note: make it bigger for release version.
	start_time_after_full = 7000,
	-- when a side reaches this value, it will win
	winning_score = 200000,
	-------------------------------------
	-- private members
	-------------------------------------
	-- player count on side1
	players_count_side0 = 0,
	-- player count on side0
	players_count_side1 = 0,
	-- mapping from battle players nid to player struct. {}
	players = nil,
	-- mapping from resource id to resource points. 
	resource_points = nil,
	-- only used on client side, number of resource point taken by side 0
	side0_resouce_point_count = 0,
	-- only used on client side, number of resource point taken by side 11
	side1_resouce_point_count = 0,
	-- total score of side 0
	score_side0 = 0,
	-- total score of side 1
	score_side1 = 0,
	-- if battle is started. 
	is_started = nil,
	-- if battle is finished. 
	is_finished = nil,
	-- which side wins the battle. can be 0,1 or nil. 
	winning_side = nil,
	-- time ticks when the battle start. 
	battle_start_time = nil,
	-- elapsed time since battle is started. 
	elapsed_time = 0,
});

function battlefield:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self

	o:reset();

	return o
end

-- has begun. 
-- @param 
function battlefield:has_begun()
	return self.is_started;
end

-- reset battlefield
function battlefield:reset()
	self.players_count_side0 = 0;
	self.players_count_side1 = 0;
	self.players = {};
	self.resource_points = {
		[1] = resource_point:new(),
		[2] = resource_point:new(),
		[3] = resource_point:new(),
		[4] = resource_point:new(),
		[5] = resource_point:new(),
	};
	self.score_side0 = 0;
	self.score_side1 = 0;
	self.strength_side0 = 0;
	self.strength_side1 = 0;
	self.start_count_down = nil;
	self.is_started = nil;
	self.is_finished = nil;
	self.battle_start_time = nil;
	self.elapsed_time = 0;
	self.winning_side = nil;
	self.side0_resouce_point_count=nil;
	self.side1_resouce_point_count=nil;
	self.battle_stat = nil;
	self.battle_fighting_spirit_stat = nil;
	self.finished_fighting_spirit_stat = nil;
end

-- this function updates self.side0_resouce_point_count and self.side1_resouce_point_count
-- only used on client side, since server side does not care about the rp count. 
function battlefield:update_tower_count()
	local count0, count1 = 0, 0
	local i, rp;
	for i,rp in pairs(self.resource_points) do
		if(rp.owner == 0) then
			count0 = count0 + 1;
		elseif(rp.owner == 1) then
			count1 = count1 + 1;
		end
	end
	self.side0_resouce_point_count=count0;
	self.side1_resouce_point_count=count1;
end


-- this function should be called every 1 or 2 seconds to framemove the combat system. 
-- @param elapsed_time: milliseconds elapsed since the last call to this function. 
-- @param battleserver: the battle server object. 
function battlefield:framemove(elapsed_time, battleserver)
	
	if(self.is_started) then
		if(not self.is_finished) then
			self.elapsed_time = self.elapsed_time + elapsed_time;

			-- apply damage of all resource points 
			local rp_id, resource_point;
			for rp_id, resource_point in pairs(self.resource_points) do
				local side, score_delta = resource_point:framemove(elapsed_time);
				if(side) then
					self:add_score(nil, side, score_delta);
				end
			end

			-- check if one side wins
			if(self.score_side0 >= self.winning_score or self.score_side1 >= self.winning_score) then
				self.is_finished = true;
				if(self.score_side0 > self.score_side1) then
					self.score_side0 = self.winning_score;
					self.winning_side = 0;
				else
					self.score_side1 = self.winning_score;
					self.winning_side = 1;
				end
				self:on_battle_win(battleserver);
			end
		end
	else
		if(not self.is_finished) then
			if(self:can_start()) then
				if(not self.start_count_down) then
					self.start_count_down = self.start_time_after_full or 60000;
				end
			else
				self.start_count_down = nil;
			end
		end
		if(self.start_count_down) then
			self.start_count_down = self.start_count_down - elapsed_time;
			if(self.start_count_down <=0 ) then
				self.is_started = true;
				if(System.options.version == "kids") then
					battleserver.gridnode.combat_is_started = true;
				end
			end
		end
	end
end

-- get by resource point index or name. 
-- @param name_or_index: usually it is number id 1-5
function battlefield:get_resource_point(name_or_index)
	return self.resource_points[name_or_index];
end

-- if players are full
function battlefield:is_full()
	return (self.players_count_side0 == self.max_players_side) or (self.players_count_side1 == self.max_players_side);
end

-- if we can start the game. 
function battlefield:can_start()
	if(not self.can_start_players_count) then
		return self:is_full();
	else
		return (self.players_count_side0+self.players_count_side1)>= self.can_start_players_count;
	end
end


-- return true if battle is not full and not finished. 
function battlefield:can_join()

	return not self.is_finished 
		and ((self.players_count_side0 ~= self.max_players_side) or (self.players_count_side1 ~= self.max_players_side)) 
		and not (self.is_started and (self.players_count_side0+self.players_count_side1) < self.min_players_count );
end

-- nid, player pair of iterator
function battlefield:each_player()
	return pairs(self.players);
end

-- public: add score to a given side. 
-- @param nid: string or number. the nid who added this score. can be nil.  string is preferred. 
-- @param side: nil, 0 or 1. if nil, it will automatically read from nid's default side. 
-- it is recommended to use nil for this value, unless you are sure about the nid's side. 
-- @param value: the delta value to be added. 
function battlefield:add_score(nid, side, value, postpone_time)
	if(nid and not side) then
		side = self:get_player_side(nid)
	end
	if(side == 0) then
		self.score_side0 = self.score_side0 + value;
	elseif(side == 1) then
		self.score_side1 = self.score_side1 + value;
	end
	-- TODO: add arena score
end

-- the healing effect add 70% of score
-- @param nid: the nid that is being healed
-- @caster_nid: this is the origin of the heal
function battlefield:add_heal(nid, side, value, postpone_time, arena ,caster_nid, can_get_fighting_spirit_value)
	if(nid and not side) then
		side = self:get_player_side(nid)
	end
	if(System.options.version == "kids") then
		-- add fighting_spirit_value
		local caster_player = self:get_player(tostring(caster_nid));
		if(caster_player) then
			caster_player.score = caster_player.score + value;
			if(can_get_fighting_spirit_value) then
				battlefield:add_fighting_spirit(caster_player,value)
			end			
		end
		self:add_score(nil, side, value, postpone_time, arena)
	else
		value = value * 0.7;
		
	
		if(side) then
			if(arena) then
				local arena_side = arena:GetPlayerSide_v(nid);
				if(arena_side) then
					local count = arena:GetPlayerCount(arena_side);
					if(count>0) then
						local avg_score = value/count;
						local index, nid_from;
						for index, nid_from in arena:ForEachPlayer(arena_side) do
							local player = self:get_player(tostring(nid_from))
							if (player) then
								player.score = player.score + avg_score;
							end
						end
					end
				end
			end
			return self:add_score(nil, side, value, postpone_time, arena)
		end		
	end	
end

-- dealing damage with gear_score_v2*10 attack values. 
function battlefield:add_death(nid, side, value, postpone_time, arena)
	if(nid and arena) then
		local player = MyCompany.Aries.Combat_Server.Player.GetPlayerCombatObj(nid);
		if(player) then
			-- gear_score_v2*10 attack values. 
			value = player:GetGearScoreV2() * 10;
			-- player server object
			if(System.options.version == "teen") then
				return self:add_attack(nid, side, value, postpone_time, arena);
			else
				return;
			end
			
		end
	end
end

-- this is the oppposite of add_score
-- @param nid: this is the number nid that is being attacked. 
-- @caster_nid: this is the origin of the attack
function battlefield:add_attack(nid, side, value, postpone_time, arena, caster_nid, can_get_fighting_spirit_value)
	if(nid and not side) then
		side = self:get_player_side(nid)
		-- get the opposite side
		if(side) then
			side = 1-side;
		end
	end
	if(System.options.version == "kids") then
		local caster_player = self:get_player(tostring(caster_nid));
		if(caster_player) then
			caster_player.score = caster_player.score + value;
			if(can_get_fighting_spirit_value) then
				
				local fighting_spirit_weight = 1;
				local target_nid = tonumber(nid);
		
				if(value >= 8000) then
					local record_8000 = caster_player.dam_over_8000_record;
					if(not record_8000[target_nid]) then
						record_8000[target_nid] = 0;
					elseif(record_8000[target_nid] < 3) then
						fighting_spirit_weight = 1;
					elseif(record_8000[target_nid] == 3) then
						fighting_spirit_weight = 0.7;
					elseif(record_8000[target_nid] == 4) then
						fighting_spirit_weight = 0.3;
					elseif(record_8000[target_nid] >= 5) then
						fighting_spirit_weight = 0;
					end
					record_8000[target_nid] = record_8000[target_nid] + 1;
				end

				if(value >= 5000) then
					local record_5000 = caster_player.dam_over_5000_record;
					if(not record_5000[target_nid]) then
						record_5000[target_nid] = 0;
					elseif(record_5000[target_nid] < 4) then
						fighting_spirit_weight = 1;
					elseif(record_5000[target_nid] == 4) then
						fighting_spirit_weight = if_else(fighting_spirit_weight < 0.7,fighting_spirit_weight,0.7);
					elseif(record_5000[target_nid] == 5) then
						fighting_spirit_weight = if_else(fighting_spirit_weight < 0.3,fighting_spirit_weight,0.3);
					elseif(record_5000[target_nid] >= 6) then
						fighting_spirit_weight = 0;
					end
					record_5000[target_nid] = record_5000[target_nid] + 1;
				end

				local fighting_spirit_damage = if_else(value > 10000,10000,value);
				fighting_spirit_damage = fighting_spirit_damage*fighting_spirit_weight;

				-- add fighting_spirit_value
				battlefield:add_fighting_spirit(caster_player,fighting_spirit_damage);

				
			end
			
		end
		self:add_score(nil, side, value, postpone_time, arena)
	else
		
		if(side) then
			if(arena) then
				local arena_side = arena:GetPlayerSide_v(nid);
				if(arena_side) then
					local count = arena:GetPlayerCount(1-arena_side);
					if(count>0) then
						local avg_score = value/count;
						local index, nid_from;
						for index, nid_from in arena:ForEachPlayer(1-arena_side) do
							local player = self:get_player(tostring(nid_from))
							if (player) then
								player.score = player.score + avg_score;

							end
						end
					end
				end
			end
			return self:add_score(nil, side, value, postpone_time, arena)
		end
	end	
end

-- public: get player side
-- @param nid: number or string. string is preferred.
-- return side: side is 0,1 or nil. if nil, it is invalid player
function battlefield:get_player_side(nid)
	local player = self:get_player(tostring(nid))
	if(player) then
		return player.side;
	end
end

-- get battle player by nid. 
function battlefield:get_player(nid)
	if(nid) then
		return self.players[nid];
	end
end

local add_player_fail_time;

-- automatically add players to the weaker side according to player count and strength. 
function battlefield:add_player_pair_by_level(nid1, nid2, strength1, strength2)

	if(not nid2) then
		if(self.strength_side0 < self.strength_side1) then
			if(self.players_count_side0 < self.players_count_side1) then
				return self:add_player(nid1, 0, nil, strength1);
			else				
				if(not add_player_fail_time) then
					add_player_fail_time = self.elapsed_time;
				elseif((self.elapsed_time - add_player_fail_time)>10000) then
					add_player_fail_time = nil;
					return self:add_player(nid1, 0, nil, strength1);
				end
				-- do not do anything
			end
		elseif(self.strength_side0 == self.strength_side1) then
			-- add anyway for equal strength
			return self:add_player(nid1, 0, nil, strength1);
		else
			if(self.players_count_side0 > self.players_count_side1) then
				return self:add_player(nid1, 1, nil, strength1);
			else
				if(not add_player_fail_time) then
					add_player_fail_time = self.elapsed_time;
				elseif((self.elapsed_time - add_player_fail_time)>10000) then
					add_player_fail_time = nil;
					return self:add_player(nid1, 1, nil, strength1);
				end
				-- do not do anything
			end
		end
	else
		if(self.strength_side0 < self.strength_side1) then
			-- side0 is weaker
			if(self.players_count_side0 < self.players_count_side1) then
				-- add the stronger one to minority side, the other one pending
				if(strength1 > strength2) then
					return self:add_player(nid1, 0, nil, strength1), nil;
				else
					return nil, self:add_player(nid2, 0, nil, strength2);
				end
			else
				-- add stronger one to weaker side
				if(strength1 > strength2) then
					return self:add_player(nid1, 0, nil, strength1), self:add_player(nid2, 1, nil, strength2);
				else
					return self:add_player(nid2, 0, nil, strength2), self:add_player(nid1, 1, nil, strength1);
				end
			end
		else
			-- side1 is weaker
			if(self.players_count_side0 > self.players_count_side1) then
				-- add the stronger one to minority side, the other one pending
				if(strength1 > strength2) then
					return self:add_player(nid1, 1, nil, strength1), nil;
				else
					return nil, self:add_player(nid2, 1, nil, strength2);
				end
			else
				-- add stronger one to weaker side
				if(strength1 > strength2) then
					return self:add_player(nid1, 1, nil, strength1), self:add_player(nid2, 0, nil, strength2);
				else
					return self:add_player(nid2, 1, nil, strength2), self:add_player(nid1, 0, nil, strength1);
				end
			end
		end
	end
end

-- only used internally
-- @param nid: string;
-- @param side: 0 or 1. if nil, it will automatically add to the minority side. 
-- @param player: gridnode agent. this is not used. 
-- @param strength: strength of the player for calculating overall strength of a given side. 
-- @return side of the added player. if nil, it means not able to add, either because it is full or already exist. 
function battlefield:add_player(nid, side, player, strength)
	if(not nid or self.players[nid]) then
		return;
	end
	if(not side) then
		if(self.players_count_side0 > self.players_count_side1) then
			return self:add_player(nid, 1, player, strength);
		else
			return self:add_player(nid, 0, player, strength);
		end
	elseif(side == 0) then
		if(self.players_count_side0 < self.max_players_side) then
			self.players[nid] = battle_player:new({side=0,nid=nid, strength=strength});
			self.players_count_side0 = self.players_count_side0 + 1;
			self.strength_side0 = self.strength_side0 + (strength or 0);
			self.is_dirty_side0 = true;
			return 0;
		end
	elseif(side == 1) then
		if(self.players_count_side1 < self.max_players_side) then
			self.players[nid] = battle_player:new({side=1,nid=nid, strength=strength});
			self.players_count_side1 = self.players_count_side1 + 1;
			self.strength_side1 = self.strength_side1 + (strength or 0);
			self.is_dirty_side1 = true;
			return 1;
		end
	end
end

-- load players from side0 and side1 strings. 
-- @param side0: comma separated nid string
-- @param side1: comma separated nid string
function battlefield:from_side_string(side0, side1)
	self.players = {};
	self.players_count_side0 = 0;
	self.players_count_side1 = 0;
	local nid
	if(side0) then
		for nid in side0:gmatch("%d+") do
			self:add_player(nid, 0);
		end
	end
	if(side1) then
		for nid in side1:gmatch("%d+") do
			self:add_player(nid, 1);
		end
	end
end

-- get string of a given object to be synchronized with client. 
function battlefield:get_side_string(side)
	if(side == 0) then
		if(self.is_dirty_side0) then
			self.is_dirty_side0 = nil;
			local side0_str = "";
			local nid, player
			for nid, player in pairs(self.players) do
				if(player.side == 0) then
					side0_str = nid..","..side0_str;
				end
			end
			self.side0_str = side0_str;
		end
		return self.side0_str;
	elseif(side == 1) then
		if(self.is_dirty_side1) then
			self.is_dirty_side1 = nil;
			local side1_str = "";
			local nid, player
			for nid, player in pairs(self.players) do
				if(player.side == 1) then
					side1_str = nid..","..side1_str;
				end
			end
			self.side1_str = side1_str;
		end
		return self.side1_str;
	end
end

-- only used internally
function battlefield:remove_player(nid) 
	local player = self:get_player(nid)
	if(player) then
		self.players[nid] = nil;
		if(player.side == 0) then
			self.players_count_side0 = self.players_count_side0 - 1;
			self.strength_side0 = self.strength_side0 - (player.strength or 0);
			self.is_dirty_side0 = true;
		else
			self.players_count_side1 = self.players_count_side1 - 1;
			self.strength_side1 = self.strength_side1 - (player.strength or 0);
			self.is_dirty_side1 = true;
		end
	end
end

-- only used internally
function battlefield:get_player_score(nid) 
	local player = self:get_player(nid)
	if(player) then
		return player.score;
	end
end

-- get the elapsed battle time since start. 
function battlefield:get_battle_elapsed_time()
	return self.elapsed_time;
end

-- player has to reach this score in order to have reward. 
local min_reward_score = 2000; 
-- 20% percent of player side will get top reward. 
local top_win_percent = 0.2;
-- now in kids verison the common rewards are same,which add in this case the player have GSID 17540 or 17541     -- 2011.11.5
-- 现在儿童版中英雄谷奖励是相同的，只会根据玩家是否有17540和17541（英雄谷幸运蛋，类似红蘑菇的保险单）而不同              -- 2011.11.5
-- rewards: needs to modify according to config for kids and teen version. 
local rewards_default_kids = {
	--- 50417 英雄谷获奖次数标记，17542 英雄积分，17540和17541英雄谷幸运蛋大、小，20043 英雄谷徽章，
	win =  {exp=nil, joybean=nil, loots = { [17542]=100,[20043]=1,[50417]=1,[17577]=3 }},
	win_behas_17540 =  {exp=nil, joybean=nil, loots = {[17542]=300,[17540]=-1,[20043]=1,[50417]=1,[17577]=6 }},
	win_behas_17541 =  {exp=nil, joybean=nil, loots = {[17542]=600,[17541]=-1,[20043]=1,[50417]=1,[17577]=6 }},
    lost = {exp=nil, joybean=nil, loots = { [17542]=60,[20043]=1,[50417]=1,[17577]=1 }},
	lost_behas_17540 = {exp=nil, joybean=nil, loots = { [17542]=200,[17540]=-1,[20043]=1,[50417]=1,[17577]=6 }},
	lost_behas_17541 = {exp=nil, joybean=nil, loots = { [17542]=400,[17541]=-1,[20043]=1,[50417]=1,[17577]=6 }},

	---- 火玉17143, 5星面包17135, 英雄谷试炼徽章20043,仙豆17213,互助历练奖章17278,  -19(精力值)
	--win = {
		--top = {exp=nil, joybean=nil, loots = { [17285]=1, [20043]=1, [-19]=-10,  } },
		--middle = {exp=nil, joybean=nil, loots = { [17286]=1, [20043]=1, [-19]=-10,  } },
		--last = {exp=nil, joybean=nil, loots = { [17286]=1, [20043]=1, [-19]=-10,  } },
	--},
	--lost = {
		--top = {exp=nil, joybean=nil, loots = { [17286]=1, [-19]=-10, } },
		--middle = {exp=nil, joybean=nil, loots = { [17287]=1, [-19]=-10, } },
		--last = {exp=nil, joybean=nil, loots = { [17287]=1, [-19]=-10, } },
	--},
}
local rewards_default_teen = {
	-- 火玉17143, 5星面包17135, 英雄谷试炼徽章20043,仙豆17213, 战场徽章17227, -19(精力值)
	win = {
		top = {exp=nil, joybean=nil, loots = { [17227]=3, [17135]=2, [20043]=1, [-19]=nil, } },
		middle = {exp=nil, joybean=nil, loots = { [17227]=2, [17135]=2, [20043]=1, [-19]=nil,  } },
		last = {exp=nil, joybean=nil, loots = { [17227]=1, [17135]=1, [20043]=1, [-19]=nil,  } },
	},
	lost = {
		top = {exp=nil, joybean=nil, loots = { [17227]=2, [17135]=1, [20030]=nil, [-19]=nil } },
		middle = {exp=nil, joybean=nil, loots = { [17227]=1, [17135]=1, [20030]=nil, [-19]=nil } },
		last = {exp=nil, joybean=nil, loots = { [17227]=nil, [17135]=1, [20030]=nil, [-19]=nil } },
	}
}

local reward_pres_template = nil; -- {[-19] = 5};

local rewards_default = rewards_default_kids;

-- this didn't use now   -- 2011.11.5
local extra_rewards = {
	[1] = {from = {"17541,1"},to = {win = {"17542,200"},lost = {"17542,180"}}},
	[2] = {from = {"17540,1"},to = {win = {"17542,80"}, lost = {"17542,70"}}},
}

function battlefield:SetRewardByVersion(load_version)
	if(load_version == "teen") then
		rewards_default = rewards_default_teen;
	else
		rewards_default = rewards_default_kids;
	end
	battlefield.load_version = load_version;	
end

-- private:called when battle wins
function battlefield:on_battle_win(battleserver)
	NPL.load("(gl)script/apps/Aries/GoldRankingList/ranking_server.lua");
	local RankingServer = commonlib.gettable("MyCompany.Aries.GoldRankingList.RankingServer");
	NPL.load("(gl)script/kids/3DMapSystemItem/PowerItemManager.lua");
	local PowerItemManager = commonlib.gettable("Map3DSystem.Item.PowerItemManager");
	local beHasGSID = PowerItemManager.IfOwnGSItem;
	local getSchool = PowerItemManager.GetUserSchool;
	-- get the stats string. 
	local stats = "{";
	local fighting_spirit_stat = "{";
	local nid, player;
	local win_players = {};
	local lost_players = {};
	for nid, player in pairs(self.players) do
		if(player.side) then
			stats = stats..format("{%s,%d},", nid, player.score)
			if(battlefield.load_version == "kids") then
				

				local beHas, _, _, copies = PowerItemManager.IfOwnGSItem(nid, 50415);

				copies = if_else(copies,copies,0);
				fighting_spirit_stat = fighting_spirit_stat..format("{%s,%d,%d,%d},", nid,player.score,player.fighting_spirit_value,copies);
				local submit_score = player.fighting_spirit_value/90 + math.min(500,copies);
				
				--RankingServer.SubmitScore("FightingSpiritValue_100", tonumber(nid), nil, submit_score, function(msg) end, nil, getSchool(tonumber(nid)));
				local x = submit_score%1;
				local max_fighting_spirit = math.floor(submit_score) + if_else(x>0.5,1,0);
				RankingServer.SubmitScore("FightingSpiritValue_100", tonumber(nid), nil, max_fighting_spirit, function(msg) end, nil, getSchool(tonumber(nid)));

				local _, _, _, copies_52105 = PowerItemManager.IfOwnGSItem(nid, 52105);
				copies_52105 = if_else(copies_52105,copies_52105,0);

				local sets_str = "50415~0|23452~0|23453~0|23454~0|23455~0";
				if(max_fighting_spirit > copies_52105) then
					sets_str = sets_str.."|52102~"..tostring(max_fighting_spirit);
				end
				

				--local sets_str = "50415~0|23452~0|23453~0|23454~0|23455~0";


				PowerItemManager.ChangeItem(tonumber(nid), nil, nil, function(msg) 
					if(msg and msg.issuccess) then
						--LOG.std(nil, "debug", "PowerItemManager", "PowerItemManager.ChangeItem for adding the battlefield goods is succeed with %s", nid, updates);	
					else
						LOG.std(nil, "debug", "PowerItemManager", "PowerItemManager.ChangeItem for adding the battlefield goods with callback function got error msg:%s", nid, commonlib.serialize_compact(msg));	
					end
				end, nil, nil, nil, sets_str);


			end
			if(self.winning_side == player.side) then
				win_players[#win_players+1] = player;
			else
				lost_players[#lost_players+1] = player;
			end
		end
	end
	table.sort(win_players, function(left, right) 
			return left.score>right.score;
		end);
	table.sort(lost_players, function(left, right) 
			return left.score>right.score;
		end);

	stats = stats.."}";
	self.battle_stat = stats;
	if(battlefield.load_version == "kids") then
		fighting_spirit_stat = fighting_spirit_stat.."}";
		self.finished_fighting_spirit_stat = fighting_spirit_stat;

	end
	

	LOG.std(nil, "system", "battlefield", {"battle finished", win_players=win_players, lost_players=lost_players});
	
	-- process reward with joybean exp_pts and loots
	NPL.load("(gl)script/kids/3DMapSystemItem/PowerItemManager.lua");
	local PowerItemManager = commonlib.gettable("Map3DSystem.Item.PowerItemManager");

	local rewards = rewards_default;
	local i
	local count = #win_players;
	local head_count = math.floor(self.max_players_side*top_win_percent);
	local version = System.options.version;
	for i = 1, count do
		player = win_players[i];
		local each_nid = tonumber(player.nid);
		local reward;
		if(version == "kids") then
			if(player.fighting_spirit_value) then
				
				--reward = rewards.win;
				if(beHasGSID(each_nid,17541)) then
					--reward = rewards.win_behas_17541;
					reward = commonlib.copy(rewards.win_behas_17541);
				elseif(beHasGSID(each_nid,17540)) then
					--reward = rewards.win_behas_17540;
					reward = commonlib.copy(rewards.win_behas_17540);
				else
					reward = commonlib.copy(rewards.win);
				end

				if(beHasGSID(each_nid,12034)) then
					reward.loots[12034] = -1;
				elseif(beHasGSID(each_nid,12035)) then
					reward.loots[12035] = -1;
				end

				if(reward and each_nid) then
					local need_stanima;
					if(reward.loots and reward.loots[-19]) then
						need_stanima = true;
					end
					local userdragoninfo = PowerItemManager.GetUserAndDragonInfoInMemory(each_nid);
					if(not need_stanima or (userdragoninfo and userdragoninfo.dragon.stamina and userdragoninfo.dragon.stamina>0) ) then
						if(battleserver) then
							-- send message to client for Dock prompt  客户端提示
							battleserver:SendRealtimeMessage(tostring(each_nid), {type="add_loots", joybean=reward.joybean, loots = reward.loots});
						end
						-- add loots
						PowerItemManager.AddExpJoybeanLoots(each_nid, reward.exp, reward.joybean, reward.loots, function(msg) end, reward_pres_template);
					end
					-- now tell quest server 
					NPL.load("(gl)script/apps/Aries/Quest/QuestServerLogics.lua");
					local QuestServerLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestServerLogics");
					QuestServerLogics.DoAddValue_ByLoots(each_nid, reward.loots);
					QuestServerLogics.PvP_Successful_Handler_By_Worldname(each_nid, "BattleField_ChampionsValley", true);
				end
			end
		else
			if(player.score and player.score>min_reward_score) then
				if(i<=head_count) then
					-- winning players with top scores
					reward = rewards.win.top;
			
				elseif(i <= (count-head_count) ) then
					-- winning players with middle scores
					reward = rewards.win.middle;
				else
					-- winning players with last scores
					reward = rewards.win.last;
				end
			

				if(reward and each_nid) then
					local need_stanima;
					if(reward.loots and reward.loots[-19]) then
						need_stanima = true;
					end
					local userdragoninfo = PowerItemManager.GetUserAndDragonInfoInMemory(each_nid);
					if(not need_stanima or (userdragoninfo and userdragoninfo.dragon.stamina and userdragoninfo.dragon.stamina>0) ) then
						if(battleserver) then
							battleserver:SendRealtimeMessage(tostring(each_nid), {type="add_loots", joybean=reward.joybean, loots = reward.loots});
						end
						PowerItemManager.AddExpJoybeanLoots(each_nid, reward.exp, reward.joybean, reward.loots, function(msg) end, reward_pres_template);
					end
					-- now tell quest server 
					NPL.load("(gl)script/apps/Aries/Quest/QuestServerLogics.lua");
					local QuestServerLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestServerLogics");
					QuestServerLogics.DoAddValue_ByLoots(each_nid, reward.loots);
					QuestServerLogics.PvP_Successful_Handler_By_Worldname(each_nid, "BattleField_ChampionsValley", true);
				end
			end
		end
		
	end
	
	local i
	local count = #lost_players;
	local head_count = math.floor(self.max_players_side/5);
	for i = 1, count do
		player = lost_players[i];
		local each_nid = tonumber(player.nid);
		local reward;
		if(version == "kids") then
			if(player.fighting_spirit_value) then
				
				--reward = rewards.lost;
				if(beHasGSID(each_nid,17541)) then
					--reward = rewards.lost_behas_17541;
					reward = commonlib.copy(rewards.lost_behas_17541);
				elseif(beHasGSID(each_nid,17540)) then
					--reward = rewards.lost_behas_17540;
					reward = commonlib.copy(rewards.lost_behas_17540);
				else
					reward = commonlib.copy(rewards.lost);
				end

				if(beHasGSID(each_nid,12034)) then
					reward.loots[12034] = -1;
				elseif(beHasGSID(each_nid,12035)) then
					reward.loots[12035] = -1;
				end

				if(reward and each_nid) then
					local need_stanima;
					if(reward.loots and reward.loots[-19]) then
						need_stanima = true;
					end
					local userdragoninfo = PowerItemManager.GetUserAndDragonInfoInMemory(each_nid);
					if(not need_stanima or (userdragoninfo and userdragoninfo.dragon.stamina and userdragoninfo.dragon.stamina>0)) then
						if(battleserver) then
							battleserver:SendRealtimeMessage(tostring(each_nid), {type="add_loots", joybean=reward.joybean, loots = reward.loots});
						end
						PowerItemManager.AddExpJoybeanLoots(each_nid, reward.exp, reward.joybean, reward.loots, function(msg) end, reward_pres_template);
					end
					-- now tell quest server 
					NPL.load("(gl)script/apps/Aries/Quest/QuestServerLogics.lua");
					local QuestServerLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestServerLogics");
					QuestServerLogics.DoAddValue_ByLoots(each_nid, reward.loots);
					QuestServerLogics.PvP_Successful_Handler_By_Worldname(each_nid, "BattleField_ChampionsValley", false);
				end
			end
		else
			if(player.score and player.score>min_reward_score) then
				if(i<=head_count) then
					-- winning players with top scores
					reward = rewards.lost.top;
			
				elseif(i <= (count-head_count) ) then
					-- winning players with middle scores
					reward = rewards.lost.middle;
				else
					-- winning players with last scores
					reward = rewards.lost.last;
				end
				if(reward and each_nid) then
					local need_stanima;
					if(reward.loots and reward.loots[-19]) then
						need_stanima = true;
					end
					local userdragoninfo = PowerItemManager.GetUserAndDragonInfoInMemory(each_nid);
					if(not need_stanima or (userdragoninfo and userdragoninfo.dragon.stamina and userdragoninfo.dragon.stamina>0)) then
						if(battleserver) then
							battleserver:SendRealtimeMessage(tostring(each_nid), {type="add_loots", joybean=reward.joybean, loots = reward.loots});
						end
						PowerItemManager.AddExpJoybeanLoots(each_nid, reward.exp, reward.joybean, reward.loots, function(msg) end, reward_pres_template);
					end
					-- now tell quest server 
					NPL.load("(gl)script/apps/Aries/Quest/QuestServerLogics.lua");
					local QuestServerLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestServerLogics");
					QuestServerLogics.DoAddValue_ByLoots(each_nid, reward.loots);
					QuestServerLogics.PvP_Successful_Handler_By_Worldname(each_nid, "BattleField_ChampionsValley", false);
				end
			end
		end
		
	end

end

function battlefield:update_players_score()
	-- get the stats string. 
	local stats = "{";
	local nid, player;

	for nid, player in pairs(self.players) do
		if(player.side) then
			stats = stats..format("{%s,%d},", nid, player.score)
		end
	end
	stats = stats.."}";
	self.battle_stat = stats;
end

function battlefield:add_fighting_spirit(player,value)
	if (player) then
		player.fighting_spirit_value = player.fighting_spirit_value + value;
	end				
end

function battlefield:update_fighting_spirit_value()
	-- get the stats string. 
	local stats = "{";
	local nid, player;
	for nid, player in pairs(self.players) do
		if(player.side) then
			stats = stats..format("{%s,%d,%d},", nid,player.score,player.fighting_spirit_value)
		end
	end
	stats = stats.."}";
	self.battle_fighting_spirit_stat = stats;
end