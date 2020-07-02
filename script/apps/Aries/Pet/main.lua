--[[
Title: customizable mount pet and follow pet implementation
Author(s): WangTian
Date: 2009/6/15
Desc: In aries project we support two kinds of pets, mount and follow
	Mount pet can be customized in 4 geometry parts: head, body, tail and wing.
	Mount pet experience 3 stages: spawn, minor and major
	In each stage mount pet have different visual states: follow(spawn), mount/follow(minor), fly/mount/follow(major)
	Follow pet can't be customized and doesn't have any growing stages
	Follow pet can only have one visual state: follow
	
	This file provides implementation and helper function to easily switch between states
	
	Character Naming, suppose we have the user named andy and OPC with #nid# in the scene:
		1. Myself if not riding mount pet: character "andy" with or without follow pet "andy+follow"
		2. Myself if riding mount pet: character "andy+driver" and mount pet "andy" with or without follow pet "andy+follow"
		3. OPC if not riding mount pet: character "#nid#@#domain#" with or without follow pet "#nid#@#domain#+follow"
		4. OPC if riding mount pet: character "#nid#@#domain#+driver" and mount pet "#nid#@#domain#" with or without follow pet "#nid#@#domain#+follow"
	These function helps get the specific character object
		GetUserCharacterObj:	"andy" or "andy+driver" or "#nid#@#domain#" or "#nid#@#domain#+driver"
		GetUserMountObj:		"andy" or "#nid#@#domain#"
		GetUserFollowObj:		"andy+follow" or "#nid#@#domain#+follow"
	
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Pet/main.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Mail/MailManager.lua");
NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
NPL.load("(gl)script/apps/Aries/Player/main.lua");
NPL.load("(gl)script/ide/Debugger/NPLProfiler.lua");
NPL.load("(gl)script/apps/Aries/Pet/DragonPetFactory.lua");
NPL.load("(gl)script/apps/Aries/Mail/MailManager.lua");
NPL.load("(gl)script/apps/Aries/Mail/MailManager_MagicStar.lua");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
local MailManager = commonlib.gettable("MyCompany.Aries.Quest.Mail.MailManager")
local MailManager_MagicStar = commonlib.gettable("MyCompany.Aries.Quest.Mail.MailManager_MagicStar");
local npl_profiler = commonlib.gettable("commonlib.npl_profiler");
local tostring = tostring
local tonumber = tonumber
local type = type
local LOG = LOG;

local string_find = string.find;
local string_format = string.format;
local format = format;
local string_match = string.match;

local ProfileManager = commonlib.gettable("System.App.profiles.ProfileManager");
local ItemManager = commonlib.gettable("System.Item.ItemManager");
local CCS = commonlib.gettable("Map3DSystem.UI.CCS")
local Predefined = commonlib.gettable("Map3DSystem.UI.CCS.Predefined")
local Player = commonlib.gettable("MyCompany.Aries.Player");
local EffectManager = commonlib.gettable("MyCompany.Aries.EffectManager");
local Scene = commonlib.gettable("MyCompany.Aries.Scene");
local HomeProfilePage = commonlib.gettable("MyCompany.Aries.Inventory.HomeProfilePage");
local ParaScene_GetCharacter = commonlib.getfield("ParaScene.GetCharacter");
local LOG = LOG;
local MyCompany = MyCompany;
local SentientGroupIDs = commonlib.gettable("MyCompany.Aries.SentientGroupIDs");
SentientGroupIDs.Player = 3; 
SentientGroupIDs.OPC = 4; 
SentientGroupIDs.MountPet = 5; 
SentientGroupIDs.FollowPet = 6;
SentientGroupIDs.NPC = 7;

-- when indoor mode, the biped is not mounted. 
local indoor_mode_nids = {};

NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetHelper.lua");
local CombatPetHelper = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetHelper");

NPL.load("(gl)script/apps/Aries/Combat/main.lua");
local Combat = commonlib.gettable("MyCompany.Aries.Combat");

-- scaling factored applied to all characters. 
local main_char_scaling = 1.6105;
local mount_char_scaling = main_char_scaling;
local follow_char_scaling = main_char_scaling;

-- override the sentient groups in GSL agent
local GSL_SentientGroupIDs = commonlib.gettable("Map3DSystem.GSL.SentientGroupIDs");
GSL_SentientGroupIDs.Player = SentientGroupIDs.Player;
GSL_SentientGroupIDs.OPC = SentientGroupIDs.OPC;

local ItemManager = commonlib.gettable("System.Item.ItemManager");

-- GM player asset file
local GM_assetfile = "character/v5/01human/TownChiefRodd/TownChiefRodd.x";

NPL.load("(gl)script/apps/Aries/Combat/MsgHandler.lua");
local MsgHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");

-- create class
local libName = "AriesPet";
local Pet = commonlib.gettable("MyCompany.Aries.Pet");
local Player = commonlib.gettable("MyCompany.Aries.Player");

-- last applied full ccs mapping
local last_applied_full_ccs_mapping = {};

-- render importance of main players and its pets. 
Pet.main_player_render_importance = 2;

-- speed scale and vip level mapping
local speed_scale_magicstarlevel_mapping = {1.1, 1.1, 1.15, 1.15, 1.2, 1.2, 1.25, 1.25, 1.3, 1.3};

local tips_gsid22000 = "训练点";

-- reset scaling
function Pet.ResetDefaultScaling(main_char, mount_char, follow_char)
	main_char_scaling = main_char or mount_char_scaling
	mount_char_scaling = mount_char or mount_char_scaling
	follow_char_scaling = follow_char or follow_char_scaling
end

function Pet.GetFollowPetScaling()
	return follow_char_scaling
end

function Pet.GetMountPetScaling()
	return mount_char_scaling
end

function Pet.GetMainCharScaling()
	return main_char_scaling
end

-- invoked at MyCompany.Aries.OnActivateDesktop()
function Pet.Init()
	-- hook into deleteobj, and delete the pet before the player is deleted
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC, 
		callback = Pet.Hook_SceneObjectDeleted, 
		hookName = "PetDeleteHook", appName = "scene", wndName = "object"});
	
	-- clear last applied full ccs mapping
	Pet.ClearLastAppliedFullCCSMapping();

	if(System.options.version=="kids") then
		tips_gsid22000="训练点";
	else
		tips_gsid22000="潜力点";
	end

	---- set the density of the character to float on the water surface
	--local att = ParaScene.GetPlayer():GetAttributeObject();
	--att:SetField("Density", 0.7);
end

function Pet.ClearLastAppliedFullCCSMapping()
	-- clear last applied full ccs mapping
	last_applied_full_ccs_mapping = {};
end

Pet.setting_map = nil;

-- this will load from "config/Aries/Others/all_pets_settings.xml" and "config/Aries/Others/all_pets.xml"
function Pet.LoadPetSettings()
	if(Pet.setting_map) then
		return;
	end
	Pet.setting_map = {};
	
	local function translate_node(attr, is_create_new)
		local o;
		if(not is_create_new) then
			o = attr;
		end
		if(attr.name and attr.name~="") then
			o = o or {};
			o.name = attr.name;
		end
		if(attr.filename and attr.filename~="") then
			o = o or {};
			o.filename = attr.filename;
		end
		if(attr.gsid) then
			o = o or {};
			o.gsid = tonumber(attr.gsid);
		end
		if(attr.follow_speed) then
			o = o or {};
			o.follow_speed = tonumber(attr.follow_speed);
		end
		if(attr.follow_scale) then
			o = o or {};
			o.follow_scale = tonumber(attr.follow_scale);
		end
		if(attr.mount_scale) then
			o = o or {};
			o.mount_scale = tonumber(attr.mount_scale);
		end
		if(attr.scale) then
			o = o or {};
			o.scale = tonumber(attr.scale);
		end
		if(attr.can_fly) then
			o = o or {};
			o.can_fly = attr.can_fly == "true";
		end
		return o;
	end

	-- read from all_pets.xml
	local provider = CombatPetHelper.GetClientProvider();
	local _, all_pets = provider:GetReadOnlyXmlNode()
	if(all_pets)then
		local gsid, petNode
		for gsid, petNode in pairs(all_pets) do
			if(petNode.attr) then
				local node = translate_node(petNode.attr, true);
				if(node) then
					Pet.setting_map[gsid] = node;
				end
			end
		end
	else
		LOG.std("", "warn", "Pet", "provider:GetReadOnlyXmlNode() has no pet defined")
	end

	-- also merge data settings from all_pets.xml, please note this will overwrite data from previous file.
	Pet.configFilePath = if_else(System.options.version=="kids", "config/Aries/Others/all_pets_settings.xml", "config/Aries/Others/all_pets_settings.teen.xml");
	local xmlRoot = ParaXML.LuaXML_ParseFile(Pet.configFilePath);
	if(xmlRoot)then
		local modelNode;
		for modelNode in commonlib.XPath.eachNode(xmlRoot,"//pets/pet")do
			local attr = modelNode.attr;
			if(attr)then
				translate_node(attr);
				if(attr.filename) then
					local keyname = string.lower(attr.filename);
					local old_setting = Pet.setting_map[keyname];
					if(not old_setting or not attr.gsid) then
						Pet.setting_map[keyname] = attr;
					end
				end
				if(attr.gsid) then
					Pet.setting_map[tonumber(attr.gsid)] = attr;
				end
			end
		end
		LOG.std("", "info", "Pet", "pet settings file loaded from %s", Pet.configFilePath)
	else
		LOG.std("", "warn", "Pet", "can not open pet settings file from %s", Pet.configFilePath)
	end
end

--@param assetFile: this can be asset file name or pet's gsid. 
--@param fieldname: "follow_speed", "follow_scale", "mount_scale". if nil, the entire pet setting table is returned. 
--@return nil or number
function Pet.QueryPetSetting(assetFile, fieldname)
	if(Pet.setting_map == nil)then
		Pet.LoadPetSettings();
	end

	if(Pet.setting_map)then
		local name;
		if(type(assetFile) == "string") then
			name = string.lower(assetFile);
		elseif(type(assetFile) == "number") then
			name = assetFile;
		end

		if(name) then
			local setting = Pet.setting_map[name];
			if(setting)then
				if(fieldname) then
					return setting[fieldname];
				else
					return setting;
				end
			end
		end
	end
end

-- NOTE: 2010-7-7: write some thing
function Pet.GetRealPlayer()
	local name = Pet.GetUserCharacterName()
	return ParaScene.GetObject(name);
end

-- get real player name
-- @nid: nid of the user, nil means the user himself
-- @return: name of the player
function Pet.GetUserCharacterName(nid)
	local name;
	if(nid == nil or nid == ProfileManager.GetNID()) then
		-- user himself
		name = Player.RealPlayerName;
		if(not name or name == "") then
			name = tostring(ProfileManager.GetNID());
		end
	elseif(nid) then
		-- other player
		--name = nid.."@"..paraworld.GetDomain();
		name = tostring(nid);
	end
	return name;
end

-- get real player character object
-- @nid: nid of the user, nil means the user himself
-- @return: character object or nil if not found
function Pet.GetUserCharacterObj(nid)
	local name;
	if(nid == nil or nid == ProfileManager.GetNID()) then
		-- user himself
		name = Player.RealPlayerName;
		if(not name or name == "") then
			name = tostring(nid);
		end
	elseif(nid) then
		-- other player
		--name = nid.."@"..paraworld.GetDomain();
		name = tostring(nid);
	end
	-- check for driver first and then character himself
	local obj = ParaScene_GetCharacter(name.."+driver");
	if(obj:IsValid() == true) then
		return obj;
	else
		obj = ParaScene_GetCharacter(name);
		if(obj:IsValid() == true) then
			return obj;
		end
	end
end

-- get real player mount pet object
-- @nid: nid of the user, nil means the user himself
-- @return: character object or nil if not found
function Pet.GetUserMountObj(nid)
	local name = Pet.GetUserCharacterName(nid) or "";
	-- check for driver first and then character himself
	local obj = ParaScene_GetCharacter(name.."+driver");
	if(obj:IsValid() == true) then
		obj = ParaScene_GetCharacter(name);
		if(obj:IsValid() == true) then
			return obj;
		end
	end
	local obj = ParaScene_GetCharacter(name.."+mountpet-follow");
	if(obj:IsValid() == true) then
		return obj;
	end
end

-- get real player follow pet object name
-- @nid: nid of the user, nil means the user himself
-- @return: name of the follow pet
function Pet.GetUserFollowPetName(nid)
	local name;
	if(nid == nil or nid == ProfileManager.GetNID()) then
		-- user himself
		name = Player.RealPlayerName;
	elseif(nid) then
		-- other player
		--name = nid.."@"..paraworld.GetDomain();
		name = tostring(nid);
	end
	return name.."+followpet";
end

-- get real player follow pet object
-- @nid: nid of the user, nil means the user himself
-- @return: character object or nil if not found
function Pet.GetUserFollowObj(nid)
	local name = Pet.GetUserCharacterName(nid) or "";
	-- check for driver first and then character himself
	local obj = ParaScene_GetCharacter(name.."+followpet");
	if(obj:IsValid() == true) then
		return obj;
	end
end

-- get the pet in memory
-- @param guid: item instance guid
-- @return: pet item
function Pet.GetUserPetInMemory(guid)
	return ItemManager.GetItemByGUID(guid);
end

-- refresh my pets in homeland
-- @param hide_map:(leio added)include a gsid map record whose gsid not create in homeland
function Pet.RefreshMyPetsFromMemoryInHomeland(hide_map)
	local petNames = {};
	hide_map = hide_map or {};
	-- get all biped objects, and record all pet names
	local player = ParaScene.GetObject("<player>");
	local playerCur = player;
	while(playerCur:IsValid() == true) do
		-- get next object
		playerCur = ParaScene.GetNextObject(playerCur);
		if(playerCur:IsCharacter()) then
			-- record all pet names
			local name = playerCur.name;
			if(string_find(name, "MyFollowPet:")) then
				local guid = string.gsub(name, "MyFollowPet:", "");
				guid = tonumber(guid);
				if(guid) then
					petNames[guid] = name;
				end
			elseif(string_find(name, "MyMountPet:")) then
				local guid = string.gsub(name, "MyMountPet:", "");
				guid = tonumber(guid);
				if(guid) then
					petNames[guid] = name;
				end
			end
		end
		-- if cycled to the player character
		if(playerCur:equals(player)) then
			break;
		end
	end
	
	-- load all pet characters
	local ItemManager = ItemManager;
	local count = ItemManager.GetPetCountInHomeland();
	local i;
	for i = 1, count do
		local item = ItemManager.GetPetByOrder(nil, i);
		if(item and item.guid > 0) then
			if(not hide_map[item.gsid])then
				-- remove from the pet name list
				petNames[item.guid] = nil;
				-- create the pet in homeland
				if(item and item.CreateSceneObjectInHomeland) then
					item:CreateSceneObjectInHomeland();
				end
			end
			---- NOTE by Andy: Leio, i just add the pets into the scene and make them random walk
			--MyCompany.Aries.Pet.CreateMyPetInHomeland(item.guid);
		end
	end
	
	-- remove non-exist pets
	local guid, name;
	for guid, name in pairs(petNames) do
		local removedPet = ParaScene.GetObject(name);
		if(removedPet and removedPet:IsValid() == true) then
			ParaScene.Delete(removedPet);
		end
	end
end

