--[[
NPL.load("(gl)script/apps/DBServer/BLL/ServerObjectBLL.lua");
local ServerObjectBLL = commonlib.gettable("DBServer.BLL.ServerObjectBLL");
]]

NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/apps/DBServer/LocalCache.lua");
NPL.load("(gl)script/apps/DBServer/DBProvider.lua");
NPL.load("(gl)script/apps/DBServer/Entity/ServerObjectEntity.lua");

local LocalCache = commonlib.gettable("DBServer.LocalCache");
local DBProvider = commonlib.gettable("DBServer.DBProvider");
local ServerObjectEntity = commonlib.gettable("DBServer.ServerObjectEntity");


NPL.load("(gl)script/apps/DBServer/BLL/ServerObjectBLL.lua");
local ServerObjectBLL = commonlib.gettable("DBServer.BLL.ServerObjectBLL");
ServerObjectBLL.EMoneyDiscount = "EMoneyDiscount";

ServerObjectBLL.dbProvider = DBProvider.getServerObject();


function ServerObjectBLL.getAll()
	local _list = LocalCache.get("svrobjs");
	if(not _list) then
		_list = {};
		local _all = ServerObjectBLL.dbProvider:get();
		if(_all) then
			for _i in pairs(_all) do
				local _item = _all[_i];
				_list[_item.Key] = _item;
			end
		end
	end
	return _list;
end


function ServerObjectBLL.get(key)
	local _list = ServerObjectBLL.getAll();
	if(_list) then
		return _list[key];
	end
	return nil;
end


function ServerObjectBLL.add(key, value)
	-- TODO:
end


function ServerObjectBLL.update(key, value)
	-- TODO:
end


function ServerObjectBLL.delete(key)
	-- TODO:
end