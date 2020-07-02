--[[
Title: code behind for Avatar_equip_upgrade.lua
Author(s): WD
Date: 2011/09/24
use the lib:
------------------------------------------------------------
purpose:equipment exchange for teen version

NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/Avatar_equip_upgrade.lua");
local Avatar_equip_upgrade = commonlib.gettable("MyCompany.Aries.NPCs.ShoppingZone.Avatar_equip_upgrade");
Avatar_equip_upgrade.ShowPage();
------------------------------------------------------------
--]]

local ItemManager = Map3DSystem.Item.ItemManager;
local GetItemByID = ItemManager.GetGlobalStoreItemInMemory;
local GetItemsCount = ItemManager.GetItemCountInBag;
local GetItemsInBag = ItemManager.GetItemsInBag;
local hasGSItem = ItemManager.IfOwnGSItem;
local ExtendedCost = ItemManager.ExtendedCost;
local GetExtTemp = ItemManager.GetExtendedCostTemplateInMemory;
local GetExtendedCostTemplateFromItemCount = ItemManager.GetExtendedCostTemplateFromItemCount;
local getEquippedItem = ItemManager.GetEquippedItem;

local getItemByGuid = ItemManager.GetItemByGUID;
local MSG = _guihelper.MessageBox;
local echo = commonlib.echo;
local Player = commonlib.gettable("MyCompany.Aries.Player");

NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/Avatar_equipment_subpage.lua");
NPL.load("(gl)script/apps/Aries/Items/item.addonlevel.lua");
local addonlevel = commonlib.gettable("MyCompany.Aries.Items.addonlevel");

local Avatar_equip_upgrade = commonlib.gettable("MyCompany.Aries.NPCs.ShoppingZone.Avatar_equip_upgrade");
local Avatar_equipment_subpage = commonlib.gettable("MyCompany.Aries.NPCs.ShoppingZone.Avatar_equipment_subpage")


Avatar_equip_upgrade.material = {guid = 0,number = 0,};
Avatar_equip_upgrade.hold_number = 0;
Avatar_equip_upgrade.from_level = nil;
Avatar_equip_upgrade.properties = { attack_percentage = 0,attack_absolute = 0,}
Avatar_equip_upgrade.upvalue = 1;
Avatar_equip_upgrade.prev_guid = nil;

function Avatar_equip_upgrade:Init()
	self.page = document:GetPageCtrl();
	
	if(addonlevel and addonlevel.get_levelup_req)then
		 local goods = getItemByGuid(Avatar_equipment_subpage.IncomingEquip.guid);
		 
		 if(goods and goods.GetAddonLevel)then
			--if(self.prev_guid ~= Avatar_equipment_subpage.IncomingEquip.guid)then
				self.from_level = goods:GetAddonLevel() or 0
			--end
			
			local gsid = Avatar_equipment_subpage.IncomingEquip.gsid
			local required_gsid,required_number = addonlevel.get_levelup_req(gsid, self.from_level )
			local has, guid, _, copies = hasGSItem(required_gsid);

			self.material.gsid = required_gsid;
			self.material.guid = guid or 0;
			self.material.number = required_number or 0;
			self.hold_number = copies or 0
			
			self.properties.attack_percentage = addonlevel.get_attack_percentage(gsid,self.from_level + self.upvalue);
			self.properties.attack_absolute = addonlevel.get_attack_absolute(gsid,self.from_level + self.upvalue);
			self.properties.hp_absolute = addonlevel.get_hp_absolute(gsid,self.from_level + self.upvalue);
			self.properties.resist_absolute = addonlevel.get_resist_absolute(gsid,self.from_level + self.upvalue);

			self.properties.resilience_percentage = addonlevel.get_resilience_percentage(gsid,self.from_level + self.upvalue);
			self.properties.critical_strike_percent = addonlevel.get_critical_strike_percent(gsid,self.from_level + self.upvalue);
		 end
		if(self.page)then
			self.page:SetValue("IncomingEquipGuid",Avatar_equipment_subpage.IncomingEquip.guid or 0);
			-- self.page:SetValue("material_item",self.material.gsid);
		end

		self.prev_guid = Avatar_equipment_subpage.IncomingEquip.guid;
	end
