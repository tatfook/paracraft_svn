--[[
Title: code behind for page NormalView.html
Author(s): Leio
Date: 2009/7/23
Desc:  script/kids/3DMapSystemUI/HomeLand/Pages/NormalView.html
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/Pages/NormalView.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Team/TeamWorldInstancePortal.lua");
local TeamWorldInstancePortal = commonlib.gettable("MyCompany.Aries.Team.TeamWorldInstancePortal");
local NormalViewPage = commonlib.gettable("MyCompany.Aries.Inventory.NormalViewPage");
function NormalViewPage.SetPage()
	local self = NormalViewPage;	
	self.page = document:GetPageCtrl();
end
function NormalViewPage.RefreshPage()
	local self = NormalViewPage;	
	if(self.page)then
		self.page:Refresh(0);
	end
end
function NormalViewPage.ShowPage()
	NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandConfig.lua");
	local pos = Map3DSystem.App.HomeLand.HomeLandConfig.Panel_ShowPos;
	local self = NormalViewPage;	
	local isinteam = TeamWorldInstancePortal.IsInTeam();
	left = pos.left;
	if(isinteam)then
		left = left + 180;
	end
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/kids/3DMapSystemUI/HomeLand/Pages/NormalView.html", 
			name = "NormalViewPage.ShowPage", 
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
function NormalViewPage.ClosePage()
	local self = NormalViewPage;
	self.Clear();
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="NormalViewPage.ShowPage", 
		app_key=MyCompany.Aries.app.app_key, 
		bShow = false,bDestroy = true,});
end
function NormalViewPage.DoClick(name)
	local self = NormalViewPage;
	if(name == "move")then
		self.DoMoveNode();
	elseif(name == "left_rot")then
		self.DoFacing(0.1);
	elseif(name == "right_rot")then
		self.DoFacing(-0.1);
	elseif(name == "remove")then
		self.DoRemove();
	elseif(name == "descale")then
		self.DoScaling(-0.1);
	elseif(name == "scale")then
		self.DoScaling(0.1);
	end
end
function NormalViewPage.Clear()
	local self = NormalViewPage;
	self.show = false;
	self.canvas = nil;
	self.node = nil;
	self.bean = nil;
	self.page = nil;
	self.curState = nil;
end
function NormalViewPage.Init(canvas,node,bean,combinedState)
	local self = NormalViewPage;
	if(not canvas or not node or not bean)then return end
	self.BindCanvas(canvas)
	self.BindNode(node)
	self.BindBean(bean)
	self.ChangeState(combinedState);
end
function NormalViewPage.BindCanvas(canvas)
	local self = NormalViewPage;
	self.canvas = canvas;
end
function NormalViewPage.BindNode(node)
	local self = NormalViewPage;
	self.node = node;
end
function NormalViewPage.BindBean(bean)
	local self = NormalViewPage;
	self.bean = bean;
end

-- 移动
function NormalViewPage.DoMoveNode()
	local self = NormalViewPage;
	if(self.node)then
		Map3DSystem.App.HomeLand.HomeLandGateway.DoMoveNode();
	end
end
-- 旋转
function NormalViewPage.DoFacing(v)
	local self = NormalViewPage;
	if(self.node)then
		Map3DSystem.App.HomeLand.HomeLandGateway.DoFacing(v);
	end
end
-- 缩放
function NormalViewPage.DoScaling(v)
	local self = NormalViewPage;
	if(self.node)then
		Map3DSystem.App.HomeLand.HomeLandGateway.DoScaling(v);
	end
end
-- 回收
function NormalViewPage.DoRemove()
	local self = NormalViewPage;
	if(self.node)then
		Map3DSystem.App.HomeLand.HomeLandGateway.DoRemove()
	end
end
function NormalViewPage.ChangeState(combinedState)
	local self = NormalViewPage;
	if(not combinedState)then return end
	if(combinedState == "master_outside_true" or combinedState == "master_inside_true")then
		self.curState = "master_edit";
	elseif(combinedState == "master_outside_false" or combinedState == "master_inside_false")then
		self.curState = "master_view";
	elseif(combinedState == "guest_outside_false" or combinedState == "guest_inside_false")then
		self.curState = "guest_view";
	end		
end