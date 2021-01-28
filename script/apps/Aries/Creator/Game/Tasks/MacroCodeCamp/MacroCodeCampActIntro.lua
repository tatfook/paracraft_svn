--[[
    活动页
    NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/MacroCodeCamp/MacroCodeCampActIntro.lua");
    local MacroCodeCampActIntro = commonlib.gettable("WinterCamp.MacroCodeCamp")
    MacroCodeCampActIntro.ShowView()

    local MacroCodeCampActIntro = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/MacroCodeCamp/MacroCodeCampActIntro.lua");
    MacroCodeCampActIntro.ShowView()
]]
local HttpWrapper = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/HttpWrapper.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/MacroCodeCamp/QRCodeWnd.lua");
local QRCodeWnd = commonlib.gettable("MyCompany.Aries.Creator.Game.Tasks.MacroCodeCamp.QRCodeWnd");
NPL.load("(gl)script/apps/Aries/Creator/Game/block_engine.lua");
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine")
local MacroCodeCampActIntro = NPL.export()--commonlib.gettable("WinterCamp.MacroCodeCamp")

local page 
MacroCodeCampActIntro.isEnterJoin = false
local httpwrapper_version = HttpWrapper.GetDevVersion();
local projectId = GameLogic.options:GetProjectId();
MacroCodeCampActIntro.campIds = {
    ONLINE = 41570,
    RELEASE = 1471,
}
MacroCodeCampActIntro.isShowVipBtn = false

MacroCodeCampActIntro.keepworkList = {
    ONLINE = "https://keepwork.com",
    STAGE = "http://dev.kp-para.cn",
    RELEASE = "http://rls.kp-para.cn",
    LOCAL = "http://dev.kp-para.cn"
}

function MacroCodeCampActIntro.CheckCanShow()
    -- if System.options.isDevMode then
    --     return true
    -- else 
    --     return false
    -- end
    -- local start_time = 2021-1-25 
    -- local end_time = 2021-2-21
    -- local year = 2021
    -- local month = 2
    -- local day = 7
    -- local end_time_stamp = os.time({day=day, month=month, year=year, hour=0}); 
    -- local cur_time_stamp = os.time()
    -- if cur_time_stamp >= end_time_stamp then
    --     return false
    -- end
    -- return true
    return true
end

function MacroCodeCampActIntro.OnInit()
	page = document:GetPageCtrl();
end

function MacroCodeCampActIntro.ShowView(isShowVip)
    if not MacroCodeCampActIntro.CheckCanShow() then
        return 
    end
    MacroCodeCampActIntro.isShowVipBtn = isShowVip or false
    local view_width = 1030
	local view_height = 600
    local params = {
        url = "script/apps/Aries/Creator/Game/Tasks/MacroCodeCamp/MacroCodeCampActIntro.html",
        name = "MacroCodeCampActIntro.ShowView", 
        isShowTitleBar = false,
        DestroyOnClose = true,
        style = CommonCtrl.WindowFrame.ContainerStyle,
        allowDrag = true,
        enable_esc_key = true,
        zorder = 2,
        app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key, 
        directPosition = true,
            align = "_ct",
            x = -view_width/2,
            y = -view_height/2,
            width = view_width,
            height = view_height,
    };
    System.App.Commands.Call("File.MCMLWindowFrame", params);
    MacroCodeCampActIntro.OnRefreshPage()
end

function MacroCodeCampActIntro.GetQRCodeUrl()
    local urlbase = MacroCodeCampActIntro.keepworkList[httpwrapper_version];
	local uerid = GameLogic.GetFilters():apply_filters("store_get",'user/userId');
    local url = string.format("%s/p/qr/purchase?userId=%s&from=%s",urlbase, uerid, "vip_wintercamp1_join");
    return url
end

function MacroCodeCampActIntro.ShowQRCode()  
    if QRCodeWnd then
        QRCodeWnd:Show(page:GetParentUIObject());        
    end
end

function MacroCodeCampActIntro.HideQRCode()  
    if QRCodeWnd then
        QRCodeWnd:Hide()
    end
end

function MacroCodeCampActIntro.ClosePage()
    if page then
        page:CloseWindow()
    end
    MacroCodeCampActIntro.HideQRCode() 
    MacroCodeCampActIntro.isShowVipBtn = false
    MacroCodeCampActIntro.isEnterJoin = false 
