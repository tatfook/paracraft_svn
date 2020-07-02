--[[
Title: Chat main window user interface
Author(s): WangTian
Date: 2009/4/9
NOTE: updated to the new user interface
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Chat/MainWnd.lua");
------------------------------------------------------------
]]

-- create class
local libName = "AriesMainWnd";
local MainWnd = {};
commonlib.setfield("MyCompany.Aries.Chat.MainWnd", MainWnd);
local Chat = MyCompany.Aries.Chat;

Chat.UserStatus = {
	[1] = "Available",
	[2] = "Chatty",
	[3] = "Away",
	[4] = "Busy",
	[5] = "Extanded Away",
	[6] = "Offline",
	--[1] = "在线",
	--[2] = "接受聊天",
	--[3] = "离开",
	--[4] = "忙碌",
	--[5] = "离开",
	--[6] = "隐身",
}

Chat.UserStatusIcon = {
	[1] = "Texture/Aries/Andy/Green_32bits.png",
	[2] = "Texture/Aries/Andy/Blue_32bits.png",
	[3] = "Texture/Aries/Andy/Red_32bits.png",
	[4] = "Texture/Aries/Andy/Yellow_32bits.png",
	[5] = "Texture/Aries/Andy/Red_32bits.png",
	[6] = "Texture/Aries/Andy/Grey_32bits.png",
}

-- Show the Chat main window
-- @param bSilentInit: if true, the window is init but not show
function MainWnd.ShowMainWnd(bShow, bSilentInit)
	local _app = System.App.Chat.app._app;
	local _wnd = _app:FindWindow("MainWnd") or _app:RegisterWindow("MainWnd", nil, MainWnd.MSGProc);
	
	NPL.load("(gl)script/ide/WindowFrame.lua");
	
	local frame = CommonCtrl.WindowFrame.GetWindowFrame2(_wnd.app.name, _wnd.name);
	if(frame ~= nil) then
		frame:Show2(bShow);
		return;
	end
	
	local sampleWindowsParam = {
		wnd = _wnd, -- a CommonCtrl.os.window object
		
		--icon = "Texture/3DMapSystem/Chat/AppIcon_64.png";
		text = System.User.nid, --"Buddy List",
		
		isShowTitleBar = true, -- default show title bar
		isShowToolboxBar = false, -- default hide title bar
		isShowStatusBar = false, -- default show status bar
		
		initialPosX = 700, 
		initialPosY = 175, 
		initialWidth = 225, -- initial width of the window client area
		initialHeight = 400, -- initial height of the window client area
		
		directPosition = true,
			align = "_rb",
			x = -290,
			y = -490,
			width = 225,
			height = 400,
			
		allowDrag = true,
		allowResize = true,
		--opacity = 100,
		
		--isShowCloseBox = true, -- hide the close box
		
		style = {
			window_bg = "Texture/Aries/Andy/Frame_63_35_32bits.png:8 64 20 36",
			fillBGLeft = 0,
			fillBGTop = 0,
			fillBGWidth = 0,
			fillBGHeight = 0,
			
			shadow_bg = "Texture/Aries/Common/frame2_shadow.png: 30 30 30 30",
			fillShadowLeft = -21,
			fillShadowTop = -6,
			fillShadowWidth = -21,
			fillShadowHeight = -28,
			
			titleBarHeight = 24,
			statusBarHeight = 35,
			
			borderLeft = 0,
			borderRight = 0,
			borderBottom = 1,
			resizerSize = 24,
			resizer_bg = "",
			
			textcolor = "0 0 0",
			
			CloseBox = {alignment = "_lt",
					x = 8, y = 6, size = 18,
					icon = "Texture/Aries/Andy/Close_32bits.png; 3 2 18 18",},
			MinBox = {alignment = "_lt",
					x = 29, y = 6, size = 18,
					icon = "Texture/Aries/Andy/Minimize_32bits.png; 3 2 18 18",},
			MaxBox = {alignment = "_lt",
					x = 50, y = 6, size = 18,
					icon = "Texture/Aries/Andy/Maximize_32bits.png; 3 2 18 18",},
			
			resizerSize = 16,
			resizer_bg = "Texture/Aries/Common/Resizer_32bits.png",
		},
		
		maxWidth = 400,
		maxHeight = 700,
		minWidth = 200,
		minHeight = 300,
		
		isShowMinimizeBox = true,
		isShowMaximizeBox = true,
		isShowCloseBox = true,
		
		alignment = "Free", -- Free|Left|Right|Bottom
		
		ShowUICallback = MainWnd.Show,
	};
	
	frame = CommonCtrl.WindowFrame:new2(sampleWindowsParam);
	frame:Show2(bShow, nil, bSilentInit);
	
	-- show the messages that not yet visualized, including the offline message and the messages received before 
	--    Chat application main window is launched
	--MainWnd.ShowUnvisualizedMSG();
end


-- destory the main window, usually called when the world is closed
function MainWnd.DestroyMainWnd()
	local _app = System.App.Chat.app._app;
	local _wnd = _app:FindWindow("MainWnd");
	
	if(_wnd ~= nil) then
		NPL.load("(gl)script/ide/WindowFrame.lua");
		local frame = CommonCtrl.WindowFrame.GetWindowFrame2(_wnd.app.name, _wnd.name);
		if(frame ~= nil) then
			frame:Destroy();
		end
		
		CommonCtrl.DeleteControl("treeView_Chat_Contacts");
		CommonCtrl.DeleteControl("dropdownlistUserStatus");
	end
end

-- Andy: why we need a IsWaiting here? LXZ 2009.11.15
MainWnd.IsWaiting = false;

function MainWnd.RegisterDoPendingMSGTimer()
	-- set OnRoster message timer
	NPL.load("(gl)script/ide/timer.lua");
	MainWnd.timer = MainWnd.timer or commonlib.Timer:new({callbackFunc = MainWnd.DoPendingMSGTimer});
	MainWnd.timer:Change(1000,1000);
	
	-- Andy: why we need a IsWaiting here? LXZ 2009.11.15
	MainWnd.IsWaiting = false;