-- hide my pets in homeland
function Pet.HideMyPetsFromMemoryInHomeland()
	local petNames = {};
	-- get all biped objects, and record all pet names
	local player = ParaScene.GetObject("<player>");
	local playerCur = player;
	while(playerCur:IsValid() == true) do
		-- get next object
		playerCur = ParaScene.GetNextObject(playerCur);
		if(playerCur:IsValid() and playerCur:IsCharacter()) then
			-- record all pet names
			if(string_find(playerCur.name, "MyFollowPet:")) then
				local guid = string.gsub(playerCur.name, "MyFollowPet:", "");
				guid = tonumber(guid);
				if(guid) then
					petNames[guid] = playerCur.name;
				end
			elseif(string_find(playerCur.name, "MyMountPet:")) then
				local guid = string.gsub(playerCur.name, "MyMountPet:", "");
				guid = tonumber(guid);
				if(guid) then
					petNames[guid] = playerCur.name;
				end
			end
		end
		-- if cycled to the player character
		if(playerCur:equals(player) == true) then
			break;
		end
	end
	
	local guid, name;
	for guid, name in pairs(petNames) do
		local pet = ParaScene.GetObject(name);
        if(pet and pet:IsValid() == true) then
            local petChar = pet:ToCharacter();
            petChar:Stop();
            local att = pet:GetAttributeObject();
			att:SetField("On_Perception", "");
			att:SetField("On_FrameMove", "");
            -- hide the pet from scene, teleport to 10000 meters below ground
            local params = {
                asset_file = "character/v5/09effect/Disappear/Disappear.x",
                binding_obj_name = pet.name,
                start_position = nil,
                duration_time = 1500,
                force_name = "HidePetInHomelandEffect_"..pet.name,
                begin_callback = function() end,
                end_callback = nil,
                stage1_time = 800,
                stage1_callback = function()
						EffectManager.StopBinding("HidePetInHomelandEffect_"..pet.name);
						local pet = ParaScene.GetObject(name);
						if(pet and pet:IsValid() == true) then
							local px, py, pz = pet:GetPosition();
							pet:SetPosition(px, (py - 10000), pz);
						end
	                end,
                stage2_time = nil,
                stage2_callback = nil,
            };
            EffectManager.CreateEffect(params);
        end
	end
end

-- refresh my pets in homeland
-- @param nid: nid of the OPC
function Pet.RefreshOPCPetsFromMemoryInHomeland(nid)
	if(not nid or nid == ProfileManager.GetNID()) then
		log("error: not valid nid or myself in Pet.RefreshOPCPetsFromMemoryInHomeland\n");
		return;
	end
	local petNames = {};
	-- get all biped objects, and record all pet names
	local player = ParaScene.GetObject("<player>");
	local playerCur = player;
	while(playerCur:IsValid() == true) do
		-- get next object
		playerCur = ParaScene.GetNextObject(playerCur);
		if(playerCur:IsValid() and playerCur:IsCharacter()) then
			-- record all pet names
			if(string_find(playerCur.name, nid.."FollowPet:")) then
				local guid = string.gsub(playerCur.name, nid.."FollowPet:", "");
				guid = tonumber(guid);
				if(guid) then
					petNames[guid] = playerCur.name;
				end
			elseif(string_find(playerCur.name, nid.."MountPet:")) then
				local guid = string.gsub(playerCur.name, nid.."MountPet:", "");
				guid = tonumber(guid);
				if(guid) then
					petNames[guid] = playerCur.name;
				end
			end
		end
		-- if cycled to the player character
		if(playerCur:equals(player) == true) then
			break;
		end
	end
	
	-- load all pet characters
	local ItemManager = ItemManager;
	local count = ItemManager.GetPetCountInHomeland(nid);
	local i;
	for i = 1, count do
		local item = ItemManager.GetPetByOrder(nid, i);
		if(item and item.guid > 0) then
			-- remove from the pet name list
			petNames[item.guid] = nil;
			-- create the pet in homeland
			if(item and item.CreateSceneObjectInHomeland) then
				item:CreateSceneObjectInHomeland();
			end
			---- NOTE by Andy: Leio, i just add the pets into the scene and make them random walk
			--MyCompany.Aries.Pet.CreateOPCPetInHomeland(nid, item.guid);
		end
	end
	
	-- remove non-exist pets
	local guid, name;
	for guid, name in pairs(petNames) do
		local removedPet = ParaScene.GetObject(name);
		if(removedPet and removedPet:IsValid() == true) then
			ParaScene.Delete(removedPet);
		end
	end
end

-- hook into deleteobj, and delete the pet before the player is deleted
function Pet.Hook_SceneObjectDeleted(nCode, appName, msg)
	if(not nCode) then return end
	if(msg.type == Map3DSystem.msg.OBJ_DeleteObject) then
		-- this is a standalone computer or a character. 
		local obj = Map3DSystem.obj.GetObjectInMsg(msg);
		if(obj and obj:IsCharacter()) then
			if(obj:GetDynamicField("IsOPC", false)) then
				-- 2010/6/28: if the player is in combat skip delete the character
				if(obj:GetDynamicField("IsInCombat", false)) then
					-- skip the object delete if the character is an incombat character
					return;
				end
				-- set last applied ccs info deprecated, otherwise the player will skip the ccs application
				last_applied_full_ccs_mapping[obj.name] = nil;
				local obj_name = obj.name;
				-- delete the follow pet if available
				local _followpet = ParaScene_GetCharacter(obj_name.."+followpet");
				if(_followpet and _followpet:IsValid() == true) then
					ParaScene.Delete(_followpet);
				end
				-- delete the mount pet follow if available
				local _mountpet_follow = ParaScene_GetCharacter(obj_name.."+mountpet-follow");
				if(_mountpet_follow and _mountpet_follow:IsValid() == true) then
					ParaScene.Delete(_mountpet_follow);
				end
				--local _mountpet_follow_effect = ParaScene_GetCharacter(obj_name.."+mountpet-follow-effect");
				--if(_mountpet_follow_effect and _mountpet_follow_effect:IsValid() == true) then
					--ParaScene.Delete(_mountpet_follow_effect);
				--end
				-- delete the driver if available
				local _driver = ParaScene_GetCharacter(obj_name.."+driver");
				if(_driver and _driver:IsValid() == true) then
					ParaScene.Delete(_driver);
				end
				
				-- finally, delete the object itself. 
				ParaScene.Delete(obj);
				
				-- now return without running the default delete procedure. 
				return;
			end	
		end
	end	
	return nCode;
end

local bSkipFashionItemMode = nil;

function Pet.SetSkipFashionItemMode(bSkip)
	bSkipFashionItemMode = bSkip;
end

function Pet.GetSkipFashionItemMode()
	return bSkipFashionItemMode;
end

-- equip positions table includes all the positions that can be equiped with items
-- pet related functions are moved forward, since the user avataer is the mounted pet, and user is a driver on the pet
-- NOTE: 33 is a special position that will record the index order of the asset file in the descfile
-- NOTE: 34 is a special position that will record the status of the mount pet
-- NOTE: 30 is the VIP pet position -- Magic Star
-- NOTE: 41 is the race and gender of the character. such as 982 is elf teen female, 983 is elf teen male. empty means kids version. 
-- NOTE: 42 is the gem effect of the character. 
-- NOTE: 43 is the ring effect of the character. 
-- NOTE: 1-12: ccs attachments
-- NOTE: 51 is the base model -- 0 for elf, 1 for elf tean version, it can also be a string of custom characater. added  by LiXizhi 2011.4.7
-- NOTE: 52: multi-player mount: if available this is the nid to mount to 
local equip_positions = {34, 31, 32, 33, 40, 41, 42, 43, 44, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 35, 30, 51, 52};

-- get the users apparence information string, formerly known as the CCSInfoString
-- appareance information includes:
		-- avatar equipements 
		-- current mount pet 
		-- current mount pet customizable components
		-- current follow pet
-- @param bSkipPet: remove the mount pet, follow pet, magic star in ccs equip string
-- @param gender: nil or "female" or "male"
function Pet.GetMyEquipInfoString(bSkipPet, forceslots, gender)
	-- read skip fashion item mode before actually use
	if(bSkipFashionItemMode == nil) then
		if(MyCompany.Aries and MyCompany.Aries.app) then
			bSkipFashionItemMode = MyCompany.Aries.app:ReadConfig("bSkipFashionItemMode", false);
		elseif(SystemInfo.GetField("name") == "Taurus") then
			bSkipFashionItemMode = false;
		end
	end
	local isadopted = Pet.IsAdopted();
	local assetfile_id = Player.GetMyAvatarAssetFileID();

	local bSkipBack = false;
	local item = ItemManager.GetItemByBagAndPosition(0, 33);
	if(item) then
		local gsItem = ItemManager.GetGlobalStoreItemInMemory(item.gsid)
		if(gsItem) then
			-- 74 SkipBackItem? (C) 屏蔽背部物品标记 为1就是屏蔽背部物品 只能配在inventorytype=33上 也就是变身标记 儿童版第一次使用
			if(gsItem.template.stats[74]) then
				bSkipBack = true;
			end
		end
	end
	
	if(bSkipBack) then
		forceslots = forceslots or {};
		forceslots[8] = 0; -- back
		forceslots[70] = 0; -- fashion back
	end
	
	local is_kids_version = System.options.version == "kids";
	local equip_string = "";
	local ItemManager = ItemManager;
	local i, position;
	for i, position in ipairs(equip_positions) do
		if(position == 34) then
			-- 34 is a special position that will record the status of the mount pet
			-- 1 for mount
			-- 2 for follow
			-- 3 for mount flying
			local item = ItemManager.GetItemByBagAndPosition(0, 31);
			if(isadopted == true) then
				equip_string = equip_string.."0#"; -- 0 stands for default
			elseif(item and item.guid > 0) then
				if(item.clientdata and item.clientdata ~= "") then
					if(item.clientdata == "mount") then
						if(Player.IsFlying()) then
							equip_string = equip_string.."3#";
						else
							equip_string = equip_string.."1#";
						end
					elseif(item.clientdata == "follow") then
						equip_string = equip_string.."2#";
					else
						equip_string = equip_string.."0#"; -- 0 stands for default
					end
				else
					equip_string = equip_string.."0#"; -- 0 stands for default
				end
			else
				equip_string = equip_string.."0#"; -- 0 stands for default
			end
		elseif(position == 31) then
			-- 31 is the position of the dragon item, if the clientdata is "home" means the dragon is not around the user
			local item = ItemManager.GetItemByBagAndPosition(0, 31);
			local Player = Player;
			-- transformed gsid
			local transform_gsid = Player.transform_gsid;

			if(forceslots and forceslots[31]) then
				equip_string = equip_string..forceslots[31].."#";
			elseif(indoor_mode_nids[System.User.nid] or isadopted == true) then
				-- hide the mount pet
				equip_string = equip_string.."0#";
			elseif(item and item.guid > 0) then
				-- normal dragon update
				if(System.options.version == "teen") then
					if(transform_gsid) then
						equip_string = equip_string..transform_gsid.."#";
					else
						equip_string = equip_string.."0#";
					end
				elseif(item.clientdata and item.clientdata == "home") then
					equip_string = equip_string.."0#";
				elseif(item.clientdata and item.clientdata == "mount") then
					--local index = item:GetAssetFileIndex();
					--if(index == 1) then
						--log("ERROR: mount on mount pet when pet is still in egg stage\n");
						--equip_string = equip_string.."0#";
					--else
						if(transform_gsid) then
							equip_string = equip_string..transform_gsid.."#";
						else
							equip_string = equip_string..item.gsid.."#";
						end
					--end
				elseif(item.clientdata and item.clientdata == "follow") then
					if(transform_gsid) then
						equip_string = equip_string..transform_gsid.."#";
					else
						equip_string = equip_string..item.gsid.."#";
					end
				else
					-- including sophie
					equip_string = equip_string.."0#";
				end
			else
				equip_string = equip_string.."0#";
			end
		elseif(position == 32) then
			local bInCombat_Mark = "false";
			if(MsgHandler.IsInCombat()) then
				bInCombat_Mark = "true";
			end
			-- follow pet
			local item = ItemManager.GetItemByBagAndPosition(0, position);
			if(item and item.guid ~= 0) then
				local displayname = "";
				if(item.GetName_client) then
					displayname = item:GetName_client() or "";
				end
				displayname = string.gsub(displayname, "@", "_");
				displayname = string.gsub(displayname, "#", "_");
				if(item.GetCurLevelAssetID and item.GetQualityAndMaxQuality) then
					local asset_id = item:GetCurLevelAssetID();
					local quality = item:GetQualityAndMaxQuality();
					quality = quality or 0;
					if(asset_id and quality) then
						equip_string = equip_string..item.gsid..string.format("%03d", asset_id).."+"..bInCombat_Mark.."+"..quality.."+"..displayname.."#";
					else
						equip_string = equip_string..item.gsid.."000+"..bInCombat_Mark.."+0+"..displayname.."#";
					end
				else
					equip_string = equip_string..item.gsid.."000+"..bInCombat_Mark.."+0+"..displayname.."#";
				end
			else
				equip_string = equip_string.."0+"..bInCombat_Mark.."+0+#";
			end
		elseif(position == 33) then
			-- 33 is a special position that will record the index order of the asset file in the descfile
			local item = ItemManager.GetItemByBagAndPosition(0, 31);
			local index;
			if(item and item.guid > 0 and type(item.GetAssetFileIndex) == "function") then
				index = item:GetAssetFileIndex();
			end
			if(isadopted == true) then
				equip_string = equip_string.."0#";
			elseif(index) then
				equip_string = equip_string..index.."#";
			else
				equip_string = equip_string.."0".."#"; -- 0 stands for default asset file
			end
		elseif(position == 40) then
			---- record the dragon color assuming it will never change
			--local mynid = ProfileManager.GetNID();
			--Pet.MyDragonColor_gsids = Pet.MyDragonColor_gsids or {};
			--local color_gsid = Pet.MyDragonColor_gsids[mynid];
			--if(color_gsid == nil) then
				local item = ItemManager.GetItemByBagAndPosition(0, position);
				if(item and item.guid ~= 0) then
					color_gsid = item.gsid;
					if(item.clientdata and item.clientdata ~= "") then
						local gsid, date = string_match(item.clientdata, "^(.+)%+(.+)$");
						if(gsid and date) then
							gsid = tonumber(gsid);
							if(date == Scene.GetServerDate()) then
								color_gsid = gsid;
							end
						end
					end
					--Pet.MyDragonColor_gsids[mynid] = item.gsid;
				end
			--end
			if(isadopted == true) then
				equip_string = equip_string.."0#";
			else
				equip_string = equip_string..(color_gsid or "0").."#";
			end
		elseif(position == 30) then
			-- 30 is the VIP pet position -- Magic Star
			if(bSkipPet == true) then
				equip_string = equip_string.."0#";
			else
				local VIP = commonlib.getfield("MyCompany.Aries.VIP");
				if(VIP and VIP.IsVIPAndActivated and VIP.IsVIPAndActivated()) then -- compatible with taurus
					if(System.options.version == "teen") then
						equip_string = equip_string.."10000#";
					else
						-- 10000_MagicStar
						local item = ItemManager.GetItemByBagAndPosition(0, 30);
						if(item and item.guid > 0 and item.gsid == 10000) then
							-- get pet m level
							local bean = MyCompany.Aries.Pet.GetBean();
							if(bean and bean.mlel == 10) then
								-- 14001_FullRankMagicStar
								equip_string = equip_string.."14001#";
							else
								equip_string = equip_string.."10000#";
							end
						else
							equip_string = equip_string.."0#";
						end
					end
				else
					equip_string = equip_string.."0#";
				end
			end
		elseif(position == 41) then
			-- character gender and race 
			if(not gender) then
				equip_string = equip_string..(Player.GetMyAvatarAssetFileID().."#");
			else
				equip_string = equip_string..(if_else(gender=="female", 982, 983).."#");
			end
			
		elseif(position == 42) then
			-- character gender and race 
			equip_string = equip_string..(Player.GetMyGemEffectID().."#");
			
		elseif(position == 43) then
			-- character gender and race 
			equip_string = equip_string..(Player.GetMyRingEffectID().."#");

		elseif(position >= 44 and position <= 49) then
			-- dragon pet equips
			local item = ItemManager.GetItemByBagAndPosition(0, position);
			if(item and item.guid ~= 0) then
				equip_string = equip_string..item.gsid.."#";
			else
				equip_string = equip_string.."0#";
			end
		elseif(position < 30) then
			if(forceslots and forceslots[position]) then
				equip_string = equip_string..forceslots[position].."#";
			else
				local gsid = nil;
				-- check priority gsid
				if(position == 2) then
					-- fashion hat
					local item = ItemManager.GetItemByBagAndPosition(0, 18);
					if(item and item.guid ~= 0) then
						gsid = item.gsid;
					end
				elseif(position == 5) then
					-- fashion shirt
					local item = ItemManager.GetItemByBagAndPosition(0, 19);
					if(item and item.guid ~= 0) then
						gsid = item.gsid;
					end
				elseif(position == 8) then
					-- fashion back
					local item = ItemManager.GetItemByBagAndPosition(0, 70);
					if(item and item.guid ~= 0) then
						gsid = item.gsid;
					end
					-- fashion shirt with forced wing
					local item = ItemManager.GetItemByBagAndPosition(0, 19);
					if(item and item.guid ~= 0) then
						local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid)
						if(gsItem) then
							-- 72 Fashion_Replacement_GSID_bonus_wing(C) 时装所使用的强制翅膀 优先级比炫彩背还要高 儿童版第一次使用 S3的炫彩装 衣+翅膀 
							local replacement_wing_gsid = gsItem.template.stats[72];
							if(replacement_wing_gsid) then
								gsid = replacement_wing_gsid;
							end
						end
					end
				elseif(position == 7) then
					-- fashion boots
					local item = ItemManager.GetItemByBagAndPosition(0, 71);
					if(item and item.guid ~= 0) then
						gsid = item.gsid;
					end
				elseif(position == 11) then
					-- fashion right hand
					local item = ItemManager.GetItemByBagAndPosition(0, 72);
					if(item and item.guid ~= 0) then
						gsid = item.gsid;
					end
				elseif(position == 10) then
					---- fashion left hand
					--local item = ItemManager.GetItemByBagAndPosition(0, 72);
					--if(item and item.guid ~= 0) then
						--gsid = 0; -- empty left hand for fashion right hand item
					--end
				elseif(position == 9 and is_kids_version) then
					-- Gloves
					local item = ItemManager.GetItemByBagAndPosition(0, 9);
					if(item and item.guid ~= 0) then
						gsid = item.gsid;
					end
				end
				if(position == 9 and is_kids_version) then

				else
					if(is_kids_version) then
						if(bSkipFashionItemMode == true) then
							gsid = nil;
						end
						if(position == 2 or position == 5 or position == 7 or position == 8) then
							if(not gsid) then
								local item = ItemManager.GetItemByBagAndPosition(0, position);
								if(item and item.guid ~= 0) then
									gsid = item.gsid;
								end
							end
						end

						if(position == 11 or position == 15 or position == 16 or position == 17) then
							local item = ItemManager.GetItemByBagAndPosition(0, position);
							if(item and item.guid ~= 0) then
								gsid = item.gsid;
							end
						end

					else
						if(bSkipFashionItemMode == true) then
							gsid = nil;
						end
					end
				end

				if(gsid and gsid ~= 0) then -- "gsid ~= 0" for empty left hand on fashion right hand item
					local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid)
					if(gsItem) then
						-- 53 Fashion_Replacement_GSID
						local replacement_gsid = gsItem.template.stats[53];
						gsid = replacement_gsid;
					else
						gsid = nil;
					end
				end
				if(not gsid) then
					-- normal equips
					local item = ItemManager.GetItemByBagAndPosition(0, position);
					if(item and item.guid ~= 0) then
						gsid = item.gsid;
					else
						gsid = 0;
					end
				end
				
				if(System.options.version == "teen") then
					if(position == 2 and System.options.EnableForceHideHead) then
						-- hat
						gsid = 0;
					elseif(position == 8 and System.options.EnableForceHideBack) then
						-- back
						gsid = 0;
					end
				end
				
				if(not is_kids_version and gsid > 0) then
					local isUniSex = false;
					local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid)
					if(gsItem) then
						-- 187 is_unisex_teen(C)
						if(gsItem.template.stats[187] == 1) then
							isUniSex = true;
						end
					end
					if(isUniSex == true) then
						gsid = gsid + 30000;
					else
						if(assetfile_id == 982) then
							gsid = gsid + 40000;
						elseif(assetfile_id == 983) then
							gsid = gsid + 30000;
						end
					end
				end

				equip_string = equip_string..gsid.."#";
			end
		elseif(position == 35) then
			-- 35 is a special position that will record the additional effect on foot
			if(Player.isFreezed) then
				equip_string = equip_string.."1".."#";
			else
				equip_string = equip_string.."0".."#"; -- 0 stands for no effect
			end
		elseif(position == 51) then
			-- base model equipment string. 
			if(Player.asset_gsid) then
				equip_string = equip_string..Player.asset_gsid.."#";
			-- explicit asset file is no longer supported
			--elseif(not gender) then
			--	equip_string = equip_string..(Player.base_model_str or "0").."#";
			else
				equip_string = equip_string.."0#";
			end
		elseif(position == 52) then
			-- multi-player mount, mount target nid. 
			local player = Player.GetPlayer();
			local target_nid;
			-- add nid here if mounted
			if(not Player.IsInCombat() and player:ToCharacter():IsMounted()) then
				local BeingMountedObj = player:GetRefObject(0);
				if(BeingMountedObj:IsValid()) then
					target_nid = BeingMountedObj.name;
				end
			end
			equip_string = equip_string..(target_nid or "0").."#";
		end

	end
	
	if(bSkipPet == true) then
		if(System.options.version == "teen") then
			equip_string = string.gsub(equip_string, "%d+", "0", 5);
		else
			equip_string = string.gsub(equip_string, "%d+", "0", 9);
		end
	end
	return equip_string;
