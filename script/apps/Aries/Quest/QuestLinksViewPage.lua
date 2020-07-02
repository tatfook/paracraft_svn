--[[
Title: QuestLinksViewPage
Author(s): Leio
Date: 2013/08/12
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Quest/QuestLinksViewPage.lua");
local QuestLinksViewPage = commonlib.gettable("MyCompany.Aries.Quest.QuestLinksViewPage");
QuestLinksViewPage.ShowPage(61153);
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");

local QuestLinksViewPage = commonlib.gettable("MyCompany.Aries.Quest.QuestLinksViewPage");

QuestLinksViewPage.page_index = 1;
QuestLinksViewPage.cur_page_source = nil;
QuestLinksViewPage.hook_quest_ids = {};
QuestLinksViewPage.track_quest_id = nil;
function QuestLinksViewPage.OnInit()
	QuestLinksViewPage.page = document:GetPageCtrl();
end
function QuestLinksViewPage.LoadTemplates()
	if(QuestLinksViewPage.templates)then
		return QuestLinksViewPage.templates;
	end
	local path;
	if(CommonClientService.IsTeenVersion())then
		path = "config/Aries/Quests_Teen/quest_links_view.xml"
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
				QuestLinksViewPage.hook_quest_ids[id] = true;
			end
		end
		QuestLinksViewPage.templates = templates;
		return QuestLinksViewPage.templates;
	end
end
function QuestLinksViewPage.HasInclude_QuestIds(id)
	QuestLinksViewPage.LoadTemplates();
	if(QuestLinksViewPage.hook_quest_ids and QuestLinksViewPage.hook_quest_ids[id])then
		return true;
	end
end
function QuestLinksViewPage.SearchPageIndexByID(track_quest_id)
	if(not track_quest_id)then
		return 1;
	end
	if(QuestLinksViewPage.templates)then
		local k,v;
		for k,v in ipairs(QuestLinksViewPage.templates) do
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

function QuestLinksViewPage.ShowPage(track_quest_id)
	QuestLinksViewPage.LoadTemplates();
	if(not QuestLinksViewPage.templates or #QuestLinksViewPage.templates == 0)then
		return
	end

	local provider = QuestClientLogics.GetProvider();

	if (track_quest_id) then
		track_quest_id = tonumber(track_quest_id);
		QuestLinksViewPage.track_quest_id = track_quest_id;
		QuestLinksViewPage.page_index = QuestLinksViewPage.SearchPageIndexByID(track_quest_id);
	else	
		QuestLinksViewPage.track_quest_id = nil;
		QuestLinksViewPage.page_index = 1;
		for k,v in ipairs(QuestLinksViewPage.templates) do
			local node;
			for node in commonlib.XPath.eachNode(v, "//quest") do
				local id = node.attr.id;
				id = tonumber(id);				
				local state = provider:GetState(id);
				if (state == 0 or state ==1) then
					QuestLinksViewPage.track_quest_id = id;
					QuestLinksViewPage.page_index = k;
					break;
				end
			end
			if (QuestLinksViewPage.page_index > 1) then
				break;
			end
		end		
	end

	local url;
	if(CommonClientService.IsTeenVersion())then
		url = "script/apps/Aries/Quest/QuestLinksViewPage.teen.html"
	else
		url = "script/apps/Aries/Quest/QuestLinksViewPage.html"
	end
	local params = {
		url = url, 
		name = "QuestLinksViewPage.ShowPage", 
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
	QuestLinksViewPage.LoadPage();
end
function QuestLinksViewPage.LoadPage()
	if(QuestLinksViewPage.templates)then
		QuestLinksViewPage.cur_page_source = QuestLinksViewPage.templates[QuestLinksViewPage.page_index];
		if(QuestLinksViewPage.page)then
			QuestLinksViewPage.page:Refresh(0);
		end
	end
end
function QuestLinksViewPage.DS_Func(index)
	if(not QuestLinksViewPage.cur_page_source)then return 0 end
	if(index == nil) then
		return #(QuestLinksViewPage.cur_page_source);
	else
		return QuestLinksViewPage.cur_page_source[index];
	end
end