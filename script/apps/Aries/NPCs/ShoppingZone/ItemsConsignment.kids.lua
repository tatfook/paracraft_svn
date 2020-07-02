--[[
Title: 
Author(s): WD
Date: 2011/11/18
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/ItemsConsignment.kids.lua");
MyCompany.Aries.NPCs.ShoppingZone.ItemsConsignment.ShowPage();
------------------------------------------------------------
]]

NPL.load("(gl)script/ide/timer.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/API/ParaworldAPI.lua");
NPL.load("(gl)script/apps/Aries/Desktop/GenericTooltip.lua");
NPL.load("(gl)script/apps/Aries/Desktop/AvatarBag.lua");


NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/ItemsFilter.lua");
local ItemsFilter = commonlib.gettable("MyCompany.Aries.NPCs.ShoppingZone.ItemsFilter");
local NotificationArea = commonlib.gettable("MyCompany.Aries.Desktop.NotificationArea");
local GenericTooltip = CommonCtrl.GenericTooltip:new();

local AvatarBag = commonlib.gettable("MyCompany.Aries.Desktop.AvatarBag");
local ItemsConsignment = commonlib.gettable("MyCompany.Aries.NPCs.ShoppingZone.ItemsConsignment");
local Avatar_gems_subpage = commonlib.gettable("MyCompany.Aries.NPCs.ShoppingZone.Avatar_gems_subpage");
local Player = commonlib.gettable("MyCompany.Aries.Player");
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
local hasOPCGSItem = ItemManager.IfOPCOwnGSItem;
local equipOPCGSItem = ItemManager.IfOPCEquipGSItem;
local getItemByGsid = ItemManager.GetGlobalStoreItemInMemory;

local MSG = _guihelper.MessageBox;
local echo = commonlib.echo;
local table_insert = table.insert;

local COMMISSION_FACTOR  = 0.2
local PAGE_SIZE_PURCHASE = 11
local PAGE_SIZE_SELL = 10;

ItemsConsignment.filter = ItemsConsignment.filter or 0;
ItemsConsignment.goods = {};
ItemsConsignment.DisplayItems = {};
ItemsConsignment.pindex = 0;

ItemsConsignment.MiddlePriceTable = {[3] = 300,[5] = 700,[7] = 1100,};

local function GetMiddlePrice(arg)
	return ItemsConsignment.MiddlePriceTable[arg];
end

ItemsConsignment.QtyTable = {
{value="----- 所有 -----",selected = true,},
--{value="普通",selected = false,},
--{value="精良",selected = false,},
--{value="卓越",selected = false,},
--{value="极品",selected = false,},
};

ItemsConsignment.TimePeriodTable = {
{value="3",selected = true,},
{value="5",selected = false,},
{value="7",selected = false,},
};

ItemsConsignment.InfoTable = {
{value="显示自己姓名",selected = false,},
{value="不透露自己姓名",selected = true,},};

local seed = math.seed;
local random = math.random;

local WHITE = "#ffffff";
local BLUE = "#0099ff";
local GREEN = "#00cc33";
local PURPLE = "#c648e1";
local YELLOW = "#ff9a00";
local RED = "#ff0000";
local GRAY = "fcf5bd";
local CURRENT_EQUIP_COLOR = "#fcf776";
local EQUIP_STATS_COLOR = "#f0a607";
local LIMITED_COLOR = "#da0202";
local DEFAULT_COLOR = "#52dff4";

