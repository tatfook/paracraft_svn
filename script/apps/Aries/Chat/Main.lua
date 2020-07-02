--[[
Title: new chat system for 3D Map system
Author(s): WangTian
Date: 2009/4/9
Desc: Chat system main
Chat system is based on the Jabber client and works as a part of the paraworld online experience. OneTimeInit funciton is part of 
	login procedure. Users are organized in groups(router in jabber) and shown with user icon picture and online status.
	Chat system provides a chat window for each contact. The chat window can also minimized to icons lined on the right bottom corner
	of the screen, right above the status bar.

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Chat/Main.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Chat/BadWordFilter.lua");
local BadWordFilter = commonlib.gettable("MyCompany.Aries.Chat.BadWordFilter");
NPL.load("(gl)script/apps/Aries/Friends/BuddyList.lua");
NPL.load("(gl)script/apps/Aries/Friends/Main.lua");
-- create class
local libName = "AriesChat";
local Chat = commonlib.gettable("MyCompany.Aries.Chat");

NPL.load("(gl)script/apps/Aries/Chat/MainWnd.lua");
NPL.load("(gl)script/apps/Aries/Chat/ChatWnd.lua");

NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/ChatChannel.lua");
local ChatChannel = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatChannel");

NPL.load("(gl)script/apps/Aries/Combat/main.lua");
local Combat = commonlib.gettable("MyCompany.Aries.Combat");

local chat_app = commonlib.gettable("System.App.Chat");
-- one time init of Aries chat
function Chat.Init()
	if(Chat.IsInit) then return end
	Chat.IsInit = true;
	
	System.App.Chat.AddEventListener("JE_OnMessage", function(msg)
		Chat.OnReceiveChatMessage(msg);
	end)
	
	System.App.Chat.AddEventListener("JE_OnSelfPresence", function(msg)
		Chat.MainWnd.OnSelfPresence(msg);
	end)
	
	--System.App.Chat.AddEventListener("OnRosterPresence", function(msg)
		--Chat.OnRosterPresence(msg);
	--end)
	
	System.App.Chat.AddEventListener("CE_OnBecomeOnline", function(msg)
		Chat.OnBecomeOnline(msg);
	end)
	
	System.App.Chat.AddEventListener("CE_OnBecomeOffline", function(msg)
		Chat.OnBecomeOffline(msg);
	end)
end

-- get the currently connected client. return nil, if connection is not valid
function Chat.GetConnectedClient()
	if(chat_app.GetConnectedClient) then
		return chat_app.GetConnectedClient();
	end
end

-- on receive chat message
function Chat.OnReceiveChatMessage(msg)
	--["type"]=5,
	--["body"]="fdadafd",
	--["from"]="andy2@pala5.cn/ParaWorld Chat",
			
	-- TODO: tell this message from one contact or multiple contact chatting
	--if(MyCompany.Aries.Friends.RecentContactListPage.allowmosheng~=true)then
		--local dsTable = {};
		--MyCompany.Aries.Friends.BuddyListPage.GetFriends(nil,"access plus 10 minutes", dsTable);
		--return;
	--end

	-- check the UI avaiability, if Chat application is not visualized, push to buffer
	if(MyCompany.Aries.Friends.IsUIAvailable() ~= true) then
		LOG.std(nil, "debug", "ChatReceived", msg)
		-- retry every 5 seconds
		local msg = commonlib.deepcopy(msg);
		UIAnimManager.PlayCustomAnimation(1000, function(elapsedTime)
			if(elapsedTime == 1000) then
				Chat.OnReceiveChatMessage(msg);
			end
		end);
		return;
	end
	
	LOG.std(nil, "debug", "ChatReceived Silient", msg)
	
	if(string.find(msg.body, "^%[Aries%]") == 1) then
		----------FriendSystemDebugStep2----------
		local nid = string.match(msg.body, "^%[Aries%]%[AddFriendRequest%]:(%d+)$");
		if(nid) then
			nid = tonumber(nid);
			NPL.load("(gl)script/apps/Aries/Friends/Main.lua");
			MyCompany.Aries.Friends.ReceiveFriendRequest(nid);
		end
		----------FriendSystemDebugStep3----------
		local nid = string.match(msg.body, "^%[Aries%]%[AddFriendReply%]:(%d+)$");
		if(nid) then
			nid = tonumber(nid);
			NPL.load("(gl)script/apps/Aries/Friends/Main.lua");
			MyCompany.Aries.Friends.ConfirmFriendReply(nid);
		end
		
		local nid = string.match(msg.body, "^%[Aries%]%[PositionQueryRequest%]:(%d+)$");
		if(nid) then
			nid = tonumber(nid);
			NPL.load("(gl)script/apps/Aries/Friends/Main.lua");
			MyCompany.Aries.Friends.RecvPositionQueryRequest(nid);
		end
		
		local reply = string.match(msg.body, "^%[Aries%]%[PositionQueryReply%]:(.+)$");
		if(reply) then
			NPL.load("(gl)script/apps/Aries/Friends/Main.lua");
			local nid = msg.from:match("^%d+");
			MyCompany.Aries.Friends.RecvPositionQueryReply(nid, reply);
		end
		
		local invite = string.match(msg.body, "^%[Aries%]%[InviteTeleport%]:(.+)$");
		if(invite) then
			NPL.load("(gl)script/apps/Aries/Friends/Main.lua");
			MyCompany.Aries.Friends.RecvInviteTeleport(invite);
		end
		
		local nid_updatepop = string.match(msg.body, "^%[Aries%]%[UpdateUserPopularity%]:(.+)$");
		if(nid_updatepop) then
			NPL.load("(gl)script/apps/Aries/Friends/Main.lua");
			MyCompany.Aries.Friends.RecvUpdateUserPopularity(nid_updatepop);
		end
		
		local nid_voter = string.match(msg.body, "^%[Aries%]%[VotePopularityBy%]:(.+)$");
		if(nid_voter) then
			NPL.load("(gl)script/apps/Aries/Friends/Main.lua");
			MyCompany.Aries.Friends.OnVotePopularityBy(nid_voter);
		end
		
		-- cancel visualize message content
		return;
	elseif(tonumber(string.match(msg.from, "^(%d+)@+")) == 10000) then
		if (msg.body) then
			local msgdata = msg.body:match("^({.*})");
			if(msgdata) then
				msg.body = msg.body:gsub("^{.*}", "")
				if(msgdata) then
					LOG.std(nil, "system", "Chat", "system message contains data table:%s", msgdata);
				end
				msgdata = NPL.LoadTableFromString(msgdata);
				if(msgdata) then
					if(msgdata.type == "pay") then
						MyCompany.Aries.event:DispatchEvent(msgdata);
					end
				end
			end
			if(msg.body and msg.body~="") then
				NPL.load("(gl)script/apps/Aries/Chat/SystemChat.lua");
				MyCompany.Aries.Chat.SystemChat.ShowPage(msg.body);
			end
		end
	else
		NPL.load("(gl)script/apps/Aries/Friends/Main.lua");
		local nid = Chat.GetNameFromJID(msg.from);

		nid = tonumber(nid);

		local allowmosheng = commonlib.getfield("MyCompany.Aries.Friends.RecentContactListPage.allowmosheng");
		if(not MyCompany.Aries.Friends.IsFriendInMemory(nid) and allowmosheng == false) then
			return;
		end

		LOG.std(nil, "debug", "ChatReceived", "nid:"..tostring(nid));

		Chat.RecentContacts = Chat.RecentContacts or MyCompany.Aries.app:ReadConfig("RecentContact", {});
		if(Chat.RecentContacts[msg.from] == true) then
			-- already in the latest contact list;
		else
			-- added to the recent contact list and write the config to Aries app
			Chat.RecentContacts[msg.from] = true;
			MyCompany.Aries.app:WriteConfig("RecentContact", Chat.RecentContacts);
		end
		
		--青年版用新的聊天UI 2011/09/09 leio
		if(System.options.version == "kids") then
			local hasCheatWords = BadWordFilter.HasCheatingWord(msg.body);
			if(hasCheatWords) then
				msg.body = (msg.body or "").."\n【官方安全提示】如果聊天中有涉及财产的交易，请一定先核实好友身份；私人间交易发生纠纷，不受官方保护，切勿随意和陌生人交易"
			end
		end

		if(System.options.version ~= "kids")then
			NPL.load("(gl)script/apps/Aries/Chat/ChatPage.lua");
			local ChatPage = commonlib.gettable("MyCompany.Aries.ChatPage");
			local chatPageInstance = ChatPage.GetPageInstance(msg.from)
			if(chatPageInstance)then
				chatPageInstance:RecvMSG(msg.from, msg.subject, msg.body);
			end
		else
			-- check the UI avaiability, if Chat application is not visualized, push to buffer
			if(MyCompany.Aries.Friends.IsUIAvailable() == true) then
				Chat.VisualizeMessage(msg.from, msg.subject, msg.body);
			else
				msg.type = "OnMessage";
				System.App.Chat.AttachPendingMSG(msg);
			end
		end
	end
end

-- show the message with ChatWnd
-- @param JID
-- @param subject
-- @param body
function Chat.VisualizeMessage(JID, subject, body)
	
	local param = {[1] = JID};
	
	local chatwnd = Chat.ChatWnd:CreateGetWnd(param);
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

function Chat.OnSelfPresence(msg)
	Chat.MainWnd.OnSelfPresence(msg.presence);
end

function Chat.OnBecomeOnline(msg)
	local jid = msg.jid;
	Chat.UserStateChanged(jid,"online");
	--local nid = string.match(jid, "^(%d+)@.+");
	--nid = tonumber(nid);
	--
	--if(not MyCompany.Aries.Friends.IsFriendInMemory(nid)) then
		---- unsubscribe to the user that are not in the friend list
		--local jc = MyCompany.Aries.Chat.GetConnectedClient();
		--if(jc) then
			--jc:Unsubscribe(nid.."@"..System.User.ChatDomain, "");
		--end
		---- we only show online presence of buddies
		--return;
	--end
	--
	--if(nid) then
		--local ProfileManager = System.App.profiles.ProfileManager;
		--ProfileManager.GetUserInfo(nid, "OnBecomeOnline", function(msg)
			--local userinfo = ProfileManager.GetUserInfoInMemory(nid);
			--if(userinfo and userinfo.nickname) then
				--if(System.options.version == "kids") then
					--MyCompany.Aries.Desktop.Dock.ShowNotification("script/apps/Aries/Desktop/NotificationTemplate/UserBecomeOnline.html?nickname="..userinfo.nickname, nil, 3); -- for 3 second notification count down
				--else
					---- append npc chat channel message
					--ChatChannel.AppendChat({
						--ChannelIndex = ChatChannel.EnumChannels.BecomeOnline, 
						--from = 0, 
						--fromname = userinfo.nickname, 
						--fromschool = Combat.GetSchool(nid), 
						--fromisvip = false, 
						--words = "上线了",
						--bHideTooltip = true,
						--bHideColon = true,
					--});
				--end
				---- play online sound
				--local audio_file = "Audio/Haqi/UI/BecomeOnline.ogg";
				--if(audio_file) then
					--local audio_src = AudioEngine.CreateGet(audio_file)
					--audio_src.file = audio_file;
					--audio_src:play(); -- then play with default. 
				--end
				---- refresh the friends window
				--MyCompany.Aries.Friends.Refresh();
			--end
		--end, "access plus 1 minutes");
	--end
end
--@param jid:jid of user
--@param state:"online" or "offline"
function Chat.UserStateChanged(jid,state)
	if(not jid)then return end
	local nid = string.match(jid, "^(%d+)@.+");
	nid = tonumber(nid);
	state = state or "online";

	if(not MyCompany.Aries.Friends.IsFriendInMemory(nid)) then
		-- unsubscribe to the user that are not in the friend list
		local jc = MyCompany.Aries.Chat.GetConnectedClient();
		if(jc) then
			jc:Unsubscribe(nid.."@"..System.User.ChatDomain, "");
		end
		-- we only show online presence of buddies
		return;
	end
	
	if(nid) then
		local ProfileManager = System.App.profiles.ProfileManager;
		ProfileManager.GetUserInfo(nid, "OnBecomeOnline", function(msg)
			local userinfo = ProfileManager.GetUserInfoInMemory(nid);
			if(userinfo and userinfo.nickname) then
				if(System.options.version == "kids") then
					MyCompany.Aries.Desktop.Dock.ShowNotification("script/apps/Aries/Desktop/NotificationTemplate/UserBecomeOnline.html?nickname="..userinfo.nickname, nil, 3); -- for 3 second notification count down
				else
					local words;
					if(state == "online")then
						words = "上线了"
					else
						words = "下线了"
					end
					-- append npc chat channel message
					ChatChannel.AppendChat({
						ChannelIndex = ChatChannel.EnumChannels.BecomeOnline, 
						from = nid, 
						fromname = userinfo.nickname, 
						fromschool = Combat.GetSchool(nid), 
						fromisvip = false, 
						words = words,
						bHideTooltip = true,
						bHideColon = true,
					});
				end
				-- play online sound
				local audio_file = "Audio/Haqi/UI/BecomeOnline.ogg";
				if(audio_file) then
					local audio_src = AudioEngine.CreateGet(audio_file)
					audio_src.file = audio_file;
					audio_src:play(); -- then play with default. 
				end
				-- refresh the friends window
				MyCompany.Aries.Friends.Refresh();

				NPL.load("(gl)script/apps/Aries/Friends/FriendsPage.lua");
				local FriendsPage = commonlib.gettable("MyCompany.Aries.FriendsPage");
				FriendsPage.Refresh()
			end
		end, "access plus 1 minutes");
	end
end
function Chat.OnBecomeOffline(msg)
	local jid = msg.jid;
	--NOTE:kids only support online state,why?
	if(System.options.version ~= "kids") then
		Chat.UserStateChanged(jid,"offline");
	end
	--MyCompany.Aries.Desktop.Dock.ShowNotification(function (_parent)
		--if(_parent == nil or _parent:IsValid() == false) then
			--return;
		--end
		--
		--local _notify = ParaUI.CreateUIObject("container", "items", "_lt", 10, 0, 180, 128);
		--_notify.background = "";
		--_parent:AddChild(_notify);
		--
		--local _icon = ParaUI.CreateUIObject("button", "icon", "_lt", 16, 40, 48, 48);
		--_icon.background = "Texture/Aries/Friends/FriendsWnd_BuddyIcon_Offline.png";
		--_notify:AddChild(_icon);
		----MyCompany.Aries.Desktop.FillUIObjectWithPhotoFromNIDImmediate(_icon, System.App.Chat.GetNameFromJID(jid));
		--
		--local _name = ParaUI.CreateUIObject("text", "name", "_lt", 80, 42, 160, 24);
		--_name.background = "";
		--_name.text = System.App.Chat.GetNameFromJID(jid);
		--_name.font = System.DefaultBoldFontString;
		--_notify:AddChild(_name);
		--MyCompany.Aries.Desktop.FillUIObjectWithNameFromNID(_name, System.App.Chat.GetNameFromJID(jid));
		--local _text = ParaUI.CreateUIObject("text", "text", "_lt", 80, 64, 60, 24);
		--_text.background = "";
		--_text.text = "下线了";
		--_notify:AddChild(_text);
	--end);
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
		log("error UpdateContactList: invalid jabber client\n");
		return;
	end
	if(jc:GetIsAuthenticated() ~= true) then
		log("error UpdateContactList: jabber client not authenticated\n");
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
		log("Aries fetching roster...\n");
		local _, item
		for _, item in ipairs(roster) do
			if(item.subscription == 0) then
				-- S10nNone: 
				--Contact and user are not subscribed to each other, and neither has requested a subscription from the other.
			else
				--local userDetail = commonlib.LoadTableFromString(jc:GetRosterItemDetail(item.jid));
				local presence = System.App.Chat.GetPresenceFromJID(item.jid);
				item.presence = presence;
				
				-- first get userinfo of the contact on each roster fetching
				Map3DSystem.App.profiles.ProfileManager.GetUserInfo(System.App.Chat.GetNameFromJID(item.jid), "FetchingRosterGetUserInfo", function(msg) end);
				
				if(item.subscription == 8 or item.subscription == 4) then
					-- we show online contact ONLY at least user subscribed to contact
					--subscription 4: S10nTo, User is subscribed to contact (one-way).
					--subscription 8: S10nBoth, User and contact are subscribed to each other (two-way).
					table.insert(Chat.RosterItems, item);
				end
				
				commonlib.log("JID: %s; name:%s; groups: subscription:%d \n", item.jid, item.name, item.subscription);
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
	if(MyCompany.Aries.Friends.IsUIAvailable())then
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
		log("contact: ");commonlib.echo(contact);
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
	return System.App.Chat.GetNameFromJID(sJID)
end

-- Message Processor of Chat jabber client
-- it handles various messages
function Chat.MSGProc(window, msg)
end
