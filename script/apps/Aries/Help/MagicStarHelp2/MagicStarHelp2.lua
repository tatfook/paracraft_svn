--[[
Title: 
Author(s): Leio
Date: 2010/10/28
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Help/MagicStarHelp2/MagicStarHelp2.lua");
MyCompany.Aries.Help.MagicStarHelp2.ShowPage();
------------------------------------------------------------
--]]
local MagicStarHelp2 = commonlib.gettable("MyCompany.Aries.Help.MagicStarHelp2");
function MagicStarHelp2.ShowPage()
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	 System.App.Commands.Call("File.MCMLWindowFrame", {
        url = "script/apps/Aries/Help/MagicStarHelp2/MagicStarHelp2.html", 
        app_key = MyCompany.Aries.app.app_key, 
        name = "MagicStarHelp2.ShowPage", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
        style = style,
        zorder = 2,
        allowDrag = false,
		isTopLevel = true,
        directPosition = true,
            align = "_ct",
            x = -677/2,
            y = -483/2,
            width = 677,
            height = 483,
    });
end
