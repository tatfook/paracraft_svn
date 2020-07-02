--[[
Title: 
Author(s): Leio
Date: 2009/8/20
Desc:
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/FreeGrab/Pages/FreeGrabOptionPage.lua");
-------------------------------------------------------
]]
local FreeGrabOptionPage = {
	name = "FreeGrabOptionPage",
	grab_manager = nil,
	free_grab = nil,
	
};
commonlib.setfield("Map3DSystem.App.FreeGrab.FreeGrabOptionPage", FreeGrabOptionPage);
function FreeGrabOptionPage.Bind(grab_manager,free_grab)
	local self = FreeGrabOptionPage;
	self.grab_manager = grab_manager;
	self.free_grab = free_grab;
end
function FreeGrabOptionPage.ShowPage()
	local self = FreeGrabOptionPage;
	local align,left,top,width,height = "_ct",-320,-250,720,480;
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/kids/3DMapSystemUI/FreeGrab/Pages/FreeGrabOptionPage.html", 
			name = self.name.."ShowPage", 
			app_key = Map3DSystem.App.FreeGrab.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			directPosition = true,
				align = align,
				x = left,
				y = top,
				width = width,
				height = height,
		});
	
end
function FreeGrabOptionPage.ClosePage()
	local self = FreeGrabOptionPage;
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name = self.name.."ShowPage", 
		app_key = Map3DSystem.App.FreeGrab.app.app_key, 
		bShow = false,bDestroy = true,});
end
function FreeGrabOptionPage.DoResume()
	local self = FreeGrabOptionPage;
	self.grab_manager:Resume();
	self.ClosePage();
end
function FreeGrabOptionPage.DoMain()
	local self = FreeGrabOptionPage;
	self.grab_manager:Stop();
	self.ClosePage();
	NPL.load("(gl)script/kids/3DMapSystemUI/FreeGrab/Pages/FreeGrabMainPage.lua");
	Map3DSystem.App.FreeGrab.FreeGrabMainPage.Bind(self.grab_manager,self.free_grab)
	Map3DSystem.App.FreeGrab.FreeGrabMainPage.ShowPage();
end