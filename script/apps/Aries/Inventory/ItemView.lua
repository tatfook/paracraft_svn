--[[
Title: code behind for page ItemView.html
Author(s): WangTian
Date: 2009/4/24
Desc:  script/apps/Aries/Inventory/ItemView.html
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local ItemViewPage = {};
commonlib.setfield("MyCompany.Aries.Inventory.ItemViewPage", ItemViewPage);

-- The data source for items
function ItemViewPage.DS_Func_Items(dsTable, index, pageCtrl)      
	-- get the class of the 
	local class = pageCtrl:GetRequestParam("class");
	local subclass = pageCtrl:GetRequestParam("subclass");
	local bag = pageCtrl:GetRequestParam("bag");
	if(bag) then
		bag = tonumber(bag);
	end
	
    if(not dsTable.status) then
        -- use a default cache
        if(index == nil) then
			dsTable.Count = 100;
			ItemViewPage.GetItems(class, subclass, bag, pageCtrl, "access plus 5 minutes", dsTable);
			return dsTable.Count;
        else
			if(index <= 100) then
				return {guid = 0};
			end
        end
    elseif(dsTable.status == 2) then
        if(index == nil) then
			return dsTable.Count;
        else
			return dsTable[index];
        end
    end 
end

function ItemViewPage.GetItems(class, subclass, bag, pageCtrl, cachepolicy, output)
	-- find the right bag for inventory items
	local bags;
	if(class == "character" and subclass == "makeup") then
		bags = {1};
	elseif(class == "character" and subclass == "consumable") then
		bags = {10010};
		--bags = {30001, 10010, 91};
		--bags = {30011};
	elseif(class == "character" and subclass == "collect") then
		bags = {12, 42};
	elseif(class == "character" and subclass == "reading") then
		bags = {13};
	elseif(class == "mount" and subclass == "makeup") then
		bags = {21};
	elseif(class == "mount" and subclass == "feed") then
		bags = {22};
	elseif(class == "mount" and subclass == "pill") then
		bags = {23};
	elseif(class == "mount" and subclass == "medal") then
		bags = {10063};
	elseif(class == "test" and subclass == "homeland") then
		bags = {10001};
	end
	if(bags == nil) then
		bags = {bag};
	end
	if(bags == nil) then
		-- return empty datasource table, if no bag id is specified
		output.Count = 0;
		commonlib.resize(output, output.Count)
		return;
	end
	-- fetching inventory items
	output.status = 1;
	local ItemManager = System.Item.ItemManager;
	bags.ReturnCount = 0;
	local _, bag;
	for _, bag in ipairs(bags) do
		ItemManager.GetItemsInBag(bag, "ariesitems_"..bag, function(msg)
			bags.ReturnCount = bags.ReturnCount + 1;
			if(bags.ReturnCount >= #bags) then
				if(msg and msg.items) then
					local count = 0;
					local __, bag;
					for __, bag in ipairs(bags) do
						local i;
						for i = 1, ItemManager.GetItemCountInBag(bag) do
							local item = ItemManager.GetItemByBagAndOrder(bag, i);
							if(item ~= nil) then
								output[count + i] = {guid = item.guid};
							end
						end
						count = count + ItemManager.GetItemCountInBag(bag);
					end
					-- fill the 12 tiles per page
					local displaycount = math.ceil(count/12) * 12;
					if(count == 0) then
						displaycount = 12;
					end
					local i;
					for i = count + 1, displaycount do
						output[i] = {guid = 0};
					end
					output.Count = displaycount;
				end
				commonlib.resize(output, output.Count);
				-- fetched inventory items
				output.status = 2;
				pageCtrl:Refresh(0.1);
			end
		end, cachepolicy);
	end
end