end

function MainWnd.UnregisterDoPendingMSGTimer()
	-- kill OnRoster message timer
	if(MainWnd.timer) then
		MainWnd.timer:Change();
	end
end

function MainWnd.DoPendingMSGTimer()
	if(MainWnd.IsWaiting == true) then
		return;
	end
	
	do return end
	
	local MSGs = System.App.Chat.GetPendingMSGs();
	if(MSGs) then
		local i, MSG;
		for i, MSG in pairs(MSGs) do
			if(MSG.type == "OnMessage") then
				-- this message is sent BEFORE the interface is inited;
				Chat.VisualizeMessage(MSG.from, MSG.subject, MSG.body);
				MSGs[i] = nil;
			elseif(MSG.type == "OnRoster") then
				if(MSG.subscription == 6) then
					-- S10nToIn:
					-- User is subscribed to contact, and contact has sent user a subscription request but user has not replied yet.
					-- this is usually received when contact add user as a friend when the user is offline
					-- pack it as an "OnSubscription" message and reprocess in the next round
					MSGs[i].type = "OnSubscription";
				elseif(MSG.subscription == 4) then
					-- Aries added:
					-- S10nTo:
					-- User is subscribed to contact (one-way).
					-- This is usually received when contact unsubscribe(remove friend) to the user
					-- unsubscribe the contact too, 
					local jc = System.App.Chat.GetConnectedClient();
					if(jc ~= nil) then
						-- Unsubscribe
						log("Unsubscribe1: ".. MSG.jid.." ___\n")
						jc:Unsubscribe(MSG.jid, "");
					else
						log("error: nil jabber client when trying to unsubscribe one-way subscription through jabber\n");
					end
					MSGs[i] = nil;
					MainWnd.IsWaiting = false;
				elseif(MSG.subscription == 0) then
					-- S10nNone:
					-- Contact and user are not subscribed to each other, and neither has requested a subscription from the other.
					-- Usually shows:
					--		after the user decline the contact's subscription
					--		after the contact remove user from his/her contact list
					
					-- delete the message record
					MSGs[i] = nil;
				end
			elseif(MSG.type == "OnSubscription") then
				-- check if user already subscribed to the contact
				local isSubscribed = false;
				local rosterGroups, rosterItems = Chat.GetContactList();
				local _, contact;
				for _, contact in pairs(rosterItems) do
					if(contact.jid == MSG.jid and contact.subscription == 4) then 
						-- subscription: 4
						-- S10nTo: User is subscribed to contact (one-way).
						isSubscribed = true;
						break;
					end
				end
				if(isSubscribed) then
					-- this is a add contact confirm message
					System.App.profiles.ProfileManager.GetUserInfo(string.gsub(MSG.jid, "@.*$", ""), "AddFriendConfirm", function(msg)
						if(msg ~= nil) then
							if(msg.users ~= nil) then
								if(msg.users[1] ~= nil) then
									--msg.users[1].userid
									_guihelper.MessageBox("用户 <pe:name uid = '"..msg.users[1].userid.."' linked=false/> 已经将你加入密友名单。\n",  
									function (dialogResult)
										local jc = Chat.GetConnectedClient();
										if(jc ~= nil) then
											if(dialogResult == _guihelper.DialogResult.OK) then
												-- pop the next message in pending queue
												MainWnd.IsWaiting = false;
											end
										end
									end, _guihelper.MessageBoxButtons.OK);
									return;
								end
							end
						end
						MainWnd.IsWaiting = false;
					end, System.localserver.CachePolicies["never"]);
					
					-- delete the message record
					MSGs[i] = nil;
					-- wait for user reply until the next message is shown
					MainWnd.IsWaiting = true;
					return;
				else
					-- Show the subscription
					System.App.profiles.ProfileManager.GetUserInfo(string.gsub(MSG.jid, "@.*$", ""), "AddFriendConfirm", function(msg)
						if(msg ~= nil) then
							if(msg.users ~= nil) then
								if(msg.users[1] ~= nil) then
									--msg.users[1].userid
									
	commonlib.echo({rosterGroups, rosterItems})
	
	local _, contact;
	for _, contact in pairs(rosterItems) do
		if(contact.jid == MSG.jid and contact.subscription == 8) then 
			local nid = string.gsub(MSG.jid, "@.*$", "");
			nid = tonumber(nid);
			MyCompany.Aries.Desktop.NotificationArea.AppendFeed("story", {
				type = "AriesConfirmFriend", 
				Name = nid, 
				nid = nid, 
				nickname = msg.users[1].nickname}
			);
			MainWnd.IsWaiting = false;
			-- delete the message record
			MSGs[i] = nil;
			do return end
		end
	end
	
	local jc = Chat.GetConnectedClient();
	if(jc ~= nil) then
		local rostor = jc:GetRoster();
		if(type(rostor) == "string") then
			rostor = commonlib.LoadTableFromString(rostor);
		end
		if(roster) then
			local _, item
			for _, item in ipairs(roster) do
				if(item.jid == MSG.jid and item.subscription == 6 and MSG.msg == "Hi") then 
					local nid = string.gsub(MSG.jid, "@.*$", "");
					nid = tonumber(nid);
					if(nid) then
						MyCompany.Aries.Desktop.NotificationArea.AppendFeed("request", {
							type = "AriesAddAsFriend", 
							Name = nid, 
							nid = nid, 
							nickname = msg.users[1].nickname}
						);
						
						MainWnd.IsWaiting = false;
						-- delete the message record
						MSGs[i] = nil;
						
						do return end
					end
				end
			end
		end
	end
	
	do return end
	
									_guihelper.MessageBox("用户 <pe:name uid = '"..msg.users[1].userid.."' linked=false/> 加你为密友。 是否接受？\n加为密友后, 你可以随时获得对方的在线状态以及秘密聊天。",  
									function (dialogResult)
										local jc = Chat.GetConnectedClient();
										if(jc ~= nil) then
											if(dialogResult == _guihelper.DialogResult.Yes) then
												-- accept
												-- allow subscription
												jc:AllowSubscription(MSG.jid, true);
												-- auto subscribe to it
												jc:Subscribe(MSG.jid, "name", "General", "I am "..tostring(System.App.Chat.jid));
												-- pop the next message in pending queue
												MainWnd.IsWaiting = false;
											elseif(dialogResult == _guihelper.DialogResult.No) then
												-- decline
												-- refuse subscription
												jc:AllowSubscription(MSG.jid, false);
												-- pop the next message in pending queue
												MainWnd.IsWaiting = false;
											end
										end
									end, _guihelper.MessageBoxButtons.YesNo);
									return;
								end
							end
						end
						MainWnd.IsWaiting = false;
					end, System.localserver.CachePolicies["never"]);
					
					-- delete the message record
					MSGs[i] = nil;
					-- wait for user reply until the next message is shown
					MainWnd.IsWaiting = true;
					return;
				end
			elseif(MSG.type == "OnUnsubscription") then
				-- Show the subscription
				System.App.profiles.ProfileManager.GetUserInfo(string.gsub(MSG.jid, "@.*$", ""), "AddFriendConfirm", function(msg)
					if(msg ~= nil) then
						if(msg.users ~= nil) then
							if(msg.users[1] ~= nil) then
								--msg.users[1].userid
								_guihelper.MessageBox("用户 <pe:name uid = '"..msg.users[1].userid.."' linked=false/> 将你移出密友名单。\n",  
								function (dialogResult)
									local jc = Chat.GetConnectedClient();
									if(jc ~= nil) then
										if(dialogResult == _guihelper.DialogResult.OK) then
											-- pop the next message in pending queue
											MainWnd.IsWaiting = false;
										end
									end
								end, _guihelper.MessageBoxButtons.OK);
								return;
							end
						end
					end
					MainWnd.IsWaiting = false;
				end, System.localserver.CachePolicies["never"]);
					
				-- update the contact list
				Chat.UpdateContactList();
				-- delete the message record
				MSGs[i] = nil;
				-- wait for user reply until the next message is shown
				MainWnd.IsWaiting = true;
				return;
			end
		end
	end