end
function Avatar_equip_upgrade.GetProps()
	local self = Avatar_equip_upgrade;
	if(Avatar_equipment_subpage.IncomingEquip.gsid and Avatar_equipment_subpage.IncomingEquip.gsid == -999)then return "" end
	local lvl = (self.from_level or 0) + 1;
	local is_full_level;
	if(lvl  > addonlevel.get_max_addon_level(Avatar_equipment_subpage.IncomingEquip.gsid))then
		lvl = (self.from_level or 0)
		is_full_level = true;
	end
	local text = format([[<div style="font-weight:bold;">%s:+%s</div>]], Avatar_equipment_subpage.IncomingEquip.name, lvl);
	if(not is_full_level)then
		local attack_value = self.properties.attack_percentage or self.properties.attack_absolute;
		if(attack_value) then
			text = format("%s<div>强化攻击:+%s%%</div>", text, tostring(attack_value))
		end
		local hp_absolute = self.properties.hp_absolute;
		if(hp_absolute) then
			text = format("%s<div>强化HP:+%s</div>", text, tostring(hp_absolute))
		end
		local resist_absolute = self.properties.resist_absolute;
		if(resist_absolute) then
			text = format("%s<div>强化防御:+%s%%</div>", text, tostring(resist_absolute))
		end

		local resilience_percentage = self.properties.resilience_percentage;
		if(resilience_percentage) then
			text = format("%s<div>韧性:+%s%%</div>", text, tostring(resilience_percentage))
		end

		local critical_strike_percent = self.properties.critical_strike_percent;
		if(critical_strike_percent) then
			text = format("%s<div>暴击:+%s%%</div>", text, tostring(critical_strike_percent))
		end

	else
		text = format("%s<div>已经强化到满级了</div>", text);
	end
	
	return text;
end

function Avatar_equip_upgrade.GetItemUnits(gsid)
	local has, _, _, copies = hasGSItem(gsid);
	return copies or 0;
end

function Avatar_equip_upgrade.ShowPageWithGsid(gsid)
	Avatar_equip_upgrade.ShowPage(gsid);
end

function Avatar_equip_upgrade.ShowPageWithGuid(guid)
	Avatar_equip_upgrade.ShowPage(nil, guid);
end

function Avatar_equip_upgrade.ShowPage(gsid, guid)
	
	local self = Avatar_equip_upgrade;
	addonlevel.init();

	local page_addr = "script/apps/Aries/NPCs/ShoppingZone/Avatar_equip_upgrade.teen.html"
	if(System.options.version == "teen")then
		Avatar_equipment_subpage.FURNISHINGS_FILTER =  
		{
		BAG_FURNISHINGS_ID = {0,1},
		SUB_TYPE = {{2,5,6,7,8,9,10,11,12,14,15,16,17,18,19,70,71},
					{2,5,6,7,8,9,12,18,19,70,71},
					{14,15,16,17},
					{10,11}}};
	elseif(System.options.version =="kids" or not System.options.version or System.options.version == "")then
		page_addr = "script/apps/Aries/NPCs/ShoppingZone/Avatar_equip_upgrade.kids.html"
		Avatar_equipment_subpage.FURNISHINGS_FILTER = 
		{
		BAG_FURNISHINGS_ID = {0,1},
		SUB_TYPE = {{2,5,6,7,8,9,10,11,12,14,15,16,17,18,19,70,71},
		{10,11},{2,18},{8,70},{5,6,19},{7,71},
					{12,14,15,16,17},
					}};
	end

	local has_item;
	if(not gsid and not guid) then
		if(System.options.version == "kids") then
			if(Player.GetLevel() <= 10) then
				-- tricky: this is a special item
				local has = hasGSItem(1912);
				if(has) then
					gsid = 1912;
				end
			end
		end
	end
	if(type(gsid) == "number") then
		page_addr = format("%s?gsid=%d", page_addr, gsid);
		has_item = true;
	elseif(type(guid) == "number") then
		page_addr = format("%s?guid=%d", page_addr, guid);
		has_item = true;
	end
	Avatar_equip_upgrade.is_pending = false;
	Avatar_equipment_subpage:BindParent("EquipUpgrade",self);
	local width,height = 759,470;

	local params = {
			url = page_addr, 
			name = "Avatar_equip_upgrade.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			enable_esc_key = true,
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			directPosition = true,
			align = "_ct",
			x = -width * .5,
			y = -height * .5,
			width = width,
			height = height,}
	System.App.Commands.Call("File.MCMLWindowFrame", params);
	if(params._page)then
		params._page.OnClose = self.Clean;
	end
	if(not has_item) then
		Avatar_equipment_subpage:Update();
	end
	--ItemManager.GetItemsInBag( 12, "0", function(msg)self:Refresh();end, "access plus 0 minutes");
	--CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		--callback = Avatar_equip_upgrade.HookHandler, 
		--hookName = "Hook_UpdateMaterials", appName = "Aries", wndName = "main"});
end

