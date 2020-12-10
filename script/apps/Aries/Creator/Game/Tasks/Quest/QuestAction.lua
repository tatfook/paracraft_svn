--[[
Title: QuestAction
Author(s): leio
Date: 2020/12/10
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Quest/QuestAction.lua");
local QuestAction = commonlib.gettable("MyCompany.Aries.Game.Tasks.Quest.QuestAction");

QuestAction.IncreaseNumberValue("60003_1",1);
QuestAction.SetValue("60003_2","ABC");
QuestAction.IncreaseNumberValue("60003_3",100);

QuestAction.DoFinish(60003);
-------------------------------------------------------
]]
local KeepWorkItemManager = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/KeepWorkItemManager.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Quest/QuestProvider.lua");
local QuestProvider = commonlib.gettable("MyCompany.Aries.Game.Tasks.Quest.QuestProvider");
local QuestAction = commonlib.gettable("MyCompany.Aries.Game.Tasks.Quest.QuestAction");

function QuestAction.IncreaseNumberValue(id,value)
    QuestProvider:GetInstance():IncreaseNumberValue(id,value);
end
function QuestAction.SetValue(id,value)
    QuestProvider:GetInstance():SetValue(id,value);
end
function QuestAction.DoFinish(quest_gsid)
    local item = QuestProvider:GetInstance():CreateOrGetQuestItemContainer(quest_gsid);
    if(item)then
        item:DoFinish();
    end
end

