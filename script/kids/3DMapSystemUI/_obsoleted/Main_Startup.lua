--[[
Title: [Obsoleted in 2008.1.28: use UI/DesktopWnd.lua instead] The first startup window for 3d map system
Author(s): LiXizhi
Date: 2007/10/2
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Main_Startup.lua");
Map3DSystem.UI.Main_Startup.Show()
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/kids/3DMapSystem_Data.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/IntroVideoPanel.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Settings.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/LoadWorldWnd.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/CreateWorldWnd.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/EBook/EBook.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/ParaWorldIntroPage.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/PainterWnd.lua");
-- Themes and Images
Map3DSystem.UI.Main_Startup.ToolTipBG = "Texture/3DMapSystem/Startup/tooltip.png:9 9 9 9";
Map3DSystem.UI.Main_Startup.DefaultHoverBG = "Texture/3DMapSystem/Startup/MainNavButtonBG.png";
Map3DSystem.UI.Main_Startup.DefaultSelectedBG = "Texture/3DMapSystem/Startup/MainNavButtonBG.png";

-- HTML panels
Map3DSystem.UI.Main_Startup.GameIntroPanel = {panelName = "ParaWorldIntro_Panel", HTMLFile = "Texture/3DMapSystem/HTML/ParaWorldIntro.html"};
Map3DSystem.UI.Main_Startup.CreditsPanel = {panelName = "Credits_Panel", HTMLFile = "Texture/3DMapSystem/HTML/Credits.html"};
Map3DSystem.UI.Main_Startup.VideoTutorialPanel = {panelName = "VideoTutorial_Panel", HTMLFile = "Texture/3DMapSystem/HTML/VideoTutorial.html"};
Map3DSystem.UI.Main_Startup.OfficialSitePanel = {panelName = "OfficialSite_Panel", HTMLFile = "Texture/3DMapSystem/HTML/OfficialSite.html"};

-- GameIntroPanel
-- @see this is an example of a panel control. it show how to write ShowUICallback()
function Map3DSystem.UI.Main_Startup.OnShowUICallback_GameIntroPanel(bShow, _parent)
	Map3DSystem.UI.Main_Startup.OnShowUICallback_HTMLPanel(bShow, _parent, Map3DSystem.UI.Main_Startup.GameIntroPanel)
end
-- CreditsPanel
function Map3DSystem.UI.Main_Startup.OnShowUICallback_CreditsPanel(bShow, _parent)
	Map3DSystem.UI.Main_Startup.OnShowUICallback_HTMLPanel(bShow, _parent, Map3DSystem.UI.Main_Startup.CreditsPanel)
end

-- VideoTutorialPanel
function Map3DSystem.UI.Main_Startup.OnShowUICallback_VideoTutorialPanel(bShow, _parent)
	--Map3DSystem.UI.Main_Startup.OnShowUICallback_HTMLPanel(bShow, _parent, Map3DSystem.UI.Main_Startup.VideoTutorialPanel)
	NPL.load("(gl)script/kids/3DMapSystemUI/InGame/WebBrowser.lua");
	Map3DSystem.UI.WebBrowser.Show(bShow, _parent);
end

-- OfficialSitePanel
function Map3DSystem.UI.Main_Startup.OnShowUICallback_OfficialSitePanel(bShow, _parent)
	Map3DSystem.UI.Main_Startup.OnShowUICallback_HTMLPanel(bShow, _parent, Map3DSystem.UI.Main_Startup.OfficialSitePanel)
end


-- called by GameIntroPanel and CreditsPanel 
function Map3DSystem.UI.Main_Startup.OnShowUICallback_HTMLPanel(bShow, _parent, panelData)
	local _this  = ParaUI.GetUIObject(panelData.panelName);
	if(_this:IsValid()) then
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		_this.visible = bShow;
		local ctl = CommonCtrl.GetControl(panelData.panelName);
		if(ctl~=nil) then
			if(not bShow) then
				ctl:Unload()
			else
				if(ctl.source~=panelData.HTMLFile) then
					ctl:LoadFile(panelData.HTMLFile);
				end	
			end
		end	
	else
		if(bShow == false) then return end
		
		-- create and show the panel in _parent
		NPL.load("(gl)script/ide/HTMLRenderer.lua");
		
		local ctl = CommonCtrl.GetControl(panelData.panelName);
		if(not ctl) then
			ctl = CommonCtrl.HTMLRenderer:new{
				name = panelData.panelName,
				alignment = "_fi",
				left=10, top=10,
				width = 10,
				height = 10,
				parent = _parent,
				source = panelData.HTMLFile,
			};
		else
			ctl.parent = _parent;
			if(ctl.source~=panelData.HTMLFile) then
				ctl:LoadFile(panelData.HTMLFile);
			end	
		end	
		
		ctl:Show(true);
	end
end

-- Exit app button.
function Map3DSystem.UI.Main_Startup.OnClickCallback_ExitApp()
	_guihelper.MessageBox("你确定要退出程序么?", Map3DSystem.UI.Main_Startup.OnExitApp);
end
function Map3DSystem.UI.Main_Startup.OnExitApp()
	ParaGlobal.ExitApp();
end
-- the default page to display
Map3DSystem.UI.Main_Startup.DefaultPanelIndex = 2;

-- all tag buttons
Map3DSystem.UI.Main_Startup.NavButtonSet = {
	{
		Type = "Panel",
		Text = "开场动画",
		OriginalBG = "Texture/3DMapSystem/Startup/nav1.png; 0 0 77 100";
		SelectedBG = nil,
		HoverBG = nil,
		-- it should be a function of following format: function FuncName(bShow, _parent, parentWindow) end
		ShowUICallback = Map3DSystem.UI.IntroVideoPanel.OnShowUICallback,
	}, 
	{
		Type = "Panel",
		Text = "帕拉巫世界",
		OriginalBG = "Texture/3DMapSystem/Startup/nav2.png; 0 0 77 100";
		SelectedBG = "Texture/3DMapSystem/Startup/nav2.png; 0 0 77 100",
		HoverBG = nil,
		-- it should be a function of following format: function FuncName(bShow, _parent, parentWindow) end
		ShowUICallback = Map3DSystem.UI.ParaWorldIntroPage.Show,
		-- whether it is the currently selected panel 
		IsSelected = true;
	}, 
	{
		Type = "Panel",
		Text = "视频教程",
		OriginalBG = "Texture/3DMapSystem/Startup/nav3.png; 0 0 77 100";
		SelectedBG = nil,
		HoverBG = nil,
		-- it should be a function of following format: function FuncName(bShow, _parent, parentWindow) end
		ShowUICallback = Map3DSystem.UI.Main_Startup.OnShowUICallback_VideoTutorialPanel,
	}, 
	{
		Type = "Separator";
	},
	{
		Type = "Panel",
		Text = "超级书吧",
		ToolTip = "点击 <<超级书吧>>, 这里有许多3D电子书，电子书的每一页都有一个魔法门，带你进入书中的3D世界。\n\n在这里，你也可以创建并发行你自己的3D电子书",
		OriginalBG = "Texture/3DMapSystem/Startup/nav4.png; 0 0 77 100";
		SelectedBG = nil,
		HoverBG = nil,
		-- it should be a function of following format: function FuncName(bShow, _parent, parentWindow) end
		ShowUICallback = EBook.Show,
	}, 
	{
		Type = "Panel",
		Text = "开创世界",
		ToolTip = "点击 <<开创世界>>, 您可以开创自己的<新世界>。在这里您可以发挥想象力创作出你的梦境",
		OriginalBG = "Texture/3DMapSystem/Startup/nav5.png; 0 0 77 100";
		SelectedBG = nil,
		HoverBG = nil,
		-- it should be a function of following format: function FuncName(bShow, _parent, parentWindow) end
		ShowUICallback = Map3DSystem.UI.CreateWorldWnd.Show,
	}, 
	{
		Type = "Panel",
		Text = "读取世界",
		ToolTip = "点击 <<读取世界>>, 您可以访问您本地计算机中的3D世界；这里所有的世界都是其他小朋友和开发者使用本软件制作的。",
		OriginalBG = "Texture/3DMapSystem/Startup/nav6.png; 0 0 77 100";
		SelectedBG = nil,
		HoverBG = nil,
		-- it should be a function of following format: function FuncName(bShow, _parent, parentWindow) end
		ShowUICallback = Map3DSystem.UI.LoadWorldWnd.Show,
	}, 
	{
		Type = "Panel",
		Text = "世界地图",
		OriginalBG = "Texture/3DMapSystem/Startup/nav7.png; 0 0 77 100";
		SelectedBG = nil,
		HoverBG = nil,
		-- it should be a function of following format: function FuncName(bShow, _parent, parentWindow) end
		ShowUICallback = Map3DSystem.UI.MapMainWnd.Show,
	}, 
	{
		Type = "Separator";
	},
	{
		Type = "Panel",
		Text = "系统设置",
		ToolTip = "点击 <<系统设置>>, 您可以随时根据您的计算机性能，调整3D显示画质。\n\n如果您的程序运行缓慢，请将<图形>模式调到\"简\"; \n\n高级用户也可以按F2键调整分辨率.",
		OriginalBG = "Texture/3DMapSystem/Startup/nav8.png; 0 0 77 100";
		SelectedBG = nil,
		HoverBG = nil,
		-- it should be a function of following format: function FuncName(bShow, _parent, parentWindow) end
		ShowUICallback = Map3DSystem.UI.Settings.ShowSettings,
	}, 
	{
		Type = "Panel",
		Text = "制作群体",
		OriginalBG = "Texture/3DMapSystem/Startup/nav9.png; 0 0 77 100";
		SelectedBG = nil,
		HoverBG = nil,
		-- it should be a function of following format: function FuncName(bShow, _parent, parentWindow) end
		ShowUICallback = Map3DSystem.UI.Main_Startup.OnShowUICallback_CreditsPanel,
	}, 
	{
		Type = "Panel",
		Text = "进入官网",
		OriginalBG = "Texture/3DMapSystem/Startup/nav10.png; 0 0 77 100";
		SelectedBG = nil,
		HoverBG = nil,
		-- it should be a function of following format: function FuncName() end
		ShowUICallback = Map3DSystem.UI.Main_Startup.OnShowUICallback_OfficialSitePanel,
	}, 
	{
		Type = "Button",
		Text = "退出程序",
		OriginalBG = "Texture/3DMapSystem/Startup/nav11.png; 0 0 77 100";
		SelectedBG = nil,
		HoverBG = nil,
		-- it should be a function of following format: function FuncName() end
		ClickCallback = Map3DSystem.UI.Main_Startup.OnClickCallback_ExitApp,
	}, 
	{
		Type = "Separator";
	},
};
	
function Map3DSystem.UI.Main_Startup.Show()
	local _this,_parent;
	
	_this=ParaUI.GetUIObject("Main_Startup");
	if(_this:IsValid() == false) then
		-- Main_Startup
		_this=ParaUI.CreateUIObject("container","Main_Startup","_fi", 0, 0, 0, 0);
		--_this.background = "Texture/uncheckbox.png:10 10 10 10";
		--_this.background = "Texture/3DMapSystem/Startup/Main_Startup.png:4 4 4 4";
		--_this.background = "Texture/whitedot.png";
		_this.background = "Texture/3DMapSystem/Startup/EasyFrame.png:2 2 2 2";
		_this:AttachToRoot();
		_parent = _this;

		--_this = ParaUI.CreateUIObject("text", "title", "_lt", 154, 26, 633, 12)
		--_this.text = "将全世界的网上力量和资源团结起来，共同创建属于每一个人的游戏世界。   - ParaEngine 宗旨";
		--_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label32", "_lb", 3, -21, 416, 16)
		_this.text = "2007 @ ParaEngine Corporation. All Rights Reserved.";
		_this:GetFont("text").color = "105 105 105";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label3", "_rb", -336, -21, 320, 16)
		_this.text = "帕拉巫小宇宙v1.0  Powered by ParaEngine";
		_this:GetFont("text").color = "105 105 105";
		_parent:AddChild(_this);

		-- PanelMain
		_this = ParaUI.CreateUIObject("container", "PanelAndNavbar", "_fi", 6, 107, 215, 32)
		--_this.background = "Texture/3DMapSystem/Startup/Main_Startup.png:4 4 4 4";
		--_this.background = "Texture/whitedot.png";
		--_this.background = "Texture/3DMapSystem/Startup/EasyFrame.png:2 2 2 2";
		_this.background = "";
		_parent:AddChild(_this);
		
		-- LoginPanel
		_this = ParaUI.CreateUIObject("container", "LoginPanel", "_rt", -209, 107, 202, 200)
		_this.background = "Texture/3DMapSystem/Startup/LoginPanel.png:3 3 3 3";
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("container", "LoginTitleBG", "_lt", 16, 16, 179, 26)
		_this.background = "Texture/3DMapSystem/Startup/LoginTitleBG.png:4 4 4 4";
		_parent:AddChild(_this);
		
		--_this = ParaUI.CreateUIObject("container", "LoginTitleIcon", "_lt", 16, 5, 48, 48);
		--_this.background = "Texture/3DMapSystem/Startup/LoginIcon.png; 0 0 48 48";
		--_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("text", "LoginTitle", "_lt", 80, 24, 56, 16)
		_this.text = "请 登 陆";
		_this:GetFont("text").color = "165 42 42";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("text", "label1", "_lt", 1, 65, 40, 16)
		_this.text = "用户名";
		_guihelper.SetUIFontFormat(_this, 2+32+256);
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("imeeditbox", "editboxUserName", "_lt", 54, 62, 78, 20)
		_this.background = "Texture/3DMapSystem/Startup/LoginEditbox.png:4 4 4 4";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("text", "label2", "_lt", 1, 90, 40, 16)
		_this.text = "密  码";
		_guihelper.SetUIFontFormat(_this, 2+32+256);
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("imeeditbox", "textBoxPassWord", "_lt", 54, 87, 78, 20)
		_this.PasswordChar = "*";
		_this.background = "Texture/3DMapSystem/Startup/LoginEditbox.png:4 4 4 4";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "LoginBtnTemp", "_lt", 136, 55, 60, 50);
		_this.background = "Texture/3DMapSystem/Startup/LoginBtnSquare.png; 0 0 60 50";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("text", "label7", "_lt", 1, 115, 40, 16)
		_this.text = "域  名";
		_guihelper.SetUIFontFormat(_this, 2+32+256);
		_parent:AddChild(_this);
		
		NPL.load("(gl)script/ide/dropdownlistbox.lua");
		local ctl = CommonCtrl.dropdownlistbox:new{
			name = "comboBoxDomain",
			alignment = "_lt",
			left = 54,
			top = 112,
			width = 133,
			height = 20,
			buttonwidth = 16,
			dropdownheight = 106,
 			parent = _parent,
			text = "",
			listbox_bg = "Texture/3DMapSystem/Startup/LoginEditbox.png:4 4 4 4",
			editbox_bg = "Texture/3DMapSystem/Startup/LoginEditbox.png:4 4 4 4",
			dropdownbutton_bg = "Texture/3DMapSystem/Startup/LoginDropdownBtn.png",
			--listbox_bg = "Texture/uncheckbox.png:4 4 4 4", -- list box background texture
			--editbox_bg = "Texture/uncheckbox.png:4 4 4 4", -- edit box background texture
			items = {"www.kids3dmovie.com", "www.paraengine.com", },
		};
		ctl:Show();


		NPL.load("(gl)script/ide/CheckBox.lua");
		local ctl = CommonCtrl.checkbox:new{
			name = "checkboxRememberUserNamePassword",
			alignment = "_lt",
			left = 12,
			top = 140,
			width = 91,
			height = 10,
			parent = _parent,
			isChecked = true,
			checked_bg = "Texture/3DMapSystem/Startup/LoginCheckedBtn.png; 0 0 10 10",
			unchecked_bg = "Texture/3DMapSystem/Startup/LoginUncheckedBtn.png; 0 0 10 10",
			text = "记住帐户",
		};
		ctl:Show();
		
		_this = ParaUI.CreateUIObject("button", "btnLogin", "_lt", 5, 160, 60, 24)
		_this.text = "忘记密码";
		_this.background = "Texture/3DMapSystem/Startup/ButtonLightBlue.png: 4 4 4 4";
		--_this.rotation = -0.2;
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "btnRegister", "_lt", 70, 160, 60, 24)
		_this.text = "注册";
		_this.background = "Texture/3DMapSystem/Startup/ButtonLightBlue.png: 4 4 4 4";
		--_this.rotation = -0.2;
		--_guihelper.SetVistaStyleButton(_this, "", "Texture/uncheckbox.png:4 4 4 4");
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "button1", "_lt", 135, 160, 60, 24)
		--_this.rotation = -0.2;
		_this.text = "离线浏览";
		_this.tooltip = "离线浏览";
		_this.background = "Texture/3DMapSystem/Startup/ButtonLightBlue.png: 4 4 4 4";
		--_this.rotation = -0.2;
		--_guihelper.SetVistaStyleButton(_this, "", "Texture/uncheckbox.png:4 4 4 4");
		_this.onclick = ";Map3DSystem.UI.Main_Startup.OnLoginOfflineMode();";
		_parent:AddChild(_this);

		-- top bar
		_this = ParaUI.CreateUIObject("container", "topbar", "_mt", 1, 1, 1, 102);
		_this.background = "";
		_parent = ParaUI.GetUIObject("Main_Startup");
		_parent:AddChild(_this);
		_parent = _this;
		
		_this = ParaUI.CreateUIObject("container", "TopBarBG", "_mt", 0, 0, 0, 102)
		_this.background = "Texture/3DMapSystem/Startup/TopBarBG.png:1 1 1 1";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("container", "TopBarBGDeco", "_mt", 0, 0, 0, 102)
		_this.background = "Texture/3DMapSystem/Startup/TopBarDeco.png;0 0 1024 102";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("container", "TopBarBGRight", "_rt", -512, 0, 512, 102)
		_this.background = "Texture/3DMapSystem/Startup/TopBarRight.png;0 0 512 102";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("container", "TopBarBGRight", "_lt", 0, 0, 1024, 102)
		_this.background = "Texture/3DMapSystem/Startup/ParaEngineTenet.png;0 0 1024 102";
		_parent:AddChild(_this);
		
		-- LOGO
		_this = ParaUI.CreateUIObject("button", "LOGO", "_lt", 0, 0, 128, 128)
		_this.background = "Texture/kidui/explorer/logo_cn.png";
		_guihelper.SetUIColor(_this, "255 255 255");
		_this.enabled = false;
		_this.translationx=5;
		_this.translationy=-6;
		_parent:AddChild(_this);
		
		_parent = ParaUI.GetUIObject("PanelAndNavbar");
		
		_this = ParaUI.CreateUIObject("container", "panelMain", "_fi", 0, 20, 0, 0)
		--_this.background = "";
		_this.background = "Texture/3DMapSystem/Startup/EasyFrame.png :2 2 2 2";
		_parent:AddChild(_this);
		-- panelNavBar
		_this = ParaUI.CreateUIObject("container", "panelNavBar", "_mt", 0, 0, 0, 20);
		_this.background = "";
		_parent:AddChild(_this);
		_parent = _this;
		
		local index, button;
		local left, top, width, height = 0, 0, 70, 20
		local lastGroupLeft = left;
		for index, button in Map3DSystem.UI.Main_Startup.NavButtonSet do
			if(button.Type == "Panel" or button.Type == "Button" ) then
				_this = ParaUI.CreateUIObject("button", "btn"..index, "_lt", left, top, width + 1, height + 1)
				_this.text = button.Text;
				_this:GetFont("text").color = "24 57 124";
				--_guihelper.SetUIFontFormat(_this, 36+256);-- 36 for single-lined  vertical center alignment
				--_guihelper.SetVistaStyleButton(_this, "", Map3DSystem.UI.Main_Startup.DefaultHoverBG);
				--_this.rotation = -0.4;
				_this.onclick = string.format(";Map3DSystem.UI.Main_Startup.OnClickNavButton(%d)",index);
				
				--_this.background = button.OriginalBG;
				_this.background = "Texture/3DMapSystem/Startup/TabBtnUnpressed.png: 2 2 2 2";
				_guihelper.SetUIColor(_this, "255 255 255");
				
				--_this.onmouseenter = string.format(";Map3DSystem.UI.Main_Startup.OnMouseEnterNavButton(%d)",index);
				--_this.onmouseleave = string.format(";Map3DSystem.UI.Main_Startup.OnMouseLeaveNavButton(%d)",index);
				_parent:AddChild(_this);
				left = left+width;
			--elseif(button.Type == "Separator") then
				--_this = ParaUI.CreateUIObject("button", "NavButton"..index, "_lt", lastGroupLeft, top+height, left-lastGroupLeft, 3)
				--_this.background = "Texture/alphadot.png";
				--_guihelper.SetUIColor(_this, "255 255 255");
				--_parent:AddChild(_this);
				--left = left+16; -- seperator width is 16
				--lastGroupLeft = left;
			end	
		end
		
		-- panelStatistics
		_this = ParaUI.CreateUIObject("container", "panelStatistics", "_rt", -209, 314, 202, 135)
		--_this.background = "";
		_this.background = "Texture/3DMapSystem/Startup/StatusPanel.png:7 22 2 2";
		_parent = ParaUI.GetUIObject("Main_Startup");
		_parent:AddChild(_this);
		_parent = _this;
		
		--_this = ParaUI.CreateUIObject("container", "StautsTitleIcon", "_lt", 5, -5, 32, 32);
		--_this.background = "Texture/3DMapSystem/Startup/StatusIcon.png";
		--_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("text", "textStatus", "_lt", 70, 5, 80, 20);
		_this.text = " 统     计";
		--_this.background = "Texture/3DMapSystem/Startup/StatusBtn.png: 5 5 5 5";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label4", "_lt", 19, 40, 210, 36)
		_this.text = [[XXXXXX 位用户在线
		16000 平方公里用户创建的
		虚拟世界
		100000 万平方公里虚拟土地
		待售]];
		_parent:AddChild(_this);

		-- panelNews
		_this = ParaUI.CreateUIObject("container", "panelNews", "_mr", 7, 456, 202, 32)
		--_this.background = "";
		_this.background = "Texture/3DMapSystem/Startup/StatusPanel.png:7 22 2 2";
		_parent = ParaUI.GetUIObject("Main_Startup");
		_parent:AddChild(_this);
		_parent = _this;

		--_this = ParaUI.CreateUIObject("container", "StautsTitleIcon", "_lt", 5, -5, 32, 32);
		--_this.background = "Texture/3DMapSystem/Startup/NewsIcon.png";
		--_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("text", "textNews", "_lt", 70, 5, 80, 20);
		_this.text = " 新     闻";
		--_this.background = "Texture/3DMapSystem/Startup/StatusBtn.png: 5 5 5 5";
		_parent:AddChild(_this);

		NPL.load("(gl)script/ide/TreeView.lua");
		local ctl = CommonCtrl.TreeView:new{
			name = "treeViewNews",
			alignment = "_fi",
			left = 2,
			top = 40,
			width = 2,
			height = 2,
			parent = _parent,
			ShowIcon = false,
			DefaultIndentation = 15,
			DefaultNodeHeight = 22,
		};
		local node = ctl.RootNode;
		node = node:AddChild( CommonCtrl.TreeNode:new({Text = "2007年10月-12月", Name = "Node3", }) );
		node = node:AddChild( CommonCtrl.TreeNode:new({Text = "帕拉巫社区正在开发中", Name = "Node0", }) );
		node = node.parent;
		node = node:AddChild( CommonCtrl.TreeNode:new({Text = "3D地图系统上线", Name = "Node7", }) );
		node = node.parent;
		node = node:AddChild( CommonCtrl.TreeNode:new({Text = "赠送虚拟土地", Name = "Node2", }) );
		node = node.parent;
		node = node:AddChild( CommonCtrl.TreeNode:new({Text = "注册用户达到2万", Name = "Node2", }) );
		node = node.parent;
		node = node:AddChild( CommonCtrl.TreeNode:new({Text = "儿童社区上线", Name = "Node12", }) );
		node = node.parent;
		node = node:AddChild( CommonCtrl.TreeNode:new({Text = "中央电视台少儿频道", Name = "Node12", }) );
		node = node.parent;
		node = node.parent;
		node = node:AddChild( CommonCtrl.TreeNode:new({Text = "2007年9月", Name = "Node4", }) );
		node = node:AddChild( CommonCtrl.TreeNode:new({Text = "KidsMovie发行上市", Name = "Node8", }) );
		node = node.parent;
		node = node:AddChild( CommonCtrl.TreeNode:new({Text = "少年宫大篷车活动", Name = "Node10", }) );
		node = node.parent;
		node = node:AddChild( CommonCtrl.TreeNode:new({Text = "3D创意培训班开课了", Name = "Node11", }) );
		node = node.parent;
		node = node:AddChild( CommonCtrl.TreeNode:new({Text = "KidsMovie国际版发行", Name = "Node11", }) );
		node = node.parent;
		node = node.parent;
		ctl:Show();
		
		-- tooltip
		_parent = ParaUI.GetUIObject("Main_Startup");
		_this = ParaUI.CreateUIObject("button", "tooltip", "_lt", 0, 0, 300, 120)
		_this.background = Map3DSystem.UI.Main_Startup.ToolTipBG;
		_guihelper.SetUIColor(_this, "255 255 255");
		_guihelper.SetUIFontFormat(_this, 0+16);-- left alignment
		_this.spacing = 10;
		_this.enabled = false;
		_this:BringToFront();
		_this.visible = false;
		_this:UpdateRect();
		_parent:AddChild(_this);
		
		-- update panel
		Map3DSystem.UI.Main_Startup.UpdateSelectedPanel();
	end	
