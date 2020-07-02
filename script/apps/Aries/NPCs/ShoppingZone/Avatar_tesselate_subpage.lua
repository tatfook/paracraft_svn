--[[
Title: code behind for Avatar_tesselate_subpage
Author(s): WD
Date: 2011/08/02

use the lib:
------------------------------------------------------------
just as a subpage of avatar equipment
------------------------------------------------------------
--]]

local ItemManager = Map3DSystem.Item.ItemManager;
local GetItemByID = ItemManager.GetGlobalStoreItemInMemory;
local GetItemsCount = ItemManager.GetItemCountInBag;
local GetItemsInBag = ItemManager.GetItemsInBag;
local GetItemByBagAndOrder = ItemManager.GetItemByBagAndOrder;
local MSG = _guihelper.MessageBox;
local table_insert = table.insert;
local PAGE_SIZE = 14;

local Avatar_tesselate_subpage = commonlib.gettable("MyCompany.Aries.NPCs.ShoppingZone.Avatar_tesselate_subpage");

TESSELATE = 
{
	BAG_TESSELATE_ID = 12,
	TESSELATE_SUBCLASS = 7,
	CATEGORY = "SocketingRune",
	--[[
		SELECT_ALL = 1;
		SELECT_LOW_LEVEL = 2;
		SELECT_HIGH_LEVEL = 3;
		SELECT_SUPER_LEVEL = 4;
	--]]
	SUB_TYPE = {
		"所有","低级","高级","顶级"
	}
};

Avatar_tesselate_subpage.filter = Avatar_tesselate_subpage.filter or 1;
Avatar_tesselate_subpage.DisplayItems = {};
Avatar_tesselate_subpage.Items = {};
Avatar_tesselate_subpage.Items_Count = 0;
Avatar_tesselate_subpage.TesselateOdds = Avatar_tesselate_subpage.TesselateOdds or 0;
--a tuple for mount odds
Avatar_tesselate_subpage.TesselateRateCollection = {10,20,30};
Avatar_tesselate_subpage.ParentTable = {name = "",parent = {},};
Avatar_tesselate_subpage.TesselDataTable = Avatar_tesselate_subpage.TesselDataTable or
{
	SelectTesselCount = 0,
	TesselGsids = {},
}

function Avatar_tesselate_subpage:Init()
	self.page = document:GetPageCtrl();
end

function Avatar_tesselate_subpage:Refresh(delta)
	self.page:Refresh(delta or 0.1);
end

function Avatar_tesselate_subpage:GetItemsByFilter(filter,callback)
	self.filter  = filter or 1;
	self.DisplayItems = {};
	self.Items = {};

	GetItemsInBag(TESSELATE.BAG_TESSELATE_ID,"tesselate of self",function(msg) 
		if(msg and msg.items) then
			local _index;
			local _count = GetItemsCount(TESSELATE.BAG_TESSELATE_ID);
			
			for _index = 1,_count do
				local _item = GetItemByBagAndOrder(TESSELATE.BAG_TESSELATE_ID,_index);
				
				if(_item ~= nil) then
					local _igsid = tonumber(_item.gsid);
					
					local _goods = GetItemByID(_igsid);
					if(_goods ~= nil and _goods.category == TESSELATE.CATEGORY and TESSELATE.TESSELATE_SUBCLASS ==_goods.template.subclass) then
						local _item2 = {
									gsid = _goods.gsid,
									copies = _item.copies,
									guid = _item.guid,
									name = _goods.template.name,
								};	
								
						table_insert(self.DisplayItems,_item2);
						table_insert(self.Items,_item2);
					end
				end
			end

			--before update calc copies
			self:CalcTesselCopies();
			if(callback and type(callback) == "function") then
				callback();
			end
		end
	end,"access plus 1 day");
end

--[[
	bind parent table to this.
	@param name:the parent table name.
	@param parent:the parent table.
--]]
function Avatar_tesselate_subpage:BindParent(name,parent)
	if(not name and type(name) ~= "string")then
		commonlib.echo("bind must specify parent name.");
		return;
	end

	if(not parent) then
		commonlib.echo("the parent is nil.");
		return;
	end

	self.ParentTable.name = name;
	self.ParentTable.parent = parent;

	if(name == "GemTessel")then
		self.PageSize = 14;
	end


	if(self.page == nil) then
		self.page = parent.page;	
	end
end

function Avatar_tesselate_subpage:FilterItems(name)
	if(not self:IsEmpty()) then
		self:GetItemsByFilter(1);
		if(not self:IsEmpty()) then
			return;
		end
	end
	local name = tonumber(name);
	self:GetItemsByFilter(name);

	self:Refresh();
end

function Avatar_tesselate_subpage:GetDataSource(index)
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
		self.DisplayItems[i] = { gsid = -999,guid = -999,copies = 0};
	end

	if(index == nil) then
		return #(self.DisplayItems);
	else
		return self.DisplayItems[index];
	end
end

function Avatar_tesselate_subpage:IsEmpty()
	if(#self.Items > 0)  then
		return false;
	else
		return true;
	end
end

function Avatar_tesselate_subpage:OnClickItem(arg,notrefresh)
	if(not arg) then return end
	local _gsid = tonumber(arg);
	
	if (self.TesselDataTable == nil or self.TesselDataTable.SelectTesselCount == 3) then
		return;
	else
		table_insert(self.TesselDataTable.TesselGsids,_gsid);
		self.TesselDataTable.SelectTesselCount = self.TesselDataTable.SelectTesselCount +1;
		table.sort(self.TesselDataTable.TesselGsids);
	end
	
	if(not notrefresh and self.ParentTable.parent) then
		self:Update(
			function() 
				self.ParentTable.parent:Refresh(); 
			end);
	end
end

--[[
	calc tessel copies by gsid
--]]
function Avatar_tesselate_subpage:CalcTesselCopies()
	if(self.TesselDataTable == nil) then 
		return;
	end

	local i,v = 0,0;
	for i,v in ipairs(self.DisplayItems) do
		local _i,_v,_size = 0,0,0;
		for _i,_v in ipairs(self.TesselDataTable.TesselGsids) do
			if(_v == v.gsid) then
				_size = _size +1;
			end
		end
		v.copies = v.copies - _size;
		if(v.copies == 0) then
			table.remove(self.DisplayItems,i);
		end
	end
end

function Avatar_tesselate_subpage:ResetStates()
	self.TesselateOdds = 0;
	self.TesselDataTable = {
	SelectTesselCount = 0,
	TesselGsids = {},};
end

--[[
	after update data,then refresh page,default is refresh self content
--]]
function Avatar_tesselate_subpage:Update(refresh_cb)
	self:GetItemsByFilter(self.filter,refresh_cb or function() self:Refresh(); end);
end