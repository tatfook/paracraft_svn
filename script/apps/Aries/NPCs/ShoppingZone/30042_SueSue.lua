--[[
Title: SueSue
Author(s): WangTian
Date: 2009/7/30

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/ShoppingZone/30042_SueSue.lua
------------------------------------------------------------
]]

-- create class
local libName = "SueSue";
local SueSue = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.SueSue", SueSue);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- SueSue.main
function SueSue.main()
end


-------------- schedule labazhou --------------

function SueSue.GiveLaBaZhou()
	-- 1150_MasqueGlass
	if(not hasGSItem(1150)) then
		-- 206 LaBaZhou_SuesueReward_1150_MasqueGlass 
		ItemManager.ExtendedCost(206, nil, nil, function(msg)end, function(msg) 
			log("+++++++ Extended cost 206: LaBaZhou_SuesueReward_1150_MasqueGlass return: +++++++\n")
			commonlib.echo(msg);
		end, nil, nil, 12);
	else
		-- 207 LaBaZhou_SuesueReward_17029_CrystalRock 
		ItemManager.ExtendedCost(207, nil, nil, function(msg)end, function(msg) 
			log("+++++++ Extended cost 207: LaBaZhou_SuesueReward_17029_CrystalRock return: +++++++\n")
			commonlib.echo(msg);
		end, nil, nil, 12);
	end
end

function SueSue.GiveLaBaZhouToday()
	-- 50253_SuesueRecvLaBaZhouToday
	local gsObtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(50253);
	if(gsObtain and gsObtain.inday == 1) then
		return true;
	else
		return false;
	end
end

function SueSue.NotGiveLaBaZhouTodayAndHaveLaBaZhou()
	-- 17050_LaBaZhou
	if(not SueSue.GiveLaBaZhouToday() and (hasGSItem(17050, 12))) then
		return true;
	else
		return false;
	end
end

--function SueSue.GetRandomRewardName()
	---- 1150_MasqueGlass
	--if(not hasGSItem(1150)) then
		--return "一个星光眼镜";
	--end
	--return "三个晶晶石";
--end


-------------- schedule Carnation --------------

function SueSue.GiveCarnation()
	local i = SueSue.GetDailyIndex();
	if(i == 1) then
		-- 355 Carnation_SuesueReward_17082_CatchingNet_Level3 
		ItemManager.ExtendedCost(355, nil, nil, function(msg)end, function(msg) 
			log("+++++++ Extended cost 355: Carnation_SuesueReward_17082_CatchingNet_Level3 return: +++++++\n")
			commonlib.echo(msg);
		end, nil, nil, 12);
	elseif(i == 2) then
		-- 356 Carnation_SuesueReward_17029_CrystalRock 
		ItemManager.ExtendedCost(356, nil, nil, function(msg)end, function(msg) 
			log("+++++++ Extended cost 356: Carnation_SuesueReward_17029_CrystalRock return: +++++++\n")
			commonlib.echo(msg);
		end, nil, nil, 12);
	end
end

function SueSue.GiveCarnationToday()
	-- 50279_SuesueRecvCarnationToday
	local gsObtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(50279);
	if(gsObtain and gsObtain.inday == 1) then
		return true;
	else
		return false;
	end
end

function SueSue.NotGiveCarnationTodayAndHaveCarnation()
	-- 17085_CollectableCarnation
	if(not SueSue.GiveCarnationToday() and (hasGSItem(17085, 12))) then
		return true;
	else
		return false;
	end
end

function SueSue.GetRandomRewardName()
	local i = SueSue.GetDailyIndex();
	if(i == 1) then
		return "3级捕兽网";
	elseif(i == 2) then
		return "5颗晶晶石";
	end
end

function SueSue.GetRandomRewardGSID()
	local i = SueSue.GetDailyIndex();
	if(i == 1) then
		return 17082;
	elseif(i == 2) then
		return 17029;
	end
end

function SueSue.GetDailyIndex()
	local nid = System.App.profiles.ProfileManager.GetNID();
	local serverdate = MyCompany.Aries.Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
	serverdate = string.gsub(serverdate, "%D", "");
	local days = tonumber(serverdate);
	
	local i = math.mod(math.mod((days * nid), 2287), 2) + 1; -- 2287: the 340th prime number
	return i;
end
function SueSue.CanShow()
	return (hasGSItem(50019) and not hasGSItem(50020));
end