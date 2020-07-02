--[[
Title: code behind for make machine
Author(s): WD
Date: 2011/11/08

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/SnowArea/MakeItem_subpage.teen.lua");

--]]

local ItemManager = Map3DSystem.Item.ItemManager;
local GetItemByID = ItemManager.GetGlobalStoreItemInMemory;
local GetItemsCount = ItemManager.GetItemCountInBag;
local GetItemsInBag = ItemManager.GetItemsInBag;
local hasGSItem = ItemManager.IfOwnGSItem;
local GetExtTemp = ItemManager.GetExtendedCostTemplateInMemory;
local MSG = _guihelper.MessageBox;
local echo = commonlib.echo;

local MakeItem_subpage = commonlib.gettable("MyCompany.Aries.NPCs.SnowArea.MakeItem_subpage");
NPL.load("(gl)script/apps/Aries/Desktop/GenericTooltip.lua");
local GenericTooltip = CommonCtrl.GenericTooltip:new();

MakeItem_subpage.MAKE_UNITS = 1
MakeItem_subpage.visible = false;
MakeItem_subpage.MakeItemTable = 
{
--[[
	display_percentage = "",
	cur_percentage = 10,
	total_percentage = 200,
	name = "bbbbb",
	qty = 3,
	gsid = 1533,
	materials = {},
	level_stage = "",
	]]
}

local format = string.format
function MakeItem_subpage:Init()
	self.page  = document:GetPageCtrl()
end

function MakeItem_subpage:SetMakeItem()
	self.page:SetValue("makeitem",MakeItem_subpage.MakeItemTable.gsid);
end

function MakeItem_subpage:SetSkillPercentage()
	if(MyCompany.Aries.NPCs.SnowArea.CastMachine.TOTAL_SEPC_EXP > 0)then
		MakeItem_subpage.MakeItemTable.display_percentage = format("%s/%s",MyCompany.Aries.NPCs.SnowArea.CastMachine.cur_spec_exp,MyCompany.Aries.NPCs.SnowArea.CastMachine.TOTAL_SEPC_EXP);
	else	
		MakeItem_subpage.MakeItemTable.display_percentage = tostring(MyCompany.Aries.NPCs.SnowArea.CastMachine.cur_spec_exp or 0)
	end
	self.page:SetValue("btnPercentage",MakeItem_subpage.MakeItemTable.display_percentage);
end

function MakeItem_subpage.GetName()
	return string.format([[<div style="color:%s;">%s</div>]],GenericTooltip.GetEquipColor(MakeItem_subpage.MakeItemTable.qty or 0),MakeItem_subpage.MakeItemTable.name or "unknown");
end

function MakeItem_subpage:GetDataSource(index)

	if(index == nil) then
		return #(MakeItem_subpage.MakeItemTable.materials);
	else
		return MakeItem_subpage.MakeItemTable.materials[index];
	end
end

--[[
check materials whether is enought 
]]
function MakeItem_subpage:CheckMaterials()
	local mat = MakeItem_subpage.MakeItemTable.materials;
	if(not mat)then return end
	local i,v,n
	for i,v in ipairs(mat)do
		if(v.units < v.value)then
			n = true;
			break;
		end
	end
	return n
end

--[[
calc materials,be called after make item successfully
]]
function MakeItem_subpage:CalcMaterials()
	local mat = MakeItem_subpage.MakeItemTable.materials;
	if(not mat)then return end
	local i,v
	for i,v in ipairs(mat)do
		v.units = v.units - v.value
		if(v.units < 0)then v.units = 0 end
	end	
end

function MakeItem_subpage.DoMake(arg)
	if(MakeItem_subpage.Making)then return end;
	MyCompany.Aries.NPCs.SnowArea.CastMachine.MakeItem(arg)
end

function MakeItem_subpage:Clean()
	MakeItem_subpage:ResetStates()
end

function MakeItem_subpage:ResetStates()
	MakeItem_subpage.visible = false;
	MakeItem_subpage.MAKE_UNITS = 1
end

function MakeItem_subpage.SetCopies(arg)
	local self = MakeItem_subpage;
	--if(self.Making)then return end;
	if(arg == "inc")then
		if(self.MAKE_UNITS < MyCompany.Aries.NPCs.SnowArea.CastMachine.MAX_ITEMS_PATCH_SIZE)then
			self.MAKE_UNITS = self.MAKE_UNITS + 1
		end
	elseif(arg == "dec")then
		self.MAKE_UNITS = self.MAKE_UNITS - 1
		if(self.MAKE_UNITS == 0)then self.MAKE_UNITS = 1 end
	end

	MyCompany.Aries.NPCs.SnowArea.CastMachine:Refresh();	
end

function MakeItem_subpage.OnKeyupCopies(ctrl)
	local self = MakeItem_subpage;
	if(self.Making)then return end;

	local ctrl = self.page:FindControl(ctrl);
    if(not tonumber(ctrl.text))then
		self.page:SetUIValue("txtItemsCount",self.MAKE_UNITS)
        --_guihelper.MessageBox("无效的输入.");
		return;
    end

	if(tonumber(ctrl.text) > MyCompany.Aries.NPCs.SnowArea.CastMachine.MAX_ITEMS_PATCH_SIZE)then
		self.MAKE_UNITS = MyCompany.Aries.NPCs.SnowArea.CastMachine.MAX_ITEMS_PATCH_SIZE;	
		self.page:SetUIValue("txtItemsCount",self.MAKE_UNITS)
	elseif(tonumber(ctrl.text) < 1)then
		self.MAKE_UNITS = 1;
		self.page:SetUIValue("txtItemsCount",self.MAKE_UNITS)
	else
		self.MAKE_UNITS = tonumber(ctrl.text);
	end	
end

