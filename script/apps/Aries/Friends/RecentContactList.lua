--[[
Title: code behind for page RecentContactList.html
Author(s): WangTian
Date: 2009/5/3
Desc:  script/apps/Aries/Friends/RecentContactList.html
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local RecentContactListPage = {};
commonlib.setfield("MyCompany.Aries.Friends.RecentContactListPage", RecentContactListPage);


local dsTable = {};
--RecentContactListPage.allowmosheng = RecentContactListPage.allowmosheng or true;

if(RecentContactListPage.allowmosheng==nil)then
	RecentContactListPage.allowmosheng = true;
end

-- data source for items
function RecentContactListPage.DS_Func_RecentContact(index, pageCtrl)
	local ProfileManager = commonlib.gettable("System.App.profiles.ProfileManager");
	if(index ~= nil) then
		return dsTable[index];
	elseif(index == nil) then
		-- clear the existing data
		dsTable = {};
		local count = 0;
		local from, _;
		local RecentContacts = MyCompany.Aries.app:ReadConfig("RecentContact", {});
		for from, _ in pairs(RecentContacts) do
			count = count + 1;
			local nid = string.gsub(from, "@.*$", "");
			nid = tonumber(nid);
			local priority = count;
			local Friends = MyCompany.Aries.Friends;
			--if(Friends.IsUserOnlineInMemory(nid) and Friends.IsFriendInMemory(nid)) then
			if(Friends.IsUserOnlineInMemory(nid)) then
				-- add the online contact priority by 30000
				priority = 30000 + priority;
			end
			local isvip = false;
			local userinfo = ProfileManager.GetUserInfoInMemory(nid);
			if(userinfo and userinfo.energy and userinfo.energy > 0 and userinfo.mlel) then
				-- add the VIP contact priority by 10000 and sorted by m level
				priority = 10000 + priority + userinfo.mlel * 500;
				isvip = true;
			end
			dsTable[count] = {
				bshow = true, nid = nid, priority = priority, isvip = isvip,
				icon = "Texture/Aries/Friends/FriendsWnd_BuddyIcon_Online_32bits.png;0 0 32 26"
			};
		end

	    -- sort the table according to priority
	    table.sort(dsTable, function(a, b)
			return (a.priority > b.priority);
	    end);

		dsTable.count = count;
		
		if(dsTable.count < 10) then
			dsTable.count = 10;
			local j;
			for j = (count+1), dsTable.count do
				dsTable[j] = {bshow = false};
			end
		end
		
		pageCtrl:SetUIValue("recentcontactcount", "("..count..")");
		
		return dsTable.count;
	end
end

function RecentContactListPage.AllowMoSheng(page,bAllowed)
	RecentContactListPage.allowmosheng = bAllowed;
	if(page)then
		page:Refresh(0.01);
	end
end