--[[
Title: Desktop Dock Area for Aquarius App
Author(s): WangTian
Date: 2008/12/2
See Also: script/apps/Aquarius/Desktop/AquariusDesktop.lua

	4. middle bottom area: always on top first level function list, it further divides into:
		4.1 Menu, "windows start"-like icon to show all the applications in a window
		4.2 Quick Launch, customizable bar that holds user specific organization
		4.3 Current App, shows the current application icon indicating the running application status
		4.4 UtilBar1, utility bar 1, show small icons of utility
		4.5 UtilBar2, utility bar 2, show large icons of utility
		
Area:  
					---------------------------------------------------------
	  zorder = 2 -> | Profile	Target								Mini Map| <- zorder = 2
target zorder = 1 	|														|
					| 													 C	|
					| 													 h	|
					| 													 a	|
					| 													 t	| <- zorder = 2
					|-------|											 T	|
					| 		|											 a	|
					| 	M	|											 b	|
	  zorder = 4 -> |	E	|											 s	|
					|	N	|									 -----------|
					|	U	|									 |  Notif-  | <- zorder = 1
					|		|									 | ication  |
					|		|			CurrentApp Toolbar		 |			| <- zorder = 2
					| Menu | QuickLaunch | CurrentApp | UtilBar1 | UtilBar2	| <- zorder = 3
					|┗━━━━━━━━━━━━━Dock━━━━━━━━━━━━━┛ |
					---------------------------------------------------------
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aquarius/Desktop/Dock.lua");
MyCompany.Aquarius.Desktop.Dock.InitDock();
------------------------------------------------------------
]]

-- create class
local libName = "AquariusDesktopDock";
local Dock = {};
commonlib.setfield("MyCompany.Aquarius.Desktop.Dock", Dock);

-- data keeping
-- current icons of dock area
Dock.RootNode = CommonCtrl.TreeNode:new({Name = "DockRoot",});

Dock.MenuNode = Dock.RootNode:AddChild(CommonCtrl.TreeNode:new({Text = "菜单", Name = "MenuRoot"}));
	Dock.MenuNode:AddChild(CommonCtrl.TreeNode:new({app_key = "Creator_GUID", }));
	Dock.MenuNode:AddChild(CommonCtrl.TreeNode:new({app_key = "Env_GUID", }));
	Dock.MenuNode:AddChild(CommonCtrl.TreeNode:new({app_key = "CCS_GUID", }));
	Dock.MenuNode:AddChild(CommonCtrl.TreeNode:new({app_key = "Chat_GUID", }));
	Dock.MenuNode:AddChild(CommonCtrl.TreeNode:new({app_key = "profiles_GUID", }));
	Dock.MenuNode:AddChild(CommonCtrl.TreeNode:new({app_key = "worlds_GUID", }));
	Dock.MenuNode:AddChild(CommonCtrl.TreeNode:new({app_key = "Blueprint_GUID", }));
	Dock.MenuNode:AddChild(CommonCtrl.TreeNode:new({app_key = "Developers_GUID", }));
-- Quick launch is fixed design according to UI artwork, so don't change the node numbers
Dock.QuickLaunchNode = Dock.RootNode:AddChild(CommonCtrl.TreeNode:new({Text = "快捷栏", Name = "QuickLaunchRoot"}));
	Dock.QuickLaunchNode:AddChild(CommonCtrl.TreeNode:new({Slot = 1, app_key = "Creator_GUID", }));
	Dock.QuickLaunchNode:AddChild(CommonCtrl.TreeNode:new({Slot = 2, app_key = "CCS_GUID", }));
	Dock.QuickLaunchNode:AddChild(CommonCtrl.TreeNode:new({Slot = 3, app_key = "Chat_GUID", }));
	Dock.QuickLaunchNode:AddChild(CommonCtrl.TreeNode:new({Slot = 4, AppCommand="File.Open.Asset", }));
	Dock.QuickLaunchNode:AddChild(CommonCtrl.TreeNode:new({Slot = 5, AppCommand="File.Open.PersonalWorld", }));
	Dock.QuickLaunchNode:AddChild(CommonCtrl.TreeNode:new({Slot = 6, AppCommand="File.SaveAndPublish", }));
	Dock.QuickLaunchNode:AddChild(CommonCtrl.TreeNode:new({Slot = 7, AppCommand="File.MCMLBrowser", }));
	Dock.QuickLaunchNode:AddChild(CommonCtrl.TreeNode:new({Slot = 8, AppCommand="File.ProTools", }));
	Dock.QuickLaunchNode:AddChild(CommonCtrl.TreeNode:new({Slot = 9, AppCommand="File.ArtTools",}));
	Dock.QuickLaunchNode:AddChild(CommonCtrl.TreeNode:new({Slot = 10, app_key = "HomeZone_GUID", }));
		
Dock.CurrentAppNode = Dock.RootNode:AddChild(CommonCtrl.TreeNode:new({Text = "当前App", Name = "CurrentAppRoot"}));
	Dock.CurrentAppNode:AddChild(CommonCtrl.TreeNode:new({app_key = nil, })); -- no application is activated on init
-- UtilBar1 and UtilBar2 are fixed design according to UI artwork, so don't change the node numbers
Dock.UtilBar1Node = Dock.RootNode:AddChild(CommonCtrl.TreeNode:new({Text = "功能1", Name = "UtilBar1Root"}));
	Dock.UtilBar1Node:AddChild(CommonCtrl.TreeNode:new({CommandName = "Profile.Aquarius.EditProfile", tooltip = "个人", params = nil, icon = "Texture/Aquarius/Desktop/UtilBar1_Profile_32bits.png; 0 0 24 32",}));
	Dock.UtilBar1Node:AddChild(CommonCtrl.TreeNode:new({CommandName = "Profile.Aquarius.NA", tooltip = "社交（此版本尚未开放）", params = nil, icon = "Texture/Aquarius/Desktop/UtilBar1_Social_32bits.png; 0 0 24 32",}));
	Dock.UtilBar1Node:AddChild(CommonCtrl.TreeNode:new({CommandName = "Profile.Aquarius.Task", tooltip = "任务", params = nil, icon = "Texture/Aquarius/Desktop/UtilBar1_Quest_32bits.png; 0 0 24 32",}));
	Dock.UtilBar1Node:AddChild(CommonCtrl.TreeNode:new({CommandName = "Profile.Aquarius.LocalMap", tooltip = "地图", params = nil, icon = "Texture/Aquarius/Desktop/UtilBar1_Map_32bits.png; 0 0 24 32",}));
	Dock.UtilBar1Node:AddChild(CommonCtrl.TreeNode:new({CommandName = "Profile.Aquarius.EscPage", tooltip = "设置", params = nil, icon = "Texture/Aquarius/Desktop/UtilBar1_Setting_32bits.png; 0 0 24 32",}));
	Dock.UtilBar1Node:AddChild(CommonCtrl.TreeNode:new({CommandName = "Profile.Chat.ChatWithContactImmediate", tooltip = "帮助", params = {nid = "114"}, icon = "Texture/Aquarius/Desktop/UtilBar1_Help_32bits.png; 0 0 24 32",}));
	--Dock.UtilBar1Node:AddChild(CommonCtrl.TreeNode:new({CommandName = "", params = nil, icon = "Texture/Aquarius/Dock/util7.png; 0 0 24 32",}));
