--[[
Title: MoveHouseCar_frame
Author(s): Leio
Date: 2010/01/01

use the lib:

------------------------------------------------------------
script/apps/Aries/NPCs/TownSquare/30349_MoveHouseCar_frame.lua
------------------------------------------------------------
]]
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
-- create class
local libName = "MoveHouseCar_frame";
local MoveHouseCar_frame = {
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
	exchanged_item_tooltip = nil,--提示
	
	required_total_types = nil,--兑换物品 需要几种类型的物品
	
	required_item_gsid_1 = nil,
	required_item_tooltip_1 = nil,
    required_item_num_1 = nil,
    required_item_name_1 = nil,
    required_item_icon_1 = nil,
    has_item_num_1 = nil,
    --required_item_gsid_2 
    --required_item_gsid_3
    
    tooltip_map = {
		[39104] = "这里是最节能、最绿化的环保村，要想搬进去可不是件简单的活儿，你必须有50枚环保小红花才能代表你是个名副其实的环保小卫士，那样你就可以把家安在环保村咯！",
		[39103] = "搬家车发现了甜蜜岛屿，它是由好多奶油、巧克力酱和糖果构成的呢，可是它快化掉了，如果你有5个冰块和2个蜂蜜结晶，就能把甜蜜岛屿冻住，舒服的住进去了。",
		[39102] = "这里是喜气洋洋的新春之家，如果你有6个红枫叶，就可以把家都搬到新春之家去了。",
		[39101] = "这是美丽的冰雪之家，如果你有“哈”“奇”“小”“镇”“欢”“迎”“你”七种卡片各2张，就可以搬去那里住哦。",
		[-1] = "这里是春意盎然的青青草原，如果你有2000奇豆，就可以把家都搬到青青草原去了。",
    },
    
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.MoveHouseCar_frame", MoveHouseCar_frame);

function MoveHouseCar_frame.Clear()
	local self = MoveHouseCar_frame;
	self.state = "all";
	self.exID = nil;
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
		--cast_level = 0,
		--odds = 50,
	--}
--]]
function MoveHouseCar_frame.Bind(msg)
	commonlib.echo("=====name");
	commonlib.echo(msg);
	
	local exid = msg.exID;
	local single_gsid = msg.single_gsid;
	--local exTemplate = ItemManager.GetExtendedCostTemplateInMemory(exid);
	--commonlib.echo("========exTemplate");
	--commonlib.echo(exTemplate);
	--if(exTemplate) then
		--local single_gsid = string.match(exTemplate.exname, "^.+_(%d+)_.+$");
		--if(single_gsid) then
			--single_gsid = tonumber(single_gsid);
			--table.insert(msg.exchanged_gsids, {key = single_gsid, value = 1});
		--end
	--end
	if(single_gsid) then
		table.insert(msg.exchanged_gsids, {key = single_gsid, value = 1});
	end
		
	local self = MoveHouseCar_frame;
	self.Clear();
	local exID,gsids,exchanged_gsids,price,cast_level,odds = msg.exID,msg.gsids,msg.exchanged_gsids,msg.price,msg.cast_level,msg.odds;
	self.price,self.cast_level,self.odds = price,cast_level,odds;
	self.cast_next_level = msg.cast_next_level;
	self.odds_next_level = msg.odds_next_level;
	local r = self.GetItems(gsids);
	self.state = msg.state;
	if(exid == 293)then
		local k = 1;
		NPL.load("(gl)script/apps/Aries/Player/main.lua");
		local count = MyCompany.Aries.Player.GetMyJoybeanCount();
		self["has_item_num_"..k] = count;--自己的钱
		self["required_item_num_"..k] = 2000--需要的钱;
		self.required_total_types = k;--累计物品类型总数
	else
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
	end
	--最终合成的物品
	if(exid == 293)then
		--模拟 青青草原 物品
		self["exchanged_item_gsid"] = -1;
		self["exchanged_item_num"] = 1;
		self["exchanged_item_name"] = "青青草原";
		self["exchanged_item_icon"] = msg.icon or "";
		self["exchanged_item_tooltip"] = "这里是春意盎然的青青草原，如果你有2000奇豆，就可以把家都搬到青青草原去了。";
	else
		local r = self.GetItems(exchanged_gsids);
		if(r and r[1])then
			local gsid = r[1].gsid;
			self["exchanged_item_gsid"] = gsid;
			self["exchanged_item_num"] = r[1].num;
			local description = self.tooltip_map[gsid];
			self["exchanged_item_tooltip"] = description;
			self["exchanged_item_icon"] = msg.icon or "";
			local description = self.tooltip_map[gsid] or "";
			self["exchanged_item_tooltip"] = description;
			
		end
	end
end

-- s = { { key=17003, value=2 }, { key=17014, value=1 }, { key=17013, value=1 } },
function MoveHouseCar_frame.GetItems(s)
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
function MoveHouseCar_frame.CanBuild()
	local self = MoveHouseCar_frame;
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
