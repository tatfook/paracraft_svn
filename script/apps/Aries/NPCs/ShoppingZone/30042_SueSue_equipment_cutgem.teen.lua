--[[
Title: Retrieve_gems_from_equipment
Author(s): WD
Date: 2011/08/11

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/DefaultTheme.teen.lua");
MyCompany.Aries.Theme.Default:Load();
NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/30042_SueSue_equipment_cutgem.teen.lua");
local Retrieve_gems_from_equipment = commonlib.gettable("MyCompany.Aries.NPCs.ShoppingZone.Retrieve_gems_from_equipment");
Retrieve_gems_from_equipment.ShowPage();
purpose:retrieve gems from avatar equipment for teen version
------------------------------------------------------------
]]

NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/Avatar_equipment_subpage.lua");

--instance
local Retrieve_gems_from_equipment = commonlib.gettable("MyCompany.Aries.NPCs.ShoppingZone.Retrieve_gems_from_equipment");
local Avatar_equipment_subpage = commonlib.gettable("MyCompany.Aries.NPCs.ShoppingZone.Avatar_equipment_subpage");

--shortcut
local ItemManager = Map3DSystem.Item.ItemManager;
local GetItemByID = ItemManager.GetGlobalStoreItemInMemory;
local GetItemsCount = ItemManager.GetItemCountInBag;
local GetItemsInBag = ItemManager.GetItemsInBag;
local hasGSItem = ItemManager.IfOwnGSItem;
local GetItemByGUID = ItemManager.GetItemByGUID;
local UnEquipGemFromSocket2 = ItemManager.UnEquipGemFromSocket2;
local MSG = _guihelper.MessageBox;
local echo = commonlib.echo;
local SLOTS_COUNT = 6;

local ENABLE_TRACK = true;
local function TRACK(caption,obj)
	if(ENABLE_TRACK)then
		echo(caption);
		echo(obj);
	end
end

Retrieve_gems_from_equipment.RetrieveGems = {};
Retrieve_gems_from_equipment.CostItems = 0;
Retrieve_gems_from_equipment.HoldItems =  0;
Retrieve_gems_from_equipment.CONSUME_ITEM_ID = 17179;
Retrieve_gems_from_equipment.VisibleFlag = 0;

