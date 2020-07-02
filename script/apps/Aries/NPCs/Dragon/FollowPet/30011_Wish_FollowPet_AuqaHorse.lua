--[[
Title: 30011_Wish_FollowPet_AuqaHorse
Author(s): WangTian
Date: 2009/7/29

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet_AuqaHorse.lua
------------------------------------------------------------
]]

-- create class
local libName = "WishRandom_FollowPet_AquaHorse";
local WishRandom_FollowPet_AquaHorse = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.WishRandom_FollowPet_AquaHorse", WishRandom_FollowPet_AquaHorse);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- WishRandom_FollowPet_AquaHorse.main
function WishRandom_FollowPet_AquaHorse.main()
end

function WishRandom_FollowPet_AquaHorse.On_Timer()
end

-- 50077_Wish_FollowPet3_CatchAquaHorse_Acquire
-- 50078_Wish_FollowPet3_CatchAquaHorse_Complete
-- 50079_Wish_FollowPet3_CatchAquaHorse_RewardFriendliness
-- 50080_Wish_FollowPet4_PlayWithAquaHorse_Acquire
-- 50081_Wish_FollowPet4_PlayWithAquaHorse_Complete
-- 50082_Wish_FollowPet4_PlayWithAquaHorse_RewardFriendliness

--50163_WishFollowPet3_Acquire
--50164_WishFollowPet4_Acquire

-- 10108_FollowPetXM

-- refresh quest status
function WishRandom_FollowPet_AquaHorse.RefreshStatus()
	-- check if dragon fetched from sophie
	if(not MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie()) then
		return;
	end
	
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
	
	-- 50163_WishFollowPet3_Acquire
	if(hasGSItem(50163)) then
		if(hasGSItem(10108)) then
			local bHas, guid = hasGSItem(50163);
			-- NOTE: discard the destroy the acquire and refresh afterwards
			if(bHas and guid) then
				ItemManager.DestroyItem(guid, 1, function(msg) end, function(msg)
					log("+++++++ Destroy 50163_WishFollowPet3_Acquire when happened to have auqahorse already return: +++++++\n")
					commonlib.echo(msg);
					WishRandom_FollowPet_AquaHorse.RefreshStatus();
				end);
			end
		else
			QuestArea.AppendQuestStatus(
				"script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet3_CatchAquaHorse_status.html",
				"dragon", "", "带一只小蓝马回家",  50163);
		end
		WishRandom_FollowPet_AquaHorse.RegisterHook1();
	elseif(not hasGSItem(50163)) then
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet3_CatchAquaHorse_status.html");
		WishRandom_FollowPet_AquaHorse.UnregisterHook1();
	end
	
	-- 50164_WishFollowPet4_Acquire
	if(hasGSItem(50164)) then
		QuestArea.AppendQuestStatus(
			"script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet4_PlayWithAquaHorse_status.html",
			"dragon", "", "喂饱青青马场的小蓝马",  50164);
		WishRandom_FollowPet_AquaHorse.RegisterHook2();
	elseif(not hasGSItem(50164)) then
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet4_PlayWithAquaHorse_status.html");
		WishRandom_FollowPet_AquaHorse.UnregisterHook2();
	end
end

