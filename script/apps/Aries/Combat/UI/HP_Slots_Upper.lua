--[[
Title: code behind for page MyCards.html
Author(s): WangTian
Date: 2009/6/12
Desc:  script/apps/Aries/Combat/UI/HP_Slots_Upper.html
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local HP_Slots_Upper = commonlib.gettable("MyCompany.Aries.Combat.HP_Slots_Upper");

-- The data source for items
function HP_Slots_Upper.DS_Func_Homeland_Items(dsTable, index, pageCtrl)
    if(not dsTable.status) then
        -- use a default cache
        HP_Slots_Upper.GetItems(pageCtrl, "access plus 5 minutes", dsTable)
    elseif(dsTable.status == 2) then    
        if(index == nil) then
			return dsTable.Count;
        else
			return dsTable[index];
        end
    end 
end

function HP_Slots_Upper.GetItems(pageCtrl, cachepolicy, output)
end