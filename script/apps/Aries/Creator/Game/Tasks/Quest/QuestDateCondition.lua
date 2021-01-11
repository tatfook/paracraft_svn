--[[
Title: QuestDateCondition
Author(s): leio
Date: 2021/1/11
use the lib:
------------------------------------------------------------
NOTE£º
------------------------------------------------------------------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Quest/QuestDateCondition.lua");
local QuestDateCondition = commonlib.gettable("MyCompany.Aries.Game.Tasks.Quest.QuestDateCondition");
-------------------------------------------------------
]]
local QuestDateCondition = commonlib.inherit(nil,commonlib.gettable("MyCompany.Aries.Game.Tasks.Quest.QuestDateCondition"))

QuestDateCondition.type= "QuestDateCondition";
function QuestDateCondition:ctor()
        self.values = {};
        self.strict = false;
        self.cur_time = nil;
end
--[[
 {   
            "values" : [ 
                { "date": "2021-1-11", "duration": "10:00:00-12:00:00" },
                { "date": "2021-1-11", "duration": "14:00:00-16:00:00" },
                { "date": "2021-1-11", "duration": "20:00:00-22:00:00" },
            ],
            "strict": false,
        }
]]
function QuestDateCondition:Parse(config)
    if(not config)then
        return
    end
    self.values = commonlib.deepcopy(config.values or {})
    self.strict = config.strict;
end
function QuestDateCondition:Refresh()
    keepwork.user.server_time({},function(err, msg, data)
        if(err == 200)then
            self.cur_time_stamp = data.now;
            echo("=============self.cur_time_stamp");
            echo(self.cur_time_stamp);
        end
    end)
end
function QuestDateCondition:IsValid()
    -- check date by self.cur_time_stamp
end