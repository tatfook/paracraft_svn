--[[
Title: DanceParty
Author(s): WangTian
Date: 2009/8/1

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/FriendshipPark/30186_DanceParty.lua
------------------------------------------------------------
]]

-- create class
local libName = "DanceParty";
local DanceParty = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.DanceParty", DanceParty);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

local arenas = {
			[1] = {position = {20151.921875, 1.0921800136566, 19945.236328125}, nextclear_time = nil, last_nid = nil, }, -- robot dancer
			[2] = {position = {20159.28515625, 1.4389280080795, 19935.7421875}, nextclear_time = nil, last_nid = nil, },
			[3] = {position = {20152.13671875, 1.4428150653839, 19926.84765625}, nextclear_time = nil, last_nid = nil, },
			[4] = {position = {20141.779296875, 1.2836680412292, 19930.208984375}, nextclear_time = nil, last_nid = nil, },
			[5] = {position = {20141.234375, 0.80361604690552, 19941.29296875}, nextclear_time = nil, last_nid = nil, },
			[6] = {position = {20047.494140625, 1.5415239334106, 19729.39453125}, nextclear_time = nil, last_nid = nil, }, -- twist dancer
			[7] = {position = {20058.34765625, 1.3432559967041, 19719.15234375}, nextclear_time = nil, last_nid = nil, },
			[8] = {position = {20044.482421875, 1.7471499443054, 19709.181640625}, nextclear_time = nil, last_nid = nil, },
			[9] = {position = {20036.92578125, 2.0381300449371, 19720.927734375}, nextclear_time = nil, last_nid = nil, },
			[10] = {position = {20054.685546875, -0.43746501207352, 19647.216796875}, nextclear_time = nil, last_nid = nil, }, -- thomas dancer
			[11] = {position = {20072.599609375, -0.43708908557892, 19647.662109375}, nextclear_time = nil, last_nid = nil, },
			[12] = {position = {20072.0859375, -0.57310199737549, 19630.39453125}, nextclear_time = nil, last_nid = nil, },
			[13] = {position = {20054.8359375, -0.69334900379181, 19630.455078125}, nextclear_time = nil, last_nid = nil, },
			[14] = {position = {20062, -10000, 19740.0}, nextclear_time = nil, last_nid = nil, }, -- not used
			[15] = {position = {20066, -10000, 19740.0}, nextclear_time = nil, last_nid = nil, },
			[16] = {position = {20070, -10000, 19740.0}, nextclear_time = nil, last_nid = nil, },
			[17] = {position = {20044, -10000, 19735.5}, nextclear_time = nil, last_nid = nil, },
			[18] = {position = {20051, -10000, 19735.5}, nextclear_time = nil, last_nid = nil, },
		};

--local dancing_aura = "character/common/dummy/elf_size/elf_size.x";
--local empty_aura = "character/common/dummy/cube_size/cube_size.x";

local isDancing = false;
local dancing_gsid = nil;

