--[[
Title: ItemSellPanel
Author(s): 
Date: 
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/ItemSellPanel.lua");
MyCompany.Aries.Desktop.ItemSellPanel.ShowPage(guid);
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
local ItemSellPanel = commonlib.gettable("MyCompany.Aries.Desktop.ItemSellPanel");

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

function ItemSellPanel.OnClickDiscardItem(guid)
	if(not DealDefend.CanPass())then
		return
	end
	
	local item = ItemManager.GetItemByGUID(guid);
	if( item ) then
		-- it must be item that is owned by the current user. 
		if(not item.nid or (tostring(item.nid)==tostring(System.User.nid)) )then
			
			local gsItem = ItemManager.GetGlobalStoreItemInMemory(item.gsid);
			if(gsItem)then
				if(gsItem.template.cansell) then
					local equipped_item, isEquipped = ItemManager.GetEquippedItem(gsItem);
					if(not isEquipped) then
						local __,__,__,copies = hasGSItem(item.gsid);
						
						_guihelper.Custom_MessageBox(format("你确定要丢弃<pe:slot guid='%d'style='height:48px;width:48px'/>么？<div style='color:#f02222'>温馨提示：丢弃掉的物品无法找回，请慎用此功能！</div>", guid),function(result)
							if(result == _guihelper.DialogResult.Yes)then
								ItemManager.SellItem(guid, copies or 1, function(msg) end, function(msg)
									if(msg and msg.issuccess)then
									end			
								end);
							end
						end,_guihelper.MessageBoxButtons.YesNo);
						return;
					else
						_guihelper.MessageBox("你正在使用中的物品不能丢弃，请脱下后再丢弃");
						return;
					end
				end
			end
		else
			_guihelper.MessageBox("这个物品不能丢弃. 它是别人的物品");
			return;
		end
	end
	_guihelper.MessageBox("这个物品不能丢弃.");
end

-- call this function whenever a user right click a user item. 
function ItemSellPanel.OnClickSellItem(guid)
	if(not DealDefend.CanPass())then
		return
	end
	
	local item = ItemManager.GetItemByGUID(guid);
	if( item ) then
		-- it must be item that is owned by the current user. 
		if(not item.nid or (tostring(item.nid)==tostring(System.User.nid)) )then
			
			local gsItem = ItemManager.GetGlobalStoreItemInMemory(item.gsid);
			if(gsItem)then
				if(gsItem.template.cansell) then
					local equipped_item, isEquipped = ItemManager.GetEquippedItem(gsItem);
					if(not isEquipped) then
						if(CommonClientService.IsKidsVersion())then
							return ItemSellPanel.ShowPage(guid);
						else
							local __,__,__,copies = hasGSItem(item.gsid);
							copies = copies or 0;
							if(copies == 1)then
								ItemSellPanel.ShowSingleItemPage(item.gsid);
								--ItemSellPanel.DoSellItem(item.gsid,1);
							else
								ItemSellPanel.ShowPage(guid);
							end
							return
						end
					else
						_guihelper.MessageBox("你正在使用中的物品不能出售，请脱下后再出售");
						return;
					end
				end
			end
		else
			_guihelper.MessageBox("这个物品不能出售. 它是别人的物品");
			return;
		end
	end
	_guihelper.MessageBox("这个物品不能出售.");
end

function ItemSellPanel.ShowPage(guid)
	ItemSellPanel.guid = tonumber(guid);
	if(System.options.version == "kids")then
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/Desktop/ItemSellPanel.html", 
			name = "ItemSellPanel.ShowPage", 
			app_key=MyCompany.Aries.app.app_key,
			isShowTitleBar = false,
			DestroyOnClose = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 10,
			isTopLevel = false,
			allowDrag = false,
			directPosition = true,
			enable_esc_key = true,
			align = "_ct",
			x = -361/2,
			y = -400/2,
			width = 361,
			height = 400,
		});
	else
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/Desktop/ItemSellPanel.teen.html", 
			name = "ItemSellPanel.ShowPage", 
			app_key=MyCompany.Aries.app.app_key,
			isShowTitleBar = false,
			DestroyOnClose = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 10,
			isTopLevel = false,
			allowDrag = false,
			directPosition = true,
			enable_esc_key = true,
			align = "_ct",
			x = -466/2,
			y = -355/2,
			width = 466,
			height = 355,
		});
	end
