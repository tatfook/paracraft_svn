--[[
Title: Map app for Paraworld
Author(s): ParaEngine Map Team
Date: 2008/1/24
Desc: 

---++ Get Tile By ID
more info, see code doc. 
<verbatim>
	Map3DSystem.App.Map.GetTileByID(tileID, callback, param1)
</verbatim>


INSERT INTO apps VALUES (NULL, 'Map_GUID', 'Map', '1.0.0', 'http://www.paraengine.com/apps/Map_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemUI/Map/IP.xml', '', 'script/kids/3DMapSystemUI/Map/app_main.lua', 'Map3DSystem.App.Map.MSGProc', 1);
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Map/app_main.lua");
------------------------------------------------------------
]]

-- requires

-- create class
commonlib.setfield("Map3DSystem.App.Map", {});

-------------------------------------------
-- event handlers
-------------------------------------------

-- OnConnection method is the obvious point to place your UI (menus, mainbars, tool buttons) through which the user will communicate to the app. 
-- This method is also the place to put your validation code if you are licensing the add-in. You would normally do this before putting up the UI. 
-- If the user is not a valid user, you would not want to put the UI into the IDE.
-- @param app: the object representing the current application in the IDE. 
-- @param connectMode: type of Map3DSystem.App.ConnectMode. 
function Map3DSystem.App.Map.OnConnection(app, connectMode)
	if(connectMode == Map3DSystem.App.ConnectMode.UI_Setup) then
		-- TODO: place your UI (menus,toolbars, tool buttons) through which the user will communicate to the app
		-- e.g. MainBar.AddItem(), MainMenu.AddItem().
		
		-- e.g. Create a Map command link in the main menu 
		local commandName = "Map.WorldMap";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			local items = {
				{name = "Map.WorldMap", text="世界地图...", pos = 1, icon = "Texture/3DMapSystem/common/world_go.png"},
				{name = "Map.Search", text="搜索", pos = 2, icon = "Texture/3DMapSystem/common/search.png"},
				-- TODO: Locations, we may read the list from a remote XML file on the map app server and cache it locally. 
				-- here I just add them manually here. 
				{name = "Map.Locations.MC_colonycenter", text="MC移民总部"},
				{name = "Map.Locations.PE_center", text="ParaEngine中心"},
				{name = "Map.Locations.newbie_village", text="新手村"},
				{name = "Map.Locations.kids_town", text="儿童城"},
				{name = "Map.Locations.clubs", text="俱乐部"},
				{name = "Map.Locations.WorldWindow", text="世界之窗"},
				{name = "Map.Locations.Cottages", text="别墅区"},
				{name = "Map.Locations.MMORPG", text="帕拉巫网游区"},
				{name = "Map.Locations.playground", text="游乐场"},
				{name = "Map.Locations.KORAOK", text="K歌城"},
				{name = "Map.Locations.Singles", text="单身俱乐部"},
				{name = "Map.Locations.MovieCity", text="影城"},
				{name = "Map.Locations.TradeCity", text="交易城"},
				{name = "Map.Locations.LandAuction", text="土地拍卖所"},
				{name = "Map.Locations.GambleCity", text="赌城"},
				{name = "Map.Locations.LoveIsland", text="情人岛"},
				{name = "Map.Locations.Artchitecture", text="建筑大观"},
				{name = "Map.Locations.Artist", text="美术之家"},
				{name = "Map.Locations.MC_Research", text="MC研究中心"},
				{name = "Map.Locations.Education", text="教育"},
				{name = "Map.Locations.AppCity", text="APP城"},
			};
			local i, item
			for i, item in ipairs(items) do
				command = Map3DSystem.App.Commands.AddNamedCommand(
					{name = item.name,app_key = app.app_key, ButtonText = item.text, icon = item.icon, });
				-- add command to mainmenu control, using the same folder as commandName. But you can use any folder you like
				command:AddControl("mainmenu", item.name, item.pos);
			end	
		end
			
	else
		-- place the app's one time initialization code here.
		-- during one time init, its message handler may need to update the app structure with static integration points, 
		-- i.e. app.about, HomeButtonText, HomeButtonText, HasNavigation, NavigationButtonText, HasQuickAction, QuickActionText,  See app template for more information.
		
		Map3DSystem.App.Map.app = app; -- keep a reference
		app.about =  "official map application"
		app.HideHomeButton = true;
		app.HomeButtonText = "地图";
		app.Title = "世界地图";
		app.icon = "Texture/3DMapSystem/AppIcons/Map_64.dds"
		app.SubTitle = "地球尺度的3D世";
				
		app:SetSettingPage("MapRegPage.html", "我的虚拟土地");
		app:SetHelpPage("WelcomePage.html");
		
		-- set profile definition
		-- TODO: temporarily keep UserInfo here. move this to a web service on the central server instead.
		app:SetProfileDefinition({
			ProfileBox = true,
			UserTiles = {
			  -- this is a string containing recently purchased tileid seperated by commar. e.g. "416, 417,"
			  ["tiles"] = true,
			  --["x"] = true,
			  --["y"] = true,
		  },
		});

		--------------------------------------------
		-- add a desktop icon. 
		--local commandName = "Startup.map";
		--local command = Map3DSystem.App.Commands.GetCommand(commandName);
		--if(command == nil) then
			--command = Map3DSystem.App.Commands.AddNamedCommand({name = commandName,app_key = app.app_key, 
				--ButtonText = "地图", icon = "Texture/3DMapSystem/Desktop/Startup/map.png", OnShowUICallback = function(bShow, _parent, parentWindow)
					--NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppWrapper.lua");
					--Map3DSystem.App.Map.MapWnd.Show(bShow,_parent,parentWindow);
				--end});
			--local pos_category = commandName;	
			--command:AddControl("desktop", pos_category, 2);	
		--end	
		--
		---- add registration page command, this is required by LoginApp to handler per application user registration. 
		--local commandName = "Registration.Map";
		--local command = Map3DSystem.App.Commands.GetCommand(commandName);
		--if(command == nil) then
			--command = Map3DSystem.App.Commands.AddNamedCommand(
				--{name = commandName,app_key = app.app_key, ButtonText = "App注册", });
		--end
	end
