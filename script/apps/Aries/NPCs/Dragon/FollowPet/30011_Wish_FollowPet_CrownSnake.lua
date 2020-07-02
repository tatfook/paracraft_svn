--[[
Title: 30011_Wish_FollowPet_CrownSnake
Author(s): WangTian
Date: 2009/7/29

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet_CrownSnake.lua
------------------------------------------------------------
]]

-- create class
local libName = "WishRandom_FollowPet_CrownSnake";
local WishRandom_FollowPet_CrownSnake = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.WishRandom_FollowPet_CrownSnake", WishRandom_FollowPet_CrownSnake);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- WishRandom_FollowPet_CrownSnake.main
function WishRandom_FollowPet_CrownSnake.main()
end

function WishRandom_FollowPet_CrownSnake.On_Timer()
end

-- 50083_Wish_FollowPet5_CatchCrownSnake_Acquire
-- 50084_Wish_FollowPet5_CatchCrownSnake_Complete
-- 50085_Wish_FollowPet5_CatchCrownSnake_RewardFriendliness
-- 50086_Wish_FollowPet6_PlayWithCrownSnake_Acquire
-- 50087_Wish_FollowPet6_PlayWithCrownSnake_Complete
-- 50088_Wish_FollowPet6_PlayWithCrownSnake_RewardFriendliness

-- 50165_WishFollowPet5_Acquire
-- 50166_WishFollowPet6_Acquire

-- 10110_FollowPetHGS

-- refresh quest status
function WishRandom_FollowPet_CrownSnake.RefreshStatus()
	-- check if dragon fetched from sophie
	if(not MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie()) then
		return;
	end
	
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
	
	-- 50165_WishFollowPet5_Acquire
	if(hasGSItem(50165)) then
		if(hasGSItem(10110)) then
			local bHas, guid = hasGSItem(50165);
			-- NOTE: discard the destroy the acquire and refresh afterwards
			if(bHas and guid) then
				ItemManager.DestroyItem(guid, 1, function(msg) end, function(msg)
					log("+++++++ Destroy 50165_WishFollowPet5_Acquire when happened to have crownsnake already return: +++++++\n")
					commonlib.echo(msg);
					WishRandom_FollowPet_CrownSnake.RefreshStatus();
				end);
			end
		else
			QuestArea.AppendQuestStatus(
				"script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet5_CatchCrownSnake_status.html",
				"dragon", "", "收养皇冠蛇",  50165);
		end
		WishRandom_FollowPet_CrownSnake.RegisterHook1();
	elseif(not hasGSItem(50165)) then
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet5_CatchCrownSnake_status.html");
		WishRandom_FollowPet_CrownSnake.UnregisterHook1();
	end
	
	-- 50166_WishFollowPet6_Acquire
	if(hasGSItem(50166)) then
		QuestArea.AppendQuestStatus(
			"script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet6_PlayWithCrownSnake_status.html",
			"dragon", "", "挑战皇冠蛇",  50166);
		WishRandom_FollowPet_CrownSnake.RegisterHook2();
	elseif(not hasGSItem(50166)) then
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet6_PlayWithCrownSnake_status.html");
		WishRandom_FollowPet_CrownSnake.UnregisterHook2();
	end
end

