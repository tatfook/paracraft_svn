--[[
Title: 
Author(s): Leio
Date: 2010/10/25
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Quest/QuestTrackerPane.lua");
local QuestTrackerPane = commonlib.gettable("MyCompany.Aries.Quest.QuestTrackerPane");
QuestTrackerPane.Show(true);

NPL.load("(gl)script/apps/Aries/Quest/QuestTrackerPane.lua");
local QuestTrackerPane = commonlib.gettable("MyCompany.Aries.Quest.QuestTrackerPane");
QuestTrackerPane.NeedReload();
QuestTrackerPane.ReloadPage();

NPL.load("(gl)script/apps/Aries/Quest/QuestTrackerPane.lua");
local QuestTrackerPane = commonlib.gettable("MyCompany.Aries.Quest.QuestTrackerPane");
local list = QuestTrackerPane.GetModeWorldList();
echo("==============list");
echo(list);
------------------------------------------------------------
]]
local LOG = LOG;
NPL.load("(gl)script/ide/Debugger/NPLProfiler.lua");
local npl_profiler = commonlib.gettable("commonlib.npl_profiler");
NPL.load("(gl)script/apps/Aries/Quest/QuestPathfinderNavUI.lua");
local QuestPathfinderNavUI = commonlib.gettable("MyCompany.Aries.Quest.QuestPathfinderNavUI");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
NPL.load("(gl)script/apps/Aries/Quest/NPCList.lua");
local NPCList = commonlib.gettable("MyCompany.Aries.Quest.NPCList");
NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
NPL.load("(gl)script/apps/Aries/mcml/pe_goal_pointer.lua");
local goal_manager = commonlib.gettable("MyCompany.Aries.mcml_controls.goal_manager");

local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
local QuestArea = commonlib.gettable("MyCompany.Aries.Desktop.QuestArea");
local NPC = commonlib.gettable("MyCompany.Aries.Quest.NPC");
local Player = commonlib.gettable("MyCompany.Aries.Player");		
local QuestTrackerPane = commonlib.gettable("MyCompany.Aries.Quest.QuestTrackerPane");
local BasicArena = commonlib.gettable("MyCompany.Aries.Quest.NPCs.BasicArena");
QuestTrackerPane.tree_view_data = nil;
QuestTrackerPane.tree_view_data_1 = nil;
QuestTrackerPane.tree_view_data_2 = nil;
QuestTrackerPane.show_state = 1;--1 已接任务 or 2 可接任务
QuestTrackerPane.q_list = nil;
QuestTrackerPane.has_accept_quest_map = {};
QuestTrackerPane.can_accept_cnt = 0;

--任务追踪 切换世界后没有立即获取到mob坐标 用timer刷新 直至找到位置
--如果切换追踪 取消追踪 清空
local pending_mob_track_timer = nil;
local try_find_num = 0;
local bg_timer;

--青年版只需一个分类 QuestTrackerPane.show_state = 1 QuestTrackerPane.tree_view_data_1
--然后用group_filter_menus过滤
QuestTrackerPane.group_filter_menus = {
	{p_label = "修行", selected = true, keyname = 0, UnSelectedMenuItemBG = "Texture/Aries/Common/Teen/quest/tab_1_32bits.png;0 0 40 31", SelectedMenuItemBG = "Texture/Aries/Common/Teen/quest/tab_1_selected_32bits.png;0 0 40 31",},
	{p_label = "挑战", keyname = 1, UnSelectedMenuItemBG = "Texture/Aries/Common/Teen/quest/tab_2_32bits.png;0 0 40 31", SelectedMenuItemBG = "Texture/Aries/Common/Teen/quest/tab_2_selected_32bits.png;0 0 40 31",},
	{p_label = "对战", keyname = 2, UnSelectedMenuItemBG = "Texture/Aries/Common/Teen/quest/tab_3_32bits.png;0 0 40 31", SelectedMenuItemBG = "Texture/Aries/Common/Teen/quest/tab_3_selected_32bits.png;0 0 40 31",},
	{p_label = "休闲", keyname = 3, UnSelectedMenuItemBG = "Texture/Aries/Common/Teen/quest/tab_4_32bits.png;0 0 40 31", SelectedMenuItemBG = "Texture/Aries/Common/Teen/quest/tab_4_selected_32bits.png;0 0 40 31",},
	--{p_label = "活动", keyname = 4, },
	{p_label = "全部", keyname = -1, UnSelectedMenuItemBG = "Texture/Aries/Common/Teen/quest/tab_all_32bits.png;0 0 40 31", SelectedMenuItemBG = "Texture/Aries/Common/Teen/quest/tab_all_selected_32bits.png;0 0 40 31",},
}
function QuestTrackerPane.DoSelectedGroupMenuNode(value)
	value = value or 1;
	local k,v;
	for k,v in ipairs(QuestTrackerPane.group_filter_menus) do
		if(v.keyname == value)then
			v.selected = true;
		else
			v.selected = false;
		end
	end
end
function QuestTrackerPane.GetSelectedGroupMenuNode()
	local k,v;
	for k,v in ipairs(QuestTrackerPane.group_filter_menus) do
		if(v.selected)then
			return v;
		end
	end
end
QuestTrackerPane.filter_menus = {
	{label = "全部", selected = true, keyname = -1,},
	{label = "1人", keyname = 1, min = 1, max = 1,},
	{label = "2人", keyname = 2, min = 2, max = 2,},
	{label = "多人", keyname = 3, min = 3, max = 10,},
}
function QuestTrackerPane.DoJump_params(params)
    if(params) then
        local questid,goalid,goaltype = params.internal_questid,params.internal_track_id,params.goal_type;
        QuestTrackerPane.TrackCurrentGoal(goalid);
		
		local item_info,about_questtype = QuestHelp.SearchTemplateItemByID(goalid);
        if(item_info and about_questtype)then
            if(about_questtype == "CustomGoal")then
                if(item_info.helpfunction and item_info.helpfunction~="" )then
            	    NPL.DoString(item_info.helpfunction);
                end
                if(not item_info.position)then
                    return;
                end
            end
        end
		if(WorldManager:IsInInstanceWorld())then
			_guihelper.MessageBox("你目前在副本当中，不能追踪！");
			return
		end
        QuestTrackerPane.DoJump(questid,goalid,goaltype);
    end
end
function QuestTrackerPane.DoJump_InPage(name,mcmlNode)
    local params = mcmlNode:GetPreValue("this", true);
	QuestTrackerPane.DoJump_params(params);
end
function QuestTrackerPane.DoTrack(name, mcmlNode)
    local params = mcmlNode:GetPreValue("this", true);
    if(params) then
        local questid,goalid,goaltype = params.internal_questid,params.internal_track_id,params.goal_type;
        -- automatically set current goal
        QuestTrackerPane.TrackCurrentGoal(goalid);

        local item_info,about_questtype = QuestHelp.SearchTemplateItemByID(goalid);
        if(item_info and about_questtype)then
            --只对自定义任务目标 做特殊判断
            if(about_questtype == "CustomGoal")then
                --如果有特殊触发函数
                if(item_info.helpfunction and item_info.helpfunction~="" )then
            	    NPL.DoString(item_info.helpfunction);
                    return;
                end
                --如果没有跳转坐标
                if(not item_info.position)then
                    return;
                end
            end
        end
        if(WorldManager:IsInInstanceWorld())then
            _guihelper.MessageBox("你目前在副本当中，不能追踪！");
            return
        end
        
        local is_active = QuestTrackerPane.FindPath_IsActive(questid,goalid);
        if(false and is_active)then
            QuestTrackerPane.FindPath_Active(nil, nil);
            QuestTrackerPane.page:CallMethod("view_questtrack", "Update");
        else
            QuestTrackerPane.FindPath_Active(questid,goalid);
	        QuestTrackerPane.page:CallMethod("view_questtrack", "Update");
        end

        if(name == "btnTrack") then
            -- only check task but not start navigation
        else
            QuestTrackerPane.StartAutoNavigation(questid,goalid,goaltype);
        end
    end
