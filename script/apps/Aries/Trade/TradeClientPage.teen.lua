--[[
Title: code behind for trade client page
Author(s): WD, reviewed by LiXizhi
Date: 2011/10/11
Company: ParaEnging Co.
Desc:
-----------------------------------------------
NPL.load("(gl)script/apps/Aries/DefaultTheme.teen.lua");
MyCompany.Aries.Theme.Default:Load();
NPL.load("(gl)script/apps/Aries/Trade/TradeClientPage.teen.lua");
local TradeClientPage = commonlib.gettable("MyCompany.Aries.Trade.TradeClientPage");
TradeClientPage.ShowPage();
-----------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Trade/TradeClient.lua");
NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetPane.lua");
NPL.load("(gl)script/apps/Aries/Desktop/GenericTooltip.lua");

local GenericTooltip = CommonCtrl.GenericTooltip:new();
local CombatPetPane = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetPane");
local TradeClient = commonlib.gettable("MyCompany.Aries.Trade.TradeClient");
local TradeClientPage = commonlib.gettable("MyCompany.Aries.Trade.TradeClientPage");
local Player = commonlib.gettable("MyCompany.Aries.Player");
NPL.load("(gl)script/ide/TooltipHelper.lua");

local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");
local ItemManager = Map3DSystem.Item.ItemManager;
local GetItemByID = ItemManager.GetGlobalStoreItemInMemory;
local GetItemsCount = ItemManager.GetItemCountInBag;
local hasGSItem = ItemManager.IfOwnGSItem;
local getItemByGuid = ItemManager.GetItemByGUID;
local GetItemsInBag = ItemManager.GetItemsInBag;
local GetItemByBagAndOrder = ItemManager.GetItemByBagAndOrder;
local table_insert = table.insert;
local MSG = _guihelper.MessageBox;

TradeClientPage.filter = TradeClientPage.filter or 0;
TradeClientPage.Items= {};
TradeClientPage.DisplayItems= {};
TradeClientPage.PageSize = 56;
TradeClientPage.CurrentPet = {};
TradeClientPage.CurrentPetIndex = 1;

TradeClientPage.GOLD_ID = 17178;
TradeClientPage.MAGICBEAN_ID = 984

--[[
	1:equipment;2:pet;
]]
TradeClientPage.BagFamily = {0,1,3,23,24,25,26,12,13,14};

TradeClientPage.Item_Cate = {
		[1] = {bags={24},class =18,subclass={1}},
		[2] = {bags={25},class =18,subclass={2,}},
		[3] = {bags={12},class =3,subclass={2}},
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
		self.PageSize = 56;
	else
		self.PageSize = 14;
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
			self.DisplayItems[i] = { gsid = -999,name = "",qty = 0,params ="",};
		else
			self.DisplayItems[i] = { index = i,checked = false,name="",icon ="",};
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
		displayGoods[i] = { gsid = -999,guid = 0,copies = 0,displayname = "",};
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
		displayGoods[i] = { guid = 0,gsid=-999,copies = 0,displayname = "",};
	end

	if(index == nil) then
		return #displayGoods;
	else
		return displayGoods[index];
	end	
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

	
	local fetched_bag_count = 0;
	for _,bagid in ipairs(bags_family) do
		GetItemsInBag(bagid,"hold items",function(msg) 
			fetched_bag_count = fetched_bag_count + 1;

			if(msg and msg.items) then
				local _index;
				local _count = GetItemsCount(bagid);

				for _index = 1,_count do
					local _item = GetItemByBagAndOrder(bagid,_index);
					local _goods = GetItemByID(_item.gsid);	
					--commonlib.echo(_goods);

					if(_item and _goods and (not _item.guid or _item.guid>0) )then
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
									if(	_goods.template.subclass == v and _goods.template.class == class) then
										--table_insert(self.DisplayItems,{gsid = _item.gsid,guid=guid,name=name,copies = copies,qty=qty,
										--params = string.format("%s@%s#%s&%s!",guid,name,qty,copies)});
											if((_goods.template.bagfamily ~= 0 and _item.gsid ~= 10000)or (_item.gsid == 998 and _goods.template.bagfamily == 0))then
												self:BuildDisplayItems(_item.gsid,guid,name,copies,qty,_goods.template.cangift,_goods.template.canexchange,has_socketed);	
											end
										break;
									end
								end
							end
						else
							--table_insert(self.DisplayItems,{gsid = _item.gsid,guid=guid,name=name,copies = copies,qty=qty,
							--params = string.format("%s@%s#%s&%s!",guid,name,qty,copies)});
							if((_goods.template.bagfamily ~= 0 and _item.gsid ~= 10000) or (_item.gsid == 998 and _goods.template.bagfamily == 0))then
								self:BuildDisplayItems(_item.gsid,guid,name,copies,qty,_goods.template.cangift,_goods.template.canexchange,has_socketed);
							end
						end

						table_insert(self.Items,{gsid = _item.gsid,guid=_item.guid,params = string.format("%s@%s#%s&%s!",guid,name,qty,copies)});
					end
				end
			end
			if(fetched_bag_count == #bags_family) then
				if(callback and type(callback) == "function") then
					callback();
				end
			end
		end,"access plus 1 year");
	end
	--commonlib.echo(self.DisplayItems);
end

function TradeClientPage:FilterItems(name)
	if(#self.Items == 0) then
		return;
	end

	self.filter = tonumber(name or 0);
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
		self:GetItemsByFilter(self.filter,function() 
			self:FilterIncomingItems();
			self:Refresh();
		end);
	else
		self:GetPetList(gsid);	
	end
end

function TradeClientPage.CheckPay()
	--local txtCost = tonumber(TradeClientPage.page:GetUIValue("txtCost", 0)) or 0;
	local txtCost = 0;
	if(txtCost)then
		if(txtCost > 0 )then
			TradeClientPage.page:SetUIValue("txtCost", 0);
			local name = MyCompany.Aries.ExternalUserModule:GetConfig().currency_name or "魔豆";
			_guihelper.MessageBox("为了账户安全, 本版暂时禁止了"..name.."交易")
			return
		end
		TradeClient:SetPay(txtCost);
		TradeClientPage.commission = TradeClient:CalcMoney();
		if(TradeClientPage.commission)then
			TradeClientPage:Refresh();
			return TradeClientPage.commission;
		else
			TradeClientPage.commission = "";
		end
	end
	return 
end

function TradeClientPage:OnClickItem(arg,params,isindex)
	if(not arg) then return end
	local money,items,is_confirmed,is_ok = TradeClient:GetSendDataProperties();

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

	--incoming items processed
	self:SetSendGoods(arg,params);
	self:Update(arg,params);
	TradeClient:SendItemUpdate();
	
end

function TradeClientPage:BuildDisplayItems(gsid,guid,name,copies,qty,cangift,canexchange, has_socketed)
	if(cangift and canexchange and not has_socketed)then
		table_insert(self.DisplayItems,1,{gsid = gsid,guid=guid,name=name,copies = copies,qty=qty,cangift=cangift,canexchange = canexchange and not has_socketed,
			params = string.format("%s@%s#%s&%s!",guid,name,qty,copies)});
	end	
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

function TradeClientPage.GetItemCopies(gsid)
	local has, _, _, copies = hasGSItem(gsid);
	return copies or 0
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
					v.copies = TradeClientPage:CheckCopies(gsid,v.copies)
				end
			end

			break;
		end
	end

	for i,v in ipairs(items) do
		if(v.gsid == gsid)then
			if(self.filter ~= 6)then
				v.copies = v.copies + (copies or 1);
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
	local has, __, ___, max_copies = hasGSItem(gsid);
	--echo("max_copies:" .. max_copies)
	if(has)then
		if( copies > max_copies)then
		return max_copies;
		else
		return copies
		end
	end
	return 0
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

	local equip_color = GenericTooltip.GetEquipColor(qty);
	return {gsid = gsid,guid = guid,displayname=string.format([[<div style="color:%s;">%s</div>]],equip_color,name),copies = (copies or 1)};
end

function TradeClientPage.ShowPage(partner_nid,not_return)
	NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
	local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
	local can_pass = DealDefend.CanPass(function()
		TradeClientPage.ShowPage(partner_nid,not_return);
	end);
	if(not can_pass)then 
		--if(TradeClient.partner_accepted and TradeClient.tradeclient)then
			--TradeClient.tradeclient:CancelTrade();
		--end
		return 
	end

	local self = TradeClientPage;
	local width,height = 800,512;
	
	TradeClientPage.partner_nid = TradeClientPage.partner_nid or partner_nid;
	if(not partner_nid ) then return end
	if(not TradeClient.initialized)then
		TradeClient:Init(tostring(partner_nid));
	end
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
					url = "script/apps/Aries/Trade/TradeClientPage.teen.html" , 
					name = "TradeClientPage.ShowPage", 
					app_key=MyCompany.Aries.app.app_key, 
					isShowTitleBar = false,
					DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
					enable_esc_key = true,
					style = CommonCtrl.WindowFrame.ContainerStyle,
					allowDrag = true,
					directPosition = true,
					align = "_ct",
					x = -width * 0.5,
					y = -height * 0.5,
					width = width,
					height = height,
					};

			System.App.Commands.Call("File.MCMLWindowFrame", params);
			if(params._page)then
			params._page.OnClose = self.Clean;
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
		local params = {
					url = "script/apps/Aries/Trade/TradeClientPage.teen.html" , 
					name = "TradeClientPage.ShowPage", 
					app_key=MyCompany.Aries.app.app_key, 
					isShowTitleBar = false,
					DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
					enable_esc_key = true,
					style = CommonCtrl.WindowFrame.ContainerStyle,
					allowDrag = true,
					directPosition = true,
					align = "_ct",
					x = -width * .5,
					y = -height * .5,
					width = width,
					height = height,
					};

			System.App.Commands.Call("File.MCMLWindowFrame", params);
			if(params._page)then
			params._page.OnClose = self.Clean;
			end
			TradeClientPage:Update();
		end)
	end
end

function TradeClientPage.Clean()
	TradeClient:Clean();
	local self = TradeClientPage
	self.CurrentPet = {};
	self.Items = {};
	self.CurrentPetIndex = 1;
	self.DisplayItems = {};
	self.filter = 0;
	self.timer = nil;
	self.can_shake = true;
	self.check20s = nil;
	self.commission = nil;
	self.partner_nid = nil
end

function TradeClientPage:CloseWindow()
	if(self.page)then
		self.page:CloseWindow();
	end
end