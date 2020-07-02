--[[
Title: CastMachine_compose_frame
Author(s): Leio
Date: 2010/01/18

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/SnowArea/30345_CastMachine_compose_frame.lua
------------------------------------------------------------
]]
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
-- create class
local libName = "CastMachine_compose_frame";
local CastMachine_compose_frame = {
	state = "all", -- "all" or "normal"
	exID = nil,
	cast_level = nil,--建造级别
	odds = nil,--合成几率
	cast_next_level = nil,--下一级
	odds_next_level = nil,
	
	exchanged_item_gsid = nil,
	exchanged_item_num = nil,
	exchanged_item_name = nil,
	exchanged_item_icon = nil,
	exchanged_item_price = nil,--出售价格
	
	required_total_types = nil,--兑换物品 需要几种类型的物品
	
	required_item_gsid_1 = nil,
	required_item_tooltip_1 = nil,
    required_item_num_1 = nil,
    required_item_name_1 = nil,
    required_item_icon_1 = nil,
    has_item_num_1 = nil,
    --required_item_gsid_2 
    --required_item_gsid_3
   
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.CastMachine_compose_frame", CastMachine_compose_frame);

function CastMachine_compose_frame.Clear()
	local self = CastMachine_compose_frame;
	self.state = "all";
	self.exID = nil;
	self.exinfo = nil;
	self.gsids = nil;
	self.exchanged_gsids = nil;
	self.cast_level = nil;
	self.odds = nil;
	self.cast_next_level = nil;
	self.odds_next_level = nil;
	
	self.exchanged_item_gsid = nil;
	self.exchanged_item_num = nil;
	self.exchanged_item_name = nil;
	self.exchanged_item_icon = nil;
	self.exchanged_item_price = nil;
	
	self.required_total_types = nil;
	local k;
	for k = 1,10 do
		self["required_item_gsid_"..k] = nil;
		self["required_item_num_"..k] = nil;
		self["required_item_tooltip_"..k] = nil;
		self["required_item_name_"..k] = nil;
		self["required_item_icon_"..k] = nil;
		self["has_item_num_"..k] = nil;
	end
end
--[[
	--local msg = {
		--exID = 271,
		--gsids = { { key=17003, value=2 }, { key=17014, value=1 }, { key=17013, value=1 } },
		--exchanged_gsids = { { key=30065, value=1 }, },
		--pres = { { key=30065, value=1 }, },
		--cast_level = 0,
		--odds = 50,
	--}
--]]
function CastMachine_compose_frame.Bind(msg)
	local self = CastMachine_compose_frame;
	self.Clear();
	local exid = msg.exID;
	local exTemplate = ItemManager.GetExtendedCostTemplateInMemory(exid);
	if(exTemplate) then
		local single_gsid = string.match(exTemplate.exname, "^.+_(%d+)_.+$");
		if(single_gsid) then
			single_gsid = tonumber(single_gsid);
			--table.insert(msg.exchanged_gsids, {key = single_gsid, value = 1});
		end
	end
	
	local exID,gsids,exchanged_gsids,price,cast_level,odds = msg.exID,msg.gsids,msg.exchanged_gsids,msg.price,msg.cast_level,msg.odds;
	self.exinfo = msg.exinfo;
	self.price,self.cast_level,self.odds = price,cast_level,odds;
	self.cast_next_level = msg.cast_next_level;
	self.odds_next_level = msg.odds_next_level;
	
	--把msg.pres 和 msg.gsids 和到一起
	local new_gsids = {};
	if(msg.pres)then
		local k,v;
		for k,v in ipairs(msg.pres) do
			table.insert(new_gsids,v);
		end
	end
	if(msg.gsids)then
		local k,v;
		for k,v in ipairs(msg.gsids) do
			table.insert(new_gsids,v);
		end
	end
	local r = self.GetItems(new_gsids);
	self.state = msg.state;
	if(r)then
		local k,v;
		for k,v in ipairs(r) do
			if(v.gsid)then
				local gsid = v.gsid;
				self["required_item_gsid_"..k] = gsid;
				self["required_item_num_"..k] = v.num;
				
				local __, guid,__,copies = hasGSItem(gsid);
				self["has_item_num_"..k] = copies or 0;--自己拥有物品的数量
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid)
				if(gsItem) then
					local name = gsItem.template.name or "";
					local icon = gsItem.icon or "";
					self["required_item_name_"..k] = name;
					self["required_item_icon_"..k] = icon;
					
					local description = gsItem.template.description;
					if(description)then
						local __,__,__,place = string.find(description,"(.+)|(.+)");
						description = place or "";
					end
					local tooltip = string.format("%s---%s",name,description);
					self["required_item_tooltip_"..k] = tooltip;
				end
				
				self.required_total_types = k;--累计物品类型总数
			end
		end
	end
	--最终合成的物品
	local r = self.GetItems(exchanged_gsids);
	if(r)then
		local gsid = r[1].gsid;
		self["exchanged_item_gsid"] = gsid;
		self["exchanged_item_num"] = r[1].num;
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid)
		if(gsItem) then
			local name = gsItem.template.name;
			local icon = gsItem.icon;
			local price = gsItem.ebuyprice;
			self["exchanged_item_name"] = name or "";
			self["exchanged_item_icon"] = icon or "";
			--[[
				assetfile="model/05plants/v5/04other/BambooBarrier/BambooBarrier.x",
			  category="OutdoorOther",
			  dailylimitedpurchase=0,
			  descfile="",
			  ebuyprice=500,
			  esellprice=0,
			  esellrandombonus=0,
			  gsid=30052,
			  hourlylimitedpurchase=50,
			  icon="Texture/Aries/Item/30052_BambooBarrier.png",
			  maxdailycount=0,
			  maxweeklycount=0,
			  pbuyprice=0,
			  psellprice=0,
			  --]]
			self["exchanged_item_price"] = price or "";
		end
	end
