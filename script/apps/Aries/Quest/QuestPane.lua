--[[
Title: QuestPane
Author(s): Leio
Date: 2011/07/08
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/DefaultTheme.teen.lua");
MyCompany.Aries.Theme.Default:Load();
NPL.load("(gl)script/apps/Aries/Quest/QuestPane.lua");
local QuestPane = commonlib.gettable("MyCompany.Aries.Quest.QuestPane");
QuestPane.ShowPage();

NPL.load("(gl)script/apps/Aries/Quest/QuestPane.lua");
local QuestPane = commonlib.gettable("MyCompany.Aries.Quest.QuestPane");
QuestPane.ShowPage("can_accept_quest",60119);
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/mcml/pe_aries_quest.lua");
local pe_aries_quest_item = commonlib.gettable("MyCompany.Aries.mcml_controls.pe_aries_quest_item");

NPL.load("(gl)script/apps/Aries/Quest/QuestWeekRepeat.lua");
local QuestWeekRepeat = commonlib.gettable("MyCompany.Aries.Quest.QuestWeekRepeat");
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
NPL.load("(gl)script/apps/Aries/Quest/QuestTrackerPane.lua");
local QuestTrackerPane = commonlib.gettable("MyCompany.Aries.Quest.QuestTrackerPane");
local Dock = commonlib.gettable("MyCompany.Aries.Desktop.Dock");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
local QuestPane = commonlib.gettable("MyCompany.Aries.Quest.QuestPane");
local LOG = LOG;
local ItemManager = Map3DSystem.Item.ItemManager;

QuestPane.selected_node = nil;
QuestPane.selected_type = nil;
QuestPane.datasource = nil;
QuestPane.datasource_map = {};
QuestPane.all_template_quest = nil;
QuestPane.togglebuttons_data = {
    { label="可接任务", selected = true,  value="can_accept_quest", },
    { label="已接任务",value="accepted_quest",},
    --{ label="已完成" , value="finished_quest", },
    { label="任务大全" , value="template_quest", },
}
QuestPane.menu_states = {
	--["accepted_quest"] = selected_questid,
	--["can_accept_quest"] = selected_questid,
};
---------------------------------------------------------------------------------
function QuestPane.has_value(list)
	if(list)then
		local len = #list;
		if(len > 0)then
			return true;
		end
	end
end
function QuestPane.BuildContentSource(questid)
    local provider = QuestClientLogics.GetProvider();
	local templates = provider:GetTemplateQuests();
    local template = templates[questid];
	if(not template)then return end
	local result = {};
	table.insert(result,{name = "Title"});
	table.insert(result,{name = "Detail"});
	if(QuestPane.HasRequestAttr_and_RequestQuest(questid))then
		table.insert(result,{name = "RequestQuest_RequestAttr"});
	end
	if(QuestPane.HasRecommendMembers(questid))then
		table.insert(result,{name = "RecommendMembers"});
	end
	if(QuestPane.HasWeekRepeat(questid))then
		table.insert(result,{name = "WeekRepeat"});
	end
	if(QuestPane.HasTimeStamp(questid))then
		table.insert(result,{name = "TimeStamp"});
	end
	if(QuestPane.HasGoal(questid))then
		table.insert(result,{name = "GoalListTitle"});
	end
	local function PushGoal(goal_type)
		if(QuestPane.has_value(template[goal_type]))then
			local progress_list = pe_aries_quest_item.goalProgress(template,questid,provider,goal_type);
			local k,v; 
			for k,v in ipairs(progress_list) do
				local node = { name = "Goal_Item", attr = v}
				local label,track_id,help_func = QuestTrackerPane.GetGoalLabel(goal_type,{id = v.id, value = v.cur_value, max_value = v.req_value, });
				node.attr["internal_label"] = label;
				node.attr["internal_track_id"] = track_id;
				node.attr["internal_questid"] = questid;
				node.attr["internal_help_func"] = help_func;
				node.attr["goal_type"] = goal_type;
				table.insert(result,node);
			end
		end
	end
	PushGoal("Goal");
	PushGoal("GoalItem");
	PushGoal("ClientGoalItem");
	PushGoal("ClientExchangeItem");
	PushGoal("FlashGame");
	PushGoal("ClientDialogNPC");
	PushGoal("CustomGoal");
	local item = QuestTrackerPane.GetNpcItem(questid,"StartNPC",nil);
	if(item)then
		item.name = "StartNPC";
		table.insert(result,item);
	end
	item = QuestTrackerPane.GetNpcItem(questid,"EndNPC",nil);
	if(item)then
		item.name = "EndNPC";
		table.insert(result,item);
	end
	return result;
end
function QuestPane.HasWeekRepeat(questid)
    local provider = QuestClientLogics.GetProvider();
	local templates = provider:GetTemplateQuests();
    local template = templates[questid];
    return QuestWeekRepeat.HasTemplate(template.WeekRepeat);
end
function QuestPane.HasTimeStamp(questid)
    return QuestHelp.HasTimeStamp(questid);
end
function QuestPane.HasGoal(questid)
    return QuestHelp.HasGoal(questid);
end
function QuestPane.HasRequestAttr_and_RequestQuest(questid)
    return QuestHelp.HasRequestAttr_and_RequestQuest(questid)
end
function QuestPane.HasRecommendMembers(questid)
	local provider = QuestClientLogics.GetProvider();
	local templates = provider:GetTemplateQuests();
    local template = templates[questid];
    if(template and template.RecommendMembers)then
        local arr = commonlib.split(template.RecommendMembers,"#")
		if(arr)then
            local RecommendMembers = tonumber(arr[1]);
            local RecommendMembers_Max  = tonumber(arr[2]);
            if(RecommendMembers and RecommendMembers_Max)then
                return true
            elseif(RecommendMembers and RecommendMembers > 1)then
                return true;
            end
		end
    end
end
---------------------------------------------------------------------------------
--三级菜单
function QuestPane.LoadMenuTemplate()
	local self = QuestPane;
	if(not self.menu_template)then
		local path = "config/Aries/Quests_Teen/menu.xml";
		self.menu_template = ParaXML.LuaXML_ParseFile(path);
	end
	return self.menu_template;
end
function QuestPane.CreateMenus(all_list,type)
	local self = QuestPane;
	if(not all_list or not type)then
		return;
	end
	local world;
	local menu_template = self.LoadMenuTemplate();
	menu_template = commonlib.deepcopy(menu_template);

	local empty_world = {};
	local world_index = 0;
	for world in commonlib.XPath.eachNode(menu_template, "//menus/world") do
		world_index = world_index + 1;
		--空节点记录
		local empty_world_node = empty_world[world_index] or {};
		empty_world[world_index] = empty_world_node;
		empty_world_node.all_empty = true;
		local world_id = tonumber(world.attr.id);
		local folder;
		local folder_index = 0;
		for folder in commonlib.XPath.eachNode(world, "/folder") do
			folder_index = folder_index + 1;
			empty_world_node[folder_index] = true;
			local folder_id = tonumber(folder.attr.id);
			local k,v;
			for k,v in ipairs(all_list) do
				local QuestGroup2 = v.QuestGroup2;
				local QuestGroup3 = v.QuestGroup3 or 0;
				local state = v.state;
				if(QuestGroup2 == world_id and QuestGroup3 == folder_id)then
					local item = {
						name = "item",
						attr = v;
					}
					if(type == "accepted_quest")then
						if(state == 0 or state == 1)then
							if(state == 1)then
								v.state_str = "进行中";
							end
							if(state == 0)then
								v.state_str = "可交付";
							end
							table.insert(folder,item);
							empty_world_node[folder_index] = false;
							empty_world_node.all_empty = false;
						end
					elseif(type == "can_accept_quest")then
						if(state == 2)then
							v.name = "item";
							v.state_str = "可接取";
							table.insert(folder,item);
							empty_world_node[folder_index] = false;
							empty_world_node.all_empty = false;
						end
					elseif(type == "locked_quest")then
						if(state == 9)then
							v.name = "item";
							v.state_str = "锁定";
							table.insert(folder,item);
							empty_world_node[folder_index] = false;
							empty_world_node.all_empty = false;
						end
					elseif(type == "finished_quest")then
						if(state == 10)then
							v.name = "item";
							v.state_str = "完成";
							table.insert(folder,item);
							empty_world_node[folder_index] = false;
							empty_world_node.all_empty = false;
						end
					elseif(type == "dropped_quest")then
						if(state == 11)then
							v.name = "item";
							v.state_str = "放弃";
							table.insert(folder,item);
							empty_world_node[folder_index] = false;
							empty_world_node.all_empty = false;
						end
					--任务大全
					elseif(type == "template_quest")then
						v.name = "item";
						--重新更新任务状态
						local provider = QuestClientLogics.GetProvider();
						local state = provider:GetState(v.questid);
						v.state = state;
						if(state == 0)then
							v.state_str = "可交付";
						elseif(state == 1)then
							v.state_str = "进行中";
						elseif(state == 2)then
							v.state_str = "可接取";
						elseif(state == 9)then
							v.state_str = "锁定";
						elseif(state == 10)then
							v.state_str = "完成";
						end
						empty_world_node[folder_index] = false;
						empty_world_node.all_empty = false;
						table.insert(folder,item);
					end
				end
			end
		end
	end
	--剔除没有任务的节点
	local world_nodes = menu_template[1];
	if(world_nodes)then
		local world_len = #world_nodes;
		while(world_len > 0) do
			local empty_world_node = empty_world[world_len];
			if(empty_world_node)then
				if(empty_world_node.all_empty)then
					table.remove(world_nodes,world_len);
				else
					local nodes = world_nodes[world_len];
					if(nodes)then
						local folder_len = #nodes;
						while(folder_len > 0) do
							if(empty_world_node[folder_len])then
								table.remove(nodes,folder_len);
							end
							folder_len = folder_len - 1;
						end		
					end
				end
			end
			world_len = world_len - 1;
		end
	end
	return menu_template;
end
---------------------------------------------------------------------------------
--关闭页面的时候记录了上一次选中的类型和id
function QuestPane.ClosePage()
	local self = QuestPane;
	if(self.page)then
		self.page:CloseWindow();
		self.page = nil;
	end
	self.datasource = nil;
	self.datasource_map = {};
	self.extra_reward_list = nil;
end
function QuestPane.OnInit()
	local self = QuestPane;
	self.page = document:GetPageCtrl();
end
function QuestPane.CreatePage()
	local self = QuestPane;
	local params = {
				url = "script/apps/Aries/Quest/QuestPane.teen.html", 
				name = "QuestPane.ShowPage", 
				app_key=MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				enable_esc_key = true,
				style = CommonCtrl.WindowFrame.ContainerStyle,
				allowDrag = true,
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
			Dock.OnClose("QuestPane.ShowPage")
		end
	end
end
--@param type:显示的类型 优先级为:type or self.selected_type or "accepted_quest";
--@param questid:选中的id
function QuestPane.ShowPage(type,questid)
	local self = QuestPane;
	local provider = QuestClientLogics.GetProvider();
	if(not provider)then
		LOG.std("","warning","QuestPane.ShowOrHidePage","provider is nil");
		return;
	end
	if(not provider.local_is_init)then
		LOG.std("","warning","QuestPane.ShowOrHidePage","client provider is not init");
		return;
	end

	-- open quest tracker pane
	if(not QuestTrackerPane.is_expanded) then
		QuestTrackerPane.DoExpanded(true);
	end
	local selected_type = type or self.selected_type or "can_accept_quest";
	self.FindDataSource(selected_type,questid);
	self.UpdateToggleBtn(selected_type);
	self.SetExtraRewardList();
	self.CreatePage();
	if(self.page)then
		self.page:Refresh(0);
	end
end
function QuestPane.UpdateToggleBtn(type)
	local self = QuestPane;
	local k,v;
	for k,v in ipairs(self.togglebuttons_data) do
		if(v.value == type)then
			v.selected = true;
		else
			v.selected = false;
		end
	end
end
function QuestPane.GetQuestID()
	local self = QuestPane;
	if(self.selected_type)then
		return self.menu_states[self.selected_type];
	end
end
function QuestPane.HoldQuestID(id)
	local self = QuestPane;
	if(self.selected_type)then
		self.menu_states[self.selected_type] = id;
	end
end
--@param type: "accepted_quest" "can_accept_quest" "locked_quest" "finished_quest" "dropped_quest"
--@param questid:默认选中的id
function QuestPane.FindDataSource(type,questid)
	local self = QuestPane;
	local provider = QuestClientLogics.GetProvider();
	if(not provider)then
		return;
	end
	local all_list = provider:FindQuests();
	if(not self.all_template_quest)then
		self.all_template_quest = provider:FindAllQuestsTemplate();
	end
	if(type == "template_quest")then
		all_list = self.all_template_quest;
	end
	--self.datasource_map[type] = QuestPane.CreateWorldsFolder(all_list,type);
	self.datasource_map[type] = QuestPane.CreateMenus(all_list,type);
	self.datasource = self.datasource_map[type];
	self.selected_type = type;

	local selected_questid = questid or self.menu_states[type];
	local datasource = self.datasource;
	if(datasource)then
		local find_id = false;
		local first_world;
		local first_folder;
		local first_item;
		local world;
		for world in commonlib.XPath.eachNode(datasource, "//world") do
			if(not first_world)then
				first_world = world;
			end
			local folder;
			for folder in commonlib.XPath.eachNode(world, "/folder") do
				if(not first_folder)then
					first_folder = folder;
				end
				local item;
				for item in commonlib.XPath.eachNode(folder, "/item") do
					if(not first_item)then
						first_item = item;
					end
					item.attr.checked = false;
					local questid = item.attr.questid;
					--分类全部展开
					world.attr.expanded = true;
					if(type ~= "template_quest")then
						folder.attr.expanded = true;
					end
					if(questid and selected_questid and questid == selected_questid)then
						find_id = true;
						world.attr.expanded = true;
						folder.attr.expanded = true;
						item.attr.checked = true;
						self.menu_states[type] = selected_questid;
					end
					item.attr.is_track = QuestTrackerPane.Has_Tracked(questid)
				end
			end
		end
		if(not find_id)then
			if(first_world and first_folder and first_item)then
				first_world.attr.expanded = true;
				first_folder.attr.expanded = true;
				first_item.attr.checked = true;
				self.HoldQuestID(first_item.attr.questid);
			end
		end
	end
end
function QuestPane.CreateWorldsFolder(all_list,type)
	local self = QuestPane;
	if(not all_list or not type)then
		return;
	end
	local menus = {name = "world", attr = {label = "所有", }};
	--哈奇岛
	local folder = self.CreateFolder(all_list,0,type)
	if(folder)then
		table.insert(menus,folder);
	end
	--火鸟岛
	folder = self.CreateFolder(all_list,1,type)
	if(folder)then
		table.insert(menus,folder);
	end
	--寒冰岛
	folder = self.CreateFolder(all_list,2,type)
	if(folder)then
		table.insert(menus,folder);
	end
	--沙漠岛
	folder = self.CreateFolder(all_list,5,type)
	if(folder)then
		table.insert(menus,folder);
	end
	--幽暗岛
	folder = self.CreateFolder(all_list,6,type)
	if(folder)then
		table.insert(menus,folder);
	end
	return menus;
end
function QuestPane.CreateFolder(all_list,world,type)
	local self = QuestPane;
	if(not all_list or not world)then
		return;
	end
	--item = { checked = nil, is_track = nil, questid = id, state = state, attr_level = attr_level, label = label, QuestGroup1 = QuestGroup1, QuestGroup2 = QuestGroup2, };
	local folder = { name = "folder", attr = {label = "", } };
	local label;
	if(world == 0)then
		label = "彩虹岛";
	elseif(world == 1)then
		label = "火鸟岛";
	elseif(world == 2)then
		label = "寒冰岛";
	elseif(world == 5)then
		label = "沙漠岛";
	elseif(world == 6)then
		label = "幽暗岛";
	end
	folder.attr.label = label;
	local k,v;
	for k,v in ipairs(all_list) do
		local QuestGroup2 = v.QuestGroup2;
		local state = v.state;
		if(QuestGroup2 == world)then
			local item = {
				name = "item",
				attr = v;
			}
			if(type == "accepted_quest")then
				if(state == 0 or state == 1)then
					if(state == 1)then
						v.state_str = "进行中";
					end
					if(state == 0)then
						v.state_str = "可交付";
					end
					table.insert(folder,item);
				end
			elseif(type == "can_accept_quest")then
				if(state == 2)then
					v.name = "item";
					v.state_str = "可接取";
					table.insert(folder,item);
				end
				----合并锁定任务到 可接任务里面
				--if(state == 9)then
					--v.name = "item";
					--v.state_str = "锁定";
					--table.insert(folder,item);
				--end
			elseif(type == "locked_quest")then
				if(state == 9)then
					v.name = "item";
					v.state_str = "锁定";
					table.insert(folder,item);
				end
			elseif(type == "finished_quest")then
				if(state == 10)then
					v.name = "item";
					v.state_str = "完成";
					table.insert(folder,item);
				end
			elseif(type == "dropped_quest")then
				if(state == 11)then
					v.name = "item";
					v.state_str = "放弃";
					table.insert(folder,item);
				end
			--任务大全
			elseif(type == "template_quest")then
				v.name = "item";
				--重新更新任务状态
			    local provider = QuestClientLogics.GetProvider();
				local state = provider:GetState(v.questid);
				v.state = state;
				if(state == 0)then
					v.state_str = "可交付";
				elseif(state == 1)then
					v.state_str = "进行中";
				elseif(state == 2)then
					v.state_str = "可接取";
				elseif(state == 9)then
					v.state_str = "锁定";
				elseif(state == 10)then
					v.state_str = "完成";
				end
				table.insert(folder,item);
			end
		end
	end
	--如果有内容再返回
	local len = #folder;
	if(len > 0)then
		return folder;
	end
end
--[[
获取任务额外奖励
return: reward_list,--额外奖励列表 { {gsid,num,checked}, {gsid,num,checked}, }
		req_num,--可以发送的奖励数目
		need_select,--是否还需要用户手动选择，比如有1项奖励，可选的也只有1项，那么系统会自动选择这项奖励，用户不需要再选
--]]
function QuestPane.GetExtraReword(id)
    if(not id)then
        return;
    end 
    local provider = QuestClientLogics.GetProvider();
	local templates = provider:GetTemplateQuests();
    local template = templates[id];
    if(template)then
        local v = template["Reward"];
        if(v and v[2])then
            local reward_list = {};
            local bak_reward_list = {};
			--默认自动选中的奖励 和 need_select = true配合使用
            local internal_reward_list = {};
            local list = v[2];
			--需要发的奖励数目
            local req_num = list.choice or 0;
			--是否只显示本系可以用的物品，默认是true
			local schoolfilter = list.schoolfilter or 1;
            local k,v;
            local len = #list;
            local allChecked = false;
            if(req_num >= len)then
                allChecked = true;
            end
            for k,v in ipairs(list) do
				local gsid = v.id;
				local num = v.value;

				local node = {
					gsid = gsid,
					num = num,
					checked = false,
				}
				table.insert(bak_reward_list,node);

				--只显示本系可用
				if(schoolfilter == 1)then
					local is_right_school = CommonClientService.IsRightSchool(gsid);
					local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
					if(CommonClientService.IsTeenVersion())then
						--卡牌
						if(gsItem and gsItem.template.stats[136] and gsItem.template.stats[136] > 0)then
							is_right_school = CommonClientService.IsRightSchool(gsid,nil,136);
						end
					end
					if(is_right_school)then
						local node = {
							gsid = gsid,
							num = num,
							checked = true,
							index = k,--奖励索引
						}
						table.insert(reward_list,node);
					end
				else
					local node = {
						gsid = gsid,
						num = num,
						checked = allChecked,
						index = k,--奖励索引
					}
					table.insert(reward_list,node);
				end
            end
			local len = #reward_list;
			--是否还需要用户手动选择奖励，
			local need_select = true;

			if(req_num == len)then
				need_select = false;
			else
				--如果可选的奖励数目不够
				if(req_num > len)then
					reward_list = bak_reward_list;
				end
			end
            return reward_list,req_num,need_select;
        end
    end
end
--更新奖励数据源
function QuestPane.SetExtraRewardList()
	local self = QuestPane;
	self.extra_reward_list = nil;
	local id = QuestPane.GetQuestID()
	local extra_reward_list,req_num = self.GetExtraReword(id);
	self.extra_reward_list = extra_reward_list;
	if(self.page)then
		self.page:CallMethod("extra_reward_view", "SetDataSource", extra_reward_list or {});
		self.page:CallMethod("extra_reward_view", "DataBind"); 
	end
end