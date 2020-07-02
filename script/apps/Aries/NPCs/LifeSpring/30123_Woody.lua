--[[
Title: 30123_Woody
Author(s): WangTian
Date: 2009/8/27

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/LifeSpring/30123_Woody.lua
------------------------------------------------------------
]]

-- create class
local libName = "Woody";
local Woody = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.Woody", Woody);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- Woody.main
function Woody.main()
end

function Woody.PreDialog()
	local bean = MyCompany.Aries.Pet.GetBean();
	--if(bean) then
		--if(bean.health == 2)then
			--return true;
		--end
	--end
	
	local woody = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(30123);
	if(woody and woody:IsValid() == true) then
		--headon_speech.Speek(woody.name, headon_speech.GetBoldTextMCML("我是伍迪，曾经由于我的自私和疏忽，失去了我最心爱的抱抱龙，所以现在只有孤苦伶仃的一个人。"), 3, true);
		--return false;
		return true;
	end
end


-------------- schedule labazhou --------------

function Woody.GiveLaBaZhou()
	local i = Woody.GetDailyIndex();
	if(i == 1) then
		-- 203 LaBaZhou_WoodyReward_30082_YarnToy 
		ItemManager.ExtendedCost(203, nil, nil, function(msg)end, function(msg) 
			log("+++++++ Extended cost 203: LaBaZhou_WoodyReward_30082_YarnToy return: +++++++\n")
			commonlib.echo(msg);
		end, nil, nil, 12);
	elseif(i == 2) then
		-- 204 LaBaZhou_WoodyReward_30081_EdelweissCarpet 
		ItemManager.ExtendedCost(204, nil, nil, function(msg)end, function(msg) 
			log("+++++++ Extended cost 204: LaBaZhou_WoodyReward_30081_EdelweissCarpet return: +++++++\n")
			commonlib.echo(msg);
		end, nil, nil, 12);
	elseif(i == 3) then
		-- 205 LaBaZhou_WoodyReward_30080_SeaWeedIceLamp 
		ItemManager.ExtendedCost(205, nil, nil, function(msg)end, function(msg) 
			log("+++++++ Extended cost 205: LaBaZhou_WoodyReward_30080_SeaWeedIceLamp return: +++++++\n")
			commonlib.echo(msg);
		end, nil, nil, 12);
	end
end

function Woody.GiveLaBaZhouToday()
	-- 50252_WoodyRecvLaBaZhouToday
	local gsObtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(50252);
	if(gsObtain and gsObtain.inday == 1) then
		return true;
	else
		return false;
	end
end

function Woody.NotGiveLaBaZhouTodayAndHaveLaBaZhou()
	-- 17050_LaBaZhou
	if(not Woody.GiveLaBaZhouToday() and (hasGSItem(17050, 12))) then
		return true;
	else
		return false;
	end
end

function Woody.GetRandomRewardName()
	local i = Woody.GetDailyIndex();
	if(i == 1) then
		return "毛线娃娃";
	elseif(i == 2) then
		return "雪绒花地毯";
	elseif(i == 3) then
		return "海苔冰灯";
	end
end

function Woody.GetRandomRewardGSID()
	local i = Woody.GetDailyIndex();
	if(i == 1) then
		return 30082;
	elseif(i == 2) then
		return 30081;
	elseif(i == 3) then
		return 30080;
	end
end

function Woody.GetDailyIndex()
	local nid = System.App.profiles.ProfileManager.GetNID();
	local serverdate = MyCompany.Aries.Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
	serverdate = string.gsub(serverdate, "%D", "");
	local days = tonumber(serverdate);
	
	local i = math.mod(math.mod((days * nid), 2741), 3) + 1; -- 2741: the 400th prime number
	return i;
end