end

-- @param nSelectedIndex: panel index to be selected. if this is nil. The current selection is not changed, but UI is still updated
function Map3DSystem.UI.Main_Startup.UpdateSelectedPanel(nSelectedIndex)
	local index, button, _this,_parent;
	_parent = ParaUI.GetUIObject("Main_Startup");
	if(_parent:IsValid()) then
		_parent=(_parent:GetChild("PanelAndNavbar")):GetChild("panelMain");
	end	
	local left, top, width, height = 10, 0, 50, 56
	local lastGroupLeft = left;
	for index, button in Map3DSystem.UI.Main_Startup.NavButtonSet do
		if(button.Type == "Panel") then
			_this = ParaUI.GetUIObject("btn"..index)
			if(_this:IsValid()) then
				if(not nSelectedIndex) then
					if(button.IsSelected) then
						nSelectedIndex = index
					end
				end
				if(nSelectedIndex == index) then
					button.IsSelected = true;
					--_this.background = Map3DSystem.UI.Main_Startup.DefaultSelectedBG;
					--_this.background = button.SelectedBG;
					_this.background = "Texture/3DMapSystem/Startup/TabBtnPressed.png: 2 2 2 2";
					_this:GetFont("text").color = "204 102 51";
					if(button.ShowUICallback~=nil) then
						if(not button.window) then
							local app = CommonCtrl.os.CreateGetApp("Main_Startup");
							-- register a window with index as its name
							button.window = app:RegisterWindow(tostring(index), nil, Map3DSystem.UI.Main_Startup.MsgProc);
							-- keep button index in window struct
							button.window.buttonIndex = index;
						end
						button.ShowUICallback(true, _parent, button.window);
					end	
				elseif(button.IsSelected) then
					button.IsSelected = false;
					--_this.background = button.OriginalBG;
					_this.background = "Texture/3DMapSystem/Startup/TabBtnUnpressed.png: 2 2 2 2";
					_this:GetFont("text").color = "24 57 124";
					if(button.ShowUICallback~=nil) then
						button.ShowUICallback(false, nil, button.window);
					end
				end
			end
		end	
	end
