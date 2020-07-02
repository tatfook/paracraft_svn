--[[
Title: Desktop addon level
Author(s): LiXizhi
Date: 2012/4/5
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Items/item.addonlevel.lua");
local addonlevel = commonlib.gettable("MyCompany.Aries.Items.addonlevel");
addonlevel.init();
echo({addonlevel.get_levelup_req(1808, nil, 5)}) -- 17178, 500
echo({addonlevel.get_levelup_req(1808, nil, 6)}) -- nil
echo({addonlevel.get_levelup_req(1809, 3, 5)})  -- 17178, 630
echo({addonlevel.get_attack_percentage(1809, 5)})  -- 5

-- on client side, call this to upgrade
local _, guid = Map3DSystem.Item.ItemManager.IfOwnGSItem(1807);
if(guid) then
	System.GSL_client:SendRealtimeMessage("sPowerAPI", {name="SetItemAddonLevel", params={guid=guid}});
end
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemItem/ItemManager.lua");
local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");
-- create class
local addonlevel = commonlib.gettable("MyCompany.Aries.Items.addonlevel");

-- mapping from gsid to itemset table. 
local items = {};
local itemsets = {};

-- load everything from file
-- calling this multiple times has no effect
-- @param filename: load from config/Aries/Others/globalstore.addonlevel.kids.xml
function addonlevel.init(filename)
	if(addonlevel.is_inited) then
		return
	end
	addonlevel.is_inited = true;
	filename = filename or if_else(System.options.version=="kids", "config/Aries/Others/globalstore.addonlevel.kids.xml", "config/Aries/Others/globalstore.addonlevel.teen.xml");
	
	local xmlDocRoot = ParaXML.LuaXML_ParseFile(filename);
	if(not xmlDocRoot) then
		LOG.std(nil, "error", "addonlevel", "can not open file from %s", filename);
		return;
	end
	itemsets = {};
	local node;
	for node in commonlib.XPath.eachNode(xmlDocRoot, "/itemsets/itemset") do
		if(node.attr and node.attr.gsids) then
			local itemset = {};
			itemsets[#itemsets+1] = itemset;
			
			local gsid;
			for gsid in node.attr.gsids:gmatch("%d+") do
				items[tonumber(gsid)] = itemset;
			end
			local sub_node;
			for sub_node in commonlib.XPath.eachNode(node, "/addon") do
				local addon = sub_node.attr;
				local level = tonumber(addon.level);
				itemset[level] = addon;
				addon.attack_percentage = tonumber(addon.attack_percentage);
				addon.attack_absolute = tonumber(addon.attack_absolute);
				addon.hp = tonumber(addon.hp);
				addon.resist_absolute = tonumber(addon.resist_absolute);
				addon.resilience_percentage = tonumber(addon.resilience_percentage);
				addon.critical_strike_percent = tonumber(addon.critical_strike_percent);

				if(addon.levelup_requirement) then
					local require_gsid, require_count = addon.levelup_requirement:match("^{(%-?%d+),(%d+)}");
					if(require_count) then
						addon.require_gsid = tonumber(require_gsid);
						addon.require_count = tonumber(require_count);
					end
				end
			end
		end
	end
end

-- get attack percentage by gsid and level
-- @return nil if it does not contain any attack percentage. 
function addonlevel.get_attack_percentage(gsid, level)
	return addonlevel.get_value(gsid, level, "attack_percentage");
end

-- get attack absolute by gsid and level
-- @return nil if it does not contain any attack absolute 
function addonlevel.get_attack_absolute(gsid, level)
	return addonlevel.get_value(gsid, level, "attack_absolute");
end

-- get resist absolute by gsid and level
-- @return nil if it does not contain any resist absolute 
function addonlevel.get_resist_absolute(gsid, level)
	return addonlevel.get_value(gsid, level, "resist_absolute");
end

-- get resist absolute by gsid and level
-- @return nil if it does not contain any resist absolute 
function addonlevel.get_resilience_percentage(gsid, level)
	return addonlevel.get_value(gsid, level, "resilience_percentage");
end

-- get resist absolute by gsid and level
-- @return nil if it does not contain any resist absolute 
function addonlevel.get_critical_strike_percent(gsid, level)
	return addonlevel.get_value(gsid, level, "critical_strike_percent");
end

-- get hp absolute by gsid and level
-- @return nil if it does not contain any hp absolute 
function addonlevel.get_hp_absolute(gsid, level)
	return addonlevel.get_value(gsid, level, "hp");
end

-- get value by fieldname
function addonlevel.get_value(gsid, level, fieldname)
	local itemset = items[gsid];
	
	if(itemset) then
		local max_level = #itemset;
		level = level or 1;
		if(max_level < level) then
			LOG.std(nil, "debug", "item.addonlevel", "gsid:%d has level %d which is larger than max_level %d", gsid, level, max_level)
			level = max_level;
		end
		local addon = itemset[level];
		if(addon) then
			return addon[fieldname];
		end
		return 0;
	end
end

-- get the max addon level. 
function addonlevel.get_max_addon_level(gsid)
	local itemset = items[gsid];
	if(itemset) then
		return #itemset;
	end
end

-- if there is addon property for the item. 
function addonlevel.can_have_addon_property(gsid)
	return items[gsid]~=nil;
end

-- get levelup requirement
-- @return gsid, count: 
function addonlevel.get_levelup_req(gsid, from_level, to_level)
	local itemset = items[gsid];
	if(itemset) then
		to_level = to_level or ((from_level or 0) + 1);
		from_level = from_level or (to_level - 1);

		local require_gsid
		local require_count = 0;

		local level;
		for level = from_level+1, to_level do 
			local addon = itemset[level];
			if(addon and addon.require_count) then
				require_gsid = addon.require_gsid;
				require_count = require_count + addon.require_count;
			end
		end
		if(require_count>0) then
			return require_gsid, require_count;
		end
	end
end
function addonlevel.get_itemset(gsid)
	return items[gsid];
end
function addonlevel.get_addon(gsid,level)
	local itemset = addonlevel.get_itemset(gsid);
	if(itemset)then
		return itemset[level];
	end
end
--根据已有的货币(奇豆)推算可以升级的属性
function addonlevel.search_addon_bycost(require_gsid, require_count,gsid)
	local itemset = addonlevel.get_itemset(gsid);
	if(itemset)then
		local k,addon;
		local result;
		for k,addon in ipairs(itemset) do
			if(addon.require_gsid == require_gsid and addon.require_count <= require_count)then
				result = addon;
			end
		end
		return result;
	end	
end
--交换属性
function addonlevel.tradein(from_gsid,from_level,to_gsid)
	if(not from_gsid or not from_level or not to_gsid)then return end
	if(from_gsid == to_gsid)then
		return
	end
	local from_addon = addonlevel.get_addon(from_gsid,from_level);
	if(from_addon)then
		local to_addon = addonlevel.search_addon_bycost(from_addon.require_gsid, from_addon.require_count,to_gsid);
		return to_addon;
	end
end
--查找和gsid相同类型的物品，并按等级从低到高排序
function addonlevel.search_same_type_items(gsid)
	if(not gsid)then return end
	local s_gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(s_gsItem)then
		local s_class = s_gsItem.template.class;
		local s_subclass = s_gsItem.template.subclass;
		local s_equip_level = s_gsItem.template.stats[138] or s_gsItem.template.stats[168];

		if(items)then
			local result = {};
			local k,v;
			for k,v in pairs(items) do
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(k);
				if(gsItem)then
					local class = gsItem.template.class;
					local subclass = gsItem.template.subclass;
					local equip_level = gsItem.template.stats[138] or gsItem.template.stats[168];
					equip_level = equip_level or 0;
					if(s_class == class and s_subclass == subclass)then
						table.insert(result,{
							gsid = k,
							equip_level = equip_level,
						});
					end
				end
			end
			table.sort(result,function(a,b)
				return a.equip_level < b.equip_level;
			end);
			return result;
		end
	end
	
end