end

function MacroCodeCampActIntro.OnRefreshPage(delaytime)
    if(page)then
        page:Refresh(delaytime or 0);
    end
    MacroCodeCampActIntro.RegisterButton()
    MacroCodeCampActIntro.GetVipRestNum()
end

function MacroCodeCampActIntro.RegisterButton()    
    local parent  = page:GetParentUIObject()
    local strPath = ';NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/MacroCodeCamp/MacroCodeCampActIntro.lua")'

    local detail_btn = ParaUI.CreateUIObject("button", "ShowDetail", "_lt", 760, 80, 108, 42);
    detail_btn.visible = true
    detail_btn.onclick = string.format([[%s.OnBtnDetailClick();]],strPath)
    detail_btn.background = "Texture/Aries/Creator/keepwork/WinterCamp/btn3_108X42_32bits.png;0 0 108 42";
    parent:AddChild(detail_btn);

    if (not System.User.isVip and not System.User.isVipSchool) or MacroCodeCampActIntro.isShowVipBtn then
        local join_bt = ParaUI.CreateUIObject("button", "JoinAct", "_lt", 390, 500, 223, 80);
        join_bt.visible = true
        join_bt.background = "Texture/Aries/Creator/keepwork/WinterCamp/btn_223X80_32bits.png;0 0 223 80";
        parent:AddChild(join_bt);

        local scancode_bt = ParaUI.CreateUIObject("button", "ScanCode", "_lt", 390, 500, 223, 80);
        scancode_bt.visible = false
        scancode_bt.background = "Texture/Aries/Creator/keepwork/WinterCamp/btn2_223X80_32bits.png;0 0 223 80";
        parent:AddChild(scancode_bt);

        local textVipRest = ParaUI.CreateUIObject("button", "vip_rest", "_lt", 410, 446, 200, 80);
        textVipRest.enabled = false;
        textVipRest.text = "剩余：100名";
        textVipRest.background = "";
        textVipRest.font = "System;16;bold";
        textVipRest.visible = false
        _guihelper.SetButtonFontColor(textVipRest, "#072D4B", "#072D4B");
        parent:AddChild(textVipRest);

        join_bt.onmouseenter =  string.format([[%s.BtnJoinOnMouseEnter();]],strPath) 
        scancode_bt.onmouseleave = string.format([[%s.BtnScanCodeOnMouseLeave();]],strPath)
    end 
    local visitor_bt = ParaUI.CreateUIObject("button", "VisitorScene", "_lt", 42, 162, 208, 149);
    visitor_bt.background = "Texture/Aries/Creator/keepwork/WinterCamp/tu5_208X149_32bits.png;0 0 208 149";
    visitor_bt.onclick = string.format([[%s.OnClick(1);]],strPath)           
    visitor_bt.onmouseenter = string.format([[%s.OnMouseEnter(1);]],strPath) 
    visitor_bt.onmouseleave = string.format([[%s.OnMouseLeave(1);]],strPath)
    parent:AddChild(visitor_bt)

    local protect_bt = ParaUI.CreateUIObject("button", "ProtectSelf", "_lt", 748, 162, 208, 149);
    protect_bt.background = "Texture/Aries/Creator/keepwork/WinterCamp/tu7_208X149_32bits.png;0 0 208 149";
    protect_bt.onclick = string.format([[%s.OnClick(2);]],strPath)           
    protect_bt.onmouseenter = string.format([[%s.OnMouseEnter(2);]],strPath) 
    protect_bt.onmouseleave = string.format([[%s.OnMouseLeave(2);]],strPath)
    parent:AddChild(protect_bt)

    local programer_bt = ParaUI.CreateUIObject("button", "Programer", "_lt", 42, 386, 208, 149);
    programer_bt.background = "Texture/Aries/Creator/keepwork/WinterCamp/tu6_208X149_32bits.png;0 0 208 149";
    programer_bt.onclick = string.format([[%s.OnClick(3);]],strPath)           
    programer_bt.onmouseenter = string.format([[%s.OnMouseEnter(3);]],strPath) 
    programer_bt.onmouseleave = string.format([[%s.OnMouseLeave(3);]],strPath)
    parent:AddChild(programer_bt)

    local programerf_bt = ParaUI.CreateUIObject("button", "Programerf", "_lt", 748, 386, 208, 149);
    programerf_bt.background = "Texture/Aries/Creator/keepwork/WinterCamp/tu8_208X149_32bits.png;0 0 208 149";
    programerf_bt.onclick = string.format([[%s.OnClick(4);]],strPath)           
    programerf_bt.onmouseenter = string.format([[%s.OnMouseEnter(4);]],strPath) 
    programerf_bt.onmouseleave = string.format([[%s.OnMouseLeave(4);]],strPath)
    parent:AddChild(programerf_bt)    
