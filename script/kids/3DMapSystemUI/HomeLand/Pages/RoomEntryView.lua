--[[
Title: code behind for page RoomEntryView.html
Author(s): Leio
Date: 2009/7/23
Desc:  script/kids/3DMapSystemUI/HomeLand/Pages/RoomEntryView.html
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/Pages/RoomEntryView.lua");
-------------------------------------------------------
]]
local RoomEntryViewPage = {

};
commonlib.setfield("MyCompany.Aries.Inventory.RoomEntryViewPage", RoomEntryViewPage);

function RoomEntryViewPage.ShowPage()
	NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandConfig.lua");
	local pos = Map3DSystem.App.HomeLand.HomeLandConfig.Panel_ShowPos;
	local self = RoomEntryViewPage;
	System.App.Commands.Call("File.MCMLWindowFrame", {
				url = "script/kids/3DMapSystemUI/HomeLand/Pages/RoomEntryView.html", 
				name = "RoomEntryViewPage.ShowPage", 
				app_key=MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				style = CommonCtrl.WindowFrame.ContainerStyle,
				zorder = 1,
				allowDrag = false,
				directPosition = true,
					align = pos.align,
					x = pos.left,
					y = pos.top,
					width = pos.width,
					height = pos.height,
			});
end
function RoomEntryViewPage.ClosePage()
	local self = RoomEntryViewPage;
	self.Clear();
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="RoomEntryViewPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			bShow = false,bDestroy = true,});
end
function RoomEntryViewPage.DoClick(name)
	local self = RoomEntryViewPage;
	if(name == "move")then
		self.DoMoveNode();
	elseif(name == "left_rot")then
		self.DoFacing(-0.1);
	elseif(name == "right_rot")then
		self.DoFacing(0.1);
	elseif(name == "remove")then
		self.DoRemove();
	elseif(name == "clean")then
		self.Clean();
	elseif(name == "delete")then
		self.Delete();
	end
end
function RoomEntryViewPage.Clear()
	local self = RoomEntryViewPage;
	self.show = false;
	self.canvas = nil;
	self.node = nil;
	self.bean = nil;
	self.page = nil;
	self.curState = nil;
end
function RoomEntryViewPage.Init(canvas,node,bean,combinedState)
	local self = RoomEntryViewPage;
	if(not canvas or not node or not bean)then return end
	self.BindCanvas(canvas)
	self.BindNode(node)
	self.BindBean(bean)
	self.ChangeState(combinedState);
end
function RoomEntryViewPage.BindCanvas(canvas)
	local self = RoomEntryViewPage;
	self.canvas = canvas;
end
function RoomEntryViewPage.BindNode(node)
	local self = RoomEntryViewPage;
	self.node = node;
end
function RoomEntryViewPage.BindBean(bean)
	local self = RoomEntryViewPage;
	self.bean = bean;
end

--打扫
function RoomEntryViewPage.Clean()
	local self = RoomEntryViewPage;
	if(not self.node)then return end
	local guid = self.node:GetGUID();
	NPL.load("(gl)script/kids/3DMapSystemApp/API/homeland/paraworld.homeland.house.lua");
	local msg = {
		nid = Map3DSystem.App.HomeLand.HomeLandGateway.GetNID(),
		guid = guid,
	}
	commonlib.echo("开始打扫：");
	commonlib.echo(msg);
	paraworld.homeland.house.Depurate(msg,"house",function(msg)	
			commonlib.echo("打扫之后：");
			commonlib.echo(msg);
						if(msg and msg.issuccess)then
							self.Update(msg);
							_guihelper.MessageBox("打扫成功！");
							self.ClosePage();
						elseif(msg and msg.errorcode == 426)then
							_guihelper.MessageBox("今天已经打扫过了，明天再来吧！");
							self.ClosePage();
						end
					end);
end

function RoomEntryViewPage.Delete()
	local self = RoomEntryViewPage;
	local guid = self.node:GetGUID();
	_guihelper.MessageBox("你确定要铲除 #"..tostring(guid).." 么？", function(result) 
			if(_guihelper.DialogResult.Yes == result) then
				
			elseif(_guihelper.DialogResult.No == result) then
				self.ClosePage();
				
			end
		end, _guihelper.MessageBoxButtons.YesNo);
end
function RoomEntryViewPage.Update(bean)
	local self = RoomEntryViewPage;
	if(not self.canvas or not self.node)then return end
	self.bean = bean;
	self.canvas:BindNode_OutdoorHouse(self.node,bean)
	self.UpdateUI();
end
function RoomEntryViewPage.UpdateUI()
	local self = RoomEntryViewPage;
	self.ShowPage();
end
function RoomEntryViewPage.ChangeState(combinedState)
	local self = RoomEntryViewPage;
	if(not combinedState)then return end
	if(combinedState == "master_outside_true" or combinedState == "master_inside_true")then
		self.curState = "master_edit";
	elseif(combinedState == "master_outside_false" or combinedState == "master_inside_false")then
		self.curState = "master_view";
	elseif(combinedState == "guest_outside_false" or combinedState == "guest_inside_false")then
		self.curState = "guest_view";
	end		
end