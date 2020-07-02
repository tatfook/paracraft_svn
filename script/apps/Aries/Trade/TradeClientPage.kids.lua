--[[
Title: code behind for trade client page
Author(s): WD, reviewed by LiXizhi
Date: 2011/10/11
Company: ParaEnging Co.
Desc:
-----------------------------------------------
--for trade kids version
NPL.load("(gl)script/apps/Aries/Trade/TradeClientPage.kids.lua");
local TradeClientPage = commonlib.gettable("MyCompany.Aries.Trade.TradeClientPage");
TradeClientPage.ShowPage();
-----------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Trade/TradeClient.lua");
NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetPane.lua");

local CombatPetPane = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetPane");
local TradeClient = commonlib.gettable("MyCompany.Aries.Trade.TradeClient");
local TradeClientPage = commonlib.gettable("MyCompany.Aries.Trade.TradeClientPage");
local Player = commonlib.gettable("MyCompany.Aries.Player");
NPL.load("(gl)script/ide/TooltipHelper.lua");
local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");

local ItemManager = Map3DSystem.Item.ItemManager;
local GetItemByID = ItemManager.GetGlobalStoreItemInMemory;
local GetItemsCount = ItemManager.GetItemCountInBag;
local GetItemsInBag = ItemManager.GetItemsInBag;
local hasGSItem = ItemManager.IfOwnGSItem;
local GetItemByBagAndOrder = ItemManager.GetItemByBagAndOrder;
local GetAllCanGiftItemGUIDs = ItemManager.GetAllCanGiftItemGUIDs;
local table_insert = table.insert;
local MSG = _guihelper.MessageBox;

local COMMISSION_FACTOR  = 0.05

TradeClientPage.filter = TradeClientPage.filter or 0;
TradeClientPage.Items= {};
TradeClientPage.DisplayItems= {};
TradeClientPage.PageSize = 56;
TradeClientPage.CurrentPet = {};
TradeClientPage.CurrentPetIndex = 1;
TradeClientPage.GiftItemsGUIDs = {};

local WHITE = "#ffffff";
local BLUE = "#0099ff";
local GREEN = "#00cc33";
local PURPLE = "#c648e1";
local YELLOW = "#ff9a00";
local RED = "#ff0000";
local GRAY = "#fcf5bd";
local HALF_TRANSPRENCY = "#98fffc7f";
--[[
	1:equipment;2:pet;
]]
TradeClientPage.BagFamily = {0,1,24,25,3,23,12,13,14};

--[[
	<pe:tab-item name="0" text="全部"/>
	<pe:tab-item name="1" text="防具"/> class = 1 and subclass[1,9],12,18,19,70,71
	<pe:tab-item name="2" text="饰品"/> class = 1 and subclass = 14,15,16,17
	<pe:tab-item name="3" text="武器"/> class = 1 and subclass = 10,11
	<pe:tab-item name="4" text="宝石"/> class = 3 and subclass = 6,8
	<pe:tab-item name="5" text="符文"/> class = 18 and subclass = 2
	<pe:tab-item name="6" text="宠物"/> class = 11 and subclass = 1
	<pe:tab-item name="7" text="道具"/> class = 3 and subclass = 8,7
	<pe:tab-item name="8" text="卡片包"/> class = 19,subclass=1
	<pe:tab-item name="9" text="消耗品"/> class = 3 and subclass = [1,5]
]]
TradeClientPage.Item_Cate = {
		[1] = {bags={1},class ={1},subclass={1,2,3,4,5,6,7,8,9,12,18,19,70,71}},
		[2] = {bags={1},class ={1},subclass={14,15,16,17}},
		[3] = {bags={1},class ={1},subclass={10,11}},
		[4] = {bags={24},class ={18},subclass={1}},
		--[4] = {class ={3,},subclass={6,8}},
		[5] = {bags={25},class ={18},subclass={2,}},
		--[6] = {bags={10010},class ={11},subclass={1,}},
		--[7] = {class ={3,},subclass={7,8}},
		[8] = {bags ={1},class ={19},subclass={1,}},
		[9] = {bags ={0,3,12,13,14},class ={3,100},subclass={1,4,5,6,7,8,9,10,}},
		};


function TradeClientPage:Init()
	self.page = document:GetPageCtrl();
end

function TradeClientPage:IsVisible()
	if(self.page and self.page:IsVisible()) then
		return true;
	end
end

function TradeClientPage:Refresh(delta)
	if(self.page)then
		self.page:Refresh(delta or 0.1);
	end
end

function TradeClientPage:GetDataSource(index)
	if(self.filter ~= 6)then
		self.PageSize = 12;
	else
		self.PageSize = 11;
	end

	local items_count = 0;
	if(self.DisplayItems)then
		items_count = #self.DisplayItems;
	end
	local displaycount = math.ceil(items_count / self.PageSize) * self.PageSize;
	if(displaycount == 0)then
		displaycount = self.PageSize;
	end

	local i;
	for i = items_count + 1,displaycount do
		if(self.filter ~= 6)then
			self.DisplayItems[i] = { gsid = 0,name = "",qty = 0,params ="",has_socketed=false};
		else
			self.DisplayItems[i] = { index = i,checked = false,name="",icon ="",has_socketed=false};
		end
	end

	if(index == nil) then
		return #(self.DisplayItems);
	else
		return self.DisplayItems[index];
	end
end

function TradeClientPage:GetSendDataSource(index)
	local money,items,is_confirmed,is_ok = TradeClient:GetSendDataProperties();
	local displayGoods = commonlib.deepcopy(items);

	local _temp = 0;
	if(displayGoods)then
		_temp = #displayGoods;
	end
	local displaycount = math.ceil(_temp / TradeClient.MAX_SLOTS) * TradeClient.MAX_SLOTS;
	if(displaycount == 0)then
		displaycount = TradeClient.MAX_SLOTS;
	end

	local i;
	for i = _temp + 1,displaycount do
		displayGoods[i] = { gsid = 0,guid = 0,copies = 0,displayname = "",};
	end

	if(index == nil) then
		return #displayGoods;
	else
		return displayGoods[index];
	end
end

function TradeClientPage:GetReceiveDataSource(index)
	local money,items,is_confirmed,is_ok = TradeClient:GetReceiveDataProperties();
	local displayGoods = commonlib.deepcopy(items);
	local _temp = 0;
	
	if(displayGoods)then
		_temp = #displayGoods;
	end

	local displaycount = math.ceil(_temp / TradeClient.MAX_SLOTS) * TradeClient.MAX_SLOTS;
	if(displaycount == 0)then
		displaycount = TradeClient.MAX_SLOTS;
	end

	local i;
	for i = _temp + 1,displaycount do
		displayGoods[i] = { guid = 0,gsid=0,copies = 0,displayname = "",};
	end

	if(index == nil) then
		return #displayGoods;
	else
		return displayGoods[index];
	end	
end

function TradeClientPage:BelongClass(class_id,class_cont)
	local i,v;
	for i,v in ipairs(class_cont)do
		if(class_id == v)then
			return true;
		end
	end
	return false;
end

--pass guid to determine the item which is can gift
function TradeClientPage:IsCanGiftItem(guid)
	local i,v;
	for i,v in ipairs(self.GiftItemsGUIDs)do
		if(tonumber(v) == guid)then
			return true;
		end
	end
	return false;
end

function TradeClientPage:GetItemsByFilter(filter,callback)
	self.DisplayItems = {};
	local _,bagid;
	local bags_family;
	if(filter == 0)then
		bags_family = self.BagFamily;
	else
		bags_family = self.Item_Cate[filter].bags;
	end

	if(#self.GiftItemsGUIDs == 0)then
		self.GiftItemsGUIDs = GetAllCanGiftItemGUIDs(); 
	end
	
	--commonlib.echo(self.GiftItemsGUIDs);
		
	for _,bagid in ipairs(bags_family) do
		GetItemsInBag(bagid,"hold items",function(msg) 
		if(msg and msg.items) then
			local _index;
			local _count = GetItemsCount(bagid);

			for _index = 1,_count do
				local _item = GetItemByBagAndOrder(bagid,_index);
				local _goods = GetItemByID(_item.gsid);	
				--commonlib.echo(_goods);
				--commonlib.echo(_item);

				if(_item and _goods)then
					local qty = _goods.template.stats[221] or -1
					local copies = _item.copies or 1;
					local name = _goods.template.name;
					local guid = _item.guid;

					local has_socketed = false;
					--如果镶嵌有宝石 不能交易
					if(_item.GetSocketedGems)then
						local gems = _item:GetSocketedGems() or {};
						local len = #gems;
						if(len > 0)then
							has_socketed = true;
						end
					end
					-- if there is addon level, disable trading. 
					if(_item.GetAddonLevel and _item:GetAddonLevel()>0)then
						has_socketed = true;
					end

					if(filter ~= 0)then
						local subclass = self.Item_Cate[filter].subclass;
						local class = self.Item_Cate[filter].class; 
						local i,v;
						if(subclass) then
							for i,v in ipairs(subclass) do
								if(	_goods.template.subclass == v and self:BelongClass(_goods.template.class,class)) then
									--table_insert(self.DisplayItems,{gsid = _item.gsid,guid=guid,name=name,copies = copies,qty=qty,cangift=_goods.template.cangift,canexchange = _goods.template.canexchange,
									--params = string.format("%s@%s#%s&%s!",guid,name,qty,copies)});
									if(_goods.template.subclass == 1 and _goods.template.class == 18) then
										if(_item.gsid ~= 22000 and _item.gsid > 40000) then
											self:BuildDisplayItems(_item.gsid,guid,name,copies,qty,_goods.template.cangift,_goods.template.canexchange,has_socketed);	
										end
									elseif((_goods.template.bagfamily ~= 0 and _item.gsid ~= 10000)or (_item.gsid == 998 and _goods.template.bagfamily == 0))then
										self:BuildDisplayItems(_item.gsid,guid,name,copies,qty,_goods.template.cangift,_goods.template.canexchange,has_socketed);	
									end
									break;
								end
							end
						end
					else
						if(_goods.template.subclass == 1 and _goods.template.class == 18) then
							if(_item.gsid ~= 22000 and _item.gsid > 40000) then
								self:BuildDisplayItems(_item.gsid,guid,name,copies,qty,_goods.template.cangift,_goods.template.canexchange,has_socketed);	
							end
						elseif((_goods.template.bagfamily ~= 0 and _item.gsid ~= 10000) or (_item.gsid == 998 and _goods.template.bagfamily == 0))then
							self:BuildDisplayItems(_item.gsid,guid,name,copies,qty,_goods.template.cangift,_goods.template.canexchange,has_socketed);
						end
						--table_insert(self.DisplayItems,{gsid = _item.gsid,guid=guid,name=name,copies = copies,qty=qty,cangift=_goods.template.cangift,canexchange = _goods.template.canexchange,
						--params = string.format("%s@%s#%s&%s!",guid,name,qty,copies)});
					end

					table_insert(self.Items,{gsid = _item.gsid,guid=_item.guid,params = string.format("%s@%s#%s&%s!",guid,name,qty,copies)});
				end
			end
		end
		end,"access plus 1 year");
	end
	--commonlib.echo(self.DisplayItems);

	if(callback and type(callback) == "function") then
		callback();
	end
end

function TradeClientPage:BuildDisplayItems(gsid,guid,name,copies,qty,cangift,canexchange,has_socketed)
	if(has_socketed)then
		table_insert(self.DisplayItems,{gsid = gsid,guid=guid,name=name,copies = copies,qty=qty,has_socketed=true,
				params = string.format("%s@%s#%s&%s!",guid,name,qty,copies)});		
	else
		if(cangift and canexchange)then
			table_insert(self.DisplayItems,1,{gsid = gsid,guid=guid,name=name,copies = copies,qty=qty,cangift=cangift,canexchange = canexchange,has_socketed=false,
							params = string.format("%s@%s#%s&%s!",guid,name,qty,copies)});
		else
			table_insert(self.DisplayItems,{gsid = gsid,guid=guid,name=name,copies = copies,qty=qty,cangift=cangift,canexchange = canexchange,has_socketed=false,
							params = string.format("%s@%s#%s&%s!",guid,name,qty,copies)});
		end	
	end
end

function TradeClientPage:FilterItems(name)
	if(#self.Items == 0) then
		return;
	end

	self.filter = tonumber(name or 1);
	if(self.filter == 6)then
		self:GetPetList();	
	else
		self:Update();
	end
end

function TradeClientPage:GetPetList(arg,params)
	CombatPetPane.SearchPetList(nil,function(msg) 
		self.DisplayItems = {};
		if(msg and msg.list)then
			self.DisplayItems = msg.list;
			--filter incoming pets
			self:FilterIncomingItems();
			if(arg)then
				self:OnClickItem(arg ,nil,false);
			else
				self:OnClickItem(self.CurrentPetIndex,nil,true);
			end
		end
	end);	
end

function TradeClientPage:FilterIncomingItems()
	local money,items,is_confirmed,is_ok = TradeClient:GetSendDataProperties();
	local i,v,i2,v2;

	for i,v in ipairs(items) do
		for i2,v2 in ipairs(self.DisplayItems) do
			if(v.gsid == v2.gsid)then
				v2.copies = (v2.copies or 1)- v.copies;
				if(v2.copies == 0)then
					table.remove(self.DisplayItems,i2);
				end
				break;
			end
		end
	end
end

function TradeClientPage:Update(gsid,params)
	if(self.filter ~= 6)then
		self.CheckPay();
		self:GetItemsByFilter(self.filter,function() 
		self:FilterIncomingItems();
		self:Refresh();
		end);
	else
		self:GetPetList(gsid);	
	end
end

function TradeClientPage.GetMagicBean()
    local __,__,__,copies = hasGSItem(984);
    copies = copies or 0;
	--[[
	if(TradeClientPage.commission and TradeClientPage.commission > 0)then
		copies = copies - TradeClientPage.commission;
	end
	]]
    return copies;
end

function TradeClientPage.CalcCommission(arg)
	TradeClientPage.commission = COMMISSION_FACTOR * (arg or 0)
	TradeClientPage.commission = math.ceil(TradeClientPage.commission)
	if(TradeClientPage.page) then
		TradeClientPage.page:SetValue("txtCommission",tostring(TradeClientPage.commission));
	end
end
function TradeClientPage.CheckPay()
	local txtCost = TradeClientPage.page and TradeClientPage.page:FindControl("txtCost");
	if(txtCost)then
		TradeClientPage.pay_magicbean = tonumber(txtCost.text) or 0;

		TradeClient:SetPay(tonumber(txtCost.text) or 0);
		TradeClientPage.CalcCommission(tonumber(txtCost.text) or 0);

	end
end

function TradeClientPage:OnClickItem(arg,params,isindex)
	if(not arg) then return end
	local money,items,is_confirmed,is_ok = TradeClient:GetSendDataProperties();
	
	if(arg == 984)then
		TradeClientPage.page:SetValue("txtCost","0");
		TradeClient:SetPay(0);
	else
		self.CheckPay();
		if(TradeClientPage.pay_magicbean and TradeClientPage.pay_magicbean > 0)then
			if((TradeClientPage.pay_magicbean + TradeClientPage.commission) > TradeClientPage.GetMagicBean())then
				_guihelper.MessageBox("你的魔豆不足以进行本次交易。");
				return 
			end
		end
	end

	--cancel incoming item
	if(params == "cancelitem")then
		local i,v;
		for i,v in ipairs(items)do
			if(v.gsid == arg)then
				table.remove(items,i);
				break;
			end
		end	

		self:Update(arg,params);
		if(self.filter == 6)then
			self:OnClickItem(self.CurrentPet.gsid,nil);
		end
		TradeClient:SendItemUpdate();
		return; --end cancel item,and return it.
	end

	if(self.filter == 6)then
		local node;

		if(isindex == true)then
			node = self.DisplayItems[arg];
			self.CurrentPetIndex = arg;
			self.CurrentPet = node;
		else
			local i,v;
			for i,v in ipairs(self.DisplayItems) do
				if(v.gsid == arg)then
					node = v;
					self.CurrentPet = v;
					self.CurrentPetIndex = i;
				end
			end
		end

		local k,v;
		for  k,v in ipairs(self.DisplayItems)do
			v.checked = false;
		end
		if(node)then
			if(node.checked)then
				node.checked = false;
			else
				node.checked = true;
			end
		end
		
		self:Refresh();
		return;
	end

	--[[local i,v;
	for i,v in ipairs(self.DisplayItems)do
		if(v.gsid == arg)then
			if(not v.canexchange or not v.cangift)then MSG(string.format("\"%s\"不能交易。",v.name));return end
			break;
		end
	end
	]]

	--incoming items processed
	self:SetSendGoods(arg,params);
	self:Update(arg,params);
	TradeClient:SendItemUpdate();
	
end

function TradeClientPage:GetGold()
	local hasGold, _, _, my_gold_count = hasGSItem(17178);
	if(hasGold and my_gold_count)then
		return my_gold_count;
	end
	return ""
end
--default is select first pet
function TradeClientPage:SelectPet()
	local money,items,is_confirmed,is_ok = TradeClient:GetSendDataProperties();
	if((self.CurrentPet and not self.CurrentPet.gsid) or is_confirmed )then return end

	local i,v,j;
	for i,v in ipairs(items) do
		if(v.gsid == self.CurrentPet.gsid)then
			j = true;
			break;
		end
	end

	if(not j and #items == TradeClient.MAX_SLOTS) then return end

	self:SetSendGoods(self.CurrentPet.gsid);

	CombatPetPane.SearchPetList(nil,function(msg) 
		self.DisplayItems = {};
		if(msg and msg.list)then
			self.DisplayItems = msg.list;
			--filter incoming pets
			self:FilterIncomingItems();
		end
	end);

	self:OnClickItem(1,nil,true);
	self:Update();
	TradeClient:SendItemUpdate();
	--self:Refresh();

end

function TradeClientPage:GetItemsCountById(gsid)
	local i,v;
	local count = 1;
	for i,v in ipairs(self.DisplayItems) do
		if(v.gsid == gsid )then
			count = (v.copies or 1);
			break;
		end
	end
	return count;
end

function TradeClientPage:ParseParams(params)
	if(not params)then return end
	return tonumber(string.match(params,"^(%d+)@")),
	string.match(params,"@(.+)#"),
	tonumber(string.match(params,"#(-?%d)&")),
	tonumber(string.match(params,"&(%d+)!")),
	string.match(params,"!(.+)$");
end

function TradeClientPage:SetSendGoods(gsid,params)
	local money,items,is_confirmed,is_ok = TradeClient:GetSendDataProperties();

	local name = "";
	local qty = -1;
	local copies = 1;
	local guid = 0;
	local sgl;

	if(self.filter == 6)then
		name = self.CurrentPet.name;
		local i,v;
		for i,v in ipairs(self.Items)do
			if(v.gsid == gsid)then
				guid,name,qty,copies,sgl = self:ParseParams(v.params);
				if(sgl)then
					copies = 1;
				end
				break;
			end
		end
	elseif(params) then -- format(%s@%s#%s&%s$%s!)
		guid,name,qty,copies,sgl = self:ParseParams(params);
		if(sgl)then
			copies = 1;
		end
	end

	local i,v,j;
	for i,v in ipairs(items) do
		if(v.gsid == gsid)then
			j = true;
			break;
		end
	end

	if(not j and #items == TradeClient.MAX_SLOTS) then return end
	j = nil;

	for i,v in ipairs(self.DisplayItems) do
		if(v.gsid == gsid )then
			if(self.filter == 6)then
				table.remove(self.DisplayItems,i);
			else
				if(not v.copies)then
					table_remove(self.DisplayItems,i)
				elseif(v.copies == 1)then
					table.remove(self.DisplayItems,i);
				else
					v.copies = v.copies - (copies or 1);
				end
			end

			break;
		end
	end

	for i,v in ipairs(items) do
		if(v.gsid == gsid)then
			if(self.filter ~= 6)then
				v.copies = v.copies + (copies or 1);
				v.copies = TradeClientPage:CheckCopies(gsid,v.copies)
				--echo("current copies:" .. v.copies);
			end
			j = true;
			break;
		end
	end

	local item_table = self:BuildDisplayTable(gsid,guid,name,qty,copies);
	if(not item_table)then return end

	if(#items < TradeClient.MAX_SLOTS)then
		TradeClient:SetSendGoods(item_table,j);
	end
end

--check trade units whether is out  range of max copies
function TradeClientPage:CheckCopies(gsid,copies)
	local _, __, ___, max_copies = hasGSItem(gsid);
	--echo("max_copies:" .. max_copies)
	if(copies > max_copies)then
		return max_copies;
	end
	return copies
end

--[[
	determine the distance of each other which is can trade
]]
function TradeClientPage:CanTrade(nid)
	if(not nid and not MyCompany.Aries.Trade.TradeClient.partner_nid)then return false end
	nid = nid or MyCompany.Aries.Trade.TradeClient.partner_nid;
	local dist_sq = MyCompany.Aries.Player.DistanceSqToGSLAgent(nid)

	if(dist_sq  and dist_sq < 20*20) then
		return true;
	else
		return false;
	end
end

function TradeClientPage:CanExchangeAndGift()
	if(self.filter == 6)then
		local i,v;
		for i,v in ipairs(self.DisplayItems)do
			if(v.gsid == self.CurrentPet.gsid and v.canexchange and v.cangift)then
				return true;
			else
				return false;
			end
		end
	else

	end
end

--[[
	@return:build table for display
]]
function TradeClientPage:BuildDisplayTable(gsid,guid,name,qty,copies)
	if(not guid or not gsid)then return end
	if(not name and name ~= "")then
		local item;
		
		item = GetItemByID(gsid);--???
		if(not item)then return end

		name = item.template.name;

		if(not qty)then
			qty = (item.template.stats[221] or -1);
		end
	end

	if(not qty)then qty = -1; end

	local equip_color = "#000000";
	if(qty == 0)then
		equip_color = WHITE;
	elseif(qty == 1)then
		equip_color = GREEN;
	elseif(qty == 2)then
		equip_color = BLUE;
	elseif(qty == 3)then
		equip_color = PURPLE;
	elseif(qty == 4)then
		equip_color = YELLOW;
	end

	return {gsid = gsid,guid = guid,displayname=string.format([[<div style="color:%s;">%s</div>]],equip_color,name),copies = (copies or 1)};
end

function TradeClientPage.ShowPage(partner_nid,not_return)
	NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
	local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
	local can_pass = DealDefend.CanPass(function()
		TradeClientPage.ShowPage(partner_nid,not_return)
	end);
	if(not can_pass)then 
		--if(TradeClient.partner_accepted and TradeClient.tradeclient)then
			--TradeClient.tradeclient:CancelTrade();
		--end
		return 
	end

	local self = TradeClientPage;
	local width,height = 780,465;
	

	if(not partner_nid) then return end
	--if(not TradeClient.initialized)then
		TradeClient:Init(tostring(partner_nid));
	--end
	-- distance check timer.
	self.timer = self.timer or commonlib.Timer:new({callbackFunc = function(timer)
		if(not TradeClientPage:CanTrade())then
			timer:Change();
			if(TradeClientPage:IsVisible())then
				TradeClientPage:CloseWindow();
			end
			--_guihelper.MessageBox("距离太远了。");
		end
	end});
	self.timer:Change(1000,1000);

	if(TradeClient.partner_accepted)then
		local params = {
					url = "script/apps/Aries/Trade/TradeClientPage.kids.html" , 
					name = "TradeClientPage.ShowPage", 
					app_key=MyCompany.Aries.app.app_key, 
					isShowTitleBar = false,
					DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
					enable_esc_key = true,
					style = CommonCtrl.WindowFrame.ContainerStyle,
					allowDrag = true,
					directPosition = true,
					align = "_ct",
					isTopLevel = true,
					x = -width * .5,
					y = -height * .5,
					width = width,
					height = height,
					};

			System.App.Commands.Call("File.MCMLWindowFrame", params);
			if(params._page)then
				params._page.OnClose = TradeClientPage.ResetStates
			end
			
		self:Update();
	elseif(not not_return)then
		TradeClientPage.can_shake = false;
		self.check20s = self.check20s or commonlib.Timer:new({callbackFunc = function(timer)
			timer:Change();
			if(not TradeClientPage.can_shake)then
				MyCompany.Aries.Trade.TradeClient.trade_canceled = true;
				MyCompany.Aries.Trade.TradeClient:Clean();
				_guihelper.MessageBox("交易请求超时。")
			end
		end});
		self.check20s:Change(20000);

		BroadcastHelper.PushLabel({id="trade_tip", label = "交易申请已经发出， 等待对方确认", max_duration=10000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
		TradeClient:AcceptRequestTrade(tostring(partner_nid),function(partner_nid)
		if(not partner_nid ) then return end
		if(not TradeClient.initialized)then
			TradeClient:Init(tostring(partner_nid));
		end

		TradeClientPage.can_shake = true;

		local width,height = 780,465;
		local params = {
					url = "script/apps/Aries/Trade/TradeClientPage.kids.html" , 
					name = "TradeClientPage.ShowPage", 
					app_key=MyCompany.Aries.app.app_key, 
					isShowTitleBar = false,
					DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
					enable_esc_key = true,
					style = CommonCtrl.WindowFrame.ContainerStyle,
					allowDrag = true,
					directPosition = true,
					isTopLevel = true,
					align = "_ct",
					x = -width * .5,
					y = -height * .5,
					width = width,
					height = height,
					};

			System.App.Commands.Call("File.MCMLWindowFrame", params);
			if(params._page)then
				params._page.OnClose = TradeClientPage.ResetStates
			end
			TradeClientPage:Update();
		end)
	end
end

function TradeClientPage:ResetStates()
	TradeClient:Clean();
	TradeClientPage.commission = 0;
	self.CurrentPet = {};
	self.Items = {};
	self.CurrentPetIndex = 1;
	self.DisplayItems = {};
	self.filter = 0;
	self.timer = nil;
	self.can_shake = true;
	self.check20s = nil;
	TradeClientPage.pay_magicbean = 0;
end

function TradeClientPage:CloseWindow()
	if(TradeClientPage.page)then
		TradeClientPage.page:CloseWindow();
	end
end