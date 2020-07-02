--[[
Title: code behind page for FriendsFinder.html
Author(s): LiXizhi
Date: 2008/4/30
Desc: Finding friends by providing a list of email, IM account. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/profiles/FriendsFinder.lua");
-------------------------------------------------------
]]

local FriendsFinder = {};
commonlib.setfield("Map3DSystem.App.profiles.FriendsFinder", FriendsFinder)

---------------------------------
-- page event handlers
---------------------------------

-- first time init page
function FriendsFinder.OnInit()
end

-- search people by email or name. 
function FriendsFinder.OnSearchPeople(name, values)
	local pageCtrl = document:GetPageCtrl();
	if(not pageCtrl) then return end
	
	local nameoremail = values["name_email"];
	if(nameoremail=="") then
		pageCtrl:SetUIValue("SearchResultTitle", "请输入名字或Email");
		return
	elseif(string.len(nameoremail)<3) then	
		pageCtrl:SetUIValue("SearchResultTitle", "请输入太短了");
		return
	else
		pageCtrl:SetNodeValue("SearchResultTitle", "请输入名字或Email");
		pageCtrl:SetNodeValue("name_email", nameoremail);
	end
	
	if(string.match(nameoremail, "@")) then
		-- search by email
		pageCtrl:GetNode("gvwFindFriends"):SetAttribute("DataSourceID", "FindByEmailDataSource");
		pageCtrl:CallMethod("FindByEmailDataSource", "SetParameter", "SelectParameters", "email", nameoremail);
		pageCtrl:CallMethod("FindByEmailDataSource", "Select", true); -- force an update
		pageCtrl:Refresh(0.01);
	else
		-- search by name
		pageCtrl:GetNode("gvwFindFriends"):SetAttribute("DataSourceID", "FindByUserNameDataSource");
		-- because we use LIKE clause, we will match for any user name that contains part nameoremail
		nameoremail = "%%"..nameoremail.."%%";
		pageCtrl:CallMethod("FindByUserNameDataSource", "SetParameter", "SelectParameters", "username", nameoremail);
		pageCtrl:CallMethod("FindByUserNameDataSource", "Select", true); -- force an update
		pageCtrl:Refresh(0.01);
	end
end
