--[[
    NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/MacroCodeCamp/MacroCodeCampMiniPro.lua");
    local MacroCodeCampMiniPro = commonlib.gettable("WinterCamp.MacroCodeCamp")
    MacroCodeCampMiniPro.ShowView()

    local MacroCodeCampMiniPro = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/MacroCodeCamp/MacroCodeCampMiniPro.lua");
    MacroCodeCampMiniPro.ShowView()
]]
local HttpWrapper = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/HttpWrapper.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/MacroCodeCamp/QRCodeWnd.lua");
local QRCodeWnd = commonlib.gettable("MyCompany.Aries.Creator.Game.Tasks.MacroCodeCamp.QRCodeWnd");
local MacroCodeCampMiniPro = NPL.export()--commonlib.gettable("WinterCamp.MacroCodeCamp")

local page 

function MacroCodeCampMiniPro.OnInit()
	page = document:GetPageCtrl();
end

function MacroCodeCampMiniPro.ShowView()
    local view_width = 450
	local view_height = 410
    local params = {
        url = "script/apps/Aries/Creator/Game/Tasks/MacroCodeCamp/MacroCodeCampMiniPro.html",
        name = "MacroCodeCampMiniPro.ShowView", 
        isShowTitleBar = false,
        DestroyOnClose = true,
        style = CommonCtrl.WindowFrame.ContainerStyle,
        allowDrag = false,
        enable_esc_key = true,
        zorder = 3,
        app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key, 
        directPosition = true,
            align = "_ct",
            x = -view_width/2,
            y = -view_height/2,
            width = view_width,
            height = view_height,
    };
    System.App.Commands.Call("File.MCMLWindowFrame", params);   
end