--[[
Title: spell cast viewer page
Author(s): WangTian
Date: 2009/5/5
Desc: script/apps/Aries/Pipeline/SpellCastViewer/SpellCastViewerPage.html
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Pipeline/SpellCastViewer/SpellCastViewerPage.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Combat/CombatCameraView.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/mcml/PageCtrl.lua");

NPL.load("(gl)script/apps/Aries/Combat/main.lua");
NPL.load("(gl)script/apps/Aries/Combat/SpellCast.lua");

-- create class
local SpellCastViewerPage = {};
commonlib.setfield("MyCompany.Aries.Combat.SpellCastViewerPage", SpellCastViewerPage);

local CombatCameraView = commonlib.gettable("MotionEx.CombatCameraView");

NPL.load("(gl)script/apps/Aries/Combat/CombatCameraView.lua");
local CombatCameraView = commonlib.gettable("MotionEx.CombatCameraView");

local page;
local SpellCast = MyCompany.Aries.Combat.SpellCast;

-- on init show the current avatar in pe:avatar
function SpellCastViewerPage.OnInit()
	page = document:GetPageCtrl();
    SpellCastViewerPage.EnableMotion();

	-- some code driven audio files for backward compatible
	AudioEngine.Init();
	-- set max concurrent sounds
	AudioEngine.SetGarbageCollectThreshold(10)
	-- load wave description resources
	AudioEngine.LoadSoundWaveBank("config/Aries/Audio/AriesRegionBGMusics.bank.xml");
end

function SpellCastViewerPage.TestSpell_Lightning()
	SpellCastViewerPage.TestSpellFromFile("config/Aries/Spells/TestSpell_Lightning.xml");
end

function SpellCastViewerPage.TestSpell_Heal()
	SpellCastViewerPage.TestSpellFromFile("config/Aries/Spells/TestSpell_Heal.xml");
end

function SpellCastViewerPage.TestSpell_Leech()
	SpellCastViewerPage.TestSpellFromFile("config/Aries/Spells/TestSpell_Leech.xml");
end

function SpellCastViewerPage.RemoveTestArena()
	NPL.load("(gl)script/apps/Aries/Combat/ObjectManager.lua");
	MyCompany.Aries.Combat.ObjectManager.DestroyArenaObj(9991);

	MyCompany.Aries.Quest.NPC.DeleteNPCCharacter(39001, 10091);
	MyCompany.Aries.Quest.NPC.DeleteNPCCharacter(39001, 10092);
	MyCompany.Aries.Quest.NPC.DeleteNPCCharacter(39001, 10093);
	MyCompany.Aries.Quest.NPC.DeleteNPCCharacter(39001, 10094);

	local i = 1;
	for i = 1, 4 do
		local _obj = ParaScene.GetCharacter(tostring(1234560 + i));
		if(_obj and _obj:IsValid() == true) then
			ParaScene.Delete(_obj);
		end
		local _obj = ParaScene.GetCharacter(tostring(1234560 + i).."+driver");
		if(_obj and _obj:IsValid() == true) then
			ParaScene.Delete(_obj);
		end
	end
end

-- switch to teen version assets
function SpellCastViewerPage.SwitchToTeenVersionAssets()
	System.options.version = "teen";
	ParaIO.LoadReplaceFile("config/AssetsReplaceFile_HaqiTown_teen_zhCN.xml", false);
end

--NOTE:added by leio 2011/05/21
--[[
NPL.load("(gl)script/apps/Aries/Combat/CombatCameraView.lua");
local CombatCameraView = commonlib.gettable("MotionEx.CombatCameraView");
CombatCameraView.enabled = true;
NPL.load("(gl)script/apps/Aries/Pipeline/SpellCastViewer/SpellCastViewerPage.lua");
local character_list = {
	[1] = {AssetFile = "character/v3/Elf/Female/ElfFemale.xml", Scale="1" },
	[2] = {AssetFile = "character/v3/Elf/Female/ElfFemale.xml",Scale="1" },
	[3] = {AssetFile = "character/v3/Elf/Female/ElfFemale.xml",Scale="1" },
	[4] = {AssetFile = "character/v3/Elf/Female/ElfFemale.xml",Scale="1" },
	[5] = {AssetFile = "character/v5/10mobs/HaqiTown/BlazeHairMonster/BlazeHairMonster.x",Scale="1" },
	[6] = {AssetFile = "character/v5/10mobs/HaqiTown/EvilSnowman/EvilSnowman.x",Scale="1" },
	[7] = {AssetFile = "character/v5/10mobs/HaqiTown/FireRockyOgre/FireRockyOgre_02.x",Scale="1" },
	[8] = {AssetFile = "character/v5/10mobs/HaqiTown/RedCrab/RedCrab.x",Scale="1" },
}
MyCompany.Aries.Combat.SpellCastViewerPage.RemoveTestArena()
-- some code driven audio files for backward compatible
AudioEngine.Init();
-- set max concurrent sounds
AudioEngine.SetGarbageCollectThreshold(10)
-- load wave description resources
AudioEngine.LoadSoundWaveBank("config/Aries/Audio/AriesRegionBGMusics.bank.xml");
MyCompany.Aries.Combat.SpellCastViewerPage.CreateArena(x, y, z,character_list,function()
	-- force open sound for taurus
	ParaAudio.SetVolume(1);
	MyCompany.Aries.Combat.SpellCastViewerPage.TestSpellFromFile("config/Aries/Spells/Storm_SingleAttack_Level1.xml",1,5);
end);
--]]
function SpellCastViewerPage.CreateArena(x, y, z,character_list,callbackFunc)
	if(not character_list)then
		return
	end
	NPL.load("(gl)script/apps/Aries/Quest/NPC.lua");
	NPL.load("(gl)script/apps/Aries/Combat/ObjectManager.lua");
	
	NPL.load("(gl)script/kids/3DMapSystemItem/ItemManager.lua");
	Map3DSystem.Item.ItemManager.GlobalStoreTemplates[10001] = {
		assetfile = "character/v3/PurpleDragonMajor/Female/PurpleDragonMajorFemale.xml",
		template = {name = "taurus"}
	};
	
	-- for SentientGroupIDs
	NPL.load("(gl)script/apps/Aries/Pet/main.lua");
	
	MyCompany.Aries.Combat.ObjectManager.SyncEssentialCombatResource(function()
		
		local p_x, p_y, p_z = ParaScene.GetPlayer():GetPosition();
		if(x and y and z) then
			p_x = x;
			p_y = y;
			p_z = z;
		end

		NPL.load("(gl)script/apps/Aries/Combat/MsgHandler.lua");
		local MsgHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");

		local arena_meta = MsgHandler.Get_arena_meta_data_by_id(9991);
		arena_meta.mode = "pve"

		MyCompany.Aries.Combat.ObjectManager.CreateArenaObj(9991, {x = p_x, y = p_y, z = p_z}, true);
		-- if nid is not available it is a Taurus project character
		-- create a character 
		local i;
		for i = 1, 8 do
			local node = character_list[i];
			if(node)then
				local Scale = tonumber(node.Scale) or 1;
				if( i <= 4)then
					local nid_name = tostring(1234560 + i);
					local AssetFile = node.AssetFile or "character/v3/Elf/Female/ElfFemale.xml";
					local CCSInfoStr = node.CCSInfoStr or "0#1#0#2#1#@0#F#0#0#0#0#0#F#0#0#0#0#9#F#0#0#0#0#9#F#0#0#0#0#10#F#0#0#0#0#8#F#0#0#0#0#0#F#0#0#0#0#@1#10001#0#3#11009#0#0#0#0#0#0#0#0#1072#1073#1074#0#0#0#0#0#0#0#0#";
					local player = ParaScene.GetObject(nid_name);
					if(player:IsValid() == false) then
						Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_CreateObject, 
							silentmode = true,
							SkipHistory = true,
							obj_params = {
								name = nid_name,
								AssetFile = AssetFile,
								CCSInfoStr = CCSInfoStr,
								x = p_x,
								y = p_y,
								z = p_z,
								IsCharacter = true,
								IsPersistent = false, -- do not save an GSL agent when saving scene
								scaling = Scale,
							},
						})
						--local player = ParaScene.GetObject(nid_name);
						--if(player:IsValid() == true) then
							--Map3DSystem.UI.CCS.ApplyCCSInfoString(player, CCSInfoStr);
						--end
					end
			
					MyCompany.Aries.Combat.ObjectManager.MountPlayerOnSlot(1234560 + i, 9991, i);
				else
					local AssetFile = node.AssetFile or "character/v5/10mobs/HaqiTown/BlazeHairMonster/BlazeHairMonster.x";
					local params = {
						position = {p_x, p_y, p_z},
						assetfile_char = AssetFile,
						instance = 10090 + i - 4,
						name = "",
						scaling = Scale,
						--scale_char = Scale,
					};
					local NPC = MyCompany.Aries.Quest.NPC;
					local char_buffslot = NPC.CreateNPCCharacter(39001, params);
					MyCompany.Aries.Combat.ObjectManager.MountNPCOnSlot(39001, 10090 + i - 4, 9991, i);
				end
			end
		end
		if(callbackFunc)then
			callbackFunc();
		end
	end)
