--[[
Title: Developers app for Paraworld
Author(s): LiXizhi
Date: 2008/1/31
Desc: 
Developers is an application to create, edit, submit other applications. Application developers can create a new application from several predefined template and submit applications to application directory. 
db registration insert script
INSERT INTO apps VALUES (NULL, 'Developers_GUID', 'Developers', '1.0.0', 'http://www.paraengine.com/apps/Developers_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemApp/Developers/IP.xml', '', 'script/kids/3DMapSystemApp/Developers/app_main.lua', 'Map3DSystem.App.Developers.MSGProc', 1);

---++ Help.GenerateNPLWikiDoc
generate wiki doc from all npl source code to script/doc folder. 
<verbatim>
	Map3DSystem.App.Commands.Call("Help.GenerateNPLWikiDoc");
</verbatim>

---++ Help.GenerateNPLWikiDoc
generate wiki doc from all npl source code to script/doc folder. 
<verbatim>
	Map3DSystem.App.Commands.Call("Help.GenerateNPLWikiDoc");
</verbatim>

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/Developers/app_main.lua");
------------------------------------------------------------
]]

-- requires

-- create class
commonlib.setfield("Map3DSystem.App.Developers", {});

-------------------------------------------
-- event handlers
-------------------------------------------

-- OnConnection method is the obvious point to place your UI (menus, mainbars, tool buttons) through which the user will communicate to the app. 
-- This method is also the place to put your validation code if you are licensing the add-in. You would normally do this before putting up the UI. 
-- If the user is not a valid user, you would not want to put the UI into the IDE.
-- @param app: the object representing the current application in the IDE. 
-- @param connectMode: type of Map3DSystem.App.ConnectMode. 
function Map3DSystem.App.Developers.OnConnection(app, connectMode)
	
	if(connectMode == Map3DSystem.App.ConnectMode.UI_Setup) then
		
		-- e.g. Create a EditApps command link in the main menu 
		local commandName = "Profile.Developers";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "新建向导", icon = "Texture/3DMapSystem/common/plugin_add.png", });
			
			commandName = "Help.GenerateNPLWikiDoc";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "生成NPL文档", icon = "Texture/3DMapSystem/common/printer.png", });
			-- add command to mainmenu control, using the same folder as commandName. But you can use any folder you like
			local pos_category = commandName;
			command:AddControl("mainmenu", pos_category);
			
			commandName = "File.TranslateFile";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "翻译文件", icon = "Texture/3DMapSystem/common/comment_edit.png", });
				
			commandName = "File.ArtTools";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "美术开发工具集", icon = "Texture/3DMapSystem/AppIcons/Inventory_64.dds", });	
				
			commandName = "File.ProTools";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "程序开发工具集", icon = "Texture/3DMapSystem/AppIcons/Settings_64.dds", });		
		end
	else
		-- TODO: place the app's one time initialization code here.
		-- during one time init, its message handler may need to update the app structure with static integration points, 
		-- i.e. app.about, HomeButtonText, HomeButtonText, HasNavigation, NavigationButtonText, HasQuickAction, QuickActionText,  See app template for more information.
		
		-- e.g. 
		app.about =  "developers"
		app.HideHomeButton = true;
		Map3DSystem.App.Developers.app = app; 
		app.Title = "帕拉巫开发";
		app.icon = "Texture/3DMapSystem/AppIcons/Debug_64.dds"
		app.SubTitle = "PEDN 开发网与工具箱";
		app:SetHelpPage("WelcomePage.html");
		--------------------------------------------
		-- add a desktop icon. 
		-- e.g. Create a Painter command 
	end
end

-- Receives notification that the Add-in is being unloaded.
function Map3DSystem.App.Developers.OnDisconnection(app, disconnectMode)
	if(disconnectMode == Map3DSystem.App.DisconnectMode.UserClosed or disconnectMode == Map3DSystem.App.DisconnectMode.WorldClosed)then
		-- TODO: remove all UI elements related to this application, since the IDE is still running. 
		
		-- e.g. remove command from mainbar
		local command = Map3DSystem.App.Commands.GetCommand("Profile.Developers");
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
function Map3DSystem.App.Developers.OnQueryStatus(app, commandName, statusWanted)
	if(statusWanted == Map3DSystem.App.CommandStatusWanted) then
		-- TODO: return an integer by adding values in Map3DSystem.App.CommandStatus.
		return (Map3DSystem.App.CommandStatus.Enabled + Map3DSystem.App.CommandStatus.Supported)
	end
end

