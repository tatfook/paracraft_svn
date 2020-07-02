--[[
Title: GemTranslationPage
Author(s): Leio 
Date: 2012/06/13
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ApparelTranslation/GemTranslationPage.lua");
local GemTranslationPage = commonlib.gettable("MyCompany.Aries.ApparelTranslation.GemTranslationPage");
GemTranslationPage.ShowPage();
------------------------------------------------------------
--]]
NPL.load("(gl)script/apps/Aries/Items/item.addonlevel.lua");
local addonlevel = commonlib.gettable("MyCompany.Aries.Items.addonlevel");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/apps/Aries/ApparelTranslation/GemTranslationHelper.lua");
local GemTranslationHelper = commonlib.gettable("MyCompany.Aries.ApparelTranslation.GemTranslationHelper");
NPL.load("(gl)script/apps/Aries/UserBag/BagHelper.lua");
local BagHelper = commonlib.gettable("MyCompany.Aries.Inventory.BagHelper");
local GemTranslationPage = commonlib.gettable("MyCompany.Aries.ApparelTranslation.GemTranslationPage");
NPL.load("(gl)script/kids/3DMapSystemItem/ItemManager.lua");
local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");
GemTranslationPage.min_pagesize = 10;
GemTranslationPage.gsid = nil;
GemTranslationPage.target_gsid = nil;
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;

function GemTranslationPage.OnInit()
	local self = GemTranslationPage;
	self.page = document:GetPageCtrl();
end
--@param gsid:指定可以平移的装备
function GemTranslationPage.ShowPage(gsid)
	local self = GemTranslationPage;
	
	self.gsid= gsid;
	local find = GemTranslationPage.Reload_AllTransableList();
	if(not find)then
		_guihelper.MessageBox("暂时没有可以平移的装备！");
		return
	end
	local params = {
			url = "script/apps/Aries/ApparelTranslation/GemTranslationPage.teen.html", 
			name = "GemTranslationPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			enable_esc_key = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			zorder = zorder,
			directPosition = true,
				align = "_ct",
				x = -760/2,
				y = -470/2,
				width = 760,
				height = 470,
		}
	System.App.Commands.Call("File.MCMLWindowFrame", params);
	GemTranslationPage.Reload();
end
function GemTranslationPage.DoChangeItem(gsid)
	local self = GemTranslationPage;
	if(not gsid)then return end
	self.gsid = gsid;
	GemTranslationPage.Reload();
end
--搜索可以宝石平移的装备 只显示和本系别相关的
--@param gsid:搜索和指定gsid相关的装备
function GemTranslationPage.SearchItemListFromBag_Client(gsid)
	local self = GemTranslationPage;
	local item_list = GemTranslationHelper.SearchItemListFromBag_Client();
	local result = {};
	if(item_list)then
		local k,v;
		for k,v in ipairs(item_list) do
			local from_gsid = v.gsid;
			local from_guid = v.guid;
			local from_right_school = CommonClientService.IsRightSchool(from_gsid);
			local kk,vv;
			for kk,vv in ipairs(item_list) do
				local to_gsid = vv.gsid
				local to_guid = vv.guid;
				local to_right_school = CommonClientService.IsRightSchool(to_gsid);
				--本系
				if(from_right_school and to_right_school)then
					--是否可以宝石平移
					local gem_can = GemTranslationHelper.CanTranslation_Gem(nil,from_gsid,to_gsid);
					--是否可以属性平移
					local addon_can = GemTranslationHelper.CanTranslation_Addon(nil,from_gsid,to_gsid);
					--宝石列表
					--属性列表
					local from_gems,from_addon_level;
					local to_gems;
					local from_item = GemTranslationHelper.GetUserItem(nil,from_gsid);
					local to_item = GemTranslationHelper.GetUserItem(nil,to_gsid);
					local to_addon;
					if(from_item and to_item and from_item.GetSocketedGems and from_item.GetAddonLevel and to_item.GetSocketedGems and to_item.GetAddonLevel)then
						from_gems = from_item:GetSocketedGems();
						from_addon_level = from_item:GetAddonLevel();

						to_gems = to_item:GetSocketedGems();

						to_addon = addonlevel.tradein(from_gsid,from_addon_level,to_gsid)
					end
					local from_name = "";
					local to_name = "";
					local from_gsItem = GemTranslationHelper.GetGlobalStoreItem(from_gsid);
					if(from_gsItem)then
						from_name = from_gsItem.template.name;
					end
					local to_gsItem = GemTranslationHelper.GetGlobalStoreItem(to_gsid);
					if(to_gsItem)then
						to_name = to_gsItem.template.name;
					end
					if(gem_can or addon_can)then
						if(not gsid or gsid == from_gsid)then
							table.insert(result,{
								has_gsid = true,
								from_gsid = from_gsid,to_gsid = to_gsid,
								from_guid = from_guid,to_guid = to_guid,

								gem_can = gem_can,
								addon_can = addon_can,
								from_name = from_name,
								to_name = to_name,
								from_gems = from_gems,
								from_addon_level = from_addon_level,
								to_gems = to_gems,
								to_addon = to_addon,

								can_translation = true,
							});
						end
					end
				end
			end
		end
	end
	return result;
