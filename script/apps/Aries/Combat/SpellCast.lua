--[[
Title: combat system spell cast for Aries App
Author(s): WangTian
Date: 2009/4/7
Area: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Combat/SpellCast.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Scene/EffectManager.lua");
NPL.load("(gl)script/apps/Aries/Combat/CombatCameraView.lua");

NPL.load("(gl)script/ide/AssetPreloader.lua");

local CombatCameraView = commonlib.gettable("MotionEx.CombatCameraView");
local CCS = commonlib.gettable("Map3DSystem.UI.CCS");
local UIAnimManager = commonlib.gettable("UIAnimManager");
local EffectManager = commonlib.gettable("MyCompany.Aries.EffectManager");
local ObjectManager = commonlib.gettable("MyCompany.Aries.Combat.ObjectManager");
local Animation = commonlib.gettable("System.Animation");
local AudioEngine = commonlib.gettable("AudioEngine");

local tostring = tostring;
local tonumber = tonumber;
local math_cos = math.cos;
local math_sin = math.sin;
local type = type;
local table_insert = table.insert;

NPL.load("(gl)script/ide/Effect/frozenEffect.lua");
local FrozenEffect = commonlib.gettable("MyCompany.Aries.FrozenEffect");
NPL.load("(gl)script/ide/Effect/stoneEffect.lua");
local StoneEffect = commonlib.gettable("MyCompany.Aries.StoneEffect");
NPL.load("(gl)script/ide/Effect/transparentEffect.lua");
local TransparentEffect = commonlib.gettable("MyCompany.Aries.TransparentEffect");

-- create class
local SpellCast = commonlib.gettable("MyCompany.Aries.Combat.SpellCast");

-- SpellCast.FaceEachOther
function SpellCast.FaceEachOther(caster_char, target_char)
	if(not caster_char or not target_char) then
		-- nil caster or nil target
		return;
	end
	if(caster_char:IsValid() ~= true or target_char:IsValid() ~= true) then
		-- invalid caster or invalid target
		return;
	end
	-- face to each other
	local c_x, c_y, c_z = caster_char:GetPosition();
	local t_x, t_y, t_z = target_char:GetPosition();
	CCS.CharacterFaceTarget(caster_char, t_x, t_y, t_z);
	CCS.CharacterFaceTarget(target_char, c_x, c_y, c_z);
end

local sound_replacements = nil;

-- SpellCast.CreateGetSoundReplacements
function SpellCast.CreateGetSoundReplacements()
	if(sound_replacements) then
		return sound_replacements;
	end

	sound_replacements = {};
	
	local xmlRoot = ParaXML.LuaXML_ParseFile("config/Aries/Audio/SpellSoundReplacement.xml");
	if(xmlRoot) then
		local node_title;
		for node_title in commonlib.XPath.eachNode(xmlRoot, "/replacements/asset_title") do
			if(node_title.attr and node_title.attr.title) then
				local per_title = {};
				local replacement_title;
				for replacement_title in commonlib.XPath.eachNode(node_title, "/replacement") do
					if(replacement_title.attr and replacement_title.attr.target_asset and replacement_title.attr.sound_asset) then
						per_title[replacement_title.attr.target_asset] = replacement_title.attr.sound_asset;
					end
				end

				sound_replacements[node_title.attr.title] = per_title;
			end
		end
	end
end

-- buff string to table
-- @param str: buff string
-- NOTE: e.x. input "1,2,3,4" --> output {1,2,3,4}
--			  input "fire,water," --> output {"fire","water"}
function SpellCast.BuffStringToTable(str)
	local t = {};
	local unit;
	for unit in string.gmatch(str, "[^,]+") do
		if(tonumber(unit)) then
			table.insert(t, tonumber(unit));
		else
			table.insert(t, unit);
		end
	end
	return t;
end

-- cache the xml root in memory to improve frequent spell play IO latency
local SpellCast_File_XMLRoots = {};

-- cancel spell play if caster is far away from the player
local cancel_spellplay_distance_sq = 2500;

-- default spell duration
local default_spell_duration = 5000;

-- only play spell duration, esp for not sentient arenas and pending for next spell play after duration
function SpellCast.GetSpellDuration(spell_config_file)
	-- spell cast config 
	local filename = spell_config_file;
	local xmlRoot = SpellCast_File_XMLRoots[filename];
	-- for taurus force read the spell file
	if(not xmlRoot or System.SystemInfo.GetField("name") == "Taurus") then
		xmlRoot = ParaXML.LuaXML_ParseFile(filename);
		if(not xmlRoot) then
			commonlib.log("error: failed loading spell config file: %s\n", filename);
			return;
		end
		SpellCast_File_XMLRoots[filename] = xmlRoot;
	end
	-- spell duration
	local spell_duration = default_spell_duration;
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/spell") do
		if(node.attr and node.attr.duration) then
			spell_duration = tonumber(node.attr.duration);
		end
	end
	return spell_duration;
end

-- only play spell duration, esp for not sentient arenas and pending for next spell play after duration
function SpellCast.PlaySpellDuration(spell_config_file, finish_callback, framemove_callback)
	-- spell cast config 
	local filename = spell_config_file;
	local xmlRoot = SpellCast_File_XMLRoots[filename];
	-- for taurus force read the spell file
	if(not xmlRoot or System.SystemInfo.GetField("name") == "Taurus") then
		xmlRoot = ParaXML.LuaXML_ParseFile(filename);
		if(not xmlRoot) then
			commonlib.log("error: failed loading spell config file: %s\n", filename);
			return;
		end
		SpellCast_File_XMLRoots[filename] = xmlRoot;
	end
	-- spell duration
	local spell_duration = default_spell_duration;
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/spell") do
		if(node.attr and node.attr.duration) then
			spell_duration = tonumber(node.attr.duration);
		end
	end
	UIAnimManager.PlayCustomAnimation(spell_duration, function(elapsedTime)
		if(framemove_callback) then
			framemove_callback(elapsedTime);
		end
		if(elapsedTime == spell_duration) then
			if(finish_callback) then
				finish_callback();
			end
		end
	end);
end

-- record all playing id set
local playing_id_set = {};

-- get effect node duration
-- duration_from_end is an attribute that specify the duration with the spell end
local function GetEffectNodeDuration(node, spell_duration, default_value)
	if(not spell_duration) then
		log("error: spell_duration missing in GetEffectNodeDuration call\n");
		return;
	end
	if(node.attr and node.attr.duration_from_end) then
		local spell_duration_from_end = tonumber(node.attr.duration_from_end);
		if(spell_duration_from_end) then
			local starttime = 0;
			if(node.attr and node.attr.starttime) then
				starttime = tonumber(node.attr.starttime) or 0;
			end
			return spell_duration + spell_duration_from_end - starttime;
		end
	end
	if(node.attr and node.attr.duration) then
		local duration = tonumber(node.attr.duration);
		if(duration) then
			return duration;
		end
	end
	return default_value or 1000;
end


-- mount pet asset name to mount animation file name. 
local default_mount_anim_map_replace_with_sex = {
	["character/v6/02animals/huoyanzhiyi/huoyanzhiyi.x"] = {
		["male"] = {
			[71] = "character/Animation/v6/TeenElfMale_chibang_attack.x",
			[73] = "character/Animation/v6/TeenElfMale_chibang_damaged.x",
		},
		["female"] = {
			[71] = "character/Animation/v6/TeenElfFemale_chibang_attack.x",
			[73] = "character/Animation/v6/TeenElfFemale_chibang_damaged.x",
		},
	},
	["character/v6/02animals/TianShiZhiYi/TianShiZhiYi.x"] = {
		["male"] = {
			[71] = "character/Animation/v6/TeenElfMale_chibang_attack.x",
			[73] = "character/Animation/v6/TeenElfMale_chibang_damaged.x",
		},
		["female"] = {
			[71] = "character/Animation/v6/TeenElfFemale_chibang_attack.x",
			[73] = "character/Animation/v6/TeenElfFemale_chibang_damaged.x",
		},
	},
};

-- mount pet asset name to mount animation file name. 
local default_mount_anim_map_teen_with_sex = {
	["character/v6/02animals/huoyanzhiyi/huoyanzhiyi.x"] = {
		["male"] = "character/Animation/v6/TeenElfMale_chibang.x",
		["female"] = "character/Animation/v6/TeenElfFemale_chibang.x",
	},
	["character/v6/02animals/TianShiZhiYi/TianShiZhiYi.x"] = {
		["male"] = "character/Animation/v6/TeenElfMale_chibang.x",
		["female"] = "character/Animation/v6/TeenElfFemale_chibang.x",
	},
	["character/v6/02animals/XueDiChe/XueDiChe.x"] = {
		["male"] = "character/Animation/v6/TeenElfMale_Car.x",
		["female"] = "character/Animation/v6/TeenElfMale_Car.x",
	},
};

-- SpellCast.EntitySpellCast()
-- @param bSkipCamera: true for skip camera and sound effect(for those observer players)
-- NOTE: if the obj is too far away from the player, spell play is cancelled, finish_callback function is called after the duration
function SpellCast.EntitySpellCast(arena_id, caster_char, caster_slotid, target_char_or_chars, target_slotid_or_slotids, spell_config_file, center_x, center_y, center_z, comment_params, update_buffs, finish_callback, update_hp_callback, bSkipCamera, playing_id, bForceSound, force_spell_duration)
	local target_chars = {};
	if(type(target_char_or_chars) == "table") then
		target_chars = target_char_or_chars;
	else
		table_insert(target_chars, target_char_or_chars);
	end
	local target_slotids = {};
	if(type(target_slotid_or_slotids) == "table") then
		target_slotids = target_slotid_or_slotids;
	else
		table_insert(target_slotids, target_slotid_or_slotids);
	end
	if(not caster_char or not target_char_or_chars) then
		-- nil caster or nil target
		return;
	end
	if(caster_char:IsValid() ~= true) then
		-- invalid caster
		return;
	end
	for _, t_char in pairs(target_chars) do
		if(t_char:IsValid() ~= true) then
			-- invalid target
			return;
		end
	end
	-- spell cast config 
	local filename = spell_config_file;
	-- LOG.std(nil, "debug", "SpellCast.EntitySpellCast", filename);

	local xmlRoot = SpellCast_File_XMLRoots[filename];
	-- for taurus force read the spell file
	if(not xmlRoot or System.SystemInfo.GetField("name") == "Taurus") then
		xmlRoot = ParaXML.LuaXML_ParseFile(filename);
		if(not xmlRoot) then
			commonlib.log("error: failed loading spell config file: %s\n", filename);
			return;
		end
		SpellCast_File_XMLRoots[filename] = xmlRoot;
	end
	-- spell duration
	local spell_duration = default_spell_duration;
	if(force_spell_duration) then
		spell_duration = force_spell_duration;
	else
		local node;
		for node in commonlib.XPath.eachNode(xmlRoot, "/spell") do
			if(node.attr and node.attr.duration) then
				spell_duration = tonumber(node.attr.duration);
			end
		end
	end
	UIAnimManager.PlayCustomAnimation(spell_duration, function(elapsedTime)
		if(elapsedTime == spell_duration) then
			if(finish_callback) then
				if(not bSkipCamera) then
					CombatCameraView.StopCurMotion();
				end
				finish_callback();
			end
		end
	end);
	
	local current_worlddir = ParaWorld.GetWorldDirectory();
	if(not string.find(string.lower(current_worlddir), "instance")) then
		local dist = caster_char:DistanceToPlayerSq();
		if(dist > cancel_spellplay_distance_sq) then
			-- if user in too far away from the combat the spell play is cancelled
			return;
		end
	end

	if(not playing_id) then
		playing_id = ParaGlobal.GenerateUniqueID();
	end
	
	-- public world
	local asset_preloader;
	--if(not System.options.IsMobilePlatform) then
		asset_preloader = commonlib.AssetPreloader:new({
			callbackFunc = function(nItemsLeft, loader)
				log(nItemsLeft.." assets remaining\n")
			end
		});
	--end

	playing_id_set[playing_id] = true;
	
	-- create effect part of the spell
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/spell/effect") do
		if(node.attr and node.attr.type and node.attr.asset) then
			local type = node.attr.type;
			local asset = node.attr.asset;
			local starttime = tonumber(node.attr.starttime or 0);
			local duration = GetEffectNodeDuration(node, spell_duration);
			local scale = tonumber(node.attr.scale or 1);
			local scale_from = tonumber(node.attr.scale_from or scale);
			local scale_to = tonumber(node.attr.scale_to or scale);
			local facing = tonumber(node.attr.facing or 0);
			local offset_y = tonumber(node.attr.offset_y or 0);
			local offset_radius = tonumber(node.attr.offset_radius or 0);
			local offset_angle = tonumber(node.attr.offset_angle or 0);

			-- preload asset
			if(asset_preloader) then
				asset_preloader:AddAssets(ParaAsset.LoadParaX("", asset));
			end
			
			-- bind the effect to caster or target
			local binding_objs = {};
			if(type == "caster_aura") then
				table_insert(binding_objs, caster_char);
			elseif(type == "target_aura") then
				binding_objs = target_chars;
			end
			
			-- opacity timeline
			local opacity_timeline = {};
			local opacity_node;
			for opacity_node in commonlib.XPath.eachNode(node, "/opacity") do
				if(opacity_node.attr and opacity_node.attr.fromtime and opacity_node.attr.duration and opacity_node.attr.from and opacity_node.attr.to) then
					local fromtime = tonumber(opacity_node.attr.fromtime or 0);
					local duration = tonumber(opacity_node.attr.duration or 0);
					local from = tonumber(opacity_node.attr.from or 0);
					local to = tonumber(opacity_node.attr.to or 0);
					if(fromtime and duration and from and to) then
						table.insert(opacity_timeline, {
							fromtime = fromtime,
							duration = duration,
							from = from,
							to = to,
						});
					end
				end
			end

			-- traverse through all binding objects
			local _, bind_obj;
			for _, bind_obj in pairs(binding_objs) do
				-- create effect function 
				local func_play_effect = function()
					if(not playing_id_set[playing_id]) then
						return;
					end
					local params = {
						asset_file = asset,
						binding_obj_name = bind_obj.name,
						offset_y = offset_y,
						offset_radius = offset_radius,
						offset_angle = offset_angle,
						scale = scale_from,
						facing = bind_obj:GetFacing() + facing,
						duration_time = duration,
						speed = tonumber(node.attr.speedscale or 1),
						begin_callback = function()
						end,
						end_callback = function()
						end,
					};
					if(scale_from ~= scale_to or #opacity_timeline ~= 0) then
						params.elapsedtime_callback = function(elapsedTime, obj)
							local ratio = elapsedTime / duration;
							local scale = scale_from + (scale_to - scale_from) * ratio;
							if(obj and obj:IsValid() == true) then
								obj:SetScale(scale);
								-- set opacity
								local _, opacity_block;
								for _, opacity_block in ipairs(opacity_timeline) do
									local fromtime = opacity_block.fromtime;
									local duration = opacity_block.duration;
									local from = opacity_block.from;
									local to = opacity_block.to;
									if(fromtime and duration and from and to) then
										if(elapsedTime > fromtime and (elapsedTime <= (fromtime + duration))) then
											local current_opacity = (to - from) * (elapsedTime - fromtime) / duration + from;
											local params = obj:GetEffectParamBlock();
											params:SetFloat("g_opacity", current_opacity);
										end
									end
								end
							end
							if(not playing_id_set[playing_id]) then
								EffectManager.DestroyEffectObjIfValid(obj);
							end
						end;
					else
						params.elapsedtime_callback = function(elapsedTime, obj)
							if(not playing_id_set[playing_id]) then
								EffectManager.DestroyEffectObjIfValid(obj);
							end
						end;
					end
					EffectManager.CreateEffect(params);
				end
				-- play the effect immediately or after start time
				if(starttime >= 50) then
					UIAnimManager.PlayCustomAnimation(starttime, function(elapsedTime)
						if(elapsedTime == starttime) then
							func_play_effect();
						end
					end);
				else
					func_play_effect();
				end
			end
		end
	end
	
	-- create actor part of the spell
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/spell/actor") do
		if(node.attr and node.attr.style and node.attr.asset) then
			local style = node.attr.style;
			local asset = node.attr.asset;
			local starttime = tonumber(node.attr.starttime or 0);
			local duration = GetEffectNodeDuration(node, spell_duration);
			local scale = tonumber(node.attr.scale or 1);
			local scale_from = tonumber(node.attr.scale_from or scale);
			local scale_to = tonumber(node.attr.scale_to or scale);
			local facing = tonumber(node.attr.facing or 0);
			local offset_y = tonumber(node.attr.offset_y or 0);
			local offset_radius = tonumber(node.attr.offset_radius or 0);
			local offset_angle = tonumber(node.attr.offset_angle or 0);
			local real_facing;

			if(node.attr.real_facing) then
				real_facing = tonumber(node.attr.real_facing);
			end
			
			-- preload asset
			if(asset_preloader) then
				if(style == "center_actor") then
					asset_preloader:AddAssets(ParaAsset.LoadParaX("", asset));
				elseif(style == "center_model") then
					asset_preloader:AddAssets(ParaAsset.LoadStaticMesh("", asset));
				end
			end

			-- opacity timeline
			local opacity_timeline = {};
			local opacity_node;
			for opacity_node in commonlib.XPath.eachNode(node, "/opacity") do
				if(opacity_node.attr and opacity_node.attr.fromtime and opacity_node.attr.duration and opacity_node.attr.from and opacity_node.attr.to) then
					local fromtime = tonumber(opacity_node.attr.fromtime or 0);
					local duration = tonumber(opacity_node.attr.duration or 0);
					local from = tonumber(opacity_node.attr.from or 0);
					local to = tonumber(opacity_node.attr.to or 0);
					if(fromtime and duration and from and to) then
						table.insert(opacity_timeline, {
							fromtime = fromtime,
							duration = duration,
							from = from,
							to = to,
						});
					end
				end
			end

			-- bind the effect to caster or target
			local position = {0, 0, 0};
			if(style == "center_actor") then
				position = {center_x + math_cos(offset_angle) * offset_radius, 
							center_y + 1.1 + offset_y, 
							center_z - math_sin(offset_angle) * offset_radius
							}; -- delta height is 1.0700006484985
				-- calculate caster and target facing
				local caster_facing;
				local target_facing;
				local targets_center_facing = 0;
				if(caster_char and caster_char.GetPosition)then
					local x, y, z = caster_char:GetPosition();
					--caster_facing = math.atan2((position[1] - x), (position[3] - z)) - math.pi/2;
					caster_facing = math.atan2((x - position[1]), (z - position[3])) - math.pi/2;
				end
				if(target_char_or_chars and target_char_or_chars.GetPosition)then
					local x, y, z = target_char_or_chars:GetPosition();
					--target_facing = math.atan2((position[1] - x), (position[3] - z)) - math.pi/2;
					target_facing = math.atan2((x - position[1]), (z - position[3])) - math.pi/2;
					targets_center_facing = target_facing;
				elseif(target_char_or_chars and target_char_or_chars[1] and target_char_or_chars[1].GetPosition)then
					-- pick the first player as the target
					local x, y, z = target_char_or_chars[1]:GetPosition();
					--target_facing = math.atan2((position[1] - x), (position[3] - z)) - math.pi/2;
					target_facing = math.atan2((x - position[1]), (z - position[3])) - math.pi/2;
					local i = 1;
					for i = 1, #target_char_or_chars do
						local x, y, z = target_char_or_chars[i]:GetPosition();
						--target_facing = math.atan2((position[1] - x), (position[3] - z)) - math.pi/2;
						local temp_facing = math.atan2((x - position[1]), (z - position[3])) - math.pi/2;
						if(temp_facing < 0) then
							temp_facing = temp_facing + math.pi * 2;
						elseif(temp_facing > math.pi * 2) then
							temp_facing = temp_facing - math.pi * 2;
						end
						targets_center_facing = targets_center_facing + temp_facing;
					end
					targets_center_facing = targets_center_facing / #target_char_or_chars;
				end

				-- facing and anim timeline
				local facing_timeline = {[0] = (target_facing + facing) or 0};
				local anim_timeline = {[0] = 0};
				local frame_node;
				for frame_node in commonlib.XPath.eachNode(node, "/frame") do
					if(frame_node.attr and frame_node.attr.time) then
						local time = tonumber(frame_node.attr.time);
						-- animation part of the action
						if(frame_node.attr.anim) then
							local anim = tonumber(frame_node.attr.anim) or frame_node.attr.anim; -- anim may be animid or animation file
							anim_timeline[time] = anim;
						end
						-- facing part of the action
						if(frame_node.attr.face_obj) then
							if(frame_node.attr.face_obj == "target" and target_facing) then
								facing_timeline[time] = target_facing + (tonumber(frame_node.attr.offset_facing) or 0);
							elseif(frame_node.attr.face_obj == "caster" and caster_facing) then
								facing_timeline[time] = caster_facing + (tonumber(frame_node.attr.offset_facing) or 0);
							elseif(frame_node.attr.face_obj == "targets_center" and targets_center_facing) then
								facing_timeline[time] = targets_center_facing + (tonumber(frame_node.attr.offset_facing) or 0);
							elseif(frame_node.attr.face_obj == "caster_crystal" and type(caster_slotid) == "number") then
								if(caster_slotid <= 4) then
									facing_timeline[time] = math.pi + (tonumber(frame_node.attr.offset_facing) or 0);
								elseif(caster_slotid >= 5) then
									facing_timeline[time] = 0 + (tonumber(frame_node.attr.offset_facing) or 0);
								end
							end
						end
					end
				end
				-- current facing and anim
				local this_facing = facing_timeline[0];
				local this_anim = anim_timeline[0];
				local next_facing_time = 0;
				local next_anim_time = 0;
				local large_int = 999999;
				local function GetNextFacingTime(time)
					local return_t;
					local t, _;
					local min_forward_time = large_int;
					for t, _ in pairs(facing_timeline) do
						if(time <= t and (t - time) < min_forward_time) then
							min_forward_time = t - time;
							return_t = t;
						end
					end
					if(min_forward_time == large_int) then
						return_t = large_int;
					end
					this_facing = facing_timeline[next_facing_time];
					next_facing_time = return_t;
				end

				local function GetNextAnimTime(time)
					local return_t;
					local t, _;
					local min_forward_time = large_int;
					for t, _ in pairs(anim_timeline) do
						if(time <= t and (t - time) < min_forward_time) then
							min_forward_time = t - time;
							return_t = t;
							this_anim = _;
						end
					end
					if(min_forward_time == large_int) then
						return_t = large_int;
					end
					this_anim = anim_timeline[next_anim_time];
					next_anim_time = return_t;
					return this_anim;
				end
				
				-- create effect function 
				local func_play_effect = function()
					if(not playing_id_set[playing_id]) then
						return;
					end
					local params = {
						asset_file = asset,
						start_position = position,
						scale = scale_from,
						facing = facing,
						duration_time = duration,
						speed = tonumber(node.attr.speedscale or 1),
						begin_callback = function()
						end,
						end_callback = function()
						end,
					};
					params.elapsedtime_callback = function(elapsedTime, obj)
						local ratio = elapsedTime / duration;
						local scale = scale_from + (scale_to - scale_from) * ratio;
						if(obj and obj:IsValid() == true) then
							obj:SetScale(scale);
							if(elapsedTime > next_facing_time) then
								GetNextFacingTime(elapsedTime);
							end
							if(real_facing) then
								obj:SetFacing(real_facing);
							else
								obj:SetFacing(this_facing);
							end
							if(elapsedTime > next_anim_time) then
								local this_anim = GetNextAnimTime(elapsedTime);
								if(type(this_anim) == "string") then
									Animation.PlayAnimationFile(this_anim, obj);
								else
									Animation.PlayAnimationFile({this_anim}, obj);
								end
							end
							local _, opacity_block;
							for _, opacity_block in ipairs(opacity_timeline) do
								local fromtime = opacity_block.fromtime;
								local duration = opacity_block.duration;
								local from = opacity_block.from;
								local to = opacity_block.to;
								if(fromtime and duration and from and to) then
									if(elapsedTime > fromtime and (elapsedTime <= (fromtime + duration))) then
										local current_opacity = (to - from) * (elapsedTime - fromtime) / duration + from;
										local params = obj:GetEffectParamBlock();
										params:SetFloat("g_opacity", current_opacity);
									end
								end
							end
						end
						if(not playing_id_set[playing_id]) then
							EffectManager.DestroyEffectObjIfValid(obj);
						end
					end;
					EffectManager.CreateEffect(params);
				end
				-- play the effect immediately or after start time
				if(starttime >= 50) then
					UIAnimManager.PlayCustomAnimation(starttime, function(elapsedTime)
						if(elapsedTime == starttime) then
							func_play_effect();
						end
					end);
				else
					func_play_effect();
				end
			elseif(style == "center_model") then
				position = {center_x + math_cos(offset_angle) * offset_radius, 
							center_y + 1.1 + offset_y, 
							center_z - math_sin(offset_angle) * offset_radius
						}; -- delta height is 1.0700006484985
				-- create effect function 
				local func_play_effect = function()
					if(not playing_id_set[playing_id]) then
						return;
					end
					local params = {
						asset_file = asset,
						ismodel = true,
						start_position = position,
						facing = facing,
						scale = scale,
						duration_time = duration,
						speed = tonumber(node.attr.speedscale or 1),
						begin_callback = function()
						end,
						end_callback = function()
						end,
					};
					params.elapsedtime_callback = function(elapsedTime, obj)
						if(not playing_id_set[playing_id]) then
							EffectManager.DestroyEffectObjIfValid(obj);
						end
						if(obj and obj:IsValid() == true) then
							local _, opacity_block;
							for _, opacity_block in ipairs(opacity_timeline) do
								local fromtime = opacity_block.fromtime;
								local duration = opacity_block.duration;
								local from = opacity_block.from;
								local to = opacity_block.to;
								if(fromtime and duration and from and to) then
									if(elapsedTime > fromtime and (elapsedTime <= (fromtime + duration))) then
										local current_opacity = (to - from) * (elapsedTime - fromtime) / duration + from;
										local params = obj:GetEffectParamBlock();
										params:SetFloat("g_opacity", current_opacity);
									end
								end
							end
						end
					end;
					EffectManager.CreateEffect(params);
				end
				-- play the effect immediately or after start time
				if(starttime >= 50) then
					UIAnimManager.PlayCustomAnimation(starttime, function(elapsedTime)
						if(elapsedTime == starttime) then
							func_play_effect();
						end
					end);
				else
					func_play_effect();
				end
			end
		end
	end
	
	-- create missile part of the spell
	for node in commonlib.XPath.eachNode(xmlRoot, "/spell/missile") do
		if(node.attr and node.attr.type and node.attr.asset) then
			local type = node.attr.type;
			local asset = node.attr.asset;
			local starttime = tonumber(node.attr.starttime or 0);
			local duration = GetEffectNodeDuration(node, spell_duration);
			local scale = tonumber(node.attr.scale or 1);
			local from_offset_y = tonumber(node.attr.from_offset_y or 0);
			local to_offset_y = tonumber(node.attr.to_offset_y or 0);
			
			-- preload asset
			if(asset_preloader) then
				asset_preloader:AddAssets(ParaAsset.LoadParaX("", asset));
			end

			-- for each target character play missile effect
			local _, t_char;
			for _, t_char in pairs(target_chars) do
				
				-- bind the effect to caster or target
				local player_from;
				local player_to;
				if(type == "caster_to_target") then
					player_from = caster_char;
					player_to = t_char;
				elseif(type == "target_to_caster") then
					player_from = t_char;
					player_to = caster_char;
				end
			
				-- record the player names
				local player_from_name = player_from.name;
				local player_to_name = player_to.name;

				
				local from_x, from_y, from_z = player_from:GetPosition();
				local to_x, to_y, to_z = player_to:GetPosition();

				local facing_missile = math.atan2((to_x - from_x), (to_z - from_z)) - math.pi/2;
			
				-- create effect function 
				local func_play_missile = function()
					if(not playing_id_set[playing_id]) then
						return;
					end
					local params = {
						asset_file = asset,
						start_position = {player_from:GetPosition()},
						offset_y = offset_y,
						scale = scale,
						facing = facing_missile,
						duration_time = duration,
						speed = tonumber(node.attr.speedscale or 1),
						begin_callback = function()
						end,
						end_callback = function()
						end,
						elapsedtime_callback = function(elapsedTime, obj)
							local player_from = ParaScene.GetCharacter(player_from_name);
							local player_to = ParaScene.GetCharacter(player_to_name);
							if(player_from and player_from:IsValid() == true and player_to and player_to:IsValid() == true) then
								local x_this, y_this, z_this = player_from:GetPosition();
								local x_next, y_next, z_next = player_to:GetPosition();
								local ratio = elapsedTime / duration;
								local x, y, z;
								x = x_this + (x_next - x_this) * ratio;
								y = (y_this + from_offset_y) + ((y_next + to_offset_y) - (y_this + from_offset_y)) * ratio;
								z = z_this + (z_next - z_this) * ratio;
								obj:SetPosition(x, y, z);
							end
							if(not playing_id_set[playing_id]) then
								EffectManager.DestroyEffectObjIfValid(obj);
							end
						end,
					};
					EffectManager.CreateEffect(params);
				end
				-- play the effect immediately or after start time
				if(starttime >= 50) then
					UIAnimManager.PlayCustomAnimation(starttime, function(elapsedTime)
						if(elapsedTime == starttime) then
							func_play_missile();
						end
					end);
				else
					func_play_missile();
				end
			end
		end
	end
	
	-- create missile part of the spell when center position is available
	if(center_x and center_y and center_z) then
		local node;
		for node in commonlib.XPath.eachNode(xmlRoot, "/spell/radius_missile") do
			if(node.attr and node.attr.type and node.attr.asset) then
				local type = node.attr.type;
				local asset = node.attr.asset;
				local starttime = tonumber(node.attr.starttime or 0);
				local duration = GetEffectNodeDuration(node, spell_duration);
				local scale = tonumber(node.attr.scale or 1);
				local from_offset_y = tonumber(node.attr.from_offset_y or 0);
				local to_offset_y = tonumber(node.attr.to_offset_y or 0);
				
				-- preload asset
				if(asset_preloader) then
					asset_preloader:AddAssets(ParaAsset.LoadParaX("", asset));
				end

				-- for each caster character play missile effect
				if(type == "center_to_caster" or type == "caster_to_center") then
					-- bind the effect to caster or target
					local from_x, from_y, from_z;
					local to_x, to_y, to_z;
					if(type == "center_to_caster") then
						from_x, from_y, from_z = center_x, center_y, center_z;
						to_x, to_y, to_z = caster_char:GetPosition();
					elseif(type == "caster_to_center") then
						from_x, from_y, from_z = caster_char:GetPosition();
						to_x, to_y, to_z = center_x, center_y, center_z;
					end

					local facing_missile = math.atan2((to_x - from_x), (to_z - from_z)) - math.pi/2;
			
					-- create effect function 
					local func_play_missile = function()
						if(not playing_id_set[playing_id]) then
							return;
						end
						local params = {
							asset_file = asset,
							start_position = {from_x, from_y, from_z},
							offset_y = offset_y,
							scale = scale,
							facing = facing_missile,
							duration_time = duration,
							speed = tonumber(node.attr.speedscale or 1),
							begin_callback = function()
							end,
							end_callback = function()
							end,
							elapsedtime_callback = function(elapsedTime, obj)
								local x_this, y_this, z_this = from_x, from_y, from_z;
								local x_next, y_next, z_next = to_x, to_y, to_z;
								local ratio = elapsedTime / duration;
								local x, y, z;
								x = x_this + (x_next - x_this) * ratio;
								y = (y_this + from_offset_y) + ((y_next + to_offset_y) - (y_this + from_offset_y)) * ratio;
								z = z_this + (z_next - z_this) * ratio;
								obj:SetPosition(x, y, z);
								if(not playing_id_set[playing_id]) then
									EffectManager.DestroyEffectObjIfValid(obj);
								end
							end,
						};
						EffectManager.CreateEffect(params);
					end
					-- play the effect immediately or after start time
					if(starttime >= 50) then
						UIAnimManager.PlayCustomAnimation(starttime, function(elapsedTime)
							if(elapsedTime == starttime) then
								func_play_missile();
							end
						end);
					else
						func_play_missile();
					end
				elseif(type == "center_to_target" or type == "target_to_center") then
					-- for each target character play missile effect
					local _, t_char;
					for _, t_char in pairs(target_chars) do
				
						-- bind the effect to caster or target
						local from_x, from_y, from_z;
						local to_x, to_y, to_z;
						if(type == "center_to_target") then
							from_x, from_y, from_z = center_x, center_y, center_z;
							to_x, to_y, to_z = t_char:GetPosition();
						elseif(type == "target_to_center") then
							from_x, from_y, from_z = t_char:GetPosition();
							to_x, to_y, to_z = center_x, center_y, center_z;
						end

						local facing_missile = math.atan2((to_x - from_x), (to_z - from_z)) - math.pi/2;
			
						-- create effect function 
						local func_play_missile = function()
							if(not playing_id_set[playing_id]) then
								return;
							end
							local params = {
								asset_file = asset,
								start_position = {from_x, from_y, from_z},
								offset_y = offset_y,
								scale = scale,
								facing = facing_missile,
								duration_time = duration,
								speed = tonumber(node.attr.speedscale or 1),
								begin_callback = function()
								end,
								end_callback = function()
								end,
								elapsedtime_callback = function(elapsedTime, obj)
									local x_this, y_this, z_this = from_x, from_y, from_z;
									local x_next, y_next, z_next = to_x, to_y, to_z;
									local ratio = elapsedTime / duration;
									local x, y, z;
									x = x_this + (x_next - x_this) * ratio;
									y = (y_this + from_offset_y) + ((y_next + to_offset_y) - (y_this + from_offset_y)) * ratio;
									z = z_this + (z_next - z_this) * ratio;
									obj:SetPosition(x, y, z);
									if(not playing_id_set[playing_id]) then
										EffectManager.DestroyEffectObjIfValid(obj);
									end
								end,
							};
							EffectManager.CreateEffect(params);
						end
						-- play the effect immediately or after start time
						if(starttime >= 50) then
							UIAnimManager.PlayCustomAnimation(starttime, function(elapsedTime)
								if(elapsedTime == starttime) then
									func_play_missile();
								end
							end);
						else
							func_play_missile();
						end
					end
				end

			end
		end
	end
	
	-- create animation part of the spell
	for node in commonlib.XPath.eachNode(xmlRoot, "/spell/animation") do
		if(node.attr and node.attr.type and (node.attr.asset or node.attr.id)) then
			-- preload asset
			if(type(node.attr.asset) == "string") then
				if(asset_preloader) then
					asset_preloader:AddAssets(ParaAsset.LoadParaX("", asset));
				end
			end

			local type = node.attr.type;
			local asset = node.attr.asset;
			local id = tonumber(node.attr.id or 0);
			local starttime = tonumber(node.attr.starttime or 0);
			local duration = GetEffectNodeDuration(node, spell_duration, 0);
			
			-- bind the effect to caster or target
			local anim_obj_names = {};
			if(type == "caster") then
				table_insert(anim_obj_names, caster_char.name);
			elseif(type == "target") then
				local _, t_char;
				for _, t_char in pairs(target_chars) do
					table_insert(anim_obj_names, t_char.name);
				end
			end
			-- asser unit: animation id or animation asset file name
			local asset_unit;
			if(id and id ~= 0) then
				asset_unit = {id};
			else
				asset_unit = {asset};
			end
			-- for each animation object play animation id or animation file
			local _, anim_obj_name;
			for _, anim_obj_name in pairs(anim_obj_names) do
				-- create effect function 
				local func_play_anim = function()
					if(not playing_id_set[playing_id]) then
						return;
					end
					if(duration == 0) then
						-- play immediate animation
						local anim_obj = ParaScene.GetObject(anim_obj_name);
						local anim_obj_keyname;
						if(anim_obj and anim_obj:IsValid() == true) then
							anim_obj_keyname = anim_obj:GetPrimaryAsset():GetKeyName();
							local anims = commonlib.deepcopy(asset_unit);
							table_insert(anims, 0);
							Animation.PlayAnimationFile(anims, anim_obj);
						end
						if(anim_obj_keyname == "character/common/teen_default_combat_pose_mount/teen_default_combat_pose_mount.x" or anim_obj_keyname == "character/v6/02animals/WhiteCloud/WhiteCloud.x") then
							local anim_obj_mount = ParaScene.GetObject(anim_obj_name.."+driver");
							if(anim_obj_mount and anim_obj_mount:IsValid() == true) then
								local anims = commonlib.deepcopy(asset_unit);
								local default_mount_animfile = "character/Animation/v6/teen_default_combat_pose.x";
								local anim_obj_mount_assetkey = anim_obj_mount:GetPrimaryAsset():GetKeyName();
								if(anim_obj_mount_assetkey == "character/v3/TeenElf/Female/TeenElfFemale.xml") then
									default_mount_animfile = "character/Animation/v6/teen_default_combat_pose_female.x";
								elseif(anim_obj_mount_assetkey == "character/v3/TeenElf/Male/TeenElfMale.xml") then
									default_mount_animfile = "character/Animation/v6/teen_default_combat_pose_male.x";
								end
								table_insert(anims, default_mount_animfile);
								Animation.PlayAnimationFile(anims, anim_obj_mount);
							end
						elseif(anim_obj_keyname and default_mount_anim_map_replace_with_sex[anim_obj_keyname] and default_mount_anim_map_teen_with_sex[anim_obj_keyname]) then
							local anim_obj_mount = ParaScene.GetObject(anim_obj_name.."+driver");
							if(anim_obj_mount and anim_obj_mount:IsValid() == true) then
								local anim_obj_mount_assetkey = anim_obj_mount:GetPrimaryAsset():GetKeyName();
								local anims = {};
								local _, id_or_file;
								for _, id_or_file in ipairs(asset_unit) do
									local group;
									if(anim_obj_mount_assetkey == "character/v3/TeenElf/Female/TeenElfFemale.xml") then
										group = default_mount_anim_map_replace_with_sex[anim_obj_keyname]["female"];
									elseif(anim_obj_mount_assetkey == "character/v3/TeenElf/Male/TeenElfMale.xml") then
										group = default_mount_anim_map_replace_with_sex[anim_obj_keyname]["male"];
									end
									if(group) then
										id_or_file = group[id_or_file] or id_or_file;
									end
									table_insert(anims, id_or_file);
								end
								if(default_mount_anim_map_teen_with_sex[anim_obj_keyname]) then
									local default_mount_animfile;
									if(anim_obj_mount_assetkey == "character/v3/TeenElf/Female/TeenElfFemale.xml") then
										default_mount_animfile = default_mount_anim_map_teen_with_sex[anim_obj_keyname]["female"];
									elseif(anim_obj_mount_assetkey == "character/v3/TeenElf/Male/TeenElfMale.xml") then
										default_mount_animfile = default_mount_anim_map_teen_with_sex[anim_obj_keyname]["male"];
									end
									if(default_mount_animfile) then
										table_insert(anims, default_mount_animfile);
									end
								end
								Animation.PlayAnimationFile(anims, anim_obj_mount);
							end
						elseif(anim_obj_keyname == "character/v6/02animals/WhiteCloud/WhiteCloud.x") then
							-- NOTE: cancel on cloud casting animation
							--local anim_obj_mount = ParaScene.GetObject(anim_obj_name.."+driver");
							--if(anim_obj_mount and anim_obj_mount:IsValid() == true) then
								--local anims = commonlib.deepcopy(asset_unit);
								--local default_mount_animfile = "character/Animation/v6/teen_default_combat_pose.x";
								--local anim_obj_mount_assetkey = anim_obj_mount:GetPrimaryAsset():GetKeyName();
								--if(anim_obj_mount_assetkey == "character/v3/TeenElf/Female/TeenElfFemale.xml") then
									--default_mount_animfile = "character/Animation/v6/teen_Mount_FlyingCloud_female.x";
								--elseif(anim_obj_mount_assetkey == "character/v3/TeenElf/Male/TeenElfMale.xml") then
									--default_mount_animfile = "character/Animation/v6/teen_Mount_FlyingCloud_male.x";
								--end
								--table_insert(anims, default_mount_animfile);
								--Animation.PlayAnimationFile(anims, anim_obj_mount);
							--end
						end
					else
						-- play looped channel animation
						local anim_obj = ParaScene.GetObject(anim_obj_name);
						if(anim_obj and anim_obj:IsValid() == true) then
							Animation.PlayAnimationFile(asset_unit, anim_obj);
						end
						local anim_obj_mount = ParaScene.GetObject(anim_obj_name.."+driver");
						if(anim_obj_mount and anim_obj_mount:IsValid() == true) then
							Animation.PlayAnimationFile(asset_unit, anim_obj_mount);
						end
						-- return to idle when finished
						UIAnimManager.PlayCustomAnimation(duration, function(elapsedTime)
							if(elapsedTime == duration) then
								-- return to idle
								local anim_obj = ParaScene.GetObject(anim_obj_name);
								if(anim_obj and anim_obj:IsValid() == true) then
									---- NOTE: forget why i need an animation file confirmed
									--local animfile = anim_obj:ToCharacter():GetAnimFileName()
									--if(asset == animfile) then
										--Animation.PlayAnimationFile({0}, anim_obj);
									--end
									Animation.PlayAnimationFile({0}, anim_obj);
								end
								---- return to idle
								--local anim_obj_mount = ParaScene.GetObject(anim_obj_name.."+driver");
								--if(anim_obj_mount and anim_obj_mount:IsValid() == true) then
									--local default_mount_animfile = "character/Animation/v5/DefaultMount.x";
									--if(System.options.version == "teen") then
										--default_mount_animfile = "character/Animation/v5/DefaultMount_teen.x";
										--default_mount_animfile = "character/Animation/v5/MagicBesom_teen.x";
									--end
									--Animation.PlayAnimationFile(default_mount_animfile, anim_obj_mount);
								--end
							end
						end);
					end
				end
				-- play the effect immediately or after start time
				if(starttime >= 50) then
					UIAnimManager.PlayCustomAnimation(starttime, function(elapsedTime)
						if(elapsedTime == starttime) then
							func_play_anim();
						end
					end);
				else
					func_play_anim();
				end
			end
		end
	end

	-- start preloader
	if(asset_preloader) then
		asset_preloader:Start();
	end

	-- create shader_effect part of the spell
	for node in commonlib.XPath.eachNode(xmlRoot, "/spell/shader_effect") do
		if(node.attr and node.attr.type and node.attr.name) then
			local type = node.attr.type;
			local name = node.attr.name;
			local starttime = tonumber(node.attr.starttime or 0);
			local duration = GetEffectNodeDuration(node, spell_duration, 0);
			
			-- bind the effect to caster or target
			local anim_obj_names = {};
			if(type == "caster") then
				table_insert(anim_obj_names, caster_char.name);
			elseif(type == "target") then
				local _, t_char;
				for _, t_char in pairs(target_chars) do
					table_insert(anim_obj_names, t_char.name);
				end
			end
			-- for each animation object play animation id or animation file
			local _, anim_obj_name;
			for _, anim_obj_name in pairs(anim_obj_names) do
				-- create effect function 
				local func_play_anim = function()
					-- NOTE: shader effect skip the playing_id_set[playing_id] test
					-- play immediate animation
					if(name == "frozen") then
						local anim_obj = ParaScene.GetObject(anim_obj_name);
						if(anim_obj and anim_obj:IsValid() == true) then
							FrozenEffect.ApplyFrozenEffect(anim_obj);
						end
						local anim_obj_mount = ParaScene.GetObject(anim_obj_name.."+driver");
						if(anim_obj_mount and anim_obj_mount:IsValid() == true) then
							FrozenEffect.ApplyFrozenEffect(anim_obj_mount);
						end
					elseif(name == "stealth") then
						local anim_obj = ParaScene.GetObject(anim_obj_name);
						if(anim_obj and anim_obj:IsValid() == true) then
							TransparentEffect.Apply(anim_obj);
							TransparentEffect.SetDiffuseColor(0.8, 0.8, 0.8);
						end
						local anim_obj_mount = ParaScene.GetObject(anim_obj_name.."+driver");
						if(anim_obj_mount and anim_obj_mount:IsValid() == true) then
							TransparentEffect.Apply(anim_obj_mount);
							TransparentEffect.SetDiffuseColor(0.8, 0.8, 0.8);
						end
					elseif(name == "stone") then
						-- <shader_effect type="target" name="stone" starttime="1500" duration="1000"/>
						local anim_obj = ParaScene.GetObject(anim_obj_name);
						if(anim_obj and anim_obj:IsValid() == true) then
							StoneEffect.ApplyEffect(anim_obj);
							if(duration > 0) then
								UIAnimManager.PlayCustomAnimation(duration, function(elapsedTime)
									if(anim_obj and anim_obj:IsValid() == true) then
										local factor = elapsedTime / duration;
										if(factor > 1) then
											factor = 1;
										elseif(factor < 0) then
											factor = 0;
										end
										local params = anim_obj:GetEffectParamBlock();
										params:SetFloat("transitionFactor", factor);
									end
								end);
							end
						end
						local anim_obj_mount = ParaScene.GetObject(anim_obj_name.."+driver");
						if(anim_obj_mount and anim_obj_mount:IsValid() == true) then
							StoneEffect.ApplyEffect(anim_obj_mount);
							if(duration > 0) then
								UIAnimManager.PlayCustomAnimation(duration, function(elapsedTime)
									if(anim_obj_mount and anim_obj_mount:IsValid() == true) then
										local factor = elapsedTime / duration;
										if(factor > 1) then
											factor = 1;
										elseif(factor < 0) then
											factor = 0;
										end
										local params = anim_obj_mount:GetEffectParamBlock();
										params:SetFloat("transitionFactor", factor);
									end
								end);
							end
						end
					elseif(name == "reset") then
						local anim_obj = ParaScene.GetObject(anim_obj_name);
						if(anim_obj and anim_obj:IsValid() == true) then
							FrozenEffect.ResetEffect(anim_obj);
						end
						local anim_obj_mount = ParaScene.GetObject(anim_obj_name.."+driver");
						if(anim_obj_mount and anim_obj_mount:IsValid() == true) then
							FrozenEffect.ResetEffect(anim_obj_mount);
						end
					end
				end
				-- play the effect immediately or after start time
				if(starttime >= 50) then
					UIAnimManager.PlayCustomAnimation(starttime, function(elapsedTime)
						if(elapsedTime == starttime) then
							func_play_anim();
						end
					end);
				else
					func_play_anim();
				end
			end
		end
	end
	
	-- create animation part of the spell
	for node in commonlib.XPath.eachNode(xmlRoot, "/spell/action_hidearrow") do
		if(node.attr and node.attr.starttime) then
			local starttime = tonumber(node.attr.starttime);
			if(starttime) then
				UIAnimManager.PlayCustomAnimation(starttime, function(elapsedTime)
					if(elapsedTime == starttime) then
						ObjectManager.SetSequenceArrowVisible(arena_id, false);
					end
				end);
			end
		end
	end
	for node in commonlib.XPath.eachNode(xmlRoot, "/spell/action_showarrow") do
		if(node.attr and node.attr.starttime) then
			local starttime = tonumber(node.attr.starttime);
			if(starttime) then
				UIAnimManager.PlayCustomAnimation(starttime, function(elapsedTime)
					if(elapsedTime == starttime) then
						ObjectManager.SetSequenceArrowVisible(arena_id, true);
					end
				end);
			end
		end
	end
	
	-- create comment part of the spell
	if(comment_params) then
		local comment_number_seq_count = 1;
		local node;
		for node in commonlib.XPath.eachNode(xmlRoot, "/spell/comment") do
			if(node.attr and node.attr.type and node.attr.starttime) then
				local type = node.attr.type;
				local starttime = tonumber(node.attr.starttime or 0);
			
				-- pick the comment object and the content
				local binding_obj_units = {};
				local content = "";
				local delta_hp = 0;
				local color = node.attr.color or "da2d2d";
				local anim_type = "plain";
				local play_shake_anim = false;
				local play_doubleattack_anim = false;
				local play_dodge_anim = false;
				if(type == "target_damage") then
					local _, t_char;
					local nIndex = 1;
					for _, t_char in pairs(target_chars) do
						table_insert(binding_obj_units, {
							obj_name = t_char.name, 
							content = "-"..(comment_params[comment_number_seq_count][nIndex] or "0"),
							delta_hp = -comment_params[comment_number_seq_count][nIndex],
							prior_mark = (comment_params[comment_number_seq_count].prior_target_marks or {})[nIndex],
						});
						nIndex = nIndex + 1;
						if(comment_params[comment_number_seq_count].mark == "c") then
							play_shake_anim = true;
						end
						if(comment_params[comment_number_seq_count].mark == "t") then
							play_doubleattack_anim = true;
						end
						if(comment_params[comment_number_seq_count].mark == "d") then
							play_dodge_anim = true;
						end
					end
					color = node.attr.color or "da2d2d";
					comment_number_seq_count = comment_number_seq_count + 1;
					anim_type = "critical";
				elseif(type == "caster_damage") then
					table_insert(binding_obj_units, {
						obj_name = caster_char.name, 
						content = "-"..(comment_params[comment_number_seq_count][1] or "0"),
						delta_hp = -comment_params[comment_number_seq_count][1],
					});
					color = node.attr.color or "da2d2d";
					comment_number_seq_count = comment_number_seq_count + 1;
					anim_type = "critical";
				elseif(type == "target_heal") then
					local _, t_char;
					local nIndex = 1;
					for _, t_char in pairs(target_chars) do
						table_insert(binding_obj_units, {
							obj_name = t_char.name, 
							content = "+"..(comment_params[comment_number_seq_count][nIndex] or "0"),
							delta_hp = comment_params[comment_number_seq_count][nIndex],
						});
						nIndex = nIndex + 1;
					end
					color = node.attr.color or "63d13e";
					comment_number_seq_count = comment_number_seq_count + 1;
					anim_type = "critical";
				elseif(type == "caster_heal") then
					table_insert(binding_obj_units, {
						obj_name = caster_char.name, 
						content = "+"..(comment_params[comment_number_seq_count][1] or "0"),
						delta_hp = comment_params[comment_number_seq_count][1],
					});
					color = node.attr.color or "63d13e";
					comment_number_seq_count = comment_number_seq_count + 1;
					anim_type = "critical";
				elseif(type == "target_title") then
					local _, t_char;
					local nIndex = 1;
					for _, t_char in pairs(target_chars) do
						table_insert(binding_obj_units, {
							obj_name = t_char.name, 
							content = node.attr.content or "",
							delta_hp = 0,
						});
						nIndex = nIndex + 1;
					end
					color = node.attr.color or "63d13e";
					anim_type = "plain";
				elseif(type == "caster_title") then
					table_insert(binding_obj_units, {
						obj_name = caster_char.name, 
						content = node.attr.content or "",
						delta_hp = 0,
					});
					color = node.attr.color or "63d13e";
					anim_type = "plain";
				end

				-- traverse through all binding objects
				local _, binding_obj_unit;
				for _, binding_obj_unit in pairs(binding_obj_units) do
					local bind_obj_name = binding_obj_unit.obj_name;
					local content = binding_obj_unit.content;
					local prior_mark = binding_obj_unit.prior_mark;
					local delta_hp = binding_obj_unit.delta_hp;
					-- create effect function
					local func_play_effect = function()
						if(playing_id_set[playing_id]) then
							--local mcml_str = string.format([[<div style="margin-left:0px;width:300px;height:32;color:#%s;text-align:center;base-font-size:18;font-weight:bold;text-shadow:true" >%s</div>]], color, content)
							local mcml_str = "";
							if(prior_mark and prior_mark == "c") then -- "" stands for normal
								mcml_str = [[<img src="Texture/Aries/Common/CriticalStrike.png;0 0 180 80" style="width:135px;height:60px;"/><br/>]];
							elseif(prior_mark and prior_mark == "t") then -- t stands for double attack
								mcml_str = [[<img src="Texture/Aries/Common/DoubleAttack.png" style="width:128px;height:32px;"/><br/>]];
							elseif(prior_mark and prior_mark == "d") then -- "" stands for normal
								if(System.options.version == "kids") then
									mcml_str = [[<img src="Texture/Aries/Common/Dodge_kids.png" style="width:128px;height:32px;"/><br/>]];
								else
									mcml_str = [[<img src="Texture/Aries/Common/Dodge.png" style="width:64px;height:32px;"/><br/>]];
								end
							elseif(not prior_mark and play_shake_anim) then
								mcml_str = [[<img src="Texture/Aries/Common/CriticalStrike.png;0 0 180 80" style="width:135px;height:60px;"/><br/>]];
							elseif(not prior_mark and play_doubleattack_anim) then
								mcml_str = [[<img src="Texture/Aries/Common/DoubleAttack.png" style="width:128px;height:32px;"/><br/>]];
								
							elseif(not prior_mark and play_dodge_anim) then
								if(System.options.version == "kids") then
									mcml_str = [[<img src="Texture/Aries/Common/Dodge_kids.png" style="width:128px;height:32px;"/><br/>]];
								else
									mcml_str = [[<img src="Texture/Aries/Common/Dodge.png" style="width:64px;height:32px;"/><br/>]];
								end
							end
							local spritestyle = "CombatDigits";
							if(not tonumber(content)) then
								spritestyle = "SpellName";
							end
							if(System.options.locale == "zhCN" or System.options.locale == "zhTW") then
								-- Chinese character with text sprite
								mcml_str = mcml_str..string.format([[<aries:textsprite spritestyle="%s" color="#%s" text="%s" default_fontsize="18" fontsize="24"/>]], spritestyle, color, content);
								--mcml_str = string.format([[<aries:textsprite spritestyle="%s" color="#%s" text="%s" fontsize="18"/>]], spritestyle, color, content);
							else
								-- other locales with text font
								--title = title..title;
								mcml_str = mcml_str..string.format([[<div ><input type="button" style="margin-left:0px;background:;width:400px;height:32;color:#%s;text-align:center;font-size:24pt;font-weight:bold;text-shadow:true" value="%s"/></div>]], color, content)
							end
							local sCtrlName = headon_speech.Speek(bind_obj_name, mcml_str, 2, true, true, true, -1);
							if(sCtrlName) then
								if(anim_type == "plain") then
									UIAnimManager.PlayCustomAnimation(2000, function(elapsedTime)
										local parent = ParaUI.GetUIObject(sCtrlName);
										if(parent:IsValid()) then

											parent.translationy = 13;
											
											if(elapsedTime < 700) then
												local scaling = 1.6 + 0.4 * elapsedTime / 700;
												parent.scalingx = scaling;
												parent.scalingy = scaling;
											elseif(elapsedTime < 1000) then
												local scaling = 2.0 - 0.2 * (1000 - elapsedTime) / 300;
												parent.scalingx = scaling;
												parent.scalingy = scaling;
											else
												parent.scalingx = 1.8;
												parent.scalingy = 1.8;
											end
											parent:ApplyAnim();
										end
									end);
								elseif(anim_type == "critical") then
									UIAnimManager.PlayCustomAnimation(2500, function(elapsedTime)
										local parent = ParaUI.GetUIObject(sCtrlName);
										if(parent:IsValid()) then
											--if(elapsedTime < 1000) then
												--parent.translationy = 14 - (1000 * 1000 / 2000) * 20 / 1000;
											--else
												--parent.translationy = 14 - (elapsedTime * elapsedTime / 2000) * 20 / 1000;
											--end
											--if(isCritical and elapsedTime < 200) then
												--parent.scalingx = 2.4 - 0.6 * math.abs(elapsedTime - 100) / 100;
												--parent.scalingy = 2.4 - 0.6 * math.abs(elapsedTime - 100) / 100;
											--else
												--parent.scalingx = 1.8;
												--parent.scalingy = 1.8;
											--end

											parent.translationy = 13;
											
											if(elapsedTime < 100) then
												local scaling = 1.5 + 0.6 * elapsedTime / 100;
												parent.scalingx = scaling;
												parent.scalingy = scaling;
											elseif(elapsedTime < 300) then
												local scaling = 2.1 - 0.3 * (elapsedTime - 100) / 200;
												parent.scalingx = scaling;
												parent.scalingy = scaling;
											else
												parent.scalingx = 1.8;
												parent.scalingy = 1.8;
											end
											
											if(elapsedTime >= 1700) then
												local color = "255 255 255 "..math.ceil(255 - 255 * (elapsedTime - 1700) / 800);
												parent.colormask = color;
											end

											parent:ApplyAnim();
										end
									end);
								end
							end
						end
						if(update_hp_callback) then
							update_hp_callback(bind_obj_name, delta_hp);
						end
					end

					local func_shake_effect = function()
						local att = ParaCamera.GetAttributeObject();
						local dist = att:GetField("CameraObjectDistance", 10);
						local angle = att:GetField("CameraLiftupAngle", 0);
						local rot = att:GetField("CameraRotY", 0);
	
						-- refactored by LXZ 2010.1.6: using offset = amp * sin(wt)
						local total_time = 1; -- length of the animation in seconds
						local total_time_ms = total_time*1000;
	
						UIAnimManager.PlayCustomAnimation(total_time_ms, function(elapsedTime)
							local current_dist = att:GetField("CameraObjectDistance", 10);
							local current_angle = att:GetField("CameraLiftupAngle", 0);
							local current_rot = att:GetField("CameraRotY", 0);

							if(current_angle == angle and current_rot == rot) then
								if(elapsedTime == total_time_ms) then
									--local att = ParaCamera.GetAttributeObject();
									--att:SetField("CameraObjectDistance", dist);
									--att:GetField("CameraLiftupAngle", angle);
									--att:GetField("CameraRotY", rot);
								else
									elapsedTime = elapsedTime / 1000
									local amp = 2.8*(-(elapsedTime - total_time*0.5)*(elapsedTime - total_time*0.5) + 0.25*elapsedTime*elapsedTime);
									local frequency = 70;
									local offset = amp * math.sin(frequency*elapsedTime);
			
									local att = ParaCamera.GetAttributeObject();
									att:SetField("CameraObjectDistance", dist + offset);
									att:SetField("CameraLiftupAngle", angle);
									att:SetField("CameraRotY", rot);
								end
							end
						end);
					end
					-- play the effect immediately or after start time
					if(starttime >= 50) then
						UIAnimManager.PlayCustomAnimation(starttime, function(elapsedTime)
							if(elapsedTime == starttime) then
								func_play_effect();
								if(play_shake_anim) then
									func_shake_effect();
								elseif(play_doubleattack_anim) then
									func_shake_effect();
								end
							end
						end);
					else
						func_play_effect();
						if(play_shake_anim) then
							func_shake_effect();
						elseif(play_doubleattack_anim) then
							func_shake_effect();
						end
					end
				end
			end
		end
	end
	
	-- create update part of the spell
	if(update_buffs) then
		local node;
		for node in commonlib.XPath.eachNode(xmlRoot, "/spell/update") do
			if(node.attr and node.attr.type) then
				local type = node.attr.type;
				local anim = node.attr.anim or "move";
				local starttime = tonumber(node.attr.starttime or 0);
				local anim_id = 4;
				if(anim == "move") then
					anim_id = 4;
				elseif(anim == "stop") then
					anim_id = 0;
				end
			
				-- bind the effect to caster or target
				local binding_units = {};
				if(type == "caster_charms") then
					table_insert(binding_units, {
						slot_id = caster_slotid, 
						charms = update_buffs[1].caster_charms,
					});
				elseif(type == "last_caster_charms") then
					table_insert(binding_units, {
						slot_id = caster_slotid, 
						charms = update_buffs[1].last_caster_charms,
					});
				elseif(type == "target_charms") then
					local _, slot_id;
					for _, slot_id in ipairs(target_slotids) do
						table_insert(binding_units, {
							slot_id = slot_id,
							charms = update_buffs[_].target_charms,
						});
					end
				elseif(type == "caster_wards") then
					table_insert(binding_units, {
						slot_id = caster_slotid, 
						wards = update_buffs[1].caster_wards,
					});
				elseif(type == "last_target_wards") then
					local _, slot_id;
					for _, slot_id in ipairs(target_slotids) do
						table_insert(binding_units, {
							slot_id = slot_id,
							wards = update_buffs[_].last_target_wards,
						});
					end
				elseif(type == "target_wards") then
					local _, slot_id;
					for _, slot_id in ipairs(target_slotids) do
						table_insert(binding_units, {
							slot_id = slot_id,
							wards = update_buffs[_].target_wards,
						});
					end
				elseif(type == "caster_overtimes") then
					table_insert(binding_units, {
						slot_id = caster_slotid, 
						overtimes = update_buffs[1].caster_overtimes,
					});
				elseif(type == "last_target_overtimes") then
					local _, slot_id;
					for _, slot_id in ipairs(target_slotids) do
						table_insert(binding_units, {
							slot_id = slot_id,
							overtimes = update_buffs[_].last_target_overtimes,
						});
					end
				elseif(type == "target_overtimes") then
					local _, slot_id;
					for _, slot_id in ipairs(target_slotids) do
						table_insert(binding_units, {
							slot_id = slot_id,
							overtimes = update_buffs[_].target_overtimes,
						});
					end
				end

				-- traverse through all binding objects
				local _, binding_unit;
				for _, binding_unit in ipairs(binding_units) do
					-- create effect function 
					local func_update = function()
						-- NOTE: update buff skip the playing_id_set[playing_id] test
						if(binding_unit.charms) then
							ObjectManager.RefreshBuffs(arena_id, binding_unit.slot_id, "charm", binding_unit.charms);
							ObjectManager.PlayAnimSlots(arena_id, binding_unit.slot_id, "charm", anim_id);
						elseif(binding_unit.wards) then
							ObjectManager.RefreshBuffs(arena_id, binding_unit.slot_id, "ward", binding_unit.wards);
							ObjectManager.PlayAnimSlots(arena_id, binding_unit.slot_id, "ward", anim_id);
						elseif(binding_unit.overtimes) then
							ObjectManager.RefreshBuffs(arena_id, binding_unit.slot_id, "overtime", binding_unit.overtimes);
							ObjectManager.PlayAnimSlots(arena_id, binding_unit.slot_id, "overtime", anim_id);
						end
					end
					-- play the effect immediately or after start time
					if(starttime >= 50) then
						UIAnimManager.PlayCustomAnimation(starttime, function(elapsedTime)
							if(elapsedTime == starttime) then
								func_update();
							end
						end);
					else
						func_update();
					end
				end
			end
		end
	end
	
	---- create followpet hide of the spell
	--local node;
	--for node in commonlib.XPath.eachNode(xmlRoot, "/spell/pet") do
		--if(node.attr and node.attr.type and node.attr.asset) then
			--
			--local nid = caster_char.name;
			--nid = tonumber(nid);
			--if(nid) then
				--local Pet = MyCompany.Aries.Pet;
				--local caster_follow = Pet.GetUserFollowObj(nid);
				--if(caster_follow and caster_follow:IsValid()) then
					--local starttime = tonumber(node.attr.starttime or 0);
					--local duration = tonumber(node.attr.duration or 0);
					--
					---- play the sound immediately or after start time
					--if(starttime >= 50) then
						--UIAnimManager.PlayCustomAnimation(starttime, function(elapsedTime)
							--if(elapsedTime == starttime) then
								--caster_follow:SetVisible(false);
							--end
						--end);
					--else
						--caster_follow:SetVisible(false);
					--end
					--if((starttime + duration) >= 50) then
						--UIAnimManager.PlayCustomAnimation(starttime + duration, function(elapsedTime)
							--if(elapsedTime == (starttime + duration)) then
								--caster_follow:SetVisible(true);
							--end
						--end);
					--else
						--caster_follow:SetVisible(true);
					--end
				--end
			--end
		--end
	--end

	-- check force sound
	if(not bForceSound) then
		-- skip camera playing
		if(bSkipCamera) then
			return;
		end
	end
	
	-- NOTE: we assume that sound playing is cancelled without dynamic camera control
	-- create sound part of the spell
	-- bDisableSound = System.options.IsMobilePlatform;
	local bDisableSound;
	if(not bDisableSound) then
		for node in commonlib.XPath.eachNode(xmlRoot, "/spell/sound") do
			if(node.attr and node.attr.type and node.attr.asset) then
			
				local asset = node.attr.asset;
				local starttime = tonumber(node.attr.starttime or 0);

				local sound_replacement = SpellCast.CreateGetSoundReplacements();
				if(sound_replacement) then
					local pertitle_replacement = sound_replacement[asset]
					if(pertitle_replacement) then
						local _, bind_obj;
						for _, bind_obj in pairs(target_chars) do
							local att = bind_obj:GetAttributeObject();
							local assetkey_name = att:GetDynamicField("player_phase", bind_obj:GetPrimaryAsset():GetKeyName());

							-- use additional branch for teen version character
							if(System.options.version == "teen") then
								local bind_obj_mount = ParaScene.GetObject(bind_obj.name.."+driver");
								if(bind_obj_mount and bind_obj_mount:IsValid() == true) then
									local bind_obj_mount_assetkey = bind_obj_mount:GetPrimaryAsset():GetKeyName();
									if(bind_obj_mount_assetkey == "character/v3/TeenElf/Female/TeenElfFemale.xml") then
										assetkey_name = assetkey_name.."_female";
									elseif(bind_obj_mount_assetkey == "character/v3/TeenElf/Male/TeenElfMale.xml") then
										assetkey_name = assetkey_name.."_male";
									end
								end
							end

							if(pertitle_replacement[assetkey_name]) then
								asset = pertitle_replacement[assetkey_name];
								break;
							end
						end
					end
				end

				local audio_src = AudioEngine.CreateGet(asset);
				if(audio_src.file and audio_src.file == "") then
					-- load plain audio. 
					local audio_type = node.attr.type;
					audio_src.file = asset;
					if(audio_type == "plain") then
						audio_src.inmemory = true;
					end
				end

				-- play the sound immediately or after start time
				if(playing_id_set[playing_id]) then
					if(starttime >= 50) then
						UIAnimManager.PlayCustomAnimation(starttime, function(elapsedTime)
							if(elapsedTime == starttime) then
								if(playing_id_set[playing_id]) then
									audio_src:play();
								end
							end
						end);
					else
						if(playing_id_set[playing_id]) then
							audio_src:play();
						end
					end
				end
			end
		end
	end
	
	-- skip camera playing
	if(bSkipCamera) then
		return;
	end
	
	-- forced spell cast camera lookat missile effect name
	local force_name = "Aries_Combat_Camera_Lookat_SpellCast";

	-- create camera lookat part of the spell
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/spell/lookat") do
		if(node.attr and node.attr.type) then
			local type = node.attr.type;
			local starttime = tonumber(node.attr.starttime or 0);
			local duration = GetEffectNodeDuration(node, spell_duration);
			local from_offset_y = tonumber(node.attr.from_offset_y or 0);
			local to_offset_y = tonumber(node.attr.to_offset_y or 0);

			local target_char = nil;
			-- for the first target character play lookat missile effect
			local _, t_char;
			for _, t_char in pairs(target_chars) do
				target_char = t_char;
				break;
			end
			if(not target_char or target_char:IsValid() == false) then
				return;
			end

			-- bind the effect to caster or target
			local player_from;
			local player_to;
			if(type == "caster_to_target") then
				player_from = caster_char;
				player_to = target_char;
			elseif(type == "target_to_caster") then
				player_from = target_char;
				player_to = caster_char;
			end
			
			-- record the player names
			local player_from_name = player_from.name;
			local player_to_name = player_to.name;

				
			local from_x, from_y, from_z = player_from:GetPosition();
			local to_x, to_y, to_z = player_to:GetPosition();

			local facing_missile = math.atan2((to_x - from_x), (to_z - from_z)) - math.pi/2;

			-- create effect function 
			local func_play_missile = function()
				local params = {
					asset_file = "character/common/dummy/cube_size/cube_size.x",
					start_position = {player_from:GetPosition()},
					offset_y = offset_y,
					scale = 0.00001,
					force_name = force_name,
					facing = facing_missile,
					duration_time = duration,
					begin_callback = function()
					end,
					end_callback = function()
					end,
					elapsedtime_callback = function(elapsedTime, obj)
						local player_from = ParaScene.GetCharacter(player_from_name);
						local player_to = ParaScene.GetCharacter(player_to_name);
						if(player_from and player_from:IsValid() == true and player_to and player_to:IsValid() == true) then
							local x_this, y_this, z_this = player_from:GetPosition();
							local x_next, y_next, z_next = player_to:GetPosition();
							local ratio = elapsedTime / duration;
							local x, y, z;
							x = x_this + (x_next - x_this) * ratio;
							y = (y_this + from_offset_y) + ((y_next + to_offset_y) - (y_this + from_offset_y)) * ratio;
							z = z_this + (z_next - z_this) * ratio;
							obj:SetPosition(x, y, z);
						end
					end,
				};
				EffectManager.CreateEffect(params);
			end
			-- play the effect immediately or after start time
			if(starttime >= 50) then
				UIAnimManager.PlayCustomAnimation(starttime, function(elapsedTime)
					if(elapsedTime == starttime) then
						func_play_missile();
					end
				end);
			else
				func_play_missile();
			end
			break;
		end
	end

	
	local x,y,z;
	local start_point_pos;
	local end_point_pos;
	if(caster_char and caster_char.GetPosition)then
		x,y,z = caster_char:GetPosition();
		start_point_pos = {x,y,z};
	end
	if(target_char_or_chars and target_char_or_chars.GetPosition)then
		x,y,z = target_char_or_chars:GetPosition();
		end_point_pos = {x,y,z};
	elseif(target_char_or_chars and target_char_or_chars[1] and target_char_or_chars[1].GetPosition)then
		-- pick the first player as the target
		x,y,z = target_char_or_chars[1]:GetPosition();
		end_point_pos = {x,y,z};
	else
		-- in case the spell don't need a target, like fizzle or pass
		end_point_pos = start_point_pos;
	end
	local ground_pos = { center_x, center_y, center_z };
			
	local miniscene_name = EffectManager.GetMinisceneName();
	local args = {
		start_point_pos = start_point_pos,
		end_point_pos = end_point_pos,
		ground_pos = ground_pos,
		miniscene_name = miniscene_name,
		lookat_effect_force_name = force_name,
		spell_config_file = spell_config_file,
		caster_slotid = caster_slotid,
		target_slotids = target_slotids,
	}
	CombatCameraView.PlayMotion(nil, args, function() end);
end

function SpellCast.StopSpellCasting(playing_id)
	if(playing_id) then
		playing_id_set[playing_id] = nil;
	end
end

-- enter Combat mode
function SpellCast.OnEnterCombatMode()
end

-- leave Combat mode
function SpellCast.OnLeaveCombatMode()
end
