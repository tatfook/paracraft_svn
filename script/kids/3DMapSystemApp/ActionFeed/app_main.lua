--[[
Title: ActionFeed app for Paraworld
Author(s): LiXizhi
Date: 2008/1/17
Desc: 
-- the second param can be a table of {name, title, url, DisplayNavBar, x,y, width, height, icon, iconsize}
Map3DSystem.App.Commands.Call("Profile.ActionFeed.Add", {uid = "", content=""});

db registration insert script
INSERT INTO apps VALUES (NULL, 'ActionFeed_GUID', 'ActionFeed', '1.0.0', 'http://www.paraengine.com/apps/ActionFeed_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemApp/ActionFeed/IP.xml', '', 'script/kids/3DMapSystemApp/ActionFeed/app_main.lua', 'Map3DSystem.App.ActionFeed.MSGProc', 1);

[APP Integration Point]: Action feed bar 
Desc: Applications can send notifications to a user via action feed. Action feed is usually displayed on the very top of 
the in-game screen. It provides goal sets, action feeds, hints, requests, message alerts, etc in a simple icon sequence 
in time order. Action feed is very easy to catch the user attention and should always provide a concise goal-driven task
 that calls the user in to action. The interesting thing is that most action feeds are associated with user profile and 
 viewable by both its owner and visitors, thus allowing viral distribution of user goals, contents and actions among its friends.

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/ActionFeed/app_main.lua");
------------------------------------------------------------
]]

-- requires

-- create class
commonlib.setfield("Map3DSystem.App.ActionFeed", {});

-------------------------------------------
-- event handlers
-------------------------------------------

-- OnConnection method is the obvious point to place your UI (menus, mainbars, tool buttons) through which the user will communicate to the app. 
-- This method is also the place to put your validation code if you are licensing the add-in. You would normally do this before putting up the UI. 
-- If the user is not a valid user, you would not want to put the UI into the IDE.
-- @param app: the object representing the current application in the IDE. 
-- @param connectMode: type of Map3DSystem.App.ConnectMode. 
function Map3DSystem.App.ActionFeed.OnConnection(app, connectMode)
	if(connectMode == Map3DSystem.App.ConnectMode.UI_Setup) then
		-- place your UI (menus,toolbars, tool buttons) through which the user will communicate to the app
		-- e.g. MainBar.AddItem(), MainMenu.AddItem().
		
		-- show Action Feed Bar here. 
		--NPL.load("(gl)script/kids/3DMapSystemApp/ActionFeed/ActionFeedBar.lua");
		--Map3DSystem.App.ActionFeed.ActionFeedBar.ShowWnd(app);
		
		-- Feeds: show the feeds
		local commandName = "Profile.ShowActionFeed";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand({
				name = commandName,
				app_key = app.app_key, 
				tooltip = "Feeds", 
				icon = "Texture/3DMapSystem/MainBarIcon/Feed.png; 0 0 48 48", 
			});
		end
	else
		-- place the app's one time initialization code here.
		-- during one time init, its message handler may need to update the app structure with static integration points, 
		-- i.e. app.about, HomeButtonText, HomeButtonText, HasNavigation, NavigationButtonText, HasQuickAction, QuickActionText,  See app template for more information.
		
		NPL.load("(gl)script/kids/3DMapSystemApp/ActionFeed/StatusBar.lua");
		
		Map3DSystem.App.ActionFeed.app = app; -- keep a reference	
		app.HideHomeButton = true;
		
		local commandName = "Profile.ActionFeed.Add";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "发迷你消息", icon = app.icon, });
		end
	end
end

-- Receives notification that the Add-in is being unloaded.
function Map3DSystem.App.ActionFeed.OnDisconnection(app, disconnectMode)
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
function Map3DSystem.App.ActionFeed.OnQueryStatus(app, commandName, statusWanted)
	if(statusWanted == Map3DSystem.App.CommandStatusWanted) then
		-- return enabled and supported 
		return (Map3DSystem.App.CommandStatus.Enabled + Map3DSystem.App.CommandStatus.Supported)
	end
end

-- feed templates are mapping from template name to template functions. which takes the feed content string and output the final feed string. 
local feedtemplates = {
	["message"] = function(content)
		return string.format("<pe:name uid='%s'/> 说:%s", Map3DSystem.App.profiles.ProfileManager.GetUserID() or "", content or "") 
	end,
	["poke"] = function(content)
		return string.format("<pe:name uid='%s'/> 打了个招呼:%s", Map3DSystem.App.profiles.ProfileManager.GetUserID() or "", content or "") 
	end,
	["empty"] = function(content)
		return content;
	end,
}

