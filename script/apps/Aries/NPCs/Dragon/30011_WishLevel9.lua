--[[
Title: 30011_WishLevel9
Author(s): WangTian
Date: 2009/7/29

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/30011_WishLevel9.lua
------------------------------------------------------------
]]

-- create class
local libName = "WishLevel9";
local WishLevel9 = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.WishLevel9", WishLevel9);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- WishLevel9.main
function WishLevel9.main()
end

-- 50050_WishLevel9_Acquire
-- 50051_WishLevel9_Complete
-- 50052_WishLevel9_RewardFriendliness
-- 50040_WishLevel9_TalkedWithDragonTotem
-- 50041_WishLevel9_FireBallShard
-- 15001_SpitFire

-- refresh quest status
function WishLevel9.RefreshStatus()
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
	if(not hasGSItem(50050) and not hasGSItem(50051)) then
		ItemManager.PurchaseItem(50050, 1, function(msg) end, function(msg)
			if(msg) then
				log("+++++++Purchase 50050_WishLevel9_Acquire return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess == true) then
					Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/30011_WishLevel9_Acquire.html");
				end
			end
		end);
	elseif(hasGSItem(50050) and not hasGSItem(50051) and not hasGSItem(50040)) then
		QuestArea.AppendQuestStatus(
			"script/apps/Aries/NPCs/Dragon/30011_WishLevel9_status.html",
			"dragon", "", "抱抱龙喷火的秘密", 50050);
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/30011_WishLevel9_status2.html");
		WishLevel9.RegisterHook();
	elseif(hasGSItem(50050) and not hasGSItem(50051) and hasGSItem(50040)) then
		QuestArea.AppendQuestStatus(
			"script/apps/Aries/NPCs/Dragon/30011_WishLevel9_status2.html",
			"dragon", "", "抱抱龙喷火的秘密", 50050);
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/30011_WishLevel9_status.html");
		WishLevel9.RegisterHook();
	elseif(hasGSItem(50050) and hasGSItem(50051)) then
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/30011_WishLevel9_status.html");
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/30011_WishLevel9_status2.html");
		WishLevel9.UnregisterHook();
	end
end

-- 50050_WishLevel9_Acquire
-- 50051_WishLevel9_Complete
-- 50052_WishLevel9_RewardFriendliness
-- 50040_WishLevel9_TalkedWithDragonTotem
-- 50041_WishLevel9_FireBallShard
-- 15001_SpitFire

-- item purchase hook
-- @param gsid: global store id of the purchased item
-- @param count: count of the purchased item
function WishLevel9.OnItemPurchase(gsid, count)
	if(gsid == 50051 and count == 1) then
		WishLevel9.RefreshStatus();
		Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/30011_WishLevel9_Finish.html");
	end
end

function WishLevel9.OnFireMasterGameClose()
end

-- register hook into 
function WishLevel9.RegisterHook()
	---- hook into pet name change
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnObtainItemAfterGetItemsInBag") then
				WishLevel9.OnItemPurchase(msg.gsid, msg.count);
			end
		end, 
		hookName = "WishLevel9_PurchaseQuestComplete", appName = "Aries", wndName = "main"});
		
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnFireMasterGameClose") then
				WishLevel9.OnFireMasterGameClose();
			end
		end, 
		hookName = "WishLevel9_FireMasterGameClose", appName = "Aries", wndName = "main"});
end

-- unregister hook
function WishLevel9.UnregisterHook()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "WishLevel9_PurchaseQuestComplete", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "WishLevel9_FireMasterGameClose", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end