--[[
Title: The default desktop app
Author(s): LiXizhi
Date: 2008/5/15
Desc: Default in-game user desktop app, which has by default most common functions on its application exclusive desktop. 
It is also customizable and can be extended via desktop widgets. 

---++ show desktop welcome page.
This is usually bind to F1 key
Map3DSystem.App.Commands.Call("Profile.MyDesktop.ShowWelcomePage")

db registration insert script
INSERT INTO apps VALUES (NULL, 'MyDesktop_GUID', 'MyDesktop', '1.0.0', 'http://www.paraengine.com/apps/MyDesktop_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemUI/MyDesktop/IP.xml', '', 'script/kids/3DMapSystemUI/MyDesktop/app_main.lua', 'Map3DSystem.App.MyDesktop.MSGProc', 1);
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MyDesktop/app_main.lua");
------------------------------------------------------------
]]
local L = CommonCtrl.Locale("ParaWorld");


-- requires

-- create class
commonlib.setfield("Map3DSystem.App.MyDesktop", {});

-------------------------------------------
-- event handlers
-------------------------------------------

-- OnConnection method is the obvious point to place your UI (menus, mainbars, tool buttons) through which the user will communicate to the app. 
-- This method is also the place to put your validation code if you are licensing the add-in. You would normally do this before putting up the UI. 
-- If the user is not a valid user, you would not want to put the UI into the IDE.
-- @param app: the object representing the current application in the IDE. 
-- @param connectMode: type of Map3DSystem.App.ConnectMode. 
function Map3DSystem.App.MyDesktop.OnConnection(app, connectMode)
	if(connectMode == Map3DSystem.App.ConnectMode.UI_Setup) then
		-- enable autotips by default
		autotips.Show(true);
		
		local commandName = "Profile.ToggleAutotips";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand({
				name = commandName, 
				app_key = app.app_key, 
				ButtonText = L"显示提示",
				tooltip=L"显示/隐藏提示",
				icon = "Texture/3DMapSystem/common/bell.png", 
			});
		end	
			
		-- all most all status bar icons are added via this applications, to keep things easy to manage. 
		-- in case we change the mind whether this or that needs to be a status bar icon or not. 
		Map3DSystem.UI.AppTaskBar.StatusBar.AddTask({name = "AutoLobbyPage",icon = "Texture/3DMapSystem/common/transmit.png", 
			tooltip = L"当前世界服务器状态", commandName = "File.AutoLobbyPage"});
		
		Map3DSystem.UI.AppTaskBar.StatusBar.AddTask({name = "ToggleChat",icon = "Texture/3DMapSystem/common/chat.png", 
			tooltip = L"显示/隐藏群体聊天窗口(Enter键)", commandName = "Profile.Chat.QuickChat"});
			
		Map3DSystem.UI.AppTaskBar.StatusBar.AddTask({name = "HomePage",icon = "Texture/3DMapSystem/common/house.png", 
			tooltip = L"我的首页", commandName = "Profile.HomePage"});
		
		Map3DSystem.UI.AppTaskBar.StatusBar.AddTask({name = "MiniMap",icon = "Texture/3DMapSystem/common/eye.png", 
			tooltip = L"显示/隐藏小地图: 包括玩家和NPC位置等", commandName = "Profile.MiniMap"});
					
		Map3DSystem.UI.AppTaskBar.StatusBar.AddTask({name = "ToggleAutotips",icon = "Texture/3DMapSystem/common/bell.png", 
			tooltip = L"显示/隐藏提示文字", commandName = "Profile.ToggleAutotips"});
		
		Map3DSystem.UI.AppTaskBar.StatusBar.AddTask({name = "HelpPage",icon = "Texture/3DMapSystem/common/help_16.png", 
			tooltip = L"显示当前应用程序帮助(F1键)", commandName = "File.Help"});
			
		Map3DSystem.UI.AppTaskBar.StatusBar.AddTask({name = "ScreenShot",icon = "Texture/3DMapSystem/common/page_white_camera.png", 
			tooltip = L"显示截图(F11键)", commandName = "File.ScreenShot"});
			
		Map3DSystem.UI.AppTaskBar.StatusBar.AddTask({name = "SaveWorld",icon = "Texture/3DMapSystem/common/disk.png", 
			tooltip = L"保存或发布世界", commandName = "File.SaveAndPublish"});
			
		Map3DSystem.UI.AppTaskBar.StatusBar.AddTask({name = "SubmitBug",icon = "Texture/3DMapSystem/common/bug.png", 
			tooltip = L"发送Bug或建议", commandName = "File.SubmitBug"});	
		
	else
		app.about = "Default in-game user desktop"
		Map3DSystem.App.MyDesktop.app = app; 
		app.Title = L"缺省桌面";
		app.icon = "Texture/3DMapSystem/AppIcons/Desktop_64.dds"
		app.SubTitle = L"我的桌面";
		app:SetHelpPage("WelcomePage.html");
		app.HideHomeButton = true;
		
		local commandName = "player.togglefly";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand({
				name = commandName, 
				app_key = app.app_key, 
				ButtonText = L"飞翔(F)",
				tooltip=L"切换飞翔和着陆状态(F键)",
				icon = "Texture/3DMapSystem/common/fly.png", 
			});
			
			commandName = "player.togglerun";
			command = Map3DSystem.App.Commands.AddNamedCommand({
				name = commandName, 
				app_key = app.app_key, 
				ButtonText = L"跑步(R)",
				tooltip=L"切换跑步和走路状态(R键)",
				icon = "Texture/3DMapSystem/common/feet.png", 
			});
		end
		
	end
