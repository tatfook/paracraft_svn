--[[
Title: Status bar on the AppTaskBar
Author(s): WangTian
Date: 2008/6/2
Desc: 
Desc: Applications can send notifications to a user via action feed. Action feed is displayed on the very right of 
the AppTaskBar. It provides goal sets, action feeds, hints, requests, message alerts, etc in a simple icon sequence 
in time order. Feed is very easy to catch the user attention and should always provide a concise goal-driven task
 that calls the user in to action. The interesting thing is that most action feeds are associated with user profile and 
 viewable by both its owner and visitors, thus allowing viral distribution of user goals, contents and actions among its friends.
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/ActionFeed/StatusBar.lua");
Map3DSystem.App.ActionFeed.StatusBar.OnRenderBox(mcml)

Map3DSystem.App.ActionFeed.StatusBar.AddFeed({
	Icon = "!",
	OnClick = "_guihelper.MessageBox(\"this is a tip\");",
	UpdateUI = true,
})
------------------------------------------------------------
]]

-- create class
commonlib.setfield("Map3DSystem.App.ActionFeed.StatusBar", {});


-- a feed template
Map3DSystem.App.ActionFeed.StatusBar.FeedTemplate = {
	-- nil or "GUID" the specified application must be installed and loaded before the onclick event can be called. 
	-- we will download the application at runtime. If nil, it may be from in-game function.
	app_key = nil,
	-- NOTE: by andy, local of external application
	isLocal = true,
	-- icon to be displayed, in case the application is not installed locally. this icon will be displayed as an uninstalled icon. 
	-- it will first index to into Map3DSystem.App.ActionFeed.StatusBar.IconMap table using the icon string, if not found, the icon string is used as the actual icon path. 
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
	--creation_date = nil,
	creation_time = nil, -- change to creation time
	-- ticks: in case an animation is used when adding this icon.
	ticks = 0,
}

-- a task template, task is a local window that stays perminently on the interface like chat window
Map3DSystem.App.ActionFeed.StatusBar.TaskTemplate = {
	icon = nil, --icon to be displayed
	text = nil, --text to be displayed
	tasktab_bg = nil, -- the background on the statusbar, icon and text is shown in the task tab
	onclick = nil, -- function () end when the task is clicked
}

-- inner UI control name
Map3DSystem.App.ActionFeed.StatusBar.UIname = "StatusBar";
Map3DSystem.App.ActionFeed.StatusBar.WndName = "StatusBar";

-- messge types
Map3DSystem.App.ActionFeed.StatusBar.MSGTYPE = {
	ADD_ACTIONFEED = 1532,
	ADD_TASK = 1533,
}

-- init the status bar in at application connection
function Map3DSystem.App.ActionFeed.StatusBar.Init()
	-- init the os.window object
	local wndName = Map3DSystem.App.ActionFeed.StatusBar.WndName;
	local _app = Map3DSystem.App.ActionFeed.app._app;
	local _wnd = _app:FindWindow(wndName) or _app:RegisterWindow(wndName, nil, Map3DSystem.App.ActionFeed.StatusBar.MSGProc);
	
	-- TODO: init the feed from local history
end

---- create a new feed from a feed message
--function Map3DSystem.App.ActionFeed.StatusBar.CreateFeedFromMsg(msg)
	--local feed = {ticks=0};
	--if(msg ~= nil) then
		--feed.app_key = msg.app_key;
		--feed.isLocal = msg.isLocal;
		--feed.Icon = Map3DSystem.App.ActionFeed.StatusBar.IconMap[msg.Icon or "x"] or msg.Icon;
		--feed.IconStyle = msg.IconStyle;
		--feed.OnAddStyle = msg.OnAddStyle;
		--feed.OnClick = msg.OnClick;
		--feed.OnClickMCML = msg.OnClickMCML;
		--feed.UpdateUI = msg.UpdateUI;
		--feed.position = msg.position;
		--feed.posAction = msg.posAction;
		--feed.tooltip = msg.tooltip;
		--feed.text = msg.text;
		--feed.creation_time = msg.creation_time;
	--end	
	--return feed;
--end
--
---- create a new task from a task message
--function Map3DSystem.App.ActionFeed.StatusBar.CreateTaskFromMsg(msg)
	--local task = {};
	--if(msg ~= nil) then
		--task.icon = msg.icon or "";
		--task.text = msg.text or "Untitled";
		--task.tasktab_bg = msg.tasktab_bg or "";
		--task.onclick = msg.onclick;
	--end	
	--return task;
