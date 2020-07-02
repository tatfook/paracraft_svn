--[[
Title: 
Author(s): leio
Date: 2011/07/27
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/DefaultTheme.teen.lua");
MyCompany.Aries.Theme.Default:Load();
NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CharacterBagPage.lua");
local CharacterBagPage = commonlib.gettable("MyCompany.Aries.Inventory.CharacterBagPage");
CharacterBagPage.ShowPage()

NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CharacterBagPage.lua");
local CharacterBagPage = commonlib.gettable("MyCompany.Aries.Inventory.CharacterBagPage");
CharacterBagPage.RefreshPage();

NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CharacterBagPage.lua");
local CharacterBagPage = commonlib.gettable("MyCompany.Aries.Inventory.CharacterBagPage");
CharacterBagPage.Call_Server()
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/apps/Aries/ApparelTranslation/GemTranslationPage.lua");
local GemTranslationPage = commonlib.gettable("MyCompany.Aries.ApparelTranslation.GemTranslationPage");
NPL.load("(gl)script/apps/Aries/UserBag/EquipHelper.lua");
local EquipHelper = commonlib.gettable("MyCompany.Aries.Inventory.EquipHelper");
NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
NPL.load("(gl)script/apps/Aries/UserBag/BagHelper.lua");
local BagHelper = commonlib.gettable("MyCompany.Aries.Inventory.BagHelper");
NPL.load("(gl)script/apps/Aries/Combat/main.lua");
NPL.load("(gl)script/apps/Aries/HaqiShop/NPCShopProvider.lua");
local NPCShopProvider = commonlib.gettable("MyCompany.Aries.NPCShopProvider");
local Combat = commonlib.gettable("MyCompany.Aries.Combat");
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
local Dock = commonlib.gettable("MyCompany.Aries.Desktop.Dock");
local CharacterBagPage = commonlib.gettable("MyCompany.Aries.Inventory.CharacterBagPage");
CharacterBagPage.folder_menu = nil;--分类
CharacterBagPage.grid_view_item_list = nil;
CharacterBagPage.selected_folder = nil;
CharacterBagPage.selected_subfolder = nil;

CharacterBagPage.pagesize = 54;--每页显示数据
CharacterBagPage.gems_list = nil;--背包中的宝石列表
CharacterBagPage.translation_list = nil;--可以平移的装备列表
CharacterBagPage.card_filter_list = {
	{ quality = 0, selected = true, label="<div style='color:#ffffff;'>普通</div>", tooltip = "白色品质的卡牌", bg_1 = "Texture/Aries/Common/Teen/control/white_selected_btn_32bits.png", bg_2 = "Texture/Aries/Common/Teen/control/white_btn_32bits.png" },
	{ quality = 1, selected = true, label="<div style='color:#77d305;'>精良</div>", tooltip = "绿色品质的卡牌", bg_1 = "Texture/Aries/Common/Teen/control/green_selected_btn_32bits.png", bg_2 = "Texture/Aries/Common/Teen/control/green_btn_32bits.png"  },
	{ quality = 2, selected = true, label="<div style='color:#0d99fc;'>稀有</div>", tooltip = "蓝色品质的卡牌", bg_1 = "Texture/Aries/Common/Teen/control/blue_selected_btn_32bits.png", bg_2 = "Texture/Aries/Common/Teen/control/blue_btn_32bits.png"  },
	{ quality = 3, selected = true, label="<div style='color:#985ef7;'>传奇</div>", tooltip = "紫色品质的卡牌", bg_1 = "Texture/Aries/Common/Teen/control/purple_selected_btn_32bits.png", bg_2 = "Texture/Aries/Common/Teen/control/purple_btn_32bits.png"  },
}
function CharacterBagPage.DS_Func_Card_Filter(index)
	if(not CharacterBagPage.card_filter_list)then return 0 end
	if(index == nil) then
		return #(CharacterBagPage.card_filter_list);
	else
		return CharacterBagPage.card_filter_list[index];
	end
end
function CharacterBagPage.CardFilter_Quality_IsSelected(quality)
	if(not quality or quality < 0)then
		return true;
	end
	if(CharacterBagPage.card_filter_list)then
		local k,v;
		for k,v in ipairs(CharacterBagPage.card_filter_list) do
			if(v.selected and v.quality == quality)then
				return true;
			end
		end
	end
	return false;
end
function CharacterBagPage.CardFilter_IsSelectedAll()
	if(CharacterBagPage.card_filter_list)then
		local k,v;
		for k,v in ipairs(CharacterBagPage.card_filter_list) do
			if(not v.selected)then
				return false;
			end
		end
	end
	return true;
end
function CharacterBagPage.CardFilter_SelectedAll(b)
	if(CharacterBagPage.card_filter_list)then
		local k,v;
		for k,v in ipairs(CharacterBagPage.card_filter_list) do
			v.selected = b;
		end
	end
end
function CharacterBagPage.CardFilter_Toggle(index)
	if(index and CharacterBagPage.card_filter_list and CharacterBagPage.card_filter_list[index])then
		local node = CharacterBagPage.card_filter_list[index];
		node.selected = not node.selected;
	end
end
function CharacterBagPage.CreateMenu()
	local self = CharacterBagPage;
	local bags_menu = BagHelper.GetBagsMenu();
	local folder_menu = {};
	local subfolder_map = {};
	table.insert(folder_menu,{label = "全部", selected = true, keyname = nil,});
	local k,v;
	for k,v in ipairs(bags_menu) do
		table.insert(folder_menu,{label = v.label , keyname = v.keyname,});

		local kk,vv;
		local subfolder_menu = {};
		for kk,vv in ipairs(v) do
			local selected;
			if(kk == 1)then
				selected = true;
			end
			table.insert(subfolder_menu,{label = vv.label , selected = selected, keyname = vv.keyname,});
		end
		subfolder_map[v.keyname] = subfolder_menu;
	end
	return folder_menu,subfolder_map;
end

function CharacterBagPage.DoChangeFolder(folder)
	local self = CharacterBagPage;
	self.DoChange(folder,subfolder,true);
end
--同步用户背包里面的数据config/Aries/BagDefine_Teen/bag.xml
function CharacterBagPage.SynchUserBag(callbackFunc)
	local self = CharacterBagPage;
	BagHelper.Search(nil,nil,nil,function(msg)
		if(callbackFunc)then
			callbackFunc();
		end
	end,"access plus 0 minutes")
end
function CharacterBagPage.IsSortedBag()
	return CharacterBagPage.is_sorted_bag;
end
function CharacterBagPage.DoSortBag()
	CharacterBagPage.is_sorted_bag = true;
	CharacterBagPage.RefreshPage();
end
function CharacterBagPage.DoChange(folder,subfolder,bResetSubMenu, bMaintainPage)
	local self = CharacterBagPage;
	self.selected_folder = folder;
	self.selected_subfolder = subfolder;

	self.subfolder_menu = nil;
	local item_list = BagHelper.Search_Memory(self.nid,self.selected_folder,self.selected_subfolder);
	if(item_list)then
		if(folder and folder == "CombatCard")then
			local result = {};
			local k,v;
			for k,v in ipairs(item_list) do
				local gsid = v.gsid;
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
				if(gsItem)then
					local apparel_quality = gsItem.template.stats[221] or -1;
					if(CharacterBagPage.CardFilter_Quality_IsSelected(apparel_quality))then
						table.insert(result,v);
					end
				end
			end
			item_list = result;
			BagHelper.SortCard(item_list);
		end
		if(not CharacterBagPage.IsSortedBag())then
			if(folder == nil)then
				table.sort(item_list,function(a,b)
					if(a.obtaintime and b.obtaintime)then
						return a.obtaintime > b.obtaintime;
					end
				end);
			end
		end
		
		self.grid_view_item_list = item_list;

		local pagesize = pagesize or self.pagesize;
		local count = #self.grid_view_item_list;
		local displaycount = math.ceil(count / pagesize) * pagesize;

		if(count == 0 )then
			displaycount = pagesize;
		end
		local max_bag_size = CharacterBagPage.GetBagSize();
		displaycount = math.max(displaycount,max_bag_size);
		local i;
		for i = count + 1, displaycount do
			self.grid_view_item_list[i] = { guid = 0,obtaintime = "" };
		end
		if(self.subfolder_map and folder)then
			self.subfolder_menu = self.subfolder_map[folder];
			if(self.subfolder_menu and bResetSubMenu)then
				local k,v;
				for k,v in ipairs(self.subfolder_menu) do
					if(k == 1)then
						v.selected = true;
					else
						v.selected = false;
					end
				end
			end
		end
		if(self.page)then
			if(not bMaintainPage) then
				self.page:CallMethod("bags_view", "GotoPage", 1);
			end
			self.page:Refresh(0);
		end
	end
end
function CharacterBagPage.DS_Func_Items(index)
	local self = CharacterBagPage;
	if(not self.grid_view_item_list)then return 0 end
	if(index == nil) then
		return #(self.grid_view_item_list);
	else
		return self.grid_view_item_list[index];
	end
end
function CharacterBagPage.OnInit()
	local self = CharacterBagPage;
	self.page = document:GetPageCtrl();
end
function CharacterBagPage.ClosePage()
	local self = CharacterBagPage;
	if(self.page)then
		self.page:CloseWindow();
		self.page = nil;
	end
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "Hook_CharacterBagPage", 
		hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end

function CharacterBagPage.RefreshPage(bMaintainPage)
	local self = CharacterBagPage;
	self.DoChange(self.selected_folder,self.selected_subfolder, nil, bMaintainPage);
end

function CharacterBagPage.ShowPage_click_from_dock(nid, selected_folder, zorder)
	ParaAudio.PlayUISound("Bag_teen");
	CharacterBagPage.ShowPage(nid, selected_folder, zorder);
end

function CharacterBagPage.GetRepairMoney()
    local nid = System.App.profiles.ProfileManager.GetNID();
	local userinfo = System.App.profiles.ProfileManager.GetUserInfoInMemory(nid) or {};
	local emoney = userinfo.emoney or 0;--银币
    local need_money = NPCShopProvider.GetRepairMoney();
    if(need_money and need_money > 0)then
        local s;
        if(emoney < need_money)then
            s = string.format([[<div style="color:#f61909">%d银币</div>]],need_money);
        else
            s = string.format([[%d银币]],need_money);
        end
        return s;
    end
end
function CharacterBagPage.DoRepairAllItems()
    NPCShopProvider.DoResetDurability(function()
        pageCtrl:Refresh(0);
    end)
end

function CharacterBagPage.ShowPage(nid,selected_folder,zorder)
	local self = CharacterBagPage;
	self.LoadTemplate();
	self.nid= nid;
	self.folder_menu,self.subfolder_map = CharacterBagPage.CreateMenu();
	zorder = zorder or 0;
	CharacterBagPage.is_sorted_bag = false;
	CharacterBagPage.CardFilter_SelectedAll(true);
	if(self.folder_menu and selected_folder)then
		local k,v;
		for k,v in ipairs(self.folder_menu) do
			if(v.keyname == selected_folder)then
				v.selected = true;
			else
				v.selected = false;
			end
		end
	end
	local params = {
				url = "script/apps/Aries/Desktop/CombatCharacterFrame/CharacterBagPage.teen.html", 
				name = "CharacterBagPage.ShowPage", 
				app_key=MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				enable_esc_key = true,
				style = CommonCtrl.WindowFrame.ContainerStyle,
				allowDrag = true,
				zorder = zorder,
				directPosition = true,
					align = "_ct",
					x = -800/2,
					y = -470/2,
					width = 800,
					height = 470,
		}
	System.App.Commands.Call("File.MCMLWindowFrame", params);	
	if(params._page) then
		params._page.OnClose = function(bDestroy)
			CommonCtrl.os.hook.UnhookWindowsHook({hookName = "Hook_CharacterBagPage", hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
			Dock.OnClose("CharacterBagPage.ShowPage")
		end
	end
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = CharacterBagPage.HookHandler, 
		hookName = "Hook_CharacterBagPage", appName = "Aries", wndName = "main"});
	self.gems_list = EquipHelper.GetGems();
	self.translation_list = GemTranslationPage.SearchItemListFromBag_Client();
	self.DoChange(selected_folder,nil);
end
-- the hook is stil needed, since we may move pe_slot between bags instead of just refreshing them
function CharacterBagPage.HookHandler(nCode, appName, msg, value)
	if(msg.action_type == "post_pe_slot_PageRefresh")then
		local self = CharacterBagPage;
		if(self.page and self.page:IsVisible()) then
			self.RefreshPage(true);
		end
	end
	return nCode;
end

--获取拥有物品的总数量
function CharacterBagPage.GetItemCnt()
	local self = CharacterBagPage;
	local item_list = BagHelper.Search_Memory(self.nid,nil,nil);
	if(item_list)then
		return #item_list;
	end
	return 0;
end

-- whether it is too heavy. 
function CharacterBagPage.IsBagTooHeavy()
	return (CharacterBagPage.GetItemCnt()>CharacterBagPage.GetBagSize())
end
--当前背包格子数量
function CharacterBagPage.GetBagSize()
	local self = CharacterBagPage;
	local cur_node,next_node,is_full = self.GetCurBagLevelNode();
	if(cur_node)then
		return cur_node.bag_size;
	end
	return self.pagesize;
end
--return cur_node,next_node,is_full
function CharacterBagPage.GetBagLevelNode(level)
	local self = CharacterBagPage;
	level = level or 0;	
	local bag_template_list = self.bag_template_list;
	if(bag_template_list)then
		local len = #bag_template_list;
		local max_node = bag_template_list[len];
		local max_level = max_node.level;

		local next_level = level + 1;
		if(next_level > max_level)then
			return max_node,max_node,true;
		end

		local cur_node = bag_template_list[level + 1];
		local next_node = bag_template_list[next_level + 1];
		return cur_node,next_node;
	end
end
--return cur_node,next_node,is_full
function CharacterBagPage.GetCurBagLevelNode()
	local self = CharacterBagPage;
	self.LoadTemplate();
	local hasItem,guid,bag,level = ItemManager.IfOwnGSItem(976);
	return self.GetBagLevelNode(level);
end
function CharacterBagPage.LoadTemplate()
	local self = CharacterBagPage;
	if(self.is_load)then
		return
	end
	self.is_load = true;
	local xmlRoot = ParaXML.LuaXML_ParseFile("config/Aries/BagDefine_Teen/bag_extend.xml");
	local node;
	local bag_template_list = {};
	for node in commonlib.XPath.eachNode(xmlRoot, "//items/item") do
		local level = tonumber(node.attr.level);
		local bag_size = tonumber(node.attr.bag_size);
		local price = tonumber(node.attr.price);
		if(level and bag_size and price)then
			table.insert(bag_template_list,{
				level = level, bag_size = bag_size, price = price,
			});
		end
	end
	table.sort(bag_template_list,function(a,b)
		if(a.level and b.level)then
			return a.level < b.level;
		end
	end);
	self.bag_template_list = bag_template_list;
end
function CharacterBagPage.BagExtend_Handle(msg)
	local self = CharacterBagPage;
	if(msg and msg.level and msg.level > 0)then

		local pre_node = CharacterBagPage.GetBagLevelNode(msg.level - 1);
		local cur_node,next_node,is_full = CharacterBagPage.GetBagLevelNode(msg.level);
		if(pre_node and cur_node)then
			_guihelper.MessageBox(string.format([[<div>你已经扩展<span style="color:#ff0000">%d</span>格成功！</div>]],cur_node.bag_size - pre_node.bag_size));
		end
	end
end
function CharacterBagPage.DoBagExtend()
	local self = CharacterBagPage;
	QuestClientLogics.CallServer("MyCompany.Aries.Inventory.BagExtendServerHelper.DoBagExtend",{})
end