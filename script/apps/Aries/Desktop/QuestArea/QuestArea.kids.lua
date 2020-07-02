--[[
Title: Helper buttons around the map area 
Author(s): WangTian
Date: 2009/4/7
Desc: See Also: script/apps/Aries/Desktop/AriesDesktop.lua
Such as ranking, task list, lobby, mijiuhulu, lobby count down, toggle camera mode, etc. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/QuestArea.lua");
MyCompany.Aries.Desktop.QuestArea.Init();
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Quest/QuestWeeklyPage.lua");
NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/ItemsConsignment.kids.lua");
NPL.load("(gl)script/apps/Aries/GoldRankingList/GoldRankingListMain.lua");
NPL.load("(gl)script/apps/Aries/Desktop/ActivityNote.lua");
NPL.load("(gl)script/apps/Aries/Desktop/MiJiuHuLu.lua");
NPL.load("(gl)script/apps/Aries/BigEvents/BigEvents.lua");
NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
NPL.load("(gl)script/apps/Aries/CombatRoom/WorldTeamQuest.lua");
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
NPL.load("(gl)script/apps/Aries/Quest/MoodPerDay.lua");
NPL.load("(gl)script/apps/Aries/Desktop/Calendar.kids.lua");

NPL.load("(gl)script/apps/Aries/Desktop/EXPBuffArea.lua");
local EXPBuffArea = commonlib.gettable("MyCompany.Aries.Desktop.EXPBuffArea");
NPL.load("(gl)script/apps/Aries/Combat/main.lua");
local Combat = commonlib.gettable("MyCompany.Aries.Combat");
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
-- create class
local libName = "AriesDesktopQuestArea";
local QuestArea = commonlib.gettable("MyCompany.Aries.Desktop.QuestArea");
local LOG = LOG;
local page;
-- all appended quest status
QuestArea.StatusList = {};

QuestArea.showhulu = QuestArea.showhulu or true;
QuestArea.max_size = 12;

-- virtual function: create UI
function QuestArea.CreateV2()
	local self = QuestArea;
	local _parent = ParaUI.CreateUIObject("container", "AriesQuestArea", "_rt", -454, 8, 454, 100);
	_parent.background = "";
	_parent:GetAttributeObject():SetField("ClickThrough", true);
	_parent:AttachToRoot();
	_parent.zorder= -10;
	page = page or Map3DSystem.mcml.PageCtrl:new({url="script/apps/Aries/Desktop/QuestArea/QuestArea.kids.html",click_through = true,});
	if(System.options.IsMobilePlatform) then
		page.SelfPaint = true;
	end
	-- one can create a UI instance like this. 
	page:Create("Aries_QuestArea_mcml", _parent, "_fi", 0, 0, 0, 0);
	
	-- unread email count. 
	NPL.load("(gl)script/apps/Aries/Mail/MailBox.lua");
	MyCompany.Aries.Mail.MailBox:AddEventListener("unread_mail_change", function(self, event)
		if(event.unread_mail) then
			QuestArea.Refresh_MailCnt(event.unread_mail);
		end
	end, QuestArea, "QuestArea");
	
	local NotificationArea = commonlib.gettable("MyCompany.Aries.Desktop.NotificationArea");
	local bMagazineAnimPlayed;
	NotificationArea:AddEventListener("has_unread_magazine", function()
			local _magazine = page:FindControl("news");
			if(_magazine) then
				local fileName = "script/UIAnimation/CommonIcon.lua.table";
				UIAnimManager.LoadUIAnimationFile(fileName);
				UIAnimManager.PlayUIAnimationSequence(_magazine, fileName, "Bounce", true);
				bMagazineAnimPlayed = true;
			end
		end, QuestArea, "QuestArea");
	NotificationArea:AddEventListener("magazine_opened", function()
			if(bMagazineAnimPlayed) then
				bMagazineAnimPlayed = false;
				local _magazine = page:FindControl("news");
				if(_magazine) then
					local fileName = "script/UIAnimation/CommonIcon.lua.table";
					UIAnimManager.LoadUIAnimationFile(fileName);
					UIAnimManager.StopLoopingUIAnimationSequence(_magazine, fileName, "Bounce");
				end
			end
		end, QuestArea, "QuestArea");
	QuestArea.RegistGsids();
end

-- virtual function: create UI
function QuestArea.Create()
	-- the height used to be 64, but the camera toggle button is bigger, so add 20 pixels
	local _questArea = ParaUI.CreateUIObject("container", "AriesQuestArea", "_rt", -652, 4, 640, 82);
	_questArea.background = "";
	_questArea:GetAttributeObject():SetField("ClickThrough", true);
	_questArea:AttachToRoot();
	
	local i;
	for i = 1, 7 do
		local _quest = ParaUI.CreateUIObject("button", "Quest"..i, "_rt", -80*i-80-100, 0, 80, 75);
		_quest.background = "";
		_quest.animstyle = 23;
		_quest.visible = false;
		_questArea:AddChild(_quest);
	end
	
	local _questDragonCont = ParaUI.CreateUIObject("container", "QuestDragon", "_rt", -78, 0, 78, 46);
	_questDragonCont.background = "";
	_questArea:AddChild(_questDragonCont);

	local _questDragon = ParaUI.CreateUIObject("button", "btnQuestDragon", "_lt", 0, 0, 78, 46);
	_questDragon.background = "Texture/Aries/Dock/Web/dragonwish_icon_32bits.png;0 0 78 46";
	_questDragon.animstyle = 23;
	--_questDragon.onclick = ";MyCompany.Aries.Quest.MoodPerDay.ShowMainWnd();";
	_questDragon.onclick = ";MyCompany.Aries.Desktop.QuestArea.OnClickQuestDragonStatus();";
	_questDragon.tooltip = "抱抱龙心愿";
	_questDragonCont:AddChild(_questDragon);
	local _questDragonFlash = ParaUI.CreateUIObject("button", "QuestDragonFlash", "_lt", 0, 0, 78, 46);
	_questDragonFlash.background = "Texture/Aries/Dock/Web/dragonwish_icon_32bits.png;0 0 78 46";
	_questDragonFlash.enabled = false;
	_questDragonFlash.visible = false;
	_questDragonCont:AddChild(_questDragonFlash);
	local _questDragon_count = ParaUI.CreateUIObject("button", "QuestDragonCount", "_lt", 53, 30, 32, 32);
	_questDragon_count.background = "Texture/Aries/Temp/UnreadNum.png";
	_questDragon_count.font = System.DefaultLargeBoldFontString;
	_guihelper.SetFontColor(_questDragon_count, "255 255 255");
	_guihelper.SetUIColor(_questDragon_count, "255 255 255");
	_questDragon_count.enabled = false;
	_questDragon_count.visible = false;
	--_questDragon_count.onclick = ";MyCompany.Aries.Desktop.NotificationArea.OnClickFeed();";
	_questDragonCont:AddChild(_questDragon_count);
	
	local _questList = ParaUI.CreateUIObject("button", "QuestList", "_rt", -78-71-10, 5, 71, 46);
	_questList.background = "Texture/Aries/Dock/Web/questlist_icon_32bits.png;0 0 71 46";
	_questList.animstyle = 23;
	_questList.onclick = ";MyCompany.Aries.Desktop.QuestArea.ShowQuestListPage();";
	_questList.tooltip = "任务列表 (L)";
	_questArea:AddChild(_questList);
	local _questActived_count = ParaUI.CreateUIObject("button", "QuestActivedCount", "_rt", -78-71 + 46 , 30, 32, 32);
	_questActived_count.background = "Texture/Aries/Temp/UnreadNum.png";
	_questActived_count.font = System.DefaultLargeBoldFontString;
	_guihelper.SetFontColor(_questActived_count, "255 255 255");
	_guihelper.SetUIColor(_questActived_count, "255 255 255");
	_questActived_count.enabled = false;
	_questArea:AddChild(_questActived_count);

	local _btn = ParaUI.CreateUIObject("button", "Ranking", "_rt", -78-71-50-20, 5, 51, 52);
	_btn.background = "Texture/Aries/GoldRankingList/bang_32bits.png;0 0 51 52";
	_btn.animstyle = 23;
	_btn.onclick = ";MyCompany.Aries.GoldRankingList.GoldRankingListMain.ShowMainWnd();";
	_btn.tooltip = "金牌荣誉榜";
	_questArea:AddChild(_btn);

	local _btn = ParaUI.CreateUIObject("button", "BigEvents", "_rt", -78-71-50-20-60-60-60-60, 5, 51, 46);
	_btn.background = "Texture/Aries/Desktop/bigevent_icn_32bits.png;0 0 51 46";
	_btn.animstyle = 23;
	_btn.onclick = ";MyCompany.Aries.BigEvents.BigEventsListMain.ShowMainWnd();";
	_btn.tooltip = "大事件";
	_btn.visible = false;
	_questArea:AddChild(_btn);

	local _btnhulu = ParaUI.CreateUIObject("button", "NewActivities", "_rt", -78-71-50-20-60, 6, 54, 49);
	_btnhulu.background = "Texture/Aries/Desktop/ActivityNote/huodong_32bits.png;0 0 54 49";
	_btnhulu.animstyle = 23;
	_btnhulu.onclick = ";MyCompany.Aries.Desktop.Calendar.ShowPage();";
	_btnhulu.tooltip = "活动日历";
	_questArea:AddChild(_btnhulu);

	--if(System.options.isAB_SDK)then
	local btnConsignment = ParaUI.CreateUIObject("button", "btnConsignment", "_rt", -78-71-50-20-60-65, 0, 64, 64);
	btnConsignment.background = "Texture/Aries/Common/ThemeKid/ico_consignment_32bits.png;0 0 64 64";
	btnConsignment.animstyle = 23;
	btnConsignment.onclick = ";MyCompany.Aries.NPCs.ShoppingZone.ItemsConsignment.ShowPage();";
	btnConsignment.tooltip = "寄售行";
	_questArea:AddChild(btnConsignment);
	--end

	local _btnhulu = ParaUI.CreateUIObject("button", "MiJiuHuLu", "_rt", -78-71-50-20-60-60-64-64, 0, 58, 58);
	_btnhulu.background = "Texture/Aries/Desktop/MiJiuHuLu/icon_32bits.png";
	_btnhulu.animstyle = 23;
	_btnhulu.onclick = ";MyCompany.Aries.Desktop.MiJiuHuLu.ShowPage(2);";
	_btnhulu.tooltip = "米酒葫芦";
	_btnhulu.visible = QuestArea.showhulu;
	_questArea:AddChild(_btnhulu);

	local _hulutips = ParaUI.CreateUIObject("button", "MiJiuHuLuTips", "_rt", -78-71-50-20-80-60-64-64, 32, 102, 20);
	_hulutips.background = "";
	_hulutips.tooltip = "米酒葫芦";
	_hulutips.onclick = ";MyCompany.Aries.Desktop.MiJiuHuLu.ShowPage(2);";
	_hulutips.font = "System;11;bold";
	_guihelper.SetFontColor(_hulutips, "0 0 0");
	_hulutips.shadow = true;
	_hulutips.scalingx = 1.1;
	_hulutips.scalingy = 1.1;
	_hulutips.visible = QuestArea.showhulu;
	_questArea:AddChild(_hulutips);

	local _btn_quest_weekly = ParaUI.CreateUIObject("button", "QuestWeekly", "_rt", -78-71-50-20-80-60-64-64-50, 6, 71, 46);
	_btn_quest_weekly.background = "Texture/Aries/Dock/Web/questweekly_icon_32bits.png;0 0 71 46";
	_btn_quest_weekly.animstyle = 23;
	_btn_quest_weekly.onclick = ";MyCompany.Aries.Quest.QuestWeeklyPage.ShowPage();";
	_btn_quest_weekly.tooltip = "日常任务";
	_questArea:AddChild(_btn_quest_weekly);

	local _btnbuff = ParaUI.CreateUIObject("container", "lobby_service", "_rt", -78-71-50-20-60-60-60, 0, 64, 64);
	_btnbuff.background = "";
	_questArea:AddChild(_btnbuff);
	EXPBuffArea.Create_LobbyBtn("lobby_service");


	if(EXPBuffArea.CanCreateBuff())then
		local _btnbuff = ParaUI.CreateUIObject("container", "exp_btnbuff", "_rt", -70 - 40, 62, 40, 40);
		_btnbuff.background = "";
		_questArea:AddChild(_btnbuff);
		EXPBuffArea.CreateBuff("exp_btnbuff");
	end
	if(EXPBuffArea.CanCreateBuff_Holiday())then
		local _btnbuff = ParaUI.CreateUIObject("container", "exp_btnbuff_holiday", "_rt", -70-40-40, 62, 40, 40);
		_btnbuff.background = "";
		_questArea:AddChild(_btnbuff);
		EXPBuffArea.CreateBuff_Holiday("exp_btnbuff_holiday");
	end
	if(true)then
		local _btnbuff = ParaUI.CreateUIObject("container", "exp_btn_double_exp_buff", "_rt", -70-40-40-40, 62, 40, 40);
		_btnbuff.background = "";
		_questArea:AddChild(_btnbuff);
		EXPBuffArea.CreateBuff_global_double_exp("exp_btn_double_exp_buff");
	end
	if(true)then
		local _btnbuff = ParaUI.CreateUIObject("container", "damage_boost_pill_buff", "_rt", -70-40-40-40-40, 62, 40, 40);
		_btnbuff.background = "";
		_questArea:AddChild(_btnbuff);
		EXPBuffArea.CreateBuff_damage_boost_pill("damage_boost_pill_buff");
	end
	if(true)then
		local _btnbuff = ParaUI.CreateUIObject("container", "resist_boost_pill_buff", "_rt", -70-40-40-40-40-40, 62, 40, 40);
		_btnbuff.background = "";
		_questArea:AddChild(_btnbuff);
		EXPBuffArea.CreateBuff_resist_boost_pill("resist_boost_pill_buff");
	end
	if(true)then
		local _btnbuff = ParaUI.CreateUIObject("container", "HP_boost_pill_buff", "_rt", -70-40-40-40-40-40-40, 62, 40, 40);
		_btnbuff.background = "";
		_questArea:AddChild(_btnbuff);
		EXPBuffArea.CreateBuff_HP_boost_pill("HP_boost_pill_buff");
	end
	if(true)then
		local _btnbuff = ParaUI.CreateUIObject("container", "criticalstrike_boost_pill_buff", "_rt", -70-40-40-40-40-40-40, 62, 40, 40);
		_btnbuff.background = "";
		_questArea:AddChild(_btnbuff);
		EXPBuffArea.CreateBuff_criticalstrike_boost_pill("criticalstrike_boost_pill_buff");
	end
	if(true)then
		local _btnbuff = ParaUI.CreateUIObject("container", "resilience_boost_pill_buff", "_rt", -70-40-40-40-40-40-40-40, 62, 40, 40);
		_btnbuff.background = "";
		_questArea:AddChild(_btnbuff);
		EXPBuffArea.CreateBuff_resilience_boost_pill("resilience_boost_pill_buff");
	end

	--if(System.options.isAB_SDK)then
		QuestArea.camera_mode_page = QuestArea.camera_mode_page or Map3DSystem.mcml.PageCtrl:new({url="script/apps/Aries/Desktop/CameraModeBar.html"});
		-- one can create a UI instance like this. 
		QuestArea.camera_mode_page:Create("camera_mode_page", _questArea, "_rt", -64, 62, 62, 20);
	--end

	QuestArea.Refresh();
	MyCompany.Aries.Quest.MoodPerDay.Init();
	--QuestArea.ShowDragonCount(10);
end

local MSGTYPE = commonlib.gettable("MyCompany.Aries.Desktop.MSGTYPE");

local function_available_map = 
{
	--["BigEvents"] = {available=false, min_level=6},
	["Ranking"] = {available=false, min_level=6},
	-- ["MiJiuHuLu"] = {available=false, min_level=6},
	["NewActivities"] = {available=false, min_level=7},
	["AdvancedLottery"] = {available=false, min_level=10},
	["QuestDragon"] = {available=false, min_level=5},
	["lobby_service"] = {available=false, min_level=7},
	["btnConsignment"] = {available=false, min_level=8},
	["QuestWeekly"] = {available=false, min_level=10},
	["btnTeamQuest"] = {available=false, min_level=40}, 
}

-- virtual function: Desktop window handler
function QuestArea.MSGProc(msg)
	if(msg.type == MSGTYPE.ON_LEVELUP or msg.type == MSGTYPE.ON_ACTIVATE_DESKTOP) then
		-- LOG.std(nil, "debug", "QuestArea msg", msg);
		local level = msg.level;

		local bNeedRefresh;
		local name, func_item 
		for name, func_item in pairs(function_available_map) do
			if(not func_item.available and level>=(func_item.min_level or 0)) then
				func_item.available = true;
				bNeedRefresh = true;
			end
		end
		if(level<10) then
			-- force refresh below level 10. 
			bNeedRefresh = true;
		end

		if(bNeedRefresh) then
			QuestArea.RefreshAvailableFunctions();
		end
	end
end

function QuestArea.RefreshAvailableFunctions()
	local name, func_item
	for name, func_item in pairs(function_available_map) do
		if(page) then
			local _btn = page:FindControl(name);
			if(_btn) then
				_btn.visible = func_item.available;
			end
		else
			local _questArea = ParaUI.GetUIObject("AriesQuestArea");
			if(_questArea:IsValid())  then
				_questArea:GetChild(name).visible = func_item.available;
			end
		end
	end
end

function QuestArea.ShowMijiuhulu(show)
	if(page) then
		local hulu = page:FindControl("MiJiuHuLu");
		if(hulu) then
			hulu.background = if_else(show, "Texture/Aries/Dock/kids/hulu_32bits.png;0 0 37 51", "Texture/Aries/Dock/kids/hulu_grey_32bits.png;0 0 37 51");
		end
		page:SetUIValue("MiJiuHuLuTips", "");
	else
		local _hulu = ParaUI.GetUIObject("MiJiuHuLu");
		_hulu.visible = show;
		local _hulutip = ParaUI.GetUIObject("MiJiuHuLuTips");
		_hulutip.visible = show;
	end
	QuestArea.showhulu = show;
end

function QuestArea.SetMiJiuHuLuTips(tips)
	if(page) then
		page:SetUIValue("MiJiuHuLuTips", tips);
	else
		local _hulutips = ParaUI.GetUIObject("MiJiuHuLuTips");
		_hulutips.text = tips;
	end
end

function QuestArea.FlashMiJiuHuLu(bbounce)
	if(bbounce == false)then
		QuestArea.Bounce_Static_Icon("MiJiuHuLu","stop")
		QuestClientLogics.has_bounced = false;
	else
		QuestArea.Bounce_Static_Icon("MiJiuHuLu","bounce")
		--QuestClientLogics.has_bounced = true;		
	end	
end

function QuestArea.SetFateCardTips(tips)
	--echo(tips.."||".."--------");
	--if(page) then
		--page:SetUIValue("DockFateCardTips", tips);
	--else
		local fatecardtips = ParaUI.GetUIObject("DockFateCardTips");
		--echo(fatecardtips.text);
		--echo(fatecardtips);
		fatecardtips.text = tips;
		--echo(fatecardtips.text);
		--_guihelper.SetUIColor(fatecardtips, "255 255 255")
	--end
	--echo("7777777");
end

function QuestArea.SetFateCardIcon(value)
	--echo(value);
	--echo("33333333333");
	--if(page) then
		local fatecard = ParaUI.GetUIObject("FateCard");
		fatecard.background = if_else(value, "Texture/Aries/Common/ThemeKid/fatecard/fatecard_icon.png;0 0 41 41", "Texture/Aries/Common/ThemeKid/fatecard/fatecard_grey_icon.png;0 0 41 41");

		--local fatecard = page:FindControl("FateCard");
		--if(fatecard) then
			--fatecard.src = if_else(value, "Texture/Aries/Common/ThemeKid/fatecard/fatecard_icon.png;0 0 41 41", "Texture/Aries/Common/ThemeKid/fatecard/fatecard_grey_icon.png;0 0 41 41");
		--end
		----page:SetUIValue("MiJiuHuLuTips", "");
	--else
		--local fatecard = ParaUI.GetUIObject("MiJiuHuLu");
		--if(fatecard) then
			--fatecard.src = if_else(value, "Texture/Aries/Common/ThemeKid/fatecard/fatecard_icon.png;0 0 41 41", "Texture/Aries/Common/ThemeKid/fatecard/fatecard_grey_icon.png;0 0 41 41");
		--end
		----_hulu.visible = show;
		----local _hulutip = ParaUI.GetUIObject("MiJiuHuLuTips");
		----_hulutip.visible = show;
	--end
	--QuestArea.showhulu = show;
end

-- obsoleted function
function QuestArea.ShowHeroDragonPage()
	NPL.load("(gl)script/apps/Aries/NPCs/MagicSchool/30408_HeroDragonQuest.lua");
	local HeroDragonQuest = commonlib.gettable("MyCompany.Aries.Quest.NPCs.HeroDragonQuest");
	HeroDragonQuest.PreDialog();
	QuestArea.Bounce_Static_Icon("HeroDragon","stop");
end

function QuestArea.Bounce_Static_Icon(name,bounce_or_stop)
	local _icon;
	if(page) then
		_icon = page:FindControl(name);
	else
		local _questArea = ParaUI.GetUIObject("AriesQuestArea");
		if(_questArea and _questArea:IsValid() == true)  then
			_icon = _questArea:GetChild(name);
		end
	end
	if(_icon and _icon:IsValid()) then
		if(bounce_or_stop == "bounce") then
			local fileName = "script/UIAnimation/CommonIcon.lua.table";
			UIAnimManager.LoadUIAnimationFile(fileName);
			UIAnimManager.PlayUIAnimationSequence(_icon, fileName, "Bounce", true);
		elseif(bounce_or_stop == "stop") then
			local fileName = "script/UIAnimation/CommonIcon.lua.table";
			UIAnimManager.LoadUIAnimationFile(fileName);
			UIAnimManager.StopLoopingUIAnimationSequence(_icon, fileName, "Bounce");
		end
	end
end

function QuestArea.ShowDragonCount(count)
	count = tonumber(count);
	local _questDragonCount = ParaUI.GetUIObject("QuestDragonCount");
	
	if(count <= 0) then
		_questDragonCount.visible = false;
	else
		_questDragonCount.visible = true;
		_questDragonCount.text = count .."";
	end
end

-- Kids version only API
function QuestArea.OnClickQuestDragonStatus()
	local _questDragonFlash = ParaUI.GetUIObject("QuestDragonFlash");
	_questDragonFlash.visible = false;
	MyCompany.Aries.Quest.MoodPerDay.ShowMainWnd();
end

-- show the quest message page
-- @param node: 
--	CommonCtrl.TreeNode:new({
--		type = "AriesQuestMSG", 
--		url = url})
function QuestArea.ShowQuestNode(node)
	if(node.type == "AriesQuestMSG" and node.url) then
		local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
		style.shadow_bg = "texture/bg_black_20opacity.png";
		style.fillShadowLeft = -10000;
		style.fillShadowTop = -10000;
		style.fillShadowWidth = -10000;
		style.fillShadowHeight = -10000;
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = node.url, 
			name = "Quest_Notification", 
			app_key = MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			--DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = style,
			zorder = 2,
			allowDrag = false,
			isTopLevel = true,
			directPosition = true,
				align = "_ct",
				x = -920/2,
				y = -552/2,
				width = 920,
				height = 512,
			DestroyOnClose = true,
		});
	end
