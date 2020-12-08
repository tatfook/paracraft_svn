--[[
Title: keepwork.quest
Author(s): leio
Date: 2020/12/8
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/keepwork.quest.lua");
]]

local HttpWrapper = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/HttpWrapper.lua");

--http://yapi.kp-para.cn/project/32/interface/api/3662
-- 获取用户任务进度记录
HttpWrapper.Create("keepwork.questitem.list", "%MAIN%/core/v0//users/taskRecords", "GET", true)

--http://yapi.kp-para.cn/project/32/interface/api/3657
-- 用户任务进度记录
HttpWrapper.Create("keepwork.questitem.save", "%MAIN%/core/v0/users/taskRecords", "POST", true)

