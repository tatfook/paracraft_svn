--[[
Title: 30095_AngieGranny_Shop
Author(s): 
Date: 
Desc: 
use the lib:
------------------------------------------------------------
script/apps/Aries/NPCs/Playground/30095_AngieGranny_Shop.lua
------------------------------------------------------------
]]

-- create class
local AngieGranny_Shop = commonlib.gettable("MyCompany.Aries.Quest.NPCs.AngieGranny_Shop");
--commonlib.setfield("MyCompany.Aries.Quest.NPCs.AngieGranny_Shop", AngieGranny_Shop);

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
local last_category = "12";

function AngieGranny_Shop.ShowPage()
	NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
	local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
	if(not DealDefend.CanPass())then
		return
	end
	System.App.Commands.Call("File.MCMLWindowFrame", {
		url = "script/apps/Aries/NPCs/Playground/30095_AngieGranny_Shop_panel.html", 
		name = "AngieGranny_confirm.ShowPage", 
		app_key=MyCompany.Aries.app.app_key,
		isShowTitleBar = false,
		DestroyOnClose = true,
		style = CommonCtrl.WindowFrame.ContainerStyle,
		zorder = 1,
		isTopLevel = true,
		allowDrag = false,
		directPosition = true,
		align = "_ct",
		x = -320,
		y = -250,
		width = 750,
		height = 480,
	});
	-- AngieGranny_Shop.LoadData();
end

function AngieGranny_Shop.SelectCate(cates, bNoRefresh)
	last_category = cates;
	local _self = AngieGranny_Shop;
	local _datas = {};
	_self.datas = nil;
	local IsLocal = true;
	for _bag in string.gfind(cates, "[^_]+") do
		ItemManager.GetItemsInBag(_bag, "AngieGranny_Shop.SelectCate__".._bag, function(msg)
			if(msg and msg.items) then
				local _i;
				for _i = 1, ItemManager.GetItemCountInBag(tonumber(_bag)) do
					local _item = ItemManager.GetItemByBagAndOrder(tonumber(_bag), _i);
					if(_item ~= nil) then
						local _gsid = _item.gsid;
						local _gsItem = ItemManager.GetGlobalStoreItemInMemory(_gsid);
						if(_gsItem ~= nil and _gsItem.template.cansell) then
							local _icon = _gsItem.icon;
							local _price = _gsItem.esellprice;
							local _o = {
								gsid = _gsid,
								copies = _item.copies,
								icon = _icon,
								price = _price,
								guid = _item.guid,
							}
							table.insert(_datas,_o);
						end
					end
				end
				local _count = #_datas;
				local _displaycount = math.ceil(_count/12) * 12;
				if(_count == 0) then
					_displaycount = 12;
				end
				local _i;
				--for _i = _count + 1, _displaycount do
					--_datas[_i] = {guid = 0};
				--end
				_self.datas = _datas;
				if(_count > 0) then
					local _curSelected = _self.datas[1];
					if(_curSelected) then
						_self.selected_item = _curSelected;
						MyCompany.Aries.Quest.NPCs.AngieGranny_Shop.DoClick(_curSelected.guid);
					end
				else
					_self.selected_item = nil;
				end
				--commonlib.echo("!!:SelectCate 0");
				--commonlib.echo(_self.selected_item);
				if(not IsLocal or not bNoRefresh) then
					--commonlib.echo("!!:SelectCate 1");
					
					_self.page:Refresh(0.01);
				end
			end
		end, "access plus 1 minutes");
	end
	IsLocal = false;
	--_guihelper.MessageBox(commonlib.serialize(_cs));
end

function AngieGranny_Shop.OnInit()
	AngieGranny_Shop.page = document:GetPageCtrl();
	AngieGranny_Shop.page:SetValue("radioCate", last_category)
	AngieGranny_Shop.SelectCate(last_category, true);
end

function AngieGranny_Shop.LoadData()
end

function AngieGranny_Shop.DS_Func(index)
	local _self = AngieGranny_Shop;
	if(not _self.datas)then return 0 end
	if(index == nil) then
		return #_self.datas;
	else
		return _self.datas[index];
	end
end