end
function SpellCastViewerPage.TestArena(x, y, z)
	NPL.load("(gl)script/apps/Aries/Quest/NPC.lua");
	NPL.load("(gl)script/apps/Aries/Combat/ObjectManager.lua");
	
	NPL.load("(gl)script/kids/3DMapSystemItem/ItemManager.lua");
	Map3DSystem.Item.ItemManager.GlobalStoreTemplates[10001] = {
		assetfile = "character/v3/PurpleDragonMajor/Female/PurpleDragonMajorFemale.xml",
		template = {name = "taurus"}
	};
	
	NPL.load("(gl)script/apps/Aries/mcml/mcml_aries.lua");
	MyCompany.Aries.mcml_controls.register_all();

	-- for SentientGroupIDs
	NPL.load("(gl)script/apps/Aries/Pet/main.lua");
	
	MyCompany.Aries.Combat.ObjectManager.SyncEssentialCombatResource(function()
		
		
		--local nid = System.App.profiles.ProfileManager.GetNID();
		--
		--if(nid) then
			--MyCompany.Aries.Combat.ObjectManager.CreateArenaObj(9991, {x = 19614.01171875, y = 1.5266243219376, z = 19873.302734375});
			---- if nid is available it is an Aries project character
			--MyCompany.Aries.Combat.ObjectManager.MountPlayerOnSlot(nid, 9991, 1);
			--return;
		--end
		local p_x, p_y, p_z = ParaScene.GetPlayer():GetPosition();
		if(x and y and z) then
			p_x = x;
			p_y = y;
			p_z = z;
		end

		NPL.load("(gl)script/apps/Aries/Combat/MsgHandler.lua");
		local MsgHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");

		local arena_meta = MsgHandler.Get_arena_meta_data_by_id(9991);
		arena_meta.mode = "pve"

		MyCompany.Aries.Combat.ObjectManager.CreateArenaObj(9991, {x = p_x, y = p_y, z = p_z}, true);
		-- if nid is not available it is a Taurus project character
		-- create a character 
		
		local player_assets = {};
		local player_coinfig = "config/SpellCastViewerPage_Players.xml";
		local xmlRoot = ParaXML.LuaXML_ParseFile(player_coinfig);
		if(xmlRoot) then
			local each_player;
			for each_player in commonlib.XPath.eachNode(xmlRoot, "/player_assets/asset") do
				if(each_player and each_player.attr) then
					if(tonumber(each_player.attr.id) and each_player.attr.path) then
						player_assets[tonumber(each_player.attr.id)] = each_player.attr;
					end
				end
			end
		end
		
		local i = 1;
		for i = 1, 4 do
			local nid_name = tostring(1234560 + i);
			
			local player = ParaScene.GetObject(nid_name);
			if(player:IsValid() == false) then
				local obj_params = {
					name = nid_name,
					AssetFile = "character/v3/Elf/Female/ElfFemale.xml",
					CCSInfoStr = "0#1#0#2#1#@0#F#0#0#0#0#0#F#0#0#0#0#9#F#0#0#0#0#9#F#0#0#0#0#10#F#0#0#0#0#8#F#0#0#0#0#0#F#0#0#0#0#@1#10001#0#3#11009#0#0#0#0#0#0#0#0#1072#1073#1074#0#0#0#0#0#0#0#0#",
					x = p_x,
					y = p_y,
					z = p_z,
					IsCharacter = true,
					IsPersistent = false, -- do not save an GSL agent when saving scene
				};

				if(player_assets[i]) then
					obj_params.AssetFile = player_assets[i].path;
					obj_params.CCSInfoStr = nil;
					obj_params.scaling = tonumber(player_assets[i].scale);
				end

				Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_CreateObject, 
					silentmode = true,
					SkipHistory = true,
					obj_params = obj_params,
				})
				local player = ParaScene.GetObject(nid_name);
				if(player:IsValid() == true and not player_assets[i]) then
					Map3DSystem.UI.CCS.ApplyCCSInfoString(player, "0#1#0#2#1#@0#F#0#0#0#0#0#F#0#0#0#0#9#F#0#0#0#0#9#F#0#0#0#0#10#F#0#0#0#0#8#F#0#0#0#0#0#F#0#0#0#0#@1#10001#0#3#11009#0#0#0#0#0#0#0#0#1072#1073#1074#0#0#0#0#0#0#0#0#");
				end
			end
			
			MyCompany.Aries.Combat.ObjectManager.MountPlayerOnSlot(1234560 + i, 9991, i);
		end
		
		local mob_assets = {{},{},{},{},};
		local mob_coinfig = "config/SpellCastViewerPage_Mobs.xml";
		local xmlRoot = ParaXML.LuaXML_ParseFile(mob_coinfig);
		if(xmlRoot) then
			local each_mob;
			for each_mob in commonlib.XPath.eachNode(xmlRoot, "/mob_assets/asset") do
				if(each_mob and each_mob.attr) then
					if(tonumber(each_mob.attr.id) and each_mob.attr.path) then
						mob_assets[tonumber(each_mob.attr.id)] = each_mob.attr;
					end
				end
			end
		end

		local i = 1;
		for i = 1, 4 do
			local asset_char;
			
			if(i == 1) then
				asset_char = mob_assets[1].path or "character/v5/10mobs/HaqiTown/BlazeHairMonster/BlazeHairMonster.x";
			elseif(i == 2) then
				asset_char = mob_assets[2].path or "character/v5/10mobs/HaqiTown/EvilSnowman/EvilSnowman.x";
			elseif(i == 3) then
				asset_char = mob_assets[3].path or "character/v5/10mobs/HaqiTown/FireRockyOgre/FireRockyOgre_02.x";
			elseif(i == 4) then
				asset_char = mob_assets[4].path or "character/v5/10mobs/HaqiTown/RedCrab/RedCrab.x";
			end
			

			--if(i == 1) then
				--asset_char = "character/v3/GameNpc/GTCK/GTCK.x";
				----asset_char = "character/v3/GameNpc/XRKZS/XRKZS.x";
			--elseif(i == 2) then
				--asset_char = "character/v3/GameNpc/HKBS/HKBS.x";
			--elseif(i == 3) then
				--asset_char = "character/v3/GameNpc/XRKZS/XRKZS.x";
			--elseif(i == 4) then
				--asset_char = "character/v3/GameNpc/FCSQ/FCSQ.x";
			--end
			local params = {
				position = {p_x, p_y, p_z},
				assetfile_char = asset_char,
				instance = 10090 + i,
				name = "",
				scaling = 1,
				scale_char = 1,
			};
			params.scaling = mob_assets[i].scale or 1;
			local NPC = MyCompany.Aries.Quest.NPC;
			local char_buffslot = NPC.CreateNPCCharacter(39001, params);
			MyCompany.Aries.Combat.ObjectManager.MountNPCOnSlot(39001, 10090 + i, 9991, 4 + i);
		end

		local i = 1;
		for i = 1, 8 do
			MyCompany.Aries.Combat.ObjectManager.ShowPipsOnSlot(9991, i, 3, 4);
		end
		SpellCastViewerPage.SpellFinishedCallback(true);
	end)
	
