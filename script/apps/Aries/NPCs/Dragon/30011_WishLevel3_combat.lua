--[[
Title: 30011_WishLevel3_combat
Author(s): Leio
Date: 2010/07/03

use the lib:

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/Dragon/30011_WishLevel3_combat.lua");
------------------------------------------------------------
]]

-- create class
local libName = "WishLevel3_combat";
local WishLevel3_combat = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.WishLevel3_combat", WishLevel3_combat);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- WishLevel3_combat.main
function WishLevel3_combat.main()
end

-- refresh quest status
function WishLevel3_combat.RefreshStatus()
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
	if(not hasGSItem(50308) and not hasGSItem(50309)) then
		ItemManager.PurchaseItem(50308, 1, function(msg) end, function(msg)
			if(msg) then
				log("+++++++Purchase 50308_WishLevel3_combat_Acquire return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess == true) then
					Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/30011_WishLevel3_combat_Acquire.html");
				end
			end
		end);
	elseif(hasGSItem(50308) and not hasGSItem(50309)) then
		QuestArea.AppendQuestStatus(
			"script/apps/Aries/NPCs/Dragon/30011_WishLevel3_combat_status.html",
			"dragon", "", "抱抱龙想加入战斗", 50308);
		WishLevel3_combat.RegisterHook();
	elseif(hasGSItem(50308) and hasGSItem(50309)) then
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/30011_WishLevel3_combat_status.html");
		WishLevel3_combat.UnregisterHook();
	end
end

-- item purchase hook
-- @param gsid: global store id of the purchased item
-- @param count: count of the purchased item
function WishLevel3_combat.OnItemPurchase(gsid, count)
	if(gsid == 50309 and count == 1) then
		WishLevel3_combat.RefreshStatus();
		---- make sure that the 
		--QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/30011_WishLevel3_status.html");
		--WishLevel3_combat.UnregisterHook();
		Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/30011_WishLevel3_combat_Finish.html");
	end
end

-- register hook into pet name change
function WishLevel3_combat.RegisterHook()
	-- hook into pet name change
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnObtainItemAfterGetItemsInBag") then
				WishLevel3_combat.OnItemPurchase(msg.gsid, msg.count);
			end
		end, 
		hookName = "WishLevel3_combat_PurchaseQuestComplete", appName = "Aries", wndName = "main"});
end

-- unregister hook
function WishLevel3_combat.UnregisterHook()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "WishLevel3_combat_PurchaseQuestComplete", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end