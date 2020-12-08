--[[
Title: QuestProvider
Author(s): leio
Date: 2020/12/8
use the lib:
------------------------------------------------------------
local config = {
        { id = 10001, type = "NUMBER",  finished_value = 3, title = "", desc = "", },
        { id = 10002, type = "STRING", finished_value = "ABC", title = "", desc = "", },
        { id = 10003, type = "NUMBER", finished_value = 100, title = "", desc = "", },

}
local clientdata_list = {
    { gsId = 1, data = nil, },
    { gsId = 2, data = nil, },
    { gsId = 3, data = nil, },
    { gsId = 4, data = nil, },
}
local quest_nodes = {
    { exid = 11, gsId = 1, conditions = { 10001, 10002, 10003, }, },
    { exid = 12, gsId = 2, },
    { exid = 13, gsId = 3, },
    { exid = 14, gsId = 4, },
}
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Quest/QuestProvider.lua");
local QuestProvider = commonlib.gettable("MyCompany.Aries.Game.Tasks.Quest.QuestProvider");
QuestProvider:OnInit(config, clientdata_list, quest_nodes);

QuestProvider:IncreaseNumberValue(10001,1);
QuestProvider:SetValue(10002,"ABC");
QuestProvider:IncreaseNumberValue(10003,100);
echo(QuestProvider:Dump(),true);

local item = QuestProvider:CreateOrGetQuestItemContainer(1);
if(item)then
    item:DoFinish();
end
-------------------------------------------------------


]]
NPL.load("(gl)script/ide/EventDispatcher.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Quest/QuestItem.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Quest/QuestItemContainer.lua");
local QuestItemContainer = commonlib.gettable("MyCompany.Aries.Game.Tasks.Quest.QuestItemContainer");
local QuestItem = commonlib.gettable("MyCompany.Aries.Game.Tasks.Quest.QuestItem");

local QuestProvider = commonlib.gettable("MyCompany.Aries.Game.Tasks.Quest.QuestProvider");


function QuestProvider:OnInit(config, clientdata_list, quest_nodes)
    if(self.is_init)then
        return
    end
    self.is_init = true;
    QuestProvider.config_map = {};
    QuestProvider.questItemContainer_map = {};
    self.config = config;
    for k,v in ipairs(config) do
        self.config_map[v.id] = v;
    end
    self:FillData(clientdata_list);
    self:Match(quest_nodes);
end
function QuestProvider:FillData(clientdata_list)
    if(not clientdata_list)then
        return
    end
     for k,v in ipairs(clientdata_list) do
        local gsid = v.gsId;
        local data = v.data;
        local item = self:CreateOrGetQuestItemContainer(gsid);  
        item:Parse(data);
    end
end

function QuestProvider:Match(quest_nodes)
    if(not quest_nodes)then
        return
    end
     for k,v in ipairs(quest_nodes) do
        local gsid = v.gsId;
        local conditions = v.conditions;
        if(conditions)then
            local itemContainer = self:CreateOrGetQuestItemContainer(gsid);  
                for kk,id in ipairs(conditions) do
                local item = itemContainer:GetChildById(id);
                if(not item)then
                    local template = self:GetQuestItemTemplate(id);
                    local quest_item = QuestItem:new():OnInit(id, nil, template);      
                    itemContainer:AddChild(quest_item);
                end
            end
        end
    end
end
function QuestProvider:CreateOrGetQuestItemContainer(gsid,data)
    if(not gsid)then
        return
    end
    local item = self.questItemContainer_map[gsid];
    if(not item)then
        item = QuestItemContainer:new():OnInit(gsid,data);  

        item:AddEventListener(QuestItemContainer.Events.OnChanged,function(__,event)
            commonlib.echo("==============OnChanged");
            commonlib.echo(item:GetData(),true);
            --TODO: save data
        end)
        item:AddEventListener(QuestItemContainer.Events.OnFinish,function(__,event)
            commonlib.echo("==============OnFinish");
            commonlib.echo(item:GetData(),true);
        end)
        

        self.questItemContainer_map[gsid] = item;
    end
    return item;
end
function QuestProvider:GetQuestItemTemplate(id)
    return self.config_map[id];
end
function QuestProvider:IncreaseNumberValue(id,value)
    if(not self:GetQuestItemTemplate(id))then
        return
    end
    for k,v in pairs(self.questItemContainer_map) do
        v:IncreaseNumberValue(id,value);
    end
end
function QuestProvider:SetValue(id,value)
    if(not self:GetQuestItemTemplate(id))then
        return
    end
    for k,v in pairs(self.questItemContainer_map) do
        v:SetValue(id,value);
    end
end
function QuestProvider:Dump()
    commonlib.echo("==============Dump");
    local result = {};
    for k,v in pairs(self.questItemContainer_map) do
        table.insert(result, {
            gsid = v.gsid,
            v:GetData()
        });
    end
    return result;
end
