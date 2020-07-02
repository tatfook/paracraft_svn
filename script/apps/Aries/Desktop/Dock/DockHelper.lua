--[[
Title: 
Author(s): leio
Company: 
Date: 2012/06/18
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/Dock/DockHelper.lua");
local DockHelper = commonlib.gettable("MyCompany.Aries.Desktop.DockHelper");
local is_gem = DockHelper.IsGem(gsid);
commonlib.echo(is_gem);
NPL.load("(gl)script/apps/Aries/Desktop/Dock/DockHelper.lua");
local DockHelper = commonlib.gettable("MyCompany.Aries.Desktop.DockHelper");
local can_upgrade = DockHelper.CanUpgrade(1407);
commonlib.echo(can_upgrade);
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/UserBag/BagHelper.lua");
local BagHelper = commonlib.gettable("MyCompany.Aries.Inventory.BagHelper");
NPL.load("(gl)script/apps/Aries/ApparelTranslation/GemTranslationHelper.lua");
local GemTranslationHelper = commonlib.gettable("MyCompany.Aries.ApparelTranslation.GemTranslationHelper");
NPL.load("(gl)script/apps/Aries/Items/item.addonlevel.lua");
local addonlevel = commonlib.gettable("MyCompany.Aries.Items.addonlevel");
NPL.load("(gl)script/kids/3DMapSystemItem/ItemManager.lua");
local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");
local DockHelper = commonlib.gettable("MyCompany.Aries.Desktop.DockHelper");
--装备是否可以升级
function DockHelper.CanUpgrade(gsid)
	if(not gsid)then return end
	addonlevel.init();
	if(addonlevel.can_have_addon_property(gsid))then
		return true;
	end
end
--是否是宝石
function DockHelper.IsGem(gsid)
	local self = DockHelper;
	if(not gsid)then return end
	if(not self.gems_bag_list)then
		self.gems_bag_list = {};
		BagHelper.PushTable(self.gems_bag_list,BagHelper.GetBagList("Gem","1"));
		BagHelper.PushTable(self.gems_bag_list,BagHelper.GetBagList("Gem","2"));
		BagHelper.PushTable(self.gems_bag_list,BagHelper.GetBagList("Gem","3"));
		BagHelper.PushTable(self.gems_bag_list,BagHelper.GetBagList("Gem","4"));
		BagHelper.PushTable(self.gems_bag_list,BagHelper.GetBagList("Gem","5"));
	end
	if(BagHelper.IncludeGsid(self.gems_bag_list,gsid))then
		return true;
	end
end
function DockHelper.IsCombatDeck(gsid)
	local self = DockHelper;
	if(not gsid)then return end
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(gsItem)then
		local class = gsItem.template.class;
		local subclass = gsItem.template.subclass;
		local bagfamily = gsItem.template.bagfamily;
		if(bagfamily == 1 and class == 19 and subclass == 1)then
			return true;
		end
	end
end