end

local FollowPet_HeadOnDisplayColor = {
	[0] = "200 255 255",
	[1] = "0 204 51",
	[2] = "0 153 255",
	[3] = "198 72 225",
	[4] = "255 154 0",
};


local ccs_equip_positions = {34, 31, 32, 33, 40, 41, 42, 43, 44, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 35, 30, 51, 52};

-- get mount pet, and transform
function CCS.GetCriticalGSIDfromCCS(sInfo)
	local _, _, equip_string = string_match(sInfo or "", "[^@]+@[^@]+@([^@]+)");

	local i = 0;
	local gsid, value_str;
	for value_str in string.gmatch(equip_string, "([^#]+)") do
		i = i + 1;
		local position = ccs_equip_positions[i];
		if(position == 31 or position == 32) then	
			-- 31 mount pet, 32 follow pet
			gsid = tonumber(value_str);
		elseif(position == 51) then	
			-- transform gsid.
			gsid = tonumber(value_str);
			if(gsid and gsid>10) then
			end
		end
	end
end


-- Note: this function needs to be optimized as much as possible. Right now, there are too many GetCharacter() calls. 
-- @return the elf character
-- @params forceslots: force set of the character slots, e.x. {[35]=1}
function Pet.ApplyEquipInfoString(obj_params, equip_string, forceslots)
	
	local obj;
	local playerChar;
	local _elf;

	if(type(obj_params) == "table") then
		obj = ObjEditor.GetObjectByParams(obj_params);
	elseif(type(obj_params) == "userdata") then
		obj = obj_params;
	else
		log("error: obj_params not table or userdata value.\n");
		return;
	end
	
	local isMounted = false;
	local obj_name;
	local IsMainPlayer;
	local mountpet_changed;

	local is_kids_version = System.options.version == "kids";

	-- get player character
	if(obj ~= nil and obj:IsCharacter()) then
		playerChar = obj:ToCharacter();

		obj_name = obj.name;
		IsMainPlayer = (obj_name == tostring(ProfileManager.GetNID()));

		-- reset all character slots
		local i;
		for i = 0, 45 do
			playerChar:SetCharacterSlot(i, 0);
		end
		--if(obj:GetScale() ~= main_char_scaling) then
			--obj:SetScale(main_char_scaling);
		--end
		
		obj:SetPhysicsRadius(0.8); 
		obj:SetPhysicsHeight(1.8);
		
		local density;
		if(IsMainPlayer) then
			obj:SetField("SkipPicking", true);
			density = Player.GetNewDensity();
		else
			local world = WorldManager:GetCurrentWorld();
			if(world and world.can_dive) then
				density = Player.DiveDensity;
			end
		end
		
		obj:SetDensity(density or Player.NormalDensity);
	else
		log("error: invalid or nil object in Pet.ApplyEquipInfoString()\n")
		return;
	end
	
	
	local gsidMountPet;
	local positionMountPet;
	local mountPetStage = 1; -- 1 egg, 2 minor, 3 major
	
	local isEquipHat = false;
	local isEquipOverhead = false;

	local elf_vippet_assetfile = nil;
	
	local this_nid = tonumber(obj_name);
	if(this_nid) then
		--if(Scene.IsGMAccount) then
			--local isGM = Scene.IsGMAccount(this_nid);
			--if(isGM) then
				--equip_string = ""; -- clear the GM equipment string
				--local asset = ParaAsset.LoadParaX("", GM_assetfile);
				--local playerChar = obj:ToCharacter();
				--playerChar:ResetBaseModel(asset);
			--end
		--end
	end
	
	local i = 0;
	local ItemManager = ItemManager;
	local gsid, value_str;
	for value_str in string.gfind(equip_string, "([^#]+)") do
		--playerChar:SetCharacterSlot(slot, tonumber(itemID));
		--Inventory.SetCharacterSlot(obj, slot, tonumber(itemID));
		gsid = tonumber(value_str);
		i = i + 1;
		local position = equip_positions[i];
		
		if(forceslots and forceslots[position]) then
			gsid = forceslots[position];
		end
		
		if(position == 34) then
			if(gsid == 0 or gsid == 1) then
				positionMountPet = "mount";
			elseif(gsid == 2) then
				positionMountPet = "follow";
				-- all teen version mount pet is mount instead of follow
				if(System.options.version == "teen") then
					positionMountPet = "mount";
				end
			elseif(gsid == 3) then
				positionMountPet = "flying";
			end
		elseif(position == 31) then
			if(System.options.version == "teen") then
				if(not obj:GetDynamicField("IsInCombat", false)) then
					if(gsid == 10001) then
						-- force default mount to follow in teen version
						-- NOTE: default mount in teen version is a combat post object with player mounted
						positionMountPet = "follow";
					end
				end
			end
			-- mount pet
			if(positionMountPet == "mount" or positionMountPet == "flying") then
				if(gsid ~= 0) then
					isMounted = true;
					gsidMountPet = gsid;
					local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid)
					if(gsItem) then
						-- reset the base model to mount pet asset
						local assetfile = gsItem.assetfile;
						
						if(obj:GetDynamicField("mount_gsid", 0)~=gsidMountPet or assetfile ~=  obj:GetPrimaryAsset():GetKeyName()) then
							local asset = ParaAsset.LoadParaX("", assetfile);
							local playerChar = obj:ToCharacter();
							playerChar:ResetBaseModel(asset);
							mountpet_changed = true;
							obj:SetScale(mount_char_scaling);
							obj:SetDynamicField("mount_gsid", gsidMountPet or 0);
							local pet_setting;
							if(IsMainPlayer) then	
								pet_setting = Pet.QueryPetSetting(gsidMountPet) or Pet.QueryPetSetting(assetfile);
								if(pet_setting and pet_setting.can_fly) then
									obj:SetField("IgnoreSlopeCollision", true);
								else
									obj:SetField("IgnoreSlopeCollision", false);
								end
							end
							pet_setting = pet_setting or Pet.QueryPetSetting(gsidMountPet) or Pet.QueryPetSetting(assetfile);
							if(pet_setting) then
								if(pet_setting.mount_scale) then
									obj:SetScale(pet_setting.mount_scale);
								end
							end
						end
						
						-- get or create the driver character
						local _driver = ParaScene_GetCharacter(obj_name.."+driver");
						if(_driver and _driver:IsValid() == true) then
							-- do nothing
						else
							local obj_params = {};
							obj_params.name = obj_name.."+driver";
							local x, y, z = obj:GetPosition();
							obj_params.x = x;
							obj_params.y = y;
							obj_params.z = z;
							obj_params.AssetFile = ""; -- "character/v3/Elf/Female/ElfFemale.xml";
							obj_params.IsCharacter = true;
							-- skip saving to history for recording or undo.
							System.SendMessage_obj({
								type = System.msg.OBJ_CreateObject, 
								obj_params = obj_params, 
								SkipHistory = true,
								silentmode = true,
							});
							_driver = ParaScene_GetCharacter(obj_name.."+driver");
							_driver:SetScale(main_char_scaling);
							-- obj is mount pet
							local assetname = obj:GetPrimaryAsset():GetKeyName();
							
							obj:SetPhysicsRadius(0.8); 
							obj:SetPhysicsHeight(1.8);	
							_driver:SetDensity(Player.NormalDensity);
							
							--obj:SetField("On_AssetLoaded", ";ItemManager.RefreshMyself();")
							--obj:UpdateTileContainer();
							--obj:SetVisible(show)
							
							-- hide display name of the pet when selected
							_driver:SetDynamicField("name", "");
							
							if(IsMainPlayer) then
								_driver:SetField("RenderImportance", Pet.main_player_render_importance);
								_driver:SetField("SkipPicking", true);
							end
							--[[ TODO: character born effect: shall we only show it when character is visible?
							local params = {
								asset_file = "character/v5/09effect/Fly/FlyStar.x",
								binding_obj_name = obj_name,
								start_position = nil,
								duration_time = 1600,
							};
							EffectManager.CreateEffect(params);]]
						end
					end
				elseif(gsid == 0) then
					-- delete the driver if available
					local _driver = ParaScene_GetCharacter(obj_name.."+driver");
					if(_driver and _driver:IsValid() == true) then
						ParaScene.Delete(_driver);
					end
				end
				-- delete the mount pet follow if available
				local _mountpet_follow = ParaScene_GetCharacter(obj_name.."+mountpet-follow");
				if(_mountpet_follow and _mountpet_follow:IsValid() == true) then
					ParaScene.Delete(_mountpet_follow);
				end
				--local _mountpet_follow_effect = ParaScene_GetCharacter(obj_name.."+mountpet-follow-effect");
				--if(_mountpet_follow_effect and _mountpet_follow_effect:IsValid() == true) then
					--ParaScene.Delete(_mountpet_follow_effect);
				--end
			elseif(positionMountPet == "follow") then
				if(gsid ~= 0) then
					isMounted = false;
					gsidMountPet = gsid;
					local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid)
					if(gsItem) then
						local assetfile = gsItem.assetfile;

						local pet_setting = Pet.QueryPetSetting(gsid) or Pet.QueryPetSetting(assetfile);
						local follow_scale;
						if(pet_setting) then
							follow_scale = pet_setting.follow_scale;
						end

						local _mountpet_follow = ParaScene_GetCharacter(obj_name.."+mountpet-follow");
						if(_mountpet_follow and _mountpet_follow:IsValid() == true) then
							-- modify the asset file
							System.SendMessage_obj({
								type = System.msg.OBJ_ModifyObject, 
								obj_params = _mountpet_follow, 
								SkipHistory = true,
								asset_file = assetfile,
								scale = (follow_scale or 0.5) * follow_char_scaling,
							});
						else
							local obj_params = {};
							obj_params.name = obj_name.."+mountpet-follow";
							local x, y, z = obj:GetPosition();
							obj_params.x = x;
							obj_params.y = y;
							obj_params.z = z;
							obj_params.AssetFile = assetfile;
							obj_params.IsCharacter = true;
							-- skip saving to history for recording or undo.
							System.SendMessage_obj({
								type = System.msg.OBJ_CreateObject, 
								obj_params = obj_params, 
								SkipHistory = true,
								silentmode = true,
							});
							_mountpet_follow = ParaScene_GetCharacter(obj_name.."+mountpet-follow");
							
							-- hide display name of the pet when selected
							_mountpet_follow:SetDynamicField("name", "");
						
							-- NOTE by Andy 2009/6/18: Group special for Aries project
							_mountpet_follow:SetGroupID(SentientGroupIDs["MountPet"]);
							
							--_mountpet_follow:SetPerceptiveRadius(1000);
							-- set the follow pet AI template
							_mountpet_follow:SetScale((follow_scale or 0.5) * follow_char_scaling);
							local playerChar = _mountpet_follow:ToCharacter();
							playerChar:Stop();
							-- playerChar:SetSpeedScale(1.5);
							local att = _mountpet_follow:GetAttributeObject();
							att:SetDynamicField("GlobalStoreName", gsItem.template.name);
							att:SetDynamicField("item_gsid", gsid);
							att:SetField("MovementStyle", 4);
							att:SetField("AlwaysSentient", false);
							att:SetField("PerceptiveRadius", 10);
							att:SetField("Sentient Radius", 10);
							-- att:SetField("Sentient", false);
							att:SetField("OnLoadScript", [[;MyCompany.Aries.Pet.MountPet_FollowAI.On_LeaveSentientArea();]]);
							att:SetField("FrameMoveInterval", 800);
							
							if(IsMainPlayer) then
								_mountpet_follow:SetSentientField(SentientGroupIDs["Player"], true);
								att:SetField("AlwaysSentient", true);
								att:SetField("Sentient", true);
								att:SetField("On_FrameMove", [[;MyCompany.Aries.Pet.MountPet_FollowAI.On_Perception();]]);
								_mountpet_follow:SetField("RenderImportance", Pet.main_player_render_importance);
								_mountpet_follow:SetField("SkipPicking", true);
								--playerChar:AssignAIController("face", "true");
							else
								_mountpet_follow:SetSentientField(SentientGroupIDs["OPC"], true);
								att:SetField("AlwaysSentient", false);
								att:SetField("On_LeaveSentientArea", [[;MyCompany.Aries.Pet.MountPet_FollowAI.On_LeaveSentientArea();]]);
								att:SetField("On_Perception", [[;MyCompany.Aries.Pet.MountPet_FollowAI.On_Perception();]]);
							end

							_mountpet_follow:SetPhysicsRadius(0.8); -- mount pet
							_mountpet_follow:SetPhysicsHeight(1.8);
							_mountpet_follow:SetDensity(Player.NormalDensity);
						end
					end
				elseif(gsid == 0) then
					-- delete the mount pet follow if available
					local _mountpet_follow = ParaScene_GetCharacter(obj_name.."+mountpet-follow");
					if(_mountpet_follow and _mountpet_follow:IsValid() == true) then
						ParaScene.Delete(_mountpet_follow);
					end
					--local _mountpet_follow_effect = ParaScene_GetCharacter(obj_name.."+mountpet-follow-effect");
					--if(_mountpet_follow_effect and _mountpet_follow_effect:IsValid() == true) then
						--ParaScene.Delete(_mountpet_follow_effect);
					--end
				end
				-- delete the driver if available
				local _driver = ParaScene_GetCharacter(obj_name.."+driver");
				if(_driver and _driver:IsValid() == true) then
					ParaScene.Delete(_driver);
				end
			end
		elseif(position == 32) then
			-- follow pet
			local follow_pet_gsid, bInCombat_Mark, quality, follow_pet_displayname;
			if(not gsid) then
				follow_pet_gsid, bInCombat_Mark, quality, follow_pet_displayname = string_match(value_str, "^(%d+)%+([^%+]*)%+(%d+)%+(.*)$");
				if(follow_pet_gsid and bInCombat_Mark and quality and follow_pet_displayname) then
					gsid = tonumber(follow_pet_gsid);
					if(bInCombat_Mark == "true") then
						bInCombat_Mark = true;
					elseif(bInCombat_Mark == "false") then
						bInCombat_Mark = false;
					end
					quality = tonumber(quality);
				end
			end
			if(gsid and gsid ~= 0) then
				local pet_gsid = math.floor(gsid / 1000);
				local pet_asset_id = math.mod(gsid, 1000);
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(pet_gsid);
				if(gsItem) then
					local assetfile;
					if(pet_asset_id) then
						if(System.options.version == "kids")then
							local provider = CombatPetHelper.GetClientProvider();
							assetfile = provider:GetAssetFileFromGSIDandAssetID(pet_gsid, pet_asset_id);
						else
							NPL.load("(gl)script/apps/Aries/CombatPet/CombatPetConfig.lua");
							local CombatPetConfig = commonlib.gettable("MyCompany.Aries.CombatPet.CombatPetConfig");
							local pet_config = CombatPetConfig.GetInstance_Client();
							assetfile = pet_config:GetAssetFileFromGSIDandAssetID(pet_gsid, pet_asset_id);
						end
					end
					assetfile = assetfile or gsItem.assetfile;
					
					local pet_setting = Pet.QueryPetSetting(pet_gsid) or Pet.QueryPetSetting(assetfile);
					local follow_scale;
					if(pet_setting) then
						follow_scale = pet_setting.follow_scale;
					end
					--local follow_speed;
					--if(pet_setting) then
						--follow_speed = pet_setting.follow_speed;
					--end

					local _followpet = ParaScene_GetCharacter(obj_name.."+followpet");
					if(_followpet and _followpet:IsValid() == true) then
						-- modify the asset file
						System.SendMessage_obj({
							type = System.msg.OBJ_ModifyObject, 
							obj_params = _followpet, 
							SkipHistory = true,
							asset_file = assetfile,
							scale = follow_scale or 1,
						});
					else
						local obj_params = {};
						obj_params.name = obj_name.."+followpet";
						local x, y, z = obj:GetPosition();
						obj_params.x = x;
						obj_params.y = y;
						obj_params.z = z;
						obj_params.AssetFile = assetfile;
						obj_params.IsCharacter = true;
						obj_params.scaling = follow_scale;
						-- skip saving to history for recording or undo.
						System.SendMessage_obj({
							type = System.msg.OBJ_CreateObject, 
							obj_params = obj_params, 
							SkipHistory = true,
							silentmode = true,
						});
						_followpet = ParaScene_GetCharacter(obj_name.."+followpet");
						
						-- hide display name of the pet when selected
						_followpet:SetDynamicField("name", "");
						
						-- NOTE by Andy 2009/6/18: Group special for Aries project
						_followpet = ParaScene_GetCharacter(obj_name.."+followpet");
						_followpet:SetGroupID(SentientGroupIDs["FollowPet"]);
						
						--_followpet:SetPerceptiveRadius(1000);
						-- set the follow pet AI template
						local playerChar = _followpet:ToCharacter();
						local att = _followpet:GetAttributeObject();
						playerChar:Stop();
						--playerChar:SetSpeedScale(1.5);
						att:SetField("MovementStyle", 4);
						att:SetField("FrameMoveInterval", 500);
						if(IsMainPlayer) then
							_followpet:SetSentientField(SentientGroupIDs["Player"], true);
							att:SetField("AlwaysSentient", true);
							att:SetField("Sentient", true);
							att:SetField("On_FrameMove", [[;MyCompany.Aries.Pet.FollowPet_FollowAI.On_Perception();]]);
							_followpet:SetField("RenderImportance", Pet.main_player_render_importance);
							_followpet:SetField("SkipPicking", true);
							-- playerChar:AssignAIController("face", "true");
						else
							_followpet:SetSentientField(SentientGroupIDs["OPC"], true);
							att:SetField("AlwaysSentient", false);
							att:SetField("On_LeaveSentientArea", [[;MyCompany.Aries.Pet.FollowPet_FollowAI.On_LeaveSentientArea();]]);
							att:SetField("On_Perception", [[;MyCompany.Aries.Pet.FollowPet_FollowAI.On_Perception();]]);
						end
						att:SetField("PerceptiveRadius", 10);
						att:SetField("Sentient Radius", 10);
						--att:SetField("Sentient", false);
						att:SetField("OnLoadScript", [[;MyCompany.Aries.Pet.FollowPet_FollowAI.On_LeaveSentientArea();]]);
						
						_followpet:SetPhysicsRadius(0.8); -- follow pet
						_followpet:SetPhysicsHeight(1.8);
						_followpet:SetDensity(Player.NormalDensity);
					end
					local att = _followpet:GetAttributeObject();
					att:SetDynamicField("GlobalStoreName", gsItem.template.name);
					att:SetDynamicField("item_gsid", pet_gsid);

					if(System.options.version == "teen") then
						quality = quality or 0;
						
						local displayname = gsItem.template.name;
						if(follow_pet_displayname and follow_pet_displayname ~= "") then
							displayname = follow_pet_displayname;
						end
						local att = _followpet:GetAttributeObject();
						att:SetDynamicField("followpet_displayname", displayname);
						local follow_pet_displaycolor = FollowPet_HeadOnDisplayColor[quality] or FollowPet_HeadOnDisplayColor[0];
						--att:SetDynamicField("FollowPetDisplayname", displayname);
						--att:SetDynamicField("FollowPetDisplaycolor", follow_pet_displaycolor);
						--if(obj:GetDynamicField("IsInCombat", false)) then
						if(bInCombat_Mark == true) then
							System.ShowHeadOnDisplay(false, _followpet, "", follow_pet_displaycolor, {y = 0.5});
						else
							System.ShowHeadOnDisplay(true, _followpet, displayname, follow_pet_displaycolor, {y = 0.5});
						end
					end
				end
			elseif(gsid == 0) then
				-- delete the follow pet if available
				local _followpet = ParaScene_GetCharacter(obj_name.."+followpet");
				if(_followpet and _followpet:IsValid() == true) then
					ParaScene.Delete(_followpet);
				end
			end
		elseif(position == 33) then
			-- NOTE: 33 is a special position that will record the index order of the asset file in the descfile
			local index = gsid;
			mountPetStage = index;
			local assetfile;
			local pet_setting
			if(isMounted == true) then
				assetfile = ItemManager.GetAssetFileFromGSIDAndIndex(gsidMountPet, index);
				if(assetfile and assetfile ~=  obj:GetPrimaryAsset():GetKeyName()) then
					local asset = ParaAsset.LoadParaX("", assetfile);
					local playerChar = obj:ToCharacter();
					playerChar:ResetBaseModel(asset);
				end
			end
			if(positionMountPet == "follow") then
				local _mountpet_follow = ParaScene_GetCharacter(obj_name.."+mountpet-follow");
				if(_mountpet_follow and _mountpet_follow:IsValid() == true) then
					assetfile = assetfile or ItemManager.GetAssetFileFromGSIDAndIndex(gsidMountPet, index);
					if(assetfile and assetfile ~=  _mountpet_follow:GetPrimaryAsset():GetKeyName()) then
						local asset = ParaAsset.LoadParaX("", assetfile);
						local playerChar = _mountpet_follow:ToCharacter();
						playerChar:ResetBaseModel(asset);

						pet_setting = pet_setting or Pet.QueryPetSetting(gsidMountPet) or Pet.QueryPetSetting(assetfile);
						if(pet_setting) then
							if(pet_setting.follow_scale) then
								playerChar:SetScale(pet_setting.follow_scale);
							end
						end
					end
				end
			end
		elseif(position == 40) then
			-- directly apply the base color
			if(is_kids_version) then
				local assetfile;
				if(mountPetStage == 1) then -- egg
					if(gsid == 11009) then
						--assetfile = "character/v3/PurpleDragonEgg/SkinColor01.dds";
						assetfile = "character/v3/PurpleDragonMinor/SkinColor01.dds";
					elseif(gsid == 11010) then
						--assetfile = "character/v3/PurpleDragonEgg/SkinColor02.dds";
						assetfile = "character/v3/PurpleDragonMinor/SkinColor02.dds";
					elseif(gsid == 11011) then
						--assetfile = "character/v3/PurpleDragonEgg/SkinColor03.dds";
						assetfile = "character/v3/PurpleDragonMinor/SkinColor03.dds";
					elseif(gsid == 11012) then
						--assetfile = "character/v3/PurpleDragonEgg/SkinColor04.dds";
						assetfile = "character/v3/PurpleDragonMinor/SkinColor04.dds";
					elseif(gsid == 16049) then
						--assetfile = "character/v3/PurpleDragonEgg/SkinColor05.dds";
						assetfile = "character/v3/PurpleDragonMinor/SkinColor05.dds";
					elseif(gsid == 16050) then
						--assetfile = "character/v3/PurpleDragonEgg/SkinColor06.dds";
						assetfile = "character/v3/PurpleDragonMinor/SkinColor06.dds";
					end
				elseif(mountPetStage == 2) then -- minor
					if(gsid == 11009) then
						assetfile = "character/v3/PurpleDragonMinor/SkinColor01.dds";
					elseif(gsid == 11010) then
						assetfile = "character/v3/PurpleDragonMinor/SkinColor02.dds";
					elseif(gsid == 11011) then
						assetfile = "character/v3/PurpleDragonMinor/SkinColor03.dds";
					elseif(gsid == 11012) then
						assetfile = "character/v3/PurpleDragonMinor/SkinColor04.dds";
					elseif(gsid == 16049) then
						assetfile = "character/v3/PurpleDragonMinor/SkinColor05.dds";
					elseif(gsid == 16050) then
						assetfile = "character/v3/PurpleDragonMinor/SkinColor06.dds";
					end
				elseif(mountPetStage == 3) then -- major
					if(isMounted == true) then
						if(obj and obj:IsValid() == true) then
							if(gsid == 11009) then
								obj:ToCharacter():SetBodyParams(1, -1, -1, -1, -1);
							elseif(gsid == 11010) then
								obj:ToCharacter():SetBodyParams(2, -1, -1, -1, -1);
							elseif(gsid == 11011) then
								obj:ToCharacter():SetBodyParams(3, -1, -1, -1, -1);
							elseif(gsid == 11012) then
								obj:ToCharacter():SetBodyParams(4, -1, -1, -1, -1);
							elseif(gsid == 16049) then
								obj:ToCharacter():SetBodyParams(5, -1, -1, -1, -1);
							elseif(gsid == 16050) then
								obj:ToCharacter():SetBodyParams(6, -1, -1, -1, -1);
							end
						end
					end
				
					if(positionMountPet == "follow") then
						local _mountpet_follow = ParaScene_GetCharacter(obj_name.."+mountpet-follow");
						if(_mountpet_follow and _mountpet_follow:IsValid() == true) then
							if(gsid == 11009) then
								_mountpet_follow:ToCharacter():SetBodyParams(1, -1, -1, -1, -1);
							elseif(gsid == 11010) then
								_mountpet_follow:ToCharacter():SetBodyParams(2, -1, -1, -1, -1);
							elseif(gsid == 11011) then
								_mountpet_follow:ToCharacter():SetBodyParams(3, -1, -1, -1, -1);
							elseif(gsid == 11012) then
								_mountpet_follow:ToCharacter():SetBodyParams(4, -1, -1, -1, -1);
							elseif(gsid == 16049) then
								_mountpet_follow:ToCharacter():SetBodyParams(5, -1, -1, -1, -1);
							elseif(gsid == 16050) then
								_mountpet_follow:ToCharacter():SetBodyParams(6, -1, -1, -1, -1);
							end
						end
					end
				end
				if(isMounted == true and assetfile) then
					if(obj and obj:IsValid() == true) then
						obj:SetReplaceableTexture(1, ParaAsset.LoadTexture("", assetfile, 1));
					end
				end
				if(positionMountPet == "follow" and assetfile) then
					local _mountpet_follow = ParaScene_GetCharacter(obj_name.."+mountpet-follow");
					if(_mountpet_follow and _mountpet_follow:IsValid() == true) then
						_mountpet_follow:SetReplaceableTexture(1, ParaAsset.LoadTexture("", assetfile, 1));
					end
				end
			end
		elseif(position and (position < 30 or position == 41 or position == 42 or position == 43)) then
			-- this is the character clothes and hand-held
			if(isMounted == true) then
				_elf = ParaScene_GetCharacter(obj_name.."+driver");
			elseif(isMounted == false) then
				_elf = obj;
			end
			if(position == 41) then
				local assetfile = "character/v3/Elf/Female/ElfFemale.xml";
				if(not is_kids_version) then
					assetfile = Player.GetAvaterAssetFileByID(gsid) or "character/v3/TeenElf/Female/TeenElfFemale.xml";
				end
				if(assetfile ~= _elf:GetPrimaryAsset():GetKeyName()) then
					local asset = ParaAsset.LoadParaX("", assetfile);
					local playerChar = _elf:ToCharacter();
					playerChar:ResetBaseModel(asset);
				end
				if(_elf:GetScale() ~= main_char_scaling) then
					_elf:SetScale(main_char_scaling);
				end
				if(isMounted == true) then
					-- mount the driver. this is tricky by LiXizhi:  only mount the driver when its main asset file is known. 
					--Player.MountPlayerOnChar(_elf, obj, true);
					Player.MountPlayerOnChar(_elf, obj, mountpet_changed);
				end
			end
			if(_elf and _elf:IsValid() == true) then
				-- select the SetCharacterSlot target and choose the right character slot or facial or cartoonface components
				local _elfChar = _elf:ToCharacter();
				local slot;
				if(position == 1) then
					slot = 14; -- overhead
				elseif(position == 2) then
					slot = 0; -- hat
				elseif(position == 3) then
					-- TODO: cartoon face related
				elseif(position == 4) then
					slot = 20; -- glass
				elseif(position == 5) then
					slot = 16; -- shirt
					-- CS_ARIES_CHAR_SHIRT_TEEN character slot implemented with separated region path for teen shirt items
					if(System.options.version == "teen") then
						slot = 28;
					end
				elseif(position == 6) then
					slot = 17; -- pants
				elseif(position == 7) then
					slot = 19; -- boots
				elseif(position == 8) then
					slot = 21; -- wings
				elseif(position == 9) then
					slot = 18; -- gloves
				elseif(position == 10) then
					slot = 11; -- left hand
				elseif(position == 11) then
					slot = 10; -- right hand
				elseif(position == 12) then
					-- TODO: hair style
				elseif(position == 42) then
					slot = 29; -- gem effect
				elseif(position == 43) then
					slot = 30; -- ring effect
				end
				--mount the item
				if(slot) then
					if(slot == 0 and gsid > 0) then
						isEquipHat = true;
					elseif(slot == 14 and gsid > 0) then
						isEquipOverhead = true;
					end
					if(position == 8) then --back
						local original_gsid = gsid;
						if(System.options.version == "teen") then
							-- remove teen version display id offset
							if(gsid > 30000 and gsid < 39999) then
								original_gsid = gsid - 30000;
							elseif(gsid > 40000 and gsid < 49999) then
								original_gsid = gsid - 40000;
							end
						end
						local gsItem = ItemManager.GetGlobalStoreItemInMemory(original_gsid);
						if(gsItem) then
							-- reset the base model to mount pet asset
							local bForceAttBack = gsItem.template.stats[13];
							if(bForceAttBack == 1) then
								slot = 26; -- CS_BACK 
								_elfChar:SetCharacterSlot(21, 0);
							else
								slot = 21; -- CS_ARIES_CHAR_GLASS 
								_elfChar:SetCharacterSlot(26, 0);
							end
						end
					end
					if(position == 5) then -- shirt
						local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
						if(gsItem) then
							-- 181 ground_effect_id
							local ground_effect_id = gsItem.template.stats[181];
							if(ground_effect_id and ground_effect_id > 1000) then
								_elfChar:SetCharacterSlot(27, ground_effect_id);
							else
								_elfChar:SetCharacterSlot(27, 0);
							end
						end
					end
					if(position == 4) then -- glass
						-- NOTE: we use mask as a basic cartoon face component in teen version
						if(System.options.version == "kids") then
							local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
							if(gsItem) then
								-- reset the base model to mount pet asset
								local bForceCartoonFace = gsItem.template.stats[16];
								if(bForceCartoonFace == 1) then
									slot = nil; -- CF_MASK
									_elfChar:SetCartoonFaceComponent(6, 0, gsid);
									_elfChar:SetCharacterSlot(20, 0);
								else
									slot = 20; -- CS_ARIES_CHAR_WING 
									_elfChar:SetCartoonFaceComponent(6, 0, 0);
								end
							end
							if(gsid == 0) then
								-- reset the glass and the mask
								_elfChar:SetCartoonFaceComponent(6, 0, 0);
								_elfChar:SetCharacterSlot(20, 0);
							end
						end
					end
					if(slot) then
						_elfChar:SetCharacterSlot(slot, gsid);
					end
				end
			else
				_elf = nil;
			end
		elseif(position and position >= 44 and position<=50) then
			-- this is the mount pet appearance
			if(is_kids_version) then
				local mountpetobj;
				local playerobj;
				if(positionMountPet == "mount") then
					if(isMounted == true) then
						mountpetobj = obj;
						playerobj = ParaScene_GetCharacter(obj_name.."+driver");
					else
						playerobj = obj;
					end
				elseif(positionMountPet == "follow") then
					mountpetobj = ParaScene_GetCharacter(obj_name.."+mountpet-follow");
				end
				if(mountpetobj and mountpetobj:IsValid() == true) then
					-- choose the right character slot
					local _objChar = mountpetobj:ToCharacter();
					local slot;
					if(position == 41) then
						slot = 22; -- head
					elseif(position == 42) then
						slot = 23; -- body
					elseif(position == 43) then
						slot = 24; -- tail
					elseif(position == 44) then
						slot = 25; -- wing
					end
					----mount the item
					--if(slot) then
						--_objChar:SetCharacterSlot(slot, gsid);
					--end
				end
				if(playerobj and playerobj:IsValid() == true) then
					-- reset non-dragon items for player
					local _objChar = playerobj:ToCharacter();
					local slot;
					if(position == 41) then
						slot = 22; -- head
					elseif(position == 42) then
						slot = 23; -- body
					elseif(position == 43) then
						slot = 24; -- tail
					elseif(position == 44) then
						slot = 25; -- wing
					end
					-- reset non-dragon items for player
					if(slot) then
						_objChar:SetCharacterSlot(slot, 0);
					end
				end
			end
		elseif(position == 35) then
			-- this is the character effect on foot
			local index = gsid;
			if(isMounted == true) then
				_elf = ParaScene_GetCharacter(obj_name.."+driver");
			elseif(isMounted == false) then
				_elf = obj;
			end
			if(_elf and _elf:IsValid() == true) then
				-- select the SetCharacterSlot target and choose the right character slot or facial or cartoonface components
				local _elfChar = _elf:ToCharacter();
				if(index == 1) then
					-- use the freezed elf female
					local assetfile = "character/v5/01human/ElfFemaleFreezed/ElfFemaleFreezed.x";
					if(assetfile ~=  _elf:GetPrimaryAsset():GetKeyName()) then
						local asset = ParaAsset.LoadParaX("", assetfile);
						local playerChar = _elfChar;
						playerChar:ResetBaseModel(asset);
						if(_elf:GetScale() ~= main_char_scaling) then
							_elf:SetScale(main_char_scaling);
						end
					end
				elseif(index == 0) then
					-- do nothing for unfreezed user character
				end
			end
		elseif(position == 30) then
			if(gsid ~= 0) then
				local assetfile = nil;
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
				if(gsItem) then
					elf_vippet_assetfile = gsItem.assetfile;
				else
					if(System.options.version == "teen") then
						elf_vippet_assetfile = "character/v6/03pet/MagicStar/MagicStar.x"; -- default asset file
					else
						elf_vippet_assetfile = "character/v5/11vip/MagicStar/MagicStar.x"; -- default asset file
					end
				end
			else
				elf_vippet_assetfile = nil;
			end
		elseif(position == 51) then
			-- base character model: added by LiXizhi 2011.4.7
			if(not gsid) then
				-- for special assets: disabled
				--if(_elf and value_str ~= _elf:GetPrimaryAsset():GetKeyName()) then
					--_elf:ToCharacter():ResetBaseModel(ParaAsset.LoadParaX("", value_str));
				--end
			elseif(gsid > 10) then
				local gsItem = ItemManager.GetGlobalStoreItemInMemory(gsid);
				-- only allow transform marker type to take effect. 
				if(gsItem and gsItem.template and gsItem.template.inventorytype == 33) then
					local elf_transform_file = gsItem.assetfile;
					if(_elf and elf_transform_file ~= _elf:GetPrimaryAsset():GetKeyName()) then
						_elf:ToCharacter():ResetBaseModel(ParaAsset.LoadParaX("", elf_transform_file));
						local TransformAvatarScale = gsItem.template.stats[64];
						if(TransformAvatarScale) then
							if(TransformAvatarScale>20) then
								TransformAvatarScale = TransformAvatarScale/100;
							end
							_elf:SetScale(TransformAvatarScale);
						end
						if(isMounted == true) then
							-- update the driver mount animation if any 
							Player.MountPlayerOnChar(_elf, obj, true);
						end
					end
				end
			end
			-- for gsid 0,1: there is no need to set Elf back, since that would be done in previous position(<30). 
		elseif(position == 52) then
			-- multiplayer mount
			-- echo({"111111111111", obj_nid = obj.name, value=value_str, this_nid = System.User.nid})
			if(value_str~= "0") then
				if(not isMounted) then
					if(System.options.version == "kids") then
						obj:AddEvent(format("mont %s %d character/Animation/v5/DefaultMount.x", value_str, 1), 0, true);
					else
						obj:AddEvent(format("mont %s %d character/Animation/v5/DefaultMount_teen.x", value_str, 1), 0, true);
					end
				end
			elseif(playerChar and playerChar:IsMounted()) then
				-- do not mount on any remote player
				obj:AddEvent("umnt", 0, true);
			end
		end
	end
	
	-- NOTE: special scaling for Aries project to scale the avatar to main_char_scaling, including avatars, dragons, follow pets, NPCs, GameObjects
	local _player = obj;
	
	local this_nid = tonumber(_player.name);

	--local HeadOnDisplayColor = Player.HeadOnDisplayColor;
	--if(Scene) then
		--local isGM = Scene.IsGMAccount(this_nid);
		--if(isGM) then
			--HeadOnDisplayColor = Player.HeadOnDisplayColor_TownChiefRodd;
		--end
	--end
	--
	--if(isEquipHat == true) then
		--local headon_text = Player.GetHeadonTextString(_player);
		--System.ShowHeadOnDisplay(true, _player, headon_text, HeadOnDisplayColor, {y = 0.7});
	--else
		--local headon_text = Player.GetHeadonTextString(_player);
		--System.ShowHeadOnDisplay(true, _player, headon_text, HeadOnDisplayColor, {y = 0.2});
	--end

	Player.ShowHeadonTextForNID(this_nid, _player);
	
	if(IsMainPlayer) then
		if(System.options.version == "teen") then
			Pet.UpdateAvatarSpeed();
		end
	end
		
	-- flying aura
	if(obj and System.options.version == "kids") then
		if(positionMountPet == "flying") then
			local asset = ParaAsset.LoadParaX("", "character/v5/09effect/Fly/fly.x");
			obj:ToCharacter():AddAttachment(asset, 4, 1);
		else
			obj:ToCharacter():RemoveAttachment(4, 1);
		end
	end

	-- hide the headon speech, in case of user unmount from pet and with the former headon speech
	--headon_speech.Speek(obj_name, "", 0);
	
	-- return the elf character
	if(not _elf) then
		if(isMounted == true) then
			_elf = ParaScene_GetCharacter(obj_name.."+driver");
		elseif(isMounted == false) then
			_elf = obj;
		end
	end

	-- tricky: we will skip terrain normal when player is not mounted. 
	if(IsMainPlayer) then
		if(isMounted == true) then
			obj:SetField("SkipTerrainNormal", false);
		else
			obj:SetField("SkipTerrainNormal", true);
			obj:SetField("IgnoreSlopeCollision", false);
		end
	end

	-- vip pet asset mount
	if(_elf and _elf:IsValid() == true) then
		if(elf_vippet_assetfile) then
			local asset = ParaAsset.LoadParaX("", elf_vippet_assetfile);
			_elf:ToCharacter():AddAttachment(asset, 4, 1);
		else
			_elf:ToCharacter():RemoveAttachment(4, 1);
		end

	end
	-- return the elf character
	return _elf;