end

local last_caster_id = nil;

function SpellCastViewerPage.TestSpellFromFile_page(file)
	
	-- force open sound for taurus
	ParaAudio.SetVolume(1);

	local caster_id = page:GetValue("caster_id");
    local target_id = page:GetValue("target_id");
    if(tonumber(caster_id)) then
        caster_id = tonumber(caster_id);
    end
    if(tonumber(target_id)) then
        target_id = tonumber(target_id);
    end
	SpellCastViewerPage.TestSpellFromFile("config/Aries/Spells/"..file, caster_id, target_id);
	-- show the sequence arrow
    MyCompany.Aries.Combat.ObjectManager.ShowSequenceArrow(9991, last_caster_id, caster_id);
	last_caster_id = caster_id;

	ParaMisc.CopyTextToClipboard(file);
end
function SpellCastViewerPage.TestSpellFromAbsoluteFile(file,caster_id, target_id, enable_camera)
	CombatCameraView.enabled = enable_camera;
	-- force open sound for taurus
	ParaAudio.SetVolume(1);
	SpellCastViewerPage.TestSpellFromFile(file, caster_id, target_id);
	-- show the sequence arrow
    MyCompany.Aries.Combat.ObjectManager.ShowSequenceArrow(9991, last_caster_id, caster_id);
	last_caster_id = caster_id;
