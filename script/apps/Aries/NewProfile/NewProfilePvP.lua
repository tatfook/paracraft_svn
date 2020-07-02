 --[[
Title: 
Author(s): zrf
Date: 2011/1/6
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NewProfile/NewProfilePvP.lua");
------------------------------------------------------------
]]

local NewProfilePvP = commonlib.gettable("MyCompany.Aries.NewProfile.NewProfilePvP");
local Combat = commonlib.gettable("MyCompany.Aries.Combat");

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
 
function NewProfilePvP.Init()
	NewProfilePvP.page= document:GetPageCtrl();
end

function NewProfilePvP.DS_Func(index)
	if(NewProfilePvP.ready == true)then
		if(index==nil)then
			return #(NewProfilePvP.honour);
		else
			return NewProfilePvP.honour[index];
		end
	elseif(index==nil)then
		return 4;
	end
end

function NewProfilePvP.GetPvPStats(arena, type)
	
	if(System.options.version == "kids") then
		return NewProfilePvP.GetPvPStats_New(arena, type);
	end

	if(NewProfilePvP.ready == true)then
		--20032_RedMushroomPvP_1v1_WinningCount
		--20033_RedMushroomPvP_1v1_LosingCount
		--20034_RedMushroomPvP_2v2_WinningCount
		--20035_RedMushroomPvP_2v2_LosingCount
		--20036_RedMushroomPvP_3v3_WinningCount
		--20037_RedMushroomPvP_3v3_LosingCount
		--20038_RedMushroomPvP_4v4_WinningCount
		--20039_RedMushroomPvP_4v4_LosingCount
		local base = 20032;
		local base_offset = 0;
		if(arena == "1v1") then
			base = 20032;
		elseif(arena == "2v2") then
			base = 20034;
		elseif(arena == "3v3") then
			base = 20036;
		elseif(arena == "4v4") then
			base = 20038;
		elseif(arena == "1v1_toc") then
			base = 20051;
		end
		if(type == "win_count") then
			base_offset = 0;
		elseif(type == "lose_count") then
			base_offset = 1;
		elseif(type == "winning_rate") then
			base_offset = nil;
		elseif(type == "rating") then
			base_offset = nil;
		end

		if(base_offset == 0 or base_offset == 1) then
			
			local nid = NewProfilePvP.nid;
			if(nid == System.App.profiles.ProfileManager.GetNID())then
				local bhas,_,__,count = hasGSItem(base + base_offset);
				if(not bhas or not count)then
					count = 0;
				end
				return tostring(count);
			else
				local hasGSItem0 = ItemManager.IfOPCOwnGSItem;
				local count = 0;
				local bhas, guid = hasGSItem0(nid, base + base_offset);
				if(bhas)then
					local item0 = ItemManager.GetOPCItemByGUID(nid, guid);
					count = item0.copies;
				end
				return tostring(count);
			end
		elseif(base_offset == nil) then
			
			local nid = NewProfilePvP.nid;
			
			local rating_revise = 1;
			local my_level = 0;
			if(nid == System.App.profiles.ProfileManager.GetNID())then
				my_level = Combat.GetMyCombatLevel();
			else
				local bean = MyCompany.Aries.Pet.GetBean(nid);
				if(bean) then
					my_level = bean.combatlel or 1;
				else
					my_level = 1;
				end
			end
			if(my_level >= 50) then
				rating_revise = 1;
			elseif(my_level >= 40) then
				rating_revise = 0; -- rating_revise = 0.5;
			elseif(my_level >= 30) then
				rating_revise = 0; -- rating_revise = 0.25;
			elseif(my_level >= 20) then
				rating_revise = 0; -- rating_revise = 0.125;
			else
				rating_revise = 0;
			end

			if(nid == System.App.profiles.ProfileManager.GetNID())then
				local bhas,_,__,count1 = hasGSItem(base);
				if(not bhas or not count1)then
					count1 = 0;
				end
				local bhas,_,__,count2 = hasGSItem(base + 1);
				if(not bhas or not count2)then
					count2 = 0;
				end
				if(count1 == 0 and count2 == 0 and (count1 + count2) == 0) then
					return "0";
				end
				
				if(type == "winning_rate") then
					return tostring(math.ceil(100 * count1 / ((count1 + count2))));
				elseif(type == "rating") then
					return tostring(math.ceil(rating_revise * count1 * 10 * count1 / ((count1 + count2))));
				end
			else
				local hasGSItem0 = ItemManager.IfOPCOwnGSItem;
				local count1 = 0;
				local count2 = 0;
				local bhas, guid = hasGSItem0(nid, base);
				if(bhas)then
					local item0 = ItemManager.GetOPCItemByGUID(nid, guid);
					count1 = item0.copies;
				end
				local bhas, guid = hasGSItem0(nid, base + 1);
				if(bhas)then
					local item0 = ItemManager.GetOPCItemByGUID(nid, guid);
					count2 = item0.copies;
				end
				if(count1 == 0 and count2 == 0 and (count1 + count2) == 0) then
					return "0";
				end
				if(type == "winning_rate") then
					return tostring(math.ceil(100 * count1 / ((count1 + count2))));
				elseif(type == "rating") then
					return tostring(math.ceil(rating_revise * count1 * 10 * count1 / ((count1 + count2))));
				end
			end
		end
		return "";

			--local bhas,_,__,count_20029 = hasGSItem(20029);
			--if(not bhas or not count_20029)then
				--count_20029 = 0;
			--end

	else 
		return "";
	end
