--[[
Title: code behind for Avatar_equipment_subpage
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
local getItemByGuid = ItemManager.GetItemByGUID;
local table_insert = table.insert;
local table_remove = table.remove;
local MSG = _guihelper.MessageBox;
if(System.options.version =="kids" or not System.options.version or System.options.version == "")then
	NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/Avatar_equip_exchange.kids.lua");
elseif(System.options.version == "teen")then
	NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/Avatar_equip_exchange.lua");
end

local Avatar_gems_tesselate = commonlib.gettable("MyCompany.Aries.NPCs.ShoppingZone.Avatar_gems_tesselate");
local Avatar_gems_subpage = commonlib.gettable("MyCompany.Aries.NPCs.ShoppingZone.Avatar_gems_subpage");
local Avatar_equip_exchange =commonlib.gettable("MyCompany.Aries.NPCs.ShoppingZone.Avatar_equip_exchange");
local addonlevel = commonlib.gettable("MyCompany.Aries.Items.addonlevel");
local Avatar_equipment_subpage = commonlib.gettable("MyCompany.Aries.NPCs.ShoppingZone.Avatar_equipment_subpage");
local echo = commonlib.echo;
Avatar_equipment_subpage._DEBUG = Avatar_equipment_subpage._DEBUG or 0;
function Avatar_equipment_subpage:LOG(caption,obj)
	if(self._DEBUG)then
		echo(caption);
		echo(obj);
	end
end
--魔典:范围[17233,17248]
local EXCLUDE_EQUIPS = {min = 17233,max = 17248};

Avatar_equipment_subpage.DEFAULT_EQUIP_FILTER = {
	BAG_FURNISHINGS_ID = 1,
	SUB_TYPE = {{2,5,6,7,8,9,10,11,12,14,15,16,17,18,19,70,71},
				{2,5,6,7,8,9,12,18,19,70,71},
				{14,15,16,17},
				{10,11}}
};

Avatar_equipment_subpage.FURNISHINGS_FILTER = Avatar_equipment_subpage.FURNISHINGS_FILTER or Avatar_equipment_subpage.DEFAULT_EQUIP_FILTER;

--[[equip slots 
	默认的配置应该是一下数值
	装备、武器
	level	总孔数	已开孔数	可打孔数 消耗打孔石
	0~9		2		1		1		1			
	10~19	2		1		1		1
	20~29	3		2		1		1	
	30~39	4		3		1		1
	40~49	5		4		1		1
	50~59	6		5		1		1
	]]

	--[[
		@return:max_cnt,usable_slots,unusable_slots,cost
	]]
	local function OnRangeBetween1(gsItem, lvl, holecnt)
		-- 36 Item_Socket_Count(CS) 装备可镶嵌槽的数量 只能从0变为一个数值 不能改 
		-- 67 Item_CanCreateGemHole_Count(CS) 装备可开槽的数量 只能从0变为一个数值 不能改  
		-- 68 Cost_CraftSlotCharm_Count(CS) 装备镶嵌宝石消耗打孔石的数量 只能从0变为一个数值 不能改  
		if(gsItem) then
			local stat_36 = gsItem.template.stats[36] or 0;
			local stat_67 = gsItem.template.stats[67] or 0;
			local stat_68 = gsItem.template.stats[68] or 0;
			return (stat_36 + stat_67), (stat_36 + holecnt), (stat_67 - holecnt), stat_68;
		else
			return 0,0,0,0;
		end
		--if(lvl >= 0 and lvl <= 9)then 
			--return 1,1,0,0
		--elseif(lvl >= 10 and lvl <= 19)then 
			--return 2,1 + holecnt,2-(1+holecnt),1
		--elseif(lvl >= 20 and lvl <= 29)then 
			--return 3,2 + holecnt,3-(2+holecnt),1
		--elseif(lvl >= 30 and lvl <= 39)then 
			--return 4,3 + holecnt,4-(3+holecnt),1
		--elseif(lvl >= 40 and lvl <= 49)then 
			--return 5,4+holecnt,5-(4+holecnt),1
		--elseif(lvl >= 50 and lvl <= 59)then 
			--return 6,5+holecnt,6-(5+holecnt),1
		--end
	end

--[[equip slots 
	默认的配置应该是一下数值
饰品level	总孔数	已开孔数	可打孔数 消耗打孔石
	0~9		2		1		1		1
	10~19	2		1		1		1
	20~29	2		1		1		1
	30~39	2		1		1		1
	40~49	3		2		1		1
	50~59	3		2		1		1
	]]
	local function OnRangeBetween2(gsItem, lvl, holecnt)
		-- 36 Item_Socket_Count(CS) 装备可镶嵌槽的数量 只能从0变为一个数值 不能改 
		-- 67 Item_CanCreateGemHole_Count(CS) 装备可开槽的数量 只能从0变为一个数值 不能改  
		-- 68 Cost_CraftSlotCharm_Count(CS) 装备镶嵌宝石消耗打孔石的数量 只能从0变为一个数值 不能改  
		if(gsItem) then
			local stat_36 = gsItem.template.stats[36] or 0;
			local stat_67 = gsItem.template.stats[67] or 0;
			local stat_68 = gsItem.template.stats[68] or 0;
			return (stat_36 + stat_67), (stat_36 + holecnt), (stat_67 - holecnt), stat_68;
		else
			return 0,0,0,0;
		end
		--if(lvl >= 0 and lvl <= 9)then 
			--return 1,1,0,0
		--elseif(lvl >= 10 and lvl <= 19)then 
			--return 1,1,0,0
		--elseif(lvl >= 20 and lvl <= 29)then 
			--return 2,1 + holecnt,2-(1+holecnt),1
		--elseif(lvl >= 30 and lvl <= 39)then 
			--return 2,1+holecnt,2-(1+holecnt),1
		--elseif(lvl >= 40 and lvl <= 49)then 
			--return 3,2+holecnt,3-(2+holecnt),1
		--elseif(lvl >= 50 and lvl <= 59)then 
			--return 3,2+holecnt,3-(2+holecnt),1
		--end
	end

	Avatar_equipment_subpage.EQUIP_SLOTS = {
		others = { 
			func_isbetween = OnRangeBetween1,
			},
		acces = {
			func_isbetween = OnRangeBetween2,
		},
	};

--the default is one,means display all
Avatar_equipment_subpage.filter = Avatar_equipment_subpage.filter or 1;
Avatar_equipment_subpage.DisplayItems = {};
Avatar_equipment_subpage.Items = {};
Avatar_equipment_subpage.ParentTable = {name = "",parent = {},};
Avatar_equipment_subpage.IncomingEquip = {gsid = -999,guid =-999,level = 0,name = "",
										qty = 0,typ = "",holdSlots = 0,gemsCount = 0,
										holdGems = {},totalSlots = 0,subclass = 0,};

function Avatar_equipment_subpage:Init()
	self.page = document.GetPageCtrl();
end

function Avatar_equipment_subpage._IsExcludeEquip(gsid)
	if(gsid and gsid >= EXCLUDE_EQUIPS.min and gsid <= EXCLUDE_EQUIPS.max)then 
		echo("exclude equip:" .. gsid);
		return true;
	else 
		return false;
	end
end

function Avatar_equipment_subpage:_RetrieveEquips(iBag)
	local _index;
	local _count = GetItemsCount(iBag);
			
	for _index = 1,_count do
		local _item = GetItemByBagAndOrder(iBag,_index);
			
		if(_item ~= nil) then
			local holecnt = 0;
			local holdgems = {};
			local holdcnt = 0;

			if(_item.PrepareSocketedGemsIfNot) then
				_item:PrepareSocketedGemsIfNot();
				holecnt = _item:GetHoleCount();
						
				local _holdgems = _item:GetSocketedGems();
				if(_holdgems) then
					local i,v;
					for i,v in ipairs(_holdgems) do
						local gem = GetItemByID(v);
						holdgems[#holdgems + 1] = {gsid = v,name = gem.template.name,level = gem.template.stats[41] or 0};
					end
				end
			end

			local _igsid = tonumber(_item.gsid);
			local _goods = GetItemByID(_igsid);				
			local gsid,name,level,qty,typ,maxcnt,equip_lvl;		
			
			if(not Avatar_equipment_subpage._IsExcludeEquip(_igsid))then
			if(_goods ~= nil) then
				qty = _goods.template.stats[221] or -1;--装备品质
				equip_lvl = _goods.template.stats[138] or _goods.template.stats[168];
				typ = self:GetEquipTyp(_goods.template.class,_goods.template.subclass) or "unknown";
				maxcnt,holdcnt = self:GetSlotsInfo(_goods, equip_lvl, typ, holecnt);

				local slots_count = _goods.template.stats[36] or 0;
				--commonlib.echo(_goods);
				--commonlib.echo("gsid:" .. _goods.gsid .. ",name:" .. _goods.template.name .. ",holecnt:" .. holecnt);
				local equip = {
							gsid = _goods.gsid,
							guid = _item.guid,
							name = _goods.template.name,
							holecnt = holecnt or 0,--仅仅是玩家打过的孔数目
							holdcnt = holdcnt or 0,--所有可用的孔，包含holecnt 和 预先开的孔如(防具)
							level = _goods.template.stats[138] or 1,
							qty = qty,
							typ = typ,
							maxcnt = maxcnt or 0,--所有孔数目
							holdgems = holdgems or {},
							subclass = _goods.template.subclass or 0,
						};

						
				local subtype = Avatar_equipment_subpage.FURNISHINGS_FILTER.SUB_TYPE[self.filter or 1];
				local  item2 = getItemByGuid(equip.guid);

				local i,v;
				if(subtype) then
					for i,v in ipairs(subtype) do
						if(	equip.subclass == v and self.ParentTable.name == "GemTessel"  and qty > 0) then
							local i,v,tessel;
							if(equip.holdcnt > #equip.holdgems)then tessel = 0;end
							for i,v in ipairs(holdgems)do
								if(v.level < 5)then tessel = 0; break; end
							end
							if(#holdgems == 0)then tessel = 0;end
							if(tessel)then
								table_insert(self.DisplayItems,equip); 
							end
							break;
						elseif(equip.subclass == v and self.ParentTable.name == "EquipUpgrade" and 
							addonlevel and addonlevel.can_have_addon_property)then
							--local from_level = 0		 
							--if(item2 and item2.GetAddonLevel)then
								--from_level = item2:GetAddonLevel()
							--end
							--local max_level = addonlevel.get_max_addon_level(equip.gsid) or 0
							local has = addonlevel.can_have_addon_property(equip.gsid)
							local from_level = 0
							if(_item.GetAddonLevel)then
								from_level = _item:GetAddonLevel() or 0
							end
							local get_max_addon_level = addonlevel.get_max_addon_level(equip.gsid) or -1;
							if(has and from_level < get_max_addon_level)then
								table_insert(self.DisplayItems,equip); 
							end
							break;
						elseif(equip.subclass == v and (self.ParentTable.name == "EquipSlotting" or 
								self.ParentTable.name == "GemRetrieve") and equip.maxcnt > 0  and qty > 0)then
							table_insert(self.DisplayItems,equip); 
							break;
						elseif(equip.subclass == v and self.ParentTable.name ~= "GemTessel" and 
								self.ParentTable.name ~= "EquipSlotting" and 
								self.ParentTable.name ~= "GemRetrieve" and 
								self.ParentTable.name ~= "EquipUpgrade")then
							if(self.ParentTable.name == "EquipExchange")then
								local isexchangeable = Avatar_equip_exchange:IsExchangableEquip(equip.gsid)
								if(Avatar_equip_exchange.SetHighEquipTable)then
									Avatar_equip_exchange:SetHighEquipTable(equip.gsid);
								end
										
								if(isexchangeable)then
									table_insert(self.DisplayItems,equip); 
								end
							else
								table_insert(self.DisplayItems,equip); 
							end
									
							break;
						end
					end
				end
				
				table_insert(self.Items,equip);

			end
			end
		end
	end

	self:LOG("self.DisplayItems",self.DisplayItems);
	self:LOG("self.Items",self.Items);
end

function Avatar_equipment_subpage:GetItemsByFilter(callback)
	self.filter  = self.filter or 1;
	self.DisplayItems = {};
	self.Items = {};
	self.FURNISHINGS_FILTER = self.FURNISHINGS_FILTER or Avatar_equipment_subpage.DEFAULT_EQUIP_FILTER;

	local iBag = self.FURNISHINGS_FILTER.BAG_FURNISHINGS_ID;
	if(type(iBag) == "number")then
		GetItemsInBag(iBag,"furnishings of self",function(msg) 
			if(msg and msg.items) then
				Avatar_equipment_subpage:_RetrieveEquips(iBag);
				if(callback and type(callback) == "function") then
					callback();
				end
			end
		end,"access plus 5 seconds");		
	elseif(type(iBag) == "table")then
		local i,v
		local size = #iBag;
		for i,v in ipairs(iBag)do
			GetItemsInBag(v,"furnishings of self",function(msg) 
				if(msg and msg.items) then
					Avatar_equipment_subpage:_RetrieveEquips(v);
					if(callback and type(callback) == "function" and i == size) then
						callback();
					end
				end
			end,"access plus 5 seconds");	
		end
	end
end

--[[
	check whether contains one equip,if contain return true.
	@param gsid:a number value type.
]]
function Avatar_equipment_subpage:ContainsEquip(gsid)
	local i,v,find;
	for i,v in ipairs(self.Items)do
		if(v.gsid == gsid)then
			find = true;
			break;
		end
	end
	return find;
end

--[[
	refresh master page
]]
function Avatar_equipment_subpage:Refresh(delta)
	if(self.page)then
		self.page:GetRootPage():Refresh(delta or 0.1);
		--self.page:Refresh(delta or 0.1);
	end
end

function Avatar_equipment_subpage:IsEmpty()
	if(#self.Items == 0) then
		return true;
	end
	return false;
end

function Avatar_equipment_subpage:GetEquipTyp(class,subclass)
	if(class ~= 1)then return end
	
	local SUB_TYPE = Avatar_equipment_subpage.DEFAULT_EQUIP_FILTER.SUB_TYPE;
	if(not SUB_TYPE) then return; end

	local i,v,j,k;
	for i,v in ipairs(SUB_TYPE) do
		--if index equal to 1,skip all equip lookup
		if(i~=1)then
			for j,k in ipairs(SUB_TYPE[i]) do
				if(SUB_TYPE[i][j] == subclass) then
					if(i == 2) then
						return "clothes_shoes";
					elseif(i == 3) then
						return "acces";
					elseif(i == 4) then
						return "weapons";
					end
				end
			end
		end
	end
	return;
end

function Avatar_equipment_subpage:IsEquip(name)
	if(name == "clothes_shoes" or name == "acces" or name == "weapons")then
		return true;
	end
	return false;
end

--[[
	note:if item type is slot,id ref to guid,else is gsid
--]]
function Avatar_equipment_subpage:OnClickItem(arg,notrefresh)
	if(not self.needFilterIncomingEquip and self.IncomingEquip.guid == arg)then
		return;
	end

	if(self.ParentTable.name == "EquipExchange")then
		local goods = getItemByGuid(arg)
		if(goods and goods.gsid)then
			if(Avatar_equip_exchange.HasHighEquip[goods.gsid])then
				MSG("你已经拥有该装备的升级装备。");
				return;
			end
		end
	end
	
	if(Avatar_gems_subpage and Avatar_gems_subpage.ZeroIncomingGem)then
		Avatar_gems_subpage:ZeroIncomingGem();
		if(Avatar_gems_subpage.Update)then
			Avatar_gems_subpage:Update()
		end
	end

	if(self.ParentTable.name == "GemTessel" )then
		Avatar_gems_tesselate.upgradeGem = nil;
		Avatar_gems_tesselate.upgradeGemPos = nil;
	end
	self.IncomingEquip.guid = arg
	self:Update();
end

function Avatar_equipment_subpage.FilterIncomingEquip()
	local i,v
	for i,v in ipairs(Avatar_equipment_subpage.DisplayItems)do
		if(Avatar_equipment_subpage.IncomingEquip.gsid == v.gsid)then
			table.remove(Avatar_equipment_subpage.DisplayItems,i);
			break;
		end
	end
end

--[[
	after update data,then refresh page
--]]
function Avatar_equipment_subpage:Update(refresh_cb)
	self:GetItemsByFilter(refresh_cb or function() 	
	--update incoming equip
	self:SetIncomingEquip();
	if(self.needFilterIncomingEquip)then
		self.FilterIncomingEquip()
	end
	self:Refresh(); end);
end

function Avatar_equipment_subpage:SetIncomingEquip(arg)
	--if(self:IsEmpty()) then
		--return;
	--end

	arg = arg or self.IncomingEquip.guid;
	if(arg == 0) then return; end

	local j,k;
	for j,k in ipairs(self.Items) do
		if(self.Items[j].guid == arg) then
			self.IncomingEquip.gsid = self.Items[j].gsid;
			self.IncomingEquip.guid = self.Items[j].guid;
			self.IncomingEquip.level = self.Items[j].level;
			self.IncomingEquip.qty = self.Items[j].qty;
			self.IncomingEquip.typ = self.Items[j].typ;

			self.IncomingEquip.name = self.Items[j].name;
			self.IncomingEquip.holdSlots = self.Items[j].holdcnt or 0;
			self.IncomingEquip.totalSlots = self.Items[j].maxcnt or 0;
			self.IncomingEquip.holdGems = self.Items[j].holdgems;
			self.IncomingEquip.gemsCount = #self.IncomingEquip.holdGems;
			self.IncomingEquip.subclass = self.Items[j].subclass;

			break;
		end
	end

end

function Avatar_equipment_subpage:FilterItems(name)
	if(self:IsEmpty()) then
		return;
	end

	--assign new filter
	self.filter = tonumber(name or 1);
	self:Update();
end

function Avatar_equipment_subpage:GetDataSource(index)
	local size = 0;

	if(self.DisplayItems)then
		size = #self.DisplayItems;
	end
	local displaycount = math.ceil(size / self.PageSize) * self.PageSize;
	if(displaycount == 0)then
		displaycount = self.PageSize;
	end

	local i;
	for i = size + 1,displaycount do
		self.DisplayItems[i] = { gsid = -999,guid = -999, };
	end

	if(index == nil) then
		return #(self.DisplayItems);
	else
		return self.DisplayItems[index];
	end
end

function Avatar_equipment_subpage:BindParent(name,parent)
	if(not name and type(name) ~= "string")then
		commonlib.echo("must specify parent name for bind.");
		return;
	end

	if(not parent) then
		commonlib.echo("the parent is nil.");
		return;
	end

	self.ParentTable.name = name;

	if(name == "GemTessel")then
		self.PageSize = 14;
	elseif(name == "EquipSlotting" or name == "EquipExchange" or name=="GemRetrieve" or name=="EquipUpgrade")then
		if(System.options.version == "teen")then
			self.PageSize = 40;
		elseif(System.options.version == "kids")then
			self.PageSize = 12;		
		end
	end

	if(name ~= "EquipSlotting")then
		self.needFilterIncomingEquip = true;
	end

	if(self.page == nil) then
		self:LOG("set page ctrl","")
		self.page = parent.page;	
	end
end

--[[
	call by parent window,when window is closed
--]]
function Avatar_equipment_subpage:ResetStates(defaultFilter,callback)
	
	if(defaultFilter) then
		self.filter = 1;
	end
	self:ZeroIncomingEquip();
	self.needFilterIncomingEquip = nil;
	self.ParentTable = {name = "",parent = {},};
	if(callback and type(callback) == "function")then
		callback();
	end
end

function Avatar_equipment_subpage:ZeroIncomingEquip()
	self.IncomingEquip = {gsid = -999,guid = -999,level = 0,name = "",
						qty = 0,typ = "",holdSlots = 0,gemsCount = 0,
						holdGems = {},totalSlots = 0,subclass = 0,};
end

--[[
	defines mount gems type for equip
	called on gems tesselate
--]]
function Avatar_equipment_subpage:SetAllowableGemsType()
	local attack = {1,2,3,4,5,6,7,8,9,10};
	local defense = {11,12,13,14,15,16,17,18,19,20};
	local hit = {21,22,23,24,25,26,27,28,29,30};
	local dodge = {31,32,33,34,35,36,37,38,39,40};
	local critical = {41,42,43,44,45,46,47,48,49,50};
	local tenacity = {51,52,53,54,55,56,57,58,59,60};

	local magic = {61,62,63,64,65,66,67,68,69,70};
	local cure = {71,72,73,74,75,76,77,78,79,80};
	local speed = {81,82,83,84,85,86,87,88,89,90};
	local blood = {91,92,93,94,95,96,97,98,99,100};
	local rift = {101,102,103,104,105,106,107,108,109,110};
	

	self.AllowableGemsTypeTable = {
			clothes_shoes = {
				attack = attack,defense = defense,tenacity = tenacity,
				cure = cure,blood = blood,},
			acces = {
				hit = hit,dodge = dodge,critical = critical,tenacity = tenacity,
				magic = magic,speed = speed,blood = blood,rift = rift,},
			weapons = {
				attack = attack,defense = defense,critical = critical,
				magic = magic,cure = cure,blood = blood,},};
end

--[[
	@param qty:quality of item.
	@param typ:type of item,the type is predefined in this page.
	@return:totalSlots,usableSlots.

function Avatar_equipment_subpage:GetSlotsInfo(qty,typ,holecnt)
	local usable_slots,total_slots = 0,0;
	local holecnt = holecnt or 0;
	
	if(qty >= 1) then
		if(typ == "clothes_shoes") then
			usable_slots = holecnt + 3;
		else
			usable_slots = holecnt;
		end

		if(typ == "clothes_shoes" or typ == "weapons") then
			total_slots = 6;
		else
			total_slots = 3;
		end
	end
	
	return total_slots,usable_slots;
end
--]]

-- @return: total_slots, usable_slots
function Avatar_equipment_subpage:GetSlotsInfo(gsItem, lvl, typ, holecnt)
	lvl = tonumber(lvl) or 0;
	holecnt = tonumber(holecnt) or 0;

	if(typ == "acces") then
		return self.EQUIP_SLOTS[typ].func_isbetween(gsItem, lvl, holecnt)
	elseif(typ) then
		return self.EQUIP_SLOTS["others"].func_isbetween(gsItem, lvl, holecnt)
	end
	return 0,0;
end

--[[
获取消耗的打孔石
]]
function Avatar_equipment_subpage:GetCostRocks(gsItem, lvl, typ)
	local max_cnt,hold_cnt,slot_cnt,cost_rocks = self:GetSlotsInfo(gsItem, lvl, typ, 0);
	return cost_rocks or 0;
end

function Avatar_equipment_subpage:GetIncomingEquipGems()
	return self.IncomingEquip.holdGems;
end