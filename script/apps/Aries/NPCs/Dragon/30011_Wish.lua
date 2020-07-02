--[[
Title: DragonWish
Author(s): WangTian
Date: 2009/7/28

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/30011_Wish.lua
------------------------------------------------------------
]]

-- create class
local libName = "DragonWish";
local DragonWish = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.DragonWish", DragonWish);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;
local NPCs = MyCompany.Aries.Quest.NPCs;

-- DragonWish.main
function DragonWish.main()
	
	-- NOTE: 2010/10/2 all quests are temparorily disabled
	do return end

	if(DragonWish.isInit) then
		return;
	end
	DragonWish.isInit = true;
	
	-- TODO: sync the files in this folder before successive calls
	NPL.load("(gl)script/apps/Aries/NPCs/Dragon/30011_WishLevel0.lua");
	NPCs.WishLevel0.main();
	NPL.load("(gl)script/apps/Aries/NPCs/Dragon/30011_WishLevel1.lua");
	NPCs.WishLevel1.main();
	NPL.load("(gl)script/apps/Aries/NPCs/Dragon/30011_WishLevel2.lua");
	NPCs.WishLevel2.main();
	NPL.load("(gl)script/apps/Aries/NPCs/Dragon/30011_WishLevel3.lua");
	NPCs.WishLevel3.main();
	--NPL.load("(gl)script/apps/Aries/NPCs/Dragon/30011_WishLevel3_combat.lua");
	--NPCs.WishLevel3_combat.main();
	NPL.load("(gl)script/apps/Aries/NPCs/Dragon/30011_WishLevel4.lua");
	NPCs.WishLevel4.main();
	NPL.load("(gl)script/apps/Aries/NPCs/Dragon/30011_WishLevel5.lua");
	NPCs.WishLevel5.main();
	NPL.load("(gl)script/apps/Aries/NPCs/Dragon/30011_WishLevel6.lua");
	NPCs.WishLevel6.main();
	NPL.load("(gl)script/apps/Aries/NPCs/Dragon/30011_WishLevel7.lua");
	NPCs.WishLevel7.main();
	NPL.load("(gl)script/apps/Aries/NPCs/Dragon/30011_WishLevel8.lua");
	NPCs.WishLevel8.main();
	NPL.load("(gl)script/apps/Aries/NPCs/Dragon/30011_WishLevel9.lua");
	NPCs.WishLevel9.main();
	NPL.load("(gl)script/apps/Aries/NPCs/Dragon/30011_WishLevel10.lua");
	NPCs.WishLevel10.main();
	NPL.load("(gl)script/apps/Aries/NPCs/Dragon/30011_WishLevel12.lua");
	NPCs.WishLevel12.main();
	
	-- schedule 2009/12/11
	--NPL.load("(gl)script/apps/Aries/NPCs/Dragon/091211/CookForElk.lua");
	--NPCs.CookForElk.main();
	
	-- schedule 2009/12/18
	--NPL.load("(gl)script/apps/Aries/NPCs/Dragon/091218/WishForSnowman.lua");
	--NPCs.WishForSnowman.main();
	--NPL.load("(gl)script/apps/Aries/NPCs/Dragon/091218/TakeElkHome.lua");
	--NPCs.TakeElkHome.main();
	--NPL.load("(gl)script/apps/Aries/NPCs/Dragon/091218/SpecialChristmasGift.lua");
	--NPCs.SpecialChristmasGift.main();
	--NPL.load("(gl)script/apps/Aries/NPCs/Dragon/091218/KnitChirstmasSock.lua");
	--NPCs.KnitChirstmasSock.main();
	
	-- schedule 2009/12/25
	--NPL.load("(gl)script/apps/Aries/NPCs/Dragon/091225/SnowShooting.lua");
	--NPCs.SnowShooting.main();
	NPL.load("(gl)script/apps/Aries/NPCs/Dragon/091225/BuildIceHouse.lua");
	NPCs.BuildIceHouse.main();
	
	---- schedule 2010/01/08
	--NPL.load("(gl)script/apps/Aries/NPCs/Dragon/100108/WishingLamp.lua");
	--NPCs.WishForWishingLamp.main();
	
	---- schedule 2010/01/15
	--NPL.load("(gl)script/apps/Aries/NPCs/Dragon/100115/CookLaBaZhou.lua");
	--NPCs.CookLaBaZhou.main();
	
	-- schedule 2010/03/26
	NPL.load("(gl)script/apps/Aries/NPCs/Dragon/100326/OddEggGift.lua");
	NPCs.OddEggGift.main();
	
	---- deprecated
	--NPL.load("(gl)script/apps/Aries/NPCs/Dragon/30011_WishRandom1.lua");
	--NPCs.WishRandom1.main();
	
	NPL.load("(gl)script/apps/Aries/NPCs/Dragon/Homeland/HomelandSeries.lua");
	NPCs.HomelandSeries.main();
	NPL.load("(gl)script/apps/Aries/NPCs/Dragon/Food/FoodSeries.lua");
	NPCs.FoodSeries.main();
	NPL.load("(gl)script/apps/Aries/NPCs/Dragon/Game/GameSeries.lua");
	NPCs.GameSeries.main();
	NPL.load("(gl)script/apps/Aries/NPCs/Dragon/FollowPet/FollowPetSeries.lua");
	NPCs.FollowPetSeries.main();

	--if(true)then return; end

	local Pet = MyCompany.Aries.Pet;
	if(Pet.IsMyDragonFetchedFromSophie()) then
		DragonWish.RefreshStatus();
	end
