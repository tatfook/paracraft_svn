--[[
    local ActRedhat = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/ActRedhat/ActRedhat.lua")
    ActRedhat.ShowPage()
]]

local KeepWorkItemManager = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/KeepWorkItemManager.lua");
local ActRedhat = NPL.export()

local hat_gisd = 90000
local maxHatNum = 200
local my_hat = 0
local page

function ActRedhat.ShowPage()
    local twidth = 470
    local theight = 350
    local params = {
        url = "script/apps/Aries/Creator/Game/Tasks/ActRedhat/ActRedhat.html",
        name = "ActRedhat.ShowPage", 
        isShowTitleBar = false,
        DestroyOnClose = true,
        style = CommonCtrl.WindowFrame.ContainerStyle,
        allowDrag = true,
        enable_esc_key = true,
        zorder = -1,
        app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key, 
        directPosition = true,                
        align = "_ct",
        x = -twidth/2,
        y = -theight/2,
        width = twidth,
        height = theight,
    };                
    System.App.Commands.Call("File.MCMLWindowFrame", params)            
end

function ActRedhat.OnInit()
	page = document:GetPageCtrl();
end

function ActRedhat.getLeftHat()
    local bHas,guid,bagid,copies = KeepWorkItemManager.HasGSItem(hat_gisd)
	my_hat = copies or 0;

	return my_hat
end

function ActRedhat.OnClickOk()
    if page then
        page:CloseWindow(0)
    end
end

function ActRedhat:getExcDesc()
    local str = string.format("恭喜获得爷爷的帽子X1，当前拥有的帽子总数%d/%d",ActRedhat.getLeftHat(),maxHatNum)
    return str
end

