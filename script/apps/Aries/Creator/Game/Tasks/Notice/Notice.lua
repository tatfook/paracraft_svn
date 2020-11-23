--[[
Title: Notice
Author(s): yangguiyi
Date: 2020/11/23
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/Notice/Notice.lua").Show();
--]]

local KeepworkServiceSession = NPL.load("(gl)Mod/WorldShare/service/KeepworkService/Session.lua")
local LoginModal = NPL.load("(gl)Mod/WorldShare/cellar/LoginModal/LoginModal.lua")
local KeepWorkItemManager = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/KeepWorkItemManager.lua");
local Notice = NPL.export();
function Notice.OnInit()
    page = document:GetPageCtrl();
    page.OnClose = Notice.CloseView
end

function Notice.Show()
    keepwork.notic.announcements({
    },function(info_err, info_msg, info_data)
        print("ggggggggggggggg", info_err)
        commonlib.echo(info_data, true)
        if info_err == 200 then
            local params = {
                url = "script/apps/Aries/Creator/Game/Tasks/Notice/Notice.html",
                name = "Notice.Show", 
                isShowTitleBar = false,
                DestroyOnClose = true,
                style = CommonCtrl.WindowFrame.ContainerStyle,
                allowDrag = true,
                enable_esc_key = true,
                zorder = -1,
                app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key, 
                directPosition = true,
                
                align = "_ct",
                x = -700/2,
                y = -399/2,
                width = 700,
                height = 399,
            };
            
            System.App.Commands.Call("File.MCMLWindowFrame", params)
        else
        end
    end) 

end

function Notice.CloseView()
    -- body
end