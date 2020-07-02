--[[
Title: SueSue_equipment_extend_panel
Author(s): Leio
Date: 2010/11/30

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/30042_SueSue_equipment_extend_panel.lua");
MyCompany.Aries.Quest.NPCs.SueSue_equipment_extend_panel.ShowPage();

NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/30042_SueSue_equipment_extend_panel.lua");
local bags = {0,1};
MyCompany.Aries.Quest.NPCs.SueSue_equipment_extend_panel.GetItemsFromBags(bags,function(msg)
	commonlib.echo(msg);
end,cachepolicy)

NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/30042_SueSue_equipment_extend_panel.lua");
MyCompany.Aries.Quest.NPCs.SueSue_equipment_extend_panel.OnlyRefreshPage()
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
local SueSue_equipment_extend_panel = {
	equipment_gsid = 0,--准备镶嵌的装备
	gem_gsid = 0,--镶嵌的宝石
	rune_1_gsid = 0,--镶嵌符 
	rune_2_gsid = 0,--镶嵌符 
	rune_3_gsid = 0,--镶嵌符 
	selected_rune_index = nil,--选择第几个镶嵌符
	selected_index = nil,--选择第几步
	types_index = nil,--第一步当中，装备的分类索引 1 :all 
	all_bags = {
		{0, 1, 10010},
		{12},
		{12},
	},
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.SueSue_equipment_extend_panel", SueSue_equipment_extend_panel);

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
local LOG = LOG;

function SueSue_equipment_extend_panel.DS_Func_panel(index)
	local self = SueSue_equipment_extend_panel;
	if(not self.selected_items)then return 0 end
	if(index == nil) then
		return #(self.selected_items);
	else
		return self.selected_items[index];
	end
end
function SueSue_equipment_extend_panel.GetPageCtrl()
	local self = SueSue_equipment_extend_panel; 
	return self.page;
end
function SueSue_equipment_extend_panel.ClosePage()
	local self = SueSue_equipment_extend_panel; 
	if(self.page)then
		self.page:CloseWindow();
	end
end
function SueSue_equipment_extend_panel.DoClear()
	local self = SueSue_equipment_extend_panel; 
	self.selected_index = 1;
	self.types_index = 1;
	self.equipment_gsid = 0;
	self.gem_gsid = 0;
	self.rune_1_gsid = 0;
	self.rune_2_gsid = 0;
	self.rune_3_gsid = 0;
	self.selected_rune_index = nil;
	self.selected_items = nil;
end
function SueSue_equipment_extend_panel.GetBags()
	local self = SueSue_equipment_extend_panel; 
	if(self.selected_index)then
		local bags = self.all_bags[self.selected_index];
		return bags;
	end
end
--更改大的分类
function SueSue_equipment_extend_panel.DoChange(index,types_index)
	local self = SueSue_equipment_extend_panel; 
	index = tonumber(index);
	types_index = tonumber(types_index);
	--大的分类
	self.selected_index = index or 1;
	self.types_index = types_index or 1;
	local bags = self.GetBags();
	SueSue_equipment_extend_panel.GetItemsFromBags(bags,function(msg)
		if(msg)then
			self.selected_items = nil;
			if(not msg.isEmpty)then
				self.selected_items = msg.output;
			end
			self.DoRefresh();
		end
	end)
end
function SueSue_equipment_extend_panel.DoRefresh()
	local self = SueSue_equipment_extend_panel; 
	if(self.page)then
		self.page:Refresh(0.01);
	end
end
function SueSue_equipment_extend_panel.OnInit()
	local self = SueSue_equipment_extend_panel; 
	self.page = document:GetPageCtrl();
end
function SueSue_equipment_extend_panel.OnlyRefreshPage()
	local self = SueSue_equipment_extend_panel;
	self.DoClear();
	self.DoChange(1,1);
end
function SueSue_equipment_extend_panel.ShowPage()
	local self = SueSue_equipment_extend_panel;
	if(not DealDefend.CanPass())then
		return
	end
	self.DoClear();
	local params = {
			url = "script/apps/Aries/NPCs/ShoppingZone/30042_SueSue_equipment_extend_panel.html", 
			name = "SueSue_equipment_extend_panel.ShowPage", 
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
	};
	if(params._page) then
		params._page.OnClose = function(bDestroy)
			CommonCtrl.os.hook.UnhookWindowsHook({hookName = "Hook_MountGemPage", hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
		end
	end

	System.App.Commands.Call("File.MCMLWindowFrame", params);
	--默认选中第一个分类
	self.DoChange(1,1);
	
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = SueSue_equipment_extend_panel.HookHandler, 
		hookName = "Hook_MountGemPage", appName = "Aries", wndName = "main"});
end

-- the hook is stil needed, since we may move pe_slot between bags instead of just refreshing them
function SueSue_equipment_extend_panel.HookHandler(nCode, appName, msg, value)
	if(msg.action_type == "post_pe_slot_PageRefresh")then
		local self = SueSue_equipment_extend_panel;
		if(self.page and self.page:IsVisible()) then
			SueSue_equipment_extend_panel.DoChange(self.selected_index, self.types_index);
		end
	end
	return nCode;
end

function SueSue_equipment_extend_panel.CanPush(selected_index,types_index,gsid)
	local self = SueSue_equipment_extend_panel; 
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(gsItem)then
		class = tonumber(gsItem.template.class);
		subclass = tonumber(gsItem.template.subclass);
		if(selected_index == 1)then
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
			return false;
		elseif(selected_index == 2)then
			--宝石id 区间
			if(gsid >= 26001 and gsid <= 26699)then
				--宝石等级
				local stat = gsItem.template.stats[41] or 0;
				if(System.options.version == "kids") then
					local type = tonumber(gsItem.template.stats[42]) or 0;
					local equipGSID = tonumber(self.equipment_gsid);			
					if(equipGSID ~= 0) then				
						local equipGSItem = ItemManager.GetGlobalStoreItemInMemory(equipGSID);
						local eqclass = tonumber(equipGSItem.template.class);
						local eqsubclass = tonumber(equipGSItem.template.subclass);		
						-- 头部 披风 胸部 项链 靴子
						if(eqclass == 1 and (eqsubclass == 2 or eqsubclass == 8 or eqsubclass == 5 or eqsubclass == 17 or eqsubclass == 7)) then 
							if(type == 19 or type == 20 or (type >= 12 and type <= 15)) then
								return false;
							end
						-- 手镯 戒指
						elseif(eqclass == 1 and eqsubclass == 15 or eqsubclass == 16) then
							if(type == 19 or type == 1 or (type >= 2 and type<= 6)) then
								return false;
							end
						-- 主手武器
						elseif(eqclass == 1 and eqsubclass == 11) then
							if(type == 1 or type == 20 or (type >=7 and type <= 18)) then
								return false;
							end		
						end
					end
				end
				if(types_index == 1)then
					return true;
				else
					if((types_index -1) == stat and stat > 0)then
						return true;
					end
				end
			end
			return false;
		elseif(selected_index == 3)then
			--镶嵌符id 区间
			
			if(gsid >= 26701 and gsid <= 26703)then
				
				return true;
			end
			return false;
		end
		return true;
	end
end
function SueSue_equipment_extend_panel.GetItemsFromBags(bags,callbackFunc,cachepolicy)
	local self = SueSue_equipment_extend_panel; 
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
function SueSue_equipment_extend_panel.GetGemLevel(gsid)
	local self = SueSue_equipment_extend_panel; 
	if(not gsid or gsid == 0)then
		return;
	end
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(gsItem)then
		local level = gsItem.template.stats[41];
		return level;
	end
end
--10 is 10%
function SueSue_equipment_extend_panel.GetRuneOdds(gsid)
	local self = SueSue_equipment_extend_panel; 
	if(not gsid or gsid == 0)then
		return;
	end
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(gsItem)then
		local odds = gsItem.template.stats[35];
		return odds;
	end
end
function SueSue_equipment_extend_panel.GetMoney(gsid)
	local self = SueSue_equipment_extend_panel; 
	local level = self.GetGemLevel(gsid);
	local beans = {
		100,200,300,400,500
	};
	local bean = beans[level] or 0;
	return bean;
end
function SueSue_equipment_extend_panel.GetAllOdds()
	local self = SueSue_equipment_extend_panel; 
	local odds = 0;
	--镶嵌符概率
	odds = odds + (self.GetRuneOdds(self.rune_1_gsid) or 0);
	odds = odds + (self.GetRuneOdds(self.rune_2_gsid) or 0);
	odds = odds + (self.GetRuneOdds(self.rune_3_gsid) or 0);

	
	local gems_odd = {
		100,80,60,40,25
	};
	local gems_max_odd = {
		100,100,100,100,100
	};
	local gem_level = self.GetGemLevel(self.gem_gsid);
	--宝石概率
	if(gem_level)then
		odds = odds + gems_odd[gem_level] or 0;
		--最大总概率
		local max_odds = gems_max_odd[gem_level] or 0;

		odds = math.min(odds,max_odds);
		end
	return odds;
end
function SueSue_equipment_extend_panel.DoExchange()
	local self = SueSue_equipment_extend_panel;

	--equipment_gsid = 0,--准备镶嵌的装备
	--gem_gsid = 0,--镶嵌的宝石
	--rune_1_gsid = 0,--镶嵌符 
	--rune_2_gsid = 0,--镶嵌符 
	--rune_3_gsid = 0,--镶嵌符 
	if(not self.equipment_gsid or not self.gem_gsid)then
		return;
	end
	local __,gem_guid = hasGSItem(self.gem_gsid);
	local __,item_guid = hasGSItem(self.equipment_gsid);
	if(not gem_guid or not item_guid)then
		return
	end
	function get_rune_guids()
		local map = {};
		local k,kk;
		for k = 1,3 do
			local gsid = self["rune_"..k.."_gsid"];
			if(gsid and gsid ~= 0)then
				if(not map[gsid])then
					map[gsid] = 1;
				else
					map[gsid] = map[gsid] + 1;
				end	
			end
		end
		local map_guids = {};
		for gsid,cnt in pairs(map) do
			local __,_guid = hasGSItem(gsid);
			if(_guid)then
				map_guids[_guid] = cnt;
			end
		end
		return map_guids;
	end
	local rune_guids = get_rune_guids();
	LOG.std("", "info","before SueSue_equipment_extend_panel.DoExchange",{gem_guid = gem_guid,item_guid = item_guid,rune_guids = rune_guids });
	ItemManager.MountGemInSocket(gem_guid, item_guid, rune_guids, function(msg)
	LOG.std("", "info","after SueSue_equipment_extend_panel.DoExchange",msg);
		if(msg)then
			if(msg.issuccess and msg.errorcode == 0)then
				MyCompany.Aries.event:DispatchEvent({type = "custom_goal_client"},79017);
				--先关闭页面
				self.OnlyRefreshPage();
				local s = "真是太幸运了，你居然成功的把宝石镶嵌了上去，恭喜恭喜！ ";
				_guihelper.Custom_MessageBox(s,function(result)
					if(result == _guihelper.DialogResult.OK)then
					end
				end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
			else
				local s;
				local level = self.GetGemLevel(self.gem_gsid);
				if(level == 1)then
					s = "真遗憾，这次宝石镶嵌失败了，你的1级宝石破碎消失了，宝石镶嵌符可以提高成功率，下次要留意哦！";
				else
					if(level) then
						s = string.format("真遗憾，这次宝石镶嵌失败了，你的%d级宝石降为%d级宝石！宝石镶嵌符可以提高成功率，下次要留意哦！",level,level-1);
					else
						s = "真遗憾，这次宝石镶嵌失败了";
					end
				end
				--刷新页面
				self.OnlyRefreshPage();
				_guihelper.Custom_MessageBox(s,function(result)
					if(result == _guihelper.DialogResult.Yes)then
						
					else
						self.DoShowShopPanel();
					end
				end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/get_rune_32bits.png; 0 0 153 49"});
			end
		end
	end);
	
end

function SueSue_equipment_extend_panel.OnRadioClick(value)
	local self = SueSue_equipment_extend_panel;
	value = tonumber(value) or 1;
	self.DoChange(self.selected_index,value)
end

-- show the accesory page of the shop. 
function SueSue_equipment_extend_panel.DoShowShopPanel()
	local self = SueSue_equipment_extend_panel;
	NPL.load("(gl)script/apps/Aries/HaqiShop/HaqiShop.lua");
	MyCompany.Aries.HaqiShop.ShowMainWnd("tabGems","3001");
	self.ClosePage();
end