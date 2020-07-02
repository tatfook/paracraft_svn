--[[
Title: code behind for Avatar_gems_tesselate
Author(s): WD
Date: 2011/08/03

use the lib:
------------------------------------------------------------
purpose:for avatar gems tesselate

NPL.load("(gl)script/apps/Aries/DefaultTheme.teen.lua");
MyCompany.Aries.Theme.Default:Load();
NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/Avatar_gems_tesselate.lua");
local Avatar_gems_tesselate = commonlib.gettable("MyCompany.Aries.Desktop.Avatar_gems_tesselate");
Avatar_gems_tesselate.ShowPage();
------------------------------------------------------------
--]]


NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/Avatar_equipment_subpage.lua");
NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/Avatar_gems_subpage.lua");
NPL.load("(gl)script/apps/Aries/NPCs/ShoppingZone/Avatar_tesselate_subpage.lua");

local Avatar_gems_subpage = commonlib.gettable("MyCompany.Aries.NPCs.ShoppingZone.Avatar_gems_subpage");
local Avatar_equipment_subpage = commonlib.gettable("MyCompany.Aries.NPCs.ShoppingZone.Avatar_equipment_subpage");
local Avatar_tesselate_subpage = commonlib.gettable("MyCompany.Aries.NPCs.ShoppingZone.Avatar_tesselate_subpage");

local Avatar_gems_tesselate = commonlib.gettable("MyCompany.Aries.NPCs.ShoppingZone.Avatar_gems_tesselate");
local Player = commonlib.gettable("MyCompany.Aries.Player");

local echo = commonlib.echo;

Avatar_gems_tesselate._DEBUG = Avatar_gems_tesselate._DEBUG or false;
function Avatar_gems_tesselate:LOG(caption,obj)
	if(self._DEBUG)then
		echo(caption);
		echo(obj);
	end
end

local ItemManager = Map3DSystem.Item.ItemManager;
local GetItemByID = ItemManager.GetGlobalStoreItemInMemory;
local GetItemsCount = ItemManager.GetItemCountInBag;
local GetItemsInBag = ItemManager.GetItemsInBag;
local GetItemByBagAndOrder = ItemManager.GetItemByBagAndOrder;
local hasGSItem = ItemManager.IfOwnGSItem;
local MountGemInSocket2 = ItemManager.MountGemInSocket2;
local MSG = _guihelper.MessageBox;
local random = math.random;
local strsub = string.sub;
local strfind = string.find;
local format = string.format;
local CreateGemHole = ItemManager.CreateGemHole;
local SLOTS_COUNT = 6;

--lucky items defined
Avatar_gems_tesselate.LUCKY_ITEM_ID = 26701
Avatar_gems_tesselate.SlotRockGsid = 17177;
Avatar_gems_tesselate.LuckyItemCnt =0;
Avatar_gems_tesselate.CostSlotRocks = 1;
Avatar_gems_tesselate.CostMoneyFactor = {clothes_shoes = 25,acces = 50,weapons = 100,};
Avatar_gems_tesselate.modValueRange = {-4,-3,-2,-1,0,1,2,3,4};
Avatar_gems_tesselate.modValue = Avatar_gems_tesselate.modValue or 0;

Avatar_gems_tesselate.InitialOdds =0;
Avatar_gems_tesselate.TesselateOdds = Avatar_gems_tesselate.TesselateOdds or 0;
--Avatar_gems_tesselate.IncomingTesselGsid1 = Avatar_gems_tesselate.IncomingTesselGsid1 or 0;
--Avatar_gems_tesselate.IncomingTesselGsid2 = Avatar_gems_tesselate.IncomingTesselGsid2 or 0;
--Avatar_gems_tesselate.IncomingTesselGsid3 = Avatar_gems_tesselate.IncomingTesselGsid3 or 0;
Avatar_gems_tesselate.HoldJoybean = 0;
Avatar_gems_tesselate.CostJoybean = 0;--EQUIP_LEVEL * ( 2 ^ GEM_LEVEL ) * 100
Avatar_gems_tesselate.SlotCostJoybean = 0;

