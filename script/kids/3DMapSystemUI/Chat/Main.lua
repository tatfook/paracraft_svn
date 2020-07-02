--[[
Title: new chat system for 3D Map system
Author(s): WangTian
Date: 2008/5/27, Autoreconnect added LiXizhi 2009.1.15
Desc: Chat system main
Chat system is based on the Jabber client and works as a part of the paraworld online experience. OneTimeInit funciton is part of 
	login procedure. Users are organized in groups(router in jabber) and shown with user icon picture and online status.
	Chat system provides a chat window for each contact. The chat window can also minimized to icons lined on the right bottom corner
	of the screen, right above the status bar.

Version History:
2009-2-12: long name display bug fixed in online/offline notification

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Chat/Main.lua");
Map3DSystem.App.Chat.OneTimeInit();
-- call Map3DSystem.App.Chat.InitJabber periodically if disconnected. 
Map3DSystem.App.Chat.InitJabber();
-- they contains the jid
Map3DSystem.App.Chat.jid;
Map3DSystem.App.Chat.UserJID;
-- call cleanup to reset. 
Map3DSystem.App.Chat.CleanUp()
------------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemUI/Chat/MainWnd2.lua");

local Chat = commonlib.gettable("Map3DSystem.App.Chat");
local LOG = LOG;

-- private: 
Chat.LastConnectionTime = 0;
-- connect timer
Chat.ConnectTimer = -100000;
-- only reconnect every 20 seconds
Chat.ConnectPeriod = 20000; -- 20000 milliseconds
-- once ondisconnected, we will try to Auto reconnect by 2 times before waiting until the next ConnectPeriod
Chat.AutoConnectCount = 2;
Chat.ReconnectCount_ = 0; 
	
-- log chat application event traffic
local LOG_CHAT_JC_TRAFFIC = true;

-- a mapping from event name to their callback functions
local jc_event_callbacks = {};

-- one time initialize to chat system
-- Call Map3DSystem.App.Chat.OneTimeInit() at authentication success
-- login to JGSL chat during login procedure, see Map3DSystem.App.Login.Proc_Authentication
-- including:
--		1. init the jabber client instant messanger
--		2. init the os.window object for message process
function Chat.OneTimeInit()
	if(not Chat.IsInit) then
		Chat.IsInit = true;
		-- init the jabber client using the user ID to log in jabber server: Map3DSystem.User.userid
		Chat.InitJabber();
		
		-- init the os.window object for message process
		local _app = Chat.app._app;
		local _wnd = _app:FindWindow("JCMain") or _app:RegisterWindow("JCMain", nil, Chat.MSGProc);	
	end
end

-- disconnect and cleanup Chat. 
function Chat.CleanUp()
	Chat.IsInit = nil;
	Chat.jid = nil;
	Chat.UserJID = nil;
	Chat.LastConnectionTime = 0;
	-- connect timer
	Chat.ConnectTimer = -100000;
	-- only reconnect every 20 seconds
	Chat.ConnectPeriod = 20000; -- 20000 milliseconds
	-- once ondisconnected, we will try to Auto reconnect by 2 times before waiting until the next ConnectPeriod
	Chat.AutoConnectCount = 2;
	Chat.ReconnectCount_ = 0; 
	
	if(Chat.jc)	 then
		local jc = Chat.jc;
		Chat.jc = nil;
		jc:Close();
	end
end

-- Get default jabber client, create if not exist
-- It does not open a connection immediately.
function Chat.GetClient()
	if(not Chat.jc and Chat.jid) then
		Chat.UserJID = Chat.jid;
		local jc = JabberClientManager.CreateJabberClient(Chat.jid);
		Chat.jc = jc;
		
		jc:ResetAllEventListeners();
		
		-- bind event to map 3d system chat
		jc:AddEventListener("JE_OnConnect", "Map3DSystem.App.Chat.OnConnect()");
		jc:AddEventListener("JE_OnAuthenticate", "Map3DSystem.App.Chat.OnAuthenticate()");
		jc:AddEventListener("JE_OnDisconnect", "Map3DSystem.App.Chat.OnDisconnect()");
		jc:AddEventListener("JE_OnAuthError", "Map3DSystem.App.Chat.OnAuthError()");
		jc:AddEventListener("JE_OnError", "Map3DSystem.App.Chat.OnError()");
		
		jc:AddEventListener("JE_OnMessage", "Map3DSystem.App.Chat.OnMessage()");
		jc:AddEventListener("JE_OnStanzaMessageChat", "Map3DSystem.App.Chat.OnStanzaMessageChat()"); -- TODO
		
		jc:AddEventListener("JE_OnRoster", "Map3DSystem.App.Chat.OnRoster()"); -- TODO
		jc:AddEventListener("JE_OnSubscriptionRequest", "Map3DSystem.App.Chat.OnSubscription()");
		jc:AddEventListener("JE_OnUnsubscriptionRequest", "Map3DSystem.App.Chat.OnUnsubscription()");
		
		jc:AddEventListener("JE_OnSelfPresence", "Map3DSystem.App.Chat.OnSelfPresence()"); -- TODO
		jc:AddEventListener("JE_OnRosterPresence", "Map3DSystem.App.Chat.OnRosterPresence()"); -- TODO
	end
	return Chat.jc
end

-- get the currently connected client. return nil, if connection is not valid
function Chat.GetConnectedClient()
	local jc = Chat.GetClient();
	if(jc and jc:GetIsAuthenticated()) then
		return jc;
	end
end

-- this function will return true if nMilliSecondsPassed is passed since last timer of timerName is set
-- @param timerName: such as "ConnectTimer"
-- @param nMilliSecondsPassed: such as 20000 milliseconds
-- @param bUpdateIfTrue: whether it will update last connection time if true.
function Chat.CheckLastTime(timerName, nMilliSecondsPassed, bUpdateIfTrue)
	local nTime = ParaGlobal.GetGameTime();
	if((nTime - Chat[timerName]) > nMilliSecondsPassed ) then -- 20000 milliseconds
		if(bUpdateIfTrue) then
			Chat[timerName] = nTime;
		end	
		return true;
	end
end

function Chat.StartTimer()
	Chat.timer = Chat.timer or commonlib.Timer:new({callbackFunc = Chat.OnTimer});
	Chat.timer:Change(Chat.ConnectPeriod, Chat.ConnectPeriod);
end

-- the current chat server(host:port) to try to connect to. 
Chat.ServerIndex = 1;

-- initiate the instant messager client
-- @param username: user name
-- @param password: password
-- @param chat_domain: server name, "paraweb3d.com", "pala5.cn", "192.168.0.223" .etc
-- such as Map3DSystem.App.Chat.InitIM("andy", "1234567", "pala5.cn")
function Chat.InitJabber(username, password, chat_domain)
	
	username = username or Map3DSystem.User.nid;
	password = password or Map3DSystem.User.ejabberdsession or Map3DSystem.User.Password;
	chat_domain = chat_domain or Map3DSystem.User.ChatDomain;
	
	-- jabber client name
	Chat.jid = username.."@"..chat_domain;
	Chat.UserJID = Chat.jid;
	
	local jc = Chat.GetClient();
	if(jc) then
		if(not jc:GetIsAuthenticated()) then
			if(Chat.AllowRetry or  Chat.CheckLastTime("ConnectTimer", Chat.ConnectPeriod, true)) then -- 20000 milliseconds
				Chat.AllowRetry = nil;
				jc.Password = password;
				
				local address = Map3DSystem.User.ChatServers[Chat.ServerIndex];
				if(address) then
					if(address.host) then	
						jc.Server = address.host;
					end
					if(address.port) then	
						jc.Port = tonumber(address.port);
					end
				else
					if(Map3DSystem.User.ChatPort) then	
						jc.Port = tonumber(Map3DSystem.User.ChatPort);
					end
				end
				
				-- open the connection
				if(not jc:Connect()) then
					LOG.std("", "warning", "JC", "warning: cannot make connection for %s (%s:%s)", Chat.jid, jc.Server, jc.Port);
				else
					LOG.std("", "system", "JC", "connecting to JC %s (%s:%s) ...", Chat.jid, jc.Server, jc.Port);
					Chat.StartTimer();	
				end
			else
				LOG.std("", "warning", "JC", "you can not connect when you have just making a connection attempt a while ago");
			end	
		else
			LOG.std("", "warning", "JC", "already connected to "..Chat.jid);
		end	
	else
		LOG.std("", "warning", "JC", "Invalid JC client");	
	end
end

------------------------- Connect and Auth Event -------------------------

-- add a function call back to a given JC event 
-- TODO: use hook for other message types. 
-- @param JE_EventName: currently only "JE_OnAuthenticate" and "JE_OnDisconnect" is supported. 
-- @param funcCallBack: it is of type function(msg) end
function Chat.AddEventListener(JE_EventName, funcCallBack)
	jc_event_callbacks[JE_EventName] = funcCallBack;
end

-- fire a given event. 
-- event beginning with JE is Jabber Event, such as "JE_OnAuthenticate"
-- event beginning with CE is Chat Event, such as "CE_OnBecomeOnline"
function Chat.FireEvent(JE_EventName, msg)
	if(type(jc_event_callbacks[JE_EventName]) == "function") then
		jc_event_callbacks[JE_EventName](msg);
		return true;
	end
end

function Chat.OnConnect()
	if(LOG_CHAT_JC_TRAFFIC == true) then
		LOG.std("", "debug", "JC", {"OnConnect:", msg});
	else
		LOG.std("", "system", "JC", "Chat: connection established.");
	end
	if(Chat.timer) then
		Chat.timer:Change();
	end	
end

function Chat.OnAuthenticate()
	if(LOG_CHAT_JC_TRAFFIC == true) then
		LOG.std("", "debug", "JC", {"OnAuthenticate:", msg});
	else
		LOG.std("", "system", "JC", "Chat: connection authenticated.");
	end
	Chat.ReconnectCount_ = 0;
	Chat.FireEvent("JE_OnAuthenticate", msg);
end

function Chat.OnDisconnect()
	if(LOG_CHAT_JC_TRAFFIC == true) then
		LOG.std("", "debug", "JC", {"OnDisconnect:", msg});
	else
		LOG.std("", "system", "JC", "Chat: connection disconnected.");
	end
	if(not Chat.jc) then
		return
	end
	if (Chat.ReconnectCount_ < Chat.AutoConnectCount) then
		Chat.ReconnectCount_ = Chat.ReconnectCount_ +1;
		LOG.std("", "system", "JC", "auto reconnecting on the %d times", Chat.ReconnectCount_)
		Chat.AllowRetry = true; -- this will bypass the connectperiod check and reconnect immediately. 
		Chat.InitJabber();
	else
		LOG.std("", "system", "JC", "we shall wait %d milliseconds before trying again.", Chat.ConnectPeriod)
		Chat.StartTimer()
	end
	
	Chat.FireEvent("JE_OnDisconnect", msg);
end

-- set timer
function Chat.OnTimer()
	Chat.InitJabber();
	-- try next server
	if( not Map3DSystem.User.ChatServers[Chat.ServerIndex+1]) then
		Chat.ServerIndex = 1;
	else
		Chat.ServerIndex = Chat.ServerIndex + 1;
	end
end

function Chat.OnAuthError()
	if(LOG_CHAT_JC_TRAFFIC == true) then
		LOG.std("", "debug", "JC", {"OnAuthError:", msg});
	else
		LOG.std("", "error", "JC", "Chat: An error occured during authentication:");
		LOG.std("", "error", "JC", msg);
	end
end

function Chat.OnError()
	if(LOG_CHAT_JC_TRAFFIC == true) then
		LOG.std("", "debug", "JC", {"OnError:", msg});
	else
		LOG.std("", "error", "JC","Chat: An error occured:");
		LOG.std("", "error", "JC",msg);
	end
end

------------------------- Common Event -------------------------

function Chat.OnMessage()
	if(LOG_CHAT_JC_TRAFFIC == true) then
		LOG.std("", "debug", "JC", {"OnMessage:", msg});
	end
	
	if(msg and msg.subtype) then
		if( msg.subtype == 2 or msg.subtype == 32 or msg.subtype == 8192) then
			-- the client msg.from is possibly offline, since we received an invalid message, here. 
			-- because server is epoll style, we do nothing about it. 
			LOG.std("", "system", "JC", "offine jabber message received:")
			LOG.std("", "system", "JC", msg)
			return;
		end
	end
	
	if(Chat.FireEvent("JE_OnMessage", msg) ~= true) then
		-- if no event callback is avaiable, invoke the default implementation
		Map3DSystem.App.Chat.OnReceiveChatMessage(msg);
	end
end

-- on receive chat message
function Chat.OnReceiveChatMessage(msg)
	--["type"]=5,
	--["body"]="fdadafd",
	--["from"]="andy2@pala5.cn/ParaWorld Chat",
			
	-- TODO: tell this message from one contact or multiple contact chatting
	
	-- check the UI avaiability, if Chat application is not visualized, push to buffer
	if(Map3DSystem.App.Chat.MainWnd.IsUIAvailable() == true) then
		Map3DSystem.App.Chat.VisualizeMessage(msg.from, msg.subject, msg.body);
	else
		msg.type = "OnMessage";
		Chat.AttachPendingMSG(msg);
	end
end

-- show the message with ChatWnd
-- @param JID
-- @param subject
-- @param body
function Map3DSystem.App.Chat.VisualizeMessage(JID, subject, body)
	
	local param = {[1] = JID};
	
	NPL.load("(gl)script/kids/3DMapSystemUI/Chat/ChatWnd2.lua");
	local chatwnd = Map3DSystem.App.Chat.ChatWnd:CreateGetWnd(param);
	local isVisible = chatwnd:GetVisible();
	if(isVisible == nil) then
		chatwnd:ShowMainWnd(true, true); -- silent init without showing the window
	elseif(isVisible == true) then
		--chatwnd:ShowMainWnd(true); -- keep the window frame visibility
	elseif(isVisible == false) then
		--chatwnd:ShowMainWnd(false); -- keep the window frame visibility
	end
	chatwnd:RecvMSG(JID, subject, body);
end

function Chat.OnStanzaMessageChat()
	if(LOG_CHAT_JC_TRAFFIC == true) then
		LOG.std("", "debug", "JC", {"OnStanzaMessageChat:", msg});
	end
end

-- pending messages
-- these messages usually need MessageBox to show, the message will queue up for the DoPendingMSGTimer() to 
-- show on screen one by one, otherwise the next message will close the previous messagebox
Chat.PendingMSGs = Chat.PendingMSGs or {};
-- client user interface may get the PnRoster messaged that received before ui objects are created
function Chat.GetPendingMSGs()
	return Chat.PendingMSGs or {};
end
-- attach pending message
function Chat.AttachPendingMSG(msg)
	commonlib.log(msg)
	table.insert(Chat.PendingMSGs, msg);
end

function Chat.OnRoster()
	if(LOG_CHAT_JC_TRAFFIC == true) then
		LOG.std("", "debug", "JC", {"OnRoster:", msg});
	end
	
	local i, m;
	for i, m in ipairs(msg) do
		m.type = "OnRoster";
		Chat.AttachPendingMSG(m);
	end
end

function Chat.OnSubscription()
	if(LOG_CHAT_JC_TRAFFIC == true) then
		LOG.std("", "debug", "JC", {"OnSubscription:", msg});
	end
	msg.type = "OnSubscription";
	Chat.AttachPendingMSG(msg);
end

function Chat.OnUnsubscription()
	if(LOG_CHAT_JC_TRAFFIC == true) then
		LOG.std("", "debug", "JC", {"OnUnsubscription:", msg});
	end
	msg.type = "OnUnsubscription";
	Chat.AttachPendingMSG(msg);
end

-- presence mapping, updated every time jabber client receives a presence message
Chat.JID_Presence_mapping = {};

function Chat.OnSelfPresence()
	if(LOG_CHAT_JC_TRAFFIC == true) then
		LOG.std("", "debug", "JC", {"OnSelfPresence:", msg});
	end
	Chat.JID_Presence_mapping[msg.jid] = msg.presence;
	
	if(Chat.FireEvent("JE_OnSelfPresence", msg) ~= true) then
		-- if no event callback is avaiable, invoke the default implementation
		Map3DSystem.App.Chat.MainWnd.OnSelfPresence(msg.presence);
	end
end

function Chat.OnRosterPresence()
	if(LOG_CHAT_JC_TRAFFIC == true) then
		LOG.std("", "debug", "JC", {"OnRosterPresence:", msg});
	end
	
	local oldPresence = Chat.JID_Presence_mapping[msg.jid] or 5;
	Chat.JID_Presence_mapping[msg.jid] = msg.presence;
	
	if(Chat.FireEvent("JE_OnRosterPresence", msg) ~= true) then
		-- if no event callback is avaiable, invoke the default implementation
		--NOTE 2009/11/19: change Presence to PresenceType 0.97 -> 1.0
		--if(oldPresence == 6 and msg.presence ~= 6 and msg.presence ~= 0) then
		if(oldPresence == 5 and msg.presence and msg.presence < 5) then
			-- become online
			if(Chat.FireEvent("CE_OnBecomeOnline", msg) ~= true) then
				Chat.UpdateContactList();
				local jid = msg.jid;
				
				--MyCompany.Aquarius.Desktop.Dock.ShowNotification(function (_parent)
					--if(_parent == nil or _parent:IsValid() == false) then
						--return;
					--end
					--
					--local _notify = ParaUI.CreateUIObject("container", "items", "_lt", 10, 0, 180, 128);
					--_notify.background = "";
					--_parent:AddChild(_notify);
					--
					--local _icon = ParaUI.CreateUIObject("button", "icon", "_lt", 16, 40, 48, 48);
					--_icon.background = nil;
					--_notify:AddChild(_icon);
					--MyCompany.Aquarius.Desktop.FillUIObjectWithPhotoFromNIDImmediate(_icon, Chat.GetNameFromJID(jid));
					--
					--local _name = ParaUI.CreateUIObject("text", "name", "_lt", 80, 42, 160, 24);
					--_name.background = "";
					--_name.text = Chat.GetNameFromJID(jid);
					--_name.font = System.DefaultBoldFontString;
					--_notify:AddChild(_name);
					--MyCompany.Aquarius.Desktop.FillUIObjectWithNameFromNID(_name, Chat.GetNameFromJID(jid));
					--local _text = ParaUI.CreateUIObject("text", "text", "_lt", 80, 64, 60, 24);
					--_text.background = "";
					--_text.text = "上线了";
					--_notify:AddChild(_text);
				--end, function ()
					--local param = {[1] = jid};
					--NPL.load("(gl)script/kids/3DMapSystemUI/Chat/ChatWnd2.lua");
					--local chatwnd = Map3DSystem.App.Chat.ChatWnd:CreateGetWnd(param);
					--chatwnd:ShowMainWnd(true);
				--end)
			end
		elseif(msg.presence == 5) then
			-- become offline
			if(Chat.FireEvent("CE_OnBecomeOffline", msg) ~= true) then
				Chat.UpdateContactList();
				local jid = msg.jid;
				
				--MyCompany.Aquarius.Desktop.Dock.ShowNotification(function (_parent)
					--if(_parent == nil or _parent:IsValid() == false) then
						--return;
					--end
					--
					--local _notify = ParaUI.CreateUIObject("container", "items", "_lt", 10, 0, 180, 128);
					--_notify.background = "";
					--_parent:AddChild(_notify);
					--
					--local _icon = ParaUI.CreateUIObject("button", "icon", "_lt", 16, 40, 48, 48);
					--_icon.background = nil;
					--_notify:AddChild(_icon);
					--MyCompany.Aquarius.Desktop.FillUIObjectWithPhotoFromNIDImmediate(_icon, Chat.GetNameFromJID(jid));
					--
					--local _name = ParaUI.CreateUIObject("text", "name", "_lt", 80, 42, 160, 24);
					--_name.background = "";
					--_name.text = Chat.GetNameFromJID(jid);
					--_name.font = System.DefaultBoldFontString;
					--_notify:AddChild(_name);
					--MyCompany.Aquarius.Desktop.FillUIObjectWithNameFromNID(_name, Chat.GetNameFromJID(jid));
					--local _text = ParaUI.CreateUIObject("text", "text", "_lt", 80, 64, 60, 24);
					--_text.background = "";
					--_text.text = "下线了";
					--_notify:AddChild(_text);
				--end);
			end
		end
	end
end


-- update contact list
--		in online mode, contact information is retrieved from the jabber client
--		in offline mode, contact information is retrieved from the history
function Chat.UpdateContactList()
	
	-- roster groups
	Chat.RosterGroups = {};
	-- roster items
	Chat.RosterItems = {};
	
	local jc = Chat.GetConnectedClient();
	if(jc == nil) then
		LOG.std("", "error", "JC", "error UpdateContactList: invalid jabber client");
		return;
	end
	if(jc:GetIsAuthenticated() ~= true) then
		LOG.std("", "error", "JC", "error UpdateContactList: jabber client not authenticated");
		return;
	end
	
	local function DoesGroupExist(groupname)
		local i, name;
		for i, name in ipairs(Chat.RosterGroups) do
			if(name == groupname) then
				return true;
			end
		end
		return false;
	end
	
	local rostor = jc:GetRoster();
	if(type(rostor) == "string") then
		rostor = commonlib.LoadTableFromString(rostor);
	end
	if(roster) then
		LOG.std("", "system", "JC", "main fetching roster...");
		local _, item
		for _, item in ipairs(roster) do
			if(item.subscription == 0) then
				-- S10nNone: 
				--Contact and user are not subscribed to each other, and neither has requested a subscription from the other.
			else
				--local userDetail = commonlib.LoadTableFromString(jc:GetRosterItemDetail(item.jid));
				local presence = Chat.JID_Presence_mapping[item.jid];
				item.presence = presence;
				
				-- first get userinfo of the contact on each roster fetching
				Map3DSystem.App.profiles.ProfileManager.GetUserInfo(Chat.GetNameFromJID(item.jid), "FetchingRosterGetUserInfo");
				
				if(item.subscription == 8 or item.subscription == 4) then
					-- we show online contact ONLY at least user subscribed to contact
					--subscription 4: S10nTo, User is subscribed to contact (one-way).
					--subscription 8: S10nBoth, User and contact are subscribed to each other (two-way).
					table.insert(Chat.RosterItems, item);
				end
				
				LOG.std("", "system", "JC", "JID: %s; name:%s; groups: subscription:%d", item.jid, item.name, item.subscription);
				local _, group 
				for _, group in ipairs(item.groups) do
					--commonlib.log(group);
					if(DoesGroupExist(group) == false) then
						table.insert(Chat.RosterGroups, group);
					end
				end
				local _, resource
				for _, resource in ipairs(item.resources) do
					--commonlib.log(resource);
				end
			end
		end
	end
	
	-- offline contact group
	table.insert(Chat.RosterGroups, "Offline Contacts");
	
	-- if main window UI is avaiable update the contact treeview
	if(Chat.MainWnd.IsUIAvailable())then
		Chat.MainWnd.UpdateContactTreeView();
	end
end

-- get the roster groups and roster items
-- @return: RosterGroups and RosterItems
function Chat.GetContactList()
	if(Chat.RosterGroups == nil or Chat.RosterItems == nil 
		or Chat.RosterGroups == {} or Chat.RosterItems == {}) then
		-- update the contact list when no group and items information found
		Chat.UpdateContactList();
	end
	return Chat.RosterGroups, Chat.RosterItems;
end

-- is JID in contact list
-- @param: JID of the user
function Chat.IsInContactList(JID)
	local rosterGroups, rosterItems = Chat.GetContactList();
	
	local _, contact;
	for _, contact in pairs(rosterItems) do
		-- log("contact: ");commonlib.echo(contact);
		if(contact.jid == JID and contact.subscription == 9) then 
			-- subscription: 9
			-- S10nBoth: User and contact are subscribed to each other (two-way).
			return true;
		end
	end
	return false;
end

-- return the name of a Jabber ID, if not including any "@" sign the whole JID is returned
-- @param sJID: the given JID
-- @return: the name of the JID
-- e.g. for JID:"andy@paraweb3d.com" it returns "andy"
function Chat.GetNameFromJID(sJID)
	if(sJID) then
		local _at = string.find(sJID, "@", 1);
		local _name;
		if(_at == nil) then
			return sJID;
		else
			return string.sub(sJID, 1, _at - 1);
		end
	end
end

-- Message Processor of Chat jabber client
-- it handles various messages
function Chat.MSGProc(window, msg)
end

-- get the presence status from JID
-- NOTE: the status is in-memory presence status that will be updated with jabber events
-- @return: presence status, nil if not valid
function Chat.GetPresenceFromJID(JID)
	return Chat.JID_Presence_mapping[JID];
end
