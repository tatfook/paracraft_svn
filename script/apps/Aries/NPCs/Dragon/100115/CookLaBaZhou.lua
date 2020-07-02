--[[
Title: 30011_CookLaBaZhou
Author(s): WangTian
Date: 2009/7/29

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/100115/CookLaBaZhou.lua
------------------------------------------------------------
]]

-- create class
local libName = "CookLaBaZhou";
local CookLaBaZhou = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.CookLaBaZhou", CookLaBaZhou);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- CookLaBaZhou.main
function CookLaBaZhou.main()
	CookLaBaZhou.RefreshStatus()
end

function CookLaBaZhou.On_Timer()
end

function CookLaBaZhou.CanAcquireQuest()
	-- check if dragon fetched from sophie
	if(not MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie()) then
		return false;
	end
	if(not hasGSItem(50249) and not hasGSItem(50250)) then
		return true;
	end
	return false
end

function CookLaBaZhou.AcquireQuest()
	-- check if dragon fetched from sophie
	if(not MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie()) then
		_guihelper.MessageBox("快去找苏菲领回你的抱抱龙吧！");
		return;
	end
	
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
    
	if(not hasGSItem(50249) and not hasGSItem(50250)) then
		ItemManager.PurchaseItem(50249, 1, function(msg) end, function(msg)
			if(msg) then
				log("+++++++Purchase 50249_CookLaBaZhou_Acquire return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess == true) then
					Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/100115/CookLaBaZhou_Acquire.html");
				end
			end
		end);
	end
end

-- 17050_LaBaZhou

-- 50249_CookLaBaZhou_Acquire
-- 50250_CookLaBaZhou_Complete
-- 50251_CookLaBaZhou_RewardFriendliness

-- refresh quest status
function CookLaBaZhou.RefreshStatus()
	---- check if dragon fetched from sophie
	--if(not MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie()) then
		--_guihelper.MessageBox("快去找苏菲领回你的抱抱龙吧！");
		--return;
	--end
	
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
    
	if(hasGSItem(50249) and not hasGSItem(50250)) then
		QuestArea.AppendQuestStatus(
			"script/apps/Aries/NPCs/Dragon/100115/CookLaBaZhou_status.html",
			"dragon", "", "找呼噜大叔做腊八粥", 50249);
		CookLaBaZhou.RegisterHook();
	elseif(hasGSItem(50249) and hasGSItem(50250)) then
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/100115/CookLaBaZhou_status.html");
		CookLaBaZhou.UnregisterHook();
	end
end

-- CookLaBaZhou.OnObtainIceHouse
function CookLaBaZhou.OnObtainIceHouse()
    -- finish the quest
    -- exid 201: DragonQuest_CookLaBaZhou
    ItemManager.ExtendedCost(201, nil, nil, function(msg)end, function(msg)
	    log("+++++++ExtendedCost 201: DragonQuest_CookLaBaZhou return: +++++++\n")
	    commonlib.echo(msg);
	    CookLaBaZhou.RefreshStatus();
		MyCompany.Aries.Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/100115/CookLaBaZhou_Finish.html");
		-- 50251_CookLaBaZhou_RewardFriendliness
		if(msg.issuccess == true) then
			-- use the item 50251 to increase pet friendliness
            local bHas, guid = hasGSItem(50251);
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
function CookLaBaZhou.RegisterHook()
	-- hook into pet name change
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnObtainItemAfterGetItemsInBag") then
				if(msg.gsid == 17050) then
					CookLaBaZhou.OnObtainIceHouse();
				end
			end
		end, 
		hookName = "CookLaBaZhou_OnObtain", appName = "Aries", wndName = "main"});
end

-- unregister hook
function CookLaBaZhou.UnregisterHook()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "CookLaBaZhou_OnObtain", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end