--[[
Title: Chat app for Paraworld
Author(s): WangTian, original template by LiXizhi
Date: 2008/1/9, Added Summon mode 2008.7.18 lxz
Desc: chatting via jabber

---++ Summon Mode
More information, please see NPL.load("(gl)script/kids/3DMapSystemUI/Chat/SummonMode.lua");
<verbatim>
	-- activate summon mode
	Map3DSystem.App.Commands.Call("Profile.Chat.Summon");
	-- block a summoned agent
	Map3DSystem.App.Commands.Call("Profile.Chat.BlockAgent", {JID = JID});
</verbatim>

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Chat/app_main.lua");
------------------------------------------------------------
]]

-- requires

-- create class
local Chat = commonlib.gettable("Map3DSystem.App.Chat");


-------------------------------------------
-- event handlers
-------------------------------------------

-- OnConnection method is the obvious point to place your UI (menus, mainbars, tool buttons) through which the user will communicate to the app. 
-- This method is also the place to put your validation code if you are licensing the add-in. You would normally do this before putting up the UI. 
-- If the user is not a valid user, you would not want to put the UI into the IDE.
-- @param app: the object representing the current application in the IDE. 
-- @param connectMode: type of Map3DSystem.App.ConnectMode. 
function Map3DSystem.App.Chat.OnConnection(app, connectMode)
	if(connectMode == Map3DSystem.App.ConnectMode.UI_Setup) then
		-- TODO: place your UI (menus,toolbars, tool buttons) through which the user will communicate to the app
		-- e.g. MainBar.AddItem(), MainMenu.AddItem().
		
		-- Create an add contact command link in the taskbar
		local commandName = "Profile.Chat.AddContact";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "添加联系人", 
				icon = "Texture/3DMapSystem/common/user_add.png", 
				});
			
			commandName = "Profile.Chat.AddContactImmediate";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "立即添加联系人", 
				icon = "Texture/3DMapSystem/common/user_add.png", 
				});
				
			commandName = "Profile.Chat.ChatWithContactImmediate";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "立即和联系人聊天", 
				icon = "Texture/3DMapSystem/common/user_add.png", 
				});
		end
		
		NPL.load("(gl)script/kids/3DMapSystemUI/Chat/ChannelManager.lua");
		Map3DSystem.App.Chat.ChannelManager.OnUISetup();
	else
		-- TODO: place the app's one time initialization code here.
		-- during one time init, its message handler may need to update the app structure with static integration points, 
		-- i.e. app.about, HomeButtonText, HomeButtonText, HasNavigation, NavigationButtonText, HasQuickAction, QuickActionText,  See app template for more information.
		
		-- e.g. 
		Map3DSystem.App.Chat.app = app; -- keep a reference
		app.about =  "chatting via jabber"
		app.HideHomeButton = true;
		app.Title = "聊天";
		app.icon = "Texture/3DMapSystem/AppIcons/chat_64.dds"
		app.SubTitle = "即时通讯;传送到朋友身边";
		
		-- Create a Chat main window command link
		local commandName = "Profile.Chat.MainWnd";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "聊天主窗口", 
				icon = "Texture/3DMapSystem/common/chat.png", 
				});
		end
		
		local commandName = "Profile.Chat.Summon";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "召唤玩家", 
				icon = "Texture/3DMapSystem/common/transmit.png", 
				});
		end
		
		local commandName = "Profile.Chat.QuickChat";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "群聊", 
				icon = "Texture/3DMapSystem/common/comment.png", 
				});
		end
		
		local commandName = "Profile.Chat.BlockAgent";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "屏蔽替身", 
				icon = "Texture/3DMapSystem/common/Trash.png", 
				});
		end
		
		-- init the channel
		NPL.load("(gl)script/kids/3DMapSystemUI/Chat/ChannelManager.lua");
		Map3DSystem.App.Chat.ChannelManager.Init();
	end
end

-- Receives notification that the Add-in is being unloaded.
function Map3DSystem.App.Chat.OnDisconnection(app, disconnectMode)
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
function Map3DSystem.App.Chat.OnQueryStatus(app, commandName, statusWanted)
	if(statusWanted == Map3DSystem.App.CommandStatusWanted) then
	end
end

