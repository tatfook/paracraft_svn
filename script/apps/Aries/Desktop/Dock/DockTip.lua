--[[
Title: 
Author(s): leio
Company: 
Date: 2011/11/28
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/Dock/DockTip.lua");
local DockTip = commonlib.gettable("MyCompany.Aries.Desktop.DockTip");
DockTip.GetInstance():PushGsid(23341);
DockTip.GetInstance():PushGsid(23342);
DockTip.GetInstance():PushGsid(23343);
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/apps/Aries/ApparelTranslation/GemTranslationPage.lua");
local GemTranslationPage = commonlib.gettable("MyCompany.Aries.ApparelTranslation.GemTranslationPage");
NPL.load("(gl)script/apps/Aries/Desktop/Dock/DockHelper.lua");
local DockHelper = commonlib.gettable("MyCompany.Aries.Desktop.DockHelper");
NPL.load("(gl)script/ide/Director/CardMovieHelper.lua");
local CardMovieHelper = commonlib.gettable("Director.CardMovieHelper");
NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetPane.lua");
NPL.load("(gl)script/apps/Aries/UserBag/EquipHelper.lua");
local EquipHelper = commonlib.gettable("MyCompany.Aries.Inventory.EquipHelper");
local CombatPetPane = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetPane");
local Dock = commonlib.gettable("MyCompany.Aries.Desktop.Dock");
NPL.load("(gl)script/apps/Aries/ServerObjects/Gatherer/GathererBarPage.lua");
local GathererBarPage = commonlib.gettable("MyCompany.Aries.ServerObjects.GathererBarPage");

NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetHelper.lua");
local CombatPetHelper = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetHelper");
local Player = commonlib.gettable("MyCompany.Aries.Player");
local Pet = commonlib.gettable("MyCompany.Aries.Pet");

NPL.load("(gl)script/apps/Aries/CombatPet/CombatFollowPetPane.lua");
local CombatFollowPetPane = commonlib.gettable("MyCompany.Aries.CombatPet.CombatFollowPetPane");
NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetConfig.lua");
local CombatPetConfig = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetConfig");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
local DockTip = commonlib.gettable("MyCompany.Aries.Desktop.DockTip");
DockTip.timer = nil;
DockTip.node_list = {};
DockTip.page_name = "DockTip.ShowPage";
DockTip.page_ctrl = nil;
DockTip.page_file = "script/apps/Aries/Desktop/Dock/DockTip.teen.html";
DockTip.cur_interval = 0;
DockTip.interval = 100;
DockTip.duration = 5000;
DockTip.timer_enabled = false;
DockTip.instance_map = {};
function DockTip.GetInstance(name)
	name = name or "docktip_instance";
	if(not DockTip.instance_map[name])then
		DockTip.instance_map[name] = DockTip:new()
	end
	return DockTip.instance_map[name];
end
function DockTip:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	o:OnInit();
	return o
end

function DockTip:GetParams(name)
	if(not name)then return end
	local k,v;
	for k,v in ipairs(self.pos_list) do	
		if(v.name == name)then
			return v;
		end
	end
end
function DockTip:OnInit_GetPageCtrl()
	self.page = document:GetPageCtrl();
end
function DockTip:ChangeWorld()
	if(self.timer)then
		self.timer:Change(0, self.interval);
	end
	self.is_showing_node = false;
end
function DockTip:GetNodeList()
	return self.node_list,self.node_map;
end
function DockTip:OnInit()
	self:ChangeWorld();
	if(self.is_init)then
		return
	end
	self.motion_queue = {};
	self.is_init = true;
	self.timer = commonlib.Timer:new();
	self.timer.callbackFunc = DockTip.TimerCallBack;
	self.node_list = {};
	self.node_map = {};
	self.pending_gsid_list = {};
	if(System.options.version == "kids") then
		self.page_file = "script/apps/Aries/Desktop/Dock/DockTip.kids.html"
		local y = -82;
		self.pos_list = {
			{name = "DockTip.ProfilePane.ShowPage", label = "人物", x = -350, y = y},
			{name = "DockTip.CombatCardTeen", label = "技能", x = -350+47, y = y, title="你获得了新卡片！" },
			{name = "DockTip.CharacterBagPage.ShowPage", label = "背包", x = -350+47*2, y = y, title="你获得了新装备！", btn="立即穿上" },
			{name = "DockTip.collectable", label = "收集品", x = -350+47*3, y = y, title="你获得了新物品！", btn="立即使用" },
			{name = "DockTip.CombatPetPane.ShowPage", label = "宠物", x = -350+47*4, y = y, title="你获得了新宠物！", btn="立即出战" },
			{name = "DockTip.MountPet.ShowMenu", label = "坐骑", x = -350+47*5, y = y, title="你获得了新坐骑！", btn="立即驾驭" },
			
			{name = "DockTip.FriendsPage.ShowPage", label = "好友", x = 35, y = y, title="你可以在这里添加好友！" },
			{name = "DockTip.FamilyMembersPage.ShowPage", label = "家族", x = 82, y = y},
			{name = "DockTip.Aries.LocalMapMCML", label = "地图", x = -42, y = y-8,},
		}
	else
		local y = -85;
		local x = -375+52;
		self.pos_list = {
			{name = "DockTip.ProfilePane.ShowPage", label = "人物", x = x, y = y},
			{name = "DockTip.MountPet.ShowMenu", label = "坐骑", x = x+52, y = y, title="你获得了新坐骑！", btn="立即驾驭" },
			{name = "DockTip.CharacterBagPage.ShowPage", label = "背包", x = x+52, y = y, title="你获得了新装备！", btn="立即穿上" },
			{name = "DockTip.CombatPetPane.ShowPage", label = "宠物", x = x+52*2, y = y, title="你获得了新宠物！", btn="立即出战" },
			{name = "DockTip.CombatCardTeen", label = "技能", x = x+52*3, y = y, title="你获得了新卡片！" },
			--{name = "DockTip.QuestPane.ShowPage", label = "任务", x = x, y = y},
			{name = "DockTip.LobbyClientServicePage.ShowPage", label = "组队", x = x+52*4, y = y},
			{name = "DockTip.FriendsPage.ShowPage", label = "好友", x = x+52*6, y = y, title="你可以在这里添加好友！" },
			{name = "DockTip.FamilyMembersPage.ShowPage", label = "家族", x = x+52*7, y = y},
			--{name = "DockTip.Aries.LocalMapMCML", label = "地图", x = x, y = y,},
		}	
	end
	

	local nid = Map3DSystem.User.nid or 0;
	local key = string.format("DockTip:SetActiveTimer_%d",nid);
	self.timer_enabled = MyCompany.Aries.Player.LoadLocalData(key, false);
	self.timer:Change(0, self.interval);
end
function DockTip:IsVisible()
	if(self.page)then
		return self.page:IsVisible();
	end
end
function DockTip:RemoveTopNode()
	local len = #self.node_list;
	local node = self.node_list[1];
	if(node)then
		table.remove(self.node_list,1);
		if(node.gsid)then
			self.node_map[node.gsid] = nil;
		end
	end
	self:HideTip();
	return node;
end
function DockTip:ShowTopNode()
	self:HideTip();
	self:BubbleTip();
end
function DockTip:HideTip()
	if(self.page)then
		self.page:CloseWindow();
		self.page = nil;
	end
end
function DockTip:BubbleTip()
	local node = self:GetFirstNode();
	if(not node or not node.name)then return end
	local name = node.name;
	local params = self:GetParams(name);
	if(params)then
		self:CreatePage(params.x,params.y,name);
	end
end

function DockTip:DoAction(node)
	if(node) then
		local onclick_func = node.onclick;
		local gsid = node.gsid;
		if(onclick_func and DockTip[onclick_func])then
			DockTip[onclick_func](gsid, node);
		end
	end
end

-- called periodically
function DockTip.TimerCallBack(timer)
	if(DockTip.instance_map)then
		local k,dock_tip;
		for k,dock_tip in pairs(DockTip.instance_map) do
			local max_duration = 3000;
			local pending_time = dock_tip.pending_time or 0
			pending_time = pending_time + dock_tip.interval;
			if(pending_time >= max_duration)then
				dock_tip:CheckAllPendingGsids();				
				dock_tip.pending_time = 0
			else
				dock_tip.pending_time = pending_time;
			end

			if(not dock_tip:HasChildren())then
				return
			end
			local can_show = dock_tip:CheckCanShow();
			if(can_show)then
				if(not dock_tip.is_showing_node)then
					dock_tip.cur_interval = 0;
					dock_tip:ShowTopNode();
					dock_tip.is_showing_node = true;
				else
					dock_tip.cur_interval = dock_tip.cur_interval + dock_tip.interval;
					if(dock_tip.cur_interval >= dock_tip.duration)then
						local force_remove;
						if(System.options.version == "kids" and MyCompany.Aries.Player.GetLevel() <= 12) then
							force_remove = true;
							local node = dock_tip:GetFirstNode();
							dock_tip:DoAction(node);
						end

						if(force_remove or dock_tip.timer_enabled)then
							dock_tip.is_showing_node = false;
							local node = dock_tip:RemoveTopNode();
						end
					end
				end
				--逻辑显示 但是窗口没有显示
				if(dock_tip.is_showing_node and not dock_tip:IsVisible())then
					dock_tip:ShowTopNode();
				end
			else
				dock_tip:HideTip();
			end
					
			
		end
	end
	
end

function DockTip:SetActiveTimer()
	if(self.timer_enabled)then
		self.timer_enabled = false;
	else
		self.timer_enabled = true
		if(self.is_showing_node)then
			self.cur_interval = 0;
		end
	end
	local nid = Map3DSystem.User.nid;
	local key = string.format("DockTip:SetActiveTimer_%d",nid);
	MyCompany.Aries.Player.SaveLocalData(key, self.timer_enabled);
end
function DockTip:TimerIsEnabled()
	return self.timer_enabled;
end
--检查窗口是否在显示，如果显示，隐藏DockTip
function DockTip:CheckCanShow()
	local Dock = commonlib.gettable("MyCompany.Aries.Desktop.Dock");
	if(Dock.cmds)then
		local k,v;
		for k,v in pairs(Dock.cmds) do
			local _wnd = Dock.FindWindow(v.wndName);
			if(_wnd)then
				if(_wnd:IsVisible())then
					return false;
				end
			end
		end
	end
	local Desktop = commonlib.gettable("MyCompany.Aries.Desktop");
	local can_show = Desktop.IsVisible;
	return can_show;
end
--是否已经包含
function DockTip:HasNodeByGsid(gsid)
	if(not gsid)then return end
	if(self.node_map[gsid])then
		return true;
	end
end

function DockTip:GetTipCount()
	return #self.node_list;
end
function DockTip:__PushNode(node)
	if(not node or node.animation_only)then return end
	local gsid = node.gsid;
	if(self:HasNodeByGsid(gsid))then
		return;
	end
	table.insert(self.node_list,node);
	if(gsid)then
		self.node_map[gsid] = gsid;
	end
end
function DockTip:PushAnimation(node)
	if(not node)then return end
	if(node.name and node.gsid)then
		table.insert(self.motion_queue, node);
	else
		self:__PushNode(node);
	end
	self:CheckAnimation();
end
function DockTip:CheckAnimation()
	local len = #self.motion_queue;
	if(len > 0)then
		local node = self.motion_queue[1];
		local gsid = node.gsid;
		local name = node.name;
		name = string.match(name,"DockTip.(.+)");
		local uiname = "instancebtn_"..name;
		local obj = ParaUI.GetUIObject(uiname);
		if(obj and obj:IsValid())then
			local end_x, end_y, screen_width, screen_height = obj:GetAbsPosition();
			local params = self:GetParams(name);
			local runtime_datasource = {
				gsid= gsid,
				start_x = 150,
				start_y = -48,
				start_align = "_ct";
				end_x = end_x,
				end_y = end_y,
				end_align = "_lt";
				version = "item",
			}
			CardMovieHelper.GotItem(runtime_datasource,function()
				table.remove(self.motion_queue,1);
				self:__PushNode(node);
				self:CheckAnimation();

			end)
		else
			table.remove(self.motion_queue,1);
			self:__PushNode(node);
			self:CheckAnimation();
		end
	end
end
function DockTip:PushNode(node)
	if(not node)then return end
	if(not self.is_init)then
		return
	end
	self:PushAnimation(node);
	--self:__PushNode(node);
end
function DockTip:Manual_RemoveFirstNode()
	self.is_showing_node = false;
	self:RemoveTopNode();
end
function DockTip:GetFirstNode()
	return self.node_list[1];
end
function DockTip:HasChildren()
	local len = #self.node_list;
	if(len > 0)then
		return true;
	end
end
function DockTip:DeleteNodeByName(name)
	if(not name)then return end
	local node = self:GetFirstNode();
	if(node and node.name and node.name == name)then
		table.remove(self.node_list,1);

		if(node.gsid)then
			self.node_map[node.gsid] = nil;
		end
	end
end
function DockTip:ShowPage()
end
function DockTip:CreatePage(x,y,name)
	local url = string.format("%s?name=%s",self.page_file,name or "");
	local params = {
			url = url, 
			name = self.page_name, 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			enable_esc_key = false,
			isTopLevel = false,
			allowDrag = false,
			click_through = true, -- allow clicking through
			directPosition = true,
				align = "_ctb",
				x = x,
				y = y,
				width = 200,
				height = 100,
		};
	System.App.Commands.Call("File.MCMLWindowFrame", params);
end
function DockTip:BuildTag(gsid,tag)
	if(not gsid)then
		return
	end
	if(tag)then
		return tag;
	end
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(gsItem)then
		local bean = MyCompany.Aries.Pet.GetBean() or {};
		local combatlel = bean.combatlel or 0;

		local class = gsItem.template.class;
		local subclass = gsItem.template.subclass;
		local bagfamily = gsItem.template.bagfamily;
		local inventorytype = gsItem.template.inventorytype;
		local auto_use_type = gsItem.template.stats[66];
		if(bagfamily ==  1 and class == 1)then
			local combatlevel_requirement = gsItem.template.stats[138] or 0;  -- 掉落装备级别
			local apparel_quality=gsItem.template.stats[221] or -1;  -- 品质	
			local position = gsItem.template.inventorytype; -- 装备位
			--只显示自己的系别 并且满足级别要求
			if (CommonClientService.IsRightSchool(gsid)) then
				if(CommonClientService.IsTeenVersion())then
					--绿装以上 提示装备平移
					if(apparel_quality > 0)then
						local item_list = GemTranslationPage.SearchItemListFromBag_Client();
						if(item_list)then
							local k,v;
							for k,v in ipairs(item_list) do
								if(v.to_gsid == gsid or v.from_gsid == gsid)then
									return "GemCanTranslation";
								end
							end
						end
					end
				end
				local curItem = ItemManager.GetItemByBagAndPosition(0, position); -- 身上同位置装备
				if(not curItem or not curItem.gsid)then
					--新装备
					return "IsApparel";
				end
				curItem = ItemManager.GetGlobalStoreItemInMemory(curItem.gsid)
				if(curItem)then
					local cur_combatlevel_requirement = curItem.template.stats[138] or 0;
					local cur_apparel_quality = curItem.template.stats[221] or -1;
					if(combatlevel_requirement == cur_combatlevel_requirement)then
						--同级别的比较品质
						if(apparel_quality > cur_apparel_quality)then
							return "IsApparel";
						end
					elseif(combatlevel_requirement > cur_combatlevel_requirement)then
						return "IsApparel";
					end
				end
				--装备是否可升级
				if(CommonClientService.IsTeenVersion())then
					if(DockHelper.CanUpgrade(gsid))then
						return "CanUpgrade";
					end
				end
			end
		end
		--如果是宝石 并且有可以镶嵌宝石的装备
		if(DockHelper.IsGem(gsid) and EquipHelper.GetBestFreeSlotItem())then
			return "IsGem";
		end
		--如果是卡包
		if(DockHelper.IsCombatDeck(gsid))then
			return "IsCombatDeck";
		end
		if(bagfamily == 23)then
			return "IsPet";
		elseif(bagfamily == 24 or bagfamily == 25)then
			return "IsCard";
		elseif(bagfamily == 10010)then
			return "IsCombatPet";
		end
		if(auto_use_type)then
			if(auto_use_type == 1)then
				return "auto_use_type_1";
			elseif(auto_use_type == 2)then
				return "auto_use_type_2";
			end
		end
		if(bagfamily == 12 or bagfamily == 14)then
			return "Collectable";
		end
	end
end
function DockTip:RemovePendingGsid(gsid)
	if(not gsid)then
		return
	end
	local k,v;
	for k,v in ipairs(self.pending_gsid_list) do
		if(v.gsid == gsid)then
			table.remove(self.pending_gsid_list,k);
		end
	end
end
function DockTip:CheckAllPendingGsids()
	local len = #self.pending_gsid_list;
	if(len > 0)then
		LOG.std("", "info","before DockTip:CheckAllPendingGsids one time");
	end
	while(len > 0)do
		local node = self.pending_gsid_list[len];
		if(node)then
			local check_times = node.check_times or 0;
			local gsid = node.gsid;
			local tag = node.tag;
			--尝试3次
			if(check_times < 3)then
				LOG.std("", "info","DockTip:CheckAllPendingGsids",node);
				local bHas = hasGSItem(gsid);
				LOG.std("", "info","bHas",bHas);

				self:PushGsid(gsid,tag,true);
				check_times = check_times + 1;
				node.check_times = check_times;
			else
				LOG.std("", "info","DockTip:CheckAllPendingGsids delete node",node);
				table.remove(self.pending_gsid_list,len);
			end	
		end
		len = len - 1;
	end
	if(len > 0)then
		LOG.std("", "info","after DockTip:CheckAllPendingGsids one time");
	end
end
function DockTip:GetPendingNode(gsid)
	if(not gsid)then
		return
	end
	local k,v;
	for k,v in ipairs(self.pending_gsid_list) do
		if(v.gsid == gsid)then
			return v;
		end
	end
end
function DockTip:PushToPendingList(gsid,tag)
	if(not gsid)then
		return
	end
	local node = self:GetPendingNode(gsid);
	if(node)then
		return
	else
		table.insert(self.pending_gsid_list,{
			gsid = gsid,
			tag = tag,
			check_times = 0,
		});
	end
end
function DockTip:PushGsid(gsid,tag,is_pending_state)
	if(not self.is_init)then
		return
	end
	if(not gsid)then return end
	LOG.std("", "info","DockTip:PushGsid",{gsid = gsid, is_pending_state = is_pending_state,});
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(gsid == 0)then
		local node = { name = "DockTip.CharacterBagPage.ShowPage", gsid = 0, title="你获得了一个新物品！", animation_only=true};
		self:PushNode(node);
		return
	end
	if(gsItem)then
		
		if(gsid > 0)then
			local bHas = hasGSItem(gsid);
			if(not bHas)then
				LOG.std("", "info","DockTip:PushToPendingList",{gsid = gsid, tag = tag, is_pending_state = is_pending_state,});
				self:PushToPendingList(gsid,tag);
				return
			else
				LOG.std("", "info","DockTip:RemovePendingGsid",{gsid = gsid});
				self:RemovePendingGsid(gsid);
			end
		end
		local name;
		local node;
		local class = gsItem.template.class;
		local subclass = gsItem.template.subclass;
		local bagfamily = gsItem.template.bagfamily;
		--[[if(gsid == 17172)then
			-- do not prompt if level is small
			if(System.options.version == "kids" and Player.GetLevel() <10) then
				return;
			end
			CombatPetPane.SetAnchorTip(true);
			name = "DockTip.CombatPetPane.ShowPage";
			node = { name = name, gsid = gsid, title="你获得了战宠口粮！", btn="none", };
			self:PushNode(node);
			return;
		end]]
		if(gsid == 17268)then
			if(CommonClientService.IsKidsVersion())then
				name = "DockTip.collectable";
				node = { name = name, gsid = gsid, title="神奇的月饼可以做什么呢？", btn="马上看看", onclick="OnClick_Shop",  };
				self:PushNode(node);
			end
			return;
		elseif(gsid == 966)then
			if(System.options.version == "teen")then
				-- pet training points. 
				NPL.load("(gl)script/apps/Aries/CombatPet/CombatFollowPetPane.lua");
				local CombatFollowPetPane = commonlib.gettable("MyCompany.Aries.CombatPet.CombatFollowPetPane");
				if(CombatFollowPetPane.CanLevelUp_FollowingPet()) then
					--name = "DockTip.CombatPetPane.ShowPage";
					--node = { name = name, gsid = gsid, title="你的宠物可以升级了", btn="马上看看", onclick="OnClick_PetManager", force_action_level=20 };
					--self:PushNode(node);
					NPL.load("(gl)script/apps/Aries/Desktop/HPMyPlayerArea.lua");
					local HPMyPlayerArea = commonlib.gettable("MyCompany.Aries.Desktop.HPMyPlayerArea");
					HPMyPlayerArea.UpdateUI(true);
				end
				return;
			end
		end
		local tag = self:BuildTag(gsid,tag);
		if(not tag)then
			return
		end
		if(tag == "IsApparel")then
			NPL.load("(gl)script/kids/3DMapSystemItem/Item_CombatApparel.lua");
			local Item_CombatApparel = commonlib.gettable("Map3DSystem.Item.Item_CombatApparel");
			local bCanEquip = Item_CombatApparel.CheckCanEquip(gsid)
			if(bCanEquip) then
				name = "DockTip.CharacterBagPage.ShowPage";
				node = { name = name, gsid = gsid, title="你获得了更好的新装备！", btn="立即穿上", onclick="OnClick_Item",  force_action_level=15};
				self:PushNode(node);
			end
		elseif(tag == "CanUpgrade")then
			-- teen only
			name = "DockTip.CharacterBagPage.ShowPage";
			node = { name = name, gsid = gsid, title="你的装备可以进行强化了！", btn="立即强化", onclick="OnClick_Upgrade",  };
			self:PushNode(node);
		elseif(tag == "IsGem")then
			name = "DockTip.CharacterBagPage.ShowPage";
			node = { name = name, gsid = gsid, title="你的装备可以进行镶嵌宝石了！", btn="立即镶嵌", onclick="OnClick_IsGem",  };
			self:PushNode(node);
		elseif(tag == "IsCombatDeck")then
			-- do not prompt if level is small, since we will use task pe:goalpointer
			if(Player.GetLevel() <20) then
				return;
			end
			-- teen only
			name = "DockTip.CombatCardTeen";
			node = { name = name, gsid = gsid, title="你获得了新的卡包！",btn="立即查看", onclick="OnClick_Cards",};
			self:PushNode(node);
		elseif(tag == "IsPet")then
			name = "DockTip.MountPet.ShowMenu";
			if(System.options.version == "kids") then
				node = { name = name, gsid = gsid, title="你获得了抱抱龙变身药丸！", btn="立即使用", onclick="OnClick_Pet", };
			else
				node = { name = name, gsid = gsid, title="你获得了新坐骑！", btn="立即驾驭", onclick="OnClick_Pet", };
			end
			self:PushNode(node);
		elseif(tag == "IsCard")then
			name = "DockTip.CombatCardTeen";

			if(class == 18 and subclass == 2)then
				node = { name = name, gsid = gsid, title="你获得了符文卡牌！",btn="查看符文卡牌", onclick="OnClick_Spell",};
			else
				local title = "你获得了技能卡牌！";
				node = { name = name, gsid = gsid, title=title,btn="查看技能卡牌", onclick="OnClick_Spell", };
			end
			if(gsid ~= 22000)then
				if(System.options.version=="kids") then
					-- only inform user if level is above 10. 
					if(Player.GetLevel() >=10) then
						-- cards needs to be viewed
						self:PushNode(node);
					end
				else
					--DockTip.OnClick_Spell(gsid)
					self:PushNode(node);
				end
			end
		elseif(tag == "IsCombatPet")then
			name = "DockTip.CombatPetPane.ShowPage";
			--只提示和自己系别相同的宠物
			local cnt = ItemManager.GetFollowPetCount();
			cnt = cnt or 0;
			--可能延迟
			if(cnt == 0)then
				node = { name = name, gsid = gsid, title="你获得了新宠物！", btn="立即出战", onclick="OnClick_Combatpet", force_action_level=10 };
			--第一个宠物自动跟随
			elseif(cnt == 1)then
				node = { name = name, gsid = gsid, title="你获得了新宠物！", btn="立即查看", onclick = "OnClick_PetManager", force_action_level=10};
				DockTip.OnClick_Combatpet(gsid);
			else
				local pet_config = CombatPetConfig.GetInstance_Client();
				local row = pet_config:GetRow(gsid);
				if(row)then
					local school = row.school;
					--本系宠物
					if(CommonClientService.IsRightSchool(gsid,nil,nil,school))then
						node = { name = name, gsid = gsid, title="你获得了新宠物！", btn="立即出战", onclick="OnClick_Combatpet",  };
					else
						node = { name = name, gsid = gsid, title="你获得了新宠物！", btn="立即查看", onclick = nil, };
					end
				end
			end
			if(node)then
				self:PushNode(node);
			end
		elseif(tag == "auto_use_type_1")then
			-- use it now
			if(System.options.version == "kids") then
				name = "DockTip.collectable";
			else
				name = "DockTip.CharacterBagPage.ShowPage";
			end
			node = { name = name, gsid = gsid, title=format("你获得了【%s】？", gsItem.template.name or ""), btn="马上打开", onclick="OnClick_Item_NeedShowBar",  force_action_level=10};
			self:PushNode(node);
		elseif(tag == "auto_use_type_2")then
			-- use it immediately
			DockTip.OnClick_Item(gsid);
		elseif(tag == "Collectable")then
			name = "DockTip.CharacterBagPage.ShowPage";
			node = { name = name, gsid = gsid, title="你获得了一个新物品！", animation_only=true, btn="马上看看", onclick="OnClick_GatherBag",  };
			self:PushNode(node);
		elseif(tag == "AutoLearnSpell")then
			name = "DockTip.CombatCardTeen";
			node = { name = name, gsid = gsid, title="你获得了技能卡牌！",btn="查看技能卡牌", onclick="OnClick_Spell", };
			--if(System.options.version=="kids") then
				---- only inform user if level is above 10. 
				--if(Player.GetLevel() >=10) then
					--self:PushNode(node);
				--end
			--else
				--self:PushNode(node);
			--end
			self:PushNode(node);

		elseif(tag == "GemCanTranslation")then
			-- obsoleted
			name = "DockTip.CharacterBagPage.ShowPage";
			node = { name = name, gsid = gsid, title="你的装备可以进行平移了！", btn="立即平移", onclick="OnClick_GemTranslation",  };
			self:PushNode(node);
		end
	end
end
function DockTip.OnClick_Pet(gsid)
	if(System.options.version=="kids") then
		NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatCardDeckSubPage.lua");
		local MyCardsManager = commonlib.gettable("MyCompany.Aries.Inventory.Cards.MyCardsManager");
		MyCardsManager.ShowCardTip(gsid,1,"mount")
	else
		if(not gsid)then return end
		local bHas, guid = hasGSItem(gsid);
		if(bHas) then
			local item = ItemManager.GetItemByGUID(guid);
			if(item and item.guid > 0) then
				item:OnClick("left", nil, true);
			end
		end
		local item = ItemManager.GetMyMountPetItem();
		if(not item)then return end
		item:MountMe();
	end
end

function DockTip.OnClick_PetManager(gsid)
	local Dock = commonlib.gettable("MyCompany.Aries.Desktop.Dock");
	Dock.FireCmd("CombatFollowPetPane.ShowPage");
	if(System.options.version == "teen") then
		-- show the pet food tips if there is pet food. 
		local gsid = 17172; -- pet food
		local bHas, guid, _, copies = hasGSItem(gsid);
		if(bHas) then
			NPL.load("(gl)script/apps/Aries/mcml/pe_goal_pointer.lua");
			local goal_manager = commonlib.gettable("MyCompany.Aries.mcml_controls.goal_manager");
			goal_manager.SetCurrentGoal("feedpet");
		end
	end
end

-- force mount the pet 
function DockTip.OnClick_Combatpet(gsid)
	if(not CombatFollowPetPane.IsFollowing(gsid))then
		CombatFollowPetPane.DoToggleHome(gsid, function()
			local word = CombatPetHelper.GetPetTalk(gsid, "entercombat");
			if(type(word) == "string") then
				local followpet = Pet.GetUserFollowObj();
				if(followpet and followpet:IsValid()) then
					local speak_word = "<span style='color:#093f4f'>"..word.."</span>";
					headon_speech.Speek(followpet.name, speak_word, 6, true, nil, true, nil, "#ffffffc0");
				end
			end
		end);
	end
end

function DockTip.OnClick_Item(gsid)
	if(not gsid)then return end
	local hasGSItem = ItemManager.IfOwnGSItem;
	local bHas, guid = hasGSItem(gsid);
	if(bHas) then
		local item = ItemManager.GetItemByGUID(guid);
		if(item and item.guid > 0) then
			item:OnClick("left", nil, true);
		end
	end
end
function DockTip.OnClick_Cards(gsid)
	if(System.options.version=="kids") then
		NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatCardDeckSubPage.lua");
	else
		NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatCardManager.teen.lua");
	end
	local MyCardsManager = commonlib.gettable("MyCompany.Aries.Inventory.Cards.MyCardsManager");
	MyCardsManager.ShowPage();
end
function DockTip.OnClick_Spell(gsid)
	--NPL.load("(gl)script/apps/Aries/NPCs/MagicSchool/CombatSkillLearn.lua");
	--local CombatSkillLearn = commonlib.gettable("MyCompany.Aries.Quest.NPCs.CombatSkillLearn");
	--CombatSkillLearn.ShowPageWithTip(true)
	if(not gsid)then return end
	local bHas, guid = hasGSItem(gsid);
	if(bHas) then
		if(System.options.version=="kids") then
			NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatCardDeckSubPage.lua");
			local MyCardsManager = commonlib.gettable("MyCompany.Aries.Inventory.Cards.MyCardsManager");	
			local state = MyCardsManager.GetPropByTemplateGsid(gsid);
			local cardtip="card"
			if (gsid>23000) then
				cardtip = "rune"			
			end
			MyCardsManager.ShowCardTip(gsid,1,cardtip);
			--local state = MyCardsManager.GetPropByTemplateGsid(gsid);
			--if (gsid>23000) then
				--MyCardsManager.SetRunePage();	
				--MyCardsManager.SetPageState(state);	
			--else
				--MyCardsManager.SetCombatCardPage()
				--MyCardsManager.SetPageState(state);	
			--end
			--MyCardsManager.ShowPage()
		else
			NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatCardManager.teen.lua");
			local MyCardsManager = commonlib.gettable("MyCompany.Aries.Inventory.Cards.MyCardsManager");
			MyCardsManager.ShowCardTip(gsid)
		end
	end
end
function DockTip.OnClick_GemTranslation(gsid)
	NPL.load("(gl)script/apps/Aries/ApparelTranslation/GemTranslationPage.lua");
	local GemTranslationPage = commonlib.gettable("MyCompany.Aries.ApparelTranslation.GemTranslationPage");
	GemTranslationPage.ShowPage();
end
function DockTip.OnClick_Upgrade(gsid)
	NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/Avatar_equip_upgrade.lua");
	local Avatar_equip_upgrade = commonlib.gettable("MyCompany.Aries.NPCs.ShoppingZone.Avatar_equip_upgrade");
	Avatar_equip_upgrade.ShowPage(gsid);
end
function DockTip.OnClick_IsGem(gsid)
	NPL.load("(gl)script/apps/Aries/ApparelTranslation/GemAttachPage.lua");
	local GemAttachPage = commonlib.gettable("MyCompany.Aries.ApparelTranslation.GemAttachPage");
	GemAttachPage.ShowPage();
end
function DockTip.OnClick_Shop(gsid,node)
	if(gsid == 17268)then
		NPL.load("(gl)script/apps/Aries/HaqiShop/NPCShopPage.lua");
		local NPCShopPage = commonlib.gettable("MyCompany.Aries.NPCShopPage");
		NPCShopPage.ShowPage(30431,"menu1","superpat");
	end
end
function DockTip.OnClick_GatherBag(gsid,node)
	if(CommonClientService.IsTeenVersion())then
		NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CharacterBagPage.lua");
		local CharacterBagPage = commonlib.gettable("MyCompany.Aries.Inventory.CharacterBagPage");
		CharacterBagPage.ShowPage(nil,"Material")
	end
end
function DockTip.NeedShowBar(gsid)
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(gsItem)then
		local auto_use_type = gsItem.template.stats[66];
		if(auto_use_type and auto_use_type == 1)then
			return true;
		end
	end
end
function DockTip.OnClick_Item_NeedShowBar(gsid)
	if(not gsid)then return end
	local hasGSItem = ItemManager.IfOwnGSItem;
	local bHas, guid = hasGSItem(gsid);
	if(bHas) then
		local item = ItemManager.GetItemByGUID(guid);
		if(item and item.guid > 0) then
			local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
			local title = string.format("正在打开【%s】",gsItem.template.name or "");
			GathererBarPage.Start({ duration = 2000, title = title, disable_shortkey = true,},nil,function()
				item:OnClick("left", nil, true);
			end);
		end
	end
end