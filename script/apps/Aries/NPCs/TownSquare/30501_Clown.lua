--[[
Title: 
Author(s): Leio
Company:
Date: 2010/09/30

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/TownSquare/30501_Clown.lua
------------------------------------------------------------
]]

-- create class
local libName = "Clown";
local Clown = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.Clown", Clown);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

function Clown.main()
end
function Clown.PreDialog()
end