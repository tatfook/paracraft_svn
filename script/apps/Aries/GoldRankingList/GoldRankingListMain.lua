--[[
Title: 
Author(s): zrf
Date: 2011/1/24
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/GoldRankingList/GoldRankingListMain.lua");
MyCompany.Aries.GoldRankingList.GoldRankingListMain.ShowMainWnd();
MyCompany.Aries.GoldRankingList.GoldRankingListMain.ShowPage(listname, is_history_data, "pets")
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatProfile.lua");
local GoldRankingListMain = commonlib.gettable("MyCompany.Aries.GoldRankingList.GoldRankingListMain");
NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");
NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatProfile.lua");
local RankingServer = commonlib.gettable("MyCompany.Aries.GoldRankingList.RankingServer");
local ItemManager = commonlib.gettable("System.Item.ItemManager");

GoldRankingListMain.listall = nil;GoldRankingListMain.class = GoldRankingListMain.class or {};
GoldRankingListMain.data = GoldRankingListMain.data or {};
GoldRankingListMain.history_data = GoldRankingListMain.history_data or {};
GoldRankingListMain.cur_item = GoldRankingListMain.cur_item or {};

GoldRankingListMain.rankdate = 0; 


function GoldRankingListMain.Init()
	GoldRankingListMain.LoadRankingList();
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

function GoldRankingListMain.PurchaseEnergyStone()
    local gsid=998;
    Map3DSystem.mcml_controls.pe_item.OnClickGSItem(gsid,true);	
end

function GoldRankingListMain.GetCurPage()
	return GoldRankingListMain.curpage;
end

function GoldRankingListMain.GetCurList()
	return GoldRankingListMain.curlist;
end

function GoldRankingListMain.GetCurItem()
	return GoldRankingListMain.cur_item;
end

function GoldRankingListMain.ChangePage(index)
	index = tonumber(index);
	if (index) then
		GoldRankingListMain.cur_item = GoldRankingListMain.class[index];
		GoldRankingListMain.curpage = GoldRankingListMain.class[index].listname;
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

function GoldRankingListMain.FilterPK(ListArray,combatlvl)
	local _list;
	local result={};
	for _,_list in ipairs(ListArray) do
		if (_list.lvl) then
			if (tonumber(_list.lvl)==combatlvl) then
				table.insert(result,_list);
			end
		else
			table.insert(result,_list);
		end
	end
	return result;
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


function GoldRankingListMain.ChangeList(listtype,combatlvl)
	if (not GoldRankingListMain.curlist) then  -- 如果当前排行榜大类不存在，初始化
		GoldRankingListMain.curlist = listtype;
		if (listtype=="pk") then
			local tmplist = commonlib.deepcopy(GoldRankingListMain.listall[listtype]);
			--combatlvl=combatlvl or 50;
			combatlvl=50;
			GoldRankingListMain.class = GoldRankingListMain.FilterPK(tmplist,combatlvl);
		else
			GoldRankingListMain.class = commonlib.deepcopy(GoldRankingListMain.listall[listtype]);
		end		
		GoldRankingListMain.cur_item = GoldRankingListMain.class[1];
		if(GoldRankingListMain.cur_item) then
			GoldRankingListMain.curpage = GoldRankingListMain.cur_item.listname;
		end
	
	elseif (GoldRankingListMain.curlist~=listtype) then -- 如果当前排行榜大类和当前不同，更换
		GoldRankingListMain.curlist = listtype;
		if (listtype=="pk") then
			local tmplist = commonlib.deepcopy(GoldRankingListMain.listall[listtype]);
			--combatlvl=combatlvl or 50;
			combatlvl=50;
			GoldRankingListMain.class = GoldRankingListMain.FilterPK(tmplist,combatlvl);
		else
			GoldRankingListMain.class = commonlib.deepcopy(GoldRankingListMain.listall[listtype]);
		end
		GoldRankingListMain.cur_item = GoldRankingListMain.class[1];
		if(GoldRankingListMain.cur_item) then
			GoldRankingListMain.curpage = GoldRankingListMain.cur_item.listname;
		end

	elseif (listtype=="pk" and combatlvl) then -- 如果当前排行榜是赛场，并且有需要按等级过滤，更换
		local tmplist = commonlib.deepcopy(GoldRankingListMain.listall[listtype]);
		--combatlvl=combatlvl or 50;
		combatlvl=50;
		GoldRankingListMain.cur_item = GoldRankingListMain.class[1];
		if(GoldRankingListMain.cur_item) then
			GoldRankingListMain.curpage = GoldRankingListMain.cur_item.listname;
		end
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
	if(ExternalUserModule:GetConfig().disable_all_ranking) then
		_guihelper.MessageBox(format("%s排行榜正在紧张的准备中, 近期开放", MyCompany.Aries.ExternalUserModule:GetConfig().company or ""));
		return
	end	

	GoldRankingListMain.LoadRankingList();

	if (not next(GoldRankingListMain.class)) then  -- 如果是第一次打开排行榜，初始化 pk 列表
		--  2012.4.1--2012.4.30 关闭竞技排名
		 --GoldRankingListMain.class = commonlib.deepcopy(GoldRankingListMain.listall["pk"]);			
		GoldRankingListMain.class = commonlib.deepcopy(GoldRankingListMain.listall["explore"]);	
	end	
	
	--  2012.4.1--2012.4.30 关闭竞技排名
	 --GoldRankingListMain.curpage = GoldRankingListMain.curpage or "family_pk";
	GoldRankingListMain.curpage = GoldRankingListMain.curpage or "boss_family";
	-- 如果第一次打开或者当前GoldRankingListMain.curlist指向“英雄谷”排行栏，需要将其指向“探险”排行栏  -- 2013.11.6 lipeng
	if ((not GoldRankingListMain.curlist) or (GoldRankingListMain.curlist == "battlefield" and System.options.version == "kids")) then -- 如果是第一次打开排行榜，初始化 pk 
	--  2012.4.1--2012.4.30 关闭竞技排名
		 --GoldRankingListMain.ChangeList("pk");	
		GoldRankingListMain.ChangeList("explore");	
	end

	if (GoldRankingListMain.curlist=="pk") then
		local bean = MyCompany.Aries.Pet.GetBean();
		local combatlvl,setlvl=0,0;
		if(bean) then
			combatlvl = bean.combatlel or 0;
		end 

		if (combatlvl>=20 and combatlvl<=29) then
			setlvl=20
		elseif (combatlvl>=30 and combatlvl<=39) then
			setlvl=30
		elseif (combatlvl>=40 and combatlvl<=49) then
			setlvl=40
		elseif (combatlvl>=50 or combatlvl<20) then
			setlvl=50
		end	
		setlvl=50;	
		GoldRankingListMain.ChangeList("pk",setlvl);	
	end

    System.App.Commands.Call("File.MCMLWindowFrame", {
        url = "script/apps/Aries/GoldRankingList/GoldRankingListMain.html", 
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
            x = -877/2,
            y = -512/2-40,
            width = 877,
            height = 512,
    });

	if (not GoldRankingListMain.curlist) then 
		GoldRankingListMain.ChangeList("pk");	
	end
end
-- 打开英雄谷排行榜调用这个函数  -- 2013.11.6 lipeng
function GoldRankingListMain.ShowMainWnd_BattleField()
	if(ExternalUserModule:GetConfig().disable_all_ranking) then
		_guihelper.MessageBox(format("%s排行榜正在紧张的准备中, 近期开放", MyCompany.Aries.ExternalUserModule:GetConfig().company or ""));
		return
	end	

	GoldRankingListMain.LoadRankingList();

	if (not next(GoldRankingListMain.class)) then  -- 如果是第一次打开排行榜，初始化 pk 列表
		--  2012.4.1--2012.4.30 关闭竞技排名
		 --GoldRankingListMain.class = commonlib.deepcopy(GoldRankingListMain.listall["pk"]);			
		GoldRankingListMain.class = commonlib.deepcopy(GoldRankingListMain.listall["explore"]);	
	end	
	
	--  2012.4.1--2012.4.30 关闭竞技排名
	 --GoldRankingListMain.curpage = GoldRankingListMain.curpage or "family_pk";
	GoldRankingListMain.curpage = GoldRankingListMain.curpage or "boss_family";
	
		GoldRankingListMain.ChangeList("battlefield");	

	if (GoldRankingListMain.curlist=="pk") then
		local bean = MyCompany.Aries.Pet.GetBean();
		local combatlvl,setlvl=0,0;
		if(bean) then
			combatlvl = bean.combatlel or 0;
		end 

		if (combatlvl>=20 and combatlvl<=29) then
			setlvl=20
		elseif (combatlvl>=30 and combatlvl<=39) then
			setlvl=30
		elseif (combatlvl>=40 and combatlvl<=49) then
			setlvl=40
		elseif (combatlvl>=50 or combatlvl<20) then
			setlvl=50
		end	
		setlvl=50;	
		GoldRankingListMain.ChangeList("pk",setlvl);	
	end

    System.App.Commands.Call("File.MCMLWindowFrame", {
        url = "script/apps/Aries/GoldRankingList/GoldRankingPKListMain_battlefield.html", 
        app_key = MyCompany.Aries.app.app_key, 
        name = "GoldRankingListMain.ShowMainWnd_BattleField", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
        style = CommonCtrl.WindowFrame.ContainerStyle,
        zorder = 0,
		enable_esc_key = true,
        allowDrag = false,
		directPosition = true,
            align = "_ct",
            x = -837/2,
            y = -512/2,
            width = 837,
            height = 512,
    });

	--GoldRankingListMain.ChangeList("battlefield");	
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

-- @param rank_id: string id, such as "family_pk", "pk_1v1_storm", "pk_1v1_life", "pk_1v1_fire", "pk_1v1_ice", "pk_1v1_death", "pk_1v1_all"
-- @param rankdate: such as "201106", which means 2011.6. if nil, it is current
-- @param callbackFunc: function(data) end, when data is available. This can be nil.
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
					row.familyname = row.tag or "";
				end

				if(#msg== 50 and System.options.isAB_SDK) then
					-- TODO: making every user can see it. 
					-- fetching the second page, if user still stays on the page 
					local last_msg = msg;
					-- fetch the second page
					RankingServer.GetRanking(rank_id, rankdate, item.school, region, function(msg, rank)
						if(type(msg) == "table") then
							local index, row
							for index, row in ipairs(msg) do
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
								row.familyname = row.tag or "";
								last_msg[50+index] = row;
							end
						end
						msg = last_msg;
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
					end, nil, 1)
					return;
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
		paraworld.users.GetRanking({rankid=string.lower(rank_rid),date=tonumber(rankdate)},"GoldRankingListMain" .. rank_rid, function(msg)
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


function GoldRankingListMain.SubmitScore(listname)
	local item = GoldRankingListMain.GetRankItemByName(listname);
	if(not item) then
		return;
	end
	local rank_name = item.rank_id or item.listname
	local rankdata = RankingServer.GetRankByName(rank_name, item.school, ExternalUserModule:GetRegionID());

	if(item.tag == "family") then
		local ProfileManager = System.App.profiles.ProfileManager;
		local myinfo = ProfileManager.GetUserInfoInMemory(ProfileManager.GetNID());
		if(myinfo and (myinfo.family or "")  == "") then
			_guihelper.MessageBox("你还没有加入家族; 不能代表家族提交积分.");
			return;
		end
	end

	local function do_submit_(score)
		GoldRankingListMain.last_submit_item = item;
		local params = {rank_name=rank_name, gsid=rankdata.gsid, score=score, school = item.school}
		LOG.std(nil, "debug", "ranking.submitscore", params);
		System.GSL_client:SendRealtimeMessage("sPowerAPI", {name="SubmitScore", params=params});
	end

	if(RankingServer.IsSpecialRankingName(rank_name)) then
		local score = RankingServer.GetClientCombatScore(rank_name, item.school)
		if(score and score>0) then
			do_submit_(score);
		else
			_guihelper.MessageBox("积分太低， 不能提交");
		end

	elseif(rankdata and rankdata.gsid) then
		local bOwn, guid, bag, count = ItemManager.IfOwnGSItem(rankdata.gsid, rankdata.bag)
		if(bOwn and count > 0) then
			do_submit_(count);
		else
			_guihelper.MessageBox("积分太低， 不能提交");
		end
	else
		_guihelper.MessageBox("这个榜暂时不能提交");
    end
end

-- called when score is submitted. 
function GoldRankingListMain.OnSubmitScoreCallback(msg)
	LOG.std(nil, "info", "PowerAPIClient.SubmitScore.result", msg);
	
	-- refresh the rank list if score is bigger than minscore. 
	if(msg.input_msg and msg.msg and msg.msg.issuccess and msg.msg.minscore and msg.msg.minscore <= msg.input_msg.score) then
		if(msg.msg.minscore < msg.input_msg.score) then
			_guihelper.MessageBox("提交成功！恭喜你榜上有名了！");
		else
			_guihelper.MessageBox("提交成功！你在末位要加油哦！");
		end
		if(GoldRankingListMain.last_submit_item) then
			GoldRankingListMain.GetRankingData(GoldRankingListMain.last_submit_item.listname , nil, function(msg)
				LOG.std(nil, "info", "PowerAPIClient.SubmitScore.result.updated", "rank %s updated", GoldRankingListMain.last_submit_item.listname);
			end,"access plus 1 seconds");
		end
	else
		_guihelper.MessageBox("提交成功！您的分数不够上榜, 继续努力吧！");
	end
end

function GoldRankingListMain.GetRankPosByListname(nid, listname, callbackFunc)
	local chknid = tonumber(nid or System.User.nid);
	
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
-- nid: 用户帐号, classid: 用户系别id, rtype: pk_all(天梯总榜),pk_class(赛场系别),boss(挑战系别)，callbackFunc(order): 回调函数，参数是返回值(本系排名，order>100 不在排行榜内）
--
function GoldRankingListMain.GetRankPos(nid,classid,rtype,callbackFunc)
	local classid = tonumber(classid);
	local rank_id="";
	local chknid = tonumber(nid);
	-- local isTop10 = false;
	if (rtype=="pk_all") then
		rank_id = "pk_2v2_all";
	elseif (rtype=="pk_class") then
		local bean = MyCompany.Aries.Pet.GetBean(nid);
		local combatlvl;
		if(bean) then
			combatlvl = bean.combatlel or 0;
		end 
		combatlvl=50;
		
		if(not ExternalUserModule:GetConfig().use_oldranking_api) then
			rank_id="pk";
		else
			if (combatlvl>=50 or combatlvl<20) then
				rank_id="pk";
			elseif(combatlvl>=40 and combatlvl<=49) then
				rank_id="pk4047";
			elseif(combatlvl>=30 and combatlvl<=39) then
				rank_id="pk3039";
			elseif(combatlvl>=20 and combatlvl<=29) then
				rank_id="pk2029";
			end
		end

		if (classid == 986) then -- fire
			rank_id=string.format("%s_2v2_fire",rank_id);
		elseif (classid == 987) then --ice
			rank_id=string.format("%s_2v2_ice",rank_id);
		elseif (classid == 988) then --storm
			rank_id=string.format("%s_2v2_storm",rank_id);
		elseif (classid == 990) then --life
			rank_id=string.format("%s_2v2_life",rank_id);
		elseif (classid == 991) then --death
			rank_id=string.format("%s_2v2_death",rank_id);
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
	if (rk_id==0) then --taomee
		rank_rid = rank_id;
	else  -- other co-operator, obsoleted
		rank_rid = rank_id .. "_"..rk_id;
	end
	GoldRankingListMain.GetRankPosByListname(nid, rank_rid, callbackFunc);
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

	paraworld.users.GetFamilyRank({listname=string.lower(rank_rid),date=rankdate},"GoldRankingListMain" .. rank_rid, function(msg)
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
--	local s=string.format([[<iframe name="GoldRankingListMainFrame" src="script/apps/Aries/GoldRankingList/GoldRankingListSub_%d.html"/>]],
--						GoldRankingListMain.curpage );
	local s;

	local function IsBOSSRank(listname)
		local isboss=string.find(string.lower(listname),"_boss");
		if (isboss) then
			return true
		else
			return false
		end			
	end

	local item = GoldRankingListMain.GetRankItemByName(GoldRankingListMain.curpage)
	if(not item) then
		return
	end
	local rank_id = item.rank_id or item.listname
	local rankdata = RankingServer.GetRankByName(rank_id, item.school, ExternalUserModule:GetRegionID());
	if(rankdata) then
		if(GoldRankingListMain.curlist == "battlefield" and System.options.version == "kids") then  -- 如果是英雄谷排行榜调用对应的英雄谷frame文件  213.11.6 lipeng
			s=string.format([[<iframe name="GoldRankingListMainFrame" src="script/apps/Aries/GoldRankingList/GoldRankingListSub_battlefield_contest.html?listname=%s"/>]],GoldRankingListMain.curpage);
		elseif(GoldRankingListMain.cur_item) then
			s = [[<iframe name="GoldRankingListMainFrame" src="script/apps/Aries/GoldRankingList/GoldRankingListSub_common.html"/>]];
		end
	else
		-- old ranking 
		if (GoldRankingListMain.curlist == "pk" and GoldRankingListMain.curpage ~= "pk_winner") then	
			s=string.format([[<iframe name="GoldRankingListMainFrame" src="script/apps/Aries/GoldRankingList/GoldRankingListSub_pk_contest.html?listname=%s"/>]],GoldRankingListMain.curpage);
		elseif (GoldRankingListMain.curlist == "explore" and (GoldRankingListMain.curpage == "family_level" or GoldRankingListMain.curpage == "homevisit" or GoldRankingListMain.curpage == "popularity" )) then
			s=string.format([[<iframe name="GoldRankingListMainFrame" src="script/apps/Aries/GoldRankingList/GoldRankingListSub_popularity.html?listname=%s"/>]],GoldRankingListMain.curpage );
		elseif (GoldRankingListMain.curlist == "explore" and IsBOSSRank(GoldRankingListMain.curpage)) then
			s=string.format([[<iframe name="GoldRankingListMainFrame" src="script/apps/Aries/GoldRankingList/GoldRankingListSub_pve_boss.html?listname=%s"/>]],GoldRankingListMain.curpage);
		elseif (GoldRankingListMain.curlist == "explore" and GoldRankingListMain.curpage == "boss_family") then
			s=string.format([[<iframe name="GoldRankingListMainFrame" src="script/apps/Aries/GoldRankingList/GoldRankingListSub_pk_contest.html?listname=%s"/>]],GoldRankingListMain.curpage);
		else
			s=string.format([[<iframe name="GoldRankingListMainFrame" src="script/apps/Aries/GoldRankingList/GoldRankingListSub_%s.html"/>]],
								GoldRankingListMain.curpage );
		end
	end
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
	--local pagedata = GoldRankingListMain.data[1];
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
								_guihelper.MessageBox("已经兑换过或已经自动发送过奖品了. 请查看你的背包或邮件.");
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

local extra_rewards_list = {};

local function initExtraRewardList()
	local file = "config/Aries/Ranking/ranking_list_reward.kids.xml";
	local xmlRoot = ParaXML.LuaXML_ParseFile(file);
	if(xmlRoot) then
		local list_rewards = {};
		local reward = {};
		local each_list;
		for each_list in commonlib.XPath.eachNode(xmlRoot, "/rewards/listname") do
			list_reward = {};
			local name = each_list.attr.name;

			local each_reward;
			for each_reward in commonlib.XPath.eachNode(each_list, "/reward") do
				reward = {};
				reward.note = each_reward.attr.note;
				reward.gsids = each_reward.attr.gsids;
				table.insert(list_rewards,reward);
			end

			extra_rewards_list[name] = list_rewards;
		end
	end
end

function GoldRankingListMain.GetRankingRewardMCML(listname)
	if(listname) then
		if(next(extra_rewards_list) == nil) then
			initExtraRewardList();
		end
		local reward_mcml;
		reward = extra_rewards_list[listname];
		if(reward) then
			local mcml = {};
			local item;
			for i = 1,#reward do
				item = reward[i];
				if(item.note) then
					mcml[#mcml+1] = format([[<div class="default" style="font-size:13px;font-weight:bolder;margin-top:5px;color:#FCEA98">%s</div>]], item.note);
				end
				mcml[#mcml+1] = [[<div class="default">]];
				local gsids = item.gsids;
				local gsid,count;
				for gsid,count in gsids:gmatch("(%d+),(%d+)") do
					gsid = tonumber(gsid);
					count = tonumber(count);
					mcml[#mcml+1] = format([[<pe:item gsid='%d' isclickable="false" style="float:left;margin:2px;margin-left:10px;width:40px;height:40px;"/><div style="position:relative;float:left;margin-top:20px;margin-left:-45px;width:58px;text-align:right;color:#FCEA98">%d</div>]], gsid, count);
						
				end
				mcml[#mcml+1] = [[</div>]];
			end
			reward_mcml = table.concat(mcml, "")
		end
		return reward_mcml or "";
	end


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
						mcml[#mcml+1] = format([[<div class="default" style="font-weight:bolder;margin-top:5px;color:#FCEA98">[第%d名]</div>]], rank_num);
					else
						mcml[#mcml+1] = format([[<div class="default" style="font-weight:bolder;margin-top:10px;color:#FCEA98">[第%d名-第%d名]</div>]], last_rank_num, rank_num);
					end
					last_rank_num = rank_num+1;

					mcml[#mcml+1] = [[<div class="default">]];
					local gsid,count;
					for gsid,count in items:gmatch("(%d+),(%d+)") do
						gsid = tonumber(gsid);
						count = tonumber(count);
						mcml[#mcml+1] = format([[<pe:item gsid='%d' isclickable="false" style="float:left;margin:2px;margin-left:10px;width:32px;height:32px;"/><div style="position:relative;float:left;margin-top:17px;margin-left:-45px;width:58px;text-align:right;color:#FCEA98">%d</div>]], gsid, count);
						
					end
					mcml[#mcml+1] = [[</div>]];
				end
				GoldRankingListMain.cur_item.reward_mcml = table.concat(mcml, "")
			end
		end
		return GoldRankingListMain.cur_item.reward_mcml;
	end
end

function GoldRankingListMain.GetListViewDS()
	local viewlist = {}
	local gearScore = MyCompany.Aries.Player.GetGearScore();
	local listtype = GoldRankingListMain.curlist;
	local curselectedlist = GoldRankingListMain.listall_ds[listtype];
	for i = 1,#curselectedlist do
		local item = curselectedlist[i];
		--if(item.attr and item.attr.listname and string.match(item.attr.listname,"pk1v1")) then
			--local min_gs = if_else(item.attr.min_gs,tonumber(item.attr.min_gs),nil);
			--local max_gs = if_else(item.attr.max_gs,tonumber(item.attr.max_gs),nil);
			--if(not min_gs or (min_gs and gearScore >= min_gs)) then
				--if(not max_gs or (max_gs and gearScore <= max_gs)) then
					--table.insert(viewlist,item);		
				--end
			--end
		if(listtype == "pk" and item.name == "folder" and (string.match(item.attr.name,"1v1") or string.match(item.attr.name,"2v2"))) then
			local min_gs = if_else(item.attr.min_gs,tonumber(item.attr.min_gs),nil);
			local max_gs = if_else(item.attr.max_gs,tonumber(item.attr.max_gs),nil);
			if(not min_gs or (min_gs and gearScore >= min_gs)) then
				if(not max_gs or (max_gs and gearScore <= max_gs)) then
					table.insert(viewlist,item);		
				end
			end
		else
			table.insert(viewlist,item);
		end
	end
	return viewlist;
end

function GoldRankingListMain.OpenAwardPage(listname)
	System.App.Commands.Call("File.MCMLWindowFrame", {
        url = string.format("script/apps/Aries/GoldRankingList/GoldRankingListSub_Display_Award.html?listname=%s",listname), 
        app_key = MyCompany.Aries.app.app_key, 
        name = "GoldRankingListMain.OpenAwardPage", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
        style = CommonCtrl.WindowFrame.ContainerStyle,
        zorder = 0,
		enable_esc_key = true,
        allowDrag = false,
		directPosition = true,
            align = "_ct",
            x = -300/2,
            y = -262/2,
            width = 300,
            height = 262,
    });
end