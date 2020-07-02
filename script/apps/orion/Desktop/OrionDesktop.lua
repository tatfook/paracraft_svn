--[[
Title: Desktop UI for Orion App
Author(s): WangTian, LiXizhi
Date: 2008/11/21
Desc: The desktop UI contains 
	1. left top area: current user role icon and profile
	2. left middle area: current role functions
	3. right top area: mini map and status
	4. middle bottom area: always on top function list
	5. top middle area: time since playing
Area: 
	-----------------------------------------------------
	| Profile				Timer				Mini Map|
	| Role										 Status |
	| T													|
	| o													|
	| o													|
	| l													|
	| b													|
	| a													|
	| r													|
	|													|
	|													|
	|													|
	|													|
	|						Dock						|
	-----------------------------------------------------
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Orion/Desktop/OrionDesktop.lua");
MyCompany.Orion.Desktop.InitDesktop();
MyCompany.Orion.Desktop.SendMessage({type = MyCompany.Orion.Desktop.MSGTYPE.SHOW_DESKTOP, bShow = true});
------------------------------------------------------------
]]

-- create class
local libName = "OrionDesktop";
local Desktop = {};
commonlib.setfield("MyCompany.Orion.Desktop", Desktop);

-- messge types
Desktop.MSGTYPE = {
	-- show/hide the task bar, 
	-- msg = {bShow = true}
	SHOW_DESKTOP = 1001,
};
 
-- register a timer for time played countup and update the hour and minute text
function Desktop.DoCountTime()
	local date = ParaGlobal.GetDateFormat("yyyy-M-d");
	local readdate = MyCompany.Orion.app:ReadConfig("Date", nil);
	if(readdate == date) then
		-- continue with the last time count
		local minutes = MyCompany.Orion.app:ReadConfig("Minutes", nil);
		minutes = minutes + 1;
		MyCompany.Orion.app:WriteConfig("Minutes", minutes);
		-- update the hour and minute texts if exist
		local _hour = ParaUI.GetUIObject(Desktop.timehour_id);
		if(_hour:IsValid() == true) then
			_hour.text = math.floor(minutes/60).."";
		end
		local _minute = ParaUI.GetUIObject(Desktop.timeminute_id);
		if(_minute:IsValid() == true) then
			_minute.text = math.mod(minutes, 60).."";
		end
	else
		-- start count of the day
		MyCompany.Orion.app:WriteConfig("Date", date);
		MyCompany.Orion.app:WriteConfig("Minutes", 0);
	end
end

-- call this only once at the beginning of the game. 
-- init main bar: this does not show the task bar, it just builds the data structure and messaging system.
function Desktop.InitDesktop()
	if(Desktop.IsInit) then return end
	Desktop.IsInit = true;
	Desktop.name = libName;
	
	-- register a timer for time played count
	NPL.SetTimer(15431, 60, ";MyCompany.Orion.Desktop.DoCountTime();");
	
	-- create the root node for data keeping.
	Desktop.RootNode = CommonCtrl.TreeNode:new({Name = "root", Icon = "", });
	Desktop.ProfileNode = Desktop.RootNode:AddChild(CommonCtrl.TreeNode:new({text = "人物头像栏", name = "Profile"}));
	Desktop.RoleNode = Desktop.RootNode:AddChild(CommonCtrl.TreeNode:new({text = "变身卡", name = "Role"}));
		-- limited role nodes derived from the HelloChat application
		Desktop.RoleNode:AddChild(CommonCtrl.TreeNode:new({text = "主角", name = "Avatar", 
			icon = "Texture/3DMapSystem/AppIcons/People_64.dds", 
			file="script/apps/Orion/Roles/AvatarTab.html", }));
		Desktop.RoleNode:AddChild(CommonCtrl.TreeNode:new({text = "应用程序|媒体", name = "Media", 
			icon = "Texture/3DMapSystem/AppIcons/VideoRecorder_64.dds", 
			file="script/apps/Orion/Roles/MediaTab.html", }));
		Desktop.RoleNode:AddChild(CommonCtrl.TreeNode:new({text = "创造", name = "Creation", 
			icon = "Texture/3DMapSystem/AppIcons/painter_64.dds", 
			file="script/apps/Orion/Roles/CreationTab.html", }));
		Desktop.RoleNode:AddChild(CommonCtrl.TreeNode:new({text = "工具", name = "Tools", 
			icon = "Texture/3DMapSystem/AppIcons/Settings_64.dds", 
			file="script/apps/Orion/Roles/ToolsTab.html", }));
		Desktop.RoleNode:AddChild(CommonCtrl.TreeNode:new({text = "高级编辑器", name = "WorldBuilder", 
			icon = "Texture/3DMapSystem/AppIcons/Blueprint_64.dds", 
			file="script/apps/Orion/Roles/WorldBuilderTab.html", }));
		--Desktop.RoleNode:AddChild(CommonCtrl.TreeNode:new({text = "高级编辑器0", name = "WorldBuilder0", 
		--	icon = "Texture/3DMapSystem/AppIcons/Blueprint_64.dds", 
		--	file="script/apps/Orion/Roles/WorldBuilderTab.html", }));
				
	Desktop.ToolbarNode = Desktop.RootNode:AddChild(CommonCtrl.TreeNode:new({text = "变身操作", name = "Toolbar"}));
		Desktop.ToolbarNode:AddChild(CommonCtrl.TreeNode:new({text = "功能1", name = "Action1"}));
		Desktop.ToolbarNode:AddChild(CommonCtrl.TreeNode:new({text = "功能2", name = "Action2"}));
		Desktop.ToolbarNode:AddChild(CommonCtrl.TreeNode:new({text = "功能3", name = "Action3"}));
		Desktop.ToolbarNode:AddChild(CommonCtrl.TreeNode:new({text = "功能4", name = "Action4"}));
	Desktop.StatusNode = Desktop.RootNode:AddChild(CommonCtrl.TreeNode:new({text = "副操作栏", name = "Status"}));
		Desktop.StatusNode:AddChild(CommonCtrl.TreeNode:new({text = "我的首页", name = "Status1", 
			icon = "Texture/3DMapSystem/Desktop/StartPage.png", commandname = "Profile.Orion.HomePage"}));
		Desktop.StatusNode:AddChild(CommonCtrl.TreeNode:new({text = "星图", name = "Status2", 
			icon = "Texture/3DMapSystem/Desktop/StarMap.png", commandname = "File.Open.StarView"}));
		Desktop.StatusNode:AddChild(CommonCtrl.TreeNode:new({text = "当前世界服务器状态", name = "Status3", 
			icon = "Texture/3DMapSystem/common/transmit.png", commandname = "File.AutoLobbyPage"}));
		Desktop.StatusNode:AddChild(CommonCtrl.TreeNode:new({text = "显示/隐藏提示文字", name = "Status4", 
			icon = "Texture/3DMapSystem/common/bell.png", commandname = "Profile.ToggleAutotips"}));
		Desktop.StatusNode:AddChild(CommonCtrl.TreeNode:new({text = "显示/隐藏聊天窗口", name = "Status5", 
			icon = "Texture/3DMapSystem/common/chat.png", commandname = "Profile.Chat.MainWnd"}));
		Desktop.StatusNode:AddChild(CommonCtrl.TreeNode:new({text = "退出", name = "Status6", 
			icon = "Texture/3DMapSystem/common/shutdown.png", commandname = "File.Exit"}));
	Desktop.DockNode = Desktop.RootNode:AddChild(CommonCtrl.TreeNode:new({text = "主操作栏", name = "Dock"}));
		Desktop.DockNode:AddChild(CommonCtrl.TreeNode:new({text = "主操作1", name = "Dock1"}));
		Desktop.DockNode:AddChild(CommonCtrl.TreeNode:new({text = "主操作2", name = "Dock2"}));
		Desktop.DockNode:AddChild(CommonCtrl.TreeNode:new({text = "主操作3", name = "Dock3"}));
		Desktop.DockNode:AddChild(CommonCtrl.TreeNode:new({text = "主操作4", name = "Dock4"}));
		Desktop.DockNode:AddChild(CommonCtrl.TreeNode:new({text = "主操作5", name = "Dock5"}));
		Desktop.DockNode:AddChild(CommonCtrl.TreeNode:new({text = "主操作6", name = "Dock6"}));
		Desktop.DockNode:AddChild(CommonCtrl.TreeNode:new({text = "主操作7", name = "Dock7"}));
		Desktop.DockNode:AddChild(CommonCtrl.TreeNode:new({text = "主操作8", name = "Dock8"}));
	-- create windows for message handling
	NPL.load("(gl)script/ide/os.lua");
	local _app = CommonCtrl.os.CreateGetApp(Desktop.name);
	Desktop.App = _app;
	Desktop.MainWnd = _app:RegisterWindow("main", nil, Desktop.MSGProc);