-- This is called when the command is invoked.The Exec is fired after the QueryStatus event is fired, assuming that the return to the statusOption parameter of QueryStatus is supported and enabled. 
-- This is the event where you place the actual code for handling the response to the user click on the command.
-- @param commandName: The name of the command to determine state for. Usually in the string format "Category.SubCate.Name".
function Map3DSystem.App.Chat.OnExec(app, commandName, params)
	
	if(commandName == "Profile.Chat.MainWnd") then
		-- init the chat
		if(Map3DSystem.UI.AppDesktop.CheckUser()) then
			NPL.load("(gl)script/kids/3DMapSystemUI/Chat/MainWnd2.lua");
			Map3DSystem.App.Chat.MainWnd.ShowMainWnd();
		end
	elseif(commandName == "Profile.Chat.Summon") then	
		-- adde lxz 2008.7.16
		NPL.load("(gl)script/kids/3DMapSystemUI/Chat/SummonMode.lua");
		Map3DSystem.App.Chat.SummonMode.Activate()

	elseif(commandName == "Profile.Chat.BlockAgent") then	
		-- adde lxz 2008.7.16
		NPL.load("(gl)script/kids/3DMapSystemUI/Chat/SummonMode.lua");
		Map3DSystem.App.Chat.SummonMode.BlockAgent(params.JID)

	elseif(commandName == "Profile.Chat.AddContact") then
		-- removed lxz 2008.6.19
		---- launch the chat main window
		--if(Map3DSystem.App.Chat.IsInit == nil) then
			--NPL.load("(gl)script/kids/3DMapSystemUI/Chat/Main.lua");
			--Map3DSystem.App.Chat.OneTimeInit();
			--Map3DSystem.App.Chat.IsInit = true;
		--end
		
		NPL.load("(gl)script/kids/3DMapSystemUI/Chat/MainWnd2.lua");
		Map3DSystem.App.Chat.MainWnd.ShowMainWnd(true);
		
		Map3DSystem.App.Chat.MainWnd.ToggleAddContactPanel()
		
	elseif(commandName == "Profile.Chat.AddContactImmediate") then
		-- add contact immediate
		if(not params.JID and params.uid) then
			Map3DSystem.App.profiles.ProfileManager.GetJID(params.uid, function(jid)
				NPL.load("(gl)script/kids/3DMapSystemUI/Chat/MainWnd2.lua");
				Map3DSystem.App.Chat.MainWnd.AddContactImmediate(jid);
			end)
		elseif(params.JID) then
			NPL.load("(gl)script/kids/3DMapSystemUI/Chat/MainWnd2.lua");
			Map3DSystem.App.Chat.MainWnd.AddContactImmediate(params.JID);
		end	
		NPL.load("(gl)script/kids/3DMapSystemUI/Chat/MainWnd2.lua");
		
	elseif(commandName == "Profile.Chat.ChatWithContactImmediate") then
		-- chat with contact immediate
		if(not params.JID and (params.uid or params.nid)) then
			Map3DSystem.App.profiles.ProfileManager.GetJID((params.uid or params.nid), function(jid)
				NPL.load("(gl)script/kids/3DMapSystemUI/Chat/MainWnd2.lua");
				Map3DSystem.App.Chat.MainWnd.ChatWithContactImmediate(jid);
			end)
		elseif(params.JID) then
			NPL.load("(gl)script/kids/3DMapSystemUI/Chat/MainWnd2.lua");
			Map3DSystem.App.Chat.MainWnd.ChatWithContactImmediate(params.JID);
		end	
		
	elseif(commandName == "Profile.Chat.QuickChat") then	
		-- TODO: 2008.6.22 lxz for andy: toggle group quick chat and BBS window. This is similar to Enter key pressed. The status bar also contains a link to this command. 
		-- This may be called from other applications, so both quick chat and BBS should have zorder 1 and the window should be very transparent. 
		
		-- show or hide QuickChatPage
		NPL.load("(gl)script/kids/3DMapSystemUI/Chat/QuickChatPage.lua");
		if(params and params.bShow==false) then
			-- hide the window
			--Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name = "QuickChatPage", app_key = app.app_key, bShow = false,});
			
			-- hide the chat input
			Map3DSystem.App.Chat.QuickChatPage.OnHideInput();
		else
			-- call below to show the window
			Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
				url = "script/kids/3DMapSystemUI/Chat/QuickChatPage.html", name = "QuickChatPage", 
				app_key = app.app_key, 
				isShowTitleBar = false,
				isShowToolboxBar = false,
				isShowStatusBar = false,
				initialWidth = 422,
				initialHeight = 206,
				initialPosX = 0, 
				initialPosY = 32, -- added by LXZ, 2008.8.16. to give it a lift on left bottom. 
				isPinned = true,
				style = CommonCtrl.WindowFrame.DefaultPanel,
				alignment = "LeftBottom", -- Free|Left|Right|Bottom
				allowDrag = true,
				--bToggleShowHide = true, -- toggle show and hide
			});
			
			Map3DSystem.PushState({name = "QuickChatPage", OnEscKey = Map3DSystem.App.Chat.QuickChatPage.OnHideInput});
		end
		
		Map3DSystem.App.Chat.QuickChatPage.OnShowInput();
		Map3DSystem.App.Chat.QuickChatPage.UpdateContact();
		
	elseif(string.find(commandName, "Profile.Chat.ToggleChatTab")) then
		local ID = string.sub(commandName, string.len("Profile.Chat.ToggleChatTab.") + 1, -1);
		Map3DSystem.App.Chat.ChatWnd.OnToggleChatTab(ID);
	elseif(app:IsHomepageCommand(commandName)) then
		Map3DSystem.App.Chat.GotoHomepage();
	elseif(app:IsNavigationCommand(commandName)) then
		Map3DSystem.App.Chat.Navigate();
	elseif(app:IsQuickActionCommand(commandName)) then	
		Map3DSystem.App.Chat.DoQuickAction();
	end
end

-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
function Map3DSystem.App.Chat.OnRenderBox(mcmlData)
end


