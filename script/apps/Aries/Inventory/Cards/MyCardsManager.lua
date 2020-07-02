--[[
Title: 
Author(s): Leio	
Date: 2010/07/02
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Inventory/Cards/MyCardsManager.lua");
MyCompany.Aries.Inventory.Cards.MyCardsManager.GetRemoteCombatBag()

NPL.load("(gl)script/apps/Aries/Inventory/Cards/MyCardsManager.lua");
local gsid = 22003;
local state = MyCompany.Aries.Inventory.Cards.MyCardsManager.GetPropByTemplateGsid(gsid);
commonlib.echo(state);
MyCompany.Aries.Inventory.Cards.MyCardsManager.SetPageState(state);


强制显示背包: NPL.load("(gl)script/apps/Aries/app_main.lua"); 714行
强制显示卡片分类：NPL.load("(gl)script/apps/Aries/NPCs/MagicSchool/CombatSkillLearn.lua"); 263行
-------------------------------------------------------
]]

local MyCardsManager = commonlib.gettable("MyCompany.Aries.Inventory.Cards.MyCardsManager")

MyCardsManager.filename = "config/aries/cardstemplate.xml";
MyCardsManager.CardsViewPageCtrl = nil;
--战斗背包
MyCardsManager.combat_bags = MyCardsManager.combat_bags or {}
MyCardsManager.MyCardsBagPageCtrl = nil;
MyCardsManager.maxNum = 30;
MyCardsManager.canEquipNum = 8;
MyCardsManager.equipNum = 0;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
function MyCardsManager.GetPropByTemplateGsid(templategsid)
	local self = MyCardsManager;
	if(not templategsid)then return "1" end
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(templategsid)
	if(gsItem)then
		local assetkey = gsItem.assetkey or "";
		assetkey = string.lower(assetkey);
		local prop = string.match(assetkey,".+_(.+)$") or "";
		--metal wood water fire earth
		if(prop == "metal")then
			return "2";
		elseif(prop == "wood")then
			return "3";
		elseif(prop == "water")then
			return "4";
		elseif(prop == "fire")then
			return "5";
		elseif(prop == "earth")then
			return "6";
		else
			return "1";
		end
	end
	return "1";
end
--打开指定的技能分类
function MyCardsManager.SetPageState(state)
	local self = MyCardsManager;
	state = tostring(state);
	if(not state)then return end
	local MyCardsPage = commonlib.gettable("MyCompany.Aries.Inventory.MyCardsPage");
	if(self.MyCardsPageCtrl and MyCardsPage)then
		MyCardsPage.TabValue = state;
		self.MyCardsPageCtrl:Refresh(0.01);
	end
end
function MyCardsManager.Set_MyCardsPageCtrl(page)
	local self = MyCardsManager;
	self.MyCardsPageCtrl = page;
end
function MyCardsManager.Set_CardsViewPageCtrl(page)
	local self = MyCardsManager;
	self.CardsViewPageCtrl = page;
end
function MyCardsManager.Set_MyCardsBagPageCtrl(page)
	local self = MyCardsManager;
	self.MyCardsBagPageCtrl = page;
end
--clientdata is a table
function MyCardsManager.Bag_RemoteSave(callbackFunc)
	local self = MyCardsManager;
	if(not self.combat_bags)then return end
	local gsid = 995;
	local bagFamily = 1002;
	commonlib.echo("=========before save 995_CombatBagDesc");
	commonlib.echo(self.combat_bags);
	ItemManager.GetItemsInBag(bagFamily, "GetChristmasSocksTag", function(msg)
		local hasGSItem = ItemManager.IfOwnGSItem;
		local hasItem,guid = hasGSItem(gsid)
		if(hasItem)then
			local item = ItemManager.GetItemByGUID(guid);
			if(item)then
				--序列化
				local bags = {};
				local k,v;
				for k,v in ipairs(self.combat_bags) do
					if(v.gsid and v.gsid ~= 0)then
						--转换key
						table.insert(bags,v.gsid);
					end
				end
				local clientdata = commonlib.serialize_compact2(bags);
					commonlib.echo("============after save 995_CombatBagDesc1");
					commonlib.echo(clientdata);
				ItemManager.SetClientData(guid,clientdata,function(msg_setclientdata)
					commonlib.echo("============after save 995_CombatBagDesc2");
					commonlib.echo(msg_setclientdata);
					if(callbackFunc and type(callbackFunc) == "function")then
						callbackFunc({
								
						});
					end
				end);
			end
		end
	end, "access plus 0 minutes");
