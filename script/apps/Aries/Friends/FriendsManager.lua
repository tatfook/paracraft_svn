--[[
Title: 
Author(s): 
Date: 2011/07/18
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Friends/FriendsManager.lua");
local FriendsManager = commonlib.gettable("MyCompany.Aries.FriendsManager");
FriendsManager.CreateOrGetManager();
-------------------------------------------------------
]]
local FriendsManager = commonlib.gettable("MyCompany.Aries.FriendsManager");
local ProfileManager = commonlib.gettable("Map3DSystem.App.profiles.ProfileManager");
local Player = commonlib.gettable("MyCompany.Aries.Player");

local string_gfind = string.gfind

function FriendsManager.CreateOrGetManager()
	if(not FriendsManager.manager_instance)then
		FriendsManager.manager_instance = FriendsManager:new();
		FriendsManager.manager_instance:OnInit();
	end
	return FriendsManager.manager_instance;
end
function FriendsManager:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end
function FriendsManager:OnInit()
	
end

function FriendsManager:SearchBuddyList(callbackFunc)
	local cache_policy = "access plus 1 minutes";
	local msg = {
		cache_policy = cache_policy, 
		nid = nil, -- myself
		pageindex = -1,
		onlyonline = 0,
		order = 3,
		isinverse = 0,
	};
	
	paraworld.friends.get(msg, "Aries_GetMyFriends", function(msg)
		if(msg and msg.nids) then
			local list = {};
	        local nid;
			local count = 0;
	        for nid in string_gfind(msg.nids, "([^,]+)") do 
				nid = tonumber(nid);
				local isvip = false;
				count = count + 1;
				local priority = count;

				local userinfo = ProfileManager.GetUserInfoInMemory(nid);
				local gender = Player.GetGender(nid)
				if(userinfo and userinfo.energy and userinfo.energy > 0 and userinfo.mlel) then
					-- add the VIP contact priority by 10000 and sorted by m level
					priority = 10000 + priority + userinfo.mlel * 500;
					isvip = true;
				end
				
				local Friends = MyCompany.Aries.Friends;
				local is_online = Friends.IsUserOnlineInMemory(nid);
				local icon = "";
				if(gender == "male")then
					if(is_online)then
						icon = "Texture/Aries/Common/ThemeTeen/others/boy_32bits.png;"
						priority = 30000 + priority;
					else
						icon = "Texture/Aries/Common/ThemeTeen/others/boy_offline_32bits.png;"
					end
				else
					if(is_online)then
						icon = "Texture/Aries/Common/ThemeTeen/others/girl_32bits.png;"
						priority = 30000 + priority;
					else
						icon = "Texture/Aries/Common/ThemeTeen/others/girl_offline_32bits.png;"
					end
				end
				table.insert(list, {nid = nid,icon = icon,isvip = isvip,priority = priority,gender = gender,});
				table.sort(list, function(a, b)
					return (a.priority > b.priority);
				end);
	        end
			if(callbackFunc)then
				callbackFunc({issuccess = true, list = list,});
			end
		else
			if(callbackFunc)then
				callbackFunc({issuccess = false});
			end
		end
	end);
end
function FriendsManager:SearchNearbyList()
	local list = {};
	--for all bipeds, get OPC status
	local player = ParaScene.GetObject("<player>");
	local playerCur = player;
	local count = 0;
	while(playerCur:IsValid() == true) do
		-- get next object
		playerCur = ParaScene.GetNextObject(playerCur);
		-- currently get all scene objects
		if(playerCur:IsValid() and playerCur:IsCharacter()) then
			local x, y, z = playerCur:GetPosition()
			-- NOTE: filter player position at y:-12345, which is a hiden position in gm command, refer to GSL_agent.lua
			if(y ~= -12345) then
				local att = playerCur:GetAttributeObject();
				local isOPC = att:GetDynamicField("IsOPC", false);
				if(isOPC == true) then
					count = count + 1;
					local nid = string.gsub(playerCur.name, "@.*$", "");
					local name = att:GetDynamicField("name", "");
					nid = tonumber(nid);
					local priority = count;
					local isvip = false;
					local userinfo = ProfileManager.GetUserInfoInMemory(nid);
					local gender = Player.GetGender(nid)
					
					--local school = "unknown";
					--if(userinfo) then
						--school = self:GetSchoolByCode(userinfo.combatschool);
					--end


					local Friends = MyCompany.Aries.Friends;
					local icon = "";
					local is_online = true;
					if(Friends.IsFriendInMemory(nid))then
						is_online = Friends.IsUserOnlineInMemory(nid);
						if(gender == "male")then
							if(is_online)then
								icon = "Texture/Aries/Common/ThemeTeen/others/boy_32bits.png;"
								priority = 30000 + priority;
							else
								icon = "Texture/Aries/Common/ThemeTeen/others/boy_offline_32bits.png;"
							end
						else
							if(is_online)then
								icon = "Texture/Aries/Common/ThemeTeen/others/girl_32bits.png;"
								priority = 30000 + priority;
							else
								icon = "Texture/Aries/Common/ThemeTeen/others/girl_offline_32bits.png;"
							end
						end
					else
						if(gender == "male")then
							icon = "Texture/Aries/Common/ThemeTeen/others/boy_32bits.png;"
							priority = 30000 + priority;
						else
							icon = "Texture/Aries/Common/ThemeTeen/others/girl_32bits.png;"
							priority = 30000 + priority;
						end
					end
					if(userinfo and userinfo.energy and userinfo.energy > 0 and userinfo.mlel) then
						-- add the VIP contact priority by 10000 and sorted by m level
						priority = 10000 + priority + userinfo.mlel * 500;
						isvip = true;
					end
					if(is_online)then
						table.insert(list, {bshow = true,nid = nid,name = name,priority = priority,icon = icon,isvip = isvip,});
					end
				end
			end
		end
		-- if cycled to the player character
		if(playerCur:equals(player) == true) then
			break;
		end
	end
	-- sort the table according to priority
	table.sort(list, function(a, b)
		return (a.priority > b.priority);
	end);
	return list;
