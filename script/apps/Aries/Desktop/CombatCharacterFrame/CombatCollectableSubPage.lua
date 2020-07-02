--[[
Title: code behind for page CombatCollectableSubPage.html
Author(s): zrf
Date: 2010/9/6
Desc:  script/apps/Aries/Desktop/CombatCharacterFrame/CombatCollectableSubPage.html
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local Player = commonlib.gettable("MyCompany.Aries.Player");
local CombatCollectableSubPage = commonlib.gettable("MyCompany.Aries.Desktop.CombatCollectableSubPage");

CombatCollectableSubPage.items = CombatCollectableSubPage.items or {Count = 0};
CombatCollectableSubPage.showitems = CombatCollectableSubPage.showitems or {Count = 0};

function CombatCollectableSubPage.Init()
	CombatCollectableSubPage.curpage = CombatCollectableSubPage.curpage or 1;
	CombatCollectableSubPage.pagectrl = document:GetPageCtrl();
	CombatCollectableSubPage.items = CombatCollectableSubPage.items or {};

	local tmp = tostring(CombatCollectableSubPage.curpage);

	if(CombatCollectableSubPage.pagectrl:GetNodeValue("tabs") ~= tmp )then
		CombatCollectableSubPage.pagectrl:SetNodeValue("tabs", tmp);
	end

	CombatCollectableSubPage.nid = CombatCollectableSubPage.nid or System.App.profiles.ProfileManager.GetNID();
	CombatCollectableSubPage.nid = tonumber(CombatCollectableSubPage.nid);
	
	if(MyCompany.Aries.Desktop.CombatCharacterFrame.showcollectall)then
		CombatCollectableSubPage.curpage = 1;
		CombatCollectableSubPage.pagectrl:SetNodeValue("tabs", "1");
		MyCompany.Aries.Desktop.CombatCharacterFrame.showcollectall = false;
	end
end

-- get all items(maybe from local cache), apply the current filter, and then refresh page
-- @param page: nil or when some of the data is fetched, we will invoke page:Refresh()
-- @param callback_func: nil or the callback func when data is available. function(bIsImmediateResult) end, bIsImmediateResult is true if callback is called before this function returns. 
-- @return true if result is immediate. 
function CombatCollectableSubPage.GetItems(page, call_back)
	local bIsImmediateResult;
	CombatCollectableSubPage.showitems.Count = 100;
	local bags = { 12, 13, 14 };
	CombatCollectableSubPage.items.status = 1;
	local itemmanager = System.Item.ItemManager;
	bags.ReturnCount = 0;
	local _, bag;
	for _,bag in ipairs(bags) do
		itemmanager.GetItemsInBag( bag, "ariesitems_" .. bag, function(msg)
			bags.ReturnCount = bags.ReturnCount + 1;
			-- when all bags are fetched.
			if( bags.ReturnCount >= #bags)then
				if(msg and msg.items)then
					local count = 0;
					local __,bag;

					for __,bag in ipairs(bags) do
						local i;

						for i = 1, itemmanager.GetItemCountInBag(bag) do
							local item = itemmanager.GetItemByBagAndOrder(bag, i);
							--commonlib.echo(item);
							if( item ~= nil )then
								CombatCollectableSubPage.items[count+ i] = { guid=item.guid,gsid=item.gsid};
							end
						end

						count = count + itemmanager.GetItemCountInBag(bag);
					end

					-- create dummy items, so that it is multiple is 3row*4col=12 cells
					local displaycount = math.ceil(count / 12) * 12;

					if(count == 0 )then
						displaycount = 12;
					end

					local i;
					for i = count + 1, displaycount do
						CombatCollectableSubPage.items[i] = { guid = 0 };
					end

					CombatCollectableSubPage.items.Count = count;
				end

				local tmp = CombatCollectableSubPage.curpage;
				local item,gsItem;
				local class,subclass;
				CombatCollectableSubPage.showitems = {Count = 0};
				for _, item in ipairs(CombatCollectableSubPage.items) do
					if(item.guid~=0)then
						gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(tonumber(item.gsid));
						if(gsItem) then
							class = tonumber(gsItem.template.class);
							subclass = tonumber(gsItem.template.subclass);
						
							if( ( tmp == 1) or
								( tmp == 2 and class == 3 and ( subclass == 5 or subclass == 9 or subclass==10 )) or
								( tmp == 3 and class == 3 and  ( subclass == 6 or subclass == 7 ) ) or
								( tmp == 4 and class == 3 and subclass == 8) or
								( tmp == 5 and class == 3 and (subclass == 1 or subclass == 2 or subclass == 3 or subclass == 4 or subclass == 20)) or
								( tmp == 5 and class == 4 and subclass == 1) or
								( tmp == 6 and class == 3 and subclass == 11) or
								( tmp == 6 and class == 101) 
								 )then
								 if(gsItem.template.stats[76] ~= 1) then
									if( class == 3 and subclass == 9 )then
										table.insert(CombatCollectableSubPage.showitems, 1, item);
								
									else
										table.insert(CombatCollectableSubPage.showitems,item);
									end
									CombatCollectableSubPage.showitems.Count = CombatCollectableSubPage.showitems.Count + 1;
								 end
								 --if( class == 3 and subclass == 9 )then
									--table.insert(CombatCollectableSubPage.showitems, 1, item);
								--
								 --else
									--table.insert(CombatCollectableSubPage.showitems,item);
								 --end
								--CombatCollectableSubPage.showitems.Count = CombatCollectableSubPage.showitems.Count + 1;
							end
						end
					end
				end

				CombatCollectableSubPage.items.status = 2;
				if(page) then
					page:Refresh(0.01);
				end
				if(call_back) then
					call_back(bIsImmediateResult == nil);
				end
				bIsImmediateResult = true;
			end
		end, "access plus 5 minutes" );
	end
	if(bIsImmediateResult == nil) then
		bIsImmediateResult = false;
	end
	return bIsImmediateResult;
end

--function CombatCollectableSubPage

function CombatCollectableSubPage.GetPage()
	return CombatCollectableSubPage.curpage;
end

-- filter data for current sub category
function CombatCollectableSubPage.Filter()
	local tmp = CombatCollectableSubPage.curpage;
	local _, item,gsItem;
	local class,subclass;
	
	CombatCollectableSubPage.showitems = {Count = 0};
	for _, item in ipairs(CombatCollectableSubPage.items) do
		if(item.guid~=0)then
			gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(tonumber(item.gsid));
			if(gsItem) then
				class = tonumber(gsItem.template.class);
				subclass = tonumber(gsItem.template.subclass);
				if( ( tmp == 1) or
					( tmp == 2 and class == 3 and ( subclass == 5 or subclass == 9 or subclass==10  )) or
					( tmp == 3 and class == 3 and ( subclass == 6 or subclass == 7 ) ) or
					( tmp == 4 and class == 3 and subclass == 8) or
					( tmp == 5 and class == 3 and subclass == 1) or
					( tmp == 5 and class == 3 and subclass == 2) or
					( tmp == 5 and class == 3 and subclass == 3) or
					( tmp == 5 and class == 3 and subclass == 4) or
					( tmp == 5 and class == 4 and subclass == 1) or
					( tmp == 6 and class == 3 and subclass == 11) or
					( tmp == 6 and class == 101) 
					 )then

					if( class == 3 and subclass == 9 )then
						table.insert(CombatCollectableSubPage.showitems, 1, item);
								
					else
						table.insert(CombatCollectableSubPage.showitems,item);
					end
					CombatCollectableSubPage.showitems.Count = CombatCollectableSubPage.showitems.Count + 1;
				end
			end
		end
	end
end


-- get the current bag size
function CombatCollectableSubPage.GetBagSize()
	if(CombatCollectableSubPage.items)then
		return CombatCollectableSubPage.items.Count or 0;
	end
	return 0;
end

-- Get bage size string
function CombatCollectableSubPage.GetBagSizeString()
	return format("%d/%d", CombatCollectableSubPage.GetBagSize(), Player.GetMaxBagSize());
end

-- Get bage size string
function CombatCollectableSubPage.GetBagSizeTooltip()
	if(CombatCollectableSubPage.GetBagSize()>Player.GetMaxBagSize())then
		return "物品总数/背包容量(魔法星可以翻倍)";
	else
		return "物品总数/背包容量(魔法星可以翻倍)";
	end
end

-- ds function of the current selected sub category
function CombatCollectableSubPage.DS_Func(index)
	local size = 0;
	local self = CombatCollectableSubPage
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