-- This is called when the command is invoked.The Exec is fired after the QueryStatus event is fired, assuming that the return to the statusOption parameter of QueryStatus is supported and enabled. 
-- This is the event where you place the actual code for handling the response to the user click on the command.
-- @param commandName: The name of the command to determine state for. Usually in the string format "Category.SubCate.Name".
function Map3DSystem.App.ActionFeed.OnExec(app, commandName, params)
	if(commandName == "Profile.ActionFeed.Add") then	
		-- params = {uid = uid, content = content, silentMode=silentMode, feedtype = feedtype, feedtemplate = feedtemplate, callbackFunc=callbackFunc(bSucceed) end}
		-- @param uid: if nil it will be sent to all friends, otherwise only the friends of the given uid. it may be multiple uid seperated by commar. 
		-- @param silentMode: if true, no UI is displayed, message is sent. otherwise use nil to display a dialog to send the message. 
		-- @param feedtype: what kinds of feed is sent, nil,"Story", "Action", "Request", "Message", "Item". Defaults to "Story", where "story" and "action" requires that the receiver is a friend of the current user. 
		-- @param feedtemplate: feed template name. specify which feed template to use. if nil, "message" template is used. Some common template includes "message",  "empty",  
		
		if(type(params) == "string") then
			params = {uid = params};
		elseif(type(params) ~= "table") then	
			params = {};
		end
		if(params.feedtype==nil or params.feedtype=="") then
			params.feedtype = "Story"; -- defaults to "Story"
		end
		if(params.feedtemplate==nil or params.feedtemplate == "") then
			params.feedtemplate = params.feedtemplate or "message";-- defaults to "message" feed template
		end	
		
		if(params.silentMode) then
			local content = params.content;
			local feedtemplateFunc = feedtemplates[params.feedtemplate or "message"];
			if(feedtemplateFunc) then
				content = feedtemplateFunc(content)
			end
			if( content and content~="" ) then
				local function ResultFunc(msg)
					local bSuc;
					if(msg and msg.issuccess) then
						commonlib.log("successfully publish silent feed %s to user\n", content)
						bSuc = true
					else
						commonlib.log("failed publishing silent feed %s to user\n", content)
					end	
					if(type(params.callbackFunc) == "function") then
						params.callbackFunc(bSuc);
					end
				end
				local msg;
				if(params.feedtype=="Story") then
					msg = {to_uids = params.uid, story = content,};
					paraworld.actionfeed.PublishStoryToUser(msg, "paraworld", ResultFunc);
				elseif(params.feedtype=="Message") then
					msg = {to_uids = params.uid, message = content,};
					paraworld.actionfeed.PublishMessageToUser(msg, "paraworld", ResultFunc);
				elseif(params.feedtype=="Action") then
					msg = {to_uids = params.uid, action = content,};
					paraworld.actionfeed.PublishActionToUser(msg, "paraworld", ResultFunc);	
				elseif(params.feedtype=="Request") then
					msg = {to_uids = params.uid, request = content,};
					paraworld.actionfeed.PublishRequestToUser(msg, "paraworld", ResultFunc);		
				elseif(params.feedtype=="Item") then
					msg = {to_uids = params.uid, item = content,};
					paraworld.actionfeed.PublishItemToUser(msg, "paraworld", ResultFunc);
				end	
			end	
		else
			Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
				url=System.localserver.UrlHelper.WS_to_REST("script/kids/3DMapSystemApp/ActionFeed/PublishFeedPage.html", 
					params, {"uid", "content", "feedtype", "feedtemplate"}), 
				name="ActionFeed.PublishFeed", 
				app_key=app.app_key, 
				text = "发送消息",
				icon = "Texture/3DMapSystem/common/feed.png",
				DestroyOnClose = true,
				directPosition = true,
					align = "_ct",
					x = -300/2,
					y = -270/2,
					width = 300,
					height = 270,
				zorder = params.zorder or 2,	
			});	
		end	
	end	
end

-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
function Map3DSystem.App.ActionFeed.OnRenderBox(mcmlData)
end


-- called when the user wants to nagivate to the 3D world location relavent to this application
function Map3DSystem.App.ActionFeed.Navigate()
end

-- called when user clicks to check out the homepage of this application. Homepage usually includes:
-- developer info, support, developer worlds information, app global news, app updates, all community user rating, active users, trade, currency transfer, etc. 
function Map3DSystem.App.ActionFeed.GotoHomepage()
end

-- called when user clicks the quick action for this application. 
function Map3DSystem.App.ActionFeed.DoQuickAction()
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
function Map3DSystem.App.ActionFeed.MSGProc(window, msg)
	----------------------------------------------------
	-- application plug-in messages here
	----------------------------------------------------
	if(msg.type == Map3DSystem.App.MSGTYPE.APP_CONNECTION) then	
		-- Receives notification that the Add-in is being loaded.
		Map3DSystem.App.ActionFeed.OnConnection(msg.app, msg.connectMode);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_DISCONNECTION) then	
		-- Receives notification that the Add-in is being unloaded.
		Map3DSystem.App.ActionFeed.OnDisconnection(msg.app, msg.disconnectMode);

	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUERY_STATUS) then
		-- This is called when the command's availability is updated. 
		-- NOTE: this function returns a result. 
		msg.status = Map3DSystem.App.ActionFeed.OnQueryStatus(msg.app, msg.commandName, msg.statusWanted);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_EXEC) then
		-- This is called when the command is invoked.
		Map3DSystem.App.ActionFeed.OnExec(msg.app, msg.commandName, msg.params);
				
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_RENDER_BOX) then	
		-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
		Map3DSystem.App.ActionFeed.OnRenderBox(msg.mcml);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_NAVIGATION) then
		-- Receives notification that the user wants to nagivate to the 3D world location relavent to this application
		Map3DSystem.App.ActionFeed.Navigate();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_HOMEPAGE) then
		-- called when user clicks to check out the homepage of this application. 
		Map3DSystem.App.ActionFeed.GotoHomepage();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUICK_ACTION) then
		-- called when user clicks the quick action for this application. 
		Map3DSystem.App.ActionFeed.DoQuickAction();
	

	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		
	end
