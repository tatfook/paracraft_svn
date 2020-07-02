--[[
Title: 30011_BuildIceHouse
Author(s): WangTian
Date: 2009/7/29

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/091225/BuildIceHouse.lua
------------------------------------------------------------
]]

-- create class
local libName = "BuildIceHouse";
local BuildIceHouse = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.BuildIceHouse", BuildIceHouse);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- BuildIceHouse.main
function BuildIceHouse.main()
	BuildIceHouse.RefreshStatus()
end

function BuildIceHouse.On_Timer()
end

function BuildIceHouse.CanAcquireQuest()
	---- check if dragon fetched from sophie
	--if(not MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie()) then
		--return false;
	--end
	---- 30006_IceHouse
	--if(not hasGSItem(30006) and not hasGSItem(50212) and not hasGSItem(50213)) then
		--return true;
	--end
	
	-- NOTE: CAN'T acquire quest after 2010/1/21, but can finish the quest if already acquired
	
	return false
end

function BuildIceHouse.AcquireQuest()
	-- check if dragon fetched from sophie
	if(not MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie()) then
		_guihelper.MessageBox("快去找苏菲领回你的抱抱龙吧！");
		return;
	end
	
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
    
	if(not hasGSItem(50212) and not hasGSItem(50213)) then
		ItemManager.PurchaseItem(50212, 1, function(msg) end, function(msg)
			if(msg) then
				log("+++++++Purchase 50212_BuildIceHouse_Acquire return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess == true) then
					Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/091225/BuildIceHouse_Acquire.html");
				end
			end
		end);
	end
end

-- 30006_IceHouse

-- 50212_BuildIceHouse_Acquire
-- 50213_BuildIceHouse_Complete
-- 50214_BuildIceHouse_RewardFriendliness

-- refresh quest status
function BuildIceHouse.RefreshStatus()
	---- check if dragon fetched from sophie
	--if(not MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie()) then
		--_guihelper.MessageBox("快去找苏菲领回你的抱抱龙吧！");
		--return;
	--end
	
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
    
	if(hasGSItem(50212) and not hasGSItem(50213)) then
		QuestArea.AppendQuestStatus(
			"script/apps/Aries/NPCs/Dragon/091225/BuildIceHouse_status.html",
			"dragon", "", "建造冰雪小屋", 50212);
		BuildIceHouse.RegisterHook();
	elseif(hasGSItem(50212) and hasGSItem(50213)) then
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/091225/BuildIceHouse_status.html");
		BuildIceHouse.UnregisterHook();
	end
end

-- BuildIceHouse.OnObtainIceHouse
function BuildIceHouse.OnObtainIceHouse()
    -- finish the quest
    -- exid 153: DragonQuest_BuildIceHouse
    ItemManager.ExtendedCost(153, nil, nil, function(msg)end, function(msg)
	    log("+++++++ExtendedCost 153: DragonQuest_BuildIceHouse return: +++++++\n")
	    commonlib.echo(msg);
	    BuildIceHouse.RefreshStatus();
		MyCompany.Aries.Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/091225/BuildIceHouse_Finish.html");
		-- 50214_BuildIceHouse_RewardFriendliness
		if(msg.issuccess == true) then
			-- use the item 50214 to increase pet friendliness
            local bHas, guid = hasGSItem(50214);
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
function BuildIceHouse.RegisterHook()
	-- hook into pet name change
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnObtainItemAfterGetItemsInBag") then
				if(msg.gsid == 30006) then
					BuildIceHouse.OnObtainIceHouse();
				end
			end
		end, 
		hookName = "BuildIceHouse_OnObtain", appName = "Aries", wndName = "main"});
end

-- unregister hook
function BuildIceHouse.UnregisterHook()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "BuildIceHouse_OnObtain", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end