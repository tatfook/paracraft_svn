--[[
Title: FollowPetSeries
Author(s): WangTian
Date: 2009/7/31

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Dragon/FollowPet/FollowPetSeries.lua
------------------------------------------------------------
]]

-- create class
local libName = "FollowPetSeries";
local FollowPetSeries = {};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.FollowPetSeries", FollowPetSeries);

local Quest = MyCompany.Aries.Quest;
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;
local NPCs = MyCompany.Aries.Quest.NPCs;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- FollowPetSeries.main
function FollowPetSeries.main()
	NPL.load("(gl)script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet_Lulu.lua");
	NPCs.WishRandom_FollowPet_Lulu.main();
	NPL.load("(gl)script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet_AuqaHorse.lua");
	NPCs.WishRandom_FollowPet_AquaHorse.main();
	NPL.load("(gl)script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet_CrownSnake.lua");
	NPCs.WishRandom_FollowPet_CrownSnake.main();
	NPL.load("(gl)script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet_Beehive.lua");
	NPCs.WishRandom_FollowPet_Beehive.main();
	NPL.load("(gl)script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet_FleaChick.lua");
	NPCs.WishRandom_FollowPet_FleaChick.main();
end

function FollowPetSeries.PickRandomQuest()
    return false;
end

function FollowPetSeries.CanAcquireQuest(id)
	local acquire_gsid;
	
	if(id == 1 and not hasGSItem(50161) and not hasGSItem(10103)) then
		acquire_gsid = 50161;
	elseif(id == 2 and not hasGSItem(50162) and hasGSItem(10103)) then
		acquire_gsid = 50162;
	elseif(id == 3 and not hasGSItem(50163) and not hasGSItem(10108)) then
		acquire_gsid = 50163;
	elseif(id == 4 and not hasGSItem(50164) and hasGSItem(10108)) then
		acquire_gsid = 50164;
	elseif(id == 5 and not hasGSItem(50165) and not hasGSItem(10110)) then
		acquire_gsid = 50165;
	elseif(id == 6 and not hasGSItem(50166) and hasGSItem(10110)) then
		acquire_gsid = 50166;
	elseif(id == 7 and not hasGSItem(50167)) then
		acquire_gsid = 50167;
	elseif(id == 8 and not hasGSItem(50168) and not hasGSItem(10107)) then
		acquire_gsid = 50168;
	elseif(id == 9 and not hasGSItem(50169) and hasGSItem(10107)) then
		acquire_gsid = 50169;
	end
	
	if(acquire_gsid) then
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(acquire_gsid);
		local gsObtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(acquire_gsid);
		if(gsItem and gsObtain) then
			local remainingDailyCount = (gsItem.maxdailycount or 1000) - (gsObtain.inday or 0);
			if(remainingDailyCount > 0) then
				return true;
			end
		else
			return true;
		end
	end
	
	return false;
end

