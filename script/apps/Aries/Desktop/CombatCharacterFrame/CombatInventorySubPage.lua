--[[
Title: code behind for page CombatInventorySubPage.html
Author(s): zrf
Date: 2010/9/6
Desc:  script/apps/Aries/Desktop/CombatCharacterFrame/CombatInventorySubPage.html
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local Player = commonlib.gettable("MyCompany.Aries.Player");

local CombatInventorySubPage = commonlib.gettable("MyCompany.Aries.Desktop.CombatInventorySubPage");

-- all items
CombatInventorySubPage.inventory = CombatInventorySubPage.inventory or {Count = 0};
-- filtered items in the current selected category
CombatInventorySubPage.showitems = CombatInventorySubPage.showitems or {Count = 0};
-- sub page index
CombatInventorySubPage.curpage = 1;

function CombatInventorySubPage.Init()
	CombatInventorySubPage.curpage = CombatInventorySubPage.curpage or 1;
	CombatInventorySubPage.pagectrl = document:GetPageCtrl();
	CombatInventorySubPage.inventory = CombatInventorySubPage.inventory or {};

	local tmp = tostring(CombatInventorySubPage.curpage);

	if(CombatInventorySubPage.pagectrl:GetNodeValue("tabs") ~= tmp )then
		CombatInventorySubPage.pagectrl:SetNodeValue("tabs", tmp);
	end

	CombatInventorySubPage.nid = CombatInventorySubPage.nid or System.App.profiles.ProfileManager.GetNID();
	CombatInventorySubPage.nid = tonumber(CombatInventorySubPage.nid);
	CombatInventorySubPage.inventory = CombatInventorySubPage.inventory or {};
end

-- get all items(maybe from local cache), apply the current filter, and then refresh page
-- @param page: nil or when some of the data is fetched, we will invoke page:Refresh()
-- @param callback_func: nil or the callback func when data is available. function(bIsImmediateResult) end, bIsImmediateResult is true if callback is called before this function returns. 
-- @return true if result is immediate. 
function CombatInventorySubPage.GetItems(page, call_back)
	local bIsImmediateResult;
	CombatInventorySubPage.showitems.Count = 100;
	local bags = { 1, };
	CombatInventorySubPage.inventory.status = 1;
	local ItemManager = System.Item.ItemManager;
	bags.ReturnCount = 0;
	local _, bag;
	for _,bag in ipairs(bags) do
		ItemManager.GetItemsInBag( bag, "ariesitems_" .. bag, function(msg)
			bags.ReturnCount = bags.ReturnCount + 1;
			-- when all bags are fetched.
			if( bags.ReturnCount >= #bags)then
				if(msg and msg.items)then
					local count = 0;
					local __,bag;

					for __,bag in ipairs(bags) do
						local i;
						local bagitem_count = ItemManager.GetItemCountInBag(bag);
						for i = 1, bagitem_count do
							local item = ItemManager.GetItemByBagAndOrder(bag, i);
							if( item ~= nil )then
								CombatInventorySubPage.inventory[count+ i] = { guid=item.guid,gsid=item.gsid};
							end
						end
						count = count + bagitem_count;
					end

					-- new user levelup bag item.
					--local bHas_17150, guid_17150 = ItemManager.IfOwnGSItem(17150, 12);
					--if(bHas_17150) then
						--CombatInventorySubPage.inventory[count + 1] = { guid=guid_17150, gsid=17150};
						--count= count + 1;
					--end

					-- create dummy items, so that it is multiple is 3row*4col=12 cells
					local displaycount = math.ceil(count / 12) * 12;

					if(count == 0 )then
						displaycount = 12;
					end

					local i;
					for i = count + 1, displaycount do
						CombatInventorySubPage.inventory[i] = { guid = 0 };
					end

					CombatInventorySubPage.inventory.Count = count;
				end

				CombatInventorySubPage.Filter();
				CombatInventorySubPage.inventory.status = 2;
				if(page) then
					page:Refresh(0.01);
				end
				if(call_back) then
					call_back(bIsImmediateResult == nil);
				end
				bIsImmediateResult = true;
			end
		end, "access plus 5 minutes");
	end
	if(bIsImmediateResult == nil) then
		bIsImmediateResult = false;
	end
	return bIsImmediateResult;
end

function CombatInventorySubPage.GetPage()
	return CombatInventorySubPage.curpage;
end

-- filter data for current sub category
function CombatInventorySubPage.Filter()
	local tmp = CombatInventorySubPage.curpage;
	local item,gsItem;
	local class,subclass,bagfamily;
	CombatInventorySubPage.showitems = {Count = 0};
	for _, item in ipairs(CombatInventorySubPage.inventory) do
		if(item.guid~=0)then
			gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(tonumber(item.gsid));
			if(gsItem)then
				class = tonumber(gsItem.template.class);
				subclass = tonumber(gsItem.template.subclass);
				bagfamily = gsItem.template.bagfamily;
						
				if( ( tmp == 1) or
					( tmp == 2 and class == 1 and ( subclass == 2 or subclass == 18 ) ) or
					( tmp == 3 and class == 1 and ( subclass == 5 or subclass == 6 or subclass == 19 ) ) or
					( tmp == 4 and class == 1 and ( subclass == 7 or subclass == 71 ) ) or
					( tmp == 5 and class == 1 and (subclass == 15 or subclass == 16 or subclass == 17)) or
					( tmp == 6 and class == 1 and ( subclass == 8 or subclass == 70 ) ) or
					( tmp == 7 and ( (class == 1 and subclass == 10) or (class == 1 and subclass == 11) )) or
					( tmp == 8 and class == 19 and subclass == 1) )then
					table.insert(CombatInventorySubPage.showitems,item);
					CombatInventorySubPage.showitems.Count = CombatInventorySubPage.showitems.Count + 1;
				end
			end
		end
	end
end

-- get the current bag size
function CombatInventorySubPage.GetBagSize()
	if(CombatInventorySubPage.inventory)then
		return CombatInventorySubPage.inventory.Count or 0;
	end
	return 0;
end

-- Get bage size string
function CombatInventorySubPage.GetBagSizeString()
	return format("%d/%d", CombatInventorySubPage.GetBagSize(), Player.GetMaxBagSize());
end

function CombatInventorySubPage.GetBagSizeTooltip()
	if(CombatInventorySubPage.GetBagSize()>Player.GetMaxBagSize())then
		return "物品总数/背包容量(魔法星可以翻倍)";
	else
		return "物品总数/背包容量(魔法星可以翻倍)";
	end
end

-- ds function of the current selected sub category
function CombatInventorySubPage.DS_Func(index)
	local size = 0;
	local self = CombatInventorySubPage
	if(self.showitems)then
		size = #self.showitems;
	end
	local displaycount = math.ceil(size / Player.GetMaxBagSize()) * Player.GetMaxBagSize();
	if(displaycount == 0)then
		displaycount = Player.GetMaxBagSize();
	end

	local i;
	for i = size + 1,displaycount do
		self.showitems[i] = { guid = 0, };
	end
	if(index == nil)then
		return #(self.showitems);
	else
		return self.showitems[index];
	end
end