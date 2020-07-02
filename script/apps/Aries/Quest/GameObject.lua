--[[
Title: Aries quest game object
Author(s): WangTian
Date: 2009/7/21

use the lib:

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Quest/GameObject.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Quest/main.lua");

-- create class
local GameObject = commonlib.gettable("MyCompany.Aries.Quest.GameObject");
local ItemManager = commonlib.gettable("System.Item.ItemManager");
local ParaScene_GetCharacter = commonlib.getfield("ParaScene.GetCharacter");
local ParaScene_GetObject = commonlib.getfield("ParaScene.GetObject");
local tostring = tostring
local tonumber = tonumber
local type = type

-- init the respawn timer, invoked at Quest.Init() thus Aries application connect
function GameObject.InitRespawnTimer()
	NPL.load("(gl)script/ide/timer.lua");
	GameObject.respawn_timer = GameObject.respawn_timer or commonlib.Timer:new({callbackFunc = GameObject.CheckRespawn});
	GameObject.respawn_timer:Change(0, 5000);
end

-- respawn_gameobj_times records all game objects that need respawn
-- format:  ["40001"] = 543514, -- respawn game time
--			["40002(2)"] = 754320, -- respawn game time
GameObject.respawn_gameobj_times = {};

-- append to the game object respawn time list
function GameObject.AppendRespawn(gameobj_id, instance, respawn_interval)
	local key;
	if(gameobj_id) then
		if(instance) then
			key = gameobj_id.."("..instance..")";
		else
			key = gameobj_id.."";
		end
	end
	if(key and respawn_interval and respawn_interval>0) then
		GameObject.respawn_gameobj_times[key] = ParaGlobal.GetGameTime() + respawn_interval;
	end
end

-- check for game object respawn, create the game object if respawn time span reached
function GameObject.CheckRespawn()
	local HomeLandGateway = Map3DSystem.App.HomeLand.HomeLandGateway;
	local removelist = {};
	local key, time;
	for key, time in pairs(GameObject.respawn_gameobj_times) do
		local gameobj_id = string.match(key, "^(%d+)$");
		if(gameobj_id) then
			gameobj_id = tonumber(gameobj_id);
			if(ParaGlobal.GetGameTime() > time) then
				if(not GameObject.GetGameObjectCharacterFromIDAndInstance(gameobj_id)) then
					local params = MyCompany.Aries.Quest.GameObjectList.GameObjects[gameobj_id];
					if(params) then
						-- create game object if user is not in homeland
						if(not HomeLandGateway.IsInHomeland()) then
							params.skip_respawn = true;
							GameObject.CreateGameObjectCharacter(gameobj_id, params);
						end
					end
				end
				table.insert(removelist, key);
			end
		else
			local gameobj_id, instance = string.match(key, "^(%d+)%((%d+)%)$");
			if(gameobj_id and instance) then
				gameobj_id = tonumber(gameobj_id);
				instance = tonumber(instance);
				if(ParaGlobal.GetGameTime() > time) then
					if(not GameObject.GetGameObjectCharacterFromIDAndInstance(gameobj_id)) then
						local params = MyCompany.Aries.Quest.GameObjectList.GameObjects[gameobj_id];
						if(params) then
							-- create game object if user is not in homeland
							if(not HomeLandGateway.IsInHomeland()) then
								local position = params.positions[instance];
								local facing = params.facings[instance];
								local scaling = params.scaling;
								if(params.scalings) then
									scaling = params.scalings[instance];
								end
								local params = commonlib.deepcopy(params);
								params.copies = nil;
								params.positions = nil;
								params.facings = nil;
								params.scalings = nil;
								params.position = position;
								params.facing = facing;
								params.scaling = scaling;
								params.instance = instance;
								params.skip_respawn = true;
								GameObject.CreateGameObjectCharacter(gameobj_id, params);
							end
						end
					end
					table.insert(removelist, key);
				end
			else
				table.insert(removelist, key);
			end
		end
	end
	-- remove respawned game object key and non supported key formats
	local _, key;
	for _, key in ipairs(removelist) do
		GameObject.respawn_gameobj_times[key] = nil;
	end
end

-- check if the object is GameObject
-- @return true if is GameObject, otherwise false
function GameObject.IsGameObject(obj)
	if(obj and obj:IsValid() == true) then
		if(string.match(obj.name, "^GameObject:")) then
			return true;
		end
	end
	return false;
end

-- get game object id and instance from character object
-- @param obj: GameObject object
-- @return GameObj_id, instance: if is GameObject, otherwise nil, if instance order, otherwise nil
function GameObject.GetGameObjIDAndInstanceFromCharacter(obj)
	if(GameObject.IsGameObject(obj) == true) then
		--GameObject:122
		--GameObject:122(543)
		local GameObj_id, instance = string.match(obj.name, "GameObject:(%d+)[%(]?(%d*)[%)]?");
		if(GameObj_id and instance and instance ~= "") then
			return tonumber(GameObj_id), tonumber(instance);
		elseif(GameObj_id) then
			return tonumber(GameObj_id);
		end
	end
end

-- get the GameObject object from GameObj_id and instance
-- @param gameobj_id: game object id
-- @param instance(optional): instance of the gameobject character, starts from 1
-- @return valid gameobject character, otherwise nil
function GameObject.GetGameObjectCharacterFromIDAndInstance(gameobj_id, instance)
	local gameobj_char_name = "GameObject:"..gameobj_id;
	if(instance) then
		gameobj_char_name = "GameObject:"..gameobj_id.."("..instance..")";
	end
	local player = ParaScene_GetCharacter(gameobj_char_name);
	local gameobj_model_name = "g_"..gameobj_char_name.."_model";
	local gameobjModel = ParaScene_GetObject(gameobj_model_name);
	if(player and player:IsValid() == true) then
		if(gameobjModel:IsValid() == true) then
			return player, gameobjModel;
		else
			return player;
		end
	end
end

-- get the game object display name from gameobj_id
-- NOTE: the GameObject character must be visualized
-- @param gameobj_id: game object id
-- @return display name, otherwise nil
function GameObject.GetGameObjectDisplayNameFromID(gameobj_id)
	local gameobjectChar = GameObject.GetGameObjectCharacterFromIDAndInstance(gameobj_id, instance);
	local displayName;
	if(gameobjectChar and gameobjectChar:IsValid() == true) then
		displayName = gameobjectChar:GetDynamicField("DisplayName", "");
		if(displayName ~= "") then
			return displayName;
		else
			-- if the display name is not available, try the first instance
			-- NOTE: we assume that all instances share the same display name
			local gameobjectChar = GameObject.GetGameObjectCharacterFromIDAndInstance(gameobj_id, 1);
			if(gameobjectChar and gameobjectChar:IsValid() == true) then
				displayName = gameobjectChar:GetDynamicField("DisplayName", "");
				if(displayName ~= "") then
					return displayName;
				end
			end
		end
	end
end


-- create game object by gameobj_id and params
-- @param gameobj_id: game object id
-- @params: GameObject params including:
--		name = "",
--		position = {x, y, z},
--		assetfile_char = "", -- game object always uses a character to invoke the AI script or quest logic
--		(optional)facing = 0,
--		(optional)scaling = 1,
--		(optional)instance = 1, -- order of the game object that have multiple character instance, starts from 1, sharing the same gameobj_id, script and item bag
--		(optional)assetfile_model = "", -- some game objects are solid physics object, the model object share the same facing and scaling params as character
--		(optional)replaceabletextures_model = {}, -- some model contains replaceable texture to show multimedia content besides texture, such as flv, wmv
--		(optional)isalwaysshowheadontext = false, -- default false
--		(optional)isshownifown = true, default to true
--		(optional)isdeleteafterpick = false, default to false
--		gameobj_type = "", -- "GSItem"|"FreeItem"|"MCMLPage"
--		gsid = 1, if gameobj_type is "GSItem" or "FreeItem"
--		page_url = "", if gameobj_type is "MCMLPage"
--		pick_count = 1, if gameobj_type is "FreeItem"
--		isdeleteafterpick = false, if gameobj_type is "FreeItem"
-- @return game object character object if success and gameobjModel if valid
--		model/05plants/03shrub/1-xianrenzhang.x
--		model/05plants/04other/largemushrooms1.x
--		model/05plants/04other/largemushrooms2.x
-- Sample: 
--local params = {
	--name = "Metagron",
	--position = { 20065.27734375, 0.49730199575424, 19818.572265625 },
	----assetfile_char = "character/v1/01human/baru/baru.x",
	--assetfile_char = "character/v3/Elf/Female/ElfFemale.xml",
	--facing = 2,
	--scaling = 1.1,
	--instance = 3,
	--assetfile_model = "model/04deco/v3/1-gongyuangonggaolan.x",
	--replaceabletextures_model = {
		--[1] = "Texture/3DMapSystem/TEMP/Startup/paraworldCG_320_240.flv",
		--[2] = "Texture/productcover_exit.png",
	--},
	--isalwaysshowheadontext = false,
--};
--GameObject.CreateGameObjectCharacter(43123, params);
function GameObject.CreateGameObjectCharacter(gameobj_id, params)
	if(not gameobj_id or type(params) ~= "table") then
		LOG.std("", "warn", "GameObject", "create game object got nil params")
		return;
	end
	
	local key;
	if(gameobj_id) then
		if(params.instance) then
			key = gameobj_id.."("..params.instance..")";
		else
			key = gameobj_id.."";
		end
	end
	if(key) then
		if(GameObject.respawn_gameobj_times[key] and not params.skip_respawn) then
			-- skip the game object creation if the object is during respawn interval
			return;
		end
	end
	
	-- TODO: this is a very dirty code relying on the fact that the items are syncronized at the main login process
	if(params.isshownifown == false) then
		if(params.gsid) then
			local hasGSItem = ItemManager.IfOwnGSItem;
			if(hasGSItem(params.gsid)) then
				LOG.std("", "system", "GameObject", "GameObject:"..gameobj_id.."game object creation failed, because hasGSItem:"..params.gsid.." in bag");
				return;
			end
		end
	end
	
	local gameobj_char_name = "GameObject:"..gameobj_id;
	if(params.instance) then
		gameobj_char_name = "GameObject:"..gameobj_id.."("..params.instance..")";
	end
	-- create each game object character
	local gameobjectChar = ParaScene_GetCharacter(gameobj_char_name);
	if(gameobjectChar:IsValid() == false) then
		local obj_params = {};
		obj_params.name = gameobj_char_name;
		obj_params.x = params.position[1];
		obj_params.y = params.position[2];
		obj_params.z = params.position[3];
		obj_params.AssetFile = params.assetfile_char;
		if(params.gsid == 0) then -- it's the joy bean
			obj_params.AssetFile = "character/v5/08functional/JoyBean/JoyBean.x";
		end
		obj_params.IsCharacter = true;
		-- skip saving to history for recording or undo.
		System.SendMessage_obj({type = Map3DSystem.msg.OBJ_CreateObject, obj_params = obj_params, SkipHistory = true, silentmode = true,});
		gameobjectChar = ParaScene_GetCharacter(gameobj_char_name);

		if(params.skiprender_char) then
			gameobjectChar:SetField("SkipRender", true);
		end
		if(params.renderdistance) then
			gameobjectChar:SetField("RenderDistance", params.render_distance);
		end
	end
	-- if character exists, update the position and rotation
	gameobjectChar:SetPosition(params.position[1], params.position[2], params.position[3]);
	gameobjectChar:SetFacing(params.facing or 0);
	-- NOTE: special scaling for Aries project to scale the avatar to 1.6105, including avatars, dragons, follow pets, NPCs, GameObjects
	-- gameobjectChar:SetScale(1.6105 * (params.scaling_char or params.scaling or 1));
	gameobjectChar:SetScale((params.scaling_char or 1) * (params.scaling or 1));
	gameobjectChar:SetDynamicField("gameobj_type", params.gameobj_type);
	gameobjectChar:SetDynamicField("gsid", params.gsid);
	gameobjectChar:SetDynamicField("page_url", params.page_url);
	gameobjectChar:SetDynamicField("pick_count", params.pick_count or 1);
	gameobjectChar:SetDynamicField("onpick_msg", params.onpick_msg or nil);
	gameobjectChar:SetDynamicField("isdeleteafterpick", params.isdeleteafterpick or false);
	gameobjectChar:SetDynamicField("PickDist", params.pickdist);
	gameobjectChar:SetDynamicField("respawn_interval", params.respawn_interval);
	--gameobjectChar:ToCharacter():AssignAIController("face", "true");
	if(params.isalwaysshowheadontext == true) then
		gameobjectChar:SetDynamicField("AlwaysShowHeadOnText", true);
		System.ShowHeadOnDisplay(true, gameobjectChar, "GameObject:"..params.name);
		gameobjectChar:SetDynamicField("DisplayName", params.name);
	else
		gameobjectChar:SetDynamicField("AlwaysShowHeadOnText", false);
		gameobjectChar:SetDynamicField("DisplayName", "");
	end
	
	local gameobjModel;
	if(params.assetfile_model) then
		local gameobj_model_name = "g_"..gameobj_char_name.."_model";
		gameobjModel = ParaScene_GetObject(gameobj_model_name);
		if(gameobjModel:IsValid() == false) then
			local obj_params = {};
			obj_params.name = gameobj_model_name;
			obj_params.x = params.position[1];
			obj_params.y = params.position[2];
			obj_params.z = params.position[3];
			obj_params.rotation = params.rotation;
			obj_params.AssetFile = params.assetfile_model;
			obj_params.scaling = (params.scale_model or 1) * (params.scaling or 1);
			obj_params.facing = params.facing or 0;
			obj_params.IsCharacter = false;

			obj_params.EnablePhysics = params.EnablePhysics;
			-- skip saving to history for recording or undo.
			System.SendMessage_obj({type = Map3DSystem.msg.OBJ_CreateObject, obj_params = obj_params, SkipHistory = true, silentmode = true,});
			
			--local asset = ParaAsset.LoadStaticMesh("", params.assetfile_model)
			--gameobjModel = ParaScene.CreateMeshPhysicsObject(gameobj_model_name, asset, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
			--ParaScene.Attach(gameobjModel);
			
			gameobjModel = ParaScene_GetObject(gameobj_model_name);

			gameobjModel:SetField("progress", 1);
			if(params.skiprender_mesh) then
				gameobjModel:SetField("SkipRender", true);
			end
			if(params.physics_group and params.physics_group>0) then
				gameobjModel:SetPhysicsGroup(params.physics_group);
			end
			if(params.renderdistance) then
				gameobjModel:SetField("RenderDistance", params.render_distance);
			end
		else
			gameobjModel:SetScale((params.scale_model or 1) * (params.scaling or 1));
			gameobjModel:SetFacing(params.facing or 0);
			gameobjModel:SetPosition(params.position[1], params.position[2], params.position[3]);
		end

		if(params.replaceabletextures_model and gameobjModel:GetNumReplaceableTextures()>0) then
			local i;
			for i = 1, gameobjModel:GetNumReplaceableTextures() do
				local filename = params.replaceabletextures_model[i];
				if(filename and filename ~= "") then
					gameobjModel:SetReplaceableTexture(i-1, ParaAsset.LoadTexture("", filename, 1));
				end	
			end
		end
	end
	
	
	return gameobjectChar, gameobjModel;
	
	-- TODO: set the sentient radius and sentient to users
	
	--------------------------------------------------------
	--player:SetField("SentientField", 3);--senses everybody including its own kind.
	--char:SetField("Sentient Radius", System.options.CharClickDistSq); -- sense click distance characters
	--player:SetField("GroupID", 3);
	--player:SetField("Sentient", true);
	--player:MakeGlobal(true);
	--------------------------------------------------------
end

-- delete the game object character in the scene
-- @param gameobj_id: game object id
-- @parma instance(optional): instance of the game object character, starts from 1
function GameObject.DeleteGameObjectCharacter(gameobj_id, instance)
	-- auto deselect the game object if selected
	local TargetArea = MyCompany.Aries.Desktop.TargetArea;
	if(TargetArea.TargetGameObj_id == gameobj_id and TargetArea.TargetGameObj_instance == instance) then
		-- deselect object
		System.SendMessage_obj({type = System.msg.OBJ_DeselectObject, obj = nil});
	end
	local gameobjectChar = GameObject.GetGameObjectCharacterFromIDAndInstance(gameobj_id, instance)
	local gameobj_char_name;
	if(gameobjectChar and gameobjectChar:IsValid() == true) then
		gameobj_char_name = gameobjectChar.name;
		ParaScene.Delete(gameobjectChar);
	end
	if(gameobj_char_name) then
		local gameobj_model_name = "g_"..gameobj_char_name.."_model";
		local gameobjModel = ParaScene_GetObject(gameobj_model_name);
		if(gameobjModel:IsValid() == true) then
			ParaScene.Delete(gameobjModel);
		end
	end
end