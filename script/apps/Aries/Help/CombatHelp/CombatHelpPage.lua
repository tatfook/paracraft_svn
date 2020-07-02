--[[
Title: 
Author(s): Leio
Date: 2010/07/22
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Help/CombatHelp/CombatHelpPage.lua");
MyCompany.Aries.Help.CombatHelpPage.ShowPage();
------------------------------------------------------------
--]]
local CombatHelpPage = {
	pages = {
		{ width = 677, height = 483 },
		{ width = 677, height = 483 },
		{ width = 677, height = 483 },
		{ width = 677, height = 483 },
	}
};
commonlib.setfield("MyCompany.Aries.Help.CombatHelpPage", CombatHelpPage);
function CombatHelpPage.ShowPage()
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	 System.App.Commands.Call("File.MCMLWindowFrame", {
        url = "script/apps/Aries/Help/CombatHelp/CombatHelpPage.html", 
        app_key = MyCompany.Aries.app.app_key, 
        name = "CombatHelpPage.ShowPage", 
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
function CombatHelpPage.ShowPage_Frame(index)
	local self = CombatHelpPage;
	if(not index)then return end
	local url = string.format("script/apps/Aries/Help/CombatHelp/CombatHelpPage_Frame_%d.html",index);
	local page = self.pages[index];
	if(not page)then return end
	local width = page.width;
	local height = page.height;
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	 System.App.Commands.Call("File.MCMLWindowFrame", {
        url = url, 
        app_key = MyCompany.Aries.app.app_key, 
        name = "CombatHelpPage.ShowPage_"..index, 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
        style = style,
        zorder = 2,
        allowDrag = false,
		isTopLevel = true,
        directPosition = true,
            align = "_ct",
            x = -width/2,
            y = -height/2,
            width = width,
            height = height,
    });
end
