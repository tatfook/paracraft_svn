--[[
Title: Desktop Health Point display for current player area
Author(s): Leio
Date: 2010/06/29
See Also: script/apps/Aries/Desktop/AriesDesktop.lua
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/HPMyPlayerArea.lua");
local HPMyPlayerArea = commonlib.gettable("MyCompany.Aries.Desktop.HPMyPlayerArea");
MyCompany.Aries.Desktop.HPMyPlayerArea.Init();
MyCompany.Aries.Desktop.HPMyPlayerArea.SetValue(100,500);
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Team/TeamClientLogics.lua");
NPL.load("(gl)script/apps/Aries/Player/main.lua");
local Player = commonlib.gettable("MyCompany.Aries.Player");
local TeamClientLogics = commonlib.gettable("MyCompany.Aries.Team.TeamClientLogics");

-- create class
local HPMyPlayerArea = commonlib.createtable("MyCompany.Aries.Desktop.HPMyPlayerArea", {
	cur_value = 0,
	max_value = 0,	
	max_index = 10,
});

HPMyPlayerArea.name = "HPBottleArea_instance";

local page;

-- invoked at Desktop.InitDesktop()
function HPMyPlayerArea.Init()
	-- load implementation
	HPMyPlayerArea.Create();
end

-- virtual function: create the area UI
function HPMyPlayerArea.Create()
	local self = HPMyPlayerArea;
	local _parent = ParaUI.CreateUIObject("container", self.name.."HPMyPlayerArea", "_lt", 0, 0, 256, 140);
	_parent.background = "";
	_parent:SetField("ClickThrough", true);
	_parent:AttachToRoot();
	
	page = page or Map3DSystem.mcml.PageCtrl:new({
			url=if_else(System.options.version=="kids", "script/apps/Aries/Desktop/MyPlayerArea/MyPlayerArea.kids.html", "script/apps/Aries/Desktop/MyPlayerArea/MyPlayerArea.teen.html"),
			click_through = true,
			SelfPaint = System.options.IsMobilePlatform,
		});

	-- one can create a UI instance like this. 
	page:Create("Aries_MyPlayerArea_mcml", _parent, "_fi", 0, 0, 0, 0);
end

-- virtual function: refresh UI
function HPMyPlayerArea.UpdateUI(bForceRefresh)
	if(page) then
		if(bForceRefresh) then
			page:Refresh();
		else
			local self = HPMyPlayerArea;
			HPMyPlayerArea.UpdateUIByPage(page, self.cur_value, self.max_value, true);
		end
	end
end

-- update name when it is changed
function HPMyPlayerArea.UpdateUIByName()
	if(page) then
		local name_node = page:GetNode("name");
		if(name_node) then
			name_node:SetAttribute("value", nil);
			page:Refresh();
		end
	end
end

-- update UI for current health / max health
-- This function may be called by multiple different pages with same layout
-- @param cur_value: current health
-- @param max_value: max or total health
function HPMyPlayerArea.UpdateUIByPage(page, cur_value, max_value, is_self)
	if(page) then
		cur_value = cur_value or 0;
		max_value = max_value or 100;
		
		cur_value = math.min(cur_value,max_value);
		page:SetValue("health_text", string.format("%d/%d",cur_value,max_value));
		local max_healthbar_value = 100;
		page:SetValue("healthbar", math.min(math.floor(cur_value/max_value*max_healthbar_value)+1, max_healthbar_value));

		if(is_self) then
			local current_stamina, max_stamina = Player.GetStamina();
			page:SetValue("stamina_text", string.format("%d/%d",current_stamina,max_stamina));
			local stamina_percent = math.min(math.floor(current_stamina/max_stamina*max_healthbar_value)+1, max_healthbar_value)
			if(current_stamina == 0) then
				stamina_percent = 0;
			end
			page:SetValue("stamina_bar", stamina_percent);
			local ctl = page:FindControl("stamina_refill");
			if(ctl) then
				ctl.visible = stamina_percent < 80;
			end
			page:SetValue("levelBtn", tostring(MyCompany.Aries.Player.GetLevel()));
		end
	end
end

-- public function: Set the UI mode of the HP area, so that it has different display for different mode.
-- @param mode: "combat", "normal", "home"
function HPMyPlayerArea.SetMode(mode)
	HPMyPlayerArea.mode = mode;
	local _hpBottleArea = ParaUI.GetUIObject(HPMyPlayerArea.name.."HPMyPlayerArea");
	if(_hpBottleArea:IsValid())then
		if(mode == "combat") then
			_hpBottleArea.visible = false;
		else
			_hpBottleArea.visible = true;
		end
	end
end

-- public function: show or hide the map area, toggle the visibility if bShow is nil
function HPMyPlayerArea.Show(bShow)
	if(HPMyPlayerArea.mode == "tutorial") then
		if(not bShow) then
			return; -- in tutorial mode, ignore any hide command from Desktop.HideAllAreas()
		end
	end
	local self = HPMyPlayerArea;
	local _hpBottleArea = ParaUI.GetUIObject(self.name.."HPMyPlayerArea");
	if(_hpBottleArea:IsValid() == true) then
		if(bShow == nil) then
			bShow = not _hpBottleArea.visible;
		end
		if(HPMyPlayerArea.mode == "combat") then
			bShow = false;
		end
		_hpBottleArea.visible = bShow;
	end
end

-- virtual function: 
function HPMyPlayerArea.OnActivateDesktop()
	HPMyPlayerArea.UpdateUI(true);
end

-- public function: Set player's health point for display
function HPMyPlayerArea.SetValue(cur_value,max_value)
	local self = HPMyPlayerArea;
	if(not cur_value or not max_value)then return end
	local bChanged;
	if(self.cur_value ~= cur_value)  then
		self.cur_value = cur_value;
		bChanged = true;
	end
	if(self.max_value ~= max_value) then
		self.max_value = max_value;
		bChanged = true;
	end
	self.UpdateUI();

	-- once changed, postpone for 5 seconds and broadcast the message to all users. 
	if(bChanged) then
		TeamClientLogics:BroadcastMyHPInfo(true);
	end
end

-- public function: Get player's health point 
function HPMyPlayerArea.GetHP()
	local cur_value = HPMyPlayerArea.cur_value or 0;
	local max_value = HPMyPlayerArea.max_value or 100;
	return cur_value,max_value;
end

--[[
NPL.load("(gl)script/apps/Aries/Desktop/HPMyPlayerArea.lua");
local HPMyPlayerArea = commonlib.gettable("MyCompany.Aries.Desktop.HPMyPlayerArea");
HPMyPlayerArea.ShowHpPotionPage();
--]]
function HPMyPlayerArea.ShowHpPotionPage()
	local is_combat = Player.IsInCombat();
	if(is_combat)then
		_guihelper.MessageBox("战斗中不能吃红枣！");
		return;
	end
	System.App.Commands.Call("File.MCMLWindowFrame", {
				url = "script/apps/Aries/Desktop/MyPlayerArea/HpPotionPage.html", 
				name = "HPMyPlayerArea.ShowHpPotionPage", 
				app_key=MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				enable_esc_key = true,
				style = CommonCtrl.WindowFrame.ContainerStyle,
				allowDrag = false,
				directPosition = true,
					align = "_ct",
					x = -500/2,
					y = -260/2,
					width = 500,
					height = 260,
		});		
	HPMyPlayerArea.LoadItems();
end
function HPMyPlayerArea.LoadItems()
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	local equipGSItem = ItemManager.IfEquipGSItem;

	local self = HPMyPlayerArea;
	local searched_map = {
		[17155] = true,
		[17156] = true,
		[17157] = true,
		[17158] = true,
		[17159] = true,
	}
	self.hp_potion_list = {};
	local bag = 12;
	ItemManager.GetItemsInBag( bag, "ariesitems_" .. bag, function(msg)
				local i;
				local cnt = ItemManager.GetItemCountInBag(bag);
				for i = 1, cnt do
					local item = ItemManager.GetItemByBagAndOrder(bag, i);
					if(item)then
						local gsid = item.gsid;
						local guid = item.guid;
						if(searched_map[gsid])then
							table.insert(self.hp_potion_list,{guid = guid,gsid = gsid,});
						end
					end
				end
				local count = #self.hp_potion_list;
				local pagesize = 15;
				local displaycount = math.ceil(count / pagesize) * pagesize;

				if(count == 0 )then
					displaycount = pagesize;
				end

				local i;
				for i = count + 1, displaycount do
					self.hp_potion_list[i] = { guid = 0, gsid = 100000000,};
				end
				table.sort(self.hp_potion_list,function(a,b)
					return a.gsid < b.gsid;
				end);
				if(self.hp_potion_page)then
					self.hp_potion_page:Refresh(0);
				end
		end, "access plus 5 minutes");
end

function HPMyPlayerArea.DS_Func(index)
	local self = HPMyPlayerArea;
	if(not self.hp_potion_list)then return 0 end
	if(index == nil) then
		return #(self.hp_potion_list);
	else
		return self.hp_potion_list[index];
	end	
end

function HPMyPlayerArea.OnInit_HpPotionPage()
	local self = HPMyPlayerArea;
	self.hp_potion_page = document:GetPageCtrl();	
end