-- DanceParty.main
function DanceParty.main()
	
	-- DEBUG purpose aura
	--local i;
	--for i = 1, #arenas do
		--local arena = arenas[i];
		--local params = {
			--asset_file = empty_aura,
			--binding_obj_name = nil,
			--start_position = arena.position,
			--duration_time = 10000000,
			--force_name = "DanceParty_arena_"..i,
			--elapsedtime_callback = function(elapsedTime, obj)
				--if(obj and obj:IsValid() == true) then
					--local assetfile = obj:GetPrimaryAsset():GetKeyName();
					--if(arena.dancing == true and assetfile ~= dancing_aura) then
						--local asset = ParaAsset.LoadParaX("", dancing_aura);
						--local effectChar = obj:ToCharacter();
						--effectChar:ResetBaseModel(asset);
					--elseif(arena.dancing ~= true and assetfile ~= empty_aura) then
						--local asset = ParaAsset.LoadParaX("", empty_aura);
						--local effectChar = obj:ToCharacter();
						--effectChar:ResetBaseModel(asset);
					--end
				--end
			--end,
		--};
		--local EffectManager = MyCompany.Aries.EffectManager;
		--EffectManager.CreateEffect(params);
	--end
	
	
	local params = {
		name = "",
		--position = position,
		assetfile_char = "character/common/dummy/elf_size/elf_size.x",
		assetfile_model = "model/06props/v5/03quest/Arena/Arena_Blue.x",
		facing = math.random(0, 628)/100,
		scaling = 1.7,
		scaling_model = 0.0001,
		main_script = "",
		main_function = "",
		talkdist = 6,
		predialog_function = "MyCompany.Aries.Quest.NPCs.DanceParty.Arena_PreDialog",
		dialog_page = "script/apps/Aries/NPCs/FriendshipPark/30186_DanceParty_dialog.html",
		EnablePhysics = false,
		--cursor = "Texture/Aries/Cursor/Pick.tga",
	};
	local NPC = MyCompany.Aries.Quest.NPC;
	local i;
	for i = 1, 18 do
		local npcid = DanceParty.ToNPC_ID(i);
		local position = commonlib.deepcopy(arenas[i].position)
		position[2] = position[2] - 1;
		params.position = position;
		local arena, arenaModel = NPC.CreateNPCCharacter(npcid, params);
	end
	
	
	-- hook into OnThrowableItemSelected
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnThrowableItemSelected") then
				if(isDancing and msg.gsid and msg.guid) then
					-- cancel dancing
					Map3DSystem.GSL_client:SendRealtimeMessage("s30186", {body="[Aries][ServerObject30186]CancelDance"});
					isDancing = false;
					lastPosition = nil;
				end
			end
		end, 
		hookName = "DanceParty_OnThrowableItemSelected", appName = "Aries", wndName = "main"});
	
	-- hook into OnPlayCharAnim
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnPlayCharAnim") then
				if(isDancing and msg.gsid ~= dancing_gsid) then
					-- cancel dancing
					Map3DSystem.GSL_client:SendRealtimeMessage("s30186", {body="[Aries][ServerObject30186]CancelDance"});
					isDancing = false;
					lastPosition = nil;
				end
			end
		end, 
		hookName = "DanceParty_CharAnimListener", appName = "Aries", wndName = "main"});
end

local lastPosition = nil;
-- DanceParty.On_Timer
function DanceParty.On_Timer()
	if(isDancing == true) then
		local userChar = MyCompany.Aries.Pet.GetUserCharacterObj();
		if(userChar and userChar:IsValid() == true) then
			local x, y, z = userChar:GetPosition();
			if(lastPosition and x and y and z) then
				-- check for last user position, if any offset, cancel the dance process
				local delta = math.abs(lastPosition[1] - x) + math.abs(lastPosition[2] - y) + math.abs(lastPosition[3] - z);
				if(delta > 0.1) then
					-- cancel dancing
					Map3DSystem.GSL_client:SendRealtimeMessage("s30186", {body="[Aries][ServerObject30186]CancelDance"});
					isDancing = false;
					lastPosition = nil;
				else
					lastPosition = {x, y, z};
				end
			else
				lastPosition = {x, y, z};
			end
		end
	end
end

-- 9005_DidaDance
-- 9006_RobotDance
-- 9007_WindmillDance
-- 9008_TwistDance
-- 9009_RollingDance
-- 9010_ThomasDance

-- pre_dialog of the dance arena
function DanceParty.Arena_PreDialog(npc_id)
	-- 301861 memory reserved for all dance arenas
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(301861);
	local arena_id = DanceParty.ToArena_ID(npc_id);
	if(arena_id) then
		-- each arena memory
		memory[arena_id] = memory[arena_id] or {};
		memory = memory[arena_id];
		local arena = arenas[arena_id];
		if(arena.dancing == true) then
			if(isDancing == true) then
				memory.dialog_state = 6;
			else
				memory.dialog_state = 1;
			end
		else
			if(arena_id >= 1 and arena_id <= 5) then
				-- 9006_RobotDance
				if(hasGSItem(9006)) then
					memory.dialog_state = 2;
				else
					memory.dialog_state = 3;
				end
			elseif(arena_id >= 6 and arena_id <= 9) then
				-- 9008_TwistDance
				if(hasGSItem(9008)) then
					memory.dialog_state = 2;
				else
					memory.dialog_state = 3;
				end
			elseif(arena_id >= 10 and arena_id <= 13) then
				-- 9010_ThomasDance
				if(hasGSItem(9010)) then
					memory.dialog_state = 2;
				else
					memory.dialog_state = 3;
				end
			end
		end
	end
