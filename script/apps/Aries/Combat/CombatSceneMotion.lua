--[[
Title: CombatSceneMotion
Author(s): Leio
Date: 2011/04/07
Desc:

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Combat/CombatSceneMotion.lua");
local CombatSceneMotion = commonlib.gettable("MotionEx.CombatSceneMotion");

CombatSceneMotion.StopMotion();

NPL.load("(gl)script/apps/Aries/Combat/CombatSceneMotion.lua");
local CombatSceneMotion = commonlib.gettable("MotionEx.CombatSceneMotion");
NPL.load("(gl)script/apps/Aries/Combat/CombatSceneMotionHelper.lua");
local CombatSceneMotionHelper = commonlib.gettable("MotionEx.CombatSceneMotionHelper");
CombatSceneMotionHelper.Load();
local arena_params = CombatSceneMotionHelper.FindArena("config/Aries/WorldData/61HaqiTown.Arenas_Mobs.xml","10000_water3");

local x,y,z = ParaScene.GetPlayer():GetPosition();
arena_params.x = x;
arena_params.y = y;
arena_params.z = z;
CombatSceneMotionHelper.ShowArena(arena_params,function(msg)
	--commonlib.echo(msg.arena_infos);
	local k,v;
	for k,v in ipairs(msg.arena_infos) do
		local s = string.format("%.2f  %.2f",v.facing,v.facing +math.pi);
		commonlib.echo(s);
	end
	CombatSceneMotionHelper.Clear();
	CombatSceneMotion.PlayMotion("1",msg.arena_infos,function()
		--_guihelper.MessageBox("end");
	end)
end);

NPL.load("(gl)script/apps/Aries/Combat/CombatSceneMotionHelper.lua");
local CombatSceneMotionHelper = commonlib.gettable("MotionEx.CombatSceneMotionHelper");
NPL.load("(gl)script/apps/Aries/Combat/CombatSceneMotion.lua");
local CombatSceneMotion = commonlib.gettable("MotionEx.CombatSceneMotion");
local x,y,z = ParaScene.GetPlayer():GetPosition();
local arena_infos = CombatSceneMotionHelper.GetAbsoluteArenaInfo(x,y,z)
CombatSceneMotion.PlayMotion("1",arena_infos,function()
	--_guihelper.MessageBox("end");
end)
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/MotionEx/MotionTypes.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/CCS/ccs.lua");
local CCS = commonlib.gettable("System.UI.CCS");
local MotionTypes = commonlib.gettable("MotionEx.MotionTypes");
local CombatSceneMotion = commonlib.gettable("MotionEx.CombatSceneMotion");
CombatSceneMotion.filename = "config/Aries/Cameras/CombatSceneMotions.xml";
CombatSceneMotion.interval = 10;
CombatSceneMotion.motion_pools = {};
CombatSceneMotion.obj_maps = {};
CombatSceneMotion.timer_maps = {};
CombatSceneMotion.callbackFunc = nil;-- end callback
CombatSceneMotion.mini_scene_combatmotion = "mini_scene_combatmotion";
local ParaScene_GetMiniSceneGraph = ParaScene.GetMiniSceneGraph;

function CombatSceneMotion.ForceLoadAllMotions()
	local self = CombatSceneMotion;
	self.LoadAllMotions(self.filename,true);
end
function CombatSceneMotion.LoadAllMotions(filename,forceLoad)
	local self = CombatSceneMotion;
	if(not filename)then return end
	function load()
		local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
		for node in commonlib.XPath.eachNode(xmlRoot, "//combatmotions/motion") do
			if(node.attr and node.attr.id)then
				local id = node.attr.id;
				local id_node;
				for id_node in string.gfind(id, "[^|]+") do
					self.motion_pools[id_node] = node;
				end
			end
		end
	end
	if(forceLoad or not self.reload)then
		self.reload = true;
		load();
	end
end
function CombatSceneMotion.CreateCaption(txt)
	local self = CombatSceneMotion;
	local _parent=ParaUI.GetUIObject("CombatSceneMotion.CreateCaption_container");
	local _, _, screenWidth, screenHeight = ParaUI.GetUIObject("root"):GetAbsPosition();
	self.DestroyCaption();
	if(_parent:IsValid() == false)then		
		local _this = ParaUI.CreateUIObject("container","CombatSceneMotion.CreateCaption_container", "_ctb", 0, 0, screenWidth, 80)
		_this.background="Texture/whitedot.png";
		_guihelper.SetUIColor(_this, "37 16 5");
		_this:AttachToRoot();
		_this.zorder = 1000;
		_parent = _this;
		
		_this = ParaUI.CreateUIObject("text", "CombatSceneMotion.CreateCaption_container_text", "_lt", 10,15,screenWidth-10,56)
		_this.text = txt or "";
		_this.font="System;16";
		_guihelper.SetFontColor(_this, "255 255 255");
		_this.shadow = false;
		_guihelper.SetUIFontFormat(_this,5);
		_parent:AddChild(_this);
	end

	local _parent=ParaUI.GetUIObject("CombatSceneMotion.CreateCaption_text_container_top");
	if(_parent:IsValid() == false)then
		local _this = ParaUI.CreateUIObject("container","CombatSceneMotion.CreateCaption_text_container_top", "_ct", -screenWidth/2, -screenHeight/2, screenWidth, 80)
		_this.background="Texture/whitedot.png";
		_guihelper.SetUIColor(_this, "37 16 5");
		_this:AttachToRoot();
	end
end
function CombatSceneMotion.UpdateCaption(txt)
	local self = CombatSceneMotion;
	txt = txt or "";
	local _this = ParaUI.GetUIObject("CombatSceneMotion.CreateCaption_container_text");
	if(_this:IsValid())then
		_this.text = txt;	
	end
end
function CombatSceneMotion.DestroyCaption()
	local self = CombatSceneMotion;
	ParaUI.Destroy("CombatSceneMotion.CreateCaption_container");
	ParaUI.Destroy("CombatSceneMotion.CreateCaption_text_container_top");
end
function CombatSceneMotion.UpdateCamera(props_param)
	local self = CombatSceneMotion;
	if(not props_param)then return end
	local x,y,z = props_param.x,props_param.y,props_param.z;
	local CameraObjectDistance,CameraLiftupAngle,CameraRotY = props_param.CameraObjectDistance,props_param.CameraLiftupAngle,props_param.CameraRotY;
	local att = ParaCamera.GetAttributeObject();
	if(x and y and z)then
		ParaCamera.SetLookAtPos(x, y, z)
	end
	if(CameraObjectDistance)then
		att:SetField("CameraObjectDistance", CameraObjectDistance);
	end
	if(CameraLiftupAngle)then
		att:SetField("CameraLiftupAngle", CameraLiftupAngle);
	end
	if(CameraRotY)then
		att:SetField("CameraRotY", CameraRotY);
	end
end
function CombatSceneMotion.GetEntity(effect_name)
	local self = CombatSceneMotion;
	if(not effect_name)then return end
	local effectGraph = ParaScene_GetMiniSceneGraph(self.mini_scene_combatmotion);
	local obj = effectGraph:GetObject(effect_name);
	return obj;
end
function CombatSceneMotion.CreateEntity(effect_name,props_param)
	local self = CombatSceneMotion;
	if(not effect_name or not props_param)then return end
	local effectGraph = ParaScene_GetMiniSceneGraph(self.mini_scene_combatmotion);
	local asset_file =  props_param.asset;
	local x,y,z = props_param.x,props_param.y,props_param.z;
	local facing = props_param.facing;
	local scale = props_param.scale;
	local ismodel = props_param.ismodel;
	local animation = props_param.animation;
	if(not asset_file)then
		return
	end
	local obj;
	if(effectGraph:IsValid()) then
		effectGraph:DestroyObject(effect_name);
		if(ismodel) then
			asset = ParaAsset.LoadStaticMesh("", asset_file);
			obj = ParaScene.CreateMeshPhysicsObject(effect_name, asset, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
			obj:SetField("progress", 1);
		else
			asset = ParaAsset.LoadParaX("", asset_file);
			obj = ParaScene.CreateCharacter(effect_name, asset , "", true, 1.0, 0, 1.0);
			Map3DSystem.Animation.PlayAnimationFile(animation, obj);

		end
		if(obj and obj:IsValid() == true) then
			if(System.options.is_mcworld) then
				obj:SetAttribute(128, true);
			end
			obj:SetPosition(x, y, z);
			if(scale) then
				obj:SetScale(scale);
			end
			if(facing) then
				obj:SetFacing(facing);
			end
			effectGraph:AddChild(obj);

			local ccsinfo = props_param.ccsinfo;
			if(ccsinfo and not ismodel)then
				ccsinfo = commonlib.LoadTableFromString(ccsinfo);
				if(ccsinfo)then
					CCS.DB.ApplyCartoonfaceInfoString(obj, ccsinfo.cartoonface_info);
					CCS.Predefined.ApplyFacialInfoString(obj, ccsinfo.facial_info);
					local npcCharChar = obj:ToCharacter();
					local i;
					for i = 0, 45 do
						npcCharChar:SetCharacterSlot(i, ccsinfo.equips[i] or 0);
					end
				end
			end
		end
	end
	self.obj_maps[effect_name] = effect_name;
end
function CombatSceneMotion.DestroyEntity(effect_name)
	local self = CombatSceneMotion;
	if(not effect_name)then return end
	local effectGraph = ParaScene_GetMiniSceneGraph(self.mini_scene_combatmotion);
	if(effectGraph:IsValid()) then
		effectGraph:DestroyObject(effect_name);
	end
end
function CombatSceneMotion.UpdateEntity(effect_name,props_param)
	local self = CombatSceneMotion;
	if(not effect_name or not props_param)then return end
	local x,y,z = props_param.x,props_param.y,props_param.z;
	local facing = props_param.facing;
	local scale = props_param.scale;
	local effectGraph = ParaScene_GetMiniSceneGraph(self.mini_scene_combatmotion);
	if(effectGraph:IsValid()) then
		local obj = effectGraph:GetObject(effect_name);
		if(obj and obj:IsValid())then
			if(x and y and z)then
				obj:SetPosition(x,y,z);
			end
			if(facing)then
				obj:SetFacing(facing);
			end
			if(scale)then
				obj:SetScale(scale);
			end
		end
	end
end
function CombatSceneMotion.HookKeyDown()
	local self = CombatSceneMotion;
	local esc_pressed = ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_ESCAPE) or ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_SPACE);
	if(esc_pressed)then
		self.StopMotion();
	end	
end
function CombatSceneMotion.StopMotion()
	local self = CombatSceneMotion;
	 self.DestroyCaption();
	 local k,v;
	 for k,v in pairs(self.obj_maps) do
		self.DestroyEntity(v);
	 end
	 local k,v;
	 for k,v in pairs(self.timer_maps) do
		v:Change();
	 end
	 if(self.callbackFunc)then
		self.callbackFunc();
		self.callbackFunc = nil;
	 end
	 self.obj_maps = {};
	 self.timer_maps = {};
end
function CombatSceneMotion.HasMotion(id)
	local self = CombatSceneMotion;
	self.LoadAllMotions(self.filename);
	if(not id)then return end
	local xmlnodes = self.motion_pools[id];
	if(xmlnodes)then
		return true;
	end
end
--[[
	arena_infos = {
		[1] = {x,y,z,facing},
		[2] = {x,y,z,facing},
		...
		[9] = {x,y,z,facing},-- arena center point
	}
--]]
function CombatSceneMotion.PlayMotion(id,arena_infos,callbackFunc)
	local self = CombatSceneMotion;
	self.LoadAllMotions(self.filename);
	if(not id)then return end
	local xmlnodes = self.motion_pools[id];
	if(not xmlnodes or not arena_infos)then 
		return 
	end
	self.StopMotion();
	local total_duration = tonumber(xmlnodes.attr.duration);
	local cur_duration = 0;
	

	local mytimer = commonlib.Timer:new({callbackFunc = function(timer)
			if(cur_duration > total_duration)then
				timer:Change();	
				--clear all
				self.StopMotion();
			end
			self.HookKeyDown();
			cur_duration = cur_duration +  timer:GetDelta(200);
	end})
	self.callbackFunc = callbackFunc;
	mytimer:Change(0,self.interval);
	self.timer_maps[mytimer] = mytimer;

	local getvalue = function(motion_handler,run_time,duration, props_param,prop)
		if(not motion_handler or not props_param or not prop)then return end
		local begin_value = props_param["begin_"..prop];
		local cur_value = props_param["cur_"..prop];
		local end_value = props_param["end_"..prop];
		if(begin_value and cur_value and end_value and (begin_value ~= end_value))then
			local begin = begin_value;
			local change = end_value - begin_value;

			local value = motion_handler( run_time , begin , change , duration );	
			props_param["cur_"..prop] = value;
			return value;
		end
	end
	local get_start_end = function(s)
		if(not s)then return end
		if(string.find(s,"|"))then
			local b,e = string.match(s,"(.+)|(.+)");
			return tonumber(b),tonumber(e);
		else
			return tonumber(s);
		end
	end
	--获取站位坐标
	local get_pos = function(index)
		if(not index)then return end
		local node = arena_infos[index];
		if(node)then
			return node.x,node.y,node.z;
		end
	end
	--获取站位点默认值
	local get_default_facing = function(index)
		if(not index)then return end
		local node = arena_infos[index];
		if(node)then
			return node.facing;
		end
	end
	--获取绝对坐标
	local get_pos_null_index = function(s)
		if(not s)then return end
		if(string.find(s,"|"))then
			local b_x,b_y,b_z,e_x,e_y,e_z = string.match(s,"(.+),(.+),(.+)|(.+),(.+),(.+)");
			return tonumber(b_x),tonumber(b_y),tonumber(b_z),tonumber(e_x),tonumber(e_y),tonumber(e_z);
		else
			local b_x,b_y,b_z = string.match(s,"(.+),(.+),(.+)");
			return tonumber(b_x),tonumber(b_y),tonumber(b_z);
		end
	end
	local node;
	for node in commonlib.XPath.eachNode(xmlnodes, "//puppet") do
		local index = node.attr.index;
		local position = node.attr.position;
		local facing = node.attr.facing;
		local scale = node.attr.scale;
		local ismodel = node.attr.ismodel;
		local animation = node.attr.animation;
		local ccsinfo = node.attr.ccsinfo;
		--local animation = node.attr.animation;
		--local beep = node.attr.beep;
		if(ismodel == "true" or ismodel == "True")then
			ismodel = true;
		end
		local starttime = tonumber(node.attr.starttime);
		local duration = tonumber(node.attr.duration);
		--距离百分比
		local percent = tonumber(node.attr.percent) or 100;
		percent = math.min(percent,100);
		local asset = node.attr.asset;

		local start_index,end_index;
		local begin_x,end_x;
		local begin_y,end_y;
		local begin_z,end_z;
		local begin_facing,end_facing;
		local begin_scale,end_scale;

		
		
		start_index, end_index = get_start_end(index);
		begin_facing,end_facing = get_start_end(facing);
		begin_scale,end_scale = get_start_end(scale);
		
		if(not begin_facing and not end_facing)then
			local default_facing = get_default_facing(start_index) or 0;
			begin_facing,end_facing = default_facing;
		end
		--如果有开始点
		if(start_index)then
			begin_x,begin_y,begin_z = get_pos(start_index);
		end
		--如果有结束点
		if(end_index)then
			end_x,end_y,end_z = get_pos(end_index);
			end_x = begin_x + (end_x - begin_x) * (percent/100);
			end_y = begin_y + (end_y - begin_y) * (percent/100);
			end_z = begin_z + (end_z - begin_z) * (percent/100);
		end
		--绝对坐标
		if(position)then
			begin_x,begin_y,begin_z,end_x,end_y,end_z = get_pos_null_index(position);
			start_index = start_index or 9;
			--center info
			local center = arena_infos[start_index] or {};
			local center_x,center_y,center_z = center.x,center.y,center.z;
			if(begin_x)then begin_x = begin_x + center_x; end
			if(begin_y)then begin_y = begin_y + center_y; end
			if(begin_z)then begin_z = begin_z + center_z; end
			if(end_x)then end_x = end_x + center_x; end
			if(end_y)then end_y = end_y + center_y; end
			if(end_z)then end_z = end_z + center_z; end
		end
		local motiontypes = node.attr.motiontypes or "None";
		local motion_handler = MotionTypes[motiontypes];
		
		local run_time = 0;
		local name = "combatmotion_"..ParaGlobal.GenerateUniqueID();
		local props_param = {
			begin_x = begin_x,cur_x = begin_x,end_x = end_x,
			begin_y = begin_y,cur_y = begin_y,end_y = end_y,
			begin_z = begin_z,cur_z = begin_z,end_z = end_z,
			begin_facing = begin_facing,cur_facing = begin_facing,end_facing = end_facing,
			begin_scale = begin_scale,cur_scale = begin_scale,end_scale = end_scale,
			--animation = animation,
			--beep = beep,
			--has_animation = false,
			--has_beep = false,
		}
		local mytimer = commonlib.Timer:new({callbackFunc = function(timer)
			if(run_time == 0)then
				--start
				self.CreateEntity(name,{
					x = props_param.begin_x,
					y = props_param.begin_y,
					z = props_param.begin_z,
					facing = props_param.begin_facing,
					scale = props_param.begin_scale,
					asset = asset,
					ismodel = ismodel,
					animation = animation,
					ccsinfo = ccsinfo,
				});
				--if(props_param.animation and not props_param.has_animation)then
					--props_param.has_animation = true;
					--local obj = self.GetEntity(name);
					--if(obj and obj:IsValid())then
						--System.Animation.PlayAnimationFile(props_param.has_animation, obj);
					--end
				--end
				--if(props_param.beep and not props_param.has_beep)then
					--props_param.has_beep = true;
					--headon_speech.Speak(name, beep, math.floor(duration/1000));
				--end
			elseif(run_time < duration)then
				--update
				if(motion_handler)then
					getvalue(motion_handler,run_time, duration, props_param, "x");
					getvalue(motion_handler,run_time, duration, props_param, "y");	
					getvalue(motion_handler,run_time, duration, props_param, "z");	
					getvalue(motion_handler,run_time, duration, props_param, "facing");	
					getvalue(motion_handler,run_time, duration, props_param, "scale");	
					--commonlib.echo(props_param);
					self.UpdateEntity(name,{
						x = props_param.cur_x,
						y = props_param.cur_y,
						z = props_param.cur_z,
						facing = props_param.cur_facing,
						scale = props_param.cur_scale,
						asset = asset,
						ismodel = ismodel,
					});
				end
			else
				--end
				self.UpdateEntity(name,{
					x = props_param.end_x,
					y = props_param.end_y,
					z = props_param.end_z,
					facing = props_param.end_facing,
					scale = props_param.end_scale,
					asset = asset,
					ismodel = ismodel,
				});
				self.DestroyEntity(name);
				timer:Change();
			end
			run_time = run_time + timer:GetDelta(200);
		end})
		mytimer:Change(starttime, self.interval)
		self.timer_maps[mytimer] = mytimer;
	end
	local node;
	for node in commonlib.XPath.eachNode(xmlnodes, "//camera") do
		local index = node.attr.index;
		local position = node.attr.position;
		local CameraObjectDistance = node.attr.CameraObjectDistance;
		local CameraLiftupAngle = node.attr.CameraLiftupAngle;
		local CameraRotY = node.attr.CameraRotY;
		local starttime = tonumber(node.attr.starttime);
		local duration = tonumber(node.attr.duration);

		local start_index,end_index;
		local begin_x,end_x;
		local begin_y,end_y;
		local begin_z,end_z;
		local begin_CameraObjectDistance,end_CameraObjectDistance;
		local begin_CameraLiftupAngle,end_CameraLiftupAngle;
		local begin_CameraRotY,end_CameraRotY;

		start_index, end_index = get_start_end(index);
		begin_CameraObjectDistance,end_CameraObjectDistance = get_start_end(CameraObjectDistance);
		begin_CameraLiftupAngle,end_CameraLiftupAngle = get_start_end(CameraLiftupAngle);
		begin_CameraRotY,end_CameraRotY = get_start_end(CameraRotY);
		if(not begin_CameraObjectDistance and not end_CameraObjectDistance)then
			begin_CameraObjectDistance,end_CameraObjectDistance = 0,0;
		end
		if(not begin_CameraLiftupAngle and not end_CameraLiftupAngle)then
			begin_CameraLiftupAngle,end_CameraLiftupAngle = 0,0;
		end
		if(not begin_CameraRotY and not end_CameraRotY)then
			local default_facing = get_default_facing(start_index) or 0;
			begin_CameraRotY,end_CameraRotY = default_facing,default_facing;
		end
		
		local motiontypes = node.attr.motiontypes or "None";
		local motion_handler = MotionTypes[motiontypes];
		--距离百分比
		local percent = tonumber(node.attr.percent) or 100;
		percent = math.min(percent,100);

		--如果有开始点
		if(start_index)then
			begin_x,begin_y,begin_z = get_pos(start_index);
		end
		--如果有结束点
		if(end_index)then
			end_x,end_y,end_z = get_pos(end_index);
			end_x = begin_x + (end_x - begin_x) * (percent/100);
			end_y = begin_y + (end_y - begin_y) * (percent/100);
			end_z = begin_z + (end_z - begin_z) * (percent/100);
		end
		--绝对坐标
		if(position)then
			begin_x,begin_y,begin_z,end_x,end_y,end_z = get_pos_null_index(position);

			start_index = start_index or 9;
			--center info
			local center = arena_infos[start_index] or {};
			local center_x,center_y,center_z = center.x,center.y,center.z;

			if(begin_x)then begin_x = begin_x + center_x; end
			if(begin_y)then begin_y = begin_y + center_y; end
			if(begin_z)then begin_z = begin_z + center_z; end
			if(end_x)then end_x = end_x + center_x; end
			if(end_y)then end_y = end_y + center_y; end
			if(end_z)then end_z = end_z + center_z; end
		end
		local run_time = 0;
		local props_param = {
			begin_x = begin_x,cur_x = begin_x,end_x = end_x,
			begin_y = begin_y,cur_y = begin_y,end_y = end_y,
			begin_z = begin_z,cur_z = begin_z,end_z = end_z,
			begin_CameraObjectDistance = begin_CameraObjectDistance,cur_CameraObjectDistance = begin_CameraObjectDistance,end_CameraObjectDistance = end_CameraObjectDistance,
			begin_CameraLiftupAngle = begin_CameraLiftupAngle,cur_CameraLiftupAngle = begin_CameraLiftupAngle,end_CameraLiftupAngle = end_CameraLiftupAngle,
			begin_CameraRotY = begin_CameraRotY,cur_CameraRotY = begin_CameraRotY,end_CameraRotY = end_CameraRotY,
		}
		local mytimer = commonlib.Timer:new({callbackFunc = function(timer)
			if(run_time == 0)then
				--start
				self.UpdateCamera({
					x = props_param.begin_x,
					y = props_param.begin_y,
					z = props_param.begin_z,
					CameraObjectDistance = props_param.begin_CameraObjectDistance,
					CameraLiftupAngle = props_param.begin_CameraLiftupAngle,
					CameraRotY = props_param.begin_CameraRotY,
				});
			elseif(run_time < duration)then
				--update
				if(motion_handler)then
					getvalue(motion_handler,run_time, duration, props_param, "x");
					getvalue(motion_handler,run_time, duration, props_param, "y");	
					getvalue(motion_handler,run_time, duration, props_param, "z");	
					getvalue(motion_handler,run_time, duration, props_param, "CameraObjectDistance");	
					getvalue(motion_handler,run_time, duration, props_param, "CameraLiftupAngle");	
					getvalue(motion_handler,run_time, duration, props_param, "CameraRotY");	
					self.UpdateCamera({
						x = props_param.cur_x,
						y = props_param.cur_y,
						z = props_param.cur_z,
						CameraObjectDistance = props_param.cur_CameraObjectDistance,
						CameraLiftupAngle = props_param.cur_CameraLiftupAngle,
						CameraRotY = props_param.cur_CameraRotY,
					});
				end
			else
				--end
				self.UpdateCamera({
					x = props_param.end_x,
					y = props_param.end_y,
					z = props_param.end_z,
					CameraObjectDistance = props_param.end_CameraObjectDistance,
					CameraLiftupAngle = props_param.end_CameraLiftupAngle,
					CameraRotY = props_param.end_CameraRotY,
				});
				timer:Change();
			end
			run_time = run_time + timer:GetDelta(200);
		end})
		mytimer:Change(starttime, self.interval)
		self.timer_maps[mytimer] = mytimer;
	end
	local run_time = 0;
	local node;
	local time_list = {};
	for node in commonlib.XPath.eachNode(xmlnodes, "//captions/item") do
		local time = node.attr.time;
		local text = node.attr.text;
		if(node[1])then
			text = node[1];
		end
		local minutes,seconds = string.match(time,"(.+):(.+)");
		minutes = tonumber(minutes) or 0;
		seconds = tonumber(seconds) or 0;
		time = (minutes * 60 + seconds) * 1000;

		table.insert(time_list,{
			time = time,
			text = text,
			next_time = nil,
		});
	end
	local k,v;
	for k,v in ipairs(time_list) do
		local next_node = time_list[k+1];
		if(next_node)then
			v.next_time = next_node.time;
		end
	end
	local index = 1;
	local mytimer = commonlib.Timer:new({callbackFunc = function(timer)
		local node = time_list[index];
		local txt;
		if(node)then
			txt = node.text;
		end
		if(node and node.next_time)then
			if(run_time >= node.next_time)then
				index = index + 1;
				if(time_list[index])then
					txt = time_list[index].text;
				end
			end
		end
		if(run_time == 0)then
			self.CreateCaption(txt);
		elseif(run_time < total_duration)then
			--update
			self.UpdateCaption(txt);
		else
			--end
			self.UpdateCaption(txt);
			self.DestroyCaption(txt);
			timer:Change();
		end
		run_time = run_time + timer:GetDelta(200);
	end})
	mytimer:Change(0, self.interval)
	self.timer_maps[mytimer] = mytimer;
	--audio
	local node;

	for node in commonlib.XPath.eachNode(xmlnodes, "//audio") do
		local assetfile = node.attr.assetfile;
		local run_time = 0;
		local starttime = tonumber(node.attr.starttime);
		local duration = tonumber(node.attr.duration);
		local audio_src = AudioEngine.CreateGet(assetfile)
		local mytimer = commonlib.Timer:new({callbackFunc = function(timer)
			if(run_time == 0)then
				if(audio_src)then
					audio_src.file = assetfile;
					audio_src:play();
				end
			elseif(run_time < duration)then
				--update
				
			else
				--end
				if(audio_src)then
					audio_src:stop();
				end
				timer:Change();
			end
			run_time = run_time + timer:GetDelta(200);
		end})
		mytimer:Change(starttime, self.interval)
		self.timer_maps[mytimer] = mytimer;
	end
end