end
--function CastMachine_compose_frame.GetItems(s)
	--if(not s)then return end
	--local exist;
	--local result = {};
	--for exist in string.gfind(s, "([^|]+)") do
		--if(exist)then
			--local __,__,gsid,num = string.find(exist,"(.+),(.+)");
			--gsid = tonumber(gsid);
			--num = tonumber(num);
			--table.insert(result,{gsid = gsid, num = num});
		--end
	--end
	--return result;
--end
-- s = { { key=17003, value=2 }, { key=17014, value=1 }, { key=17013, value=1 } },
function CastMachine_compose_frame.GetItems(s)
	if(not s)then return end
	local exist;
	local result = {};
	local k,v;
	for k,v in ipairs(s) do
		table.insert(result,{gsid = v.key, num = v.value});
	end
	return result;
end
--是否可以建造
function CastMachine_compose_frame.CanBuild()
	local self = CastMachine_compose_frame;
	if(self.required_total_types)then
		local result = {};
		local k;
		for k = 1,self.required_total_types do
			local required_num = self["required_item_num_"..k];
			local has_num = self["has_item_num_"..k];
			if(required_num and has_num and has_num >= required_num)then
				result[k] = true;
			end
		end
		for k = 1,self.required_total_types do
			--只要有一个不满足 返回false
			if(not result[k])then
				return false;
			end
		end
		return true;
	end
end
--返回错误提示信息
function CastMachine_compose_frame.Error_NeedItems()
	local self = CastMachine_compose_frame;
	local total_type = self.required_total_types;
	if(total_type == 1)then
		s = string.format("制作一个%s需要%d个%s,你的材料还不够呢。",
											self.exchanged_item_name,
											self.required_item_num_1,self.required_item_name_1
											);
	elseif(total_type == 2)then
		s = string.format("制作一个%s需要%d个%s,%d个%s,你的材料还不够呢。",
											self.exchanged_item_name,
											self.required_item_num_1,self.required_item_name_1,
											self.required_item_num_2,self.required_item_name_2
											);
	elseif(total_type == 3)then
		s = string.format("制作一个%s需要%d个%s,%d个%s,%d个%s,你的材料还不够呢。",
											self.exchanged_item_name,
											self.required_item_num_1,self.required_item_name_1,
											self.required_item_num_2,self.required_item_name_2,
											self.required_item_num_3,self.required_item_name_3
											);
	elseif(total_type == 4)then
		s = string.format("制作一个%s需要%d个%s,%d个%s,%d个%s,%d个%s,你的材料还不够呢。",
											self.exchanged_item_name,
											self.required_item_num_1,self.required_item_name_1,
											self.required_item_num_2,self.required_item_name_2,
											self.required_item_num_3,self.required_item_name_3,
											self.required_item_num_4,self.required_item_name_4
											);
	elseif(total_type == 5)then
		s = string.format("制作一个%s需要%d个%s,%d个%s,%d个%s,%d个%s,%d个%s,你的材料还不够呢。",
											self.exchanged_item_name,
											self.required_item_num_1,self.required_item_name_1,
											self.required_item_num_2,self.required_item_name_2,
											self.required_item_num_3,self.required_item_name_3,
											self.required_item_num_4,self.required_item_name_4,
											self.required_item_num_5,self.required_item_name_5
											);
	end
	s = string.format("<div style='margin-left:15px;margin-top:20px;text-align:center'>%s</div>",s);
	return s;
end