end

-- update avatar speed
-- NOTE: only valid for teen version
function Pet.UpdateAvatarSpeed(isNavSpeed)
	if(System.options.version == "teen") then
		local is_bag_too_heavy = Combat.IsOverWeight();
		local VIP = commonlib.gettable("MyCompany.Aries.VIP");
		local level = VIP.GetMagicStarLevel();
		local speed_scale = 1.2;
		if(isNavSpeed) then
			-- is player is in navigation mode, we will use vip 10 speed
			speed_scale = (speed_scale_magicstarlevel_mapping[10]) + 0.2;
		else
			if(level and level > 0) then
				speed_scale = (speed_scale_magicstarlevel_mapping[level] or 1) + 0.2;
			end
		end
		if(is_bag_too_heavy) then
			speed_scale = speed_scale - 0.4;
		end
		local player = Pet.GetRealPlayer();
		if(player) then
			player:SetField("Speed Scale", speed_scale);
		end
	end
end

-- 2009.12.16. rewrite the GetFacialInfoString implementation to support skin color mask. 
-- get the facial information string from the obj_param
-- @param obj_param: object parameter(table) or ParaObject object
-- @return: the facial info string if CCS character
--		or nil if no facial information is found
function CCS.Predefined.GetFacialInfoString(obj_params)
	
	local obj;
	local playerChar;
	
	if(type(obj_params) == "userdata") then
		obj = obj_params;
	elseif(type(obj_params) == "table") then
		obj = ObjEditor.GetObjectByParams(obj_params);
	else
		LOG.std("", "error", "pet", "error: obj_params not table or userdata value.");
		return;
	end
	
	-- get player character
	if(obj ~= nil and obj:IsCharacter()) then
		playerChar = obj:ToCharacter();
	end
	
	if(playerChar and playerChar:IsCustomModel()) then
		-- set the faical parameter according to ccs table(facial info part)
		return format("%d#%d#%d#%d#%s#", playerChar:GetBodyParams(0), playerChar:GetBodyParams(1), playerChar:GetBodyParams(2), playerChar:GetBodyParams(3), playerChar:GetSkinColorMask());
	else
		--log("error: attempt to get a non character ccs information or non custom character.\n");
		return nil;
	end
