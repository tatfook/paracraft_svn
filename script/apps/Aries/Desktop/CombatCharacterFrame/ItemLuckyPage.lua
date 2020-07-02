--[[
Title: 
Author(s): leio
Date: 2013/1/29
Desc:  

NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/ItemLuckyPage.lua");
local ItemLuckyPage = commonlib.gettable("MyCompany.Aries.Desktop.ItemLuckyPage");
ItemLuckyPage.ShowPage();
]]
NPL.load("(gl)script/kids/3DMapSystemItem/PowerExtendedCost.lua");
local PowerExtendedCost = commonlib.gettable("Map3DSystem.Item.PowerExtendedCost");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
local ItemLuckyPage = commonlib.gettable("MyCompany.Aries.Desktop.ItemLuckyPage");
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
ItemLuckyPage.super_transfer_node = nil;
ItemLuckyPage.super_loots = nil;
ItemLuckyPage.other_loots = nil;
ItemLuckyPage.loots = nil;
ItemLuckyPage.cut_gsids = {
	[50369] = true,
	[50370] = true,
	[50371] = true,
	[50372] = true,
	[50373] = true,
	[50374] = true,
	[50375] = true,
	[50376] = true,
	[50377] = true,
	[50413] = true,
}
ItemLuckyPage.menus = {
	{ label = "铜币专区", keyname = "lottery_bronze_free", keyname2 = "lottery_bronze", buy_exid = 1628, game_coin = 50375, game_coin2 = 17369, count_gsid = 50369, },
	{ label = "银币专区", keyname = "lottery_silver_free", keyname2 = "lottery_silver", buy_exid = 1629, game_coin = 50376, game_coin2 = 17370, count_gsid = 50371, },
	{ label = "金币专区", keyname = "lottery_gold_free", keyname2 = "lottery_gold", buy_exid = 1630, game_coin = 50377, game_coin2 = 17371, count_gsid = 50373, },
	{ label = "钻石专区", selected = true, keyname = "lottery_diamond_free", keyname2 = "lottery_diamond", buy_exid = 1962, game_coin = 50414, game_coin2 = 17534, count_gsid = 50413, },
}
ItemLuckyPage.is_pending = nil;
function ItemLuckyPage.GetMenu_CheckedNode()
	local k,v;
	for k,v in ipairs(ItemLuckyPage.menus) do
		if(v.selected)then
			return v;
		end
	end
end
function ItemLuckyPage.GetCoin2Count()
	local node = ItemLuckyPage.GetMenu_CheckedNode();
	if(node)then
		local __,__,__,copies = hasGSItem(node.game_coin2)
		return copies or 0;
	end
	return 0;
end
function ItemLuckyPage.IsPending()
	return ItemLuckyPage.is_pending;
end
function ItemLuckyPage.GotLoots()
	if(ItemLuckyPage.loots)then
		return true;
	end
end 
function ItemLuckyPage.GetCountGsid()
	local node = ItemLuckyPage.GetMenu_CheckedNode();
	if(node)then
		return node.count_gsid;
	end
end
function ItemLuckyPage.IsFirstLucky()
	local node = ItemLuckyPage.GetMenu_CheckedNode();
	if(node)then
		local gsid = node.game_coin;
		local __,__,__,copies = hasGSItem(gsid);
		copies = copies or 0;
		if(copies > 0)then
			return true;
		end
	end
	return false;
end
function ItemLuckyPage.OnInit()
	ItemLuckyPage.page = document:GetPageCtrl();
end
function ItemLuckyPage.DS_Func_super_loots(index)
	if(not ItemLuckyPage.super_loots)then return 0 end
	if(index == nil) then
		return #(ItemLuckyPage.super_loots);
	else
		return ItemLuckyPage.super_loots[index];
	end
end
function ItemLuckyPage.DS_Func_other_loots(index)
	if(not ItemLuckyPage.other_loots)then return 0 end
	if(index == nil) then
		return #(ItemLuckyPage.other_loots);
	else
		return ItemLuckyPage.other_loots[index];
	end
end
function ItemLuckyPage.DS_Func_loots(index)
	if(not ItemLuckyPage.loots)then return 0 end
	if(index == nil) then
		return #(ItemLuckyPage.loots);
	else
		return ItemLuckyPage.loots[index];
	end
end
function ItemLuckyPage.LootHandle(loots)
	loots = loots or {};
	ItemLuckyPage.is_pending = nil;
	local len = #loots;
	while(len > 0) do
		local node = loots[len];
		if(node and node.gsid and ItemLuckyPage.cut_gsids[node.gsid])then
			table.remove(loots,len);
		end
		len = len - 1;
	end
	ItemLuckyPage.loots = loots;
	if(ItemLuckyPage.page)then
		ItemLuckyPage.page:Refresh(0);
	end
