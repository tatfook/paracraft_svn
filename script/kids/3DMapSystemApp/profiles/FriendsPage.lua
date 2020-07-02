--[[
Title: code behind page for FriendsPage.html
Author(s): LiXizhi
Date: 2008/4/30
Desc: Viewing all friends of a given user (the current user) in a standalone window 
we can sort by who is online, who is recently updated, and who is newly added, etc. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/profiles/FriendsPage.lua");
FriendsPage.html?tab=recent
FriendsPage.html?tab=everyone
FriendsPage.html?tab=online
FriendsPage.html?uid=For which user to display
-------------------------------------------------------
]]

local FriendsPage = {};
commonlib.setfield("Map3DSystem.App.profiles.FriendsPage", FriendsPage)

---------------------------------
-- page event handlers
---------------------------------

-- first time init page
function FriendsPage.OnInit()
    local uid = document:GetPageCtrl():GetRequestParam("uid") or Map3DSystem.App.profiles.ProfileManager.GetUserID();
    if(uid and uid~="") then
        document:GetPageCtrl():SetNodeValue("uid", uid);
    end
end

-- The data source function. 
function FriendsPage.DS_Func(dsTable, index, uid, pageCtrl, pageindex, onlyonline, order, isinverse)
    if(not dsTable.status) then
        -- use a default cache
        FriendsPage.GetFriends(pageCtrl, "access plus 10 seconds", dsTable, uid, pageindex, onlyonline, order, isinverse)
    elseif(dsTable.status==2) then    
        if(index==nil) then
            return dsTable.Count;
        else
            return dsTable[index];
        end
    end 
end

-- get friends web service call. it will refresh page once finished. 
function FriendsPage.GetFriends(pageCtrl, cachepolicy, output, uid, pageindex, onlyonline, order, isinverse)
	local msg = {
		cache_policy = cachepolicy, 
		uid = uid,
		pageindex = pageindex or 0,
		onlyonline = onlyonline or 0,
		order = order or 1,
		isinverse = isinverse or 0,
	};
	output.status = 1;
	paraworld.friends.get(msg, "paraworld", function(msg)
		if(msg and (msg.errorcode==0 or errorcode==nil)) then
		    if(msg.uids) then
		        local uid;
		        local i=0;
		        for uid in string.gfind(msg.uids, "([%w%-]+)") do 
		            i = i+1
		            output[i] = {uid = uid};
		        end
		        output.Count = i;
		    else
		        output.Count = 0;
		    end
		else
		    log("warning: error fetching friends\n")    
		    commonlib.echo(msg);
		    output.Count = 0;
		end
		commonlib.resize(output, output.Count)
		output.status = 2;
		pageCtrl:Refresh();
	end);
end
