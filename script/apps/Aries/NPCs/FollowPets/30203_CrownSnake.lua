--[[
Title: CrownSnake
Author(s): WangTian
Date: 2009/8/25

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/FollowPets/30203_CrownSnake.lua
------------------------------------------------------------
]]

-- create class
local libName = "CrownSnake";
local CrownSnake = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.CrownSnake", CrownSnake);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- CrownSnake.main
function CrownSnake.main()
	local bHas, guid = hasGSItem(50055);
	--if(bHas == true) then
		--local item = ItemManager.GetItemByGUID(guid);
		--if(item and item.guid > 0) then
			--if(item.clientdata == (MyCompany.Aries.Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd"))) then
				---- delete the snake instances
				--NPC.DeleteNPCCharacter(30203, 1);
				--NPC.DeleteNPCCharacter(30203, 2);
				--return;
			--end
		--end
	--end
	
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30203);
	local snake = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30203, 1);
	if(snake and snake:IsValid() == true) then
		-- record the born position
		memory.bornPos = {snake:GetPosition()};
	end
	
	local snake2 = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30203, 2);
	if(snake2 and snake2:IsValid() == true) then
		System.SendMessage_obj({
			type = System.msg.OBJ_ModifyObject, 
			obj_params = snake2, 
			SkipHistory = true,
			asset_file = "character/common/tag/mousecursor_helper.x",
		});
	end
	
	-- hook into OnWorldClosing
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnWorldClosing") then
				-- first unhook the world closing
				CommonCtrl.os.hook.UnhookWindowsHook({hookName = "WorldClosing_CrownSnake", 
					hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
				-- then reset the snake to hide the HP bar on the screen top
				CrownSnake.EndFlee();
			end
		end, 
		hookName = "WorldClosing_CrownSnake", appName = "Aries", wndName = "main"});
end

-- CrownSnake.On_Timer
function CrownSnake.On_Timer()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30203);
	-- snake is been deleted from the scene, saying the last word
	if(memory.leaving == true) then
		return;
	end
	if(memory.countdowntime) then
		if((ParaGlobal.GetGameTime() - memory.countdowntime) > 90000) then
			if(memory.isFlee == true) then
				CrownSnake.EndFlee();
				local snake = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30203, 1);
				if(snake and snake:IsValid() == true) then
					---- say the following text with NPC_dialog
					--headon_speech.Speek(snake.name, headon_speech.GetBoldTextMCML("哎，打半天都打不中我，不跟你玩了，你明天再来吧。"), 3, true);
					System.App.Commands.Call("File.MCMLWindowFrame", {
						url = "script/apps/Aries/NPCs/FollowPets/30203_CrownSnake_dialog_answer.html?state=1", 
						app_key = MyCompany.Aries.app.app_key, 
						name = "NPC_Dialog", 
						isShowTitleBar = false,
						DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
						style = CommonCtrl.WindowFrame.ContainerStyle,
						zorder = 2,
						enable_esc_key = true,
						allowDrag = false,
						directPosition = true,
							align = "_ctb",
							x = 0,
							y = 22,
							width = 900,
							height = 230,
					});
					
					memory.leaving = true;
					local snakeChar = snake:ToCharacter();
					snakeChar:Stop();
					local name = snake.name;
					-- remove the snake from scene
	                local params = {
		                asset_file = "character/v5/09effect/Disappear/Disappear.x",
		                binding_obj_name = name,
		                start_position = nil,
		                duration_time = 3000,
		                force_name = "CrownSnakeDisappearEffect",
		                begin_callback = function() end,
		                end_callback = nil,
		                stage1_time = 1000,
		                stage1_callback = function()
						        local EffectManager = MyCompany.Aries.EffectManager;
						        EffectManager.StopBinding("CrownSnakeDisappearEffect");
				                MyCompany.Aries.Quest.NPC.DeleteNPCCharacter(30203, 1);
			                end,
		                stage2_time = 2000,
							stage2_callback = function()
									local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30203);
									memory.countdowntime = nil;
									memory.isFlee = nil;
									memory.countdowntime = nil;
									memory.leaving = nil;
									memory.isStunned = nil;
									memory.TargetFleePosIndex = nil;
									memory.lastFleePosition = nil;
									memory.isRewarded = nil;
									memory.count = nil;
									NPL.load("(gl)script/apps/Aries/Quest/NPCList.lua");
									local NPCList = commonlib.gettable("MyCompany.Aries.Quest.NPCList");
									local params = NPCList.GetNPCByIDAllWorlds(30203);
									params.instance = 1;
									MyCompany.Aries.Quest.NPC.CreateNPCCharacter(30203,params);
								end,
	                };
	                local EffectManager = MyCompany.Aries.EffectManager;
	                EffectManager.CreateEffect(params);
				end
			end
		end
	end