end

function NewProfilePvP.GetPvPStats_New(arena, type)
	if(NewProfilePvP.ready == true)then
		--20032_RedMushroomPvP_1v1_WinningCount
		--20033_RedMushroomPvP_1v1_LosingCount
		--20034_RedMushroomPvP_2v2_WinningCount
		--20035_RedMushroomPvP_2v2_LosingCount
		--20036_RedMushroomPvP_3v3_WinningCount
		--20037_RedMushroomPvP_3v3_LosingCount
		--20038_RedMushroomPvP_4v4_WinningCount
		--20039_RedMushroomPvP_4v4_LosingCount
		local base = 20032;
		local base_offset = 0;
		if(arena == "1v1") then
			base = 20032;
		elseif(arena == "2v2") then
			base = 20034;
		elseif(arena == "3v3") then
			base = 20036;
		elseif(arena == "4v4") then
			base = 20038;
		elseif(arena == "1v1_toc") then
			base = 20051;
		end
		if(type == "win_count") then
			base_offset = 0;
		elseif(type == "lose_count") then
			base_offset = 1;
		elseif(type == "winning_rate") then
			base_offset = nil;
		elseif(type == "rating") then
			if(arena == "1v1" or arena == "2v2") then
				--base = 20046;
				local gearScore = MyCompany.Aries.Player.GetGearScore(NewProfilePvP.nid);
				base = Combat.GetPVPPointGSID(arena,gearScore,"win");
			--elseif(arena == "2v2") then
				--base = 20048;
			elseif(arena == "3v3") then
				base = 20091;
			end
			base_offset = nil;
		elseif(type == "rating_weighted") then
			if(arena == "1v1" or arena == "2v2") then
				--base = 20046;
				local gearScore = MyCompany.Aries.Player.GetGearScore(NewProfilePvP.nid);
				base = Combat.GetPVPPointGSID(arena,gearScore,"win");
			--elseif(arena == "2v2") then
				--base = 20048;
			elseif(arena == "3v3") then
				base = 20091;
			end
			base_offset = nil;
		end

		if(base_offset == 0 or base_offset == 1) then
			
			local nid = NewProfilePvP.nid;
			if(nid == System.App.profiles.ProfileManager.GetNID())then
				local bhas,_,__,count = hasGSItem(base + base_offset);
				if(not bhas or not count)then
					count = 0;
				end
				return tostring(count);
			else
				local hasGSItem0 = ItemManager.IfOPCOwnGSItem;
				local count = 0;
				local bhas, guid = hasGSItem0(nid, base + base_offset);
				if(bhas)then
					local item0 = ItemManager.GetOPCItemByGUID(nid, guid);
					count = item0.copies;
				end
				return tostring(count);
			end
		elseif(base_offset == nil) then
			
			local nid = NewProfilePvP.nid;
			
			local rating_revise = 1;
			local my_level = 0;
			if(nid == System.App.profiles.ProfileManager.GetNID())then
				my_level = Combat.GetMyCombatLevel();
			else
				local bean = MyCompany.Aries.Pet.GetBean(nid);
				if(bean) then
					my_level = bean.combatlel or 1;
				else
					my_level = 1;
				end
			end
			if(my_level >= 50) then
				rating_revise = 1;
			elseif(my_level >= 40) then
				rating_revise = 0.3;
			elseif(my_level >= 30) then
				rating_revise = 0.2;
			elseif(my_level >= 20) then
				rating_revise = 0.1;
			else
				rating_revise = 0;
			end

			if(nid == System.App.profiles.ProfileManager.GetNID())then
				local bhas,_,__,count1 = hasGSItem(base);
				if(not bhas or not count1)then
					count1 = 0;
				end
				local bhas,_,__,count2 = hasGSItem(base + 1);
				if(not bhas or not count2)then
					count2 = 0;
				end
				if(type == "winning_rate" and count1 == 0 and count2 == 0 and (count1 + count2) == 0) then
					return "0";
				end
				
				if(type == "winning_rate") then
					return tostring(math.ceil(100 * count1 / ((count1 + count2))));
				elseif(type == "rating") then
					--return tostring(math.ceil(rating_revise * count1 * 10 * count1 / ((count1 + count2))));
					if(arena == "3v3") then
						return count1;
					else
						return 1000 + count1 - count2;	
					end
				elseif(type == "rating_weighted") then
					if(arena == "3v3") then
						return tostring(math.ceil(rating_revise * count1));
					else
						return tostring(math.ceil(rating_revise * (1000 + count1 - count2)));
					end
					--return tostring(math.ceil(rating_revise * (1000 + count1 - count2)));
				end
			else
				local hasGSItem0 = ItemManager.IfOPCOwnGSItem;
				local count1 = 0;
				local count2 = 0;
				local bhas, guid = hasGSItem0(nid, base);
				if(bhas)then
					local item0 = ItemManager.GetOPCItemByGUID(nid, guid);
					count1 = item0.copies;
				end
				local bhas, guid = hasGSItem0(nid, base + 1);
				if(bhas)then
					local item0 = ItemManager.GetOPCItemByGUID(nid, guid);
					count2 = item0.copies;
				end
				if(type == "winning_rate" and count1 == 0 and count2 == 0 and (count1 + count2) == 0) then
					return "0";
				end
				if(type == "winning_rate") then
					return tostring(math.ceil(100 * count1 / ((count1 + count2))));
				elseif(type == "rating") then
					--return tostring(math.ceil(rating_revise * count1 * 10 * count1 / ((count1 + count2))));
					--return 1000 + count1 - count2;
					if(arena == "3v3") then
						return count1;
					else
						return 1000 + count1 - count2;	
					end
				elseif(type == "rating_weighted") then
					if(arena == "3v3") then
						return tostring(math.ceil(rating_revise * count1));
					else
						return tostring(math.ceil(rating_revise * (1000 + count1 - count2)));
					end
					--return tostring(math.ceil(rating_revise * (1000 + count1 - count2)));
				end
			end
		end
		return "";

			--local bhas,_,__,count_20029 = hasGSItem(20029);
			--if(not bhas or not count_20029)then
				--count_20029 = 0;
			--end

	else 
		return "";
	end
