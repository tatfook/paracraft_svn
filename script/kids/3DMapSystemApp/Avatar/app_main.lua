--[[
Title: Avatar app for Paraworld
Author(s): [your name], original template by LiXizhi
Date: 2008/1/5
Desc: 
replace "Map3DSystem.App" with whatever your name
db registration insert script
INSERT INTO apps VALUES (NULL, 'Avatar_GUID', 'Avatar', '1.0.0', 'http://www.paraengine.com/apps/Avatar_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemApp/Avatar/IP.xml', '', 'script/kids/3DMapSystemApp/Avatar/app_main.lua', 'Map3DSystem.App.Avatar.MSGProc', 1);
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/Avatar/app_main.lua");
------------------------------------------------------------
]]

-- requires

-- create class
commonlib.setfield("Map3DSystem.App.Avatar", {});

-------------------------------------------
-- event handlers
-------------------------------------------

-- OnConnection method is the obvious point to place your UI (menus, mainbars, tool buttons) through which the user will communicate to the app. 
-- This method is also the place to put your validation code if you are licensing the add-in. You would normally do this before putting up the UI. 
-- If the user is not a valid user, you would not want to put the UI into the IDE.
-- @param app: the object representing the current application in the IDE. 
-- @param connectMode: type of Map3DSystem.App.ConnectMode. 
function Map3DSystem.App.Avatar.OnConnection(app, connectMode)
	if(connectMode == Map3DSystem.App.ConnectMode.UI_Setup) then
		-- TODO: place your UI (menus,toolbars, tool buttons) through which the user will communicate to the app
		-- e.g. MainBar.AddItem(), MainMenu.AddItem().
		
		-- e.g. Create a Avatar command link in the main menu 
		local commandName = "Profile.Avatar";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "Avatar Selector Window", Icon = app.icon, });
			-- add command to mainmenu control, using the same folder as commandName. But you can use any folder you like
			local pos_category = commandName;
			-- add to front.
			command:AddControl("mainmenu", pos_category, 1);
		end
			
	else
		-- TODO: place the app's one time initialization code here.
		-- during one time init, its message handler may need to update the app structure with static integration points, 
		-- i.e. app.about, HomeButtonText, HomeButtonText, HasNavigation, NavigationButtonText, HasQuickAction, QuickActionText,  See app template for more information.
		
		-- e.g. 
		
		-- necessary functions needed during the registration page interaction.
		NPL.load("(gl)script/kids/3DMapSystemApp/avatar/RegistrationPage.lua");
		
		app.about =  "your short scription of the application here using the current language"
		if(ParaEngine.GetLocale() == "zhCN") then
			app.HomeButtonText = "Avatar in Chinese";
		else
			app.HomeButtonText = "Avatar in English";
		end
	end
end

-- Receives notification that the Add-in is being unloaded.
function Map3DSystem.App.Avatar.OnDisconnection(app, disconnectMode)
	if(disconnectMode == Map3DSystem.App.DisconnectMode.UserClosed or disconnectMode == Map3DSystem.App.DisconnectMode.WorldClosed)then
		-- TODO: remove all UI elements related to this application, since the IDE is still running. 
		
		-- e.g. remove command from mainbar
		local command = Map3DSystem.App.Commands.GetCommand("Profile.Avatar");
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
function Map3DSystem.App.Avatar.OnQueryStatus(app, commandName, statusWanted)
	if(statusWanted == Map3DSystem.App.CommandStatusWanted) then
		-- TODO: return an integer by adding values in Map3DSystem.App.CommandStatus.
		if(commandName == "Profile.Avatar") then
			-- return enabled and supported 
			return (Map3DSystem.App.CommandStatus.Enabled + Map3DSystem.App.CommandStatus.Supported)
		end
	end
end

