--[[
Title: browse all applications from official site. Download and install applications to the current computer. 
Author(s): LiXizhi
Date: 2008/1/12
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/EditApps/BrowseAppsWnd.lua");
Map3DSystem.App.EditApps.ShowBrowseAppWnd(app);
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");

commonlib.setfield("Map3DSystem.App.EditApps.BrowseAppsWnd", {});

-- the current logged in user's root bag object. of type Map3DSystem.App.EditApps.Bag
Map3DSystem.App.EditApps.UserBag = nil;

-- display the main inventory window for the current user.
function Map3DSystem.App.EditApps.ShowBrowseAppWnd(_app)
	NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
	local _wnd = _app:FindWindow("BrowseAppsWnd") or _app:RegisterWindow("BrowseAppsWnd", nil, Map3DSystem.App.EditApps.BrowseAppsWnd.MSGProc);
	
	local _wndFrame = _wnd:GetWindowFrame();
	if(not _wndFrame) then
		_wndFrame = _wnd:CreateWindowFrame{
			icon = "Texture/3DMapSystem/common/plugin_add.png",
			text = "浏览应用程序",
			initialPosX = 200,
			initialPosY = 150,
			initialWidth = 640,
			initialHeight = 370,
			allowDrag = true,
			initialPosX = 150,
			initialPosY = 70,
			initialWidth = 600,
			initialHeight = 500,
			ShowUICallback = Map3DSystem.App.EditApps.BrowseAppsWnd.Show,
		};
	end
	_wnd:ShowWindowFrame(true);
end


--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
-- @param _parent: parent window inside which the content is displayed. it can be nil.
function Map3DSystem.App.EditApps.BrowseAppsWnd.Show(bShow, _parent, parentWindow)
	local _this;
	Map3DSystem.App.EditApps.BrowseAppsWnd.parentWindow = parentWindow;
	
	_this=ParaUI.GetUIObject("BrowseApps_cont");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		
		if(_parent==nil) then
			_this=ParaUI.CreateUIObject("container","BrowseApps_cont","_lt",100,50, 606, 390);
			_this:AttachToRoot();
		else
			_this = ParaUI.CreateUIObject("container", "BrowseApps_cont", "_fi",5,0,5,5);
			_this.background = ""
			_parent:AddChild(_this);
		end	
		_parent = _this;

		_this = ParaUI.CreateUIObject("text", "title", "_lt", 3, 9, 97, 15)
		_this.text = "应用程序目录";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label6", "_rt", -265, 54, 75, 15)
		_this.text = "显示分类:";
		_parent:AddChild(_this);

		NPL.load("(gl)script/ide/dropdownlistbox.lua");
		local ctl = CommonCtrl.dropdownlistbox:new{
			name = "comboBoxAppCategory",
			alignment = "_rt",
			left = -169,
			top = 51,
			width = 166,
			height = 23,
			dropdownheight = 106,
 			parent = _parent,
 			AllowUserEdit = false,
			text = "全部 (15)",
			items = {"全部 (15)", "官方程序 (15)", "游戏 (3)", "交友 (5)", "娱乐 (1)", "教育 (1)", "商务 (1)", "工具 (3)", },
		};
		-- TODO: retrieve item count in categories from application app server
		ctl:Show();

		-----------------------------------------------------------
		-- main app list
		-----------------------------------------------------------
		NPL.load("(gl)script/ide/TreeView.lua");
		local ctl = CommonCtrl.TreeView:new{
			name = "treeViewBrowseAppList",
			alignment = "_fi",
			left = 0,
			top = 76,
			width = 0,
			height = 0,
			parent = _parent,
			container_bg = "Texture/3DMapSystem/common/ThemeLightBlue/tabview_body.png: 5 5 5 5", --"Texture/3DMapSystem/Common/BG2.png:8 8 8 8",
			DefaultIndentation = 5,
			DefaultNodeHeight = 22,
			DrawNodeHandler = Map3DSystem.App.EditApps.BrowseAppsWnd.DrawAppNodeHandler,
			onclick = Map3DSystem.App.EditApps.BrowseAppsWnd.OnClickApp,
		};
		local node = ctl.RootNode;
		
		-- TODO: load initial data set. 
		NPL.load("(gl)script/kids/3DMapSystemApp/appkeys.lua");
		local key, app;
		for key, app in ipairs(Map3DSystem.App.AppDirectory) do
			
			if(app.icon==nil or app.icon=="") then
				-- display the icon according to whether it is official or third party, how popular, etc. if it does not provide one. 
				if(app.IsOfficial) then
					-- TODO: use official icon
					app.icon = "Texture/3DMapSystem/IntroPage/circle.png";
				else
					-- TODO: use standard app icon
					app.icon = "Texture/3DMapSystem/IntroPage/downflow.png";
				end	
			end
			
			node:AddChild(CommonCtrl.TreeNode:new({Name = key, Text = app.Title or app.SubTitle or app.name, type = "app", Icon = app.icon, app=app, date = app.date, popularity = app.popularity, activities = app.activities}));
		end
		-- do not update the treeview, since we will sort later on. 
		ctl:Show(true, true);
		
		_this = ParaUI.CreateUIObject("text", "title", "_lt", 3, 9, 97, 15)
		_this.text = "应用程序目录";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("imeeditbox", "searchText", "_rt", -169, 8, 135, 24)
		_this.text = "<搜索>";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "searchApps", "_rt", -27, 8, 24, 24)
		_this.background = "Texture/3DMapSystem/webbrowser/goto.png";
		_parent:AddChild(_this);

		---------------------------------------------
		-- tabs
		---------------------------------------------
		NPL.load("(gl)script/ide/MainMenu.lua");
		local ctl = CommonCtrl.GetControl("BrowseAppSortMenu");
		if(ctl==nil)then
			ctl = CommonCtrl.MainMenu:new{
				name = "BrowseAppSortMenu",
				alignment = "_lt",
				left = 0,
				top = 50,
				width = 240,
				height = 26,
				parent = _parent,
				MouseOverItemBG = "",
				UnSelectedMenuItemBG = "Texture/3DMapSystem/common/ThemeLightBlue/tabitem_unselected.png: 6 6 6 2",
				SelectedMenuItemBG = "Texture/3DMapSystem/common/ThemeLightBlue/tabitem_selected.png: 6 6 6 2",
				onclick = function (node, param1) _guihelper.MessageBox(node.Text) end
			};
			local node = ctl.RootNode;
			node:AddChild(CommonCtrl.TreeNode:new({Text = "最热门", Name = "Popular", onclick = Map3DSystem.App.EditApps.BrowseAppsWnd.OnClickSort}));
			node:AddChild(CommonCtrl.TreeNode:new({Text = "最新添加", Name = "Newest", onclick = Map3DSystem.App.EditApps.BrowseAppsWnd.OnClickSort}));
			node:AddChild(CommonCtrl.TreeNode:new({Text = "最多用户", Name = "MostUsers", onclick = Map3DSystem.App.EditApps.BrowseAppsWnd.OnClickSort}));
		else
			ctl.parent = _parent
		end	
		
		ctl:Show(true);
		
		-- retrieve list and sorting by popularity (index == 1)
		CommonCtrl.MainMenu.OnClickTopLevelMenuItem("BrowseAppSortMenu", 1);
		
	else
		if(not bShow) then
			Map3DSystem.App.EditApps.BrowseAppsWnd.OnDestory()
		end
	end	
end

-- destory the control
function Map3DSystem.App.EditApps.BrowseAppsWnd.OnDestory()
	ParaUI.Destroy("BrowseApps_cont");
end

-- sorting the application list by a sort critria
function Map3DSystem.App.EditApps.BrowseAppsWnd.OnClickSort(treeNode)
	local ctl = CommonCtrl.GetControl("treeViewBrowseAppList");
	if(ctl==nil)then
		return
	end
	local node = ctl.RootNode;
	
	if(treeNode.Name == "Popular") then
		node:SortChildren(CommonCtrl.TreeNode.GenerateGreaterCFByField("popularity")); -- sort children by field
	elseif(treeNode.Name == "Newest") then
		node:SortChildren(CommonCtrl.TreeNode.GenerateGreaterCFByField("date")); -- sort children by field
	elseif(treeNode.Name == "MostUsers") then
		node:SortChildren(CommonCtrl.TreeNode.GenerateGreaterCFByField("activities")); -- sort children by field
	end
	ctl:Update();
end

-- user clicked to edit an application node.
function Map3DSystem.App.EditApps.BrowseAppsWnd.OnClickApp(treeNode)
	-- only one node is selected for editing at a time
	if(Map3DSystem.App.EditApps.BrowseAppsWnd.SelectedAppNode~=nil) then
		Map3DSystem.App.EditApps.BrowseAppsWnd.SelectedAppNode.NodeHeight = nil;
		Map3DSystem.App.EditApps.BrowseAppsWnd.SelectedAppNode.Selected = nil;
	end
	treeNode.NodeHeight = 100;
	treeNode.Selected = true;
	Map3DSystem.App.EditApps.BrowseAppsWnd.SelectedAppNode = treeNode;
	
	-- update view
	treeNode.TreeView:Update(nil, treeNode);
end

-- owner draw function to treeViewEditAppList
function Map3DSystem.App.EditApps.BrowseAppsWnd.DrawAppNodeHandler(_parent, treeNode)
	if(_parent == nil or treeNode == nil) then
		return
	end
	local _this;
	local left = 2; -- indentation of this node. 
	local top = 2;
	local height = treeNode:GetHeight();
	local nodeWidth = treeNode.TreeView.ClientWidth;
	
	if(treeNode.TreeView.ShowIcon) then
		local IconSize = treeNode.TreeView.DefaultIconSize;
		if(treeNode.Icon~=nil and IconSize>0) then
			_this=ParaUI.CreateUIObject("button","b","_lt", left, top , IconSize, IconSize);
			_this.background = treeNode.Icon;
			_guihelper.SetUIColor(_this, "255 255 255");
			_parent:AddChild(_this);
		end	
		left = left + IconSize;
	end	
	if(treeNode.TreeView.RootNode:GetHeight() > 0) then
		left = left + treeNode.TreeView.DefaultIndentation*treeNode.Level + 2;
	else
		left = left + treeNode.TreeView.DefaultIndentation*(treeNode.Level-1) + 2;
	end	
	
	if(treeNode.type == "group") then
		-- render my map group treeNode: a colored name and an expand arrow
		width = 24 -- check box width
		
		_this=ParaUI.CreateUIObject("button","b","_lt", left, top , width, width);
		_this.onclick = string.format(";CommonCtrl.TreeView.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
		_parent:AddChild(_this);
		left = left + width + 2;
		
		if(treeNode.Expanded) then
			_this.background = "Texture/3DMapSystem/common/itemopen.png";
		else
			_this.background = "Texture/3DMapSystem/common/itemclosed.png";
		end
		
		_this=ParaUI.CreateUIObject("text", "b", "_lt", left, 5, nodeWidth - left-1, height);
		_parent:AddChild(_this);
		_this:GetFont("text").format=36; -- single line and vertical align
		
		_this.text = treeNode.Text;
		
	elseif(treeNode.type == "app") then
		-- render an application treeNode
		if(not treeNode.Selected) then
			_parent.background = "";
			_this=ParaUI.CreateUIObject("button","b","_fi", left, 2 , 75, 2);
			_parent:AddChild(_this);
			_this.background = "";
			_guihelper.SetVistaStyleButton(_this, nil, "Texture/alphadot.png");
			_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
			_this.text = treeNode.Text;
			_this.onclick = string.format(";CommonCtrl.TreeView.OnClickNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			
			local app = Map3DSystem.App.AppManager.GetApp(treeNode.app.app_key);
			if(app~=nil) then
				_this = ParaUI.CreateUIObject("text", "label5", "_rt", -72, 5, 72, 16)
				_parent:AddChild(_this);
					
				if(app.UserAdded) then
					_this.text = "已加载";
				else
					_this.text = "已安装";
				end
			else
				_this = ParaUI.CreateUIObject("button", "b", "_rt", -22, 3, 16, 16)
				_this.background= "Texture/3DMapSystem/IntroPage/downflow.png";
				_this.enabled = false;
				_guihelper.SetUIColor(_this, "255 255 255 255"); 
				_parent:AddChild(_this);
					
				_this = ParaUI.CreateUIObject("text", "label5", "_rt", -72, 5, 72, 16)
				_parent:AddChild(_this);
				_this.text = "没安装";
				_this:GetFont("text").color = "100 0 0";
			end
		else
			_parent.background = "Texture/alphadot.png";
			
			_this=ParaUI.CreateUIObject("text","b","_lt", left, 3 , 200, 22);
			_parent:AddChild(_this);
			_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
			_this.text = treeNode.Text;
		
		
			_this = ParaUI.CreateUIObject("button", "button2", "_rb", -86, -60, 75, 23)
			_this.text = "官网";
			_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/btn_bg_highlight.png: 4 4 4 4";
			_parent:AddChild(_this);

			local app = Map3DSystem.App.AppManager.GetApp(treeNode.app.app_key);
			if(app~=nil) then
				_this = ParaUI.CreateUIObject("text", "label5", "_rt", -72, 5, 72, 16)
				_parent:AddChild(_this);
					
				if(app.UserAdded) then
					_this.text = "已加载";
				else
					_this.text = "已安装";
				end
			else
				_this = ParaUI.CreateUIObject("button", "button4", "_rt", -86, 5, 75, 23)
				_this.text = "安装";
				_this.onclick = string.format(";Map3DSystem.App.EditApps.BrowseAppsWnd.OnClickInstallApp(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
				_parent:AddChild(_this);
			end
			
			if(treeNode.app.about~=nil) then
				-- the full about text of the program
				_this = ParaUI.CreateUIObject("text", "about", "_lt", left, 38, nodeWidth-left-90, 16)
				_this.text = treeNode.app.about;
				_parent:AddChild(_this);
			end

		end
	end
end

function Map3DSystem.App.EditApps.BrowseAppsWnd.OnClickInstallApp(sCtrlName, nodePath)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting IDE's TreeView instance "..sCtrlName.."\r\n");
		return;
	end
	local treeNode = self:GetNodeByPath(nodePath);
	if(treeNode ~= nil) then
		if(Map3DSystem.App.Registration.GetApp(treeNode.app.app_key)~=nil) then
			_guihelper.MessageBox("您已经安装了此程序, 若需要重新安装, 请先卸载");
			return
		end
		local IP_filepath = treeNode.app.IP;
		if(not ParaIO.DoesFileExist(IP_filepath, true)) then
			_guihelper.MessageBox("您需要先到应用程序官网下载程序后，才能安装。请点击官网。");
			return
		end
		-- install the application
		local app = Map3DSystem.App.Registration.InstallApp(treeNode.app, IP_filepath);
		if(app ~= nil ) then
			_guihelper.MessageBox(string.format("应用程序<%s>安装成功, 并已经成功加载。请注意有些应用程序需要您重新启动社区才能正常工作。", treeNode.app.name));
		else
			_guihelper.MessageBox(string.format("应用程序<%s>在安装或加载时出现了错误。请注意有些应用程序需要您重新启动社区才能正常工作。", treeNode.app.name));
		end
		-- Update current window
		treeNode.TreeView:Update(nil, treeNode);
		--Map3DSystem.App.EditApps.BrowseAppsWnd.parentWindow.app:SendMessage({type = CommonCtrl.os.MSGTYPE.WM_CLOSE, wndName = "BrowseAppsWnd"});
	end
end

function Map3DSystem.App.EditApps.BrowseAppsWnd.MSGProc(window, msg)
	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		window:DestroyWindowFrame(false);
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		-- update control 
		local ctl = CommonCtrl.GetControl("treeViewBrowseAppList");
		if(ctl~=nil) then
			ctl:Update();
		end	
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		
	end
end