--end

-- an array of all feeds
Map3DSystem.App.ActionFeed.StatusBar.feeds = {};

-- an array of all tasks
Map3DSystem.App.ActionFeed.StatusBar.tasks = {};

-------------------------- TASK --------------------------

-- add a task into status, it will automatically refresh the status bar
-- @param task:
--	{
--		name = "Chat1",
--		icon = "optional icon, usually has it",
--		text = "this is optional",
--		tooltip = "some text",
--		commandName = "",
--	}
function Map3DSystem.App.ActionFeed.StatusBar.AddTask(task)
	if(task ~= nil and task.name ~= nil) then
		local i, t;
		for i, t in ipairs(Map3DSystem.App.ActionFeed.StatusBar.tasks) do
			if(task.name == t.name) then
				log("Add task with the same name in Map3DSystem.App.ActionFeed.StatusBar.AddTask()\n");
				return;
			end
		end
		
		table.insert(Map3DSystem.App.ActionFeed.StatusBar.tasks, task);
		
		-- refresh UI
		Map3DSystem.App.ActionFeed.StatusBar.Refresh();
	end
end

function Map3DSystem.App.ActionFeed.StatusBar.PostMSGToTask(taskName, msg)
	do return end;
	if(taskName ~= nil) then
		local i, t;
		for i, t in ipairs(Map3DSystem.App.ActionFeed.StatusBar.tasks) do
			if(taskName == t.name) then
				local _taskObj = ParaUI.GetUIObject("Task_"..taskName);
				if(_taskObj:IsValid() == true) then
					
					local _msgCont = ParaUI.GetUIObject("Task_MSG_Cont");
					local _msg = ParaUI.GetUIObject("Task_MSG_Cont_text");
					if(_msgCont:IsValid() == false) then
						local _msgCont = ParaUI.CreateUIObject("container", "Task_MSG_Cont", "_lt", 1,1,1,1);
						_msgCont.background = nil;
						_msgCont.zorder = 11; -- TODO: choose a proper zorder for task message
						_msgCont.enabled = false;
						_msgCont:AttachToRoot();
						
						_msg = ParaUI.CreateUIObject("text", "Task_MSG_Cont_text", "_lt", 10, 5, 1,1);
						_msgCont:AddChild(_msg);
						
						-- create animation if not create before. 
						NPL.load("(gl)script/ide/Motion/AnimatorEngine.lua");
						local motion = CommonCtrl.Motion.AnimatorEngine:new({framerate=24});
						local groupManager = CommonCtrl.Motion.AnimatorManager:new();
						local layerManager = CommonCtrl.Motion.LayerManager:new();
						local layerBGManager = CommonCtrl.Motion.LayerManager:new();
						local PopupAnimator = CommonCtrl.Motion.Animator:new();
						PopupAnimator:Init("script/kids/3DMapSystemUI/Chat/Motion/MapsShowMessageOnTask.xml", "Task_MSG_Cont");
						layerManager:AddChild(PopupAnimator);
						groupManager:AddChild(layerManager);
						groupManager:AddChild(layerBGManager);
						motion:SetAnimatorManager(groupManager);
						
						Map3DSystem.App.ActionFeed.StatusBar.motion = motion;
					end
					
					local taskX, taskY, taskwidth, taskHeight = _taskObj:GetAbsPosition();
					
					if(msg == nil or msg == "") then
						return;
					end
					
					local _textwidth = _guihelper.GetTextWidth(msg);
					
					local lines = math.ceil(_textwidth / 150);
					
					local width, height;
					if(lines == 1) then
						width = _textwidth + 20;
					else
						width = 170;
					end
					height = lines * 14 + 10;
					
					local x = taskX + taskHeight / 2 + 8 - width;
					local y = taskY - height;
					
					_msgCont.x = x;
					_msgCont.y = y;
					_msgCont.width = width;
					_msgCont.height = height;
					_msg.width = width - 20;
					_msg.height = height - 10;
					_msg.text = msg;
					
					Map3DSystem.App.ActionFeed.StatusBar.motion:doPlay();
				end
			end
		end
	end
end