end

-- 2009.12.16. rewrite the ApplyFacialInfoString implementation to support skin color mask. 
-- apply the facial information string to the obj_param object
-- @param obj_param: object parameter(table) or ParaObject object
-- @param sInfo: ccs information string
-- NOTE: Facial information string is the first section of the full CCS information string
function CCS.Predefined.ApplyFacialInfoString(obj_params, sInfo)
	local obj;
	local playerChar;
	
	if(type(obj_params) == "userdata") then
		obj = obj_params;
	elseif(type(obj_params) == "table") then
		obj = ObjEditor.GetObjectByParams(obj_params);
	else
		LOG.std("", "error", "pet", "error: obj_params not table or userdata value.");
		return;
	end
	
	-- get player character
	if(obj and obj:IsCharacter()) then
		playerChar = obj:ToCharacter();
	end
	
	if(playerChar ~= nil and playerChar:IsCustomModel()) then
		-- set the faical parameter according to ccs table(facial info part)
		local skinColor, faceType, hairColor, hairStyle, facialHair = string_match(sInfo, "([^#]+)#([^#]+)#([^#]+)#([^#]+)#([^#]*)#?");
		if(hairStyle) then
			skinColor = tonumber(skinColor) or 0
			faceType = tonumber(faceType) or 0;
			hairColor = tonumber(hairColor) or 0;
			hairStyle = tonumber(hairStyle) or 0;

			-- we will use facialHair to store skin color mask. 
			playerChar:SetBodyParams(skinColor, faceType, hairColor, hairStyle, 1);
			if(facialHair ~= "") then
				playerChar:SetSkinColorMask(facialHair);
			else
				playerChar:SetSkinColorMask("F");
			end
		end
	else
		--log("error: attempt to set a non character ccs information or non custom character.\n");
	end
