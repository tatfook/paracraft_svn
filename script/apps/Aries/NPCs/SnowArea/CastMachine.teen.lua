--[[
Title: code behind for make machine
Author(s): WD
Date: 2011/11/08
--EXP_CALC = SPEC_LVL / (2 * SPEC_LVL - TARGET_REQUIRED_LVL) - (SPEC_LVL - TARGET_REQUIRED_LVL) * EXP_CALC_FACTOR
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/SnowArea/CastMachine.teen.lua");
local CastMachine = commonlib.gettable("MyCompany.Aries.NPCs.SnowArea.CastMachine");
CastMachine.ShowPage();
------------------------------------------------------------
--]]

local ItemManager = Map3DSystem.Item.ItemManager;
local GetItemByID = ItemManager.GetGlobalStoreItemInMemory;
local GetItemsCount = ItemManager.GetItemCountInBag;
local GetItemsInBag = ItemManager.GetItemsInBag;
local hasGSItem = ItemManager.IfOwnGSItem;
local ExtendedCost = ItemManager.ExtendedCost;
local MSG = _guihelper.MessageBox;
local echo = commonlib.echo;
local GetExtTemp = ItemManager.GetExtendedCostTemplateInMemory;
local table_sort = table.sort;

NPL.load("(gl)script/ide/timer.lua");
NPL.load("(gl)script/apps/Aries/ServerObjects/Gatherer/GathererBarPage.lua");
local GathererBarPage = commonlib.gettable("MyCompany.Aries.ServerObjects.GathererBarPage");
NPL.load("(gl)script/apps/Aries/NPCs/SnowArea/MakeItem_subpage.teen.lua");
--NPL.load("(gl)script/apps/Aries/NPCs/SnowArea/CastMachine_subpage.teen.lua");
--local CastMachine_subpage = commonlib.gettable("MyCompany.Aries.NPCs.SnowArea.CastMachine_subpage");
local CastMachine = commonlib.gettable("MyCompany.Aries.NPCs.SnowArea.CastMachine");

CastMachine.MaxMakingCount = 1000;
CastMachine._DEBUG = CastMachine._DEBUG or 0;
function CastMachine:LOG(caption,obj)
	if(self._DEBUG)then
		echo(caption);
		echo(obj);
	end
end

NPL.load("(gl)script/apps/Aries/NPCs/SnowArea/LearnedSkill_subpage.teen.lua");
local LearnedSkill_subpage = commonlib.gettable("MyCompany.Aries.NPCs.SnowArea.LearnedSkill_subpage");
local MakeItem_subpage = commonlib.gettable("MyCompany.Aries.NPCs.SnowArea.MakeItem_subpage");
local function IsMaking()
	return MakeItem_subpage.Making;
end
CastMachine.LETHE_MASTER_ID = 31011
CastMachine.VIEW_SPEC = 0;
CastMachine.LEARN_NEW_SKILL = 2;
CastMachine.MAKE_ITEM = 4;
CastMachine.OpMode = CastMachine.OpMode or CastMachine.LEARN_NEW_SKILL
CastMachine.Spec_Skill_name = "";
CastMachine.cur_spec_exp = 0
CastMachine.TOTAL_SEPC_EXP = 300
CastMachine.MakableItems = CastMachine.MakableItems or {};
CastMachine.MAX_ITEMS_PATCH_SIZE = 1;
CastMachine.UnmakableItems = CastMachine.UnmakableItems or {};
CastMachine.Visible = true;

-- level requirement of learn list
local learn_list = {
        [21105] = 10,
        [21106] = 25,
        [21107] = 15,
        [21108] = 20,
        [21109] = 5,
        [21110] = 5,
    }
function CastMachine.GetLearnLevel(gsid)
    return learn_list[gsid] or 0;
end

function CastMachine.CanLearn(gsid)
    local level = CastMachine.GetLearnLevel(gsid);
    if(MyCompany.Aries.Player.GetLevel() >= level)then
        return true;
    end
end

