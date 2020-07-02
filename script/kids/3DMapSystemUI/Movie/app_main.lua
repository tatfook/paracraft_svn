--[[
Title: VideoRecorder app for Paraworld
Author(s): WangTian, original template by LiXizhi
Date: 2008/1/7
Desc: 

---++ File.PlayMovieScript
*example*
<verbatim>
	-- load a movie script, so that when movie pages are shown, they present this loaded movie script. 
	Map3DSystem.App.Commands.Call("File.PlayMovieScript", "temp/moviescript/mymoviescript.xml");
</verbatim>

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/app_main.lua");
------------------------------------------------------------
]]

-- requires

-- create class
commonlib.setfield("MyCompany.Apps.VideoRecorder", {});

-------------------------------------------
-- event handlers
-------------------------------------------

-- OnConnection method is the obvious point to place your UI (menus, mainbars, tool buttons) through which the user will communicate to the app. 
-- This method is also the place to put your validation code if you are licensing the add-in. You would normally do this before putting up the UI. 
-- If the user is not a valid user, you would not want to put the UI into the IDE.
-- @param app: the object representing the current application in the IDE. 
-- @param connectMode: type of Map3DSystem.App.ConnectMode. 
function MyCompany.Apps.VideoRecorder.OnConnection(app, connectMode)
	if(connectMode == Map3DSystem.App.ConnectMode.UI_Setup) then
		-- TODO: place your UI (menus,toolbars, tool buttons) through which the user will communicate to the app
		-- e.g. MainBar.AddItem(), MainMenu.AddItem().
		
		-- e.g. Create a VideoRecorder command link in the main menu 
		local commandName = "File.VideoRecorder";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "视频录像", icon = "Texture/3DMapSystem/common/film.png", });
			-- add command to mainmenu control, using the same folder as commandName. But you can use any folder you like
			local pos_category = commandName;
			-- insert before Profile.GroupLast
			local index = Map3DSystem.UI.MainMenu.GetItemIndex("File.GroupLast");
			-- add to front.
			command:AddControl("mainmenu", pos_category, index);
			
			commandName = "File.NewMovie";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "新建影片", icon = "Texture/3DMapSystem/AppIcons/CG_64.dds", });
				
			commandName = "File.MovieAssets";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "我选中的影片", icon = "Texture/3DMapSystem/AppIcons/assets_64.dds", });
			
			commandName = "File.MovieList";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "电影列表", icon = "Texture/3DMapSystem/AppIcons/VideoRecorder_64.dds", });	
			commandName = "File.MovieCameraTarget";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "摄像机属性", icon = "", });	
			commandName = "File.MovieOceanTarget";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "海洋属性", icon = "", });
			commandName = "File.MovieLandTarget";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "陆地属性", icon = "", });
			commandName = "File.MovieSkyTarget";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "天空属性", icon = "", });
			commandName = "File.MovieCaptionTarget";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "字幕属性", icon = "", });
			commandName = "File.MovieActorTarget";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "人物属性", icon = "", });
			commandName = "File.MovieBuildingTarget";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "建筑属性", icon = "", });
			commandName = "File.MoviePlantTarget";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "植物属性", icon = "", });
			commandName = "File.MovieSoundTarget";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "声音属性", icon = "", });
			commandName = "File.MovieEffectTarget";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "特效属性", icon = "", });
			commandName = "File.MovieControlTarget";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "控件属性", icon = "", });
			commandName = "File.CloseAllPropertyPanel";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "关闭所有属性面板", icon = "", });
			commandName = "File.ClearAll";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "清除所有", icon = "", });
			commandName = "File.GetPlayerFocus";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "获得人物焦点", icon = "", });
			commandName = "File.SetPlayerFocus";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "设置人物焦点", icon = "", });
			commandName = "File.CreateEntity";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "创建", icon = "", });
			commandName = "File.CreateEntityUnhook";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "取消创建钩子", icon = "", });
			commandName = "File.MoveEndUnHook";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "取消移动钩子", icon = "", });
		end
	else
		-- TODO: place the app's one time initialization code here.
		-- during one time init, its message handler may need to update the app structure with static integration points, 
		-- i.e. app.about, HomeButtonText, HomeButtonText, HasNavigation, NavigationButtonText, HasQuickAction, QuickActionText,  See app template for more information.
		-- e.g. 
		app.about =  "VideoRecorder"
		app.HideHomeButton = true;
		MyCompany.Apps.VideoRecorder.app = app; -- keep a reference
		
		local commandName = "File.PlayMovieScript";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "播放电影", icon = "Texture/3DMapSystem/common/film.png", });
		end		
	end
