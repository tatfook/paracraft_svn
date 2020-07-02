--[[
Title: Quest NPC list and game objects
Author(s): WangTian
Date: 2009/7/20 
Desc: all NPCs avaiable and game objects
revised by LiXizhi 2010/8/18: NPC list now belongs to a given world. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Quest/NPCList.lua");
MyCompany.Aries.Quest.NPCList.Init();
MyCompany.Aries.Quest.NPCList.LoadNPCInWorld("worlds/MyWorlds/61HaqiTown")
MyCompany.Aries.Quest.GameObjectList.DumpInstances("61HaqiTown");

MyCompany.Aries.Quest.NPCList.GetNPCByID(30001)
local npc, worldname = MyCompany.Aries.Quest.NPCList.GetNPCByIDAllWorlds(30001)
-- MyCompany.Aries.Quest.NPCList.NPCs will contain the loaded npc list
------------------------------------------------------------
]]
-- create class
local NPCList = commonlib.gettable("MyCompany.Aries.Quest.NPCList");

-- mapping from world name to NPC xml configuration file. 
local worlds_map = {};
local worlds = {}; -- array of world config files

NPCList.NPCs = {};

-- call this function only once
function NPCList.Init()
	if(NPCList.is_inited) then
		return NPCList.is_inited;
	end
	NPCList.is_inited = true;
	LOG.std(nil, "system", "NPCList", "NPCList initialized");

	if(#worlds_map == 0) then
		if(System and System.options and System.options.version)then
			if(System.options.version=="kids")then
				
				worlds_map = {
					["61HaqiTown"] = {filename = "config/Aries/WorldData/61HaqiTown.NPC.xml", npc_list=nil, world_path = "worlds/MyWorlds/61HaqiTown/", },
					["FlamingPhoenixIsland"] = {filename = "config/Aries/WorldData/FlamingPhoenixIsland.NPC.xml", npc_list=nil, world_path = "worlds/MyWorlds/FlamingPhoenixIsland/", },
					["FrostRoarIsland"] = {filename = "config/Aries/WorldData/FrostRoarIsland.NPC.xml", npc_list=nil, world_path = "worlds/MyWorlds/FrostRoarIsland/", },
					["AncientEgyptIsland"] = {filename = "config/Aries/WorldData/AncientEgyptIsland.NPC.xml", npc_list=nil, world_path = "worlds/MyWorlds/AncientEgyptIsland/", },
					["HaqiTown_FireCavern"] = {filename = "config/Aries/WorldData/HaqiTown_FireCavern.NPC.xml", npc_list=nil, world_path = "worlds/Instances/HaqiTown_FireCavern/", },
					["HaqiTown_FireCavern_110527_1"] = {filename = "config/Aries/WorldData/HaqiTown_FireCavern_110527_1.NPC.xml", npc_list=nil, world_path = "worlds/Instances/HaqiTown_FireCavern/", },
					["HaqiTown_FireCavern_110527_2"] = {filename = "config/Aries/WorldData/HaqiTown_FireCavern_110527_2.NPC.xml", npc_list=nil, world_path = "worlds/Instances/HaqiTown_FireCavern/", },

					["CrazyTower_1_to_5"] = {filename = "config/Aries/WorldData/CrazyTower_1_to_5.NPC.xml", npc_list=nil, world_path = "worlds/Instances/CrazyTower_Fire_1/", },
					["CrazyTower_6_to_10"] = {filename = "config/Aries/WorldData/CrazyTower_6_to_10.NPC.xml", npc_list=nil, world_path = "worlds/Instances/CrazyTower_Fire_2/", },
					["CrazyTower_11_to_15"] = {filename = "config/Aries/WorldData/CrazyTower_11_to_15.NPC.xml", npc_list=nil, world_path = "worlds/Instances/CrazyTower_Ice_1/", },
					["CrazyTower_16_to_20"] = {filename = "config/Aries/WorldData/CrazyTower_16_to_20.NPC.xml", npc_list=nil, world_path = "worlds/Instances/CrazyTower_Ice_2/", },
					["CrazyTower_21_to_25"] = {filename = "config/Aries/WorldData/CrazyTower_21_to_25.NPC.xml", npc_list=nil, world_path = "worlds/Instances/CrazyTower_Storm_1/", },
					["CrazyTower_26_to_30"] = {filename = "config/Aries/WorldData/CrazyTower_26_to_30.NPC.xml", npc_list=nil, world_path = "worlds/Instances/CrazyTower_Storm_2/", },
					["CrazyTower_31_to_35"] = {filename = "config/Aries/WorldData/CrazyTower_31_to_35.NPC.xml", npc_list=nil, world_path = "worlds/Instances/CrazyTower_Life_1/", },
					["CrazyTower_36_to_40"] = {filename = "config/Aries/WorldData/CrazyTower_36_to_40.NPC.xml", npc_list=nil, world_path = "worlds/Instances/CrazyTower_Life_2/", },
					["CrazyTower_41_to_45"] = {filename = "config/Aries/WorldData/CrazyTower_41_to_45.NPC.xml", npc_list=nil, world_path = "worlds/Instances/CrazyTower_Death_1/", },
					["CrazyTower_46_to_50"] = {filename = "config/Aries/WorldData/CrazyTower_46_to_50.NPC.xml", npc_list=nil, world_path = "worlds/Instances/CrazyTower_Death_2/", },
					["CrazyTower_51_to_55"] = {filename = "config/Aries/WorldData/CrazyTower_51_to_55.NPC.xml", npc_list=nil, world_path = "worlds/Instances/CrazyTower_Fire_1/", },
					["CrazyTower_56_to_60"] = {filename = "config/Aries/WorldData/CrazyTower_56_to_60.NPC.xml", npc_list=nil, world_path = "worlds/Instances/CrazyTower_Fire_2/", },
					["CrazyTower_61_to_65"] = {filename = "config/Aries/WorldData/CrazyTower_61_to_65.NPC.xml", npc_list=nil, world_path = "worlds/Instances/CrazyTower_Ice_1/", },
					["CrazyTower_66_to_70"] = {filename = "config/Aries/WorldData/CrazyTower_66_to_70.NPC.xml", npc_list=nil, world_path = "worlds/Instances/CrazyTower_Ice_2/", },
					["CrazyTower_71_to_75"] = {filename = "config/Aries/WorldData/CrazyTower_71_to_75.NPC.xml", npc_list=nil, world_path = "worlds/Instances/CrazyTower_Storm_1/", },
					["CrazyTower_76_to_80"] = {filename = "config/Aries/WorldData/CrazyTower_76_to_80.NPC.xml", npc_list=nil, world_path = "worlds/Instances/CrazyTower_Storm_2/", },
					["CrazyTower_81_to_85"] = {filename = "config/Aries/WorldData/CrazyTower_81_to_85.NPC.xml", npc_list=nil, world_path = "worlds/Instances/CrazyTower_Life_1/", },
					["CrazyTower_86_to_90"] = {filename = "config/Aries/WorldData/CrazyTower_86_to_90.NPC.xml", npc_list=nil, world_path = "worlds/Instances/CrazyTower_Life_2/", },
					["CrazyTower_91_to_95"] = {filename = "config/Aries/WorldData/CrazyTower_91_to_95.NPC.xml", npc_list=nil, world_path = "worlds/Instances/CrazyTower_Death_1/", },
					["CrazyTower_96_to_100"] = {filename = "config/Aries/WorldData/CrazyTower_96_to_100.NPC.xml", npc_list=nil, world_path = "worlds/Instances/CrazyTower_Death_2/", },
					["NewUserIsland"] = {filename = "config/Aries/WorldData/NewUserIsland.NPC.xml", npc_list=nil, world_path = "worlds/MyWorlds/NewUserIsland/", },
					["DarkForestIsland"] = {filename = "config/Aries/WorldData/DarkForestIsland.NPC.xml", npc_list=nil, world_path = "worlds/MyWorlds/DarkForestIsland/", },
					["CrazyTower_WaterBubbleSupreme"] = {filename = "config/Aries/WorldData/CrazyTower_WaterBubbleSupreme.NPC.xml", npc_list=nil, world_path = "worlds/Instances/CrazyTower_Life_1/", },
					["CrazyTower_IroncladSupreme"] = {filename = "config/Aries/WorldData/CrazyTower_IroncladSupreme.NPC.xml", npc_list=nil, world_path = "worlds/Instances/CrazyTower_Storm_1/", },
					["CrazyTower_SnowmanSupreme"] = {filename = "config/Aries/WorldData/CrazyTower_SnowmanSupreme.NPC.xml", npc_list=nil, world_path = "worlds/Instances/CrazyTower_Ice_1/", },
					["CrazyTower_WaterBubbleCasern"] = {filename = "config/Aries/WorldData/CrazyTower_WaterBubbleCasern.NPC.xml", npc_list=nil, world_path = "worlds/Instances/CrazyTower_Life_2/", },
					["CrazyTower_IroncladCasern"] = {filename = "config/Aries/WorldData/CrazyTower_IroncladCasern.NPC.xml", npc_list=nil, world_path = "worlds/Instances/CrazyTower_Storm_2/", },
					["CrazyTower_SnowmanCasern"] = {filename = "config/Aries/WorldData/CrazyTower_SnowmanCasern.NPC.xml", npc_list=nil, world_path = "worlds/Instances/CrazyTower_Ice_2/", },
					["BattleField_ChampionsValley_Master"] = {filename = "config/Aries/WorldData/BattleField_ChampionsValley_Master.NPC.xml", npc_list=nil, world_path = "worlds/Instances/BattleField_ChampionsValley/", },
				};
				worlds = {
					worlds_map["61HaqiTown"], 
					worlds_map["FlamingPhoenixIsland"], 
					worlds_map["FrostRoarIsland"], 
					worlds_map["AncientEgyptIsland"], 
					worlds_map["HaqiTown_FireCavern"], 
					worlds_map["HaqiTown_FireCavern_110527_1"], 
					worlds_map["HaqiTown_FireCavern_110527_2"],
					worlds_map["CrazyTower_1_to_5"],
					worlds_map["CrazyTower_6_to_10"],
					worlds_map["CrazyTower_11_to_15"],
					worlds_map["CrazyTower_16_to_20"],
					worlds_map["CrazyTower_21_to_25"],
					worlds_map["CrazyTower_26_to_30"],
					worlds_map["CrazyTower_31_to_35"],
					worlds_map["CrazyTower_36_to_40"],
					worlds_map["CrazyTower_41_to_45"],
					worlds_map["CrazyTower_46_to_50"],
					worlds_map["CrazyTower_51_to_55"],
					worlds_map["CrazyTower_56_to_60"],
					worlds_map["CrazyTower_61_to_65"],
					worlds_map["CrazyTower_66_to_70"],
					worlds_map["CrazyTower_71_to_75"],
					worlds_map["CrazyTower_76_to_80"],
					worlds_map["CrazyTower_81_to_85"],
					worlds_map["CrazyTower_86_to_90"],
					worlds_map["CrazyTower_91_to_95"],
					worlds_map["CrazyTower_96_to_100"],
					worlds_map["NewUserIsland"],
					worlds_map["DarkForestIsland"],
					worlds_map["CrazyTower_WaterBubbleSupreme"],
					worlds_map["CrazyTower_IroncladSupreme"],
					worlds_map["CrazyTower_SnowmanSupreme"],
					worlds_map["CrazyTower_WaterBubbleCasern"],
					worlds_map["CrazyTower_IroncladCasern"],
					worlds_map["CrazyTower_SnowmanCasern"],
					worlds_map["BattleField_ChampionsValley_Master"],
				};
			else
				worlds_map = {
					["61HaqiTown_teen"] = {filename = "config/Aries/WorldData_Teen/61HaqiTown_teen.NPC.xml", npc_list=nil, world_path = "worlds/MyWorlds/61HaqiTown_teen/", },
					["FlamingPhoenixIsland"] = {filename = "config/Aries/WorldData_Teen/FlamingPhoenixIsland_teen.NPC.xml", npc_list=nil, world_path = "worlds/MyWorlds/FlamingPhoenixIsland_teen/", },
					["FrostRoarIsland"] = {filename = "config/Aries/WorldData_Teen/FrostRoarIsland_teen.NPC.xml", npc_list=nil, world_path = "worlds/MyWorlds/FrostRoarIsland_teen/", },
					["AncientEgyptIsland"] = {filename = "config/Aries/WorldData_Teen/AncientEgyptIsland_teen.NPC.xml", npc_list=nil, world_path = "worlds/MyWorlds/AncientEgyptIsland_teen/", },
					["DarkForestIsland"] = {filename = "config/Aries/WorldData_Teen/DarkForestIsland_teen.NPC.xml", npc_list=nil, world_path = "worlds/MyWorlds/DarkForestIsland_teen/", },
					["CloudFortressIsland"] = {filename = "config/Aries/WorldData_Teen/CloudFortressIsland_teen.NPC.xml", npc_list=nil, world_path = "worlds/MyWorlds/CloudFortressIsland_teen/", },
					["DarkForestIsland_DeathDungeon"] = {filename = "config/Aries/WorldData_Teen/DarkForestIsland_DeathDungeon_teen.NPC.xml", npc_list=nil, world_path = "worlds/Instances/DarkForestIsland_DeathDungeon/", },
					["DarkForestIsland_PirateNest"] = {filename = "config/Aries/WorldData_Teen/DarkForestIsland_PirateNest_teen.NPC.xml", npc_list=nil, world_path = "worlds/Instances/DarkForestIsland_PirateNest/", },
					["DarkForestIsland_PirateSeamaster"] = {filename = "config/Aries/WorldData_Teen/DarkForestIsland_PirateSeamaster_teen.NPC.xml", npc_list=nil, world_path = "worlds/Instances/DarkForestIsland_PirateSeamaster/", },
					["Global_FrostRoarIsland_TreasureHouse"] = {filename = "config/Aries/WorldData_Teen/Global_FrostRoarIsland_TreasureHouse_teen.NPC.xml", npc_list=nil, world_path = "worlds/Instances/Global_TreasureHouse_teen_1/", },
					["HaqiTown_HarshDesert"] = {filename = "config/Aries/WorldData_Teen/HaqiTown_HarshDesert_teen.NPC.xml", npc_list=nil, world_path = "worlds/Instances/HaqiTown_HarshDesert/", },
					["DarkForestIsland_DeathHeadQuarter"] = {filename = "config/Aries/WorldData_Teen/DarkForestIsland_DeathHeadQuarter_teen.NPC.xml", npc_list=nil, world_path = "worlds/Instances/DarkForestIsland_DeathHeadQuarter/", },
				}
				worlds = {
					worlds_map["61HaqiTown_teen"], 
					worlds_map["FlamingPhoenixIsland"], 
					worlds_map["FrostRoarIsland"], 
					worlds_map["AncientEgyptIsland"], 
					worlds_map["DarkForestIsland"],
					worlds_map["CloudFortressIsland"],
					worlds_map["DarkForestIsland_DeathDungeon"],
					worlds_map["DarkForestIsland_PirateNest"],
					worlds_map["DarkForestIsland_PirateSeamaster"],
					worlds_map["Global_FrostRoarIsland_TreasureHouse"],
					worlds_map["HaqiTown_HarshDesert"],
					worlds_map["DarkForestIsland_DeathHeadQuarter"],
					};
			end
			local worldname, npc_data
			for worldname, npc_data in pairs(worlds_map) do
				npc_data.worldname = worldname;
			end
		end
	end
end

-- get npc filename by world name
function NPCList.GetNPCData(worldname)
	return worlds_map[worldname];
end

-- dump all NPC instances in the current world to the default file. 
-- function only used at dev time. 
-- @param worldname: dump NPC in a given world (such as "FlamingPhoenixIsland"). If nil, the current is used. 
function NPCList.DumpInstances(worldname)
	NPL.load("(gl)script/ide/IPCBinding/Framework.lua");
	local EntityView = commonlib.gettable("IPCBinding.EntityView");
	local EntityHelperSerializer = commonlib.gettable("IPCBinding.EntityHelperSerializer");
	local EntityBase = commonlib.gettable("IPCBinding.EntityBase");

	local filename = "script/PETools/Aries/NPC.entity.xml";
	local template = EntityView.LoadEntityTemplate(filename, false);
	if(template) then
		local npcs
		if(worldname and worlds_map[worldname]) then
			if(worlds_map[worldname].filename) then
				npcs = worlds_map[worldname].npc_list;
			else
				npcs = worlds_map[worldname];
			end
		end
		npcs = npcs or NPCList.GetNPCList();
		local npc_id, npc
		for npc_id, npc in pairs(npcs) do
			local npc_id = tonumber(npc_id)
			if(npc_id) then
				npc.npc_id = npc.npc_id or npc_id;
				-- forcing using existing uid
				npc.uid = npc.uid or ParaGlobal.GenerateUniqueID();
				local npc = EntityBase.IDECreateNewInstance(template, npc, nil);
				EntityHelperSerializer.SaveInstance(npc);
				LOG.std("", "debug", "NPCList", "dumping npc_id %s, uid %s", npc.npc_id, npc.uid);
			end
			
		end 
	end
end


-- load all npcs in all worlds into memory, so that we can query by id. 
-- we can call this multiple times, only the first time will take effect. 
function NPCList.LoadNPCs()
	if(NPCList.is_loaded) then
		return 
	else
		NPCList.is_loaded = true;
	end

	local worldname, npc_data
	for worldname, npc_data in pairs(worlds_map) do
		NPCList.LoadNPCData(npc_data)
	end
end

-- load the npc_data
-- @return the NPC_list table. may be empty or nil. 
function NPCList.LoadNPCData(npc_data)
	if(not npc_data) then 
		return 
	end
	if(npc_data.npc_list) then
		return npc_data.npc_list;
	else
		if(npc_data.filename) then
			npc_data.npc_list = {};
			NPL.load("(gl)script/ide/IPCBinding/Framework.lua");
			local EntityView = commonlib.gettable("IPCBinding.EntityView");
			local EntityHelperSerializer = commonlib.gettable("IPCBinding.EntityHelperSerializer");
			local EntityBase = commonlib.gettable("IPCBinding.EntityBase");
			local template = EntityView.LoadEntityTemplate("script/PETools/Aries/NPC.entity.xml", false);
			if(template) then
				local npcs = {};
				local npc_list = {};
				EntityHelperSerializer.LoadInstancesFromFile(template, npc_data.filename, worldpath, npcs);
				LOG.std("", "system","NPCList", "%d npc loaded in file %s", #(npcs), npc_data.filename);
				local index, npc 
				for index, npc in ipairs(npcs) do
					if(npc.npc_id) then
						setmetatable(npc, nil);
						npc.template = nil;
						npc.worldfilter = nil;
						npc.codefile = nil;
						npc.editors = nil;
						npc.eventDispatcher = nil;
						npc.index = index;

						local npc_id = tonumber(npc.npc_id);
						if(npc_id) then
							npc_list[npc_id] = npc;
						end
						-- commonlib.echo(npc, true)
					end
				end
				npc_data.npc_list = npc_list;
			end
		else
			npc_data.npc_list = {};
		end
	end
	return npc_data.npc_list;
end

-- load a NPC for a given world path. it will load the first npc lists whose name matches the worldpath. 
-- @param worldpath: the name of the world,such as "61HaqiTown"
function NPCList.LoadNPCInWorld(worldpath)
	local worldname, npc_data
	for worldname, npc_data in pairs(worlds_map) do
		if(worldpath == worldname) then
			NPCList.NPCs = NPCList.LoadNPCData(npc_data) or {};
			return 
		end
	end
	-- TODO: we may auto try to open "config/Aries/WorldData/[worldname].NPC.xml" to load NPC, here we will load empty table
	NPCList.NPCs = {};
end

-- get the NPC lists in the current world
function NPCList.GetNPCList()
	return NPCList.NPCs;
end

-- get the NPC by id in the current world
function NPCList.GetNPCByID(npc_id)
	return NPCList.NPCs[npc_id];
end

-- Get NPC by id, search in all worlds in given order. 
-- @return npc table and belonging world_name
function NPCList.GetNPCByIDAllWorlds(npc_id)
	NPCList.Init();
	local _, npc_data
	for _, npc_data in ipairs(worlds) do
		local npc_list = NPCList.LoadNPCData(npc_data);
		local npc = npc_list[npc_id];
		if(npc) then
			return npc, npc_data.worldname, npc_data;
		end
	end
end
