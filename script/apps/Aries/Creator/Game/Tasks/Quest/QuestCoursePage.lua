--[[
Title: QuestCoursePage
Author(s): yangguiyi
Date: 2021/01/17
Desc:  
Use Lib:
-------------------------------------------------------
local QuestCoursePage = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Quest/QuestCoursePage.lua");
QuestCoursePage.Show();
--]]
local QuestCoursePage = NPL.export();
local HttpWrapper = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/HttpWrapper.lua");
-- local QuestProvider = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Quest/QuestProvider.lua");
local QuestProvider = commonlib.gettable("MyCompany.Aries.Game.Tasks.Quest.QuestProvider");

local KeepWorkItemManager = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/KeepWorkItemManager.lua");
local pe_gridview = commonlib.gettable("Map3DSystem.mcml_controls.pe_gridview");
local ParacraftLearningRoomDailyPage = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/ParacraftLearningRoom/ParacraftLearningRoomDailyPage.lua");
local DailyTaskManager = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/DailyTask/DailyTaskManager.lua");
local TaskIdList = DailyTaskManager.GetTaskIdList()
local QuestAction = commonlib.gettable("MyCompany.Aries.Game.Tasks.Quest.QuestAction");
local QuestRewardPage = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Quest/QuestRewardPage.lua");

commonlib.setfield("MyCompany.Aries.Creator.Game.Task.Quest.QuestCoursePage", QuestCoursePage);
local page;
QuestCoursePage.isOpen = false
QuestCoursePage.TaskData = {}
QuestCoursePage.is_add_event = false
QuestCoursePage.begain_exid = 40015
QuestCoursePage.end_exid = 40024
QuestCoursePage.is_always_exist_exid = 40024
QuestCoursePage.begain_time_t = {year=2021, month=1, day=14, hour=0, min=0, sec=0}

QuestCoursePage.GiftState = {
	can_not_get = 0,		--未能领取
	can_get = 1,			--可领取
	has_get = 2,			--已领取
}

QuestCoursePage.TaskState = {
	can_go = 0,
	has_go = 1,
	can_not_go = 2,
}

QuestCoursePage.CourseData = {
	{catch_value = 20, state = QuestCoursePage.GiftState.can_not_get, img = "", course_id = 1, exid = 30023},
	{catch_value = 40, state = QuestCoursePage.GiftState.can_not_get, img = "", course_id = 2, exid = 30024},
	{catch_value = 60, state = QuestCoursePage.GiftState.can_not_get, img = "", course_id = 3, exid = 30025},
	{catch_value = 80, state = QuestCoursePage.GiftState.can_not_get, img = "", course_id = 4, exid = 30026},
	{catch_value = 100, state = QuestCoursePage.GiftState.can_not_get, img = "", course_id = 5, exid = 30027},
}

QuestCoursePage.CourseTimeLimit = {
	{begain_time = {hour=10,min=30}, end_time = {hour=10,min=45}},
	{begain_time = {hour=13,min=30}, end_time = {hour=13,min=45}},
	{begain_time = {hour=16,min=0}, end_time = {hour=16,min=15}},
	{begain_time = {hour=18,min=0}, end_time = {hour=18,min=15}},
}

local VersionToKey = {
	ONLINE = 1,
	RELEASE = 2,
	LOCAL = 3,
}

local ProInitData = {}

local TargetProgerssValue = 60
local MaxProgressValue = 100
local RewardNums = 5
local modele_bag_id = 0
local server_time = 0
local today_weehours = 0

function QuestCoursePage.OnInit()
	page = document:GetPageCtrl();
	page.OnClose = QuestCoursePage.CloseView
	page.OnCreate = QuestCoursePage.OnCreate()
end

function QuestCoursePage.OnCreate()
end

-- is_make_up 是否补课面板
function QuestCoursePage.Show(is_make_up)
	QuestCoursePage.is_make_up = is_make_up
    if(not GameLogic.GetFilters():apply_filters('is_signed_in'))then
        return
    end
	keepwork.user.server_time({}, function(err, msg, data)
		if err == 200 then
			server_time = commonlib.timehelp.GetTimeStampByDateTime(data.now)
			today_weehours = commonlib.timehelp.GetWeeHoursTimeStamp(server_time)
			QuestCoursePage.ShowView()
		end
	end)
