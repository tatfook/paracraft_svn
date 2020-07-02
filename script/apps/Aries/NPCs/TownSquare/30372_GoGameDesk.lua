--[[
Title: GoGameDesk
Author(s): Leio
Date: 2010/02/01

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/TownSquare/30372_GoGameDesk.lua
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
-- create class
local libName = "GoGameDesk";
local GoGameDesk = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.GoGameDesk", GoGameDesk);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- GoGameDesk.main
function GoGameDesk.main()
end
function GoGameDesk.PreDialog(npc_id, instance)
	NPL.load("(gl)script/apps/Aries/NPCs/Commons/SingleExtend.lua");
	local msg = {
		req_num = 6,
		exID = 391,
		ex_name = "围棋桌",
	}
	MyCompany.Aries.Quest.NPCs.SingleExtend.RedLeafDoExtend(msg);
	return false;
end
