--[[
Title: code behind for Avatar_gems_subpage
Author(s): WD
Date: 2011/08/02

use the lib:
------------------------------------------------------------
just as a subpage of avatar's gems
------------------------------------------------------------
--]]

local Avatar_gems_subpage = commonlib.gettable("MyCompany.Aries.NPCs.ShoppingZone.Avatar_gems_subpage");
NPL.load("(gl)script/ide/TooltipHelper.lua");
local Avatar_equipment_subpage = commonlib.gettable("MyCompany.Aries.NPCs.ShoppingZone.Avatar_equipment_subpage");

local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");
local BAG_COLLECTABLE_ID  = 12;
local SOCKETABLE_GEMS_MIN = 26001;
local SOCKETABLE_GEMS_MAX = 26699;

local ItemManager = Map3DSystem.Item.ItemManager;
local GetItemByID = ItemManager.GetGlobalStoreItemInMemory;
local GetItemsCount = ItemManager.GetItemCountInBag;
local GetItemsInBag = ItemManager.GetItemsInBag;
local GetItemByBagAndOrder = ItemManager.GetItemByBagAndOrder;

local MSG = _guihelper.MessageBox;
local string_sub = string.sub;
local table_insert = table.insert;
local table_remove = table.remove;
local echo = commonlib.echo;

Avatar_gems_subpage._DEBUG = Avatar_gems_subpage._DEBUG or false;
function Avatar_gems_subpage:LOG(caption,obj)
	if(self._DEBUG)then
		echo(caption);
		echo(obj);
	end
end

Avatar_gems_subpage.filter = Avatar_gems_subpage.filter or 0;
Avatar_gems_subpage.Items= {};
Avatar_gems_subpage.ItemsOfSelf= {};
Avatar_gems_subpage.DisplayItems= {};
--build incoming gem hash table
Avatar_gems_subpage.IncomingGem = {gsid = -999,high_level_gsid = -999,guid = -999,name = "",cps = 0,level = 0,copies = 0,typ = 0,odds = 0,};

--the cost unit is calculated for gem refine.
Avatar_gems_subpage.CostQidouUnit = Avatar_gems_subpage.CostQidouUnit or 0;
--the cost unit tuple is calculated for gem refine.
Avatar_gems_subpage.GemCostQidouCollection= {4000,9000,16000,25000};
Avatar_gems_subpage.ParentTable = {name = "",parent = {},};
--mark last incoming gem,just for memory gsid replace it with a new gem
Avatar_gems_subpage.last_incominggem = nil;

function Avatar_gems_subpage:Init()
	self.page = document:GetPageCtrl();
end

function Avatar_gems_subpage:Refresh(delta)
	if(self.page)then
		self.page:GetRootPage():Refresh(delta or 0.1);
	end
end

--[[
	calculate gems item count.
--]]
function Avatar_gems_subpage:CalcGemsCopies()
	if(self.IncomingGem.gsid == -999) then 
		return; 
	end

	local i,v,cps;
	for i,v in ipairs(self.DisplayItems) do
		if(v.gsid == self.IncomingGem.gsid) then
			v.copies = v.copies - self.IncomingGem.copies;
			cps = v.copies;
			if(v.copies == 0) then
				table_remove(self.DisplayItems,i);
			end
			break;
		end
	end
	return cps or 0
end