end

function SpellCastViewerPage.GetCasterAndTarget(caster_id, target_id)
	-- if the arena is created use the arena object to play spell effect
		
		local caster;
		local target;
		if(not caster_id) then
			caster = {isPlayer = true, nid = 1234561, slotid = caster_id};
		else
			if(caster_id >= 1 and caster_id <= 4) then
				caster = {isPlayer = true, nid = 1234560 + caster_id, slotid = caster_id};
			elseif(caster_id >= 5 and caster_id <= 8) then
				caster = {isPlayer = false, npc_id = 39001, instance = 10090 + (caster_id - 4), slotid = caster_id};
			end
		end
		if(not target_id) then
			target = {isPlayer = false, npc_id = 39001, instance = 10091, slotid = target_id};
		else
			if(target_id >= 1 and target_id <= 4) then
				target = {isPlayer = true, nid = 1234560 + target_id, slotid = target_id};
			elseif(target_id >= 5 and target_id <= 8) then
				target = {isPlayer = false, npc_id = 39001, instance = 10090 + (target_id - 4), slotid = target_id};
			end
		end
	return caster,target;
end

local charm_key_id_mapping = {
	["Fire_FireDamageBlade"] = 11,
	["Fire_AreaAccuracyWeakness"] = 12,
	["Fire_FireDispellWeakness"] = 13,
	["Storm_StormAccuracyBlade"] = 14,
	["Storm_StormDamageBlade"] = 15,
	["Storm_StormDispellWeakness"] = 16,
	["Ice_IceDamageBlade"] = 17,
	["Ice_IceDispellWeakness"] = 18,
	["Life_LifeDamageBlade"] = 19,
	["Life_AreaAccuracyBlade"] = 20,
	["Life_HealBlade"] = 21,
	["Life_LifeDispellWeakness"] = 22,
	["Death_DeathDamageBlade"] = 23,
	["Death_AreaDamageWeakness"] = 24,
	["Death_HealWeakness"] = 25,
	["Death_DeathDispellWeakness"] = 26,
};

local ward_key_id_mapping = {
	["Fire_FireDamageTrap"] = 21,
	["Fire_FirePrism"] = 22,
	["Fire_FireGreatShield"] = 23,
	["Storm_StormDamageTrap"] = 24,
	["Storm_AreaDamageTrap"] = 25,
	["Storm_StormGreatShield"] = 26,
	["Ice_GlobalShield"] = 27,
	["Ice_IceDamageTrap"] = 28,
	["Ice_IcePrism"] = 29,
	["Ice_Absorb_LevelX"] = 30,
	["Ice_StunAbsorb"] = 31,
	["Ice_IceGreatShield"] = 32,
	["Life_Absorb_Level3"] = 33,
	["Life_LifePrism"] = 34,
	["Life_Absorb_Level3"] = 35,
	["Life_LifeDamageTrap"] = 36,
	["Life_LifeGreatShield"] = 37,
	["Death_SymmetryGlobalTrap_Target"] = 38,
	["Death_SymmetryGlobalTrap_Caster"] = 39,
	["Death_DeathDamageTrap"] = 40,
	["Death_DeathPrism"] = 41,
	["Death_GlobalDamageTrap"] = 42,
	["Death_DeathGreatShield"] = 43,
};

local playing_id = 0;

