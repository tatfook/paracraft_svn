--[[
Title: QuestWeeklyLinksViewPage
Author(s): Leio
Date: 2013/09/05
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Quest/QuestWeeklyLinksViewPage.lua");
local QuestWeeklyLinksViewPage = commonlib.gettable("MyCompany.Aries.Quest.QuestWeeklyLinksViewPage");
QuestWeeklyLinksViewPage.ShowPage();
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
local QuestWeeklyLinksViewPage = commonlib.gettable("MyCompany.Aries.Quest.QuestWeeklyLinksViewPage");
NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");

QuestWeeklyLinksViewPage.page_index = 1;
QuestWeeklyLinksViewPage.cur_page_source = nil;
QuestWeeklyLinksViewPage.hook_quest_ids = {};
QuestWeeklyLinksViewPage.track_quest_id = nil;

-- 25级以前青年版推荐任务无特效提示
local bean = MyCompany.Aries.Pet.GetBean();
local combatlel = bean.combatlel or 0;
QuestWeeklyLinksViewPage.tips_enable = if_else(combatlel>=25,true,false);

function QuestWeeklyLinksViewPage.OnInit()
	QuestWeeklyLinksViewPage.page = document:GetPageCtrl();
end
function QuestWeeklyLinksViewPage.LoadTemplates()
	if(QuestWeeklyLinksViewPage.templates)then
		return QuestWeeklyLinksViewPage.templates;
	end
	local bean = MyCompany.Aries.Pet.GetBean();
	local combatlel = bean.combatlel or 0;

	local path;
	if(CommonClientService.IsTeenVersion())then
		path = "config/Aries/Quests_Teen/quest_links_view_weekly.xml"
	end
	if(path)then
		local templates = {};
		local xmlRoot = ParaXML.LuaXML_ParseFile(path);
		local node;
		local index = 1;
		for node in commonlib.XPath.eachNode(xmlRoot, "/items/item") do
			templates[index] = node;
			index = index + 1;
		end
		for node in commonlib.XPath.eachNode(xmlRoot, "//quest") do
			local id = node.attr.id;
			id = tonumber(id);
			if(id)then
				QuestWeeklyLinksViewPage.hook_quest_ids[id] = true;
			end
		end
		QuestWeeklyLinksViewPage.templates = templates;
		return QuestWeeklyLinksViewPage.templates;
	end
end
function QuestWeeklyLinksViewPage.HasInclude_QuestIds(id)
	QuestWeeklyLinksViewPage.LoadTemplates();
	if(QuestWeeklyLinksViewPage.hook_quest_ids and QuestWeeklyLinksViewPage.hook_quest_ids[id])then
		return true;
	end
end
function QuestWeeklyLinksViewPage.CanPush(id)
	local bean = MyCompany.Aries.Pet.GetBean();
	local combatlel = bean.combatlel or 0;
	local quest_templates = QuestHelp.GetTemplates();
	local quest_template = quest_templates[id];
	if(quest_template)then
		local provider = QuestClientLogics.GetProvider();
		local state = provider:GetState(id);

		--commonlib.echo("========quest_id:"..id..",state="..state);

		if (state == 9) then
			local isaccept,debugmsg = provider:CanAccept(id)
			if (not isaccept)then
				local quest_temp = debugmsg.template;						
				if (quest_temp.RequestAttr[1]) then							
					local maxlevel = quest_temp.RequestAttr[1].topvalue;
					if (maxlevel and maxlevel<combatlel) then
						return false
					end
				end
			end
			return false
		elseif (state == 10) then
			return false
		elseif (state<=2)then
			if (state == 2 ) then -- 只有 state = 2, canaccept 有可接任务，才特效提醒
				QuestWeeklyLinksViewPage.tips_enable = true;
			end
			return true;
		end

		--local RecommendLevel = quest_template.RecommendLevel;
		--if(not RecommendLevel)then
			--return true;
		--elseif(combatlel >= RecommendLevel)then
			--return true;
		--end
	end
end
function QuestWeeklyLinksViewPage.SearchPageIndexByID(track_quest_id)
	if(not track_quest_id)then
		return 1;
	end
	if(QuestWeeklyLinksViewPage.templates)then
		local k,v;
		for k,v in ipairs(QuestWeeklyLinksViewPage.templates) do
			local node;
			for node in commonlib.XPath.eachNode(v, "//quest") do
				local id = node.attr.id;
				id = tonumber(id);
				if(id and id == track_quest_id)then
					return k;
				end
			end
		end
	end
	return 1;
end
function QuestWeeklyLinksViewPage.ShowPage(track_quest_id)
	track_quest_id = tonumber(track_quest_id);
	QuestWeeklyLinksViewPage.track_quest_id = track_quest_id;
	QuestWeeklyLinksViewPage.LoadTemplates();
	QuestWeeklyLinksViewPage.page_index = QuestWeeklyLinksViewPage.SearchPageIndexByID(track_quest_id);
	if(not QuestWeeklyLinksViewPage.templates or #QuestWeeklyLinksViewPage.templates == 0)then
		QuestWeeklyLinksViewPage.tips_enable = false;
		return
	end
	local url;
	if(CommonClientService.IsTeenVersion())then
		url = "script/apps/Aries/Quest/QuestWeeklyLinksViewPage.teen.html"
	else
		url = "script/apps/Aries/Quest/QuestWeeklyLinksViewPage.html"
	end
	local params = {
		url = url, 
		name = "QuestWeeklyLinksViewPage.ShowPage", 
		app_key=MyCompany.Aries.app.app_key, 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		enable_esc_key = true,
		style = CommonCtrl.WindowFrame.ContainerStyle,
		allowDrag = true,
		zorder = 0,
		directPosition = true,
			align = "_ct",
			x = -760/2,
			y = -460/2,
			width = 760,
			height = 460,
	}
	System.App.Commands.Call("File.MCMLWindowFrame", params);	
	QuestWeeklyLinksViewPage.LoadPage();
end
function QuestWeeklyLinksViewPage.LoadPage()
	if(QuestWeeklyLinksViewPage.templates)then	
		QuestWeeklyLinksViewPage.tips_enable = false;
		local cur_page_source = QuestWeeklyLinksViewPage.templates[QuestWeeklyLinksViewPage.page_index];
		local result = {};
		if(cur_page_source)then
			result.attr = cur_page_source.attr;
			local k,v;
			for k,v in ipairs(cur_page_source) do
				local id = v.attr.id;
				id = tonumber(id);
				--commonlib.echo("========quest_id==:"..id);
				if(QuestWeeklyLinksViewPage.CanPush(id))then
					table.insert(result,v);
					--commonlib.echo(v);
				end
			end
		end
		QuestWeeklyLinksViewPage.cur_page_source = result;
		if(QuestWeeklyLinksViewPage.page)then
			QuestWeeklyLinksViewPage.page:Refresh(0);
		end
	end
end
function QuestWeeklyLinksViewPage.DS_Func(index)
	if(not QuestWeeklyLinksViewPage.cur_page_source)then return 0 end
	if(index == nil) then
		return #(QuestWeeklyLinksViewPage.cur_page_source);
	else
		return QuestWeeklyLinksViewPage.cur_page_source[index];
	end
end