end

function CCS.CanCreatePlayer(nid, x, y, z)
	--if(System.options.version == "kids") then
		--local world = WorldManager:GetCurrentWorld();
		--if(world and (world.name == "HaqiTown_RedMushroomArena_1v1" or world.name == "HaqiTown_RedMushroomArena_2v2")) then
			--if(MsgHandler.IsInCombat()) then
				--return true;
			--end
			--return false;
		--end
	--end
	return true;
end

function CCS.TranslatePlayerPosition(x, y, z)
	--if(x and y and z) then
		--
		--if(System.options.version == "kids") then
			--local world = WorldManager:GetCurrentWorld();
			--if(world and (world.name == "HaqiTown_RedMushroomArena_1v1" or world.name == "HaqiTown_RedMushroomArena_2v2")) then
				--local freeze_pos1 = {20000.083984375, 63.791568756104, 20015.98046875};
				--local freeze_pos2 = {20000.08203125, 63.868598937988, 19988.294921875};
				--local abs1 = math.abs(freeze_pos1[1] - x) + math.abs(freeze_pos1[2] - y) + math.abs(freeze_pos1[3] - z);
				--local abs2 = math.abs(freeze_pos2[1] - x) + math.abs(freeze_pos2[2] - y) + math.abs(freeze_pos2[3] - z);
				--if(abs1 < 0.1 or abs2 < 0.1) then
					--return x, (y - 50), z;
				--end
				--
				--local myarena = MsgHandler.GetMyArenaData();
				--if(myarena) then
					--local _, each_player;
					--for _, each_player in pairs(myarena.players) do
					--end
					--
				--end
				--if(MsgHandler.IsInCombat()) then
					--return x, (y - 50), z;
				--end
			--end
		--end
	--end
	return x, y, z;
end

function CCS.GetCCSInfoString_for_GSL_agent()
	if(System.options.version == "kids") then
		local world = WorldManager:GetCurrentWorld();
		if(world and world.name and (world.name == "HaqiTown_RedMushroomArena_1v1" or world.name == "HaqiTown_RedMushroomArena_2v2" or string.match(world.name,"HaqiTown_RedMushroomArena_1v1"))) then
			return CCS.GetCCSInfoString(nil, nil, {
				[2] = 0; -- hat
				--[18] = 0; -- fashion hat
				[5] = 1050; -- shirt
				--[19] = 0; -- fashion shirt
				[6] = 1051; -- pant
				[8] = 0; -- back
				--[70] = 0; -- fashion back
				[7] = 1052; -- boots
				--[71] = 0; -- fashion boots
				[11] = 0; -- right hand
				--[72] = 0; -- fashion right hand
				[10] = 0; -- left hand
				[9] = 0; -- Gloves
				[31] = 10001; -- mount dragon
			});
		else
			return CCS.GetCCSInfoString();
		end
	else
		return CCS.GetCCSInfoString();
	end
end

-- rewrite the CCSInfoString related function
-- Follow and Mount pet information is also included in the CCSInfoString
-- CCSInfoString	the player character contains 3 sections: facial cartoonface and characterslot
--					mount and follow pet contains 1 sections: mount pet, follow pet and mount pet apparels

-- get the CCS information string from the obj_param
-- @param obj_param: object parameter(table) or ParaObject object
-- @param forceslots: force slots, e.x.
-- local CCS = commonlib.gettable("Map3DSystem.UI.CCS")
-- 		cssinfo = CCS.GetCCSInfoString(nil, true, {
-- 			[2] = head_gsid, 
-- 			[5] = body_gsid, 
-- 			[7] = shoe_gsid, 
-- 			[8] = backside_gsid, 
-- 		});
-- @return: the ccs info string if CCS character
--		or nil if no CCS information is found
function CCS.GetCCSInfoString(obj_params, bSkipPet, forceslots, gender)
	local equip_string = Pet.GetMyEquipInfoString(bSkipPet, forceslots, gender);
	local base_avatar_string = "0#1#0#1#1#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#@";
	local dragonFetched = true;
	local ItemManager = ItemManager;
	-- 999_ccsinfo_user
	if(gender) then
		if(gender == "female") then
		else
			base_avatar_string = "0#1#0#1#1#@200#F#0#0#0#0#0#F#0#0#0#0#-1#F#0#0#0#0#-1#F#0#0#0#0#-1#F#0#0#0#0#-1#F#0#0#0#0#200#F#0#0#0#0#@"
		end
	end
	local bOwn, guid = ItemManager.IfOwnGSItem(999);
	if(bOwn == true and guid > 0) then
		local item = ItemManager.GetItemByGUID(guid);
		if(item and item.guid > 0) then
			if(item.clientdata and item.clientdata ~= "") then
				base_avatar_string = item.clientdata;
			end
		end
	else
		return if_else(System.options.version=="kids","0#1#0#1#1#@0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#0#F#0#0#0#0#8#F#0#0#0#0#0#F#0#0#0#0#@0#0#0#0#0#0#0#0#0#0#0#0#0#1050#1051#1052#0#0#0#1810#0#0#0#0#0#0#", "0#1#0#3#1#@100#F#0#0#0#0#0#F#0#0#0#0#-1#F#0#0#0#0#-1#F#0#0#0#0#-1#F#0#0#0#0#-1#F#0#0#0#0#100#F#0#0#0#0#@0#0#0#0#0#982#0#0#0#0#0#0#0#41001#0#41002#0#0#0#31266#0#0#0#0#0#0#");
	end
	
	local player = Player.GetPlayer();
	if(player ~= nil and player:IsValid() == true) then
		local _, y, __ = player:GetPosition();
		if((y > 9004 and y < 11000) or y > 21000) then
			-- NOTE: there will be no mount pet or follow pet object valid for indoor users
			-- unattach the mount pet to the character
			if(string_find(equip_string, "^(.+)#(%d+)#") == 1) then
				equip_string = string.gsub(equip_string, "#(%d+)#", "#0#", 1);
			end
			-- unattach the follow pet to the character
			if(string_find(equip_string, "^(.+)#0#(%d+)#") == 1) then
				equip_string = string.gsub(equip_string, "#0#(%d+)#", "#0#0#", 1);
			end
		end
	end
	
	return base_avatar_string..equip_string;
end

-- enter indoor mode, not allowing any follow pet or mounted
function Pet.EnterIndoorMode(nid)
	indoor_mode_nids[nid] = true;
	Pet.RefreshOPC_CCS(nid);
end

-- leave indoor mode, not allowing any follow pet or mounted
function Pet.LeaveIndoorMode(nid)
	indoor_mode_nids[nid] = false;
	Pet.RefreshOPC_CCS(nid);
end

-- record latest OPC ccs string information
Pet.CCSInfos_OPC = {};

-- refresh the OPC character ccs info
-- @param nid:
-- @param forceslots: force set of the character slots, e.x. {[35]=1}
-- @param ccsinfo_if_nil: if no previous ccs info string is available use this one. if nil, a default one will also be used. 
-- @param isforcemount: force avatar to mount on the dragon
function Pet.RefreshOPC_CCS(nid, forceslots, ccsinfo_if_nil, isforcemount)
	if(not nid or nid == ProfileManager.GetNID()) then
		-- myself
		local equip_string = CCS.GetCCSInfoString();
		local player = Pet.GetRealPlayer();
		CCS.ApplyCCSInfoString(player, equip_string, nil, isforcemount);
	elseif((tonumber(nid) or 0)>0) then
		-- other player
		local sInfo = Pet.CCSInfos_OPC[tostring(nid)] or ccsinfo_if_nil;
		if(not sInfo) then
			-- use the default css
			sInfo = if_else(System.options.version=="kids",
				 "0#1#0#2#1#@0#F#0#0#0#0#0#F#0#0#0#0#9#F#0#0#0#0#9#F#0#0#0#0#10#F#0#0#0#0#8#F#0#0#0#0#0#F#0#0#0#0#@1#10001#0#3#11009#0#0#0#0#0#0#0#0#1072#1073#1074#0#0#0#0#0#0#0#0#",
				 "0#1#0#3#1#@100#F#0#0#0#0#0#F#0#0#0#0#-1#F#0#0#0#0#-1#F#0#0#0#0#-1#F#0#0#0#0#-1#F#0#0#0#0#100#F#0#0#0#0#@0#0#0#0#0#982#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#");
			if(System.options.version == "teen") then
				if(not forceslots) then
					forceslots = {};
				end
				forceslots[5] = 41001;
				forceslots[7] = 41002;
			end
		end
		local player = ParaScene.GetObject(tostring(nid));
		if(sInfo and player and player:IsValid() == true) then
			CCS.ApplyCCSInfoString(player, sInfo, forceslots, isforcemount);
		end
	end
end

local function UnattachPets(equip_string)
	-- unattach the mount pet to the character
	if(string_find(equip_string, "^(.+)#(%d+)#") == 1) then
		equip_string = string.gsub(equip_string, "#(%d+)#", "#0#", 1);
	end
	-- unattach the follow pet to the character
	if(string_find(equip_string, "^(.+)#0#(%d+)#") == 1) then
		equip_string = string.gsub(equip_string, "#0#(%d+)#", "#0#0#", 1);
	end
	return equip_string;
end

local function ForceMountPet(equip_string)
	-- mount pet
	if(string_match(equip_string, "^(%d+)#") ~= "1") then
		equip_string = string.gsub(equip_string, "(%d+)#", "1#", 1);
	end
	-- attach mount pet gsid
	if(string_match(equip_string, "^[^#]-#(%d+)#") == "0") then
		-- fix bug: mount pet transform is substituted with the default mount pet dragon
		equip_string = string.gsub(equip_string, "#(%d+)#", "#10001#", 1);
	end
	return equip_string;
end

-- apply the ccs information string to the obj_params object
-- @param obj_param: object parameter(table) or ParaObject object
-- @param sInfo: ccs information string
-- @params forceslots: force set of the character slots, e.x. {[35]=1}
-- @param isforcemount: force avatar to mount on the dragon
-- NOTE: obj can be ParaScene object or mini scene graph object
function CCS.ApplyCCSInfoString(obj_params, sInfo, forceslots, isforcemount)
	
	if(type(obj_params) == "userdata") then
		Pet.CCSInfos_OPC[obj_params.name] = sInfo;
	end
	
	local facial_info_string, cartoonface_info_string, equip_string =  string_match(sInfo or "", "([^@]+)@([^@]+)@([^@]+)");
	
	if(equip_string) then
		----assert non-mounted level 1 mount dragon
		--if(string_find(equip_string, "1#10001#(%d+)#1") == 1) then
			--LOG.std("", "warn", "Pet", "assertion non-mounted level 1 mount dragon fail in ApplyCCSInfoString, change the equip_string from:")
			--LOG.std("", "warn", "pet", equip_string)
			--equip_string = "2"..string.sub(equip_string, 2, -1);
			--LOG.std("", "warn", "pet", equip_string)
		--end

		local function GetObjFromObjParams(obj_params)
			local obj;
			if(type(obj_params) == "table") then
				obj = ObjEditor.GetObjectByParams(obj_params);
			elseif(type(obj_params) == "userdata") then
				obj = obj_params;
			end
			return obj;
		end

		local obj = GetObjFromObjParams(obj_params);
		-- get player character
		if(obj ~= nil and obj:IsValid() == true) then
			-- true for force mount dragon dynamic field
			local att = obj:GetAttributeObject();
			if(att:GetDynamicField("ForceMountDragon", false)) then
				isforcemount = true;
			end
			
			local _, y, __ = obj:GetPosition();
			if((y > 9004 and y < 11000) or y > 21000 or indoor_mode_nids[tonumber(obj_params.name)]) then
				-- NOTE: there will be no mount pet or follow pet object valid for indoor users
				equip_string = UnattachPets(equip_string);
			end
			
			-- while in homeland editing
			if(HomeProfilePage.curState == "master_edit") then
				-- NOTE: there will be no mount pet or follow pet object valid for homeland editing
				equip_string = UnattachPets(equip_string);
			else
				-- force mount pet
				if(isforcemount) then
					equip_string = ForceMountPet(equip_string);
				end
			end
			
			local applied_full_ccs = format("%s%s%s", equip_string, facial_info_string, cartoonface_info_string);
			local obj_name = obj.name;
			if(last_applied_full_ccs_mapping[obj_name] ~= applied_full_ccs or not obj:equals(ParaScene.GetObject(obj_name))) then -- is not minit scene object
				LOG.std("", "debug","CCS", "apply equip_string(%s) to character(%s)", equip_string, obj.name);
				last_applied_full_ccs_mapping[obj_name] = applied_full_ccs;
				npl_profiler.perf_begin("apply_equip_string")
				local obj_params = Pet.ApplyEquipInfoString(obj_params, equip_string, forceslots);
				CCS.Predefined.ApplyFacialInfoString(obj_params, facial_info_string);
				if(System.options.version == "teen") then
					CCS.DB.ApplyCartoonfaceInfoString(obj_params, cartoonface_info_string); -- don't skip mask in teen version
				else
					CCS.DB.ApplyCartoonfaceInfoString(obj_params, cartoonface_info_string, true); -- true for skip mask, the mask is set through equip string
				end
				-- NOTE 2010/8/30: for all characters with hat, hide the hair, hair is included in the hat model
				if(obj_params:ToCharacter():GetCharacterSlotItemID(0) > 1) then -- IT_Head
					obj_params:ToCharacter():SetBodyParams(-1, -1, 0, 0, -1); -- int hairColor, int hairStyle
				end
				npl_profiler.perf_end("apply_equip_string")
			end
		end
	else
		LOG.std("", "error", "Pet", "didn't found any CCS information");
	end