end

-- if the quest notification shown
function QuestArea.IsNotificationVisible()
	local _app = MyCompany.Aries.app;
	if(_app and _app._app) then
		_app = _app._app;
		local _wnd = _app:FindWindow("Quest_Notification");
		if(_wnd) then
			if(_wnd:IsVisible()) then
				return true;
			end
		end
	end
	return false;
end

-- show the medal quest status window
function QuestArea.ShowQuestMedalStatus()
	local url = "script/apps/Aries/Quest/QuestStatusMedal.html";
	if(QuestArea.GetMedalQuestCount() == 0) then
		url = "script/apps/Aries/Quest/QuestStatusMedalEmpty.html";
	end
	
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	style.shadow_bg = "texture/bg_black_20opacity.png";
	style.fillShadowLeft = -10000;
	style.fillShadowTop = -10000;
	style.fillShadowWidth = -10000;
	style.fillShadowHeight = -10000;
	System.App.Commands.Call("File.MCMLWindowFrame", {
		-- TODO:  Add uid to url
		url = url, 
		name = "QuestStatusWnd", 
		app_key = MyCompany.Aries.app.app_key, 
		isShowTitleBar = false,
		allowDrag = false,
		--DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		style = style,
		zorder = 2,
		directPosition = true,
			align = "_ct",
			x = -820/2,
			y = -520/2,
			width = 820,
			height = 512,
	});
	System.App.Commands.Call("File.MCMLWindowFrame", {
		-- TODO:  Add uid to url
		name = "QuestStatusWnd", 
		app_key = MyCompany.Aries.app.app_key, 
		refresh = true,
	});
