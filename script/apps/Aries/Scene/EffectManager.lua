--[[
Title: effect manager
Author(s): WangTian
Date: 2009/9/4
Desc:
Scene effect manager will use mini scene "aries_effect" as the effect object scene graph.
Effect manager provides helper functions to create, modify, delete effect objects.

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Scene/EffectManager.lua");
------------------------------------------------------------
]]

-- create class
local EffectManager = commonlib.gettable("MyCompany.Aries.EffectManager");
local UIAnimManager = commonlib.gettable("UIAnimManager");

local ParaScene_GetMiniSceneGraph = ParaScene.GetMiniSceneGraph;
local math_cos = math.cos
local math_sin = math.sin;
local table_insert = table.insert;
local pairs = pairs;
local LOG = LOG;
local type = type;

-- binding of effect name and scene object name
local Binding_Effect_SceneObj = {};

-- invoked at MyCompany.Aries.OnActivateDesktop()
function EffectManager.Init()
	NPL.load("(gl)script/ide/timer.lua");
	EffectManager.timer = EffectManager.timer or commonlib.Timer:new({callbackFunc = EffectManager.DoEffectUpdateTimer});
	EffectManager.timer:Change(0,0); -- fastest timer
end

function EffectManager.Exit()
	if(EffectManager.timer) then
		EffectManager.timer:Change()
	end
end

function EffectManager.GetObject(name)
	local player;
	if(name == "localuser") then
		local entity = GameLogic.EntityManager.GetPlayer();
		player = entity and entity:GetInnerObject()
	else
		player = ParaScene.GetObject(name);
	end
	return player;
end

-- UIAnimManager.PlayCustomAnimation only follows UI framemove rates, we set the scene position binding to a super high rate timer
function EffectManager.DoEffectUpdateTimer()
	local effectGraph = ParaScene_GetMiniSceneGraph("aries_effect");
	if(effectGraph:IsValid()) then
		local invalid_effectnames = {};
		local effect_name, param;
		for effect_name, param in pairs(Binding_Effect_SceneObj) do
			if(param.binding_obj_name) then
				local effect = effectGraph:GetObject(effect_name);
				if(effect and effect:IsValid() == true) then
					local binding_obj = EffectManager.GetObject(param.binding_obj_name);
					if(binding_obj and binding_obj:IsValid() == true) then
						local x, y, z = binding_obj:GetPosition();
						local facing = binding_obj:GetFacing();
						effect:SetPosition(
							x + math_cos(facing + param.offset_angle) * param.offset_radius,
							y + param.offset_y,
							z - math_sin(facing + param.offset_angle) * param.offset_radius
						);
						local bVisible = binding_obj:GetField("visible", false);
						effect:SetVisible(bVisible);
					else
						table_insert(invalid_effectnames, effect_name);
					end
				else
					-- NOTE: strange, the effect object is not valid until the next update timer tick
					-- set the binding to nil in end_function in effectmanager
					--table_insert(invalid_effectnames, effect_name);
				end
			end	
		end
		local _, invalid_effect_name;
		for _, invalid_effect_name in pairs(invalid_effectnames) do
			Binding_Effect_SceneObj[invalid_effect_name] = nil;
		end
	end
end

-- @return effect mini scene name
function EffectManager.GetMinisceneName()
	return "aries_effect";
end

function EffectManager.IsBinding(effect_name)
	if(Binding_Effect_SceneObj[effect_name]) then
		return true;
	end
	return false;
end

-- stop binding the effect, especially useful when the object is away and valid but still want to show the effect in the previous position
function EffectManager.StopBinding(effect_name)
	Binding_Effect_SceneObj[effect_name] = nil;
end

