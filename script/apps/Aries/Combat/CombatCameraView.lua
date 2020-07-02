--[[
Title: CombatCameraView
Author(s): Leio
Date: 2010/06/17
Desc:

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Combat/CombatCameraView.lua");
local CombatCameraView = commonlib.gettable("MotionEx.CombatCameraView");
CombatCameraView.ForceLoadAllCameras()

NPL.load("(gl)script/apps/Aries/Combat/CombatCameraView.lua");
local CombatCameraView = commonlib.gettable("MotionEx.CombatCameraView");
CombatCameraView.DoOutPut()
------------------------------------------------------------
--]]

NPL.load("(gl)script/apps/Aries/Scene/EffectManager.lua");
NPL.load("(gl)script/ide/STL.lua");
NPL.load("(gl)script/ide/MotionEx/MotionLine.lua");
NPL.load("(gl)script/ide/MotionEx/MotionPlayer.lua");

local MotionLine = commonlib.gettable("MotionEx.MotionLine");
local MotionPlayer = commonlib.gettable("MotionEx.MotionPlayer");
local CombatCameraView = commonlib.gettable("MotionEx.CombatCameraView");
CombatCameraView.filename = "config/Aries/Cameras/Cameras.xml";
local ParaGlobal_timeGetTime = ParaGlobal.timeGetTime

CombatCameraView.states = {
	"battle_point", 
	"select_spell",
	"pre_battle",
	"battle",
}
CombatCameraView.motion_pools = {};
CombatCameraView.enabled = true;
function CombatCameraView.DoStop()
	local self  = CombatCameraView;
	if(self.motion_player)then 
		self.motion_player:Stop();
	end
end
--标记战斗技能的动画是否 是在MotionXmlToTable中触发
--如果是 忽略CombatCameraView.StopCurMotion()
--因为技能动画时间轴 并不和MotionXmlToTable时间轴一致
--会出现以下情况：MotionXmlToTable已经在播放下一个技能的摄影机动画
--				但是 SpellCast中上一个时间轴还没有停止
--会造成的问题：中断了目前摄影机的动画
--UIAnimManager.PlayCustomAnimation(spell_duration, function(elapsedTime)
	--if(elapsedTime == spell_duration) then
		--if(finish_callback) then
			--if(not bSkipCamera) then
				--CombatCameraView.StopCurMotion();
			--end
			--finish_callback();
		--end
	--end
--end);
function CombatCameraView.PlayIn_MotionXmlToTable(b)
	local self  = CombatCameraView;
	self.is_play_in_MotionXmlToTable = b;
end
function CombatCameraView.IsPlayIn_MotionXmlToTable()
	local self  = CombatCameraView;
	return self.is_play_in_MotionXmlToTable
end
--播放动画
function CombatCameraView.DoStart(nodes,callbackFunc)
	local self  = CombatCameraView;
	if(not nodes)then return end
	if(not self.motion_player)then 
		self.motion_player = MotionPlayer:new();
	end
	ParaCamera.GetAttributeObject():SetField("PhysicsGroupMask", 268435456); 
	--CombatCameraView.DoStop();
	local keyFrames = MotionLine.ChageToKeyFrames(nodes);
	if(not keyFrames)then return end;
	self.motion_player:AddEventListener("play",function()
		--commonlib.echo("play");
	end,{});
	self.motion_player:AddEventListener("stop",function()
		--commonlib.echo("stop");
		--if(callbackFunc)then
			--callbackFunc();
		--end
	end,{});
	self.motion_player:AddEventListener("end",function()
		--commonlib.echo("end");
		ParaCamera.GetAttributeObject():SetField("PhysicsGroupMask", 4294967295);
		if(callbackFunc)then
			callbackFunc();
		end
	end,{});
	self.motion_player:AddEventListener("update",function(funcHolder,event)
		--commonlib.echo("update");
		--commonlib.echo(event.time);
	end,{});

	local motionLine = MotionLine:new{
		type = "aries_camera",
	}
	--commonlib.echo(keyFrames);
	motionLine:AddKeyFrames(keyFrames);
	--clear old frames
	self.motion_player:Clear();
	self.motion_player:AddMotionLine(motionLine);
	self.motion_player:Play();
end
function CombatCameraView.StopCurMotion()
	local self = CombatCameraView;
	if(self.IsPlayIn_MotionXmlToTable())then
		return
	end
	if(self.motion_player)then
		--self.motion_player:Stop();
		self.motion_player:Pause();
	end
	NPL.load("(gl)script/ide/Director/SpellCameraHelper.lua");
	local SpellCameraHelper = commonlib.gettable("Director.SpellCameraHelper");
	SpellCameraHelper.Stop();