Dock.UtilBar2Node = Dock.RootNode:AddChild(CommonCtrl.TreeNode:new({Text = "功能2", Name = "UtilBar2Root"}));
	Dock.UtilBar2Node:AddChild(CommonCtrl.TreeNode:new({CommandName = "Profile.Aquarius.FeedPage", tooltip = "动态", params = nil, icon = "Texture/Aquarius/Desktop/UtilBar2_Feed_32bits.png; 0 0 40 40"}));
	Dock.UtilBar2Node:AddChild(CommonCtrl.TreeNode:new({CommandName = "Profile.Aquarius.NA", tooltip = "愿望（此版本尚未开放）", params = nil, icon = "Texture/Aquarius/Desktop/UtilBar2_Wish_32bits.png; 0 0 40 40"}));
	Dock.UtilBar2Node:AddChild(CommonCtrl.TreeNode:new({CommandName = "Profile.Aquarius.NA", tooltip = "邮件（此版本尚未开放）", params = nil, icon = "Texture/Aquarius/Desktop/UtilBar2_Mail_32bits.png; 0 0 40 40"}));
	Dock.UtilBar2Node:AddChild(CommonCtrl.TreeNode:new({CommandName = "Profile.Aquarius.NA", tooltip = "星球（此版本尚未开放）", params = nil, icon = "Texture/Aquarius/Desktop/UtilBar2_Star_32bits.png; 0 0 40 40"}));
	Dock.UtilBar2Node:AddChild(CommonCtrl.TreeNode:new({CommandName = "Profile.Aquarius.NA", tooltip = "背包（此版本尚未开放）", params = nil, icon = "Texture/Aquarius/Desktop/UtilBar2_Bag_32bits.png; 0 0 40 40"}));
	Dock.UtilBar2Node:AddChild(CommonCtrl.TreeNode:new({CommandName = "Profile.Aquarius.FriendsPage", tooltip = "朋友", params = nil, icon = "Texture/Aquarius/Desktop/UtilBar2_Friends_32bits.png; 0 0 40 40"}));
	Dock.UtilBar2Node:AddChild(CommonCtrl.TreeNode:new({CommandName = "Profile.Aquarius.NA", tooltip = "日历（此版本尚未开放）", params = nil, icon = "Texture/Aquarius/Desktop/UtilBar2_Calendar_32bits.png; 0 0 40 40"}));

