--[[
Title: Friends main window for Aries App
Author(s): WangTian
Date: 2009/5/4
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Friends/Main.lua");
MyCompany.Aries.Friends.ShowMainWnd();
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/XPath.lua");

NPL.load("(gl)script/apps/Aries/Player/main.lua");
NPL.load("(gl)script/apps/Aries/Combat/MsgHandler.lua");
NPL.load("(gl)script/ide/Encoding.lua");
NPL.load("(gl)script/ide/TooltipHelper.lua");
local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");

NPL.load("(gl)script/apps/Aries/Friends/BestFriendList.lua");
local BestFriendListPage = commonlib.gettable("MyCompany.Aries.Friends.BestFriendListPage");
local Encoding = commonlib.Encoding;
-- create class
local libName = "AriesFriends";
local Friends = commonlib.gettable("MyCompany.Aries.Friends");
local MsgHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");
local Pet = commonlib.gettable("MyCompany.Aries.Pet");
local VIP = commonlib.gettable("MyCompany.Aries.VIP");

-- show the friends main window
-- @param bShow: show or hide the main window, nil to toggle visibility
function Friends.ShowMainWnd(bShow)
	local _mainWnd = ParaUI.GetUIObject("AriesFriendsMainWnd");
	
	if(_mainWnd:IsValid() == false) then
		if(bShow == false) then
			return;
		end
		Friends.isRefreshRequested = false;
		
		if(System.options.version=="kids") then
			_mainWnd = ParaUI.CreateUIObject("container", "AriesFriendsMainWnd", "_ctb", 280, 70, 320, 512);
			_mainWnd.background = "";
			_mainWnd.zorder = 1; 
			_mainWnd:AttachToRoot();
		
			Friends.contentPage = System.mcml.PageCtrl:new({url = "script/apps/Aries/Friends/FriendsWnd.kids.html"});
			Friends.contentPage:Create("Friends_Content", _mainWnd, "_fi", 0, 0, 0, 0);
		else
			_mainWnd = ParaUI.CreateUIObject("container", "AriesFriendsMainWnd", "_ctb", 280, 70, 320, 512);
			_mainWnd.background = "";
			_mainWnd.zorder = 1; 
			_mainWnd:AttachToRoot();
		
			Friends.contentPage = System.mcml.PageCtrl:new({url = "script/apps/Aries/Friends/FriendsWnd.teen.html"});
			Friends.contentPage:Create("Friends_Content", _mainWnd, "_fi", 0, 0, 0, 0);
		end
		Friends.SetUIAvailable(true);
		
	else
		-- toggle visibility if bShow is nil
		if(bShow == nil) then
			bShow = not _mainWnd.visible;
		end
		if(bShow == true) then
			Friends.Refresh_imp();
		end
		
		_mainWnd.visible = bShow;
	end
	if(not bShow)then
		BestFriendListPage.ClosePage_SelectFriends();
	end
end

-- hide the friends main window
function Friends.HideMainWnd()
	Friends.ShowMainWnd(false);
end

-- refresh the page only at next show time. 
function Friends.Refresh()
	Friends.isRefreshRequested = true;
	
	if(Friends.IsUIAvailable()) then
		Friends.Refresh_imp();
	end
end

-- refresh the friends main window
function Friends.Refresh_imp()
	Friends.isRefreshRequested = false;
	
	if(Friends.contentPage) then
		Friends.contentPage:Refresh(0.01);
	end
end

-- set whether ui is available. this function is called when dock is created. 
function Friends.SetUIAvailable(bAvailable)
	Friends.is_ui_available = bAvailable
end

-- get whether ui is available. if not, we may need to delay private chat message until ui is ready
function Friends.IsUIAvailable()
	return Friends.is_ui_available;
	--local _mainWnd = ParaUI.GetUIObject("AriesFriendsMainWnd");
	--if(_mainWnd:IsValid() == true) then
		--return true;
	--elseif(_mainWnd:IsValid() == true) then
		--return false;
	--end
end

-- NOTE: Friends.MyFriendNIDs in memory is NOT reliable, there isn't a message that posted back to the user to inform the friend is removed
Friends.MyFriendNIDs = {};
-- mapping from nid to true.
Friends.MyFriendNID_map = {};
Friends.MyFriendNIDs_Online = {};

-- auto subscribe and unsubscribe on every friends list refresh
function Friends.UpdateJabberSubscription()
	if(MyCompany.Aries.Chat) then
		-- getfriends call is initiated before MyCompany.Aries.Chat is init
		local jc = MyCompany.Aries.Chat.GetConnectedClient();
		if(jc) then
			local count = Friends.GetFriendCountInMemory();
			LOG.std("", "system", "Friends", "Friends.UpdateJabberSubscription for %d friends", count);
			local i;
			for i = 1, count do
				local nid = Friends.GetFriendNIDByIndexInMemory(i);
				if(nid) then
					-- allow subscription to the user
					jc:AllowSubscription(nid.."@"..System.User.ChatDomain, true);
					-- auto subscribe to it
					jc:Subscribe(nid.."@"..System.User.ChatDomain, "name", "General", "I am "..System.App.profiles.ProfileManager.GetNID());
				end
			end
			-- unsubscribe to the user that are not in the friend list
			-- TODO:
			--jc:Unsubscribe(nid.."@"..System.User.ChatDomain, "");
		end
	end
end

-- get my friends
-- @param callbackFunc: the callback function(msg) end, the message only contains one field: issuccess
--		if issuccess is true, one can get the friend list in memory by GetFriendCountInMemory() and GetFriendNIDByIndexInMemory()
-- @param cache_policy: nil or string or a cache policy object, such as "access plus 1 day", System.localserver.CachePolicies["never"]
--		default to "access plus 5 minutes"
function Friends.GetMyFriends(callbackFunc, cache_policy, timeout, timeout_callback)
	local msg = {
		cache_policy = cache_policy or "access plus 10 minutes", 
		nid = nil, -- myself
		pageindex = -1,
		onlyonline = 0,
		order = 3,
		isinverse = 0,
	};
	paraworld.friends.get(msg, "Aries_GetMyFriends", function(msg)
		if(msg and msg.nids) then
			-- reset my friends list
			Friends.MyFriendNIDs = {};
			Friends.MyFriendNID_map = {};
	        local nid;
	        for nid in string.gfind(msg.nids, "([^,]+)") do 
				nid = tonumber(nid);
				table.insert(Friends.MyFriendNIDs, nid);
				Friends.MyFriendNID_map[nid] = true;
	        end
	        -- Friends.UpdateJabberSubscription();
			
			callbackFunc({issuccess = true});
		else
			callbackFunc({issuccess = false});
		end
	end, nil, timeout, timeout_callback);
end

-- get the friend count in memory
-- @return friend count
function Friends.GetFriendCountInMemory()
	return #(Friends.MyFriendNIDs);
end

-- get the friend nid in memory by index
-- @param index: index in the friend nid list
-- @return friend nid, nil if not found
function Friends.GetFriendNIDByIndexInMemory(index)
	if(index) then
		return Friends.MyFriendNIDs[index];
	end
end

-- is in memory friend list
-- @return true or false
function Friends.IsFriendInMemory(nid)
	return Friends.MyFriendNID_map[tonumber(nid) or 0] == true;
	--local i, n;
	--for i, n in ipairs(Friends.MyFriendNIDs) do
		--if(n == nid) then
			--return true;
		--end
	--end
	--return false;
end

-- is user online in memory
-- NOTE: check for scene object first and then jabber
-- @return true or false
function Friends.IsUserOnlineInMemory(nid)
	-- myself
	if(nid == System.App.profiles.ProfileManager.GetNID()) then
		return true;
	end
	
	--for all bipeds, get OPC status
	--local player = ParaScene.GetObject("<player>");
	--local playerCur = player;
	--local count = 0;
	--while(playerCur:IsValid() == true) do
		---- get next object
		--playerCur = ParaScene.GetNextObject(playerCur);
		---- currently get all scene objects
		--if(playerCur:IsValid() and playerCur:IsCharacter()) then
			--local att = playerCur:GetAttributeObject();
			--local isOPC = att:GetDynamicField("IsOPC", false);
			--if(isOPC) then
				--local nid_user = string.gsub(playerCur.name, "@.*$", "");
				--if(nid == tonumber(nid_user)) then
					--return true;
				--end
			--end
		--end
		---- if cycled to the player character
		--if(playerCur:equals(player) == true) then
			--break;
		--end
	--end
	
	if(Map3DSystem.GSL_client:HasAgent(nid)) then
		return true;
	end
	
	
	-- check for jc roster
	if(MyCompany.Aries.Chat) then
		-- aries_onlinestatus may be initiated before MyCompany.Aries.Chat is init
		local jc = MyCompany.Aries.Chat.GetConnectedClient();
		if(jc) then
			if(jc.IsOnline) then
				return jc:IsOnline(nid);
			else
				local rostor = jc:GetRoster();
				if(type(rostor) == "string") then
					rostor = commonlib.LoadTableFromString(rostor);
				end
				
				if(roster) then
					local _, item
					for _, item in ipairs(roster) do
						--if(item.subscription == 8 or item.subscription == 4) then
							-- we show online contact ONLY at least user subscribed to contact
							--subscription 4: S10nTo, User is subscribed to contact (one-way).
							--subscription 8: S10nBoth, User and contact are subscribed to each other (two-way).
							local nid_in_jid = string.match(item.jid, "^(%d+)@.+");
							if(nid_in_jid and nid == tonumber(nid_in_jid)) then
								if(item.online) then
									return true;
								end
							end
						--end
					end
				end
			end	
		end
	end
	return false;
end


-- NOTE: Friends.MyFamilyMemberNIDs in memory is NOT reliable, there isn't a message that posted back to the user to inform the member is removed
-- family normal member
Friends.MyFamilyMemberNIDs = {};
Friends.MyFamilyMemberNIDs_Online = {};
-- family deputy members
Friends.MyFamilyDeputyNIDs = {};
-- family admin member
Friends.MyFamilyAdminNIDs = {};
-- family info
Friends.MyFamilyInfo = nil;
-- my status in family, 0 is admin, 1 is deputy, 2 is memeber,default is 2
Friends.MyStatusInFamily = 2;


-- get my family name
function Friends.GetMyFamilyName()
	local my_nid = System.App.profiles.ProfileManager.GetNID();
	local userinfo = System.App.profiles.ProfileManager.GetUserInfoInMemory(my_nid);
	if(userinfo) then
		return userinfo.family;
	end
end

-- get my family ID
function Friends.GetMyFamilyID()
	local my_nid = System.App.profiles.ProfileManager.GetNID();
	local userinfo = System.App.profiles.ProfileManager.GetUserInfoInMemory(my_nid);
	if(not userinfo or not userinfo.family or userinfo.family == "") then
		return ;
	end
	if(Friends.MyFamilyInfo) then
		return Friends.MyFamilyInfo.id;
	end
end

-- array of my best friends like this {"14861822", "1234567"};
local my_best_friends_nid = nil; 
-- return nil or a table array of nids
function Friends.GetMyBestFriends()
	-- TODO: for LEIO, please return an array of best friends nid strings
	local list = BestFriendListPage.GetBestFriendList();
	if(list)then
		local result = {};
		local k,v;
		for k,v in ipairs(list) do
			local nid = tostring(v.nid);
			if(nid)then
				if(BestFriendListPage.HasInFriend(nid)) then
					table.insert(result,nid);
				end
			end
		end
		my_best_friends_nid = result;
	end
	return my_best_friends_nid;
end

-- get my family info
-- @param callbackFunc: the callback function(msg) end, the message only contains one field: issuccess
--		if issuccess is true, one can get the friend list in memory by GetMyFamilyMemberCountInMemory() and GetMyFamilyMemberNIDByIndexInMemory()
-- @param cache_policy: nil or string or a cache policy object, such as "access plus 1 day", System.localserver.CachePolicies["never"]
--		default to "access plus 10 minutes"
function Friends.GetMyFamilyInfo(callbackFunc, cache_policy, timeout, timeout_callback)
	-- get family id or name
	local idorname = Friends.GetMyFamilyName();
	if(not idorname) then
		LOG.std("", "system", "Friends", "nil family name for loggedin user in Friends.GetMyFamilyInfo");
		return;
	end
	if(idorname == "") then
		LOG.std("", "system", "Friends", "empty family name for loggedin user in Friends.GetMyFamilyInfo, user hasn't joined any family");
		callbackFunc({issuccess = true});
		return;
	end
	-- fetch family info with cache_policy
	local msg = {
		cache_policy = cache_policy or "access plus 10 minutes", 
		idorname = idorname,
	};
	paraworld.Family.Get(msg, "Aries_GetMyFamilyInfo", function(msg)
		if(msg and not msg.errorcode) then
			-- reset my family admin list
			Friends.MyFamilyAdminNIDs = {};
			local nid = tonumber(msg.admin);
			table.insert(Friends.MyFamilyAdminNIDs, nid);
			if(Map3DSystem.User.nid == nid)then
				Friends.MyStatusInFamily = 0; --自己是族长
			end
			-- reset my family deputy list
			Friends.MyFamilyDeputyNIDs = {};
	        local nid;
	        for nid in string.gfind(msg.deputy, "([^,]+)") do 
				nid = tonumber(nid);
				table.insert(Friends.MyFamilyDeputyNIDs, nid);
				if(Friends.MyStatusInFamily == 2) then
					if(Map3DSystem.User.nid == nid)then
						Friends.MyStatusInFamily = 1; --自己是族长
					end
				end
				
	        end
			-- reset my family member list
			Friends.MyFamilyMemberNIDs = {};
			---------------- old implementation ----------------
	        --local nid;
	        --for nid in string.gfind(msg.members, "([^,]+)") do 
				--nid = tonumber(nid);
				--table.insert(Friends.MyFamilyMemberNIDs, nid);
	        --end
	        ----------------------------------------------------
	        local _, member;
	        for _, member in ipairs(msg.members) do
				table.insert(Friends.MyFamilyMemberNIDs, member.nid);
	        end	
	        
			-- remember the family world server id string
			Friends.familyworld = msg.familyworld;
			-- whether it is the admin. 
			Friends.is_admin = tostring(Map3DSystem.User.nid) == tostring(msg.admin);

	        -- keep a record of my family info
	        Friends.MyFamilyInfo = commonlib.deepcopy(msg);
			callbackFunc({issuccess = true});
		else
			callbackFunc({issuccess = false});
		end
	end, nil, timeout, timeout_callback);
end

-- family member count including the deputy and admin
function Friends.GetMyFamilyMemberCountInMemory()
	-- return #(Friends.MyFamilyAdminNIDs) + #(Friends.MyFamilyDeputyNIDs) + #(Friends.MyFamilyMemberNIDs);
	return #(Friends.MyFamilyMemberNIDs);
end

-- family member count including the deputy and admin
function Friends.GetMyFamilyMemberNIDByIndexInMemory(index)
	if(index <= #(Friends.MyFamilyMemberNIDs)) then
		return Friends.MyFamilyMemberNIDs[index];
	end
	--index = index - #(Friends.MyFamilyMemberNIDs);
	--if(index <= #(Friends.MyFamilyDeputyNIDs)) then
		--return Friends.MyFamilyDeputyNIDs[index];
	--end
	--index = index - #(Friends.MyFamilyDeputyNIDs);
	--if(index <= #(Friends.MyFamilyAdminNIDs)) then
		--return Friends.MyFamilyAdminNIDs[index];
	--end
	LOG.std("", "error", "Friends", "MyFamilyMemberNIDByIndexInMemory outofrange");
end

-- is my family member
function Friends.IsMyFamilyMemberInMemory(nid)
	local i, member_nid;
	for i, member_nid in ipairs(Friends.MyFamilyMemberNIDs) do
		if(nid == member_nid) then
			return true;
		end
	end
	return false;
end

-- is my family deputy
function Friends.IsMyFamilyDeputyInMemory(nid)
	local i, deputy_nid;
	for i, deputy_nid in ipairs(Friends.MyFamilyDeputyNIDs) do
		if(nid == deputy_nid) then
			return true;
		end
	end
	return false;
end

-- is my family admin
function Friends.IsMyFamilyAdminInMemory(nid)
	local i, admin_nid;
	for i, admin_nid in ipairs(Friends.MyFamilyAdminNIDs) do
		if(nid == admin_nid) then
			return true;
		end
	end
	return false;
end

-- get family info, just an easy wrapper of the family.get api
-- @param idorname: id or name of the family
-- @param callbackFunc: the callback function(msg) end, the message only contains one field: issuccess
--		if issuccess is true, one can get the friend list in memory by MyFamilyMemberCountInMemory() and MyFamilyMemberNIDByIndexInMemory()
-- @param cache_policy: nil or string or a cache policy object, such as "access plus 1 day", System.localserver.CachePolicies["never"]
--		default to "access plus 10 minutes"
function Friends.GetFamilyInfo(idorname, callbackFunc, cache_policy, timeout, timeout_callback)
	-- fetch family info with cache_policy
	local msg = {
		cache_policy = cache_policy, 
		idorname = idorname,
	};
	paraworld.Family.Get(msg, "Aries_GetFamilyInfo", function(msg)
		if(msg and (msg.name == Friends.GetMyFamilyName())) then
			-- refresh my family info in local server
			Friends.GetMyFamilyInfo(function() end);
		end
		callbackFunc(msg);
	end, nil, timeout, timeout_callback);
end

-- NOTE: we user jabber resource message representing the user's LAST visited game server id plus world id
-- @return: world_id, gameserver_id or nil if invalid or never enter a world before
function Friends.GetUserGSAndWorldIDInMemory(nid)
	-- check for jc roster
	if(MyCompany.Aries.Chat) then
		-- aries_onlinestatus may be initiated before MyCompany.Aries.Chat is init
		local jc = MyCompany.Aries.Chat.GetConnectedClient();
		if(jc) then
			local rostor = jc:GetRoster();
			if(type(rostor) == "string") then
				rostor = commonlib.LoadTableFromString(rostor);
			end
			if(roster) then
				local _, item
				for _, item in ipairs(roster) do
					  --{
						--groups={ "General" },
						--jid="23338@test.pala5.cn",
						--name="name",
						--online=1,
						--resources={ pe={ message="", presence=1, priority=0 } },
						--subscription=8 
					  --},
					local nid_in_jid = string.match(item.jid, "^(%d+)@.+");
					if(nid_in_jid and nid == tonumber(nid_in_jid)) then
						if(item.resources) then
							local resource, body;
							for resource, body in pairs(item.resources) do
								if(resource == "pe") then
									local message = body.message or ""; --<-- we use this mesage to mark the world server and game server id
									local world_id, gameserver_id = string.match(message, "^(%d+)@(%d+)$");
									if(world_id and gameserver_id) then
										return world_id, gameserver_id;
									end
								end
							end
						end
						return;
					end
				end
			end
		end
	end
end

-- add as friend by NID, if success
-- @param nid: nid of the player
-- @param callbackFunc: the callback function(msg) end
-- @param type: "send" or "reply", default to send
function Friends.AddFriendByNID(nid, callbackFunc, type)
	if(not nid or nid == System.App.profiles.ProfileManager.GetNID()) then
		LOG.std("", "warn", "Friends", "you can't add yourself (%s)as friend", tostring(nid));
		return;
	end

	NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
	local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");	
	local myNid=System.App.profiles.ProfileManager.GetNID();
	local canSendMsg=ExternalUserModule:CanViewUser(myNid, nid);
	if (not canSendMsg) then
		_guihelper.MessageBox("不同区之间的用户, 暂时无法加好友");
		LOG.std("", "warn", "Friends", "you can't add user(%s) from other region as friend", tostring(nid));
		return
	end

	Friends.GetMyFriends(function(msg) 
		
		if(Friends.CheckFriendsFull()) then
			return;
		end
		
		-- no matter if msg.issuccess
		local is_already_friend;
		if(Friends.IsFriendInMemory(nid) == true) then
			log("error: nid:"..tostring(nid).." is already your friend\n");
			commonlib.echo(nid);
			is_already_friend = true;
		end
		local msg = {
			friendnid = nid,
		};
		paraworld.friends.add(msg, "AriesAddFriend", function(msg)
			if(msg.issuccess == true) then
				--if(type == nil or type == "send") then
				if(msg.state == 2) then
					-- send a message to tell the user
					local Chat = MyCompany.Aries.Chat;
					local jc = Chat.GetConnectedClient();
					if(jc) then
						----------FriendSystemDebugStep1----------
						-- TODO: this instant message may fail to send, resend this message or inform the user
						jc:Message(nid.."@"..System.User.ChatDomain, "[Aries][AddFriendRequest]:"..System.App.profiles.ProfileManager.GetNID());
						-- allow subscription to the user
						jc:AllowSubscription(nid.."@"..System.User.ChatDomain, true);
						-- auto subscribe to it
						jc:Subscribe(nid.."@"..System.User.ChatDomain, "name", "General", "I am "..System.App.profiles.ProfileManager.GetNID());
					end
					--_guihelper.MessageBox("已向对方发送了好友请求");
				end
				
				--if(type == "reply") then
				if(msg.state == 1) then
					-- send a message to tell the user
					local Chat = MyCompany.Aries.Chat;
					local jc = Chat.GetConnectedClient();
					if(jc) then
						----------FriendSystemDebugStep1----------
						-- TODO: this instant message may fail to send, resend this message or inform the user
						jc:Message(nid.."@"..System.User.ChatDomain, "[Aries][AddFriendReply]:"..System.App.profiles.ProfileManager.GetNID());
						-- allow subscription to the user
						jc:AllowSubscription(nid.."@"..System.User.ChatDomain, true);
						-- auto subscribe to it
						jc:Subscribe(nid.."@"..System.User.ChatDomain, "name", "General", "I am "..System.App.profiles.ProfileManager.GetNID());
					end
					--_guihelper.MessageBox("双方已成为好友");
				end
			end
			
			-- automatically get my friends again with the newly updated local server version
			-- mainly for friends in memory update
			Friends.GetMyFriends(function(msg) end, "access plus 1 minute");
			
			-- callback function
			callbackFunc(msg);
			MyCompany.Aries.event:DispatchEvent({type = "custom_goal_client"},79018);
			
			--if(msg.issuccess == true and msg.state == 1) then
				---- successfully add the friend
				--Friends.GetMyFriends(function(msg2)
					--if(msg2.issuccess == false) then
						---- but fail to fetch friend list afterward
						---- add the friend in the back of the friend list
						--table.insert(Friends.MyFriendNIDs, nid);
					--end
				--end, "access plus 0 day");
			--end
		end);
	end, "access plus 20 minutes");
end

-- add friend by nid with dialog messge box
--@param nid
function Friends.AddFriendByNIDWithUI(nid)
	if(not nid) then
		log("error: nil nid in Friends.AddFriendByNIDWithUI(nid)\n")
		return;
	end
	
	if(nid == System.App.profiles.ProfileManager.GetNID()) then
		_guihelper.MessageBox("你不能加自己为好友哦");
		return;
	end
	
	local isGM = MyCompany.Aries.Scene.IsGMAccount(nid);
	if(isGM) then
		_guihelper.MessageBox([[<div style="margin-top:30px;margin-left:-10px;width:300px;">哦噢，罗德镇长正在忙，有问题可以给他写信哦！]]);
		return;
	end
	
	-- get friend by force
	Friends.GetMyFriends(function(msg) 
		-- no matter if msg.issuccess
		if(Friends.IsFriendInMemory(nid)) then
			_guihelper.MessageBox([[<div style="margin-top:30px;margin-left:-2px;width:300px;">对方已经是你的好友了，不需要再重复添加啦！]]);
			log("error: nid:"..tostring(nid).." is already your friend when trying to add friend bu nid\n");
			return;
		end
		
		System.App.profiles.ProfileManager.GetUserInfo(nid, "Proc_VerifyNickName", function(msg)
			if(msg == nil or not msg.users or not msg.users[1]) then
				log("error in get user info when adding friend\n")
				commonlib.echo(msg)
				local s = string.format("你查找的%s不存在!",MyCompany.Aries.ExternalUserModule:GetConfig().account_name);
				_guihelper.MessageBox(s);
				return;
			end
			local nickname = tostring(msg.users[1].nickname);
			nickname = nickname or "";
			nickname = commonlib.XPath.XMLEncodeString(nickname);

			_guihelper.MessageBox(format("你确定要加<pe:name nid='%s' value='%s (%s)'/>为好友么？", tostring(nid), nickname, tostring(MyCompany.Aries.ExternalUserModule:GetNidDisplayForm(nid))), function(result) 
				if(_guihelper.DialogResult.OK == result) then
					-- add as friend
					MyCompany.Aries.Friends.AddFriendByNID(nid, function(msg)
						-- msg if not added before:
						-- echo:return { issuccess=true, state=2 }
						-- msg if already added before, and user not confirmed:
						-- echo:return { issuccess=false, state=500 }
						commonlib.echo("++++++++++AriesAddFriend+++++++++++")
						commonlib.echo(msg);
						if(msg) then
							if(msg.issuccess) then
								if(msg.state == 1) then
									_guihelper.MessageBox("添加成功, 你们已成为了好友");
									log("添加成功, 你们已成为了好友\n")
									commonlib.echo(nid);
								elseif(msg.state == 2) then
									_guihelper.MessageBox("已经向对方发出了好友请求，请耐心等待回复");
									log("已向对方发送了好友请求\n")
									commonlib.echo(nid);
								elseif(msg.state == 3) then
									log("你们已经是好友了z");
									commonlib.echo(nid);
								end
							else
								log(string.format("添加失败了, 查看log了解原因"));
								commonlib.echo(nid);
								commonlib.echo(msg);
								local message;
								if(errorcode == 500 or errorcode == 498) then
									message = "好友的邀请函好象送丢了，要不要再向("..MyCompany.Aries.ExternalUserModule:GetNidDisplayForm(nid)..")发出一封邀请函呢？";
									_guihelper.MessageBox(message, function(result) 
										if(_guihelper.DialogResult.Yes == result) then
											-- call this function again
											Friends.AddFriendByNIDWithUI(nid)
										elseif(_guihelper.DialogResult.No == result) then
										end
									end, _guihelper.MessageBoxButtons.YesNo);
								elseif(errorcode == 499) then
									message = string.format("邀请函上要有对方的%s我才能给你投递哦，请填写对方的%s.",MyCompany.Aries.ExternalUserModule:GetConfig().account_name,MyCompany.Aries.ExternalUserModule:GetConfig().account_name);
									_guihelper.MessageBox(message);
								elseif(errorcode == 497) then
									message = string.format("好象没有小哈奇的%s是(%d)哦，再看看是不是输错号码了呢？",MyCompany.Aries.ExternalUserModule:GetConfig().account_name,MyCompany.Aries.ExternalUserModule:GetNidDisplayForm(nid));
									_guihelper.MessageBox(message);
								end
							end	
						end
					end);
				elseif(_guihelper.DialogResult.Cancel == result) then
					-- doing nothing if the user cancel the add as friend
				end
			end, _guihelper.MessageBoxButtons.OKCancel);
		end, "access plus 5 minutes");
	end, "access plus 15 minutes");
end

-- remove friend by NID, if success
-- @param nid: nid of the player
-- @param callbackFunc: the callback function(msg) end
function Friends.RemoveFriendByNID(nid, callbackFunc)
	if(not nid or nid == System.App.profiles.ProfileManager.GetNID()) then
		log("error: you can't remove yourself from friend list\n");
		commonlib.echo(nid);
		return;
	end
	Friends.GetMyFriends(function(msg) 
		-- no matter if msg.issuccess
		if(Friends.IsFriendInMemory(nid) == false) then
			log("error: nid:"..tostring(nid).." is not your friend\n");
			commonlib.echo(nid);
			return;
		end
		local msg = {
			friendnid = nid,
		};
		paraworld.friends.remove(msg, "AriesRemoveFriend", function(msg)
			if(msg.issuccess == true) then
				---- successfully add the friend
				--Friends.GetMyFriends(function(msg2)
					--if(msg2.issuccess == false) then
						-- but fail to fetch friend list afterward
						-- remove the friend from the friend list
						local count = #(Friends.MyFriendNIDs);
						log("before remove\n")
						commonlib.echo(Friends.MyFriendNIDs)
						local i;
						for i, n in ipairs(Friends.MyFriendNIDs) do
							if(nid == n) then
								table.remove(Friends.MyFriendNIDs, i);
								commonlib.resize(Friends.MyFriendNIDs, count - 1);
								Friends.MyFriendNID_map[nid] = nil;
								break;
							end
						end
						log("after remove\n")
						commonlib.echo(Friends.MyFriendNIDs)
						
						----------FriendSystemDebugStep1----------
						local Chat = MyCompany.Aries.Chat;
						local jc = Chat.GetConnectedClient();
						if(jc) then
							-- unsubscribe to the user
							jc:Unsubscribe(nid.."@"..System.User.ChatDomain, "");
							---- TODO: tell the user to refresh his/her friend list
							--jc:Message(nid.."@"..System.User.ChatDomain, "[Aries][RemoveFriend]:"..System.App.profiles.ProfileManager.GetNID());
						end
					--end
				--end, "access plus 0 day");
				if(msg.issuccess == true) then
					BroadcastHelper.PushLabel({id="addfriend_tip", label = "成功删除好友", max_duration=10000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
				end
			else
				_guihelper.MessageBox("删除好友失败，请稍后重试");
			end
			
			-- automatically get my friends again with the newly updated local server version
			-- mainly for friends in memory update
			Friends.GetMyFriends(function(msg) end, "access plus 1 minute");
			
			-- callback function
			callbackFunc(msg);
		end);
	end, "access plus 0 day");
end


function Friends.GetMaxFriendsCount()
	return 100 + 10 * VIP.GetMagicStarLevel();
end

function Friends.CheckFriendsFull()
	local count = Friends.GetFriendCountInMemory();
	
	local max_count = Friends.GetMaxFriendsCount();
	if(count >= max_count) then
		_guihelper.MessageBox("你的好友列表已经满了。魔法星VIP等级越高好友上限越大");
		return true;
	end
end

function Friends.ReceiveFriendRequest(nid)
	
	local isAllowAddFriend = System.options.isAllowAddFriend;
	if(isAllowAddFriend == false) then
		-- refuse to be added as friend
		--[[local msg = {
			friendnid = nid,
		};
		paraworld.friends.remove(msg, "AriesRemoveFriend", function(msg)
			if(msg) then
				if(msg.issuccess) then
					-- successfully decline friends request
					-- sync the jabber buddy list with the firend list
					local jc = System.App.Chat.GetConnectedClient();
					if(jc ~= nil) then
						local jid = nid.."@"..System.User.ChatDomain;
						-- allow subscription
						jc:AllowSubscription(jid, false);
						log("Deny Subscription to "..jid.."\n")
					else
						log("error: nil jabber client when trying to deny friend request through jabber\n");
					end
				end	
			end
		end);
		]]
		NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/ChatChannel.lua");
		local ChatChannel = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatChannel");
		ChatChannel.AppendChat({ChannelIndex=ChatChannel.EnumChannels.System, from=nid, words="系统自动拒绝了好友申请"});
		-- BroadcastHelper.PushLabel({id="addfriend_tip", label = "系统自动拒绝了好友申请", max_duration=10000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
		return;
	end
	
	if(nid and nid ~= System.App.profiles.ProfileManager.GetNID()) then
		System.App.profiles.ProfileManager.GetUserInfo(nid, "IsFriendInMemory", function(msg)
			if(msg == nil or not msg.users or not msg.users[1]) then
				commonlib.echo(msg)
				log("error in get user info when adding friend\n")
				return;
			end
			local nickname = tostring(msg.users[1].nickname);
			
			local NotificationArea = MyCompany.Aries.Desktop.NotificationArea;
			if(NotificationArea.GetFeedByName("Friends.ReceiveFriendRequest"..nid)) then
				-- the request node is shown in the notification area
				-- cancel the feed in case of multiple request
				return;
			end
			NotificationArea.AppendFeed("request", {
				type = "Friends.ReceiveFriendRequest", 
				Name = "Friends.ReceiveFriendRequest"..nid, 
				nid = nid, 
				nickname = nickname, 
				ShowCallbackFunc = function(node)
					local nickname = node.nickname or "";
					local nid = node.nid;
					nickname = Encoding.EncodeStr(nickname);
					_guihelper.MessageBox("你同意 <pe:name value='"..nickname.."' nid='"..nid.."' profile_zorder=\"20000\" useyou=false/> ("..tostring(MyCompany.Aries.ExternalUserModule:GetNidDisplayForm(nid))..") 将你加为好友么", function(result)
						if(_guihelper.DialogResult.Yes == result) then
							-- move the maximum friends count check to the confirm process
							if(Friends.CheckFriendsFull()) then
								return;
							end
							-- accept the friend request
							Friends.AddFriendByNID(nid, function(msg)
								if(msg) then
									if(msg.issuccess) then
										---- sync the jabber buddy list with the firend list
										--local jc = System.App.Chat.GetConnectedClient();
										--if(jc ~= nil) then
											--local jid = nid.."@"..System.User.ChatDomain;
											---- allow subscription
											--jc:AllowSubscription(jid, true);
											---- auto subscribe to it
											--jc:Subscribe(jid, "name", "General", "I am "..tostring(System.App.Chat.jid));
											--log("Allow Subscription to "..jid.."\n")
										--else
											--log("error: nil jabber client when trying to add back friend through jabber\n");
										--end
										if(msg.issuccess == true and msg.state == 1) then
											_guihelper.MessageBox("用户 <pe:name value='"..nickname.."' nid='"..nid.."' profile_zorder=\"20000\" useyou=false/> ("..tostring(MyCompany.Aries.ExternalUserModule:GetNidDisplayForm(nid))..") 已经成为你的好友了，你可以在好友列表中看到他哦。", nil, nil, nil, nil, true); -- true for isNotTopLevel

											NPL.load("(gl)script/apps/Aries/Friends/FriendsPage.lua");
											local FriendsPage = commonlib.gettable("MyCompany.Aries.FriendsPage");
											FriendsPage.Refresh("BuddyList");
										end
									else
										log(string.format("确认好友邀请失败了, 查看log了解原因"));
										commonlib.echo(nid);
										commonlib.echo(msg);
									end	
								end
							end, "reply");
						elseif(_guihelper.DialogResult.No == result) then
							local msg = {
								friendnid = nid,
							};
							paraworld.friends.remove(msg, "AriesRemoveFriend", function(msg)
								if(msg) then
									if(msg.issuccess) then
										-- successfully decline friends request
										-- sync the jabber buddy list with the firend list
										local jc = System.App.Chat.GetConnectedClient();
										if(jc ~= nil) then
											local jid = nid.."@"..System.User.ChatDomain;
											-- allow subscription
											jc:AllowSubscription(jid, false);
											log("Deny Subscription to "..jid.."\n")
										else
											log("error: nil jabber client when trying to deny friend request through jabber\n");
										end
									end	
								end
							end);
						end
					end, _guihelper.MessageBoxButtons.YesNo, nil, nil, true); -- true for isNotTopLevel
				end,
			});
		end);
	else
		_guihelper.MessageBox("不能添加或删除自己为好友哦");
	end
end

function Friends.ConfirmFriendReply(nid)
	if(nid and nid ~= System.App.profiles.ProfileManager.GetNID()) then
		
		System.App.profiles.ProfileManager.GetUserInfo(nid, "IsFriendInMemory", function(msg)
			if(msg == nil or not msg.users or not msg.users[1]) then
				commonlib.echo(msg)
				log("error in get user info when adding friend\n")
				return;
			end	
			local nickname = tostring(msg.users[1].nickname);
			local NotificationArea = MyCompany.Aries.Desktop.NotificationArea;
			if(NotificationArea.GetFeedByName("Friends.ConfirmFriendReply"..nid)) then
				-- the request node is shown in the notification area
				-- cancel the feed in case of multiple request
				return;
			end
			NotificationArea.AppendFeed("story", {
				type = "Friends.ConfirmFriendReply", 
				Name = "Friends.ConfirmFriendReply"..nid, 
				nid = nid, 
				nickname = nickname,
				ShowCallbackFunc = function(node)
					local nickname = node.nickname;
					local nid = node.nid;
					_guihelper.MessageBox("用户 <pe:name value='"..Encoding.EncodeStr(nickname).."' nid='"..nid.."' profile_zorder=\"20000\" /> ("..tostring(MyCompany.Aries.ExternalUserModule:GetNidDisplayForm(nid))..") 已经成为你的好友了，你可以在好友列表中看到他哦。", nil, nil, nil, nil, true); -- true for isNotTopLevel
					NPL.load("(gl)script/apps/Aries/Friends/FriendsPage.lua");
					local FriendsPage = commonlib.gettable("MyCompany.Aries.FriendsPage");
					FriendsPage.Refresh("BuddyList");
				end;
			});
		end);
		-- auto refresh friends in memory
		Friends.GetMyFriends(function() 
			NPL.load("(gl)script/apps/Aries/Friends/FriendsPage.lua");
			local FriendsPage = commonlib.gettable("MyCompany.Aries.FriendsPage");
			FriendsPage.Refresh()
		end, "access plus 0 day");
	end
end

function Friends.GenerateMyPositionString()
	-- world text name
	worldname = MyCompany.Aries.WorldServerName or "";
	
	local regionname = "";
	local home_owner_nid;
	-- open the region radar
	NPL.load("(gl)script/kids/3DMapSystemApp/worlds/RegionRadar.lua");
	local args = Map3DSystem.App.worlds.Global_RegionRadar.WhereIam();
	if(args) then
		regionname = args.label;
		
		if(System.App.HomeLand.HomeLandGateway.IsInMyHomeland())then
			home_owner_nid = System.App.profiles.ProfileManager.GetNID();
		elseif(System.App.HomeLand.HomeLandGateway.IsInOtherHomeland())then
			-- NOTE: leio, i manually get the nid from the table
			home_owner_nid = System.App.HomeLand.HomeLandGateway.nid;
		end
		if(home_owner_nid) then
			local nickname = "";
			local userinfo = System.App.profiles.ProfileManager.GetUserInfoInMemory(home_owner_nid);
			if(userinfo) then
				nickname = userinfo.nickname;
				regionname = nickname.."的家园";
			end
		end
	end
	
	local x, y, z = ParaScene.GetPlayer():GetPosition();
	local serverInfo = Map3DSystem.GSL_client:GetServerInfo();
	--是否正在战斗
	local isInCombat = MsgHandler.IsInCombat();
	--commonlib.echo("========isInCombat");
	--commonlib.echo(System.App.profiles.ProfileManager.GetNID());
	--commonlib.echo(isInCombat);
 	local reply = string.format("%s,%s,%s,%s,%s@%s,%s,%s,%s,%s", 
						System.App.profiles.ProfileManager.GetNID(), 
						x, y, z, 
						System.GSL_client.worldserver_id, Map3DSystem.GSL_client.gameserver_nid, 
						worldname, regionname,
						home_owner_nid or "",
						tostring(isInCombat) or "false");
	return reply;
end

function Friends.ParsePositionString(reply)
	local nid, x, y, z, ws_id, gs_nid, worldname, regionname, home_owner_nid, isInCombat = string.match(reply, "^([^,]*),([^,]*),([^,]*),([^,]*),([^,@]*)@([^,]*),([^,]*),([^,]*),(.*),(.*)$");
	
	--log("aaaaaaaaaaaaaa Friends.RecvPositionQueryReply\n")
	--commonlib.echo({nid, x, y, z, ws_id, gs_nid, worldname, regionname, home_owner_nid});
	
	if(nid) then
		nid = tonumber(nid);
	end
	if(x and y and z) then
		x = tonumber(x);
		y = tonumber(y);
		z = tonumber(z);
	end
	if(home_owner_nid) then
		home_owner_nid = tonumber(home_owner_nid);
	end
	
	return nid, x, y, z, ws_id, gs_nid, worldname, regionname, home_owner_nid, isInCombat;
end

-- this timer is started in OnActivateDesktop
function Friends.InitPositionQueryWaitTimer()
	-- not used: 
	--PositionQueryTimer = commonlib.Timer:new({callbackFunc = Friends.OnPositionQueryWaitTimer});
	--PositionQueryTimer:Change(0, 1000);
end

function Friends.DumpCameraSettings()
	log("========DumpCameraSettings========\n")
	local scene = ParaScene.GetMiniSceneGraph("NPCDialog_miniscene");
	if(scene and scene:IsValid() == true) then
		log("NPCDialog_miniscene");
		commonlib.echo({scene:CameraGetLookAtPos()})
		commonlib.echo({scene:CameraGetEyePosByAngle()});
	end
end

function Friends.OnPositionQueryWaitTimer()
	local timedoutlist;
	local nid, countdowntime;
	for nid, countdowntime in pairs(PositionQueryWaitlist) do
		PositionQueryWaitlist[nid] = (countdowntime - 1000);
		if((countdowntime - 1000) < 0) then
			timedoutlist = timedoutlist or {};
			table.insert(timedoutlist, nid);
		end
	end
	
	if(timedoutlist) then
		local _, nid;
		for _, nid in ipairs(timedoutlist) do
			PositionQueryWaitlist[nid] = nil;
			local nickname = "";
			local userinfo = System.App.profiles.ProfileManager.GetUserInfoInMemory(nid);
			if(userinfo) then
				nickname = userinfo.nickname;
			end
			_guihelper.MessageBox(string.format([[<div style="margin-left:20px;margin-top:30px;">不知道你的好友[%s]在哪里哦. 可能对方不在线.</div>]], nickname));
		end
	end
end

-- query friend position
function Friends.QueryFriendPosition(nid)
	NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
	local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");	
	local myNid=System.App.profiles.ProfileManager.GetNID();
	local canSendMsg=ExternalUserModule:CanViewUser(myNid, nid);
	if (not canSendMsg) then
		_guihelper.MessageBox("不同区之间的用户, 暂时无法传送");
		LOG.std("", "warn", "Friends", "you can't query user(%s) from other region", tostring(nid));
		return
	end

	local nickname = "";
	local userinfo = System.App.profiles.ProfileManager.GetUserInfoInMemory(nid);
	if(userinfo) then
		nickname = userinfo.nickname;
	end
	local isFriend = Friends.IsFriendInMemory(nid);
	if(isFriend) then
		local isOnline = Friends.IsUserOnlineInMemory(nid);
		-- Step1: check if online in memory
		if(isOnline) then
			-- Step2: check if in nearby list
			--for all bipeds, get OPC nid and position
			local player = ParaScene.GetObject("<player>");
			local playerCur = player;
			while(playerCur:IsValid() == true) do
				-- get next object
				playerCur = ParaScene.GetNextObject(playerCur);
				-- currently get all scene objects
				if(playerCur:IsValid() and playerCur:IsCharacter()) then
					local att = playerCur:GetAttributeObject();
					local isOPC = att:GetDynamicField("IsOPC", false);
					if(isOPC == true) then
						local nid_in_name = string.gsub(playerCur.name, "@.*$", "");
						if(nid_in_name == tostring(nid)) then
							local dist = playerCur:DistanceTo(player);
							if(dist < 10) then
								_guihelper.MessageBox(string.format([[<div style="margin-top:32px;">你的好友[%s](%s)就在你附近。</div>]], nickname, tostring(MyCompany.Aries.ExternalUserModule:GetNidDisplayForm(nid))), nil, nil, "script/apps/Aries/Desktop/GUIHelper/PositionQueryMessageBox.html");
								return;
							end
							break;
						end
					end
				end
				-- if cycled to the player character
				if(playerCur:equals(player) == true) then
					break;
				end
			end
			
			-- Step3: query for position
			-- NOTE: although target user may still in the same world as the player, exceeding 20 meter range, 
			--		we still query position using jabber message
			local Chat = MyCompany.Aries.Chat;
			local jc = Chat.GetConnectedClient();
			if(jc) then
				Friends.lastQueryNid = nid;
				jc:Message(jc.MessageType.online_only, nid.."@"..System.User.ChatDomain, "[Aries][PositionQueryRequest]:"..System.App.profiles.ProfileManager.GetNID());
				-- PositionQueryWaitlist[tostring(nid)] = 3500;
			end
		else
			_guihelper.MessageBox(string.format([[<div style="margin-left:-10px;margin-top:32px;">你的好友[%s](%s)现在不在线。</div>]], nickname, tostring(MyCompany.Aries.ExternalUserModule:GetNidDisplayForm(nid))), nil, nil, "script/apps/Aries/Desktop/GUIHelper/PositionQueryMessageBox.html");
			
		end
	end
end

-- receive position query request
-- answer immediately
function Friends.RecvPositionQueryRequest(nid)
	NPL.load("(gl)script/apps/Aries/Login/ExternalUserModule.lua");
	local ExternalUserModule = commonlib.gettable("MyCompany.Aries.ExternalUserModule");	
	local myNid=System.App.profiles.ProfileManager.GetNID();
	local canSendMsg=ExternalUserModule:CanViewUser(myNid, nid);
	if (not canSendMsg) then
		_guihelper.MessageBox("不同区之间的用户, 暂时无法传送");
		LOG.std("", "warn", "Friends", "you can't query position of user(%s) from other region", tostring(nid));
		return
	end
	
	local Chat = MyCompany.Aries.Chat;
	local jc = Chat.GetConnectedClient();
	if(jc) then
		local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
		local addr = WorldManager:GetWorldAddress();
		if(addr) then
			if(System.options.EnableFriendTeleport) then
				if(System.User.is_ready) then
					LOG.std(nil, "debug", "Friends", "my position is sent to my friend "..nid);
					jc:Message(jc.MessageType.online_only, nid.."@"..System.User.ChatDomain, "[Aries][PositionQueryReply]:"..commonlib.serialize_compact(addr));
				else
					LOG.std(nil, "info", "Friends", "ignored my friend's position request "..nid);
					jc:Message(jc.MessageType.online_only, nid.."@"..System.User.ChatDomain, "[Aries][PositionQueryReply]:"..commonlib.serialize_compact({is_unknown_pos = true, }));
				end
			else
				LOG.std(nil, "info", "Friends", "denied my friend's position request "..nid);
				jc:Message(jc.MessageType.online_only, nid.."@"..System.User.ChatDomain, "[Aries][PositionQueryReply]:"..commonlib.serialize_compact({is_denied = true}));
			end
		else
			LOG.std(nil, "info", "Friends", "world can not teleport."..nid);
			jc:Message(jc.MessageType.online_only, nid.."@"..System.User.ChatDomain, "[Aries][PositionQueryReply]:"..commonlib.serialize_compact({world_address_disabled = true}));
		end
	end
end

-- receive position query reply
-- @param nid: from which user 
-- @param reply: the message string. 
function Friends.RecvPositionQueryReply(nid, reply)
	LOG.std(nil, "debug", "Friends", "position query reply from nid(%s) : %s", tostring(nid), commonlib.serialize_compact(reply));
	if(tostring(Friends.lastQueryNid) ~= tostring(nid)) then
		LOG.std("", "warn", "Friends", "we received request from (%s), but we never asked for it", tostring(nid));
		return;
	end

	-- teleport to world address 
	local address = NPL.LoadTableFromString(reply);
	local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
	if(address) then
		if(address.is_denied) then
			_guihelper.MessageBox(format("你的好友<pe:name nid='%s' />屏蔽了好友传送. ", tostring(nid)));
		elseif(address.is_unknown_pos) then	
			_guihelper.MessageBox(format("你的好友<pe:name nid='%s' />目前位置不明, 请稍候试试看. ", tostring(nid)));
		elseif(address.world_address_disabled) then	
			_guihelper.MessageBox(format("你的好友<pe:name nid='%s' />所在的世界 不允许传送.", tostring(nid)));
		else
			local world_info = WorldManager:GetWorldInfo(address.name);
			if(world_info.can_save_location) then
				WorldManager:TeleportByWorldAddress(address);
			elseif(world_info.world_title) then
				_guihelper.MessageBox(format("你的好友<pe:name nid='%s' />正在副本\"%s\"中, 不能直接传送. 需要对方召唤你才能传送.", tostring(nid), world_info.world_title));
			end
		end
	end
end

-- receive invite teleport invitation
function Friends.RecvInviteTeleport(invite)
	local nid, x, y, z, ws_id, gs_nid, worldname, regionname, home_owner_nid = Friends.ParsePositionString(invite);
	
    if(MyCompany.Aries.Desktop.Dock.IsIdleMode()) then
		-- idle mode not allowing teleport
		return;
    end
    
	if(Friends.IsFriendInMemory(nid)) then
		local nickname = "";
		local userinfo = System.App.profiles.ProfileManager.GetUserInfoInMemory(nid);
		if(userinfo) then
			nickname = userinfo.nickname;
		end
		--你的好友[用户名](米米号)邀请你去[地点名]，你要过去吗？
		if(ws_id == System.GSL_client.worldserver_id and gs_nid == System.GSL_client.gameserver_nid) then
			regionname = regionname or "";
			_guihelper.MessageBox(string.format([[<div style="margin-top:24px;">你的好友[%s](%s)邀请你去[%s]，你要过去吗？</div>]], nickname, tostring(MyCompany.Aries.ExternalUserModule:GetNidDisplayForm(nid)), regionname), function(result)
				if(_guihelper.DialogResult.OK == result) then
						if(home_owner_nid) then
						local myvisitedhome;
						if(System.App.HomeLand.HomeLandGateway.IsInMyHomeland())then
							myvisitedhome = System.App.profiles.ProfileManager.GetNID();
						elseif(System.App.HomeLand.HomeLandGateway.IsInOtherHomeland())then
							-- NOTE: leio, i manually get the nid from the table
							myvisitedhome = System.App.HomeLand.HomeLandGateway.nid;
						end
						if(myvisitedhome and myvisitedhome == home_owner_nid) then
							_guihelper.MessageBox("你已经在"..nickname.."的家了");
						else
							-- goto user homeland
							UIAnimManager.PlayCustomAnimation(200, function(elapsedTime)
								if(elapsedTime == 200) then
									System.App.Commands.Call("Profile.Aries.GotoHomeLand", {nid = home_owner_nid});
								end
							end);
						end
					else
						local HomeLandGateway = Map3DSystem.App.HomeLand.HomeLandGateway;
						if(HomeLandGateway.IsInHomeland()) then
							UIAnimManager.PlayCustomAnimation(200, function(elapsedTime)
								if(elapsedTime == 200) then
									-- leave the homeland and teleport to user
									HomeLandGateway.SetTeleportBackPosition(x, y + 0.1, z);
									HomeLandGateway.Away();
								end
							end);
						else
							-- teleport to the target
							local params = {
								asset_file = "character/particles/summonNew.x",
								binding_obj_name = ParaScene.GetPlayer().name,
								start_position = nil,
								duration_time = 800,
								begin_callback = function() 
								end,
								end_callback = function()
									-- set the position and camera setting
									ParaScene.GetPlayer():SetPosition(x, y + 0.1, z); -- a little higher
									ParaScene.GetPlayer():ToCharacter():FallDown();
									local params = {
										asset_file = "character/v5/temp/Effect/LoyaltyDown_Impact_Base.x",
										binding_obj_name = ParaScene.GetPlayer().name,
										start_position = nil,
										duration_time = 800,
										begin_callback = function() 
										end,
										end_callback = function()
										end,
									};
									local EffectManager = MyCompany.Aries.EffectManager;
									EffectManager.CreateEffect(params);
									-- auto refresh myself
									System.Item.ItemManager.RefreshMyself();
								end,
							};
							local EffectManager = MyCompany.Aries.EffectManager;
							EffectManager.CreateEffect(params);
						end
					end
				end
			end, _guihelper.MessageBoxButtons.OKCancel, nil, "script/apps/Aries/Desktop/GUIHelper/PositionQueryMessageBox.html");
		end
	end
end

-- update the user info if receive "[Aries][UpdateUserPopularity]:nid" chat message
function Friends.RecvUpdateUserPopularity(nid_updatepop)
	if(nid_updatepop) then
		nid_updatepop = tonumber(nid_updatepop);
		log("===== Friends.RecvUpdateUserPopularity =====\n");
		commonlib.echo(nid_updatepop);
		System.App.profiles.ProfileManager.GetUserInfo(nid_updatepop, "RecvUpdateUserPopularity", function(msg)
		end, "access plus 0 day");
	end
	
end

-- update the user info after 
function Friends.OnVotePopularityBy(nid_voter)
	if(nid_voter) then
		nid_voter = tonumber(nid_voter);
		log("===== Friends.OnVotePopularityBy =====\n");
		commonlib.echo(nid_voter);
		-- update myself user info
		System.App.profiles.ProfileManager.GetUserInfo(nil, "OnVotePopularityBy", function(msg)
		end, "access plus 0 day");
		System.App.profiles.ProfileManager.GetUserInfo(nid_voter, "IsFriendInMemory", function(msg)
			if(msg == nil or not msg.users or not msg.users[1]) then
				commonlib.echo(msg)
				log("error in get user info when adding friend\n")
				return;
			end
			local nickname = tostring(msg.users[1].nickname);
			-- append notification feed
			local NotificationArea = MyCompany.Aries.Desktop.NotificationArea;
			NotificationArea.AppendFeed("story", {
				type = "Friends.OnVotePopularityBy", 
				Name = "Friends.OnVotePopularityBy_"..nid_voter, 
				nid = nid_voter, 
				nickname = nickname,
				ShowCallbackFunc = function(node)
					local nickname = node.nickname;
					local nid = node.nid;
					nid = tostring(nid);
					_guihelper.MessageBox(string.format([[<div style="margin-left:40px;margin-top:20px;"><pe:name value='%s' nid='%s' profile_zorder="20000" /> (%s) <br/> 给你增加了1点人气值哦！]], nickname, nid, MyCompany.Aries.ExternalUserModule:GetNidDisplayForm(nid)), nil, nil, nil, nil, true); -- true for isNotTopLevel
				end;
			});
		end);
	end
end