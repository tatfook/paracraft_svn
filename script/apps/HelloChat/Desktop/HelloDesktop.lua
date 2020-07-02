--[[
Title: Desktop UI for HelloChat App
Author(s): LiXizhi
Date: 2008/10/26
Desc: The desktop UI contains 
   1. a task bar that is docked at the bottom of the screen and has four functional area from left to right. 
      1. Chat toolbar: for enter chat text and actions
      1. App quick launch bar: frequently used Icon command, such as User Profile, HelloChat Home Page 
      1. Action Toolbar: frequently used actions or special effect.
      1. CommonStatusBar: less useful functions. E.g. social content, chat users, screenshot, control panel.
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/HelloChat/Desktop/HelloDesktop.lua");
MyCompany.HelloChat.Desktop.InitDesktop();
MyCompany.HelloChat.Desktop.SendMessage({type = MyCompany.HelloChat.Desktop.MSGTYPE.SHOW_DESKTOP, bShow = true});
------------------------------------------------------------
]]

-- create class
local libName = "HelloDesktop";
local Desktop = {};
commonlib.setfield("MyCompany.HelloChat.Desktop", Desktop);

-- messge types
Desktop.MSGTYPE = {
	-- show/hide the task bar, 
	-- msg = {bShow = true}
	SHOW_DESKTOP = 1001,
};

