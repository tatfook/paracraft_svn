--[[
Title: QuestAction
Author(s): leio
Date: 2020/12/9
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Quest/QuestAction.lua");
local QuestAction = commonlib.gettable("MyCompany.Aries.Game.Tasks.Quest.QuestAction");
-------------------------------------------------------
]]

NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Quest/QuestProvider.lua");
local QuestProvider = commonlib.gettable("MyCompany.Aries.Game.Tasks.Quest.QuestProvider");

local QuestAction = commonlib.gettable("MyCompany.Aries.Game.Tasks.Quest.QuestAction")
QuestAction.Types = {
    default_addvalue = "addvalue", 
    default_setvalue = "setvalue", 
}
QuestAction.actions = {};
function QuestAction.Add(name, callback, ...)
    
end

