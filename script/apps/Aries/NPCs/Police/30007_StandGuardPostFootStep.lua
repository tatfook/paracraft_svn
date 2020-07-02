--[[
Title: StandGuardPostFootStep
Author(s): WangTian
Date: 2009/7/30

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/30007_StandGuardPostFootStep.lua
------------------------------------------------------------
]]

-- create class
local libName = "StandGuardPostFootStep";
local StandGuardPostFootStep = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.StandGuardPostFootStep", StandGuardPostFootStep);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- StandGuardPostFootStep.main
function StandGuardPostFootStep.main()
end