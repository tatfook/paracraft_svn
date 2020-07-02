--[[
Title: 
Author(s): Leio
Date: 2013/3/5
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetConfig.lua");
local CombatPetConfig = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetConfig");
local pet_config = CombatPetConfig.GetInstance_Client();
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/ApparelTranslation/GemTranslationHelper.lua");
local GemTranslationHelper = commonlib.gettable("MyCompany.Aries.ApparelTranslation.GemTranslationHelper");
NPL.load("(gl)script/ide/Document/ExcelDocReader.lua");
	local ExcelDocReader = commonlib.gettable("commonlib.io.ExcelDocReader");
-- create class
local CombatPetConfig = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetConfig");
CombatPetConfig.auto_index = 0;
CombatPetConfig.instance_map = {};
CombatPetConfig.isteen = true;
CombatPetConfig.isremote = false;
CombatPetConfig.rows_map = {};
CombatPetConfig.template_map = {};--初始属性模板
CombatPetConfig.row_template = {};
function CombatPetConfig.AutoIndex()
	CombatPetConfig.auto_index = CombatPetConfig.auto_index + 1;
	return CombatPetConfig.auto_index;
end
CombatPetConfig.sort_priority = {
	[101] = CombatPetConfig.AutoIndex(),
	[102] = CombatPetConfig.AutoIndex(),
	[196] = CombatPetConfig.AutoIndex(),
	[204] = CombatPetConfig.AutoIndex(),
	[243] = CombatPetConfig.AutoIndex(),
	[188] = CombatPetConfig.AutoIndex(),
	[182] = CombatPetConfig.AutoIndex(),
	[152] = CombatPetConfig.AutoIndex(),
	[153] = CombatPetConfig.AutoIndex(),
	[154] = CombatPetConfig.AutoIndex(),
	[157] = CombatPetConfig.AutoIndex(),
	[156] = CombatPetConfig.AutoIndex(),
	[151] = CombatPetConfig.AutoIndex(),
	[155] = CombatPetConfig.AutoIndex(),
	[160] = CombatPetConfig.AutoIndex(),
	[161] = CombatPetConfig.AutoIndex(),
	[162] = CombatPetConfig.AutoIndex(),
	[165] = CombatPetConfig.AutoIndex(),
	[164] = CombatPetConfig.AutoIndex(),
	[159] = CombatPetConfig.AutoIndex(),
	[163] = CombatPetConfig.AutoIndex(),
}
function CombatPetConfig.GetInstance_Client()
	return CombatPetConfig.GetInstance("Client",true,false);
end
function CombatPetConfig.GetInstance_Server(isteen)
	return CombatPetConfig.GetInstance("Server",isteen,true);
end
function CombatPetConfig.GetInstance(name,isteen,isremote)
	name = name or "CombatPetConfig.GetInstance";
	if(System.options.version == "teen") then
		isteen = true;
	else
		isteen = false;
	end
	if(not CombatPetConfig.instance_map[name])then
		local config = CombatPetConfig:new({
			isteen = isteen,
			isremote = isremote,
		})
		config:Load();
		CombatPetConfig.instance_map[name] = config;
	end
	return CombatPetConfig.instance_map[name];
end
function CombatPetConfig:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	o:OnInit()
	return o
end
function CombatPetConfig:OnInit()
	self.rows_map = {};
	self.template_map = {};
	self.row_template = {};
	self.all_foods = {};
	self.levels_info_map = {};
end
function CombatPetConfig:GetFilePath()
	local root_path;
	local config_path;
	local place_path;
	if(self.isteen)then
		root_path = "config/Aries/CombatPet_Teen/";
		config_path = "config/Aries/CombatPet_Teen/properties.xml";
		place_path = "config/Aries/CombatPet_Teen/places.csv";
	end
	return root_path,config_path,place_path;
end
function CombatPetConfig:Load_CommonTemplate(path)
	if(not path)then return end
	local reader = ExcelDocReader:new();
	reader:SetSchema({
		{name="levels", type="string"},
		{name="exp_percent", type="number"},
		{name="get_max_exp", type="number"},
		{name="entity_stat_101", type="string"},
		{name="entity_stat_102", type="string"},
		{name="entity_stat_196", type="string"},
		{name="entity_stat_204", type="string"},
		{name="entity_stat_243", type="string"},
		{name="entity_stat_188", type="string"},
		{name="entity_stat_182", type="string"},
		{name="entity_stat_152", type="string"},
		{name="entity_stat_153", type="string"},
		{name="entity_stat_154", type="string"},
		{name="entity_stat_157", type="string"},
		{name="entity_stat_156", type="string"},
		{name="entity_stat_151", type="string"},
		{name="entity_stat_155", type="string"},
		{name="entity_stat_160", type="string"},
		{name="entity_stat_161", type="string"},
		{name="entity_stat_162", type="string"},
		{name="entity_stat_165", type="string"},
		{name="entity_stat_164", type="string"},
		{name="entity_stat_159", type="string"},
		{name="entity_stat_163", type="string"},
	})
	if(reader:LoadFile(path, 2)) then 
		local rows = reader:GetRows();
		if(rows)then
			return rows[2];
		end
	end
end
function CombatPetConfig:Load()
	local root_path,config_path,place_path = self:GetFilePath();
	if(not root_path or not config_path or not place_path)then
		return
	end
	local file = ParaIO.open(place_path, "r");
	local place_map = {};--出现地点
	if(file:IsValid()) then

		line = file:readline();
		while(line) do
			local arr = commonlib.split(line,",");
			local name = arr[1];
			local gsid = tonumber(arr[2]);
			local place = arr[3];
			if(gsid)then
				place_map[gsid] = {
					name = name,
					gsid = gsid,
					place = place,
				}	
			end
			line = file:readline();
		end
		file:close();
	end
	local reader = ExcelDocReader:new();
	reader:SetSchema({
		{name="label", type="string"},
		{name="gsid", type="number"},
		{name="school", type="number"},
		{name="quality", type="number"},
		{name="locale", type="string"},
		{name="quality_level", type="number"},
		{name="req_magic_level", type="number"},
		{name="max_level", type="number"},
		{name="start_evolve_level", type="number"},
		{name="evolve_foods", type="string"},
		{name="evolve_assets", type="string"},
		{name="common_template", type="string"},
		{name="places", type="string"},
		{name="entity_stat_101", type="string"},
		{name="entity_stat_102", type="string"},
		{name="entity_stat_196", type="string"},
		{name="entity_stat_204", type="string"},
		{name="entity_stat_243", type="string"},
		{name="entity_stat_188", type="string"},
		{name="entity_stat_182", type="string"},
		{name="entity_stat_152", type="string"},
		{name="entity_stat_153", type="string"},
		{name="entity_stat_154", type="string"},
		{name="entity_stat_157", type="string"},
		{name="entity_stat_156", type="string"},
		{name="entity_stat_151", type="string"},
		{name="entity_stat_155", type="string"},
		{name="entity_stat_160", type="string"},
		{name="entity_stat_161", type="string"},
		{name="entity_stat_162", type="string"},
		{name="entity_stat_165", type="string"},
		{name="entity_stat_164", type="string"},
		{name="entity_stat_159", type="string"},
		{name="entity_stat_163", type="string"},
		{name="entity_cards", type="string"},
		{name="stat_scale", type="number"},
		{name="cards", type="string"},
	})
	local rows_map = {}; -- mapping from gsid to excel data. 
	local template_map = {};
	local all_foods = {};
	-- read from the second row
	if(reader:LoadFile(config_path, 2)) then 
		local rows = reader:GetRows();
		if(not rows) then
			return;
		end
		-- echo(commonlib.serialize(rows, true));
		local _, row
		for _, row in ipairs(rows) do
			if(row.gsid) then
				row.order = _;
				rows_map[row.gsid] = row
				----替换出现位置
				--local palce_node = place_map[row.gsid];
				--if(palce_node)then
					--row.places = palce_node.place or "";
				--else
					--row.places = "";
				--end
				if(row.evolve_foods)then
					local evolve_foods = row.evolve_foods;
					local foods_arr = commonlib.split(evolve_foods,"#");
					for k,v in ipairs(foods_arr) do
						local _gsid = tonumber(v);
						all_foods[_gsid] = true;
					end    	
				end
				local common_path = row.common_template;
				if(common_path and common_path ~= "")then
					if(not template_map[common_path])then
						local full_path = string.format("%s%s",root_path,common_path);
						template_map[common_path] = self:Load_CommonTemplate(full_path);
					end
				end
			end
		end
	end
	self.rows_map = rows_map;
	self.template_map = template_map;
	self.all_foods = all_foods;
end
function CombatPetConfig:GetCommonTemplate(common_path)
	common_path = common_path or "commons.xml";
	if(self.template_map)then
		return self.template_map[common_path];
	end
end
function CombatPetConfig:GetAllRows()
	return self.rows_map;
end
function CombatPetConfig:GetRow(gsid)
	if(not gsid)then return end
	local row = self.rows_map[gsid];
	local row_common;
	if(row and row.common_template)then
		row_common = self.template_map[row.common_template];
	end
	return row,row_common;
end
--[[
(0:aaaaa.x)
(1:aaaaa.x)
(2:aaaaa.x)
(3:aaaaa.x)
to
{
	{level = level, assetfile = assetfile,},
	{level = level, assetfile = assetfile,},
}

--]]

function CombatPetConfig:Parse_AssetsToList(assets)
	if(not assets)then return end
	assets = string.gsub(assets,"%s","");
	local section;
	local result = {};
	for section in string.gmatch(assets, "([^%(^%)]+)") do
		local arr = commonlib.split(section,":")
		table.insert(result,{
			level = tonumber(arr[1]) or 0,
			assetfile = arr[2],
		});
	end
	return result; 
end
--[[
(0:0)
(1:100)
(2:1000)
(3:5000)
to
{
	{level = level, exp = exp,},
	{level = level, exp = exp,},
}

--]]

function CombatPetConfig:Parse_LevelsToList(levels)
	if(not levels)then return end
	levels = string.gsub(levels,"%s","");
	local section;
	local result = {};
	for section in string.gmatch(levels, "([^%(^%)]+)") do
		local arr = commonlib.split(section,":")
		table.insert(result,{
			level = tonumber(arr[1]) or 0,
			exp = tonumber(arr[2]) or 0,
		});
	end
	return result; 
end
--[[
(0:20134#ai_key#1,20134#ai_key#1,20134#ai_key#1)
(3:20134#ai_key#1,20134#ai_key#1,20134#ai_key#1)
(5:20134#ai_key#1,20134#ai_key#1,20134#ai_key#1)
return
{
	{
		level = 0,card_list = {
			gsid = gsid ,ai_key = ai_key, count = count,
		}
	},
	{
		level = 1,card_list = {
			gsid = gsid ,ai_key = ai_key, count = count,
		}
	}
}
--]]
function CombatPetConfig:Parse_CardsToList(cards)
	if(not cards)then return end
	cards = string.gsub(cards,"%s","");
	local section;
	local result = {};
	for section in string.gmatch(cards, "([^%(^%)]+)") do
		local arr = commonlib.split(section,":")
		local level = tonumber(arr[1]) or 0;
		local card_info = arr[2];
		local card_list = {};
		local arr_card = commonlib.split(card_info,",")
		local k,v;
		for k,v in ipairs(arr_card) do
			local v_arr = commonlib.split(v,"#");
			local gsid = tonumber(v_arr[1]);
			local ai_key = v_arr[2];
			local count = tonumber(v_arr[3]);
			table.insert(card_list,{
				gsid = gsid,
				ai_key = ai_key,
				count = count,
			});
		end
		table.insert(result,{
			level = level,
			card_list = card_list,
		});
	end
	return result; 
end
--返回 虚体,实体 list,entity_list = {{stat = stat,value = value,}...},{{stat = stat,value = value,}...}
function CombatPetConfig:Parse_StatToList(row)
	if(not row)then return end
	local k,v;
	local list = {};
	local entity_list = {};
	local stat_scale = row.stat_scale or 0;
	for k,v in pairs(row) do
		local stat = string.match(k,"^entity_stat_(.+)");
		stat = tonumber(stat);
		if(stat)then
			local value = tonumber(v);
			if(value)then
				--实体
				table.insert(entity_list,{
					stat = stat,
					value = value;
					p = CombatPetConfig.sort_priority[stat] or 0,
				});
				--虚体
				table.insert(list,{
					stat = stat,
					value = value * stat_scale;--根据比例缩放
					p = CombatPetConfig.sort_priority[stat] or 0,
				});
			end
			
		end
	end

	local function func(a,b)
		if(a.p and b.p)then
			return a.p < b.p;
		end
	end
	local function check(list)
		local k,v;
		for k,v in ipairs(list) do
			v.p = nil;
		end
	end
	table.sort(list,func);
	table.sort(entity_list,func);
	check(list)
	check(entity_list)
	return list,entity_list;
end
function CombatPetConfig:GetTemplateInfo(gsid)
	if(not gsid)then
		return
	end
	if(CombatPetConfig.row_template[gsid])then
		return CombatPetConfig.row_template[gsid];
	end
	local row,row_common = self:GetRow(gsid);
	--满级附加属性
	local stat_list,entity_stat_list = self:Parse_StatToList(row)
	--初始附加属性
	local common_stat_list,common_entity_stat_list = self:Parse_StatToList(row_common)
	--虚体附加卡牌
	local cards_list = {};
	--实体附加卡牌
	local entity_cards_list = {};
	--资源列表
	local assets_list = {};
	if(row)then
		cards_list = self:Parse_CardsToList(row.cards)
		entity_cards_list = self:Parse_CardsToList(row.entity_cards)
		assets_list = self:Parse_AssetsToList(row.evolve_assets);
	end
	--等级
	local levels = {};
	if(row_common)then
		levels = self:Parse_LevelsToList(row_common.levels)
	end
	
	CombatPetConfig.row_template[gsid] = {
		row = row,
		row_common = row_common,
		stat_list = stat_list,
		entity_stat_list = entity_stat_list,
		common_stat_list = common_stat_list,
		common_entity_stat_list = common_entity_stat_list,
		cards_list = cards_list,
		entity_cards_list = entity_cards_list,
		levels = levels,
		assets_list = assets_list,
	} 
	return CombatPetConfig.row_template[gsid];
end

function CombatPetConfig:GetLevelsInfo(gsid,exp)
	if(not gsid)then
		return
	end
	exp = exp or 0;
	local cache_key = string.format("%d_%d",gsid,exp);
	if(self.levels_info_map[cache_key])then
		return self.levels_info_map[cache_key];
	end
	local tempalte = self:GetTemplateInfo(gsid)
	if(tempalte)then
		local start_evolve_level;
		local row = tempalte.row;
		if(row)then
			start_evolve_level = row.start_evolve_level;--指定进化等级段
		end
		local stat_list = tempalte.stat_list;
		local entity_stat_list = tempalte.entity_stat_list;
		local common_stat_list = tempalte.common_stat_list;
		local common_entity_stat_list = tempalte.common_entity_stat_list;
		local cards_list = tempalte.cards_list;
		
		local entity_cards_list = tempalte.entity_cards_list;
		
		local levels = tempalte.levels or {};--等级段
		local assets_list = tempalte.assets_list or {};--资源列表
		
		local cur_level = 0;
		local cur_level_exp = 0;
		local cur_level_max_exp = 0;
		local max_level = row.max_level or 0;
		local max_exp = 0;
		local cur_stat_list = {};
		local cur_entity_stat_list = {};
		local cur_cards_list = {};
		local cur_entity_cards_list = {};

		local k,v;
		for k,v in ipairs(levels) do
			if(v.level <= max_level)then
				max_exp = max_exp + v.exp;
			end
		end

		if(exp == 0)then
			cur_level = 0;
			if(levels[2])then
				cur_level_max_exp = levels[2].exp
			end
		elseif(exp >= max_exp)then
			cur_level = max_level;
		else
			local k,v;
			local temp_exp = exp;
			for k,v in ipairs(levels) do
				temp_exp = temp_exp - v.exp;
				if(temp_exp < 0)then
					cur_level = v.level - 1;
					cur_level_exp = v.exp + temp_exp;
					cur_level_max_exp = v.exp;
					break;
				end
			end
		end
		local stat_value_scale = cur_level / max_level;
		--虚体stat
		cur_stat_list = self:Stat_Scale(stat_list,common_stat_list,stat_value_scale);
		--实体stat
		cur_entity_stat_list = self:Stat_Scale(entity_stat_list,common_entity_stat_list,stat_value_scale);
		self:Stat_mode(cur_stat_list);
		self:Stat_mode(cur_entity_stat_list);
		local function get_card(level,list)
			if(not list)then
				return
			end
			local k,v;
			local result_list;
			for k,v in ipairs(list) do
				if(v.level and v.level <= level)then
					result_list = v.card_list;
				end
			end
			return result_list;
		end
		--虚体卡片
		cur_cards_list = get_card(cur_level,cards_list);
		--实体卡片
		cur_entity_cards_list = get_card(cur_level,entity_cards_list);
		local is_full = false;
		if(cur_level and max_level and max_level > 0 and cur_level >= max_level)then
			is_full = true;
		end
		--只取最大级的卡片
		cards_list = get_card(max_level,cards_list);
		
		entity_cards_list = get_card(max_level,entity_cards_list);
		
		local node = {
			start_evolve_level = start_evolve_level,--开始进化 
			cur_level = cur_level,--当前级别
			cur_level_exp = cur_level_exp,--当前级别经验值
			cur_level_max_exp = cur_level_max_exp,--当前级别总经验值
			max_level = max_level,--最高级别
			max_exp = max_exp,--满级经验总和
			cur_stat_list = cur_stat_list,--虚体附加属性
			cur_entity_stat_list = cur_entity_stat_list,--实体附加属性
			cur_cards_list = cur_cards_list,--虚体附加卡片
			cur_entity_cards_list = cur_entity_cards_list,--实体附加卡片

			stat_list = stat_list,
			entity_stat_list = entity_stat_list,
			cards_list = cards_list,
			entity_cards_list = entity_cards_list,
			is_full = is_full,--是否已经满级

			assets_list = assets_list,
		}
		self.levels_info_map[cache_key] = node;
		return node;
	end
end
--精确小数位
function CombatPetConfig:Stat_mode(stat_list)
	local k,v;
	for k,v in ipairs(stat_list) do
		local stat = v.stat;
		local value = v.value;
		if(stat == 101)then
			value = math.floor(value);
		else
			value = string.format("%.2f",value);
		end
		v.value = tonumber(value);
	end
end
function CombatPetConfig:Stat_Scale(max_stat_list,common_stat_list,scale)
	if(max_stat_list and common_stat_list and scale)then
		local result = {};
		local k,v;
		for k,v in ipairs(max_stat_list) do
			local kk,vv;
			for kk,vv in ipairs(common_stat_list) do
				if(v.stat and vv.stat and v.stat == vv.stat)then
					local max_value = v.stat;
					local max_value = v.value or 0;
					local min_value = vv.value or 0;
					local value = (min_value + scale * max_value)
					value = math.min(value,max_value);
					table.insert(result,{
						stat = v.stat,
						value = value,
					});
				end
			end
		end
		return result;
	end
end
function CombatPetConfig:GetAssetFileFromGSIDandAssetID(gsid,id)
	local gsItem = GemTranslationHelper.GetGlobalStoreItem(gsid,self.isremote);
	local assetfile = "";
	local row = self:GetRow(gsid);
	if(gsItem or not row)then
		assetfile = gsItem.assetfile;
	end
	local folder,filename,suffx = string.match(assetfile, [[^(.+)/(.+)%.(.+)$]]);
	local assets_list = self:Parse_AssetsToList(row.evolve_assets);
	if(folder and assets_list)then
		local k,v;
		local temp_assetfile;
		for k,v in ipairs(assets_list) do
			if(v.level and id >= v.level)then
				temp_assetfile = v.assetfile;
			end
		end
		if(temp_assetfile)then
			assetfile = string.format("%s/%s",folder,temp_assetfile);
		end
	end
	return assetfile;
end
--返回当前级别的形象的编号 0(默认) or 1(满级) or 2(进化满级)
function CombatPetConfig:GetCurLevelAssetID(gsid,exp)
	local __,id = self:GetCurLevelAssetFileAndID(gsid,exp);
	return id;
end
--返回当前级别的形象 assetfile,id
function CombatPetConfig:GetCurLevelAssetFileAndID(gsid,exp)
	if(not gsid)then return end
	local row = self:GetRow(gsid);
	if(not row)then
		return
	end
	exp = exp or 0;
	local id = 0;
	
	local assetfile = "";
	local gsItem = GemTranslationHelper.GetGlobalStoreItem(gsid,self.isremote);
	if(gsItem)then
		assetfile = gsItem.assetfile or "";
	end
	local folder,filename,suffx = string.match(assetfile, [[^(.+)/(.+)%.(.+)$]]);
	local levels_info = self:GetLevelsInfo(gsid,exp)
	if(folder and levels_info and levels_info.assets_list)then
		local cur_level = levels_info.cur_level;
		local assets_list = levels_info.assets_list;
		local k,v;
		local temp_assetfile;
		for k,v in ipairs(assets_list) do
			if(v.level and cur_level >= v.level)then
				temp_assetfile = v.assetfile;
				id = cur_level;
			end
		end
		if(temp_assetfile)then
			assetfile = string.format("%s/%s",folder,temp_assetfile);
		end
	end
	return assetfile,id;
end
local colour_map = 
{
	[0] = "#ffffff",
	[1] = "#00cc33",
	[2] = "#0099ff",
	[3] = "#c648e1",
	[4] = "#ff9a00",
};
function CombatPetConfig:GetTemplateColorName(gsid)
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	local pet_name;
	if(gsItem) then
		pet_name = gsItem.template.name;
		return self:BuildColorName(pet_name,gsid);
	end
end
function CombatPetConfig:BuildColorName(pet_name,gsid)
	exp = exp or 0;
	if(not pet_name or not gsid)then
		return
	end
	local row = self:GetRow(gsid);
	local quality =row.quality or 0;
	return string.format([[<div style="color:%s">%s</div>]],colour_map[quality],pet_name);
end
function CombatPetConfig:IsCombatPet(gsid)
	local row = self:GetRow(gsid);
	if(row)then
		return true;
	end
end
--是否是扩展等级可以吃的食物
function CombatPetConfig:IsSeniorFoodGsid(pet_gsid,gsid)
	if(not gsid)then return end
	local row = self:GetRow(pet_gsid);
	if(row)then
		local evolve_foods = row.evolve_foods;
        local foods_arr = commonlib.split(evolve_foods,"#");
		for k,v in ipairs(foods_arr) do
			local _gsid = tonumber(v);
			if(_gsid == gsid)then
				return true;
			end
        end    
	end
end
--return 实体卡片 cur_entity_cards_list ={ {gsid = gsid, ai_key = ai_key}, {gsid = gsid, ai_key = ai_key}, }
function CombatPetConfig:GetCurLevelAICards(gsid,exp)
	local levels_info = self:GetLevelsInfo(gsid,exp)
	local cur_entity_cards_list  = {};
	if(levels_info)then
		cur_entity_cards_list = levels_info.cur_entity_cards_list;
	end
	return cur_entity_cards_list or {};
end
--返回当前级别所带的卡片
--return 虚体 实体 cur_cards_list,cur_entity_cards_list 格式 {20,21,22}
function CombatPetConfig:GetCurLevelCards(gsid,exp)
	local levels_info = self:GetLevelsInfo(gsid,exp)
	local result = {};
	local result_entity = {};
	if(levels_info)then
		local cur_cards_list = levels_info.cur_cards_list;
		local cur_entity_cards_list = levels_info.cur_entity_cards_list;
		
		local k,v;
		if(cur_cards_list)then
			for k,v in ipairs(cur_cards_list) do
				if(v.gsid)then
					table.insert(result,v.gsid);
				end
			end
		end
		if(cur_entity_cards_list)then
			for k,v in ipairs(cur_entity_cards_list) do
				if(v.gsid)then
					table.insert(result_entity,v.gsid);
				end
			end
		end
	end
	return result,result_entity;
end
--返回当前级别所带的附加属性
--return 虚体 实体  cur_stat_map,cur_entity_stat_map 格式{ [102]=5, [103]=10,}
function CombatPetConfig:GetCurLevelProps(gsid,exp)
	local levels_info = self:GetLevelsInfo(gsid,exp)
	local cur_stat_map = {};
	local cur_entity_stat_map = {};
	if(levels_info)then
		local cur_stat_list = levels_info.cur_stat_list--虚体附加属性
		local cur_entity_stat_list = levels_info.cur_entity_stat_list--实体附加属性
		local k,v;
		if(cur_stat_list)then
			for k,v in ipairs(cur_stat_list) do
				if(v.stat and v.value)then
					cur_stat_map[v.stat] = v.value; 
				end
			end
		end
		if(cur_entity_stat_list)then
			for k,v in ipairs(cur_entity_stat_list) do
				if(v.stat and v.value)then
					cur_entity_stat_map[v.stat] = v.value; 
				end
			end
		end
	end
	return cur_stat_map,cur_entity_stat_map;
end
--目前跟随宠物附加属性 虚体 实体
function CombatPetConfig:GetCurLevelCards_FollowingPet()
	local item = ItemManager.GetMyCurrentFollowPetItemOnEquip();
    if(item and item.guid > 0) then
        local serverdata = item:GetServerData();
		local exp = serverdata.exp;
		return self:GetCurLevelCards(item.gsid,exp);
	end
end
--目前跟随宠物附加卡片 虚体 实体
function CombatPetConfig:GetCurLevelProps_FollowingPet()
	local item = ItemManager.GetMyCurrentFollowPetItemOnEquip();
    if(item and item.guid > 0) then
        local serverdata = item:GetServerData();
		local exp = serverdata.exp;
		return self:GetCurLevelProps(item.gsid,exp);
	end
end
function CombatPetConfig:IsCommonFood(gsid)
	if(not gsid)then
		return
	end
	if(gsid == 17172 or gsid == 17185 or gsid == 17211 or gsid == 17302)then
		return true
	end
end
function CombatPetConfig:IsFood(gsid)
	if(not gsid)then
		return
	end
	if(self:IsCommonFood(gsid))then
		return true
	end
	if(self.all_foods and self.all_foods[gsid])then
		return true;
	end
end