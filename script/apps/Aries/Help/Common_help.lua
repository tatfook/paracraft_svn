--[[
Title: 
Author(s): Spring
Date: 2010/12/15
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Help/Common_help.lua");
------------------------------------------------------------
--]]
local Common_help = commonlib.gettable("MyCompany.Aries.Help.Common_help");

function Common_help.CombatPetHelp_ShowPage()
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	 System.App.Commands.Call("File.MCMLWindowFrame", {
        url = "script/apps/Aries/Help/CombatPetHelp/CombatPetHelp.html", 
        app_key = MyCompany.Aries.app.app_key, 
        name = "Common_help.CombatPetHelp_ShowPage", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
        style = style,
        zorder = 2,
        allowDrag = false,
		isTopLevel = true,
        directPosition = true,
            align = "_ct",
            x = -700/2,
            y = -520/2,
            width = 700,
            height = 520,
    });
end

function Common_help.ShopHelp_ShowPage()
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	 System.App.Commands.Call("File.MCMLWindowFrame", {
        url = "script/apps/Aries/Help/ShopHelp/ShopHelp.html", 
        app_key = MyCompany.Aries.app.app_key, 
        name = "Common_help.ShopHelp_ShowPage", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
        style = style,
        zorder = 2,
        allowDrag = false,
		isTopLevel = true,
        directPosition = true,
            align = "_ct",
            x = -700/2,
            y = -450/2,
            width = 700,
            height = 450,
    });
end

function Common_help.GemHelp_ShowPage()
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	 System.App.Commands.Call("File.MCMLWindowFrame", {
        url = "script/apps/Aries/Help/GemHelp/GemHelp.html", 
        app_key = MyCompany.Aries.app.app_key, 
        name = "Common_help.GemHelp_ShowPage", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
        style = style,
        zorder = 2,
        allowDrag = false,
		isTopLevel = true,
        directPosition = true,
            align = "_ct",
            x = -700/2,
            y = -470/2,
            width = 700,
            height = 470,
    });
end