end

-- show the dragon quest status window
function QuestArea.ShowQuestDragonStatus()
	local url = "script/apps/Aries/Quest/QuestStatusDragon.html";
	if(QuestArea.GetDragonQuestCount() == 0) then
		url = "script/apps/Aries/Quest/QuestStatusDragonEmpty.html";
	end

	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	style.shadow_bg = "texture/bg_black_20opacity.png";
	style.fillShadowLeft = -10000;
	style.fillShadowTop = -10000;
	style.fillShadowWidth = -10000;
	style.fillShadowHeight = -10000;
	System.App.Commands.Call("File.MCMLWindowFrame", {
		-- TODO:  Add uid to url
		url = url, 
		name = "QuestStatusWnd", 
		app_key = MyCompany.Aries.app.app_key, 
		isShowTitleBar = false,
		allowDrag = false,
		--DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		style = style,
		zorder = 2,
		directPosition = true,
			align = "_ct",
			x = -820/2,
			y = -520/2,
			width = 820,
			height = 512,
	});
	System.App.Commands.Call("File.MCMLWindowFrame", {
		-- TODO:  Add uid to url
		name = "QuestStatusWnd", 
		app_key = MyCompany.Aries.app.app_key, 
		refresh = true,
	});
end

-- show the dragon quest status window
function QuestArea.ShowQuestDragonStatusByUrl(url)
	QuestArea.ShowQuestDragonStatus()
	System.App.Commands.Call("File.MCMLWindowFrame", {
		-- TODO:  Add uid to url
		name = "QuestStatusWnd", 
		url = url,
		app_key = MyCompany.Aries.app.app_key, 
		refresh = true,
	});
