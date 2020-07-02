--[[
Title: 
Author(s): Leio	
Date: 2012/10/29
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Inventory/Cards/CardsUnpackPage.lua");
local CardsUnpackPage = commonlib.gettable("MyCompany.Aries.Inventory.Cards.CardsUnpackPage");
CardsUnpackPage.ShowPage(17265);
-------------------------------------------------------
]]

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
local CardsUnpackPage = commonlib.gettable("MyCompany.Aries.Inventory.Cards.CardsUnpackPage");
CardsUnpackPage.tick = 0;
CardsUnpackPage.is_rolling = false;
CardsUnpackPage.rool_cnt = 0;
CardsUnpackPage.gsid = nil;
CardsUnpackPage.cards_list = nil;
CardsUnpackPage.min_duration = 1000;
CardsUnpackPage.max_duration = 30000;
function CardsUnpackPage.OnInit()
	CardsUnpackPage.page = document:GetPageCtrl();
end
function CardsUnpackPage.ShowPage(gsid)
	CardsUnpackPage.tick = 0;
	CardsUnpackPage.rool_cnt = 0;
	CardsUnpackPage.is_rolling = false;
	CardsUnpackPage.StopTimer();
	CardsUnpackPage.gsid = gsid;
	CardsUnpackPage.cards_list = {
		{ is_empty = true, },{ is_empty = true, },{ is_empty = true, },{ is_empty = true, },{ is_empty = true, },{ is_empty = true, },
	};
	local url = "script/apps/Aries/Inventory/Cards/CardsUnpackPage.teen.html";
	local params = {
			url = url,
			name = "CardsUnpackPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			enable_esc_key = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			directPosition = true,
			zorder = 10000,
			align = "_ct",
			x = -770/2,
			y = -445/2,
			width = 770,
			height = 445,
			cancelShowAnimation = true,
		}
	System.App.Commands.Call("File.MCMLWindowFrame", params);	
	if(params._page) then
		params._page.OnClose = function(bDestroy)
			CardsUnpackPage.StopTimer();
			CardsUnpackPage.page = nil;
			CardsUnpackPage.is_rolling = false;
			CardsUnpackPage.tick = 0;
		end
	end	
end
function CardsUnpackPage.DS_Func(index)
    if(not CardsUnpackPage.cards_list)then return 0 end
	if(index == nil) then
		return #(CardsUnpackPage.cards_list);
	else
		return CardsUnpackPage.cards_list[index];
	end
end
function CardsUnpackPage.StopTimer()
	if(CardsUnpackPage.timer)then
		CardsUnpackPage.timer:Change();
	end
	CardsUnpackPage.tick = 0;
end
function CardsUnpackPage.DoRoll_Handle(gsid_list)
	if(not gsid_list)then return end 
	if(CardsUnpackPage.tick and CardsUnpackPage.tick < CardsUnpackPage.min_duration)then
		CardsUnpackPage.pending_gsid_list = gsid_list;
		return
	end
	gsid_list = CardsUnpackPage.ConvertList_ipairs(gsid_list)
	CardsUnpackPage.StopTimer();
	CardsUnpackPage.RefreshGridview(gsid_list);
	CardsUnpackPage.is_rolling = false;
	CardsUnpackPage.rool_cnt = CardsUnpackPage.rool_cnt + 1;
	if(CardsUnpackPage.page)then
		CardsUnpackPage.page:Refresh(0);
	end
end
function CardsUnpackPage.DoRoll(interval)
	interval = interval or 200;
	CardsUnpackPage.tick = 0;
	CardsUnpackPage.is_rolling = true;
	if(not CardsUnpackPage.timer) then
		CardsUnpackPage.timer = commonlib.Timer:new({callbackFunc = function()
			local __,__,cards_list = CardsUnpackPage.GetCardsFromCardPack(CardsUnpackPage.gsid);
			CardsUnpackPage.RefreshGridview(cards_list);
			CardsUnpackPage.tick = CardsUnpackPage.tick + interval;
			--³¬Ê±
			if(CardsUnpackPage.tick > CardsUnpackPage.max_duration)then
				CardsUnpackPage.StopTimer();
				if(CardsUnpackPage.page)then
					CardsUnpackPage.page:CloseWindow()
				end
			elseif(CardsUnpackPage.tick >= CardsUnpackPage.min_duration and CardsUnpackPage.pending_gsid_list)then
				CardsUnpackPage.DoRoll_Handle(CardsUnpackPage.pending_gsid_list);
			end
		end})
	end
	CardsUnpackPage.timer:Change(0,interval);
