--[[
Title: 
Author(s): CYF
Date: 2013/03/21
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/DBServer/test/test.lua");
local pf = commonlib.gettable("DBServer.TableDAL.tests.pf");
pf.get("123123");
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/DBServer/DBSettings.lua");
NPL.load("(gl)script/apps/DBServer/TableDAL/DAL_mem_table.lua");
NPL.load("(gl)script/apps/DBServer/Entity/UserProfileEntity.lua");
NPL.load("(gl)script/apps/DBServer/Entity/PetEntity.lua");
NPL.load("(gl)script/apps/DBServer/TableDAL/TableDAL.lua");
NPL.load("(gl)script/apps/DBServer/BLL/UserBLL.lua");
NPL.load("(gl)script/apps/DBServer/BLL/GlobalStoreBLL.lua");
NPL.load("(gl)script/apps/DBServer/BLL/ServerObjectBLL.lua");

local UserProfileEntity = commonlib.gettable("DBServer.UserProfileEntity");
local PetEntity = commonlib.gettable("DBServer.PetEntity");
local DBSettings = commonlib.gettable("DBServer.DBSettings");
local TableDAL = commonlib.gettable("DBServer.TableDAL");
local GlobalStoreBLL = commonlib.gettable("DBServer.BLL.GlobalStoreBLL");
local ServerObjectBLL = commonlib.gettable("DBServer.BLL.ServerObjectBLL");

local DAL_mem_table = commonlib.gettable("DBServer.TableDAL.DAL_mem_table");

local UserBLL = commonlib.gettable("DBServer.BLL.UserBLL");

local pf = commonlib.gettable("DBServer.TableDAL.tests.pf");

local test = commonlib.gettable("DBServer.TableDAL.test");

NPL.load("(gl)script/apps/DBServer/BLL/InstanceBLL.lua");
local InstanceBLL = commonlib.gettable("DBServer.BLL.InstanceBLL");


function test.GS_get(gsid)
	local _gs = GlobalStoreBLL.get(gsid);
	LOG.std(nil, "warn", "test GS_get:", _gs);
end

function test.SO_get(key)
	local _so = ServerObjectBLL.get(key);
	LOG.std(nil, "warn", "test SO_get:", _so);
end

function test:getPF()
	if(not self.pf) then
		self.pf = DAL_mem_table:ctor({
			dbcnf = DBSettings.getCN("cn" .. DBSettings.dbIndex()),
			tbname = "userprofile",
			use_partition = true,
			entity_class = UserProfileEntity,
			primarykey_is_auto = false;
			primary_key = {"NID"},
			partition_key = "NID",
			keys = {}
		});
		TableDAL.Init();
	end
	return self.pf;
end


function test.userBLL_getByNID(pNID)
	--[[
	local _pf = test:getPF();
	UserBLL.getByNID(pNID, function(_pRe)
		LOG.std(nil, "warn", "DAL_mem_table:select", commonlib.serialize_compact(_pRe));
	end);
	]]

	local _pf = test:getPF();

	UserBLL.getByNID(pNID, function(_pRe)
		LOG.std(nil, "warn", "test userBLL.getByNID", commonlib.serialize_compact(_pRe));

		_pRe.Photo = "Hello World";

		UserBLL.update(_pRe, function(_pRe1)
			LOG.std(nil, "warn", "test userBLL.update", _pRe1);

			UserBLL.delete(_pRe, function(_pRe2)
				LOG.std(nil, "warn", "test userBLL.delete", _pRe2);
				--[[
				_pRe.Photo = "HaHaHaHaHa";
				UserBLL.insert(_pRe, function(_pRe3)
					LOG.std(nil, "warn", "test userBLL.insert", _pRe3);
				end);
				]]
			end);
		end);
	end);

	--[[
	local _row = {
					Photo="HaHaHaHaHa",EMoney="0",AccumMoDou="0",FirstName="",LastVote="2009-12-01 00:00:00",PMoney="0",RegisterArea="",
					Birthday="2013-04-17 16:35:48",Family="",NID="864",Introducer="-1",LastName="",Votes="",Nickname="a_864",Email="",
					ResetSecDt="2100-01-01 00:00:00",Gender="",SecPass="",SecPassVerify="2000-01-01 00:00:00",Popularity="0",SecAPt="",
				};
	UserBLL.insert(_row, function(_pRe)
		LOG.std(nil, "warn", "test userBLL.insert", _pRe);
	end);
	]]
end


function test.userBLL_setNName2(nid, newNName)
	local _pf = test:getPF();

	UserBLL.setNName2(nid, newNName, function(_re)
		LOG.std(nil, "warn", "test userBLL.setNName2", _re);
	end);
end


function test.InstanceBLL_get(nid, guid)
	local _pf = test:getPF();

	InstanceBLL.get(nid, guid, function(_re)
		LOG.std(nil, "warn", "test InstanceBLL.get", _re);
	end);
end


function test.InstanceBLL_getInBag(nid, bag)
	local _pf = test:getPF();

	InstanceBLL.getInBag(nid, bag, function(_re)
		LOG.std(nil, "warn", "test InstanceBLL.getInBag", _re);
	end);
end


function test.InstanceBLL_getMaxPositionInBag(nid, bag)
	local _pf = test:getPF();

	InstanceBLL.getMaxPositionInBag(nid, bag, function(_re)
		LOG.std(nil, "warn", "test InstanceBLL.getMaxPositionInBag", _re);
	end);
end
