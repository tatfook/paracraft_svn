--[[
Title: 30125_ReviveElixar
Author(s): WangTian
Date: 2009/8/27

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/LifeSpring/30125_ReviveElixar.lua
------------------------------------------------------------
]]

-- create class
local libName = "ReviveElixar";
local ReviveElixar = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.ReviveElixar", ReviveElixar);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- ReviveElixar.main
function ReviveElixar.main()
end

function ReviveElixar.PreDialog()
end