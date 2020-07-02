--[[
Title: 30095_AngieGranny
Author(s): LiXizhi
Date: 2010/1/4
Desc: 
use the lib:
------------------------------------------------------------
script/apps/Aries/NPCs/Playground/30095_AngieGranny.lua
------------------------------------------------------------
]]

-- create class
local AngieGranny = commonlib.gettable("MyCompany.Aries.Quest.NPCs.AngieGranny");

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- AngieGranny.main
function AngieGranny.main()
end

function AngieGranny.PreDialog()
	return true;
end