-- invoked at Desktop.InitDesktop(), it assert this function is invoked only once
function Dock.InitDock()
	
	--System.App.Chat.InitJabber(Map3DSystem.User.Name, Map3DSystem.User.Password, paraworld.TranslateURL("%CHATDOMAIN%"), paraworld.TranslateURL("%CHATDOMAINIP%"));
	--System.App.Chat.InitJabber(username, password, servername, NetworkHost)
	--System.App.Chat.InitJabber("andy", "qwerty103", "jabber.test.pala5.com")
	
	local _dock = ParaUI.CreateUIObject("container", "Dock", "_ctb", 0, 0, 1084, 48);
	_dock.onframemove = ";MyCompany.Aquarius.Desktop.Dock.DoFramemove();";
	--_dock.background = "Texture/Aquarius/Dock/Dock1.png: 4 4 4 4";
	_dock.background = "Texture/Aquarius/Desktop/Dock_32bits.png; 0 0 64 48: 28 23 28 23";
	_dock.zorder = 3;
	_dock:AttachToRoot();
	
	local menuWidth = 75;
	local _menu = ParaUI.CreateUIObject("button", "Menu", "_lt", 30, 0, 75, 48);
	_menu.onclick = ";MyCompany.Aquarius.Desktop.Dock.ToggleMenu();";
	_menu.background = "Texture/Aquarius/Desktop/MainMenu_Btn_32bits.png; 0 0 75 48";
	_dock:AddChild(_menu);
	
	local _separator = ParaUI.CreateUIObject("container", "Separator", "_lt", 30 + menuWidth, 5, 2, 36);
	_separator.background = "Texture/Aquarius/Desktop/Dock_Separator_32bits.png";
	_dock:AddChild(_separator);
	
	local quickLaunchWidth = 41 * Dock.QuickLaunchNode:GetChildCount() + 22; -- 22 for the scroll pager and locker
	local _quicklaunch = ParaUI.CreateUIObject("container", "QuickLaunch", "_lt", 
			30 + menuWidth + 2, 4, quickLaunchWidth, 40);
	_quicklaunch.background = "";
	_dock:AddChild(_quicklaunch);
	
	
	-- make a button inventory slot style
	-- @param uiobject: button UI object
	-- @param backgroundImage: background image always shows on slot
	-- @param highlightImage: highlight image shows only on mouse over indicating available slot for item 
	--			or item outer glow highlight
	local function SetSlotStyleButton(uiobject, backgroundImage, highlightImage)
		if(uiobject~=nil and uiobject:IsValid())then
			local texture;
			
			if(backgroundImage ~= nil) then
				uiobject:SetActiveLayer("background");
				uiobject.background = backgroundImage; 
				
				uiobject:SetCurrentState("highlight");
				uiobject.color="255 255 255";
				uiobject:SetCurrentState("pressed");
				uiobject.color="255 255 255";
				uiobject:SetCurrentState("disabled");
				uiobject.color="255 255 255 100";
				uiobject:SetCurrentState("normal");
				uiobject.color="255 255 255";
				
				uiobject:SetActiveLayer("artwork");
			end
			
			if(highlightImage ~= nil) then
				uiobject:SetActiveLayer("artwork");
				uiobject.background = highlightImage; 
				
				uiobject:SetCurrentState("highlight");
				uiobject.color="255 255 255 200";
				uiobject:SetCurrentState("pressed");
				uiobject.color="255 255 255 255";
				uiobject:SetCurrentState("normal");
				uiobject.color="0 0 0 0";
				uiobject:SetCurrentState("disabled");
				uiobject.color="0 0 0 0";
			end
		end
	end
	
	local i;
	for i = 1, Dock.QuickLaunchNode:GetChildCount() do
		-- each quicklaunch bar item has a slot containing an icon no matter if the node is empty
		local node = Dock.QuickLaunchNode:GetChild(i);
		local _slot = ParaUI.CreateUIObject("container", "Slot"..i, "_lt", (i - 1) * 41, 0, 40, 40);
		_slot.background = "";
		_quicklaunch:AddChild(_slot);
		
		local _highlight = ParaUI.CreateUIObject("button", "HighLight", "_fi", 0, 0, 0, 0);
		SetSlotStyleButton(_highlight, 
				"Texture/Aquarius/Desktop/QuickLaunch_Slot_Norm_32bits.png; 0 0 40 40", 
				"Texture/Aquarius/Desktop/QuickLaunch_Slot_Over_32bits.png; 0 0 40 40");
		_slot:AddChild(_highlight);
		
		local _icon = ParaUI.CreateUIObject("button", "Icon"..i, "_lt", 4, 4, 32, 32);
		if(node.app_key) then
			local app = System.App.AppManager.GetApp(node.app_key);
			_icon.background = app.icon or app.Icon;
			_icon.tooltip = app.Title;
		elseif(node.AppCommand) then
			local command = System.App.Commands.GetCommand(node.AppCommand);
			_icon.background = command.icon or command.Icon;
			_icon.tooltip = command.ButtonText;
		else
			_icon.background = "";
			_icon.tooltip = "将一个已安装的APP图标拖拽到这里（此版本尚未开放）";
		end
		_icon.onclick = ";MyCompany.Aquarius.Desktop.Dock.OnClickQuickLaunchItem("..i..");";
		_icon.candrag = true;
		_icon.ondragbegin = ";MyCompany.Aquarius.Desktop.Dock.OnAppDragBegin(false, "..i..");";
		_icon.ondragmove = ";MyCompany.Aquarius.Desktop.Dock.OnAppDragMove();";
		_icon.ondragend = ";MyCompany.Aquarius.Desktop.Dock.OnAppDragEnd();";
		_slot:AddChild(_icon);
	end
	
	-- toggle the quicklaunchbar lock
	-- TODO: the background and candrag is not actually changed
	function Dock.ToggleLock()
		local _dock = ParaUI.GetUIObject("Dock");
		local _quicklaunch = _dock:GetChild("QuickLaunch");
		local _lock = _quicklaunch:GetChild("Lock");
		Dock.IsQuickLaunchBarLocked = not Dock.IsQuickLaunchBarLocked;
		if(Dock.IsQuickLaunchBarLocked == true) then
			_lock.background = "Texture/Aquarius/Desktop/QuickLaunch_Locked_32bits.png; 0 0 22 40";
			local i;
			for i = 1, Dock.QuickLaunchNode:GetChildCount() do
				local _slot = _quicklaunch:GetChild("Icon"..i);
				local _icon = _slot:GetChild("Icon"..i);
				_icon.candrag = false;
				local _highlight = _slot:GetChild("HighLight");
				SetSlotStyleButton(_highlight, 
						"Texture/Aquarius/Desktop/QuickLaunch_Slot_Norm_32bits.png; 0 0 40 40", 
						"Texture/Aquarius/Desktop/QuickLaunch_Slot_Norm_32bits.png; 0 0 40 40");
			end
		else
			_lock.background = "Texture/Aquarius/Desktop/QuickLaunch_Unlocked_32bits.png; 0 0 22 40";
			local i;
			for i = 1, Dock.QuickLaunchNode:GetChildCount() do
				local _slot = _quicklaunch:GetChild("Icon"..i);
				local _icon = _slot:GetChild("Icon"..i);
				_icon.candrag = true;
				local _highlight = _slot:GetChild("HighLight");
				SetSlotStyleButton(_highlight, 
						"Texture/Aquarius/Desktop/QuickLaunch_Slot_Norm_32bits.png; 0 0 40 40", 
						"Texture/Aquarius/Desktop/QuickLaunch_Slot_Over_32bits.png; 0 0 40 40");
			end
		end
	end
	
	local _lock = ParaUI.CreateUIObject("button", "Lock", "_rt", -22, 0, 22, 40);
	Dock.IsQuickLaunchBarLocked = false;
	_lock.background = "Texture/Aquarius/Desktop/QuickLaunch_Unlocked_32bits.png; 0 0 22 40";
	_lock.tooltip = "锁定/解锁";
	_lock.onclick = ";MyCompany.Aquarius.Desktop.Dock.ToggleLock();";
	_quicklaunch:AddChild(_lock);
	
	local _separator = ParaUI.CreateUIObject("container", "Separator", "_lt", 30 + menuWidth + 2 + quickLaunchWidth, 5, 2, 36);
	_separator.background = "Texture/Aquarius/Desktop/Dock_Separator_32bits.png";
	_dock:AddChild(_separator);
	
	local currentAppWidth = 46;
	local _currentapp = ParaUI.CreateUIObject("container", "CurrentApp", "_lt", 
			30 + menuWidth + 2 + quickLaunchWidth + 2, 4, currentAppWidth, 40);
	_currentapp.background = "";
	_dock:AddChild(_currentapp);
	
		local _highlight = ParaUI.CreateUIObject("button", "HighLight", "_lt", 2, 0, 40, 40);
		SetSlotStyleButton(_highlight, 
				"Texture/Aquarius/Desktop/QuickLaunch_Slot_Norm_32bits.png; 0 0 40 40", 
				"Texture/Aquarius/Desktop/QuickLaunch_Slot_Over_32bits.png; 0 0 40 40");
		_currentapp:AddChild(_highlight);
		
		local _icon = ParaUI.CreateUIObject("button", "Icon", "_lt", 6, 4, 32, 32);
		_icon.background = "";
		_currentapp:AddChild(_icon);
		
	local _separator = ParaUI.CreateUIObject("container", "Separator", "_lt", 30 + menuWidth + 2 + quickLaunchWidth + 2 + currentAppWidth, 5, 2, 36);
	_separator.background = "Texture/Aquarius/Desktop/Dock_Separator_32bits.png";
	_dock:AddChild(_separator);
	
	local utilBar1Width = 160;
	local _utilbar1 = ParaUI.CreateUIObject("container", "UtilBar1", "_lt", 
			30 + menuWidth + 2 + quickLaunchWidth + 2 + currentAppWidth + 4, 4 + 1, utilBar1Width, 38);
	_utilbar1.background = "Texture/Aquarius/Desktop/UtilBar1_BG_32bits.png: 20 20 8 8";
	_dock:AddChild(_utilbar1);
	
	local i;
	for i = 1, Dock.UtilBar1Node:GetChildCount() do
		local node = Dock.UtilBar1Node:GetChild(i);
		local _bg = ParaUI.CreateUIObject("container", "BG", "_lt", (i - 1) * 26 + 3, 3, 24, 32);
		_bg.background = "Texture/Aquarius/Desktop/UtilBar1_Slot_32bits.png; 0 0 24 32";
		_bg.enabled = false;
		_utilbar1:AddChild(_bg);
		local _util = ParaUI.CreateUIObject("button", "Util", "_lt", (i - 1) * 26 + 3, 3, 24, 32);
		_util.background = node.icon;
		_util.tooltip = node.tooltip;
		_util.onclick = ";MyCompany.Aquarius.Desktop.Dock.OnClickUtilBar1Icon("..i..");";
		_utilbar1:AddChild(_util);
	end
	
	local _separator = ParaUI.CreateUIObject("container", "Separator", "_lt", 
		30 + menuWidth + 2 + quickLaunchWidth + 2 + currentAppWidth + 4 + utilBar1Width + 2, 5, 2, 36);
	_separator.background = "Texture/Aquarius/Desktop/Dock_Separator_32bits.png";
	_dock:AddChild(_separator);
	
	local utilBar2Width = 41 * Dock.UtilBar2Node:GetChildCount();
	local _utilbar2 = ParaUI.CreateUIObject("container", "UtilBar2", "_lt", 
		30 + menuWidth + 2 + quickLaunchWidth + 2 + currentAppWidth + 4 + utilBar1Width + 6, 4, utilBar2Width, 40);
	_utilbar2.background = "";
	_dock:AddChild(_utilbar2);
	
	local i;
	for i = 1, Dock.UtilBar2Node:GetChildCount() do
		local node = Dock.UtilBar2Node:GetChild(i);
		local _bg = ParaUI.CreateUIObject("container", "BG", "_lt", (i - 1) * 41, 0, 40, 40);
		_bg.background = "Texture/Aquarius/Desktop/UtilBar2_Slot_32bits.png; 0 0 40 40";
		_bg.enabled = false;
		_utilbar2:AddChild(_bg);
		local _util = ParaUI.CreateUIObject("button", "Util", "_lt", (i - 1) * 41, 0, 40, 40);
		_util.background = node.icon;
		_util.tooltip = node.tooltip;
		_util.onclick = ";MyCompany.Aquarius.Desktop.Dock.OnClickUtilBar2Icon("..i..");";
		_utilbar2:AddChild(_util);
	end
	
	Dock.ClickReceiverName = "ClickReceiver";
	local _clickRecv = ParaUI.CreateUIObject("button", Dock.ClickReceiverName, "_fi", 0, 0, 0, 0);
	_clickRecv.background = "";
	_clickRecv.visible = false;
	_clickRecv.zorder = 100;
	_clickRecv.onclick = ";MyCompany.Aquarius.Desktop.Dock.OnClickReceiverClick();";
	_clickRecv:AttachToRoot();
end

function Dock.OnClickUtilBar1Icon(index)
	local node = Dock.UtilBar1Node:GetChild(index);
	if(node.CommandName ~= "") then
		System.App.Commands.Call(node.CommandName, node.params);
	else
		_guihelper.MessageBox(index);
	end
end

function Dock.OnClickUtilBar2Icon(index)
	local node = Dock.UtilBar2Node:GetChild(index);
	if(node.CommandName ~= "") then
		System.App.Commands.Call(node.CommandName, node.params);
	else
		_guihelper.MessageBox(index);
	end
end