end

-- append to quest area for display
-- @page_url: status page url of the quest status
-- @type: "medal"|"dragon"|"normal"
-- @icon: icon of the quest status to be shown on quest area or quest list
-- @title: title of the quest status in quest status list, or tooltip in questarea
-- @(optional)gsid: icon of the quest status in quest status list, if both icon and gsid is specified, use gsid, 
--					we sort the quest list according to the obtaintime of the first item with this gsid
-- @(optional)priority: this is only useful when the type is normal, lower number indicates higher priority that stands right-most
-- @(optional)position: the position of the quest panel, table including: alignment, left, top, width, height
--		if no position is provided, use the default size
-- @(optional)onclick_callback: callback function that runs prior to MCML page if valid
function QuestArea.AppendQuestStatus(page_url, type, icon, title, gsid, priority, position, onclick_callback)
	if(page_url) then
		LOG.std("", "debug","Quest", "====QuestArea.AppendQuestStatus====")
		LOG.std("", "debug","Quest", {page_url, type, icon, title, gsid, priority, position});
	end
	QuestArea.StatusList[page_url] = {
		page_url = page_url,
		type = type,
		icon = icon,
		title = title,
		gsid = gsid,
		priority = priority,
		position = position,
		onclick_callback = onclick_callback,
	};
	QuestArea.Refresh();
end

-- remove from quest area
-- @page_url: status page url of the quest status
function QuestArea.DeleteQuestStatus(page_url)
	if(QuestArea.StatusList[page_url]) then
		LOG.std("", "debug","Quest", "====QuestArea.DeleteQuestStatus====")
		LOG.std("", "debug","Quest", page_url);
	end
	QuestArea.StatusList[page_url] = nil;
	QuestArea.Refresh();
end

