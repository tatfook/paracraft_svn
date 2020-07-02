--[[
Title: 30011_KnitChirstmasSock
Author(s): WangTian
Date: 2009/7/29

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/091218/KnitChirstmasSock.lua
------------------------------------------------------------
]]

-- create class
local libName = "KnitChirstmasSock";
local KnitChirstmasSock = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.KnitChirstmasSock", KnitChirstmasSock);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- KnitChirstmasSock.main
function KnitChirstmasSock.main()
	KnitChirstmasSock.RefreshStatus();
end

function KnitChirstmasSock.On_Timer()
end

function KnitChirstmasSock.CanAcquireQuest()
	if(not hasGSItem(50205) and not hasGSItem(50206)) then
		return true;
	end
	return false
end

function KnitChirstmasSock.AcquireQuest()
	-- check if dragon fetched from sophie
	if(not MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie()) then
		return false;
	end
	-- check if dragon fetched from sophie
	if(not MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie()) then
		_guihelper.MessageBox("快去找苏菲领回你的抱抱龙吧！");
		return;
	end
	
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
    
	if(not hasGSItem(50205) and not hasGSItem(50206)) then
		ItemManager.PurchaseItem(50205, 1, function(msg) end, function(msg)
			if(msg) then
				log("+++++++Purchase 50205_KnitChirstmasSock_Acquire return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess == true) then
					Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/091218/KnitChirstmasSock_Acquire.html");
				end
			end
		end);
	end
end

-- 50205_KnitChirstmasSock_Acquire
-- 50206_KnitChirstmasSock_Complete
-- 50207_KnitChirstmasSock_RewardFriendliness

-- refresh quest status
function KnitChirstmasSock.RefreshStatus()
	---- check if dragon fetched from sophie
	--if(not MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie()) then
		--_guihelper.MessageBox("快去找苏菲领回你的抱抱龙吧！");
		--return;
	--end
	
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
    
	if(hasGSItem(50205) and not hasGSItem(50206)) then
		QuestArea.AppendQuestStatus(
			"script/apps/Aries/NPCs/Dragon/091218/KnitChirstmasSock_status.html",
			"dragon", "", "编织漂亮的圣诞袜", 50205);
		KnitChirstmasSock.RegisterHook();
	elseif(hasGSItem(50205) and hasGSItem(50206)) then
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/091218/KnitChirstmasSock_status.html");
		KnitChirstmasSock.UnregisterHook();
	end
end

-- KnitChirstmasSock.OnObtainSock
function KnitChirstmasSock.OnObtainSock()
    -- finish the quest
    -- exid 148: DragonQuest_KnitChirstmasSock 
    ItemManager.ExtendedCost(148, nil, nil, function(msg)end, function(msg)
	    log("+++++++ExtendedCost 148: DragonQuest_KnitChirstmasSock return: +++++++\n")
	    commonlib.echo(msg);
	    KnitChirstmasSock.RefreshStatus();
		MyCompany.Aries.Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/091218/KnitChirstmasSock_Finish.html");
		-- 50207_KnitChirstmasSock_RewardFriendliness
		if(msg.issuccess == true) then
			-- use the item 50207 to increase pet friendliness
            local bHas, guid = hasGSItem(50207);
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
function KnitChirstmasSock.RegisterHook()
	-- hook into pet name change
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnObtainItemAfterGetItemsInBag") then
				if(msg.gsid == 30061 or msg.gsid == 30062 or msg.gsid == 30063 or msg.gsid == 30064) then
					KnitChirstmasSock.OnObtainSock();
				end
			end
		end, 
		hookName = "KnitChirstmasSock_OnObtain", appName = "Aries", wndName = "main"});
end

-- unregister hook
function KnitChirstmasSock.UnregisterHook()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "KnitChirstmasSock_OnObtain", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end