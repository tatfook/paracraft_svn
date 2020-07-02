--[[
Title: 
Author(s): Leio
Date: 2010/12/11
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetProvider.lua");
local CombatPetProvider = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetProvider");
CombatPetProvider:LoadConfigFile()
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/ApparelTranslation/GemTranslationHelper.lua");
local GemTranslationHelper = commonlib.gettable("MyCompany.Aries.ApparelTranslation.GemTranslationHelper");
local Combat = commonlib.gettable("MyCompany.Aries.Combat");
NPL.load("(gl)script/kids/3DMapSystemItem/ItemManager.lua");
local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");
NPL.load("(gl)script/kids/3DMapSystemItem/PowerItemManager.lua");
local PowerItemManager = commonlib.gettable("Map3DSystem.Item.PowerItemManager");

-- create class
local CombatPetProvider = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetProvider");
CombatPetProvider.isremote = false;
CombatPetProvider.isteen = false;
CombatPetProvider.pets_map = nil;
CombatPetProvider.pets_xmlnode_map = nil;
--all_pets.xml
CombatPetProvider.all_pets_xmlnode_list = nil;
CombatPetProvider.all_pets_xmlnode_map = nil;

function CombatPetProvider:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end
function CombatPetProvider:GetFilePath()
	local config_path;
	local allpet_info;
	local config_path2;
	local config_stats_map;
	local config_addon_gem;
	if(self.isteen)then
		config_path = "config/Aries/Others/combatpet_levels.teen.xml";
		allpet_info = "config/Aries/Others/all_pets.teen.xml";
		config_path2 = "config/Aries/Others/combatpet_levels.excel.teen.xml";
		config_stats_map = "config/Aries/Others/combatpet_levels_properties.excel.teen.xml";
		config_addon_gem = nil;
	else
		config_path = "config/Aries/Others/combatpet_levels.xml";
		allpet_info = "config/Aries/Others/all_pets.xml";
		config_path2 = "config/Aries/Others/combatpet_levels.excel.xml";
		config_stats_map = "config/Aries/Others/combatpet_levels_properties.excel.xml";
		config_addon_gem = "config/Aries/Others/combatpet_addon_gem.xml";
	end
	return config_path,allpet_info, config_path2, config_stats_map, config_addon_gem;
end
-- { [101] = 35, [102] = 40, } + { [103] = 35, [102] = 40, }
function CombatPetProvider:AddTwoTable(map1,map2)
	map1 = map1 or {};
	map2 = map2 or {};
	local result = {};
	local k,v;
	for k,v in pairs(map1) do
		result[k] = v;
	end
	local k,v;
	for k,v in pairs(map2) do
		result[k] = v + (result[k] or 0);
	end
	return result;
end
--获取宝石附加的属性 和额外配置的总和
--return  { [101] = 35, [102] = 40, }
function CombatPetProvider:GetAddonProperties(gem_gsid)
	if(not gem_gsid)then return end
	if(self.addon_gem_map and self.valid_stats_map)then
		local gsItem = GemTranslationHelper.GetGlobalStoreItem(gem_gsid,self.isremote);
		if(gsItem)then
			local stat,node;
			for stat,node in pairs(self.addon_gem_map) do
				local value = gsItem.template.stats[stat];
				--找到对应的宝石类别 +HP or others
				if(value)then
					--宝石等级
					local level = gsItem.template.stats[41];
					if(level)then
						--附加属性
						local addon = node[level];
						if(addon)then
							local gem_addon = {};
							local k,__;
							for k,__ in pairs(self.valid_stats_map) do
								local v = (gsItem.template.stats[k] or 0) + (addon[k] or 0);
								if(v > 0)then
									gem_addon[k] = v;
								end
							end
							return gem_addon;
						end
					end
				end
			end
			
		end
	end
end
function CombatPetProvider:IsValidStat_AttachGem(stat)
	if(not stat)then return end
	if(self.addon_gem_map and self.addon_gem_map[stat])then
		return true;
	end
end
--加载配置文件
function CombatPetProvider:LoadConfigFile()
	local config_path,allpet_info, config_path2, config_stats_map,config_addon_gem = self:GetFilePath();

	if(config_addon_gem)then
		local valid_stats_map = {};
		--[[
			valid_stats_map = {
				[101] = true,[102] = true,
			};
		--]]
		local addon_gem_map = {};
		--[[
			addon_gem_map = {
				[101] = {
					[1] = { [101] = 35, [102] = 40, }
					[2] = { [101] = 35, [102] = 40, }
					[3] = { [101] = 35, [102] = 40, }
					[4] = { [101] = 35, [102] = 40, }
					[5] = { [101] = 35, [102] = 40, }
				},
				[102] = {
					[1] = { [101] = 35, [102] = 40, }
					[2] = { [101] = 35, [102] = 40, }
					[3] = { [101] = 35, [102] = 40, }
					[4] = { [101] = 35, [102] = 40, }
					[5] = { [101] = 35, [102] = 40, }
				},
			}
		--]]
		local xmlRoot = ParaXML.LuaXML_ParseFile(config_addon_gem);
		if(xmlRoot)then
			local item;
			for item in commonlib.XPath.eachNode(xmlRoot, "//root") do
				local valid_stats = item.attr["valid_stats"];
				if(valid_stats)then
					local stat_num;
					for stat_num in string.gfind(valid_stats, "[^,]+") do
						stat_num = tonumber(stat_num);
						valid_stats_map[stat_num] = stat_num;
					end
				end
				break;
			end

			local item;
			for item in commonlib.XPath.eachNode(xmlRoot, "//items") do
				local stat = tonumber(item.attr["stat"]);
				if(stat)then
					local node = {};
					addon_gem_map[stat] = node;
					local gem_item;
					for gem_item in commonlib.XPath.eachNode(item, "/gem") do
						if(gem_item)then
							local level = gem_item.attr["level"];
							level = tonumber(level);
							local value = self:GetTableIndexValue(gem_item,"addon");
							node[level] = value;
						end
					end	
				end
			end
			
		end
		self.valid_stats_map = valid_stats_map;
		self.addon_gem_map = addon_gem_map;
	end
	local xmlnode_list = {};
	local xmlnode_map = {};

	local xmlRoot = ParaXML.LuaXML_ParseFile(allpet_info);
	if(xmlRoot)then
		LOG.std(nil, "debug", "CombatPetProvider", "load config file:%s", allpet_info);
		local item;
		for item in commonlib.XPath.eachNode(xmlRoot, "//items/item") do
			if(item)then
				local gsid = item.attr["gsid"];
				--gsid is a number
				gsid = tonumber(gsid);
				if(gsid)then
					if(not xmlnode_map[gsid])then
						xmlnode_map[gsid] = item;
						table.insert(xmlnode_list,item);
					end
				end
			end
		end
	end
	self.xmlnode_list = xmlnode_list;
	self.xmlnode_map = xmlnode_map;


	-------------------------------------------------------
	-- read concise information from excel if provided. 
	-------------------------------------------------------
	NPL.load("(gl)script/ide/Document/ExcelDocReader.lua");
	local ExcelDocReader = commonlib.gettable("commonlib.io.ExcelDocReader");
	local reader = ExcelDocReader:new();

	-- schema is optional, which can change the row's keyname to the defined value. 
	reader:SetSchema({
		{name="level", type="number"},
		{name="exp", type="number"},
		{name=101, type="number" }, -- hp
		{name=if_else(System.options.version=="kids", 111, 151), type="number" }, -- attack
		{name=if_else(System.options.version=="kids", 119, 159), type="number" }, -- defense
		{name=102, type="number" },
		{name=103, type="number" },
		{name=196, type="number" }, -- critical attack
		{name=204, type="number" }, -- resillence
	})
	-- read from the second row
	if(reader:LoadFile(config_stats_map, 2)) then 
		local stats_map = {}; -- mapping from property stats to data. 
		local rows = reader:GetRows();
		local _, row
		for _, row in ipairs(rows) do
			if(row.level) then
				stats_map[row.level] = row
			end
		end
		self.stats_map = stats_map;
	end
	-------------------------------------------------------
	-- read concise information from excel if provided. 
	-------------------------------------------------------
	local rows_map = {}; -- mapping from gsid to excel data. 
	NPL.load("(gl)script/ide/Document/ExcelDocReader.lua");
	local ExcelDocReader = commonlib.gettable("commonlib.io.ExcelDocReader");
	local reader = ExcelDocReader:new();

	-- schema is optional, which can change the row's keyname to the defined value. 
	local function card_and_level_func(value)  
		if(value) then
			local level, card_gsid = value:match("^(%d+)[,:](%d+)");
			return {level=tonumber(level), card_gsid=tonumber(card_gsid)};
		end
	end

	local function custom_property(value)  
		if(value) then
			local fieldname, field_value = value:match("^(%d+)[,:](%d+)");
			if(fieldname) then
				return tonumber(field_value), tonumber(fieldname);
			else
				return tonumber(value);
			end
		end
	end

	reader:SetSchema({
		{name="gsid", type="number"},
		{name="displayname"},
		{name="max_level", type="number" },
		{name=101, type="number" }, -- "hp"
		{name = if_else(System.options.version=="kids", 111, 151), validate_func=custom_property }, -- "attack"
		{name = if_else(System.options.version=="kids", 119, 159), validate_func=custom_property }, -- "defense"
		{name=102, validate_func=custom_property }, -- "powerpips_rate"
		{name=103, validate_func=custom_property }, -- "accuracy"
		{name=196, validate_func=custom_property }, -- "critical_attack"
		{name=204, validate_func=custom_property }, -- "critical_block"
		{name=256, validate_func=custom_property }, -- "致命一击"
		{name="card1",  validate_func= card_and_level_func},
		{name="card2",  validate_func= card_and_level_func},
		{name="card3",  validate_func= card_and_level_func},
		{name="card4",  validate_func= card_and_level_func},
		{name="card5",  validate_func= card_and_level_func},
		{name="card6",  validate_func= card_and_level_func},
		{name="card7",  validate_func= card_and_level_func},
		{name="card8",  validate_func= card_and_level_func},
	})
	-- read from the second row
	if(reader:LoadFile(config_path2, 2)) then 
		local rows = reader:GetRows();
		-- echo(commonlib.serialize(rows, true));
		local _, row
		for _, row in ipairs(rows) do
			if(row.gsid) then
				row.order = _;
				rows_map[row.gsid] = row
			end
		end
	end

	------------------------------------------------
	-- now read original config file. 
	------------------------------------------------
	xmlRoot = ParaXML.LuaXML_ParseFile(config_path);
	local pets_map = {};
	local pets_xmlnode_map = {};
	
	if(xmlRoot)then
		LOG.std(nil, "debug", "CombatPetProvider", "load config file:%s", config_path);
		local item;
		local pIndex = 0;
		for item in commonlib.XPath.eachNode(xmlRoot, "//items/item") do
			if(item)then
				local gsid = item.attr["gsid"];
				--gsid is a number
				gsid = tonumber(gsid);
				if(gsid)then
					pIndex = pIndex + 1;
					if(not pets_map[gsid])then
						local p = self:GetProperties(item, rows_map[gsid]);
						if(p) then
							pets_map[gsid] = p;
							if(p)then
								p.pIndex = pIndex;
							end
							pets_xmlnode_map[gsid] = item;

							local max_exp = p.max_exp or 0;
							local debug_max_exp = p.debug_max_exp or 0;
							if(max_exp ~= debug_max_exp)then
								--LOG.std(nil, "warn", "CombatPetProvider", "gsid: %d 多了 %d EXP", gsid,(max_exp-debug_max_exp))
							end
						end
					end
				end
			end
		end
	end
	self.pets_map = pets_map;
	self.pets_xmlnode_map = pets_xmlnode_map;

	-- add rows that is not in the original xml list but appears in the concise excel list. 
	local index, row
	for index, row in pairs(rows_map) do
		if(row.gsid)then
			if(not pets_map[row.gsid]) then
				pets_map[row.gsid] = self:GetProperties(nil, row);
			end
		end
	end
end
----------------------------all_pets.xml
function CombatPetProvider:GetReadOnlyXmlNode()
	return self.xmlnode_list,self.xmlnode_map;
end
function CombatPetProvider:GetReadOnlyPetXmlNode(gsid)
	local node = self.xmlnode_map[gsid];
	return node;
end
----------------------------
--返回所有战宠的配置信息
--return:self.pets_map,self.pets_xmlnode_map
function CombatPetProvider:GetAllPets()
	return self.pets_map,self.pets_xmlnode_map
end
--重新设置数据源
function CombatPetProvider:SetAllPets(pets_map,pets_xmlnode_map)
	self.pets_map = pets_map or {};
	self.pets_xmlnode_map = pets_xmlnode_map or {};
end
--是否是战宠
--return: iscombat,isvip
function CombatPetProvider:IsCombatPet(gsid)
	gsid = tonumber(gsid);
	local p = self:GetPropertiesByID(gsid);
	if(p)then
		return true,p.isvip;
	end
end
--是否有宠物的记录
function CombatPetProvider:HasPet(gsid)
	local p = self:GetPropertiesByID(gsid);
	if(p)then
		return true;
	end
end
--获取战宠的只读属性
function CombatPetProvider:GetPropertiesByID(gsid)
	if(not gsid)then return end
	return self.pets_map[gsid];
end

-- get the standard value by level. 
-- @param fieldname: "exp", or one of the stats number, such as 101 for hp. 
function CombatPetProvider:GetStandardValue(fieldname, level)
	if(self.stats_map) then
		local value, stat_index;
		local row = self.stats_map[level];
		if(not row) then
			row = self.stats_map[#(self.stats_map)];
		end
		if(row) then
			if(fieldname == "exp")  then
				value = row.exp or 100;
			elseif(type(fieldname) == "number")  then
				value = row[fieldname];
				stat_index = fieldname;
			end
		end
		return value, stat_index;
	end
end

function CombatPetProvider:IsFood(gsid)
	if(not gsid)then
		return
	end
	if(gsid == 17172 or gsid == 17185 or gsid == 17211)then
		return true
	end
	if(self.all_foods and self.all_foods[gsid])then
		return true;
	end
end
function CombatPetProvider:GetProperties(node, row)
	row = row or {};
	if(not self.all_foods)then
		self.all_foods = {};
	end
	if(row.gsid or node) then
		local gsid = row.gsid or self:GetNumber(node,"gsid") or 0;
		local label = row.displayname or self:GetString(node,"label") or "";
		local school_requirement = row.school_requirement or self:GetString(node,"school_requirement") or "";
		local combatlevel_requirement = row.combatlevel_requirement or self:GetNumber(node,"combatlevel_requirement") or 0;
		local assetfile_full = row.assetfile_full or self:GetString(node,"assetfile_full") or "";
		local assetfile_senior_full = row.assetfile_senior_full or self:GetString(node,"assetfile_senior_full") or "";
		
		--战宠描述
		local desc = row.desc or self:GetString(node,"desc") or "";
		--推荐系别
		local school = row.school or self:GetString(node,"school") or "";
		--要求魔法星等级: -1 不要求, 0 魔法星等级为0并且有m值
		local req_magic_level = row.req_magic_level or self:GetNumber(node,"req_magic_level") or -1;
		local isvip = row.isvip or self:GetBoolean(node,"isvip");
		local append_items_gsid = row.append_items_gsid or self:GetString(node,"append_items_gsid") or "";
		local max_level = row.max_level or ((self:GetNumber(node,"max_level") or -1) + 1);
		local quality_level = row.quality_level or self:GetNumber(node,"quality_level") or 0;
		local quality = row.quality or self:GetNumber(node,"quality") or 0;
		local senior_quality = row.senior_quality or self:GetNumber(node,"senior_quality") or 0;--有进化等级才有效
		--debug
		local debug_max_exp = self:GetNumber(node,"max_exp") or 0;
		local k;
		--最大经验从每级的经验和计算
		local max_exp = 0;
		--每级成长经验
		local exp_level = {};
		if(row.max_level) then
			-- auto compute the max level. 
			for k = 1, max_level do
				local value = self:GetStandardValue("exp", k) or 100;
				exp_level[k] = value
				max_exp = max_exp + value;
				debug_max_exp = max_exp;
			end
		else
			for k = 1, max_level do
				local key = string.format("exp_level_%d",k);
				local value = self:GetNumber(node,key) or 0;
				exp_level[k] = value;
				max_exp = max_exp + value;
			end
		end

		--每级可以携带的卡片
		local append_card_level = {};
		if(row.max_level) then
			-- auto compute. 
			local level_card_map = {};
			for k= 1, 8 do
				local v = row["card"..tostring(k)];
				if(v and v.card_gsid and v.level) then
					level_card_map[v.level] = tostring(v.card_gsid)..","..(level_card_map[v.level] or "");
				end
			end
			local cards = {};
			for k = 1, max_level do
				if(level_card_map[k]) then
					cards = commonlib.copy(cards);
					local card_gsid;
					for card_gsid in string.gfind(level_card_map[k], "[^,]+") do
						card_gsid = tonumber(card_gsid);
						cards[#cards + 1] = card_gsid;
					end
				end
				append_card_level[k] = cards;
			end
		else
			for k = 1, max_level do
				local key = string.format("append_card_level_%d",k - 1);
				local value = self:GetTable(node,key) or "";
				append_card_level[k] = value;
			end
		end
		--每级可以附加的属性
		local append_prop_level = {};
		if(row.max_level) then
			local function add_prop(value_map, fieldname, level)
				if(row[fieldname]) then
					local std_fieldname = fieldname;
					local value_std_max, stat_index = self:GetStandardValue(std_fieldname, max_level);
					if(not value_std_max) then
						std_fieldname = if_else(System.options.version=="kids", 111, 151);
						value_std_max, stat_index = self:GetStandardValue(std_fieldname, max_level);
					end 

					if(stat_index and value_std_max) then
						local value_std = self:GetStandardValue(std_fieldname, level);
						if(value_std) then
							value_map[fieldname] = math.ceil(value_std*row[fieldname]/value_std_max);
						end
					else
						value_map[fieldname] = math.ceil(level/max_level);
					end
				end
			end
			for k = 1, max_level do
				local value_map = {};
				-- add all stat values whose key is number 
				local stat_number, _
				for stat_number, _ in pairs(row) do
					if(type(stat_number) == "number") then
						add_prop(value_map, stat_number, k);
					end
				end
				append_prop_level[k] = value_map;
			end
		else
			for k = 1, max_level do
				local key = string.format("append_prop_level_%d",k - 1);
				local value = self:GetTableIndexValue(node,key);
				append_prop_level[k] = value;
			end
		end
		--加经验提成 默认值,可以为空
		local add_exp_percent_default = self:GetNumber(node,"add_exp_percent_default") or 80;
		local add_exp_percent_level = {};
		if(not row.max_level) then
			for k = 1, max_level do
				local key = string.format("add_exp_percent_level_%d",k);
				local value = self:GetNumber(node,key) or 0;
				add_exp_percent_level[k] = value;
			end
		end
		--加经验最大 默认值,可以为空
		local add_exp_max_default = self:GetNumber(node,"add_exp_max_default") or 80;
		local add_exp_max_level = {};
		if(not row.max_level) then
			for k = 1, max_level do
				local key = string.format("add_exp_max_level_%d",k);
				--空为不限制
				local value = self:GetNumber(node,key);
				add_exp_max_level[k] = value;
			end
		end
		--战宠扩展等级------------------------------------------
		local senior_max_exp = 0;
		local senior_max_level = self:GetNumber(node,"senior_max_level") or -1;
		senior_max_level = senior_max_level + 1;
		--每级成长经验
		local senior_exp_level = {};
		for k = 1, senior_max_level do
			local key = string.format("senior_exp_level_%d",k);
			local value = self:GetNumber(node,key) or 0;
			senior_exp_level[k] = value;
			senior_max_exp = senior_max_exp + value;
		end
		--每级可以携带的卡片
		local senior_append_card_level = {};
		for k = 1, senior_max_level do
			local key = string.format("senior_append_card_level_%d",k - 1);
			local value = self:GetTable(node,key) or "";
			senior_append_card_level[k] = value;
		end
		--每级可以附加的属性
		local senior_append_prop_level = {};
		for k = 1, senior_max_level do
			local key = string.format("senior_append_prop_level_%d",k - 1);
			local value = self:GetTableIndexValue(node,key) or "";
			senior_append_prop_level[k] = value;
		end
		--扩展等级可以长经验的物品
		local senior_gsid = self:GetTable(node,"senior_gsid");
		if(senior_gsid)then
			local k,v;
			for k,v in ipairs(senior_gsid) do
			self.all_foods[v] = v;
			end
		end
		------------------------------------------------------
		local exp_level_list = self:GetGirdviewList_exp_level(exp_level);
		local append_card_level_list = self:GetGirdviewList_append_card_level(append_card_level);
		local append_prop_level_list = self:GetGirdviewList_append_prop_level(append_prop_level);
		local combine_props_list = self:GetGirdviewList_Combine_Props_Cards(max_level,append_prop_level_list,append_card_level_list);

		local senior_exp_level_list = self:GetGirdviewList_exp_level(senior_exp_level);
		local senior_append_card_level_list = self:GetGirdviewList_append_card_level(senior_append_card_level);
		local senior_append_prop_level_list = self:GetGirdviewList_append_prop_level(senior_append_prop_level);
		local senior_combine_props_list = self:GetGirdviewList_Combine_Props_Cards(senior_max_level,senior_append_prop_level_list,senior_append_card_level_list);

		local senior_gsid_str = self:Get_Gsid_Info(senior_gsid);
		--战宠出现地点------------------------------------------
		local place_list = self:GetPlaceList(gsid);
		------------------------------------------------------
		local r = {
			desc = desc,
			school = school,
			gsid = gsid,
			label = label,
			school_requirement = school_requirement,
			combatlevel_requirement = combatlevel_requirement,
			isvip = isvip,
			max_exp = max_exp,
			max_level = max_level,
			exp_level = exp_level,
			append_card_level = append_card_level,
			append_prop_level = append_prop_level,
			order =  row.order,

			--方便gridview显示
			exp_level_list = exp_level_list,
			append_card_level_list = append_card_level_list,
			append_prop_level_list = append_prop_level_list,
			combine_props_list = combine_props_list,

			--加经验提成 默认值
			add_exp_percent_default = add_exp_percent_default,
			add_exp_percent_level = add_exp_percent_level,
			add_exp_max_default = add_exp_max_default,
			add_exp_max_level = add_exp_max_level,
			req_magic_level = req_magic_level,
			quality_level = quality_level,
			quality = quality,--品质
			senior_quality = senior_quality,--进化后的品质

			debug_max_exp = debug_max_exp,

			--战宠扩展等级属性
			senior_max_exp = senior_max_exp,
			senior_max_level = senior_max_level,
			senior_exp_level = senior_exp_level,
			senior_append_card_level = senior_append_card_level,
			senior_append_prop_level = senior_append_prop_level,
			senior_gsid = senior_gsid,
			--方便gridview显示
			senior_exp_level_list = senior_exp_level_list,
			senior_append_card_level_list = senior_append_card_level_list,
			senior_append_prop_level_list = senior_append_prop_level_list,
			senior_combine_props_list = senior_combine_props_list,

			senior_gsid_str = senior_gsid_str,
			place_list = place_list,--出现地点

			assetfile_full = assetfile_full,
			assetfile_senior_full = assetfile_senior_full,
		};
		return r;
	end
end
--战宠处于高级成长阶段
function CombatPetProvider:Locate_SeniorLevel(gsid,cur_exp)
	if(self:HasSeniorLevel(gsid))then
		local cur_level,nextlevel_exp,nextlevel_total_exp,isfull = self:GetLevelInfo(gsid,cur_exp)
		return isfull;
	end
end
--战宠总经验  包括普通阶段和高级阶段
function CombatPetProvider:GetTotalExp(gsid)
	if(not gsid)then return end
	local p = self:GetPropertiesByID(gsid);
	if(p)then
		local max_exp = p.max_exp or 0;
		local senior_max_exp = p.senior_max_exp or 0;
		local v = max_exp + senior_max_exp;
		return v;
	end
	return 0;
end
--是否是扩展等级可以吃的食物
function CombatPetProvider:IsSeniorFoodGsid(pet_gsid,gsid)
	if(not gsid)then return end
	local p = self:GetPropertiesByID(pet_gsid);
	if(p and p.senior_gsid)then
		local k,v;
		for k,v in ipairs(p.senior_gsid) do
			if(gsid == v)then
				return true;
			end
		end
	end	
end
--是否具有扩展等级
function CombatPetProvider:HasSeniorLevel(gsid)
	if(not gsid)then return end
	local p = self:GetPropertiesByID(gsid);
	if(p)then
		local senior_max_level = p.senior_max_level;
		if(senior_max_level and senior_max_level > 0)then
			return true;
		end
	end	
end
--获取扩展等级信息
--返回当前级别和 下一级经验信息
--@param gsid:宠物gsid
--@param cur_exp:宠物总经验
--return: cur_level,nextlevel_exp,nextlevel_total_exp,isfull
function CombatPetProvider:GetSeniorLevelInfo(gsid,cur_exp)
	if(not self:HasSeniorLevel(gsid))then
		return -1;
	end
	local cur_level,nextlevel_exp,nextlevel_total_exp,isfull = self:GetLevelInfo(gsid,cur_exp);
	if(isfull)then
		local p = self:GetPropertiesByID(gsid);
		if(p and cur_exp)then
			cur_exp = cur_exp - p.max_exp;
			local max_exp = p.senior_max_exp;
			local max_level = p.senior_max_level;
			local exp_level = p.senior_exp_level;
			if(cur_exp >= max_exp)then
				local isfull = true;
				return max_level,0,0,isfull;
			end
			local _exp_1 = 0
			local _exp_2 = cur_exp;
			local k;
			for k = 1, max_level do
				local exp = exp_level[k];
				_exp_2 = _exp_2 - exp;
				if(_exp_2 == 0)then
					return k,0,exp_level[k+1];
				elseif(_exp_2 < 0)then
					return k - 1,(cur_exp - _exp_1),exp_level[k];
				else
					_exp_1 = _exp_1 + exp
				end
			end
		end
		return -1;
	end
	return -1;
end
--返回当前级别和 下一级经验信息
--return: cur_level,nextlevel_exp,nextlevel_total_exp,isfull
function CombatPetProvider:GetLevelInfo(gsid,cur_exp)
	local p = self:GetPropertiesByID(gsid);
	cur_exp = cur_exp or 0;
	if(p and cur_exp)then
		local max_exp = p.max_exp;
		local max_level = p.max_level;
		local exp_level = p.exp_level;
		if(cur_exp >= max_exp)then
			local isfull = true;
			return max_level,0,0,isfull;
		end
		local _exp_1 = 0
		local _exp_2 = cur_exp;
		local k;
		for k = 1, max_level do
			local exp = exp_level[k];
			_exp_2 = _exp_2 - exp;
			if(_exp_2 == 0)then
				return k,0,exp_level[k+1];
			elseif(_exp_2 < 0)then
				return k - 1,(cur_exp - _exp_1),exp_level[k];
			else
				_exp_1 = _exp_1 + exp
			end
		end
		return -1;
	end
	return -1;
end
--获取战宠出现地点的列表 
--格式{gsid = gsid,label = label}
function CombatPetProvider:GetPlaceList(gsid)
	if(not gsid)then return end
	local xmlnode = self:GetReadOnlyPetXmlNode(gsid);
	local list = {};
	if(xmlnode)then
		local textbuffer;
        local place;
		local index = 1;
        for place in commonlib.XPath.eachNode(xmlnode, "//places/place") do
			local label = place[1];
			if(label)then
				table.insert(list,{gsid = gsid,label = label});
			end
        end
    end
	return list;
end
function CombatPetProvider:GetNumber(node,key)
	if(node and key)then
		local v = node.attr[key];
		v = tonumber(v);
		return v;
	end
end
function CombatPetProvider:GetString(node,key)
	if(node and key)then
		local v = node.attr[key];
		if(v)then
			v = tostring(v);
			return v;
		end
	end
end
function CombatPetProvider:GetBoolean(node,key)
	if(node and key)then
		local v = node.attr[key];
		v = tostring(v);
		if(v)then
			v = string.lower(v);
			if(v == "true")then
				return true;
			else
				return false;
			end
		end
	end
	return false;
end
--"20,21" to {20,21}
function CombatPetProvider:GetTable(node,key)
	local t = {};
	if(node and key)then
		local v = node.attr[key];
		v = tostring(v);
		if(v)then
			local section
			for section in string.gfind(v, "[^,]+") do
				section = tonumber(section);
				table.insert(t,section);
			end
		end
	end
	return t;
end
--102:5,103:10 to {[102] = 5, [103] = 10}
function CombatPetProvider:GetTableIndexValue(node,key)
	local t = {};
	if(node and key)then
		local v = node.attr[key];
		v = tostring(v);
		if(v)then
			local section
			for section in string.gfind(v, "[^,]+") do
				local index,value = string.match(section,"(.+):(.+)");
				index = tonumber(index);
				value = tonumber(value);
				if(index and value)then
					t[index] = value;
				end
			end
		end
	end
	return t;
end
--转换成gridview显示的格式{level = level, props_table = props_table, props_str = props_str, cards_table = cards_table, cards_str = cards_str,}
function CombatPetProvider:GetGirdviewList_Combine_Props_Cards(max_level,append_prop_level,append_card_level)
	local combine_list = {};
	for k = 1,max_level+1 do
		local prop_node = append_prop_level[k];
		local node = {};
		if(prop_node)then
			node.props_table = prop_node.props_table;
			node.props_str = prop_node.props_str;
			node.props_serialize = prop_node.props_serialize;
		end
		local card_node = append_card_level[k];
		if(card_node)then
			node.cards_table = card_node.cards_table;
			node.cards_str = card_node.cards_str;
			node.cards_serialize = card_node.cards_serialize;
		end
		node.level = k - 1;
		table.insert(combine_list,node);
	end
	return combine_list;
end
--转换成gridview显示的格式
function CombatPetProvider:GetGirdviewList_exp_level(exp_level)
	local exp_level_list = {};
	if(exp_level)then
		local k,v;
		for k,v in ipairs(exp_level) do
			table.insert(exp_level_list,{level = k, exp = v})
		end
	end  
	return exp_level_list;
end
--转换成gridview显示的格式
function CombatPetProvider:GetGirdviewList_append_card_level(append_card_level)
	local append_card_level_list = {};
	if(append_card_level)then
		local k,v;
		for k,v in ipairs(append_card_level) do
			table.insert(append_card_level_list,{level = k - 1, cards_table = v, cards_str = self:Get_Gsid_Info(v),cards_serialize = commonlib.serialize(v)})
		end
	end
	return append_card_level_list;
end
--转换成gridview显示的格式
function CombatPetProvider:GetGirdviewList_append_prop_level(append_prop_level)
	local append_prop_level_list = {};
	if(append_prop_level)then
		local k,v;
		for k,v in ipairs(append_prop_level) do
			table.insert(append_prop_level_list,{level = k - 1, props_table = v, props_str = self:Get_Props_Info(v),props_serialize = commonlib.serialize(v)})
		end
	end
	return append_prop_level_list;
end
function CombatPetProvider:Get_Gsid_Info(t)
   local s="";
    if(t)then
        local k,v;
        for k,v in ipairs(t) do
            local gsItem = ItemManager.GetGlobalStoreItemInMemory(v);
            if(gsItem)then
                local  path = string.format("%s;0 0 45 44",gsItem.descfile);
                local str = string.format([[<pe:item gsid="%d"  isclickable="false" style="float:left;margin-left:2px;width:36px;height:36px;"/>]],v,path);
                s = s .. str;
            end
        end
    end
    s = string.format([[<div style="float:left;">%s</div>]],s);
    return s;
end
function CombatPetProvider:Get_Props_List(t)
	if(t)then
		local props_list = {};
		local k,v;
        for k,v in pairs(t) do
            local label = Combat.GetStatWord_OfTypeValue(k,v);
			table.insert(props_list,{stat_id = k, value = v, label = label,});
		end
		table.sort(props_list,function(a,b)
			return a.stat_id < b.stat_id;
		end);
		return props_list
	end
end
function CombatPetProvider:Get_Cards_List(t)
	if(t)then
		local cards_list = {};
		local k,gsid;
        for k,gsid in pairs(t) do
			table.insert(cards_list,{gsid = gsid, });
		end
		table.sort(cards_list,function(a,b)
			return a.gsid < b.gsid;
		end);
		return cards_list
	end
end
--@param t:数据源
--@param split:分隔符 或者"is_mcml"
function CombatPetProvider:Get_Props_Info(t,split,width,height,margintop)
    local s="";
	split = split or ","
    if(t)then
		local props_list = {};
		local k,v;
        for k,v in pairs(t) do
			table.insert(props_list,{stat_id = k, value = v});
		end
		table.sort(props_list,function(a,b)
			return a.stat_id < b.stat_id;
		end);
        local k,v;
        for k,v in ipairs(props_list) do
            local str = Combat.GetStatWord_OfTypeValue(v.stat_id,v.value);
            if(str)then
				if(split == "is_mcml")then
					str = string.format([[<div style="width:%dpx;height:%dpx;margin-top:%dpx;" class="textfieldbutton">%s</div>]],width,height,margintop,str);
					s = s .. str;
				else 
					if(s=="")then
						s = s .. str;
					else
						s = s ..split.. str;
					end
				end
            end
        end
    end

    s = string.format([[<div style="float:left;">%s</div>]],s);
    return s;
end
--返回当前级别所带的卡片
--return {20,21,22}
function CombatPetProvider:GetCurLevelCards_FollowingPet()
	local item = ItemManager.GetMyCurrentFollowPetItemOnEquip();
    if(item and item.guid > 0) then
        local serverdata = item:GetServerData();
		local exp = serverdata.exp;
		return self:GetCurLevelCards(item.gsid,exp);
	end
end
--返回当前级别所带的卡片
--return {20,21,22}
function CombatPetProvider:GetCurLevelCards(gsid,exp)
	if(not gsid)then return end
	exp = exp or 0;
	local p = self:GetPropertiesByID(gsid);
	if(p)then
		local cur_level,nextlevel_exp,nextlevel_total_exp,isfull = self:GetLevelInfo(gsid,exp)
		local append_card_level = p.append_card_level or {};
		
		--普通成长
		local value;
		if(cur_level and cur_level >=0)then
			if(isfull)then
				value = append_card_level[cur_level];
			else
				value = append_card_level[cur_level + 1];
			end
		end
        if(isfull and self:HasSeniorLevel(gsid))then
			--高级成长
			local senior_append_card_level = p.senior_append_card_level or {};
			cur_level,nextlevel_exp,nextlevel_total_exp,isfull = self:GetSeniorLevelInfo(gsid,exp)
			if(cur_level and cur_level >=0)then
				if(isfull)then
					value = senior_append_card_level[cur_level];
				else
					value = senior_append_card_level[cur_level + 1];
				end
			end	
		end
		return value;
	end
end
--当前携带的宠物的附加属性
--return { [102]=5, [103]=10,}
function CombatPetProvider:GetCurLevelProps_FollowingPet()
	local item = ItemManager.GetMyCurrentFollowPetItemOnEquip();
    if(item and item.guid > 0) then
        local serverdata = item:GetServerData();
		local exp = serverdata.exp;
		return self:GetCurLevelProps(item.gsid,exp);
	end
end
function CombatPetProvider:GetAssetFileFromGSIDandAssetID(gsid,id)
	if(not gsid)then return end
	local p = self:GetPropertiesByID(gsid);
	id = id or 0;
	local assetfile = "";
	local gsItem = GemTranslationHelper.GetGlobalStoreItem(gsid,self.isremote);
	if(gsItem)then
		assetfile = gsItem.assetfile;
	end
	if(p)then
		if(id == 1 and p.assetfile_full and p.assetfile_full ~= "")then
			assetfile = p.assetfile_full;
		end
		if(id == 2 and p.assetfile_senior_full and p.assetfile_senior_full ~= "")then
			assetfile = p.assetfile_senior_full;
		end	
	end
	return assetfile;
end
--返回当前级别的形象的编号 0(默认) or 1(满级) or 2(进化满级)
function CombatPetProvider:GetCurLevelAssetID(gsid,exp)
	if(not gsid)then return end
	exp = exp or 0;
	local p = self:GetPropertiesByID(gsid);
	local id = 0;
	if(p)then
		local cur_level,nextlevel_exp,nextlevel_total_exp,isfull = self:GetLevelInfo(gsid,exp)
		if(isfull)then
			id = 1;
		end
        if(self:HasSeniorLevel(gsid))then
			--高级成长
			cur_level,nextlevel_exp,nextlevel_total_exp,isfull = self:GetSeniorLevelInfo(gsid,exp)
				if(isfull)then
					id = 2;
				end	
		end
	end
	return id;
end
--返回当前级别的形象
function CombatPetProvider:GetCurLevelAssetFile(gsid,exp)
	if(not gsid)then return end
	exp = exp or 0;
	local p = self:GetPropertiesByID(gsid);
	local assetfile = "";
	local gsItem = GemTranslationHelper.GetGlobalStoreItem(gsid,self.isremote);
	if(gsItem)then
		assetfile = gsItem.assetfile;
	end
	if(p)then
		local cur_level,nextlevel_exp,nextlevel_total_exp,isfull = self:GetLevelInfo(gsid,exp)
		if(isfull and p.assetfile_full and p.assetfile_full ~= "")then
			assetfile = p.assetfile_full;
		end
        if(self:HasSeniorLevel(gsid))then
			--高级成长
			cur_level,nextlevel_exp,nextlevel_total_exp,isfull = self:GetSeniorLevelInfo(gsid,exp)
				if(isfull and p.assetfile_senior_full and p.assetfile_senior_full ~= "")then
					assetfile = p.assetfile_senior_full;
				end	
		end
	end
	return assetfile;
end
--返回当前级别所带的附加属性
--return { [102]=5, [103]=10,}
function CombatPetProvider:GetCurLevelProps(gsid,exp)
	if(not gsid)then return end
	exp = exp or 0;
	local p = self:GetPropertiesByID(gsid);
	if(p)then
		local cur_level,nextlevel_exp,nextlevel_total_exp,isfull = self:GetLevelInfo(gsid,exp)
		local append_prop_level = p.append_prop_level or {};
		
		--普通成长
		local value;
		if(cur_level and cur_level >=0)then
			if(isfull)then
				value = append_prop_level[cur_level];
			else
				value = append_prop_level[cur_level + 1];
			end
		end
        if(isfull and self:HasSeniorLevel(gsid))then

			--高级成长
			local senior_append_prop_level = p.senior_append_prop_level or {};
			cur_level,nextlevel_exp,nextlevel_total_exp,isfull = self:GetSeniorLevelInfo(gsid,exp)
			if(cur_level and cur_level >=0)then
				if(isfull)then
					value = senior_append_prop_level[cur_level];
				else
					value = senior_append_prop_level[cur_level + 1];
				end
			end	
		end
		return value;
	end
end
--获取宠物大全中 最高等级附带的卡片列表
function CombatPetProvider:GetTemplateMaxLevelCards(gsid)
	if(not gsid)then return end
	local p = self:GetPropertiesByID(gsid);
	if(p)then
		if(self:HasSeniorLevel(gsid))then
			local senior_append_card_level = p.senior_append_card_level;
			local senior_max_level = p.senior_max_level;
			return senior_append_card_level[senior_max_level];
		else
			local append_card_level = p.append_card_level;
			local max_level = p.max_level;
			return append_card_level[max_level];
		end
	end
end
--获取宠物大全中 最高等级附加属性
function CombatPetProvider:GetTemplateMaxLevelProps(gsid)
	if(not gsid)then return end
	local p = self:GetPropertiesByID(gsid);
	if(p)then
		if(self:HasSeniorLevel(gsid))then
			local senior_append_prop_level = p.senior_append_prop_level;
			local senior_max_level = p.senior_max_level;
			return senior_append_prop_level[senior_max_level];
		else
			local append_prop_level = p.append_prop_level;
			local max_level = p.max_level;
			return append_prop_level[max_level];
		end
	end
end
--获取推荐地点的描述
function CombatPetProvider:GetPlace(gsid,place_index)
	if(not gsid)then return end
	place_index = place_index or 1;
	local xmlnode = self:GetReadOnlyPetXmlNode(gsid);
    if(xmlnode)then
		local textbuffer;
        local place;
		local index = 1;
        for place in commonlib.XPath.eachNode(xmlnode, "//places/place") do
			if(index == place_index)then
				return place[1] or "";
			end
			index = index + 1;
        end
    end
end
function CombatPetProvider:DoTrack(gsid)
	if(not gsid)then return end
	NPL.load("(gl)script/apps/Aries/HaqiShop/ItemGuides.lua");
	local ItemGuides = commonlib.gettable("MyCompany.Aries.ItemGuides");
	local guides = ItemGuides.BuildGuideDataSourceForItem(gsid);
	if(guides) then
		-- teleport to the first one in the item guides.
		local node = commonlib.XPath.selectNode(guides, "//catchpet") or commonlib.XPath.selectNode(guides, "//loot");
							
		if(node and node.attr) then
			local t = node.attr;
			local worldname= t.worldname;
			local _, position,camera = MyCompany.Aries.Combat.MsgHandler.GetArenaTeleportPosByCenter(t.x, t.y, t.z);
			if(position) then
				local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
				WorldManager:GotoWorldPosition(worldname,position,camera,nil, function()
					-- TODO: close page
				end);
			end
		else
			_guihelper.MessageBox("系统无法自动找到这个宠物, 自己去探索下吧～");
		end
	end
end
function CombatPetProvider:IsFollowPet(gsid)
	if(not gsid)then
		return
	end
	local gsItem = GemTranslationHelper.GetGlobalStoreItem(gsid);
	if(gsItem)then
		local bagfamily = gsItem.template.bagfamily;
		if(bagfamily == 10010)then
			return true;
		end
	end
end
local colour_map = 
{
	[0] = "#ffffff",
	[1] = "#00cc33",
	[2] = "#0099ff",
	[3] = "#c648e1",
	[4] = "#ff9a00",
};
function CombatPetProvider:GetTemplateColorName(gsid)
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	local pet_name;
	if(gsItem) then
		pet_name = gsItem.template.name;
		local cur_quality_pet_name,max_quality_pet_name = self:BuildColorName(pet_name,gsid,0);
		return max_quality_pet_name;
	end
end
--return cur_quality_pet_name,max_quality_pet_name;
function CombatPetProvider:BuildColorName(pet_name,gsid,exp)
	exp = exp or 0;
	if(not pet_name or not gsid)then
		return
	end
	local cur_quality,max_quality = self:GetQualityAndMaxQuality(gsid,exp)
	local cur_quality_pet_name = string.format([[<div style="color:%s">%s</div>]],colour_map[cur_quality],pet_name);
	local max_quality_pet_name = string.format([[<div style="color:%s">%s</div>]],colour_map[max_quality],pet_name);
	return cur_quality_pet_name,max_quality_pet_name;
end
--获取品质
--return cur_quality,max_quality;
function CombatPetProvider:GetQualityAndMaxQuality(gsid,exp)
	local p = self:GetPropertiesByID(gsid);
	local cur_quality;
	local max_quality;
	if(p)then
		local state = self:GetGrownState(gsid,exp);
		if(state == "junior")then
			cur_quality = p.quality;
		else
			cur_quality = p.senior_quality;
		end
		max_quality = math.max(p.quality,p.senior_quality);
	end
	return cur_quality or 0,max_quality or 0;
end
function CombatPetProvider:GetGrownState_FollowingPet()
	local item = ItemManager.GetMyCurrentFollowPetItemOnEquip();
    if(item and item.guid > 0) then
        local serverdata = item:GetServerData();
		local exp = serverdata.exp;
		return self:GetGrownState(item.gsid,exp);
	end
end
--返回我的宠物 成长阶段 "junior" or "senior"
function CombatPetProvider:GetGrownState(gsid,exp)
    local state = "junior"
    if(self:Locate_SeniorLevel(gsid,exp))then
        state = "senior"
    end
    return state;
end
--根据成长阶段 返回等级
function CombatPetProvider:GetLevel(gsid,exp)
    local p = self:GetPropertiesByID(gsid);
    if(p)then
		local level,cur_exp,total_exp,isfull = self:GetLevelInfo(gsid,exp or 0);
        if(isfull and self:HasSeniorLevel(gsid))then
			level,cur_exp,total_exp,isfull = self:GetSeniorLevelInfo(gsid,exp or 0);
		end
		--TODO:最高级索引错误
		if(isfull)then
			level = level - 1;
		end
        return level,isfull;
    end
end
function CombatPetProvider:GetLevel_FollowingPet()
	local item = ItemManager.GetMyCurrentFollowPetItemOnEquip();
    if(item and item.guid > 0) then
        local serverdata = item:GetServerData();
		local exp = serverdata.exp;
		return self:GetLevel(item.gsid,exp);
	end
end
--return level,cur_exp,total_exp,isfull,state,state_str
function CombatPetProvider:IsFull(gsid,exp)
	local p = self:GetPropertiesByID(gsid);
    if(p)then
		local state = self:GetGrownState(gsid,exp);
		local state_str;
		if(state == "senior")then
			state_str = "进化";
		else
			state_str = "成长";
		end
		local level,cur_exp,total_exp,isfull = self:GetLevelInfo(gsid,exp or 0);
        if(isfull and self:HasSeniorLevel(gsid))then
			level,cur_exp,total_exp,isfull = self:GetSeniorLevelInfo(gsid,exp or 0);
		end
		
		return level,cur_exp,total_exp,isfull,state,state_str;
    end
end