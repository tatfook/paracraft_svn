--[[
Title: 
Author(s): Leio
Date: 2010/02/02
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Help/HelpPaper.lua");
local msg = {
	pages = MyCompany.Aries.Help.HelpPaper.AllPages["family_help"],
}
MyCompany.Aries.Help.HelpPaper.ShowPage(msg)
------------------------------------------------------------
--]]

local HelpPaper = {
	index = 1,
	pages = nil,
};
commonlib.setfield("MyCompany.Aries.Help.HelpPaper", HelpPaper);
HelpPaper.AllPages = {
	["pet_help"] = {
		"script/apps/Aries/Help/Pages/HelpPet_Frame1.html",
		"script/apps/Aries/Help/Pages/HelpPet_Frame2.html",
	},
	["role_help"] = {
		"script/apps/Aries/Help/Pages/HelpRole_Frame1.html",
	},
	["family_help"] = {
		"script/apps/Aries/Help/Pages/HelpFamily_Frame1.html",
	},
}
function HelpPaper.OnInit()
	local self = HelpPaper;
	self.pageCtrl = document:GetPageCtrl();
end
function HelpPaper.ShowPage(msg)
	local self = HelpPaper;
	self.pages = msg.pages;
	self.index = 1;
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	 System.App.Commands.Call("File.MCMLWindowFrame", {
        url = "script/apps/Aries/Help/HelpPaper.html", 
        app_key = MyCompany.Aries.app.app_key, 
        name = "HelpPaper.ShowPage", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
        style = style,
        zorder = 2,
        allowDrag = false,
		isTopLevel = true,
        directPosition = true,
            align = "_ct",
            x = -800/2,
            y = -600/2,
            width = 800,
            height = 600,
    });
    self.RefreshPage();
end
function HelpPaper.ClosePage(msg)
	local self = HelpPaper;
	if(self.pageCtrl)then
		self.pageCtrl:CloseWindow();
	end
end
function HelpPaper.RefreshPage()
	local self = HelpPaper;
	if(self.pageCtrl)then
		local url = self.GetCurFrameURL();
		self.pageCtrl:SetValue("contentframe",url);
		self.pageCtrl:Refresh(0.01);
	end
end
function HelpPaper.Count()
	local self = HelpPaper;
	if(self.pages)then
		return #self.pages;
	end
	return 0;
end
function HelpPaper.IsFirstPage()
	local self = HelpPaper;
    if(self.index == 1)then
        return true;
    end
end

function HelpPaper.IsLastPage()
	local self = HelpPaper;
    if(self.index >= self.Count())then
        return true;
    end
end
function HelpPaper.PrePage()
	local self = HelpPaper;
    if(not self.IsFirstPage())then
        self.index = self.index - 1;
        self.RefreshPage();
    end
end
function HelpPaper.NextPage()
	local self = HelpPaper;
    if(not self.IsLastPage())then
        self.index = self.index + 1;
        self.RefreshPage();
    end
end
function HelpPaper.GetCurFrameURL()
	local self = HelpPaper;
	local url;
	if(self.pages)then
		url = self.pages[self.index];
	end
	return url or "";
end