-- clean up the quest status
-- @type: type of the quest status, if nil all quest status is cleaned up
function QuestArea.CleanupQuestStatus(type)
	if(type == nil) then
		LOG.warn("QuestArea.StatusList all status are cleaned up")
		QuestArea.StatusList = {};
		QuestArea.Refresh();
		return;
	else
		local page_url, param;
		for page_url, param in pairs(QuestArea.StatusList) do
			if(param.type == type) then
				QuestArea.StatusList[page_url] = nil;
			end
		end
	end
	QuestArea.Refresh();
end

function QuestArea.Refresh_QuestCnt(cnt)
	if(not cnt or QuestArea.questActivedCount == cnt)then return end
	QuestArea.questActivedCount = cnt;

	local _questActivedCount
	if(page) then
		_questActivedCount = page:FindControl("QuestActivedCount")
	else
		_questActivedCount = ParaUI.GetUIObject("QuestActivedCount");
	end
	if(_questActivedCount) then
		if(cnt == 0) then
			_questActivedCount.visible = false;
		else
			_questActivedCount.visible = true;
			_questActivedCount.text = tostring(cnt);
		end
	end
end

function QuestArea.Refresh_MailCnt(cnt)
	if(not cnt or QuestArea.mailCount == cnt)then return end
	QuestArea.mailCount = cnt;

	local _mailCount = page:FindControl("MailCount");
	if(_mailCount) then
		if(cnt == 0) then
			_mailCount.visible = false;
		else
			_mailCount.visible = true;
			_mailCount.text = tostring(cnt);
		end
	end
end

-- fresh the quest area
function QuestArea.Refresh()
	if(page) then
		-- page:Refresh();
		QuestArea.Refresh_QuestCnt(QuestArea.questActivedCount);
		QuestArea.Refresh_MailCnt(QuestArea.mailCount);
	else
		local medalQuestCount = 0;
		local dragonQuestCount = 0;
		local normalQuests = {};
		local page_url, param;
		for page_url, param in pairs(QuestArea.StatusList) do
			if(param.type == "medal") then
				medalQuestCount = medalQuestCount + 1;
			elseif(param.type == "dragon") then
				dragonQuestCount = dragonQuestCount + 1;
			elseif(param.type == "normal") then
				table.insert(normalQuests, {
					page_url = param.page_url,
					icon = param.icon,
					title = param.title,
					priority = param.priority,
				});
			end
		end
	
		---- refresh the quest counts
		--local _questMedalCount = ParaUI.GetUIObject("QuestMedalCount");
		----local _questDragonCount = ParaUI.GetUIObject("QuestDragonCount");
		--
		--if(medalQuestCount == 0) then
			--_questMedalCount.visible = false;
		--else
			--_questMedalCount.visible = false;
			--_questMedalCount.text = medalQuestCount.."";
		--end
		--if(dragonQuestCount == 0) then
			--_questDragonCount.visible = false;
		--else
			--_questDragonCount.visible = true;
			--_questDragonCount.text = dragonQuestCount.."";
		--end
	
		-- refresh the normal quest icons
		table.sort(normalQuests, function(a, b)
			return (a.priority < b.priority);
		end)
		local i;
		for i = 1, 7 do
			local _questArea = ParaUI.GetUIObject("AriesQuestArea");
			if(_questArea and _questArea:IsValid() == true)  then
				local _icon = _questArea:GetChild("Quest"..i);
				if(_icon and _icon:IsValid())  then
					local param = normalQuests[i];
					if(param) then
						-- set each normal quest icon
						_icon.background = param.icon;
						_icon.onclick = ";MyCompany.Aries.Desktop.QuestArea.ShowNormalQuestStatus(\""..param.page_url.."\");";
						_icon.tooltip = param.title;
						_icon.visible = true;
					else
						_icon.visible = false;
					end
				end
			end
		end
	end
end

-- play the bounce animation or stop for normal quest icon
-- @params quest_page_url: quest page url
-- @params bounce_or_stop: "bounce" or "stop"
function QuestArea.BounceNormalQuestIcon(quest_page_url, bounce_or_stop)
	local normalQuests = {};
	local page_url, param;
	for page_url, param in pairs(QuestArea.StatusList) do
		if(param.type == "normal") then
			table.insert(normalQuests, {
				page_url = param.page_url,
				icon = param.icon,
				title = param.title,
				priority = param.priority,
			});
		end
	end
	commonlib.echo(normalQuests);
	-- refresh the normal quest icons
	table.sort(normalQuests, function(a, b)
		return (a.priority < b.priority);
	end);
	-- animation the normal quest icon
	local i = 1;
	local _, param;
	for _, param in pairs(normalQuests) do
		if(quest_page_url == param.page_url) then
			local _questArea = ParaUI.GetUIObject("AriesQuestArea");
			if(_questArea and _questArea:IsValid() == true)  then
				local _icon = _questArea:GetChild("Quest"..i);
				if(_icon and _icon:IsValid() == true) then
					if(bounce_or_stop == "bounce") then
						local fileName = "script/UIAnimation/CommonIcon.lua.table";
						UIAnimManager.LoadUIAnimationFile(fileName);
						UIAnimManager.PlayUIAnimationSequence(_icon, fileName, "Bounce", true);
					elseif(bounce_or_stop == "stop") then
						local fileName = "script/UIAnimation/CommonIcon.lua.table";
						UIAnimManager.LoadUIAnimationFile(fileName);
						UIAnimManager.StopLoopingUIAnimationSequence(_icon, fileName, "Bounce");
					end
				end
			end
			return;
		end
		i = i + 1;
	end
end


function QuestArea.GetMedalQuestCount()
	local medalQuestCount = 0;
	local page_url, param;
	for page_url, param in pairs(QuestArea.StatusList) do
		if(param.type == "medal") then
			medalQuestCount = medalQuestCount + 1;
		end
	end
	return medalQuestCount;
end

function QuestArea.GetDragonQuestCount()
	local dragonQuestCount = 0;
	local page_url, param;
	for page_url, param in pairs(QuestArea.StatusList) do
		if(param.type == "dragon") then
			dragonQuestCount = dragonQuestCount + 1;
		end
	end
	return dragonQuestCount;
end

function QuestArea.GetUnreadDragonNotificationCount()
	local countUnread = 0;
	local count = QuestArea.QuestRootNode:GetChildCount();
	local i;
	for i = 1, count do
		local node = QuestArea.QuestRootNode:GetChild(i);
		if(node.bShown ~= true) then
			countUnread = countUnread + 1;
		end
	end
	return countUnread;
end

function QuestArea.ShowNormalQuestStatus(page_url)
	-- run the onclick callback prior to MCML page
	if(QuestArea.StatusList[page_url] and QuestArea.StatusList[page_url].onclick_callback) then
		QuestArea.StatusList[page_url].onclick_callback();
		return;
	end
	
	local url = page_url;
	local position = (QuestArea.StatusList[page_url] or {}).position or {};
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	style.shadow_bg = "texture/bg_black_20opacity.png";
	style.fillShadowLeft = -10000;
	style.fillShadowTop = -10000;
	style.fillShadowWidth = -10000;
	style.fillShadowHeight = -10000;
	System.App.Commands.Call("File.MCMLWindowFrame", {
		-- TODO:  Add uid to url
		url = url, 
		name = "QuestStatusWnd_Normal", 
		app_key = MyCompany.Aries.app.app_key, 
		isShowTitleBar = false,
		allowDrag = false,
		--DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		style = style,
		zorder = 2,
		directPosition = true,
			align = position.align or "_ct",
			x = position.x or -1020/2,
			y = position.y or -680/2,
			width = position.width or 1020,
			height = position.height or 680,
	});
	System.App.Commands.Call("File.MCMLWindowFrame", {
		-- TODO:  Add uid to url
		name = "QuestStatusWnd_Normal", 
		app_key = MyCompany.Aries.app.app_key, 
		refresh = true,
	});