end

-- event handlers
function Map3DSystem.UI.Main_Startup.MsgProc(window, msg)
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		local button  = Map3DSystem.UI.Main_Startup.NavButtonSet[window.buttonIndex];
		if(button ~= nil) then
			-- open the default page.
			Map3DSystem.UI.Main_Startup.UpdateSelectedPanel(Map3DSystem.UI.Main_Startup.DefaultPanelIndex);
		end
	end
end

function Map3DSystem.UI.Main_Startup.OnClickNavButton(index)
	local button = Map3DSystem.UI.Main_Startup.NavButtonSet[index];
	if(button.Type == "Panel") then
		Map3DSystem.UI.Main_Startup.UpdateSelectedPanel(index);
	elseif(button.Type == "Button") then
		if(button.ClickCallback~=nil) then
			button.ClickCallback();
		end
	end	
end

function Map3DSystem.UI.Main_Startup.OnMouseLeaveNavButton(index)
	local button = Map3DSystem.UI.Main_Startup.NavButtonSet[index];
	local _this;
	_this=ParaUI.GetUIObject("Main_Startup");
	if(_this:IsValid()) then
		_tooltip=_this:GetChild("tooltip");
		_this = (_this:GetChild("PanelAndNavbar")):GetChild("panelNavBar");
		if(_this:IsValid()) then
			_this=_this:GetChild("btn"..index);
			if(_this:IsValid()) then
				-- get the nav button object
				_this.scalingx = 1;
				_this.scalingy = 1;
				
				_tooltip.visible = false;
			end
		end
	end
