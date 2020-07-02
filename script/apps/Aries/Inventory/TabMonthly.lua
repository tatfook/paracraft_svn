--[[
Title: code behind for page TabMonthly.html
Author(s): WangTian
Date: 2009/4/24
Desc:  script/apps/Aries/Inventory/TabMonthly.html
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local TabMonthlyPage = {};
commonlib.setfield("MyCompany.Aries.Inventory.TabMonthlyPage", TabMonthlyPage);

-- data source for items
function TabMonthlyPage.DS_Func_Items(index)
	commonlib.echo(index);
	if(index ~= nil) then
		return {};
	elseif(index == nil) then
		return 0;
	end
end