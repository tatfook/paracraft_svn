--[[
Title: DockCampIcon
Author(s): yangguiyi
Date: 2021/01/28
Desc:  
Use Lib:
-------------------------------------------------------
local DockCampIcon = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Dock/DockCampIcon.lua");
DockCampIcon.Show();
--]]
local QuestCoursePage = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Quest/QuestCoursePage.lua");

local DockCampIcon = NPL.export();
local page;

DockCampIcon.leftMin = 10;
DockCampIcon.leftMax = 128;
DockCampIcon.left = DockCampIcon.leftMin;
DockCampIcon.top = -100;
DockCampIcon.width = 400;
DockCampIcon.height = 200;

function DockCampIcon.OnInit()
	page = document:GetPageCtrl();
	page.OnClose = DockCampIcon.CloseView
	page.OnCreate = DockCampIcon.OnCreate
end

function DockCampIcon.OnCreate()
end

function DockCampIcon.CloseView()
	NPL.KillTimer(10087)
end

function DockCampIcon.Show()
	DockCampIcon.ShowView()
end

function DockCampIcon.ShowView()
	if page and page:IsVisible() then
		return
	end
	
	local left = DockCampIcon.left;
	local params = {
		url = "script/apps/Aries/Creator/Game/Tasks/Dock/DockCampIcon.html",
		name = "DockCampIcon.Show",
		isShowTitleBar = false,
		DestroyOnClose = true,
		style = CommonCtrl.WindowFrame.ContainerStyle,
		allowDrag = false,
		bShow = bShow,
		zorder = -1,
		ClickThrough = true,
		enable_esc_key = false,
		cancelShowAnimation = true,
		directPosition = true,
			align = "_ctl",
			x = left,
			y = DockCampIcon.top,
			width = DockCampIcon.width,
			height = DockCampIcon.height,
	};
	System.App.Commands.Call("File.MCMLWindowFrame", params);

	NPL.SetTimer(10087, 3, ';NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Dock/DockCampIcon.lua").UpdateTime()');
end

function DockCampIcon.UpdateTime()
	if page and not page:IsVisible() then
		DockCampIcon.CloseView()
		return
	end
	
	page:SetUIValue("cur_time", os.date("%H:%M"))

	local begain_day_weehours = os.time(QuestCoursePage.begain_time_t)
	if os.time() < begain_day_weehours then
		page:SetUIValue("cur_state", "自由探索")
	else
		local cur_time_stamp = os.time()
		if QuestCoursePage.IsGraduateTime(cur_time_stamp) then
			page:SetUIValue("cur_state", "自由探索")
		else
			local cur_state = QuestCoursePage.CheckCourseTimeState(cur_time_stamp)
			local desc = cur_state == QuestCoursePage.ToCourseState.in_time and "上课" or "自由探索"
			page:SetUIValue("cur_state", desc)
		end
	end	
end