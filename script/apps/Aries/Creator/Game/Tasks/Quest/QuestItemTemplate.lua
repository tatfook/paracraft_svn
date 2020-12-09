--[[
Title: QuestItemTemplate
Author(s): leio
Date: 2020/12/8
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Quest/QuestItemTemplate.lua");
local QuestItemTemplate = commonlib.gettable("MyCompany.Aries.Game.Tasks.Quest.QuestItemTemplate");
-------------------------------------------------------
]]

NPL.load("(gl)script/ide/EventDispatcher.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Quest/QuestProvider.lua");
local QuestProvider = commonlib.gettable("MyCompany.Aries.Game.Tasks.Quest.QuestProvider");

local QuestItemTemplate = commonlib.inherit(nil,commonlib.gettable("MyCompany.Aries.Game.Tasks.Quest.QuestItemTemplate"))
QuestItemTemplate.Types = {
    NONE = "NONE", 

    VIRTUAL = "VIRTUAL", -- for virtual target
    REAL = "REAL",  -- for real item 

}
function QuestItemTemplate:ctor()
    -- property list
    self.exid = nil; -- number
    self.gsid = nil; -- number
    self.id = nil; -- string or number
    self.type = QuestItemTemplate.Types.NONE;
    self.finished_value = nil;
    self.title = nil;
    self.desc = nil;
end
function QuestItemTemplate:GetUniqueKey()
    local key = string.format("%s_%s",tostring(self.gsid), tostring(self.id));
    return key;
end
function QuestItemTemplate:GetData()
    local data = {
        exid = self.exid,
        gsid = self.gsid,
        id = self.id,
        type = self.type,
        finished_value = self.finished_value,
        title = self.title,
        desc = self.desc,
    }
    return data;
end
