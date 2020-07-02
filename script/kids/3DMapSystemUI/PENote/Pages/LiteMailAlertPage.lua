--[[
Title: 
Author(s): Leio
Date: 2009/11/16
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/PENote/Pages/LiteMailAlertPage.lua");
Map3DSystem.App.PENote.LiteMailAlertPage.ShowPage();
-------------------------------------------------------
]]
-- default member attributes
local LiteMailAlertPage = {
	page = nil,

}
commonlib.setfield("Map3DSystem.App.PENote.LiteMailAlertPage",LiteMailAlertPage);

function LiteMailAlertPage.OnInit()
	local self = LiteMailAlertPage;
	self.page = document:GetPageCtrl();
end
function LiteMailAlertPage.ShowPage()
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/kids/3DMapSystemUI/PENote/Pages/LiteMailAlertPage.html", 
			name = "LiteMailAlertPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			--app_key=MyCompany.Taurus.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 4,
			isTopLevel = true,
			allowDrag = false,
			directPosition = true,
				align = "_ct",
				x = -180,
				y = -185,
				width = 360,
				height = 270,
		});
end
function LiteMailAlertPage.ClosePage()
	local self = LiteMailAlertPage;
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="LiteMailAlertPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			bShow = false,bDestroy = true,});
end