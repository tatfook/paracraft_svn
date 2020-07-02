--[[
Title: 
Author(s): Leio
Date: 2010/12/13

use the lib:

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30415_GaGa.lua");
------------------------------------------------------------
]]

local GaGa = commonlib.gettable("MyCompany.Aries.Quest.NPCs.GaGa");

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;


function GaGa.main()
end
function GaGa.PreDialog()
end