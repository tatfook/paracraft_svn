--[[
Title: profiles app for Paraworld
Author(s): LiXizhi, WangTian
Date: 2008/2/14
Desc: 
Managing all user profiles (mcml) and general privacy settings. A profile contains basic user info, friends(social graph), app boxes(avatar, map lands, ...), etc

---++ App Commands
*example*
<verbatim>
	-- Show a window for a given user to be able to download its world and join it. 
	Map3DSystem.App.Commands.Call("Profile.VisitWorld", {uid = "loggedinuser"});
	-- show home page for current user
	Map3DSystem.App.Commands.Call("Profile.HomePage");
	-- friends pages
	Map3DSystem.App.Commands.Call("Friends.AllFriends");
	Map3DSystem.App.Commands.Call("Friends.FriendsFinder");
	Map3DSystem.App.Commands.Call("Friends.InviteFriends");
</verbatim>

db registration insert script
INSERT INTO apps VALUES (NULL, 'profiles_GUID', 'profiles', '1.0.0', 'http://www.paraengine.com/apps/profiles_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemApp/profiles/IP.xml', '', 'script/kids/3DMapSystemApp/profiles/app_main.lua', 'Map3DSystem.App.profiles.MSGProc', 1);
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/profiles/app_main.lua");
------------------------------------------------------------
]]

local L = CommonCtrl.Locale("ParaWorld");

-- requires

-- create class
local profiles = commonlib.gettable("Map3DSystem.App.profiles");

-------------------------------------------
-- public method
-------------------------------------------

-- Finding friends by providing a list of email, IM account. 
function Map3DSystem.App.profiles.ShowFriendsFinder()
	-- TODO: show FriendsFinder.html
end

-- Viewing all friends of a given user (or the current user) in a standalone window 
function Map3DSystem.App.profiles.ViewFriends(profile)
	-- TODO: show FriendsPage.html
end

-- Invite friends by providing (or importing) a list of email addresses and a user-typed message. 
function Map3DSystem.App.profiles.ShowInviteFriendsWnd()
	-- TODO: show InviteFriends.html
end

-------------------------------------------
-- event handlers
-------------------------------------------

