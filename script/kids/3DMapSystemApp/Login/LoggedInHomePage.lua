--[[
Title: LoggedInHomePage.html code-behind script
Author(s): LiXizhi
Date: 2008/5/19
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/Login/LoggedInHomePage.lua");
-------------------------------------------------------
]]

-- create class
local LoggedInHomePage = {};
Map3DSystem.App.Login.LoggedInHomePage = LoggedInHomePage;

function LoggedInHomePage.OnInit()
	local self = document:GetPageCtrl();
	
	local uid = self:GetRequestParam("uid") or Map3DSystem.App.profiles.ProfileManager.GetUserID();
    if(uid and uid~="") then
        self:SetNodeValue("uid", uid);
    end
end

---------------------------------
-- page event handlers
---------------------------------

-- category is nil or ""
function LoggedInHomePage.ClearFeed(category)
	local pageCtrl = document:GetPageCtrl();
	if(pageCtrl._PAGESCRIPT) then
		pageCtrl._PAGESCRIPT["dsStoryFeed"] = nil;
		pageCtrl._PAGESCRIPT["dsMsgFeed"] = nil;
		pageCtrl._PAGESCRIPT["dsRequestFeed"] = nil;
	end
    Map3DSystem.App.ActionFeed.ClearFeed(category, pageCtrl)
end
