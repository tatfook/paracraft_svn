--[[
Title: 
Author(s): leio
Company: 
Date: 2011/11/17
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/Dock/ManualDock.lua");
local ManualDock = commonlib.gettable("MyCompany.Aries.Desktop.ManualDock");
ManualDock.InternalOnInit();
ManualDock.Invoke(23107);
ManualDock.Invoke(23252);


NPL.load("(gl)script/apps/Aries/Desktop/Dock/ManualDock.lua");
local ManualDock = commonlib.gettable("MyCompany.Aries.Desktop.ManualDock");
commonlib.echo(ManualDock.gridview_list);
------------------------------------------------------------
]]
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
local ManualDock = commonlib.gettable("MyCompany.Aries.Desktop.ManualDock");
NPL.load("(gl)script/ide/STL.lua");
local List = commonlib.gettable("commonlib.List");
ManualDock.node_list = nil;
ManualDock.gridview_list = nil;
function ManualDock.OnInit()
	local self = ManualDock;
	self.page = document:GetPageCtrl();
end
function ManualDock.ShowPage(bShow)
	if(not CommonClientService.IsTeenVersion())then
		return
	end
	if(bShow)then
		ManualDock.InternalOnInit();
	else
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name = "ManualDock.InternalOnInit", app_key=MyCompany.Aries.app.app_key, bShow = false});
	end
end
function ManualDock.RefreshPage()
	local self = ManualDock;
	if(self.page)then
		--if(not self.HasNodes())then
			--self.page:Refresh(0);
			----self.ShowPage(false);
		--else
			----self.ShowPage(true);
			--self.page:Refresh(0);
		--end
		self.page:Refresh(0);
	end
end
function ManualDock.InternalOnInit()
	local self = ManualDock;
	if(not self.node_list)then
		self.node_list = List:new();
	end
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = ManualDock.HookHandler, 
		hookName = "Hook_ManualDock", appName = "Aries", wndName = "main"});

	System.App.Commands.Call("File.MCMLWindowFrame", {
		url = "script/apps/Aries/Desktop/Dock/ManualDock.teen.html", 
		name = "ManualDock.InternalOnInit", 
		app_key=MyCompany.Aries.app.app_key, 
		--app_key=MyCompany.Taurus.app.app_key, 
		isShowTitleBar = false,
		DestroyOnClose = false, -- prevent many ViewProfile pages staying in memory
		style = CommonCtrl.WindowFrame.ContainerStyle,
		zorder = -1, -- avoid interaction with other normal user interface
		click_through = true, -- allow clicking through
		allowDrag = false,
		bShow = true,
		--isPinned = true,
		directPosition = true,
			align = "_ctb",
			x = 120,
			y = -100,
			width = 200,
			height = 100,
	});
end
function ManualDock.HookHandler(nCode, appName, msg, value)
	local self = ManualDock;
	if(msg.action_type == "push_manual_dock_node")then
		self.PushNode(msg.node);
	end
	return nCode;
end
--show a global item on user's desktop to remind what item be got 
function ManualDock.Invoke(gsid)
	if(not gsid)then return end
	if(not CommonClientService.IsTeenVersion())then
		return
	end
	CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", 
	{ action_type = "push_manual_dock_node", node = {gsid = gsid}, wndName = "main",});
end
function ManualDock.HasNodes()
	local self = ManualDock;
	if(self.gridview_list)then
		local len = #self.gridview_list;
		if(len > 0)then
			return true;
		end
	end
end
function ManualDock.HasGsid(gsid)
	local self = ManualDock;
	if(not gsid)then return end
	if(self.node_list)then
		local item = self.node_list:first();
		while (item) do
			if(item.gsid and item.gsid == gsid)then
				return true;
			end
			item = self.node_list:next(item)
		end
	end
end
--add a new node to the head of the list
--node.gsid can't duplicate
function ManualDock.PushNode(node)
	local self = ManualDock;
	if(not node)then return end
	if(self.HasGsid(node.gsid))then
		return
	end
	if(self.node_list)then
		node.uid = ParaGlobal.GenerateUniqueID();
		self.node_list:push_front(node);
		local size = self.node_list:size();
		--max size is 10,if big than max size remove last node
		if(size > 10)then
			local last_node = self.node_list:last();
			self.node_list:remove(last_node);
		end
		self.gridview_list = self.BuildViewList();
		self.RefreshPage();
	end
end
--remove a node from the node_list
function ManualDock.DestroyNode(node)
	local self = ManualDock;
	local item = self.node_list:first();
	while (item) do
		if(item.uid and node.uid and item.uid == node.uid)then
			self.node_list:remove(item);
			self.gridview_list = self.BuildViewList();
			self.RefreshPage();
			break;
		end
		item = self.node_list:next(item)
	end
end
--build a view list for gridview's data source
function ManualDock.BuildViewList()
	local self = ManualDock;
	if(self.node_list)then
		local list = {};
		local item = self.node_list:first();
		while (item) do
			table.insert(list,{gsid = item.gsid, uid = item.uid});
			item = self.node_list:next(item)
		end
		return list;
	end
end