end

-- Receives notification that the Add-in is being unloaded.
function MyCompany.Apps.VideoRecorder.OnDisconnection(app, disconnectMode)
	if(disconnectMode == Map3DSystem.App.DisconnectMode.UserClosed or disconnectMode == Map3DSystem.App.DisconnectMode.WorldClosed)then
		-- TODO: remove all UI elements related to this application, since the IDE is still running. 
		
		-- e.g. remove command from mainbar
		local command = Map3DSystem.App.Commands.GetCommand("File.VideoRecorder");
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
function MyCompany.Apps.VideoRecorder.OnQueryStatus(app, commandName, statusWanted)
	if(statusWanted == Map3DSystem.App.CommandStatusWanted) then
		-- TODO: return an integer by adding values in Map3DSystem.App.CommandStatus.
		if(commandName == "File.VideoRecorder") then
			-- return enabled and supported 
			return (Map3DSystem.App.CommandStatus.Enabled + Map3DSystem.App.CommandStatus.Supported)
		end
	end
end

-- This is called when the command is invoked.The Exec is fired after the QueryStatus event is fired, assuming that the return to the statusOption parameter of QueryStatus is supported and enabled. 
-- This is the event where you place the actual code for handling the response to the user click on the command.
-- @param commandName: The name of the command to determine state for. Usually in the string format "Category.SubCate.Name".
function MyCompany.Apps.VideoRecorder.OnExec(app, commandName, params)
	NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieListPage.lua");
	local _, _, screenWidth, screenHeight = ParaUI.GetUIObject("root"):GetAbsPosition();
	if(commandName == "File.VideoRecorder") then
		NPL.load("(gl)script/kids/3DMapSystemUI/Movie/VideoRecorder.lua");
		local _wnd = app._wnd
		local _wndFrame = _wnd:GetWindowFrame();
		if(not _wndFrame) then
			_wndFrame = _wnd:CreateWindowFrame{
				icon = "Texture/3DMapSystem/common/film.png",
				text = "视频录像",
				directPosition = true,
					align = "_ct",
					x = -390/2,
					y = -430/2,
					width = 390,
					height = 430,
				ShowUICallback = Map3DSystem.Movie.VideoRecorder.Show,
			};
		end
		_wnd:ShowWindowFrame(true);
	elseif(commandName == "File.PlayMovieScript") then	
		if(type(params) == "string") then
			-- LXZ for LEIO:2008.11.6
			local filename = params;
			if (filename=="") then
				return
			end
			if(not string.match(filename, "[/\\]")) then
				-- this is a relative path, so we will search in the current world's movie folder
				filename = ParaWorld.GetWorldDirectory().."movies/"..filename;
			end	
			if(ParaIO.DoesFileExist(filename, true)) then
				NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MoviePlayerPage.lua");
				NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieScript.lua");
				NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieListPage.lua");
				NPL.load("(gl)script/ide/Animation/Motion/PreLoader.lua");
				NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieManager.lua");
				
				local moviescript = Map3DSystem.Movie.MovieScriptManager.GetScript(filename)
				if(moviescript)then
					CommonCtrl.Animation.Motion.PreLoader.DataBind(moviescript)
					CommonCtrl.Animation.Motion.PreLoader.CreateAllObjects()
					Map3DSystem.Movie.MoviePlayerPage.DoOpenWindow()
					local root_clip = moviescript:GetPlayMovieClips();
					Map3DSystem.Movie.MoviePlayerPage.DataBind(root_clip)
				end
			else
				commonlib.log("warning: File.PlayMovieScript can not find movie file: %s\n", filename)
			end	
		end
	elseif(commandName == "File.MovieList") then
		NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieEditPage.lua");
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url="script/kids/3DMapSystemUI/Movie/MovieListPage.html", name="MovieListPage", 
			app_key=app.app_key, 
			text = "电影列表",
			directPosition = true,
				align = "_ct",
				x = -360/2,
				y = -390/2,
				width = 360,
				height = 390,
			--bToggleShowHide = false,
			--DestroyOnClose = true,
		});
		Map3DSystem.App.Commands.Call("File.SetPlayerFocus");
	elseif(commandName == "File.MovieAssets") then	
		NPL.load("(gl)script/kids/3DMapSystemUI/Movie/MovieEditPage.lua");
		Map3DSystem.Movie.MovieEditPage.ReShow()
		Map3DSystem.App.Commands.Call("File.CloseAllPropertyPanel");
	elseif(commandName == "File.MovieCameraTarget") then	
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url="script/kids/3DMapSystemUI/Movie/PropertyPanel/CameraPanelPage.html", name="CameraPanelPage", 
			app_key=app.app_key, 
			isShowTitleBar = true, 
			isShowToolboxBar = false, 
			isShowStatusBar = false, 
			initialPosX = 800 - 4, 
			initialPosY = 175, 
			initialWidth = 220, -- initial width of the window client area
			initialHeight = 440, -- initial height of the window client area
			allowDrag = true,
			opacity = 90,
			icon = "Texture/3DMapSystem/AppIcons/VideoRecorder_64.dds; 0 0 48 48",
			text = "摄像机属性",
			style = CommonCtrl.WindowFrame.DefaultStyle,
			alignment = "Free", 
		});
	Map3DSystem.Movie.CameraPanelPage.DataBind(params)
	elseif(commandName == "File.MovieOceanTarget") then	
		Map3DSystem.App.Commands.Call("Env.ocean")		
		Map3DSystem.App.Env.OceanPage.DataBind(params)
	elseif(commandName == "File.MovieLandTarget") then	
		Map3DSystem.App.Commands.Call("Env.terrain")		
		Map3DSystem.App.Env.TerrainPage.DataBind(params)
	elseif(commandName == "File.MovieSkyTarget") then	
		Map3DSystem.App.Commands.Call("Env.sky")		
		Map3DSystem.App.Env.SkyPage.DataBind(params)
	elseif(commandName == "File.MovieCaptionTarget") then	
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url="script/kids/3DMapSystemUI/Movie/PropertyPanel/CaptionPanelPage.html", name="CaptionPanelPage", 
			app_key=app.app_key, 
			isShowTitleBar = true, 
			isShowToolboxBar = false, 
			isShowStatusBar = false, 
			initialPosX = 800 - 4, 
			initialPosY = 175, 
			initialWidth = 220, -- initial width of the window client area
			initialHeight = 440, -- initial height of the window client area
			allowDrag = true,
			opacity = 90,
			icon = "Texture/3DMapSystem/AppIcons/Discussion_64.dds; 0 0 48 48",
			text = "字幕属性",
			style = CommonCtrl.WindowFrame.DefaultStyle,
			alignment = "Free", 
		});		
		Map3DSystem.Movie.CaptionPanelPage.DataBind(params)
	elseif(commandName == "File.MovieActorTarget") then	
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url="script/kids/3DMapSystemUI/Movie/PropertyPanel/ActorPanelPage.html", name="ActorPanelPage", 
			app_key=app.app_key, 
			isShowTitleBar = true, 
			isShowToolboxBar = false, 
			isShowStatusBar = false, 
			initialPosX = 800 - 4, 
			initialPosY = 175, 
			initialWidth = 220, -- initial width of the window client area
			initialHeight = 440, -- initial height of the window client area
			allowDrag = true,
			opacity = 90,
			icon = "Texture/3DMapSystem/Creator/Level1_NC.png; 0 0 48 48",
			text = "人物属性",
			style = CommonCtrl.WindowFrame.DefaultStyle,
			alignment = "Free", 
		});
	Map3DSystem.Movie.ActorPanelPage.DataBind(params)
	elseif(commandName == "File.MovieBuildingTarget") then	
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url="script/kids/3DMapSystemUI/Movie/PropertyPanel/BuildingPanelPage.html", name="BuildingPanelPage", 
			app_key=app.app_key, 
			isShowTitleBar = true, 
			isShowToolboxBar = false, 
			isShowStatusBar = false, 
			initialPosX = 800 - 4, 
			initialPosY = 175, 
			initialWidth = 220, -- initial width of the window client area
			initialHeight = 440, -- initial height of the window client area
			allowDrag = true,
			opacity = 90,
			icon = "Texture/3DMapSystem/Creator/Level1_BCS.png; 0 0 48 48",
			text = "建筑属性",
			style = CommonCtrl.WindowFrame.DefaultStyle,
			alignment = "Free", 
		});		
		Map3DSystem.Movie.BuildingPanelPage.DataBind(params)
		elseif(commandName == "File.MoviePlantTarget") then	
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url="script/kids/3DMapSystemUI/Movie/PropertyPanel/PlantPanelPage.html", name="PlantPanelPage", 
			app_key=app.app_key, 
			isShowTitleBar = true, 
			isShowToolboxBar = false, 
			isShowStatusBar = false, 
			initialPosX = 800 - 4, 
			initialPosY = 175, 
			initialWidth = 220, -- initial width of the window client area
			initialHeight = 440, -- initial height of the window client area
			allowDrag = true,
			opacity = 90,
			icon = "Texture/3DMapSystem/Creator/NM_Trees.png; 0 0 48 48",
			text = "植物属性",
			style = CommonCtrl.WindowFrame.DefaultStyle,
			alignment = "Free", 
		});		
		Map3DSystem.Movie.PlantPanelPage.DataBind(params)
	elseif(commandName == "File.MovieSoundTarget") then	
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url="script/kids/3DMapSystemUI/Movie/PropertyPanel/SoundPanelPage.html", name="SoundPanelPage", 
			app_key=app.app_key, 
			isShowTitleBar = true, 
			isShowToolboxBar = false, 
			isShowStatusBar = false, 
			initialPosX = 800 - 4, 
			initialPosY = 175, 
			initialWidth = 220, -- initial width of the window client area
			initialHeight = 440, -- initial height of the window client area
			allowDrag = true,
			opacity = 90,
			icon = "Texture/3DMapSystem/AppIcons/Noname2.dds; 0 0 48 48",
			text = "声音属性",
			style = CommonCtrl.WindowFrame.DefaultStyle,
			alignment = "Free", 
		});		
		Map3DSystem.Movie.SoundPanelPage.DataBind(params)
	elseif(commandName == "File.MovieEffectTarget") then	
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url="script/kids/3DMapSystemUI/Movie/PropertyPanel/EffectPanelPage.html", name="EffectPanelPage", 
			app_key=app.app_key, 
			isShowTitleBar = true, 
			isShowToolboxBar = false, 
			isShowStatusBar = false, 
			initialPosX = 800 - 4, 
			initialPosY = 175, 
			initialWidth = 220, -- initial width of the window client area
			initialHeight = 440, -- initial height of the window client area
			allowDrag = true,
			opacity = 90,
			icon = "Texture/3DMapSystem/Creator/NM_Particle.png; 0 0 48 48",
			text = "特效属性",
			style = CommonCtrl.WindowFrame.DefaultStyle,
			alignment = "Free", 
		});		
		Map3DSystem.Movie.EffectPanelPage.DataBind(params)
	elseif(commandName == "File.MovieControlTarget") then	
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url="script/kids/3DMapSystemUI/Movie/PropertyPanel/ControlPanelPage.html", name="ControlPanelPage", 
			app_key=app.app_key, 
			isShowTitleBar = true, 
			isShowToolboxBar = false, 
			isShowStatusBar = false, 
			initialPosX = 800 - 4, 
			initialPosY = 175, 
			initialWidth = 220, -- initial width of the window client area
			initialHeight = 440, -- initial height of the window client area
			allowDrag = true,
			opacity = 90,
			icon = "Texture/3DMapSystem/AppIcons/Blueprint_64.dds; 0 0 48 48",
			text = "控件属性",
			style = CommonCtrl.WindowFrame.DefaultStyle,
			alignment = "Free", 
		});		
		Map3DSystem.Movie.ControlPanelPage.DataBind(params)
	elseif(commandName == "File.CloseAllPropertyPanel") then	
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			name="TerrainPage", app_key = Map3DSystem.App.Env.app.app_key, bShow = false});
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			name="OceanPage", app_key = Map3DSystem.App.Env.app.app_key, bShow = false});
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			name="SkyPage", app_key = Map3DSystem.App.Env.app.app_key, bShow = false});
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			name="CameraPanelPage", app_key = app.app_key, bShow = false});
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			name="ActorPanelPage", app_key = app.app_key, bShow = false});
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			name="SoundPanelPage", app_key = app.app_key, bShow = false});
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			name="BuildingPanelPage", app_key = app.app_key, bShow = false});
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			name="PlantPanelPage", app_key = app.app_key, bShow = false});
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			name="EffectPanelPage", app_key = app.app_key, bShow = false});
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			name="ControlPanelPage", app_key = app.app_key, bShow = false});
		NPL.load("(gl)script/kids/3DMapSystemUI/Creator/Main.lua");
		Map3DSystem.UI.Creator.Close();	
		Map3DSystem.App.Commands.Call("File.CreateEntityUnhook");
		Map3DSystem.App.Commands.Call("File.MoveEndUnHook");
		Map3DSystem.App.Commands.Call("File.GetPlayerFocus");
	elseif(commandName == "File.ClearAll") then	
		Map3DSystem.Movie.MovieListPage.ClearGlobalValue();
		Map3DSystem.Movie.MovieListPage.OnClickClose()
		Map3DSystem.Movie.MovieEditPage.OnClickClose(true)
		Map3DSystem.App.Commands.Call("File.CloseAllPropertyPanel");
	elseif(commandName == "File.GetPlayerFocus") then	
		local name = Map3DSystem.Movie.MovieListPage.PlayerName;
		if(name)then
			local player = ParaScene.GetCharacter(name)
			if(player:IsValid() == true) then 	
				player:ToCharacter():SetFocus();
			end
		end
	elseif(commandName == "File.SetPlayerFocus") then	
		local object = ParaScene.GetPlayer();
		if(object:IsValid())then
			Map3DSystem.Movie.MovieListPage.PlayerName = object.name;
		end
	elseif(commandName == "File.CreateEntity") then	
		Map3DSystem.Movie.MovieClipToolBar_Advance_Page.OnSelected(params.type,params.type2)
	elseif(commandName == "File.CreateEntityUnhook") then	
		local toolBar = Map3DSystem.Movie.MovieToolBar.GlobalHimself;
		if(toolBar)then
			toolBar:CreateEntityUnhook();
		end
	elseif(commandName == "File.MoveEndUnHook") then	
		local toolBar = Map3DSystem.Movie.MovieToolBar.GlobalHimself;
		if(toolBar)then
			toolBar:MoveEndUnHook();
		end
	elseif(app:IsHomepageCommand(commandName)) then
		MyCompany.Apps.VideoRecorder.GotoHomepage();
	elseif(app:IsNavigationCommand(commandName)) then
		MyCompany.Apps.VideoRecorder.Navigate();
	elseif(app:IsQuickActionCommand(commandName)) then	
		MyCompany.Apps.VideoRecorder.DoQuickAction();
	end
