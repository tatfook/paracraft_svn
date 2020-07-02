--[[
Title: 30011_TakeElkHome
Author(s): WangTian
Date: 2009/7/29

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/091218/TakeElkHome.lua
------------------------------------------------------------
]]

-- create class
local libName = "TakeElkHome";
local TakeElkHome = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.TakeElkHome", TakeElkHome);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- TakeElkHome.main
function TakeElkHome.main()
	TakeElkHome.RefreshStatus()
end

function TakeElkHome.On_Timer()
end

function TakeElkHome.CanAcquireQuest()
	-- check if dragon fetched from sophie
	if(not MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie()) then
		return false;
	end
    -- 10111_FollowPet_Elk
	if(not hasGSItem(10111) and not hasGSItem(50199) and not hasGSItem(50200)) then
		return true;
	end
	return false
end

function TakeElkHome.AcquireQuest()
	---- check if dragon fetched from sophie
	--if(not MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie()) then
		--_guihelper.MessageBox("快去找苏菲领回你的抱抱龙吧！");
		--return;
	--end
	
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
    
    -- 10111_FollowPet_Elk
	if(not hasGSItem(10111) and not hasGSItem(50199) and not hasGSItem(50200)) then
		ItemManager.PurchaseItem(50199, 1, function(msg) end, function(msg)
			if(msg) then
				log("+++++++Purchase 50199_TakeElkHome_Acquire return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess == true) then
					Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/091218/TakeElkHome_Acquire.html");
				end
			end
		end);
	end
end

-- 50199_TakeElkHome_Acquire 
-- 50200_TakeElkHome_Complete
-- 50201_TakeElkHome_RewardFriendliness


-- refresh quest status
function TakeElkHome.RefreshStatus()
	---- check if dragon fetched from sophie
	--if(not MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie()) then
		--_guihelper.MessageBox("快去找苏菲领回你的抱抱龙吧！");
		--return;
	--end
	
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
    
	if(hasGSItem(50199) and not hasGSItem(50200)) then
		QuestArea.AppendQuestStatus(
			"script/apps/Aries/NPCs/Dragon/091218/TakeElkHome_status.html",
			"dragon", "", "带麋鹿回家", 50199);
		TakeElkHome.RegisterHook();
	elseif(hasGSItem(50199) and hasGSItem(50200)) then
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/091218/TakeElkHome_status.html");
		TakeElkHome.UnregisterHook();
	end
end

-- TakeElkHome.OnObtainElk
function TakeElkHome.OnObtainElk()
    -- finish the quest
    -- exid 146: DragonQuest_TakeElkHome 
    ItemManager.ExtendedCost(146, nil, nil, function(msg)end, function(msg)
	    log("+++++++ExtendedCost 146: DragonQuest_TakeElkHome return: +++++++\n")
	    commonlib.echo(msg);
	    TakeElkHome.RefreshStatus();
		MyCompany.Aries.Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/091218/TakeElkHome_Finish.html");
		-- 50201_TakeElkHome_RewardFriendliness
		if(msg.issuccess == true) then
			-- use the item 50201 to increase pet friendliness
            local bHas, guid = hasGSItem(50201);
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
function TakeElkHome.RegisterHook()
	-- hook into pet name change
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnObtainItemAfterGetItemsInBag") then
				-- 10111_FollowPet_Elk
				if(msg.gsid == 10111) then
					TakeElkHome.OnObtainElk();
				end
			end
		end, 
		hookName = "TakeElkHome_OnObtain", appName = "Aries", wndName = "main"});
end

-- unregister hook
function TakeElkHome.UnregisterHook()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "TakeElkHome_OnObtain", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end