--[[
Title: PVP session
Author(s): Leio, LiXizhi
Date: 2013/7/10
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/CombatRoom/PvPSessionPage.lua");
local PvPSessionPage = commonlib.gettable("MyCompany.Aries.CombatRoom.PvPSessionPage");
PvPSessionPage.ShowPage("1v1")
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
NPL.load("(gl)script/apps/Aries/Team/TeamClientLogics.lua");
NPL.load("(gl)script/apps/Aries/Friends/Main.lua");
local TeamClientLogics = commonlib.gettable("MyCompany.Aries.Team.TeamClientLogics");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
local PvPSessionPage = commonlib.gettable("MyCompany.Aries.CombatRoom.PvPSessionPage");
local Player = commonlib.gettable("MyCompany.Aries.Player");
local ItemManager = System.Item.ItemManager;

local sessions_type = "1v1";
local page;
function PvPSessionPage.OnInit()
	page = document:GetPageCtrl();
	PvPSessionPage.page = page;

	PvPSessionPage.gs_score = Player.GetGearScore();
	PvPSessionPage.BuildSessions();
	PvPSessionPage.BuildMenus();
	if(CommonClientService.IsTeenVersion()) then
		PvPSessionPage.sessions_list = PvPSessionPage.CreateDisplaySession(PvPSessionPage.GetSessions());
	else
		PvPSessionPage.sessions_list = PvPSessionPage.CreateDisplaySessionForKids1V1(PvPSessionPage.GetSessions());
	end
	
end
function PvPSessionPage.ShowPage(sessions_type_)
	sessions_type = sessions_type_ or sessions_type;
	local url;
	if(CommonClientService.IsTeenVersion()) then
		url = "script/apps/Aries/CombatRoom/PvPSessionPage.teen.html";
		---- disable UI for teen. 
		--NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
		--local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
		--LobbyClientServicePage.DoAutoJoinRoom("HaqiTown_RedMushroomArena_"..sessions_type, "PvP");
	else
		url = "script/apps/Aries/CombatRoom/PvPSessionPage.html";
		
	end
	local params = {
			url = url, 
			name = "PvPSessionPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			enable_esc_key = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			directPosition = true,
				align = "_ct",
				x = -830/2,
				y = -480/2,
				width = 830,
				height = 480,
		}
	System.App.Commands.Call("File.MCMLWindowFrame", params);
end
function PvPSessionPage.BuildMenus()
	if(CommonClientService.IsTeenVersion()) then
		if(not PvPSessionPage.menus)then
			PvPSessionPage.menus = {
				{label = "1v1", title="1v1排位赛", keyname = "1v1", selected = true, },
				-- 2014.11.4暂时关闭
				--{label = "2v2", title="2v2排位赛", keyname = "2v2", },
			}
		end
	else
		if(not PvPSessionPage.menus)then
			PvPSessionPage.menus = {
				{label = "", title="1v1排位赛", keyname = "1v1", selected = true, SelectedMenuItemBG = "texture/aries/pvpsession/on_1v1_32bits.png;0 0 64 25", UnSelectedMenuItemBG = "texture/aries/pvpsession/off_1v1_32bits.png;0 0 64 25", },
				-- 2v2 2014.05 暂时关闭
				--{label = "", title="2v2排位赛", keyname = "2v2", SelectedMenuItemBG = "texture/aries/pvpsession/on_2v2_32bits.png;0 0 64 25", UnSelectedMenuItemBG = "texture/aries/pvpsession/off_2v2_32bits.png;0 0 64 25", },
			}
		end
	end
	local k,v;
	for k,v in ipairs(PvPSessionPage.menus) do
		if(v.keyname == sessions_type)then
			v.selected = true;
		else
			v.selected = false;
		end
	end
end

function PvPSessionPage.SetMembers(members)
	PvPSessionPage.members = members;
	if(PvPSessionPage.page)then
		PvPSessionPage.page:Refresh(0);
	end
end

function PvPSessionPage.DoSelectedMenu(keyname)
	sessions_type = keyname;
	PvPSessionPage.BuildMenus();
	-- sessions list
	if(PvPSessionPage.page)then
		PvPSessionPage.page:Refresh(0.01);
	end
end

function PvPSessionPage.GetSelectedMenuNode()
	if(PvPSessionPage.menus)then
		local k,v;
		for k,v in ipairs(PvPSessionPage.menus) do
			if(v.selected)then
				return v;
			end
		end
	end
end
function PvPSessionPage.GetSessions()
	local node = PvPSessionPage.GetSelectedMenuNode();
	if(node and node.keyname)then
		return PvPSessionPage[node.keyname];
	end
end

-- build all medal gsid state. 
function PvPSessionPage.BuildSessions()
	if(CommonClientService.IsTeenVersion()) then
		if(not PvPSessionPage["1v1"])then
			PvPSessionPage["1v1"] = {
				{label = "青铜守护者", gsid = 20058, min_score=1500, exid="rank_medal_10_1v1"},
				{label = "青铜守护者", gsid = 20059, min_score=1750, exid="rank_medal_11_1v1"},
				{label = "白银守护者", gsid = 20060, min_score=2000, exid="rank_medal_20_1v1"},
				{label = "白银守护者", gsid = 20061, min_score=2250, exid="rank_medal_21_1v1"},
				{label = "黄金守护者", gsid = 20062, min_score=2500, exid="rank_medal_30_1v1"},
				{label = "黄金守护者", gsid = 20063, min_score=2750, exid="rank_medal_31_1v1"},
				{label = "银龙守护者", gsid = 20064, min_score=3000, exid="rank_medal_40_1v1"},
				{label = "银龙守护者", gsid = 20065, min_score=3150, exid="rank_medal_41_1v1"},
				{label = "青铜守护者", gsid = 20066, min_score=3300, exid="rank_medal_50_1v1"},
				{label = "青铜守护者", gsid = 20067, min_score=3400, exid="rank_medal_51_1v1"},

				{label = "最强", gsid = 20068, min_score=3500, exid="rank_medal_60_1v1"},
			}
		end
		if(not PvPSessionPage["2v2"])then
			PvPSessionPage["2v2"] = {
				{label = "青铜守护者", gsid = 20069, min_score=1000, exid="rank_medal_10_2v2"},
				{label = "青铜守护者", gsid = 20070, min_score=1100, exid="rank_medal_11_2v2"},
				{label = "白银守护者", gsid = 20071, min_score=1200, exid="rank_medal_20_2v2"},
				{label = "白银守护者", gsid = 20072, min_score=1300, exid="rank_medal_21_2v2"},
				{label = "黄金守护者", gsid = 20073, min_score=1400, exid="rank_medal_30_2v2"},
				{label = "黄金守护者", gsid = 20074, min_score=1500, exid="rank_medal_31_2v2"},
				{label = "银龙守护者", gsid = 20075, min_score=1600, exid="rank_medal_40_2v2"},
				{label = "银龙守护者", gsid = 20076, min_score=1700, exid="rank_medal_41_2v2"},
				{label = "青铜守护者", gsid = 20077, min_score=1800, exid="rank_medal_50_2v2"},
				{label = "青铜守护者", gsid = 20078, min_score=1900, exid="rank_medal_51_2v2"},
				{label = "最强", gsid = 20079, min_score=2000, exid="rank_medal_60_2v2"},
			}
		end
	else
		if(not PvPSessionPage["1v1"])then
			--PvPSessionPage["1v1"] = {
				--{label = "青铜守护者", gsid = 20057, min_score=1000, exid="rank_medal_10_1v1"},
				--{label = "青铜守护者", gsid = 20058, min_score=1100, exid="rank_medal_11_1v1"},
				--{label = "白银守护者", gsid = 20059, min_score=1200, exid="rank_medal_20_1v1"},
				--{label = "白银守护者", gsid = 20060, min_score=1300, exid="rank_medal_21_1v1"},
				--{label = "黄金守护者", gsid = 20061, min_score=1400, exid="rank_medal_30_1v1"},
				--{label = "黄金守护者", gsid = 20062, min_score=1500, exid="rank_medal_31_1v1"},
				--{label = "银龙守护者", gsid = 20063, min_score=1600, exid="rank_medal_40_1v1"},
				--{label = "银龙守护者", gsid = 20064, min_score=1700, exid="rank_medal_41_1v1"},
				--{label = "青铜守护者", gsid = 20065, min_score=1800, exid="rank_medal_50_1v1"},
				--{label = "青铜守护者", gsid = 20066, min_score=1900, exid="rank_medal_51_1v1"},
--
				--{label = "最强", gsid = 20067, min_score=2000, exid="rank_medal_60_1v1"},
			--}
			PvPSessionPage["1v1"] = {
				{label = "青铜守护者", gsid = 20108, min_gs=0,	  max_gs=399,  exid="rank_medal_399_1v1"},
				{label = "青铜守护者", gsid = 20109, min_gs=400,  max_gs=599,  exid="rank_medal_599_1v1"},
				{label = "白银守护者", gsid = 20110, min_gs=600,  max_gs=699,  exid="rank_medal_699_1v1", beSendMail = true},
				{label = "白银守护者", gsid = 20111, min_gs=700,  max_gs=799,  exid="rank_medal_799_1v1"},
				{label = "银龙守护者", gsid = 20112, min_gs=800,  max_gs=899,  exid="rank_medal_899_1v1", beSendMail = true},
				{label = "银龙守护者", gsid = 20113, min_gs=900,  max_gs=999,  exid="rank_medal_999_1v1"},
				{label = "金龙守护者", gsid = 20114, min_gs=1000, max_gs=1099, exid="rank_medal_1099_1v1", beSendMail = true},
				{label = "金龙守护者", gsid = 20115, min_gs=1100, max_gs=1199, exid="rank_medal_1199_1v1"},

				{label = "最强", gsid = 20116, min_gs=1200, exid="rank_medal_1200_1v1", beSendMail = true},
			}
		end
		if(not PvPSessionPage["2v2"])then
			PvPSessionPage["2v2"] = {
				{label = "青铜守护者", gsid = 20068, min_score=1000, exid="rank_medal_10_2v2"},
				{label = "青铜守护者", gsid = 20069, min_score=1100, exid="rank_medal_11_2v2"},
				{label = "白银守护者", gsid = 20070, min_score=1200, exid="rank_medal_20_2v2"},
				{label = "白银守护者", gsid = 20071, min_score=1300, exid="rank_medal_21_2v2"},
				{label = "黄金守护者", gsid = 20072, min_score=1400, exid="rank_medal_30_2v2"},
				{label = "黄金守护者", gsid = 20073, min_score=1500, exid="rank_medal_31_2v2"},
				{label = "银龙守护者", gsid = 20074, min_score=1600, exid="rank_medal_40_2v2"},
				{label = "银龙守护者", gsid = 20075, min_score=1700, exid="rank_medal_41_2v2"},
				{label = "青铜守护者", gsid = 20076, min_score=1800, exid="rank_medal_50_2v2"},
				{label = "青铜守护者", gsid = 20077, min_score=1900, exid="rank_medal_51_2v2"},
				{label = "最强", gsid = 20078, min_score=2000, exid="rank_medal_60_2v2"},
			}
		end
	end
	
	if(CommonClientService.IsTeenVersion()) then
		PvPSessionPage.CheckSessionByScore(PvPSessionPage["1v1"], PvPSessionPage.gs_score, Player.GetRankingScore("1v1"));
	else
		PvPSessionPage.CheckSessionByScoreForKids1V1(PvPSessionPage["1v1"], PvPSessionPage.gs_score);
	end
	PvPSessionPage.CheckSessionByScore(PvPSessionPage["2v2"], PvPSessionPage.gs_score, Player.GetRankingScore("2v2"));
end

-- only five items are displayed. 
function PvPSessionPage.CreateDisplaySession(session)
	--local cur_stage = PvPSessionPage.GetRankStage()
	local score = PvPSessionPage.GetRankScore();

	local beFindCurrentStage = false;
	
	local display_items = {};
	local i, stage;
	for i, stage in ipairs(session) do
		
		if(i%2 == 1) then
			if(stage.has_item) then
				local next_stage = session[i+1];
				if(not next_stage or not next_stage.has_item) then
					display_items[#display_items+1] = stage;
				end
			else
				display_items[#display_items+1] = stage;
			end
		else
			if(stage.has_item) then
				display_items[#display_items+1] = stage;
			end
		end
		if(stage.has_item) then
			stage.status = "has";
		else
			stage.status = "no";
		end
		--if(stage == cur_stage) then
			--stage.status = "current";
		--elseif(session[i-1] and session[i-1].status=="current") then
			--stage.status = "next";
		--end
		if(score < stage.min_score) then
			if(session[i - 1] and score >= session[i - 1].min_score) then
				session[i - 1].status = "current";	
				beFindCurrentStage = true;
				stage.status = "next";
			end
		end
	end
	if(not beFindCurrentStage) then
		if(score < display_items[1].min_score) then
			display_items[1].status = "current";
			display_items[2].status = "next";
		end
		if(score > display_items[#display_items].min_score) then
			display_items[#display_items].status = "current";
		end
		
	end
	return display_items;
end

-- only five items are displayed. 
function PvPSessionPage.CreateDisplaySessionForKids1V1(session)
	--local cur_stage = PvPSessionPage.GetRankStage()
	local cur_gs = PvPSessionPage.gs_score;

	local display_items = {};
	local i, stage;
	for i, stage in ipairs(session) do
		
		if(i%2 == 1) then
			if(stage.has_item) then
				local next_stage = session[i+1];
				if(not next_stage or not next_stage.has_item) then
					display_items[#display_items+1] = stage;
				end
			else
				display_items[#display_items+1] = stage;
			end
		else
			if(stage.has_item) then
				display_items[#display_items+1] = stage;
			end
		end
		if(stage.has_item) then
			stage.status = "has";
		else
			stage.status = "no";
		end

		local meetConditions = true;
		if(stage.min_gs and cur_gs < stage.min_gs) then
			meetConditions = false;
		end

		if(stage.max_gs and cur_gs > stage.max_gs) then
			meetConditions = false;
		end

		if(meetConditions) then
			stage.status = "current";
			if(session[i+1]) then
				session[i+1].status = "next";
			end
		--elseif(session[i-1] and session[i-1].status=="current") then
			--stage.status = "next";
		end
	end
	return display_items;
end

function PvPSessionPage.CheckSessionByScore(session, gs_score, rank_score)
	local i, stage;
	for i, stage in ipairs(session) do
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(stage.gsid);
		if(gsItem) then
			stage.label = gsItem.template.name:gsub("徽章$","");
			local bHas = ItemManager.IfOwnGSItem(stage.gsid)
			stage.has_item = (bHas == true);
			stage.min_gs_score = stage.min_score-1000;
			if(System.options.version == "teen") then
				stage.tip_label = stage.label;
			else
				if(i == #session) then
					stage.tip_label = format("%s (%d以上战力)", stage.label, stage.min_gs_score);
				else
					stage.tip_label = format("%s (%d - %d 战力)", stage.label, stage.min_gs_score, stage.min_gs_score + 99);
				end
			end
			

			if(rank_score > stage.min_score and not stage.has_item) then
				stage.has_item = true;
				-- automatically purchase it if not exist
				System.GSL_client:SendRealtimeMessage("sPowerAPI", {name="PowerExtendedCost", params={exid=stage.exid}});
			end
		end
	end
end

function PvPSessionPage.CheckSessionByScoreForKids1V1(session, gs_score)
	local i, stage;
	for i, stage in ipairs(session) do
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(stage.gsid);
		if(gsItem) then
			stage.label = gsItem.template.name:gsub("徽章$","");
			local bHas = ItemManager.IfOwnGSItem(stage.gsid)
			stage.has_item = (bHas == true);
			if(i == #session) then
				stage.tip_label = format("%s(%d以上战力)", stage.label, stage.min_gs);
			else
				stage.tip_label = format("%s(%d-%d 战力)", stage.label, stage.min_gs, stage.max_gs);
			end
			
			if(not stage.has_item and stage.beSendMail) then
				local meetConditions = true;
				if(stage.min_gs and gs_score < stage.min_gs) then
					meetConditions = false;
				end
				if(stage.max_gs and gs_score > stage.max_gs) then
					meetConditions = false;
				end
				if(meetConditions) then
					NPL.load("(gl)script/apps/Aries/Mail/MailManager.lua");
					local original_mail = MyCompany.Aries.Quest.Mail.MailManager.GetMail(10044)
					local mail = {};
					commonlib.partialcopy(mail,original_mail);
					mail.content = string.format(mail.content,stage.min_gs,stage.label);
					MyCompany.Aries.Quest.Mail.MailManager.PushMail(mail);
				end
			end
			if(gs_score >= stage.min_gs and not stage.has_item) then
				stage.has_item = true;
				-- automatically purchase it if not exist
				System.GSL_client:SendRealtimeMessage("sPowerAPI", {name="PowerExtendedCost", params={exid=stage.exid}});
			end
		end
	end
end


function PvPSessionPage.Ds_Func(index)
	if(not PvPSessionPage.sessions_list)then return 0 end
	if(index == nil) then
		return #(PvPSessionPage.sessions_list);
	else
		return PvPSessionPage.sessions_list[index];
	end
end

PvPSessionPage.members_1v1 = {
    {},
};
PvPSessionPage.members_2v2 = {
    {},
	{},
};
-- TODO: 
function PvPSessionPage.Ds_Func_Members(index)
	if(sessions_type == "1v1") then
		PvPSessionPage.members = PvPSessionPage.members_1v1;
	else
		PvPSessionPage.members = PvPSessionPage.members_2v2;
	end
	if(not PvPSessionPage.members)then return 0 end
	if(index == nil) then
		return #(PvPSessionPage.members);
	else
		return PvPSessionPage.members[index];
	end
end

-- combat score
function PvPSessionPage.GetGearScore()
	return PvPSessionPage.gs_score;
end

function PvPSessionPage.GetRankScore()
	return Player.GetRankingScore(sessions_type);
end

function PvPSessionPage.GetVirtualRankingScore()
	return Player.GetVirtualRankingScore(sessions_type)
end

function PvPSessionPage.GetStageByScore(score)
	local session = PvPSessionPage.GetSessions();
	local i, stage;
	for i, stage in ipairs(session) do
		if(score >= stage.min_score and score < (stage.min_score+100)) then
			return stage;
		end
	end
	return session[#session];
end

function PvPSessionPage.GetCurrentStage()
	return PvPSessionPage.GetStageByScore(PvPSessionPage.GetVirtualRankingScore());
end

function PvPSessionPage.GetRankStage()
	return PvPSessionPage.GetStageByScore(PvPSessionPage.GetRankScore());
end

function PvPSessionPage.GetMostFitStage()
	return PvPSessionPage.GetStageByScore(PvPSessionPage.GetGearScore()+1000);
end

function PvPSessionPage.GetMostFitStageForKids1V1()
	local cur_gs = PvPSessionPage.gs_score; 
	local session = PvPSessionPage.GetSessions();
	local i, stage;
	for i, stage in ipairs(session) do
		if(cur_gs >= stage.min_gs and i == #session) then
			return stage;
		elseif(cur_gs >= stage.min_gs and cur_gs <= stage.max_gs) then
			return stage;
		end
	end
end

function PvPSessionPage.HasFamilyAvoid()
	return if_else(PvPSessionPage.GetVirtualRankingScore() > 5000,"关","开");
end

function PvPSessionPage.GetStatusTips()
	if(System.options.version == "teen") then
		local text = "提示:1500分以下，失败不扣分";
		local name = "";
		return text, name;
	end
	local fit_stage = PvPSessionPage.GetMostFitStage();
	local cur_stage = PvPSessionPage.GetCurrentStage();
	local text = "【提示】 "
	if(fit_stage.min_score < cur_stage.min_score) then
		text = text..[[你的战斗力不匹配当前段位，现已越级挑战，请快提高属性吧！<br/>]]
	end

	local strict_pvp_score = if_else(System.options.version == "teen", 1800, 1800);

	local virtual_score = PvPSessionPage.GetVirtualRankingScore()
	local rank_score = PvPSessionPage.GetRankScore()
	local name = "";
	if(rank_score < cur_stage.min_score and rank_score <= strict_pvp_score) then
		name = "积分赛(胜40,负0)"
		text = text..[[积分赛：胜利40积分， 失败不扣分]]
	elseif(virtual_score <= strict_pvp_score) then
		if(virtual_score%100 < 90) then
			name = "排位赛(胜+10,负-5)"
			text = text..[[排位赛：胜利10积分， 失败扣5分]]
		else
			name = "晋级赛(胜+5,负-10)"
			text = text..[[晋级赛：胜利5积分， 失败扣10分，连赢2场就能晋级了！]]
		end
	else
		name = "王者争夺赛"
		text = text..[[您的积分已经很高, 排队时间可能较长, 胜负积分由系统决定]]
	end
	return text, name;
end

function PvPSessionPage.GetStatusTipsForKids1v1()
	local text = "【提示】 "

	local strict_pvp_score = if_else(System.options.version == "teen", 1800, 1800);

	local virtual_score = PvPSessionPage.GetVirtualRankingScore()
	local rank_score = PvPSessionPage.GetRankScore()
	local gearscore = Player.GetGearScore();
	local min_score = 1000 + gearscore;

	local name = "";

	if(rank_score <= strict_pvp_score) then
		name = "积分赛(胜40,负0)"
		text = text..[[积分赛：胜利40积分， 失败不扣分]]
	--elseif(virtual_score <= strict_pvp_score) then
		--if(virtual_score%100 < 90) then
			--name = "排位赛(胜+10,负-5)"
			--text = text..[[排位赛：胜利10积分， 失败扣5分]]
		--else
			--name = "晋级赛(胜+5,负-10)"
			--text = text..[[晋级赛：胜利5积分， 失败扣10分，连赢2场就能晋级了！]]
		--end
	else
		name = "王者争夺赛"
		text = text..[[您的积分已经很高, 排队时间可能较长, 胜负积分由系统决定]]
	end
	return text, name;
end

function PvPSessionPage.GetStatus()
	local _,name;
	if(sessions_type == "1v1") then
		_,name = PvPSessionPage.GetStatusTipsForKids1v1();
	else
		_,name = PvPSessionPage.GetStatusTips();
	end
	return name or "";
end

function PvPSessionPage.OnClickJoin()
	if(PvPSessionPage.gs_score >= 1000 and System.options.version == "kids") then
		_guihelper.MessageBox("你的战斗力已经超过1000，不能参加低战斗力的1v1比赛，请前往拉斐尔城堡参与3v3比赛。");
		return;
	end
	if(page) then
		page:CloseWindow();
	end
	local worldname_suffix;
	if(System.options.version == "kids" and sessions_type == "1v1") then
		local gearScore = Player.GetGearScore();
		if(gearScore < 600) then
			worldname_suffix = "1v1_599";
		elseif(gearScore < 800) then
			worldname_suffix = "1v1_799";
		elseif(gearScore < 1000) then
			worldname_suffix = "1v1_999";
		elseif(gearScore < 1200) then
			worldname_suffix = "1v1_1199";
		else
			worldname_suffix = "1v1_1200";
		end	
	else
		worldname_suffix = sessions_type;
	end
	
	NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
	local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
	--LobbyClientServicePage.DoAutoJoinRoom("HaqiTown_RedMushroomArena_"..sessions_type, "PvP");
	LobbyClientServicePage.DoAutoJoinRoom("HaqiTown_RedMushroomArena_"..worldname_suffix, "PvP");
end

function PvPSessionPage.Be1v1()
	if(sessions_type == "1v1") then
		return true;
	else
		return false;
	end
end

function PvPSessionPage.OnClickJoin2v2ForKids()
	local family_id = MyCompany.Aries.Friends.GetMyFamilyID();
	if(not family_id) then
		_guihelper.MessageBox("你还没有加入家族，无法参加2v2比赛！");
		return;
	end
	if(not TeamClientLogics:IsInTeam()) then
		_guihelper.MessageBox("2v2必须同家族玩家组队才能参加比赛！");
		return;
	end
	local gearScore = Player.GetGearScore();
	if(gearScore < 1000) then
		_guihelper.MessageBox("你的战斗力小于1000，不能参加2v2比赛。");
		return;
	end
	if(page) then
		page:CloseWindow();
	end
	local worldname_suffix;
	--local gearScore = Player.GetGearScore();
	-- worldname_suffix only world tag, differentiate the worlds from players gearscore.
	if(gearScore < 1800) then
		worldname_suffix = "2v2_1999";
	else
		worldname_suffix = "2v2_5000";
	end	
	
	NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
	local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
	--LobbyClientServicePage.DoAutoJoinRoom("HaqiTown_RedMushroomArena_"..sessions_type, "PvP");
	LobbyClientServicePage.DoAutoJoinRoom("HaqiTown_RedMushroomArena_"..worldname_suffix, "PvP");
end