function SpellCastViewerPage.TestSpellFromFile(file, caster_id, target_id)
	 --force load all cameras motion file
	CombatCameraView.ForceLoadAllCameras();
	local key = string.match(file, [[([^/]-)%.xml$]]);
	if(not key) then
		log("error: invalid key name for SpellCastViewerPage.TestSpellFromFile file="..file.."\n")
		return;
	end

	NPL.load("(gl)script/apps/Aries/Quest/NPC.lua");
	NPL.load("(gl)script/apps/Aries/Combat/ObjectManager.lua");
	NPL.load("(gl)script/apps/Aries/Combat/SpellPlayer.lua");
	local SpellPlayer = MyCompany.Aries.Combat.SpellPlayer;
	---- test destory arena object
	--MyCompany.Aries.Combat.ObjectManager.DestroyArenaObj(9991)
	
	local bArenaCreated = MyCompany.Aries.Combat.ObjectManager.IsArenaObjCreated(9991);

	local commentfile = string.gsub(file, "%.xml$", ".comment.xml");

	playing_id = playing_id + 1;

	local quality;
	if(page)then
		quality = page:GetValue("SpellQuality");
	end
	if(quality == "White") then
		quality = nil;
	end
	
	if(bArenaCreated == true) then
		if(key == "Death_SymmetryGlobalTrap") then
			-- single spell
			local caster, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, target_id)
			SpellPlayer.PlaySpellEffect_single(9991, caster, target, file, {{100}}, {{
				target_wards = tostring(ward_key_id_mapping[key.."_Target"])..",6,6,", last_target_wards = "0,6,6", 
				target_charms = "1,2,", last_target_charms = "0,2", 
				caster_wards = tostring(ward_key_id_mapping[key.."_Caster"])..",6,6,", last_caster_wards = "0,6,6", 
				caster_charms = "1,2,", last_caster_charms = "0,2"
			}}, SpellCastViewerPage.SpellFinishedCallback, nil, true, nil, playing_id, nil, quality);
			
		elseif(string.find(string.lower(file), "area") and (string.find(string.lower(file), "blade") or string.find(string.lower(file), "weakness"))) then
			-- area attack or area heal
			local targets = {};
			if(target_id <= 4) then
				local _, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, 1);
				table.insert(targets, target);
				local _, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, 2);
				table.insert(targets, target);
				local _, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, 3);
				table.insert(targets, target);
				local _, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, 4);
				table.insert(targets, target);
			elseif(target_id >= 5) then
				local _, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, 5);
				table.insert(targets, target);
				local _, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, 6);
				table.insert(targets, target);
				local _, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, 7);
				table.insert(targets, target);
				local _, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, 8);
				table.insert(targets, target);
			end
			local caster, __ = SpellCastViewerPage.GetCasterAndTarget(caster_id, target_id)
			SpellPlayer.PlaySpellEffect_multiple(9991, caster, targets, file, {{100, 200, 300, 400}}, {
				{target_wards = "6,6,6,", last_target_wards = "0,0,6", target_charms = tostring(charm_key_id_mapping[key])..",2", last_target_charms = "0,2,"},
				{target_wards = "6,6,6,", last_target_wards = "0,0,6", target_charms = tostring(charm_key_id_mapping[key])..",2", last_target_charms = "0,2,"},
				{target_wards = "6,6,6,", last_target_wards = "0,0,6", target_charms = tostring(charm_key_id_mapping[key])..",2", last_target_charms = "0,2,"},
				{target_wards = "6,6,6,", last_target_wards = "0,0,6", target_charms = tostring(charm_key_id_mapping[key])..",2", last_target_charms = "0,2,"},
				}, SpellCastViewerPage.SpellFinishedCallback, nil, true, nil, playing_id, nil, quality);
		elseif(string.find(string.lower(file), "area") and (string.find(string.lower(file), "shield") or string.find(string.lower(file), "prism") or 
				string.find(string.lower(file), "absorb") or string.find(string.lower(file), "trap"))) then
			-- area attack or area heal
			local targets = {};
			if(target_id <= 4) then
				local _, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, 1);
				table.insert(targets, target);
				local _, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, 2);
				table.insert(targets, target);
				local _, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, 3);
				table.insert(targets, target);
				local _, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, 4);
				table.insert(targets, target);
			elseif(target_id >= 5) then
				local _, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, 5);
				table.insert(targets, target);
				local _, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, 6);
				table.insert(targets, target);
				local _, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, 7);
				table.insert(targets, target);
				local _, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, 8);
				table.insert(targets, target);
			end
			local caster, __ = SpellCastViewerPage.GetCasterAndTarget(caster_id, target_id)
			SpellPlayer.PlaySpellEffect_multiple(9991, caster, targets, file, {{100, 200, 300, 400}}, {
				{target_wards = tostring(ward_key_id_mapping[key])..",6,6,", last_target_wards = "0,6,6", target_charms = "1,2,", last_target_charms = "1,2"},
				{target_wards = tostring(ward_key_id_mapping[key])..",6,6,", last_target_wards = "0,6,6", target_charms = "1,2,", last_target_charms = "1,2"},
				{target_wards = tostring(ward_key_id_mapping[key])..",6,6,", last_target_wards = "0,6,6", target_charms = "1,2,", last_target_charms = "1,2"},
				{target_wards = tostring(ward_key_id_mapping[key])..",6,6,", last_target_wards = "0,6,6", target_charms = "1,2,", last_target_charms = "1,2"},
				}, SpellCastViewerPage.SpellFinishedCallback, nil, true, nil, playing_id);
		elseif(string.find(string.lower(file), "area")) then
			-- area attack or area heal
			local targets = {};
			if(target_id <= 4) then
				local _, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, 1);
				table.insert(targets, target);
				local _, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, 2);
				table.insert(targets, target);
				local _, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, 3);
				table.insert(targets, target);
				local _, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, 4);
				table.insert(targets, target);
			elseif(target_id >= 5) then
				local _, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, 5);
				table.insert(targets, target);
				local _, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, 6);
				table.insert(targets, target);
				local _, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, 7);
				table.insert(targets, target);
				local _, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, 8);
				table.insert(targets, target);
			end
			local caster, __ = SpellCastViewerPage.GetCasterAndTarget(caster_id, target_id)
			SpellPlayer.PlaySpellEffect_multiple(9991, caster, targets, file, {{100, 200, 300, 400}}, nil, SpellCastViewerPage.SpellFinishedCallback, nil, true, nil, playing_id, nil, quality);
		elseif(string.find(string.lower(file), "arena")) then
			-- arena attack
			local targets = {};
			local _, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, 1);
			table.insert(targets, target);
			local _, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, 2);
			table.insert(targets, target);
			local _, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, 3);
			table.insert(targets, target);
			local _, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, 4);
			table.insert(targets, target);
			local _, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, 5);
			table.insert(targets, target);
			local _, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, 6);
			table.insert(targets, target);
			local _, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, 7);
			table.insert(targets, target);
			local _, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, 8);
			table.insert(targets, target);
			local caster, __ = SpellCastViewerPage.GetCasterAndTarget(caster_id, target_id)
			SpellPlayer.PlaySpellEffect_multiple(9991, caster, targets, file, {{100, 200, 300, 400, 500, 600, 700, 800}}, nil, SpellCastViewerPage.SpellFinishedCallback, nil, true, nil, playing_id, nil, quality);
		elseif(string.find(string.lower(file), "singleattackwithlifetap")) then
			-- single spell
			local caster, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, target_id)
			SpellPlayer.PlaySpellEffect_single(9991, caster, target, file, {{100},{25}}, nil, SpellCastViewerPage.SpellFinishedCallback, nil, true, nil, playing_id, nil, quality);
		elseif(string.find(string.lower(file), "singleattackwithpercent")) then
			-- single spell
			local caster, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, target_id)
			SpellPlayer.PlaySpellEffect_single(9991, caster, target, file, {{200},{100}}, nil, SpellCastViewerPage.SpellFinishedCallback, nil, true, nil, playing_id, nil, quality);
		elseif(string.find(string.lower(file), "singleattackwithimmolate")) then
			-- single spell
			local caster, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, target_id)
			SpellPlayer.PlaySpellEffect_single(9991, caster, target, file, {{600},{250}}, nil, SpellCastViewerPage.SpellFinishedCallback, nil, true, nil, playing_id, nil, quality);
		elseif(string.find(string.lower(file), "singlehealwithimmolate")) then
			-- single spell
			local caster, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, target_id)
			SpellPlayer.PlaySpellEffect_single(9991, caster, target, file, {{700},{250}}, nil, SpellCastViewerPage.SpellFinishedCallback, nil, true, nil, playing_id, nil, quality);
		elseif(string.find(string.lower(file), "stealpositivecharm")) then
			-- single spell
			local caster, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, target_id)
			SpellPlayer.PlaySpellEffect_single(9991, caster, target, file, {{100}}, {{target_wards = "6,6,6,", last_target_wards = "0,0,6", target_charms = "0,2,", last_target_charms = "1,2", caster_wards = "6,6,6,", last_caster_wards = "0,0,6", caster_charms = "1,2,", last_caster_charms = "0,2"}}, SpellCastViewerPage.SpellFinishedCallback, nil, true, nil, playing_id, nil, quality);
		elseif(string.find(string.lower(file), "stealpositiveward")) then
			-- single spell
			local caster, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, target_id)
			SpellPlayer.PlaySpellEffect_single(9991, caster, target, file, {{100}}, {{target_wards = "0,6,6,", last_target_wards = "6,6,6", target_charms = "0,2,", last_target_charms = "1,2", caster_wards = "6,6,6,", last_caster_wards = "0,6,6", caster_charms = "1,2,", last_caster_charms = "0,2"}}, SpellCastViewerPage.SpellFinishedCallback, nil, true, nil, playing_id, nil, quality);
		elseif(string.find(string.lower(file), "blade") or string.find(string.lower(file), "weakness")) then
			-- single spell
			local caster, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, target_id)
			SpellPlayer.PlaySpellEffect_single(9991, caster, target, file, {{100}}, {{
				target_wards = "6,6,6,", last_target_wards = "0,6,6", 
				target_charms = tostring(charm_key_id_mapping[key])..",2,", last_target_charms = "0,2", 
				caster_wards = "6,6,6,", last_caster_wards = "0,6,6", 
				caster_charms = "1,2,", last_caster_charms = "0,2"
			}}, SpellCastViewerPage.SpellFinishedCallback, nil, true, nil, playing_id, nil, quality);
		elseif(string.find(string.lower(file), "shield") or string.find(string.lower(file), "trap") or 
				string.find(string.lower(file), "prism") or string.find(string.lower(file), "absorb")) then
			-- single spell
			local caster, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, target_id)
			SpellPlayer.PlaySpellEffect_single(9991, caster, target, file, {{100}}, {{
				target_wards = tostring(ward_key_id_mapping[key])..",6,6,", last_target_wards = "0,6,6", 
				target_charms = "0,2,", last_target_charms = "0,2", 
				caster_wards = "6,6,6,", last_caster_wards = "0,6,6", 
				caster_charms = "1,2,", last_caster_charms = "0,2"
			}}, SpellCastViewerPage.SpellFinishedCallback, nil, true, nil, playing_id, nil, quality);
		else
			-- single spell
			local caster, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, target_id)
			SpellPlayer.PlaySpellEffect_single(9991, caster, target, file, {{100}}, {{target_wards = "6,6,6,", last_target_wards = "0,0,6", target_charms = "1,2,", last_target_charms = "0,2", caster_wards = "6,6,6,", last_caster_wards = "0,0,6", caster_charms = "1,2,", last_caster_charms = "0,2"}}, SpellCastViewerPage.SpellFinishedCallback, nil, true, nil, playing_id, nil, quality);
		end
	else
		-- if the arena is not created, use the character and the selected object as the caster and the target
		local caster_char = ParaScene.GetPlayer();
		local target_char = System.obj.GetObject("selection");
		if(caster_char and caster_char:IsValid() == true and target_char and target_char:IsValid() == true) then
			--SpellCast.FaceEachOther(caster_char, target_char)
			SpellCast.EntitySpellCast(nil, caster_char, nil, target_char, nil, file);
		end
	end
