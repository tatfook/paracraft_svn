--[[
Title: combat system combat unit server for Aries App
Author(s): WangTian
Date: 2012/12/2
Area: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Combat/ServerObject/unit_server.lua");
------------------------------------------------------------
]]

local format = format;
-- create class
local libName = "AriesCombat_Server_Unit";
local Unit = commonlib.gettable("MyCompany.Aries.Combat_Server.Unit");

-- combat server
local combat_server = commonlib.gettable("MyCompany.Aries.Combat_Server.combat_server");
-- card server
local Card = commonlib.gettable("MyCompany.Aries.Combat_Server.Card");
-- arena class
local Arena = commonlib.gettable("MyCompany.Aries.Combat_Server.Arena");
-- player server object
local Player = commonlib.gettable("MyCompany.Aries.Combat_Server.Player");
-- mob server object
local Mob = commonlib.gettable("MyCompany.Aries.Combat_Server.Mob");

NPL.load("(gl)script/kids/3DMapSystemItem/PowerItemManager.lua");
local PowerItemManager = commonlib.gettable("Map3DSystem.Item.PowerItemManager");

function Unit:GetType()
	return "unit";
end

function Unit.GetUnit()
	return "getunit";
end