end
function QuestTrackerPane.ResetFilterMenu()
	if(QuestTrackerPane.filter_menus)then
		local k,v;
		for k,v in ipairs(QuestTrackerPane.filter_menus) do
			if(k == 1)then
				v.selected = true;
			else
				v.selected = nil;
			end
		end
	end
end
--是否显示任务过滤
function QuestTrackerPane.NeedShowFilterMenu()
	--if(CommonClientService.IsTeenVersion())then
		--if(QuestTrackerPane.show_state == 1)then
			--if(QuestTrackerPane.tree_view_data_1)then
				--local len = #QuestTrackerPane.tree_view_data_1;
				--if(len >= 10)then
					--return true;
				--end
			--end
		--elseif(QuestTrackerPane.show_state == 2)then
			--if(QuestTrackerPane.tree_view_data_2)then
				--local len = #QuestTrackerPane.tree_view_data_2;
				--if(len >=10)then
					--return true;
				--end
			--end
		--end
	--end
	return true;
end
--返回选中的菜单
function QuestTrackerPane.GetSelectedMenuNode()
	local k,v;
	for k,v in ipairs(QuestTrackerPane.filter_menus) do
		if(v.selected)then
			return v;
		end
	end
end
function QuestTrackerPane.OnInit()
	local self = QuestTrackerPane;
	self.page = document:GetPageCtrl();
end
--标记需要重新加载数据
function QuestTrackerPane.NeedReload()
	local self = QuestTrackerPane;
	self.is_dirty = true;	
end
function QuestTrackerPane.DoChangeShowState(state)
	local self = QuestTrackerPane;
	self.show_state = state;
	QuestTrackerPane.ResetFilterMenu();
	self.ReloadPage();
end
--根据切换状态 返回tree_view_data
function QuestTrackerPane.GetCurStateTreeviewData()
	local self = QuestTrackerPane;
	if(self.show_state == 1)then
		return self.tree_view_data_1;
	else
		return self.tree_view_data_2;
	end
end
--加载数据并刷新页面
function QuestTrackerPane.ReloadPage()
	if(CommonClientService.IsTeenVersion())then
		--npl_profiler.perf_begin("QuestTrackerPane.ReloadPage", true);
		local v = QuestTrackerPane.LoadTrackState();
		QuestTrackerPane.DoSelectedGroupMenuNode(v);
		QuestTrackerPane.ReloadPage_teen();
		-- 0.0485s on android phone 2015.3.30
		--npl_profiler.perf_end("QuestTrackerPane.ReloadPage", true);
		--LOG.std(nil, "info", "QuestTrackerPane.ReloadPage Perf", npl_profiler.perf_get("QuestTrackerPane.ReloadPage"));
	else
		QuestTrackerPane.ReloadPage_kids();
	end
end
function QuestTrackerPane.ReloadPage_kids()
	local self = QuestTrackerPane;
	if(self.page)then
		local track_is_empty = false;
		self.tree_view_data = self.GetCurStateTreeviewData();
		if(self.is_dirty or not self.tree_view_data)then
			self.tree_view_data_1,self.tree_view_data_2 = self.SearchQuestsState();
			if(self.tree_view_data_1 and #self.tree_view_data_1 > 0)then
				self.show_state = 1;
				if(self.find_path_questid and self.find_path_goalid)then
					-- tricky: we will always refresh the goal for the current quest when quest state changes
					self.find_path_goalid = nil;
				end
			else
				self.show_state = 2;
				track_is_empty = true;
				self.find_path_questid = nil;
				self.find_path_goalid = nil;
			end
			self.tree_view_data = self.GetCurStateTreeviewData();
			self.is_dirty = false;	
		end
		-- for kids version, always turn off area tips if page has been refreshed. 
		QuestHelp.ActiveAreaTip(false);
		self.page:Refresh(0);
	end
end
function QuestTrackerPane.ReloadPage_teen()
	local self = QuestTrackerPane;
	if(self.page)then
		--青年版只显示一个分类
		self.show_state = 1;
		self.tree_view_data = self.GetCurStateTreeviewData();
		if(self.is_dirty or not self.tree_view_data)then
			self.tree_view_data_1,self.tree_view_data_2 = self.SearchQuestsState();
			self.tree_view_data = self.GetCurStateTreeviewData();
			if(self.tree_view_data and #self.tree_view_data > 0)then
				if(self.find_path_questid and self.find_path_goalid)then
					-- tricky: we will always refresh the goal for the current quest when quest state changes
					self.find_path_goalid = nil;
				end
			else
				self.find_path_questid = nil;
				self.find_path_goalid = nil;
			end
			self.is_dirty = false;	
		end
		
		if(self.find_path_questid and self.find_path_goalid)then
			self.FindPath_ReActive();
		else
			if(not self.find_path_questid)then
				self.FindPath_ActiveTopGoal();
			else
				self.FindPath_ActiveNextGoal();
			end
		end
		--根据推荐人数 过滤显示
		if(self.tree_view_data and QuestTrackerPane.NeedShowFilterMenu())then
			local group_menu_node = QuestTrackerPane.GetSelectedGroupMenuNode();			
			if(group_menu_node)then
				local keyname = group_menu_node.keyname;
				if(keyname > -1)then
					local result = {};
					local k,v;
					for k,v in ipairs(self.tree_view_data) do
						if(v.attr)then
							local questid = v.attr.questid;
							local templates = QuestHelp.GetTemplates();
							local template = templates[questid];
							if(template and template.QuestTrackGroup and (keyname == template.QuestTrackGroup))then
								table.insert(result,v);
							end
						end
						
					end
					self.tree_view_data = result;
				end
			end
			--local menu_node = QuestTrackerPane.GetSelectedMenuNode();			
			--if(menu_node)then
				--local keyname = menu_node.keyname;
				--local min = menu_node.min or 1;
				--local max = menu_node.max or 10;
				--if(keyname > -1)then
					--local result = {};
					--local k,v;
					--for k,v in ipairs(self.tree_view_data) do
						--local can_push = false;
						--if(v.attr)then
							--local questid = v.attr.questid;
							--local templates = QuestHelp.GetTemplates();
							--local template = templates[questid];
							--if(template)then
								--local arr = commonlib.split(template.RecommendMembers,"#")
								--local RecommendMembers = tonumber(arr[1]);
								--if(not RecommendMembers)then
									--can_push = true;
								--else
									--if(RecommendMembers >= min and RecommendMembers <= max)then
										--can_push = true;
									--end
								--end
								--if(can_push)then
									--table.insert(result,v);
								--end
							--end
						--end
						--
					--end
					--self.tree_view_data = result;
				--end
			--end
		end
		QuestTrackerPane.UpdateQuestCntInDock(QuestTrackerPane.can_accept_cnt);
		self.page:Refresh(0);
	end
end
function QuestTrackerPane.ShowPage()
	local self = QuestTrackerPane;
	self.LoadState();
	local params;
	if(System.options.version == "kids") then
		params = {
			url = "script/apps/Aries/Quest/QuestTrackerPane.html", 
			name = "QuestTrackerPane.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = false, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = -1, -- avoid interaction with other normal user interface
			click_through = true, -- allow clicking through
			bShow = true,
			allowDrag = false,
			isPinned = true,
			cancelShowAnimation = true,
			directPosition = true,
				align = "_mr",
				x = 0,
				y = 120,
				width = 250,
				height = 125,
		};
	else
		params = {
			url = "script/apps/Aries/Quest/QuestTrackerPane.teen.html", 
			name = "QuestTrackerPane.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = false, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = -1, -- avoid interaction with other normal user interface
			click_through = true, -- allow clicking through
			bShow = true,
			allowDrag = false,
			isPinned = true,
			cancelShowAnimation = true,
			directPosition = true,
				align = "_mr",
				x = 0,
				y = 200,
				width = 270,
				height = 125,
		};
	end
	if(System.options.IsMobilePlatform) then
		-- params.SelfPaint = true;
		params.align = "_rt";
		params.x = params.x - params.width;
		params.height = 120;
	end

	System.App.Commands.Call("File.MCMLWindowFrame", params);
	self.ReloadPage();
	MyCompany.Aries.event:AddEventListener("pay_after", function(self, event) 
		QuestTrackerPane.NeedReload();
		QuestTrackerPane.ReloadPage();	
		QuestClientLogics.UpdateUI();
	end, nil, "QuestTrackerPane_aries_external_pay_money");
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, callback = QuestTrackerPane.HookHandler, 
			hookName = "Hook_QuestTrackerPane", appName = "Aries", wndName = "main"});