end

-- CrownSnake.PreDialog
function CrownSnake.PreDialog(npc_id, instance)
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30203);
	-- snake is been deleted from the scene, saying the last word
	if(memory.leaving == true) then
		return false;
	end
	if(npc_id == 30203 and instance == 1) then
		-- skip the instance 1
		if(memory.isStunned == true) then
			if(not hasGSItem(10110)) then
				return true;
			else
				local snake = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30203, 1);
				if(snake and snake:IsValid() == true) then
					if(memory.isRewarded == true) then
						-- say something when rewarded in this session
					else
						memory.isRewarded = true;
						--local r = math.random(0, 100);
						--local count = 5;
						--if(r < 50) then
							--count = 5;
							---- exid 26: CrownSnake_JoyBean_5
							--ItemManager.ExtendedCost(26, nil, nil, function(msg)
								--log("+++++++ExtendedCost 26: CrownSnake_JoyBean_5 return: +++++++\n")
								--commonlib.echo(msg);
								--if(msg.issuccess == true) then
									---- call hook for OnJoyBeanObtainFromCrownSnake
									--local hook_msg = { aries_type = "OnJoyBeanObtainFromCrownSnake", count = 5, wndName = "main"};
									--CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
									--local hook_msg = { aries_type = "onJoyBeanObtainFromCrownSnake_MPD", count = 5, wndName = "main"};
									--CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
								--
								--end
							--end);
						--elseif(r < 80) then
							--count = 30;
							---- exid 27: CrownSnake_JoyBean_30
							--ItemManager.ExtendedCost(27, nil, nil, function(msg)
								--log("+++++++ExtendedCost 27: CrownSnake_JoyBean_30 return: +++++++\n")
								--commonlib.echo(msg);
								--if(msg.issuccess == true) then
									---- call hook for OnJoyBeanObtainFromCrownSnake
									--local hook_msg = { aries_type = "OnJoyBeanObtainFromCrownSnake", count = 30, wndName = "main"};
									--CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
									--local hook_msg = { aries_type = "onJoyBeanObtainFromCrownSnake_MPD", count = 30, wndName = "main"};
									--CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
								--
								--end
							--end);
						--elseif(r < 95) then
							--count = 100;
							---- exid 28: CrownSnake_JoyBean_100
							--ItemManager.ExtendedCost(28, nil, nil, function(msg)
								--log("+++++++ExtendedCost 28: CrownSnake_JoyBean_100 return: +++++++\n")
								--commonlib.echo(msg);
								--if(msg.issuccess == true) then
									---- call hook for OnJoyBeanObtainFromCrownSnake
									--local hook_msg = { aries_type = "OnJoyBeanObtainFromCrownSnake", count = 100, wndName = "main"};
									--CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
									--local hook_msg = { aries_type = "onJoyBeanObtainFromCrownSnake_MPD", count = 100, wndName = "main"};
									--CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
--
								--end
							--end);
						--elseif(r <= 100) then
							--count = 200;
							---- exid 29: CrownSnake_JoyBean_200
							--ItemManager.ExtendedCost(29, nil, nil, function(msg)
								--log("+++++++ExtendedCost 29: CrownSnake_JoyBean_200 return: +++++++\n")
								--commonlib.echo(msg);
								--if(msg.issuccess == true) then
									---- call hook for OnJoyBeanObtainFromCrownSnake
									--local hook_msg = { aries_type = "OnJoyBeanObtainFromCrownSnake", count = 200, wndName = "main"};
									--CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
									--local hook_msg = { aries_type = "onJoyBeanObtainFromCrownSnake_MPD", count = 200, wndName = "main"};
									--CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
--
								--end
							--end);
						--end
						--local myInfo = System.App.profiles.ProfileManager.GetUserInfoInMemory();
						--local staminaValue = tonumber(myInfo.stamina);
						--local hasEnoughStamina = if_else(staminaValue >= 10,true,false);
						local speak;
						local hasBe,_,_,num = System.Item.ItemManager.IfOwnGSItem(50404);
						if(hasBe) then
							speak = "好痛呀，你别再来打我了，我的好东西都给你，你快走吧。";
							ItemManager.ExtendedCost(1908, nil, nil, function(msg)
								log("+++++++   ExtendedCost 1908 +++++++\n")
								commonlib.echo(msg);
								if(msg.issuccess == true) then
									MyCompany.Aries.Desktop.HPMyPlayerArea.UpdateUI();
									if(msg.obtains[50403]) then
										System.GSL_client:SendRealtimeMessage("sPowerAPI", {name="PowerExtendedCost", params={exid="FarmerFinedayPigShield"}});
									end
								end
							end);
							System.App.Commands.Call("File.MCMLWindowFrame", {
								url = "script/apps/Aries/NPCs/FollowPets/30203_CrownSnake_dialog_answer.html?speak="..speak, 
								app_key = MyCompany.Aries.app.app_key, 
								name = "NPC_Dialog", 
								isShowTitleBar = false,
								DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
								style = CommonCtrl.WindowFrame.ContainerStyle,
								zorder = 2,
								enable_esc_key = true,
								allowDrag = false,
								directPosition = true,
									align = "_ctb",
									x = 0,
									y = 22,
									width = 900,
									height = 230,
							});
						else
							speak = "你的小游戏奖励次数已经用尽了，在小游戏页面可以购买获得奖励的次数哦！现在购买？";
							_guihelper.MessageBox(speak,function(result) 
								if(result == _guihelper.DialogResult.Yes) then
									NPL.load("(gl)script/apps/Aries/Pet/LittleGame.lua");
									local LittleGame = commonlib.gettable("MyCompany.Aries.Pet.LittleGame");
									LittleGame.ShowPage();
								end
							end,_guihelper.MessageBoxButtons.YesNo);
						end

						---- say the following text with NPC_dialog
						--headon_speech.Speek(snake.name, headon_speech.GetBoldTextMCML("好痛呀，你别再来打我了，我给你"..count.."奇豆你快走吧。"), 3, true);
					
						
						memory.leaving = true;
						local snakeChar = snake:ToCharacter();
						snakeChar:Stop();
						local name = snake.name;
						-- remove the snake from scene
						local params = {
							asset_file = "character/v5/09effect/Disappear/Disappear.x",
							binding_obj_name = name,
							start_position = nil,
							duration_time = 4000,
							force_name = "CrownSnakeDisappearEffect",
							begin_callback = function() end,
							end_callback = nil,
							stage1_time = 3000,
							stage1_callback = function()
									local EffectManager = MyCompany.Aries.EffectManager;
									EffectManager.StopBinding("CrownSnakeDisappearEffect");
									MyCompany.Aries.Quest.NPC.DeleteNPCCharacter(30203, 1);
								end,
							stage2_time = 3500,
							stage2_callback = function()
									local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30203);
									memory.countdowntime = nil;
									memory.isFlee = nil;
									memory.countdowntime = nil;
									memory.leaving = nil;
									memory.isStunned = nil;
									memory.TargetFleePosIndex = nil;
									memory.lastFleePosition = nil;
									memory.isRewarded = nil;
									memory.count = nil;
									NPL.load("(gl)script/apps/Aries/Quest/NPCList.lua");
									local NPCList = commonlib.gettable("MyCompany.Aries.Quest.NPCList");
									local params = NPCList.GetNPCByIDAllWorlds(npc_id);
									params.instance = 1;
									MyCompany.Aries.Quest.NPC.CreateNPCCharacter(30203,params);
								end,
						};
						local EffectManager = MyCompany.Aries.EffectManager;
						EffectManager.CreateEffect(params);
					end
				end
				return false;
			end
		elseif(memory.isFlee == nil) then
			CrownSnake.BeginFlee();
			-- refresh the selected page to show the hp bar
			MyCompany.Aries.Desktop.TargetArea.RefreshSelectResponsePage();
			return false;
		elseif(memory.isFlee == true) then
			CrownSnake.On_Hit();
			-- refresh the selected page to update to the newly hit hp
			MyCompany.Aries.Desktop.TargetArea.RefreshSelectResponsePage();
			return false;
		end
	elseif(npc_id == 30203 and instance == 2) then
		-- skip the instance 2
		if(memory.isFlee == true) then
			CrownSnake.On_Miss();
		end
		return false;
	end
