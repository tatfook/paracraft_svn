--[[
Title: 
Author(s): spring
Date: 2011/6/2
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/GoldRankingList/GoldRankingPKListMain_history.lua");
MyCompany.Aries.GoldRankingList.GoldRankingPKListMain.ShowMainWnd();
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatProfile.lua");
local GoldRankingPKListMain = commonlib.gettable("MyCompany.Aries.GoldRankingList.GoldRankingPKListMain");
NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");

GoldRankingPKListMain.listall = {
	["pk"]={
		{name="赛场家族榜",isnew=1,listname="family_pk"},
		--{name="挑战家族总榜",isnew=1,listname="boss_family"},

		{name="挑战总榜 风暴系",isnew=0,listname="storm_All_Boss"},
		{name="挑战总榜 生命系",isnew=0,listname="life_All_Boss"},
		{name="挑战总榜 烈火系",isnew=0,listname="fire_All_Boss"},
		{name="挑战总榜 寒冰系",isnew=0,listname="ice_All_Boss"},
		{name="挑战总榜 死亡系",isnew=0,listname="death_All_Boss"},
		},
};GoldRankingPKListMain.class = GoldRankingPKListMain.class or {};
-- GoldRankingPKListMain.curpage = GoldRankingPKListMain.curpage or "pk_1v1_all";
GoldRankingPKListMain.data = GoldRankingPKListMain.data or {};
GoldRankingPKListMain.curlist = GoldRankingPKListMain.curlist or "pk";
GoldRankingPKListMain.rankdate = nil; 

GoldRankingPKListMain.IsCached = {};

------------------------------------------------------
function GoldRankingPKListMain.Init()
	GoldRankingPKListMain.page = document:GetPageCtrl();

	--NPL.load("(gl)script/apps/Aries/Scene/main.lua");
	--local Scene = commonlib.gettable("MyCompany.Aries.Scene");
	--local serverDate = Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
	--local year,month,day = string.match(serverDate,"(.+)-(.+)-(.+)");
	--year = tonumber(year);
	--month = tonumber(month)-1;
	--if (month==0) then
		--year=year-1;
		--month=12;
	--end
--
	--if (not GoldRankingPKListMain.rankdate) then
		--GoldRankingPKListMain.rankdate = year*100+month;
	--end
end

function GoldRankingPKListMain.SetCacheFalse()
	for s_index in ipairs(GoldRankingPKListMain.class) do
		local listnm=GoldRankingPKListMain.class[s_index].listname;
		GoldRankingPKListMain.IsCached[listnm]=false;
	end
end
--function GoldRankingPKListMain.PurchaseEnergyStone()
    --local gsid=998;
    --Map3DSystem.mcml_controls.pe_item.OnClickGSItem(gsid,true);	
--end
--
function GoldRankingPKListMain.GetCurPage()
	return GoldRankingPKListMain.curpage;
end

function GoldRankingPKListMain.GetCurList()
	return GoldRankingPKListMain.curlist;
end
 
function GoldRankingPKListMain.ChangePage(index)
	index = tonumber(index);
	GoldRankingPKListMain.curpage = GoldRankingPKListMain.class[index].listname;
	-- GoldRankingPKListMain.GetRankingData(GoldRankingPKListMain.curpage);

	if (GoldRankingPKListMain.data[GoldRankingPKListMain.curpage] and GoldRankingPKListMain.IsCached[GoldRankingPKListMain.curpage]) then -- 判断当前项排行榜是否已在内存中
		if (next(GoldRankingPKListMain.data[GoldRankingPKListMain.curpage])~=nil) then

		else
			if (GoldRankingPKListMain.curpage == "family_pk" or GoldRankingPKListMain.curpage == "boss_family") then
				GoldRankingPKListMain.GetFamilyRankingData(GoldRankingPKListMain.curpage);				
			else
				GoldRankingPKListMain.GetRankingData(GoldRankingPKListMain.curpage);
			end
			GoldRankingPKListMain.IsCached[GoldRankingPKListMain.curpage]=true;
		end
	else
		if (GoldRankingPKListMain.curpage == "family_pk"  or GoldRankingPKListMain.curpage == "boss_family") then
			GoldRankingPKListMain.GetFamilyRankingData(GoldRankingPKListMain.curpage);
		else
			GoldRankingPKListMain.GetRankingData(GoldRankingPKListMain.curpage);
		end
		GoldRankingPKListMain.IsCached[GoldRankingPKListMain.curpage]=true;
	end	

	if(GoldRankingPKListMain.page)then
		GoldRankingPKListMain.page:Refresh(0.01);
	end
end

function GoldRankingPKListMain.ChangeList(listtype,combatlvl)
	GoldRankingPKListMain.curlist = listtype;
	if (combatlvl) then
		local tmplist = commonlib.deepcopy(GoldRankingPKListMain.listall[listtype]);
		combatlvl=combatlvl or 50;
		GoldRankingPKListMain.class = GoldRankingPKListMain.FilterPK(tmplist,combatlvl);
	else
		GoldRankingPKListMain.class = commonlib.deepcopy(GoldRankingPKListMain.listall[listtype]);
	end

	GoldRankingPKListMain.curpage = GoldRankingPKListMain.class[1].listname;
	GoldRankingPKListMain.GetRankingData(GoldRankingPKListMain.curpage);
	if(GoldRankingPKListMain.page)then
		GoldRankingPKListMain.page:Refresh(0.01);
	end
end

function GoldRankingPKListMain.FilterPK(ListArray,combatlvl)
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

function GoldRankingPKListMain.ShowMainWnd(zorder,listnm,rdate)
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);

	NPL.load("(gl)script/apps/Aries/Scene/main.lua");
	local Scene = commonlib.gettable("MyCompany.Aries.Scene");
	local serverDate = Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
	local syear,smonth,sday = string.match(serverDate,"(.+)-(.+)-(.+)");
	local month = tonumber(smonth);
	local year = tonumber(syear);

--	if ((month % 2)==0) then
--		month = month-2;
--	else
		month = month-1;
--	end	
	
	if (month<=0) then
		year=year-1;
		month=12+month;
	end

	if (rdate) then
		if (GoldRankingPKListMain.rankdate~=rdate) then
			GoldRankingPKListMain.SetCacheFalse();
		end
		GoldRankingPKListMain.rankdate = rdate;
	else
		GoldRankingPKListMain.SetCacheFalse();
		GoldRankingPKListMain.rankdate = year*100+month;
	end
	
	setlvl=50;	
	GoldRankingPKListMain.ChangeList("pk",setlvl);	
	-- GoldRankingPKListMain.class = commonlib.deepcopy(GoldRankingPKListMain.listall["pk"]);

	if (listnm) then
		GoldRankingPKListMain.curpage = listnm;
	else
		GoldRankingPKListMain.curpage = GoldRankingPKListMain.curpage or "family_pk";
	end

    System.App.Commands.Call("File.MCMLWindowFrame", {
        url = "script/apps/Aries/GoldRankingList/GoldRankingPKListMain_history.html?rdate="..GoldRankingPKListMain.rankdate, 
        app_key = MyCompany.Aries.app.app_key, 
        name = "GoldRankingPKListMain.ShowMainWnd", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
        style = style,
        zorder = zorder or 1,
		enable_esc_key = true,
        allowDrag = false,
		directPosition = true,
            align = "_ct",
            x = -877/2,
            y = -512/2-40,
            width = 877,
            height = 512,
    });


	if (GoldRankingPKListMain.curpage == "family_pk" or GoldRankingPKListMain.curpage == "boss_family") then
		GoldRankingPKListMain.GetFamilyRankingData(GoldRankingPKListMain.curpage);				
	else
		GoldRankingPKListMain.GetRankingData(GoldRankingPKListMain.curpage);
	end
	if(GoldRankingPKListMain.page)then
		GoldRankingPKListMain.page:Refresh(0.01);
	end
end

function GoldRankingPKListMain.DS_Func(index)
	if(index == nil)then
		return #(GoldRankingPKListMain.class);
	else
		return GoldRankingPKListMain.class[index];
	end
end

function GoldRankingPKListMain.DS_Func_Sub(index)
	if(GoldRankingPKListMain.data[GoldRankingPKListMain.curpage])then

		if(index == nil)then
			return #(GoldRankingPKListMain.data[GoldRankingPKListMain.curpage]);
		else
			return GoldRankingPKListMain.data[GoldRankingPKListMain.curpage][index];
		end
	end
end

function GoldRankingPKListMain.GetRankingData(listname, rankdate, callbackFunc)
	local rankdate = tonumber(rankdate or GoldRankingPKListMain.rankdate);
	local rk_id = ExternalUserModule:GetRankID();
	local rank_rid;
	if (rk_id==0) then --taomee
		rank_rid = listname;
	else  -- other co-operator
		rank_rid = listname .. "_"..rk_id;
	end

	paraworld.users.GetPKRanking({listname=rank_rid,date=rankdate},"GoldRankingPKListMain" .. rank_rid, function(msg)
		if(msg and msg.list)then		
			GoldRankingPKListMain.data[listname] = msg.list;

			--commonlib.echo("=================rankid==="..rank_rid.."==rankdate:"..rankdate);
			--commonlib.echo(GoldRankingPKListMain.data[listname]);
			--commonlib.echo(msg);
			--commonlib.echo("==========GoldRankingPKListMain.GetRankingData");
			--commonlib.echo(rank_rid);
			--commonlib.echo(GoldRankingPKListMain.data);
			if(callbackFunc) then
				callbackFunc(msg.list);
			end

			if(GoldRankingPKListMain.page)then
				GoldRankingPKListMain.page:Refresh(0.01);
			end
		end
	end);
end

-- 检查某用户在该系当前排行榜的名次，如果返回101 则不在排行榜内
-- nid: 用户帐号, classid: 用户系别id, rtype: pk_all(天梯总榜),pk_class(赛场系别),boss(挑战系别)，callbackFunc(order): 回调函数，参数是返回值(本系排名，order>100 不在排行榜内）
--
function GoldRankingPKListMain.GetRankPos(nid,classid,rtype,rankdate,callbackFunc)
	local classid = tonumber(classid);
	local rank_id="";
	local chknid = tonumber(nid);
	local rankdate = tonumber(rankdate or GoldRankingPKListMain.rankdate);
	-- local isTop10 = false;
	if (rtype=="pk_all") then
		rank_id="pk_2v2_all";
	elseif (rtype=="pk_class") then
		rank_id="pk";
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
	else  -- other co-operator
		rank_rid = rank_id .. "_"..rk_id;
	end

	rank_rid = string.lower(rank_rid);
	if (GoldRankingPKListMain.data[rank_id]) then
		if (next(GoldRankingPKListMain.data[rank_id])~=nil) then
			local i=1;
			while (i<=100)
			do
				if (GoldRankingPKListMain.data[rank_id][i].nid == chknid) then
					break;
				end
				i=i+1;
			end
			if(callbackFunc) then
				callbackFunc(i);
			end
		else
			paraworld.users.GetPKRanking({listname=rank_rid,date=rankdate},"GoldRankingPKListMain" .. rank_rid, function(msg)
				if(msg and msg.list) then	
					if (next(msg.list)~=nil) then	
						GoldRankingPKListMain.data[rank_id] = msg.list;
						local i=1;
						local find_id=0;
						while (i<=100 and (GoldRankingPKListMain.data[rank_id][i]~=nil))
						do
							if (GoldRankingPKListMain.data[rank_id][i].nid == chknid) then
								find_id=1;
								break;
							end
							i=i+1;
						end

						if(callbackFunc) then
							if (find_id==1) then
								callbackFunc(i);
							else
								callbackFunc(101);
							end
						end
					else
						if(callbackFunc) then
							callbackFunc(101);
						end
					end
				else
					if(callbackFunc) then
						callbackFunc(101);
					end
				end
			end);
		end
	else
		paraworld.users.GetPKRanking({listname=rank_rid,date=rankdate},"GoldRankingPKListMain" .. rank_rid, function(msg)
			if(msg and msg.list)then		
				if (next(msg.list)~=nil) then
					GoldRankingPKListMain.data[rank_id] = msg.list;
					local i=1;
					local find_id=0;
					while (i<=100 and (GoldRankingPKListMain.data[rank_id][i]~=nil))
					do
						if (GoldRankingPKListMain.data[rank_id][i].nid == chknid) then
							find_id=1;
							break;
						end
						i=i+1;
					end
					if(callbackFunc) then
						if (find_id==1) then
							callbackFunc(i);
						else
							callbackFunc(101);
						end
					end
				else
					if(callbackFunc) then
						callbackFunc(101);
					end
				end
			else
				if(callbackFunc) then
					callbackFunc(101);
				end
			end
		end);
	end

end

function GoldRankingPKListMain.GetFamilyRankingData(rank_id, rankdate, callbackFunc)
	local rankdate = tonumber(rankdate or GoldRankingPKListMain.rankdate);
	local rk_id = ExternalUserModule:GetRankID();
	local rank_rid;
	if (rk_id==0) then --taomee
		rank_rid = rank_id;
	else  -- other co-operator
		rank_rid = rank_id .. "_"..rk_id;
	end
	paraworld.users.GetFamilyRank({listname=rank_rid,date=rankdate},"GoldRankingPKListMain" .. rank_rid, function(msg)
		if(msg and msg.list)then		
			local fmrank_his,tmrank={},{};
			local tmp_index;
			for tmp_index,tmprank in ipairs(msg.list) do
				if (tmp_index>20) then break end;
				table.insert(fmrank_his,tmprank);
			end
			GoldRankingPKListMain.data[rank_id] = fmrank_his;

			--commonlib.echo("=================rankid==="..rank_id);
			--commonlib.echo(GoldRankingPKListMain.data[rank_id]);
			-- GoldRankingPKListMain.data[rank_id] = msg.list;

			if(callbackFunc) then
				callbackFunc(msg.list);
			end

			if(GoldRankingPKListMain.page)then
				GoldRankingPKListMain.page:Refresh(0.01);
			end
		end
	end);
end

function GoldRankingPKListMain.GetFrame()
	local s;
	s=string.format([[<iframe name="GoldRankingPKListMainFrame" src="script/apps/Aries/GoldRankingList/GoldRankingListSub_pk_contest_history.html?listname=%s"/>]],GoldRankingPKListMain.curpage);
	return s;
end

function GoldRankingPKListMain.ShowMS(index)
	index = tonumber(index);
	local pagedata = GoldRankingPKListMain.data[GoldRankingPKListMain.curpage];

	if(pagedata)then
		local data = pagedata[index];
		if(data and data.mlvl and data.mlvl > 0 )then
			return true;
		end
	end
end

function GoldRankingPKListMain.ShowMLevel(index)
	index = tonumber(index);
	local pagedata = GoldRankingPKListMain.data[GoldRankingPKListMain.curpage];

	if(pagedata)then
		local data = pagedata[index];
		if(data and data.mlvl and data.mlvl >= 0 )then
			return "Texture/Aries/Desktop/CombatCharacterFrame/MagicStar/" .. data.mlvl .. "_32bits.png;0 0 16 10";
		end
	end

	return "";
end

function GoldRankingPKListMain.OnClickMagicStar(index)
	index = tonumber(index);
	local pagedata = GoldRankingPKListMain.data[GoldRankingPKListMain.curpage];
	if(pagedata)then
		local data = pagedata[index];
		MyCompany.Aries.Desktop.CombatProfile.ShowPage(data.nid);
	end
end