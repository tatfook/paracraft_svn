 --[[
Title: 
Author(s): zrf
Date: 2011/1/6
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NewProfile/NewProfileHonour.lua");
------------------------------------------------------------
]]

local NewProfileHonour = commonlib.gettable("MyCompany.Aries.NewProfile.NewProfileHonour");

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
 local PAGE_SIZE = 25;

function NewProfileHonour.Init()
	NewProfileHonour.page= document:GetPageCtrl();
end

function NewProfileHonour.DS_Func(index)
	if(NewProfileHonour.ready == true)then
		if(index==nil)then
			return #(NewProfileHonour.honour);
		else
			return NewProfileHonour.honour[index];
		end
	elseif(index==nil)then
			return 0;
	end
end

function NewProfileHonour.GetItems(nid)
	local bag = 10062;
	-- fetching inventory items
	NewProfileHonour.honour = {};
	NewProfileHonour.honour.status = 1;
	NewProfileHonour.ready= false;

	local ItemManager = System.Item.ItemManager;
	if(nid == System.App.profiles.ProfileManager.GetNID()) then
		ItemManager.GetItemsInBag(bag, "NewProfileHonour_MyMedal", function(msg)
			-- default table
			local bhas,_,__,count_50333 = hasGSItem(50333);
			if(not bhas or not count_50333)then
				count_50333 = 0;
			end
			local bhas,_,__,count_20029 = hasGSItem(20029);
			if(not bhas or not count_20029)then
				count_20029 = 0;
			end
			local bhas,_,__,count_20030 = hasGSItem(20030);
			if(not bhas or not count_20030)then
				count_20030 = 0;
			end
			local bhas,_,__,count_20031 = hasGSItem(20031);
			if(not bhas or not count_20031)then
				count_20031 = 0;
			end
			
			local bhas,_,__,count_20040 = hasGSItem(20040);
			if(not bhas or not count_20040)then
				count_20040 = 0;
			end
			local bhas,_,__,count_20041 = hasGSItem(20041);
			if(not bhas or not count_20041)then
				count_20041 = 0;
			end
			local bhas,_,__,count_20042 = hasGSItem(20042);
			if(not bhas or not count_20042)then
				count_20042 = 0;
			end
			local bhas,_,__,count_20043 = hasGSItem(20043);
			if(not bhas or not count_20043)then
				count_20043 = 0;
			end
			local bhas,_,__,count_20044 = hasGSItem(20044);
			if(not bhas or not count_20044)then
				count_20044 = 0;
			end
			local bhas,_,__,count_20045 = hasGSItem(20045);
			if(not bhas or not count_20045)then
				count_20045 = 0;
			end
			local bhas,_,__,count_20050 = hasGSItem(20050);
			if(not bhas or not count_20050)then
				count_20050 = 0;
			end
			
			NewProfileHonour.honour[1] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalPolice_Empty_32bits.png", tooltip = "神勇徽章"};
			NewProfileHonour.honour[2] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalAngel_Empty_32bits.png", tooltip = "天使徽章"};
			NewProfileHonour.honour[3] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalGenerous_Empty_32bits.png", tooltip = "友情徽章"};
			NewProfileHonour.honour[4] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalPopularity_Empty_32bits.png", tooltip = "人气徽章"};
			NewProfileHonour.honour[5] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalEnvironmental_Empty_32bits.png", tooltip = "环保徽章"};
			NewProfileHonour.honour[6] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalEntrance_32bits.png", tooltip = string.format("魔塔奇兵徽章\r\n已完成试炼之塔%d层",count_50333) };
			NewProfileHonour.honour[7] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalFreePvPPractice_Empty_32bits.png", tooltip = string.format("练习奖章\r\n已获得%d枚",count_20029) };
			NewProfileHonour.honour[8] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalFreePvPTrialOfChampions_Empty_32bits.png", tooltip = string.format("试炼徽章\r\n已获得%d枚",count_20030) };
			NewProfileHonour.honour[9] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalPairedPvPArena_Empty_32bits.png", tooltip = string.format("赛场英雄徽章\r\n已获得%d枚",count_20031) };
			NewProfileHonour.honour[10] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalPKSeason_Empty_32bits.png", tooltip = string.format("系别冠军金牌\r\n已获得%d枚",count_20040) };
			NewProfileHonour.honour[11] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalPKSeason_Empty_32bits.png", tooltip = string.format("系别亚军银牌\r\n已获得%d枚",count_20041) };
			NewProfileHonour.honour[12] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalPKSeason_Empty_32bits.png", tooltip = string.format("系别季军铜牌\r\n已获得%d枚",count_20042) };
			NewProfileHonour.honour[13] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Item/20043_HeroBasinPVPTryOut.png",tooltip = string.format("英雄谷奖章\r\n已获得%d枚",count_20043)};
			--NewProfileHonour.honour[14] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Item/20044_HeroBasinPVPStadium.png",tooltip = string.format("英雄谷赛场奖章\r\n已获得%d枚",count_20044)};
			NewProfileHonour.honour[14] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/Medal_InorderMagicBadge_32bits.png",tooltip = string.format("中级魔法师徽章\r\n已获得%d枚",count_20045)};
			NewProfileHonour.honour[15] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/RedMushroomPvPTopClassMedal_Empty_32bits.png",tooltip = string.format("天梯冠军金牌\r\n已获得%d枚",count_20050)};
			
			local i;
			for i = 16,PAGE_SIZE do
				NewProfileHonour.honour[i] = {isempty = true, isnotempty = false, gsid = "", };
			end
			
			--commonlib.echo("!!!!!!!!!!!:GetItems 1");
			--commonlib.echo(output);
			
			-- medals to show in the profile window
			local medal_series = {
				{20004, 20006, 20007, 20008},
				{20010, 20011, 20012, 20013},
				{20005, 20001, 20002, 20003},
				{20016, 20017, 20018, 20019},
				{20021, 20022, 20023, 20024},
				{20025, 20026, 20027, 20028},
				{20029, },
				{20030, },
				{20031, },
				{20040, },
				{20041, },
				{20042, },
				{20043, },
				{20045, },
				{20050, },
			};
			-- check for each category in the series and show the highest ranking medal
			local hasGSItem = ItemManager.IfOwnGSItem;
			local i;
			for i = 1, #(medal_series) do
				local ii;
				for ii = 1, #(medal_series[i]) do
					if(hasGSItem(medal_series[i][ii])) then
						local gsid = medal_series[i][ii];
						local name = "";
						local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(gsid);
						if(gsItem) then
							name = gsItem.template.name;
						end
						NewProfileHonour.honour[i].isempty = false;
						NewProfileHonour.honour[i].isnotempty = true;
						NewProfileHonour.honour[i].gsid = gsid;
						NewProfileHonour.honour[i].slot = "";

						if(i == 6) then
							NewProfileHonour.honour[i].tooltip = string.format("%s\r\n已完成试炼之塔%d层",name, count_50333);
						elseif(i == 7) then
							NewProfileHonour.honour[i].tooltip = string.format("%s\r\n已获得%d枚",name, count_20029);
						elseif(i == 8) then
							NewProfileHonour.honour[i].tooltip = string.format("%s\r\n已获得%d枚",name, count_20030);
						elseif(i == 9) then
							NewProfileHonour.honour[i].tooltip = string.format("%s\r\n已获得%d枚",name, count_20031);
						elseif(i == 10) then
							NewProfileHonour.honour[i].tooltip = string.format("%s\r\n已获得%d枚",name, count_20040);
						elseif(i == 11) then
							NewProfileHonour.honour[i].tooltip = string.format("%s\r\n已获得%d枚",name, count_20041);
						elseif(i == 12) then
							NewProfileHonour.honour[i].tooltip = string.format("%s\r\n已获得%d枚",name, count_20042);
						elseif(i == 13) then
							NewProfileHonour.honour[i].tooltip = string.format("%s\r\n已获得%d枚",name, count_20043);
						elseif(i == 14) then
							NewProfileHonour.honour[i].tooltip = string.format("%s\r\n已获得%d枚",name, count_20045);
						elseif(i == 15) then
							NewProfileHonour.honour[i].tooltip = string.format("%s\r\n已获得%d枚",name, count_20050);
						else
							NewProfileHonour.honour[i].tooltip = name;
						end
					end
				end
			end
			NewProfileHonour.honour.Count = PAGE_SIZE;
			commonlib.resize(NewProfileHonour.honour, NewProfileHonour.honour.Count);

			--commonlib.echo("!!!!!!!!!!!:GetItems 2");
			--commonlib.echo(output);
			
			-- fetched inventory items
			NewProfileHonour.honour.status = 2;
			NewProfileHonour.ready= true;
			if(NewProfileHonour.page)then
				NewProfileHonour.page:Refresh(0.01);
			end
			
		end, "access plus 1 minutes");
	else
		ItemManager.GetItemsInOPCBag(nid, 31001, "NewProfileHonour_OPCMedal_0", function(msg)

			ItemManager.GetItemsInOPCBag(nid, bag, "NewProfileHonour_OPCMedal", function(msg)
				-- default table
				--local bhas,_,__,count = hasGSItem(50333);
				--if(not bhas or not count)then
					--count = 0;
				--end

				local hasGSItem0 = ItemManager.IfOPCOwnGSItem;
				local bhas,guid = hasGSItem0(nid,50333);
				local count_50333 = 0;
				if(bhas)then
					local item0 = ItemManager.GetOPCItemByGUID(nid,guid);
					count_50333 = item0.copies;
				end
				local bhas,guid = hasGSItem0(nid,20029);
				local count_20029 = 0;
				if(bhas)then
					local item0 = ItemManager.GetOPCItemByGUID(nid,guid);
					count_20029 = item0.copies;
				end
				local bhas,guid = hasGSItem0(nid,20030);
				local count_20030 = 0;
				if(bhas)then
					local item0 = ItemManager.GetOPCItemByGUID(nid,guid);
					count_20030 = item0.copies;
				end
				local bhas,guid = hasGSItem0(nid,20031);
				local count_20031 = 0;
				if(bhas)then
					local item0 = ItemManager.GetOPCItemByGUID(nid,guid);
					count_20031 = item0.copies;
				end
				
				local bhas,guid = hasGSItem0(nid,20040);
				local count_20040 = 0;
				if(bhas)then
					local item0 = ItemManager.GetOPCItemByGUID(nid,guid);
					count_20040 = item0.copies;
				end
				local bhas,guid = hasGSItem0(nid,20041);
				local count_20041 = 0;
				if(bhas)then
					local item0 = ItemManager.GetOPCItemByGUID(nid,guid);
					count_20041 = item0.copies;
				end
				local bhas,guid = hasGSItem0(nid,20042);
				local count_20042 = 0;
				if(bhas)then
					local item0 = ItemManager.GetOPCItemByGUID(nid,guid);
					count_20042 = item0.copies;
				end
				local bhas,guid = hasGSItem0(nid,20043);
				local count_20043 = 0;
				if(bhas)then
					local item0 = ItemManager.GetOPCItemByGUID(nid,guid);
					count_20043 = item0.copies;
				end
				local bhas,guid = hasGSItem0(nid,20044);
				local count_20044 = 0;
				if(bhas)then
					local item0 = ItemManager.GetOPCItemByGUID(nid,guid);
					count_20044 = item0.copies;
				end
				local bhas,guid = hasGSItem0(nid,20045);
				local count_20045 = 0;
				if(bhas)then
					local item0 = ItemManager.GetOPCItemByGUID(nid,guid);
					count_20045 = item0.copies;
				end
				local bhas,guid = hasGSItem0(nid,20050);
				local count_20050 = 0;
				if(bhas)then
					local item0 = ItemManager.GetOPCItemByGUID(nid,guid);
					count_20050 = item0.copies;
				end
				NewProfileHonour.honour[1] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalPolice_Empty_32bits.png", tooltip = "神勇徽章"};
				NewProfileHonour.honour[2] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalAngel_Empty_32bits.png", tooltip = "天使徽章"};
				NewProfileHonour.honour[3] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalGenerous_Empty_32bits.png", tooltip = "友情徽章"};
				NewProfileHonour.honour[4] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalPopularity_Empty_32bits.png", tooltip = "人气徽章"};
				NewProfileHonour.honour[5] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalEnvironmental_Empty_32bits.png", tooltip = "环保徽章"};
				NewProfileHonour.honour[6] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalEntrance_32bits.png", tooltip = string.format("魔塔奇兵徽章\r\n已完成试炼之塔%d层",count_50333) };
				NewProfileHonour.honour[7] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalFreePvPPractice_Empty_32bits.png", tooltip = string.format("练习奖章\r\n已获得%d枚",count_20029) };
				NewProfileHonour.honour[8] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalFreePvPTrialOfChampions_Empty_32bits.png", tooltip = string.format("试炼徽章\r\n已获得%d枚",count_20030) };
				NewProfileHonour.honour[9] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalPairedPvPArena_Empty_32bits.png", tooltip = string.format("赛场英雄徽章\r\n已获得%d枚",count_20031) };
				NewProfileHonour.honour[10] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalPKSeason_Empty_32bits.png", tooltip = string.format("系别冠军金牌\r\n已获得%d枚",count_20040) };
				NewProfileHonour.honour[11] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalPKSeason_Empty_32bits.png", tooltip = string.format("系别亚军银牌\r\n已获得%d枚",count_20041) };
				NewProfileHonour.honour[12] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalPKSeason_Empty_32bits.png", tooltip = string.format("系别季军铜牌\r\n已获得%d枚",count_20042) };
				NewProfileHonour.honour[13] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Item/20043_HeroBasinPVPTryOut.png",tooltip = string.format("英雄谷奖章\r\n已获得%d枚",count_20043)};
				--NewProfileHonour.honour[14] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Item/20044_HeroBasinPVPStadium.png",tooltip = string.format("英雄谷赛场奖章\r\n已获得%d枚",count_20044)};
				NewProfileHonour.honour[14] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/Medal_InorderMagicBadge_32bits.png",tooltip = string.format("中级魔法师徽章\r\n已获得%d枚",count_20045)};
				NewProfileHonour.honour[15] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/RedMushroomPvPTopClassMedal_Empty_32bits.png",tooltip = string.format("天梯冠军金牌\r\n已获得%d枚",count_20050)};
				NewProfileHonour.honour[16] = {isempty = true, isnotempty = false, gsid = "", };
				local i
				for i= 16,PAGE_SIZE do
					NewProfileHonour.honour[i ] = {isempry = true,isnotempty= false,gsid=""}
				end
			
				--commonlib.echo("!!!!!!!!!!!:GetItems 3");
				--commonlib.echo(output);			 

				-- medals to show in the profile window
				local medal_series = {
					{20004, 20006, 20007, 20008},
					{20010, 20011, 20012, 20013},
					{20005, 20001, 20002, 20003},
					{20016, 20017, 20018, 20019},
					{20021, 20022, 20023, 20024},
					{20025, 20026, 20027, 20028},
					{20029, },
					{20030, },
					{20031, },
					{20040, },
					{20041, },
					{20042, },
					{20043, },
					{20045, },
					{20050, },
				};
				-- check for each category in the series and show the highest ranking medal
				local hasGSItem = ItemManager.IfOPCOwnGSItem;
				local i;
				for i = 1, #(medal_series) do
					local ii;
					for ii = 1, #(medal_series[i]) do
						if(hasGSItem(nid, medal_series[i][ii])) then
							local gsid = medal_series[i][ii];
							local name = "";
							local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(gsid);
							if(gsItem) then
								name = gsItem.template.name;
							end
							NewProfileHonour.honour[i].isempty = false;
							NewProfileHonour.honour[i].isnotempty = true;
							NewProfileHonour.honour[i].gsid = gsid;
							NewProfileHonour.honour[i].slot = "";
							if(i == 6) then
								NewProfileHonour.honour[i].tooltip = string.format("%s\r\n已完成试炼之塔%d层",name, count_50333 );
							elseif(i == 7) then
								NewProfileHonour.honour[i].tooltip = string.format("%s\r\n已获得%d枚",name, count_20029);
							elseif(i == 8) then
								NewProfileHonour.honour[i].tooltip = string.format("%s\r\n已获得%d枚",name, count_20030);
							elseif(i == 9) then
								NewProfileHonour.honour[i].tooltip = string.format("%s\r\n已获得%d枚",name, count_20031);
							elseif(i == 10) then
								NewProfileHonour.honour[i].tooltip = string.format("%s\r\n已获得%d枚",name, count_20040);
							elseif(i == 11) then
								NewProfileHonour.honour[i].tooltip = string.format("%s\r\n已获得%d枚",name, count_20041);
							elseif(i == 12) then
								NewProfileHonour.honour[i].tooltip = string.format("%s\r\n已获得%d枚",name, count_20042);
							elseif(i == 13) then
								NewProfileHonour.honour[i].tooltip = string.format("%s\r\n已获得%d枚",name, count_20043);
							elseif(i == 14) then
								NewProfileHonour.honour[i].tooltip = string.format("%s\r\n已获得%d枚",name, count_20045);
							elseif(i == 15) then
								NewProfileHonour.honour[i].tooltip = string.format("%s\r\n已获得%d枚",name, count_20050);
							else
								NewProfileHonour.honour[i].tooltip = name;
							end
						end
					end
				end
				NewProfileHonour.honour.Count = 15;
				commonlib.resize(NewProfileHonour.honour, NewProfileHonour.honour.Count);

				--commonlib.echo("!!!!!!!!!!!:GetItems 4");
				--commonlib.echo(output);
				-- fetched inventory items
				NewProfileHonour.honour.status = 2;
				NewProfileHonour.ready= true;

				if(NewProfileHonour.page)then
					NewProfileHonour.page:Refresh(0.01);
				end
			
			end, "access plus 1 minutes");
		end, "access plus 1 minutes");
	end
end
