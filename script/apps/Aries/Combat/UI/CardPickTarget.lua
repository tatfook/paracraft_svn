--[[
Title: code behind for page MyCards.html
Author(s): WangTian
Date: 2009/6/12
Desc:  script/apps/Aries/Combat/UI/MyCards.html
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local MyCards = commonlib.gettable("MyCompany.Aries.Combat.MyCards");

-- The data source for items
function MyCards.DS_Func_Homeland_Items(dsTable, index, pageCtrl)
    if(not dsTable.status) then
        -- use a default cache
        MyCards.GetItems(pageCtrl, "access plus 5 minutes", dsTable)
    elseif(dsTable.status == 2) then    
        if(index == nil) then
			return dsTable.Count;
        else
			return dsTable[index];
        end
    end 
end

function MyCards.GetItems(pageCtrl, cachepolicy, output)
	-- fetching inventory items
	output.status = 1;
	-- reacord each slot gsid
	local base_gsid = 23000;
	-- 14 pages of items
	output.Count = 14 * 7;
	local inc = 1;
	local i = 1;
	for i = 1, 14 do
		local j = 1;
		for j = 1, 7 do
			output[inc] = {gsid = base_gsid + i + (j - 1)};
			inc = inc + 1;
		end
	end
	
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	local equipGSItem = ItemManager.IfEquipGSItem;
	
	-- find the right bag for inventory items
	local bags = {25};
	bags.ReturnCount = 0;
	local _, bag;
	for _, bag in ipairs(bags) do
		ItemManager.GetItemsInBag(bag, "mycards_"..bag, function(msg)
			bags.ReturnCount = bags.ReturnCount + 1;
			if(bags.ReturnCount >= #bags) then
				if(msg and msg.items) then
					local i;
					for i = 1, #output do
						local gsid = output[i].gsid;
						local bHas, guid = hasGSItem(gsid);
						if(bHas) then
							output[i].bAvailable = true;
							output[i].guid = guid;
						else
							output[i].bAvailable = false;
						end
					end
				end
				commonlib.resize(output, output.Count);
				-- fetched inventory items
				output.status = 2;
				pageCtrl:Refresh(0.1);
			end
		end, cachepolicy);
	end
end