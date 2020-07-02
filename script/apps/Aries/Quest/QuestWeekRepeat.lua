--[[
Title: 
Author(s): Leio
Date: 2013/1/2
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Quest/QuestWeekRepeat.lua");
local QuestWeekRepeat = commonlib.gettable("MyCompany.Aries.Quest.QuestWeekRepeat");


NPL.load("(gl)script/apps/Aries/Quest/QuestWeekRepeat.lua");
local QuestWeekRepeat = commonlib.gettable("MyCompany.Aries.Quest.QuestWeekRepeat");
QuestWeekRepeat.Load("config/Aries/Quests_Teen/week_repeat.xml");
local id = 1;
local date = "2013-01-03";
local time = "16:30:10";
local r = QuestWeekRepeat.CanAccept(id,date,time);
echo(r);

NPL.load("(gl)script/apps/Aries/Quest/QuestWeekRepeat.lua");
local QuestWeekRepeat = commonlib.gettable("MyCompany.Aries.Quest.QuestWeekRepeat");
QuestWeekRepeat.Load("config/Aries/Quests_Teen/week_repeat.xml");
local id = 1;
local date = "2013-01-03";
local time = "16:24:00";
local now_date = "2013-01-04";
local now_time = "00:00:00";
local r = QuestWeekRepeat.CanClear(id,date,time,now_date,now_time)
echo("=============r");
echo(r);

NPL.load("(gl)script/apps/Aries/Quest/QuestWeekRepeat.lua");
local QuestWeekRepeat = commonlib.gettable("MyCompany.Aries.Quest.QuestWeekRepeat");
local date = ParaGlobal.GetDateFormat("yyyy-MM-dd")
--local date = "2013-01-03";
local week = 2;
QuestWeekRepeat.GetDateByWeek(date,week)
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/DateTime.lua");
NPL.load("(gl)script/apps/Aries/Quest/QuestTimeStamp.lua");
local QuestTimeStamp = commonlib.gettable("MyCompany.Aries.Quest.QuestTimeStamp");
NPL.load("(gl)script/apps/Aries/Scene/main.lua");
local Scene = commonlib.gettable("MyCompany.Aries.Scene");
NPL.load("(gl)script/ide/commonlib.lua");
local QuestWeekRepeat = commonlib.gettable("MyCompany.Aries.Quest.QuestWeekRepeat");
QuestWeekRepeat.templates = nil;
function QuestWeekRepeat.Load(filepath)
	if(not filepath)then return end
	local self = QuestWeekRepeat;
	if(self.templates)then
		return;
	end
	local xmlRoot = ParaXML.LuaXML_ParseFile(filepath);
	local node;
	local map = {};
	for node in commonlib.XPath.eachNode(xmlRoot, "/times/time") do
		local id = node.attr.id;
		local clear = node.attr.clear;
		local label = node.attr.label;
		id = tonumber(id);
		if(id and clear and id ~= 0)then
			map[id] = {
				id = id,
				clear = clear,
				label = label,
			};
		end 
	end
	self.templates = map;
end
--某个时间是否可以接受任务
--比较 周几 和 几点
function QuestWeekRepeat.CanAccept(id,date,time)
	id = tonumber(id);
	if(not id or not date or not time or not QuestWeekRepeat.templates)then
		return
	end
	local template = QuestWeekRepeat.templates[id];
	if(not template)then
		return
	end
	local year, month, day = string.match(date, "^(%d+)%-(%d+)%-(%d+)$");
	year = tonumber(year);
	month = tonumber(month);
	day = tonumber(day);
	local week_num = QuestTimeStamp.get_day_of_week(day, month, year);
	time = commonlib.timehelp.TimeStrToMill(time);

	local clear = template.clear;
	local clear_arr = commonlib.split(clear," ");
	local clear_strict = clear_arr[1] or "0";--是否严格比较周几 默认否
	local clear_week = clear_arr[2] or "0";--周几可以接任务 默认是每天任务
	local clear_time = clear_arr[3] or "00:00:00";--默认结算时间
	clear_strict = tonumber(clear_strict);
	clear_week = tonumber(clear_week);
	clear_time = commonlib.timehelp.TimeStrToMill(clear_time);

	if(clear_week == 0)then
		if(time >=clear_time)then
			return true
		end
	else
		if(clear_strict == 1)then
			if(week_num == clear_week and time >=clear_time)then
				return true
			end
		else
			if(week_num >= clear_week and time >=clear_time)then
				return true
			end
		end
	end
end
--时间是否已经过期
function QuestWeekRepeat.IsOutoff(id,date,time,now_date,now_time)
	id = tonumber(id);
	if(not id or not date or not time or not now_date or not now_time or not QuestWeekRepeat.templates)then
		return
	end
	local template = QuestWeekRepeat.templates[id];
	if(not template)then
		return
	end
	local time = commonlib.GetMillisecond_Date(date .. " " .. time);
	local day_time = commonlib.timehelp.TimeStrToMill(now_time);
	local now_time = commonlib.GetMillisecond_Date(now_date .. " " .. now_time);

	local duration = now_time - time;
	if(duration < 0 or date == now_date)then
		return
	end
	local year, month, day = string.match(now_date, "^(%d+)%-(%d+)%-(%d+)$");
	year = tonumber(year);
	month = tonumber(month);
	day = tonumber(day);
	local week_num = QuestTimeStamp.get_day_of_week(day, month, year);

	local clear = template.clear;
	local clear_arr = commonlib.split(clear," ");
	local clear_strict = clear_arr[1] or "0";--是否严格比较周几 默认否
	local clear_week = clear_arr[2] or "0";--周几可以接任务 默认是每天任务
	local clear_time = clear_arr[3] or "00:00:00";--默认结算时间
	clear_strict = tonumber(clear_strict);
	clear_week = tonumber(clear_week);
	clear_time = commonlib.timehelp.TimeStrToMill(clear_time);

	local is_outoff_week = QuestWeekRepeat.IsOutoffWeek(date,now_date,clear_week)

	if(clear_week == 0)then
		if(day_time >=clear_time)then
			return true
		end
	else
		if(clear_strict == 1)then
			if(is_outoff_week and week_num == clear_week and day_time >=clear_time)then
				return true
			end
		else
			if(is_outoff_week and day_time >=clear_time)then
				return true
			end
		end
	end
end
function QuestWeekRepeat.HasTemplate(id)
	id = tonumber(id);
	if(not id or not QuestWeekRepeat.templates)then return end
	local template = QuestWeekRepeat.templates[id];
	if(template)then
		return true,template;
	end
end
-- @param date:"yyyy-MM-dd"
function QuestWeekRepeat.days_str_since2000(date)
	local year, month, day = string.match(date, "^(%d+)%-(%d+)%-(%d+)$");
	year = tonumber(year);
	month = tonumber(month);
	day = tonumber(day);
	return commonlib.timehelp.days_since2000(year, month, day)
end
--根据任务完成的日期判断 是否过期
function QuestWeekRepeat.IsOutoffWeek(finished_date,now_date,week)
	now_date = now_date or ParaGlobal.GetDateFormat("yyyy-MM-dd");
	--local now = QuestWeekRepeat.GetDateByWeek(now_date,week);
	local finished = QuestWeekRepeat.GetDateByWeek(finished_date,week);
	local now_days = QuestWeekRepeat.days_str_since2000(now_date);
	local finished_days = QuestWeekRepeat.days_str_since2000(finished);
	local dur = now_days - finished_days;
	if(dur >= 7)then
		return true;
	end
end
--根据日期换算出本周week的日期
function QuestWeekRepeat.GetDateByWeek(date,week)
	if(not date or not week)then
		return
	end
	local year, month, day = string.match(date, "^(%d+)%-(%d+)%-(%d+)$");
	year = tonumber(year);
	month = tonumber(month);
	day = tonumber(day);
	local week_num = QuestTimeStamp.get_day_of_week(day, month, year);
	local shift_days = week - week_num;
	local result = commonlib.timehelp.get_next_date_str(date, shift_days,"%04d-%02d-%02d")
	return result;
end