end

function DanceParty.ToNPC_ID(index)
	return (301860 + index);
end

function DanceParty.ToArena_ID(index)
	return (index - 301860);
end

function DanceParty.TryDance(npc_id)
	local arena_id = DanceParty.ToArena_ID(npc_id);
	if(arena_id) then
		Map3DSystem.GSL_client:SendRealtimeMessage("s30186", {body="[Aries][ServerObject30186]TryDance:"..arena_id});
	end
end

-- say level5 quest speech
-- @return: true if the doctor hasn't speak out the the final word
--			false if continue with the next dialog answer condition
function DanceParty.PreDialog()
	return true;
end

-- refresh dancing aura, mount a dancing aura on the arena
function DanceParty.RefreshDancingAura(arena_id)
	local arena = arenas[arena_id];
	arena.dancing = true;
end

-- refresh empty aura, mount an empty aura on the arena indicating the arena is available
function DanceParty.RefreshEmptyAura(arena_id)
	local arena = arenas[arena_id];
	arena.dancing = nil;
end

-- start dance on the arena
function DanceParty.StartDance(arena_id)
	--if(not arena_id or arena_id < 0 or arena_id > 18) then
	if(not arena_id or arena_id < 1 or arena_id > 13) then
		log("error: invalid arena_id got in DanceParty.StartDance\n");
		return;
	end
	
	-- teleport to the arena center
	local arena = arenas[arena_id];
	local x, y, z = arena.position[1], arena.position[2], arena.position[3];
	ParaScene.GetPlayer():SetPosition(x, y, z);
	local gsid = "";
	-- play the animation
	if(arena_id >= 1 and arena_id <= 5) then
		-- robot dance
		gsid = 9006;
	elseif(arena_id >= 6 and arena_id <= 9) then
		-- twist dance
		gsid = 9008;
	elseif(arena_id >= 10 and arena_id <= 13) then
		-- thomas dance
		gsid = 9010;
	end
	
	-- set myself dancing
	isDancing = true;
	dancing_gsid = gsid;
	
	local bHas, guid = hasGSItem(gsid);
	if(bHas) then
		local item = ItemManager.GetItemByGUID(guid);
		if(item and item.guid > 0) then
			item:OnClick("left");
		end
	end
	
	local params = {
		asset_file = "character/v5/temp/effect/loyaltydown_impact_base.x",
		binding_obj_name = ParaScene.GetPlayer().name,
		start_position = nil,
        duration_time = 800,
        force_name = nil,
        begin_callback = function() end,
        end_callback = nil,
	};
	local EffectManager = MyCompany.Aries.EffectManager;
	EffectManager.CreateEffect(params);
	
	--_guihelper.MessageBox("start dance "..tostring(arena_id))
end

-- cancel dance on the arena
function DanceParty.CancelDance(arena_id)
	isDancing = false;
	DanceParty.OffArena(arena_id)
	_guihelper.MessageBox([[<div style="margin-left:10px;margin-top:20px;">本次跳舞被打断啦，跳舞的过程可不能乱走动的！</div>]]);
	--_guihelper.MessageBox("CancelDance"..tostring(arena_id))
end

