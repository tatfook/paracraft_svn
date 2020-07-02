--[[
Title: 
Author(s): leio
Date: 2012/3/22
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Quest/QuestWeeklyPage.lua");
local QuestWeeklyPage = commonlib.gettable("MyCompany.Aries.Quest.QuestWeeklyPage");
QuestWeeklyPage.ShowPage()
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
local QuestWeeklyPage = commonlib.gettable("MyCompany.Aries.Quest.QuestWeeklyPage");
local LOG = LOG;
QuestWeeklyPage.selected_id = nil;
function QuestWeeklyPage.OnInit()
	local self = QuestWeeklyPage;
	self.page = document:GetPageCtrl();
end
function QuestWeeklyPage.GetQuestID()
	local self = QuestWeeklyPage;
	return self.selected_id;
end
function QuestWeeklyPage.HoldQuestID(id)
	local self = QuestWeeklyPage;
	self.selected_id = id;
end
function QuestWeeklyPage.ShowPage(questid)
	local self = QuestWeeklyPage;
	local provider = QuestClientLogics.GetProvider();
	if(not provider)then
		LOG.std("","warning","QuestWeeklyPage.ShowPage","provider is nil");
		return;
	end
	if(not provider.local_is_init)then
		LOG.std("","warning","QuestWeeklyPage.ShowPage","client provider is not init");
		return;
	end
	local all_list = provider:FindQuests();
	self.menu_datasource_map = self.CreateWorldsFolder(all_list);

	local selected_questid = questid or self.selected_id;
	local datasource = self.menu_datasource_map;
	local is_empty = true;
	if(datasource)then
		local find_id = false;
		local firest_folder;
		local firest_item;
		local folder;
		for folder in commonlib.XPath.eachNode(datasource, "//folder") do
			if(not firest_folder)then
				firest_folder = folder;
			end
			local item;
			for item in commonlib.XPath.eachNode(folder, "//item") do
				if(not firest_item)then
					firest_item = item;
				end
				local questid = item.attr.questid;
				if(questid and selected_questid and questid == selected_questid)then
					find_id = true;
					folder.attr.expanded = true;
					item.attr.checked = true;
					self.selected_id = selected_questid;
				end
				is_empty = false;
			end
		end
		if(not find_id)then
			if(firest_folder and firest_item)then
				firest_folder.attr.expanded = true;
				firest_item.attr.checked = true;
				self.HoldQuestID(firest_item.attr.questid);
			end
		end
	end
	if(self.selected_id and provider:HasFinished(self.selected_id))then
		self.selected_id = nil;
	end
	if(is_empty)then
		_guihelper.MessageBox("你今天的日常任务已经全部完成了，请明天再来吧！");
		return;
	end
	QuestWeeklyPage.SetExtraRewardList();
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/Quest/QuestWeeklyPage.html", 
			name = "QuestWeeklyPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			bToggleShowHide = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			isTopLevel = true,
			allowDrag = false,
			enable_esc_key = true,
			directPosition = true,
				align = "_ct",
				x = -931/2,
				y = -508/2,
				width = 931,
				height = 508,
		});
end
function QuestWeeklyPage.CreateWorldsFolder(all_list)
	local self = QuestWeeklyPage;
	if(not all_list)then
		return;
	end
	local menus = {};
	--每日任务
	local folder = self.CreateFolder(all_list,0)
	if(folder)then
		table.insert(menus,folder);
	end
	--周末任务
	folder = self.CreateFolder(all_list,1)
	if(folder)then
		table.insert(menus,folder);
	end
	return menus;
end
function QuestWeeklyPage.CreateFolder(all_list,weekly_type)
	local self = QuestWeeklyPage;
	if(not all_list or not weekly_type)then
		return;
	end
	--item = { checked = nil, is_track = nil, questid = id, state = state, attr_level = attr_level, label = label, QuestGroup1 = QuestGroup1, QuestGroup2 = QuestGroup2, };
	local folder = { name = "folder", attr = {label = "", } };
	local label;
	if(weekly_type == 0)then
		label = "每日任务";
	elseif(weekly_type == 1)then
		label = "每周任务";
	end
	folder.attr.label = label;
	local k,v;
	for k,v in ipairs(all_list) do
		local TimeStamp = v.TimeStamp;
		local state = v.state;
		if(TimeStamp == weekly_type)then
			local item = {
				name = "item",
				attr = v;
			}
			--"accepted_quest"
			if(state == 0 or state == 1)then
				if(state == 1)then
					v.state_str = "进行中";
				end
				if(state == 0)then
					v.state_str = "可交付";
				end
				table.insert(folder,item);
			end
			-- "can_accept_quest"
			if(state == 2)then
				v.name = "item";
				v.state_str = "可接取";
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
function QuestWeeklyPage.GetExtraReword(id)
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
					if(is_right_school)then
						local node = {
							gsid = gsid,
							num = num,
							checked = true,
						}
						table.insert(reward_list,node);
					end
					local node = {
						gsid = gsid,
						num = num,
						checked = is_right_school,
					}
					table.insert(internal_reward_list,node);
				else
					local node = {
						gsid = gsid,
						num = num,
						checked = allChecked,
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
            return reward_list,req_num,need_select,internal_reward_list;
        end
    end
end
--更新奖励数据源
function QuestWeeklyPage.SetExtraRewardList()
	local self = QuestWeeklyPage;
	self.extra_reward_list = nil;
	local id = QuestWeeklyPage.GetQuestID()
	local extra_reward_list,req_num = self.GetExtraReword(id);
	self.extra_reward_list = extra_reward_list;
	if(self.page)then
		self.page:CallMethod("extra_reward_view", "SetDataSource", extra_reward_list or {});
		self.page:CallMethod("extra_reward_view", "DataBind"); 
	end
end