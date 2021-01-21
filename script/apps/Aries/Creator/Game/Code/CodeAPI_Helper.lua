--[[
Title: CodeAPI
Author(s): wxa
Date: 2018/6/8
Desc: sandbox API environment
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Code/CodeAPI_Helper.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/Code/CodeUI.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Code/CodeGlobals.lua");
local CodeGlobals = commonlib.gettable("MyCompany.Aries.Game.Code.CodeGlobals");
local CodeUI = commonlib.gettable("MyCompany.Aries.Game.Code.CodeUI");
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic");
local env_imp = commonlib.gettable("MyCompany.Aries.Game.Code.env_imp");

-- 获取客户端环境
function env_imp:getEnv()
    return string.lower(ParaEngine.GetAppCommandLineByParam("env", "online"));
end
