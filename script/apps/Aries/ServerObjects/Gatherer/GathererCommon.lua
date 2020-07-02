--[[
Title: 
Author(s): Leio
Date: 2012/02/22
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/ServerObjects/Gatherer/GathererCommon.lua");
local GathererCommon = commonlib.gettable("MyCompany.Aries.ServerObjects.GathererCommon");
local map,quest_used_list,quest_used_map = GathererCommon.LoadTemplate();
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
local GathererCommon = commonlib.gettable("MyCompany.Aries.ServerObjects.GathererCommon");
GathererCommon.quality_map= {
	[0] = 21109,--采集学
	[1] = 21110,--采金学
}

local cached_data = {};

--通过config/Aries/Workspace/worldconfig.xml 加载所有世界可以捡取的物品
-- @note by LiXizhi: result is always cached.
--@param _version:加载版本 default value is "teen"
--return map,quest_used_list,quest_used_map
--map:[id_index] = node
--quest_used_list:[index] = node
--quest_used_map:[id] = node
function GathererCommon.LoadTemplate(_version)
	local self = GathererCommon;
	_version = _version or "teen";
	if(cached_data[_version]) then
		return unpack(cached_data[_version])
	end
	
	local map = {};
	local quest_used_list = {};
	local quest_used_map = {};
	local function get_number(v)
		if(v and v~="")then
			v = tonumber(v);
			return v;
		end
	end
	local function get_bool(v)
		if(v == "false" or snap == "False")then
			v = false
		else
			v = true;
		end
		return v;
	end
	local function push_data(xmlRoot,worldname)
		if(xmlRoot)then
			local item;
			for item in commonlib.XPath.eachNode(xmlRoot, "//items/item") do
				local id = tonumber(item.attr.id);
				if(id)then
					local label = item.attr.label;
					local level = get_number(item.attr.level) or 0;--物品的等级
					local quality = get_number(item.attr.quality) or 0;--物品的品质 0 植物(21109) 1矿石(21110)

					local enabled_native_quest = get_bool(item.attr.enabled_native_quest);--是否对任务系统有效 默认true
					local enabled_gather = get_bool(item.attr.enabled_gather);--是否对采集系统有效 默认true

					local gsid = get_number(item.attr.gsid);
					local scale = get_number(item.attr.scale) or 1;--默认缩放
					local scale_char = get_number(item.attr.scale_char) or 1;--默认缩放
					local talkdist = get_number(item.attr.talkdist) or 5;--默认对话距离
					local facing = get_number(item.attr.facing) or 0;--默认
					local duration = get_number(item.attr.duration) or 60000;--默认刷新时间
					local assetfile = item.attr.assetfile;
					local snap = get_bool(item.attr.snap);--是否吸附地面 默认true
					local index = 1;
					local item_point;

					local quest_used_node = nil;
					local quest_used_world = QuestHelp.WorldNameToWorldNum(worldname);--兼容旧的格式;
					local quest_used_point_list = {};
					local quest_used_position = "";

					for item_point in commonlib.XPath.eachNode(item, "//point") do
						local pos = item_point.attr.pos;
						local x,y,z = string.match(pos,"(.+),(.+),(.+)");
						x = tonumber(x);
						y = tonumber(y);
						z = tonumber(z);
						if(x and y and z)then
							--quest used info--------------------------------------	
							table.insert(quest_used_point_list,{x = x,y = y,z = z});
							if(quest_used_position == "")then
								quest_used_position = pos;
							else
								quest_used_position = quest_used_position.."#"..pos;
							end

							-------------------------------------------------------	

							scale = get_number(item_point.attr.scale) or scale;
							talkdist = get_number(item_point.attr.talkdist) or talkdist;
							facing = get_number(item_point.attr.facing) or facing;
							if(item_point.attr.snap and item_point.attr.snap ~= "")then
								snap = get_bool(item_point.attr.snap);--是否吸附地面 默认true
							end
							local key = string.format("%d_%d",id,index);
							local node = {
								key = key,
								id = id,
								gsid = gsid,
								index = index,
								level = level,
								quality = quality,
								enabled_native_quest = enabled_native_quest,
								enabled_gather = enabled_gather,
								worldname = worldname,
								label = label,
								scale = scale,
								scale_char = scale_char,
								assetfile = assetfile,
								position = {x,y,z},
								talkdist = talkdist,
								facing = facing,
								duration = duration,
								snap = snap,

								born_sec = 0,
							}
							map[key] = node;
							index = index + 1;
						else
							LOG.std("", "waring","invalid position in PickItemServerLogics.OnInit",{id,index});
						end
					end

					quest_used_node = {
						id = id,
						gsid = gsid,
						level = level,
						worldname = worldname,
						world = quest_used_world,
						label = label,
						scale = scale,
						scale_char = scale_char,
						assetfile = assetfile,
						point_list = quest_used_point_list,
						position = quest_used_position,--兼容旧的格式
					}
					if(not quest_used_map[id])then
						table.insert(quest_used_list,quest_used_node);
						quest_used_map[id] = quest_used_node;
					end
				end
			end
		end
	end
	local config_path;
	if(_version == "teen")then
		config_path = "config/Aries/Workspace/worldconfig.teens.xml";
	else
		config_path = "config/Aries/Workspace/worldconfig.kids.xml";
	end
	local xmlRoot = ParaXML.LuaXML_ParseFile(config_path);
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "//worlds/world") do
		local worldname = node.attr.worldname;
		local pickitempath = node.attr.pickitempath;
		local version = node.attr.version;
		if(pickitempath and version and pickitempath ~= "" and version == _version)then
			local root_node = ParaXML.LuaXML_ParseFile(pickitempath);
			push_data(root_node,worldname);
		end
	end
	cached_data[_version] = {map,quest_used_list,quest_used_map};
	return unpack(cached_data[_version]);
end
--[[	
	格式转换 
	map = {
		["aa"] = true,
		["bb"] = true,
	}
	to 
	list = {"aa","bb"};
--]]
function GathererCommon.MapToList(map)
	if(not map)then return end
	local list = {};
	for k,v in pairs(map) do
		if(v)then
			table.insert(list,k);
		end
	end
	return list;
end
--[[	
	格式转换 
	list = {"aa","bb"};
	to 
	map = {
		["aa"] = true,
		["bb"] = true,
	}
--]]
function GathererCommon.ListToMap(list)
	if(not list)then return end
	local map = {};
	local k,v;
	for k,v in ipairs(list) do
		map[v] = true;
	end
	return map;
end
-----------------------------------------------------------------------------------------------工具预览
function GathererCommon.LoadItemInWorld_BySingleStr(parent_node_str,node_str,index)
	if(not parent_node_str or not node_str)then return end
	local parent_node = ParaXML.LuaXML_ParseString(parent_node_str);
	local node = ParaXML.LuaXML_ParseString(node_str);
	GathererCommon.LoadItemInWorld_BySingleNode(parent_node[1],node[1],index);
end
function GathererCommon.LoadItemInWorld_BySingleNode(parent_node,node,index)
	if(not parent_node or not node)then return end
	local function get_pos(pos)
		if(not pos)then return end
		local a
		local result = {};
		for a in string.gfind(pos, "[^,]+") do
			table.insert(result,tonumber(a));
		end
		return result;
	end
	local label = parent_node.attr.label;
	local id = tonumber(parent_node.attr.id);
	local scale = tonumber(parent_node.attr.scale);
	local scale_char = tonumber(parent_node.attr.scale_char);
	local facing = tonumber(parent_node.attr.facing);
	local assetfile = parent_node.attr.assetfile;
	local snap = parent_node.attr.snap;
	if(snap == "false" or snap == "False")then
		snap = false;
	else
		snap = true;
	end
	scale = tonumber(node.attr.scale) or scale;
	facing = tonumber(node.attr.facing) or facing;
	if(node.attr.snap and node.attr.snap ~= "")then
		if(snap == "false" or snap == "False")then
			snap = false;
		else
			snap = true;
		end
	end
	local position = node.attr.pos;
	position = get_pos(position);
	index = index or 1
	if(id and position)then
		local name = string.format("%s(%d %d)",label,id,index);
		local params = {
			name = name,
			instance = index,
			position = position,
			facing = facing,
			scaling = scale,
			scale_char = scale_char,
			assetfile_char = "character/v5/09effect/Common/Star02_Shangsheng_Yellow.x",
			--assetfile_char = "character/common/dummy/cube_size/cube_size.x",
			assetfile_model = assetfile,
			isalwaysshowheadontext = true,
		}
		MyCompany.Aries.Quest.NPC.DeleteNPCCharacter(id,index);
		MyCompany.Aries.Quest.NPC.CreateNPCCharacter(id, params);
		if(snap)then
			local npcChar, _model = MyCompany.Aries.Quest.NPC.GetNpcCharModelFromIDAndInstance(id,index);
			if(npcChar and npcChar:IsValid())then
				npcChar:SnapToTerrainSurface(0);
				if(_model and _model:IsValid())then
					local x,y,z = npcChar:GetPosition();
					_model:SetPosition(x,y,z);
				end
			end	
		end
	end
end
function GathererCommon.LoadItemInWorld_ByFile(filepath)
	if(not filepath)then return end
	local mcmlNode = ParaXML.LuaXML_ParseFile(filepath);
	local parent_node;
	for parent_node in commonlib.XPath.eachNode(mcmlNode, "//items/item") do
		local node;
		local index = 0;
		for node in commonlib.XPath.eachNode(parent_node, "/point") do
			GathererCommon.LoadItemInWorld_BySingleNode(parent_node,node,index);
			index = index + 1;
		end
	end
end
