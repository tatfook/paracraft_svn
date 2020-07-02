--[[
Title: code behind for page feed.html
Author(s): LiXizhi
Date: 2009/1/1
Desc:  script/apps/Aquarius/Profile/feed.html?uid=&nid=
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local feedPage = {};
commonlib.setfield("MyCompany.Aquarius.feedPage", feedPage)

---------------------------------
-- page event handlers
---------------------------------

-- init
function feedPage.OnInit()
	local self = document:GetPageCtrl();
	local uid = self:GetRequestParam("uid") or Map3DSystem.App.profiles.ProfileManager.GetUserID();
    if(uid and uid~="") then
		self:SetNodeValue("uid", uid);
    end
end