end

-- CrownSnake.StartFlee
function CrownSnake.BeginFlee()
	local bHas, guid = hasGSItem(50055);
	if(bHas == false) then
		ItemManager.PurchaseItem(50055, 1, function(msg) end, function(msg)
			if(msg) then
				log("+++++++Purchase 50055_CrownSnakeLastHitTag return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess == true) then
				end
			end
		end, MyCompany.Aries.Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd"));
	else
        ItemManager.SetClientData(guid, MyCompany.Aries.Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd"), function(msg_setclientdata)
			log("+++++++SetClientData 50055_CrownSnakeLastHitTag return: +++++++\n")
            commonlib.echo(msg_setclientdata);
        end);
	end
	
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30203);
	-- snake is been deleted from the scene, saying the last word
	if(memory.leaving == true) then
		return;
	end
	memory.isFlee = true;
	memory.hp = 5;
	memory.countdowntime = ParaGlobal.GetGameTime();
	local snake = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30203, 1);
	if(snake and snake:IsValid() == true) then
		snake:ToCharacter():SetSpeedScale(4);
		---- play speed sound
		--local dx, dy, dz = snake:GetPosition();
		--ParaAudio.PlayStatic3DSound("Speed", "CrownSnake_"..ParaGlobal.GenerateUniqueID(), dx, dy, dz);
		local name = "Audio/Haqi/Speed.wav";
		MyCompany.Aries.Scene.PlayGameSound(name);
	end
	--CrownSnake.RefreshHP();
