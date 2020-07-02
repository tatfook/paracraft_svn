--[[
Title: 30011_WishLevel2
Author(s): WangTian
Date: 2009/7/29

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/30011_WishLevel2.lua
------------------------------------------------------------
]]

-- create class
local libName = "WishLevel2";
local WishLevel2 = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.WishLevel2", WishLevel2);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- WishLevel2.main
function WishLevel2.main()
end

-- refresh quest status
function WishLevel2.RefreshStatus()
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
	if(not hasGSItem(50016) and not hasGSItem(50017)) then
		ItemManager.PurchaseItem(50016, 1, function(msg) end, function(msg)
			if(msg) then
				log("+++++++Purchase 50016_WishLevel2_Acquire return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess == true) then
					Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/30011_WishLevel2_Acquire.html");
				end
			end
		end);
	elseif(hasGSItem(50016) and not hasGSItem(50017)) then
		QuestArea.AppendQuestStatus(
			"script/apps/Aries/NPCs/Dragon/30011_WishLevel2_status.html",
			"dragon", "", "去生命之泉打泉水", 50016);
		WishLevel2.RegisterHook();
	elseif(hasGSItem(50016) and hasGSItem(50017)) then
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/30011_WishLevel2_status.html");
		WishLevel2.UnregisterHook();
	end
end

-- 21005: MorningGlory
-- 17006: LifeSpringWater

-- item purchase hook
-- @param gsid: global store id of the purchased item
-- @param count: count of the purchased item
function WishLevel2.OnItemPurchase(gsid, count)
	if(gsid == 17006 and count == 3) then
        -- finish the quest
        -- exid 85: DragonQuestGrow_Level2
        ItemManager.ExtendedCost(85, nil, nil, function(msg)end, function(msg)
		    log("+++++++ExtendedCost 85: DragonQuestGrow_Level2 return: +++++++\n")
		    commonlib.echo(msg);
			WishLevel2.RefreshStatus();
			Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/30011_WishLevel2_Finish.html");
			--50018_WishLevel2_RewardFriendliness
			if(msg.issuccess == true) then
				-- use the item 50018 to increase pet friendliness
                local bHas, guid = hasGSItem(50018);
                if(bHas and guid) then
                    local item = ItemManager.GetItemByGUID(guid);
                    if(item and item.guid > 0) then
                        item:OnClick("left");
                    end
                end
				--WishLevel0.RefreshStatus();
			end
        end);
	end
end

-- register hook into pet name change
function WishLevel2.RegisterHook()
	-- hook into pet name change
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnObtainItemAfterGetItemsInBag") then
				WishLevel2.OnItemPurchase(msg.gsid, msg.count);
			end
		end, 
		hookName = "WishLevel2_PurchaseSpringWater", appName = "Aries", wndName = "main"});
end

-- unregister hook
function WishLevel2.UnregisterHook()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "WishLevel2_PurchaseSpringWater", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end