end

-- Message Processor of Chat main control
function MainWnd.MSGProc(window, msg)
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		MainWnd.Close()
	end
end

-- check if the main window UI is available
-- on world switching the UI is all reset
function MainWnd.IsUIAvailable()
	return ParaUI.GetUIObject("Chat_MainWnd"):IsValid();
end

function MainWnd.Close()
	local _app = System.App.Chat.app._app;
	local _wnd = _app:FindWindow("MainWnd") or _app:RegisterWindow("MainWnd", nil, MainWnd.MSGProc);
	
	NPL.load("(gl)script/ide/WindowFrame.lua");
	
	local frame = CommonCtrl.WindowFrame.GetWindowFrame2(_wnd.app.name, _wnd.name);
	
	if(frame ~= nil) then
		frame:Show2(false);
	end
end

-- show Chat MainWnd in the parent window
-- @param bShow: boolean to show or hide. if nil, it will toggle current setting.
-- @param _parent: parent window inside which the content is displayed. it can be nil.
-- @param parentWindow: parent os window object, parent window for sending messages
function MainWnd.Show(bShow, _parent, parentWindow)
	
	MainWnd.parentWindow = parentWindow;
	
	local _this;
	_this = ParaUI.GetUIObject("Chat_MainWnd");
	
	if(_this:IsValid() == false) then
		if(bShow == false) then
			return;
		end
		
		if(_parent == nil) then
			_this = ParaUI.CreateUIObject("container", "Chat_MainWnd", "_lt", 0, 50, 300, 500);
			_this:AttachToRoot();
		else
			_this = ParaUI.CreateUIObject("container", "Chat_MainWnd", "_fi", 0, 0, 0, 0);
			_this.background = "";
			_parent:AddChild(_this);
		end
		
		local _myselfRegion = ParaUI.CreateUIObject("container", "MyselfRegion", "_mt", 0, 0, 0, 39);
		_myselfRegion.background = "";
		_this:AddChild(_myselfRegion);
		
		local _toolboxRegion = ParaUI.CreateUIObject("container", "ToolboxRegion", "_mb", 0, 0, 0, 35);
		_toolboxRegion.background = "";
		_this:AddChild(_toolboxRegion);
		
		local _contactsRegion = ParaUI.CreateUIObject("container", "ContactsRegion", "_fi", 0, 39, 0, 34);
		_contactsRegion.background = "";
		_this:AddChild(_contactsRegion);
		
		
		--------------------- Myself Region ---------------------
		
		_this = ParaUI.CreateUIObject("container", "btnUserMainIcon_BG", "_rt", -36, 3, 30, 31)
		_this.background = "Texture/Aries/Andy/UserIcon_BG_32bits.png: 3 3 3 3";
		_myselfRegion:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("container", "btnUserMainIcon", "_rt", -35, 4, 28, 28)
		--_this.background = "Texture/Aries/Andy/UserIcon_BG_32bits.png: 3 3 3 3";
		local jc = Chat.GetConnectedClient();
		if(jc ~= nil and jc:IsValid() == true) then
			math.randomseed(tonumber(jc.User) + 4);
		end
		local iconRandomIndex = math.random(1, 6);
		local iconRandomIndex = math.random(1, 6);
		_this.background = "Texture/Aries/Andy/UserIconSample"..iconRandomIndex..".png";
		_myselfRegion:AddChild(_this);
		
		MyCompany.Aries.Desktop.FillUIObjectWithPhotoFromNIDImmediate(_this, System.User.nid);
		
		_this = ParaUI.CreateUIObject("text", "username", "_lt", 26, 5, 100, 16);
		_this.font = System.DefaultBoldFontString;
		_myselfRegion:AddChild(_this);
		if(jc ~= nil and jc:IsValid() == true) then
			_this.text = jc.User;
			MyCompany.Aries.Desktop.FillUIObjectWithNameFromNID(_this, jc.User);
		else
			_this.text = "Me";
		end
		
		_this = ParaUI.CreateUIObject("button", "btnUserMainStatus", "_lt", 6, 12, 16, 16)
		--_this.text = "IM Icon";
		_this.background = "Texture/Aries/Andy/Grey_32bits.png";
		_myselfRegion:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("text", "statustext", "_lt", 27, 21, 100, 16);
		_this.text = "Offline";
		_myselfRegion:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "select", "_lt", 85, 21, 11, 11);
		_this.background = "Texture/3DMapSystem/common/ItemOpenGrey.png";
		_myselfRegion:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "statustext", "_lt", 26, 19, 80, 20);
		_this.onclick = ";MyCompany.Aries.Chat.MainWnd.ShowOnlineStatusSelect();";
		_this.background = "";
		_myselfRegion:AddChild(_this);
		
		if(System.App.Chat.UserJID) then
			local selfPresence = System.App.Chat.GetPresenceFromJID(System.App.Chat.UserJID);
			if(selfPresence) then
				MainWnd.OnSelfPresence(selfPresence);
			end
		end
		
		local ctl = CommonCtrl.GetControl("OnlineStatusSelectContextMenu");
		if(ctl == nil)then
			ctl = CommonCtrl.ContextMenu:new{
				name = "OnlineStatusSelectContextMenu",
				width = 100,
				height = 150,
			};
			local node = ctl.RootNode;
			local subNode;
			
			node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new{Text = "char", Name = "char", Type = "Group", Invisible = false, NodeHeight = 0 });
				node:AddChild(CommonCtrl.TreeNode:new({
						Text = Chat.UserStatus[1], 
						Name = Chat.UserStatus[1], 
						Type = "Menuitem", 
						onclick = "MyCompany.Aries.Chat.MainWnd.SetUserStatus(1);", 
						Icon = Chat.UserStatusIcon[1]}));
				node:AddChild(CommonCtrl.TreeNode:new({
						Text = Chat.UserStatus[2], 
						Name = Chat.UserStatus[2], 
						Type = "Menuitem", 
						onclick = "MyCompany.Aries.Chat.MainWnd.SetUserStatus(2);", 
						Icon = Chat.UserStatusIcon[2]}));
				node:AddChild(CommonCtrl.TreeNode:new({
						Text = Chat.UserStatus[3], 
						Name = Chat.UserStatus[3], 
						Type = "Menuitem", 
						onclick = "MyCompany.Aries.Chat.MainWnd.SetUserStatus(3);", 
						Icon = Chat.UserStatusIcon[3]}));
				node:AddChild(CommonCtrl.TreeNode:new({
						Text = Chat.UserStatus[4], 
						Name = Chat.UserStatus[4], 
						Type = "Menuitem", 
						onclick = "MyCompany.Aries.Chat.MainWnd.SetUserStatus(4);", 
						Icon = Chat.UserStatusIcon[4]}));
				node:AddChild(CommonCtrl.TreeNode:new({
						Text = Chat.UserStatus[6], 
						Name = Chat.UserStatus[6], 
						Type = "Menuitem", 
						onclick = "MyCompany.Aries.Chat.MainWnd.SetUserStatus(6);", 
						Icon = Chat.UserStatusIcon[6]}));
		end
		
		
		--------------------- Toolbox Region ---------------------
		
		_this = ParaUI.CreateUIObject("button", "AddContact", "_lt", 6, 6, 29, 23);
		_this.background = "Texture/Aries/Andy/ChatToolbar_AddContact_32bits.png; 0 0 27 23";
		_this.onclick = ";MyCompany.Aries.Chat.MainWnd.ToggleAddContactPanel();";
		_this.tooltip = "Add Contact";
		_toolboxRegion:AddChild(_this);
		
		local function ToggleAddContactPanel()
			local _main = ParaUI.GetUIObject("Chat_MainWnd");
			local _contactsRegion = _main:GetChild("ContactsRegion");
			local _addContactPanel = _contactsRegion:GetChild("AddContactPanel");
			_addContactPanel.visible = not _addContactPanel.visible;
			
			if(_addContactPanel.visible == true) then
				MainWnd.ShowGrey();
			else
				MainWnd.HideGreyAndPanels();
			end
		end
		MainWnd.ToggleAddContactPanel = ToggleAddContactPanel;
		
		_middle = ParaUI.CreateUIObject("container", "middle", "_ctt", 0, 6, 86, 23);
		_middle.background = "";
		_toolboxRegion:AddChild(_middle);
		
			_this = ParaUI.CreateUIObject("button", "FindContact", "_lt", 0, 0, 29, 23);
			_this.background = "Texture/Aries/Andy/ChatToolbar_Search_32bits.png; 0 0 29 23";
			_this.tooltip = "TODO: Find Contact";
			_middle:AddChild(_this);
			
			_this = ParaUI.CreateUIObject("button", "Graph", "_lt", 28, 0, 29, 23);
			_this.background = "Texture/Aries/Andy/ChatToolbar_Friends_32bits.png; 0 0 29 23";
			_this.tooltip = "TODO: Show All Friends in Graph";
			_middle:AddChild(_this);
			
			_this = ParaUI.CreateUIObject("button", "Remove", "_lt", 28 + 28, 0, 29, 23);
			_this.background = "Texture/Aries/Andy/ChatToolbar_RemoveContact_32bits.png; 0 0 29 23";
			_this.onclick = ";MyCompany.Aries.Chat.MainWnd.ToggleRemoveContactPanel();";
			_this.tooltip = "Remove Contact";
			_middle:AddChild(_this);
		
		local function ToggleRemoveContactPanel()
			local _main = ParaUI.GetUIObject("Chat_MainWnd");
			local _contactsRegion = _main:GetChild("ContactsRegion");
			local _removeContactPanel = _contactsRegion:GetChild("RemoveContactPanel");
			_removeContactPanel.visible = not _removeContactPanel.visible;
			
			if(_removeContactPanel.visible == true) then
				MainWnd.ShowGrey();
			else
				MainWnd.HideGreyAndPanels();
			end
		end
		Chat.MainWnd.ToggleRemoveContactPanel = ToggleRemoveContactPanel;
		
		
		
		--------------------- Contacts Region ---------------------
		
		local function OnClickUser(treeNode)
			
			if(mouse_button == "left") then
				local param = {[1] = treeNode.Name};
				
				NPL.load("(gl)script/kids/3DMapSystemUI/Chat/ChatWnd2.lua");
				local chatwnd = Chat.ChatWnd:CreateGetWnd(param);
				chatwnd:ShowMainWnd(true);
			else
				local ctl = CommonCtrl.GetControl("MainWnd_ContextMenu");
				if(ctl==nil)then
					NPL.load("(gl)script/ide/ContextMenu.lua");
					ctl = CommonCtrl.ContextMenu:new{
						name = "MainWnd_ContextMenu",
						width = 120,
						height = 160,
						--container_bg = "Texture/3DMapSystem/ContextMenu/BG3.png:8 8 8 8",
						--container_bg = "Texture/3DMapSystem/ContextMenu/BG2.png:8 8 8 8",
					};
					local node = ctl.RootNode;
					node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new{Text = "pe:name", Name = "pe:name", Type = "Group", NodeHeight = 0 });
					
					node:AddChild(CommonCtrl.TreeNode:new({Text = "查看信息", Name = "viewprofile", Type = "Menuitem", onclick = function()
							--System.App.Commands.Call(System.options.ViewProfileCommand, ctl.uid)
							_guihelper.MessageBox("View profile\n");
						end, Icon = "Texture/3DMapSystem/common/userInfo.png",}));
					
					node:AddChild(CommonCtrl.TreeNode:new({Text = "加为好友", Name = "addasfriend",Type = "Menuitem", onclick = function()
							--System.App.Commands.Call("Profile.Aquarius.AddAsFriend", {uid = ctl.uid});
							_guihelper.MessageBox("Add as friend\n");
						end, Icon = "Texture/3DMapSystem/common/user_add.png",}));	
					
					node:AddChild(CommonCtrl.TreeNode:new({Text = "私聊", Name = "chat", Type = "Menuitem", onclick = function()
							--System.App.Commands.Call("Profile.Chat.ChatWithContactImmediate", {uid = ctl.uid});
							_guihelper.MessageBox("Chat with contact\n");
						end, Icon = "Texture/3DMapSystem/common/chat.png",}));
					
					node:AddChild(CommonCtrl.TreeNode:new({Text = "打个招呼", Name = "poke", Type = "Menuitem", onclick = function()
							--System.App.profiles.ProfileManager.Poke(ctl.uid)
							_guihelper.MessageBox("Say Hi~~~\n");
						end, Icon = "Texture/3DMapSystem/common/wand.png",}));
							
					node:AddChild(CommonCtrl.TreeNode:new({Text = "去他的房间", Name = "teleport", Type = "Menuitem", onclick = function()
							-- TODO: 
							--_guihelper.MessageBox("他没有入住房间")
							--System.App.Commands.Call("Profile.Aquarius.NA");
							_guihelper.MessageBox("Go to his/her room\n");
						end, Icon = "Texture/3DMapSystem/common/house.png",}));
					
					node:AddChild(CommonCtrl.TreeNode:new({Text = "去他的星球", Name = "teleport", Type = "Menuitem", onclick = function()
							-- TODO: 
							--_guihelper.MessageBox("他没有拥有的星球")
							--System.App.Commands.Call("Profile.Aquarius.NA");
							_guihelper.MessageBox("Go to his/her star\n");
						end, Icon = "Texture/3DMapSystem/common/page_world.png",}));	
						
					node:AddChild(CommonCtrl.TreeNode:new({Text = "去找他", Name = "teleport", Type = "Menuitem", onclick = function()
							--System.App.profiles.ProfileManager.TeleportToUser(ctl.uid);
							_guihelper.MessageBox("Teleport to his/her place\n");
						end, Icon = "Texture/3DMapSystem/common/transmit.png",}));
						
					node:AddChild(CommonCtrl.TreeNode:new({Text = "屏蔽", Name = "blockuser", Type = "Menuitem", onclick = function()
							-- TODO: block the user in IM
							--System.App.Commands.Call("Profile.Aquarius.NA");
							_guihelper.MessageBox("Block user\n");
						end, Icon = "Texture/3DMapSystem/common/cancel.png",}));	
						
						
					--node:AddChild(CommonCtrl.TreeNode:new({Text = "访问家园", Name = "visitworld",onclick = function()
							--System.App.profiles.ProfileManager.GotoHomeWorld(ctl.uid)
						--end, Icon = "Texture/3DMapSystem/common/house.png",}));		
					--node:AddChild(CommonCtrl.TreeNode:new({Text = "打个招呼", Name = "poke", Type = "Menuitem", onclick = function()
							--System.App.profiles.ProfileManager.Poke(ctl.uid)
						--end, Icon = "Texture/3DMapSystem/common/wand.png",}));
					
					--node:AddChild(CommonCtrl.TreeNode:new({Text = "查看好友", Name = "viewfriend",Type = "Menuitem", onclick = function()
							--System.App.profiles.ProfileManager.FriendsPage(ctl.uid)
						--end, }));	
				end	
				System.App.profiles.ProfileManager.GetUserInfo(System.App.Chat.GetNameFromJID(treeNode.contact.jid), nil, function(msg) 
					if(msg and msg.users and msg.users[1]) then
						ctl.uid = msg.users[1].userid;
					else
						ctl.uid = nil;
					end
					ctl:Show();
				end, "access plus 10 year");
			end
		end
		MainWnd.OnClickUser = OnClickUser;
		
		NPL.load("(gl)script/ide/TreeView.lua");
		local param = {
				name = "treeView_Chat_Contacts",
				alignment = "_fi",
				left = 0,
				top = 0,
				width = 0,
				height = 0,
				--container_bg = "Texture/3DMapSystem/IM/white80opacity.png",
				container_bg = "",
				parent = _contactsRegion,
				DefaultIndentation = 24,
				DefaultNodeHeight = 24,
				DrawNodeHandler = MainWnd.DrawContactNodeHandler,
				onclick = MainWnd.OnClickUser,
			};
		local ctl = CommonCtrl.TreeView:new(param);
		ctl:Show();
		
		MainWnd.UpdateContactTreeView();
		
		-- inner panels and mask
		local _grey = ParaUI.CreateUIObject("button", "Grey", "_fi", 0, 0, 0, 0);
		_grey.background = "Texture/grey_32bits.png";
		_grey.visible = false;
		_grey.onclick = ";MyCompany.Aries.Chat.MainWnd.HideGreyAndPanels();";
		_contactsRegion:AddChild(_grey);
		
		local function ShowGrey()
			local _main = ParaUI.GetUIObject("Chat_MainWnd");
			local _contactsRegion = _main:GetChild("ContactsRegion");
			local _grey = _contactsRegion:GetChild("Grey");
			_grey.visible = true;
		end
		MainWnd.ShowGrey = ShowGrey;
		
		local function HideGreyAndPanels()
			local _main = ParaUI.GetUIObject("Chat_MainWnd");
			local _contactsRegion = _main:GetChild("ContactsRegion");
			local _grey = _contactsRegion:GetChild("Grey");
			local _addContactPanel = _contactsRegion:GetChild("AddContactPanel");
			local _removeContactPanel = _contactsRegion:GetChild("RemoveContactPanel");
			_grey.visible = false;
			_addContactPanel.visible = false;
			_removeContactPanel.visible = false;
		end
		MainWnd.HideGreyAndPanels = HideGreyAndPanels;
		
		local _addContactPanel = ParaUI.CreateUIObject("container", "AddContactPanel", "_ctt", 0, 0, 200, 130);
		_addContactPanel.visible = false;
		_addContactPanel.background = "Texture/Aries/Common/ContextMenu_BG_32bits.png; 0 26 64 38: 31 1 31 36";
		_contactsRegion:AddChild(_addContactPanel);
		local _text = ParaUI.CreateUIObject("text", "JIDtext", "_lt", 30, 8, 180, 24);
		_text.text = "您想要添加联系人的ID:";
		_addContactPanel:AddChild(_text);
		local _JID = ParaUI.CreateUIObject("editbox", "JID", "_lt", 35, 32, 130, 24);
		_addContactPanel:AddChild(_JID);
		--local _pala = ParaUI.CreateUIObject("text", "@pala5.cn", "_lt", 110, 35, 90, 26);
		--_pala.text = "@"..paraworld.TranslateURL("%CHATDOMAIN%");
		--_addContactPanel:AddChild(_pala);
		local _add = ParaUI.CreateUIObject("button", "Add", "_rt", -115, 67, 80, 28);
		_add.text = "添加联系人";
		_add.onclick = ";MyCompany.Aries.Chat.MainWnd.OnClickAddContact();";
		_addContactPanel:AddChild(_add);
		
		local function OnClickAddContact()
			local _main = ParaUI.GetUIObject("Chat_MainWnd");
			local _contactsRegion = _main:GetChild("ContactsRegion");
			local _addContactPanel = _contactsRegion:GetChild("AddContactPanel");
			local _JID = _addContactPanel:GetChild("JID");
			if(_JID.text == "") then
				_guihelper.MessageBox("请输入要添加联系人的ID");
			else
				local JID = _JID.text.."@"..paraworld.TranslateURL("%CHATDOMAIN%");
				_JID.text = "";
				MainWnd.AddContactImmediate(JID);
				
				MainWnd.HideGreyAndPanels();
			end
		end
		MainWnd.OnClickAddContact = OnClickAddContact;
		
		local _removeContactPanel = ParaUI.CreateUIObject("container", "RemoveContactPanel", "_ctt", 0, 0, 200, 130);
		_removeContactPanel.visible = false;
		_removeContactPanel.background = "Texture/Aries/Common/ContextMenu_BG_32bits.png; 0 26 64 38: 31 1 31 36";
		_removeContactPanel.color = "201 74 69";
		_contactsRegion:AddChild(_removeContactPanel);
		local _text = ParaUI.CreateUIObject("text", "JIDtext", "_lt", 30, 8, 180, 24);
		_text.text = "您想要删除联系人的ID:";
		_removeContactPanel:AddChild(_text);
		local _JID = ParaUI.CreateUIObject("editbox", "JID", "_lt", 35, 32, 130, 24);
		_removeContactPanel:AddChild(_JID);
		local _remove = ParaUI.CreateUIObject("button", "Add", "_rt", -115, 67, 80, 28);
		_remove.text = "删除联系人";
		_remove.color = "201 74 69";
		_remove.onclick = ";MyCompany.Aries.Chat.MainWnd.OnClickRemoveContact();";
		_removeContactPanel:AddChild(_remove);
		
		local function OnClickRemoveContact()
			local _main = ParaUI.GetUIObject("Chat_MainWnd");
			local _contactsRegion = _main:GetChild("ContactsRegion");
			local _removeContactPanel = _contactsRegion:GetChild("RemoveContactPanel");
			local _JID = _removeContactPanel:GetChild("JID");
			if(_JID.text == "") then
				_guihelper.MessageBox("请输入要删除联系人的ID");
			else
				local JID = _JID.text.."@"..paraworld.TranslateURL("%CHATDOMAIN%");
				
				if(JID ~= nil) then
					local jc = Chat.GetConnectedClient();
					if(jc ~= nil) then
						_JID.text = "";
						jc:Unsubscribe(JID, "");
					else
						_guihelper.MessageBox("您已从聊天服务器断开");
					end
				end
				MainWnd.HideGreyAndPanels();
			end
		end
		MainWnd.OnClickRemoveContact = OnClickRemoveContact;
		
	else
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		_this.visible = bShow;
	end
