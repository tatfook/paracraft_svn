--[[
Title: Managing model and texture in map system. 
Author(s): SunLingfeng @ paraengine.com
Date: 2007/10/18
Revised: 2007/11/3 By LiXizhi (refactoring and comments)
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppAssetManager.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppCommon.lua");

if( not Map3DApp.Global) then Map3DApp.Global = {};end
if( not Map3DApp.Global.AssetManager) then Map3DApp.Global.AssetManager = {};end

Map3DApp.Global.AssetManager.name = "mapManager";
Map3DApp.Global.AssetManager.models = {};
Map3DApp.Global.AssetManager.textures = {};
Map3DApp.Global.AssetManager.mapTextures = {};
Map3DApp.Global.AssetManager.characters = {}

-- delete all resources. 
function Map3DApp.Global.AssetManager.Destroy()
	local k, item;
	for k, item in pairs(Map3DApp.Global.AssetManager.models) do
		item:UnloadAsset();
	end
	Map3DApp.Global.AssetManager.models = {};
	
	for k, item  in pairs(Map3DApp.Global.AssetManager.textures) do
		item:UnloadAsset();
	end
	Map3DApp.Global.AssetManager.textures = {};
	
	Map3DApp.Global.AssetManager.UnloadAllMapTex();
end

-- return managed ParaAssetObject by file name
function Map3DApp.Global.AssetManager.GetModel(modelName)
	if( modelName == nil or modelName == "")then
		return nil;
	end
	
	if( Map3DApp.Global.AssetManager.models[modelName] == nil)then
		Map3DApp.Global.AssetManager.models[modelName] = ParaAsset.LoadStaticMesh("",modelName);
	end
	if(Map3DApp.Global.AssetManager.models[modelName]:IsValid())then
		return Map3DApp.Global.AssetManager.models[modelName];
	else
		return nil
	end
end

-- return managed ParaAssetObject by file name
function Map3DApp.Global.AssetManager.GetTexture(textureName)
	if( textureName == nil or textureName == "")then
		return nil;
	end
	
	if(Map3DApp.Global.AssetManager.textures[textureName] == nil)then
		 Map3DApp.Global.AssetManager.textures[textureName] = ParaAsset.LoadTexture("",textureName,1);
	end
	
	if( Map3DApp.Global.AssetManager.textures[textureName]:IsValid())then
		return Map3DApp.Global.AssetManager.textures[textureName]
	else
		return nil
	end
end

-- unload a given asset by file name
function Map3DApp.Global.AssetManager.UnloadModel(modelName)
	if( Map3DApp.Global.AssetManager.models[modelName] ~= nil)then
		Map3DApp.Global.AssetManager.models[modelName]:UnloadAsset();
		Map3DApp.Global.AssetManager.models[modelName] = nil;
	end
end

-- unload a given asset by file name
function Map3DApp.Global.AssetManager.UnloadTexture(textureName)
	if( Map3DApp.Global.AssetManager.textures[textureName] ~= nil)then
		Map3DApp.Global.AssetManager.textures[textureName]:UnloadAsset();
		Map3DApp.Global.AssetManager.textures[textureName] = nil;
	end
end

---
function Map3DApp.Global.AssetManager.GetMapTex(textureName)
	if( textureName == nil or textureName == "")then
		return nil;
	end
	
	if(Map3DApp.Global.AssetManager.mapTextures[textureName] == nil)then
		Map3DApp.Global.AssetManager.mapTextures[textureName] = ParaAsset.LoadTexture("",textureName,1);
	end
	if(Map3DApp.Global.AssetManager.mapTextures[textureName]:IsValid())then
		return Map3DApp.Global.AssetManager.mapTextures[textureName]
	else
		return nil
	end
end

function Map3DApp.Global.AssetManager.UnloadAllMapTex()
	for k, item  in pairs(Map3DApp.Global.AssetManager.mapTextures) do
		item:UnloadAsset();
	end

	Map3DApp.Global.AssetManager.mapsTextures = {};
end

function Map3DApp.Global.AssetManager.UnloadMapTex(textureName)
	if( Map3DApp.Global.AssetManager.textures[textureName] ~= nil)then
		Map3DApp.Global.AssetManager.textures[textureName]:UnloadAsset();
		Map3DApp.Global.AssetManager.textures[textureName] = nil;
	end
end

--
function Map3DApp.Global.AssetManager.GetCharacter(modelName)
	if( modelName == nil or ParaIO.DoesFileExist(modelName,true) == false)then
		return;
	end

	if( Map3DApp.Global.AssetManager.characters[modelName] == nil)then
		Map3DApp.Global.AssetManager.characters[modelName] = ParaAsset.LoadParaX("",modelName);
	end
	if(Map3DApp.Global.AssetManager.characters[modelName]:IsValid())then
		return Map3DApp.Global.AssetManager.characters[modelName];
	else
		return nil
	end
end

function Map3DApp.Global.AssetManager.UnloadCharacter(modelName)
	if( Map3DApp.Global.AssetManager.characters[modelName] ~= nil)then
		Map3DApp.Global.AssetManager.characters[modelName]:UnloadAsset();
		Map3DApp.Global.AssetManager.characters[modelName] = nil;
	end
end
