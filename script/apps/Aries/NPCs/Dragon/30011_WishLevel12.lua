--[[
Title: 30011_WishLevel12
Author(s): LiXizhi, based on WangTian's 30011_WishLevel12
Date: 2010/1/2
use the lib:
------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/30011_WishLevel12.lua
------------------------------------------------------------
]]

-- create class
local WishLevel12 = commonlib.gettable("MyCompany.Aries.Quest.NPCs.WishLevel12");

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- WishLevel12.main
function WishLevel12.main()
end

-- 50218_WishLevel12_Acquire
-- 50219_WishLevel12_Complete
-- 50220_WishLevel12_RewardFriendliness

-- refresh quest status
function WishLevel12.RefreshStatus()
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
	if(not hasGSItem(50218) and not hasGSItem(50219)) then
		ItemManager.PurchaseItem(50218, 1, function(msg) end, function(msg)
			if(msg) then
				log("+++++++Purchase 50218_WishLevel12_Acquire return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess == true) then
					Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/30011_WishLevel12_Acquire.html");
				end
			end
		end);
	elseif(hasGSItem(50218) and not hasGSItem(50219)) then
		QuestArea.AppendQuestStatus(
			"script/apps/Aries/NPCs/Dragon/30011_WishLevel12_status.html",
			"dragon", "", "抱抱龙想学新的绝活", 50218);
		WishLevel12.RegisterHook();
	elseif(hasGSItem(50218) and hasGSItem(50219)) then
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/30011_WishLevel12_status.html");
		WishLevel12.UnregisterHook();
	end
end

-- item purchase hook
function WishLevel12.OnLearnRollingAnim()
    -- finish the quest
    -- exid 189: DragonQuestGrow_Level12
    ItemManager.ExtendedCost(189, nil, nil, function(msg)end, function(msg)
	    log("+++++++ExtendedCost 189: DragonQuestGrow_Level12 return: +++++++\n")
	    commonlib.echo(msg);
		WishLevel12.RefreshStatus();
		Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/30011_WishLevel12_Finish.html");
		-- 50220_WishLevel12_RewardFriendliness
		if(msg.issuccess == true) then
			-- use the item 50220 to increase pet friendliness
            local bHas, guid = hasGSItem(50220);
            if(bHas and guid) then
                local item = ItemManager.GetItemByGUID(guid);
                if(item and item.guid > 0) then
                    item:OnClick("left");
                end
            end
		end
    end);
end

-- register hook into 
function WishLevel12.RegisterHook()
	---- hook into pet name change
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnLearnRollingAnim") then
				WishLevel12.OnLearnRollingAnim();
			end
		end, 
		hookName = "WishLevel12_PurchaseQuestComplete", appName = "Aries", wndName = "main"});
end

-- unregister hook
function WishLevel12.UnregisterHook()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "WishLevel12_PurchaseQuestComplete", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end