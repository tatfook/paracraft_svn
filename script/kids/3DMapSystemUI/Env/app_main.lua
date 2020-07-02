--[[
Title: Env app for Paraworld
Author(s): LiXizhi
Date: 2008/2/14
Desc: editing environment of the world, such as sky, ocean, and terrain.
db registration insert script
INSERT INTO apps VALUES (NULL, 'Env_GUID', 'Env', '1.0.0', 'http://www.paraengine.com/apps/Env_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemUI/Env/IP.xml', '', 'script/kids/3DMapSystemUI/Env/app_main.lua', 'Map3DSystem.App.Env.MSGProc', 1);
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Env/app_main.lua");
------------------------------------------------------------
]]
local L = CommonCtrl.Locale("ParaWorld");


-- requires

-- create class
commonlib.setfield("Map3DSystem.App.Env", {});

-------------------------------------------
-- event handlers
-------------------------------------------

-- OnConnection method is the obvious point to place your UI (menus, mainbars, tool buttons) through which the user will communicate to the app. 
-- This method is also the place to put your validation code if you are licensing the add-in. You would normally do this before putting up the UI. 
-- If the user is not a valid user, you would not want to put the UI into the IDE.
-- @param app: the object representing the current application in the IDE. 
-- @param connectMode: type of Map3DSystem.App.ConnectMode. 
function Map3DSystem.App.Env.OnConnection(app, connectMode)
	if(connectMode == Map3DSystem.App.ConnectMode.UI_Setup) then
		
		-------------------- Command on Toolbox --------------------
		
		local commandName = "Env.sky";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil or command.app_key ~= app.app_key) then
			command = Map3DSystem.App.Commands.AddNamedCommand({
				name = commandName, 
				app_key = app.app_key, 
				ButtonText = L"天空",
				tooltip = L"更改天空和云雾的颜色与样式", 
				icon = "Texture/3DMapSystem/MainBarIcon/Sky.png; 0 0 48 48", 
			});
		end
		
		-- Terrain: edit the terrain height map and terrain texture
		local commandName = "Env.terrain";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil or command.app_key ~= app.app_key) then
			command = Map3DSystem.App.Commands.AddNamedCommand({
				name = commandName, 
				app_key = app.app_key, 
				ButtonText = L"陆地",
				tooltip = L"更改地貌与地表", 
				icon = "Texture/3DMapSystem/MainBarIcon/Terrain.png; 0 0 48 48", 
			});
		end
		
		-- Water: edit the water level and water color
		local commandName = "Env.ocean";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil or command.app_key ~= app.app_key) then
			command = Map3DSystem.App.Commands.AddNamedCommand({
				name = commandName, 
				app_key = app.app_key, 
				ButtonText = L"海洋",
				tooltip = L"更改海洋的颜色与水面高度", 
				icon = "Texture/3DMapSystem/MainBarIcon/Water.png; 0 0 48 48", 
			});
		end
		
	else
		-- TODO: place the app's one time initialization code here.
		-- during one time init, its message handler may need to update the app structure with static integration points, 
		-- i.e. app.about, HomeButtonText, HomeButtonText, HasNavigation, NavigationButtonText, HasQuickAction, QuickActionText,  See app template for more information.
		
		-- e.g. 
		app.about =  "editing environment of the world, such as sky, ocean, and terrain."
		app.HideHomeButton = true;
		app:SetSettingPage("SettingsPage.html", L"环境设置");
		Map3DSystem.App.Env.app = app; 
		app.Title = L"大自然";
		app.icon = "Texture/3DMapSystem/AppIcons/Environment_64.dds"
		app.SubTitle = L"改变天空,陆地,海洋";
	end
end

-- Receives notification that the Add-in is being unloaded.
function Map3DSystem.App.Env.OnDisconnection(app, disconnectMode)
	if(disconnectMode == Map3DSystem.App.DisconnectMode.UserClosed or disconnectMode == Map3DSystem.App.DisconnectMode.WorldClosed)then
		-- TODO: remove all UI elements related to this application, since the IDE is still running. 
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
function Map3DSystem.App.Env.OnQueryStatus(app, commandName, statusWanted)
	if(statusWanted == Map3DSystem.App.CommandStatusWanted) then
		-- return enabled and supported for all commands
		return (Map3DSystem.App.CommandStatus.Enabled + Map3DSystem.App.CommandStatus.Supported)
	end
