--[[
    Title: keepwork.scancode.test
    Author(s): pbb
    Date: 2021/1/19
    Desc: 主要测试生成二维码 和 小程序码  
    Use Lib:
    -------------------------------------------------------
    local test = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/test/keepwork.scancode.test.lua");
    test.GenerateQRcode()
    test.GenerateBindWxacode("FY")
]]
local KeepWorkItemManager = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/KeepWorkItemManager.lua");
NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/KeepWorkAPI.lua");
local test = NPL.export()


function test.GenerateQRcode()
    keepwork.qrcode.generateQR({
        text = "https://www.baidu.com"
    },function(err, msg, data)
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data,true); 
    end)   
end

--situation FY:防疫; BB：程序员爸爸成长日记
function test.GenerateBindWxacode(situation)
    local profile = KeepWorkItemManager.GetProfile()
    local wxacodes = profile.wxacodes or ""
    local isFind = false
    if #wxacodes > 0 then
        --print("url==========",wxacode)
        for i = 1,#wxacodes do
            if wxacodes[i].situation == situation then
                print("url==========",wxacodes[i].wxacode)
                isFind = true
                break
            end
        end       
    end  
    if not isFind then
        keepwork.user.bindWxacode({
            situation = situation
        },function(err, msg, data)
            commonlib.echo(err);
            commonlib.echo(msg);
            commonlib.echo(data,true);  
            if err == 200 then
                KeepWorkItemManager.LoadProfile(true, function()  --刷新用户信息                  
                    GameLogic.GetFilters():apply_filters('login_with_token')
               end)
            end
        end)
    end    
end