--Avatar_gems_tesselate.CanTessel = false;
Avatar_gems_tesselate.starCount = -1;
Avatar_gems_tesselate.VisibleFlag_Tessel = 0;
Avatar_gems_tesselate.VisibleFlag_Slot = 0;
Avatar_gems_tesselate.IncomingLuckyItems = {};
Avatar_gems_tesselate.upgradeGemPos = nil;
Avatar_gems_tesselate.MAX_USE_LUCKYS = 100

--joybean cost rule
Avatar_gems_tesselate.CostSlotRocks_Table = {
	clothes_shoes = {factor = 25,},
	acces = {factor = 50,},
	weapons = {factor = 100,},
};

function Avatar_gems_tesselate:Init()
	self.page = document:GetPageCtrl();

	if(Avatar_equipment_subpage and Avatar_gems_subpage )  then
		self.HoldJoybean = MyCompany.Aries.Player.GetMyJoybeanCount();
		Avatar_gems_tesselate.HoldLuckyItem = self:GetItemUnits(Avatar_gems_tesselate.LUCKY_ITEM_ID)
		--[[if(Avatar_equipment_subpage.IncomingEquip.gemsCount == Avatar_equipment_subpage.IncomingEquip.holdSlots and 
			Avatar_equipment_subpage.IncomingEquip.guid ~= 0 and 
			Avatar_gems_subpage.IncomingGem.gsid ~= 0) then
	
			Avatar_gems_subpage:ResetStates();
			Avatar_gems_subpage:Update();
		end
		]]
		self:ResetControlState();

		--set holded gems to slots
		if(Avatar_equipment_subpage.IncomingEquip.holdGems) then
			local i,v;
			for i,v in ipairs(Avatar_equipment_subpage.IncomingEquip.holdGems) do
				if(v and type(v) == "table") then
					self:LOG("SET IncomingGemGsid" .. i,"IncomingGemGsid" .. i);
					self:LOG("Avatar_gems_tesselate.upgradeGem:" ,Avatar_gems_tesselate.upgradeGem);
					self:LOG("Avatar_equipment_subpage.IncomingEquip.holdGems:" ,Avatar_equipment_subpage.IncomingEquip.holdGems);
					
					self.page:SetValue("IncomingGemGsid" .. i,v.gsid);--mapping gems to items list
					if(Avatar_gems_tesselate.upgradeGem and v.gsid == Avatar_gems_tesselate.upgradeGem)then
						self:LOG("enable btnEquipTessle" .. i);
						self.page:SetUIEnabled("btnEquipTessle" .. i,true);
					else
						self.page:SetUIEnabled("btnEquipTessle" .. i,false);
					end
				end
			end
		end

		--calculate cost money for tesselate.
		self.CostJoybean = (Avatar_equipment_subpage.IncomingEquip.level or 0) * 
						100 * if_else(Avatar_gems_subpage.IncomingGem.level and Avatar_gems_subpage.IncomingGem.level == 0,0,math.pow(2,(Avatar_gems_subpage.IncomingGem.level or 0)));
						
		self:LOG("Avatar_gems_subpage.IncomingGem:" ,Avatar_gems_subpage.IncomingGem);

		--set incoming gem to slot
		if(Avatar_gems_subpage.IncomingGem.gsid ~= -999) then
			self:CalcOdds();
			--[[
			local typTable,k,v,find,k2,v2;
			
			typTable = Avatar_equipment_subpage.AllowableGemsTypeTable[Avatar_equipment_subpage.IncomingEquip.typ];			
			
			if(Avatar_gems_subpage.IncomingGem.typ ~= 0 and typTable) then
				for k,v in pairs(typTable) do
					for k2,v2 in ipairs(v) do
						if(v2 == Avatar_gems_subpage.IncomingGem.typ) then
							find = true;
							break;
						end
					end
				end
			end

			--if current incoming gem's mount attribute is not affect equip,break it.
			if(not find) then
				self.TesselateOdds = 0;
				self.CostJoybean = "";
				self.CanTessel = false;
			else
				self.CanTessel = true;
			end
			]]
		end

		--tessel new gem
		if((Avatar_equipment_subpage.IncomingEquip.gemsCount < Avatar_equipment_subpage.IncomingEquip.holdSlots or Avatar_equipment_subpage.IncomingEquip.guid == -999) and
		not Avatar_gems_tesselate.upgradeGem) then
			self.page:SetValue("IncomingGemGsid" .. (Avatar_equipment_subpage.IncomingEquip.gemsCount + 1),Avatar_gems_subpage.IncomingGem.gsid or -999);
		end

		if(Avatar_equipment_subpage.IncomingEquip.guid ~= -999) then
			local index = 1;
			if(Avatar_equipment_subpage.IncomingEquip.gemsCount == 0)then
			 index = 1;
			 else
				if(Avatar_equipment_subpage.IncomingEquip.gemsCount < Avatar_equipment_subpage.IncomingEquip.holdSlots)then
					index = Avatar_equipment_subpage.IncomingEquip.gemsCount + 1;
				end
			 end
			self:LOG("self.upgradeGemPos",self.upgradeGemPos)
			
			if(not Avatar_gems_tesselate.upgradeGem and Avatar_equipment_subpage.IncomingEquip.gemsCount < Avatar_equipment_subpage.IncomingEquip.holdSlots)then
				self.VisibleFlag_Tessel = index;
			elseif(self.upgradeGemPos)then
				self.VisibleFlag_Tessel = self.upgradeGemPos;
			end
			if(self.VisibleFlag_Tessel > 0)then
				self.page:SetUIEnabled("btnEquipTessle" .. self.VisibleFlag_Tessel,true);
			end
		end
		self:SetTesse();
		
		self:LOG("Avatar_gems_tesselate.HoldLuckyItem",Avatar_gems_tesselate.HoldLuckyItem)

		if(not self.ShowTesselOdds()) then
			self.TesselateOdds = 0;
		end

		local i;
		for i = 1, SLOTS_COUNT do
			self.page:SetUIEnabled("btnEquipSlotting" .. i,false);
		end
		self.VisibleFlag_Slot = 0;

		for i = Avatar_equipment_subpage.IncomingEquip.holdSlots+1, if_else(Avatar_equipment_subpage.IncomingEquip.holdSlots+1 <= Avatar_equipment_subpage.IncomingEquip.totalSlots,
		Avatar_equipment_subpage.IncomingEquip.holdSlots+1, Avatar_equipment_subpage.IncomingEquip.totalSlots)do
			self.page:SetUIEnabled("btnEquipSlotting" .. i,true);
			self.VisibleFlag_Slot = tonumber(i);
		end
	
		if(Avatar_equipment_subpage.IncomingEquip.holdSlots < Avatar_equipment_subpage.IncomingEquip.totalSlots) then
			local gsItem;
			if(Avatar_equipment_subpage.IncomingEquip.gsid) then
				gsItem = ItemManager.GetGlobalStoreItemInMemory(Avatar_equipment_subpage.IncomingEquip.gsid);
			end
			self.CostSlotRocks = Avatar_equipment_subpage:GetCostRocks(gsItem, Avatar_equipment_subpage.IncomingEquip.level, Avatar_equipment_subpage.IncomingEquip.typ);
			self:LOG("self.CostSlotRocks:",self.CostSlotRocks);
			self.SlotCostJoybean = self.CostSlotRocks_Table[Avatar_equipment_subpage.IncomingEquip.typ].factor * (Avatar_equipment_subpage.IncomingEquip.holdSlots + 1) * Avatar_equipment_subpage.IncomingEquip.level;
		end

		--self.page:SetValue("progress",self.TesselateOdds or 0);
		self.page:SetValue("IncomingEquipGuid",Avatar_equipment_subpage.IncomingEquip.guid or -999);
		self.page:SetValue("tabsEquipments",tostring(Avatar_equipment_subpage.filter));
		self.page:SetValue("tabsLevelGems",tostring(Avatar_gems_subpage.filter));
	end
