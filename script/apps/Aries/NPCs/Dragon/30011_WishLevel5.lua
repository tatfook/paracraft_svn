--[[
Title: 30011_WishLevel5
Author(s): WangTian
Date: 2009/7/29

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/30011_WishLevel5.lua
------------------------------------------------------------
]]

-- create class
local libName = "WishLevel5";
local WishLevel5 = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.WishLevel5", WishLevel5);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- WishLevel5.main
function WishLevel5.main()
end

--50025_WishLevel5_Acquire
--50026_WishLevel5_Complete

-- refresh quest status
function WishLevel5.RefreshStatus()
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
	if(not hasGSItem(50025) and not hasGSItem(50026)) then
		ItemManager.PurchaseItem(50025, 1, function(msg) end, function(msg)
			if(msg) then
				log("+++++++Purchase 50025_WishLevel5_Acquire return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess == true) then
					Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/30011_WishLevel5_Acquire.html");
				end
			end
		end);
	elseif(hasGSItem(50025) and not hasGSItem(50026)) then
		QuestArea.AppendQuestStatus(
			"script/apps/Aries/NPCs/Dragon/30011_WishLevel5_status.html",
			"dragon", "", "打听多克特博士的秘密", 50025);
		WishLevel5.RegisterHook();
	elseif(hasGSItem(50025) and hasGSItem(50026)) then
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/30011_WishLevel5_status.html");
		WishLevel5.UnregisterHook();
	end
end

-- item purchase hook
-- @param gsid: global store id of the purchased item
-- @param count: count of the purchased item
function WishLevel5.OnItemPurchase(gsid, count)
	if(gsid == 50026 and count == 1) then
		WishLevel5.RefreshStatus();
		-- refresh level 10 quest status in case of leveling up directly to level 10
		MyCompany.Aries.Quest.NPCs.DragonWish.RefreshStatus();
		
		Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/30011_WishLevel5_Finish.html");
	end
end

-- register hook into 
function WishLevel5.RegisterHook()
	-- hook into pet name change
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnObtainItemAfterGetItemsInBag") then
				WishLevel5.OnItemPurchase(msg.gsid, msg.count);
			end
		end, 
		hookName = "WishLevel5_PurchaseQuestComplete", appName = "Aries", wndName = "main"});
end

-- unregister hook
function WishLevel5.UnregisterHook()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "WishLevel5_PurchaseQuestComplete", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end