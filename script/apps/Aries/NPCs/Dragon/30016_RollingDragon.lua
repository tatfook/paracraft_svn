--[[
Title: RollingDragon
Author(s): WangTian
Date: 2009/7/30

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/30016_RollingDragon.lua
------------------------------------------------------------
]]

-- create class
local libName = "RollingDragon";
local RollingDragon = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.RollingDragon", RollingDragon);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

-- RollingDragon.main
function RollingDragon.main()
end

function RollingDragon.PreDialog()
	return true;
end