--[[
Title: 
Author(s): Leio
Date: 2010/07/01
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Inventory/ItemViewExPage.lua");
-------------------------------------------------------
]]
local ItemViewExPage = {};
commonlib.setfield("MyCompany.Aries.Inventory.ItemViewExPage", ItemViewExPage);

-- The data source for items
function ItemViewExPage.DS_Func_Items(dsTable, index, pageCtrl,showNum)      
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
			ItemViewExPage.GetItems(class, subclass, bag, pageCtrl, "access plus 5 minutes", dsTable,showNum);
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

function ItemViewExPage.GetItems(class, subclass, bag, pageCtrl, cachepolicy, output,showNum)
	--默认显示12个
	showNum = showNum or 12;
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
	elseif(class == "mount" and subclass == "pill_color") then
		bags = {23};
	elseif(class == "mount" and subclass == "pill") then
		bags = {26, 23}; -- marker and pill
	elseif(class == "mount" and subclass == "medal") then
		bags = {10063};
	elseif(class == "combat") then
		bags = {24};
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

	local marker_gsid_to_index = {};
	
	local _, bag;
	for _, bag in ipairs(bags) do
		ItemManager.GetItemsInBag(bag, "ariesitems_"..bag, function(msg)
			bags.ReturnCount = bags.ReturnCount + 1;
			if(bags.ReturnCount >= #bags) then
				if(msg and msg.items) then
					local count = 0;
					local combat_count = 0;
					local __, bag;
					for __, bag in ipairs(bags) do
						local i;
						for i = 1, ItemManager.GetItemCountInBag(bag) do
							local item = ItemManager.GetItemByBagAndOrder(bag, i);
							if(item ~= nil) then
								local gsItem = ItemManager.GetGlobalStoreItemInMemory(item.gsid)
								if(class ~= "combat")then
									if(gsItem)then
										if(class == "mount" and subclass == "pill_color")then
											local a = gsItem.template.class;
											local b = gsItem.template.subclass;
											if(b == 7)then
												count = count + 1;
												output[count] = {guid = item.guid, gsid = item.gsid, };
											end
										elseif(class == "mount" and subclass == "pill")then
											local class = gsItem.template.class;
											local subclass = gsItem.template.subclass;
											if(subclass == 6) then
												-- pill
												count = count + 1;
												output[count] = {guid = item.guid, gsid = item.gsid, };
												--local marker_gsid = ItemManager.GetTransformMarker_from_Pill(item.gsid);
												--local hasGSItem = ItemManager.IfOwnGSItem;
												--local bHas;
												--if(marker_gsid) then
													--bHas = hasGSItem(marker_gsid);
												--end
												--if(bHas and marker_gsid and marker_gsid_to_index[marker_gsid]) then
													---- overwrite with pill item
													--local i_marker = marker_gsid_to_index[marker_gsid];
													--output[i_marker] = {guid = item.guid, gsid = item.gsid, is_marker = true};
												--elseif(bHas and marker_gsid) then
													---- skip the pill that is already mounted
												--else
													--count = count + 1;
													--output[count] = {guid = item.guid, gsid = item.gsid, };
												--end
											elseif(subclass == 8) then
												-- transform marker
												count = count + 1;
												output[count] = {guid = item.guid, gsid = item.gsid, is_marker = true};
												-- record marker index
												marker_gsid_to_index[item.gsid] = count;
											end
										else
											output[count + i] = {guid = item.guid, gsid = item.gsid, };
										end
									else
										LOG.std("", "error","can't find gsItem",item.gsid);
									end
								else
									if(gsItem)then
										local assetkey = gsItem.assetkey or "";
										assetkey = string.lower(assetkey);
										local prop = string.match(assetkey,".+_(.+)$");
										--all metal wood water fire earth
										if(subclass == "all" or (prop == subclass))then
											--24号包排除 经验石
											if(item.gsid ~= 22000)then
												combat_count = combat_count + 1;
												output[combat_count] = {guid = item.guid, gsid = item.gsid, };
											end
										end
									else
										LOG.std("", "error","can't find gsItem",item.gsid);
									end
								end
							end
						end
						if(class ~= "combat")then
							if(class == "mount" and subclass == "pill_color")then
							elseif(class == "mount" and subclass == "pill")then
							else
								count = count + ItemManager.GetItemCountInBag(bag);
							end
						else
							count = combat_count;
						end
					end
					-- fill the 12 tiles per page
					local displaycount = math.ceil(count/showNum) * showNum;
					if(count == 0) then
						displaycount = showNum;
					end
					local i;
					for i = count + 1, displaycount do
						output[i] = {guid = 0, gsid = 0};
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