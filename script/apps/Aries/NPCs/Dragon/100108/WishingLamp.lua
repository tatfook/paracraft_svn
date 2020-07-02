--[[
Title: 30011_WishForWishingLamp
Author(s): WangTian
Date: 2009/7/29

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/100108/WishingLamp.lua
------------------------------------------------------------
]]

-- create class
local libName = "WishForWishingLamp";
local WishForWishingLamp = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.WishForWishingLamp", WishForWishingLamp);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- WishForWishingLamp.main
function WishForWishingLamp.main()
	WishForWishingLamp.RefreshStatus()
end

function WishForWishingLamp.On_Timer()
end

function WishForWishingLamp.CanAcquireQuest()
	-- check if dragon fetched from sophie
	if(not MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie()) then
		return false;
	end
	if(not hasGSItem(50243) and not hasGSItem(50244)) then
		return true;
	end
	return false
end

function WishForWishingLamp.AcquireQuest()
	-- check if dragon fetched from sophie
	if(not MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie()) then
		_guihelper.MessageBox("快去找苏菲领回你的抱抱龙吧！");
		return;
	end
	
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
    
	if(not hasGSItem(50243) and not hasGSItem(50244)) then
		ItemManager.PurchaseItem(50243, 1, function(msg) end, function(msg)
			if(msg) then
				log("+++++++Purchase 50243_WishingLamp_Acquire return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess == true) then
					Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/100108/WishingLamp_Acquire.html");
				end
			end
		end);
	end
end

-- 50243_WishingLamp_Acquire
-- 50244_WishingLamp_Complete
-- 50245_WishingLamp_RewardFriendliness

-- refresh quest status
function WishForWishingLamp.RefreshStatus()
	---- check if dragon fetched from sophie
	--if(not MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie()) then
		--_guihelper.MessageBox("快去找苏菲领回你的抱抱龙吧！");
		--return;
	--end
	
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
    
	if(hasGSItem(50243) and not hasGSItem(50244)) then
		QuestArea.AppendQuestStatus(
			"script/apps/Aries/NPCs/Dragon/100108/WishingLamp_status.html",
			"dragon", "", "放一盏许愿灯", 50243);
		WishForWishingLamp.RegisterHook();
	elseif(hasGSItem(50243) and hasGSItem(50244)) then
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/100108/WishingLamp_status.html");
		WishForWishingLamp.UnregisterHook();
	end
end

-- WishForWishingLamp.OnFlyWishingLamp
function WishForWishingLamp.OnFlyWishingLamp()
    -- finish the quest
    -- exid 188: DragonQuest_30095_WishingLamp
    ItemManager.ExtendedCost(188, nil, nil, function(msg) end, function(msg)
	    log("+++++++ExtendedCost 188: DragonQuest_30095_WishingLamp return: +++++++\n")
	    commonlib.echo(msg);
	    WishForWishingLamp.RefreshStatus();
		MyCompany.Aries.Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/100108/WishingLamp_Finish.html");
		-- 50245_WishingLamp_RewardFriendliness
		if(msg.issuccess == true) then
			-- use the item 50245 to increase pet friendliness
            local bHas, guid = hasGSItem(50245);
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
function WishForWishingLamp.RegisterHook()
	-- hook into pet name change
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnFlyWishingLamp") then
				WishForWishingLamp.OnFlyWishingLamp();
			end
		end, 
		hookName = "WishForWishingLamp_OnFlyWishingLamp", appName = "Aries", wndName = "main"});
end

-- unregister hook
function WishForWishingLamp.UnregisterHook()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "WishForWishingLamp_OnFlyWishingLamp", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end