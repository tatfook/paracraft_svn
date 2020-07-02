--[[
Title: Profiles management
Author(s): LiXizhi, WangTian
Date: 2008/2/14
Desc: Managing all profiles: a profile provider interface. It also provides a listener method for callers to get informed of certain profile changes. 
This public class is used by other applications to access user profiles in the social network.

---++ NID functions
given nid as first parameter, do something about the user. 
More information, please see code doc
<verbatim>
	Map3DSystem.App.profiles.ProfileManager.ShowProfilePage(nid)
	Map3DSystem.App.profiles.ProfileManager.FriendsPage(nid)
	Map3DSystem.App.profiles.ProfileManager.TeleportToUser(nid, JID)
	Map3DSystem.App.profiles.ProfileManager.AddAsFriend(nid, relationType)
	Map3DSystem.App.profiles.ProfileManager.DownloadMapProfile(nid, callbackFunc)
	Map3DSystem.App.profiles.ProfileManager.FriendsRequestFeed(nid, silentMode)
	Map3DSystem.App.profiles.ProfileManager.PublishFeed(nid, content, silentMode, feedtype, feedtemplate)
	Map3DSystem.App.profiles.ProfileManager.Poke(nid)
	Map3DSystem.App.profiles.ProfileManager.GotoHomeWorld(nid)
	Map3DSystem.App.profiles.ProfileManager.AddAsFriend(nid, relationType)
</verbatim>
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/profiles/ProfileManager.lua");
Map3DSystem.App.profiles.ProfileManager.GetUserID()
Map3DSystem.App.profiles.ProfileManager.CreateGetProfile(nid)
Map3DSystem.App.profiles.ProfileManager.DownloadFullProfile(nid, callbackFunc)
Map3DSystem.App.profiles.ProfileManager.GetMCML(nid, Map3DSystem.App.appkeys["profiles"], function(nid, appkey, bSucceed, profile)
		if(bSucceed) then
			commonlib.echo(profile)
		end
	end)
Map3DSystem.App.profiles.ProfileManager.SetMCML(nid, app_key, profile, callbackFunc)
Map3DSystem.App.profiles.ProfileManager.SetMCMLUserInfo(values, callbackFunc)
Map3DSystem.App.profiles.ProfileManager.SaveToProfile({blood="1",}, function(bSucceed)
end)
Map3DSystem.App.profiles.ProfileManager.GetUserInfo(nid, "profilepage", function(msg)
	if(msg and msg.users and msg.users[1]) then
		local user = msg.users[1];
		local nickname = user.nickname;
		if(user.nickname) then
		end
	end
end)
Map3DSystem.App.profiles.ProfileManager.GetMyInfo(fieldname)
Map3DSystem.App.profiles.ProfileManager.GetJID(uids_or_nids, callbackFunc, queueName)
-------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemApp/profiles/profile.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/mcml/mcml.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/API/ParaworldAPI.lua");

local ProfileManager = commonlib.gettable("Map3DSystem.App.profiles.ProfileManager");
local Map3DSystem = commonlib.gettable("Map3DSystem");

-- a list of all profiles: mapping from userid to its profile object. 
ProfileManager.profiles = {};

-- call this function only once when the profile app loads. 
-- @param app: the profile application object. 
function ProfileManager.Init(app)
	-- create profile manager windows for profile download message callbacks. 
	ProfileManager._wnd = app._app:RegisterWindow("pmgr", nil, ProfileManager.MSGProc)
end	

----------------------------------------
-- profile manager methods: call these function from other applications or system modules. 
----------------------------------------

-- get the user ID of the current user.
function ProfileManager.GetUserID()
	return Map3DSystem.User.userid;
end

-- get the nid of the current user.
function ProfileManager.GetNID()
	if(Map3DSystem.User.nid and tonumber(Map3DSystem.User.nid)) then
		return tonumber(Map3DSystem.User.nid);
	end
	return Map3DSystem.User.nid;
end

-- check whether nid is currently logged in user nid. 
-- @param nid: nil, "", "loggedinuser" or Map3DSystem.User.nid will all be regarded as the current user. 
-- @return true if nid is currently logged in user id. 
function ProfileManager.IsCurrentUser(nid)
	if(Map3DSystem.User.nid and Map3DSystem.User.nid ~= "") then
		return (nid == nil or nid == "" or nid == "loggedinuser" or nid == Map3DSystem.User.nid)
	end
end

-- get a profile by its userid. if the profile of the given user is not downloaded. it will create an empty one and return. 
-- @param userid: user id. if nil the current user is used.
function ProfileManager.CreateGetProfile(nid)
	if(ProfileManager.IsCurrentUser(nid)) then
		nid = ProfileManager.GetNID();
	end
	nid = nid or "";
	local profile = ProfileManager.GetProfile(nid);
	if(profile == nil) then
		profile = Map3DSystem.App.profiles.profile:new({nid = nid});
		ProfileManager.profiles[nid] = profile;
	end
	return profile;
end

-- get a profile by its userid. if the profile of the given user is not downloaded. it will return nil. 
-- @param userid: if nil the profile of the currently signed in user is returned. 
function ProfileManager.GetProfile(userid)
	if(ProfileManager.IsCurrentUser(userid)) then
		userid = ProfileManager.GetUserID();
	end
	userid = userid or "";
	return ProfileManager.profiles[userid];
end

-- This will grab all application profiles from the server of a given user
-- This is usually used when user asks to view the complete profile of a given user, or the current user is just logged in 
-- and a complete copy of current user profile is downloaded from the server. 
-- please note that local server is NOT tested first. So it always looks for the server. 
-- @param nid: user nid;  if nil, the current user nid is used
-- @param callbackFunc: nil or function to call whenever the data is ready, function(uid, appkey, bSucceed) end, 
-- @return return true if it is fetching data or data is already available. it paraworld.errorcode, if web service can not be called at this time, due to error or too many concurrent calls.
function ProfileManager.DownloadFullProfile(nid, callbackFunc, cache_policy, timeout, timeout_callback)
	if(ProfileManager.IsCurrentUser(nid)) then
		nid = ProfileManager.GetNID();
	end
	-- TODO: download user info
	
	-- Download all application profiles. 
	return ProfileManager.GetMCML(nid, nil, callbackFunc, cache_policy, nil, timeout, timeout_callback)
end

-- This will grab just enough information about the user from the server of a given user to display its name, photo, and a few other profile fields. 
-- This is usually used when we meat a stranger and wants to view a basic info about him, including a thumbnail image.
-- please note that local server is NOT tested first. So it always looks for the server. 
-- @param nid: user nid
-- @param callbackFunc: nil or function to call whenever the data is ready, function(nid, appkey, bSucceed) end, 
-- @return return true if it is fetching data or data is already available. it paraworld.errorcode, if web service can not be called at this time, due to error or too many concurrent calls.
function ProfileManager.DownloadMiniProfile(nid, callbackFunc, timeout, timeout_callback)
	if(ProfileManager.IsCurrentUser(nid)) then
		nid = ProfileManager.GetNID();
	end
	-- TODO: Such information should be from paraworld.users.XXX
	
	-- NOTE: Currently, I simply store all user info in profile app's profile box. However, such information should be 
	-- stored and retrieved in other place in order to be searched by SQL. 
	return ProfileManager.GetMCML(nid, Map3DSystem.App.appkeys["profiles"], callbackFunc, nil, nil, timeout, timeout_callback)
end


-- it will return immediately the application's mcml profile data for the user. I assumes that GetMCML or the user profile is already downloaded and available in memory. 
function ProfileManager.GetMCMLInMemory(nid, app_key)
	if(ProfileManager.IsCurrentUser(nid)) then
		nid = ProfileManager.GetNID();
	end
	return ProfileManager.CreateGetProfile(nid):GetMCML(app_key);
end

-- this is the wrapper of GetMCML Paraworld API. 
-- Gets an app MCML that is currently set for a user's profile. A user MCML profile includes the content for its profile box.
-- See the MCML documentation for a description of the markup and its role in various contexts.
-- @param nid: for which user to get, if nil, the current user nid is used
-- @param app_key: for which application to get, if nil all applications are retrieved. 
-- @param callbackFunc: nil or function to call whenever the data is ready, function(nid, app_key, bSucceed, profile) end , where nid, app_key are forwarded. 
-- in the callbackFunc one can use profile or call Map3DSystem.App.profiles.ProfileManager.GetMCMLInMemory(nid, app_key) to retrieve a fresh copy of the app profile. 
-- @param cache_policy: nil or string or a cache policy object, such as "access plus 1 day", System.localserver.CachePolicies["never"]
-- @return return true if it is fetching data or data is already available. it paraworld.errorcode, if web service can not be called at this time, due to error or too many concurrent calls.
function ProfileManager.GetMCML(nid, app_key, callbackFunc, cache_policy, queuename, timeout, timeout_callback)
	if(ProfileManager.IsCurrentUser(nid)) then
		nid = ProfileManager.GetNID();
	end
	if(type(cache_policy) == "string") then
		cache_policy = System.localserver.CachePolicy:new(cache_policy)
	end
	
	local msg = {
		nid = nid,
		appkey = app_key,
		cache_policy = cache_policy,
	}
	return paraworld.profile.GetMCML(msg, queuename or "profiles", ProfileManager.profile_getMCML_callback, {callbackFunc = callbackFunc, nid = nid, app_key = app_key}, timeout, timeout_callback);
end

function ProfileManager.OnUpdateUserInfo(userinfo)
	if(userinfo and userinfo.nid) then
		ProfileManager.UserInfos[tonumber(userinfo.nid)] = userinfo;
		-- call hook for OnUserInfoChangedOrFirstFetch
		local hook_msg = { aries_type = "OnUserInfoFetched", nid = userinfo.nid, wndName = "main"};
		CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
	end
end

-- private: callback
function ProfileManager.profile_getMCML_callback(msg, params)
	-- save to profiles
	local bSucceed;
	if(type(msg)=="table"  and (msg.errorcode==nil or tonumber(msg.errorcode)<=1)) then
		local profile = ProfileManager.CreateGetProfile(params.nid);
		if(msg.profile) then
			-- only one application MCML box
			profile:SetMCML(params.app_key, msg.profile);
		elseif(msg.apps) then
			-- multiple application MCML boxes
			local i, app
			for i, app in ipairs(msg.apps) do
				if(app.appkey) then
					profile:SetMCML(app.appkey, app.profile);
				end
			end
		end
		bSucceed = true;
	else
		commonlib.log("warning: profile_getMCML_callback get invalid msg \n");
		commonlib.echo(msg)
	end	
	
	if(params.callbackFunc) then
		local profile
		if(bSucceed and params.app_key) then
			profile = ProfileManager.GetMCMLInMemory(params.nid, params.app_key)
		end	
		params.callbackFunc(params.nid, params.app_key, bSucceed, profile);
	end
end

-- record all user infos in memory
ProfileManager.UserInfos = {};

local known_users;
function ProfileManager.GetKnownUserByNid(nid)
	if(not known_users) then
		known_users = {
			["0"] = {
				users = {{
				  nid="0",
				  nickname=L"系统消息",
				  photo="http://file.test.pala5.cn/UserUpload/2009-1-4/c1fd8320-7445-497f-9356-5f2d0efb1be5.jpg",
				  username="LiXizhi1",
				  userid="4bc27a7d-f8b5-4124-9f1a-07cae50ef3d3" 
				}} 
			}
		};
	end
	return known_users[nid];
end

--[[ Get all commonly used public fields of a given or group of users. 
-- @param ids: it can be either nids or uids. we will automatically detect it. 
returned msg is :
msg = {
  users={
    {
      nid="001",
      nickname="",
      photo="http://file.test.pala5.cn/UserUpload/2009-1-4/c1fd8320-7445-497f-9356-5f2d0efb1be5.jpg",
      username="LiXizhi1",
      userid="4bc27a7d-f8b5-4124-9f1a-07cae50ef3d3" 
    } 
  } 
]] 
function ProfileManager.GetUserInfo(ids, queueName, callbackFunc, cache_policy, timeout, timeout_callback)
	if(type(cache_policy) == "string") then
		cache_policy = System.localserver.CachePolicy:new(cache_policy)
	end
	
	if(string.find(tostring(ids), "%-")) then
		-- skip all negative nid calls
		if(callbackFunc) then
			callbackFunc({errorcode = 500});
		end
		return;
	end

	local nids,uids;
	
	nids = ids or System.User.nid;

	--if(ids) then
		--if(string.match(ids, "[%-]")) then
			--uids = ids;
		--else
			--nids = ids;
		--end
	--else
		--nids = 	System.User.nid;
	--end
	
	-- for all single nid user info request, push into the pending queue for lazy network traffic
	if(tonumber(nids)) then
		local user = ProfileManager.GetKnownUserByNid(tostring(nids));
		if(user) then
			-- for known users. 
			if(callbackFunc) then
				callbackFunc(user);
			end
			return;
		end
		local userinfo_msg = paraworld.users.getInfoIfUnexpiredInLocalServer(nids, cache_policy);
		if(userinfo_msg) then
			cache_policy = "access plus 1 year";
		elseif(tonumber(nids) == System.User.nid) then
			-- self
			local inputMsg = {
				nid = nids, 
				--uids = uids, 
				--fields= "userid,nid,username,nickname,photo,smallphoto",
				--fields = "userid,nid,nickname,photo,smallphoto",
				--fields = "userid,nid,nickname,pmoney,emoney,birthday,popularity,family",
				cache_policy = cache_policy,
			};
			paraworld.users.GetUserAndDragonInfo(inputMsg, "userinfo" or queueName or "MyselfName", function(msg)
				if(msg and not msg.errorcode) then
					local userinfo = msg.user;
					-- wrap the return message with new format
					if(callbackFunc) then
						callbackFunc({
							users = {userinfo}, 
						});
					end
				else
					if(callbackFunc) then
						callbackFunc(msg);
					end
				end
			end, nil, timeout, timeout_callback);
			return;
		else
			ProfileManager.GetSingleUserInfo(tonumber(nids), function(msg)
				if(msg and msg.users and #(msg.users) > 0) then
					ProfileManager.GetUserInfo(tonumber(nids), "RefetchUserInfo_"..nids, callbackFunc, "access plus 1 year", timeout, timeout_callback);
				else
					if(callbackFunc) then
						callbackFunc(msg);
					end
				end
			end, timeout, timeout_callback);
			return;
		end
	end
	
	local inputMsg = {
		nids = nids, 
		--uids = uids, 
		--fields= "userid,nid,username,nickname,photo,smallphoto",
		--fields = "userid,nid,nickname,photo,smallphoto",
		--fields = "userid,nid,nickname,pmoney,emoney,birthday,popularity,family",
		cache_policy = cache_policy,
	};
	paraworld.users.getInfo(inputMsg, "getInfo" or queueName or "MyselfName", function(msg)
		if(msg and type(msg.users) == "table") then
			local i, user
			for i, user in ipairs(msg.users) do
				if(user.nid) then
					ProfileManager.UserInfos[tonumber(user.nid)] = (user);
					-- call hook for OnUserInfoChangedOrFirstFetch
					local hook_msg = { aries_type = "OnUserInfoFetched", nid = user.nid, wndName = "main"};
					CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
				end
			end
		end
		if(callbackFunc) then
			callbackFunc(msg);
		end
	end, nil, timeout, timeout_callback);
end

function ProfileManager.GetUserInfoInMemory(nid)
	if(not nid) then
		nid = ProfileManager.GetNID();
	end
	nid = tonumber(nid);
	if(not nid) then
		return;
	end
	local userinfo = ProfileManager.UserInfos[tonumber(nid)];
	if(not userinfo) then
		local userinfo_ls = paraworld.users.getInfoIfUnexpiredInLocalServer(nid, "access plus 1 year")
		if(userinfo_ls and tonumber(userinfo_ls.nid) == nid) then
			userinfo = userinfo_ls;
			ProfileManager.UserInfos[tonumber(nid)] = userinfo;
		end
	end
	return userinfo;
end

-- pending single userinfo request queue
ProfileManager.pending_singleinfo_request_queue = ProfileManager.pending_singleinfo_request_queue or {};
local pending_queue = ProfileManager.pending_singleinfo_request_queue;
pending_queue[1] = "zombie";
local pending_queue_head = 1;
local pending_queue_rear = 1;
local max_nids_count = 5;
-- NOTE: we use the last entry as the rear, and the last "zombie" as the head
-- pending_queue = {"zombie", "zombie", "zombie", "zombie", entry, entry, entry, }
--													  ^
--												pending_queue_head			^
--																		pending_queue_rear
function ProfileManager.GetSingleUserInfo(nid, callbackFunc, timeout, timeout_callback)
	nid = tonumber(nid);
	if(not nid or not callbackFunc) then
		return;
	end

	-- insert into the pending queue
	pending_queue_rear = pending_queue_rear + 1;
	pending_queue[pending_queue_rear] = {
		nid = nid,
		callbackFunc = callbackFunc,
		timeout = timeout,
		timeout_callback = timeout_callback,
	};
	
	if(not ProfileManager.lazy_timer) then
		ProfileManager.lazy_timer = commonlib.Timer:new({callbackFunc = function()
			local count = 0;
			if((pending_queue_rear - pending_queue_head) >= max_nids_count) then
				count = max_nids_count;
			elseif(pending_queue_rear == pending_queue_head) then
				count = 0;
			else
				count = pending_queue_rear - pending_queue_head;
			end
			-- batch send each segment of the pending queue
			if(count > 0) then
				local start = pending_queue_head + 1;
				local i;
				local nids = {};
				for i = start, (start + count - 1) do
					local nid = pending_queue[i].nid;
					nids[nid] = true;
				end
				-- make nids_str input string, remove collision nids
				local nids_str = "";
				local nid, _;
				for nid, _ in pairs(nids) do
					nids_str = nids_str..nid..",";
				end
				
				local inputMsg = {
					nids = nids_str, 
					--fields = "userid,nid,nickname,pmoney,emoney,birthday,popularity,family",
					cache_policy = "access plus 0 day",
				};
				paraworld.users.getInfo(inputMsg, "getInfoBatched" or ("pending_singleinfo_request_"..start), function(msg)
					-- dispatch the user info messages to each callback function
					if(msg and type(msg.users) == "table") then
						local i, user;
						for i, user in ipairs(msg.users) do
							if(user.nid) then
								local i;
								for i = start, (start + count - 1) do
									if(pending_queue[i] and pending_queue[i].nid == user.nid) then
										-- make output msg
										local output_msg = {
											users = {user},
										};
										pending_queue[i].callbackFunc(output_msg);
										pending_queue[i] = nil;
									end
								end
							end
						end
						for i = start, (start + count - 1) do
							if(pending_queue[i]) then
								pending_queue[i].callbackFunc(nil);
								pending_queue[i] = nil;
							end
						end
					end
				end, nil, 10000, function()
					local i;
					for i = start, (start + count - 1) do
						if(type(pending_queue[i].timeout_callback) == "function") then
							pending_queue[i].timeout_callback();
							pending_queue[i] = nil;
						end
					end
				end);
				-- advance the head pointer
				pending_queue_head = pending_queue_head + count;
			end
		end});
		ProfileManager.lazy_timer:Change(100, 100);
	end
end


-- get the JID of by uid or nid. 
-- @param id: it can be uid or nid of a given user. 
-- @param callbackFunc: the callback function(jid) end, 
-- @param queueName: request queue name. it can be nil. 
function ProfileManager.GetJID(id, callbackFunc, queueName)
	local nid,uid;
	if(not id) then
		callbackFunc(System.User.jid)
		return;
	else
		if(string.match(id, "[%-]")) then
			uid = id;
			ProfileManager.GetUserInfo(uid, queueName or "GetJID", function(msg)
				if(msg and msg.users and msg.users[1]) then
					local user = msg.users[1];
					if(user.nid) then
						local jid = string.format("%s@%s", tostring(user.nid), tostring(Map3DSystem.User.ChatDomain));
						callbackFunc(jid);
					end
				end
			end)
		else
			nid = id;
			local jid = string.format("%s@%s", nid, Map3DSystem.User.ChatDomain);
			callbackFunc(jid);
			return;
		end
	
	end
end

-- get the value of a given field of the current user from its profile app's UserInfo table. 
-- @param fieldname: commonly used ones are photo, 
function ProfileManager.GetMyInfo(fieldname)
	local profile = System.App.profiles.app:GetMCMLInMemory();
	if(profile and profile.UserInfo) then
		return profile.UserInfo[fieldname];
	end	
end

-- set MCML for a given application of the current user. 
-- and it will GetMCML for the same app from server immediately after set is completed. This Get operation ensures that local server is also updated. 
-- @param nid: this must be nil and current user is used. In future, we will allow arbitratry id with app signature. 
-- @param app_key: for which application to get, if nil all applications are retrieved. 
-- @param profile: if this is table. it is serialized to string. If this is nil, the app MCML will be cleared. 
-- @param callbackFunc: nil or function to call whenever the data is ready, function(nid, app_key, bSucceed) end , where nid, app_key are forwarded. 
-- @return return true if it is fetching data or data is already available. it paraworld.errorcode, if web service can not be called at this time, due to error or too many concurrent calls.
function ProfileManager.SetMCML(nid, app_key, profile, callbackFunc)
	local type_ = type(profile)
	if( type_ == "table") then
		-- if this is table. it is serialized to string using the most compact serialization method. 
		profile = commonlib.serialize_compact(profile);
	elseif(type_ == "nil") then
		-- If this is nil, the app MCML will be cleared. 
	elseif(type_ ~= "string") then
		-- other types or string is left as they are
		profile = tostring(profile);
	end
	
	local msg = {
		nid = nid or ProfileManager.GetNID(),
		appkey = app_key,
		profile = profile,
	}
	return paraworld.profile.SetMCML(msg, "profiles", ProfileManager.profile_setMCML_callback, {callbackFunc = callbackFunc, nid=nid, app_key=app_key})
end

-- private: callback
function ProfileManager.profile_setMCML_callback(msg, params)
	-- save to profiles
	local bSucceed;
	if(msg and (msg.errorcode==nil or tonumber(msg.errorcode)<=1)) then
		bSucceed = true;
		-- GetMCML for the same app from server immediately after set is completed. 
		-- This Get operation ensures that local server is also updated. 
		ProfileManager.GetMCML(params.nid, params.app_key, nil, System.localserver.CachePolicies["never"])
	else
		log("warning: profile SetMCML has an error return\n");
		commonlib.echo(msg);
	end	
	if(params.callbackFunc) then
		params.callbackFunc(params.nid, params.app_key, bSucceed);
	end
end

-- save the name value pairs to mcml of the profile application and commit
-- @param values: table of name, value pairs
-- @param callbackFunc: function (bSucceed) end
function ProfileManager.SaveToProfile(values, callbackFunc)
	if(not values) then return end
	
	local name, value
	for name, value in pairs(values) do
		if(string.len(tostring(value))>100) then
			commonlib.log("warning: ProfileManager.SaveToProfile field value is too long\n %s = %s \n", name,value);
			callbackFunc(false)
			return
		end
	end
	
	local profile = Map3DSystem.App.profiles.app:GetMCMLInMemory() or {};
	if(type(profile) ~= "table") then
		profile = {};
	end
	profile.UserInfo = profile.UserInfo or {};
	if(not commonlib.partialcompare(profile.UserInfo, values)) then
		log("updating profile: \n")
		commonlib.echo(values);
		commonlib.partialcopy(profile.UserInfo, values);
		Map3DSystem.App.profiles.app:SetMCML(nil, profile, function (nid, appkey, bSucceed)
			if(callbackFunc) then
				callbackFunc(bSucceed)
			end	
		end)
	else
		-- nothing has changed. just send true. 
		if(callbackFunc) then
			callbackFunc(true);
		end	
	end	
end

-- set mcml user info
-- @param values: {username, gender, photo, birth_year, selfdescription, interest}, see the app_main of profileAPP for a complete list of supported field. 
-- @param callbackFunc: nil or function to call whenever the data is ready, function(nid, app_key, bSucceed) end , where nid, app_key are forwarded. 
function ProfileManager.SetMCMLUserInfo(values, callbackFunc)
	local profile = System.App.profiles.app:GetMCMLInMemory() or {};
	profile.UserInfo = profile.UserInfo or {};
	commonlib.partialcopy(profile.UserInfo, values);
	Map3DSystem.App.profiles.app:SetMCML(nil, profile, callbackFunc);
end

-- TODO: Returns a wide array of user-specific information for each user identifier passed, limited by the view of the current user. 
-- This function returned immediately. use RegisterProfileListener to get informed of download completion message.
-- @param nids: List of user nids. This is a comma-separated list of user nids.
-- @param fields: List of desired fields in return. This is a comma-separated list of field strings. 
function ProfileManager.DownloadUserInfo(nids, fields)
	local msg = {
		nids = nids,
		fields = fields,
	}
	--paraworld.CreateRPCWrapper("paraworld.users.getTemp", "http://202.104.149.47/Users/GetInfo.asmx");
	--paraworld.users.getTemp(msg, "profileGetInfoTemp", ProfileManager.users_getInfo_callback, function() log("pre\n"); end, function() log("post\n"); end);
	--paraworld.users.getInfo(msg, "profiles", ProfileManager.users_getInfo_callback);
end

-- private: call back
function ProfileManager.users_getInfo_callback(msg)
	-- save to profiles
	local result = msg;
	-- TODO: record the LastDownloadTime
	if(result.info == nil) then
		local k, v;
		for k, v in ipairs(result.users) do
			if(v.userid ~= nil) then
				local profile = ProfileManager.CreateGetProfile(v.userid);
				profile.UserInfo = v;
			end
		end
	else
		-- exception or error
		log("error on paraworld.users.getInfo: "..result.info.."\n");
	end
	
	-- send message, so that the profile listeners are informed. 
	ProfileManager._wnd:SendMessage(nil, {nids = msg.nids or msg.nid});
end

-- TODO: download the identifiers of a given user's friends. The current user is determined from the session_key parameter. 
function ProfileManager.DownloadFriends(nid)
	local msg = {
		nid = nid,
	}
	paraworld.friends.get(msg, "profiles", ProfileManager.friends_get_callback)
end

-- private: call back
function ProfileManager.friends_get_callback(msg)
	-- save to profiles
	local result = msg;
	-- TODO: wait for user ID return
	-- TODO: record the LastDownloadTime
	if(result.info == nil and result.friends) then
		local k, v;
		for k, v in ipairs(result.friends) do
			if(v.userid ~= nil) then
				local profile = ProfileManager.CreateGetProfile(v.userid);
				profile.friends = v;
			end
		end
	else
		-- exception or error
		log("error on paraworld.friends.get: "..result.info.."\n");
	end
	
	-- send message, so that the profile listeners are informed.
	ProfileManager._wnd:SendMessage(nil, {nids = msg.nids or msg.nid});
end

-- func_callback will be called whenever the profiles for nids is downloaded or updated. 
-- @param hookName: a unique string name of the event handler
-- @param func_callback: it is function (nids) end, the nids is a comma-separated list of user ids that have just been updated.
-- @param nids: List of user ids. This is a comma-separated list of user ids. if nil it will hook to all messages. 
function Map3DSystem.App.profiles.RegisterProfileListener(hookName, func_callback, nids)
	local hook = CommonCtrl.os.hook.SetWindowsHook({hookType=CommonCtrl.os.hook.HookType.WH_CALLWNDPROC, 
		callback = function(nCode, appName, msg)
			-- return the nCode to be passed to the next hook procedure in the hook chain. 
			-- in most cases, if nCode is nil, the hook procedure should do nothing. 
			if(nCode==nil) then return end
			if(nids == nil or nids == msg.nids) then
				func_callback(msg.nids)
			end
			
			return nCode
		end, 
		hookName = hookName, appName = Map3DSystem.App.profiles.app.name, wndName = "pmgr"});
end

-- remove a listender from profile updates. 
function Map3DSystem.App.profiles.UnregisterProfileListener(hookName)
	CommonCtrl.os.hook.UnhookWindowsHook({hookName=hookName, hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC})
end

-- handling profile manager messages. 
function ProfileManager.MSGProc(window, msg)
	if(msg ~= nil) then
		-- call hook for profile download and update
		if(CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROC, 0, Map3DSystem.App.profiles.app.name, msg) == nil) then
			return;
		end
	end
end

-----------------------------------------
-- nid functions: given nid as first parameter, do something about the user. 
-----------------------------------------

-- add the given user as friend of the current user.  
function ProfileManager.AddAsFriend(nid, relationType)
	if(nid and nid ~= ProfileManager.GetNID()) then
		
		System.App.profiles.ProfileManager.GetUserInfo(item.nid, "AquariusFillBackName"..item.nid, function (msg)
			local nid;
			if(msg and msg.users and msg.users[1]) then
				nid = msg.users[1].nid;
			end
			if(nid) then
				local msg = {
					friendnid = nid,
					--relationType = relationType or 0,
				};
				paraworld.friends.add(msg, "paraworld", function(msg)
					if(msg) then
						if(msg.issuccess) then
							if(msg.state == 1) then
								_guihelper.MessageBox(L"添加成功, 你们已成为了好友");
								ProfileManager.BecomeFriendsFeed(nid, true)
							elseif(msg.state == 2) then
								_guihelper.MessageBox(L"已向对方发送了好友请求");
								ProfileManager.FriendsRequestFeed(nid, true)
							elseif(msg.state == 3) then
								_guihelper.MessageBox(L"你们已经是好友了");	
							end
						else
							if(msg.state == 3) then
								_guihelper.MessageBox(L"你们已经是好友了");	
							else
								_guihelper.MessageBox(string.format(L"添加失败了, 查看log了解原因"));
								commonlib.echo(msg);
							end
						end	
					end
				end);
			end
		end);
	else
		_guihelper.MessageBox(L"不能加自己为好友.");
	end	
end

-- remove the given user from my friend list 
-- @param silentMode: if true, no user interface is displayed. if nil, it will display a confirmation dialog and result dialog both before and after. 
function ProfileManager.RemoveFriend(nid, silentMode)
	if( nid and nid ~= ProfileManager.GetNID()) then
		local function RemoveFriend()
			System.App.profiles.ProfileManager.GetUserInfo(item.nid, "AquariusFillBackName"..item.nid, function (msg)
				local nid;
				if(msg and msg.users and msg.users[1]) then
					nid = msg.users[1].nid;
				end
				if(nid) then
					local msg = {
						friendnid = nid,
					};
					paraworld.friends.remove(msg, "paraworld", function(msg)
						if(msg and not silentMode) then
							if(msg.issuccess) then
								_guihelper.MessageBox(L"已经删除, 你的好友列表会稍后更新");
							else	
								_guihelper.MessageBox(L"删除失败,  查看log了解原因");
							end
						end
					end);
				end
			end);
		end
		if(not silentMode) then
			_guihelper.MessageBox(L"您确定要删除好友么?" , RemoveFriend);
		else
			RemoveFriend();
		end	
	else
		if(not silentMode) then
			_guihelper.MessageBox(L"不能删除自己");
		end	
	end	
end

-- go to the default home world of the given user. 
-- it just shows a popup mcml window showing the land of the given user, and its download progress. 
function ProfileManager.GotoHomeWorld(nid)
	Map3DSystem.App.Commands.Call("Profile.VisitWorld", {nid = nid})
end

-- Poke a user using actionfeed api.
function ProfileManager.Poke(nid)
	ProfileManager.PublishFeed(nid, "Hi!", nil, "Message", "poke")
end

-- publish a feed story from current user to nid
-- @param nid: if nil it will be sent to all friends, otherwise only the friends of the given nid. it may be multiple nid seperated by commar. 
-- @param silentMode: if true, no UI is displayed, message is sent. otherwise use nil to display a dialog to send the message. 
-- @param feedtype: what kinds of feed is sent, nil,"Story", "Action", "Request", "Message". Defaults to "Story", where "story" and "action" requires that the receiver is a friend of the current user. 
-- @param feedtemplate: feed template name. specify which feed template to use. if nil, "message" template is used. Some common template includes "message",  "empty",  
function ProfileManager.PublishFeed(nid, content, silentMode, feedtype, feedtemplate)
	Map3DSystem.App.Commands.Call("Profile.ActionFeed.Add", {nid = nid, content = content, silentMode=silentMode, feedtype = feedtype, feedtemplate = feedtemplate})
end

-- publish a friend request feed to the given user. usually the caller should already send the request out. 
function ProfileManager.FriendsRequestFeed(nid, silentMode)
	ProfileManager.PublishFeed(nid, string.format(L"<pe:name nid='%s'/>请求加你为朋友<a onclick='Map3DSystem.App.profiles.ProfileManager.AddAsFriend' param1='%s'>同意</a>", ProfileManager.GetUserID(), ProfileManager.GetUserID()), silentMode, "Request", "empty")
end

-- publish to all friends in the circle that you and the given user have newly become friends
function ProfileManager.BecomeFriendsFeed(nid, silentMode)
	ProfileManager.PublishFeed(nil, string.format(L"<pe:name nid='%s'/>和<pe:name nid='%s'/>成为了好朋友", ProfileManager.GetUserID(), nid), silentMode, "Story", "empty")
	-- Send a message to this friend(nid) telling him or her about the news. 
	local profile = ProfileManager.GetProfile();
	if(profile and nid) then
		local name = profile:getFullName();
		if(name) then
			paraworld.actionfeed.sendEmail({to = nid, title=L"你在帕拉巫又多了一位新朋友", body = name..L"刚刚同意了你的好友请求"}, "paraworld", function(msg)
				if(msg and msg.issuccess) then
					commonlib.log("successfully send email to to user %s\n", nid)
				else
					commonlib.log("failed sendEmail to user %s\n", nid)
				end	
			end);
		end	
	end	
end

-- This will grab just enough information about the user from the server of a given user to display its homeworld and dreamworlds information.
-- This is usually used when we meat a stranger and wants to a basic info about him, including a thumbnail image.
-- please note that local server is NOT tested first. So it always looks for the server. 
-- @param nid: user id
-- @param callbackFunc: nil or function to call whenever the data is ready, function(nid, appkey, bSucceed) end, 
-- @return return true if it is fetching data or data is already available. it paraworld.errorcode, if web service can not be called at this time, due to error or too many concurrent calls.
function ProfileManager.DownloadMapProfile(nid, callbackFunc)
	if(ProfileManager.IsCurrentUser(nid)) then
		nid = ProfileManager.GetUserID();
	end
	-- TODO: Such information should be from paraworld.users.XXX
	
	-- NOTE: Currently, I simply store all user info in profile app's profile box. However, such information should be 
	-- stored and retrieved in other place in order to be searched by SQL. 
	return ProfileManager.GetMCML(nid, Map3DSystem.App.appkeys["profiles"], callbackFunc)
end

-- show the profile page for a given user. 
-- @param nid: user id
function ProfileManager.ShowProfilePage(nid, width, height)
	if(ProfileManager.IsCurrentUser(nid)) then
		nid = ProfileManager.GetNID();
	end
	Map3DSystem.App.Commands.Call(Map3DSystem.options.ViewProfileCommand, nid)
end

-- show the profile page for a given user. 
-- @param nid: user id
function ProfileManager.FriendsPage(nid, width, height)
	if(ProfileManager.IsCurrentUser(nid)) then
		nid = ProfileManager.GetNID();
	end
	
	local href = string.format("script/kids/3DMapSystemApp/Profiles/FriendsPage.html?nid=%s", nid)
	Map3DSystem.mcml_controls.pe_a.OnClickHRefToMcmlBrowser(href, "_mcmlblank", width, height)
end

-- teleport to a given user. It will show up the world for downloading and joining. 
-- @param nid: user id to which to teleport
-- @param jid: this is optional. if specified, it will be the target user's JID 
function ProfileManager.TeleportToUser(nid, jid)
	if(ProfileManager.IsCurrentUser(nid)) then
		_guihelper.MessageBox("你已经在自己的身边")
		return
	end
	if(not Map3DSystem.JGSL.GetJID()) then
		_guihelper.MessageBox("您没有登录到服务器, 无法传送")
		return;
	end
	
	ProfileManager.GetUserInfo(nid, "teleporttouser", function(msg)
		if(msg and msg.users and msg.users[1]) then
			local user = msg.users[1];
			if(user.nickname) then
				_guihelper.MessageBox(string.format("确定要传送到 %s 的身边么?", user.nickname), function(res)
					if(res and res == _guihelper.DialogResult.Yes) then
						-- pressed YES
						System.App.Commands.Call("File.MCMLWindowFrame", {
							url=System.localserver.UrlHelper.BuildURLQuery("script/kids/3DMapSystemApp/Profiles/TeleportPage.html", {nid=nid, jid=jid, nickname=user.nickname}), 
							name="TeleportPage", 
							refresh = true,
							text = L"传送到世界",
							directPosition = true,
								align = "_ct",
								x = -250/2,
								y = -150/2,
								width = 250,
								height = 150,
							zorder = 2,	
						});
					end
				end, _guihelper.MessageBoxButtons.YesNo);
			end
		end
	end)
end