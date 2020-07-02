--[[
Title: 30011_CookForElk
Author(s): WangTian
Date: 2009/7/29

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/091211/CookForElk.lua
------------------------------------------------------------
]]

-- create class
local libName = "CookForElk";
local CookForElk = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.CookForElk", CookForElk);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- CookForElk.main
function CookForElk.main()
end

function CookForElk.On_Timer()
end

-- 50188_WishElkFeed_Acquire
-- 50189_WishElkFeed_Complete
-- 50190_WishElkFeed_RewardFriendliness
-- 50191_WishElkFeed_TalkedToSophieDragon

-- refresh quest status
function CookForElk.RefreshStatus()
	-- check if dragon fetched from sophie
	if(not MyCompany.Aries.Pet.IsMyDragonFetchedFromSophie()) then
		_guihelper.MessageBox("快去找苏菲领回你的抱抱龙吧！");
		return;
	end
	
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
    
	if(not hasGSItem(50188) and not hasGSItem(50189)) then
		ItemManager.PurchaseItem(50188, 1, function(msg) end, function(msg)
			if(msg) then
				log("+++++++Purchase 50188_WishElkFeed_Acquire return: +++++++\n")
				commonlib.echo(msg);
				if(msg.issuccess == true) then
					Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/091211/CookForElk_Acquire.html");
				end
			end
		end);
	elseif(hasGSItem(50188) and not hasGSItem(50189)) then
		QuestArea.AppendQuestStatus(
			"script/apps/Aries/NPCs/Dragon/091211/CookForElk_status.html",
			"dragon", "", "给圣诞麋鹿准备美食", 50188);
		CookForElk.RegisterHook();
	elseif(hasGSItem(50188) and hasGSItem(50189)) then
		QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/Dragon/091211/CookForElk_status.html");
		CookForElk.UnregisterHook();
	end
end

-- register hook into pet name change
function CookForElk.RegisterHook()
	-- hook into pet name change
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
		end, 
		hookName = "CookForElk_PetName", appName = "Aries", wndName = "main"});
end

-- unregister hook
function CookForElk.UnregisterHook()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "CookForElk_PetName", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end