--[[
Title: code behind for page LoggedInHomePage.html
Author(s): LiXizhi
Date: 2008/10/27
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/HelloChat/Desktop/LoggedInHomePage.lua");
-------------------------------------------------------
]]

local LoggedInHomePage = {};
commonlib.setfield("MyCompany.HelloChat.LoggedInHomePage", LoggedInHomePage)

---------------------------------
-- page event handlers
---------------------------------

-- init
function LoggedInHomePage.OnInit()
	--local self = document:GetPageCtrl();
	--local name = self:GetRequestParam("name")
	--self:SetNodeValue("fileName", name);
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