end

-- This is called when the command is invoked.The Exec is fired after the QueryStatus event is fired, assuming that the return to the statusOption parameter of QueryStatus is supported and enabled. 
-- This is the event where you place the actual code for handling the response to the user click on the command.
-- @param commandName: The name of the command to determine state for. Usually in the string format "Category.SubCate.Name".
function Map3DSystem.App.Env.OnExec(app, commandName, params)
	if(commandName == "Env.sky") then
		-- show the sky panel
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url="script/kids/3DMapSystemUI/Env/SkyPage.html", name="SkyPage", 
			app_key = app.app_key, 
			isShowTitleBar = true, 
			isShowToolboxBar = false, 
			isShowStatusBar = false, 
			initialPosX = 800 - 4, 
			initialPosY = 175, 
			initialWidth = 220, -- initial width of the window client area
			initialHeight = 440, -- initial height of the window client area
			directPosition = true,
				align = "_lb",
				x = 0,
				y = -544,
				width = 205,
				height = 464,
			opacity = 90,
			icon = "Texture/3DMapSystem/MainBarIcon/Sky.png; 0 0 48 48",
			text = L"天空",
			style = CommonCtrl.WindowFrame.DefaultStyle,
			--{
				--window_bg = "Texture/3DMapSystem/Creator/container.png:7 7 7 7",
				--borderLeft = 0,
				--borderRight = 0,
				--resizerSize = 24,
				--resizer_bg = "",
			--},
			alignment = "Free", 
		});
		--Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			--name="TerrainPage", app_key = app.app_key, bShow = false});
		--Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			--name="OceanPage", app_key = app.app_key, bShow = false});
		
	elseif(commandName == "Env.terrain") then
		-- params = "adv" for advanced terrain page
		-- params = nil for simple terrain page
		local urlParams;
		if(type(params) == "string") then
			urlParams = "?tab="..params;
		end
		
		-- show the terrain panel
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url="script/kids/3DMapSystemUI/Env/TerrainPage.html"..(urlParams or ""), name="TerrainPage", 
			app_key = app.app_key, 
			isShowTitleBar = true, 
			isShowToolboxBar = false, 
			isShowStatusBar = false, 
			initialPosX = 800 - 4, 
			initialPosY = 175, 
			initialWidth = 220, -- initial width of the window client area
			initialHeight = 440, -- initial height of the window client area
			directPosition = true,
				align = "_rb",
				x = -205,
				y = -544,
				width = 240,
				height = 464,
			opacity = 90,
			icon = "Texture/3DMapSystem/MainBarIcon/Terrain.png; 0 0 48 48",
			text = L"陆地",
			style = CommonCtrl.WindowFrame.DefaultStyle,
			--style = {
				--window_bg = "Texture/3DMapSystem/Creator/container.png:7 7 7 7",
				--borderLeft = 0,
				--borderRight = 0,
				--resizerSize = 24,
				--resizer_bg = "",
			--},
			alignment = "Free", 
		});
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			name="SkyPage", app_key = app.app_key, bShow = false});
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			name="OceanPage", app_key = app.app_key, bShow = false});

	elseif(commandName == "Env.ocean") then
		-- show the ocean panel
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url="script/kids/3DMapSystemUI/Env/OceanPage.html", name="OceanPage", 
			app_key = app.app_key, 
			isShowTitleBar = true, 
			isShowToolboxBar = false, 
			isShowStatusBar = false, 
			initialPosX = 800 - 4, 
			initialPosY = 175, 
			initialWidth = 220, -- initial width of the window client area
			initialHeight = 440, -- initial height of the window client area
			directPosition = true,
				align = "_rb",
				x = -205,
				y = -544,
				width = 205,
				height = 464,
			allowDrag = true,
			opacity = 90,
			icon = "Texture/3DMapSystem/MainBarIcon/Water.png; 0 0 48 48",
			text = L"海洋",
			style = CommonCtrl.WindowFrame.DefaultStyle,
			--style = {
				--window_bg = "Texture/3DMapSystem/Creator/container.png:7 7 7 7",
				--borderLeft = 0,
				--borderRight = 0,
				--resizerSize = 24,
				--resizer_bg = "",
			--},
			alignment = "Free", 
		});
		--Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			--name="SkyPage", app_key = app.app_key, bShow = false});
		--Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			--name="TerrainPage", app_key = app.app_key, bShow = false});
		
	elseif(app:IsHomepageCommand(commandName)) then
		Map3DSystem.App.Env.GotoHomepage();
	elseif(app:IsNavigationCommand(commandName)) then
		Map3DSystem.App.Env.Navigate();
	elseif(app:IsQuickActionCommand(commandName)) then	
		Map3DSystem.App.Env.DoQuickAction();
	end