end

function Pet.LastAppliedCCSInfoDeprecated(nid)
	last_applied_full_ccs_mapping[tostring(nid)] = nil;
end

-- return if the dragon fetched from sophie
function Pet.IsMyDragonFetchedFromSophie()
	local item = ItemManager.GetMyMountPetItem();
	if(item and item.guid > 0) then
		return true;
	end
	return false;
end

function Pet.IsAdopted()
	local bean = MyCompany.Aries.Pet.GetBean();
	if(bean) then
		if(bean.isadopted == true) then
			return true;
		end
	end
	return false;
end

-- return if other play dragon fetched from sophie
function Pet.IsOPCDragonFetchedFromSophie(nid)
	local ItemManager = ItemManager;
	local item = ItemManager.GetOPCMountPetItem(nid);
	if(item and item.guid > 0) then
		return true;
	end
	return false;
end

------------------------------------------------------
--对坐骑的操作：
------------------------------------------------------

function Pet.On_MountPetClick(type)
	--NPL.load("(gl)script/apps/Aries/Inventory/TabMountOthers.lua");
	--local nid;
	--local pet_id;
	--if(type == "master")then
		--if(Pet.my_dragon_pet_instance)then
			--nid = Pet.my_dragon_pet_instance:GetNID();
			--pet_id = Pet.my_dragon_pet_instance:GetPetID();
		--end
		--System.App.Commands.Call("Profile.Aries.ShowMountPetProfile");
	--elseif(type == "guest")then
		--if(Pet.opc_dragon_pet_instance)then
			--nid = Pet.opc_dragon_pet_instance:GetNID();
			--pet_id = Pet.opc_dragon_pet_instance:GetPetID();
		--end
		----MyCompany.Aries.Inventory.TabMountOthersPage.ShowPage(nid);
	--end
	----_guihelper.MessageBox({nid,pet_id,type});
end
function Pet.On_Perception()
	Pet.DoPerception(Pet.my_dragon_pet_instance);
	Pet.DoPerception(Pet.opc_dragon_pet_instance);
end
function Pet.DoPerception(dragon_pet)
	if(not dragon_pet)then return end
	local radius = Map3DSystem.App.HomeLand.PetState.const_minAIRadius;
	local pet_obj = dragon_pet:GetPetEntity();
	if(pet_obj)then
		local player = Pet.GetUserCharacterObj();
		if(player and player:IsValid())then
			local dis = pet_obj:DistanceTo(player)
			if(dis > radius)then
				dragon_pet.isInAISquare = false;
			else
				if(not dragon_pet.isInAISquare)then
					dragon_pet.isInAISquare = true;
					dragon_pet:SpeakInSquare()
				end
			end
		else
			LOG.std("", "error", "Pet", "坐骑在家园中智能感应失效！");
		end
	end
end
---------------------------
--在离开别人的家园后
function Pet.StopDragonPetOthers()
	if(Pet.dragon_pet_others)then
		Pet.dragon_pet_others:StopMonitor();
	end
end
--nid 是用户nid
function Pet.GetPetValueByNID(nid)
	if(not nid or nid == Map3DSystem.User.nid)then
		return MyCompany.Aries.Pet.my_dragon_pet_instance;
	else
		--其他人的家园中访问坐骑
		return MyCompany.Aries.Pet.opc_dragon_pet_instance;
	end
end

function Pet.Update(nid)
	local p = Pet.GetPetValueByNID(nid);
	if(not p)then return end
	return p:Update();
end
--立即加载坐骑的成长数据
function Pet.GetRemoteValue(nid, callbackFunc, cache_policy)
	local p = Pet.GetPetValueByNID(nid);
	if(not p)then return end
	return p:GetRemoteValue(callbackFunc, cache_policy)
end
--初始化自己的坐骑 只被执行一次
function Pet.InitMyDragonPet(callbackFunc)
	MyCompany.Aries.Pet.DragonPetFactory.GetInstance(nil,function(msg)
		if(msg)then
			local pet_dragon = msg.pet_dragon;
			if(pet_dragon)then
				pet_dragon.loadedFunc = Pet.DoLoadedFunc;--远程数据加载完成的事件
				pet_dragon.speakFunc = Pet.DoSpeakFunc;--自动说话的事件
				pet_dragon.speakInManualFunc = Pet.DoSpeakInManualFunc;--手动说话的事件
				pet_dragon.levelUpFunc = Pet.DoLevelUpFunc;--升级的事件
				pet_dragon.magic_star_levelUpFunc = Pet.DoLevelUpFunc_MagicStar;--魔法星升级事件
				pet_dragon.magic_star_rebornFunc = Pet.DoRebornFunc_MagicStar;--魔法星能量值从0变为非0
				pet_dragon.combatlelUpFunc = Pet.DoLevelUpFunc_Combat;--战斗等级升级
				pet_dragon.normalFunc = Pet.DoNormalFunc;--健康情况正常事件
				pet_dragon.sickFunc = Pet.DoSickFunc;--生病事件
				pet_dragon.deadFunc = Pet.DoDeadFunc;--死亡事件
				pet_dragon.startSpeakAndLoadTimer = Pet.DoStartSpeakAndLoadTimerFunc;--启动 自动说话 和自动加载数据的timer
				pet_dragon.stopSpeakAndLoadTimer = Pet.DoStopSpeakAndLoadTimerFunc;--关闭 自动说话 和自动加载数据的timer
				
				Pet.my_dragon_pet_instance = pet_dragon;
			end
			--备份龙的数据
			Pet.SetDragonInstance(Map3DSystem.User.nid,pet_dragon);

			Pet.SetWindowsHook_DragonHook();
			if(callbackFunc and type(callbackFunc) == "function")then
				callbackFunc({
				
				});
			end
			--重新加载次自己龙的数据，达到刷新状态的目的
			Pet.GetRemoteValue();
		end
	end);
	
	Pet.SendMail_Level_5 = false;
end
---------------------------------------------------
--自己坐骑的事件
----------------------------------------------------
--远程数据加载完成的事件
function Pet.DoLoadedFunc(msg)
	local p = Pet.GetPetValueByNID();
	if(not p)then return end
	LOG.std("", "debug", "pet", "DoLoadedFunc");
	Pet.Save_Local_Bean();
end
--自动说话事件
function Pet.DoSpeakFunc(msg)
	local p = Pet.GetPetValueByNID();
	if(not p)then return end
	if(msg)then
		local message = msg.message;
		LOG.std("", "debug", "pet", "DoSpeakFunc");
		LOG.std("", "debug", "pet", message);
	end
end
--手动说话事件
function Pet.DoSpeakInManualFunc(msg)
	local p = Pet.GetPetValueByNID();
	if(not p)then return end
	if(msg)then
		local message = msg.message;
		LOG.std("", "debug", "pet", "DoSpeakInManualFunc");
		LOG.std("", "debug", "pet", message);
	end
end
--升级事件
function Pet.DoLevelUpFunc(msg)
	local p = Pet.GetPetValueByNID();
	if(not p)then return end
	LOG.std("", "debug", "pet", "DoLevelUpFunc");
	
	if(commonlib.getfield("MyCompany.Aries.Quest.NPCs.DragonWish.RefreshStatus")) then
		MyCompany.Aries.Quest.NPCs.DragonWish.RefreshStatus();
	end
	
	local bean = Pet.GetBean();
	if(bean)then
		local level = bean.level;
		if(level >= 5)then
			if(not ItemManager.IfOwnGSItem(50264) and Pet.SendMail_Level_5 == false)then
				Pet.SendMail_Level_5 = true;
				----发邮件，提醒龙升到5级
				--NPL.load("(gl)script/apps/Aries/Mail/MailManager.lua");
				--MyCompany.Aries.Quest.Mail.MailManager.PushMailByID(8002);
			end
		end

		-- 抱抱龙升级后启动主动提醒
		NPL.load("(gl)script/apps/Aries/Desktop/Dock/AutoTips.lua");
		local AutoTips = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips");
		AutoTips.CheckShowPage(nil, nil, 3);
	end
end
--魔法星升级事件
function Pet.DoLevelUpFunc_MagicStar(msg)
	local p = Pet.GetPetValueByNID();
	if(not p)then return end
	LOG.std("", "debug", "pet","DoLevelUpFunc_MagicStar");
	local bean = Pet.GetBean();
	if(bean)then
		local mlel = bean.mlel or 0;
		local combatlel = bean.combatlel;
		MailManager_MagicStar.SentLevelMail(mlel);
		MyCompany.Aries.Desktop.SendMessage({type = MyCompany.Aries.Desktop.MSGTYPE.ON_LEVELUP, mlel = mlel, level = combatlel});
	end
end
--战斗等级升级
function Pet.DoLevelUpFunc_Combat(msg)
	LOG.std("", "debug", "pet", "DoLevelUpFunc_Combat");
	local p = Pet.GetPetValueByNID();
	if(not p)then return end
	local bean = Pet.GetBean();
	if(bean)then
		local combatlel = bean.combatlel;
		--发邮件 
		if(combatlel == 3)then
			System.App.profiles.ProfileManager.GetUserInfo(nil, nil, function(msg)
				if(msg and msg.users)then
					local users = msg.users[1];
					if(users)then
						local introducer = users.introducer;
						if(not introducer or introducer == -1)then return end

						Map3DSystem.App.profiles.ProfileManager.GetJID(introducer, function(jid)
							if(jid)then
								MyCompany.Aries.Quest.Mail.MailClient.SendMessage({
									msg_type = "redfruit_remind_levelup_3",
									nid = Map3DSystem.User.nid,
									mail_id = 10027,
								},jid);
							end
						end)
					end
				end
			end);
		end
		--拉升级活动---黄金新手礼包活动
		if(combatlel == 3 or combatlel == 5 or combatlel == 10 or combatlel == 15 or combatlel == 20 or combatlel == 25 or combatlel == 30)then
			local bHas = ItemManager.IfOwnGSItem(17150);
			if(not bHas)then return end
			local mail = MailManager.GetMail(10028);
			mail = commonlib.deepcopy(mail);
			mail.content = string.format("你真棒，已经%d级了，记得打开黄金新手礼包领取奖品哦，就在你的背包里，注意查看哦！",combatlel);
			MailManager.PushMail(mail);
		end

		local _list = {4, 8, 12, 16, 20, 25, 30, 35, 40, 45, 50,};
		local k,v;
		local cur_index;
		for k,v in ipairs(_list) do
			if(combatlel == v)then
				cur_index = k;
				break;
			end
		end
		if(cur_index)then
			local next_level = _list[cur_index+1];
			if(next_level)then
				local mail = MailManager.GetMail(10024);
				if(mail)then
					mail = commonlib.deepcopy(mail);
					mail.content = string.format("恭喜你现在升到%d级，可以获得一个%s，当你升到%d级，将获得下一个%s。",combatlel,tips_gsid22000,next_level,tips_gsid22000);
					MailManager.PushMail(mail);
				end
			end
		end

		-- 自动学习本系技能
		if(System.options.version=="kids") then
			NPL.load("(gl)script/apps/Aries/NPCs/MagicSchool/CombatSkillLearn.lua");
			local CombatSkillLearn = commonlib.gettable("MyCompany.Aries.Quest.NPCs.CombatSkillLearn");
			CombatSkillLearn.KidsAutoStudy();
		else
			NPL.load("(gl)script/apps/Aries/NPCs/MagicSchool/CombatSkillLearn.lua");
			local CombatSkillLearn = commonlib.gettable("MyCompany.Aries.Quest.NPCs.CombatSkillLearn");
			CombatSkillLearn.TeenAutoStudy();
			-- 17150_GoldenGiftPack
			local level_map = {
				[3] = true,
				[5] = true,
				[10] = true,
				[15] = true,
				[20] = true,
				[25] = true,
				[30] = true,
			};
			if(System.options.version == "teen") then
				level_map = {
					[5] = true,
					[15] = true,
					[25] = true,
					[35] = true,
					[45] = true,
					[55] = true,
				};
--				if(combatlel and level_map[combatlel]) then
					NPL.load("(gl)script/apps/Aries/Gift/TiroGiftPackPage.teen.lua");
					local TiroGiftPackPage = commonlib.gettable("MyCompany.Aries.Gift.TiroGiftPackPage");
					local bbounce = TiroGiftPackPage.CanGetUpgradeGift()
					--commonlib.echo("========lvlup")
					--commonlib.echo(MyCompany.Aries.Pet.GetBean())
					--commonlib.echo(bbounce)
					NPL.load("(gl)script/apps/Aries/Desktop/LinksArea/LinksAreaPage.lua");
					local LinksAreaPage = commonlib.gettable("MyCompany.Aries.Desktop.LinksAreaPage");					
					LinksAreaPage.FlashBtn("upgrade",bbounce)	
--				end
				NPL.load("(gl)script/apps/Aries/Quest/QuestWeeklyLinksViewPage.lua");
				local QuestWeeklyLinksViewPage = commonlib.gettable("MyCompany.Aries.Quest.QuestWeeklyLinksViewPage");
				QuestWeeklyLinksViewPage.LoadTemplates();
				if(QuestWeeklyLinksViewPage.templates)then	
					QuestWeeklyLinksViewPage.LoadPage();
					--commonlib.echo("===========QuestWeeklyLinksViewPage.LoadPage")
					--commonlib.echo(QuestWeeklyLinksViewPage.cur_page_source)
					--commonlib.echo(QuestWeeklyLinksViewPage.tips_enable)
					if (QuestWeeklyLinksViewPage.tips_enable) then
						LinksAreaPage.FlashBtn("weekly",true)	
					end
				end
			else
				if(combatlel and level_map[combatlel]) then
					NPL.load("(gl)script/apps/Aries/Desktop/Dock/DockTip.lua");
					local DockTip = commonlib.gettable("MyCompany.Aries.Desktop.DockTip");
					local item_name = "";
					local gsItem = ItemManager.GetGlobalStoreItemInMemory(17150);
					if(gsItem) then
						item_name = gsItem.template.name;
					end
					DockTip.GetInstance():PushNode({name = "DockTip.CharacterBagPage.ShowPage", title=string.format("可开启%s", item_name), gsid=17150, btn="立即开启", onclick="OnClick_Item", });
				end
			end
		end

		-- 升级后启动主动提醒
		NPL.load("(gl)script/apps/Aries/Desktop/Dock/AutoTips.lua");
		local AutoTips = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips");
		local system_looptip = commonlib.gettable("MyCompany.Aries.Desktop.AutoTips.system_looptip");
		if ((combatlel==5) and (not system_looptip.i2d3d))then