end

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

local PickRandomQuestTime = nil;
local isPickRandomQuest = false;
local lastGameTime = 0;

function DragonWish.PickRandomQuest()

	if(System.App.MiniGames.AntiIndulgence.IsAntiSystemIsEnabled()) then
		return;
	end
	
	local Pet = MyCompany.Aries.Pet;
	if(not Pet.IsMyDragonFetchedFromSophie()) then
		return;
	end
	local petLevel = 0;
	-- get pet level
	local bean = MyCompany.Aries.Pet.GetBean();
	if(bean) then
		petLevel = bean.level or 0;
		--if(bean.health == 2) then
			---- don't receive quest notification if the dragon is dead
			--return;
		--end
	end
	-- TODO: pick on random quest
	-- random quest 1
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
	local ran = math.random(0, 3600) or 0;
	
	local HomelandSeries = MyCompany.Aries.Quest.NPCs.HomelandSeries;
	local FoodSeries = MyCompany.Aries.Quest.NPCs.FoodSeries;
	local GameSeries = MyCompany.Aries.Quest.NPCs.GameSeries;
	local FollowPetSeries = MyCompany.Aries.Quest.NPCs.FollowPetSeries;
	
	-- 50141 ~ 50144 : homeland series
	if(ran <= 100 and HomelandSeries.CanAcquireQuest(1)) then
		HomelandSeries.AcquireQuest(1);
	elseif(ran <= 200 and HomelandSeries.CanAcquireQuest(2)) then
		HomelandSeries.AcquireQuest(2);
	elseif(ran <= 300 and HomelandSeries.CanAcquireQuest(3)) then
		HomelandSeries.AcquireQuest(3);
	elseif(ran <= 400 and HomelandSeries.CanAcquireQuest(4)) then
		HomelandSeries.AcquireQuest(4);
	elseif(ran <= 500 and HomelandSeries.CanAcquireQuest(5)) then
		HomelandSeries.AcquireQuest(5);
	elseif(ran <= 600 and HomelandSeries.CanAcquireQuest(6)) then
		HomelandSeries.AcquireQuest(6);
	elseif(ran <= 700 and HomelandSeries.CanAcquireQuest(7)) then
		HomelandSeries.AcquireQuest(7);
	-- 50151 ~ 150157 : food series
	elseif(ran <= 800 and petLevel >= 2 and FoodSeries.CanAcquireQuest(1)) then
		FoodSeries.AcquireQuest(1);
	elseif(ran <= 900 and petLevel >= 2 and FoodSeries.CanAcquireQuest(2)) then
		FoodSeries.AcquireQuest(2);
	elseif(ran <= 1000 and petLevel >= 2 and FoodSeries.CanAcquireQuest(3)) then
		FoodSeries.AcquireQuest(3);
	elseif(ran <= 1100 and FoodSeries.CanAcquireQuest(4)) then
		FoodSeries.AcquireQuest(4);
	elseif(ran <= 1200 and FoodSeries.CanAcquireQuest(5)) then
		FoodSeries.AcquireQuest(5);
	elseif(ran <= 1300 and FoodSeries.CanAcquireQuest(6)) then
		FoodSeries.AcquireQuest(6);
	elseif(ran <= 1400 and FoodSeries.CanAcquireQuest(7)) then
		FoodSeries.AcquireQuest(7);
	elseif(ran <= 1500 and FoodSeries.CanAcquireQuest(8)) then
		FoodSeries.AcquireQuest(8);
	elseif(ran <= 1600 and FoodSeries.CanAcquireQuest(9)) then
		FoodSeries.AcquireQuest(9);
	-- FOREVER DEPRECATED
	--elseif(ran <= 1700 and petLevel >= 2 and FoodSeries.CanAcquireQuest(10)) then
		--FoodSeries.AcquireQuest(10);
	--elseif(ran <= 1800 and petLevel >= 2 and FoodSeries.CanAcquireQuest(11)) then
		--FoodSeries.AcquireQuest(11);
	--elseif(ran <= 1900 and petLevel >= 2 and FoodSeries.CanAcquireQuest(12)) then
		--FoodSeries.AcquireQuest(12);
	elseif(ran <= 1700 and petLevel >= 2 and FoodSeries.CanAcquireQuest(10)) then
		FoodSeries.AcquireQuest(12);
	-- 50161 ~ 50167 : followpet series
	elseif(ran <= 1800 and petLevel >= 3 and FollowPetSeries.CanAcquireQuest(1)) then
		FollowPetSeries.AcquireQuest(1);
	elseif(ran <= 1900 and petLevel >= 3 and FollowPetSeries.CanAcquireQuest(2)) then
		FollowPetSeries.AcquireQuest(2);
	elseif(ran <= 2000 and petLevel >= 4 and FollowPetSeries.CanAcquireQuest(3)) then
		FollowPetSeries.AcquireQuest(3);
	elseif(ran <= 2100 and petLevel >= 4 and FollowPetSeries.CanAcquireQuest(4)) then
		FollowPetSeries.AcquireQuest(4);
	elseif(ran <= 2200 and petLevel >= 3 and FollowPetSeries.CanAcquireQuest(5)) then
		FollowPetSeries.AcquireQuest(5);
	elseif(ran <= 2300 and petLevel >= 3 and FollowPetSeries.CanAcquireQuest(6)) then
		FollowPetSeries.AcquireQuest(6);
	elseif(ran <= 2400 and FollowPetSeries.CanAcquireQuest(7)) then
		FollowPetSeries.AcquireQuest(7);
	elseif(ran <= 2500 and FollowPetSeries.CanAcquireQuest(8)) then
		FollowPetSeries.AcquireQuest(8);
	elseif(ran <= 2600 and FollowPetSeries.CanAcquireQuest(9)) then
		FollowPetSeries.AcquireQuest(9);
	-- 50171 ~ 50174 : game series
	elseif(ran <= 2700 and GameSeries.CanAcquireQuest(1)) then
		GameSeries.AcquireQuest(1);
	elseif(ran <= 2800 and GameSeries.CanAcquireQuest(2)) then
		GameSeries.AcquireQuest(2);
	elseif(ran <= 2900 and GameSeries.CanAcquireQuest(3)) then
		GameSeries.AcquireQuest(3);
	elseif(ran <= 3000 and GameSeries.CanAcquireQuest(4)) then
		GameSeries.AcquireQuest(4);
	elseif(ran <= 3100 and GameSeries.CanAcquireQuest(5)) then
		GameSeries.AcquireQuest(5);
	elseif(ran <= 3200 and GameSeries.CanAcquireQuest(6)) then
		GameSeries.AcquireQuest(6);
	elseif(ran <= 3300 and GameSeries.CanAcquireQuest(7)) then
		GameSeries.AcquireQuest(7);
	elseif(ran <= 3400 and GameSeries.CanAcquireQuest(8)) then
		GameSeries.AcquireQuest(8);
	elseif(ran <= 3500 and petLevel >= 2 and GameSeries.CanAcquireQuest(9)) then
		GameSeries.AcquireQuest(9);
	elseif(ran <= 3600 and petLevel >= 2 and GameSeries.CanAcquireQuest(10)) then
		GameSeries.AcquireQuest(10);
	end