-- This is called when the command is invoked.The Exec is fired after the QueryStatus event is fired, assuming that the return to the statusOption parameter of QueryStatus is supported and enabled. 
-- This is the event where you place the actual code for handling the response to the user click on the command.
-- @param commandName: The name of the command to determine state for. Usually in the string format "Category.SubCate.Name".
function Map3DSystem.App.Avatar.OnExec(app, commandName, params)
	if(commandName == "Profile.Avatar") then
		-- TODO: actual code of processing the command goes here. 
		
		-- create and display an avatar selector window for user
		NPL.load("(gl)script/kids/3DMapSystemApp/avatar/AvatarSelectWnd.lua");
		Map3DSystem.App.Avatar.ShowAvatarSelectorWnd();
		
	elseif(app:IsHomepageCommand(commandName)) then
		Map3DSystem.App.Avatar.GotoHomepage();
	elseif(app:IsNavigationCommand(commandName)) then
		Map3DSystem.App.Avatar.Navigate();
	elseif(app:IsQuickActionCommand(commandName)) then	
		Map3DSystem.App.Avatar.DoQuickAction();
	end
end

-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
function Map3DSystem.App.Avatar.OnRenderBox(mcmlData)
end

-- called when the user wants to nagivate to the 3D world location relavent to this application
function Map3DSystem.App.Avatar.Navigate()
end

-- called when user clicks to check out the homepage of this application. Homepage usually includes:
-- developer info, support, developer worlds information, app global news, app updates, all community user rating, active users, trade, currency transfer, etc. 
function Map3DSystem.App.Avatar.GotoHomepage()
end

-- called when user clicks the quick action for this application. 
function Map3DSystem.App.Avatar.DoQuickAction()
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
function Map3DSystem.App.Avatar.MSGProc(window, msg)
	----------------------------------------------------
	-- application plug-in messages here
	----------------------------------------------------
	if(msg.type == Map3DSystem.App.MSGTYPE.APP_CONNECTION) then	
		-- Receives notification that the Add-in is being loaded.
		Map3DSystem.App.Avatar.OnConnection(msg.app, msg.connectMode);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_DISCONNECTION) then	
		-- Receives notification that the Add-in is being unloaded.
		Map3DSystem.App.Avatar.OnDisconnection(msg.app, msg.disconnectMode);

	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUERY_STATUS) then
		-- This is called when the command's availability is updated. 
		-- NOTE: this function returns a result. 
		msg.status = Map3DSystem.App.Avatar.OnQueryStatus(msg.app, msg.commandName, msg.statusWanted);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_EXEC) then
		-- This is called when the command is invoked.
		Map3DSystem.App.Avatar.OnExec(msg.app, msg.commandName, msg.params);
				
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_RENDER_BOX) then	
		-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
		Map3DSystem.App.Avatar.OnRenderBox(msg.mcml);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_NAVIGATION) then
		-- Receives notification that the user wants to nagivate to the 3D world location relavent to this application
		Map3DSystem.App.Avatar.Navigate();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_HOMEPAGE) then
		-- called when user clicks to check out the homepage of this application. 
		Map3DSystem.App.Avatar.GotoHomepage();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUICK_ACTION) then
		-- called when user clicks the quick action for this application. 
		Map3DSystem.App.Avatar.DoQuickAction();
	

	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		
	end
end

-- Check if the user's avatar information is fully filled in the offical user info
--		IsRegistrationComplete function is called automatically by the LoginApp application 
--		according to the sequence: Avatar, MapApp, ProfileApp applications
-- If the information is NOT fully filled, launch the registration page
-- If the information is fully filles, continue with other process
function Map3DSystem.App.Avatar.IsRegistrationComplete()
	local isComplete;
	-- TODO: check if the avatar informaiton is fully filled
	-- getAvatarInfo
	isComplete = false;
	if(isComplete == false) then
		-- launch the avatar select window
		NPL.load("(gl)script/kids/3DMapSystemApp/avatar/AvatarSelectWnd.lua");
		Map3DSystem.App.Avatar.ShowAvatarSelectorWnd();
	else
		-- continue with other process
		return;
	end
end

function Map3DSystem.App.Avatar.EditMyself()
	log("Edit Myself!\n");
	log("TODO: User Interface design conflict: global and miniscene graph owned avatar.\n");
end

Map3DSystem.App.Avatar.DefaultQuestionSign = "character/common/headquest/headquest.x";