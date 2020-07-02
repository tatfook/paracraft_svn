--[[
Title: 30011_Wish_FollowPet_Lulu
Author(s): WangTian
Date: 2009/7/29

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet_Lulu.lua
------------------------------------------------------------
]]

-- create class
local libName = "WishRandom_FollowPet_Lulu";
local WishRandom_FollowPet_Lulu = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.WishRandom_FollowPet_Lulu", WishRandom_FollowPet_Lulu);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- WishRandom_FollowPet_Lulu.main
function WishRandom_FollowPet_Lulu.main()
end

function WishRandom_FollowPet_Lulu.On_Timer()
end

-- 50071_Wish_FollowPet1_CatchLulu_Acquire
-- 50072_Wish_FollowPet1_CatchLulu_Complete
-- 50073_Wish_FollowPet1_CatchLulu_RewardFriendliness
-- 50074_Wish_FollowPet2_PlayWithLulu_Acquire
-- 50075_Wish_FollowPet2_PlayWithLulu_Complete
-- 50076_Wish_FollowPet2_PlayWithLulu_RewardFriendliness

-- 50161_WishFollowPet1_Acquire
-- 50162_WishFollowPet2_Acquire

-- 10103_FollowPetMGBB

-- refresh quest status
function WishRandom_FollowPet_Lulu.RefreshStatus()
	-- check if dragon fetched from sophie
	if(not MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie()) then
		return;
	end
	
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
	
	-- 50161_WishFollowPet1_Acquire
	if(hasGSItem(50161)) then
		if(hasGSItem(10103)) then
			local bHas, guid = hasGSItem(50161);
			-- NOTE: discard the destroy the acquire and refresh afterwards
			if(bHas and guid) then
				ItemManager.DestroyItem(guid, 1, function(msg) end, function(msg)
					log("+++++++ Destroy 50161_WishFollowPet1_Acquire when happened to have lulumushroom already return: +++++++\n")
					commonlib.echo(msg);
					WishRandom_FollowPet_Lulu.RefreshStatus();
				end);
			end
		else
			QuestArea.AppendQuestStatus(
				"script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet1_CatchLulu_status.html",
				"dragon", "", "带一只蘑菇噜回家",  50161);
		end
		WishRandom_FollowPet_Lulu.RegisterHook1();
	elseif(not hasGSItem(50161)) then
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet1_CatchLulu_status.html");
		WishRandom_FollowPet_Lulu.UnregisterHook1();
	end
	
	-- 50162_WishFollowPet2_Acquire
	if(hasGSItem(50162)) then
		QuestArea.AppendQuestStatus(
			"script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet2_PlayWithLulu_status.html",
			"dragon", "", "挑战森林里的蘑菇噜",  50162);
		WishRandom_FollowPet_Lulu.RegisterHook2();
	elseif(not hasGSItem(50162)) then
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet2_PlayWithLulu_status.html");
		WishRandom_FollowPet_Lulu.UnregisterHook2();
	end
end