end

-- Receives notification that the Add-in is being unloaded.
function Map3DSystem.App.MyDesktop.OnDisconnection(app, disconnectMode)
end

-- This is called when the command's availability is updated
-- When the user clicks a command (menu or mainbar button), the QueryStatus event is fired. 
-- The QueryStatus event returns the current status of the specified named command, whether it is enabled, disabled, 
-- or hidden in the CommandStatus parameter, which is passed to the msg by reference (or returned in the event handler). 
-- @param commandName: The name of the command to determine state for. Usually in the string format "Category.SubCate.Name".
-- @param statusWanted: what status of the command is queried. it is of type Map3DSystem.App.CommandStatusWanted
-- @return: returns according to statusWanted. it may return an integer by adding values in Map3DSystem.App.CommandStatus.
function Map3DSystem.App.MyDesktop.OnQueryStatus(app, commandName, statusWanted)
	if(statusWanted == Map3DSystem.App.CommandStatusWanted) then
		return (Map3DSystem.App.CommandStatus.Enabled + Map3DSystem.App.CommandStatus.Supported)
	end
end

local OriginalDensity = nil;
-- This is called when the command is invoked.The Exec is fired after the QueryStatus event is fired, assuming that the return to the statusOption parameter of QueryStatus is supported and enabled. 
-- This is the event where you place the actual code for handling the response to the user click on the command.
-- @param commandName: The name of the command to determine state for. Usually in the string format "Category.SubCate.Name".
function Map3DSystem.App.MyDesktop.OnExec(app, commandName, params)
	if(commandName == "player.togglefly") then
		-- 'F' key to toggle flying
		-- toggle flying state by setting density to 0. 
		if(Map3DSystem.App.Commands.GetCommand("Profile.Aries.ToggleFly")) then
			-- call the aries fly command
			Map3DSystem.App.Commands.Call("Profile.Aries.ToggleFly");
			return;
		end
		local player = ParaScene.GetPlayer();
		if(player:GetDensity()>0.5) then
			if(Map3DSystem.User.CheckRight("CanFly")) then
				-- make it light to fly
				OriginalDensity = player:GetDensity();
				player:SetDensity(0);
				-- jump up a little
				player:ToCharacter():AddAction(action_table.ActionSymbols.S_JUMP_START); 
				
				autotips.AddTips("flying", L"您进入了飞行状态. 请按 F 键返回重力状态")
			end	
		elseif(player:GetDensity() == 0 and OriginalDensity) then
			-- restore to original density
			player:SetDensity(OriginalDensity);
			autotips.AddTips("flying", nil)
		end
	elseif(commandName == "player.togglerun") then
		-- 'R' key to toggle running
		local char = ParaScene.GetPlayer():ToCharacter();
		if(char:IsValid())then
			if(char:WalkingOrRunning() ==true) then
				char:AddAction(action_table.ActionSymbols.S_ACTIONKEY, action_table.ActionKeyID.TOGGLE_TO_RUN);
				autotips.AddTips("running", nil)
			else
				char:AddAction(action_table.ActionSymbols.S_ACTIONKEY, action_table.ActionKeyID.TOGGLE_TO_WALK);
				autotips.AddTips("running", L"您进入了行走模式. 请按 R 键返回跑步模式")
			end	
		end
	elseif(commandName == "Profile.MyDesktop.ShowWelcomePage") then	
		-- force showing welcome page. 
		Map3DSystem.App.Commands.Call("File.WelcomePage", {url="script/kids/3DMapSystemUI/MyDesktop/WelcomePage.html", bShow=true})
	elseif(commandName == "Profile.ToggleAutotips") then
		local bShow = autotips.Show();
		ParaScene.GetAttributeObject():SetField("ShowHeadOnDisplay", bShow);
	elseif(app:IsHomepageCommand(commandName)) then
		Map3DSystem.App.MyDesktop.GotoHomepage();
	elseif(app:IsNavigationCommand(commandName)) then
		Map3DSystem.App.MyDesktop.Navigate();
	elseif(app:IsQuickActionCommand(commandName)) then	
		Map3DSystem.App.MyDesktop.DoQuickAction();
	end
