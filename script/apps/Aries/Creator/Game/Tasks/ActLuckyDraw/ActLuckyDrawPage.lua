--[[
Title: ActLuckyDrawPage
Author(s): yangguiyi
Date: 2020/9/22
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/ActLuckyDraw/ActLuckyDrawPage.lua").Show();
--]]

local ActLuckyDrawPage = NPL.export();
NPL.load("(gl)script/ide/Transitions/Tween.lua");
local page;
ActLuckyDrawPage.Current_Item_DS = {};
ActLuckyDrawPage.draw_bt_enable = true
ActLuckyDrawPage.id = 0
function ActLuckyDrawPage.OnInit()
    page = document:GetPageCtrl();
    page.OnClose = ActLuckyDrawPage.CloseView

	-- local _minimap = ParaUI.CreateUIObject("container", "ImgTable", "_ct", -168 - 3, 3, 400, 400);
	-- _minimap.background = "Texture/Aries/Creator/keepwork/ActLuckyDrawPage/timg.png;0 0 1020 1020";
    -- _minimap.zorder = -1;
    
        -- commonlib.TimerManager.SetTimeout(function()

        --     local tween=CommonCtrl.Tween:new{}
        --     tween.looping=false;
        --     tween.obj=page:FindUIControl("ImgTable");
        --     -- print("ccccccccccccc")
        --     -- commonlib.echo()
        --     tween.prop="rotation";
        --     tween.begin=0;
        --     tween.change=-30;
        --     tween.duration=5;
        --     tween:Start();

        --     local uiClt = page:FindUIControl("ImgTable");
        --     print("dddddddddddddddddd")
        --     commonlib.echo(uiClt, true)

        --     -- local _cursorText = page.GetUIObject("ImgTable");
        --     -- print("eeeeeeeeeeeeeeeee")
        --     -- commonlib.echo(_cursorText, true)
        -- end, 1000)


    


		-- tween.MotionChange=Tween_test.MotionChange;
		-- tween.MotionFinish=Tween_test.MotionFinish;	
		-- tween.MotionStop=Tween_test.MotionStop;	
		-- Tween_test.TWEEN=tween;
		-- if(Tween_test.EaseType)then 
		-- 	local str="CommonCtrl.TweenEquations."..tostring(Tween_test.EaseType);
		-- 	local f=loadstring("Tween_test.TWEEN.func="..str);
		-- 	--like this:Tween_test.TWEEN.func=TweenEquations.easeOutCubic;
		-- 	f();
			
		-- end
end

function ActLuckyDrawPage.Show()

    local function openView()
        local params = {
            url = "script/apps/Aries/Creator/Game/Tasks/ActLuckyDraw/ActLuckyDrawPage.html",
            name = "ActLuckyDrawPage.Show", 
            isShowTitleBar = false,
            DestroyOnClose = true,
            style = CommonCtrl.WindowFrame.ContainerStyle,
            allowDrag = true,
            enable_esc_key = true,
            zorder = -1,
            app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key, 
            directPosition = true,
            
            align = "_ct",
            x = -730/2,
            y = -401/2,
            width = 730,
            height = 401,
        };
        
        System.App.Commands.Call("File.MCMLWindowFrame", params);

        ActLuckyDrawPage.UpdataDrawBt()
    end

    keepwork.tatfook.lucky_load({
        activityCode = "nationalDay",
    },function(err, msg, data)
            -- print("aaaaaaaaaaaaaaaa", err, msg)
            -- commonlib.echo(data, true)
        if err == 200 then
            ActLuckyDrawPage.id = data.id
            openView()
        else
            GameLogic.AddBBS("statusBar", L"活动暂未开启!敬请期待", 5000, "0 255 0");
        end

    end)  

    -- openView()
end

function ActLuckyDrawPage.OnRefresh()
    if(page)then
        page:Refresh(0);
    end
end

function ActLuckyDrawPage.CloseView()
    ActLuckyDrawPage.ClearData()
end

function ActLuckyDrawPage.ClearData()
    ActLuckyDrawPage.Current_Item_DS = {}
end

function ActLuckyDrawPage.LuckyDraw()
    if not ActLuckyDrawPage.draw_bt_enable then
        GameLogic.AddBBS("statusBar", L"您已许愿，请等待结果", 5000, "0 255 0");
        return
    end

    ActLuckyDrawPage.draw_bt_enable = false

    keepwork.tatfook.lucky_push({
        lotteryId = ActLuckyDrawPage.id,
    },function(err, msg, data)

        if err == 200 then
            -- print("dddddddddwwwww", data.data)
            -- commonlib.echo(data, true)
    
            ActLuckyDrawPage.UpdataDrawBt()
            GameLogic.AddBBS("statusBar", L"参与抽奖成功，请静候佳音", 5000, "0 255 0");
        elseif err == 400 then
            GameLogic.AddBBS("statusBar", L"未绑定手机号不能参与抽奖", 5000, "255 0 0");
            ActLuckyDrawPage.draw_bt_enable = true
        end

    end) 
    
end

function ActLuckyDrawPage.OpenRewardList()
    local ActGetRewardList = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/ActLuckyDraw/ActGetRewardList.lua");
    ActGetRewardList.Show();

    page:CloseWindow(0)
    ActLuckyDrawPage.ClearData()
end

function ActLuckyDrawPage.UpdataDrawBt()
    keepwork.tatfook.lucky_check({
        lotteryId = ActLuckyDrawPage.id,
    },function(err, msg, data)

        if err == 200 then
            commonlib.echo(data, true)
    
            ActLuckyDrawPage.draw_bt_enable = not data.data
            ActLuckyDrawPage.OnRefresh()
        end

    end)  
end
