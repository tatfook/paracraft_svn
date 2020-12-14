--[[
Title: QuestAction
Author(s): leio
Date: 2020/12/10
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Quest/QuestAction.lua");
local QuestAction = commonlib.gettable("MyCompany.Aries.Game.Tasks.Quest.QuestAction");

QuestAction.SetValue("60003_1",2);
echo("===================test");
echo(QuestAction.GetValue("60003_1"));
echo(QuestAction.GetFinishedValue("60003_1"));
echo(QuestAction.GetItemTemplate("60003_1"));
QuestAction.SetValue("60003_2","abc");
QuestAction.SetValue("60003_3",5);

QuestAction.DoFinish(60003);



NPL.load("(gl)script/apps/Aries/Creator/Game/game_logic.lua");
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
GameLogic.QuestAction.SetValue(id,value);
GameLogic.QuestAction.GetValue(id);
GameLogic.QuestAction.DoFinish(quest_gsid);


-- 设置任务目标"60001_1"的值为:1
GameLogic.QuestAction.SetValue("60001_1",1);

-- 获取任务目标"60001_1"的值
GameLogic.QuestAction.GetValue("60001_1");

-- 完成任务60001
GameLogic.QuestAction.DoFinish(60001);

if(GameLogic.QuestAction and GameLogic.QuestAction.SetValue)then
    GameLogic.QuestAction.SetValue("60001_1",1);
end
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/game_logic.lua");
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")

local KeepWorkItemManager = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/KeepWorkItemManager.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Quest/QuestProvider.lua");
local QuestProvider = commonlib.gettable("MyCompany.Aries.Game.Tasks.Quest.QuestProvider");
local QuestAction = commonlib.gettable("MyCompany.Aries.Game.Tasks.Quest.QuestAction");

-- read world_id from template.goto_world
-- template.goto_world = ["ONLINE","RELEASE","LOCAL"]
function QuestAction.GetGoToWorldId(target_id)
    local template = QuestAction.GetItemTemplate(target_id);
    if(template)then
        return template:GetCurVersionValue("goto_world");
        
    end
end
function QuestAction.SetValue(id,value)
    if(not id)then
        return
    end
    QuestProvider:GetInstance():SetValue(id,value);
end
function QuestAction.GetValue(id)
    return QuestProvider:GetInstance():GetValue(id);
end
function QuestAction.GetFinishedValue(id)
    local template = QuestAction.GetItemTemplate(id);
    if(template)then
        return template.finished_value;
    end
end
function QuestAction.GetItemTemplate(id)
    local item = QuestAction.FindItemById(id);
    if(item and item.template)then
        return item.template;
    end
end
function QuestAction.FindItemById(id)
    return QuestProvider:GetInstance():FindItemById(id);
end
function QuestAction.DoFinish(quest_gsid)
    if(not quest_gsid)then
        return
    end
    local item = QuestProvider:GetInstance():CreateOrGetQuestItemContainer(quest_gsid);
    if(item)then
        item:DoFinish();
    end
end

