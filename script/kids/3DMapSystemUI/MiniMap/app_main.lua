--[[
Title: MiniMap app for Paraworld
Author(s): Andy, port to app by LiXizhi
Date: 2008/1/5
Desc: 
---++ File.MapPosLogPage
show/hide the map position log page. it is a convinient place to remember position in current 3d world. 
<verbatim>
	Map3DSystem.App.Commands.Call("File.MapPosLogPage");
</verbatim>
db registration insert script
INSERT INTO apps VALUES (NULL, 'MiniMap_GUID', 'MiniMap', '1.0.0', 'http://www.paraengine.com/apps/MiniMap_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemUI/MiniMap/IP.xml', '', 'script/kids/3DMapSystemUI/MiniMap/app_main.lua', 'Map3DSystem.App.MiniMap.MSGProc', 1);
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MiniMap/app_main.lua");
------------------------------------------------------------
]]

-- requires

-- create class
commonlib.setfield("Map3DSystem.App.MiniMap", {});

-------------------------------------------
-- event handlers
-------------------------------------------

-- OnConnection method is the obvious point to place your UI (menus, mainbars, tool buttons) through which the user will communicate to the app. 
-- This method is also the place to put your validation code if you are licensing the add-in. You would normally do this before putting up the UI. 
-- If the user is not a valid user, you would not want to put the UI into the IDE.
-- @param app: the object representing the current application in the IDE. 
-- @param connectMode: type of Map3DSystem.App.ConnectMode. 
function Map3DSystem.App.MiniMap.OnConnection(app, connectMode)
	if(connectMode == Map3DSystem.App.ConnectMode.UI_Setup) then
		-- TODO: place your UI (menus,toolbars, tool buttons) through which the user will communicate to the app
		-- e.g. MainBar.AddItem(), MainMenu.AddItem().
		local commandName = "Profile.GenerateMiniMap";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, icon="Texture/3DMapSystem/common/eye.png",
				app_key = app.app_key,});
		end
		local commandName = "Profile.ShowSwfMapPage";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, icon="Texture/3DMapSystem/common/eye.png",
				app_key = app.app_key,});
		end
	else
		-- TODO: place the app's one time initialization code here.
		-- during one time init, its message handler may need to update the app structure with static integration points, 
		-- i.e. app.about, HomeButtonText, HomeButtonText, HasNavigation, NavigationButtonText, HasQuickAction, QuickActionText,  See app template for more information.
		
		-- e.g. Create a MiniMap command link in the main menu 
		local commandName = "Profile.MiniMap";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand({name = commandName,app_key = app.app_key, ButtonText = "小地图", icon = "Texture/3DMapSystem/common/eye.png", });
		end
		
		-- e.g. 
		app.about =  "in-game mini map"
		Map3DSystem.App.MiniMap.app = app; 
		app.HideHomeButton = true;
		
		local commandName = "File.MapPosLogPage";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			commandName = "File.MapPosLogPage";
			command = Map3DSystem.App.Commands.AddNamedCommand({name = commandName,app_key = app.app_key, ButtonText = "地图位置标记", icon = app.icon, });
		end	
	end
end

-- Receives notification that the Add-in is being unloaded.
function Map3DSystem.App.MiniMap.OnDisconnection(app, disconnectMode)
	if(disconnectMode == Map3DSystem.App.DisconnectMode.UserClosed or disconnectMode == Map3DSystem.App.DisconnectMode.WorldClosed)then
		-- TODO: remove all UI elements related to this application, since the IDE is still running. 
		
		-- e.g. remove command from mainbar
		local command = Map3DSystem.App.Commands.GetCommand("Profile.MiniMap");
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
function Map3DSystem.App.MiniMap.OnQueryStatus(app, commandName, statusWanted)
	if(statusWanted == Map3DSystem.App.CommandStatusWanted) then
		-- TODO: return an integer by adding values in Map3DSystem.App.CommandStatus.
		if(commandName == "Profile.MiniMap") then
			-- return enabled and supported 
			return (Map3DSystem.App.CommandStatus.Enabled + Map3DSystem.App.CommandStatus.Supported)
		end
	end
end

