--[[
Title: Gifting For recharge in holiday
Author(s): LiPeng
Date: 2012/6/27
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Gift/GiftingForRechargeInHoliday.lua");
local GiftingForRechargeInHoliday = commonlib.gettable("MyCompany.Aries.Gift.GiftingForRechargeInHoliday");
GiftingForRechargeInHoliday.ShowPage();
-------------------------------------------------------
]]
local ItemManager = System.Item.ItemManager;
local GiftingForRechargeInHoliday = commonlib.gettable("MyCompany.Aries.Gift.GiftingForRechargeInHoliday");

function GiftingForRechargeInHoliday.init()
	if(GiftingForRechargeInHoliday.inited) then
		return;
	end
	GiftingForRechargeInHoliday.inited = true;
	local presList = {[-14] = "战斗等级",[-17] = "魔法星等级",[-19] = "精力值",};
	local bags = {17472,17473,17474,17475};
	GiftingForRechargeInHoliday.giftbags = {};
	local k,v;
	for k,v in ipairs(bags) do
		local item = {};
		item.gsid = v;
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(v);
		local exid = gsItem.template.stats[47];
		item.exid = exid;
		local exItem = ItemManager.GetExtendedCostTemplateInMemory(exid);
		item.goods = {};
		local kk,vv;
		for kk,vv in ipairs(exItem.tos) do
			if(vv.key >0 and vv.key < 50000 and vv.value > 0) then
				table.insert(item.goods,{gsid = vv.key,count = vv.value});
			end
		end
		local pk,pv;
		local s = "";
		for pk,pv in ipairs(exItem.pres) do
			if(presList[pv.key]) then
				if(s ~= "") then
					s = s..",";
				end
				s = s..presList[pv.key]..pv.value.."可以换购";
			end
			if(tonumber(pv.key) == -14) then
				item.level = pv.value;
			end
		end
		if(not item.level) then
			item.level = 0;
		end
		local name = gsItem.template.name;
		item.des = s;
		item.name = name;
		if(item.gsid == 17472 or item.gsid == 17473) then
			--table.insert(item.goods,1,{gsid = 10187,count = 1});
		end
		table.insert(GiftingForRechargeInHoliday.giftbags,item);
	end
end

function GiftingForRechargeInHoliday.ShowPage()
	local params = {
		url = "script/apps/Aries/Gift/GiftingForRechargeInHoliday.html",
		name = "GiftingForRechargeInHoliday.ShowPage", 
		app_key=MyCompany.Aries.app.app_key, 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		enable_esc_key = true,
		style = CommonCtrl.WindowFrame.ContainerStyle,
		allowDrag = true,
		zorder = 10,
		directPosition = true,
			align = "_ct",
			x = -606/2,
			y = -470/2,
			width = 605,
			height = 470,
	};
	System.App.Commands.Call("File.MCMLWindowFrame", params);	
end