--[[
Title: Settings the preferences for Paraworld users, such as window resolution, graphics, sound, key board preferences. 
Author(s): LiXizhi
Date: 2008/1/28
Desc: 
---++ show app setting page
an app can open its settings page using following command. If no app_key is specified, the current application desktop is used. 

*For example*
<verbatim>
	Map3DSystem.App.Commands.Call("File.Settings", {category="app", app_key = "profiles_GUID"});
	-- An application set its settings page in its UI connection event. 
	app:SetSettingPage("AvatarRegPage.html", "Avatar Settings Title");
</verbatim>

---++ show app File.Help
any app can open its help page using following command. If no app_key is specified, the current application desktop is used.  

*For example*
<verbatim>
	-- show the Help page for the currently active desktop
	Map3DSystem.App.Commands.Call("File.Help")
	-- show the Help page for a given app
	Map3DSystem.App.Commands.Call("File.Help", {app_key = "profiles_GUID"});
	-- An application set its help page in its UI connection event. 
	app:SetHelpPage("WelcomePage.html", "Avatar Help");
</verbatim>

---++ show app welcome page
An application can open a welcome page at its OnActivateDesktop event handler. This is easily done by calling below
<verbatim>
	-- display welcome page according to user preference
	Map3DSystem.App.Commands.Call("File.WelcomePage", {url="script/kids/3DMapSystemUI/MyDesktop/WelcomePage.html"})
	-- force display welcome page
	Map3DSystem.App.Commands.Call("File.WelcomePage", {url="script/kids/3DMapSystemUI/MyDesktop/WelcomePage.html", bShow=true})
	-- force hide welcome page
	Map3DSystem.App.Commands.Call("File.WelcomePage", {bShow=false})
</verbatim>
It will automatically remember whether the user wants to show it again when desktop is switched to the app. 
One can force display even the user does not want to show it by adding the bShow property to the command parameter. 

---++ File.SendEmail
<verbatim>
	Map3DSystem.App.Commands.Call("File.SendEmail", {mailto="support@paraengine.com", subject="", body=""})
</verbatim>
---++ File.SubmitBug
Show the submit bug dialog window.
<verbatim>
	Map3DSystem.App.Commands.Call("File.SubmitBug")
</verbatim>

db registration insert script
INSERT INTO apps VALUES (NULL, 'Settings_GUID', 'Settings', '1.0.0', 'http://www.paraengine.com/apps/Settings_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemUI/Settings/IP.xml', '', 'script/kids/3DMapSystemUI/Settings/app_main.lua', 'Map3DSystem.App.Settings.MSGProc', 1);
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Settings/app_main.lua");
------------------------------------------------------------
]]
local L = CommonCtrl.Locale("ParaWorld");


-- requires

-- create class
commonlib.setfield("Map3DSystem.App.Settings", {});

-------------------------------------------
-- event handlers
-------------------------------------------