end

-- CrownSnake.StartFlee
function CrownSnake.EndFlee()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30203);
	-- snake is been deleted from the scene, saying the last word
	if(memory.leaving == true) then
		return;
	end
	memory.isFlee = nil;
	memory.hp = nil;
	memory.countdowntime = nil;
	local snake = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30203, 1);
	if(snake and snake:IsValid() == true) then
		snake:ToCharacter():SetSpeedScale(1);
	end
	--CrownSnake.RefreshHP();
end

-- CrownSnake.On_Hit
function CrownSnake.On_Hit()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30203);
	-- snake is been deleted from the scene, saying the last word
	if(memory.leaving == true) then
		return;
	end
	if(memory.isFlee == true) then
		memory.hp = memory.hp - 1;
		local effect_name = ParaGlobal.GenerateUniqueID();
		if(memory.hp == 0) then
			CrownSnake.EndFlee();
			CrownSnake.On_Catch();
		end
	end
	local snake = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30203, 1);
	if(snake and snake:IsValid() == true) then
		local r = math.random(0, 100);
		if(r <= 20) then
			headon_speech.Speek(snake.name, headon_speech.GetBoldTextMCML("哎呀好痛呀，下手别这么狠呀～"), 3, true);
		elseif(r <= 40) then
			headon_speech.Speek(snake.name, headon_speech.GetBoldTextMCML("真不走运，竟然被你打中了！"), 3, true);
		elseif(r <= 60) then
			headon_speech.Speek(snake.name, headon_speech.GetBoldTextMCML("这是什么武器，打得好疼呀～"), 3, true);
		elseif(r <= 80) then
			headon_speech.Speek(snake.name, headon_speech.GetBoldTextMCML("我的骨头哇，差点被你打断了～"), 3, true);
		elseif(r <= 100) then
			headon_speech.Speek(snake.name, headon_speech.GetBoldTextMCML("痛！我好惨呀！"), 3, true);
		end
		
		-- hit effect
		local name = snake.name;
        local params = {
            asset_file = "character/v5/temp/Effect/KidneyShot_Base_Cast.x",
            binding_obj_name = name,
            start_position = nil,
            duration_time = 500,
            force_name = nil,
            begin_callback = function() end,
            end_callback = nil,
            stage1_time = nil,
            stage1_callback = nil,
            stage2_time = nil,
            stage2_callback = nil,
        };
        local EffectManager = MyCompany.Aries.EffectManager;
        EffectManager.CreateEffect(params);
		---- play speed sound
		--local dx, dy, dz = snake:GetPosition();
		--ParaAudio.PlayStatic3DSound("Btn1", "CrownSnake_"..ParaGlobal.GenerateUniqueID(), dx, dy, dz);
		local name = "Audio/Haqi/Button01.wav";
		MyCompany.Aries.Scene.PlayGameSound(name);
	end
	--CrownSnake.RefreshHP();
