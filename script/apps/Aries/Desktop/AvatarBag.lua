--[[
Title: code behind for AvatarBag
Author(s): WD, refactored by LiXizhi 2012.6.17
Date: 2011/11/24
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/AvatarBag.lua");
local AvatarBag = commonlib.gettable("MyCompany.Aries.Desktop.AvatarBag");
AvatarBag:Init();
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/TooltipHelper.lua");
local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");
local ItemManager = Map3DSystem.Item.ItemManager;
local GetItemByID = ItemManager.GetGlobalStoreItemInMemory;
local GetItemsCount = ItemManager.GetItemCountInBag;
local hasGSItem = ItemManager.IfOwnGSItem;
local GetItemsInBag = ItemManager.GetItemsInBag;
local GetItemByBagAndOrder = ItemManager.GetItemByBagAndOrder;

local echo = commonlib.echo;
local table_insert = table.insert;
local table_remove = table.remove;
local AvatarBag = commonlib.gettable("MyCompany.Aries.Desktop.AvatarBag");

AvatarBag.bags_family = nil;
AvatarBag.DisplayItems = {};
AvatarBag.ItemNameTable = {};
AvatarBag.Items_Count = 0;
AvatarBag.PageSize = 12;
AvatarBag.Items = AvatarBag.Items or {};
AvatarBag.slots = AvatarBag.slots or 1;
AvatarBag.ParentTable = {name = "",parent};
AvatarBag.IsDialogMode = AvatarBag.IsDialogMode or false;

function AvatarBag:Init()
	self.page = document.GetPageCtrl();
	self.bags_family = self.bags_family or System.options.tradable_bag_family;
end

function AvatarBag:Show(name,parent,slots, show_only_tradable)
	if(name == "ItemsConsignment") then
		AvatarBag.bags_family = System.options.auction_bag_family or System.options.tradable_bag_family or AvatarBag.bags_family;
	else
		AvatarBag.bags_family = System.options.tradable_bag_family or AvatarBag.bags_family;
	end

	self.show_only_tradable = show_only_tradable;
	if(name and self.ParentTable.parent ~= parent)then
		self.ParentTable.name = name;	
		self.ParentTable.parent = parent;
		self.slots = slots;
	end

	if(not self.Visible)then
		self.Visible = true;
		self:GetItemsByFilter();
		self:FilterItems();
	end
	self:Parent():Refresh();
end

-- obsoleted function:
function AvatarBag.ShowPage(name,parent,slots)
	AvatarBag.IsDialogMode = true;
	local width,height = 422,416;
	local self = AvatarBag

	if(name and self.ParentTable.parent ~= parent)then
		self.ParentTable.name = name;	
		self.ParentTable.parent = parent;
		self.slots = slots;
	end

	local params = {
		url = "script/apps/Aries/Desktop/AvatarBag.kids.html", 
		app_key = MyCompany.Aries.app.app_key, 
		name = "AvatarBag.ShowPage", 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		style = CommonCtrl.WindowFrame.ContainerStyle,
		enable_esc_key = true,
		allowDrag = false,
		isTopLevel = true,
		directPosition = true,
		align = "_ct",
		x = -width * .5,
		y = -height * 0.5,
		width = width,
		height = height,}

		System.App.Commands.Call("File.MCMLWindowFrame", params);

	if(params._page)then
		params._page.OnClose = AvatarBag.Clean;
	end
	AvatarBag:Update(function() self:FilterItems();self:Refresh();end)
end

-- obsoleted function. 
function AvatarBag.CloseWindow()
	if(AvatarBag.page)then
		AvatarBag.page:CloseWindow();
	end
end

function AvatarBag.Hide()
	AvatarBag.Visible = false;
	AvatarBag:Parent():Refresh();
end

function AvatarBag.Clean()
	AvatarBag.Visible = false;
	
	if(not AvatarBag.IsDialogMode)then
		AvatarBag.ResetStates()
	end
	AvatarBag.IsDialogMode = false;
end

function AvatarBag.ResetStates()
	AvatarBag.Items = {};
end 

function AvatarBag:Parent()
	if(self.ParentTable.parent)then
		return self.ParentTable.parent;
	end
end
--是否是绑定物品
function AvatarBag:CheckBinding(gsid)
	NPL.load("(gl)script/apps/Aries/Desktop/GenericTooltip.lua");
    local GenericTooltip = self.GenericTooltip;
	if(not GenericTooltip)then
		GenericTooltip = CommonCtrl.GenericTooltip:new();
	end
	self.GenericTooltip = GenericTooltip;
	return self.GenericTooltip:CheckBinding(gsid);
end
function AvatarBag:GetItemsByFilter(callback)
	self.DisplayItems = {};
	local _,bagid;

	local show_only_tradable = self.show_only_tradable;

	for _,bagid in ipairs(self.bags_family) do
		GetItemsInBag(bagid,"hold items",function(msg) 
			if(msg and msg.items) then
				local _index;
				local _count = GetItemsCount(bagid);

				for _index = 1,_count do
					local _item = GetItemByBagAndOrder(bagid,_index);
					local _goods = GetItemByID(_item.gsid);	
					
					--是否是绑定物品
					local is_binding = self:CheckBinding(_item.gsid);
					if(not is_binding and _item and _goods and (not _item.guid or _item.guid >= -1) )then
						--local qty = _goods.template.stats[221] or -1
						local copies = _item.copies or 1;
						local name = _goods.template.name;
						name = name or "unknown name";
						local cangift=_goods.template.cangift;
						local canexchange = _goods.template.canexchange;
						local has_socketed = false;
						if(not show_only_tradable or (cangift and canexchange)) then
							--如果镶嵌有宝石 不能交易
							if(_item.GetSocketedGems)then
								local gems = _item:GetSocketedGems() or {};
								local len = #gems;
								if(len > 0)then
									has_socketed = true;
								end
							end
							if(_item.GetAddonLevel and _item:GetAddonLevel()>0)then
								has_socketed = true;
							end

							if(_item.IsUsed and _item:IsUsed()) then
								has_socketed = true;
							end
							
							if((_goods.template.bagfamily ~= 0 and _item.gsid ~= 10000) or (_item.gsid == 998 and _goods.template.bagfamily == 0))then
								if(has_socketed)then
									table_insert(self.DisplayItems,{gsid = _item.gsid,guid=_item.guid,copies = copies,has_socketed = true,});
								else
									if(canexchange and cangift)then
										table_insert(self.DisplayItems,1,{gsid = _item.gsid,guid=_item.guid,copies = copies,cangift=true,canexchange = true,has_socketed = false});
									else
										table_insert(self.DisplayItems,{gsid = _item.gsid,guid=_item.guid,copies = copies,cangift=false,canexchange = false,has_socketed = false});
									end
								end
							end

							if(not AvatarBag.ItemNameTable[_item.gsid])then
								AvatarBag.ItemNameTable[_item.gsid] = name;
							end
						end
					end
				end
			end
		end,"");
	end

	if(callback and type(callback) == "function") then
		callback();
	end
end

function AvatarBag:Refresh(delta)
	self.page:Refresh(delta or 0.1);
end

function AvatarBag:CanSell(gsid)
	local i,v,b
	for i,v in ipairs(self.DisplayItems)do
		if(v.gsid == gsid)then
			if(v.cangift and  v.canexchange)then
				b= 0;
			end
			break;
		end
	end
	return b;
end

function AvatarBag:ContainItem(gsid)
	return self:ContainItemByGsid(gsid)
end

function AvatarBag:ContainItemByGsid(gsid)
	local i,v
	for i,v in ipairs(self.Items)do
		if(v.gsid == gsid)then
			return true,i;
		end
	end	
	return false;
end

-- @param arg:pass gsid
function AvatarBag:getItemName(arg)
	return AvatarBag.ItemNameTable[arg];
end

--[[
@param arg:pass gsid
]]
function AvatarBag:GetItemsCountById(arg)
	local i,v;
	local count = 1;
	for i,v in ipairs(self.DisplayItems) do
		if(v.gsid == arg )then
			count = (v.copies or 1);
			break;
		end
	end
	return count;
end

--[[
@param arg:pass gsid
]]
function AvatarBag:RemoveItem(arg,callback)
	local hold,idx = self:ContainItemByGsid(arg);
	if(hold)then
		if(#self.Items == 1)then
		self.Items = {};
		else
		table_remove(self.Items,idx);
		end
	end

	if(callback)then
		callback();
	else
		if(self.ParentTable.parent) then
		self:Update(
		function() 
			self:FilterItems();
			self:Parent():Refresh(); 
		end);
		end
	end
end

-- @param gsid:pass gsid
function AvatarBag:getGuid(gsid)
	local has,guid,bag,copies = hasGSItem(gsid)
	return guid or -999;
end

-- @param arg:pass guid
function AvatarBag:getGSid(guid)
	local i,v,gsid
	for i,v in ipairs(self.DisplayItems)do
		if(v.guid == guid)then
			gsid = v.gsid;
			break
		end
	end
	return gsid;
end

--[[
	note:if item type is slot,id ref to guid,else is gsid
--]]
function AvatarBag:OnClickItem(arg,copies)
	if(not arg) then return end

	if(#self.Items <= self.slots)then
		local hold,idx = self:ContainItemByGsid(arg);
		local gsid  = arg;--self:getGSid(arg);
		local guid = self:getGuid(arg)
		--local name = self:getItemName(arg);

		if(AvatarBag.ParentTable.name =="Mail")then
			if(hold)then
				self.Items[idx].copies =self.Items[idx].copies + (copies or 1); 
			else
				table_insert(self.Items,{guid =  guid,gsid = gsid,copies = (copies or 1)});
			end
		elseif(AvatarBag.ParentTable.name =="ItemsConsignment")then
			--idx = 1;
			if(hold)then
				self.Items[1].copies =self.Items[1].copies + (copies or 1); 
			else
				self.Items[1] = {gsid = gsid,guid = guid,copies = (copies or 1)}; 	
			end
		end
	end
	
	if(self.ParentTable.parent) then
		self:Update(function() 
			self:FilterItems();
			self:Parent():Refresh();
			
			if(AvatarBag.IsDialogMode)then
				AvatarBag:Refresh();
			end
		end);
	end
end

function AvatarBag.IsVisible()
	if(AvatarBag.page and AvatarBag.Visible) then
		return true;
	end
end

-- after update data,then refresh page
function AvatarBag:Update(refresh_cb)
	self:GetItemsByFilter(refresh_cb or function() self:Refresh(); end);
end

function AvatarBag:FilterItems()
	local i,v,i2,v2
	for i2,v2 in ipairs(self.Items)do
		for i,v  in ipairs(self.DisplayItems )do
			if(v.guid == v2.guid or v.gsid == v2.gsid)then
				if(not v.copies)then
					table_remove(self.DisplayItems,i)
				end

				if(v.copies > 0)then
					v.copies = v.copies - v2.copies;
				end
				if(v.copies == 0)then
					table_remove(self.DisplayItems,i)
				end
			end
		end
		
	end

	if(self:Parent().filter == 1)then
		local items = self:Parent().DisplayItems
		for i2,v2 in ipairs(items)do
			for i,v  in ipairs(self.DisplayItems )do
			if(v.guid == v2.guid or v.gsid == v2.gsid)then
				if(not v.copies)then
					table_remove(self.DisplayItems,i)
				end

				if(v.copies > 0)then
					v.copies = v.copies - v2.copies;
				end
				if(v.copies == 0)then
					table_remove(self.DisplayItems,i)
				end
			end
		end	
		end
	end
end

function AvatarBag:GetDataSource(index)
	self.Items_Count = 0;
	if(self.DisplayItems)then
		self.Items_Count = #self.DisplayItems;
	end
	local displaycount = math.ceil(self.Items_Count / self.PageSize) * self.PageSize;
	if(displaycount == 0)then
		displaycount = self.PageSize;
	end

	local i;
	for i = self.Items_Count + 1,displaycount do
		self.DisplayItems[i] = { gsid = -999,guid = -999,canexchange = false,cangift = false, };
	end

	if(index == nil) then
		return #(self.DisplayItems);
	else
		return self.DisplayItems[index];
	end
end