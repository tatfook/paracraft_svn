--[[
Title: inventory bag page for aquarius item system
Author(s): WangTian
Date: 2009/2/10
use the lib:
------------------------------------------------------------------------
NPL.load("(gl)script/apps/Aquarius/Inventory/InventoryBagPage.lua");

script/apps/Aquarius/Inventory/InventoryBagPage.html?class=1&subclass=1
------------------------------------------------------------------------
]]

local InventoryBagPage = {};
commonlib.setfield("MyCompany.Aquarius.InventoryBagPage", InventoryBagPage)

---------------------------------
-- page event handlers
---------------------------------

-- first time init page
function InventoryBagPage.OnInit()
    local class = document:GetPageCtrl():GetRequestParam("class");
    local subclass = document:GetPageCtrl():GetRequestParam("subclass");
    
    if(class and class ~= "" and subclass and subclass ~= "") then
        document:GetPageCtrl():SetNodeValue("class", tonumber(class));
        document:GetPageCtrl():SetNodeValue("subclass", tonumber(subclass));
    end
end

-- The data source function. 
function InventoryBagPage.DS_Func(dsTable, index, uid, pageCtrl, class, subclass)
    if(not dsTable.status) then
		-- get item from local server, item system uses an epoll mechanism to update with event listeners
        InventoryBagPage.GetItems(pageCtrl, "access plus 1 year", dsTable, uid, class, subclass)
    elseif(dsTable.status == 2) then    
        if(index == nil) then
            return dsTable.Count;
        else
            return dsTable[index];
        end
    end 
end

-- get friends web service call. it will refresh page once finished. 
function InventoryBagPage.GetItems(pageCtrl, cachepolicy, output, uid, class, subclass)
	local class = tonumber(class);
	local subclass = tonumber(subclass);
    --local class = tonumber(pageCtrl:GetNodeValue("class"));
    --local subclass = tonumber(pageCtrl:GetNodeValue("subclass"));
    
	local msg = {
		cache_policy = cachepolicy, 
		uid = uid,
		pageindex = pageindex or 0,
		onlyonline = onlyonline or 0,
		order = order or 1,
		isinverse = isinverse or 0,
	};
	output.status = 1;
	--paraworld.items.getitemsinmybag(msg, "paraworld", function(msg)
	--end);
	
	paraworld.friends.get(msg, "paraworld", function(msg)
		-- get the bag with the BagFamily that contains the class.subclass items
		local myBags = System.Item.ItemManager.GetMyBags();
		local currentBag;
		local _, bag;
		
		for _, bag in pairs(myBags) do
			local nContainerSlots = bag:GetAttribute("ContainerSlots");
			local nBagFamily = bag:GetAttribute("BagFamily");
			if(nContainerSlots > 0) then
				if(nBagFamily == (class * 1000 + subclass)) then
					currentBag = bag;
					break;
				end
			end
		end
		
		-- get the items in the bag
		if(currentBag ~= nil) then
		
			output.Count = currentBag:GetAttribute("ContainerSlots");
			local slot;
			for slot = 1, output.Count do
				output[slot] = {slot = slot, bag = currentBag:GetID()};
			end
		else
			output.Count = 0;
		end
		output.status = 2;
		pageCtrl:Refresh();
	end);
end




--<script type="text/npl" src="InventoryBagPage.lua" trans="ParaworldMCML">
--<![CDATA[
---- status: nil not available, 1 fetching, 2 fetched. 
--dsItems = Eval("dsItems") or {status=nil, };
--
--function DS_Func_Items(index)
    --return MyCompany.Aquarius.InventoryBagPage.DS_Func(dsItems, index, pageCtrl);
--end
--]]></script>
--
--<script refresh="false" type="text/npl" src="InventoryBagPage.lua">
	--local tabpage = document:GetPageCtrl():GetRequestParam("tab");
    --if(tabpage and tabpage~="") then
        --document:GetPageCtrl():SetNodeValue("FriendsTabs", tabpage);
    --end
--</script>
--<script type="text/npl" src="InventoryBagPage.lua"><![CDATA[
--MyCompany.Aquarius.InventoryBagPage.OnInit();
--local pageCtrl = document:GetPageCtrl();
--class = pageCtrl:GetNodeValue("class");
--subclass = pageCtrl:GetNodeValue("subclass");
--
---- status: nil not available, 1 fetching, 2 fetched. 
--dsItems = Eval("dsItems") or {status=nil, };
--
--function DS_Func_Items(index)
    --return MyCompany.Aquarius.InventoryBagPage.DS_Func(dsItems, index, pageCtrl);
--end
--
--]]></script>