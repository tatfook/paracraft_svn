--[[
NPL.load("(gl)script/apps/DBServer/BLL/GSCntInTimeSpanBLL.lua");
local GSCntInTimeSpanBLL = commonlib.gettable("DBServer.BLL.GSCntInTimeSpanBLL");
]]

NPL.load("(gl)script/apps/DBServer/TableDAL/DAL_router.lua");

local DAL_router = commonlib.gettable("DBServer.TableDAL.DAL_router");



local GSCntInTimeSpanBLL = commonlib.gettable("DBServer.BLL.GSCntInTimeSpanBLL");

GSCntInTimeSpanBLL.tbkey = "gscntints";



function GSCntInTimeSpanBLL.get(nid, gsid, callbackFun)
	DAL_router.select(GSCntInTimeSpanBLL.tbkey, {NID = nid, GSID = gsid}, callbackFun);
end