--[[
Title: auction house
Author(s): LiXizhi
Date: 2012/6/27
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/HaqiShop/ItemGuides.lua");
local ItemGuides = commonlib.gettable("MyCompany.Aries.ItemGuides");
ItemGuides.Init();
ItemGuides.OnClickViewItem(gsid);
ItemGuides.PrintManualAll();
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");
local ItemGuides = commonlib.gettable("MyCompany.Aries.ItemGuides");
local NPCList = commonlib.gettable("MyCompany.Aries.Quest.NPCList");

local empty_template_ds = {name="text", attr={value="该物品暂时没有别的获取途径" } }
local only_npc_shop_template_ds = {name="text", attr={value="在NPC商店中可以获得" } }


function ItemGuides.Init(bForceRefresh)
	if(ItemGuides.is_inited and not bForceRefresh) then
		return;
	end
	ItemGuides.is_inited = true;
	ItemGuides.monsterInfo = {};

	if(System.options.version == "kids") then
		ItemGuides.Load_Loots(true);
	else
		ItemGuides.Load_Loots();
		ItemGuides.Load_Gathering();
		ItemGuides.Load_Makings();
		ItemGuides.Load_Custom();
		ItemGuides.Load_Quest();
		NPL.load("(gl)script/apps/Aries/HaqiShop/NPCShopProvider.lua");
		local NPCShopProvider = commonlib.gettable("MyCompany.Aries.NPCShopProvider");
		NPCShopProvider.Load();
	end
end

function ItemGuides.OnClickViewItem(gsid)
	NPL.load("(gl)script/apps/Aries/HaqiShop/AuctionHouse.lua");
	local AuctionHouse = commonlib.gettable("MyCompany.Aries.AuctionHouse");
	AuctionHouse.OnClickViewItem(gsid);
end

-- @param bIgnoreInstancedWorld: do not find loot in instanced world.
function ItemGuides.Load_Loots(bIgnoreInstancedWorld)
	local worlds;
	if(System.options.version == "kids") then 
		worlds = {
			{worldname = "61HaqiTown"},
			{worldname = "FlamingPhoenixIsland"},
			{worldname = "FrostRoarIsland"},
			{worldname = "AncientEgyptIsland"},
			{worldname = "DarkForestIsland"},
		};
	else
		worlds = {
			{worldname = "61HaqiTown_teen"},
			{worldname = "FlamingPhoenixIsland"},
			{worldname = "FrostRoarIsland"},
			{worldname = "AncientEgyptIsland"},
			{worldname = "DarkForestIsland"},
			{worldname = "CloudFortressIsland"},
		};
	end

	if(not bIgnoreInstancedWorld) then
		NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClient.lua");
		local LobbyClient = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClient");
		local lc = LobbyClient:GetClient();
		local game_templates = LobbyClient:GetGameTemplates();
		if(game_templates)then
			local k,v; 
			for k,v in pairs(game_templates) do
				if(v.game_type == "PvE") then
					worlds[#worlds+1] = {worldname = v.worldname}
				end
			end
		end
	end

	local _, world
	for _, world in ipairs(worlds) do
		local worldname = world.worldname;
		local config_file = if_else(System.options.version == "kids", "config/Aries/WorldData/", "config/Aries/WorldData_Teen/");
		local world_info = WorldManager:GetWorldInfo(worldname);
		if(world_info) then
			--local worldpathname = world_info.worldpath:match("([^/]+)$")
			local worldpathname = world.keyname or worldname;
			local config_file = config_file..worldpathname..".Arenas_Mobs.xml";
			ItemGuides.BuildArenaMobLoots(config_file)
		end
	end
end

function ItemGuides.Load_Gathering()
	NPL.load("(gl)script/apps/Aries/ServerObjects/Gatherer/GathererCommon.lua");
	local GathererCommon = commonlib.gettable("MyCompany.Aries.ServerObjects.GathererCommon");
	local gather_map = GathererCommon.LoadTemplate();
	if(gather_map) then
		local id, node
		for id, node in pairs(gather_map) do
			if(node.gsid) then
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(node.gsid);
				if(gsItem) then
					gsItem.guides = gsItem.guides or {};
					gsItem.guides["gather"] = gsItem.guides["gather"] or {};

					local gather = gsItem.guides["gather"];
					
					gather[#gather+1] = node;
				end
			end
		end
	end
end

function ItemGuides.Load_Makings()
	--NPL.load("(gl)script/apps/Aries/NPCs/SnowArea/CastMachine_subpage.teen.lua");
	--local CastMachine_subpage = commonlib.gettable("MyCompany.Aries.NPCs.SnowArea.CastMachine_subpage");
	--local cate_items = CastMachine_subpage:LoadData();
	local filename = if_else(System.options.version=="kids", nil, "config/Aries/Others/make_item.csv")
	if(filename) then
		local file = ParaIO.open(filename, "r");
		if(file:IsValid())then
			local line = file:readline();
			while (line) do
				local class_item, target_gsid, exid = line:match("^(%d+),(%d+),(%d+)")
				class_item = tonumber(class_item)
				target_gsid = tonumber(target_gsid)
				exid = tonumber(exid)
				if(target_gsid) then
					local gsItem = ItemManager.GetGlobalStoreItemInMemory(target_gsid);
					if(gsItem) then
						gsItem.guides = gsItem.guides or {};
						gsItem.guides["making"] = gsItem.guides["making"] or {};
						local making = gsItem.guides["making"];
						making[#making+1] = {class_item = class_item, target_gsid = target_gsid, exid = exid};
					end
				end
				line = file:readline();
			end
			file:close();
		end
	end

end

function ItemGuides.Load_Custom()
	local filename = if_else(System.options.version=="kids", nil, "config/Aries/Others/globalstore.itemguide.teen.xml")
	if(filename) then
		local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
		if(xmlRoot) then
			local node;
			for node in commonlib.XPath.eachNode(xmlRoot, "/itemsets/itemset") do
				if(node.attr and node.attr.gsids) then
					local gsid;
					for gsid in node.attr.gsids:gmatch("%d+") do
						local gsid = tonumber(gsid);
						local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
						if(gsItem) then
							gsItem.guides = gsItem.guides or {};
							gsItem.guides["custom"] = gsItem.guides["custom"] or {};
							local making = gsItem.guides["custom"];
							making[#making+1] = node;
						end
					end
				end
			end
		end
	end
end

function ItemGuides.Load_Quest()
	NPL.load("(gl)script/apps/Aries/Quest/QuestHelp.lua");
	local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
	local __,templates = QuestHelp.LoadQuestTempaltesByClient();
	if(not templates)then return end
	local k,template;
	for k,template in pairs(templates) do
		local Reward = template.Reward;
		if(Reward)then
			local Reward_2 = Reward[2];
			if(Reward_2)then
				local __,item;
				for __,item in ipairs(Reward_2) do
					local gsid = item.id;
					local value = item.value;
					if(gsid and gsid > 0)then
						local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
						if(gsItem) then
							gsItem.guides = gsItem.guides or {};
							gsItem.guides["quest"] = gsItem.guides["quest"] or {};
							local making = gsItem.guides["quest"];
							making[#making+1] = template;
						end
					end
				end
			end
		end
	end
end
-- all loaded config file
local arena_and_mobs_config_file_pairs_xmlroot = {}
-- all mob templates
local MobTemplate = {};
MobTemplate.templates = MobTemplate.templates or {};

-- @param value: loot string: "{[17177,1]=40,[16068,1]=0.1,[26122,1]=40}"
local function add_loots(value, loot_guide, mob_node, loots)
	if(not value or value=="") then
		return 
	end
	value = string.gsub(value, "%[", "[\"");
	value = string.gsub(value, "%]", "\"]");
	local loot = commonlib.LoadTableFromString(value);
	if(loot) then
		local name, percent;
		for name, percent in pairs(loot) do
			local gsid = name:match("^(%d+)");
			gsid = tonumber(gsid);
			if(gsid) then
				loot_guide = loot_guide or {};
				loot_guide.drop_percent = percent or 0;
				ItemGuides.AddLoot(gsid, loot_guide);
				if(loots) then
					loots[#loots+1] = {gsid=gsid, percent=percent}
				end
			end
		end
	else
		LOG.std(nil, "error", "ItemGuides", "error in loot for mob file %s. loot string is %s", mob_node.attr.mob_template, value);
	end
end

-- @param loot_guide: {worldname, x,y,z, drop_percent, mob_level}
function ItemGuides.AddLoot(gsid, loot_guide)
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(gsItem) then
		gsItem.guides = gsItem.guides or {};
		gsItem.guides["loots"] = gsItem.guides["loots"] or {};
		local loots = gsItem.guides["loots"];
		local index, guide;
		for index, guide in ipairs(loots) do
			if(guide.worldname == loot_guide.worldname and guide.mob_level==loot_guide.mob_level and guide.displayname==loot_guide.displayname) then
				if(guide.drop_percent < loot_guide.drop_percent) then
					loots[index] = commonlib.copy(loot_guide);
				end
				return;
			end
		end
		loots[#loots+1] = commonlib.copy(loot_guide);
	end
end

-- add catch pet
function ItemGuides.AddCatchPet(gsid, loot_guide, mob_node)
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(gsItem) then
		gsItem.guides = gsItem.guides or {};
		gsItem.guides["catchpet"] = gsItem.guides["catchpet"] or {};
		local loots = gsItem.guides["catchpet"];
		local index, guide;
		for index, guide in ipairs(loots) do
			if(guide.worldname == loot_guide.worldname and guide.mob_level==loot_guide.mob_level and guide.displayname==loot_guide.displayname) then
				return;
			end
		end
		loots[#loots+1] = commonlib.copy(loot_guide);
	end
end

function ItemGuides.GetArenaMobConfigXMLNode(config_file)
	local xmlRoot = arena_and_mobs_config_file_pairs_xmlroot[config_file];
	if(not xmlRoot) then
		xmlRoot = ParaXML.LuaXML_ParseFile(config_file);
	end
	if(not xmlRoot) then
		LOG.std(nil, "error", "ItemGuides", "failed loading arena and mob config file: %s", config_file);
		return;
	end
	arena_and_mobs_config_file_pairs_xmlroot[config_file] = xmlRoot;
	return xmlRoot;
end

function ItemGuides.GetMobTemplateXMLNode(template_key)
	local template = MobTemplate.templates[template_key];
	if(not template) then
		-- create mob template if not exist

		-- code from MobTemplate:new() in mob_server.lua
		local xmlRoot = ParaXML.LuaXML_ParseFile(template_key);
		if(not xmlRoot) then
			LOG.std(nil, "error", "combatmob", "failed loading mob template template_key:"..tostring(template_key));
			return;
		end
		MobTemplate.templates[template_key] = xmlRoot;
		template = xmlRoot;
	end
	return template;
end

-- build loots from a given arena mob config file
--  Arena.InitArenaAndMobFromFile
-- @param loots: out table or nil. it contains all loots in config_file.
function ItemGuides.BuildArenaMobLoots(config_file, isinstance, loots)
	local xmlRoot = ItemGuides.GetArenaMobConfigXMLNode(config_file);
	if(not xmlRoot) then
		return;
	end
	
	LOG.std(nil,"debug", "ItemGuides", "loaded arena and mob config file %s", config_file);

	local worldname = string.match(config_file, [[/([^/]-)%.Arenas_Mobs%.xml$]])
	if(not worldname) then
		LOG.std(nil, "error", " ", "fatal error: world config file in invalid format");
		return;
	end
	
	-- arena ids
	local arena_ids = {};
	-- infile id and arena id mapping
	local file_id_arena_id_mapping = {};
	-- last arena in config file to mark the last instance arena
	local last_arena;
	-- create each arena object and associated mobs
	local each_arena;
	for each_arena in commonlib.XPath.eachNode(xmlRoot, "/arenas/arena") do
		local position = each_arena.attr.position;
		local x, y, z = string.match(position, "(.+),(.+),(.+)");
		if(x and y and z) then
			x = tonumber(x);
			y = tonumber(y);
			z = tonumber(z);
		end

		local loot_guide = {
			worldname = worldname,
			x = x, y = y, z = z,
		};
		local ai_module = each_arena.attr.ai_module;
		-- mobs
		local mob;
		for mob in commonlib.XPath.eachNode(each_arena, "/mob") do
			if(mob.attr.mob_template and mob.attr.mob_template ~= "" and mob.attr.mob_template ~= "nil") then
				-- create mob object
				local mob_node = mob;
				-- set mob template if available
				if(mob_node.attr.mob_template) then
					local template_key = mob_node.attr.mob_template;
					local template = ItemGuides.GetMobTemplateXMLNode(template_key);
					if(template) then
						-- fetch all mob template attributes
						local mob_template;
						for mob_template in commonlib.XPath.eachNode(template, "/mobtemplate/mob") do
							-- copy all mob_template attributes to stats table
							loot_guide.mob_level = tonumber(mob_template.attr.level) or 0;
							loot_guide.displayname = mob_template.attr.displayname;
							if(mob_template.attr.catch_pet) then
								local pet_gsid = tonumber(mob_template.attr.catch_pet);
								if(pet_gsid) then
									ItemGuides.AddCatchPet(pet_gsid, loot_guide, mob_node);
									if(loots) then
										loots[#loots+1] = {gsid=pet_gsid, is_pet = true};
									end
								end
							end

							if(System.options.version == "kids") then
								ItemGuides.AddMonsterInfo(mob_template,template_key);
							end

							add_loots(mob_template.attr.loot1_easy, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot2_easy, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot3_easy, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot4_easy, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot5_easy, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot6_easy, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot7_easy, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot8_easy, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot9_easy, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot10_easy, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot1, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot2, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot3, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot4, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot5, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot6, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot7, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot8, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot9, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot10, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot1_hard, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot2_hard, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot3_hard, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot4_hard, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot5_hard, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot6_hard, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot7_hard, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot8_hard, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot9_hard, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot10_hard, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot1_hero, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot2_hero, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot3_hero, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot4_hero, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot5_hero, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot6_hero, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot7_hero, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot8_hero, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot9_hero, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot10_hero, loot_guide, mob_node, loots)

							add_loots(mob_template.attr.loot_fire_easy, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot_fire, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot_fire_hard, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot_ice_easy, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot_ice, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot_ice_hard, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot_storm_easy, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot_storm, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot_storm_hard, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot_life_easy, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot_life, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot_life_hard, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot_death_easy, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot_death, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot_death_hard, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot_myth_easy, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot_myth, loot_guide, mob_node, loots)
							add_loots(mob_template.attr.loot_myth_hard, loot_guide, mob_node, loots)
						end
					end
				end

			end
		end
	end
end

function ItemGuides.HasGuidesForItem(gsid)
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(gsItem and gsItem.guides) then
		return true;
	end
end

-- build a data source for mcml page display
function ItemGuides.BuildGuideDataSourceForItem(gsid)
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	if(not gsItem) then
		return;
	end
	if(gsItem.guides_ds) then
		return gsItem.guides_ds;
	end
	if(gsItem.guides) then
		local xml_root = {};
		gsItem.guides_ds = xml_root;

		if(gsItem.guides["custom"]) then
			local _, node;
			for _, node in ipairs(gsItem.guides["custom"])  do
				local _, folder_node;
				for _, folder_node in ipairs(node)  do
					if(folder_node.attr) then
						if(folder_node.attr.expanded == nil) then
							folder_node.attr.expanded = true;
						end
					end
					xml_root[#xml_root+1] = folder_node;
				end
			end
		end
		if(gsItem.guides["making"]) then
			local making = {name="folder", attr={label="生产制造", expanded=true}, };
			xml_root[#xml_root+1] = making;
			local _, guide;
			for _, guide in ipairs(gsItem.guides["making"])  do
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(guide.class_item);
				if(gsItem) then
					local ex_item = ItemManager.GetExtendedCostTemplateInMemory(guide.exid);
					if(ex_item) then
						local require_level = 0;
						if(ex_item.pres and #(ex_item.pres) > 0) then
							local pre = ex_item.pres[1]
							require_level = pre.value
							if(pre.key ~= guide.class_item) then
								LOG.std(nil, "error", "ItemGuides", "make_item.csv has mismaking configurations")
								echo(guide);
							end
							making[#making+1] = {name="making", attr={ displayname = gsItem.template.name, require_level = require_level}, }
						end
					end
				end
			end
		end
		if(gsItem.guides["loots"]) then
			local loots = {name="folder", attr={label="掉落", expanded=true}, };
			xml_root[#xml_root+1] = loots;
			
			-- sort by mob_level
			table.sort(gsItem.guides["loots"], function(a, b)
				return a.mob_level < b.mob_level;
			end)
			local _, guide;
			for _, guide in ipairs(gsItem.guides["loots"])  do
				local world_info = WorldManager:GetWorldInfo(guide.worldname);
				if(world_info) then
					if(WorldManager:IsInstanceWorld(guide.worldname)) then
						guide.world_title = format("[副本]%s", world_info.world_title);
					else
						guide.world_title = world_info.world_title;
					end
				end
				if(guide.drop_percent) then
					local p = guide.drop_percent;
					local text;
					if(p>50) then
						text="高";
					elseif(p>10) then
						text="中";
					elseif(p>1) then
						text="低";
					else
						text="稀有";
					end
					guide.drop_percent_text = text;
					if(System.options.isAB_SDK) then
						guide.drop_percent_text = format("%s(%d%%)", guide.drop_percent_text, guide.drop_percent);
					end
				end
				loots[#loots+1] = {name="loot", attr=guide, }
			end
		end
		if(gsItem.guides["catchpet"]) then
			local loots = {name="folder", attr={label="捕捉", expanded=true}, };
			xml_root[#xml_root+1] = loots;
			-- sort by mob_level
			table.sort(gsItem.guides["catchpet"], function(a, b)
				return a.mob_level < b.mob_level;
			end)
			local _, guide;
			for _, guide in ipairs(gsItem.guides["catchpet"])  do
				local world_info = WorldManager:GetWorldInfo(guide.worldname);
				if(world_info) then
					if(WorldManager:IsInstanceWorld(guide.worldname)) then
						guide.world_title = format("[副本]%s", world_info.world_title);
					else
						guide.world_title = world_info.world_title;
					end
				end
				loots[#loots+1] = {name="catchpet", attr=guide, }
			end
		end
		if(gsItem.guides["gather"]) then
			local gather = {name="folder", attr={label="采集", expanded=true}, };
			xml_root[#xml_root+1] = gather;
			table.sort(gsItem.guides["gather"], function(a, b)
				return a.worldname < b.worldname;
			end)
			local _, guide;
			for _, guide in ipairs(gsItem.guides["gather"])  do
				local world_info = WorldManager:GetWorldInfo(guide.worldname);
				if(world_info) then
					if(WorldManager:IsInstanceWorld(guide.worldname)) then
						guide.world_title = format("[副本]%s", world_info.world_title);
					else
						guide.world_title = world_info.world_title;
					end
				end
				gather[#gather+1] = {name="gather", attr={worldname=guide.worldname, displayname = gsItem.template.name, world_title=guide.world_title, x=guide.position[1], y=guide.position[2], z=guide.position[3]}, }
			end
		end
		if(gsItem.guides["quest"]) then
			local quest = {name="folder", attr={label="任务获得", expanded=true}, };
			xml_root[#xml_root+1] = quest;
			table.sort(gsItem.guides["quest"], function(a, b)
				if(a.RecommendLevel and b.RecommendLevel)then
					return a.RecommendLevel  < b.RecommendLevel;
				end
			end)
			local _, guide;
			for _, guide in ipairs(gsItem.guides["quest"])  do
				local Id = guide.Id;
				local Title = guide.Title;
				local Detail = guide.Detail;
				quest[#quest+1] = {name="quest", attr={Id = Id, Title = Title, Detail = Detail, RecommendLevel=guide.RecommendLevel }, }
			end
		end
	end
	if(gsItem.npc_shop_items) then
		local from_gsids;
		local _, item;

		local npcs, npcid_map;

		local has_exid_zero;
		local remove_exid_zero;
		for _, item in ipairs(gsItem.npc_shop_items) do
			local exid = item["exid"];
			if(exid and exid == 0) then
				local price = gsItem.ebuyprice;
				local pbuyprice = gsItem.count;
				if(price and price>0) then
					-- qidou:
				elseif(pbuyprice and pbuyprice>0) then
					has_exid_zero = true;
				end
			end
		end

		for _, item in ipairs(gsItem.npc_shop_items) do
			local exid = item["exid"];
			if(exid and exid ~= 0) then
				local exTemplate = ItemManager.GetExtendedCostTemplateInMemory(exid);
				if(exTemplate and exTemplate.froms and exTemplate.tos)then
					local _, from;
					for _, from in ipairs(exTemplate.froms) do
						local gsid = from.key;
						if(gsid==984) then
							remove_exid_zero = has_exid_zero
						elseif(gsid and gsid~=984 and gsid ~=0 and gsid~=gsItem.gsid) then
							from_gsids = from_gsids or {};
							from_gsids[gsid] = true;
						end
					end
				end
			end
			local npcid = item["npcid"];
			if(npcid and npcid>0) then
				local npc, worldname = NPCList.GetNPCByIDAllWorlds(npcid);
				if(npc and npc.name) then
					if(not npcs) then
						npcs = {name="folder", attr={label="商人", expanded=true}, };
					end
					npcid_map = npcid_map or {};
					if(not npcid_map[npcid]) then
						npcid_map[npcid] = true;
						local name;
						if(npc.name2) then
							name = npc.name..npc.name2;
						else
							name = npc.name;
						end
						local world_title = WorldManager:GetWorldInfo(worldname).world_title;
						npcs[#npcs+1] = {name="npc", attr={npcid=npcid, npc_name=name, worldname=worldname, world_title= world_title}, }
					end
				end
			end
		end
		if(remove_exid_zero) then
			local index;
			for index, item in ipairs(gsItem.npc_shop_items) do
				local exid = item["exid"];
				if(exid and exid == 0) then
					commonlib.removeArrayItem(gsItem.npc_shop_items, index);
					break;
				end
			end
		end

		if(from_gsids) then
			local xml_root = gsItem.guides_ds or {};
			gsItem.guides_ds = xml_root;

			local items = {name="folder", attr={label="兑换物列表", expanded=true}, };
			xml_root[#xml_root+1] = items;
				
			local gsid, _;
			for gsid, _ in pairs(from_gsids) do
				items[#items+1] = {name="item", attr={gsid=gsid}, }
			end
		end
		if(npcs) then
			local xml_root = gsItem.guides_ds or {};
			gsItem.guides_ds = xml_root;
			xml_root[#xml_root+1] = npcs;
		end

		gsItem.guides_ds = gsItem.guides_ds or only_npc_shop_template_ds;
		
	end
	
	return gsItem.guides_ds or empty_template_ds;
end


-- print manual to text files are examine
function ItemGuides.PrintManualAll()
	ItemGuides.PrintManualQuest();
	ItemGuides.PrintManualSkills();
	ItemGuides.PrintManualItemWiki();
	ItemGuides.PrintManualPets();
	ItemGuides.PrintManualInstanceAndReward();
	ItemGuides.PrintManualMakings();
end

function ItemGuides.PrintManualQuest(filename)
	filename = filename or "temp/guides/"..tostring(System.options.version).."/manual_quest.txt";
	local lines = {};

	NPL.load("(gl)script/apps/Aries/Quest/QuestProvider.lua");
	NPL.load("(gl)script/apps/Aries/Quest/QuestClientLogics.lua");
	local QuestClientLogics = commonlib.gettable("MyCompany.Aries.Quest.QuestClientLogics");
	local provider = QuestClientLogics.GetProvider();
	local QuestHelp = commonlib.gettable("MyCompany.Aries.Quest.QuestHelp");
	local __,templates = QuestHelp.LoadQuestTempaltesByClient();
	if(not templates)then return end
	local map = QuestHelp.GetRewardList();


	NPL.load("(gl)script/apps/Aries/Quest/QuestPane.lua");
	local QuestPane = commonlib.gettable("MyCompany.Aries.Quest.QuestPane");
	QuestPane.FindDataSource("template_quest");
	local allquests = QuestPane.datasource_map["template_quest"];
	
	local function DumpQuest(template, pre_title)
		-- if k==1 then echo(template) end
		local str_attr = "";
		local RequestAttr = template.RequestAttr;
        if(RequestAttr)then
            local len = #RequestAttr;
                
            if(len > 0)then
                local k,v;
                for k,v in ipairs(RequestAttr)do
                    local id = v.id;
                    local value = v.value;
                    id = tonumber(id)
                    value = tonumber(value) or 0
                    if(id == 214)then
                        --目前前置条件只判断 等级
						if(v.topvalue)then
							local topvalue = tonumber(v.topvalue);
	                        str_attr = string.format(" (%d-%d级)",value,topvalue);
						else
	                        str_attr = string.format(" (%d级)",value);
						end
                        break;
                    end
                end
            end
        end
		lines[#lines + 1] = format("-----------------------\r\n任务名字：%s%s%s\r\n描述:%s\r\n", pre_title, template.Title or "", str_attr, template.Detail or "");
		local Reward = template.Reward;
		if(Reward)then
			lines[#lines + 1] = "奖励:";
			local Reward_1 = Reward[1];
			if(Reward_1)then
				local _, v_;
				for _, v_ in ipairs(Reward_1) do
					local id = v_.id;
					local value = v_.value;
					local label = "";
					local item = map[id];
					if(item)then
						label = item.label;
					end
					lines[#lines + 1] = format("%s,", label);
				end
			end
			local Reward_2 = Reward[2];
			if(Reward_2)then
				local __,item;
				for __,item in ipairs(Reward_2) do
					local gsid = item.id;
					local value = item.value;
					if(gsid and gsid > 0)then
						local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
						if(gsItem) then
							lines[#lines + 1] = format("%s,", gsItem.template.name or "");
						end
					end
				end
			end
			lines[#lines + 1] = "\r\n";
		end
	end

	local _, world;
	for _, world in ipairs(allquests[1])  do
		local pre_title = (world.attr.label or "")..">" ;
		local _, folder;
		for _, folder in ipairs(world)  do
			pre_title = pre_title .. (folder.attr.label or "")..">"
			local _, item;
			for _, item in ipairs(folder)  do
				-- pre_title = pre_title .. (folder.attr.label or "")
				local template = templates[item.attr.questid];
				if(template) then
					DumpQuest(template, pre_title);
				end
			end
		end
	end

	
	local k,template;
	for k,template in pairs(templates) do
		-- DumpQuest(template);
	end

	if(commonlib.WriteTextToFile(lines, filename)) then
		LOG.std(nil, "debug", "ItemGuides", "successfully printed manual to %s", filename)
	else
		LOG.std(nil, "error", "ItemGuides", "failed to printed manual to %s", filename)
	end
end

function ItemGuides.PrintManualSkills(filename)
	filename = filename or "temp/guides/"..tostring(System.options.version).."/manual_skills.txt";
	local lines = {};

	NPL.load("(gl)script/apps/Aries/NPCs/MagicSchool/CombatSkillLearn.lua");
	local CombatSkillLearn = commonlib.gettable("MyCompany.Aries.Quest.NPCs.CombatSkillLearn");
	
	local all_skills = {
		{card_type = "combat", cardclass="30401", title="寒冰系" }, 
		{card_type = "combat", cardclass="30402", title="烈火系"}, 
		{card_type = "combat", cardclass="30398", title="风暴系"}, 
		{card_type = "combat", cardclass="none", title="大地系"}, 
		{card_type = "combat", cardclass="30400", title="死亡系"}, 
		{card_type = "combat", cardclass="30399", title="生命系"}, 
		{card_type = "combat", cardclass="30112", title="平衡系"}, 


		{card_type = "rune", cardclass="ice", title="符文"}, 
		{card_type = "rune", cardclass="fire", title="符文"}, 
		{card_type = "rune", cardclass="storm", title="符文"}, 
		{card_type = "rune", cardclass="death", title="符文"}, 
		{card_type = "rune", cardclass="life", title="符文"}, 
		{card_type = "rune", cardclass="balance", title="符文"}, 

		{card_type = "pet", cardclass="allpets", title="宠物卡"}, 
	}

	local function DumpAll() 
		local k, v;
		for k, v in pairs(all_skills) do
			local dsItems = v.dsItems;
			local count = dsItems.Count or #dsItems;

			local npc_id = tonumber(v.cardclass);
			if(npc_id) then
				CombatSkillLearn.OnInit(npc_id,true);
				count = CombatSkillLearn.DS_Func_CombatSkillLearn(nil);
			end

			if(count and count> 0) then
				local i;
				for i=1, count do 
					local skill;
					if(npc_id) then
						skill = CombatSkillLearn.DS_Func_CombatSkillLearn(i);
					else
						skill = CombatSkillLearn.DS_Func_SkillsDeck(dsItems, i,v.card_type,v.cardclass,1000,1000, nil);
					end
					if(skill) then
						lines[#lines+1] = format("------------------------\r\n");
						if(skill.pet) then
							lines[#lines+1] = format("%s: %s(%s)\r\n", v.title or "", skill.name or "", skill.pet or "");
						else
							lines[#lines+1] = format("%s: %s\r\n", v.title or "", skill.name or "");
						end
						lines[#lines+1] = format("等级: %s\r\n", tostring(skill.needlevel or 0));
						-- echo(skill)
						local gsItem = ItemManager.GetGlobalStoreItemInMemory(skill.gsid);
						if(gsItem) then
							lines[#lines+1] = format("描述:\r\n%s\r\n", gsItem.template.description or "");
						end
					end
				end
			end
		end
		if(commonlib.WriteTextToFile(lines, filename)) then
			LOG.std(nil, "debug", "ItemGuides", "successfully printed manual to %s", filename)
		else
			LOG.std(nil, "error", "ItemGuides", "failed to printed manual to %s", filename)
		end
	end

	NPL.load("(gl)script/ide/timer.lua");
	local mytimer = commonlib.Timer:new({callbackFunc = function(timer)
		local has_unfinished; 
		local k, v;
		for k, v in pairs(all_skills) do
			if(v.dsItems and v.dsItems.status == 2) then
			else
				has_unfinished = true;
				if(not v.dsItems) then
					local dsItems = {status = nil, };
					local npc_id = tonumber(v.cardclass);
					if(npc_id) then
						CombatSkillLearn.OnInit(npc_id,true);      	
					end
					local count = CombatSkillLearn.DS_Func_SkillsDeck(dsItems, nil,v.card_type,v.cardclass,1000,1000, nil);
					v.dsItems = dsItems;
				end
			end
		end
		if(not has_unfinished) then
			timer:Change();
			DumpAll() ;
		end
	end})
	mytimer:Change(0, 400);
end

function ItemGuides.PrintManualItemWiki(filename)
	filename = filename or "temp/guides/"..tostring(System.options.version).."/manual_item_wiki.txt";
	local lines = {};

	NPL.load("(gl)script/apps/Aries/HaqiShop/AuctionHouse.lua");
	local AuctionHouse = commonlib.gettable("MyCompany.Aries.AuctionHouse");
	local category = AuctionHouse.GetCategoryDS();

	NPL.load("(gl)script/apps/Aries/Desktop/GenericTooltip.lua");
	local GenericTooltip = CommonCtrl.GenericTooltip:new();

	local gsid_map = {};
	local node;
	for node in commonlib.XPath.eachNode(category, "//item") do
		local label = node.attr.label;
		lines[#lines+1] = "--------------------------------\r\n";
		lines[#lines+1] = format("-- %s \r\n", label or "");
		lines[#lines+1] = "--------------------------------\r\n";

		AuctionHouse.ChangeMarketDataSource(node.attr);
		
		local count = AuctionHouse.DS_MarketFunc();
		local i;
		for i = 1, count do
			local item = AuctionHouse.DS_MarketFunc(i)
			if(item) then
				local gsid = item.gsid;
				if(not gsid_map[gsid]) then
					gsid_map[gsid] = true;
					local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
					if(gsItem) then
						lines[#lines + 1] = format("<%s>:", gsItem.template.name or "");
						local stats = gsItem.template.stats
						local level_limit = stats[138] or stats[168];
						if(level_limit)then
							lines[#lines + 1] = format(" 等级:%s",tostring(level_limit));
						end
						if(gsItem.template.description and gsItem.template.description~="") then
							local desc = gsItem.template.description:gsub("#", "")
							lines[#lines + 1] = format(" 描述: %s", desc or "");
						end
						local text = GenericTooltip:getStatsByGsid(false,gsid);
						if(text) then
							text = text:gsub("<[^>]*>", " ")
							if(text and text~="") then
								lines[#lines + 1] = format(" 属性: %s", text or "");
							end
						end
						lines[#lines + 1] = "\r\n"
					end
				end
			end
		end
	end

	if(commonlib.WriteTextToFile(lines, filename)) then
		LOG.std(nil, "debug", "ItemGuides", "successfully printed manual to %s", filename)
	else
		LOG.std(nil, "error", "ItemGuides", "failed to printed manual to %s", filename)
	end
end

function ItemGuides.PrintManualPets(filename)
	filename = filename or "temp/guides/"..tostring(System.options.version).."/manual_pets.txt";
	local lines = {};


	if(commonlib.WriteTextToFile(lines, filename)) then
		LOG.std(nil, "debug", "ItemGuides", "successfully printed manual to %s", filename)
	else
		LOG.std(nil, "error", "ItemGuides", "failed to printed manual to %s", filename)
	end
end

function ItemGuides.PrintManualInstanceAndReward(filename)
	filename = filename or "temp/guides/"..tostring(System.options.version).."/manual_instances.txt";
	local lines = {};

	local bIgnoreInstancedWorld;
	local worlds;
	if(System.options.version == "kids") then 
		worlds = {
			{worldname = "61HaqiTown"},
			{worldname = "FlamingPhoenixIsland"},
			{worldname = "FrostRoarIsland"},
			{worldname = "AncientEgyptIsland"},
			{worldname = "DarkForestIsland"},
		};
		bIgnoreInstancedWorld = true;
	else
		worlds = {
			{worldname = "61HaqiTown_teen"},
			{worldname = "FlamingPhoenixIsland"},
			{worldname = "FrostRoarIsland"},
			{worldname = "AncientEgyptIsland"},
			{worldname = "DarkForestIsland"},
		};
		bIgnoreInstancedWorld = false;
	end

	if(not bIgnoreInstancedWorld) then
		NPL.load("(gl)script/apps/Aries/CombatRoom/LobbyClient.lua");
		local LobbyClient = commonlib.gettable("MyCompany.Aries.CombatRoom.LobbyClient");
		local lc = LobbyClient:GetClient();
		local game_templates = LobbyClient:GetGameTemplates();
		if(game_templates)then
			local k,v; 
			for k,v in pairs(game_templates) do
				if(v.game_type == "PvE") then
					worlds[#worlds+1] = {worldname = v.worldname, game_tmpl = v};
				end
			end
		end
	end

	local _, world
	for _, world in ipairs(worlds) do
		local worldname = world.worldname;
		local config_file = if_else(System.options.version == "kids", "config/Aries/WorldData/", "config/Aries/WorldData_Teen/");
		local world_info = WorldManager:GetWorldInfo(worldname);
		if(world_info) then
			--local worldpathname = world_info.worldpath:match("([^/]+)$")
			local worldpathname = world.keyname or worldname;
			local config_file = config_file..worldpathname..".Arenas_Mobs.xml";
			lines[#lines + 1] = format("----------------------\r\n");
			if(world.game_tmpl) then
				lines[#lines + 1] = format("副本名字：%s\r\n等级:%d-%d\r\n描述:%s\r\n", world.game_tmpl.name or "", world.game_tmpl.min_level or 0, world.game_tmpl.max_level or 55,  world.game_tmpl.desc or "");
			else
				lines[#lines + 1] = format("公共世界名字：%s\r\n", world_info.world_title or "");
			end
			lines[#lines + 1] = format("掉落与奖励：\r\n    ");
			local loots = {};
			ItemGuides.BuildArenaMobLoots(config_file, world.game_tmpl~=nil, loots)
			local _, loot
			local gsid_map = {};
			for _, loot in ipairs(loots) do
				if(not gsid_map[loot.gsid]) then
					gsid_map[loot.gsid] = true;
					local gsItem = ItemManager.GetGlobalStoreItemInMemory(loot.gsid);
					if(gsItem) then
						lines[#lines + 1] = format("%s,", gsItem.template.name);
					end
				end
			end
			lines[#lines + 1] = "\r\n";
		end
	end

	if(commonlib.WriteTextToFile(lines, filename)) then
		LOG.std(nil, "debug", "ItemGuides", "successfully printed manual to %s", filename)
	else
		LOG.std(nil, "error", "ItemGuides", "failed to printed manual to %s", filename)
	end
end

function ItemGuides.PrintManualMakings(filename)
	filename = filename or "temp/guides/"..tostring(System.options.version).."/manual_makings.txt";
	local lines = {};

	local file = ParaIO.open(if_else(System.options.version=="kids", nil, "config/Aries/Others/make_item.csv"), "r");
	if(file:IsValid())then
		local line = file:readline();
		while (line) do
			local class_item, target_gsid, exid = line:match("^(%d+),(%d+),(%d+)")
			class_item = tonumber(class_item)
			target_gsid = tonumber(target_gsid)
			exid = tonumber(exid)
			if(target_gsid) then
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(target_gsid);
				if(gsItem) then
					lines[#lines + 1] = format("------------------\r\n名字: %s\r\n", gsItem.template.name or "");
					if(exid) then
						local ex_item = ItemManager.GetExtendedCostTemplateInMemory(exid);
						if(ex_item) then
							if(ex_item.froms and #(ex_item.froms) > 0) then
								lines[#lines + 1] = "材料: ";
								local _, value
								for _, value in ipairs(ex_item.froms) do
									local gsItem_ = ItemManager.GetGlobalStoreItemInMemory(tonumber(value.key));
									if(gsItem_) then
										lines[#lines + 1] = format("%s(%d个),", gsItem_.template.name, tonumber(value.value));
									end
								end
							end
						end
					end
					lines[#lines + 1] = "\r\n";
				end
			end
			line = file:readline();
		end
		file:close();
	end

	if(commonlib.WriteTextToFile(lines, filename)) then
		LOG.std(nil, "debug", "ItemGuides", "successfully printed manual to %s", filename)
	else
		LOG.std(nil, "error", "ItemGuides", "failed to printed manual to %s", filename)
	end
end

function ItemGuides.AddMonsterInfo(mob_template,template_key)
	if(not ItemGuides.monsterInfo[template_key]) then
		--local displayname = mob_template.attr.displayname;
		local attack = tonumber(mob_template.attr["damage_"..mob_template.attr.phase.."_percent"]);
		if(not attack or attack <= 0) then 
			attack = "无加成";
		end
		local cards = {};
		local cardsWithOdds = {};
		if(mob_template.attr.available_cards) then
			local card,odds;	
			for card,odds in string.gmatch(mob_template.attr.available_cards,"%((%d+),(%d+)%)") do
				local oddsNum = tonumber(odds);
				if(next(cardsWithOdds)) then
					local i = nil;
					local len = #(cardsWithOdds);
					while(next(cardsWithOdds,i)) do
						local _,item = next(cardsWithOdds,i);
						if(i) then
							i = i + 1;
						else
							i = 1;
						end
						if(oddsNum >= item[2]) then
							table.insert(cardsWithOdds,i,{card,oddsNum});
							break;
						else
							if(len == i) then
								table.insert(cardsWithOdds,{card,oddsNum});
								break;
							end
						end
					end
				else
					table.insert(cardsWithOdds,{card,oddsNum});
				end
			end
		end
		if(next(cardsWithOdds)) then
			if(#cardsWithOdds >= 5) then
				cards = {cardsWithOdds[1][1],cardsWithOdds[2][1],cardsWithOdds[3][1],cardsWithOdds[4][1],cardsWithOdds[5][1],};
			else
				for i = 1,#cardsWithOdds do
					table.insert(cards,cardsWithOdds[i][1]);
				end
			end

		end
		local schoolcomparelist = {fire = "烈火系",ice = "寒冰系",life = "生命系",storm = "风暴系",death = "死亡系",};
		ItemGuides.monsterInfo[template_key] = {
			["asset"] =  mob_template.attr.asset,
			["displayname"] =  mob_template.attr.displayname,
			["school"] =  schoolcomparelist[mob_template.attr.phase],
			["hp"] =  mob_template.attr.hp,
			["attack"] =  attack,
		};
		if(next(cards)) then
			ItemGuides.monsterInfo[template_key]["cards"] = cards;
		end
	end
end