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
        x = -564/2,
        y = -324/2,
        width = 564,
        height = 324,
    };
    
    System.App.Commands.Call("File.MCMLWindowFrame", params);
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
    print("抽奖抽奖")
end

function ActLuckyDrawPage.OpenRewardList()
    local ActGetRewardList = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/ActLuckyDraw/ActGetRewardList.lua");
    ActGetRewardList.Show();
end