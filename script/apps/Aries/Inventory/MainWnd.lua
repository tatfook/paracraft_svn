--[[
Title: Inventory main window for Aries App
Author(s): WangTian
Date: 2009/4/24
Desc: inventory window only shows the items in memory
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Inventory/MainWnd.lua");
MyCompany.Aries.Inventory.ShowMainWnd();
------------------------------------------------------------
]]

-- create class
local libName = "AriesInventory";
local Inventory = commonlib.gettable("MyCompany.Aries.Inventory");

-- data keeping of the inventory tab backgrounds and pagectrls
local Inventory_Tabs = {
	[1] = {	name = "Character",
		on_bg = "Texture/Aries/Inventory/TabCharacterOn.png; 0 0 58 50",
		off_bg = "Texture/Aries/Inventory/TabCharacterOff.png; 0 0 58 50",
		content_page = "script/apps/Aries/Inventory/TabCharacter.html",
		pageCtrl = nil,
	},
	[2] = {	name = "Mount",
		on_bg = "Texture/Aries/Inventory/TabMountOn.png; 0 0 58 50",
		off_bg = "Texture/Aries/Inventory/TabMountOff.png; 0 0 58 50",
		content_page = "script/apps/Aries/Inventory/TabMountExPage1.html",
		pageCtrl = nil,
	},
	[3] = {	name = "Follow",
		on_bg = "Texture/Aries/Inventory/TabFollowOn.png; 0 0 58 50",
		off_bg = "Texture/Aries/Inventory/TabFollowOff.png; 0 0 58 50",
		content_page = "script/apps/Aries/Inventory/TabFollow.html",
		pageCtrl = nil,
	},
	[4] = {	name = "Monthly",
		on_bg = "Texture/Aries/Inventory/TabMonthlyOn.png; 0 0 58 50",
		off_bg = "Texture/Aries/Inventory/TabMonthlyOff.png; 0 0 58 50",
		content_page = "script/apps/Aries/Inventory/TabMonthly.html",
		pageCtrl = nil,
	},
};

-- show the inventory main window
-- @param bShow: show or hide the main window, nil to toggle visibility
-- @param index: index of the tab to be shown, default to 1
function Inventory.ShowMainWnd(bShow, index)
	local _mainWnd = ParaUI.GetUIObject("AriesInventoryMainWnd");
	
	if(_mainWnd:IsValid() == false) then
		if(bShow == false) then
			return;
		end 
		-- call hook into open inventory window
		local msg = { aries_type = "OnOpenInventoryWnd", wndName = "main"};
		CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
		--NOTE by leio:new dragon bags view is changed
		_mainWnd = ParaUI.CreateUIObject("container", "AriesInventoryMainWnd", "_ct", -440, -256, 880, 512);
		_mainWnd.background = "";
		_mainWnd.zorder = 2;
		_mainWnd:AttachToRoot();
		
		local _content = ParaUI.CreateUIObject("container", "Content_Level_1", "_fi", 0, 0, 0, 0);
		_content.background = "";
		_mainWnd:AddChild(_content);
		
		--local _tabs = ParaUI.CreateUIObject("container", "Tabs_Level_1", "_lb", 26, -50, 232, 50);
		--_tabs.background = "";
		--_mainWnd:AddChild(_tabs);
		
		local i, node;
		for i, node in ipairs(Inventory_Tabs) do
			local _content_page = ParaUI.CreateUIObject("container", node.name, "_fi", 0, 0, 0, 0);
			_content_page.background = "";
			_content:AddChild(_content_page);
			local contentPage = System.mcml.PageCtrl:new({url = node.content_page});
			contentPage:Create("Inventory"..node.name.."Content", _content_page, "_fi", 0, 0, 0, 0);
			node.pageCtrl = contentPage;
			
			--local _tab = ParaUI.CreateUIObject("button", node.name, "_lt", (i - 1) * 58, 0, 58, 50);
			--_tab.background = "Texture/Aries/Inventory/TabCharacterOn.png; 0 0 58 50";
			----NOTE: temporarily turn off the inventory tab switching
			----_tab.onclick = ";MyCompany.Aries.Inventory.OnTabClick("..i..");";
			--_tabs:AddChild(_tab);
		end
		
		local index = index or 1;
		Inventory.OnTabClick(index);
	else
		local preVisiable = _mainWnd.visible;
		-- toggle visibility if bShow is nil
		if(bShow == nil) then
			bShow = not _mainWnd.visible;
		end
		_mainWnd.visible = bShow;
		
		if(bShow == true and preVisiable == false) then
			-- reset the tab character page checked value to "1"
			local TabCharacterPage = commonlib.getfield("MyCompany.Aries.Inventory.TabCharacterPage");
			if(TabCharacterPage) then
				TabCharacterPage.TabValue = "1";
			end
			-- reset the tab mount page checked value to "1"
			local TabMountPage = commonlib.getfield("MyCompany.Aries.Inventory.TabMountPage");
			if(TabMountPage) then
				TabMountPage.TabValue = "2";
			end
			
			-- call hook into open inventory window
			local msg = { aries_type = "OnOpenInventoryWnd", wndName = "main"};
			CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
		elseif(bShow == false and preVisiable == true) then
			-- call hook into close inventory window
			local msg = { aries_type = "OnCloseInventoryWnd", wndName = "main"};
			CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", msg);
		end
		
		-- refresh the pageCtrl for each show
		if(bShow == true) then
			local i, node;
			for i, node in ipairs(Inventory_Tabs) do
				node.pageCtrl:Init(node.pageCtrl.url);
			end
			local index = index or 1;
			Inventory.OnTabClick(index);
		end
	end
end

-- refresh the main window page controls
-- @param index: refresh the specific tab, if nil refresh all tabs
function Inventory.RefreshMainWnd(index)
	local i, node;
	for i, node in ipairs(Inventory_Tabs) do
		if(node.pageCtrl and node.pageCtrl.Refresh and (index == i or index == nil)) then
			--node.pageCtrl:Refresh(0.1);
			node.pageCtrl:Init(node.pageCtrl.url);
		end
	end
end

-- hide the inventory main window
function Inventory.HideMainWnd()
	Inventory.ShowMainWnd(false);
end

-- on click the first level tab of the inventory main window
-- @param index: shown tab, index into Inventory_Tabs
function Inventory.OnTabClick(index)
	local _mainWnd = ParaUI.GetUIObject("AriesInventoryMainWnd");
	if(_mainWnd:IsValid() == true) then
		local _content = _mainWnd:GetChild("Content_Level_1");
		local _tabs = _mainWnd:GetChild("Tabs_Level_1");
		local i, node;
		for i, node in ipairs(Inventory_Tabs) do
			if(i == index) then
				-- show the content and change the tab background
				local _content_page = _content:GetChild(node.name);
				local _tab = _tabs:GetChild(node.name);
				_content_page.visible = true;
				_tab.background = node.on_bg;
				-- refresh the page ctrl which might be modified
				if(node.pageCtrl) then
					node.pageCtrl:Refresh();
				end
			else
				-- hide the content and change the tab background
				local _content_page = _content:GetChild(node.name);
				local _tab = _tabs:GetChild(node.name);
				_content_page.visible = false;
				_tab.background = node.off_bg;
			end
		end
	end
end