end
--任务进度的显示数据
function QuestTrackerPane.GetGoalLabel(goal_type,goal_info)
	local self = QuestTrackerPane;
	if(not goal_type or not goal_info)then return end
	local label;
	local track_id;
	local help_func;
	if(goal_type == "Goal")then
		local id = goal_info.id;
		track_id = id;
		local __,map = QuestHelp.GetGoalList();
		local item = map[id]
		if(item)then
			local value = goal_info.value or 0;
			local max_value = goal_info.max_value or 0;
			label = string.format("消灭【%s】%d个(%d/%d)",item.label or "",max_value,value,max_value);
			help_func = item.helpfunction;
		end
	elseif(goal_type == "GoalItem")then
		local id = goal_info.id;
		track_id = goal_info.producer_id;
		local __,map = QuestHelp.GetQuestItemList();
		local item = map[id]
		if(item)then
			local value = goal_info.value or 0;
			local max_value = goal_info.max_value or 0;
			label = string.format("找到【%s】%d个(%d/%d)",item.label or "",max_value,value,max_value);
			local __,temp_map = QuestHelp.GetGoalList();
			local temp_item = temp_map[track_id];
			if(temp_item)then
				help_func = temp_item.helpfunction;
			end
		end
	elseif(goal_type == "ClientGoalItem")then
		local id = goal_info.id;
		track_id = id;
		local __,map = QuestHelp.GetClientItemList();
		local item = map[id]
		if(item)then
			local value = goal_info.value or 0;
			local max_value = goal_info.max_value or 0;
			label = string.format("收集【%s】%d个(%d/%d)",item.label or "",max_value,value,max_value);
			help_func = item.helpfunction;
		end
	elseif(goal_type == "ClientExchangeItem")then
		local id = goal_info.id;
		--合成只能在这个位置
		track_id = 30345;
		local __,map = QuestHelp.GetClientExchangeItemList();
		local item = map[id]
		if(item)then
			local value = goal_info.value or 0;
			local max_value = goal_info.max_value or 0;
			label = string.format("合成【%s】%d次(%d/%d)",item.label or "",max_value,value,max_value);
		end
	elseif(goal_type == "FlashGame")then
		local id = goal_info.id;
		track_id = id;
		local __,map = QuestHelp.GetFlashGameList();
		local item = map[id]
		if(item)then
			local value = goal_info.value or 0;
			local max_value = goal_info.max_value or 0;
			label = string.format("玩小游戏【%s】%d次(%d/%d)",item.label or "",max_value,value,max_value);
		end
	elseif(goal_type == "ClientDialogNPC")then
		local id = goal_info.id;
		track_id = id;
		local __,map = QuestHelp.GetNpcList();
		local item = map[id]
		if(item)then
			local value = goal_info.value or 0;
			local max_value = goal_info.max_value or 0;
			label = string.format("对话【%s】%d次(%d/%d)",item.label or "",max_value,value,max_value);
		end
	elseif(goal_type == "CustomGoal")then
		local id = goal_info.id;
		track_id = id;
		local __,map = QuestHelp.GetCustomGoalList();
		local item = map[id]
		if(item)then
			local customlabel = item.customlabel;
			local value = goal_info.value or 0;
			local max_value = goal_info.max_value or 0;
			if(id == 20046 or id == 20048)then
				value = value + 1000;
				max_value = max_value + 1000;
			end
			if(customlabel)then
				customlabel = string.format(customlabel,max_value);
				label = string.format("%s(%d/%d)",customlabel,value,max_value);
			else
				label = string.format("获得【%s】%d个(%d/%d)",item.label or "",max_value,value,max_value);
			end
			help_func = item.helpfunction;
		end
	end
	return label,track_id,help_func;
end

function QuestTrackerPane.SortQuest(q_list)
	local self = QuestTrackerPane;
	if(not q_list)then return end
	table.sort(q_list,function(a,b)
		return (a.track_time < b.track_time) 
			or ( (a.track_time == b.track_time) and (a.state < b.state) ) 
			or ( (a.track_time == b.track_time) and (a.state == b.state) and (a.QuestGroup1 < b.QuestGroup1) ) 
			or ( (a.track_time == b.track_time) and (a.state == b.state) and (a.QuestGroup1 == b.QuestGroup1) and (a.RecommendLevel > b.RecommendLevel) ) ;
	end);
end

-- set current goal 
function QuestTrackerPane.TrackCurrentGoal(template_id)
    local template = QuestHelp.SearchTemplateItemByID(template_id)
    
    if(template and template.goalpointer) then
        template.goalpointer.id = template.id;
        goal_manager.SetCurrentGoal(template.goalpointer.type, template.goalpointer);
    end
end
--是否包含主线任务
function QuestTrackerPane.IncludeMainQuest(folder_view)
	local self = QuestTrackerPane;
	local templates = QuestHelp.GetTemplates();
	if(folder_view)then
		local k,v;
		for k,v in ipairs(folder_view) do
			if(v.attr and v.attr.questid and templates[v.attr.questid])then
				local template = templates[v.attr.questid];
				local QuestGroup1 = template.QuestGroup1;
				if(QuestGroup1 and QuestGroup1 == 0)then
					return true;
				end
			end
		end
	end
end
-- 搜索任务链的最顶端
-- @param deepest_questid:最底端任务id
-- @param search_state:任务状态 2 can_accept, 9 locked
-- @param result:搜索结果 result.id = id;
function QuestTrackerPane.FindTopQuest(deepest_questid,search_state,result)
	if(not deepest_questid or not result)then
		return
	end
	result.id = deepest_questid;
	local provider = QuestClientLogics.GetProvider();
	local templates = QuestHelp.GetTemplates();
	local template = templates[deepest_questid];
	if(template)then
		local RequestQuest = template.RequestQuest;
		local node = RequestQuest[1];
		if(node and node.id)then
			if(search_state)then
				local state = provider:GetState(node.id);
				if(search_state == state)then
					QuestTrackerPane.FindTopQuest(node.id,search_state,result)
				end
			else
				QuestTrackerPane.FindTopQuest(node.id,search_state,result)
			end
		end
	end