function ItemsConsignment:Init()
	self.page = document:GetPageCtrl();
	if(self.GetGoldBean)then
	self.HoldGoldBean = self.GetGoldBean();--MyCompany.Aries.Player.GetMyJoybeanCount();
	end

	if(AvatarBag.Items and #AvatarBag.Items > 0)then
		self.goods.gsid =AvatarBag.Items[1].gsid
		self.goods.guid = AvatarBag.Items[1].guid;
		self.goods.copies = AvatarBag.Items[1].copies;
		--self.page:SetValue("incomingItem",self.goods.guid);
		self.goods.item = getItemByGsid(self.goods.gsid);
		if(not ItemsConsignment.goods.expire and not ItemsConsignment.page:GetValue("txtCommission"))then
			ItemsConsignment.goods.expire = ItemsConsignment.TimePeriodTable[1].value;
		end
		ItemsConsignment.goods.expire = ItemsConsignment.goods.expire or ItemsConsignment.TimePeriodTable[1].value;
		ItemsConsignment.page:SetValue("txtCommission",(ItemsConsignment.goods.expire))
		--echo("+++++++++++++++++begin self.goods++++++++++++++")
		--echo(self.goods);
		--echo("+++++++++++++++++end self.goods++++++++++++++")
	end

	-- self.page:SetValue("incomingItem",self.goods.gsid or 0);
end

function ItemsConsignment.GetGoldBean()
	local hasGold, _, _, my_gold_count = hasGSItem(17213);
	if(hasGold and my_gold_count)then
		return my_gold_count;
	end
	return 0
end

function ItemsConsignment.Id(arg)
	if(arg)then
		ItemsConsignment.id = tonumber(arg);
	else
		return ItemsConsignment.id;
	end
end
function ItemsConsignment.Filter(arg)
	arg = tonumber(arg);

	if(ItemsConsignment.filter == arg)then return end
	ItemsConsignment.filter = arg
	ItemsConsignment.is_lastpage = false;
	ItemsConsignment.DisplayItems = {}
	ItemsConsignment.id = nil;
	ItemsConsignment.pindex = 0;

	if(arg == 0 )then
		MyCompany.Aries.Desktop.AvatarBag.Visible = false;
		if(ItemsConsignment.goods.guid ~= 0 or ItemsConsignment.goods.guid)then
			MyCompany.Aries.Desktop.AvatarBag:RemoveItem(ItemsConsignment.goods.guid);
			ItemsConsignment.goods.copies = 0;
			ItemsConsignment.goods.guid = 0
			ItemsConsignment.goods.gsid = 0
		end
	else
		ItemsFilter:Clean()
		ItemsConsignment.GetInShopByMe({nid=nil,pindex=0,psize =PAGE_SIZE_SELL});
	end
	ItemsConsignment:Refresh()
end 

function ItemsConsignment.GetName()
	--local equip_color = DEFAULT_COLOR or "#52dff4";
	local self = ItemsConsignment
	local item_name = "";
	if(self.goods.gsid and self.goods.gsid ~= 0)then
		--self.quality = self.goods.item.template.stats[221] or -1;
		--if(self.quality == 0)then
			--equip_color = WHITE;
		--elseif(self.quality == 1)then
			--equip_color = GREEN;
		--elseif(self.quality == 2)then
			--equip_color = BLUE;
		--elseif(self.quality == 3)then
			--equip_color = PURPLE;
		--elseif(self.quality == 4)then
			--equip_color = YELLOW;
		--end

		item_name = self.goods.item.template.name or "undefined name";
	end

	return string.format([[<div>%s</div>]],item_name);
end

function ItemsConsignment.ShowPage()
	NPL.load("(gl)script/apps/Aries/mcml/pe_goal_pointer.lua");
	local goal_manager = commonlib.gettable("MyCompany.Aries.mcml_controls.goal_manager");
	goal_manager.finish("open_auctionhouse");

	if(System.options.disable_trading) then
		_guihelper.MessageBox("因个人账户安全原因，物品交换/邮件系统进行维护。预计将在下次更新后修复功能，若提前恢复交易功能不做另行通知。");
		return;
	end

	NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
	local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
	local can_pass = DealDefend.CanPass(function()
		ItemsConsignment.ShowPage(tabName);
	end);
	if(not can_pass)then return end

	--make sure the value of width and height is copy from design page
	local width,height = 790,490;

	local params = {
        url = "script/apps/Aries/NPCs/ShoppingZone/ItemsConsignment.kids.html", 
        app_key = MyCompany.Aries.app.app_key, 
        name = "ItemsConsignment.ShowPage", 
    isShowTitleBar = false,
    DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
    style = CommonCtrl.WindowFrame.ContainerStyle,
	enable_esc_key = true,
    allowDrag = true,
	isTopLevel = true,
    directPosition = true,
    align = "_ct",
    x = -width * .5,
    y = -height * 0.5,
    width = width,
    height = height,}
	System.App.Commands.Call("File.MCMLWindowFrame", params);


	if(params._page)then
		params._page.OnClose = ItemsConsignment.Clean;
	end


end

function ItemsConsignment.OnClickItem(arg)
	local gsid = ItemsConsignment.goods.gsid
	ItemsConsignment.goods = {copies = 0,guid=0,gsid=0}
	MyCompany.Aries.Desktop.AvatarBag:RemoveItem(gsid);
end

function ItemsConsignment.OnSelectRow(arg)
	arg = tonumber(arg)
	ItemsConsignment.Id(arg);
	local i,v 
	for i,v in ipairs(ItemsConsignment.DisplayItems)do
		if(v.id == arg)then
			v.is_selected = true;
			if(ItemsConsignment.filter == 0)then
				ItemsConsignment.CalcCommission(v.price)
			end
		else
			v.is_selected = false;
		end
	end
	ItemsConsignment:Refresh();
	if(ItemsConsignment.filter == 0)then
		ItemsConsignment.Buy(true)
	end
end

function ItemsConsignment.GetMagicBean()
    local __,__,__,copies = hasGSItem(984);
    copies = copies or 0;
    return copies;
end

-- @param arg: "0" previous page, "1" next page, "btnSearch" search again from first page. 
-- @param bIgnoreTextSearch: true to ignore text search. 
function ItemsConsignment.Search(arg, bIgnoreTextSearch)
--[[
///     [ minlel ] 最小等级
///     [ maxlel ] 最大等级
///     [ quality ] 品质
///     [ gsname ] 物品名
///     pindex 页码
///     psize 每页的数据量
]]
	local minlel,maxlel,name,quality
	local self = ItemsConsignment
	if(not ItemsConsignment.page) then
		return
	end
	if(arg == "btnSearch")then
		ItemsConsignment.pindex = 0;
		--ItemsConsignment.prev_call = "SearchFromShop"
	elseif(arg == "0")then
		local txtName = ItemsConsignment.page:FindControl("txtName")
		if(txtName and txtName.text == "" and #self.DisplayItems == 0 and ItemsConsignment.pindex == 0)then
			MSG("在进行翻页之前，请先搜索物品。");return 
		elseif(#self.DisplayItems == 0 and ItemsConsignment.pindex ==0 and ItemsConsignment.filter == 1)then
			MSG("你还没有寄售物品哦。");return 
		--elseif(#self.DisplayItems == 0 and ItemsConsignment.pindex > 0)then
			--MSG("请翻前一页。");return 
		elseif(#self.DisplayItems > 0 and ItemsConsignment.pindex ==0)then 
			MSG("已经是第一页啦。");return 
		end

		ItemsConsignment.pindex = ItemsConsignment.pindex - 1;
	elseif(arg == "1")then
		local txtName = ItemsConsignment.page:FindControl("txtName")
		if(txtName and txtName.text == "" and #self.DisplayItems == 0 and ItemsConsignment.pindex == 0)then
			MSG("在进行翻页之前，请先搜索物品。");return 
		elseif(#self.DisplayItems == 0 and ItemsConsignment.pindex == 0 and ItemsConsignment.filter == 1)then
			MSG("你还没有寄售物品哦。");return 
		elseif(#self.DisplayItems == 0 and ItemsConsignment.pindex > 0)then
			MSG("请翻前一页。");return 
		elseif(ItemsConsignment.is_lastpage and ItemsConsignment.pindex > 0)then 
			MSG("已经翻到最后一页啦。");return 
		elseif(ItemsConsignment.pindex == 0 and #self.DisplayItems> 0 and ItemsConsignment.is_lastpage)then
			MSG("只有一页数据哦。");return 
		end
		ItemsConsignment.pindex = (ItemsConsignment.pindex or 0) + 1;		
	end

	if(ItemsConsignment.filter == 0)then
		-- all shop items by everyone
		if(bIgnoreTextSearch) then
			self.page:SetValue("txtName", "");
		else
			local txtName = ItemsConsignment.page:FindControl("txtName")
			if(txtName and txtName.text ~= "")then
				name = txtName.text;
				self.page:SetValue("txtName", name);
			end
		end
		ItemsConsignment.SearchFromShop({minlel = minlel,maxlel = maxlel,
			itemclass = if_else(name==nil, ItemsFilter.class, nil),
			subclass = if_else(name==nil, ItemsFilter.subclass, nil),
			quality = if_else(name==nil, ItemsFilter.quality, nil),
			gsname = name or ItemsFilter.keywords,
			pindex = ItemsConsignment.pindex,psize=PAGE_SIZE_PURCHASE},ItemsFilter.vars);
		--[[
		if(name and name ~= "")then
			self.page:SetValue("txtName", name)
		else
			self.page:SetValue("txtName", "")
		end
		
		if(minlel and minlel ~= "")then
		self.page:SetValue("txtMinLevel",minlel)
		else
		self.page:SetValue("txtMinLevel","")
		end
		if(maxlel and maxlel ~= "")then
		self.page:SetValue("txtMaxLevel",maxlel)
		else
		self.page:SetValue("txtMaxLevel","")
		end
		]]
	elseif(ItemsConsignment.filter == 1) then
		-- only items by myself
		ItemsConsignment.GetInShopByMe({nid=nil,pindex=ItemsConsignment.pindex,psize =PAGE_SIZE_SELL});
	end
end     

function ItemsConsignment.OpenSpecifiedItem(...)
	local priID,secID = ...;
	if(priID == nil or tonumber(priID) == nil) then
		LOG.std(nil,"error","ItemsConsignment","the specified primaryItem is nil");
		return;
	end
	priID = tonumber(priID);
	if(secID ~= nil and tonumber(secID) ~= nil) then
		secID = tonumber(secID);
	end
	local t;
	if(secID ~= nil) then
		if(ItemsFilter.filter_list[priID] and ItemsFilter.filter_list[priID][secID]) then
			t = ItemsFilter.filter_list[priID][secID]["attr"];
		end
	else
		if(ItemsFilter.filter_list[priID]) then
			t = ItemsFilter.filter_list[priID]["attr"];
		end
	end
	ItemsConsignment.ShowPage();
	if(t ~= nil) then
		ItemsFilter:OnClickItem(t);
	end
end
--[[
function ItemsConsignment.OnSelectQty(ctrl)
	local self = ItemsConsignment;
	local ddlQty = self.page:FindControl("ddlQty");

	if(ddlQty and ddlQty.GetValue)then
		local value = ddlQty:GetValue();

		local i,v;
		for i,v in ipairs(self.QtyTable)do
			if(v.value == value)then
				v.selected = true;
			else
				v.selected = false;
			end
		end
	end
end
]]

function ItemsConsignment.CheckUnValidChars(ctrl)
	local ctrl = ItemsConsignment.page:FindControl(ctrl);
    if(not tonumber(ctrl.text) and ctrl.text ~= "")then
		ctrl.text = (ctrl.text or ""):match("%d+");
		ItemsConsignment.page:SetValue(ctrl,ctrl.text)
        -- _guihelper.MessageBox("无效的输入.");
		return;
    end
	-- ItemsConsignment.page:SetValue(ctrl,ctrl.text)
end

function ItemsConsignment.OnPressMinLevel(ctrl)
	ItemsConsignment.CheckUnValidChars(ctrl)
end

function ItemsConsignment.OnPressMaxLevel(ctrl)
	ItemsConsignment.CheckUnValidChars(ctrl)
end

function ItemsConsignment.Buy(arg)

	if(ItemsConsignment.id == nil)then MSG("请先选择寄售中的物品，再购买它！"); return end

	ItemsConsignment.BuyFromShop({id=ItemsConsignment.Id()})
end

function ItemsConsignment:RemoveItemByID(id)
	local i,v 
	for i,v in ipairs(ItemsConsignment.DisplayItems)do
		if(v.id == id)then
			table.remove(ItemsConsignment.DisplayItems,i)
			self:Refresh();
			break;
		end
	end

end


function ItemsConsignment.CancelSell()
	if(ItemsConsignment.id == nil)then MSG("选择已经寄售的物品,才能取消哦！"); return end
	ItemsConsignment._CancelSell({id=ItemsConsignment.Id()})
end

local function _GetConsigName(gsid,cnt)
	local name = AvatarBag:getItemName(ItemsConsignment.goods.gsid);
	if(not cnt or cnt < 2)then
		return name
	else
		return string.format("%s X %s",name,cnt);
	end
end


function ItemsConsignment.BeginSell()
	if(not ItemsConsignment.goods.gsid or ItemsConsignment.goods.gsid == 0)then MSG("请先放入要寄售的物品！");return end

	if( not ItemsConsignment.goods.price)then MSG("你还没有写入卖价！"); return end
	if(ItemsConsignment.goods.price == 0 or not tonumber(ItemsConsignment.goods.price))then MSG("无效的卖价，价格是数字而且应该大于0！");return end

	if(ItemsConsignment.GetGoldBean() < (tonumber(ItemsConsignment.goods.expire) or 0))then MSG("你的仙豆不足以支付寄售费!"); return end


	_guihelper.MessageBox(string.format("你确定以%s魔豆寄售物品【%s】么？（注：寄售%s天， 寄售费%s仙豆）",
	ItemsConsignment.goods.price,_GetConsigName(ItemsConsignment.goods.gsid,ItemsConsignment.goods.copies),
	ItemsConsignment.goods.expire,
	ItemsConsignment.goods.expire), function(result)
		if(_guihelper.DialogResult.Yes == result) then
			local i,v,showseller;
			showseller = 0;
			for i,v in ipairs(ItemsConsignment.InfoTable)do
				if(v.selected)then
					if(i == 1)then
						showseller = 1;
					else

					end
					break;
				end
			end

			local expire = tonumber(ItemsConsignment.goods.expire) * 24;


			ItemsConsignment.AppendToShop({guid=ItemsConsignment.goods.guid,
			cnt=ItemsConsignment.goods.copies,expire= expire,
			showseller = showseller,price=ItemsConsignment.goods.price})

		end
	end, _guihelper.MessageBoxButtons.YesNo);

end

function ItemsConsignment.CalcCommission(arg)
	ItemsConsignment.commission = COMMISSION_FACTOR * (arg or 0)
	ItemsConsignment.commission = math.ceil(ItemsConsignment.commission);

end

function ItemsConsignment.SellPrice(ctrl)
	local self = ItemsConsignment;

	local ctrl = self.page:FindControl(ctrl);
	if(ctrl)then
		if(not tonumber(ctrl.text))then
			_guihelper.MessageBox("无效的输入.");
			ItemsConsignment.goods.price = 0;
			--ItemsConsignment.CalcCommission()
			return;
		end

		ItemsConsignment.goods.price = tonumber(ctrl.text);
		
	end
end
	
function ItemsConsignment.OnSelectTimePeriod(ctrl)
	local self = ItemsConsignment;
	local dllSellPeriod = self.page:FindControl(ctrl);

	if(dllSellPeriod and dllSellPeriod.GetValue)then
		local value = dllSellPeriod:GetValue();

		ItemsConsignment.goods.expire = tonumber(value)
		ItemsConsignment.page:SetValue("txtCommission",(ItemsConsignment.goods.expire))

		local i,v;
		for i,v in ipairs(self.TimePeriodTable)do
			if(v.value == value)then
				v.selected = true;
			else
				v.selected = false;
			end
		end


	end
end

function ItemsConsignment.OnSelectDisplaySelfInfo(ctrl)
	local self = ItemsConsignment;
	local ddlDisplaySelfInfo = self.page:FindControl("ddlDisplaySelfInfo");

	if(ddlDisplaySelfInfo and ddlDisplaySelfInfo.GetValue)then
		local value = ddlDisplaySelfInfo:GetValue();

		local i,v;
		for i,v in ipairs(self.InfoTable)do
			if(v.value == value)then
				v.selected = true;
			else
				v.selected = false;
			end
		end
	end
end

function ItemsConsignment.GetDataSource(index)

	if(index == nil) then
		return #(ItemsConsignment.DisplayItems);
	else
		return ItemsConsignment.DisplayItems[index];
	end
end

--[[
	refresh whole page of gem refine
--]]
function ItemsConsignment:Refresh(delta)
	if(ItemsConsignment.page)then
		ItemsConsignment.page:Refresh(delta or 0.1);
	end
end

function ItemsConsignment.NewQuery()
	ItemsConsignment.DisplayItems = {};
end

function ItemsConsignment:Clean()
	AvatarBag.Clean(true)
	ItemsFilter:Clean()
	ItemsConsignment.goods = {copies = 0,guid=0,gsid=0}
	ItemsConsignment.filter = 0;
	ItemsConsignment.DisplayItems = {};
	ItemsConsignment.sort_col = nil;
	ItemsConsignment.is_lastpage = nil;
	--ItemsConsignment.select_id = nil;
	ItemsConsignment.TimePeriodTable = {
	{value="3",selected = true,},
	{value="5",selected = false,},
	{value="7",selected = false,},
	};
end

function ItemsConsignment.CloseWindow()
	if(ItemsConsignment.page)then
	ItemsConsignment.page:CloseWindow();
	end
end

--[[
/// <summary>
/// 分页取得所有用户寄售在商店中的物品
/// 接收参数：
///     itemclass 物品所属的Class，必传
///     [ subclass ] 物品所属的SubClass
///     [ school ] 系别
///     [ orders ] 排序方式。示例：0,1,-1,0,0 。逗号分隔的每一项分别表示：[0]:品质,[1]:等级,[2]:剩余时间,[3]:出售者,[4]:单价。值0 1 -1分别表示：不排序、升序、降序
///     pindex 页码
///     psize 每页的数据量，最大20
/// 返回值：
///     [ list ]
///         id 编号
///         gsid 物品GSID
///         name 物品名称
///         lel 物品等级
///         nid 售卖者的NID
///         nname 售卖者的昵称
///         price 价格
///         expire 过期时间
///			cnt
///     [ errorcode ] 493:参数错误
/// </summary>
]]					
function ItemsConsignment.GetInShop(params,...)
	if(not params)then return end

	local arg1,arg2 = ...;
	paraworld.auction.GetInShop(params,nil,function(msg) 
		if(type(msg) == "table")then
			ItemsConsignment:Update(msg,arg1,arg2)
			if(#msg < PAGE_SIZE_PURCHASE)then
				ItemsConsignment.is_lastpage = true;
			else
				ItemsConsignment.is_lastpage = false;
			end	
		else
			echo(msg);
			MSG("已经搜索完了.");
		end
	end);
end

--[[
	check current select,if select row then return gsid
]]
function ItemsConsignment:CheckCurrentSelectItem()
	if(self.DisplayItems and #self.DisplayItems > 0)then
		local i,v,id
		for i,v in ipairs(self.DisplayItems)do
			if(v.is_selected)then
				id = v.id;
				break;
			end
		end
		return id;
	end
end
--[[17131,17140]]
function ItemsConsignment:Update(list,...)
	--self.select_id = self.select_id or self:CheckCurrentSelectItem()
	--echo("select_id:" .. (self.select_id or 0));
	self.DisplayItems = {};
	local arg1,arg2 = ...;
	if(type(list) == "table" and #list > 0)then
		local i,v;
		--echo(list);
		for i,v in ipairs(list)do
			local item = getItemByGsid(v.gsid);	
			local item_name = "";
			local is_selected = false;
				
			if(ItemsConsignment.Id() and ItemsConsignment.Id() == v.id)then
				is_selected = true;
			end
			if(item)then
				item_name = item.template.name or "undefined name";
			end
			--echo(item);
			--item_name = string.format([[<div style="float:left;width:130px;margin-left:5px;margin-top:5px;font-size:12px;">%s</div>]],item_name);

			local typ = 0;
			if(item)then
				typ = GenericTooltip.GetItemType(item.template.subclass);
			end

			local isequip = GenericTooltip:IsEquip(item);
			if(not isequip)then typ = "";end

			local unit = v.price / v.cnt;
			local i,f = math.modf(unit);
			if(type(f) == "number" and f > 0)then
				local a = tonumber(string.sub(f,0,3));
				local b = tonumber(string.sub(f,4,4))
				if(b and b > 5)then
					a = a + .1;
				end
				
				unit = i + a;	
			end
			

			local school = "";
			local school_stats = item.template.stats[137];
			local cn_school,en_school = GenericTooltip.GetSchool(school_stats);
			local level = v.lel or item.template.stats[138] or item.template.stats[168]
			local seller = v.nname;
			if( not v.nname and not v.nid)then
				seller = "";
			elseif(v.nid == Map3DSystem.User.nid)then
				seller = "我自己"
			end

			level = level or 0;
			if(level < 1)then level = "" end
			
			if(ItemsFilter.class == 18 and ItemsFilter.subclass == 1 and ItemsFilter.school_code) then
				if(ItemsFilter.school_code == item.template.stats[136]) then
					table_insert(self.DisplayItems,{id=v.id,gsid = v.gsid,name=item_name,
						level = level,nid=v.nid, serverdata = v.serverdata or v.svrdata,
						price=v.price,time=string.sub(v.expire,6,16),nname=seller,
						copies = v.cnt,unit = unit,
						is_selected=is_selected,typ=typ,class=cn_school or "",})
				end
			else
				table_insert(self.DisplayItems,{id=v.id,gsid = v.gsid,name=item_name,
					level = level,nid=v.nid, serverdata = v.serverdata or v.svrdata,
					price=v.price,time=string.sub(v.expire,6,16),nname=seller,
					copies = v.cnt,unit = unit,
					is_selected=is_selected,typ=typ,class=cn_school or "",})
			end

			

			--[[
			if(arg1 == "面包")then
				if(v.gsid <= 17140 and v.gsid >= 17131)then
					table_insert(self.DisplayItems,{id=v.id,gsid = v.gsid,name=item_name,
					level = level,nid=v.nid,
					price=v.price,time=string.sub(v.expire,6,16),nname=seller,
					copies = v.cnt,unit = unit,
					is_selected=is_selected,typ=typ,class=cn_school or "",})
				end

			elseif(arg1 == "红枣")then
				if(v.gsid <= 17140 and v.gsid >= 17131)then
				else
				table_insert(self.DisplayItems,{id=v.id,gsid = v.gsid,name=item_name,
				level = level,nid=v.nid,
				price=v.price,time=string.sub(v.expire,6,16),nname=seller,
				copies = v.cnt,unit = unit,
				is_selected=is_selected,typ=typ,class=cn_school or "",})
				end
			elseif(arg1 == "1级宝石")then
				if(level == 1)then
					table_insert(self.DisplayItems,{id=v.id,gsid = v.gsid,name=item_name,
					level = level,nid=v.nid,
					price=v.price,time=string.sub(v.expire,6,16),nname=seller,
					copies = v.cnt,unit = unit,
					is_selected=is_selected,typ=typ,class=cn_school or "",})
				end
			elseif(arg1 == "2级宝石")then
				if(level == 2)then
					table_insert(self.DisplayItems,{id=v.id,gsid = v.gsid,name=item_name,
					level = level,nid=v.nid,
					price=v.price,time=string.sub(v.expire,6,16),nname=seller,
					copies = v.cnt,unit = unit,
					is_selected=is_selected,typ=typ,class=cn_school or "",})
				end
			elseif(arg1 == "3级宝石")then
				if(level == 3)then
					table_insert(self.DisplayItems,{id=v.id,gsid = v.gsid,name=item_name,
					level = level,nid=v.nid,
					price=v.price,time=string.sub(v.expire,6,16),nname=seller,
					copies = v.cnt,unit = unit,
					is_selected=is_selected,typ=typ,class=cn_school or "",})
				end

			elseif(arg1 == "生命系" or arg1 == "烈火系" or arg1 == "寒冰系" or arg1 == "死亡系" or arg1 == "风暴系" or arg1 == "通用")then
				if(cn_school == arg1)then
					table_insert(self.DisplayItems,{id=v.id,gsid = v.gsid,name=item_name,
					level = level,nid=v.nid,
					price=v.price,time=string.sub(v.expire,6,16),nname=seller,
					copies = v.cnt,unit = unit,
					is_selected=is_selected,typ=typ,class=cn_school or "",})
				elseif(not cn_school and arg1 == "通用")then
					table_insert(self.DisplayItems,{id=v.id,gsid = v.gsid,name=item_name,
					level = level,nid=v.nid,
					price=v.price,time=string.sub(v.expire,6,16),nname=seller,
					copies = v.cnt,unit = unit,
					is_selected=is_selected,typ=typ,class=cn_school or "",})

				end
			
			else
				table_insert(self.DisplayItems,{id=v.id,gsid = v.gsid,name=item_name,
				level = level,nid=v.nid,
				price=v.price,time=string.sub(v.expire,6,16),nname=seller,
				copies = v.cnt,unit = unit,
				is_selected=is_selected,typ=typ,class=cn_school or "",})
			end]]
		end	
			
		--echo("---------------------build completely-------------------------")
		--echo(self.DisplayItems);
	else
		--MSG("没有搜索到你需要的物品");--time out?
	end

	ItemsConsignment.page:CallMethod("pegvwGemsView","SetDataSource",ItemsConsignment.DisplayItems);
	ItemsConsignment.page:CallMethod("pegvwGemsView","DataBind")
	--ItemsConsignment:Refresh();
end

function ItemsConsignment:GetPriceByID(id)
	local item = self:GetDisplayItemByID(id);
	if(item) then
		return item.price;
	end
end

function ItemsConsignment:GetDisplayItemByID(id)
	local i,v 
	for i,v in ipairs(self.DisplayItems)do
		if(v.id == id)then
			return v;
		end
	end
end

--[[ this is SLOW, call this sparingly
/// <summary>
/// 搜索正在出售中的物品
/// 接收参数：
///     sessionkey 当前用户
///     [ canuse ] 是否只搜当前用户可用的，0:否；1:是
///     [ minlel ] 最小等级
///     [ maxlel ] 最大等级
///     [ quality ] 品质
///     [ gsname ] 物品名
///     pindex 页码
///     psize 每页的数据量
/// 返回值：
///     [ list ]
///         id 编号
///         gsid 物品GSID
///         name 物品名称
///         lel 物品等级
///         nid 售卖者的NID
///         nname 售卖者的昵称
///         price 价格
///         expire 过期时间
///			cnt
/// </summary>
]]
function ItemsConsignment.SearchFromShop(params,...)
	if(not params)then return end
	--echo(params);
	--echo(...);
	local arg1,arg2 = ...;

	paraworld.auction.SearchFromShop(params,nil,function(msg) 
		
		if(type(msg) == "table")then

			--MSG("SUCCESS");
			ItemsConsignment:Update(msg,arg1,arg2)
			if(#msg < PAGE_SIZE_PURCHASE)then
				ItemsConsignment.is_lastpage = true;
			else
				ItemsConsignment.is_lastpage = false;
			end	

		else
			echo(msg);
			MSG("没有搜索到你需要的物品.");
		end
	end);	
end

--[[
/// <summary>
/// 将指定的物品添加到商店出售
/// 接收参数：
///     sessionkey 当前登录用户
///     guid
///     expire 时限，如12表示12小时后过期
///     price 价格，魔豆
///     cnt 数量
///     showseller 是否公开卖家信息，0:否；1:是
/// 返回值：
///     issuccess
///     [ errorcode ] 493:参数错误；419:用户不存在；497:物品不存在；438:不可出售；411:E币不足；
/// </summary>
]] 
--paraworld.create_wrapper("paraworld.auction.AppendToShop", "MAIN%/API/Items/AppendToShop.ashx");
function ItemsConsignment.AppendToShop(params)
	if(not params)then return end
	--echo(params);
	local commission = ItemsConsignment.page:GetValue("txtCommission");

	if(paraworld.auction and paraworld.auction.AppendToShop)then
	paraworld.auction.AppendToShop(params,nil,function(msg)  
		
		if(msg and msg.issuccess)then
			ItemsConsignment.goods.copies = 0
			 ItemsConsignment.goods.guid=0
			 ItemsConsignment.goods.gsid=0
			
			--ItemManager.GetItemsInBag( 12, "0", function(msg)end, "access plus 0 minutes");

			ItemsConsignment.GetInShopByMe({nid=nil,pindex=0,psize =PAGE_SIZE_SELL});

			AvatarBag.ResetStates();
			ItemsConsignment:Refresh();
			
		elseif(msg.errorcode == 438)then
			echo(msg);
			MSG("该物品不可出售.");
		elseif(msg.errorcode == 411)then
			--411:E币不足
			echo(msg);
			MSG("你的仙豆不够了哦.");
		else
			MSG("你寄售物品的数量与实际拥有的数量不同.");
			echo(msg);
			--MSG("执行出错.");
		end
		
	end);
	end
end


function ItemsConsignment.GenDisplayName(name,copies)
    if(not copies or copies == 1)then
        return name;
    else
        return string.format("%s X %s",name or "",copies or 1);
    end
end

--[[
/// <summary>
/// 从商店中购买
/// 接收参数：
///     sessionkey 当前登录用户
///     id 商品ID
/// 返回值：
///     issuccess
///     [ errorcode ] 497:物品不存在；419:用户不存在；443:魔豆不足；
/// </summary>
]]
--paraworld.create_wrapper("paraworld.auction.BuyFromShop", "MAIN%/API/Items/BuyFromShop.ashx");
function ItemsConsignment.BuyFromShop(params)
	if(not params)then return end
	local item = ItemsConsignment:GetDisplayItemByID(params.id);
	if(params.id == nil)then MSG("请先选择寄售中的物品，再购买它！"); return end
	if(not item) then
		MSG("你选择的物品不在当前页面。");
		return 
	end
	local gsid = item.gsid;
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(gsItem)then
		local maxcount = gsItem.template.maxcount or 0;
		local __,__,__,copies = hasGSItem(gsid);
		copies = copies or 0;
		copies = copies + item.copies;
		if(copies > maxcount)then
			MSG(string.format("你不能拥有过多的%s!",item.name));
			return;
		end
	end

	local price = item.price or 0;
	local cost = ((ItemsConsignment.commission or 0)+ price);
	
	local name_text = ItemsConsignment.GenDisplayName(item.name, item.copies) or "";

	_guihelper.MessageBox(string.format( "确认花费%d魔豆购买【%s】？",cost,name_text),function(res) 
		if(ItemsConsignment.GetMagicBean() < cost)then
			MSG("你的魔豆已不足！")
			return 
		end

		if(res and res == _guihelper.DialogResult.OK) then
			paraworld.auction.BuyFromShop(params,nil,function(msg)
			if(msg and msg.issuccess)then
				--local last_value = ItemsConsignment.page:GetValue("txtHoldModou");
				--local sell_price = ItemsConsignment:GetPriceByID(params.id)
				--last_value = tonumber(last_value) - cost;
				-- ItemManager.GetItemsInBag( 0, "0", function(msg)end, "access plus 0 minutes");
				
				--ItemsConsignment:SetCtrlValue("txtHoldModou",tostring(last_value))
				ItemsConsignment:RemoveItemByID(params.id)
				ItemsConsignment.id = nil;
				NotificationArea.CheckEmail(3000);
				MSG("购买成功，刚才购买的物品已经邮寄到你的<br/>邮箱了，您可以打开屏幕上方的邮件，收取附件。");
			elseif(msg.errorcode == 443)then
				echo(msg)
				MSG("你的魔豆已不足！")
			else
				echo(msg)
				MSG("无法购买， 该物品可能刚刚被其他人抢购了！")
			end
	
	 end);
		end
	end)


end

function ItemsConsignment:SetCtrlValue(name,value)
	self.page:SetValue(name,value or "");
end

--[[
/// <summary>
/// 取消指定商品的出售
/// 接收参数：
///     sessionkey 当前登录用户
///     id 商品ID
/// 返回值：
///     issuccess
///     [ errorcode ] 497:物品不存在 438:无权限
/// </summary>
]]
--paraworld.create_wrapper("paraworld.auction.CancelSell", "MAIN%/API/Items/CancelSell.ashx");
function ItemsConsignment._CancelSell(params)
	if(not params)then return end
	if(not params.id)then return end
	paraworld.auction.CancelSell(params,nil,function(msg)
	
		if(msg and msg.issuccess)then
			echo(msg);
			--TODO:	
			--ItemsConsignment.GetInShopByMe({nid=nil,pindex=0,psize =PAGE_SIZE_PURCHASE});
			ItemsConsignment:RemoveItemByID(params.id)
			ItemsConsignment.id = nil;
			MSG("您的物品已从交易所下架，请在邮件中收回。");
			NotificationArea.CheckEmail(3000);
		elseif(msg.errorcode == 497)then
			echo(msg);
			MSG("该物品已经不存在了.");
		elseif(msg.errorcode == 438)then
			MSG("你不能取消这个物品的寄售.");
		end
	 end);
end


--[[
/// <summary>
/// 检查用户在商店中过期的物品，如果有，则做出售失败处理。
/// 用户登录后，每隔一段时间（如30分钟）调用一次此API
/// 接收参数：
///     sessionkey 当前登录用户
/// 返回值：
///     issuccess
/// </summary>
]]
--paraworld.create_wrapper("paraworld.auction.CheckItemsInShop", "MAIN%/API/Items/CheckItemsInShop.ashx");
function ItemsConsignment.CheckItemsInShop(params)
	if(not params)then return end
	paraworld.auction.CheckItemsInShop(params,nil,function(msg)
		
		--TODO:
	 end);
end

--[[
/// <summary>
/// 取得用户在商店中在售的物品
/// 接收参数：
///     sessionkey
///     pindex 页码
///     psize 每页的数据量
/// 返回值：
///     [ list ]
///         id
///         gsid
///         name
///         price 出售价格
///         expire 过期时间，yyyy-MM-dd HH:mm:ss
/// </summary>
]]
--paraworld.create_wrapper("paraworld.auction.GetInShopByMe", "MAIN%/API/Items/GetInShopByMe.ashx");
function ItemsConsignment.GetInShopByMe(params)
	if(not params)then return end

	paraworld.auction.GetInShopByMe(params,nil,function(msg) 
		if(type(msg) == "table")then
			--TODO:
			--echo("+++++++++++++++++++++++++++++item of me++++++++++++++++++++++++++++++++")
			--echo(msg);

			if(#msg < PAGE_SIZE_SELL)then
				ItemsConsignment.is_lastpage = true;
			else
				ItemsConsignment.is_lastpage = false;
			end	
			ItemsConsignment:Update(msg)
			
		else
			echo(msg);
			MSG("没有搜索到你需要的物品.");

		end
	end);
end


function ItemsConsignment.ExchCloseTip()
	_guihelper.MessageBox("因个人账户安全原因，物品交换/邮件系统进行维护。预计将在下次更新后修复功能，若提前恢复交易功能不做另行通知。");
end