-- Desc: toggle the menu when clicking the menu button
--		Currently it shows specific application list, each app node contains an icon, app name and a description
-- NOTE: The icon of an application is specially designed for icon dragging process. See also:
--		Application and quicklaunch bar dragging metaphor
Dock.MenuName = "AquariusDockMenu";
function Dock.ToggleMenu(bShow)
	local _menu;
	_menu = ParaUI.GetUIObject(Dock.MenuName);
	
	local menuItemWidth, menuItemHeight = 256 -14 -19, 56;
	
	local preShowMenuVisible;
	if(_menu:IsValid() == true)then
		preShowMenuVisible = _menu.visible;
		if(bShow == nil) then
			_menu.visible = not _menu.visible;
		else
			_menu.visible = bShow;
		end
	else
		preShowMenuVisible = false;
		if(bShow == false) then
			return;
		end
		-- show the menu above the menu button
		local nCount = Dock.MenuNode:GetChildCount();
		
		local _dock = ParaUI.GetUIObject("Dock");
		if(_dock:IsValid() == false) then
			log("InValid dock object\n");
			return;
		end
		local _menuButton = _dock:GetChild("Menu");
		if(_menuButton:IsValid() == false) then
			log("InValid menu button object\n");
			return;
		end
		
		-- get menu button position
		local x, y, width, height = _menuButton:GetAbsPosition();
		
		_menu = ParaUI.CreateUIObject("container", Dock.MenuName, "_ctb", -510 + menuItemWidth/2 + 4, -47, menuItemWidth, 60 -13 + menuItemHeight * nCount + 40 -21);
		--_menu.background = "Texture/Aquarius/Dock/Dock1.png;0 0 16 14:4 4 4 4";
		_menu.background = "";
		_menu.zorder = 4;
		_menu:AttachToRoot();
		
		local _bg = ParaUI.CreateUIObject("container", "BG", "_fi", -14, -13, -19, -21);
		_bg.background = "Texture/Aquarius/Desktop/MainMenu_BG_32bits.png: 127 64 127 50";
		_bg.enabled = false;
		_menu:AddChild(_bg);
		
		--local _menutext = ParaUI.CreateUIObject("text", "MenuText", "_lt", 10, 3, 110, 21);
		--_menutext.text = "PALA5 菜单";
		--_guihelper.SetFontColor(_menutext, "174 174 174");
		--_menu:AddChild(_menutext);
		
		local _close = ParaUI.CreateUIObject("button", "Close", "_rt", -35, 5, 32, 32);
		_close.background = "Texture/Aquarius/Desktop/MainMenu_Close_32bits.png";
		_close.onclick = ";MyCompany.Aquarius.Desktop.Dock.ToggleMenu(false);";
		_menu:AddChild(_close);
		
		local i;
		for i = 1, nCount do
			local node = Dock.MenuNode:GetChild(i);
			
			local _item = ParaUI.CreateUIObject("container", "App"..i, "_lt", 0, (i - 1) * menuItemHeight + 60 - 13, menuItemWidth, menuItemHeight);
			_item.background = "";
			_menu:AddChild(_item);
			
			if(node.app_key == nil) then
				log("invalid app_key for dock menu\n");
				return;
			end
			local app = System.App.AppManager.GetApp(node.app_key);
			
			local _backIcon = ParaUI.CreateUIObject("container", "BackIcon", "_lt", 12, 3, 48, 48);
			_backIcon.background = app.icon or app.Icon;
			_backIcon.enabled = false;
			_backIcon.visible = false;
			_item:AddChild(_backIcon);
			
			local _frontIcon = ParaUI.CreateUIObject("button", "FrontIcon", "_lt", 12, 3, 48, 48);
			_frontIcon.background = app.icon or app.Icon;
			_frontIcon.candrag = true;
			_frontIcon.onclick = ";MyCompany.Aquarius.Desktop.Dock.OnClickMenuItem("..i..");";
			_frontIcon.ondragbegin = ";MyCompany.Aquarius.Desktop.Dock.OnAppDragBegin(true, "..i..");";
			_frontIcon.ondragmove = ";MyCompany.Aquarius.Desktop.Dock.OnAppDragMove();";
			_frontIcon.ondragend = ";MyCompany.Aquarius.Desktop.Dock.OnAppDragEnd();";
			_item:AddChild(_frontIcon);
			
			local _name = ParaUI.CreateUIObject("text", "Title", "_lt", 70, 10, 140, 20);
			--_name.text = app.text or app.Text;
			_name.text = app.Title;
			--_guihelper.SetFontColor(_name, "230 230 230");
			_item:AddChild(_name);
			
			local _desc = ParaUI.CreateUIObject("text", "SubTitle", "_lt", 70, 30, 140, 48);
			--_desc.text = app.tooltip or app.Tooltip or app.desc or app.Desc;
			_desc.text = app.SubTitle;
			--_guihelper.SetFontColor(_desc, "174 174 174");
			_item:AddChild(_desc);
			
		end
	end
	
	if(preShowMenuVisible == true and _menu.visible == true) then
		
	elseif(preShowMenuVisible == false and _menu.visible == false) then
		
	elseif(preShowMenuVisible == false and _menu.visible == true) then
		
		-- show the window, the window frame is already BringToFront()
		local block = UIDirectAnimBlock:new();
		block:SetUIObject(_menu);
		block:SetTime(200);
		block:SetAlphaRange(0, 1);
		block:SetTranslationYRange(200, 0);
		block:SetApplyAnim(true);
		UIAnimManager.PlayDirectUIAnimation(block);
		
	elseif(preShowMenuVisible == true and _menu.visible == false) then
		
		-- hide the window
		
		_menu.visible = true;
		
		local block = UIDirectAnimBlock:new();
		block:SetUIObject(_menu);
		block:SetTime(200);
		block:SetAlphaRange(1, 0);
		block:SetTranslationYRange(0, 200);
		block:SetApplyAnim(true);
		block:SetCallback(function ()
			_menu.visible = false;
		end)
		UIAnimManager.PlayDirectUIAnimation(block);
	end
end

-- record the current icon dragging process
Dock.DragNodeIsFromMenu = nil;
Dock.DragNodeIndex = nil;
Dock.DragNodeRows = nil;

-- if true the Dock.QuickLaunchDragIcon is snapped to the cursor
Dock.IsSnapToCursor = false;
-- quick launch bar icon during click drag process
Dock.QuickLaunchDragIcon = nil;
-- offset from left top point of icon to mouse click point
Dock.QuickLaunchDragIconClickOffsetX = nil;
Dock.QuickLaunchDragIconClickOffsetY = nil;
Dock.QuickLaunchDragIconSizeWidth = nil;
Dock.QuickLaunchDragIconSizeHeight = nil;

local _elapsedtime = 0;
-- translation the QuickLaunchDragIcon object if exists
function Dock.DoFramemove()
	if(Dock.IsSnapToCursor == true) then
		local _icon;
		if(Dock.DragNodeIsFromMenu == true) then
			local _menu = ParaUI.GetUIObject(Dock.MenuName);
			local _item = _menu:GetChild("App"..Dock.DragNodeIndex);
			_icon = _item:GetChild("FrontIcon");
		else
			local _dock = ParaUI.GetUIObject("Dock");
			local _quicklaunch = _dock:GetChild("QuickLaunch");
			local _slot = _quicklaunch:GetChild("Slot"..Dock.DragNodeIndex);
			_icon = _slot:GetChild("Icon"..Dock.DragNodeIndex);
		end
		
		Dock.QuickLaunchDragIcon = _icon;
		
		if(Dock.QuickLaunchDragIcon ~= nil and Dock.QuickLaunchDragIcon:IsValid()) then
			_elapsedtime = _elapsedtime + deltatime; -- deltatime: 0.033333
			--if(_elapsedtime > 0.05) then
			if(true) then -- set on every frame move
				_elapsedtime = 0;
				local _icon = Dock.QuickLaunchDragIcon;
				local x, y, width, height = _icon:GetAbsPosition();
				local mouseX, mouseY = ParaUI.GetMousePosition();
				_icon.translationx = mouseX - x - Dock.QuickLaunchDragIconClickOffsetX * width / Dock.QuickLaunchDragIconSizeWidth;
				_icon.translationy = mouseY - y - Dock.QuickLaunchDragIconClickOffsetY * height / Dock.QuickLaunchDragIconSizeHeight;
			end
		end
	end
end