end

-- CrownSnake.On_Miss
function CrownSnake.On_Miss()
	local snake = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30203, 1);
	if(snake and snake:IsValid() == true) then
		local r = math.random(0, 80);
		if(r <= 20) then
			headon_speech.Speek(snake.name, headon_speech.GetBoldTextMCML("哼！想打我，可没那么容易！"), 3, true);
		elseif(r <= 40) then
			headon_speech.Speek(snake.name, headon_speech.GetBoldTextMCML("我跑！你再练练功夫吧！"), 3, true);
		elseif(r <= 60) then
			headon_speech.Speek(snake.name, headon_speech.GetBoldTextMCML("哈哈，我的皮滑溜着呢～"), 3, true);
		elseif(r <= 80) then
			headon_speech.Speek(snake.name, headon_speech.GetBoldTextMCML("耶！成功脱逃。"), 3, true);
		end
		local name = snake.name;
		-- miss effect
        local params = {
            asset_file = "character/v5/temp/Effect/GreaterHeal_Low_Base.x",
            binding_obj_name = name,
            start_position = nil,
            duration_time = 500,
            force_name = nil,
            begin_callback = function() end,
            end_callback = nil,
            stage1_time = nil,
            stage1_callback = nil,
            stage2_time = nil,
            stage2_callback = nil,
        };
        local EffectManager = MyCompany.Aries.EffectManager;
        EffectManager.CreateEffect(params);
		---- play speed sound
		--local dx, dy, dz = snake:GetPosition();
		--ParaAudio.PlayStatic3DSound("Btn4", "CrownSnake_"..ParaGlobal.GenerateUniqueID(), dx, dy, dz);
		local name = "Audio/Haqi/Button04.wav";
		MyCompany.Aries.Scene.PlayGameSound(name);
	end
end

-- CrownSnake.On_Catch
function CrownSnake.On_Catch()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30203);
	-- snake is been deleted from the scene, saying the last word
	if(memory.leaving == true) then
		return;
	end
	memory.isStunned = true;
	System.App.Commands.Call("Profile.Aries.ShowNPCDialog", 
		{npc_id = 30203, instance = 1,}
	);
end