end

-- flash the normal status icon
function QuestArea.FlashQuestNormalIcon(url)
	local normalQuests = {};
	local page_url, param;
	for page_url, param in pairs(QuestArea.StatusList) do
		if(param.type == "normal") then
			table.insert(normalQuests, {
				page_url = param.page_url,
				icon = param.icon,
				title = param.title,
				priority = param.priority,
			});
		end
	end
	-- refresh the normal quest icons
	table.sort(normalQuests, function(a, b)
		return (a.priority < b.priority);
	end)
	local i = 1;
	local _, param;
	for _, param in pairs(normalQuests) do
		if(url == param.page_url) then
			-- flash dragon status icon
			UIAnimManager.PlayCustomAnimation(1600, function(elapsedTime)
				local _questArea = ParaUI.GetUIObject("AriesQuestArea");
				if(_questArea and _questArea:IsValid() == true)  then
					local _icon = _questArea:GetChild("Quest"..i);
					if(_icon and _icon:IsValid() == true)  then
						local alpha = math.mod(elapsedTime, 300);
						if(alpha <= 150) then
							alpha = 100 + math.floor(155 * alpha / 150);
						elseif(alpha <= 300) then
							alpha = 255 - math.floor(155 * (alpha - 150) / 150);
						end
						_icon.color = "255 255 255 "..alpha;
						if(elapsedTime == 1600) then
							_icon.color = "255 255 255 255";
						end
					end
				end
			end);
			break;
		end
		i = i + 1;
	end
end

-- flash the quest medal status icon
function QuestArea.FlashQuestMedalIcon()
	local _questMedalFlash = ParaUI.GetUIObject("QuestMedalFlash");
	local i;
	for i = 1, 4 do
		-- flashing animation
		local block = UIDirectAnimBlock:new();
		block:SetUIObject(_questMedalFlash);
		block:SetCallfront(function (obj)
			obj.visible = true;
			end);
		block:SetTime(200);
		block:SetScalingXRange(1, 1.5);
		block:SetScalingYRange(1, 1.5);
		block:SetAlphaRange(1, 0);
		block:SetApplyAnim(true);
		block:SetCallback(function ()
			_questMedalFlash.visible = false;
		end)
		UIAnimManager.PlayDirectUIAnimation(block);
	end
end

-- flash the quest dragon status icon
function QuestArea.FlashQuestDragonIcon()
	local _questDragonFlash = ParaUI.GetUIObject("QuestDragonFlash");
	local i;
	for i = 1, 4 do
		-- flashing animation
		local block = UIDirectAnimBlock:new();
		block:SetUIObject(_questDragonFlash);
		block:SetCallfront(function (obj)
			obj.visible = true;
			end); 
		block:SetTime(3000);
		block:SetScalingXRange(1, 1.5);
		block:SetScalingYRange(1, 1.5);
		block:SetAlphaRange(1, 0);
		block:SetApplyAnim(true);
		block:SetCallback(function ()
			_questDragonFlash.visible = false;
		end)
		UIAnimManager.PlayDirectUIAnimation(block);
	end
end

local position_map = {
	[34] = {basic_gsid = 15512, beHasNote = "通用攻击:+%d%%", beNotHasNote = "增加通用攻击", stat_type = 111,},
	[35] = {basic_gsid = 15513, beHasNote = "通用防御:+%d%%", beNotHasNote = "增加通用防御", stat_type = 119,},
	[37] = {basic_gsid = 15514, beHasNote = "血量:+%d", beNotHasNote = "增加血量", stat_type = 101,},
	[38] = {basic_gsid = 15535, beHasNote = "暴击:+%d%%", beNotHasNote = "增加暴击", stat_type = 196,},
	[39] = {basic_gsid = 15536, beHasNote = "韧性:+%d%%", beNotHasNote = "增加韧性", stat_type = 204,},
	[85] = {basic_gsid = 15607, beHasNote = "通用穿透:+%d%%", beNotHasNote = "增加通用穿透", stat_type = 212,},
	[86] = {basic_gsid = 15608, beHasNote = "伤害:+%d%%", beNotHasNote = "增加伤害", stat_type = 151,},
	[87] = {basic_gsid = 15609, beHasNote = "受到伤害:-%d%%", beNotHasNote = "减少受到伤害", stat_type = 159,},
	[88] = {basic_gsid = 15610, beHasNote = "致命一击:+%d%%、绝对防御:+%d%%", beNotHasNote = "增加致命一击、绝对防御", stat_type_1 = 256, stat_type_2 = 188,},
	[89] = {basic_gsid = 15611, beHasNote = "治疗:+%d%%", beNotHasNote = "增加治疗", stat_type = 182,},
};

