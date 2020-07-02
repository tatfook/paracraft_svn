NPL.load("(gl)script/ide/mysql/mysql.lua");

NPL.load("(gl)script/apps/DBServer/DBSettings.lua");
NPL.load("(gl)script/apps/DBServer/DataAccess.lua");
NPL.load("(gl)script/apps/DBServer/Entity/ServerObjectEntity.lua");

local luasql = commonlib.luasql;

local DataAccess = commonlib.gettable("DBServer.DataAccess");
local ServerObjectEntity = commonlib.gettable("DBServer.ServerObjectEntity");

local MySqlServerObjectProvider = commonlib.inherit(DataAccess, commonlib.gettable("DBServer.DAL.MySqlServerObjectProvider"));

function MySqlServerObjectProvider:getListFromReader(reader)
	local _list = {};
	for _i in pairs(reader.list) do
		local _row = reader.list[_i];
		table.insert(_list, ServerObjectEntity:new(_row.Key, _row.Value));
	end
end

function MySqlServerObjectProvider.getFromRow(row)
	return ServerObjectEntity:new(row.Key, row.Value);
end


function MySqlServerObjectProvider:add(key, value)
	-- TODO:
end


function MySqlServerObjectProvider:update(key, value)
	-- TODO:
end

function MySqlServerObjectProvider:delete(key, value)
	-- TODO:
end

function MySqlServerObjectProvider:get()
	local _con = self:getConnection_Items();
	
	if(not _con) then
		commonlib.log("_con is null");
	else
		if(not _con.cn) then
			commonlib.log("_con.cn is null");
		end
	end
	
	local _list = self:execReader(_con.cn, "select * from serverobject", MySqlServerObjectProvider.getFromRow);
	_con.cn:close();
	_con.env:close();
	return _list;
end