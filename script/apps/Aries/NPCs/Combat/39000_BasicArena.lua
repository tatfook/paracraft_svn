--[[
Title: BasicArena
Author(s): WangTian
Date: 2009/8/24

use the lib:

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/Combat/39000_BasicArena.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Combat/MsgHandler.lua");
NPL.load("(gl)script/ide/Debugger/NPLProfiler.lua");
local npl_profiler = commonlib.gettable("commonlib.npl_profiler");
-- create class
local libName = "BasicArena";
local BasicArena = commonlib.gettable("MyCompany.Aries.Quest.NPCs.BasicArena");
local BasicArena_Treasurebox = commonlib.gettable("MyCompany.Aries.Quest.NPCs.BasicArena_Treasurebox");
local ObjectManager = commonlib.gettable("MyCompany.Aries.Combat.ObjectManager");

local GameObject = commonlib.gettable("MyCompany.Aries.Quest.GameObject");
local NPC = commonlib.gettable("MyCompany.Aries.Quest.NPC");
local MsgHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");
local ItemManager = commonlib.gettable("System.Item.ItemManager");

local Pet = commonlib.gettable("MyCompany.Aries.Pet");
local EffectManager = commonlib.gettable("MyCompany.Aries.EffectManager");

local Player = commonlib.gettable("MyCompany.Aries.Player");

local NPC = commonlib.gettable("MyCompany.Aries.Quest.NPC");		

NPL.load("(gl)script/ide/TooltipHelper.lua");
local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");

NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");

NPL.load("(gl)script/apps/Aries/Scene/AutoFollowAI.lua");
local AutoFollowAI = commonlib.gettable("MyCompany.Aries.AI.AutoFollowAI");
NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClient.lua");
local LobbyClient = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClient");
local game_info = commonlib.gettable("Map3DSystem.GSL.Lobby.game_info");
local CombatTutorial = commonlib.gettable("MyCompany.Aries.Quest.NPCs.CombatTutorial");
local CombatPipTutorial = commonlib.gettable("MyCompany.Aries.Quest.NPCs.CombatPipTutorial");

NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");

local safe_area_heal_tick = 100;

-- how many seconds to recover the player's hp from 0 to max. Standing will double this value. 
-- please note that 50 is a good value for slow recovery, 4 is fast recover. 
BasicArena.HP_recover_heal_count = 4;

-- BasicArena.main
function BasicArena.main()
end

-- BasicArena.PreDialog
function BasicArena.PreDialog(arena_id)
	--MsgHandler.OnEnterCombat(arena_id - 10000)
	return false;
end

-- BasicArena.main
function BasicArena_Treasurebox.main()
end

function BasicArena_Treasurebox.PreDialog(npc_id)
	local arena_id = ObjectManager.GetArena_ID_From_TreasureBox_NPC_ID(npc_id);
	if(arena_id) then
		MyCompany.Aries.Combat.MsgHandler.OnLootTreasureBox(arena_id);
	end
	return false;
end

-- enter combat range
local combat_range_sq = 350;
-- alert combat danger range
local alert_combat_range_sq = 570;

-- enter combat range
local combat_range = math.ceil(math.sqrt(combat_range_sq));

-- slow down timer ticks
local slowdown_timer_ticks = nil;

-- immortal countdown for after flee effect
local immortal_countdown = nil;
local immortal_tips_countdown = nil;

-- become immortal for the next 8 seconds if user leave the arena or fled
-- time period is 500 milliseconds
local immortal_time = 16;

-- immortal for a period of time for other non-auto player enter combat first
local immortal_time_auto_entercombat_delay = 20;

-- slow down timer ticks for update user names
local slowdown_timer_ticks_update_usernames = 13;

-- record myself arena key
local myself_arena_key = nil;

-- last heart beat time
local last_heart_beat_time = ParaGlobal.GetGameTime();

-- send heart beat message interval
local send_heart_beat_interval = 3000;

-- last heal by time time
local last_heal_by_time_time = 0;

function BasicArena.GetEnterCombatRadius()
	if(System.options.version == "teen") then
		combat_range_sq = 350;
		alert_combat_range_sq = 1500;
	end
	local world_info = WorldManager:GetCurrentWorld();
	if(world_info and world_info.enter_combat_range) then
		return world_info.enter_combat_range, world_info.enter_combat_range_sq, world_info.alert_combat_range_sq;
	end
	return combat_range, combat_range_sq, alert_combat_range_sq;
end

-- return true if player is standing on the immortal position. 
function BasicArena.IsInImmortalPosition()
	
	local world_info = WorldManager:GetCurrentWorld();
	if(world_info.team_mode == "battlefield") then
		return false;
	end

	if(BasicArena.immortal_position) then
		local x, y, z = Player.GetPlayer():GetPosition();
		if( (math.abs(BasicArena.immortal_position[1]-x)+math.abs(BasicArena.immortal_position[3]-z))>0.2) then
			BasicArena.immortal_position = nil;
		else
			return true;
		end
	end
end

local is_enter_combat_enabled = true;

-- whether to allow entering combat. One should remember to set it back to true. 
-- @param bEnable: true to enable entering combat. 
function BasicArena.EnableEnterCombat(bEnable)
	is_enter_combat_enabled = bEnable;
end

function BasicArena.CanEnterCombat()
	return is_enter_combat_enabled;
end

local is_global_timer_enabled;
-- enable global arena timer
function BasicArena.EnableGlobalTimer(bEnable,timer_period)
	if(not BasicArena.global_timer) then
		BasicArena.global_timer = commonlib.Timer:new({callbackFunc = function(timer)
			if(is_global_timer_enabled) then
				BasicArena.On_Timer();
			end
		end})
	end
	is_global_timer_enabled = bEnable;
	if(bEnable) then
		LOG.std(nil,"debug", "BasicArena", "EnableGlobalTimer: true");
		BasicArena.global_timer:Change(timer_period or 500, timer_period or 500);
	else
		LOG.std(nil,"debug", "BasicArena", "EnableGlobalTimer: false");
		-- BasicArena.global_timer:Change();
	end
end

-- called on each framemove
function BasicArena.On_AutoHeal(curTime, current_worlddir)
	if(MsgHandler.IsInCombat() or (curTime - last_heal_by_time_time) < 2000) then
		return;
	end
	local world_info = WorldManager:GetCurrentWorld();
	
	if(System.options.version == "kids") then
		-- kids version
		if((curTime - last_heal_by_time_time) > 2000) then
			if(current_worlddir == "worlds/MyWorlds/61HaqiTown/") then
				-- check position
				local Global_RegionRadar = commonlib.getfield("Map3DSystem.App.worlds.Global_RegionRadar");
				if(Global_RegionRadar) then
					local args = Global_RegionRadar.WhereIam();
					if(args) then
						local regionkey = args.key;
						if(regionkey == "Region_TownSquare") then
							-- set last heal by time time
							last_heal_by_time_time = curTime;
							-- heal by little potion
							if(MsgHandler) then
								local MaxHP = MsgHandler.GetMaxHP()
								if(not MsgHandler.IsFullHealth()) then
									MsgHandler.HealByWisp(safe_area_heal_tick);
								end
							end
						end
					end
				end
			elseif(current_worlddir == "worlds/MyWorlds/FlamingPhoenixIsland/") then
				local x, y, z = ParaScene.GetPlayer():GetPosition();
				local dist_sq = (x - 19774) * (x - 19774) + (z - 19634) * (z - 19634);
				if(dist_sq < 2000) then
					-- set last heal by time time
					last_heal_by_time_time = curTime;
					-- heal by little potion
					if(MsgHandler) then
						local MaxHP = MsgHandler.GetMaxHP()
						if(not MsgHandler.IsFullHealth()) then
							MsgHandler.HealByWisp(safe_area_heal_tick);
						end
					end
				end
			elseif(current_worlddir == "worlds/MyWorlds/FrostRoarIsland/") then
				local x, y, z = ParaScene.GetPlayer():GetPosition();
				local dist_sq = (x - 19621) * (x - 19621) + (z - 19486) * (z - 19486);
				if(dist_sq < 2000) then
					-- set last heal by time time
					last_heal_by_time_time = curTime;
					-- heal by little potion
					if(MsgHandler) then
						local MaxHP = MsgHandler.GetMaxHP()
						if(not MsgHandler.IsFullHealth()) then
							MsgHandler.HealByWisp(safe_area_heal_tick);
						end
					end
				end
			elseif(current_worlddir == "worlds/MyWorlds/AncientEgyptIsland/") then
				local x, y, z = ParaScene.GetPlayer():GetPosition();
				local dist_sq = (x - 19772) * (x - 19772) + (z - 19608) * (z - 19608);
				if(dist_sq < 2000) then
					-- set last heal by time time
					last_heal_by_time_time = curTime;
					-- heal by little potion
					if(MsgHandler) then
						local MaxHP = MsgHandler.GetMaxHP()
						if(not MsgHandler.IsFullHealth()) then
							MsgHandler.HealByWisp(safe_area_heal_tick);
						end
					end
				end
			elseif(current_worlddir == "worlds/MyWorlds/61HaqiTown_teen/") then
				local x, y, z = ParaScene.GetPlayer():GetPosition();
				local dist_sq = (x - 19782) * (x - 19782) + (z - 18984) * (z - 18984);
				if(dist_sq < 2000) then
					-- set last heal by time time
					last_heal_by_time_time = curTime;
					-- heal by little potion
					if(MsgHandler) then
						local MaxHP = MsgHandler.GetMaxHP()
						if(not MsgHandler.IsFullHealth()) then
							MsgHandler.HealByWisp(safe_area_heal_tick);
						end
					end
				end
			end

			-- heal the character at a very slow rate if not at healing spot.
			
			if(world_info.allow_immediate_hp_recovery and last_heal_by_time_time ~= curTime) then
				-- set last heal by time time
				last_heal_by_time_time = curTime;
				if(MsgHandler) then
					local MaxHP = MsgHandler.GetMaxHP();
					MsgHandler.HealByWisp(MaxHP);
				end
			elseif(world_info.allow_hp_recovery and last_heal_by_time_time ~= curTime) then
				-- set last heal by time time
				last_heal_by_time_time = curTime;
				-- heal by little potion
				if(MsgHandler) then
					local MaxHP = MsgHandler.GetMaxHP()
					if(not MsgHandler.IsFullHealth()) then
						local heal_count = MaxHP/100;
						if(Player.IsStanding()) then
							heal_count = heal_count * 2;
						end
						-- TODO: more VIP recover speed here. 
						MsgHandler.HealByWisp(math.floor(heal_count));
					end
				end
			end
		end
	else
		-- teen version
		if(world_info.allow_immediate_hp_recovery and last_heal_by_time_time ~= curTime) then
			-- set last heal by time time
			last_heal_by_time_time = curTime;
			if(MsgHandler) then
				local MaxHP = MsgHandler.GetMaxHP();
				MsgHandler.HealByWisp(MaxHP);
			end
		elseif(world_info.allow_hp_recovery and (curTime - last_heal_by_time_time) > 2000) then
			-- set last heal by time time
			last_heal_by_time_time = curTime;
			-- heal by little potion
			if(MsgHandler) then
				local MaxHP = MsgHandler.GetMaxHP()
				if(not MsgHandler.IsFullHealth()) then
					local heal_count = MaxHP / BasicArena.HP_recover_heal_count;
					if(Player.IsStanding()) then
						heal_count = heal_count * 2;
					end
					-- TODO: more VIP recover speed here. 
					MsgHandler.HealByWisp(math.floor(heal_count));
				end
			end
		end
	end
end

function BasicArena.Set_immortal_countdown(time)
	immortal_countdown = time;
end

function BasicArena.IsImmortal()
	if(immortal_countdown and immortal_countdown > 0) then
		return true;
	end
	return false;
end

-- this is a singleton global timer. BasicArena.On_Timer
function BasicArena.On_Timer()
	MsgHandler.On_BasicArenaTimer();

	local current_worlddir = ParaWorld.GetWorldDirectory();

	-- heal over time
	local curTime = ParaGlobal.GetGameTime();
	local MsgHandler = MsgHandler;
	local Pet = Pet;
	
	BasicArena.On_AutoHeal(curTime, current_worlddir);

	-- send heart beat message every 5 seconds
	if((curTime - last_heart_beat_time) > send_heart_beat_interval) then
		last_heart_beat_time = curTime;
		MsgHandler.OnHeartBeat();
	end
	
	if(slowdown_timer_ticks_update_usernames) then
		slowdown_timer_ticks_update_usernames = slowdown_timer_ticks_update_usernames - 1;
		if(slowdown_timer_ticks_update_usernames <= 0) then
			BasicArena.UpdatePlayerDisplaynames();
			slowdown_timer_ticks_update_usernames = 13;
		end
	end
	
	if(immortal_countdown) then
		
		immortal_countdown = immortal_countdown - 1;

		local my_name = Pet.GetUserCharacterName();
		
		local force_name = "Aries_Combat_Flee_Immortal_Myself";
		
		if(not EffectManager.IsEffectValid(force_name)) then
			-- immortal effect
			local params = {
				asset_file = "character/v5/temp/Effect/Recklessness_Impact_Chest.x",
				binding_obj_name = my_name,
				start_position = nil,
				offset_y = 1.5,
				duration_time = 999999999,
				scale = 2,
				force_name = force_name,
				begin_callback = function() 
				end,
				end_callback = function() 
				end,
			};
			EffectManager.CreateEffect(params);
		end

		local isImmotal = BasicArena.IsInImmortalPosition();
		if(isImmotal) then
			if(WorldManager:GetCurrentWorld().immortal_after_combat or WorldManager:IsInPublicWorld()) then
				immortal_countdown = immortal_time;
			else
				immortal_countdown = 0; -- super short immortal time.
			end
			if(BasicArena.IsArenaAutoReentrant()) then
				-- when in auto combat mode, we shall allow user to automatically join a battle when level above 30. 
				BasicArena.immortal_position = nil;
			else
				-- show other tips during immortal period. 
				immortal_tips_countdown = (immortal_tips_countdown or immortal_time) - 1;
				if(immortal_tips_countdown<=0) then
					immortal_tips_countdown = immortal_time;
					BasicArena.ShowHealthRecoverHint();
					-- BroadcastHelper.PushLabel({id="immortal", label = "请离开当前位置， 才能进入下一次战斗", max_duration=8000, color = "0 255 0", scaling=1.1, bold=true, shadow=true});
				end
			end

		elseif(immortal_countdown <= 0) then
			immortal_countdown = nil;
			immortal_tips_countdown = nil;
			-- remove the effect immediately
			EffectManager.DestroyEffect(force_name);
			-- BroadcastHelper.PushLabel({id="immortal", });
		end
		return;
	end
	
	if(slowdown_timer_ticks) then
		slowdown_timer_ticks = slowdown_timer_ticks - 1;
		if(slowdown_timer_ticks <= 0) then
			slowdown_timer_ticks = nil;
		end
		return;
	end
	---- get player position
	--local myself_objname = tostring(System.App.profiles.ProfileManager.GetNID())
	--local player = ParaScene.GetObject(myself_objname)
	--if(not player:IsValid()) then
		--return;
	--end

	local bMyselfInBattle = false;

	local whereIsDragon = "home";

	local item = ItemManager.GetMyMountPetItem();
	if(item and item.guid > 0) then
		whereIsDragon = item:WhereAmI();
	end
	
	local myself_objname = tostring(System.App.profiles.ProfileManager.GetNID());
	
	local player;
	if(myself_objname == "localuser") then
		player = GameLogic.EntityManager.GetPlayer():GetInnerObject();
	else
		player = ParaScene.GetObject(myself_objname);
	end
	
	local p_x, p_y, p_z = player:GetPosition();

	local min_dist_sq = 999999;
	local arena_id = nil;
	local side = nil;
	local mode = nil;
	
	local NPC = NPC;
	
	-- apply different combat enter range according to different world directory
	local combat_range, combat_range_sq, alert_combat_range_sq =  BasicArena.GetEnterCombatRadius();
	
	-- npl_profiler.perf_begin("BasicArena.On_Timer")
	local arena_key_valuedata_pairs = MsgHandler.Get_arena_key_valuedata_pairs();
	local key, valuedata;
	for key, valuedata in pairs(arena_key_valuedata_pairs) do
	
		if(valuedata.bIncludedMyselfInArena == true) then
			myself_arena_key = key;
		elseif(valuedata.bIncludedMyselfInArena == false and myself_arena_key == key) then
			-- user leave the arena by any reason
			myself_arena_key = nil;
			-- become immortal for the next period of time
			BasicArena.BecomeImmortal();
			return;
		end

		if(valuedata.bIncludedMyselfInArena == true) then
			bMyselfInBattle = true;
			arena_id = nil;
		end

		-- calculate the min square distance
		local dx = valuedata.p_x - p_x;
		local dy = valuedata.p_y - p_y;
		local dz = valuedata.p_z - p_z;
		local dist_sq = dx * dx + dy* dy + dz * dz;
		local bInCombatRadius;
		local bAlertDanger;
		
		if(dist_sq < combat_range_sq and dist_sq < min_dist_sq) then
			bInCombatRadius = true;
			min_dist_sq = dist_sq;
			arena_id = valuedata.arena_id;
			if(valuedata.p_z <= p_z) then
				side = "near";
			else
				side = "far";
			end
			mode = valuedata.mode;
		elseif(dist_sq < alert_combat_range_sq) then
			bAlertDanger = true;
		end

		if( bMyselfInBattle == true or 
			valuedata.bIncludedMyselfInArena == true) then
			-- continue;
		elseif( valuedata.bPlayersFull == true ) then  
			-- player full
			if(bInCombatRadius) then
				BroadcastHelper.PushLabel({id="entercombat", label = "人数已满, 请看看周围的法阵或等待战斗结束", max_duration=5000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,
					background = "Texture/Aries/Common/gradient_white_32bits.png",background_color = "#1f3243",
				});
			end
		elseif(not valuedata.bIncludedAnyAliveMob and valuedata.mode == "pve") then
			-- no mobs visible
			if(bInCombatRadius) then
				--if(System.options.version == "teen") then
					if(not WorldManager:IsInInstanceWorld()) then
						BroadcastHelper.PushLabel({id="entercombat", label = "这里的怪物还没有刷新, 请等待", max_duration=3000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,
							background = "Texture/Aries/Common/gradient_white_32bits.png",background_color = "#1f3243",
						});
						-- immortal for a period of time for other non-auto player enter combat first
						if(Player.IsAutoCombatMode() and BasicArena.IsInImmortalPosition()) then
							immortal_countdown = immortal_time_auto_entercombat_delay;
						end
					end
				--end
			end
		else
			if(bInCombatRadius) then
				BroadcastHelper.PushLabel({id="entercombat", label = "准备战斗, 请等待...", max_duration=1500, color = "255 0 0", scaling=1.1, bold=true, shadow=true,
					background = "Texture/Aries/Common/gradient_white_32bits.png",background_color = "#1f3243",
				});
			
				if(current_worlddir == "worlds/Instances/HaqiTown_RedMushroomArena/" or
					current_worlddir == "worlds/Instances/HaqiTown_LafeierCastle_PVP/" or 
					string.find(current_worlddir, "worlds/Instances/HaqiTown_TrialOfChampions")) then
					-- set team position according to the team id
	
					local matchinfo = LobbyClient:GetMatchInfo();
				
					if(not matchinfo) then
						matchinfo = {teams = {{},{}}}
					end
				
					---- no default side for red mushroom arena
					--side = "near";

					local game1 = game_info:new(matchinfo.teams[1]);
					local game2 = game_info:new(matchinfo.teams[2]);
					if(game1:has_player(tostring(System.App.profiles.ProfileManager.GetNID()))) then
						side = "near";
					end
					if(game2:has_player(tostring(System.App.profiles.ProfileManager.GetNID()))) then
						side = "far";
					end
				end
			elseif(bAlertDanger) then
				local text; 
				if(valuedata.mode ~= "pve") then
					text = "走入PvP法阵将触发战斗";
				elseif(valuedata.bIncludedAnyPlayer) then
					text = "走入法阵将触发战斗";
				else
					text = "靠近怪物将触发战斗";
				end
				BroadcastHelper.PushLabel({id="entercombat", label = text, max_duration=1500, color = "255 0 0", scaling=1.1, bold=true, shadow=true,
					background = "Texture/Aries/Common/gradient_white_32bits.png",background_color = "#1f3243",
				});
			end
		end
	end
	-- npl_profiler.perf_end("BasicArena.On_Timer")

	-- NOTE: timer period is 500 milliseconds
	-- enter the closest combat arena
	if(arena_id and not MsgHandler.IsInCombat()) then

		if(System.options.version == "kids" and whereIsDragon == "home" and not BasicArena.allowWithoutPetCombat) then
			BroadcastHelper.PushLabel({id="entercombat_withoutdragon_tip", label = "驾驭抱抱龙或者让抱抱龙跟随你才能加入战斗", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,
				background = "Texture/Aries/Common/gradient_white_32bits.png",
				background_color = "#1f3243",
			});
			-- slow down the timer player is not ready for enter combat
			slowdown_timer_ticks = 4;
		elseif(not AutoFollowAI:CanEnterCombat()) then
			BroadcastHelper.PushLabel({id="entercombat_disabled_tip", label = "跟随状态不能参加战斗", max_duration=10000, color = "255 0 0", scaling=1, bold=true, shadow=true,});
			-- slow down the timer player is not ready for enter combat
			slowdown_timer_ticks = 4;

		elseif(not BasicArena.CanEnterCombat()) then
			BroadcastHelper.PushLabel({id="entercombat_disabled_tip", label = "当前状态不能参与战斗", max_duration=10000, color = "255 0 0", scaling=1, bold=true, shadow=true,});
			-- slow down the timer player is not ready for enter combat
			slowdown_timer_ticks = 4;
		else
			local current_hp = MsgHandler.GetCurrentHP();
			local max_hp = MsgHandler.GetMaxHP();
			local combat_level = MyCompany.Aries.Combat.GetMyCombatLevel();
			if(mode == "free_pvp" and combat_level <= 5) then
				slowdown_timer_ticks = 20;
				BroadcastHelper.PushLabel({id="free_pvp_level_tip", label = "5级以上才能PK", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
				return;
			end
			if(mode == "free_pvp" and (current_hp / max_hp) < 0.8) then
				if(current_worlddir ~= "worlds/Instances/HaqiTown_RedMushroomArena/" and
					current_worlddir ~= "worlds/Instances/HaqiTown_LafeierCastle_PVP/" and
					not string.find(current_worlddir, "worlds/Instances/HaqiTown_TrialOfChampions")) then
					slowdown_timer_ticks = 10;
					BroadcastHelper.PushLabel({id="free_pvp_hp_tip", label = "体力值超过80%才能进入PK法阵！", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,
						background = "Texture/Aries/Common/gradient_white_32bits.png",
						background_color = "#1f3243",
					});
					return;
				end
			end
			local function OnEnterCombat(arena_id, side)
				--check room state
					LobbyClientServicePage.LoadRoomState(function(msg)
						if(msg and (msg.status == "match_making" or msg.status == "waiting" ))then

							local world_info = WorldManager:GetCurrentWorld();
							if(world_info.force_teamworld) then
								-- do nothing 
							else
								BroadcastHelper.PushLabel({id="match_making", label = "你正在排队，不适合参加战斗", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,
										background = "Texture/Aries/Common/gradient_white_32bits.png",
										background_color = "#1f3243",
									});
							end
							MyCompany.Aries.Combat.MsgHandler.OnEnterCombat(arena_id, side);
							-- not before enter combat and the message handler
							slowdown_timer_ticks = 10;
						else
							MyCompany.Aries.Combat.MsgHandler.OnEnterCombat(arena_id, side);
							-- not before enter combat and the message handler
							slowdown_timer_ticks = 10;
						end
					end, false);
			end
			if(string.find(current_worlddir, [[worlds/Instances]])) then
				OnEnterCombat(arena_id, side);
			else
				NPL.load("(gl)script/apps/Aries/Desktop/AntiIndulgenceArea.lua");
				local AntiIndulgenceArea = commonlib.gettable("MyCompany.Aries.Desktop.AntiIndulgenceArea");
				if(mode == "free_pvp" or (AntiIndulgenceArea.IsAntiSystemIsEnabled and not AntiIndulgenceArea.IsAntiSystemIsEnabled())) then
					OnEnterCombat(arena_id, side);
				else
					BroadcastHelper.PushLabel({id="antiindulgence_tip", label = "你今天的战斗时间已经用完！", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
					-- don't try enter combat for the next 100 seconds
					slowdown_timer_ticks = 20;
				end
			end
			
			NPL.load("(gl)script/apps/Aries/Desktop/AntiIndulgenceArea.lua");
			local AntiIndulgenceArea = commonlib.gettable("MyCompany.Aries.Desktop.AntiIndulgenceArea");
			if(AntiIndulgenceArea.IsAntiSystemIsEnabled and AntiIndulgenceArea.IsAntiSystemIsEnabled()) then
				BroadcastHelper.PushLabel({id="antiindulgence_tip", label = "你今天的战斗时间已经用完！不再获得战斗经验、宠物经验、奇豆、战利品！", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
			end
		end
	end
end

-- on enter sentient area
-- note: shall we delay some logics until sentient and add code here?
-- such as only create arena helper objects until it is first sentient. 
function BasicArena.On_EnterSentientArea(arena_id)
	
	local arena_meta = MsgHandler.Get_arena_meta_data_by_id(arena_id);
	if(arena_meta.is_sentient ~= true) then
		arena_meta.is_sentient = true;
		BasicArena.On_FrameMove(arena_id);
	end
	arena_meta.is_sentient = true;
	
	local arena_data = MsgHandler.Get_arena_data_by_id(arena_id);
	-- refresh arena data
	if(arena_data.treasurebox) then
		ObjectManager.ShowTreasureBox(arena_data.arena_id, arena_data.treasurebox);
	else
		ObjectManager.DestroyTreasureBox(arena_data.arena_id);
	end
	-- remove all arena buffs
	ObjectManager.RefreshArenaBuffs(arena_id, arena_data.slotbuffs, true, arena_meta);
	-- refresh all arena fled slots
	ObjectManager.RefreshFledSlots(arena_id, arena_data.fledslots, arena_meta);
end

-- on leave sentient area
function BasicArena.On_LeaveSentientArea(arena_id)
	
	local arena_meta = MsgHandler.Get_arena_meta_data_by_id(arena_id);
	arena_meta.is_sentient = false;

	-- turn model visibility to off, since it uses mini-scenegraph. 
	ObjectManager.UpdateArenaPlatformModel(arena_id, arena_meta, true);
	ObjectManager.DestroySequenceArrow(arena_id);
	ObjectManager.DestroyGlobalAura(arena_id);
	ObjectManager.RemoveAllArenaPips(arena_id);
	-- remove all arena buffs
	ObjectManager.RefreshArenaBuffs(arena_id, nil, nil, arena_meta);
	-- remove fled flags
	ObjectManager.RefreshFledSlots(arena_id, nil, arena_meta);
end

-- called every 0.4 seconds
-- TODO: move detect player (OnEnterCombat) logics here from OnTimer logics. 
function BasicArena.On_FrameMove(arena_id)
	
	local arena_meta = MsgHandler.Get_arena_meta_data_by_id(arena_id);
	
	-- turn on and off visibility of the arena model platform according to whether there are players on it. 
	ObjectManager.UpdateArenaPlatformModel(arena_id, arena_meta);

	local arena_char, arena_model = NPC.GetNpcCharModelFromIDAndInstance(ObjectManager.GetArena_NPC_ID(arena_id));
	if(arena_char and arena_char:IsValid()) then
		if(arena_meta) then
			if(not arena_meta.bIncludedAnyAliveMob) then
				local att = arena_char:GetAttributeObject();
				att:SetField("SkipRender", true);
				return;
			end
			if(not arena_meta.bIncludedAnyPlayer) then
				local dist_sq = arena_char:DistanceToPlayerSq();
				if(dist_sq < 1500) then
					local att = arena_char:GetAttributeObject();
					att:SetField("SkipRender", false);
					return;
				end
			end
		end
		local att = arena_char:GetAttributeObject();
		att:SetField("SkipRender", true);
	end
end

-- BasicArena.OnVictory
function BasicArena.OnVictory()
	myself_arena_key = nil;
	BasicArena.BecomeImmortal();
end

-- BasicArena.OnFleeSuccess
function BasicArena.OnFleeSuccess()
	local my_arena_data;
	local safe_position;
	local GetMyArenaData = commonlib.getfield("MyCompany.Aries.Combat.MsgHandler.GetMyArenaData");
	
	local combat_range, combat_range_sq, alert_combat_range_sq =  BasicArena.GetEnterCombatRadius();

	if(GetMyArenaData) then
		my_arena_data = GetMyArenaData();
		if(my_arena_data) then
			--if(System.options.version == "teen" or not WorldManager:IsInInstanceWorld()) then
				local world_info = WorldManager:GetCurrentWorld();
				if(world_info.flee_pos == "bornpos") then
					-- flee to born position
				else
					-- flee to current arena position. 
					local name, pos, camera_pos = MsgHandler.GetArenaTeleportPos(my_arena_data);
					if(pos) then
						safe_position = {position = pos, camera = camera_pos};
					end
				end
			--end
		end
	end

	myself_arena_key = nil;
	-- @Note: flee no longer becomes immortal.
	BasicArena.BecomeImmortal();

	BasicArena.TeleportToSafeZone(true, function() 
		-- half hp 
		local SetCurrentHP = MsgHandler.SetCurrentHP;
		local current_hp = MsgHandler.GetCurrentHP();
		local max_hp = MsgHandler.GetMaxHP();
		--local hp = current_hp;
		--if(current_hp * 2 > max_hp) then
			--hp = math.ceil(max_hp / 2);
		--end
		--if(SetCurrentHP) then
			--SetCurrentHP(hp);
		--end
		
		NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
		local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
		local world_info = WorldManager:GetCurrentWorld();
		if(world_info.team_mode == "battlefield") then
			SetCurrentHP(0);
			MsgHandler.HealByWisp(1, true); -- true for bForceProportion
		else
			-- other battlefield instance and public world
			SetCurrentHP(0);
			MsgHandler.HealByWisp(1000);
		end
	end, safe_position);
end

-- BasicArena.OnDefeated
function BasicArena.OnDefeated()
	local SetCurrentHP = MsgHandler.SetCurrentHP;
	if(SetCurrentHP) then
		SetCurrentHP(0);
	end
	local my_arena_data;
	local safe_position;
	local combat_range, combat_range_sq, alert_combat_range_sq =  BasicArena.GetEnterCombatRadius();

	local GetMyArenaData = commonlib.getfield("MyCompany.Aries.Combat.MsgHandler.GetMyArenaData");
	if(GetMyArenaData) then
		my_arena_data = GetMyArenaData();
		if(my_arena_data) then
			if(System.options.version == "teen") then
				local current_worlddir = ParaWorld.GetWorldDirectory();
				--if(string.find(current_worlddir, [[worlds/Instances]])) then
					safe_position = {position = {my_arena_data.p_x - combat_range - 5, my_arena_data.p_y, my_arena_data.p_z}, camera = {20.00,0.28,0},};
				--end
			end
		end
	end
	myself_arena_key = nil;
	BasicArena.BecomeImmortal();
	BasicArena.TeleportToSafeZone(true, function() 
		-- half hp 
		local current_hp = MsgHandler.GetCurrentHP();
		local max_hp = MsgHandler.GetMaxHP();
		--MsgHandler.HealByWisp(max_hp);
		MsgHandler.HealByWisp(1000);
	end, safe_position);
end

-- BasicArena.OnDefeatedInInstance
function BasicArena.OnDefeatedInInstance()
	local SetCurrentHP = MsgHandler.SetCurrentHP;
	if(SetCurrentHP) then
		SetCurrentHP(0);
		MsgHandler.HealByWisp(1000);
	end
	myself_arena_key = nil;
end

-- show hint only if health is low
-- this function is called whenever the user leaves the combat. 
function BasicArena.ShowHealthRecoverHint()
	local health_percent = Player.GetCurrentHP() / Player.GetMaxHP();
	local player_level = Player.GetLevel();
	if(health_percent < 0.7) then
		if(player_level < 20) then
			if(System.options.version == "kids") then
				--BroadcastHelper.PushLabel({id="HealthRecoverHint", label = "你受伤了! 路面上的红色血球或红枣可以补血; 小镇广场也可以恢复HP", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,
					--background = "Texture/Aries/Common/gradient_white_32bits.png",
					--background_color = "#1f3243",
				--});
			else
				--BroadcastHelper.PushLabel({id="HealthRecoverHint", label = "你受伤了! 快使用治疗药剂回血", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,
					--background = "Texture/Aries/Common/gradient_white_32bits.png",
					--background_color = "#1f3243",
				--});
			end
		else
			if(System.options.version == "kids") then
				--BroadcastHelper.PushLabel({id="HealthRecoverHint", label = "你受伤了! 打开背包吃红枣可以迅速补血", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,
					--background = "Texture/Aries/Common/gradient_white_32bits.png",
					--background_color = "#1f3243",
				--});
			else
				--BroadcastHelper.PushLabel({id="HealthRecoverHint", label = "你受伤了! 快使用治疗药剂回血", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,
					--background = "Texture/Aries/Common/gradient_white_32bits.png",
					--background_color = "#1f3243",
				--});
			end
		end
	end
end

function BasicArena.IsInTutorial()
	
	NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
	local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
	local world_info = WorldManager:GetCurrentWorld();
	local worldpath = world_info.worldpath;
	if (not worldpath)then
		return false
	end
	if(not string.find(string.lower(worldpath), "tutorial")) then
		return false;
	end

	if(CombatTutorial and CombatTutorial.IsInTutorial and CombatTutorial.IsInTutorial()) then
		return true;
	elseif(CombatPipTutorial and CombatPipTutorial.IsInTutorial and CombatPipTutorial.IsInTutorial()) then
		return true;
	end
end

function BasicArena.IsArenaAutoReentrant()
	return MsgHandler.GetIsAutoAIMode() and Player.GetLevel()>30;
end

-- diable entering combat
function BasicArena.BecomeImmortal()
	if(immortal_countdown and immortal_countdown > 0) then
		return;
	end
	if(BasicArena.IsInTutorial()) then
		return;
	end

	if(not BasicArena.IsArenaAutoReentrant()) then
		-- reset remaining time
		if(WorldManager:GetCurrentWorld().immortal_after_combat or WorldManager:IsInPublicWorld()) then
			immortal_countdown = immortal_time;
		else
			immortal_countdown = 0; -- super short immortal time.
		end
		-- show tips.
		BasicArena.ShowHealthRecoverHint();

		-- new logic added by LiXizhi 2011.8.24: if player does not move, it will be immortal forever, the count down only works after the player moves and auto combat is not enabled. 
		BasicArena.immortal_position = {Player.GetPlayer():GetPosition()};
		-- LOG.std("", "debug", "BasicArena", "becomes immortal");

		--if(System.options.version == "teen") then
			--local combat_level = MyCompany.Aries.Combat.GetMyCombatLevel();
			--if(combat_level <= 5) then
				--BroadcastHelper.PushLabel({id="immortal", label = "你刚刚结束战斗，暂时无法加入新的战斗", max_duration=8000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,
					--background = "Texture/Aries/Common/gradient_white_32bits.png",
					--background_color = "#1f3243",
				--});
			--end
		--end
		
	else
		if(System.options.version == "teen") then
			BasicArena.immortal_position = {Player.GetPlayer():GetPosition()};
		else
			BasicArena.immortal_position = nil;
		end
	end
end

local safe_spots = {
	["worlds/MyWorlds/61HaqiTown/"] = {
		{position = {20058.06, 3.34, 19713.05}, camera = {8.86, 0.32, 2.16},},
		{position = {20114.80, 5.54, 19736.32}, camera = {8.86, 0.29, -2.09},},
		{position = {20058.72, 5.26, 19719.62}, camera = {8.86, 0.25, 0.40},},
		{position = {20060.71, 8.03, 19796.74}, camera = {8.86, 0.50, -1.11},},
		{position = {20069.57, 0.45, 19741.62}, camera = {8.85, 0.34, -0.95},},
	},
	["worlds/MyWorlds/FlamingPhoenixIsland/"] = {
		{position = {19810.55, 7.66, 19628.82}, camera = {15.00, 0.31, -1.98},},
		{position = {19776.34, 6.99, 19653.57}, camera = {15.00, 0.30, -2.63},},
		{position = {19838.84, 6.19, 19634.46}, camera = {15.00, 0.25, -2.79},},
	},
	["worlds/MyWorlds/FrostRoarIsland/"] = {
		{position = {19630.23,5.74,19468.69}, camera = {6.89,0.37,-2.22},},
		{position = {19624.21,5.85,19476.66}, camera = {6.89,0.37,-1.56},},
		{position = {19626.60,5.89,19484.65}, camera = {6.89,0.37,-1.09},},
		{position = {19610.50,5.90,19494.16}, camera = {6.89,0.40,-0.66},},
		{position = {19614.78,5.87,19507.24}, camera = {6.89,0.39,-1.53},},
	},
	["worlds/MyWorlds/AncientEgyptIsland/"] = {
		{position = {19775.49,5.69,19604.71}, camera = {15.00,0.33,2.08},},
		{position = {19778.29,6.17,19612.71}, camera = {15.00,0.31,-1.99},},
		{position = {19779.89,6.60,19630.29}, camera = {15.00,0.31,-2.50},},
		{position = {19766.43,6.65,19632.68}, camera = {15.00,0.31,3.03},},
		{position = {19759.16,6.60,19620.92}, camera = {15.00,0.31,1.93},},
		{position = {19767.18,6.57,19610.68}, camera = {15.00,0.31,-0.38},},
	},

	-- teen version worlds
	["worlds/MyWorlds/61HaqiTown_teen/"] = {
		{position = {20118.56,29.91,19696.45}, camera = {13.31,0.12,0.97},},
		{position = {20006.01,19.30,19362.41}, camera = {16.20,0.49,-2.87},},
		{position = {19672.58,25.68,19608.46}, camera = {12.15,0.14,-2.42},},
		{position = {20188.56,52.39,19974.02}, camera = {15.00,0.29,-1.68},},
		{position = {19861.83,17.24,19239.11}, camera = {16.20,0.62,-2.51},},
	},
	["worlds/MyWorlds/FlamingPhoenixIsland_teen/"] = {
		{position = {19850.43,8.71,19636.00}, camera = {20.00,0.29,2.97},},
		{position = {19687.07,9.56,19723.70}, camera = {20.00,0.51,1.82},},
		{position = {19622.81,47.49,19834.21}, camera = {20.00,0.36,2.54},},
		{position = {19881.43,31.26,19821.00}, camera = {20.00,0.20,1.65},},
		{position = {19822.86,73.36,19960.25}, camera = {20.00,0.24,-0.48},},
		{position = {20021.18,72.64,19918.23}, camera = {20.00,0.19,0.18},},
		{position = {20066.66,39.81,19526.64}, camera = {20.00,0.44,1.94},},
		{position = {20023.37,22.74,19612.22}, camera = {20.00,0.29,0.91},},
	},
	["worlds/MyWorlds/FrostRoarIsland_teen/"] = {
		{position = {19617.62,8.26,19464.88}, camera = {18.00,0.17,-1.47},},
		{position = {19715.05,9.10,19835.89}, camera = {20.00,0.23,-2.93},},
		{position = {19879.22,12.82,19778.50}, camera = {20.00,0.39,0.73},},
		{position = {20115.71,8.88,19969.91}, camera = {20.00,0.06,-3.08},},
		{position = {20206.51,51.34,20102.56}, camera = {20.00,0.41,1.96},},
		{position = {20087.92,157.71,20185.96}, camera = {20.00,0.45,-0.92},},
		{position = {19837.01,8.44,20408.79}, camera = {20.00,-0.02,-1.85},},
		{position = {19659.46,9.77,20173.89}, camera = {20.00,0.24,1.65},},
		{position = {19588.01,14.33,19982.79}, camera = {20.00,0.12,0.03},},
		{position = {19472.00,40.61,19746.34}, camera = {20.00,0.44,1.36},},
	},
	["worlds/MyWorlds/AncientEgyptIsland_teen/"] = {
		{position = {19768.08,8.89,19608.97}, camera = {20.00,0.28,-2.07},},
		{position = {19576.25,16.13,19879.83}, camera = {20.00,0.26,-2.09},},
		{position = {19277.02,18.63,19839.38}, camera = {20.00,0.27,-2.56},},
		{position = {19617.77,12.91,20125.05}, camera = {20.00,0.04,-2.72},},
		{position = {19892.25,10.24,20121.89}, camera = {15.00,0.16,-1.94},},
		{position = {19829.34,19.78,19846.39}, camera = {20.00,0.29,0.04},},
		{position = {20100.75,12.01,19705.71}, camera = {20.00,0.19,1.90},},
		{position = {20077.62,22.56,20061.10}, camera = {20.00,0.13,-0.62},},
		{position = {20143.05,61.46,20339.36}, camera = {15.00,0.24,-2.28},},
	},
	["worlds/MyWorlds/DarkForestIsland_teen/"] = {
		{position = {20023.54,7.78,20214.09}, camera = {19.41,0.24,2.07},},
		{position = {19564.29,6.84,20125.00}, camera = {19.41,0.27,0.69},},
		{position = {19788.13,12.57,19848.97}, camera = {19.41,0.25,1.88},},
		{position = {19661.64,6.05,19687.28}, camera = {19.41,0.35,2.58},},
		{position = {19584.62,30.79,19582.52}, camera = {19.41,0.39,-2.96},},
		{position = {19407.71,46.79,20061.16}, camera = {19.41,0.43,1.80},},
	},
};

-- teleport to safe zone
function BasicArena.TeleportToSafeZone(bForceCurrentWorld, finish_callback, safe_position)

    local worldpath = ParaWorld.GetWorldDirectory();
    
	local world_safe_spots = safe_spots[worldpath];

	if(not world_safe_spots) then
		if(bForceCurrentWorld) then
			-- NOTE: skip instance return world teleport
			NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
			local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
			local world_info = WorldManager:GetCurrentWorld();

			local born_pos = world_info.born_pos;
			if(world_info.team_mode == "battlefield") then
				NPL.load("(gl)script/apps/Aries/Combat/Battlefield/BattlefieldClient.lua");
				local BattlefieldClient = commonlib.gettable("MyCompany.Aries.Battle.BattlefieldClient");
				born_pos = BattlefieldClient:GetMyBornPos(nil);
			end
			if(born_pos) then
				if(type(born_pos) == "table") then
					local db = ParaWorld.GetAttributeProvider();
					local camera = {
						db:GetAttribute("CameraObjectDistance", 5), 
						db:GetAttribute("CameraLiftupAngle", 0.4), 
						db:GetAttribute("CameraRotY", 0)
					};
					world_safe_spots = {{
						position = {born_pos.x, born_pos.y, born_pos.z},
						camera = camera,
					}};
				end
			end
		else
			-- user is in instance world
			UIAnimManager.PlayCustomAnimation(500, function(elapsedTime)
				if(elapsedTime == 500) then
					NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
					local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");

					local world_info = WorldManager:GetReturnWorld();
					local worldpath = world_info.worldpath;
					local world_safe_spots = safe_spots[worldpath..[[/]]];
					if(world_safe_spots) then
						local i = 1;
						i = math.random(1, #world_safe_spots);
						local position = world_safe_spots[i].position;
						local camera = world_safe_spots[i].camera;
						world_info:SetTeleportBackPosition(position[1], position[2], position[3]);
						world_info:SetTeleportBackCamera(camera[1], camera[2], camera[3]);
					end
					-- teleport back from instance world
					WorldManager:TeleportBack();
				end
			end);
			return;
		end
	end
	if(not world_safe_spots or not next(world_safe_spots)) then
		return
	end

	local i = 1;
	
	if(System.options.version == "teen") then
		-- find nearest safe spot
		local nearest_dist_sq = 99999999;
		local j;
		local x, y, z = Player.GetPlayer():GetPosition();
		for j = 1, #world_safe_spots do
			local spot_x = world_safe_spots[j].position[1];
			local spot_z = world_safe_spots[j].position[3];
			local dist_sq = (x - spot_x) * (x - spot_x) + (z - spot_z) * (z - spot_z);
			if(dist_sq <= nearest_dist_sq) then
				nearest_dist_sq = dist_sq;
				i = j;
			end
		end
	else
		
		i = math.random(1, #world_safe_spots);
	end

	local position = world_safe_spots[i].position;
	local camera = world_safe_spots[i].camera;

	if(safe_position) then
		if(safe_position.position and safe_position.camera) then
			position = safe_position.position;
			camera = safe_position.camera;
		end
	end
	
	-- teleport to town center square
	local msg = { 
		aries_type = "OnMapTeleport", 
		position = position, 
		camera = camera, 
		bIgnoreCombatCheck = true,
		bForceSkipTeleportCheck = true,
		finish_callback = finish_callback,
		wndName = "map", 
	};
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
end

-- BasicArena.UpdatePlayerNames
function BasicArena.UpdatePlayerDisplaynames()
	
	----for all bipeds, get OPC status
	--local player = ParaScene.GetObject("<player>");
	--local playerCur = player;
	--local allPlayers = {};
	--local count = 0;
	--while(playerCur:IsValid() == true) do
		---- get next object
		--playerCur = ParaScene.GetNextObject(playerCur);
		---- currently get all scene objects
		--if(playerCur:IsValid() and playerCur:IsCharacter()) then
			--local att = playerCur:GetAttributeObject();
			--local isOPC = att:GetDynamicField("IsOPC", false);
			--if(isOPC == true) then
				--count = count + 1;
				--local nid = string.gsub(playerCur.name, "@.*$", "");
				--if(nid) then
					--local name = att:GetDynamicField("name", "");
					--allPlayers[count] = {nid = nid, name = name};
					---- refresh the name
					--System.App.profiles.ProfileManager.GetUserInfo(nid, nil, function(msg)
					--end, "access plus 1 year");
				--end
			--end
		--end
		---- if cycled to the player character
		--if(playerCur:equals(player) == true) then
			--break;
		--end
	--end
	--
	---- update myself
	--System.App.profiles.ProfileManager.GetUserInfo(nil, nil, function(msg)
	--end, "access plus 1 year");
	--
	--NPL.load("(gl)script/apps/Aries/Combat/MsgHandler.lua");
	--local arena_key_valuedata_pairs = MyCompany.Aries.Combat.MsgHandler.Get_arena_key_valuedata_pairs();
	--local key, valuedata;
	--for key, valuedata in pairs(arena_key_valuedata_pairs) do
	--
		--local _, eachplayer;
		--for _, eachplayer in ipairs(valuedata.players) do
			---- 
			--local player = ParaScene.GetObject(tostring(eachplayer.nid));
			--if(player and player:IsValid() == true) then
				--local att = player:GetAttributeObject();
				--att:SetDynamicField("DisplayName", "");
				--System.ShowHeadOnDisplay(true, player, "", "99 209 62");
			--end
		--end
	--end
end