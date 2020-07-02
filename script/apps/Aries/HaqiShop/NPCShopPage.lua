--[[
Title: 
Author(s): leio
Date: 2011/09/26
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/HaqiShop/NPCShopPage.lua");
local NPCShopPage = commonlib.gettable("MyCompany.Aries.NPCShopPage");
NPCShopPage.ShowPage(31003);

NPL.load("(gl)script/apps/Aries/HaqiShop/NPCShopPage.lua");
local NPCShopPage = commonlib.gettable("MyCompany.Aries.NPCShopPage");
NPCShopPage.is_debug = true;
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/MinorSkillPage.lua");
local MinorSkillPage = commonlib.gettable("MyCompany.Aries.Desktop.MinorSkillPage");
NPL.load("(gl)script/apps/Aries/UserBag/BagHelper.lua");
local BagHelper = commonlib.gettable("MyCompany.Aries.Inventory.BagHelper");
NPL.load("(gl)script/apps/Aries/HaqiShop/HaqiShop.lua");
local HaqiShop = commonlib.gettable("MyCompany.Aries.HaqiShop");
local Dock = commonlib.gettable("MyCompany.Aries.Desktop.Dock");
NPL.load("(gl)script/apps/Aries/Desktop/Dock/DockTip.lua");
local DockTip = commonlib.gettable("MyCompany.Aries.Desktop.DockTip");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CharacterBagPage.lua");
local CharacterBagPage = commonlib.gettable("MyCompany.Aries.Inventory.CharacterBagPage");
NPL.load("(gl)script/apps/Aries/HaqiShop/NPCShopProvider.lua");
local NPCShopProvider = commonlib.gettable("MyCompany.Aries.NPCShopProvider");
local NPCShopPage = commonlib.gettable("MyCompany.Aries.NPCShopPage");
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

NPCShopPage.folder_menu = nil;--分类
NPCShopPage.grid_view_item_list = nil;
NPCShopPage.selected_folder = nil;
NPCShopPage.selected_subfolder = nil;

--item list which can be buy by user
NPCShopPage.show_list = nil;
--item list which can be recovered by user
NPCShopPage.recover_list = nil;
--通过激活码进行的兑换
function NPCShopPage.GetExchangeCodeIDs()
	if(NPCShopPage.exchange_code_ids)then
		return NPCShopPage.exchange_code_ids;
	end
	if(CommonClientService.IsKidsVersion())then
		NPCShopPage.exchange_code_ids = {
			[1816] = { label = "", check_gsid = 50349, },
		}
	else
	end
	return NPCShopPage.exchange_code_ids;
end
--user bag-----------------------------------------------------
function NPCShopPage.CreateMenu()
	local self = NPCShopPage;
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
function NPCShopPage.DoChangeFolder(folder)
	local self = NPCShopPage;
	self.LoadData_Bag(folder,subfolder,true);
end
function NPCShopPage.LoadData_Bag(folder,subfolder,bResetSubMenu)
	local self = NPCShopPage;
	self.selected_folder = folder;
	self.selected_subfolder = subfolder;

	self.subfolder_menu = nil;
	BagHelper.Search(self.nid,self.selected_folder,self.selected_subfolder,function(msg)
		if(msg and msg.item_list)then
			self.grid_view_item_list = msg.item_list;

				local pagesize = 56;
				local count = #self.grid_view_item_list;
				local displaycount = math.ceil(count / pagesize) * pagesize;

				if(count == 0 )then
					displaycount = pagesize;
				end
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
				self.page:Refresh(0);
			end
		end
	end)
end
function NPCShopPage.DS_Func_Items_Bag(index)
	local self = NPCShopPage;
	if(not self.grid_view_item_list)then return 0 end
	if(index == nil) then
		return #(self.grid_view_item_list);
	else
		return self.grid_view_item_list[index];
	end
end
-------------------------------------------------------------------------
function NPCShopPage.OnInit()
	local self = NPCShopPage;
	self.page = document:GetPageCtrl();
end

local NoAllTabNPC = {
	[30430] = true,
	[30429] = true,
	[30550] = true,
	[30551] = true,
	[30552] = true,
	[30553] = true,
	[30554] = true,
}
-- whether the all items tab should be shown for the given NPC. 
function NPCShopPage.CanShowAllItemsTab()
	local nTabsCount = 1;
	if(NPCShopPage.class_name_list)then
        nTabsCount = #NPCShopPage.class_name_list;

		if(nTabsCount > 1) then
			if(System.options.version == "kids") then
				-- disable all tabs for given NPC id. Currently this is hard coded in source file. 
				if(NoAllTabNPC[NPCShopPage.npcid or ""] ) then
					return;
				end
			else
				
			end
		end
    end
	return nTabsCount>1;
end

function NPCShopPage.ShowPage(npcid,superclass,class,zorder)
	local self = NPCShopPage;
	zorder = zorder or 1;
	npcid = tonumber(npcid);
	superclass = superclass or "menu1"
	self.npcid = npcid;
	self.superclass = superclass;	
	self.class_name_list = NPCShopProvider.FindClassNameList(self.npcid,self.superclass);
	self.money_list = NPCShopProvider.FindMoneyList(self.npcid,self.superclass);
	self.recover_list = NPCShopProvider.GetRecoverList();

	local first_type = class or "all_types";
	
	if(not NPCShopPage.CanShowAllItemsTab()) then
		if(self.class_name_list[1])then
			first_type = self.class_name_list[1].class
		end
	end
	
	NPL.load("(gl)script/apps/Aries/mcml/pe_goal_pointer.lua");
    local goal_manager = commonlib.gettable("MyCompany.Aries.mcml_controls.goal_manager");
	if(goal_manager.match_param("npc_shop_id", npcid)) then
        goal_manager.finish("open_npc_shop");
    end

	if(System.options.version == "kids")then
		if(npcid == 30533 and not MinorSkillPage.IsHunter())then
			_guihelper.MessageBox("你的职业不是灵兽猎人, 不需要这些卡片！");
			return;
		end
		if(npcid == 30534 and not MinorSkillPage.IsIdentifier())then
			_guihelper.MessageBox("你的职业不是魔法鉴定师, 不需要这些魔法晶体！");
			return;
		end
		if(npcid == 30535 and not MinorSkillPage.IsBuilder())then
			_guihelper.MessageBox("你的职业不是魔法工匠, 不需要这些融合剂！");
			return;
		end
		local params = {
			url = "script/apps/Aries/HaqiShop/NPCShopPage.html", 
			name = "NPCShopPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			enable_esc_key = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			zorder = zorder,
			directPosition = true,
				align = "_ct",
				x = -700/2,
				y = -500/2,
				width = 700,
				height = 500,
			cancelShowAnimation = true,
		};
		System.App.Commands.Call("File.MCMLWindowFrame", params);
		
		HaqiShop.LoadCurAvatar();
		HaqiShop.ShowAvatar(HaqiShop.head_gsid_cur,HaqiShop.body_gsid_cur,HaqiShop.pants_gsid_cur,HaqiShop.shoe_gsid_cur,HaqiShop.backside_gsid_cur,HaqiShop.leftweapon_gsid_cur,HaqiShop.rightweapon_gsid_cur, params._page);
		self.DoChangeType(first_type,true);
	else
		self.folder_menu,self.subfolder_map = CharacterBagPage.CreateMenu();
		self.shoptip = NPCShopProvider.FindNPCshopTip(npcid,superclass);
		local params = {
			url = "script/apps/Aries/HaqiShop/NPCShopPage.teen.html", 
			name = "NPCShopPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			enable_esc_key = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = zorder,
			allowDrag = true,
			directPosition = true,
				align = "_ct",
				x = -900/2,
				y = -520/2,
				width = 900,
				height = 520,
			cancelShowAnimation = true,
		}
		System.App.Commands.Call("File.MCMLWindowFrame", params);		
		if(params._page) then
			params._page.OnClose = function(bDestroy)
				Dock.OnClose("NPCShopPage.ShowPage")
			end
		end
		self.DoChangeType(first_type);
		self.DoChangeFolder(nil);
	end
end
-- change shop items type
function NPCShopPage.DoChangeType(type,bRefresh)
	local self = NPCShopPage;
	self.type = type;
	local p;
	if(self.type == "all_types")then
		p = nil;
	else
		p = self.type;
	end
	self.show_list = NPCShopProvider.FindDataSource(self.npcid,self.superclass,p);
	if(bRefresh)then
		self.RefreshPage();
	end
end
function NPCShopPage.RefreshPage()
	local self = NPCShopPage;
	if(self.page)then
		self.page:Refresh(0.1);
	end
end
function NPCShopPage.ClosePage()
	local self = NPCShopPage;
	if(self.page)then
		self.page:CloseWindow();
		self.page = nil;
	end
	self.show_list = nil;
	self.npcid = nil;
	--CommonCtrl.os.hook.UnhookWindowsHook({hookName = "Hook_NPCShopPage", 
		--hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end
function NPCShopPage.DS_Func_Items(index)
	local self = NPCShopPage;
	if(not self.show_list)then return 0 end
	if(index == nil) then
		return #(self.show_list);
	else
		return self.show_list[index];
	end
end
--货币列表
function NPCShopPage.DS_Func_Money(index)
	local self = NPCShopPage;
	if(not self.money_list)then return 0 end
	if(index == nil) then
		return #(self.money_list);
	else
		return self.money_list[index];
	end
end
function NPCShopPage.PushSellHistory(gsid)
	local self = NPCShopPage;
	if(not gsid)then return end
	NPCShopProvider.PushSellHistory(gsid);
	self.recover_list = NPCShopProvider.GetRecoverList();
	if(self.page)then
		self.page:CallMethod("history_view", "SetDataSource", self.recover_list);
        self.page:CallMethod("history_view", "DataBind"); 
	end
end

-- this function is no longer used
function NPCShopPage.HookHandler(nCode, appName, msg, value)
	local self = NPCShopPage;
	if(msg.action_type == "post_pe_slot_PageRefresh")then
		self.LoadData_Bag(self.selected_folder);
	end
	return nCode;
end

function NPCShopPage.OnClickItem(gsid,inst,index)
	if(System.options.version == "kids") then
		return HaqiShop.OnClickItem(gsid,inst,index, NPCShopPage.page);
	else
		return HaqiShop.OnClickItem(gsid,inst,index, NPCShopPage.page);
	end
end

function NPCShopPage.ResetPreviewModel(name)
	HaqiShop.ResetPreviewModel(NPCShopPage.page);
end

function NPCShopPage.OnProcessPurchaseErrorMsg(msg)
	if(msg and msg.errorcode) then
		local errorcode = msg.errorcode;
		if(errorcode == 429) then
			_guihelper.MessageBox("购买失败了! 超过每周购买的最大限制");
		elseif(errorcode == 428) then
			_guihelper.MessageBox("购买失败了! 超过每日购买的最大限制");
		elseif(errorcode == 443) then
			_guihelper.MessageBox("购买失败了! 超过每小时总购买数");
		elseif(errorcode == 437) then
			_guihelper.MessageBox("购买失败了! 超过当天总购买数");
		elseif(errorcode == 427) then
			_guihelper.MessageBox("购买失败了! 条件不符");
		elseif(errorcode == 424) then
			_guihelper.MessageBox("购买失败了! 购买数量超过限制");
		elseif(errorcode == 438) then
			_guihelper.MessageBox("购买失败了! 不可进行此操作");
		elseif(errorcode == 441) then
			_guihelper.MessageBox("购买失败了! 超过当月消费限制");
		elseif(errorcode == 442) then
			_guihelper.MessageBox("购买失败了! 超过单笔消费限制");
		elseif(errorcode == 433) then
			_guihelper.MessageBox("购买失败了! 已达最大购买值");
		elseif(errorcode == 421) then
			_guihelper.MessageBox("此兑换码已全部发完，暂无库存! 请改天再来吧");
		elseif(errorcode == 493) then
			_guihelper.MessageBox("购买失败了! 你不能拥有过多这个物品");
		else
			_guihelper.MessageBox(format("购买失败了: code %d", errorcode));
		end
	else
		_guihelper.MessageBox("购买失败了");
	end
end

local kids_special_ids = {
	exid = {
		[1709] = true,
		},
	gsid = {
		-- [17439] = true,
		}
}
--兑换前置条件是否包含特殊id
function NPCShopPage.IncludeSpecialID(exid,id, gsid)
	if(((not exid) and (not gsid)) or (not id))then return end
	if(exid and exid > 0) then
		local exTemplate = ItemManager.GetExtendedCostTemplateInMemory(exid);
		if(exTemplate and exTemplate.pres)then
			local k,v;
			for k,v in pairs(exTemplate.pres) do
				if (tonumber(v.key)== id) then
					return true;
				end
			end
		end
	end
    if(System.options.version == "kids" and ((exid and kids_special_ids.exid[exid]) or (gsid and kids_special_ids.gsid[gsid]))) then
		return true;
	end
end

-- @param mcmlCode: mcmlCode is displayed at the bottom of the page
function NPCShopPage.ShowExchangeCodePage(exid,gsid_mcmlCode)
	if(not exid)then return end
	if(type(gsid_mcmlCode) == "string") then
		NPCShopPage.exchange_code_mcmlCode = mcmlCode;
	elseif(type(gsid_mcmlCode) == "number") then
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid_mcmlCode);
		if(gsItem)then
			if(System.options.version == "kids") then
				if(gsid_mcmlCode == 17299) then
					gsid_mcmlCode = [[<div style="text-weight:bold;font-size:14px;">欢迎加入新人成长计划! <br/>
登录<a href='http://haqi.61.com/webplayer/kidslauncher/haqi_activity20121204.html'>哈奇活动页(点击进入)</a>, 领取激活码</div>]];
				end
			end
		end
	else
		NPCShopPage.exchange_code_mcmlCode = nil;
	end
	local url = string.format("script/apps/Aries/HaqiShop/ExchangeCodePage.html?exid=%d",exid);
	local params = {
		url = url, 
		name = "NPCShopPage.ShowExchangeCodePage", 
		app_key=MyCompany.Aries.app.app_key, 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		enable_esc_key = true,
		style = CommonCtrl.WindowFrame.ContainerStyle,
		allowDrag = true,
		isTopLevel = true,
		zorder = 1000,
		directPosition = true,
			align = "_ct",
			x = -300/2,
			y = -400/2,
			width = 300,
			height = 400,
	}
	System.App.Commands.Call("File.MCMLWindowFrame", params);	
end