end

-- add contact immediately
-- @param JID: the JID of user to be added
function MainWnd.AddContactImmediate(JID)
	if(Chat.IsInContactList(JID) == false) then
		local jc = Chat.GetConnectedClient();
		if(jc ~= nil) then
			--jc:Subscribe(JID, nil, "general");
			jc:Subscribe(JID, "nameme", "General", "I am "..tostring(System.App.Chat.jid));
			autotips.AddMessageTips(string.format("已经向%s发出密友邀请", JID));
		else
			_guihelper.MessageBox("您已从聊天服务器断开");
		end
	else
		autotips.AddMessageTips(string.format("%s已经在你的通讯列表中", JID));
	end
end

-- chat with contact immediately
-- @param JID: the JID of user to be chatted to
function MainWnd.ChatWithContactImmediate(JID)
	if(JID == nil or JID == "") then
		return;
	end
	-- uplock chatting with non-contactlist JID 2008/12/27
	local param = {[1] = JID};
	
	NPL.load("(gl)script/apps/Aries/Chat/ChatWnd.lua");
	local chatwnd = Chat.ChatWnd:CreateGetWnd(param);
	chatwnd:ShowMainWnd(true);
end

function MainWnd.GetUserIconSampleFromNID(nid)
	math.randomseed(tonumber(nid) + 4);
	local iconRandomIndex = math.random(1, 6);
	local iconRandomIndex = math.random(1, 6);
	return "Texture/Aries/Andy/UserIconSample"..iconRandomIndex..".png";