--更新buff状态
function QuestArea.UpdateGsidStatus()
	local k,v;
	local show_gsids = {};
	local pill_gsids = {};
	local pill_own_num = 0;
	local pill_total_num = 0;
	for k,v in ipairs(QuestArea.gsids) do
		local gsid = v.gsid;
		local icon = v.icon;
		local tooltip = v.tooltip;
		local copies = v.copies;

		if(gsid == "gift")then
			local bean = MyCompany.Aries.Pet.GetBean();
			if(bean and bean.combatlel and bean.combatlel >=12)then
				if(not hasGSItem(50398) or not hasGSItem(50399))then
					table.insert(show_gsids,{gsid = gsid, click_action = "gift",copies = 1, icon = icon, tooltip = tooltip,});		
				end
			end
		elseif(gsid == "fatecard") then
			local bean = MyCompany.Aries.Pet.GetBean();
			if(bean and bean.combatlel and bean.combatlel >=10) then
				table.insert(show_gsids,{gsid = gsid, click_action = "fatecard",copies = 1, icon = icon, tooltip = tooltip,});
			end
		elseif(gsid == "paracraft") then
			local bean = MyCompany.Aries.Pet.GetBean();
			if(bean and bean.combatlel and bean.combatlel >=0) then
				table.insert(show_gsids,{gsid = gsid, click_action = "paracraft",copies = 1, icon = icon, tooltip = tooltip,});
			end
		elseif(gsid == "monsterhandbook") then
			local bean = MyCompany.Aries.Pet.GetBean();
			if(bean and bean.combatlel and bean.combatlel >=10) then
				table.insert(show_gsids,{gsid = gsid, click_action = "monsterhandbook",copies = 1, icon = icon, tooltip = tooltip,});
			end
		elseif(gsid == "ananascoin") then
			local bean = MyCompany.Aries.Pet.GetBean();
			if(bean and bean.combatlel and bean.combatlel >=10) then
				table.insert(show_gsids,{gsid = gsid, click_action = "ananascoin",copies = 1, icon = icon, tooltip = tooltip,});
			end
		elseif(gsid == "playlittlegame") then
			local bean = MyCompany.Aries.Pet.GetBean();
			if(bean and bean.combatlel and bean.combatlel >=20) then
				table.insert(show_gsids,{gsid = gsid, click_action = "playlittlegame",copies = 1, icon = icon, tooltip = tooltip,});
			end
		elseif(gsid == "happy_summer") then
			table.insert(show_gsids,{gsid = gsid, click_action = "happy_summer",copies = 1, icon = icon, tooltip = tooltip,});
		elseif(gsid == "christmas") then
			table.insert(show_gsids,{gsid = gsid, click_action = "christmas",copies = 1, icon = icon, tooltip = tooltip,});
		elseif(gsid == "newyearday") then
			table.insert(show_gsids,{gsid = gsid, click_action = "newyearday",copies = 1, icon = icon, tooltip = tooltip,});
		elseif(gsid == "battlefieldqueue") then
			table.insert(show_gsids,{gsid = gsid, click_action = "battlefieldqueue",copies = 1, icon = icon, tooltip = tooltip,});
		elseif(gsid == "battlefieldranking") then
			table.insert(show_gsids,{gsid = gsid, click_action = "battlefieldranking",copies = 1, icon = icon, tooltip = tooltip,});
		elseif(gsid == "global_double_exp")then
			if(copies == 1)then
				table.insert(show_gsids,{gsid = gsid, copies = copies, icon = icon, tooltip = tooltip,});		
			end
		elseif(gsid == "over_weight")then
			if(Combat.IsOverWeight())then
				table.insert(show_gsids,{gsid = gsid, copies = 1, icon = icon, tooltip = tooltip,});		
			end
		elseif(gsid == "zero_durability")then
			local p = Combat.GetLowestDurabilityPercent();
			if(p <= 50 and p > 20)then
				table.insert(show_gsids,{gsid = gsid, click_action = "Bag", copies = 1, tooltip="装备已破损<br/>当一件装备耐久度为0%时，它的属性就会完全失效。<br/>打开背包，点击左下角的【修理】按钮即可修复。", extra_info = string.format([[<div style="color:#fee11c">%d%%</div>]],p), icon = "Texture/Aries/Desktop/ExpBuff/durability_60_32bits.png", });		
			elseif(p <= 20)then
				table.insert(show_gsids,{gsid = gsid, click_action = "Bag", copies = 1, tooltip="装备已严重破损<br/>当一件装备耐久度为0%时，它的属性就会完全失效。<br/>打开背包，点击左下角的【修理】按钮即可修复。", extra_info = string.format([[<div style="color:#f61909">%d%%</div>]],p), icon = "Texture/Aries/Desktop/ExpBuff/durability_20_32bits.png", });		
			end
		elseif(gsid == "slot_position_bag_0")then
			local bag = v.bag;
			local from_position = v.from_position;
			local to_position = v.to_position;
			if(bag and from_position and to_position)then
				local basic_gsid,pillgsid,beHasNote,beNotHasNote,pillNote;
				local position;
				for position = from_position,to_position do
					if(position ~= 36) then
						local item = ItemManager.GetItemByBagAndPosition(bag, position);
						
						basic_gsid = position_map[position].basic_gsid;
						beHasNote = position_map[position].beHasNote;
						beNotHasNote = position_map[position].beNotHasNote;

						if(item and item.guid and item.guid ~= 0)then
							local guid = item.guid;
							pillgsid = item.gsid;
							local pill_gsItem = ItemManager.GetGlobalStoreItemInMemory(pillgsid);

							if(position == 88) then
								local stat_type_1 = position_map[position].stat_type_1;
								local stat_value_1 = pill_gsItem.template.stats[stat_type_1];
								local stat_type_2 = position_map[position].stat_type_2;
								local stat_value_2 = pill_gsItem.template.stats[stat_type_2];
								stat_value_2 = stat_value_2/10;
								pillNote = string.format(beHasNote, stat_value_1, stat_value_2);
							elseif(pillgsid == 15617 or pillgsid == 15627) then
								beHasNote = "通用防御:+%d%%、血量:+%d";
								local stat_type_1 = 119;
								local stat_value_1 = pill_gsItem.template.stats[stat_type_1];
								local stat_type_2 = 101;
								local stat_value_2 = pill_gsItem.template.stats[stat_type_2];
								pillNote = string.format(beHasNote, stat_value_1, stat_value_2);
							elseif(pillgsid == 15623 or pillgsid == 15633) then
								beHasNote = "受到伤害:-%d%%、血量:+%d";
								local stat_type_1 = 159;
								local stat_value_1 = pill_gsItem.template.stats[stat_type_1];
								local stat_type_2 = 101;
								local stat_value_2 = pill_gsItem.template.stats[stat_type_2];
								pillNote = string.format(beHasNote, stat_value_1, stat_value_2);
							else
								local stat_type = position_map[position].stat_type;
								local stat_value = pill_gsItem.template.stats[stat_type];
								pillNote = string.format(beHasNote, stat_value);
							end
							table.insert(pill_gsids,{gsid = pillgsid, behas = true, copies = 1, guid = guid, pillNote = pillNote,});
							pill_own_num = pill_own_num + 1;
						else
							pillNote = beNotHasNote;
							pillgsid = basic_gsid;
							table.insert(pill_gsids,{gsid = pillgsid, behas = false,copies = 1, pillNote = pillNote,});
						end
						pill_total_num = pill_total_num + 1;
					end
					
				end
			end
		elseif(gsid == 40001 or gsid == 40003) then
			local bHas,__,__,count = hasGSItem(gsid);
			if(bHas)then
				table.insert(pill_gsids,{gsid = gsid, behas = true, copies = count,});	
				pill_own_num = pill_own_num + 1;
			else
				table.insert(pill_gsids,{gsid = gsid, behas = false,copies = count,});	
			end
			pill_total_num = pill_total_num + 1;
		else
			local bHas,__,__,copies = hasGSItem(gsid);
			if(bHas)then
				table.insert(show_gsids,{gsid = gsid, copies = copies, icon = icon, tooltip = tooltip,});		
			end
		end
	end
	QuestArea.pill_list = pill_gsids;
	table.insert(show_gsids,2,{gsid = "pillbuff", click_action = "pillbuff", copies = 1, icon = if_else(pill_own_num > 0,"Texture/Aries/Desktop/ExpBuff/pill_icon_32bits.png","Texture/Aries/Desktop/ExpBuff/pill_icon_grey_32bits.png"), tooltip = "pill",own_num = pill_own_num, total_num = pill_total_num,});
	--table.insert(show_gsids,3,{gsid = "pillbuff", click_action = "pillbuff", copies = 1, icon = if_else(pill_own_num > 0,"Texture/Aries/Desktop/ExpBuff/pill_icon_32bits.png","Texture/Aries/Desktop/ExpBuff/pill_icon_grey_32bits.png"), tooltip = "pill",own_num = pill_own_num, total_num = pill_total_num,});
	local nItemsPerLine = 12;
	local nCount = 0;
	local nFirstLineItem = 1;
	for k = 1,QuestArea.max_size do
		nCount = k % nItemsPerLine;
		local tmp = show_gsids[k];
		if(nCount == 1) then
			nFirstLineItem = k;
		end
		if(nCount == nItemsPerLine or k == QuestArea.max_size or (not tmp and nCount>1)) then
			QuestArea.SwapTable(nFirstLineItem, nFirstLineItem + nItemsPerLine - 1, show_gsids);
		end
		if(not tmp) then
			break;
		end
	end
	if(not commonlib.compare(QuestArea.show_gsids, show_gsids)) then
		-- only refresh if at least one item changes
		QuestArea.show_gsids = show_gsids;
		if(QuestArea.page)then
			QuestArea.page:CallMethod("buffview", "SetDataSource",QuestArea.show_gsids);
			QuestArea.page:CallMethod("buffview","DataBind");
		end
	end