end
--是否有可以平移的装备
function GemTranslationPage.CanTrans(search_gsid)
	local self = GemTranslationPage;
	if(not search_gsid)then
		return
	end
	local has_item,guid = hasGSItem(search_gsid);
	if(not has_item)then
		return
	end
	local item = ItemManager.GetItemByGUID(guid);
	local has_gems = false;
	local has_addon = false;
	if(item and item.GetSocketedGems)then
		local cnt = #(item:GetSocketedGems() or {});
		if(cnt > 0)then
			has_gems = true;
		end
	end
	if(item and item.GetAddonLevel)then
		local level = item:GetAddonLevel();
		if(level and level > 0)then
			has_addon = true;
		end
	end
	--如果已经有镶嵌宝石 或者强化属性 再详细搜索
	if(has_gems or has_addon)then
		local trans_able_list,own_list,locked_list,item_list = self.SearchResult(search_gsid);
		if(trans_able_list and #trans_able_list > 0)then
			return true;
		end
	end
end
--return trans_able_list,own_list,locked_list,item_list
function GemTranslationPage.SearchResult(search_gsid)
	local self = GemTranslationPage;
	if(not search_gsid)then return end
	--可以平移的物品
	local item_list = self.SearchItemListFromBag_Client(search_gsid);
	if(item_list)then
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(search_gsid);
		local equip_level = gsItem.template.stats[138] or gsItem.template.stats[168];
		equip_level = equip_level or 0;
		--可以平移的装备
		local trans_able_list = {};
		--已经拥有的装备
		local own_list = {};
		--未来更强的装备
		local locked_list = {};
		--所有相关的物品
		local all_same_type_items = addonlevel.search_same_type_items(search_gsid);
		local k,v;
		for k,v in ipairs(all_same_type_items) do
			local gsid = v.gsid;
			if(search_gsid ~= gsid)then
				local is_locked = true;
				local kk,vv;
				for kk,vv in ipairs(item_list) do
					local to_gsid = vv.to_gsid;
					if(gsid == to_gsid)then
						is_locked = false;
						break;	
					end
				end
				if(is_locked)then
					local has_item = hasGSItem(gsid);
					if(has_item and CommonClientService.IsRightSchool(gsid))then
						table.insert(own_list,v);
					else
						if(v.equip_level >= equip_level and CommonClientService.IsRightSchool(gsid))then
							table.insert(locked_list,v);
						end	
					end
				else
					table.insert(trans_able_list,v);
				end
			end
		end
		return trans_able_list,own_list,locked_list,item_list;
	end
end
--查找所有可以平移的装备
--@param search_gsid:默认选中的物品 默认排第一位
function GemTranslationPage.SearchAllTransableList(search_gsid)
	local result = {};
	local temp = {};
	local list = GemTranslationPage.SearchItemListFromBag_Client();
	local k,v;
	local index;
	for k,v in ipairs(list) do
		if(not temp[v.from_gsid])then
			temp[v.from_gsid] = true;
			table.insert(result,v);
			if(search_gsid and search_gsid == v.from_gsid)then
				index = #result;
			end
		end
	end
	--local search_gsid_node;
	--if(search_gsid and index)then
		--search_gsid_node = result[index];
		--table.remove(result,index);
	--end
	table.sort(result,function(a,b)
		return a.from_gsid < b.from_gsid;
	end)
	--if(search_gsid_node)then
		--table.insert(result,1,search_gsid_node);
	--end
	return result;
end
--加载所有可以平移的装备
--return find
function GemTranslationPage.Reload_AllTransableList()
	local self = GemTranslationPage;
	local all_trans_able_list = GemTranslationPage.SearchAllTransableList();
	local find = false;
	if(all_trans_able_list and (#all_trans_able_list) > 0)then
		find = true;
	end
	all_trans_able_list = all_trans_able_list or {};
	CommonClientService.Fill_List(all_trans_able_list,10);
	self.all_trans_able_list = all_trans_able_list;
	return find;
end
function GemTranslationPage.Reload()
	local self = GemTranslationPage;
	self.trans_able_list = nil;
	self.own_list = nil;
	self.locked_list = nil;
	self.item_list = nil;
	self.target_gsid = nil;
    self.trans_node = nil;

	local trans_able_list,own_list,locked_list,item_list = GemTranslationPage.SearchResult(self.gsid);
	trans_able_list = trans_able_list or {};
	own_list = own_list or {};
	locked_list = locked_list or {};
	CommonClientService.Fill_List(trans_able_list,7);
	CommonClientService.Fill_List(own_list,7);
	CommonClientService.Fill_List(locked_list,7);
	self.trans_able_list = trans_able_list;
	self.own_list = own_list;
	self.locked_list = locked_list;
	self.item_list = item_list;
	if(self.page)then
		self.page:Refresh(0);
	end
end
function GemTranslationPage.GetTransAbleNode(from_gsid,to_gsid)
	local self = GemTranslationPage;
	if(self.item_list and from_gsid and to_gsid)then
		local k,v;
		for k,v in ipairs(self.item_list) do
			if(v.from_gsid == from_gsid and v.to_gsid == to_gsid)then
				return v;
			end
		end
	end
end
function GemTranslationPage.DS_Func_all_trans_able_list(index)
	local self = GemTranslationPage;
	if(not self.all_trans_able_list)then return 0 end
	if(index == nil) then
		return #(self.all_trans_able_list);
	else
		return self.all_trans_able_list[index];
	end
end
function GemTranslationPage.DS_Func_trans_able_list(index)
	local self = GemTranslationPage;
	if(not self.trans_able_list)then return 0 end
	if(index == nil) then
		return #(self.trans_able_list);
	else
		return self.trans_able_list[index];
	end
end
function GemTranslationPage.DS_Func_own_list(index)
	local self = GemTranslationPage;
	if(not self.own_list)then return 0 end
	if(index == nil) then
		return #(self.own_list);
	else
		return self.own_list[index];
	end
end
function GemTranslationPage.DS_Func_locked_list(index)
	local self = GemTranslationPage;
	if(not self.locked_list)then return 0 end
	if(index == nil) then
		return #(self.locked_list);
	else
		return self.locked_list[index];
	end
end
function GemTranslationPage.DoGemTranslation(from_gsid,to_gsid)
	local self = GemTranslationPage;
	if(from_gsid and to_gsid)then
		self.last_send_time = self.last_send_time or 0;
		local curTime = ParaGlobal.timeGetTime();
		if((curTime-self.last_send_time) < 3000) then
			return;
		end
		self.last_send_time = curTime;
		ItemManager.GetItemsInBag(1,"",function(msg)
			if(GemTranslationHelper.CanTranslation(nil,from_gsid,to_gsid))then
				System.GSL_client:SendRealtimeMessage("sPowerAPI", {name="DoGemTranslation", params={from_gsid = from_gsid,to_gsid = to_gsid,}});				
			else
				_guihelper.MessageBox("这件装备不需要再平移了！");
			end
		end)
	end
end
function GemTranslationPage.DoGemTranslation_Handle(msg)
	local self = GemTranslationPage;
	if(msg and msg.issuccess)then
			local from_gsid = msg.from_gsid;
			local to_gsid = msg.to_gsid;
			_guihelper.MessageBox("装备平移成功！");
			
			ItemManager.GetItemsInBag(0,"",function(msg)
				ItemManager.GetItemsInBag(1,"",function(msg)
				GemTranslationPage.Reload();
			end);
		end);
	end
end

