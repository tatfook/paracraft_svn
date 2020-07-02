--[[
Title: EBook app for Paraworld
Author(s): LiXizhi
Date: 2008/1/5
Desc: 
---++ show the Ebook window
<verbatim>
	Map3DSystem.App.Commands.Call("File.EBook");
</verbatim>

replace "MyCompany.Apps" with whatever your name
db registration insert script
INSERT INTO apps VALUES (NULL, 'EBook_GUID', 'EBook', '1.0.0', 'http://www.paraengine.com/apps/EBook_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemUI/EBook/IP.xml', '', 'script/kids/3DMapSystemUI/EBook/app_main.lua', 'MyCompany.Apps.EBook.MSGProc', 1);
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/EBook/app_main.lua");
------------------------------------------------------------
]]

-- requires

-- create class
commonlib.setfield("MyCompany.Apps.EBook", {});

-------------------------------------------
-- event handlers
-------------------------------------------

-- OnConnection method is the obvious point to place your UI (menus, mainbars, tool buttons) through which the user will communicate to the app. 
-- This method is also the place to put your validation code if you are licensing the add-in. You would normally do this before putting up the UI. 
-- If the user is not a valid user, you would not want to put the UI into the IDE.
-- @param app: the object representing the current application in the IDE. 
-- @param connectMode: type of Map3DSystem.App.ConnectMode. 
function MyCompany.Apps.EBook.OnConnection(app, connectMode)
	if(connectMode == Map3DSystem.App.ConnectMode.UI_Setup) then
		-- Create a EBook command link in the main menu 
		local commandName = "File.EBook";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "3D电子书", icon = "Texture/3DMapSystem/common/script.png", });
			-- add command to mainmenu control, using the same folder as commandName. But you can use any folder you like
			local pos_category = commandName;
			-- insert after File.group2.
			local index = Map3DSystem.UI.MainMenu.GetItemIndex("File.Group2");
			if(index ~= nil) then
				index = index+1;
			end
			command:AddControl("mainmenu", pos_category, index);
		end
			
	else
		-- place the app's one time initialization code here.
		-- during one time init, its message handler may need to update the app structure with static integration points, 
		-- i.e. app.about, HomeButtonText, HomeButtonText, HasNavigation, NavigationButtonText, HasQuickAction, QuickActionText,  See app template for more information.
		app.HideHomeButton = true;
		MyCompany.Apps.EBook.app = app;
		app.Title = "电子书";
		app.icon = "Texture/3DMapSystem/AppIcons/Intro_64.dds"
		app.SubTitle = "制作3D电子书";
		app:SetHelpPage("WelcomePage.html");
		
		--------------------------------------------
		-- add a desktop icon. 
		local commandName = "Offline.Ebook";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand({name = commandName,app_key = app.app_key, 
				ButtonText = "电子书", icon = "Texture/3DMapSystem/AppIcons/Book_64.dds", OnShowUICallback = function(bShow, _parent, parentWindow)
					NPL.load("(gl)script/kids/3DMapSystemUI/EBook/EBook.lua");
					EBook.Show(bShow, _parent, parentWindow)
				end});
			local pos_category = commandName;	
			command:AddControl("desktop", pos_category);	
			
			commandName = "Online.Ebook";
			command = Map3DSystem.App.Commands.AddNamedCommand({name = commandName,app_key = app.app_key, 
				ButtonText = "电子书", icon = "Texture/3DMapSystem/AppIcons/Book_64.dds", OnShowUICallback = function(bShow, _parent, parentWindow)
					NPL.load("(gl)script/kids/3DMapSystemUI/EBook/EBook.lua");
					EBook.Show(bShow, _parent, parentWindow)
				end});
			local pos_category = commandName;	
			command:AddControl("desktop", pos_category);	
		end	
	end
end

-- Receives notification that the Add-in is being unloaded.
function MyCompany.Apps.EBook.OnDisconnection(app, disconnectMode)
	if(disconnectMode == Map3DSystem.App.DisconnectMode.UserClosed or disconnectMode == Map3DSystem.App.DisconnectMode.WorldClosed)then
		-- e.g. remove command from mainbar
		local command = Map3DSystem.App.Commands.GetCommand("File.EBook");
		if(command == nil) then
			command:Delete();
		end
	end
end

-- This is called when the command's availability is updated
-- When the user clicks a command (menu or mainbar button), the QueryStatus event is fired. 
-- The QueryStatus event returns the current status of the specified named command, whether it is enabled, disabled, 
-- or hidden in the CommandStatus parameter, which is passed to the msg by reference (or returned in the event handler). 
-- @param commandName: The name of the command to determine state for. Usually in the string format "Category.SubCate.Name".
-- @param statusWanted: what status of the command is queried. it is of type Map3DSystem.App.CommandStatusWanted
-- @return: returns according to statusWanted. it may return an integer by adding values in Map3DSystem.App.CommandStatus.
function MyCompany.Apps.EBook.OnQueryStatus(app, commandName, statusWanted)
	if(statusWanted == Map3DSystem.App.CommandStatusWanted) then
		-- TODO: return an integer by adding values in Map3DSystem.App.CommandStatus.
		if(commandName == "File.EBook") then
			-- return enabled and supported 
			return (Map3DSystem.App.CommandStatus.Enabled + Map3DSystem.App.CommandStatus.Supported)
		end
	end
