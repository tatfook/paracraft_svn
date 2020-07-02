--[[
Title: GoGameStool
Author(s): Leio
Date: 2010/02/01

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/TownSquare/30373_GoGameStool.lua
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
-- create class
local libName = "GoGameStool";
local GoGameStool = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.GoGameStool", GoGameStool);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- GoGameStool.main
function GoGameStool.main()
end
function GoGameStool.PreDialog(npc_id, instance)
	NPL.load("(gl)script/apps/Aries/NPCs/Commons/SingleExtend.lua");
	local msg = {
		req_num = 2,
		exID = 392,
		ex_name = "围棋凳",
	}
	MyCompany.Aries.Quest.NPCs.SingleExtend.RedLeafDoExtend(msg);
	return false;
end

