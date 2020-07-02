--[[
Title: some helper function convert DB data type to run time data type
Author(s): Clayman
Date: 
Desc: 
use the lib:
------------------------------------------------------------
--NPL.load("(gl)script/kids/3DMapSystemUI/Map/DataPvdHelper.lua");
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemUI/Map/MapDataDefine.lua");

Map3DApp.DataPvdHelper = {};
local helper = Map3DApp.DataPvdHelper;

function helper.ParseModels(modelString)
	if(modelString == nil)then
		return;
	end
	
	local models = {};
	local modelCount = 0;
	for model in string.gfind(modelString,".-[;]") do
		modelCount = modelCount + 1;
		models[modelCount] = Map3DApp.ModelInstance:new();
		local temp = models[modelCount];
		__,__,temp.modelID,temp.offsetX,temp.offsetY,temp.facing = string.find(model,"(%d+),([%+%-]?%d+[.]?%d*),([%+%-]?%d+[.]?%d*),([%+%-]?%d+[.]?%d*)");
		if(temp.modelID)then
			temp.modelID = tonumber(temp.modelID);
			local modelInfo = Map3DApp.DataPvd.GetModelByID(temp.modelID);
			if(modelInfo ~= nil)then
				temp.model = modelInfo.model;
			end
		end
	end
	return models;
end

function helper.PackModelInstances(modelInstances)
	
end

--texture string format is something like:
--"*/*/../*.*; */*/../*.*"
function helper.ParseTexture(textureString)
	if(textureString == nil or textureString == "")then
		return;
	end
	
	local textures = {};
	local texCount = 0;
	for texture in string.gfind(textureString,"%w.-[.]%a%a%a")do
		texCount = texCount + 1;
		textures[texCount] = texture;
	end
	return textures;
end


--convert data base tileInfo type to runtime type
function helper.ParseTileInfo(msg)
	local tileInfo = Map3DApp.TileInfo.CreateTileInfo();
	
	if(msg == nil)then
		return tileInfo;
	end
	
	if(msg.tileID and msg.tile ~= "")then
		tileInfo.id = msg.tileID;
	else
		return tileInfo;
	end
	
	if(msg.tileName and msg.tileName ~= "")then	
		tileInfo.name = msg.tileName;
	end
	
	if(msg.x and msg.x ~= "")then
		tileInfo.x = tonumber(msg.x);
	else
		tileInfo.id = 0;
		return tileInfo;
	end
	
	if(msg.y and msg.y ~= "")then
		tileInfo.y = tonumber(msg.y);
	else
		tileInfo.id = 0;
		return tileInfo;
	end
	
	if(msg.z and msg.z ~= "")then
		tileInfo.z = tonumber(msg.z);
	end
	
	if(msg.ownerUName and msg.ownerUName ~= "")then
		tileInfo.ownerUserName = msg.ownerUName;
	end
	
	if(msg.ownerUID and msg.ownerUID ~= "")then
		tileInfo.ownerUserID = msg.ownerUID;
	end
	
	if(msg.useUName and msg.useUName ~= "")then
		tileInfo.username = msg.useUName;
	end
	
	if(msg.useUID and msg.useUID ~= "")then
		tileInfo.userUserID = msg.useUID;
	end
	
	if(msg.cityName and msg.cityName ~= "")then
		tileInfo.cityName = msg.cityName;
	end
	
	if(msg.price and msg.price ~= "")then
		tileInfo.price = 0;
	end
	
	if(msg.rentPrice and msg.rentPrice ~= "")then
		tileInfo.rentPrice = msg.rentPrice;
	end
	
	if(msg.community and msg.community ~= "")then
		tileInfo.community = msg.community;
	end
	
	if(msg.ageGroup and msg.ageGroup ~= "")then
		tileInfo.ageGroup = msg.ageGroup;
	end
	
	if(msg.tileType and msg.tileType ~= "")then
		tileInfo.tileState = msg.tileType;
	end
	
	local terrain = Map3DApp.TerrainInfo:new();
	if(msg.terrainStyle and msg.tileTerrainStyle ~= "")then
		terrain.type = terrainStyle;
	end
	
	if(msg.rotation and msg.rotation ~= "")then
		terrain.rotation = msg.rotation;
	end
	
	if(msg.rank and msg.rank ~= "")then
		tileInfo.rank = msg.rank;
	end
	
	if(msg.texture and msg.texture ~= "")then
		local textures = Map3DApp.DataPvdHelper.ParseTexture(msg.texture);
		if(textures ~= nil)then
			if(textures[1])then
				terrain.tex0 = textures[1];
				
				if(textures[2])then
					terrain.tex1 = textures[2];
				end
			end
		end
	end
	tileInfo.terrainInfo = terrain;
	
	if(msg.models and msg.models ~= "")then
		local models = Map3DApp.DataPvdHelper.ParseModels(msg.models);
		if(models ~= nil)then
			tileInfo.models = models;
		end
	end
	
	return tileInfo;
end

--convert data base modelInfo to runtime type
function helper.ConvertModel2RunType(dbModelData)
	local modelInfo = Map3DApp.ModelInfo:new();
	
	if(dbModelData.id)then
		modelInfo.id = dbModelData.id;
	else
		return nil;
	end
	
	if(dbModelData.model)then
		modelInfo.model = dbModelData.model;
	end
	
	if(dbModelData.name)then
		modelInfo.name = dbModelData.name;
	end
	
	if(dbModelData.image)then
		modelInfo.image = dbModelData.image;
	end
	
	if(dbModelData.type)then
		modelInfo.type = dbModelData.type
	end
	return modelInfo;
end

helper.modelInstId = 0;
function helper.CreateModelInstanceID()
	helper.modelInstId = helper.modelInstId + 1;
	return tostring(helper.modelInstId);
end
