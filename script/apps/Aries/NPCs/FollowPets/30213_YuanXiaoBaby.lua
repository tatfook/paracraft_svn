--[[
Title: YuanXiaoBaby
Author(s): WangTian
Date: 2009/8/25

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/FollowPets/30213_YuanXiaoBaby.lua
------------------------------------------------------------
]]

-- create class
local libName = "YuanXiaoBaby";
local YuanXiaoBaby = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.YuanXiaoBaby", YuanXiaoBaby);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;


local delete_after_spawn_time = 60000;
local last_spawn_time = nil;

-- YuanXiaoBaby.main
function YuanXiaoBaby.main()
	
	last_spawn_time = ParaGlobal.GetGameTime();
	
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30213);
	if(memory.nRealBabyInstance == nil) then
		-- set the real yuanxiao baby npc instance
		local r = math.random(0, 300);
		if(r <= 100) then
			memory.nRealBabyInstance = 1;
		elseif(r <= 200) then
			memory.nRealBabyInstance = 2;
		elseif(r <= 300) then
			memory.nRealBabyInstance = 3;
		end
	end
	
	-- 17083_TinyColorPaper
	-- 17084_ColouredGlaze
	if(memory.missReward == nil) then
		--17078_NewYearCoupon
		memory.missReward = 17078;
		memory.missRewardCount = 1;
		---- set guess miss reward
		--local r = math.random(0, 100);
		--if(r <= 50) then
			--memory.missReward = 17083;
			--memory.nRewardCount = 2;
		--elseif(r <= 100) then
			--memory.missReward = 17084;
			--memory.nRewardCount = 2;
		--end
	end
	
	-- 16045_ColorPill_Green
	-- 16046_ColorPill_Purple
	-- 16047_ColorPill_Red
	-- 16048_ColorPill_Orange
	-- 16049_ColorPill_DarkLava
	-- 16050_ColorPill_DarkBlood
	if(memory.hitReward == nil) then
		--17078_NewYearCoupon
		memory.hitReward = 17078;
		memory.hitRewardCount = 2;
		---- set guess hit reward
		--local r = math.random(0, 1000);
		--if(r <= 200) then
			--memory.hitReward = 16045;
			--memory.nRewardCount = 1;
		--elseif(r <= 400) then
			--memory.hitReward = 16046;
			--memory.nRewardCount = 1;
		--elseif(r <= 600) then
			--memory.hitReward = 16047;
			--memory.nRewardCount = 1;
		--elseif(r <= 800) then
			--memory.hitReward = 16048;
			--memory.nRewardCount = 1;
		--elseif(r <= 900) then
			--memory.hitReward = 16049;
			--memory.nRewardCount = 1;
		--elseif(r <= 1000) then
			--memory.hitReward = 16050;
			--memory.nRewardCount = 1;
		--end
	end
end

-- YuanXiaoBaby.On_Timer
function YuanXiaoBaby.On_Timer()
	-- remove all yuanxiao baby if exceeding 1 minutes
	if(last_spawn_time and (ParaGlobal.GetGameTime() - last_spawn_time) > delete_after_spawn_time) then
		YuanXiaoBaby.RemoveAllYuanXiaoBaby()
		last_spawn_time = nil;
	end
end

-- quest speech
-- @return: false if speak the headon speech
--			true if continue with the next dialog answer condition
function YuanXiaoBaby.PreDialog(npc_id, instance)
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30213);
	-- this is tricky to use the isFirstTalk field indicating if it is the first talk to the yuanxiao baby
	-- NOTE: NPC memory will be reset on yuanxiao baby creation
	if(memory.isFirstTalk == nil) then
		memory.isFirstTalk = true;
		-- show the invisible yuanxiao baby
		local i;
		for i = 1, 3 do
			local baby = NPC.GetNpcCharacterFromIDAndInstance(30213, i);
			if(baby and baby:IsValid() == true) then
				baby:SetVisible(true);
			end
		end
	elseif(memory.isFirstTalk == true) then
		-- the next time user talk to the NPC it will set the isFirstTalk to false
		memory.isFirstTalk = false;
		if(YuanXiaoBaby.IsFakeBaby(instance)) then
			memory.missorhit = "miss";
		else
			memory.missorhit = "hit";
		end
	end
	
	return true;
end

function YuanXiaoBaby.IsFirstTalk()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30213);
	-- this is tricky to use the isFirstTalk field indicating if it is the first talk to the yuanxiao baby
	-- NOTE: NPC memory will be reset on yuanxiao baby creation
	if(memory.isFirstTalk == true) then
		return true;
	else
		return false;
	end
end

function YuanXiaoBaby.IsFakeBaby(instance)
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30213);
	if(instance and instance == memory.nRealBabyInstance) then
		return false;
	else
		return true;
	end
end

function YuanXiaoBaby.IsTalkToFakeBaby()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30213);
	if(memory.missorhit == "miss") then
		return true;
	elseif(memory.missorhit == "hit") then
		return false;
	end
	return true;
end

function YuanXiaoBaby.IfOwnYuanXiaoBaby()
	-- 10129_YuanXiaoBaby
	if(hasGSItem(10129)) then
		return true;
	end
	return false;
