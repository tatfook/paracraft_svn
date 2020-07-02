--[[
Title: FisherHanter
Author(s): Leio
Date: 2010/03/08

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/Farm/30368_FisherHanter.lua
------------------------------------------------------------
]]

-- create class
local libName = "FisherHanter";
local FisherHanter = {
	selected_item = nil,
	sell_item = nil,
	fruit_map = {
		17106,--臭脚丫马靴
		17107,--胖乎乎水母
		17108,--小毛头泥鳅
		17109,--呆呆大头鱼
		17110,--大个头螃蟹
		17111,--闪闪皇冠鱼	
	},
	filter = {
	}
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.FisherHanter", FisherHanter);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

-- FisherHanter.main
function FisherHanter.main()
	local self = FisherHanter; 
end

function FisherHanter.OnInit()
	local self = FisherHanter; 
	self.page = document:GetPageCtrl();
end
function FisherHanter.DoOpen()
	local self = FisherHanter; 
	self.selected_item = nil;
	self.sell_item = nil;
	self.DataAdapter();
	if(self.IsEmpty())then
		NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
		_guihelper.Custom_MessageBox("<div style='margin-left:15px;margin-top:20px;text-align:center'>你还没有海产物呢，赶紧去休闲渔场捕点来吧！</div>",function(result)
			if(result == _guihelper.DialogResult.OK)then
			end
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
		return
	end
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/NPCs/TownSquare/30389_FisherHanter_panel.html", 
			name = "FisherHanter_panel.ShowPage", 
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
			MyCompany.Aries.Quest.NPCs.FisherHanter.DoClick(item.guid);
		end
	end
end
function FisherHanter.PreDialog(npc_id, instance)
	local self = FisherHanter; 
end
function FisherHanter.IsEmpty()
	local self = FisherHanter;
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
function FisherHanter.DataAdapter()
	local self = FisherHanter;
	local fruits = self.fruit_map;
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
					commonlib.echo("===============insert item in FisherHanter.DataAdapter");
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
function FisherHanter.DoClick(guid)
	local self = FisherHanter;
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
function FisherHanter.RefreshPage()
	local self = FisherHanter;
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
					MyCompany.Aries.Quest.NPCs.FisherHanter.DoClick(item.guid);
				end
			end
		end
	end
end
function FisherHanter.GetMax()
	local self = FisherHanter;
	if(self.selected_item)then
		local num =  self.selected_item.copies or 0;
		return num;
	end
	return 0;
end
function FisherHanter.DoSell()
	local self = FisherHanter;
	if(self.selected_item and self.page)then
		local max = self.GetMax();
		local sell_num = self.page:GetValue("count");
		sell_num = tonumber(sell_num);
		if(sell_num)then
			sell_num = math.min(sell_num,max);
			self.sell_item = commonlib.deepcopy(self.selected_item);
			self.sell_item.num = sell_num;
		
			System.App.Commands.Call("File.MCMLWindowFrame", {
				url = "script/apps/Aries/NPCs/TownSquare/30389_FisherHanter_panel_confirm.html", 
				name = "FisherHanter_panel_confirm.ShowPage", 
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
function FisherHanter.SellItem()
	local self = FisherHanter;
	 local info = self.GetSellItemInfo();
    if(not info)then return end
    local gsid = info.gsid;
    local has,guid,bag,copies = hasGSItem(gsid);
    if(has)then
		local count = info.num;
		local bean = info.num * info.price;
		commonlib.echo("========before sell item in FisherHanter");
		commonlib.echo(info);
		ItemManager.SellItem(guid, count, function(msg) end, function(msg)
			commonlib.echo("========before sell item in FisherHanter");
			commonlib.echo(msg);
			if(msg and msg.issuccess)then
				local s = string.format([[<div style="margin-left:20px;margin-top:20px;text-align:center">恭喜你交易成功！你获得了%d奇豆。</div>]],bean);
				_guihelper.MessageBox(s,function(result)
					if(result == _guihelper.DialogResult.OK)then
						MyCompany.Aries.Quest.NPCs.FisherHanter.RefreshPage();
					end
				end,_guihelper.MessageBoxButtons.OK);
			end
		end)
    end
end
function FisherHanter.GetSellItemInfo()
	local self = FisherHanter;
	return self.sell_item;
end
function FisherHanter.DS_Func(index)
	local self = FisherHanter;
	if(not self.fruits)then return 0 end
	if(index == nil) then
		return #self.fruits ;
	else
		return self.fruits[index];
	end
end