-- call this only once at the beginning of the game. 
-- init main bar: this does not show the task bar, it just builds the data structure and messaging system.
function Desktop.InitDesktop()
	if(Desktop.IsInit) then return end
	Desktop.IsInit = true;
	Desktop.name = libName;
	
	-- create the root node for data keeping.
	Desktop.RootNode = CommonCtrl.TreeNode:new({Name = "root", Icon = "", });
	Desktop.ToolbarNode = Desktop.RootNode:AddChild(CommonCtrl.TreeNode:new({Text = "toolbar", Name = "toolbar"}));
	Desktop.StatusBarNode = Desktop.RootNode:AddChild(CommonCtrl.TreeNode:new({Text = "statusbar", Name = "statusbar"}));
		
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
		-- msg = {bShow = true}
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
		_this.background = "Texture/HelloChat/mainbar.png;0 37 110 27:20 0 78 0";
		_parent:AddChild(_this);
		left = left + width;
		_parent = _this;
		
		_this = ParaUI.CreateUIObject("button", "input", "_lt", 15, 3, 60, 22)
		_this.background = "";
		_this.text = "[所有人]";
		_this.tooltip = "更改聊天频道";
		NPL.load("(gl)script/apps/HelloChat/BBSChat/ChannelContextMenu.lua");
		_this.onclick = ";MyCompany.HelloChat.ChannelContextMenu.Show();"
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
        
		NPL.load("(gl)script/apps/HelloChat/BBSChat/BBSChatWnd.lua");
		
		_this = ParaUI.CreateUIObject("imeeditbox", "inputtext", "_fi", 76, 5, 75, 2)
		_this.background = "";
		_guihelper.SetFontColor(_this,"255 255 255");
		_this:GetAttributeObject():SetField("CaretColor", tonumber("FFFFFFFF", 16));
		_this:GetAttributeObject():SetField("SelectedBackColor", tonumber("FF0000FF", 16));
		_this.onchange = ";MyCompany.HelloChat.Desktop.OnInputTextChange();";
		
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "b", "_rt", -66, 6, 16, 18)
		_this.background = "Texture/HelloChat/mainbar.png;152 10 16 18";
		_this.tooltip = "表情动作";
		_guihelper.SetUIColor(_this,"255 255 255");
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "b", "_rt", -50, 4, 39, 22)
		_this.background = "Texture/HelloChat/mainbar.png;111 7 39 22";
		_this.tooltip = "发送";
		_this.onclick = ";MyCompany.HelloChat.Desktop.OnClickSend();";
		_guihelper.SetUIColor(_this,"255 255 255");
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "b", "_rt", -10, 7, 8, 16)
		_this.background = "Texture/HelloChat/mainbar.png;102 12 8 16";
		_guihelper.SetUIColor(_this,"255 255 255");
		_this.tooltip = "隐藏|显示聊天记录";
		_this.onclick = ";MyCompany.HelloChat.ChatWnd.Show();";
		_parent:AddChild(_this);
		
		_parent = _parent.parent;
		
		--
		-- quick launch bar
		--
		width = 80;
		_this = ParaUI.CreateUIObject("container", "quickbar", "_lt", left, 0, width, 35)
		_this.background = "Texture/HelloChat/mainbar.png;110 29 42 35:14 0 10 0";
		_parent:AddChild(_this);
		left = left + width;
		_parent = _this;
		
		_this = ParaUI.CreateUIObject("button", "b", "_lt", 8, 4, 30, 30)
		_this.background = "Texture/3DMapSystem/Desktop/StartPage.png";
		_this.onclick = ";System.App.Commands.Call(\"Profile.HelloChat.HomePage\")";
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
		_this.background = "Texture/HelloChat/mainbar.png;152 29 51 35:1 0 15 0";
		_parent:AddChild(_this);
		left = left + width;
		_parent = _this;
		
		-- TODO: should read from XML file. I just hard code here. 
		Desktop.ribbon_tabs = {
			{name = "Avatar", tooltip="主角", icon="Texture/3DMapSystem/AppIcons/People_64.dds", file="script/apps/HelloChat/Ribbons/AvatarTab.html", bSkipCache=nil},
			{name = "Media", tooltip="应用程序|媒体",icon="Texture/3DMapSystem/AppIcons/VideoRecorder_64.dds", file="script/apps/HelloChat/Ribbons/MediaTab.html", bSkipCache=nil},
			{name = "Creation", tooltip="创造",icon="Texture/3DMapSystem/AppIcons/painter_64.dds", file="script/apps/HelloChat/Ribbons/CreationTab.html", bSkipCache=nil, onshow="MyCompany.HelloChat.RibbonControl.OnShowCreationTab"},
			{name = "Tools", tooltip="工具", icon="Texture/3DMapSystem/AppIcons/Settings_64.dds", file="script/apps/HelloChat/Ribbons/ToolsTab.html", bSkipCache=nil},
			{name = "WorldBuilder", tooltip="高级编辑器",icon="Texture/3DMapSystem/AppIcons/Blueprint_64.dds", file="script/apps/HelloChat/Ribbons/WorldBuilderTab.html", bSkipCache=nil},
		}
		
		local left_sub, btnSize, spacing = 4, 30, 5;
		
		-- left arrow
		_this = ParaUI.CreateUIObject("button", "b", "_lt", left_sub, 9, 14, 20)
		_this.background = "Texture/HelloChat/mainbar.png;199 7 14 20";
		_parent:AddChild(_this);
		left_sub = left_sub + 14 + spacing;
		
		-- highlighter
		_this = ParaUI.CreateUIObject("button", "b", "_lt", left_sub-5, 0, 39, 35)
		_this.background = "Texture/HelloChat/icon_bg.png;0 0 33 33:5 5 5 5";
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
			_this.onclick = string.format(";MyCompany.HelloChat.Desktop.OnClickRibbonTab(%d)", nIndex);
			_parent:AddChild(_this);	
			left_sub=left_sub+btnSize+spacing;
			tabs[tab.name] = tab;
		end
		
		-- right arrow
		_this = ParaUI.CreateUIObject("button", "b", "_lt", left_sub, 9, 14, 20)
		_this.background = "Texture/HelloChat/mainbar.png;218 7 14 20";
		_parent:AddChild(_this);
		
		_parent = _parent.parent;
		
		-- create ribbon manager for toolbar ribbon tabs
		if(not Desktop.RibbonControl) then
			NPL.load("(gl)script/ide/RibbonControl.lua");
			Desktop.RibbonControl = CommonCtrl.RibbonControl:new({
				name = "HelloChat.RibbonControl",
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
		_this.background = "Texture/HelloChat/mainbar.png;203 37 35 27:1 0 15 0";
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
		MyCompany.HelloChat.ChatWnd.SendMSG(_this.text);
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
				MyCompany.HelloChat.ChatWnd.SendMSG(_this.text);
				_this.text = "";
				_this:LostFocus();
			end
		end
	end
end