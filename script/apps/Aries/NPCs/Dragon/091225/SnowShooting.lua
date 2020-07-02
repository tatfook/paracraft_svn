--[[
Title: 30011_SnowShooting
Author(s): WangTian
Date: 2009/7/29

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/091225/SnowShooting.lua
------------------------------------------------------------
]]

-- create class
local libName = "SnowShooting";
local SnowShooting = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.SnowShooting", SnowShooting);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- SnowShooting.main
function SnowShooting.main()
	SnowShooting.RefreshStatus()
end

function SnowShooting.On_Timer()
end

function SnowShooting.CanAcquireQuest()
	-- check if dragon fetched from sophie
	if(not MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie()) then
		return false;
	end
	if(not hasGSItem(50209) and not hasGSItem(50210)) then
		return true;
	end
	return false
end

function SnowShooting.AcquireQuest()
	-- check if dragon fetched from sophie
	if(not MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie()) then
		_guihelper.MessageBox("快去找苏菲领回你的抱抱龙吧！");
		return;
	end
	
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
    
	if(not hasGSItem(50209) and not hasGSItem(50210)) then
		ItemManager.PurchaseItem(50209, 1, function(msg) end, function(msg)
			if(msg) then
				log("+++++++Purchase 50209_SnowShooting_Acquire return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess == true) then
					Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/091225/SnowShooting_Acquire.html");
				end
			end
		end);
	end
end

-- 50209_SnowShooting_Acquire
-- 50210_SnowShooting_Complete
-- 50211_SnowShooting_RewardFriendliness

-- refresh quest status
function SnowShooting.RefreshStatus()
	---- check if dragon fetched from sophie
	--if(not MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie()) then
		--_guihelper.MessageBox("快去找苏菲领回你的抱抱龙吧！");
		--return;
	--end
	
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
    
	if(hasGSItem(50209) and not hasGSItem(50210)) then
		QuestArea.AppendQuestStatus(
			"script/apps/Aries/NPCs/Dragon/091225/SnowShooting_status.html",
			"dragon", "", "赢取百发百中银杯", 50209);
		SnowShooting.RegisterHook();
	elseif(hasGSItem(50209) and hasGSItem(50210)) then
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/091225/SnowShooting_status.html");
		SnowShooting.UnregisterHook();
	end
end

-- SnowShooting.OnObtainSnowShootingTrophy
function SnowShooting.OnObtainSnowShootingTrophy()
    -- finish the quest
    -- exid 154: DragonQuest_SnowShooting
    ItemManager.ExtendedCost(154, nil, nil, function(msg)end, function(msg)
	    log("+++++++ExtendedCost 154: DragonQuest_SnowShooting return: +++++++\n")
	    commonlib.echo(msg);
	    SnowShooting.RefreshStatus();
		MyCompany.Aries.Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/091225/SnowShooting_Finish.html");
		-- 50211_SnowShooting_RewardFriendliness
		if(msg.issuccess == true) then
			-- use the item 50211 to increase pet friendliness
            local bHas, guid = hasGSItem(50211);
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
function SnowShooting.RegisterHook()
	-- hook into pet name change
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnObtainItemAfterGetItemsInBag") then
				if(msg.gsid == 30073) then
					-- 30073_SnowShooterSilverCup
					SnowShooting.OnObtainSnowShootingTrophy();
				end
			end
		end, 
		hookName = "SnowShooting_OnObtain", appName = "Aries", wndName = "main"});
end

-- unregister hook
function SnowShooting.UnregisterHook()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "SnowShooting_OnObtain", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end