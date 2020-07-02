--[[
Title: Login App for Paraworld. Provides different styles of login windows for apps. Login app can be used by any other official 
or third party apps in case they want to authenticate the user either from the official site or their own website. 
Author(s): LiXizhi
Date: 2008/1/24
Desc: 
db registration insert script
INSERT INTO apps VALUES (NULL, 'Login_GUID', 'Login', '1.0.0', 'http://www.paraengine.com/apps/Login_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemApp/Login/IP.xml', '', 'script/kids/3DMapSystemApp/Login/app_main.lua', 'Map3DSystem.App.Login.MSGProc', 1);
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/Login/app_main.lua");
------------------------------------------------------------
]]
local L = CommonCtrl.Locale("ParaWorld");

-- requires
-- create class
commonlib.setfield("Map3DSystem.App.Login", {});

-------------------------------------------
-- event handlers
-------------------------------------------

-- OnConnection method is the obvious point to place your UI (menus, mainbars, tool buttons) through which the user will communicate to the app. 
-- This method is also the place to put your validation code if you are licensing the add-in. You would normally do this before putting up the UI. 
-- If the user is not a valid user, you would not want to put the UI into the IDE.
-- @param app: the object representing the current application in the IDE. 
-- @param connectMode: type of Map3DSystem.App.ConnectMode. 
function Map3DSystem.App.Login.OnConnection(app, connectMode)
	if(connectMode == Map3DSystem.App.ConnectMode.UI_Setup) then
		-- TODO: place your UI (menus,toolbars, tool buttons) through which the user will communicate to the app
		-- e.g. MainBar.AddItem(), MainMenu.AddItem().
		
	else
		-- TODO: place the app's one time initialization code here.
		-- during one time init, its message handler may need to update the app structure with static integration points, 
		-- i.e. app.about, HomeButtonText, HomeButtonText, HasNavigation, NavigationButtonText, HasQuickAction, QuickActionText,  See app template for more information.
		
		-- e.g. 
		app.about =  L"登陆 -- 帕拉巫"
		Map3DSystem.App.Login.app = app; 
		app.HideHomeButton = true;
		-- set the setting page using relative path.
		app:SetSettingPage("setting.html", L"制定桌面首页");
		
		--------------------------------------------
		-- add a desktop icon. 
		local commandName = "Startup.ParaworldStartPage";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
		
			-- show the front page url
			local url = ParaEngine.GetAppCommandLineByParam("startpage", Map3DSystem.App.Login.app:ReadConfig("StartPageMCML", "script/kids/3DMapSystemApp/Login/StartPage.html"))
			command = Map3DSystem.App.Commands.AddNamedCommand({name = commandName,app_key = app.app_key, 
				ButtonText = L"首页", icon = "Texture/3DMapSystem/Desktop/Startup/CG.png", url=url});
			command:AddControl("desktop", commandName, 1);	
		
			commandName = "Startup.Tutorials";
			command = Map3DSystem.App.Commands.AddNamedCommand({name = commandName,app_key = app.app_key, 
				ButtonText = L"教程", icon = "Texture/3DMapSystem/AppIcons/Intro_64.dds", url="script/kids/3DMapSystemApp/Login/TutorialPage.html?tab=offline"});
			local pos_category = commandName;	
			command:AddControl("desktop", pos_category, 2);	
			
			commandName = "Startup.Credits";
			command = Map3DSystem.App.Commands.AddNamedCommand({name = commandName,app_key = app.app_key, 
				ButtonText = L"制作群", icon = "Texture/3DMapSystem/Desktop/Startup/credits.png", url="script/kids/3DMapSystemApp/Login/CreditsPage.html"});
			local pos_category = commandName;	
			command:AddControl("desktop", pos_category, 6);	
			
			commandName = "Startup.ParaworldWebSite";
			command = Map3DSystem.App.Commands.AddNamedCommand({name = commandName,app_key = app.app_key, 
				ButtonText = L"官网", icon = "Texture/3DMapSystem/Desktop/Startup/OfficalWeb.png", url="script/kids/3DMapSystemApp/Login/OfficialWebPage.html"});
			local pos_category = commandName;	
			command:AddControl("desktop", pos_category, 7);	
			
			--commandName = "Startup.CGPage";	
			--command = Map3DSystem.App.Commands.AddNamedCommand({name = commandName,app_key = app.app_key, 
				--ButtonText = "CG动画", icon = app.icon, OnShowUICallback = function(bShow, _parent, parentWindow)
					--NPL.load("(gl)script/kids/3DMapSystemApp/Login/CGPage.lua");
					--Map3DSystem.App.Login.CGPage.Show(bShow, _parent, parentWindow)
				--end});
			--command:AddControl("desktop", commandName,10);	
			
			-- for Online Panel
			commandName = "Online.HomePage";
			NPL.load("(gl)script/ide/System/localserver/UrlHelper.lua");
			command = Map3DSystem.App.Commands.AddNamedCommand({name = commandName,app_key = app.app_key, 
				ButtonText = L"我的首页", icon = "Texture/3DMapSystem/AppIcons/homepage_64.dds",  
				url=System.localserver.UrlHelper.BuildURLQuery("script/kids/3DMapSystemUI/Settings/WelcomePage.html", {url="script/kids/3DMapSystemApp/Login/TutorialPage.html", redirect="script/kids/3DMapSystemApp/Login/FrontPageV1.html", autoredirect="true", }),
				--url="script/kids/3DMapSystemApp/Login/StartPage.html",
			});
			command:AddControl("desktop", commandName, 1);	
			
			commandName = "Online.ProfileReg";
			command = Map3DSystem.App.Commands.AddNamedCommand({name = commandName,app_key = app.app_key, 
				ButtonText = L"个人档案", icon = "Texture/3DMapSystem/AppIcons/Profiles_64.dds", url="script/kids/3DMapSystemApp/profiles/ProfileRegPage.html"});
			command:AddControl("desktop", commandName, 2);	
			
			-- for offline panel
			commandName = "Offline.ProfileReg";
			command = Map3DSystem.App.Commands.AddNamedCommand({name = commandName,app_key = app.app_key, 
				ButtonText = L"教程", icon = "Texture/3DMapSystem/AppIcons/Intro_64.dds", url="script/kids/3DMapSystemApp/Login/TutorialPage.html?tab=offline"});
			command:AddControl("desktop", commandName, 1);	
			
			--
			-- common commands
			--
			commandName = "Profile.Login";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = L"登陆", icon = app.icon, });
				
			commandName = "File.Logout";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = L"注销", });	
				
			commandName = "File.Exit";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = L"退出", });	
		end
	end