-- drag begin of menu application icon and quicklaunch bar icon
-- param isMenu: true for app icon dragged FROM menu app icons, false for app icon dragged FROM quicklaunch bar
-- param index: index into the menu node or quicklaunch bar node
-- param rows: rows index of quicklaunch bar, nil for app icons from menu
function Dock.OnAppDragBegin(isMenu, index, rows)
	-- Dock.ShowNotification(commonlib.serialize({isMenu, index, rows}));
	
	-- record the current icon
	Dock.DragNodeIsFromMenu = isMenu;
	Dock.DragNodeIndex = index;
	Dock.DragNodeRows = rows;
	
	if(isMenu == true) then
		-- visible backicon
		-- we assume all the objects are valid
		local _menu = ParaUI.GetUIObject(Dock.MenuName);
		local _item = _menu:GetChild("App"..index);
		local _backIcon = _item:GetChild("BackIcon");
		_backIcon.visible = true;
		
		-- get icon object
		local _menu = ParaUI.GetUIObject(Dock.MenuName);
		local _item = _menu:GetChild("App"..index);
		_item:BringToFront(); --  front of other slots, so allow icon over other slots when translation
		local _icon = _backIcon; -- _item:GetChild("FrontIcon"); -- use backicon as the position counter, FrontIcon is dragged off the container
		local x, y, width, height = _icon:GetAbsPosition();
		local mouseX, mouseY = ParaUI.GetMousePosition();
		-- record offset proportion
		--Dock.QuickLaunchDragIcon = Dock.QuickLaunchDragIcon or _icon;
		Dock.QuickLaunchDragIconClickOffsetX = Dock.QuickLaunchDragIconClickOffsetX or (mouseX - x);
		Dock.QuickLaunchDragIconClickOffsetY = Dock.QuickLaunchDragIconClickOffsetY or (mouseY - y);
		Dock.QuickLaunchDragIconSizeWidth = Dock.QuickLaunchDragIconSizeWidth or width;
		Dock.QuickLaunchDragIconSizeHeight = Dock.QuickLaunchDragIconSizeHeight or height;
	else
		local node = Dock.QuickLaunchNode:GetChild(index);
		if(node.app_key == nil) then
			-- drag from an empty quicklaunch bar icon
			Dock.DragNodeIsFromMenu = nil;
			Dock.DragNodeIndex = nil;
			Dock.DragNodeRows = nil;
			return;
		end
		-- get icon object
		local _dock = ParaUI.GetUIObject("Dock");
		local _quicklaunch = _dock:GetChild("QuickLaunch");
		local _slot = _quicklaunch:GetChild("Slot"..index);
		_slot:BringToFront(); --  front of other slots so allow icon over other slots when translation
		--local _icon = _slot:GetChild("Icon"..index);
		--local x, y, width, height = _icon:GetAbsPosition();
		local x, y, width, height = _slot:GetAbsPosition();
		x = x + 8;
		y = y + 8;
		width = width - 16;
		height = height - 16;
		local mouseX, mouseY = ParaUI.GetMousePosition();
		-- record offset
		--Dock.QuickLaunchDragIcon = Dock.QuickLaunchDragIcon or _icon;
		Dock.QuickLaunchDragIconClickOffsetX = Dock.QuickLaunchDragIconClickOffsetX or (mouseX - x);
		Dock.QuickLaunchDragIconClickOffsetY = Dock.QuickLaunchDragIconClickOffsetY or (mouseY - y);
		Dock.QuickLaunchDragIconSizeWidth = Dock.QuickLaunchDragIconSizeWidth or width;
		Dock.QuickLaunchDragIconSizeHeight = Dock.QuickLaunchDragIconSizeHeight or height;
	end
	
	-- visible the click receiver object
	local _clickRecv = ParaUI.GetUIObject(Dock.ClickReceiverName);
	_clickRecv.visible = true;
end

-- drag move of menu application icon and quicklaunch bar icon
function Dock.OnAppDragMove()
end

