--[[
Title: GoldenHorse
Author(s): WangTian
Date: 2009/8/25

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/FollowPets/30548_GoldenHorse.lua
------------------------------------------------------------
]]

-- create class
local libName = "GoldenHorse";
local GoldenHorse = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.GoldenHorse", GoldenHorse);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- Golden horse scale stages

--local scale_stages = {2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6};

-- GoldenHorse.main
function GoldenHorse.main()
	GoldenHorse.init_scale = 4;
	GoldenHorse.step_scale = 0.5;
	--GoldenHorse.last_scale = GoldenHorse.last_scale or 2.5;
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30548);
	-- hook into OnThrowableHit
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnThrowableHit") then
				if(msg.msg.nid == System.App.profiles.ProfileManager.GetNID()) then
					local msg = msg.msg;
					commonlib.echo(msg);
					memory.hit_gsid = msg.throwItem.gsid;
					--memory.hitpoint_x = msg.endPoint.x;
					--memory.hitpoint_y = msg.endPoint.y;
					--memory.hitpoint_z = msg.endPoint.z;
					memory.hitObjNameList = msg.hitObjNameList;
				end
			end
		end, 
	hookName = "OnThrowableHit_30548_GoldenHorse", appName = "Aries", wndName = "throw"});

	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30548);
	local goldenHorse = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30548);
	if(goldenHorse and goldenHorse:IsValid() == true) then
		if(not memory.isPlaying) then
			goldenHorse:SetScale(4);
		end
	end
end

function GoldenHorse.CreateFunction()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30548);
	local horse = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30548);
	if(horse and horse:IsValid() == true) then

	else
		NPL.load("(gl)script/apps/Aries/Quest/NPCList.lua");
		local NPCList = commonlib.gettable("MyCompany.Aries.Quest.NPCList");
		local params = NPCList.GetNPCByIDAllWorlds(30548);
		--params.instance = 1;
		NPC.CreateNPCCharacter(30548,params);
		local horse = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30548);
		headon_speech.Speek(horse.name, headon_speech.GetBoldTextMCML("我小蓝马王子来啦，快给点掌声！"), 3, true);
	end
end

-- GoldenHorse.On_Timer
function GoldenHorse.On_Timer()
	-- AI script will reset nextGossipInstance to nil if visualized
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30548);
	local time = MyCompany.Aries.Scene.GetElapsedSecondsSince0000();
	local minute = math.floor(time/60)%60;
	minute = tonumber(minute);
	local horse = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30548);
	if(minute >= 6 and minute <= 15) then
		-- select one of the horse to say the headon text
		--memory.lastHeadonTextTime = time;
		--local r = math.random(1, 8); -- in case of 0
		--local choice = math.ceil(r);
		--local horse = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30548);
		--local player = ParaScene.GetPlayer();
		--if(horse and horse:IsValid() == true) then
			----echo("1111");
			----local r = math.random(1, 4);
			----local choice = math.ceil(r) or 1;
			----local gossips = {"我是温顺的小蓝马，我肚子饿了，想吃果冻！",
							----"我是快乐的小蓝马，我最喜欢吃滑滑甜甜的东西，你知道是什么吗？",
							----"嘀哒嘀，嘀哒嘀，我的颜色最魅力！",
							----"你给我带果冻来了吗？",};
			----local dist = horse:DistanceTo(player);
			----if(dist < 30) then
				----headon_speech.Speek(horse.name, headon_speech.GetBoldTextMCML(gossips[choice]), 3, true);
			----end
		--else
			----echo("2222");
			--
			--NPL.load("(gl)script/apps/Aries/Quest/NPCList.lua");
			--local NPCList = commonlib.gettable("MyCompany.Aries.Quest.NPCList");
			--local params = NPCList.GetNPCByIDAllWorlds(30548);
			----params.instance = 1;
			--NPC.CreateNPCCharacter(30548,params);
			--local horse = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30548);
			--headon_speech.Speek(horse.name, headon_speech.GetBoldTextMCML("我小蓝马王子来啦，快给点掌声！"), 3, true);