end

function Avatar_gems_tesselate:GetItemUnits(id)
	local has,_,__,copies = hasGSItem(id)
	if(has)then
		return copies or 0;
	end
	return 0;
end

function Avatar_gems_tesselate.ShowPage(gsid)
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
	local self = Avatar_gems_tesselate;
	
	Avatar_gems_subpage:BindParent("GemTessel",self);
	Avatar_equipment_subpage:BindParent("GemTessel",self);
	--Avatar_tesselate_subpage:BindParent("GemTessel",self);

	Avatar_gems_subpage.GemsOdds = {100,90,80,70,60,};

	Avatar_gems_subpage.SlotOdds = {
	clothes_shoes = {[1] = 100,[2] = 90, [3] = 80,[4] = 70,[5] = 60,[6] = 50,},
	acces = {[1] = 100,[2] = 80, [3] = 60,},
	weapons = {[1] = 100,[2] = 90, [3] = 80,[4] = 70,[5] = 60,[6] = 50,}};

	local value = random(1,9);	
	self.timeLucky,self.starCount,self.timeLucky_cn = Player.GetTimeLucky();
	self.modValue = Avatar_gems_tesselate.modValueRange[value];

	local page_addr = "script/apps/Aries/NPCs/ShoppingZone/Avatar_gems_tesselate.html"
	local has_item;
	if(type(gsid) == "number") then
		page_addr = format("%s?gsid=%d", page_addr, gsid);
		has_item = true;
	end

	local width,height = 758,470;
	local params = {
		url = page_addr, 
		name = "Avatar_gems_tesselate.ShowPage", 
		app_key=MyCompany.Aries.app.app_key, 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		enable_esc_key = true,
		style = CommonCtrl.WindowFrame.ContainerStyle,
		allowDrag = true,
		directPosition = true,
		align = "_ct",
		x = -width * 0.5,
		y = -height * 0.5,
		width = width,
		height = height,}
	System.App.Commands.Call("File.MCMLWindowFrame", params);	
	if(params._page)then
		params._page.OnClose = self.Clean;
	end

	Avatar_equipment_subpage:SetAllowableGemsType();
	--Avatar_gems_subpage:GetAllItems();
	Avatar_gems_subpage:Update(function() Avatar_equipment_subpage:Update();end);			
	--Avatar_tesselate_subpage:Update();