end

function ItemSellPanel.Init()
	ItemSellPanel.page = document:GetPageCtrl();
	if(ItemSellPanel.guid)then
		local item = Map3DSystem.Item.ItemManager.GetItemByGUID(ItemSellPanel.guid);
		if(item)then
			local item2 = Map3DSystem.Item.ItemManager.GetGlobalStoreItemInMemory(item.gsid);
			if(item2)then
				ItemSellPanel.item = item2;
			end
			ItemSellPanel.page:SetValue("count", ItemSellPanel.GetCount() or 0);
		end
	end

	--ItemSellPanel.timer = ItemSellPanel.timer or commonlib.Timer:new({callbackFunc = function(timer)
		-- TODO: all user to enter count like in PurchaseStackableItem.html
	--end})
end

function ItemSellPanel.GetPrice()
	if(ItemSellPanel.item)then
		return ItemSellPanel.item.esellprice;
	end
end

function ItemSellPanel.GetCount()
	if(ItemSellPanel.item)then
		local bhas,_,__,count = hasGSItem(ItemSellPanel.item.gsid);
		if(bhas)then
			return count;
		else
			return 0;
		end
	end
end


function ItemSellPanel.GetPriceText()
	local _price = 0;
	local _num = 0;
	if(ItemSellPanel.item)then
		_num = tonumber(ItemSellPanel.page:GetValue("count")) or 0;
		_price =  tonumber(ItemSellPanel.item.esellprice) or 0;
		--commonlib.echo("!!:GetPriceText");
        --commonlib.echo(_num);
        --commonlib.echo(_price);
		local s=string.format("收购价：%d %s",_price * _num, System.options.haqi_GameCurrency);
		return s;
		-- return "收购价：" .. tostring(_price * _num).."奇豆";
	end
end

function ItemSellPanel.GetIcon()
	if(ItemSellPanel.item)then
		return ItemSellPanel.item.icon;
	end
end

function ItemSellPanel.OnClickSell()
	if(ItemSellPanel.item)then	
		local cnt = tonumber(ItemSellPanel.page:GetValue("count") or 0);
		ItemSellPanel.page:CloseWindow();
		ItemSellPanel.DoSellItem(ItemSellPanel.item.gsid,cnt);
	end
end
function ItemSellPanel.DoSellItem(gsid,cnt)
	if(not gsid)then return end
	cnt = cnt or 1;
	local bHas,guid,__,copies = hasGSItem(gsid);
	copies = copies or 0;
	if(cnt > copies)then
		return
	end
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(gsItem)then
		if(not gsItem.template.cansell) then
			_guihelper.MessageBox("这个物品不能出售.");
			return;
		end
		ItemManager.SellItem(guid, cnt, function(msg) end, function(msg)
			if(msg and msg.issuccess)then
			end			
		end);			
	end
end
function ItemSellPanel.ShowSingleItemPage(gsid)
	if(System.options.version == "kids")then
	else
		if(not gsid)then
			return
		end
		local url = string.format("script/apps/Aries/Desktop/Functions/ItemSellPanelSingleItem.teen.html?gsid=%d",gsid);
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = url, 
			name = "ItemSellPanel.ShowSingleItemPage", 
			app_key=MyCompany.Aries.app.app_key,
			isShowTitleBar = false,
			DestroyOnClose = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 10,
			isTopLevel = false,
			allowDrag = false,
			directPosition = true,
			enable_esc_key = true,
			align = "_ct",
			x = -466/2,
			y = -355/2,
			width = 466,
			height = 355,
		});
	end
end