end

function DragonWish.PickOperationalQuest()
	--if(true)then return; end

	local Pet = MyCompany.Aries.Pet;
	if(not Pet.IsMyDragonFetchedFromSophie()) then
		return;
	end
	local petLevel = 0;
	-- get pet level
	local bean = MyCompany.Aries.Pet.GetBean();
	if(bean) then
		petLevel = bean.level or 0;
	end
	--if(petLevel < 3)then
		--return
	--end
	-- schedule 2009/12/18
	--if(NPCs.WishForSnowman.CanAcquireQuest()) then
		--NPL.load("(gl)script/apps/Aries/NPCs/Dragon/091218/WishForSnowman.lua");
		--NPCs.WishForSnowman.AcquireQuest();
	--elseif(NPCs.TakeElkHome.CanAcquireQuest()) then
		--NPL.load("(gl)script/apps/Aries/NPCs/Dragon/091218/TakeElkHome.lua");
		--NPCs.TakeElkHome.AcquireQuest();
	--elseif(NPCs.SpecialChristmasGift.CanAcquireQuest()) then
		--NPL.load("(gl)script/apps/Aries/NPCs/Dragon/091218/SpecialChristmasGift.lua");
		--NPCs.SpecialChristmasGift.AcquireQuest();
	--elseif(NPCs.KnitChirstmasSock.CanAcquireQuest()) then
		--NPL.load("(gl)script/apps/Aries/NPCs/Dragon/091218/KnitChirstmasSock.lua");
		--NPCs.KnitChirstmasSock.AcquireQuest();
		
	-- schedule 2010/03/26
	if(NPCs.OddEggGift.CanAcquireQuest()) then
		NPL.load("(gl)script/apps/Aries/NPCs/Dragon/100326/OddEggGift.lua");
		NPCs.OddEggGift.AcquireQuest();
	-- schedule 2010/01/15
	--if(NPCs.CookLaBaZhou.CanAcquireQuest()) then
		--NPL.load("(gl)script/apps/Aries/NPCs/Dragon/100115/CookLaBaZhou.lua");
		--NPCs.CookLaBaZhou.AcquireQuest();
	-- schedule 2010/01/08
	--elseif(NPCs.WishForWishingLamp.CanAcquireQuest()) then
		--NPL.load("(gl)script/apps/Aries/NPCs/Dragon/100108/WishingLamp.lua");
		--NPCs.WishForWishingLamp.AcquireQuest();
	-- schedule 2009/12/25
	--elseif(NPCs.SnowShooting.CanAcquireQuest()) then
		--NPL.load("(gl)script/apps/Aries/NPCs/Dragon/091225/SnowShooting.lua");
		--NPCs.SnowShooting.AcquireQuest();
	elseif(NPCs.BuildIceHouse.CanAcquireQuest()) then
		NPL.load("(gl)script/apps/Aries/NPCs/Dragon/091225/BuildIceHouse.lua");
		NPCs.BuildIceHouse.AcquireQuest();
	end