end

function YuanXiaoBaby.ClearFakeBaby()
	YuanXiaoBaby.RemoveFakeYuanXiaoBaby(true); -- true for bSkipDeselect
	-- clear riddle answer memory
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30261); --  riddle memory
	memory.LastLightupTimes = {};
end

function YuanXiaoBaby.TalkToRealBaby()
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30213);
	if(memory.nRealBabyInstance) then
		local targetNPC_id = MyCompany.Aries.Desktop.TargetArea.TargetNPC_id;
		local targetNPC_instance = MyCompany.Aries.Desktop.TargetArea.TargetNPC_instance;
		if(targetNPC_instance ~= memory.nRealBabyInstance) then
			MyCompany.Aries.Desktop.TargetArea.TalkToNPC(30213, memory.nRealBabyInstance, true);
		end
	end
end

function YuanXiaoBaby.GetMissReward()
	--local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30213);
	---- 17078_NewYearCoupon
	---- 17083_TinyColorPaper
	---- 17084_ColouredGlaze
	--local exid;
	--if(memory.missReward == 17083) then
		--exid = 325;
	--elseif(memory.missReward == 17083) then
		--exid = 326;
	--end
	--
	--if(exid) then
		--ItemManager.ExtendedCost(exid, nil, nil, function() 
			--log("+++++++ YuanXiaoBabyReward: "..exid.." return: +++++++\n")
			--commonlib.echo(msg);
			--YuanXiaoBaby.RemoveAllYuanXiaoBaby();
		--end);
	--end
	
	-- 17078_NewYearCoupon
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30213);
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(memory.missReward);
	local maxDailyCount = tonumber(gsItem.maxdailycount);
	ItemManager.PurchaseItem(memory.missReward, memory.missRewardCount, function(msg)
		log("+++++++ YuanXiaoBabyMissReward return: +++++++\n")
		commonlib.echo(msg);
		if(msg.issuccess == true) then
			YuanXiaoBaby.RemoveAllYuanXiaoBaby();
		elseif(msg.issuccess == false and msg.errorcode == 428) then
			local s = string.format("每天最多获得%d张<pe:item gsid='%d' style='width:32px;height:32px;' isclickable='false'/>，改天再来找我玩吧！",maxDailyCount,memory.hitReward);
			_guihelper.MessageBox(s);
			YuanXiaoBaby.RemoveAllYuanXiaoBaby();
		else
			_guihelper.MessageBox("获得"..gsItem.template..name.."失败，快去报告镇长！");
			YuanXiaoBaby.RemoveAllYuanXiaoBaby();
		end
	end, function(msg) end, nil, nil);
end

function YuanXiaoBaby.GetHitReward()
	-- 17078_NewYearCoupon
	local memory = MyCompany.Aries.Quest.NPCAIMemory.GetMemory(30213);
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(memory.hitReward);
	local maxDailyCount = tonumber(gsItem.maxdailycount);
	ItemManager.PurchaseItem(memory.hitReward, memory.hitRewardCount, function(msg)
		log("+++++++ YuanXiaoBabyHitReward return: +++++++\n")
		commonlib.echo(msg);
		if(msg.issuccess == true) then
			YuanXiaoBaby.RemoveAllYuanXiaoBaby();
		elseif(msg.issuccess == false and msg.errorcode == 428) then
			local s = string.format("每天最多获得%d张<pe:item gsid='%d' style='width:32px;height:32px;' isclickable='false'/>，改天再来找我玩吧！",maxDailyCount,memory.hitReward);
			_guihelper.MessageBox(s);
			YuanXiaoBaby.RemoveAllYuanXiaoBaby();
		else
			_guihelper.MessageBox("获得"..gsItem.template..name.."失败，快去报告镇长！");
			YuanXiaoBaby.RemoveAllYuanXiaoBaby();
		end
	end, function(msg) end, nil, nil);
end

function YuanXiaoBaby.TakeBabyHome()
	-- 10129_YuanXiaoBaby
	ItemManager.PurchaseItem(10129, 1, function(msg)
		if(msg.issuccess == true) then
			MyCompany.Aries.Desktop.TargetArea.ShowTarget("");
			YuanXiaoBaby.RemoveAllYuanXiaoBaby();
		end
	end, function(msg) end, nil, nil);
end

function YuanXiaoBaby.RemoveFakeYuanXiaoBaby()
	local i = 1;
	for i = 1, 3 do
		if(YuanXiaoBaby.IsFakeBaby(i)) then
			-- delete the fake yuanxiao baby if exist
			local baby = NPC.GetNpcCharacterFromIDAndInstance(30213, i);
			if(baby and baby:IsValid() == true) then
				NPC.DeleteNPCCharacter(30213, i);
			end
		end
	end
end

function YuanXiaoBaby.RemoveAllYuanXiaoBaby()
	local i = 1;
	for i = 1, 3 do
		-- delete all yuanxiao baby if exist
		local baby = NPC.GetNpcCharacterFromIDAndInstance(30213, i);
		if(baby and baby:IsValid() == true) then
			NPC.DeleteNPCCharacter(30213, i);
		end
	end
end
