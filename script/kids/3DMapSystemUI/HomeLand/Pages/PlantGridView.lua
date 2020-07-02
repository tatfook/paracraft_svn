--[[
Title: code behind for page PlantGridView.html
Author(s): Leio
Date: 2009/7/23
Desc:  script/kids/3DMapSystemUI/HomeLand/Pages/PlantGridView.html
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/Pages/PlantGridView.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Team/TeamWorldInstancePortal.lua");
local TeamWorldInstancePortal = commonlib.gettable("MyCompany.Aries.Team.TeamWorldInstancePortal");
local PlantGridViewPage = {

};
commonlib.setfield("MyCompany.Aries.Inventory.PlantGridViewPage", PlantGridViewPage);
--检测放种子的背包 是否为空
function PlantGridViewPage.CheckBagIsEmpty()
	local self = PlantGridViewPage;
	-- find the right bag for inventory items
	local bag;
	bag = 42;

	local ItemManager = Map3DSystem.Item.ItemManager;
	ItemManager.GetItemsInBag(bag, "homelanditems_"..bag, function(msg)
		if(msg and msg.items) then
			local count = ItemManager.GetItemCountInBag(bag);
			if(count == 0) then
				-- dirty code to notify the user no seed available
				_guihelper.MessageBox("你没有种子了，快去买些种子回来吧！");
			end
		end
	end, "access plus 0 minutes");
end
function PlantGridViewPage.ShowPage()
	NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandConfig.lua");
	local pos = Map3DSystem.App.HomeLand.HomeLandConfig.Panel_ShowPos;
	local self = PlantGridViewPage;
	local isinteam = TeamWorldInstancePortal.IsInTeam();
	left = pos.left;
	if(isinteam)then
		left = left + 210;
	end
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/kids/3DMapSystemUI/HomeLand/Pages/PlantGridView.html", 
			name = "PlantGridViewPage.ShowPage", 
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
	if(self.curState == "master_view")then
		self.CheckBagIsEmpty();
	end
end
function PlantGridViewPage.ClosePage()
	local self = PlantGridViewPage;
	
	self.Clear();
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="PlantGridViewPage.ShowPage", 
		app_key=MyCompany.Aries.app.app_key, 
		bShow = false,bDestroy = true,});
end
function PlantGridViewPage.DoClick(name)
	local self = PlantGridViewPage;
	if(name == "move")then
		self.DoMoveNode();
	elseif(name == "left_rot")then
		self.DoFacing(-0.1);
	elseif(name == "right_rot")then
		self.DoFacing(0.1);
	elseif(name == "remove")then
		self.DoRemove();
	end
end
function PlantGridViewPage.Clear()
	local self = PlantGridViewPage;
	self.show = false;
	self.canvas = nil;
	self.node = nil;
	self.bean = nil;
	self.page = nil;
	self.curState = nil;
	self.hitTestNodeIndex = nil;
end
function PlantGridViewPage.Init(canvas,node,bean,combinedState,hitTestNodeIndex)
	local self = PlantGridViewPage;
	if(not canvas or not node or not bean or not combinedState)then return end
	self.BindCanvas(canvas)
	self.BindNode(node)
	self.BindBean(bean)
	self.ChangeState(combinedState);
	self.BindHitIndex(hitTestNodeIndex);
end
function PlantGridViewPage.BindCanvas(canvas)
	local self = PlantGridViewPage;
	self.canvas = canvas;
end
function PlantGridViewPage.BindNode(node)
	local self = PlantGridViewPage;
	self.node = node;
end
function PlantGridViewPage.BindBean(bean)
	local self = PlantGridViewPage;
	self.bean = bean;
end
function PlantGridViewPage.BindHitIndex(hitTestNodeIndex)
	local self = PlantGridViewPage;
	self.hitTestNodeIndex = hitTestNodeIndex;
end
function PlantGridViewPage.ChangeState(combinedState)
	local self = PlantGridViewPage;
	if(not combinedState)then return end
	if(combinedState == "master_outside_true" or combinedState == "master_inside_true")then
		self.curState = "master_edit";
	elseif(combinedState == "master_outside_false" or combinedState == "master_inside_false")then
		self.curState = "master_view";
	elseif(combinedState == "guest_outside_false" or combinedState == "guest_inside_false")then
		self.curState = "guest_view";
	end		
end