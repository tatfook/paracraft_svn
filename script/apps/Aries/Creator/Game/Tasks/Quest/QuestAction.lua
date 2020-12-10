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
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/game_logic.lua");
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")

local KeepWorkItemManager = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/KeepWorkItemManager.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Quest/QuestProvider.lua");
local QuestProvider = commonlib.gettable("MyCompany.Aries.Game.Tasks.Quest.QuestProvider");
local QuestAction = commonlib.gettable("MyCompany.Aries.Game.Tasks.Quest.QuestAction");

function QuestAction.SetValue(id,value)
    if(not id)then
        return
    end
    -- post log
	GameLogic.GetFilters():apply_filters("user_behavior", 1, "click.quest_action.setvalue", { id = id, value = value, });
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
    -- post log
	GameLogic.GetFilters():apply_filters("user_behavior", 1, "click.quest_action.do_finish", { quest_gsid = quest_gsid});
    local item = QuestProvider:GetInstance():CreateOrGetQuestItemContainer(quest_gsid);
    if(item)then
        item:DoFinish();
    end
end

