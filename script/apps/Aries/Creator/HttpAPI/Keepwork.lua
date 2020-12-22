--[[
Title: keepwork
Author(s): wxa
Date: 2020/12/22
Desc: 后端数据语义化
Use Lib: 
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/Keepwork.lua");
]]

local KeepWorkItemManager = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/KeepWorkItemManager.lua");

local Keepwork = NPL.export();

-- 获取用户信息
function Keepwork:GetUserInfo()
    return KeepWorkItemManager.GetProfile();
end

-- 是否首次登录
function Keepwork:IsFirstLoginParacraft()
    local bExist = KeepWorkItemManager.HasGSItem(37);
    return not bExist;
end

-- 首次登录回调
function Keepwork:FirstLoginCallback()
    local userinfo = self:GetUserInfo();
    
    userinfo.extra = userinfo.extra or {};
    userinfo.extra.ParacraftPlayerEntityInfo = userinfo.extra.ParacraftPlayerEntityInfo or {};
    userinfo.extra.ParacraftPlayerEntityInfo.asset = userinfo.extra.ParacraftPlayerEntityInfo.asset or "character/CC/02human/paperman/boy01.x";
    -- 本地化主角模型 
    GameLogic.options:SetMainPlayerAssetName(userinfo.extra.ParacraftPlayerEntityInfo.asset);    
    -- 将默认模型提交至服务器
    keepwork.user.setinfo({
        router_params = {id = userinfo.id},
        extra = userinfo.extra,
    }, function(status, msg, data) 
        if (status < 200 or status >= 300) then 
            LOG.std(nil, "error", "Keepwork", "更新玩家信息失败");
        end
    end);
end

-- 用户登录成功
function Keepwork:OnLogin()
    if (self:IsFirstLoginParacraft()) then
        self:FirstLoginCallback();
    end
end

function Keepwork:OnLogout()
end