-- create a binding effect at specific object
-- @param params: parameter table as below
	-- asset_file: effect asset file
	-- binding_obj_name: binding object name
	-- start_position: start position, e.x. {19887.11328125, 3.8270180225372, 20021.203125}
	-- (optional)duration_time: effect duration time, if duration_time is nil means permanent
	-- (optional)force_name: if nil use randomly picked unique name
	-- (optional)begin_callback: callback function called at animation begin
	-- (optional)end_callback: callback function called at animation end, AFTER the effect is destroyed
	-- (optional)stage1_time, stage1_callback: time and callback called at time1, function(effect_obj) end
	-- (optional)stage2_time, stage2_callback: time and callback called at time2, function(effect_obj) end
	-- (optional)period, if nil it is rendering frame rate, or it can be milliseconds interval. 
-- NOTE: all callbacks are not invoked if any error happens
function EffectManager.CreateEffect(params)
	local asset_file = params.asset_file;
	local binding_obj_name = params.binding_obj_name;
	local start_position = params.start_position;
	local offset_y = params.offset_y;
	local offset_radius = params.offset_radius;
	local offset_angle = params.offset_angle;
	local duration_time = params.duration_time;
	local force_name = params.force_name;
	local begin_callback = params.begin_callback;
	local end_callback = params.end_callback;
	local elapsedtime_callback = params.elapsedtime_callback;
	local stage1_time = params.stage1_time;
	local stage1_callback = params.stage1_callback;
	local stage2_time = params.stage2_time;
	local stage2_callback = params.stage2_callback;
	if(asset_file == nil) then
		LOG.warn("nil asset_file name at EffectManager.CreateEffect with %s", binding_obj_name);
		return;
	end
	if(not start_position) then
		local binding_obj = EffectManager.GetObject(binding_obj_name);
		if(binding_obj and binding_obj:IsValid() == true) then
			start_position = {binding_obj:GetPosition()};
		else
			LOG.warn("nil start_position and invalid binding object at EffectManager.CreateEffect with %s", binding_obj_name);
			return;
		end
	end
	if(duration_time == nil) then
		duration_time = 100000000;
	elseif(duration_time < 50) then
		LOG.warn("duration time span too short at EffectManager.CreateEffect %s", binding_obj_name);
		return;
	end
	local effect_name = "AriesEffect_"..ParaGlobal.GenerateUniqueID();
	
	if(force_name) then
		effect_name = force_name;
	end
	if(stage1_time == nil) then
		stage1_time = math.floor(duration_time/3);
	end
	if(stage2_time == nil) then
		stage2_time = math.floor(duration_time*2/3);
	end
	-- reset stage1 and stage2
	local enterStage1 = nil;
	local enterStage2 = nil;
	-- NOTE: UIAnimManager.PlayCustomAnimation only follows UI framemove rates, we set the scene position binding to a super high rate timer
	-- set the binding between effect and scene object
	if(binding_obj_name) then
		Binding_Effect_SceneObj[effect_name] = {
			binding_obj_name = binding_obj_name, 
			offset_y = offset_y or 0,
			offset_radius = offset_radius or 0,
			offset_angle = offset_angle or 0,
		};
	end
		
	UIAnimManager.PlayCustomAnimation(duration_time, function(elapsedTime)
		if(type(elapsedtime_callback) == "function") then
			local obj;
			local effectGraph = ParaScene_GetMiniSceneGraph("aries_effect");
			if(effectGraph and effectGraph:IsValid() == true) then
				obj = effectGraph:GetObject(effect_name);
			end
			if(obj and obj:IsValid() == true) then
				elapsedtime_callback(elapsedTime, obj);
			end
			
		end
		if(elapsedTime == 0) then
			-- begin animation, create new effect object
			local effectGraph = ParaScene_GetMiniSceneGraph("aries_effect");
			if(effectGraph and effectGraph:IsValid() == true) then
				effectGraph:DestroyObject(effect_name);
				local asset;
				local obj;
				if(params.ismodel) then
					asset = ParaAsset.LoadStaticMesh("", asset_file);
					obj = ParaScene.CreateMeshPhysicsObject(effect_name, asset, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
					obj:SetField("progress", 1);
				else
					asset = ParaAsset.LoadParaX("", asset_file);
					obj = ParaScene.CreateCharacter(effect_name, asset , "", true, 1.0, 0, 1.0);
				end
				if(obj and obj:IsValid() == true and start_position and start_position[1] and start_position[2]) then
					obj:SetPosition(start_position[1], start_position[2], start_position[3]);
					if(System.options.is_mcworld) then
						obj:SetAttribute(128, true);
					end
					if(params.scale) then
						obj:SetScale(params.scale);
					end
					if(params.facing) then
						obj:SetFacing(params.facing);
					end
					if(params.replaceable_texture_effect) then
						obj:SetReplaceableTexture(2, ParaAsset.LoadTexture("", params.replaceable_texture_effect, 1));
					end
					if(params.speed) then
						obj:SetField("Speed Scale", params.speed);
					end
					effectGraph:AddChild(obj);
					if(begin_callback) then
						begin_callback(obj);
					end
				end
			end
		elseif(elapsedTime > stage1_time and elapsedTime < duration_time and enterStage1 == nil) then
			-- enter animation stage 1
			enterStage1 = true;
			local effectGraph = ParaScene_GetMiniSceneGraph("aries_effect");
			if(effectGraph and effectGraph:IsValid() == true) then
				local obj = effectGraph:GetObject(effect_name);
				if(obj and obj:IsValid() == true) then
					if(stage1_callback) then
						stage1_callback(obj);
					end
				end
			end
		elseif(elapsedTime > stage2_time and elapsedTime < duration_time and enterStage2 == nil) then
			-- enter animation stage 2
			enterStage2 = true;
			local effectGraph = ParaScene_GetMiniSceneGraph("aries_effect");
			if(effectGraph and effectGraph:IsValid() == true) then
				local obj = effectGraph:GetObject(effect_name);
				if(obj and obj:IsValid() == true) then
					if(stage2_callback) then
						stage2_callback(obj);
					end
				end
			end
		elseif(elapsedTime == duration_time) then
			-- end animation, destroy effect object
			local effectGraph = ParaScene_GetMiniSceneGraph("aries_effect");
			if(effectGraph and effectGraph:IsValid() == true) then
				effectGraph:DestroyObject(effect_name);
			end
			if(end_callback) then
				end_callback();
			end
			-- reset the effect object binding
			Binding_Effect_SceneObj[effect_name] = nil;
		end
	end, effect_name, params.period);
end

-- check if the effect object is valid in the mini scene
-- @param forcename: speficied in PlayEffect
function EffectManager.IsEffectValid(forcename)
	if(forcename) then
		local effectGraph = ParaScene_GetMiniSceneGraph("aries_effect");
		if(effectGraph and effectGraph:IsValid() == true) then
			local obj = effectGraph:GetObject(forcename);
			if(obj and obj:IsValid() == true) then
				return true;
			end
		end
	end
	return false;
end

-- destroy effect and the custom animation object
-- @param forcename: speficied in PlayEffect
function EffectManager.DestroyEffect(forcename)
	if(forcename) then
		local effectGraph = ParaScene_GetMiniSceneGraph("aries_effect");
		local obj = effectGraph:GetObject(forcename);
		if(obj and obj:IsValid()) then
			UIAnimManager.StopCustomAnimation(forcename);
			effectGraph:DestroyObject(obj);
		end
	end
end

-- destroy effect and the custom animation object
-- @param obj: effect object
function EffectManager.DestroyEffectObjIfValid(obj)
	if(obj and obj:IsValid()) then
		local effectGraph = ParaScene_GetMiniSceneGraph("aries_effect");
		if(effectGraph and effectGraph:IsValid()) then
			UIAnimManager.StopCustomAnimation(obj.name);
			effectGraph:DestroyObject(obj);
		end
	end
end