end
function MyCardsManager.Bag_RemoteLoad(callbackFunc)
	local self = MyCardsManager;
	local gsid = 995;
	local bagFamily = 1002;
	ItemManager.GetItemsInBag(bagFamily, "995_CombatBagDesc", function(msg)
			local hasGSItem = ItemManager.IfOwnGSItem;
			local hasItem,guid = hasGSItem(gsid);
			if(hasItem)then
				local item = ItemManager.GetItemByGUID(guid);
				if(item)then
					local clientdata = item.clientdata;
					commonlib.echo(clientdata);
					if(clientdata == "")then
						clientdata = "{}"
					end
					commonlib.echo("==========before commonlib.LoadTableFromString(clientdata) in 995_CombatBagDesc");
					clientdata = commonlib.LoadTableFromString(clientdata);
					commonlib.echo("==========after commonlib.LoadTableFromString(clientdata) in 995_CombatBagDesc");
					commonlib.echo(clientdata);

					if(clientdata and type(clientdata) == "table")then
						local bags = {};
						local k;
						for k = 1,self.maxNum do
							bags[k] = {gsid = 0};
						end
						local k,v;
						for k,v in ipairs(clientdata) do
							v = tonumber(v);
							if(v)then
								--转换key
								bags[k] = {gsid = v};
								--table.insert(bags,{ gsid = v });
							end
						end
						self.combat_bags = bags;
						if(callbackFunc and type(callbackFunc) == "function")then
							callbackFunc({
							});
						end
					end
					
				end
			end
		end, "access plus 0 minutes");
end
function MyCardsManager.Bag_Clip()
	local self = MyCardsManager;
	if(not self.combat_bags)then return end
	local k,len = 1,self.maxNum;
	local count = 0;
	for k = 1,len do
		local node = self.combat_bags[k];
		if(not node)then
			self.combat_bags[k] = {gsid = 0};
		elseif(node.gsid ~= 0)then
			count = count + 1;
		end
	end
	self.equipNum = count;
end
--放入战斗背包列表
--script/apps/Aries/Inventory/Cards/MyCardsBagPage.html
function MyCardsManager.Bag_DS_Func_Items(index)
	local self = MyCardsManager;
	if(not self.combat_bags)then return 0 end
	if(index == nil) then
		return #(self.combat_bags);
	else
		return self.combat_bags[index];
	end
end

function MyCardsManager.CombatBagIsNull()
	local self = MyCardsManager;
	if(not self.combat_bags)then
		return true;
	end
	local k,v;
	for k,v in ipairs(self.combat_bags) do
		if(v.gsid and v.gsid ~= 0)then
			return false;
		end
	end
	return true;
end
--是否已经在战斗背包
--返回include:是否包含,count：已经携带的数量
function MyCardsManager.InCombatBag(gsid)
	local self = MyCardsManager;
	if(not gsid or not self.combat_bags)then return end	
	local k,v;
	local include = false;
	local count = 0;
	for k,v in ipairs(self.combat_bags) do
		if(v.gsid == gsid)then
			include = true;
		end
		if(v.gsid and v.gsid ~= 0)then
			count = count + 1;
		end
	end
	return include,count;
