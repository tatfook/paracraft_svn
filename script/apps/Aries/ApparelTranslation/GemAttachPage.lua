--[[
Title: GemAttachPage
Author(s): Leio 
Date: 2012/06/13
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ApparelTranslation/GemAttachPage.lua");
local GemAttachPage = commonlib.gettable("MyCompany.Aries.ApparelTranslation.GemAttachPage");
GemAttachPage.ShowPage();
------------------------------------------------------------
--]]
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/apps/Aries/UserBag/BagHelper.lua");
local BagHelper = commonlib.gettable("MyCompany.Aries.Inventory.BagHelper");
local GemAttachPage = commonlib.gettable("MyCompany.Aries.ApparelTranslation.GemAttachPage");
NPL.load("(gl)script/kids/3DMapSystemItem/ItemManager.lua");
local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");
local hasGSItem = ItemManager.IfOwnGSItem;
--选中的装备
GemAttachPage.selected_guid = nil;
GemAttachPage.selected_item_info_list = nil;
GemAttachPage.apparel_list = nil;
GemAttachPage.apparel_selected_type = nil;
GemAttachPage.gems_list = nil;
GemAttachPage.gems_selected_type = nil;
GemAttachPage.selected_gem_guid = nil;
GemAttachPage.apparel_menu = {
	{label = "所有装备", selected = true, keyname = nil,},
	{label = "武器", keyname="1", zero_bag_list = {
			{ bag = 0, class = 1, subclass = {10,11}, },
		},
	},
	{label = "服装", keyname="2", zero_bag_list = {
			{ bag = 0, class = 1, subclass = {2,3,4,5,6,7,8,9,12,17,14,15,16}, },
		},
	},
}
GemAttachPage.gems_menu = {
	{label = "全部", selected = true, keyname = nil,},
	{label = "一级", keyname="1", },
	{label = "二级", keyname="2", },
	{label = "三级", keyname="3", },
	{label = "四级", keyname="4", },
	{label = "五级", keyname="5", },
	{label = "六级", keyname="6", },
}
function GemAttachPage.OnInit()
	GemAttachPage.page = document:GetPageCtrl();
