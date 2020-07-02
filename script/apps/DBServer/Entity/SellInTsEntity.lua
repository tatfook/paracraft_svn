--[[
NPL.load("(gl)script/apps/DBServer/Entity/SellInTsEntity.lua");
local SellInTsEntity = commonlib.gettable("DBServer.SellInTsEntity");
]]

NPL.load("(gl)script/apps/DBServer/Helper.lua");
NPL.load("(gl)script/apps/DBServer/BLL/GlobalStoreBLL.lua");

local Helper = commonlib.gettable("DBServer.Helper");
local GlobalStoreBLL = commonlib.gettable("DBServer.BLL.GlobalStoreBLL");

local SellInTsEntity = commonlib.gettable("DBServer.SellInTsEntity");

function SellInTsEntity:new(o)
	o = o or {};
	setmetatable(o, self);
    self.__index = self;
    
	return o;
end

function SellInTsEntity:clone(o)
	local new_obj = {
		GSID = tonumber(o.GSID);
        InDay = tonumber(InDay);
        InHour = tonumber(InHour);
        LastUpdate = LastUpdate;
	};
	return self:new(new_obj);
end


function SellInTsEntity:isClearInDay()
	return Helper.DateTime.compare(Helper.DateTime.date(Helper.DateTime.parse(self.LastUpdate)), Helper.DateTime.date(Helper.DateTime.now())) ~= 0;
end


function SellInTsEntity:isClearInHour()
	return self:isClearInDay() or
			Helper.DateTime.parse(self.LastUpdate).hour ~= Helper.DateTime.now().hour;
end