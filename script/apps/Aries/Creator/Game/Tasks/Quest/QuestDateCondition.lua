--[[
Title: QuestDateCondition
Author(s): leio
Date: 2021/1/11
use the lib:
------------------------------------------------------------
NOTE：
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
        self.endtime = nil
end
--[[
 {   
            "values" : [ 
                { "date": "2021-1-11", "duration": "10:00:00-12:00:00" },
                { "date": "2021-1-11", "duration": "14:00:00-16:00:00" },
                { "date": "2021-1-11", "duration": "20:00:00-22:00:00" },
            ],
            "strict": false,
            "endtime": 2021-01-12 11:28:21
        }
]]
function QuestDateCondition:Parse(config)
    if(not config)then
        return
    end
    self.values = commonlib.deepcopy(config.values or {})
    self.strict = config.strict;
    self.endtime = config.endtime
end
function QuestDateCondition:Refresh()
    keepwork.user.server_time({},function(err, msg, data)
        if(err == 200)then
            self.cur_time = data.now;
            echo("=============self.cur_time");
            echo(self.cur_time);
        end
    end)
end
function QuestDateCondition:IsValid()
    -- check date by self.cur_time
    if self.cur_time == nil then
        return false
    end

    local cur_time_stamp = commonlib.timehelp.GetTimeStampByDateTime(self.cur_time)

    -- local HttpWrapper = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/HttpWrapper.lua");
    -- local httpwrapper_version = HttpWrapper.GetDevVersion();
    -- if httpwrapper_version == "RELEASE" or httpwrapper_version == "LOCAL" then
    --     cur_time_stamp = os.time()
    -- end

    -- 先判断结束时间
    if self.endtime and self.endtime ~= "" then
        local year, month, day, hour, min, sec = self.endtime:match("^(%d+)%D(%d+)%D(%d+)%D(%d+)%D(%d+)%D(%d+)") 
        if not year then
            return false
        end

        local endtime_stamp = QuestDateCondition.GetTimeStamp(year, month, day, hour, min, sec)
        if cur_time_stamp > endtime_stamp then
            return false
        end
    end

    local cur_date_str = os.date("%Y-%m-%d",cur_time_stamp)
    for i, v in ipairs(self.values) do
        local date = self.strict and v.date or cur_date_str
        local target_time_str = string.format("%s-%s", date, v.duration)
        local year, month, day, hour_begain, min_begain, sec_begain, hour_end, min_end, sec_end = target_time_str:match("^(%d+)%D(%d+)%D(%d+)%D(%d+)%D(%d+)%D(%d+)%D(%d+)%D(%d+)%D(%d+)") 

        local begain_time_stamp = QuestDateCondition.GetTimeStamp(year, month, day, hour_begain, min_begain, sec_begain)
        local end_time_stamp = QuestDateCondition.GetTimeStamp(year, month, day, hour_end, min_end, sec_end)
        if cur_time_stamp >= begain_time_stamp and cur_time_stamp <= end_time_stamp then
            return true
        end
    end

    return false
end

function QuestDateCondition.GetTimeStamp(year, month, day, hour, min, sec)
    local time_stamp = os.time({day=tonumber(day), month=tonumber(month), year=tonumber(year), hour=tonumber(hour)})
    time_stamp = time_stamp + min * 60 + sec

    return time_stamp
end