end
function GemAttachPage.ShowPage(gsid)
	GemAttachPage.selected_guid = nil;
	GemAttachPage.selected_item_info_list = nil;
	GemAttachPage.apparel_list = nil;
	GemAttachPage.apparel_selected_type = nil;
	GemAttachPage.apparel_selected_type_zero_bag_list = nil;
	GemAttachPage.gems_list = nil;
	GemAttachPage.gems_selected_type = nil;
	GemAttachPage.selected_gem_guid = nil;
	if(gsid)then
		local __,guid = hasGSItem(gsid);
		GemAttachPage.selected_guid = guid;
	end
	local params = {
			url = "script/apps/Aries/ApparelTranslation/GemAttachPage.teen.html", 
			name = "GemAttachPage.ShowPage", 
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
	GemAttachPage.Reload();
end
function GemAttachPage.Reload()
	GemAttachPage.Load_item_info();
	GemAttachPage.Load_apparel_list();
	GemAttachPage.Load_gems_list();
	GemAttachPage.RefreshPage();
end
function GemAttachPage.RefreshPage()
	if(GemAttachPage.page)then
		GemAttachPage.page:Refresh(0);
	end
end
function GemAttachPage.Load_item_info()
	GemAttachPage.selected_item_info_list = nil;
	if(GemAttachPage.selected_guid)then
		local item = ItemManager.GetItemByGUID(GemAttachPage.selected_guid);
		if(item and item.GetHoleCount and item.GetSocketedGems)then
			--已经开孔的数量
			local opened_cnt = item:GetHoleCount() or 0;
			--NOTE:开孔数量为0
			opened_cnt = 0;
			local gsItem = ItemManager.GetGlobalStoreItemInMemory(item.gsid);
			-- 36 Item_Socket_Count(CS) 装备可镶嵌槽的数量 只能从0变为一个数值 不能改 
			-- 67 Item_CanCreateGemHole_Count(CS) 装备可开槽的数量 只能从0变为一个数值 不能改  
			-- 68 Cost_CraftSlotCharm_Count(CS) 装备镶嵌宝石消耗打孔石的数量 只能从0变为一个数值 不能改  
			local stat_36 = gsItem.template.stats[36] or 0;--默认孔位数量
			local stat_67 = gsItem.template.stats[67] or 0;--可开启孔位数量
			local stat_68 = gsItem.template.stats[68] or 0;--开一个孔需要打孔石数量
			--最大孔位数量
			local max_cnt = stat_36 + stat_67;
			--已经可以使用的孔位数量
			local useable_cnt = stat_36 + opened_cnt;
			if(opened_cnt > max_cnt or opened_cnt > stat_67)then
				--超过最大数量
				return
			end
			--已经镶嵌的宝石列表
			local gems = item:GetSocketedGems() or {};
			local k = 1;
			local result = {};
			local replaced = false;
			for k = 1,max_cnt do
				local gem_gsid = nil;
				local locked = true;
				local attached = false;
				if(k <= useable_cnt)then
					gem_gsid = gems[k];
					locked = false;
					if(gem_gsid)then
						attached = true;
					else
						if(GemAttachPage.selected_gem_guid and not replaced)then
							local item = ItemManager.GetItemByGUID(GemAttachPage.selected_gem_guid);
							if(item)then
								gem_gsid = item.gsid;
								replaced = true;
							end
						end
					end
				end
				table.insert(result,{
					gem_gsid = gem_gsid,
					locked = locked,
					attached = attached,
				});
			end
			GemAttachPage.selected_item_info_list = result;
		end
	end
end
function GemAttachPage.Load_apparel_list()
	local list = BagHelper.Search_Memory(nil,"Equipment",GemAttachPage.apparel_selected_type);
	if(not GemAttachPage.apparel_selected_type)then
		--全部装备
		list = CommonClientService.UnionList(list,BagHelper.SearchBagList_Memory(nil,BagHelper.GetZeroBagList()));
	else
		list = CommonClientService.UnionList(list,BagHelper.SearchBagList_Memory(nil,GemAttachPage.apparel_selected_type_zero_bag_list));
	end
	GemAttachPage.apparel_list = list;
	if(GemAttachPage.apparel_list)then
		local len = #GemAttachPage.apparel_list;
		while(len > 0)do
			local node = GemAttachPage.apparel_list[len];
			if(node and node.gsid)then
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(node.gsid);
				local stat_36 = gsItem.template.stats[36] or 0;--默认孔位数量
				local stat_67 = gsItem.template.stats[67] or 0;--可开启孔位数量
				local max_cnt = stat_36 + stat_67;
				if(max_cnt == 0)then
					table.remove(GemAttachPage.apparel_list,len);
				end
			end
			len = len - 1;
		end
	end
	CommonClientService.Fill_List(GemAttachPage.apparel_list,14);
end
function GemAttachPage.Load_gems_list()
	if(GemAttachPage.gems_selected_type)then
		GemAttachPage.gems_list = BagHelper.Search_Memory(nil,"Gem",GemAttachPage.gems_selected_type);
	else
		local list1 = BagHelper.Search_Memory(nil,"Gem","1");
		local list2 = BagHelper.Search_Memory(nil,"Gem","2");
		local list3 = BagHelper.Search_Memory(nil,"Gem","3");
		local list4 = BagHelper.Search_Memory(nil,"Gem","4");
		local list5 = BagHelper.Search_Memory(nil,"Gem","5");
		GemAttachPage.gems_list = CommonClientService.UnionList(list1,list2);
		GemAttachPage.gems_list = CommonClientService.UnionList(GemAttachPage.gems_list,list3);
		GemAttachPage.gems_list = CommonClientService.UnionList(GemAttachPage.gems_list,list4);
		GemAttachPage.gems_list = CommonClientService.UnionList(GemAttachPage.gems_list,list5);
		GemAttachPage.gems_list = CommonClientService.UnionList(GemAttachPage.gems_list,list6);
	end
	CommonClientService.Fill_List(GemAttachPage.gems_list,14);
end
--选中一件物品
function GemAttachPage.DoClick(guid)
	GemAttachPage.selected_guid = guid;
	GemAttachPage.selected_gem_guid = nil;
	GemAttachPage.Load_item_info();
	GemAttachPage.RefreshPage();
end
function GemAttachPage.DoClick_gem(guid)
	GemAttachPage.selected_gem_guid = guid;
	GemAttachPage.Load_item_info();
	GemAttachPage.RefreshPage();
end
--更换背包目录
function GemAttachPage.DoClick_Menu_Apparel(keyname,node)
	GemAttachPage.apparel_selected_type = keyname;
	GemAttachPage.apparel_selected_type_zero_bag_list = node.zero_bag_list;
	GemAttachPage.Load_apparel_list();
	GemAttachPage.RefreshPage();
end
--更换宝石目录
function GemAttachPage.DoClick_Menu_Gems(keyname)
	GemAttachPage.gems_selected_type = keyname;
	GemAttachPage.Load_gems_list();
	GemAttachPage.RefreshPage();
end
function GemAttachPage.DS_Func_item_info(index)
	if(not GemAttachPage.selected_item_info_list)then return 0 end
	if(index == nil) then
		return #(GemAttachPage.selected_item_info_list);
	else
		return GemAttachPage.selected_item_info_list[index];
	end
end
function GemAttachPage.DS_Func_apparel_list(index)
	if(not GemAttachPage.apparel_list)then 
		return if_else(not index, 0, nil);
	end
	if(index == nil) then
		return #(GemAttachPage.apparel_list);
	else
		return GemAttachPage.apparel_list[index];
	end
end
function GemAttachPage.DS_Func_gems_list(index)
	if(not GemAttachPage.gems_list)then 
		return if_else(not index, 0, nil);
	end

	if(index == nil) then
		return #(GemAttachPage.gems_list);
	else
		return GemAttachPage.gems_list[index];
	end
end
