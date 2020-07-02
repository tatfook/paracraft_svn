--[[
NPL.load("(gl)script/apps/DBServer/TableDAL/DAL_handler.lua");
local DAL_handler = commonlib.gettable("DBServer.TableDAL.DAL_handler");
]]

NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/apps/DBServer/DBSettings.lua");

local DBSettings = commonlib.gettable("DBServer.DBSettings");

local DAL_handler = commonlib.gettable("DBServer.TableDAL.DAL_handler");

DAL_handler.dbIndex = DBSettings.dbIndex();

