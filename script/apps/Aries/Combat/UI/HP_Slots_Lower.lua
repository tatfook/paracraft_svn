--[[
Title: code behind for page MyCards.html
Author(s): WangTian
Date: 2009/6/12
Desc:  script/apps/Aries/Combat/UI/HP_Slots_Lower.html
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local HP_Slots_Lower = commonlib.gettable("MyCompany.Aries.Combat.HP_Slots_Lower");

-- The data source for items
function HP_Slots_Lower.DS_Func_Homeland_Items(dsTable, index, pageCtrl)
    if(not dsTable.status) then
        -- use a default cache
        HP_Slots_Lower.GetItems(pageCtrl, "access plus 5 minutes", dsTable)
    elseif(dsTable.status == 2) then    
        if(index == nil) then
			return dsTable.Count;
        else
			return dsTable[index];
        end
    end 
end