end

-- set main window current user status, automaticly set the user's presence information
function MainWnd.SetUserStatus(status)
	local jc = Chat.GetConnectedClient();
	if(jc == nil or jc:IsValid() == false) then
		return;
	end
	if(status == 1) then
		jc:SetPresence(1, nil, "", 0);
	elseif(status == 2) then
		jc:SetPresence(2, nil, "", 0);
	elseif(status == 3) then
		jc:SetPresence(3, nil, "", 0);
	elseif(status == 4) then
		jc:SetPresence(4, nil, "", 0);
	elseif(status == 5) then
		jc:SetPresence(5, nil, "", 0);
	elseif(status == 6) then
		jc:SetPresence(6, nil, "", 0);
		-- NOTE: jabber will not send OnPresence message when user status is set to appeart offline
		MainWnd.OnSelfPresence(6);
	end
end

-- set main window current user status, automaticly set the user's presence information
function MainWnd.OnSelfPresence(presence)
	local jc = Chat.GetConnectedClient();
	if(jc == nil or jc:IsValid() == false) then
		return;
	end
	local _myself = ParaUI.GetUIObject("MyselfRegion");
	if(_myself:IsValid()) then
		local _icon = _myself:GetChild("btnUserMainStatus");
		local _text = _myself:GetChild("statustext");
		local _username = _myself:GetChild("username");
		_username.text = "...";
		MyCompany.Aries.Desktop.FillUIObjectWithNameFromNID(_username, jc.User);
		
		if(presence == 0) then
			status = 6;
		elseif(presence == 1) then
			status = 1;
		elseif(presence == 2) then
			status = 2;
		elseif(presence == 3) then
			status = 3;
		elseif(presence == 4) then
			status = 4;
		elseif(presence == 5) then
			status = 5;
		elseif(presence == 6) then
			status = 6;
		end
		_icon.background = Chat.UserStatusIcon[status];
		_text.text = Chat.UserStatus[status];
	end