-- remove task from the status bar, automatically refresh the UI
-- @param taskName: task name
function Map3DSystem.App.ActionFeed.StatusBar.RemoveTask(taskName)
	if(taskName ~= nil) then
		local index;
		local i, t;
		for i, t in ipairs(Map3DSystem.App.ActionFeed.StatusBar.tasks) do
			if(taskName == t.name) then
				index = i;
				break;
			end
		end
		if(index ~= nil) then
			table.remove(Map3DSystem.App.ActionFeed.StatusBar.tasks, index);
		end
		
		-- refresh UI
		Map3DSystem.App.ActionFeed.StatusBar.Refresh();
	end
end

-------------------------- FEED --------------------------

-- add a feed, it will automatically popup the feed information
-- @param task:
--	{
--		ownerDraw = function (_parent)
--		name = "Chat1",
--		icon = "...",
--		text = "Andy",
--		background = "",
--		commandName = "",
--	}
function Map3DSystem.App.ActionFeed.StatusBar.AddFeed(feed)
	if(feed ~= nil and feed.name ~= nil) then
		local i, t;
		for i, t in ipairs(Map3DSystem.App.ActionFeed.StatusBar.feeds) do
			if(feed.name == t.name) then
				log("Add feed with the same name in Map3DSystem.App.ActionFeed.StatusBar.AddFeed()\n");
				return;
			end
		end
		
		table.insert(Map3DSystem.App.ActionFeed.StatusBar.feeds, feed);
		
		local _feed = ParaUI.GetUIObject("FeedPopUpBtn");
		if(_feed:IsValid() == true) then
			local x, y, width, height = _feed:GetAbsPosition();
			
			local screenWidth = ParaUI.GetUIObject("root").width;
			local screenHeight = ParaUI.GetUIObject("root").height;
			
			local borderY = screenHeight - y;
			
			local _popUpFeed = ParaUI.GetUIObject("PopUpFeed");
			if(_popUpFeed:IsValid() == false) then
				
				local _popUpFeed = ParaUI.CreateUIObject("container", "PopUpFeed", "_rb", -160, -120-borderY, 160, 120);
				_popUpFeed.background = feed.background;
				_popUpFeed.zorder = 10; -- TODO: choose a proper zorder for popupfeed
				_popUpFeed.lifetime = 1.5;
				_popUpFeed:AttachToRoot();
				
				local _icon = ParaUI.CreateUIObject("container", "Icon", "_lt", 8, 8, 24, 24);
				_icon.background = feed.icon;
				_popUpFeed:AddChild(_icon);
				
				local _text = ParaUI.CreateUIObject("button", "Text", "_ct", -60, -35, 120, 70);
				_text.text = feed.text;
				_text.background = "";
				_text.onclick = string.format(";Map3DSystem.App.ActionFeed.StatusBar.OnClickPopUpFeed(%q);", feed.name);
				_popUpFeed:AddChild(_text);
			else
				_popUpFeed.lifetime = 1.5;
				_popUpFeed:GetChild("Icon").background = feed.icon;
				_popUpFeed:GetChild("Text").text = feed.text;
			end
			
			--if(not Map3DSystem.App.ActionFeed.StatusBar.PopupMotion_) then
				--NPL.load("(gl)script/ide/Motion/AnimatorEngine.lua");
				--Map3DSystem.App.ActionFeed.StatusBar.PopupMotion_ = CommonCtrl.Motion.AnimatorEngine:new({framerate=24});
				--local groupManager = CommonCtrl.Motion.AnimatorManager:new();
				--local layerManager = CommonCtrl.Motion.LayerManager:new();
				--local layerBGManager = CommonCtrl.Motion.LayerManager:new();
				--local PopupAnimator = CommonCtrl.Motion.Animator:new();
				--PopupAnimator:Init("script/kids/3DMapSystemApp/ActionFeed/PopUpFeed.xml", "PopUpFeed");
				--
				--layerManager:AddChild(PopupAnimator);
				--layerBGManager:AddChild(BgGreyOutAnimator);
				--groupManager:AddChild(layerManager);
				--groupManager:AddChild(layerBGManager);
				--Map3DSystem.App.ActionFeed.StatusBar.PopupMotion_:SetAnimatorManager(groupManager);
			--end
			--Map3DSystem.App.ActionFeed.StatusBar.PopupMotion_:doPlay();
		end
		
		
		-- refresh UI
		Map3DSystem.App.ActionFeed.StatusBar.Refresh();
	end
end

