--[[
Title: Mocha
Author(s): WangTian
Date: 2009/7/30

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/ShoppingZone/30151_Mocha.lua
------------------------------------------------------------
]]

-- create class
local libName = "Mocha";
local Mocha = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.Mocha", Mocha);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- Mocha.main
function Mocha.main()
end
function Mocha.CanShow()
	local hasHouse = MyCompany.Aries.Quest.NPCs.DongDong.HasNaturalHouse();
    local num = MyCompany.Aries.Quest.NPCs.DongDong.GetNaturalCrystal();
    if(not hasHouse)then
        if(num == 2 or num == 3 or ( hasGSItem(50042) and not hasGSItem(50043) ) )then
            return true;
        end
    end
end