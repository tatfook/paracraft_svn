--[[
Title: game objects list
Author(s): WangTian
Date: 2009/7/20
Desc: all GameObjects avaiable and game objects
revised by LiXizhi 2010/8/18: game objects now belongs to a given world. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Quest/GameObjectList.lua");
MyCompany.Aries.Quest.GameObjectList.LoadGameObjectsInWorld("worlds/MyWorlds/61HaqiTown")
-- MyCompany.Aries.Quest.GameObjectList.GameObjects will contain the loaded game object list
MyCompany.Aries.Quest.GameObjectList.DumpInstances("61HaqiTown");
------------------------------------------------------------
]]
-- create class
local GameObjectList = commonlib.gettable("MyCompany.Aries.Quest.GameObjectList");

-- mapping from world name to NPC table list. 
local worlds_map = {
["61HaqiTown"] = {filename = "config/Aries/WorldData/61HaqiTown.GameObject.xml", obj_list=nil, },
-- ["FlamingPhoenixIsland"] = {filename = "config/Aries/WorldData/FlamingPhoenixIsland.NPC.xml", obj_list=nil, },
["FrostRoarIsland"] = {filename = "config/Aries/WorldData/FrostRoarIsland.GameObject.xml", obj_list=nil, },
};

GameObjectList.GameObjects = {}

-- dump all NPC instances in the current world to the default file. 
-- function only used at dev time. 
-- @param worldname: dump NPC in a given world (such as "FlamingPhoenixIsland"). If nil, the current is used. 
function GameObjectList.DumpInstances(worldname)
	NPL.load("(gl)script/ide/IPCBinding/Framework.lua");
	local EntityView = commonlib.gettable("IPCBinding.EntityView");
	local EntityHelperSerializer = commonlib.gettable("IPCBinding.EntityHelperSerializer");
	local EntityBase = commonlib.gettable("IPCBinding.EntityBase");

	local filename = "script/PETools/Aries/GameObject.entity.xml";
	local template = EntityView.LoadEntityTemplate(filename, false);
	if(template) then
		local objs
		if(worldname and worlds_map[worldname]) then
			if(worlds_map[worldname].filename) then
				objs = worlds_map[worldname].obj_list;
			else
				objs = worlds_map[worldname];
			end
		end
		objs = objs or GameObjectList.GetGameObjectList();
		local obj_id, obj
		for obj_id, obj in pairs(objs) do
			local obj_id = tonumber(obj_id)
			if(obj_id) then
				obj.obj_id = obj.obj_id or obj_id;
				-- forcing using existing uid
				obj.uid = obj.uid or ParaGlobal.GenerateUniqueID();
				local obj = EntityBase.IDECreateNewInstance(template, obj, nil);
				EntityHelperSerializer.SaveInstance(obj);
				LOG.std("", "debug", "GameObjectList", "dumping obj_id %s, uid %s", obj.obj_id, obj.uid);
			end
		end 
	end
end

-- load a GameObject for a given world path. it will load the first obj lists whose name matches the worldpath. 
-- @param worldpath: the name of the world,such as "61HaqiTown"
function GameObjectList.LoadGameObjectsInWorld(worldpath)
	local worldname, obj_data
	for worldname, obj_data in pairs(worlds_map) do
		if(worldpath == worldname) then
			if(obj_data.obj_list) then
				-- if we already loaded, 
				GameObjectList.GameObjects = obj_data.obj_list;
			elseif(obj_data.filename) then
				obj_data.obj_list = {};
				NPL.load("(gl)script/ide/IPCBinding/Framework.lua");
				local EntityView = commonlib.gettable("IPCBinding.EntityView");
				local EntityHelperSerializer = commonlib.gettable("IPCBinding.EntityHelperSerializer");
				local EntityBase = commonlib.gettable("IPCBinding.EntityBase");
				local template = EntityView.LoadEntityTemplate("script/PETools/Aries/GameObject.entity.xml", false);
				if(template) then
					local objs = {};
					local obj_list = {};
					EntityHelperSerializer.LoadInstancesFromFile(template, obj_data.filename, worldpath, objs);
					LOG.std("", "system","GameObjectList", "%d gameobject loaded in file %s", #(objs), obj_data.filename);
					local _, obj 
					for _, obj in ipairs(objs) do
						if(obj.obj_id) then
							setmetatable(obj, nil);
							obj.template = nil;
							obj.worldfilter = nil;
							obj.codefile = nil;
							obj.editors = nil;
							obj.eventDispatcher = nil;

							local obj_id = tonumber(obj.obj_id);
							if(obj_id) then
								obj_list[obj_id] = obj;
							end
							-- commonlib.echo(obj, true)
						end
					end
					obj_data.obj_list = obj_list;
				end
			else
				obj_data.obj_list = {};
			end
			GameObjectList.GameObjects = obj_data.obj_list or {};
			return 
		end
	end
	GameObjectList.GameObjects = {}
end

function GameObjectList.GetGameObjectList()
	return GameObjectList.GameObjects;
end

function GameObjectList.GetGameObjectByID(gameobject_id)
	return GameObjectList.GameObjects[gameobject_id];
end
