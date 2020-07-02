--[[
Title: 
Author(s): leio
Date: 2012/07/10
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/UserBag/EquipHelper.lua");
local EquipHelper = commonlib.gettable("MyCompany.Aries.Inventory.EquipHelper");
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/UserBag/BagHelper.lua");
local BagHelper = commonlib.gettable("MyCompany.Aries.Inventory.BagHelper");
NPL.load("(gl)script/apps/Aries/ApparelTranslation/GemTranslationHelper.lua");
local GemTranslationHelper = commonlib.gettable("MyCompany.Aries.ApparelTranslation.GemTranslationHelper");
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/apps/Aries/ApparelTranslation/GemTranslationHelper.lua");
local GemTranslationHelper = commonlib.gettable("MyCompany.Aries.ApparelTranslation.GemTranslationHelper");
NPL.load("(gl)script/apps/Aries/Items/item.addonlevel.lua");
local addonlevel = commonlib.gettable("MyCompany.Aries.Items.addonlevel");
local EquipHelper = commonlib.gettable("MyCompany.Aries.Inventory.EquipHelper");
local ItemManager = Map3DSystem.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local Player = commonlib.gettable("MyCompany.Aries.Player");


local function BetterEquipmentCompareFunc(last_gsItem, gsItem)
	local is_better, new_value
	local needLvl=gsItem.template.stats[138] or 0;  -- 掉落装备级别
	local needSchool=gsItem.template.stats[137];  -- 掉落装备可用系别
	if (Player.GetLevel() >= needLvl and (not needSchool or CommonClientService.IsRightSchool(gsItem.gsid))) then
		if(last_gsItem) then
			local needLvl2 = last_gsItem.template.stats[138] or 0;  -- 掉落装备级别
			if(needLvl2 < needLvl) then
				return true, needLvl;
			end
		else
			return true, needLvl;
		end
	end
end

function EquipHelper.BetterEquipmentWithGemsCompareFunc(last_gsItem, gsItem)
	if(not last_gsItem and gsItem) then
		if(EquipHelper.HasFreeSlot(gsItem.gsid)) then
			return true;
		end
	end
end

-- get the first(TODO: not best)  equipment that has a slot to mount gems. 
function EquipHelper.GetBestFreeSlotItem()
	local new_item = ItemManager.GetBestEquipmentByBag(nil, nil, EquipHelper.BetterEquipmentWithGemsCompareFunc)
	if(new_item) then
		return new_item.gsid;
	end
end

-- whether gsid equipment is better than the one we are wearing. 
-- @param gsid: whether the given gsid is a better one than the one wearing
-- @param only_show_best: if true, 
function EquipHelper.IsBetterEquipment(gsid, only_show_best)
	if(not gsid)then return end
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(gsItem)then
		local ItemInventoryType = gsItem.template.inventorytype; -- 掉落装备类别
		if (gsItem.template.class==1 and ItemInventoryType) then -- judge item is equip or not
			local needLvl=gsItem.template.stats[138] or 0;  -- 掉落装备级别
			local needSchool=gsItem.template.stats[137];  -- 掉落装备可用系别
			local needSex=gsItem.template.stats[63];  -- 男女可用
			local is_right_sex = (not needSex or Player.GetGender() == if_else(needSex==0, "male","female") )
			
			if(Player.GetLevel() >= needLvl and (not needSchool or CommonClientService.IsRightSchool(gsid)) and is_right_sex) then
				local curItem = ItemManager.GetItemByBagAndPosition(0, ItemInventoryType); -- 当前身上穿着的该类装备级别
				if(curItem) then
					curItem = ItemManager.GetGlobalStoreItemInMemory(curItem.gsid)
				end
				if (not curItem or (curItem.template.stats[138] or 0)<needLvl ) then
					-- it is a better equipment, now filter to see if it is also the best equipment in my bag. 
					-- @note: this function is kind of slow. 
					if(only_show_best) then
						local new_item = ItemManager.GetBestEquipmentByBag(1, ItemInventoryType, BetterEquipmentCompareFunc)
						if(new_item and new_item.gsid == gsid) then
							return true;
						end
					else
						return true;
					end
				end
			end
		end
	end
end


function EquipHelper.CanUpgrade(gsid)
	local self = EquipHelper;
	if(not gsid)then return end
	local item = GemTranslationHelper.GetUserItem(nil,gsid);
	if(item and item.GetAddonLevel)then
		if(addonlevel.can_have_addon_property(gsid))then
			local max_addon_level = addonlevel.get_max_addon_level(gsid);
			local addon_level = item:GetAddonLevel();
			local required_gsid,required_number = addonlevel.get_levelup_req(gsid, addon_level);
			required_number = required_number or 0;
			local __,__,__,money = hasGSItem(required_gsid);
			money = money or 0;
			--有足够的奇豆
			--没有满级
			--本系
			if(money > 0 and money >= required_number and addon_level < max_addon_level and CommonClientService.IsRightSchool(gsid))then
				return true;
			end
		end
	end
end

-- gsid: can be nil
function EquipHelper.DoUpgrade(gsid)
	local self = EquipHelper;
	if(gsid and not self.CanUpgrade(gsid))then
		return
	end

	NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/Avatar_equip_upgrade.lua");
	local Avatar_equip_upgrade = commonlib.gettable("MyCompany.Aries.NPCs.ShoppingZone.Avatar_equip_upgrade");
	Avatar_equip_upgrade.ShowPage(gsid);
end


--宝石镶嵌-------------------------------------------------------------------------------------------
--[[
	是否包含可以升级的装备 ,是否包含可以镶嵌宝石的装备
	return has_upgrade_item,has_attach_gem_item;

	NPL.load("(gl)script/apps/Aries/UserBag/EquipHelper.lua");
	local EquipHelper = commonlib.gettable("MyCompany.Aries.Inventory.EquipHelper");
	local has_upgrade_item,has_attach_gem_item = EquipHelper.GetEquipmentState();
	commonlib.echo({has_upgrade_item,has_attach_gem_item});
--]]
function EquipHelper.GetEquipmentState()
	local self = EquipHelper;
	local list = GemTranslationHelper.SearchItemListFromBag_Client();
	if(list)then
		local k,v;
		local has_upgrade_item = false;--是否包含可以升级的装备
		local has_attach_gem_item = false;--是否包含可以镶嵌宝石的装备
		for k,v in ipairs(list) do
			local gsid = v.gsid;
			if(not has_upgrade_item)then
				has_upgrade_item = self.CanUpgrade(gsid);
			end
			if(not has_attach_gem_item)then
				has_attach_gem_item = self.CanAttachGem(gsid);
			end
		end
		return has_upgrade_item,has_attach_gem_item;
	end
end
--背包中宝石列表
function EquipHelper.GetGems()
	local gems_list = BagHelper.Search_Memory(nil,"Gem",nil);
	return gems_list;
end

-- if there is free slot on the given equipement that mount gems. 
-- the gsid must match my school 
function EquipHelper.HasFreeSlot(gsid)
	if(not gsid)then return end
	local max_cnt_1,usable_slots_1,unusable_slots_1,__ = GemTranslationHelper.GetUserTotalHoleCount(nil,gsid);
	--有孔位
	if(usable_slots_1 and usable_slots_1 > 0 and CommonClientService.IsRightSchool(gsid))then
		return true;
	end
end

--装备是否可以镶嵌宝石
--判断条件是：装备有孔位 并且有宝石
function EquipHelper.CanAttachGem(gsid,gems_list)
	local self = EquipHelper;
	if(not gsid)then return end

	local max_cnt_1,usable_slots_1,unusable_slots_1,__ = GemTranslationHelper.GetUserTotalHoleCount(nil,gsid);

	--if(System.options.version == "kids") then
		--local gsItem = ItemManager.GetGlobalStoreItemInMemory(self.gsid);
		--if(gsItem) then
			--max_cnt_1 = gsItem.template.stats[36] or 0;
			--usable_slots_1 = max_cnt_1;
			--if(max_cnt_1 > 0) then
				--local _holdgems
				--if(self.goods.GetSocketedGems)then
					--_holdgems = self.goods:GetSocketedGems();
					--if(_holdgems) then
						--unusable_slots_1 = #_holdgems;
					--end
				--end
			--end
		--end
	--end

	
	--有孔位
	if(usable_slots_1 and usable_slots_1 > 0 and CommonClientService.IsRightSchool(gsid))then
		--有宝石
		gems_list = gems_list or BagHelper.Search_Memory(nil,"Gem",nil);
		if(gems_list and #gems_list > 0)then
			return true;
		end
	end
end
--是否可以平移
function EquipHelper.CanTranslation(gsid,translation_list)
	local self = EquipHelper;
	if(not gsid or not translation_list)then return end
	local k,v;
	for k,v in ipairs(translation_list) do
		if(v.from_gsid == gsid)then
			return true;
		end
	end
end

-- get the total number of gems on the given gsid
-- @Note: only used on client side. 
function EquipHelper.GetMountedGemCount(gsid)
	if(System.options.version == "kids") then
		local bHas,guid = hasGSItem(gsid);
		if(bHas)then
			local item = ItemManager.GetItemByGUID(guid);
			if(item and item.GetSocketedGems)then
				local gems = item:GetSocketedGems();
				if(gems and #gems>0) then
					return #gems;
				end
			end
		end
	else
		-- TODO: for teen
	end
	return 0;
end

function EquipHelper.GetMaxGemCount(gsid)
	if(System.options.version == "kids") then
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
		if(gsItem)then
			local hole_cnt = gsItem.template.stats[36] or 0;
			return hole_cnt;
		end
	else
		-- TODO: for teen.
	end
	return 0;
end

-- get the total addon level on the given gsid
-- @Note: only used on client side. 
function EquipHelper.GetAddonLevel(gsid)
	local bHas,guid = hasGSItem(gsid);
	if(bHas)then
		local item = ItemManager.GetItemByGUID(guid);
		if(item.GetAddonLevel) then
			return item:GetAddonLevel() or 0;
		end
	end
	return 0;
end

-- get the user item level 
function EquipHelper.GetUseLevel(gsid)
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(gsItem)then
		local needLvl = gsItem.template.stats[138] or 0; 
		return needLvl;
	end
end