--[[
Title: DutyList
Author(s): WangTian
Date: 2009/7/25

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Police/30002_DutyList.lua
------------------------------------------------------------
]]

-- create class
local libName = "DutyList";
local DutyList = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.DutyList", DutyList);

NPL.load("(gl)script/apps/Aries/Quest/NPCAIMemory.lua");

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- DutyList.main
function DutyList.main()
	-- 50003_StandGuardPost_DailyQuestAccept
	local gsObtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(50003);
	local bHas, guid = hasGSItem(50003)
	if(gsObtain and gsObtain.inday == 0 and bHas) then
		-- destroy the item if the quest is not obtained today
		ItemManager.DestroyItem(guid, 1, function() end);
	end
end

-- update the NPC quest status in quest area
function DutyList.RefreshStatus()
end

-- 50001_PoliceInauguralQuestAccept
-- 50002_PoliceInauguralQuestComplete

-- DutyList.PreDialog
function DutyList.PreDialog()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30002);
	
	if(not hasGSItem(50002)) then
		memory.dialog_state = 1;
	else
		-- 50003_StandGuardPost_DailyQuestAccept
		local gsObtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(50003);
		if(gsObtain and gsObtain.inday > 0 and not hasGSItem(50003)) then
			memory.dialog_state = 3;
			-- reward for diffenent medals
			if(hasGSItem(20008)) then
				memory.reward = 1800;
			elseif(hasGSItem(20007)) then
				memory.reward = 1200;
			elseif(hasGSItem(20006)) then
				memory.reward = 800;
			elseif(hasGSItem(20004)) then
				memory.reward = 500;
			else
				memory.reward = 400;
			end
		else
			memory.dialog_state = 2;
			
			--local i = DutyList.GetPostIndex();
			NPL.load("(gl)script/apps/Aries/NPCs/Police/30006_StandGuardPost.lua");
			memory.zonename = MyCompany.Aries.Quest.NPCs.StandGuardPost.GetPostZoneName();
			
			memory.zoneAssigned = true;
			
			---- accept the quest
			--ItemManager.PurchaseItem(50003, 1, function(msg) end, function() 
				--if(msg) then
					--log("+++++++Purchase 50003_StandGuardPost_DailyQuestAccept return: +++++++\n")
					--commonlib.echo(msg);
					--if(msg.issuccess == true) then
						---- refresh the foot steps
						--DutyList.RefreshFootSteps();
					--end
				--end
			--end);
		end
	end
    
	return true;
end
