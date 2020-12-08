--[[
Title: QuestItemContainer
Author(s): leio
Date: 2020/12/8
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Quest/QuestItemContainer.lua");
local QuestItemContainer = commonlib.gettable("MyCompany.Aries.Game.Tasks.Quest.QuestItemContainer");
-------------------------------------------------------
]]
local KeepWorkItemManager = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/KeepWorkItemManager.lua");
NPL.load("(gl)script/ide/EventDispatcher.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Quest/QuestProvider.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Quest/QuestItem.lua");
local QuestProvider = commonlib.gettable("MyCompany.Aries.Game.Tasks.Quest.QuestProvider");
local QuestItem = commonlib.gettable("MyCompany.Aries.Game.Tasks.Quest.QuestItem");
local QuestItemContainer = commonlib.inherit(commonlib.gettable("commonlib.EventSystem"),commonlib.gettable("MyCompany.Aries.Game.Tasks.Quest.QuestItemContainer"))

QuestItemContainer.Events = {
    OnChanged = "OnChanged",
    OnFinish = "OnFinish",
}
function QuestItemContainer:ctor()
end
function QuestItemContainer:OnInit(gsid, client_data)
    self.gsid = gsid;
    self.state = nil -- 1 means finished
    self.children = {};
    self:Parse(client_data)
    return self;
end
function QuestItemContainer:Parse(client_data)
    if(not client_data)then
        return
    end
    if(type(client_data) == "object")then
        if(client_data.state == 1)then
            self.state = client_data.state;
        else
            for k,v in ipairs(client_data) do
                local id = v.id;
                local value = v.value;
                local template = QuestProvider:GetQuestItemTemplate(id);
                local quest_item = QuestItem:new():OnInit(id, value, template);      
                self:AddChild(quest_item);
            end
        end
    end
end
function QuestItemContainer:GetChildById(id)
    if(not id)then
        return
    end
     for k,v in ipairs(self.children) do
        if(v.id == id)then
            return v;
        end
    end
end
function QuestItemContainer:AddChild(quest_item)
    if(not quest_item)then
        return
    end
    if(self:HasChild(quest_item))then
        return
    end
    quest_item:AddEventListener(QuestItem.Events.OnChanged,function(__,event)
        local gsid = self.gsid;
        self:DispatchEvent({ type = QuestItemContainer.Events.OnChanged, gsid = gsid, });
    end)
    table.insert(self.children,quest_item);
end
function QuestItemContainer:HasChild(quest_item)
    if(not quest_item)then
        return
    end
    for k,v in ipairs(self.children) do
        if(v.id == quest_item.id)then
            return true;
        end
    end
end
function QuestItemContainer:CanFinish()
    for k,v in ipairs(self.children) do
        if(not v:CanFinish())then
            return false;
        end
    end
    return true;
end
function QuestItemContainer:IsFinished()
    return self.state == 1;
end
function QuestItemContainer:DoFinish()
    if(not self:CanFinish())then
        return
    end
    self.state = 1;
    self:DispatchEvent({ type = QuestItemContainer.Events.OnFinish, gsid = self.gsid, });
end
-- only saving this data to server
function QuestItemContainer:GetData()
    local state = self.state
    local result = {
        state = state,
        
    };
    if(state ~= 1)then
        for k,v in ipairs(self.children) do
            result.children = result.children or {};
            table.insert(result.children,v:GetData());
        end
    end
    return result;
end

function QuestItemContainer:IncreaseNumberValue(id, value)
    if(not id)then
        return
    end
    if(self:CanFinish() or self:IsFinished())then
        return
    end
    for k,v in ipairs(self.children) do
        if(v.id == id)then
            v:IncreaseNumberValue(value);
        end
    end
end
function QuestItemContainer:SetValue(id, value)
    if(not id)then
        return
    end
    if(self:CanFinish() or self:IsFinished())then
        return
    end
    for k,v in ipairs(self.children) do
        if(v.id == id)then
            v:SetValue(value);
        end
    end
end