-- drag end of menu application icon and quicklaunch bar icon
function Dock.OnAppDragEnd()
	local isMenu = Dock.DragNodeIsFromMenu;
	local index = Dock.DragNodeIndex;
	local rows = Dock.DragNodeRows;
	
	if(isMenu == nil and index == nil and rows == nil) then
		-- invalid dragging process
		return;
	end
	
	if(isMenu == true) then
		-- invisible backicon
		-- we assume all the objects are valid
		local _menu = ParaUI.GetUIObject(Dock.MenuName);
		local _item = _menu:GetChild("App"..index);
		local _backIcon = _item:GetChild("BackIcon");
		_backIcon.visible = false;
	end
	
	-- click receiver object
	local _clickRecv = ParaUI.GetUIObject(Dock.ClickReceiverName);
	
	if(isMenu == true) then
		-- dragged from menu app icons
		local menuNode = Dock.MenuNode:GetChild(index);
		
		-- get quick lauch bar position
		local _dock = ParaUI.GetUIObject("Dock");
		local _quicklaunch = _dock:GetChild("QuickLaunch");
		local x, y, width, height = _quicklaunch:GetAbsPosition();
		width = width - 32; -- 32 for scrolling and locking
		local mouseX, mouseY = ParaUI.GetMousePosition();
		local isOver = false;
		if((mouseX >= x) and (mouseX < (x + width)) and (mouseY >= y) and (mouseY < (y + height))) then
			isOver = true;
		end
		
		-- check if over quicklaunch bar
		if(isOver == true) then
			-- get the icon area
			local targetIndex = math.floor((mouseX - x)/(width/10)) + 1;
			-- check if the icon is empty
			local quickLaunchNode = Dock.QuickLaunchNode:GetChild(targetIndex);
			local isEmpty = true;
			if(quickLaunchNode.app_key ~= nil) then
				isEmpty = false;
			end
			if(isEmpty == true) then
				-- assign application key
				quickLaunchNode.app_key = menuNode.app_key;
				-- assign quick launch icon background
				local _dock = ParaUI.GetUIObject("Dock");
				local _quicklaunch = _dock:GetChild("QuickLaunch");
				local _slot = _quicklaunch:GetChild("Slot"..targetIndex);
				local _icon = _slot:GetChild("Icon"..targetIndex);
				local app = System.App.AppManager.GetApp(quickLaunchNode.app_key);
				_icon.background = app.icon or app.Icon;
				_icon.tooltip = app.Title;
				-- hide the full screen click receiver
				_clickRecv.visible = false;
				-- reset the current icon dragging information
				Dock.DragNodeIsFromMenu = nil;
				Dock.DragNodeIndex = nil;
				Dock.DragNodeRows = nil;

				if(Dock.QuickLaunchDragIcon ~= nil and Dock.QuickLaunchDragIcon:IsValid()) then
					Dock.QuickLaunchDragIcon.translationx = 0;
					Dock.QuickLaunchDragIcon.translationy = 0;
					Dock.QuickLaunchDragIcon.scalingx = 1;
					Dock.QuickLaunchDragIcon.scalingy = 1;
				end
				Dock.IsSnapToCursor = false;
				Dock.QuickLaunchDragIcon = nil;
				Dock.QuickLaunchDragIconClickOffsetX = nil;
				Dock.QuickLaunchDragIconClickOffsetY = nil;
				Dock.QuickLaunchDragIconSizeWidth = nil;
				Dock.QuickLaunchDragIconSizeHeight = nil;
			else
				-- TODO: create button at icon area and begin another drag process 
				
				-- assign application key
				local temp = quickLaunchNode.app_key;
				quickLaunchNode.app_key = menuNode.app_key;
				-- assign quick launch icon background
				local _dock = ParaUI.GetUIObject("Dock");
				local _quicklaunch = _dock:GetChild("QuickLaunch");
				local _slot = _quicklaunch:GetChild("Slot"..targetIndex);
				local _icon = _slot:GetChild("Icon"..targetIndex);
				local app = System.App.AppManager.GetApp(quickLaunchNode.app_key);
				_icon.background = app.icon or app.Icon;
				_icon.tooltip = app.Title;
				
				local i;
				local nCount = Dock.MenuNode:GetChildCount();
				for i = 1, nCount do
					local node = Dock.MenuNode:GetChild(i);
					if(node.app_key == temp) then
						index = i;
						break;
					end
				end
				
				Dock.OnAppDragBegin(true, index);
				Dock.IsSnapToCursor = true;
			end
		else
			-- floating icon with cursor
			Dock.OnAppDragBegin(true, index);
			Dock.IsSnapToCursor = true;
		end
	else
		-- dragged from quicklaunch bar app icons
		local quickLaunchNodeSrc = Dock.QuickLaunchNode:GetChild(index);
		
		-- get quick lauch bar position
		local _dock = ParaUI.GetUIObject("Dock");
		local _quicklaunch = _dock:GetChild("QuickLaunch");
		local x, y, width, height = _quicklaunch:GetAbsPosition();
		width = width - 32; -- 32 for scrolling and locking
		local mouseX, mouseY = ParaUI.GetMousePosition();
		local isOver = false;
		if((mouseX >= x) and (mouseX < (x + width)) and (mouseY >= y) and (mouseY < (y + height))) then
			isOver = true;
		end
		
		-- check if over quicklaunch bar
		if(isOver == true) then
			-- get the icon area
			local targetIndex = math.floor((mouseX - x)/(width/10)) + 1;
			-- check if the icon is empty
			local quickLaunchNodeDest = Dock.QuickLaunchNode:GetChild(targetIndex);
			local isEmpty = true;
			if(quickLaunchNodeDest.app_key ~= nil) then
				isEmpty = false;
			end
			if(isEmpty == true) then
				-- assign application key
				quickLaunchNodeDest.app_key = quickLaunchNodeSrc.app_key;
				-- assign quick launch icon background
				local _dock = ParaUI.GetUIObject("Dock");
				local _quicklaunch = _dock:GetChild("QuickLaunch");
				local _slot = _quicklaunch:GetChild("Slot"..targetIndex);
				local _icon = _slot:GetChild("Icon"..targetIndex);
				local app = System.App.AppManager.GetApp(quickLaunchNodeDest.app_key);
				_icon.background = app.icon or app.Icon;
				_icon.tooltip = app.Title;
				
				-- delete application key
				quickLaunchNodeSrc.app_key = nil;
				-- delete quick launch icon background
				local _slot = _quicklaunch:GetChild("Slot"..index);
				local _icon = _slot:GetChild("Icon"..index);
				_icon.background = "";
				_icon.tooltip = "将一个已安装的APP图标拖拽到这里（此版本尚未开放）";
				_icon.translationx = 0;
				_icon.translationy = 0;
				_icon.onclick = nil;
				-- hide the full screen click receiver
				_clickRecv.visible = false;
				-- reset the current icon dragging information
				Dock.DragNodeIsFromMenu = nil;
				Dock.DragNodeIndex = nil;
				Dock.DragNodeRows = nil;
				-- reset quick launch bar icon during click drag process
				Dock.IsSnapToCursor = false;
				Dock.QuickLaunchDragIcon = nil;
				Dock.QuickLaunchDragIconClickOffsetX = nil;
				Dock.QuickLaunchDragIconClickOffsetY = nil;
				Dock.QuickLaunchDragIconSizeWidth = nil;
				Dock.QuickLaunchDragIconSizeHeight = nil;
			else
				-- drag on self
				if(targetIndex == index) then
					local _dock = ParaUI.GetUIObject("Dock");
					local _quicklaunch = _dock:GetChild("QuickLaunch");
					local _slot = _quicklaunch:GetChild("Slot"..targetIndex);
					local _icon = _slot:GetChild("Icon"..targetIndex);
					_icon.translationx = 0;
					_icon.translationy = 0;
					-- reset the current icon dragging information
					Dock.DragNodeIsFromMenu = nil;
					Dock.DragNodeIndex = nil;
					Dock.DragNodeRows = nil;
					-- reset quick launch bar icon during click drag process
					Dock.IsSnapToCursor = false;
					Dock.QuickLaunchDragIcon = nil;
					Dock.QuickLaunchDragIconClickOffsetX = nil;
					Dock.QuickLaunchDragIconClickOffsetY = nil;
					Dock.QuickLaunchDragIconSizeWidth = nil;
					Dock.QuickLaunchDragIconSizeHeight = nil;
					
					-- finish process
					_clickRecv.visible = false;
					return;
				end
				-- keep drag process and swap app_key and icon
				
				-- swap application key
				local temp = quickLaunchNodeSrc.app_key;
				quickLaunchNodeSrc.app_key = quickLaunchNodeDest.app_key;
				quickLaunchNodeDest.app_key = temp;
				-- assign quick launch icon background
				local _dock = ParaUI.GetUIObject("Dock");
				local _quicklaunch = _dock:GetChild("QuickLaunch");
				local _slot = _quicklaunch:GetChild("Slot"..targetIndex);
				local _icon = _slot:GetChild("Icon"..targetIndex);
				local app = System.App.AppManager.GetApp(quickLaunchNodeDest.app_key);
				_icon.background = app.icon or app.Icon;
				_icon.tooltip = app.Title;
				-- delete quick launch icon background
				local _slot = _quicklaunch:GetChild("Slot"..index);
				local _icon = _slot:GetChild("Icon"..index);
				local app = System.App.AppManager.GetApp(quickLaunchNodeSrc.app_key);
				_icon.background = app.icon or app.Icon;
				_icon.tooltip = app.Title;
				
				_icon.translationx = 0;
				_icon.translationy = 0;
				-- reset the current icon dragging information
				Dock.DragNodeIsFromMenu = nil;
				Dock.DragNodeIndex = nil;
				Dock.DragNodeRows = nil;
				-- reset quick launch bar icon during click drag process
				Dock.IsSnapToCursor = false;
				Dock.QuickLaunchDragIcon = nil;
				Dock.QuickLaunchDragIconClickOffsetX = nil;
				Dock.QuickLaunchDragIconClickOffsetY = nil;
				Dock.QuickLaunchDragIconSizeWidth = nil;
				Dock.QuickLaunchDragIconSizeHeight = nil;
				
				-- finish process
				_clickRecv.visible = false;
				return;
			end
		else
			-- floating icon with cursor
			Dock.OnAppDragBegin(false, index);
			Dock.IsSnapToCursor = true;
		end
	end
end

function Dock.OnClickReceiverClick()
	-- Dock.ShowNotification("Dock.OnClickReceiverClick");

	local _dock = ParaUI.GetUIObject("Dock");
	local x, y, width, height = _dock:GetAbsPosition();
	
	local mouseX, mouseY = ParaUI.GetMousePosition();
	
	local isOver = false;
	if((mouseX >= x) and (mouseX < (x + width)) and (mouseY >= y) and (mouseY < (y + height))) then
		isOver = true;
	end
	if(isOver == true) then
		local _icon;
		if(Dock.DragNodeIsFromMenu == true) then
			local _menu = ParaUI.GetUIObject(Dock.MenuName);
			local _item = _menu:GetChild("App"..Dock.DragNodeIndex);
			_icon = _item:GetChild("FrontIcon");
			_icon.translationx = 0;
			_icon.translationy = 0;
		end
		Dock.OnAppDragEnd();
	else
		local _icon;
		if(Dock.DragNodeIsFromMenu == true) then
			local _menu = ParaUI.GetUIObject(Dock.MenuName);
			local _item = _menu:GetChild("App"..Dock.DragNodeIndex);
			_icon = _item:GetChild("FrontIcon");
			_icon.translationx = 0;
			_icon.translationy = 0;
		else
			local _dock = ParaUI.GetUIObject("Dock");
			local _quicklaunch = _dock:GetChild("QuickLaunch");
			local _slot = _quicklaunch:GetChild("Slot"..Dock.DragNodeIndex);
			_icon = _slot:GetChild("Icon"..Dock.DragNodeIndex);
			_icon.background = "";
			_icon.tooltip = "将一个已安装的APP图标拖拽到这里（此版本尚未开放）";
			_icon.translationx = 0;
			_icon.translationy = 0;
			local node = Dock.QuickLaunchNode:GetChild(Dock.DragNodeIndex);
			node.app_key = nil;
		end
		
		-- reset the current icon dragging information
		Dock.DragNodeIsFromMenu = nil;
		Dock.DragNodeIndex = nil;
		Dock.DragNodeRows = nil;
		-- reset quick launch bar icon during click drag process
		Dock.IsSnapToCursor = false;
		Dock.QuickLaunchDragIcon = nil;
		Dock.QuickLaunchDragIconClickOffsetX = nil;
		Dock.QuickLaunchDragIconClickOffsetY = nil;
		Dock.QuickLaunchDragIconSizeWidth = nil;
		Dock.QuickLaunchDragIconSizeHeight = nil;
		
		-- finish process
		local _clickRecv = ParaUI.GetUIObject(Dock.ClickReceiverName);
		_clickRecv.visible = false;
	end
