--[[
Title: IceStoneGate
Author(s): WangTian
Date: 2009/8/25

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/SnowArea/30274_IceStoneGate.lua
------------------------------------------------------------
]]

-- create class
local libName = "IceStoneGate";
local IceStoneGate = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.IceStoneGate", IceStoneGate);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- IceStoneGate.main
function IceStoneGate.main()
end