end

-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
function Map3DSystem.App.MyDesktop.OnRenderBox(mcmlData)
end

-- called when the user wants to nagivate to the 3D world location relavent to this application
function Map3DSystem.App.MyDesktop.Navigate()
end

-- called when user clicks to check out the homepage of this application. Homepage usually includes:
-- developer info, support, developer worlds information, app global news, app updates, all community user rating, active users, trade, currency transfer, etc. 
function Map3DSystem.App.MyDesktop.GotoHomepage()
end

-- called when user clicks the quick action for this application. 
function Map3DSystem.App.MyDesktop.DoQuickAction()
end

-- Add terrain, sky and ocean button to the toolbar. 
function Map3DSystem.App.MyDesktop.OnActivateDesktop()
	Map3DSystem.UI.AppTaskBar.AddCommand("Profile.CCS.AnimationPage")
	Map3DSystem.UI.AppTaskBar.AddCommand("player.togglefly")
	Map3DSystem.UI.AppTaskBar.AddCommand("player.togglerun")
	Map3DSystem.UI.AppTaskBar.AddCommand("Profile.Chat.Summon")
	--Map3DSystem.UI.AppTaskBar.AddCommand("File.ScreenShot")
	Map3DSystem.UI.AppTaskBar.AddCommand("Profile.MyDesktop.ShowWelcomePage")
	Map3DSystem.App.Commands.Call("File.WelcomePage", {url="script/kids/3DMapSystemUI/MyDesktop/WelcomePage.html"})

	autotips.AddIdleTips(L"按住鼠标左键不放移动鼠标,可以改变视角")	
	autotips.AddIdleTips(L"按住鼠标右键不放移动鼠标,同时按住W,A,S或D键可以控制人物")
	autotips.AddIdleTips(L"反复的按Space键,可以跳得更高")
	autotips.AddIdleTips(L"按Enter键,打开对话面板")
	autotips.AddIdleTips(L"点击左下角的按钮, 可以切换到其他应用程序桌面")
	autotips.AddIdleTips(L"通过右下角的许多按钮, 你可以找到帕拉巫世界中的其他居民")
	if(Map3DSystem.User.HasRight("Teleport")) then
		autotips.AddIdleTips(L"点击鼠标中键可以瞬移")	
	end
	
	-- show the mini map at world load
	Map3DSystem.App.Commands.Call("Profile.MiniMap");
	
	-- load chat wnd
	if(Map3DSystem.App.Chat) then
		Map3DSystem.App.Chat.OnLoadChat();
	end	
end

-- 
function Map3DSystem.App.MyDesktop.OnDeactivateDesktop()
	
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
function Map3DSystem.App.MyDesktop.MSGProc(window, msg)
	----------------------------------------------------
	-- application plug-in messages here
	----------------------------------------------------
	if(msg.type == Map3DSystem.App.MSGTYPE.APP_CONNECTION) then	
		-- Receives notification that the Add-in is being loaded.
		Map3DSystem.App.MyDesktop.OnConnection(msg.app, msg.connectMode);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_DISCONNECTION) then	
		-- Receives notification that the Add-in is being unloaded.
		Map3DSystem.App.MyDesktop.OnDisconnection(msg.app, msg.disconnectMode);

	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUERY_STATUS) then
		-- This is called when the command's availability is updated. 
		-- NOTE: this function returns a result. 
		msg.status = Map3DSystem.App.MyDesktop.OnQueryStatus(msg.app, msg.commandName, msg.statusWanted);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_EXEC) then
		-- This is called when the command is invoked.
		Map3DSystem.App.MyDesktop.OnExec(msg.app, msg.commandName, msg.params);
				
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_RENDER_BOX) then	
		-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
		Map3DSystem.App.MyDesktop.OnRenderBox(msg.mcml);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_NAVIGATION) then
		-- Receives notification that the user wants to nagivate to the 3D world location relavent to this application
		Map3DSystem.App.MyDesktop.Navigate();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_HOMEPAGE) then
		-- called when user clicks to check out the homepage of this application. 
		Map3DSystem.App.MyDesktop.GotoHomepage();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUICK_ACTION) then
		-- called when user clicks the quick action for this application. 
		Map3DSystem.App.MyDesktop.DoQuickAction();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_ACTIVATE_DESKTOP) then
		Map3DSystem.App.MyDesktop.OnActivateDesktop();
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_DEACTIVATE_DESKTOP) then
		Map3DSystem.App.MyDesktop.OnDeactivateDesktop();
		
		
	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		
	end
end