end

function NewProfilePvP.GetItems(nid)
	local bag = 10062;
	-- fetching inventory items
	NewProfilePvP.honour = {};
	NewProfilePvP.honour.status = 1;
	NewProfilePvP.ready= false;
	NewProfilePvP.nid = nid;

	local ItemManager = System.Item.ItemManager;
	if(nid == System.App.profiles.ProfileManager.GetNID()) then
		ItemManager.GetItemsInBag(bag, "NewProfilePvP_MyMedal", function(msg)
			-- default table
			--local bhas,_,__,count_50333 = hasGSItem(50333);
			--if(not bhas or not count_50333)then
				--count_50333 = 0;
			--end
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

			--NewProfilePvP.honour[1] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalPolice_Empty_32bits.png", tooltip = "神勇徽章"};
			--NewProfilePvP.honour[2] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalAngel_Empty_32bits.png", tooltip = "天使徽章"};
			--NewProfilePvP.honour[3] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalGenerous_Empty_32bits.png", tooltip = "友情徽章"};
			--NewProfilePvP.honour[4] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalPopularity_Empty_32bits.png", tooltip = "人气徽章"};
			--NewProfilePvP.honour[5] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalEnvironmental_Empty_32bits.png", tooltip = "环保徽章"};
			--NewProfilePvP.honour[6] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalEntrance_32bits.png", tooltip = string.format("魔塔奇兵徽章\r\n已完成试炼之塔%d层",count_50333) };
			NewProfilePvP.honour[1] = {isempty = true, isnotempty = false, gsid = "", count = 0, slot = "Texture/Aries/Profile/MedalFreePvPPractice_Empty_32bits.png", tooltip = string.format("练习奖章\r\n已获得%d枚",count_20029) };
			NewProfilePvP.honour[2] = {isempty = true, isnotempty = false, gsid = "", count = 0, slot = "Texture/Aries/Profile/MedalFreePvPTrialOfChampions_Empty_32bits.png", tooltip = string.format("试炼徽章\r\n已获得%d枚",count_20030) };
			NewProfilePvP.honour[3] = {isempty = true, isnotempty = false, gsid = "", count = 0, slot = "Texture/Aries/Profile/MedalPairedPvPArena_Empty_32bits.png", tooltip = string.format("赛场英雄徽章\r\n已获得%d枚",count_20031) };
			--NewProfilePvP.honour[4] = {isempty = true, isnotempty = false, gsid = "", };
			--NewProfilePvP.honour[11] = {isempty = true, isnotempty = false, gsid = "", };
			--NewProfilePvP.honour[12] = {isempty = true, isnotempty = false, gsid = "", };
			--NewProfilePvP.honour[13] = {isempty = true, isnotempty = false, gsid = "", };
			--NewProfilePvP.honour[14] = {isempty = true, isnotempty = false, gsid = "", };
			--NewProfilePvP.honour[15] = {isempty = true, isnotempty = false, gsid = "", };
			--NewProfilePvP.honour[16] = {isempty = true, isnotempty = false, gsid = "", };
			
			--commonlib.echo("!!!!!!!!!!!:GetItems 1");
			--commonlib.echo(output);
			
			-- medals to show in the profile window
			local medal_series = {
				--{20004, 20006, 20007, 20008},
				--{20010, 20011, 20012, 20013},
				--{20005, 20001, 20002, 20003},
				--{20016, 20017, 20018, 20019},
				--{20021, 20022, 20023, 20024},
				--{20025, 20026, 20027, 20028},
				{20029, },
				{20030, },
				{20031, },
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
						NewProfilePvP.honour[i].isempty = false;
						NewProfilePvP.honour[i].isnotempty = true;
						NewProfilePvP.honour[i].gsid = gsid;
						NewProfilePvP.honour[i].slot = "";

						--if(i == 6) then
							--NewProfilePvP.honour[i].tooltip = string.format("%s\r\n已完成试炼之塔%d层",name, count_50333);
						if(i == 1) then
							NewProfilePvP.honour[i].tooltip = string.format("%s\r\n已获得%d枚",name, count_20029);
							NewProfilePvP.honour[i].count = count_20029;
						elseif(i == 2) then
							NewProfilePvP.honour[i].tooltip = string.format("%s\r\n已获得%d枚",name, count_20030);
							NewProfilePvP.honour[i].count = count_20030;
						elseif(i == 3) then
							NewProfilePvP.honour[i].tooltip = string.format("%s\r\n已获得%d枚",name, count_20031);
							NewProfilePvP.honour[i].count = count_20031;
						else
							NewProfilePvP.honour[i].tooltip = name;
						end
					end
				end
			end
			NewProfilePvP.honour.Count = 3;
			commonlib.resize(NewProfilePvP.honour, NewProfilePvP.honour.Count);

			--commonlib.echo("!!!!!!!!!!!:GetItems 2");
			--commonlib.echo(output);
			
			-- fetched inventory items
			NewProfilePvP.honour.status = 2;
			NewProfilePvP.ready= true;
			if(NewProfilePvP.page)then
				NewProfilePvP.page:Refresh(0.01);
			end
			
		end, "access plus 1 minutes");
	else
		ItemManager.GetItemsInOPCBag(nid, 31001, "NewProfilePvP_OPCMedal_0", function(msg)

			ItemManager.GetItemsInOPCBag(nid, bag, "NewProfilePvP_OPCMedal", function(msg)
				-- default table
				--local bhas,_,__,count = hasGSItem(50333);
				--if(not bhas or not count)then
					--count = 0;
				--end

				local hasGSItem0 = ItemManager.IfOPCOwnGSItem;
				--local bhas,guid = hasGSItem0(nid,50333);
				--local count_50333 = 0;
				--if(bhas)then
					--local item0 = ItemManager.GetOPCItemByGUID(nid,guid);
					--count_50333 = item0.copies;
				--end
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

				--NewProfilePvP.honour[1] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalPolice_Empty_32bits.png", tooltip = "神勇徽章"};
				--NewProfilePvP.honour[2] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalAngel_Empty_32bits.png", tooltip = "天使徽章"};
				--NewProfilePvP.honour[3] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalGenerous_Empty_32bits.png", tooltip = "友情徽章"};
				--NewProfilePvP.honour[4] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalPopularity_Empty_32bits.png", tooltip = "人气徽章"};
				--NewProfilePvP.honour[5] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalEnvironmental_Empty_32bits.png", tooltip = "环保徽章"};
				--NewProfilePvP.honour[6] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalEntrance_32bits.png", tooltip = string.format("魔塔奇兵徽章\r\n已完成试炼之塔%d层",count_50333) };
				NewProfilePvP.honour[1] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalFreePvPPractice_Empty_32bits.png", tooltip = string.format("练习奖章\r\n已获得%d枚",count_20029) };
				NewProfilePvP.honour[2] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalFreePvPTrialOfChampions_Empty_32bits.png", tooltip = string.format("试炼徽章\r\n已获得%d枚",count_20030) };
				NewProfilePvP.honour[3] = {isempty = true, isnotempty = false, gsid = "", slot = "Texture/Aries/Profile/MedalPairedPvPArena_Empty_32bits.png", tooltip = string.format("赛场英雄徽章\r\n已获得%d枚",count_20031) };
				--NewProfilePvP.honour[4] = {isempty = true, isnotempty = false, gsid = "", };
				--NewProfilePvP.honour[11] = {isempty = true, isnotempty = false, gsid = "", };
				--NewProfilePvP.honour[12] = {isempty = true, isnotempty = false, gsid = "", };
				--NewProfilePvP.honour[13] = {isempty = true, isnotempty = false, gsid = "", };
				--NewProfilePvP.honour[14] = {isempty = true, isnotempty = false, gsid = "", };
				--NewProfilePvP.honour[15] = {isempty = true, isnotempty = false, gsid = "", };
				--NewProfilePvP.honour[16] = {isempty = true, isnotempty = false, gsid = "", };
			
				--commonlib.echo("!!!!!!!!!!!:GetItems 3");
				--commonlib.echo(output);			 

				-- medals to show in the profile window
				local medal_series = {
					--{20004, 20006, 20007, 20008},
					--{20010, 20011, 20012, 20013},
					--{20005, 20001, 20002, 20003},
					--{20016, 20017, 20018, 20019},
					--{20021, 20022, 20023, 20024},
					--{20025, 20026, 20027, 20028},
					{20029, },
					{20030, },
					{20031, },

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
							NewProfilePvP.honour[i].isempty = false;
							NewProfilePvP.honour[i].isnotempty = true;
							NewProfilePvP.honour[i].gsid = gsid;
							NewProfilePvP.honour[i].slot = "";
							--if(i == 6) then
								--NewProfilePvP.honour[i].tooltip = string.format("%s\r\n已完成试炼之塔%d层",name, count_50333 );
							if(i == 1) then
								NewProfilePvP.honour[i].tooltip = string.format("%s\r\n已获得%d枚",name, count_20029);
								NewProfilePvP.honour[i].count = count_20029;
							elseif(i == 2) then
								NewProfilePvP.honour[i].tooltip = string.format("%s\r\n已获得%d枚",name, count_20030);
								NewProfilePvP.honour[i].count = count_20030;
							elseif(i == 3) then
								NewProfilePvP.honour[i].tooltip = string.format("%s\r\n已获得%d枚",name, count_20031);
								NewProfilePvP.honour[i].count = count_20031;
							else
								NewProfilePvP.honour[i].tooltip = name;
							end
						end
					end
				end
				NewProfilePvP.honour.Count = 3;
				commonlib.resize(NewProfilePvP.honour, NewProfilePvP.honour.Count);

				--commonlib.echo("!!!!!!!!!!!:GetItems 4");
				--commonlib.echo(output);
				-- fetched inventory items
				NewProfilePvP.honour.status = 2;
				NewProfilePvP.ready= true;

				if(NewProfilePvP.page)then
					NewProfilePvP.page:Refresh(0.01);
				end
			
			end, "access plus 1 minutes");
		end, "access plus 1 minutes");
	end
end

function NewProfilePvP.GetTextFor1v1()
	local text = ""
	local gearScore = MyCompany.Aries.Player.GetGearScore(NewProfilePvP.nid);
	if(gearScore < 600) then
		text = "青铜王者组<br/>1v1"
	elseif(gearScore < 800) then
		text = "白银王者组<br/>1v1"
	elseif(gearScore < 1000) then
		text = "银龙王者组<br/>1v1"
	elseif(gearScore < 1200) then
		text = "金龙守护者组<br/>1v1"
	else
		text = "巨龙王者组<br/>1v1"
	end
	return text;
end