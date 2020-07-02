--[[
Title: code behind page for ProfilePage.html
Author(s): LiXizhi
Date: 2008/6/3
Desc: The user profile page to show when clicked on a user name link
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/profiles/ProfilePage.lua");
-- uid is for whom the profile page is shown. if nil, it is the current user. 
script/kids/3DMapSystemApp/Profiles/ProfilePage.html?uid=XXX
-------------------------------------------------------
]]

local ProfilePage = {};
commonlib.setfield("Map3DSystem.App.profiles.ProfilePage", ProfilePage)

---------------------------------
-- page event handlers
---------------------------------

-- first time init page
function ProfilePage.OnInit()
	local self = document:GetPageCtrl();
	local uid = self:GetRequestParam("uid") or Map3DSystem.App.profiles.ProfileManager.GetUserID();
    if(uid and uid~="") then
        self:SetNodeValue("uid", uid);
    end
end