end

function SpellCastViewerPage.StopSpellCasting()
	SpellCast.StopSpellCasting(playing_id);
end

function SpellCastViewerPage.SpellFinishedCallback(force_update)
	local NPC = MyCompany.Aries.Quest.NPC;
	NPL.load("(gl)script/apps/Aries/Combat/CombatCameraView.lua");
	local CombatCameraView = commonlib.gettable("MotionEx.CombatCameraView");
	local v = CombatCameraView.enabled;
	--local v = page:GetValue("checkbox_motion_enabled");
	NPL.load("(gl)script/apps/Aries/Combat/ObjectManager.lua");
	if(v or force_update)then
		local arena_char = NPC.GetNpcCharacterFromIDAndInstance(MyCompany.Aries.Combat.ObjectManager.GetArena_CameraView_NPC_ID(9991));
		if(arena_char) then
			arena_char:ToCharacter():SetFocus();
			local att = ParaCamera.GetAttributeObject();
			att:SetField("CameraObjectDistance", 22);
			att:SetField("CameraLiftupAngle", 0.453516068459);
			att:SetField("CameraRotY", 1.5619721412659);
		end
	end
end
function SpellCastViewerPage.ClickDBUpdate()
	_guihelper.MessageBox("确认更新数据库？\n\n请确认database/characters.db文件为只读，数据更新需要花些时间，请耐心等待\n", function ()
				Map3DSystem.UI.CCS.DB.AutoGenerateItems();
				_guihelper.CloseMessageBox();
			end);
