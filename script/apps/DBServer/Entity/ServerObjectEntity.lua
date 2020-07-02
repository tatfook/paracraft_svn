--[[
NPL.load("(gl)script/apps/DBServer/Entity/ServerObjectEntity.lua");
local ServerObjectEntity = commonlib.gettable("DBServer.ServerObjectEntity");
]]

local ServerObjectEntity = commonlib.gettable("DBServer.ServerObjectEntity");


function ServerObjectEntity:new(key, value)
	local _o = {
		Key = key,
		Value = value
	};
	setmetatable(_o, self);
    self.__index = self;
    return _o;
end