end
function FriendsManager:SearchRecentList()
	local list = {};
	local count = 0;
	local from, _;
	local RecentContacts = MyCompany.Aries.app:ReadConfig("RecentContact", {});
	for from, _ in pairs(RecentContacts) do
		count = count + 1;
		local nid = string.gsub(from, "@.*$", "");
		nid = tonumber(nid);
		local priority = count;
		local Friends = MyCompany.Aries.Friends;
		local is_online = Friends.IsUserOnlineInMemory(nid);
		local gender = Player.GetGender(nid)
		local icon = "";
		if(gender == "male")then
			if(is_online)then
				icon = "Texture/Aries/Common/ThemeTeen/others/boy_32bits.png;"
				priority = 30000 + priority;
			else
				icon = "Texture/Aries/Common/ThemeTeen/others/boy_offline_32bits.png;"
			end
		else
			if(is_online)then
				icon = "Texture/Aries/Common/ThemeTeen/others/girl_32bits.png;"
				priority = 30000 + priority;
			else
				icon = "Texture/Aries/Common/ThemeTeen/others/girl_offline_32bits.png;"
			end
		end
		local isvip = false;
		local userinfo = ProfileManager.GetUserInfoInMemory(nid);
		
		if(userinfo and userinfo.energy and userinfo.energy > 0 and userinfo.mlel) then
			-- add the VIP contact priority by 10000 and sorted by m level
			priority = 10000 + priority + userinfo.mlel * 500;
			isvip = true;
		end
		if(nid ~= Map3DSystem.User.nid)then
			table.insert(list, {bshow = true,nid = nid,name = name,priority = priority,icon = icon,isvip = isvip,});
		end
	end
	-- sort the table according to priority
	table.sort(list, function(a, b)
		return (a.priority > b.priority);
	end);
	return list;
end
-- get a black member list form local db
function FriendsManager:SearchBlackMemberList()
	local myself = Map3DSystem.User.nid;
	local key = string.format("BlackMemberList_%d",myself);
	return MyCompany.Aries.Player.LoadLocalData(key, {});
end
-- save a black member list to local db
-- @param list: a ids list {nid = 0,nid = 1}
function FriendsManager:SaveBlackMemberList(list)
	local myself = Map3DSystem.User.nid;
	local key = string.format("BlackMemberList_%d",myself);
	MyCompany.Aries.Player.SaveLocalData(key, list);
end
function FriendsManager:HasBlackMember(nid)
	if(not nid)then return end
	local list = self:SearchBlackMemberList();
	local k,v;
	for k,v in ipairs(list) do
		if(v.nid == nid)then
			return true;
		end
	end
end
function FriendsManager:CanAddBlackMember()
	local list = self:SearchBlackMemberList();
	if(list)then
		local len = #list;
		if(len < 100)then
			return true;
		end
	end
end
function FriendsManager:AddBlackMember(nid)
	if(not nid)then return end
	local list = self:SearchBlackMemberList();
	if(self:CanAddBlackMember())then
		table.insert(list,{nid = nid});
		self:SaveBlackMemberList(list);
	end
end
function FriendsManager:RemoveBlackMember(nid)
	if(not nid)then return end
	local list = self:SearchBlackMemberList();
	local k,v;
	for k,v in ipairs(list) do
		if(v.nid == nid)then
			table.remove(list,k);
			break;
		end
	end
	self:SaveBlackMemberList(list);
end