-- on item obtained feed
-- @param gsid: global store id of the item
-- @param count: item count
function WishRandom_FollowPet_AquaHorse.OnItemObtained(gsid, count)
	-- 10108_FollowPetXM
	if(gsid == 10108) then
		local bHas_50163, guid_50163 = hasGSItem(50163);
		if(bHas_50163) then
			-- complete the quest by extended cost
			ItemManager.ExtendedCost(65, nil, nil, function(msg)end, function(msg)
				log("+++++++ WishFollowPetSeries ExtendedCost 65: DragonQuestRandom_FollowPet3 return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess == true) then
					-- notify the quest finished
					WishRandom_FollowPet_AquaHorse.RefreshStatus();
					Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet3_CatchAquaHorse_Finish.html");
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
			--ItemManager.DestroyItem(guid_50163, 1, function(msg)
				--log("+++++++ Destroy 50163_WishFollowPet3_Acquire return: +++++++\n")
				--commonlib.echo(msg);
				--if(msg.issuccess == true) then
					--ItemManager.PurchaseItem(50078, 1, function(msg) end, function(msg)
						--if(msg) then
							--log("+++++++Purchase 50078_Wish_FollowPet3_CatchAquaHorse_Complete return: +++++++\n")
							--commonlib.echo(msg);
							--if(msg.issuccess == true) then
								--WishRandom_FollowPet_AquaHorse.RefreshStatus();
								--Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet3_CatchAquaHorse_Finish.html");
							--end
						--end
					--end);
					--ItemManager.PurchaseItem(50079, 1, function(msg) end, function(msg)
						--if(msg) then
							--log("+++++++Purchase 50079_Wish_FollowPet3_CatchAquaHorse_RewardFriendliness return: +++++++\n")
							--commonlib.echo(msg);
							--if(msg.issuccess == true) then
								---- use the item 50079 to increase pet friendliness
								--local bHas, guid = hasGSItem(50079);
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

function WishRandom_FollowPet_AquaHorse.OnJoyBeanObtainFromAquaHorse(count)
	local bHas_50164, guid_50164 = hasGSItem(50164);
	if(bHas_50164) then
		-- complete the quest by extended cost
		ItemManager.ExtendedCost(66, nil, nil, function(msg)end, function(msg)
			log("+++++++ WishFollowPetSeries ExtendedCost 66: DragonQuestRandom_FollowPet4 return: +++++++\n")
			commonlib.echo(msg);
			if(msg.issuccess == true) then
				-- notify the quest finished
				WishRandom_FollowPet_AquaHorse.RefreshStatus();
				Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet4_PlayWithAquaHorse_Finish.html");
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
		--ItemManager.DestroyItem(guid_50164, 1, function(msg)
			--log("+++++++ Destroy 50164_WishFollowPet4_Acquire return: +++++++\n")
			--commonlib.echo(msg);
			--if(msg.issuccess == true) then
				--ItemManager.PurchaseItem(50081, 1, function(msg) end, function(msg)
					--if(msg) then
						--log("+++++++Purchase 50081_Wish_FollowPet4_PlayWithAquaHorse_Complete return: +++++++\n")
						--commonlib.echo(msg);
						--if(msg.issuccess == true) then
							--WishRandom_FollowPet_AquaHorse.RefreshStatus();
							--Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet4_PlayWithAquaHorse_Finish.html");
						--end
					--end
				--end);
				--ItemManager.PurchaseItem(50082, 1, function(msg) end, function(msg)
					--if(msg) then
						--log("+++++++Purchase 50082_Wish_FollowPet4_PlayWithAquaHorse_RewardFriendliness return: +++++++\n")
						--commonlib.echo(msg);
						--if(msg.issuccess == true) then
							---- use the item 50076 to increase pet friendliness
							--local bHas, guid = hasGSItem(50082);
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
function WishRandom_FollowPet_AquaHorse.RegisterHook1()
	-- hook into item obtain
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnObtainItemAfterGetItemsInBag") then
				WishRandom_FollowPet_AquaHorse.OnItemObtained(msg.gsid, msg.count);
			end
		end, 
		hookName = "WishRandom_FollowPet_AquaHorse_CatchAquaHorse", appName = "Aries", wndName = "main"});
end
function WishRandom_FollowPet_AquaHorse.RegisterHook2()
	-- hook into AquaHorse joy bean obtain
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnJoyBeanObtainFromAquaHorse") then
				WishRandom_FollowPet_AquaHorse.OnJoyBeanObtainFromAquaHorse(msg.count);
			end
		end, 
		hookName = "WishRandom_FollowPet_AquaHorse_PlayWithAquaHorse", appName = "Aries", wndName = "main"});
end

-- unregister hook
function WishRandom_FollowPet_AquaHorse.UnregisterHook1()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "WishRandom_FollowPet_AquaHorse_CatchAquaHorse", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end
-- unregister hook
function WishRandom_FollowPet_AquaHorse.UnregisterHook2()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "WishRandom_FollowPet_AquaHorse_PlayWithAquaHorse", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end