-- on item obtained feed
-- @param gsid: global store id of the item
-- @param count: item count
function WishRandom_FollowPet_Lulu.OnItemObtained(gsid, count)
	-- 10103_FollowPetMGBB
	if(gsid == 10103) then
		local bHas_50161, guid_50161 = hasGSItem(50161);
		if(bHas_50161) then
			-- complete the quest by extended cost
			ItemManager.ExtendedCost(63, nil, nil, function(msg)end, function(msg)
				log("+++++++ WishFollowPetSeries ExtendedCost 63: DragonQuestRandom_FollowPet1 return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess == true) then
					-- notify the quest finished
					WishRandom_FollowPet_Lulu.RefreshStatus();
					Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet1_CatchLulu_Finish.html");
					-- use the reward item to increase pet friendliness
					local bHas, guid = hasGSItem(50126);
					if(bHas and guid) then
						local item = ItemManager.GetItemByGUID(guid);
						if(item and item.guid > 0) then
							item:OnClick("left");
						end
					end
				end
			end);
			--ItemManager.DestroyItem(guid_50161, 1, function(msg)
				--log("+++++++ Destroy 50161_WishFollowPet1_Acquire return: +++++++\n")
				--commonlib.echo(msg);
				--if(msg.issuccess == true) then
					--ItemManager.PurchaseItem(50072, 1, function(msg) end, function(msg)
						--if(msg) then
							--log("+++++++Purchase 50072_Wish_FollowPet1_CatchLulu_Complete return: +++++++\n")
							--commonlib.echo(msg);
							--if(msg.issuccess == true) then
								--WishRandom_FollowPet_Lulu.RefreshStatus();
								--Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet1_CatchLulu_Finish.html");
							--end
						--end
					--end);
					--ItemManager.PurchaseItem(50073, 1, function(msg) end, function(msg)
						--if(msg) then
							--log("+++++++Purchase 50073_Wish_FollowPet1_CatchLulu_RewardFriendliness return: +++++++\n")
							--commonlib.echo(msg);
							--if(msg.issuccess == true) then
								---- use the item 50073 to increase pet friendliness
								--local bHas, guid = hasGSItem(50073);
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

function WishRandom_FollowPet_Lulu.OnJoyBeanObtainFromLuluMushroom(count)
	local bHas_50162, guid_50162 = hasGSItem(50162);
	if(bHas_50162) then
		-- complete the quest by extended cost
		ItemManager.ExtendedCost(64, nil, nil, function(msg)end, function(msg)
			log("+++++++ WishFollowPetSeries ExtendedCost 64: DragonQuestRandom_FollowPet2 return: +++++++\n")
			commonlib.echo(msg);
			if(msg.issuccess == true) then
				-- notify the quest finished
				WishRandom_FollowPet_Lulu.RefreshStatus();
				Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet2_PlayWithLulu_Finish.html");
				-- use the reward item to increase pet friendliness
				local bHas, guid = hasGSItem(50126);
				if(bHas and guid) then
					local item = ItemManager.GetItemByGUID(guid);
					if(item and item.guid > 0) then
						item:OnClick("left");
					end
				end
			end
		end);
		--ItemManager.DestroyItem(guid_50162, 1, function(msg)
			--log("+++++++ Destroy 50162_WishFollowPet2_Acquire return: +++++++\n")
			--commonlib.echo(msg);
			--if(msg.issuccess == true) then
				--ItemManager.PurchaseItem(50075, 1, function(msg) end, function(msg)
					--if(msg) then
						--log("+++++++Purchase 50075_Wish_FollowPet2_PlayWithLulu_Complete return: +++++++\n")
						--commonlib.echo(msg);
						--if(msg.issuccess == true) then
							--WishRandom_FollowPet_Lulu.RefreshStatus();
							--Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet2_PlayWithLulu_Finish.html");
						--end
					--end
				--end);
				--ItemManager.PurchaseItem(50076, 1, function(msg) end, function(msg)
					--if(msg) then
						--log("+++++++Purchase 50076_Wish_FollowPet2_PlayWithLulu_RewardFriendliness return: +++++++\n")
						--commonlib.echo(msg);
						--if(msg.issuccess == true) then
							---- use the item 50076 to increase pet friendliness
							--local bHas, guid = hasGSItem(50076);
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
function WishRandom_FollowPet_Lulu.RegisterHook1()
	-- hook into item obtain
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnObtainItemAfterGetItemsInBag") then
				WishRandom_FollowPet_Lulu.OnItemObtained(msg.gsid, msg.count);
			end
		end, 
		hookName = "WishRandom_FollowPet_Lulu_CatchLulu", appName = "Aries", wndName = "main"});
end
function WishRandom_FollowPet_Lulu.RegisterHook2()
	-- hook into lulu joy bean obtain
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnJoyBeanObtainFromLuluMushroom") then
				WishRandom_FollowPet_Lulu.OnJoyBeanObtainFromLuluMushroom(msg.count);
			end
		end, 
		hookName = "WishRandom_FollowPet_Lulu_PlayWithLulu", appName = "Aries", wndName = "main"});
end

-- unregister hook
function WishRandom_FollowPet_Lulu.UnregisterHook1()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "WishRandom_FollowPet_Lulu_CatchLulu", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end
-- unregister hook
function WishRandom_FollowPet_Lulu.UnregisterHook2()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "WishRandom_FollowPet_Lulu_PlayWithLulu", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end