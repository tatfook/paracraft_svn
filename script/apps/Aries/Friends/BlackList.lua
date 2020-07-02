--[[
Title: code behind for page BlackList.html
Author(s): WangTian
Date: 2009/5/3
Desc:  script/apps/Aries/Friends/BlackList.html
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local BlackListPage = {};
commonlib.setfield("MyCompany.Aries.Friends.BlackListPage", BlackListPage);

-- data source for items
function BlackListPage.DS_Func_BlackList(index)
	commonlib.echo(index);
	if(index ~= nil) then
		return {name = "BlackList_"..index..""};
	elseif(index == nil) then
		return 30;
	end
end