--[[
Title: SueSue_equipment_cutgem_panel
Author(s): Leio
Date: 2010/11/30

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/30042_SueSue_equipment_cutgem_panel.lua");
MyCompany.Aries.Quest.NPCs.SueSue_equipment_cutgem_panel.ShowPage();

NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/30042_SueSue_equipment_cutgem_panel.lua");
local bags = {0,1};
MyCompany.Aries.Quest.NPCs.SueSue_equipment_cutgem_panel.GetItemsFromBags(bags,function(msg)
	commonlib.echo(msg);
end,cachepolicy)

NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/30042_SueSue_equipment_cutgem_panel.lua");
MyCompany.Aries.Quest.NPCs.SueSue_equipment_cutgem_panel.OnlyRefreshPage();
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
local SueSue_equipment_cutgem_panel = {
	selected_gsid = nil,--选中的装备gsid

	gem_gsids = {},--镶嵌宝石列表
	selected_index = nil,--选择第几步
	types_index = nil,--第一步当中，装备的分类索引 1 :all 
	all_bags = {
		{0, 1, 10010},
		{12},
		{12},
	},
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.SueSue_equipment_cutgem_panel", SueSue_equipment_cutgem_panel);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
local LOG = LOG;

function SueSue_equipment_cutgem_panel.GetDataSource()
	local self = SueSue_equipment_cutgem_panel;
	local gsid = self.selected_gsid;
    local gem_gsids = self.gem_gsids;
    if(gsid)then
        local bHas,guid = hasGSItem(gsid);
        if(bHas)then
            local item = ItemManager.GetItemByGUID(guid);
            if(item and item.GetSocketedGems)then
                local gems = item:GetSocketedGems() or {};
                local k,v;
                for k,v in ipairs(gems) do
                    table.insert(gem_gsids,{gsid = v});
                end
            end
        end
    end
end
function SueSue_equipment_cutgem_panel.DS_Func_panel(index)
	local self = SueSue_equipment_cutgem_panel;
	if(not self.selected_items)then return 0 end
	if(index == nil) then
		return #(self.selected_items);
	else
		return self.selected_items[index];
	end
end
function SueSue_equipment_cutgem_panel.GetPageCtrl()
	local self = SueSue_equipment_cutgem_panel; 
	return self.page;
end
function SueSue_equipment_cutgem_panel.ClosePage()
	local self = SueSue_equipment_cutgem_panel; 
	if(self.page)then
		self.page:CloseWindow();
	end
end
function SueSue_equipment_cutgem_panel.DoClear()
	local self = SueSue_equipment_cutgem_panel; 
	self.selected_index = 1;
	self.types_index = 1;
	self.selected_gsid = nil;
	self.selected_items = nil;

	self.gem_gsids = {};
end
function SueSue_equipment_cutgem_panel.GetBags()
	local self = SueSue_equipment_cutgem_panel; 
	if(self.selected_index)then
		local bags = self.all_bags[self.selected_index];
		return bags;
	end
end
--更改大的分类
function SueSue_equipment_cutgem_panel.DoChange(index,types_index)
	local self = SueSue_equipment_cutgem_panel; 
	index = tonumber(index);
	types_index = tonumber(types_index);
	--大的分类
	self.selected_index = index or 1;
	self.types_index = types_index or 1;
	local bags = self.GetBags();
	SueSue_equipment_cutgem_panel.GetItemsFromBags(bags,function(msg)
		if(msg)then
			self.selected_items = nil;
			if(not msg.isEmpty)then
				self.selected_items = msg.output;
			end
			self.DoRefresh();
		end
	end)
end
function SueSue_equipment_cutgem_panel.DoRefresh(t)
	local self = SueSue_equipment_cutgem_panel; 
	if(self.page)then
		self.page:Refresh(t or 0.01);
	end
end
function SueSue_equipment_cutgem_panel.OnInit()
	local self = SueSue_equipment_cutgem_panel; 
	self.page = document:GetPageCtrl();
end
function SueSue_equipment_cutgem_panel.OnlyRefreshPage()
	local self = SueSue_equipment_cutgem_panel;
	self.DoClear();
	self.DoChange(1,1);
end
function SueSue_equipment_cutgem_panel.ShowPage()
	local self = SueSue_equipment_cutgem_panel;
	if(not DealDefend.CanPass())then
		return
	end
	self.DoClear();
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/NPCs/ShoppingZone/30042_SueSue_equipment_cutgem_panel.html", 
			name = "SueSue_equipment_cutgem_panel.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			allowDrag = false,
			isTopLevel = true,
			directPosition = true,
				align = "_ct",
				x = -830/2,
				y = -515/2,
				width = 830,
				height = 515,
		});
	--默认选中第一个分类
	self.DoChange(1,1);
end
function SueSue_equipment_cutgem_panel.CanPush(selected_index,types_index,gsid)
	local self = SueSue_equipment_cutgem_panel; 
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(gsItem)then
		class = tonumber(gsItem.template.class);
		subclass = tonumber(gsItem.template.subclass);
		if(selected_index == 1)then
			local bHas,guid = hasGSItem(gsid);
			if(bHas)then
				local item = ItemManager.GetItemByGUID(guid);
				if(item and item.GetSocketedGems)then
					local gems = item:GetSocketedGems() or {};
					local len = #gems;
					if(len > 0)then
			
						--这个装备是否可以镶嵌宝石
						local stat = gsItem.template.stats[36] or 0;
						if(stat > 0)then
							if( ( types_index == 1 and class == 1 and ( subclass == 2 or subclass == 5 or subclass == 6 or subclass == 7 or subclass == 8 or subclass == 10 or subclass == 11 or subclass == 15  or subclass == 16 or subclass == 17)) or
								( types_index == 2 and class == 1 and subclass == 2) or
								( types_index == 3 and class == 1 and ( subclass == 5 or subclass == 6 ) ) or
								( types_index == 4 and class == 1 and subclass == 7) or
								( types_index == 5 and class == 1 and (subclass == 15 or subclass == 16 or subclass == 17)) or
								( types_index == 6 and class == 1 and subclass == 8) or 
								( types_index == 7 and class == 1 and (subclass == 10 or subclass == 11)))then
									return true;
							end
						end
					end
				end
			end
			
			return false;
		end
	end
	return false;
end
function SueSue_equipment_cutgem_panel.GetItemsFromBags(bags,callbackFunc,cachepolicy)
	local self = SueSue_equipment_cutgem_panel; 
	if(not bags)then return end
	local output = {};
	cachepolicy = cachepolicy or "access plus 5 minutes";
	local index = 0;
	local isEmpty = true;
	function getbag(callbackFunc,cachepolicy)
		index = index + 1;
		local bag = bags[index];
		if(not bag)then
			if(callbackFunc and type(callbackFunc) == "function")then
				local count = #output;
				-- fill the 9 tiles per page
				local displaycount = math.ceil(count/9) * 9;
				if(count == 0) then
					displaycount = 9;
				end
				local i;
				for i = count + 1, displaycount do
					output[i] = {guid = 0};
				end
				callbackFunc(
					{output = output,isEmpty = isEmpty,}
				);
				return
			end
		end
		local ItemManager = System.Item.ItemManager;
		ItemManager.GetItemsInBag(bag, "ariesitems", function(msg)
			if(msg and msg.items) then
				local count = ItemManager.GetItemCountInBag(bag);
				local i;
				for i = 1, count do
					local item = ItemManager.GetItemByBagAndOrder(bag, i);
					if(item ~= nil) then
						--过滤
						local canpush = self.CanPush(self.selected_index,self.types_index,item.gsid);
						if(canpush)then
							isEmpty = false;
							table.insert(output,{guid = item.guid,gsid = item.gsid});
						end
					end
				end
				getbag(callbackFunc,cachepolicy);
			end
		end, cachepolicy);
	end
	getbag(callbackFunc,cachepolicy)
end

function SueSue_equipment_cutgem_panel.DoExchange()
	local self = SueSue_equipment_cutgem_panel;

	
end

function SueSue_equipment_cutgem_panel.OnRadioClick(value)
	local self = SueSue_equipment_cutgem_panel;
	value = tonumber(value) or 1;
	self.DoChange(self.selected_index,value)
end
function SueSue_equipment_cutgem_panel.DoShowShopPanel()
	local self = SueSue_equipment_cutgem_panel;
	NPL.load("(gl)script/apps/Aries/HaqiShop/HaqiShop.lua");
	MyCompany.Aries.HaqiShop.ShowMainWnd("tabGems")
	self.ClosePage();
end