--[[
NPL.load("(gl)script/apps/DBServer/Entity/GSCntInTimeSpanEntity.lua");
local GSCntInTimeSpanEntity = commonlib.gettable("DBServer.GSCntInTimeSpanEntity");
]]

NPL.load("(gl)script/apps/DBServer/Helper.lua");
NPL.load("(gl)script/apps/DBServer/DBSettings.lua");

local Helper = commonlib.gettable("DBServer.Helper");
local DBSettings = commonlib.gettable("DBServer.DBSettings");


local GSCntInTimeSpanEntity = commonlib.gettable("DBServer.GSCntInTimeSpanEntity");

function GSCntInTimeSpanEntity:new(o)
	o = o or {};
	setmetatable(o, self);
    self.__index = self;
    
	if(not o.CntInDay) then
		o.CntInDay = 0;
	end
	if(not o.CntInWeek) then
		o.CntInWeek = 0;
	end
	if(not o.LastDate) then
		o.LastDate = Helper.DateTime.now();
	end

	return o;
end

function GSCntInTimeSpanEntity:clone(o)
	local new_obj = {
		NID = tonumber(o.NID);
        GSID = tonumber(o.GSID);
        CntInDay = tonumber(o.CntInDay);
        CntInWeek = tonumber(o.CntInWeek);
        LastDate = o.LastDate;
	};
	return self:new(new_obj);
end


function GSCntInTimeSpanEntity:isClearDay()
	return Helper.DateTime.compare(Helper.DateTime.date(Helper.DateTime.now()), Helper.DateTime.date(Helper.DateTime.parse(self.LastDate))) ~= 0;
end


function GSCntInTimeSpanEntity:isClearWeek()
	local _iStart = DBSettings.getWeekStart();
	local _dtToday = Helper.DateTime.date(Helper.DateTime.now());
	local _iDayOfWeek = Helper.DateTime.dayOfWeek(_dtToday);
	local _dtFirst = Helper.DateTime.addDays((_iDayOfWeek >= _iStart and (_iStart - _iDayOfWeek)) or -(_iDayOfWeek + 1 + (6 - _iStart)));
	return Helper.DateTime.compare(_dtFirst, self.LastDate) > 0;
end