end

function Avatar_gems_tesselate:SetTesse()
	self.page:SetValue("IncomingTesselGsid1",self.LUCKY_ITEM_ID );
end

--[[
	if not select any equip or gem or tesselate odds is unaviable,then donot show progress bar
--]]
function Avatar_gems_tesselate.ShowTesselOdds()
	local self = Avatar_gems_tesselate;
	if(self.TesselateOdds ~= nil and self.TesselateOdds > 0 and 
		Avatar_gems_subpage.IncomingGem.gsid ~= -999 and Avatar_equipment_subpage.IncomingEquip.guid ~= -999) then
		return true;
	else
		return false;
	end
end

--cancel incoming items
function Avatar_gems_tesselate:CancelItem(arg,param)
	if (param == "equip" and arg == Avatar_equipment_subpage.IncomingEquip.guid) then
		Avatar_equipment_subpage:ZeroIncomingEquip();
		if(Avatar_gems_subpage.IncomingGem.gsid ~= -999)then
			Avatar_gems_subpage:ZeroIncomingGem();
			Avatar_gems_tesselate.upgradeGem = nil
		end
		Avatar_gems_subpage.last_incominggem = nil;
		self.upgradeGemPos = nil;
		self.LuckyItemCnt = 0
		Avatar_gems_subpage:Update(function() Avatar_equipment_subpage:Update();end);			
	elseif (param == "gem")then
		if(arg ~= Avatar_gems_subpage.last_incominggem)then
			return
		elseif(arg == Avatar_gems_subpage.last_incominggem and arg == Avatar_gems_tesselate.upgradeGem) then
			local hold_gems = Avatar_equipment_subpage:GetIncomingEquipGems()
			self:LOG("hold_gems",hold_gems);
			for i,v in ipairs(hold_gems)do
				if(v.gsid == arg)then
					table.remove(hold_gems,i);
					break;
				end
			end
			self:LOG("hold_gems",hold_gems);
		end

		if(arg == Avatar_gems_tesselate.upgradeGem)then
			Avatar_gems_tesselate.upgradeGem = nil
		end
		Avatar_gems_subpage.last_incominggem = nil;
		self.upgradeGemPos = nil;
		self.LuckyItemCnt = 0
		Avatar_gems_subpage:ZeroIncomingGem();		
		Avatar_gems_subpage:Update(function() Avatar_equipment_subpage:Update();end);			
	end			
