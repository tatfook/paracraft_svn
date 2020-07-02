--[[
Title: code behind for page FriendsWnd.html
Author(s): WangTian
Date: 2009/5/3
Desc:  script/apps/Aries/Friends/FriendsWnd.html
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local FriendsWndPage = {};
commonlib.setfield("MyCompany.Aries.Friends.FriendsWndPage", FriendsWndPage);

-- data source for items
function FriendsWndPage.DS_Func_Buddies(index)
	commonlib.echo(index);
	if(index ~= nil) then
		return {};
	elseif(index == nil) then
		return 10;
	end
end