-- OnConnection method is the obvious point to place your UI (menus, mainbars, tool buttons) through which the user will communicate to the app. 
-- This method is also the place to put your validation code if you are licensing the add-in. You would normally do this before putting up the UI. 
-- If the user is not a valid user, you would not want to put the UI into the IDE.
-- @param app: the object representing the current application in the IDE. 
-- @param connectMode: type of Map3DSystem.App.ConnectMode. 
function Map3DSystem.App.profiles.OnConnection(app, connectMode)
	if(connectMode == Map3DSystem.App.ConnectMode.UI_Setup) then
		-- TODO: place your UI (menus,toolbars, tool buttons) through which the user will communicate to the app
		-- e.g. MainBar.AddItem(), MainMenu.AddItem().
		
		-- e.g. Create a profiles command link in the main menu 
		local commandName = "Profile.HomePage";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			commandName = "Profile.HomePage";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = L"我的首页", icon = "Texture/3DMapSystem/common/house.png", });
			-- add command to mainmenu control, using the same folder as commandName. But you can use any folder you like
			local pos_category = commandName;
			command:AddControl("mainmenu", pos_category, 1);
			
			commandName = "Profile.EditProfile";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = L"个人档案", icon = "Texture/3DMapSystem/common/userInfo.png", });
			-- add command to mainmenu control, using the same folder as commandName. But you can use any folder you like
			local pos_category = commandName;
			command:AddControl("mainmenu", pos_category, 2);
			
			commandName = "Profile.ViewProfile";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = L"个人档案", icon = "Texture/3DMapSystem/common/userInfo.png", });
			-- add command to mainmenu control, using the same folder as commandName. But you can use any folder you like
			local pos_category = commandName;
			
			commandName = "Profile.VisitWorld";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = L"个人世界", icon = "Texture/3DMapSystem/common/world_go.png", });
			-- add command to mainmenu control, using the same folder as commandName. But you can use any folder you like
			local pos_category = commandName;
			command:AddControl("mainmenu", pos_category, 3);
			
			commandName = "Profile.PrivacySettings";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = L"隐私管理", icon = "Texture/3DMapSystem/common/report.png",});
			-- add command to mainmenu control, using the same folder as commandName. But you can use any folder you like
			pos_category = commandName;
			-- add to front.
			command:AddControl("mainmenu", pos_category, 4);
			
			--
			-- friends related. 
			--
			commandName = "Friends.AllFriends";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = L"我的好友", icon = "Texture/3DMapSystem/common/user.png",});
			-- add command to mainmenu control, using the same folder as commandName. But you can use any folder you like
			pos_category = commandName;
			-- add to front.
			command:AddControl("mainmenu", pos_category, 1);
			
			--commandName = "Friends.Online";
			--command = Map3DSystem.App.Commands.AddNamedCommand(
				--{name = commandName,app_key = app.app_key, ButtonText = "在线的", });
			---- add command to mainmenu control, using the same folder as commandName. But you can use any folder you like
			--pos_category = commandName;
			---- before group 2
			--command:AddControl("mainmenu", pos_category);
			--
			--commandName = "Friends.RecentUpdated";
			--command = Map3DSystem.App.Commands.AddNamedCommand(
				--{name = commandName,app_key = app.app_key, ButtonText = "最近更新的", });
			---- add command to mainmenu control, using the same folder as commandName. But you can use any folder you like
			--pos_category = commandName;
			---- before group 2
			--command:AddControl("mainmenu", pos_category);
			--
			--commandName = "Friends.RecentAdded";
			--command = Map3DSystem.App.Commands.AddNamedCommand(
				--{name = commandName,app_key = app.app_key, ButtonText = "最近添加的", });
			---- add command to mainmenu control, using the same folder as commandName. But you can use any folder you like
			--pos_category = commandName;
			---- before group 2
			--command:AddControl("mainmenu", pos_category);
			
			commandName = "Friends.FriendsFinder";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = L"找朋友", icon = "Texture/3DMapSystem/common/search.png",});
			-- add command to mainmenu control, using the same folder as commandName. But you can use any folder you like
			pos_category = commandName;
			-- add to end
			command:AddControl("mainmenu", pos_category, nil);
			
			commandName = "Friends.InviteFriends";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = L"邀请朋友", icon = "Texture/3DMapSystem/common/user_add.png",});
			-- add command to mainmenu control, using the same folder as commandName. But you can use any folder you like
			pos_category = commandName;
			-- add to end
			command:AddControl("mainmenu", pos_category, nil);
			
		end
	else
		-- TODO: place the app's one time initialization code here.
		-- during one time init, its message handler may need to update the app structure with static integration points, 
		-- i.e. app.about, HomeButtonText, HomeButtonText, HasNavigation, NavigationButtonText, HasQuickAction, QuickActionText,  See app template for more information.
		
		-- e.g. 
		app.about = "managing and creating tasks. Task is usually associated with some kind of rewards and task can be completed in a varierty of ways."
		Map3DSystem.App.profiles.app = app; 
		
		-- set profile definition
		-- TODO: temporarily keep UserInfo here. move this to a web service on the central server instead. 
		app:SetProfileDefinition({
			ProfileBox = true,
			UserInfo = {
			  -- basicinfo.html
			  ["gender"] = true,
			  ["blood"] = true,
			  ["horoscope"] = true,
			  ["selfdescription"] = true,
			  ["photo"] = true,
			  
			  -- interests.html
			  ["relationship"] = true,
			  ["meeting"] = true,
			  ["meeting"] = true,
			  ["color"] = true,
			  ["music"] = true,
			  ["interest"] = true,
			  
			  -- aboutme.html
			  ["username"] = true,
			  ["birth_year"] = true,
			  ["birth_day"] = true,
			  ["birth_month"] = true,
			  ["home_province"] = true,
			  ["home_city"] = true,
			  ["office_phone"] = true,
			  ["emailaddress"] = true,
			  ["msn"] = true,
			  ["website"] = true,
			  ["qq"] = true,
			  ["mobile_phone"] = true,
			  
			  -- education
			  --["highschool_name_0"] = true,
			  --["element_school"] = true,
			  --["highschool_class_0"] = true,
			  --["highschool_year_0"] = true,
			  --["middle_school"] = true,
			  --["univ_name_0"] = true,
			  --["univ_year_0"] = true,
			  --["department_0"] = true,
			  ["company_name_0"] = true,
			  ["company_workhere_0"] = true,
			  ["company_year_0"] = true,
			  ["company_desc_0"] = true,
		  },
		});
	
		app.HideHomeButton = true;
		app.Title = L"我的档案";
		app.icon = "Texture/3DMapSystem/AppIcons/Profiles_64.dds"
		app.SubTitle = L"个人信息, 交友";
		
		-- settings page
		app:SetSettingPage("ProfileRegPage.html", L"我的个人档案");
		app:SetHelpPage("WelcomePage.html");
		
		-- init the profile manager
		NPL.load("(gl)script/kids/3DMapSystemApp/profiles/ProfileManager.lua");
		Map3DSystem.App.profiles.ProfileManager.Init(app);
		
		-- add registration page command, this is required by LoginApp to handler per application user registration. 
		local commandName = "Registration.profiles";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = L"App注册", });
		end
		
		-- add registration page command, this is required by LoginApp to handler per application user registration. 
		local commandName = "Profile.VisitWorld";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = L"访问世界", icon="Texture/3DMapSystem/common/world_go.png" });
		end
	end
