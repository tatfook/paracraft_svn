--[[
Title: QuestItem
Author(s): leio
Date: 2020/12/8
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Quest/QuestItem.lua");
local QuestItem = commonlib.gettable("MyCompany.Aries.Game.Tasks.Quest.QuestItem");
-------------------------------------------------------
]]

NPL.load("(gl)script/ide/EventDispatcher.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Quest/QuestProvider.lua");
local QuestProvider = commonlib.gettable("MyCompany.Aries.Game.Tasks.Quest.QuestProvider");

local QuestItem = commonlib.inherit(commonlib.gettable("commonlib.EventSystem"),commonlib.gettable("MyCompany.Aries.Game.Tasks.Quest.QuestItem"))
QuestItem.Types= {
    NUMBER = "NUMBER",
    STRING = "STRING",
}
QuestItem.Events = {
    OnChanged = "OnChanged",
}
function QuestItem:ctor()
end
function QuestItem:OnInit(id, value, template)
    self.type = template.type;
    self.id = id;
    self.value = value;
    self.finished_value = template.finished_value;
    return self;
end

function QuestItem:GetValue()
    return self.value;
end
function QuestItem:IncreaseNumberValue(value)
    if(self.type ~= QuestItem.Types.NUMBER)then
	    LOG.std(nil, "error", "QuestItem", "IncreaseNumberValue error with type: %s, value = %s", self.type, tostring(value));
        return    
    end
    local cur_value = self.value or 0;
    self.value = cur_value + value;
    if(self.value > self.finished_value)then
        self.value = self.finished_value;
    end

    self:DispatchEvent({ type = QuestItem.Events.OnChanged, });
end
function QuestItem:SetValue(value)
    self.value = value;
    self:DispatchEvent({ type = QuestItem.Events.OnChanged, });
end
function QuestItem:IsDirty()
    return self.is_dirty;
end
function QuestItem:CanFinish()
    if(self.value and self.finished_value)then
        if(self.type == QuestItem.Types.NUMBER)then
            return self.value >= self.finished_value;
        elseif(self.type == QuestItem.Types.STRING)then
            return self.value == self.finished_value;
        end
    end
end
-- only saving this data to server
function QuestItem:GetData()
    local data = {
        id = self.id,
        value = self.value,
    }
    return data;
end
