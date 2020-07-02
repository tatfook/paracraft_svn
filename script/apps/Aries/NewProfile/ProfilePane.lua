--[[
Title: 
Author(s): leio
Date: 2011/07/26
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/DefaultTheme.teen.lua");
MyCompany.Aries.Theme.Default:Load();
NPL.load("(gl)script/apps/Aries/NewProfile/ProfilePane.lua");
local ProfilePane = commonlib.gettable("MyCompany.Aries.ProfilePane");
ProfilePane.ShowPage(nil);
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/UserBag/BagHelper.lua");
local BagHelper = commonlib.gettable("MyCompany.Aries.Inventory.BagHelper");
NPL.load("(gl)script/apps/Aries/GoldRankingList/ranking_server.lua");
local RankingServer = commonlib.gettable("MyCompany.Aries.GoldRankingList.RankingServer");
local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");
NPL.load("(gl)script/apps/Aries/Combat/MsgHandler.lua");
local MsgHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");
NPL.load("(gl)script/apps/Aries/Profile/FullProfile.lua");
local Combat = commonlib.gettable("MyCompany.Aries.Combat");
NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyHelper.lua");
local LobbyHelper = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyHelper");
NPL.load("(gl)script/apps/Aries/ApparelTranslation/GemTranslationHelper.lua");
local GemTranslationHelper = commonlib.gettable("MyCompany.Aries.ApparelTranslation.GemTranslationHelper");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
local Player = commonlib.gettable("MyCompany.Aries.Player");
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
local Dock = commonlib.gettable("MyCompany.Aries.Desktop.Dock");
local ProfilePane = commonlib.gettable("MyCompany.Aries.ProfilePane");
ProfilePane.is_edit_name = nil;
ProfilePane.cur_type = "combatinfo"; -- "combatinfo" "honour" "pvpinfo"
ProfilePane.combatinfo_list = nil;
ProfilePane.medal_list = nil;
ProfilePane.pvpstat_list = nil;

function ProfilePane.OnInit()
	local self = ProfilePane;
	self.page = document:GetPageCtrl();
end
function ProfilePane.Clear()
	local self = ProfilePane;
	self.is_edit_name = nil;
	self.cur_type = "combatinfo"; 
	self.combatinfo_list = nil;
	self.medal_list = nil;
	self.pvpstat_list = nil;
	self.boss_gsid_list = nil;
end
function ProfilePane.ShowPage(nid,type,zorder)
	local self = ProfilePane;
	nid = tonumber(nid) or Map3DSystem.User.nid;
	self.nid = nid;
	local bag_list = {
		{ bag = 0, search_bag_all = true, },{ bag = 15, search_bag_all = true, },{ bag = 10062, search_bag_all = true, },
	}
	System.App.profiles.ProfileManager.GetUserInfo(nid, "ProfilePane.ShowPage", function(msg)
		BagHelper.SearchBagList(nid,bag_list,function()
			ProfilePane._ShowPage(nid,type,zorder);
		end)	
	end);
end
function ProfilePane._ShowPage(nid,type,zorder)
	local self = ProfilePane;
	if(self.page)then
		self.page:CloseWindow();
	end
	self.Clear();

	self.cur_type = type or "combatinfo";
	zorder = zorder or 1;
	local params = {
				url = "script/apps/Aries/NewProfile/ProfilePane.teen.html", 
				name = "ProfilePane.ShowPage", 
				app_key=MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				enable_esc_key = true,
				style = CommonCtrl.WindowFrame.ContainerStyle,
				allowDrag = true,
				zorder = zorder,
				directPosition = true,
					align = "_ct",
					x = -800/2,
					y = -470/2,
					width = 800,
					height = 470,
		}
	System.App.Commands.Call("File.MCMLWindowFrame", params);
	if(params._page) then
		params._page.OnClose = function(bDestroy)
			Dock.OnClose("ProfilePane.ShowPage")
		end
	end	
	self.GetAllInfo(function(msg)
		if(msg and msg.all_info)then
			local all_info = msg.all_info;
			self.GetRemainPoint = all_info.GetRemainPoint or 0;
			self.GetPowerPipChance = all_info.GetPowerPipChance or 0;
			self.GetOutputHealBoost = all_info.GetOutputHealBoost or 0;
			self.GetAgility = all_info.GetAgility or 0;
			self.GetCriticalStrikeChance = all_info.GetCriticalStrikeChance or 0;
			self.GetResilienceChance = all_info.GetResilienceChance or 0;
			self.GetDodgeChance = all_info.GetDodgeChance or 0;
			self.GetSpellPenetrationChance = all_info.GetSpellPenetrationChance or 0;
			self.GetHitChance = all_info.GetHitChance or 0;
			self.GetCriticalStrikeDamageBonus = all_info.GetCriticalStrikeDamageBonus or 0;
			self.GetHp = all_info.GetHp or 0;

			self.combatinfo_list = all_info.combatinfo_list;
			self.medal_list = all_info.medal_list;
			self.pvpstat_list = all_info.pvpstat_list;
			self.boss_gsid_list = all_info.boss_gsid_list;
			if(self.page)then
				self.page:SetValue("tabscontrol",self.cur_type);
				self.page:Refresh(0.1);
			end
		end
	end)
end
--战斗力
function ProfilePane.DS_Func_Items_combatinfo_list(index)
	local self = ProfilePane;
	if(not self.combatinfo_list)then return 0 end
	if(index == nil) then
		return #(self.combatinfo_list);
	else
		return self.combatinfo_list[index];
	end
end
--徽章
function ProfilePane.DS_Func_Items_medal_list(index)
	local self = ProfilePane;
	if(not self.medal_list)then return 0 end
	if(index == nil) then
		return #(self.medal_list);
	else
		return self.medal_list[index];
	end
end
--pvp战绩
function ProfilePane.DS_Func_Items_pvpstat_list(index)
	local self = ProfilePane;
	if(not self.pvpstat_list)then return 0 end
	if(index == nil) then
		return #(self.pvpstat_list);
	else
		return self.pvpstat_list[index];
	end
end
--boss
function ProfilePane.DS_Func_Items_boss_list(index)
	local self = ProfilePane;
	if(not self.boss_gsid_list)then return 0 end
	if(index == nil) then
		return #(self.boss_gsid_list);
	else
		return self.boss_gsid_list[index];
	end
end
function ProfilePane.GetAllInfo(callbackFunc)
	local self = ProfilePane;
	--战斗力
	local function GetStats(school,type)
		if(self.nid == Map3DSystem.User.nid)then
			return tostring(Combat.GetStats(school,type));
		else
			return tostring(Combat.GetStats(school,type,self.nid));
		end
	end
	--自己剩余训练点
	local function GetRemainPoint()
		if(self.nid == Map3DSystem.User.nid)then
			local hasGSItem = ItemManager.IfOwnGSItem;
			local __,__,__,copies = hasGSItem(22000);
			copies = copies or 0;
			return copies;
		else
			local hasGSItem = ItemManager.IfOPCOwnGSItem;
			local __,__,__,copies = hasGSItem(self.nid,22000);
			copies = copies or 0;
			return copies;
		end
	end
	--超级魔力点生成率
	local function GetPowerPipChance()
		if(self.nid == Map3DSystem.User.nid)then
			return Combat.GetPowerPipChance(nil,nil);
		else
			return Combat.GetPowerPipChance(nil,self.nid);
		end
	end
	--治疗加成
	local function GetOutputHealBoost()
		if(self.nid == Map3DSystem.User.nid)then
			return Combat.GetOutputHealBoost();
		else
			return Combat.GetOutputHealBoost(self.nid);
		end
	end
	--被治疗加成
	local function GetInputHealBoost()
		if(self.nid == Map3DSystem.User.nid)then
			return Combat.GetInputHealBoost();
		else
			return Combat.GetInputHealBoost(self.nid);
		end
	end
	--敏捷
	local function GetAgility()
		return Combat.GetAgility(self.nid);
	end
	--暴击
	local function GetCriticalStrikeChance()
		return Combat.GetCriticalStrikeChance(self.nid);
	end
	--韧性
	local function GetResilienceChance()
		return Combat.GetResilienceChance(self.nid);
	end
	--闪避
	local function GetDodgeChance()
		return Combat.GetDodgeChance(self.nid);
	end
	--穿透
	local function GetSpellPenetrationChance()
		return Combat.GetSpellPenetrationChance(self.nid);
	end
	--命中
	local function GetHitChance()
		return Combat.GetHitChance(self.nid);
	end
	--暴击伤害加成
	local function GetCriticalStrikeDamageBonus()
		return Combat.GetCriticalStrikeDamageBonus(self.nid);
	end
	--hp
	local function GetHp()
		if(self.nid == Map3DSystem.User.nid)then
			return MsgHandler.GetMaxHP();
		else
			local _max_hp = MyCompany.Aries.Combat.GetUpdateMaxHP(nil, self.nid)
			--local _max_hp = MyCompany.Aries.OPC.GetMaxHP(self.nid, function(max_hp)
				--_max_hp = max_hp;
			--end);
			return _max_hp;
		end
	end

	--战斗力
	local combatinfo_list = {
		{label = "风暴系",school = "storm",accuracy = GetStats("storm","accuracy"), damage = GetStats("storm","damage_absolute_base"), resist = GetStats("storm","resist_absolute_base"),},
		{label = "烈火系",school = "fire",accuracy = GetStats("fire","accuracy"), damage = GetStats("fire","damage_absolute_base"), resist = GetStats("fire","resist_absolute_base"),},
		{label = "寒冰系",school = "ice",accuracy = GetStats("ice","accuracy"), damage = GetStats("ice","damage_absolute_base"), resist = GetStats("ice","resist_absolute_base"),},
		{label = "生命系",school = "life",accuracy = GetStats("life","accuracy"), damage = GetStats("life","damage_absolute_base"), resist = GetStats("life","resist_absolute_base"),},
		{label = "死亡系",school = "death",accuracy = GetStats("death","accuracy"), damage = GetStats("death","damage_absolute_base"), resist = GetStats("death","resist_absolute_base"),},
		{label = "平衡系",school = "balance",accuracy = GetStats("balance","accuracy"), damage = GetStats("balance","damage_absolute_base"), resist = GetStats("balance","resist_absolute_base"),},
	};
	--战绩
	local pvpstat_list = {
		{ 
			label = "红蘑菇赛场(1v1)",
			win_count = ProfilePane.GetPvPStats("1v1", "win_count"),
			lose_count = ProfilePane.GetPvPStats("1v1", "lose_count"),
			winning_rate = ProfilePane.GetPvPStats("1v1", "winning_rate"),
			rating = ProfilePane.GetPvPStats("1v1", "rating"),
		},
		{ 
			label = "红蘑菇赛场(2v2)",
			win_count = ProfilePane.GetPvPStats("2v2", "win_count"),
			lose_count = ProfilePane.GetPvPStats("2v2", "lose_count"),
			winning_rate = ProfilePane.GetPvPStats("2v2", "winning_rate"),
			rating = ProfilePane.GetPvPStats("2v2", "rating"),
		},
		--{ 
			--label = "红蘑菇赛场(3v3)",
			--win_count = ProfilePane.GetPvPStats("3v3", "win_count"),
			--lose_count = ProfilePane.GetPvPStats("3v3", "lose_count"),
			--winning_rate = ProfilePane.GetPvPStats("3v3", "winning_rate"),
			--rating = ProfilePane.GetPvPStats("3v3", "rating"),
		--},
		--{ 
			--label = "红蘑菇赛场(4v4)",
			--win_count = ProfilePane.GetPvPStats("4v4", "win_count"),
			--lose_count = ProfilePane.GetPvPStats("4v4", "lose_count"),
			--winning_rate = ProfilePane.GetPvPStats("4v4", "winning_rate"),
			--rating = ProfilePane.GetPvPStats("4v4", "rating"),
		--},
	}
	--徽章
	local medal_list = {
		{label = "赛场英雄徽章", gsid = 20031 ,empty_icon = "Texture/Aries/Profile/MedalPairedPvPArena_Empty_32bits.png", count = nil,},
		{label = "试炼徽章", gsid = 20030 ,empty_icon = "Texture/Aries/Profile/MedalFreePvPTrialOfChampions_Empty_32bits.png", count = nil,},
		{label = "练习奖章", gsid = 20029 ,empty_icon = "Texture/Aries/Profile/MedalFreePvPPractice_Empty_32bits.png", count = nil,},
		{label = "魔塔奇兵徽章", gsids = {20025, 20026, 20027, 20028} ,empty_icon = "Texture/Aries/Profile/MedalEntrance_32bits.png", count = nil,},
		{label = "环保徽章", gsids = {20021, 20022, 20023, 20024} , empty_icon = "Texture/Aries/Profile/MedalEnvironmental_Empty_32bits.png", count = nil,},
		{label = "人气徽章", gsids = {20016, 20017, 20018, 20019} , empty_icon = "Texture/Aries/Profile/MedalPopularity_Empty_32bits.png", count = nil,},
		{label = "友情徽章", gsids = {20005, 20001, 20002, 20003} , empty_icon = "Texture/Aries/Profile/MedalGenerous_Empty_32bits.png", count = nil,},
		{label = "天使徽章", gsids = {20010, 20011, 20012, 20013} , empty_icon = "Texture/Aries/Profile/MedalAngel_Empty_32bits.png", count = nil,},
		{label = "神勇徽章", gsids = {20004, 20006, 20007, 20008} , empty_icon = "Texture/Aries/Profile/MedalPolice_Empty_32bits.png", count = nil,},
		{label = "英雄谷奖章", gsid = 20043 ,empty_icon = "Texture/Aries/Item_Teen/20043_HeroBasinPVPTryOut.png", count = nil,},
		{label = "英雄谷赛场奖章", gsid = 20044 ,empty_icon = "Texture/Aries/Item_Teen/20044_HeroBasinPVPStadium.png", count = nil,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
		{label = "", count = -1,},
	}
	local boss_gsid_list = LobbyHelper.GetBossGsidList();
	if(boss_gsid_list)then
		local k,v;
		for k,v in ipairs(boss_gsid_list) do
			local gsid = v.gsid;
			if(gsid)then
				local item = GemTranslationHelper.GetUserItem(self.nid,gsid);
				if(item and item.copies)then
					v.cnt = item.copies;
				end
			end
		end
		CommonClientService.Fill_List(boss_gsid_list,48);
	end
	local medal_list = {};
	local all_info = {
		GetRemainPoint = GetRemainPoint(),--剩余训练点
		GetPowerPipChance = GetPowerPipChance(),--超级魔力点生成率
		GetOutputHealBoost = GetOutputHealBoost(),--治疗加成
		GetInputHealBoost = GetInputHealBoost(),--被治疗加成
		GetAgility = GetAgility(),--敏捷
		GetCriticalStrikeChance = GetCriticalStrikeChance(),--暴击
		GetResilienceChance = GetResilienceChance(),--韧性
		GetDodgeChance = GetDodgeChance(),--闪避
		GetSpellPenetrationChance = GetSpellPenetrationChance(),--穿透
		GetHitChance = GetHitChance(),--命中
		GetCriticalStrikeDamageBonus = GetCriticalStrikeDamageBonus(),--暴击伤害加成
		GetHp = GetHp(),--血量

		combatinfo_list = combatinfo_list,--战斗力
		pvpstat_list = pvpstat_list,--战绩
		medal_list = medal_list,--徽章

		boss_gsid_list = boss_gsid_list,--成就
	}
	local function filter_medal_list(medal_list)
		
		local pagesize = 64;
		local count = #medal_list;
		local displaycount = math.ceil(count / pagesize) * pagesize;

		if(count == 0 )then
			displaycount = pagesize;
		end
		displaycount = displaycount;
		local i;
		for i = count + 1, displaycount do
			medal_list[i] = { guid = -1};
		end
		return medal_list;
	end
	self.Fill_medal_list(medal_list,function()
		--只显示拥有的徽章
		all_info.medal_list = filter_medal_list(medal_list);
		if(callbackFunc)then
			callbackFunc({
				all_info = all_info,
			});
		end
	end)

end
function ProfilePane.Fill_medal_list(medal_list,callbackFunc)
	local self = ProfilePane;
	if(not medal_list)then return end
	local bag = 10062;
	if(self.nid == Map3DSystem.User.nid)then
		local hasGSItem = ItemManager.IfOwnGSItem;
		ItemManager.GetItemsInBag(bag, "NewProfileHonour_MyMedal", function(msg)
			local count = ItemManager.GetItemCountInBag(bag);
			
			local i;
			for i = 1, count do
				local item = ItemManager.GetItemByBagAndOrder(bag, i);
				if(item) then
					local gsItem = ItemManager.GetGlobalStoreItemInMemory(item.gsid);
					if(gsItem and gsItem.category == "Medal")then
						table.insert(medal_list,{guid = item.guid,});
					end
				end
			end
			if(callbackFunc)then
				callbackFunc();
			end
		end,"access plus 1 minutes");
	else
		ItemManager.GetItemsInOPCBag(self.nid, bag, "NewProfileHonour_OPCMedal", function(msg)
			local count = ItemManager.GetOPCItemCountInBag(self.nid, bag)
			local i;
			for i = 1, count do
				local item = ItemManager.GetOPCItemByBagAndOrder(self.nid,bag, i);
				if(item) then
					local gsItem = ItemManager.GetGlobalStoreItemInMemory(item.gsid);
					if(gsItem and gsItem.category == "Medal")then
						table.insert(medal_list,{guid = item.guid,});
					end
				end
			end
			if(callbackFunc)then
				callbackFunc();
			end
		end,"access plus 1 minutes")
	end
end

-- get ranking item count, taking rankitem_serverdata into consideration. 
-- by lixizhi 2012.12.2
local function GetRankItemCount(nid, gsid, rankitem_serverdata)
	if(not nid or nid == System.App.profiles.ProfileManager.GetNID())then
		local bhas,guid,__,count = hasGSItem(gsid);
		if(not bhas or not count)then
			count = 0;
		else
			local item0 = ItemManager.GetItemByGUID(guid);
			if(item0.serverdata and item0.serverdata~="" and rankitem_serverdata and rankitem_serverdata~=item0.serverdata) then
				count = 0;
			end
		end
		return count;
	else
		local hasGSItem0 = ItemManager.IfOPCOwnGSItem;
		local count = 0;
		local bhas, guid = hasGSItem0(nid, gsid);
		if(bhas)then
			local item0 = ItemManager.GetOPCItemByGUID(nid,guid);
			count = item0.copies;
			if(item0.serverdata and item0.serverdata~="" and rankitem_serverdata and rankitem_serverdata~=item0.serverdata) then
				count = 0;
			end
		end
		return count;
	end
end

--红蘑菇战绩
function ProfilePane.GetPvPStats(arena, type)
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
	local rank_name;
	if(arena == "1v1") then
		base = 20032;
		rank_name = "pk1v1";
	elseif(arena == "2v2") then
		base = 20034;
		rank_name = "pk2v2";
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
		if(arena == "1v1") then
			base = 20046;
		elseif(arena == "2v2") then
			base = 20048;
		end
		base_offset = nil;
	elseif(type == "rating_weighted") then
		if(arena == "1v1") then
			base = 20046;
		elseif(arena == "2v2") then
			base = 20048;
		end
		base_offset = nil;
	end
	local rankitem_serverdata;
	if(rank_name) then
		local rank_data = RankingServer.GetRankByName(rank_name,nil, ExternalUserModule:GetRegionID());
		if(rank_data) then
			rankitem_serverdata = rank_data.rankitem_serverdata;
		end
	end
	local nid = ProfilePane.nid;

	if(base_offset == 0 or base_offset == 1) then
		return tostring(GetRankItemCount(nid, base + base_offset, rankitem_serverdata));
	elseif(base_offset == nil) then
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

		local count1 = GetRankItemCount(nid, base, rankitem_serverdata);
		local count2 = GetRankItemCount(nid, base + 1, rankitem_serverdata);

		if(type == "winning_rate" and count1 == 0 and count2 == 0 and (count1 + count2) == 0) then
			return "0";
		end
				
		if(type == "winning_rate") then
			return tostring(math.ceil(100 * count1 / ((count1 + count2))));
		elseif(type == "rating") then
			--return tostring(math.ceil(rating_revise * count1 * 10 * count1 / ((count1 + count2))));
			return 1000 + count1 - count2;
		elseif(type == "rating_weighted") then
			return tostring(math.ceil(rating_revise * (1000 + count1 - count2)));
		end
	end
	return "";
end
-- get nick name in memory. 
function ProfilePane.GetNicknameInMem()
    local ProfileManager = System.App.profiles.ProfileManager;
    local profile = ProfileManager.GetUserInfoInMemory(ProfileManager.GetNID());
    if(profile) then
        return profile.nickname;
    end
    return "";
end
function ProfilePane.ChangeNickName(nickname,page)
	local self = ProfilePane;
	if(ProfilePane.GetNicknameInMem() == nickname or not nickname) then
		if(page)then
			self.is_edit_name = nil;
			page:Refresh(0.1);
		end
		return;
	end
	nickname = string.gsub(nickname," ","");
	if(string.len(nickname) == 0)then
		_guihelper.MessageBox("名字不能全部为空！");
		return
	end
	local count_charCN = math.floor((string.len(nickname) - ParaMisc.GetUnicodeCharNum(nickname))/2);
	local count_weight = ParaMisc.GetUnicodeCharNum(nickname) + count_charCN;
	
	local certified_nickname = MyCompany.Aries.Chat.BadWordFilter.FilterStringForUserName(nickname);
	if(certified_nickname ~= nickname) then
		_guihelper.MessageBox(format("你的昵称中包含非法语言:%s", certified_nickname));
		return;
	elseif(nickname == "") then
		_guihelper.MessageBox("你还没有名字呢，不能保存！");
		return
	elseif(count_weight > 16) then
		_guihelper.MessageBox("你的昵称太长了，请挑选一个短点的吧。");
		return
	end
	local bOwn, guid, bag, copies = ItemManager.IfOwnGSItem(984);
	copies = copies or 0;
	if(copies < 200)then
		-- _guihelper.MessageBox("改名需要200金币，你的金币不够！");
        _guihelper.Custom_MessageBox("改名需要200金币，你的金币不够！是否充值？",function(result)
	        if(result == _guihelper.DialogResult.Yes)then
                NPL.load("(gl)script/apps/Aries/VIP/PurChaseMagicBean.lua");
                local PurchaseMagicBean = commonlib.gettable("MyCompany.Aries.Inventory.PurChaseMagicBean");
                PurchaseMagicBean.Show()     
	        end
        end,_guihelper.MessageBoxButtons.YesNo);   

		if(self.page)then
			ProfilePane.is_edit_name = false;
			self.page:Refresh(0);
		end
		return
	end
	local function ChangeName_()
		commonlib.echo("=======before change name");
		commonlib.echo(nickname);
		paraworld.users.ChangeNickname({nname = nickname, }, "SetInfoInFullProfile", function(msg)
			commonlib.echo("=======after change name");
			commonlib.echo(msg);
			if(not msg)then return end
			if(msg.issuccess)then
				-- user name changed
				local hook_msg = { aries_type = "UserNameChanged", changed_name = nickname, wndName = "main"};
				CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
				-- auto refresh the user self info in memory
				System.App.profiles.ProfileManager.GetUserInfo();
				-- send nickname update to chat channel
				MyCompany.Aries.BBSChatWnd.SendUserNicknameUpdate();
				
				if(page)then
					self.is_edit_name = nil;
					page:SetValue("FullProfileUserName", nickname);
					page:Refresh(0.1);
					MyCompany.Aries.Desktop.HPMyPlayerArea.UpdateUIByName();
				end
				ItemManager.GetItemsInBag(0, "", function(msg)end, "access plus 0 minutes");
				_guihelper.MessageBox("改名成功！");
			else
				if(msg.errorcode == 418)then
					_guihelper.MessageBox("这个名称已经存在，换一个其他的吧。");
				elseif(msg.errorcode == 443)then
					_guihelper.MessageBox("金币不足，修改名称失败！");
				else
					_guihelper.MessageBox(format("暂时无法改名. 错误码%s", tostring(msg.errorcode)));
				end
			end
		end);
	end
	_guihelper.MessageBox(format("改名要花费200金币，您目前有%d金币, 是否要改名？", copies), function()
		ChangeName_();
	end)
end
function ProfilePane.__ChangeNickName(nickname,page)
	local self = ProfilePane;
	-- do not do anything if nick name is not changed. 
	if(ProfilePane.GetNicknameInMem() == nickname or not nickname) then
		if(page)then
			self.is_edit_name = nil;
			page:Refresh(0.1);
		end
		return;
	end

	local count_charCN = math.floor((string.len(nickname) - ParaMisc.GetUnicodeCharNum(nickname))/2);
	local count_weight = ParaMisc.GetUnicodeCharNum(nickname) + count_charCN;
	
	local certified_nickname = MyCompany.Aries.Chat.BadWordFilter.FilterStringForUserName(nickname);
	if(certified_nickname ~= nickname) then
		_guihelper.MessageBox(format("你的昵称中包含非法语言:%s", certified_nickname));
		return;
	elseif(nickname == "") then
		_guihelper.MessageBox("你还没有名字呢，不能保存！");
		return
	elseif(count_weight > 16) then
		_guihelper.MessageBox("你的昵称太长了，请挑选一个短点的吧。");
		return
	end

	-- nick name free change count
	local bOwn, guid, bag, copies = ItemManager.IfOwnGSItem(981, 1002);
	local max_free_change_name_count = 1;
	local free_changename_left_count = max_free_change_name_count - if_else(bOwn, copies, 0);
	-- local free_changename_left_count = tonumber(Player.LoadLocalData("change_nickname_count", "1")) or 1;

	-- how much glod is needed to change the name. 
	local required_gold_count = ItemManager.GetExtendedCostTemplateFromItemCount(825, nil);

	-- @param bUseGold: whether to use gold to change name.
	local function ChangeName_(bUseGold)
		paraworld.users.setInfo({nickname = nickname, }, "SetInfoInFullProfile", function(msg)
			if(msg and msg.issuccess)then
				-- user name changed
				local hook_msg = { aries_type = "UserNameChanged", changed_name = nickname, wndName = "main"};
				CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
				-- auto refresh the user self info in memory
				System.App.profiles.ProfileManager.GetUserInfo();
				-- send nickname update to chat channel
				MyCompany.Aries.BBSChatWnd.SendUserNicknameUpdate();
				
				if(page)then
					self.is_edit_name = nil;
					page:SetValue("FullProfileUserName", nickname);
					page:Refresh(0.1);
				end
				if(free_changename_left_count > 0) then
					free_changename_left_count = free_changename_left_count -1;
					ItemManager.PurchaseItem(981, 1, function()end, function()end, nil, "none");
					--Player.SaveLocalData("change_nickname_count", tostring(free_changename_left_count));
				end
				LOG.std(nil, "system", "userprofile", "change name success. new name is %s", nickname);
				if(bUseGold) then
					-- now remove gold. we do this last, since even this fail, the user name is gauranteed to be changed. 
					ItemManager.ExtendedCost(825, nil, nil, function(msg)
						if(msg and msg.issuccess)then
							LOG.std(nil, "system", "userprofile", "change name gold removed");
						else
							LOG.std(nil, "error", "userprofile", "change name remove gold failed");
						end
					end)
				end
			end
		end);
	end

	if(MyCompany.Aries.Player.GetLevel() <20) then
		_guihelper.MessageBox(format("20级前可免费改名，此后需要%d金豆，确定要改名吗？",required_gold_count), function()
			ChangeName_(false);
		end);
	elseif(free_changename_left_count>0) then
		_guihelper.MessageBox(format("首次改名免费，此后改名则需要%d金豆，确定要改名吗？",required_gold_count), function()
			ChangeName_(false);
		end);
	else
		local hasGold, _, _, my_gold_count = hasGSItem(17178, 12);
		if(hasGold and my_gold_count and my_gold_count>=required_gold_count) then
			_guihelper.MessageBox(format("改名要花费%d金豆，您目前有%d金豆, 是否要改名？", required_gold_count, my_gold_count), function()
				ChangeName_(true);
			end)
		else
			_guihelper.MessageBox(format("改名要花费%d金豆，您目前有%d金豆. <br/> 收集更多的金豆再来改名吧.", required_gold_count, my_gold_count or 0));
			if(page)then
				self.is_edit_name = nil;
				page:Refresh(0.1);
			end
		end
	end
end

function ProfilePane.GetGearScore()
	if(ProfilePane.nid == System.App.profiles.ProfileManager.GetNID())then
		return Player.GetGearScore();
	else
		local _,_,_,copies =ItemManager.IfOPCOwnGSItem(ProfilePane.nid, 965)
		return copies or 0;
	end
end
