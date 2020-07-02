--[[
Title: code behind for page TabCharacter.html
Author(s): WangTian
Date: 2009/4/24
Desc:  script/apps/Aries/Inventory/TabCharacter.html
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local TabCharacterPage = {};
commonlib.setfield("MyCompany.Aries.Inventory.TabCharacterPage", TabCharacterPage);

-- the profile page must be manually closed
TabCharacterPage.isEditing = false;

-- data source for items
function TabCharacterPage.DS_Func_Items(index)
	commonlib.echo(index);
	if(index ~= nil) then
		return {};
	elseif(index == nil) then
		return 0;
	end
end

function TabCharacterPage.SetEditState(isEditing)
	TabCharacterPage.isEditing = isEditing;
end

function TabCharacterPage.GetEditState()
	return TabCharacterPage.isEditing;
end
