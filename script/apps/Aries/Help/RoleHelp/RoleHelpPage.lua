--[[
Title: 
Author(s): Leio
Date: 2010/03/03
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Help/RoleHelp/RoleHelpPage.lua");
MyCompany.Aries.Help.RoleHelpPage.ShowPage();
------------------------------------------------------------
--]]
local RoleHelpPage = {
	pages = {
		{ width = 677, height = 404 },
		{ width = 677, height = 483 },
		{ width = 677, height = 483 },
	}
};
commonlib.setfield("MyCompany.Aries.Help.RoleHelpPage", RoleHelpPage);
function RoleHelpPage.ShowPage()
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	 System.App.Commands.Call("File.MCMLWindowFrame", {
        url = "script/apps/Aries/Help/RoleHelp/RoleHelpPage.html", 
        app_key = MyCompany.Aries.app.app_key, 
        name = "RoleHelpPage.ShowPage", 
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
function RoleHelpPage.ShowPage_Frame(index)
	local self = RoleHelpPage;
	if(not index)then return end
	local url = string.format("script/apps/Aries/Help/RoleHelp/RoleHelpPage_Frame_%d.html",index);
	local page = self.pages[index];
	if(not page)then return end
	local width = page.width;
	local height = page.height;
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	 System.App.Commands.Call("File.MCMLWindowFrame", {
        url = url, 
        app_key = MyCompany.Aries.app.app_key, 
        name = "RoleHelpPage.ShowPage_"..index, 
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
