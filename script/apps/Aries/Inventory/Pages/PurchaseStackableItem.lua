--[[
Title: code behind for page PurchaseStackableItem.html
Author(s): WangTian
Date: 2009/8/5
Desc:  script/apps/Aries/Inventory/Pages/PurchaseStackableItem.html
Use Lib:
-------------------------------------------------------
-------------------------------------------------------
]]
local PurchaseStackableItemPage = {};
commonlib.setfield("MyCompany.Aries.Inventory.PurchaseStackableItemPage", PurchaseStackableItemPage);

local item_name, item_gsid;
function PurchaseStackableItemPage.OnInit()
	PurchaseStackableItemPage.timer = PurchaseStackableItemPage.timer or commonlib.Timer:new({callbackFunc = function(timer)
		PurchaseStackableItemPage.CheckCount(item_name, item_gsid)
	end})
end

function PurchaseStackableItemPage.StartTimer(name, gsid)
	item_name, item_gsid = name, gsid;
	PurchaseStackableItemPage.timer:Change(0,30);
end

function PurchaseStackableItemPage.StopTimer()
	PurchaseStackableItemPage.timer:Change();
end

PurchaseStackableItemPage.lastValidValue = "1";
function PurchaseStackableItemPage.CheckCount(name, gsid)
	local ctl = CommonCtrl.GetControl(name);
	if(ctl) then
		local init_value = ctl:GetValue("count");
		local value = init_value;
		if(value) then
			if(string.match(value, "([^%d]+)")) then
				value = PurchaseStackableItemPage.lastValidValue;
			elseif(value == "") then
				value = PurchaseStackableItemPage.lastValidValue;
			else
				local count = tonumber(value);
				if(count > 99) then
					value = "99";
				elseif(count < 1) then
					value = "1";
				else
					value = tostring(tonumber(value));
				end
			end
		else
			value = "1";
		end
		
		-- refresh the description text
		if(PurchaseStackableItemPage.lastValidValue ~= value) then
			local ItemManager = Map3DSystem.Item.ItemManager;
			local hasGSItem = ItemManager.IfOwnGSItem;
			local name = "";
			local price = 0;
			local pbuyprice = 0;
			local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(gsid);
			if(gsItem) then
				name = gsItem.template.name;
				price = gsItem.ebuyprice;
				pbuyprice = gsItem.count;
			end
			local mymoney = 0;
			local my_p_money = 0;
			local bhas,_,_,count = hasGSItem(984);
			if (bhas and count) then
				my_p_money = count;
			end
			local ProfileManager = System.App.profiles.ProfileManager;
			local myInfo = ProfileManager.GetUserInfoInMemory(ProfileManager.GetNID());
			if(myInfo) then
				mymoney = myInfo.emoney;
			end
			local desc1 = "";
			local desc2 = "";
			if(pbuyprice and pbuyprice>0) then
				desc1 = value.."个"..name.."需要"..value * pbuyprice.."魔豆，你现在有"..my_p_money.."魔豆。";
				desc2 = "你确认要购买吗？";
			else
				-- check for discount value
				local isHalfPriceDay = false;
				local discount = MyCompany.Aries.Scene.GetServerObjectValue("EMoneyDiscount");
				if(discount and tonumber(discount) == 0.5) then
					isHalfPriceDay = true;
					price = price * tonumber(discount);
				end
				if(isHalfPriceDay) then
					desc1 = "今天是半价日，"..value.."个"..name.."需要"..value * price.."奇豆，";
					desc2 = "你现在有"..mymoney.."奇豆。你确认要购买吗？";
				else
					desc1 = value.."个"..name.."需要"..value * price.."奇豆，你现在有"..mymoney.."奇豆。";
					desc2 = "你确认要购买吗？";
				end
			end

			local VIP = commonlib.gettable("MyCompany.Aries.VIP");
			local bVIP=VIP.IsVIP();
			if (gsid==998) then
				local vipname="";
				if (System.options.version=="kids") then
					vipname = "魔法星";
				else
					vipname = "VIP";
				end
				if (bVIP) then
					desc2 ="获得能量石给魔法星补充能量, 你确认要购买吗？";
				else
					desc2 =string.format("能量石可以激活%s, 你确认要购买吗？",vipname);
				end   
			end
			ctl:SetValue("buydesc1", desc1);
			ctl:SetValue("buydesc2", desc2);
		end
		
		-- record the last valid count value and refresh the control is needed
		PurchaseStackableItemPage.lastValidValue = value;
		if(init_value ~= value) then
			ctl:SetValue("count", tostring(value));
		end
	end
end