end

-- onclick callback of quick launch icon
function Dock.OnClickQuickLaunchItem(index)
	local node = Dock.QuickLaunchNode:GetChild(index);
	if(not node) then 
		return;
	end
	if(node.app_key) then
		Dock.SwitchApp(node.app_key);
	elseif(node.AppCommand) then
		Map3DSystem.App.Commands.Call(node.AppCommand);
	end
end

-- onclick callback of menu icon
function Dock.OnClickMenuItem(index)
	local node = Dock.MenuNode:GetChild(index);
	if(not node) then 
		return;
	end
	Dock.ToggleMenu(false);
	Dock.SwitchApp(node.app_key);
end

NPL.load("(gl)script/kids/3DMapSystemUI/Desktop/AppTaskBar.lua");
System.UI.AppTaskBar.CurrentAppDesktop = nil;

--Dock.AddCommand();
--Dock.ClearToolBar();
--Dock.RefreshToolbar();
--
--Dock.AddAppMenuItemsToToolBar();

-- switch to a given application exclusive desktop mode. We can optionally save last screen to texture for switching back display.
-- internally it just send APP_DEACTIVATE_DESKTOP message to the old app, and APP_ACTIVATE_DESKTOP message to the new application.
-- The new application is expected to add commands to app toolbar via Dock.AddCommand() before the message returns. 
-- Note1: The app toolbar will by default display all application menu items, unless an application explicitly 
--		specifies its toolbar content inside APP_ACTIVATE_DESKTOP message handler. 
-- Note2: The application can change the toolbar content at any time, by calling Dock.ClearToolBar(), adding new commands 
--		and then calling Dock.RefreshToolbar()
-- @param app_key: the application key. if key is the same as current, it will refresh anyway. if nil, it will clear desktop
function Dock.SwitchApp(app_key)
	if(app_key == "Creator_GUID" or app_key == "Blueprint_GUID") then
		local worldPath = ParaWorld.GetWorldDirectory();
		if(worldPath == "worlds/MyWorlds/AlphaWorld/") then
			_guihelper.MessageBox("您不能在公共场景中创造\n请找传送大使将你传送到涂鸦世界\n");
			return;
		end
	end
	if(System.UI.AppTaskBar.CurrentAppDesktop and (System.UI.AppTaskBar.CurrentAppDesktop ~= app_key)) then
		-- Deactivate the old desktop
		local app = System.App.AppManager.GetApp(System.UI.AppTaskBar.CurrentAppDesktop);
		if(app) then
			app:SendMessage({type = System.App.MSGTYPE.APP_DEACTIVATE_DESKTOP});
		end
	end
	
	-- switch to current app
	System.UI.AppTaskBar.CurrentAppDesktop = app_key;
	
	-- clear toolbar since we will rebuild them
	System.UI.AppTaskBar.ClearToolBar();
	
	-- load default desktop settings, such as desktop mode is set to "game" for all applications. 
	-- load default desktop mode
	System.UI.AppDesktop.ChangeMode("game")
	
	if(not System.UI.AppTaskBar.CurrentAppDesktop) then return end
	
	local app = System.App.AppManager.GetApp(System.UI.AppTaskBar.CurrentAppDesktop);
	if(not app) then return end
	
	-- send a activate desktop message to the current application, we will expect the application to have added toolbar commands after this message returns.
	app:SendMessage({type = System.App.MSGTYPE.APP_ACTIVATE_DESKTOP});
	
	if(System.UI.AppTaskBar.ToolbarNode:GetChildCount() == 0) then
		-- if the current application does not provide any toolbar commands inside its APP_ACTIVATE_DESKTOP message handler, 
		-- we will extract all menu commands related to this application. If there is still none, the menu bar will be refreshed empty. 
		--System.UI.AppTaskBar.AddAppMenuItemsToToolBar(System.UI.AppTaskBar.CurrentAppDesktop);
		
		local appCommand;
		local count = 0;
		for appCommand in System.UI.MainMenu.GetAppCommands(System.UI.AppTaskBar.CurrentAppDesktop) do
			if(appCommand.ButtonText) then
				count = count + 1;
				-- only display those with at least text and an optional icon. 
				System.UI.AppTaskBar.AddCommand(appCommand, "toolbar.menu"..count)
			end	
		end
	end
	
	-- refresh toolbar for this application. 
	Dock.RefreshToolbar();
	
	-- set current app icon
	local _dock = ParaUI.GetUIObject("Dock");
	local _currentapp = _dock:GetChild("CurrentApp");
	local _icon = _currentapp:GetChild("Icon");
	_icon.background = app.icon or app.Icon;
	_icon.tooltip = app.Title;
	
	local block = UIDirectAnimBlock:new();
	block:SetUIObject(_icon);
	block:SetTime(200);
	block:SetScalingXRange(2, 1);
	block:SetScalingYRange(2, 1);
	block:SetAlphaRange(0, 1);
	UIAnimManager.PlayDirectUIAnimation(block);
	
	-- TODO: close the windows first or the toolbar
	-- quit current app
	System.PushState({name = "QuitApp", OnEscKey = Dock.QuitApp});
end

function Dock.QuitApp()
	ParaUI.Destroy("AquariusToolBar");
	Dock.SwitchApp();
	
	-- clear current app icon
	local _dock = ParaUI.GetUIObject("Dock");
	local _currentapp = _dock:GetChild("CurrentApp");
	local _icon = _currentapp:GetChild("Icon");
	
	local block = UIDirectAnimBlock:new();
	block:SetUIObject(_icon);
	block:SetTime(200);
	block:SetScalingXRange(1, 2);
	block:SetScalingYRange(1, 2);
	block:SetAlphaRange(1, 0);
	block:SetCallback(function ()
		_icon.background = "";
	end);
	UIAnimManager.PlayDirectUIAnimation(block);
end

