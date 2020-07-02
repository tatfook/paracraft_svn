--[[
Title: add/remove/edit privacy settings for all installed applications of a given user
Author(s): LiXizhi
Date: 2008/1/12
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/EditApps/EditAppsWnd.lua");
Map3DSystem.App.EditApps.ShowEditAppWnd(app);
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");

commonlib.setfield("Map3DSystem.App.EditApps.EditAppsWnd", {});

-- the current logged in user's root bag object. of type Map3DSystem.App.EditApps.Bag
Map3DSystem.App.EditApps.UserBag = nil;

-- display the main inventory window for the current user.
function Map3DSystem.App.EditApps.ShowEditAppWnd(_app)
	NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
	local _wnd = _app:FindWindow("EditAppsWnd") or _app:RegisterWindow("EditAppsWnd", nil, Map3DSystem.App.EditApps.EditAppsWnd.MSGProc);
	
	local _wndFrame = _wnd:GetWindowFrame();
	if(not _wndFrame) then
		_wndFrame = _wnd:CreateWindowFrame{
			icon = "Texture/3DMapSystem/common/plugin.png",
			text = "添加/删除程序",
			initialPosX = 150,
			initialPosY = 70,
			initialWidth = 600,
			initialHeight = 500,
			allowDrag = true,
			allowResize = true,
			ShowUICallback =Map3DSystem.App.EditApps.EditAppsWnd.Show,
		};
	end
	_wnd:ShowWindowFrame(true);
end

-- this function is called via mcml pe:custom control. 
function Map3DSystem.App.EditApps.EditAppsWnd.ShowInMCML(params)
	local _this;	
	local _parent = params.parent;
	
	if(_parent==nil) then
		_this=ParaUI.CreateUIObject("container",params.name,"_lt",100,50, 606, 390);
		_this:AttachToRoot();
	else
		_this = ParaUI.CreateUIObject("container", params.name, params.alignment, params.left,params.top,params.width,params.height);
		_this.background = ""
		_parent:AddChild(_this);
	end	
	_parent = _this;
	
	-- wndEditMyApplications
	_this = ParaUI.CreateUIObject("button", "btnBrowseApps", "_rt", -163, 5, 160, 28)
	_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/btn_bg_highlight.png: 4 4 4 4";
	_this.text = "浏览更多程序";
	_this.onclick = ";Map3DSystem.App.EditApps.EditAppsWnd.OnClickBrowseApps()";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", "label1", "_lt", 12, 50, 112, 15)
	_this.text = "当前安装的程序";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", "label3", "_lt", 12, 9, 300, 15)
	_this.text = "点击程序名称, 编辑设置";
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("text", "label2", "_rt", -265, 50, 75, 15)
	_this.text = "排序方式:";
	_parent:AddChild(_this);

	NPL.load("(gl)script/ide/dropdownlistbox.lua");
	local ctl = CommonCtrl.dropdownlistbox:new{
		name = "comboBoxEditAppSortMethod",
		alignment = "_rt",
		left = -163,
		top = 47,
		width = 160,
		height = 23,
		dropdownheight = 106,
		parent = _parent,
		text = "名称",
		AllowUserEdit = false,
		items = {"是否加载", "名称", "大小", "使用频率", "上次使用时间", "", },
	};
	ctl:Show();

	NPL.load("(gl)script/ide/TreeView.lua");
	local ctl = CommonCtrl.TreeView:new{
		name = "treeViewEditAppList",
		alignment = "_fi",
		left = 0,
		top = 76,
		width = 0,
		height = 0,
		parent = _parent,
		container_bg = "Texture/3DMapSystem/common/ThemeLightBlue/container_bg.png: 4 4 4 4",
		DefaultIndentation = 5,
		DefaultNodeHeight = 22,
		DrawNodeHandler = Map3DSystem.App.EditApps.EditAppsWnd.DrawAppNodeHandler,
		onclick = Map3DSystem.App.EditApps.EditAppsWnd.OnClickApp,
	};
	local node = ctl.RootNode;
	
	-- load initial data set. 
	local key, app;
	for key, app in Map3DSystem.App.AppManager.GetNextApp() do
		if(app.icon==nil or app.icon=="") then
			-- display the icon according to whether it is official or third party, if it does not provide one. 
			-- TODO: use standard app icon
			app.icon = "Texture/3DMapSystem/common/title_bar_restore_press.png";
		end
		node:AddChild(CommonCtrl.TreeNode:new({Name = key, Text = app.Title or app.SubTitle or app.name, type = "app", Icon = app.icon, app=app}));
	end
	
	ctl:Show();
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
-- @param _parent: parent window inside which the content is displayed. it can be nil.
function Map3DSystem.App.EditApps.EditAppsWnd.Show(bShow, _parent, parentWindow)
	local _this;
	Map3DSystem.App.EditApps.EditAppsWnd.parentWindow = parentWindow;
	
	_this=ParaUI.GetUIObject("EditApps_cont");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		
		Map3DSystem.App.EditApps.EditAppsWnd.ShowInMCML({
			name = "EditApps_cont",
			alignment = "_fi",
			left = 5,
			top = 0,
			width = 5,
			height = 5,
			parent = _parent,
		});
		
	else
		if(not bShow) then
			Map3DSystem.App.EditApps.EditAppsWnd.OnDestory()
		end
	end	
end

-- destory the control
function Map3DSystem.App.EditApps.EditAppsWnd.OnDestory()
	ParaUI.Destroy("EditApps_cont");
end

-- TODO: sort ctl.RootNode using some compare functions. 
function Map3DSystem.App.EditApps.EditAppsWnd.SortApp()
	
end

function Map3DSystem.App.EditApps.EditAppsWnd.OnClickBrowseApps()
	if(Map3DSystem.App.EditApps.EditAppsWnd.parentWindow) then
		-- close current window
		Map3DSystem.App.EditApps.EditAppsWnd.parentWindow.app:SendMessage({type = CommonCtrl.os.MSGTYPE.WM_CLOSE, wndName = "EditAppsWnd"});
	end		
	-- show browse app window 
	NPL.load("(gl)script/kids/3DMapSystemApp/EditApps/BrowseAppsWnd.lua");
	Map3DSystem.App.EditApps.ShowBrowseAppWnd(Map3DSystem.App.EditApps.EditAppsWnd.parentWindow.app);
end

-- user clicked to edit an application node.
-- @param treeNode: if nil it will deselect the current selection
function Map3DSystem.App.EditApps.EditAppsWnd.OnClickApp(treeNode)
	-- only one node is selected for editing at a time
	if(Map3DSystem.App.EditApps.EditAppsWnd.SelectedAppNode~=nil) then
		Map3DSystem.App.EditApps.EditAppsWnd.SelectedAppNode.NodeHeight = nil;
		Map3DSystem.App.EditApps.EditAppsWnd.SelectedAppNode.Selected = nil;
	end
	if(treeNode~=nil) then
		treeNode.NodeHeight = 144;
		treeNode.Selected = true;
		Map3DSystem.App.EditApps.EditAppsWnd.SelectedAppNode = treeNode;
		
		-- update view
		treeNode.TreeView:Update(nil, treeNode);
	end	
end

-- call this function to deselect a selected node. 
function Map3DSystem.App.EditApps.EditAppsWnd.OnDeselectApp(treeNode)
	if(Map3DSystem.App.EditApps.EditAppsWnd.SelectedAppNode~=nil) then
		Map3DSystem.App.EditApps.EditAppsWnd.SelectedAppNode.NodeHeight = nil;
		Map3DSystem.App.EditApps.EditAppsWnd.SelectedAppNode.Selected = nil;
	end
	if(treeNode~=nil) then
		treeNode.NodeHeight = nil;
		treeNode.Selected = nil;
		-- update view
		treeNode.TreeView:Update();
	end	
end

-- owner draw function to treeViewEditAppList
function Map3DSystem.App.EditApps.EditAppsWnd.DrawAppNodeHandler(_parent, treeNode)
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
			
			-- TODO: maybe we should also prevent removing official applications. 
			if(treeNode.app.UserAdded) then
				_this = ParaUI.CreateUIObject("text", "label5", "_rt", -72, 5, 72, 16)
				_this.text = "已加载";
				_parent:AddChild(_this);
			else
				_this = ParaUI.CreateUIObject("button", "b", "_rt", -22, 3, 16, 16)
				_this.background= "Texture/3DMapSystem/IntroPage/downflow.png";
				_this.enabled = false;
				_guihelper.SetUIColor(_this, "255 255 255 255"); 
				_parent:AddChild(_this);
					
				_this = ParaUI.CreateUIObject("text", "label5", "_rt", -72, 5, 72, 16)
				_parent:AddChild(_this);
				_this.text = "未加载";
				_this:GetFont("text").color = "100 0 0";	
			end	
		else
			_parent.background = "Texture/alphadot.png";
			
			_this=ParaUI.CreateUIObject("text","b","_lt", left, 3 , 200, 22);
			_parent:AddChild(_this);
			_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
			_this.text = treeNode.Text;
		
			-- show the editing panel.
			_this = ParaUI.CreateUIObject("button", "btnUnInstall", "_rb", -86, -31, 75, 23)
			_this.text = "完全删除";
			_this.onclick = string.format(";Map3DSystem.App.EditApps.EditAppsWnd.OnClickUninstallApp(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());

			-- TODO: do some onclick
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnUpdate", "_rb", -204, -31, 100, 23)
			_this.text = "更新设置";
			-- TODO: do some onclick
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnOfficialSite", "_rb", -86, -78, 75, 23)
			_this.text = "首页";
			_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/btn_bg_highlight.png: 4 4 4 4";
			-- TODO: open official site at app.url
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("text", "label4", "_rt", -195, 40, 184, 16)
			_this.text = "上次使用时间: 2008.1.7";
			-- TODO: use timing
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "AddRemove", "_rt", -86, 10, 75, 23)
			_parent:AddChild(_this);
			_this.onclick = string.format(";Map3DSystem.App.EditApps.EditAppsWnd.OnClickAddRemoveApp(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			if(treeNode.app.UserAdded) then
				_this.text = "卸载";
			else
				_this.text = "加载";
			end	

			NPL.load("(gl)script/ide/CheckBox.lua");
			local ctl = CommonCtrl.checkbox:new{
				name = "checkBoxAppSettingEmail",
				alignment = "_lt",
				left = 19,
				top = 40,
				width = 243,
				height = 20,
				parent = _parent,
				isChecked = not treeNode.app.DenyEmail,
				text = "允许程序发送Email到我的邮箱",
			};
			ctl:Show();

			NPL.load("(gl)script/ide/CheckBox.lua");
			local ctl = CommonCtrl.checkbox:new{
				name = "checkBoxAppSettingGuestView",
				alignment = "_lt",
				left = 19,
				top = 66,
				width = 187,
				height = 20,
				parent = _parent,
				isChecked = not treeNode.app.DenyGuest,
				text = "允许陌生人查看此程序",
			};
			ctl:Show();

			NPL.load("(gl)script/ide/CheckBox.lua");
			local ctl = CommonCtrl.checkbox:new{
				name = "checkBoxAppSettingFeed",
				alignment = "_lt",
				left = 19,
				top = 92,
				width = 187,
				height = 20,
				parent = _parent,
				isChecked = not treeNode.app.DenyActionFeed,
				text = "允许程序发送行为博客",
			};
			ctl:Show();

			NPL.load("(gl)script/ide/CheckBox.lua");
			local ctl = CommonCtrl.checkbox:new{
				name = "checkBoxAppSettingHomeButton",
				alignment = "_lt",
				left = 19,
				top = 116,
				width = 251,
				height = 20,
				parent = _parent,
				isChecked = not treeNode.app.HideHomeButton and not treeNode.app.DenyHomeButton,
				text = "允许程序图标显示在我的首页上",
			};
			ctl:Show();
		end
	end
end

-- uninstall permanently
function Map3DSystem.App.EditApps.EditAppsWnd.OnClickUninstallApp(sCtrlName, nodePath)

	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting IDE's TreeView instance "..sCtrlName.."\r\n");
		return;
	end
	local treeNode = self:GetNodeByPath(nodePath);
	if(treeNode ~= nil) then
		_guihelper.MessageBox(string.format("您确定要完全删除应用程序<%s>么? 建议您仅仅卸载此程序, 一旦删除将不可逆转。\n", treeNode.app.name), function()
			-- uninstall the application
			if (Map3DSystem.App.Registration.UninstallApp(treeNode.app.app_key)) then
				_guihelper.MessageBox(string.format("应用程序<%s>已经删除。您的更改在重新启动社区后才有效。", treeNode.app.name));
				-- update list. 
				treeNode:Detach();
				treeNode.TreeView:Update();
				-- close current window
				--Map3DSystem.App.EditApps.EditAppsWnd.parentWindow.app:SendMessage({type = CommonCtrl.os.MSGTYPE.WM_CLOSE, wndName = "EditAppsWnd"});
			else
				_guihelper.MessageBox(string.format("应用程序<%s>无法删除。此程序为系统程序不可删除。", treeNode.app.name));
			end
		end);
	end
end

-- add or remove on startup.  
function Map3DSystem.App.EditApps.EditAppsWnd.OnClickAddRemoveApp(sCtrlName, nodePath)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting IDE's TreeView instance "..sCtrlName.."\r\n");
		return;
	end
	local treeNode = self:GetNodeByPath(nodePath);
	if(treeNode ~= nil) then
		-- add or remove the application
		if(treeNode.app.UserAdded) then
			-- remove app
			_guihelper.MessageBox(string.format("您确定要卸载应用程序<%s>么? 卸载后您可以回到这里随时加载。\n", treeNode.app.name), function()
				if(Map3DSystem.App.Registration.AddRemoveAppOnStartup(treeNode.app.app_key, false)) then
					_guihelper.MessageBox(string.format("应用程序<%s>已经卸载。您的更改在重新启动社区后才有效。", treeNode.app.name));
					-- update list. 
					treeNode.app.UserAdded = false;
					Map3DSystem.App.EditApps.EditAppsWnd.OnDeselectApp(treeNode);
					-- close current window
					-- Map3DSystem.App.EditApps.EditAppsWnd.parentWindow.app:SendMessage({type = CommonCtrl.os.MSGTYPE.WM_CLOSE, wndName = "EditAppsWnd"});
				else
					_guihelper.MessageBox(string.format("应用程序<%s>无法卸载。此程序为系统程序不可卸载。", treeNode.app.name));
				end
			end);	
		else
			-- add app
			_guihelper.MessageBox(string.format("您确定要加载应用程序<%s>么? \n", treeNode.app.name), function()
				if(Map3DSystem.App.Registration.AddRemoveAppOnStartup(treeNode.app.app_key, true)) then
					_guihelper.MessageBox(string.format("应用程序<%s>已经加载。您的更改在重新启动社区后才有效。", treeNode.app.name));
					-- update list. 
					treeNode.app.UserAdded = true;
					Map3DSystem.App.EditApps.EditAppsWnd.OnDeselectApp(treeNode);
					-- close current window
					--Map3DSystem.App.EditApps.EditAppsWnd.parentWindow.app:SendMessage({type = CommonCtrl.os.MSGTYPE.WM_CLOSE, wndName = "EditAppsWnd"});
				else
					_guihelper.MessageBox(string.format("应用程序<%s>无法加载。", treeNode.app.name));
				end
			end);	
		end	
	end
end

function Map3DSystem.App.EditApps.EditAppsWnd.MSGProc(window, msg)
	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		window:DestroyWindowFrame(false);
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		-- update control 
		local ctl = CommonCtrl.GetControl("treeViewEditAppList");
		if(ctl~=nil) then
			ctl:Update();
		end	
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		
	end
end