-- OnConnection method is the obvious point to place your UI (menus, mainbars, tool buttons) through which the user will communicate to the app. 
-- This method is also the place to put your validation code if you are licensing the add-in. You would normally do this before putting up the UI. 
-- If the user is not a valid user, you would not want to put the UI into the IDE.
-- @param app: the object representing the current application in the IDE. 
-- @param connectMode: type of Map3DSystem.App.ConnectMode. 
function Map3DSystem.App.Settings.OnConnection(app, connectMode)
	if(connectMode == Map3DSystem.App.ConnectMode.UI_Setup) then
		-- TODO: place your UI (menus,toolbars, tool buttons) through which the user will communicate to the app
		-- e.g. MainBar.AddItem(), MainMenu.AddItem().
		
		-- e.g. Create a Settings command link in the main menu 
		local commandName = "File.Settings";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command ~= nil) then
			-- add command to mainmenu control, using the same folder as commandName. But you can use any folder you like
			local pos_category = commandName;
			-- add to last group.
			local nPos = Map3DSystem.App.Command.GetPosIndex("mainmenu", "File.GroupLast");
			if(nPos~=nil) then nPos = nPos+1 end
			command:AddControl("mainmenu", pos_category, nPos);
		end
			
	else
		-- TODO: place the app's one time initialization code here.
		-- during one time init, its message handler may need to update the app structure with static integration points, 
		-- i.e. app.about, HomeButtonText, HomeButtonText, HasNavigation, NavigationButtonText, HasQuickAction, QuickActionText,  See app template for more information.
		
		-- e.g. 
		app.about =  "change your application preferences."
		Map3DSystem.App.Settings.app = app; 
		app.HideHomeButton = true;
		app.icon = "Texture/3DMapSystem/Desktop/Startup/setting.png";
		
		local commandName = "File.Settings";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = L"设置...", icon = "Texture/3DMapSystem/common/monitor.png", });
		end
		
		local commandName = "File.Help";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = L"帮助", icon = "Texture/3DMapSystem/common/Help.png", });
		end
		
		local commandName = "File.WelcomePage";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = L"欢迎页面", icon = "Texture/3DMapSystem/common/action.png",});
		end
		
		local commandName = "File.ShowWelcomePage";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = L"欢迎页", icon = "Texture/3DMapSystem/common/action.png",});
		end
		
		local commandName = "File.SendEmail";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand({name = commandName,app_key = app.app_key, ButtonText = "Send Email", });
		end
		
		local commandName = "File.SubmitBug";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = L"提交Bug", icon = "Texture/3DMapSystem/common/bug.png",});
		end
		
		
		--------------------------------------------
		-- add a desktop icon. 
		local commandName = "Startup.Settings";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand({name = commandName,app_key = app.app_key, 
				ButtonText = L"设置", icon = "Texture/3DMapSystem/Desktop/Startup/setting.png", OnShowUICallback = function(bShow, _parent, parentWindow)
					NPL.load("(gl)script/kids/3DMapSystemUI/Settings/Settings.lua");
					Map3DSystem.App.Settings.Settings.Show(bShow, _parent, parentWindow)
				end});
			local pos_category = commandName;	
			command:AddControl("desktop", pos_category, 4);	
		end	
	end
end

-- Receives notification that the Add-in is being unloaded.
function Map3DSystem.App.Settings.OnDisconnection(app, disconnectMode)
	if(disconnectMode == Map3DSystem.App.DisconnectMode.UserClosed or disconnectMode == Map3DSystem.App.DisconnectMode.WorldClosed)then
		-- TODO: remove all UI elements related to this application, since the IDE is still running. 
		
		-- e.g. remove command from mainbar
		local command = Map3DSystem.App.Commands.GetCommand("File.Settings");
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
function Map3DSystem.App.Settings.OnQueryStatus(app, commandName, statusWanted)
	if(statusWanted == Map3DSystem.App.CommandStatusWanted) then
		-- TODO: return an integer by adding values in Map3DSystem.App.CommandStatus.
		if(commandName == "File.Settings") then
			-- return enabled and supported 
			return (Map3DSystem.App.CommandStatus.Enabled + Map3DSystem.App.CommandStatus.Supported)
		end
	end
end