end

-- Receives notification that the Add-in is being unloaded.
function Map3DSystem.App.profiles.OnDisconnection(app, disconnectMode)
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
function Map3DSystem.App.profiles.OnQueryStatus(app, commandName, statusWanted)
	if(statusWanted == Map3DSystem.App.CommandStatusWanted) then
		-- TODO: return an integer by adding values in Map3DSystem.App.CommandStatus.
		-- return enabled and supported 
		return (Map3DSystem.App.CommandStatus.Enabled + Map3DSystem.App.CommandStatus.Supported)
	end
end

-- This is called when the command is invoked.The Exec is fired after the QueryStatus event is fired, assuming that the return to the statusOption parameter of QueryStatus is supported and enabled. 
-- This is the event where you place the actual code for handling the response to the user click on the command.
-- @param commandName: The name of the command to determine state for. Usually in the string format "Category.SubCate.Name".
function Map3DSystem.App.profiles.OnExec(app, commandName, params)
	if(commandName == "Registration.profiles" and params) then
			if(params.operation=="query") then
				-- check this application's MCML profile to determine if registration is complete. 
				local profile = app:GetMCMLInMemory() or {};
				if(profile.UserInfo and profile.UserInfo.username and profile.UserInfo.username~="" and profile.UserInfo.photo and profile.UserInfo.photo~="") then
					-- if username and photo is available, it means that all required fields are completed. 
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
					NPL.load("(gl)script/kids/3DMapSystemApp/profiles/ProfileRegPage.lua");
					Map3DSystem.App.profiles.RegPage.OnFinishedFunc = params.callbackFunc;
					Map3DSystem.App.profiles.RegPage:Create("profiles.RegPage", params.parent, "_fi", 0,0,0,0);
				end	
			end
	elseif(commandName == "Profile.VisitWorld") then
		params = params or {uid="loggedinuser"}
		params.url = System.localserver.UrlHelper.WS_to_REST("script/kids/3DMapSystemApp/profiles/VisitWorldPage.html", 
			params, {"uid"});
		params.name = params.name or "Profile.VisitWorld";
		params.title = params.title or L"访问世界";
		params.zorder = params.zorder or 2;
		params.icon = "Texture/3DMapSystem/common/world_go.png";
		params.width = params.width or 480;
		params.height = params.height or 340;
		params.x = (ParaUI.GetUIObject("root").width-params.width)/2
		params.y = (ParaUI.GetUIObject("root").height-params.height)/2
		Map3DSystem.App.Commands.Call("File.MCMLBrowser", params);
			
	elseif(Map3DSystem.UI.AppDesktop.CheckUser(commandName)) then
		-- all functions below requres user is logged in. 	
		if(commandName == "Profile.EditProfile") then	
			Map3DSystem.App.Commands.Call("File.MCMLBrowser", {url="script/kids/3DMapSystemApp/profiles/ProfileRegPage.html", name="Friends", title=L"个人档案", DisplayNavBar = true});
		elseif(commandName == "Profile.ViewProfile") then	
			local uid = "loggedinuser";
			if(type(params) == "string") then
				uid = params;
			elseif(type(params) == "table" and params.uid) then	
				uid = params.uid;
			end
			Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
				-- TODO:  Add uid to url
				url=System.localserver.UrlHelper.BuildURLQuery("script/kids/3DMapSystemApp/Profiles/ProfilePage.html", {uid=uid}), 
				name="ViewProfile", 
				app_key=app.app_key, 
				text = "个人信息",
				directPosition = true,
					align = "_ct",
					x = -550/2,
					y = -420/2,
					width = 550,
					height = 420,
			});
			
		elseif(commandName == "Profile.HomePage") then
			Map3DSystem.App.Commands.Call("File.MCMLBrowser", {url="script/kids/3DMapSystemApp/Login/LoggedInHomePage.html", name="Friends", title=L"我的首页", DisplayNavBar = true});
		elseif(commandName == "Friends.RecentAdded") then	
			Map3DSystem.App.Commands.Call("File.MCMLBrowser", {url="script/kids/3DMapSystemApp/profiles/FriendsPage.html?tab=recent", name="Friends", title=L"朋友", DisplayNavBar = true});
		elseif(commandName == "Friends.RecentUpdated") then	
			Map3DSystem.App.Commands.Call("File.MCMLBrowser", {url="script/kids/3DMapSystemApp/profiles/FriendsPage.html?tab=recent", name="Friends", title=L"朋友", DisplayNavBar = true});
		elseif(commandName == "Friends.Online") then	
			Map3DSystem.App.Commands.Call("File.MCMLBrowser", {url="script/kids/3DMapSystemApp/profiles/FriendsPage.html?tab=online", name="Friends", title=L"朋友", DisplayNavBar = true});		
		elseif(commandName == "Friends.AllFriends") then	
			Map3DSystem.App.Commands.Call("File.MCMLBrowser", {url="script/kids/3DMapSystemApp/profiles/FriendsPage.html", name="Friends", title=L"朋友", DisplayNavBar = true});	
		elseif(commandName == "Friends.InviteFriends") then		
			Map3DSystem.App.Commands.Call("File.MCMLBrowser", {url="script/kids/3DMapSystemApp/profiles/InviteFriends.html", name="Friends", title=L"朋友", DisplayNavBar = true});
		elseif(commandName == "Friends.FriendsFinder") then		
			Map3DSystem.App.Commands.Call("File.MCMLBrowser", {url="script/kids/3DMapSystemApp/profiles/FriendsFinder.html", name="Friends", title=L"朋友", DisplayNavBar = true});
		elseif(app:IsHomepageCommand(commandName)) then
			Map3DSystem.App.profiles.GotoHomepage();
		elseif(app:IsNavigationCommand(commandName)) then
			Map3DSystem.App.profiles.Navigate();
		elseif(app:IsQuickActionCommand(commandName)) then	
			Map3DSystem.App.profiles.DoQuickAction();
		end
	end	