end

-- Receives notification that the Add-in is being unloaded.
function Map3DSystem.App.Map.OnDisconnection(app, disconnectMode)
	if(disconnectMode == Map3DSystem.App.DisconnectMode.UserClosed or disconnectMode == Map3DSystem.App.DisconnectMode.WorldClosed)then
		-- remove all UI elements related to this application, since the IDE is still running. 
		
		-- e.g. remove command from mainbar
		local command = Map3DSystem.App.Commands.GetCommand("Map.WorldMap");
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
function Map3DSystem.App.Map.OnQueryStatus(app, commandName, statusWanted)
	if(statusWanted == Map3DSystem.App.CommandStatusWanted) then
		-- return an integer by adding values in Map3DSystem.App.CommandStatus.
		if(commandName == "Map.WorldMap" or commandName == "Map.Search" or commandName == "Registration.Map") then
			-- return enabled and supported 
			return (Map3DSystem.App.CommandStatus.Enabled + Map3DSystem.App.CommandStatus.Supported)
		end
	end
end

-- This is called when the command is invoked.The Exec is fired after the QueryStatus event is fired, assuming that the return to the statusOption parameter of QueryStatus is supported and enabled. 
-- This is the event where you place the actual code for handling the response to the user click on the command.
-- @param commandName: The name of the command to determine state for. Usually in the string format "Category.SubCate.Name".
function Map3DSystem.App.Map.OnExec(app, commandName, params)
	if(commandName == "Map.WorldMap") then
		-- show the main world map window
		NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppWrapper.lua");
		Map3DSystem.App.Map.ShowMapWnd(app._app);
		
	elseif(commandName == "Map.Search") then
		-- TODO: switch to map search
		_guihelper.MessageBox("TODO: switch to Map search.");
	
	elseif(commandName == "Registration.Map" and params) then
		if(params.operation=="query") then
			-- TODO: check this application's MCML profile to determine if registration is complete. 
			local profile = app:GetMCMLInMemory() or {};
			if(profile.UserTiles and profile.UserTiles.tiles) then
				--we consider land register step is done, if user already have tiles 
				return {RequiredComplete = true, CompleteProgress = 1}
			else
				return {RequiredComplete = false, CompleteProgress = 0.1}
			end
		elseif(params.operation=="show") then
			_guihelper.CloseMessageBox();
			-- 
			-- Show the MCML registration page here. 
			-- 
			if(params.parent) then
				NPL.load("(gl)script/kids/3DMapSystemUI/Map/MapRegPage.lua");
				Map3DSystem.App.Map.MapRegPage.OnFinishedFunc = params.callbackFunc;
				Map3DSystem.App.Map.MapRegPage:Create("Map.MapRegPage", params.parent, "_fi", 0,0,0,0);
			end	
		end
	elseif(app:IsHomepageCommand(commandName)) then
		Map3DSystem.App.Map.GotoHomepage();
	elseif(app:IsNavigationCommand(commandName)) then
		Map3DSystem.App.Map.Navigate();
	elseif(app:IsQuickActionCommand(commandName)) then	
		Map3DSystem.App.Map.DoQuickAction();
	end
