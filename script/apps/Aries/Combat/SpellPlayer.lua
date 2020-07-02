--[[
Title: combat system battle spell player for Aries App
Author(s): WangTian
Date: 2009/4/7
Area: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Combat/SpellPlayer.lua");
------------------------------------------------------------
]]

NPL.load("(gl)script/apps/Aries/Scene/EffectManager.lua");
NPL.load("(gl)script/apps/Aries/Combat/SpellCast.lua");
NPL.load("(gl)script/apps/Aries/Combat/BattleComment.lua");


local SpellCast = commonlib.gettable("MyCompany.Aries.Combat.SpellCast");
local NPC = commonlib.gettable("MyCompany.Aries.Quest.NPC");
local BattleComment = commonlib.gettable("MyCompany.Aries.Combat.BattleComment");
local ObjectManager = commonlib.gettable("MyCompany.Aries.Combat.ObjectManager");
local EffectManager = commonlib.gettable("MyCompany.Aries.EffectManager");
local UIAnimManager = commonlib.gettable("UIAnimManager");
local tostring = tostring;
local tonumber = tonumber;


-- create class
local SpellPlayer = commonlib.gettable("MyCompany.Aries.Combat.SpellPlayer");


local base_arena_id_offset = 10000;
local slot_id_mount_id_offset = 19;

-- the facing offset of the player to arena slot, otherwise the player will face the side of the arena center
local facing_offset_player_to_arenaslot = - math.pi / 2;

local target_flashing_effect = "character/v5/09effect/Combat_Common/TargetPicker/CasterCircle/CasterCircle.x"

local speak_audio_word_mapping = {
};

local bInited = false;

function SpellPlayer.Init()
	if(bInited) then
		return;
	end

	if(System.options.version == "kids") then
		speak_audio_word_mapping = {
			["哎哟，不错嘛，有两下子！"] = "Audio/Haqi/CombatTutorial/Speak_rat1.ogg",
			["哎呦，好疼啊，该我了！"] = "Audio/Haqi/CombatTutorial/Speak_rat2.ogg",
			["该死，居然发招失败！大哥，快来帮我！"] = "Audio/Haqi/CombatTutorial/Speak_rat3.ogg",
			["我的老弟啊，我要为你报仇！"] = "Audio/Haqi/CombatTutorial/Speak_rat4.ogg",
			["哼！别得意，暗黑魔王会为我们报仇的！"] = "Audio/Haqi/CombatTutorial/Speak_rat5.ogg",
	
			-- DoomLord
			["让你们尝尝我的厉害!"] = "Audio/Haqi/DoomLord/DoomLord_word1.ogg",
			["你们居然敢激怒我?!"] = "Audio/Haqi/DoomLord/DoomLord_word2.ogg",
			["男爵让我为你治疗!"] = "Audio/Haqi/DoomLord/FrostScylla_word1.ogg",
			["让你们见识下我的威力!"] = "Audio/Haqi/DoomLord/FrostScylla_word2.ogg",
			["群伤是无济于事的!"] = "Audio/Haqi/DoomLord/FireBeatle_word1.ogg",
			["让我来解决你们!"] = "Audio/Haqi/DoomLord/FireBeatle_word2.ogg",
			["大家保护男爵!"] = "Audio/Haqi/DoomLord/FireBeatle_word3.ogg",
			["大家快给男爵治疗!"] = "Audio/Haqi/DoomLord/EvilElvin_word1.ogg",
			["我不能死!我要反击!"] = "Audio/Haqi/DoomLord/EvilElvin_word2.ogg",
	
			-- FireCavern
			["让你尝尝我的厉害!"] = "Audio/Haqi/FireCavern/FireRockyOgre_word.ogg",
		};
	elseif(System.options.version == "teen") then
		if(System.options.locale == "zhCN" or System.options.locale == "zhTW") then
			-- read word audio mapping from config
			local config_file;
			if(System.options.locale == "zhCN") then
				config_file = "config/Aries/Audio/SpeakWordAudioMapping.zhCN.xml";
			elseif(System.options.locale == "zhTW") then
				config_file = "config/Aries/Audio/SpeakWordAudioMapping.zhTW.xml";
			end
			local xmlRoot = ParaXML.LuaXML_ParseFile(config_file);
			if(xmlRoot) then
				local each_modifier;
				for each_modifier in commonlib.XPath.eachNode(xmlRoot, "/audiowords/audio") do
					local word = each_modifier.attr.word;
					local sound_asset = each_modifier.attr.sound_asset;
					if(word and sound_asset) then
						speak_audio_word_mapping[word] = sound_asset;
					end
				end
			end
		end
	end
	bInited = true;