function Avatar_equip_upgrade:Clean()
	local self = Avatar_equip_upgrade
	Avatar_equipment_subpage:ResetStates(1);
	self:ResetStates();
end
function Avatar_equip_upgrade:CloseWindow()
	self.page:CloseWindow();
	--CommonCtrl.os.hook.UnhookWindowsHook({hookName = "Hook_UpdateMaterials", 
		--hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET});
end

function Avatar_equip_upgrade:Refresh(delta)
	self.page:Refresh(delta or 0.1);
end




function Avatar_equip_upgrade:ResetStates()
	self.upvalue = 1;
	self.from_level = nil;
	self.prev_guid = nil;
	self.material.gsid =  nil;
	self.material.guid =  0;
	self.material.number = 0;
	self.hold_number =  0
end


function Avatar_equip_upgrade.CanUpgrade()
	local self = Avatar_equip_upgrade
	if(Avatar_equipment_subpage.IncomingEquip.guid == 0 or Avatar_equipment_subpage.IncomingEquip.guid==-999)then 
		MSG("请先放入你的装备再进行强化。");		
		return false;
	end
	if(addonlevel and addonlevel.get_max_addon_level and self.from_level  == addonlevel.get_max_addon_level(Avatar_equipment_subpage.IncomingEquip.gsid))then
		MSG("装备已经满级,不能再强化了。");
		return false;
	end

	if(self.material.number > self.hold_number)then 
		MSG("你强化装备需要的材料不足了哦。");		
		return false 
	end

	return true;
end

function Avatar_equip_upgrade:OnClickItem(arg)
	Avatar_equipment_subpage:ZeroIncomingEquip();
	self:ResetStates();
	Avatar_equipment_subpage:Update(function() self:Refresh(); end);
end

-- obsoleted function
function Avatar_equip_upgrade.HookHandler(nCode, appName, msg, value)
	local self = Avatar_equip_upgrade;
	if(msg.action_type == "post_pe_slot_PageRefresh")then
		self.Refresh();
	end
	return nCode;
end


--[[
	equip exchange
--]]
function Avatar_equip_upgrade.EquipUpgrade(arg)
	NPL.load("(gl)script/apps/Aries/mcml/pe_goal_pointer.lua");
	local goal_manager = commonlib.gettable("MyCompany.Aries.mcml_controls.goal_manager");
	goal_manager.finish("do_addonlevel");

	local self = Avatar_equip_upgrade
	NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
	local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
	if(not DealDefend.CanPass())then
		return
	end
	if(not self.CanUpgrade())then	
		return
	end

	local _, guid = Map3DSystem.Item.ItemManager.IfOwnGSItem(Avatar_equipment_subpage.IncomingEquip.gsid);
	if(guid)then
		Avatar_equip_upgrade.is_pending = true;
		Avatar_equip_upgrade.UpdateBtnState();
		LOG.std(nil, "info", "Avatar_equip_upgrade", "do upgrade gsid %d, guid %d", Avatar_equipment_subpage.IncomingEquip.gsid or 0, guid or 0);
		System.GSL_client:SendRealtimeMessage("sPowerAPI", {name="SetItemAddonLevel", params={guid=guid}});
	end
end
function Avatar_equip_upgrade.UpdateBtnState()
	if(Avatar_equip_upgrade.page)then
		local btn = Avatar_equip_upgrade.page:FindControl("btnAllEquipSlotting");
		if(btn)then
			btn.enabled = not Avatar_equip_upgrade.is_pending;
		end
	end
end
function Avatar_equip_upgrade.ClearTimer()
	Avatar_equip_upgrade.upgrage_successful = false;
	if(Avatar_equip_upgrade.timer)then
		Avatar_equip_upgrade.timer.callbackFunc = nil;
		Avatar_equip_upgrade.timer:Change();
	end
end
function Avatar_equip_upgrade.UpgradeHandle()
	Avatar_equip_upgrade.is_pending = false;
	Avatar_equip_upgrade.UpdateBtnState();
	Avatar_equip_upgrade.upgrage_successful = true;
	if(not Avatar_equip_upgrade.timer)then
		Avatar_equip_upgrade.timer = commonlib.Timer:new();
	end
	Avatar_equip_upgrade.timer.callbackFunc = function(timer)
		Avatar_equip_upgrade.upgrage_successful = false;
		Avatar_equip_upgrade:Refresh();
	end;
	Avatar_equip_upgrade.timer:Change(2000, nil);
	Avatar_equip_upgrade:Refresh();
	local media_file = "Audio/Haqi/UI/AcceptQuest_teen.ogg";
	local audio_src = AudioEngine.CreateGet(media_file);
	audio_src.file = media_file;
	audio_src:play();
end