end

function Avatar_gems_tesselate.GetHoldSlotRocks()
	local _, __, ___, copies = hasGSItem(Avatar_gems_tesselate.SlotRockGsid)
	return copies or 0;
end

function Avatar_gems_tesselate.GetCostSlotRocks()
	if(Avatar_gems_tesselate.CostSlotRocks == 0)then
		return ""
	end
	return Avatar_gems_tesselate.CostSlotRocks
end

function Avatar_gems_tesselate:CalcOdds()
	if(Avatar_gems_subpage.ItemsOfSelf == nil) then return end
	local i,v,gemodd,slotodd,typ,slotIndex;

	--宝石成功概率
	for i,v in ipairs(Avatar_gems_subpage.ItemsOfSelf) do
		if(v.gsid== Avatar_gems_subpage.IncomingGem.gsid) then
			gemodd = v.odds;
			break;
		end	
	end

	if(Avatar_equipment_subpage.IncomingEquip.gemsCount < Avatar_equipment_subpage.IncomingEquip.holdSlots) then
		slotIndex = Avatar_equipment_subpage.IncomingEquip.gemsCount + 1;
	end

	--插槽成功概率
	if(slotIndex and slotIndex > 0) then
		slotodd = Avatar_gems_subpage.SlotOdds[Avatar_equipment_subpage.IncomingEquip.typ][slotIndex];
	end

	gemodd = gemodd or 0;
	gemodd = (gemodd * (slotodd or 1) / 100) + self.timeLucky + self.modValue;

	self.TesselateOdds= gemodd;
	self.TesselateOdds = if_else(self.TesselateOdds >= 100,100,self.TesselateOdds);
	Avatar_gems_tesselate.InitialOdds = self.TesselateOdds;
	if(Avatar_gems_tesselate.LuckyItemCnt > 0)then
	self.TesselateOdds = self.TesselateOdds + Avatar_gems_tesselate.LuckyItemCnt * Avatar_tesselate_subpage.TesselateRateCollection[1]
	end
	self:LOG("Avatar_gems_tesselate.InitialOdds:",Avatar_gems_tesselate.InitialOdds)
	self.TesselateOdds = if_else(self.TesselateOdds >= 100,100,self.TesselateOdds);
	self:LOG("self.TesselateOdds:",self.TesselateOdds)

end

function Avatar_gems_tesselate:Refresh(delta)
	local self = Avatar_gems_tesselate
	self.page:Refresh(delta or 0.1);
end


