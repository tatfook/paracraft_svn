--[[
Title: 30011_OddEggGift
Author(s): WangTian
Date: 2009/7/29

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/100326/OddEggGift.lua
------------------------------------------------------------
]]

-- create class
local libName = "OddEggGift";
local OddEggGift = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.OddEggGift", OddEggGift);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- OddEggGift.main
function OddEggGift.main()
	OddEggGift.RefreshStatus()
end

function OddEggGift.On_Timer()
end

function OddEggGift.CanAcquireQuest()
	-- check if dragon fetched from sophie
	if(not MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie()) then
		return false;
	end
	if(not hasGSItem(50297) and not hasGSItem(50298)) then
		return true;
	end
	return false
end

function OddEggGift.AcquireQuest()
	-- check if dragon fetched from sophie
	if(not MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie()) then
		_guihelper.MessageBox("快去找苏菲领回你的抱抱龙吧！");
		return;
	end
	
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
    
	if(not hasGSItem(50297) and not hasGSItem(50298)) then
		ItemManager.PurchaseItem(50297, 1, function(msg) end, function(msg)
			if(msg) then
				log("+++++++Purchase 50297_OddEggWish_Acquire return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess == true) then
					Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/100326/OddEggGift_Acquire.html");
				end
			end
		end);
	end
end

-- 50297_OddEggWish_Acquire
-- 50298_OddEggWish_Complete
-- 50299_OddEggWish_RewardFriendliness

-- refresh quest status
function OddEggGift.RefreshStatus()
	---- check if dragon fetched from sophie
	--if(not MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie()) then
		--_guihelper.MessageBox("快去找苏菲领回你的抱抱龙吧！");
		--return;
	--end
	
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
    
	if(hasGSItem(50297) and not hasGSItem(50298)) then
		QuestArea.AppendQuestStatus(
			"script/apps/Aries/NPCs/Dragon/100326/OddEggGift_status.html",
			"dragon", "", "抱抱龙要怪怪蛋的礼物", 50297);
		OddEggGift.RegisterHook();
	elseif(hasGSItem(50297) and hasGSItem(50298)) then
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/100326/OddEggGift_status.html");
		OddEggGift.UnregisterHook();
	end
end

-- OddEggGift.OnOddEggApplyGift
function OddEggGift.OnOddEggApplyGift()
    -- finish the quest
    -- exid 387: DragonQuest_OddEggWish
    ItemManager.ExtendedCost(387, nil, nil, function(msg)end, function(msg)
	    log("+++++++ExtendedCost 387: DragonQuest_OddEggWish return: +++++++\n")
	    commonlib.echo(msg);
	    OddEggGift.RefreshStatus();
		MyCompany.Aries.Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/100326/OddEggGift_Finish.html");
		-- 50299_OddEggWish_RewardFriendliness
		if(msg.issuccess == true) then
			-- use the item 50299 to increase pet friendliness
            local bHas, guid = hasGSItem(50299);
            if(bHas and guid) then
                local item = ItemManager.GetItemByGUID(guid);
                if(item and item.guid > 0) then
                    item:OnClick("left");
                end
            end
		end
    end);
end

-- register hook into pet name change
function OddEggGift.RegisterHook()
	-- hook into pet name change
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnOddEggApplyGift") then
				OddEggGift.OnOddEggApplyGift();
			end
		end, 
		hookName = "OddEggGift_OnObtain", appName = "Aries", wndName = "main"});
end

-- unregister hook
function OddEggGift.UnregisterHook()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "OddEggGift_OnObtain", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end