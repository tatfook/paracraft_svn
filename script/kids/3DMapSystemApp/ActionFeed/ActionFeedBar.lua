--[[
Title: Action feed bar
Author(s): LiXizhi
Date: 2007/12/28
[APP Integration Point]: Action feed bar 
Desc: Applications can send notifications to a user via action feed. Action feed is usually displayed on the very top of 
the in-game screen. It provides goal sets, action feeds, hints, requests, message alerts, etc in a simple icon sequence 
in time order. Action feed is very easy to catch the user attention and should always provide a concise goal-driven task
 that calls the user in to action. The interesting thing is that most action feeds are associated with user profile and 
 viewable by both its owner and visitors, thus allowing viral distribution of user goals, contents and actions among its friends.
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/ActionFeed/ActionFeedBar.lua");
Map3DSystem.App.ActionFeed.ActionFeedBar.OnRenderBox(mcml)

Map3DSystem.App.ActionFeed.ActionFeedBar.AddFeed({
	Icon = "!",
	OnClick = "_guihelper.MessageBox(\"this is a tip\");",
	UpdateUI = true,
})
------------------------------------------------------------
]]

-- create class
commonlib.setfield("Map3DSystem.App.ActionFeed.ActionFeedBar", {});

-- messge types
Map3DSystem.App.ActionFeed.ActionFeedBar.MSGTYPE = {
	ADD_ACTIONFEED = 1000,	
}

-- an array of all feeds
Map3DSystem.App.ActionFeed.ActionFeedBar.feeds = {};

-- a feed template
Map3DSystem.App.ActionFeed.ActionFeedBar.feed = {
	-- nil or "GUID" the specified application must be installed and loaded before the onclick event can be called. 
	-- we will download the application at runtime. If nil, it may be from in-game function.
	app_key = nil,
	-- icon to be displayed, in case the application is not installed locally. this icon will be displayed as an uninstalled icon. 
	-- it will first index to into Map3DSystem.App.ActionFeed.ActionFeedBar.IconMap table using the icon string, if not found, the icon string is used as the actual icon path. 
	Icon = nil,
	-- how icon is displayed: nil (normal style, 30% alpha until action bar has focus)| "Alert"(click once to stop beeping) | "ConstColor",
	IconStyle = nil,
	-- nil(normal) | "fly" how icon is animated when added to the bar. 
	OnAddStyle = nil,
	-- function or string: this is only valid for local application or in-game function. 
	OnClick = nil,
	-- mcmlTable or nil: it can only be an mcml table to be parsed to the associated app.OnActionFeedClick(mcmlTable).
	-- this is mostly used for external applications. Simply use OnClick if it is an local app. 
	OnClickMCML = nil,
	-- boolean or nil: immediately update UI. default to no.
	UpdateUI = nil,
	-- nil or {x=0, y=0,z=0} position table, in case this action item is associated with a 3D scene position.
	position = nil,
	-- nil | "teleport": if an icon item has position and posAction, when clicking it, it will not only triggers onclick, but also bring the camera to the position 
	-- and may teleport the user to the position on the second click depending on the posAction type.
	posAction = nil,
	-- nil or text: the mouse over tooltip to display. Text may contain mcml markups to include URLs like another user_id. 
	tooltip = nil,
	-- the text to display. Currently, we do not display it.
	text = nil,
	-- time created
	creation_date = nil,
	-- ticks: in case an animation is used when adding this icon.
	ticks = 0,
}

-- create a new feed from a feed message
function Map3DSystem.App.ActionFeed.ActionFeedBar.CreateFeedFromMsg(msg)
	local feed = {ticks=0};
	if(msg~=nil) then
		feed.app_key = msg.app_key;
		feed.Icon = Map3DSystem.App.ActionFeed.ActionFeedBar.IconMap[msg.Icon or "x"] or msg.Icon;
		feed.IconStyle = msg.IconStyle;
		feed.OnAddStyle = msg.OnAddStyle;
		feed.OnClick = msg.OnClick;
		feed.OnClickMCML = msg.OnClickMCML;
		feed.UpdateUI = msg.UpdateUI;
		feed.position = msg.position;
		feed.posAction = msg.posAction;
		feed.tooltip = msg.tooltip;
		feed.text = msg.text;
		feed.creation_date = msg.creation_date;
	end	
	return feed;
end

-- inner UI control name
Map3DSystem.App.ActionFeed.ActionFeedBar.UIname = "ActionFeedBar";
Map3DSystem.App.ActionFeed.ActionFeedBar.AppName = "ActionFeedBar";

