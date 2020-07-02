
NPL.load("(gl)script/apps/DBServer/Helper.lua");
NPL.load("(gl)script/apps/DBServer/BLL/GlobalStoreBLL.lua");
NPL.load("(gl)script/ide/Json.lua");

local Helper = commonlib.gettable("DBServer.Helper");
local GlobalStoreBLL = commonlib.gettable("DBServer.BLL.GlobalStoreBLL");

local InstanceEntity = commonlib.gettable("DBServer.InstanceEntity");


function InstanceEntity:new(o)
	o = o or {};
	setmetatable(o, self);
    self.__index = self;
    
	return o;
end


function InstanceEntity:clone(o)
	local new_obj = {
		GUID = tonumber(o.GUID),
        NID = tonumber(o.NID),
        GSID = tonumber(o.GSID),
        ObtainTime = o.ObtainTime,
        Bag = tonumber(o.Bag),
        Position = tonumber(o.Position),
        ClientData = o.ClientData,
        ServerData = o.ServerData,
        Copies = tonumber(o.Copies)
	};
	return self:new(new_obj);
end


function InstanceEntity:getGlobalStore()
	return GlobalStoreBLL.get(self.GSID);
end


function InstanceEntity:getIsBound()
	if(not Helper.String.isNullOrEmpty(self.ServerData)) then
		local jsonServerData = commonlib.Json.Encode(self.ServerData);
		return jsonServerData.bound == 1;
	end
	return false;
end