end

-- Receives notification that the Add-in is being unloaded.
function Map3DSystem.App.Login.OnDisconnection(app, disconnectMode)
	if(disconnectMode == Map3DSystem.App.DisconnectMode.UserClosed or disconnectMode == Map3DSystem.App.DisconnectMode.WorldClosed)then
		-- TODO: remove all UI elements related to this application, since the IDE is still running. 
		
		-- e.g. remove command from mainbar
		local command = Map3DSystem.App.Commands.GetCommand("Profile.Login");
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
function Map3DSystem.App.Login.OnQueryStatus(app, commandName, statusWanted)
	if(statusWanted == Map3DSystem.App.CommandStatusWanted) then
		-- TODO: return an integer by adding values in Map3DSystem.App.CommandStatus.
		-- return enabled and supported 
		return (Map3DSystem.App.CommandStatus.Enabled + Map3DSystem.App.CommandStatus.Supported)
	end
end

-- This is called when the command is invoked.The Exec is fired after the QueryStatus event is fired, assuming that the return to the statusOption parameter of QueryStatus is supported and enabled. 
-- This is the event where you place the actual code for handling the response to the user click on the command.
-- @param commandName: The name of the command to determine state for. Usually in the string format "Category.SubCate.Name".
function Map3DSystem.App.Login.OnExec(app, commandName, params)
	if(commandName == "Profile.Login") then
		local title, cmdredirect;
		if(type(params) == "string") then
			title = params;
		elseif(type(params) == "table")	then
			title = params.title;
			cmdredirect = params.cmdredirect;
		end
		
		-- remove any message box if any. 
		_guihelper.CloseMessageBox()
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url=System.localserver.UrlHelper.BuildURLQuery("script/kids/3DMapSystemApp/Login/LoginPage.html", {cmdredirect=cmdredirect}), 
			name="Login.Wnd", 
			app_key=app.app_key, 
			text = L"登陆窗口",
			isShowTitleBar = true, 
			isShowToolboxBar = false, 
			isShowStatusBar = false, 
			allowResize = false,
			initialPosX = (1020-320)/2,
			initialPosY = 50,
			initialWidth = 320,
			initialHeight = 290,
			zorder=3,
		});
		
	elseif(commandName == "File.Logout") then		
		-- back to main startup
		_guihelper.MessageBox(L"确认要注销, 并返回登陆页么?", function() 
			
			Map3DSystem.reset();
			main_state = nil;
		end);
	elseif(commandName == "File.Exit") then	
		-- exit to windows
		_guihelper.MessageBox(L"确认要退出游戏么?", Map3DSystem.UI.Exit.OnExit);
		
	elseif(app:IsHomepageCommand(commandName)) then
		Map3DSystem.App.Login.GotoHomepage();
	elseif(app:IsNavigationCommand(commandName)) then
		Map3DSystem.App.Login.Navigate();
	elseif(app:IsQuickActionCommand(commandName)) then	
		Map3DSystem.App.Login.DoQuickAction();
	end
