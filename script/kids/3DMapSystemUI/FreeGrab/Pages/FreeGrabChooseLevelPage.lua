--[[
Title: 
Author(s): Leio
Date: 2009/8/20
Desc:
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/FreeGrab/Pages/FreeGrabChooseLevelPage.lua");
-------------------------------------------------------
]]
local FreeGrabChooseLevelPage = {
	name = "FreeGrabChooseLevelPage",
	grab_manager = nil,
	free_grab = nil,
	
};
commonlib.setfield("Map3DSystem.App.FreeGrab.FreeGrabChooseLevelPage", FreeGrabChooseLevelPage);
function FreeGrabChooseLevelPage.Bind(grab_manager,free_grab)
	local self = FreeGrabChooseLevelPage;
	self.grab_manager = grab_manager;
	self.free_grab = free_grab;
	self.items = free_grab:GetAllLevelDescriptor();
end
function FreeGrabChooseLevelPage.DS_Func_Items(index)
	local self = FreeGrabChooseLevelPage;
	if(not self.items)then return 0 end
	if(index == nil) then
		return #(self.items);
	else
		return self.items[index];
	end
end
function FreeGrabChooseLevelPage.ShowPage()
	local self = FreeGrabChooseLevelPage;
	local align,left,top,width,height = "_ct",-320,-250,720,480;
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/kids/3DMapSystemUI/FreeGrab/Pages/FreeGrabChooseLevelPage.html", 
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
function FreeGrabChooseLevelPage.ClosePage()
	local self = FreeGrabChooseLevelPage;
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name = self.name.."ShowPage", 
		app_key = Map3DSystem.App.FreeGrab.app.app_key, 
		bShow = false,bDestroy = true,});
end
function FreeGrabChooseLevelPage.DoClick(level)
	level = tonumber(level);
	local self = FreeGrabChooseLevelPage;
	if(self.free_grab and level)then
		self.ClosePage();
		self.grab_manager:Play(level);
	end
end