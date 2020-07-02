--[[
Title: 30124_AnamnesisCrystal
Author(s): WangTian
Date: 2009/8/27

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/LifeSpring/30124_AnamnesisCrystal.lua
------------------------------------------------------------
]]

-- create class
local libName = "AnamnesisCrystal";
local AnamnesisCrystal = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.AnamnesisCrystal", AnamnesisCrystal);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- AnamnesisCrystal.main
function AnamnesisCrystal.main()
end

function AnamnesisCrystal.PreDialog()
end