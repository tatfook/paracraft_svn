--[[
Title: 
Author(s): Leio
Date: 2009/8/20
Desc:
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/FreeGrab/Pages/FreeGrabMainPage.lua");
-------------------------------------------------------
]]
local FreeGrabMainPage = {
	name = "FreeGrabMainPage",
	grab_manager = nil,
	free_grab = nil
};
commonlib.setfield("Map3DSystem.App.FreeGrab.FreeGrabMainPage", FreeGrabMainPage);
function FreeGrabMainPage.Bind(grab_manager,free_grab)
	local self = FreeGrabMainPage;
	self.grab_manager = grab_manager;
	self.free_grab = free_grab;
end
function FreeGrabMainPage.Return()
	local self = FreeGrabMainPage;
	if(self and self.free_grab)then
		local page_state = self.grab_manager.last_page_state;
		self.grab_manager:ShowPage(page_state)
	end
end
function FreeGrabMainPage.PlayNow()
	local self = FreeGrabMainPage;
	if(self and self.grab_manager)then
		self.grab_manager:Play(1);
		self.ClosePage()
	end
end
function FreeGrabMainPage.ChooseLevel()
	local self = FreeGrabMainPage;
	local page_state = "choose_level";
	self.ShowChildPage(page_state);
end
function FreeGrabMainPage.OptionPanel()
	local self = FreeGrabMainPage;
	local page_state = "option";
	self.ShowChildPage(page_state);
end
function FreeGrabMainPage.HighScores()
	local self = FreeGrabMainPage;
	local page_state = "high_score";
	self.ShowChildPage(page_state);
end
function FreeGrabMainPage.MyScores()
	local self = FreeGrabMainPage;
	local page_state = "my_score";
	self.ShowChildPage(page_state);
end
function FreeGrabMainPage.Help()
	local self = FreeGrabMainPage;
	local page_state = "help";
	self.ShowChildPage(page_state);
end
function FreeGrabMainPage.Away()
	local self = FreeGrabMainPage;
	if(self and self.grab_manager)then
		self.grab_manager:Away();
	end
end
function FreeGrabMainPage.ShowPage()
	local self = FreeGrabMainPage;
	local align,left,top,width,height = "_ct",0,0,1020,680;
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/kids/3DMapSystemUI/FreeGrab/Pages/FreeGrabMainPage.html", 
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
function FreeGrabMainPage.ClosePage()
	local self = FreeGrabMainPage;
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name = self.name.."ShowPage", 
		app_key = Map3DSystem.App.FreeGrab.app.app_key, 
		bShow = false,bDestroy = true,});
end
function FreeGrabMainPage.ShowChildPage(page_state)
	local self = FreeGrabMainPage;
	if(not page_state)then return end
	if(page_state == "choose_level")then
		NPL.load("(gl)script/kids/3DMapSystemUI/FreeGrab/Pages/FreeGrabChooseLevelPage.lua");
		self.curShowPage = Map3DSystem.App.FreeGrab.FreeGrabChooseLevelPage;
	elseif(page_state == "option")then
		self.curShowPage = Map3DSystem.App.FreeGrab.FreeGrabOptionPage;
	elseif(page_state == "high_score")then
		self.curShowPage = Map3DSystem.App.FreeGrab.FreeGrabHighScoresPage;
	elseif(page_state == "my_score")then
		self.curShowPage = Map3DSystem.App.FreeGrab.FreeGrabMyScoresPage;
	elseif(page_state == "help")then
		self.curShowPage = Map3DSystem.App.FreeGrab.FreeGrabMyHelpPage;
	end
	if(self.curShowPage)then
		self.curShowPage.Bind(self.grab_manager,self.free_grab);
		self.curShowPage.ShowPage();
	end
end
function FreeGrabMainPage.CloseChildPage()
	local self = FreeGrabMainPage;
	if(self.curShowPage)then
		self.curShowPage.ClosePage();
	end
end