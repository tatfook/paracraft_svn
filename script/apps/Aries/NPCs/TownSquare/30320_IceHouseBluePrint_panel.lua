--[[
Title: IceHouseBluePrint_panel
Author(s): Leio
Date: 2009/12/22

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/TownSquare/30320_IceHouseBluePrint_panel.lua
------------------------------------------------------------
]]

-- create class
local libName = "IceHouseBluePrint_panel";
local IceHouseBluePrint_panel = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.IceHouseBluePrint_panel", IceHouseBluePrint_panel);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;








