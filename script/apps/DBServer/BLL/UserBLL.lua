--[[
NPL.load("(gl)script/apps/DBServer/BLL/UserBLL.lua");
local UserBLL = commonlib.gettable("DBServer.BLL.UserBLL");
]]

NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/apps/DBServer/LocalCache.lua");
NPL.load("(gl)script/apps/DBServer/DBProvider.lua");
NPL.load("(gl)script/apps/DBServer/TableDAL/DAL_mem_table.lua");
NPL.load("(gl)script/apps/DBServer/DBSettings.lua");
NPL.load("(gl)script/ide/DateTime.lua");
NPL.load("(gl)script/apps/DBServer/Helper.lua");
NPL.load("(gl)script/apps/DBServer/ErrorCodes.lua");
NPL.load("(gl)script/apps/DBServer/TableDAL/DAL_router.lua");


local MemDB = commonlib.gettable("DBServer.TableDAL.DAL_mem_table");
local DBSettings = commonlib.gettable("DBServer.DBSettings");
local Helper = commonlib.gettable("DBServer.Helper");
local ErrorCodes = commonlib.gettable("DBServer.ErrorCodes");
local DAL_router = commonlib.gettable("DBServer.TableDAL.DAL_router");

local UserBLL = commonlib.gettable("DBServer.BLL.UserBLL");

UserBLL.tbkey = "userpf";



function UserBLL.getByNID(nid, callbackFun)
	--[[
	UserBLL.memdb:select({NID = nid}, function(_pRe)
		callbackFun(_pRe);
	end);
	]]

	DAL_router.select(UserBLL.tbkey, {NID = nid}, callbackFun);
end


function UserBLL.getByNIDs(nids, callbackFun)
	-- TODO:
end


function UserBLL.update(row, callbackFun)
	DAL_router.update(UserBLL.tbkey, row, callbackFun);
end


function UserBLL.delete(row, callbackFun)
	DAL_router.delete(UserBLL.tbkey, row, callbackFun);
end


function UserBLL.insert(row, callbackFun)
	DAL_router.insert(UserBLL.tbkey, row, callbackFun);
end


function UserBLL.addMoney(nid, pmoney, emoney, callbackFun)
	UserBLL.getByNID(nid, function(_pRe)
		if(_pRe) then
			if(_pRe.PMoney + pmoney >= 0 and _pRe.EMoney + emoney >= 0) then
				_pRe.PMoney = _pRe.PMoney + pmoney;
				_pRe.EMoney = _pRe.EMoney + emoney;
				--[[
				UserBLL.memdb:update(_pRe, function(_pRe1)
					callbackFun(_pRe1);
				end);
				]]

				-- DAL_router.update(UserBLL.tbkey, _pRe, callbackFun);

				UserBLL.update(_pRe, callbackFun);
			end
		end
	end);
end


function UserBLL.applyResetSecPass(nid, callbackFun)
	UserBLL.getByNID(nid, function(_pRe)
		if(_pRe) then
			local _now = os.date("*t");
			local _dt = commonlib.timehelp.get_next_date_str(string.format("%04d-%02d-%02d", _now.year, _now.month, _now.day), 7, "%04d-%02d-%02d");
			_pRe.ResetSecDt = _dt;
			--[[
			UserBLL.memdb:update(_pRe, function(_pRe1)
				callbackFun(0);
			end);
			]]

			--[[
			DAL_router.update(UserBLL.tbkey, _pRe, function(_pRe1)
				callbackFun(0);
			end);
			]]

			UserBLL.update(_pRe, function(_pRe1)
				callbackFun(0);
			end);
		else
			callbackFun(419);
		end
	end);
end



function UserBLL.checkSecPass(nid, callbackFun)
	UserBLL.getByNID(nid, function(_pRe)
		if(_pRe) then
			local _hasSecPass = Helper.String.isNullOrEmpty(_pRe.SecPass);
			callbackFun({issuccess=not _hasSecPass or Helper.DateTime.compare(Helper.DateTime.date(Helper.DateTime.parse(pRe.SecPassVerify)), Helper.DateTime.date(os.date("*t"))) == 0, hassecpass=_hasSecPass});
		else
			callbackFun({issuccess=false, hassecpass=false});
		end
	end);
end


-- callbackFun true 成功；false 失败
function UserBLL.setNName(nid, newNName, callbackFun)
	UserBLL.getByNID(nid, function(_pRe)
		if(_pRe) then
			_pRe.Nickname = newNName;
			--[[
			UserBLL.memdb:update(_pRe, function(_pRe1)
				callbackFun(_pRe1);
			end);
			]]

			-- DAL_router.update(UserBLL.tbkey, _pRe, callbackFun);

			UserBLL.update(_pRe, callbackFun);
		end
	end);
end

-- 青年版
-- callbackFun 494:newName太长了；427:已经设置过昵称了；0:成功
function UserBLL.setNName2(nid, newNName, callbackFun)
	if(string.len(newNName) <= 16) then
		UserBLL.getByNID(nid, function(_pf)
			if(_pf and Helper.String.isNullOrEmpty(_pf.Nickname)) then
				_pf.Nickname = newNName;
				--[[
				UserBLL.memdb:update(_pf, function(_pRe1)
					callbackFun(0);
				end);
				]]

				--[[
				DAL_router.update(UserBLL.tbkey, _pf, function(_pRe1)
					callbackFun(0);
				end);
				]]

				UserBLL.update(_pf, function(_pRe1)
					callbackFun(0);
				end);
			else
				callbackFun(ErrorCodes["条件不符"]);
			end
		end);
	else
		callbackFun(ErrorCodes["语法错误"]);
	end
end



function UserBLL.changeNName(nid, newNName, callbackFun)
	local _consumeM = DBSettings.changeNName_ConsumeM();
	if(string.len(newNName) <= 16) then
		-- TODO:
	end
end


function UserBLL.checkNName(nname)
	-- TODO:
end