end

-- send a message to Desktop:main window handler
-- Desktop.SendMessage({type = Desktop.MSGTYPE.MENU_SHOW});
function Desktop.SendMessage(msg)
	msg.wndName = "main";
	Desktop.App:SendMessage(msg);
end


-- Desktop window handler
function Desktop.MSGProc(window, msg)
	if(msg.type == Desktop.MSGTYPE.SHOW_DESKTOP) then
		-- show/hide the task bar, 
		--msg = {bShow = true}
		Desktop.Show(msg.bShow);
	end
end

-------------------------
-- protected
-------------------------

-- show or hide task bar UI
function Desktop.Show(bShow)
	local _bar, _this, _parent;
	local left,top,width,height;
	
	_this = ParaUI.GetUIObject(libName);
	if(_this:IsValid())then
		if(bShow==nil) then
			_this.visible = not _this.visible;
		else
			_this.visible = bShow;
		end
	else
		if( bShow == false)then
			return;
		end
		
		-- the border of the areas aligned to the screen, except Dock
		local borderLeft, borderRight, borderTop = 1, 1, 1;
		
		-- Profile area
		local _profile = ParaUI.CreateUIObject("container", "ProfileArea", "_lt", borderLeft, borderTop, 420, 124);
		_profile.background = "";
		_profile:AttachToRoot();
			local _portrait = ParaUI.CreateUIObject("container", "Portrait", "_lt", 0, 0, 124, 124);
			_portrait.background = "Texture/Orion/ProfileCharIcon_BG.png; 2 2 124 124";
			_profile:AddChild(_portrait);
				local _icon = ParaUI.CreateUIObject("button", "Portrait", "_lt", 14, 14, 96, 96);
				_icon.background = "Texture/3DMapSystem/common/png-1472.png";
				_portrait:AddChild(_icon);
			local _name = ParaUI.CreateUIObject("button", "Name", "_lt", 124, 12, 108, 34);
			_name.background = "Texture/Orion/TimePlayed.png:15 15 15 15";
			_name.text = "李小多";
			_name.font = "System;18;bold";
			_guihelper.SetFontColor(_name, "255 215 0");
			_profile:AddChild(_name);
			local _apperence = ParaUI.CreateUIObject("container", "Apperence", "_lt", 124, 50, 288, 68);
			_apperence.background = "Texture/Orion/ProfileCharAppearance_BG.png:30 30 30 30";
			_profile:AddChild(_apperence);
				
				local _bg = ParaUI.CreateUIObject("container", "Apperence", "_lt", 10, 10, 48, 48);
				_bg.background = "Texture/Orion/ProfileCharItem_BG.png:15 15 15 15";
				_apperence:AddChild(_bg);
				local _hat = ParaUI.CreateUIObject("button", "Hat", "_lt", 10, 10, 48, 48);
				_hat.background = "Texture/Orion/IT_Head.png";
				--_hat.text = "帽子";
				_apperence:AddChild(_hat);
				local _bg = ParaUI.CreateUIObject("container", "Apperence", "_lt", 10 + 48 + 7, 10, 48, 48);
				_bg.background = "Texture/Orion/ProfileCharItem_BG.png:15 15 15 15";
				_apperence:AddChild(_bg);
				local _shirt = ParaUI.CreateUIObject("button", "Shirt", "_lt", 10 + 48 + 7, 10, 48, 48);
				_shirt.background = "Texture/Orion/IT_Chest.png";
				--_shirt.text = "衣服";
				_apperence:AddChild(_shirt);
				local _bg = ParaUI.CreateUIObject("container", "Apperence", "_lt", 10 + (48 + 7) * 2, 10, 48, 48);
				_bg.background = "Texture/Orion/ProfileCharItem_BG.png:15 15 15 15";
				_apperence:AddChild(_bg);
				local _gloves = ParaUI.CreateUIObject("button", "Gloves", "_lt", 10 + (48 + 7) * 2, 10, 48, 48);
				_gloves.background = "Texture/Orion/IT_Gloves.png";
				--_gloves.text = "手套";
				_apperence:AddChild(_gloves);
				local _bg = ParaUI.CreateUIObject("container", "Apperence", "_lt", 10 + (48 + 7) * 3, 10, 48, 48);
				_bg.background = "Texture/Orion/ProfileCharItem_BG.png:15 15 15 15";
				_apperence:AddChild(_bg);
				local _pants = ParaUI.CreateUIObject("button", "Pants", "_lt", 10 + (48 + 7) * 3, 10, 48, 48);
				_pants.background = "Texture/Orion/IT_Pants.png";
				--_pants.text = "裤子";
				_apperence:AddChild(_pants);
				local _bg = ParaUI.CreateUIObject("container", "Apperence", "_lt", 10 + (48 + 7) * 4, 10, 48, 48);
				_bg.background = "Texture/Orion/ProfileCharItem_BG.png:15 15 15 15";
				_apperence:AddChild(_bg);
				local _boots = ParaUI.CreateUIObject("button", "Boots", "_lt", 10 + (48 + 7) * 4, 10, 48, 48);
				_boots.background = "Texture/Orion/IT_Boots.png";
				--_boots.text = "鞋";
				_apperence:AddChild(_boots);
		
		-- TODO: should read from XML file. I just hard code here. 
		Desktop.ribbon_tabs = {
			{name = "Avatar", tooltip="主角", icon="Texture/3DMapSystem/AppIcons/People_64.dds", 
				role_bg = "texture/Orion/Role_BG_Red.png: 30 30 30 30", 
				poprole_bg = "texture/Orion/PopRole_BG_Red.png: 15 15 15 15", 
				file="script/apps/Orion/Roles/AvatarTab.html", bSkipCache=nil},
			{name = "Media", tooltip="应用程序|媒体",icon="Texture/3DMapSystem/AppIcons/VideoRecorder_64.dds", 
				role_bg = "texture/Orion/Role_BG_Yellow.png: 30 30 30 30", 
				poprole_bg = "texture/Orion/PopRole_BG_Yellow.png: 15 15 15 15", 
				file="script/apps/Orion/Roles/MediaTab.html", bSkipCache=nil},
			{name = "Creation", tooltip="创造",icon="Texture/3DMapSystem/AppIcons/painter_64.dds", 
				role_bg = "texture/Orion/Role_BG_Green.png: 30 30 30 30", 
				poprole_bg = "texture/Orion/PopRole_BG_Green.png: 15 15 15 15", 
				file="script/apps/Orion/Roles/CreationTab.html", bSkipCache=nil, onshow="MyCompany.Orion.RibbonControl.OnShowCreationTab"},
			{name = "Tools", tooltip="工具", icon="Texture/3DMapSystem/AppIcons/Settings_64.dds", 
				role_bg = "texture/Orion/Role_BG_Blue.png: 30 30 30 30", 
				poprole_bg = "texture/Orion/PopRole_BG_Blue.png: 15 15 15 15", 
				file="script/apps/Orion/Roles/ToolsTab.html", bSkipCache=nil},
			{name = "WorldBuilder", tooltip="高级编辑器",icon="Texture/3DMapSystem/AppIcons/Blueprint_64.dds", 
				role_bg = "texture/Orion/Role_BG_Violet.png: 30 30 30 30", 
				poprole_bg = "texture/Orion/PopRole_BG_Violet.png: 15 15 15 15", 
				file="script/apps/Orion/Roles/WorldBuilderTab.html", bSkipCache=nil},
			{name = "WorldBuilder0", tooltip="高级编辑器0",icon="Texture/3DMapSystem/AppIcons/Blueprint_64.dds", 
				role_bg = "texture/Orion/Role_BG_Violet.png: 30 30 30 30", 
				poprole_bg = "texture/Orion/PopRole_BG_Violet.png: 15 15 15 15", 
				file="script/apps/Orion/Roles/WorldBuilderTab.html", bSkipCache=nil},
		}
		
		-- keep the pop role window visible on mouse leave role area when the mouse position is still over pop role window, otherwise hide
		function Desktop.OnLeaveRoleArea()
			local x, y = ParaUI.GetMousePosition();
			local temp = ParaUI.GetUIObjectAtPoint(x, y);
			if(temp:IsValid() == true) then
				while(temp.parent.name ~= "__root") do
					temp = temp.parent;
				end
			end
			if(temp.name == "PopupRoleArea") then
				ParaUI.GetUIObject("PopupRoleArea").visible = true;
			else
				ParaUI.GetUIObject("PopupRoleArea").visible = false;
			end
		end
		
		function Desktop.OnClickRibbonTab(nIndex)
			local tab = Desktop.ribbon_tabs[nIndex];
			if(tab) then
				local bVisible = Desktop.RibbonControl:ShowTab(tab.name, false); -- not toggle
				-- update the role text and icon according to the ribbon tab selection
				local _rolearea = ParaUI.GetUIObject(Desktop.rolearea_id);
				if(_rolearea:IsValid() == true) then
					_rolearea.background = tab.role_bg;
				end
				local _roleicon = ParaUI.GetUIObject(Desktop.roleicon_id);
				if(_roleicon:IsValid() == true) then
					_roleicon.background = tab.icon;
				end
				local _roletext = ParaUI.GetUIObject(Desktop.roletext_id);
				if(_roletext:IsValid() == true) then
					_roletext.text = tab.tooltip;
				end
				-- adjust highlighter bg
				local tmp = ParaUI.GetUIObject(Desktop.highlighter_id);
				if(tmp:IsValid()) then
					tmp.visible = bVisible;
					--tmp.translationx = (nIndex-1)*64;
					tmp.translationy = 72 * (nIndex - 1);
				end
			end
		end
		
		-- Role area
		local _rolearea = ParaUI.CreateUIObject("container", "RoleArea", "_lt", borderLeft, borderTop + 124, 124, 90);
		--_rolearea.background = "Texture/Orion/Role_BG.png: 30 30 30 30";
		_rolearea.onmouseenter = string.format(";ParaUI.GetUIObject(%q).visible = true;", "PopupRoleArea");
		_rolearea.onmouseleave = ";MyCompany.Orion.Desktop.OnLeaveRoleArea();";
		_rolearea:AttachToRoot();
		Desktop.rolearea_id = _rolearea.id;
			local _roleicon = ParaUI.CreateUIObject("button", "RoleIcon", "_lt", 40, 12, 48, 48)
			_roleicon.background = "";
			--_roleicon.enabled = false;
			_rolearea:AddChild(_roleicon);
			Desktop.roleicon_id = _roleicon.id;
			local _roletext = ParaUI.CreateUIObject("button", "RoleText", "_lt", 20, 63, 88, 18);
			_roletext.background = "";
			_roletext.enabled= false;
			_roletext.text = "";
			_rolearea:AddChild(_roletext);
			_roletext.font= "system;12;bold";
			_guihelper.SetFontColor(_roletext, "255 255 255");
			Desktop.roletext_id = _roletext.id;
		
		-- Popup Role area
		local _role = ParaUI.CreateUIObject("container", "PopupRoleArea", "_lt", borderLeft, borderTop + 124 + 90, 200, 377);
		_role.background = "Texture/Orion/ProfileCharAppearance_BG.png:30 30 30 30";
		_role.visible = false;
		_role.zorder = 2;
		_role.onmouseleave = ";MyCompany.Orion.Desktop.OnLeaveRoleArea();";
		_role:AttachToRoot();
			--local _roleplay = ParaUI.CreateUIObject("button", "Role", "_lt", 0, 0, 128, 64);
			----_roleplay.background = "";
			--_roleplay.text = "当前扮演角色";
			--_role:AddChild(_roleplay);
			local i;
			local tabs = {}; -- used in RibbonControl
			for i = 1, Desktop.RoleNode:GetChildCount() do
				local node = Desktop.RoleNode:GetChild(i);
				local _bg = ParaUI.CreateUIObject("button", "BG", "_lt", 14, 72 * (i - 1) + 12, 175, 64);
				--_bg.background = "texture/Orion/ProfileCharItem_BG.png: 15 15 15 15";
				--_bg.color= "255 255 0".." 100";
				_bg.background = Desktop.ribbon_tabs[i].poprole_bg;
				_bg.onclick = ";MyCompany.Orion.Desktop.OnClickRibbonTab("..i..");";
				_role:AddChild(_bg);
				local _bg = ParaUI.CreateUIObject("container", "BG", "_lt", 22, 72 * (i - 1) + 20, 48, 48);
				_bg.background = "texture/Orion/ProfileCharItem_BG.png: 15 15 15 15";
				_role:AddChild(_bg);
				local _box = ParaUI.CreateUIObject("button", "Role"..i, "_lt", 22, 72 * (i - 1) + 20, 48, 48);
				--_box.background = "";
				_box.background = node.icon;
				_box.onclick = ";MyCompany.Orion.Desktop.OnClickRibbonTab("..i..");";
				_role:AddChild(_box);
				tabs[Desktop.ribbon_tabs[i].name] = Desktop.ribbon_tabs[i];
				
				local _box = ParaUI.CreateUIObject("button", "RoleText"..i, "_lt", 14 + 64, 72 * (i - 1) + 20, 100, 48);
				_box.background = "";
				_box.enabled= false;
				_box.text = node.text;
				_role:AddChild(_box);
				_box.font= "system;14;bold";
				--_guihelper.SetFontColor(_box, "255 255 255");
				tabs[Desktop.ribbon_tabs[i].name] = Desktop.ribbon_tabs[i];
			end
			
			-- highlighter
			local _highlighter = ParaUI.CreateUIObject("button", "HighLighter", "_lt", 22, 20, 48, 48)
			_highlighter.background = "Texture/Orion/icon_bg.png;0 0 33 33:5 5 5 5";
			_highlighter.enabled = false;
			_guihelper.SetUIColor(_highlighter, "255 255 255 255");
			_role:AddChild(_highlighter);
			Desktop.highlighter_id = _highlighter.id;
			
			-- create ribbon manager for toolbar ribbon tabs
			if(not Desktop.RibbonControl) then
				NPL.load("(gl)script/ide/RibbonControl.lua");
				Desktop.RibbonControl = CommonCtrl.RibbonControl:new({
					name = "Orion.RibbonControl",
					alignment = "_lt",
					left = borderLeft,
					top = 214 + borderLeft,
					width = 160,
					height = 512,
					parent = nil,
					tabs = tabs, -- tabs are generated above
				});
			end
			
			-- change to the first role by default
			Desktop.OnClickRibbonTab(1);
		
		---- NOTE: Toolbar area is shown in MCML page form, current using the Ribbon page of the HelloChat application
		---- NOTE: the toobox area height changes according to the function count in the toolbox
		--local _toolbar = ParaUI.CreateUIObject("container", "ToolbarArea", "_lt", borderLeft, borderTop + 128 + 64, 512, 64);
		--_toolbar.background = "";
		--_toolbar:AttachToRoot();
		
		
		
		---- Toolbar area
		---- NOTE: the toobox area height changes according to the function count in the toolbox
		--local _toolbar = ParaUI.CreateUIObject("container", "ToolbarArea", "_lt", borderLeft, borderTop + 128 + 64, 64, 256);
		----_toolbar.background = "";
		--_toolbar:AttachToRoot();
			--local i;
			--for i = 1, Desktop.ToolbarNode:GetChildCount() do
				--local node = Desktop.ToolbarNode:GetChild(i);
				--local _box = ParaUI.CreateUIObject("button", "Action"..i, "_lt", 0, 64*(i-1), 64, 64);
				----_box.background = "";
				--_box.text = node.text;
				--_toolbar:AddChild(_box);
			--end
		
		-- countup timer area
		local _timer = ParaUI.CreateUIObject("container", "TimerArea", "_ctt", 0, 0, 240, 35);
		_timer.background = "Texture/Orion/TimePlayed.png:15 15 15 15";
		_timer:AttachToRoot();
			local _text = ParaUI.CreateUIObject("button", "text", "_fi", 0, 0, 0, 0);
			_text.text = "今天玩了    小时    分钟了";
			_text.font = "System;16;bold";
			_text.enabled = false;
			_text.background = "";
			_guihelper.SetFontColor(_text, "65 105 225");
			_timer:AddChild(_text);
			local _text = ParaUI.CreateUIObject("button", "hour", "_lt", 85, 0, 32, 35);
			_text.text = "0";
			_text.font = "System;16;bold";
			_text.enabled = false;
			_text.background = "";
			_guihelper.SetFontColor(_text, "255 255 255");
			_timer:AddChild(_text);
			Desktop.timehour_id = _text.id;
			local _text = ParaUI.CreateUIObject("button", "minute", "_lt", 140, 0, 32, 35);
			_text.text = "0";
			_text.font = "System;16;bold";
			_text.enabled = false;
			_text.background = "";
			_guihelper.SetFontColor(_text, "255 255 255");
			_timer:AddChild(_text);
			Desktop.timeminute_id = _text.id;
		
 	--[[
		-- init window object
	local _app = MyCompany.Orion.app._app;
	local _wnd = _app:FindWindow("Mail") or _app:RegisterWindow("Mail", nil, Desktop.MSGProc1);
	
	NPL.load("(gl)script/ide/WindowFrame.lua");]]
	
	
	---------------------------------------------------------------------------------------------------------------
	--Title:Email Module
	--Author: Chengpeng Zhang
	--Date:2009-02-27
	
	--[[--store control name that has been ever shown
	local TreeViewOpenedNameTable = {}
	function Desktop.ShowMailTreeView(ctlName)
		local _ui = ParaUI.GetUIObject("TreeView_Orion_Mail_ShowOne")
		if(_ui.visible) then _ui.visible = false end
		
		local flag = false
		local ctl = CommonCtrl.GetControl(ctlName);
		for i = 1, #TreeViewOpenedNameTable do
			if(TreeViewOpenedNameTable[i] == "compose_cont") then 
				local pg = ParaUI.GetUIObject("compose_cont")
				if(pg) then pg.visible = false end
			else
				local temp = CommonCtrl.GetControl(TreeViewOpenedNameTable[i])
				temp:Show(false);
			end
			if(TreeViewOpenedNameTable[i] == ctlName) then flag = true end
		end
		
		if(not flag) then  table.insert(TreeViewOpenedNameTable, ctlName) end
		
		if("compose_cont" == ctlName) then
			local pg = ParaUI.GetUIObject("compose_cont")
			if(pg) then pg.visible = true end
		else
			ctl:Show(true);
		end
	end
	
	function Desktop.SaveComposedMail()
		local ctl = ParaUI.GetUIObject("MailShowArea_EditboxTo");
		local composed_mail_to = ctl.text
		
		ctl = ParaUI.GetUIObject("MailShowArea_EditboxSubject");
		local composed_mail_subject = ctl.text

		ctl = CommonCtrl.GetControl("MultiLineEditbox_Mail_Compose");
		local composed_mail_content = ctl:GetText()
		
		local composed_mail = "to:"..composed_mail_to.."\r\nsubject:"..composed_mail_subject.."\r\ncontent:"..composed_mail_content
		if(0 == #composed_mail_to) then composed_mail_to = "unknown" end
		local f = ParaIO.open("mail/"..composed_mail_subject..".txt", "w")
		if(f:IsValid()) then
			f:writeline(composed_mail)
			f:close()
		end
	end
	
	function Desktop.DiscardComposedMail()
		local ctl = ParaUI.GetUIObject("MailShowArea_EditboxTo");
		ctl.text = ""
		
		ctl = ParaUI.GetUIObject("MailShowArea_EditboxSubject");
		ctl.text = ""

		ctl = CommonCtrl.GetControl("MultiLineEditbox_Mail_Compose");
		ctl:SetText("")
	end

	function Desktop.ShowOneEmail(treeview_name, treenode_title, treenode_date)
		local ctl = CommonCtrl.GetControl(treeview_name);
		if(ctl) then ctl:Show(false) end
		
		local _ui = ParaUI.GetUIObject("TreeView_Orion_Mail_ShowOne")
		if(_ui) then
			_ui:GetChild("title").text = treenode_title 
			_ui:GetChild("date").text = treenode_date
			_ui.visible = true
		end
	end
	--The Email Window Frame Call Back	
	function Desktop.EmailFrameWindowCallBack(bShow, _parent) 
			local groot = ParaUI.GetUIObject("MailArea");
			if(groot:IsValid() == false) then
				groot = ParaUI.CreateUIObject("container", "MailArea", "_lt",0 , 0, 100, 600)
				groot.background = "Texture/alphadot.png:15 15 15 15" 
				_parent:AddChild(groot)
			end
			
			local _groot = ParaUI.CreateUIObject("container", "MailShowArea", "_lt",110 , 0, 900-110, 600)
			_groot.background = "Texture/pressedbox.png:15 15 15 15" 
			_parent:AddChild(_groot)
			
			NPL.load("(gl)script/ide/TreeView.lua");
			
			--Create a TreeView to store Inbox Data
			local ctl_Inbox = CommonCtrl.GetControl("TreeView_Orion_Mail_Inbox");
			if(ctl_Inbox == nil) then
					ctl_Inbox = CommonCtrl.TreeView:new{
					name = "TreeView_Orion_Mail_Inbox",
					alignment = "_lt",
					left=0, top=0,
					width = 900-110,
					height = 600,
					parent = _groot,
					DrawNodeHandler = function (parent,treeNode)
						if(parent==nil or treeNode==nil) then return end
						local date = ParaGlobal.GetDateFormat("yyyy-MM-dd");
						
						local _btn = ParaUI.CreateUIObject("button", "btn", "_fi", 0,0,0,0);
						_btn.background = "Texture/3DMapSystem/common/AquaOpenBlue_full.png:4 4 4 4";
						_btn.color = "255 255 255 100";
						_btn.onclick = string.format(";MyCompany.Orion.Desktop.ShowOneEmail(%q, %q, %q);", "TreeView_Orion_Mail_Inbox", treeNode.title, date)
						parent:AddChild(_btn);
						
						local _icon = ParaUI.CreateUIObject("container", "icon", "_lt", 8, 8, 32, 32);
						_icon.background = "Texture/3DMapSystem/common/page_white.png";
						parent:AddChild(_icon);
						
						local _title = ParaUI.CreateUIObject("text", "title", "_lt", 8+32, 8+8, 100, 32);
						_title.text = treeNode.title;
						parent:AddChild(_title);
						
						local _date = ParaUI.CreateUIObject("text", "date", "_rt", -100, 16, 100, 24);
						_date.text = date;
						parent:AddChild(_date);
						local width, _ = _date:GetTextLineSize();
						
						return 48;
					end,
				};
				local node = ctl_Inbox.RootNode;
				node:AddChild(CommonCtrl.TreeNode:new({title = "Inbox1", Name = "sample"}));
				node:AddChild(CommonCtrl.TreeNode:new({title = "Inbox2", Name = "sample"}));
				node:AddChild(CommonCtrl.TreeNode:new({title = "Inbox3", Name = "sample"}));
				node:AddChild(CommonCtrl.TreeNode:new({title = "Inbox4", Name = "sample"}));
				node:AddChild(CommonCtrl.TreeNode:new({title = "Inbox5", Name = "sample"}));
			end
            
            --Create a container to show just one Email clicked
			_c = ParaUI.CreateUIObject("container", "TreeView_Orion_Mail_ShowOne", "_fi", 0,0,0,0);
			_c.background = "Texture/3DMapSystem/common/AquaOpenBlue_full.png:4 4 4 4";
			_c.color = "255 255 255 100";
			_groot:AddChild(_c);
			
			local _icon = ParaUI.CreateUIObject("container", "icon", "_lt", 8, 8, 32, 32);
			_icon.background = "Texture/3DMapSystem/common/page_white.png";
			_c:AddChild(_icon);
			
			local _title = ParaUI.CreateUIObject("text", "title", "_lt", 8+32, 8+8, 100, 32);
			_c:AddChild(_title);
			
			local _date = ParaUI.CreateUIObject("text", "date", "_rt", -100, 16, 100, 24);
			_c:AddChild(_date);
			
			_c.visible = false
		
			local node = ParaUI.CreateUIObject("button","InboxArea","_lt",0, 0, 100, 50)
			node.background = "Texture/b_up.png:15 15 15 15";
			node.text= "Inbox";
			node.enabled= true;
			node.onclick = string.format(";MyCompany.Orion.Desktop.ShowMailTreeView(%q);", "TreeView_Orion_Mail_Inbox");
			node.font= "system;14;bold";
			_guihelper.SetFontColor(node, "255 255 255");
			groot:AddChild(node)
			
			--Create a TreeView to store Sent Mail Data
			local ctl_SentMail = CommonCtrl.GetControl("TreeView_Orion_Mail_SentMail");
			if(ctl_SentMail == nil) then
				ctl_SentMail = CommonCtrl.TreeView:new{
				name = "TreeView_Orion_Mail_SentMail",
				alignment = "_lt",
				left=0, top=0,
				width = 900-110,
				height = 600,
				parent = _groot,
				DrawNodeHandler = function (parent,treeNode)
					
					local _btn = ParaUI.CreateUIObject("button", "btn", "_fi", 0,0,0,0);
					_btn.background = "Texture/3DMapSystem/common/AquaOpenBlue_full.png:4 4 4 4";
					_btn.color = "255 255 255 100";
					local date = ParaGlobal.GetDateFormat("yyyy-MM-dd");
					_btn.onclick = string.format(";MyCompany.Orion.Desktop.ShowOneEmail(%q, %q, %q);", "TreeView_Orion_Mail_SentMail", treeNode.title, date)
					parent:AddChild(_btn);
					
					local _icon = ParaUI.CreateUIObject("container", "icon", "_lt", 8, 8, 32, 32);
					_icon.background = "Texture/3DMapSystem/common/page_white.png";
					parent:AddChild(_icon);
					
					local _title = ParaUI.CreateUIObject("text", "title", "_lt", 8+32, 8+8, 100, 32);
					_title.text = treeNode.title;
					parent:AddChild(_title);
					
					local _date = ParaUI.CreateUIObject("text", "date", "_rt", -100, 16, 100, 24);
					_date.text = date;
					parent:AddChild(_date);
					
					return 48;
				end,
				};
				local node1 = ctl_SentMail.RootNode;
				node1:AddChild(CommonCtrl.TreeNode:new({title = "Sent Mail1", Name = "sample"}));
				node1:AddChild(CommonCtrl.TreeNode:new({title = "Sent Mail2", Name = "sample"}));
				node1:AddChild(CommonCtrl.TreeNode:new({title = "Sent Mail3", Name = "sample"}));
				node1:AddChild(CommonCtrl.TreeNode:new({title = "Sent Mail4", Name = "sample"}));
				node1:AddChild(CommonCtrl.TreeNode:new({title = "Sent Mail5", Name = "sample"}));
			end
			--ctl:Show();
			local node = ParaUI.CreateUIObject("button","SentMailArea","_lt",0, 0+100, 100, 50)
			node.background = "Texture/b_up.png:15 15 15 15";
			node.text= "Sent Mail";
			node.enabled= true;
			node.onclick = string.format(";MyCompany.Orion.Desktop.ShowMailTreeView(%q);", "TreeView_Orion_Mail_SentMail")
			node.font= "system;14;bold";
			_guihelper.SetFontColor(node, "255 255 255");
			groot:AddChild(node)
			
			--Create a TreeView to store Drafts Data
			local ctl_Drafts = CommonCtrl.GetControl("TreeView_Orion_Mail_Drafts");
			if(ctl_Drafts == nil) then
				ctl_Drafts = CommonCtrl.TreeView:new{
				name = "TreeView_Orion_Mail_Drafts",
				alignment = "_lt",
 				left=0, top=0,
				width = 900-110,
				height = 600,
				parent = _groot,
				DrawNodeHandler = function (parent,treeNode)
					
					local _btn = ParaUI.CreateUIObject("button", "btn", "_fi", 0,0,0,0);
					_btn.background = "Texture/3DMapSystem/common/AquaOpenBlue_full.png:4 4 4 4";
					_btn.color = "255 255 255 100";
					local date = ParaGlobal.GetDateFormat("yyyy-MM-dd");
					_btn.onclick = string.format(";MyCompany.Orion.Desktop.ShowOneEmail(%q, %q, %q);", "TreeView_Orion_Mail_Drafts", treeNode.title, date)
					parent:AddChild(_btn);
					
					local _icon = ParaUI.CreateUIObject("container", "icon", "_lt", 8, 8, 32, 32);
					_icon.background = "Texture/3DMapSystem/common/page_white.png";
					parent:AddChild(_icon);
					
					local _title = ParaUI.CreateUIObject("text", "title", "_lt", 8+32, 8+8, 100, 32);
					_title.text = treeNode.title;
					parent:AddChild(_title);
					
					local _date = ParaUI.CreateUIObject("text", "date", "_rt", -100, 16, 100, 24);
					_date.text = date;
					parent:AddChild(_date);
					
					return 48;
				end,
				};
				local node1 = ctl_Drafts.RootNode;
				node1:AddChild(CommonCtrl.TreeNode:new({title = "Drafts1", Name = "sample"}));
				node1:AddChild(CommonCtrl.TreeNode:new({title = "Drafts2", Name = "sample"}));
				node1:AddChild(CommonCtrl.TreeNode:new({title = "Drafts3", Name = "sample"}));
				node1:AddChild(CommonCtrl.TreeNode:new({title = "Drafts4", Name = "sample"}));
				node1:AddChild(CommonCtrl.TreeNode:new({title = "Drafts5", Name = "sample"}));
			end
			--ctl:Show();
			local node = ParaUI.CreateUIObject("button","DraftsArea","_lt",0, 0+100+100, 100, 50)
			node.background = "Texture/b_up.png:15 15 15 15";
			node.text= "Drafts";
			node.enabled= true;
			node.onclick = string.format(";MyCompany.Orion.Desktop.ShowMailTreeView(%q);", "TreeView_Orion_Mail_Drafts")
			node.font= "system;14;bold";
			_guihelper.SetFontColor(node, "255 255 255");
			groot:AddChild(node)
			
			--Create a TreeView to store Spam Data
			local ctl_Spam = CommonCtrl.GetControl("TreeView_Orion_Mail_Spam");
			if(ctl_Spam == nil) then
				ctl_Spam = CommonCtrl.TreeView:new{
				name = "TreeView_Orion_Mail_Spam",
				alignment = "_lt",
				left=0, top=0,
				width = 900-110,
				height = 600,
				parent = _groot,
				DrawNodeHandler = function (parent,treeNode)
					
					local _btn = ParaUI.CreateUIObject("button", "btn", "_fi", 0,0,0,0);
					_btn.background = "Texture/3DMapSystem/common/AquaOpenBlue_full.png:4 4 4 4";
					_btn.color = "255 255 255 100";
					local date = ParaGlobal.GetDateFormat("yyyy-MM-dd");
					_btn.onclick = string.format(";MyCompany.Orion.Desktop.ShowOneEmail(%q, %q, %q);", "TreeView_Orion_Mail_Spam", treeNode.title, date)
					parent:AddChild(_btn);
					
					local _icon = ParaUI.CreateUIObject("container", "icon", "_lt", 8, 8, 32, 32);
					_icon.background = "Texture/3DMapSystem/common/page_white.png";
					parent:AddChild(_icon);
					
					local _title = ParaUI.CreateUIObject("text", "title", "_lt", 8+32, 8+8, 100, 32);
					_title.text = treeNode.title;
					parent:AddChild(_title);
					
					local date = ParaGlobal.GetDateFormat("yyyy-MM-dd");
					local _date = ParaUI.CreateUIObject("text", "date", "_rt", -100, 16, 100, 24);
					_date.text = date;
					parent:AddChild(_date);
					
					return 48;
				end,
				};
				local node1 = ctl_Spam.RootNode;
				node1:AddChild(CommonCtrl.TreeNode:new({title = "Spam1", Name = "sample"}));
				node1:AddChild(CommonCtrl.TreeNode:new({title = "Spam2", Name = "sample"}));
				node1:AddChild(CommonCtrl.TreeNode:new({title = "Spam3", Name = "sample"}));
				node1:AddChild(CommonCtrl.TreeNode:new({title = "Spam4", Name = "sample"}));
				node1:AddChild(CommonCtrl.TreeNode:new({title = "Spam5", Name = "sample"}));
			end
			--ctl:Show();
			local node = ParaUI.CreateUIObject("button","SpamArea","_lt",0, 0+100+100+100, 100, 50)
			node.background = "Texture/b_up.png:15 15 15 15";
			node.text= "Spam";
			node.enabled= true;
			node.onclick = string.format(";MyCompany.Orion.Desktop.ShowMailTreeView(%q);", "TreeView_Orion_Mail_Spam")
			node.font= "system;14;bold";
			_guihelper.SetFontColor(node, "255 255 255");
			groot:AddChild(node)
			
			
			------------------------Compose Mail Area---------------------------------------------
			local _compose_cont = ParaUI.CreateUIObject("container","compose_cont","_fi", 0, 0, 0, 0);
			_compose_cont.background = "";
			_groot:AddChild(_compose_cont)
			_compose_cont.visible = false
			
			NPL.load("(gl)script/ide/MultiLineEditbox.lua");
			local ctl = CommonCtrl.MultiLineEditbox:new{
				name = "MultiLineEditbox_Mail_Compose",
				alignment = "_lt",
				left=10, 
				top=120,
				width = 900-140,
				height = 460, 
				WordWrap = false,
				container_bg = "Texture/3DMapSystem/common/ThemeLightBlue/btn_bg_highlight.png: 4 4 4 4",
				parent = _compose_cont,
			};
			ctl:Show(true);
			ctl:SetText("Please Compose Here:\r");
			--log(ctl:GetText());
			
			local node = ParaUI.CreateUIObject("text","MailShowArea_TextTo","_lt",10, 10, 100, 30)
			node.background = "";
			node.text= "To:";
			node.font= "system;14;bold";
			_guihelper.SetFontColor(node, "255 0 0");
			_compose_cont:AddChild(node)
			
			
			local node = ParaUI.CreateUIObject("editbox","MailShowArea_EditboxTo","_lt",10+30+50, 10, 600, 30)
			node.background = "Texture/speak_box.png:15 15 15 15";
			_compose_cont:AddChild(node)

			local node = ParaUI.CreateUIObject("text","MailShowArea_TextSubject","_lt",10, 10+30, 100, 30)
			node.background = "";
			node.text= "Subject:";
			node.font= "system;14;bold";
			_guihelper.SetFontColor(node, "255 0 0");
			_compose_cont:AddChild(node)
			
			local node = ParaUI.CreateUIObject("editbox","MailShowArea_EditboxSubject","_lt",10+30+50, 10+30, 600, 30)
			node.background = "Texture/speak_box.png:15 15 15 15";
			_compose_cont:AddChild(node)
			
			local node = ParaUI.CreateUIObject("button","MailShowArea_Send","_lt",10, 10+30+30, 100, 30)
			node.background = "Texture/box.png:15 15 15 15";
			node.text= "Send";
			node.font= "system;14;bold";
			_guihelper.SetFontColor(node, "255 0 0");
			_compose_cont:AddChild(node)
			
			local node = ParaUI.CreateUIObject("button","MailShowArea_Save","_lt",10+100+10, 10+30+30, 100, 30)
			node.background = "Texture/box.png:15 15 15 15";
			node.enable = true
			node.onclick = ";MyCompany.Orion.Desktop.SaveComposedMail();"
			node.text= "Save";
			node.font= "system;14;bold";
			_guihelper.SetFontColor(node, "255 0 0");
			_compose_cont:AddChild(node)
			
			local node = ParaUI.CreateUIObject("button","MailShowArea_Discard","_lt",10+100+100+10+10, 10+30+30, 100, 30)
			node.background = "Texture/box.png:15 15 15 15";
			node.text= "Discard";
			node.onclick = string.format(";MyCompany.Orion.Desktop.DiscardComposedMail();")
			node.font= "system;14;bold";
			_guihelper.SetFontColor(node, "255 0 0");
			_compose_cont:AddChild(node)
			-----------------------------------------------------------------------------
						
			local node = ParaUI.CreateUIObject("button","ComposeButtonArea","_lt",0, 0+100+100+100+100, 100, 50)
			node.background = "Texture/b_up.png:15 15 15 15";
			node.text= "Compose";
			node.enabled= true;
			node.onclick = string.format(";MyCompany.Orion.Desktop.ShowMailTreeView(%q);", "compose_cont")
			node.font= "system;14;bold";
			_guihelper.SetFontColor(node, "255 255 255");
			groot:AddChild(node)
			
	end
	
	--Define the Email Window Frame pattern
	local EmailWindowsParam = {
		wnd = _wnd, -- a CommonCtrl.os.window object
		
		text = "Pala5 Email",
		
		isShowTitleBar = true, -- default show title bar
		isShowToolboxBar = false, -- default hide title bar
		isShowStatusBar = false, -- default show status bar
		
		initialWidth = 900, -- initial width of the window client area
		initialHeight = 600, -- initial height of the window client area
		
		initialPosX = 50,
		initialPosY = 10,
		
		maxWidth = 600,
		maxHeight = 600,
		minWidth = 300,
		minHeight = 300,
		
		style = CommonCtrl.WindowFrame.DefaultStyle,
				
		alignment = "Free", -- Free|Left|Right|Bottom
		
		ShowUICallback = MyCompany.Orion.Desktop.EmailFrameWindowCallBack,
		
	};
	
	--Create a window object in the pattern of EmailWindowParam
	local frame = CommonCtrl.WindowFrame:new2(EmailWindowsParam);
	
	--Show the Window Frame named wndname
	function pmail(wndname)
		local _app = MyCompany.Orion.app._app;
		local _wnd = _app:FindWindow(wndname);
		if(_wnd ~= nil) then
			local frame = _wnd:GetWindowFrame();
			if(frame ~= nil) then
				frame:Show2();
			end
		end	
	end
	
	
	commonlib.setfield("MyCompany.Orion.Desktop.pmail", pmail);

	]]
		-- Dock area
		-- NOTE: the dock area width changes according to the function count in the dock
		local _dock = ParaUI.CreateUIObject("container", "DockArea", "_ctb", 0, 0, 542, 77);
		_dock.background = "Texture/Orion/Dock_BG.png:15 15 15 15";
		_dock:AttachToRoot();
			local i;
			for i = 1, Desktop.DockNode:GetChildCount() do
				local node = Desktop.DockNode:GetChild(i);
				local _box = ParaUI.CreateUIObject("button", "Dock"..i, "_lt", 89 * (i - 1) + 7, 5, 84, 68);
				_box.background = "Texture/Orion/DockIconSet.png;"..(85 * (i - 1) + 1).." 0 84 68";
				if(i == 6) then
				--pop up the Email Module
					NPL.load("(gl)script/apps/Orion/Desktop/Mail.lua");
					--_box.onclick = string.format(";MyCompany.Orion.Desktop.pmail(%q);","Mail");
					--_box.onclick = ";MyCompany.Orion.Mail.CreateMailWindow();MyCompany.Orion.Mail.ShowMailWindow();"
					_box.onclick = ";MyCompany.Orion.Mail.ShowMailWindow();"
					
				elseif(5 == i) then
					NPL.load("(gl)script/apps/Orion/Desktop/Calendar.lua");
					--_box.onclick = string.format(";MyCompany.Orion.Calendar.show(%q);","Calendar");
					_box.onclick = ";MyCompany.Orion.Calendar.show();"
				end
				_dock:AddChild(_box);
			end	
		
		-- Minimap area
		local _minimap = ParaUI.CreateUIObject("container", "MinimapArea", "_rt", -156 - borderRight, borderTop, 156, 189);
		_minimap.background = "Texture/Orion/Minimap_BG.png:30 44 30 27";
		_minimap:AttachToRoot();
			local _text = ParaUI.CreateUIObject("button", "Text", "_lt", 0, 12, 156, 24);
			_text.background = "";
			_text.text= "李小多的家";
			_text.enabled= false;
			_text.font= "system;14;bold";
			_guihelper.SetFontColor(_text, "255 255 255");
			_minimap:AddChild(_text);
			local _minimapContent = ParaUI.CreateUIObject("container", "MinimapContent", "_lt", 14, 39, 128, 128);
			_minimapContent.background = "";
			_minimap:AddChild(_minimapContent);
			-- show the page on the minimap content
			Desktop.MinimapPage = Map3DSystem.mcml.PageCtrl:new({url="script/apps/Orion/Desktop/MinimapPage.html"});
			Desktop.MinimapPage:Create("OrionMinimapPage", _minimapContent, "_fi", 0, 0, 0, 0);
		
		-- Status area
		-- NOTE: the status area width changes according to the function count in the status
		local _status = ParaUI.CreateUIObject("container", "StatusArea", "_rt", -156 - borderRight, borderTop + 196, 192, 24);
		_status.background = "";
		_status:AttachToRoot();
			local i;
			for i = 1, Desktop.StatusNode:GetChildCount() do
				local node = Desktop.StatusNode:GetChild(i);
				local _box = ParaUI.CreateUIObject("button", "Status"..i, "_lt", 26*(i-1), 0, 24, 24);
				--_box.background = "";
				--_box.text = node.text;
				_box.background = node.icon;
				if(node.commandname ~= nil) then
					_box.onclick = ";System.App.Commands.Call(\""..node.commandname.."\")";
				end
				_status:AddChild(_box);
			end
		
		-- TODO: need refinement with artwork and update logic
		
		do return end
		
		local left,top,width, height = 0, 0, 350,27;
		_this = ParaUI.CreateUIObject("container", libName, "_mb", 0, 0, 0, 35);
		_this.background = "";
		_this.zorder = 5; -- make it stay on top. 
		_this:AttachToRoot();
		_parent = _this;
		
		--
		-- the chat bar
		--
		
		_this = ParaUI.CreateUIObject("container", "chatbar", "_lt", left, 35-height, width, height)
		_this.background = "Texture/Orion/mainbar.png;0 37 110 27:20 0 78 0";
		_parent:AddChild(_this);
		left = left + width;
		_parent = _this;
		
		_this = ParaUI.CreateUIObject("button", "input", "_lt", 15, 3, 60, 22)
		_this.background = "";
		_this.text = "[所有人]";
		_this.tooltip = "更改聊天频道";
		NPL.load("(gl)script/apps/Orion/BBSChat/ChannelContextMenu.lua");
		_this.onclick = ";MyCompany.Orion.ChannelContextMenu.Show();"
		_guihelper.SetUIFontFormat(_this, 36);
		-- _guihelper.SetButtonTextColor(_this,"255 255 255");
		_this:SetCurrentState("highlight");
        _this:GetFont("text").color = "255 255 255";
        _this:SetCurrentState("pressed");
		_this:GetFont("text").color = "160 160 160";
        _this:SetCurrentState("normal");
        _this:GetFont("text").color = "200 200 200";
        _this:SetCurrentState("disabled");
        _this:GetFont("text").color = "200 200 200 160";
        
        _parent:AddChild(_this);
        
		NPL.load("(gl)script/apps/Orion/BBSChat/BBSChatWnd.lua");
		
		_this = ParaUI.CreateUIObject("imeeditbox", "inputtext", "_fi", 76, 5, 75, 2)
		_this.background = "";
		_guihelper.SetFontColor(_this,"255 255 255");
		_this:GetAttributeObject():SetField("CaretColor", tonumber("FFFFFFFF", 16));
		_this:GetAttributeObject():SetField("SelectedBackColor", tonumber("FF0000FF", 16));
		_this.onchange = ";MyCompany.Orion.Desktop.OnInputTextChange();";
		
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "b", "_rt", -66, 6, 16, 18)
		_this.background = "Texture/Orion/mainbar.png;152 10 16 18";
		_this.tooltip = "表情动作";
		_guihelper.SetUIColor(_this,"255 255 255");
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "b", "_rt", -50, 4, 39, 22)
		_this.background = "Texture/Orion/mainbar.png;111 7 39 22";
		_this.tooltip = "发送";
		_this.onclick = ";MyCompany.Orion.Desktop.OnClickSend();";
		_guihelper.SetUIColor(_this,"255 255 255");
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "b", "_rt", -10, 7, 8, 16)
		_this.background = "Texture/Orion/mainbar.png;102 12 8 16";
		_guihelper.SetUIColor(_this,"255 255 255");
		_this.tooltip = "隐藏|显示聊天记录";
		_this.onclick = ";MyCompany.Orion.ChatWnd.Show();";
		_parent:AddChild(_this);
		
		_parent = _parent.parent;
		
		--
		-- quick launch bar
		--
		width = 80;
		_this = ParaUI.CreateUIObject("container", "quickbar", "_lt", left, 0, width, 35)
		_this.background = "Texture/Orion/mainbar.png;110 29 42 35:14 0 10 0";
		_parent:AddChild(_this);
		left = left + width;
		_parent = _this;
		
		_this = ParaUI.CreateUIObject("button", "b", "_lt", 8, 4, 30, 30)
		_this.background = "Texture/3DMapSystem/Desktop/StartPage.png";
		_this.onclick = ";System.App.Commands.Call(\"Profile.Orion.HomePage\")";
		_this.tooltip = "我的首页";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "b", "_lt", 40, 4, 30, 30)
		_this.background = "Texture/3DMapSystem/Desktop/StarMap.png";
		_this.onclick = ";System.App.Commands.Call(\"File.Open.StarView\")";
		_this.tooltip = "星图";
		
		_parent:AddChild(_this);
		_parent = _parent.parent;
		
		--
		-- toolbar
		--
		width = 300;
		_this = ParaUI.CreateUIObject("container", "quickbar", "_lt", left, 0, width, 35)
		_this.background = "Texture/Orion/mainbar.png;152 29 51 35:1 0 15 0";
		_parent:AddChild(_this);
		left = left + width;
		_parent = _this;
		
		-- TODO: should read from XML file. I just hard code here. 
		Desktop.ribbon_tabs = {
			{name = "Avatar", tooltip="主角", icon="Texture/3DMapSystem/AppIcons/People_64.dds", file="script/apps/Orion/Roles/AvatarTab.html", bSkipCache=nil},
			{name = "Media", tooltip="应用程序|媒体",icon="Texture/3DMapSystem/AppIcons/VideoRecorder_64.dds", file="script/apps/Orion/Roles/MediaTab.html", bSkipCache=nil},
			{name = "Creation", tooltip="创造",icon="Texture/3DMapSystem/AppIcons/painter_64.dds", file="script/apps/Orion/Roles/CreationTab.html", bSkipCache=nil, onshow="MyCompany.Orion.RibbonControl.OnShowCreationTab"},
			{name = "Tools", tooltip="工具", icon="Texture/3DMapSystem/AppIcons/Settings_64.dds", file="script/apps/Orion/Roles/ToolsTab.html", bSkipCache=nil},
			{name = "WorldBuilder", tooltip="高级编辑器",icon="Texture/3DMapSystem/AppIcons/Blueprint_64.dds", file="script/apps/Orion/Roles/WorldBuilderTab.html", bSkipCache=nil},
		    --{name = "WorldBuilder0", tooltip="高级编辑器0",icon="Texture/3DMapSystem/AppIcons/Blueprint_64.dds", file="script/apps/Orion/Roles/WorldBuilderTab.html", bSkipCache=nil},
		}
		
		local left_sub, btnSize, spacing = 4, 30, 5;
		
		-- left arrow
		_this = ParaUI.CreateUIObject("button", "b", "_lt", left_sub, 9, 14, 20)
		_this.background = "Texture/Orion/mainbar.png;199 7 14 20";
		_parent:AddChild(_this);
		left_sub = left_sub + 14 + spacing;
		
		-- highlighter
		_this = ParaUI.CreateUIObject("button", "b", "_lt", left_sub-5, 0, 39, 35)
		_this.background = "Texture/Orion/icon_bg.png;0 0 33 33:5 5 5 5";
		_this.enabled = false;
		_this.visible= false;
		_guihelper.SetUIColor(_this, "255 255 255 255");
		_parent:AddChild(_this);
		Desktop.highlighter_id = _this.id;
		
		function Desktop.OnClickRibbonTab(nIndex)
			local tab = Desktop.ribbon_tabs[nIndex];
			if(tab) then
				local bVisible = Desktop.RibbonControl:ShowTab(tab.name, true);
				
				-- adjust highlighter bg
				local tmp = ParaUI.GetUIObject(Desktop.highlighter_id);
				if(tmp:IsValid()) then
					tmp.visible = bVisible;
					tmp.translationx = (nIndex-1)*(btnSize + spacing);
				end
			end
		end
		
		local nIndex, tab;
		local tabs = {}; -- used in RibbonControl
		-- all toolbar buttons
		for nIndex, tab in ipairs(Desktop.ribbon_tabs) do
			_this = ParaUI.CreateUIObject("button", "b", "_lt", left_sub, 4, btnSize, btnSize)
			_this.background = tab.icon;
			if(tab.tooltip) then 
				_this.tooltip = tab.tooltip
			end	
			_this.onclick = string.format(";MyCompany.Orion.Desktop.OnClickRibbonTab(%d)", nIndex);
			_parent:AddChild(_this);	
			left_sub=left_sub+btnSize+spacing;
			tabs[tab.name] = tab;
		end
		
		-- right arrow
		_this = ParaUI.CreateUIObject("button", "b", "_lt", left_sub, 9, 14, 20)
		_this.background = "Texture/Orion/mainbar.png;218 7 14 20";
		_parent:AddChild(_this);
		
		_parent = _parent.parent;
		
		-- create ribbon manager for toolbar ribbon tabs
		if(not Desktop.RibbonControl) then
			NPL.load("(gl)script/ide/RibbonControl.lua");
			Desktop.RibbonControl = CommonCtrl.RibbonControl:new({
				name = "Orion.RibbonControl",
				alignment = "_lb",
				left = 350+3,
				top = -35-46,
				width = 500,
				height = 46,
				parent = nil,
				tabs = tabs, -- tabs are generated above
			});
		end
		
		--
		-- status bar
		--
		_this = ParaUI.CreateUIObject("container", "statusbar", "_fi", left, 35-height, 0, 0)
		_this.background = "Texture/Orion/mainbar.png;203 37 35 27:1 0 15 0";
		_parent:AddChild(_this);
		left = left + width;
		_parent = _this;
		
		-- status bar buttons
		Desktop.status_buttons = {
			{name = "Exit",icon = "Texture/3DMapSystem/common/shutdown.png", tooltip = "退出", commandName = "File.Exit"},
			{name = "AutoLobbyPage",icon = "Texture/3DMapSystem/common/transmit.png", tooltip = "当前世界服务器状态", commandName = "File.AutoLobbyPage"},
			{name = "ToggleAutotips",icon = "Texture/3DMapSystem/common/bell.png", tooltip = "显示/隐藏提示文字", commandName = "Profile.ToggleAutotips"},
			{name = "ToggleChat",icon = "Texture/3DMapSystem/common/chat.png", tooltip = "显示/隐藏聊天窗口", commandName = "Profile.Chat.MainWnd"},
			{name = "SubmitBug",icon = "Texture/3DMapSystem/common/bug.png", tooltip = "发送Bug或建议", commandName = "File.SubmitBug"},
		}
		local left_sub, btnSize, spacing = 9, 16, 5;
		local nIndex, tab
		for nIndex, tab in ipairs(Desktop.status_buttons) do
			_this = ParaUI.CreateUIObject("button", "b", "_rt", - left_sub-btnSize, 7, btnSize, btnSize)
			_this.background = tab.icon;
			if(tab.tooltip) then 
				_this.tooltip = tab.tooltip
			end	
			_this.onclick = string.format(";System.App.Commands.Call(%q)", tab.commandName);
			_parent:AddChild(_this);	
			left_sub=left_sub+btnSize+spacing;
		end
	end