-- This is called when the command is invoked.The Exec is fired after the QueryStatus event is fired, assuming that the return to the statusOption parameter of QueryStatus is supported and enabled. 
-- This is the event where you place the actual code for handling the response to the user click on the command.
-- @param commandName: The name of the command to determine state for. Usually in the string format "Category.SubCate.Name".
function Map3DSystem.App.MiniMap.OnExec(app, commandName, params)
	if(commandName == "Profile.MiniMap") then
		NPL.load("(gl)script/kids/3DMapSystemUI/MiniMap/MiniMapPage.lua");
		Map3DSystem.App.MiniMap.MiniMapPage.Show();
	elseif(commandName == "File.MapPosLogPage") then
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {url="script/kids/3DMapSystemUI/MiniMap/MapPosLogPage.html", name="MapPosLogPage", app.app_key, 
			bToggleShowHide=true, DestroyOnClose=true, 
			text = "地图位置标记",
			initialPosX = 10, 
			initialPosY = 80,
			initialWidth = 260, 
			initialHeight = 320,
			bAutoSize = true,
			});
	elseif(commandName == "Profile.GenerateMiniMap") then			
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url="script/kids/3DMapSystemUI/MiniMap/GenMiniMapPage.html", 
			name="GenMapPage", 
			icon="Texture/3DMapSystem/common/eye.png",
			app_key = app.app_key, 
			allowDrag = true,
			initialPosX = 0, 
			initialPosY = 0, 
			initialWidth = 220,
			initialHeight = 550,
			text = "Gen mini map page",
			DestroyOnClose = true,
		});
	elseif(commandName == "Profile.ShowSwfMapPage")then
		NPL.load("(gl)script/kids/3DMapSystemUI/MiniMap/SwfMapPage.lua");
		Map3DSystem.App.MiniMap.SwfMapPage.ShowPage(app);
	elseif(app:IsHomepageCommand(commandName)) then
		Map3DSystem.App.MiniMap.GotoHomepage();
	elseif(app:IsNavigationCommand(commandName)) then
		Map3DSystem.App.MiniMap.Navigate();
	elseif(app:IsQuickActionCommand(commandName)) then	
		Map3DSystem.App.MiniMap.DoQuickAction();
	end
end

-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
function Map3DSystem.App.MiniMap.OnRenderBox(mcmlData)
end


-- called when the user wants to nagivate to the 3D world location relavent to this application
function Map3DSystem.App.MiniMap.Navigate()
end

-- called when user clicks to check out the homepage of this application. Homepage usually includes:
-- developer info, support, developer worlds information, app global news, app updates, all community user rating, active users, trade, currency transfer, etc. 
function Map3DSystem.App.MiniMap.GotoHomepage()
end

-- called when user clicks the quick action for this application. 
function Map3DSystem.App.MiniMap.DoQuickAction()
end

-- called whenever a new world is loaded (just before the 3d scene is enabled, yet after world data is loaded). 
function Map3DSystem.App.MiniMap.OnWorldLoad()
	
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
function Map3DSystem.App.MiniMap.MSGProc(window, msg)
	----------------------------------------------------
	-- application plug-in messages here
	----------------------------------------------------
	if(msg.type == Map3DSystem.App.MSGTYPE.APP_CONNECTION) then	
		-- Receives notification that the Add-in is being loaded.
		Map3DSystem.App.MiniMap.OnConnection(msg.app, msg.connectMode);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_DISCONNECTION) then	
		-- Receives notification that the Add-in is being unloaded.
		Map3DSystem.App.MiniMap.OnDisconnection(msg.app, msg.disconnectMode);

	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUERY_STATUS) then
		-- This is called when the command's availability is updated. 
		-- NOTE: this function returns a result. 
		msg.status = Map3DSystem.App.MiniMap.OnQueryStatus(msg.app, msg.commandName, msg.statusWanted);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_EXEC) then
		-- This is called when the command is invoked.
		Map3DSystem.App.MiniMap.OnExec(msg.app, msg.commandName, msg.params);
				
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_RENDER_BOX) then	
		-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
		Map3DSystem.App.MiniMap.OnRenderBox(msg.mcml);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_NAVIGATION) then
		-- Receives notification that the user wants to nagivate to the 3D world location relavent to this application
		Map3DSystem.App.MiniMap.Navigate();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_HOMEPAGE) then
		-- called when user clicks to check out the homepage of this application. 
		Map3DSystem.App.MiniMap.GotoHomepage();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUICK_ACTION) then
		-- called when user clicks the quick action for this application. 
		Map3DSystem.App.MiniMap.DoQuickAction();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_WORLD_LOAD) then
		-- called whenever a new world is loaded (just before the 3d scene is enabled, yet after world data is loaded). 
		Map3DSystem.App.MiniMap.OnWorldLoad();

	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		
	end
end