--[[
Title: Dancer
Author(s): WangTian
Date: 2009/8/1

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/FriendshipPark/30181_Dancer.lua
------------------------------------------------------------
]]

-- create class
local libName = "Dancer";
local Dancer = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.Dancer", Dancer);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

-- Dancer.main
function Dancer.main()
end

-- say level5 quest speech
-- @return: true if the doctor hasn't speak out the the final word
--			false if continue with the next dialog answer condition
function Dancer.PreDialog()
	return true;
end