--[[
Title: combat system object manager for Aries App
Author(s): WangTian
Date: 2009/4/7
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Combat/ObjectManager.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Scene/EffectManager.lua");
NPL.load("(gl)script/ide/AssetPreloader.lua");
NPL.load("(gl)script/ide/Debugger/NPLProfiler.lua");
NPL.load("(gl)script/apps/Aries/Player/BaseChar.lua");
NPL.load("(gl)script/apps/Aries/Scene/AutoCameraController.lua");
local AutoCameraController = commonlib.gettable("MyCompany.Aries.AutoCameraController");
local npl_profiler = commonlib.gettable("commonlib.npl_profiler");
local NPC = commonlib.gettable("MyCompany.Aries.Quest.NPC");
local ProfileManager = commonlib.gettable("Map3DSystem.App.profiles.ProfileManager");
local Player = commonlib.gettable("MyCompany.Aries.Player");
local Pet = commonlib.gettable("MyCompany.Aries.Pet");
local BaseChar = commonlib.gettable("MyCompany.Aries.BaseChar");
local EffectManager = commonlib.gettable("MyCompany.Aries.EffectManager");
local MsgHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");
local Scene = commonlib.gettable("MyCompany.Aries.Scene");
local OPC = commonlib.gettable("MyCompany.Aries.OPC");
local LOG = LOG;
local type = type;
local tonumber = tonumber
local table_insert = table.insert
local ParaScene_GetObject = ParaScene.GetObject;
-- create class
local ObjectManager = commonlib.gettable("MyCompany.Aries.Combat.ObjectManager");

NPL.load("(gl)script/ide/Effect/frozenEffect.lua");
local FrozenEffect = commonlib.gettable("MyCompany.Aries.FrozenEffect");
NPL.load("(gl)script/ide/Effect/transparentEffect.lua");
local TransparentEffect = commonlib.gettable("MyCompany.Aries.TransparentEffect");
NPL.load("(gl)script/ide/Effect/stoneEffect.lua");
local StoneEffect = commonlib.gettable("MyCompany.Aries.StoneEffect");

NPL.load("(gl)script/apps/Aries/Dialog/Headon_OPC.lua");
local Headon_OPC = commonlib.gettable("MyCompany.Aries.Dialog.Headon_OPC");

NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");

local base_arena_id_offset = 10000;

local slot_id_mount_id_offset = 19;

local maximum_buff_count = 12;

-- the sentient radius of arena mobs and the arena object itself. this is usually the same as the view radius
local mob_sentient_radius = 110;

-- the facing offset of the player to arena slot, otherwise the player will face the side of the arena center
local facing_offset_player_to_arenaslot = - math.pi / 2;
-- force isfreeze
local forceslots_isfreeze = {[35]=0};

-- record the charm ward and mini aura data
local buff_data = nil;

-- init charm and ward data from file
function ObjectManager.CreateGetCharmAndWardData()
	if(buff_data) then
		return buff_data;
	end
	buff_data = {
		charms = {},
		wards = {},
		miniauras = {},
		globalauras = {},
	};
	local config_file = "config/Aries/Cards/CharmWardList.xml";
	if(System.options.version == "teen") then
		config_file = "config/Aries/Cards/CharmWardList.teen.xml";
	else
		config_file = "config/Aries/Cards/CharmWardList.xml";
	end

	local xmlRoot = ParaXML.LuaXML_ParseFile(config_file);
	if(not xmlRoot) then
		commonlib.log("error: failed loading charm and ward data file: %s\n", config_file);
		return;
	end
	LOG.std(nil, "info", "ObjectManager", "ObjectManager loaded charm and ward data file: %s", config_file);
	-- check each charm data
	local each_charm;
	for each_charm in commonlib.XPath.eachNode(xmlRoot, "/list/charmlist/charm") do
		if(each_charm.attr) then
			local id = tonumber(each_charm.attr.id);
			local o = {};
			-- copy all attributes to charm data
			local key, value;
			for key, value in pairs(each_charm.attr) do
				if(key ~= "id") then
					if(value == "true") then
						o[key] = true;
					elseif(value == "false") then
						o[key] = false;
					else
						o[key] = tonumber(value) or value;
					end
				end
			end
			buff_data.charms[id] = o;
		end
	end
	-- check each ward data
	local each_ward;
	for each_ward in commonlib.XPath.eachNode(xmlRoot, "/list/wardlist/ward") do
		if(each_ward.attr) then
			local id = tonumber(each_ward.attr.id);
			local o = {};
			-- copy all attributes to ward data
			local key, value;
			for key, value in pairs(each_ward.attr) do
				if(key ~= "id") then
					if(value == "true") then
						o[key] = true;
					elseif(value == "false") then
						o[key] = false;
					else
						o[key] = tonumber(value) or value;
					end
				end
			end
			buff_data.wards[id] = o;
		end
	end
	-- check each mini aura data
	local each_miniaura;
	for each_miniaura in commonlib.XPath.eachNode(xmlRoot, "/list/miniauralist/miniaura") do
		if(each_miniaura.attr) then
			local id = tonumber(each_miniaura.attr.id);
			local o = {
				stats = {},
			};
			-- copy all attributes to ward data
			local key, value;
			for key, value in pairs(each_miniaura.attr) do
				if(key ~= "id" and key ~= "stats") then
					if(value == "true") then
						o[key] = true;
					elseif(value == "false") then
						o[key] = false;
					else
						o[key] = tonumber(value) or value;
					end
				end
			end
			local stat_section;
			for stat_section in string.gmatch(each_miniaura.attr.stats, "([^%(^%)]+)") do
				local stat_type, stat_value = string.match(stat_section, "^(.-),(.-)$");
				if(stat_type and stat_value) then
					stat_type = tonumber(stat_type);
					stat_value = tonumber(stat_value);
					if(stat_type and stat_value) then
						o.stats[stat_type] = stat_value;
					end
				end
			end
			buff_data.miniauras[id] = o;
		end
	end
	-- check each global aura data
	local each_globalaura;
	for each_globalaura in commonlib.XPath.eachNode(xmlRoot, "/list/globalauralist/globalaura") do
		if(each_globalaura.attr) then
			local id = tonumber(each_globalaura.attr.id);
			local o = {
				stats = {},
			};
			-- copy all attributes to ward data
			local key, value;
			for key, value in pairs(each_globalaura.attr) do
				if(key ~= "id" and key ~= "stats") then
					if(value == "true") then
						o[key] = true;
					elseif(value == "false") then
						o[key] = false;
					else
						o[key] = tonumber(value) or value;
					end
				end
			end
			local stat_section;
			for stat_section in string.gmatch(each_globalaura.attr.stats, "([^%(^%)]+)") do
				local stat_type, stat_value = string.match(stat_section, "^(.-),(.-)$");
				if(stat_type and stat_value) then
					stat_type = tonumber(stat_type);
					stat_value = tonumber(stat_value);
					if(stat_type and stat_value) then
						o.stats[stat_type] = stat_value;
					end
				end
			end
			buff_data.globalauras[id] = o;
		end
	end
	return buff_data;
end

function ObjectManager.SyncEssentialCombatResourceMini(callbackContinue)
	local loader = commonlib.AssetPreloader:new({
		callbackFunc = function(nItemsLeft, loader)
			if(nItemsLeft <= 0) then
				callbackContinue();
			end
		end
	});
	loader:AddAssets(ParaAsset.LoadStaticMesh("", "model/06props/v5/06combat/Common/Arena/HaqiTown_Basic.x"));
	loader:AddAssets(ParaAsset.LoadStaticMesh("", "model/06props/v5/06combat/Common/Arena/HaqiTown_Basic_teen.x"));
	loader:AddAssets(ParaAsset.LoadStaticMesh("", "model/06props/v5/06combat/Common/Slot/normal_slot.x"));
	loader:AddAssets(ParaAsset.LoadStaticMesh("", "model/06props/v5/06combat/Common/BuffSlots/common_buffslot.x"));
	loader:AddAssets(ParaAsset.LoadStaticMesh("", "model/06props/v5/06combat/Common/BuffSlots/common_buffslot_static.x"));
	loader:Start();
end

function ObjectManager.SyncEssentialCombatResource(callbackContinue)
	-- public world
	local loader = commonlib.AssetPreloader:new({
		callbackFunc = function(nItemsLeft, loader)
			log(nItemsLeft.." assets remaining\n")
			if(nItemsLeft <= 0) then
				callbackContinue();
			end
		end
	});
	--loader:AddAssets(ParaAsset.LoadParaX("", "character/v5/02animals/Ostrich/Ostrich.x"));
	loader:AddAssets(ParaAsset.LoadParaX("", "character/v3/PurpleDragonMajor/Female/PurpleDragonMajorFemale.xml"));
	loader:AddAssets(ParaAsset.LoadStaticMesh("", "model/06props/v5/06combat/Common/Arena/HaqiTown_Basic.x"));
	loader:AddAssets(ParaAsset.LoadStaticMesh("", "model/06props/v5/06combat/Common/Arena/HaqiTown_Basic_teen.x"));
	loader:AddAssets(ParaAsset.LoadStaticMesh("", "model/06props/v5/06combat/Common/Slot/normal_slot.x"));
	loader:AddAssets(ParaAsset.LoadStaticMesh("", "model/06props/v5/06combat/Common/Arena/HaqiTown_Basic_Life_teen.x"));
	loader:AddAssets(ParaAsset.LoadStaticMesh("", "model/06props/v5/06combat/Common/Arena/HaqiTown_Basic_Fire_teen.x"));
	loader:AddAssets(ParaAsset.LoadStaticMesh("", "model/06props/v5/06combat/Common/Arena/HaqiTown_Basic_Ice_teen.x"));
	loader:AddAssets(ParaAsset.LoadStaticMesh("", "model/06props/v5/06combat/Common/Arena/HaqiTown_Basic_Storm_teen.x"));
	loader:AddAssets(ParaAsset.LoadStaticMesh("", "model/06props/v5/06combat/Common/Arena/HaqiTown_Basic_Death_teen.x"));
	loader:Start();
end

function ObjectManager.GetArena_NPC_ID(arena_id)
	return base_arena_id_offset + arena_id;
end

function ObjectManager.GetArena_CameraView_NPC_ID(arena_id, isFarSide)
	if(isFarSide) then
		return (base_arena_id_offset + arena_id) * 10 + 100002;
	end
	return (base_arena_id_offset + arena_id) * 10 + 100000;
end

function ObjectManager.GetArena_TreasureBox_NPC_ID(arena_id)
	return (base_arena_id_offset + arena_id) * 10 + 100001;
end

function ObjectManager.GetArena_ID_From_TreasureBox_NPC_ID(treasurebox_npc_id)
	return (treasurebox_npc_id - 100001) / 10 - base_arena_id_offset;
end

function ObjectManager.GetSlot_NPC_ID(arena_id, slot_id)
	return (base_arena_id_offset + arena_id) * 10 + slot_id;
end

function ObjectManager.GetArena_Aura2_NPC_ID(arena_id)
	return (base_arena_id_offset + arena_id) * 10 + 100003;
end

-- @param buffslot_type: 0 for Charm, 1 for Ward, 2 for DoT and HoT, 3 for miniaura
function ObjectManager.GetBuffSlot_NPC_ID(arena_id, slot_id, buffslot_type)
	return (((base_arena_id_offset + arena_id) * 10 + slot_id) * 20) + buffslot_type;
end

-- @param pip_id: 1 ~ 7
function ObjectManager.GetPipSlot_NPC_ID(arena_id, slot_id, pip_id)
	return (((base_arena_id_offset + arena_id) * 10 + slot_id) * 20) + pip_id + 3;
end

-- @param sequence: from 1
function ObjectManager.GetBuff_Name(arena_id, slot_id, buffslot_id, sequence)
	-- NOTE: this causes the famous int bug, DON'T use calculations included large ints
	-- http://lua-users.org/wiki/FloatingPoint
	-- ObjectManager.GetBuff_Name(9991, 1, 1, 1) <-- "Buff_Name_99911104"
	-- ObjectManager.GetBuff_Name(9991, 1, 1, 2) <-- "Buff_Name_99911104"
	--return "Buff_Name_"..(arena_id*10000+slot_id*1000+buffslot_id*100+sequence);
	return "Buff_Name_"..tostring(arena_id)..(slot_id*1000+buffslot_id*100+sequence);
end

-- @param slot_id: slot id
function ObjectManager.GetFledSlot_Name(arena_id, slot_id)
	return "FledSlot_Name_"..(arena_id*10+slot_id);
end

-- mount player on slot
-- @param nid: player nid. 
-- @param player: this can be nil, in which case we will fetch by nid. otherwise we will use it directly which saves us one invocation.
function ObjectManager.MountPlayerOnSlot(nid, arena_id, slot_id, isByWalk, is_sentient, player, bMinion)
	nid = nid or 0;
	-- if the player is the user
	if(nid == ProfileManager.GetNID()) then
		
		if(System.User.nid == "localuser") then
			GameLogic.RunCommand("/hide desktop")
			GameLogic.ActivateNullContext()
			GameLogic.EntityManager.GetPlayer():FaceTarget(nil);
			GameLogic.Pause();
			ParaCamera.GetAttributeObject():SetField("EnableBlockCollision", false);	
		else
			-- enter movement freeze mode
			Player.EnterFreezeMoveMode();
			-- hide all desktop areas
			MyCompany.Aries.Desktop.HideAllAreas();
			-- close the local map if opened
			if(System.SystemInfo.GetField("name") == "Aries") then
				NPL.load("(gl)script/apps/Aries/Map/LocalMap.lua");
				MyCompany.Aries.Desktop.LocalMap.Hide();
			end
			-- show exp and hp bar
			NPL.load("(gl)script/apps/Aries/Desktop/EXPArea.lua");
			MyCompany.Aries.Desktop.EXPArea.Show();
			-- NPL.load("(gl)script/apps/Aries/Desktop/HPMyPlayerArea.lua");
			-- MyCompany.Aries.Desktop.HPMyPlayerArea.Show(true);
			MyCompany.Aries.Combat.UI.BattleChatArea.SetMode("combat");
			MyCompany.Aries.Combat.UI.BattleChatArea.Show(true);
			-- enter jump freeze mode
			Player.EnterFreezeJumpMode();
			-- enter freeze reverse mode, (left shift)
			MyCompany.Aries.EnterFreezeReverseMode();
		end
		
		-- player object
		player = player or Player.GetPlayerObject();
		if(player:IsValid()) then
			-- make it OPC movement style
			player:SetField("MovementStyle", 4)
			player:SetField("normal", {0,1,0}); -- force normal to be upward
			player:SetField("SkipPicking", false);
			Player.GetDriverObject():SetField("SkipPicking", true);
		end
		MyCompany.Aries.Player.SetFreezed(false); -- LXZ: is it necessary here?
	end
	
	-- set local
	BaseChar.SetLocal(nid);

	-- player object
	if(type(nid) == "number") then
		if(nid < 0) then
			player = player or ParaScene_GetObject(-nid.."+followpet");
			player:SetField("Speed Scale", 1);
		else
			player = player or ParaScene_GetObject(tostring(nid));
		end
	elseif(nid == "localuser") then
		player = GameLogic.EntityManager.GetPlayer():GetInnerObject()
	end

	if(player:IsValid()) then
		local is_already_in_combat = player:GetDynamicField("IsInCombat", false);
		if(is_sentient or not is_already_in_combat) then
			-- only mount to xref if sentient or we have never mount it before.  
			local arena_model = NPC.GetNpcModelFromIDAndInstance(ObjectManager.GetArena_NPC_ID(arena_id));
			if(arena_model) then
				local nXRefCount = arena_model:GetXRefScriptCount();
				local toX, toY, toZ = arena_model:GetXRefScriptPosition(slot_id - 1);
				local facing = arena_model:GetXRefScriptFacing(slot_id - 1) + facing_offset_player_to_arenaslot;

				isByWalk = false;
				
				if(type(nid) == "number" and nid < 0 and ProfileManager.GetNID() == -nid) then
					-- walk to the slot position. 
					if(not is_already_in_combat) then
						local host_player = ParaScene_GetObject(tostring(-nid));
						local fromX, fromY, fromZ = host_player:GetPosition();
						player:SetPosition(fromX, fromY, fromZ);
					
						-- local fromX, fromY, fromZ = player:GetPosition();
						local dX, dY, dZ = toX - fromX, toY - fromY, toZ - fromZ;
						-- only walk if it is within 30 meters 
						if(math.abs(dX + dY + dZ) > 0.1) then
							player:ToCharacter():MoveAndTurn(dX, dY, dZ, facing);
						else
							player:SetPosition(toX, toY, toZ);
							player:SetFacing(facing);
						end
					end
				else
					player:SetPosition(toX, toY, toZ);
					player:UpdateTileContainer();
					player:SetFacing(facing);
				end
				
				-- echo({ProfileManager.GetNID(), nid, toX, toY, toZ, "11111111111111111111111"})
			end
		end

		if(not is_already_in_combat) then
			-- make avatar immune to ice freeze
			player:SetDynamicField("IsImmuneToIceFreeze", true);
			-- force mount dragon
			player:SetDynamicField("ForceMountDragon", true);
			-- mark as in combat
			player:SetDynamicField("IsInCombat", true);
		end

		local arena_data = MsgHandler.Get_arena_data_by_id(arena_id);
		if(arena_data) then
			if(player:GetDynamicField("IsHiddenDisplayName", false)) then
				if(not arena_data.bIncludedMyselfInArena) then
					if(is_sentient) then
						player:SetDynamicField("IsHiddenDisplayName", false);
						-- show head on text
						Player.ShowHeadonTextForNID(nid, player);
					end
				end
			else
				if(arena_data.bIncludedMyselfInArena) then
					player:SetDynamicField("IsHiddenDisplayName", true);
					-- hide head on text
					Player.ShowHeadonTextForNID(nid, player);
				end
			end
		end

		if(is_sentient) then
			-- 35 stands for isfreeze force the user to unfreeze
			if(not bMinion and type(nid) == "number" and nid > 0) then
				Pet.RefreshOPC_CCS(nid, forceslots_isfreeze);
			end
		end
		--BaseChar.MountOn({nid = nid, model = arena_model, slot_index = (slot_id_mount_id_offset + slot_id)});
	end
end

-- unmount player from slot
-- @param nid: player nid. 
-- @param player: this can be nil, in which case we will fetch by nid. otherwise we will use it directly which saves us one invocation.
function ObjectManager.UnMountPlayerFromSlot(nid, is_sentient, player, bMinion)
	
	-- if the player is the user
	if(nid == ProfileManager.GetNID()) then
		if(System.User.nid~="localuser") then
			-- leave movement freeze mode
			Player.LeaveFreezeMoveMode();
			-- show all desktop areas
			MyCompany.Aries.Desktop.ShowAllAreas();
			-- leave jump freeze mode
			Player.LeaveFreezeJumpMode();
			-- leave freeze reverse mode, (left shift)
			MyCompany.Aries.LeaveFreezeReverseMode();
		end
		-- player object
		player = player or Player.GetPlayerObject();
		if(player and player:IsValid()) then
			-- make it normal movement style
			player:SetField("MovementStyle", 0)
			player:SetField("SkipPicking", true);
			Player.GetDriverObject():SetField("SkipPicking", true);
		end
		AutoCameraController:RestoreCamera();
		if(System.User.nid=="localuser") then
			ParaCamera.GetAttributeObject():SetField("EnableBlockCollision", true);	
			GameLogic.Resume();
			GameLogic.RunCommand("/show desktop")
			GameLogic.ActivateDefaultContext()
		end
	end

	-- set unlocal
	BaseChar.SetUnLocal(nid);

	-- remove all auto combat mark
	Headon_OPC.ChangeHeadonMark(nid, "");

	-- player object
	if(type(nid) == "number" and nid < 0) then
		player = player or ParaScene_GetObject(-nid.."+followpet");

		-- when player is set to initial player position
		local _target = ParaScene_GetObject(tostring(-nid));
		local x, y, z = _target:GetPosition();
		player:SetPosition(x, y, z);
		player:UpdateTileContainer();
	elseif(nid == "localuser") then
		local entity = GameLogic.EntityManager.GetPlayer();
		player = entity and entity:GetInnerObject();
	elseif(nid) then
		player = player or ParaScene_GetObject(tostring(nid));
	end
	if(player and player:IsValid()) then
		-- make avatar not immune to ice freeze
		player:SetDynamicField("IsImmuneToIceFreeze", false);
		-- reset ForceMountDragon
		player:SetDynamicField("ForceMountDragon", false);
		-- mark as not in combat
		player:SetDynamicField("IsInCombat", false);

		if(player:GetDynamicField("IsHiddenDisplayName", true)) then
			-- make display name visible
			player:SetDynamicField("IsHiddenDisplayName", false);
			Player.ShowHeadonTextForNID(nid, player)
		end

		if(nid and (tonumber(nid) or 0) > 0) then
			if(is_sentient) then
				if(not bMinion) then
					Pet.RefreshOPC_CCS(nid, nil);
				end
			end
		
			local anim_obj = ParaScene.GetObject(player.name);
			if(anim_obj and anim_obj:IsValid() == true) then
				FrozenEffect.ResetEffect(anim_obj);
			end
			local anim_obj_mount = ParaScene.GetObject(player.name.."+driver");
			if(anim_obj_mount and anim_obj_mount:IsValid() == true) then
				FrozenEffect.ResetEffect(anim_obj_mount);
			end
		end
	end

	--BaseChar.UnMount({
		--nid = nid, 
		---- position = {x = , y = , z = }, -- skip the unmount position
	--});
	--MyCompany.Aries.Pet.LeaveIndoorMode(nid);
end

-- mount npc object on slot
function ObjectManager.MountNPCOnSlot(npc_id, instance, arena_id, slot_id, isByWalk)
	local arena_npc_id = ObjectManager.GetArena_NPC_ID(arena_id);
	local NPC = NPC;
	local arena_model = NPC.GetNpcModelFromIDAndInstance(arena_npc_id);
	if(arena_model) then
		local npcChar = NPC.GetNpcCharacterFromIDAndInstance(npc_id, instance);
		if(npcChar) then
			local arena_model = NPC.GetNpcModelFromIDAndInstance(ObjectManager.GetArena_NPC_ID(arena_id));
			if(arena_model) then
				local toX, toY, toZ = arena_model:GetXRefScriptPosition(slot_id - 1);
				local facing = arena_model:GetXRefScriptFacing(slot_id - 1) + facing_offset_player_to_arenaslot;
				npcChar:SetPosition(toX, toY, toZ);
				npcChar:SetField("normal", {0,1,0}); -- force normal to be upward
				npcChar:UpdateTileContainer();
				npcChar:SetFacing(facing);
				-- mark the npc character is in combat
				-- npcChar:SetDynamicField("IsInCombat", true);
			end
		end
		--BaseChar.MountOn({nid = nid, model = arena_model, slot_index = (slot_id_mount_id_offset + slot_id)});
	end
end

-- unmount npc object from slot
function ObjectManager.UnMountNPCFromSlot(npc_id, instance)
	local npcChar = NPC.GetNpcCharacterFromIDAndInstance(npc_id, instance);
	if(npcChar and npcChar:IsValid() == true) then
		FrozenEffect.ResetEffect(npcChar);
	end
end

-- @param arena_id: arena id
-- @return: x, y, z
function ObjectManager.GetArenaCenter(arena_id)
	local arena_model = NPC.GetNpcModelFromIDAndInstance(ObjectManager.GetArena_NPC_ID(arena_id));
	if(arena_model) then
		return arena_model:GetPosition();
	end
end

-- basic arena assets
local BasicArenaAssets = {
	["life"] = "model/06props/v5/06combat/Common/Arena/HaqiTown_Basic_Life_teen.x",
	["fire"] = "model/06props/v5/06combat/Common/Arena/HaqiTown_Basic_Fire_teen.x",
	["ice"] = "model/06props/v5/06combat/Common/Arena/HaqiTown_Basic_Ice_teen.x",
	["storm"] = "model/06props/v5/06combat/Common/Arena/HaqiTown_Basic_Storm_teen.x",
	["death"] = "model/06props/v5/06combat/Common/Arena/HaqiTown_Basic_Death_teen.x",
};

-- @param arena_id: arena id
-- @return: asset x file path
function ObjectManager.GetBasicArenaAsset(arena_id)
	if(System.options.version == "teen") then
		local arena_data = MsgHandler.Get_arena_data_by_id(arena_id);
		if(arena_data) then
			local appearance = arena_data.appearance;
			local current_worlddir = ParaWorld.GetWorldDirectory();
			if(current_worlddir) then
				local current_worlddir_lower = string.lower(current_worlddir);
				if(current_worlddir_lower) then
					if(string.find(current_worlddir_lower, "61haqitown")) then
						return BasicArenaAssets[appearance or "life"];
					elseif(string.find(current_worlddir_lower, "flamingphoenixisland")) then
						return BasicArenaAssets[appearance or "fire"];
					elseif(string.find(current_worlddir_lower, "frostroarisland")) then
						return BasicArenaAssets[appearance or "ice"];
					elseif(string.find(current_worlddir_lower, "ancientegyptisland")) then
						return BasicArenaAssets[appearance or "storm"];
					elseif(string.find(current_worlddir_lower, "darkforestisland")) then
						return BasicArenaAssets[appearance or "death"];
					elseif(string.find(current_worlddir_lower, "cloudfortressisland")) then
						return BasicArenaAssets[appearance or "life"];
					end
				end
			end
		end
		return "model/06props/v5/06combat/Common/Arena/HaqiTown_Basic_teen.x";
	end
	if(System.options.is_mcworld) then
		return "model/06props/v5/06combat/Common/Arena/HaqiTown_Basic_teen.x";
	end
	return "model/06props/v5/06combat/Common/Arena/HaqiTown_Basic.x";
end

-- sequence arrow assets
local SequenceArrowAssets = {
	["life"] = "model/06props/v5/06combat/Common/SequenceArrow/sequence_arrow_Life_teen.x",
	["fire"] = "model/06props/v5/06combat/Common/SequenceArrow/sequence_arrow_Fire_teen.x",
	["ice"] = "model/06props/v5/06combat/Common/SequenceArrow/sequence_arrow_Ice_teen.x",
	["storm"] = "model/06props/v5/06combat/Common/SequenceArrow/sequence_arrow_Storm_teen.x",
	["death"] = "model/06props/v5/06combat/Common/SequenceArrow/sequence_arrow_Death_teen.x",
};

-- @param arena_id: arena id
-- @return: asset x file path
function ObjectManager.GetSequenceArrowAsset(arena_id)
	if(System.options.version == "teen") then
		local arena_data = MsgHandler.Get_arena_data_by_id(arena_id);
		if(arena_data) then
			local appearance = arena_data.appearance;
			local current_worlddir = ParaWorld.GetWorldDirectory();
			if(current_worlddir) then
				local current_worlddir_lower = string.lower(current_worlddir);
				if(current_worlddir_lower) then
					if(string.find(current_worlddir_lower, "61haqitown")) then
						return SequenceArrowAssets[appearance or "life"];
					elseif(string.find(current_worlddir_lower, "flamingphoenixisland")) then
						return SequenceArrowAssets[appearance or "fire"];
					elseif(string.find(current_worlddir_lower, "frostroarisland")) then
						return SequenceArrowAssets[appearance or "ice"];
					elseif(string.find(current_worlddir_lower, "ancientegyptisland")) then
						return SequenceArrowAssets[appearance or "storm"];
					elseif(string.find(current_worlddir_lower, "darkforestisland")) then
						return SequenceArrowAssets[appearance or "death"];
					end
				end
			end
		end
		return "model/06props/v5/06combat/Common/SequenceArrow/sequence_arrow_teen.x";
	end
	return "model/06props/v5/06combat/Common/SequenceArrow/sequence_arrow.x";
end

-- play animation of the arena model platform floating upwards
-- turn on and off visibility of the arena model platform according to whether there are players on it. 
-- @param arena_id: number
-- @param arena_meta: if nil, it will be fetched. 
-- @param force_invisible: if true it will force invisible even there is player on it. This is true when arena is out of sentient. 
function ObjectManager.UpdateArenaPlatformModel(arena_id, arena_meta, force_invisible)
	arena_meta = arena_meta or MsgHandler.Get_arena_meta_data_by_id(arena_id);
	local force_name = "Aries_Combat_Arena_"..arena_id;

	if(arena_meta.mode ~= "pve") then
		if(not EffectManager.IsEffectValid(force_name)) then
			-- always shown arena effect
			local params = {
				asset_file = ObjectManager.GetBasicArenaAsset(arena_id),
				ismodel = true,
				binding_obj_name = nil,
				start_position = {arena_meta.p_x, arena_meta.p_y, arena_meta.p_z},
				duration_time = 999999999,
				scaling = 1,
				force_name = force_name,
			};
			EffectManager.CreateEffect(params);
			if(arena_meta.mode == "free_pvp") then
				NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
				local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
				local world_info = WorldManager:GetCurrentWorld();
				local pvp_layer_y = arena_meta.p_y;
				if(System.options.version == "teen") then
					pvp_layer_y = pvp_layer_y + 0.3;
				end
				if(world_info.team_mode ~= "battlefield") then
					-- always shown pvp arena slot color effect
					local force_name_color_effect = "Aries_Combat_Arena_"..arena_id.."_color_effect";
					local asset_file = "model/06props/v5/06combat/Common/Arena/HaqiTown_Basic_PVP.x";
					if(System.options.version == "teen") then
						asset_file = "model/06props/v5/06combat/Common/Arena/HaqiTown_Basic_PVP_teen.x";
					end
					local params = {
						asset_file = asset_file,
						ismodel = true,
						binding_obj_name = nil,
						start_position = {arena_meta.p_x, pvp_layer_y, arena_meta.p_z},
						duration_time = 999999999,
						scaling = 1,
						force_name = force_name_color_effect,
					};
					EffectManager.CreateEffect(params);
				else
					NPL.load("(gl)script/apps/Aries/Combat/Battlefield/BattlefieldClient.lua");
					local BattlefieldClient = commonlib.gettable("MyCompany.Aries.Battle.BattlefieldClient");
					local my_side = BattlefieldClient.my_side;
					if(my_side == 0) then
						-- always shown pvp arena slot color effect
						local force_name_color_effect = "Aries_Combat_Arena_"..arena_id.."_color_effect";
						local params = {
							asset_file = "model/06props/v5/06combat/Common/Arena/HaqiTown_Basic_PVP_battlefield.x",
							ismodel = true,
							binding_obj_name = nil,
							start_position = {arena_meta.p_x, pvp_layer_y, arena_meta.p_z},
							duration_time = 999999999,
							scaling = 1,
							facing = math.pi,
							force_name = force_name_color_effect,
						};
						EffectManager.CreateEffect(params);
					elseif(my_side == 1) then
						-- always shown pvp arena slot color effect
						local force_name_color_effect = "Aries_Combat_Arena_"..arena_id.."_color_effect";
						local params = {
							asset_file = "model/06props/v5/06combat/Common/Arena/HaqiTown_Basic_PVP_battlefield.x",
							ismodel = true,
							binding_obj_name = nil,
							start_position = {arena_meta.p_x, pvp_layer_y, arena_meta.p_z},
							duration_time = 999999999,
							scaling = 1,
							force_name = force_name_color_effect,
						};
						EffectManager.CreateEffect(params);
					end
				end
			end
		end
	elseif(arena_meta.bIncludedAnyPlayer and not force_invisible) then
		if(not EffectManager.IsEffectValid(force_name)) then
			-- rising effect
			local params = {
				asset_file = ObjectManager.GetBasicArenaAsset(arena_id),
				ismodel = true,
				binding_obj_name = nil,
				start_position = {arena_meta.p_x, arena_meta.p_y, arena_meta.p_z},
				duration_time = 999999999,
				scaling = 1,
				force_name = force_name,
				begin_callback = function() 
				end,
				end_callback = function() 
				end,
				--elapsedtime_callback = function(elapsedTime, obj) 
					--if(elapsedTime < 1000) then
						--obj:SetPosition(arena_meta.p_x, arena_meta.p_y - 1 + elapsedTime / 1000, arena_meta.p_z);
					--end
				--end,
			};
			EffectManager.CreateEffect(params);
			-- play spell file
			if(System.options.version == "teen") then
				NPL.load("(gl)script/apps/Aries/Combat/SpellPlayer.lua");
				local SpellPlayer = commonlib.gettable("MyCompany.Aries.Combat.SpellPlayer");
				local spell_file = "config/Aries/Spells/Arena_EnterCombat_teen.xml";
				local caster = {isPlayer = true, nid = ProfileManager.GetNID()};
				SpellPlayer.PlaySpellEffect_single(arena_id, caster, caster, spell_file, {{0}}, nil, function()
				end, true, nil, nil, nil, nil, nil, true); -- true for bSkipAutoTargetEffect
			end
		end
	else
		-- remove the effect immediately
		EffectManager.DestroyEffect(force_name);
	end
end

-- Create arena model, slots, mobs, etc in the scene. 
-- this function will set arena_meta.is_arena_obj_created to true, so that we only need to call this function once for each 3d world.
-- @param arena_id: the arena id
-- @param params: the arena params, including: x, y, z, facing, scaling
-- @param bForceVisible: force the arena model object to be visible, this is only used for Taurus project
function ObjectManager.CreateArenaObj(arena_id, params, bForceVisible, bMovieArena)
	npl_profiler.perf_begin("CreateArenaObj")

	local arena_meta;
	-- some meta data about the arena. 
	if(not SystemInfo.GetField("name") == "Taurus") then -- for taurus only
		arena_meta = MsgHandler.Get_arena_meta_data_by_id(arena_id);
		arena_meta.is_arena_obj_created = true;
	end

	-- create arena object if not exist
	local NPC = NPC;
	local arena_char, arena_model = NPC.GetNpcCharModelFromIDAndInstance(ObjectManager.GetArena_NPC_ID(arena_id));
	if(not arena_model) then
		local scaling = 1;
		local world_info = WorldManager:GetCurrentWorld();
		if(world_info and world_info.enter_combat_range) then
			scaling = world_info.enter_combat_range / math.ceil(math.sqrt(350));
		end

		-- arena entity
		local params = {
			position = {params.x, params.y, params.z},
			assetfile_char = "character/v5/09effect/Combat_Common/CombatArea/CombatArea_entercombat.x",skiprender_char = true,
			assetfile_model = ObjectManager.GetBasicArenaAsset(arena_id),
			--assetfile_model = "model/01building/v5/01house/SkyWheel/SkyWheel.x",
			--assetfile_model = "model/06props/v5/06combat/Common/Slot/normal_slot.x",
			facing = params.facing or 0,
			scaling = 1,
			scale_char = scaling,
			main_script = "script/apps/Aries/NPCs/Combat/39000_BasicArena.lua",
			main_function = "MyCompany.Aries.Quest.NPCs.BasicArena.main();",
			predialog_function = "MyCompany.Aries.Quest.NPCs.BasicArena.PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			PerceptiveRadius = 0,
			SentientRadius = mob_sentient_radius,
			FrameMoveInterval = 400,
			timer_period = 500,
		};
		
		local world_info = WorldManager:GetCurrentWorld();
		if(world_info.name == "61HaqiTown_teen" or world_info.name == "NewUserIsland") then
			params.assetfile_char = "character/v5/09effect/Combat_Common/CombatArea/CombatArea_entercombat_withtext.x";
		elseif(world_info.name == "Tutorial" or world_info.name == "CombatTutorial" or world_info.name == "CombatPipTutorial") then
			params.assetfile_char = "character/common/dummy/elf_size/elf_size.x";
		end

		if(bMovieArena) then
			-- NOTE: this indicates the arena is a non-combatable arena, such as movie play arena
			params.assetfile_char = "character/common/dummy/elf_size/elf_size.x";
		end

		arena_char, arena_model = NPC.CreateNPCCharacter(ObjectManager.GetArena_NPC_ID(arena_id), params);
		-- NPC.CreateTimer("BasicArena", "MyCompany.Aries.Quest.NPCs.BasicArena.On_Timer();", params.timer_period);

		if(arena_char) then
			arena_char:SetField("On_EnterSentientArea", string.format([[;MyCompany.Aries.Quest.NPCs.BasicArena.On_EnterSentientArea(%d);]], arena_id));
			arena_char:SetField("On_LeaveSentientArea", string.format([[;MyCompany.Aries.Quest.NPCs.BasicArena.On_LeaveSentientArea(%d);]], arena_id));
			arena_char:SetField("On_FrameMove", string.format([[;MyCompany.Aries.Quest.NPCs.BasicArena.On_FrameMove(%d);]], arena_id));
			-- skip picking
			arena_char:SetField("SkipPicking", true);
		end

		if(arena_model) then
			if(not bForceVisible) then
				arena_model:SetVisible(false);
			end
			if(params.bIncludedAnyPlayer) then
				arena_model:EnablePhysics(true);
			else
				arena_model:EnablePhysics(false);
			end
		end
	end

	-- Note by LXZ: shall we create following only in view range?
	local arena_char = NPC.GetNpcCharacterFromIDAndInstance(ObjectManager.GetArena_CameraView_NPC_ID(arena_id));
	if(not arena_char) then
		
		local eye_x = params.x - 20057.634765625 + 20057.703125;
		local eye_y = params.y - 0.44960099458694 + 3.2235388755798;
		local eye_z = params.z - 19731.861328125 + 19741.373046875;
		-- arena entity
		local params = {
			position = {eye_x, eye_y, eye_z},
			assetfile_char = "character/common/dummy/elf_size/elf_size.x",skiprender_char = true,
			--assetfile_model = "model/01building/v5/01house/SkyWheel/SkyWheel.x",
			--assetfile_model = "model/06props/v5/06combat/Common/Slot/normal_slot.x",
			facing = params.facing or 0,
			scaling = 0.0001,
			isdummy = true,
		};
		NPC.CreateNPCCharacter(ObjectManager.GetArena_CameraView_NPC_ID(arena_id), params);
	end
	local arena_char = NPC.GetNpcCharacterFromIDAndInstance(ObjectManager.GetArena_CameraView_NPC_ID(arena_id, true));
	if(not arena_char) then
		
		local eye_x = params.x - 20057.634765625 + 20057.703125;
		local eye_y = params.y - 0.44960099458694 + 3.2235388755798;
		local eye_z = params.z + 19731.861328125 - 19741.373046875; -- reversed arena side camera
		-- arena entity
		local params = {
			position = {eye_x, eye_y, eye_z},
			assetfile_char = "character/common/dummy/elf_size/elf_size.x",skiprender_char = true,
			--assetfile_model = "model/01building/v5/01house/SkyWheel/SkyWheel.x",
			--assetfile_model = "model/06props/v5/06combat/Common/Slot/normal_slot.x",
			facing = params.facing or 0,
			scaling = 0.0001,
			isdummy = true,
		};
		NPC.CreateNPCCharacter(ObjectManager.GetArena_CameraView_NPC_ID(arena_id, true), params);
	end
	
	
	-- Note by LXZ: shall we create following only in view range?
	-- slot entity
	if(arena_model) then
		local nXRefCount = arena_model:GetXRefScriptCount();
		
		local i = 0;
		local toX, toY, toZ;
		
		for i = 0, nXRefCount - 2 do
			toX, toY, toZ = arena_model:GetXRefScriptPosition(i);
			
			local slot_id = i + 1;
			
			local slot_model = NPC.GetNpcModelFromIDAndInstance(ObjectManager.GetSlot_NPC_ID(arena_id, slot_id));
			if(not slot_model) then
				local params = {
					position = {toX, toY, toZ},
					assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
					--assetfile_model = ObjectManager.GetBasicArenaAsset(arena_id),
					--assetfile_model = "model/01building/v5/01house/SkyWheel/SkyWheel.x",
					assetfile_model = "model/06props/v5/06combat/Common/Slot/normal_slot.x",
					facing = arena_model:GetXRefScriptFacing(i),
					--name = tostring(slot_id),
					--scaling = 4,
					scale_char = 0.00001,
					scaling_model = 1,
					isdummy = true,
				};
				local _;
				_, slot_model = NPC.CreateNPCCharacter(ObjectManager.GetSlot_NPC_ID(arena_id, slot_id), params);
			end
			
			if(slot_model) then
				local nXRefCount = slot_model:GetXRefScriptCount();
				
				local ii = 0;
				local toX_slot, toY_slot, toZ_slot;
				
				--for ii = 0, 2 do
				for ii = 0, 3 do
					local xref_id = ii;
					if(ii == 3) then -- mini aura
						xref_id = 2;
					end
					toX_slot, toY_slot, toZ_slot = slot_model:GetXRefScriptPosition(xref_id);
					local buffslot_id = ii;
					
					local buffslot_npcid = ObjectManager.GetBuffSlot_NPC_ID(arena_id, slot_id, buffslot_id)
					local model_buffslot = NPC.GetNpcModelFromIDAndInstance(buffslot_npcid);
					if(not model_buffslot) then
						local scaling_model = params.scaling or 0.5;
						local assetfile_model = "model/06props/v5/06combat/Common/BuffSlots/common_buffslot.x";
						local params = {
							position = {toX_slot, toY_slot, toZ_slot},
							assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
							--assetfile_char = "character/v5/09effect/Combat_Common/BuffSlots/charm_buffslot.x",
							assetfile_model = assetfile_model,
							--assetfile_model = ObjectManager.GetBasicArenaAsset(arena_id),
							--assetfile_model = "model/01building/v5/01house/SkyWheel/SkyWheel.x",
							--assetfile_model = "model/06props/v5/06combat/Common/Slot/normal_slot.x",
							facing = slot_model:GetXRefScriptFacing(i),
							name = "",
							scale_char = 0.00001,
							scaling_model = scaling_model,
							isdummy = true,
						};
						if(ii == 3) then -- mini aura
							params.position = {toX_slot, toY, toZ_slot}; -- use slot base positin as miniaura position
							params.scaling_model = 0.00001;
							params.assetfile_model = "model/06props/v5/06combat/Common/BuffSlots/common_buffslot_static.x";
						end
						local char_buffslot, model_buffslot = NPC.CreateNPCCharacter(ObjectManager.GetBuffSlot_NPC_ID(arena_id, slot_id, buffslot_id), params);
						model_buffslot:SetField("AnimID", 4);
					end
				end
			end
			
		end
	end

	npl_profiler.perf_end("CreateArenaObj")
end

function ObjectManager.DestroyAllArenaAndMobs()	
	for key, arena_data in pairs(MsgHandler.Get_arena_key_valuedata_pairs() or {}) do
		if(arena_data.arena_id) then
			ObjectManager.DestroyArenaObj(arena_data.arena_id)
		end
	end
	
	for id, mob in pairs(MsgHandler.Get_mob_id_valuedata_pairs() or {}) do
		NPC.DeleteNPCCharacter(39001, id);
	end
end

function ObjectManager.DestroyArenaObj(arena_id)
	local NPC = NPC;
	
	local arena_model = NPC.GetNpcModelFromIDAndInstance(ObjectManager.GetArena_NPC_ID(arena_id));
	if(arena_model) then
		local nXRefCount = arena_model:GetXRefScriptCount();
		
		local i = 0;
		local toX, toY, toZ;
		
		for i = 0, nXRefCount - 2 do
			toX, toY, toZ = arena_model:GetXRefScriptPosition(i);
			
			local slot_id = i + 1;
			
			local slot_model = NPC.GetNpcModelFromIDAndInstance(ObjectManager.GetSlot_NPC_ID(arena_id, slot_id));
			if(slot_model) then
				local nXRefCount = slot_model:GetXRefScriptCount();
				
				local ii = 0;
				local toX, toY, toZ;
				
				for ii = 0, 2 do
					toX, toY, toZ = slot_model:GetXRefScriptPosition(ii);
					local buffslot_id = ii;
					local char_buffslot = NPC.DeleteNPCCharacter(ObjectManager.GetBuffSlot_NPC_ID(arena_id, slot_id, buffslot_id));
					local char_shield = NPC.DeleteNPCCharacter(ObjectManager.GetBuffSlot_NPC_ID(arena_id, slot_id, buffslot_id) + 100);
				end

				ObjectManager.ShowPipsOnSlot(arena_id, slot_id, 0, 0);
			end
			
			NPC.DeleteNPCCharacter(ObjectManager.GetSlot_NPC_ID(arena_id, slot_id));
		end
	end
	
	NPC.DeleteNPCCharacter(ObjectManager.GetArena_NPC_ID(arena_id));
end


local phase_to_school_name = {
	["fire"] = "烈火系",
	["ice"] = "寒冰系",
	["storm"] = "风暴系",
	["life"] = "生命系",
	["death"] = "死亡系",
	["balance"] = "平衡系",
}
local function GetSchoolNameByPhase(phase)
	return phase_to_school_name[phase or ""] or "未知系"
end

function ObjectManager.GetWorldFilePath(any_filename)
	if(any_filename) then
		if(not ParaIO.DoesAssetFileExist(any_filename, true)) then
			local filename = ParaWorld.GetWorldDirectory()..any_filename;
			if(ParaIO.DoesAssetFileExist(filename, true)) then
				any_filename = filename;
			end
		end
		return any_filename
	end
end

-- create all mobs that is guarding a given arena
function ObjectManager.CreateArenaMobs(arena_id, arena_data)
	local arena_meta = MsgHandler.Get_arena_meta_data_by_id(arena_id);
	arena_meta.is_arena_mobs_created = true;
	local p_x, p_y, p_z = arena_meta.p_x, arena_meta.p_y, arena_meta.p_z;

	local slot_id, eachmob;
	for slot_id, eachmob in ipairs(arena_data.mobs) do
		local mob_char = NPC.GetNpcCharacterFromIDAndInstance(39001, eachmob.id);

		local displayname = (eachmob.displayname or "").." "..(eachmob.level or 0).."级";
		
		if(not mob_char) then
			local mob_x, mob_y, mob_z  = p_x, p_y, p_z;
			-- create character at fixed different position at different slot position. 
			local offset = 4;
			if(slot_id == 1) then
				mob_x = mob_x + offset;
			elseif(slot_id == 2) then
				mob_x = mob_x - offset;
			elseif(slot_id == 3) then
				mob_z = mob_z + offset;
			elseif(slot_id == 4) then
				mob_z = mob_z - offset;
			end
			

			local params = {
				position = {mob_x, mob_y, mob_z},
				assetfile_char = ObjectManager.GetWorldFilePath(eachmob.asset),
				instance = eachmob.id,
				--name = "("..eachmob.phase..")"..eachmob.displayname,
				name = displayname,
				cursor_text = format("[%s]%s\n血量:%d", GetSchoolNameByPhase(eachmob.phase), displayname, eachmob.max_hp or 0),
				scaling = 1,
				SentientRadius = mob_sentient_radius,
				PerceptiveRadius = mob_sentient_radius,
				scale_char = eachmob.scale,
				HeadOnDisplayColor = "238 3 98",
				talkdist = if_else(System.options.version == "kids", nil, 1),
				--autowalk = if_else(System.options.version == "kids", nil, false),
				cursor = "combat",
				main_script = "script/apps/Aries/NPCs/Combat/39001_BasicMob.lua",
				main_function = "MyCompany.Aries.Quest.NPCs.BasicMob.main();",
				predialog_function = "MyCompany.Aries.Quest.NPCs.BasicMob.PreDialog",
				--timer_period = 500,
				--on_timer = ";MyCompany.Aries.Quest.NPCs.BasicMob.On_Timer();",
				AI_script = "script/apps/Aries/NPCs/Combat/39001_BasicMob_AI.lua",
				FrameMoveInterval = 550,
				On_FrameMove = ";MyCompany.Aries.Quest.NPCAI.BasicMob_AI.On_FrameMove();",
			};
			
			if(System.options.version == "teen") then
				params.cursor_text = format("[%s]%s", GetSchoolNameByPhase(eachmob.phase), displayname);
			end

			--if(System.options.version == "teen") then
				--if(eachmob.rarity == "boss") then
					--params.HeadOnDisplayColor = MyCompany.Aries.Player.HeadOnDisplayColor_MobBoss;
				--elseif(eachmob.rarity == "elite") then
					--params.HeadOnDisplayColor = MyCompany.Aries.Player.HeadOnDisplayColor_MobElite;
				--else
					--params.HeadOnDisplayColor = MyCompany.Aries.Player.HeadOnDisplayColor_MobNormal;
				--end
			--end
			
			mob_char = NPC.CreateNPCCharacter(39001, params);
			
			-- fixed missing actor skins 
			if(params.assetfile_char == "character/CC/02human/actor/actor.x") then
				mob_char:SetReplaceableTexture(2, ParaAsset.LoadTexture("", "Texture/blocks/human/boy_worker01.png", 1));
			end

			if(eachmob.asset_ccs) then
				local CCS = commonlib.gettable("Map3DSystem.UI.CCS")
				--CCS.ApplyCCSInfoString(mob_char, eachmob.asset_ccs);
				CCS.ApplyCCSInfoString(mob_char, eachmob.asset_ccs, {[32] = 0}); -- force skip follow pet, TODO: bug, follow pet will stay in the arena
			end

			mob_char:SetDynamicField("slot_id", 4 + slot_id);

			--if(not eachmob.asset) then
				--LOG.std(nil, "error", "ObjectManager error", eachmob);
			--end
			if(eachmob.asset and string.find(string.lower(eachmob.asset), "manekineko")) then
				mob_char:SetDynamicField("real_movementstyle", 4);
				mob_char:SetField("MovementStyle", 4)
			else
				local current_worlddir = ParaWorld.GetWorldDirectory();
				if(current_worlddir == "worlds/Instances/FrostRoarIsland_StormEye/") then
					mob_char:SetDynamicField("real_movementstyle", 4);
					mob_char:SetField("MovementStyle", 4)
				end
			end
			
			if(eachmob.current_hp and eachmob.current_hp <= 0) then
				mob_char:SetVisible(false);
				mob_char:SetField("SkipPicking", true);
			end

			-- if elevation is over 4 meters above terrain, set the flat movementstyle
			local t_elev = ParaTerrain.GetElevation(mob_x, mob_z);
			if((t_elev + 4) < mob_y) then
				mob_char:SetDynamicField("real_movementstyle", 4);
				mob_char:SetField("MovementStyle", 4)
			end
		end
	end
end

-- remove all pips display on a given arena.
function ObjectManager.RemoveAllArenaPips(arena_id)
	local arena_meta = MsgHandler.Get_arena_meta_data_by_id(arena_id);
	if(arena_meta.total_pips and arena_meta.total_pips > 0) then
		arena_meta.total_pips = 0;
		local slot_id;
		for slot_id = 1, 8 do
			ObjectManager.ShowPipsOnSlot(arena_id, slot_id, 0, 0);
		end
	end
end

-- show pips on slot
function ObjectManager.ShowPipsOnSlot(arena_id, slot_id, pip_count, power_pip_count)
	
	if(System.options.version == "teen") then
		-- NOTE: don't show pips in scene for teen version
		pip_count = 0;
		power_pip_count = 0;
	end
	
	local NPC = NPC;

	local slot_model = NPC.GetNpcModelFromIDAndInstance(ObjectManager.GetSlot_NPC_ID(arena_id, slot_id));
	if(slot_model) then
		local nXRefCount = slot_model:GetXRefScriptCount();
				
		local ii = 0;
		local toX, toY, toZ;
				
		for ii = 3, 9 do
			toX, toY, toZ = slot_model:GetXRefScriptPosition(ii);
			local pipslot_id = ii - 2;
			if(pip_count >= pipslot_id) then
				local pipslot_npcid = ObjectManager.GetPipSlot_NPC_ID(arena_id, slot_id, pipslot_id)
				local char_pipslot = NPC.GetNpcCharacterFromIDAndInstance(pipslot_npcid);
				if(not char_pipslot) then
					local params = {
						position = {toX, toY - 0.2, toZ},
						assetfile_char = "character/v5/09effect/Combat_Common/Pips/normal_pip.x",
						--assetfile_char = "character/v5/09effect/Combat_Common/Pips/power_pip.x",
						--assetfile_char = "character/v5/09effect/Combat_Common/BuffSlots/charm_buffslot.x",
						--assetfile_model = "model/06props/v5/06combat/Common/BuffSlots/common_buffslot.x",
						--assetfile_model = ObjectManager.GetBasicArenaAsset(arena_id),
						--assetfile_model = "model/01building/v5/01house/SkyWheel/SkyWheel.x",
						--assetfile_model = "model/06props/v5/06combat/Common/Slot/normal_slot.x",
						facing = 0, -- slot_model:GetXRefScriptFacing(i),
						name = "",
						scale_char = 0.7,
						scaling_model = 0.5,
						isdummy = true,
						selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
					};
					char_pipslot = NPC.CreateNPCCharacter(pipslot_npcid, params);
				else
					if(char_pipslot:GetPrimaryAsset():GetKeyName() ~= "character/v5/09effect/Combat_Common/Pips/normal_pip.x") then
						local asset = ParaAsset.LoadParaX("", "character/v5/09effect/Combat_Common/Pips/normal_pip.x");
						char_pipslot:ToCharacter():ResetBaseModel(asset);
					end
				end
			elseif(power_pip_count >= (pipslot_id - pip_count)) then
				local pipslot_npcid = ObjectManager.GetPipSlot_NPC_ID(arena_id, slot_id, pipslot_id)
				local char_pipslot = NPC.GetNpcCharacterFromIDAndInstance(pipslot_npcid);
				if(not char_pipslot) then
					local params = {
						position = {toX, toY - 0.2, toZ},
						--assetfile_char = "character/v5/09effect/Combat_Common/Pips/normal_pip.x",
						assetfile_char = "character/v5/09effect/Combat_Common/Pips/power_pip.x",
						--assetfile_char = "character/v5/09effect/Combat_Common/BuffSlots/charm_buffslot.x",
						--assetfile_model = "model/06props/v5/06combat/Common/BuffSlots/common_buffslot.x",
						--assetfile_model = ObjectManager.GetBasicArenaAsset(arena_id),
						--assetfile_model = "model/01building/v5/01house/SkyWheel/SkyWheel.x",
						--assetfile_model = "model/06props/v5/06combat/Common/Slot/normal_slot.x",
						facing = 0, -- slot_model:GetXRefScriptFacing(i),
						name = "",
						scale_char = 0.7,
						scaling_model = 0.5,
						isdummy = true,
						selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
					};
					char_pipslot = NPC.CreateNPCCharacter(pipslot_npcid, params);
				else
					if(char_pipslot:GetPrimaryAsset():GetKeyName() ~= "character/v5/09effect/Combat_Common/Pips/power_pip.x") then
						local asset = ParaAsset.LoadParaX("", "character/v5/09effect/Combat_Common/Pips/power_pip.x");
						char_pipslot:ToCharacter():ResetBaseModel(asset);
					end
				end
			else
				local pipslot_npcid = ObjectManager.GetPipSlot_NPC_ID(arena_id, slot_id, pipslot_id)
				-- delete pip
				NPC.DeleteNPCCharacter(pipslot_npcid);
			end
		end
	end
end

-- check if the arena object in created in scene
-- NOTE: we only check the base scene object of arena
function ObjectManager.IsArenaObjCreated(arena_id)
	local NPC = NPC;
	local arena_model = NPC.GetNpcModelFromIDAndInstance(ObjectManager.GetArena_NPC_ID(arena_id));
	if(arena_model) then
		return true;
	end
	return false
end

---- apply or break buffs
---- @params arena_id: arena id
---- @params slot_id: slot id 1 to 8
---- @params level: "charm" or "ward" or "overtime"
---- @params buffs: id series
---- @params applies: id series
---- @params breaks: id series
--function ObjectManager.ApplyOrBreakBuffs(arena_id, slot_id, level, buffs, applies, breaks)
	--if(not arena_id or not slot_id or not level or not buffs) then
		--log("error: nil param in function ObjectManager.ApplyOrBreakBuffs\n");
		--commonlib.echo({arena_id, slot_id, level, buffs});
		--return;
	--end
	--local buffslot_id = 0;
	--if(level == "charm") then
		--buffslot_id = 0;
	--elseif(level == "ward") then
		--buffslot_id = 1;
	--elseif(level == "overtime") then
		--buffslot_id = 2;
	--end
--
	---- "character/v5/09effect/Combat_Earth/DamageShieldAndThorn_Level1_Earth_Shield.x"
--
	--local buffslot_npcid = ObjectManager.GetBuffSlot_NPC_ID(arena_id, slot_id, buffslot_id)
	--local model_buffslot = NPC.GetNpcModelFromIDAndInstance(buffslot_npcid);
	--if(model_buffslot and model_buffslot:IsValid() == true) then
		--
		--local buff_name = ObjectManager.GetBuff_Name(arena_id, slot_id, buffslot_id, sequence)
--
		--local att = obj:GetAttributeObject();
		--o:ToCharacter():MountOn(obj, 19 + i);
		--att:SetField("AnimID", 4);
	--end
--end

-- refresh the player or mobs positions on the arena. For some reason, the slot units may change position, such as some AI to move mobs or GSL to move player.  
function ObjectManager.RefreshSlotUnitPosition(arena_id, slotunits)
	local arena_model;
	local slot_id = 1;
	for slot_id = 1, 4 do
		local player_id = slotunits[slot_id];
		if(player_id) then
			-- player object
			local player;
			if(type(player_id) == "number") then
				if(player_id < 0) then
					player = ParaScene_GetObject(-player_id.."+followpet");
				else
					player = ParaScene_GetObject(tostring(player_id));
				end
			elseif(player_id == "localuser") then
				player = GameLogic.EntityManager.GetPlayer():GetInnerObject();
			end

			-- skip the player's pet
			if( player:IsValid()) then
				arena_model = arena_model or NPC.GetNpcModelFromIDAndInstance(ObjectManager.GetArena_NPC_ID(arena_id));
				if(arena_model) then
					if(type(player_id) == "number" and player_id<0 and ProfileManager.GetNID() == -player_id) then
						-- if it is the pet of the current player, let it walk to slot position if it is standing. 
						if(player:IsStanding()) then
							local fromX, fromY, fromZ = player:GetPosition();
							local toX, toY, toZ = arena_model:GetXRefScriptPosition(slot_id - 1);
							local facing = arena_model:GetXRefScriptFacing(slot_id - 1) + facing_offset_player_to_arenaslot;

							local dX, dY, dZ = toX - fromX, toY - fromY, toZ - fromZ;
							-- only walk if it is within 30 meters 
							if(math.abs(dX + dY + dZ) > 0.1) then
								player:ToCharacter():MoveAndTurn(dX, dY, dZ, facing);
							else
								player:SetPosition(toX, toY, toZ);
								player:SetFacing(facing);
							end
						end
					else
						local toX, toY, toZ = arena_model:GetXRefScriptPosition(slot_id - 1);
						local facing = arena_model:GetXRefScriptFacing(slot_id - 1) + facing_offset_player_to_arenaslot;
						player:SetPosition(toX, toY, toZ);
						--player:SetField("normal", {0,1,0}); -- force normal to be upward
						--player:UpdateTileContainer();
						player:SetFacing(facing);
					end
				end
			end
		end
	end
	for slot_id = 5, 8 do
		local mob_id = slotunits[slot_id];
		if(mob_id) then
			local npcChar = NPC.GetNpcCharacterFromIDAndInstance(39001, mob_id);
			if(npcChar) then
				arena_model = arena_model or NPC.GetNpcModelFromIDAndInstance(ObjectManager.GetArena_NPC_ID(arena_id));
				if(arena_model) then
					local toX, toY, toZ = arena_model:GetXRefScriptPosition(slot_id - 1);
					local facing = arena_model:GetXRefScriptFacing(slot_id - 1) + facing_offset_player_to_arenaslot;
					npcChar:SetPosition(toX, toY, toZ);
					--npcChar:SetField("normal", {0,1,0}); -- force normal to be upward
					--npcChar:UpdateTileContainer();
					npcChar:SetFacing(facing);
				end
			end
		end
	end
end

local aura_asset_mapping = {
	["fire"] = "model/06props/v5/06combat/GlobalAura/Fire_FireGlobalAura/Fire_FireGlobalAura.x",
	["ice"] = "model/06props/v5/06combat/GlobalAura/Ice_IceGlobalAura/Ice_IceGlobalAura.x",
	["storm"] = "model/06props/v5/06combat/GlobalAura/Storm_StormGlobalAura/Storm_StormGlobalAura.x",
	--["myth"] = "model/06props/v5/06combat/GlobalAura/Myth_MythGlobalAura/Myth_MythGlobalAura.x",
	["life"] = "model/06props/v5/06combat/GlobalAura/Life_LifeGlobalAura/Life_LifeGlobalAura.x",
	["death"] = "model/06props/v5/06combat/GlobalAura/Death_DeathGlobalAura/Death_DeathGlobalAura.x",
	["death_damage"] = "model/06props/v5/06combat/GlobalAura/Death_Pet_DeathGlobalAuraDamage/Death_Pet_DeathGlobalAuraDamage.x",
	--["balance"] = "model/06props/v5/06combat/GlobalAura/Balance_BalanceGlobalAura/Balance_BalanceGlobalAura.x",
};

-- show global aura
-- @param arena_id:
-- @param aura: global aura id, e.x. "fire", "ice" .etc
-- @param finish_callback: finish callback invoked when the animation is finished
function ObjectManager.ShowGlobalAura(arena_id, aura)
	if(not arena_id or not aura) then
		log("error: ObjectManager.ShowGlobalAura got invalid input:".. commonlib.serialize({arena_id, aura}));
		return;
	end
	-- validate asset version
	ObjectManager.ValidateAssetMappingVersionIfNot();
	-- aura effects
	local aura_asset = aura_asset_mapping[aura];
    if(not aura_asset) then
        if(type(aura) == "string") then
			local aura_key, gsid = string.match(aura, "^([%w_]+)_([%d]+)");
			if(aura_key and gsid) then
				aura_asset = aura_asset_mapping[aura_key];
			end
        end
    end
	local NPC = NPC;
	local arena_model = NPC.GetNpcModelFromIDAndInstance(ObjectManager.GetArena_NPC_ID(arena_id));
	if(arena_model) then
		local aura_model = NPC.GetNpcModelFromIDAndInstance(ObjectManager.GetSlot_NPC_ID(arena_id, 0));
		if(aura_model) then
			-- aura is already created
			if(aura_model:GetPrimaryAsset():GetKeyName() ~= aura_asset) then
				-- change aura asset if needed
				NPC.ChangeModelAsset(ObjectManager.GetSlot_NPC_ID(arena_id, 0), nil, aura_asset);
			end
			return;
		end
		local i = 0;
		local toX, toY, toZ = arena_model:GetXRefScriptPosition(8);
		local params = {
			position = {toX, toY, toZ},
			assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
			assetfile_model = aura_asset,
			--assetfile_model = ObjectManager.GetSequenceArrowAsset(arena_id),
			--assetfile_model = ObjectManager.GetBasicArenaAsset(arena_id),
			--assetfile_model = "model/01building/v5/01house/SkyWheel/SkyWheel.x",
			--assetfile_model = "model/06props/v5/06combat/Common/Slot/normal_slot.x",
			facing = 0,
			name = "",
			----scaling = 4,
			--scale_char = 0.65,
			----scaling_model = 1,
			scale_char = 0.0001,
			scaling_model = 1,
			EnablePhysics = false,
			isdummy = true,
		};
		NPC.CreateNPCCharacter(ObjectManager.GetSlot_NPC_ID(arena_id, 0), params);
	end
end

-- show global aura
-- @param arena_id:
-- @param aura: global aura id, e.x. "fire", "ice" .etc
-- @param finish_callback: finish callback invoked when the animation is finished
function ObjectManager.ShowGlobalAura2(arena_id, aura)
	if(not arena_id or not aura) then
		log("error: ObjectManager.ShowGlobalAura2 got invalid input:".. commonlib.serialize({arena_id, aura}));
		return;
	end
	-- validate asset version
	ObjectManager.ValidateAssetMappingVersionIfNot();
	-- aura effects
	local aura_asset = aura_asset_mapping[aura];
	local aura2_npc_id = ObjectManager.GetArena_Aura2_NPC_ID(arena_id);
	local NPC = NPC;
	local arena_model = NPC.GetNpcModelFromIDAndInstance(ObjectManager.GetArena_NPC_ID(arena_id));
	if(arena_model) then
		local aura_model = NPC.GetNpcModelFromIDAndInstance(aura2_npc_id);
		if(aura_model) then
			-- aura is already created
			if(aura_model:GetPrimaryAsset():GetKeyName() ~= aura_asset) then
				-- change aura asset if needed
				NPC.ChangeModelAsset(aura2_npc_id, nil, aura_asset);
			end
			return;
		end
		local i = 0;
		local toX, toY, toZ = arena_model:GetXRefScriptPosition(8);
		local params = {
			position = {toX, toY, toZ},
			assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
			assetfile_model = aura_asset,
			--assetfile_model = ObjectManager.GetSequenceArrowAsset(arena_id),
			--assetfile_model = ObjectManager.GetBasicArenaAsset(arena_id),
			--assetfile_model = "model/01building/v5/01house/SkyWheel/SkyWheel.x",
			--assetfile_model = "model/06props/v5/06combat/Common/Slot/normal_slot.x",
			facing = 0,
			name = "",
			----scaling = 4,
			--scale_char = 0.65,
			----scaling_model = 1,
			scale_char = 0.0001,
			scaling_model = 1,
			EnablePhysics = false,
			isdummy = true,
		};
		NPC.CreateNPCCharacter(aura2_npc_id, params);
	end
end

-- destroy global aura
function ObjectManager.DestroyGlobalAura(arena_id)
	NPC.DeleteNPCCharacter(ObjectManager.GetSlot_NPC_ID(arena_id, 0));
end
-- destroy global aura2
function ObjectManager.DestroyGlobalAura2(arena_id)
	NPC.DeleteNPCCharacter(ObjectManager.GetArena_Aura2_NPC_ID(arena_id));
end

local charms_id_mapping = {
	[1] = "character/v5/09effect/Combat_Metal/PowerEnhanceBlade_Level0_Metal.x",
	[2] = "character/v5/09effect/Combat_Wood/PowerEnhanceBlade_Level0_Wood.x",
	[3] = "character/v5/09effect/Combat_Earth/PowerEnhanceBlade_Level0_Earth.x",
	[4] = "character/v5/09effect/Combat_Water/PowerEnhanceBlade_Level0_Water.x",
	[5] = "character/v5/09effect/Combat_Fire/PowerEnhanceBlade_Level0_Fire.x",
	[6] = "character/v5/09effect/Combat_Wood/Charm_AreaGlobalDamageWeakness_Level1_Wood.x",
	[7] = "character/v5/09effect/Combat_Metal/Charm_BoostAccuracy_Metal.x",
	[8] = "character/v5/09effect/Combat_Wood/Charm_FocusPrism_Wood.x",
	[9] = "character/v5/09effect/Combat_Wood/Charm_AreaGlobalDamageWeakness_Level2_Wood.x",
	
	-- new version charms
	[11] = "character/v5/09effect/Combat_Fire/Fire_FireDamageBlade.x",
	[12] = "character/v5/09effect/Combat_Fire/Fire_AreaAccuracyWeakness.x",
	[13] = "character/v5/09effect/Combat_Fire/Fire_FireDispellWeakness.x",
	[14] = "character/v5/09effect/Combat_Storm/Storm_StormAccuracyBlade.x",
	[15] = "character/v5/09effect/Combat_Storm/Storm_StormDamageBlade.x",
	[16] = "character/v5/09effect/Combat_Storm/Storm_StormDispellWeakness.x",
	[17] = "character/v5/09effect/Combat_Ice/Ice_IceDamageBlade.x",
	[18] = "character/v5/09effect/Combat_Ice/Ice_IceDispellWeakness.x",
	[19] = "character/v5/09effect/Combat_Life/Life_LifeDamageBlade.x",
	[20] = "character/v5/09effect/Combat_Life/Life_AreaAccuracyBlade.x",
	[21] = "character/v5/09effect/Combat_Life/Life_HealBlade.x",
	[22] = "character/v5/09effect/Combat_Life/Life_LifeDispellWeakness.x",
	[23] = "character/v5/09effect/Combat_Death/Death_DeathDamageBlade.x",
	[24] = "character/v5/09effect/Combat_Death/Death_AreaDamageWeakness.x",
	[25] = "character/v5/09effect/Combat_Death/Death_HealWeakness.x",
	[26] = "character/v5/09effect/Combat_Death/Death_DeathDispellWeakness.x",
	[27] = "character/v5/09effect/Combat_Life/Life_HealBlade.x",
	[28] = "character/v5/09effect/Combat_Life/Life_LifeDamageBlade.x",
	[29] = "character/v5/09effect/Combat_Fire/Fire_AreaAccuracyWeakness.x",
	[30] = "character/v5/09effect/Combat_Death/Death_SingleGuardianWithImmolate_Level8_BUff.x",

	[31] = "character/v5/09effect/Combat_Fire/Fire_FireDamageBlade.x",
	[32] = "character/v5/09effect/Combat_Storm/Storm_StormDamageBlade.x",
	[33] = "character/v5/09effect/Combat_Ice/Ice_IceDamageBlade.x",
	[34] = "character/v5/09effect/Combat_Life/Life_LifeDamageBlade.x",
	[35] = "character/v5/09effect/Combat_Death/Death_DeathDamageBlade.x",
};

local wards_id_mapping = {
	[1] = "character/v5/09effect/Combat_Metal/DamageShieldAndThorn_Level2_Metal_Shield.x",
	[2] = "character/v5/09effect/Combat_Wood/DamageShieldAndThorn_Level2_Wood_Shield.x",
	[3] = "character/v5/09effect/Combat_Water/DamageShieldAndThorn_Level2_Water_Shield.x",
	[4] = "character/v5/09effect/Combat_Fire/DamageShieldAndThorn_Level2_Fire_Shield.x",
	[5] = "character/v5/09effect/Combat_Earth/DamageShieldAndThorn_Level2_Earth_Shield.x",
	[6] = "character/v5/09effect/Combat_Metal/DamageShieldAndThorn_Level1_Metal_Shield.x",
	[7] = "character/v5/09effect/Combat_Wood/DamageShieldAndThorn_Level1_Wood_Shield.x",
	[8] = "character/v5/09effect/Combat_Water/DamageShieldAndThorn_Level1_Water_Shield.x",
	[9] = "character/v5/09effect/Combat_Fire/DamageShieldAndThorn_Level1_Fire_Shield.x",
	[10] = "character/v5/09effect/Combat_Earth/DamageShieldAndThorn_Level1_Earth_Shield.x",
	[11] = "character/v5/09effect/Combat_Metal/Ward_WaterDamageTrap_Level1_Metal.x",
	[12] = "character/v5/09effect/Combat_Fire/Ward_WaterDamageTrap_Level1_Fire.x",
	[13] = "character/v5/09effect/Combat_Earth/Ward_GlobalShield_Level1_Earth.x",
	
	-- new version wards
	[21] = "character/v5/09effect/Combat_Fire/Fire_FireDamageTrap.x",
	[22] = "character/v5/09effect/Combat_Fire/Fire_FirePrism.x",
	[23] = "character/v5/09effect/Combat_Fire/Fire_FireGreatShield.x",
	[24] = "character/v5/09effect/Combat_Storm/Storm_StormDamageTrap.x",
	[25] = "character/v5/09effect/Combat_Storm/Storm_StormDamageTrap.x",
	--[25] = "character/v5/09effect/Combat_Storm/Storm_AreaDamageTrap.x",
	[26] = "character/v5/09effect/Combat_Storm/Storm_StormGreatShield.x",
	[27] = "character/v5/09effect/Combat_Ice/Ice_GlobalShield.x",
	[28] = "character/v5/09effect/Combat_Ice/Ice_IceDamageTrap.x",
	[29] = "character/v5/09effect/Combat_Ice/Ice_IcePrism.x",
	[30] = "character/v5/09effect/Combat_Ice/Ice_Absorb_LevelX.x",
	[31] = "character/v5/09effect/Combat_Ice/Ice_StunAbsorb.x",
	[32] = "character/v5/09effect/Combat_Ice/Ice_IceGreatShield.x",
	[33] = "character/v5/09effect/Combat_Life/Life_Absorb_Level3.x",
	[34] = "character/v5/09effect/Combat_Life/Life_LifePrism.x",
	[35] = "character/v5/09effect/Combat_Life/Life_Absorb_Level3.x",
	[36] = "character/v5/09effect/Combat_Life/Life_LifeDamageTrap.x",
	[37] = "character/v5/09effect/Combat_Life/Life_LifeGreatShield.x",
	[38] = "character/v5/09effect/Combat_Death/Death_GlobalDamageTrap.x",
	[39] = "character/v5/09effect/Combat_Death/Death_GlobalDamageTrap.x",
	--[38] = "character/v5/09effect/Combat_Death/Death_SymmetryGlobalTrap_Target.x",
	--[39] = "character/v5/09effect/Combat_Death/Death_SymmetryGlobalTrap_Caster.x",
	[40] = "character/v5/09effect/Combat_Death/Death_DeathDamageTrap.x",
	[41] = "character/v5/09effect/Combat_Death/Death_DeathPrism.x",
	[42] = "character/v5/09effect/Combat_Death/Death_GlobalDamageTrap.x",
	[43] = "character/v5/09effect/Combat_Death/Death_DeathGreatShield.x",
	[44] = "character/v5/09effect/Combat_Ice/Ice_GlobalShield.x",
	[45] = "character/v5/09effect/Combat_Ice/Ice_GlobalShield.x",

	[46] = "character/v5/09effect/Combat_Death/Death_DeathDamageTrap.x",
	[47] = "character/v5/09effect/Combat_Fire/Fire_FireDamageTrap.x",
	[48] = "character/v5/09effect/Combat_Life/Life_LifeDamageTrap.x",
	[49] = "character/v5/09effect/Combat_Storm/Storm_StormDamageTrap.x",
	[50] = "character/v5/09effect/Combat_Fire/Fire_FireGreatShield.x",
	[51] = "character/v5/09effect/Combat_Ice/Ice_IceDamageTrap.x",

	[52] = "character/v5/09effect/Combat_Storm/Storm_StormDamageTrap_Standing_Dun.x",
	--[53] -- disabled heal effect displayed in the overtime layer
	[54] = "character/v5/09effect/Combat_Ice/Ice_ReflectionShield_Dun.x",
	--[55] -- cursed heal effect displayed in the overtime layer
	--[56] -- cursed powerpip effect displayed in the overtime layer
	--[57] -- boost powerpip effect displayed in the overtime layer
	[58] = "character/v5/09effect/Combat_Ice/Ice_DefensiveStance.x",
	--[59] = "", -- Storm_SingleStealth, hide the stealth ward

	[77] = "character/v5/09effect/Combat_Balance/Balance_GlobalShield.x",
	[78] = "character/v5/09effect/Combat_Balance/Balance_GlobalShield.x",
	[79] = "character/v5/09effect/Combat_Balance/Balance_GlobalShield.x",

	[88] = "character/v5/09effect/Combat_Death/Death_DeathDamageTrap.x",
	[89] = "character/v5/09effect/Combat_Fire/Fire_FireDamageTrap.x",
	[90] = "character/v5/09effect/Combat_Life/Life_LifeDamageTrap.x",
	[91] = "character/v5/09effect/Combat_Storm/Storm_StormDamageTrap.x",
	[92] = "character/v5/09effect/Combat_Ice/Ice_IceDamageTrap.x",
	[98] = "character/v5/09effect/Combat_Ice/Ice_Absorb_LevelX.x",
};

local overtimes_id_mapping = {
	["fire"] = "character/v5/09effect/Combat_Fire/Fire_Dot.x",
	["water"] = "character/v5/09effect/Combat_Water/Water_Dot.x",
	["ice"] = "character/v5/09effect/Combat_Ice/Ice_Dot.x",
	["storm"] = "character/v5/09effect/Combat_Storm/Storm_Dot.x",
	["life"] = "character/v5/09effect/Combat_Life/Life_Dot.x",
	["death"] = "character/v5/09effect/Combat_Death/Death_Dot.x",
	["hot"] = "character/v5/09effect/Combat_Life/Life_hot.x",
	["disabledheal"] = "character/v5/09effect/Combat_Death/Death_SingleAttackWithDisabledHeal_Dun.x",
	["firesplash"] = "character/v5/09effect/Combat_Fire/DoT_Fire_Splash_Zadan.x",
	["cursedheal"] = "character/v5/09effect/Combat_Death/Death_Rune_HealTrap_Standing.x",
	["cursedpowerpip"] = "character/v5/09effect/Combat_Life/Life_Rune_PowerPipTrap_Standing.x",
	["boostpowerpip"] = "character/v5/09effect/Combat_General/Balance_BoostPowerPipChance_Standing.x",
	["antifreeze"] = "character/v5/09effect/Combat_Ice/Ice_SingleFreeze_AntiFreeze.x",
};

local miniaura_id_mapping = {
	[1] = "character/v5/09effect/Combat_Fire/Fire_FireResist_MiniAura.x",
	[2] = "character/v5/09effect/Combat_Ice/Ice_IceResist_MiniAura.x",
	[3] = "character/v5/09effect/Combat_Storm/Storm_StormResist_MiniAura.x",
	[4] = "character/v5/09effect/Combat_Life/Life_LifeResist_MiniAura.x",
	[5] = "character/v5/09effect/Combat_Death/Death_DeathResist_MiniAura.x",

	[6] = "character/v5/09effect/Combat_Fire/Fire_FireResist_MiniAura.x",
	[7] = "character/v5/09effect/Combat_Ice/Ice_IceResist_MiniAura.x",
	[8] = "character/v5/09effect/Combat_Storm/Storm_StormResist_MiniAura.x",
	[9] = "character/v5/09effect/Combat_Life/Life_LifeResist_MiniAura.x",
	[10] = "character/v5/09effect/Combat_Death/Death_DeathResist_MiniAura.x",

	["freeze"] = "character/v5/09effect/Combat_Ice/Ice_SingleFreeze_End_bingjingu.x",
	--["defensive"] = "character/v5/06quest/PolicePatrolFootStep/PolicePatrolFootStep.x",
	["dead"] = "character/v6/09effect/Combat_Common/Die/Die_MuBei.x",
	["dead_elite"] = "character/v6/09effect/Combat_Common/Die/Die_MuBei.x",
	["dead_boss"] = "character/v6/09effect/Combat_Common/Die/Die_MuBei.x",
	["stun"] = "character/v5/09effect/Combat_Common/Stun/Stun.x",
	
	["fire_kids"] = "character/v5/09effect/Combat_Fire/Fire_BlazingStance.x",
	["ice_kids"] = "character/v5/09effect/Combat_Ice/Ice_PierceStance.x",
	["storm_kids"] = "character/v5/09effect/Combat_Storm/Storm_ElectricStance.x",
	["life_kids"] = "character/v5/09effect/Combat_Life/Life_HealingStance.x",
	["death_kids"] = "character/v5/09effect/Combat_Death/Death_VampireStance.x",

	["fire_kids_siblin"] = "character/v5/09effect/Combat_Fire/Fire_BlazingStance_Dun.x",
	["ice_kids_siblin"] = "character/v5/09effect/Combat_Ice/Ice_PierceStance_Dun.x",
	["storm_kids_siblin"] = "character/v5/09effect/Combat_Storm/Storm_ElectricStance_Dun.x",
	["life_kids_siblin"] = "character/v5/09effect/Combat_Life/Life_HealingStance_Dun.x",
	["death_kids_siblin"] = "character/v5/09effect/Combat_Death/Death_VampireStance_Dun.x",
};

-- for teen version some assets will be updated with new paths
-- e.x. global shield is a balance school spell in teen version
local bValidateAssetMappingVersion = false;
function ObjectManager.ValidateAssetMappingVersionIfNot()
	if(not bValidateAssetMappingVersion) then
		if(System.options.version == "teen") then
			charms_id_mapping = {
				-- new version charms
				[11] = "character/v6/09effect/Combat_Fire/Fire_FireDamageBlade.x",
				[12] = "character/v6/09effect/Combat_Fire/Fire_AreaAccuracyWeakness.x",
				[13] = "character/v6/09effect/Combat_Fire/Fire_FireDispellWeakness.x",
				[14] = "character/v6/09effect/Combat_Storm/Storm_StormAccuracyBlade.x",
				[15] = "character/v6/09effect/Combat_Storm/Storm_StormDamageBlade.x",
				[16] = "character/v6/09effect/Combat_Storm/Storm_StormDispellWeakness.x",
				[17] = "character/v6/09effect/Combat_Ice/Ice_IceDamageBlade.x",
				[18] = "character/v6/09effect/Combat_Ice/Ice_IceDispellWeakness.x",
				[19] = "character/v6/09effect/Combat_Life/Life_LifeDamageBlade.x",
				[20] = "character/v6/09effect/Combat_Life/Life_AreaAccuracyBlade.x",
				[21] = "character/v6/09effect/Combat_Life/Life_HealBlade.x",
				[22] = "character/v6/09effect/Combat_Life/Life_LifeDispellWeakness.x",
				[23] = "character/v6/09effect/Combat_Death/Death_DeathDamageBlade.x",
				[24] = "character/v6/09effect/Combat_Death/Death_AreaDamageWeakness.x",
				[25] = "character/v6/09effect/Combat_Death/Death_HealWeakness.x",
				[26] = "character/v6/09effect/Combat_Death/Death_DeathDispellWeakness.x",
				[27] = "character/v6/09effect/Combat_Life/Life_HealBlade.x",
				[28] = "character/v6/09effect/Combat_Life/Life_LifeDamageBlade.x",
				[29] = "character/v6/09effect/Combat_Fire/Fire_AreaAccuracyWeakness.x",
				[30] = "character/v6/09effect/Combat_Death/Death_SingleGuardianWithImmolate_Level8.x",

				[31] = "character/v6/09effect/Combat_Fire/Fire_FireDamageBlade_Adv.x",
				[32] = "character/v6/09effect/Combat_Storm/Storm_StormDamageBlade_Adv.x",
				[33] = "character/v6/09effect/Combat_Ice/Ice_IceDamageBlade_Adv.x",
				[34] = "character/v6/09effect/Combat_Life/Life_LifeDamageBlade_Adv.x",
				[35] = "character/v6/09effect/Combat_Death/Death_DeathDamageBlade_Adv.x",

				[37] = "character/v6/09effect/Combat_Balance/Balance_GreatDamageBlade_level1.x",
				[38] = "character/v6/09effect/Combat_Life/Life_LifeDamageBlade.x",
				[39] = "character/v6/09effect/Combat_Balance/Balance_BalanceDamageBlade.x",
			};

			wards_id_mapping = {
				-- new version wards
				[21] = "character/v6/09effect/Combat_Fire/Fire_FireDamageTrap.x",
				[22] = "character/v6/09effect/Combat_Fire/Fire_FirePrism.x",
				[23] = "character/v6/09effect/Combat_Fire/Fire_FireGreatShield.x",
				[24] = "character/v6/09effect/Combat_Storm/Storm_StormDamageTrap.x",
				[25] = "character/v6/09effect/Combat_Storm/Storm_StormDamageTrap.x",
				--[25] = "character/v6/09effect/Combat_Storm/Storm_AreaDamageTrap.x",
				[26] = "character/v6/09effect/Combat_Storm/Storm_StormGreatShield.x",
				[27] = "character/v6/09effect/Combat_Ice/Ice_GlobalShield.x",
				[28] = "character/v6/09effect/Combat_Ice/Ice_IceDamageTrap.x",
				[29] = "character/v6/09effect/Combat_Ice/Ice_IcePrism.x",
				[30] = "character/v6/09effect/Combat_Ice/Ice_Absorb_LevelX.x",
				[31] = "character/v6/09effect/Combat_Ice/Ice_StunAbsorb.x",
				[32] = "character/v6/09effect/Combat_Ice/Ice_IceGreatShield.x",
				[33] = "character/v6/09effect/Combat_Life/Life_Absorb_Level3.x",
				[34] = "character/v6/09effect/Combat_Life/Life_LifePrism.x",
				[35] = "character/v6/09effect/Combat_Life/Life_Absorb_Level3.x",
				[36] = "character/v6/09effect/Combat_Life/Life_LifeDamageTrap.x",
				[37] = "character/v6/09effect/Combat_Life/Life_LifeGreatShield.x",
				[38] = "character/v6/09effect/Combat_Death/Death_GlobalDamageTrap.x",
				[39] = "character/v6/09effect/Combat_Death/Death_GlobalDamageTrap.x",
				--[38] = "character/v6/09effect/Combat_Death/Death_SymmetryGlobalTrap_Target.x",
				--[39] = "character/v6/09effect/Combat_Death/Death_SymmetryGlobalTrap_Caster.x",
				[40] = "character/v6/09effect/Combat_Death/Death_DeathDamageTrap.x",
				[41] = "character/v6/09effect/Combat_Death/Death_DeathPrism.x",
				[42] = "character/v6/09effect/Combat_Death/Death_GlobalDamageTrap.x",
				[43] = "character/v6/09effect/Combat_Death/Death_DeathGreatShield.x",
				[44] = "character/v6/09effect/Combat_Ice/Ice_GlobalShield.x",
				[45] = "character/v6/09effect/Combat_Ice/Ice_GlobalShield.x",

				[46] = "character/v6/09effect/Combat_Death/Death_Pet_DeathDamageTrap_Pineapple.x",
				[47] = "character/v6/09effect/Combat_Fire/Fire_Pet_FireDamageTrap_OrangeBaby.x",
				[48] = "character/v6/09effect/Combat_Life/Life_Pet_LifeDamageTrap_StrawberryGirl.x",
				[49] = "character/v6/09effect/Combat_Storm/Storm_Pet_StormDamageTrap_Alexander.x",
				[50] = "character/v6/09effect/Combat_Fire/Fire_FireGreatShield.x",
				[51] = "character/v6/09effect/Combat_Ice/Ice_Pet_IceDamageTrap_IceShrimpWarrior.x",

				[52] = "character/v6/09effect/Combat_Storm/Storm_StormDamageTrap_Standing.x",
				--[53] -- disabled heal effect displayed in the overtime layer
				[54] = "character/v6/09effect/Combat_Ice/Ice_ReflectionShield.x",
				--[55] -- cursed heal effect displayed in the overtime layer
				--[56] -- cursed powerpip effect displayed in the overtime layer
				--[57] -- boost powerpip effect displayed in the overtime layer
				[58] = "character/v6/09effect/Combat_Ice/Ice_DefensiveStance.x",
				--[59] = "", -- Storm_SingleStealth, hide the stealth ward
				[64] = "character/v6/09effect/Combat_Storm/Storm_Rune_BoostDodgeChance.x",
				[65] = "character/v6/09effect/Combat_Balance/Balance_BalanceDamageTrap.x",

				[67] = "character/v6/09effect/Combat_Balance/Balance_Rune_ControlAbsorb_Dragon.x",
			};

			overtimes_id_mapping = {
				["fire"] = "character/v6/09effect/Combat_Fire/Fire_Dot.x",
				["water"] = "character/v6/09effect/Combat_Water/Water_Dot.x",
				["ice"] = "character/v6/09effect/Combat_Ice/Ice_Dot.x",
				["storm"] = "character/v6/09effect/Combat_Storm/Storm_Dot.x",
				["life"] = "character/v6/09effect/Combat_Life/Life_Dot.x",
				["death"] = "character/v6/09effect/Combat_Death/Death_Dot.x",
				["hot"] = "character/v6/09effect/Combat_Life/Life_hot.x",
				["disabledheal"] = "character/v6/09effect/Combat_Death/Death_SingleAttackWithDisabledHeal.x",
				["firesplash"] = "character/v6/09effect/Combat_Fire/Fire_DOTAttackWithSplash_Level6.x",
				["cursedheal"] = "character/v6/09effect/Combat_Death/Death_Rune_HealTrap_Standing.x",
				["cursedpowerpip"] = "character/v6/09effect/Combat_Balance/Balance_Rune_PowerPipTrap_Standing.x",
				["boostpowerpip"] = "character/v6/09effect/Combat_Balance/Balance_Rune_BoostPowerPipChance_Standing.x",
				["antifreeze"] = "character/v6/09effect/Combat_Ice/Ice_SingleFreeze_AntiFreeze.x",
			};

			miniaura_id_mapping = {
				[1] = "character/v6/09effect/Combat_Fire/Fire_Rune_FireResist_MiniAura.x",
				[2] = "character/v6/09effect/Combat_Ice/Ice_Rune_IceResist_MiniAura.x",
				[3] = "character/v6/09effect/Combat_Storm/Storm_Rune_StormResist_MiniAura.x",
				[4] = "character/v6/09effect/Combat_Life/Life_Rune_LifeResist_MiniAura.x",
				[5] = "character/v6/09effect/Combat_Death/Death_Rune_DeathResist_MiniAura.x",

				[6] = "character/v6/09effect/Combat_Fire/Fire_FireResist_MiniAura.x",
				[7] = "character/v6/09effect/Combat_Ice/Ice_IceResist_MiniAura.x",
				[8] = "character/v6/09effect/Combat_Storm/Storm_StormResist_MiniAura.x",
				[9] = "character/v6/09effect/Combat_Life/Life_LifeResist_MiniAura.x",
				[10] = "character/v6/09effect/Combat_Death/Death_DeathResist_MiniAura.x",

				[10] = "character/v6/09effect/Combat_Balance/Balance_Rune_GlobalResist_MiniAura_Iron.x",

				["freeze"] = "character/v6/09effect/Combat_Ice/Ice_SingleFreeze.x",
				--["defensive"] = "character/v6/06quest/PolicePatrolFootStep/PolicePatrolFootStep.x",
				["dead"] = "character/v6/09effect/Combat_Common/Die/Die_MuBei.x",
				["dead_elite"] = "character/v6/09effect/Combat_Common/Die/Die_MuBei.x",
				["dead_boss"] = "character/v6/09effect/Combat_Common/Die/Die_MuBei.x",
				["stun"] = "character/v6/09effect/Combat_Common/Stun/Stun.x",
				["control"] = "character/v6/09effect/Combat_Balance/Balance_Rune_AreaControl_Devil.x",
				
				["healing"] = "character/v6/09effect/Combat_Life/Life_HealingStance.x",
				["blazing"] = "character/v6/09effect/Combat_Fire/Fire_BlazingStance.x",
				["electric"] = "character/v6/09effect/Combat_Storm/Storm_ElectricStance.x",
				["vampire"] = "character/v6/09effect/Combat_Death/Death_VampireStance.x",
				["pierce"] = "character/v6/09effect/Combat_Ice/Ice_PierceStance.x",
			};
			
			aura_asset_mapping = {
				["fire"] = "model/06props/v6/06combat/GlobalAura/Fire_FireGlobalAura/Fire_FireGlobalAura.x",
				["ice"] = "model/06props/v6/06combat/GlobalAura/Ice_IceGlobalAura/Ice_IceGlobalAura.x",
				["storm"] = "model/06props/v6/06combat/GlobalAura/Storm_StormGlobalAura/Storm_StormGlobalAura.x",
				--["myth"] = "model/06props/v6/06combat/GlobalAura/Myth_MythGlobalAura/Myth_MythGlobalAura.x",
				["life"] = "model/06props/v6/06combat/GlobalAura/Life_LifeGlobalAura/Life_LifeGlobalAura.x",
				["death"] = "model/06props/v6/06combat/GlobalAura/Death_DeathGlobalAura/Death_DeathGlobalAura.x",
				["death_damage"] = "model/06props/v6/06combat/GlobalAura/Death_Pet_DeathGlobalAuraDamage/Death_Pet_DeathGlobalAuraDamage.x",
				--["balance"] = "model/06props/v6/06combat/GlobalAura/Balance_BalanceGlobalAura/Balance_BalanceGlobalAura.x",
				
				-- aura2
				[31] = "model/06props/v6/06combat/GlobalAura/Death_DeathGlobalAura2/Death_DeathGlobalAura2.x",
				[32] = "model/06props/v6/06combat/GlobalAura/Fire_FireGlobalAura2/Fire_FireGlobalAura2.x",
				[33] = "model/06props/v6/06combat/GlobalAura/Ice_IceGlobalAura2/Ice_IceGlobalAura2.x",
				[34] = "model/06props/v6/06combat/GlobalAura/Storm_StormGlobalAura2/Storm_StormGlobalAura2.x",
				[35] = "model/06props/v6/06combat/GlobalAura/Life_LifeGlobalAura2/Life_LifeGlobalAura2.x",
			};
		end
		if(System.options.version == "teen") then
			wards_id_mapping[27] = "character/v6/09effect/Combat_Balance/Balance_GlobalShield.x";
			charms_id_mapping[36] = "character/v6/09effect/Combat_Balance/Balance_Rune_TauntStance.x";
		end
		bValidateAssetMappingVersion = true;
	end
end

-- refresh buffs
-- @params arena_id: arena id
-- @params slot_id: slot id 1 to 8
-- @params level: "charm" or "ward" or "overtime"
-- @params buffs: nil or string of id series
-- @params arena_meta: the last buffs. 
-- @return true if there is buffs on the slot
function ObjectManager.RefreshBuffs(arena_id, slot_id, level, buffs, arena_meta)
	arena_meta = arena_meta or MsgHandler.Get_arena_meta_data_by_id(arena_id);
	if(not arena_id or not slot_id or not level) then
		LOG.error("nil param in function ObjectManager.RefreshBuffs\n");
		commonlib.echo({arena_id, slot_id, level});
		return;
	end
	-- validate asset version
	ObjectManager.ValidateAssetMappingVersionIfNot();
	-- specific buff slot levels charms, wards and overtime effects
	local buffslot_id = 0;
	local mapping;
	if(level == "charm") then
		buffslot_id = 0;
		mapping = charms_id_mapping;
	elseif(level == "ward") then
		buffslot_id = 1;
		mapping = wards_id_mapping;
	elseif(level == "overtime") then
		buffslot_id = 2;
		mapping = overtimes_id_mapping;
	elseif(level == "miniaura") then
		buffslot_id = 3;
		mapping = miniaura_id_mapping;
	else
		LOG.error("unknown buff level")
		return;
	end

	-- we will only update buffs if buffs string changes
	local last_slotbuffs = arena_meta.slotbuffs or {};
	local meta_slot_id = slot_id*10+buffslot_id;
	local last_buffs_string = last_slotbuffs[meta_slot_id] or "";
	local last_buffs = last_slotbuffs[meta_slot_id*100];
	if(not last_buffs) then
		last_buffs = {};
		last_slotbuffs[meta_slot_id*100] = last_buffs;
	end
	buffs = buffs or "";

	if(last_buffs_string == buffs) then
		return (buffs ~= "") 
	end
	-- save buffs string
	last_slotbuffs[meta_slot_id] = buffs;
	arena_meta.slotbuffs = last_slotbuffs;
	
	buffs = ObjectManager.BuffStringToTable(buffs);

	local isFrozen = false;
	local isStealth = false;
	local isStone = false;
	
	local nBufCount = 0;
	-- load the buffs with asset
	local buffslot_npcid = ObjectManager.GetBuffSlot_NPC_ID(arena_id, slot_id, buffslot_id)
	local model_buffslot = NPC.GetNpcModelFromIDAndInstance(buffslot_npcid);
	if(model_buffslot) then
		local freeze_buffChar = nil;
		local i;
		for i = 1, maximum_buff_count do
			local last_buff_id = last_buffs[i];
			local buff_id = buffs[i];

			if(level == "overtime" and buff_id) then
				-- remove the rounds and icon_gsid
				local this_buff_id = string.match(buff_id, "^([^_]+)");
				if(this_buff_id) then
					buff_id = this_buff_id;
				end
			elseif(level == "ward" and buff_id) then
				-- remove the rounds and icon_gsid
				local this_buff_id = string.match(buff_id, "^([%d]+)");
				if(this_buff_id) then
					buff_id = tonumber(this_buff_id);
				end
			end

			if(buff_id == "freeze") then
				isFrozen = true;
			end
			
			if(buff_id == "stealth") then
				isStealth = true;
			end
			
			if(buff_id == "stone") then
				isStone = true;
			end

			if(buff_id ~= last_buff_id) then
				last_buffs[i] = buff_id;
				
				local buff_name = ObjectManager.GetBuff_Name(arena_id, slot_id, buffslot_id, i)
				local buffChar = ParaScene_GetObject(buff_name);

				if(buffChar:IsValid() == false) then
					if(buff_id and buff_id ~= 0) then
						-- create the buff object on demand
						local toX, toY, toZ = model_buffslot:GetPosition();
						local obj_params = {};
						obj_params.name = buff_name;
						obj_params.x = toX;
						obj_params.y = toY;
						obj_params.z = toZ;
						obj_params.AssetFile = "";
						obj_params.IsCharacter = true;
						-- skip saving to history for recording or undo.
						System.SendMessage_obj({type = Map3DSystem.msg.OBJ_CreateObject, obj_params = obj_params, SkipHistory = true, silentmode = true,});
						buffChar = ParaScene_GetObject(buff_name);
						-- mount on the normal buff slot
						buffChar:ToCharacter():MountOn(model_buffslot, 19 + math.mod(i - 1, 12) + 1);
						-- skip pick buffs
						buffChar:SetField("SkipPicking", true);
					end
				end
				if(buffChar:IsValid()) then
					if(buff_id ~= 0 and buff_id) then
						local base_buff_id = buff_id;
						if(type(buff_id) == "number") then
							base_buff_id = math.mod(buff_id, 1000); -- base white card buff id
						end
						local asset = ParaAsset.LoadParaX("", mapping[base_buff_id] or "");
						buffChar:ToCharacter():ResetBaseModel(asset);
						buffChar:SetVisible(true);
						nBufCount = nBufCount + 1;
						-- record the freeze buff character
						if(buff_id == "freeze") then
							freeze_buffChar = buffChar;
						end
						if(buff_id == "dead") then
							buffChar:SetFacing(model_buffslot:GetFacing() - math.pi / 2);
							buffChar:SetScale(1);
						end
						if(buff_id == "stun") then
							buffChar:SetFacing(model_buffslot:GetFacing() - math.pi / 2);
							buffChar:SetScale(1);
						end
					else
						buffChar:SetVisible(false);
					end
				end
			elseif(buff_id and buff_id~=0) then
				nBufCount = nBufCount + 1;
			end
		end

		model_buffslot:SetField("AnimID", 4);

		local arena_data = MsgHandler.Get_arena_data_by_id(arena_id);
		
		-- NOTE 2012/11/15: 
		-- set unit object freeze, stealth or stone effect ONLY in miniaura
		-- updated wards value(rounds update) will cause another effect reset
		if(level == "miniaura") then
			if(arena_data and arena_data.players and arena_data.players[slot_id] and arena_data.players[slot_id].slot_id) then -- could be player with empty table
				local eachplayer = arena_data.players[slot_id];
				local player = ParaScene_GetObject(tostring(eachplayer.nid));
				if(player and player:IsValid() == true) then
					if(isFrozen) then
						FrozenEffect.ApplyFrozenEffect(player);
						if(freeze_buffChar and freeze_buffChar:IsValid() == true) then
							freeze_buffChar:SetFacing(player:GetFacing());
							freeze_buffChar:SetPosition(player:GetPosition());
						end
					elseif(isStealth) then
						TransparentEffect.Apply(player);
						TransparentEffect.SetDiffuseColor(0.8, 0.8, 0.8);
					elseif(isStone) then
						StoneEffect.ApplyEffect(player);
						local params = player:GetEffectParamBlock();
						params:SetFloat("transitionFactor", 1);
					else
						FrozenEffect.ResetEffect(player);
					end
				end
				local player_driver = ParaScene_GetObject(tostring(eachplayer.nid).."+driver");
				if(player_driver and player_driver:IsValid() == true) then
					if(isFrozen) then
						FrozenEffect.ApplyFrozenEffect(player_driver);
					elseif(isStealth) then
						TransparentEffect.Apply(player_driver);
						TransparentEffect.SetDiffuseColor(0.8, 0.8, 0.8);
					elseif(isStone) then
						StoneEffect.ApplyEffect(player_driver);
						local params = player:GetEffectParamBlock();
						params:SetFloat("transitionFactor", 1);
					else
						FrozenEffect.ResetEffect(player_driver);
					end
				end

			elseif(arena_data and arena_data.mobs and arena_data.mobs[slot_id - 4]) then
				local eachmob = arena_data.mobs[slot_id - 4];
				local mob_char = NPC.GetNpcCharacterFromIDAndInstance(39001, eachmob.id);
				if(mob_char and mob_char:IsValid() == true) then
					if(isFrozen) then
						FrozenEffect.ApplyFrozenEffect(mob_char);
						if(freeze_buffChar and freeze_buffChar:IsValid() == true) then
							freeze_buffChar:SetFacing(mob_char:GetFacing());
							freeze_buffChar:SetPosition(mob_char:GetPosition());
						end
					elseif(isStealth) then
						TransparentEffect.Apply(mob_char);
						TransparentEffect.SetDiffuseColor(0.8, 0.8, 0.8);
					elseif(isStone) then
						StoneEffect.ApplyEffect(mob_char);
						local params = player:GetEffectParamBlock();
						params:SetFloat("transitionFactor", 1);
					else
						FrozenEffect.ResetEffect(mob_char);
					end
				end
			end
		end

		if(nBufCount > 0)then
			arena_meta.bHasBuff = true;
			model_buffslot:SetField("SkipRender", false);
			return true;
		else
			model_buffslot:SetField("SkipRender", true);
			return false;
		end
	end
	return (nBufCount > 0);
end

-- refresh all buffs, such as charms, wards and overtimes. 
-- each arena has 8 slots, each slot has 3 animated char for charms, wards and overtimes, separately. 
--  each char has 12 attachment points on to which we can mount buff effects. 
-- This function will cache last buff on the arena_meta.slotbuffs. It will only perform update if buff data differs from last. 
-- @param slotbuffs: nil to remove all. or a table of {charms="", wards="1,2,", overtimes=""}. 
function ObjectManager.RefreshArenaBuffs(arena_id, slotbuffs, forcemove, arena_meta)
	arena_meta = arena_meta or MsgHandler.Get_arena_meta_data_by_id(arena_id);
	if(not slotbuffs) then
		if(not arena_meta.bHasBuff) then
			return 
		end
		-- remove them all. 
		slotbuffs = {};
	end
	local bHasBuff;
	local i;
	for i = 1, 8 do
		local buffs = slotbuffs[i] or {};
		
		bHasBuff = ObjectManager.RefreshBuffs(arena_id, i, "charm", buffs.charms, arena_meta) or bHasBuff;
		bHasBuff = ObjectManager.RefreshBuffs(arena_id, i, "ward", buffs.wards, arena_meta) or bHasBuff; 
		bHasBuff = ObjectManager.RefreshBuffs(arena_id, i, "overtime", buffs.overtimes, arena_meta) or bHasBuff; 
		bHasBuff = ObjectManager.RefreshBuffs(arena_id, i, "miniaura", buffs.miniaura, arena_meta) or bHasBuff; 
	end
	arena_meta.bHasBuff = bHasBuff;
end

-- buff string to table
-- @param str: buff string
-- NOTE: e.x. input "1,2,3,4" --> output {1,2,3,4}
--			  input "fire,water," --> output {"fire","water"}
function ObjectManager.BuffStringToTable(str)
	str = str or "";
	local t = {};
	local unit;
	for unit in string.gmatch(str, "[^,]+") do
		if(tonumber(unit)) then
			table_insert(t, tonumber(unit));
		else
			table_insert(t, unit);
		end
	end
	return t;
end

-- refresh buffs
-- @params arena_id: arena id
-- @params slot_id: slot id 1 to 8
-- @params level: "charm" or "ward" or "overtime"
-- @params anim: anim id 0 or 4
function ObjectManager.PlayAnimSlots(arena_id, slot_id, level, anim)
	if(not arena_id or not slot_id or not level or not anim) then
		log("error: nil param in function ObjectManager.PlayAnimSlots\n");
		commonlib.echo({arena_id, slot_id, level, anim});
		return;
	end

	local buffslot_id = 0;
	if(level == "charm") then
		buffslot_id = 0;
	elseif(level == "ward") then
		buffslot_id = 1;
	elseif(level == "overtime") then
		buffslot_id = 2;
	end

	local buffslot_npcid = ObjectManager.GetBuffSlot_NPC_ID(arena_id, slot_id, buffslot_id)
	local model_buffslot = NPC.GetNpcModelFromIDAndInstance(buffslot_npcid);
	if(model_buffslot and model_buffslot:IsValid() == true) then
		local att = model_buffslot:GetAttributeObject();
		att:SetField("AnimID", anim);
	end
end

-- refresh arena fled slots(show/hide a white flag for fleed players)
-- it will always checks the arena_meta first before making any changes to the game scene.
-- @param arena_id: arena id
-- @param fledslots: e.x. {true, nil, true, nil}
-- @return true if has at least one fled
function ObjectManager.RefreshFledSlots(arena_id, fledslots, arena_meta)
	arena_meta = arena_meta or MsgHandler.Get_arena_meta_data_by_id(arena_id);
	if(not fledslots) then
		if(not arena_meta.bHasfleds) then
			return;
		end
		fledslots = {};
	end
	last_fledslots = arena_meta.fledslots;
	if(not last_fledslots) then
		last_fledslots = {};
		arena_meta.fledslots = last_fledslots;
	end
	local bHasfleds;
	local slot_id;
	for slot_id = 1, 8 do
		local isFled = fledslots[slot_id] == true;
		local last_isFled = last_fledslots[slot_id] == true;
		
		if(isFled) then
			bHasfleds = true;
		end
		if(isFled ~= last_isFled) then
			last_fledslots[slot_id] = isFled;
			
			if(isFled) then
				-- load the buffs with asset
				local slot_npcid = ObjectManager.GetSlot_NPC_ID(arena_id, slot_id);
				local char_slot = NPC.GetNpcCharacterFromIDAndInstance(slot_npcid);
				if(char_slot and char_slot:IsValid() == true) then
					local fledslot_name = ObjectManager.GetFledSlot_Name(arena_id, slot_id)
					local fledslotChar = ParaScene_GetObject(fledslot_name);
					if(fledslotChar:IsValid() == false) then
						-- create the buff object on demand
						local toX, toY, toZ = char_slot:GetPosition();
						local obj_params = {};
						obj_params.name = fledslot_name;
						obj_params.x = toX;
						obj_params.y = toY;
						obj_params.z = toZ;
						obj_params.facing = char_slot:GetFacing();
						obj_params.AssetFile = "character/v5/09effect/Combat_Misc/DefeatedFlag/DefeatedFlag.x";
						obj_params.IsCharacter = true;
						-- skip saving to history for recording or undo.
						System.SendMessage_obj({type = Map3DSystem.msg.OBJ_CreateObject, obj_params = obj_params, SkipHistory = true, silentmode = true,});
					end
					fledslotChar:SetVisible(true);
				end
			else
				local fledslot_name = ObjectManager.GetFledSlot_Name(arena_id, slot_id)
				local fledslotChar = ParaScene_GetObject(fledslot_name);
				if(fledslotChar:IsValid()) then
					fledslotChar:SetVisible(false);
				end
			end
		end
	end
	arena_meta.bHasfleds = bHasfleds;
	return bHasfleds;
end

local slot_id_facing_mapping = {
	[1] = 2.2,
	[2] = 2.83,
	[3] = 3.455,
	[4] = 4.08,
	[5] = 5.34,
	[6] = 5.97,
	[7] = 6.60,
	[8] = 7.23,
};

-- set the arena arrow pointer visible attribute
function ObjectManager.SetSequenceArrowVisible(arena_id, bVisible)
	if(arena_id and (bVisible == true or bVisible == false)) then
		local arrow = NPC.GetNpcModelFromIDAndInstance(ObjectManager.GetSlot_NPC_ID(arena_id, 9));
		if(arrow) then
			arrow:SetField("visible", bVisible);
		end
	end
end

-- sequence arrow
-- @param arena_id:
-- @param from_slot_id: from slot id, if it is nil or 0, immediate set
-- @param to_slot_id: to slot id
-- @param finish_callback: finish callback invoked when the animation is finished
function ObjectManager.ShowSequenceArrow(arena_id, from_slot_id, to_slot_id, finish_callback)
	local NPC = NPC;
	local arena_model = NPC.GetNpcModelFromIDAndInstance(ObjectManager.GetArena_NPC_ID(arena_id));
	if(arena_model) then
		local arrow = NPC.GetNpcCharacterFromIDAndInstance(ObjectManager.GetSlot_NPC_ID(arena_id, 9));
		if(arrow) then
			-- arrow is already created
			ObjectManager.AnimateArrow(arena_id, from_slot_id, to_slot_id, function()
				if(finish_callback) then
					finish_callback();
				end
			end);
			return;
		end
		local i = 0;
		local toX, toY, toZ = arena_model:GetXRefScriptPosition(8);
		local params = {
			position = {toX, toY, toZ},
			assetfile_char = "character/common/dummy/cube_size/cube_size.x",
			--assetfile_char = "character/v5/09effect/Combat_Common/SequenceArrow/sequence_arrow.x",
			assetfile_model = ObjectManager.GetSequenceArrowAsset(arena_id),
			--assetfile_model = ObjectManager.GetBasicArenaAsset(arena_id),
			--assetfile_model = "model/01building/v5/01house/SkyWheel/SkyWheel.x",
			--assetfile_model = "model/06props/v5/06combat/Common/Slot/normal_slot.x",
			facing = slot_id_facing_mapping[to_slot_id],
			name = "",
			----scaling = 4,
			--scale_char = 0.65,
			----scaling_model = 1,
			scale_char = 0.0001,
			scaling_model = 1,
			EnablePhysics = false, -- disable sequence arrow physics
			isdummy = true,
		};
		NPC.CreateNPCCharacter(ObjectManager.GetSlot_NPC_ID(arena_id, 9), params);
	end
	local arrow = NPC.GetNpcModelFromIDAndInstance(ObjectManager.GetSlot_NPC_ID(arena_id, 9));
	if(arrow) then
		-- continue target arrow pointer animation
		local att = arrow:GetAttributeObject();
		att:SetField("AnimID", 70 + to_slot_id);
	end
	if(finish_callback) then
		finish_callback();
	end
end

function ObjectManager.AnimateArrow(arena_id, from_slot_id, to_slot_id, finish_callback)
	local NPC = NPC;
	local arena_model = NPC.GetNpcModelFromIDAndInstance(ObjectManager.GetArena_NPC_ID(arena_id));
	if(arena_model) then
		local arrow = NPC.GetNpcModelFromIDAndInstance(ObjectManager.GetSlot_NPC_ID(arena_id, 9));
		if(arrow) then
			-- arrow is already created
			from_slot_id = from_slot_id or to_slot_id;
			if(from_slot_id ~= to_slot_id) then
				local att = arrow:GetAttributeObject();
				att:SetField("AnimID", 0);
			end
			local current_facing = slot_id_facing_mapping[from_slot_id];
			local target_facing = slot_id_facing_mapping[to_slot_id];
			if(math.abs(current_facing - target_facing) < 0.1) then
				-- if the arrow is too close, means some flip animation
				current_facing = target_facing;
			end
			if(current_facing > target_facing) then
				target_facing = target_facing + math.pi * 2;
			end
			--local current_facing = arrow:GetFacing();
			--local target_facing = slot_id_facing_mapping[to_slot_id];
			--if(current_facing < 0) then
				--current_facing = current_facing + math.pi * 2;
			--end
			--while(true) do
				--if(target_facing < current_facing) then
					--target_facing = target_facing + math.pi * 2;
				--elseif(target_facing > current_facing + math.pi * 2) then
					--target_facing = target_facing - math.pi * 2;
				--else
					--break;
				--end
			--end
			--local arrow_name = arrow.name;
			--if(math.abs((current_facing + math.pi * 2) - target_facing) < 0.1) then
				---- if the arrow is too close, means some flip animation
				--current_facing = target_facing;
			--end
			local total_time = 200;
			local arrow_name = arrow.name;
			UIAnimManager.PlayCustomAnimation(total_time, function(elapsedTime)
				local arrow = ParaScene_GetObject(arrow_name);
				if(arrow and arrow:IsValid() == true) then
					if(elapsedTime == total_time) then
						arrow:SetFacing(target_facing);
						local att = arrow:GetAttributeObject();
						att:SetField("AnimID", 70 + to_slot_id);
						-- wait another total_time ms to halt the arrow animation
						UIAnimManager.PlayCustomAnimation(total_time, function(elapsedTime)
							if(elapsedTime == total_time) then
								if(finish_callback) then
									finish_callback();
								end
							end
						end);
					else
						local rate = elapsedTime / total_time;
						local this_facing = current_facing + (target_facing - current_facing) * rate;
						arrow:SetFacing(this_facing);
					end
				end
			end);
			-- return  otherwise the finish_callback will be called twice
			return;
		end
	end
	if(finish_callback) then
		--_guihelper.MessageBox("get log r4\n")
		finish_callback();
	end
end

-- destroy sequence arrow
function ObjectManager.DestroySequenceArrow(arena_id)
	NPC.DeleteNPCCharacter(ObjectManager.GetSlot_NPC_ID(arena_id, 9));
end

local treasurebox_asset_mapping = {
	["default"] = "model/06props/v5/03quest/TreasureBox/TreasureBox_04.x",
	["FireCavern"] = "model/06props/v5/03quest/TreasureBox/TreasureBox_04.x",
	["TheGreatTree"] = "model/06props/v5/03quest/TreasureBox/TreasureBox_02.x",
};

-- show treasure box
-- @param arena_id:
-- @param treasurebox: {loot_id, position, facing}
function ObjectManager.ShowTreasureBox(arena_id, treasurebox)
	if(not arena_id or not treasurebox) then
		log("error: ObjectManager.ShowTreasureBox got invalid input:".. commonlib.serialize({arena_id, treasurebox}));
		return;
	end
	local treasurebox_asset = treasurebox_asset_mapping[treasurebox.loot_id] or treasurebox_asset_mapping["default"];
	local NPC = NPC;
	local arena_model = NPC.GetNpcModelFromIDAndInstance(ObjectManager.GetArena_NPC_ID(arena_id));
	if(arena_model) then
		local treasurebox_model = NPC.GetNpcModelFromIDAndInstance(ObjectManager.GetArena_TreasureBox_NPC_ID(arena_id));
		if(treasurebox_model) then
			---- treasurebox is already created
			--if(treasurebox_model:GetPrimaryAsset():GetKeyName() ~= treasurebox_asset) then
				---- change treasurebox asset if needed
				--local asset = ParaAsset.LoadParaX("", treasurebox_asset);
				--treasurebox:ToCharacter():ResetBaseModel(asset);
			--end
			return;
		end
		local i = 0;
		local params = {
			position = {treasurebox.position.x, treasurebox.position.y, treasurebox.position.z},
			assetfile_char = "character/common/dummy/cube_size/cube_size.x",skiprender_char = true,
			assetfile_model = treasurebox_asset,
			--assetfile_model = ObjectManager.GetSequenceArrowAsset(arena_id),
			--assetfile_model = ObjectManager.GetBasicArenaAsset(arena_id),
			--assetfile_model = "model/01building/v5/01house/SkyWheel/SkyWheel.x",
			--assetfile_model = "model/06props/v5/06combat/Common/Slot/normal_slot.x",
			facing = 0,
			name = "",
			----scaling = 4,
			--scale_char = 0.65,
			----scaling_model = 1,
			scale_char = 2,
			scaling_model = 1,
			EnablePhysics = true,
			cursor = "Texture/Aries/Cursor/TreasureBox.tga",
			main_script = "script/apps/Aries/NPCs/Combat/39000_BasicArena.lua",
			main_function = "MyCompany.Aries.Quest.NPCs.BasicArena_Treasurebox.main();",
			predialog_function = "MyCompany.Aries.Quest.NPCs.BasicArena_Treasurebox.PreDialog",
			selected_page = "script/apps/Aries/Desktop/SelectionResponse/CommonNPC_Empty.html",
			isdummy = true,
		};
		NPC.CreateNPCCharacter(ObjectManager.GetArena_TreasureBox_NPC_ID(arena_id), params);
	end
	if(finish_callback) then
		--_guihelper.MessageBox("get log r1\n")
		finish_callback();
	end
end

-- destroy global treasure box
function ObjectManager.DestroyTreasureBox(arena_id)
	NPC.DeleteNPCCharacter(ObjectManager.GetArena_TreasureBox_NPC_ID(arena_id));
end

function ObjectManager.EnterArenaView(arena_id, params, bIncludedAnyBossMob)
	NPL.load("(gl)script/kids/3DMapSystemApp/worlds/RegionRadar.lua");
	System.App.worlds.Global_RegionRadar.End();
	-- suspend the GSL self update
	System.GSL.SuspendSelfUpdate(true);
	
	
	-- play a combat bg music
	local current_worlddir = ParaWorld.GetWorldDirectory();
	if(current_worlddir == "worlds/Instances/HaqiTown_RedMushroomArena/") then
		Scene.ReplaceBGMusic("Combat_RedMushroomArena")
	else
		if(System.options.version == "teen") then
			if(bIncludedAnyBossMob) then
				Scene.ReplaceBGMusic("Combat_Teen_Boss_TrialVersion")
			else
				Scene.ReplaceBGMusic("Combat_Teen_Common_TrialVersion")
			end
		else
			Scene.ReplaceBGMusic("Combat_Drumbeat")
		end
	end
end

function ObjectManager.LeaveArenaView(arena_id, params)
	local nid_str = tostring(ProfileManager.GetNID());
	if(nid_str == "localuser") then
		local player = GameLogic.EntityManager.GetPlayer();
		if(player) then
			player:GetInnerObject():ToCharacter():SetFocus();
		end
	else
		local avatar = ParaScene.GetCharacter(nid_str);
		if(avatar and avatar:IsValid()) then
			avatar:ToCharacter():SetFocus();
		end
	end
	-- restore bg music. 
	Scene.RestoreBGMusic()

	NPL.load("(gl)script/kids/3DMapSystemApp/worlds/RegionRadar.lua");
	System.App.worlds.Global_RegionRadar.Start();
	-- resume the GSL self update
	System.GSL.SuspendSelfUpdate(false);
end

local bHideIdleMobs = false;
function ObjectManager.GetIsHideIdleMobs()
	return bHideIdleMobs;
end
function ObjectManager.SetIsHideIdleMobs(bHide)
	bHideIdleMobs = bHide;
end