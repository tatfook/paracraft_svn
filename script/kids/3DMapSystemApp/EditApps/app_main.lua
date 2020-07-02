--[[
Title: EditApps app for Paraworld
Author(s): LiXizhi
Date: 2008/1/6
Desc: 
---++ Add/remove applications. 
Call following applications. 
   * Map3DSystem.App.Commands.Call("Profile.EditApps")

db registration insert script
INSERT INTO apps VALUES (NULL, 'EditApps_GUID', 'EditApps', '1.0.0', 'http://www.paraengine.com/apps/EditApps_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemApp/EditApps/IP.xml', '', 'script/kids/3DMapSystemApp/EditApps/app_main.lua', 'Map3DSystem.App.EditApps.MSGProc', 1);
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/EditApps/app_main.lua");
------------------------------------------------------------
]]
local L = CommonCtrl.Locale("ParaWorld");

-- requires

-- create class
commonlib.setfield("Map3DSystem.App.EditApps", {});

-------------------------------------------
-- event handlers
-------------------------------------------

-- OnConnection method is the obvious point to place your UI (menus, mainbars, tool buttons) through which the user will communicate to the app. 
-- This method is also the place to put your validation code if you are licensing the add-in. You would normally do this before putting up the UI. 
-- If the user is not a valid user, you would not want to put the UI into the IDE.
-- @param app: the object representing the current application in the IDE. 
-- @param connectMode: type of Map3DSystem.App.ConnectMode. 
function Map3DSystem.App.EditApps.OnConnection(app, connectMode)
	if(connectMode == Map3DSystem.App.ConnectMode.UI_Setup) then
		-- place your UI (menus,toolbars, tool buttons) through which the user will communicate to the app
		-- e.g. MainBar.AddItem(), MainMenu.AddItem().
		
		-- e.g. Create a EditApps command link in the main menu 
		local commandName = "Profile.EditApps";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = L"添加/删除程序", icon = "Texture/3DMapSystem/common/plugin_add.png", });
			-- add command to mainmenu control, using the same folder as commandName. But you can use any folder you like
			local pos_category = commandName;
			
			-- insert after File.group2.
			local index = Map3DSystem.App.Command.GetPosIndex("mainmenu", "Profile.Group2");
			if(index ~= nil) then
				index = index+1;
			end
			command:AddControl("mainmenu", pos_category, index);
		end
			
	else
		-- place the app's one time initialization code here.
		-- during one time init, its message handler may need to update the app structure with static integration points, 
		-- i.e. app.about, HomeButtonText, HomeButtonText, HasNavigation, NavigationButtonText, HasQuickAction, QuickActionText,  See app template for more information.
		Map3DSystem.App.EditApps.app = app; -- keep a reference
		app.HideHomeButton = true;
		app.about =  "Edit applications"
		app.icon = "Texture/3DMapSystem/Desktop/Startup/AddRemoveApp.png";
		
		--------------------------------------------
		-- add a desktop icon. 
		local commandName = "Startup.EditApps";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand({name = commandName,app_key = app.app_key, 
				ButtonText = L"添加/删除程序", icon = "Texture/3DMapSystem/Desktop/Startup/AddRemoveApp.png", OnShowUICallback = function(bShow, _parent, parentWindow)
					NPL.load("(gl)script/kids/3DMapSystemApp/EditApps/BrowseAppsWnd.lua");
					Map3DSystem.App.EditApps.BrowseAppsWnd.Show(bShow, _parent, parentWindow);
				end});
			local pos_category = commandName;	
			command:AddControl("desktop", pos_category, 3);	
		end	
	end
end

-- Receives notification that the Add-in is being unloaded.
function Map3DSystem.App.EditApps.OnDisconnection(app, disconnectMode)
	if(disconnectMode == Map3DSystem.App.DisconnectMode.UserClosed or disconnectMode == Map3DSystem.App.DisconnectMode.WorldClosed)then
	end
end