end

-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
function Map3DSystem.App.Login.OnRenderBox(mcmlData)
end


-- called when the user wants to nagivate to the 3D world location relavent to this application
function Map3DSystem.App.Login.Navigate()
end

-- called when user clicks to check out the homepage of this application. Homepage usually includes:
-- developer info, support, developer worlds information, app global news, app updates, all community user rating, active users, trade, currency transfer, etc. 
function Map3DSystem.App.Login.GotoHomepage()
	NPL.load("(gl)script/kids/3DMapSystemApp/Login/LoginWnd.lua");
	Map3DSystem.App.Login.ShowLoginWnd(Map3DSystem.App.Login.app._app);
end

-- called when user clicks the quick action for this application. 
function Map3DSystem.App.Login.DoQuickAction()
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
function Map3DSystem.App.Login.MSGProc(window, msg)
	----------------------------------------------------
	-- application plug-in messages here
	----------------------------------------------------
	if(msg.type == Map3DSystem.App.MSGTYPE.APP_CONNECTION) then	
		-- Receives notification that the Add-in is being loaded.
		Map3DSystem.App.Login.OnConnection(msg.app, msg.connectMode);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_DISCONNECTION) then	
		-- Receives notification that the Add-in is being unloaded.
		Map3DSystem.App.Login.OnDisconnection(msg.app, msg.disconnectMode);

	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUERY_STATUS) then
		-- This is called when the command's availability is updated. 
		-- NOTE: this function returns a result. 
		msg.status = Map3DSystem.App.Login.OnQueryStatus(msg.app, msg.commandName, msg.statusWanted);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_EXEC) then
		-- This is called when the command is invoked.
		Map3DSystem.App.Login.OnExec(msg.app, msg.commandName, msg.params);
				
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_RENDER_BOX) then	
		-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
		Map3DSystem.App.Login.OnRenderBox(msg.mcml);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_NAVIGATION) then
		-- Receives notification that the user wants to nagivate to the 3D world location relavent to this application
		Map3DSystem.App.Login.Navigate();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_HOMEPAGE) then
		-- called when user clicks to check out the homepage of this application. 
		Map3DSystem.App.Login.GotoHomepage();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUICK_ACTION) then
		-- called when user clicks the quick action for this application. 
		Map3DSystem.App.Login.DoQuickAction();
	

	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		
	end
end