end

function Map3DSystem.UI.Main_Startup.OnMouseEnterNavButton(index)
	local button = Map3DSystem.UI.Main_Startup.NavButtonSet[index];
	local _this, _tooltip;
	_this=ParaUI.GetUIObject("Main_Startup");
	if(_this:IsValid()) then
		_tooltip=_this:GetChild("tooltip");
		_this = (_this:GetChild("PanelAndNavbar")):GetChild("panelNavBar");
		if(_this:IsValid()) then
			_this=_this:GetChild("btn"..index);
			if(_this:IsValid()) then
				-- get the nav button object
				_this.scalingx = 1.15;
				_this.scalingy = 1.15;
				
				if(button.ToolTip~=nil) then
					local left,top, _,height = _this:GetAbsPosition();
					_tooltip.visible = true;
					_tooltip.translationx = left;
					_tooltip.translationy = top+height+2;
					_tooltip.text = button.ToolTip;
				else
					_tooltip.visible = false;	
				end
			end
		end
	end
end

-- destory the control
function Map3DSystem.UI.Main_Startup.OnDestory()
	ParaUI.Destroy("Main_Startup");
end

function Map3DSystem.UI.Main_Startup.OnLoginOfflineMode()
	Map3DSystem.UI.Main_Startup.OnDestory();
	main_state="ingame";
end

