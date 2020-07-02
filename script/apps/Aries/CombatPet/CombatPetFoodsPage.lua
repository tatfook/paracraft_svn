--[[
Title: CombatPetFoodsPage
Author(s): Leio 
Date: 2011/02/28
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetFoodsPage.lua");
local CombatPetFoodsPage = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetFoodsPage");
CombatPetFoodsPage.ShowPage()

NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetFoodsPage.lua");
local CombatPetFoodsPage = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetFoodsPage");
commonlib.echo(CombatPetFoodsPage.items)
local msg = {
	state = 1,
}
CombatPetFoodsPage.DoFeed_Handler(msg)
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/apps/Aries/Desktop/Dock/DockTip.lua");
local DockTip = commonlib.gettable("MyCompany.Aries.Desktop.DockTip");
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetPage.lua");
local CombatPetPage = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetPage");
NPL.load("(gl)script/apps/Aries/HaqiShop/HaqiShop.lua");
local Dock = commonlib.gettable("MyCompany.Aries.Desktop.Dock");

-- create class
local CombatPetFoodsPage = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetFoodsPage");
CombatPetFoodsPage.bags = {12};
CombatPetFoodsPage.pet_gsid = nil;
function CombatPetFoodsPage.OnInit()
	local self = CombatPetFoodsPage; 
	self.page = document:GetPageCtrl();
end
function CombatPetFoodsPage.ClosePage()
	local self = CombatPetFoodsPage; 
	if(self.page)then
		self.page:CloseWindow();
	end
end
function CombatPetFoodsPage.DoRefresh(time)
	local self = CombatPetFoodsPage; 
	if(self.page)then
		self.page:Refresh(time or 0.2);
	end
end
function CombatPetFoodsPage.DS_Func_panel(index)
	local self = CombatPetFoodsPage;

	if(not self.items)then return 0 end
	local len = self.items;
	if(len == 0)then return 0 end
	if(index == nil) then
		return #(self.items);
	else
		return self.items[index];
	end
end
function CombatPetFoodsPage.LoadBags(callbackFunc)
	local self = CombatPetFoodsPage;
	local bags = self.bags;
	self.items = nil;
	self.GetItemsFromBags(bags,function(msg)
		if(msg)then
			if(not msg.isEmpty)then
				table.sort(msg.output,function(a,b)
					if(a.prority and b.prority)then
						return a.prority > b.prority;
					end
				end);
				self.items = msg.output;
			end
			self.DoRefresh();
			if(callbackFunc)then
				callbackFunc();
			end
		end
	end)
end
function CombatPetFoodsPage.ShowPage(pet_gsid)
	local self = CombatPetFoodsPage; 
	if(not pet_gsid)then return end
	self.pet_gsid = pet_gsid;
	
	self.LoadBags(function()
		--if(not self.items)then
			--local s = "你很懒哦，一个果实都没有，快去家园多种植点吧！或者可以先买点战宠口粮，让战宠快快长大呢！";
			--_guihelper.Custom_MessageBox(s,function(result)
			--end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
			--return
		--end
		local url;
		local control_dock = false;
		if(System.options.version == "kids") then
			url = "script/apps/Aries/CombatPet/CombatPetFoodsPage.html";
		else
			url = "script/apps/Aries/CombatPet/CombatPetFoodsPage.teen.html";
			control_dock = true;
		end
		System.App.Commands.Call("File.MCMLWindowFrame", params);
		local params = {
			url = url, 
			name = "CombatPetFoodsPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			allowDrag = true,
			isTopLevel = true,
			enable_esc_key = true,
			directPosition = true,
				align = "_ct",
				x = -540/2,
				y = -500/2,
				width = 540,
				height = 440,
		}
		System.App.Commands.Call("File.MCMLWindowFrame", params);		
		if(control_dock)then
			if(params._page) then
				params._page.OnClose = function(bDestroy)
					Dock.OnClose("CombatPetFoodsPage.ShowPage")
				end
			end
		end
	end);
end
function CombatPetFoodsPage.CanPush(gsid)
	local self = CombatPetFoodsPage;
	if(not gsid)then return end
	local HomeLandGateway = commonlib.gettable("Map3DSystem.App.HomeLand.HomeLandGateway");
	local fruits = HomeLandGateway.all_fruits_list;
	if(gsid == 17172 or gsid == 17185 or gsid == 17211)then
		return true;
	end
	if(gsid == 17045)then
		return false;
	end
	local k,v;
	for k,v in ipairs(fruits) do
		if(v == gsid)then
			return true;
		end
	end
end
function CombatPetFoodsPage.GetItemsFromBags(bags,callbackFunc,cachepolicy)
	local self = CombatPetFoodsPage; 
	if(not bags)then return end
	local output = {};
	cachepolicy = cachepolicy or "access plus 0 minutes";
	local index = 0;
	local isEmpty = true;
	function getbag(callbackFunc,cachepolicy)
		index = index + 1;
		local bag = bags[index];
		if(not bag)then
			if(callbackFunc and type(callbackFunc) == "function")then
				local count = #output;
				local pagesize = 14;
				-- fill the 10 tiles per page
				local displaycount = math.ceil(count/pagesize) * pagesize;
				if(count == 0) then
					displaycount = pagesize;
				end
				local i;
				for i = count + 1, displaycount do
					output[i] = {guid = 0};
				end
				callbackFunc(
					{output = output,isEmpty = isEmpty, prority = 0,}
				);
				return
			end
		end
		local ItemManager = System.Item.ItemManager;
		ItemManager.GetItemsInBag(bag, "ariesitems", function(msg)
			if(msg and msg.items) then
				local count = ItemManager.GetItemCountInBag(bag);
				local i;
				for i = 1, count do
					local item = ItemManager.GetItemByBagAndOrder(bag, i);
					if(item ~= nil) then
						--过滤
						local canpush = self.CanPush(item.gsid);
						if(canpush)then
							isEmpty = false;
							local prority = 1;
							if(item.gsid == 17172 or item.gsid == 17185 or item.gsid == 17211)then
								prority = 2;
							end
							table.insert(output,{guid = item.guid,gsid = item.gsid, prority = prority});
						end
					end
				end
				getbag(callbackFunc,cachepolicy);
			end
		end, cachepolicy);
	end
	getbag(callbackFunc,cachepolicy)
end
--[[
local state:
	1 用户点击 某一个物品后，当天可喂养次数为0，是则弹出系统提示
	2 喂养错了物品，消耗物品和喂养次数不增加任何经验时候
	3 喂养物品正确（非口粮），喂养后战宠未满级
	4 喂养口粮后，战宠未满级
	5 喂养后战宠满级
--]]
function CombatPetFoodsPage.DoFeed_Handler(msg)
	local self = CombatPetFoodsPage;
	if(not msg or not msg.state)then return end
	local state = msg.state;
	local pet_gsid = msg.pet_gsid;
	local food_gsid = msg.food_gsid;
	local fruit_name = "";
	local pet_name = "";
	local ItemManager = System.Item.ItemManager;

	local bHas,guid = ItemManager.IfOwnGSItem(pet_gsid)
	if(bHas)then
		local item = ItemManager.GetItemByGUID(guid);
		if(item and item.GetName_client)then
			pet_name = item:GetName_client();
		end
	end
	local function refreshCombatPetPage()
		local selected_pet_index = CombatPetPage.selected_pet_index;
		CombatPetPage.DoRadio(1,selected_pet_index);

	end
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(food_gsid);
	if(gsItem)then
		fruit_name = gsItem.template.name;
	end
	self.DoRefresh(0.5);
	if(state == 1)then
		local s = [[今天你已经喂了这只战宠15次了，不能再喂养了，明天再来吧！喂养次数有限，喂战宠口粮最保险哦！]];
		_guihelper.Custom_MessageBox(s,function(result)
			if(result == _guihelper.DialogResult.Yes)then
				self.ClosePage();
				MyCompany.Aries.HaqiShop.ShowMainWnd("tabTool","5003")
			else
				self.ClosePage();
			end
		end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/got_combatpet_food_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/Later_32bits.png; 0 0 153 49"});
	elseif(state == 2)then
		self.LoadBags();
		refreshCombatPetPage();
		local s = string.format([[唉呀， 今天%s不对%s的胃口，战斗经验没有增加，再喂其他的试试看吧！喂养次数有限，喂战宠口粮最保险哦！]],fruit_name,pet_name);
		_guihelper.Custom_MessageBox(s,function(result)
			if(result == _guihelper.DialogResult.Yes)then
				self.ClosePage();
				MyCompany.Aries.HaqiShop.ShowMainWnd("tabTool","5003")
			end
		end,_guihelper.MessageBoxButtons.YesNo,{yes = "Texture/Aries/Common/got_combatpet_food_32bits.png; 0 0 153 49", no = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
	elseif(state == 3)then
		self.LoadBags();
		refreshCombatPetPage();
		local s = string.format([[%s今天很喜欢吃%s，增加了30点战斗经验，喂战宠口粮每次可以增加150点经验呢！]],pet_name,fruit_name);
		_guihelper.Custom_MessageBox(s,function(result)
			if(result == _guihelper.DialogResult.OK)then
			end
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
	elseif(state == 4)then
		self.LoadBags();
		refreshCombatPetPage();
		local s = string.format([[ 哇，%s一口吞下战宠口粮，战斗经验立刻暴增300点!]],pet_name);
		_guihelper.Custom_MessageBox(s,function(result)
			if(result == _guihelper.DialogResult.OK)then
			end
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
	elseif(state == 14)then
		self.LoadBags();
		refreshCombatPetPage();
		local s;
		if(CommonClientService.IsKidsVersion())then
			s = string.format([[ 哇，%s一口吞下高级战宠口粮，战斗经验立刻暴增1200点!]],pet_name);
		else
			s = string.format([[ 哇，%s一口吞下高级战宠口粮，战斗经验立刻暴增900点!]],pet_name);
		end
		_guihelper.Custom_MessageBox(s,function(result)
			if(result == _guihelper.DialogResult.OK)then
			end
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
	elseif(state == 15)then
		self.LoadBags();
		refreshCombatPetPage();
		local s = string.format([[ 哇，%s一口吞下超级战宠口粮，战斗经验立刻暴增2400点!]],pet_name);
		_guihelper.Custom_MessageBox(s,function(result)
			if(result == _guihelper.DialogResult.OK)then
			end
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
	elseif(state == 5)then
		refreshCombatPetPage();
		local s = string.format([[太棒了，%s已经长到满级啦！]],pet_name);
		_guihelper.Custom_MessageBox(s,function(result)
			if(result == _guihelper.DialogResult.OK)then
				self.ClosePage();
			end
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
	end
end
function CombatPetFoodsPage.CheckDate_FollowPet_Handler(msg)
	local self = CombatPetFoodsPage;
	if(not msg)then return end
	local pet_gsid = msg.pet_gsid;
	LOG.std("","info","CombatPetFoodsPage.CheckDate_FollowPet_Handler", msg);
	local function refreshCombatPetPage()
		local selected_pet_index = CombatPetPage.selected_pet_index;
		CombatPetPage.DoRadio(1,nil,selected_pet_index);
	end
	self.DoRefresh();
	refreshCombatPetPage();
end