--[[
Title: FruitSaleShop
Author(s): Leio
Date: 2010/03/08

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Farm/30368_FruitSaleShop.lua
------------------------------------------------------------
]]

-- create class
local libName = "FruitSaleShop";
local FruitSaleShop = {
	selected_item = nil,
	sell_item = nil,
	
	filter = {
		[17045] = true,
	}
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.FruitSaleShop", FruitSaleShop);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- FruitSaleShop.main
function FruitSaleShop.main()
	local self = FruitSaleShop; 
end

function FruitSaleShop.OnInit()
	local self = FruitSaleShop; 
	self.page = document:GetPageCtrl();
end
function FruitSaleShop.PreDialog(npc_id, instance)
	local self = FruitSaleShop; 
	self.selected_item = nil;
	self.sell_item = nil;
	self.DataAdapter();
	if(self.IsEmpty())then
		NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
		_guihelper.Custom_MessageBox("<div style='margin-left:15px;margin-top:20px;text-align:center'>你现在没有可回收的果实，快去买点种子回家种上吧。</div>",function(result)
			if(result == _guihelper.DialogResult.OK)then
			end
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		return false
	end
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/NPCs/Farm/30368_FruitSaleShop_panel.html", 
			name = "FruitSaleShop_panel.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			isTopLevel = true,
			allowDrag = false,
			directPosition = true,
				align = "_ct",
				x = -320,
				y = -250,
				width = 720,
				height = 480,
		});
	if(self.fruits)then
		local item = self.fruits[1];
		if(item)then
			MyCompany.Aries.Quest.NPCs.FruitSaleShop.DoClick(item.guid);
		end
	end
	return false;
end
function FruitSaleShop.IsEmpty()
	local self = FruitSaleShop;
	if(not self.fruits)then
		return true;
	end
	local k,v;
	for k,v in ipairs(self.fruits) do
		if(v.guid ~= 0)then
			return false;
		end
	end
	return true;
end
function FruitSaleShop.DataAdapter()
	local self = FruitSaleShop;
	--local ItemManager = System.Item.ItemManager;
	--local count = ItemManager.GetItemCountInBag(42);
	--local fruits;
	--if(count and count > 0)then
		--for i = 1, count do
			--local item = ItemManager.GetItemByBagAndOrder(42, i);
			--if(item)then
			--
			--end
		--end
	--end
	local fruits = Map3DSystem.App.HomeLand.HomeLandGateway.plant_fruit_map;
		commonlib.echo("==============fruits");
		commonlib.echo(fruits);
	if(not fruits)then return end
	local k,v;
	local result = {};
	for k,v in pairs(fruits) do
		local gsid = v;
		if(not self.filter[gsid])then
			local has,guid,bag,copies = hasGSItem(gsid);
			commonlib.echo("==============gsid");
			commonlib.echo(gsid);
			copies = copies or 0;
			if(has)then
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid)
				if(gsItem) then
					local icon = gsItem.icon;
					local price = gsItem.esellprice;
					
					local o = {
						gsid = gsid,
						copies = copies,
						icon = icon,
						price = price,
						guid = guid,
					}
					commonlib.echo("===============insert item in FruitSaleShop.DataAdapter");
					commonlib.echo(o);
					table.insert(result,o);
				end 
			end
		end
	end
	local count = #result;
	-- fill the 12 tiles per page
	local displaycount = math.ceil(count/12) * 12;
	if(count == 0) then
		displaycount = 12;
	end
	local i;
	for i = count + 1, displaycount do
		result[i] = {guid = 0};
	end
					
	self.fruits = result;
end
function FruitSaleShop.DoClick(guid)
	local self = FruitSaleShop;
	guid = tonumber(guid);
	if(not guid)then return end
	local item = ItemManager.GetItemByGUID(guid);
	if(item)then
		local gsid = item.gsid;
		local has,guid,bag,copies = hasGSItem(gsid);
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid)
		if(gsItem) then
			local name = gsItem.template.name;
			local icon = gsItem.icon;
			local price = gsItem.esellprice;
			self.selected_item = {
				name = name,
				icon = icon,
				price = price,
				copies = copies,
				gsid = gsid,
			}
			if(self.page)then
				self.page:SetValue("icon",icon);
				self.page:Refresh(0.01);
			end
		end
	end
end
---clear selected item and refresh page when deal is successful
function FruitSaleShop.RefreshPage()
	local self = FruitSaleShop;
	if(self.page)then
		self.selected_item = nil;
		self.sell_item = nil;
		self.DataAdapter();
		if(self.IsEmpty())then
			self.page:CloseWindow();
		else
			self.page:SetValue("icon","");
			self.page:Refresh(0.01);
			if(self.fruits)then
				local item = self.fruits[1];
				if(item)then
					MyCompany.Aries.Quest.NPCs.FruitSaleShop.DoClick(item.guid);
				end
			end
		end
	end
end
function FruitSaleShop.GetMax()
	local self = FruitSaleShop;
	if(self.selected_item)then
		local num =  self.selected_item.copies or 0;
		return num;
	end
	return 0;
end
function FruitSaleShop.DoSell()
	local self = FruitSaleShop;
	if(self.selected_item and self.page)then
		local max = self.GetMax();
		local sell_num = self.page:GetValue("count");
		sell_num = tonumber(sell_num);
		if(sell_num)then
			sell_num = math.min(sell_num,max);
			self.sell_item = commonlib.deepcopy(self.selected_item);
			self.sell_item.num = sell_num;
		
			System.App.Commands.Call("File.MCMLWindowFrame", {
				url = "script/apps/Aries/NPCs/Farm/30368_FruitSaleShop_panel_confirm.html", 
				name = "FruitSaleShop_panel_confirm.ShowPage", 
				app_key=MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				style = CommonCtrl.WindowFrame.ContainerStyle,
				zorder = 1,
				isTopLevel = true,
				allowDrag = false,
				directPosition = true,
					align = "_ct",
					x = -470/2,
					y = -250,
					width = 470,
					height = 340,
			});
			
		end
	end
end
function FruitSaleShop.SellItem()
	local self = FruitSaleShop;
	 local info = self.GetSellItemInfo();
    if(not info)then return end
    local gsid = info.gsid;
    local has,guid,bag,copies = hasGSItem(gsid);
    if(has)then
		local count = info.num;
		local bean = info.num * info.price;
		commonlib.echo("========before sell item in FruitSaleShop");
		commonlib.echo(info);
		ItemManager.SellItem(guid, count, function(msg) end, function(msg)
			commonlib.echo("========before sell item in FruitSaleShop");
			commonlib.echo(msg);
			if(msg and msg.issuccess)then
				local s = string.format([[<div style="margin-left:20px;margin-top:20px;text-align:center">恭喜你交易成功！你获得了%d奇豆。</div>]],bean);
				_guihelper.MessageBox(s,function(result)
					if(result == _guihelper.DialogResult.OK)then
						MyCompany.Aries.Quest.NPCs.FruitSaleShop.RefreshPage();
					end
				end,_guihelper.MessageBoxButtons.OK);
			end
		end)
    end
end
function FruitSaleShop.GetSellItemInfo()
	local self = FruitSaleShop;
	return self.sell_item;
end
function FruitSaleShop.DS_Func(index)
	local self = FruitSaleShop;
	if(not self.fruits)then return 0 end
	if(index == nil) then
		return #self.fruits ;
	else
		return self.fruits[index];
	end
end