-- remove feed from the status bar, automatically refresh the UI
-- @param feedName: feed name
function Map3DSystem.App.ActionFeed.StatusBar.RemoveFeed(feedName)
	if(feedName ~= nil) then
		local index;
		local i, t;
		for i, t in ipairs(Map3DSystem.App.ActionFeed.StatusBar.feeds) do
			if(feedName == t.name) then
				index = i;
				break;
			end
		end
		if(index ~= nil) then
			table.remove(Map3DSystem.App.ActionFeed.StatusBar.feeds, index);
		end
		
		-- refresh UI
		Map3DSystem.App.ActionFeed.StatusBar.Refresh();
	end
end

---- append a feed object into the feed array. Call UpdateUI() afterwards to reflect the changes to the UI. 
--function Map3DSystem.App.ActionFeed.StatusBar.AppendFeed(feed)
	--Map3DSystem.App.ActionFeed.StatusBar.feeds[table.getn(Map3DSystem.App.ActionFeed.StatusBar.feeds) + 1] = feed;
--end
--
---- append a task object into the feed array. Call UpdateUI() afterwards to reflect the changes to the UI. 
--function Map3DSystem.App.ActionFeed.StatusBar.AppendTask(task)
	--Map3DSystem.App.ActionFeed.StatusBar.tasks[table.getn(Map3DSystem.App.ActionFeed.StatusBar.tasks) + 1] = task;
--end

-- clear all feeds. Call UpdateUI() afterwards to reflect the changes to the UI. 
function Map3DSystem.App.ActionFeed.StatusBar.Reset()
	Map3DSystem.App.ActionFeed.StatusBar.feeds = {};
	Map3DSystem.App.ActionFeed.StatusBar.tasks = {};
end


function Map3DSystem.App.ActionFeed.StatusBar.Refresh()
	local _parent = Map3DSystem.App.ActionFeed.StatusBar.parentUIObj
	if(_parent ~= nil and _parent:IsValid() == true) then
		Map3DSystem.App.ActionFeed.StatusBar.Show(_parent);
	end
end

-- onclick the task on the status bar
function Map3DSystem.App.ActionFeed.StatusBar.OnClickTask(taskName)
	local i, t;
	for i, t in ipairs(Map3DSystem.App.ActionFeed.StatusBar.tasks) do
		if(taskName == t.name) then
			local commandName = t.commandName;
			local command = Map3DSystem.App.Commands.GetCommand(commandName);
			if(command ~= nil) then
				command:Call();
			end
		end
	end
end

-- onclick the pop up feed 
function Map3DSystem.App.ActionFeed.StatusBar.OnClickPopUpFeed(feedName)
	local i, t;
	for i, t in ipairs(Map3DSystem.App.ActionFeed.StatusBar.feeds) do
		if(feedName == t.name) then
			local commandName = t.commandName;
			local command = Map3DSystem.App.Commands.GetCommand(commandName);
			if(command ~= nil) then
				command:Call();
			end
		end
	end
end

