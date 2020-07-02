--[[
Title: 30011_WishLevel3
Author(s): WangTian
Date: 2009/7/29

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/30011_WishLevel3.lua
------------------------------------------------------------
]]

-- create class
local libName = "WishLevel3";
local WishLevel3 = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.WishLevel3", WishLevel3);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- WishLevel3.main
function WishLevel3.main()
end

-- refresh quest status
function WishLevel3.RefreshStatus()
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
	if(not hasGSItem(50019) and not hasGSItem(50020)) then
		ItemManager.PurchaseItem(50019, 1, function(msg) end, function(msg)
			if(msg) then
				log("+++++++Purchase 50019_WishLevel3_Acquire return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess == true) then
					Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/30011_WishLevel3_Acquire.html");
				end
			end
		end);
	elseif(hasGSItem(50019) and not hasGSItem(50020)) then
		QuestArea.AppendQuestStatus(
			"script/apps/Aries/NPCs/Dragon/30011_WishLevel3_status.html",
			"dragon", "", "送只小花猫给苏苏", 50019);
		WishLevel3.RegisterHook();
	elseif(hasGSItem(50019) and hasGSItem(50020)) then
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/30011_WishLevel3_status.html");
		WishLevel3.UnregisterHook();
	end
end

-- item purchase hook
-- @param gsid: global store id of the purchased item
-- @param count: count of the purchased item
function WishLevel3.OnItemPurchase(gsid, count)
	if(gsid == 50020 and count == 1) then
		WishLevel3.RefreshStatus();
		---- make sure that the 
		--QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/30011_WishLevel3_status.html");
		--WishLevel3.UnregisterHook();
		Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/30011_WishLevel3_Finish.html");
	end
end

-- register hook into pet name change
function WishLevel3.RegisterHook()
	-- hook into pet name change
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnObtainItemAfterGetItemsInBag") then
				WishLevel3.OnItemPurchase(msg.gsid, msg.count);
			end
		end, 
		hookName = "WishLevel3_PurchaseQuestComplete", appName = "Aries", wndName = "main"});
end

-- unregister hook
function WishLevel3.UnregisterHook()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "WishLevel3_PurchaseQuestComplete", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end