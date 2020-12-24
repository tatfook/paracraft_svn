--[[
    Title: keepwork.qrcode
    Author(s): pbb
    Date: 2020/12/24
    Desc:  
    Use Lib:
    -------------------------------------------------------
    NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/keepwork.qrcode.lua");
]]

local HttpWrapper = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/HttpWrapper.lua");

-- 生产二维码图片
--http://yapi.kp-para.cn/project/32/interface/api/3682 
HttpWrapper.Create("keepwork.qrcode.generateQR", "%MAIN%/core/v0/keepworks/generateQR", "POST", true)