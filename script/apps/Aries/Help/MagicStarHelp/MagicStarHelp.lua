--[[
Title: 
Author(s): Spring
Date: 2010/10/27
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Help/MagicStarHelp/MagicStarHelp.lua");
MyCompany.Aries.Help.MagicStarHelp.ShowPage();
------------------------------------------------------------
--]]
local MagicStarHelp = commonlib.gettable("MyCompany.Aries.Help.MagicStarHelp");
function MagicStarHelp.ShowPage()
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	 System.App.Commands.Call("File.MCMLWindowFrame", {
        url = "script/apps/Aries/Help/MagicStarHelp/MagicStarHelp.html", 
        app_key = MyCompany.Aries.app.app_key, 
        name = "MagicStarHelp.ShowPage", 
        isShowTitleBar = false,
		bToggleShowHide = true,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
        style = style,
        zorder = 2,
        allowDrag = false,
		isTopLevel = true,
		enable_esc_key = true,
        directPosition = true,
            align = "_ct",
            x = -762/2,
            y = -488/2,
            width = 762,
            height = 487,
    });
end
