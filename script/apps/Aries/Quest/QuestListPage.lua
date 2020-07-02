--[[
Title: Quest List Page
Author(s): LiXizhi for ZRF
Date: 2010/8/21
Desc:  client side UI class for rendering quest lists of the current player. 
It may register hooks and call functions on QuestClient class to obtain all the available quest list. 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Quest/QuestListPage.lua");
local QuestListPage = commonlib.gettable("MyCompany.Aries.Quest.QuestListPage");
QuestListPage.ShowPage()

NPL.load("(gl)script/apps/Aries/Quest/QuestListPage.lua");
local QuestListPage = commonlib.gettable("MyCompany.Aries.Quest.QuestListPage");
_guihelper.MessageBox(QuestListPage.main_menu_expanded);

-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
local QuestListPage = commonlib.gettable("MyCompany.Aries.Quest.QuestListPage");
local LOG = LOG;

QuestListPage.list = nil;
--主线 or 支线 分类
QuestListPage.quest_types_index = nil;
--选的哪条记录
QuestListPage.selected_index = nil;
QuestListPage.provider = nil;
----现有任务菜单状态
--QuestListPage.main_menu_expanded = {true,true,};
----完成的任务菜单状态
--QuestListPage.branch_menu_expanded = {true,true,};
----放弃的任务菜单状态
--QuestListPage.drop_menu_expanded = {true,true,};



function QuestListPage.ResetMenu(b)
	local self = QuestListPage;
	self.menu_state = {
		{b,b,b,b,},
		{b,b,b,b,},
		{b,b,b,b,},
	};
end
QuestListPage.ResetMenu(true);
function QuestListPage.OnInit()
	local self = QuestListPage;
	self.page = document:GetPageCtrl();
end
function QuestListPage.GetSource()
	local self = QuestListPage;
	local index = self.quest_types_index;
	if(self.root_node)then
		return self.root_node[index];
	end
end
function QuestListPage.ClosePage()
	local self = QuestListPage;
	if(self.page)then
		self.page:CloseWindow();
		local frame = self.page:GetNode("detailInfo");
		if(frame and frame.pageCtrl)then
			frame.pageCtrl:CloseWindow();
		end
		self.Clear();
	end	
end
function QuestListPage.Clear()
	local self = QuestListPage;
	--self.quest_types_index = nil;
	self.page = nil;
	self.last_selected_questid = nil;
end
function QuestListPage.ListToTreeNode(list,search_quest_id)
	local self = QuestListPage;
	local quest_types,quest_types_map = QuestHelp.GetQuestTypesList();
	if(not list or not quest_types)then return end
	local quest_types_index = 1;
	local selected_folder_index = 1;
	local selected_index = 1;
	local root = {
		name = "folder",
		attr = { label = "root" };
	};
	local k,v;
	for k,v in ipairs(quest_types) do
		local id = v.id;
		id = tonumber(id);
		local label = v.label;
		local kk,vv;
		--现有任务 完成的任务 放弃的任务
		local level_1_node = {
			name = "folder",
			id = id,
			attr = {label = label, show_index = k, };
		}
		for kk,vv in ipairs(v) do
			--现有任务
				--哈奇小镇
				--火鸟岛
				--...
			--or
			--完成的任务
				--哈奇小镇
				--火鸟岛
				--...
			local id_2 = vv.id;
			local label_2 = vv.label;
			local level_2_node = {
				name = "folder",
				attr = {label = label_2, show_index = kk, };
			}
			local kkk,vvv;
			local t_index = 0;
			for kkk,vvv in ipairs(list) do
				local QuestGroup1 = vvv.QuestGroup1;
				local QuestGroup2 = vvv.QuestGroup2;

				local label_3 = vvv.label;
				local state = vvv.state;
				local questid = vvv.questid;
				local canInsert;
				--现有任务
				if(id == 0  and QuestGroup2 == id_2)then
					if(state == 0 or state == 1 or state == 2 or state == 9)then
						canInsert = true;
					end
				--完成的任务
				elseif(id == 1 and QuestGroup2 == id_2)then
					if(state == 10)then
						canInsert = true;
					end
				--放弃的任务
				elseif(id == 2  and QuestGroup2 == id_2)then
					if(state == 11)then
						canInsert = true;
					end
				end
				--过滤日常任务
				if(QuestHelp.HasTimeStamp(questid))then
					canInsert = false;
				end
				if(canInsert)then
					t_index = t_index + 1;
					vvv.show_index = t_index;
					vvv.parent_show_index = kk;
					local level_3_node = {
						name = "item",
						attr = vvv,
					}
					table.insert(level_2_node,level_3_node);	
					if(search_quest_id == questid)then
						quest_types_index = k;
						selected_folder_index = kk;
						selected_index = t_index;
					end	
				end
			end
			table.insert(level_1_node,level_2_node);		
		end
		table.insert(root,level_1_node);		
	end
	return root,quest_types_index,selected_folder_index,selected_index;
end
function QuestListPage.ShowPage(id)
	local self = QuestListPage;
	local provider = QuestClientLogics.GetProvider();
	if(not provider)then
		LOG.std("","warning","QuestListPage.ShowPage","provider is nil");
		return;
	end
	if(not provider.local_is_init)then
		LOG.std("","warning","QuestListPage.ShowPage","client provider is not init");
		return;
	end
	QuestClientLogics.DoSync_Client_ClientGoalItem();
	self.quest_types_index = self.quest_types_index or 1;
	local list = provider:FindQuests();
	local root_node,quest_types_index,selected_folder_index,selected_index = self.ListToTreeNode(list,id);
	self.root_node  = root_node;
	if(id)then
		self.quest_types_index,self.selected_folder_index,self.selected_index  = quest_types_index,selected_folder_index,selected_index ;
		self.ResetMenu(false);
		 local menu_expanded = self.menu_state[self.quest_types_index];
		 menu_expanded[self.selected_folder_index] = true;
	end
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/Quest/QuestListPage.html", 
			name = "QuestListPage.ShowPage", 
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
	if(self.quest_types_index and self.selected_folder_index and self.selected_index)then
		local root_node =  self.root_node[self.quest_types_index];
		if(root_node)then
			local folder_node = root_node[self.selected_folder_index];
			if(folder_node)then
				local node = folder_node[self.selected_index];
				if(node and node.attr)then
					local questid = node.attr.questid;
					self.ShowFrame(questid);
				end
			end
		end
	else
		self.SelectedFirstNode();
	end
end

function QuestListPage.SelectedFirstNode()
	local self = QuestListPage;
	if(self.root_node)then
		local first_node = self.root_node[self.quest_types_index or 1];
		if(first_node and first_node[1] and first_node[1][1] and first_node[1][1].attr)then
			self.ShowFrame(first_node[1][1].attr.questid);

			self.selected_folder_index = 1;
			self.selected_index = 1;
		end
	end
end
function QuestListPage.ShowFrame(id)
	local self = QuestListPage;
	id = tonumber(id);
	if(not id or not self.page)then return end
	local url = string.format("script/apps/Aries/Quest/QuestDetailFramePage.html?id=%d",id);
	local frame = self.page:GetNode("detailInfo");
	if(frame and frame.pageCtrl)then
		frame:SetAttribute("src", url);
	end
	self.last_selected_questid = id;
	self.page:Refresh(0);
	
end
function QuestListPage.DoClick(id,mcmlNode)
	local self = QuestListPage;
	self.ShowFrame(id);
	if(mcmlNode)then
		local parent_show_index = mcmlNode:GetAttribute("param1",1);
		local show_index = mcmlNode:GetAttribute("param2",1);
		local questid = mcmlNode:GetAttribute("param3","");

		self.selected_folder_index = parent_show_index;
		self.selected_index = show_index;
		--if(name)then
			--local bg = "Texture/aries/quest/questlist/fontbg1_32bits.png;0 0 158 40";
			--mcmlNode:SetUIBackground(name,bg);
		--end
	end
end