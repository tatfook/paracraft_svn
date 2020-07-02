--[[
Title: Inventor app for Paraworld
Author(s): 
Date: 2008/11/24
Desc: 
db registration insert script
INSERT INTO apps VALUES (NULL, 'Sample_GUID', 'Inventor', '1.0.0', 'http://www.paraengine.com/apps/Sample_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemUI/Inventor/IP.xml', '', 'script/kids/3DMapSystemUI/Inventor/app_main.lua', 'MyCompany.Apps.Inventor.MSGProc', 1);

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/app_main.lua");
------------------------------------------------------------
]]

-- requires

-- create class
commonlib.setfield("MyCompany.Apps.Inventor", {});
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Util/GlobalInventor.lua");
-------------------------------------------
-- event handlers
-------------------------------------------

-- OnConnection method is the obvious point to place your UI (menus, mainbars, tool buttons) through which the user will communicate to the app. 
-- This method is also the place to put your validation code if you are licensing the add-in. You would normally do this before putting up the UI. 
-- If the user is not a valid user, you would not want to put the UI into the IDE.
-- @param app: the object representing the current application in the IDE. 
-- @param connectMode: type of Map3DSystem.App.ConnectMode. 
function MyCompany.Apps.Inventor.OnConnection(app, connectMode)
	if(connectMode == Map3DSystem.App.ConnectMode.UI_Setup) then
		-- TODO: place your UI (menus,toolbars, tool buttons) through which the user will communicate to the app
		-- e.g. MainBar.AddItem(), MainMenu.AddItem().
		
		-- e.g. Create a Inventor command link in the main menu 
		local commandName = "Profile.Inventor";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "From Inventor UI Setup", icon = app.icon, });
			-- add command to mainmenu control, using the same folder as commandName. But you can use any folder you like
			local pos_category = commandName;
			-- add to front.
			command:AddControl("mainmenu", pos_category, 1);
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = "Profile.Inventor.CreateEntityTool",app_key = app.app_key, ButtonText = "From Inventor UI Setup", icon = app.icon, });
				
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = "Profile.Inventor.PointerTool",app_key = app.app_key, ButtonText = "From Inventor UI Setup", icon = app.icon, });
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = "Profile.Inventor.EntityTool",app_key = app.app_key, ButtonText = "From Inventor UI Setup", icon = app.icon, });
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = "Profile.Inventor.RotationTool",app_key = app.app_key, ButtonText = "From Inventor UI Setup", icon = app.icon, });
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = "Profile.Inventor.ScaleTool",app_key = app.app_key, ButtonText = "From Inventor UI Setup", icon = app.icon, });
				
			-- Undo
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = "Profile.Inventor.Undo",app_key = app.app_key, ButtonText = "From Inventor UI Setup", icon = app.icon, });
			-- Redo
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = "Profile.Inventor.Redo",app_key = app.app_key, ButtonText = "From Inventor UI Setup", icon = app.icon, });
			-- Cut
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = "Profile.Inventor.Cut",app_key = app.app_key, ButtonText = "From Inventor UI Setup", icon = app.icon, });
			-- Copy
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = "Profile.Inventor.Copy",app_key = app.app_key, ButtonText = "From Inventor UI Setup", icon = app.icon, });
			-- Paste
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = "Profile.Inventor.Paste",app_key = app.app_key, ButtonText = "From Inventor UI Setup", icon = app.icon, });
			-- Delete
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = "Profile.Inventor.Delete",app_key = app.app_key, ButtonText = "From Inventor UI Setup", icon = app.icon, });
			-- DeleteAll
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = "Profile.Inventor.DeleteAll",app_key = app.app_key, ButtonText = "From Inventor UI Setup", icon = app.icon, });
			-- SelectAll
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = "Profile.Inventor.SelectAll",app_key = app.app_key, ButtonText = "From Inventor UI Setup", icon = app.icon, });
			-- UnSelectAll
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = "Profile.Inventor.UnSelectAll",app_key = app.app_key, ButtonText = "From Inventor UI Setup", icon = app.icon, });
			-- GetNextSelection
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = "Profile.Inventor.GetNextSelection",app_key = app.app_key, ButtonText = "From Inventor UI Setup", icon = app.icon, });
			-- Group
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = "Profile.Inventor.Group",app_key = app.app_key, ButtonText = "From Inventor UI Setup", icon = app.icon, });
			-- UnGroup
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = "Profile.Inventor.UnGroup",app_key = app.app_key, ButtonText = "From Inventor UI Setup", icon = app.icon, });
			-- ShowLite3DCanvasView
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = "Profile.Inventor.ShowLite3DCanvasView",app_key = app.app_key, ButtonText = "From Inventor UI Setup", icon = app.icon, });
			-- OpenDocument
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = "Profile.Inventor.OpenDocument",app_key = app.app_key, ButtonText = "From Inventor UI Setup", icon = app.icon, });
			-- NewDocument
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = "Profile.Inventor.NewDocument",app_key = app.app_key, ButtonText = "From Inventor UI Setup", icon = app.icon, });
			-- SaveDocument
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = "Profile.Inventor.SaveDocument",app_key = app.app_key, ButtonText = "From Inventor UI Setup", icon = app.icon, });
			-- SaveDocumentAs
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = "Profile.Inventor.SaveDocumentAs",app_key = app.app_key, ButtonText = "From Inventor UI Setup", icon = app.icon, });
			-- Start
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = "Profile.Inventor.Start",app_key = app.app_key, ButtonText = "From Inventor UI Setup", icon = app.icon, });
			-- Stop
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = "Profile.Inventor.Stop",app_key = app.app_key, ButtonText = "From Inventor UI Setup", icon = app.icon, });
			-- BindPropertyPanel
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = "Profile.Inventor.BindPropertyPanel",app_key = app.app_key, ButtonText = "From Inventor UI Setup", icon = app.icon, });
		end
			
	else
		-- TODO: place the app's one time initialization code here.
		-- during one time init, its message handler may need to update the app structure with static integration points, 
		-- i.e. app.about, HomeButtonText, HomeButtonText, HasNavigation, NavigationButtonText, HasQuickAction, QuickActionText,  See app template for more information.
		
		-- e.g. 
		app.about =  "your short scription of the application here using the current language"
		if(ParaEngine.GetLocale() == "zhCN") then
			app.HomeButtonText = "Inventor in Chinese";
		else
			app.HomeButtonText = "Inventor in English";
		end
	end
	MyCompany.Apps.Inventor.app = app;
