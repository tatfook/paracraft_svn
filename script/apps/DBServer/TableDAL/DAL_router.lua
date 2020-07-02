--[[
Title: handle update insert query
Author: LiXizhi
Date: 2013/2/20
Desc: 
-----------------------------------------------
NPL.load("(gl)script/apps/DBServer/TableDAL/DAL_router.lua");
local DAL_router = commonlib.gettable("DBServer.TableDAL.DAL_router");
-----------------------------------------------
]]

NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/apps/DBServer/DBSettings.lua");
NPL.load("(gl)script/apps/DBServer/Entity/UserProfileEntity.lua");
NPL.load("(gl)script/apps/DBServer/Entity/InstanceEntity.lua");
NPL.load("(gl)script/apps/DBServer/Entity/SellInTsEntity.lua");
NPL.load("(gl)script/apps/DBServer/Entity/GSCntInTimeSpanEntity.lua");
NPL.load("(gl)script/apps/DBServer/TableDAL/TableDAL.lua");
NPL.load("(gl)script/apps/DBServer/TableDAL/DAL_mem_table.lua");

local DBSettings = commonlib.gettable("DBServer.DBSettings");
local UserProfileEntity = commonlib.gettable("DBServer.UserProfileEntity");
local InstanceEntity = commonlib.gettable("DBServer.InstanceEntity");
local SellInTsEntity = commonlib.gettable("DBServer.SellInTsEntity");
local GSCntInTimeSpanEntity = commonlib.gettable("DBServer.GSCntInTimeSpanEntity");
local TableDAL = commonlib.gettable("DBServer.TableDAL");
local MemDB = commonlib.gettable("DBServer.TableDAL.DAL_mem_table");

local DAL_router = commonlib.gettable("DBServer.TableDAL.DAL_router");

DAL_router.dbIndex = DBSettings.getDBIndex();

DAL_router.localMemdb = {};

DAL_router.localMemdb.userpf = MemDB:ctor({
			dbcnf = DBSettings.getCN("cn" .. DAL_router.dbIndex),
			tbname = "userprofile",
			use_partition = true,
			entity_class = UserProfileEntity,
			primarykey_is_auto = false;
			primary_key = {"NID"},
			partition_key = "NID",
			keys = {},
			funDbIndex = function(_pSelf, _pObj)
				return math.floor(math.mod(_pObj["NID"], DBSettings.getTBCnt()) / DBSettings.getDBCnt());
			end
		});

DAL_router.localMemdb.instance = MemDB:ctor({
			dbcnf = DBSettings.getCN("cn" .. DAL_router.dbIndex),
			tbname = "instance",
			use_partition = true,
			entity_class = InstanceEntity,
			primarykey_is_auto = true;
			primary_key = {"GUID", "NID"},
			partition_key = "NID",
			keys = {
				{type="multiple", cols={"NID", "Bag"}},
				{type="multiple", cols={"NID", "GSID"}}
			},
			funDbIndex = function(_pSelf, _pObj)
				return math.floor(math.mod(_pObj["NID"], DBSettings.getTBCnt()) / DBSettings.getDBCnt());
			end
		});

DAL_router.localMemdb.gscntints = MemDB:ctor({
			dbcnf = DBSettings.getCN("cn" .. DAL_router.dbIndex),
			tbname = "gscntintimespan",
			use_partition = true,
			entity_class = GSCntInTimeSpanEntity,
			primarykey_is_auto = true;
			primary_key = {"NID", "GSID"},
			partition_key = "NID",
			keys = {},
			funDbIndex = function(_pSelf, _pObj)
				return math.floor(math.mod(_pObj["NID"], DBSettings.getTBCnt()) / DBSettings.getDBCnt());
			end
		});


DAL_router.localMemdb.sellInTs = MemDB:ctor({
			dbcnf = DBSettings.getCN("mySQLItems"),
			tbname = "sellgscntintimespan",
			use_partition = false,
			entity_class = SellInTsEntity,
			primarykey_is_auto = false;
			primary_key = {"GSID"},
			partition_key = nil,
			keys = {},
			funDbIndex = function(_pSelf, _pObj)
				return -1;
			end
		});

--[[
function DAL_router.isLocalDB(pTbKey, pObj)
	local _memdb = DAL_router.localMemdb[pTbKey];
	if(_memdb) then
		if(_memdb.funDbIndex ~= nil) then
			return _memdb.funDbIndex(pObj) == DAL_router.dbIndex;
		end
	end
	return false;
end
]]

function DAL_router.select(pTbKey, pCommand, funCallback)
	local _memdb = DAL_router.localMemdb[pTbKey];
	if(_memdb) then
		local _islocal = false;
		if(_memdb.funDbIndex) then
			_islocal = _memdb:funDbIndex(pCommand) == DAL_router.dbIndex;
		else
			_islocal = true;
		end

		if(_islocal) then
			_memdb:select(pCommand, funCallback);
		else
			-- TODO: send to another dbserver
		end
	else
		LOG.std(nil, "warn", "DAL_router:select", "illegal tbkey : " .. pTbKey);
		funCallback(nil);
	end
end

function DAL_router.update(pTbKey, pCommand, funCallback)
	local _memdb = DAL_router.localMemdb[pTbKey];
	if(_memdb) then
		local _islocal = false;
		if(_memdb.funDbIndex) then
			_islocal = _memdb:funDbIndex(pCommand) == DAL_router.dbIndex;
		else
			_islocal = true;
		end

		if(_islocal) then
			_memdb:update(pCommand, funCallback);
		else
			-- TODO: send to another dbserver
		end
	else
		LOG.std(nil, "warn", "DAL_router:update", "illegal tbkey : " .. pTbKey);
		funCallback(nil);
	end
end


function DAL_router.delete(pTbKey, pCommand, funCallback)
	local _memdb = DAL_router.localMemdb[pTbKey];
	if(_memdb) then
		local _islocal = false;
		if(_memdb.funDbIndex) then
			_islocal = _memdb:funDbIndex(pCommand) == DAL_router.dbIndex;
		else
			_islocal = true;
		end

		if(_islocal) then
			_memdb:delete(pCommand, funCallback);
		else
			-- TODO: send to another dbserver
		end
	else
		LOG.std(nil, "warn", "DAL_router:update", "illegal tbkey : " .. pTbKey);
		funCallback(nil);
	end
end


function DAL_router.insert(pTbKey, pCommand, funCallback)
	local _memdb = DAL_router.localMemdb[pTbKey];
	if(_memdb) then
		local _islocal = false;
		if(_memdb.funDbIndex) then
			_islocal = _memdb:funDbIndex(pCommand) == DAL_router.dbIndex;
		else
			_islocal = true;
		end

		if(_islocal) then
			_memdb:insert(pCommand, funCallback);
		else
			-- TODO: send to another dbserver
		end
	else
		LOG.std(nil, "warn", "DAL_router:update", "illegal tbkey : " .. pTbKey);
		funCallback(nil);
	end
end


function DAL_router.SendRequest()
end

function DAL_router.OnFrameMove()
end