end

----------------------
-- public functions
----------------------

-- get action feed data for a given user and fill the data into a data source table. 
-- @param output: [in|out] the data source table to hold the returned data. the data item is a table {mcml=string} and 
-- output.Count, contains the data item count. output.status, contains the current download status: nil not available, 1 fetching, 2 fetched. 
-- @param uid: if nil, it is the current user. we will fetch via actionfeed profile for the given user.
-- @param feedtype: feed type to retrieve. "Story", "Message", "Request", "Action". if nil, it defaults to "Story"
-- @param cache_policy: if nil, it will use default setting. if uid is current user and cache_policy is nil, the in memory version is used. 
-- @param pageCtrl:if this is not nil, pageCtrl:Refresh() will be called once data table is retrieved. 
function Map3DSystem.App.ActionFeed.GetDSTable(output, uid, feedtype, pageCtrl, cache_policy)
	output.status = nil;
	feedtype = feedtype or "Story";
	local function RefreshActionFeedView_(profile)
		if(profile and type(profile[feedtype])=="table") then
			local mcml;
			output.Count = 0;
			local i;
			for i, mcml in ipairs(profile[feedtype]) do 
				output[i] = {mcml = mcml};
				output.Count = i;
			end
		else
			output.Count = 0;
		end
		commonlib.resize(output, output.Count)
		output.status = 2;
		if(pageCtrl) then
			pageCtrl:Refresh();	
		end	
	end
	
	-- if nil. we will fetch via actionfeed profile for the user ,
	if(cache_policy) then
		-- fetch using profile. 
		Map3DSystem.App.ActionFeed.app:GetMCML(uid, function(uid, app_key, bSucceed)
			local profile;
			if(bSucceed) then
				profile = Map3DSystem.App.ActionFeed.app:GetMCMLInMemory(uid);
			else
				log("warning: error fetching action feeds\n")    
			end
			RefreshActionFeedView_(profile)
		end, cache_policy)
	else
		-- use in memory version
		local profile = Map3DSystem.App.ActionFeed.app:GetMCMLInMemory(uid);
		RefreshActionFeedView_(profile);
	end	
end

-- get action feed data for a given user and fill the data into a data source function. 
-- in an mcml embedded script, we can built a actionfeed datasource function instance like below. 
--<verbatim>
---- status: nil not available, 1 fetching, 2 fetched. 
--dsActionFeed = Eval("dsActionFeed") or {status=nil, };
     --
--function DS_Func_ActionFeed_Story(index)
    --return Map3DSystem.App.ActionFeed.DataSourceFunc(index, dsActionFeed, hostuid, "Story", pageCtrl)
--end
--</verbatim>
-- for an example: see ProfilePage.html. 
-- @param output: [in|out] the data source table to hold the returned data. the data item is a table {mcml=string} and 
-- output.Count, contains the data item count. output.status, contains the current download status: nil not available, 1 fetching, 2 fetched. 
-- @param uid: if nil, it is the current user. we will fetch via actionfeed profile for the given user.
-- @param feedtype: feed type to retrieve. "Story", "Message", "Request", "Action". if nil, it defaults to "Story"
-- @param cache_policy: if nil, it will use default setting. if uid is current user and cache_policy is nil, the in memory version is used. 
-- @param pageCtrl:if this is not nil, pageCtrl:Refresh() will be called once data table is retrieved. 
function Map3DSystem.App.ActionFeed.DataSourceFunc(index, dsTable, uid, feedtype, pageCtrl, cache_policy)
	if(not dsTable.status) then
        -- use a default cache
        Map3DSystem.App.ActionFeed.GetDSTable(dsTable, uid, feedtype, pageCtrl, cache_policy or "access plus 20 minutes");
    elseif(dsTable.status==2) then    
        if(index==nil) then
            return dsTable.Count;
        else
            return dsTable[index];
        end
    end 
end

-- clear feed for a given category for the current logged in user. 
-- @param feedtype: "Story", "Message", "Request", "Action". if nil, it defaults to "Story"
-- @param pageCtrl:if this is not nil, pageCtrl:Refresh() will be called once done
function Map3DSystem.App.ActionFeed.ClearFeed(category, pageCtrl)
	local profile = Map3DSystem.App.ActionFeed.app:GetMCMLInMemory();
	profile[category or "Story"] = nil;
	Map3DSystem.App.ActionFeed.app:SetMCML(nil, profile, function (uid, appkey, bSucceed)
		if(bSucceed) then
			if(pageCtrl) then
				pageCtrl:Refresh();
			end	
		end	
	end)
end