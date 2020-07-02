--[[
Title: 
Author(s): Leio
Date: 2011/08/24
Desc: 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Quest/QuestDetailPane.lua");
local QuestDetailPane = commonlib.gettable("MyCompany.Aries.Quest.QuestDetailPane");
QuestDetailPane.ShowPage(60001,"do_accepted")
-------------------------------------------------------
]]
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
local QuestDetailPane = commonlib.gettable("MyCompany.Aries.Quest.QuestDetailPane");
local LOG = LOG;
NPL.load("(gl)script/apps/Aries/Quest/QuestPane.lua");
local QuestPane = commonlib.gettable("MyCompany.Aries.Quest.QuestPane");
function QuestDetailPane.OnInit()
	local self = QuestDetailPane;
	self.page = document:GetPageCtrl();
end
function QuestDetailPane.ClosePage()
	local self = QuestDetailPane;
	if(self.page)then
		self.page:CloseWindow();
		self.id = nil;
		self.state = nil;
		self.extra_reward_list = nil;
		self.req_num = nil;
		self.need_select = nil;
	end	
end
function QuestDetailPane.GetExtraReword()
    return QuestDetailPane.extra_reward_list,QuestDetailPane.req_num,QuestDetailPane.need_select;
end
--获取选择的长度
function QuestDetailPane.GetSelectedList()
    local extra_reward_list,req_num,need_select = QuestDetailPane.GetExtraReword();
    local list = extra_reward_list;
    if(list)then
        local selected_list = {};
        local k,v;
        for k,v in ipairs(list) do
            if(v.checked and v.index)then
                table.insert(selected_list,v.index);
            end
        end
        return selected_list;
    end
end
--接受任务
function QuestDetailPane.DoAccepted()
	NPL.load("(gl)script/apps/Aries/mcml/pe_goal_pointer.lua");
	local goal_manager = commonlib.gettable("MyCompany.Aries.mcml_controls.goal_manager");
	goal_manager.finish("do_quest_button");

    local questid = QuestDetailPane.id;
    questid = tonumber(questid);
    local msg = {
	            nid = nid,
	            id = questid,
            }

	QuestDetailPane.ClosePage();

    QuestClientLogics.TryAccept(msg, function(msg)
		if(msg and msg.issuccess) then
			if(QuestClientLogics.EnableTrackingAfterAccept and System.options.version == "teen") then
				NPL.load("(gl)script/apps/Aries/Quest/QuestPathfinderNavUI.lua");
				local QuestPathfinderNavUI = commonlib.gettable("MyCompany.Aries.Quest.QuestPathfinderNavUI");
				QuestPathfinderNavUI.EnterAutoNavigationMode();
			end
		end
	end);
    
	return true;
end
--检查是否有需要选择的奖励
function QuestDetailPane.Check_CanFinished()
    local extra_reward_list,req_num = QuestDetailPane.GetExtraReword();
    if(extra_reward_list)then
        local len = #extra_reward_list;
        if(len == 0)then
            return true;
        end
        local selected_list = QuestDetailPane.GetSelectedList();
        local n = 0;
        if(selected_list)then
            n = #selected_list;
        end
        if(n < req_num)then
            _guihelper.MessageBox("请选择你的奖励！");
            return false;
        elseif(n > req_num)then
            _guihelper.MessageBox("你选择的奖励太多了！");
            return false;
        end
    end
    return true;
end
--完成任务
function QuestDetailPane.DoFinished()
	NPL.load("(gl)script/apps/Aries/mcml/pe_goal_pointer.lua");
	local goal_manager = commonlib.gettable("MyCompany.Aries.mcml_controls.goal_manager");
	goal_manager.finish("do_quest_button");

    local can_pass = QuestDetailPane.Check_CanFinished();
    if(not can_pass)then return end
    local questid = QuestDetailPane.id;
    questid = tonumber(questid);
    local reward_index_list = QuestDetailPane.GetSelectedList();
    
     local msg = {
	            nid = nid,
	            id = questid,
                reward_index_list = reward_index_list,
            }
    QuestClientLogics.TryFinished(msg);
    QuestDetailPane.ClosePage();
	return true;
end
-- called immediately after opening the dialog page
function QuestDetailPane.EnterDialogMode()
	MyCompany.Aries.HandleKeyboard.EnterDialogMode(QuestDetailPane.OnKeyDownProc);
end

-- called after closing the dialog page
function QuestDetailPane.LeaveDialogMode()
	MyCompany.Aries.HandleKeyboard.LeaveDialogMode();
end

function QuestDetailPane.OnKeyDownProc(virtual_key)
	if(virtual_key == Event_Mapping.EM_KEY_SPACE) then
		if(System.options.version == "kids") then
			Map3DSystem.App.Commands.Call("Profile.Aries.Jump");
		end
	elseif(virtual_key == Event_Mapping.EM_KEY_ENTER or virtual_key == Event_Mapping.EM_KEY_X) then
		-- force user to click on the user interface or read the text. In case the user is pressing X key too fast. 
		--if(MyCompany.Aries.Quest.QuestDetailPane.state == 'do_accepted')then
			--QuestDetailPane.DoAccepted()
		--elseif(MyCompany.Aries.Quest.QuestDetailPane.state == 'do_finished')then
			--QuestDetailPane.DoFinished()
		--end
	elseif(virtual_key == Event_Mapping.EM_KEY_ESCAPE) then
		QuestDetailPane.ClosePage();
	end
end

--@param id:quest id;
--@param state: "do_accepted" or "do_finished"
function QuestDetailPane.ShowPage(id,state)
	local self = QuestDetailPane;
	if(not id)then return end
	local url = string.format("script/apps/Aries/Quest/QuestDetailPane.teen.html");
	self.id = id;
	self.state = state;
	local extra_reward_list,req_num,need_select= QuestPane.GetExtraReword(id);
	--额外奖励列表,打开界面的时候只生成一次
	self.extra_reward_list = extra_reward_list;
	--可以发送的数目
	self.req_num = req_num;
	--是否还需要用户手动选择，比如有1项奖励，可选的也只有1项，那么系统会自动选择这项奖励，用户不需要再选
	self.need_select = need_select;

	local params =  {
		url = url, 
		name = "QuestDetailPane.ShowPage", 
		app_key=MyCompany.Aries.app.app_key, 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		style = CommonCtrl.WindowFrame.ContainerStyle,
		zorder = 1,
		isTopLevel = true,
		allowDrag = false,
		enable_esc_key = true,
		directPosition = true,
			align = "_ct",
			x = -395/2,
			y = -350/2,
			width = 395,
			height = 420,
	};
	System.App.Commands.Call("File.MCMLWindowFrame", params);
	if(params._page) then
		QuestDetailPane.EnterDialogMode();
		params._page.OnClose = function(bDestroy)
			QuestDetailPane.LeaveDialogMode();
		end
	end
end