end

function SpellCastViewerPage.ClickLeftHandUpdate(name, mcmlNode)
	if(mcmlNode) then
        local gsid = mcmlNode:GetNumber("gsid");
        if(gsid) then
			SpellCastViewerPage.HandUpdate(gsid, 0);
		end
	end
end

function SpellCastViewerPage.ClickRightHandUpdate(name, mcmlNode)
	if(mcmlNode) then
        local gsid = mcmlNode:GetNumber("gsid");
        if(gsid) then
			SpellCastViewerPage.HandUpdate(gsid, 1);
		end
	end
end

function SpellCastViewerPage.ClickHatUpdate(name, mcmlNode)
	if(mcmlNode) then
        local gsid = mcmlNode:GetNumber("gsid");
        if(gsid) then
			local playerChar = ParaScene.GetPlayer():ToCharacter();
			playerChar:SetCharacterSlot(0, 0);
		end
	end
end

function SpellCastViewerPage.ClickBackUpdate(name, mcmlNode)
	if(mcmlNode) then
        local gsid = mcmlNode:GetNumber("gsid");
        if(gsid) then
			local playerChar = ParaScene.GetPlayer():ToCharacter();
			playerChar:SetCharacterSlot(26, 0);
		end
	end
end

function SpellCastViewerPage.HandUpdate(gsid, hand)
	local playerChar = ParaScene.GetPlayer():ToCharacter();
	if(gsid and hand == 0) then
		playerChar:SetCharacterSlot(11, gsid);
	elseif(gsid and hand == 1) then
		playerChar:SetCharacterSlot(10, gsid);
	end
end

NPL.load("(gl)script/kids/3DMapSystemApp/API/paraworld.globalstore.lua");

function SpellCastViewerPage.DS_Func_Items(index)
	--ItemManager
	--local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(gsid);
	
	if(index ~= nil) then
		local gsid = 1000 + globalstoreitems_count - index + 1;
		local gsItem = globalstoreitems[gsid];
		if(not gsItem or index > globalstoreitems_count) then
			return;
		end
		return {img = gsItem.icon, tooltip = gsid.."\n"..gsItem.template.name, gsid = gsid};
	elseif(index == nil) then
		return globalstoreitems_count;
	end
