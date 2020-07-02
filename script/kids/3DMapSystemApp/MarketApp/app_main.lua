--[[
Title: MarketApp app for Paraworld
Author(s): Leio , original template by LiXizhi
Date: 2008/1/14
Desc: 
replace "Map3DSystem.App" with whatever your name
db registration insert script
INSERT INTO apps VALUES (NULL, 'MarketApp_GUID', 'MarketApp', '1.0.0', 'http://www.paraengine.com/apps/MarketApp_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemApp/MarketApp/IP.xml', '', 'script/kids/3DMapSystemApp/MarketApp/app_main.lua', 'Map3DSystem.App.MarketApp.MSGProc', 1);
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/MarketApp/app_main.lua");
------------------------------------------------------------
]]

-- requires

-- create class
commonlib.setfield("Map3DSystem.App.MarketApp", {});

-------------------------------------------
-- event handlers
-------------------------------------------

-- OnConnection method is the obvious point to place your UI (menus, mainbars, tool buttons) through which the user will communicate to the app. 
-- This method is also the place to put your validation code if you are licensing the add-in. You would normally do this before putting up the UI. 
-- If the user is not a valid user, you would not want to put the UI into the IDE.
-- @param app: the object representing the current application in the IDE. 
-- @param connectMode: type of Map3DSystem.App.ConnectMode. 
function Map3DSystem.App.MarketApp.OnConnection(app, connectMode)
	if(connectMode == Map3DSystem.App.ConnectMode.UI_Setup) then
		-- TODO: place your UI (menus,toolbars, tool buttons) through which the user will communicate to the app
		-- e.g. MainBar.AddItem(), MainMenu.AddItem().
		
		-- e.g. Create a MarketApp command link in the main menu 
		local commandName = "Profile.MarketApp";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "商城", icon = app.icon, });
			-- add command to mainmenu control, using the same folder as commandName. But you can use any folder you like
			local pos_category = commandName;
			-- insert after File.group2.
			local index = Map3DSystem.App.Command.GetPosIndex("mainmenu", "Profile.Group1");
			if(index ~= nil) then
				index = index+1;
			end
			command:AddControl("mainmenu", pos_category, index);
		end
			
	else
		-- TODO: place the app's one time initialization code here.
		-- during one time init, its message handler may need to update the app structure with static integration points, 
		-- i.e. app.about, HomeButtonText, HomeButtonText, HasNavigation, NavigationButtonText, HasQuickAction, QuickActionText,  See app template for more information.
		
		-- e.g. 
		
		Map3DSystem.App.MarketApp.app = app; -- keep a reference 
		app.HideHomeButton = true;
		app.HomeButtonText = "商城";
		app.about =  "Market Place service application"
	end
end

-- Receives notification that the Add-in is being unloaded.
function Map3DSystem.App.MarketApp.OnDisconnection(app, disconnectMode)
	if(disconnectMode == Map3DSystem.App.DisconnectMode.UserClosed or disconnectMode == Map3DSystem.App.DisconnectMode.WorldClosed)then
		-- TODO: remove all UI elements related to this application, since the IDE is still running. 
		
		-- e.g. remove command from mainbar
		local command = Map3DSystem.App.Commands.GetCommand("Profile.MarketApp");
		if(command == nil) then
			command:Delete();
		end
	end
	-- TODO: just release any resources at shutting down. 
end

-- This is called when the command's availability is updated
-- When the user clicks a command (menu or mainbar button), the QueryStatus event is fired. 
-- The QueryStatus event returns the current status of the specified named command, whether it is enabled, disabled, 
-- or hidden in the CommandStatus parameter, which is passed to the msg by reference (or returned in the event handler). 
-- @param commandName: The name of the command to determine state for. Usually in the string format "Category.SubCate.Name".
-- @param statusWanted: what status of the command is queried. it is of type Map3DSystem.App.CommandStatusWanted
-- @return: returns according to statusWanted. it may return an integer by adding values in Map3DSystem.App.CommandStatus.
function Map3DSystem.App.MarketApp.OnQueryStatus(app, commandName, statusWanted)
	if(statusWanted == Map3DSystem.App.CommandStatusWanted) then
		-- TODO: return an integer by adding values in Map3DSystem.App.CommandStatus.
		if(commandName == "Profile.MarketApp") then
			-- return enabled and supported 
			return (Map3DSystem.App.CommandStatus.Enabled + Map3DSystem.App.CommandStatus.Supported)
		end
	end
end