end
--添加到战斗背包
function MyCardsManager.AppendToCombatBag(gsid,callbackFunc)
	local self = MyCardsManager;
	if(not gsid)then return end	
	local include,count = self.InCombatBag(gsid);
	--如果已经包含 或者 超出最大数量
	if(include or count >= self.maxNum)then
		return
	end
	commonlib.echo("=========append");
	commonlib.echo(gsid);
	--commonlib.insertArrayItem(self.combat_bags, 1, {gsid = gsid})
	--table.insert(self.combat_bags,{gsid = gsid});
	local k,v;
	for k,v in ipairs(self.combat_bags) do
		if(v.gsid == 0)then
			v.gsid = gsid;
			break;
		end
	end
	commonlib.echo(self.combat_bags);
	self.Bag_Clip();
	--保存
	MyCardsManager.Bag_RemoteSave(function()
		self.RefreshPage();
	end)
end
--从战斗背包移除
function MyCardsManager.RemoveFromCombatBag(gsid,callbackFunc)
	local self = MyCardsManager;
	if(not gsid)then return end	
	local k,v;
	commonlib.echo("=========remove");
	commonlib.echo(gsid);
	commonlib.echo(self.combat_bags);
	for k,v in ipairs(self.combat_bags) do
		if(v.gsid == gsid)then
			--commonlib.removeArrayItem(self.combat_bags,k);
			table.remove(self.combat_bags,k);
			break;
		end
	end
	commonlib.echo(self.combat_bags);
	self.Bag_Clip();
	commonlib.echo(self.combat_bags);
	--保存
	MyCardsManager.Bag_RemoteSave(function()
		self.RefreshPage();
	end)
end
function MyCardsManager.RefreshPage()
	local self = MyCardsManager;
	if(self.CardsViewPageCtrl)then
		self.CardsViewPageCtrl:Refresh(0.01);
	end
	if(self.MyCardsBagPageCtrl)then
		self.MyCardsBagPageCtrl:Refresh(0.01);
	end
end
--是否超过最大携带量
function MyCardsManager.CanEquip()
	local self = MyCardsManager;
	if(self.equipNum >= self.canEquipNum)then
		return false;
	end
	return true;
end
--携带
function MyCardsManager.DoAppend(gsid)
	local self = MyCardsManager;
	self.AppendToCombatBag(gsid,callbackFunc);
end
--取消携带
function MyCardsManager.DoRemove(gsid)
	local self = MyCardsManager;
	self.RemoveFromCombatBag(gsid,callbackFunc);
end
--是否拥有卡片获得的权利
function MyCardsManager.HasCardTemplagte(templategsid)
	local self = MyCardsManager;
	if(templategsid)then
		return hasGSItem(templategsid);
	end
	local bag = 24;
	for i = 1, ItemManager.GetItemCountInBag(bag) do
		local item = ItemManager.GetItemByBagAndOrder(bag, i);
		if(item ~= nil) then
			local gsid = item.gsid;
			--排除 经验石
			if(gsid and gsid ~= 22000)then
				local bHas = hasGSItem(gsid);
				if(bHas)then
					return true;
				end
			end
		end
	end
end
function MyCardsManager.GetLocalCombatBag()
	local self = MyCardsManager;
	return self.combat_bags;
end
function MyCardsManager.GetRemoteCombatBag(callbackFunc)
	local self = MyCardsManager;
	self.Bag_RemoteLoad(function()
		self.Bag_Clip();
		if(callbackFunc)then
			callbackFunc();
		end
	end);
end
function MyCardsManager.OnOpen()
	local self = MyCardsManager;
	if(self.isOpened)then return end
	self.isOpened = true;
	self.GetRemoteCombatBag(function()
	end);
end
function MyCardsManager.OnClose()
	local self = MyCardsManager;
	self.isOpened = false;
end
--获取自己背包的数量
function MyCardsManager.GetCanEquipNum()
	local self = MyCardsManager;
	return self.canEquipNum;
end