--[[
Title: HomeZone
Author(s):  
Date: 2009/2/18
Desc: 
 
------------------------------------------------------------
db registration insert script
INSERT INTO apps VALUES (NULL, 'HomeZone_GUID', 'HomeZone', '1.0.0', 'http://www.paraengine.com/apps/HomeZone_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemUI/HomeZone/IP.xml', '', 'script/kids/3DMapSystemUI/HomeZone/app_main.lua', 'Map3DSystem.App.HomeZone.MSGProc', 1);
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/HomeZone/app_main.lua");
------------------------------------------------------------
]]


-- create class
local HomeZone = {};
commonlib.setfield("Map3DSystem.App.HomeZone", HomeZone);
function HomeZone.OnActivateDesktop()
	Map3DSystem.UI.AppTaskBar.AddCommand("Profile.HomeZone.DeleteNode");
	Map3DSystem.UI.AppTaskBar.AddCommand("Profile.HomeZone.Undo");
	Map3DSystem.UI.AppTaskBar.AddCommand("Profile.HomeZone.Redo");
	--Map3DSystem.UI.AppTaskBar.AddCommand("Profile.HomeZone.Load");
	Map3DSystem.UI.AppTaskBar.AddCommand("Profile.HomeZone.Save")
	--Map3DSystem.UI.AppTaskBar.AddCommand("Profile.HomeZone.Away");
	--Map3DSystem.UI.AppTaskBar.AddCommand("Profile.HomeZone.Clear");
	
	--NPL.load("(gl)script/kids/3DMapSystemUI/HomeZone/HomeZoneEditor.lua");
	--Map3DSystem.App.HomeZoneEditor.Start();
	--Map3DSystem.App.HomeZoneEditor.Load();
end
function HomeZone.OnDeactivateDesktop()
	Map3DSystem.App.Commands.Call("Profile.HomeZone.Away");
end
-------------------------------------------
-- event handlers
-------------------------------------------

-- OnConnection method is the obvious point to place your UI (menus, mainbars, tool buttons) through which the user will communicate to the app. 
-- This method is also the place to put your validation code if you are licensing the add-in. You would normally do this before putting up the UI. 
-- If the user is not a valid user, you would not want to put the UI into the IDE.
-- @param app: the object representing the current application in the IDE. 
-- @param connectMode: type of Map3DSystem.App.ConnectMode. 
function Map3DSystem.App.HomeZone.OnConnection(app, connectMode)
	if(connectMode == Map3DSystem.App.ConnectMode.UI_Setup) then
		-- TODO: place your UI (menus,toolbars, tool buttons) through which the user will communicate to the app
		-- e.g. MainBar.AddItem(), MainMenu.AddItem().
		
		-- e.g. Create a HomeZone command link in the main menu 
		local commandName = "Profile.HomeZone";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "房间", icon = "Texture/3DMapSystem/AppIcons/homepage_64.dds", });
		end
		local commandName = "Profile.HomeZone.DeleteNode";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "删除", icon = "Texture/3DMapSystem/common/wrongsign.png", });
		end
		local commandName = "Profile.HomeZone.Undo";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "撤销", icon = "Texture/3DMapSystem/Creator/Objects/undo.png", });
		end
		local commandName = "Profile.HomeZone.Redo";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "重做", icon = "Texture/3DMapSystem/Creator/Objects/redo.png", });
		end
		local commandName = "Profile.HomeZone.Load";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "加载", icon = "Texture/3DMapSystem/common/reset.png", });
		end
		local commandName = "Profile.HomeZone.Save";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "保存", icon = "Texture/3DMapSystem/common/save.png", });
		end
		local commandName = "Profile.HomeZone.Clear";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "删除数据", icon = "Texture/3DMapSystem/common/png-0762.png", });
		end
		local commandName = "Profile.HomeZone.Away";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "离开房间", icon = "Texture/3DMapSystem/Creator/Objects/speed.png", });
		end
	else
		-- TODO: place the app's one time initialization code here.
		-- during one time init, its message handler may need to update the app structure with static integration points, 
		-- i.e. app.about, HomeButtonText, HomeButtonText, HasNavigation, NavigationButtonText, HasQuickAction, QuickActionText,  See app template for more information.
		
		-- e.g. 
		app.about =  "your short scription of the application here using the current language"
		app.icon =  "Texture/3DMapSystem/AppIcons/homepage_64.dds";
		Map3DSystem.App.HomeZone.app = app; -- keep a reference
		if(ParaEngine.GetLocale() == "zhCN") then
			app.HomeButtonText = "HomeZone in Chinese";
		else
			app.HomeButtonText = "HomeZone in English";
		end
	end
end