-- This is called when the command is invoked.The Exec is fired after the QueryStatus event is fired, assuming that the return to the statusOption parameter of QueryStatus is supported and enabled. 
-- This is the event where you place the actual code for handling the response to the user click on the command.
-- @param commandName: The name of the command to determine state for. Usually in the string format "Category.SubCate.Name".
function Map3DSystem.App.MarketApp.OnExec(app, commandName, params)
	if(commandName == "Profile.MarketApp") then
		-- TODO: actual code of processing the command goes here. 
		-- e.g.
		NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
		
		local _app = app._app;
		local _wnd = app._wnd;
		
		local _appName, _wndName, _document, _frame;
		_frame = Map3DSystem.UI.Windows.GetWindowFrame(_wnd.app.name, _wnd.name);
		if(_frame) then
			_appName = _frame.wnd.app.name;
			_wndName = _frame.wnd.name;
			_document = ParaUI.GetUIObject(_appName.."_".._wndName.."_window_document");
		else
			local param = {
				wnd = _wnd,
				--isUseUI = true,
				mainBarIconSetID = 17, -- or nil
				icon = "Texture/3DMapSystem/MainBarIcon/Modify.png",
				iconSize = 48,
				text = "商城（全部应用程序）",
				style = Map3DSystem.UI.Windows.Style[1],
				maximumSizeX = 800,
				maximumSizeY = 650,
				minimumSizeX = 700,
				minimumSizeY = 500,
				isShowIcon = true,
				--opacity = 100, -- [0, 100]
				isShowMaximizeBox = false,
				isShowMinimizeBox = false,
				isShowAutoHideBox = false,
				allowDrag = true,
				allowResize = true,
				initialPosX = 150,
				initialPosY = 100,
				initialWidth = 700,
				initialHeight = 500,
				
				ShowUICallback = Map3DSystem.App.MarketApp.Show,
				
			};
			_appName, _wndName, _document, _frame = Map3DSystem.UI.Windows.RegisterWindowFrame(param);
		end
		Map3DSystem.UI.Windows.ShowWindow(true, _appName, _wndName);
		
	elseif(app:IsHomepageCommand(commandName)) then
		Map3DSystem.App.MarketApp.GotoHomepage();
	elseif(app:IsNavigationCommand(commandName)) then
		Map3DSystem.App.MarketApp.Navigate();
	elseif(app:IsQuickActionCommand(commandName)) then	
		Map3DSystem.App.MarketApp.DoQuickAction();
	end
end

-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
function Map3DSystem.App.MarketApp.OnRenderBox(mcmlData)
end


-- called when the user wants to nagivate to the 3D world location relavent to this application
function Map3DSystem.App.MarketApp.Navigate()
end

-- called when user clicks to check out the homepage of this application. Homepage usually includes:
-- developer info, support, developer worlds information, app global news, app updates, all community user rating, active users, trade, currency transfer, etc. 
function Map3DSystem.App.MarketApp.GotoHomepage()
end

-- called when user clicks the quick action for this application. 
function Map3DSystem.App.MarketApp.DoQuickAction()
end

-------------------------------------------
-- client world database function helpers.
-------------------------------------------

------------------------------------------
-- all related messages
------------------------------------------
-----------------------------------------------------
-- APPS can be invoked in many ways: 
--	Through app Manager 
--	mainbar or menu command or buttons
--	Command Line 
--  3D World installed apps
-----------------------------------------------------
function Map3DSystem.App.MarketApp.MSGProc(window, msg)
	----------------------------------------------------
	-- application plug-in messages here
	----------------------------------------------------
	if(msg.type == Map3DSystem.App.MSGTYPE.APP_CONNECTION) then	
		-- Receives notification that the Add-in is being loaded.
		Map3DSystem.App.MarketApp.OnConnection(msg.app, msg.connectMode);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_DISCONNECTION) then	
		-- Receives notification that the Add-in is being unloaded.
		Map3DSystem.App.MarketApp.OnDisconnection(msg.app, msg.disconnectMode);

	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUERY_STATUS) then
		-- This is called when the command's availability is updated. 
		-- NOTE: this function returns a result. 
		msg.status = Map3DSystem.App.MarketApp.OnQueryStatus(msg.app, msg.commandName, msg.statusWanted);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_EXEC) then
		-- This is called when the command is invoked.
		Map3DSystem.App.MarketApp.OnExec(msg.app, msg.commandName, msg.params);
				
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_RENDER_BOX) then	
		-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
		Map3DSystem.App.MarketApp.OnRenderBox(msg.mcml);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_NAVIGATION) then
		-- Receives notification that the user wants to nagivate to the 3D world location relavent to this application
		Map3DSystem.App.MarketApp.Navigate();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_HOMEPAGE) then
		-- called when user clicks to check out the homepage of this application. 
		Map3DSystem.App.MarketApp.GotoHomepage();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUICK_ACTION) then
		-- called when user clicks the quick action for this application. 
		Map3DSystem.App.MarketApp.DoQuickAction();
	

	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		Map3DSystem.UI.Windows.ShowWindow(false, Map3DSystem.App.MarketApp.app._app.name, msg.wndName);
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		
	end
end


-- destory the control
function Map3DSystem.App.MarketApp.OnDestory()
	ParaUI.Destroy("RoomHostAll_cont");
end


--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
-- @param _parent: parent window inside which the content is displayed. it can be nil.
function Map3DSystem.App.MarketApp.Show(bShow, _parent, parentWindow)
	local _this;
	Map3DSystem.App.RoomHostApp.parentWindow = parentWindow;
	
	_this=ParaUI.GetUIObject("MarketAll_cont");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		
		if(_parent==nil) then
			_this=ParaUI.CreateUIObject("container","MarketAll_cont","_lt",100,50, 700, 500);
			_this:AttachToRoot();
		else
			_this = ParaUI.CreateUIObject("container", "MarketAll_cont", "_fi",0,0,0,0);
			_this.background = ""
			_parent:AddChild(_this);
		end	
		_parent = _this;
		
		-- TODO: 
		_this = ParaUI.CreateUIObject("text", "label2", "_lt", 10, 17, 272, 16)
		_this.text = "TODO: 加入应用程序相关的UI";
		_parent:AddChild(_this);
		
		-- 
		NPL.load("(gl)script/kids/3DMapSystemApp/MarketApp/MarketListCtl.lua");
		local ctl = Map3DSystem.App.MarketListCtl:new{
			name = "MarketAll_MarketListCtl1",
			alignment = "_fi",
			left=0, top=50,
			width = 0,
			height = 0,
			parent = _parent,
		};
		ctl:Show();
	else
		if(not bShow) then
			Map3DSystem.App.RoomHostApp.OnDestory()
		end
	end		
end