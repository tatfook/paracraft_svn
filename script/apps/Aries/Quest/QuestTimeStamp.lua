--[[
Title: 
Author(s): Leio
Date: 2012/3/19
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Quest/QuestTimeStamp.lua");
local QuestTimeStamp = commonlib.gettable("MyCompany.Aries.Quest.QuestTimeStamp");
QuestTimeStamp.Load("config/Aries/Quests/time_stamp.xml");
local id = "3";
commonlib.echo(QuestTimeStamp.IsValidDate(id,"2012-03-19"));
commonlib.echo(QuestTimeStamp.IsValidDate(id,"2012-03-19","13:10:10"));
commonlib.echo(QuestTimeStamp.IsValidDate(id,"2012-05-30"));
commonlib.echo(QuestTimeStamp.IsValidDate(id,"2012-05-30","13:10:10"));
commonlib.echo(QuestTimeStamp.IsValidDate(id,"2012-06-05"));
commonlib.echo(QuestTimeStamp.IsValidDate(id,"2012-06-05","13:10:10"));

commonlib.echo(QuestTimeStamp.IsValidDate(id,"2012-03-20"));
commonlib.echo(QuestTimeStamp.IsValidDate(id,"2012-03-20","13:10:10"));
commonlib.echo(QuestTimeStamp.IsValidDate(id,"2012-06-26"));
commonlib.echo(QuestTimeStamp.IsValidDate(id,"2012-06-26","13:10:10"));

NPL.load("(gl)script/apps/Aries/Quest/QuestTimeStamp.lua");
local QuestTimeStamp = commonlib.gettable("MyCompany.Aries.Quest.QuestTimeStamp");
local id = 0;
local template = QuestTimeStamp.templates[id];
commonlib.echo(template);
NPL.load("(gl)script/apps/Aries/Quest/QuestTimeStamp.lua");
local QuestTimeStamp = commonlib.gettable("MyCompany.Aries.Quest.QuestTimeStamp");
QuestTimeStamp.GetClientDateTime()
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Scene/main.lua");
local Scene = commonlib.gettable("MyCompany.Aries.Scene");
NPL.load("(gl)script/ide/commonlib.lua");
local QuestTimeStamp = commonlib.gettable("MyCompany.Aries.Quest.QuestTimeStamp");
QuestTimeStamp.templates = nil;
--[[
------------------------------xml convert to table
<time id="1">
		<weekly week="1" open="00:00:00" close="24:00:00" />
		<date year="2012" month="5" day="30" open="00:00:00" close="24:00:00" />
		<daterange year="2012" month="5" from="1" to="30" open="00:00:00" close="24:00:00" />
</time>

local time_stamp = {
	["1"] = {
		["week1"] = { open="00:00:00", close="24:00:00" },
		["date_2012_5_30"] = { open="00:00:00", close="24:00:00" },
		["daterange_2012_5_1_to_30"] = { year=2012, month=5, from=1, to=30, open="00:00:00", close="24:00:00" },
	},
}
------------------------------
--]]
function QuestTimeStamp.Load(filepath)
	if(not filepath)then return end
	local self = QuestTimeStamp;
	if(self.templates)then
		return;
	end
	local xmlRoot = ParaXML.LuaXML_ParseFile(filepath);
	local node;
	local map = {};
	for node in commonlib.XPath.eachNode(xmlRoot, "/times/time") do
		local id = node.attr.id;
		if(id)then
			local node_map = {};
			map[tonumber(id)] = node_map;
			local weekly_node;
			for weekly_node in commonlib.XPath.eachNode(node, "/weekly") do
				local week = weekly_node.attr.week;
				local open = weekly_node.attr.open or "00:00:00";
				local close = weekly_node.attr.close  or "24:00:00";
				if(week)then
					local key = string.format("week%s",week);
					node_map[key] = {open = open, close = close};
				end
			end
			local date_node;
			for date_node in commonlib.XPath.eachNode(node, "/date") do
				local year = date_node.attr.year;
				local month = date_node.attr.month;
				local day = date_node.attr.day;
				local open = date_node.attr.open or "00:00:00";
				local close = date_node.attr.close  or "24:00:00";
				year = tonumber(year);
				month = tonumber(month);
				day = tonumber(day);
				if(year and month and day)then
					local key = string.format("date_%d_%d_%d",year,month,day);
					node_map[key] = {open = open, close = close};
				end
			end
			local daterange_node;
			for daterange_node in commonlib.XPath.eachNode(node, "/daterange") do
				local year = daterange_node.attr.year;
				local month = daterange_node.attr.month;
				local from = daterange_node.attr.from;
				local to = daterange_node.attr.to;
				local open = daterange_node.attr.open or "00:00:00";
				local close = daterange_node.attr.close  or "24:00:00";
				year = tonumber(year);
				month = tonumber(month);
				from = tonumber(from);
				to = tonumber(to);
				if(year and month and from and to)then
					local key = string.format("daterange_%d_%d_%d_to_%d",year,month,from,to);
					node_map[key] = {isrange = true,year = year, month = month, from = from, to = to, open = open, close = close};
				end
			end
		end 
	end
	self.templates = map;
end
--检测是否是一个有效时间
--@param id:the id of time template
--@param date:date format is "yyyy-MM-dd"
--@param time:time format is "HH:mm:ss",can be nil,default value is "00:00:00"
function QuestTimeStamp.IsValidDate(id,date,time)
	local self = QuestTimeStamp;
	id = tonumber(id);
	if(not id or not date)then return end
	time = time or "00:00:00"
	local template = QuestTimeStamp.templates[id];
	if(template)then
		local function include_time(node,time)
			if(node)then
				local open = commonlib.timehelp.TimeStrToMill(node.open) or 0;
				local close = commonlib.timehelp.TimeStrToMill(node.close) or 0;
				time = commonlib.timehelp.TimeStrToMill(time) or 0;
				if(time >= open and time <= close)then
					return true;
				end
			end
		end
		local year, month, day = string.match(date, "^(%d+)%-(%d+)%-(%d+)$");
		year = tonumber(year);
		month = tonumber(month);
		day = tonumber(day);
		--check weekly
		local week_num = QuestTimeStamp.get_day_of_week(day, month, year);
		local key = string.format("week%d",week_num);
		local node = template[key];
		if(node)then
			return include_time(node,time);
		end
		--check date
		local key = string.format("date_%d_%d_%d",year,month,day);
		local node = template[key];
		if(node)then
			return include_time(node,time);
		end
		--check date range
		local k,v;
		for k,v in pairs(template) do
			if(v.isrange)then
				local _year = v.year;
				local _month = v.month;
				local from = v.from;
				local to = v.to;
				if(year == _year and month == _month and day >= from and day <= to)then
					return include_time(v,time);
				end
			end
		end
	end
end
function QuestTimeStamp.HasTemplate(id)
	local self = QuestTimeStamp;
	id = tonumber(id);
	if(not id or not self.templates)then return end
	local template = self.templates[id];
	if(template)then
		return true;
	end
end

local days = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" }
local map = {
	[1] = 7,
	[2] = 1,
	[3] = 2,
	[4] = 3,
	[5] = 4,
	[6] = 5,
	[7] = 6,
}
--根据日期返回周几
--return 1(周一),"Mon"
--[[
NPL.load("(gl)script/apps/Aries/Quest/QuestTimeStamp.lua");
local QuestTimeStamp = commonlib.gettable("MyCompany.Aries.Quest.QuestTimeStamp");
local week_num,week_str = QuestTimeStamp.get_day_of_week(19, 3, 2012);
commonlib.echo({week_num,week_str});
--]]
function QuestTimeStamp.get_day_of_week(dd, mm, yy) 
	local mmx = mm
	if (mm == 1) then  mmx = 13; yy = yy-1  end
	if (mm == 2) then  mmx = 14; yy = yy-1  end
	local val8 = dd + (mmx*2) +  math.floor(((mmx+1)*3)/5)   + yy + math.floor(yy/4)  - math.floor(yy/100)  + math.floor(yy/400) + 2
	local val9 = math.floor(val8/7)
	local dw = val8-(val9*7) 

	if (dw == 0) then
		dw = 7
	end
	return map[dw],days[dw];
end

--@param date:"yyyy-MM-dd"
function QuestTimeStamp.GetWeek(date) 
	if(not date)then return end
	local year, month, day = string.match(date, "^(%d+)%-(%d+)%-(%d+)$");
	year = tonumber(year);
	month = tonumber(month);
	day = tonumber(day);
	local week_num = QuestTimeStamp.get_day_of_week(day, month, year);
	return week_num;
end
--获取本地时间 返回格式为:"yyyy-MM-dd","HH:mm:ss"
function QuestTimeStamp.GetClientDateTime()
	if(System.options.isAB_SDK)then
		local date = ParaGlobal.GetDateFormat("yyyy-MM-dd")
		local time = ParaGlobal.GetTimeFormat("H:mm:ss");
		return date,time;
	end
	local date = Scene.GetServerDate();
	local seconds = Scene.GetElapsedSecondsSince0000() or 0;
	local time = commonlib.timehelp.MillToTimeStr(seconds*1000,"h-m-s");
	return date,time;
end

function QuestTimeStamp.GetServerDate()
	return ParaGlobal.GetDateFormat("yyyy-MM-dd")
end

function QuestTimeStamp.GetServerWeek()
	local date = ParaGlobal.GetDateFormat("yyyy-MM-dd")
	local year, month, day = string.match(date, "^(%d+)%-(%d+)%-(%d+)$");
	year = tonumber(year);
	month = tonumber(month);
	day = tonumber(day);
	local week_num = QuestTimeStamp.get_day_of_week(day, month, year);
	return week_num,date;
end