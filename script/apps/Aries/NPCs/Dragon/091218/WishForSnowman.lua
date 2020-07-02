--[[
Title: 30011_WishForSnowman
Author(s): WangTian
Date: 2009/7/29

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/091218/WishForSnowman.lua
------------------------------------------------------------
]]

-- create class
local libName = "WishForSnowman";
local WishForSnowman = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.WishForSnowman", WishForSnowman);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- WishForSnowman.main
function WishForSnowman.main()
	WishForSnowman.RefreshStatus()
end

function WishForSnowman.On_Timer()
end

function WishForSnowman.CanAcquireQuest()
	-- check if dragon fetched from sophie
	if(not MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie()) then
		return false;
	end
	if(not hasGSItem(50196) and not hasGSItem(50197)) then
		return true;
	end
	return false
end

function WishForSnowman.AcquireQuest()
	-- check if dragon fetched from sophie
	if(not MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie()) then
		_guihelper.MessageBox("快去找苏菲领回你的抱抱龙吧！");
		return;
	end
	
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
    
	if(not hasGSItem(50196) and not hasGSItem(50197)) then
		ItemManager.PurchaseItem(50196, 1, function(msg) end, function(msg)
			if(msg) then
				log("+++++++Purchase 50196_WishForSnowman_Acquire return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess == true) then
					Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/091218/WishForSnowman_Acquire.html");
				end
			end
		end);
	end
end

-- 50196_WishForSnowman_Acquire 
-- 50197_WishForSnowman_Complete
-- 50198_WishForSnowman_RewardFriendliness

-- refresh quest status
function WishForSnowman.RefreshStatus()
	---- check if dragon fetched from sophie
	--if(not MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie()) then
		--_guihelper.MessageBox("快去找苏菲领回你的抱抱龙吧！");
		--return;
	--end
	
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
    
	if(hasGSItem(50196) and not hasGSItem(50197)) then
		QuestArea.AppendQuestStatus(
			"script/apps/Aries/NPCs/Dragon/091218/WishForSnowman_status.html",
			"dragon", "", "抱抱龙要小雪人", 50196);
		WishForSnowman.RegisterHook();
	elseif(hasGSItem(50196) and hasGSItem(50197)) then
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/091218/WishForSnowman_status.html");
		WishForSnowman.UnregisterHook();
	end
end

-- WishForSnowman.OnObtainSnowman
function WishForSnowman.OnObtainSnowman()
    -- finish the quest
    -- exid 145: DragonQuest_WishForSnowman
    ItemManager.ExtendedCost(145, nil, nil, function(msg)end, function(msg)
	    log("+++++++ExtendedCost 145: DragonQuest_WishForSnowman return: +++++++\n")
	    commonlib.echo(msg);
	    WishForSnowman.RefreshStatus();
		MyCompany.Aries.Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/091218/WishForSnowman_Finish.html");
		-- 50198_WishForSnowman_RewardFriendliness
		if(msg.issuccess == true) then
			-- use the item 50198 to increase pet friendliness
            local bHas, guid = hasGSItem(50198);
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
function WishForSnowman.RegisterHook()
	-- hook into pet name change
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnObtainItemAfterGetItemsInBag") then
				if(msg.gsid == 30069 or msg.gsid == 30070 or msg.gsid == 30071 or msg.gsid == 30072) then
					WishForSnowman.OnObtainSnowman();
				end
			end
		end, 
		hookName = "WishForSnowman_OnObtain", appName = "Aries", wndName = "main"});
end

-- unregister hook
function WishForSnowman.UnregisterHook()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "WishForSnowman_OnObtain", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end