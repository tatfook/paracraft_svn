--[[
Title: code behind for page MyHomelandStore.html
Author(s): WangTian
Date: 2009/6/12
Desc:  script/kids/3DMapSystemUI/HomeLand/Pages/MyHomelandStore.lua
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/HaqiShop/NPCShopProvider.lua");
local NPCShopProvider = commonlib.gettable("MyCompany.Aries.NPCShopProvider");
local MyHomelandStorePage = commonlib.gettable("Map3DSystem.App.HomeLand.MyHomelandStorePage");
local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");
local Player = commonlib.gettable("MyCompany.Aries.Player");

-- The data source for items
function MyHomelandStorePage.DS_Func_Homeland_Items(dsTable, index, pageCtrl)      
	-- get the class of the 
	local class = pageCtrl:GetRequestParam("class");
	local subclass = pageCtrl:GetRequestParam("subclass");
	
    if(not dsTable.status) then
        -- use a default cache
        MyHomelandStorePage.GetItems(class, subclass, pageCtrl, "access plus 5 minutes", dsTable);
	end
    if(dsTable.status == 2) then    
        if(index == nil) then
			return dsTable.Count;
        else
			return dsTable[index];
        end
    end 
end

local cached_npc_items = {};

-- rebuild a given data source using data in local memory store into output table. 
function MyHomelandStorePage.RebuildDateSource(bags, npcids, output)
	local count = 0;
	local gsid_map = {}; -- mapping from gsid to index
	if(bags and #bags>0) then
		local __, bag;
		for __, bag in ipairs(bags) do
			local i;
			local bagitem_count = ItemManager.GetItemCountInBag(bag)
			for i = 1, bagitem_count do
				local item = ItemManager.GetItemByBagAndOrder(bag, i);
				if(item ~= nil) then
					count = count + 1;
					output[count] = {guid = item.guid, gsid = item.gsid or 0, bHas=true};
					gsid_map[item.gsid or 0] = count;
				end
			end
		end
	end
	local owned_item_count = count;

	if(npcids and #npcids>0) then
		local _, npcid;
		for _, npcid in ipairs(npcids) do
			if(not cached_npc_items[npcid]) then
				local items = NPCShopProvider.FindDataSource(npcid);
				if(items) then
					items_ds = {};
					cached_npc_items[npcid] = items_ds;
					for _, item in ipairs(items) do
						local level;
						local xiandou;
						local moudou;
						if(item.gsid) then
							if(item.exid) then
								local exTemplate = ItemManager.GetExtendedCostTemplateInMemory(item.exid);
								if(exTemplate and exTemplate.froms)then	
									local _, from;
									for _, from in ipairs(exTemplate.froms) do
										if(from.key == 17213) then
											xiandou = tonumber(from.value);
										elseif(from.key == 984) then
											moudou = tonumber(from.value);
										end
									end
								end
								if(exTemplate and exTemplate.pres)then	
									local _,v;
            						for _,v in pairs(exTemplate.pres) do
										if (tonumber(v.key)==-14) then
											level = tonumber(v.value);
										end
									end
								end
							end
							
							items_ds[#items_ds+1] = {gsid = item.gsid or 0, guid=0, exid = item.exid, level=level, moudou=moudou, xiandou=xiandou};
							table.sort(items_ds, function(a, b)
								return (a.level or 0) < (b.level or 0)
							end)
						end
					end
				end
			end
			if(cached_npc_items[npcid]) then
				local _, item;
				for _, item in ipairs(cached_npc_items[npcid]) do
					local item_index = gsid_map[item.gsid]
					if( not item_index) then
						count = count + 1;
						output[count] = item;
					else
						local item_old = output[item_index];
						if(item_old and not item_old.exid) then
							output[item_index] = item;
							item.bHas = item_old.bHas;
						end
					end
				end
			end
		end
	end
	
	if(npcids and #npcids>1) then
		commonlib.resize(output, count);
		commonlib.algorithm.quicksort(output, function(a, b)
			return (((a.level or 0) <= (b.level or 0)));
		end, owned_item_count+1, count)
	end

	-- fill the 8 tiles per page
	local displaycount = math.ceil(count/8) * 8;

	if(count == 0) then
		displaycount = 8;
	end
	local i;
	for i = count + 1, displaycount do
		output[i] = {guid = 0, gsid=0};
	end
	output.Count = displaycount;

	commonlib.resize(output, output.Count);

	-- fetched inventory items
	output.status = 2;
end

function MyHomelandStorePage.OnPurchaseItem(gsid, params)
	if(type(params) == "table") then
		if(params.level and params.level>=Player.GetLevel()) then
			_guihelper.MessageBox(format("%d级才能解锁这个物品， 快去升级吧", params.level));
			return;
		end
		local command = System.App.Commands.GetCommand("Profile.Aries.PurchaseItemWnd");
		if(command) then
			command:Call({gsid = gsid, exid = params.exid, npc_shop = if_else(params.exid, true, nil)});
		end
	end
end

function MyHomelandStorePage.GetItems(class, subclass, pageCtrl, cachepolicy, output)
	-- find the right bag for inventory items
	local bags;
	-- find the right npc shop items. 
	local npcids;
	if(class == "homeoutdoor" and subclass == "house") then
		bags = {41};
		npcids = {40003};
	elseif(class == "homeoutdoor" and subclass == "plant") then -- not used now
		bags = {42};
	elseif(class == "homeoutdoor" and subclass == "other") then
		bags = {44};
		npcids = {40001};
	elseif(class == "homeoutdoor" and subclass == "effect") then
		bags = {45};
	elseif(class == "homeoutdoor" and subclass == "parterre") then
		bags = {46};
		npcids = {40002}; -- plant
	elseif(class == "homeoutdoor" and subclass == "all") then
		bags = {41, 44, 45, 46, 51, 52, 53, 54};
		npcids = {40002,40001,40003, 40005};
	elseif(class == "homeindoor" and subclass == "decorate") then
		bags = {51};
	elseif(class == "homeindoor" and subclass == "furniture") then
		bags = {52};
	elseif(class == "homeindoor" and subclass == "honor") then
		bags = {53};
	elseif(class == "homeindoor" and subclass == "other") then
		bags = {54};
	elseif(class == "homeindoor" and subclass == "all") then
		bags = {51, 52, 53, 54};
		npcids = {40005};
	end
	if(bags == nil) then
		-- return empty datasource table, if no bag id is specified
		output.Count = 0;
		commonlib.resize(output, output.Count)
		return;
	end
	-- fetching inventory items
	output.status = 1;
	bags.ReturnCount = 0;
	local _, bag;
	local is_fetching;
	for _, bag in ipairs(bags) do
		ItemManager.GetItemsInBag(bag, "homelanditems_"..bag, function(msg)
			bags.ReturnCount = bags.ReturnCount + 1;
			if(bags.ReturnCount >= #bags) then
				-- rebuild invetory when all bag items are fetched. 
				MyHomelandStorePage.RebuildDateSource(bags, npcids, output)
				
				-- when data is available, refresh the page. 
				if(is_fetching) then
					pageCtrl:Refresh(0.1);
				end
			end
		end, cachepolicy);
	end
	is_fetching = true;
end