function Avatar_gems_tesselate.Clean()
	local self = Avatar_gems_tesselate
	--reset subpages
	Avatar_equipment_subpage:ResetStates(1);
	Avatar_gems_subpage:ResetStates(1);
	--Avatar_tesselate_subpage:ResetStates();
	Avatar_gems_subpage.last_incominggem = nil;
	self.upgradeGem = nil;
	self.TesselateOdds = 0;
	self.HoldLuckyItem = 1;
	self.InitialOdds = 0;
	self.LuckyItemCnt = 0;
	self.IncomingLuckyItems = {};
	self.upgradeGemPos = nil;
	self.timeLucky_cn = nil;
	self.SlotCostJoybean = 0;
end

function Avatar_gems_tesselate.GetLuckyItemGuid()
	local has,guid,bag,copies = hasGSItem(Avatar_gems_tesselate.LUCKY_ITEM_ID)
	if(has)then
		return guid;
	end
	return
end

function Avatar_gems_tesselate:CloseWindow()
	self.page:CloseWindow();
end

function Avatar_gems_tesselate:Check()
	if(Avatar_equipment_subpage:IsEmpty()) then
		return "你还没有可以镶嵌宝石的装备。";
	end

	if(Avatar_gems_subpage:IsEmpty()) then
		return "你还没有宝石。";
	end

	if(Avatar_equipment_subpage.IncomingEquip.guid == -999) then
		return  "你还没有选择一件装备。";
	end

	if(Avatar_equipment_subpage.IncomingEquip.totalSlots == 0) then
		return  "这件装备没有插槽哦。";
	end
	
	if(Avatar_equipment_subpage.IncomingEquip.holdSlots == 0  and Avatar_equipment_subpage.IncomingEquip.totalSlots > 0) then
		return  "这件装备插槽未起用，请先打孔！";
	end

	--more gem check
	--[[if(Avatar_equipment_subpage.IncomingEquip.gemsCount == Avatar_equipment_subpage.IncomingEquip.totalSlots) then
		return  "这件装备不能再镶嵌了。";
	end
	]]
	if(Avatar_gems_subpage.IncomingGem.guid == -999) then
		return  "你还没有选择一颗宝石。";
	end

	if(self.CostJoybean >  MyCompany.Aries.Player.GetMyJoybeanCount())then
		return "你的奇豆不足了。"
	end	
	--[[
	if(not self.CanTessel) then
		echo("该宝石不能镶嵌到这件装备上")
		--return  "该宝石不能镶嵌到这件装备上。"; 
	end
	
	local gemType = strsub(Avatar_gems_subpage.IncomingGem.name,4);
		if(not Avatar_gems_tesselate.upgradeGem)then
		local i,v

		for i,v in ipairs(Avatar_equipment_subpage.IncomingEquip.holdGems) do
			if(v and type(v) == "table") then
				if(strfind(v.name,gemType)) then
					return "这件装备已经镶嵌了同类型的宝石!";
				end
			end
		end
	end
]]
	return 
end