-- mapping from icon string to icon path. 
Map3DSystem.App.ActionFeed.ActionFeedBar.IconMap = {
	["!"] = "Texture/whitedot.dds",
	["?"] = "Texture/whitedot.dds",
	["x"] = "Texture/whitedot.dds",
	["tips"] = "Texture/whitedot.dds",
	["question"] = "Texture/whitedot.dds",
	["app"] = "Texture/whitedot.dds",
	["app_uninstalled"] = "Texture/whitedot.dds",
	["gift"] = "Texture/whitedot.dds",
	["gift_sent"] = "Texture/whitedot.dds",
	["blueprint_created"] = "Texture/whitedot.dds",
	["blueprint_deployed"] = "Texture/whitedot.dds",
	["blueprint_completed"] = "Texture/whitedot.dds",
	["footprint"] = "Texture/whitedot.dds",
	["friend_request"] = "Texture/whitedot.dds",
	["city_request"] = "Texture/whitedot.dds",
	["offline"] = "Texture/whitedot.dds",
	["online"] = "Texture/whitedot.dds",
	["person_join"] = "Texture/whitedot.dds",
	["person_leave"] = "Texture/whitedot.dds",
	["poke"] = "Texture/whitedot.dds",
	["feed"] = "Texture/whitedot.dds",
	["ads"] = "Texture/whitedot.dds",
	["wall"] = "Texture/whitedot.dds",
	["game"] = "Texture/whitedot.dds",
	["gameHighScore"] = "Texture/whitedot.dds",
	["treasure_quest"] = "Texture/whitedot.dds",
	["treasure_gain"] = "Texture/whitedot.dds",
	["pet_talk"] = "Texture/whitedot.dds",
	["pet_wish"] = "Texture/whitedot.dds",
	["pet_wish_completed"] = "Texture/whitedot.dds",
	["chat"] = "Texture/whitedot.dds",
	["card"] = "Texture/whitedot.dds",
	["game"] = "Texture/whitedot.dds",
	["rate"] = "Texture/whitedot.dds",
	["save"] = "Texture/whitedot.dds",
	["save_completed"] = "Texture/whitedot.dds",
	["publish"] = "Texture/whitedot.dds",
	["publish_completed"] = "Texture/whitedot.dds",
	["Land_renting"] = "Texture/whitedot.dds",
	["Land_confirmed"] = "Texture/whitedot.dds",
}

--[[ add a new feed to the action feed bar. 
@param msg: is a table of the format
msg = {
	-- no need to set, since we will set automatically for you. 
	type = Map3DSystem.App.ActionFeed.ActionFeedBar.MSGTYPE.ADD_ACTIONFEED,
	-- the specified application must be installed and loaded before the onclick event can be called. 
	-- we will download the application at runtime. If nil, it may be from in-game function.
	app_key = nil or "GUID",
	-- icon to be displayed, in case the application is not installed locally. this icon will be displayed as an uninstalled icon. 
	-- it will first index to into Map3DSystem.App.ActionFeed.ActionFeedBar.IconMap table using the icon string, if not found, the icon string is used as the actual icon path. 
	Icon = "!" or "Texture/whitedot.dds", etc,
	-- how icon is displayed.
	IconStyle = nil (normal style, 30% alpha until action bar has focus)| "Alert"(click once to stop beeping) | "ConstColor",
	-- how icon is animated when added to the bar. 
	OnAddStyle = nil(normal) | "fly",
	-- this is only valid for local application or in-game function. 
	OnClick = function or string,
	-- it can only be an mcml table to be parsed to the associated app.OnActionFeedClick(mcmlTable).
	-- this is mostly used for external applications. Simply use OnClick if it is an local app. 
	OnClickMCML = mcmlTable or nil,
	-- immediately update UI. default to no.
	UpdateUI = boolean or nil,
	-- position table, in case this action item is associated with a 3D scene position.
	position = nil or {x=0, y=0,z=0},
	-- if an icon item has position and posAction, when clicking it, it will not only triggers onclick, but also bring the camera to the position 
	-- and may teleport the user to the position on the second click depending on the posAction type.
	posAction = nil | "teleport",
	-- the mouse over tooltip to display. Text may contain mcml markups to include URLs like another user_id. 
	tooltip = nil or text,
	-- the text to display. Currently, we do not display it.
	text = nil,
	-- time created
	creation_date = nil,
	-- distribution method, we allow viral distribution of action feed among friends and current user. 
	-- Please note that, not all client of applications is allowed to send feeds to the REST server directly. Basically, only app server can update feeds on REST server. 
	-- so in most cases, this parameter is nil. 
	distribution = nil (do nothing or just local feed) | "friends feed" (add this feed to friends) | "friends feed" (email this feed to all my friends) | "owner" (email to world owner)
}
]]
function Map3DSystem.App.ActionFeed.ActionFeedBar.AddFeed(msg)
	if(Map3DSystem.App.ActionFeed.ActionFeedBar.MainApp~=nil) then
		msg.wndName = "main";
		msg.type = Map3DSystem.App.ActionFeed.ActionFeedBar.MSGTYPE.ADD_ACTIONFEED;
		Map3DSystem.App.ActionFeed.ActionFeedBar.MainApp:SendMessage(msg);
	end	
end

-- [APP IP Function]
-- this function should be called when a game world is loaded. It will load all action feed icons that is relavent to this world
-- since action feed bar contains integration points, only call OnRenderBox when mcml are retrieved from server and apps for this world are all installed 
-- @param mcml: the mcml descriptive data that is usually retrieved from the paraworld REST server.
function Map3DSystem.App.ActionFeed.ActionFeedBar.OnRenderBox(mcml)
	-- add item to action feed bar according to mcml content
	
	-- display the window
	if(not Map3DSystem.App.ActionFeed.ActionFeedBar.IsInitWnd) then 
		-- init window if it has not been done before.
		Map3DSystem.App.ActionFeed.ActionFeedBar.InitMainWndObject();
	end
	Map3DSystem.UI.Windows.ShowApplication(Map3DSystem.App.ActionFeed.ActionFeedBar.AppName);
