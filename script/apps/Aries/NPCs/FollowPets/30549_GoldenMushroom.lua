--[[
Title: GoldenMushroom
Author(s): WangTian
Date: 2009/8/25

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/FollowPets/30549_GoldenMushroom.lua
------------------------------------------------------------
]]

-- create class
local libName = "GoldenMushroom";
local GoldenMushroom = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.GoldenMushroom", GoldenMushroom);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;


-- GoldenMushroom.main
function GoldenMushroom.main()
	GoldenMushroom.init_scale = 4;
	GoldenMushroom.step_scale = 0.5;
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30549);
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
	hookName = "OnThrowableHit_30549_GoldenMushroom", appName = "Aries", wndName = "throw"});

	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30549);
	local goldenMushroom = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30549);
	if(goldenMushroom and goldenMushroom:IsValid() == true) then
		if(not memory.isPlaying) then
			goldenMushroom:SetScale(4);
		end
	end
end

function GoldenMushroom.CreateFunction()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30549);
	local mushroom = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30549);

	if(mushroom and mushroom:IsValid() == true) then

	else
		NPL.load("(gl)script/apps/Aries/Quest/NPCList.lua");
		local NPCList = commonlib.gettable("MyCompany.Aries.Quest.NPCList");
		local params = NPCList.GetNPCByIDAllWorlds(30549);
		NPC.CreateNPCCharacter(30549,params);
		local mushroom = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30549);
		headon_speech.Speek(mushroom.name, headon_speech.GetBoldTextMCML("我蘑菇噜王子来啦，快给点掌声！"), 3, true);
	end	
end

-- GoldenMushroom.On_Timer
function GoldenMushroom.On_Timer()
	-- AI script will reset nextGossipInstance to nil if visualized
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30549);
	local time = MyCompany.Aries.Scene.GetElapsedSecondsSince0000();
	--echo(time);
	local minute = math.floor(time/60)%60;
	
	--echo(minute);
	minute = tonumber(minute);
	local mushroom = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30549);
	if(minute >= 6 and minute <= 15) then

		--if(mushroom and mushroom:IsValid() == true) then
--
		--else
			--NPL.load("(gl)script/apps/Aries/Quest/NPCList.lua");
			--local NPCList = commonlib.gettable("MyCompany.Aries.Quest.NPCList");
			--local params = NPCList.GetNPCByIDAllWorlds(30549);
			----params.instance = 1;
			--NPC.CreateNPCCharacter(30549,params);
			--local mushroom = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30549);
			--headon_speech.Speek(mushroom.name, headon_speech.GetBoldTextMCML("我蘑菇噜王子来啦，快给点掌声！"), 3, true);
--
			--CommonCtrl.BroadcastHelper.PushLabel({id="goldenMushroom_appear", label = event.attr.value or text, max_duration=10000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
			--MyCompany.Aries.ChatSystem.ChatChannel.AppendChat({ChannelIndex=MyCompany.Aries.ChatSystem.ChatChannel.EnumChannels.System, is_direct_mcml=true, words=text or event.attr.value, bHideSubject=true});
		--end
	else
		if(mushroom and mushroom:IsValid() == true) then
			--echo(memory.isPlaying);
			if(not memory.isPlaying) then
				local mushroomChar = mushroom:ToCharacter();
				mushroomChar:Stop();
				local name = mushroom.name;
				-- remove the snake from scene
	            local params = {
		            asset_file = "character/v5/09effect/Disappear/Disappear.x",
		            binding_obj_name = name,
		            start_position = nil,
		            duration_time = 3000,
		            force_name = "GoldenMushroomDisappearEffect",
		            begin_callback = function() end,
		            end_callback = nil,
		            stage1_time = 1000,
		            stage1_callback = function()
						    headon_speech.Speek(name, headon_speech.GetBoldTextMCML("放风时间到了，我该回家了，小哈奇，拜拜"), 3, true);
			            end,
		            stage2_time = 2500,
					stage2_callback = function()
							NPC.DeleteNPCCharacter(30549);
						end,
	            };
	            local EffectManager = MyCompany.Aries.EffectManager;
	            EffectManager.CreateEffect(params);
			end
		end
	end
end

-- GoldenMushroom.On_Shrink
-- @param instance: npc instance of the GoldenMushroom
function GoldenMushroom.On_Shrink()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30549);
	local goldenMushroom = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30549);
	if(goldenMushroom and goldenMushroom:IsValid() == true) then
		memory.stage = 1;
		local scale_from = goldenMushroom:GetScale();
		local scale_to = GoldenMushroom.init_scale;
		memory.shrinkCountDown = nil;
		memory.shrinkStartTime = nil;
		memory.isShrinking = true;
		--memory.isFull = nil;
		memory.isPlaying = nil;
		--memory.hitcount = 0;
		UIAnimManager.PlayCustomAnimation(500, function(elapsedTime)
			local goldenMushroom = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30549);
			if(goldenMushroom and goldenMushroom:IsValid() == true) then
				if(elapsedTime == 500) then
					goldenMushroom:SetScale(scale_to);
					-- finish shrinking animation
					memory.isShrinking = nil;
				end
				local this_scale = (scale_to - scale_from) * elapsedTime / 500 + scale_from;
				goldenMushroom:SetScale(this_scale);
			end
		end);
	end