end
--过滤重复的gsid
function ItemLuckyPage.FilterLoots(list)
	if(not list)then
		return
	end
	local temp_map = {};
	local result = {};
	local k,v;
	for k,v in ipairs(list) do
		if(v.gsid) then
			local gsid_count = format("%d_%d", v.gsid or 0, v.count or 1);
			if(not temp_map[gsid_count])then
				table.insert(result,v);
				temp_map[gsid_count] = true;
			end
		end
	end
	return result;
end
function ItemLuckyPage.BuildLoots(ex_template)
	if(not ex_template)then
		return
	end
	local temp_map = {};
	local super_loots = nil;
	local other_loots = {};
	local k,v;
	for k,v in ipairs(ex_template) do
		if(v.attr and v.attr.loot)then
			local kk,vv;
			for kk,vv in ipairs(v.attr.loot) do
				if(vv.gsid) then
					local gsid_count = format("%d_%d", vv.gsid or 0, vv.count or 1);
					if(not temp_map[gsid_count])then
						table.insert(other_loots,vv);
						temp_map[gsid_count] = true;
					end
				end
			end
			super_loots = v.attr.loot;
			super_transfer_node = v;
		end
	end
	table.sort(other_loots, function(a,b) 
		return (a.gsid < b.gsid) or (a.gsid==b.gsid and (a.count or 1) > (b.count or 1));
	end);
	return super_loots,other_loots,super_transfer_node;
end
function ItemLuckyPage.OnClickFolder(node)
	local ex_template = PowerExtendedCost.GetExtendedCostTemplateInMemory(node.keyname);
	local __,free_other_loots = ItemLuckyPage.BuildLoots(ex_template);--免费
	ex_template = PowerExtendedCost.GetExtendedCostTemplateInMemory(node.keyname2);
	local super_loots,other_loots,super_transfer_node = ItemLuckyPage.BuildLoots(ex_template);
	other_loots = CommonClientService.UnionList(free_other_loots,other_loots);
	super_loots = ItemLuckyPage.FilterLoots(super_loots);
	other_loots = ItemLuckyPage.FilterLoots(other_loots);
	ItemLuckyPage.super_loots = super_loots;
	ItemLuckyPage.other_loots = other_loots;
	ItemLuckyPage.super_transfer_node = super_transfer_node;

	echo(ItemLuckyPage.super_loots);
	echo(ItemLuckyPage.other_loots);
	if(ItemLuckyPage.page)then
		ItemLuckyPage.page:Refresh(0);
	end
end
function ItemLuckyPage.ShowPage()
	if(MyCompany.Aries.Player.GetLevel() < 10) then
		_guihelper.MessageBox("卡牌乐透10级开启， 你的等级不够，快做任务升级吧");
		return;
	end
	PowerExtendedCost.LoadFromConfig();
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	local url = "script/apps/Aries/Desktop/CombatCharacterFrame/ItemLuckyPage.html";
	local params = {
		url = url, 
		app_key = MyCompany.Aries.app.app_key, 
		name = "ItemCheckPage.ShowPage", 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		cancelShowAnimation = true,
		style = style,
		bToggleShowHide = true,
		zorder = 10,
		allowDrag = true,
		-- isTopLevel = true,
		enable_esc_key = true,
		directPosition = true,
			align = "_ct",
			x = -640/2,
			y = -470/2,
			width = 640,
			height = 470,
	}
	System.App.Commands.Call("File.MCMLWindowFrame", params);
    ItemLuckyPage.is_pending = nil;
	ItemLuckyPage.loots = nil;
	local node = ItemLuckyPage.GetMenu_CheckedNode();
	if(node)then
		ItemLuckyPage.OnClickFolder(node);
	end

	-- auto purchase free lottery
	ItemLuckyPage.CheckPurchaseFreeLottery();
end

-- added by LiXizhi
-- auto purchase free lottery
function ItemLuckyPage.CheckPurchaseFreeLottery()
	if(not ItemLuckyPage.has_purchased) then
		ItemLuckyPage.has_purchased = true;
		local has_free_lottery;
		local gsids = {[50375] = true, [50376] = true};

		local gsid, _
		for gsid, _ in pairs(gsids) do
			local obtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(gsid);
			if (obtain and obtain.inday==0) then
				local bHas = ItemManager.IfOwnGSItem(gsid);
				if(not bHas) then
					ItemManager.PurchaseItem(gsid, 1, function(msg) 
						LOG.std("", "system","ItemLuckyPage", "free lottery "..gsid.." return: +++++++"..LOG.tostring(msg));
						if(msg.issuccess == true) then
							-- refresh the page if purchased. 
							if(ItemLuckyPage.page) then
								ItemLuckyPage.page:Refresh();
							end
						end
					end, function(msg) end, nil, "none");
				end
			end
		end
	end
end