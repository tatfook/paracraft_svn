--[[
Title: ranking api on the server side. 
Author(s): LiXizhi
Date: 2012/11/6
Desc: all server side ranking 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/GoldRankingList/ranking_server.lua");
local RankingServer = commonlib.gettable("MyCompany.Aries.GoldRankingList.RankingServer");
RankingServer.Init();
RankingServer.SubmitScore("xiandou", "295285926", nil, nil, function(msg) echo(msg) end);
RankingServer.SubmitScore("pk1v1", "295285926", 478, 1000, function(msg) end, 10, "life");

RankingServer.GetRanking("pk1v1", "20121102", "life")
RankingServer.GetMyRankIndex("pk1v1")
RankingServer.RecomputeRankDate("20120102")
RankingServer.GetMyRankReward("pk1v1")
RankingServer.GetSingleComputedRank("xiandou", "20121129")
RankingServer.Dump();
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/DateTime.lua");
NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");

local PowerItemManager = commonlib.gettable("Map3DSystem.Item.PowerItemManager");
local RankingServer = commonlib.gettable("MyCompany.Aries.GoldRankingList.RankingServer");

local ranking_map =  {
	-- @param region can be date string or nil.  we can seperate rank list according to region 
	-- @param school: nil or "fire","ice",etc. We usually need to seperate rank list according to player school.
	-- @param rank_id: the rank_id. must be [0,999] 
	-- @param seasonly:  array of month_day when a new season begins. for a rank that begins on the first day every two month, 
	--	we can write {"0101", "0301", "0501", "0701", "0901", "1101"}, for a quaterly rank {"0101", "0401", "0701", "1001"}
	-- @param monthly: if available, it will be a monthly rank list. This is the day the of month, when a new rank begins. must be 2 digits, such as "01"
	-- @param weekly: if available, it will be a weekly rank list. This is the day the of week. "1" stands for monday, "7" is sunday. 
	-- @param single_rank: TODO: if true, the rank never expires.
	-- @param newuser_submit_times="4". Suppse the time difference between the current rank date and last is 1 months and current rank_date is 20130501, 
	--  then newuser_submit_times = "4" means that 4*1=4. users whose birthday is bigger than 20130101 can submit to this rank. in other words, 
	--  any new user can submit exactly 4 times to this rank. this applies to monthly, weekly, daily and seasonly ranks. 
	--		@note: A special meaning for seasonly rank is that this value matches to months. 
	-- @param whether we will passthrough to another rank. 
	--["pk1v1"] = {
		--{rank_id = "1",  monthly="01", school="ice", region=nil, minscore = 0, }, 
		--{rank_id = "2",  monthly="01", school="fire", region=nil, minscore = 0, }, 
		--{rank_id = "3",  monthly="01", school="life", region=nil, minscore = 0, }, 
		--{rank_id = "4",  monthly="01", school="death", region=nil, minscore = 0, }, 
		--{rank_id = "5",  monthly="01", school="storm", region=nil, minscore = 0, }, 
	--},
	--["pk1v1_practice"] = {
		--{rank_id = "10",  gsid=20051, weekly=1, region=nil, minscore = 0, }, 
	--},
	--["pk2v2"] = {
		--{rank_id = "21",  monthly="01", school="ice", region=nil, minscore = 0, }, 
		--{rank_id = "22",  monthly="01", school="fire", region=nil, minscore = 0, }, 
		--{rank_id = "23",  monthly="01", school="life", region=nil, minscore = 0, }, 
		--{rank_id = "24",  monthly="01", school="death", region=nil, minscore = 0, }, 
		--{rank_id = "25",  monthly="01", school="storm", region=nil, minscore = 0, }, 
	--},
	--["popularity"] = {
		--{rank_id = "107",  gsid=-101, weekly="1", region=nil, minscore = 0, }, 
	--},
};

local cur_date_str = "1982-11-26";

function RankingServer.Init()
	if(not RankingServer.is_inited) then
		RankingServer.is_inited = true;

		local filename;
		if(System.options.version == "teen")then
			filename = "config/Aries/Ranking/ranking_server.teen.xml"
		else
			filename = "config/Aries/Ranking/ranking_server.kids.xml"
		end

		local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
		if(xmlRoot) then
			local node;
			for node in commonlib.XPath.eachNode(xmlRoot, "/ranking/rank") do
				if(node.attr and node.attr.name) then
					local rank = {};
					ranking_map[node.attr.name] = rank;
					
					local _, item;
					for _, item in ipairs(node) do
						local attr =  item.attr;
						if(attr.gsid) then
							attr.gsid = tonumber(attr.gsid);
							if(System.options.version == "kids" and attr.ignore_gsid and attr.ignore_gsid == "true") then
								attr.gsid = nil;
							end
						end
						if(attr.weekly) then
							attr.weekly = tonumber(attr.weekly);
						end
						if(attr.seasonly) then
							attr.seasonly = commonlib.LoadTableFromString(attr.seasonly);
						end
						if(attr.onlymax == "true") then
							attr.onlymax = 1;
						end
						if(attr.bag) then
							attr.bag = tonumber(attr.bag);
						end
						if(attr.region) then
							attr.region = tonumber(attr.region);
						end
						if(attr.newuser_submit_times) then
							attr.newuser_submit_times = tonumber(attr.newuser_submit_times);
						end

						attr.tag = attr.tag or "";

						attr.minscore = tonumber(attr.minscore) or 0;
						rank[#rank+1] = attr;
					end
				end
			end
		end
		RankingServer.CheckLogTime();
	end
end

function RankingServer.GetRankByName(name, school, region)
	local rank = ranking_map[name];
	if(rank) then
		local nCount = #rank;
		local i;
		for i = 1, nCount do
			local rank_data = rank[i];
			if(rank_data and (not school or not rank_data.school or rank_data.school == school) and (not region or not rank_data.region or rank_data.region == region)) then
				return rank_data;
			end	
		end
	end
end

-- print internal ranking state
function RankingServer.Dump()
	commonlib.log(commonlib.serialize(ranking_map, true));
end

-- @param rank_data: the rank data 
-- @param year, month, day: if nil, the client side's time is used.  year can also be "YYYYMMDD", otherwise it must be number.
function RankingServer.RecomputeRankItem(rank_data, year, month, day)
	if(not year or type(year) == "string") then
		local date_str = year or MyCompany.Aries.Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
		year, month, day = date_str:match("^(%d%d%d%d)%D*(%d%d)%D*(%d%d)$");
		year = tonumber(year);
		month = tonumber(month);
		day = tonumber(day);
	end
	if(rank_data.monthly) then
		begin_day = tonumber(rank_data.monthly);
		begin_month = month;
		begin_year = year;
		if(begin_day <= day) then
			begin_month = begin_month + 1;
			if(begin_month>12) then
				begin_month = 1;
				begin_year = year +1;
			end
		end
		last_year = begin_year;
		last_month = begin_month - 1
		if(last_month<=0) then
			last_year = last_year -1;	
			last_month = 12;
		end
		if(rank_data.newuser_submit_times) then
			local birth_year = begin_year;
			local birth_month = begin_month - rank_data.newuser_submit_times*1
			if(birth_month<=0) then
				birth_year = birth_year - 1;
				birth_month = 12 + birth_month;
			end
			rank_data.min_birthday = string.format("%04d%02d%02d", birth_year, birth_month, begin_day);
		end
		rank_data.rank_date = string.format("%04d%02d%02d", begin_year, begin_month, begin_day);
		rank_data.last_rank_date = string.format("%04d%02d%02d", last_year, last_month, begin_day);
		rank_data.fullname = string.format("%s%03d", rank_data.rank_date, tonumber(rank_data.rank_id));
		rank_data.last_fullname = string.format("%s%03d", rank_data.last_rank_date, tonumber(rank_data.rank_id));
		rank_data.minscore = 0;
	elseif(rank_data.seasonly) then
		local cur_date = month*100+day;
		local index, begin_date;
		for index, begin_date in ipairs(rank_data.seasonly) do
			local date = tonumber(begin_date);
			if(cur_date<date) then
				rank_data.rank_date = string.format("%04d%s", year, begin_date);
				if(index <= 1) then
					rank_data.last_rank_date = string.format("%04d%s", year-1, rank_data.seasonly[#(rank_data.seasonly)]);
				else
					rank_data.last_rank_date = string.format("%04d%s", year, rank_data.seasonly[index-1]);
				end
				break;
			elseif(cur_date == date or index == #(rank_data.seasonly) ) then
				rank_data.last_rank_date = string.format("%04d%s", year, begin_date);
				if(index == #(rank_data.seasonly)) then
					rank_data.rank_date = string.format("%04d%s", year+1, rank_data.seasonly[1]);
				else
					rank_data.rank_date = string.format("%04d%s", year, rank_data.seasonly[index+1]);
				end
				break;
			end
		end

		if(rank_data.newuser_submit_times) then
			local begin_year, begin_month, begin_day = rank_data.rank_date:match("(%d%d%d%d%d)(%d%d)(%d%d)");
			begin_year, begin_month, begin_day = tonumber(begin_year), begin_year(begin_month), begin_year(begin_day);
			if(begin_year) then
				local birth_year = begin_year;
				local birth_month = begin_month - rank_data.newuser_submit_times*1
				if(birth_month<=0) then
					birth_year = birth_year - 1;
					birth_month = 12 + birth_month;
				end
				rank_data.min_birthday = string.format("%04d%02d%02d", birth_year, birth_month, begin_day);
			end
		end

		rank_data.fullname = string.format("%s%03d", rank_data.rank_date, tonumber(rank_data.rank_id));
		rank_data.last_fullname = string.format("%s%03d", rank_data.last_rank_date, tonumber(rank_data.rank_id));
		rank_data.minscore = 0;
	elseif(rank_data.weekly) then
		local dayofweek = commonlib.timehelp.get_day_of_week(year, month, day)
		local begin_weekday = tonumber(rank_data.weekly);

		local offset_days = begin_weekday - dayofweek;
		if(offset_days <= 0) then
			offset_days = offset_days + 7;
		end
		local begin_year, begin_month, begin_day = commonlib.timehelp.get_next_date(year,month, day, offset_days)
		local last_year, last_month, last_day = commonlib.timehelp.get_next_date(year,month, day, offset_days-7)

		if(rank_data.newuser_submit_times) then
			local birth_year, birth_month, birth_day = commonlib.timehelp.get_next_date(begin_year, begin_month, begin_day, -7*rank_data.newuser_submit_times)
			if(birth_year) then
				rank_data.min_birthday = string.format("%04d%02d%02d", birth_year, birth_month, birth_day);
			end
		end

		rank_data.rank_date = string.format("%04d%02d%02d", begin_year, begin_month, begin_day);
		rank_data.last_rank_date = string.format("%04d%02d%02d", last_year, last_month, last_day);
		rank_data.fullname = string.format("%s%03d", rank_data.rank_date, tonumber(rank_data.rank_id));
		rank_data.last_fullname = string.format("%s%03d", rank_data.last_rank_date, tonumber(rank_data.rank_id));
		rank_data.minscore = 0;
	elseif(rank_data.daily == "true") then
		local begin_year, begin_month, begin_day = commonlib.timehelp.get_next_date(year, month, day, 1);
		local last_year, last_month, last_day = year,month, day;

		if(rank_data.newuser_submit_times) then
			local birth_year, birth_month, birth_day = commonlib.timehelp.get_next_date(begin_year, begin_month, begin_day, -1*rank_data.newuser_submit_times)
			if(birth_year) then
				rank_data.min_birthday = string.format("%04d%02d%02d", birth_year, birth_month, birth_day);
			end
		end

		rank_data.rank_date = string.format("%04d%02d%02d", begin_year, begin_month, begin_day);
		rank_data.last_rank_date = string.format("%04d%02d%02d", last_year, last_month, last_day);
		rank_data.fullname = string.format("%s%03d", rank_data.rank_date, tonumber(rank_data.rank_id));
		rank_data.last_fullname = string.format("%s%03d", rank_data.last_rank_date, tonumber(rank_data.rank_id));
		rank_data.minscore = 0;
	end
	if(rank_data.rank_date) then
		-- if the rank item's server data is different from this one, it will be deleted. 
		rank_data.rankitem_serverdata = commonlib.Json.Encode({rdate=rank_data.rank_date});
	end
end

-- recomputer the rank_data.rank_date and rank_data.last_rank_date
-- @param date_str: such as "1982-11-26"
function RankingServer.RecomputeRankDate(date_str)
	local year, month, day = date_str:match("^(%d%d%d%d)%D*(%d%d)%D*(%d%d)$");
	year = tonumber(year);
	month = tonumber(month);
	day = tonumber(day);
	local _, rank
	for _, rank in pairs(ranking_map) do
		local index, rank_data;
		for index, rank_data in ipairs(rank) do
			RankingServer.RecomputeRankItem(rank_data, year, month, day);
		end
	end
end

-- check the log time. 
-- @return date_str, time_str, nCurTime
function RankingServer.CheckLogTime()
	local date_str, time_str, nCurTime = commonlib.log.GetLogTimeString();
	if(cur_date_str ~= date_str) then
		cur_date_str = date_str;

		year, month, day = date_str:match("^(%d%d%d%d)%D*(%d%d)%D*(%d%d)$");
		year = tonumber(year);
		month = tonumber(month);
		day = tonumber(day);

		RankingServer.days_to2050 = commonlib.timehelp.days_to2050(year, month, day)
		

		-- date has just changed, we will need to change all rank_date is necessary. 
		LOG.std(nil, "system", "RankingServer", "ranking server updated time %s %s", cur_date_str, time_str);

		RankingServer.RecomputeRankDate(date_str);
	end
	return date_str, time_str, nCurTime;
end

local not_on_rank_list_template = {issuccess = false};
-- server side only function submit ranking 
-- @param rank_name: such as "pk1v1"
-- @param nid: number or string
-- @param guid: the score item's guid. if nil, the ranking's gsid will be used. 
-- @param callbackFunc: the callback function. 
-- @param score: score if it is old rank. 
-- @param score_new: score if it is the first time we submit to the rank. 
-- @param region: if nil, it is calculated from from_nid
function RankingServer.SubmitScore(rank_name, from_nid, guid, score, callbackFunc, score_new, school, region)
	if(not region) then
		region = ExternalUserModule:GetRegionIDFromNid(from_nid);
	end

	local date_str, time_str, nCurTime = RankingServer.CheckLogTime();
	
	local rank = RankingServer.GetRankByName(rank_name, school, region)
	-- echo({rank.gsid, score = score, rank_name, is_done=tostring(rank and (not score or rank.minscore < score))})
	if(rank and (not score or rank.minscore < score)) then
		if(date_str) then
			if(rank.begin_time) then
				local begin_date = date_str:gsub("%D+", "");
				if(begin_date == rank.last_rank_date) then
					-- this the first day
					local seconds_now = commonlib.timehelp.GetSecondsFromStr(time_str)
					if(not rank.begin_time_seconds) then
						rank.begin_time_seconds = commonlib.timehelp.GetSecondsFromStr(rank.begin_time) or 0;
					end
					-- echo({"1111111111111", seconds_now, time_str, rank.begin_time_seconds})
					if(seconds_now <= rank.begin_time_seconds) then
						-- this rank has not begun. 
						if(callbackFunc) then
							callbackFunc({issuccess = false, begin_time = rank.begin_time});
						end
						return;
					end
				end
			end
		end

		local tag = nil;
		if(rank.gsid) then
			-- TODO: verify school
			if(rank.gsid ~= guid) then
				-- only rank.gsid ranks can initiate from client. 
				return;
			end
			guid, score, score_new = nil, nil, nil;
		end
		if(RankingServer.IsSpecialRankingName(rank_name)) then
			RankingServer.GetServerCombatScore(from_nid, rank_name, rank.school, function(score)
				if(score and score>0) then
					RankingServer.SubmitScore_internal(rank, from_nid, guid, score, callbackFunc, score_new, school, region)
				end
			end)
		else
			RankingServer.SubmitScore_internal(rank, from_nid, guid, score, callbackFunc, score_new, school, region)
		end
	else
		-- Do nothing, since the user's score is smaller than the last smallest one. 
		if(callbackFunc) then
			callbackFunc(not_on_rank_list_template);
		end
		return true;
	end
end

-- internal function
function RankingServer.SubmitScore_internal(rank, from_nid, guid, score, callbackFunc, score_new, school, region)
	local is_testing_from_client = false;
	if(is_testing_from_client) then
		paraworld.WorldServers.AddRank({
				nid = from_nid, 
				rid = tonumber(rank.fullname),
				begindt = tonumber(rank.last_rank_date),
				gsid = rank.gsid,
				guid = guid, 
				score = score,
				score2 = score_new,
				tag = rank.tag, -- remove this, maybe the name of the player
				min_birthday = rank.min_birthday,
			}, "AddRank", function (msg)
			if(msg and msg.issuccess and msg.minscore) then
				rank.minscore = msg.minscore;
			end
			if(callbackFunc) then
				callbackFunc(msg);
			end
		end);
	else
		local date_str, time_str, nCurTime = commonlib.log.GetLogTimeString();
		local hh,mm = time_str:match("^(%d+)%D*(%d%d)");
		hh = tonumber(hh);
		mm = tonumber(mm);
		-- tricky: since the database order m in descending order, we will use the time to year 2050 as m value. 
		local date_time = (RankingServer.days_to2050 or 0)*10000 + (24*60-hh*60-mm);

		local params = {
			rank_id = rank.fullname, 
			begin_date = rank.last_rank_date, 
			onlymax = rank.onlymax,
			gsid = rank.gsid, 
			guid = guid, 
			score = score, 
			score_new = score_new, 
			tag = if_else(rank.tag == "", nil, rank.tag),
			min_birthday = rank.min_birthday,
			m = date_time, -- use the m value as date_time to 2050
			energy = nil,
			popularity = nil,
		}
		PowerItemManager.AddUserRanking(from_nid, params, function(msg)
			if(msg and msg.issuccess) then
				if(msg.minscore) then
					rank.minscore = msg.minscore;
				end
				if(errorcode == 493) then
						
				end
			end
			if(callbackFunc) then
				callbackFunc(msg);
			end
		end)
	end
end

function RankingServer.GetSingleComputedRank(rank_name, date, school, region)
	local rank = RankingServer.GetRankByName(rank_name, school, region)
	if(rank) then
		rank = commonlib.clone(rank);
		RankingServer.RecomputeRankItem(rank, date);
		return rank;
	end
end

-- only client side: the following is for testing only. 
-- @param rank_name: such as "pk1v1"
-- @param date: string like "2012-11-26". if nil, it will be current date(Client side uses last login date time)
-- @param callbackFunc: function(msg, rank) end where msg is like array {{nid=295285926,score=1100,m=0,popularity=0,energy=0,tag="",},}, rank is a copy of the rank item representing the date
-- @param pindex: page index, default to 0, can be 1. 
function RankingServer.GetRanking(rank_name, date, school, region, callbackFunc, cache_policy, pindex)
	local rank = RankingServer.GetSingleComputedRank(rank_name, date, school, region)
	if(rank) then
		paraworld.WorldServers.GetRankList({
				rid = tonumber(rank.fullname),
				cache_policy = cache_policy,
				pindex = pindex, 
			}, "GetRanking", function (msg)
			if(callbackFunc) then
				callbackFunc(msg, rank);
			end
		end);
	end
end

-- only client side: 
-- @param rank_name: such as "pk1v1"
function RankingServer.GetMyRankIndex(rank_name)
	local school = MyCompany.Aries.Player.GetSchool();
	local date;
	local region = MyCompany.Aries.ExternalUserModule:GetRegionID();
	local rank = RankingServer.GetSingleComputedRank(rank_name, date, school, region)
	if(rank) then
		paraworld.WorldServers.GetRankIndex({
				rid = tonumber(rank.fullname),
			}, "GetRanking", function (msg)
			if(callbackFunc) then
				callbackFunc(msg);
			end
		end);
	end
end

-- only client side: 
-- @param rank_name: such as "pk1v1"
-- @param date: if nil it will be last rank
function RankingServer.GetMyRankReward(rank_name, date, school, region, callbackFunc)
	school = school or MyCompany.Aries.Player.GetSchool();
	region = region or MyCompany.Aries.ExternalUserModule:GetRegionID();

	local rank = RankingServer.GetSingleComputedRank(rank_name, date, school, region)
	if(rank) then
		paraworld.Items.ExchangeRank({
				rid = if_else(data==nil, tonumber(rank.last_fullname), tonumber(rank.fullname)),
			}, "GetRankingReward", function (msg)
			if(callbackFunc) then
				callbackFunc(msg);
			end
		end);
	end
end

-- get client side score for a given combat value name
-- @param name: 
function RankingServer.GetClientCombatScore(name, school)
	local Combat = commonlib.gettable("MyCompany.Aries.Combat");
	local nid = System.User.nid;
	school = school or MyCompany.Aries.Player.GetSchool();
	if(name == "accuracy" or name =="damage_absolute_base" or name == "resist_absolute_base" or name =="damage" or name == "resist" ) then
		return math.abs(Combat.GetStats(school, name) or 0);
	elseif(name=="PowerPipChance") then
		return math.ceil(Combat.GetPowerPipChance(nil,nil) or 0);
	elseif(name=="OutputHealBoost") then
		return Combat.GetOutputHealBoost();
	elseif(name=="InputHealBoost") then
		return Combat.GetInputHealBoost();
	elseif(name=="CriticalStrikeChance") then
		return Combat.GetCriticalStrikeChance(nid);
	elseif(name=="ResilienceChance") then
		return Combat.GetResilienceChance(nid);
	elseif(name=="DodgeChance") then
		return Combat.GetDodgeChance(nid);
	elseif(name=="SpellPenetrationChance") then
		return Combat.GetSpellPenetrationChance(nid);
	elseif(name=="HitChance") then
		return Combat.GetHitChance(nid);
	elseif(name=="HP") then
		local MsgHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");
		return MsgHandler.GetMaxHP();
	end
end

local special_ranking_name = {
	["accuracy"]=true,
	["damage"]=true,
	["resist"]=true,
	["damage_absolute_base"]=true,
	["resist_absolute_base"]=true,
	["PowerPipChance"]=true,
	["OutputHealBoost"]=true,
	["InputHealBoost"]=true,
	["CriticalStrikeChance"]=true,
	["ResilienceChance"]=true,
	["DodgeChance"]=true,
	["SpellPenetrationChance"]=true,
	["HitChance"]=true,
	["HP"]=true,
}
function RankingServer.IsSpecialRankingName(name)
	return special_ranking_name[name or ""];
end


-- @param callbackFunc: function(score) end
function RankingServer.GetServerCombatScore(nid, name, school, callbackFunc)
	MyCompany.Aries.Combat_Server.Arena.OnReponse_CheckStats(nid, function(player)
		if(player) then
			school = school or player:GetPhase();
			local score;
			if(name == "accuracy") then
				score = player:GetAccuracyBoost(school);
			elseif(name=="damage") then
				score = player:GetDamageBoost(school);
			elseif(name=="resist") then
				score = math.abs(player:GetResist(school) or 0);
			elseif(name=="damage_absolute_base") then
				score = player:GetDamageBoost_absolute(school);
			elseif(name=="resist_absolute_base") then
				score = math.abs(player:GetResist_absolute(school) or 0);
			elseif(name=="PowerPipChance") then
				score = math.ceil(player:GetPowerPipChance() or 0);
			elseif(name=="OutputHealBoost") then
				score = player:GetOutputHealBoost();
			elseif(name=="InputHealBoost") then
				score = player:GetInputHealBoost();
			elseif(name=="CriticalStrikeChance") then
				score = player:GetCriticalStrike(school);
			elseif(name=="ResilienceChance") then
				score = player:GetResilience(school);
			elseif(name=="DodgeChance") then
				score = player:GetDodge(school);
			elseif(name=="SpellPenetrationChance") then
				score = player:GetSpellPenetration(school);
			elseif(name=="HitChance") then
				score = player:GetHitChance(school);
			elseif(name=="HP") then
				score = player:GetUpdatedMaxHP();
			end
			if(callbackFunc) then
				callbackFunc(score);
			end
		end
	end);
end