end

-- play effect on the arena slot characters
-- @param arena_id: arena id
-- @param caster: {params}
-- @param target: {params}
-- @param spell_config_file: spell config file
-- @param comment_config_file: battle comment config file
-- @param comment_params: battle comment config param {param, param}
-- @paras update_buffs: update buffs
-- @param finish_callback: callback function that invoked after spell playing
-- @param bSkipCamera: true for skip camera
-- @param update_hp_callback: callback function that invoked when hp is updated in comment, update_hp_callback(obj_name, delta_hp)
-- @param card_gs_item: global store item. maybe nil. card_gs_item.template.stats[99] is card type, etc. 
-- NOTE: params:
--			isPlayer: true for player, false for npc
--			if player: nid, slot_id or {nid, slot_id}
--			if npc: npc_id, instance and slot_id or {npc_id, instance, slot_id}
function SpellPlayer.PlaySpellEffect_single(arena_id, caster, target, spell_config_file, comment_params, update_buffs, finish_callback, bSkipCamera, bIncludedInBattle, update_hp_callback, playing_id, card_gs_item, card_quality, bSkipAutoTargetEffect)
	if(not arena_id or not caster or not target or not spell_config_file) then
		log("error: nil param in SpellPlayer.PlaySpellEffect_single function call \n")
		return;
	end
	
	local bAbove3D = bIncludedInBattle;

	local SpellCast = SpellCast;
	local NPC = NPC;
	
	-- get caster and target character
	local caster_char = nil;
	local target_char = nil;
	if(caster.isPlayer == true) then
		---- first double check mount player on slot
		--ObjectManager.MountPlayerOnSlot(caster.nid, arena_id, caster.slot_id)
		-- player character
		if(caster.bFromPetCard) then
			--caster_char = ParaScene.GetObject(tostring(caster.nid).."+followpet");
		end
		if(not caster_char or not caster_char:IsValid()) then
			if(type(caster.nid) == "number") then
				if(caster.nid and caster.nid < 0) then
					caster_char = ParaScene.GetObject(-caster.nid.."+followpet");
				else
					caster_char = ParaScene.GetObject(tostring(caster.nid));
				end
			elseif(caster.nid == "localuser") then
				local entity = GameLogic.EntityManager.GetPlayer()
				caster_char = entity and entity:GetInnerObject()
			end
		end
	else
		-- npc character
		caster_char = NPC.GetNpcCharacterFromIDAndInstance(caster.npc_id, caster.instance);
	end
	if(target.isPlayer == true) then
		---- first double check mount player on slot
		--ObjectManager.MountPlayerOnSlot(caster.nid, arena_id, caster.slot_id)
		-- player character
		if(type(target.nid) == "number") then
			if(target.nid and target.nid < 0) then
				target_char = ParaScene.GetObject(-target.nid.."+followpet");
			else
				target_char = ParaScene.GetObject(tostring(target.nid));
			end
		elseif(target.nid == "localuser") then
			local entity = GameLogic.EntityManager.GetPlayer()
			target_char = entity and entity:GetInnerObject()
		end
	else
		-- npc character
		target_char = NPC.GetNpcCharacterFromIDAndInstance(target.npc_id, target.instance);
	end
	
	-- NOTE 2010/7/29: battle comment file is deparacated, the comment params will be in spell config file
	---- play battle comment file
	--if(comment_config_file) then
		--BattleComment.PlayCommentOnCaster(caster_char, comment_config_file, 0, bAbove3D);
	--end
	--if(comment_config_file and target_comment_params) then
		--BattleComment.PlayCommentOnTarget(target_char, comment_config_file, target_comment_params, bAbove3D, update_hp_callback);
	--end
	--if(comment_config_file and caster_comment_params) then
		--BattleComment.PlayCommentOnTarget(caster_char, comment_config_file, caster_comment_params, bAbove3D, update_hp_callback);
	--end

	if(spell_config_file == "config/Aries/Spells/Speak.xml" and caster_char and caster_char:IsValid() == true) then
		-- comment_params = headon_speech.GetBoldTextMCML(comment_params)

		local locale = System.options.locale;
		if(locale == "zhCN" or locale == "zhTW") then
			-- play mob sound for zhCN and zhTW
			if(type(comment_params) == "string") then
				local MsgHandler = commonlib.gettable("MyCompany.Aries.Combat.MsgHandler");
				if(MsgHandler.Get_arena_data_by_id) then
					local arena_data = MsgHandler.Get_arena_data_by_id(arena_id);
					if(arena_data) then
						if(arena_data.bIncludedMyselfInArena) then
							local assetfile = speak_audio_word_mapping[comment_params];
							if(assetfile) then
								local audio_src = AudioEngine.CreateGet(assetfile)
								audio_src.file = assetfile;
								audio_src:play(); -- then play with default. 
							end
						end
					end
				end
			end
		end

		if(type(comment_params) == "string") then
			comment_params = "<span style='color:#093f4f'>"..comment_params.."</span>";
		end
		headon_speech.Speek(caster_char.name, comment_params, 6, true, nil, true, nil, "#ffffffc0", 40);
		return;
	end

	if(spell_config_file == "config/Aries/Spells/Shout.xml") then
		-- create effect function 
		local func_play_effect = function()
			local title = tostring(comment_params);
			local color = "fe3803";  -- another green color 79b702 for positive spell names
			if(card_gs_item) then
				local card_type = card_gs_item.template.stats[99];
				if(card_type == 1) then
					-- for gold border card. 
					color = "e6b322";
				end
			end
			if(System.options.version == "teen") then
				-- 221 apparel_quality(CG) 装备的品质 -1未知 0白 1绿 2蓝 3紫 4橙 
				color = "ffffff";
				if(card_gs_item) then
					local quality = card_gs_item.template.stats[221];
					if(quality == 1) then
						color = "#00cc33";
					elseif(quality == 2) then
						color = "#0099ff";
					elseif(quality == 3) then
						color = "#c648e1";
					elseif(quality == 4) then
						color = "#ff9a00";
					end
				end
			end

			local mcml_str = "";
			if(System.options.locale == "zhCN" or System.options.locale == "zhTW") then
				-- Chinese character with text sprite
				mcml_str = string.format([[<aries:textsprite spritestyle="SpellName" color="#%s" text="%s" default_fontsize="18" fontsize="24"/>]], color, title);
			else
				-- other locales with text font
				--title = title..title;
				mcml_str = string.format([[<div ><input type="button" style="margin-left:0px;background:;width:400px;height:32;color:#%s;text-align:center;font-size:24pt;font-weight:bold;text-shadow:true" value="%s"/></div>]], color, title)
			end
			local sCtrlName = headon_speech.Speek(caster_char.name, mcml_str, 2, bAbove3D, true, true, -2, nil, -16);
			if(sCtrlName) then
				UIAnimManager.PlayCustomAnimation(3000, function(elapsedTime)
					local parent = ParaUI.GetUIObject(sCtrlName);
					if(parent:IsValid()) then
						--if(elapsedTime < 1000) then
							--parent.translationy = 14 - (1000 * 1000 / 2000) * 20 / 1000;
						--else
							--parent.translationy = 14 - (elapsedTime * elapsedTime / 2000) * 20 / 1000;
						--end
						--parent.scalingx = 1.5;
						--parent.scalingy = 1.5;

						
						--parent.translationy = 13;
											
						if(elapsedTime < 100) then
							local scaling = 1.3 + 0.4 * elapsedTime / 100;
							parent.scalingx = scaling;
							parent.scalingy = scaling;
						elseif(elapsedTime < 300) then
							local scaling = 1.7 - 0.2 * (elapsedTime - 100) / 200;
							parent.scalingx = scaling;
							parent.scalingy = scaling;
						else
							parent.scalingx = 1.5;
							parent.scalingy = 1.5;
						end

						parent:ApplyAnim();
					end
				end);
			end

		end
		-- play the effect immediately or after start time
		UIAnimManager.PlayCustomAnimation(1000, function(elapsedTime)
			if(elapsedTime == 1000) then
				func_play_effect();
			end
		end);
		return;
	end

	local x, y, z;
	if(ObjectManager.GetArenaCenter) then
		x, y, z = ObjectManager.GetArenaCenter(arena_id);
	else
		x, y, z = ParaScene.GetPlayer():GetPosition();
	end
	
	-- if both caster and target are valid play the effect file
	if(caster_char and caster_char:IsValid() == true and target_char and target_char:IsValid() == true) then
		local bForceSound;
		if(bIncludedInBattle) then
			bForceSound = true;
		end
		SpellCast.EntitySpellCast(arena_id, caster_char, caster.slotid, target_char, target.slotid, spell_config_file, x, y, z, comment_params, update_buffs, finish_callback, update_hp_callback, bSkipCamera, playing_id, bForceSound);
		if(card_quality) then
			local spell_name = string.match(spell_config_file, "([^/^.]+).xml$");
			if(spell_name) then
				local school = string.match(spell_name, "^([^_]+)_");
				if(school) then
					local spell_duration = SpellCast.GetSpellDuration(spell_config_file);
					local quality_spell_file = "config/Aries/Spells/Quality_"..school.."_"..card_quality..".xml";
					SpellCast.EntitySpellCast(arena_id, caster_char, caster.slotid, target_char, target.slotid, quality_spell_file, x, y, z, comment_params, update_buffs, function() end, function() end, true, playing_id, nil, spell_duration);
				end
			end
		end
		if(not bSkipAutoTargetEffect) then
			-- auto play flashing effect
			SpellPlayer.PlayTargetEffect(target_char)
		end
	else
		if(finish_callback) then
			--_guihelper.MessageBox("get log r2\n")
			finish_callback();
		end
	end
