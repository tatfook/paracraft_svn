--[[
Title: 30011_WishLevel10
Author(s): WangTian
Date: 2009/7/29

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/30011_WishLevel10.lua
------------------------------------------------------------
]]

-- create class
local libName = "WishLevel10";
local WishLevel10 = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.WishLevel10", WishLevel10);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- WishLevel10.main
function WishLevel10.main()
	
	-- assert:
	-- 2010/1/21
	-- NOTE: the original extendedcost 182 DragonQuestGrow_Level10 froms: empty, tos: 50216,1|50217,1|10113,1 pres: 50215,1 
	--		it doesn't destroy the MysteryChest the Doctor gave him in the level 6 wish
	--		we change the extendedcost to 182 DragonQuestGrow_Level10 froms:17007,1 tos:50216,1|50217,1|10113,1 pres:50215,1 
	--		and destroy the chest manually if the user complete the level 10 wish
	if(hasGSItem(50215) and hasGSItem(50216)) then
		-- complete the level 10 wish
		-- destory the chest if not extendedcost before
		-- 17007_MysteryChest
		local bHas, guid = hasGSItem(17007);
		if(bHas) then
			ItemManager.DestroyItem(guid, 1, function() end);
		end
	end
end

-- 50215_WishLevel10_Acquire
-- 50216_WishLevel10_Complete
-- 50217_WishLevel10_RewardFriendliness

-- 50026_WishLevel5_Complete

-- refresh quest status
function WishLevel10.RefreshStatus()
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
	if(not hasGSItem(50215) and not hasGSItem(50216) and hasGSItem(50026)) then -- complete level5 quest
		ItemManager.PurchaseItem(50215, 1, function(msg) end, function(msg)
			if(msg) then
				log("+++++++Purchase 50215_WishLevel10_Acquire return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess == true) then
					Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/30011_WishLevel10_Acquire.html");
				end
			end
		end);
	elseif(hasGSItem(50215) and not hasGSItem(50216)) then
		QuestArea.AppendQuestStatus(
			"script/apps/Aries/NPCs/Dragon/30011_WishLevel10_status.html",
			"dragon", "", "找多克特博士开箱子", 50215);
		WishLevel10.RegisterHook();
	elseif(hasGSItem(50215) and hasGSItem(50216)) then
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/30011_WishLevel10_status.html");
		WishLevel10.UnregisterHook();
	end
end

-- item purchase hook
-- @param gsid: global store id of the purchased item
-- @param count: count of the purchased item
function WishLevel10.OnItemPurchase(gsid, count)
	if(gsid == 50216 and count == 1) then
		WishLevel10.RefreshStatus();
		Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/30011_WishLevel10_Finish.html");
	end
end

-- register hook into 
function WishLevel10.RegisterHook()
	---- hook into pet name change
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnObtainItemAfterGetItemsInBag") then
				WishLevel10.OnItemPurchase(msg.gsid, msg.count);
			end
		end, 
		hookName = "WishLevel10_PurchaseQuestComplete", appName = "Aries", wndName = "main"});
end

-- unregister hook
function WishLevel10.UnregisterHook()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "WishLevel10_PurchaseQuestComplete", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end