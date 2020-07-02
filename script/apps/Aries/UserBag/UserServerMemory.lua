--[[
Title: 
Author(s): leio
Date: 2012/08/21
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/UserBag/UserServerMemory.lua");
local UserServerMemory = commonlib.gettable("MyCompany.Aries.Inventory.UserServerMemory");
]]
NPL.load("(gl)script/apps/Aries/UserBag/UserMemoryTable.lua");
local UserMemoryTable = commonlib.gettable("MyCompany.Aries.Inventory.UserMemoryTable");
NPL.load("(gl)script/apps/Aries/UserBag/UserServerMemory.lua");
local UserServerMemory = commonlib.gettable("MyCompany.Aries.Inventory.UserServerMemory");
UserServerMemory.providers = {};
function UserServerMemory.DoInit_Server(nid,version)
	
end
function UserServerMemory.SetData(nid,msg)
	
end