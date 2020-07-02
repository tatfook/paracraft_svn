--[[
Title: mini map manager for paraworld
Author(s): WangTian
Date: 2008/1/14
Desc: mini map manager will handle all the mini map related data 
		including portal and OPC position(JGSL support)
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MiniMap/MiniMapManager.lua");
------------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/MiniMap/MiniMapWnd.lua");


if(not Map3DSystem.UI.MiniMapManager) then Map3DSystem.UI.MiniMapManager = {}; end


-- mini map north direction
Map3DSystem.UI.MiniMapManager.northDir = 0;

-- scale applied to every mini map object, including avatar, OPC, camera and portal
-- mini map objects will have the same X and Z coordinate in ParaScene
Map3DSystem.UI.MiniMapManager.assetScale = 4;

-- Y positions divide the mini map objects into several layers
-- avatar is always on top of OPCs .etc
Map3DSystem.UI.MiniMapManager.cameraPosY = 3;
Map3DSystem.UI.MiniMapManager.portalPosY = 4;
Map3DSystem.UI.MiniMapManager.OPCPosY = 5;
Map3DSystem.UI.MiniMapManager.avatarPosY = 6;

if(not Map3DSystem.UI.MiniMapManager.PortalList) then Map3DSystem.UI.MiniMapManager.PortalList = {}; end
if(not Map3DSystem.UI.MiniMapManager.OPCList) then Map3DSystem.UI.MiniMapManager.OPCList = {}; end

-- use the main character as user avatar
Map3DSystem.UI.MiniMapManager.AvatarName = Map3DSystem.User.Name;

Map3DSystem.UI.MiniMapManager.AssetListDefault = {
	-- LXZ 2008.6.29, for release purposes, following are no longer used. If they are used in future, move to the map folder, instead of test folder. 
	["assetAvatarDefault"] = "model/test/ryb/red/red.x",
	["assetPortalDefault"] = "model/test/ryb/blue/blue.x",
	["assetOPCDefault"] = "model/test/ryb/yellow/yellow.x",
	["assetCameraDefault"] = "model/test/ryb/camera/camera.x",
	["ground"] = "model/common/map3D/map3D.x", -- added LXZ 2008.6.29 for ground texture
};

function Map3DSystem.UI.MiniMapManager.InitDefaultAssets()
	-- LXZ 2008.6.29, use lazy loading, no need to load them here
end

-- register the avatar object in the mini map
function Map3DSystem.UI.MiniMapManager.RegisterAvatarObject()
	local scene = Map3DSystem.UI.MiniMapWnd.GetScene();
	local _asset = ParaAsset.LoadStaticMesh("", Map3DSystem.UI.MiniMapManager.AssetListDefault["assetAvatarDefault"]);
	local obj = ParaScene.CreateMeshPhysicsObject("avatar_minimap", _asset, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
	if( obj:IsValid())then
		obj:SetScale(Map3DSystem.UI.MiniMapManager.assetScale);
		obj:GetAttributeObject():SetField("progress", 1);
		scene:AddChild(obj);
	end
end

-- register the camera object in the mini map
function Map3DSystem.UI.MiniMapManager.RegisterCameraObject()
	local scene = Map3DSystem.UI.MiniMapWnd.GetScene();
	local _asset = ParaAsset.LoadStaticMesh("", Map3DSystem.UI.MiniMapManager.AssetListDefault["assetCameraDefault"]);
	local obj = ParaScene.CreateMeshPhysicsObject("camera_minimap", _asset, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
	if( obj:IsValid())then
		obj:SetScale(Map3DSystem.UI.MiniMapManager.assetScale);
		obj:GetAttributeObject():SetField("progress", 1);
		scene:AddChild(obj);
	end
end

-- register the OPC object in mini map
-- @param opcname: OPC name
-- @param assetname: if no asset name is specified, use default asset name
-- @param texturename: background file shown on local map or other 2D map implementation, if no texture name is specified, use default texture name
function Map3DSystem.UI.MiniMapManager.RegisterOPCObject(opcname, assetname, texturename)
	if(ParaScene.GetObject(opcname) == nil) then
		log("warning: register a non-exist OPC to mini map. opcname: "..opcname..".\n");
		return;
	end
	if(assetname == nil) then
		-- not specify the asset name, use default
		assetname = Map3DSystem.UI.MiniMapManager.AssetListDefault["assetOPCDefault"];
	end
	local _asset = ParaAsset.LoadStaticMesh("", assetname);
	
	-- create mini scene object
	local obj;
	local scene = Map3DSystem.UI.MiniMapWnd.GetScene();
	obj = ParaScene.CreateMeshPhysicsObject("OPC_"..opcname, _asset, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
	if(obj:IsValid()) then
		obj:SetScale(Map3DSystem.UI.MiniMapManager.assetScale);
		obj:GetAttributeObject():SetField("progress", 1);
		scene:AddChild(obj);
	end
	-- insert the opcname in OPC list
	table.insert(Map3DSystem.UI.MiniMapManager.OPCList, {name = opcname, texturename = texturename});
end

-- unregister the OPC object in mini map
-- @param opcname: OPC name
function Map3DSystem.UI.MiniMapManager.UnregisterOPCObject(opcname)
	-- remove mini scene object
	local obj;
	local scene = Map3DSystem.UI.MiniMapWnd.GetScene();
	scene:DestroyObject("OPC_"..opcname);
	
	-- remove the opcname in OPC list
	local k, v;
	for k, v in pairs(Map3DSystem.UI.MiniMapManager.OPCList) do
		if(v.name == opcname) then
			Map3DSystem.UI.MiniMapManager.OPCList[k] = nil;
		end
	end
end

-- register the Portal object in mini map
-- @param portalname: Portal object name
-- @param assetname: if no asset name is specified, use default asset name
-- @param texturename: background file shown on local map or other 2D map implementation, if no texture name is specified, use default texture name
function Map3DSystem.UI.MiniMapManager.RegisterPortalObject(portalname, texturename)
	if(ParaScene.GetObject(portalname) == nil) then
		log("warning: register a non-exist portal object to mini map. portalname: "..portalname..".\n");
		return;
	end
	if(assetname == nil) then
		-- not specify the asset name, use default
		assetname = Map3DSystem.UI.MiniMapManager.AssetListDefault["assetPortalDefault"];
	end
	local _asset = ParaAsset.LoadStaticMesh("", assetname);
	
	-- create mini scene object
	local obj;
	local scene = Map3DSystem.UI.MiniMapWnd.GetScene();
	obj = ParaScene.CreateMeshPhysicsObject("Portal_"..portalname, _asset, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
	if(obj:IsValid()) then
		obj:SetScale(Map3DSystem.UI.MiniMapManager.assetScale);
		obj:GetAttributeObject():SetField("progress", 1);
		scene:AddChild(obj);
	end
	-- insert the portalname in Portal list
	table.insert(Map3DSystem.UI.MiniMapManager.PortalList, {name = portalname, texturename = texturename});
end

-- unregister the Portal object in mini map
-- @param portalname: Portal name
function Map3DSystem.UI.MiniMapManager.UnregisterPortalObject(portalname)
	-- remove mini scene object
	local obj;
	local scene = Map3DSystem.UI.MiniMapWnd.GetScene();
	scene:RemoveObject("Portal_"..portalname);
	
	-- remove the portalname in Portal list
	local k, v;
	for k, v in pairs(Map3DSystem.UI.MiniMapManager.PortalList) do
		if(v.name == portalname) then
			Map3DSystem.UI.MiniMapManager.PortalList[k] = nil;
		end
	end
end