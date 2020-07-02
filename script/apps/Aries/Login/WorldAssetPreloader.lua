--[[
Title: Load Pre-world Assets 
Author(s): LiXizhi
Date: 2010/8/19
Desc:  moved world preloader to the xml file "config/Aries/Preloaders/Preloaders.WorldAssset.xml", and include it in the world loading progresbar
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Login/WorldAssetPreloader.lua");
local WorldAssetPreloader = commonlib.gettable("MyCompany.Aries.WorldAssetPreloader")
WorldAssetPreloader.StartWorldPreload(worldname)

local loader = MyCompany.Aries.WorldAssetPreloader.GetLoaderForWorld(worldpath, worldfolder)
loader.callbackFunc = function(nItemsLeft, loader)
	log(nItemsLeft.." assets remaining\n")
	if(nItemsLeft <= 0) then
		Continue();
	end
end
loader:Start();
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
NPL.load("(gl)script/ide/TooltipHelper.lua");
local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
local WorldAssetPreloader = commonlib.gettable("MyCompany.Aries.WorldAssetPreloader")

-- mapping from world name to world filter. such as {[".*"] = {filter=".*", {key="a.x", type="parax"}, {key="b.x", type="mesh"} }}
local worlds = {};
-- mapping from world path to loader
local loaders = {};
local fullworld_loaders = {};
local is_init = false;

-- init from file
function WorldAssetPreloader.Init()
	if(is_init) then
		return;
	end
	is_init = true;
	WorldAssetPreloader.LoadFromFile();
end


local started_world_loaders = {}
-- start loading a given world by name
-- this function can be called multiple times. 
-- @param bForceRestart: if false, multiple calls with the same worldname will be ignored. 
function WorldAssetPreloader.StartWorldPreload(worldname, bForceRestart)
	if(not worldname) then
		return;
	end
	if(not bForceRestart and started_world_loaders[worldname]) then
		return;
	end
	LOG.std(nil, "system", "StartWorldPreload", "now starting world %s", worldname);

	started_world_loaders[worldname] = true;
	WorldAssetPreloader.OnGoalLoaded(nil, {worldname_or_path = worldname, 
		--bHideUI = if_else(System.options.isAB_SDK, false, true), 
		bHideUI = true,
		bNoGoalComplete = true,
	});
end

-- this function is called when loading world goal is loaded. 
-- only the most recent loader
-- @param goal: this parameter is not used, can be nil. 
function WorldAssetPreloader.OnGoalLoaded(goal, params)
	local worldname, worldfolder = params.worldname_or_path, params.worldname_or_path;

	if(worldname) then
		local worldtitle = worldname;
		local world = WorldManager:GetWorldInfo(params.worldname_or_path);
		if(world.worldpath == params.worldname_or_path or world.name == params.worldname_or_path) then
			worldname, worldfolder = world.name, world.worldpath;
			worldtitle = world.world_title or worldtitle;
		end

		local bHideUI = params.bHideUI;
		local bNoGoalComplete = params.bNoGoalComplete;

		local must_complete = params.must_complete == "true";
		-- finish it after 2 seconds
		if(not must_complete) then
			WorldAssetPreloader.goal_timer = WorldAssetPreloader.goal_timer or commonlib.Timer:new({callbackFunc = function(timer)
				if(not bNoGoalComplete) then
					NPL.load("(gl)script/apps/Aries/mcml/pe_goal_pointer.lua");
					local goal_manager = commonlib.gettable("MyCompany.Aries.mcml_controls.goal_manager");
					goal_manager.finish("finish_world_preloader");
				end
			end})
			WorldAssetPreloader.goal_timer:Change(2000, nil);
		end

		if(worldname == WorldAssetPreloader.last_goal_name) then
			return
		else
			WorldAssetPreloader.last_goal_name = worldname;
		end

		if(not bHideUI) then
			BroadcastHelper.PushLabel({id="preloadworld", label = format("正在为您下载【%s】", worldtitle), max_duration=10000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
		end

		local loader = MyCompany.Aries.WorldAssetPreloader.GetLoaderForWorld(worldname, worldfolder)
		loader.callbackFunc = function(nItemsLeft, loader)
			if(nItemsLeft > 0) then
				if(not bHideUI) then
					BroadcastHelper.PushLabel({id="preloadworld", label = string.format("正在为您下载【%s】剩余:%d", worldtitle, nItemsLeft), max_duration=10000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
				end
			else
				-- we will instantiate another loader for 

				local loader = WorldAssetPreloader.GetFullWorldLoaderForWorld(worldname, worldfolder)
				loader.callbackFunc = function(nItemsLeft, loader)
					
					if(nItemsLeft > 0) then
						if(not bHideUI) then
							BroadcastHelper.PushLabel({id="preloadworld", label = string.format("正在为您准备【%s】剩余:%d", worldtitle, nItemsLeft), max_duration=10000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
						end
					else
						local loader = WorldAssetPreloader.GetMobNPCLoaderForWorld(worldname, worldname)

						loader.callbackFunc = function(nItemsLeft, loader)
							if(nItemsLeft > 0) then
								if(not bHideUI) then
									BroadcastHelper.PushLabel({id="preloadworld", label = string.format("正在为您准备【%s】剩余:%d", worldtitle, nItemsLeft), max_duration=10000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
								end
							else
								if(not bHideUI) then
									BroadcastHelper.PushLabel({id="preloadworld", label = format("恭喜！【%s】下载完成了", worldtitle), max_duration=10000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
								end
								LOG.std(nil, "system", "WorldAssetPreloader", "finished preloading world %s", worldname);
								if(not bNoGoalComplete) then
									NPL.load("(gl)script/apps/Aries/mcml/pe_goal_pointer.lua");
									local goal_manager = commonlib.gettable("MyCompany.Aries.mcml_controls.goal_manager");
									goal_manager.finish("finish_world_preloader");
								end
							end
						end
						loader:Start();
					end
				end;
				loader:Start();
			end
		end
		loader:Start();
	end
end


-- load from world name. 
function WorldAssetPreloader.LoadFromFile(filename)
	filename = filename or "config/Aries/Preloaders/Preloaders.WorldAssset.xml"
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(not xmlRoot) then
		LOG.std("", "error", "Preloader", "failed loading preloader config file %s", filename);
		return;
	end
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/worlds/world") do
		local filter = string.lower(node.attr.filter);
		if(filter and (not node.attr.version or node.attr.version==System.options.version)) then
			local world = {filter = filter};
			worlds[filter] = world;
			local nAssetCount = #node;
			local index, asset
			for index = 1, nAssetCount do
				local asset = node[index];
				world[index] = asset.attr;
			end
		end
	end

	-- mapping from level to auto loading settings. 
	local autoloading = {};
	WorldAssetPreloader.autoloading = autoloading;

	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/worlds/autoloading") do
		if(node.attr.version and node.attr.version==System.options.version) then
			local world;
			for world in commonlib.XPath.eachNode(node, "/preload") do
				local attr = world.attr;
				if(attr) then
					local from_level = tonumber(attr.from_level);
					local to_level = tonumber(attr.to_level) or from_level;
					local level;
					for level = from_level, to_level do
						autoloading[level] = attr;
					end
				end
			end
		end
	end
end

-- all worlds that have been loaded. 
local last_autoloads = {};

-- this function is called on user login as well as when user levels up during game play. 
function WorldAssetPreloader.OnPlayerReachedLevel(level)
	level = level or MyCompany.Aries.Player.GetLevel();
	if(WorldAssetPreloader.autoloading) then
		local world = WorldAssetPreloader.autoloading[level];
		if(world and not last_autoloads[world.worldname]) then
			last_autoloads[world.worldname] = true;
			LOG.std(nil, "system", "preload", "loading world asset for level %d with world %s", level, world.worldname)
			local mytimer = commonlib.Timer:new({callbackFunc = function(timer)
				WorldAssetPreloader.StartWorldPreload(world.worldname)
			end})
			-- only start after 1000 seconds
			mytimer:Change(1000, nil);
		end
	end
end

-- this loader shall only be used after the standard world loader is completed. 
-- in additional to standard loader, it will also download all terrain mask files which is the largest file found in world. 
-- and all block world if any. 
function WorldAssetPreloader.GetFullWorldLoaderForWorld(worldpath, worldfolder)
	worldpath = string.lower(worldpath or "");
	worldfolder = worldfolder or worldpath
	
	WorldAssetPreloader.Init();
	local loader = fullworld_loaders[worldpath];
	if(loader) then
		return loader;
	end
	NPL.load("(gl)script/ide/AssetPreloader.lua");
	loader = commonlib.AssetPreloader:new({});
	fullworld_loaders[worldpath] = loader;
	WorldAssetPreloader.AppendBaseWorldAssets(loader, worldfolder, {include_blockworld=true, include_maskfile = true, exclude_standard_file = true});

	return loader;
end

local mob_npc_loaders = {};

-- preload all NPC and mobs for a given world. 
function WorldAssetPreloader.GetMobNPCLoaderForWorld(worldpath, worldname)
	worldpath = string.lower(worldpath or "");
	worldfolder = worldfolder or worldpath
	
	WorldAssetPreloader.Init();
	local loader = mob_npc_loaders[worldpath];
	if(loader) then
		return loader;
	end
	NPL.load("(gl)script/ide/AssetPreloader.lua");
	loader = commonlib.AssetPreloader:new({});
	mob_npc_loaders[worldpath] = loader;
	WorldAssetPreloader.AppendWorldMobAsset(loader, worldname)
	WorldAssetPreloader.AppendWorldNPCAsset(loader, worldname)

	return loader;
end

-- start for a given world 
-- @param worldpath: world name or world path. such as "61HaqiTown"
-- @param worldfolder: this must be the disk root folder of the world(e.g. "worlds/MyWorlds/61HaqiTown"), where we will grep all terrain and config files. if nil, it will be worldpath. 
function WorldAssetPreloader.GetLoaderForWorld(worldpath, worldfolder)
	worldpath = string.lower(worldpath or "");
	worldfolder = worldfolder or worldpath
	
	WorldAssetPreloader.Init();
	local loader = loaders[worldpath];
	if(loader) then
		return loader;
	end
	NPL.load("(gl)script/ide/AssetPreloader.lua");
	loader = commonlib.AssetPreloader:new({});
	loaders[worldpath] = loader;

	local duplicated_keys = {};

	local nCount = 0;
	local filter, world;
	for filter, world in pairs(worlds) do
		if(filter== worldpath or worldpath:match(filter)) then
			local _, asset
			for _, asset in ipairs(world) do
				if(not duplicated_keys[asset.key]) then
					if(asset.type == "parax") then
						loader:AddAssets(ParaAsset.LoadParaX("", asset.key));
					elseif(asset.type == "mesh") then
						loader:AddAssets(ParaAsset.LoadStaticMesh("", asset.key));
					elseif(asset.type == "texture") then
						loader:AddAssets(ParaAsset.LoadTexture("", asset.key, 1));
					elseif(asset.type == "file") then
						loader:AddAssets(asset.key);
					end
					duplicated_keys[asset.key] = true;
					nCount = nCount + 1;
				end
			end
		end
	end
	WorldAssetPreloader.AppendBaseWorldAssets(loader, worldfolder);
	LOG.std("", "system", "preloader", "worldpath:%s has %d preworld assets", worldpath, nCount);
	return loader;
end


-- make world preloader for all terrain elevation and static object files that can not be async loaded
-- So that we can preload all these files before entering the game world, which gaurantees smooth game play.
-- @param params: nil or {include_blockworld=false, include_maskfile=true, exclude_standard_file=true, etc }
function WorldAssetPreloader.AppendBaseWorldAssets(loader, worldpath, params)
	-- copy only used files, this way we can support clone a world from assets manifest files. 
	local base_world = Map3DSystem.World:new();
	base_world:SetDefaultFileMapping(worldpath);
	
	local function default_callback_(bSucceed, filename)
		if(not bSucceed) then
			_guihelper.MessageBox(format("无法下载资源:%s. 请检查你的网络连接，并重新尝试", filename));
		end
	end
	-- max download count is 4. 
	loader:GetFileLoader():SetMaxConcurrentDownload(4);
	loader:AddFileAsset(base_world.sNpcDbFile, default_callback_);
	loader:AddFileAsset(base_world.sAttributeDbFile, default_callback_);
	-- make sure the default main texture is also installed. 
	loader:AddFileAsset("Texture/tileset/generic/MainTexture.dds", default_callback_);

	params = params or {};
	local include_maskfile = params.include_maskfile;
	local include_blockworld = params.include_blockworld;
	local exclude_standard_file = params.exclude_standard_file;
	
	loader:AddFileAsset(base_world.sConfigFile, function(bSucceed, filename)
		if(bSucceed) then
			local config_file = ParaIO.OpenAssetFile(base_world.sConfigFile);
			if(config_file:IsValid()) then
				-- find all referenced files
				local text = config_file:GetText();
				local files = {};
			
				-- check add a file
				local function check_add_file(filename)
					if(not files[filename]) then
						LOG.std(nil, "debug", "WorldAssetPreloader", "adding file %s", filename)
						files[filename] = true;
						loader:AddFileAsset(filename);
					end
				end
				
				local w;
				for w in string.gmatch(text, "[^\r\n]+") do
					w = string.match(w, "[^/]+config%.txt$");
					if(w) then
						local config_file_name = worldpath.."/config/"..w;
						
						loader:AddFileAsset(config_file_name, function(bSucceed, filename)
							
							if(bSucceed) then
								local file = ParaIO.OpenAssetFile(config_file_name);
								if(file:IsValid()) then
									local tile_text = file:GetText();
									
									for w in string.gmatch(tile_text, "[^\r\n]+") do
										local content;
										if(not exclude_standard_file) then
											content = string.match(w, "[^/]+%.onload%.lua$");
											if(content) then
												check_add_file(worldpath.."/script/"..content);
												-- check_add_file(worldpath.."/config/"..string.gsub(content, "onload%.lua$", "mask"));
											end
											local content = string.match(w, "[^/]+%.raw$");
											if(content) then
												check_add_file(worldpath.."/elev/"..content);
											end
											local content = string.match(w, "^%(%S+,%s*[^/]*/regions/([^/]+%.png)%)$");
											if(content) then
												check_add_file(worldpath.."/regions/"..content);
											end
											local content = string.match(w, "^MainTextureFile = (%S+)$");
											if(content) then
												check_add_file(content);
											end
										end
										if(include_maskfile) then
											local content = string.match(w, "^NumOfDetailTextures = (%d+)$");
											if(content and tonumber(content)> 0 ) then
												local mask_file = config_file_name:gsub("config%.txt$", "mask")
												if(mask_file) then
													check_add_file(mask_file);
												end
											end
										end
										if(include_blockworld) then
											local config_file_name = worldpath.."/blockWorld/blockTemplate.xml";
											-- TODO: adding all block world raw file here. 
											-- check for blockWorld *.raw file
										end
									end
									file:close();
								else
									LOG.std(nil, "error", "WorldAssetPreloader", "unable to open file %s", filename)
								end
							else
								_guihelper.MessageBox(format("无法下载资源:%s. 请检查你的网络连接，并重新尝试", filename));
							end
						end)
					end	
				end
				config_file:close();
			else
				LOG.std(nil, "error", "WorldAssetPreloader", "unable to open file %s", filename)
			end
		else
			_guihelper.MessageBox(format("无法下载资源:%s. 请检查你的网络连接，并重新尝试", filename));
		end
	end)
end

function WorldAssetPreloader.AppendWorldMobAsset(loader, worldname)
	NPL.load("(gl)script/apps/Aries/HaqiShop/ItemGuides.lua");
	local ItemGuides = commonlib.gettable("MyCompany.Aries.ItemGuides");

	local files = {};
	-- check add a file
	local function check_add_file(filename)
		if(not files[filename]) then
			LOG.std(nil, "debug", "WorldAssetPreloader", "adding file %s", filename)
			files[filename] = true;
			loader:AddFileAsset(filename);
		end
	end

	local config_file = if_else(System.options.version == "kids", "config/Aries/WorldData/", "config/Aries/WorldData_Teen/");
	local world_info = WorldManager:GetWorldInfo(worldname);
	
	if(world_info) then
		local worldpathname = worldname;
		local config_file = config_file..worldpathname..".Arenas_Mobs.xml";
		
		local xmlRoot = ItemGuides.GetArenaMobConfigXMLNode(config_file);
		if(not xmlRoot) then
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
						if(not template) then
							return
						end
						-- fetch all mob template attributes
						local mob_template;
						for mob_template in commonlib.XPath.eachNode(template, "/mobtemplate/mob") do
							local asset = mob_template.attr.asset;
							if(asset) then
								check_add_file(asset)
							end
						end
					end
				end
			end
		end
	end
end

function WorldAssetPreloader.AppendWorldNPCAsset(loader, worldname)
	NPL.load("(gl)script/apps/Aries/Quest/NPCList.lua");
	local NPCList = commonlib.gettable("MyCompany.Aries.Quest.NPCList");

	local npc_data = NPCList.GetNPCData(worldname);
	if(not npc_data) then
		return;
	end
	local npc_list = NPCList.LoadNPCData(npc_data);
	if(npc_list) then
		local files = {};
		-- check add a file
		local function check_add_file(filename)
			if(not files[filename]) then
				LOG.std(nil, "debug", "WorldAssetPreloader", "adding file %s", filename)
				files[filename] = true;
				loader:AddFileAsset(filename);
			end
		end

		local _, npc;
		for _, npc in pairs(npc_list) do
			if(npc.assetfile_model) then
				check_add_file(npc.assetfile_model);
			end
			if(npc.assetfile_char) then
				check_add_file(npc.assetfile_char);
			end
		end
	end
end