end

-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
function MyCompany.Apps.VideoRecorder.OnRenderBox(mcmlData)
end


-- called when the user wants to nagivate to the 3D world location relavent to this application
function MyCompany.Apps.VideoRecorder.Navigate()
end

-- called when user clicks to check out the homepage of this application. Homepage usually includes:
-- developer info, support, developer worlds information, app global news, app updates, all community user rating, active users, trade, currency transfer, etc. 
function MyCompany.Apps.VideoRecorder.GotoHomepage()
end

-- called when user clicks the quick action for this application. 
function MyCompany.Apps.VideoRecorder.DoQuickAction()
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
function MyCompany.Apps.VideoRecorder.MSGProc(window, msg)
	----------------------------------------------------
	-- application plug-in messages here
	----------------------------------------------------
	if(msg.type == Map3DSystem.App.MSGTYPE.APP_CONNECTION) then	
		-- Receives notification that the Add-in is being loaded.
		MyCompany.Apps.VideoRecorder.OnConnection(msg.app, msg.connectMode);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_DISCONNECTION) then	
		-- Receives notification that the Add-in is being unloaded.
		MyCompany.Apps.VideoRecorder.OnDisconnection(msg.app, msg.disconnectMode);

	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUERY_STATUS) then
		-- This is called when the command's availability is updated. 
		-- NOTE: this function returns a result. 
		msg.status = MyCompany.Apps.VideoRecorder.OnQueryStatus(msg.app, msg.commandName, msg.statusWanted);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_EXEC) then
		-- This is called when the command is invoked.
		MyCompany.Apps.VideoRecorder.OnExec(msg.app, msg.commandName, msg.params);
				
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_RENDER_BOX) then	
		-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
		MyCompany.Apps.VideoRecorder.OnRenderBox(msg.mcml);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_NAVIGATION) then
		-- Receives notification that the user wants to nagivate to the 3D world location relavent to this application
		MyCompany.Apps.VideoRecorder.Navigate();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_HOMEPAGE) then
		-- called when user clicks to check out the homepage of this application. 
		MyCompany.Apps.VideoRecorder.GotoHomepage();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUICK_ACTION) then
		-- called when user clicks the quick action for this application. 
		MyCompany.Apps.VideoRecorder.DoQuickAction();

	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		window:DestroyWindowFrame();
	end
end