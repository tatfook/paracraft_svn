--[[
Title: code behind for page MusicBox.html
Author(s): Leio
Date: 2009/12/15
Desc:  script/kids/3DMapSystemUI/HomeLand/Pages/MusicBox.html
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/Pages/MusicBox.lua");
MyCompany.Aries.Inventory.MusicBoxPage.ShowPage();
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Team/TeamWorldInstancePortal.lua");
local TeamWorldInstancePortal = commonlib.gettable("MyCompany.Aries.Team.TeamWorldInstancePortal");
local MusicBoxPage = {
};
commonlib.setfield("MyCompany.Aries.Inventory.MusicBoxPage", MusicBoxPage);
function MusicBoxPage.ShowPage()
	NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandConfig.lua");
	local pos = Map3DSystem.App.HomeLand.HomeLandConfig.Panel_ShowPos;
	local self = NormalViewPage;	
	local isinteam = TeamWorldInstancePortal.IsInTeam();
	left = pos.left;
	if(isinteam)then
		left = left + 180;
	end
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/kids/3DMapSystemUI/HomeLand/Pages/MusicBox.html", 
			name = "MusicBoxPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			allowDrag = false,
			click_through = true,
			directPosition = true,
				align = pos.align,
				x = left,
				y = pos.top,
				width = pos.width,
				height = pos.height,
		});
end
function MusicBoxPage.ClosePage()
	local self = MusicBoxPage;
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="MusicBoxPage.ShowPage", 
		app_key=MyCompany.Aries.app.app_key, 
		bShow = false,bDestroy = true,});
		
	--在关闭面板的时候，清空选中的物体
	if(self.canvas and self.canvas.nodeProcessor)then
		self.canvas.nodeProcessor.selectedNode = nil;
	end
	
	self.canvas = nil;
	self.node = nil;
	self.curState = nil;
end
function MusicBoxPage.Init(canvas,node,combinedState)
	local self = MusicBoxPage;
	self.canvas = canvas;
	self.node = node;
	self.ChangeState(combinedState);
end
function MusicBoxPage.DoPlay()
	local self = MusicBoxPage;
	if(self.canvas and self.node)then
		self.canvas:PlayMusic(self.node,true);
		self.canvas:SaveSingleNodeClientData(self.node);
		self.ClosePage();
	end
end
function MusicBoxPage.DoStop()
	local self = MusicBoxPage;
	if(self.canvas and self.node)then
		self.canvas:PlayMusic(self.node,false);
		self.canvas:SaveSingleNodeClientData(self.node);
		self.ClosePage();
	end
end
function MusicBoxPage.ChangeState(combinedState)
	local self = MusicBoxPage;
	if(not combinedState)then return end
	if(combinedState == "master_outside_true" or combinedState == "master_inside_true")then
		self.curState = "master_edit";
	elseif(combinedState == "master_outside_false" or combinedState == "master_inside_false")then
		self.curState = "master_view";
	elseif(combinedState == "guest_outside_false" or combinedState == "guest_inside_false")then
		self.curState = "guest_view";
	end		
end