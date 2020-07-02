--[[
Title: 
Author(s): Leio
Date: 2010/03/03
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Help/PetHelp/PetHelpPage.lua");
MyCompany.Aries.Help.PetHelpPage.ShowPage();
------------------------------------------------------------
--]]
local PetHelpPage = {
	pages = {
		{ width = 677, height = 483 },
		{ width = 677, height = 317 },
		{ width = 677, height = 483 },
		{ width = 677, height = 441 },
	}
};
commonlib.setfield("MyCompany.Aries.Help.PetHelpPage", PetHelpPage);
function PetHelpPage.ShowPage()
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	 System.App.Commands.Call("File.MCMLWindowFrame", {
        url = "script/apps/Aries/Help/PetHelp/PetHelpPage.html", 
        app_key = MyCompany.Aries.app.app_key, 
        name = "PetHelpPage.ShowPage", 
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
function PetHelpPage.ShowPage_Frame(index)
	local self = PetHelpPage;
	if(not index)then return end
	local url = string.format("script/apps/Aries/Help/PetHelp/PetHelpPage_Frame_%d.html",index);
	local page = self.pages[index];
	if(not page)then return end
	local width = page.width;
	local height = page.height;
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	 System.App.Commands.Call("File.MCMLWindowFrame", {
        url = url, 
        app_key = MyCompany.Aries.app.app_key, 
        name = "PetHelpPage.ShowPage_"..index, 
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
