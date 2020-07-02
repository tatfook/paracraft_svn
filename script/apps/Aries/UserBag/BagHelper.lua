--[[
Title: 
Author(s): leio
Date: 2012/05/21
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/UserBag/BagHelper.lua");
local BagHelper = commonlib.gettable("MyCompany.Aries.Inventory.BagHelper");
BagHelper.Load()
commonlib.echo(BagHelper.bags_menu);
BagHelper.bags_menu = {
	{
		label = label,
		keyname = keyname,
		{label = subfolder_label, keyname = subfolder_keyname,},
		{label = subfolder_label, keyname = subfolder_keyname,},
		{label = subfolder_label, keyname = subfolder_keyname,},
	},
	{
		label = label,
		keyname = keyname,
		{label = subfolder_label, keyname = subfolder_keyname,},
		{label = subfolder_label, keyname = subfolder_keyname,},
		{label = subfolder_label, keyname = subfolder_keyname,},
	},
}
BagHelper.bags = {
	["folder_keyname"] = {
		["subfolder_keyname"] = 
		{
			{
				search_bag_all = true, 
				category = category,
				card_school = card_school, 
				gem_level = gem_level, 
				bag = bag, class = class, subclass = subclass, 
				region = {
					{ gsid_from = gsid_from, gsid_to = gsid_to,},
					{ gsid_from = gsid_from, gsid_to = gsid_to,},
				},
			},
			{
				search_bag_all = true, 
				category = category,
				card_school = card_school, 
				gem_level = gem_level, 
				bag = bag, class = class, subclass = subclass, 
				region = {
					{ gsid_from = gsid_from, gsid_to = gsid_to,},
					{ gsid_from = gsid_from, gsid_to = gsid_to,},
				},
			},
		},
		["subfolder_keyname"] = ...
	},
	["folder_keyname"] = ...
}
NPL.load("(gl)script/apps/Aries/UserBag/BagHelper.lua");
local BagHelper = commonlib.gettable("MyCompany.Aries.Inventory.BagHelper");
local folder_key = "Equipment";
local subfolder_key = "1";
BagHelper.Search(nid,folder_key,subfolder_key,function(msg)
	commonlib.echo("========msg.item_list");
	commonlib.echo(msg.item_list);
end)

NPL.load("(gl)script/apps/Aries/UserBag/BagHelper.lua");
local BagHelper = commonlib.gettable("MyCompany.Aries.Inventory.BagHelper");
local gsid = 984;
_guihelper.MessageBox(BagHelper.IsInExcludeRegion(gsid));
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/ide/XPath.lua");
NPL.load("(gl)script/kids/3DMapSystemItem/ItemManager.lua");
local ItemManager = Map3DSystem.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
local BagHelper = commonlib.gettable("MyCompany.Aries.Inventory.BagHelper");
BagHelper.file_path = "config/Aries/BagDefine_Teen/bag.xml";
BagHelper.bags_menu = nil;
BagHelper.bags = nil;
BagHelper.exclude_regions = {};
function BagHelper.SortCard(items)
	local self = CharacterBagPage;
	if(not items)then
		return
	end

	local k,v;
	for k,v in ipairs(items) do
		local gsid = v.gsid;
		if(gsid)then
			local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
			if(gsItem)then
				local school = gsItem.template.stats[136] or -1
				if(CommonClientService.IsRightSchool(gsid,nil,136))then
					school = -1;
				end
				local combatlevel_requirement = gsItem.template.stats[138] or 0;  -- 掉落装备级别
				local apparel_quality = gsItem.template.stats[221] or -1
				v.school = school;
				v.combatlevel_requirement = combatlevel_requirement;
				v.apparel_quality = apparel_quality;
			end
		end
	end
	table.sort(items,function(a,b)
		return (a.school < b.school)
			or (a.school == b.school and a.combatlevel_requirement < b.combatlevel_requirement)
			or (a.school == b.school and a.combatlevel_requirement == b.combatlevel_requirement and a.apparel_quality < b.apparel_quality)
	end);
end
function BagHelper.IsInExcludeRegion(gsid,guid)
	local self = BagHelper;
	if(not gsid)then return end
	local k,v;
	for k,v in ipairs(self.exclude_regions) do
		if(gsid >= v.from and gsid <= v.to)then
			return true;
		end
	end
	if(guid < 0)then
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
		if(gsItem)then
			local bag = gsItem.template.bagfamily;
			if(bag == 24)then
				return true;
			end
		end
	end
end
function BagHelper.GetBagsMenu()
	local self = BagHelper;
	self.Load();
	return self.bags_menu or {};
end
function BagHelper.GetBagsItem()
	local self = BagHelper;
	self.Load();
	return self.bags_menu or {};
end
function BagHelper.ToTable(s)
	if(not s)then return end
	local result = {};
	local v;
	for v in string.gfind(s, "[^,]+") do
		table.insert(result,tonumber(v));
	end
	return result;
end
function BagHelper.Load()
	local self = BagHelper;
	if(self.is_load)then
		return
	end
	self.is_load = true;
	local bags_menu = {};
	local bags = {};
	self.file_path = if_else(Map3DSystem.options.version=="kids", "config/Aries/BagDefine/bag.xml", "config/Aries/BagDefine_Teen/bag.xml");
	local xmlRoot = ParaXML.LuaXML_ParseFile(self.file_path);
	local exclude_node
	for exclude_node in commonlib.XPath.eachNode(xmlRoot, "/items/exclude/item") do
		local from_gsid = tonumber(exclude_node.attr.from);
		local to_gsid = tonumber(exclude_node.attr.to);
		if(from_gsid and to_gsid)then
			table.insert(self.exclude_regions,{from = from_gsid, to = to_gsid});
		end
	end
	local folder_node;
	local folder_index = 0;
	for folder_node in commonlib.XPath.eachNode(xmlRoot, "/items/folder") do
		folder_index = folder_index + 1;
		local folder_label = folder_node.attr.label;
		local folder_keyname = folder_node.attr.keyname or tostring(folder_index);
		local subfolder_node;
		local folder_bags = bags[folder_keyname] or {};
		bags[folder_keyname] = folder_bags;
		--menu
		local folder_menu = {
			label = folder_label,
			keyname = folder_keyname,
		}
		table.insert(bags_menu,folder_menu);
		local subfolder_index = 0;
		for subfolder_node in commonlib.XPath.eachNode(folder_node, "/subfolder") do
			subfolder_index = subfolder_index + 1;
			local subfolder_label = subfolder_node.attr.label;
			local subfolder_keyname = subfolder_node.attr.keyname or tostring(subfolder_index);
			local subfolder_bags = folder_bags[subfolder_keyname] or {};
			folder_bags[subfolder_keyname] = subfolder_bags;
			--系别过滤
			local card_school = subfolder_node.attr.card_school;
			--宝石级别过滤，只对宝石有效
			local gem_level = tonumber(subfolder_node.attr.gem_level);
			--menu
			local subfolder_menu = {
				label = subfolder_label,
				keyname = subfolder_keyname,
			}
			table.insert(folder_menu,subfolder_menu);
			local item_node;
			for item_node in commonlib.XPath.eachNode(subfolder_node, "/item") do
				local search_bag_all = item_node.attr.search_bag_all;
				if(search_bag_all and (search_bag_all == "True" or search_bag_all == "true"))then
					search_bag_all = true;
				else
					search_bag_all = false;
				end
				local category = item_node.attr.category;
				
				--bag编号
				local bag = tonumber(item_node.attr.bag);
				local class = tonumber(item_node.attr.class);--table
				local subclass = BagHelper.ToTable(item_node.attr.subclass);--table
				--gsid区间
				local region;
				local region_node;
				for region_node in commonlib.XPath.eachNode(item_node, "/region") do
					local gsid_from = tonumber(region_node.attr.gsid_from);
					local gsid_to = tonumber(region_node.attr.gsid_to);

					region = region or {};
					table.insert(region,{gsid_from = gsid_from, gsid_to = gsid_to, });
				end
				local item = {
					folder_label = folder_label,
					folder_keyname = folder_keyname,
					subfolder_label = subfolder_label,
					subfolder_keyname = subfolder_keyname,
					search_bag_all = search_bag_all,
					category = category,
					card_school = card_school,
					gem_level = gem_level,
					bag = bag,
					class = class,
					subclass = subclass,
					region = region,
				}
				table.insert(subfolder_bags,item);
			end
		end
	end
	self.bags_menu = bags_menu;
	self.bags = bags;
end
function BagHelper.SearchBag(nid,bag_node,callbackFunc,cache_policy)
	local self = BagHelper;
	if(not bag_node)then return end
	local is_myself;
	if(not nid or nid == Map3DSystem.User.nid)then
		is_myself = true;
	end
	cache_policy = cache_policy or "access plus 1 year";
	local search_bag_all = bag_node.search_bag_all;
	local category = bag_node.category;
	local card_school = bag_node.card_school;
	local gem_level = bag_node.gem_level;
	local bag = bag_node.bag;
	local class = bag_node.class;
	local subclass = bag_node.subclass;
	local region = bag_node.region;
	local class_map = {};
	local subclass_map = {};
	--只有一个值
	if(class)then
		class_map[class] = true;
	end
	--有多个值
	if(subclass)then
		local k,v;
		for k,v in ipairs(subclass) do
			subclass_map[v] = true;
		end
	end
	local function push(item)
		if(item and item.gsid)then
			local gsid = item.gsid;

			local guid = item.guid;
			local obtaintime = item.obtaintime;
			local can_push = false;
			if(self.IsInExcludeRegion(gsid,guid))then
				return false;
			end
			local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
			if(search_bag_all)then
				can_push = true;
			else
				if(gsItem)then
					--有指定目录
					if(category and gsItem.category)then
						if(category == gsItem.category)then
							can_push = true;
						end
					else
						local _class = gsItem.template.class;
						local _subclass = gsItem.template.subclass;
						if(_class and class_map[_class] and _subclass and subclass_map[_subclass])then
							if(card_school or gem_level)then
								local stats = gsItem.template.stats;
								if(card_school)then
									if(CommonClientService.IsRightSchool(gsid,card_school,136))then
										can_push = true;
									end
								end
								if(gem_level)then
							
									local _gem_level = stats[41];--宝石等级
									if(_gem_level and gem_level == _gem_level)then
										can_push = true;
									end
							
								end
							else
								can_push = true;
								if(region)then
									local k,v;
									for k,v in ipairs(region) do
										local from = v.gsid_from;
										local to = v.gsid_to;
										if(from and gsid < from)then
											can_push = false;
										end
										if(to and gsid > to)then
											can_push = false;
										end
									end							
								end
							end
						end
					end
				end
			end
			return can_push;
		end
	end
	if(is_myself)then
		ItemManager.GetItemsInBag(bag, "ariesitems_" .. bag, function(msg)
			local i;
			local cnt = ItemManager.GetItemCountInBag(bag);
			local result = {};
			for i = 1, cnt do
				local item = ItemManager.GetItemByBagAndOrder(bag, i);
				if(item and item.gsid)then
					local gsid = item.gsid;
					local guid = item.guid;
					local obtaintime = item.obtaintime;
					local clientdata = item.clientdata;
					local serverdata = item.serverdata;
					local cnt = item.copies or 0;
					local can_push = push(item);
					if(can_push)then
						local node = {
							gsid = gsid,
							guid = guid,
							obtaintime = obtaintime,
							clientdata = clientdata,
							serverdata = serverdata,
							cnt = cnt,
						};	
						table.insert(result,node);
					end
				end
			end
			if(callbackFunc)then
				callbackFunc({
					item_list = result,
				});
			end
		end, cache_policy);		
	else
		ItemManager.GetItemsInOPCBag(nid,bag, "ariesitems_" .. bag, function(msg)
			local i;
			local cnt = ItemManager.GetOPCItemCountInBag(nid,bag);
			local result = {};
			for i = 1, cnt do
				local item = ItemManager.GetOPCItemByBagAndOrder(nid,bag, i);
				if(item and item.gsid)then
					local gsid = item.gsid;
					local guid = item.guid;
					local obtaintime = item.obtaintime;
					local clientdata = item.clientdata;
					local serverdata = item.serverdata;
					local cnt = item.copies or 0;
					local can_push = push(item);
					if(can_push)then
						local node = {
							gsid = gsid,
							guid = guid,
							obtaintime = obtaintime,
							clientdata = clientdata,
							serverdata = serverdata,
							cnt = cnt,
						};	
						table.insert(result,node);
					end
				end
			end
			if(callbackFunc)then
				callbackFunc({
					item_list = result,
				});
			end
		end, cache_policy);	
	end

end
--[[return 
	local list = {
		{gsid = gsid,guid = guid,obtaintime = obtaintime,},
		{gsid = gsid,guid = guid,obtaintime = obtaintime,},
		{gsid = gsid,guid = guid,obtaintime = obtaintime,},
--]]
function BagHelper.SearchBag_Memory(nid,bag_node)
	local self = BagHelper;
	if(not bag_node)then return end
	local is_myself;
	if(not nid or nid == Map3DSystem.User.nid)then
		is_myself = true;
	end
	local search_bag_all = bag_node.search_bag_all;
	local category = bag_node.category;
	local card_school = bag_node.card_school;
	local gem_level = bag_node.gem_level;
	local bag = bag_node.bag;
	local class = bag_node.class;
	local subclass = bag_node.subclass;
	local region = bag_node.region;
	local class_map = {};
	local subclass_map = {};
	--只有一个值
	if(class)then
		class_map[class] = true;
	end
	--有多个值
	if(subclass)then
		local k,v;
		for k,v in ipairs(subclass) do
			subclass_map[v] = true;
		end
	end
	local function push(item)
		if(item and item.gsid)then
			local gsid = item.gsid;
			local guid = item.guid;
			local obtaintime = item.obtaintime;
			local can_push = false;
			if(self.IsInExcludeRegion(gsid,guid))then
				return false;
			end
			local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
			if(search_bag_all)then
				can_push = true;
			else
				if(gsItem)then
					--有指定目录
					if(category and gsItem.category)then
						if(category == gsItem.category)then
							can_push = true;
						end
					else
						local _class = gsItem.template.class;
						local _subclass = gsItem.template.subclass;
						if(_class and class_map[_class] and _subclass and subclass_map[_subclass])then
							if(card_school or gem_level)then
								local stats = gsItem.template.stats;
								if(card_school)then
									if(CommonClientService.IsRightSchool(gsid,card_school,136))then
										can_push = true;
									end
								end
								if(gem_level)then
							
									local _gem_level = stats[41];--宝石等级
									if(_gem_level and gem_level == _gem_level)then
										can_push = true;
									end
							
								end
							else
								can_push = true;
								if(region)then
									local k,v;
									for k,v in ipairs(region) do
										local from = v.gsid_from;
										local to = v.gsid_to;
										if(from and gsid < from)then
											can_push = false;
										end
										if(to and gsid > to)then
											can_push = false;
										end
									end							
								end
							end
						end
					end
				end
			end
			return can_push;
		end
	end
	if(is_myself)then
		local i;
		local cnt = ItemManager.GetItemCountInBag(bag);
		local result = {};
		for i = 1, cnt do
			local item = ItemManager.GetItemByBagAndOrder(bag, i);
			if(item and item.gsid)then
				local gsid = item.gsid;
				local guid = item.guid;
				local obtaintime = item.obtaintime;

				local can_push = push(item);
				if(can_push)then
					local node = {
						gsid = gsid,
						guid = guid,
						obtaintime = obtaintime,
					};	
					table.insert(result,node);
				end
			end
		end
		return result;
	else
		local i;
		local cnt = ItemManager.GetOPCItemCountInBag(nid,bag);
		local result = {};
		for i = 1, cnt do
			local item = ItemManager.GetOPCItemByBagAndOrder(nid,bag, i);
			if(item and item.gsid)then
				local gsid = item.gsid;
				local guid = item.guid;
				local obtaintime = item.obtaintime;

				local can_push = push(item);
				if(can_push)then
					local node = {
						gsid = gsid,
						guid = guid,
						obtaintime = obtaintime,
					};	
					table.insert(result,node);
				end
			end
		end
		return result;
	end

end
--[[
格式
local bag_list = {
	{
		search_bag_all = true, 
		card_school = card_school, 
		gem_level = gem_level, 
		bag = 1, class = 1, subclass = {1,2,3}, 
		region = {
			{ gsid_from = 10000, gsid_to = 20000,},
			{ gsid_from = gsid_from, gsid_to = gsid_to,},
		},
	},
	{
		search_bag_all = true, 
		card_school = card_school, 
		gem_level = gem_level, 
		bag = bag, class = class, subclass = subclass, 
		region = {
			{ gsid_from = gsid_from, gsid_to = gsid_to,},
			{ gsid_from = gsid_from, gsid_to = gsid_to,},
		},
	},
}
--]]
function BagHelper.SearchBagList(nid,bag_list,callbackFunc,cache_policy)
	local self = BagHelper;
	if(not bag_list)then return end
	local len = #bag_list;
	local result = {};
	local index = 0;

	local function do_search(finished_func)
		index = index + 1;
		local bag_node = bag_list[index];
		if(not bag_node)then
			if(finished_func)then
				finished_func();
			end
			return;
		else
			BagHelper.SearchBag(nid,bag_node,function(msg)
				if(msg and msg.item_list)then
					local k,v;
					for k,v in ipairs(msg.item_list) do
						table.insert(result,v);
					end
					do_search(finished_func)
				end
			end,cache_policy)
		end
	end
	do_search(function()
		if(callbackFunc)then
			callbackFunc({
				item_list = result,
			});
		end
	end)
end
function BagHelper.SearchBagList_Memory(nid,bag_list)
	local self = BagHelper;
	if(not bag_list)then return end
	local result = {};
	local k,bag_node;
	for k,bag_node in ipairs(bag_list) do
		local item_list = BagHelper.SearchBag_Memory(nid,bag_node);
		if(item_list)then
			local k,v;
			for k,v in ipairs(item_list) do
				table.insert(result,v);
			end
		end
	end
	return result; 
end
function BagHelper.Search_Memory(nid,folder_key,subfolder_key)
	local self = BagHelper;
	local bag_list = self.GetBagList(folder_key,subfolder_key);
	return self.SearchBagList_Memory(nid,bag_list);
end
function BagHelper.Search(nid,folder_key,subfolder_key,callbackFunc,cache_policy)
	local self = BagHelper;
	local bag_list = self.GetBagList(folder_key,subfolder_key);
	self.SearchBagList(nid,bag_list,callbackFunc,cache_policy);
end
--返回bag描述列表
--[[return 
local bag_list = {
	{
		search_bag_all = true, 
		card_school = card_school, 
		gem_level = gem_level, 
		bag = 1, class = 1, subclass = {1,2,3}, 
		region = {
			{ gsid_from = 10000, gsid_to = 20000,},
			{ gsid_from = gsid_from, gsid_to = gsid_to,},
		},
	},
	{
		search_bag_all = true, 
		card_school = card_school, 
		gem_level = gem_level, 
		bag = bag, class = class, subclass = subclass, 
		region = {
			{ gsid_from = gsid_from, gsid_to = gsid_to,},
			{ gsid_from = gsid_from, gsid_to = gsid_to,},
		},
	},
}
--]]
--@param folder_key:一级目录关键字 if nil then search all folder
--@param subfolder_key:二级目录关键字 if nil then search all subfolder
--@param source_bags:被搜索的数据源
function BagHelper.GetBagList(folder_key,subfolder_key,source_bags)
	local self = BagHelper;
	BagHelper.Load();
	source_bags = source_bags or self.bags;
	if(source_bags)then
		--search all
		if(folder_key == nil)then
			local k,folder;
			local result = {};
			for k,folder in pairs(source_bags) do
				local kk,subfolder;
				for kk,subfolder in pairs(folder) do
					local kkk,vvv;
					for kkk,vvv in ipairs(subfolder) do
						table.insert(result,vvv);
					end
				end 
			end
			return result;
		else
			local folder = source_bags[folder_key];
			if(folder)then
				--search all subfolder
				if(subfolder_key == nil)then
					local k,v;
					local result = {};
					for k,v in pairs(folder) do
						local kk,vv;
						for kk,vv in ipairs(v) do
							table.insert(result,vv);
						end
					end
					return result;
				else
					return folder[subfolder_key];
				end
			end
		end
	end
end
--获取0号包的描述
function BagHelper.GetZeroBagList()
	local self = BagHelper;
	local bag_list = {
		{
			search_bag_all = true, 
			bag = 0,
		},
	};
	return bag_list;
end
--把source数据加入到target里面
function BagHelper.PushTable(target,source)
	if(not target or not source)then
		return
	end
	local k,v;
	for k,v in ipairs(source) do
		table.insert(target,v);
	end
end
--gsid 是否在bag分类中
function BagHelper.IncludeGsid(bag_list,gsid)
	if(not bag_list or not gsid)then return end
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(gsItem)then
		local bag = gsItem.template.bagfamily;
		local class = gsItem.template.class;
		local subclass = gsItem.template.subclass;
		local k,v;
		for k,v in ipairs(bag_list) do
			if(v.bag == bag and v.class == class)then
				local __,_subclass;
				for __,_subclass in ipairs(v.subclass) do
					if(_subclass == subclass)then
						return true;
					end
				end
			end
		end
	end
end