function Retrieve_gems_from_equipment.ShowPage(gsid)
	
	local self = Retrieve_gems_from_equipment;
	Avatar_equipment_subpage:BindParent("GemRetrieve",self);
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
	

	local width,height = 758,470;

	local page_addr = "script/apps/Aries/NPCs/ShoppingZone/30042_SueSue_equipment_cutgem.teen.html"
	local has_item;
	if(type(gsid) == "number") then
		page_addr = format("%s?gsid=%d", page_addr, gsid);
		has_item = true;
	end

	local params = {
			url = page_addr, 
			name = "Retrieve_gems_from_equipment.ShowPage", 
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

--[[
	get hold items and return it
	@param gsid:item gsid
]]
function Retrieve_gems_from_equipment:GetItemsUnits(gsid)
	local has, __, ___, copies = hasGSItem(gsid)
	self.HoldItems = copies or 0;
	return self.HoldItems;
end

function Retrieve_gems_from_equipment:GetItemName(gsid)
	if(not self.ITEM_NAME)then
		local item = GetItemByID(gsid);
		if(item and item.template)then
			self.ITEM_NAME  = item.template.name;
		end
	end
	return self.ITEM_NAME or "unknown name"
end


function Retrieve_gems_from_equipment:Init()
	self.page = document:GetPageCtrl();
	
	if(Avatar_equipment_subpage) then
		self:GetItemsUnits(self.CONSUME_ITEM_ID)
		if(Avatar_equipment_subpage.IncomingEquip.guid) then
			self.page:SetValue("IncomingEquipGuid",Avatar_equipment_subpage.IncomingEquip.guid or 0);
		end

		self.CostItems = if_else(Avatar_equipment_subpage.IncomingEquip.gemsCount ~= 0,Avatar_equipment_subpage.IncomingEquip.gemsCount,"");

	end

	self:ResetItems();
	self:SetControlState();
	
	--set holded gems to slots
	if(Avatar_equipment_subpage.IncomingEquip.holdGems) then
		local i,v;
		for i,v in ipairs(Avatar_equipment_subpage.IncomingEquip.holdGems) do
			if(v and type(v) == "table") then
				self.page:SetValue("IncomingGemGsid" .. i,if_else(v.gsid and v.gsid == 0,-999,v.gsid or -999));
				self.page:SetUIEnabled("btnGemRetrieve" .. i,true);
			end
		end
	end
	self.VisibleFlag = Avatar_equipment_subpage.IncomingEquip.gemsCount;
end

function Retrieve_gems_from_equipment:Refresh(delta)
	self.page:Refresh(delta or 0.1);
end

--[[
	@param:arg ref to gsid
	@param:aux-param
--]]
function Retrieve_gems_from_equipment:CancelItem(arg,param)
	if (param == "equip") then
		Avatar_equipment_subpage:ZeroIncomingEquip();
		Avatar_equipment_subpage:Update(function()self:Refresh(); end)
	end
	
end

function Retrieve_gems_from_equipment:Check()
	if(Avatar_equipment_subpage:IsEmpty()) then
		return "你还没有装备。";
	end

	if( Avatar_equipment_subpage.IncomingEquip.guid == 0) then
		return "你没有选择一件装备，请先选择镶嵌了宝石的装备！"
	elseif (Avatar_equipment_subpage.IncomingEquip.gemsCount == 0) then
		return "这件装备还没有镶嵌任何宝石。"
	end

	if(self.CostItems  == 0 or self.CostItems == "") then
		return "你没有要回收的宝石！"
	end
	
	if(self.CostItems > self.HoldItems) then
		return string.format("需要的材料【%s】不足了！",Retrieve_gems_from_equipment:GetItemName(Retrieve_gems_from_equipment.CONSUME_ITEM_ID))
	end
end

function Retrieve_gems_from_equipment.DoRetrieveGem(arg)
	local self = Retrieve_gems_from_equipment;
	NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
	local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
	if(not DealDefend.CanPass())then
		return
	end
	local err = self:Check()

	if(err)then
		MSG(err)
		return
	end

	local gemIndex = tonumber(string.sub(arg,-1));

	if(gemIndex ~= 0)then
		self.RetrieveGems[1] = Avatar_equipment_subpage.IncomingEquip.holdGems[gemIndex].gsid;
	else
		--[[retrieve all gems from equip slots]]
		local i,v;
		local holdItems = Avatar_equipment_subpage.IncomingEquip.holdGems;
		self.RetrieveGems = {};

		for i,v in ipairs(holdItems) do
			self.RetrieveGems[#self.RetrieveGems + 1] = v.gsid;
		end
	end


	UnEquipGemFromSocket2(self.RetrieveGems,Avatar_equipment_subpage.IncomingEquip.guid, nil,
		function(msg)
			if(msg) then
				TRACK("MSG",msg);
				if(msg.issuccess) then
					self.CostItems = 0;
					MSG("恭喜你，成功摘除了宝石！");
					Avatar_equipment_subpage:Update();
				elseif(msg.errorcode == 427)then
					MSG("摘除宝石需要宝石凿！");	
				elseif(msg.errorcode == 433)then
					MSG("你的背包满了！");	
				elseif(msg.errorcode == 493)then
					MSG("参数不符合要求！");	
				else
					echo(msg.errorcode);
					MSG("很遗憾，没有成功摘除宝石！");	
				end
			end
		end);
end

function Retrieve_gems_from_equipment:Clean()
	Avatar_equipment_subpage:ResetStates();
	Retrieve_gems_from_equipment.RetrieveGems = {};
end

function Retrieve_gems_from_equipment:CloseWindow()
	self.page:CloseWindow();
end

function Retrieve_gems_from_equipment:SetControlState()
	local i;
	for i = 1, SLOTS_COUNT do
		self.page:SetUIEnabled("btnGemRetrieve" .. i,false);
	end

	self.page:SetUIEnabled("btnAllGemsRetrieve0",false);	
	self.VisibleFlag = 0;

	if(Avatar_equipment_subpage.IncomingEquip.gemsCount > 0)then
		self.page:SetUIEnabled("btnAllGemsRetrieve0",true);	
	end
	
end

function Retrieve_gems_from_equipment:ResetItems()
	local i;
	for i = 1, SLOTS_COUNT do
		self.page:SetValue("IncomingGemGsid" .. i,-999);
	end
end
