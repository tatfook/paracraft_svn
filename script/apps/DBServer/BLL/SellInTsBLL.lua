--[[
NPL.load("(gl)script/apps/DBServer/BLL/SellInTsBLL.lua");
local SellInTsBLL = commonlib.gettable("DBServer.BLL.SellInTsBLL");
]]

NPL.load("(gl)script/apps/DBServer/Helper.lua");
NPL.load("(gl)script/apps/DBServer/TableDAL/DAL_router.lua");
NPL.load("(gl)script/apps/DBServer/Entity/SellInTsEntity.lua");

local Helper = commonlib.gettable("DBServer.Helper");
local DAL_router = commonlib.gettable("DBServer.TableDAL.DAL_router");
local SellInTsEntity = commonlib.gettable("DBServer.SellInTsEntity");


local SellInTsBLL = commonlib.gettable("DBServer.BLL.SellInTsBLL");


SellInTsBLL.tbkey = "sellInTs";


function SellInTsBLL.get(gsid, callbackFun)
	DAL_router.select(SellInTsBLL.tbkey, {GSID = gsid}, callbackFun);
end


function SellInTsBLL.gets(gsids, callbackFun)
	local _list, _len = {}, #(gsids);
	Helper.Array.forEach(gsids, function(_gsid)
			SellInTsBLL.get(_gsid, function(_T)
					_len = _len - 1;
					if(_T) then
						_list[#(_list) + 1] = _T;
					end
					if(_len <= 0) then
						callbackFun(_list);
					end
				end);
		end);
	-- TODO: get all in once
end


function SellInTsBLL.set(obj, callbackFun)
	SellInTsBLL.get(obj.GSID, function(_item)
			if(_item) then
				DAL_router.update(SellInTsBLL.tbkey, obj, callbackFun);
			else
				DAL_router.insert(SellInTsBLL.tbkey, obj, callbackFun);
			end
		end);
end