--[[
Title: LazyPandaWeeklyManage
Author(s): Leio
Date: 2010/01/13

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/FollowPets/30208_LazyPandaWeeklyManage.lua
------------------------------------------------------------
]]

-- create class
local libName = "LazyPandaWeeklyManage";
local LazyPandaWeeklyManage = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.LazyPandaWeeklyManage", LazyPandaWeeklyManage);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
--第一周
function LazyPandaWeeklyManage.OnInit_Week_1()
	local bHas, guid, __, copies = hasGSItem(17003);
	if(copies > 0)then
		--吃掉一根竹子
	else
		--家出走了
	end
end
function LazyPandaWeeklyManage.HookHandler(nCode, appName, msg, value)
	if(msg.panda_weekly_type == "pet_action_feeding")then
		return nCode;
	end
end
function LazyPandaWeeklyManage.RegisterHook()
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = MyCompany.Aries.Quest.NPCs.LazyPandaWeeklyManage.HookHandler, 
		hookName = "LazyPandaWeeklyManage_hook", appName = "Aries", wndName = "mountpet"});
end
function LazyPandaWeeklyManage.UnregisterHook()
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "LazyPandaWeeklyManage_hook", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end