-- show the status bar in the _parent container
function Map3DSystem.App.ActionFeed.StatusBar.Show(_parent)
	-- TODO: refresh the status bar
	if(_parent:IsValid()) then
		Map3DSystem.App.ActionFeed.StatusBar.parentUIObj = _parent;
		
		-- remove all children, since we will rebuild all. 
		_parent:RemoveAll();
		
		
		local iconSize = 16;
		local taskHeight = 24;
		local taskWidth = 72;
		local left = 22;
		local iconTop = (taskHeight-iconSize)/2;
		
		--
		-- the right most feed display area
		--
		-- modified a little bit by LXZ 2008.6.22
		local nCount = table.getn(Map3DSystem.App.ActionFeed.StatusBar.feeds);
		local _feed = ParaUI.CreateUIObject("button", "FeedPopUpBtn", "_rt", -20, 6+iconTop, iconSize, iconSize);
		if(nCount>0)then
			_feed.text = tostring(nCount);
		end	
		_feed.tooltip=string.format("你有 %d 条消息", nCount);
		_feed.background = "Texture/3DMapSystem/common/feed.png";
		_feed.animstyle = 13;
		_guihelper.SetUIColor(_feed, "255 255 255");
		_guihelper.SetFontColor(_feed, "255 255 255");
		_parent:AddChild(_feed);
		
		
		--
		-- all other custom buttons added via application interface
		--
		
		local _,_, maxWidth = _parent:GetAbsPosition();
		maxWidth = maxWidth - 22;
		local bNoSpaceLeft;
		
		local count = 0; -- number of icon created. 
		local index, task;
		for index, task in ipairs(Map3DSystem.App.ActionFeed.StatusBar.tasks) do
			--if(task.AppCommand) then	
				-- LiXizhi 2008.6.22, added automatic taskWidth
				taskWidth = 0;
				if(task.icon) then
					taskWidth = taskWidth+iconSize+iconTop;
				end
				if(task.text) then
					taskWidth = taskWidth+_guihelper.GetTextWidth(task.text);
				end
				if(taskWidth == 0) then
					taskWidth = 16;
				end
				
				if((left + taskWidth) < maxWidth) then
				
					local _task = ParaUI.CreateUIObject("container", "Task_"..task.name, "_rt", -(left + taskWidth), 6, taskWidth, taskHeight);
					_task.background = "";
					_parent:AddChild(_task);
					
					local _left = 0
					if(task.icon) then
						local _icon = ParaUI.CreateUIObject("button", "Icon", "_lt", _left, iconTop, iconSize, iconSize);
						_icon.background = task.icon;
						_guihelper.SetUIColor(_icon, "255 255 255");
						_icon.animstyle = 13;
						_icon.onclick = string.format(";Map3DSystem.App.ActionFeed.StatusBar.OnClickTask(%q);", task.name);
						_task:AddChild(_icon);
						if(task.tooltip) then
							_icon.tooltip = task.tooltip;
						end
						_left = _left+iconSize+iconTop
					end	
					
					if(task.text) then
						local _text = ParaUI.CreateUIObject("button", "Text", "_lt", _left, 0, taskWidth-left, taskHeight);
						_text.background = "";
						_text.text = task.text;
						_text.onclick = string.format(";Map3DSystem.App.ActionFeed.StatusBar.OnClickTask(%q);", task.name);
						if(task.tooltip) then
							_text.tooltip = task.tooltip;
						end
						_task:AddChild(_text);
					end	
					
					left = left + taskWidth + 2;
				else
					bNoSpaceLeft = true;
				end	
				
				count = count + 1;
				-- 5 is maximum status bar icon number
				if(bNoSpaceLeft) then
					-- show extension button << using a popup menu control.
					Map3DSystem.App.ActionFeed.StatusBar.ExtensionItemIndex = index;
					
					local _this = ParaUI.CreateUIObject("button", "extBtn", "_rt", -(left + 16), 5, 16, 16)
					_this.background = "Texture/3DMapSystem/Desktop/ext_left.png";
					_this.animstyle = 12;
					_this.onclick = ";Map3DSystem.App.ActionFeed.StatusBar.ShowStatusBarExtensionMenu();"
					_parent:AddChild(_this);
					break;
				end
			--end	
		end
		
		-- bring up a context menu for selecting extension items. 
		function Map3DSystem.App.ActionFeed.StatusBar.ShowStatusBarExtensionMenu()
			local ctl = CommonCtrl.GetControl("statusbar.ExtensionMenu");
			if(ctl == nil)then
				ctl = CommonCtrl.ContextMenu:new{
					name = "statusbar.ExtensionMenu",
					width = 130,
					height = 150,
					DefaultIconSize = 24,
					DefaultNodeHeight = 26,
					container_bg = "Texture/3DMapSystem/ContextMenu/BG2.png:8 8 8 8",
					onclick = function (node, param1)
							if(node.Name ~= nil) then
								Map3DSystem.App.ActionFeed.StatusBar.OnClickTask(node.Name);
							end
						end,
					AutoPositionMode = "_lb",
				};
			end
			local _this = Map3DSystem.App.ActionFeed.StatusBar.parentUIObj:GetChild("extBtn");
			if(_this:IsValid()) then
				local x,y,width,height = _this:GetAbsPosition();
				
				ctl.RootNode:ClearAllChildren();
				
				local index, node
				local nSize = table.getn(Map3DSystem.App.ActionFeed.StatusBar.tasks);
				for index = Map3DSystem.App.ActionFeed.StatusBar.ExtensionItemIndex, nSize do
					ctl.RootNode:AddChild(CommonCtrl.TreeNode:new(CommonCtrl.TreeNode:new({
						Text = Map3DSystem.App.ActionFeed.StatusBar.tasks[index].text, 
						Name = Map3DSystem.App.ActionFeed.StatusBar.tasks[index].name, 
						Icon = Map3DSystem.App.ActionFeed.StatusBar.tasks[index].icon})));
				end
				
				ctl:Show(x, y);
			end	
		end
		
		
	end
end