-- This is called when the command's availability is updated
-- When the user clicks a command (menu or mainbar button), the QueryStatus event is fired. 
-- The QueryStatus event returns the current status of the specified named command, whether it is enabled, disabled, 
-- or hidden in the CommandStatus parameter, which is passed to the msg by reference (or returned in the event handler). 
-- @param commandName: The name of the command to determine state for. Usually in the string format "Category.SubCate.Name".
-- @param statusWanted: what status of the command is queried. it is of type Map3DSystem.App.CommandStatusWanted
-- @return: returns according to statusWanted. it may return an integer by adding values in Map3DSystem.App.CommandStatus.
function Map3DSystem.App.EditApps.OnQueryStatus(app, commandName, statusWanted)
	if(statusWanted == Map3DSystem.App.CommandStatusWanted) then
		-- TODO: return an integer by adding values in Map3DSystem.App.CommandStatus.
		if(commandName == "Profile.EditApps") then
			-- return enabled and supported 
			return (Map3DSystem.App.CommandStatus.Enabled + Map3DSystem.App.CommandStatus.Supported)
		end
	end
end

-- This is called when the command is invoked.The Exec is fired after the QueryStatus event is fired, assuming that the return to the statusOption parameter of QueryStatus is supported and enabled. 
-- This is the event where you place the actual code for handling the response to the user click on the command.
-- @param commandName: The name of the command to determine state for. Usually in the string format "Category.SubCate.Name".
function Map3DSystem.App.EditApps.OnExec(app, commandName, params)
	if(commandName == "Profile.EditApps") then
		-- actual code of processing the command goes here. 
		
		NPL.load("(gl)script/kids/3DMapSystemApp/EditApps/EditAppsWnd.lua");
		Map3DSystem.App.EditApps.ShowEditAppWnd(app._app);
		
	elseif(app:IsHomepageCommand(commandName)) then
		Map3DSystem.App.EditApps.GotoHomepage();
	elseif(app:IsNavigationCommand(commandName)) then
		Map3DSystem.App.EditApps.Navigate();
	elseif(app:IsQuickActionCommand(commandName)) then	
		Map3DSystem.App.EditApps.DoQuickAction();
	end
end

-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
function Map3DSystem.App.EditApps.OnRenderBox(mcmlData)
end


-- called when the user wants to nagivate to the 3D world location relavent to this application
function Map3DSystem.App.EditApps.Navigate()
end

-- called when user clicks to check out the homepage of this application. Homepage usually includes:
-- developer info, support, developer worlds information, app global news, app updates, all community user rating, active users, trade, currency transfer, etc. 
function Map3DSystem.App.EditApps.GotoHomepage()
end

-- called when user clicks the quick action for this application. 
function Map3DSystem.App.EditApps.DoQuickAction()
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
function Map3DSystem.App.EditApps.MSGProc(window, msg)
	----------------------------------------------------
	-- application plug-in messages here
	----------------------------------------------------
	if(msg.type == Map3DSystem.App.MSGTYPE.APP_CONNECTION) then	
		-- Receives notification that the Add-in is being loaded.
		Map3DSystem.App.EditApps.OnConnection(msg.app, msg.connectMode);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_DISCONNECTION) then	
		-- Receives notification that the Add-in is being unloaded.
		Map3DSystem.App.EditApps.OnDisconnection(msg.app, msg.disconnectMode);

	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUERY_STATUS) then
		-- This is called when the command's availability is updated. 
		-- NOTE: this function returns a result. 
		msg.status = Map3DSystem.App.EditApps.OnQueryStatus(msg.app, msg.commandName, msg.statusWanted);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_EXEC) then
		-- This is called when the command is invoked.
		Map3DSystem.App.EditApps.OnExec(msg.app, msg.commandName, msg.params);
				
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_RENDER_BOX) then	
		-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
		Map3DSystem.App.EditApps.OnRenderBox(msg.mcml);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_NAVIGATION) then
		-- Receives notification that the user wants to nagivate to the 3D world location relavent to this application
		Map3DSystem.App.EditApps.Navigate();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_HOMEPAGE) then
		-- called when user clicks to check out the homepage of this application. 
		Map3DSystem.App.EditApps.GotoHomepage();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUICK_ACTION) then
		-- called when user clicks the quick action for this application. 
		Map3DSystem.App.EditApps.DoQuickAction();
	

	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
				
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		
	end
end