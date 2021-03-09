--[[
Title: QuestWork
Author(s): yangguiyi
Date: 2021/3/3
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Quest/QuestWork.lua").Show();
--]]
local KeepWorkItemManager = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/KeepWorkItemManager.lua");
local HttpWrapper = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/HttpWrapper.lua");
local QuestPage = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Quest/QuestPage.lua");
local QuestAction = commonlib.gettable("MyCompany.Aries.Game.Tasks.Quest.QuestAction");
local QuestWork = NPL.export();
local page
local server_time = 0

QuestWork.TypeIndex = 1

QuestWork.WorkData = {
    {name = "作业标题", desc = 0,}
}

function QuestWork.OnInit()
    page = document:GetPageCtrl();
    page.OnClose = QuestWork.CloseView
end

function QuestWork.Show()
    QuestWork.TypeIndex = 1
    QuestWork.GetWorkList(QuestWork.ShowView)
end

function QuestWork.GetWorkList(cb)
    local status = QuestWork.TypeIndex == 1 and 0 or 1
    keepwork.quest_work_list.get({
        status = status, -- 0,未完成；1已完成
    },function(err, msg, data)
        print("dddddddddddddddd")
        echo(data, true)
        if err == 200 then
            local list_data = {}
            for i, v in ipairs(data.rows) do
                if v.aiHomework then
                    list_data[#list_data + 1] = v
                end
            end
            QuestWork.HandleData(list_data)
            if cb then
                cb()
            end
        end
    end)
end

function QuestWork.ShowView()
    if page and page:IsVisible() then
        return
    end
    
    
    local params = {
        url = "script/apps/Aries/Creator/Game/Tasks/Quest/QuestWork.html",
        name = "QuestWork.Show", 
        isShowTitleBar = false,
        DestroyOnClose = true,
        style = CommonCtrl.WindowFrame.ContainerStyle,
        allowDrag = true,
        enable_esc_key = true,
        zorder = 0,
        app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key, 
        directPosition = true,
        
        align = "_ct",
        x = -960/2,
        y = -580/2,
        width = 960,
        height = 580,
    };
    System.App.Commands.Call("File.MCMLWindowFrame", params);
end

function QuestWork.FreshView()
    local parent  = page:GetParentUIObject()
end

function QuestWork.OnRefresh()
    if(page)then
        page:Refresh(0);
    end
    QuestWork.FreshView()
end

function QuestWork.CloseView()
    QuestWork.ClearData()
end

function QuestWork.ClearData()
end

function QuestWork.HandleData(data)
    QuestWork.WorkData = {}
    QuestWork.ServerDataList = data
    for i, v in ipairs(data) do
        local item_data = {}
        local aiHomework = v.aiHomework
        item_data.name = aiHomework.name
        item_data.desc = aiHomework.description
        local time_stamp = commonlib.timehelp.GetTimeStampByDateTime(v.createdAt) 
        item_data.time_desc = os.date("%Y.%m.%d",time_stamp)

        QuestWork.WorkData[#QuestWork.WorkData + 1] = item_data
    end
end

function QuestWork.OnChangeType(index)
    index = tonumber(index)
    if index == QuestWork.TypeIndex then
        return
    end

    QuestWork.TypeIndex = index
    QuestWork.GetWorkList(QuestWork.OnRefresh)
end

function QuestWork.ToWork(index)
    local data = QuestWork.ServerDataList[index]
    print("aaaaaaaaaaa", index, type(index), data)
    if nil == data then
        return
    end

    if data.aiHomework == nil then
        return
    end

    local work_data = data.aiHomework
    local type = work_data.type -- 0：更新世界类型，1：更新家园，2：作业世界
    
    if type == 0 then
        page:CloseWindow()
        QuestWork.CloseView()
        GameLogic.GetFilters():apply_filters('show_create_page')
    elseif type == 1 then
        page:CloseWindow()
        QuestWork.CloseView()
        local WorldCommon = commonlib.gettable("MyCompany.Aries.Creator.WorldCommon")

        NPL.load("(gl)script/apps/Aries/Creator/Game/Login/LocalLoadWorld.lua");
        local LocalLoadWorld = commonlib.gettable("MyCompany.Aries.Game.MainLogin.LocalLoadWorld")
        LocalLoadWorld.CreateGetHomeWorld();

        GameLogic.GetFilters():apply_filters('check_and_updated_before_enter_my_home', function()
            GameLogic.RunCommand("/loadworld home");
        end)
    else
        if work_data.projectId then
            page:CloseWindow()
            QuestWork.CloseView()
            local command = string.format("/loadworld -s -force %s", work_data.projectId)
            local CommandManager = commonlib.gettable("MyCompany.Aries.Game.CommandManager")
            local client_data = QuestAction.GetClientData()
    
            client_data.course_id = work_data.aiCourseId
            client_data.home_work_id = work_data.id

            KeepWorkItemManager.SetClientData(QuestAction.task_gsid, client_data)
            
            page:CloseWindow()
            QuestAllCourse.CloseView()

            CommandManager:RunCommand(command)
        end
    end
end

function QuestWork.Share(index)
    local data = QuestWork.ServerDataList[index]
    if nil == data then
        return
    end
    local work_data = data.aiHomework
    NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Quest/QuestWorkCode.lua").Show(work_data.wxacode);
end