--[[
Title: RecruitmentSign
Author(s): WangTian
Date: 2009/8/24

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/30083_RecruitmentSign.lua
------------------------------------------------------------
]]

-- create class
local libName = "RecruitmentSign";
local RecruitmentSign = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.RecruitmentSign", RecruitmentSign);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- RecruitmentSign.main
function RecruitmentSign.main()
	RecruitmentSign.RefreshStatus();
end

-- 50181_DoctorInauguralQuest_Accept
-- 50182_DoctorInauguralQuest_Complete

-- update the NPC quest status in quest area
function RecruitmentSign.RefreshStatus()
end

-- 50186_DoctorDialyReward_Counter
function RecruitmentSign.PreDialog()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30083);
	-- check for 50186_DoctorDialyReward_Counter daily obtain
	
	local gsObtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(50186);
	if(gsObtain and gsObtain.inday == 0) then
		if(equipGSItem(1072) and equipGSItem(1073) and equipGSItem(1074)) then
			if(hasGSItem(20013)) then
				memory.dialog_state = 6;
			elseif(hasGSItem(20012)) then
				memory.dialog_state = 5;
			elseif(hasGSItem(20011)) then
				memory.dialog_state = 4;
			elseif(hasGSItem(20010)) then
				memory.dialog_state = 3;
			else
				memory.dialog_state = 7;
			end
		else
			memory.dialog_state = 2;
		end
	else
		memory.dialog_state = 1;
	end
	return true;
end