end

-- Receives notification that the Add-in is being unloaded.
function MyCompany.Apps.Inventor.OnDisconnection(app, disconnectMode)
	if(disconnectMode == Map3DSystem.App.DisconnectMode.UserClosed or disconnectMode == Map3DSystem.App.DisconnectMode.WorldClosed)then
		-- TODO: remove all UI elements related to this application, since the IDE is still running. 
		
		-- e.g. remove command from mainbar
		local command = Map3DSystem.App.Commands.GetCommand("Profile.Inventor");
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
function MyCompany.Apps.Inventor.OnQueryStatus(app, commandName, statusWanted)
	if(statusWanted == Map3DSystem.App.CommandStatusWanted) then
		-- TODO: return an integer by adding values in Map3DSystem.App.CommandStatus.
		if(commandName == "Profile.Inventor") then
			-- return enabled and supported 
			return (Map3DSystem.App.CommandStatus.Enabled + Map3DSystem.App.CommandStatus.Supported)
		end
	end
end

-- This is called when the command is invoked.The Exec is fired after the QueryStatus event is fired, assuming that the return to the statusOption parameter of QueryStatus is supported and enabled. 
-- This is the event where you place the actual code for handling the response to the user click on the command.
-- @param commandName: The name of the command to determine state for. Usually in the string format "Category.SubCate.Name".
function MyCompany.Apps.Inventor.OnExec(app, commandName, params)
	if(commandName == "Profile.Inventor") then
		-- TODO: actual code of processing the command goes here. 
		-- e.g.
		_guihelper.MessageBox("Inventor application executed. ");
	--TODO: how to create entiry
	elseif(commandName == "Profile.Inventor.CreateEntityTool") then
		Map3DSystem.App.Inventor.GlobalInventor.CreateEntityTool(params.commandName);
		
	elseif(commandName == "Profile.Inventor.PointerTool") then
		Map3DSystem.App.Inventor.GlobalInventor.CreateTool(commandName);
	elseif(commandName == "Profile.Inventor.EntityTool") then
		Map3DSystem.App.Inventor.GlobalInventor.CreateTool(commandName);
	elseif(commandName == "Profile.Inventor.RotationTool") then
		Map3DSystem.App.Inventor.GlobalInventor.CreateTool(commandName);
	elseif(commandName == "Profile.Inventor.ScaleTool") then
		Map3DSystem.App.Inventor.GlobalInventor.CreateTool(commandName);
		
	elseif(commandName == "Profile.Inventor.Undo") then
		Map3DSystem.App.Inventor.GlobalInventor.UndoRedo(commandName);
	elseif(commandName == "Profile.Inventor.Redo") then
		Map3DSystem.App.Inventor.GlobalInventor.UndoRedo(commandName);
	elseif(commandName == "Profile.Inventor.Cut") then
		Map3DSystem.App.Inventor.GlobalInventor.Clone(commandName,params);
	elseif(commandName == "Profile.Inventor.Copy") then
		Map3DSystem.App.Inventor.GlobalInventor.Clone(commandName,params);
	elseif(commandName == "Profile.Inventor.Paste") then
		Map3DSystem.App.Inventor.GlobalInventor.Clone(commandName,params);
	elseif(commandName == "Profile.Inventor.Delete") then
		Map3DSystem.App.Inventor.GlobalInventor.Delete(commandName);
	elseif(commandName == "Profile.Inventor.DeleteAll") then
		Map3DSystem.App.Inventor.GlobalInventor.Delete(commandName);
	elseif(commandName == "Profile.Inventor.SelectAll") then
		Map3DSystem.App.Inventor.GlobalInventor.SelectAll(commandName);
	elseif(commandName == "Profile.Inventor.UnSelectAll") then
		Map3DSystem.App.Inventor.GlobalInventor.UnSelectAll(commandName);
	elseif(commandName == "Profile.Inventor.GetNextSelection") then
		Map3DSystem.App.Inventor.GlobalInventor.GetNextSelection(commandName);	
	elseif(commandName == "Profile.Inventor.Group") then
		Map3DSystem.App.Inventor.GlobalInventor.Group(commandName);
	elseif(commandName == "Profile.Inventor.UnGroup") then
		Map3DSystem.App.Inventor.GlobalInventor.Group(commandName);
	elseif(commandName == "Profile.Inventor.ShowLite3DCanvasView") then
		Map3DSystem.App.Inventor.GlobalInventor.ShowLite3DCanvasView();
	elseif(commandName == "Profile.Inventor.OpenDocument") then
		Map3DSystem.App.Inventor.GlobalInventor.OpenDocument(params);
	elseif(commandName == "Profile.Inventor.NewDocument") then
		Map3DSystem.App.Inventor.GlobalInventor.NewDocument(params);
	elseif(commandName == "Profile.Inventor.SaveDocument") then
		Map3DSystem.App.Inventor.GlobalInventor.SaveDocument(params);
	elseif(commandName == "Profile.Inventor.SaveDocumentAs") then
		Map3DSystem.App.Inventor.GlobalInventor.SaveDocumentAs(params);
	elseif(commandName == "Profile.Inventor.Start") then
		Map3DSystem.App.Inventor.GlobalInventor.Start(params);
	elseif(commandName == "Profile.Inventor.Stop") then
		Map3DSystem.App.Inventor.GlobalInventor.Stop();
	elseif(commandName == "Profile.Inventor.BindPropertyPanel") then
		Map3DSystem.App.Inventor.GlobalInventor.BindPropertyPanel();
	elseif(app:IsHomepageCommand(commandName)) then
		MyCompany.Apps.Inventor.GotoHomepage();
	elseif(app:IsNavigationCommand(commandName)) then
		MyCompany.Apps.Inventor.Navigate();
	elseif(app:IsQuickActionCommand(commandName)) then	
		MyCompany.Apps.Inventor.DoQuickAction();
	end
