--[[
Title: Tutu
Author(s): WangTian
Date: 2009/8/25

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/RockyForest/30127_Tutu.lua
------------------------------------------------------------
]]

-- create class
local libName = "Tutu";
local Tutu = {
	page_state = nil, --0 or 1
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.Tutu", Tutu);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- Tutu.main
function Tutu.main()
	Tutu.page_state = 0;
	Tutu.RefreshStatusState()
end

function Tutu.PreDialog(npc_id, instance)
	return true;
end
--是否与涂涂对话过
function Tutu.IsDialoged()
	return hasGSItem(50274);
end
--是否完成任务
function Tutu.IsFinished()
	return hasGSItem(50275);
end
--是否找齐12生肖
function Tutu.IsFindAll()
	local has = ItemManager.IfOwnGSItem;
	return has(10117) and has(10118) and has(10119) and has(10120) and has(10121) and has(10122) and has(10123) and has(10124) and has(10125) and has(10126) and has(10127) and has(10128);
end
--标记对话过
function Tutu.GiveDialogTag()
	if(not hasGSItem(50274))then
		ItemManager.PurchaseItem(50274, 1, function(msg) end, function(msg)
	        if(msg) then
		        log("+++++++Purchase 50274_TalkedWithTutu return: +++++++\n")
		        commonlib.echo(msg);
		        Tutu.RefreshStatusState()
	        end
        end,nil,"none");
	end
end
--兑换
function Tutu.DoExchange()
	ItemManager.ExtendedCost(317, nil, nil, function(msg)end, function(msg) 
			log("+++++++ Extended cost 317: TutuReward_PirateSuit return: +++++++\n")
			commonlib.echo(msg);
			Tutu.RefreshStatusState()
	end);
end
function Tutu.RefreshStatusState()
	--if(Tutu.IsDialoged() and not Tutu.IsFinished()) then
		--local QuestArea = MyCompany.Aries.Desktop.QuestArea;
		--QuestArea.AppendQuestStatus("script/apps/Aries/NPCs/RockyForest/30127_Tutu_status.html", 
			--"normal", "Texture/Aries/Quest/Props/Tutu_32bits.png;0 0 80 75", "捕捉12生肖宠物", nil, 40, nil);
	--else
		---- hide the save gucci quest icon
		--local QuestArea = MyCompany.Aries.Desktop.QuestArea;
		--QuestArea.DeleteQuestStatus("script/apps/Aries/NPCs/RockyForest/30127_Tutu_status.html");
	--end
end
function Tutu.CanShow()
	if(Tutu.IsDialoged() and not Tutu.IsFinished()) then
		return true;
	end
end
function Tutu.ShowStatus()
	NPL.load("(gl)script/apps/Aries/Desktop/QuestArea.lua");
	MyCompany.Aries.Desktop.QuestArea.ShowNormalQuestStatus("script/apps/Aries/NPCs/RockyForest/30127_Tutu_status.html");
end
-------------- schedule Carnation --------------

function Tutu.GiveCarnation()
	local i = Tutu.GetDailyIndex();
	if(i == 1) then
		-- 359 Carnation_TutuReward_16035_TransformPill_Tiger 
		ItemManager.ExtendedCost(359, nil, nil, function(msg)end, function(msg) 
			log("+++++++ Extended cost 359: Carnation_TutuReward_16035_TransformPill_Tiger return: +++++++\n")
			commonlib.echo(msg);
		end, nil, nil, 12);
	elseif(i == 2) then
		-- 360 Carnation_TutuReward_16037_TransformPill_Dragon 
		ItemManager.ExtendedCost(360, nil, nil, function(msg)end, function(msg) 
			log("+++++++ Extended cost 360: Carnation_TutuReward_16037_TransformPill_Dragon return: +++++++\n")
			commonlib.echo(msg);
		end, nil, nil, 12);
	elseif(i == 3) then
		-- 361 Carnation_TutuReward_16032_TransformPill_Ostrich 
		ItemManager.ExtendedCost(361, nil, nil, function(msg)end, function(msg) 
			log("+++++++ Extended cost 361: Carnation_TutuReward_16032_TransformPill_Ostrich return: +++++++\n")
			commonlib.echo(msg);
		end, nil, nil, 12);
	end
end

function Tutu.GiveCarnationToday()
	-- 50281_TutuRecvCarnationToday
	local gsObtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(50281);
	if(gsObtain and gsObtain.inday == 1) then
		return true;
	else
		return false;
	end
end

function Tutu.NotGiveCarnationTodayAndHaveCarnation()
	-- 17085_CollectableCarnation
	if(not Tutu.GiveCarnationToday() and (hasGSItem(17085, 12))) then
		return true;
	else
		return false;
	end
end

function Tutu.GetRandomRewardName()
	local i = Tutu.GetDailyIndex();
	if(i == 1) then
		return "虎变身药丸";
	elseif(i == 2) then
		return "龙变身药丸";
	elseif(i == 3) then
		return "鸵鸟变身药丸";
	end
end

function Tutu.GetRandomRewardGSID()
	local i = Tutu.GetDailyIndex();
	if(i == 1) then
		return 16035;
	elseif(i == 2) then
		return 16037;
	elseif(i == 3) then
		return 16032;
	end
end

function Tutu.GetDailyIndex()
	local nid = System.App.profiles.ProfileManager.GetNID();
	local serverdate = MyCompany.Aries.Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
	serverdate = string.gsub(serverdate, "%D", "");
	local days = tonumber(serverdate);
	
	local i = math.mod(math.mod((days * nid), 2129), 3) + 1; -- 2129: the 320th prime number
	return i;
end