-- Receives notification that the Add-in is being unloaded.
function Map3DSystem.App.HomeZone.OnDisconnection(app, disconnectMode)
	if(disconnectMode == Map3DSystem.App.DisconnectMode.UserClosed or disconnectMode == Map3DSystem.App.DisconnectMode.WorldClosed)then
		-- TODO: remove all UI elements related to this application, since the IDE is still running. 
		
		-- e.g. remove command from mainbar
		local command = Map3DSystem.App.Commands.GetCommand("Profile.HomeZone");
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
function Map3DSystem.App.HomeZone.OnQueryStatus(app, commandName, statusWanted)
	if(statusWanted == Map3DSystem.App.CommandStatusWanted) then
		-- TODO: return an integer by adding values in Map3DSystem.App.CommandStatus.
		if(commandName == "Profile.HomeZone") then
			-- return enabled and supported 
			return (Map3DSystem.App.CommandStatus.Enabled + Map3DSystem.App.CommandStatus.Supported)
		end
	end
end

-- This is called when the command is invoked.The Exec is fired after the QueryStatus event is fired, assuming that the return to the statusOption parameter of QueryStatus is supported and enabled. 
-- This is the event where you place the actual code for handling the response to the user click on the command.
-- @param commandName: The name of the command to determine state for. Usually in the string format "Category.SubCate.Name".
function Map3DSystem.App.HomeZone.OnExec(app, commandName, params)
	if(commandName == "Profile.HomeZone") then
		
	elseif(commandName == "Profile.HomeZone.DeleteNode") then
		Map3DSystem.App.HomeZoneEditor.Delete();
	elseif(commandName == "Profile.HomeZone.Undo") then
		Map3DSystem.App.HomeZoneEditor.Undo();
	elseif(commandName == "Profile.HomeZone.Redo") then
		Map3DSystem.App.HomeZoneEditor.Redo();
	elseif(commandName == "Profile.HomeZone.Load") then
		Map3DSystem.App.HomeZoneEditor.Load();
	elseif(commandName == "Profile.HomeZone.Save") then
		Map3DSystem.App.HomeZoneEditor.Save();
	elseif(commandName == "Profile.HomeZone.Away") then
		Map3DSystem.App.HomeZoneEditor.End();
	elseif(commandName == "Profile.HomeZone.Clear") then
		Map3DSystem.App.HomeZoneEditor.Clear();
	elseif(app:IsHomepageCommand(commandName)) then
		Map3DSystem.App.HomeZone.GotoHomepage();
	elseif(app:IsNavigationCommand(commandName)) then
		Map3DSystem.App.HomeZone.Navigate();
	elseif(app:IsQuickActionCommand(commandName)) then	
		Map3DSystem.App.HomeZone.DoQuickAction();
	end
end

-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
function Map3DSystem.App.HomeZone.OnRenderBox(mcmlData)
end


-- called when the user wants to nagivate to the 3D world location relavent to this application
function Map3DSystem.App.HomeZone.Navigate()
end

-- called when user clicks to check out the homepage of this application. Homepage usually includes:
-- developer info, support, developer worlds information, app global news, app updates, all community user rating, active users, trade, currency transfer, etc. 
function Map3DSystem.App.HomeZone.GotoHomepage()
end

-- called when user clicks the quick action for this application. 
function Map3DSystem.App.HomeZone.DoQuickAction()
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
function Map3DSystem.App.HomeZone.MSGProc(window, msg)
	----------------------------------------------------
	-- application plug-in messages here
	----------------------------------------------------
	if(msg.type == Map3DSystem.App.MSGTYPE.APP_CONNECTION) then	
		-- Receives notification that the Add-in is being loaded.
		Map3DSystem.App.HomeZone.OnConnection(msg.app, msg.connectMode);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_DISCONNECTION) then	
		-- Receives notification that the Add-in is being unloaded.
		Map3DSystem.App.HomeZone.OnDisconnection(msg.app, msg.disconnectMode);

	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUERY_STATUS) then
		-- This is called when the command's availability is updated. 
		-- NOTE: this function returns a result. 
		msg.status = Map3DSystem.App.HomeZone.OnQueryStatus(msg.app, msg.commandName, msg.statusWanted);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_EXEC) then
		-- This is called when the command is invoked.
		Map3DSystem.App.HomeZone.OnExec(msg.app, msg.commandName, msg.params);
				
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_RENDER_BOX) then	
		-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
		Map3DSystem.App.HomeZone.OnRenderBox(msg.mcml);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_NAVIGATION) then
		-- Receives notification that the user wants to nagivate to the 3D world location relavent to this application
		Map3DSystem.App.HomeZone.Navigate();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_HOMEPAGE) then
		-- called when user clicks to check out the homepage of this application. 
		Map3DSystem.App.HomeZone.GotoHomepage();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUICK_ACTION) then
		-- called when user clicks the quick action for this application. 
		Map3DSystem.App.HomeZone.DoQuickAction();
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_ACTIVATE_DESKTOP) then
		Map3DSystem.App.HomeZone.OnActivateDesktop()
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_DEACTIVATE_DESKTOP) then
		Map3DSystem.App.HomeZone.OnDeactivateDesktop();
		
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_WORLD_CLOSING) then
	
	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		
	end
end