---- refresh the hp bar
--function CrownSnake.RefreshHP()
	--local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30203);
	---- snake is been deleted from the scene, saying the last word
	--if(memory.leaving == true) then
		--return;
	--end
	--if(memory.hp == nil) then
		---- destroy
		--ParaUI.Destroy("30203_CrownSnake_HP1");
		--ParaUI.Destroy("30203_CrownSnake_HP2");
		--ParaUI.Destroy("30203_CrownSnake_HP3");
		--ParaUI.Destroy("30203_CrownSnake_HP4");
		--ParaUI.Destroy("30203_CrownSnake_HP5");
	--elseif(memory.hp <= 8) then
		---- create if not exist
		--local _CrownSnake_HP1 = ParaUI.GetUIObject("30203_CrownSnake_HP1");
		--if(_CrownSnake_HP1:IsValid() == false) then
			--_CrownSnake_HP1 = ParaUI.CreateUIObject("container", "30203_CrownSnake_HP1", "_ctt", -200, 100, 80, 44);
			--_CrownSnake_HP1:AttachToRoot();
		--end
		--local _CrownSnake_HP2 = ParaUI.GetUIObject("30203_CrownSnake_HP2");
		--if(_CrownSnake_HP2:IsValid() == false) then
			--_CrownSnake_HP2 = ParaUI.CreateUIObject("container", "30203_CrownSnake_HP2", "_ctt", -100, 100, 80, 44);
			--_CrownSnake_HP2:AttachToRoot();
		--end
		--local _CrownSnake_HP3 = ParaUI.GetUIObject("30203_CrownSnake_HP3");
		--if(_CrownSnake_HP3:IsValid() == false) then
			--_CrownSnake_HP3 = ParaUI.CreateUIObject("container", "30203_CrownSnake_HP3", "_ctt", 0, 100, 80, 44);
			--_CrownSnake_HP3:AttachToRoot();
		--end
		--local _CrownSnake_HP4 = ParaUI.GetUIObject("30203_CrownSnake_HP4");
		--if(_CrownSnake_HP4:IsValid() == false) then
			--_CrownSnake_HP4 = ParaUI.CreateUIObject("container", "30203_CrownSnake_HP4", "_ctt", 100, 100, 80, 44);
			--_CrownSnake_HP4:AttachToRoot();
		--end
		--local _CrownSnake_HP5 = ParaUI.GetUIObject("30203_CrownSnake_HP5");
		--if(_CrownSnake_HP5:IsValid() == false) then
			--_CrownSnake_HP5 = ParaUI.CreateUIObject("container", "30203_CrownSnake_HP5", "_ctt", 200, 100, 80, 44);
			--_CrownSnake_HP5:AttachToRoot();
		--end
		--
		--if(memory.hp < 5) then
			--_CrownSnake_HP5.background = "Texture/Aries/Quest/HP_slot_empty_32bits.png;0 0 25 44:11 19 13 24";
		--else
			--_CrownSnake_HP5.background = "Texture/Aries/Quest/HP_slot_red_32bits.png;0 0 25 44:11 19 13 24";
		--end
		--if(memory.hp < 4) then
			--_CrownSnake_HP4.background = "Texture/Aries/Quest/HP_slot_empty_32bits.png;0 0 25 44:11 19 13 24";
		--else
			--_CrownSnake_HP4.background = "Texture/Aries/Quest/HP_slot_red_32bits.png;0 0 25 44:11 19 13 24";
		--end
		--if(memory.hp < 3) then
			--_CrownSnake_HP3.background = "Texture/Aries/Quest/HP_slot_empty_32bits.png;0 0 25 44:11 19 13 24";
		--else
			--_CrownSnake_HP3.background = "Texture/Aries/Quest/HP_slot_red_32bits.png;0 0 25 44:11 19 13 24";
		--end
		--if(memory.hp < 2) then
			--_CrownSnake_HP2.background = "Texture/Aries/Quest/HP_slot_empty_32bits.png;0 0 25 44:11 19 13 24";
		--else
			--_CrownSnake_HP2.background = "Texture/Aries/Quest/HP_slot_red_32bits.png;0 0 25 44:11 19 13 24";
		--end
		--if(memory.hp < 1) then
			--_CrownSnake_HP1.background = "Texture/Aries/Quest/HP_slot_empty_32bits.png;0 0 25 44:11 19 13 24";
		--else
			--_CrownSnake_HP1.background = "Texture/Aries/Quest/HP_slot_red_32bits.png;0 0 25 44:11 19 13 24";
		--end
	--end
--end
--