--			commonlib.echo("============lvl tips: 2d3d");
			AutoTips.CheckShowPage("2d3d", nil, 3);
		else
--			commonlib.echo("============lvl tips");
			AutoTips.CheckShowPage(nil,nil, 3);
		end
		
		-- inform desktop
		MyCompany.Aries.Desktop.SendMessage({type = MyCompany.Aries.Desktop.MSGTYPE.ON_LEVELUP, level = combatlel});
	end -- if (bean)
end
--魔法星能量值从0变为非0
function Pet.DoRebornFunc_MagicStar(msg)
	local p = Pet.GetPetValueByNID();
	if(not p)then return end
	LOG.std("", "info", "DoRebornFunc_MagicStar");
	MailManager_MagicStar.SentRebornMail();
end
--健康情况正常事件
function Pet.DoNormalFunc(msg)
	local p = Pet.GetPetValueByNID();
	if(not p)then return end
	LOG.std("", "system", "pet", "pet is normal");
end
--生病事件
function Pet.DoSickFunc(msg)
	local p = Pet.GetPetValueByNID();
	if(not p)then return end
	LOG.std("", "system", "pet", "pet is sick");
	--如果是驾驭状态 强制转换为跟随
	Pet.ForceFollowMe()
end
--死亡事件
function Pet.DoDeadFunc(msg)
	local p = Pet.GetPetValueByNID();
	if(not p)then return end
	LOG.std("", "system", "pet", "pet is dead");
	--强制送回家
	Pet.ForceGoHome();
end

--启动 自动说话 和自动加载数据的timer
function Pet.DoStartSpeakAndLoadTimerFunc(msg)
	local p = Pet.GetPetValueByNID();
	if(not p)then return end
	LOG.std("", "debug", "pet", "DoStartSpeakAndLoadTimer");
end
--关闭 自动说话 和自动加载数据的timer
function Pet.DoStopSpeakAndLoadTimerFunc(msg)
	local p = Pet.GetPetValueByNID();
	if(not p)then return end
	LOG.std("", "debug", "pet", "DoStopSpeakAndLoadTimer");
end
--初始化其他人的坐骑,每次请求成功就把上一个替换掉
--NOTE:2011/01/06 修改 这个函数每次调用 ,相当于重新加载次数据
function Pet.InitOPCDragonPet(nid,callbackFunc)
	--if(not nid or nid == ProfileManager.GetNID())then return end
	
	LOG.std("", "debug", "pet", "before create a dragon pet instance in InitOPCDragonPet:%d",nid or -1);
	MyCompany.Aries.Pet.DragonPetFactory.GetInstance(nid,function(msg)
		LOG.std("", "debug", "pet", "after create a dragon pet instance in InitOPCDragonPet");
		if(msg)then
			Pet.opc_dragon_pet_instance = msg.pet_dragon;
			--备份龙的数据
			Pet.SetDragonInstance(nid,msg.pet_dragon);
			if(callbackFunc and type(callbackFunc) == "function") then
				callbackFunc({});
			end
		else
			if(callbackFunc and type(callbackFunc) == "function") then
				-- no message is proceed
				callbackFunc();
			end
		end
	end);
end
--------------------------------------
function Pet.SetDragonInstance(nid,data)
	if(not Pet.pet_instance_map)then
		Pet.pet_instance_map = {};
	end
	Pet.pet_instance_map[nid] = data;
end
function Pet.GetDragonInstance(nid)
	if(Pet.pet_instance_map)then
		return Pet.pet_instance_map[nid];
	end
end
--2010/10/28 added this function by leio
--TODO:改进InitMyDragonPet and InitOPCDragonPet and callbackFunc
function Pet.CreateOrGetDragonInstance(nid,callbackFunc,cache_policy,bForceUpdate)
	nid = nid or Map3DSystem.App.profiles.ProfileManager.GetNID();
	if(not Pet.pet_instance_map)then
		Pet.pet_instance_map = {};
	end
	--local instance = Pet.pet_instance_map[nid];
	local instance = Pet.GetDragonInstance(nid);
	if(not instance or bForceUpdate)then
		MyCompany.Aries.Pet.DragonPetFactory.GetInstance(nid,function(msg)
			if(msg)then
				--Pet.pet_instance_map[nid] = msg.pet_dragon;
				Pet.SetDragonInstance(nid,msg.pet_dragon);
			end
			if(callbackFunc)then
				callbackFunc();
			end
		end,cache_policy);
	else
		instance:GetRemoteValue(function()
			if(callbackFunc)then
				callbackFunc();
			end
		end, cache_policy)
	end
	return instance;
end

-- get bean by nid, including combatlel, school
-- @param nid: nid of the number 
-- @param callbackFunc: function(msg) end, where msg ={bean={combatlel, mlel, level, isadopted}},   this is invoked everytime.
-- @param cache_policy: if nil, it will be "access plus 30 seconds"
-- @param bForceUpdate: force refetch from server. 
-- @return: the current bean table in memory. {combatlel, mlel, level, isadopted}. 
function Pet.CreateOrGetDragonInstanceBean(nid,callbackFunc,cache_policy,bForceUpdate)
	nid = nid or Map3DSystem.App.profiles.ProfileManager.GetNID();
	
	local instance = Pet.CreateOrGetDragonInstance(nid,function()
		if(callbackFunc)then
			--local dragon = Pet.pet_instance_map[nid];
			local dragon = Pet.GetDragonInstance(nid);
			if(dragon)then
				local bean = dragon:GetBean();
				local args = {
					bean = bean;
				}
				callbackFunc(args);
			end
		end
	end,cache_policy,bForceUpdate);
	if(instance)then
		local bean = instance:GetBean();
		return bean;
	end
end

--通过用户的nid获取坐骑的数据
function Pet.GetBean(nid)
	local p = Pet.GetPetValueByNID(nid);
	if(not p)then return end
	return p:GetBean();
end
function Pet.SetBean(nid,bean)
	if(not bean)then return end
	local p = Pet.GetPetValueByNID(nid);
	if(not p)then return end
	return p:SetBean(bean);
end
function Pet.GetPetID(nid)
	local p = Pet.GetPetValueByNID(nid);
	if(not p)then return end
	return p:GetPetID();
end
function Pet.GetLevel(nid)
	local p = Pet.GetPetValueByNID(nid);
	if(not p)then return end
	return p:GetLevel();
end
function Pet.IsSick(nid)
	local p = Pet.GetPetValueByNID(nid);
	if(not p)then return end
	return p:IsSick();
end
function Pet.IsDead(nid)
	local p = Pet.GetPetValueByNID(nid);
	if(not p)then return end
	return p:IsDead();
end
--获取自己坐骑的信息
--return follow or ride or home
function Pet.GetState(nid)
	local p = Pet.GetPetValueByNID(nid);
	if(not p)then return end
	return p:GetState();
end
function Pet.CanFollow(nid)
	local p = Pet.GetPetValueByNID(nid);
	if(not p)then return end
	return p:CanFollow();
end
function Pet.CanRide(nid)
	local p = Pet.GetPetValueByNID(nid);
	if(not p)then return end
	return p:CanRide();
end
function Pet.CanGoHome(nid)
	local p = Pet.GetPetValueByNID(nid);
	if(not p)then return end
	return p:CanGoHome();
end
function Pet.DoFollow(nid)
	local p = Pet.GetPetValueByNID(nid);
	if(not p)then return end
	p:DoFollow();
end
function Pet.DoRide(nid)
	local p = Pet.GetPetValueByNID(nid);
	if(not p)then return end
	p:DoRide();
end
function Pet.DoGoHome(nid)
	local p = Pet.GetPetValueByNID(nid);
	if(not p)then return end
	p:DoGoHome();
end
function Pet.DoFly(nid)
	local p = Pet.GetPetValueByNID(nid);
	if(not p)then return end
	p:DoFly();
end
--给用户的坐骑喂食，包括自己的
function Pet.DoFeed(nid,item,callbackFunc)
	local p = Pet.GetPetValueByNID(nid);
	if(not p)then return end
	p:DoFeed(item,callbackFunc);
end
function Pet.DoBath(nid,item,callbackFunc)
	local p = Pet.GetPetValueByNID(nid);
	if(not p)then return end
	p:DoBath(item,callbackFunc);
end
function Pet.DoPlayToy(nid,item,callbackFunc)
	local p = Pet.GetPetValueByNID(nid);
	if(not p)then return end
	p:DoPlayToy(item,callbackFunc);
end
function Pet.DoMedicine(nid,item,callbackFunc)
	local p = Pet.GetPetValueByNID(nid);
	if(not p)then return end
	p:DoMedicine(item,callbackFunc);
end
function Pet.DoRelive(nid,item,callbackFunc)
	local p = Pet.GetPetValueByNID(nid);
	if(not p)then return end
	p:DoRelive(item,callbackFunc);
end
function Pet.DoEspecial(nid,item,callbackFunc)
	local p = Pet.GetPetValueByNID(nid);
	if(not p)then return end
	p:DoEspecial(item,callbackFunc);
end
--针对自己的坐骑
function Pet.ForceFollowMe()
	local ItemManager = ItemManager;
	local item = ItemManager.GetMyMountPetItem();
	LOG.std("", "debug", "pet", "ForceFollowMe1");
	if(item and item.guid > 0) then
		local now_state =  item:WhereAmI();
		LOG.std("", "debug", "pet", "ForceFollowMe2");
		LOG.std("", "debug", "pet", now_state);
		if(now_state == "mount")then
			item:FollowMe();
		end
	end
end
--针对自己的坐骑
function Pet.ForceGoHome()
	local p = Pet.GetPetValueByNID();
	if(not p)then return end
	local ItemManager = ItemManager;
	local item = ItemManager.GetMyMountPetItem();
	if(item and item.guid > 0) then
		--执行回家的函数
		local now_state =  item:WhereAmI();
		if(now_state == "mount" or now_state == "follow")then
			item:GoHome(true);
		end
	end
end

-- get the current mount pet status. 
-- @return nil or "mount", "follow", "home", "unknown"
function Pet.GetMountPetStatus()
	local p = Pet.GetPetValueByNID();
	if(not p)then return end
	local ItemManager = ItemManager;
	local item = ItemManager.GetMyMountPetItem();
	if(item and item.guid > 0) then
		return item:WhereAmI();
	end
end

-- this is only used in kids version. 
function Pet.ForceCombatStatus()
	if(System.options.version=="kids") then
		local status = Pet.GetMountPetStatus()
		if(status == "home") then
			Pet.ForceFollowMe();
		end
	end
end

function Pet.ForceSpeakLevelUpMsg(level)
	local p = Pet.GetPetValueByNID();
	if(not p)then return end
	p:ForceSpeakLevelUpMsg(level)
end
function Pet.DoRefreshPetsInHomeland(nid)
	NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandGateway.lua");
	if(not nid or nid == ProfileManager.GetNID()) then
		if(Map3DSystem.App.HomeLand.HomeLandGateway.IsInMyHomeland())then
			Pet.RefreshMyPetsFromMemoryInHomeland();
		end
	else
		if(Map3DSystem.App.HomeLand.HomeLandGateway.IsInOtherHomeland())then
			Pet.RefreshOPCPetsFromMemoryInHomeland(nid);
		end
	end
end

function Pet.Save_Local_Bean()
	local bean = Pet.GetBean();
	if(bean)then
		-- duplicated calls to this function with the same bean data will be ignored.
		if(not Pet.last_pet_bean or not commonlib.partialcompare(Pet.last_pet_bean, bean)) then
			MyCompany.Aries.Player.SaveLocalData("Pet.Local_Bean", bean)
			Pet.last_pet_bean = commonlib.deepcopy(bean);
		end
	end
end
function Pet.Load_Local_Bean()
	local bean = MyCompany.Aries.Player.LoadLocalData("Pet.Local_Bean", nil);
	Pet.last_pet_bean = commonlib.deepcopy(bean);
	return bean;
end
------------------
--hook 坐骑的操作
------------------
function Pet.SetWindowsHook_DragonHook()
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = Pet.DragonHookHandler, 
		hookName = "SetWindowsHook_DragonHook", appName = "Aries", wndName = "main"});
end

local tracked_aries_types = {
	["OnFetchDragonFromSophie"] = true,
	["OnStartFlying"] = true,
	["OnEndFlying"] = true,
	["PetMedicine"] = true,
}
function Pet.DragonHookHandler(nCode, appName, msg, value)
	if(tracked_aries_types[msg.aries_type or ""]) then
		--领取坐骑
		if(msg.aries_type == "OnFetchDragonFromSophie")then
			LOG.std("", "debug", "pet", "==================OnFetchDragonFromSophie");
			Pet.ForceSpeakLevelUpMsg(0);
		--开始飞翔
		elseif(msg.aries_type == "OnStartFlying")then
			LOG.std("", "debug", "pet", "==================OnStartFlying");
			Pet.DoFly();
		--结束飞翔
		elseif(msg.aries_type == "OnEndFlying")then
			LOG.std("", "debug", "pet", "==================OnEndFlying");
			Pet.DoRide();
		--吃药 或者 复活
		elseif(msg.aries_type == "PetMedicine")then
		
		end
	end
	return nCode;
end
--是否可以战斗
function Pet.CombatIsOpened()
	return true;
end
--找woody复活
function Pet.DoTeleportWoody()
    local HomeLandGateway = Map3DSystem.App.HomeLand.HomeLandGateway;
    if(HomeLandGateway.IsInHomeland()) then
        -- leave the homeland and teleport to woody
        HomeLandGateway.SetTeleportBackPosition(19999.95703125, -0.7812192440033, 20011.130859375);
        HomeLandGateway.Away();
    else
        -- directly teleport to woody
		local params = {
			asset_file = "character/v5/temp/Effect/LoyaltyDown_Impact_Base.x",
			binding_obj_name = ParaScene.GetPlayer().name,
			start_position = nil,
			duration_time = 800,
			force_name = nil,
			begin_callback = function() 
					local player = ParaScene.GetPlayer();
					if(player and player:IsValid() == true) then
						player:ToCharacter():Stop();
					end
				end,
			end_callback = nil,
			stage1_time = 600,
			stage1_callback = function()
					local player = ParaScene.GetPlayer();
					if(player and player:IsValid() == true) then
						player:SetPosition(19999.95703125, -0.7812192440033, 20011.130859375);
						-- refresh the avatar, mount pet and follow pet
						ItemManager.RefreshMyself();
						---- refresh all <pe:player>
						--Map3DSystem.mcml_controls.GetClassByTagName("pe:player").RefreshContainingPageCtrls();
					end
				end,
			stage2_time = nil,
			stage2_callback = nil,
		};
		EffectManager.CreateEffect(params);
    end
end