--
			--local text = "[公告]特殊NPC“小蓝马王子”在青青牧场出现，快去找它玩耍吧！"
			--CommonCtrl.BroadcastHelper.PushLabel({id="goldenHorse_appear", label = text, max_duration=10000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
			--text = string.format();
			--MyCompany.Aries.ChatSystem.ChatChannel.AppendChat({ChannelIndex=MyCompany.Aries.ChatSystem.ChatChannel.EnumChannels.System, is_direct_mcml=true, words=text, bHideSubject=true});
		--end
	else
		if(horse and horse:IsValid() == true) then
			if(not memory.isPlaying) then

				local horseChar = horse:ToCharacter();
				horseChar:Stop();
				local name = horse.name;
				-- remove the snake from scene
	            local params = {
		            asset_file = "character/v5/09effect/Disappear/Disappear.x",
		            binding_obj_name = name,
		            start_position = nil,
		            duration_time = 3000,
		            force_name = "GoldenHorseDisappearEffect",
		            begin_callback = function() end,
		            end_callback = nil,
		            stage1_time = 1000,
		            stage1_callback = function()
						    headon_speech.Speek(name, headon_speech.GetBoldTextMCML("放风时间到了，我该回家了，小哈奇，拜拜"), 3, true);
			            end,
		            stage2_time = 2500,
					stage2_callback = function()
							NPC.DeleteNPCCharacter(30548);
						end,
	            };
	            local EffectManager = MyCompany.Aries.EffectManager;
	            EffectManager.CreateEffect(params);
			end
		end
	end
end

-- GoldenHorse.On_Shrink
-- @param instance: npc instance of the Goldenhorse
function GoldenHorse.On_Shrink()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30548);
	local goldenHorse = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30548);
	if(goldenHorse and goldenHorse:IsValid() == true) then
		memory.stage = 1;
		local scale_from = goldenHorse:GetScale();
		local scale_to = GoldenHorse.init_scale;
		--echo("1111111");
		--echo(goldenHorse.init_scale);
		--echo(goldenHorse.last_scale);
		--goldenHorse.last_scale = goldenHorse.init_scale;
		memory.shrinkCountDown = nil;
		memory.shrinkStartTime = nil;
		memory.isShrinking = true;
		--memory.isFull = nil;
		memory.isPlaying = nil;
		--memory.hitcount = 0;
		-- repick random
		--memory.random = nil;
		-- linar shirinking scale
		UIAnimManager.PlayCustomAnimation(500, function(elapsedTime)
			local goldenHorse = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30548);
			if(goldenHorse and goldenHorse:IsValid() == true) then
				if(elapsedTime == 500) then
					goldenHorse:SetScale(scale_to);
					-- finish shrinking animation
					memory.isShrinking = nil;
				end
				local this_scale = (scale_to - scale_from) * elapsedTime / 500 + scale_from;
				goldenHorse:SetScale(this_scale);
			end
		end);
	end
end