end


function Desktop.MSGProc1(window, msg)
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		window:ShowWindowFrame(false);
	end
end

-- change the role of the current user
-- @param index: index into the RoleNode for specific role functions
function Desktop.OnChangeRole(index)
	
	local tab = Desktop.ribbon_tabs[nIndex];
	if(tab) then
		local bVisible = Desktop.RibbonControl:ShowTab(tab.name, true);
		
		-- adjust highlighter bg
		local tmp = ParaUI.GetUIObject(Desktop.highlighter_id);
		if(tmp:IsValid()) then
			tmp.visible = bVisible;
			tmp.translationx = (nIndex-1)*(btnSize + spacing);
		end
	end
	
	local node = Desktop.RoleNode:GetChild(index);
	if(node) then
		-- show the MCML file in the toolbox area
		local tmp = ParaUI.GetUIObject(Desktop.highlighter_id);
		if(tmp:IsValid()) then
			tmp.translationx = (index - 1)*64;
		end
	end
end


function Desktop.OnInputTextChange()
	local _this = ParaUI.GetUIObject(libName);
	if(_this:IsValid() == true) then
		_this = _this:GetChild("chatbar");
		if(_this:IsValid() == true) then
			_this = _this:GetChild("inputtext");
			if(_this:IsValid() == true) then
			else
				return;
			end
		end
	end
	if(virtual_key == Event_Mapping.EM_KEY_RETURN or virtual_key == Event_Mapping.EM_KEY_NUMPADENTER) then
		MyCompany.Orion.ChatWnd.SendMSG(_this.text);
		_this.text = "";
		_this:LostFocus();
	elseif(virtual_key == Event_Mapping.EM_KEY_ESCAPE) then
		_this.text = "";
		_this:LostFocus();
	end
end

function Desktop.OnClickSend()
	local _this = ParaUI.GetUIObject(libName);
	if(_this:IsValid() == true) then
		_this = _this:GetChild("chatbar");
		if(_this:IsValid() == true) then
			_this = _this:GetChild("inputtext");
			if(_this:IsValid() == true) then
				MyCompany.Orion.ChatWnd.SendMSG(_this.text);
				_this.text = "";
				_this:LostFocus();
			end
		end
	end
end