end

function MacroCodeCampActIntro.OnBtnDetailClick()
    local MacroCodeCampIntro = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/MacroCodeCamp/MacroCodeCampIntro.lua");
    MacroCodeCampIntro.ShowView()
end

function MacroCodeCampActIntro.BtnJoinOnMouseEnter()
    --print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
    MacroCodeCampActIntro.isEnterJoin = true
    MacroCodeCampActIntro.OnRefreshPage()
    MacroCodeCampActIntro.ShowQRCode() 
    ParaUI.GetUIObject("JoinAct").visible = false
    ParaUI.GetUIObject("ScanCode").visible = true

    ParaUI.GetUIObject("Programerf").background = "Texture/Aries/Creator/keepwork/WinterCamp/tu4_208X149_32bits.png;0 0 208 149";
    ParaUI.GetUIObject("Programer").background = "Texture/Aries/Creator/keepwork/WinterCamp/tu2_208X149_32bits.png;0 0 208 149";
    ParaUI.GetUIObject("ProtectSelf").background = "Texture/Aries/Creator/keepwork/WinterCamp/tu3_208X149_32bits.png;0 0 208 149";
    ParaUI.GetUIObject("VisitorScene").background = "Texture/Aries/Creator/keepwork/WinterCamp/tu1_208X149_32bits.png;0 0 208 149";
end

function MacroCodeCampActIntro.BtnScanCodeOnMouseLeave()
    --print("zzzzzzzzzzzzzzzzzzzzzzzzzz")
    MacroCodeCampActIntro.isEnterJoin = false
    MacroCodeCampActIntro.OnRefreshPage()
    MacroCodeCampActIntro.HideQRCode() 
    ParaUI.GetUIObject("JoinAct").visible = true
    ParaUI.GetUIObject("ScanCode").visible = false

    ParaUI.GetUIObject("Programerf").background = "Texture/Aries/Creator/keepwork/WinterCamp/tu8_208X149_32bits.png;0 0 208 149";
    ParaUI.GetUIObject("Programer").background = "Texture/Aries/Creator/keepwork/WinterCamp/tu6_208X149_32bits.png;0 0 208 149";
    ParaUI.GetUIObject("ProtectSelf").background =  "Texture/Aries/Creator/keepwork/WinterCamp/tu7_208X149_32bits.png;0 0 208 149";
    ParaUI.GetUIObject("VisitorScene").background = "Texture/Aries/Creator/keepwork/WinterCamp/tu5_208X149_32bits.png;0 0 208 149";
end
--[[
    【云游】【防疫】【编程】:（19236,12,19250）、（19200,12,19323）、（19265,11,19147）

    用处1： 从任意世界， 传送到某个世界的指定位置。 (需要世界里面注册这个事件)
    /loadworld -inplace  530 | /sendevent globalSetPos  {x, y, z}
    
    用处2： 传密码和参数到某个世界， 让通过直接PID无法进入世界。 
    比如任务系统传送世界
    /loadworld -inplace  530 | /sendevent globalQuestLogin  {level=1, password="1234"}
]]
function MacroCodeCampActIntro.OnClick(index)
    if MacroCodeCampActIntro.CheckNeedRealName() then
        MacroCodeCampActIntro.ClosePage()
        return
    end
    local WorldCommon = commonlib.gettable("MyCompany.Aries.Creator.WorldCommon")
    local world_id = WorldCommon.GetWorldTag("kpProjectId");    
    if index == 4 then
        --print("show programer viwe")
        local MacroCodeCampMiniPro = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/MacroCodeCamp/MacroCodeCampMiniPro.lua");
        MacroCodeCampMiniPro.ShowView()
        GameLogic.GetFilters():apply_filters('user_behavior', 1, 'click.promotion.winter_camp.first_page', { from = "wintercamp_act"..index })
        return
    end
    
    -- print("OnClick data========",index,world_id)
    local campId = MacroCodeCampActIntro.campIds[httpwrapper_version]
    if tonumber(world_id) == campId then
        MacroCodeCampActIntro.DoWinterCampEvent(index)
    else
        GameLogic.RunCommand(string.format("/loadworld -force -s %d", campId));
    end
    GameLogic.GetFilters():apply_filters('user_behavior', 1, 'click.promotion.winter_camp.first_page', { from = "wintercamp_act"..index })