--[[
	get all gems from bag 
--]]
function Avatar_gems_subpage:GetItemsByFilter(filter,callback)
	self.DisplayItems = {};
	self.ItemsOfSelf = {};

	GetItemsInBag(BAG_COLLECTABLE_ID,"gems of self",function(msg) 
		if(msg and msg.items) then
			local _index;
			local _count = GetItemsCount(BAG_COLLECTABLE_ID);

			for _index = 1,_count do
				local _item = GetItemByBagAndOrder(BAG_COLLECTABLE_ID,_index);

				if(_item ~= nil) then
					local _igsid = tonumber(_item.gsid);
				
					if(self.IsAvaiableGem(_igsid)) then
						local _goods = GetItemByID(_igsid);
						if(_goods ~= nil) then 
						--[[
							--for test view
							local _name = _goods.template.name;
							local _lvl = tonumber(string_sub(_name,1,1));
							local _typ = _goods.template.stats[42] or "unknown";--mount attribute for equip,e.g.attack,defense,or other
							local high_level_gsid = _goods.template.stats[37];
							commonlib.echo("high_level_gsid:" .. high_level_gsid .. "_typ:" .. _typ ..  "," .. "name:" .. _name .. "gsid:" .. _igsid );
							]]
							local _gem = {
									gsid = _igsid,
									high_level_gsid = _goods.template.stats[37] or -999,
									guid = _item.guid,
									copies = _item.copies,
									name = _goods.template.name,
									typ = _goods.template.stats[42] or 0,
									level = _goods.template.stats[41] or 0,
									odds = Avatar_gems_subpage.GemsOdds[_goods.template.stats[41]],
								};

							table_insert(self.ItemsOfSelf,_gem);
							if((self.filter ~= 0 and self.filter ==  _goods.template.stats[41]) or self.filter == 0) then
								table_insert(self.DisplayItems,_gem);
							end
						end
					end
				end
			end

			self:CalcGemsCopies();
			if(callback and type(callback) == "function") then
				callback();
			end
		end
	end,"access plus 5 minutes");
end

function Avatar_gems_subpage:GetAllItems()
	local _igsid,item;
	if(self.GemsCached)then return end

	for _igsid = SOCKETABLE_GEMS_MIN, SOCKETABLE_GEMS_MAX do
		item = GetItemByID(_igsid);
		if(item ~= nil) then
			local _name = item.template.name;
			local _lvl = item.template.stats[138] or item.template.stats[168];--tonumber(string_sub(_name,1,1));
						
			local _gem = {
					gsid = _igsid,
					name = _name,
					level = _lvl,
				};

			table_insert(self.Items,_gem);
		end
	end
	self.GemsCached = 1				
