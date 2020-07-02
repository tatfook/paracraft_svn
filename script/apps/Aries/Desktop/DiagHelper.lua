--[[
Title: code behind for diagnostic helper
Author(s): WD
Date: 2012/03/23

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/DiagHelper.lua");
MyCompany.Aries.Desktop.DiagHelper.ShowPage();
--]]

local DiagHelper = commonlib.gettable("MyCompany.Aries.Desktop.DiagHelper");


function DiagHelper:Init()
	self.page = document.GetPageCtrl();
end
 
function DiagHelper.ShowPage()
	local width,height = 760,470;


	local params = {
        url = "script/apps/Aries/Desktop/DiagHelper.html", 
        app_key = MyCompany.Aries.app.app_key, 
        name = "DiagHelper.ShowPage", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
        style = CommonCtrl.WindowFrame.ContainerStyle,
		enable_esc_key = true,
        allowDrag = true,
		isTopLevel = false,
        directPosition = true,
        align = "_ct",
		x = -width * .5,
		y = -height * .5,
        width = width,
        height = height,}
    System.App.Commands.Call("File.MCMLWindowFrame", params);
	if(params._page)then
		params._page.OnClose = DiagHelper.Clean;
	end

end

function DiagHelper.Clean()


end

function DiagHelper.CloseWindow()
	if(DiagHelper.page)then
		DiagHelper.page:CloseWindow();
	end
end