end

function SpellCastViewerPage.TestItem(gsid)
	local scene = ParaScene.GetMiniSceneGraph("Taurus_SpellCastViewer");
	if(scene:IsValid()) then
		local obj = scene:GetObject("SpellCastViewerAvatar");
		if(obj:IsValid()) then
			local playerChar = obj:ToCharacter();
			local gsItem = globalstoreitems[gsid];
			if(gsItem) then
				local class = gsItem.template.class;
				local subclass = gsItem.template.subclass;
				if(class == 1) then
					if(subclass == 1) then
						playerChar:SetCharacterSlot(14, gsid);
					elseif(subclass == 2) then
						playerChar:SetCharacterSlot(0, gsid);
					elseif(subclass == 4) then
						local bForceCartoonFace = gsItem.template.stats[16];
						if(bForceCartoonFace == 1) then
							playerChar:SetCartoonFaceComponent(6, 0, gsid);
							playerChar:SetCharacterSlot(20, 0);
						else
							playerChar:SetCartoonFaceComponent(6, 0, 0);
							playerChar:SetCharacterSlot(20, gsid);
						end
						playerChar:SetCharacterSlot(20, gsid);
					elseif(subclass == 5) then
						playerChar:SetCharacterSlot(16, gsid);
					elseif(subclass == 6) then
						playerChar:SetCharacterSlot(17, gsid);
					elseif(subclass == 7) then
						playerChar:SetCharacterSlot(19, gsid);
					elseif(subclass == 8) then
						local bForceAttBack = gsItem.template.stats[13];
						if(bForceAttBack == 1) then
							playerChar:SetCharacterSlot(21, 0);
							playerChar:SetCharacterSlot(26, gsid);
						else
							playerChar:SetCharacterSlot(26, 0);
							playerChar:SetCharacterSlot(21, gsid);
						end
						playerChar:SetCharacterSlot(21, gsid);
					elseif(subclass == 9) then
						playerChar:SetCharacterSlot(18, gsid);
					elseif(subclass == 10) then
						playerChar:SetCharacterSlot(11, gsid);
					elseif(subclass == 11) then
						playerChar:SetCharacterSlot(10, gsid);
					end
				end
			end
		end
	end
end
function SpellCastViewerPage.PlayCameraMotion(sName)
	local caster_id = page:GetValue("caster_id");
    local target_id = page:GetValue("target_id");
    if(tonumber(caster_id)) then
        caster_id = tonumber(caster_id);
    end
    if(tonumber(target_id)) then
        target_id = tonumber(target_id);
    end
	
	NPL.load("(gl)script/apps/Aries/Combat/SpellCast.lua");
	local SpellCast = MyCompany.Aries.Combat.SpellCast;
	local NPC = MyCompany.Aries.Quest.NPC;
	local caster, target = SpellCastViewerPage.GetCasterAndTarget(caster_id, target_id)
	-- get caster and target character
	local caster_char = nil;
	local target_char = nil;
	if(caster.isPlayer == true) then
		---- first double check mount player on slot
		--ObjectManager.MountPlayerOnSlot(caster.nid, arena_id, caster.slot_id)
		-- player character
		caster_char = ParaScene.GetObject(tostring(caster.nid));
	else
		-- npc character
		caster_char = NPC.GetNpcCharacterFromIDAndInstance(caster.npc_id, caster.instance);
	end
	if(target.isPlayer == true) then
		---- first double check mount player on slot
		--ObjectManager.MountPlayerOnSlot(caster.nid, arena_id, caster.slot_id)
		-- player character
		target_char = ParaScene.GetObject(tostring(target.nid));
	else
		-- npc character
		target_char = NPC.GetNpcCharacterFromIDAndInstance(target.npc_id, target.instance);
	end

	if(not caster_char or not target_char)then return end
	

	NPL.load("(gl)script/apps/Aries/Combat/CombatCameraView.lua");
	local CombatCameraView = commonlib.gettable("MotionEx.CombatCameraView");
	local id = sName;
	local x,y,z = caster_char:GetPosition();
	local start_point_pos = { x, y, z };

	local x,y,z = target_char:GetPosition();
	local end_point_pos = { x, y, z };

	local x, y, z = ParaScene.GetPlayer():GetPosition();
	local ObjectManager = commonlib.getfield("MyCompany.Aries.Combat.ObjectManager");
	if(ObjectManager) then
		x, y, z = ObjectManager.GetArenaCenter(9991);
	end
	--force load all cameras motion file
	CombatCameraView.ForceLoadAllCameras();
	local ground_pos = { x, y, z };
    local motion = page:GetValue("checkbox_motion");
	local args = {
		start_point_pos = start_point_pos,
		end_point_pos = end_point_pos,
		ground_pos = ground_pos,
		nomotion = motion,--直接跳转到动画的结束点
	}
	CombatCameraView.PlayMotion(id,args,function()
		--_guihelper.MessageBox("over");
	end)
end
function SpellCastViewerPage.EnableMotion()
    local v = page:GetValue("checkbox_motion_enabled");
	CombatCameraView.enabled = v;
end