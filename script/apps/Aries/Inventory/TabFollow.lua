--[[
Title: code behind for page TabFollow.html
Author(s): WangTian
Date: 2009/4/24
Desc:  script/apps/Aries/Inventory/TabFollow.html
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local TabFollowPage = {};
commonlib.setfield("MyCompany.Aries.Inventory.TabFollowPage", TabFollowPage);

-- data source for items
function TabFollowPage.DS_Func_Items(index)
	commonlib.echo(index);
	if(index ~= nil) then
		return {};
	elseif(index == nil) then
		return 0;
	end
end