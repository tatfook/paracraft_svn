--[[
Title: Sophie
Author(s): WangTian
Date: 2009/8/24

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/30081_Sophie.lua
------------------------------------------------------------
]]

-- create class
local libName = "Sophie";
local Sophie = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.Sophie", Sophie);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

-- Sophie.main
function Sophie.main()
	Sophie.RefreshStatus();
end

-- 50181_DoctorInauguralQuest_Accept
-- 50182_DoctorInauguralQuest_Complete

-- update the NPC quest status in quest area
function Sophie.RefreshStatus()
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	local equipGSItem = ItemManager.IfEquipGSItem;
	if(hasGSItem(50181) and not hasGSItem(50182)) then
		-- append accept quest
		MyCompany.Aries.Desktop.QuestArea.AppendQuestStatus(
			"script/apps/Aries/NPCs/Doctor/30081_Sophie_InauguralQuest_status.html",
			"medal", "", "我要成为一名医生", 50181);
	else
		-- delete quest status
		MyCompany.Aries.Desktop.QuestArea.DeleteQuestStatus(
			"script/apps/Aries/NPCs/Doctor/30081_Sophie_InauguralQuest_status.html"
			);
	end
end