end
--查找最接近战斗等级的一个 主线任务
function QuestTrackerPane.FindNearestMainQuest()
	local self = QuestTrackerPane;
	local templates = QuestHelp.GetTemplates();
	local bean = MyCompany.Aries.Pet.GetBean();
	local combatlel = bean.combatlel or 0;
	--已经根据推荐等级从高到低排序
	if(self.q_list)then
		local quest_map = {};
		local can_accept_list = {};
		local locked_list = {}; 
		local len = #self.q_list;
		while(len > 0)do
			local node = self.q_list[len];
			if(node)then
				local questid = node.questid;
				local state = node.state;
				if(questid and templates[questid])then
					local template = templates[questid];
					local RecommendLevel = template.RecommendLevel or 0;--推荐等级
					local QuestGroup1 = template.QuestGroup1;

					if(QuestGroup1 and QuestGroup1 == 0)then
						if(state == 2)then
							table.insert(can_accept_list,node);
						elseif(state == 9)then
							if(RecommendLevel >= combatlel)then
								table.insert(locked_list,node);
							end
						end
					end
				end	
				quest_map[questid] = node;
			end
			len = len - 1;
		end
		if(can_accept_list[1])then
			return can_accept_list[1];
		end
		local len = #locked_list;
		local node = locked_list[len];
		if(node)then
			local result = {};
			QuestTrackerPane.FindTopQuest(node.questid,9,result)
			if(result and result.id)then
				node = quest_map[result.id];
			end
		end
		return node;
	end
end
--@param questid:任务id
--@param npc_type:"StartNPC" or "EndNPC"
--@param state:任务状态
function QuestTrackerPane.GetNpcItem(questid,npc_type,state)
	local self = QuestTrackerPane;
	if(not questid or not npc_type)then return end
	local templates = QuestHelp.GetTemplates();
	local template = templates[questid];
	if(template)then
		local npc_id = template[npc_type];
		if(npc_id)then
			local __,map = QuestHelp.GetNpcList();
			local npc_item = map[npc_id];
			if(npc_item)then
				local name = npc_item.label or "";
				local place = npc_item.place or "";

				local npc, worldname, npc_data = NPCList.GetNPCByIDAllWorlds(npc_id);
				local world_info = WorldManager:GetWorldInfo(worldname);
				local cur_world_info = WorldManager:GetCurrentWorld()
				local the_same_world;
				local label;
				if(cur_world_info.name == worldname)then
					if(place == "")then
						label = string.format("%s",name);
					else
						label = string.format("%s(%s)",name,place);
					end
				else
					if(place == "")then
						label = string.format("%s(%s)",name,world_info.world_title or "");
					else
						label = string.format("%s(%s,%s)",name,world_info.world_title or "",place);
					end
				end

				local node = {};
				node["internal_label"] = label;
				node["internal_track_id"] = npc_id;
				node["internal_questid"] = questid;
				node["internal_state"] = state;
				node["goal_type"] = npc_type;
				local item = {
					name = "item", attr = node,
				};	
				return item;
			end
		end
	end