end

-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
function Map3DSystem.App.Env.OnRenderBox(mcmlData)
end


-- called when the user wants to nagivate to the 3D world location relavent to this application
function Map3DSystem.App.Env.Navigate()
end

-- called when user clicks to check out the homepage of this application. Homepage usually includes:
-- developer info, support, developer worlds information, app global news, app updates, all community user rating, active users, trade, currency transfer, etc. 
function Map3DSystem.App.Env.GotoHomepage()
end

-- called when user clicks the quick action for this application. 
function Map3DSystem.App.Env.DoQuickAction()
end

-- Add terrain, sky and ocean button to the toolbar. 
function Map3DSystem.App.Env.OnActivateDesktop()
	Map3DSystem.UI.AppTaskBar.AddCommand("Env.ocean") -- :Call();
	Map3DSystem.UI.AppTaskBar.AddCommand("Env.terrain")-- :Call();
	Map3DSystem.UI.AppTaskBar.AddCommand("Env.sky")--:Call();
	
	autotips.AddIdleTips(L"请经常保存您的世界")
	autotips.AddIdleTips(L"在你盖房子前, 可以先将地表铲平")
	autotips.AddIdleTips(L"改变地表色彩时, 可以用鼠标右键点击图案将其擦除")
end

-- 
function Map3DSystem.App.Env.OnDeactivateDesktop()

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
function Map3DSystem.App.Env.MSGProc(window, msg)
	----------------------------------------------------
	-- application plug-in messages here
	----------------------------------------------------
	if(msg.type == Map3DSystem.App.MSGTYPE.APP_CONNECTION) then	
		-- Receives notification that the Add-in is being loaded.
		Map3DSystem.App.Env.OnConnection(msg.app, msg.connectMode);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_DISCONNECTION) then	
		-- Receives notification that the Add-in is being unloaded.
		Map3DSystem.App.Env.OnDisconnection(msg.app, msg.disconnectMode);

	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUERY_STATUS) then
		-- This is called when the command's availability is updated. 
		-- NOTE: this function returns a result. 
		msg.status = Map3DSystem.App.Env.OnQueryStatus(msg.app, msg.commandName, msg.statusWanted);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_EXEC) then
		-- This is called when the command is invoked.
		Map3DSystem.App.Env.OnExec(msg.app, msg.commandName, msg.params);
				
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_RENDER_BOX) then	
		-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
		Map3DSystem.App.Env.OnRenderBox(msg.mcml);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_NAVIGATION) then
		-- Receives notification that the user wants to nagivate to the 3D world location relavent to this application
		Map3DSystem.App.Env.Navigate();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_HOMEPAGE) then
		-- called when user clicks to check out the homepage of this application. 
		Map3DSystem.App.Env.GotoHomepage();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUICK_ACTION) then
		-- called when user clicks the quick action for this application. 
		Map3DSystem.App.Env.DoQuickAction();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_ACTIVATE_DESKTOP) then
		Map3DSystem.App.Env.OnActivateDesktop();
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_DEACTIVATE_DESKTOP) then
		Map3DSystem.App.Env.OnDeactivateDesktop();
		
	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		
	end
end