function AngieGranny_Shop.DoClick(guid)
	local _self = AngieGranny_Shop;
	_self.page:SetValue("count", "1");
	guid = tonumber(guid);
	if(not guid)then return end
	local _item = ItemManager.GetItemByGUID(guid);
	if(_item)then
		local _gsid = _item.gsid;
		local _has,_guid,_bag,_copies = hasGSItem(_gsid, nil, 10001); -- exclude 10001 homeland bag
		local _gsItem = ItemManager.GetGlobalStoreItemInMemory(_gsid);
		if(_gsItem) then
			local _name = _gsItem.template.name;
			local _icon = _gsItem.icon;
			local _price = _gsItem.esellprice;
			_self.selected_item = {
				name = _name,
				icon = _icon,
				price = _price,
				copies = _copies,
				gsid = _gsid,
			}
			if(_self.page)then
				_self.page:SetValue("icon", _icon);
				--_self.page:SetValue("getDesc1_txt", ("收购价：" .. tostring(_price)));
				local _desc = "请输入出售数量(";
				local _max = AngieGranny_Shop.GetMax();
				if(_max > 1) then
					_desc = _desc .. "1-" .. tostring(_max)
				else
					_desc = _desc .. tostring(_max);
				end
				_desc = _desc .. ")";
				_self.page:SetValue("getDesc2_txt", _desc);
				AngieGranny_Shop.SetPriceText();
			end
		end
	end
end

function AngieGranny_Shop.GetMax()
	local _self = AngieGranny_Shop;
	if(_self.selected_item)then
		local _num =  _self.selected_item.copies or 0;
		return _num;
	end
	return 0;
end

function AngieGranny_Shop.SetPriceText()
	local _self = AngieGranny_Shop;
	local _price = 0;
	local _num = 0;
	if(_self.selected_item)then
		_num = tonumber(_self.page:GetValue("count"));
		_price =  tonumber(_self.selected_item.price);
		--_guihelper.MessageBox("NUM:" .. commonlib.serialize(_self.selected_item));
	end
	_self.page:SetValue("getDesc1_txt", ("收购价：" .. tostring(_price * _num)));
end

function AngieGranny_Shop.DoSell()
	local _self = AngieGranny_Shop;
	if(_self.selected_item and _self.page)then
		local _max = _self.GetMax();
		local _num = tonumber(_self.page:GetValue("count"));
		if(_num > _max) then
			_num = _max;
			_self.page:SetValue("count", tostring(_num));
		elseif(_num <= 0) then
			_num = 1;
		end
		_self.SetPriceText();
		_self.sell_item = commonlib.deepcopy(_self.selected_item);
		_self.sell_item.num = _num;
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/NPCs/Playground/30095_AngieGranny_Shop_confirm.html", 
			name = "AngieGranny_Shop_confirm.ShowPage", 
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

function AngieGranny_Shop.GetSellItem()
	return AngieGranny_Shop.sell_item;
end

function AngieGranny_Shop.SellItem()
	local _self = AngieGranny_Shop;
	local _info = _self.GetSellItem();
    if(not _info)then return end
    local _gsid = _info.gsid;
    local _has,_guid,_bag,_copies = hasGSItem(_gsid, nil, 10001); -- exclude 10001 homeland bag
    if(_has)then
		local _count = _info.num;
		local _bean = _info.num * _info.price;
		ItemManager.SellItem(_guid, _count, function(msg) end, function(msg)
			--commonlib.echo("========before Sell Item:");
			--commonlib.echo(msg);
			if(msg and msg.issuccess)then
				--_self.selected_item = nil;
				local _s = string.format([[<div style="margin-left:20px;margin-top:20px;text-align:center">恭喜你交易成功！你获得了%d奇豆。</div>]], _bean);
				_guihelper.MessageBox(_s,function(result)
					if(result == _guihelper.DialogResult.OK)then
						--MyCompany.Aries.Quest.NPCs.AngieGranny_Shop.page.CloseWindow();
					end
				end,_guihelper.MessageBoxButtons.OK);
				if(not AngieGranny_Shop.datas or #(AngieGranny_Shop.datas) <= 0)then
					AngieGranny_Shop.selected_item = nil;
				end

				if(AngieGranny_Shop.page)then
					AngieGranny_Shop.page:Refresh(0.01);
				end
			end
		end)
    end
end