end

-- This is called when the command is invoked.The Exec is fired after the QueryStatus event is fired, assuming that the return to the statusOption parameter of QueryStatus is supported and enabled. 
-- This is the event where you place the actual code for handling the response to the user click on the command.
-- @param commandName: The name of the command to determine state for. Usually in the string format "Category.SubCate.Name".
function MyCompany.Apps.EBook.OnExec(app, commandName, params)
	if(commandName == "File.EBook") then
		-- show the ebook window
		NPL.load("(gl)script/kids/3DMapSystemUI/EBook/EBook.lua");
		
		local _wnd = app._wnd;
		local _wndFrame = _wnd:GetWindowFrame();
		if(not _wndFrame) then
			_wndFrame = _wnd:CreateWindowFrame{
				icon = "Texture/3DMapSystem/MainBarIcon/Ebook_2.png",
				text = "电子书",
				isShowMaximizeBox = false,
				isShowMinimizeBox = false,
				isShowAutoHideBox = false,
				allowDrag = true,
				allowResize = false,
				initialPosX = 80, 
				initialPosY = 20,
				initialWidth = 800,
				initialHeight = 590,
				ShowUICallback = EBook.Show,
			};
		end
		_wnd:ShowWindowFrame(true);
		
	elseif(app:IsHomepageCommand(commandName)) then
		MyCompany.Apps.EBook.GotoHomepage();
		
	elseif(app:IsNavigationCommand(commandName)) then
		MyCompany.Apps.EBook.Navigate();
	elseif(app:IsQuickActionCommand(commandName)) then	
		MyCompany.Apps.EBook.DoQuickAction();
	end
end

-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
function MyCompany.Apps.EBook.OnRenderBox(mcmlData)
end


-- called when the user wants to nagivate to the 3D world location relavent to this application
function MyCompany.Apps.EBook.Navigate()
end

-- called when user clicks to check out the homepage of this application. Homepage usually includes:
-- developer info, support, developer worlds information, app global news, app updates, all community user rating, active users, trade, currency transfer, etc. 
function MyCompany.Apps.EBook.GotoHomepage()
end

-- called when user clicks the quick action for this application. 
function MyCompany.Apps.EBook.DoQuickAction()
end


-- Add terrain, sky and ocean button to the toolbar. 
function MyCompany.Apps.EBook.OnActivateDesktop(app)
	Map3DSystem.App.Commands.Call("File.EBook")
end

-- 
function MyCompany.Apps.EBook.OnDeactivateDesktop()

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
function MyCompany.Apps.EBook.MSGProc(window, msg)
	----------------------------------------------------
	-- application plug-in messages here
	----------------------------------------------------
	if(msg.type == Map3DSystem.App.MSGTYPE.APP_CONNECTION) then	
		-- Receives notification that the Add-in is being loaded.
		MyCompany.Apps.EBook.OnConnection(msg.app, msg.connectMode);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_DISCONNECTION) then	
		-- Receives notification that the Add-in is being unloaded.
		MyCompany.Apps.EBook.OnDisconnection(msg.app, msg.disconnectMode);

	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUERY_STATUS) then
		-- This is called when the command's availability is updated. 
		-- NOTE: this function returns a result. 
		msg.status = MyCompany.Apps.EBook.OnQueryStatus(msg.app, msg.commandName, msg.statusWanted);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_EXEC) then
		-- This is called when the command is invoked.
		MyCompany.Apps.EBook.OnExec(msg.app, msg.commandName, msg.params);
				
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_RENDER_BOX) then	
		-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
		MyCompany.Apps.EBook.OnRenderBox(msg.mcml);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_NAVIGATION) then
		-- Receives notification that the user wants to nagivate to the 3D world location relavent to this application
		MyCompany.Apps.EBook.Navigate();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_HOMEPAGE) then
		-- called when user clicks to check out the homepage of this application. 
		MyCompany.Apps.EBook.GotoHomepage();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUICK_ACTION) then
		-- called when user clicks the quick action for this application. 
		MyCompany.Apps.EBook.DoQuickAction();
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_ACTIVATE_DESKTOP) then
		MyCompany.Apps.EBook.OnActivateDesktop(msg.app);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_DEACTIVATE_DESKTOP) then
		MyCompany.Apps.EBook.OnDeactivateDesktop();
			
	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		window:ShowWindowFrame(false);
	end
end