-- called when the user wants to nagivate to the 3D world location relavent to this application
function Map3DSystem.App.Chat.Navigate()
end

-- called when user clicks to check out the homepage of this application. Homepage usually includes:
-- developer info, support, developer worlds information, app global news, app updates, all community user rating, active users, trade, currency transfer, etc. 
function Map3DSystem.App.Chat.GotoHomepage()
end

-- called when user clicks the quick action for this application. 
function Map3DSystem.App.Chat.DoQuickAction()
end


function Map3DSystem.App.Chat.OnActivateDesktop()
	local app = Map3DSystem.App.Assets.app;
	
	local commandName = "Profile.Chat.MainWnd";
	local command = Map3DSystem.App.Commands.GetCommand(commandName);
	if(command) then
		Map3DSystem.UI.AppTaskBar.AddCommand(command, "toolbar.ChatMainWnd")
		-- call the main window as default window on active desktop
		command:Call();
	end
	
	local commandName = "Profile.Chat.AddContact";
	local command = Map3DSystem.App.Commands.GetCommand(commandName);
	if(command) then
		Map3DSystem.UI.AppTaskBar.AddCommand(command, "toolbar.ChatAddContact")
	end
	
end

-- 
function Map3DSystem.App.Chat.OnDeactivateDesktop()
	
end

function Map3DSystem.App.Chat.OnWorldLoad()
end

function Map3DSystem.App.Chat.OnLoadChat()
	local app = Map3DSystem.App.Chat.app;
	
	if(Map3DSystem.App.Chat.IsInit ~= true) then
		-- not logged in
	else
		local commandName = "Profile.Chat.MainWnd";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command) then
			-- TODO: tricky call the main window twice to allow contact update
			command:Call();
			command:Call();
		end
	end
	
	-- link to the channel of the current world
	local worldpath = ParaWorld.GetWorldDirectory();
	Map3DSystem.App.Chat.ChannelManager.AddChannel("Channel_World_"..worldpath, "当前世界");
	
	-- automaticly switch to the public channel
	Map3DSystem.App.Chat.ChannelManager.ChangeFocusChannel("Channel_Public");
	
	-- automaticly call quick chat window
	Map3DSystem.App.Commands.Call("Profile.Chat.QuickChat");
	-- hide input for the world load show, avoiding WASD controls to be typed into the textbox
	Map3DSystem.App.Chat.QuickChatPage.OnHideInput();
end

function Map3DSystem.App.Chat.OnWorldClosed()
	NPL.load("(gl)script/kids/3DMapSystemUI/Chat/MainWnd2.lua");
	Map3DSystem.App.Chat.MainWnd.DestroyMainWnd();
	
	-- drop link to the channel of the current world
	local worldpath = ParaWorld.GetWorldDirectory();
	if(worldpath ~= "_emptyworld/") then -- omit the default world "_emptyworld/" loaded at start up
		Map3DSystem.App.Chat.ChannelManager.RemoveChannel("Channel_World_"..worldpath);
	end
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
function Map3DSystem.App.Chat.MSGProc(window, msg)
	----------------------------------------------------
	-- application plug-in messages here
	----------------------------------------------------
	if(msg.type == Map3DSystem.App.MSGTYPE.APP_CONNECTION) then	
		-- Receives notification that the Add-in is being loaded.
		Map3DSystem.App.Chat.OnConnection(msg.app, msg.connectMode);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_DISCONNECTION) then	
		-- Receives notification that the Add-in is being unloaded.
		Map3DSystem.App.Chat.OnDisconnection(msg.app, msg.disconnectMode);

	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUERY_STATUS) then
		-- This is called when the command's availability is updated. 
		-- NOTE: this function returns a result. 
		msg.status = Map3DSystem.App.Chat.OnQueryStatus(msg.app, msg.commandName, msg.statusWanted);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_EXEC) then
		-- This is called when the command is invoked.
		Map3DSystem.App.Chat.OnExec(msg.app, msg.commandName, msg.params);
				
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_RENDER_BOX) then	
		-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
		Map3DSystem.App.Chat.OnRenderBox(msg.mcml);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_NAVIGATION) then
		-- Receives notification that the user wants to nagivate to the 3D world location relavent to this application
		Map3DSystem.App.Chat.Navigate();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_HOMEPAGE) then
		-- called when user clicks to check out the homepage of this application. 
		Map3DSystem.App.Chat.GotoHomepage();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUICK_ACTION) then
		-- called when user clicks the quick action for this application. 
		Map3DSystem.App.Chat.DoQuickAction();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_ACTIVATE_DESKTOP) then
		Map3DSystem.App.Chat.OnActivateDesktop();
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_DEACTIVATE_DESKTOP) then
		Map3DSystem.App.Chat.OnDeactivateDesktop();
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_WORLD_LOAD) then
		-- called whenever a new world is loaded (just before the 3d scene is enabled, yet after world data is loaded). 
		Map3DSystem.App.Chat.OnWorldLoad();
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_WORLD_CLOSING) then
		-- called whenever a world is being closed.
		Map3DSystem.App.Chat.OnWorldClosed();

	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		
	end
end