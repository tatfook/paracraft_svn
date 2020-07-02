--[[
Title: 30011_WishLevel7
Author(s): WangTian
Date: 2009/7/29

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/30011_WishLevel7.lua
------------------------------------------------------------
]]

-- create class
local libName = "WishLevel7";
local WishLevel7 = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.WishLevel7", WishLevel7);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- WishLevel7.main
function WishLevel7.main()
end

--50031_WishLevel7_Acquire
--50032_WishLevel7_Complete

-- refresh quest status
function WishLevel7.RefreshStatus()
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
	if(not hasGSItem(50031) and not hasGSItem(50032)) then
		ItemManager.PurchaseItem(50031, 1, function(msg) end, function(msg)
			if(msg) then
				log("+++++++Purchase 50031_WishLevel7_Acquire return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess == true) then
					Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/30011_WishLevel7_Acquire.html");
				end
			end
		end);
	elseif(hasGSItem(50031) and not hasGSItem(50032)) then
		QuestArea.AppendQuestStatus(
			"script/apps/Aries/NPCs/Dragon/30011_WishLevel7_status.html",
			"dragon", "", "莫卡想看哈奇大使的衣服", 50031);
		WishLevel7.RegisterHook();
	elseif(hasGSItem(50031) and hasGSItem(50032)) then
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/30011_WishLevel7_status.html");
		WishLevel7.UnregisterHook();
	end
end

-- item purchase hook
-- @param gsid: global store id of the purchased item
-- @param count: count of the purchased item
function WishLevel7.OnItemPurchase(gsid, count)
	if(gsid == 50032 and count == 1) then
		WishLevel7.RefreshStatus();
		Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/30011_WishLevel7_Finish.html");
	end
end

-- register hook into 
function WishLevel7.RegisterHook()
	---- hook into pet name change
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnObtainItemAfterGetItemsInBag") then
				WishLevel7.OnItemPurchase(msg.gsid, msg.count);
			end
		end, 
		hookName = "WishLevel7_PurchaseQuestComplete", appName = "Aries", wndName = "main"});
end

-- unregister hook
function WishLevel7.UnregisterHook()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "WishLevel7_PurchaseQuestComplete", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end