-- This is called when the command is invoked.The Exec is fired after the QueryStatus event is fired, assuming that the return to the statusOption parameter of QueryStatus is supported and enabled. 
-- This is the event where you place the actual code for handling the response to the user click on the command.
-- @param commandName: The name of the command to determine state for. Usually in the string format "Category.SubCate.Name".
function Map3DSystem.App.Settings.OnExec(app, commandName, params)
	if(commandName == "File.Settings") then
		-- actual code of processing the command goes here. 
		NPL.load("(gl)script/kids/3DMapSystemUI/Settings/Settings.lua");
		
		Map3DSystem.App.Settings.Settings.ShowWnd(app._app, params);
		
	elseif(commandName == "File.Help") then	
		-- show help page for the current application. 
		local app_key;
		if(params) then
			app_key = params.app_key;
		end
		
		local theApp = Map3DSystem.App.AppManager.GetApp(app_key);
		if(theApp) then
			local url, title = theApp:GetHelpPage();
			if(url) then
				commonlib.echo(url)
				Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="WelcomePage", app_key = app.app_key,
					url=url,
					icon = "Texture/3DMapSystem/common/Help.png",
					text = title or L"帮助页",
					directPosition = true,
						align = "_ct",
						x = -520/2,
						y = -480/2,
						width = 520,
						height = 480,
				});
			end
		end
	elseif(commandName == "File.WelcomePage") then	
		if(type(params)~= "table") then return end
		-- show or hide welcomepage
		if(params.bShow==false) then
			-- hide the window
			Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="WelcomePage", app_key = app.app_key, bShow = false,});
		else
			if(params.url) then
				local url_pages = Map3DSystem.App.Settings.app:ReadConfig("urls", {})
				local bDonotShowNextTime = url_pages[params.url];
				
				if(params.bShow or not bDonotShowNextTime) then
					local url = System.localserver.UrlHelper.BuildURLQuery("script/kids/3DMapSystemUI/Settings/WelcomePage.html", {url=params.url, appkey=params.appkey});
					
					-- call below to show the window
					Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
						url=url, name="WelcomePage",
						app_key = app.app_key,
						icon = "Texture/3DMapSystem/common/action.png",
						text = L"欢迎页",
						directPosition = true,
							align = "_ct",
							x = -520/2,
							y = -480/2,
							width = 520,
							height = 480,
					});
				end
			end	
		end	
	elseif(commandName == "File.SubmitBug") then
		-- call below to show the window
		Map3DSystem.App.Commands.Call("File.MCMLBrowser", {url="script/kids/3DMapSystemUI/Settings/SubmitBugPage.html", name="SubmitBug", title=L"提交Bug", DisplayNavBar = false});
			
	elseif(commandName == "File.SendEmail") then
		-- submit a bug using explorer. 
		-- TODO: there is no normal way to send attachment in this way. 
		NPL.load("(gl)script/ide/System/localserver/UrlHelper.lua");
		params = params or {};
		cmdLine = string.format("mailto:%s", params.mailto or "support@paraengine.com");
		if(params.subject and params.subject~="") then
			cmdLine = string.format("%s&subject=%s", cmdLine, System.localserver.UrlHelper.url_encode(params.subject));
		end	
		if(params.body and params.body~="") then
			cmdLine = string.format("%s&body=%s", cmdLine, System.localserver.UrlHelper.url_encode(params.body));
		end	
		-- mailto:support@paraengine.com&subject=bug%body=hi"
		commonlib.echo(cmdLine)
		ParaGlobal.ShellExecute("open", cmdLine, "", "", 1); 
				
	elseif(app:IsHomepageCommand(commandName)) then
		Map3DSystem.App.Settings.GotoHomepage();
	elseif(app:IsNavigationCommand(commandName)) then
		Map3DSystem.App.Settings.Navigate();
	elseif(app:IsQuickActionCommand(commandName)) then	
		Map3DSystem.App.Settings.DoQuickAction();
	end
end

-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
function Map3DSystem.App.Settings.OnRenderBox(mcmlData)
end


-- called when the user wants to nagivate to the 3D world location relavent to this application
function Map3DSystem.App.Settings.Navigate()
end

-- called when user clicks to check out the homepage of this application. Homepage usually includes:
-- developer info, support, developer worlds information, app global news, app updates, all community user rating, active users, trade, currency transfer, etc. 
function Map3DSystem.App.Settings.GotoHomepage()
end

-- called when user clicks the quick action for this application. 
function Map3DSystem.App.Settings.DoQuickAction()
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
function Map3DSystem.App.Settings.MSGProc(window, msg)
	----------------------------------------------------
	-- application plug-in messages here
	----------------------------------------------------
	if(msg.type == Map3DSystem.App.MSGTYPE.APP_CONNECTION) then	
		-- Receives notification that the Add-in is being loaded.
		Map3DSystem.App.Settings.OnConnection(msg.app, msg.connectMode);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_DISCONNECTION) then	
		-- Receives notification that the Add-in is being unloaded.
		Map3DSystem.App.Settings.OnDisconnection(msg.app, msg.disconnectMode);

	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUERY_STATUS) then
		-- This is called when the command's availability is updated. 
		-- NOTE: this function returns a result. 
		msg.status = Map3DSystem.App.Settings.OnQueryStatus(msg.app, msg.commandName, msg.statusWanted);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_EXEC) then
		-- This is called when the command is invoked.
		Map3DSystem.App.Settings.OnExec(msg.app, msg.commandName, msg.params);
				
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_RENDER_BOX) then	
		-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
		Map3DSystem.App.Settings.OnRenderBox(msg.mcml);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_NAVIGATION) then
		-- Receives notification that the user wants to nagivate to the 3D world location relavent to this application
		Map3DSystem.App.Settings.Navigate();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_HOMEPAGE) then
		-- called when user clicks to check out the homepage of this application. 
		Map3DSystem.App.Settings.GotoHomepage();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUICK_ACTION) then
		-- called when user clicks the quick action for this application. 
		Map3DSystem.App.Settings.DoQuickAction();
	

	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		
	end
end