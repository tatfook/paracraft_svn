--[[
Title: profile data definition and provider in a single place
Author(s): LiXizhi, WangTian
Date: 2008/2/14
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/profiles/profile.lua");
-------------------------------------------------------
]]

--------------------------------------
-- profile class
--------------------------------------
local profiles = commonlib.gettable("Map3DSystem.App.profiles");

-- TODO: make this compatible with jabber interface
Map3DSystem.App.profiles.userStatus = {
	Unknown = nil,
	Online = 1,
	Busy = 2,
	NotAvailable = 3,
	Offline = -1,
};

Map3DSystem.App.profiles.profile = {
	-- the user nid of this profile
	nid = nil,
	-- user status
	userStatus = nil,
	-- user-specific information
	UserInfo = nil,
	-- array of active application keys for this user
	ActiveApps = nil,
	-- array of friends's nid
	friends = nil,
	-- when we downloaded this profile from the web last time. 
	LastDownloadTime = nil,
	-- mapping from app key to app mcml data node for this profile box
	apps = nil,
};

-- create a new profile. the profile's filename must not be nil. 
function Map3DSystem.App.profiles.profile:new(o)
	o = o or {}; -- create object if user does not provide one
	if(o.nid == nil) then
		-- the profile's nid must not be nil.
		log("error: Map3DSystem.App.profiles.profile:new(o), nid must not be nil\n");
		o.nid = "";
	end
	setmetatable(o, self);
	self.__index = self;
	
	return o;
end

------------
-- methods: 
------------
-- return a readonly copy of the profile object of this profile. 
function Map3DSystem.App.profiles.profile:getProfile()
	return commonlib.MetaClone(self);
end

-- convert this profile to string for debugging purposes. 
function Map3DSystem.App.profiles.profile:ToString()
	return profile.nid.."\n";
end

-- return the user name of the user
function Map3DSystem.App.profiles.profile:getUsername()
	if(self.UserInfo) then
		return self.UserInfo.username;
	end
end

-- return the user info. It may return nil if user info is not retrieved yet. 
function Map3DSystem.App.profiles.profile:getUserInfo()
	return self.UserInfo;
end

-- return the full name of the user. if full name is not specified, it will return user name instead. 
function Map3DSystem.App.profiles.profile:getFullName()
	if(self.UserInfo) then
		return self.UserInfo.fullname or self.UserInfo.username;
	end
end

-- return the thumbnail photo path of this profile user.
function Map3DSystem.App.profiles.profile:getUserPhoto()
	if(self.UserInfo) then
		return self.UserInfo.photo;
	end
end

-- return the network status of this profile user
function Map3DSystem.App.profiles.profile:getUserStatus()
	return self.userStatus;
end

-- return the friend list of this profile user
function Map3DSystem.App.profiles.profile:getFriends()
	return self.friends;
end

-- set the friend list of this profile user
-- @param friends: it may an nid array or a string containing nid seperated by commar or semicolon. 
function Map3DSystem.App.profiles.profile:setFriends(friends)
	if(type(friends) == "string") then
		self.friends = {};
		local uid;
		for uid in string.gfind(friends, "[^;,%s]+") do
			table.insert(self.friends, uid);
		end
	elseif(type(friends) == "table") then
		self.friends = friends;
	end
end


-- returns the app box table of a given app
-- @param app_key: application GUID key string.
-- @return return the app box object in the profile. it may return nil if not found.
function Map3DSystem.App.profiles.profile:GetMCML(app_key)
	if (self.apps) then
		return self.apps[app_key];
	end
end

-- set the application mcml data for this user. 
function Map3DSystem.App.profiles.profile:SetMCML(app_key, app)
	self.apps = self.apps or {};
	if (self.apps) then
		if(type(app) == "string") then
			-- we will try to convert it to table. 
			if(string.match(app, "^%s*{.*}%s*$")) then
				-- app is string serialized from a lua table
				if(NPL.IsPureData(app)) then
					app = commonlib.LoadTableFromString(app);
				else
					app = nil	
				end
				
				if(not app) then
					commonlib.log("warning: app profile %s of user %s is not pure data\n", tostring(app_key), tostring(self.nid))	
					app =  nil;
				end
			elseif(string.match(app, "^%s*<")) then
				-- if it is string in XML format. 
				--app = ParaMisc.EncodingConvert("", "HTML", app); -- format to html ansci code page
				app = ParaXML.LuaXML_ParseString(app);
			else
				-- in other cases, app is just a string. 	
			end
		end
		self.apps[app_key] = app;
		
		if(type(app)=="table") then
			-- if it is profiles app, we will extract information in the mcml to self.
			if(app_key == Map3DSystem.App.appkeys["profiles"]) then
				-- Note LXZ 2008.3.25: currently, userinfo and active apps are stored in profile app's mcml profile box. 
				-- we need to move them to a more secure location such as the friends list. Here we just secretly move them to the root level. 
				-- so that when we make the modification, the API of profile is not affected. 
				self.UserInfo = app.UserInfo;
				self.ActiveApps = app.ActiveApps;
			end
		end	
	end
end

-- return an array of apps that is active for this user. 
function Map3DSystem.App.profiles.profile:getActiveApps()
	return self.ActiveApps;
end

--------------------------------------
-- basic user info profile box
--------------------------------------
--
---- User information. There are two types of UserInfo. One contains only nid, name and photo as in friends list. another contains full info. 
--Map3DSystem.App.profiles.UserInfo = {
	---- user id
	--uid = nil,
	---- user name
	--name = nil, 
	---- user photo path or photo id, photo path can be deduced from photo id. 
	--photo = nil,
	--sex = nil,
	------ user status
	---- NOTE by Andy: move to profile table
	----userstatus = nil,
	--age = nil,
	--signature = nil,
	--city = nil,
	--nation = nil,
	------ array of friends's nid
	---- NOTE by Andy: move to profile table
	----friends = nil,
--};
--
---- create a new basicUserInfo box. 
--function Map3DSystem.App.profiles.UserInfo:new(o)
	--o = o or {}   -- create object if user does not provide one
	--setmetatable(o, self)
	--self.__index = self
	--return o
--end
--
--function Map3DSystem.App.profiles.UserInfo:GetPhotoPath()
	---- user photo path or photo id, photo path can be deduced from photo id. 
	---- TODO: if photo is id, convert it to url path. 
	--return self.photo;
--end
--