-- mapping from icon string to icon path. 
Map3DSystem.App.ActionFeed.StatusBar.IconMap = {
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
	type = Map3DSystem.App.ActionFeed.StatusBar.MSGTYPE.ADD_ACTIONFEED,
	-- the specified application must be installed and loaded before the onclick event can be called. 
	-- we will download the application at runtime. If nil, it may be from in-game function.
	app_key = nil or "GUID",
	-- icon to be displayed, in case the application is not installed locally. this icon will be displayed as an uninstalled icon. 
	-- it will first index to into Map3DSystem.App.ActionFeed.StatusBar.IconMap table using the icon string, if not found, the icon string is used as the actual icon path. 
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
--function Map3DSystem.App.ActionFeed.StatusBar.AddFeed(msg)
	--
	--local _app = Map3DSystem.App.ActionFeed.app._app;
	--local _wnd = _app:FindWindow(Map3DSystem.App.ActionFeed.StatusBar.WndName);
	--
	--if(_wnd ~= nil) then
		--msg.wndName = Map3DSystem.App.ActionFeed.StatusBar.WndName;
		--msg.type = Map3DSystem.App.ActionFeed.StatusBar.MSGTYPE.ADD_ACTIONFEED;
		--Map3DSystem.App.ActionFeed.app._app:SendMessage(msg)
	--end	
--end
--
--function Map3DSystem.App.ActionFeed.StatusBar.AddTask(msg)
	--
	--local _app = Map3DSystem.App.ActionFeed.app._app;
	--local _wnd = _app:FindWindow(Map3DSystem.App.ActionFeed.StatusBar.WndName);
	--
	--if(_wnd ~= nil) then
		--msg.wndName = Map3DSystem.App.ActionFeed.StatusBar.WndName;
		--msg.type = Map3DSystem.App.ActionFeed.StatusBar.MSGTYPE.ADD_TASK;
		--Map3DSystem.App.ActionFeed.app._app:SendMessage(msg)
	--end	
--end

-- [APP IP Function]
-- this function should be called when a game world is loaded. It will load all action feed icons that is relavent to this world
-- since action feed bar contains integration points, only call OnRenderBox when mcml are retrieved from server and apps for this world are all installed 
-- @param mcml: the mcml descriptive data that is usually retrieved from the paraworld REST server.
function Map3DSystem.App.ActionFeed.StatusBar.OnRenderBox(mcml)
	---- add item to action feed bar according to mcml content
	--
	---- display the window
	--if(not Map3DSystem.App.ActionFeed.StatusBar.IsInitWnd) then 
		---- init window if it has not been done before.
		--Map3DSystem.App.ActionFeed.StatusBar.InitMainWndObject();
	--end
	--Map3DSystem.UI.Windows.ShowApplication(Map3DSystem.App.ActionFeed.StatusBar.AppName);
end

---- this function is called in AppTaskBar.RefreshStatusBar() when status bar is recreated or new item is added to it.
----		status bar is heavily depend on this refresh mechanism
--function Map3DSystem.App.ActionFeed.StatusBar.Refresh(_parent)
	---- TODO: refresh the status bar
	--if(_parent:IsValid()) then
		--Map3DSystem.App.ActionFeed.StatusBar.parentUIObj = _parent;
		--
		---- remove all children, since we will rebuild all. 
		--_parent:RemoveAll();
		--
		--local _feed = ParaUI.CreateUIObject("button", "FeedBtn", "_rt", -50, 6, 48, 24);
		--_feed.background = "Texture/alphadot.png"; --"Texture/3DMapSystem/MainBarIcon/Wishlist_2.png";
		--_feed.text = "FEED";
		--_parent:AddChild(_feed);
		--
		--local taskWidth = 72;
		--local taskHeight = 24;
		--local left = 52;
		--
		--local _,_, maxWidth = _parent:GetAbsPosition();
		--maxWidth = maxWidth - 22;
		--local bNoSpaceLeft;
		--
		--local count = 0; -- number of icon created. 
		--local index, task;
		--for index, task in ipairs(Map3DSystem.App.ActionFeed.StatusBar.tasks) do
			----if(task.AppCommand) then
				--if((left + taskWidth) < maxWidth) then
					--local _task = ParaUI.CreateUIObject("button", "Task", "_rt", -(left + taskWidth), 6, taskWidth, taskHeight);
					--_task.tooltip = task.text;
					--_guihelper.SetVistaStyleButton(_task, 
						--"Texture/3DMapSystem/Desktop/LoginButton_Norm.png: 15 15 15 15", 
						--"Texture/3DMapSystem/Desktop/LoginButton_HL.png: 15 15 15 15");
					--_parent:AddChild(_task);
					--
					--local _icon = ParaUI.CreateUIObject("button", "Icon", "_rt", -(left + taskWidth), 6, taskHeight, taskHeight);
					--_icon.background = task.icon;
					--_icon.animstyle = 12;
					--_parent:AddChild(_icon);
					--
					--local _text = ParaUI.CreateUIObject("button", "Text", "_rt", -(left + taskWidth) + taskHeight, 6, taskWidth - taskHeight, taskHeight);
					--_text.background = "";
					--_text.text = task.text;
					--_parent:AddChild(_text);
					--
					--left = left + taskWidth + 2;
				--else
					--bNoSpaceLeft = true;
				--end	
				--
				--count = count + 1;
				---- 5 is maximum status bar icon number
				--if(bNoSpaceLeft) then
					---- show extension button << using a popup menu control.
					--Map3DSystem.App.ActionFeed.StatusBar.ExtensionItemIndex = index;
					--
					--local _this = ParaUI.CreateUIObject("button", "extBtn", "_rt", -(left + 16), 5, 16, 16)
					--_this.background = "Texture/3DMapSystem/Desktop/ext_left.png";
					--_this.animstyle = 12;
					--_this.onclick = ";Map3DSystem.App.ActionFeed.StatusBar.ShowStatusBarExtensionMenu();"
					--_parent:AddChild(_this);
					--break;
				--end
			----end	
		--end
		--
		---- bring up a context menu for selecting extension items. 
		--function Map3DSystem.App.ActionFeed.StatusBar.ShowStatusBarExtensionMenu()
			--local ctl = CommonCtrl.GetControl("statusbar.ExtensionMenu");
			--if(ctl == nil)then
				--ctl = CommonCtrl.ContextMenu:new{
					--name = "statusbar.ExtensionMenu",
					--width = 130,
					--height = 150,
					--DefaultIconSize = 24,
					--DefaultNodeHeight = 26,
					--container_bg = "Texture/3DMapSystem/ContextMenu/BG2.png:8 8 8 8",
					--AutoPositionMode = "_lb",
				--};
			--end
			--local _this = Map3DSystem.App.ActionFeed.StatusBar.parentUIObj:GetChild("extBtn");
			--if(_this:IsValid()) then
				--local x,y,width,height = _this:GetAbsPosition();
				--
				--ctl.RootNode:ClearAllChildren();
				--
				--local index, node
				--local nSize = table.getn(Map3DSystem.App.ActionFeed.StatusBar.tasks);
				--for index = Map3DSystem.App.ActionFeed.StatusBar.ExtensionItemIndex, nSize do
					--ctl.RootNode:AddChild(CommonCtrl.TreeNode:new(CommonCtrl.TreeNode:new({
						--Text = Map3DSystem.App.ActionFeed.StatusBar.tasks[index].text, 
						--Name = Map3DSystem.App.ActionFeed.StatusBar.tasks[index].text, 
						--Icon = Map3DSystem.App.ActionFeed.StatusBar.tasks[index].icon})));
				--end
				--
				--ctl:Show(x, y);
			--end	
		--end
		--
		--
	--end
--end

-- update the UI: call this function when new item(s) are added. 
function Map3DSystem.App.ActionFeed.StatusBar.UpdateUI()
	if(Map3DSystem.App.ActionFeed.StatusBar.parentUIObj ~= nil 
		and Map3DSystem.App.ActionFeed.StatusBar.parentUIObj:IsValid() == true) then
		Map3DSystem.App.ActionFeed.StatusBar.Refresh(Map3DSystem.App.ActionFeed.StatusBar.parentUIObj);
	end
	--local _this;
	--local _parent = ParaUI.GetUIObject(Map3DSystem.App.ActionFeed.StatusBar.UIname);
	--if(_parent:IsValid()) then
		---- get parent size. 
		--
		---- CreateGet and update all elements
		--
		---- check and delete the trailing elements if any
	--end
end

------------------------------------------
-- all related messages
------------------------------------------
function Map3DSystem.App.ActionFeed.StatusBar.MSGProc(window, msg)
	if(msg.type == Map3DSystem.App.ActionFeed.StatusBar.MSGTYPE.ADD_ACTIONFEED) then	
		---- add a new feed to the status bar. 
		--local feed = Map3DSystem.App.ActionFeed.StatusBar.CreateFeedFromMsg(msg);
		--if(feed ~= nil)then
			--Map3DSystem.App.ActionFeed.StatusBar.AppendFeed(feed);
			--if(feed.UpdateUI) then
				--Map3DSystem.App.ActionFeed.StatusBar.UpdateUI();
			--end
		--end
	elseif(msg.type == Map3DSystem.App.ActionFeed.StatusBar.MSGTYPE.ADD_TASK) then	
		---- add a new task to the status bar. 
		--local task = Map3DSystem.App.ActionFeed.StatusBar.CreateTaskFromMsg(msg);
		--if(task ~= nil)then
			--Map3DSystem.App.ActionFeed.StatusBar.AppendTask(task);
			--Map3DSystem.App.ActionFeed.StatusBar.UpdateUI();
		--end
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		Map3DSystem.App.ActionFeed.StatusBar.IsShow = false;
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		-- TODO: if size changed update icons based on new width.
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		Map3DSystem.App.ActionFeed.StatusBar.IsShow = false;
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		Map3DSystem.App.ActionFeed.StatusBar.IsShow = true;
	end
end



------------------------------------------------------------------------------------
-------------------------- THE REST IS TOTALLY DEPRACATED --------------------------
------------------------------------------------------------------------------------

---- show the main window object
--function Map3DSystem.App.ActionFeed.StatusBar.ShowWnd(app)
	--NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
		--
	--local _app = app._app;
	--local _wnd = _app:FindWindow("StatusBar") or _app:RegisterWindow("StatusBar", nil, Map3DSystem.App.ActionFeed.StatusBar.MSGProc);
	--
	--local _appName, _wndName, _document, _frame;
	--_frame = Map3DSystem.UI.Windows.GetWindowFrame(_wnd.app.name, _wnd.name);
	--if(_frame) then
		--_appName = _frame.wnd.app.name;
		--_wndName = _frame.wnd.name;
		--_document = ParaUI.GetUIObject(_appName.."_".._wndName.."_window_document");
	--else
		--local param = {
			--wnd = _wnd,
			----isUseUI = true,
			--mainBarIconSetID = 17, -- or nil
			--icon = nil,
			--iconSize = 48,
			--text = "行为博客", -- naming
			--style = Map3DSystem.UI.Windows.Style[1],
			--maximumSizeX = 800,
			--maximumSizeY = 64,
			--minimumSizeX = 100,
			--minimumSizeY = 64,
			--isShowIcon = false,
			----opacity = 100, -- [0, 100]
			--isShowMaximizeBox = false,
			--isShowMinimizeBox = false,
			--isShowAutoHideBox = false,
			--allowDrag = true,
			--allowResize = true,
			--initialPosX = 800,
			--initialPosY = 22,
			--initialWidth = 256,
			--initialHeight = 64,
			--
			--ShowUICallback = Map3DSystem.App.ActionFeed.StatusBar.Show,
			--
		--};
		--_appName, _wndName, _document, _frame = Map3DSystem.UI.Windows.RegisterWindowFrame(param);
	--end
	--Map3DSystem.UI.Windows.ShowWindow(true, _appName, _wndName);
--end
--
--function Map3DSystem.App.ActionFeed.StatusBar.OnMouseEnter()
--end
--
--function Map3DSystem.App.ActionFeed.StatusBar.OnMouseLeave()
--end
--
---- internal show method
--function Map3DSystem.App.ActionFeed.StatusBar.Show(bShow,_parent,parentWindow)
	--local _this;
	--local left,top,width,height;
--
	--Map3DSystem.App.ActionFeed.StatusBar.parentWnd = parentWindow;
--
	--_this = ParaUI.GetUIObject(Map3DSystem.App.ActionFeed.StatusBar.UIname);
	--if(_this:IsValid())then
		--_this.visible = bShow;
	--else
		--if( bShow == false)then
			--return;
		--end
		--local oldparent = _parent;
		--
		--_this = ParaUI.CreateUIObject("button", "navTo", "_lt", 5, 2, 32, 32)
		--_this.background = "Texture/3DMapSystem/webbrowser/goto.png"
		--_this.animstyle = 12;
		--_parent:AddChild(_this);
		--
		--Map3DSystem.App.ActionFeed.StatusBar.UpdateUI();
	--end
--end
--