end
function QuestTrackerPane.SearchQuestsState()
	local self = QuestTrackerPane;
	local provider = QuestClientLogics.provider;
	if(not provider)then return end
	local q_list = provider:FindQuests(true);
	if(not q_list)then return end
	self.SortQuest(q_list);
	self.q_list = q_list;
	self.has_accept_quest_map = {};
	self.can_accept_cnt = 0;

	local templates = QuestHelp.GetTemplates();
	local k,q;
	--已经接受 和 可以接受的
	local tree_view_data_1 = {};
	--可以接受的
	local tree_view_data_2 = {};

	local find_questid;
	local find_track_id;

	-- whether to show arrow tips 
	local bShowArrowPointer;

	local function ResetShowPointer_()
		if(System.options.version == "kids") then
			bShowArrowPointer = (MyCompany.Aries.Player.GetLevel()<=35)
		end
	end
	ResetShowPointer_();

	local function check(questid,track_id)
		if(not find_questid and self.show_state == 1)then
			if(self.find_path_questid and questid and self.find_path_questid == questid)then
				find_questid = true;
			end
		end
		if(not find_track_id and self.show_state == 1)then
			if(self.find_path_goalid and track_id and self.find_path_goalid == track_id)then
				find_track_id = true;
			end
		end
	end
	--@param questid:任务id
	--@param npc_type:"StartNPC" or "EndNPC"
	--@param state:任务状态
	local function GetNpcItem(questid,npc_type,state)
		local node = QuestTrackerPane.GetNpcItem(questid,npc_type,state);
		if(bShowArrowPointer) then
			if(node.attr) then
				node.attr["ShowArrowPointer"] = true;
			end
			node["ShowArrowPointer"] = true;
			bShowArrowPointer = nil;
		end
		--检测寻路目标是否存在
		check(questid,npc_id);
		return node;
	end
	local function create_subfolder(parent,goal_info,goal_type,questid,state)
		if(not parent or not goal_info)then return end
		local len = #goal_info;
		if(len > 0)then
			local node = commonlib.deepcopy(goal_info);
			local k,v;
			for k,v in ipairs(goal_info) do
				if(v.value and v.max_value and v.value < v.max_value)then
					local node = commonlib.deepcopy(v);
					local label,track_id,help_func = QuestTrackerPane.GetGoalLabel(goal_type,v);
					node["internal_label"] = label;
					node["internal_track_id"] = track_id;
					node["internal_questid"] = questid;
					node["internal_help_func"] = help_func;
					node["internal_state"] = state;
					node["goal_type"] = goal_type;
					local item = {
						name = "item", attr = node,
					};
					if(bShowArrowPointer) then
						node["ShowArrowPointer"] = true;
						bShowArrowPointer = nil;
					end
					table.insert(parent,item);
					--检测寻路目标是否存在
					check(questid,track_id);
				end
			end
		end
	end
	for k,q in ipairs(q_list) do
		local questid = q.questid;
		local state = q.state;
		local template = templates[questid];
		local label = template.Title or "";
		local RecommendLevel = q.RecommendLevel;
		local QuestGroup1 = q.QuestGroup1;
		-- hasaccept and canfinished
		if(state == 0)then
			local folder = {
				name = "folder", QuestGroup1 = QuestGroup1, RecommendLevel = RecommendLevel, attr = {questid = questid,state = state,label = label,},
			};
			table.insert(tree_view_data_1,folder);
			local npc_item = GetNpcItem(questid,"EndNPC",state);
			if(npc_item)then
				table.insert(folder,npc_item);
			end
			self.has_accept_quest_map[questid] = questid;
		-- hasaccept and not canfinished
		elseif(state == 1)then
			local q_item = provider:GetQuest(questid);
			if(q_item)then
				local folder = {
					name = "folder", QuestGroup1 = QuestGroup1, RecommendLevel = RecommendLevel, attr = {questid = questid,state = state,label = label,},
				};
				table.insert(tree_view_data_1,folder);
				create_subfolder(folder,q_item.Cur_Goal,"Goal",questid,state);
				create_subfolder(folder,q_item.Cur_GoalItem,"GoalItem",questid,state);
				create_subfolder(folder,q_item.Cur_ClientGoalItem,"ClientGoalItem",questid,state);
				create_subfolder(folder,q_item.Cur_ClientExchangeItem,"ClientExchangeItem",questid,state);
				create_subfolder(folder,q_item.Cur_FlashGame,"FlashGame",questid,state);
				create_subfolder(folder,q_item.Cur_ClientDialogNPC,"ClientDialogNPC",questid,state);
				create_subfolder(folder,q_item.Cur_CustomGoal,"CustomGoal",questid,state);
			end
			self.has_accept_quest_map[questid] = questid;
		-- canaccept
		elseif(state == 2)then
			self.can_accept_cnt = self.can_accept_cnt + 1;
			--if(CommonClientService.IsKidsVersion())then
				--local folder = {
					--name = "folder", RecommendLevel = RecommendLevel, attr = {questid = questid,state = state,label = label,},
				--};
				--table.insert(tree_view_data_1,folder);
				--local npc_item = GetNpcItem(questid,"StartNPC",state);
				--if(npc_item)then
					--table.insert(folder,npc_item);
				--end
			--end
			--tab2
			local folder = {
				name = "folder", QuestGroup1 = QuestGroup1, RecommendLevel = RecommendLevel, attr = {questid = questid,state = state,label = label,},
			};
			if(CommonClientService.IsKidsVersion())then
				table.insert(tree_view_data_2,folder);
			else
				table.insert(tree_view_data_1,folder);
			end
			local npc_item = GetNpcItem(questid,"StartNPC",state);
			if(npc_item)then
				table.insert(folder,npc_item);
			end
		end
	end
	if(not find_questid and self.show_state == 1)then
		self.find_path_questid = nil;
	end
	if(not find_track_id and self.show_state == 1)then
		self.find_path_goalid = nil;
	end
		--if((#tree_view_data_1)==1 and #tree_view_data_2>=1) then
			---- always have at least two tasks at hand for teen version. 
			--tree_view_data_1[#tree_view_data_1+1] = commonlib.clone(tree_view_data_2[1]);
		--end
		--已经追踪的列表中是否含有主线任务呢，如果没有 找一个和战斗等级最接近的 可接 或者锁定
		if(not QuestTrackerPane.IncludeMainQuest(tree_view_data_1))then
			local q = QuestTrackerPane.FindNearestMainQuest();			
			if(q)then
				local questid = q.questid;
				local state = q.state;
				local template = templates[questid];
				local label = template.Title or "";
				local RecommendLevel = q.RecommendLevel;
				local QuestGroup1 = q.QuestGroup1;

				local folder = {
					name = "folder", QuestGroup1 = QuestGroup1, RecommendLevel = RecommendLevel, attr = {questid = questid,state = state,label = label,},
				};
				table.insert(tree_view_data_1,folder);
				local npc_item;
				ResetShowPointer_();

				if(state == 0)then
					npc_item = GetNpcItem(questid,"EndNPC",state);
					self.has_accept_quest_map[questid] = questid;
				elseif(state == 2 or state == 9)then
					npc_item = GetNpcItem(questid,"StartNPC",state);
				end
				if(npc_item)then
					table.insert(folder,npc_item);
				end
			end
		end
		table.sort(tree_view_data_1,function(a,b)
			local a_RecommendLevel = a.RecommendLevel or 0
			local b_RecommendLevel = b.RecommendLevel or 0
			local a_QuestGroup1 = a.QuestGroup1 or 0
			local b_QuestGroup1 = b.QuestGroup1 or 0

			--return a_QuestGroup1 < b_QuestGroup1 
					--or (a_QuestGroup1 == b_QuestGroup1 and a.attr.state < b.attr.state)
					--or (a_QuestGroup1 == b_QuestGroup1 and a.attr.state == b.attr.state and a_RecommendLevel > b_RecommendLevel)
			return a.attr.state < b.attr.state 
					or (a.attr.state == b.attr.state and a_QuestGroup1 < b_QuestGroup1)
					or (a.attr.state == b.attr.state and a_QuestGroup1 == b_QuestGroup1 and a_RecommendLevel > b_RecommendLevel)
		end)
	
	return tree_view_data_1,tree_view_data_2;
end
-------------------------------------------------------------------------------------------
--激活任务追踪
function QuestTrackerPane.Enable_Track(questid)
	local self = QuestTrackerPane;
	local provider = QuestClientLogics.provider;
	if(not questid or not provider)then return end
	provider:SaveQuestTrackState(questid,nil);

	self.NeedReload();
    self.ReloadPage();
end
--取消追踪
function QuestTrackerPane.Disable_Track(questid)
	local self = QuestTrackerPane;
	local provider = QuestClientLogics.provider;
	if(not questid or not provider)then return end
	local local_time = commonlib.timehelp.GetLocalTime();
	provider:SaveQuestTrackState(questid,local_time);
	self.NeedReload();
    self.ReloadPage();
end
function QuestTrackerPane.Has_Tracked(questid)
	local self = QuestTrackerPane;
	local provider = QuestClientLogics.provider;
	if(not questid or not provider)then return end
	local track_time = provider:LoadQuestTrackState(questid)
	if(not track_time or track_time == "")then
		return true;
	else
		return false;
	end
end
function QuestTrackerPane.Tracked_Clear()
	local self = QuestTrackerPane;
	local provider = QuestClientLogics.provider;
	if(not provider)then return end
	provider:ResetAllTrackState();
end
-------------------------------------------------------------------------------------------
---- toggle show/hide the page
--function QuestTrackerPane.Show(bShow)
	--if(not QuestArea.is_inited) then
		--return;
	--end
	--if((QuestTrackerPane.is_disabled and bShow)) then
		--bShow = false;
	--end
	--local self = QuestTrackerPane;
	--if(bShow)then
		--self.ShowPage();
		--self.is_shown = true;
		--QuestTrackerPane.EnableTimer(true);
	--else
		--self.ClosePage();
	--end
--end
--是否隐藏
function QuestTrackerPane.LoadState()
	local self = QuestTrackerPane;
	local key = string.format("QuestTrackerPane.LoadState_%d",System.User.nid or 0);
	local b = MyCompany.Aries.Player.LoadLocalData(key, true);
	self.is_expanded = b;
end
function QuestTrackerPane.SaveState()
	local self = QuestTrackerPane;
	local key = string.format("QuestTrackerPane.LoadState_%d",System.User.nid or 0);
	local b = self.is_expanded;
	MyCompany.Aries.Player.SaveLocalData(key,b);
end

-- @param is_expanded: nil to toggle.
function QuestTrackerPane.DoExpanded(is_expanded) 
	if(is_expanded == nil) then
		if(QuestTrackerPane.is_expanded)then
			QuestTrackerPane.is_expanded = false;
		else
			QuestTrackerPane.is_expanded = true;
		end
	else
		QuestTrackerPane.is_expanded = is_expanded;
	end
    QuestTrackerPane.SaveState();
	if(QuestTrackerPane.page) then
		QuestTrackerPane.page:Refresh(0);
	end
end


function QuestTrackerPane.IsShown()
	if(QuestTrackerPane.page and QuestTrackerPane.is_shown == true) then
		return true;
	else
		return false;
	end
end

-- tricky: this is not same as not  IsShown(). if the page is not created, it is not hidden. 
function QuestTrackerPane.IsHidden()
	if(QuestTrackerPane.page and not QuestTrackerPane.is_shown ) then
		return true;
	end
end

-- toggle show/hide the page
function QuestTrackerPane.Show(bShow)
	if(not QuestArea.is_inited or (QuestTrackerPane.is_disabled and bShow)) then
		return;
	end
	local self = QuestTrackerPane;
	--if(bShow)then
		--self.ShowPage();
		--self.is_shown = true;
		--QuestTrackerPane.EnableTimer(true);
	--else
		--self.ClosePage();
	--end

	local _wnd = MyCompany.Aries.app._app:FindWindow("QuestTrackerPane.ShowPage");
	if(_wnd) then
		_wnd:ToggleShowHide(bShow, true);
	elseif(bShow) then
		self.ShowPage();
		QuestTrackerPane.EnableTimer(true);
	end
	self.is_shown = bShow;
end

function QuestTrackerPane.FadeIn()
	if(QuestTrackerPane.is_fade_out and QuestTrackerPane.page) then
		QuestTrackerPane.is_fade_out = false;
		local _parent = QuestTrackerPane.page:FindControl("canvas");
		UIAnimManager.ChangeAlpha("Aries.QuestTrackerPane", _parent, 255, 512)
		local _parent = QuestTrackerPane.page:FindControl("canvas_content");
		UIAnimManager.ChangeAlpha("Aries.QuestTrackerPane.content", _parent, 255, 512, nil, false)

		local k;
		for k = 1,5 do
			local name = string.format("questBtn%d",k);
			local anim_name = string.format("Aries.QuestTrackerPane.questBtn%d",k);
			local _parent = QuestTrackerPane.page:FindControl(name);
			UIAnimManager.ChangeAlpha(anim_name, _parent, 255, 512, nil, false);
		end
	end
end

function QuestTrackerPane.FadeOut()
	if(not QuestTrackerPane.is_fade_out and QuestTrackerPane.page) then
		QuestTrackerPane.is_fade_out = true;
		local _parent = QuestTrackerPane.page:FindControl("canvas");
		local target_content_alpha = if_else(System.options.version == "teen", 0, 0);
		UIAnimManager.ChangeAlpha("Aries.QuestTrackerPane", _parent, 160, 64, 2000)
		local _parent = QuestTrackerPane.page:FindControl("canvas_content");
		UIAnimManager.ChangeAlpha("Aries.QuestTrackerPane.content", _parent, target_content_alpha, 64, 2000, false)

		local k;
		for k = 1,5 do
			local name = string.format("questBtn%d",k);
			local anim_name = string.format("Aries.QuestTrackerPane.questBtn%d",k);
			local _parent = QuestTrackerPane.page:FindControl(name);
			UIAnimManager.ChangeAlpha(anim_name, _parent, target_content_alpha, 64, 2000, false);
		end
	end
end

local min_tracker_height = 20;

function QuestTrackerPane.HasFocus()
	if(QuestTrackerPane.IsShown()) then
		if(QuestTrackerPane.is_expanded) then
			local _parent = QuestTrackerPane.page:FindControl("canvas_content");
			if(_parent and _parent:IsValid()) then
				local x, y, width, height = _parent:GetAbsPosition();
				local treeview_ctl = QuestTrackerPane.page:FindControl("view_questtrack");
				if(treeview_ctl) then
					local logical_height = treeview_ctl:GetLogicalHeight() + 10;
					local max_height = treeview_ctl.height;
					local expected_height = math.min(logical_height, max_height)
					if(height ~= expected_height) then
						height = expected_height;
						_parent.height = height;
					end
				end
				local mouseX, mouseY = ParaUI.GetMousePosition();
				if(x<=mouseX and mouseX <= (x+width) and (y-22)<=mouseY and mouseY<(y+height)) then
					return true;
				end
			end
		else
			local _parent = QuestTrackerPane.page:FindControl("canvas");
			if(_parent and _parent:IsValid()) then
				local x, y, width, height = _parent:GetAbsPosition();
				local mouseX, mouseY = ParaUI.GetMousePosition();
				if(x<=mouseX and mouseX <= (x+width) and y<=mouseY and mouseY<(y+height)) then
					return true;
				end
			end
		end
	end
end

-- timer is enabled whenever chat edit window is shown
function QuestTrackerPane.EnableTimer(bEnabled)
	--if(System.options.version == "teen") then
		if(not bg_timer) then
			bg_timer = commonlib.Timer:new({callbackFunc = QuestTrackerPane.OnTimer})
		end
		if(bEnabled) then
			bg_timer:Change(200, 200);
		else
			bg_timer:Change(200, nil);
		end
	--end
end

-- this is a slow timer to highlight the chat area 
-- if the mouse cursor is within the chat area, we will highlight the background. 
-- otherwise we will not show the display background.
function QuestTrackerPane.OnTimer(timer)
	if(QuestTrackerPane.HasFocus()) then
		QuestTrackerPane.FadeIn();
	else
		QuestTrackerPane.FadeOut();
	end
end
function QuestTrackerPane.ClosePage()
	local self = QuestTrackerPane;
	if(self.page)then
		self.page:CloseWindow();
		self.is_shown = false;
		QuestTrackerPane.EnableTimer(false);
		QuestTrackerPane.is_fade_out = nil;
	end
end

--  whether the current quest's jump position is within a given radius of a given position. 
function QuestTrackerPane.IsNearPosition(x, y, z, radius)
	local target = QuestPathfinderNavUI.GetTargetQuest();
	if(target) then
		local jump_pos = target.jump_pos;--跳转坐标
		if(not jump_pos and target.x) then
			jump_pos = {target.x, target.y, target.z};
		end
		if(jump_pos and type(jump_pos) == "table") then
			local dx, dy = jump_pos[1]-x, jump_pos[3]-z;
			local radius = radius or target.radius or 20;
			if( (dx*dx+dy*dy) < radius*radius ) then	
				return true;
			end
		end
	end
end

function QuestTrackerPane.FindPath_IsActive(questid,goalid)
	local self = QuestTrackerPane;
	local target = QuestPathfinderNavUI.GetTargetQuest();
	if(self.find_path_questid == questid and self.find_path_goalid == goalid)then
		-- added by LiXizhi 2011.10: in case the path finder is tracking other target outside the quest system. 
		local target = QuestPathfinderNavUI.GetTargetQuest();
		if(target and target.find_path_questid == questid and target.find_path_goalid == goalid) then
			return true;
		end
	end
end
-- @param bEnable: true to enable. when true, goalid must be specified.
-- @param goalid; which goal id to track. 
function QuestTrackerPane.Enable_PendingMobTrack(bEnable, goalid)
	--青年版有效
	if(not CommonClientService.IsTeenVersion())then
		return
	end	
	local self = QuestTrackerPane;
	if(not pending_mob_track_timer)then
		pending_mob_track_timer = commonlib.Timer:new({callbackFunc = function(timer)
			local questid = self.find_path_questid;
			local goalid = self.find_path_goalid;
			if(not pending_mob_track_timer)then
				return
			end
			try_find_num = try_find_num + 1;
			if(try_find_num > 3)then
				--  at most try 3 times, i.e. 15 seconds in the world. 
				timer:Change(nil);
				return;
			end
			if(questid and goalid and goalid == self.last_goalid)then
				local n_x,n_y,n_z = QuestHelp.GetClosetArenaPosByMobID(goalid);
				if(n_x) then
					QuestTrackerPane.FindPath_Active(questid,goalid)
				end
			else
				timer:Change(nil);
			end
		end})
	end
	if(bEnable and goalid) then
		if(self.last_goalid == goalid) then
			return;
		else
			self.last_goalid = goalid;
			try_find_num = 0;
			-- only execute every 5 seconds. 
			pending_mob_track_timer:Change(5000, 5000);
		end
	else
		pending_mob_track_timer:Change(nil);
	end
end

--是否已经有追踪某个任务
function QuestTrackerPane.FindPath_HasTrackedQuest(questid)
	local self = QuestTrackerPane;
	if(self.find_path_questid and questid and self.find_path_questid == questid)then
		return true;
	end	
end
function QuestTrackerPane.FindPath_ActiveNextGoal()
	local self = QuestTrackerPane;
	if(self.find_path_questid)then
		local goalid = QuestHelp.GetFirstGoalID(self.find_path_questid);
		self.FindPath_Active(self.find_path_questid,goalid);
	end
end
--激活第一个目标
function QuestTrackerPane.FindPath_ActiveTopGoal()
	local self = QuestTrackerPane;
	--选择第一条记录
	if(self.tree_view_data and self.tree_view_data[1] and self.tree_view_data[1][1])then
		self.find_top_goal_index = 1;
		QuestTrackerPane.FindPath_TopGoal_ByIndex();
	end
end
--递归寻找每个任务的第一个目标，直到找到有坐标的目标
function QuestTrackerPane.FindPath_TopGoal_ByIndex()
	local self = QuestTrackerPane;
	local index = self.find_top_goal_index;
	if(self.tree_view_data and self.tree_view_data[index] and self.tree_view_data[index][1])then
		local item = self.tree_view_data[index][1];
		local questid = item.attr.internal_questid;
		local goalid = item.attr.internal_track_id;
		if(goalid)then
			local item_info = QuestHelp.GetItemInfoByID(goalid);
			if(item_info and item_info.x and item_info.y and item_info.z)then
				self.FindPath_Active(questid,goalid)
				return true;
			else
				self.find_top_goal_index = self.find_top_goal_index + 1;
				QuestTrackerPane.FindPath_TopGoal_ByIndex();
			end
		end
	end
end
function QuestTrackerPane.FindPath_Clear()
	local self = QuestTrackerPane;
	self.find_path_questid = nil;
	self.find_path_goalid = nil;
	QuestPathfinderNavUI.SetTargetQuest(false);
end
function QuestTrackerPane.HookHandler(nCode, appName, msg, value)
	local self = NPCShopPage;
	if(msg.action_type == "post_pe_slot_PageRefresh")then
		QuestTrackerPane.TryReload_ByDynamicItem();
	end
	return nCode;
end
--如果已经接受的任务中 任务目标包含动态属性 重新加载数据并刷新
function QuestTrackerPane.TryReload_ByDynamicItem()
	local self = QuestTrackerPane;
	local provider = QuestClientLogics.provider;
	if(not provider)then
		return
	end
	local templates = QuestHelp.GetTemplates();
	local k,questid;
	for k,questid in pairs(self.has_accept_quest_map) do
		local template = templates[questid];	
		if(template and template.CustomGoal)then
			local k,v;
			for k,v in ipairs(template.CustomGoal) do
				if(provider:IsDynamicItemGsid(v.id))then
					provider:NotifyChanged();
					QuestTrackerPane.NeedReload();
					QuestTrackerPane.ReloadPage();	
					QuestClientLogics.UpdateUI();			
					return
				end
			end
		end
	end
	if(CommonClientService.IsKidsVersion())then
		local k,questid;
		for k,questid in pairs(self.has_accept_quest_map) do
			local template = templates[questid];	
			if(template and template.ClientGoalItem)then
				if(#template.ClientGoalItem > 0)then
					QuestClientLogics.DoSync_Client_ClientGoalItem();
					provider:NotifyChanged();
					QuestTrackerPane.NeedReload();
					QuestTrackerPane.ReloadPage();				
					QuestClientLogics.UpdateUI();			
					return
				end
			end
		end
	end
end

--重新激活一次追踪的目标
function QuestTrackerPane.FindPath_ReActive()
	local self = QuestTrackerPane;
	if(self.find_path_questid and self.find_path_goalid)then
		self.FindPath_Active(self.find_path_questid,self.find_path_goalid);
	end
end
--任务追踪
--return item_info
function QuestTrackerPane.FindPath_Active(questid,goalid)
	local self = QuestTrackerPane;
	self.find_path_questid = questid;
	self.find_path_goalid = goalid;
	if(questid == nil and goalid == nil)then
		QuestPathfinderNavUI.SetTargetQuest(false)
	end
	QuestHelp.ActiveAreaTip(false);
	-- this ensures the pending.
	self.Enable_PendingMobTrack(false);

	if(WorldManager:IsInInstanceWorld())then
		QuestPathfinderNavUI.SetTargetQuest(false)
		return
	end
	if(questid and goalid)then
		local current_world = WorldManager:GetCurrentWorld();
		-- find the nearest item_info
		local item_info = QuestHelp.GetItemInfoByID(goalid,true);
		if(item_info)then
			local radius;
			local facing = 0;
			local is_npc = item_info.is_npc;
			local worldname = item_info.worldname;
			if(is_npc)then
				radius = 1;
				facing = item_info.facing;
			else
				radius = 5;
			end
			local camPos;
			if(item_info.camera_x and item_info.camera_y and item_info.camera_z)then
				camPos = {item_info.camera_x,item_info.camera_y,item_info.camera_z};
			end
			local state = item_info.state;
			--追踪坐标
			local x,y,z = item_info.x,item_info.y,item_info.z;
			--跳转坐标
			local jump_pos = { x,y,z };
			local is_arena;
			if(state == "mob" and current_world.name == worldname)then
				local n_x,n_y,n_z = QuestHelp.GetClosetArenaPosByMobID(goalid, jump_pos);
				--如果有最近法阵坐标
				if(n_x and n_y and n_z)then
					x = n_x;
					y = n_y;
					z = n_z;
					self.Enable_PendingMobTrack(false)

					NPL.load("(gl)script/ide/math/vector.lua");
					local vector3d = commonlib.gettable("mathlib.vector3d");
					local v = vector3d:new(x-jump_pos[1],0,z-jump_pos[3])

					local angle = vector3d.unit_x:angleAbsolute(v)
					facing = angle;
					jump_pos[4] = facing;
					if (Player.GetLevel()<100) then
						-- tricky: when player level is smaller than 100, we will teleport to mob position which is very close to the mob so that the auto tip will appear.
						local vOrigin = vector3d:new(x,0,z);
						v:normalize();
						local radius = BasicArena.GetEnterCombatRadius();
						v:MulByFloat(radius + 3);
						local vJumpPos = vOrigin - v;
						jump_pos[1] = vJumpPos[1]
						jump_pos[2] = y;
						jump_pos[3] = vJumpPos[3];
					end
					--if(System.options.version == "kids") then
						QuestHelp.ActiveAreaTip(true,x,y,z);
					--end
					camPos = { 15, 0.27, facing};
					item_info.camera_x, item_info.camera_y, item_info.camera_z = unpack(camPos);
					is_arena = true;
				else
					self.Enable_PendingMobTrack(true, goalid)
				end
			else
				self.Enable_PendingMobTrack(false)
			end
			local params = {
				x = x,
				y = y,
				z = z,
				jump_pos = jump_pos,--跳转坐标
				camPos = camPos,--跳转后摄影机坐标
				worldInfo = item_info.worldInfo,
				radius = radius,
				targetName = item_info.label,
				find_path_questid = questid,
				find_path_goalid = goalid,
				is_npc = is_npc,
				facing = facing,
				is_arena = is_arena,
				is_area_tip = (state == "mob"),  -- this will show up area tip
			}
			-- Note: here we will use the last jump_pos
			--item_info.x = jump_pos[1];
			--item_info.y = jump_pos[2];
			--item_info.z = jump_pos[3];
			local cur_world_info = WorldManager:GetCurrentWorld()
			if(params.worldInfo and params.worldInfo.name ~= cur_world_info.name)then
				local npcid = WorldManager:GetWorldCaptainID(cur_world_info.name);
				if(npcid)then
					local template_name = NPC.GetHeadOnUITemplateName(npcid);
					if(template_name)then
						if(string.find(template_name,"can_accept") or string.find(template_name,"can_finished") or string.find(template_name,"can_dialoged"))then
							--do nothing
						else
							NPC.ChangeHeadonMarkByID(npcid,nil,"needTranspot");
						end
					end
				end
			end
			QuestPathfinderNavUI.SetTargetQuest(params)
			QuestPathfinderNavUI.RefreshPage(true);
			if(self.page)then
				self.page:Refresh(0);
			end
			return item_info;
		end
	end
end

-- do immediate jump by quest_id and goal_id
function QuestTrackerPane.DoJump(questid,goalid,goaltype)
	if(not questid or not goalid)then
		return
	end
	if(WorldManager:IsInInstanceWorld() and not WorldManager:CanTeleport_CurrentWorld())then
        _guihelper.MessageBox("你目前在副本当中，不能跳转！");
        return
    end
    local item_info;
    --同步追踪目标
	local is_current_quest = QuestTrackerPane.FindPath_IsActive(questid,goalid)
    if(is_current_quest)then
        item_info = QuestTrackerPane.FindPath_Active(questid,goalid);
    else
        item_info = QuestHelp.GetItemInfoByID(goalid,true);
    end
	local current_world = WorldManager:GetCurrentWorld();

    if(item_info)then
	    local worldname = item_info.worldname;
        local Position = {item_info.x,item_info.y,item_info.z};
		local camPos = { item_info.camera_x,item_info.camera_y,item_info.camera_z};
        local npc_id;
        if(goaltype == "StartNPC" or goaltype == "EndNPC" or goaltype == "ClientDialogNPC")then
            npc_id = item_info.id;
            local facing = item_info.facing or 0;
            facing = facing + 1.57
            local radius = 5;
            local  x,y,z = item_info.x,item_info.y,item_info.z;
            x = x + radius * math.sin(facing);
			z = z + radius * math.cos(facing);
            Position = {x,y,z, facing+1.57};
			camPos = { 15, 0.27, facing + 1.57 - 1};
        elseif(not is_current_quest and item_info.state == "mob" and current_world.name == worldname)then
			-- we will only recompute camera position if it is not current quest. 
			local jump_pos = Position;
		
			local n_x,n_y,n_z = QuestHelp.GetClosetArenaPosByMobID(goalid, jump_pos);
			-- search the closest arena around the jump position. 
			if(n_x and n_y and n_z)then
				x = n_x;
				y = n_y;
				z = n_z;
				
				NPL.load("(gl)script/ide/math/vector.lua");
				local vector3d = commonlib.gettable("mathlib.vector3d");
				local v = vector3d:new(x-jump_pos[1],0,z-jump_pos[3])
				local angle = vector3d.unit_x:angleAbsolute(v)
				facing = angle;
				jump_pos[4] = facing;
				if (Player.GetLevel()<100) then
					-- tricky: when player level is smaller than 100, we will teleport to mob position which is very close to the mob so that the auto tip will appear.
					local vOrigin = vector3d:new(x,0,z);
					v:normalize();
					local radius = BasicArena.GetEnterCombatRadius();
					v:MulByFloat(radius + 3);
					local vJumpPos = vOrigin - v;
					jump_pos[1] = vJumpPos[1];
					jump_pos[2] = y;
					jump_pos[3] = vJumpPos[3];
				end
				--if(System.options.version == "kids") then
					QuestHelp.ActiveAreaTip(true,x,y,z);
				--end
				camPos = { 15, 0.27, facing};
			end
		end

        WorldManager:GotoWorldPosition(worldname,Position,camPos,nil,function()
            local TargetArea = commonlib.gettable("MyCompany.Aries.Desktop.TargetArea");
            if(npc_id)then
			    TargetArea.TalkToNPC(npc_id, nil, false);
            end
        end);
    end
end
--已结任务里面包含副本难度的 副本列表
--[[
	return local list = {
	{ questid = questid, worldname_location = worldname_location, is_tracking = is_tracking,},
	{ questid = questid, worldname_location = worldname_location, is_tracking = is_tracking,},
}
--]]
function QuestTrackerPane.GetModeWorldList()
	if(QuestTrackerPane.q_list)then
		local __,map = QuestHelp.GetGoalList();
		local templates = QuestHelp.GetTemplates();
		local k,q;
		local result = {};
		for k,q in ipairs(QuestTrackerPane.q_list) do
			local questid = q.questid;
			local state = q.state;
			local template = templates[questid];
			-- hasaccept and not canfinished
			if(state == 1)then
				local Goal = template.Goal or {};
				local mode_Goal = Goal.mode or -1;-- 0 1 2
				local GoalItem = template.GoalItem or {};
				local mode_GoalItem = Goal.GoalItem or -1;-- 0 1 2

				if(mode_Goal > -1)then
					local worldname_location;
					local k,v;
					for k,v in ipairs(Goal) do
						local id = v.id;
						local item = map[id]--id
						if(item)then
							worldname_location = item.worldname_location;
							if(worldname_location)then
								break;
							end
						end
					end
					local is_tracking;
					if(QuestTrackerPane.find_path_questid and questid == QuestTrackerPane.find_path_questid)then
						is_tracking = true;
					else
						is_tracking = false;
					end
					if(worldname_location)then
						table.insert(result,{
							questid = questid,	
							worldname_location = worldname_location,
							is_tracking = is_tracking,
							mode = mode_Goal+1,
						});
					end
				elseif(mode_GoalItem > -1)then
					local worldname_location;
					local k,v;
					for k,v in ipairs(GoalItem) do
						local id = v.producer_id;--producer_id
						local item = map[id]
						if(item)then
							worldname_location = item.worldname_location;
							if(worldname_location)then
								break;
							end
						end
					end
					local is_tracking;
					if(QuestTrackerPane.find_path_questid and questid == QuestTrackerPane.find_path_questid)then
						is_tracking = true;
					else
						is_tracking = false;
					end
					if(worldname_location)then
						table.insert(result,{
							questid = questid,	
							worldname_location = worldname_location,
							is_tracking = is_tracking,
							mode = mode_GoalItem+1,
						});
					end
				end
			end
		end
		return result;
	end
end

function QuestTrackerPane.StartAutoNavigation(questid,goalid,goaltype)
	if(System.options.version == "teen") then
		QuestPathfinderNavUI.EnterAutoNavigationMode(); 
	end
end
function QuestTrackerPane.SaveTrackState(v)
	MyCompany.Aries.Player.SaveLocalData("QuestTrackerPane.TrackState", v)
end
function QuestTrackerPane.LoadTrackState()
	return MyCompany.Aries.Player.LoadLocalData("QuestTrackerPane.TrackState", 0);
end
function QuestTrackerPane.GetQuestCnt()
	return QuestTrackerPane.can_accept_cnt or 0;
end
function QuestTrackerPane.UpdateQuestCntInDock(cnt)
	local btntips = ParaUI.GetUIObject("dock_quest_cnt_tips");
	if(btntips and btntips:IsValid())then
		if(cnt and cnt > 0)then
			btntips.visible = true;
			btntips.text = tostring(cnt);
		else
			btntips.visible = false;
		end
	end
end