--[[
Title: 30011_WishLevel6
Author(s): WangTian
Date: 2009/7/29

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/30011_WishLevel6.lua
------------------------------------------------------------
]]

-- create class
local libName = "WishLevel6";
local WishLevel6 = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.WishLevel6", WishLevel6);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- WishLevel6.main
function WishLevel6.main()
end

--50028_WishLevel6_Acquire
--50029_WishLevel6_Complete

-- refresh quest status
function WishLevel6.RefreshStatus()
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
	if(not hasGSItem(50028) and not hasGSItem(50029)) then
		ItemManager.PurchaseItem(50028, 1, function(msg) end, function(msg)
			if(msg) then
				log("+++++++Purchase 50028_WishLevel6_Acquire return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess == true) then
					Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/30011_WishLevel6_Acquire.html");
				end
			end
		end);
	elseif(hasGSItem(50028) and not hasGSItem(50029)) then
		QuestArea.AppendQuestStatus(
			"script/apps/Aries/NPCs/Dragon/30011_WishLevel6_status.html",
			"dragon", "", "抱抱龙奇怪的心愿", 50028);
		WishLevel6.RegisterHook();
	elseif(hasGSItem(50028) and hasGSItem(50029)) then
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/30011_WishLevel6_status.html");
		WishLevel6.UnregisterHook();
	end
end

-- item purchase hook
-- @param gsid: global store id of the purchased item
-- @param count: count of the purchased item
function WishLevel6.OnItemPurchase(gsid, count)
	if(gsid == 50029 and count == 1) then
		WishLevel6.RefreshStatus();
		Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/30011_WishLevel6_Finish.html");
	end
end

-- register hook into 
function WishLevel6.RegisterHook()
	-- hook into pet name change
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnObtainItemAfterGetItemsInBag") then
				WishLevel6.OnItemPurchase(msg.gsid, msg.count);
			end
		end, 
		hookName = "WishLevel6_PurchaseQuestComplete", appName = "Aries", wndName = "main"});
end

-- unregister hook
function WishLevel6.UnregisterHook()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "WishLevel6_PurchaseQuestComplete", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end