end

-- play effect on the arena slot characters
-- @param arena_id: arena id
-- @param caster: {params}
-- @param targets: {{params}, {params}}
-- @param spell_config_file: spell config file
-- @param comment_config_file: battle comment config file
-- @param comment_params: {params, params}
-- @paras update_buffs: update buffs
-- @param finish_callback: callback function that invoked after spell playing
-- @param bSkipCamera: true for skip camera
-- @param update_hp_callback: callback function that invoked when hp is updated in comment, update_hp_callback(obj_name, delta_hp)
-- NOTE: params:
--			isPlayer: true for player, false for npc
--			if player: nid, slot_id or {nid, slot_id}
--			if npc: npc_id, instance and slot_id or {npc_id, instance, slot_id}
function SpellPlayer.PlaySpellEffect_multiple(arena_id, caster, targets, spell_config_file, comment_params, update_buffs, finish_callback, bSkipCamera, bIncludedInBattle, update_hp_callback, playing_id, card_gs_item, card_quality)
	
	if(not arena_id or not caster or not targets or not spell_config_file) then
		log("error: nil param in SpellPlayer.PlaySpellEffect_multiple function call \n")
		return;
	end
	
	local bAbove3D = bIncludedInBattle;
	
	local SpellCast = SpellCast;
	local NPC = NPC;
	
	-- get caster and target character
	local caster_char = nil;
	local target_char = nil;
	if(caster.isPlayer == true) then
		---- first double check mount player on slot
		--ObjectManager.MountPlayerOnSlot(caster.nid, arena_id, caster.slot_id)
		-- player character
		if(caster.bFromPetCard) then
			--caster_char = ParaScene.GetObject(tostring(caster.nid).."+followpet");
		end
		if(not caster_char or not caster_char:IsValid()) then
			if(type(caster.nid) == "number") then
				if(caster.nid and caster.nid < 0) then
					caster_char = ParaScene.GetObject(-caster.nid.."+followpet");
				else
					caster_char = ParaScene.GetObject(tostring(caster.nid));
				end
			elseif(caster.nid == "localuser") then
				local entity = GameLogic.EntityManager.GetPlayer()
				caster_char = entity and entity:GetInnerObject()
			end
		end
	else
		-- npc character
		caster_char = NPC.GetNpcCharacterFromIDAndInstance(caster.npc_id, caster.instance);
	end
	
	local target_count = #targets;
	if(type(comment_params) == "table") then
		local _, params;
		for _, params in pairs(comment_params) do
			if(target_count ~= #params) then
				log("error: targets and comment_params count not equal in SpellPlayer.PlaySpellEffect_multiple function call \n")
				return;
			end
		end
	else
		log("error: comment_params is not table in SpellPlayer.PlaySpellEffect_multiple function call \n")
		return;
	end


	-- for each target play battle comment 
	local target;
	local comment_param;
	local target_chars = {};
	local target_slotids = {};
	local i;
	for i = 1, target_count do
		target = targets[i];
		comment_param = comment_params[i];
		
		if(target.isPlayer == true) then
			---- first double check mount player on slot
			--ObjectManager.MountPlayerOnSlot(caster.nid, arena_id, caster.slot_id)
			-- player character
			if(type(target.nid) == "number") then
				if(target.nid and target.nid < 0) then
					target_char = ParaScene.GetObject(-target.nid.."+followpet");
				else
					target_char = ParaScene.GetObject(tostring(target.nid));
				end
			elseif(target.nid == "localuser") then
				local entity = GameLogic.EntityManager.GetPlayer()
				target_char = entity and entity:GetInnerObject()
			end
		else
			-- npc character
			target_char = NPC.GetNpcCharacterFromIDAndInstance(target.npc_id, target.instance);
		end

		-- record each target character entity
		if(target_char and target_char:IsValid() == true) then
			table.insert(target_chars, target_char);
			table.insert(target_slotids, target.slotid);
			-- auto play flashing effect
			SpellPlayer.PlayTargetEffect(target_char);
		end
		
		-- NOTE 2010/7/29: battle comment file is deparacated, the comment params will be in spell config file
		---- play battle comment file
		--if(tonumber(comment_param)) then
			--comment_param = tonumber(comment_param);
		--end
		--if(comment_config_file and comment_param) then
			--BattleComment.PlayCommentOnCaster(caster_char, comment_config_file, 0, bAbove3D);
			--BattleComment.PlayCommentOnTarget(target_char, comment_config_file, comment_param, bAbove3D, update_hp_callback);
		--end
	end
	
	local x, y, z = ParaScene.GetPlayer():GetPosition();

	if(ObjectManager.GetArenaCenter) then
		x, y, z = ObjectManager.GetArenaCenter(arena_id);
	end

	-- if both caster and target are valid play the effect file
	if(caster_char and caster_char:IsValid() == true and target_char and target_char:IsValid() == true) then
		local bForceSound;
		if(bIncludedInBattle) then
			bForceSound = true;
		end
		SpellCast.EntitySpellCast(arena_id, caster_char, caster.slotid, target_chars, target_slotids, spell_config_file, x, y, z, comment_params, update_buffs, finish_callback, update_hp_callback, bSkipCamera, playing_id, bForceSound);
		if(card_quality) then
			local spell_name = string.match(spell_config_file, "([^/^.]+).xml$");
			if(spell_name) then
				local school = string.match(spell_name, "^([^_]+)_");
				if(school) then
					local spell_duration = SpellCast.GetSpellDuration(spell_config_file);
					local quality_spell_file = "config/Aries/Spells/Quality_"..school.."_"..card_quality..".xml";
					SpellCast.EntitySpellCast(arena_id, caster_char, caster.slotid, target_chars, target_slotids, quality_spell_file, x, y, z, comment_params, update_buffs, function() end, function() end, true, playing_id, nil, spell_duration);
				end
			end
		end
	else
		if(finish_callback) then
			--_guihelper.MessageBox("get log r3\n")
			finish_callback();
		end
	end
end

function SpellPlayer.PlaySpellDuration(spell_config_file, callback_func)
	if(not spell_config_file or not callback_func) then
		return;
	end
	SpellCast.PlaySpellDuration(spell_config_file, callback_func);
end

-- play target flashing effect on target
function SpellPlayer.PlayTargetEffect(target_char)
	if(target_char and target_char:IsValid() == true) then
		local params = {
			asset_file = target_flashing_effect,
			binding_obj_name = target_char.name,
			scale = 1,
			offset_y = -0.2,
			facing = 0,
			duration_time = 1500,
			begin_callback = function()
			end,
			end_callback = function()
			end,
		};
		EffectManager.CreateEffect(params);
	end
end