-- This is called when the command is invoked.The Exec is fired after the QueryStatus event is fired, assuming that the return to the statusOption parameter of QueryStatus is supported and enabled. 
-- This is the event where you place the actual code for handling the response to the user click on the command.
-- @param commandName: The name of the command to determine state for. Usually in the string format "Category.SubCate.Name".
function Map3DSystem.App.Developers.OnExec(app, commandName, params)
	if(commandName == "Profile.Developers") then
		-- TODO: actual code of processing the command goes here. 
		-- e.g.
		NPL.load("(gl)script/kids/3DMapSystemApp/Developers/DevelopersWnd.lua");
		Map3DSystem.App.Developers.ShowWnd(app._app);
	elseif(commandName == "Help.GenerateNPLWikiDoc") then	
		-- generate NPL wiki doc
		NPL.load("(gl)script/ide/UnitTest/unit_test.lua");
		local test = commonlib.UnitTest:new();
		if(test:ParseFile("script/NPL_twiki_doc.lua")) then test:Run(); end
	
	elseif(commandName == "File.TranslateFile") then	
		-- translate files. 
		Map3DSystem.App.Commands.Call("File.MCMLBrowser", {url="script/kids/3DMapSystemApp/Developers/TranslateFilePage.html", name="translate", title="翻译NPL, MCML源文件", DisplayNavBar = false});
	
	elseif(commandName == "File.ProTools") then	
		Map3DSystem.App.Commands.Call("File.MCMLBrowser", {url="script/kids/3DMapSystemApp/Developers/ProToolsPage.html", name="ProTools", title="程序开发工具集", DisplayNavBar = false});
	elseif(commandName == "File.ArtTools") then	
		Map3DSystem.App.Commands.Call("File.MCMLBrowser", {url="script/kids/3DMapSystemApp/Developers/ArtToolsPage.html", name="ArtTools", title="美术开发工具集", DisplayNavBar = false});
			
	elseif(app:IsHomepageCommand(commandName)) then
		Map3DSystem.App.Developers.GotoHomepage();
	elseif(app:IsNavigationCommand(commandName)) then
		Map3DSystem.App.Developers.Navigate();
	elseif(app:IsQuickActionCommand(commandName)) then	
		Map3DSystem.App.Developers.DoQuickAction();
	end
end

-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
function Map3DSystem.App.Developers.OnRenderBox(mcmlData)
end


-- called when the user wants to nagivate to the 3D world location relavent to this application
function Map3DSystem.App.Developers.Navigate()
end

-- called when user clicks to check out the homepage of this application. Homepage usually includes:
-- developer info, support, developer worlds information, app global news, app updates, all community user rating, active users, trade, currency transfer, etc. 
function Map3DSystem.App.Developers.GotoHomepage()
end

-- called when user clicks the quick action for this application. 
function Map3DSystem.App.Developers.DoQuickAction()
end

-- Add terrain, sky and ocean button to the toolbar. 
function Map3DSystem.App.Developers.OnActivateDesktop()
	Map3DSystem.UI.AppTaskBar.AddCommand("Help.Debug");
	Map3DSystem.UI.AppTaskBar.AddCommand("Help.TestConsole");
	
	Map3DSystem.UI.AppTaskBar.AddCommand("File.Separator");
	Map3DSystem.UI.AppTaskBar.AddCommand("File.ArtTools");
	Map3DSystem.UI.AppTaskBar.AddCommand("File.ProTools");
	
	Map3DSystem.UI.AppTaskBar.AddCommand("File.Separator1");
	Map3DSystem.UI.AppTaskBar.AddCommand("Profile.Developers");
	
	Map3DSystem.App.Commands.Call("File.WelcomePage", {url="script/kids/3DMapSystemApp/Developers/WelcomePage.html"})
end

-- 
function Map3DSystem.App.Developers.OnDeactivateDesktop()
	Map3DSystem.App.Commands.Call("Profile.Inventor.Stop");
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
function Map3DSystem.App.Developers.MSGProc(window, msg)
	----------------------------------------------------
	-- application plug-in messages here
	----------------------------------------------------
	if(msg.type == Map3DSystem.App.MSGTYPE.APP_CONNECTION) then	
		-- Receives notification that the Add-in is being loaded.
		Map3DSystem.App.Developers.OnConnection(msg.app, msg.connectMode);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_DISCONNECTION) then	
		-- Receives notification that the Add-in is being unloaded.
		Map3DSystem.App.Developers.OnDisconnection(msg.app, msg.disconnectMode);

	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUERY_STATUS) then
		-- This is called when the command's availability is updated. 
		-- NOTE: this function returns a result. 
		msg.status = Map3DSystem.App.Developers.OnQueryStatus(msg.app, msg.commandName, msg.statusWanted);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_EXEC) then
		-- This is called when the command is invoked.
		Map3DSystem.App.Developers.OnExec(msg.app, msg.commandName, msg.params);
				
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_RENDER_BOX) then	
		-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
		Map3DSystem.App.Developers.OnRenderBox(msg.mcml);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_NAVIGATION) then
		-- Receives notification that the user wants to nagivate to the 3D world location relavent to this application
		Map3DSystem.App.Developers.Navigate();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_HOMEPAGE) then
		-- called when user clicks to check out the homepage of this application. 
		Map3DSystem.App.Developers.GotoHomepage();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUICK_ACTION) then
		-- called when user clicks the quick action for this application. 
		Map3DSystem.App.Developers.DoQuickAction();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_ACTIVATE_DESKTOP) then
		Map3DSystem.App.Developers.OnActivateDesktop();
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_DEACTIVATE_DESKTOP) then
		Map3DSystem.App.Developers.OnDeactivateDesktop();
	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		
	end
end