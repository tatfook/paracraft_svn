--[[
Title: 
Author(s): spring
Date: 2010/09/17
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatCardSubPage.lua");
-------------------------------------------------------
]]
local CombatCardSubPage = {};
commonlib.setfield("MyCompany.Aries.Inventory.CombatCardSubPage", CombatCardSubPage);

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;

-- The data source for items
function CombatCardSubPage.DS_Func_Items(dsTable, index, pageCtrl,showNum,card_maxnum)      
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
			CombatCardSubPage.GetItems(class, subclass, bag, pageCtrl, "access plus 5 minutes", dsTable,showNum,card_maxnum);
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

function CombatCardSubPage.GetItems(class, subclass, bag, pageCtrl, cachepolicy, output,showNum,card_maxnum)
	--默认显示6个
	showNum = showNum or 6;
	-- find the right bag for inventory items
	local bags;
	if(class == "combat") then
		bags = {24};
	elseif(class == "rune") then
		bags = {25};
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
	--local ItemManager = System.Item.ItemManager;
	bags.ReturnCount = 0;
	local _, bag;
	local prop = "";
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
								if(gsItem)then
									local assetkey = gsItem.assetkey or "";
									assetkey = string.lower(assetkey);
									--local prop = string.match(assetkey,".+_(.+)$");
									prop = string.match(assetkey,"^%d+_(%a+)_.+") or "";

									local IsEnable = true;
									-- 是否是金卡
									local GoldCardProp = gsItem.template.stats[99];
									if (GoldCardProp) then									 
										local BasicSkillGSID = gsItem.template.stats[100];
										IsEnable = hasGSItem(BasicSkillGSID);
									else
										IsEnable = true;
									end
									
									--all metal wood water fire earth
									if(subclass == "all" or (prop == subclass))then
										--24号包排除 经验石
										if(item.gsid ~= 22000)then
											combat_count = combat_count + 1;
											output[combat_count] = {guid = item.guid, gsid = item.gsid, isEnable=IsEnable, };
										end
									end
								end
							end
						end
						count = combat_count;
					end
					-- fill the 6 tiles per page
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
				--commonlib.echo("======output===prop:"..prop);
				--commonlib.echo(output);

				-- fetched inventory items
				output.status = 2;
				pageCtrl:Refresh(0.1);
			end
		end, cachepolicy);
	end
end
