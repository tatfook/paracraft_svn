--[[
Title: 30096_ExiledPanda
Author(s): LiXizhi
Date: 2010/1/4
Desc: 
use the lib:
------------------------------------------------------------
script/apps/Aries/NPCs/Playground/30096_ExiledPanda.lua
------------------------------------------------------------
]]

-- create class
local ExiledPanda = commonlib.gettable("MyCompany.Aries.Quest.NPCs.ExiledPanda");

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- ExiledPanda.main
function ExiledPanda.main()
end

function ExiledPanda.PreDialog()
	return true;
end