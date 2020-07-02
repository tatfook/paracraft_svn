--[[
Title: combat system Entry for Aries App
Author(s): WangTian
Date: 2009/4/7
Area: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Combat/MsgHandler.lua");
local MsgHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");
------------------------------------------------------------
]]

NPL.load("(gl)script/apps/Aries/Combat/main.lua");
NPL.load("(gl)script/apps/Aries/Quest/NPC.lua");
NPL.load("(gl)script/apps/Aries/Combat/ObjectManager.lua");
NPL.load("(gl)script/apps/Aries/Desktop/AriesDesktop.lua");
NPL.load("(gl)script/apps/Aries/Desktop/Dock.lua");
NPL.load("(gl)script/apps/Aries/Desktop/TargetArea.lua");
NPL.load("(gl)script/apps/Aries/Combat/SpellPlayer.lua");
NPL.load("(gl)script/ide/Debugger/NPLProfiler.lua");
NPL.load("(gl)script/apps/Aries/Desktop/Areas/BattleChatArea.lua");
NPL.load("(gl)script/apps/Aries/NPCs/Combat/39001_BasicMob_AI.lua");
NPL.load("(gl)script/apps/Aries/Combat/CombatResultBubble.lua");
NPL.load("(gl)script/apps/Aries/Dialog/Dialog_NPC.lua");
NPL.load("(gl)script/apps/Aries/NPCs/Combat/39000_BasicArena.lua");
NPL.load("(gl)script/apps/Aries/Scene/AutoCameraController.lua");
NPL.load("(gl)script/apps/Aries/mcml/pe_aries_textsprite.lua");
local AutoCameraController = commonlib.gettable("MyCompany.Aries.AutoCameraController");
local MyCardsManager = commonlib.gettable("MyCompany.Aries.Inventory.Cards.MyCardsManager");
local Combat = commonlib.gettable("MyCompany.Aries.Combat");
local npl_profiler = commonlib.gettable("commonlib.npl_profiler");
local NPC = commonlib.gettable("MyCompany.Aries.Quest.NPC");
local Dock = commonlib.gettable("MyCompany.Aries.Desktop.Dock");
local TargetArea = commonlib.gettable("MyCompany.Aries.Desktop.TargetArea");
local ObjectManager = commonlib.gettable("MyCompany.Aries.Combat.ObjectManager");
local SpellPlayer = commonlib.gettable("MyCompany.Aries.Combat.SpellPlayer");
local Pet = commonlib.gettable("MyCompany.Aries.Pet");
local SystemInfo = commonlib.gettable("Map3DSystem.SystemInfo");
local NPCAIMemory = commonlib.gettable("MyCompany.Aries.Quest.NPCAIMemory");
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandGateway.lua");
local HomeLandGateway = commonlib.gettable("System.App.HomeLand.HomeLandGateway");
local tostring = tostring
local tonumber = tonumber
local string_match = string.match;
local string_find = string.find;
local table_insert = table.insert;
local math_random = math.random;
local System = System;
local ParaScene_GetObject = ParaScene.GetObject
local ProfileManager = commonlib.gettable("System.App.profiles.ProfileManager");
local Desktop = commonlib.gettable("MyCompany.Aries.Desktop");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
local LOG = LOG;
-- create class
local MsgHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");
local CombatTutorial = commonlib.gettable("MyCompany.Aries.Quest.NPCs.CombatTutorial");
local CombatPipTutorial = commonlib.gettable("MyCompany.Aries.Quest.NPCs.CombatPipTutorial");
local ItemManager = commonlib.gettable("System.Item.ItemManager");
local Cursor = commonlib.gettable("Map3DSystem.UI.Cursor");
local BasicArena = commonlib.gettable("MyCompany.Aries.Quest.NPCs.BasicArena");

local Player = commonlib.gettable("MyCompany.Aries.Player");

NPL.load("(gl)script/ide/TooltipHelper.lua");
local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");

NPL.load("(gl)script/apps/Aries/Desktop/EXPBuffArea.lua");
local EXPBuffArea = commonlib.gettable("MyCompany.Aries.Desktop.EXPBuffArea");

local pe_css = commonlib.gettable("Map3DSystem.mcml_controls.pe_css");

NPL.load("(gl)script/apps/Aries/Desktop/AntiIndulgenceArea.lua");
local AntiIndulgenceArea = commonlib.gettable("MyCompany.Aries.Desktop.AntiIndulgenceArea");

NPL.load("(gl)script/apps/Aries/Combat/ServerObject/card_server.lua");
local Card = commonlib.gettable("MyCompany.Aries.Combat_Server.Card");

NPL.load("(gl)script/apps/Aries/Combat/UI/MyCards.lua");
local MyCards = commonlib.gettable("MyCompany.Aries.Combat.MyCards");

NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetHelper.lua");
local CombatPetHelper = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetHelper");

NPL.load("(gl)script/apps/Aries/Dialog/Headon_OPC.lua");
local Headon_OPC = commonlib.gettable("MyCompany.Aries.Dialog.Headon_OPC");

NPL.load("(gl)script/ide/MotionEx/MotionXmlToTable.lua");
local MotionXmlToTable = commonlib.gettable("MotionEx.MotionXmlToTable");

NPL.load("(gl)script/apps/Aries/Desktop/Functions/FateCard.lua");
local FateCard = commonlib.gettable("MyCompany.Aries.Desktop.FateCard");

-- base arena id
local base_arena_id = 1001;

-- if user in too far away from the combat the spell play is cancelled
local cancel_spellplay_distance_sq = 60*60;

-- show hp slot and buffs during spell play
local bShowHPSlotsDuringSpellPlay = true;

-- my arena data
MsgHandler.MyArenaData = nil;

-- my arena picked cards
MsgHandler.MyArenaPickedCards = {};

-- current hp and maximum health
-- maximum health is set on every pet data update
local current_hp = 500;
local max_hp = 500;

-- arena key and value data pairs
local arena_key_valuedata_pairs = {};
local arena_key_valuedata_inactiveplayer_pairs = {};

-- mapping from arena_id (number) to a meta table containing static or dynamic attributes associated with the given arena
-- such as {is_arena_created, is_mobs_created, is_arena_visible}
local arena_meta_data_map = {};

-- mapping from arena_id (number) to a parsed data table containing last updated arena value data
local arena_data_map = {};

-- mob id and value data pairs
local mob_id_valuedata_pairs = {};

-- mapping from mob id to arena data table
local mob_id_arena_map = {};

-- hp and level mapping
local hp_level_mapping = nil;

-- record myself arena id and slot id
local myself_arena_id = nil;
local myself_slot_id = nil;

-- record last updates arena values
local last_updated_arena_values = {};
local last_updated_arena_inactiveplayer_values = {};

-- last updated server object values
local last_updated_serverobject_normalupdate_values = {};
local last_updated_serverobject_normalupdate_inactiveplayer_values = {};

--local myself_current_hp = 0;

local isMsgHandlerInited = false;

local isCardTemplateInited = false;
local isMobCCSInited = false;

local canUseHPPotion = true;

-- auto ai mode
local bAutoAIMode = false;

-- use default camera
local bUseDefaultCamera = true;

-- enraged mob scale
local ENRAGED_SCALE = 1.5;

-- not yet normal updated
local bNotYetNormalUpdated = true;

-- pvp forbidden keys
local pvp_forbidden_keys = {
};

-- instance forbidden keys
local instance_forbidden_keys = {
};

local bLootedGlobal_CatTreasureHouse_Adv = false;

local mob_ccs = {};

local bCheckedInternetCafeStatus = false;

-- init in each world initialization
function MsgHandler.Init()

	myself_arena_id = nil;
	myself_slot_id = nil;

	bNotYetNormalUpdated = true;

	-- clear the arena key and value pairs
	arena_key_valuedata_pairs = {};
	arena_key_valuedata_inactiveplayer_pairs = {};
	-- clear the mob id and value pairs
	mob_id_valuedata_pairs = {};
	-- reset last updates arena values
	last_updated_arena_values = {};
	last_updated_arena_inactiveplayer_values = {};
	-- reset last updates server object values
	last_updated_serverobject_normalupdate_values = {};
	last_updated_serverobject_normalupdate_inactiveplayer_values = {};
	-- clear and reset arena meta data
	arena_meta_data_map = {};
	-- clear and reset arena data
	arena_data_map = {};

	-- clear basic mob memory
	-- NOTE: solve the mob off position bug after enter and leave homeland
	NPCAIMemory.ClearMemory(39001);

	-- resume the GSL self update
	System.GSL.SuspendSelfUpdate(false);
	
	-- get pet level
	MsgHandler.UpdateMaxHP(Combat.GetMyCombatLevel());
	
	
	-- 996_CombatHPTag
	local hp = current_hp;
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	local bHas, guid = hasGSItem(996);
	if(bHas) then
		local item = ItemManager.GetItemByGUID(guid);
		if(item and item.guid > 0) then
			hp = tonumber(item.clientdata or "") or current_hp;
		end
	end

	-- set the current hp
	
	MsgHandler.SetCurrentHP(hp);

	-- update exp and hp ui
	Dock.UpdateLevelExpAndHP();
	
	NPL.load("(gl)script/ide/timer.lua");
	MsgHandler.update_current_hp_timer = MsgHandler.update_current_hp_timer or commonlib.Timer:new({callbackFunc = MsgHandler.TryUpdateCurrentHP});
	MsgHandler.update_current_hp_timer:Change(0, 5000);
	
	NPL.load("(gl)script/ide/timer.lua");
	MsgHandler.update_cursor_while_blockinput = MsgHandler.update_cursor_while_blockinput or commonlib.Timer:new({callbackFunc = MsgHandler.UpdateCursorTooltip});
	MsgHandler.update_cursor_while_blockinput:Change(0, 100);
	
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = function(nCode, appName, msg, value)
			if(msg.aries_type == "OnTryToLeaveTown") then
				-- force update the current hp as clientdata
				MsgHandler.ForceUpdateCurrentHP()
			end
		end, 
		hookName = "Aries_Combat_OnTryToLeaveTown", appName = "Aries", wndName = "main"});
	
	--初始化战斗聊天图标
	MyCompany.Aries.Combat.UI.BattleChatArea.Init();

	if(not isMsgHandlerInited) then
		MsgHandler.InitCardTemplateIfNot();
		MsgHandler.InitMobCCSIfNot();
	end

	BasicArena.EnableGlobalTimer(true, 500);

	isMsgHandlerInited = true;

	bUseDefaultCamera = MyCompany.Aries.app:ReadConfig("bUseDefaultCamera", true);
	
	if(System.options.version == "kids") then
		instance_forbidden_keys = {
		};
		pvp_forbidden_keys = {
			["Balance_Rune_AreaAttackCard_Elementary"] = true,
			["Balance_Rune_AreaAttackCard_Middle"] = true,
			["Balance_Rune_AreaAttackCard_High"] = true,
		};
	end

	bLootedGlobal_CatTreasureHouse_Adv = false;
end

function MsgHandler.InitCardTemplateIfNot()
	if(not isCardTemplateInited) then
		if(System.options.version == "teen") then
			Card.InitCardDataFromXML("config/Aries/Cards/CardList.teen.xml");
			Card.InitCharmAndWardDataFromFile("config/Aries/Cards/CharmWardList.teen.xml");
		else
			Card.InitCardDataFromXML("config/Aries/Cards/CardList.xml");
			Card.InitCharmAndWardDataFromFile("config/Aries/Cards/CharmWardList.xml");
		end
	end
	isCardTemplateInited = true;
end

function MsgHandler.InitMobCCSIfNot()
	if(not isMobCCSInited) then
		mob_ccs = {}; -- reset
		local mob_ccs_file;
		if(System.options.version == "kids") then
			mob_ccs_file = "config/Aries/Others/mob_ccs.kids.xml";
		elseif(System.options.version == "teen") then
			mob_ccs_file = "config/Aries/Others/mob_ccs.teen.xml";
		end
		if(mob_ccs_file) then
			local xmlRoot = ParaXML.LuaXML_ParseFile(mob_ccs_file);
			if(not xmlRoot) then
				LOG.std("", "error", "combat", "failed loading mob_ccs config file: %s", tostring(mob_ccs_file));
			else
				-- character and ccs pair
				local each_character;
				for each_character in commonlib.XPath.eachNode(xmlRoot, "/mob_ccs/character") do
					local asset = each_character.attr.asset;
					if(asset) then
						local mapping = {};
						local each_style;
						for each_style in commonlib.XPath.eachNode(each_character, "/style") do
							local name = each_style.attr.name;
							local ccs = each_style.attr.ccs;
							if(name and ccs) then
								mapping[name] = ccs;
							end
						end
						mob_ccs[asset] = mapping;
					end
				end
			end
		end
	end
	isMobCCSInited = true;
end

local instance_doors = {
	["worlds/Instances/FlamingPhoenixIsland_TheGreatTree/"] = "model/01building/v5/04instance/ShenmuSpace/ShenmuSpaceDoor.x",
	["worlds/Instances/HaqiTown_FireCavern/"] = "model/01building/v5/04instance/FireCave/FireCaveDoor_entrance.x",
	["worlds/Instances/HaqiTown_LightHouse/"] = "model/01building/v5/04instance/LightTower/LightTower1/LightTower1_door.x",
	["worlds/Instances/Global_TreasureHouse/"] = "model/01building/v5/04instance/TreasureHouse/TreasureHouse_door.x",
	--["worlds/Instances/HaqiTown_LightHouse_S1/"] = "model/01building/v5/04instance/LightTower/LightTower1/LightTower1_door.x",
	--["worlds/Instances/HaqiTown_LightHouse_S8/"] = "model/01building/v5/04instance/LightTower/LightTower8/LightTower8_door.x",
	--["worlds/Instances/HaqiTown_LightHouse_S26/"] = "model/01building/v5/04instance/LightTower/LightTower26/LightTower26_door.x",
	--["worlds/Instances/HaqiTown_LightHouse_S61/"] = "model/01building/v5/04instance/LightTower/LightTower26/LightTower26_door.x",
};

function MsgHandler.OnWorldLoad()
	
	bLootedGlobal_CatTreasureHouse_Adv = false;

	-- create instance doors
	local current_worlddir = ParaWorld.GetWorldDirectory();
	local instance_door = instance_doors[current_worlddir];

	if(ParaScene.LoadNPCsByRegion) then
		if(current_worlddir == "worlds/Instances/HaqiTown_LightHouse/") then
			ParaScene.LoadNPCsByRegion(0, 0, 0, 40000, 40000, 40000, false);
		end
	else
		if(current_worlddir == "worlds/Instances/HaqiTown_LightHouse/") then
			local i = 1;
			for i = 1, 100 do
				ParaTerrain.GetElevation(10000 + 300 * i -36, 20000);
			end
		end
	end
	
	local worldinfo = WorldManager:GetCurrentWorld();
	local worldname = worldinfo.name;

	if(worldname == "FlamingPhoenixIsland_TheGreatTree_Hero") then
		-- skip portal stage in FlamingPhoenixIsland_TheGreatTree_Hero isntance
		return;
	end
	
	if(instance_door) then
		local created = false;
		-- find all teleport portal 
		local i = 1;
		for i = 1, 300 do
			local portal = ParaScene.GetCharacter("teleport-portal:"..i);
			if(portal:IsValid() == true) then
				if(math.mod(i, 2) == 1) then
					local x, y, z = portal:GetPosition();
					if(i >= 121) then
						x = x - 2;
					end
					-- arena entity
					local params = {
						position = {x, y, z},
						assetfile_char = "character/common/dummy/elf_size/elf_size.x", skiprender_char = true,
						assetfile_model = instance_door,
						facing = portal:GetFacing(),
						scaling = 1,
						instance = i;
					};
					local arena_char, arena_model = NPC.CreateNPCCharacter(431980, params);
					if(arena_model and arena_model:IsValid() == true) then
						arena_model:SetAttribute(8192, true);
						arena_model:SetPhysicsGroup(1);
					end
					-- put the portal on the ground
					if(y > 10000) then
						portal:SetPosition(x, y - 20000, z);
					end
					
				else
					local x, y, z = portal:GetPosition();
					if(i >= 121) then
						x = x + 1;
						portal:SetPosition(x + 2, y, z);
						portal:UpdateTileContainer();
					end
					-- hide the teleport portal back to the previous level
					local x, y, z = portal:GetPosition();
					portal:SetPosition(x, y + 5000, z);
				end
				created = true;
			else
				if(created == true) then
					---- NOTE: the instance door not continuous
					--break;
				end
			end
		end
		if(created ~= true) then
			local anim_time = 500;
			UIAnimManager.PlayCustomAnimation(anim_time, function(elapsedTime)
				if(elapsedTime == anim_time) then
					MsgHandler.OnWorldLoad();
				end
			end);
		end
	end
end

-- on world load and normal updated
function MsgHandler.OnWorldLoadAndNormalUpdated()
	if(System.options.version == "kids") then
		-- unlock crazy tower
		local locking_arena_world_name = {
			["CrazyTower_36_to_40"] = true,
			["CrazyTower_41_to_45"] = true,
			["CrazyTower_46_to_50"] = true,
			["CrazyTower_51_to_55"] = true,
			["CrazyTower_56_to_60"] = true,
			["CrazyTower_61_to_65"] = true,
			["CrazyTower_66_to_70"] = true,
			["CrazyTower_71_to_75"] = true,
			["CrazyTower_76_to_80"] = true,
			["CrazyTower_81_to_85"] = true,
			["CrazyTower_86_to_90"] = true,
			["CrazyTower_91_to_95"] = true,
			["CrazyTower_96_to_100"] = true,
		};
		local world_info = WorldManager:GetCurrentWorld();
		if(world_info) then
			if(locking_arena_world_name[world_info.name]) then
				NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
				local worldname = world_info.world_title;
				local itemname = "";
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(17404);
				if(gsItem) then
					-- 17404_TheClearlySpar
					itemname = gsItem.template.name;
				end
				_guihelper.Custom_MessageBox(string.format("【%s】关卡藏有隐藏BOSS，必须先击败任意一个小怪才能引出BOSS。如果你带有【%s】，可以立刻与BOSS战斗！", worldname, itemname),function(result)
					if(result == _guihelper.DialogResult.Yes)then
						-- use item
						local hasGSItem = ItemManager.IfOwnGSItem;
						local bHas, guid = hasGSItem(17404);
						if(bHas) then
							local item = ItemManager.GetItemByGUID(guid);
							if(item and item.guid > 0) then
								item:OnClick("left");
								return;
							end
						end
						_guihelper.Custom_MessageBox(string.format("你还没有【%s】，需要立刻购买吗？", itemname), function(result)
							if(result == _guihelper.DialogResult.Yes) then
								local command = System.App.Commands.GetCommand("Profile.Aries.PurchaseItemWnd");
								if(command) then
									command:Call({gsid = 17404});
								end
							end
						end, _guihelper.MessageBoxButtons.YesNo, {show_label = true, yes = "立刻购买", no = "看看再说"});
					end
				end, _guihelper.MessageBoxButtons.YesNo, {show_label = true, yes = "立刻解锁", no = "看看再说"});
			end
		end
	end
end

function MsgHandler.On_BasicArenaTimer()
	-- create instance doors
	local current_worlddir = ParaWorld.GetWorldDirectory();
	local instance_door = instance_doors[current_worlddir];
	if(not instance_door) then
		return;
	end
	local arena_data_map = MsgHandler.Get_arena_data_map();
	local door_locks = {};
	local arena_id, data;
	for arena_id, data in pairs(arena_data_map) do
		if(data.door_lock) then
			local id = tonumber(data.door_lock);
			if(door_locks[id] == true) then
				door_locks[id] = true;
			elseif(data.bIncludedAnyAliveMob) then
				door_locks[id] = true;
			else
				door_locks[id] = false;
			end
		end
	end
	
	-- find all teleport portal 
	local i = 1;
	for i = 1, 300 do
		local portal = ParaScene.GetCharacter("teleport-portal:"..i);
		if(portal:IsValid() == true) then
			local x, y, z = portal:GetPosition();
			local door_model = NPC.GetNpcModelFromIDAndInstance(431980, i);
			if(door_model and door_model:IsValid() == true) then
				if(door_locks[i] == true) then
					-- close
					local att = door_model:GetAttributeObject();
					att:SetField("AnimID", 0);
					if(y > 10000) then
						portal:SetPosition(x, y - 20000, z);
					end
				elseif(door_locks[i] == false) then
					-- open
					local att = door_model:GetAttributeObject();
					att:SetField("AnimID", 70);
					if(y < 10000) then
						portal:SetPosition(x, y + 20000, z);
					end
				else
					local worldinfo = WorldManager:GetCurrentWorld();
					local worldname = worldinfo.name;

					if(worldname == "HaqiTown_FireCavern_110527_1" or 
						worldname == "HaqiTown_FireCavern_110527_2" or 
						worldname == "FlamingPhoenixIsland_TheGreatTree_110610_3") then
						-- close
						local att = door_model:GetAttributeObject();
						att:SetField("AnimID", 0);
						portal:SetPosition(x, - 10000, z);
					else
						-- don't need lock always open
						local att = door_model:GetAttributeObject();
						att:SetField("AnimID", 70);
						if(y < 10000) then
							portal:SetPosition(x, y + 20000, z);
						end
					end
				end
			end
		else
			--break;
		end
	end
end

function MsgHandler.GetCurrentHP()
	if(current_hp > max_hp) then
		current_hp = max_hp;
	end
	return current_hp;
end

function MsgHandler.GetMaxHP()
	return max_hp;
end

-- get the current hp of player on my arena
-- return nil if not valid or exist
-- @return: current_hp, max_hp
function MsgHandler.GetPlayerCurrentHPOnMyArena(nid)
	local my_arena_data = MsgHandler.GetMyArenaData();
	if(my_arena_data) then
		local _, each_player;
		for _, each_player in pairs(my_arena_data) do
            if(each_player.nid == nid) then
				return each_player.current_hp, each_player.max_hp;
			end
		end
	end
end

-- get proper arena position for teleport. 
-- @return  currentworldname, pos, cameraPos:
function MsgHandler.GetArenaTeleportPos(arena)
	if(arena) then
		return MsgHandler.GetArenaTeleportPosByCenter(arena.p_x,arena.p_y,arena.p_z);
	end
end

-- get proper arena position for teleport. 
-- @param x,y,z: center of the arena
-- @return  currentworldname, pos, cameraPos:
function MsgHandler.GetArenaTeleportPosByCenter(x,y,z)
	if(x) then
		local world_info = WorldManager:GetCurrentWorld();
		local facing = world_info.arena_teleport_facing or 1.57;
		local radius = BasicArena.GetEnterCombatRadius() + 1;
		x = x + radius * math.sin(facing);
		z = z + radius * math.cos(facing);
		if(x and y and z)then
			local Position = {x,y,z, facing+1.57};
			local CameraPosition = { 15, 0.27, facing + 1.57};
			return world_info.name, Position, CameraPosition;
		end
	end
end

-- update health according to dragon combat level
function MsgHandler.UpdateMaxHP(level)
	--if(not hp_level_mapping) then
		---- empty hp and level mapping table
		--hp_level_mapping = {};
		---- spell cast config 
		--local filename = "config/Aries/HP/HP_level_mapping.xml";
		--local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
		--if(not xmlRoot) then
			--LOG.std("", "error","combat","failed loading hp and level config file: %s", filename);
		--else
			---- hp and level mapping pair
			--local pair;
			--for pair in commonlib.XPath.eachNode(xmlRoot, "/mappings/pair") do
				--if(pair.attr and pair.attr.level and pair.attr.hp) then
					--local level = tonumber(pair.attr.level);
					--local hp = tonumber(pair.attr.hp);
					--hp_level_mapping[level] = hp;
				--end
			--end
		--end
	--end
	--if(hp_level_mapping[level]) then
		--max_hp = hp_level_mapping[level];
	--else
		--max_hp = 300 + (level + 1) * 30;
	--end

	---- 2010-7-6: Ina(Ina.Fu) 15:41:30 INT(POWER(A4,1.6)*2)+300+A4*30
	--max_hp = math.floor(math.pow(level, 1.6) + 300 + level * 30);
	max_hp = Combat.GetUpdateMaxHP(level);
end

-- get my arena data
-- NOTE: this is generally used in upper and lower hp slot page controls
function MsgHandler.GetMyArenaData()
	return MsgHandler.MyArenaData;
end

-- get my arena picked cards
-- NOTE: this is generally used in lower hp slot page control
function MsgHandler.GetMyArenaPickedCards()
	return MsgHandler.MyArenaPickedCards;
end

-- get the key and arena valuedata pairs
-- NOTE: valuedata is the table parsed by function MsgHandler.ParseNormalUpdateMessage
function MsgHandler.Get_arena_key_valuedata_pairs()
	return arena_key_valuedata_pairs;
end

-- get the mob id and value data pairs
-- NOTE: valuedata is the each mob table parsed by function MsgHandler.ParseNormalUpdateMessage
--		mob_id_valuedata_pairs[eachmob.id] = commonlib.deepcopy(eachmob);
function MsgHandler.Get_mob_id_valuedata_pairs()
	return mob_id_valuedata_pairs;
end

-- Get arena meta data by id. 
-- @param id: the arena id(number). please note this is NOT the key used in arena_key_valuedata_pairs
-- @return create/get a table containing the meta data for a given arena. During normal update, this table is shared. 
function MsgHandler.Get_arena_meta_data_by_id(arena_id)
	local o = arena_meta_data_map[arena_id];
	if(o) then
		return o;
	else
		o = {arena_id = arena_id};
		arena_meta_data_map[arena_id] = o;
		return o;
	end
end

function MsgHandler.Get_arena_meta_data()
	return arena_meta_data_map;
end

function MsgHandler.Get_arena_data_map()
	return arena_data_map;
end

function MsgHandler.Get_arena_data_by_id(arena_id)
	local o = arena_data_map[arena_id];
	if(o) then
		return o;
	else
		o = {arena_id = arena_id};
		arena_data_map[arena_id] = o;
		return o;
	end
end

-- get the mob data table. 
-- @param mob_id: mob id (number)
--@return nil or a mob data table. 
function MsgHandler.Get_mob_data_by_id(mob_id)
	return mob_id_valuedata_pairs[mob_id];
end

-- return the arena data table by mob id. 
function MsgHandler.Get_arena_data_by_mob_id(mob_id)
	return mob_id_arena_map[mob_id]
end

function MsgHandler.GetCanUseHPPotion()
	return canUseHPPotion;
end

function MsgHandler.PostUseHPPotion()
	canUseHPPotion = false;
end

-- get the arena position where the target mob has the highest HP. 
-- hp is computed as (All_Mob_current_hp - Other_mob_hp - players_on_arena*100dps). the virtual hp may be negative. 
-- it is tricky for one player condition. 
-- @return nil or x,y,z
function MsgHandler.Get_Highest_HP_mob_position(mob_displayname)
	local position_x;
	local position_y;
	local position_z;
	local max_hp = -1000000;
	local min_distance_square = 99999999;
	local p_x, p_y, p_z
	if(not p_x) then
		if(not pos or not pos[1]) then
			local player = MyCompany.Aries.Player.GetPlayer();
			p_x, p_y, p_z = player:GetPosition();
		else
			p_x, p_y, p_z = pos[1], pos[2], pos[3];
		end
	end

	if(mob_displayname) then
		local arena_id, data;
		for arena_id, data in pairs(arena_data_map) do
			local hp_virtual = 0;
			local bHasMob;
			
			if(data.mobs) then
				local _, eachmob;
				for _, eachmob in pairs(data.mobs) do
					if(eachmob.displayname == mob_displayname) then
						bHasMob = true;
						hp_virtual = hp_virtual + (eachmob.current_hp or 0);
					else
						hp_virtual = hp_virtual - (eachmob.current_hp or 0);
					end
				end
			end
			if(bHasMob) then
				local nPlayerCount = 0;
				local i;
				for i = 1, 4 do
					local player = data.players[i]
					if( (player and player.nid) or data.fledslots[i]) then
						nPlayerCount = nPlayerCount + 1;
					end
				end
				-- hp is computed as (All_Mob_current_hp - Other_mob_hp - players_on_arena*100dps). the virtual hp may be negative. 
				

				if(nPlayerCount == 1) then
					-- if there is just one player, we will recommend this arena.
					if(System.options.version == "kids") then
						if( Player.GetLevel() <= 10) then
							hp_virtual = hp_virtual - 100; 
						else
							hp_virtual = hp_virtual + 100; 
						end
					else
						hp_virtual = hp_virtual + 100; 
					end
				else
					-- if there is 0 or 2 or more players, we will NOT recommend this arena.
					hp_virtual = hp_virtual - nPlayerCount*100;
				end
				
				if(hp_virtual >=  max_hp) then
					local arena_distance_sq = (data.p_x - p_x) * (data.p_x - p_x) + (data.p_z - p_z) * (data.p_z - p_z);
					if(hp_virtual > max_hp or arena_distance_sq < min_distance_square) then
						position_x = data.p_x;
						position_y = data.p_y;
						position_z = data.p_z;
						max_hp = hp_virtual;
						min_distance_square = arena_distance_sq;	
					end
				end
			end
		end
	end
	return position_x, position_y, position_z;
end

-- @param pos: relative to which position to find the closest mob. if nil it is the current player position. 
-- otherwise it can be a {x,y,z} array
-- @return nil or x,y,z
function MsgHandler.Get_closest_alive_mob_position(mob_displayname, pos)
	local position_x;
	local position_y;
	local position_z;
	local min_distance_square = 99999999;
	local p_x, p_y, p_z
	if(not pos or not pos[1]) then
		local player = MyCompany.Aries.Player.GetPlayer();
		p_x, p_y, p_z = player:GetPosition();
	else
		p_x, p_y, p_z = pos[1], pos[2], pos[3];
	end
	if(mob_displayname) then
		local arena_id, data;
		for arena_id, data in pairs(arena_data_map) do
			local arena_distance_sq = nil;
			-- if has available player slots
			local bPlayersFull = data.bPlayersFull;
			local _, eachmob;
			for _, eachmob in pairs(data.mobs) do
				if(eachmob.displayname == mob_displayname and eachmob.current_hp > 0) then
					if(not arena_distance_sq) then
						arena_distance_sq = (data.p_x - p_x) * (data.p_x - p_x) + (data.p_z - p_z) * (data.p_z - p_z);
						if(bPlayersFull) then
							-- if player slot is full add square distance, lowest priority
							arena_distance_sq = arena_distance_sq + 9999999;
						end
					end
					if(arena_distance_sq < min_distance_square) then
						position_x = data.p_x;
						position_y = data.p_y;
						position_z = data.p_z;
						min_distance_square = arena_distance_sq;
					end
				end
			end
		end
	end
	return position_x, position_y, position_z;
end

-- message handler combat client
-- NOTE: server send message to the client with realtime message and dispatched according to different message types
-- @param msg: mainly real time messages
function MsgHandler.MsgProc_combat_client(msg)
	if(not msg) then
		LOG.std("", "error","combat","nil message got in MsgHandler.MsgProc_combat_client")
		return;
	end

	local message = string_match(msg, "^%[Aries%]%[combat_to_client%](.+)$");
	if(message) then
		-- parse the message
		local key, value = string_match(message, "^([^:]*):(.*)$");
		if(key and value) then
			if(key == "YouAreAlreadyInCombat") then
				-- player is already in combat
				--_guihelper.MessageBox("YouAreAlreadyInCombat");
			elseif(key == "ArenaSlotsFull") then
				-- arena slots are full
				BroadcastHelper.PushLabel({id="arenaslotsfull_tip", label = "已达到当前法阵最大人数限制", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
			elseif(key == "InsufficientStamina") then
				BroadcastHelper.PushLabel({id="pve_insufficient_stamina_tip", label = "你的精力值不足，无法得到这场战斗的战利品。", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
			elseif(key == "AllMobsDead") then
				-- arena slots are full
				--_guihelper.MessageBox("AllMobsDead");
			elseif(key == "EntranceLocked") then
				BroadcastHelper.PushLabel({id="free_pvp_locked_tip", label = "这个法阵已经关闭了", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
			elseif(key == "EntranceLockedForOtherTeam") then
				BroadcastHelper.PushLabel({id="free_pvp_locked_tip", label = "这个法阵暂时不属于你的队伍，请稍后再试", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
			elseif(key == "NoTicket") then
				BroadcastHelper.PushLabel({id="free_pvp_noticket_tip", label = "没有PK入场券不能参加PK", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
			elseif(key == "TargetAlreadyEnraged") then
				BroadcastHelper.PushLabel({id="TargetAlreadyEnraged_tip", label = "该怪物已被激怒", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
			elseif(key == "TargetRequiresHigherEnrageCard") then
				BroadcastHelper.PushLabel({id="TargetRequiresHigherEnrageCard_tip", label = "激怒该怪物需要更高级的激怒卡", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
			elseif(key == "TargetRequiresLowerEnrageCard") then
				BroadcastHelper.PushLabel({id="TargetRequiresLowerEnrageCard_tip", label = "激怒该怪物需要更低级的激怒卡", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
			elseif(key == "TargetRequiresBossEnrageCard") then
				BroadcastHelper.PushLabel({id="TargetRequiresBossEnrageCard_tip", label = "激怒该怪物需要首领激怒卡", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
				
			elseif(key == "TargetCannotBeEnraged") then
				BroadcastHelper.PushLabel({id="TargetCannotBeEnraged_tip", label = "该目标不能被激怒", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
			elseif(key == "TargetIsMinionOnGuardian") then
				BroadcastHelper.PushLabel({id="TargetIsMinionOnGuardian_tip", label = "该目标不能被释放灵魂替身", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
				
			elseif(key == "TargetCannotBeEnraged_Easy") then
				BroadcastHelper.PushLabel({id="TargetCannotBeEnraged_Easy_tip", label = "该目标不能在单人模式被激怒", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
			elseif(key == "TargetCannotBeEnraged_Normal") then
				BroadcastHelper.PushLabel({id="TargetCannotBeEnraged_Normal_tip", label = "该目标不能在普通模式被激怒", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
			elseif(key == "TargetCannotBeEnraged_Hard") then
				BroadcastHelper.PushLabel({id="TargetCannotBeEnraged_Hard_tip", label = "该目标不能在精英模式被激怒", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});

			elseif(key == "FollowPetBeenCombatBefore") then
				BroadcastHelper.PushLabel({id="FollowPetBeenCombatBefore_tip", label = "该宠物已经出战过 不能再次出战", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
				
			elseif(key == "Insufficient_12055") then
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(12055);
				if(gsItem) then
					local name = gsItem.template.name;
					if(name) then
						BroadcastHelper.PushLabel({id="InsufficientCatchPetItem_tip", label = string.format("还没有%s不能捕捉", name), max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
					end
				end
			elseif(key == "Insufficient_12056") then
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(12056);
				if(gsItem) then
					local name = gsItem.template.name;
					if(name) then
						BroadcastHelper.PushLabel({id="InsufficientCatchPetItem_tip", label = string.format("还没有%s不能捕捉", name), max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
					end
				end
				
			elseif(key == "CannotUserInPvP") then
				BroadcastHelper.PushLabel({id="CannotUserInPvP_tip", label = "这张卡片不能在PVP法阵使用", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
				
				
			elseif(key == "MyCombatPetKicked") then
				BroadcastHelper.PushLabel({id="MyCombatPetKicked_tip", label = "由于新的队友加入，您的宠物回到了伴随状态。", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
				-- follow pet word
				local word = "有人来帮忙，我就休息下！";
				local followpet = Pet.GetUserFollowObj();
				if(followpet and followpet:IsValid()) then
					local speak_word = "<span style='color:#093f4f'>"..word.."</span>";
					headon_speech.Speek(followpet.name, speak_word, 6, true, nil, true, nil, "#ffffffc0");
				end
				
			elseif(key == "InsufficientStaminaForAddtionalLoot") then
				BroadcastHelper.PushLabel({id="InsufficientStaminaForAddtionalLoot_tip", label = "您的精力值不足，无法打开宝箱。", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
				
				_guihelper.Custom_MessageBox("您的精力值不足，无法打开宝箱。", function(result)
					if(result == _guihelper.DialogResult.Yes)then
						local itemname = "";
						local gsItem = ItemManager.GetGlobalStoreItemInMemory(17250);
						if(gsItem) then
							-- 17250_EnergyPills
							itemname = gsItem.template.name;
						end
						-- use item
						local hasGSItem = ItemManager.IfOwnGSItem;
						local bHas, guid = hasGSItem(17250);
						if(bHas) then
							local item = ItemManager.GetItemByGUID(guid);
							if(item and item.guid > 0) then
								item:OnClick("left");
								return;
							end
						end
						_guihelper.Custom_MessageBox(string.format("你还没有【%s】，需要立刻购买吗？", itemname), function(result)
							if(result == _guihelper.DialogResult.Yes) then
								local command = System.App.Commands.GetCommand("Profile.Aries.PurchaseItemWnd");
								if(command) then
									command:Call({gsid = 17250});
								end
							end
						end, _guihelper.MessageBoxButtons.YesNo, {show_label = true, yes = "立刻购买", no = "看看再说"});
					end
				end, _guihelper.MessageBoxButtons.YesNo, {show_label = true, yes = "使用精力药水", no = "关闭"});
				
			elseif(key == "InsufficientKeyForAddtionalLoot") then
				BroadcastHelper.PushLabel({id="InsufficientKeyForAddtionalLoot_tip", label = "您没有黄金钥匙，无法打开宝箱。", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
				
				_guihelper.Custom_MessageBox("您没有黄金钥匙，无法打开宝箱。", function(result)
					if(result == _guihelper.DialogResult.Yes) then
						local command = System.App.Commands.GetCommand("Profile.Aries.PurchaseItemWnd");
						if(command) then
							-- 12059_GoldKey
							command:Call({gsid = 12059});
						end
					end
				end, _guihelper.MessageBoxButtons.YesNo, {show_label = true, yes = "购买黄金钥匙", no = "关闭"});
				
			elseif(key == "ClientMSG") then
				if(System.options.isAB_SDK) then
					BroadcastHelper.PushLabel({id="ClientMSG_tip", label = value.."", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
				end
				
				
				
				
			elseif(key == "WarningIdleRound") then
				if(System.options.version == "kids") then
					local maxIdleRounds,maxAccumulateIdleRounds = string.match(value,"(%d+)%%(%d+)");
					if(maxIdleRounds and maxAccumulateIdleRounds) then
						maxIdleRounds = tonumber(maxIdleRounds);
						maxAccumulateIdleRounds = tonumber(maxAccumulateIdleRounds);
						if(maxIdleRounds and maxAccumulateIdleRounds) then
							local text = string.format("连续%d次不出牌或者累计%d次不出牌你将会被踢出比赛，并且扣除200积分",maxIdleRounds,maxAccumulateIdleRounds);
							_guihelper.MessageBox(text);	
						end
					end
				elseif(value) then
					if(tonumber(value) == 1) then
						BroadcastHelper.PushLabel({id="warning_idle_round_tip", label = "注意：连续3回合不出牌将被移出法阵", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
					end
				end
			elseif(key == "WarningAccumulateIdleRound") then
				local curRounds,maxRounds = string.match(value,"(%d+)%%(%d+)");
				if(curRounds and maxRounds) then
					curRounds = tonumber(curRounds);
					maxRounds = tonumber(maxRounds);
					if(curRounds and maxRounds) then
						local text = string.format("你已累计%d次未出牌，累计%d次后你将会被踢出比赛，并且扣200积分",curRounds,maxRounds);
						_guihelper.MessageBox(text);	
					end
				end
			elseif(key == "DeductScoreForIdleRounds") then
				if(value and tonumber(value)) then
					local text = string.format("你因为连续%d回合未出牌，消极比赛，现被踢出比赛并且扣除200积分",tonumber(value));
					_guihelper.MessageBox(text);	
				end
				--_guihelper.MessageBox("你因为连续3回合未出牌，消极比赛，现被踢出比赛并且扣除500积分");
			elseif(key == "DeductScoreForAccumulateIdleRounds") then
				if(value and tonumber(value)) then
					local text = string.format("你因为累计%d回合未出牌，消极比赛，现被踢出比赛并且扣除200积分",tonumber(value));
					_guihelper.MessageBox(text);	
				end
				--_guihelper.MessageBox("你因为累计10回合未出牌，消极比赛，现被踢出比赛并且扣除500积分");
			elseif(key == "DeductScoreForFlee3v3") then
					local text = "因为你逃离比赛扣除100积分";
					_guihelper.MessageBox(text);	
			elseif(key == "ArenaUpdate") then
				-- arena update
				local key_update, value_update, key_inactiveplayer_update, value_inactiveplayer_update = string_match(value, "^([^%+]*)%+([^%+]*)%+([^%+]*)%+([^%+]*)$");
				if(key_update and value_update and key_inactiveplayer_update and value_inactiveplayer_update) then
					MsgHandler.OnArenaNormalUpdate_by_inactiveplayer_key_value(key_inactiveplayer_update, value_inactiveplayer_update);
					MsgHandler.OnArenaNormalUpdate_by_key_value(key_update, value_update);
				end
			elseif(key == "ArenaUpdate_EnterCombat") then
				-- enter combat with normal update
				-- TODO: play some effect
				Desktop.SetMode("combat");
				-- update arena values
				local key_update, value_update, key_inactiveplayer_update, value_inactiveplayer_update, mode, difficulty = string_match(value, "^([^%+]*)%+([^%+]*)%+([^%+]*)%+([^%+]*)%+([^%+]*)%+([^%+]*)$");
				if(key_update and value_update and key_inactiveplayer_update and value_inactiveplayer_update and mode and difficulty) then
					MsgHandler.OnArenaNormalUpdate_by_inactiveplayer_key_value(key_inactiveplayer_update, value_inactiveplayer_update);
					MsgHandler.OnArenaNormalUpdate_by_key_value(key_update, value_update);
					-- reset picked cards
					MsgHandler.MyArenaPickedCards = {};
					-- send log information, plus world name
					local worldinfo = WorldManager:GetCurrentWorld();
					local worldname = worldinfo.name;
					paraworld.PostLog({action = "user_enter_combat", msg = "Proc_EnterCombat", mode = mode, difficulty = difficulty, worldname = worldname}, "user_enter_combat_log", function(msg)
					end);
					-- player entercombat effect
					if(System.options.version == "teen") then
						local arena_id = string_match(key_update, "^arena_(%d+)$")
						if(arena_id) then
							local spell_file = "config/Aries/Spells/Player_EnterCombat_teen.xml";
							local caster = {isPlayer = true, nid = ProfileManager.GetNID()};
							SpellPlayer.PlaySpellEffect_single(tonumber(arena_id), caster, caster, spell_file, {{0}}, nil, function()
							end, true, nil, nil, nil, nil, nil, true); -- true for bSkipAutoTargetEffect
						end
					end
					-- follow pet word
					local item = ItemManager.GetItemByBagAndPosition(0, 32);
					if(item and item.guid ~= 0) then
						local word = CombatPetHelper.GetPetTalk(item.gsid, "attack");
						if(type(word) == "string") then
							local followpet = Pet.GetUserFollowObj();
							if(followpet and followpet:IsValid()) then
								local speak_word = "<span style='color:#093f4f'>"..word.."</span>";
								headon_speech.Speek(followpet.name, speak_word, 6, true, nil, true, nil, "#ffffffc0");
							end
						end
					end
				end
			elseif(key == "PickYourCard") then
				-- pick your card in 30 seconds
				local nRemainingTime, seq, mode, nRoundTag, remaining_deck_count, total_deck_count, remaing_switching_followpet_count, bMyFollowPetCombatMode, friendlylist, hostilelist, cards_at_hand_str, runes_at_hand_str, followpetcards_at_hand_str, followpet_history_str = string_match(value, "^([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^<]*)<([^>]*)><([^>]*)><([^>]*)><([^>]*)><([^>]*)><([^>]*)>$");
				if(nRemainingTime and seq and mode and nRoundTag and bMyFollowPetCombatMode and remaining_deck_count and total_deck_count and remaing_switching_followpet_count and friendlylist and hostilelist and cards_at_hand_str and runes_at_hand_str and followpetcards_at_hand_str and followpet_history_str) then
					nRemainingTime = tonumber(nRemainingTime);
					seq = tonumber(seq);
					nRoundTag = tonumber(nRoundTag);
					remaining_deck_count = tonumber(remaining_deck_count);
					total_deck_count = tonumber(total_deck_count);
					remaing_switching_followpet_count = tonumber(remaing_switching_followpet_count);
					if(bMyFollowPetCombatMode == "true") then
						bMyFollowPetCombatMode = true;
					else
						bMyFollowPetCombatMode = false;
					end
					MsgHandler.OnUpdateCountDown(nRemainingTime);
					MsgHandler.OnShowPick(seq, mode, nRoundTag, remaining_deck_count, total_deck_count, remaing_switching_followpet_count, bMyFollowPetCombatMode, friendlylist, hostilelist, cards_at_hand_str, nil, runes_at_hand_str, followpetcards_at_hand_str, followpet_history_str);
				end
			elseif(key == "PickYourCard_dead") then
				-- pick your card in 30 seconds
				-- for dead player only flee is available
				local nRemainingTime, seq, mode, nRoundTag, remaing_switching_followpet_count, friendlylist, hostilelist, cards_at_hand_str, runes_at_hand_str, followpetcards_at_hand_str, followpet_history_str = string_match(value, "^([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^<]*)<([^>]*)><([^>]*)><([^>]*)><([^>]*)><([^>]*)><([^>]*)>$");
				if(nRemainingTime and seq and mode and nRoundTag and remaing_switching_followpet_count and friendlylist and hostilelist and cards_at_hand_str and runes_at_hand_str and followpetcards_at_hand_str and followpet_history_str) then
					nRemainingTime = tonumber(nRemainingTime);
					seq = tonumber(seq);
					nRoundTag = tonumber(nRoundTag);
					remaing_switching_followpet_count = tonumber(remaing_switching_followpet_count);
					if(bMyFollowPetCombatMode == "true") then
						bMyFollowPetCombatMode = true;
					else
						bMyFollowPetCombatMode = false;
					end
					MsgHandler.OnUpdateCountDown(nRemainingTime);
					MsgHandler.OnShowPick(seq, mode, nRoundTag, 0, 0, remaing_switching_followpet_count, bMyFollowPetCombatMode, friendlylist, hostilelist, cards_at_hand_str, true, runes_at_hand_str, followpetcards_at_hand_str, followpet_history_str);
				end
			elseif(key == "PickYourCard_opposite") then
				-- free pvp arena waiting for opposite player to pick card
				local nRemainingTime, seq, mode, nRoundTag = string_match(value, "^([^,]*),([^,]*),([^,]*),([^,]*)$");
				if(nRemainingTime and seq and mode and nRoundTag) then
					nRemainingTime = tonumber(nRemainingTime);
					seq = tonumber(seq);
					nRoundTag = tonumber(nRoundTag);
					-- count to zero callback, just make sure the card picker is closed if confused command is arrived
					MsgHandler.OnUpdateCountDown(nRemainingTime, function() MsgHandler.HideCardPicker(); end);
					MsgHandler.OnShowIdle("等待对方选牌", mode, nRoundTag);
				end
			elseif(key == "PickYourCard_idle") then
				-- pick your card in 30 seconds
				-- for dead player only flee is available
				local nRemainingTime, mode, nRoundTag = string_match(value, "^([^,]*),([^,]*),([^,]*)$");
				if(nRemainingTime and mode and nRoundTag) then
					nRemainingTime = tonumber(nRemainingTime);
					nRoundTag = tonumber(nRoundTag);
					-- count to zero callback, just make sure the card picker is closed if confused command is arrived
					MsgHandler.OnUpdateCountDown(nRemainingTime, function() MsgHandler.HideCardPicker(); end);
					MsgHandler.OnShowIdle("正在等待队友选牌", mode, nRoundTag);
				end
			elseif(key == "PickYourCard_already") then
				-- pick your card in 30 seconds
				-- for dead player only flee is available
				local nRemainingTime, mode, nRoundTag = string_match(value, "^([^,]*),([^,]*),([^,]*)$");
				if(nRemainingTime and mode and nRoundTag) then
					nRemainingTime = tonumber(nRemainingTime);
					nRoundTag = tonumber(nRoundTag);
					-- count to zero callback, just make sure the card picker is closed if confused command is arrived
					MsgHandler.OnUpdateCountDown(nRemainingTime, function() MsgHandler.HideCardPicker(); end);
					MsgHandler.OnShowIdle("正在等待其他队友选牌", mode, nRoundTag);
				end
			elseif(key == "PickYourCard_waiting_for_start") then
				-- free pvp arena waiting for opposite player
				if(value == "pve") then
					MsgHandler.OnShowIdle("等待法阵战斗开启", "pve", -1);
				elseif(value == "free_pvp") then
					MsgHandler.OnShowIdle("等待对方法阵玩家", "free_pvp", -1);
				end
				
			elseif(key == "HasPickedThisPet_before") then
				-- play the current turn
				MsgHandler.OnHasPickedThisPet_before();

			elseif(key == "ThisIsVIPPetAndYourNot") then
				BroadcastHelper.PushLabel({id="ThisIsVIPPetAndYourNot_tip", label = "这是一个魔法星专属宠物，你还没有魔法星，不能使用哦", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
				
			elseif(key == "exceed_max_switching_followpet_count") then
				BroadcastHelper.PushLabel({id="exceed_max_switching_followpet_count_tip", label = "一场战斗最多只能参战5只宠物", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});

			elseif(key == "UnlockingArena") then
				BroadcastHelper.PushLabel({id="UnlockingArena_tip", label = "正在解锁法阵...", max_duration=8000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
				UIAnimManager.PlayCustomAnimation(3000, function(elapsedTime)
					if(elapsedTime == 3000) then
						BroadcastHelper.PushLabel({id="UnlockingArena_tip", label = "解锁法阵成功", max_duration=8000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
					end
				end);
				
			elseif(key == "AlreadyOwnPet_kids") then
				BroadcastHelper.PushLabel({id="AlreadyOwnPet_kids_tip", label = "你已经拥有该宠物了，不需要捕捉", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
				
				
				
			elseif(key == "CatchPetOverHalfHP") then
				BroadcastHelper.PushLabel({id="CatchPetOverHalfHP_tip", label = "宠物血量低于一半才可以捕捉", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
			elseif(key == "YouHaveAlreadyOwnThePet") then
				BroadcastHelper.PushLabel({id="YouHaveAlreadyOwnThePet_tip", label = "你已拥有该宠物", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
			elseif(key == "CatchPetAlreadyCaught") then
				BroadcastHelper.PushLabel({id="CatchPetAlreadyCaught_tip", label = "该宠物已经被成功捕捉", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
			elseif(key == "NotCatchablePetMob") then
				BroadcastHelper.PushLabel({id="YouHaveAlreadyOwnThePet_tip", label = "目标无法驯养", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
			elseif(key == "CatchPetHigherLevel") then
				BroadcastHelper.PushLabel({id="CatchPetHigherLevel_tip", label = "不能捕捉比你等级高的目标", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
				
			elseif(key == "CannotUseInPvP") then
				BroadcastHelper.PushLabel({id="CannotUseInPvP_tip", label = "这张卡片不能在PvP法阵使用", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
			elseif(key == "CannotUseExpectInBattlefield") then
				BroadcastHelper.PushLabel({id="CannotUseExpectInBattlefield_tip", label = "这张卡片只能在英雄谷的法阵使用", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
			elseif(key == "CannotUseInInstance") then
				BroadcastHelper.PushLabel({id="CannotUseInInstance_tip", label = "这张卡片不能在副本使用", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
				
				
			elseif(key == "DefeatLastArenaInInstance") then
				if(System.options.version == "teen") then
					local my_combat_level = Combat.GetMyCombatLevel();
					if(my_combat_level <= 11) then
						-- show broadcast tip
						BroadcastHelper.PushLabel({id="DefeatLastArenaInInstance_tip", label = "点击右上角的按钮离开副本", max_duration=20000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
						-- show the arrow pointer for leave arena button
						-- 653426 is a specific id for leave instance arrow pointer
						--NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/ArrowPointer.lua");
						--local ArrowPointer = commonlib.gettable("MyCompany.Aries.Desktop.GUIHelper.ArrowPointer");
						--ArrowPointer.ShowArrow(653426, 6, "_rt", -200, 4, 64, 64);
						local MapArea = commonlib.gettable("MyCompany.Aries.Desktop.MapArea");
						MapArea.HighLightLeaveWorld();
					end
				end
				
			elseif(key == "PlayTurn") then
				-- play the current turn
				MsgHandler.OnPlayTurn(value);
			elseif(key == "FleeFromArena") then
				-- play the current turn
				MsgHandler.OnFleeFromArena();
				-- check hp for player hp tip
				MsgHandler.OnCheckHPTip();
				Desktop.SetMode("normal");

				local world_info = WorldManager:GetCurrentWorld();
				if(world_info) then
					-- send log information
					paraworld.PostLog({
						action = "user_leave_combat", 
						msg = "Reason_FleeFromArena", 
						mode = value,
						world_name = world_info.name,
					}, "user_leave_combat_log", function(msg)
					end);
				end
				canUseHPPotion = true;
				MsgHandler.CheckEquipDurability();
				-- refresh the user level and exp bar
				MsgHandler.RefreshLevelExpBarAfter5Seconds()
			---- NOTE: the original implementation is a expendable cards
			--elseif(key == "ExpendCard") then
				---- expend card
				--MsgHandler.OnExpendCard(value);
			elseif(key == "GainExp") then
				-- gain experience
				MsgHandler.OnGainExp(value, true);
				-- check hp for player hp tip
				MsgHandler.OnCheckHPTip();
				Desktop.SetMode("normal");
				
				local world_info = WorldManager:GetCurrentWorld();
				if(world_info) then
					-- send log information
					paraworld.PostLog({
						action = "user_leave_combat", 
						msg = "Reason_GainExp", 
						mode = "pve",
						world_name = world_info.name,
					}, "user_leave_combat_log", function(msg)
					end);
				end
				-- try to player victory animation
				MsgHandler.PlayVictoryAnimation();
				canUseHPPotion = true;
				-- refresh the user level and exp bar
				MsgHandler.CheckEquipDurability();
				MsgHandler.RefreshLevelExpBarAfter5Seconds();

			elseif(key == "GainExpButDefeated") then
				-- gain experience but defeated
				MsgHandler.OnGainExpButDefeated(value);
				-- check hp for player hp tip
				MsgHandler.OnCheckHPTip();
				-- show dead tip if not shown before
				MsgHandler.OnShowDeadTip();
				Desktop.SetMode("normal");

				local world_info = WorldManager:GetCurrentWorld();
				if(world_info) then
					-- send log information
					paraworld.PostLog({
						action = "user_leave_combat", 
						msg = "Reason_GainExpButDefeated", 
						mode = "pve",
						world_name = world_info.name,
					}, "user_leave_combat_log", function(msg)
					end);
				end
				canUseHPPotion = true;
				MsgHandler.CheckEquipDurability();
				-- refresh the user level and exp bar
				MsgHandler.RefreshLevelExpBarAfter5Seconds();
				
			elseif(key == "GainExpButDefeatedInInstance") then
				-- gain experience but defeated
				MsgHandler.GainExpButDefeatedInInstance(value);
				-- check hp for player hp tip
				MsgHandler.OnCheckHPTip();
				-- show dead tip if not shown before
				MsgHandler.OnShowDeadTip();
				Desktop.SetMode("normal");

				local world_info = WorldManager:GetCurrentWorld();
				if(world_info) then
					-- send log information
					paraworld.PostLog({
						action = "user_leave_combat", 
						msg = "Reason_GainExpButDefeatedInInstance", 
						mode = "pve",
						world_name = world_info.name,
					}, "user_leave_combat_log", function(msg)
					end);
				end
				canUseHPPotion = true;
				MsgHandler.CheckEquipDurability();
				-- refresh the user level and exp bar
				MsgHandler.RefreshLevelExpBarAfter5Seconds();
				
			elseif(key == "MyGainedLoots") then
				MsgHandler.GainedLoots(value, true);

				log("MyGainedLoots:\n")
				commonlib.echo(value);
			elseif(key == "BuddyGainedLoots") then
				MsgHandler.GainedLoots(value, false);
				
				log("BuddyGainedLoots:\n")
				commonlib.echo(value);
				
			elseif(key == "MyGainedAdditionalLoots") then
				MsgHandler.OnMyGainedAdditionalLoots(value);
				
				log("MyGainedAdditionalLoots:\n")
				commonlib.echo(value);
				
				
			elseif(key == "Defeated") then
				-- defeated
				MsgHandler.OnDefeated();
				-- check hp for player hp tip
				MsgHandler.OnCheckHPTip();
				-- show dead tip if not shown before
				MsgHandler.OnShowDeadTip();
				Desktop.SetMode("normal");

				local world_info = WorldManager:GetCurrentWorld();
				if(world_info) then
					-- send log information
					paraworld.PostLog({
						action = "user_leave_combat", 
						msg = "Reason_Defeated", 
						mode = "pve",
						world_name = world_info.name,
					}, "user_leave_combat_log", function(msg)
					end);
				end
				canUseHPPotion = true;
				MsgHandler.CheckEquipDurability();
				-- refresh the user level and exp bar
				MsgHandler.RefreshLevelExpBarAfter5Seconds()
				
			elseif(key == "UpdateExpBuffArea") then
				-- refresh exp buff area
				MsgHandler.RefreshExpBuffArea();
				
			elseif(key == "UpdateEquipBags") then
				-- update equip bags 0 and 1
				MsgHandler.UpdateEquipBags();
				
			elseif(key == "CostAutomaticAICombatPill") then
				-- show cost tip
				MsgHandler.OnCostAutomaticAICombatPill();
				
			elseif(key == "SkipCostAutomaticAICombatPill") then
				-- show cost tip
				MsgHandler.OnSkipCostAutomaticAICombatPill();
				
				
			elseif(key == "Winner_pvp") then
				-- check hp for player hp tip
				MsgHandler.OnCheckHPTip();
				-- winner pvp
				Desktop.SetMode("normal");
				-- first hide all card picker
				MsgHandler.HideCardPicker();
				-- hide target picker
				MsgHandler.HideTargetPicker();
				-- first hide all hp slots
				MsgHandler.HideHPSlots();
				-- clear count down timer
				MsgHandler.OnUpdateCountDown(0);

				-- try to player victory animation
				MsgHandler.PlayVictoryAnimation();
				
				-- for battle field defeated
				local world_info = WorldManager:GetCurrentWorld();
				if(world_info and world_info.team_mode == "battlefield") then
					MsgHandler.OnEnterCombat(tonumber(value), "near"); -- value is arena id, "near" is random, the player side is set on game server
					-- clear immortal_position
					BasicArena.immortal_position = nil;
				end
				
				if(world_info) then
					-- send log information
					paraworld.PostLog({
						action = "user_leave_combat", 
						msg = "Reason_Winner_pvp", 
						mode = "free_pvp",
						world_name = world_info.name,
					}, "user_leave_combat_log", function(msg)
					end);
				end

				--MsgHandler.PvPResultTipOverhead("恭喜你取得了胜利！");
				MsgHandler.CheckEquipDurability();
				canUseHPPotion = true;
			elseif(key == "Defeated_pvp") then
				-- check hp for player hp tip
				MsgHandler.OnCheckHPTip();
				-- show dead tip if not shown before
				MsgHandler.OnShowDeadTip();
				-- winner pvp
				Desktop.SetMode("normal");
				-- first hide all card picker
				MsgHandler.HideCardPicker();
				-- hide target picker
				MsgHandler.HideTargetPicker();
				-- first hide all hp slots
				MsgHandler.HideHPSlots();
				-- clear count down timer
				MsgHandler.OnUpdateCountDown(0);
				
				-- for battle field defeated
				local world_info = WorldManager:GetCurrentWorld();
				if(world_info.team_mode == "battlefield") then
					MsgHandler.OnDefeated()
				end

				if(world_info) then
					-- send log information
					paraworld.PostLog({
						action = "user_leave_combat", 
						msg = "Reason_Defeated_pvp", 
						mode = "free_pvp",
						world_name = world_info.name,
					}, "user_leave_combat_log", function(msg)
					end);
				end

				--MsgHandler.PvPResultTipOverhead("你被打败了，再接再厉吧！");
				MsgHandler.CheckEquipDurability();
				canUseHPPotion = true;
				
			elseif(key == "DrawGame_pvp") then
				-- check hp for player hp tip
				MsgHandler.OnCheckHPTip();
				-- winner pvp
				Desktop.SetMode("normal");
				-- first hide all card picker
				MsgHandler.HideCardPicker();
				-- hide target picker
				MsgHandler.HideTargetPicker();
				-- first hide all hp slots
				MsgHandler.HideHPSlots();
				-- clear count down timer
				MsgHandler.OnUpdateCountDown(0);
				
				if(world_info) then
					-- send log information
					paraworld.PostLog({
						action = "user_leave_combat", 
						msg = "Reason_DrawGame_pvp", 
						mode = "free_pvp",
						world_name = world_info.name,
					}, "user_leave_combat_log", function(msg)
					end);
				end

				--MsgHandler.PvPResultTipOverhead("你被打败了，再接再厉吧！");
				MsgHandler.CheckEquipDurability();
				canUseHPPotion = true;
				
			elseif(key == "InActivePlayer_pvp") then
				-- winner pvp
				Desktop.SetMode("normal");
				-- first hide all card picker
				MsgHandler.HideCardPicker();
				-- hide target picker
				MsgHandler.HideTargetPicker();
				-- first hide all hp slots
				MsgHandler.HideHPSlots();
				-- clear count down timer
				MsgHandler.OnUpdateCountDown(0);

				local world_info = WorldManager:GetCurrentWorld();
				if(world_info) then
					-- send log information
					paraworld.PostLog({
						action = "user_leave_combat", 
						msg = "Reason_InActivePlayer_pvp", 
						mode = "free_pvp",
						world_name = world_info.name,
					}, "user_leave_combat_log", function(msg)
					end);
				end
				canUseHPPotion = true;
			elseif(key == "NotUseEnoughCardAndRound") then
				local card_num,round_num = string_match(message, "(%d+)%%(%d+)");
				card_num = tonumber(card_num);
				round_num = tonumber(round_num);
				local text = string.format("你在本次战斗中战斗回合小于%d,使用卡牌次数少于%d次,不能获得战斗奖励",round_num,card_num);
				_guihelper.MessageBox(text);
			elseif(key == "CombatResult") then
				-- defeated
				--MsgHandler.OnCombatResultBubble(value);
			elseif(key == "CombatResult_pvp") then
				-- defeated
				--MsgHandler.OnCombatResultBubble_pvp(value);
				
			elseif(key == "PlayMotion") then
				-- play movie motion with position and id
				-- Tricky Note: we will delay 1 second to let the character unmount from combat slot before the end of battle animation plays. 
				UIAnimManager.PlayCustomAnimation(1000, function(elapsedTime)
					if(elapsedTime == 1000) then
						MsgHandler.OnPlayMotion(value);
					end
				end);
				
			elseif(key == "SyncHP") then
				-- set direct hp
				MsgHandler.OnSyncHPFromServer(value);
			elseif(key == "BugPointMarked") then
				-- bug point marked
				_guihelper.MessageBox("Bug 标记: "..value);
				
			elseif(key == "GearScoreOnServer") then
				-- bug point marked
				_guihelper.MessageBox("本地GS:"..Combat.GetGearScore().." 服务器返回GS: "..tostring(value));
				
			elseif(key == "TreasureBoxResponse_GoExtendedcost") then
				local loot_id = value;
				if(loot_id == "Global_CatTreasureHouse_Adv") then
					-- 1728: Open_17439_TheCatBox
					local hasGSItem = ItemManager.IfOwnGSItem;
					if(not hasGSItem(17439)) then
						local name;
						local gsItem = ItemManager.GetGlobalStoreItemInMemory(17439);
						if(gsItem) then
							name = gsItem.template.name;
						end
						if(name) then
							label = string.format("你还没有%s，不能打开宝箱", name);
						end
						if(label) then
							BroadcastHelper.PushLabel({id="TreasureBoxResponse_GoExtendedcost_tip", label = label, max_duration=20000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
						end
						return;
					end
					-- mark loot
					bLootedGlobal_CatTreasureHouse_Adv = true;
					-- exe extendedcost
					ItemManager.ExtendedCost(1728, nil, nil, function(msg)
						if(msg) then
							log("+++++++loot treasure box Open_17439_TheCatBox with ExtendedCost return: +++++++\n")
							commonlib.echo(msg);
						end
					end, function(msg) end);

				end
				
			elseif(key == "TreasureBoxResponse_AlreadyPickedLoot") then
				-- AlreadyPickedLoot
				local worldinfo = WorldManager:GetCurrentWorld();
				local worldname = worldinfo.name;
				if(worldname ~= "Global_CatTreasureHouse_Basic" and worldname ~= "Global_CatTreasureHouse_Adv") then
					BroadcastHelper.PushLabel({id="treasuretip", label = "这个宝箱已经被你打开过啦，可以继续挑战开宝箱哦！", max_duration=20000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
				else
					if(worldname == "Global_CatTreasureHouse_Basic" or worldname == "Global_CatTreasureHouse_Adv") then
						if(bLootedGlobal_CatTreasureHouse_Adv) then
							BroadcastHelper.PushLabel({id="treasuretip", label = "这个宝箱已经被你打开过啦，可以继续挑战开宝箱哦！", max_duration=20000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
						else
							if(bLootedGlobal_CatTreasureHouse_Adv) then
								-- 1728: Open_17439_TheCatBox
								local hasGSItem = ItemManager.IfOwnGSItem;
								if(not hasGSItem(17439)) then
									local name;
									local gsItem = ItemManager.GetGlobalStoreItemInMemory(17439);
									if(gsItem) then
										name = gsItem.template.name;
									end
									if(name) then
										label = string.format("你还没有%s，不能打开宝箱", name);
									end
									if(label) then
										BroadcastHelper.PushLabel({id="TreasureBoxResponse_GoExtendedcost_tip", label = label, max_duration=20000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
									end
									return;
								end
								-- mark loot
								bLootedGlobal_CatTreasureHouse_Adv = true;
								-- exe extendedcost
								ItemManager.ExtendedCost(1728, nil, nil, function(msg)
									if(msg) then
										log("+++++++loot treasure box Open_17439_TheCatBox with ExtendedCost return: +++++++\n")
										commonlib.echo(msg);
									end
								end, function(msg) end);
							end
						end
					end
				end

			elseif(key == "TreasureBoxResponse_CombatNotFinished") then
				-- CombatNotFinished
				_guihelper.MessageBox([[<div style="margin-top:32px;margin-left:32px;">你没有宝箱钥匙，无法开启宝箱！</div>]]);
				
			elseif(key == "TreasureBoxResponse_CanOpenTreasureBox") then
				-- CanOpenTreasureBox
				local worldinfo = WorldManager:GetCurrentWorld();
				local worldname = worldinfo.name;
				if(worldname ~= "Global_CatTreasureHouse_Basic" and worldname ~= "Global_CatTreasureHouse_Adv") then
					NPL.load("(gl)script/ide/TooltipHelper.lua");
					local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");
					BroadcastHelper.PushLabel({
							label = "获得宝箱钥匙 x 1",
							color = "239 230 0",
							shadow = true,
							bold = true,
							font_size = 14,
							scaling = 1.2,
							});
				end
				
			elseif(key == "TreasureBoxResponse_PickedLoot") then
				
				local arena_id, loot_str = string_match(value, "^([^%+]*)%+([^%+]*)$");
				if(arena_id and loot_str) then
					local treasure_loots = {};
					arena_id = tonumber(arena_id);
					local pair_section;
					for pair_section in string.gmatch(loot_str, "%[([^%]]*)%]") do
						local gsid, count = string_match(pair_section, "^([^,]*),([^,]*)$");
						if(gsid and count) then
							gsid = tonumber(gsid);
							count = tonumber(count);
							table.insert(treasure_loots, {gsid = gsid, cnt = count});
						end
					end

					-- show notification
					local notification_msg = {};
					notification_msg.adds = treasure_loots;
					notification_msg.updates = {};
					notification_msg.stats = {};
					Dock.OnExtendedCostNotification(notification_msg);

					local treasurebox_npc_id = ObjectManager.GetArena_TreasureBox_NPC_ID(arena_id);
					if(treasurebox_npc_id) then
						local treasurebox_model = NPC.GetNpcModelFromIDAndInstance(treasurebox_npc_id);
						if(treasurebox_model) then
							-- open the box
							local att = treasurebox_model:GetAttributeObject();
							att:SetField("AnimID", 70);
							return;
						end
					end
				end

			elseif(key == "BuddyPickCard") then
				-- set picked card
				local caster_id, caster_slotid, key, target_slotid, isAutoAICard = string_match(value, "^([^,]*),([^,]*),([^,]*),([^,]*),([^,]*)$");
				if(caster_id and caster_slotid and key and target_slotid and isAutoAICard) then
					caster_id = tonumber(caster_id);
					caster_slotid = tonumber(caster_slotid);
					target_slotid = tonumber(target_slotid);
					if(isAutoAICard == "true") then
						isAutoAICard = true;
					elseif(isAutoAICard == "false") then
						isAutoAICard = false;
					else
						isAutoAICard = false;
					end
					MsgHandler.MyArenaPickedCards[caster_slotid] = {
						key = key,
						target_slotid = target_slotid,
						isAutoAICard = isAutoAICard,
					};
					-- refresh the lower part of the hp slots
					MsgHandler.RefreshHPSlots();
					-- update headon mark
					if(caster_id) then
						if(isAutoAICard) then
							Headon_OPC.ChangeHeadonMark(caster_id, "autocombat");
						else
							Headon_OPC.ChangeHeadonMark(caster_id, "");
						end
					end
				end
			elseif(key == "InstanceEntranceLockCountdown") then
				MsgHandler.PlayEntranceCountDown(value);
			elseif(key == "InstanceEntranceLockOpen") then
				MsgHandler.OnInstanceEntranceLockOpen(value);
			elseif(key == "NewDay") then
				-- force update and get all gs obtain count
				MsgHandler.TryUpdateGetAllGSObtainCntInTimeSpan();
				
			elseif(key == "ImFromInternetCafe_zhTW") then
				-- player from internet cafe
				bCheckedInternetCafeStatus = true;
				if(value == "cafewow") then
					commonlib.echo("==========ImFromInternetCafe_zhTW:cafe")
					NPL.load("(gl)script/apps/Aries/Desktop/LinksArea/LinksAreaPage.lua");
					local LinksAreaPage = commonlib.gettable("MyCompany.Aries.Desktop.LinksAreaPage");
					LinksAreaPage.ImFromInternetCafe_zhTW = true;
					LinksAreaPage.LoadLinksNode();
				elseif(value == "normal") then
					-- nothing
					commonlib.echo("==========ImFromInternetCafe_zhTW:normal")
				end
			end
		end
	end
end

-- force update and get all gs obtain count
function MsgHandler.TryUpdateGetAllGSObtainCntInTimeSpan()
	local delaytime = 15000;
	UIAnimManager.PlayCustomAnimation(delaytime, function(elapsedTime)
		if(elapsedTime == delaytime) then
			System.Item.ItemManager.GetAllGSObtainCntInTimeSpan(function(bSucceed)
				if(bSucceed) then
					-- successfully update the gs obtain time
					log("GetAllGSObtainCntInTimeSpan new day successful\n")
				else
					MsgHandler.TryUpdateGetAllGSObtainCntInTimeSpan();
					log("GetAllGSObtainCntInTimeSpan new day failed, retry in 15 seconds\n")
				end
			end, "access plus 0 day", 25000, function(msg)
				MsgHandler.TryUpdateGetAllGSObtainCntInTimeSpan();
				log("GetAllGSObtainCntInTimeSpan new day timed out, retry in 15 seconds\n")
			end);
		end
	end);
end

function MsgHandler.OnActivateDesktop()
	MsgHandler.ResetUI()
end

-- reset UI to normal desktop
function MsgHandler.ResetUI()
	ObjectManager.UnMountPlayerFromSlot(ProfileManager.GetNID());
	
	Desktop.SetMode("normal");
	-- first hide all card picker
	MsgHandler.HideCardPicker();
	-- hide target picker
	MsgHandler.HideTargetPicker();
	-- first hide all hp slots
	MsgHandler.HideHPSlots();
	-- clear count down timer
	MsgHandler.OnUpdateCountDown(0);
	-- hide all
	MsgHandler.ShowAutoAIModeBtn(false);

	-- hide the my runes page
	MsgHandler.HideMyRunesPage();
end

function MsgHandler.RefreshLevelExpBarAfter5Seconds()
	-- to eliminate the bug: 升级之后出现经验为0的情况
	UIAnimManager.PlayCustomAnimation(5000, function(elapsedTime)
		if(elapsedTime == 5000) then
			MyCompany.Aries.Pet.GetRemoteValue(nil, function() 
				-- force update
				Dock.UpdateLevelExpAndHP();
			end, "access plus 0 day");
		end
	end);
end

-- try to player victory animation
function MsgHandler.PlayVictoryAnimation()
	if(System.options.version == "teen") then
		local bPlayedAnimation = false;
		local lastframe_animID; -- tricky: this frame and last frame should be the same in case of fall to the ground animation
		UIAnimManager.PlayCustomAnimation(3000, function(elapsedTime)
			if(not bPlayedAnimation) then
				local animID = MyCompany.Aries.Player.GetPlayer():GetAnimation();
				if(lastframe_animID == 0 and animID == 0) then
					-- play user avatar animation
					local user_char = MyCompany.Aries.Player.GetPlayer();
					if(user_char and user_char:IsValid()) then
						local driver_assetkey = user_char:GetPrimaryAsset():GetKeyName();
						if(driver_assetkey == "character/v3/TeenElf/Female/TeenElfFemale.xml") then
							System.Animation.PlayAnimationFile("character/Animation/v6/teen_Victory_female.x", user_char);
							bPlayedAnimation = true;
						elseif(driver_assetkey == "character/v3/TeenElf/Male/TeenElfMale.xml") then
							System.Animation.PlayAnimationFile("character/Animation/v6/teen_Victory_male.x", user_char);
							bPlayedAnimation = true;
						end
					end
				end
				lastframe_animID = animID;
			end
		end);
	end
end

function MsgHandler.RefreshExpBuffArea()
	ItemManager.GetItemsInBag(1003, "RefreshExpBuffArea", function()
		-- update the exp buff area
		EXPBuffArea.UpdateBuff();
	end, "access plus 0 day");
end

function MsgHandler.UpdateEquipBags()
	ItemManager.GetItemsInBag(0, "UpdateEquipBags_0", function()
		ItemManager.GetItemsInBag(1, "UpdateEquipBags_1", function()
		end, "access plus 0 day");
	end, "access plus 0 day");
end

function MsgHandler.PvPResultTipOverhead(word)
	if(not word) then
		return;
	end
	local name = "Aries_HealByWisp_"..ParaGlobal.GenerateUniqueID();
	-- visualize this delta
	local _label = ParaUI.CreateUIObject("button", name, "_ct", -200, -80, 400, 32);
	_label.background = "";
	_label.shadow = true;
	_label.enabled = false;
	_label.scalingx = 1.8;
	_label.scalingy = 1.8;
	_label.font = "System;18;bold";
	_label.spacing = 4;
	_label:GetFont("text").format = 1+256; -- center and no clip
	_label:AttachToRoot();
	
	local color = "245 59 14";
	_label.text = tostring(word);
	_guihelper.SetFontColor(_label, color.." 255");
	
	-- id: 48309 for in scene battle comment notification
	local anim_time = 2000;
	UIAnimManager.PlayCustomAnimation(anim_time, function(elapsedTime)
		local _label = ParaUI.GetUIObject(name);
		if(_label:IsValid() == true) then
			_label.translationy = - elapsedTime * 60 / anim_time;
			_guihelper.SetFontColor(_label, "245 59 14 "..(255 - math.floor(elapsedTime * 200 / anim_time)));
		end
		if(elapsedTime == anim_time) then
			ParaUI.Destroy(name);
		end
	end);
end

function MsgHandler.ParseNormalUpdateInactivePlayerMessage(value)
	local inactive_player_data = {};
	local player_data;
	for player_data in string.gmatch(value, "%[(.-)%]") do
		local eachplayer = {};
		local isMob, nid, slot_id, phase, followpet_gsid, current_hp, max_hp, petlevel, pips, power_pips, charms, wards, miniaura, overtimes = 
			string_match(player_data, "^([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^#]*)#([^#]*)#([^#]*)#([^#]*)#([^#]*)$");
		if(overtimes) then
			eachplayer.ismob = (isMob == "true");
			eachplayer.nid = tonumber(nid) or nid;
			eachplayer.slot_id = tonumber(slot_id);
			eachplayer.phase = phase;
			eachplayer.followpet_gsid = tonumber(followpet_gsid);
			eachplayer.current_hp = tonumber(current_hp);
			eachplayer.max_hp = tonumber(max_hp);
			eachplayer.level = tonumber(petlevel);
			eachplayer.pips = tonumber(pips);
			eachplayer.power_pips = tonumber(power_pips);
			eachplayer.charms = charms;
			eachplayer.wards = wards;
			eachplayer.miniaura = miniaura;
			eachplayer.overtimes = overtimes;

			if(eachplayer.nid == 27001) then
				eachplayer.bMinion = true;
			elseif(eachplayer.nid == 27002) then
				eachplayer.bMinion = true;
			end
		end
		table_insert(inactive_player_data, eachplayer);
	end
	return inactive_player_data;
end

-- message parser
-- the value including all arena data, a typical arena table is:
--[[
{
	arena_id = 1001,
	players = {{nid=46650264,max_hp=500,pips=1,power_pips=0,current_hp=450,},{},{},{},},
	mobs = {{max_hp=300,id=50001,power_pips=0,asset="character/v5/10mobs/HaqiTown/BlazeHairMonster/BlazeHairMonster.x",pips=1,scale=1,phase="fire",current_hp=300,displayname="火怪",},},
	p_x = 20052.876953,
	p_y = 1.042222, 
	p_z = 19723.253906,
	bIncludedAnyAliveMob = true,
	bIncludedMyselfInArena = true,
	bIncludedAnyPlayer = true,
	bPlayersFull = false,
	pips = {1,0,0,0,1,0,0,0,},
	arrow_position = 5,
}
]]
function MsgHandler.ParseNormalUpdateMessage(value, bSkipInactivePlayerUpdate)
	local bIncludedMyselfInArena = false;
	local bMyselfFarSideInArena = false;
	local bIncludedAnyPlayer = false;
	local bIncludedAnyAliveMob = false;
	local bIncludedAnyBossMob = false;
	local data = {};
	data.mobs = {};
	data.players = {};
	data.pips = {0,0,0,0,0,0,0,0};
	data.pips_power = {0,0,0,0,0,0,0,0};
	data.slotbuffs = {};
	data.fledslots = {};
	data.slotunits = {};
	local section1, section2, section3, section4, section5, section6, section7, section8, section9, section10, section11, section12 = string_match(value, "^([^{]*){([^}]*)}{([^}]*)}{([^}]*)}{([^}]*)}{([^}]*)}{([^}]*)}{(.*)}{([^}]*)}{([^}]*)}{([^}]*)}{([^}]*)}$");
	if(section1 and section2 and section3 and section4 and section5 and section6 and section7 and section8 and section9 and section10 and section11 and section12) then
		local arena_id, mode, p_x, p_y, p_z, arrow_position = string_match(section1, "^([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*)$");
		if(arrow_position) then
			data.arena_id = tonumber(arena_id);
			data.mode = mode;
			data.p_x = tonumber(p_x);
			data.p_y = tonumber(p_y);
			data.p_z = tonumber(p_z);
			data.arrow_position = tonumber(arrow_position);
		end
		local inactive_player_data = arena_key_valuedata_inactiveplayer_pairs["arena_inactiveplayer_"..data.arena_id] or {};

		local mob_data;
		for mob_data in string.gmatch(section2, "%[([^%]]*)%]") do
			local eachmob = {};
			local isMob, id, slot_id, displayname, catchpet_gsid, phase, asset, scale, tags, current_hp, max_hp, level, pips, power_pips, charms, wards, miniaura, overtimes, threats = 
				string_match(mob_data, "^([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^#]*)#([^#]*)#([^#]*)#([^#]*)#([^#]*)#([^#]*)$");
			if(threats) then
				eachmob.ismob = (isMob == "true");
				eachmob.id = tonumber(id);
				eachmob.slot_id = tonumber(slot_id);
				eachmob.asset = asset;

				local asset_short, asset_ccs = string.match(asset, "^([^@]+)@(.+)$");
				if(asset_short and asset_ccs) then
					local mapping = mob_ccs[asset_short];
					if(mapping and asset_short == "TeenElfFemale") then
						eachmob.asset = "character/v3/TeenElf/Female/TeenElfFemale.xml";
						eachmob.asset_ccs = mapping[asset_ccs];
					elseif(mapping and asset_short == "TeenElfMale") then
						eachmob.asset = "character/v3/TeenElf/Male/TeenElfMale.xml";
						eachmob.asset_ccs = mapping[asset_ccs];
					elseif(mapping and asset_short == "ElfFemale") then
						eachmob.asset = "character/v3/Elf/Female/ElfFemale.xml";
						eachmob.asset_ccs = mapping[asset_ccs];
					end
				end

				eachmob.displayname = displayname;
				eachmob.catchpet_gsid = tonumber(catchpet_gsid);
				-- tricky: we allow format like "mob_displayname$t=client_talk_ai_name"
				local display_name_, client_talk_ai_name = displayname:match("^([^%$]*)%$t=([^%$]*)$");
				if(client_talk_ai_name) then
					eachmob.displayname = display_name_;
					eachmob.client_talk_ai_name = client_talk_ai_name;
					-- echo({display_name_, client_talk_ai_name, "ai module discovered"})
				end
				
				eachmob.phase = phase;
				if(string.find(phase, "-")) then -- "-" is can catch pet tag
					eachmob.can_catchpet = true;
					eachmob.phase = string.gsub(phase, "-", "");
				else
					eachmob.can_catchpet = false;
				end

				eachmob.scale = tonumber(scale);
				eachmob.tags = {};
				local tag;
				for tag in string.gmatch(tags, "(.)") do
					eachmob.tags[tag] = true;
					if(tag == "r") then -- r for enraged
						eachmob.scale = eachmob.scale * ENRAGED_SCALE;
					end
				end
				eachmob.current_hp = tonumber(current_hp);
				eachmob.max_hp = tonumber(max_hp);
				eachmob.level = tonumber(level);
				if(string.find(level, "e")) then -- "e" stands for elite
					eachmob.rarity = "elite";
					local real_level = string.gsub(level, "e", "");
					eachmob.level = tonumber(real_level);
				elseif(string.find(level, "b")) then -- "r" stands for rare
					eachmob.rarity = "boss";
					local real_level = string.gsub(level, "b", "");
					eachmob.level = tonumber(real_level);
					bIncludedAnyBossMob = true;
				else
					eachmob.level = tonumber(level);
				end

				eachmob.pips = tonumber(pips);
				eachmob.power_pips = tonumber(power_pips);
				eachmob.charms = charms;
				eachmob.wards = wards;
				eachmob.miniaura = miniaura;
				eachmob.overtimes = overtimes;
				eachmob.threats = threats;

				data.slotunits[eachmob.slot_id] = eachmob.id;

				-- this is a nested reference, don't commonlib.echo
				data.slotbuffs[eachmob.slot_id] = {
					charms = charms,
					wards = wards,
					overtimes = overtimes,
					miniaura = miniaura,
				};
				
				if(eachmob.current_hp > 0) then
					bIncludedAnyAliveMob = true;
				end
				-- keep a reference of the mob id and value pair
				mob_id_valuedata_pairs[eachmob.id] = eachmob;
				mob_id_arena_map[eachmob.id] = data; -- the containing arena
			end
			table_insert(data.mobs, eachmob);
		end

		local player_data;
		local player_seq = 1;
		for player_data in string.gmatch(section3, "%[([^%]]*)%]") do
			local eachplayer = {};
			local isMob, nid, slot_id, phase, followpet_gsid, current_hp, max_hp, petlevel, pips, power_pips, charms, wards, miniaura, overtimes = 
				string_match(player_data, "^([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^#]*)#([^#]*)#([^#]*)#([^#]*)#([^#]*)$");
			if(overtimes) then
				eachplayer.ismob = (isMob == "true");
				eachplayer.nid = tonumber(nid) or nid;
				eachplayer.slot_id = tonumber(slot_id);
				eachplayer.phase = phase;
				eachplayer.followpet_gsid = tonumber(followpet_gsid);
				eachplayer.current_hp = tonumber(current_hp);
				eachplayer.max_hp = tonumber(max_hp);
				eachplayer.level = tonumber(petlevel);
				eachplayer.pips = tonumber(pips);
				eachplayer.power_pips = tonumber(power_pips);
				eachplayer.charms = charms;
				eachplayer.wards = wards;
				eachplayer.miniaura = miniaura;
				eachplayer.overtimes = overtimes;
				
				if(eachplayer.nid == 27001) then
					eachplayer.bMinion = true;
				elseif(eachplayer.nid == 27002) then
					eachplayer.bMinion = true;
				end
				
				data.slotunits[eachplayer.slot_id] = eachplayer.nid;

				-- this is a nested reference, don't commonlib.echo
				data.slotbuffs[eachplayer.slot_id] = {
					charms = charms,
					wards = wards,
					overtimes = overtimes,
					miniaura = miniaura,
				};

				-- check if the current player is included in the arena
				if(ProfileManager.GetNID() == (tonumber(nid) or nid)) then
					bIncludedMyselfInArena = true;
					MsgHandler.SetCurrentHP(eachplayer.current_hp);
					if(player_seq >= 5 and bMyselfFarSideInArena == false) then
						bMyselfFarSideInArena = true;
					end
				end
				bIncludedAnyPlayer = true;
			elseif(player_data == "0") then
				eachplayer.isfledslot = true;
				data.fledslots[player_seq] = true;
			else
				if(inactive_player_data and inactive_player_data[player_seq] and not bSkipInactivePlayerUpdate) then
					eachplayer = commonlib.deepcopy(inactive_player_data[player_seq]) or {};
					if(eachplayer.nid) then
						data.slotunits[eachplayer.slot_id] = eachplayer.nid;
						-- this is a nested reference, don't commonlib.echo
						data.slotbuffs[eachplayer.slot_id] = {
							charms = eachplayer.charms,
							wards = eachplayer.wards,
							overtimes = eachplayer.overtimes,
							miniaura = eachplayer.miniaura,
						};
						-- check if the current player is included in the arena
						if(ProfileManager.GetNID() == (tonumber(eachplayer.nid) or "localuser")) then
							bIncludedMyselfInArena = true;
							MsgHandler.SetCurrentHP(eachplayer.current_hp);
							if(player_seq >= 5 and bMyselfFarSideInArena == false) then
								bMyselfFarSideInArena = true;
							end
						end
						bIncludedAnyPlayer = true;
					end
				end
			end
			table_insert(data.players, eachplayer);
			player_seq = player_seq + 1;
		end
		-- normal pips
		local slot_id = 1;
		local pip_count;
		for pip_count in string.gmatch(section4, "([^,]+)") do
			data.pips[slot_id] = tonumber(pip_count);
			slot_id = slot_id + 1;
		end

		-- power pips
		local slot_id = 1;
		local power_pips_count;
		for power_pips_count in string.gmatch(section5, "([^,]+)") do
			data.pips_power[slot_id] = tonumber(power_pips_count);
			slot_id = slot_id + 1;
		end
		-- global aura
		local aura, aura2 = string.match(section6, "^(.*),(.*)$");
		if(aura and aura2) then
			data.aura = tonumber(aura) or aura;
			data.aura2 = tonumber(aura2) or aura2;
		else
			data.aura = "";
			data.aura2 = "";
		end
		-- door_lock
		if(tonumber(section7)) then
			data.door_lock = tonumber(section7);
		end
		-- treasure box
		if(section8 ~= "") then
			data.treasurebox = commonlib.LoadTableFromString(section8);
		end
		-- special params
		data.pvp_arena_damage_boost = 0;
		data.pvp_arena_heal_penalty = 0;
		if(section9) then
			local number1, number2 = string.match(section9, "^(.*),(.*)$");
			if(number1 and number2) then
				data.pvp_arena_damage_boost = tonumber(number1);
				data.pvp_arena_heal_penalty = tonumber(number2);
			end
		end
		-- near team auras
		local near_team_auras = {};
		local near_team_aura;
		for near_team_aura in string.gmatch(section10, "([^,]+)") do
			near_team_aura = tonumber(near_team_aura);
			if(near_team_aura) then
				table.insert(near_team_auras, near_team_aura);
			end
		end
		data.near_team_auras = near_team_auras;
		-- far team auras
		local far_team_auras = {};
		local far_team_aura;
		for far_team_aura in string.gmatch(section11, "([^,]+)") do
			far_team_aura = tonumber(far_team_aura);
			if(far_team_aura) then
				table.insert(far_team_auras, far_team_aura);
			end
		end
		data.far_team_auras = far_team_auras;
		-- arena appearance
		if(section12 and section12 ~= "" and section12 ~= "nil") then
			data.appearance = section12;
		else
			data.appearance = nil;
		end
	end
	
	local bPlayersFull = true;
	if(data.mode == "pve") then
		local i;
		for i = 1, 4 do
			local player = data.players[i]
			if(not player.nid) then
				if(not data.fledslots[i]) then
					bPlayersFull = false;
					break;
				end
			end
		end
	elseif(data.mode == "free_pvp") then
		local i;
		for i = 1, 8 do
			local player = data.players[i]
			if(not player.nid) then
				if(not data.fledslots[i]) then
					bPlayersFull = false;
					break;
				end
			end
		end
	end

	if(not bIncludedAnyAliveMob and not bIncludedAnyPlayer) then
		local _, eachmob;
		for _, eachmob in pairs(data.mobs) do
			eachmob.charms = "";
			eachmob.wards = "";
			eachmob.miniaura = ""; -- clear the dead aura tag
			eachmob.overtimes = "";
			local slot_id = eachmob.slot_id;
			if(slot_id) then
				local slotbuff = data.slotbuffs[slot_id];
				if(slotbuff) then
					slotbuff.charms = "";
					slotbuff.wards = "";
					slotbuff.miniaura = ""; -- clear the dead aura tag
					slotbuff.overtimes = "";
				end
			end
		end
	end

	-- record if myself is included in arena
	data.bIncludedMyselfInArena = bIncludedMyselfInArena;
	-- record if myself is on the arena far side 
	data.bMyselfFarSideInArena = bMyselfFarSideInArena;
	-- record if included any player
	data.bIncludedAnyPlayer = bIncludedAnyPlayer;
	-- if has available player slots
	data.bPlayersFull = bPlayersFull;
	-- if include any alive mob
	data.bIncludedAnyAliveMob = bIncludedAnyAliveMob;
	-- if include any boss mob
	data.bIncludedAnyBossMob = bIncludedAnyBossMob;

	-- keep an arena data reference
	arena_data_map[data.arena_id] = data;

	-- player is included in the arena keep a copy of the arena data
	if(bIncludedMyselfInArena) then
		MsgHandler.MyArenaData = commonlib.deepcopy(data);
		MsgHandler.RefreshHPSlots();
	end

	return data;
end

function MsgHandler.IsFullHealth()
	if(current_hp >= max_hp) then
		return true;
	end
	return false;
end

function MsgHandler.IsInCombat()
	if(myself_arena_id) then
		return true;
	end
	return false;
end


-- @params pts_or_proportion:   if integer value greater than 1, it's an absolute hp point value
--								if float value less than 1, it's a direct proportion of the maximum hp points
-- @return: true for heal success, false for fail, mainly due to user is in combat
-- NOTE: one can be only healed by wisp if NOT in combat
function MsgHandler.HealByWisp(pts_or_proportion, bForceProportion)
	if(not isMsgHandlerInited) then
		-- if not inited the current and max hp is not read from the client data yet
		return;
	end
	if(not pts_or_proportion) then
		LOG.std("", "error","combat","nil pts_or_proportion got in function MsgHandler.HealByWisp");
		return false;
	end
	if(myself_arena_id) then
		LOG.std("", "warn","combat"," you can't heal yourself in combat");
		return false;
	end
	local heal_pts = 0;
	if(pts_or_proportion < 1 and pts_or_proportion > 0) then
		heal_pts = math.ceil(pts_or_proportion * max_hp);
	else
		if(bForceProportion) then
			heal_pts = math.ceil(pts_or_proportion * max_hp);
		else
			heal_pts = pts_or_proportion;
		end
	end

	-- force update the max hp
	MsgHandler.UpdateMaxHP();

	local old_current_hp = current_hp;
	-- heal the user
	current_hp = current_hp + heal_pts;
	if(current_hp > max_hp) then
		current_hp = max_hp;
	end
	if(current_hp < 0) then
		current_hp = 0;
	end

	if(current_hp > old_current_hp) then
		local delta = current_hp - old_current_hp;

		local _parent = ParaUI.GetUIObject("healing_effect_cont");
		if(not _parent:IsValid()) then
			_parent = ParaUI.CreateUIObject("container", "healing_effect_cont", "_ct", -20, -80, 120, 20);
			_parent.enabled = false;
			_parent.background = "";
			_parent.scalingx = 1.8;
			_parent.scalingy = 1.8;
			_parent.zorder = -1;
			_parent:AttachToRoot();
	
			MsgHandler.healing_page = Map3DSystem.mcml.PageCtrl:new({url="script/apps/Aries/Combat/UI/HealingHeadonEffect.html"});
			MsgHandler.healing_page:Create("healing_effect", _parent, "_fi", 0, 0, 0, 0);
		end
		if(MsgHandler.healing_page) then
			MsgHandler.healing_page:SetUIValue("text", tostring("+"..delta))
			_parent.colormask = "255 255 255 255";
			_parent.visible = true;
			_parent:ApplyAnim();
		end
		
		-- id: 48309 for in scene battle comment notification
		local anim_time = 2000;
		UIAnimManager.PlayCustomAnimation(anim_time, function(elapsedTime)
			local _parent = ParaUI.GetUIObject("healing_effect_cont");
			if(_parent:IsValid()) then
				_parent.translationy = - elapsedTime * 60 / anim_time;
				_parent.colormask = format("255 255 255 %d", (255 - math.floor(elapsedTime * 200 / anim_time)));
				_parent:ApplyAnim();
				if(elapsedTime == anim_time) then
					_parent.visible = false;
				end
			end
		end);
	end
	
	-- 996_CombatHPTag
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	local bHas, guid = hasGSItem(996);
	if(bHas) then
		local item = ItemManager.GetItemByGUID(guid);
		if(item and item.guid > 0) then
			-- fake setclientdata to memory and database only
            ItemManager.SetClientData(item.guid, tostring(current_hp), function(msg_setclientdata)
            end, nil, nil, nil, true); -- true for bMemoryDBOnly
			-- update hp UI
			Dock.UpdateLevelExpAndHP();
		end
	end
	
	return true;
end

-- force the current hp to update in every 60 seconds
local force_update_current_hp_interval = 60000;
local last_update_time = 0;
local last_update_current_hp = nil;
-- NOTE: this function is invoked in a timer every 5 seconds
function MsgHandler.TryUpdateCurrentHP()
	if(current_hp ~= last_update_current_hp) then
		if((ParaGlobal.GetGameTime() - last_update_time) > force_update_current_hp_interval) then
			last_update_time = ParaGlobal.GetGameTime();
			last_update_current_hp = current_hp;
			MsgHandler.ForceUpdateCurrentHP();
		end
	end
end

-- @params delta_hp_pts: delta health point value to set
function MsgHandler.SetCurrentHPDelta(delta_hp_pts)
	MsgHandler.SetCurrentHP(current_hp + delta_hp_pts)
end

--local spellplay_live_up_update = {};

-- mark live hp delta and restore after bar refresh
function MsgHandler.ProcessSpellPlayLiveHPDelta(obj_name, delta_hp, index)
	--spellplay_live_up_update
	--index
	--spellplay_live_up_update[index]
end

local function FindSymbolUI(_parent, obj_name)
	local nCount = _parent:GetChildCount();
	-- traverse all children in a container
	-- pay attention the GetChildAt function indexed in C++ form which begins at index 0
	for i = 0, nCount - 1 do
		local _ui = _parent:GetChildAt(i);
		if(_ui.name == obj_name) then
			return _ui.id;
		else
			if(_ui.type == "container") then
				return FindSymbolUI(_ui, obj_name);
			end
		end
	end
end
-- show delta_hp on object hpslot
function MsgHandler.ShowDeltaHPOnSlotForObject(obj_name, delta_hp)

	local status_tip_id;
	local position;

	local _this = ParaUI.GetUIObject("Aries_Combat_HP_Slot_Upper");
	if(_this:IsValid() == true) then
		local object_unit_status_tip_id = FindSymbolUI(_this, obj_name);
		if(object_unit_status_tip_id) then
			status_tip_id = object_unit_status_tip_id;
			position = "upper";
		end
	end
	if(not status_tip_id) then
		local _this = ParaUI.GetUIObject("Aries_Combat_HP_Slot_Lower");
		if(_this:IsValid() == true) then
			local object_unit_status_tip_id = FindSymbolUI(_this, obj_name);
			if(object_unit_status_tip_id) then
				status_tip_id = object_unit_status_tip_id;
				position = "lower";
			end
		end
	end

	if(status_tip_id) then
		local _status = ParaUI.GetUIObject(status_tip_id);
		if(_status:IsValid() == true) then
			local abs_x, abs_y = _status:GetAbsPosition();
			
			local delta_hp_container_name = "ShowDeltaHPOnSlotForObject_"..obj_name;
			
			UIAnimManager.StopCustomAnimation(delta_hp_container_name);
			ParaUI.Destroy(delta_hp_container_name);

			local _cont = ParaUI.CreateUIObject("container", delta_hp_container_name, "_lt", 0, 0, 64, 64);
			_cont.background = "";
			_cont.enabled = false;
			_cont.zorder = 1000;
			_cont:AttachToRoot();

			local delta_hp_text = tostring(delta_hp);
			local color = "218 45 45"; --"#da2d2d"
			local fontsize = 32;
			if(delta_hp > 0) then
				delta_hp_text = "+"..delta_hp_text;
				color = "99 209 62"; --"#63d13e"
			end

			local aries_textsprite = commonlib.gettable("MyCompany.Aries.mcml_controls.aries_textsprite");
			local spritestyle = "CombatDigits";
			local ctl = CommonCtrl.TextSprite:new{
				name = "mcml_text_sprite"..delta_hp_container_name,
				alignment = "_lt",
				left = 0,
				top = 0,
				width = 2000,
				height = fontsize,
				parent = _cont,
				text = delta_hp_text,
				color = color.." 255",
				fontsize = fontsize,
				default_fontsize = fontsize,
				image = aries_textsprite.Images[spritestyle],
				sprites = aries_textsprite.Sprites[spritestyle],
			};
			ctl:Show(true);

			local used_width = ctl:GetUsedWidth();
			if(position == "upper") then
				_cont.translationx = abs_x + 32 - used_width / 2;
			else
				_cont.translationx = abs_x + 32 - used_width / 2;
			end
			if(System.options.version ~= "teen") then
				_cont.translationy = abs_y + 16;
			else
				_cont.translationy = abs_y + 24;
			end
			
			_cont:ApplyAnim();

			local id = _cont.id;
			
				
			UIAnimManager.PlayCustomAnimation(2000, function(elapsedTime)
				if(elapsedTime == 2000) then
					ParaUI.Destroy(delta_hp_container_name);
				else
					local _cont = ParaUI.GetUIObject(id);
					if(_cont:IsValid()) then
						--_cont.scalingx = elapsedTime;
						--_cont.scalingy = elapsedTime;
						local alpha = math.abs(elapsedTime - 1000);
						if(alpha < 800) then
							alpha = 255;
						else
							alpha = math.ceil(255 * (1000 - alpha) / 200);
						end
						_cont.colormask = "255 255 255 "..alpha;
						_cont:ApplyAnim();
					end
				end
			end, delta_hp_container_name);
		end
	end
end

-- @params hp_pts: health point value to set
function MsgHandler.SetCurrentHP(hp_pts)
	-- set current hp
	current_hp = hp_pts;
	if(current_hp > max_hp) then
		current_hp = max_hp;
	elseif(current_hp < 0) then
		current_hp = 0;
	end
	
	-- 996_CombatHPTag
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	local bHas, guid = hasGSItem(996);
	if(bHas) then
		local item = ItemManager.GetItemByGUID(guid);
		if(item and item.guid > 0) then
			-- fake setclientdata to memory and database only
            ItemManager.SetClientData(item.guid, tostring(current_hp), function(msg_setclientdata)
            end, nil, nil, nil, true); -- true for bMemoryDBOnly
			-- update hp UI
			Dock.UpdateLevelExpAndHP();
		end
	end
	
	return true;
end

-- force update current hp
function MsgHandler.ForceUpdateCurrentHP()
	-- 996_CombatHPTag
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	local bHas, guid = hasGSItem(996);
	if(bHas) then
		local item = ItemManager.GetItemByGUID(guid);
		if(item and item.guid > 0) then
			-- force update the current hp client data
            ItemManager.SetClientData(item.guid, tostring(current_hp), function(msg_setclientdata)
                LOG.std("", "debug","combat","SetClientData for current hp:"..current_hp.." returns:")
                LOG.std("", "debug","combat",msg_setclientdata);
				Dock.UpdateLevelExpAndHP();
				if(msg_setclientdata.issuccess ~= true) then
					-- reset the current hp in MsgHandler.TryUpdateCurrentHP() form the next timer round
					last_update_time = 0;
					last_update_current_hp = nil;
				end
            end, nil, nil, function()
				-- reset the current hp in MsgHandler.TryUpdateCurrentHP() form the next timer round
				last_update_time = 0;
				last_update_current_hp = nil;
			end);
		end
	end
end

-- check if nid is in arena. 
local function IsInArena(nid, arena_data)
	local slot_id, eachplayer;
	for slot_id, eachplayer in ipairs(arena_data.players) do
		if(nid == eachplayer.nid) then
			return true;
		end
	end
	return false;
end

-- whether the current player is on arena
function MsgHandler.IsOnArena()
	local data = MsgHandler.GetMyArenaData();
	if(data and data.bIncludedMyselfInArena) then
		return true;
	end
end

-- if the given user nid is the same team as the current user
-- return true if user nid is same side as the current user on arena. 
function MsgHandler.IsUserInSameArenaSide(nid)
	nid = tonumber(nid);
	local data = MsgHandler.GetMyArenaData();
	if(data) then
		local nFrom = 0;
		if(data.bMyselfFarSideInArena) then
			nFrom = nFrom + 4;
		end
		local i;
		for i=1, 4 do
			local player = data.players[nFrom+i]
			if(player and player.nid == nid) then
				return true;
			end
		end
	end
end

-- is my arena unit dead, including player or mob
function MsgHandler.IsMyArenaUnitDead(id, isMob)
	local isUnitDead = false;
	local myarena_data = MsgHandler.GetMyArenaData();
	if(myarena_data) then
		local _, each_player;
		for _, each_player in pairs(myarena_data.players) do
			if(each_player.nid == id and each_player.ismob == isMob) then
				if(each_player.current_hp <= 0) then
					return true;
				end
			end
		end
		local _, each_mob;
		for _, each_mob in pairs(myarena_data.mobs) do
			if(each_mob.id == id and each_mob.ismob == isMob) then
				if(each_mob.current_hp <= 0) then
					return true;
				end
			end
		end
	end
	return false;
end


function MsgHandler.OnArenaNormalUpdate_by_inactiveplayer_key_value(key, value)
	if(not key or not value) then
		LOG.std("", "error","combat","nil key or value got in function MsgHandler.OnArenaNormalUpdate_by_inactiveplayer_key_value");
		return;
	end
	-- parse arena id
	local arena_id = string_match(key, "^arena_inactiveplayer_(%d+)$")
	if(not arena_id) then
		LOG.std("", "error","combat","invalid arena id got in function MsgHandler.OnArenaNormalUpdate_by_inactiveplayer_key_value")
		return;
	end
	arena_id = tonumber(arena_id);
	-- parse the value into inactive player data
	local inactive_player_data = MsgHandler.ParseNormalUpdateInactivePlayerMessage(value);
	
	-- keep a reference of the last arena inactive player data
	local last_arena_inactiveplayer_data = arena_key_valuedata_inactiveplayer_pairs[key] or {players = {}}; -- or emptydata
	-- keep a reference of the key and value inactive player data pairs
	arena_key_valuedata_inactiveplayer_pairs[key] = inactive_player_data;
end

-- refresh all arena values
-- NOTE: both real time and normal update values can update the arena data
--		 this function keeps refreshing
-- NOTE: in and out combat mode is also set in this function for proper UIs and camera control
-- @param bSkipSequenceArrowUpdate: skip the sequence arrow update
-- NOTE: 
function MsgHandler.OnArenaNormalUpdate_by_key_value(key, value, bSkipSequenceArrowUpdate, bSkipCameraRefresh)
	
	npl_profiler.perf_begin("OnArenaNormalUpdate_by_key_value")

	if(not key or not value) then
		LOG.std("", "error","combat","nil key or value got in function MsgHandler.OnArenaNormalUpdate_by_key_value");
		return;
	end

	-- parse arena id
	local arena_id = string_match(key, "^arena_(%d+)$")
	if(not arena_id) then
		LOG.std("", "error","combat","invalid arena id got in function MsgHandler.OnArenaNormalUpdate_by_key_value")
		return;
	end
	arena_id = tonumber(arena_id);
	-- record last updated arena values
	last_updated_arena_values[key] = value;
	-- parse the value into arena data
	local arena_data = MsgHandler.ParseNormalUpdateMessage(value);
	-- keep a reference of the last arena data
	local last_arena_data = arena_key_valuedata_pairs[key] or {players = {}}; -- or emptydata
	-- keep a reference of the key and value data pairs
	arena_key_valuedata_pairs[key] = arena_data;
	-- meta data for this arena object
	local arena_meta = MsgHandler.Get_arena_meta_data_by_id(arena_id);
	arena_meta.bIncludedMyselfInArena = arena_data.bIncludedMyselfInArena;
	arena_meta.bMyselfFarSideInArena = arena_data.bMyselfFarSideInArena;
	arena_meta.bIncludedAnyPlayer = arena_data.bIncludedAnyPlayer;
	arena_meta.bPlayersFull = arena_data.bPlayersFull;
	arena_meta.bIncludedAnyAliveMob = arena_data.bIncludedAnyAliveMob;
	arena_meta.bIncludedAnyBossMob = arena_data.bIncludedAnyBossMob;
	arena_meta.mode = arena_data.mode;

	local ObjectManager = ObjectManager;
	local p_x, p_y, p_z = arena_data.p_x, arena_data.p_y, arena_data.p_z;
	--
	-- only create arena if we have never created it since world loading
	--
	if(not arena_meta.is_arena_obj_created) then
		arena_meta.p_x = p_x;
		arena_meta.p_y = p_y;
		arena_meta.p_z = p_z;
		ObjectManager.CreateArenaObj(arena_data.arena_id, {
			x = p_x, 
			y = p_y, 
			z = p_z, 
			bIncludedAnyPlayer = arena_data.bIncludedAnyPlayer,
			bMyselfFarSideInArena = arena_data.bMyselfFarSideInArena,
		});
	end
	
	-- if current player is in arena, update more display details on the combat arena. 
	if(arena_data.bIncludedMyselfInArena) then
		-- force sentient if current player is engaged. 
		arena_meta.is_sentient = true;

		-- Although there is a slow framemove timer in BasicArena, we will update model animation immediately, if the current player is on it. 
		ObjectManager.UpdateArenaPlatformModel(arena_id, arena_meta);
	end

	--
	-- show animation arrow, buffs, fled flags on the arena platform, we will only display them when arena is sentient
	--
	if(arena_meta.is_sentient) then
		if(arena_data.arrow_position == 0 or not arena_data.bIncludedAnyPlayer) then
			ObjectManager.DestroySequenceArrow(arena_data.arena_id);
		else
			if(not bSkipSequenceArrowUpdate) then
				ObjectManager.ShowSequenceArrow(arena_data.arena_id, nil, arena_data.arrow_position);
			end
		end
		
		if(arena_data.aura == "" or not arena_data.aura or not arena_data.bIncludedAnyPlayer) then
			ObjectManager.DestroyGlobalAura(arena_data.arena_id);
		else
			ObjectManager.ShowGlobalAura(arena_data.arena_id, arena_data.aura);
		end
		
		if(arena_data.aura2 == "" or not arena_data.aura2 or not arena_data.bIncludedAnyPlayer) then
			ObjectManager.DestroyGlobalAura2(arena_data.arena_id);
		else
			ObjectManager.ShowGlobalAura2(arena_data.arena_id, arena_data.aura2);
		end

		if(arena_data.treasurebox) then
			ObjectManager.ShowTreasureBox(arena_data.arena_id, arena_data.treasurebox);
		else
			ObjectManager.DestroyTreasureBox(arena_data.arena_id);
		end

		-- update buffs display
		ObjectManager.RefreshArenaBuffs(arena_data.arena_id, arena_data.slotbuffs, true, arena_meta);
		-- update arena fled slots if sentient
		ObjectManager.RefreshFledSlots(arena_data.arena_id, arena_data.fledslots, arena_meta);
	else
		-- remove all displays in case leave sentient does not clear them
		if(arena_meta.bHasBuff) then
			ObjectManager.RefreshArenaBuffs(arena_data.arena_id, nil, nil, arena_meta);
		end
		if(arena_meta.bHasfleds) then
			ObjectManager.RefreshFledSlots(arena_data.arena_id, nil, arena_meta);
		end
	end
		
	--
	-- show each mob
	-- 
	if(not arena_meta.is_arena_mobs_created) then
		ObjectManager.CreateArenaMobs(arena_id, arena_data)
	end

	local _, eachmob;
	for _, eachmob in ipairs(arena_data.mobs) do
		local mob_char = NPC.GetNpcCharacterFromIDAndInstance(39001, eachmob.id);
		if(mob_char and mob_char:IsValid()) then
			mob_char:SetScale(eachmob.scale);
		end
	end

	local IsInArena = IsInArena;

	--
	-- check last arena data each player
	--
	-- TODO: the code here is optimized and corrected, so that RefreshSlotUnitPosition() is not needed. Only update if sentient seems OK. 
	-- a better way is to only update if changed even for sentient arenas. 
	-- NOTE 2010/8/18: Only update if sentient is NOT OK.
	----  example: one player enter the arena and other player login, the other player will see the first player aways from the arena
	----  and some misc errors like the offlined player is not removed when timedout of other source of arena combat finish
	-- Note 2010/8/19: UnMountPlayerFromSlot and MountPlayerOnSlot are optimized to only set if arena is sentient or player not already in combat before, this will save quite a few API calls. 
	-- if(arena_meta.is_sentient) then
	-- if(arena_meta.is_sentient or arena_meta.is_sentient == nil) then
		local slot_id, eachplayer;
		for slot_id, eachplayer in ipairs(last_arena_data.players) do
			if(eachplayer.nid) then
				if(not IsInArena(eachplayer.nid, arena_data)) then
					-- set attribute object
					local player
					if(type(eachplayer.nid) == "number") then
						if(eachplayer.nid < 0) then
							player = ParaScene_GetObject(-eachplayer.nid.."+followpet");
						else
							player = ParaScene_GetObject(tostring(eachplayer.nid));
						end
					elseif(eachplayer.nid == "localuser") then
						player = GameLogic.EntityManager.GetPlayer():GetInnerObject()
					end

					-- already in the arena
					ObjectManager.UnMountPlayerFromSlot(eachplayer.nid, arena_meta.is_sentient, player, eachplayer.bMinion);
					
					if(player:IsValid() and type(eachplayer.nid) == "number" and eachplayer.nid > 0) then
						-- check if the player is a valid GSL agent
						local bHasAgent = System.GSL_client:HasAgent(tostring(eachplayer.nid));
						if(not bHasAgent) then
							-- 2010/6/28: delete the character if the character isn't in the agent list
							-- TODO combat: why delete ?
							LOG.std("", "warn","combat"," a player %s which is not GSL agent is seen on combat zone.", tostring(eachplayer.nid));
							Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeleteObject, 
								silentmode = true,
								obj_params = {
									name = tostring(eachplayer.nid),
									IsCharacter = true,
								},
							})
						end
					end
				end
			end
		end
	
		-- show each player
		local slot_id, eachplayer;
		for slot_id, eachplayer in ipairs(arena_data.players) do
			if(eachplayer.nid) then
				local nid_name = tostring(eachplayer.nid);
				local player;
				if(type(eachplayer.nid) == "number") then
					if(eachplayer.nid < 0) then
						player = ParaScene_GetObject(-eachplayer.nid.."+followpet");
					else
						player = ParaScene_GetObject(nid_name);
					end
				elseif(eachplayer.nid == "localuser") then 
					player = GameLogic.EntityManager.GetPlayer():GetInnerObject();
				end
				if(SystemInfo.GetField("name") == "Aries") then -- for aries only
					if(player:IsValid() == false and type(eachplayer.nid)=="number"  and eachplayer.nid > 0) then -- for non follow pet only
						local assetfile = Player.GetAvaterAssetFileByID();
						if(eachplayer.bMinion) then
							local gsItem = ItemManager.GetGlobalStoreItemInMemory(eachplayer.nid);
							if(gsItem) then
								assetfile = gsItem.assetfile;
							end
						end
						Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_CreateObject, 
							silentmode = true,
							SkipHistory = true,
							obj_params = {
								name = nid_name,
								AssetFile = assetfile,
								x = p_x,
								y = p_y,
								z = p_z,
								IsCharacter = true,
								IsPersistent = false, -- do not save an GSL agent when saving scene
							},
						})
						player = ParaScene_GetObject(nid_name);
						if(player:IsValid() == true) then
							-- 2010/6/28: assign attributes and related settings for newly created character
							-- NOTE: this prevents offlined object is then refreshed with the online one, but without the proper dynamic attribute setting
							System.GSL.agent.SetAttributeForAgent(nid_name);
							if(not eachplayer.bMinion) then
								Pet.RefreshOPC_CCS(eachplayer.nid);
							end
						end
					end
					
					-- show the hp in player slot
					local att = player:GetAttributeObject();
					att:SetDynamicField("player_phase", eachplayer.phase);

					if(eachplayer.bMinion) then
						att:SetDynamicField("bMinion", true);
					end

					---- show the hp in player slot
					--local att = player:GetAttributeObject();
					--att:SetDynamicField("AlwaysShowHeadOnText", true);
					--att:SetDynamicField("DisplayName", eachplayer.nid..":"..eachplayer.current_hp.."/"..eachplayer.max_hp);
					--System.ShowHeadOnDisplay(true, player, eachplayer.nid..":"..eachplayer.current_hp.."/"..eachplayer.max_hp, "99 209 62");

				elseif(SystemInfo.GetField("name") == "Taurus") then -- for taurus only
				
					if(player:IsValid() == false) then
						NPL.load("(gl)script/kids/3DMapSystemItem/ItemManager.lua");
						Map3DSystem.Item.ItemManager.GlobalStoreTemplates[10001] = {
							assetfile = "character/v3/PurpleDragonMajor/Female/PurpleDragonMajorFemale.xml",
						};
						Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_CreateObject, 
							silentmode = true,
							SkipHistory = true,
							obj_params = {
								name = nid_name,
								AssetFile = "character/v3/Elf/Female/ElfFemale.xml",
								CCSInfoStr = "0#1#0#2#1#@0#F#0#0#0#0#0#F#0#0#0#0#9#F#0#0#0#0#9#F#0#0#0#0#10#F#0#0#0#0#8#F#0#0#0#0#0#F#0#0#0#0#@1#10001#0#3#11009#0#0#0#0#0#0#0#0#1072#1073#1074#0#0#0#0#0#0#0#0#",
								x = p_x,
								y = p_y,
								z = p_z,
								IsCharacter = true,
								IsPersistent = false, -- do not save an GSL agent when saving scene
							},
						})
						player = ParaScene_GetObject(nid_name);
						if(player:IsValid() == true) then
							Map3DSystem.UI.CCS.ApplyCCSInfoString(player, "0#1#0#2#1#@0#F#0#0#0#0#0#F#0#0#0#0#9#F#0#0#0#0#9#F#0#0#0#0#10#F#0#0#0#0#8#F#0#0#0#0#0#F#0#0#0#0#@1#10001#0#3#11009#0#0#0#0#0#0#0#0#1072#1073#1074#0#0#0#0#0#0#0#0#");
						end
					end
					---- show the hp in player slot
					--local att = player:GetAttributeObject();
					--att:SetDynamicField("AlwaysShowHeadOnText", true);
					--att:SetDynamicField("DisplayName", eachplayer.nid..":"..eachplayer.current_hp.."/"..eachplayer.max_hp);
					--System.ShowHeadOnDisplay(true, player, eachplayer.nid..":"..eachplayer.current_hp.."/"..eachplayer.max_hp, "99 209 62");
				end

				if(IsInArena(eachplayer.nid, last_arena_data)) then
					-- already in the arena
					ObjectManager.MountPlayerOnSlot(eachplayer.nid, arena_data.arena_id, slot_id, nil, arena_meta.is_sentient, player, eachplayer.bMinion);
				else
					-- enter the arena by walk
					ObjectManager.MountPlayerOnSlot(eachplayer.nid, arena_data.arena_id, slot_id, true, arena_meta.is_sentient, player, eachplayer.bMinion);
				end
			
				-- NOTE 2010/7/14: if the animation is played before the MountPlayerOnSlot function 
				-- in auto refresh Pet.ApplyEquipInfoString position 31, playerChar:ResetBaseModel(asset); will set the animation to 0(idle)
			
				if(arena_meta.is_sentient) then
					if(player and player:IsValid()) then
						local playerChar = player:ToCharacter()
						playerChar:Stop();
						if(eachplayer.current_hp <= 0) then
							-- in dead state(animation id is 1)
							if(playerChar:HasAnimation(1)) then
								playerChar:PlayAnimation(1);
							else
								-- use shared animation if the asset does not contain a dead animation. 
								System.Animation.PlayAnimationFile("character/Animation/v5/dalong/PurpleDragoonMajorFemale_sick_loop.x", player);
							end
						else
							-- in standing state
							playerChar:PlayAnimation(0);
						end
						player:SetDynamicField("CombatLevel", eachplayer.level);
					end
				end
			
				---- record current hp
				--if(eachplayer.nid == ProfileManager.GetNID()) then
					--if(myself_current_hp > eachplayer.current_hp) then
						--MsgHandler.ShowHPMinusHint();
					--end
					--myself_current_hp = eachplayer.current_hp;
				--end
			end
		end
	--end

	-- update arena slot mob or player position
	arena_meta.slotunits = arena_data.slotunits;
	if(arena_meta.is_sentient) then
		ObjectManager.RefreshSlotUnitPosition(arena_data.arena_id, arena_data.slotunits);
	end
		
	-- enter or leave arena view
	if(arena_data.bIncludedMyselfInArena == true) then
		if(not bSkipCameraRefresh) then
			-- create arena object if not exist
			local arena_char = NPC.GetNpcCharacterFromIDAndInstance(ObjectManager.GetArena_CameraView_NPC_ID(arena_id, arena_data.bMyselfFarSideInArena));
			if(arena_char) then
				arena_char:ToCharacter():SetFocus();
				local att = ParaCamera.GetAttributeObject();
				att:SetField("CameraObjectDistance", 22);
				att:SetField("CameraLiftupAngle", 0.453516068459);
				att:SetField("CameraRotY", 1.5619721412659);
				if(arena_data.bMyselfFarSideInArena == true) then
					-- far court
					att:SetField("CameraRotY", 1.5619721412659 + 3.14);
				end
			else
				LOG.std("", "error","combat","arena_char(%d) is invalid in ObjectManager.EnterArenaView",arena_id or 0);
			end
		end
		
		if(not myself_arena_id) then
			myself_arena_id = arena_data.arena_id;
			myself_slot_id = slot_id;
			ObjectManager.EnterArenaView(arena_data.arena_id, {x = p_x, y = p_y, z = p_z}, arena_data.bIncludedAnyBossMob);

			-- halt the dragon language
			local my_pet = Pet.GetPetValueByNID()
			if(my_pet) then
				my_pet:StopMonitor();
			end

			-- force update enviornment
			Player.ForceActivateEnvTimerFunction()
			
			-- show empty selected target
			if(TargetArea.ShowTarget and SystemInfo.GetField("name") == "Aries") then
				if(CombatTutorial and CombatTutorial.IsInTutorial and CombatTutorial.IsInTutorial()) then
					--
				else
					TargetArea.ShowTarget("");
				end
			end
		end

	elseif(arena_data.bIncludedMyselfInArena == false) then
		if(myself_arena_id == arena_data.arena_id) then
			myself_arena_id = nil;
			ObjectManager.UnMountPlayerFromSlot(ProfileManager.GetNID(), arena_meta.is_sentient);
			ObjectManager.LeaveArenaView();

			-- resume the dragon language
			local my_pet = Pet.GetPetValueByNID()
			if(my_pet) then
				my_pet:StartMonitor();
			end
			
			-- force update enviornment
			Player.ForceActivateEnvTimerFunction()

			local player = MyCompany.Aries.Player.GetPlayer();
			if(player:IsValid() == true) then
				player:ToCharacter():FallDown();
			end

			-- switch to entercombat follow pet
			if(MsgHandler.last_entercombat_pet_guid) then
				local item = ItemManager.GetItemByGUID(MsgHandler.last_entercombat_pet_guid);
				if(item and item.guid > 0 and item.bag ~= 0 and item.GetCurLevelCards) then -- if not at home
					item:OnClick("left");
					-- switch back word
					local word = CombatPetHelper.GetPetTalk(item.gsid, "leavecombat");
					if(type(word) == "string") then
						local followpet = Pet.GetUserFollowObj();
						if(followpet and followpet:IsValid()) then
							local speak_word = "<span style='color:#093f4f'>"..word.."</span>";
							headon_speech.Speek(followpet.name, speak_word, 6, true, nil, true, nil, "#ffffffc0");
						end
					end
				end
				MsgHandler.last_entercombat_pet_guid = nil;
			end
		end
		if(not myself_arena_id) then
			-- hide hp slots if not included in arena
			MsgHandler.HideHPSlots();
		end
	end
		
	-- show pips, only if sentient and current player is involved.
	if(arena_meta.is_sentient and arena_data.bIncludedMyselfInArena) then
		local total_pips = 0;
		local slot_id;
		for slot_id = 1, 8 do
			local pips_count = arena_data.pips[slot_id];
			local pips_count_power = arena_data.pips_power[slot_id];
			total_pips = total_pips + pips_count_power + pips_count;
			ObjectManager.ShowPipsOnSlot(arena_data.arena_id, slot_id, pips_count, pips_count_power);
		end
		-- so that we can remove all pips when out of range. 
		arena_meta.total_pips = total_pips;
	elseif(arena_meta.total_pips and arena_meta.total_pips > 0) then
		-- remove pips display if any
		ObjectManager.RemoveAllArenaPips(arena_id);
	end

	npl_profiler.perf_end("OnArenaNormalUpdate_by_key_value")
end

-- get global exp scale
local GlobalExpScaleAcc = nil;
function MsgHandler.GetGlobalExpScaleAcc()
	return GlobalExpScaleAcc;
end

-- refresh all arena values
function MsgHandler.OnArenaNormalUpdate(combat_client_object)
	npl_profiler.perf_begin("OnArenaNormalUpdate")
	
	local world_dir = ParaWorld.GetWorldDirectory();

	local n_GlobalExpScaleAcc = combat_client_object:GetValue("GlobalExpScaleAcc");

	GlobalExpScaleAcc = n_GlobalExpScaleAcc;
	
	if(n_GlobalExpScaleAcc == 1) then -- double exp
		EXPBuffArea.ShowBuff_global_double_exp(true, 1);
	elseif(n_GlobalExpScaleAcc == 2) then -- tripple exp
		EXPBuffArea.ShowBuff_global_double_exp(true, 2);
	elseif(n_GlobalExpScaleAcc == 3) then -- quadruple exp
		EXPBuffArea.ShowBuff_global_double_exp(true, 3);
	else
		EXPBuffArea.ShowBuff_global_double_exp(false);
	end
	
	local bInstanceEntranceLockOpen = combat_client_object:GetValue("InstanceEntranceLockOpen");
	if(bInstanceEntranceLockOpen == true) then
		MsgHandler.OnInstanceEntranceLockOpen();
	end

	---- NOTE: origianl implementation
	---- NOTE: different instance may share the same world name
	--local worldname = string.match(world_dir, [[/([^/]-)/$]])

	local worldinfo = WorldManager:GetCurrentWorld();
	local worldname = worldinfo.name;

	if(not worldname) then
		LOG.std("", "error","combat","MsgHandler.OnArenaNormalUpdate got invalid world name: "..world_dir);
		return;
	end

	local start_index = combat_client_object:GetValue("arena_start_"..string.lower(worldname));
	if(not start_index) then
		LOG.std("", "error","combat","MsgHandler.OnArenaNormalUpdate got invalid start_index");
		return;
	end
	
	if(not bCheckedInternetCafeStatus) then
		if(System.options.version == "teen") then
			MsgHandler.SendMessageToServer("CheckInternetCafeStatus:");
		end
	end

	-- refresh all arena inactive players
	local i = tonumber(start_index);
	while(true) do
		local key = "arena_inactiveplayer_"..i;
		local value = combat_client_object:GetValue(key);
		if(not value) then
			break;
		end
		if(last_updated_serverobject_normalupdate_inactiveplayer_values[key] ~= value) then
			last_updated_serverobject_normalupdate_inactiveplayer_values[key] = value;
			last_updated_arena_inactiveplayer_values[key] = value;
			-- normal update with key and value
			MsgHandler.OnArenaNormalUpdate_by_inactiveplayer_key_value(key, value);
		end
		i = i + 1;
	end
	
	-- NOTE: the inactive players list is updated BEFORE the normal update, parse process will automatically append the inactive players into the arena data
	-- refresh all arena normal update values
	local i = tonumber(start_index);
	while(true) do
		local key = "arena_"..i;
		local value = combat_client_object:GetValue(key);
		if(not value) then
			break;
		end
		if(last_updated_serverobject_normalupdate_values[key] ~= value) then
			last_updated_serverobject_normalupdate_values[key] = value;
			last_updated_arena_values[key] = value;
			-- normal update with key and value
			MsgHandler.OnArenaNormalUpdate_by_key_value(key, value);
		end
		---- NOTE: the following code is wrong
		-- arena object value is updated through two function:
		--	1. MsgHandler.OnArenaNormalUpdate(combat_client_object); in normal update
		--	2. MsgHandler.OnArenaNormalUpdate_by_key_value(key, value); in PlayTurn Handler
		-- update in play turn keeps the new update sequence while normal update value is updated after the turn is completed to all arena paticipants
		-- if normal update is updates within the new sequence, an old value is applied and then refresh with the next update value
		--if(last_updated_arena_values[key] ~= value) then
			---- normal update with key and value
			--MsgHandler.OnArenaNormalUpdate_by_key_value(key, value);
		--end
		i = i + 1;
	end
	
	if(bNotYetNormalUpdated) then
		bNotYetNormalUpdated = false;
		MsgHandler.OnWorldLoadAndNormalUpdated();
	end

	npl_profiler.perf_end("OnArenaNormalUpdate")
end

------------------------------ card picking ------------------------------

MsgHandler.PickedCardKey = nil;
MsgHandler.PickedCardSeq = nil;
MsgHandler.CardPickerPlayerList = {};
MsgHandler.CardPickerMobList = {};
MsgHandler.CardPickerFriendlyList = {};
MsgHandler.CardPickerHostileList = {};
MsgHandler.CardPickerCardsAtHandList = {};
MsgHandler.CardPickerRunesAtHandList = {};
MsgHandler.CardPickerFollowPetCardsAtHandList = {};
MsgHandler.CardPickerFollowPetHistoryList = {};
MsgHandler.CardPickerCandidateEffectList = {};

-- current sequence id
MsgHandler.current_seq = 0;
MsgHandler.remaining_deck_count = 0;
MsgHandler.total_deck_count = 0;
MsgHandler.nRoundTag = "";
MsgHandler.arena_mode = "";

MsgHandler.callback_after_card_pick = nil;
MsgHandler.callback_after_pass = nil;
MsgHandler.callback_after_card_click = nil;

-- show card picker
-- @param callback_after_card_pick: callback function after the card is picked, mainly for combat tutorial purpose
function MsgHandler.ShowCardPicker(seq, mode, nRoundTag, remaining_deck_count, total_deck_count, remaing_switching_followpet_count, bMyFollowPetCombatMode, friendlylist, hostilelist, cards_at_hand_str, isdead, runes_at_hand_str, followpetcards_at_hand_str, followpet_history_str, callback_after_card_pick, callback_after_pass, callback_after_card_click)
	MsgHandler.callback_after_card_pick = callback_after_card_pick;
	MsgHandler.callback_after_pass = callback_after_pass;
	MsgHandler.callback_after_card_click = callback_after_card_click;
	-- keep reference of sequence
	MsgHandler.current_seq = seq;
	MsgHandler.PickedCardKey = nil;
	MsgHandler.PickedCardSeq = nil;
	-- is unit in arena
	local function IsUnitInArena(isMob, id)
		if(type(ProfileManager.GetNID()) == "number") then
			if(bMyFollowPetCombatMode == false) then
				if(isMob == false and id == -ProfileManager.GetNID()) then
					return false;
				end
			elseif(bMyFollowPetCombatMode == true) then
				if(isMob == false and id == -ProfileManager.GetNID()) then
					return true;
				end
			end
		end
		return true;

		-- NOTE: this arena data is not up-to-date
		-- will cause bug: 第一回合，释放buff（专注、术、盾）法术，会自动选择自身释放，手动取消后才可对队友释放。
		-- will cause bug: 类似专注的选择问题，在蘑菇中发现，debuff的释放作为第一个施法，无法自动生效，且不能选择目标，取消施法，重选后正常。
		--local my_arena = MsgHandler.GetMyArenaData();
		--if(my_arena) then
			--local _, eachplayer;
			--for _, eachplayer in ipairs(my_arena.players) do
				--if(id == eachplayer.nid and isMob == eachplayer.ismob) then
					--return true;
				--end
			--end
			--local _, eachmob;
			--for _, eachmob in ipairs(my_arena.mobs) do
				--if(id == eachmob.id and isMob == eachmob.ismob) then
					--return true;
				--end
			--end
		--end
		--return false;
	end
	-- parse player and mob list
	if(friendlylist and hostilelist) then
		MsgHandler.CardPickerFriendlyList = {};
		MsgHandler.CardPickerHostileList = {};
		local isMob, id;
		for isMob, id in string.gmatch(friendlylist, "([^;]+),([^;]+)") do
			id = tonumber(id) or id;
			if(isMob == "true") then
				isMob = true;
			elseif(isMob == "false") then
				isMob = false;
			else
				isMob = nil;
			end
			if(isMob ~= nil and id) then
				if(IsUnitInArena(isMob, id)) then
					MsgHandler.CardPickerFriendlyList[id] = isMob;
				end
			end
		end
		for isMob, id in string.gmatch(hostilelist, "([^;]+),([^;]+)") do
			id = tonumber(id) or id;
			if(isMob == "true") then
				isMob = true;
			elseif(isMob == "false") then
				isMob = false;
			else
				isMob = nil;
			end
			if(isMob ~= nil and id) then
				if(IsUnitInArena(isMob, id)) then
					MsgHandler.CardPickerHostileList[id] = isMob;
				end
			end
		end
	end

	-- parse cards at hand list
	if(cards_at_hand_str) then
		MsgHandler.CardPickerCardsAtHandList = {};
		local pair;
		for pair in string.gmatch(cards_at_hand_str, "([^,]+)") do
			local seq, bCanCast, cooldown, key, discarded_status = string.match(pair, "^(.-)%+(.-)%+(.-)%+(.-)%+(.-)$");
			if(seq and bCanCast and cooldown and key and discarded_status) then
				seq = tonumber(seq);
				discarded_status = tonumber(discarded_status);
				if(discarded_status == 1) then
					discarded_status = false;
				elseif(discarded_status == -1) then
					discarded_status = true;
				else
					discarded_status = false;
				end
				if(bCanCast == "true") then
					bCanCast = true;
				elseif(bCanCast == "false") then
					bCanCast = false;
				else
					bCanCast = nil;
				end
				cooldown = tonumber(cooldown)
				table.insert(MsgHandler.CardPickerCardsAtHandList, {
					seq = seq,
					bCanCast = bCanCast,
					cooldown = cooldown,
					key = key,
					discarded = discarded_status,
				});
			end
		end
	end

	-- parse runes at hand list
	if(runes_at_hand_str) then
		MsgHandler.CardPickerRunesAtHandList = {};
		local pair;
		for pair in string.gmatch(runes_at_hand_str, "([^,]+)") do
			local count, bCanCast, cooldown, key = string.match(pair, "^(.-)%+(.-)%+(.-)%+(.-)$");
			if(count and bCanCast and cooldown and key) then
				count = tonumber(count);
				if(bCanCast == "true") then
					bCanCast = true;
				elseif(bCanCast == "false") then
					bCanCast = false;
				else
					bCanCast = nil;
				end
				cooldown = tonumber(cooldown)
				table.insert(MsgHandler.CardPickerRunesAtHandList, {
					count = count,
					bCanCast = bCanCast,
					cooldown = cooldown,
					key = key,
					seq = 0,
				});
			end
		end
	end
	
	-- parse follow pet cards at hand list
	if(followpetcards_at_hand_str) then
		MsgHandler.CardPickerFollowPetCardsAtHandList = {};
		local pair;
		for pair in string.gmatch(followpetcards_at_hand_str, "([^,]+)") do
			local seq, bCanCast, cooldown, key = string.match(pair, "^(.-)%+(.-)%+(.-)%+(.-)$");
			if(seq and bCanCast and cooldown and key) then
				seq = tonumber(seq);
				if(bCanCast == "true") then
					bCanCast = true;
				elseif(bCanCast == "false") then
					bCanCast = false;
				else
					bCanCast = nil;
				end
				cooldown = tonumber(cooldown)
				table.insert(MsgHandler.CardPickerFollowPetCardsAtHandList, {
					seq = seq,
					bCanCast = bCanCast,
					cooldown = cooldown,
					key = key,
				});
			end
		end
	end
	
	-- parse follow pet history list
	if(followpet_history_str) then
		MsgHandler.CardPickerFollowPetHistoryList = {};
		local guid;
		for guid in string.gmatch(followpet_history_str, "([^,]+)") do
			guid = tonumber(guid);
			if(guid) then
				MsgHandler.CardPickerFollowPetHistoryList[guid] = true;
			end
		end
	end
	
	-- MyCards.SetCardPickHint reset on each time card picker show
	MyCards.SetCardPickHint(nil, nil, nil);
	MsgHandler.hp_slots_upper_catchable_mob_id = nil;

	local base_mycard_url = "script/apps/Aries/Combat/UI/MyCards.html";
	if(System.options.version == "kids") then
		-- calculate the card pick hint
		local my_level = MyCompany.Aries.Combat.GetMyCombatLevel();
		if(my_level and my_level <= 30) then
			local myarena_data = MsgHandler.GetMyArenaData();
			if(myarena_data) then
				local _;
				for _ = 1, 4 do
					local mob = myarena_data.mobs[_];
					if(mob and mob.can_catchpet and mob.catchpet_gsid) then
						local hasGSItem = ItemManager.IfOwnGSItem;
						if(not hasGSItem(mob.catchpet_gsid)) then
							if(mob.current_hp and mob.max_hp) then
								if(mob.current_hp < (mob.max_hp * 0.7)) then
									MsgHandler.hp_slots_upper_catchable_mob_id = mob.id;
								end
							end
						end
					end
				end
			end
		end
		if(not MsgHandler.hp_slots_upper_catchable_mob_id) then
			-- no catchable pet
			local index, unit, word = MsgHandler.MakeCardPickHint();
			MyCards.SetCardPickHint(index, unit, word);
		else
			local index, unit, word = MsgHandler.MakeCardPickHint_CatchPet();
			if(index) then
				-- with catchpet rune
				MyCards.SetCardPickHint(index, unit, word);
			else
				-- no catchpet rune
				MsgHandler.hp_slots_upper_catchable_mob_id = nil;
				local index, unit, word = MsgHandler.MakeCardPickHint();
				MyCards.SetCardPickHint(index, unit, word);
			end
		end
		base_mycard_url = "script/apps/Aries/Combat/UI/MyCards.html";
	else
		-- calculate the card pick hint
		if(CombatPipTutorial and CombatPipTutorial.IsInTutorial and CombatPipTutorial.IsInTutorial()) then
		else
			local my_level = MyCompany.Aries.Combat.GetMyCombatLevel();
			--if(my_level and my_level >= 2 and my_level <= 5) then
			if(my_level and my_level <= 20) then
				--local count = ItemManager.GetItemCountInBag(10010);
				--if(count == 0) then
					local myarena_data = MsgHandler.GetMyArenaData();
					if(myarena_data) then
						local _;
						for _ = 1, 4 do
							local mob = myarena_data.mobs[_];
							if(mob and mob.can_catchpet and mob.catchpet_gsid) then
								local hasGSItem = ItemManager.IfOwnGSItem;
								if(not hasGSItem(mob.catchpet_gsid)) then
									MsgHandler.hp_slots_upper_catchable_mob_id = mob.id;
								end
							end
						end
					end
				--end
			end
			if(not MsgHandler.hp_slots_upper_catchable_mob_id) then
				local index, unit, word = MsgHandler.MakeCardPickHint();
				if(word) then
					word = string.gsub(word, "给怪物上陷阱", "给怪物上诅咒");
				end
				MyCards.SetCardPickHint(index, unit, word);
			end
		end
		base_mycard_url = "script/apps/Aries/Combat/UI/MyCards_teen.html";
	end

	local params_str = "?nRoundTag="..nRoundTag.."&mode="..mode;
	MsgHandler.remaining_deck_count = remaining_deck_count;
	MsgHandler.total_deck_count = total_deck_count;
	MsgHandler.arena_mode = mode;
	if(mode == "pve") then
		MsgHandler.nRoundTag = tonumber(nRoundTag);
	elseif(mode == "free_pvp") then
		MsgHandler.nRoundTag = tonumber(nRoundTag);
		MsgHandler.nRoundTag = math.ceil(MsgHandler.nRoundTag/ 2);
	end
	params_str = params_str.."&remaing_switching_followpet_count="..remaing_switching_followpet_count;
	params_str = params_str.."&bMyFollowPetCombatMode="..tostring(bMyFollowPetCombatMode);
	params_str = params_str.."&remaining_deck_count="..remaining_deck_count;
	params_str = params_str.."&total_deck_count="..total_deck_count;

	local mycard_url = base_mycard_url..params_str;
	if(isdead) then
		if(System.options.version == "kids") then
			mycard_url = "script/apps/Aries/Combat/UI/MyCards_dead.html"..params_str;
		else
			mycard_url = "script/apps/Aries/Combat/UI/MyCards_dead_teen.html"..params_str;
		end
	else
		mycard_url = base_mycard_url..params_str;
	end

	Cursor.ApplyCursor("default");

	---- NOTE: the pip info is not needed, CardPickerCardsAtHandList already contains the cancast boolean
	--mycard_url = mycard_url.."?offschoolpips="..offSchoolPips.."&selfschoolpips="..selfSchoolPips.."&phase="..phase;

	MsgHandler.ShowCardPicker_url(mycard_url);

	-- NOTE: skip the MyCards.SetCardPickHint reset for holding index and unit
	--MyCards.SetCardPickHint(nil, nil, nil);

	-- auto pick card for player
	local my_arena = MsgHandler.GetMyArenaData();
	if(bAutoAIMode == true) then
		MsgHandler.OnAuto();
	end
end

function MsgHandler.MakeCardPickHint_CatchPet()
	local each_rune_index, each_rune;
	for each_rune_index, each_rune in ipairs(MsgHandler.CardPickerRunesAtHandList) do
		local key_lower = string.lower(each_rune.key);
		if(string.find(key_lower, "catchpet")) then
			return each_rune_index, nil, "快使用抓宠符文抓宠物";
		end
	end
end

function MsgHandler.MakeCardPickHint()
	if(System.options.version == "teen") then
		return MsgHandler.MakeCardPickHint2();
	end
	
	-- skip combat card pick hint for player that is above level 10
	local my_combat_level = Combat.GetMyCombatLevel();
	if(my_combat_level >= 10) then
		return;
	end

	local index = nil;
	local word = nil;
	
	local data = MsgHandler.GetMyArenaData();
	if(data) then
		local bMyselfFarSideInArena = data.bMyselfFarSideInArena;
		
		local bAnyHostileWithShield = false;
		local unit_HostileWithShield = nil;

		local unit_first_mob;
		local unit_list = {};
		local index;
		for index = 1, 4 do
			local unit;
			if(bMyselfFarSideInArena == true) then
				unit = data.players[index] or data.mobs[index + 4];
			else
				unit = data.mobs[index] or data.players[index + 4];
			end
			if(unit and unit.slot_id) then -- could be player with empty table
				-- check global shield
				local buffs = data.slotbuffs[unit.slot_id];
				if(buffs) then
					local wards = ObjectManager.BuffStringToTable(buffs.wards);
					local _, id;
					for _, id in pairs(wards) do
						if(id > 0 and id == 27) then -- 27: Ice_GlobalShield
							unit.with_globalshield = true;
							bAnyHostileWithShield = true;
							unit_HostileWithShield = unit;
							break;
						end
					end
				end
				if(not unit_first_mob) then
					unit_first_mob = unit;
				end
				table.insert(unit_list, unit);
			end
		end
		
		local unit_self;
		local index;
		for index = 1, 4 do
			index = 5 - index;
			if(bMyselfFarSideInArena == true) then
				index = index + 4;
			end
			if(data.players[index].nid == ProfileManager.GetNID()) then
				unit_self = data.players[index];
				break;
			end
		end

		local key_singleheal;
		
		local key_attack;
		local key_attack_index;
		local key_attack_unit;
		local key_attack_no_pip;
		local key_attack_no_pip_index;
		local key_attack_no_pip_unit;
		local key_kill_shot;
		local key_kill_shot_index;
		local key_kill_shot_unit;
		
		local key_attack_damageblade;
		local key_attack_damageblade_index;
		local key_attack_damagetrap;
		local key_attack_damagetrap_index;
		local key_attack_damagetrap_unit;
		local key_globalshield;
		local key_globalshield_index;

		-- evaluate the card value weight, high priority to low:
		-- kill hostile
		-- debuff hostile
		-- buff self
		-- heal
		-- defence
		local CardPickerCardsAtHand_strategy = {};

		local CardPickerCardsAtHandList = MsgHandler.CardPickerCardsAtHandList;
		if(CardPickerCardsAtHandList) then
			local max_attack_key = nil;
			local max_attack_key_index = nil;
			local max_attack_level = -1;
			local discarded_card_count = 0;
			local each_card_index, each_card;
			for each_card_index, each_card in ipairs(MsgHandler.CardPickerCardsAtHandList) do
				local key_lower = string.lower(each_card.key);
				if(each_card.discarded) then
					discarded_card_count = discarded_card_count + 1;
				end
				local this_card_index = each_card_index - discarded_card_count;
				if(each_card.bCanCast and not each_card.discarded) then
					if(string.find(key_lower, "singleattack")) then
						local cardTemplate = Card.GetCardTemplate(each_card.key);
						if(cardTemplate) then
							local damage_min = cardTemplate.params.damage_min;
							local damage_max = cardTemplate.params.damage_max;
							local damage = damage_min;

							-- test each unit target
							local _, unit;
							for _, unit in pairs(unit_list) do
								if((unit.with_globalshield and (damage > unit.current_hp * 2)) or 
									(not unit.with_globalshield and (damage > unit.current_hp))) then
									key_kill_shot = each_card.key;
									key_kill_shot_index = this_card_index;
									key_kill_shot_unit = unit;
								end
							end
						end
						if(cardTemplate.pipcost == 0) then
							key_attack_no_pip = each_card.key;
							key_attack_no_pip_index = this_card_index;
							key_attack_no_pip_unit = unit_first_mob;
							if(bAnyHostileWithShield) then
								key_attack_no_pip_unit = unit_HostileWithShield;
							end
						end
						if(cardTemplate.pipcost > max_attack_level) then
							max_attack_level = cardTemplate.pipcost;
							max_attack_key = each_card.key;
							max_attack_key_index = this_card_index;
						end
					elseif(string.find(key_lower, "damageblade")) then
						key_attack_damageblade = each_card.key;
						key_attack_damageblade_index = this_card_index;
					elseif(string.find(key_lower, "damagetrap")) then
						key_attack_damagetrap = each_card.key;
						key_attack_damagetrap_index = this_card_index;
						key_attack_damagetrap_unit = unit_first_mob;
					elseif(string.find(key_lower, "globalshield")) then
						key_globalshield = each_card.key;
						key_globalshield_index = this_card_index;
					--elseif(string.find(key_lower, "singleheal")) then
						--key_singleheal = each_card.key;
					end
				end
			end
			key_attack = max_attack_key or key_attack_no_pip;
			key_attack_index = max_attack_key_index or key_attack_no_pip_index;
			key_attack_unit = max_attack_key_unit or key_attack_no_pip_unit;
		end

		local pips = unit_self.pips + unit_self.power_pips;

		pips = pips + 1; -- NOTE: tricky pips

		if(key_kill_shot and key_kill_shot_index) then
			--return key_kill_shot_index, "快给怪物以致命一击";
			return key_kill_shot_index, key_kill_shot_unit, "快给怪物强力的攻击";
		elseif(pips <= 1 and key_attack_no_pip and key_attack_no_pip_index and bAnyHostileWithShield) then
			return key_attack_no_pip_index, key_attack_no_pip_unit, "魔光可破防御盾，无需魔力点";
		elseif(pips <= 1 and (unit_self.current_hp / unit_self.max_hp) < 0.7 and key_globalshield and key_globalshield_index) then
			return key_globalshield_index, unit_self, "使用盾可防御大量伤害";
		elseif(pips <= 1 and key_attack_damageblade and key_attack_damageblade_index) then
			return key_attack_damageblade_index, unit_self, "使用术可让伤害增加";
		elseif(pips <= 1 and key_attack_damagetrap and key_attack_damagetrap_index) then
			return key_attack_damagetrap_index, key_attack_damagetrap_unit, "使用陷阱可让伤害增加";
		elseif(pips >= 2 and key_attack and key_attack_index and not bAnyHostileWithShield) then
			return key_attack_index, key_attack_unit, "快给怪物一次强力的攻击";
		elseif(key_attack_no_pip and key_attack_no_pip_index and bAnyHostileWithShield) then
			return key_attack_no_pip_index, key_attack_no_pip_unit, "魔光可破防御盾，无需魔力点";
		elseif(key_attack and key_attack_index) then
			return key_attack_index, key_attack_unit, "快给怪物一次强力的攻击";
		elseif(key_globalshield and key_globalshield_index) then
			return key_globalshield_index, unit_self, "使用盾可防御大量伤害";
		elseif(key_attack_damageblade and key_attack_damageblade_index) then
			return key_attack_damageblade_index, unit_self, "使用术可让伤害增加";
		elseif(key_attack_damagetrap and key_attack_damagetrap_index) then
			return key_attack_damagetrap_index, key_attack_damagetrap_unit, "使用陷阱可让伤害增加";
		end
	end

	return index, nil, word;
end

local damage_weight = 10;
local break_shield_weight = 100000;
local kill_shot_weight = 200000;
local single_debuff_defence_weight = 500;
local single_pip_defence_weight = 500;
local damageblade_apply_weight = 2000;
local damagetrap_apply_weight = 2000;

function MsgHandler.MakeCardPickHint2()
	
	-- skip combat card pick hint for player that is above level 10
	local my_combat_level = Combat.GetMyCombatLevel();
	if(my_combat_level > 6) then
		return;
	end

	do return end
	
	local data = MsgHandler.GetMyArenaData();
	if(data) then
		local hostiles = {};
		local index;
		for index = 1, 4 do
			local unit;
			if(bMyselfFarSideInArena == true) then
				unit = data.players[index] or data.mobs[index + 4];
			else
				unit = data.mobs[index] or data.players[index + 4];
			end
			if(unit and unit.slot_id) then -- could be player with empty table
				-- check global shield
				local buffs = data.slotbuffs[unit.slot_id];
				if(buffs) then
					local wards = ObjectManager.BuffStringToTable(buffs.wards);
					local _, id;
					for _, id in pairs(wards) do
						if(id > 0 and id == 27) then -- 27: Ice_GlobalShield
							unit.with_globalshield = true;
							break;
						end
					end
				end
				table.insert(hostiles, unit);
			end
		end
	
		local blades = {
			[11] = true, -- 11: Fire_FireDamageBlade
			[15] = true, -- 15: Storm_StormDamageBlade
			[17] = true, -- 17: Ice_IceDamageBlade
			[19] = true, -- 19: Life_LifeDamageBlade
			[23] = true, -- 23: Death_DeathDamageBlade
		};

		local traps = {
			[21] = true, -- 21: Fire_FireDamageTrap
			[24] = true, -- 24: Storm_StormDamageTrap
			[25] = true, -- 25: Storm_AreaDamageTrap
			[28] = true, -- 28: Ice_IceDamageTrap
			[36] = true, -- 36: Life_LifeDamageTrap
			[40] = true, -- 40: Death_DeathDamageTrap
			[42] = true, -- 42: Death_GlobalDamageTrap
		};

		local debuff_count_self = 0;
		local unit_self;
		local index;
		for index = 1, 4 do
			index = 5 - index;
			if(bMyselfFarSideInArena == true) then
				index = index + 4;
			end
			if(data.players[index].nid == ProfileManager.GetNID()) then
				unit_self = data.players[index];
				if(unit_self.slot_id) then
					local buffs = data.slotbuffs[unit_self.slot_id];
					local wards = ObjectManager.BuffStringToTable(buffs.wards);
					local _, id;
					for _, id in pairs(wards) do
						if(id > 0 and traps[id]) then
							debuff_count_self = debuff_count_self + 1;
						end
					end
				end
				break;
			end
		end

		--key_kill_shot_index, key_kill_shot_unit, tip_word;
		local strategy_list = {};

		local CardPickerCardsAtHandList = MsgHandler.CardPickerCardsAtHandList;
		if(CardPickerCardsAtHandList) then
			local each_card_index, each_card;
			for each_card_index, each_card in ipairs(MsgHandler.CardPickerCardsAtHandList) do
				local key_lower = string.lower(each_card.key);
				if(each_card.bCanCast and not each_card.discarded) then
					local cardTemplate = Card.GetCardTemplate(each_card.key);
					if(cardTemplate) then
						if(string.find(key_lower, "singleattack")) then
							local damage_min = cardTemplate.params.damage_min;
							local damage_max = cardTemplate.params.damage_max;
							local damage = damage_min;
							local pipcost = cardTemplate.pipcost;

							local _, unit;
							for _, unit in pairs(hostiles) do
								if(unit.current_hp > 0) then
									local weight = 0;
									local this_damage = damage;
									local this_word = "快给怪物一次强力的攻击";
									if(unit.with_globalshield) then
										this_damage = math.ceil(damage / 2);
									end
									weight = weight + this_damage * damage_weight;
									if(pipcost == 0 and unit.with_globalshield) then
										-- this is a kill shot
										weight = weight + break_shield_weight;
										this_word = "用0魔力点的小招可以破怪物的盾，而且不消耗魔力点";
									end
									if(this_damage >= unit.current_hp) then
										-- this is a kill shot
										weight = weight + kill_shot_weight - (this_damage * damage_weight * 2);
										this_word = "快给怪物强力的攻击";
									end
									table.insert(strategy_list, {
										weight = weight,
										index = each_card_index,
										unit = unit,
										word = this_word,
									});
								end
							end
						elseif(string.find(key_lower, "damageblade")) then
							table.insert(strategy_list, {
								weight = damageblade_apply_weight,
								index = each_card_index,
								unit = unit_self,
								word = "快给自己上术，下一次攻击可以得到攻击加成",
							});
						elseif(string.find(key_lower, "damagetrap")) then
							local _, unit;
							for _, unit in pairs(hostiles) do
								if(unit.current_hp > 0) then
									table.insert(strategy_list, {
										weight = damagetrap_apply_weight - unit.current_hp,
										index = each_card_index,
										unit = unit_self,
										word = "给怪物上陷阱，下一次攻击可以使它受到更多伤害",
									});
								end
							end
						elseif(string.find(key_lower, "globalshield")) then
							local weight = 0;
							local total_defence_weight = 0;
							local total_defence_count = 0;
							local _, unit;
							for _, unit in pairs(hostiles) do
								if(unit.current_hp > 0) then
									local this_debuff_count = debuff_count_self;
									if(unit.slot_id) then
										local buffs = data.slotbuffs[unit.slot_id];
										local charms = ObjectManager.BuffStringToTable(buffs.charms);
										local _, id;
										for _, id in pairs(charms) do
											if(id > 0 and blades[id]) then
												this_debuff_count = this_debuff_count + 1;
											end
										end
									end
									if(data.aura ~= "") then
										this_debuff_count = this_debuff_count + 1;
									end
									local pips_valid = unit.pips + unit.power_pips * 2;
									local this_defence_weight = 
										single_debuff_defence_weight * this_debuff_count + 
										single_pip_defence_weight * pips_valid;

									total_defence_weight = total_defence_weight + this_defence_weight;
									total_defence_count = total_defence_count + 1;
								end
							end
							if(total_defence_weight > 0 and total_defence_count > 0) then
								weight = math.ceil(total_defence_weight / total_defence_count);
								table.insert(strategy_list, {
									weight = weight,
									index = each_card_index,
									unit = unit_self,
									word = "快给自己上盾，下一次受到的攻击可以减半",
								});
							end
						end
					end
				end
			end
		end

		local max_weight = 0;
		local max_weight_index = nil;
		local _, strategy;
		for _, strategy in pairs(strategy_list) do
			if(strategy.weight > max_weight) then
				max_weight = strategy.weight;
				max_weight_index = _;
			end
		end

		if(max_weight_index) then
			local strategy = strategy_list[max_weight_index];
			return strategy.index, strategy.unit, strategy.word;
		end
	end
end

function MsgHandler.GetIsAutoAIMode()
	return bAutoAIMode;
end

function MsgHandler.GetIsUseDefaultCamera()
	return bUseDefaultCamera;
end

function MsgHandler.SetIsUseDefaultCamera(bUse)
	bUseDefaultCamera = bUse;
	MyCompany.Aries.app:WriteConfig("bUseDefaultCamera", bUse);
end

-- hide card picker
-- NOTE: hide the pet picker at the same time
function MsgHandler.HideCardPicker()
	local _this = ParaUI.GetUIObject("Aries_CardPicker");
	if(_this:IsValid() == true) then
		_this.visible = false;
	end
	-- hide pet picker
	MsgHandler.HidePetPicker();
	-- hide catch pet item picker
	MsgHandler.HideCatchPetItemPicker();
end

function MsgHandler.ShowIdleCardPicker(word, mode, nRoundTag)
	if(System.options.version == "kids") then
		MsgHandler.ShowCardPicker_url("script/apps/Aries/Combat/UI/MyCards_idle.html?word="..(word or "").."&nRoundTag="..nRoundTag.."&mode="..mode);
	else
		MsgHandler.ShowCardPicker_url("script/apps/Aries/Combat/UI/MyCards_idle_teen.html?word="..(word or "").."&nRoundTag="..nRoundTag.."&mode="..mode);
	end
end

function MsgHandler.HideIdleCardPicker()
	MsgHandler.HideCardPicker();
end

local GMAccount_With_CardPicker = {
	[46650264] = true,
	[156771957] = true,
	[172545123] = true,
	[345856428] = true, -- lipeng
};

local cached_pages = {};

-- only cache url if no paramters
-- @return page, isNewlyCreated:  
function MsgHandler.GetCachedPageByUrl(url)
	local base_url = url:gsub("%?(.*)$", "");
	local page = cached_pages[base_url];
	if(not page) then
		page = System.mcml.PageCtrl:new({url = url, click_through = true});
		cached_pages[base_url] = page;
		return page, true;
	else
		page:SetURL(url);
		return page, false;
	end
end

function MsgHandler.ShowCardPicker_url(url)

	local mycard_url = url;

	local _this = ParaUI.GetUIObject("Aries_CardPicker");
	if(_this:IsValid() == false) then
		if(System.options.version == "kids") then
			_this = ParaUI.CreateUIObject("container", "Aries_CardPicker", "_fi", 0, 0, 0, 0);
		else
			_this = ParaUI.CreateUIObject("container", "Aries_CardPicker", "_fi", 0, 0, 0, 0);
		end
		--_this.background = "texture/alphadot.png";
		_this.background = "";
		_this.zorder = 4;
		_this:GetAttributeObject():SetField("ClickThrough", true);
		_this:AttachToRoot();
		
		if(GMAccount_With_CardPicker[ProfileManager.GetNID()] or SystemInfo.GetField("name") == "Taurus") then
			local _tiny = ParaUI.CreateUIObject("button", "tiny_picker", "_ct", -380, -100, 32, 32);
			_tiny.background = "texture/alphadot.png";
			_tiny.zorder = 2;
			_tiny.onclick = ";MyCompany.Aries.Combat.MsgHandler.ShowCardPicker_menu();";
			_this:AddChild(_tiny);
		end
	end
	
	local page, isNewlyCreated = MsgHandler.GetCachedPageByUrl(url);
	if(page) then
		MsgHandler.MyCardPicker_page = page;
		if(isNewlyCreated) then
			page:Create("DebugCardPicker", _this, "_fi", 0, 0, 0, 0);
		else
			page:Refresh(0);
		end
	end

	local base_url = url:gsub("%?(.*)$", "");
	if(base_url == "script/apps/Aries/Combat/UI/MyCards.html") then
		page:SetValue("SelectableTabs", 1)
	end

	_this.visible = true;
end


function MsgHandler.SetTargetPickerHintUnitOnChoosePickHint(unit)
	MsgHandler.TargetPickerHintUnitOnChoosePickHint = unit;
end

local bAutoPickSingleTarget = false;

-- show target picker
-- @params isHostile: true for hostile units, false for friendly units, nil for defeated but nonfled friendly units
function MsgHandler.ShowTargetPicker(gsid, isHostile, bShowDeadFriendly)
	-- auto pick single target if only one target is available
	if(System.options.EnableAutoPickSingleTarget) then
		-- test proper arena side
		local unit_list;
		if(isHostile == true) then
			unit_list = MsgHandler.CardPickerHostileList;
		elseif(isHostile == false) then
			unit_list = MsgHandler.CardPickerFriendlyList;
		end

		if(unit_list) then
			-- check if it is the only available unit
			local side_count = 0;
			local last_isMob = nil;
			local last_id = nil;
			local id, isMob;
			for id, isMob in pairs(unit_list) do
				side_count = side_count + 1;
				last_isMob = isMob;
				last_id = id;
			end
			if(side_count == 1) then
				if(last_isMob ~= nil and last_id ~= nil) then
					-- pick auto target for the only unit
					MsgHandler.OnPickCard(MsgHandler.PickedCardKey, MsgHandler.PickedCardSeq, last_isMob, last_id);
					return;
				end
			end
		end
	end

	local _parent = ParaUI.GetUIObject("Aries_TargetPicker");
	if(_parent:IsValid() == false) then
		_parent = ParaUI.CreateUIObject("container", "Aries_TargetPicker", "_fi", 0, 0, 0, 0);
		--_this.background = "texture/alphadot.png";
		_parent.background = "";
		_parent:AttachToRoot();

		local text_color = "#d58302";
		local background_tex = "Texture/Aries/Quest/Dialog_BG_32bits.png: 31 31 31 31";
		
		if(System.options.version == "teen") then
			text_color = pe_css.GetDefault("highbluecolor").color;
			background_tex = pe_css.GetDefault("block").background;
			--background_tex = "Texture/Aries/Common/gradient_white_32bits.png";
			--background_color = "#1f3243";
		end
		
		local select_card_tips = if_else(Player.GetLevel()<10, "左键点击施法目标", "左键点击施法目标，右键重新选择卡片。");

		local width = _guihelper.GetTextWidth(select_card_tips) + 20;
		local tip_top = 160;
		local _tip_cont = ParaUI.CreateUIObject("container", "MiddleTargetTip_Player", "_ct", -width/2, tip_top, width, 50);
		_tip_cont.background = background_tex;
		if(background_color) then
			_guihelper.SetUIColor(_tip_cont, background_color);
		end
		_tip_cont.enabled = false;
		_parent:AddChild(_tip_cont);
		local _text = ParaUI.CreateUIObject("button", "text", "_fi", 16,8,8,8);
		--_text.text = "左键点击自己或者某个队友，选择卡片守护的对象";
		_text.text = select_card_tips;
		_text.background = "";
		_guihelper.SetFontColor(_text, text_color);
		_tip_cont:AddChild(_text);

		local _tip_cont = ParaUI.CreateUIObject("container", "MiddleTargetTip_Mob", "_ct", -width/2, tip_top, width, 50);
		_tip_cont.background = background_tex;
		if(background_color) then
			_guihelper.SetUIColor(_tip_cont, background_color);
		end
		_tip_cont.enabled = false;
		_parent:AddChild(_tip_cont);
		local _text = ParaUI.CreateUIObject("button", "text", "_fi", 16,8,8,8);
		--_text.text = "鼠标左键点击怪物，选择魔法攻击的对象！";
		_text.text = select_card_tips;
		_text.background = "";
		_guihelper.SetFontColor(_text, text_color);
		_tip_cont:AddChild(_text);
		
		local _tip_cont = ParaUI.CreateUIObject("container", "MiddleTargetTip_DyingPlayer", "_ct", -width/2, tip_top, width, 50);
		_tip_cont.background = background_tex;
		if(background_color) then
			_guihelper.SetUIColor(_tip_cont, background_color);
		end
		_tip_cont.enabled = false;
		_parent:AddChild(_tip_cont);
		local _text = ParaUI.CreateUIObject("button", "text", "_fi", 16,8,8,8);
		--_text.text = "左键点击自己或者某个队友，选择卡片复活的对象";
		_text.text = select_card_tips;
		_text.background = "";
		_guihelper.SetFontColor(_text, text_color);
		_tip_cont:AddChild(_text);
		
		local _card_display = ParaUI.CreateUIObject("container", "Card_Display", "_ct", -75, -101, 151, 230);
		_card_display.background = "";
		_card_display.enabled = false;
		_parent:AddChild(_card_display);
		
		local _this = ParaUI.CreateUIObject("button", "picker", "_fi", 0, 0, 0, 0);
		--_this.background = "texture/alphadot.png";
		_this.background = "";
		_this.cursor = "Texture/Aries/Cursor/select_combat.tga";
		_this.onframemove = ";MyCompany.Aries.Combat.MsgHandler.UpdateTargetPicker();";
		_this.onclick = ";MyCompany.Aries.Combat.MsgHandler.OnClickTargetPicker();";
		_parent:AddChild(_this);
	end

	if(isHostile == true) then
		_parent:GetChild("MiddleTargetTip_Player").visible = false;
		_parent:GetChild("MiddleTargetTip_Mob").visible = true;
		_parent:GetChild("MiddleTargetTip_DyingPlayer").visible = false;
	elseif(isHostile == false) then
		_parent:GetChild("MiddleTargetTip_Player").visible = true;
		_parent:GetChild("MiddleTargetTip_Mob").visible = false;
		_parent:GetChild("MiddleTargetTip_DyingPlayer").visible = false;
	else
		_parent:GetChild("MiddleTargetTip_Player").visible = false;
		_parent:GetChild("MiddleTargetTip_Mob").visible = false;
		_parent:GetChild("MiddleTargetTip_DyingPlayer").visible = true;
	end

	local card_key_lower = string.lower(Combat.Get_cardkey_from_gsid(gsid) or "");
	
	local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
	local card_icon;
	if(gsItem and gsItem.icon) then
		card_icon = gsItem.icon;
	end

	if(System.options.version == "teen") then
		if(MsgHandler.PickedCardKey == "CatchPet") then
			card_icon = "Texture/Aries/Combat/CatchPet/CatchPet_card.png; 0 0 151 230";
		elseif(MsgHandler.PickedCardKey == "ChangePet") then
			card_icon = "Texture/Aries/Combat/ChangePet/ChangePet_card.png; 0 0 151 230";
		end
	end

	local Card_Display = _parent:GetChild("Card_Display");
	if(card_icon) then
		Card_Display.background = card_icon;
		
		-- tricky code to destroy the card_canvas explicitly
		Card_Display:RemoveAll();
		
		if(System.options.version == "teen") then
			Map3DSystem.mcml_controls.pe_item.DrawCardMask_teen(gsid, Card_Display, true, true);
		else
			Map3DSystem.mcml_controls.pe_item.DrawCardMask(gsid, Card_Display, true);
		end
	else
		Card_Display.background = "";
		
		if(not gsid) then
			-- tricky code to destroy the card_canvas explicitly for catch pet
			Card_Display:RemoveAll();
		end
	end
	
	_parent.visible = true;


	local combattargetpicker_asset_file = "character/v5/09effect/Combat_Common/TargetPicker/MouseOver/MouseOver.x";

	if(isHostile == false) then
		combattargetpicker_asset_file = "character/v5/09effect/Combat_Common/TargetPicker/MouseOver/MouseOver_friendly.x";
	end

	-- mouse over effect
	local params = {
		asset_file = combattargetpicker_asset_file,
		binding_obj_name = nil,
		start_position = {0,0,0},
		duration_time = 999999999,
		scale = 1,
		force_name = "Aries_CombatTargetPicker",
		begin_callback = function() 
		end,
		end_callback = function() 
		end,
		elapsedtime_callback = function(elapsedTime, obj) 
			local x = MsgHandler.TargetMouseOverEffect_position_x or 0;
			local y = MsgHandler.TargetMouseOverEffect_position_y or 0;
			local z = MsgHandler.TargetMouseOverEffect_position_z or 0;
			y = y - 1;
			obj:SetPosition(x, y, z);
			
			local function GetNormalBG(background)
				if(System.options.version == "teen") then
					if(background == "Texture/Aries/Combat/CombatStateTeen/combatState_bg2_32bits.png;0 0 248 98") then
						return "Texture/Aries/Combat/CombatStateTeen/combatState_bg2_32bits.png;0 0 248 98";
					elseif(background == "Texture/Aries/Combat/CombatStateTeen/combatState_bg2_highlight_32bits.png;0 0 248 98") then
						return "Texture/Aries/Combat/CombatStateTeen/combatState_bg2_32bits.png;0 0 248 98";
					elseif(background == "Texture/Aries/Combat/CombatStateTeen/combatState_bg2_elite_32bits.png;0 0 248 98") then
						return "Texture/Aries/Combat/CombatStateTeen/combatState_bg2_elite_32bits.png;0 0 248 98";
					elseif(background == "Texture/Aries/Combat/CombatStateTeen/combatState_bg2_elite_highlight_32bits.png;0 0 248 98") then
						return "Texture/Aries/Combat/CombatStateTeen/combatState_bg2_elite_32bits.png;0 0 248 98";
					elseif(background == "Texture/Aries/Combat/CombatStateTeen/combatState_bg2_boss_32bits.png;0 0 248 98") then
						return "Texture/Aries/Combat/CombatStateTeen/combatState_bg2_boss_32bits.png;0 0 248 98";
					elseif(background == "Texture/Aries/Combat/CombatStateTeen/combatState_bg2_boss_highlight_32bits.png;0 0 248 98") then
						return "Texture/Aries/Combat/CombatStateTeen/combatState_bg2_boss_32bits.png;0 0 248 98";
					end
				else
					if(background == "Texture/Aries/Combat/CombatState/combatState_enrage_bg_highlight_32bits.png;0 0 210 69") then
						return "Texture/Aries/Combat/CombatState/combatState_enrage_bg_32bits.png;0 0 210 69";
					elseif(background == "Texture/Aries/Combat/CombatState/combatState_bg_highlight_32bits.png;0 0 210 69") then
						return "Texture/Aries/Combat/CombatState/combatState_bg_32bits.png;0 0 210 69";
					end
				end
			end

			local function GetHighlightBG(background)
				if(System.options.version == "teen") then
					if(background == "Texture/Aries/Combat/CombatStateTeen/combatState_bg2_32bits.png;0 0 248 98") then
						return "Texture/Aries/Combat/CombatStateTeen/combatState_bg2_highlight_32bits.png;0 0 248 98";
					elseif(background == "Texture/Aries/Combat/CombatStateTeen/combatState_bg2_highlight_32bits.png;0 0 248 98") then
						return "Texture/Aries/Combat/CombatStateTeen/combatState_bg2_highlight_32bits.png;0 0 248 98";
					elseif(background == "Texture/Aries/Combat/CombatStateTeen/combatState_bg2_elite_32bits.png;0 0 248 98") then
						return "Texture/Aries/Combat/CombatStateTeen/combatState_bg2_elite_highlight_32bits.png;0 0 248 98";
					elseif(background == "Texture/Aries/Combat/CombatStateTeen/combatState_bg2_elite_highlight_32bits.png;0 0 248 98") then
						return "Texture/Aries/Combat/CombatStateTeen/combatState_bg2_elite_highlight_32bits.png;0 0 248 98";
					elseif(background == "Texture/Aries/Combat/CombatStateTeen/combatState_bg2_boss_32bits.png;0 0 248 98") then
						return "Texture/Aries/Combat/CombatStateTeen/combatState_bg2_boss_highlight_32bits.png;0 0 248 98";
					elseif(background == "Texture/Aries/Combat/CombatStateTeen/combatState_bg2_boss_highlight_32bits.png;0 0 248 98") then
						return "Texture/Aries/Combat/CombatStateTeen/combatState_bg2_boss_highlight_32bits.png;0 0 248 98";
					end
				else
					if(background == "Texture/Aries/Combat/CombatState/combatState_enrage_bg_32bits.png;0 0 210 69") then
						return "Texture/Aries/Combat/CombatState/combatState_enrage_bg_highlight_32bits.png;0 0 210 69";
					elseif(background == "Texture/Aries/Combat/CombatState/combatState_bg_32bits.png;0 0 210 69") then
						return "Texture/Aries/Combat/CombatState/combatState_bg_highlight_32bits.png;0 0 210 69";
					end
				end
			end

			if(MsgHandler.MouseOverPlayerID) then
				if(MsgHandler.LastHPSlotFrameID ~= MsgHandler.MouseOverPlayerID) then
					if(MsgHandler.LastHPSlotFrameID) then
						local _this = ParaUI.GetUIObject("hp_slot_frame_"..MsgHandler.LastHPSlotFrameID);
						if(_this:IsValid() == true) then
							_this.background = GetNormalBG(_this.background);
						end
					end
					local _this = ParaUI.GetUIObject("hp_slot_frame_"..MsgHandler.MouseOverPlayerID);
					if(_this:IsValid() == true) then
						_this.background = GetHighlightBG(_this.background);
						MsgHandler.LastHPSlotFrameID = MsgHandler.MouseOverPlayerID;
						return;
					end
				else
					return;
				end
			elseif(MsgHandler.MouseOverMobID) then
				if(MsgHandler.LastHPSlotFrameID ~= MsgHandler.MouseOverMobID) then
					if(MsgHandler.LastHPSlotFrameID) then
						local _this = ParaUI.GetUIObject("hp_slot_frame_"..MsgHandler.LastHPSlotFrameID);
						if(_this:IsValid() == true) then
							_this.background = GetNormalBG(_this.background);
						end
					end
					local _this = ParaUI.GetUIObject("hp_slot_frame_"..MsgHandler.MouseOverMobID);
					if(_this:IsValid() == true) then
						_this.background = GetHighlightBG(_this.background);
						MsgHandler.LastHPSlotFrameID = MsgHandler.MouseOverMobID;
						return;
					end
				else
					return;
				end
			end
			if(MsgHandler.LastHPSlotFrameID) then
				local _this = ParaUI.GetUIObject("hp_slot_frame_"..MsgHandler.LastHPSlotFrameID);
				if(_this:IsValid() == true) then
					_this.background = GetNormalBG(_this.background);
				end
				MsgHandler.LastHPSlotFrameID = nil;
			end
			
		end,
	};
	local EffectManager = MyCompany.Aries.EffectManager;
	EffectManager.CreateEffect(params);

	-- clear effects
	MsgHandler.ClearTargetPickerCandidateEffect();
	-- reset candidate effect list
	MsgHandler.CardPickerCandidateEffectList = {};
	
	if(isHostile == true) then
		-- show only hostile units
		local id, isMob;
		for id, isMob in pairs(MsgHandler.CardPickerHostileList) do
			-- check stealth and single attack card type
			local is_stealth_and_singleattack_target = false;
			if( not (string.find(card_key_lower, "area") or string.find(card_key_lower, "singleheal")) ) then
				local myArena = MsgHandler.GetMyArenaData();
				if(isMob) then
					-- check all players for stealth
					if(myArena and myArena.players) then
						local _, each_player;
						for _, each_player in pairs(myArena.players) do
							if(each_player and each_player.nid == id) then
								-- hit
								if(string.find(each_player.miniaura, "stealth")) then
									is_stealth_and_singleattack_target = true;
								end
								break;
							end
						end
					end
				else
					-- check all mobs for stealth
					if(myArena and myArena.mobs) then
						local _, eachmob;
						for _, eachmob in pairs(myArena.mobs) do
							if(eachmob and eachmob.id == id) then
								-- hit
								if(string.find(eachmob.miniaura, "stealth")) then
									is_stealth_and_singleattack_target = true;
								end
								break;
							end
						end
					end
				end
			end

			if(not is_stealth_and_singleattack_target) then
				if(isMob) then
					MsgHandler.CardPickerCandidateEffectList["NPC:39001("..id..")"] = true;
				else
					if((tonumber(id) or 1) > 0) then
						MsgHandler.CardPickerCandidateEffectList[tostring(id)] = true;
					else
						MsgHandler.CardPickerCandidateEffectList[-id.."+followpet"] = true;
					end
				end
			end
		end
	elseif(isHostile == false) then
		-- show only friendly units
		local id, isMob;
		for id, isMob in pairs(MsgHandler.CardPickerFriendlyList) do
			if(isMob) then
				MsgHandler.CardPickerCandidateEffectList["NPC:39001("..id..")"] = true;
			else
				local isUnitDead = false;
				if(MsgHandler.IsMyArenaUnitDead(id, isMob)) then
					isUnitDead = true;
				end

				if(not isUnitDead or bShowDeadFriendly) then
					if((tonumber(id) or 1) > 0) then
						MsgHandler.CardPickerCandidateEffectList[tostring(id)] = true;
					else
						MsgHandler.CardPickerCandidateEffectList[-id.."+followpet"] = true;
					end
				end
			end
		end
	end

	local asset_file = "character/v5/09effect/Combat_Common/TargetPicker/Candidate/Candidate.x";
	local asset_file_player = "character/v5/09effect/Combat_Common/TargetPicker/Candidate/Candidate.x";
	
	local asset_file_witharrow = "character/v5/09effect/Combat_Common/TargetPicker/Candidate/Candidate_for_combat_tutorial.x";
	if(System.options.version == "teen") then
		asset_file_witharrow = "character/v5/09effect/Combat_Common/TargetPicker/Candidate/Candidate_for_combat_tutorial_teen.x";
	end
	local asset_file_player_witharrow = "character/v5/09effect/Combat_Common/TargetPicker/Candidate/Candidate_for_combat_tutorial02.x";

	if(isHostile == false) then
		asset_file = "character/v5/09effect/Combat_Common/TargetPicker/Candidate/Candidate_friendly.x";
		asset_file_player = "character/v5/09effect/Combat_Common/TargetPicker/Candidate/Candidate_friendly.x";
	end

	if(CombatTutorial and CombatTutorial.IsInTutorial and CombatTutorial.IsInTutorial()) then
		asset_file = "character/v5/09effect/Combat_Common/TargetPicker/Candidate/Candidate_for_combat_tutorial.x";
		asset_file_player = "character/v5/09effect/Combat_Common/TargetPicker/Candidate/Candidate_for_combat_tutorial02.x";
	end
	if(CombatPipTutorial and CombatPipTutorial.IsInTutorial and CombatPipTutorial.IsInTutorial()) then
		asset_file = "character/v5/09effect/Combat_Common/TargetPicker/Candidate/Candidate_for_combat_tutorial.x";
		asset_file_player = "character/v5/09effect/Combat_Common/TargetPicker/Candidate/Candidate_for_combat_tutorial02.x";
	end
	
	local pickerhint_character_name;
	local pickerhint_character_asset_file;
	if(MsgHandler.TargetPickerHintUnitOnChoosePickHint) then
		local unit = MsgHandler.TargetPickerHintUnitOnChoosePickHint;
		if(unit.ismob == true) then
			pickerhint_character_name = "NPC:39001("..unit.id..")";
			pickerhint_character_asset_file = asset_file_witharrow;
		elseif(unit.ismob == false) then
			pickerhint_character_name = tostring(unit.nid);
			pickerhint_character_asset_file = asset_file_player_witharrow;
		end
	end
	
	local name, _;
	for name, _ in pairs(MsgHandler.CardPickerCandidateEffectList) do
		local x, y, z;
		local binding_obj = ParaScene.GetObject(name);
		if(binding_obj and binding_obj:IsValid() == true) then
			x, y, z = binding_obj:GetPosition();
		end

		-- mouse over effect
		local params = {
			asset_file = if_else(tonumber(name), asset_file_player, asset_file),
			binding_obj_name = name,
			start_position = {x, y, z},
			duration_time = 999999999,
			scale = 1,
			force_name = "Aries_Candidate_"..name,
			begin_callback = function() 
			end,
			end_callback = function() 
			end,
		};
		if(pickerhint_character_name == name) then
			params.asset_file = pickerhint_character_asset_file;
		end

		local EffectManager = MyCompany.Aries.EffectManager;
		EffectManager.CreateEffect(params);
	end
	
	-- set select cursor
	System.SendMessage_game({type = Map3DSystem.msg.GAME_CURSOR, cursor = "aries_select"})
	--ParaUI.SetCursorFromFile("Texture/Aries/Cursor/select.tga",3,4);
end

-- hide target picker
function MsgHandler.HideTargetPicker()
	local _this = ParaUI.GetUIObject("Aries_TargetPicker");
	if(_this:IsValid() == true) then
		_this.visible = false;
	end
	-- destroy effect
	local EffectManager = MyCompany.Aries.EffectManager;
	EffectManager.DestroyEffect("Aries_CombatTargetPicker");
	-- also clear the picker candidates
	MsgHandler.ClearTargetPickerCandidateEffect();
	-- set back to normal cursor
	System.SendMessage_game({type = Map3DSystem.msg.GAME_CURSOR, cursor = "main"})
	--ParaUI.SetCursorFromFile("Texture/kidui/main/cursor.tga",3,4);
end

-- clear candidate effect
function MsgHandler.ClearTargetPickerCandidateEffect()
	local name, _;
	for name, _ in pairs(MsgHandler.CardPickerCandidateEffectList) do
		-- destroy effect
		local EffectManager = MyCompany.Aries.EffectManager;
		EffectManager.DestroyEffect("Aries_Candidate_"..name);
	end
end

-- show follow pet picker
function MsgHandler.ShowPetPicker()
	--NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetPage.lua");
	--local CombatPetPage = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetPage");
	--CombatPetPage.ShowPage(nil,true);

	if(System.options.version == "kids") then
		MsgHandler.ShowCardPicker_url("script/apps/Aries/Combat/UI/MyPets.html")
	else
		MsgHandler.ShowCardPicker_url("script/apps/Aries/Combat/UI/MyPets_teen.html")
	end
end

-- hide follow pet picker
function MsgHandler.HidePetPicker()
	--NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetPage.lua");
	--local CombatPetPage = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetPage");
	--CombatPetPage.ClosePage();
	
	local _this = ParaUI.GetUIObject("Aries_CardPicker");
	if(_this:IsValid() == true) then
		_this.visible = false;
	end
end

-- on click close follow pet picker
function MsgHandler.OnClickClosePetPicker()
	-- hide all target picker related assets
	MsgHandler.HideTargetPicker();
	MsgHandler.PickedCardKey = nil;
	MsgHandler.PickedCardSeq = nil;
	MsgHandler.ClearTargetPickerCandidateEffect();
	-- cancel the card picker and retrieve the recent card picker command
	MsgHandler.OnCancelPickCardByPlayer();
	-- hide pet picker
	MsgHandler.HidePetPicker();
	-- hide catch pet item picker
	MsgHandler.HideCatchPetItemPicker();
end


-- show catch pet item
-- pick from one fo the catch pet items
function MsgHandler.ShowCatchPetItemPicker(mob_id, level, current_hp, max_hp)
	local bMyArenaPlayingTurns = MsgHandler.IsMyArenaPlayingTurns();
	if(mob_id and level and not bMyArenaPlayingTurns) then
		MsgHandler.ShowCardPicker_url("script/apps/Aries/Combat/UI/MyCards_catchpet_teen.html?mob_id="..mob_id
			.."&level="..level
			.."&current_hp="..current_hp
			.."&max_hp="..max_hp);
	end
end

-- hide catch pet item picker
function MsgHandler.HideCatchPetItemPicker()
	local _this = ParaUI.GetUIObject("Aries_CardPicker");
	if(_this:IsValid() == true) then
		_this.visible = false;
	end
end

-- on click close catch pet item picker
function MsgHandler.OnClickCatchPetItemPicker()
	-- hide all target picker related assets
	MsgHandler.HideTargetPicker();
	MsgHandler.PickedCardKey = nil;
	MsgHandler.PickedCardSeq = nil;
	MsgHandler.ClearTargetPickerCandidateEffect();
	-- cancel the card picker and retrieve the recent card picker command
	MsgHandler.OnCancelPickCardByPlayer();
	-- hide pet picker
	MsgHandler.HidePetPicker();
	-- hide catch pet item picker
	MsgHandler.HideCatchPetItemPicker();
end

-- revivable card key name
local base_revivable_card_name = {
	["Life_SingleHeal_ForLife_Level2"] = true,
	["Life_SingleHealWithHOT_Level5"] = true,
	["Life_SingleHeal_LevelX"] = true,
	["Life_Pet_SingleHeal_Nymphora"] = true,
	["Death_SingleHealWithImmolate_Level3"] = true,
	["Balance_Rune_SingleHeal_Level2"] = true,
	["Balance_AreaHeal_DragonLight"] = true,
	["Balance_SingleHealWithHOT_Snake"] = true,
	["Balance_Rune_SingleHeal_LongCD"] = true,
};

local revivable_card_name = {};
local base_name, _;
for base_name, _ in pairs(base_revivable_card_name) do
	revivable_card_name[base_name] = true;
	revivable_card_name[base_name.."_Green"] = true;
	revivable_card_name[base_name.."_Blue"] = true;
	revivable_card_name[base_name.."_Purple"] = true;
	revivable_card_name[base_name.."_Orange"] = true;
end

-- onclick target picker
function MsgHandler.OnClickTargetPicker()
	if(mouse_button == "right") then
		local IsInTutorial = commonlib.getfield("MyCompany.Aries.Quest.NPCs.BasicArena.IsInTutorial");
		if(IsInTutorial) then
			if(IsInTutorial()) then
				return;
			end
		end
		-- hide all target picker related assets
		MsgHandler.HideTargetPicker();
		MsgHandler.PickedCardKey = nil;
		MsgHandler.PickedCardSeq = nil;
		MsgHandler.ClearTargetPickerCandidateEffect();
		-- cancel the card picker and retrieve the recent card picker command
		MsgHandler.OnCancelPickCardByPlayer();
	else
		MsgHandler.UpdateTargetPicker();
		
		local _this = ParaUI.GetUIObject("Aries_CardPicker");
		if(_this:IsValid() == true and _this.visible) then
			return;
		end

		if(MsgHandler.MouseOverPlayerID and MsgHandler.PickedCardKey) then
			if(string.find(string.lower(MsgHandler.PickedCardKey), "heal")) then
				if(not revivable_card_name[MsgHandler.PickedCardKey]) then
					-- check if player is alive
					local myArena = MsgHandler.GetMyArenaData();
					if(myArena and myArena.players) then
						local _, each_player;
						for _, each_player in pairs(myArena.players) do
							if(each_player and each_player.nid == MsgHandler.MouseOverPlayerID) then
								if(each_player.current_hp <= 0) then
									-- skip the card pick
									BroadcastHelper.PushLabel({id="invalid_revive_target", label = "这个卡片不能复活", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
									return;
								end
								break;
							end
						end
					end
				end
			end
			MsgHandler.OnPickCard(MsgHandler.PickedCardKey, MsgHandler.PickedCardSeq, false, MsgHandler.MouseOverPlayerID);
			MsgHandler.HideTargetPicker();
			MsgHandler.ClearTargetPickerCandidateEffect();
		elseif(MsgHandler.MouseOverMobID and MsgHandler.PickedCardKey) then
			MsgHandler.OnPickCard(MsgHandler.PickedCardKey, MsgHandler.PickedCardSeq, true, MsgHandler.MouseOverMobID);
			MsgHandler.HideTargetPicker();
			MsgHandler.ClearTargetPickerCandidateEffect();
		else
			--MsgHandler.ShowCardPicker(); BUG nil list 
		end
		--MsgHandler.HideTargetPicker();
		--MsgHandler.ClearTargetPickerCandidateEffect();
	end
end

local slowdown_timer = 6;

function MsgHandler.UpdateCursorTooltip()
	slowdown_timer = slowdown_timer + 1;
	if(slowdown_timer > 5) then
		slowdown_timer = 0;
		-- 12007_AutomaticCombatPills
		local hasGSItem = ItemManager.IfOwnGSItem;
		if(not hasGSItem(12007)) then
			if(not MsgHandler.UsedFreeAutoPillCount) then
				local server_date = MyCompany.Aries.Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
				MsgHandler.UsedFreeAutoPillCount = Player.LoadLocalData("UsedFreeAutoPillCount_"..server_date, 0);
			end
			if(MsgHandler.UsedFreeAutoPillCount >= MsgHandler.GetMaxFreeAutoCombatCount()) then
				if(not MsgHandler.IsInCombat()) then
					bAutoAIMode = false;
				end
			end
		end
		-- show auto ai mode button
		MsgHandler.ShowAutoAIModeBtn()
		
		if(HomeLandGateway.IsInHomeland()) then
			-- hide auto ai mode button in homeland
			MsgHandler.ShowAutoAIModeBtn(false)
		end

		if(BasicArena.IsInTutorial() ~= false) then
			-- hide auto ai mode button in tutorial
			MsgHandler.ShowAutoAIModeBtn(false)
		end
	end
end


function MsgHandler.SetAutoAIMode(bAuto)
	bAutoAIMode = bAuto;
end

function MsgHandler.ToggleAutoAIMode()
	bAutoAIMode = not bAutoAIMode;
end
-- on click the toggle auto ai mode
function MsgHandler.OnClickToggleAutoAIMode()
	-- 12007_AutomaticCombatPills
	local hasGSItem = ItemManager.IfOwnGSItem;
	if(not hasGSItem(12007)) then
		if(not MsgHandler.UsedFreeAutoPillCount) then
			local server_date = MyCompany.Aries.Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
			MsgHandler.UsedFreeAutoPillCount = Player.LoadLocalData("UsedFreeAutoPillCount_"..server_date, 0);
		end
		if(MsgHandler.UsedFreeAutoPillCount >= MsgHandler.GetMaxFreeAutoCombatCount()) then
			bAutoAIMode = false;
			_guihelper.MessageBox([[<div style="margin-top:16px;">没有自动战斗药丸不能进入自动战斗模式</div>]]);
			return;
		end
	end

	bAutoAIMode = not bAutoAIMode;

	if(bAutoAIMode == true and MsgHandler.IsInCombat()) then
		-- auto trigger pick card
		MsgHandler.OnAuto();
	end

	slowdown_timer = 6; -- tricky: force update
	MsgHandler.UpdateCursorTooltip()

	Dock.RefreshPage()
end
-- @param bShow: if nil, it will only update if button is already visible. 
function MsgHandler.ShowAutoAIModeBtn(bShow)
	if(System.options.mc) then
		return
	end
	local worldinfo = WorldManager:GetCurrentWorld();
	local worldname = worldinfo.name;

	if(not worldname or (string.match(worldname,"HaqiTown_LafeierCastle_PVP_Matcher") and System.options.version == "kids")) then
		MsgHandler.SetAutoAIMode(false);
		return;
	end

	local _this, _parent;
	_parent = ParaUI.GetUIObject("Area_AutoAIModeBtn");
	
	if(_parent:IsValid() == false) then
		if(not bShow) then return end

		if(System.options.version == "teen") then
			_parent = ParaUI.CreateUIObject("container", "Area_AutoAIModeBtn", "_ctr", 0, 0, 26, 97);
		else
			_parent = ParaUI.CreateUIObject("container", "Area_AutoAIModeBtn", "_ctr", 0, 0, 32, 64);
		end
		_parent.background = "";
		_parent:GetAttributeObject():SetField("ClickThrough", true);
		_parent:AttachToRoot();
	else
		if(bShow) then
			_parent.visible = bShow;
		elseif(bShow == nil) then
			bShow = _parent.visible;
		elseif(bShow == false) then
			_parent.visible = false;
		end
	end

	if(bShow) then
		_this = _parent:GetChild("AutoAIModeBtn");
		if(not _this:IsValid()) then
			if(System.options.version == "teen") then
				_this = ParaUI.CreateUIObject("button", "AutoAIModeBtn", "_lt", 0, 0, 26, 97);
			else
				_this = ParaUI.CreateUIObject("button", "AutoAIModeBtn", "_lt", 5, 0, 32, 64);
			end
			_this.onclick = ";MyCompany.Aries.Combat.MsgHandler.OnClickToggleAutoAIMode();";
			_parent:AddChild(_this);
		end
		local hasGSItem = ItemManager.IfOwnGSItem;
		local _, _, _, copies = hasGSItem(12007)
		copies = copies or 0;
		
		local FreeAutoPillWord = "";
		if(not MsgHandler.UsedFreeAutoPillCount) then
			local server_date = MyCompany.Aries.Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
			MsgHandler.UsedFreeAutoPillCount = Player.LoadLocalData("UsedFreeAutoPillCount_"..server_date, 0);
		end
		if(System.options.version == "kids") then
			FreeAutoPillWord = "还剩"..tostring(MsgHandler.GetMaxFreeAutoCombatCount() - MsgHandler.UsedFreeAutoPillCount).."次免费使用自动战斗药丸\n";
		end

		if(bAutoAIMode == true) then
			_this.tooltip = "正在自动战斗\n"..FreeAutoPillWord.."还剩"..tostring(copies).."粒自动战斗药丸";
			if(System.options.version == "teen") then
				_this.background = "Texture/Aries/Common/AutoAIMode_on_teen_32bits.png; 0 0 26 97";
			else
				_this.background = "Texture/Aries/Common/AutoAIMode_on_32bits.png; 0 0 32 64";
			end
		elseif(bAutoAIMode == false) then
			_this.tooltip = "点击打开自动战斗\n"..FreeAutoPillWord.."还剩"..tostring(copies).."粒自动战斗药丸";
			if(System.options.version == "teen") then
				_this.background = "Texture/Aries/Common/AutoAIMode_off_teen_32bits.png; 0 0 26 97";
			else
				_this.background = "Texture/Aries/Common/AutoAIMode_off_32bits.png; 0 0 32 64";
			end
		end
	end
end

function MsgHandler.OnCostAutomaticAICombatPill()
	--show some hint
	BroadcastHelper.PushLabel({id="auto_combat_pill_cost_tip", label = "消耗 自动战斗药丸 x 1", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
end

function MsgHandler.OnSkipCostAutomaticAICombatPill()
	-- record used pill count
	local server_date = MyCompany.Aries.Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
	if(not MsgHandler.UsedFreeAutoPillCount) then
		MsgHandler.UsedFreeAutoPillCount = Player.LoadLocalData("UsedFreeAutoPillCount_"..server_date, 0);
	end
	MsgHandler.UsedFreeAutoPillCount = MsgHandler.UsedFreeAutoPillCount + 1;
	Player.SaveLocalData("UsedFreeAutoPillCount_"..server_date, MsgHandler.UsedFreeAutoPillCount);
	--show some hint
	BroadcastHelper.PushLabel({id="skip_auto_combat_pill_cost_tip", label = "免费使用自动战斗药丸 还剩"..(MsgHandler.GetMaxFreeAutoCombatCount() - MsgHandler.UsedFreeAutoPillCount).."次", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
end

-- target picker frame move
function MsgHandler.UpdateTargetPicker()
	local name;
	local obj = ParaScene.MousePick(70, "biped");
	if(obj and obj:IsValid()) then
		name = obj.name;
		if(System.options.mc) then
			if(GameLogic.EntityManager.GetPlayer().obj_id == obj.id) then
				name = "localuser"
			end
		end
	else
		local x, y = ParaUI.GetMousePosition();
		local temp = ParaUI.GetUIObjectAtPoint(x, y);
		
		if(temp:IsValid() == true) then
			name = temp.name;
		end
	end

	if(name) then
		local npc_instance_id = string_match(name, "^NPC:39001%((%d+)%)$");
		local player_nid = string_match(name, "^(%d+)$") or string_match(name, "^(%d+)%+driver$");
		if(name == "localuser") then
			player_nid = name;
		else
			if(not player_nid) then
				player_nid = string_match(name, "^(%d+)%+followpet$");
				if(player_nid) then
					player_nid = "-"..player_nid;
				end
			end
			if(not player_nid) then
				player_nid = string_match(name, "^%-(%d+)$");
				if(player_nid) then
					player_nid = "-"..player_nid;
				end
			end
		end
		if(npc_instance_id) then
			local obj = ParaScene_GetObject("NPC:39001("..npc_instance_id..")");
			if(obj:IsValid()) then
				if((MsgHandler.CardPickerFriendlyList[tonumber(npc_instance_id)] == true or MsgHandler.CardPickerHostileList[tonumber(npc_instance_id)] == true) 
					and MsgHandler.CardPickerCandidateEffectList[obj.name]) then
					MsgHandler.MouseOverPlayerID = nil;
					MsgHandler.MouseOverMobID = tonumber(npc_instance_id);
					local x, y, z = obj:GetPosition();
					MsgHandler.TargetMouseOverEffect_position_x = x;
					MsgHandler.TargetMouseOverEffect_position_y = y;
					MsgHandler.TargetMouseOverEffect_position_z = z;
					return;
				end
			end
		elseif(player_nid) then
			local obj;
			player_nid = tonumber(player_nid) or player_nid;
			if(type(player_nid) == "number") then
				if(tonumber(player_nid) < 0) then
					obj = ParaScene_GetObject(-tonumber(player_nid).."+followpet");
				else
					obj = ParaScene_GetObject(tostring(player_nid));
				end
				name = obj.name;
			elseif(player_nid == "localuser") then
				obj = GameLogic.EntityManager.GetPlayer():GetInnerObject();
			end
			if(obj:IsValid()) then
				if((MsgHandler.CardPickerFriendlyList[player_nid] == false or MsgHandler.CardPickerHostileList[player_nid] == false)
					and MsgHandler.CardPickerCandidateEffectList[name]) then
					MsgHandler.MouseOverPlayerID = player_nid;
					MsgHandler.MouseOverMobID = nil;
					local x, y, z = obj:GetPosition();
					MsgHandler.TargetMouseOverEffect_position_x = x;
					MsgHandler.TargetMouseOverEffect_position_y = y;
					MsgHandler.TargetMouseOverEffect_position_z = z;
					return;
				end
			end
		end
	end
	MsgHandler.MouseOverPlayerID = nil;
	MsgHandler.MouseOverMobID = nil;
	MsgHandler.TargetMouseOverEffect_position_x = 0;
	MsgHandler.TargetMouseOverEffect_position_y = 0;
	MsgHandler.TargetMouseOverEffect_position_z = 0;
end

function MsgHandler.ShowHPMinusHint()
	--local _tip_cont = ParaUI.GetUIObject("Combat_Tutorial_ShowHPMinusHint");
	--if(_tip_cont:IsValid() == false) then
		--_tip_cont = ParaUI.CreateUIObject("container", "Combat_Tutorial_ShowHPMinusHint", "_lb", 20, -400, 200, 100);
		--_tip_cont.background = "Texture/Aries/Quest/Dialog_BG_32bits.png: 31 31 31 31";
		--_tip_cont.enabled = false;
		--_tip_cont:AttachToRoot();
		--local _text = ParaUI.CreateUIObject("text", "text", "_lt", 15, 15, 180, 80);
		--_text.text = "这里是体力值瓶，被敌方击中后，体力值会减少，当体力值为0时，战斗失败或原地等待队友帮你复活";
		--_text:DoAutoSize();
		--_text.background = "";
		--_guihelper.SetFontColor(_text, "#d58302");
		--_tip_cont:AddChild(_text);
		--
		--local Desktop = MyCompany.Aries.Desktop;
		--Desktop.GUIHelper.ArrowPointer.ShowArrow(7954, 2, "_lb", 12, -290, 64, 64);
		--
		--UIAnimManager.PlayCustomAnimation(2000, function(elapsedTime)
			--if(elapsedTime == 2000) then
				--ParaUI.Destroy("Combat_Tutorial_ShowHPMinusHint");
				--local Desktop = MyCompany.Aries.Desktop;
				--Desktop.GUIHelper.ArrowPointer.HideArrow(7954);
			--end
		--end);
	--end
end

local ShowVictoryHint_count = nil;

function MsgHandler.ShowVictoryHint()
	
	ShowVictoryHint_count = ShowVictoryHint_count or MyCompany.Aries.app:ReadConfig("ShowVictoryHint_count1", 0);
	if(ShowVictoryHint_count and type(ShowVictoryHint_count) == "number" and ShowVictoryHint_count >= 3) then
		return;
	end
	ShowVictoryHint_count = ShowVictoryHint_count + 1;
	MyCompany.Aries.app:WriteConfig("ShowVictoryHint_count1", ShowVictoryHint_count);
	
	local text_color = "#d58302";
	local background_tex = "Texture/Aries/Quest/Dialog_BG_32bits.png: 31 31 31 31";
	if(System.options.version == "teen") then
		text_color = pe_css.GetDefault("highbluecolor").color;
		background_tex = pe_css.GetDefault("block").background;
	end

	local _tip_cont = ParaUI.GetUIObject("Combat_Tutorial_ShowHPMinusHint");
	if(_tip_cont:IsValid() == false) then
		_tip_cont = ParaUI.CreateUIObject("container", "Combat_Tutorial_ShowHPMinusHint", "_lb", 20, -220, 200, 90);
		_tip_cont.background = background_tex;
		_tip_cont.enabled = false;
		_tip_cont.zorder = 3;
		_tip_cont:AttachToRoot();
		local _text = ParaUI.CreateUIObject("text", "text", "_lt", 15, 15, 180, 80);
		_text.text = "战斗胜利可以获得经验值，经验瓶满时，战斗等级会提升。";
		_text:DoAutoSize();
		_text.background = "";
		_guihelper.SetFontColor(_text, text_color);
		_tip_cont:AddChild(_text);
		
		local Desktop = MyCompany.Aries.Desktop;
		Desktop.GUIHelper.ArrowPointer.ShowArrow(7955, 2, "_lb", 60, -120, 64, 64);

		UIAnimManager.PlayCustomAnimation(5000, function(elapsedTime)
			if(elapsedTime == 5000) then
				ParaUI.Destroy("Combat_Tutorial_ShowHPMinusHint");
				local Desktop = MyCompany.Aries.Desktop;
				Desktop.GUIHelper.ArrowPointer.HideArrow(7955);
			end
		end);
	end
end

local ShowDefeatedHint_count = nil;

-- obsoleted use BasicArena.ShowHealthRecoverHint instead
function MsgHandler.ShowHealthRecoverHint()
	--[[
	ShowDefeatedHint_count = ShowDefeatedHint_count or MyCompany.Aries.app:ReadConfig("ShowDefeatedHint_count1", 0);
	if(ShowDefeatedHint_count and type(ShowDefeatedHint_count) == "number" and ShowDefeatedHint_count >= 3) then
		return;
	end
	ShowDefeatedHint_count = ShowDefeatedHint_count + 1;
	MyCompany.Aries.app:WriteConfig("ShowDefeatedHint_count1", ShowDefeatedHint_count);

	local _tip_cont = ParaUI.GetUIObject("Combat_Tutorial_ShowHPMinusHint");
	if(_tip_cont:IsValid() == false) then
		_tip_cont = ParaUI.CreateUIObject("container", "Combat_Tutorial_ShowHPMinusHint", "_lb", 20, -400, 240, 100);
		_tip_cont.background = "Texture/Aries/Quest/Dialog_BG_32bits.png: 31 31 31 31";
		_tip_cont.enabled = false;
		_tip_cont:AttachToRoot();
		local _text = ParaUI.CreateUIObject("text", "text", "_lt", 15, 15, 220, 80);
		_text.text = "HP为0且战斗失败时，将会自动被送回小镇的安全区域\n在战斗区域寻找红血球或者在小镇广场原地休息都可以恢复";
		_text:DoAutoSize();
		_text.background = "";
		_guihelper.SetFontColor(_text, "#d58302");
		_tip_cont:AddChild(_text);
		
		local Desktop = MyCompany.Aries.Desktop;
		Desktop.GUIHelper.ArrowPointer.ShowArrow(7956, 2, "_lb", 10, -290, 64, 64);

		UIAnimManager.PlayCustomAnimation(5000, function(elapsedTime)
			if(elapsedTime == 5000) then
				ParaUI.Destroy("Combat_Tutorial_ShowHPMinusHint");
				local Desktop = MyCompany.Aries.Desktop;
				Desktop.GUIHelper.ArrowPointer.HideArrow(7956);
			end
		end);
	end]]
end

-- show hp slots
function MsgHandler.ShowHPSlots()
-- NOTE 2011/3/2: check MsgHandler.GetMyArenaData() before lower and upper slots show
-- if user is logged in from an offline status which leaves a dummy offlined player in previous arena
-- the first realtime message may arrives before the first normal update message which will refresh myarena data
-- we then sacrifice the first PickCard or other messages which my arena data is nil before the first arena update
-- in this case the slots fields are empty on first message, normal updates will refresh myarena data,
-- following MsgHandler.ShowHPSlots() invokes will come with a valid myarena data
	if(MsgHandler.GetMyArenaData()) then
		local _this = ParaUI.GetUIObject("Aries_Combat_HP_Slot_Upper");
		if(_this:IsValid() == false) then
			_this = ParaUI.CreateUIObject("container", "Aries_Combat_HP_Slot_Upper", "_mt", 0, 0, 0, 160);
			--_this.background = "texture/alphadot.png";
			_this.background = "";
			_this.zorder = 3;
			_this:GetAttributeObject():SetField("ClickThrough", true);
			_this:AttachToRoot();
		
			local upper_url = "script/apps/Aries/Combat/UI/HP_Slots_Upper.html";
			if(System.options.version == "kids") then
				upper_url = "script/apps/Aries/Combat/UI/HP_Slots_Upper.html";
			else
				upper_url = "script/apps/Aries/Combat/UI/HP_Slots_Upper_teen.html";
			end
			MsgHandler.HP_slot_upper_page = System.mcml.PageCtrl:new({url = upper_url, click_through = true});
			MsgHandler.HP_slot_upper_page:Create("Debug_HP_Slots_Upper", _this, "_fi", 0, 0, 0, 0);
		else
			-- refresh the hp slot upper page control
			MsgHandler.RefreshUpperPage();
		end
		_this.visible = true;

		local _this = ParaUI.GetUIObject("Aries_Combat_HP_Slot_Lower");
		if(_this:IsValid() == false) then
			_this = ParaUI.CreateUIObject("container", "Aries_Combat_HP_Slot_Lower", "_mb", 0, 0, 0, 340);
			--_this.background = "texture/alphadot.png";
			_this.background = "";
			_this.zorder = 3;
			_this:GetAttributeObject():SetField("ClickThrough", true);
			_this:AttachToRoot();
		
			local lower_url = "script/apps/Aries/Combat/UI/HP_Slots_Lower.html";
			if(System.options.version == "kids") then
				lower_url = "script/apps/Aries/Combat/UI/HP_Slots_Lower.html";
			else
				lower_url = "script/apps/Aries/Combat/UI/HP_Slots_Lower_teen.html";
			end
			MsgHandler.HP_slot_lower_page = System.mcml.PageCtrl:new({url = lower_url, click_through = true});
			MsgHandler.HP_slot_lower_page:Create("Debug_HP_Slots_Lower", _this, "_fi", 0, 0, 0, 0);
		else
			-- refresh the hp slot lower page control
			MsgHandler.RefreshLowerPage();
		end
		_this.visible = true;
		
		if(System.options.version == "teen") then
			local _this = ParaUI.GetUIObject("Aries_Combat_EXP_bar");
			if(_this:IsValid() == false) then
				_this = ParaUI.CreateUIObject("container", "Aries_Combat_EXP_bar", "_mb", 0, -6, 0, 16);
				_this.background = "Texture/Aries/Combat/CombatStateTeen/EXP_bar_32bits.png";
				_this.enabled = false;
				_this.zorder = -100;
				_this:AttachToRoot();
			end
			_this.visible = true;
		end
	end
end

-- true to debug (reload) page on each turn so that one can program the user interface. 
local debug_page = commonlib.getfield("System.options.isAB_SDK");

-- refresh the hp slot upper page control
function MsgHandler.RefreshUpperPage()
	if(MsgHandler.HP_slot_upper_page) then
		if(debug_page) then
			MsgHandler.HP_slot_upper_page:Init(MsgHandler.HP_slot_upper_page.url);
		else
			MsgHandler.HP_slot_upper_page:Refresh(0);
		end
	end
end

-- refresh the hp slot lower page control
function MsgHandler.RefreshLowerPage()
	if(MsgHandler.HP_slot_lower_page) then
		if(debug_page) then
			MsgHandler.HP_slot_lower_page:Init(MsgHandler.HP_slot_lower_page.url);
		else
			MsgHandler.HP_slot_lower_page:Refresh(0);
		end
	end
end

-- refresh hp slots
function MsgHandler.RefreshHPSlots()
	MsgHandler.RefreshUpperPage()
	MsgHandler.RefreshLowerPage()
end
-- hide hp slots
function MsgHandler.HideHPSlots()
	local _this = ParaUI.GetUIObject("Aries_Combat_HP_Slot_Upper");
	if(_this:IsValid() == true) then
		_this.visible = false;
	end
	local _this = ParaUI.GetUIObject("Aries_Combat_HP_Slot_Lower");
	if(_this:IsValid() == true) then
		_this.visible = false;
	end
	if(System.options.version == "teen") then
		local _this = ParaUI.GetUIObject("Aries_Combat_EXP_bar");
		if(_this:IsValid() == true) then
			_this.visible = false;
		end
	end
end

-- play entrance count down
function MsgHandler.PlayEntranceCountDown(value)
	local nRemainingTime = tonumber(value);
	if(nRemainingTime) then
		--MsgHandler.OnUpdateCountDown(nRemainingTime, MsgHandler.OnInstanceEntranceLockOpen());
		MsgHandler.OnUpdateCountDown(nRemainingTime);
	end
end

function MsgHandler.OnInstanceEntranceLockOpen()
	local npcModel = NPC.GetNpcModelFromIDAndInstance(379856, 1);
	if(npcModel and npcModel:IsValid() == true) then
		--npcModel:SetPosition(0, 0, 0);
		npcModel:EnablePhysics(false);
	end
	local npcModel = NPC.GetNpcModelFromIDAndInstance(379856, 2);
	if(npcModel and npcModel:IsValid() == true) then
		--npcModel:SetPosition(0, 0, 0);
		npcModel:EnablePhysics(false);
	end
end

local cards_xml_parse_result = nil;

function MsgHandler.ShowCardPicker_menu()
	
	local ctl = CommonCtrl.GetControl("Aries_CardPicker_menu");
	if(ctl == nil)then
		ctl = CommonCtrl.ContextMenu:new{
			name = "Aries_CardPicker_menu",
			width = 170,
			subMenuWidth = 300,
			height = 285, -- add 30(menuitemHeight) for each new line. 
		};
		
		local node = ctl.RootNode;
		local subNode;
		-- name node: for displaying name of the selected object. Click to display property
		node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new{Text = "技能卡片", Name = "name", Type="Title", NodeHeight = 26 });
		node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new{Text = "----------------------", Name = "titleseparator", Type="separator", NodeHeight = 4 });
		-- for character
		node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new{Text = "Quickwords", Name = "actions", Type = "Group", NodeHeight = 0 });
			subNode = node:AddChild(CommonCtrl.TreeNode:new{Text = "先选择卡片(misc)", Name = "looped", Type = "Menuitem"});	
				subNode:AddChild(CommonCtrl.TreeNode:new({Text = "Pass", Name = "Dance1", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				subNode:AddChild(CommonCtrl.TreeNode:new({Text = "CancelCard", Name = "Dance1", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
			--subNode = node:AddChild(CommonCtrl.TreeNode:new{Text = "先选择卡片(金)", Name = "looped", Type = "Menuitem"});	
				--subNode:AddChild(CommonCtrl.TreeNode:new({Text = "PowerEnhanceBlade_Metal", Name = "2", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				--subNode:AddChild(CommonCtrl.TreeNode:new({Text = "SingleAttack_Level1_Metal", Name = "3", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				--subNode:AddChild(CommonCtrl.TreeNode:new({Text = "SingleAttack_Level2_Metal", Name = "3", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				--subNode:AddChild(CommonCtrl.TreeNode:new({Text = "SingleAttack_Level3_Metal", Name = "3", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				--subNode:AddChild(CommonCtrl.TreeNode:new({Text = "Ward_WaterDamageTrap_Level1_Metal", Name = "3", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				--subNode:AddChild(CommonCtrl.TreeNode:new({Text = "Charm_BoostAccuracy_Metal", Name = "3", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				--subNode:AddChild(CommonCtrl.TreeNode:new({Text = "SingleAttack_Level4_Metal", Name = "3", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
			--subNode = node:AddChild(CommonCtrl.TreeNode:new{Text = "先选择卡片(木)", Name = "looped", Type = "Menuitem"});	
				--subNode:AddChild(CommonCtrl.TreeNode:new({Text = "PowerEnhanceBlade_Wood", Name = "2", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				--subNode:AddChild(CommonCtrl.TreeNode:new({Text = "AreaAttack_Level1_Wood", Name = "4", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				--subNode:AddChild(CommonCtrl.TreeNode:new({Text = "AreaAttack_Level2_Wood", Name = "4", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				--subNode:AddChild(CommonCtrl.TreeNode:new({Text = "AreaAttack_Level3_Wood", Name = "4", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				--subNode:AddChild(CommonCtrl.TreeNode:new({Text = "Charm_AreaGlobalDamageWeakness_Level1_Wood", Name = "4", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				--subNode:AddChild(CommonCtrl.TreeNode:new({Text = "Charm_FocusPrism_Wood", Name = "4", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				--subNode:AddChild(CommonCtrl.TreeNode:new({Text = "Charm_DamageWeakness_Level2_Wood", Name = "4", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
			--subNode = node:AddChild(CommonCtrl.TreeNode:new{Text = "先选择卡片(水)", Name = "looped", Type = "Menuitem"});	
				--subNode:AddChild(CommonCtrl.TreeNode:new({Text = "PowerEnhanceBlade_Water", Name = "2", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				--subNode:AddChild(CommonCtrl.TreeNode:new({Text = "SingleAttack_Level1_Water", Name = "3", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				--subNode:AddChild(CommonCtrl.TreeNode:new({Text = "SingleHeal_Level1_Water", Name = "4", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				--subNode:AddChild(CommonCtrl.TreeNode:new({Text = "SingleHeal_Level2_Water", Name = "4", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				--subNode:AddChild(CommonCtrl.TreeNode:new({Text = "SingleAttackWithLifeTap_Level2_Water", Name = "4", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				--subNode:AddChild(CommonCtrl.TreeNode:new({Text = "Revive_Level1_Water", Name = "4", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				--subNode:AddChild(CommonCtrl.TreeNode:new({Text = "SingleAttackWithDOT_Level4_Water", Name = "4", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
			--subNode = node:AddChild(CommonCtrl.TreeNode:new{Text = "先选择卡片(火)", Name = "looped", Type = "Menuitem"});	
				--subNode:AddChild(CommonCtrl.TreeNode:new({Text = "PowerEnhanceBlade_Fire", Name = "2", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				--subNode:AddChild(CommonCtrl.TreeNode:new({Text = "SingleAttackWithDOT_Level1_Fire", Name = "4", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				--subNode:AddChild(CommonCtrl.TreeNode:new({Text = "SingleAttackWithDOT_Level2_Fire", Name = "4", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				--subNode:AddChild(CommonCtrl.TreeNode:new({Text = "SingleAttackWithDOT_Level3_Fire", Name = "4", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				--subNode:AddChild(CommonCtrl.TreeNode:new({Text = "Ward_EarthDamageTrap_Level1_Fire", Name = "4", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				--subNode:AddChild(CommonCtrl.TreeNode:new({Text = "SingleAttackWithImmolate_Level4_Fire", Name = "4", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				--subNode:AddChild(CommonCtrl.TreeNode:new({Text = "StealCharm_Level1_Fire", Name = "4", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
			--subNode = node:AddChild(CommonCtrl.TreeNode:new{Text = "先选择卡片(土)", Name = "looped", Type = "Menuitem"});	
				--subNode:AddChild(CommonCtrl.TreeNode:new({Text = "PowerEnhanceBlade_Earth", Name = "2", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				--subNode:AddChild(CommonCtrl.TreeNode:new({Text = "SingleAttack_Level1_Earth", Name = "3", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				--subNode:AddChild(CommonCtrl.TreeNode:new({Text = "DamageShieldAndThorn_Level1_Earth", Name = "4", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				--subNode:AddChild(CommonCtrl.TreeNode:new({Text = "DamageShieldAndThorn_Level2_Earth", Name = "4", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				--subNode:AddChild(CommonCtrl.TreeNode:new({Text = "SingleAttack_Level2_Earth", Name = "4", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				--subNode:AddChild(CommonCtrl.TreeNode:new({Text = "Ward_GlobalShield_Level1_Earth", Name = "4", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				--subNode:AddChild(CommonCtrl.TreeNode:new({Text = "SingleAttack_Level3_Earth", Name = "4", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				
			subNode = node:AddChild(CommonCtrl.TreeNode:new{Text = "先选择卡片(火)", Name = "fire", Type = "Menuitem"});
				subNode:AddChild(CommonCtrl.TreeNode:new({Text = "PowerEnhanceBlade_Earth", Name = "2", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
			subNode = node:AddChild(CommonCtrl.TreeNode:new{Text = "先选择卡片(冰)", Name = "ice", Type = "Menuitem"});
			subNode = node:AddChild(CommonCtrl.TreeNode:new{Text = "先选择卡片(风暴)", Name = "storm", Type = "Menuitem"});
			subNode = node:AddChild(CommonCtrl.TreeNode:new{Text = "先选择卡片(生命)", Name = "life", Type = "Menuitem"});
			subNode = node:AddChild(CommonCtrl.TreeNode:new{Text = "先选择卡片(死亡)", Name = "death", Type = "Menuitem"});
			subNode = node:AddChild(CommonCtrl.TreeNode:new{Text = "先选择卡片(平衡)", Name = "balance", Type = "Menuitem"});
			subNode = node:AddChild(CommonCtrl.TreeNode:new{Text = "再选择目标", Name = "target", Type = "Menuitem"});	
				subNode:AddChild(CommonCtrl.TreeNode:new({Text = "self", Name = "Dance1", Type = "Menuitem", onclick = MsgHandler.OnPickOneCard, }));
				subNode:AddChild(CommonCtrl.TreeNode:new({Text = "-1", Name = "Dance1", Type = "Menuitem", onclick = MsgHandler.OnPickOneCard, }));
				subNode:AddChild(CommonCtrl.TreeNode:new({Text = "50001", Name = "Dance1", Type = "Menuitem", onclick = MsgHandler.OnPickOneCard, }));
				subNode:AddChild(CommonCtrl.TreeNode:new({Text = "50002", Name = "Dance1", Type = "Menuitem", onclick = MsgHandler.OnPickOneCard, }));
				subNode:AddChild(CommonCtrl.TreeNode:new({Text = "50003", Name = "Dance1", Type = "Menuitem", onclick = MsgHandler.OnPickOneCard, }));
				subNode:AddChild(CommonCtrl.TreeNode:new({Text = "50004", Name = "Dance1", Type = "Menuitem", onclick = MsgHandler.OnPickOneCard, }));
				subNode:AddChild(CommonCtrl.TreeNode:new({Text = "50005", Name = "Dance1", Type = "Menuitem", onclick = MsgHandler.OnPickOneCard, }));
				subNode:AddChild(CommonCtrl.TreeNode:new({Text = "50006", Name = "Dance1", Type = "Menuitem", onclick = MsgHandler.OnPickOneCard, }));
				subNode:AddChild(CommonCtrl.TreeNode:new({Text = "50007", Name = "Dance1", Type = "Menuitem", onclick = MsgHandler.OnPickOneCard, }));
				subNode:AddChild(CommonCtrl.TreeNode:new({Text = "50008", Name = "Dance1", Type = "Menuitem", onclick = MsgHandler.OnPickOneCard, }));
				subNode:AddChild(CommonCtrl.TreeNode:new({Text = "50009", Name = "Dance1", Type = "Menuitem", onclick = MsgHandler.OnPickOneCard, }));
				subNode:AddChild(CommonCtrl.TreeNode:new({Text = "50010", Name = "Dance1", Type = "Menuitem", onclick = MsgHandler.OnPickOneCard, }));
				subNode:AddChild(CommonCtrl.TreeNode:new({Text = "50011", Name = "Dance1", Type = "Menuitem", onclick = MsgHandler.OnPickOneCard, }));
				subNode:AddChild(CommonCtrl.TreeNode:new({Text = "50012", Name = "Dance1", Type = "Menuitem", onclick = MsgHandler.OnPickOneCard, }));
				subNode:AddChild(CommonCtrl.TreeNode:new({Text = "50013", Name = "Dance1", Type = "Menuitem", onclick = MsgHandler.OnPickOneCard, }));
				subNode:AddChild(CommonCtrl.TreeNode:new({Text = "50014", Name = "Dance1", Type = "Menuitem", onclick = MsgHandler.OnPickOneCard, }));
	end

	local targetGroup = ctl.RootNode:GetChildByName("actions"):GetChildByName("target");
	targetGroup:ClearAllChildren();
	targetGroup:AddChild(CommonCtrl.TreeNode:new({Text = "self", Name = "self", Type = "Menuitem", onclick = MsgHandler.OnPickOneCard, }));
	
	local id, _;
	for id, _ in pairs(MsgHandler.CardPickerFriendlyList) do
		local userinfo = ProfileManager.GetUserInfoInMemory(id);
		local name = "unknown";
		if(userinfo) then
			name = userinfo.nickname;
		end
		targetGroup:AddChild(CommonCtrl.TreeNode:new({Text = "Friendly:__"..name.."__"..id.."", Name = id.."", Type = "Menuitem", onclick = MsgHandler.OnPickOneCard, }));
	end
	local id, _;
	for id, _ in pairs(MsgHandler.CardPickerHostileList) do
		local userinfo = ProfileManager.GetUserInfoInMemory(id);
		local name = "unknown";
		if(userinfo) then
			name = userinfo.nickname;
		end
		targetGroup:AddChild(CommonCtrl.TreeNode:new({Text = "Hostile:__"..name.."__"..id.."", Name = id.."", Type = "Menuitem", onclick = MsgHandler.OnPickOneCard, }));
	end
	
	if(not cards_xml_parse_result) then
		local xmlRoot;
		if(System.options.version == "teen") then
			xmlRoot = ParaXML.LuaXML_ParseFile("config/Aries/Cards/CardList.teen.xml");
		else
			xmlRoot = ParaXML.LuaXML_ParseFile("config/Aries/Cards/CardList.xml");
		end
		cards_xml_parse_result = xmlRoot;
	end
	
	if(cards_xml_parse_result) then
		local spellGroup = ctl.RootNode:GetChildByName("actions"):GetChildByName("fire");
		spellGroup:ClearAllChildren();
		local each_card;
		for each_card in commonlib.XPath.eachNode(cards_xml_parse_result, "/cardlist/card") do
			local datafile = each_card.attr.datafile;
			local spell_name = string.match(datafile, [[^.+/(.+).xml$]]);
			if(not (string.find(spell_name, "_Green") or string.find(spell_name, "_Blue") or string.find(spell_name, "_Purple") or string.find(spell_name, "_Orange"))) then
				if(spell_name and string.find(spell_name, "Fire_") == 1 and not string.find(spell_name, "_SingleAttack_Level0_") and not string.find(spell_name, "_VIP")) then
					spellGroup:AddChild(CommonCtrl.TreeNode:new({Text = spell_name, Name = "2", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				end
			end
		end
		spellGroup:AddChild(CommonCtrl.TreeNode:new({Text = "Fire_SingleAttack_Level0_120_adv", Name = "2", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
		
		local spellGroup = ctl.RootNode:GetChildByName("actions"):GetChildByName("ice");
		spellGroup:ClearAllChildren();
		local each_card;
		for each_card in commonlib.XPath.eachNode(cards_xml_parse_result, "/cardlist/card") do
			local datafile = each_card.attr.datafile;
			local spell_name = string.match(datafile, [[^.+/(.+).xml$]]);
			if(not (string.find(spell_name, "_Green") or string.find(spell_name, "_Blue") or string.find(spell_name, "_Purple") or string.find(spell_name, "_Orange"))) then
				if(spell_name and string.find(spell_name, "Ice_") == 1 and not string.find(spell_name, "_SingleAttack_Level0_") and not string.find(spell_name, "_VIP")) then
					spellGroup:AddChild(CommonCtrl.TreeNode:new({Text = spell_name, Name = "2", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				end
			end
		end
		spellGroup:AddChild(CommonCtrl.TreeNode:new({Text = "Ice_SingleAttack_Level0_120_adv", Name = "2", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));

		local spellGroup = ctl.RootNode:GetChildByName("actions"):GetChildByName("storm");
		spellGroup:ClearAllChildren();
		local each_card;
		for each_card in commonlib.XPath.eachNode(cards_xml_parse_result, "/cardlist/card") do
			local datafile = each_card.attr.datafile;
			local spell_name = string.match(datafile, [[^.+/(.+).xml$]]);
			if(not (string.find(spell_name, "_Green") or string.find(spell_name, "_Blue") or string.find(spell_name, "_Purple") or string.find(spell_name, "_Orange"))) then
				if(spell_name and string.find(spell_name, "Storm_") == 1 and not string.find(spell_name, "_SingleAttack_Level0_") and not string.find(spell_name, "_VIP")) then
					spellGroup:AddChild(CommonCtrl.TreeNode:new({Text = spell_name, Name = "2", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				end
			end
		end
		spellGroup:AddChild(CommonCtrl.TreeNode:new({Text = "Storm_SingleAttack_Level0_120_adv", Name = "2", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));

		local spellGroup = ctl.RootNode:GetChildByName("actions"):GetChildByName("life");
		spellGroup:ClearAllChildren();
		local each_card;
		for each_card in commonlib.XPath.eachNode(cards_xml_parse_result, "/cardlist/card") do
			local datafile = each_card.attr.datafile;
			local spell_name = string.match(datafile, [[^.+/(.+).xml$]]);
			if(not (string.find(spell_name, "_Green") or string.find(spell_name, "_Blue") or string.find(spell_name, "_Purple") or string.find(spell_name, "_Orange"))) then
				if(spell_name and string.find(spell_name, "Life_") == 1 and not string.find(spell_name, "_SingleAttack_Level0_") and not string.find(spell_name, "_VIP")) then
					spellGroup:AddChild(CommonCtrl.TreeNode:new({Text = spell_name, Name = "2", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				end
			end
		end
		spellGroup:AddChild(CommonCtrl.TreeNode:new({Text = "Life_SingleAttack_Level0_120_adv", Name = "2", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));

		local spellGroup = ctl.RootNode:GetChildByName("actions"):GetChildByName("death");
		spellGroup:ClearAllChildren();
		local each_card;
		for each_card in commonlib.XPath.eachNode(cards_xml_parse_result, "/cardlist/card") do
			local datafile = each_card.attr.datafile;
			local spell_name = string.match(datafile, [[^.+/(.+).xml$]]);
			if(not (string.find(spell_name, "_Green") or string.find(spell_name, "_Blue") or string.find(spell_name, "_Purple") or string.find(spell_name, "_Orange"))) then
				if(spell_name and string.find(spell_name, "Death_") == 1 and not string.find(spell_name, "_SingleAttack_Level0_") and not string.find(spell_name, "_VIP")) then
					spellGroup:AddChild(CommonCtrl.TreeNode:new({Text = spell_name, Name = "2", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				end
			end
		end
		spellGroup:AddChild(CommonCtrl.TreeNode:new({Text = "Death_SingleAttack_Level0_120_adv", Name = "2", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
		
		local spellGroup = ctl.RootNode:GetChildByName("actions"):GetChildByName("balance");
		spellGroup:ClearAllChildren();
		local each_card;
		for each_card in commonlib.XPath.eachNode(cards_xml_parse_result, "/cardlist/card") do
			local datafile = each_card.attr.datafile;
			local spell_name = string.match(datafile, [[^.+/(.+).xml$]]);
			if(not (string.find(spell_name, "_Green") or string.find(spell_name, "_Blue") or string.find(spell_name, "_Purple") or string.find(spell_name, "_Orange"))) then
				if(spell_name and string.find(spell_name, "Balance_") == 1 and not string.find(spell_name, "_SingleAttack_Level0_") and not string.find(spell_name, "_VIP")) then
					spellGroup:AddChild(CommonCtrl.TreeNode:new({Text = spell_name, Name = "2", Type = "Menuitem", onclick = MsgHandler.OnPickCardType, }));
				end
			end
		end
	end
	
	local x, y, width, height = ParaUI.GetUIObject("Aries_CardPicker"):GetAbsPosition();
	ctl:Show(x-11, y+40);
end

local card = "Pass";

function MsgHandler.OnPickCardType(node)
	card = node.Text;

	if(node.Text == "CancelCard") then
		MsgHandler.OnCancelPickCardByPlayer();
	end
end

function MsgHandler.OnPickOneCard(node)
	-- first hide all card picker
	MsgHandler.HideCardPicker();
	---- clear count down timer
	--MsgHandler.OnUpdateCountDown(0);
	
	--_guihelper.MessageBox(node.Text)

	if(node.Text == "self") then
		MsgHandler.OnPickCard(card, 0, false, 0); -- 0 stands for self
	else
		local npc_id = tonumber(node.Name);
		if(npc_id < 59000 and npc_id > 50000) then
			MsgHandler.OnPickCard(card, 0, true, npc_id);
		else
			MsgHandler.OnPickCard(card, 0, false, npc_id);
		end
	end

	-- hide the my runes page
	MsgHandler.HideMyRunesPage();

	-- default pass
	card = "Pass";
end

-- pick card
-- @param callback_after_card_pick: callback function after the card is picked, mainly for combat tutorial purpose
function MsgHandler.OnShowPick(seq, mode, nRoundTag, remaining_deck_count, total_deck_count, remaing_switching_followpet_count, bMyFollowPetCombatMode, friendlylist, hostilelist, cards_at_hand_str, isdead, runes_at_hand_str, followpetcards_at_hand_str, followpet_history_str, callback_after_card_pick, callback_after_pass, callback_after_card_click)
	MsgHandler.ShowCardPicker(seq, mode, nRoundTag, remaining_deck_count, total_deck_count, remaing_switching_followpet_count, bMyFollowPetCombatMode, friendlylist, hostilelist, cards_at_hand_str, isdead, runes_at_hand_str, followpetcards_at_hand_str, followpet_history_str, callback_after_card_pick, callback_after_pass, callback_after_card_click);
	MsgHandler.ShowHPSlots();
end

function MsgHandler.OnShowIdle(word, mode, nRoundTag)
	MsgHandler.ShowIdleCardPicker(word, mode, nRoundTag);
	if(word == "等待对方选牌") then
		MsgHandler.ShowHPSlots();
	end
end

-- update count down timer
function MsgHandler.OnUpdateCountDown(nRemainingTime, count_to_zero_callback)
	MyCompany.Aries.Combat.BattleComment.UpdateCountDownTimer(nRemainingTime, count_to_zero_callback);
end

function MsgHandler.OnHasPickedThisPet_before()
	BroadcastHelper.PushLabel({id="HasPickedThisPet_before_tip", label = "这个宠物已经出战过了，请选一个其他宠物", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
end

------------------------------ turn playing ------------------------------

MsgHandler.bMyArenaPlayingTurns = false;
MsgHandler.callback_after_playturn = nil;

function MsgHandler.IsMyArenaPlayingTurns()
	return MsgHandler.bMyArenaPlayingTurns;
end

-- play current turn
-- @param callback_after_playturn: callback function after play turn , mainly for combat tutorial purpose
function MsgHandler.OnPlayTurn(value, callback_after_playturn)
	Cursor.LockCursor("default");
	-- NOTE: ONLY combat tutorial has such callback function, assuming only one arena is playing
	MsgHandler.callback_after_playturn = callback_after_playturn;
	
	--_guihelper.MessageBox("OnPlayTurn:"..value);

	
	local seq, active_player_nids, inactive_player_nids, autocombat_player_nids, playturn_value = string_match(value, "^([^%?]+)%?([^%?]+)%?([^%?]*)%?([^%?]*)%?<(.*)>$");
	if(not seq or not active_player_nids or not inactive_player_nids or not autocombat_player_nids or not playturn_value) then
		-- invalid play turn value
		return;
	end

	seq = tonumber(seq);

	local bIncludedInBattle = false;
	-- search active player
	local cur_player_nid = ProfileManager.GetNID();
	local active_player_nids_table = {};
	local each_nid;
	for each_nid in string.gmatch(active_player_nids, "([^,]+)") do
		each_nid = tonumber(each_nid) or each_nid;
		if(each_nid) then
			active_player_nids_table[each_nid] = true;
		end
		if(cur_player_nid == each_nid) then
			-- play the spell play with camera animation
			bIncludedInBattle = true;
			break;
		else
			-- skip play turn if player 
			--local player = ParaScene_GetObject(tostring(each_nid));
			--if(player:IsValid()) then
				--local dist = player:DistanceToPlayerSq();
				--if(dist > cancel_spellplay_distance_sq) then
					---- if user in too far away from the combat the spell play is cancelled
					--return;
				--end
			--else
				-- player is offlined
				-- TODO:
			--end
		end
	end
	
	local inactive_player_nids_table = {};
	-- search inactive player
	if(not bIncludedInBattle) then
		local each_nid;
		for each_nid in string.gmatch(inactive_player_nids, "([^,]+)") do
			each_nid = tonumber(each_nid) or each_nid;
			if(each_nid) then
				inactive_player_nids_table[each_nid] = true;
			end
			if(cur_player_nid == each_nid) then
				-- play the spell play with camera animation
				bIncludedInBattle = true;
				break;
			else
				-- skip play turn if player 
				local player = ParaScene_GetObject(tostring(each_nid));
				if(player:IsValid()) then
					local dist = player:DistanceToPlayerSq();
					if(dist > cancel_spellplay_distance_sq) then
						-- if user in too far away from the combat the spell play is cancelled
						return;
					end
				else
					-- player is offlined
					-- TODO:
				end
			end
		end
	end
	
	local active_autocombat_nids_table = {};
	local each_autocombat_nid;
	for each_autocombat_nid in string.gmatch(autocombat_player_nids, "([^,]+)") do
		each_autocombat_nid = tonumber(each_autocombat_nid) or each_autocombat_nid;
		if(each_autocombat_nid) then
			active_autocombat_nids_table[each_autocombat_nid] = true;
		end
	end

	local each_active_player_nid, _;
	for each_active_player_nid, _ in pairs(active_player_nids_table) do
		if(active_autocombat_nids_table[each_active_player_nid]) then
			Headon_OPC.ChangeHeadonMark(each_active_player_nid, "autocombat");
		else
			Headon_OPC.ChangeHeadonMark(each_active_player_nid, "");
		end
	end
	local each_inactive_player_nid, _;
	for each_inactive_player_nid, _ in pairs(inactive_player_nids_table) do
		Headon_OPC.ChangeHeadonMark(each_inactive_player_nid, "");
	end
	
	local bSkipCamera = true;
	-- player is included in battle
	if(bIncludedInBattle == true) then
		
		-- close flee messagebox
		_guihelper.CloseMessageBox();
		
		-- skip camera play
		bSkipCamera = false;
		-- TODO: hide all card pick ui, including the upper and lower hp slots, my card picker and target trace

		if(bUseDefaultCamera == false) then
			bSkipCamera = true;
		end

		-- hide the my runes page
		MsgHandler.HideMyRunesPage();
		
		-- first hide all card picker
		MsgHandler.HideCardPicker();
		-- hide target picker
		MsgHandler.HideTargetPicker();
		-- first hide all hp slots
		if(not bShowHPSlotsDuringSpellPlay) then
			MsgHandler.HideHPSlots();
		end
		-- clear count down timer
		MsgHandler.OnUpdateCountDown(0)
		
		-- reset picked cards
		MsgHandler.MyArenaPickedCards = {};
	end
	
	local ObjectManager = ObjectManager;
	-- collect all spells
	local all_spells = {};
	local current_card_spell = 0;
	local bNextSpellIsFromPetCard = false;
	local each_spell;
	for each_spell in string.gmatch(playturn_value, "<([^>]*)>") do
		local key, value = string_match(each_spell, "^([^:]*):(.*)$");
		if(key and value) then
			if(key == "dead" or key == "speak_dead") then
				-- put dead spell play in the previous spell
				local current_spell = all_spells[current_card_spell];
				if(current_spell and current_spell.dead_spells) then
					table.insert(current_spell.dead_spells, {
						key = key,
						value = value,
					});
				end
			elseif(key == "next_spell_is_from_petcard") then
				bNextSpellIsFromPetCard = true;
			else
				-- normal spells
				local spell_struct = {
					key = key,
					value = value,
					dead_spells = {},
				};
				if(key ~= "update_value" and key ~= "update_arena" and key ~= "movearrow") then
					current_card_spell = #all_spells + 1;
					spell_struct.IsFromPetCard = bNextSpellIsFromPetCard;
					bNextSpellIsFromPetCard = false;
				end
				table_insert(all_spells, spell_struct);
			end
		end
	end

	-- play dead spell if object match
	local function TryPlayDeadSpellForObject(obj_name, delta_hp, dead_spells, playspell_func)
		if(dead_spells) then
			local _, each_dead_spell;
			for _, each_dead_spell in pairs(dead_spells) do
				if(each_dead_spell.key == "dead") then
					local params = {
						obj_name = obj_name,
						delta_hp = delta_hp,
					};
					-- true for bForceSkipThisSpellCamera
					playspell_func(each_dead_spell, function() end, true, params);
				elseif(each_dead_spell.key == "speak_dead") then
					local params = {
						obj_name = obj_name,
						delta_hp = delta_hp,
					};
					-- true for bForceSkipThisSpellCamera
					playspell_func(each_dead_spell, function() end, true, params);
				end
			end
		end
	end

	local last_applied_arena_update_key;
	local last_applied_arena_update_value;

	local function PlaySingleSpell(each_spell, finish_callback, bForceSkipThisSpellCamera, params)
		-- play the spell sequence
		local key = each_spell.key;
		local value = each_spell.value;
		if(key and value) then
			if(key == "fizzle") then
				-- TODO: spell fizzle
				local arena_id, arrow_position_id, caster_ismob, caster_id, caster_slotid, target_ismob, target_id, target_slotid, damage_school = 
					string_match(value, "^([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*)$");
				if(arena_id and arrow_position_id and caster_ismob and caster_id and caster_slotid and target_ismob and target_id and target_slotid and damage_school) then
					arena_id = tonumber(arena_id);
					local arena_meta = MsgHandler.Get_arena_meta_data_by_id(arena_id);
					if(arena_meta.is_sentient) then
						arrow_position_id = tonumber(arrow_position_id);
						caster_id = tonumber(caster_id) or caster_id;
						caster_slotid = tonumber(caster_slotid);
						target_id = tonumber(target_id) or target_id;
						target_slotid = tonumber(target_slotid);
						-- caster and target
						local caster;
						if(caster_ismob == "true") then
							caster = {isPlayer = false, npc_id = 39001, instance = caster_id, slotid = caster_slotid};
						elseif(caster_ismob == "false") then
							caster = {isPlayer = true, nid = caster_id, slotid = caster_slotid};
						end
						local target;
						if(target_ismob == "true") then
							target = {isPlayer = false, npc_id = 39001, instance = target_id, slotid = target_slotid};
						elseif(target_ismob == "false") then
							target = {isPlayer = true, nid = target_id, slotid = target_slotid};
						end
						-- play spell file
						local spell_file = "config/Aries/Spells/Fizzle_"..damage_school..".xml";
						if(System.options.version == "teen") then
							spell_file = "config/Aries/Spells/Fizzle_"..damage_school.."_teen.xml";
						end
						SpellPlayer.PlaySpellEffect_single(arena_id, caster, target, spell_file, {{0}}, nil, function()
							finish_callback();
						end, bSkipCamera or bForceSkipThisSpellCamera, bIncludedInBattle); -- bSkipCamera, bIncludedInBattle
					else
						-- play spell file
						local spell_file = "config/Aries/Spells/Fizzle_"..damage_school..".xml";
						if(System.options.version == "teen") then
							spell_file = "config/Aries/Spells/Fizzle_"..damage_school.."_teen.xml";
						end
						SpellPlayer.PlaySpellDuration(spell_file, function()
							finish_callback();
						end);
					end
				else
					finish_callback();
				end

			elseif(key == "use_petcard") then
				-- player use_petcard
				local arena_id, arrow_position_id, caster_ismob, caster_id, gsid = 
						string_match(value, "^([^,]*),([^,]*),([^,]*),([^,]*),([^,]*)$");
				if(arena_id and arrow_position_id and caster_ismob and caster_id and gsid) then
					arena_id = tonumber(arena_id);
					local arena_meta = MsgHandler.Get_arena_meta_data_by_id(arena_id);
					if(arena_meta.is_sentient) then
						arrow_position_id = tonumber(arrow_position_id);
						caster_id = tonumber(caster_id);
						gsid = tonumber(gsid);
						-- caster
						local caster;
						if(caster_ismob == "true") then
							caster = {isPlayer = false, npc_id = 39001, instance = caster_id, slotid = arrow_position_id};
						elseif(caster_ismob == "false") then
							caster = {isPlayer = true, nid = caster_id, slotid = arrow_position_id};
						end
						
						if(gsid and caster_ismob == "false") then
							local word = CombatPetHelper.GetPetTalk(gsid, "attack");
							if(type(word) == "string") then
								local followpet = Pet.GetUserFollowObj(caster_id);
								if(followpet and followpet:IsValid()) then
									local speak_word = "<span style='color:#093f4f'>"..word.."</span>";
									headon_speech.Speek(followpet.name, speak_word, 6, true, nil, true, nil, "#ffffffc0");
								end
							end
						end
					end
				end
				finish_callback();
				
			elseif(key == "next_spell_is_from_petcard") then
				-- directly pass next_spell_is_from_petcard turn
				finish_callback();

			elseif(key == "pickpet") then
				-- TODO: spell pickpet
				local arena_id, arrow_position_id, caster_ismob, caster_id, caster_slotid, target_ismob, target_id, target_slotid, damage_school, shout_follow_pet_gsid, pet_guid = 
					string_match(value, "^([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*)$");
				if(arena_id and arrow_position_id and caster_ismob and caster_id and caster_slotid and target_ismob and target_id and target_slotid and damage_school and shout_follow_pet_gsid and pet_guid) then
					arena_id = tonumber(arena_id);
					local arena_meta = MsgHandler.Get_arena_meta_data_by_id(arena_id);
					if(arena_meta.is_sentient) then
						arrow_position_id = tonumber(arrow_position_id);
						caster_id = tonumber(caster_id) or caster_id;
						caster_slotid = tonumber(caster_slotid);
						target_id = tonumber(target_id) or target_id;
						target_slotid = tonumber(target_slotid);
						pet_guid = tonumber(pet_guid);
						shout_follow_pet_gsid = tonumber(shout_follow_pet_gsid);
						-- switch follow pet
						local item = ItemManager.GetItemByGUID(pet_guid);
						if(caster_id == ProfileManager.GetNID() and item and item.guid > 0 and item.bag ~= 0 and item.GetCurLevelCards) then
							-- switch to new pet
							item:OnClick("left", nil, nil, true, function(msg)
								if(shout_follow_pet_gsid) then
									local word = CombatPetHelper.GetPetTalk(shout_follow_pet_gsid, "entercombat");
									if(type(word) == "string") then
										local followpet = Pet.GetUserFollowObj();
										if(followpet and followpet:IsValid()) then
											local speak_word = "<span style='color:#093f4f'>"..word.."</span>";
											headon_speech.Speek(followpet.name, speak_word, 6, true, nil, true, nil, "#ffffffc0");
										end
									end
								end
							end); -- true for bShowStatsDiff
						end
						-- caster and target
						local caster;
						if(caster_ismob == "true") then
							caster = {isPlayer = false, npc_id = 39001, instance = caster_id, slotid = caster_slotid};
						elseif(caster_ismob == "false") then
							caster = {isPlayer = true, nid = caster_id, slotid = caster_slotid};
						end
						local target;
						if(target_ismob == "true") then
							target = {isPlayer = false, npc_id = 39001, instance = target_id, slotid = target_slotid};
						elseif(target_ismob == "false") then
							target = {isPlayer = true, nid = target_id, slotid = target_slotid};
						end
						-- shout the follow pet name 
						if(shout_follow_pet_gsid) then
							local gsItem = ItemManager.GetGlobalStoreItemInMemory(shout_follow_pet_gsid)
							if(gsItem) then
								local spell_file = "config/Aries/Spells/Shout.xml";
								SpellPlayer.PlaySpellEffect_single(arena_id, caster, caster, spell_file, gsItem.template.name, nil, function()
								end, bSkipCamera or bForceSkipThisSpellCamera, bIncludedInBattle); -- bSkipCamera, bIncludedInBattle
							end
						end
						-- play spell file
						local spell_file = "config/Aries/Spells/Pickpet_"..damage_school..".xml";
						if(System.options.version == "teen") then
							spell_file = "config/Aries/Spells/Pickpet_"..damage_school.."_teen.xml";
						end
						SpellPlayer.PlaySpellEffect_single(arena_id, caster, target, spell_file, {{0}}, nil, function()
							finish_callback();
						end, bSkipCamera or bForceSkipThisSpellCamera, bIncludedInBattle); -- bSkipCamera, bIncludedInBattle
					else
						-- play spell file
						local spell_file = "config/Aries/Spells/Pickpet_"..damage_school..".xml";
						if(System.options.version == "teen") then
							spell_file = "config/Aries/Spells/Pickpet_"..damage_school.."_teen.xml";
						end
						SpellPlayer.PlaySpellDuration(spell_file, function()
							finish_callback();
						end);
					end
				else
					finish_callback();
				end
			elseif(key == "balance_catchpet_success" or key == "balance_catchpet_failed") then
				local spell_key = key;
				if(System.options.version == "teen") then
					spell_key = spell_key.."_teen";
				end
				-- TODO: spell pickpet
				local arena_id, arrow_position_id, caster_ismob, caster_id, caster_slotid, target_ismob, target_id, target_slotid, damage_school = 
					string_match(value, "^([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*)$");
				if(arena_id and arrow_position_id and caster_ismob and caster_id and caster_slotid and target_ismob and target_id and target_slotid and damage_school) then
					arena_id = tonumber(arena_id);
					local arena_meta = MsgHandler.Get_arena_meta_data_by_id(arena_id);
					if(arena_meta.is_sentient) then
						arrow_position_id = tonumber(arrow_position_id);
						caster_id = tonumber(caster_id) or caster_id;
						caster_slotid = tonumber(caster_slotid);
						target_id = tonumber(target_id) or target_id;
						target_slotid = tonumber(target_slotid);
						-- caster and target
						local caster;
						if(caster_ismob == "true") then
							caster = {isPlayer = false, npc_id = 39001, instance = caster_id, slotid = caster_slotid};
						elseif(caster_ismob == "false") then
							caster = {isPlayer = true, nid = caster_id, slotid = caster_slotid};
						end
						local target;
						if(target_ismob == "true") then
							target = {isPlayer = false, npc_id = 39001, instance = target_id, slotid = target_slotid};
						elseif(target_ismob == "false") then
							target = {isPlayer = true, nid = target_id, slotid = target_slotid};
						end
						-- play spell file
						local spell_file = "config/Aries/Spells/"..spell_key..".xml";
						SpellPlayer.PlaySpellEffect_single(arena_id, caster, target, spell_file, {{0}}, nil, function()
							finish_callback();
						end, bSkipCamera or bForceSkipThisSpellCamera, bIncludedInBattle); -- bSkipCamera, bIncludedInBattle

						if(caster_id == ProfileManager.GetNID() and key == "balance_catchpet_success") then
							-- send custom_goal_client event for quest goals
							MyCompany.Aries.event:DispatchEvent({type = "custom_goal_client"}, 79013);
						end
					else
						-- play spell file
						local spell_file = "config/Aries/Spells/"..spell_key..".xml";
						SpellPlayer.PlaySpellDuration(spell_file, function()
							finish_callback();
						end);
					end
				else
					finish_callback();
				end
				
			elseif(key == "balance_rune_enrage" or key == "Balance_Rune_Enrage_Level1" or key == "Balance_Rune_Enrage_Level1_teen") then
				local spell_key = key;
				-- TODO: spell pickpet
				local arena_id, arrow_position_id, caster_ismob, caster_id, caster_slotid, target_ismob, target_id, target_slotid, damage_school = 
					string_match(value, "^([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*)$");
				if(arena_id and arrow_position_id and caster_ismob and caster_id and caster_slotid and target_ismob and target_id and target_slotid and damage_school) then
					arena_id = tonumber(arena_id);
					local arena_meta = MsgHandler.Get_arena_meta_data_by_id(arena_id);
					if(arena_meta.is_sentient) then
						arrow_position_id = tonumber(arrow_position_id);
						caster_id = tonumber(caster_id) or caster_id;
						caster_slotid = tonumber(caster_slotid);
						target_id = tonumber(target_id) or target_id;
						target_slotid = tonumber(target_slotid);
						-- caster and target
						local caster;
						if(caster_ismob == "true") then
							caster = {isPlayer = false, npc_id = 39001, instance = caster_id, slotid = caster_slotid};
						elseif(caster_ismob == "false") then
							caster = {isPlayer = true, nid = caster_id, slotid = caster_slotid};
						end
						local target;
						if(target_ismob == "true") then
							target = {isPlayer = false, npc_id = 39001, instance = target_id, slotid = target_slotid};
						elseif(target_ismob == "false") then
							target = {isPlayer = true, nid = target_id, slotid = target_slotid};
						end
						-- play spell file
						local spell_file = "config/Aries/Spells/"..spell_key..".xml";
						SpellPlayer.PlaySpellEffect_single(arena_id, caster, target, spell_file, {{0}}, nil, function()
							finish_callback();
						end, bSkipCamera or bForceSkipThisSpellCamera, bIncludedInBattle); -- bSkipCamera, bIncludedInBattle
					else
						-- play spell file
						local spell_file = "config/Aries/Spells/"..spell_key..".xml";
						SpellPlayer.PlaySpellDuration(spell_file, function()
							finish_callback();
						end);
					end
				else
					finish_callback();
				end

			elseif(key == "dot") then
				-- TODO: spell dot
				local arena_id, arrow_position_id, caster_ismob, caster_id, damage_school, damage, wardsvalue = 
					string_match(value, "^([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^#]*)#(.*)$");
				if(arena_id and arrow_position_id and caster_ismob and caster_id and damage_school and damage and wardsvalue) then
					arena_id = tonumber(arena_id);
					local arena_meta = MsgHandler.Get_arena_meta_data_by_id(arena_id);
					if(arena_meta.is_sentient) then
						arrow_position_id = tonumber(arrow_position_id);
						caster_id = tonumber(caster_id) or caster_id;
						local this_mark = "";
						local mark = "";
						if(tonumber(damage)) then
							damage = tonumber(damage);
						else
							local tag, n_damage = string.match(damage, "^(.)(.+)$");
							if(tag and n_damage) then
								mark = tag;
								this_mark = tag;
								damage = tonumber(n_damage);
							end
						end
						local caster;
						local target;
						if(caster_ismob == "true") then
							caster = {isPlayer = false, npc_id = 39001, instance = caster_id, slotid = arrow_position_id};
							target = {isPlayer = false, npc_id = 39001, instance = caster_id, slotid = arrow_position_id};
						elseif(caster_ismob == "false") then
							caster = {isPlayer = true, nid = caster_id, slotid = arrow_position_id};
							target = {isPlayer = true, nid = caster_id, slotid = arrow_position_id};
						end
						-- play spell file
						local spell_file = "config/Aries/Spells/DoT_"..damage_school..".xml";
						if(System.options.version == "teen") then
							spell_file = "config/Aries/Spells/DoT_"..damage_school.."_teen.xml";
						end
						local buff_data = nil;
						if(bIncludedInBattle) then
							buff_data = {{["target_wards"] = wardsvalue}};
						end
						SpellPlayer.PlaySpellEffect_single(arena_id, caster, target, spell_file, {{damage, mark = this_mark}}, buff_data, function()
							finish_callback();
						end, bSkipCamera or bForceSkipThisSpellCamera, bIncludedInBattle, function(obj_name, delta_hp)
							if(obj_name == Pet.GetUserCharacterName()) then
								MsgHandler.SetCurrentHPDelta(delta_hp);
							end
							MsgHandler.ProcessSpellPlayLiveHPDelta(obj_name, delta_hp, index);
							-- show delta on object
							MsgHandler.ShowDeltaHPOnSlotForObject(obj_name, delta_hp);
							-- play dead spell if object match
							TryPlayDeadSpellForObject(obj_name, delta_hp, each_spell.dead_spells, PlaySingleSpell);
						end); -- bSkipCamera, bIncludedInBattle
					else
						-- play spell file
						local spell_file = "config/Aries/Spells/DoT_"..damage_school..".xml";
						if(System.options.version == "teen") then
							spell_file = "config/Aries/Spells/DoT_"..damage_school.."_teen.xml";
						end
						SpellPlayer.PlaySpellDuration(spell_file, function()
							finish_callback();
						end);
					end
				else
					finish_callback();
				end
			elseif(key == "hot") then
				-- TODO: spell hot
				local arena_id, arrow_position_id, caster_ismob, caster_id, heal, wardsvalue = 
					string_match(value, "^([^,]*),([^,]*),([^,]*),([^,]*),([^#]*)#(.*)$");
				if(arena_id and arrow_position_id and caster_ismob and caster_id and heal and wardsvalue) then
					arena_id = tonumber(arena_id);
					local arena_meta = MsgHandler.Get_arena_meta_data_by_id(arena_id);
					if(arena_meta.is_sentient) then
						arrow_position_id = tonumber(arrow_position_id);
						caster_id = tonumber(caster_id) or caster_id;
						heal = tonumber(heal);
						local caster;
						local target;
						if(caster_ismob == "true") then
							caster = {isPlayer = false, npc_id = 39001, instance = caster_id, slotid = arrow_position_id};
							target = {isPlayer = false, npc_id = 39001, instance = caster_id, slotid = arrow_position_id};
						elseif(caster_ismob == "false") then
							caster = {isPlayer = true, nid = caster_id, slotid = arrow_position_id};
							target = {isPlayer = true, nid = caster_id, slotid = arrow_position_id};
						end
						-- play spell file
						local spell_file = "config/Aries/Spells/HoT.xml";
						if(System.options.version == "teen") then
							spell_file = "config/Aries/Spells/HoT_teen.xml";
						end
						local buff_data = nil;
						if(bIncludedInBattle) then
							buff_data = {{["target_wards"] = wardsvalue}};
						end
						SpellPlayer.PlaySpellEffect_single(arena_id, caster, target, spell_file, {{heal}}, buff_data, function()
							finish_callback();
						end, bSkipCamera or bForceSkipThisSpellCamera, bIncludedInBattle, function(obj_name, delta_hp)
							if(obj_name == Pet.GetUserCharacterName()) then
								MsgHandler.SetCurrentHPDelta(delta_hp);
							end
							MsgHandler.ProcessSpellPlayLiveHPDelta(obj_name, delta_hp, index);
							-- show delta on object
							MsgHandler.ShowDeltaHPOnSlotForObject(obj_name, delta_hp);
							-- play dead spell if object match
							TryPlayDeadSpellForObject(obj_name, delta_hp, each_spell.dead_spells, PlaySingleSpell);
						end); -- bSkipCamera, bIncludedInBattle
					else
						-- play spell file
						local spell_file = "config/Aries/Spells/HoT.xml";
						if(System.options.version == "teen") then
							spell_file = "config/Aries/Spells/HoT_teen.xml";
						end
						SpellPlayer.PlaySpellDuration(spell_file, function()
							finish_callback();
						end);
					end
				else
					finish_callback();
				end
			elseif(key == "dead" or key == "dead_post") then
				-- mob or player dead
				local arena_id, arrow_position_id, caster_ismob, caster_id = string_match(value, "^([^,]*),([^,]*),([^,]*),([^,]*)$");
				if(arena_id and arrow_position_id and caster_ismob and caster_id) then
					arena_id = tonumber(arena_id);
					local arena_meta = MsgHandler.Get_arena_meta_data_by_id(arena_id);
					if(arena_meta.is_sentient) then
						arrow_position_id = tonumber(arrow_position_id);
						caster_id = tonumber(caster_id) or caster_id;
						if(params and params.obj_name) then
							local bMatchCharacter = false;
							if(params.delta_hp and params.delta_hp < 0) then
								-- damage
								if(caster_ismob == "true") then
									if(params.obj_name == "NPC:39001("..tostring(caster_id)..")") then
										bMatchCharacter = true;
									end
								elseif(caster_ismob == "false") then
									if(params.obj_name == tostring(caster_id)) then
										bMatchCharacter = true;
									end
								end
							end
							if(not bMatchCharacter) then
								finish_callback();
								return;
							end
						end
						local caster;
						local target;
						if(caster_ismob == "true") then
							caster = {isPlayer = false, npc_id = 39001, instance = caster_id, slotid = arrow_position_id};
							target = {isPlayer = false, npc_id = 39001, instance = caster_id, slotid = arrow_position_id};
						elseif(caster_ismob == "false") then
							caster = {isPlayer = true, nid = caster_id, slotid = arrow_position_id};
							target = {isPlayer = true, nid = caster_id, slotid = arrow_position_id};
						end
						-- play spell file
						local spell_file = "config/Aries/Spells/"..key..".xml";
						if(key == "dead") then
							if(System.options.version == "teen") then
								if(caster_ismob == "false") then
									spell_file = "config/Aries/Spells/dead_player_teen.xml";
								else
									spell_file = "config/Aries/Spells/dead_teen.xml";
								end
							else
								spell_file = "config/Aries/Spells/dead.xml";
							end
						elseif(key == "dead_post") then
							if(System.options.version == "teen") then
								spell_file = "config/Aries/Spells/dead_post_teen.xml";
							else
								spell_file = "config/Aries/Spells/dead_post.xml";
							end
						end
						local buff_data = nil;
						if(bIncludedInBattle) then
							buff_data = {{["target_charms"] = "", ["target_wards"] = "", ["target_overtimes"] = ""}};
						end
						SpellPlayer.PlaySpellEffect_single(arena_id, caster, target, spell_file, nil, buff_data, function()
							finish_callback();
						end, bSkipCamera or bForceSkipThisSpellCamera, bIncludedInBattle); -- bSkipCamera, bIncludedInBattle
					else
						-- NOTE 2012/1/19: dead spell do not cost any time, and invoked on damage
						---- play spell file
						--local spell_file = "config/Aries/Spells/"..key..".xml";
						--SpellPlayer.PlaySpellDuration(spell_file, function()
							--finish_callback();
						--end);
					end
				else
					finish_callback();
				end
				
			elseif(key == "dead_multiple") then
				-- NOTE 2012/1/19: dead spell do not cost any time, and invoked on damage
				do 
					finish_callback();
					return;
				end
				local arena_id, arrow_position_id, caster_ismob, caster_id, last_caster_charms, caster_charms, ismob_id_list_blocks = 
					string_match(value, "^([^,]*),([^,]*),([^,]*),([^%+]*)%+([^%+]*)%+([^%+]*)%+([^%+]*)$");
				if(arena_id and arrow_position_id and caster_ismob and caster_id and last_caster_charms and caster_charms and ismob_id_list_blocks) then
					arena_id = tonumber(arena_id);
					local arena_meta = MsgHandler.Get_arena_meta_data_by_id(arena_id);
					if(arena_meta.is_sentient) then
						arrow_position_id = tonumber(arrow_position_id);
						caster_id = tonumber(caster_id) or caster_id;
						-- caster 
						local caster;
						if(caster_ismob == "true") then
							caster = {isPlayer = false, npc_id = 39001, instance = caster_id, slotid = arrow_position_id};
						elseif(caster_ismob == "false") then
							caster = {isPlayer = true, nid = caster_id, slotid = arrow_position_id};
						end
						-- targets and params
						local targets = {};
						local params = {};
						local target_wards_array = {};
						local mark;
						local prior_target_marks = {};
						local ismob_id_list_last_ismob;
						local ismob_id_list_block;
						for ismob_id_list_block in string.gmatch(ismob_id_list_blocks, "%((.-)%)") do
							local ismob, id, arrow_position_id = 
								string_match(ismob_id_list_block, "^([^,]*),([^,]*),([^,]*)$");
							if(ismob and id and arrow_position_id) then
								if(ismob == "true") then
									table_insert(targets, {isPlayer = false, npc_id = 39001, instance = tonumber(id), slotid = tonumber(arrow_position_id)});
								elseif(ismob == "false") then
									table_insert(targets, {isPlayer = true, nid = tonumber(id) or id, slotid = tonumber(arrow_position_id)});
								end
								ismob_id_list_last_ismob = ismob;
								table_insert(params, 0);
								table_insert(target_wards_array, {
									["last_target_charms"] = "", ["target_charms"] = "", 
									["last_target_wards"] = "", ["target_wards"] = "", 
									["last_target_overtimes"] = "", ["target_overtimes"] = "", 
								});
							end
						end
						-- play spell file
						local spell_file;
						if(System.options.version == "teen") then
							if(ismob_id_list_last_ismob == "false") then
								spell_file = "config/Aries/Spells/dead_player_multiple_teen.xml";
							else
								spell_file = "config/Aries/Spells/dead_multiple_teen.xml";
							end
						else
							spell_file = "config/Aries/Spells/dead_multiple.xml";
						end
						if(not bIncludedInBattle) then
							target_wards_array = nil;
						end
						SpellPlayer.PlaySpellEffect_multiple(arena_id, caster, targets, spell_file, {params}, target_wards_array, function()
							finish_callback();
						end, bSkipCamera or bForceSkipThisSpellCamera, bIncludedInBattle, function(obj_name, delta_hp) end); -- bSkipCamera, bIncludedInBattle
					else
						-- play spell file
						local spell_file = "config/Aries/Spells/"..key..".xml";
						SpellPlayer.PlaySpellDuration(spell_file, function()
							finish_callback();
						end);
					end
				else
					finish_callback();
				end

			elseif(key == "revive" or key == "revive_post") then
				-- mob or player dead
				local arena_id, arrow_position_id, caster_ismob, caster_id = string_match(value, "^([^,]*),([^,]*),([^,]*),([^,]*)$");
				if(arena_id and arrow_position_id and caster_ismob and caster_id) then
					arena_id = tonumber(arena_id);
					local arena_meta = MsgHandler.Get_arena_meta_data_by_id(arena_id);
					if(arena_meta.is_sentient) then
						arrow_position_id = tonumber(arrow_position_id);
						caster_id = tonumber(caster_id) or caster_id;
						local caster;
						local target;
						if(caster_ismob == "true") then
							caster = {isPlayer = false, npc_id = 39001, instance = caster_id, slotid = arrow_position_id};
							target = {isPlayer = false, npc_id = 39001, instance = caster_id, slotid = arrow_position_id};
						elseif(caster_ismob == "false") then
							caster = {isPlayer = true, nid = caster_id, slotid = arrow_position_id};
							target = {isPlayer = true, nid = caster_id, slotid = arrow_position_id};
						end
						-- play spell file
						local spell_file = "config/Aries/Spells/"..key..".xml";
						local buff_data = nil;
						if(bIncludedInBattle) then
							buff_data = {{["target_charms"] = "", ["target_wards"] = "", ["target_overtimes"] = ""}};
						end
						SpellPlayer.PlaySpellEffect_single(arena_id, caster, target, spell_file, nil, buff_data, function()
							finish_callback();
						end, bSkipCamera or bForceSkipThisSpellCamera, bIncludedInBattle); -- bSkipCamera, bIncludedInBattle
					else
						-- play spell file
						local spell_file = "config/Aries/Spells/"..key..".xml";
						SpellPlayer.PlaySpellDuration(spell_file, function()
							finish_callback();
						end);
					end
				else
					finish_callback();
				end
			elseif(key == "pass") then
				-- mob or player pass
				local arena_id, arrow_position_id, caster_ismob, caster_id = string_match(value, "^([^,]*),([^,]*),([^,]*),([^,]*)$");
				if(arena_id and arrow_position_id and caster_ismob and caster_id) then
					arena_id = tonumber(arena_id);
					local arena_meta = MsgHandler.Get_arena_meta_data_by_id(arena_id);
					if(arena_meta.is_sentient) then
						arrow_position_id = tonumber(arrow_position_id);
						caster_id = tonumber(caster_id) or caster_id;
						-- caster
						local caster;
						if(caster_ismob == "true") then
							caster = {isPlayer = false, npc_id = 39001, instance = caster_id, slotid = arrow_position_id};
						elseif(caster_ismob == "false") then
							caster = {isPlayer = true, nid = caster_id, slotid = arrow_position_id};
						end
						-- play spell file
						local spell_file = "config/Aries/Spells/Pass.xml";
						SpellPlayer.PlaySpellEffect_single(arena_id, caster, caster, spell_file, nil, nil, function()
							--
						--end, bSkipCamera or bForceSkipThisSpellCamera, bIncludedInBattle); -- bSkipCamera, bAbove3D
						end, true, nil); -- bSkipCamera, bIncludedInBattle
						finish_callback();
					else
						-- play spell file
						local spell_file = "config/Aries/Spells/Pass.xml";
						SpellPlayer.PlaySpellDuration(spell_file, function()
							--
						end);
						finish_callback();
					end
				else
					finish_callback();
				end
			elseif(key == "pass_tutorial_teen") then
				-- mob or player pass_tutorial_teen
				local arena_id, arrow_position_id, caster_ismob, caster_id = string_match(value, "^([^,]*),([^,]*),([^,]*),([^,]*)$");
				if(arena_id and arrow_position_id and caster_ismob and caster_id) then
					arena_id = tonumber(arena_id);
					local arena_meta = MsgHandler.Get_arena_meta_data_by_id(arena_id);
					if(arena_meta.is_sentient) then
						arrow_position_id = tonumber(arrow_position_id);
						caster_id = tonumber(caster_id) or caster_id;
						-- caster
						local caster;
						if(caster_ismob == "true") then
							caster = {isPlayer = false, npc_id = 39001, instance = caster_id, slotid = arrow_position_id};
						elseif(caster_ismob == "false") then
							caster = {isPlayer = true, nid = caster_id, slotid = arrow_position_id};
						end
						-- play spell file
						local spell_file = "config/Aries/Spells/Pass_tutorial_teen.xml";
						SpellPlayer.PlaySpellEffect_single(arena_id, caster, caster, spell_file, nil, nil, function()
							finish_callback();
						--end, bSkipCamera or bForceSkipThisSpellCamera, bIncludedInBattle); -- bSkipCamera, bAbove3D
						end, true, nil); -- bSkipCamera, bIncludedInBattle
					else
						-- play spell file
						local spell_file = "config/Aries/Spells/Pass_tutorial_teen.xml";
						SpellPlayer.PlaySpellDuration(spell_file, function()
							finish_callback();
						end);
					end
				else
					finish_callback();
				end
			elseif(key == "update_arena") then
				-- update arena
				local key_update, value_update = string_match(value, "^([^%+]*)%+(.*)$");
				if(key_update and value_update) then
					local arena_id = string_match(key_update, "^arena_(%d+)$")
					if(not arena_id) then
						return;
					end
					arena_id = tonumber(arena_id);
					if(not arena_data_map[arena_id]) then
						-- if arena is not valid, skip proceecing to the next spell
						return;
					end
					MsgHandler.OnArenaNormalUpdate_by_key_value(key_update, value_update, true, true); -- true for bSkipSequenceArrowUpdate and bSkipCameraRefresh
					-- record last applied arena update value
					last_applied_arena_update_key = key_update;
					last_applied_arena_update_value = value_update;
				end
				-- force clear mouse over effect if user is in combat
				if(bIncludedInBattle) then
					ParaSelection.ClearGroup(2);
				end
				-- directly proceed to the next spell
				finish_callback();
			elseif(key == "update_value") then
				-- directly proceed to the next spell
				finish_callback();
				---- this is an update value command
				--if(string_find(value, "true") == 1) then
					---- this is a mob update
				--elseif(string_find(value, "false") == 1) then
					---- this is a player update
				--end
			elseif(key == "movearrow") then
				local arena_id, from_slot_id, to_slot_id = string_match(value, "^([^%+]*)%+([^%+]*)%+([^%+]*)$");
				
				if(arena_id and from_slot_id and to_slot_id) then
					arena_id = tonumber(arena_id);
					local arena_meta = MsgHandler.Get_arena_meta_data_by_id(arena_id);
					if(arena_meta.is_sentient) then
						from_slot_id = tonumber(from_slot_id);
						to_slot_id = tonumber(to_slot_id);
						ObjectManager.ShowSequenceArrow(arena_id, from_slot_id, to_slot_id, function()
							finish_callback();
						end);
					else
						finish_callback();
					end
				else
					finish_callback();
				end
			elseif(key == "playturnmotion") then
				if(bIncludedInBattle) then
					local pos_x, pos_y, pos_z, motion_id = string_match(value, "^([^,]*),([^,]*),([^,]*),([^,]*)$");
					if(pos_x and pos_y and pos_z and motion_id) then
						pos_x = tonumber(pos_x);
						pos_y = tonumber(pos_y);
						pos_z = tonumber(pos_z);
						-- hide hp slots on movie playing
						MsgHandler.HideHPSlots();
						-- play turn motion
						MotionXmlToTable.PlayCombatMotion(motion_id, function()
							finish_callback();
							-- show hp slots after movie playing
							MsgHandler.ShowHPSlots();
						end, {
							pos_x = pos_x,
							pos_y = pos_y,
							pos_z = pos_z,
							inner_combat = true,
						});
					end
				else
					-- this is almost the end of playturn sequence, the next spell is an update_arena spell
					finish_callback();
				end
			elseif(key == "motion_with_spell") then
				if(bIncludedInBattle) then
					local pos_x, pos_y, pos_z, motion_id, inmotion_sequence = string_match(value, "^([^,]*),([^,]*),([^,]*),([^,]*),(.*)$");
					if(pos_x and pos_y and pos_z and motion_id and inmotion_sequence) then
						pos_x = tonumber(pos_x);
						pos_y = tonumber(pos_y);
						pos_z = tonumber(pos_z);
						-- collect all spells
						local all_spells = {};
						local current_index = 1;
						local each_spell;
						for each_spell in string.gmatch(inmotion_sequence, "([^@]*)@@") do
							local key, value = string_match(each_spell, "^([^:]*):(.*)$");
							if(key and value) then
								table_insert(all_spells, {
									key = key,
									value = value,
								});
							end
						end
						local function PlayInMotionSpells(index)
							if(all_spells[index]) then
								PlaySingleSpell(all_spells[index], function()
									PlayInMotionSpells(index + 1);
								end, true);
							end
						end
						-- hide hp slots on movie playing
						MsgHandler.HideHPSlots();
						-- play motion with spell
						MotionXmlToTable.PlayCombatMotion(motion_id, function()
							finish_callback();
							-- show hp slots after movie playing
							MsgHandler.ShowHPSlots();
						end, {
							pos_x = pos_x,
							pos_y = pos_y,
							pos_z = pos_z,
							inner_combat = true,
							inner_combat_callback = function()
								if(all_spells[1]) then
									PlayInMotionSpells(1);
								end
						end});
					end
				else
					-- this is almost the end of playturn sequence, the next spell is an update_arena spell
					finish_callback();
				end
				
			elseif(key == "resetcamera") then
				if(bIncludedInBattle) then
					local arena_id = tonumber(value);
					if(arena_id) then
						-- create arena object if not exist
						local bMyselfFarSideInArena = true;
						local arena_data = MsgHandler.Get_arena_data_by_id(arena_id);
						if(arena_data.bMyselfFarSideInArena ~= nil) then
							bMyselfFarSideInArena = arena_data.bMyselfFarSideInArena;
						end
						local arena_char = NPC.GetNpcCharacterFromIDAndInstance(ObjectManager.GetArena_CameraView_NPC_ID(arena_id, bMyselfFarSideInArena));
						if(arena_char) then
							arena_char:ToCharacter():SetFocus();
							local att = ParaCamera.GetAttributeObject();
							att:SetField("CameraObjectDistance", 22);
							att:SetField("CameraLiftupAngle", 0.453516068459);
							att:SetField("CameraRotY", 1.5619721412659);
							if(bMyselfFarSideInArena == true) then
								-- far court
								att:SetField("CameraRotY", 1.5619721412659 + 3.14);
							end
						end
					end
				end
				finish_callback();
				
			elseif(key == "halt") then
				if(value) then
					local halt_time = tonumber(value);
					if(halt_time) then
						-- heal one health point
						UIAnimManager.PlayCustomAnimation(halt_time, function(elapsedTime)
							if(elapsedTime == halt_time) then
								finish_callback();
							end
						end);
					else
						finish_callback();
					end
				else
					finish_callback();
				end

			elseif(key == "speak" or key == "speak_dead") then
				-- mob or player speak, mainly for combat tutorial
				UIAnimManager.PlayCustomAnimation(1000, function(elapsedTime)
					if(elapsedTime == 1000) then
						-- halt for 1000 milliseconds
						finish_callback();
					end
				end);
				
				local arena_id, caster_ismob, caster_id, phase, npc_name, words = string_match(value, "^([^,]*),([^,]*),([^,]*),([^,%[]*)%[([^%]]*)%]%[(.*)%]$");
				if(arena_id and caster_ismob and caster_id and phase and npc_name and words) then
					arena_id = tonumber(arena_id);
					local bInSightRange = false;
					local arena_meta = MsgHandler.Get_arena_meta_data_by_id(arena_id);
					if(arena_meta) then
						local m_x = arena_meta.p_x;
						local m_y = arena_meta.p_y;
						local m_z = arena_meta.p_z;
						
						local player_char = MyCompany.Aries.Player.GetPlayer();
						if(player_char and player_char:IsValid()) then
							local p_x, p_y, p_z = player_char:GetPosition();
							if(m_x and m_y and m_z) then
								local arena_distance_sq = (m_x - p_x) * (m_x - p_x) + (m_z - p_z) * (m_z - p_z);
								if(arena_distance_sq < 10000) then
									bInSightRange = true;
								else
									bInSightRange = false;
								end
							end
						end
					end
					-- only play speak action and append to channel in sight range
					if(bInSightRange) then
						caster_id = tonumber(caster_id) or caster_id;
						if(params and params.obj_name) then
							local bMatchCharacter = false;
							if(params.delta_hp and params.delta_hp < 0) then
								-- damage
								if(caster_ismob == "true") then
									if(params.obj_name == "NPC:39001("..tostring(caster_id)..")") then
										bMatchCharacter = true;
									end
								elseif(caster_ismob == "false") then
									if(params.obj_name == tostring(caster_id)) then
										bMatchCharacter = true;
									end
								end
							end
							if(not bMatchCharacter) then
								return;
							end
						end
						-- caster
						local caster;
						if(caster_ismob == "true") then
							caster = {isPlayer = false, npc_id = 39001, instance = caster_id, slotid = arrow_position_id};
						elseif(caster_ismob == "false") then
							caster = {isPlayer = true, nid = caster_id, slotid = arrow_position_id};
							if(caster_id) then
								if(caster_id >= 27001 and caster_id <= 27999) then
									local gsItem = ItemManager.GetGlobalStoreItemInMemory(caster_id)
									if(gsItem) then
										npc_name = gsItem.template.name;
									end
								end
							end
						end
						-- append npc chat channel message
						NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/ChatChannel.lua");
						local ChatChannel = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatChannel");
						ChatChannel.AppendChat({
							ChannelIndex = ChatChannel.EnumChannels.NPC, 
							from = 0, 
							fromname = npc_name, 
							fromschool = phase, 
							fromisvip = false, 
							words = words,
							bHideTooltip = true,
						});
						-- play spell file
						local spell_file = "config/Aries/Spells/Speak.xml";
						SpellPlayer.PlaySpellEffect_single(arena_id, caster, caster, spell_file, words, nil, function()
						end, bSkipCamera or bForceSkipThisSpellCamera, bIncludedInBattle); -- bSkipCamera, bIncludedInBattle
					end
				end
			else
				local bFromPetCard = false;
				if(each_spell.IsFromPetCard) then
					if(System.options.version == "teen") then
						bFromPetCard = each_spell.IsFromPetCard;
					end
				end

				if(string_find(value, "%+")) then
					-- this is an area effect spell

					--AreaAttack_Level1_Wood:
					--1003,1,false,39395,(true,50004,78)(true,50005,78)(true,50006,78)
					
					local card_key, arena_id, arrow_position_id, caster_ismob, caster_id, last_caster_charms, caster_charms, ismob_id_damage_blocks = 
						string_match(value, "^([^,]*),([^,]*),([^,]*),([^,]*),([^%+]*)%+([^%+]*)%+([^%+]*)%+([^%+]*)$");
					if(card_key and arena_id and arrow_position_id and caster_ismob and caster_id and last_caster_charms and caster_charms and ismob_id_damage_blocks) then
						arena_id = tonumber(arena_id);
						local arena_meta = MsgHandler.Get_arena_meta_data_by_id(arena_id);
						if(arena_meta.is_sentient) then
							arrow_position_id = tonumber(arrow_position_id);
							caster_id = tonumber(caster_id) or caster_id;
							-- caster 
							local caster;
							if(caster_ismob == "true") then
								caster = {isPlayer = false, npc_id = 39001, instance = caster_id, slotid = arrow_position_id};
							elseif(caster_ismob == "false") then
								caster = {isPlayer = true, nid = caster_id, slotid = arrow_position_id, bFromPetCard = bFromPetCard};
							end
							-- play spell name
							local quality = nil;
							local gsid;
							if(System.options.version == "teen") then
								if(string.find(card_key, "_Rune_")) then
									gsid = Combat.Get_gsid_from_rune_cardkey(card_key);
								else
									gsid = Combat.Get_gsid_from_cardkey(card_key);
								end
								if(not gsid) then
									gsid = Combat.Get_gsid_from_rune_cardkey(card_key);
								end
							end
							if(not gsid) then
								gsid = Combat.Get_gsid_from_cardkey(card_key);
							end
							if(gsid) then
								if(not string.find(card_key, "SingleAttack_Level0")) then
									local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid)
									if(gsItem) then
										local spell_file = "config/Aries/Spells/Shout.xml";
										SpellPlayer.PlaySpellEffect_single(arena_id, caster, caster, spell_file, gsItem.template.name, nil, function()
										end, bSkipCamera or bForceSkipThisSpellCamera, bIncludedInBattle, nil, nil, gsItem); -- bSkipCamera, bIncludedInBattle
									end
								end
								--if(System.options.version == "teen") then
									local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid)
									if(gsItem) then
										if(gsItem.template.stats[221] == 1) then
											quality = "Green";
										elseif(gsItem.template.stats[221] == 2) then
											quality = "Blue";
										elseif(gsItem.template.stats[221] == 3) then
											quality = "Purple";
										elseif(gsItem.template.stats[221] == 4) then
											quality = "Orange";
										end
									end
								--end
							end
							-- targets and params
							local targets = {};
							local params = {};
							local target_wards_array = {};
							local mark;
							local prior_target_marks = {};
							local ismob_id_damage_block;
							for ismob_id_damage_block in string.gmatch(ismob_id_damage_blocks, "%((.-)%)") do
								local ismob, id, slotid, damage, last_target_charms, target_charms, last_target_wards, target_wards, last_target_overtimes, target_overtimes = 
									string_match(ismob_id_damage_block, "^([^,]*),([^,]*),([^,]*),([^,#]*)#([^#]*)#([^#]*)#([^#]*)#([^#]*)#([^#]*)#([^#]*)$");
								if(ismob and id and slotid and damage and target_wards) then
									if(ismob == "true") then
										table_insert(targets, {isPlayer = false, npc_id = 39001, instance = tonumber(id), slotid = tonumber(slotid)});
									elseif(ismob == "false") then
										table_insert(targets, {isPlayer = true, nid = tonumber(id) or id, slotid = tonumber(slotid)});
									end
									local this_mark = "";
									if(tonumber(damage)) then
										damage = tonumber(damage);
									else
										local tag, n_damage = string.match(damage, "^(.)(.+)$");
										if(tag and n_damage) then
											mark = tag;
											this_mark = tag;
											damage = tonumber(n_damage);
										end
									end
									table_insert(params, tonumber(damage));
									table_insert(prior_target_marks, this_mark);
									table_insert(target_wards_array, {
										["last_target_charms"] = last_target_charms, ["target_charms"] = target_charms, 
										["last_target_wards"] = last_target_wards, ["target_wards"] = target_wards, 
										["last_target_overtimes"] = last_target_overtimes, ["target_overtimes"] = target_overtimes, 
									});
								end
							end
							params.mark = mark;
							params.prior_target_marks = prior_target_marks;
							target_wards_array["last_caster_charms"] = last_caster_charms;
							target_wards_array["caster_charms"] = caster_charms;
							-- TODO: very dirt code to directly name all related file with the same key
							-- play spell file
							local spell_file = "config/Aries/Spells/"..key..".xml";
							if(not bIncludedInBattle) then
								target_wards_array = nil;
							end
							SpellPlayer.PlaySpellEffect_multiple(arena_id, caster, targets, spell_file, {params}, target_wards_array, function()
								finish_callback();
							end, bSkipCamera or bForceSkipThisSpellCamera, bIncludedInBattle, function(obj_name, delta_hp)
								if(obj_name == Pet.GetUserCharacterName()) then
									MsgHandler.SetCurrentHPDelta(delta_hp);
								end
								MsgHandler.ProcessSpellPlayLiveHPDelta(obj_name, delta_hp, index);
								-- show delta on object
								MsgHandler.ShowDeltaHPOnSlotForObject(obj_name, delta_hp);
								-- play dead spell if object match
								TryPlayDeadSpellForObject(obj_name, delta_hp, each_spell.dead_spells, PlaySingleSpell);
							end, nil, nil, quality); -- bSkipCamera, bIncludedInBattle
						else
							-- play spell file
							local spell_file = "config/Aries/Spells/"..key..".xml";
							SpellPlayer.PlaySpellDuration(spell_file, function()
								finish_callback();
							end);
						end
					else
						finish_callback();
					end
				else
					-- this is single effect spell
					local section1, section2 = string_match(value, "^([^#]+)(.+)$");

					if(section1 and section2) then
						local card_key, arena_id, arrow_position_id, caster_ismob, caster_id, caster_slotid, target_ismob, target_id, target_slotid, params, secondary_params = 
							string_match(section1, "^([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*)$");
						
						local last_caster_charms, caster_charms, last_target_charms, target_charms, last_target_wards, target_wards, last_target_overtimes, target_overtimes = 
							string_match(section2, "^#([^#]*)#([^#]*)#([^#]*)#([^#]*)#([^#]*)#([^#]*)#([^#]*)#([^#]*)$");

						-- NOTE: expression bug
						-- sample: value = "1001,1,false,46650264,1,false,46650264,1,0,0#####0,0,8,6,9,7,8,8,9,7,#8,6,8,6,9,7,8,8,9,7,##"
						--local arena_id, arrow_position_id, caster_ismob, caster_id, caster_slotid, target_ismob, target_id, target_slotid, params, secondary_params, 
							--last_caster_charms, caster_charms, last_target_charms, target_charms, last_target_wards, target_wards, last_target_overtimes, target_overtimes = 
							--string_match(value, "^(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+)#(.-)#(.-)#(.-)#(.-)#(.-)#(.-)#(.-)#(.-)$");
						if(arena_id and arrow_position_id and caster_ismob and caster_id and caster_slotid and target_ismob and target_id and target_slotid and params and secondary_params and 
							last_caster_charms and caster_charms and last_target_charms and target_charms and last_target_wards and target_wards and last_target_overtimes and target_overtimes) then
							arena_id = tonumber(arena_id);
							local arena_meta = MsgHandler.Get_arena_meta_data_by_id(arena_id);
							if(arena_meta.is_sentient) then
								local mark_1;
								local mark_2;
								arrow_position_id = tonumber(arrow_position_id);
								caster_id = tonumber(caster_id) or caster_id;
								caster_slotid = tonumber(caster_slotid);
								target_id = tonumber(target_id) or target_id;
								target_slotid = tonumber(target_slotid);
								if(tonumber(params)) then
									params = tonumber(params);
								else
									local tag, n_params = string.match(params, "^(.)(.+)$");
									if(tag and n_params) then
										mark_1 = tag;
										params = tonumber(n_params);
									end
								end
								if(tonumber(secondary_params)) then
									secondary_params = tonumber(secondary_params);
								else
									local tag, n_params = string.match(secondary_params, "^(.)(.+)$");
									if(tag and n_params) then
										mark_2 = tag;
										secondary_params = tonumber(n_params);
									end
								end
								-- caster and target
								local caster;
								if(caster_ismob == "true") then
									caster = {isPlayer = false, npc_id = 39001, instance = caster_id, slotid = caster_slotid};
								elseif(caster_ismob == "false") then
									caster = {isPlayer = true, nid = caster_id, slotid = caster_slotid, bFromPetCard = bFromPetCard};
								end
								local target;
								if(target_ismob == "true") then
									target = {isPlayer = false, npc_id = 39001, instance = target_id, slotid = target_slotid};
								elseif(target_ismob == "false") then
									target = {isPlayer = true, nid = target_id, slotid = target_slotid};
								end
								-- play spell name
								local quality = nil;
								local gsid;
								if(System.options.version == "teen") then
									if(string.find(card_key, "_Rune_")) then
										gsid = Combat.Get_gsid_from_rune_cardkey(card_key);
									else
										gsid = Combat.Get_gsid_from_cardkey(card_key);
									end
									if(not gsid) then
										gsid = Combat.Get_gsid_from_rune_cardkey(card_key);
									end
								end
								if(not gsid) then
									gsid = Combat.Get_gsid_from_cardkey(card_key);
								end
								if(gsid) then
									if(not string.find(card_key, "SingleAttack_Level0")) then
										local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid)
										if(gsItem) then
											local spell_file = "config/Aries/Spells/Shout.xml";
											SpellPlayer.PlaySpellEffect_single(arena_id, caster, caster, spell_file, gsItem.template.name, nil, function()
											end, bSkipCamera or bForceSkipThisSpellCamera, bIncludedInBattle, nil, nil, gsItem); -- bSkipCamera, bIncludedInBattle
										end
									end
									--if(System.options.version == "teen") then
										local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid)
										if(gsItem) then
											if(gsItem.template.stats[221] == 1) then
												quality = "Green";
											elseif(gsItem.template.stats[221] == 2) then
												quality = "Blue";
											elseif(gsItem.template.stats[221] == 3) then
												quality = "Purple";
											elseif(gsItem.template.stats[221] == 4) then
												quality = "Orange";
											end
										end
									--end
								end
								-- TODO: very dirt code to directly name all related file with the same key
								-- play spell file
								local spell_file = "config/Aries/Spells/"..key..".xml";
								local buff_data = nil;
								if(bIncludedInBattle) then
									buff_data = 
										{ {["last_caster_charms"] = last_caster_charms, ["caster_charms"] = caster_charms, 
										["last_target_charms"] = last_target_charms, ["target_charms"] = target_charms, 
										["last_target_wards"] = last_target_wards, ["target_wards"] = target_wards, 
										["last_target_overtimes"] = last_target_overtimes, ["target_overtimes"] = target_overtimes, } };
								end
								SpellPlayer.PlaySpellEffect_single(arena_id, caster, target, spell_file, 
									{{params, mark = mark_1}, {secondary_params, mark = mark_2}}, 
									buff_data, 
									function()
										finish_callback();
									end, bSkipCamera or bForceSkipThisSpellCamera, bIncludedInBattle, function(obj_name, delta_hp)
										if(obj_name == Pet.GetUserCharacterName()) then
											MsgHandler.SetCurrentHPDelta(delta_hp);
										end
										MsgHandler.ProcessSpellPlayLiveHPDelta(obj_name, delta_hp, index);
										-- show delta on object
										MsgHandler.ShowDeltaHPOnSlotForObject(obj_name, delta_hp);
										-- play dead spell if object match
										TryPlayDeadSpellForObject(obj_name, delta_hp, each_spell.dead_spells, PlaySingleSpell);
									end, nil, nil, quality); -- bSkipCamera, bIncludedInBattle
							else
								-- play spell file
								local spell_file = "config/Aries/Spells/"..key..".xml";
								SpellPlayer.PlaySpellDuration(spell_file, function()
									finish_callback();
								end);
							end
						else
							finish_callback();
						end
					else
						finish_callback();
					end
				end
				-- [1]="[Aries][combat_to_client]PlayTurn:{SingleAttack_Level1_Metal:1003,5,true,50004,false,39395,88}{fizzle:1003,6,true,50005,metal}{SingleAttack_Level1_Metal:1003,7,true,50006,false,39395,92}{AreaAttack_Level1_Wood:1003,1,false,39395,{true,50004,78}{true,50005,78}{true,50006,78}}",
				
			end
		end
	end
	
	-- pop each spell in turn sequence
	local function PlayNextSpell(index)
		-- NOTE: solve the bug that the playturn still working when enter homeland
		local HomeLandGateway = commonlib.gettable("System.App.HomeLand.HomeLandGateway");
		if(HomeLandGateway.IsInHomeland()) then
			all_spells = {};
			return;
		end
		local each_spell = all_spells[index];
		if(each_spell == nil) then
			if(last_applied_arena_update_key and last_applied_arena_update_value) then
				-- update  with refreshed camera
				MsgHandler.OnArenaNormalUpdate_by_key_value(last_applied_arena_update_key, last_applied_arena_update_value, true, nil); -- true for bSkipSequenceArrowUpdate and nil for bSkipCameraRefresh
			end
			local bContinue = true;
			if(MsgHandler.callback_after_playturn) then
				bContinue = MsgHandler.callback_after_playturn()
				MsgHandler.callback_after_playturn = nil;
			end
			if(bContinue and bIncludedInBattle) then
				MsgHandler.OnFinishedPlayTurn(seq);
			end
			if(bIncludedInBattle == true) then
				MsgHandler.bMyArenaPlayingTurns = false;
			end
			return;
		end

		if(bIncludedInBattle == true) then
			MsgHandler.bMyArenaPlayingTurns = true;
		end

		local isLastSpell = false;
		if(index == #all_spells) then
			isLastSpell = true;
		end

		PlaySingleSpell(each_spell, function()
			PlayNextSpell(index + 1);
		end);
	end
	
	if(bIncludedInBattle == true) then
		-- force refresh hp slots
		MsgHandler.ShowHPSlots()
	end

	-- play from the first spell
	PlayNextSpell(1);
	
	--UIAnimManager.PlayCustomAnimation(5000, function(elapsedTime)
		--if(elapsedTime == 5000) then
			---- finished playing turn
			--MsgHandler.OnFinishedPlayTurn();
		--end
	--end);
end

-- on flee successful
function MsgHandler.OnFleeFromArena()
    local MsgHandler = MyCompany.Aries.Combat.MsgHandler;
	-- first hide card picker
	MsgHandler.HideCardPicker();
    -- hide target picker
    MsgHandler.HideTargetPicker();
	-- first hide all hp slots
	MsgHandler.HideHPSlots();
	-- clear count down timer
	MsgHandler.OnUpdateCountDown(0);

	-- hide the my runes page
	MsgHandler.HideMyRunesPage();

	-- call the basic arena's OnFleeSuccess handler
	local OnFleeSuccess = commonlib.getfield("MyCompany.Aries.Quest.NPCs.BasicArena.OnFleeSuccess");
	if(OnFleeSuccess) then
		OnFleeSuccess();
	end
end

-- on expend card, server send this message only on card spell is successfully casted and remind the client to destroy the card
-- NOTE: in the next combat stage this process will be moved to power server api
-- @param value: key of the card template
function MsgHandler.OnExpendCard(value)
	
	--_guihelper.MessageBox("OnExpendCard"..value);
	
	local ItemManager = System.Item.ItemManager;
	local hasGSItem = ItemManager.IfOwnGSItem;
	local card_key = value;

	local gsid = 23001;
	for gsid = 23001, 23999 do
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid)
		if(gsItem) then
			local assetkey = gsItem.assetkey;
			if(string_find(assetkey, card_key)) then
				-- destroy card item
				local bHas, guid = hasGSItem(gsid);
				if(bHas) then
					ItemManager.DestroyItem(guid, 1, function() end);
				end
				return;
			end
		end
	end
end
--return notification_msg,arena_id of myself
function MsgHandler.GainedLoots(value, bFromMyself, bTriggerAdditionalLootPanel)
	
	local arena_id, mode, nid, gained_exp, original_exp, exp_scale, pet_exp, gained_joybean, isWinner, gained_loot, loot_scale = 
		string_match(value, "^([^~]*)~([^~]*)~([^~]*)~([^~]*)~([^~]*)~([^~]*)~([^~]*)~([^~]*)~([^~]*)~([^~]*)~([^~]*)$");
		
	if(gained_loot) then
		arena_id = tonumber(arena_id);
		nid = tonumber(nid);
		gained_exp = tonumber(gained_exp);
		original_exp = tonumber(original_exp);
		exp_scale = tonumber(exp_scale);
		pet_exp = tonumber(pet_exp);
		gained_joybean = tonumber(gained_joybean);
		loot_scale = tonumber(loot_scale);
		
		local loots = {};
		local gsid_cnt_str;
		for gsid_cnt_str in string.gmatch(gained_loot, "[^%+]+") do
			local gsid, cnt = string.match(gsid_cnt_str, "^(%d+),(%d+)$")
			if(gsid and cnt) then
				gsid = tonumber(gsid);
				cnt = tonumber(cnt);
				if(gsid and cnt) then
					loots[gsid] = cnt;
				end
			end
		end
		local notification_msg;
		if(bFromMyself) then
			-- show notification
			notification_msg = {};
			notification_msg.adds = {};
			notification_msg.updates = {};
			notification_msg.stats = {};
			if(gained_joybean > 0 ) then
				notification_msg.stats = {{gsid = 0, cnt = gained_joybean}};
			end
			local gsid, count;
			for gsid, count in pairs(loots) do
				--table.insert(notification_msg.adds, {gsid = gsid, cnt = count});
				
				if(not bTriggerAdditionalLootPanel) then
					-- call hook for OnObtainItem
					if(gsid < 50001) then
						table.insert(notification_msg.adds, {gsid = gsid, cnt = count});
						local hook_msg = { aries_type = "OnObtainItem", gsid = gsid, count = count, wndName = "items"};
						CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
					end
					--local hook_msg = { aries_type = "OnObtainItem", gsid = gsid, count = count, wndName = "items"};
					--CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
				end
			end
			if(not bTriggerAdditionalLootPanel) then
				Dock.OnExtendedCostNotification(notification_msg);
			end

			-- check be have "FateCardMaker"
			FateCard.HasFateCardMaker(loots);

		end
		
		if(not bFromMyself) then
			if(mode == "pve") then
				MsgHandler.OnCombatResultBubble2(nid, gained_exp, original_exp, exp_scale, pet_exp, gained_joybean, nil, loots, loot_scale);
			elseif(mode == "free_pvp") then
				if(isWinner == "true") then
					MsgHandler.OnCombatResultBubble2(nid, gained_exp, original_exp, exp_scale, pet_exp, gained_joybean, true, loots, loot_scale);
				elseif(isWinner == "false") then
					MsgHandler.OnCombatResultBubble2(nid, gained_exp, original_exp, exp_scale, pet_exp, gained_joybean, false, loots, loot_scale);
				end
			end
		end
		return notification_msg,arena_id;
	end
end

function MsgHandler.OnGainExp(value, isalive)
	--local exp_pts, result_list = string_match(value, "^(.+)~(.+)$");

	local gained_exp, original_exp, exp_scale, all_buddy_exp, gained_joybean, all_buddy_joybeans, gained_loot, all_buddy_loots, gained_lootable_mobs = 
		string_match(value, "^([^~]*)~([^~]*)~([^~]*)~([^~]*)~([^~]*)~([^~]*)~([^~]*)~([^~]*)~([^~]*)$");
	if(gained_lootable_mobs) then
		gained_exp = tonumber(gained_exp);
		original_exp = tonumber(original_exp);
		exp_scale = tonumber(exp_scale);
		gained_joybean = tonumber(gained_joybean);

		local islevelup = false;
		-- check if the user levelup
		local bean = Pet.GetBean();
		if(bean) then
			if((bean.combatexp + gained_exp) >= bean.nextlevelexp) then
				islevelup = true;
			end
		end

		local loots = {};
		local gsid;
		for gsid in string.gmatch(gained_loot, "[^#]+") do
			gsid = tonumber(gsid);

			loots[gsid] = loots[gsid] or 0;
			loots[gsid] = loots[gsid] + 1;
		end
		
		---- NOTE: 2013/4/16: the result from PowerItemManager is imp MsgHandler.GainedLoots(bFromMyself)
		---- ROLLBACK
--
		---- show notification
		--local notification_msg = {};
		--notification_msg.adds = {};
		--notification_msg.updates = {};
		--notification_msg.stats = {};
		--if(gained_joybean > 0 ) then
			--notification_msg.stats = {{gsid = 0, cnt = gained_joybean}};
		--end
		--local gsid, count;
		--for gsid, count in pairs(loots) do
			--table.insert(notification_msg.adds, {gsid = gsid, cnt = count});
			--
			---- call hook for OnObtainItem
			--local hook_msg = { aries_type = "OnObtainItem", gsid = gsid, count = count, wndName = "items"};
			--CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 0, "Aries", hook_msg);
		--end
		--Dock.OnExtendedCostNotification(notification_msg);
		
		local app_key = "";
		if(MyCompany.Aries.app) then
			app_key = MyCompany.Aries.app.app_key;
		else
			app_key = MyCompany.Taurus.app.app_key;
		end

		---- NOTE: 2010/11/2: the combat result panel is depracated
		---- show experience panel
		--System.App.Commands.Call("File.MCMLWindowFrame", {
			---- TODO:  Add uid to url
			--url = "script/apps/Aries/Combat/UI/CombatResult.html?all_buddy_exp="..all_buddy_exp..
					--"&all_buddy_joybeans="..tostring(all_buddy_joybeans)..
					--"&all_buddy_loots="..tostring(all_buddy_loots)..
					--"&islevelup="..tostring(islevelup)..
					--"&isdefeated="..tostring(not isalive)..
					--"&isteamdefeated=false", 
			--name = "Aries.CombatResult", 
			--app_key = app_key, 
			--isShowTitleBar = false,
			--allowDrag = false,
			--DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			--style = CommonCtrl.WindowFrame.ContainerStyle,
			--zorder = 2,
			--directPosition = true,
				--align = "_ct",
				--x = -840/2,
				--y = -512/2,
				--width = 840,
				--height = 512,
		--});
		---- show victory hint
		--MsgHandler.ShowVictoryHint()
		
		-- on victory
		local OnVictory = commonlib.getfield("MyCompany.Aries.Quest.NPCs.BasicArena.OnVictory");
		if(OnVictory) then
			OnVictory();
		end
		
		-- lootable mobs handler, daily quest
		-- NOTE: this is temporary solution for the first daily quest version to evaluate the process on pure client
		MsgHandler.OnLootableMobs(gained_lootable_mobs);
		
		---- NOTE: 2010/11/2: the combat result panel is depracated
		---- close mcml page if not closed after 15 seconds
		--UIAnimManager.PlayCustomAnimation(15000, function(elapsedTime)
			--if(elapsedTime == 15000) then
				--System.App.Commands.Call("File.MCMLWindowFrame", {
					---- TODO:  Add uid to url
					--url = "script/apps/Aries/Combat/UI/CombatResult.html?all_buddy_exp="..all_buddy_exp, 
					--name = "Aries.CombatResult", 
					--app_key = app_key, 
					--bShow = false;
				--});
			--end
		--end);
	end
end

function MsgHandler.OnGainExpButDefeated(value)
	MsgHandler.OnGainExp(value, false)
	-- call the basic arena's OnDefeated handler
	local OnDefeated = commonlib.getfield("MyCompany.Aries.Quest.NPCs.BasicArena.OnDefeated");
	if(OnDefeated) then
		OnDefeated();
		-- heal one health point
		UIAnimManager.PlayCustomAnimation(1000, function(elapsedTime)
			if(elapsedTime == 1000) then
				MsgHandler.HealByWisp(1);
			end
		end);
	end
end

function MsgHandler.GainExpButDefeatedInInstance(value)
	MsgHandler.OnGainExp(value, false)
	-- call the basic arena's OnDefeated handler
	local OnDefeatedInInstance = commonlib.getfield("MyCompany.Aries.Quest.NPCs.BasicArena.OnDefeatedInInstance");
	if(OnDefeatedInInstance) then
		OnDefeatedInInstance();
		-- heal one health point
		UIAnimManager.PlayCustomAnimation(1000, function(elapsedTime)
			if(elapsedTime == 1000) then
				MsgHandler.HealByWisp(1);
			end
		end);
	end
end

function MsgHandler.OnDefeated()
	
	local worldinfo = WorldManager:GetCurrentWorld();
	local worldname = worldinfo.name;

	if(worldname == "HaqiTown_FireCavern_110527_2") then
		return;
	end

	-- call the basic arena's OnDefeated handler
	local OnDefeated = commonlib.getfield("MyCompany.Aries.Quest.NPCs.BasicArena.OnDefeated");
	if(OnDefeated) then
		OnDefeated();
		-- heal one health point
		UIAnimManager.PlayCustomAnimation(1000, function(elapsedTime)
			if(elapsedTime == 1000) then
				MsgHandler.HealByWisp(1000);
			end
		end);
	end
	-- _guihelper.MessageBox([[<div style="margin-top:30px;margin-left:0px;width:300px;">很遗憾，战斗失败，你被传送回了安全区域！</div>]]);
	NPL.load("(gl)script/apps/Aries/Combat/UI/DefeatedPage.lua")
	MyCompany.Aries.Combat.DefeatedPage.Show();
end

local is_hp_tip_shown = false;

local is_dead_tip_shown = false;

function MsgHandler.OnCheckHPTip()

	if(System.options.version == "teen") then
		return;
		--if(current_hp and max_hp and current_hp > 0 and (current_hp < max_hp)) then
			--MyCompany.Aries.app:WriteConfig("is_date_tip_shown", true);
			--is_hp_tip_shown = true;
			--
			---- 启动主动提醒
				--
			--local ItemManager = System.Item.ItemManager;
			--local hasGSItem = ItemManager.IfOwnGSItem;
			--local bHas1,_ = hasGSItem(17155); -- 是否有 1 级红枣
			--local bHas2,_ = hasGSItem(17156); -- 是否有 2 级红枣
			--local bHas3,_ = hasGSItem(17157); -- 是否有 3 级红枣
			--local bHas4,_ = hasGSItem(17158); -- 是否有 4 级红枣
			--local bHas5,_ = hasGSItem(17159); -- 是否有 5 级红枣
			--local hasRedDate= bHas1 or bHas2 or bHas3 or bHas4 or bHas5;
			--if (hasRedDate) then	--是否有红枣				
				----NPL.load("(gl)script/apps/Aries/Desktop/Dock/AutoTips.lua");
				----local AutoTips = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips");
				----AutoTips.ShowPage("LowHP");
				--
				----local pe_slot = commonlib.gettable("Map3DSystem.mcml_controls.pe_slot");
				----local i;
				----for i = 1, 9 do
					----local gsid = pe_slot.Get_shortcut_gsid(i);
					----if(gsid and gsid >= 17155 and gsid <= 17159) then
						----if(hasGSItem(gsid)) then
							----local Desktop = MyCompany.Aries.Desktop;
							----Desktop.GUIHelper.ArrowPointer.ShowArrow(43298, 2, "_ctb", -342 + (i - 1) * 41, -80, 64, 64);
							----
							----UIAnimManager.PlayCustomAnimation(5000, function(elapsedTime)
								----if(elapsedTime == 5000) then
									----Desktop.GUIHelper.ArrowPointer.HideArrow(43298);
								----end
							----end);
							----break;
						----end
					----end
				----end
			--else
				----BroadcastHelper.PushLabel({id = "low_hp_no_potion_tip", label = "你没有血瓶了,要不要去NPC商店那买一点", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
				--NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/ChatChannel.lua");
				--local ChatChannel = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatChannel");
				--ChatChannel.AppendChat({
					--ChannelIndex = ChatChannel.EnumChannels.NPC, 
					--from = nil, 
					--bHideSubject = true,
					--is_direct_mcml = true, 
					--words = "从背包中打开外卖商店可以购买治疗药剂",
					--bHideTooltip = true,
				--});
			--end
		--end
		---- special teen version
		--return;
	end

	if(not is_hp_tip_shown and Player.GetLevel() > 10) then
		if(MyCompany.Aries.app:ReadConfig("is_date_tip_shown")) then
			is_hp_tip_shown = true;
			return;
		else
			local current_hp = MsgHandler.GetCurrentHP();
			local max_hp = MsgHandler.GetMaxHP();

			if(current_hp and max_hp and current_hp > 0 and (current_hp <= (max_hp * 0.6))) then
				MyCompany.Aries.app:WriteConfig("is_date_tip_shown", true);
				is_hp_tip_shown = true;

				-- 启动主动提醒
				
				local ItemManager = System.Item.ItemManager;
				local hasGSItem = ItemManager.IfOwnGSItem;
				local bHas1,_ = hasGSItem(17155); -- 是否有 1 级红枣
				local bHas2,_ = hasGSItem(17156); -- 是否有 2 级红枣
				local bHas3,_ = hasGSItem(17157); -- 是否有 3 级红枣
				local bHas4,_ = hasGSItem(17158); -- 是否有 4 级红枣
				local bHas5,_ = hasGSItem(17159); -- 是否有 5 级红枣
				local hasRedDate= bHas1 or bHas2 or bHas3 or bHas4 or bHas5;
				if (hasRedDate) then	--是否有红枣				
					NPL.load("(gl)script/apps/Aries/Desktop/Dock/AutoTips.lua");
					local AutoTips = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips");
					AutoTips.ShowPage("LowHP");
				end
				_guihelper.MessageBox([[<div style="margin-top:12px;">你的生命值太低了，快使用背包中的红枣回复生命值(红枣各个岛屿的NPC安卓婆婆有售)</div>]]);
			end
		end
	end
end

function MsgHandler.CheckEquipDurability()
-- 如果当前装着装备耐久度为0 则弹出小精灵提示
	if (Combat.HasZeroDurability()) then
		NPL.load("(gl)script/apps/Aries/Desktop/Dock/AutoTips.lua");
		local AutoTips = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips");
		AutoTips.CheckEquipDurability();
	end
end

function MsgHandler.OnShowDeadTip()
	
	if(System.options.version == "teen") then
		-- close MsgHandler.OnShowDeadTip for teen version
		return;
	end

	if(not is_dead_tip_shown) then
		if(MyCompany.Aries.app:ReadConfig("is_dead_tip_shown")) then
			is_dead_tip_shown = true;
			return;
		else
			MyCompany.Aries.app:WriteConfig("is_dead_tip_shown", true);
			is_dead_tip_shown = true;
			_guihelper.MessageBox([[<div style="margin-top:24px;">你负伤了。别担心，待在小镇里就能自动回复体力。在怪物附近的路面上寻找小红球，也可以快速回血</div>]]);
		end
	end
end

function MsgHandler.OnLootableMobs(gained_lootable_mobs)
	--勇者之龙 逻辑已经废除
	--if(not gained_lootable_mobs) then
		--return;
	--end
	--local mob_keys = {};
	--local mob_key;
	--for mob_key in string.gmatch(gained_lootable_mobs, "[^#]+") do
		--mob_keys[mob_key] = mob_keys[mob_key] or 0;
		--mob_keys[mob_key] = mob_keys[mob_key] + 1;
	--end
	--local lootable_mobs = {};
	--local key, count;
	--for key, count in pairs(mob_keys) do
		--table.insert(lootable_mobs, {
			--type = key,
			--killed = count,
		--});
	--end
	--NPL.load("(gl)script/apps/Aries/NPCs/MagicSchool/30408_HeroDragonQuest.lua");
	--local HeroDragonQuest = commonlib.gettable("MyCompany.Aries.Quest.NPCs.HeroDragonQuest");
	--HeroDragonQuest.HandleCombat(lootable_mobs);
end

function MsgHandler.OnSyncHPFromServer(value)
	local hp_pts = tonumber(value);
	local SetCurrentHP = commonlib.getfield("MyCompany.Aries.Combat.MsgHandler.SetCurrentHP");
	if(SetCurrentHP) then
		SetCurrentHP(hp_pts);
	end
end

function MsgHandler.OnMyGainedAdditionalLoots(value)
	local type, remaining_count, MyGainedLoots_str = string_match(value, "^([^,]*),([^,]*)%[([^%[^%]]*)%]$");
	if(type and remaining_count and MyGainedLoots_str) then
		remaining_count = tonumber(remaining_count);
		
		NPL.load("(gl)script/apps/Aries/Combat/UI/AdditionalLootPage.lua")
		local AdditionalLootPage = commonlib.gettable("MyCompany.Aries.Combat.AdditionalLootPage");
		AdditionalLootPage.LootsHandle(type,remaining_count);

		MsgHandler.GainedLoots(MyGainedLoots_str, true);
	end
end

function MsgHandler.OnPlayMotion(value)
	local pos_x, pos_y, pos_z, motion_id, arena_mob_file, difficulty, stamina_cost, MyGainedLoots_str = string_match(value, "^([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),(%d*)%[([^%[^%]]*)%]$");
	if(pos_x and pos_y and pos_z and motion_id and arena_mob_file and difficulty and stamina_cost and MyGainedLoots_str) then
		pos_x = tonumber(pos_x);
		pos_y = tonumber(pos_y);
		pos_z = tonumber(pos_z);
		stamina_cost = tonumber(stamina_cost);

		-- play motion
		MotionXmlToTable.PlayCombatMotion(motion_id, function()
			-- show additional loot panel
			if(MyGainedLoots_str and MyGainedLoots_str ~= "") then
				if(System.options.version == "teen") then
					local notification_msg,arena_id = MsgHandler.GainedLoots(MyGainedLoots_str, true, true); -- true for bFromMyself and bTriggerAdditionalLootPanel
					-- NOTE: show additional loots
					NPL.load("(gl)script/apps/Aries/Combat/UI/AdditionalLootPage.lua")
					local AdditionalLootPage = commonlib.gettable("MyCompany.Aries.Combat.AdditionalLootPage");
					if(notification_msg and arena_id and arena_mob_file and difficulty and stamina_cost)then
						AdditionalLootPage.ShowPage(notification_msg, arena_id, arena_mob_file, difficulty, stamina_cost);
					end
				end
			end
		end, {
			pos_x = pos_x,
			pos_y = pos_y,
			pos_z = pos_z,
		});
	end
end

------------------------------------------------------------
--					Message Send Section
------------------------------------------------------------

-- send message to server
function MsgHandler.SendMessageToServer(msg)
	if(msg) then
		local client = MsgHandler.gslClient or Map3DSystem.GSL_client;
		if(client) then
			client:SendRealtimeMessage("sAriesCombat", {body = "[Aries][combat_to_server]"..msg});
		end
	end
end

-- dump arena data
-- @param arena_id: arena id
function MsgHandler.OnDumpArenaData(arena_id)
	MsgHandler.SendMessageToServer("DumpArenaData:"..arena_id);
end

-- get all cards
-- @param deck_struct: deck cards
-- @param equip_cards: equip cards
local function get_deck_cards_str(isInstance, isPvP)

	local deck_struct = MyCardsManager.GetLocalCombatBag();

	--local rune_struct = MyCardsManager.GetLocalRuneBag();
	local rune_struct = MyCardsManager.GetRuneList();
	local equip_cards = Combat.GetEquipCards() or {};
	local pet_cards = Combat.GetPetCards() or {};

	if(not deck_struct or not equip_cards or not pet_cards) then
		LOG.std("", "error","combat","get_deck_cards_str got invalid input: "..commonlib.serialize({deck_struct, equip_cards, pet_cards}));
		return;
	end
	local cards_str = "";
	local deck_struct_internal = {};
	local _, pair;
	for _, pair in pairs(deck_struct) do
		local gsid = pair.gsid;
		if(gsid > 0) then
			deck_struct_internal[gsid] = (deck_struct_internal[gsid] or 0) + 1;
		end
	end
	local gsid, count;
	for gsid, count in pairs(deck_struct_internal) do
		local key = Combat.Get_cardkey_from_gsid(gsid);
		if(key) then
			if(isInstance and instance_forbidden_keys[key]) then
				-- don't append card key
				LOG.std("", "error", "combat", "get_deck_cards_str cards_str got forbidden key: "..tostring(key));
			elseif(isPvP and pvp_forbidden_keys[key]) then
				-- don't append card key
				LOG.std("", "error", "combat", "get_deck_cards_str cards_str got forbidden key: "..tostring(key));
			else
				cards_str = cards_str..key..","..count.."+";
			end
		end
	end
	local runes_str = "";
	local _, pair;
	for _, pair in pairs(rune_struct) do
		if(pair.gsid > 0) then
			local key = Combat.Get_rune_cardkey_from_gsid(pair.gsid);
			if(key) then
				if(isInstance and instance_forbidden_keys[key]) then
					-- don't append card key
					LOG.std("", "error", "combat", "get_deck_cards_str runes_str got forbidden key: "..tostring(key));
				elseif(isPvP and pvp_forbidden_keys[key]) then
					-- don't append card key
					LOG.std("", "error", "combat", "get_deck_cards_str runes_str got forbidden key: "..tostring(key));
				else
					runes_str = runes_str..key.."+";
				end
			end
		end
	end
	local equip_cards_str = "";
	local gsid, count;
	for gsid, count in pairs(equip_cards) do
		local key = Combat.Get_cardkey_from_gsid(gsid);
		if(key) then
			if(isInstance and instance_forbidden_keys[key]) then
				-- don't append card key
				LOG.std("", "error", "combat", "get_deck_cards_str equip_cards_str got forbidden key: "..tostring(key));
			elseif(isPvP and pvp_forbidden_keys[key]) then
				-- don't append card key
				LOG.std("", "error", "combat", "get_deck_cards_str equip_cards_str got forbidden key: "..tostring(key));
			else
				equip_cards_str = equip_cards_str..key..","..count.."+";
			end
		end
	end
	local petcards_str = "";
	local gsid, count;
	for gsid, count in pairs(pet_cards) do
		local key = Combat.Get_cardkey_from_gsid(gsid);
		if(key) then
			if(isInstance and instance_forbidden_keys[key]) then
				-- don't append card key
				LOG.std("", "error", "combat", "get_deck_cards_str petcards_str got forbidden key: "..tostring(key));
			elseif(isPvP and pvp_forbidden_keys[key]) then
				-- don't append card key
				LOG.std("", "error", "combat", "get_deck_cards_str petcards_str got forbidden key: "..tostring(key));
			else
				petcards_str = petcards_str..key..","..count.."+";
			end
		end
	end
	return cards_str, equip_cards_str, runes_str, petcards_str;
	--"Fire_SingleAttack_Level1"
	--"Fire_SingleAttackWithDOT_Level2"
	--"Fire_SingleAttack_Level3"
	--return "Fire_SingleAttack_Level1,3+Fire_SingleAttackWithDOT_Level2,4+Fire_SingleAttack_Level3,2+Fire_SingleAttack_Level3,1+";
end

local function get_dragon_totem_str()
	local dragon_totem_str = "";
	--52 巨龙之“牙”、“爪”，“鳞”，“心”标记 儿童版第一次使用  
	--53 巨龙图腾经验值标记 儿童版第一次使用 
	local item_profession = ItemManager.GetItemByBagAndPosition(0, 52);
	local item_exp = ItemManager.GetItemByBagAndPosition(0, 53);
	if(item_profession and item_profession.guid ~= 0 and item_exp and item_exp.guid ~= 0) then
		dragon_totem_str = format("%d,%d,%d", item_profession.gsid, item_exp.gsid, item_exp.copies);
	elseif(item_profession and item_profession.guid ~= 0) then
		if(System.options.version == "kids" and item_profession.gsid and item_profession.gsid >= 50351 and item_profession.gsid <= 50354) then
			dragon_totem_str = format("%d,%d,%d", item_profession.gsid, 50359, 0);
		elseif(System.options.version == "teen" and item_profession.gsid and item_profession.gsid >= 50377 and item_profession.gsid <= 50385) then
			dragon_totem_str = format("%d,%d,%d", item_profession.gsid, 50389, 0);
		end
	end
	return dragon_totem_str;
end

function MsgHandler.get_deck_cards_str()
	return get_deck_cards_str();
end

-- get equiped deck gsid, 0 if invalid
local function get_equiped_deck_gsid()
	return Combat.GetEquipDeckGSID() or 0;
	--return 24004; --24004_CombatDeck_Level15_fire
end

-- get equiped armor gsid
-- NOTE: we only return the combat related items
local function get_equiped_armor_gsids_str()
	local gsids;
	if(System.options.version == "teen") then
		gsids = Combat.GetEquipArmorGSIDs_with_durability();
	else
		gsids = Combat.GetEquipArmorGSIDs();
	end
	local gsids_str = "";
	local _, gsid;
	for _, gsid in pairs(gsids) do
		gsids_str = gsids_str..gsid..","
	end
	return gsids_str;
	-- 1231_FireHat1
	-- 1241_FireSuit1
	-- 1251_FireBoot1
	-- 1261_FireBack1
	-- 1267_FireWand_5
	--return "1231,1241,1251,1261,1267,";
end

-- get equiped armor gem gsid
-- NOTE: we only return the combat related items
local function get_equiped_armor_gem_gsids_str()
	local gsids;
	if(System.options.version == "teen") then
		gsids = Combat.GetEquipArmorGemGSIDs_with_durability();
	else
		gsids = Combat.GetEquipArmorGemGSIDs();
	end
	local gsids_str = "";
	local _, gsid;
	for _, gsid in pairs(gsids) do
		gsids_str = gsids_str..gsid..","
	end
	return gsids_str;
end

MsgHandler.last_entercombat_pet_guid = nil;

-- auto recharge health point by eating HP portion. 
function MsgHandler.RechargeHealthPoint()
	if(MsgHandler.GetCurrentHP() >= MsgHandler.GetMaxHP()) then
		return;
	end
	-- 17155_HPPotion01
	local hasGSItem = ItemManager.IfOwnGSItem;
	local bHas, guid = hasGSItem(17155);
	if(bHas) then
		local item = ItemManager.GetItemByGUID(guid);
		if(item and item.guid > 0) then
			local gsItem = ItemManager.GetGlobalStoreItemInMemory(item.gsid);
			if(gsItem) then
				-- 44 HP_potion_pts(C) 补血药丸恢复的绝对血量
				local potion_absolute = gsItem.template.stats[44];
				-- 45 HP_potion_pts_percent(C) 补血药丸恢复的血量百分比 
				local potion_percent = gsItem.template.stats[45];
				Map3DSystem.Item.ItemManager.DestroyItem(item.guid, 1, function(msg) end);
				-- hard code the HealByWisp here, move to the game server in the next release candidate
				if(potion_percent and potion_percent > 0) then
					log("info: while entercombat HealByPotion from collectable reward "..potion_percent.."%%\n")
					MsgHandler.HealByWisp(potion_percent / 100, true); -- true for bForceProportion
				end
				if(potion_absolute and potion_absolute > 0) then
					log("info: while entercombat HealByPotion from collectable reward HP:"..potion_absolute.."\n")
					MsgHandler.HealByWisp(potion_absolute);
				end
			end
		end
	end
end

local OnEnterCombat_invoke_count = 0;

-- enter combat to arena id
-- @param arena_id: arena id
-- @param side: near or far
function MsgHandler.OnEnterCombat(arena_id, side)
	
	OnEnterCombat_invoke_count = OnEnterCombat_invoke_count + 1;

	-- TODO: get my health point
	local phase = Combat.GetSchool();
	-- get pet level
	local petCombatLevel = Combat.GetMyCombatLevel();

	local msghandler_getcurrenthp = MsgHandler.GetCurrentHP();
	if(not msghandler_getcurrenthp or msghandler_getcurrenthp <= 0) then
		LOG.std("", "warning", "combat", "warning: try enter combat with invalid current hp: %s", tostring(msghandler_getcurrenthp));
		MsgHandler.HealByWisp(1);
	end
	
	-- my follow pet
	-- position 32: follow pet position
	local myfollowpet_guid = 0;
	local item = ItemManager.GetItemByBagAndPosition(0, 32);
	if(item and item.guid ~= 0) then
		myfollowpet_guid = item.guid;
		MsgHandler.last_entercombat_pet_guid = myfollowpet_guid;
	end

	-- force update max hp
	MsgHandler.UpdateMaxHP();

	local loot_scale = AntiIndulgenceArea.GetLootScale();


	if(System.options.locale ~= "zhCN") then
		-- no loot scale for non zhCN locale
		loot_scale = 1;
	end

	local my_itemset_id = 0;
	
	NPL.load("(gl)script/apps/Aries/Team/TeamClientLogics.lua");
	local TeamClientLogics = commonlib.gettable("MyCompany.Aries.Team.TeamClientLogics");
	local leadernid = TeamClientLogics:GetTeamLeaderNid() or 0;

	local isInstance = false;
	local isPvP = false;
	if(WorldManager:IsInInstanceWorld()) then
		isInstance = true;
	end
	
	local arena_data = MsgHandler.Get_arena_data_by_id(arena_id);
	if(arena_data) then
		if(arena_data.mode == "free_pvp") then
			isPvP = true;
		end
	end

	local deck_cards_str, equip_cards_str, rune_str, petcards_str = get_deck_cards_str(isInstance, isPvP);

	local dragon_totem_str = get_dragon_totem_str();
	
	--local current_worlddir = ParaWorld.GetWorldDirectory();
	--if(current_worlddir == "worlds/MyWorlds/61HaqiTown/") then
		--if(deck_cards_str == "" and equip_cards_str == "") then
			--BroadcastHelper.PushLabel({id="nocard_equiped_tip", label = "携带法杖才能加入战斗", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
			--return;
		--end
	--end
	
	---- NOTE 2012/12/27: totally depracated
	-- use hp potion if player enter combat with less than 60% HP
	--local bCheckedAutoHPPotion = MyCompany.Aries.Player.LoadLocalData("AriesSettingsPage.checkBoxAutoHPPotion", true);
	--if(bCheckedAutoHPPotion and MsgHandler.GetCurrentHP() < MsgHandler.GetMaxHP() * 0.6) then
		--MsgHandler.RechargeHealthPoint();
	--end

	if(deck_cards_str == "") then
		if(System.options.version == "teen") then
			if(not BasicArena.IsInImmortalPosition()) then
				BasicArena.BecomeImmortal();
				_guihelper.MessageBox([[你没有携带卡牌不能参与战斗， 是否现在装备卡牌？]], function(res)
					if(res and res == _guihelper.DialogResult.Yes) then
						BasicArena.BecomeImmortal();
						NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/CombatCardManager.teen.lua");
						local MyCardsManager = commonlib.gettable("MyCompany.Aries.Inventory.Cards.MyCardsManager");	
						MyCardsManager.SetCombatCardPage();
						MyCardsManager.ShowPage();
					end
				end, _guihelper.MessageBoxButtons.YesNo);
			end
		else
			BroadcastHelper.PushLabel({id="nocard_equiped_tip", label = "你没有携带卡牌不能参与战斗", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
		end
		return;
	end
	
	local is_bag_too_heavy = Combat.IsOverWeight();
	if(is_bag_too_heavy) then
		BroadcastHelper.PushLabel({id="bagtooheavy", label = "背包物品太多, 战斗力减半！快整理下背包吧", max_duration=10000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
	end

	local is_follow_pet_joincombat = false;
	if(System.options.version == "teen") then
		NPL.load("(gl)script/apps/Aries/CombatPet/CombatFollowPetPane.lua");
		local CombatFollowPetPane = commonlib.gettable("MyCompany.Aries.CombatPet.CombatFollowPetPane");
		local bAutoFight = CombatFollowPetPane.IsAutoFight();
		is_follow_pet_joincombat = bAutoFight;
	end
	
	--if(System.options.version == "teen") then
		--if(OnEnterCombat_invoke_count == 1) then
			--local bShownAutoCombatPillTip = MyCompany.Aries.app:ReadConfig("bShownAutoCombatPillTip_11fdsa", false);
			--if(not bShownAutoCombatPillTip) then
				--MyCompany.Aries.app:WriteConfig("bShownAutoCombatPillTip_11fdsa", true);
				--ArrowPointer.ShowArrow(298676, 6, "_ctr", -50, 0, 64, 64);
			--end
		--end
	--end
	AutoCameraController:SaveCamera();
	NPL.load("(gl)script/ide/Director/CardMovieHelper.lua");
	local CardMovieHelper = commonlib.gettable("Director.CardMovieHelper");
	CardMovieHelper.ResetHoldCards();
	local msg = format("%d,%s,%d,%d,%d,%s,%d,%d,%d,%f,%d,%s,%s[%s][%s][%s][%s][%s][%s][%s]", 
		arena_id, side, petCombatLevel, 
		MsgHandler.GetCurrentHP(), MsgHandler.GetMaxHP(), 
		phase,
		get_equiped_deck_gsid(),
		myfollowpet_guid,
		my_itemset_id,
		loot_scale, 
		leadernid, 
		tostring(is_bag_too_heavy),
		tostring(is_follow_pet_joincombat),
		dragon_totem_str, 
		deck_cards_str, 
		equip_cards_str, 
		rune_str, 
		petcards_str, 
		get_equiped_armor_gsids_str(),
		get_equiped_armor_gem_gsids_str());

	MsgHandler.SendMessageToServer("ShallIEnterCombat:"..msg);

	NPL.load("(gl)script/kids/3DMapSystemUI/ScreenShot/app_main.lua");
	MyCompany.Apps.ScreenShot.ShowAllUI();
end

function MsgHandler.OnLootTreasureBox(arena_id)
	MsgHandler.SendMessageToServer("IWannaLootTreasureBox:"..arena_id);
end

-- user pick card
-- @param card_key: card key
-- @param card_seq: card sequence
-- @param isMob: true for mob, false for player
-- @param id: if isMob is true, mob_id,  if isMob is false, nid
function MsgHandler.OnPickCard(card_key, card_seq, isMob, id)
	local bContinue = true;
	if(MsgHandler.callback_after_card_pick) then
		bContinue = MsgHandler.callback_after_card_pick();
		-- reset the callback
		-- ver dirty code to have a chance to stop the combat network traffic
		MsgHandler.callback_after_card_pick = nil;
	end
	if(MsgHandler.callback_after_card_click) then
		MsgHandler.callback_after_card_click = nil;
	end
	if(bContinue) then
		if(card_key == "CatchPet") then
			MsgHandler.OnCatchPet(id);
			return;
		end
		MsgHandler.SendMessageToServer("IPickCardOnTarget:"..MsgHandler.current_seq.."+"..card_key.."+"..card_seq.."+"..tostring(isMob).."+"..id);
	end
end

-- user pick card
-- @param card_key: card key
-- @param card_seq: card sequence
-- @param isMob: true for mob, false for player
-- @param id: if isMob is true, mob_id,  if isMob is false, nid
function MsgHandler.OnCancelPickCardByPlayer()
	MsgHandler.SendMessageToServer("ICancelMyPickedCard:"..MsgHandler.current_seq);
end

-- on pick pet
-- @param item: follow pet item
function MsgHandler.OnPickPet(item)
	if(item and item.guid > 0) then
		-- pick the pet
		MsgHandler.SendMessageToServer("IPickMyPet:"..MsgHandler.current_seq.."+"..item.guid.."+"..item.gsid);
	end
end

-- user catch pet
-- @param id: mob_id
function MsgHandler.OnCatchPet(id)
	if(type(id) == "number") then
		MsgHandler.SendMessageToServer("CatchPetOnTarget:"..MsgHandler.current_seq.."+"..id);
	end
end

function MsgHandler.OnPass()
	local bContinue = true;
	if(MsgHandler.callback_after_pass) then
		bContinue = MsgHandler.callback_after_pass();
		-- reset the callback
		-- ver dirty code to have a chance to stop the combat network traffic
		MsgHandler.callback_after_pass = nil;
	end
	if(bContinue) then
		-- first hide card picker
		MsgHandler.HideCardPicker();
		-- hide target picker
		MsgHandler.HideTargetPicker();
		-- pick pass card
		-- hide the my runes page
		MsgHandler.HideMyRunesPage();	
		
		MsgHandler.OnPickCard("Pass", 0, false, 0);	
	end
end

function MsgHandler.HideMyRunesPage()
	if(MyCardsManager.my_runes_page) then
		MyCardsManager.my_runes_page:CloseWindow();
	end
end


-- get the max number of times that a player can automatically engage in a combat for free. 
function MsgHandler.GetMaxFreeAutoCombatCount()
	if(System.options.version == "teen") then
		return 0;
	else
		return 50;
	end
end

function MsgHandler.OnAuto()
	bAutoAIMode = true;

	if(System.options.version == "teen") then
		MsgHandler.SendMessageToServer("PickAICardForMe:"..MsgHandler.current_seq.."+false");
	else
		local bSkipCostAutoPill = false;
		local server_date = MyCompany.Aries.Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
		if(not MsgHandler.UsedFreeAutoPillCount) then
			MsgHandler.UsedFreeAutoPillCount = Player.LoadLocalData("UsedFreeAutoPillCount_"..server_date, 0);
		end
		if(MsgHandler.UsedFreeAutoPillCount < MsgHandler.GetMaxFreeAutoCombatCount()) then
			bSkipCostAutoPill = true;
		end
		MsgHandler.SendMessageToServer("PickAICardForMe:"..MsgHandler.current_seq.."+"..tostring(bSkipCostAutoPill));
	end

	BroadcastHelper.PushLabel({id="autocombat", label = "自动战斗开启中...", max_duration=5000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
end

function MsgHandler.OnFlee()
	-- check flee world
	local current_worlddir = ParaWorld.GetWorldDirectory();
	if(current_worlddir == "worlds/Instances/HaqiTown_RedMushroomArena/" or current_worlddir == "worlds/Instances/HaqiTown_LafeierCastle_PVP/") then
		local cards_at_hand = MsgHandler.CardPickerCardsAtHandList;
		local _, card;
		for _, card in pairs(cards_at_hand) do
			_guihelper.MessageBox([[<div style="margin-left:80px;margin-top:32px;">赛场不能逃跑!</div>]]);
			return;
		end
	end
	if(string.find(current_worlddir, "worlds/Instances/HaqiTown_TrialOfChampions")) then
		local cards_at_hand = MsgHandler.CardPickerCardsAtHandList;
		local _, card;
		for _, card in pairs(cards_at_hand) do
			_guihelper.MessageBox([[<div style="margin-left:80px;margin-top:32px;">试炼场不能逃跑!</div>]]);
			return;
		end
	end
	-- first hide card picker
	MsgHandler.HideCardPicker();
    -- hide target picker
    MsgHandler.HideTargetPicker();
    -- pick pass card
    MsgHandler.OnTryFlee();
	-- hide the my runes page
	MsgHandler.HideMyRunesPage();
end

-- user discard card
-- @param card_key: card key
-- @param card_seq: card sequence
function MsgHandler.OnDiscardCard(card_key, card_seq)
	MsgHandler.SendMessageToServer("IDiscardCard:"..MsgHandler.current_seq.."+"..card_key.."+"..card_seq);
end

-- user restore discarded card
-- @param card_key: card key
-- @param card_seq: card sequence
function MsgHandler.OnRestoreDiscardedCard(card_key, card_seq)
	MsgHandler.SendMessageToServer("IRestoreDiscardedCard:"..MsgHandler.current_seq.."+"..card_key.."+"..card_seq);
end

-- finished play turn, player finish playing the spell effects
function MsgHandler.OnFinishedPlayTurn(seq)
	MsgHandler.SendMessageToServer("IFinishedPlayTurn:"..seq);
	Cursor.UnlockCursor("default");
end

-- cancel my follow pet combat card
function MsgHandler.OnClickPassFollowPetCombatCard()
	MsgHandler.SendMessageToServer("CancelMyFollowPetPickedCard:"..MsgHandler.current_seq);
end

function MsgHandler.OnFollowPet_CombatMode()
	-- first hide card picker
	MsgHandler.HideCardPicker();
	-- hide target picker
	MsgHandler.HideTargetPicker();
	-- OnFollowPet_CombatMode msg
	MsgHandler.SendMessageToServer("OnFollowPet_CombatMode:"..MsgHandler.current_seq);
end

function MsgHandler.OnFollowPet_FollowMode()
	-- first hide card picker
	MsgHandler.HideCardPicker();
	-- hide target picker
	MsgHandler.HideTargetPicker();
	-- OnFollowPet_FollowMode msg
	MsgHandler.SendMessageToServer("OnFollowPet_FollowMode:"..MsgHandler.current_seq);
end

-- try to flee from combat
function MsgHandler.OnTryFlee()
	MsgHandler.SendMessageToServer("IWannaFlee:");
end

-- request additional loot
function MsgHandler.RequestAdditionalLootPlain(arena_id)
	if(arena_id) then
		MsgHandler.SendMessageToServer("RequestAdditionalLootPlain:"..tostring(arena_id));
	end
end
-- request additional loot
function MsgHandler.RequestAdditionalLootAdv(arena_id)
	if(arena_id) then
		MsgHandler.SendMessageToServer("RequestAdditionalLootAdv:"..tostring(arena_id));
	end
end

-- heart beat of the client
function MsgHandler.OnHeartBeat()
	local my_arena_data = MsgHandler.GetMyArenaData();
	if(my_arena_data) then
		MsgHandler.SendMessageToServer("HeartBeat:");
	end
end

-- mark debug point
function MsgHandler.OnMarkDebugPoint()
	MsgHandler.SendMessageToServer("MarkDebugPoint:");
end

-- check game server gear score
function MsgHandler.OnCheckMyGearScore()
	local my_set_id = 0;
	MsgHandler.SendMessageToServer("CheckMyGearScore:"..(my_set_id or 0));
end