end

function QuestCoursePage.RefreshData()
	if page == nil or not page:IsVisible() then
		return
	end
	
	keepwork.user.server_time({}, function(err, msg, data)
		if err == 200 then
			if not QuestCoursePage.IsVisible() then
				return
			end

			server_time = commonlib.timehelp.GetTimeStampByDateTime(data.now)
			today_weehours = commonlib.timehelp.GetWeeHoursTimeStamp(server_time)

			QuestCoursePage.CheckIsTaskCompelete()
			QuestCoursePage.HandleTaskData()
			QuestCoursePage.HandleCourseData()
			QuestCoursePage.OnRefreshGridView()
			QuestCoursePage.OnRefreshGiftGridView()
		end
	end)
end

function QuestCoursePage.ShowView()
	if page and page:IsVisible() then
		return
	end

	-- if QuestProvider.GetInstance == nil then
	-- 	return
	-- end
	QuestCoursePage.CheckIsTaskCompelete()
	QuestCoursePage.HandleTaskData()
	QuestCoursePage.HandleCourseData()
	
	if not QuestCoursePage.is_add_event then
		QuestProvider:GetInstance():AddEventListener(QuestProvider.Events.OnRefresh,function()
			if not page or not page:IsVisible() then
				return
			end
			QuestCoursePage.RefreshData()
			
		end, nil, "QuestCoursePage_Event_Init")

		QuestProvider:GetInstance():AddEventListener(QuestProvider.Events.OnFinished,function(__, event)
			if not page or not page:IsVisible() then
				return
			end

			-- local questItemContainer = event.quest_item_container
			-- local childrens = questItemContainer.children
			-- QuestCoursePage.RefreshData()
		end, nil, "QuestCoursePage_OnFinished")

		QuestCoursePage.is_add_event = true
	end

    local bagNo = 1007;
    for _, bag in ipairs(KeepWorkItemManager.bags) do
        if (bagNo == bag.bagNo) then 
            modele_bag_id = bag.id;
            break;
        end
    end
	

	QuestCoursePage.isOpen = true
	local view_width = 960
	local view_height = 580
	local params = {
			url = "script/apps/Aries/Creator/Game/Tasks/Quest/QuestCoursePage.html",
			name = "QuestCoursePage.Show", 
			isShowTitleBar = false,
			DestroyOnClose = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			enable_esc_key = true,
			zorder = 0,
			app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key, 
			directPosition = true,
				align = "_ct",
				x = -view_width/2,
				y = -view_height/2,
				width = view_width,
				height = view_height,
				isTopLevel = true
		};
	System.App.Commands.Call("File.MCMLWindowFrame", params);
end

function QuestCoursePage.IsVisible()
	if page == nil then
		return false
	end
	return page:IsVisible()
end

function QuestCoursePage.OnRefreshGridView()
    -- if(page)then
    --     page:Refresh(0);
	-- end
	
	local gvw_name = "item_gridview";
	local node = page:GetNode(gvw_name);
	pe_gridview.DataBind(node, gvw_name, false);
end

function QuestCoursePage.OnRefreshGiftGridView()
    -- if(page)then
    --     page:Refresh(0);
	-- end
	
	local gvw_name = "gift_gridview";
	local node = page:GetNode(gvw_name);
	pe_gridview.DataBind(node, gvw_name, false);
end

function QuestCoursePage.CloseView()
	QuestCoursePage.isOpen = false
	NPL.KillTimer(10086);

	local file_fold_name = "Texture/Aries/Creator/keepwork/Quest/"
	local Files = commonlib.gettable("MyCompany.Aries.Game.Common.Files");
	Files:UnloadFoldAssets(file_fold_name);
end

function QuestCoursePage.EnterWorld(world_id)
	page:CloseWindow()
	QuestCoursePage.CloseView()
	local CommandManager = commonlib.gettable("MyCompany.Aries.Game.CommandManager")
	CommandManager:RunCommand(string.format('/loadworld -force -s %s', world_id))

	-- QuestCoursePage.RefreshData()
