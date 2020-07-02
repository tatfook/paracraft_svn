--[[
Title: 
Author(s): Leio	
Date: 2012/10/29
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Inventory/Cards/CardsSeparatePage.lua");
local CardsSeparatePage = commonlib.gettable("MyCompany.Aries.Inventory.Cards.CardsSeparatePage");
CardsSeparatePage.ShowPage();
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/apps/Aries/UserBag/BagHelper.lua");
local BagHelper = commonlib.gettable("MyCompany.Aries.Inventory.BagHelper");
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
local MyCardsManager = commonlib.gettable("MyCompany.Aries.Inventory.Cards.MyCardsManager");
local CardsSeparatePage = commonlib.gettable("MyCompany.Aries.Inventory.Cards.CardsSeparatePage");
CardsSeparatePage.pagesize = 48;
CardsSeparatePage.selected_gsid = nil;
CardsSeparatePage.selected_guid = nil;
CardsSeparatePage.exclude_path = "config/Aries/BagDefine_Teen/cards_separate_filter.xml";
CardsSeparatePage.exclude_regions = nil;
CardsSeparatePage.card_filter_list = {
	{ quality = 0, selected = true, tooltip = "白色品质的卡牌", bg_1 = "Texture/Aries/Common/Teen/control/white_selected_btn_32bits.png", bg_2 = "Texture/Aries/Common/Teen/control/white_btn_32bits.png" },
	{ quality = 1, selected = true, tooltip = "绿色品质的卡牌", bg_1 = "Texture/Aries/Common/Teen/control/green_selected_btn_32bits.png", bg_2 = "Texture/Aries/Common/Teen/control/green_btn_32bits.png"  },
	{ quality = 2, selected = true, tooltip = "蓝色品质的卡牌", bg_1 = "Texture/Aries/Common/Teen/control/blue_selected_btn_32bits.png", bg_2 = "Texture/Aries/Common/Teen/control/blue_btn_32bits.png"  },
	{ quality = 3, selected = true, tooltip = "紫色品质的卡牌", bg_1 = "Texture/Aries/Common/Teen/control/purple_selected_btn_32bits.png", bg_2 = "Texture/Aries/Common/Teen/control/purple_btn_32bits.png"  },
}
if(System.options.version == "kids") then
	CardsSeparatePage.card_filter_list = {
		{ quality = 0, selected = true, label="<div style='color:#ffffff;'>普通</div>", tooltip = "白色品质的卡牌", bg_1 = "Texture/Aries/Common/Teen/control/white_selected_btn_32bits.png", bg_2 = "Texture/Aries/Common/Teen/control/white_btn_32bits.png" },
		{ quality = 1, selected = true, label="<div style='color:#7CFC00;'>精良</div>", tooltip = "绿色品质的卡牌", bg_1 = "Texture/Aries/Common/Teen/control/green_selected_btn_32bits.png", bg_2 = "Texture/Aries/Common/Teen/control/green_btn_32bits.png"  },
		{ quality = 2, selected = true, label="<div style='color:#0000CD;'>稀有</div>", tooltip = "蓝色品质的卡牌", bg_1 = "Texture/Aries/Common/Teen/control/blue_selected_btn_32bits.png", bg_2 = "Texture/Aries/Common/Teen/control/blue_btn_32bits.png"  },
		{ quality = 3, selected = true, label="<div style='color:#4B0082;'>传奇</div>", tooltip = "紫色品质的卡牌", bg_1 = "Texture/Aries/Common/Teen/control/purple_selected_btn_32bits.png", bg_2 = "Texture/Aries/Common/Teen/control/purple_btn_32bits.png"  },
	}
elseif(System.options.version == "teen") then
	CardsSeparatePage.card_filter_list = {
		{ quality = 0, selected = true, label="<div style='color:#ffffff;'>普通</div>", tooltip = "白色品质的卡牌", bg_1 = "Texture/Aries/Common/Teen/control/white_selected_btn_32bits.png", bg_2 = "Texture/Aries/Common/Teen/control/white_btn_32bits.png" },
		{ quality = 1, selected = true, label="<div style='color:#77d305;'>精良</div>", tooltip = "绿色品质的卡牌", bg_1 = "Texture/Aries/Common/Teen/control/green_selected_btn_32bits.png", bg_2 = "Texture/Aries/Common/Teen/control/green_btn_32bits.png"  },
		{ quality = 2, selected = true, label="<div style='color:#0d99fc;'>稀有</div>", tooltip = "蓝色品质的卡牌", bg_1 = "Texture/Aries/Common/Teen/control/blue_selected_btn_32bits.png", bg_2 = "Texture/Aries/Common/Teen/control/blue_btn_32bits.png"  },
		{ quality = 3, selected = true, label="<div style='color:#985ef7;'>传奇</div>", tooltip = "紫色品质的卡牌", bg_1 = "Texture/Aries/Common/Teen/control/purple_selected_btn_32bits.png", bg_2 = "Texture/Aries/Common/Teen/control/purple_btn_32bits.png"  },
	}
end

function CardsSeparatePage.DS_Func_Card_Filter(index)
	if(not CardsSeparatePage.card_filter_list)then return 0 end
	if(index == nil) then
		return #(CardsSeparatePage.card_filter_list);
	else
		return CardsSeparatePage.card_filter_list[index];
	end
end
function CardsSeparatePage.CardFilter_Quality_IsSelected(quality)
	if(not quality or quality < 0)then
		return true;
	end
	if(CardsSeparatePage.card_filter_list)then
		local k,v;
		for k,v in ipairs(CardsSeparatePage.card_filter_list) do
			if(v.selected and v.quality == quality)then
				return true;
			end
		end
	end
	return false;
end
function CardsSeparatePage.CardFilter_IsSelectedAll()
	if(CardsSeparatePage.card_filter_list)then
		local k,v;
		for k,v in ipairs(CardsSeparatePage.card_filter_list) do
			if(not v.selected)then
				return false;
			end
		end
	end
	return true;
end
function CardsSeparatePage.CardFilter_SelectedAll(b)
	if(CardsSeparatePage.card_filter_list)then
		local k,v;
		for k,v in ipairs(CardsSeparatePage.card_filter_list) do
			v.selected = b;
		end
	end
end
function CardsSeparatePage.CardFilter_Toggle(index)
	if(index and CardsSeparatePage.card_filter_list and CardsSeparatePage.card_filter_list[index])then
		local node = CardsSeparatePage.card_filter_list[index];
		node.selected = not node.selected;
	end
end
function CardsSeparatePage.OnInit()
	CardsSeparatePage.page = document:GetPageCtrl();
end
function CardsSeparatePage.ShowPage(npcid)
	NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
	local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
	local can_pass = DealDefend.CanPass();
	if(not can_pass)then
		return
	end
	CardsSeparatePage.npcid = npcid;
	local url = "script/apps/Aries/Inventory/Cards/CardsSeparatePage.teen.html";
	if(System.options.version == "kids") then
		url = "script/apps/Aries/Inventory/Cards/CardsSeparatePage.kids.html";
	end
	local params = {
			url = url,
			name = "CardsSeparatePage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			enable_esc_key = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			directPosition = true,
				align = "_ct",
				x = -760/2,
				y = -470/2,
				width = 760,
				height = 470,
		}
	System.App.Commands.Call("File.MCMLWindowFrame", params);		
	CardsSeparatePage.selected_gsid = nil;
	CardsSeparatePage.selected_guid = nil;
	CardsSeparatePage.CardFilter_SelectedAll(true);
	CardsSeparatePage.LoadCards();
end
function CardsSeparatePage.DoShake(callbackFunc)
	if(not CardsSeparatePage.npcid)then
		if(callbackFunc)then
			callbackFunc();
		end
		return
	end
	local giftTree = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(CardsSeparatePage.npcid);
	if(giftTree) then
		giftTree:SetVisible(false);
		local scale = giftTree:GetScale() or 1;
		local facing = giftTree:GetFacing() or 0;
		-- create effect
		local params = {
			asset_file = "character/v6/01human/FenJieJi/FenJieJi_tremble.x",
			--ismodel = true,
			scale = scale,
			facing = facing,
			start_position = {giftTree:GetPosition()},
			duration_time = 3200,
			end_callback = function()
				local giftTree = MyCompany.Aries.Quest.NPC.GetNpcCharacterFromIDAndInstance(CardsSeparatePage.npcid);
				if(giftTree) then
					giftTree:SetVisible(true);
					if(callbackFunc)then
						callbackFunc();
					end
				end
			end,
		};
		local EffectManager = MyCompany.Aries.EffectManager;
		EffectManager.CreateEffect(params);
	end
end
function CardsSeparatePage.GetCnt(gsid)
	if(not gsid)then return end
    local __,__,__,copies = hasGSItem(gsid);
    copies = copies or 0;
    local include,count_combat,count_rune,thiscardNum = MyCardsManager.InCombatBag(gsid);
    thiscardNum = thiscardNum or 0
    copies = copies - thiscardNum;
    if(copies < 0)then
        copies = 0;
    end
    return copies;
end
function CardsSeparatePage.IsInExcludeRegion(gsid)
	if(not gsid)then return end
	local k,v;
	for k,v in ipairs(CardsSeparatePage.exclude_regions) do
		if(v.to and v.from)then
			if(gsid >= v.from and gsid <= v.to)then
				return true;
			end
		end
		if(v.gsid and gsid == v.gsid)then
			return true;
		end
	end
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(gsItem)then
		local apparel_quality = gsItem.template.stats[221];
		if(apparel_quality and apparel_quality > 3)then
			return true;
		end
	end
	local cnt = CardsSeparatePage.GetCnt(gsid) or 0;
	if(cnt <= 0)then
		return true
	end
end
function CardsSeparatePage.LoadFilter()
	if(System.options.version == "kids") then
		CardsSeparatePage.exclude_regions = {};
		return;
	end
	if(not CardsSeparatePage.exclude_regions)then
		CardsSeparatePage.exclude_regions = {};
		local xmlRoot = ParaXML.LuaXML_ParseFile(CardsSeparatePage.exclude_path);
		local exclude_node
		for exclude_node in commonlib.XPath.eachNode(xmlRoot, "/items/exclude/item") do
			local from_gsid = tonumber(exclude_node.attr.from);
			local to_gsid = tonumber(exclude_node.attr.to);
			local gsid = tonumber(exclude_node.attr.gsid);
			local node = {
				from = from_gsid,
				to = to_gsid,
				gsid = gsid,
			}
			table.insert(CardsSeparatePage.exclude_regions,node);
		end
	end
end

-- 获取当前卡牌
function CardsSeparatePage.GetCards(callbackfun)
	local output = {};
	CardsSeparatePage.cards_list = output;
	local bag = 24;
	local prop = "";
	ItemManager.GetItemsInBag(bag, "ariesitems_"..bag, function(msg)
		if(msg and msg.items) then			
			local count = 0;
			local combat_count = 0;
			local i;
			for i = 1, ItemManager.GetItemCountInBag(bag) do
				local item = ItemManager.GetItemByBagAndOrder(bag, i);
				if(item ~= nil) then
					local gsItem = ItemManager.GetGlobalStoreItemInMemory(item.gsid)
					-- only list the card which can be used
					if(gsItem)then
						local assetkey = gsItem.assetkey or "";
						assetkey = string.lower(assetkey);
						prop = string.match(assetkey,"^%d+_(%a+)_.+") or "";
						if(item.gsid ~= 22000 and item.gsid > 23000)then
							if (not gsItem.template.stats[134]) then
								local s = string.format("Error! %d doesnot has pips!",item.gsid)
								_guihelper.MessageBox(s)
							else
								combat_count = combat_count + 1;
								output[combat_count] = {guid = item.guid, gsid = item.gsid, pips=gsItem.template.stats[134], copies=item.copies, modgsid=item.gsid%1000,};
							end
						end
					end
				end
			end
			count = combat_count;
			local i,j;
			for i = 1, combat_count do
				for j=i+1, combat_count do			
					if (output[j].pips > output[i].pips ) then
						local tmpnode={};
						tmpnode = output[i];
						output[i] = output[j];
						output[j] = tmpnode;	
					elseif (output[j].pips==output[i].pips) then
						if (output[j].modgsid>output[i].modgsid) then
							local tmpnode={};
							tmpnode = output[i];
							output[i] = output[j];
							output[j] = tmpnode;		
						elseif (output[j].modgsid == output[i].modgsid)then
							if (output[j].gsid > output[i].gsid) then
								local tmpnode={};
								tmpnode = output[i];
								output[i] = output[j];
								output[j] = tmpnode;	
							end
						end
					end
				end
			end
			if(callbackfun) then
				callbackfun();
			end
		end			
	end, "access plus 5 minutes");
end

function CardsSeparatePage.LoadCards()
	local function processCardList()
		if(CardsSeparatePage.cards_list)then
			local len = #CardsSeparatePage.cards_list;
			while(len > 0)do
				local node = CardsSeparatePage.cards_list[len];
				if(node)then
					local gsid = node.gsid;
					local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
					if(gsItem)then
						local apparel_quality = gsItem.template.stats[221] or -1;
						if(not CardsSeparatePage.CardFilter_Quality_IsSelected(apparel_quality) or CardsSeparatePage.IsInExcludeRegion(gsid))then
							table.remove(CardsSeparatePage.cards_list,len);
						end
					end
				end
				len = len - 1;
			end
		end
		CommonClientService.Fill_List(CardsSeparatePage.cards_list,CardsSeparatePage.pagesize)
		if(CardsSeparatePage.page)then
			CardsSeparatePage.page:Refresh(0);
		end
	end
	--加载过滤器
	CardsSeparatePage.LoadFilter();
	if(System.options.version == "kids") then
		CardsSeparatePage.cards_list = {};
		CardsSeparatePage.GetCards(function()
			processCardList();
		end);
	elseif(System.options.version == "teen") then
		CardsSeparatePage.cards_list = BagHelper.Search_Memory(nil,"CombatCard","1");
		processCardList();
	end
end
function CardsSeparatePage.DS_Func_Cards(index)
	if(not CardsSeparatePage.cards_list)then return 0 end
	if(index == nil) then
		return #(CardsSeparatePage.cards_list);
	else
		return CardsSeparatePage.cards_list[index];
	end
end