-- on item obtained feed
-- @param gsid: global store id of the item
-- @param count: item count
function WishRandom_FollowPet_CrownSnake.OnItemObtained(gsid, count)
	-- 10110_FollowPetHGS
	if(gsid == 10110) then
		local bHas_50165, guid_50165 = hasGSItem(50165);
		if(bHas_50165) then
			-- complete the quest by extended cost
			ItemManager.ExtendedCost(67, nil, nil, function(msg)end, function(msg)
				log("+++++++ WishFollowPetSeries ExtendedCost 67: DragonQuestRandom_FollowPet5 return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess == true) then
					-- notify the quest finished
					WishRandom_FollowPet_CrownSnake.RefreshStatus();
					Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet5_CatchCrownSnake_Finish.html");
					-- use the reward item to increase pet friendliness
					local bHas, guid = hasGSItem(50128);
					if(bHas and guid) then
						local item = ItemManager.GetItemByGUID(guid);
						if(item and item.guid > 0) then
							item:OnClick("left");
						end
					end
				end
			end);
			--ItemManager.DestroyItem(guid_50165, 1, function(msg)
				--log("+++++++ Destroy 50165_WishFollowPet5_Acquire return: +++++++\n")
				--commonlib.echo(msg);
				--if(msg.issuccess == true) then
					--ItemManager.PurchaseItem(50084, 1, function(msg) end, function(msg)
						--if(msg) then
							--log("+++++++Purchase 50084_Wish_FollowPet5_CatchCrownSnake_Complete return: +++++++\n")
							--commonlib.echo(msg);
							--if(msg.issuccess == true) then
								--WishRandom_FollowPet_CrownSnake.RefreshStatus();
								--Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet5_CatchCrownSnake_Finish.html");
							--end
						--end
					--end);
					--ItemManager.PurchaseItem(50085, 1, function(msg) end, function(msg)
						--if(msg) then
							--log("+++++++Purchase 50085_Wish_FollowPet5_CatchCrownSnake_RewardFriendliness return: +++++++\n")
							--commonlib.echo(msg);
							--if(msg.issuccess == true) then
								---- use the item 50085 to increase pet friendliness
								--local bHas, guid = hasGSItem(50085);
								--if(bHas and guid) then
									--local item = ItemManager.GetItemByGUID(guid);
									--if(item and item.guid > 0) then
										--item:OnClick("left");
									--end
								--end
							--end
						--end
					--end);
				--end
			--end);
		end
	end
end

function WishRandom_FollowPet_CrownSnake.OnJoyBeanObtainFromCrownSnake(count)
	local bHas_50166, guid_50166 = hasGSItem(50166);
	if(bHas_50166) then
		-- complete the quest by extended cost
		ItemManager.ExtendedCost(68, nil, nil, function(msg)end, function(msg)
			log("+++++++ WishFollowPetSeries ExtendedCost 68: DragonQuestRandom_FollowPet6 return: +++++++\n")
			commonlib.echo(msg);
			if(msg.issuccess == true) then
				-- notify the quest finished
				WishRandom_FollowPet_CrownSnake.RefreshStatus();
				Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet6_PlayWithCrownSnake_Finish.html");
				-- use the reward item to increase pet friendliness
				local bHas, guid = hasGSItem(50128);
				if(bHas and guid) then
					local item = ItemManager.GetItemByGUID(guid);
					if(item and item.guid > 0) then
						item:OnClick("left");
					end
				end
			end
		end);
		--ItemManager.DestroyItem(guid_50166, 1, function(msg)
			--log("+++++++ Destroy 50166_WishFollowPet6_Acquire return: +++++++\n")
			--commonlib.echo(msg);
			--if(msg.issuccess == true) then
				--ItemManager.PurchaseItem(50087, 1, function(msg) end, function(msg)
					--if(msg) then
						--log("+++++++Purchase 50087_Wish_FollowPet6_PlayWithCrownSnake_Complete return: +++++++\n")
						--commonlib.echo(msg);
						--if(msg.issuccess == true) then
							--WishRandom_FollowPet_CrownSnake.RefreshStatus();
							--Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet6_PlayWithCrownSnake_Finish.html");
						--end
					--end
				--end);
				--ItemManager.PurchaseItem(50088, 1, function(msg) end, function(msg)
					--if(msg) then
						--log("+++++++Purchase 50088_Wish_FollowPet6_PlayWithCrownSnake_RewardFriendliness return: +++++++\n")
						--commonlib.echo(msg);
						--if(msg.issuccess == true) then
							---- use the item 50088 to increase pet friendliness
							--local bHas, guid = hasGSItem(50088);
							--if(bHas and guid) then
								--local item = ItemManager.GetItemByGUID(guid);
								--if(item and item.guid > 0) then
									--item:OnClick("left");
								--end
							--end
						--end
					--end
				--end);
			--end
		--end);
	end
end

-- register hook into pet name change
function WishRandom_FollowPet_CrownSnake.RegisterHook1()
	-- hook into item obtain
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnObtainItemAfterGetItemsInBag") then
				WishRandom_FollowPet_CrownSnake.OnItemObtained(msg.gsid, msg.count);
			end
		end, 
		hookName = "WishRandom_FollowPet_CrownSnake_CatchCrownSnake", appName = "Aries", wndName = "main"});
end
function WishRandom_FollowPet_CrownSnake.RegisterHook2()
	-- hook into CrownSnake joy bean obtain
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnJoyBeanObtainFromCrownSnake") then
				WishRandom_FollowPet_CrownSnake.OnJoyBeanObtainFromCrownSnake(msg.count);
			end
		end, 
		hookName = "WishRandom_FollowPet_CrownSnake_PlayWithCrownSnake", appName = "Aries", wndName = "main"});
end

-- unregister hook
function WishRandom_FollowPet_CrownSnake.UnregisterHook1()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "WishRandom_FollowPet_CrownSnake_CatchCrownSnake", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end
-- unregister hook
function WishRandom_FollowPet_CrownSnake.UnregisterHook2()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "WishRandom_FollowPet_CrownSnake_PlayWithCrownSnake", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end