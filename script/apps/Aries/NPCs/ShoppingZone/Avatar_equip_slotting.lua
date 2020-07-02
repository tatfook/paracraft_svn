--[[
Title: code behind for Avatar_equip_slotting
Author(s): WD
Date: 2011/08/16

use the lib:
------------------------------------------------------------
purpose:equipment slotting for teen version

NPL.load("(gl)script/apps/Aries/DefaultTheme.teen.lua");
MyCompany.Aries.Theme.Default:Load();
NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/Avatar_equip_slotting.lua");
local Avatar_equip_slotting = commonlib.gettable("MyCompany.Aries.NPCs.ShoppingZone.Avatar_equip_slotting");
Avatar_equip_slotting.ShowPage();
------------------------------------------------------------
--]]

local ItemManager = Map3DSystem.Item.ItemManager;
local GetItemByID = ItemManager.GetGlobalStoreItemInMemory;
local GetItemsCount = ItemManager.GetItemCountInBag;
local GetItemsInBag = ItemManager.GetItemsInBag;
local hasGSItem = ItemManager.IfOwnGSItem;
local MSG = _guihelper.MessageBox;
local echo = commonlib.echo;

local SLOTS_COUNT = 6;

local CreateGemHole = ItemManager.CreateGemHole;

NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/Avatar_equipment_subpage.lua");

local Avatar_equip_slotting = commonlib.gettable("MyCompany.Aries.NPCs.ShoppingZone.Avatar_equip_slotting");
local Avatar_equipment_subpage = commonlib.gettable("MyCompany.Aries.NPCs.ShoppingZone.Avatar_equipment_subpage")

Avatar_equip_slotting._DEBUG = Avatar_equip_slotting._DEBUG or false;
function Avatar_equip_slotting:LOG(caption,obj)
	if(self._DEBUG)then
		echo(caption);
		echo(obj);
	end
end

--Avatar_equip_slotting.UnSlot = Avatar_equip_slotting.UnSlot or 0;

Avatar_equip_slotting.CostQidou = 0;
Avatar_equip_slotting.CostSlotRocks = 0;
Avatar_equip_slotting.VisibleFlag = 0;

--打孔石消耗规则
Avatar_equip_slotting.CostSlotRocks_Table = {
	clothes_shoes = {[4] = 5,[5] = 12,[6] = 24,factor = 25,},
	acces = {[1] = 10,[2] =20, [3] = 30, factor = 50,},
	weapons = {[1] = 8,[2] = 15, [3] = 25,[4] = 40,[5] = 60,[6] = 100,factor = 100,},
};

--constants
Avatar_equip_slotting.SlotRockGsid = 17177; --SlotRockGsid is constant

function Avatar_equip_slotting.GetHoldSlotRocks()
	local _, __, ___, copies = hasGSItem(Avatar_equip_slotting.SlotRockGsid)
	return copies or 0;
end

function Avatar_equip_slotting:Init()
	self.page = document:GetPageCtrl();
	
	self.CostQidou = 0;
	self.CostSlotRocks = 0;

	if(Avatar_equipment_subpage and Avatar_equipment_subpage.IncomingEquip.guid) then
		self.page:SetValue("IncomingEquipGuid",Avatar_equipment_subpage.IncomingEquip.guid or -999);
	end

	if(Avatar_equipment_subpage.filter ~= 0) then
		self.page:SetValue("tabsEquipments",tostring(Avatar_equipment_subpage.filter));
	end

	if(Avatar_equipment_subpage.IncomingEquip.holdSlots < Avatar_equipment_subpage.IncomingEquip.totalSlots) then
		local i,v;
		local items = Avatar_equipment_subpage.DisplayItems;
		self:LOG("items",items)
		for i,v in ipairs(items) do
			if(v.guid == Avatar_equipment_subpage.IncomingEquip.guid) then
				local gsItem;
				if(v.gsid) then
					gsItem = ItemManager.GetGlobalStoreItemInMemory(v.gsid);
				end
				self.CostSlotRocks = Avatar_equipment_subpage:GetCostRocks(gsItem, v.level, v.typ);
				self:LOG("self.CostSlotRocks:",self.CostSlotRocks);
				self.CostQidou = self.CostSlotRocks_Table[v.typ].factor * (Avatar_equipment_subpage.IncomingEquip.holdSlots + 1) * v.level;
				break;
			end
		end
	end

	self:SetControlState();

end

function Avatar_equip_slotting.GetCostSlotRocks()
	if(Avatar_equip_slotting.CostSlotRocks == 0)then
		return ""
	end
	return Avatar_equip_slotting.CostSlotRocks