end

local timeline1 = 0;
local timeline1_isactive = nil;
local timeline1_nexttriggertime = nil;
local timeline2 = 0;
local timeline2_isactive = true;
local timeline2_nexttriggertime = nil;
local timeline3 = 0;
local timeline3_isactive = true;
local timeline3_nexttriggertime = nil;

-- we use multiple time lines to push quest notifications
function DragonWish.On_Timer()
	
	-- NOTE: 2010/10/2 all quests are temparorily disabled
	do return end

	--if(true)then return; end

	NPL.load("(gl)script/apps/Aries/NPCs/Dragon/30011_WishLevel0.lua");
	NPCs.WishLevel0.On_Timer();
	
	local currentGameTime = ParaGlobal.timeGetTime();
	local elapsedTimeSinceAuth = currentGameTime - System.User.LastAuthGameTime;
	
	--commonlib.ShowDebugString("timeline1", tostring(timeline1))
	--commonlib.ShowDebugString("timeline1_isactive", tostring(timeline1_isactive))
	--commonlib.ShowDebugString("timeline1_nexttriggertime", tostring(timeline1_nexttriggertime))
	
	local countQuest = MyCompany.Aries.Desktop.QuestArea.GetDragonQuestCount();
	local countNotify = MyCompany.Aries.Desktop.QuestArea.GetUnreadDragonNotificationCount();
	local isNotificationVisible = MyCompany.Aries.Desktop.QuestArea.IsNotificationVisible();
	
	-- Timeline 1: triggered after 1 minute when dragon quest list is empty
	if(countQuest == 0 and countNotify == 0 and isNotificationVisible ~= true) then
		if(timeline1_isactive == nil) then
			timeline1_isactive = true;
			timeline1_nexttriggertime = currentGameTime + 60000;
		end
	else
		timeline1_isactive = nil;
		timeline1_nexttriggertime = nil;
	end
	if(timeline1_isactive == true) then
		if(timeline1 <= timeline1_nexttriggertime and currentGameTime > timeline1_nexttriggertime) then
			DragonWish.PickRandomQuest();
			timeline1_isactive = nil;
		end
	end
	timeline1 = currentGameTime;
	
	-- Timeline 2: triggered every 5 ~ 10 minutes for operational quest
	local countQuest = MyCompany.Aries.Desktop.QuestArea.GetDragonQuestCount();
	if(timeline2 == 0) then
		-- first timer call when entering official world
		-- set the nexttriggertime to 15 minutes later
		timeline2_nexttriggertime = currentGameTime + 1000;
	end
	if(timeline2_isactive == true) then
		if(timeline2 <= timeline2_nexttriggertime and currentGameTime > timeline2_nexttriggertime) then
			timeline2_nexttriggertime = currentGameTime + math.random(300000 - 10000, 300000 + 10000);
			-- pick random quest when no quest notification pending
			DragonWish.PickOperationalQuest();
		end
	end
	timeline2 = currentGameTime;
	
	--commonlib.ShowDebugString("timeline2", tostring(timeline2))
	--commonlib.ShowDebugString("timeline2_isactive", tostring(timeline2_isactive))
	--commonlib.ShowDebugString("timeline2_nexttriggertime", tostring(timeline2_nexttriggertime))
	
	-- Timeline 3: triggered every 15 minutes for random quest
	local countQuest = MyCompany.Aries.Desktop.QuestArea.GetDragonQuestCount();
	if(timeline3 == 0) then
		-- first timer call when entering official world
		-- set the nexttriggertime to 15 minutes later
		timeline3_nexttriggertime = currentGameTime + math.random(900000 - 10000, 900000 + 10000);
	end
	if(timeline3_isactive == true) then
		if(timeline3 <= timeline3_nexttriggertime and currentGameTime > timeline3_nexttriggertime) then
			timeline3_nexttriggertime = currentGameTime + math.random(900000 - 10000, 900000 + 10000);
			-- pick random quest when no quest notification pending
			if(countNotify == 0) then
				-- pick random quest according to quest count
				local ran = 0;
				local count = countQuest;
				if(count < 3) then
					ran = 0;
				elseif(count < 6) then
					ran = math.random(0, 200);
				elseif(count >= 6) then
					ran = 101;
				end
				if(ran <= 100) then
					DragonWish.PickRandomQuest();
				end
			end
		end
	end
	timeline3 = currentGameTime;