end

function QuestCoursePage.WeekWork()
	local TeachingQuestLinkPage = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/User/TeachingQuestLinkPage.lua");
	TeachingQuestLinkPage.ShowPage();
end

function QuestCoursePage.Classroom()
	local StudyPage = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/User/StudyPage.lua");
	StudyPage.clickArtOfWar();
end

function QuestCoursePage.UpdataWorld()
	if(mouse_button == "right") then
		-- the new version
		GameLogic.GetFilters():apply_filters('show_create_page')
	else
		GameLogic.GetFilters():apply_filters('show_console_page')
	end
end

function QuestCoursePage.VisitWorld()
	GameLogic.GetFilters():apply_filters('show_offical_worlds_page')
end

function QuestCoursePage.GetCompletePro(data)
	local task_id = data.task_id or "0"
	local task_data = DailyTaskManager.GetTaskData(task_id)
	local complete_times = task_data.complete_times or 0

	return complete_times .. "/" .. task_data.max_times
end

function QuestCoursePage.HandleTaskData(data)
	QuestCoursePage.TaskData = {}
	local quest_datas = QuestProvider:GetInstance().templates_map
	local exid_list = {}
	for i, v in pairs(quest_datas) do
		-- 获取兑换规则
		if exid_list[v.exid] == nil and QuestCoursePage.GetTaskVisible(v.exid) then
			exid_list[v.exid] = 1
			local index = #QuestCoursePage.TaskData + 1
			local task_data = {}
			local exchange_data = KeepWorkItemManager.GetExtendedCostTemplate(v.exid)
			local name = exchange_data.name
			local desc = exchange_data.desc
	
			task_data.name = name
			task_data.task_id = v.exid
			task_data.task_desc = desc

			task_data.is_finish = QuestAction.IsFinish(v.gsid)
			task_data.task_type = QuestCoursePage.GetTaskType(v)
			task_data.is_main_task = task_data.task_type == "main"

			task_data.task_pro_desc = ""
			task_data.task_state = QuestCoursePage.GetTaskStateByQuest(task_data)
			task_data.order = QuestCoursePage.GetTaskOrder(v)
			task_data.bg_img = QuestCoursePage.GetBgImg(task_data)
			-- task_data.questItemContainer = v.questItemContainer

			task_data.goods_data = {}
			-- for i2, v2 in ipairs(exchange_data.exchangeTargets[1].goods) do
			-- 	if v2.goods.gsId < 60001 or v2.goods.gsId > 70000 then
			-- 		if #task_data.goods_data < 3 then
			-- 			task_data.goods_data[#task_data.goods_data + 1] = v2
			-- 		end
			-- 	end
			-- end
			QuestCoursePage.TaskData[index] = task_data
		end
	end

	-- 主线任务在前
	table.sort(QuestCoursePage.TaskData, function(a, b)
		local value_a = 10000
		local value_b = 10000
		if a.is_main_task then
			value_a = value_a + 10000
		end
		if b.is_main_task then
			value_b = value_b + 10000
		end

		if a.task_type == "branch" then
			value_a = value_a + 1000
		end
		if b.task_type == "branch" then
			value_b = value_b + 1000
		end

		if a.task_type == "loop" then
			value_a = value_a + 100
		end
		if b.task_type == "loop" then
			value_b = value_b + 100
		end

		if a.order < b.order then
			value_a = value_a + 10
		end
		if b.order < a.order then
			value_b = value_b + 10
		end

		if a.task_id < b.task_id then
			value_a = value_a + 1
		end
		if b.task_id < a.task_id then
			value_b = value_b + 1
		end

		-- if a.task_state == QuestCoursePage.TaskState.has_complete then
		-- 	value_a = value_a - 10000
		-- end
		-- if b.task_state == QuestCoursePage.TaskState.has_complete then
		-- 	value_b = value_b - 10000
		-- end

		return value_a > value_b
	end)
end

function QuestCoursePage.GetTaskProDesc(task_id)
	task_id = task_id or "0"
	local task_data = DailyTaskManager.GetTaskData(task_id)
	local complete_times = task_data.complete_times or 0

	return "进度： "  .. complete_times .. "/" .. task_data.max_times
end

function QuestCoursePage.GetTaskOrder(data)
	if data and data.order then
		return tonumber(data.order)
	end

	return 0
end

function QuestCoursePage.GetTaskVisible(exid)
	
	if exid < QuestCoursePage.begain_exid or exid > QuestCoursePage.end_exid then
		return false
	end

	-- 第几天
	local second_day = QuestCoursePage.GetSecondDay(exid)
	local date_t = commonlib.copy(QuestCoursePage.begain_time_t)
	date_t.day = date_t.day + second_day - 1
	local day_weehours = os.time(date_t)

	-- 补课要展示今天以前的课程
	if QuestCoursePage.is_make_up then
		-- print("bbbbbbbb", day_weehours < today_weehours)
		-- echo(os.date("*t",day_weehours), true)
		-- echo(os.date("*t",today_weehours), true)
		if day_weehours < today_weehours then
			return true
		end
	else -- 非补课的话 要展示今天当天的课程

		-- 毕业任务常驻
		
		if exid == QuestCoursePage.is_always_exist_exid then
			return true
		end
		
		if today_weehours == day_weehours then
			return true
		end
	end

	return false
end

function QuestCoursePage.GetTaskStateByQuest(data)
	if data.task_id == QuestCoursePage.is_always_exist_exid then
		if not QuestCoursePage.IsGraduateTime() then
			return QuestCoursePage.TaskState.can_not_go
		end

		return QuestCoursePage.TaskState.can_go
	end

	if data.is_finish then
		return QuestCoursePage.TaskState.has_go
	end

	-- 补课的话不需要管时间
	-- if QuestCoursePage.is_make_up then
	-- 	return QuestCoursePage.TaskState.can_go
	-- end

	-- local is_in_course_time = QuestCoursePage.CheckIsInCourseTime()
	-- if not is_in_course_time then
	-- 	return QuestCoursePage.TaskState.can_not_go
	-- end

	return QuestCoursePage.TaskState.can_go
end

function QuestCoursePage.GetBgImg(task_data)
	local img = "Texture/Aries/Creator/keepwork/Quest/bjtiao2_226X90_32bits.png#0 0 226 90:195 20 16 20"
	if task_data.is_main_task then
		img = "Texture/Aries/Creator/keepwork/Quest/bjtiao_226X90_32bits.png#0 0 226 90:195 20 16 20"
	end

	return img
end

function QuestCoursePage.HandleCourseData()
	local gift_state_list = QuestAction.GetGiftStateList()
	for i, v in ipairs(QuestCoursePage.CourseData) do
		v.state = gift_state_list[i] or QuestCoursePage.GiftState.can_not_get
		v.img = QuestCoursePage.GetIconImg(i, v)
		v.number_img = QuestCoursePage.GetNumImg(v)
	end
end


function QuestCoursePage.GetIconImg(index, item)
	-- 最后一个礼拜要做不同显示
	if index == #QuestCoursePage.CourseData then
		return "Texture/Aries/Creator/keepwork/Quest/liwu3_86X70_32bits.png#0 0 86 70"
	end

	local path = "Texture/Aries/Creator/keepwork/Quest/liwu1_55X56_32bits.png#0 0 55 56"
	if item.state == QuestCoursePage.GiftState.can_not_get then
		path = "Texture/Aries/Creator/keepwork/Quest/liwu2_55X56_32bits.png#0 0 55 56"
	end

	return path
end

function QuestCoursePage.GetNumImg(item)
	local num = item.catch_value
	
	return string.format("Texture/Aries/Creator/keepwork/Quest/zi_%s_23X12_32bits.png#0 0 23 12", num)
end

-- 这里的task_id 其实就是exid
function QuestCoursePage.GetReward(task_id)
	local task_data = nil
	for key, v in pairs(QuestCoursePage.TaskData) do
		if v.task_id == task_id then
			task_data = v
			break
		end
	end
	
	if nil == task_data then
		return
	end

	-- local quest_data = QuestCoursePage.GetQuestData(task_data.task_id)

	-- if quest_data == nil then
	-- 	return
	-- end

	-- if task_data.task_type == "loop" then
	-- 	local childrens = quest_data.questItemContainer.children or {}
		
	-- 	for i, v in ipairs(childrens) do
	-- 		QuestAction.FinishDailyTask(v.template.id)
	-- 	end
		
	-- 	QuestCoursePage.RefreshData()
	-- else
		
	-- 	if quest_data.questItemContainer then
	-- 		quest_data.questItemContainer:DoFinish()
	-- 	end
	-- end


end

function QuestCoursePage.Goto(task_id)
	keepwork.user.server_time({}, function(err, msg, data)
		if err == 200 then
			server_time = commonlib.timehelp.GetTimeStampByDateTime(data.now)
			today_weehours = commonlib.timehelp.GetWeeHoursTimeStamp(server_time)

			if task_id == QuestCoursePage.is_always_exist_exid then
				QuestCoursePage.ToGraduate()
				return
			end

			local show_vip_view = function(desc, form)
				_guihelper.MessageBox(desc, nil, nil,nil,nil,nil,nil,{ ok = L"确定"});
				_guihelper.MsgBoxClick_CallBack = function(res)
					if(res == _guihelper.DialogResult.OK) then
						GameLogic.GetFilters():apply_filters("VipNotice", true, "vip_goods",function()
							QuestCoursePage.Goto(task_id)
						end);
					else
					end
				end
			end
			local task_data = QuestCoursePage.GetQuestData(task_id)
			if task_data == nil then
				return
			end

			if task_data.task_state == QuestCoursePage.TaskState.can_not_go then
				return
			end

			if QuestCoursePage.is_make_up then
				if not System.User.isVip then
					show_vip_view("对不起，只有会员才能重新体验课程。立即加入会员，无限次体验全部课程！", "vip_wintercamp1_resign")
					return
				end	
			else
				-- 是否五校用户
				if not System.User.isVipSchool then
					-- 是否vip
					if not System.User.isVip then
						show_vip_view("对不起，本功能暂时只对会员开放。立即加入会员，一起学习生长吧！", "vip_wintercamp1_join")
						return
					end
				end

				-- 时间判断
				local is_in_time = QuestCoursePage.CheckIsInCourseTime()
				if not is_in_time then
					GameLogic.AddBBS(nil, L"请在门口课程表上指定的时间段内前来上课哟！");
					return
				end
				
				if not System.User.isVip then
					if task_data.is_finish then
						show_vip_view("对不起，您已免费体验过今日的课程。立即加入会员，无限次体验全部课程！", "vip_wintercamp1_replay")
						return
					end

					print(">>>>>>>>>>>>>>>>>>>>>>>task_data.id", task_data.id)
					local value = QuestAction.GetValue(task_data.id)
					if value >= 1 then
						show_vip_view("对不起，您已免费体验过今日的课程。立即加入会员，无限次体验全部课程！", "vip_wintercamp1_replay")
						return
					end
				end	
			end

			local httpwrapper_version = HttpWrapper.GetDevVersion() or "ONLINE"
			local target_index = VersionToKey[httpwrapper_version]
			if task_data.goto_world and #task_data.goto_world > 0 then
				local world_id = task_data.goto_world[target_index]
				if world_id then
					GameLogic.QuestAction.SetValue(task_data.id, 1);
					print("cccccccccccccccccccccccccQuestAction.GetValue(task_data.id)", QuestAction.GetValue(task_data.id))
					QuestCoursePage.EnterWorld(world_id)
				end

			-- elseif task_data.click and task_data.click ~= "" then
			-- 	NPL.DoString(task_data.click)
			end
			GameLogic.GetFilters():apply_filters('user_behavior', 1, 'click.quest_action.click_go_button')
		end
	end)
end

function QuestCoursePage.GetQuestData(task_id)
	for i, v in ipairs(QuestCoursePage.TaskData) do
		if v.task_id == task_id then
			return v
		end
	end
end

function QuestCoursePage.GetTaskType(data)
	return data.type
end

function QuestCoursePage.IsOpen()
	if nil == page then
		return false
	end

	return page:IsVisible()
end

function QuestCoursePage.CheckIsTaskCompelete()
    local profile = KeepWorkItemManager.GetProfile()
    -- 是否实名认证
--    if GameLogic.GetFilters():apply_filters('service.session.is_real_name') then
--         QuestAction.SetValue("40002_1",1);
--    end 

    -- 是否新的实名认证
	if GameLogic.GetFilters():apply_filters('service.session.is_real_name') then
        QuestAction.SetValue("40006_1",1);
   end 

   -- 是否选择了学校
   if profile and profile.schoolId and profile.schoolId > 0 then
        QuestAction.SetValue("40003_1",1);
   end

   -- 是否已选择了区域
   if profile and profile.region and profile.region.hasChildren == 0 then
        QuestAction.SetValue("40004_1",1);
   end
end

function QuestCoursePage.IsRoleModel(item_data)
	if item_data and item_data.bagId == modele_bag_id then
		return true
	end

	return false
end

function QuestCoursePage.OnClikcGift(gift_data)
end

-- 获取今天是第几天
function QuestCoursePage.GetSecondDay(exid)
	if exid == nil then
		return 0
	end
	return exid - QuestCoursePage.begain_exid + 1
end

function QuestCoursePage.Close()
	if nil == page then
		return
	end
	page:CloseWindow()
	QuestCoursePage.CloseView()
end

function QuestCoursePage.ToGraduate()
	if not QuestCoursePage.IsGraduateTime() then
		return
	end

	if not QuestCoursePage.CheckIsAllCourseFinish() then
		_guihelper.MessageBox("亲爱的同学，你还没有完成全部9天课程.赶快前往张老师那里，把落下的学习进度.给补回来吧！", nil, nil,nil,nil,nil,nil,{ ok = L"我要补课", title = L"无法毕业"});
		_guihelper.MsgBoxClick_CallBack = function(res)
			if(res == _guihelper.DialogResult.OK) then
				NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/TeleportPlayerTask.lua");
				local task = MyCompany.Aries.Game.Tasks.TeleportPlayer:new({blockX = 19259, blockY = 12, blockZ = 19132})
				task:Run();	

				QuestCoursePage.Close()

				commonlib.TimerManager.SetTimeout(function()  
					local QuestCoursePage = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Quest/QuestCoursePage.lua");
					QuestCoursePage.Show(true);
				end, 1000);
			end
		end
		return
	end

end

function QuestCoursePage.IsGraduateTime()
	local second_day = QuestCoursePage.GetSecondDay(QuestCoursePage.is_always_exist_exid)
	local date_t = commonlib.copy(QuestCoursePage.begain_time_t)
	date_t.day = date_t.day + second_day - 1
	local day_weehours = os.time(date_t)

	if server_time < day_weehours then
		return false
	end

	return true
end

function QuestCoursePage.CheckIsAllCourseFinish()
	local quest_datas = QuestProvider:GetInstance().templates_map
	local exid_list = {}
	local is_all_finish = true
	for i, v in pairs(quest_datas) do
		-- 获取兑换规则
		if exid_list[v.exid] == nil and v.exid >= QuestCoursePage.begain_exid and v.exid < QuestCoursePage.end_exid then
			exid_list[v.exid] = 1
			if not QuestAction.IsFinish(v.gsid) then
				is_all_finish = false
				break
			end
		end
	end

	return is_all_finish
end

function QuestCoursePage.CheckIsInCourseTime()
	for i, v in ipairs(QuestCoursePage.CourseTimeLimit) do
		local begain_time_stamp = today_weehours + v.begain_time.min * 60 + v.begain_time.hour * 3600
		local end_time_stamp = today_weehours + v.end_time.min * 60 + v.end_time.hour * 3600

		if server_time >= begain_time_stamp and server_time <= end_time_stamp then
			return true
		end
	end

	return false
end