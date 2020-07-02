--[[
Title: 30011_Wish_FollowPet_FleaChick
Author(s): WangTian
Date: 2009/7/29

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet_FleaChick.lua
------------------------------------------------------------
]]

-- create class
local libName = "WishRandom_FollowPet_FleaChick";
local WishRandom_FollowPet_FleaChick = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.WishRandom_FollowPet_FleaChick", WishRandom_FollowPet_FleaChick);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- WishRandom_FollowPet_FleaChick.main
function WishRandom_FollowPet_FleaChick.main()
end

function WishRandom_FollowPet_FleaChick.On_Timer()
end

-- 50168_WishFollowPet8_Acquire
-- 50169_WishFollowPet9_Acquire

-- 10107_FollowPetXJBB

-- refresh quest status
function WishRandom_FollowPet_FleaChick.RefreshStatus()
	-- check if dragon fetched from sophie
	if(not MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie()) then
		return;
	end
	
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
	
	-- 50168_WishFollowPet8_Acquire
	if(hasGSItem(50168)) then
		if(hasGSItem(10107)) then
			local bHas, guid = hasGSItem(50168);
			-- NOTE: discard the destroy the acquire and refresh afterwards
			if(bHas and guid) then
				ItemManager.DestroyItem(guid, 1, function(msg) end, function(msg)
					log("+++++++ Destroy 50168_WishFollowPet8_Acquire when happened to have fleachick already return: +++++++\n")
					commonlib.echo(msg);
					WishRandom_FollowPet_FleaChick.RefreshStatus();
				end);
			end
		else
			QuestArea.AppendQuestStatus(
				"script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet8_CatchFleaChick_status.html",
				"dragon", "", "带一只跳蚤鸡回家",  50168);
		end
		WishRandom_FollowPet_FleaChick.RegisterHook1();
	elseif(not hasGSItem(50168)) then
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet8_CatchFleaChick_status.html");
		WishRandom_FollowPet_FleaChick.UnregisterHook1();
	end
	
	-- 50169_WishFollowPet9_Acquire
	if(hasGSItem(50169)) then
		QuestArea.AppendQuestStatus(
			"script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet9_PlayWithFleaChick_status.html",
			"dragon", "", "给跳蚤鸡喂3条小虫",  50169);
		WishRandom_FollowPet_FleaChick.RegisterHook2();
	elseif(not hasGSItem(50169)) then
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet9_PlayWithFleaChick_status.html");
		WishRandom_FollowPet_FleaChick.UnregisterHook2();
	end
end

-- on item obtained feed
-- @param gsid: global store id of the item
-- @param count: item count
function WishRandom_FollowPet_FleaChick.OnItemObtained(gsid, count)
	-- 10107_FollowPetXJBB
	if(gsid == 10107) then
		local bHas_50168, guid_50168 = hasGSItem(50168);
		if(bHas_50168) then
			-- complete the quest by extended cost
			ItemManager.ExtendedCost(70, nil, nil, function(msg)end, function(msg)
				log("+++++++ WishFollowPetSeries ExtendedCost 70: DragonQuestRandom_FollowPet8 return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess == true) then
					-- notify the quest finished
					WishRandom_FollowPet_FleaChick.RefreshStatus();
					Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet8_CatchFleaChick_Finish.html");
					-- use the reward item to increase pet friendliness
					local bHas, guid = hasGSItem(50125);
					if(bHas and guid) then
						local item = ItemManager.GetItemByGUID(guid);
						if(item and item.guid > 0) then
							item:OnClick("left");
						end
					end
				end
			end);
		end
	end
end

function WishRandom_FollowPet_FleaChick.OnRewardObtainFromFleaChick()
	local bHas_50169, guid_50169 = hasGSItem(50169);
	if(bHas_50169) then
		-- complete the quest by extended cost
		ItemManager.ExtendedCost(71, nil, nil, function(msg)end, function(msg)
			log("+++++++ WishFollowPetSeries ExtendedCost 71: DragonQuestRandom_FollowPet9 return: +++++++\n")
			commonlib.echo(msg);
			if(msg.issuccess == true) then
				-- notify the quest finished
				WishRandom_FollowPet_FleaChick.RefreshStatus();
				Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet9_PlayWithFleaChick_Finish.html");
				-- use the reward item to increase pet friendliness
				local bHas, guid = hasGSItem(50125);
				if(bHas and guid) then
					local item = ItemManager.GetItemByGUID(guid);
					if(item and item.guid > 0) then
						item:OnClick("left");
					end
				end
			end
		end);
	end
end

-- register hook into pet name change
function WishRandom_FollowPet_FleaChick.RegisterHook1()
	-- hook into item obtain
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnObtainItemAfterGetItemsInBag") then
				WishRandom_FollowPet_FleaChick.OnItemObtained(msg.gsid, msg.count);
			end
		end, 
		hookName = "WishRandom_FollowPet_FleaChick_CatchFleaChick", appName = "Aries", wndName = "main"});
end
function WishRandom_FollowPet_FleaChick.RegisterHook2()
	-- hook into FleaChick joy bean obtain
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnJoyBeanObtainFromFleaChick") then
				WishRandom_FollowPet_FleaChick.OnRewardObtainFromFleaChick();
			elseif(msg.aries_type == "OnEggObtainFromFleaChick") then
				WishRandom_FollowPet_FleaChick.OnRewardObtainFromFleaChick();
			end
		end, 
		hookName = "WishRandom_FollowPet_FleaChick_PlayWithFleaChick", appName = "Aries", wndName = "main"});
end

-- unregister hook
function WishRandom_FollowPet_FleaChick.UnregisterHook1()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "WishRandom_FollowPet_FleaChick_CatchFleaChick", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end
-- unregister hook
function WishRandom_FollowPet_FleaChick.UnregisterHook2()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "WishRandom_FollowPet_FleaChick_PlayWithFleaChick", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end