end
function CardsUnpackPage.RefreshGridview(cards_list)
	CardsUnpackPage.cards_list = cards_list;
	if(CardsUnpackPage.page)then
		CardsUnpackPage.page:CallMethod("cards_view", "SetDataSource", CardsUnpackPage.cards_list);
        CardsUnpackPage.page:CallMethod("cards_view","DataBind");
	end
end
function CardsUnpackPage.ConvertList_ipairs(gsid_list)
	local gsid_list_2 = {};
	if(gsid_list)then
		local k,v;
		for k,v in ipairs(gsid_list) do
			local kk = 1;
			for kk = 1, v.cnt do
				table.insert(gsid_list_2,{gsid = v.gsid});
			end
		end
	end
	return gsid_list_2;
end
function CardsUnpackPage.ConvertList(gsid_list)
	local gsid_list_2 = {};
	if(gsid_list)then
		local k,v;
		for k,v in pairs(gsid_list) do
			local kk = 1;
			for kk = 1, v do
				table.insert(gsid_list_2,{gsid = k});
			end
		end
	end
	return gsid_list_2;
end
-- get cards from card pack
-- @param gsid: card pack gsid
-- @return: {[42101]=3,[41101]=10,}
function CardsUnpackPage.GetCardsFromCardPack(gsid)
	CardsUnpackPage.LoadConfig();
	local gsid_list = {};
	local nMagicdirt = nil;
	local rules = CardsUnpackPage.CardPack_eachpack[gsid];
	if(rules) then
		nMagicdirt = rules.magicdirt_count;
		local _, each_rule;
		for _, each_rule in ipairs(rules) do
			local fromset = each_rule.fromset;
			local multiplier = each_rule.multiplier;
			if(fromset and multiplier) then
				local card_series = CardsUnpackPage.CardPack_cardsets[fromset];
				local r = math.random(0, card_series.count);
				local _, each_pair;
				for _, each_pair in ipairs(card_series) do
					r = r - each_pair[2];
					if(r <= 0) then
						local gsid = each_pair[1];
						if(gsid ~= 0) then
							gsid_list[gsid] = (gsid_list[gsid] or 0) + multiplier;
						end
						break;
					end
				end
			end
		end
	end
	local gsid_list_2 = CardsUnpackPage.ConvertList(gsid_list);
	return gsid_list, nMagicdirt, gsid_list_2;
end
function CardsUnpackPage.LoadConfig()
	if(CardsUnpackPage.is_load)then
		return 
	end
	CardsUnpackPage.is_load = true;
	local CardPack_cardsets = {};
	local CardPack_eachpack = {};
	-- CardPack_cardsets is empty
	local filename = "config/Aries/CardPack.teen.xml";
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(xmlRoot) then
		local cardset_node;
		for cardset_node in commonlib.XPath.eachNode(xmlRoot, "/cardpacks/cardsets/set") do
			if(cardset_node.attr and cardset_node.attr.name and cardset_node.attr.gsids) then
				local name = cardset_node.attr.name;
				local gsids = cardset_node.attr.gsids;
				local card_series = {count = 0};
				-- parse card gsid and weight
				local card_gsid_weight_pair;
				for card_gsid_weight_pair in string.gmatch(gsids, "([^%(^%)]+)") do
					local card_gsid, weight = string.match(card_gsid_weight_pair, "^(%d-),(%d-)$");
					if(card_gsid and weight) then
						card_gsid = tonumber(card_gsid);
						weight = tonumber(weight);
						-- append to card series and inc card count
						card_series.count = card_series.count + weight * 10;
						table.insert(card_series, {card_gsid, weight * 10});
					end
				end
				CardPack_cardsets[name] = card_series;
			end
		end
		local pack_node;
		for pack_node in commonlib.XPath.eachNode(xmlRoot, "/cardpacks/pack") do
			if(pack_node.attr and pack_node.attr.gsid and pack_node.attr.magicdirt_count) then
				local gsid = pack_node.attr.gsid;
				local magicdirt_count = pack_node.attr.magicdirt_count;
				gsid = tonumber(gsid);
				magicdirt_count = tonumber(magicdirt_count);
				local rules = {magicdirt_count = magicdirt_count};
				local rule_node;
				for rule_node in commonlib.XPath.eachNode(pack_node, "/rule") do
					if(rule_node.attr and rule_node.attr.fromset and rule_node.attr.multiplier) then
						local fromset = rule_node.attr.fromset;
						local multiplier = tonumber(rule_node.attr.multiplier);
						table.insert(rules, {
							fromset = fromset,
							multiplier = multiplier,
						});
					end
				end
				CardPack_eachpack[gsid] = rules;
			end
		end
	end
	CardsUnpackPage.CardPack_cardsets = CardPack_cardsets;
	CardsUnpackPage.CardPack_eachpack = CardPack_eachpack;
end