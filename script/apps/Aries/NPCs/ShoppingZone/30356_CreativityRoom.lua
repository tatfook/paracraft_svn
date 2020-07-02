--[[
Title: CreativityRoom
Author(s): WangTian
Date: 2009/8/13

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/ShoppingZone/30356_CreativityRoom.lua
------------------------------------------------------------
]]

-- create class
local libName = "CreativityRoom";
local CreativityRoom = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.CreativityRoom", CreativityRoom);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

-- CreativityRoom.main
function CreativityRoom.main()
end

function CreativityRoom.PreDialog_CreativityRoom()
	NPL.load("(gl)script/apps/Aries/Creator/CreateOpenWorld.lua");
	MyCompany.Aries.Creator.CreateOpenWorld.ShowPage();
	return false;
end