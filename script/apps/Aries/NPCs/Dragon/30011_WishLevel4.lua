--[[
Title: 30011_WishLevel4
Author(s): WangTian
Date: 2009/7/29

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/30011_WishLevel4.lua
------------------------------------------------------------
]]

-- create class
local libName = "WishLevel4";
local WishLevel4 = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.WishLevel4", WishLevel4);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- WishLevel4.main
function WishLevel4.main()
end

-- refresh quest status
function WishLevel4.RefreshStatus()
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
	if(not hasGSItem(50022) and not hasGSItem(50023)) then
		ItemManager.PurchaseItem(50022, 1, function(msg) end, function(msg)
			if(msg) then
				log("+++++++Purchase 50022_WishLevel4_Acquire return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess == true) then
					Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/30011_WishLevel4_Acquire.html");
				end
			end
		end);
	elseif(hasGSItem(50022) and not hasGSItem(50023)) then
		QuestArea.AppendQuestStatus(
			"script/apps/Aries/NPCs/Dragon/30011_WishLevel4_status.html",
			"dragon", "", "给警长希尔的抱抱龙送一份菠萝派", 50022);
		WishLevel4.RegisterHook();
	elseif(hasGSItem(50022) and hasGSItem(50023)) then
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/30011_WishLevel4_status.html");
		WishLevel4.UnregisterHook();
	end
end

function WishLevel4.OnChiefHiltonDragonEatPineApplePie()
	local bHas, guid = hasGSItem(16012);
	if(hasGSItem(50022) and bHas) then
        -- finish the quest
        -- exid 87: DragonQuestGrow_Level4
        ItemManager.ExtendedCost(87, nil, nil, function(msg)end, function(msg)
		    log("+++++++ExtendedCost 87: DragonQuestGrow_Level4 return: +++++++\n")
		    commonlib.echo(msg);
			WishLevel4.RefreshStatus();
			Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/30011_WishLevel4_Finish.html");
			--50024_WishLevel4_RewardFriendliness
			if(msg.issuccess == true) then
				-- use the item 50024 to increase pet friendliness
                local bHas, guid = hasGSItem(50024);
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
function WishLevel4.RegisterHook()
	-- hook into pet name change
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "30014_ChiefHiltonDragon_EatPineApplePie") then
				WishLevel4.OnChiefHiltonDragonEatPineApplePie();
			end
		end, 
		hookName = "WishLevel4_EatPineApplePie", appName = "Aries", wndName = "main"});
end

-- unregister hook
function WishLevel4.UnregisterHook()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "WishLevel4_EatPineApplePie", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end