end
--[[
	filter gems by level or not filter
--]]
function Avatar_gems_subpage:FilterItems(name)
	if(#self.ItemsOfSelf == 0) then
		return;
	end

	self.filter = tonumber(name or 0);
	self:Update();
end

--[[
	bind parent table to this.
	@param name:the parent table name.
	@param parent:the parent table.
--]]
function Avatar_gems_subpage:BindParent(name,parent)
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
	elseif(name == "GemMerge")then
		self.PageSize = 56;
	end

	if(self.page == nil) then
		self.page = parent.page;	
	end
end

--[[
	return local datasource of gems
--]]
function Avatar_gems_subpage:GetDataSource(index)
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
		self.DisplayItems[i] = { gsid = -999,guid = -999, copies = 0};
	end

	if(index == nil) then
		return #(self.DisplayItems);
	else
		return self.DisplayItems[index];
	end
end

--[[
	check whether current gsid is avaiable within range between [SOCKETABLE_GEMS_MIN,SOCKETABLE_GEMS_MAX],
	if avaiable true is returned.
--]]
function Avatar_gems_subpage.IsAvaiableGem(id)
	if(id >= SOCKETABLE_GEMS_MIN and id <= SOCKETABLE_GEMS_MAX) then
		return true;
	else
		return false;
	end
end

function Avatar_gems_subpage:_ResetIncomingGem(gsid)
	if(not gsid)then return;end
	local i,v;
	for i,v in ipairs(self.DisplayItems) do
		if(v.gsid == gsid) then
			self.IncomingGem.gsid = gsid;
			self.IncomingGem.high_level_gsid = v.high_level_gsid;
			self.IncomingGem.guid = v.guid;
			self.IncomingGem.typ = v.typ;
			self.IncomingGem.odds = v.odds;
			self.IncomingGem.name = v.name;
			self.IncomingGem.level = v.level;
			self.IncomingGem.cps = v.copies or 0;
			break;
		end
	end
end

function Avatar_gems_subpage:OnClickItem(arg,notrefresh)
	if(not arg) then return end
	--if(self.ParentTable.parent.upgradeGem and self.ParentTable.name == "GemTessel")then
		--MSG("升级宝石操作还未完成。");
		--return 
	--end

	--if current select item is different from previous selection,clear gems counter to zero
	if(arg ~= self.IncomingGem.gsid) then
		self.IncomingGem.copies = 0;
		self.IncomingGem.high_level_gsid  = -999;

		local cost,i,v,index;
		for i,v in ipairs(self.DisplayItems) do
			if(v.gsid == arg) then
				self.IncomingGem.gsid = arg;
				self.IncomingGem.high_level_gsid = v.high_level_gsid;
				self.IncomingGem.guid = v.guid;
				self.IncomingGem.typ = v.typ;
				self.IncomingGem.odds = v.odds;
				self.IncomingGem.name = v.name;
				self.IncomingGem.level = v.level;
				self.IncomingGem.cps = v.copies or 0;
				break;
			end
		end

		if(self.ParentTable.name == "GemMerge") then
			--get unit from unit tuple by gem level rules.
			if(Avatar_gems_subpage.IncomingGem.level == 5) then
				self:ZeroIncomingGem();
				MSG("五级宝石不需要合成哦！");
				--BroadcastHelper.PushLabel({id="_tip", label = "五级宝石不需要合成哦！", max_duration=2000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
				return;
			end
			self.CostQidouUnit = self.GemCostQidouCollection[self.IncomingGem.level];
		end
	end


	--local cps = self:CalcGemsCopies();
	--if incoming gem's copies reached 5,directly return
	if(self.ParentTable.name == "GemMerge" and self.IncomingGem.copies < 5 and (self.IncomingGem.cps - self.IncomingGem.copies)  > 0) then
		self.IncomingGem.copies = self.IncomingGem.copies + 1;
	elseif(self.ParentTable.name == "GemTessel" ) then
		local typTable,k,v,find,k2,v2;
		--[[
		typTable = Avatar_equipment_subpage.AllowableGemsTypeTable[Avatar_equipment_subpage.IncomingEquip.typ];			
			
		if(Avatar_gems_subpage.IncomingGem.typ ~= 0 and typTable) then
			for k,v in pairs(typTable) do
				for k2,v2 in ipairs(v) do
					if(v2 == Avatar_gems_subpage.IncomingGem.typ) then
						find = true;
						break;
					end
				end
			end
		end

		--if current incoming gem's mount attribute is not affect equip,break it.
		if(not find) then
			MSG("当前装备不能镶嵌该宝石！");
			self:ZeroIncomingGem(false);
			return;
		end
		]]

		v = self.ParentTable.parent:CompareEquipedGem(self.IncomingGem.gsid);
		self:LOG("return value:",v);

		if(v)then
			if(v == self.IncomingGem.gsid )then
				self:ZeroIncomingGem(false);
				self:_ResetIncomingGem(self.last_incominggem);
				MSG("你不需要重复镶嵌同样的宝石。");
				return 		
			elseif(v == -1)then
				self:ZeroIncomingGem(false);
				self:_ResetIncomingGem(self.last_incominggem);
				MSG("你不需要镶嵌更低级的宝石。");	
				return	
			elseif(v == 1)then
				--@step2:upgrade 
				local gem = GetItemByID(self.last_incominggem);
				local b; 
				if(gem)then
					if(string.sub(Avatar_gems_subpage.IncomingGem.name,2) == string.sub(gem.template.name,2))then
						b = 0;
					end
				end
				if(not b)then
					--_guihelper.MessageBox(string.format("你需要升级宝石【%s】到【%s】吗？",string.format("%s%s",Avatar_gems_subpage.IncomingGem.level - 1,string.sub(Avatar_gems_subpage.IncomingGem.name,2)),Avatar_gems_subpage.IncomingGem.name),function(res) 
						--if(res and res == _guihelper.DialogResult.OK) then
							--replace old gem with new
							self:LOG("Avatar_equipment_subpage.IncomingEquip.holdGems",Avatar_equipment_subpage.IncomingEquip.holdGems);
							local hold_gems = Avatar_equipment_subpage.IncomingEquip.holdGems
							local i,v
							if(self.last_incominggem and self.last_incominggem ~= Avatar_gems_subpage.IncomingGem.gsid)then
								local idx,size = 1,#hold_gems
								for idx = 1,size do
									if(hold_gems[idx].gsid == self.last_incominggem)then
										table.remove(hold_gems,idx);break;
									end
								end
							end

							for i,v in ipairs(hold_gems)do
								if(v.name == string.format("%s%s",Avatar_gems_subpage.IncomingGem.level - 1,string.sub(Avatar_gems_subpage.IncomingGem.name,2)))then
									--table.remove(Avatar_equipment_subpage.IncomingEquip.holdGems,i);
									hold_gems[i].gsid = Avatar_gems_subpage.IncomingGem.gsid;
									hold_gems[i].level = Avatar_gems_subpage.IncomingGem.level;
									hold_gems[i].name = Avatar_gems_subpage.IncomingGem.name;
									self.ParentTable.parent.upgradeGemPos = i;
									break;
								end
							end
							

							self.ParentTable.parent.upgradeGem = Avatar_gems_subpage.IncomingGem.gsid
							self.last_incominggem = Avatar_gems_subpage.IncomingGem.gsid;
							
							self:LOG("Avatar_equipment_subpage.IncomingEquip.holdGems",Avatar_equipment_subpage.IncomingEquip.holdGems);
							--Avatar_gems_subpage:SetField("upgradeGem",Avatar_gems_subpage.IncomingGem.gsid)
							self:Update();
						--end
					--end);
					return;
				end
			elseif(v == 1)then
				self:ZeroIncomingGem(false);
				self:_ResetIncomingGem(self.last_incominggem);
				MSG("你需要镶嵌更低级的宝石，才能镶嵌高等级宝石。");	
				return					
			elseif(v == 0)then
				self:ZeroIncomingGem(false);
				self:_ResetIncomingGem(self.last_incominggem);
				MSG("你需要镶嵌更低级的宝石，才能镶嵌高等级宝石。");	
				return	
			end
		else
			MSG("不能镶嵌该宝石，没有开孔或者没有可用孔位了。")
			return;
		end

		if(self.IncomingGem.level > 1)then
			self:ZeroIncomingGem(false);
			self:_ResetIncomingGem(self.last_incominggem);
			MSG("你需要镶嵌更低级的宝石，才能镶嵌高等级宝石。");	
			return
		end

		local hold_gems = Avatar_equipment_subpage.IncomingEquip.holdGems

		if(hold_gems)then
			if(self.last_incominggem and self.last_incominggem ~= Avatar_gems_subpage.IncomingGem.gsid)then
				local i,size = 1,#hold_gems
				for i = 1,size do
					if(hold_gems[i].gsid == self.last_incominggem)then
						table.remove(hold_gems,i);break;
					end
				end
			end

			if(#hold_gems < Avatar_equipment_subpage.IncomingEquip.holdSlots)then
				local i = #hold_gems  + 1

				table.insert(hold_gems,i,{
				gsid =Avatar_gems_subpage.IncomingGem.gsid ,
				level = Avatar_gems_subpage.IncomingGem.level,
				name = Avatar_gems_subpage.IncomingGem.name,})

				self.ParentTable.parent.upgradeGemPos = i;
				self.ParentTable.parent.upgradeGem = Avatar_gems_subpage.IncomingGem.gsid
				self.last_incominggem = Avatar_gems_subpage.IncomingGem.gsid;
			else
				MSG("不能镶嵌该宝石，没有开孔或者没有可用孔位了。")
				return
			end
		end

		self.IncomingGem.copies = 1;
	else
		return;
	end

	--if(not self.IsAvaiableGem(arg)) then
		--commonlib.echo("current gsid is not recognize.");
		--return;
	--end

	if(not notrefresh and self.ParentTable.parent) then
		self:Update();
	end
end

--[[
	after update data,then refresh page
--]]
function Avatar_gems_subpage:Update(refresh_cb)
	self:GetItemsByFilter(self.filter,refresh_cb or function() self:Refresh(); end);
end

--[[
	call by parent window,when window is closed
--]]
function Avatar_gems_subpage:ResetStates(defaultFilter)
	self:ZeroIncomingGem(false);
	self.ParentTable = { name = "",parent = {}};
	if(defaultFilter) then
		self.filter = 0;
	end
	
end

function Avatar_gems_subpage:ZeroIncomingGem(showHighLevelGsid)
	self.IncomingGem.gsid = -999;
	self.IncomingGem.guid = -999;
	self.IncomingGem.name = "";
	self.IncomingGem.level = 0;
	self.IncomingGem.copies = 0;
	self.IncomingGem.cps = 0;
	
	--high_level_gsid is as refined gem gsid,currently is not set to 0,just show a moment.
	--samely make sure this  not is 0 before refine gem.
	if(not showHighLevelGsid) then
		self.IncomingGem.high_level_gsid = 0;
	end
end

function Avatar_gems_subpage:IsEmpty()
	if(#self.ItemsOfSelf == 0) then
		return true;
	end
	return false;
end