end

-- GoldenMushroom.On_Hit
-- @param instance: npc instance of the GoldenMushroom
function GoldenMushroom.On_Hit()
	if(not hasGSItem(50404)) then
		_guihelper.MessageBox("你的小游戏次数已经用尽了，不能再获得游戏奖励，是否现在购买？",function(result)
			if(result == _guihelper.DialogResult.Yes)then
				NPL.load("(gl)script/apps/Aries/Pet/LittleGame.lua");
				local LittleGame = commonlib.gettable("MyCompany.Aries.Pet.LittleGame");
				LittleGame.ShowPage();
			end
		end, _guihelper.MessageBoxButtons.YesNo);
	end

	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30549);

	--local stepvalue = 1;

	local goldenMushroom = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30549);
	if(goldenMushroom and goldenMushroom:IsValid() == true) then
		if(hasGSItem(2131)) then
			headon_speech.Speek(goldenMushroom.name, headon_speech.GetBoldTextMCML("你已经有小恶魔锤了，别在砸我了！"), 3, true);
			return;
		end
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
			local scale_from = goldenMushroom:GetScale();
			local scale_to = scale_from + GoldenMushroom.step_scale;
			local deltaScale = scale_to - scale_from;
			local times = {1, 50, 100, 150, 200, 250, 300, 350};
			local data = {0, 9,  16,  21,  24,  25,  24,  21};
			local name = goldenMushroom.name;
			UIAnimManager.PlayCustomAnimation(350, function(elapsedTime)
				local goldenMushroom = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30549);
				if(goldenMushroom and goldenMushroom:IsValid() == true) then
					if(elapsedTime == 350) then
						goldenMushroom:SetScale(scale_to);
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
						goldenMushroom:SetScale(delta + scale_from);
					end
				end
			end);
			ItemManager.ExtendedCost(1922, nil, nil, function(msg)
				log("+++++++ExtendedCost 1923:  return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess == true) then
					local hasBe,_,_,copies = hasGSItem(52100);
					if(msg.obtains[52101]) then
						--local hasBe,_,_,copies = hasGSItem(52100);
						if(copies == 5) then
							GoldenMushroom.On_ReachFinalStage(1);
						else
							GoldenMushroom.On_ReachFinalStage(0);
						end
					else
						local s = string.format("你已经砸中我%d次了,砸中6次变最大就给你恶魔锤哦",copies);
						headon_speech.Speek(name, headon_speech.GetBoldTextMCML(s), 3, true);
					end
				end
			end);
			--memory.hitcount = memory.hitcount + 1;
			--local s = string.format("你已经砸中我%d次了,砸中6次变最大就给你恶魔锤哦",memory.hitcount);
			--headon_speech.Speek(goldenMushroom.name, headon_speech.GetBoldTextMCML(s), 3, true);
			
		else
			local hasBe,_,_,copies = hasGSItem(52100);
			--echo(copies);
			if(copies == 5) then
				--echo("22222");
				GoldenMushroom.On_ReachFinalStage(1);
			else
				--echo("3333");
				GoldenMushroom.On_ReachFinalStage(0);
			end
		end
	end
end

function GoldenMushroom.On_ReachFinalStage(state)
	--echo("11111111");
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30549);
	--echo(memory);
	local goldenMushroom = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30549);
	if(goldenMushroom and goldenMushroom:IsValid() == true) then
		memory.shrinkStartTime = ParaGlobal.GetGameTime();
		memory.shrinkCountDown = 10000000;
		--memory.isFull = true;
		System.App.Commands.Call("Profile.Aries.ShowNPCDialog", 
			{npc_id = 30549, state = state}
		);
		--echo("555555");
		local player = ParaScene.GetPlayer();
		local dx, dy, dz = goldenMushroom:GetPosition();
		local px, py, pz = player:GetPosition();
		local goldenMushroomChar = goldenMushroom:ToCharacter();
		local s = goldenMushroomChar:GetSeqController();
		goldenMushroomChar:Stop();
		s:WalkTo((px - dx), 0, (pz - dz));
	end
end

-- quest speech
-- @return: false if speak the headon speech
--			true if continue with the next dialog answer condition
function GoldenMushroom.PreDialog(npc_id)
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30549);
	local goldenMushroom = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30549);
	if(goldenMushroom and goldenMushroom:IsValid() == true) then
		if(hasGSItem(52101)) then
			return true;
		--elseif(memory.isFull == true and memory.isRewarded == true) then
			--log("error: GoldenMushroom rewarded and full \n")
			--return false;
		end
		headon_speech.Speek(goldenMushroom.name, headon_speech.GetBoldTextMCML("只有魔力水球才能打动我，嘿嘿！"), 3, true);
	end
	return false;
end