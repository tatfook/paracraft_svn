--[[
Title: code behind for page SeedView.html
Author(s):
Date: 
Desc:  script/kids/3DMapSystemUI/HomeLand/Pages/SeedView.lua
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local SeedViewPage = {};
commonlib.setfield("MyCompany.Aries.Inventory.SeedViewPage", SeedViewPage);
-- The data source for items
function SeedViewPage.DS_Func_Homeland_Items(dsTable, index, pageCtrl)      
	-- get the class of the 
	local class = pageCtrl:GetRequestParam("class");
	local subclass = pageCtrl:GetRequestParam("subclass");
	
    if(not dsTable.status) then
        -- use a default cache
        SeedViewPage.GetItems(class, subclass, pageCtrl, "access plus 5 minutes", dsTable)
    elseif(dsTable.status == 2) then    
        if(index == nil) then
			return dsTable.Count;
        else
			return dsTable[index];
        end
    end 
end
function SeedViewPage.GetItems(class, subclass, pageCtrl, cachepolicy, output)
	local self = SeedViewPage;
	-- find the right bag for inventory items
	local bag;
	bag = 42;
	-- fetching inventory items
	output.status = 1;
	local ItemManager = Map3DSystem.Item.ItemManager;
	ItemManager.GetItemsInBag(bag, "homelanditems_"..bag, function(msg)
		if(msg and msg.items) then
			local count = ItemManager.GetItemCountInBag(bag);
			if(count == 0) then
				-- dirty code to notify the user no seed available
				--_guihelper.MessageBox("你没有种子了，快去买些种子回来吧！");
				count = 1;
			end
			-- fill the 5 tiles per page
			count = math.ceil(count/5) * 5;
			if(count > 5) then
				output.AllowPaging = true;
			end
			local i;
			for i = 1, count do
				local item = ItemManager.GetItemByBagAndOrder(bag, i);
				if(item ~= nil) then
					output[i] = {guid = item.guid};
				else
					output[i] = {guid = 0};
				end
			end
			output.Count = count;
		end
		commonlib.resize(output, output.Count);
		-- fetched inventory items
		output.status = 2;
		pageCtrl:Refresh();
	end, cachepolicy);
end