end

-- show the main window object
function Map3DSystem.App.ActionFeed.ActionFeedBar.ShowWnd(app)
	NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
		
	local _app = app._app;
	local _wnd = _app:FindWindow("ActionFeedBar") or _app:RegisterWindow("ActionFeedBar", nil, Map3DSystem.App.ActionFeed.ActionFeedBar.MSGProc);
	
	local _appName, _wndName, _document, _frame;
	_frame = Map3DSystem.UI.Windows.GetWindowFrame(_wnd.app.name, _wnd.name);
	if(_frame) then
		_appName = _frame.wnd.app.name;
		_wndName = _frame.wnd.name;
		_document = ParaUI.GetUIObject(_appName.."_".._wndName.."_window_document");
	else
		local param = {
			wnd = _wnd,
			--isUseUI = true,
			mainBarIconSetID = 17, -- or nil
			icon = nil,
			iconSize = 48,
			text = "行为博客", -- naming
			style = Map3DSystem.UI.Windows.Style[1],
			maximumSizeX = 800,
			maximumSizeY = 64,
			minimumSizeX = 100,
			minimumSizeY = 64,
			isShowIcon = false,
			--opacity = 100, -- [0, 100]
			isShowMaximizeBox = false,
			isShowMinimizeBox = false,
			isShowAutoHideBox = false,
			allowDrag = true,
			allowResize = true,
			initialPosX = 800,
			initialPosY = 22,
			initialWidth = 256,
			initialHeight = 64,
			
			ShowUICallback = Map3DSystem.App.ActionFeed.ActionFeedBar.Show,
			
		};
		_appName, _wndName, _document, _frame = Map3DSystem.UI.Windows.RegisterWindowFrame(param);
	end
	Map3DSystem.UI.Windows.ShowWindow(true, _appName, _wndName);
end

function Map3DSystem.App.ActionFeed.ActionFeedBar.OnMouseEnter()
end

function Map3DSystem.App.ActionFeed.ActionFeedBar.OnMouseLeave()
end

-- internal show method
function Map3DSystem.App.ActionFeed.ActionFeedBar.Show(bShow,_parent,parentWindow)
	local _this;
	local left,top,width,height;

	Map3DSystem.App.ActionFeed.ActionFeedBar.parentWnd = parentWindow;

	_this = ParaUI.GetUIObject(Map3DSystem.App.ActionFeed.ActionFeedBar.UIname);
	if(_this:IsValid())then
		_this.visible = bShow;
	else
		if( bShow == false)then
			return;
		end
		local oldparent = _parent;
		
		_this = ParaUI.CreateUIObject("button", "navTo", "_lt", 5, 2, 32, 32)
		_this.background = "Texture/3DMapSystem/webbrowser/goto.png"
		_this.animstyle = 12;
		_parent:AddChild(_this);
		
		Map3DSystem.App.ActionFeed.ActionFeedBar.UpdateUI();
	end
end

-- clear all feeds. Call UpdateUI() afterwards to reflect the changes to the UI. 
function Map3DSystem.App.ActionFeed.ActionFeedBar.Reset()
	Map3DSystem.App.ActionFeed.ActionFeedBar.feeds = {};
end

-- update the UI: call this function when new item(s) are added. 
function Map3DSystem.App.ActionFeed.ActionFeedBar.UpdateUI()
	local _this;
	local _parent = ParaUI.GetUIObject(Map3DSystem.App.ActionFeed.ActionFeedBar.UIname);
	if(_parent:IsValid())then
		-- get parent size. 
		
		-- CreateGet and update all elements
		
		-- check and delete the trailing elements if any
	end
end

------------------------------------------
-- all related messages
------------------------------------------
function Map3DSystem.App.ActionFeed.ActionFeedBar.MSGProc(window, msg)
	if(msg.type == Map3DSystem.App.ActionFeed.ActionFeedBar.MSGTYPE.ADD_ACTIONFEED) then	
		-- add a new feed to the action feed bar. 
		local feed = Map3DSystem.App.ActionFeed.ActionFeedBar.CreateFeedFromMsg(msg);
		if(feed~=nil)then
			Map3DSystem.App.ActionFeed.ActionFeedBar.feeds[table.getn(Map3DSystem.App.ActionFeed.ActionFeedBar.feeds)+1] = feed;
			if(feed.UpdateUI) then
				Map3DSystem.App.ActionFeed.ActionFeedBar.UpdateUI();
			end
		end
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		Map3DSystem.App.ActionFeed.ActionFeedBar.IsShow = false;
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		-- TODO: if size changed update icons based on new width.
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		Map3DSystem.App.ActionFeed.ActionFeedBar.IsShow = false;
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		Map3DSystem.App.ActionFeed.ActionFeedBar.IsShow = true;
	end
end