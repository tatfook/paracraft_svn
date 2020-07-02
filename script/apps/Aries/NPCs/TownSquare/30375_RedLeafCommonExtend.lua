--[[
Title: RedLeafCommonExtend
Author(s): Leio
Date: 2010/02/01

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/TownSquare/30375_RedLeafCommonExtend.lua
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
	NPL.load("(gl)script/apps/Aries/NPCs/Commons/SingleExtend.lua");
-- create class
local libName = "RedLeafCommonExtend";
local RedLeafCommonExtend = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.RedLeafCommonExtend", RedLeafCommonExtend);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

function RedLeafCommonExtend.ShowPanel()

end
-- RedLeafCommonExtend.main
function RedLeafCommonExtend.main()
end
--大抱熊公仔
function RedLeafCommonExtend.PreDialog_BigBearToy(npc_id, instance)
	local msg = {
		req_num = 3,
		exID = 290,
		ex_name = "大抱熊公仔",
	}
	MyCompany.Aries.Quest.NPCs.SingleExtend.RedLeafDoExtend(msg);
	return false;
end
--红衫木屏风
function RedLeafCommonExtend.PreDialog_FoldingScreen(npc_id, instance)
	local msg = {
		req_num = 4,
		exID = 348,
		ex_name = "红衫木屏风",
	}
	MyCompany.Aries.Quest.NPCs.SingleExtend.RedLeafDoExtend(msg);
	return false;
end
--布老虎
function RedLeafCommonExtend.PreDialog_TigerToy(npc_id, instance)
	local msg = {
		req_num = 4,
		exID = 347,
		ex_name = "布老虎",
	}
	MyCompany.Aries.Quest.NPCs.SingleExtend.RedLeafDoExtend(msg);
	return false;
end
--学者书架
function RedLeafCommonExtend.PreDialog_ScholarBookshelf(npc_id, instance)
	local msg = {
		req_num = 8,
		exID = 382,
		ex_name = "学者书架",
	}
	MyCompany.Aries.Quest.NPCs.SingleExtend.RedLeafDoExtend(msg);
	return false;
end
--围棋桌
function RedLeafCommonExtend.PreDialog_GoGameDesk(npc_id, instance)
	local msg = {
		req_num = 6,
		exID = 391,
		ex_name = "围棋桌",
	}
	MyCompany.Aries.Quest.NPCs.SingleExtend.RedLeafDoExtend(msg);
	return false;
end
--围棋凳
function RedLeafCommonExtend.PreDialog_GoGameStool(npc_id, instance)
	local msg = {
		req_num = 2,
		exID = 392,
		ex_name = "围棋凳",
	}
	MyCompany.Aries.Quest.NPCs.SingleExtend.RedLeafDoExtend(msg);
	return false;
end
--营地马灯
function RedLeafCommonExtend.PreDialog_CampLantern(npc_id, instance)
	local msg = {
		req_num = 4,
		exID = 404,
		ex_name = "营地马灯",
	}
	MyCompany.Aries.Quest.NPCs.SingleExtend.RedLeafDoExtend(msg);
	return false;
end
--鸟屋挂钟
function RedLeafCommonExtend.PreDialog_BirdWallclock(npc_id, instance)
	local msg = {
		req_num = 4,
		exID = 416,
		ex_name = "鸟屋挂钟",
	}
	MyCompany.Aries.Quest.NPCs.SingleExtend.RedLeafDoExtend(msg);
	return false;
end
--碎花布大抱熊
function RedLeafCommonExtend.PreDialog_DazzleRagBigBearToy(npc_id, instance)
	local msg = {
		req_num = 4,
		exID = 421,
		ex_name = "碎花布大抱熊",
	}
	MyCompany.Aries.Quest.NPCs.SingleExtend.RedLeafDoExtend(msg);
	return false;
end
--绿芽树状桌
function RedLeafCommonExtend.PreDialog_GreenStubTable(npc_id, instance)
	local msg = {
		req_num = 4,
		exID = 444,
		ex_name = "绿芽树状桌",
	}
	MyCompany.Aries.Quest.NPCs.SingleExtend.RedLeafDoExtend(msg);
	return false;
end
--绿芽树状凳
function RedLeafCommonExtend.PreDialog_GreenStubChair(npc_id, instance)
	local msg = {
		req_num = 2,
		exID = 445,
		ex_name = "绿芽树状凳",
	}
	MyCompany.Aries.Quest.NPCs.SingleExtend.RedLeafDoExtend(msg);
	return false;
end
--青蛙椅
function RedLeafCommonExtend.PreDialog_GreenFrogChair(npc_id, instance)
	local msg = {
		req_num = 4,
		exID = 442,
		ex_name = "青蛙椅",
	}
	MyCompany.Aries.Quest.NPCs.SingleExtend.RedLeafDoExtend(msg);
	return false;
end
--榕树茶几
function RedLeafCommonExtend.PreDialog_BanyanTeaTable(npc_id, instance)
	local msg = {
		req_num = 4,
		exID = 443,
		ex_name = "榕树茶几",
	}
	MyCompany.Aries.Quest.NPCs.SingleExtend.RedLeafDoExtend(msg);
	return false;
end
--三角玻璃桌
function RedLeafCommonExtend.PreDialog_TripleLegGlassShelf(npc_id, instance)
	local msg = {
		req_num = 6,
		exID = 468,
		ex_name = "三角玻璃桌",
	}
	MyCompany.Aries.Quest.NPCs.SingleExtend.RedLeafDoExtend(msg);
	return false;
end
--彩色蝴蝶丛
function RedLeafCommonExtend.PreDialog_ColorfulButterflyCluster(npc_id, instance)
	local msg = {
		req_num = 8,
		exID = 469,
		ex_name = "彩色蝴蝶丛",
	}
	MyCompany.Aries.Quest.NPCs.SingleExtend.RedLeafDoExtend(msg);
	return false;
end
--杂物架
function RedLeafCommonExtend.PreDialog_BathRack(npc_id, instance)
	local msg = {
		req_num = 6,
		exID = 479,
		ex_name = "杂物架",
	}
	MyCompany.Aries.Quest.NPCs.SingleExtend.RedLeafDoExtend(msg);
	return false;
end
--祈福灯
function RedLeafCommonExtend.PreDialog_BlessingLamp(npc_id, instance)
	local msg = {
		req_num = 8,
		exID = 490,
		ex_name = "祈福灯",
	}
	MyCompany.Aries.Quest.NPCs.SingleExtend.RedLeafDoExtend(msg);
	return false;
end