--[[
	mount gems to equipment
--]]
function Avatar_gems_tesselate.OnTesselate()
	local self = Avatar_gems_tesselate;
	NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
	local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
	if(not DealDefend.CanPass())then
		return
	end
	local err = self:Check();
	if(err)then
		MSG(err)
		return 
	end

	Avatar_gems_tesselate:LOG(Avatar_gems_subpage.IncomingGem.guid)
	Avatar_gems_tesselate:LOG(Avatar_equipment_subpage.IncomingEquip.guid)
	Avatar_gems_tesselate:LOG(self.IncomingLuckyItems)

	MountGemInSocket2(Avatar_gems_subpage.IncomingGem.guid,
		Avatar_equipment_subpage.IncomingEquip.guid,self.IncomingLuckyItems, nil, function(msg)
		if(msg) then
			if(msg.issuccess and msg.errorcode == 0) then
				Avatar_gems_subpage:ZeroIncomingGem();
				self.CostJoybean = 0
				
				Avatar_equipment_subpage:Update();
				Avatar_gems_tesselate.upgradeGemPos = nil;
				Avatar_gems_tesselate.upgradeGem = nil;
				Avatar_gems_subpage.last_incominggem = nil;
				self:Refresh();
				
				self.LuckyItemCnt = 0
				MSG("恭喜你，成功镶嵌了宝石！");
				MyCompany.Aries.event:DispatchEvent({type = "custom_goal_client"},79017);
			elseif(msg.errorcode == 493) then
				echo(msg)
				MSG("提供的某个参数不符合要求！");
			elseif(msg.errorcode == 433) then
				MSG("该装备已镶嵌过了，不能镶嵌更多的宝石了。");
			elseif(msg.errorcode == 417) then
				MSG("已经镶嵌了该类型的宝石。");
			elseif(msg.errorcode == 427) then
				MSG("你的货币不足以进行本次镶嵌。");
				echo(msg);
			elseif(msg.errorcode == 492) then
				MSG("很遗憾，没有成功镶嵌宝石。");
				echo(msg);
			else

				echo(msg);
				MSG("很遗憾，没有成功镶嵌宝石！" );				
			end
		end
	end);
end

function Avatar_gems_tesselate.OnSlotting(arg)
	local self = Avatar_gems_tesselate
	NPL.load("(gl)script/apps/Aries/DealDefend/DealDefend.lua");
	local DealDefend = commonlib.gettable("MyCompany.Aries.DealDefend.DealDefend");
	if(not DealDefend.CanPass())then
		return
	end
	if(self.CostSlotRocks > self.GetHoldSlotRocks()) then
		local nNeedCount = self.CostSlotRocks - self.GetHoldSlotRocks();
		_guihelper.MessageBox(format("你的打孔石不足了,还差%d个<br/>是否马上补充？", nNeedCount), function(result)
			if(result == _guihelper.DialogResult.Yes)then
				local command = System.App.Commands.GetCommand("Profile.Aries.PurchaseItemWnd");
				if(command) then
					command:Call({gsid = Avatar_gems_tesselate.SlotRockGsid});
				end
				
			end
		end, _guihelper.MessageBoxButtons.YesNo);
		return;
	end

    _guihelper.MessageBox( string.format([[你需要消耗%d颗<img style="width:48px;height:38px;margin-top:-10px;" class="CraftSlotCharm"/>打孔石和%s<img class="stable_bean" style="width:20px;height:20px;"/>奇豆。]],self.CostSlotRocks, self.SlotCostJoybean),function(res) 
		if(res and res == _guihelper.DialogResult.OK) then
			Avatar_gems_tesselate._OnSlotting();
		end
    end);
end

function Avatar_gems_tesselate._OnSlotting(arg)
	local self = Avatar_gems_tesselate
	if(Avatar_equipment_subpage and  Avatar_equipment_subpage.IncomingEquip.guid == 0) then
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

	if( self.SlotCostJoybean > MyCompany.Aries.Player.GetMyJoybeanCount()) then
		MSG("你的奇豆不足了。");
		return;
	end

	if(CreateGemHole and type(CreateGemHole) == "function") then
		CreateGemHole(Avatar_equipment_subpage.IncomingEquip.guid,function(msg)
		if(msg) then
			if(msg.issuccess) then
				self.SlotCostJoybean = 0;
				Avatar_equipment_subpage.IncomingEquip.holdSlots = Avatar_equipment_subpage.IncomingEquip.holdSlots + 1;
				self:Refresh();
			else
				MSG("很遗憾，没有成功打孔！");
				echo(msg);
			end
		end
		end,function(msg) end,function(msg) end);

	else
		echo("CreateGemHole is not a valid function!");
	end
