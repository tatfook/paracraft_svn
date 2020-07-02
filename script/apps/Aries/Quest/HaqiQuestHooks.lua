--[[
Title: hook processor for some special game events
Author(s): LiXizhi
Date: 2010/12/13
Desc: we will hook some special quest id to do some client side logics upon certain quest acception or completion, etc. 
Currently, "OnQuestAccepted" and "OnQuestFinished" are accepted. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Quest/HaqiQuestHooks.lua");
MyCompany.Aries.Quest.HaqiQuestHooks.InstallHooks();
local HaqiQuestHooks = commonlib.gettable("MyCompany.Aries.Quest.HaqiQuestHooks");

HaqiQuestHooks.Invoke("OnQuestFinished", id);
HaqiQuestHooks.Invoke("OnQuestAccepted", id);
------------------------------------------------------------
]]
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");

local HaqiQuestHooks = commonlib.gettable("MyCompany.Aries.Quest.HaqiQuestHooks");

-- call this function on application start. 
function HaqiQuestHooks.InstallHooks()
	if(QuestHelp.IsKidsVersion()) then
		NPL.load("(gl)script/apps/Aries/Quest/HaqiQuestHooks.kids.lua");
	else
		NPL.load("(gl)script/apps/Aries/Quest/HaqiQuestHooks.teen.lua");
	end
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = HaqiQuestHooks.OnQuestHookCallback, 
		hookName = "Aries_QuestHook", appName = "Aries", wndName = "quest"});
end

-- invoke quest
function HaqiQuestHooks.Invoke(action_type, id)
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", { aries_type = action_type, quest_id = id, wndName = "quest"});
end

-- quest hook callback. 
function HaqiQuestHooks.OnQuestHookCallback(nCode, appName, msg, value)
	if(msg.aries_type == "OnQuestAccepted") then
		if(msg.quest_id) then
			HaqiQuestHooks.OnQuestAccepted(msg.quest_id);
		end
	elseif(msg.aries_type == "OnQuestFinished") then			
		if(msg.quest_id) then
			HaqiQuestHooks.OnQuestFinished(msg.quest_id);
		end
	end
	return nCode;
end

function HaqiQuestHooks.OnQuestAccepted(quest_id)
	local func = HaqiQuestHooks.OnQuestAccepted_handlers[quest_id];
	if(func) then
		func(quest_id);
	end
end


function HaqiQuestHooks.OnQuestFinished(quest_id)
	local func = HaqiQuestHooks.OnQuestFinished_handlers[quest_id];
	if(func) then
		func(quest_id);
	end
end