end
local tmp_item_template = {is_null=true}
-- swap items in the given range. 
function QuestArea.SwapTable(start_index,end_index,source)
	if(not source)then return end
	local min = start_index
	local max = end_index
	
	local k;
	local count = math.floor((max - min+1)/2+0.5)
	for k = 0,count-1 do
		local a, b = source[min+k], source[max - k]
		source[max - k], source[min+k] = if_else(a, a, tmp_item_template), if_else(b, b, tmp_item_template);
	end
end
--注册需要显示的buff
function QuestArea.RegistGsids()
	if(not QuestArea.gsids)then
		-- following table size must less than 12
		QuestArea.gsids = {
			--{ gsid = "over_weight", label = "负重超载", icon = "Texture/Aries/Desktop/ExpBuff/over_weight_32bits.png", tooltip = "<b>负重超载</b><br/>背包中的物品超出了上限，战斗力下降一半<br/>快卖掉一些不需要的物品，或者扩展背包"},
			{ gsid = "global_double_exp", label = "青龙祝福", icon = "Texture/Aries/Desktop/ExpBuff/expbuff_double_icon_32bits.png", tooltip = "<b>青龙的祝福</b><br/>青龙大人在每个周末的晚上赐予所有哈奇魔法师的祝福<br/>战斗经验翻倍，防御强度+3%。"},
			--{ gsid = "happy_summer", label = "暑假乐翻天", icon = "Texture/Aries/Desktop/ExpBuff/happy_summer.png", tooltip = "<b>暑假乐翻天</b><br/>又到炎炎夏日，镇长爷爷特意成倍数的增加了仙豆的奖励，快点一起来疯狂一夏吧！"},
			-- 以前的药丸 加 攻击 防御 暴击 韧性    2013.10.31  lipeng
			{ gsid = "slot_position_bag_0", label = "bag", bag = 0, from_position = 34, to_position = 39, icon = "Texture/Aries/Desktop/ExpBuff/durability_60_32bits.png", tooltip = "bag_0"},
			-- 新加的药丸 加 致命 减伤 加伤 治疗 穿透    2013.10.31  lipeng
			{ gsid = "slot_position_bag_0", label = "bag", bag = 0, from_position = 85, to_position = 89, icon = "Texture/Aries/Desktop/ExpBuff/durability_60_32bits.png", tooltip = "bag_0"},
			--{ gsid = 40001, label = "经验强化药丸", icon = "Texture/Aries/Desktop/ExpBuff/expbuff_icon_32bits.png", tooltip = "<b>经验强化药丸</b><br/>平日使用<br/>使用后20场战斗经验额外增加100%",},
			--{ gsid = 40003, label = "假日努力药丸", icon = "Texture/Aries/Desktop/ExpBuff/expbuff_holiday_icon_32bits.png", tooltip = "<b>假日努力药丸</b><br/>假日使用<br/>使用后20场战斗经验加成50%",},
			{ gsid = "gift", label = "礼包", icon = "Texture/Aries/Common/Teen/gifts/gift_txt_32bits.png;0 0 40 40", tooltip = "<b>魔法哈奇最强礼包！</b>"},
			--{ gsid = "ananascoin", label = "夏日返利", icon = "Texture/Aries/Common/ThemeKid/gift/PineappleCoin_32bits.png;0 0 40 40", tooltip = "<b>清凉菠萝币，充值大返利！</b>"},
			{ gsid = "playlittlegame", label = "玩小游戏赚仙豆", icon = "Texture/Aries/Desktop/littlegame_icon.png;0 0 41 41", tooltip = "<b>玩小游戏，乐赚仙豆！</b>"},
			--{ gsid = "monsterhandbook", label = "怪物图鉴", icon = "Texture/Aries/Common/ThemeKid/monsterhandbook/ui_icon.png;0 0 41 41", tooltip = "<b>怪物图鉴</b>"},
			{ gsid = "fatecard", label = "命运卡牌", icon = "Texture/Aries/Common/ThemeKid/fatecard/fatecard_grey_icon.png;0 0 41 41", tooltip = "<b>命运卡牌拼人品<br/>仙豆奖品等着你</b>"},
			{ gsid = "battlefieldranking", label = "战魂榜", icon = "Texture/Aries/Combat/Battle/battlefield_ranking_32bits.png;0 0 41 41", tooltip = "<b>争霸排名<br/>勇夺猛犸</b>"},
			{ gsid = "battlefieldqueue", label = "英雄谷撮合", icon = "Texture/Aries/Combat/Battle/battlefield_match_32bits.png;0 0 41 41", tooltip = "<b>全新英雄谷等你来战</b>"},
			{ gsid = "paracraft", label = "创意空间", icon = "Texture/Aries/Dock/kids/paracraft_32bits.png;0 0 52 45", tooltip = "<b>热门空间完全收录！<br/>最新关卡等你挑战！</b>"},
			--{ gsid = "christmas", label = "圣诞节", icon = "Texture/Aries/Desktop/christmas_lottery.png;0 0 41 41", tooltip = "<b>打劫圣诞老人<br/>机不可失 失不再来</b>"},
			--{ gsid = "newyearday", label = "元旦", icon = "Texture/Aries/Common/ThemeKid/gift/newyearday_icon.png;0 0 41 41", tooltip = "<b>岁末充值惊喜</b>"},
		}
	end
	if(not QuestArea.timer)then
		QuestArea.timer = commonlib.Timer:new({callbackFunc = function(timer)
			QuestArea.UpdateGsidStatus();
		end});
	end
	QuestArea.timer:Change(0,5000)
end
function QuestArea.Ds_func_buff(index)
    if(not QuestArea.show_gsids)then return 0 end
    if(not index) then
        return #QuestArea.show_gsids;
    else
        return QuestArea.show_gsids[index];
    end
end
--青龙祝福
function QuestArea.ResetGsidStatus_global_double_exp(bShow, n_ExpScaleAcc)
	if(QuestArea.gsids)then
		local k,v;
		for k,v in ipairs(QuestArea.gsids) do
			if(v.gsid == "global_double_exp")then
				if(bShow)then
					v.copies = 1;
					if(n_ExpScaleAcc == 1) then
						v.tooltip = "<b>青龙的祝福</b><br/>青龙大人赐予所有哈奇的祝福<br/>战斗经验得到双倍强化！";
					elseif(n_ExpScaleAcc == 2) then
						v.tooltip = "<b>青龙的假日祝福</b><br/>青龙大人在周末晚上赐予所有哈奇的祝福<br/>战斗经验得到3倍强化！";
					elseif(n_ExpScaleAcc == 3) then
						v.tooltip = "<b>青龙的节日祝福</b><br/>青龙大人在节日赐予所有哈奇的强大祝福<br/>战斗经验得到4倍强化！";
					end
				else
					v.copies = nil;
				end
			end
		end
		QuestArea.UpdateGsidStatus();
	end
end