end

function MainWnd.ShowOnlineStatusSelect()
	local _myself = ParaUI.GetUIObject("MyselfRegion");
	if(_myself:IsValid()) then
		local _icon = _myself:GetChild("btnUserMainStatus");
		local x, y, width, height = _icon:GetAbsPosition();
		local ctl = CommonCtrl.GetControl("OnlineStatusSelectContextMenu");
		if(ctl ~= nil) then
			ctl:Show(x - 3, y + height + 8);
		end
	end
end




-- owner draw function of the contact list treeview
function MainWnd.DrawContactNodeHandler(_parent, treeNode)
	if(_parent == nil or treeNode == nil) then
		return
	end
	local _this;
	local left = 2 + treeNode.TreeView.DefaultIndentation*(treeNode.Level-1); -- indentation of this node. 
	local top = 2;
	local width;
	local height = treeNode:GetHeight();
	local nodeWidth = treeNode.TreeView.ClientWidth;
	
	if(treeNode.type == "group") then
		-- render contact group TreeNode: a check box and a text button. click either to toggle the node.
		--if(treeNode:GetChildCount() > 0) then
			-- group with children
			
			-- button
			_this = ParaUI.CreateUIObject("button", "b", "_fi", 1, 0, 1, 0);
			--_this.background = "";
			--_guihelper.SetVistaStyleButton(_this, nil, "Texture/3DMapSystem/IM/lightblue.png");
			_this.background = "Texture/Aries/Andy/ChatGroup_32bits.png: 4 4 4 4";
			_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
			_this.onclick = string.format(";CommonCtrl.TreeView.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			_parent:AddChild(_this);
			
			-- text
			local textWidth = _guihelper.GetTextWidth((treeNode.Text or "").." ("..treeNode:GetChildCount()..")");
			_this = ParaUI.CreateUIObject("button", "b", "_lt", left + 24 + 5, 0, textWidth, height);
			_this.background = "";
			_this.enabled = false;
			_guihelper.SetFontColor(_this, "120 120 120");
			_this.text = (treeNode.Text or "").." ("..treeNode:GetChildCount()..")";
			_parent:AddChild(_this);
			
			-- checkbox
			_this = ParaUI.CreateUIObject("button", "b", "_lt", left + 4, (height - 24)/2 + 4, 16, 16);
			_this.onclick = string.format(";CommonCtrl.TreeView.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			_parent:AddChild(_this);
			
			if(treeNode.Expanded) then
				--_this.background = "Texture/3DMapSystem/Chat/group_arrow_down.png; 0 0 24 24";
				_this.background = "Texture/3DMapSystem/Chat/ItemOpenGrey.png";
			else
				--_this.background = "Texture/3DMapSystem/Chat/group_arrow_right.png; 0 0 24 24";
				_this.background = "Texture/3DMapSystem/Chat/ItemCloseGrey.png";
			end
			
			
		--else
			---- no users in this group
			--_this=ParaUI.CreateUIObject("button","b","_lt", left, top , width, width);
			--_parent:AddChild(_this);
			--left = left + width + 2;
			--
			--if(treeNode.Expanded) then
				--_this.background = "Texture/3DMapSystem/IM/group-arrow-down.png";
			--else
				--_this.background = "Texture/3DMapSystem/IM/group-arrow-right.png";
			--end
			--
			--_this=ParaUI.CreateUIObject("text","b","_lt", left, 0, nodeWidth - left-1, height);
			--_parent:AddChild(_this);
			--_this:GetFont("text").format=36; -- single line and vertical align
			--
			---- set text
			--_this.text = (treeNode.Text or "").." (空)";
		--end
	elseif(treeNode.type == "user") then
		-- render user TreeNode: user status icon(according to presence, click to open dialog) + text button(NickName+Message) + tooltip (full information). 
		size = 24; -- status icon width
		
		_this = ParaUI.CreateUIObject("button", "b", "_fi", 1, 0, 1, 0);
		if(math.mod(treeNode.index, 2) == 0) then
			_this.background = "Texture/Aries/Andy/ContactEven.png";
		else
			_this.background = "Texture/Aries/Andy/ContactOdd.png";
		end
		_parent:AddChild(_this);
		
		-- button
		_this = ParaUI.CreateUIObject("button", "b", "_fi", 1, 0, 1, 0);
		_parent:AddChild(_this);
		if(math.mod(treeNode.index, 2) == 0) then
			_guihelper.SetVistaStyleButton(_this, "", "Texture/Aries/Common/ContextMenu_ItemBG_32bits.png: 1 1 1 1");
		else
			_guihelper.SetVistaStyleButton(_this, "", "Texture/Aries/Common/ContextMenu_ItemBG_32bits.png: 1 1 1 1");
		end
		_guihelper.SetUIFontFormat(_this, 36 + size); -- single line and vertical align
		_this.onclick = string.format(";CommonCtrl.TreeView.OnClickNode(%q,%q)", treeNode.TreeView.name, treeNode:GetNodePath());
		_this.onmouseenter = string.format(";MyCompany.Aries.Chat.MainWnd.OnEnterContact(%q)", "name_"..treeNode:GetNodePath());
		_this.onmouseleave = string.format(";MyCompany.Aries.Chat.MainWnd.OnLeaveContact(%q)", "name_"..treeNode:GetNodePath());
		
		function MainWnd.OnEnterContact(nameObj)
			local _name = ParaUI.GetUIObject(nameObj);
			if(_name:IsValid() == true) then
				_guihelper.SetFontColor(_name, "255 255 255");
			end
		end
		function MainWnd.OnLeaveContact(nameObj)
			local _name = ParaUI.GetUIObject(nameObj);
			if(_name:IsValid() == true) then
				_guihelper.SetFontColor(_name, "0 0 0");
			end
		end
		
		-- status icon
		local _icon = ParaUI.CreateUIObject("button", "icon", "_lt", 4, 9, 16, 16);
		local presence = System.App.Chat.GetPresenceFromJID(treeNode.contact.jid);
		presence = presence or 6;
		_icon.background = Chat.UserStatusIcon[presence];
		_parent:AddChild(_icon);
		
		-- name
		local displaytext = treeNode.contact.name;
		if(type(treeNode.contact.NickName) == "string") then
			displaytext = displaytext..treeNode.contact.NickName;
		end
		local textWidth = _guihelper.GetTextWidth(displaytext, System.DefaultFontString);
		_this = ParaUI.CreateUIObject("text", "name_"..treeNode:GetNodePath(), "_lt", 30, 10, 500, 24);
		_this.background = "";
		_this.enabled = false;
		_this.text = displaytext;
		
		_parent:AddChild(_this);
		
		local nid = System.App.Chat.GetNameFromJID(treeNode.contact.jid);
		MyCompany.Aries.Desktop.FillUIObjectWithNameFromNID(_this, nid);
		
		-- user icon
		local _user = ParaUI.CreateUIObject("container", "usericon", "_rt", -(7+28), 3, 28, 28);
		local nid = System.App.Chat.GetNameFromJID(treeNode.contact.jid);
		_user.background = "Texture/3DMapSystem/TEMP/Profile/UnKnownPhoto100.png";
		_user.enabled = false;
		_parent:AddChild(_user);
		
		MyCompany.Aries.Desktop.FillUIObjectWithPhotoFromNIDImmediate(_user, nid);
	end
end
	
-- Show the Chat main window
function MainWnd.UpdateContactTreeView()
	--commonlib.echo("warning: MainWnd.UpdateContactTreeView() why this is called without even open it. lxz 2008.6.19?\n")
	local treeView = CommonCtrl.GetControl("treeView_Chat_Contacts");
	if(treeView ~= nil) then
		local rosterGroups, rosterItems = Chat.GetContactList();
		-- clear all children and update the treeview with the new contact list
		treeView.RootNode:ClearAllChildren();
		local node = treeView.RootNode;
		local _, groupname;
		for _, groupname in pairs(rosterGroups) do
			node:AddChild(CommonCtrl.TreeNode:new({Text = groupname, Name = groupname, type = "group", NodeHeight = 20, }));
		end
		
		local i, contact;
		for i, contact in pairs(rosterItems) do
			local groupNode;
			if(contact.presence == nil or contact.presence == 6) then
				-- add to offline contact group
				groupNode = treeView.RootNode:GetChildByName("Offline Contacts");
				if(groupNode:GetChildByName(contact.jid) == nil) then
					-- avoid multiple insert into the offline contacts if contact belongs to multiple groups
					groupNode:AddChild( CommonCtrl.TreeNode:new({Text = contact.jid, Name = contact.jid, type = "user", NodeHeight = 34, contact = contact,}) );
				end
			else
				local i, groupname;
				for i, groupname in pairs(contact.groups) do
					groupNode = treeView.RootNode:GetChildByName(groupname);
					if(groupNode) then
						groupNode:AddChild( CommonCtrl.TreeNode:new({Text = contact.jid, Name = contact.jid, type = "user", NodeHeight = 34, contact = contact,}) );
					end
				end
			end
		end
		-- update UI
		treeView:Update();
	end
end