end

-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
function MyCompany.Apps.Inventor.OnRenderBox(mcmlData)
end


-- called when the user wants to nagivate to the 3D world location relavent to this application
function MyCompany.Apps.Inventor.Navigate()
end

-- called when user clicks to check out the homepage of this application. Homepage usually includes:
-- developer info, support, developer worlds information, app global news, app updates, all community user rating, active users, trade, currency transfer, etc. 
function MyCompany.Apps.Inventor.GotoHomepage()
end

-- called when user clicks the quick action for this application. 
function MyCompany.Apps.Inventor.DoQuickAction()
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
function MyCompany.Apps.Inventor.MSGProc(window, msg)
	----------------------------------------------------
	-- application plug-in messages here
	----------------------------------------------------
	if(msg.type == Map3DSystem.App.MSGTYPE.APP_CONNECTION) then	
		-- Receives notification that the Add-in is being loaded.
		MyCompany.Apps.Inventor.OnConnection(msg.app, msg.connectMode);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_DISCONNECTION) then	
		-- Receives notification that the Add-in is being unloaded.
		MyCompany.Apps.Inventor.OnDisconnection(msg.app, msg.disconnectMode);

	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUERY_STATUS) then
		-- This is called when the command's availability is updated. 
		-- NOTE: this function returns a result. 
		msg.status = MyCompany.Apps.Inventor.OnQueryStatus(msg.app, msg.commandName, msg.statusWanted);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_EXEC) then
		-- This is called when the command is invoked.
		MyCompany.Apps.Inventor.OnExec(msg.app, msg.commandName, msg.params);
				
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_RENDER_BOX) then	
		-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
		MyCompany.Apps.Inventor.OnRenderBox(msg.mcml);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_NAVIGATION) then
		-- Receives notification that the user wants to nagivate to the 3D world location relavent to this application
		MyCompany.Apps.Inventor.Navigate();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_HOMEPAGE) then
		-- called when user clicks to check out the homepage of this application. 
		MyCompany.Apps.Inventor.GotoHomepage();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUICK_ACTION) then
		-- called when user clicks the quick action for this application. 
		MyCompany.Apps.Inventor.DoQuickAction();
	

	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		
	end
end