-- DanceParty.WalkoffAndRecvReward
function DanceParty.WalkoffAndRecvReward(arena_id)
	isDancing = false;
	-- arena dance type
	local arena_type = "robot";
	if(arena_id >= 1 and arena_id <= 5) then
		-- robot dance
		arena_type = "robot";
	elseif(arena_id >= 6 and arena_id <= 9) then
		-- twist dance
		arena_type = "twist";
	elseif(arena_id >= 10 and arena_id <= 13) then
		-- thomas dance
		arena_type = "thomas";
	end
	
	local function RecvJoybean()
		local joybean_count = 100;
		local dance_skill_point = 2;
		local rewardname = "100奇豆和2点舞蹈熟练度";
		local charname = "机械舞达人";
		-- play the animation
		if(arena_type == "robot") then
			-- robot dance
			joybean_count = 50;
			dance_skill_point = 2;
			rewardname = "50奇豆和2点舞蹈熟练度";
			charname = "机械舞达人";
		elseif(arena_type == "twist") then
			-- twist dance
			joybean_count = 60;
			dance_skill_point = 4;
			rewardname = "60奇豆和4点舞蹈熟练度";
			charname = "旋转舞达人";
		elseif(arena_type == "thomas") then
			-- thomas dance
			joybean_count = 80;
			dance_skill_point = 5;
			rewardname = "80奇豆和5点舞蹈熟练度";
			charname = "托马斯达人";
		end
        local AddMoneyFunc = commonlib.getfield("MyCompany.Aries.Player.AddMoney");
        if(AddMoneyFunc) then
	        AddMoneyFunc(joybean_count, function(msg) 
		        log("======== DanceParty.WalkoffAndRecvReward JoyBean:"..joybean_count.." returns: ========\n")
		        commonlib.echo(msg);
				if(msg.issuccess == true) then
					-- send log information
					paraworld.PostLog({action = "joybean_obtain_from_other", joybeancount = joybean_count, desc = "DancePartyArenaReward"}, 
						"joybean_obtain_from_other_log", function(msg)
					end);
				end
	        end);
        end
        -- 50231_DancerSkillPoint
        ItemManager.PurchaseItem(50231, dance_skill_point, function(msg) end, function(msg)
	        if(msg) then
		        log("+++++++Purchase 50231_DancerSkillPoint("..tostring(dance_skill_point)..") return: +++++++\n")
		        commonlib.echo(msg);
	        end
        end);
		_guihelper.MessageBox(string.format([[<div style="margin-left:10px;margin-top:10px;">
        你的表演真是太精彩了！恭喜你获得%s，有时间多来表演！对了，如果你还没有领取%s的礼物，也要记得去拿哦！</div>]], rewardname, charname))
	end
	
	local function AfterRecvPopularity()
		local dance_skill_point = 2;
		local rewardname = "1点人气值和2点舞蹈熟练度";
		local charname = "机械舞达人";
		-- play the animation
		if(arena_type == "robot") then
			-- robot dance
			dance_skill_point = 2;
			rewardname = "1点人气值和2点舞蹈熟练度";
			charname = "机械舞达人";
		elseif(arena_type == "twist") then
			-- twist dance
			dance_skill_point = 4;
			rewardname = "1点人气值和4点舞蹈熟练度";
			charname = "旋转舞达人";
		elseif(arena_type == "thomas") then
			-- thomas dance
			dance_skill_point = 5;
			rewardname = "1点人气值和5点舞蹈熟练度";
			charname = "托马斯达人";
		end
        -- 50231_DancerSkillPoint
        ItemManager.PurchaseItem(50231, dance_skill_point, function(msg) end, function(msg)
	        if(msg) then
		        log("+++++++Purchase 50231_DancerSkillPoint("..tostring(dance_skill_point)..") return: +++++++\n")
		        commonlib.echo(msg);
	        end
        end);
		_guihelper.MessageBox(string.format([[<div style="margin-left:10px;margin-top:10px;">
        你的表演真是太精彩了！恭喜你获得%s，有时间多来表演！对了，如果你还没有领取%s的礼物，也要记得去拿哦！</div>]], rewardname, charname))
	end
	
	-- get off arena stage
	DanceParty.OffArena(arena_id)
	
	-- mark the dance tag if the user hasn't danced on the stage yet
	if(arena_type == "robot") then
		if(not hasGSItem(50232)) then
			-- 50232_DancedOnRobotDanceArena
			ItemManager.PurchaseItem(50232, 1, function(msg) end, function(msg)
				if(msg) then
					log("+++++++Purchase 50232_DancedOnRobotDanceArena return: +++++++\n")
					commonlib.echo(msg);
				end
			end);
		end
	elseif(arena_type == "twist") then
		if(not hasGSItem(50233)) then
			-- 50233_DancedOnTwistDanceArena
			ItemManager.PurchaseItem(50233, 1, function(msg) end, function(msg)
				if(msg) then
					log("+++++++Purchase 50233_DancedOnTwistDanceArena return: +++++++\n")
					commonlib.echo(msg);
				end
			end);
		end
	elseif(arena_type == "thomas") then
		if(not hasGSItem(50234)) then
			--  50234_DancedOnThomasDanceArena 
			ItemManager.PurchaseItem(50234, 1, function(msg) end, function(msg)
				if(msg) then
					log("+++++++Purchase 50234_DancedOnThomasDanceArena return: +++++++\n")
					commonlib.echo(msg);
				end
			end);
		end
	end
	
	-- get the dance tag
	local dance_today_tag = 50237;
	if(arena_type == "robot") then
		-- robot dance
		dance_today_tag = 50237;
	elseif(arena_type == "twist") then
		-- twist dance
		dance_today_tag = 50238;
	elseif(arena_type == "thomas") then
		-- thomas dance
		dance_today_tag = 50239;
	end
	
	-- if already vote myself in the arena, receive joybean
	local gsObtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(dance_today_tag);
	if(gsObtain and gsObtain.inday == 0) then
		-- continue
	else
		RecvJoybean();
		return;
	end
	
	-- vote myself popularity
	local msg = {
		tonid = System.App.profiles.ProfileManager.GetNID(),
	};
	paraworld.users.VotePopularity(msg, "DanceArena_VoteSelfPopularity", function(msg) 
		log("====== DanceArena_VoteSelfPopularity returns: ======\n")
		commonlib.echo(msg);
		if(msg.issuccess == true) then
			-- success vote popularity
			UIAnimManager.PlayCustomAnimation(1000, function(elapsedTime)
				if(elapsedTime == 1000) then
					-- auto update the user info
					System.App.profiles.ProfileManager.GetUserInfo(nil, "UpdateUserName_AfterVotePopularity", function(msg)
					end, "access plus 0 day");
				end
			end);
			-- send popularity update for all clients in current game world, if user is in the same game world
			MyCompany.Aries.BBSChatWnd.SendUserPopularityUpdate(System.App.profiles.ProfileManager.GetNID());
			-- continue with dance skill point purchase
			AfterRecvPopularity();
			-- purchase the arena dance tag
	        ItemManager.PurchaseItem(dance_today_tag, 1, function(msg) end, function(msg)
		        if(msg) then
			        log("+++++++Purchase dance_today_tag:"..tostring(dance_today_tag).." return: +++++++\n")
			        commonlib.echo(msg);
		        end
	        end);
		elseif(msg.errorcode) then
		end
	end);
	
	--_guihelper.MessageBox("WalkoffAndRecvReward"..tostring(arena_id))