end

-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
function Map3DSystem.App.profiles.OnRenderBox(mcmlData)
end


-- called when the user wants to nagivate to the 3D world location relavent to this application
function Map3DSystem.App.profiles.Navigate()
end

-- called when user clicks to check out the homepage of this application. Homepage usually includes:
-- developer info, support, developer worlds information, app global news, app updates, all community user rating, active users, trade, currency transfer, etc. 
function Map3DSystem.App.profiles.GotoHomepage()
end

-- called when user clicks the quick action for this application. 
function Map3DSystem.App.profiles.DoQuickAction()
end

-- Add terrain, sky and ocean button to the toolbar. 
function Map3DSystem.App.profiles.OnActivateDesktop(app)
	Map3DSystem.App.Commands.Call("Profile.HomePage")
	--Map3DSystem.App.Commands.Call("File.WelcomePage", {url="script/kids/3DMapSystemApp/profiles/WelcomePage.html"})
end

-- 
function Map3DSystem.App.profiles.OnDeactivateDesktop()

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
function Map3DSystem.App.profiles.MSGProc(window, msg)
	----------------------------------------------------
	-- application plug-in messages here
	----------------------------------------------------
	if(msg.type == Map3DSystem.App.MSGTYPE.APP_CONNECTION) then	
		-- Receives notification that the Add-in is being loaded.
		Map3DSystem.App.profiles.OnConnection(msg.app, msg.connectMode);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_DISCONNECTION) then	
		-- Receives notification that the Add-in is being unloaded.
		Map3DSystem.App.profiles.OnDisconnection(msg.app, msg.disconnectMode);

	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUERY_STATUS) then
		-- This is called when the command's availability is updated. 
		-- NOTE: this function returns a result. 
		msg.status = Map3DSystem.App.profiles.OnQueryStatus(msg.app, msg.commandName, msg.statusWanted);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_EXEC) then
		-- This is called when the command is invoked.
		msg.response = Map3DSystem.App.profiles.OnExec(msg.app, msg.commandName, msg.params);
				
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_RENDER_BOX) then	
		-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
		Map3DSystem.App.profiles.OnRenderBox(msg.mcml);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_NAVIGATION) then
		-- Receives notification that the user wants to nagivate to the 3D world location relavent to this application
		Map3DSystem.App.profiles.Navigate();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_HOMEPAGE) then
		-- called when user clicks to check out the homepage of this application. 
		Map3DSystem.App.profiles.GotoHomepage();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUICK_ACTION) then
		-- called when user clicks the quick action for this application. 
		Map3DSystem.App.profiles.DoQuickAction();
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_ACTIVATE_DESKTOP) then
		Map3DSystem.App.profiles.OnActivateDesktop(msg.app);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_DEACTIVATE_DESKTOP) then
		Map3DSystem.App.profiles.OnDeactivateDesktop();

	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		
	end
end