end

function Avatar_equip_slotting.GetCostQidou()
	if(Avatar_equip_slotting.CostQidou == 0)then
		return ""
	end
	return Avatar_equip_slotting.CostQidou
end

function Avatar_equip_slotting.GetHoldQidou()
	return MyCompany.Aries.Player.GetMyJoybeanCount() or 0
end

function Avatar_equip_slotting:SetControlState()
	local i;
	for i = 1, SLOTS_COUNT do
		self.page:SetUIEnabled("btnEquipSlotting" .. i,false);
		--self.page:SetEnable("btnEquipSlotting" .. i,"visible",false);
	end

	--self.page:SetUIEnabled("btnAllEquipSlotting",false);
	--self.page:FindControl("btnAllEquipSlotting").visible = false;	
	self.VisibleFlag = 0;

	for i = Avatar_equipment_subpage.IncomingEquip.holdSlots+1, if_else(Avatar_equipment_subpage.IncomingEquip.holdSlots+1 <= Avatar_equipment_subpage.IncomingEquip.totalSlots,
	Avatar_equipment_subpage.IncomingEquip.holdSlots+1, Avatar_equipment_subpage.IncomingEquip.totalSlots)do
		self.page:SetUIEnabled("btnEquipSlotting" .. i,true);
		self.VisibleFlag = tonumber(i);
	end

	--[[
	if(Avatar_equipment_subpage.IncomingEquip.totalSlots > Avatar_equipment_subpage.IncomingEquip.holdSlots)then
		self.page:SetUIEnabled("btnAllEquipSlotting",true);	
	end
	]]
end

function Avatar_equip_slotting.ShowPage()
	local self = Avatar_equip_slotting;

	Avatar_equipment_subpage:BindParent("EquipSlotting",self);
	local width,height = 758,470;

	local params = {
			url = "script/apps/Aries/NPCs/ShoppingZone/Avatar_equip_slotting.html", 
			name = "Avatar_equip_slotting.ShowPage", 
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
	Avatar_equipment_subpage:Update();
end

function Avatar_equip_slotting:Clean()
	Avatar_equipment_subpage:ResetStates(1);
end

function Avatar_equip_slotting:CloseWindow()
	self.page:CloseWindow();
end

function Avatar_equip_slotting:Refresh(delta)
	self.page:Refresh(delta or 0.1);
end

function Avatar_equip_slotting:OnClickItem(arg)
	Avatar_equipment_subpage:ZeroIncomingEquip();
	Avatar_equipment_subpage:Update();
end

--[[
	open purchase window
--]]
function Avatar_equip_slotting.ShowPurchasePage()


end

--[[
	slotting for equipment
--]]
function Avatar_equip_slotting.EquipSlotting(arg)
	local self = Avatar_equip_slotting
	if(Avatar_equipment_subpage and  Avatar_equipment_subpage.IncomingEquip.guid == -999) then
		MSG("在打孔之前记得选择一件装备！");
		return;
	end

	if(Avatar_equipment_subpage.IncomingEquip.totalSlots == 0) then
		MSG("这件装备不能打孔。");
		return;
	end

	if(Avatar_equipment_subpage.IncomingEquip.holdSlots == Avatar_equipment_subpage.IncomingEquip.totalSlots) then
		MSG("这件装备已经不需要打孔了。");
		return;
	end

	self:LOG("self.CostSlotRocks",self.CostSlotRocks)
	if(self.CostSlotRocks > self.GetHoldSlotRocks()) then
		MSG("你的打孔石不足以进行本次打孔。");
		return;
	end

	if( Avatar_equip_slotting.CostQidou > Avatar_equip_slotting.GetHoldQidou()) then
		MSG("你的钱币不足以进行本次打孔。");
		return;
	end


	echo(Avatar_equipment_subpage.IncomingEquip.guid);
	if(CreateGemHole and type(CreateGemHole) == "function") then
		CreateGemHole(Avatar_equipment_subpage.IncomingEquip.guid,function(msg)
		if(msg) then
			if(msg.issuccess) then
				MSG("恭喜你，打孔成功！");
				Avatar_equipment_subpage.IncomingEquip.holdSlots = Avatar_equipment_subpage.IncomingEquip.holdSlots + 1;
				self:Refresh();
			else
				MSG("很遗憾，没有成功打孔！");
				echo("CreateGemHole is failed.");
			end
		end
		end,function(msg) end,function(msg) end);

	else
		echo("CreateGemHole is not a valid function!");
	end
end