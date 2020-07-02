--[[
Title: 
Author(s): Leio	
Date: 2012/10/29
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Inventory/Cards/MagicCardShopPage.lua");
local MagicCardShopPage = commonlib.gettable("MyCompany.Aries.Inventory.Cards.MagicCardShopPage");
MagicCardShopPage.ShowPage();
-------------------------------------------------------
]]

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
local MagicCardShopPage = commonlib.gettable("MyCompany.Aries.Inventory.Cards.MagicCardShopPage");

if(System.options.version=="teen") then
	MagicCardShopPage.cards_list = {
		{label = "稀有魔法牌包", card_package_gsid = 17297, gsid = 17264, need_cnt_1 = 20, need_cnt_2 = 38, coin_gsid = 984, exid_1 = 30355, exid_2 = 30717, bg = "Texture/Aries/MagicCardShop/MagicBagLv1_32bits.png;0 0 153 196", },
		{label = "珍稀魔法牌包", card_package_gsid = 17295, gsid = 17290, need_cnt_1 = 20, need_cnt_2 = 380, coin_gsid = 984, exid_1 = 30356, exid_2 = 30718, bg = "Texture/Aries/MagicCardShop/MagicBagLv2_32bits.png;0 0 153 196",  },
		{label = "史诗魔法牌包", card_package_gsid = 17296, gsid = 17291, need_cnt_1 = 20, need_cnt_2 = 3800, coin_gsid = 984, exid_1 = 30357, exid_2 = 30719, bg = "Texture/Aries/MagicCardShop/MagicBagLv3_32bits.png;0 0 153 196",  },
	}
elseif(System.options.version=="kids") then
	MagicCardShopPage.cards_list = {
		{label = "精良魔法牌包", card_package_gsid = 17706, gsid = 17702, need_cnt_1 = 20, need_cnt_2 = 38, coin_gsid = 984, exid_1 = 2264, exid_2 = 0, bg = "Texture/Aries/MagicCardShop/Haqi1MagicBagLv1_32bits.png;0 0 153 196", },
		{label = "稀有魔法牌包", card_package_gsid = 17707, gsid = 17704, need_cnt_1 = 20, need_cnt_2 = 380, coin_gsid = 984, exid_1 = 2265, exid_2 = 0, bg = "Texture/Aries/MagicCardShop/Haqi1MagicBagLv2_32bits.png;0 0 153 196",  },
		{label = "传奇魔法牌包", card_package_gsid = 17708, gsid = 17705, need_cnt_1 = 20, need_cnt_2 = 3800, coin_gsid = 984, exid_1 = 2266, exid_2 = 0, bg = "Texture/Aries/MagicCardShop/Haqi1MagicBagLv3_32bits.png;0 0 153 196",  },
	}
end

function MagicCardShopPage.OnInit()
	MagicCardShopPage.page = document:GetPageCtrl();
end
function MagicCardShopPage.ShowPage()
	local url = "script/apps/Aries/Inventory/Cards/MagicCardShopPage.teen.html";
	if(System.options.version=="kids") then
		url = "script/apps/Aries/Inventory/Cards/MagicCardShopPage.kids.html";
	end
	local params = {
			url = url,
			name = "MagicCardShopPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			enable_esc_key = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			directPosition = true,
			zorder = 1,
			align = "_ct",
			x = -640/2,
			y = -445/2,
			width = 640,
			height = 445,
			cancelShowAnimation = true,
		}
	System.App.Commands.Call("File.MCMLWindowFrame", params);	
	if(params._page) then
		params._page.OnClose = function(bDestroy)
			MagicCardShopPage.page = nil;
		end
	end	
end
function MagicCardShopPage.DS_Func(index)
    if(not MagicCardShopPage.cards_list)then return 0 end
	if(index == nil) then
		return #(MagicCardShopPage.cards_list);
	else
		return MagicCardShopPage.cards_list[index];
	end
end
---------------------------------------开卡包动画

function MagicCardShopPage.OpenCardpack_Handle(gsid_list)
	if(not gsid_list)then return end
	local card_source_list = MagicCardShopPage.ConvertList_ipairs(gsid_list);
	MagicCardShopPage.card_source_list = card_source_list;
	local url = "script/apps/Aries/Inventory/Cards/MagicCardUnpackMotion.teen.html";
	local _this = ParaUI.GetUIObject("MagicCardShopPage.MotionContainer");
	if(_this:IsValid() == false) then
		_this = ParaUI.CreateUIObject("container", "MagicCardShopPage.MotionContainer", "_fi", 0, 0, 0, 0);
		_this.background = "";
		_this.zorder = 1000;
		_this:GetAttributeObject():SetField("ClickThrough", true);
		_this:AttachToRoot();
		MagicCardShopPage.motion_page = System.mcml.PageCtrl:new({url = url, click_through = true});
		MagicCardShopPage.motion_page:Create("MagicCardShopPage.MotionPage", _this, "_fi", 0, 0, 0, 0);
	else
		if(MagicCardShopPage.motion_page) then
			MagicCardShopPage.motion_page:Init(url);
		end
	end
	_this.visible = true;
end
function MagicCardShopPage.ConvertList_ipairs(gsid_list)
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