function Dock.RefreshToolbar()
	
	ParaUI.Destroy("AquariusToolBar");
	
	local nCount = System.UI.AppTaskBar.ToolbarNode:GetChildCount();
	
	local i;
	local index = 0;
	for i = 1, nCount do
		local node = System.UI.AppTaskBar.ToolbarNode:GetChild(i);
		if(node.Type ~= "separator") then
			index = index + 1;
		end
	end
	nCount = index;
	
	local totalWidth = 10 + 40 * nCount + 10;
	local _toolbar = ParaUI.CreateUIObject("container", "AquariusToolBar", "_ctb", 21, -48, totalWidth, 51)
	_toolbar.background = "";
	--_toolbar.background = "Texture/Aquarius/Desktop/Dock_CurrentApp_Panel_32bits.png;0 0 128 51: 16 20 16 20";
	_toolbar.zorder = 2;
	_toolbar:AttachToRoot();
	
	local _left = ParaUI.CreateUIObject("container", "Left", "_lt", 0, 0, (totalWidth - 56) / 2, 51)
	_left.background = "Texture/Aquarius/Desktop/Dock_CurrentApp_Panel_32bits.png;0 0 36 51: 16 20 1 20";
	_left.enabled = false;
	_toolbar:AddChild(_left);
	local _middle = ParaUI.CreateUIObject("container", "Middle", "_lt", (totalWidth - 56) / 2, 0, 56, 51)
	_middle.background = "Texture/Aquarius/Desktop/Dock_CurrentApp_Panel_32bits.png;36 0 56 51";
	_middle.enabled = false;
	_toolbar:AddChild(_middle);
	local _right = ParaUI.CreateUIObject("container", "Right", "_lt", (totalWidth + 56) / 2, 0, (totalWidth - 56) / 2, 51)
	_right.background = "Texture/Aquarius/Desktop/Dock_CurrentApp_Panel_32bits.png;92 0 36 51: 1 20 16 20";
	_right.enabled = false;
	_toolbar:AddChild(_right);
	
	local nCount = System.UI.AppTaskBar.ToolbarNode:GetChildCount();
	local i;
	local index = 0;
	for i = 1, nCount do
		local node = System.UI.AppTaskBar.ToolbarNode:GetChild(i);
		if(node.Type ~= "separator") then
			local _bg = ParaUI.CreateUIObject("container", "BG", "_lt", 10 + 40 * index, 4, 41, 41);
			_bg.background = "Texture/Aquarius/Desktop/UtilBar2_Slot_32bits.png; 0 0 40 40";
			_bg.enabled = false;
			_toolbar:AddChild(_bg);
			local _icon = ParaUI.CreateUIObject("button", "Icon"..i, "_lt", 10 + 40 * index + 4, 8, 32, 32)
			_icon.background = node.icon or node.Icon;
			_icon.tooltip = node.tooltip or node.Text;
			_icon.onclick = ";MyCompany.Aquarius.Desktop.Dock.OnClickToolbarIcon("..i..");";
			_icon.animstyle = 12;
			_toolbar:AddChild(_icon);
			index = index + 1;
		end
	end
	
	--_toolbar.width = 10 + 40 * index + 10;
	
	local block = UIDirectAnimBlock:new();
	block:SetUIObject(_toolbar);
	block:SetTime(200);
	block:SetTranslationYRange(48, 0);
	block:SetApplyAnim(true);
	UIAnimManager.PlayDirectUIAnimation(block);
end


function Dock.OnClickToolbarIcon(index)
	local node = System.UI.AppTaskBar.ToolbarNode:GetChild(index);
	if(node) then
		if(type(node.onclick) == "function") then
			node.onclick(node);
		elseif(node.AppCommand) then
			node.AppCommand:Call();
		end	
	end
end


-- notification count downs, if the count reach 0, the notification will play a hide animation
-- each time the notification is shown, the countdown is refresh to 3 seconds
-- the NotificationCountDown is initially negative indicating the notification is active until the count is up
-- this is specially useful when user don't want to show some presense or feed information on start up
Dock.NotificationCountDown = -2;

-- show the notification bubble over the UtilBar2
-- @param msg: the msg to display, currently only text is applied
-- @param CommandOrDostring: app command or dostring, nil indicating the notification is not clickable
function Dock.ShowNotification(msgOrOwnerDraw, CommandOrDostringOrFunction)
	if(type(Dock.NotificationCountDown) == "number" and Dock.NotificationCountDown < 0) then
		-- the NotificationCountDown is initially negative indicating the notification is active until the count is up
		-- this is specially useful when user don't want to show some presense or feed information on start up
		return;
	end
	local _notification = ParaUI.GetUIObject("AquariusNotification");
	if(_notification:IsValid() == false ) then
		_notification = ParaUI.CreateUIObject("container", "AquariusNotification", "_ctb", 390, -70, 200, 128);
		_notification.background = "";
		_notification.zorder = 1;
		_notification:AttachToRoot();
		local _BG = ParaUI.CreateUIObject("container", "BG", "_fi", -20, -15, -19, -24);
		_BG.background = "Texture/Aquarius/Common/ContextMenu_BG_32bits.png: 31 27 31 36";
		_notification:AddChild(_BG);
	end
	
	_notification.visible = true;
	
	local _text = _notification:GetChild("text");
	if(_text:IsValid() == true) then
		_text.text = "";
	end
	local _ownerDrawCanvas = _notification:GetChild("OwnerDrawCanvas");
	if(_ownerDrawCanvas:IsValid() == true) then
		_ownerDrawCanvas:RemoveAll();
	end
	if(type(msgOrOwnerDraw) == "string") then
		local _text = _notification:GetChild("text");
		if(_text:IsValid() == false) then
			_text = ParaUI.CreateUIObject("button", "text", "_fi", 20, 20, 20, 20);
			_text.background = "";
			_notification:AddChild(_text);
		end
		_text.text = msgOrOwnerDraw;
		_text.onclick = ";MyCompany.Aquarius.Desktop.Dock.DoClickNotification()";
		if(CommandOrDostringOrFunction ~= nil) then
			_text.enabled = false;
		else
			_text.enabled = true;
		end
	elseif(type(msgOrOwnerDraw) == "function") then
		local _ownerDrawCanvas = _notification:GetChild("OwnerDrawCanvas");
		if(_ownerDrawCanvas:IsValid() == false) then
			_ownerDrawCanvas = ParaUI.CreateUIObject("container", "OwnerDrawCanvas", "_fi", 0, 0, 0, 0);
			_ownerDrawCanvas.background = "";
			_notification:AddChild(_ownerDrawCanvas);
		end
		_ownerDrawCanvas:RemoveAll();
		
		msgOrOwnerDraw(_ownerDrawCanvas);
	end
	
	Dock.NotificationCallback = CommandOrDostringOrFunction;
	
	if(Dock.NotificationCountDown == nil) then
		-- skip animation if the notification box is already shown on screen
		local block = UIDirectAnimBlock:new();
		block:SetUIObject(_notification);
		block:SetTime(200);
		block:SetAlphaRange(0, 1);
		block:SetTranslationYRange(128, 0);
		block:SetApplyAnim(true); 
		UIAnimManager.PlayDirectUIAnimation(block);
	end
	
	Dock.NotificationCountDown = 3;
end

function Dock.DoClickNotification()
	local callback = Dock.NotificationCallback;
	if(type(callback) == "string") then
		-- this is a onclick string, DoString
		NPL.DoString(callback);
	elseif(type(callback) == "function") then
		-- this is a function, call directly
		callback();
	elseif(type(callback) == "table") then
		-- this is a command, call directly
		callback:Call();
	end
	
	if(Dock.NotificationCountDown ~= nil) then
		Dock.NotificationCountDown = 0.2;
	end
end

function Dock.RegisterDoNotificationTimer()
	-- set OnRoster message timer
	NPL.SetTimer(9431, 0.2, ";MyCompany.Aquarius.Desktop.Dock.DoNotificationTimer();");
end

-- bubble count downs, if the count reach 0, the bubble will play a hide animation
function Dock.DoNotificationTimer()
	if(Dock.NotificationCountDown ~= nil) then
		if(Dock.NotificationCountDown < 0) then
			-- the NotificationCountDown is initially negative indicating the notification is active until the count is up
			-- this is specially useful when user don't want to show some presense or feed information on start up
			Dock.NotificationCountDown = Dock.NotificationCountDown + 0.2;
			return;
		end
		Dock.NotificationCountDown = Dock.NotificationCountDown - 0.2;
		if(Dock.NotificationCountDown <= 0) then
			Dock.NotificationCountDown = nil;
			Dock.NotificationCallback = nil;
			local _notification = ParaUI.GetUIObject("AquariusNotification");
			if(_notification:IsValid() == true) then
				local block = UIDirectAnimBlock:new();
				block:SetUIObject(_notification);
				block:SetTime(150);
				block:SetAlphaRange(1, 0);
				block:SetTranslationYRange(0, 128);
				block:SetApplyAnim(true); 
				block:SetCallback(function ()
					_notification.visible = false;
				end); 
				UIAnimManager.PlayDirectUIAnimation(block);
			end
		end
	end
end