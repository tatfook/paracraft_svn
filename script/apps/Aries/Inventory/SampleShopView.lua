--[[
Title: code behind for page SampleShopView.html
Author(s): WangTian
Date: 2009/6/1
Desc:  script/apps/Aries/Inventory/SampleShopView.html
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local SampleShopViewPage = {};
commonlib.setfield("MyCompany.Aries.Inventory.SampleShopViewPage", SampleShopViewPage);

-- The data source for sample items
function SampleShopViewPage.DS_Func_Items(index)
    if(index == nil) then
        return 10;
    else
        return nil;
    end
end