function FollowPetSeries.AcquireQuest(id)
	if(FollowPetSeries.CanAcquireQuest(id)) then
		if(id == 1) then
			ItemManager.PurchaseItem(50161, 1, function(msg) end, function(msg)
				if(msg) then
					log("+++++++Purchase 50161_WishFollowPet1_Acquire return: +++++++\n")
					commonlib.echo(msg);
					if(msg.issuccess == true) then
						Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet1_CatchLulu_Acquire.html");
					end
				end
			end);
		elseif(id == 2 and not hasGSItem(50162) and hasGSItem(10103)) then
			ItemManager.PurchaseItem(50162, 1, function(msg) end, function(msg)
				if(msg) then
					log("+++++++Purchase 50162_WishFollowPet2_Acquire return: +++++++\n")
					commonlib.echo(msg);
					if(msg.issuccess == true) then
						Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet2_PlayWithLulu_Acquire.html");
					end
				end
			end);
		elseif(id == 3 and not hasGSItem(50163) and not hasGSItem(10108)) then
			ItemManager.PurchaseItem(50163, 1, function(msg) end, function(msg)
				if(msg) then
					log("+++++++Purchase 50163_WishFollowPet3_Acquire return: +++++++\n")
					commonlib.echo(msg);
					if(msg.issuccess == true) then
						Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet3_CatchAquaHorse_Acquire.html");
					end
				end
			end);
		elseif(id == 4 and not hasGSItem(50164) and hasGSItem(10108)) then
			ItemManager.PurchaseItem(50164, 1, function(msg) end, function(msg)
				if(msg) then
					log("+++++++Purchase 50164_WishFollowPet4_Acquire return: +++++++\n")
					commonlib.echo(msg);
					if(msg.issuccess == true) then
						Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet4_PlayWithAquaHorse_Acquire.html");
					end
				end
			end);
		elseif(id == 5 and not hasGSItem(50165) and not hasGSItem(10110)) then
			ItemManager.PurchaseItem(50165, 1, function(msg) end, function(msg)
				if(msg) then
					log("+++++++Purchase 50165_WishFollowPet5_Acquire return: +++++++\n")
					commonlib.echo(msg);
					if(msg.issuccess == true) then
						Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet5_CatchCrownSnake_Acquire.html");
					end
				end
			end);
		elseif(id == 6 and not hasGSItem(50166) and hasGSItem(10110)) then
			ItemManager.PurchaseItem(50166, 1, function(msg) end, function(msg)
				if(msg) then
					log("+++++++Purchase 50166_WishFollowPet6_Acquire return: +++++++\n")
					commonlib.echo(msg);
					if(msg.issuccess == true) then
						Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet6_PlayWithCrownSnake_Acquire.html");
					end
				end
			end);
		elseif(id == 7 and not hasGSItem(50167)) then
			ItemManager.PurchaseItem(50167, 1, function(msg) end, function(msg)
				if(msg) then
					log("+++++++Purchase 50167_WishFollowPet7_Acquire return: +++++++\n")
					commonlib.echo(msg);
					if(msg.issuccess == true) then
						Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet7_ShakeBeehive_Acquire.html");
					end
				end
			end);
		elseif(id == 8 and not hasGSItem(50168) and not hasGSItem(10107)) then
			ItemManager.PurchaseItem(50168, 1, function(msg) end, function(msg)
				if(msg) then
					log("+++++++Purchase 50168_WishFollowPet8_Acquire return: +++++++\n")
					commonlib.echo(msg);
					if(msg.issuccess == true) then
						Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet8_CatchFleaChick_Acquire.html");
					end
				end
			end);
		elseif(id == 9 and not hasGSItem(50169) and hasGSItem(10107)) then
			ItemManager.PurchaseItem(50169, 1, function(msg) end, function(msg)
				if(msg) then
					log("+++++++Purchase 50169_WishFollowPet9_Acquire return: +++++++\n")
					commonlib.echo(msg);
					if(msg.issuccess == true) then
						Quest.AppendFeedIfNotAppended("script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet9_PlayWithFleaChick_Acquire.html");
					end
				end
			end);
		end
	end
end

-- refresh quest status
function FollowPetSeries.RefreshStatus()
	NPL.load("(gl)script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet_Lulu.lua");
	NPCs.WishRandom_FollowPet_Lulu.RefreshStatus();
	NPL.load("(gl)script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet_AuqaHorse.lua");
	NPCs.WishRandom_FollowPet_AquaHorse.RefreshStatus();
	NPL.load("(gl)script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet_CrownSnake.lua");
	NPCs.WishRandom_FollowPet_CrownSnake.RefreshStatus();
	NPL.load("(gl)script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet_Beehive.lua");
	NPCs.WishRandom_FollowPet_Beehive.RefreshStatus();
	NPL.load("(gl)script/apps/Aries/NPCs/Dragon/FollowPet/30011_Wish_FollowPet_FleaChick.lua");
	NPCs.WishRandom_FollowPet_FleaChick.RefreshStatus();
end