end

function DanceParty.DancerAlreadyOnFloor(arena_id)
	_guihelper.MessageBox([[<div style="margin-left:20px;margin-top:20px;">这个舞台已经有小哈奇在表演了，等他表演完再来吧！</div>]]);
	--_guihelper.MessageBox("DancerAlreadyOnFloor"..tostring(arena_id))
end

function DanceParty.OffArena(arena_id)
	local arena = arenas[arena_id];
	local params = {
		asset_file = "character/v5/temp/effect/loyaltydown_impact_base.x",
		binding_obj_name = ParaScene.GetPlayer().name,
		start_position = nil,
        duration_time = 800,
        force_name = nil,
        begin_callback = function() end,
        end_callback = nil,
        stage1_time = 400,
        stage1_callback = function()
				local x, y, z = arena.position[1], arena.position[2], arena.position[3];
				local radius = 3 + math.random(0, 100)/100;
				local a = math.random(0, 628)/100;
				x = x + math.cos(a) * radius;
				z = z + math.sin(a) * radius;
				y = ParaTerrain.GetElevation(x, z);
				-- set to a new position with random radius and angle
				ParaScene.GetPlayer():SetPosition(x, y, z);
				-- stop any playing animation
				ParaScene.GetPlayer():ToCharacter():Stop();
				System.Animation.PlayAnimationFile({0}, ParaScene.GetPlayer());
            end,
        stage2_time = nil,
        stage2_callback = nil,
	};
	local EffectManager = MyCompany.Aries.EffectManager;
	EffectManager.CreateEffect(params);
	
end