end

-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
function Map3DSystem.App.Map.OnRenderBox(mcmlData)
end


-- called when the user wants to nagivate to the 3D world location relavent to this application
function Map3DSystem.App.Map.Navigate()
end

-- called when user clicks to check out the homepage of this application. Homepage usually includes:
-- developer info, support, developer worlds information, app global news, app updates, all community user rating, active users, trade, currency transfer, etc. 
function Map3DSystem.App.Map.GotoHomepage()
end

-- called when user clicks the quick action for this application. 
function Map3DSystem.App.Map.DoQuickAction()
end

-- Add terrain, sky and ocean button to the toolbar. 
function Map3DSystem.App.Map.OnActivateDesktop()
	Map3DSystem.App.Commands.GetCommand("Map.WorldMap"):Call();
end

-- 
function Map3DSystem.App.Map.OnDeactivateDesktop()

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
function Map3DSystem.App.Map.MSGProc(window, msg)
	----------------------------------------------------
	-- application plug-in messages here
	----------------------------------------------------
	if(msg.type == Map3DSystem.App.MSGTYPE.APP_CONNECTION) then	
		-- Receives notification that the Add-in is being loaded.
		Map3DSystem.App.Map.OnConnection(msg.app, msg.connectMode);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_DISCONNECTION) then	
		-- Receives notification that the Add-in is being unloaded.
		Map3DSystem.App.Map.OnDisconnection(msg.app, msg.disconnectMode);

	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUERY_STATUS) then
		-- This is called when the command's availability is updated. 
		-- NOTE: this function returns a result. 
		msg.status = Map3DSystem.App.Map.OnQueryStatus(msg.app, msg.commandName, msg.statusWanted);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_EXEC) then
		-- This is called when the command is invoked.
		msg.response = Map3DSystem.App.Map.OnExec(msg.app, msg.commandName, msg.params);
				
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_RENDER_BOX) then	
		-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
		Map3DSystem.App.Map.OnRenderBox(msg.mcml);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_NAVIGATION) then
		-- Receives notification that the user wants to nagivate to the 3D world location relavent to this application
		Map3DSystem.App.Map.Navigate();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_HOMEPAGE) then
		-- called when user clicks to check out the homepage of this application. 
		Map3DSystem.App.Map.GotoHomepage();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUICK_ACTION) then
		-- called when user clicks the quick action for this application. 
		Map3DSystem.App.Map.DoQuickAction();
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_ACTIVATE_DESKTOP) then
		Map3DSystem.App.Map.OnActivateDesktop();
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_DEACTIVATE_DESKTOP) then
		Map3DSystem.App.Map.OnDeactivateDesktop();


	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		
	end
end


-- this is wrapper function of paraworld.map.GetTileByID
-- @param tileID: tile id, or its string. 
-- @param callback: function of (tileInfo, param1)
-- @param param1: an optional parameter passed to callback. this can be nil.
-- @return: it will return true it is fetching or already fetched. 
function Map3DSystem.App.Map.GetTileByID(tileID, callback, param1)
	if(tileID == nil or callback == nil)then
		return nil;
	end
	
	local msg = {
		tileID = tostring(tileID);
	};
	
	local args = {
		callback = callback,
		param1 = param1,
	};
	return paraworld.map.GetTileByID(msg,"paraworld",Map3DSystem.App.Map.GetTileByIDCallBack, args);
end

-- callback
function Map3DSystem.App.Map.GetTileByIDCallBack(msg,args)
	NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppDataPvd.lua");
	
	local tileInfo = nil;
	if(msg == nil)then
		tileInfo = Map3DApp.TileInfo:new();
	elseif(msg.errorcode ~= nil)then
		if(msg.info ~= nil)then
			log("WS GetTileByID failed,error code:"..msg.info.."\n");
		end
		tileInfo = Map3DApp.TileInfo:new();
	end

	tileInfo = Map3DApp.DataPvdHelper.ParseTileInfo(msg);

	if(args.callback)then
		args.callback(tileInfo, args.param1);
	end
end
