--[[
Title: auction house
Author(s): LiXizhi
Date: 2012/6/20
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/HaqiShop/AuctionHouse.lua");
local AuctionHouse = commonlib.gettable("MyCompany.Aries.AuctionHouse");
AuctionHouse.ShowPage()
AuctionHouse.ShowPage("sell", true, 17143)
AuctionHouse.ViewPage(npcid);
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/HaqiShop/NPCShopProvider.lua");
NPL.load("(gl)script/apps/Aries/Desktop/GenericTooltip.lua");
NPL.load("(gl)script/apps/Aries/Desktop/AvatarBag.lua");
NPL.load("(gl)script/apps/Aries/HaqiShop/ItemGuides.lua");
local ItemGuides = commonlib.gettable("MyCompany.Aries.ItemGuides");
local AvatarBag = commonlib.gettable("MyCompany.Aries.Desktop.AvatarBag");
local NPCShopProvider = commonlib.gettable("MyCompany.Aries.NPCShopProvider");
local ItemManager = commonlib.gettable("System.Item.ItemManager");
local AuctionHouse = commonlib.gettable("MyCompany.Aries.AuctionHouse");
local NPCList = commonlib.gettable("MyCompany.Aries.Quest.NPCList");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
local HaqiShop = commonlib.gettable("MyCompany.Aries.HaqiShop");
local Player = commonlib.gettable("MyCompany.Aries.Player");

local page;
local GenericTooltip;
AuctionHouse.show_list = {}
AuctionHouse.pindex = 0;
AuctionHouse.MAGICBEAN_ID = 984;
-- the buyer has to pay 25% of selling price to us
AuctionHouse.buyer_fee_percent = 0.25; 
-- item to be sold
AuctionHouse.goods = {}; 
-- show seller name by default
AuctionHouse.show_seller_name = true;
-- whether to check the price range 
AuctionHouse.CheckPriceRange = false;

AuctionHouse.TimePeriodTable = {
	{value="1",selected = true, text="1天"},
	{value="3",selected = false, text="3天"},
	{value="5",selected = false, text="5天"},
	{value="7",selected = false, text="7天"},
};

-- days to qidou price mapping
AuctionHouse.AgentPriceTable = {
	[1] = 3000,
	[3] = 3000,
	[5] = 5000,
	[7] = 7000,
};

--AuctionHouse.auction_category_node = {
	--{name="item", attr={text="全部",expanded=true},},
	----folder
	--{name="folder",attr={text="卡牌", expanded=true},
		--{name="item",attr={text="技能卡",class=18,subclass=1,expanded=false}},
		--{name="item",attr={text="符文卡",class=18,subclass=2,expanded=false},},
	--},
	----{name="folder",attr={text="炫彩装", expanded=false},
		----{name="item",attr={text="帽子",class=1,subclass=18,expanded=false}},
		----{name="item",attr={text="衣服",class=1,subclass=19,expanded=false}},
		----{name="item",attr={text="背部",class=1,subclass=70,expanded=false}},
		----{name="item",attr={text="鞋子",class=1,subclass=71,expanded=false}},
		----{name="item",attr={text="手持",class=1,subclass=72,expanded=false}},
	----},
	----{name="folder",attr={text="其他", expanded=true},
		----{name="item",attr={text="宠物果实",class=3,subclass=2,expanded=false}},
	----},
--};

local PAGE_SIZE_PURCHASE = 12;

-- whether auction is enabled. 
AuctionHouse.IsEnabled = true;

function AuctionHouse.OnInit()
	--if(System.options.locale == "zhTW") then
		--AuctionHouse.IsEnabled = false;
	--end

	page = document:GetPageCtrl();
	local ds = AuctionHouse.GetCategoryDS();
	NPL.load("(gl)script/apps/Aries/HaqiShop/ItemGuides.lua");
	ItemGuides.Init();
	GenericTooltip = GenericTooltip or CommonCtrl.GenericTooltip:new();
end

-- only used for avatar bag. 
AuctionHouse.SellingView = {
	filter = 1,
	DisplayItems = {},
	Refresh =  function()
		if(page) then
			page:Refresh(0.1);
		end
	end
};

local function _GetConsigName(gsid,cnt)
	local item = ItemManager.GetGlobalStoreItemInMemory(gsid);	
	if(item) then
		local name = item.template.name;
		if(not cnt or cnt < 2)then
			return name
		else
			return string.format("%s X %s",name,cnt);
		end
	else
		return "";
	end
end

function AuctionHouse.GetAgentFee(days)
	days = days or AuctionHouse.goods.expire;
	return AuctionHouse.GetAuctionFeeByGSID(AuctionHouse.goods.gsid, days) or AuctionHouse.AgentPriceTable[days or AuctionHouse.goods.expire] or 0;
end

function AuctionHouse.GetSellerFee()
	return 1-1/(1+AuctionHouse.buyer_fee_percent);
end

-- whether a given gsid can be sold by the current user. socketed items are not tradable.
function AuctionHouse.IsTradable(gsid)
	local item = ItemManager.GetGlobalStoreItemInMemory(gsid);		
	local has, guid, _, copies = ItemManager.IfOwnGSItem(gsid);

	if(item and has) then
		local cangift=item.template.cangift;
		local canexchange = item.template.canexchange;
		local has_socketed = false;
		local _item = ItemManager.GetItemByGUID(guid);
		if(cangift and canexchange) then
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
			if(not has_socketed) then
				return true;
			end
		end
	end
end

-- call this function to show a given npc_id page
function AuctionHouse.ViewPage(npcid)
	
	local category = AuctionHouse.GetCategoryDS();
	if(category) then
		local node;
		for node in commonlib.XPath.eachNode(category, "//item") do
			if(node.attr.npcid == npcid) then
				AuctionHouse.ChangeMarketDataSource(node.attr);
			end
		end
	end
	AuctionHouse.ShowPage();
end

-- virtual function: create UI
-- @param tabname: "view", "buy", "sell",
-- @param is_market: true for market only items. 
-- @param auction_gsid: auction gsid
function AuctionHouse.ShowPage(tabname, is_market, auction_gsid)
	if(System.options.disable_trading) then
		_guihelper.MessageBox("因个人账户安全原因，物品交换/邮件系统进行维护。预计将在下次更新后修复功能，若提前恢复交易功能不做另行通知。");
		return;
	end
	
	NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
	local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
	local can_pass = DealDefend.CanPass();
	if(not can_pass)then return end

	AuctionHouse.is_market = is_market;
	
	local width,height = 827,542;
	local url = format("script/apps/Aries/HaqiShop/AuctionHouse.teen.html?tab=%s", tabname or "");
	if(auction_gsid) then
		url = format("%s&auction_gsid=%s", url, tostring(auction_gsid));
	end
	local params = {
        url = url, 
        app_key = MyCompany.Aries.app.app_key, 
        name = "AuctionHouse.ShowMainWnd", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		enable_esc_key = true,
        style = CommonCtrl.WindowFrame.ContainerStyle,
        -- zorder = 2,
        allowDrag = true,
		-- isTopLevel = true,
        directPosition = true,
        align = "_ct",
        x = -width * 0.5,
        y = -height * 0.5,
        width = width,
        height = height,
		SelfPaint = System.options.IsMobilePlatform,
	};
	System.App.Commands.Call("File.MCMLWindowFrame", params);

	if(params._page)then
		params._page.OnClose = function()
			AvatarBag.Clean(true)
			-- ItemsFilter:Clean()
			AuctionHouse.goods = {copies = 0,guid=0,gsid=-999}
			AuctionHouse.filter = 0;
			AuctionHouse.DisplayItems = {};
			AuctionHouse.sort_col = nil;
			AuctionHouse.is_lastpage = nil;
		end;
	end
end

-- 打开商城指定栏目
--  npcid:商城 虚拟 NPCID.
--  mainfolder: 左边大目录
--  subfoler: 子目录
function AuctionHouse.ShopShowPage(npcid, mainfolder, subfolder)	
	AuctionHouse.is_market = false;
	mainfolder = mainfolder or "";
	subfolder = subfolder or "";
	npcid = tonumber(npcid);

	--commonlib.echo("---------------ShopShowPage")
	--commonlib.echo(mainfolder)
	--commonlib.echo(subfolder)

	local ds = AuctionHouse.GetCategoryDS();
	local attr = {npcid = npcid}
	AuctionHouse.ChangeMarketDataSource(attr);
	
	local node;
	for node in commonlib.XPath.eachNode(ds, "//folder") do
		node.attr.expanded = false;
		node[1].attr.expanded = false;
		if(mainfolder == node.attr.label)then
			node.attr.expanded = true;			
			if(subfolder == node[1].attr.label)then 
				node[1].attr.expanded = true;
			end
		end
	end
	--  commonlib.echo(AuctionHouse.category_ds)

	for node in commonlib.XPath.eachNode(AuctionHouse.category_ds, "//item") do
		node.attr.checked = false;
		if(attr.npcid == node.attr.npcid)then
			node.attr.checked = true;
		end
	end
	local width,height = 827,542;
	local url = format("script/apps/Aries/HaqiShop/AuctionHouse.teen.html");
	local params = {
        url = url, 
        app_key = MyCompany.Aries.app.app_key, 
        name = "AuctionHouse.ShowMainWnd", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		enable_esc_key = true,
        style = CommonCtrl.WindowFrame.ContainerStyle,
        -- zorder = 2,
        allowDrag = true,
		-- isTopLevel = true,
        directPosition = true,
        align = "_ct",
        x = -width * 0.5,
        y = -height * 0.5,
        width = width,
        height = height,
		SelfPaint = System.options.IsMobilePlatform,
	};
	System.App.Commands.Call("File.MCMLWindowFrame", params);
	
	if(params._page)then
		params._page.OnClose = function()
			AvatarBag.Clean(true)
			-- ItemsFilter:Clean()
			AuctionHouse.goods = {copies = 0,guid=0,gsid=-999}
			AuctionHouse.filter = 0;
			AuctionHouse.DisplayItems = {};
			AuctionHouse.sort_col = nil;
			AuctionHouse.is_lastpage = nil;
		end;
	end
end

function AuctionHouse.OnClickViewItem(gsid)
	gsid = tonumber(gsid);
	if(not gsid) then
		return 
	end
	local width,height = 600, 490;
	local url = if_else(System.options.version=="kids", "script/apps/Aries/HaqiShop/AuctionHouseItemView.kids.html", "script/apps/Aries/HaqiShop/AuctionHouseItemView.teen.html");
	local params = {
        url = format("%s?gsid=%d", url, gsid), 
        app_key = MyCompany.Aries.app.app_key, 
        name = "AuctionHouseViewItem.ShowMainWnd", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		enable_esc_key = true,
        style = CommonCtrl.WindowFrame.ContainerStyle,
        zorder = 1,
        -- allowDrag = true,
		isTopLevel = true,
        directPosition = true,
        align = "_ct",
        x = -width * 0.5,
        y = -height * 0.5+36,
        width = width,
        height = height,
	};
	System.App.Commands.Call("File.MCMLWindowFrame", params);
end

function AuctionHouse.OnInitItemView()
	NPL.load("(gl)script/apps/Aries/HaqiShop/ItemGuides.lua");
	ItemGuides.Init();
	AuctionHouse.item_view_page = document:GetPageCtrl();
end

function AuctionHouse.GetFilterCategoryDS()
	if(not AuctionHouse.auction_category_node) then
		-- read from xml file. 
		local filename = "config/Aries/NPCShop_Teen/auctionhouse_buyer_category.xml"
			
		local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
		if(xmlRoot) then
			AuctionHouse.auction_category_node = xmlRoot[1];
			local node;
			for node in commonlib.XPath.eachNode(AuctionHouse.auction_category_node, "//item") do
				local attr = node.attr;
				if(attr) then
					if(attr.class) then
						attr.class = tonumber(attr.class);
					end
					if(attr.subclass) then
						attr.subclass = tonumber(attr.subclass);
					end
					if(attr.school) then
						attr.school = tonumber(attr.school);
					end
					if(attr.quality) then
						attr.quality = tonumber(attr.quality);
					end
					if(attr.minlel) then
						attr.minlel = tonumber(attr.minlel);
					end
					if(attr.maxlel) then
						attr.maxlel = tonumber(attr.maxlel);
					end
					attr.expanded = (attr.expanded == "true");
				end
			end
		else
			LOG.std(nil, "error", "auctionhouse", "faield to load buyer category info from file %s", filename);
		end
		AuctionHouse.auction_category_node = AuctionHouse.auction_category_node or {};
	end
	return AuctionHouse.auction_category_node;
end

-- get category list
function AuctionHouse.GetCategoryDS()
	if(not AuctionHouse.category_ds) then
		local filename = "config/Aries/NPCShop_Teen/auctionhouse_category.xml"
		local selected_attr;
			
		local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
		if(xmlRoot) then
			AuctionHouse.category_ds = xmlRoot[1];
			local node;
			for node in commonlib.XPath.eachNode(AuctionHouse.category_ds, "//item") do
				local npc_id = node.attr.npcid;
				if(type(npc_id) == "string") then
					if(not npc_id:match(",")) then
						node.attr.npcid = tonumber(npc_id);
					else
						node.attr.npcid = {};
						local npcid_;
						for npcid_ in npc_id:gmatch("(%d+)") do
							node.attr.npcid[tonumber(npcid_)] = true;
						end
					end
				end
				if(not selected_attr or node.attr.checked)then
					
					-- select the first item or the one with "checked" attribute. 
					selected_attr = node.attr;
				end
			end
		else
			LOG.std(nil, "error", "auctionhouse", "failed to load category info from file %s", filename);
		end
		AuctionHouse.category_ds = AuctionHouse.category_ds or {};
		if(selected_attr) then
			if(not selected_attr.checked) then
				selected_attr.checked = true
			end
			AuctionHouse.ChangeMarketDataSource(selected_attr);
		end
	end
	return AuctionHouse.category_ds
end

function AuctionHouse.GetCurrentPageIndex()
	return (AuctionHouse.pindex or 0);
end


-- @param goto_page: "pre", "next", "filter_changed"
function AuctionHouse.ChangeFilterDataSource(attr, bRefreshPage, goto_page)
	local params, pindex;

	if(goto_page) then
		if(goto_page == "pre") then
			if(AuctionHouse.pindex and AuctionHouse.pindex>0) then
				pindex = AuctionHouse.pindex - 1
				AuctionHouse.cur_filter_selection = nil;
			else
				return;
			end
		elseif(goto_page == "next") then
			if(AuctionHouse.pindex and AuctionHouse.is_lastpage == false) then
				pindex = AuctionHouse.pindex + 1 
				AuctionHouse.cur_filter_selection = nil;
			else
				return;
			end
		end
	else
		AuctionHouse.is_lastpage = nil;
		AuctionHouse.pindex = nil;
	end

	if(type(attr) == "string") then
		if(AuctionHouse.cur_filter_selection ~= attr or goto_page== "filter_changed") then
			AuctionHouse.cur_filter_selection = attr;
			params = {gsname=attr, pindex=pindex};
		end
	else
		if(AuctionHouse.cur_filter_selection ~= attr or goto_page== "filter_changed") then
			AuctionHouse.cur_filter_selection = attr;
			params = {gsname = attr.gsname, itemclass=attr.class, subclass=attr.subclass, pindex=pindex,
				minlel = attr.minlel,maxlel = attr.maxlel,quality=attr.quality, school=attr.school};
		else
			return;
		end
	end
	if (params) then
		AuctionHouse.has_searched = true;
		if(MyCompany.Aries.AuctionHouse.is_market) then
			--params.quality = nil;
			--params.school = nil;
			if(page) then
				local school = page:GetValue("search_school");
				local quality = page:GetValue("search_quality");
				if(quality and quality~="") then
					params.quality = tonumber(quality);
				end
				if(school and school~="") then
					params.school = tonumber(school);
				end
			end
		end

		AuctionHouse.Search(params, false, function(items)
			AuctionHouse.search_result_ds = items;
			if(bRefreshPage and page) then
				page:Refresh(0.01);
			end
		end)
	end
end

function AuctionHouse.GetAuctionQueryDS(index)
	if(AuctionHouse.search_result_ds) then
		if(index == nil) then
			return #(AuctionHouse.search_result_ds);
		else
			return AuctionHouse.search_result_ds[index];
		end
	else
		if(index == nil) then
			return 0
		end
	end
end


-- change market data source. 
-- @param attr: attributes table or string. if string it will search full text. otherwise see below
--  attr.npcid:which id can be show in npc shop.
--  attr.superclass:which superclass can be show in npc shop,default value is "menu1"
--  attr.class(optional):which class can be show in npc shop,if nil return all data.
function AuctionHouse.ChangeMarketDataSource(attr, bRefreshPage)
	if(type(attr) == "string") then
		AuctionHouse.show_list = NPCShopProvider.SearchByText(attr) or {};
		AuctionHouse.cur_selection = nil;
		if(bRefreshPage and page) then
			page:Refresh(0.01);
		end
	else
		if(AuctionHouse.cur_selection ~= attr) then
			AuctionHouse.cur_selection = attr;
			local npcid, superclass, class = attr.npcid, attr.menu, attr.class; 
			if(type(npcid) == "string") then
				npcid = tonumber(npcid);
			end
			if(attr.full_text_search) then
				AuctionHouse.show_list = NPCShopProvider.SearchByText(attr.full_text_search, superclass, class) or {};
			else
				AuctionHouse.show_list = NPCShopProvider.FindDataSource(npcid, superclass, class) or {};
			end
			if(bRefreshPage and page) then
				page:Refresh(0.01);
			end
		end
	end
end

function AuctionHouse.DS_MarketFunc(index)
	if(index == nil) then
		return #(AuctionHouse.show_list);
	else
		return AuctionHouse.show_list[index];
	end
end

-- @param price: total cost
function AuctionHouse.CalcTaxFee(price)
	AuctionHouse.commission = math.ceil(AuctionHouse.buyer_fee_percent * (price or 0));
	return AuctionHouse.commission;
end

function AuctionHouse:GetDisplayItemByID(id)
	local i,v 
	for i,v in ipairs(self.search_result_items or self.DisplayItems)do
		if(v.id == id)then
			return v;
		end
	end
end

function AuctionHouse.GenDisplayName(name,copies)
    if(not copies or copies == 1)then
        return name;
    else
        return string.format("%s X %s",name or "",copies or 1);
    end
end

function AuctionHouse.GetItemCopies(gsid)
	local has, _, _, copies = ItemManager.IfOwnGSItem(gsid);
	return copies or 0
end

function AuctionHouse:RemoveDisplayItemByID(id)
	commonlib.removeArrayItems(self.search_result_items or self.DisplayItems, function(i, v)
		return (v.id == id);
	end)
end

-- purchase item by id. 
function AuctionHouse.OnSelectAndPurchaseItem(id, callbackFunc)
	local i,v 
	for i,v in ipairs(AuctionHouse.search_result_items or AuctionHouse.DisplayItems)do
		if(v.id == id)then
			v.is_selected = true;
		else
			v.is_selected = nil;
		end
	end
	AuctionHouse.PurchaseItem({id = id}, callbackFunc);
end

-- @param params: table of {id = item_id}
-- @param callbackFunc: callbackFunc({issuccess=true}), only called when purchase succeeded. 
function AuctionHouse.PurchaseItem(params, callbackFunc)
	if(not params)then return end
	local self = AuctionHouse
	local item = self:GetDisplayItemByID(params.id);
	if(not item) then
		_guihelper.MessageBox("你选择的物品不在当前页面。");
		return 
	end
	local price = item.price or 0;
	
	
	local name_text = self.GenDisplayName(item.name, item.copies) or "";
	local money_gsid = AuctionHouse.GetCurrencyByGSID(item.gsid) or 984;

	local cost;
	if(not money_gsid or money_gsid==984) then
		cost = (AuctionHouse.CalcTaxFee(price) + price);
	else
		cost = price;
	end

	local text = string.format("确认花费%s购买【%s】？", _GetConsigName(money_gsid, cost) ,name_text)

	_guihelper.Custom_MessageBox(text,function(res) 
		if(self.GetItemCopies(money_gsid) < cost)then
			_guihelper.MessageBox(format("你的%s已不足！", _GetConsigName(money_gsid)))
			return 
		end

		if(res and res == _guihelper.DialogResult.Yes) then
			paraworld.auction.BuyFromShop(params,nil,function(msg)
				if(msg and msg.issuccess)then
					AuctionHouse:RemoveDisplayItemByID(params.id);
					MyCompany.Aries.Desktop.MapArea.CheckEmail(3000);
					_guihelper.MessageBox("购买成功，刚才购买的物品已经邮寄到你的邮箱了。");
					if(callbackFunc) then
						callbackFunc(msg);
					end
				elseif(msg.errorcode == 443)then
					_guihelper.MessageBox(format("你的%s已不足！", _GetConsigName(money_gsid)))
				else
					_guihelper.MessageBox("无法购买， 该物品可能刚刚被其他人抢购了！")
				end
			end);
		end
	end,_guihelper.MessageBoxButtons.YesNo,{show_label = true, yes = "购买", no = "取消"})
end

-- @param msg: msg returned by api
-- @param params: the input message
-- @return: the processed item array for display. Can be used for xml page source. 
function AuctionHouse:OnProcessSearchResult(msg, params)
	self.DisplayItems = {};
	local gsname = params.gsname;

	if(type(msg) == "table" and #msg > 0)then
		local i,v;

		for i,v in ipairs(msg)do
			local item = ItemManager.GetGlobalStoreItemInMemory(v.gsid);	
			local item_name = "";
			local is_selected = false;
				
			if(AuctionHouse.selected_item_id == v.id)then
				is_selected = true;
			end
			if(item)then
				item_name = item.template.name or "undefined name";
			end
			
			local qty = item.template.stats[221];

			local typ = 0;
			if(item)then
				typ = GenericTooltip.GetItemType(item.template.subclass);
			end

			local isequip = GenericTooltip:IsEquip(item);
			if(not isequip)then typ = "";qty = -1;end

			local school = "";
			local school_stats = item.template.stats[137];
			local cn_school,en_school = GenericTooltip.GetSchool(school_stats);
			local level = v.lel or item.template.stats[138] or item.template.stats[168]
			local seller = v.nname;
			if(v.nid == Map3DSystem.User.nid)then
				seller = "我自己"
			end

			local time = string.sub(v.expire,6,16)
			
			local display_price;
			local money_gsid = AuctionHouse.GetCurrencyByGSID(item.gsid);
			if(not money_gsid or money_gsid==984) then
				display_price = math.ceil(v.price*(1+AuctionHouse.buyer_fee_percent));
			else
				display_price = v.price;
			end
			local unit = display_price / v.cnt;

			local i,f = math.modf(unit);
			if(type(f) == "number" and f > 0)then
				local a = tonumber(string.sub(f,0,3));
				local b = tonumber(string.sub(f,4,4))
				if(b and b > 5)then
					a = a + .1;
				end
				
				unit = i + a;	
			end

			level = level or 0;
			if(level < 1)then level = "" end
			
			self.DisplayItems[#self.DisplayItems + 1] = {
				id=v.id, 
				gsid = v.gsid, 
				name=item_name,
				level = level, 
				nid=v.nid, 
				serverdata = v.serverdata or v.svrdata,
				price=v.price, 
				time=time, 
				nname=seller or "",
				money_gsid = money_gsid,
				showseller = v.showseller == 1,
				unformattedtime = v.expire,
				copies = v.cnt, 
				unit = unit, 
				display_price = display_price,
				qty = qty,
				is_selected=is_selected, 
				typ=typ,
				class=cn_school or "",
			};
		end	
		self.DisplayItems.refresh_time = commonlib.TimerManager.GetCurrentTime()
	end
	LOG.std(nil, "debug", "auctionhouse search result", self.DisplayItems);
	return self.DisplayItems;
end

-- @param params: {gsid, pindex, psize, quality, school}
--  gsid 物品名
--  pindex 页码
--  psize 每页的数据量
-- [ minlel ] 最小等级
-- [ maxlel ] 最大等级
-- [ quality ] 品质
-- [ gsname ] 物品名
-- @param bIsSearchByMe: whether to search items only by me. 
function AuctionHouse.Search(params, bIsSearchByMe, callbackFunc)
	local self = AuctionHouse
	params.pindex = params.pindex or 0;
	
	AuctionHouse.pindex = params.pindex;

	local function OnFinished(msg)
		-- echo(msg)
		local items = AuctionHouse:OnProcessSearchResult(msg, params);
		if(callbackFunc) then
			callbackFunc(items);
		end
		if(not bIsSearchByMe) then
			AuctionHouse.search_result_items = items;
		end
	end

	if(not bIsSearchByMe) then
		if(params.gsid) then
			params.psize = params.psize or PAGE_SIZE_PURCHASE;
			paraworld.auction.GetInShop(params,nil,OnFinished, nil, 20000, function(msg)
				OnFinished();-- timeout request
			end);
		else
			params.psize = params.psize or PAGE_SIZE_PURCHASE;
			paraworld.auction.SearchFromShop(params,nil,function(msg) 
				if(type(msg) == "table")then
					if(#msg < params.psize)then
						AuctionHouse.is_lastpage = true;
					else
						AuctionHouse.is_lastpage = false;
					end	
					OnFinished(msg);
				else
					_guihelper.MessageBox("没有搜索到你需要的物品.");
				end
			end, nil, 20000, function(msg)
				OnFinished();-- timeout request
			end);
		end
	else
		params.psize = params.psize or AuctionHouse.GetMaxSellingItemCount();
		paraworld.auction.GetInShopByMe(params,nil,OnFinished, nil, 20000, function(msg)
			OnFinished();-- timeout request
		end);
	end
end

local results = {};

-- data source function for a given gsid. 
-- internally it will prevent successive calls. 
-- @param gsid: if number it will search for a given gsid. if "my_selling_item", it will search for my own selling items. 
-- @param bForceRefresh: true to force refresh
function AuctionHouse.GetItemDataSource(gsid, index, bForceRefresh)
	if(not gsid) then 
		return;
	end
	local ds;
	results[gsid] = results[gsid] or {};
	results[gsid][AuctionHouse.pindex] = results[gsid][AuctionHouse.pindex] or {};
	local ds = results[gsid][AuctionHouse.pindex];
	local need_refresh;
	local cache_time_ms = if_else(gsid == "my_selling_item", 100000, 5000);
	if( not ds.is_fetching and (bForceRefresh or (commonlib.TimerManager.GetCurrentTime() - (ds.refresh_time or -cache_time_ms)) > cache_time_ms) ) then
		need_refresh = true;
	end
	
	if(ds and not ds.is_fetching and not need_refresh) then
		if(not index) then
			return #ds;
		else
			return ds[index];
		end
	end
	if(not ds.is_fetching) then
		ds.is_fetching = true;
		if(type(gsid) == "number") then
			AuctionHouse.Search({gsid = gsid, pindex = AuctionHouse.pindex}, false, function(items)
				ds.is_fetching = nil;
				if(AuctionHouse.item_view_page and items) then
					items.refresh_time = commonlib.TimerManager.GetCurrentTime();
					results[gsid][AuctionHouse.pindex] = items;
					if(AuctionHouse.item_view_page) then
						AuctionHouse.item_view_page:Refresh(0.1);
					end
				end
			end);
		elseif(gsid == "my_selling_item") then
			AuctionHouse.Search({pindex = AuctionHouse.pindex}, true, function(items)
					ds.is_fetching = nil;
					if(page and items) then
						items.refresh_time = commonlib.TimerManager.GetCurrentTime();
						results[gsid][AuctionHouse.pindex] = items;
						if(page) then
							page:Refresh(0.1);
						end
					end
				end);
		end
	end
end


-- cancel selling a given item. 
function AuctionHouse.CancelSell(auction_id)
	paraworld.auction.CancelSell({id = auction_id},nil,function(msg)
		if(msg and msg.issuccess)then
			-- refresh page
			AuctionHouse.GetItemDataSource("my_selling_item", 0, true);
			page:Refresh();
			MyCompany.Aries.Desktop.MapArea.CheckEmail(3000);
			_guihelper.MessageBox("物品已经成功取消寄售，并通过邮件退回了你的背包, 请查收.");
		elseif(msg.errorcode == 497)then
			_guihelper.MessageBox("该物品已经不存在了.");
		elseif(msg.errorcode == 438)then
			_guihelper.MessageBox("你不能取消这个物品的寄售.");
		end
	 end);
end

function AuctionHouse.GetMaxSellingItemCount()
	return 10 + MyCompany.Aries.Player.GetVipLevel()*5;
end

function AuctionHouse.OnClickSell()
	if(not page) then 
		return
	end
	local gsid = AuctionHouse.goods.gsid;
	if(not gsid or gsid == -999)then 
		_guihelper.MessageBox("请先放入要寄售的物品！");
		return 
	end
	local money_gsid = AuctionHouse.GetCurrencyByGSID(gsid);

	local sell_price = tonumber(page:GetValue("txtSellPrice")) or 0;
	AuctionHouse.goods.price = sell_price;

    if((not money_gsid or money_gsid == 984) and AuctionHouse.CheckPriceRange and AuctionHouse.goods.item) then
		-- 0.5 percent of the fee is min price
		local copies = AuctionHouse.goods.copies;
        local min_sell_price = AuctionHouse.goods.item.count*0.5;
		local max_sell_price = AuctionHouse.goods.item.count*10;
        if(sell_price < min_sell_price*copies) then
            page:SetValue("txtSellPrice", tostring(min_sell_price*copies));
			_guihelper.MessageBox(format("物品单价不能低于%d%s", min_sell_price, System.options.haqi_RMB_Currency));
			return
		elseif(sell_price > max_sell_price*AuctionHouse.goods.item.count) then
			page:SetValue("txtSellPrice", tostring(max_sell_price*copies));
			_guihelper.MessageBox(format("物品单价不能高于%d%s", max_sell_price, System.options.haqi_RMB_Currency));
			return
        end
    end

	local showseller = if_else(page:GetValue("IsShowSellerName"), 0, 1);

	if(AuctionHouse.goods.price == 0)then 
		_guihelper.MessageBox("无效的卖价，价格是大于0的数字！");
		return;
	end
	local agent_fee = AuctionHouse.GetAgentFee(AuctionHouse.goods.expire);
	if(AuctionHouse.GetItemCopies(0) < agent_fee)then 
		_guihelper.MessageBox("你的银币不足以支付寄售费!");
		return 
	end

	local nMySellingItemCount = AuctionHouse.GetItemDataSource("my_selling_item", nil) or 0;
	local max_selling_item_count = AuctionHouse.GetMaxSellingItemCount();
	if(nMySellingItemCount >= max_selling_item_count) then
		_guihelper.MessageBox(format("您最多只能同时寄售%d件物品, 魔法星等级越高能寄售的物品越多. 您需要取消寄售一些物品，才能寄售新的物品.", max_selling_item_count));
		return;
	end

	
	local text;
	if(not money_gsid or money_gsid == 984) then
		text = string.format("你确定以%s%s寄售物品【%s】么？<br/>（注：寄售%s天， 寄售费%s银币）成交手续费%d%%",
			AuctionHouse.goods.price, System.options.haqi_RMB_Currency,  _GetConsigName(AuctionHouse.goods.gsid,AuctionHouse.goods.copies),
			AuctionHouse.goods.expire, agent_fee,  math.ceil(AuctionHouse.GetSellerFee()*100));
	elseif(money_gsid) then
		text = string.format("你确定以%s, 寄售物品【%s】么？<br/>（注：寄售%s天， 寄售费%s银币）成交无手续费",
			_GetConsigName(money_gsid,AuctionHouse.goods.price),_GetConsigName(AuctionHouse.goods.gsid,AuctionHouse.goods.copies),
			AuctionHouse.goods.expire, agent_fee);
	end
	_guihelper.MessageBox(text, function(result)
			if(_guihelper.DialogResult.Yes == result) then
			
				local expire = tonumber(AuctionHouse.goods.expire) * 24;

				local price = AuctionHouse.goods.price;

				if(not money_gsid or money_gsid == 984) then
					price = math.floor(price/(1+AuctionHouse.buyer_fee_percent))
					while(math.ceil(price*(1+AuctionHouse.buyer_fee_percent)) < AuctionHouse.goods.price) do
						price = price + 1;
					end
				end

				local params = {guid=AuctionHouse.goods.guid,
					cnt=AuctionHouse.goods.copies,expire= expire,
					showseller = showseller,price=price};

				paraworld.auction.AppendToShop(params,nil,function(msg)  
					if(msg and msg.issuccess)then
						AuctionHouse.goods.copies = 0
						AuctionHouse.goods.guid=0
						AuctionHouse.goods.gsid=-999
						AuctionHouse.goods.price=0
						AvatarBag.ResetStates();

						-- refresh page
						AuctionHouse.GetItemDataSource("my_selling_item", 0, true);
						page:Refresh();
						
					elseif(msg.errorcode == 438)then
						_guihelper.MessageBox("该物品不可出售.");
					elseif(msg.errorcode == 411)then
						--411:E币不足
						_guihelper.MessageBox("你的奇豆不够了哦.");
					else
						_guihelper.MessageBox("你寄售物品的数量与实际拥有的数量不同.");
					end
		
				end);
				
			end
		end, _guihelper.MessageBoxButtons.YesNo);

end

-- @param point: {x,y,z, worldname, displayname}
function AuctionHouse.OnTrackPoint(point)
	if(point and point.x) then
		local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
		local QuestPathfinderNavUI = commonlib.gettable("MyCompany.Aries.Quest.QuestPathfinderNavUI");
        
		local worldInfo = WorldManager:GetWorldInfo(point.worldname)

		if(WorldManager:IsInstanceWorld(point.worldname)) then
			NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClientServicePage.lua");
			local LobbyClientServicePage = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClientServicePage");
			LobbyClientServicePage.DoAutoJoinRoom(point.worldname);
		else
			local params = {
				x = point.x,
				y = point.y,
				z = point.z,
				worldInfo = worldInfo,
				radius = 4,
				targetName = point.displayname,
			}
			QuestPathfinderNavUI.RefreshPage(true);
			QuestPathfinderNavUI.SetTargetQuest(params)
		end
	end
end

-- whether the given item can be sold in auction house. 
-- @param gsItem: gsid or gsItem.
function AuctionHouse.CanExchange(gsItem)
	-- gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(AuctionHouse.IsEnabled and gsItem and gsItem.template and gsItem.template.canexchange and gsItem.template.cangift) then
		local class = gsItem.template.class;
		local subclass = gsItem.template.subclass;
		--if(class == 18 and ( subclass == 1 or subclass == 2)) then
			-- in current version, only card can be exchanged in auction house
			return true;
		-- end
    end
end

function AuctionHouse.GetAuctionFeeByGSID(gsid, days)
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(gsItem) then
		local class = gsItem.template.class;
		local subclass = gsItem.template.subclass;
		if(class == 18 and ( subclass == 1 or subclass == 2)) then
			local quality = gsItem.template.stats[221];
			local money = 1000;
			if(quality == 1) then
				money = 1000;
			elseif(quality == 2) then
				money = 3000;
			elseif(quality == 3) then
				money = 5000;
			end
			return money* (days or 1);
		end
	end
end

local function HasMerchant(npcid)
    if(npcid and npcid>0) then
        local npc, worldname = NPCList.GetNPCByIDAllWorlds(npcid);
        if(npc and npc.name) then
            return true;
        end
    end
end

local function GetExidMoney(exid, index, is_selling)
    if(not exid)then return end
    index = index or 1;
    local exTemplate = ItemManager.GetExtendedCostTemplateInMemory(exid);
    if(exTemplate and exTemplate.froms and exTemplate.tos)then
        
        local node = if_else(is_selling, exTemplate.tos[index], exTemplate.froms[index]);
        if(node)then
            --if(node.key ~= 984)then
                local label;
                local gsItem = ItemManager.GetGlobalStoreItemInMemory(node.key);
                if(gsItem) then
                    label = gsItem.template.name;
                elseif(node.key == 0 or node.key == 1) then
                    label = "银币";
                end
                return string.format([[
<pe:item is_container="true" isclickable="false" gsid='%d' style="float:left;width:130px;margin-top:2px;height:20px" >
    <pe:item gsid='%d' isenabled="false" style="width:20px;height:20px;"/>
    <div style="float:left;margin-left:2px;">%s:</div><pe:slot type="count" gsid='%s' style="float:left" />
</pe:item>]], node.key, node.key, label or "", node.key);
            --end
        end
    end
end

local function GetLine(exid,index, is_selling, gsItem)
    if(not exid or not index)then return end
    local exTemplate = ItemManager.GetExtendedCostTemplateInMemory(exid);
    if(exid == 0) then 
        if(index==1 and gsItem) then
            local price = gsItem.ebuyprice;
            local pbuyprice = gsItem.count;
            
            if(price and price>0) then
                local s = string.format([[<img tooltip="银币" class="stable_bean" style="margin-top:2px;width:20px;height:20px;"/><div style="float:left;margin-left:2px;">%d</div>]],price);
                return s;
            elseif(pbuyprice and pbuyprice>0) then
				local orgmodou = gsItem.template.stats[50];
				local s = "";
				if (orgmodou) then					
					s = string.format([[<pe:item gsid="984" isclickable="false" style="width:20px;height:20px;"/>
					<div style="position:relative;margin-left:47px;margin-top:-46px;width:47px;height:46px;background:url(Texture/Aries/HaqiShop/cuxiao_32bits.png#0 0 47 46);" />
                    <div style="position:relative;margin-left:25px;margin-top:-13px;width:40px;height:2px;background:url(Texture/Aries/HaqiShop/line1.png#0 0 2 2);background-rotation:0.1;" />                        
					<div style="position:relative;margin-left:30px;margin-top:-20px;">%d<br />%d</div>]],orgmodou,pbuyprice);
				else
					s = string.format([[<pe:item gsid="984" isclickable="false" style="width:20px;height:20px;"/><div style="float:left;margin-left:2px;">%d</div>]],pbuyprice);
				end
                return s;
            end
        end
    elseif(exTemplate and exTemplate.froms and exTemplate.tos)then
        local node = if_else(is_selling, exTemplate.tos[index], exTemplate.froms[index]);
        if(node)then
            local name = "";
            local value = node.value or 0;
            local gsid = node.key;
            local _gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
            local assetfile = "";
            if(_gsItem)then
		        name = _gsItem.template.name;
		        assetfile = _gsItem.icon or "";
            end
            if(node.key == 0)then
                name = "银币";
                local s = string.format([[<img tooltip="银币" class="stable_bean" style="margin-top:2px;width:20px;height:20px;"/><div style="float:left;margin-left:2px;">%d</div>]],value);
                return s;
            elseif(node.key == -1)then
                name = "普通银币";
            elseif (node.key == 984 and gsItem) then
				local orgmodou = gsItem.template.stats[50];
				local pbuyprice = value;
				local s = "";
				if (orgmodou) then					
					s = string.format([[<pe:item gsid="984" isclickable="false" style="width:20px;height:20px;"/>
					<div style="position:relative;margin-left:47px;margin-top:-46px;width:47px;height:46px;background:url(Texture/Aries/HaqiShop/cuxiao_32bits.png#0 0 47 46);" />
                    <div style="position:relative;margin-left:25px;margin-top:-13px;width:40px;height:2px;background:url(Texture/Aries/HaqiShop/line1.png#0 0 2 2);background-rotation:0.1;" />                        
					<div style="position:relative;margin-left:30px;margin-top:-20px;">%d<br />%d</div>]],orgmodou,pbuyprice);
				else
					s = string.format([[<pe:item gsid="984" isclickable="false" style="width:20px;height:20px;"/><div style="float:left;margin-left:2px;">%d</div>]],pbuyprice);
				end
				return s;
			else
                local s = string.format([[<pe:item gsid="%d" isclickable="false" style="width:20px;height:20px;"/><div style="float:left;margin-left:2px;">%d</div>]],gsid or 0,value);
                return s;
            end
    	    
            local s = string.format([[<img tooltip="%s" style="margin-top:2px;width:20px;height:20px;background:url(%s)"/><div style="float:left;margin-left:2px;">%d</div>]],name,assetfile,value);
            --local s = string.format("%s:%d",name,value);
            return s;
        end
    end
end

local function IsRightSchool(gsid)
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
    if(gsItem)then
		local school_id = gsItem.template.stats[137] or gsItem.template.stats[246];
        if(school_id)then
            return CommonClientService.IsRightSchool(gsid, nil, nil, school_id);
        end
    end
    return true;
end

local function OnBuyFromNPC(gsid, exid, npcid, time_range)
    if(gsid and exid) then
        --if(npcid and npcid>0) then
            --local result = WorldManager:TrackAndGotoNPC(npcid, function()
                --MyCompany.Aries.Desktop.Dock.ShowHideAllWindow(false);
            --end);
            --if(result) then
                --return
            --end
        --end

        if(time_range and time_range ~= "") then
            local time_range = commonlib.timehelp.datetime_range:new(time_range);
            local seconds, min, hour, day, month, year = MyCompany.Aries.Scene.GetServerDateTime();
            if(time_range and not time_range:is_matched(min, hour, day, month, year)) then
                _guihelper.MessageBox(format("促销活动已经下架. 活动时间为: <br/>%s", time_range:tostring()));
                return;
            end
        end

        if(exid ~= 0) then
	        if(not NPCShopProvider.PreCheckByGsid(gsid) or not NPCShopProvider.PreCheckByExid(exid,1))then
		        return
	        end
        end
        local command = System.App.Commands.GetCommand("Profile.Aries.PurchaseItemWnd");
		if(IsRightSchool(gsid)) then
            command:Call({exid = exid, gsid = gsid, npc_shop = true});
        else
            _guihelper.MessageBox("你所购买的物品，不适合你的系别使用. 是否还要买?", function()
                command:Call({exid = exid, gsid = gsid, npc_shop = true});
            end, _guihelper.MessageBoxButtons.YesNo)
        end
    end
end

function AuctionHouse.GetFirstShopItem(gsid)
	gsid = tonumber(gsid);
    local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	local text;
	if(gsItem) then
		if(gsItem.npc_shop_items) then
			return gsItem.npc_shop_items[1], gsItem;
		end
	end
end

--[[
 在npcshop的xml配置文件中如果一个物品同时出现在npc和商城中，商城要排在前面，如下：

 81018		    符文	烈火	23319	1180		                        （商城）
 31038	menu1	fire	烈火	23319	1037	0#17227#984	-1               （npcshop）

--]]
function AuctionHouse.FindExidByShowList(gsid)
	local k,v;
	for k,v in ipairs(AuctionHouse.show_list) do
		if (v.gsid == gsid )then
			return v.exid;
		end
	end
	return nil
end

function AuctionHouse.GetPricingMCMLText(gsid)	
	local item, gsItem = AuctionHouse.GetFirstShopItem(gsid)
	local exid = nil;
	if (not AuctionHouse.is_market) then
		exid = AuctionHouse.FindExidByShowList(gsid)
		if (exid == -1 and item)then
			exid = item.exid
		end
	elseif (item) then
		exid = item.exid
	end
	if(exid) then
		local text = format([[<div style="height:24px;">%s%s</div>]], GetLine(exid,1, nil, gsItem) or "", GetLine(exid,2, nil, gsItem) or "")
		return text;
	end
end

function AuctionHouse.OnClickBuyItem(gsid)
	gsid = tonumber(gsid);
	local item = AuctionHouse.GetFirstShopItem(gsid)
	if(item) then
		OnBuyFromNPC(gsid, item.exid, item.npcid, item.time_range);
	end
end

-- in most case it is 984
function AuctionHouse.GetCurrencyByGSID(gsid)
	if(not gsid or gsid<=0) then
		return 984;
	end

	-- for all tradable objects, use 984
	do 
		return 984;
	end

	-- OBSOLETED: for different card of cards, we allow different currency:
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(gsItem and gsItem.template and gsItem.template.canexchange and gsItem.template.cangift) then
		local class = gsItem.template.class;
		local subclass = gsItem.template.subclass;
		if(class == 18 and ( subclass == 1 or subclass == 2)) then
			local quality = gsItem.template.stats[221];
			local money_gsid;
			if(quality == 1) then
				money_gsid = 17264;
			elseif(quality == 2) then
				money_gsid = 17290;
			elseif(quality == 3) then
				money_gsid = 17291;
			end
			return money_gsid;
		else
			-- main currency
			return 984;
		end
	end
end

