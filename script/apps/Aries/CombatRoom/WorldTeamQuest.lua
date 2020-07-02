--[[
Title: World Team Quest
Author(s): LiXizhi
Date: 2013/6/7
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/CombatRoom/WorldTeamQuest.lua");
local WorldTeamQuest = commonlib.gettable("MyCompany.Aries.CombatRoom.WorldTeamQuest");
WorldTeamQuest.ShowPage();

NPL.load("(gl)script/apps/Aries/CombatRoom/WorldTeamQuest.lua");
local WorldTeamQuest = commonlib.gettable("MyCompany.Aries.CombatRoom.WorldTeamQuest");
local quest_list = WorldTeamQuest.SearchQuestLinks(62226)
echo(quest_list);
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/GraphHelp.lua");
NPL.load("(gl)script/apps/Aries/Team/TeamClientLogics.lua");
local TeamClientLogics = commonlib.gettable("MyCompany.Aries.Team.TeamClientLogics");
local GraphHelp = commonlib.gettable("commonlib.GraphHelp");
NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyHelper.lua");
local LobbyHelper = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyHelper");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
NPL.load("(gl)script/apps/Aries/Desktop/AntiIndulgenceArea.lua");
local AntiIndulgenceArea = commonlib.gettable("MyCompany.Aries.Desktop.AntiIndulgenceArea");
NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClient.lua");
local LobbyClient = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClient");
NPL.load("(gl)script/apps/Aries/Quest/QuestPane.lua");
local QuestPane = commonlib.gettable("MyCompany.Aries.Quest.QuestPane");
local WorldTeamQuest = commonlib.gettable("MyCompany.Aries.CombatRoom.WorldTeamQuest");
WorldTeamQuest.catalog_list = nil; --目录
WorldTeamQuest.selected_index = nil;
WorldTeamQuest.searched_quest_links_map = {};
WorldTeamQuest.nearest_id = nil;
WorldTeamQuest.room_list = nil;--副本列表
WorldTeamQuest.selected_room_id = nil;
local page;
function WorldTeamQuest.OnInit()
	page = document:GetPageCtrl();
end

function WorldTeamQuest.ShowPage()

	local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
	local provider = QuestClientLogics.GetProvider();
	if(not provider) then
		_guihelper.MessageBox("还没有准备好，请等待1分钟再试");
		return;
	end

	WorldTeamQuest.LoadConfig();
	local url,width,height;
	if(CommonClientService.IsTeenVersion())then
		url = "script/apps/Aries/CombatRoom/WorldTeamQuest.teen.html";
		width = 620;
		height = 477;
	else
		url = "script/apps/Aries/CombatRoom/WorldTeamQuest.html";
		width = 950;
		height = 540;
	end
	local params = {
		url = url, 
		name = "WorldTeamQuest.ShowPage", 
		app_key=MyCompany.Aries.app.app_key, 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		enable_esc_key = true,
		style = CommonCtrl.WindowFrame.ContainerStyle,
		allowDrag = true,
		-- zorder = 0,
		directPosition = true,
			align = "_ct",
			x = -width/2,
			y = -height/2,
			width = width,
			height = height,
	}
	System.App.Commands.Call("File.MCMLWindowFrame", params);	
	WorldTeamQuest.ReSelected();
end
function WorldTeamQuest.LoadConfig()
	if(not WorldTeamQuest.catalog_list)then
		WorldTeamQuest.catalog_list = {};
		local file_path;
		if(CommonClientService.IsTeenVersion())then
			file_path = "config/Aries/Quests_Teen/ui_quest.xml";
		else
			file_path = "config/Aries/Quests/ui_quest.xml";
		end
		local xmlRoot = ParaXML.LuaXML_ParseFile(file_path);
		local node;
		for node in commonlib.XPath.eachNode(xmlRoot, "//categories/category/quest") do
			table.insert(WorldTeamQuest.catalog_list,node);
		end
		-- CommonClientService.Fill_List(WorldTeamQuest.catalog_list,100);
	end
end
function WorldTeamQuest.DS_Func(index)
	if(not WorldTeamQuest.catalog_list)then return 0 end
	if(index == nil) then
		return #(WorldTeamQuest.catalog_list);
	else
		return WorldTeamQuest.catalog_list[index];
	end
end
function WorldTeamQuest.GetCatalogNode(index)
	if(not index)then
		return
	end
	if(WorldTeamQuest.catalog_list and WorldTeamQuest.catalog_list[index])then
        local node = WorldTeamQuest.catalog_list[index];
		return node;
    end
end
function WorldTeamQuest.ReSelected()
	WorldTeamQuest.OnSelected(WorldTeamQuest.selected_index or 1)
end
function WorldTeamQuest.OnSelected(index)
	local node = WorldTeamQuest.GetCatalogNode(index);
	if(not node)then
		return
	end
    WorldTeamQuest.selected_room_id = nil;
    WorldTeamQuest.selected_index = index;
	local first_quest_id = tonumber(node.attr.first_quest_id);
	WorldTeamQuest.nearest_id = WorldTeamQuest.SearchNearestQuest(first_quest_id)
	WorldTeamQuest.quest_treeview_data = QuestPane.BuildContentSource(WorldTeamQuest.nearest_id)
	WorldTeamQuest.SearchRoomList(index,function()
		WorldTeamQuest.RefreshPage();
	end)
	WorldTeamQuest.RefreshPage();
end
function WorldTeamQuest.RefreshPage()
	if(page)then
		page:Refresh(0.01);
	end
end
--查找这个任务链中第一个可以执行的任务 
--return quest_id
function WorldTeamQuest.SearchNearestQuest(first_quest_id)
	local provider = QuestClientLogics.GetProvider();
	local quest_list = WorldTeamQuest.SearchQuestLinks(first_quest_id);
	if(quest_list)then
		local k,id;
		for k,id in ipairs(quest_list) do
			local canAccept = provider:CanAccept(id);
			if(canAccept)then
				return id
			end
			local hasAccept = provider:HasAccept(id);
			if(hasAccept)then
				return id
			end
		end
	end
	return first_quest_id;
end
--搜索任务链
-- @param first_quest_id:任务链的第一个id
--return list
function WorldTeamQuest.SearchQuestLinks(first_quest_id)
	if(not first_quest_id)then
		return
	end
	if(WorldTeamQuest.searched_quest_links_map and WorldTeamQuest.searched_quest_links_map[first_quest_id])then
		return WorldTeamQuest.searched_quest_links_map[first_quest_id];
	end
	local provider = QuestClientLogics.GetProvider();
	local template_graph = provider.template_graph;
	local template_graph_nodes_map = provider.template_graph_nodes_map;
	if(not template_graph or not template_graph_nodes_map)then
		return
	end
	local first_node = template_graph_nodes_map[first_quest_id];
	if(not first_node)then
		return
	end
	local output = {};
	local output_map = {};
	local function drawNodesArcs(gNode)
		if(not gNode or not output or not output_map)then return end
		local data = gNode:GetData();
		

		if(data)then
			local template = data.templateData;--模板原始数据
			if(template)then
				local id = template.Id;
				if(id)then
					id = tonumber(id);
					if(not output_map[id])then
						table.insert(output,id);
						output_map[id] = id;
					end
				end
			end
		end

	end
	WorldTeamQuest.searched_quest_links_map[first_quest_id] = output;
	local marked_map = {};
	GraphHelp.Search_DepthFirst(first_node,marked_map,drawNodesArcs);
	return output;
end
--搜索已经创建的房间
function WorldTeamQuest.SearchRoomList(index,callbackFunc)
	local node = WorldTeamQuest.GetCatalogNode(index);
	if(not node)then
		return
	end
	local keyname = node.attr.keyname;
	if(not keyname)then
		return
	end

	-- simply check ticket
	LobbyClientServicePage.CheckTicket_CanPass(keyname, false);

	-- local game_key_array = LobbyClient:GetGameKeysByUserLevel(nil, "PvE", true);
	
	LobbyClient:GetRoomListDataSource({keyname}, true, function(result)
		local list = result.formated_data;
		if(list)then
			local from_list = list;
			list = {};
			local len = #from_list;
			local _, room_info;
			for _, room_info in ipairs(from_list) do
				if(room_info and (room_info.status == "started" or keyname ~= room_info.keyname))then
					-- do nothing:
				else
					list[#list+1] = commonlib.deepcopy(room_info);
				end
			end
			WorldTeamQuest.room_list = list;
			if(callbackFunc)then
				callbackFunc();
			end
		end
	end)
end
function WorldTeamQuest.DS_Func_room_list(index)
	if(not WorldTeamQuest.room_list)then return 0 end
	if(index == nil) then
		return #(WorldTeamQuest.room_list);
	else
		return WorldTeamQuest.room_list[index];
	end
end
--questid是否已经包含在任务链中
function WorldTeamQuest.HasInclude(questid)
	if(not questid)then
		return
	end
	if(WorldTeamQuest.catalog_list)then
		local k,v; 
		for k,v in ipairs(WorldTeamQuest.catalog_list) do
			local first_quest_id = tonumber(v.attr.first_quest_id);
			local list = WorldTeamQuest.SearchQuestLinks(first_quest_id);
			if(list)then
				local __,id;
				for __,id in ipairs(list) do
					if(id == questid)then
						return true;
					end
				end
			end
		end
	end
end
function WorldTeamQuest.DoJoin(index)
	if(WorldTeamQuest.room_list and WorldTeamQuest.room_list[index])then
		local game_info = WorldTeamQuest.room_list[index];

		if(LobbyClientServicePage.DoJoinGame(game_info, nil) ~= false) then
			--NPL.load("(gl)script/apps/Aries/ServerObjects/Gatherer/GathererBarPage.lua");
			--local GathererBarPage = commonlib.gettable("MyCompany.Aries.ServerObjects.GathererBarPage");
			--GathererBarPage.Start({ duration = 7000, title = "请等待队长回复...", disable_shortkey = true, align="_ct", x=-100, y=-100,},nil,function()
			--end);
			_guihelper.MessageBox("已经发出组队请求,如果队长没有立即同意，可以试试其他队伍");
		end
	end
end

function WorldTeamQuest.CloseWindow()
	if(page) then
		page:CloseWindow();
	end
end

function WorldTeamQuest.DoCreate()
	 local node = WorldTeamQuest.GetCatalogNode(WorldTeamQuest.selected_index);
	 if(node and node.attr)then
		local keyname = node.attr.keyname;
		if(not keyname)then
			return
		end
		local game_settings = {
			game_type = "PvE",
			keyname = keyname,
		}
		if(TeamClientLogics:IsInTeam() and not TeamClientLogics:IsTeamLeader()) then
			_guihelper.MessageBox("请先离开队伍, 才能创建新队伍");
			return;
		end

		_guihelper.MessageBox("现在建立队伍, 你会被扣除1张门票, 确定建立队伍吗？", function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				WorldTeamQuest.CloseWindow();

				NPL.load("(gl)script/apps/Aries/ServerObjects/Gatherer/GathererBarPage.lua");
				local GathererBarPage = commonlib.gettable("MyCompany.Aries.ServerObjects.GathererBarPage");
				GathererBarPage.Start({ duration = 1000, title = "准备进入世界并创建队伍", disable_shortkey = true, align="_ct", x=-100, y=-100,},nil,function()
					LobbyClientServicePage.DoCreateGame(game_settings, nil, false);
				end);
			end
		end, _guihelper.MessageBoxButtons.YesNo);
	 end
end