end
--initial control states
function Avatar_gems_tesselate:ResetControlState()
	local i;
	for i = 1, SLOTS_COUNT do
		self.page:SetUIEnabled("btnEquipTessle" .. i,false);
	end

	self.VisibleFlag_Tessel = 0;
	
	for i = 1, SLOTS_COUNT do
		self.page:SetValue("IncomingGemGsid" .. i,-999);
	end
end

function Avatar_gems_tesselate:CompareEquipedGem(gsid)
	local self = Avatar_gems_tesselate	
	local hold_gems = Avatar_equipment_subpage:GetIncomingEquipGems()

	self:LOG("hold_gems>>>>>>>>>>",hold_gems)
	Avatar_gems_tesselate.upgradeGem = nil;
	self.upgradeGemPos = nil
	local res;	

	if(#hold_gems > 0)then
		local i,v
		local typ = strsub(Avatar_gems_subpage.IncomingGem.name,4);
		for i,v in ipairs(hold_gems)do
			if(v.gsid==gsid)then
				res = v.gsid;
				break;
			else
				if(typ and strfind(v.name,typ)) then
					if(Avatar_gems_subpage.IncomingGem.level < v.level)then
						res = -1;
						break;
					elseif(Avatar_gems_subpage.IncomingGem.level == (v.level + 1))then
						res = 1;
						break;
					elseif(Avatar_gems_subpage.IncomingGem.level > v.level)then
						res = 0;
						break;
					end
				end
			end
			if(i == #hold_gems)then res = "other"; end
		end
	else
		return "empty slots"; 
	end
	return res;
end

function Avatar_gems_tesselate:GetItemName(gsid)
	if(not self.ITEM_NAME)then
		local item  = GetItemByID(gsid)

		if(item and item.template)then
			self.ITEM_NAME = item.template.name or "unknown name";
		end
	end
	return self.ITEM_NAME
end

function Avatar_gems_tesselate.ExtraTesselOdds()
	local self = Avatar_gems_tesselate
	return Avatar_tesselate_subpage.TesselateRateCollection[1] * self.LuckyItemCnt
end

--for user adjust lucky value
function Avatar_gems_tesselate.SetLucky(name)
	local self = Avatar_gems_tesselate
	local luckyCnt = self:GetItemUnits(self.LUCKY_ITEM_ID)

	--check lucky item
	if(name == "inc" and not (luckyCnt > self.LuckyItemCnt))then
		if((not luckyCnt or luckyCnt == 0) and self.LuckyItemCnt == 0)then
			MSG(format("你还没有【%s】可以使用。",Avatar_gems_tesselate:GetItemName(Avatar_gems_tesselate.LUCKY_ITEM_ID)));
		else
			MSG(format("你没有更多的【%s】可以使用。",Avatar_gems_tesselate:GetItemName(Avatar_gems_tesselate.LUCKY_ITEM_ID)));
		end
		return
	end

	--check main items
	local err = self:Check();
	if(err)then
		MSG(err)
		return 
	end

	local old_odds = self.TesselateOdds; 

	if(name == "inc" and self.LuckyItemCnt < Avatar_gems_tesselate.MAX_USE_LUCKYS)then
		self.LuckyItemCnt = self.LuckyItemCnt + 1;
		if(self.TesselateOdds < 100)then
			self.TesselateOdds = self.TesselateOdds + Avatar_tesselate_subpage.TesselateRateCollection[1];
		end
	elseif(name == "dec" and self.TesselateOdds > self.InitialOdds)then
		self.LuckyItemCnt = self.LuckyItemCnt - 1;
		self.TesselateOdds = self.TesselateOdds - Avatar_tesselate_subpage.TesselateRateCollection[1]
	end

	if(old_odds  ~= self.TesselateOdds)then
		if(self.LuckyItemCnt > 0)then
			self.IncomingLuckyItems[self.GetLuckyItemGuid()] = self.LuckyItemCnt;
		end
		self:Refresh();
	end
end