--[[
Title: 
Author(s): Leio
Date: 2010/8/31
Desc: 
use the lib:

action
	"showpage": 显示就的npc dialog
	"gotogroup": 跳转到新任务的某一个dialog
	"gotonext": 任务对话的下一页
	"doaccept": 接受任务
	"dofinished": 完成任务
	"docancel": 关闭页面
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Quest/QuestDialogPage.lua");
local QuestDialogPage = commonlib.gettable("MyCompany.Aries.Quest.QuestDialogPage");
QuestDialogPage.IsDialogShown()

local npcid = 30411;
QuestDialogPage.BeforeShowPage(npcid, instance, quest_template);
QuestDialogPage.ShowPage(npcid, instance, quest_template);


NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
local provider = QuestClientLogics.GetProvider()
provider:FindClientDialog(npcid);

NPL.load("(gl)script/apps/Aries/DefaultTheme.teen.lua");
MyCompany.Aries.Theme.Default:Load();
QuestHelp.is_kids_version = false;

NPL.load("(gl)script/apps/Aries/Quest/QuestDialogPage.lua");
local QuestDialogPage = commonlib.gettable("MyCompany.Aries.Quest.QuestDialogPage");
QuestDialogPage.BeforeShowPage(31005);
QuestDialogPage.ShowPage();
QuestDialogPage.ShowFirstAction();
commonlib.echo(QuestDialogPage.cur_source_list);
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/apps/Aries/Quest/QuestHook.lua");
local QuestHook = commonlib.gettable("MyCompany.Aries.Quest.QuestHook");
NPL.load("(gl)script/apps/Aries/Quest/QuestDetailPane.lua");
local QuestDetailPane = commonlib.gettable("MyCompany.Aries.Quest.QuestDetailPane");
NPL.load("(gl)script/apps/Aries/Quest/NPCList.lua");
local NPCList = commonlib.gettable("MyCompany.Aries.Quest.NPCList");
NPL.load("(gl)script/apps/Aries/Quest/QuestDetailPage.lua");
local QuestDetailPage = commonlib.gettable("MyCompany.Aries.Quest.QuestDetailPage");

NPL.load("(gl)script/apps/Aries/Quest/QuestListPage.lua");
NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
local QuestListPage = commonlib.gettable("MyCompany.Aries.Quest.QuestListPage");
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
local QuestDialogPage = commonlib.gettable("MyCompany.Aries.Quest.QuestDialogPage");
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
local NPC = commonlib.gettable("MyCompany.Aries.Quest.NPC");

-- if true, the headon text display will be removed when dialog is shown, which will result in more movie like style. 
QuestDialogPage.toggle_headon_text = true;

--QuestDialogPage.group_list = {
	--{	
		--id = "npc", 
		--content = "content", 
		--buttons = {
			--{ label = "a", action = "gotonext" }, 
			--{ label = "b" action = "gotonext" }, 
			--{ label = "c" action = "gotonext" }, 
			--{ label = "d" action = "gotonext" }, 
		--},
	--},
	--{	
		--id = "user", 
		--content = "user content", 
		--buttons = {
			--{ label = "e", action = "gotonext" }, 
			--{ label = "f", action = "gotonext" }, 
			--{ label = "g", action = "gotonext" }, 
			--{ label = "h", action = "gotonext" }, 
		--},
	--},
--};
--QuestDialogPage.cur_group_list_item = nil;
--QuestDialogPage.group_list = nil;
--QuestDialogPage.quest_node = nil;
--QuestDialogPage.list = nil;
--QuestDialogPage.bak_list = nil;
--QuestDialogPage.cur_list_item = nil;

QuestDialogPage.quest_list = nil;--可以接受 和 可以完成的任务列表
QuestDialogPage.open_dialog_npcid = nil;
QuestDialogPage.cur_source_list = nil;--一组标题 or 一个任务的对话
QuestDialogPage.hasNativeBtns = nil;--有交互按钮
QuestDialogPage.hasQuestDialogs = nil;--有可以接受 或者 可以完成的 任务
QuestDialogPage.npc_has_common_content = nil;
QuestDialogPage.cur_page_index = nil;

-- if player is farther from the target npc than this value, we will automatically close it. 
QuestDialogPage.AutoCloseDialogDistance = 16;

function QuestDialogPage.DS_Func_Items_Buttons(index)
	local self = QuestDialogPage;
	local buttons;
	local item = self.GetCurItem();
	if(item)then
		buttons = item.buttons;
	end
	if(not buttons)then return 0 end
	if(index == nil) then
		return #(buttons);
	else
		local item = buttons[index];
		return item;
	end
end
--第几页的数据
--每一页有一句对话 和 多个交互按钮
function QuestDialogPage.GetCurItem()
	local self = QuestDialogPage;
	if(self.cur_source_list and self.cur_page_index)then
		local item = self.cur_source_list[self.cur_page_index];
		return item;
	end
end
function QuestDialogPage.IsTopPage()
	local self = QuestDialogPage;
	local page_source = self.cur_source_list;
	if(page_source)then
		local len = #page_source;
		local item = page_source[#page_source];
		if(item)then
			return item.top;
		end
	end
end
--跳转到最后一页并触发按钮
function QuestDialogPage.GotoLastPageAndActive()
	local self = QuestDialogPage;
	local page_source = self.cur_source_list;
	if(page_source)then
		local len = #page_source;
		local item = page_source[#page_source];
		if(item and item.buttons)then
			--group page
			if(item.top)then
				local node = item.buttons[1];
				QuestDialogPage.DoAction(node.action,1);
				QuestDialogPage.GotoLastPageAndActive();				
			else
				local len = #item.buttons;
				local node = item.buttons[len];
				QuestDialogPage.DoAction(node.action,len);
			end
		else
			self.ClosePage();
		end
	else
		self.ClosePage();
	end
end
--对话的翻页
function QuestDialogPage.NextPage()
	local self = QuestDialogPage;
	if(self.cur_source_list)then
		local len = #self.cur_source_list;
		if(self.cur_page_index < len)then
			self.cur_page_index  = self.cur_page_index + 1;

			if(self.page)then
				self.page:Refresh(0.01);
			end
		end
	end
end
function QuestDialogPage.OnInit()
	local self = QuestDialogPage;
	self.page = document:GetPageCtrl();
end
function QuestDialogPage.ClosePage()
	local self = QuestDialogPage;
	if(self.page)then
		self.page:CloseWindow();
		self.Clear();
	end	
end
function QuestDialogPage.Clear()
	local self = QuestDialogPage;
	self.quest_list = nil;
	self.open_dialog_npcid = nil;
	self.open_dialog_npc_instance = nil;
	self.cur_source_list = nil;--对话列表
	self.hasNativeBtns = nil;
	self.hasQuestDialogs = nil;
	self.npc_has_common_content = nil;
	self.clientdialog = nil;
	self.cur_page_index = nil;
end
function QuestDialogPage.HasDialog()
	local self = QuestDialogPage;
	if(self.hasQuestDialogs or self.hasNativeBtns or self.npc_has_common_content or self.clientdialog)then
		return true;
	end
end
function QuestDialogPage.BeforeShowPage(npcid, instance, quest_template)
	local self = QuestDialogPage;
	if(not npcid)then return end
	local provider = QuestClientLogics.GetProvider()
	if(not provider or not provider.local_is_init)then
		return
	end
	self.Clear();
	self.open_dialog_npcid = npcid;
	self.open_dialog_npc_instance = self.open_dialog_npc_instance or instance;
	--默认是第一页的对话
	self.cur_page_index = 1;

	if(not quest_template)then
		self.SetSourceList();
	else
		local node = { npcid = npcid, questid = quest_template.Id, state="start", Dialog = quest_template.StartDialog, };
		self.quest_node = node;
		self.cur_source_list = node.Dialog;
	end
end

-- if dialog is shown. 
function QuestDialogPage.IsDialogShown()
	if(QuestDialogPage.page) then
		return QuestDialogPage.page:IsVisible();
	end
end

-- enable player distance timer. it will automatically close opened NPC dialog if the player is out of the distance of the original NPC. 
-- @param bEnable: if nil or true, it will enable the timer, if false, it will disable the timer and user will need to manually close it. 
function QuestDialogPage.EnablePlayerDistanceTimer(bEnable)
	local self = QuestDialogPage;
	if(bEnable~=false) then
		QuestDialogPage.dist_timer = QuestDialogPage.dist_timer or commonlib.Timer:new({callbackFunc = function(timer)
			if(QuestDialogPage.IsDialogShown()) then
				if(self.open_dialog_npcid) then
					local npc = NPC.GetNpcCharacterFromIDAndInstance(self.open_dialog_npcid, if_else(self.open_dialog_npc_instance == 0, nil, self.open_dialog_npc_instance))
					if(not npc or npc:DistanceTo(ParaScene.GetPlayer()) > QuestDialogPage.AutoCloseDialogDistance) then
						QuestDialogPage.ClosePage();
						timer:Change();
					end
				end
			else
				timer:Change();
			end
		end})
		QuestDialogPage.dist_timer:Change(1000, 700);
	else
		if(QuestDialogPage.dist_timer) then
			QuestDialogPage.dist_timer:Change();
		end
	end
end

-- this will prevent the user clicking the quest dialog button too fast that it accidentally clicked on the ground.
function QuestDialogPage.EnableClickBlocker(bEnable, disable_duration)
	if(bEnable) then
		local obj = ParaUI.GetUIObject("questdialog_blocker_");
		QuestDialogPage.last_mouse_pos = QuestDialogPage.last_mouse_pos or {};
		QuestDialogPage.last_mouse_pos.x = mouse_x;
		QuestDialogPage.last_mouse_pos.y = mouse_y;
			
		if(not obj:IsValid()) then
			obj = ParaUI.CreateUIObject("button","questdialog_blocker_","_mb",0,0,0, if_else(System.options.version=="kids", 100, 86));
			obj.background = "";
			obj.zorder = -2; -- only prevent scene clicking instead of UI clicking. 
			obj:SetScript("onclick", function()
					if( (math.abs(QuestDialogPage.last_mouse_pos.x-mouse_x) + math.abs(QuestDialogPage.last_mouse_pos.y-mouse_y)) > 5) then
						QuestDialogPage.EnableClickBlocker(false);
					end
				end); 
			obj:AttachToRoot();
		else
			obj.visible = true;
			obj.enabled = true;
		end
		QuestDialogPage.blocker_timer = QuestDialogPage.blocker_timer or commonlib.Timer:new({callbackFunc = function(timer)
				QuestDialogPage.EnableClickBlocker(false);
			end})
		QuestDialogPage.blocker_timer:Change(disable_duration or 2000, nil)
	else
		local obj = ParaUI.GetUIObject("questdialog_blocker_");
		if(obj:IsValid()) then
			obj.visible = false;
			obj.enabled = false;
		end
		if(QuestDialogPage.blocker_timer) then
			QuestDialogPage.blocker_timer:Change();
		end
	end
end

-- called immediately after opening the dialog page
function QuestDialogPage.EnterDialogMode()
	if(System.options.version == "teen") then
		ParaCamera.GetAttributeObject():SetField("BlockInput", true);
	end
	MyCompany.Aries.HandleKeyboard.EnterDialogMode(QuestDialogPage.OnKeyDownProc);

	if(QuestDialogPage.toggle_headon_text) then
		ParaScene.GetAttributeObject():SetField("ShowHeadOnDisplay", false);
	end
end

-- called after closing the dialog page
function QuestDialogPage.LeaveDialogMode()
	if(System.options.version == "teen") then
		ParaCamera.GetAttributeObject():SetField("BlockInput", false);
	end
	-- restore ui and combat
	MyCompany.Aries.Desktop.ShowAllAreas();
	local BasicArena = commonlib.gettable("MyCompany.Aries.Quest.NPCs.BasicArena");
	BasicArena.EnableEnterCombat(true);
	QuestDialogPage.EnableClickBlocker(true);
	MyCompany.Aries.HandleKeyboard.LeaveDialogMode();
	if(QuestDialogPage.toggle_headon_text) then
		ParaScene.GetAttributeObject():SetField("ShowHeadOnDisplay", true);
	end
end

function QuestDialogPage.OnKeyDownProc(virtual_key)
	if(virtual_key == Event_Mapping.EM_KEY_SPACE) then
		if(System.options.version == "kids") then
			Map3DSystem.App.Commands.Call("Profile.Aries.Jump");
		end
	elseif(virtual_key == Event_Mapping.EM_KEY_ENTER or virtual_key == Event_Mapping.EM_KEY_X) then
		if(not QuestDialogPage.DoClick(1)) then
			local item = QuestDialogPage.GetCurItem();
			if(item and item.id) then
				QuestHelp.SayGoodbyeToNPC(item.id);
			end
			-- close the page if no button is there. 
			QuestDialogPage.ClosePage();
		end
	elseif(virtual_key == Event_Mapping.EM_KEY_ESCAPE) then
		local item = QuestDialogPage.GetCurItem();
		if(item and item.id) then
			QuestHelp.SayGoodbyeToNPC(item.id);
		end
		QuestDialogPage.ClosePage();
	end
end

-- 儿童版需要显示第一页的NPC列表
local specifiedNPCTableForKids = {36219,36220,36221,36222,30537,30538};
-- show current page
function QuestDialogPage.ShowPage(ignore_show_first_action)
	local self = QuestDialogPage;

	QuestDialogPage.EnableClickBlocker(false);
	
	if(QuestHelp.IsKidsVersion())then
		local params = {
			url = "script/apps/Aries/Quest/QuestDialogPage.html", 
			name = "QuestDialogPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 2,
			enable_esc_key = true,
			isTopLevel = true,
			allowDrag = false,
			directPosition = true,
				align = "_fi",
				x = 0,
				y = 0,
				width = 0,
				height = 0,
			cancelShowAnimation = true,
		};

		System.App.Commands.Call("File.MCMLWindowFrame", params);

		if(params._page) then
			QuestDialogPage.EnterDialogMode();
			params._page.OnClose = function(bDestroy)
				-- restore ui and combat
				QuestDialogPage.LeaveDialogMode();
			end
		end
	else
		local params = {
			url = "script/apps/Aries/Quest/QuestDialogPage.teen.html", 
			name = "QuestDialogPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 2,
			enable_esc_key = true,
			isTopLevel = true,
			allowDrag = false,
			directPosition = true,
				align = "_fi",
				x = 0,
				y = 0,
				width = 0,
				height = 0,
			cancelShowAnimation = true,
		};

		System.App.Commands.Call("File.MCMLWindowFrame", params);
		if(params._page) then
			QuestDialogPage.EnterDialogMode();
			params._page.OnClose = function(bDestroy)
				QuestDialogPage.LeaveDialogMode();
			end
		end
	end

	MyCompany.Aries.HandleMouse.ClearCursorSelection();
	

	--第一页必须显示 added:2012/06/29
	if(CommonClientService.IsTeenVersion())then
		ignore_show_first_action = true;
	else
		-- enable player distance
		QuestDialogPage.EnablePlayerDistanceTimer();
	end

	--儿童版要显示第一页的NPC
	if(CommonClientService.IsKidsVersion())then
		local k,v;
		for k,v in pairs(specifiedNPCTableForKids) do
			if(tonumber(self.open_dialog_npcid) == v) then
				ignore_show_first_action = true;
				break;
			end
		end	
	end
	--如果只有一页，并且这一页只有一个按钮的时候，自动显示这个按钮里面的内容
	--NOTE:忽略自动显示下一个接受任务，避免没有对话，直接接取任务
	if(not ignore_show_first_action)then
		QuestDialogPage.ShowFirstAction();
	end
end
function QuestDialogPage.ShowFirstAction()
	local self = QuestDialogPage;
	if(self.cur_source_list)then
		local len = #self.cur_source_list;
		if(len == 1)then
			self.cur_page_index = 1;
			local item = QuestDialogPage.GetCurItem();
			if(item and item.buttons)then
				local len_btn = #item.buttons;
				if(len_btn == 1)then
					local index = 1;
					local node = item.buttons[index];
					if(node)then
						local state = node.state or "";
						if(state ~= "progressing")then
							QuestDialogPage.DoAction(node.action,index);
						end
					end
				end
			end
		end
	end
end
--[[
state_index:
	1 可交任务
	2 任务过程中的NPC对话
	3 可领取任务
	4 功能链接
	5 其他
	6 进行中
--]]
function QuestDialogPage.SetSourceList()
	local self = QuestDialogPage;
	local npcid = self.open_dialog_npcid;
	if(not npcid)then return end
	--npc通用语言
	local npc_common_content = "";
	local npc_list,npc_list_map = QuestHelp.GetNpcList();
	local provider = QuestClientLogics.GetProvider();
	--以前npc具有的交互功能
	local nativebuttons;
	if(npc_list_map)then
		local npc_item = npc_list_map[npcid];
		if(npc_item)then
			nativebuttons = npc_item.nativebuttons;
			if(nativebuttons)then
				local len = #nativebuttons;
				--如果有旧的功能
				if(len > 0)then
					self.hasNativeBtns = true;
				end
			end
			npc_common_content = npc_item.desc or "";
		end
	end
	if(npc_common_content and npc_common_content ~= "")then
		self.npc_has_common_content = true;
	end
	if(provider)then
		local result,__,__,result_progressing,result_map,__,__,result_progressing_map,result_clientdialog = provider:FindQuestsByNPC(npcid);
		self.quest_map = result_map;--可以接受 和 可以完成的任务
		self.result_progressing_map = result_progressing_map;
		local templates = provider:GetTemplateQuests();
		function get_group(result)
			local group_list = {};
			local group_buttons = {};


			--【原始 功能链接】
			if(nativebuttons)then
				local k,v;
				for k,v in ipairs(nativebuttons) do
					local label = v.label;
					local canshow = true;
					local canshow_str = v.canshow;
					local loadfile = v.loadfile;
					--是否显示这个按钮
					if(canshow_str)then
						if(loadfile and loadfile ~= "")then
							local s = string.format("(gl)%s",loadfile);
							NPL.load(s);
						end
						local canshow_function =  commonlib.getfield(canshow_str);
						if(canshow_function)then
							canshow = canshow_function();
						end					
					end
					local state_index = k + 10;
					if(canshow)then
						local button = {
							action = v.action or "showpage",
							label = label,
							tag =  v,--button详细信息
							state_index = state_index,
						}
						table.insert(group_buttons,button);
					end
				end
			end
			--【可以接受 和 可以完成的任务】
			local k,v;
			for k,v in ipairs(result) do
				local questid = v.questid
				local state = v.state
				local state_index;
				if(state == "end")then
					state_index = 1;
				else
					state_index = 3;
				end
				local template = templates[questid];
				if(template)then
					local title = template.Title or "";
					local button = {
							action="gotogroup",
							label = title,
							questid = questid,
							state = state,
							state_index = state_index,
						};
					table.insert(group_buttons,button);
				end
			end
			--进行中的任务
			local k,v;
			for k,v in ipairs(result_progressing) do
				local questid = v.questid
				local state = v.state
				if(state == "progressing")then
					local state_index = 6;
					local template = templates[questid];
					if(template)then
						local title = template.Title or "";
						local button = {
								action="gotogroup_progressing",
								label = title,
								questid = questid,
								state = state,
								state_index = state_index,
							};
						table.insert(group_buttons,button);
					end
				end
			end
			--【激活任务后 和某个npc的对话】
			if(result_clientdialog and result_clientdialog.buttons)then
				local k,v;
				local label = result_clientdialog.label or "";
				local button = {
						action = "show_npcdialog_in_quest",
						label = label,
						tag =  result_clientdialog.buttons,--button详细信息
						state_index = 2,
					}
				table.insert(group_buttons,button);
			end
			table.insert(group_list,{
				id = npcid,
				content = npc_common_content,
				buttons = group_buttons,
				top = true,
			});

			return group_list;
		end
		if(result)then
			local len = #result;
			if(len > 0)then
				self.hasQuestDialogs = true;
			end
			local len_progressing = #result_progressing;
			local beGroup = false;
			local group_list = nil;
			--如果一个npc挂了多个任务
			--或者 已经有交互功能
			--或者 在激活的任务中 有NPC对话
			if(len > 0 or self.hasNativeBtns or result_clientdialog or len_progressing > 0)then
				self.cur_source_list = get_group(result);
				--有npc对话
				self.clientdialog = true;
				local buttons = self.cur_source_list[1].buttons;
				if(buttons)then
					table.sort(buttons,function(a,b)
						if(a.state_index and b.state_index)then
							return a.state_index < b.state_index;
						end
					end);
				end
			else
				--如果什么都没有，只显示通用语言
				local list = {
					{id = npcid,content = npc_common_content, top = true,},
				};
				self.cur_source_list = list;
				--local node = result[1];
				----有可以接的任务 或者 可以完成的任务
				--if(node)then
					--self.quest_node = node;
					--self.cur_source_list = node.Dialog;
				--else
					--local list = {
						--{id = npcid,content = npc_common_content,},
					--};
					--self.cur_source_list = list;
				--end
			end
		end
	end
end

-- Please note that if the content begins with "script/%S+%s+", the html page will be removed from the text, yet displayed separatedly. 
-- @note: the html can be something like: "script/sample.html?name=value", etc. 
-- @param isPage: true to get content page instead of content text. 
function QuestDialogPage.GetContent(isPage)
	local item = QuestDialogPage.GetCurItem();
    if(item and item.content)then
        if(not item.content_text) then
            item.content_page = string.match(item.content, "(script/%S+)");
			if(item.content_page) then
				item.content_text = string.gsub(item.content, "(script/%S+)", "");
			else
				item.content_text = item.content;
			end
        end
        if(not isPage) then
            return item.content_text;
        else
            return item.content_page;
        end
    end
end

-- click by index
-- @return true if there is index, or nil if no button at the index
function QuestDialogPage.DoClick(index)
	index = tonumber(index);
    if(not index)then return end
    local item = QuestDialogPage.GetCurItem();
    if(item and item.buttons)then
        local node = item.buttons[index];
        if(node)then
            QuestDialogPage.DoAction(node.action,index);
			return true;
        end
    end
end

function QuestDialogPage.DoAction_finished(questid)
	if(not questid)then return end
	local provider = QuestClientLogics.GetProvider();
	--额外奖励是否 全部自动选中
	function getReward_1_isAllAutoChecked(template)
		if(template)then
			local v = template["Reward"];
			if(v and v[2])then
				local info = "";
				local list = v[2];
				local choice = list.choice or 0;
				local len = #list;
				if(choice >= len)then
					local reward_index_list = {};
					local k;
					for k =1 ,len do
						table.insert(reward_index_list,k);
					end
					return true,reward_index_list,list;
				end
				return false,nil,list;
			end
		end
	end
	local templates = provider:GetTemplateQuests();
	local template = templates[questid];
	if(template)then
		local FinishQuestSilentMode = template.FinishQuestSilentMode or 0;
		local bAllChecked,reward_index_list,raw_list = getReward_1_isAllAutoChecked(template);
		if(raw_list)then
			local len = #raw_list;
			--如果有额外奖励 并且没有全部自动选中 强制显示 任务详细面板，让用户选择奖励
			if(len > 0 and not bAllChecked)then
				FinishQuestSilentMode = 0;
			end
		end
		local msg = {
			id = questid,
			reward_index_list = reward_index_list,
		}
		if(QuestClientLogics.HasFinished(msg))then
			return
		end
		if(not QuestClientLogics.CanFinished(msg))then
			return
		end
		if(FinishQuestSilentMode == 0)then
			if(QuestHelp.IsKidsVersion())then
				QuestDetailPage.ShowPage(questid,1);
			else
				QuestDetailPane.ShowPage(questid,"do_finished")
			end
		else
				QuestClientLogics.TryFinished(msg);
		end
	end
end
--当前对话页的 触发的是哪个按钮
function QuestDialogPage.DoAction(action,index)
	local self = QuestDialogPage;
	action = tostring(action);
    index = tonumber(index);
	--进行中的任务 标题列表
	if(action == "gotogroup_progressing")then
		local item = QuestDialogPage.GetCurItem();
		if(index and item and item.buttons and item.buttons[index])then
			local btn_node = item.buttons[index];
			local questid = btn_node.questid;
			if(questid and self.result_progressing_map)then
				local quest_node = self.result_progressing_map[questid];
				if(quest_node)then
					self.quest_node = quest_node;
					self.cur_source_list = quest_node.Dialog;
					self.cur_page_index = 1;
					if(self.page)then
						self.page:Refresh(0.01);
					end
				end
			end
		end
    elseif(action == "gotogroup")then
		local item = QuestDialogPage.GetCurItem();
		if(index and item and item.buttons and item.buttons[index])then
			local btn_node = item.buttons[index];
			local questid = btn_node.questid;
			if(questid and self.quest_map)then
				local quest_node = self.quest_map[questid];
				if(quest_node)then
					self.quest_node = quest_node;
					self.cur_source_list = quest_node.Dialog;
					self.cur_page_index = 1;
					if(self.page)then
						self.page:Refresh(0.01);
					end
				end
			end
		end
	elseif(action == "thingsinfo") then
		local item = QuestDialogPage.GetCurItem();
		if(index and item and item.buttons and item.buttons[index])then
			local btn_node = item.buttons[index];
			self.cur_source_list = btn_node.tag;
			self.cur_page_index = 1;
			if(self.page)then
				self.page:Refresh(0.01);
			end
		end
	elseif(action == "gofirstpage") then
		local instance = self.open_dialog_npc_instance;
		local npcid = self.open_dialog_npcid;
		self.Clear();
		self.BeforeShowPage(npcid, instance, nil);
		if(self.page)then
			self.page:Refresh(0.01);
		end
	 elseif(action == "show_npcdialog_in_quest")then
		local item = QuestDialogPage.GetCurItem();
		if(index and item and item.buttons and item.buttons[index])then
			local btn_node = item.buttons[index];
			self.cur_source_list = btn_node.tag;
			self.cur_page_index = 1;
			if(self.page)then
				self.page:Refresh(0.01);
			end
		end
    elseif(action == "gotonext")then
        --next page;
		if(self.page and index)then	
			self.NextPage();
		end
    elseif(action == "doaccept")then
		local node = self.quest_node;
		local provider = QuestClientLogics.GetProvider();
		if(node and provider)then
			local npcid = node.npcid;
			local questid = node.questid;
			local state = node.state;
			local Dialog = node.Dialog;
			if(provider:HasAccept(questid))then
				self.ClosePage();
				--do nothing
				return
			end
			local templates = provider:GetTemplateQuests();
			local template = templates[questid];
			if(template)then
				local AcceptQuestSilentMode = template.AcceptQuestSilentMode or 0;
				local msg = {
					id = questid,
				}
				QuestDialogPage.ClosePage();
				if(QuestClientLogics.HasAccept(msg))then
					return
				end
				if(not QuestClientLogics.CanAccept(msg))then
					return
				end
				if(AcceptQuestSilentMode == 0)then
					if(QuestHelp.IsKidsVersion())then
						QuestDetailPage.ShowPage(questid,0);
					else
						QuestDetailPane.ShowPage(questid,"do_accepted")
					end
				else
					 QuestClientLogics.TryAccept(msg, function(msg)
							if(msg and msg.issuccess) then
								if(QuestClientLogics.EnableTrackingAfterAccept and System.options.version == "teen") then
									NPL.load("(gl)script/apps/Aries/Quest/QuestPathfinderNavUI.lua");
									local QuestPathfinderNavUI = commonlib.gettable("MyCompany.Aries.Quest.QuestPathfinderNavUI");
									QuestPathfinderNavUI.EnterAutoNavigationMode();
								end
							end
						end);
				end
			end
		end
	elseif(action == "dofinished")then
		local node = self.quest_node;
		local provider = QuestClientLogics.GetProvider();
		if(node and provider)then
			
			local npcid = node.npcid;
			local questid = node.questid;
			local state = node.state;
			local Dialog = node.Dialog;
			QuestDialogPage.ClosePage();
			if(provider:HasFinished(questid))then
				--do nothing
				return
			end
			QuestDialogPage.DoAction_finished(questid);
		end
	elseif(action == "showpage")then
		--dofunction
		--loadfile
		--canshow
		if(self.open_dialog_npcid and self.cur_source_list)then
			local item = self.cur_source_list[self.cur_page_index];
			if(item)then
				local iscancel;
				local dofunction;
				local loadfile;
				local param1;
				local param2;
				local param3;
				local param4;
				local param5;

				local state;
				local instance;
				local npcid;
				local buttons = item.buttons;

				if(buttons and buttons[index])then
					local btn_tag = buttons[index].tag;
					if(btn_tag)then
						state = tonumber(btn_tag.state);
						instance = tonumber(btn_tag.instance);
						dialog_url = btn_tag.dialog_url;
						npcid = tonumber(btn_tag.npcid) or self.open_dialog_npcid;
						dofunction = btn_tag.dofunction;
						loadfile = btn_tag.loadfile;
						param1 = btn_tag.param1;
						param2 = btn_tag.param2;
						param3 = btn_tag.param3;
						param4 = btn_tag.param4;
						param5 = btn_tag.param5;
						iscancel = btn_tag.iscancel;
						if(iscancel)then
							iscancel = string.lower(iscancel);
							if(iscancel == "true")then
								iscancel = true;	
							else
								iscancel = false;
							end						
						end
					end
				end
				if(not iscancel)then
					if(loadfile and loadfile ~= "")then
						local s = string.format("(gl)%s",loadfile);
						NPL.load(s);
					end
					dofunction =  commonlib.getfield(dofunction);
					if(dofunction)then
						dofunction(param1,param2,param3,param4,param5);
					else
						System.App.Commands.Call("Profile.Aries.ShowNPCDialog", {dialog_url = dialog_url, npc_id = npcid, instance = instance, state = state, isfromcombopage = true,});
					end
				end
			end
			self.ClosePage();
		end
	elseif(action == "donpcdialoged")then
		if(self.open_dialog_npcid)then
			-- 通知任务完成一次对话
			local command = System.App.Commands.GetCommand("Aries.Quest.DoAddValue");
			if(command) then
				command:Call({
					increment = { {id = self.open_dialog_npcid, value = 1}, },
				});
			end
			QuestHook.Invoke("quest_npc_dialog", self.open_dialog_npcid)
		end
		self.ClosePage();
    elseif(action == "docancel")then
		self.ClosePage();
    end
end