end

-- update the NPC quest status in quest area
function DragonWish.RefreshStatus()
	
	-- NOTE: 2010/10/2 all quests are temparorily disabled
	do return end

	--if(true)then return; end

	if(System.App.MiniGames.AntiIndulgence.IsAntiSystemIsEnabled()) then
		return;
	end
	
	local Pet = MyCompany.Aries.Pet;
	if(not Pet.IsMyDragonFetchedFromSophie()) then
		return;
	end
	
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	local equipGSItem = ItemManager.IfEquipGSItem;
	
	local petLevel = 0;
	-- get pet level
	local bean = MyCompany.Aries.Pet.GetBean();
	if(bean) then
		petLevel = bean.level or 0;
	end
	
	local NotificationArea = MyCompany.Aries.Desktop.NotificationArea;
	local QuestArea = MyCompany.Aries.Desktop.QuestArea;
	
	---- deprecated
	--NPL.load("(gl)script/apps/Aries/NPCs/Dragon/30011_WishRandom1.lua");
	--MyCompany.Aries.Quest.NPCs.WishRandom1.RefreshStatus();
	
	NPL.load("(gl)script/apps/Aries/NPCs/Dragon/Homeland/HomelandSeries.lua");
	NPCs.HomelandSeries.RefreshStatus();
	NPL.load("(gl)script/apps/Aries/NPCs/Dragon/Food/FoodSeries.lua");
	NPCs.FoodSeries.RefreshStatus();
	NPL.load("(gl)script/apps/Aries/NPCs/Dragon/Game/GameSeries.lua");
	NPCs.GameSeries.RefreshStatus();
	NPL.load("(gl)script/apps/Aries/NPCs/Dragon/FollowPet/FollowPetSeries.lua");
	NPCs.FollowPetSeries.RefreshStatus();
	
	if(petLevel >= 0) then
		NPL.load("(gl)script/apps/Aries/NPCs/Dragon/30011_WishLevel0.lua");
		NPCs.WishLevel0.RefreshStatus();
	end
	if(petLevel >= 1) then
		NPL.load("(gl)script/apps/Aries/NPCs/Dragon/30011_WishLevel1.lua");
		NPCs.WishLevel1.RefreshStatus();
	end
	if(petLevel >= 2) then
		NPL.load("(gl)script/apps/Aries/NPCs/Dragon/30011_WishLevel2.lua");
		NPCs.WishLevel2.RefreshStatus();
	end
	if(petLevel >= 3) then
		NPL.load("(gl)script/apps/Aries/NPCs/Dragon/30011_WishLevel3.lua");
		NPCs.WishLevel3.RefreshStatus();
		--NPL.load("(gl)script/apps/Aries/NPCs/Dragon/30011_WishLevel3_combat.lua");
		--NPCs.WishLevel3_combat.RefreshStatus();
	end
	if(petLevel >= 4) then
		NPL.load("(gl)script/apps/Aries/NPCs/Dragon/30011_WishLevel4.lua");
		NPCs.WishLevel4.RefreshStatus();
	end
	if(petLevel >= 5) then
		NPL.load("(gl)script/apps/Aries/NPCs/Dragon/30011_WishLevel5.lua");
		NPCs.WishLevel5.RefreshStatus();
	end
	if(petLevel >= 6) then
		NPL.load("(gl)script/apps/Aries/NPCs/Dragon/30011_WishLevel6.lua");
		NPCs.WishLevel6.RefreshStatus();
	end
	if(petLevel >= 7) then
		NPL.load("(gl)script/apps/Aries/NPCs/Dragon/30011_WishLevel7.lua");
		NPCs.WishLevel7.RefreshStatus();
	end
	if(petLevel >= 8) then
		NPL.load("(gl)script/apps/Aries/NPCs/Dragon/30011_WishLevel8.lua");
		NPCs.WishLevel8.RefreshStatus();
	end
	if(petLevel >= 9) then
		NPL.load("(gl)script/apps/Aries/NPCs/Dragon/30011_WishLevel9.lua");
		NPCs.WishLevel9.RefreshStatus();
	end
	if(petLevel >= 10) then
		NPL.load("(gl)script/apps/Aries/NPCs/Dragon/30011_WishLevel10.lua");
		NPCs.WishLevel10.RefreshStatus();
	end
	if(petLevel >= 12) then
		NPL.load("(gl)script/apps/Aries/NPCs/Dragon/30011_WishLevel12.lua");
		NPCs.WishLevel12.RefreshStatus();
	end
	
	-- schedule 2009/12/11
	--NPL.load("(gl)script/apps/Aries/NPCs/Dragon/091211/CookForElk.lua");
	--NPCs.CookForElk.RefreshStatus();
	
	-- schedule 2009/12/18
	--NPL.load("(gl)script/apps/Aries/NPCs/Dragon/091218/WishForSnowman.lua");
	--NPCs.WishForSnowman.RefreshStatus();
	--NPL.load("(gl)script/apps/Aries/NPCs/Dragon/091218/TakeElkHome.lua");
	--NPCs.TakeElkHome.RefreshStatus();
	--NPL.load("(gl)script/apps/Aries/NPCs/Dragon/091218/SpecialChristmasGift.lua");
	--NPCs.SpecialChristmasGift.RefreshStatus();
	--NPL.load("(gl)script/apps/Aries/NPCs/Dragon/091218/KnitChirstmasSock.lua");
	--NPCs.KnitChirstmasSock.RefreshStatus();
	
	-- schedule 2009/12/25
	--NPL.load("(gl)script/apps/Aries/NPCs/Dragon/091225/SnowShooting.lua");
	--NPCs.SnowShooting.RefreshStatus();
	NPL.load("(gl)script/apps/Aries/NPCs/Dragon/091225/BuildIceHouse.lua");
	if(petLevel >= 3) then
		NPCs.BuildIceHouse.RefreshStatus();
	end
	---- schedule 2010/01/08
	--NPL.load("(gl)script/apps/Aries/NPCs/Dragon/100108/WishingLamp.lua");
	--if(petLevel >= 3) then
		--NPCs.WishForWishingLamp.RefreshStatus();
	--end
	
	---- schedule 2010/01/15
	--NPL.load("(gl)script/apps/Aries/NPCs/Dragon/100115/CookLaBaZhou.lua");
	--NPCs.CookLaBaZhou.RefreshStatus();
	
	-- schedule 2010/03/26
	NPL.load("(gl)script/apps/Aries/NPCs/Dragon/100326/OddEggGift.lua");
	if(petLevel >= 3) then
		NPCs.OddEggGift.RefreshStatus();
	end
end