--[[
    活动详情也
    local MacroCodeCampIntro = NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/MacroCodeCamp/MacroCodeCampIntro.lua");
    MacroCodeCampIntro.ShowView()
]]
local MacroCodeCampIntro = NPL.export()--commonlib.gettable("WinterCamp.MacroCodeCamp")

local page 
MacroCodeCampIntro.data = {{}}
function MacroCodeCampIntro.OnInit()
	page = document:GetPageCtrl();
end

function MacroCodeCampIntro.ShowView()
    local view_width = 820
	local view_height = 560
    local params = {
        url = "script/apps/Aries/Creator/Game/Tasks/MacroCodeCamp/MacroCodeCampIntro.html",
        name = "MacroCodeCampIntro.ShowView", 
        isShowTitleBar = false,
        DestroyOnClose = true,
        style = CommonCtrl.WindowFrame.ContainerStyle,
        allowDrag = true,
        enable_esc_key = true,
        zorder = 4,
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