function CastMachine:Init()
	self.page = document:GetPageCtrl();

end

function CastMachine.OnToggleCategory(skill_gsid)
	skill_gsid = tonumber(skill_gsid);
	local self = CastMachine
	if(IsMaking())then 
		return 
	end

	local k,v;
	for k,v in ipairs(LearnedSkill_subpage.LearnedSkill) do
		if(v.spec_id == skill_gsid)then
			self:SetItems(v.list);
			self.SPEC_ID = v.spec_id;
			self.SPEC_DESC = LearnedSkill_subpage.ItemsCates[v.spec_id].desc;
			self.cur_spec_exp = LearnedSkill_subpage.GetItemUnits(v.spec_id)			
			LearnedSkill_subpage.activeSpecName = v.name;
			break;
		end
	end
	self.Spec_Skill_name = LearnedSkill_subpage.activeSpecName
	CastMachine.OpMode = CastMachine.VIEW_SPEC
	CastMachine.EquipListView();

	if(self.page)then
		local pgbSpecPercentage2 = self.page:GetNode("pgbSpecPercentage2");
		if(pgbSpecPercentage2)then
			pgbSpecPercentage2:SetAttribute("Value",self.cur_spec_exp);
		end
	end
	CastMachine:Refresh();
end


--[[
{text=v2.name,gsid = v2.gsid,spec_gsid=v.gsid,
	exp = exp or 0,is_selected = false,
	colour = colour,units = units,mount_exp = f,
	canmake= canmake,spec_exp = spec_exp or 0,}
]]
function CastMachine:SetItems(src)
	self.MakableItems = {}
	self.UnmakableItems = {}
	self.HasMakeableItems = false
	self.HasunMakeableItems = false

	local i,v 
	for i,v in ipairs(src)do
		if(MyCompany.Aries.NPCs.SnowArea.LearnedSkill_subpage.MAKABLE)then
			if(v.canmake)then
				self.MakableItems[#self.MakableItems + 1] = v;
			else
				table.insert(self.UnmakableItems,v);
			end
		else
			if(v.spec_exp >= v.exp)then
				self.MakableItems[#self.MakableItems + 1] = v;
			else
				table.insert(self.UnmakableItems,v);
			end
		end
	end

	if(#self.MakableItems > 0)then
		self.HasMakeableItems = true
	end
	if(#self.UnmakableItems > 0)then
		self.HasunMakeableItems = true
	end
end

function CastMachine.ShowPage()
	local self = CastMachine;
	local width,height = 663,468;
	--CastMachine_subpage:BindParent("CastMachine",CastMachine);
	LearnedSkill_subpage:BuildSpecskillList()

	if(LearnedSkill_subpage.LearnedSpecCounter() > 0)then
		if(not self.SPEC_ID)then
			CastMachine.OpMode = CastMachine.VIEW_SPEC	
			local k,v;
			for k,v in ipairs(LearnedSkill_subpage.LearnedSkill) do
				self.Spec_Skill_name = v.name;
				self:SetItems(v.list);
				self.SPEC_ID = v.spec_id;
				self.SPEC_DESC = LearnedSkill_subpage.ItemsCates[v.spec_id].desc;
				self.cur_spec_exp = LearnedSkill_subpage.GetItemUnits(v.spec_id)
				LearnedSkill_subpage.activeSpecName = v.name;
				LearnedSkill_subpage.deactiveSpecName = nil;
				break;
			end
		end

		CastMachine.EquipListView();
		local params = {
			url = "script/apps/Aries/NPCs/SnowArea/CastMachine.teen.html", 
			name = "CastMachine.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			enable_esc_key = true,
			allowDrag = true,
			isTopLevel = false,
			directPosition = true,
			align = "_ct",
			x = -width * .5,
			y = -height * 0.5,
			width = width,
			height = height,
		}

		System.App.Commands.Call("File.MCMLWindowFrame", params);
		if(params._page)then
			params._page.OnClose = CastMachine.Clean;
		end	
		if(self.page and self.page.GetNode)then
			local pgbSpecPercentage2 = self.page:GetNode("pgbSpecPercentage2");
			if(pgbSpecPercentage2 and pgbSpecPercentage2.SetAttribute)then
				pgbSpecPercentage2:SetAttribute("Value",self.cur_spec_exp or 0);
			end
		end
	else
		CastMachine.OpMode = CastMachine.LEARN_NEW_SKILL
		CastMachine.ShowLearnSkillPage();
	end
end

function CastMachine.ShowLearnSkillPage()
	NPL.load("(gl)script/apps/Aries/NPCs/SnowArea/ForgetSkill.teen.lua");
	local ForgetSkill = commonlib.gettable("MyCompany.Aries.NPCs.SnowArea.ForgetSkill");
	ForgetSkill.ShowPage();
end

function CastMachine.Clean()
	local self  = CastMachine
	self.OpMode = nil;
	--self.Spec_Skill_name = ""; 
	--self.cur_spec_exp = 0 
	--self.MakableItems = {};
	--self.MAX_ITEMS_PATCH_SIZE = 1;
	--self.HasMakeableItems = false
	--self.HasunMakeableItems = false
	--self.SPEC_ID = nil;
	--self.UnmakableItems = {};

	--if(self.PP_TIMER)then
		--self.PP_TIMER:Change();
	--end
	LearnedSkill_subpage:Clean()
end

function CastMachine:SetVisible(visible)
	self.Visible = visible;
	self:Refresh();
end

function CastMachine:CloseWindow()
	if(self and self.page)then
		--if(IsMaking())then
			--self:SetVisible(false);
		--else
			self.page:CloseWindow();
		--end
	end
end

function CastMachine:Refresh(delta)
	if(self and self.page)then
		self.page:Refresh(delta or 0.1);
	end
end

local function comp_func(lhs,rhs)
	if(lhs > rhs)then
		return true
	else
		return false
	end
end

-- @param arg: "view1": makable "view2":unmakable.
function CastMachine.EquipListView(arg)
	local self = CastMachine
	if(IsMaking())then 
		return 
	end
	if(arg and self.ShowView == arg)then 
		return 
	end
	local refresh = true;
	if(not arg)then 
		refresh = false 
	end

	if(not arg) then
		if(self.HasMakeableItems) then
			arg = "view1";
		else
			arg = "view2";
		end
	end
	CastMachine.OpMode = CastMachine.VIEW_SPEC
	LearnedSkill_subpage:BuildSpecskillList();

	local k,v;
	for k,v in ipairs(LearnedSkill_subpage.LearnedSkill) do
		if(LearnedSkill_subpage.activeSpecName == v.name)then
			self:SetItems(v.list);
			self.SPEC_ID = v.spec_id;
			self.cur_spec_exp = LearnedSkill_subpage.GetItemUnits(v.spec_id)			
			break;
		end
	end
	self.Spec_Skill_name = LearnedSkill_subpage.activeSpecName

	local i,v
	if(CastMachine.ShowView == "view1")then
		for i,v in ipairs(self.MakableItems)do
			v.is_selected = false;
		end
	elseif(CastMachine.ShowView == "view2")then
		for i,v in ipairs(self.UnmakableItems)do
			v.is_selected = false;
		end
	end
	--[[local old = self.MakableItems
	self.MakableItems = {};

	local i,v
	for i,v in ipairs(old)do
		if(arg == "view1")then
			if(MyCompany.Aries.NPCs.SnowArea.LearnedSkill_subpage.MAKABLE)then
				if(v.canmake)then
					self.MakableItems[#self.MakableItems + 1] = v;
				end
			else
				if(v.spec_exp >= v.exp)then
					self.MakableItems[#self.MakableItems + 1] = v;
				end
			end
		elseif(arg == "view2")then
			if(v.exp > v.spec_exp )then
				self.UnmakableItems[#self.MakableItems + 1] = v;
			end
		end
		if(v.spec_exp >= v.exp)then
			self.HasMakeableItems = true --HasMakeableItems not means can make
		else
			self.HasunMakeableItems = true
		end
	end
	]]
	if(arg == "view1")then
		table_sort(self.MakableItems,function(tb1,tb2)
				if(tb1 and tb2)then
				return comp_func(tb1.mount_exp, tb2.mount_exp)
				end
			end);
	end

	CastMachine.ShowView = arg
	if(refresh)then
		self:Refresh();
	end
end

function CastMachine:GetSpec1DataSource(index)
	if(not index) then
		return #self.MakableItems;
	else
		-- return NPL.LoadTableFromString(commonlib.serialize(self.MakableItems[index]))
		return self.MakableItems[index];
	end
end

function CastMachine:GetSpec2DataSource(index)
	if(not index) then
		return #self.UnmakableItems;
	else
		-- return NPL.LoadTableFromString(commonlib.serialize(self.UnmakableItems[index]))
		return self.UnmakableItems[index];
	end
end


function CastMachine.GetSpecExp()
	if(CastMachine.TOTAL_SEPC_EXP and CastMachine.TOTAL_SEPC_EXP > 0 )then
		return string.format("%s/%s",CastMachine.cur_spec_exp, CastMachine.TOTAL_SEPC_EXP);	
	else
		return tostring(CastMachine.cur_spec_exp or 0);
	end 
end

function CastMachine:OnClickItem(arg,arg2)
	--TODO:show spec desc
	if(not arg or IsMaking())then return end

	self.Spec_Skill_name = LearnedSkill_subpage.activeSpecName  .. " > " .. arg
	CastMachine.OpMode = CastMachine.MAKE_ITEM

	MakeItem_subpage.MakeItemTable.gsid = LearnedSkill_subpage.MakableItemsNameTable[arg].gsid
	MakeItem_subpage.MakeItemTable.name = arg
	MakeItem_subpage.MakeItemTable.qty = LearnedSkill_subpage.MakableItemsNameTable[arg].qty
	MakeItem_subpage.MakeItemTable.exid = LearnedSkill_subpage.MakableItemsNameTable[arg].exid
	MakeItem_subpage.MakeItemTable.exp = LearnedSkill_subpage.MakableItemsNameTable[arg].exp

	CastMachine:GetMaterials(MakeItem_subpage.MakeItemTable.exid)
	-- self:LOG("MakeItem_subpage.MakeItemTable.materials:",MakeItem_subpage.MakeItemTable);
	
	local k,v,i2,v2
	for k,v in ipairs(LearnedSkill_subpage.LearnedSkill)do
		for i2,v2 in ipairs(v.list)do
			if(v2.text == arg)then
				self.cur_spec_exp = LearnedSkill_subpage.GetItemUnits(v.spec_id)
				self.MAKE_SPEC_ID = v.spec_id
				self.MAX_ITEMS_PATCH_SIZE = v2.units;
				break;
			end
		end
	end
	
	self.MAX_ITEMS_PATCH_SIZE = self.MAX_ITEMS_PATCH_SIZE or 1
	MakeItem_subpage.MAKE_UNITS = 1;

	local i,v
	if(CastMachine.ShowView == "view1")then
		for i,v in ipairs(self.MakableItems)do
			if(v.text == arg)then
				v.is_selected = true;
			else
				v.is_selected = false;
			end
		end
	elseif(CastMachine.ShowView == "view2")then
		for i,v in ipairs(self.UnmakableItems)do
			if(v.text == arg)then
				v.is_selected = true;
			else
				v.is_selected = false;
			end
		end
	end
	
	CastMachine:Refresh();
end

function CastMachine:GetMaterials(exid,gsid)
	MakeItem_subpage.MakeItemTable.materials = {};
	if(not LearnedSkill_subpage.ExchangeTempList[exid])then return end

	local froms = LearnedSkill_subpage.ExchangeTempList[exid].froms or {}
	local i,v
	for i,v in ipairs(froms)do
		if(v.key and v.key >0)  then
			local copies = LearnedSkill_subpage.GetItemUnits(v.key)
			local item = GetItemByID(v.key);
			local name,texture;
			if(item)then
				name = item.template.name;
				--texture = item.icon;
			end
			local material = {gsid = v.key,value = v.value,name = name or "",units = copies or 0,};
			table.insert(MakeItem_subpage.MakeItemTable.materials,material);
		elseif(v.key == -20) then
			MakeItem_subpage.MakeItemTable.materials.stamina_cost = math.abs(v.value or 0);
		end
	end
end

function CastMachine.OnClickFillStamina2()
	_guihelper.MessageBox("是否使用一个体力药剂补充体力值？" , function(result)
			if(result == _guihelper.DialogResult.Yes)then
				local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");
				local hasGSItem = ItemManager.IfOwnGSItem;
				local _,guid,_,copies = hasGSItem(17157); -- 精力药剂
				if(not copies or copies <= 0)then
					local command = System.App.Commands.GetCommand("Profile.Aries.PurchaseItemWnd");
					if(command) then
						command:Call({gsid = 17157});-- 精力药剂
					end
				else
					local item  = ItemManager.GetItemByGUID(guid)
					if(item and item.OnClick) then
						item:OnClick("left", function(msg)
							CastMachine:Refresh();
						end);
					end
				end
			end
		end, _guihelper.MessageBoxButtons.YesNo);
end

function CastMachine.Check()
	local item = if_else(MakeItem_subpage.MakeItemTable.gsid,GetItemByID(MakeItem_subpage.MakeItemTable.gsid),nil);
	if(item and item.template)then
		local copies = LearnedSkill_subpage.GetItemUnits(MakeItem_subpage.MakeItemTable.gsid)
		if(copies == item.template.maxcount)then
			return string.format("你已经拥有太多的【%s】。",MakeItem_subpage.MakeItemTable.name); 
		end
		
		local stamina_cost = commonlib.getfield("MakeItemTable.materials.stamina_cost", MakeItem_subpage) or 0;
		if(stamina_cost > MyCompany.Aries.Player.GetStamina2()) then
			return string.format("你的体力值不够了"); 
		end
	end
end

function CastMachine:AsyncUpdateItems()
	local k,v;
	for k,v in ipairs(LearnedSkill_subpage.LearnedSkill) do
		if(LearnedSkill_subpage.activeSpecName == v.name)then
			self:SetItems(v.list);
			self.SPEC_ID = v.spec_id;
			self.cur_spec_exp = LearnedSkill_subpage.GetItemUnits(v.spec_id)
			break;
		end
	end
	--[[
	local old = self.MakableItems
	self.MakableItems = {};
	self.HasMakeableItems = false
	self.HasunMakeableItems = false

	local i,v
	for i,v in ipairs(old)do
		if(MyCompany.Aries.NPCs.SnowArea.LearnedSkill_subpage.MAKABLE)then
			if(v.canmake)then
				self.MakableItems[#self.MakableItems + 1] = v;
			end
		else
			if(v.spec_exp >= v.exp)then
				self.MakableItems[#self.MakableItems + 1] = v;
			end
		end
		if(v.spec_exp >= v.exp)then
			self.HasMakeableItems = true --HasMakeableItems not means can make
		else
			self.HasunMakeableItems = true
		end
	end
	
	if(not self.HasMakeableItems )then
		self.MakableItems = old;
	end
	]]
	table_sort(self.MakableItems,function(tb1,tb2)
			if(tb1 and tb2)then
			return comp_func(tb1.mount_exp, tb2.mount_exp)
			end
		end);
	if(self.page)then
		local pgbSpecPercentage2 = self.page:GetNode("pgbSpecPercentage2");
		if(pgbSpecPercentage2)then
			pgbSpecPercentage2:SetAttribute("Value",self.cur_spec_exp);
		end
	end
	CastMachine:Refresh();
end

function CastMachine:_MakeItem(arg)
	if(MakeItem_subpage.MakeItemTable.exid and ExtendedCost and type(ExtendedCost) == "function") then
	ExtendedCost(MakeItem_subpage.MakeItemTable.exid,nil,nil,function(msg)
		if(msg) then
			--427  条件不符  
			if(msg.issuccess) then
				--MSG(string.format("成功制造了【%s】！",MakeItem_subpage.MakeItemTable.name));
				MakeItem_subpage:CalcMaterials()

				local function OnSuccess()
					LearnedSkill_subpage:BuildSpecskillList()
					-- self:LOG("self.MAKE_SPEC_ID",self.MAKE_SPEC_ID);
					self.cur_spec_exp = LearnedSkill_subpage.GetItemUnits(self.MAKE_SPEC_ID);
					-- self:LOG("cur_spec_exp",self.cur_spec_exp);

					if(MakeItem_subpage.MAKE_UNITS > 0)then
						MakeItem_subpage.SetCopies("dec")
					end
					CastMachine:AsyncUpdateItems()
				end
				OnSuccess();
				--ItemManager.GetItemsInBag( 12, "0", function(msg)
					--ItemManager.GetItemsInBag( 0, "0", 
					--function(msg) 
						--OnSuccess();
					--end, "access plus 0 seconds");
				--end, "access plus 0 seconds");
					
				self.SUB_PATCH = self.SUB_PATCH + 1
			else
				CastMachine:unfreezePage();
				if(msg.errorcode==427)then
					echo(msg)
					MSG(string.format("制造物品【%s】的条件不符！",MakeItem_subpage.MakeItemTable.name));
				elseif(msg.errorcode == 424)then
					MSG(string.format("物品【%s】的数量有限制，不能制造过多！",MakeItem_subpage.MakeItemTable.name))
				else
					echo(msg);
					MSG("制造失败了！");
				end
			end
		end
		end,function(msg)end);
	end	
end

function CastMachine.MakeItem(arg)	
	local err = CastMachine.Check();
	if(err)then
		MSG(err);
		return;
	end

	local self = CastMachine;
	if(arg == "btnMakeAll")then
		MakeItem_subpage.MAKE_UNITS = self.MAX_ITEMS_PATCH_SIZE
		MyCompany.Aries.NPCs.SnowArea.CastMachine:Refresh();
	end

	--enter page lock state
	--self.page:SetValue("AlphaPPT","1");

	local editBox = self.page:FindControl("txtItemsCount")
	if(editBox) then
		-- force lost focus, so that any key will cancel making items. 
		editBox:LostFocus(); 
	end

	-- the current item index to be made
	self.SUB_PATCH  = 0;
	self.MAX_PATCH = MakeItem_subpage.MAKE_UNITS;
	MakeItem_subpage.Making = 0;
	MyCompany.Aries.NPCs.SnowArea.CastMachine:Refresh();

	self.last_item = nil;
	self.PP_TIMER = self.PP_TIMER or commonlib.Timer:new({callbackFunc = function(timer)
			if(self.last_item ~= self.SUB_PATCH) then
				if(self.SUB_PATCH < self.MaxMakingCount and self.SUB_PATCH < self.MAX_PATCH)then
					self.last_item = self.SUB_PATCH;
					GathererBarPage.Start(nil,function()
						CastMachine:unfreezePage();
					 end,function()
						CastMachine:_MakeItem();
					end)
				else
					CastMachine:unfreezePage()
				end
			end
		end});
	
	self.PP_TIMER:Change(0,2000);
end

function CastMachine:unfreezePage()
	self.MAX_ITEMS_PATCH_SIZE = self.MAX_ITEMS_PATCH_SIZE - self.SUB_PATCH
	if(self.PP_TIMER)then
		self.PP_TIMER:Change();
	end	
	MakeItem_subpage.Making = nil;
	--MyCompany.Aries.NPCs.SnowArea.CastMachine:Refresh();
	self.SUB_PATCH = 0
	CastMachine:SetVisible(true)
	--self.page:SetValue("AlphaPPT","0");	
end

