--[[
Title: 30011_Wish_FollowPet_Beehive
Author(s): WangTian
Date: 2009/7/29

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet_Beehive.lua
------------------------------------------------------------
]]

-- create class
local libName = "WishRandom_FollowPet_Beehive";
local WishRandom_FollowPet_Beehive = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.WishRandom_FollowPet_Beehive", WishRandom_FollowPet_Beehive);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- WishRandom_FollowPet_Beehive.main
function WishRandom_FollowPet_Beehive.main()
end

function WishRandom_FollowPet_Beehive.On_Timer()
end

-- 50089_Wish_FollowPet7_ShakeBeehive_Acquire
-- 50090_Wish_FollowPet7_ShakeBeehive_Complete
-- 50091_Wish_FollowPet7_ShakeBeehive_RewardFriendliness

-- 50167_WishFollowPet7_Acquire

-- refresh quest status
function WishRandom_FollowPet_Beehive.RefreshStatus()
	-- check if dragon fetched from sophie
	if(not MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie()) then
		return;
	end
	
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
	
	-- 50167_WishFollowPet7_Acquire
	if(hasGSItem(50167)) then
		QuestArea.AppendQuestStatus(
			"script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet7_ShakeBeehive_status.html",
			"dragon", "", "摇摇老蜂窝",  50167);
		WishRandom_FollowPet_Beehive.RegisterHook();
	elseif(not hasGSItem(50167)) then
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet7_ShakeBeehive_status.html");
		WishRandom_FollowPet_Beehive.UnregisterHook();
	end
end

function WishRandom_FollowPet_Beehive.OnShakeBeehive()
	local bHas_50167, guid_50167 = hasGSItem(50167);
	if(bHas_50167) then
		-- complete the quest by extended cost
		ItemManager.ExtendedCost(69, nil, nil, function(msg)end, function(msg)
			log("+++++++ WishFollowPetSeries ExtendedCost 69: DragonQuestRandom_FollowPet7 return: +++++++\n")
			commonlib.echo(msg);
			if(msg.issuccess == true) then
				-- notify the quest finished
				WishRandom_FollowPet_Beehive.RefreshStatus();
				Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet7_ShakeBeehive_Finish.html");
				-- use the reward item to increase pet friendliness
				local bHas, guid = hasGSItem(50123);
				if(bHas and guid) then
					local item = ItemManager.GetItemByGUID(guid);
					if(item and item.guid > 0) then
						item:OnClick("left");
					end
				end
			end
		end);
		--ItemManager.DestroyItem(guid_50167, 1, function(msg)
			--log("+++++++ Destroy 50167_WishFollowPet7_Acquire return: +++++++\n")
			--commonlib.echo(msg);
			--if(msg.issuccess == true) then
				--ItemManager.PurchaseItem(50090, 1, function(msg) end, function(msg)
					--if(msg) then
						--log("+++++++Purchase 50090_Wish_FollowPet7_ShakeBeehive_Complete return: +++++++\n")
						--commonlib.echo(msg);
						--if(msg.issuccess == true) then
							--WishRandom_FollowPet_Beehive.RefreshStatus();
							--Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet7_ShakeBeehive_Finish.html");
						--end
					--end
				--end);
				--ItemManager.PurchaseItem(50091, 1, function(msg) end, function(msg)
					--if(msg) then
						--log("+++++++Purchase 50091_Wish_FollowPet7_ShakeBeehive_RewardFriendliness return: +++++++\n")
						--commonlib.echo(msg);
						--if(msg.issuccess == true) then
							---- use the item 50091 to increase pet friendliness
							--local bHas, guid = hasGSItem(50091);
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
function WishRandom_FollowPet_Beehive.RegisterHook()
	-- hook into shake beehive
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnShakeBeehive") then
				WishRandom_FollowPet_Beehive.OnShakeBeehive();
			end
		end, 
		hookName = "WishRandom_FollowPet_Beehive_ShakeBeehive", appName = "Aries", wndName = "main"});
end

-- unregister hook
function WishRandom_FollowPet_Beehive.UnregisterHook()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "WishRandom_FollowPet_Beehive_ShakeBeehive", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end