end
--[[
local id = "select_spell";
local start_point_pos = { 239.7, 1.3, 256.7 };
local end_point_pos = { 261, 1.3, 243 };
local ground_pos = { 250.33, 2.77, 249.84 };
local args = {
	start_point_pos = start_point_pos,
	end_point_pos = end_point_pos,
	ground_pos = ground_pos,
	nomotion = false,--直接跳转到动画的结束点
	spell_config_file = spell_config_file,
}
local args = {
	start_point_pos = start_point_pos, --开始位置
	end_point_pos = end_point_pos, -- 结束位置
	ground_pos = ground_pos, -- 圆盘位置
	miniscene_name = miniscene_name,--跟随物体的mini scene
	lookat_effect_force_name = force_name,-- 跟随物体的名称
	spell_config_file = spell_config_file,-- 特效的路径
	caster_slotid = caster_slotid,--开始的索引
	target_slotids = target_slotids,--结束的索引列表
	nomotion = false,--直接跳转到动画的结束点
}
CombatCameraView.PlayMotion(id,args,function()
	_guihelper.MessageBox("over");
end)
--]]
function CombatCameraView.PlayMotion(id,args,callbackFunc)
	local self = CombatCameraView;
	--commonlib.echo("=======PlayMotion");
	--commonlib.echo(id);
	--commonlib.echo(args.spell_config_file);
	--commonlib.echo(args);
	--commonlib.echo(self.enabled);
	if(not args or not args.start_point_pos or not args.end_point_pos or not args.ground_pos)then return end
	if(not self.enabled)then return end
	NPL.load("(gl)script/ide/Director/SpellCameraHelper.lua");
	local SpellCameraHelper = commonlib.gettable("Director.SpellCameraHelper");
	--启用新版摄影机播放
	if(SpellCameraHelper.HasCamera(args.spell_config_file))then
		SpellCameraHelper.Play(args);
		return
	end
	self.LoadAllCameras(self.filename,false);

	--id
	--filename
	--default_combat_name
	local filename = self.GetFileName(args.spell_config_file);
	id = id or filename;

	local mcmlNode = self.GetXmlNodeByID(string.lower(id));

	local default_combat_name = "default_combat";
	local default_combat_mcmlNode = self.GetXmlNodeByID(string.lower(default_combat_name));

	mcmlNode = mcmlNode or default_combat_mcmlNode;
	if(not mcmlNode)then
		mcmlNode = self.GetRandomMotion();
	end
	if(mcmlNode and args)then
		args.start_facing = math.atan2((args.ground_pos[1] - args.start_point_pos[1]), (args.ground_pos[3] - args.start_point_pos[3])) - math.pi/2;
		args.end_facing = math.atan2((args.ground_pos[1] - args.end_point_pos[1]), (args.ground_pos[3] - args.end_point_pos[3])) - math.pi/2;

		CombatCameraView.SetFollowObjID(args.lookat_effect_force_name);
		CombatCameraView.SetMinisceneName(args.miniscene_name);

		local mcmlNode = Map3DSystem.mcml.buildclass(mcmlNode);
		if(mcmlNode)then
			mcmlNode.start_facing = args.start_facing;
			mcmlNode.end_facing = args.end_facing;
			mcmlNode.start_point_pos = args.start_point_pos;
			mcmlNode.end_point_pos = args.end_point_pos;
			mcmlNode.ground_pos = args.ground_pos;
			mcmlNode.caster_slotid = args.caster_slotid;
			mcmlNode.target_slotids = args.target_slotids;
			local nodes;
			if(mcmlNode.name == "camera_v2")then
				nodes = Map3DSystem.mcml_controls.aries_camera_2.create("PlayMotion", mcmlNode, nil, _parent, 10, 10, 400, 400)
			else
				nodes = Map3DSystem.mcml_controls.aries_camera.create("PlayMotion", mcmlNode, nil, _parent, 10, 10, 400, 400)
			end
			if(nodes)then
				if(args.nomotion)then
					local node = nodes[2];
					if(node)then
						node.duration = 10;
						node.FrameType = "None";
						nodes = {
							{duration = 0},
							node,
						};
					end
				end
				--commonlib.echo("=======nodes");
				--commonlib.echo(nodes);
				self.DoStart(nodes,callbackFunc)
			end
		end
	end
end
function CombatCameraView.GetXmlNodeByID(id)
	local self = CombatCameraView;
	if(not id)then return end;
	local xmlnode = self.motion_pools[id];
	return xmlnode;
end
function CombatCameraView.ForceLoadAllCameras()
	local self = CombatCameraView;
	self.LoadAllCameras(self.filename,true);
end
function CombatCameraView.LoadAllCameras(filename,forceLoad)
	local self = CombatCameraView;
	if(not filename)then 
		return 
	end
	local function load()
		local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
		for node in commonlib.XPath.eachNode(xmlRoot, "/cameras/camera") do
			if(node.attr and node.attr.id)then
				local id = node.attr.id;
				local id_node;
				for id_node in string.gfind(id, "[^|]+") do
					self.motion_pools[string.lower(id_node)] = node;
				end
			end
		end
		for node in commonlib.XPath.eachNode(xmlRoot, "/cameras/camera_v2") do
			if(node.attr and node.attr.id)then
				local id = node.attr.id;
				local id_node;
				for id_node in string.gfind(id, "[^|]+") do
					self.motion_pools[string.lower(id_node)] = node;
				end
			end
		end
	end
	self.forceLoad = forceLoad;
	if(self.forceLoad)then
		load();
	else
		if(not self.reload)then
			self.reload = true;
			load();
		end
	end
end
function CombatCameraView.SetMinisceneName(miniscenename)
	local self = CombatCameraView;
	self.miniscenename = miniscenename;
end
function CombatCameraView.GetMinisceneName()
	local self = CombatCameraView;
	return self.miniscenename;
end
function CombatCameraView.SetFollowObjID(id)
	local self = CombatCameraView;
	self.follow_id = id;
end
--获取跟随物体的ID
function CombatCameraView.GetFollowObjID()
	local self = CombatCameraView;
	return self.follow_id;
end
function CombatCameraView.GetRandomMotion()
	local self = CombatCameraView;
	local r = math.random(4);
	local id = string.format("default_battle_%d",r);
	local mcmlNode = self.GetXmlNodeByID(id);
	return mcmlNode;
end
function CombatCameraView.GetFileName(path)
	local self = CombatCameraView;
	if(not path)then return end;
	local name;
	local p;
	for p in string.gfind(path, "[^/]+") do
		name = p;
	end
	name = string.match(name,"(.+)%.(.+)");
	return name;
end
function CombatCameraView.DoOutPut()
	local self = CombatCameraView;
	local k,v;
	for k,v in pairs(self.motion_pools) do
		if(v)then
			commonlib.echo(k);
		end
	end
end