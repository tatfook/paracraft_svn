--[[
Title: 30011_WishLevel0
Author(s): WangTian
Date: 2009/7/29

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/30011_WishLevel0.lua
------------------------------------------------------------
]]

-- create class
local libName = "WishLevel0";
local WishLevel0 = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.WishLevel0", WishLevel0);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- WishLevel0.main
function WishLevel0.main()
end

WishLevel0.ActiveTabMountMonitor = false;

function WishLevel0.On_Timer()
	--if(WishLevel0.ActiveTabMountMonitor == true) then
		--local page = commonlib.getfield("MyCompany.Aries.Inventory.TabMountPage.page");
		--if(page) then
			--page:Goto("script/apps/Aries/Inventory/TabMount.html?withtip=true");
			--page:Refresh(0.1);
			--WishLevel0.ActiveTabMountMonitor = false;
		--end
	--end
end

-- refresh quest status
function WishLevel0.RefreshStatus()
	-- check if dragon fetched from sophie
	if(not MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie()) then
		_guihelper.MessageBox("快去找苏菲领回你的抱抱龙吧！");
		return;
	end
	
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
    
	if(not hasGSItem(50010) and not hasGSItem(50011)) then
		ItemManager.PurchaseItem(50010, 1, function(msg) end, function(msg)
			if(msg) then
				log("+++++++Purchase 50010_WishLevel0_Acquire return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess == true) then
					Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/30011_WishLevel0_Acquire.html");
				end
			end
		end);
	elseif(hasGSItem(50010) and not hasGSItem(50011)) then
		QuestArea.AppendQuestStatus(
			"script/apps/Aries/NPCs/Dragon/30011_WishLevel0_status.html",
			"dragon", "", "抱抱龙的新名字", 50010);
		WishLevel0.RegisterHook();
	elseif(hasGSItem(50010) and hasGSItem(50011)) then
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/30011_WishLevel0_status.html");
		WishLevel0.UnregisterHook();
	end

	-- NOTE: for old users that already finish the level 0 quest, check for 19004_DragonSkillHandbook
	--		 if not own the book, purchase a free copy
	-- 50011_WishLevel0_Complete
	if(hasGSItem(50011) and not hasGSItem(19004)) then
		ItemManager.PurchaseItem(19004, 1, function(msg) end, function(msg)
			if(msg) then
				log("+++++++Purchase 19004_DragonSkillHandbook return: +++++++\n")
				commonlib.echo(msg);
			end
		end, nil, nil, nil, false); -- false for ForceShowOrHideNotificationOnObtain
	end
end

function WishLevel0.OnPetNameChanged()
	if(hasGSItem(50010)) then
        -- finish the quest
        -- exid 83: DragonQuestGrow_Level0
        ItemManager.ExtendedCost(83, nil, nil, function(msg)end, function(msg)
		    log("+++++++ExtendedCost 83: DragonQuestGrow_Level0 return: +++++++\n")
		    commonlib.echo(msg);
			WishLevel0.RefreshStatus();
			Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/30011_WishLevel0_Finish.html");
			--50012_WishLevel0_RewardFriendliness
			if(msg.issuccess == true) then
				-- use the item 50012 to increase pet friendliness
                local bHas, guid = hasGSItem(50012);
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
function WishLevel0.RegisterHook()
	-- hook into pet name change
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "PetNameChanged") then
				WishLevel0.OnPetNameChanged();
			end
		end, 
		hookName = "WishLevel0_PetName", appName = "Aries", wndName = "main"});
	-- hook into OnDragonIconClick
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnDragonIconClick") then
			    local Desktop = MyCompany.Aries.Desktop;
				Desktop.GUIHelper.ArrowPointer.HideArrow(5491);
			end
		end, 
		hookName = "WishLevel0_DragonIconClick", appName = "Aries", wndName = "main"});
end

-- unregister hook
function WishLevel0.UnregisterHook()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "WishLevel0_PetName", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "WishLevel0_DragonIconClick", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end