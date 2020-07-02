
local ItemStruct = commonlib.gettable("DBServer.ItemStruct");

function ItemStruct:new(id, cnt, serverData, clientData, isGreedy)
	local o = {
		id = id,
		cnt = cnt,
		serverData = serverData,
		clientData = clientData,
		IsGreedy = isGreedy
	};
	setmetatable(o, self);
    self.__index = self;
    
	return o;
end




local ItemAddStruct = commonlib.gettable("DBServer.ItemAddStruct");

function ItemAddStruct:new(gsid, class, subClass, bag, position, cnt, serverData, clientData)
	local o = {
		gsid = gsid,
		Class = class,
		subClass = subClass,
		bag = bag,
		position = position,
		cnt = cnt,
		serverData = serverData,
		clientData = clientData,
		guid = 0
	};
	setmetatable(o, self);
    self.__index = self;
    
	return o;
end