--[[
Title: MarketService
Author(s): Leio
Date: 2008/1/14
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/MarketApp/MarketService.lua");
------------------------------------------------------------
]]

-- requires

-- create class
if(not Map3DSystem.App.MarketService) then Map3DSystem.App.MarketService = {} end


--Send a request to get a list of all items in sale in the application. 
--@param pageNumber: 1 based index of page. 
--@param ItemsPerPage: default to 10
function Map3DSystem.App.MarketService.GetItemList(app_key, pageNumber, ItemsPerPage)
end



--Buy a given item using the current user session and id. 
--When transaction completed, item will automatically show up in the user’s default inventory. 
function Map3DSystem.App.MarketService.BuyItem(app_key, item_id)
end