-- GoldenHorse.On_Hit
-- @param instance: npc instance of the Goldenhorse
function GoldenHorse.On_Hit()
	if(not hasGSItem(50404)) then
		_guihelper.MessageBox("你的小游戏次数已经用尽了，不能再获得游戏奖励，是否现在购买？",function(result)
			if(result == _guihelper.DialogResult.Yes)then
				NPL.load("(gl)script/apps/Aries/Pet/LittleGame.lua");
				local LittleGame = commonlib.gettable("MyCompany.Aries.Pet.LittleGame");
				LittleGame.ShowPage();
			end
		end, _guihelper.MessageBoxButtons.YesNo);
	end

	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30548);

	--local stepvalue = 1;

	local goldenHorse = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30548);


	if(goldenHorse and goldenHorse:IsValid() == true) then

		if(hasGSItem(2131)) then
			headon_speech.Speek(goldenHorse.name, headon_speech.GetBoldTextMCML("你已经有小恶魔锤了，喂我吃再多魔力果冻也没好东西哦！"), 3, true);
			return;
		end
		--memory.stage = memory.stage or 1;

		--if(hit_gsid == 9508 or hit_gsid == 9509) then
			--stepvalue = #scale_stages - memory.stage;
		--end
		
		if(memory.isShrinking == true) then
			-- skip the hit response while shrinking
			return;
		end
		
		if(not hasGSItem(52101)) then
			-- scale to the next stage
			memory.shrinkStartTime = ParaGlobal.GetGameTime();
			memory.shrinkCountDown = 20000;
			memory.isPlaying = true;
			--memory.hitcount = memory.hitcount or 0; 
			--local scale_from = scale_stages[memory.stage];
			local scale_from = goldenHorse:GetScale();
			local scale_to = scale_from + GoldenHorse.step_scale;
			local deltaScale = scale_to - scale_from;
			local times = {1, 50, 100, 150, 200, 250, 300, 350};
			local data = {0, 9,  16,  21,  24,  25,  24,  21};
			local name = goldenHorse.name;
			UIAnimManager.PlayCustomAnimation(350, function(elapsedTime)
				local goldenHorse = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30548);
				if(goldenHorse and goldenHorse:IsValid() == true) then
					if(elapsedTime == 350) then
						goldenHorse:SetScale(scale_to);
					end
					local first, second;
					local i, time;
					for i, time in pairs(times) do
						if(times[i + 1] and elapsedTime >= times[i] and elapsedTime < times[i + 1]) then
							first = i;
							second = i + 1;
							break;
						end
					end
					if(first and second) then
						local delta = ((elapsedTime - times[first])/(times[second] - times[first]) * (data[second] - data[first]) + data[first]) * deltaScale / 25;
						goldenHorse:SetScale(delta + scale_from);
					end
				end
			end);
			--goldenHorse.last_scale = scale_to;
			--memory.stage = memory.stage + stepvalue;
			--echo("2222222");
			ItemManager.ExtendedCost(1923, nil, nil, function(msg)
				log("+++++++ExtendedCost 1923:  return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess == true) then
					local hasBe,_,_,copies = hasGSItem(52100);
					if(msg.obtains[52101]) then
						--echo("5555555555");
						--local hasBe,_,_,copies = hasGSItem(52100);
						if(copies == 5) then
							GoldenHorse.On_ReachFinalStage(1);
						else
							GoldenHorse.On_ReachFinalStage(0);
						end
						--echo(memory.stage);
						--GoldenHorse.On_ReachFinalStage(memory.stage);
						--ItemManager.ExtendedCost(1921);
					else
						local s = string.format("你已经喂我%d次了,喂够6次变最大就给你恶魔锤哦",copies);
						headon_speech.Speek(name, headon_speech.GetBoldTextMCML(s), 3, true);
					end
				end
			end);
			--local has
			--local s = string.format("你已经喂我%d次了,喂够6次变最大就给你恶魔锤哦",memory.hitcount);
			--headon_speech.Speek(goldenHorse.name, headon_speech.GetBoldTextMCML(s), 3, true);
			--memory.hitcount = memory.hitcount + 1;
			--if(scale_stages[memory.stage + 1] == nil) then
				---- reach the final stage
				----echo("22222222");
				--GoldenHorse.On_ReachFinalStage();
			--else
				----_guihelper.MessageBox(memory.stage);
				--headon_speech.Speek(GoldenHorse.name, headon_speech.GetBoldTextMCML("魔力果冻好吃，再来一个！"), 3, true);
			--end
			---- exid 22: GoldenHorse_JoyBean_500
			----ItemManager.ExtendedCost(1907);
		else
			local hasBe,_,_,copies = hasGSItem(52100);
			if(copies == 5) then
				GoldenHorse.On_ReachFinalStage(1);
			else
				GoldenHorse.On_ReachFinalStage(0);
			end
		end
	end
end

function GoldenHorse.On_ReachFinalStage(state)
	--echo("11111111");
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30548);
	--echo(memory);
	local goldenHorse = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30548);
	if(goldenHorse and goldenHorse:IsValid() == true) then
		memory.shrinkStartTime = ParaGlobal.GetGameTime();
		memory.shrinkCountDown = 10000000;
		--memory.isFull = true;
		--_guihelper.MessageBox("XXXXXXXXX");
		System.App.Commands.Call("Profile.Aries.ShowNPCDialog", 
			{npc_id = 30548, state = state}
		);
		--echo("OOOOOOOOOOOOO");
		local player = ParaScene.GetPlayer();
		local dx, dy, dz = goldenHorse:GetPosition();
		local px, py, pz = player:GetPosition();
		local goldenHorseChar = goldenHorse:ToCharacter();
		local s = goldenHorseChar:GetSeqController();
		goldenHorseChar:Stop();
		s:WalkTo((px - dx), 0, (pz - dz));
	end
end

-- quest speech
-- @return: false if speak the headon speech
--			true if continue with the next dialog answer condition
function GoldenHorse.PreDialog(npc_id)
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30548);
	local goldenHorse = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30548);
	if(goldenHorse and goldenHorse:IsValid() == true) then
		if(hasGSItem(52101)) then
			return true;
		--elseif(memory.isFull == true and memory.isRewarded == true) then
			--log("error: Goldenhorse rewarded and full \n")
			--return false;
		end
		headon_speech.Speek(goldenHorse.name, headon_speech.GetBoldTextMCML("魔力果冻是我的爱！"), 3, true);
	end
	return false;
end