--[[
Title: 
Author(s): spring
Date: 2011/12/8
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/GoldRankingList/GoldRankingListMain.teen.lua");
MyCompany.Aries.GoldRankingList.GoldRankingListMain.ShowMainWnd();
MyCompany.Aries.GoldRankingList.GoldRankingListMain.ShowPage(listname, is_history_data, curlist)
MyCompany.Aries.GoldRankingListMain.SubmitScore(listname, bSilentMode)
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatProfile.lua");
local GoldRankingListMain = commonlib.gettable("MyCompany.Aries.GoldRankingList.GoldRankingListMain");
NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");
NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatProfile.lua");
local RankingServer = commonlib.gettable("MyCompany.Aries.GoldRankingList.RankingServer");

local ItemManager = commonlib.gettable("System.Item.ItemManager");

GoldRankingListMain.listall = nil;


GoldRankingListMain.class = GoldRankingListMain.class or {};
GoldRankingListMain.data = GoldRankingListMain.data or {};
GoldRankingListMain.history_data = GoldRankingListMain.history_data or {};
GoldRankingListMain.rankdate = 0; 

function GoldRankingListMain.Init()
	GoldRankingListMain.LoadRankingList()
	GoldRankingListMain.page = document:GetPageCtrl();
	GoldRankingListMain.rankdate = tonumber(GoldRankingListMain.GetLastMonthDateStr());
end

function GoldRankingListMain.LoadRankingList()
	if(GoldRankingListMain.listall) then
		return
	end
	GoldRankingListMain.listall = {};
	GoldRankingListMain.listall_ds = {};
	local filename;
	if(System.options.version == "teen")then
		filename = "config/Aries/Ranking/ranking_list.teen.xml"
	else
		filename = "config/Aries/Ranking/ranking_list.kids.xml"
	end

	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(xmlRoot) then
		local category;
		for category in commonlib.XPath.eachNode(xmlRoot, "/ranking/category") do
			local category_name = category.attr.name;
			local cat = {};
			GoldRankingListMain.listall[category_name] = cat;
			GoldRankingListMain.listall_ds[category_name] = category;

			local node;
			for node in commonlib.XPath.eachNode(category, "//rank") do
				local attr = node.attr;
				if(attr.isnew == "true") then
					attr.isnew = 1;
				else
					attr.isnew = 0;
				end
				if(attr.lvl) then
					attr.lvl = tonumber(attr.lvl);
				end
				local can_add;
				if(attr.region) then
					local region = tonumber(attr.region);
					if(region) then
						can_add = ExternalUserModule:CanViewRegion(region)
					end
				else
					can_add = true;
				end
				if(can_add) then
					attr.index = #cat+1;
					cat[attr.index] = attr;
				end
			end
		end
	end
end

-- get the last month string like "201109"
function GoldRankingListMain.GetLastMonthDateStr()
	NPL.load("(gl)script/apps/Aries/Scene/main.lua");
	local Scene = commonlib.gettable("MyCompany.Aries.Scene");
	local serverDate = Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
	local year,month,day = string.match(serverDate,"(.+)-(.+)-(.+)");

	day = tonumber(day);
	if (day==1) then
		month = tonumber(month)-1;
		if (month==0) then
			year = tonumber(year)-1;
			month =12;
		else
			year = tonumber(year);
		end
	else
		year = tonumber(year);
		month = tonumber(month);
	end
	return tostring(year*100+month);
end

function GoldRankingListMain.GetCurPage()
	return GoldRankingListMain.curpage;
end

function GoldRankingListMain.GetCurList()
	return GoldRankingListMain.curlist;
end

function GoldRankingListMain.ChangePage(index)
	index = tonumber(index);
	if (index) then
		GoldRankingListMain.cur_item = GoldRankingListMain.class[index];
		GoldRankingListMain.curpage = GoldRankingListMain.cur_item.listname;
	end
	GoldRankingListMain.rankdate_selected = nil;
	local data = GoldRankingListMain.data[GoldRankingListMain.curpage];
	if (not data or #data == 0) then
		if (GoldRankingListMain.curpage == "family_pk" or GoldRankingListMain.curpage == "boss_family") then
			GoldRankingListMain.GetFamilyRankingData(GoldRankingListMain.curpage);
		else
			GoldRankingListMain.GetRankingData(GoldRankingListMain.curpage);
		end
	end	
	if(GoldRankingListMain.page)then
		GoldRankingListMain.page:Refresh(0.01);
	end
end

function GoldRankingListMain.UpdateList()
	if (GoldRankingListMain.data[GoldRankingListMain.curpage]) then
		if (next(GoldRankingListMain.data[GoldRankingListMain.curpage])~=nil) then
			--commonlib.echo("=================GoldRankingListMain.data");
		else
			if (GoldRankingListMain.curpage == "family_pk" or GoldRankingListMain.curpage == "boss_family") then
				GoldRankingListMain.GetFamilyRankingData(GoldRankingListMain.curpage);
			else
				GoldRankingListMain.GetRankingData(GoldRankingListMain.curpage);
			end
		end
	else
		if (GoldRankingListMain.curpage == "family_pk" or GoldRankingListMain.curpage == "boss_family") then
			GoldRankingListMain.GetFamilyRankingData(GoldRankingListMain.curpage);
		else
			GoldRankingListMain.GetRankingData(GoldRankingListMain.curpage);
		end
	end
	if(GoldRankingListMain.page)then
		GoldRankingListMain.page:Refresh(0.01);
	end
end

function GoldRankingListMain.ChangeList(listtype)
	if (not GoldRankingListMain.curlist) then  -- 如果当前排行榜大类不存在，初始化
		GoldRankingListMain.curlist = listtype;
		GoldRankingListMain.class = GoldRankingListMain.listall[listtype];
		-- 取大类第一个列表
		GoldRankingListMain.cur_item = GoldRankingListMain.class[1];
		GoldRankingListMain.curpage = GoldRankingListMain.cur_item.listname;
	elseif (GoldRankingListMain.curlist~=listtype) then -- 如果当前排行榜大类和当前不同，更换
		GoldRankingListMain.curlist = listtype;
		GoldRankingListMain.class = GoldRankingListMain.listall[listtype];
		-- 取大类第一个列表
		GoldRankingListMain.cur_item = GoldRankingListMain.class[1];
		GoldRankingListMain.curpage = GoldRankingListMain.cur_item.listname;
	end
	GoldRankingListMain.rankdate_selected = nil;
	GoldRankingListMain.UpdateList();
end

-- show history
-- @param listname: "family_pve"
-- @param is_history_data: whether we will show history data instead of the newest data. 
function GoldRankingListMain.ShowPage(listname, is_history_data, curlist)
	GoldRankingListMain.LoadRankingList();
	
	if(not listname) then
		listname = "pk_1v1_"..MyCompany.Aries.Player.GetSchool();
	end

	if(not curlist) then
		if(listname == "family_pve") then
			curlist = "explore"
		end
	end
	curlist = curlist or "pk";
	
	GoldRankingListMain.curlist = curlist;
	GoldRankingListMain.class = GoldRankingListMain.listall[curlist];
	if(listname) then
		GoldRankingListMain.cur_item = GoldRankingListMain.GetRankItemByName(listname) or GoldRankingListMain.cur_item;
		GoldRankingListMain.curpage = GoldRankingListMain.cur_item.listname;
	end

	GoldRankingListMain.ShowMainWnd();

	GoldRankingListMain.UpdateList();
end

function GoldRankingListMain.ShowMainWnd()
	GoldRankingListMain.LoadRankingList();

	-- 如果是第一次打开排行榜，初始化 pk 列表
	if (not next(GoldRankingListMain.class)) then  
		GoldRankingListMain.curlist = "pk";
		GoldRankingListMain.class = GoldRankingListMain.listall[GoldRankingListMain.curlist];
		local listname = "pk_1v1_"..MyCompany.Aries.Player.GetSchool();
		GoldRankingListMain.cur_item = GoldRankingListMain.GetRankItemByName(listname);
	end	
	
	if(not GoldRankingListMain.cur_item) then
		GoldRankingListMain.cur_item = GoldRankingListMain.class[1];
	end
	GoldRankingListMain.curpage = GoldRankingListMain.cur_item.listname;
	GoldRankingListMain.rankdate_selected = nil;

    System.App.Commands.Call("File.MCMLWindowFrame", {
        url = "script/apps/Aries/GoldRankingList/GoldRankingListMain.teen.html", 
        app_key = MyCompany.Aries.app.app_key, 
        name = "GoldRankingListMain.ShowMainWnd", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
        style = CommonCtrl.WindowFrame.ContainerStyle,
        zorder = 0,
		enable_esc_key = true,
        allowDrag = false,
		directPosition = true,
            align = "_ct",
            x = -760/2,
            y = -486/2,
            width = 760,
            height = 486,
    });

	if (not GoldRankingListMain.curlist) then 
		GoldRankingListMain.ChangeList("pk");	
	end
end

function GoldRankingListMain.DS_Func(index)
	if(index == nil)then
		return #(GoldRankingListMain.class);
	else
		return GoldRankingListMain.class[index];
	end
end

function GoldRankingListMain.DS_Func_Sub(index)
	if(GoldRankingListMain.rankdate_selected) then
		if(GoldRankingListMain.history_data[GoldRankingListMain.curpage]) then
			local data = GoldRankingListMain.history_data[GoldRankingListMain.curpage][GoldRankingListMain.rankdate_selected];
			if(data) then
				if(index == nil)then
					return #(data);
				else
					return data[index];
				end
			end
		end
	else
		if(GoldRankingListMain.data[GoldRankingListMain.curpage])then
			if(index == nil)then
				return #(GoldRankingListMain.data[GoldRankingListMain.curpage]);
			else
				return GoldRankingListMain.data[GoldRankingListMain.curpage][index];
			end
		end
	end
end

-- get rank item by listname
function GoldRankingListMain.GetRankItemByName(name)
	if(not GoldRankingListMain.item_map) then
		GoldRankingListMain.LoadRankingList();
		GoldRankingListMain.item_map = {};
		local _, items;
		for _, items in pairs(GoldRankingListMain.listall) do
			local _, item;
			for _, item in pairs(items) do
				GoldRankingListMain.item_map[item.listname] = item;
			end
		end
	end
	return GoldRankingListMain.item_map[name];
end

-- GoldRankingListMain.ranktype={"pk_winner","magicstar_level","combat_hero","popularity","dragon_level","dragon_strength","dragon_wisdom","dragon_agility","dragon_kindness",};

-- @param listname: string id, such as "family_pk", "pk_1v1_storm", "pk_1v1_life", "pk_1v1_fire", "pk_1v1_ice", "pk_1v1_death", "pk_1v1_all"
-- @param rankdate: such as "201106", which means 2011.6. if nil, it is current
-- @param callbackFunc: function(data) end, when data is available. This can be nil.
-- @param bNoRefreshPage: true to not refresh the page
function GoldRankingListMain.GetRankingData(listname, rankdate, callbackFunc, cache_policy, bNoRefreshPage)
	-- TODO: the item should be here. 
	local item = GoldRankingListMain.GetRankItemByName(listname)
	if(not item) then
		return
	end
	local rank_id = item.rank_id or item.listname
	local region = ExternalUserModule:GetRegionID();
	local rankdata = RankingServer.GetRankByName(rank_id, item.school, region);

	if(rankdata) then

		local is_boss = if_else(item.is_boss, true, false);
		
		RankingServer.GetRanking(rank_id, rankdate, item.school, region, function(msg, rank)
			if(type(msg) == "table") then
				local _, row
				for _, row in ipairs(msg) do
					-- score=8505,m=0,popularity=0,energy=0,tag=""
					row.field1 = row.score or 0;
					if(row.m and row.m>0) then
						local m = row.m;
						local mins = 24*60 - m%10000;
						local time_str = string.format("%.2d:%.2d", math.floor(mins/60), mins%60)
						local year, month, days = commonlib.timehelp.breakdaynum(commonlib.timehelp.makedaynum(2050, 1, 1) - math.floor(m/10000));
						row.field2 = string.format("%.4d-%.2d-%.2d %s", year, month, days, time_str);
					else
						row.field2 = "";
					end

					if(is_boss and type(row.field1) == "number") then
						local STARTING_ACHIEVEMENT_ROUND = 100000000;
						local field1 = row.field1;
						if(field1 > 10000) then
							field1 = (STARTING_ACHIEVEMENT_ROUND - field1)
							local round = math.floor(field1 / 100000);
							local duration = field1 % 100000;
							duration = string.format("%02d:%02d", math.floor(duration / 60), duration % 60);
							row.field1 = format("%d (%s)", round, duration);
						else
							row.field1 = format("%d", 10000 - field1);
						end
					end
					row.familyname = row.tag or "";
				end
				LOG.std(nil, "debug", "GoldRankingListMain.GetRankingData", msg)
				if(rankdate) then
					GoldRankingListMain.history_data[item.listname] = GoldRankingListMain.history_data[item.listname] or {};
					GoldRankingListMain.history_data[item.listname][rank.rank_date] = msg;
				else
					GoldRankingListMain.data[item.listname] = msg;
				end
				
				if(callbackFunc) then
					callbackFunc(msg);
				end
				if(not bNoRefreshPage and GoldRankingListMain.page)then
					GoldRankingListMain.page:Refresh(0.01);
				end
			end
		end, cache_policy)
		return;
	else
		-- old API
		local rk_id = ExternalUserModule:GetRankID();
		local rank_rid;
		if (rk_id==0) then --taomee
			rank_rid = rank_id;
		else  -- other co-operator
			rank_rid = rank_id .. "_"..rk_id;
		end
		rank_rid = string.lower(rank_rid);
		paraworld.users.GetRanking({rankid=rank_rid,date=tonumber(rankdate)},"GoldRankingListMain" .. rank_rid, function(msg)
			if(msg and msg.list)then		
				GoldRankingListMain.data[rank_id] = msg.list;
				--commonlib.echo("===================="..rank_id);
				--commonlib.echo(GoldRankingListMain.data);
				if(callbackFunc) then
					callbackFunc(msg.list);
				end

				if(not bNoRefreshPage and GoldRankingListMain.page)then
					GoldRankingListMain.page:Refresh(0.01);
				end
			end
		end);
	end
end

function GoldRankingListMain.SubmitScore(listname, bSilentMode)
	local item = GoldRankingListMain.GetRankItemByName(listname);
	if(not item) then
		return;
	end
	local rank_name = item.rank_id or item.listname
	local rankdata = RankingServer.GetRankByName(rank_name, item.school, ExternalUserModule:GetRegionID());

	if(rankdata and rankdata.tag == "family") then
		local ProfileManager = System.App.profiles.ProfileManager;
		local myinfo = ProfileManager.GetUserInfoInMemory(ProfileManager.GetNID());
		if(myinfo and (myinfo.family or "")  == "") then
			if(not bSilentMode) then
				_guihelper.MessageBox("你还没有加入家族; 不能代表家族提交积分.");
			end
			return;
		end
	end

	local function do_submit_(score)
		GoldRankingListMain.last_submit_item = item;
		if(rankdata.only_max) then
			-- TODO: check if we can be on rank. by comparing with my last score and the min score 
		end
		local params = {rank_name=rank_name, gsid=rankdata.gsid, score=score, school = item.school}
		LOG.std(nil, "debug", "ranking.submitscore", params);
		GoldRankingListMain.is_silent_submit = bSilentMode;
		System.GSL_client:SendRealtimeMessage("sPowerAPI", {name="SubmitScore", params=params});
	end

	if(RankingServer.IsSpecialRankingName(rank_name)) then
		local score = RankingServer.GetClientCombatScore(rank_name, item.school)
		if(score and score>0) then
			do_submit_(score);
		else
			if(not bSilentMode) then
				_guihelper.MessageBox("积分太低， 不能提交");
			end
		end

	elseif(rankdata and rankdata.gsid) then
		local bOwn, guid, bag, count = ItemManager.IfOwnGSItem(rankdata.gsid, rankdata.bag);
		
		-- special item. 
		if(rankdata.tag == "family") then
			NPL.load("(gl)script/apps/Aries/Family/FamilyManager.lua");
			local FamilyManager = commonlib.gettable("Map3DSystem.App.Family.FamilyManager");
			local family_manager = FamilyManager.CreateOrGetManager();
			if(rankdata.gsid == 20054 and family_manager.pvp_total_score) then 
				bOwn, count = true, math.max(count or 0, family_manager.pvp_total_score);
			elseif(rankdata.gsid == 20056 and family_manager.pve_total_score) then 
				bOwn, count = true, math.max(count or 0, family_manager.pve_total_score);
			end
		end

		if(bOwn and count and count > 0) then
			do_submit_(count);
		else
			if(not bSilentMode) then
				_guihelper.MessageBox("积分太低， 不能提交");
			end
		end
	else
		if(not bSilentMode) then
			_guihelper.MessageBox("这个榜暂时不能提交");
		end
    end
end

-- called when score is submitted. 
function GoldRankingListMain.OnSubmitScoreCallback(msg)
	LOG.std(nil, "info", "PowerAPIClient.SubmitScore.result", msg);

	if(GoldRankingListMain.is_silent_submit) then	
		return;
	end

	-- refresh the rank list if score is bigger than minscore. 
	if(msg.input_msg and msg.msg and msg.msg.issuccess and msg.msg.minscore and msg.msg.minscore <= msg.input_msg.score) then
		if(msg.msg.minscore < msg.input_msg.score) then
			_guihelper.MessageBox("提交成功！恭喜你榜上有名了！积分和排名刷新可能需要重新或次日登录");
		else
			_guihelper.MessageBox("提交成功！你在末位要加油哦！");
		end
		if(GoldRankingListMain.last_submit_item) then
			GoldRankingListMain.GetRankingData(GoldRankingListMain.last_submit_item.listname , nil, function(msg)
				LOG.std(nil, "info", "PowerAPIClient.SubmitScore.result.updated", "rank %s updated", GoldRankingListMain.last_submit_item.listname);
			end,"access plus 1 seconds");
		end
	else
		if(msg.msg and msg.msg.begin_time) then
			_guihelper.MessageBox(format("排行榜开始提交的时间为:%s<br/>稍后再来提交分数吧！", msg.msg.begin_time));
		else
			_guihelper.MessageBox("提交成功！您的分数不够上榜, 继续努力吧！");
		end
	end
end

function GoldRankingListMain.GetRankPosByListname(nid, listname, callbackFunc)
	local chknid = tonumber(nid or System.User.nid);
	listname = string.lower(listname);

	if (GoldRankingListMain.data[listname]) then
		local i, item;
		for i, item in ipairs(GoldRankingListMain.data[listname]) do
			if(item.nid == chknid) then
				if(callbackFunc) then
					callbackFunc(i);
				end
				return;
			end
		end
		if(callbackFunc) then
			callbackFunc(-1);
		end
	else
		GoldRankingListMain.GetRankingData(listname, nil, function()
			if (GoldRankingListMain.data[listname]) then
				GoldRankingListMain.GetRankPosByListname(nid, listname, callbackFunc);
			end
		end, nil, true)
	end
end

-- 检查某用户在该系当前排行榜的名次，如果返回101 则不在排行榜内
-- nid: 用户帐号, classid: 用户系别id,  rtype: pk(赛场系别),boss(挑战系别)，callbackFunc(order): 回调函数，参数是返回值(本系排名，order>100 不在排行榜内）
--
function GoldRankingListMain.GetRankPos(nid,classid,rtype,callbackFunc)
	local classid = tonumber(classid);
	local rank_id="";
	local chknid = tonumber(nid);
	-- local isTop10 = false;
	if (rtype=="pk") then
		if (classid == 986) then -- fire
			rank_id="pk_1v1_fire";
		elseif (classid == 987) then --ice
			rank_id="pk_1v1_ice";
		elseif (classid == 988) then --storm
			rank_id="pk_1v1_storm";
		elseif (classid == 990) then --life
			rank_id="pk_1v1_life";
		elseif (classid == 991) then --death
			rank_id="pk_1v1_death";
		end
	elseif (rtype=="boss") then
		if (classid == 986) then -- fire
			rank_id="fire_All_Boss"
		elseif (classid == 987) then --ice
			rank_id="ice_All_Boss";
		elseif (classid == 988) then --storm
			rank_id="storm_All_Boss";
		elseif (classid == 990) then --life
			rank_id="life_All_Boss";
		elseif (classid == 991) then --death
			rank_id="death_All_Boss";
		end
	end

	local rk_id = ExternalUserModule:GetRankID();
	local rank_rid;
	if (rk_id==0) then --main operator
		rank_rid = rank_id;
	else  -- other co-operator
		rank_rid = rank_id .. "_"..rk_id;
	end

	GoldRankingListMain.GetRankPosByListname(nid, string.lower(rank_rid), callbackFunc);
end

-- @param rank_id: string id, such as "family_pk"
-- @param rankdate: such as "201106", which means 2011.6. if nil, it is current
-- @param callbackFunc: function(data) end, when data is available. This can be nil.
function GoldRankingListMain.GetFamilyRankingData(rank_id, rankdate, callbackFunc)
	local rankdate = tonumber(rankdate or GoldRankingListMain.rankdate);
	local rk_id = ExternalUserModule:GetRankID();
	local rank_rid;
	if (rk_id==0) then --taomee
		rank_rid = rank_id;
	else  -- other co-operator
		rank_rid = rank_id .. "_"..rk_id;
	end

	rank_rid = string.lower(rank_rid);
	paraworld.users.GetFamilyRank({listname=rank_rid,date=rankdate},"GoldRankingListMain" .. rank_rid, function(msg)
		if(msg and msg.list)then		
			GoldRankingListMain.data[rank_id] = msg.list;
			--commonlib.echo("===================="..rank_id);
			--commonlib.echo(GoldRankingListMain.data);
			if(callbackFunc) then
				callbackFunc(msg.list);
			end
			if(GoldRankingListMain.page)then
				GoldRankingListMain.page:Refresh(0.01);
			end
		end
	end);
end

function GoldRankingListMain.GetFrame()
	local s;

	local function IsBOSSRank(listname)
		local listname=string.lower(listname);
		local isboss=string.find(listname,"_boss");
		return isboss;
	end

	s=string.format([[<iframe name="GoldRankingListMainFrame" src="script/apps/Aries/GoldRankingList/GoldRankingListSub_pk_contest.teen.html?listname=%s"/>]],GoldRankingListMain.curpage);
	return s;
end

function GoldRankingListMain.ShowMS(index)
	index = tonumber(index);
	local pagedata = GoldRankingListMain.data[GoldRankingListMain.curpage];

	if(pagedata)then
		local data = pagedata[index];
		if(data and data.mlvl and data.mlvl > 0 )then
			return true;
		end
	end
end

function GoldRankingListMain.ShowMLevel(index)
	index = tonumber(index);
	local pagedata = GoldRankingListMain.data[GoldRankingListMain.curpage];

	if(pagedata)then
		local data = pagedata[index];
		if(data and data.mlvl and data.mlvl >= 0 )then
			return "Texture/Aries/Desktop/CombatCharacterFrame/MagicStar/" .. data.mlvl .. "_32bits.png;0 0 16 10";
		end
	end

	return "";
end

function GoldRankingListMain.OnClickMagicStar(index)
	index = tonumber(index);
	local pagedata = GoldRankingListMain.data[GoldRankingListMain.curpage];
	if(pagedata)then
		local data = pagedata[index];
		--commonlib.echo("!!:OnClickMagicStar");
		--commonlib.echo(data.nid);
		MyCompany.Aries.Desktop.CombatProfile.ShowPage(data.nid);
	end
end

function GoldRankingListMain.GetLastReward(rankname, rankdata)
	if(GoldRankingListMain.rankdate_selected) then
		if(GoldRankingListMain.history_data[GoldRankingListMain.curpage]) then
			local data = GoldRankingListMain.history_data[GoldRankingListMain.curpage][GoldRankingListMain.rankdate_selected];
			if(data) then
				local my_nid = tonumber(System.User.nid);
				local ranking, item
				local my_ranking;
				for ranking, item in ipairs(data) do
					if(item.nid == my_nid) then
						my_ranking = ranking;
						break;
					end
				end
				if(my_ranking) then
					
					RankingServer.GetMyRankReward(rankname, nil, GoldRankingListMain.cur_item.school, nil, function(msg)
						if(msg) then
							if(msg.issuccess) then
								_guihelper.MessageBox(format("您的排名是%d<br/>奖励已经发到了你的背包中", my_ranking));
							elseif(msg.errorcode == 427) then
								_guihelper.MessageBox("不在可获得奖励的名次范围内");
							elseif(msg.errorcode == 417) then
								_guihelper.MessageBox("已经兑换过奖品了");
							elseif(msg.errorcode == 416) then
								_guihelper.MessageBox("不存在此排行榜的奖励定义");
							elseif(msg.errorcode == 415) then
								_guihelper.MessageBox("排行榜统计还未结束");
							end
						end
					end)
				else	
					_guihelper.MessageBox("你没有上榜，不能领取奖励");
				end
			end
		end
	end
end

function GoldRankingListMain.GetRankingRewardMCML()
	if(GoldRankingListMain.cur_item) then
		local rankname = GoldRankingListMain.cur_item.rank_id or GoldRankingListMain.cur_item.listname;
		local rankdata = RankingServer.GetRankByName(rankname, GoldRankingListMain.cur_item.school, ExternalUserModule:GetRegionID());

		if(rankdata and not GoldRankingListMain.cur_item.reward_mcml) then
			GoldRankingListMain.cur_item.reward_mcml = "";
			local reward = MyCompany.Aries.Scene.GetServerObjectValue("rank_"..tostring(rankdata.rank_id));
			if(reward) then
				local mcml = {};
				-- reward is a string like "1:16086,1;20052,1;17213,5;17178,10|2:16086,1;20052,1;17213,3;17178,5"
				local last_rank_num = 1;
				local rank_num, items;
				for rank_num, items in reward:gmatch("(%d+):([^|]+)") do
					rank_num = tonumber(rank_num);
					if(last_rank_num == rank_num) then
						mcml[#mcml+1] = format([[<div class="default" style="margin-top:5px;">第%d名</div>]], rank_num);
					else
						mcml[#mcml+1] = format([[<div class="default" style="margin-top:5px;">第%d名-第%d名</div>]], last_rank_num, rank_num);
					end
					last_rank_num = rank_num+1;

					mcml[#mcml+1] = [[<div class="default">]];
					local gsid,count;
					for gsid,count in items:gmatch("(%d+),(%d+)") do
						gsid = tonumber(gsid);
						count = tonumber(count);
						mcml[#mcml+1] = format([[<pe:item gsid='%d' isclickable="false" style="float:left;margin:2px;width:32px;height:32px;"/><div style="position:relative;float:left;margin-top:17px;margin-left:-20px;width:22px;text-align:right;">%d</div>]], gsid, count);
					end
					mcml[#mcml+1] = [[</div>]];
				end
				GoldRankingListMain.cur_item.reward_mcml = table.concat(mcml, "")
			end
		end
		return GoldRankingListMain.cur_item.reward_mcml;
	end
end
