--[[
Title: CombatSceneMotionHelper
Author(s): Leio
Date: 2011/04/09
Desc:

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Combat/CombatSceneMotionHelper.lua");
local CombatSceneMotionHelper = commonlib.gettable("MotionEx.CombatSceneMotionHelper");
local arena_params = CombatSceneMotionHelper.FindArena("config/Aries/WorldData/61HaqiTown.Arenas_Mobs.xml","10000_water3");
local x,y,z = ParaScene.GetPlayer():GetPosition();
arena_params.x = x;
arena_params.y = y;
arena_params.z = z;
CombatSceneMotionHelper.ShowArena(arena_params,function(msg)
	commonlib.echo(msg);
end);


NPL.load("(gl)script/apps/Aries/Combat/CombatSceneMotionHelper.lua");
local CombatSceneMotionHelper = commonlib.gettable("MotionEx.CombatSceneMotionHelper");
local player = ParaScene.GetPlayer();
CombatSceneMotionHelper.PlayMotionByFile("config/Aries/WorldData/61HaqiTown.Arenas_Mobs.xml","10000_water3","1",function()
	_guihelper.MessageBox("end");
	player:ToCharacter():SetFocus();
end)

NPL.load("(gl)script/apps/Aries/Combat/CombatSceneMotionHelper.lua");
local CombatSceneMotionHelper = commonlib.gettable("MotionEx.CombatSceneMotionHelper");
local player = ParaScene.GetPlayer();
local x,y,z = player:GetPosition();
CombatSceneMotionHelper.PlayMotion("1",x,y,z,function()
	_guihelper.MessageBox("end");
	player:ToCharacter():SetFocus();
end)

NPL.load("(gl)script/apps/Aries/Combat/CombatSceneMotionHelper.lua");
local CombatSceneMotionHelper = commonlib.gettable("MotionEx.CombatSceneMotionHelper");
local arena_params = CombatSceneMotionHelper.FindArena("config/Aries/WorldData/61HaqiTown.Arenas_Mobs.xml","10000_water3");
local x,y,z = ParaScene.GetPlayer():GetPosition();
arena_params.x = x;
arena_params.y = y;
arena_params.z = z;
CombatSceneMotionHelper.ShowArena_InMiniScene(arena_params)

NPL.load("(gl)script/apps/Aries/Combat/CombatSceneMotionHelper.lua");
local CombatSceneMotionHelper = commonlib.gettable("MotionEx.CombatSceneMotionHelper");
commonlib.echo(CombatSceneMotionHelper.all_arenas);
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/MotionEx/MotionXmlToTable.lua");
local MotionXmlToTable = commonlib.gettable("MotionEx.MotionXmlToTable");
local ParaScene_GetMiniSceneGraph = ParaScene.GetMiniSceneGraph;
NPL.load("(gl)script/ide/object_editor.lua");
local ObjEditor = commonlib.gettable("ObjEditor");

NPL.load("(gl)script/apps/Aries/Combat/CombatSceneMotion.lua");
local CombatSceneMotion = commonlib.gettable("MotionEx.CombatSceneMotion");

local CombatSceneMotionHelper = commonlib.gettable("MotionEx.CombatSceneMotionHelper");
CombatSceneMotionHelper.mini_scene_name = "CombatSceneMotionHelper.mini_scene_instance";
--存储所有的法阵信息 包括各个世界的
CombatSceneMotionHelper.all_arenas = {
}
CombatSceneMotionHelper.is_loaded = false
CombatSceneMotionHelper.entity_maps = {};
CombatSceneMotionHelper.entity_maps_mini = {};
CombatSceneMotionHelper.replace_asset_file = "config/Aries/Mob_Teen/Common_Attrbutes.csv";
CombatSceneMotionHelper.replace_asset_file_map = {};
function CombatSceneMotionHelper.LoadReplaceAsset()
	local self = CombatSceneMotionHelper;
	if(self.load_replace_map)then
		return;
	end
	self.load_replace_map = true;
	self.replace_asset_file_map = {};
	local function get_arr(s)
		if(not s)then return end
		local list = {};
		local line;
		for line in string.gfind(s, "([^,]+)") do
			table.insert(list,line);
		end
		return list;
	end
	local line;
	local file_path = self.replace_asset_file;
	local file = ParaIO.open(file_path, "r");
	if(file:IsValid()) then
		line=file:readline();
		while line~=nil do 
			local arr = get_arr(line);
			if(arr)then
				local mob = arr[1];
				local assetfile = arr[2];
				if(mob and assetfile)then
					mob = string.format("config/Aries/Mob_Teen/%s",mob);
					self.replace_asset_file_map[mob] = assetfile;
				end
			end
			line=file:readline();
		end
		file:close();
	end
end
function CombatSceneMotionHelper.PlayCombatMotion_LoginWorld_Handle(filepath)
	local self = CombatSceneMotionHelper;
	if(not filepath)then return end
	commonlib.echo("======CombatSceneMotionHelper.PlayCombatMotion_LoginWorld_Handle");
	commonlib.echo({filepath = filepath});
	self.PlayCombatMotion_LoginWorld(filepath,true,true);
end
function CombatSceneMotionHelper.PlayMotion_Handle(filepath,arenaid,id)
	local self = CombatSceneMotionHelper;
	commonlib.echo("======CombatSceneMotionHelper.PlayMotion_Handle");
	commonlib.echo({filepath = filepath, id = id});
	if(not id)then return end
	CombatSceneMotion.ForceLoadAllMotions();
	self.Clear_MiniScene();
	local x,y,z;
	local player = ParaScene.GetPlayer();
	if(filepath and filepath ~= "none")then
		commonlib.echo("======filepath");
		commonlib.echo(filepath);
		commonlib.echo(id);
		local arena_params = CombatSceneMotionHelper.FindArena(filepath,arenaid);
		commonlib.echo(arena_params);
		if(not arena_params)then return end
		x,y,z = arena_params.x,arena_params.y,arena_params.z;
	else
		x,y,z = player:GetPosition();
	end
	self.PlayMotion(id,x,y,z,function()
		_guihelper.MessageBox("end");
		player:ToCharacter():SetFocus();
	end)
end
--显示所有的法阵
function CombatSceneMotionHelper.ShowAllArena_ByStr(str,version)
	local self = CombatSceneMotionHelper;
	if(not str)then return end
	self.Clear_MiniScene();
	self.LoadReplaceAsset();
	local mcmlNode = ParaXML.LuaXML_ParseString(str);
	local node;
	for node in commonlib.XPath.eachNode(mcmlNode, "//arenas/arena") do
		local arena_params = self.GetArenaByMcmlNode(node);
		CombatSceneMotionHelper.ShowArena_InMiniScene(arena_params,version);
	end
end
function CombatSceneMotionHelper.ShowArena_ByStr(str,version,clear)
	local self = CombatSceneMotionHelper;
	if(not str)then return end
	self.LoadReplaceAsset();
	local mcmlNode = ParaXML.LuaXML_ParseString(str);
	local arena_params = self.GetArenaByMcmlNode(mcmlNode[1]);
	CombatSceneMotionHelper.ShowArena_InMiniScene(arena_params,version,clear);
end
function CombatSceneMotionHelper.ShowArena_Handle(filepath,id,version)
	local self = CombatSceneMotionHelper;
	if(not filepath or not id)then return end
	self.LoadReplaceAsset();
	CombatSceneMotion.ForceLoadAllMotions();
	commonlib.echo("======filepath");
	commonlib.echo(filepath);
	commonlib.echo(id);
	local arena_params = CombatSceneMotionHelper.FindArena(filepath,id);
	commonlib.echo(arena_params);
	if(not arena_params)then return end
	ParaScene.GetPlayer():SetPosition(arena_params.x,arena_params.y,arena_params.z);
	--local x,y,z = ParaScene.GetPlayer():GetPosition();
	--arena_params.x = x;
	--arena_params.y = y;
	--arena_params.z = z;
	CombatSceneMotionHelper.ShowArena_InMiniScene(arena_params,version);
end
--加载一个mobs.xml里面所有的法阵
function CombatSceneMotionHelper.LoadOneFile(path)
	local self = CombatSceneMotionHelper;
	self.LoadReplaceAsset();
	local xmlRoot = ParaXML.LuaXML_ParseFile(path);
	local maps = {};
	if(xmlRoot)then
		local node;
		for node in commonlib.XPath.eachNode(xmlRoot, "//arenas/arena") do
			local result = self.GetArenaByMcmlNode(node);
			if(result and result.id)then
				maps[result.id] = result;
			end
		end
	end	
	return maps;
end
--[[
	return arena = {
		id = string,
		x = number,
		y = number,
		z = number,
		facing = number,
		[1] = {displayname = string, asset = asset},
		...
		[4] = {displayname = string, asset = asset},
	}
--]]
function CombatSceneMotionHelper.FindArena(filepath,id)
	local self = CombatSceneMotionHelper;
	if(not filepath or not id)then return end

	local arenas = self.all_arenas[filepath];
	if(not arenas)then
		arenas = self.LoadOneFile(filepath);
		self.all_arenas[filepath] = arenas;
	end
	commonlib.echo(id);
	commonlib.echo(arenas);
	if(arenas)then
		return arenas[id];
	end
end

function CombatSceneMotionHelper.GetArenaByMcmlNode(xmlnode)
	local self = CombatSceneMotionHelper;
	if(not xmlnode)then return end
	local id = xmlnode.attr.id;
	local facing = tonumber(xmlnode.attr.facing) or 0;
	local position = xmlnode.attr.position;
	local x,y,z;
	if(position)then
		x,y,z = string.match(position,"(.+),(.+),(.+)");
		x = tonumber(x);
		y = tonumber(y);
		z = tonumber(z);
	end
	local result = {
		id = id,
		x = x,
		y = y,
		z = z,
		facing = facing,
	}
	local node;
	for node in commonlib.XPath.eachNode(xmlnode, "//mob") do
		local mob_template_path = node.attr.mob_template;
		if(mob_template_path and mob_template_path ~= "")then
			local xmlRoot = ParaXML.LuaXML_ParseFile(mob_template_path);
			if(xmlRoot)then
				local mob_node;
				for mob_node in commonlib.XPath.eachNode(xmlRoot, "//mobtemplate/mob") do
					local displayname = mob_node.attr.displayname;
					local asset = mob_node.attr.asset;
					local mob = {
						displayname = displayname,
						asset = asset,
						mob_template_path = mob_template_path,
					}
					table.insert(result,mob);
					break;
				end
				
			end
		end
	end
	return result;
end
function CombatSceneMotionHelper.Clear()
	local self = CombatSceneMotionHelper;
	for k,v in pairs(self.entity_maps) do
		if(v and v:IsValid())then
			ParaScene.Delete(v);
		end
	end
	if(self.timer)then
		self.timer:Change();
	end
	self.entity_maps = {};
end
function CombatSceneMotionHelper.Clear_MiniScene()
	local self = CombatSceneMotionHelper;
	local effectGraph = ParaScene_GetMiniSceneGraph(self.mini_scene_name);
	local k,v;
	for k,v  in pairs(self.entity_maps_mini) do
		effectGraph:DestroyObject(v);
	end
	self.entity_maps_mini = {};
end
--[[显示法阵和怪物具体信息
local arena_params = CombatSceneMotionHelper.FindArena("config/Aries/WorldData/61HaqiTown.Arenas_Mobs.xml","10000_water3");
local x,y,z = ParaScene.GetPlayer():GetPosition();
arena_params.x = x;
arena_params.y = y;
arena_params.z = z;

	arena_params = {
		id = string,
		facing = number,
		x = number,
		y = number,
		z = number,
		[1] = {displayname = string, asset = asset},
		...
		[4] = {displayname = string, asset = asset},
	}
--]]
function CombatSceneMotionHelper.ShowArena_InMiniScene(arena_params,version,clear)
	local self = CombatSceneMotionHelper;
	if(not arena_params)then return end	
	local id = arena_params.id;
	local effectGraph = ParaScene_GetMiniSceneGraph(self.mini_scene_name);
	if(clear)then
		self.Clear_MiniScene();
	end
	local arena_facing = arena_params.facing;
	local arena_x = arena_params.x or 250;
	local arena_y = arena_params.y or 0;
	local arena_z = arena_params.z or 250;
	local arena_info = self.GetAbsoluteArenaInfo(arena_x,arena_y,arena_z)
	local name = ParaGlobal.GenerateUniqueID();
	local default_arena = "model/06props/v5/06combat/Common/Arena/HaqiTown_Basic.x";
	if(version == "teen" or System.options.is_mcworld)then
		default_arena = "model/06props/v5/06combat/Common/Arena/HaqiTown_Basic_teen.x";
	end
	local entity_params = {
		name = name,
		x = arena_x,
		y = arena_y,
		z = arena_z,
		AssetFile = arena_params.asset or default_arena,
		facing = arena_facing,
	}
	-- create arena
	local arena_model = ObjEditor.CreateObjectByParams(entity_params);
	arena_model:GetAttributeObject():SetField("progress",1);
	effectGraph:AddChild(arena_model);

	self.entity_maps_mini[name] = name;
	local k,v;
	for k,v in ipairs(arena_params) do
		if(v.asset)then
			local index = k + 4;
			local info = arena_info[index];
			if(info)then
				local name = ParaGlobal.GenerateUniqueID();
				local asset = v.asset;
				local mob_template_path = v.mob_template_path;
				if(version == "teen" and mob_template_path)then
					if(self.replace_asset_file_map[mob_template_path])then
						asset = self.replace_asset_file_map[mob_template_path];
					end
				end
				local entity_params = {
					name = name,
					x = info.x,
					y = info.y,
					z = info.z,
					facing = info.facing,
					AssetFile = asset,
					IsCharacter = true,
				}
				local entity = ObjEditor.CreateObjectByParams(entity_params);
				entity:GetAttributeObject():SetField("progress",1);
				effectGraph:AddChild(entity);
				self.entity_maps_mini[name] = name;
			end
		end
	end
end
--[[
为了加载插件点的坐标，所以在真实场景中创造了法阵
查看法阵和怪物信息用CombatSceneMotionHelper.ShowArena_InMiniScene
	arena_params = {
		id = string,
		facing = number,
		x = number,
		y = number,
		z = number,
		[1] = {displayname = string, asset = asset},
		...
		[4] = {displayname = string, asset = asset},
	}

	callbackFunc.arena_infos = {
		[1] = { x,y,z,facing },
		...
		[9] = { x,y,z,facing },-- arena center pointer
	}
--]]
function CombatSceneMotionHelper.ShowArena(arena_params,callbackFunc)
	local self = CombatSceneMotionHelper;
	if(not arena_params)then return end	
	local id = arena_params.id;
	self.Clear();
	local arena_facing = arena_params.facing;
	local arena_x = arena_params.x or 250;
	local arena_y = arena_params.y or 0;
	local arena_z = arena_params.z or 250;

	local entity_params = {
		name = id,
		x = arena_x,
		y = arena_y,
		z = arena_z,
		AssetFile = arena_params.asset or "model/06props/v5/06combat/Common/Arena/HaqiTown_Basic.x",
		facing = arena_facing,
	}
	-- create arena
	local arena_model = ObjEditor.CreateObjectByParams(entity_params);
	arena_model:GetAttributeObject():SetField("progress",1);
	ParaScene.Attach(arena_model);
	self.entity_maps[arena_model] = arena_model;
	if(arena_model and arena_model:IsValid())then
		NPL.load("(gl)script/ide/timer.lua");
		if(not self.timer)then
				self.timer = commonlib.Timer:new({callbackFunc = function(timer)
				-- get ref point in arena
				local nXRefCount = arena_model:GetXRefScriptCount();
				local k;
				local arena_infos = {};
				local ground_pos_x,ground_pos_y,ground_pos_z = arena_model:GetXRefScriptPosition(8);
				--NOTE: ref point y value higher then arena hight
				ground_pos_y = arena_y;
				arena_infos[9] = {x = ground_pos_x,y = ground_pos_y,z = ground_pos_z,facing = arena_facing};
				-- nXRefCount is 9
				for k = 0,nXRefCount - 2 do
				
					local x,y,z = arena_model:GetXRefScriptPosition(k);
					local facing = arena_model:GetXRefScriptFacing(k);
					facing = math.atan2((ground_pos_x - x), (ground_pos_z - z)) - math.pi/2;

					arena_infos[k+1] = {x = x,y = y,z = z,facing = facing};
				end
				--create mobs
				local k,v;
				for k,v in ipairs(arena_params) do
					local pos = arena_infos[k+4];
					if(pos)then
						local x,y,z = pos.x,pos.y,pos.z;
						local facing = pos.facing;
						local asset = v.asset;
						local entity_params = {
							name = id..(k+4),
							x = x,
							y = y,
							z = z,
							facing = facing,
							AssetFile = asset,
							IsCharacter = true,
						}
						local entity = ObjEditor.CreateObjectByParams(entity_params);
						entity:GetAttributeObject():SetField("progress",1);
						ParaScene.Attach(entity);
						self.entity_maps[entity] = entity;
					end
				end
				--local k,v;
				--for k,v in ipairs(arena_infos) do
					--local entity_params = {
						--x = v.x,
						--y = v.y,
						--z = v.z,
						--facing = v.facing,
						--AssetFile = "character/v5/10mobs/HaqiTown/DeathBubble/DeathBubble.x",
						--IsCharacter = true,
					--}
					--local entity = ObjEditor.CreateObjectByParams(entity_params);
					--entity:GetAttributeObject():SetField("progress",1);
					--ParaScene.Attach(entity);
					--self.entity_maps[entity] = entity;
				--end

				local k,v;
				local arena_infos_relative = {};
				for k,v in ipairs(arena_infos) do
					arena_infos_relative[k] = {
						x = v.x - arena_x,
						y = v.y - arena_y,
						z = v.z - arena_z,
						facing = v.facing,
					}
				end
				if(callbackFunc)then
					callbackFunc({
						arena_infos = arena_infos,
						arena_infos_relative = arena_infos_relative,
					})
				end
			end})
		end
		self.timer:Change(1000, nil)
	end
end
function CombatSceneMotionHelper.GetAbsoluteArenaInfo(x,y,z)
	local self = CombatSceneMotionHelper;
	if(not x or not y or not z)then return end
	local const_info = {
		{y=1.07,x=-14.72629,facing=0.61626,z=10.43018,},
		{y=1.07,x=-5.66545,facing=1.25131,z=17.12558,},
		{y=1.07,x=5.61966,facing=-4.39527,z=17.12299,},
		{y=1.07,x=14.68445,facing=-3.7593,z=10.43259,},
		{y=1.07,x=14.68985,facing=-2.52527,z=-10.40605,},
		{y=1.07,x=5.63028,facing=-1.88863,z=-17.11443,},
		{y=1.07,x=-5.66262,facing=-1.25154,z=-17.13002,},
		{y=1.07,x=-14.72411,facing=-0.61641,z=-10.4321,},
		{y=0,x=0,facing=0,z=0,},
	};
	local result = {};
	local k,v;
	for k,v in ipairs(const_info) do
		result[k] = {
			x = x + v.x,
			y = y + v.y,
			z = z + v.z,
			facing = v.facing,
		}
	end
	return result;
end
function CombatSceneMotionHelper.PlayMotion(motionid,x,y,z,callbackFunc)
	if(not motionid or not x or not y or not z)then
		if(callbackFunc)then
			callbackFunc();
		end
		return
	end
	local arena_infos = CombatSceneMotionHelper.GetAbsoluteArenaInfo(x,y,z)
	CombatSceneMotion.PlayMotion(motionid,arena_infos,function()
		if(callbackFunc)then
			callbackFunc();
		end
	end)
end
--@param filepath:法阵路径
--@param id:法阵id
--@param motionid:动画id
--@param callbackFunc:动画结束回调函数
function CombatSceneMotionHelper.PlayMotionByFile(filepath,id,motionid,callbackFunc)
	local self = CombatSceneMotionHelper;
	local arena_info = self.FindArena(filepath,id)
	if(arena_info and motionid)then
		local arena_info = CombatSceneMotionHelper.GetAbsoluteArenaInfo(arena_info.x,arena_info.y,arena_info.z);
		CombatSceneMotion.PlayMotion(motionid,arena_info,function()
			if(callbackFunc)then
				callbackFunc();
			end
		end)
	else
		if(callbackFunc)then
			callbackFunc();
		end
	end
end
-- @param state: true to freeze camera.
local function SetPlayerFreeze(state)
	local player = ParaScene.GetPlayer();
	local playerChar = player:ToCharacter();
	if(state == true)then
		playerChar:Stop();
		-- commented by LiXizhi 2011.9.22 (Enter Key should be received in object manager)
		-- ParaScene.GetAttributeObject():SetField("BlockInput", true); 
		System.KeyBoard.SetKeyPassFilter(System.KeyBoard.enter_key_filter);
		System.Mouse.SetMousePassFilter(System.Mouse.disable_filter);
		ParaCamera.GetAttributeObject():SetField("BlockInput", true);
	else
		System.KeyBoard.SetKeyPassFilter(nil);
		System.Mouse.SetMousePassFilter(nil);
		ParaScene.GetAttributeObject():SetField("BlockInput", false);
		ParaCamera.GetAttributeObject():SetField("BlockInput", false);
	end
end
local function SetFocus()
	local Pet = commonlib.gettable("MyCompany.Aries.Pet");
	if(Pet and Pet.GetRealPlayer)then
		local player = Pet.GetRealPlayer();
		if(player and player:IsValid())then
			player:ToCharacter():SetFocus();
		end
	end
	
end
--接受战斗结束后消息
function CombatSceneMotionHelper.PlayCombatMotion_Handle(x, y, z, motionid, callbackFunc)
	local self = CombatSceneMotionHelper;
	commonlib.echo("===========CombatSceneMotionHelper.PlayCombatMotion_Handle");
	commonlib.echo({x = x, y = y, z = z, motionid = motionid});
	if(not x or not y or not z or not motionid)then
		return
	end
	if(not MotionXmlToTable.IsOld_CombatMotionID(motionid))then
		MotionXmlToTable.PlayCombatMotion(motionid,callbackFunc)
		return
	end
	
	local has_motion = CombatSceneMotion.HasMotion(motionid);
	if(not has_motion)then return end
	SetPlayerFreeze(true);
	CombatSceneMotionHelper.ShowUI(false);
	self.PlayMotion(motionid,x,y,z,function()
		SetPlayerFreeze(false);
		SetFocus();
		CombatSceneMotionHelper.ShowUI(true);
		if(callbackFunc) then
			callbackFunc();
		end
	end)
end

--[[在进入副本的时候，播放摄影机和对话 动画
NPL.load("(gl)script/apps/Aries/Combat/CombatSceneMotionHelper.lua");
local CombatSceneMotionHelper = commonlib.gettable("MotionEx.CombatSceneMotionHelper");
local filepath = "config/Aries/Cameras/SceneLoading2.xml";
CombatSceneMotionHelper.PlayCombatMotion_LoginWorld(filepath,true);
--]]
function CombatSceneMotionHelper.PlayCombatMotion_LoginWorld(filepath,is_taurus,bReload)
	if(not filepath)then return end
	if(not is_taurus)then
		SetPlayerFreeze(true)
		CombatSceneMotionHelper.ShowUI(false);
	end
	NPL.load("(gl)script/ide/MotionEx/MotionRender.lua");
	local MotionRender = commonlib.gettable("MotionEx.MotionRender");
	NPL.load("(gl)script/ide/MotionEx/MotionFactory.lua");
	local MotionFactory = commonlib.gettable("MotionEx.MotionFactory");
	local name = "player_name_PlayCombatMotion_LoginWorld"
	local motionPlayer = MotionFactory.GetPlayer(name);
	motionPlayer.esc_key = true;
	local player = ParaScene.GetPlayer();
	if(not motionPlayer:HasEventListener("stop"))then
		motionPlayer:AddEventListener("stop",function()
			SetFocus(is_taurus);
			MotionRender.ForceEnd();
			if(not is_taurus)then
				SetFocus();
				SetPlayerFreeze(false);
				CombatSceneMotionHelper.ShowUI(true);
			else
				if(player and player:IsValid())then
					player:ToCharacter():SetFocus();
				end	
			end
		end,{});
	end
	if(not motionPlayer:HasEventListener("end"))then
		motionPlayer:AddEventListener("end",function()
			MotionRender.ForceEnd();
			if(not is_taurus)then
				SetFocus();
				SetPlayerFreeze(false);
				CombatSceneMotionHelper.ShowUI(true);
			else
				if(player and player:IsValid())then
					player:ToCharacter():SetFocus();
				end	
			end
		end,{});
	end
	MotionFactory.PlayMotionFile(name,filepath,bReload);

end
NPL.load("(gl)script/ide/TooltipHelper.lua");
local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");
function CombatSceneMotionHelper.ShowUI(bShow)
	NPL.load("(gl)script/apps/Aries/Desktop/AriesDesktop.lua");
	if(bShow)then
		MyCompany.Aries.Desktop.ShowAllAreas();
	else
		MyCompany.Aries.Desktop.HideAllAreas();
	end
	BroadcastHelper.Show(bShow);
end