end

function MacroCodeCampActIntro.DoWinterCampEvent(index)
    local pos = {
        {19236,12,19250},
        {19200,12,19323},
        {19265,11,19147},
    }
   
    if index == 1 then        
        --GameLogic.RunCommand(string.format("/goto  %d %d %d", pos[index][1],pos[index][2],pos[index][3]));
        MacroCodeCampActIntro.ClosePage()
        commonlib.TimerManager.SetTimeout(function()             
            GameLogic.GetCodeGlobal():BroadcastTextEvent("PlayGuideMovies", {}, function()
                -- print("asddasdasdasdasdasdasdasdasd")
            end);
        end,1000)
    elseif index == 2 then
        GameLogic.GetCodeGlobal():BroadcastTextEvent("openUI", {name = "taskMain"}, function()
            MacroCodeCampActIntro.ClosePage()
        end);
    elseif index == 3 then 
        GameLogic.RunCommand(string.format("/goto  %d %d %d", pos[index][1],pos[index][2],pos[index][3]));
        MacroCodeCampActIntro.ClosePage()
        commonlib.TimerManager.SetTimeout(function()            
            GameLogic.QuestAction.OpenCampCourseView()
        end,500)                       
    end
end

function MacroCodeCampActIntro.OnMouseEnter(index)
    local names = {"VisitorScene","ProtectSelf","Programer","Programerf"}
    local bgs = {
        "Texture/Aries/Creator/keepwork/WinterCamp/1.png",
        "Texture/Aries/Creator/keepwork/WinterCamp/2.png",
        "Texture/Aries/Creator/keepwork/WinterCamp/3.png",
        "Texture/Aries/Creator/keepwork/WinterCamp/4.png",
    }
    -- print("OnMouseEnter data========",index)

    --ParaUI.GetUIObject(names[index]).background = bgs[index];
    
end

function MacroCodeCampActIntro.OnMouseLeave(index)
    local names = {"VisitorScene","ProtectSelf","Programer","Programerf"}
    local bgs = {
        "Texture/Aries/Creator/keepwork/WinterCamp/scene.png",
        "Texture/Aries/Creator/keepwork/WinterCamp/fy.png",
        "Texture/Aries/Creator/keepwork/WinterCamp/bc.png",
        "Texture/Aries/Creator/keepwork/WinterCamp/bb.png",     
    }
    -- print("OnMouseLeave data========",index)

    --ParaUI.GetUIObject(names[index]).background = bgs[index];
end

function MacroCodeCampActIntro.GetVipRestNum()
    if System.User.isVip then
        return
    end
    keepwork.wintercamp.restvip({},function(err, msg, data)
        print("test.GetVipRest")
        -- commonlib.echo(err);
        -- commonlib.echo(msg);
        -- commonlib.echo(data,true);
        if err == 200 then
            local viprest = data.rest
            ParaUI.GetUIObject("vip_rest").text= string.format("剩余：%d名",viprest)
            ParaUI.GetUIObject("vip_rest").visible = true
        end
    end)
end

function MacroCodeCampActIntro.CheckNeedRealName()
    if not GameLogic.GetFilters():apply_filters('service.session.is_real_name') then
        GameLogic.GetFilters():apply_filters(
            'show_certificate',
            function(result)
                if (result) then
                    -- GameLogic.AddBBS(nil, L'领取成功', 5000, '0 255 0');
                    -------------------------------------------------------
                    local DockPage = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Dock/DockPage.lua");
                    DockPage.page:Refresh(0.01)
                    GameLogic.QuestAction.AchieveTask("40006_1", 1, true)
                end
            end
        );
        return true
    end
    return false
end