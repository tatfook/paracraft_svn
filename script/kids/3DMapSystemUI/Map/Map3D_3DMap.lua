
--[[
Title: display 3D map
Author(s): Sun Lingfeng
Date: 2007/1/20
Use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3D_3DMap.lua");
local _this = Map3DApp.Map3DLayer:new{
	name = "3DMap",
}
uiContainer:SetBGImage(_this:GetMap());
-------------------------------------------------------
]]

NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppCommon.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppTile.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppVirtualCamera.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DCell.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/landCell.lua");


if(not Map3DApp) then Map3DApp = {};end;

local Map3DLayer = {
	name = "map3D",
	resolutionX = 1024,
	resolutionY = 1024,
	scene = nil,
	onViewRegionChange = nil,
	visible = false,
	
	--
	virtCam = nil,
	minCamElevation = 2,
	maxCamElevation = 12,
	cameraHeight = 0,
	minPitch = 0.5,
	maxPitch = 1.3,
	defaultYaw = 0,
	
	--total number of tiles in map 
	mapDimension = 32768,
	--displayed number of tiles in 3D map
	tileDimension = 10,
	tileSize = 4.5,
	posX = 0;
	posY = 0;
	posZ = 0;
	
	--
	cells = {};
	childLayers = {};
	--
	panStep = 0.0000001;
	
	--event
	--fired when reach the min zoom state
	onMinZoom = nil;
	onMinZoomSubscriber = nil;
	listeners = {};
}
Map3DApp.Map3DLayer = Map3DLayer;


function Map3DLayer:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	
	--create virtual camera
	o.virtCam = Map3DApp.VirtualCamera:new{
		name = "3dMapCamera",
		viewPosX = 0.5;
		viewPosY = 0.5;
		viewPosZ = 0;
		viewRegion = 5 * Map3DApp.DataPvd.GetLogicCellSize(),
	};

	--create map cells
	local left = -math.floor(o.tileDimension / 2) * o.tileSize;
	o.cells = {};
	for i = 1,o.tileDimension do
		o.cells[i] = {};
		for j = 1,o.tileDimension do
			o.cells[i][j] = Map3DApp.LandCell:new{
				name = "landCell".."_"..i.."_"..j,
				tileSize = o.tileSize,
				pos_x = left + (j - 1) * o.tileSize;
				pos_z = left + (j - 1) * o.tileSize;
				pos_y = 0,
			};
		end
	end

	CommonCtrl.AddControl(o.name,o);
	return o;
end

--Destory object
function Map3DLayer:Destory()
	--destory all map tiles
	if(self.tiles ~= nil)then
		for i = 1,self.tileDimension do
			for j = 1,self.tileDimension do
				tile = Map3DApp.Global.GetTile(self.tiles[i][j])
				if(tile ~= nil)then
					tile:Destroy();
				end
			end
		end
		self.tiles = nil;
	end
	
	--destory scene
	local scene = ParaScene.GetMiniSceneGraph(self.name);
	if(scene:IsValid())then
		scene:DestroyChildren();
	end
	ParaScene.DeleteMiniSceneGraph(self.name);
	
	self.name = nil;
	self.onViewRegionChange = nil;
	self.virtCam = nil;
end

function Map3DLayer:GetMap()
	local scene = ParaScene.GetMiniSceneGraph(self.name);
	local flagObject = scene:GetObject(self.name);
	if(flagObject:IsValid() == false)then
		self:ResetScene();
	end
	return scene:GetTexture();
end

--private,recreate scene after scene reset
function Map3DLayer:ResetScene()
	--reset scene
	local scene = ParaScene.GetMiniSceneGraph(self.name);
	scene:Reset();
	scene:SetRenderTargetSize(self.resolutionX,self.resolutionY);
	scene:EnableCamera(true);
	scene:EnableActiveRendering(true);
	
	local att = scene:GetAttributeObject();
	--att:SetField("EnableFog",true);
	--att:SetField("FogColor",{1,1,1});
	--att:SetField("FogStart",10);
	--att:SetField("FogEnd",50);
	--att:SetField("FogDensity",0.95);
	
	--this is a invisible object,we use it to check if the scene is reseted later.
	local model = Map3DApp.Global.AssetManager.GetModel("model/06props/shared/pops/huaban.x");
	if(model ~= nil)then
		local flagObject = ParaScene.CreateMeshPhysicsObject(self.name,model,1,1,1,false,"1,0,0,0,1,0,0,0,1,0,0,0");
		flagObject:SetVisible(false);
		flagObject:GetAttributeObject():SetField("progress",1);
		scene:AddChild(flagObject);
	end
	
	--reset all children if any
	for i = 1,self.tileDimension do
		for j = 1,self.tileDimension do
			self.cells[i][j]:SetScene(scene);
			self.cells[i][j]:Show(true);
		end
	end
end

function Map3DLayer:ResetCamera()
	local scene = ParaScene.GetMiniSceneGraph(self.name);
	if(scene:IsValid() == false)then
		return;
	end
	
	scene:CameraSetEyePosByAngle(self.defaultYaw,0.785,0);
	self:SetViewElevation(0.01);
end

function Map3DLayer:Pan(dx,dy)
	local scene = ParaScene.GetMiniSceneGraph(self.name);
	if(scene:IsValid() == false)then
		return;
	end

	local yaw = scene:CameraGetEyePosByAngle();
	local theta = yaw - self.defaultYaw;
	local x = math.cos(theta)*dx + math.sin(theta)*dy;
	local y = math.cos(theta)*dy - math.sin(theta)*dx;
	
	self:SetViewPosition(self.virtCam.viewPosX + x,self.virtCam.viewPosY + y);
end

function Map3DLayer:SetViewPosition(x,y)
	local scene = ParaScene.GetMiniSceneGraph(self.name);
	if(scene:IsValid() == false)then
		return;
	end
	
	if(x > 1)then
		x = 1;
	elseif(x < 0)then
		x = 0;
	end
	self.virtCam.viewPosX = x;
	
	if( y > 1)then
		y = 1;
	elseif(y < 0)then
		y = 0;
	end
	self.virtCam.viewPosY = y;

	local mod = math.mod(self.virtCam.viewPosX,Map3DApp.DataPvd.GetLogicCellSize());
	--logic x position of the top left cell
	local logicX = self.virtCam.viewPosX - mod - math.floor(self.tileDimension/2)*Map3DApp.DataPvd.GetLogicCellSize();
	local offset = -mod / Map3DApp.DataPvd.GetLogicCellSize() * self.tileSize;
	--3D world x position of the most left cell
	local worldX = offset - math.floor(self.tileDimension/2) * self.tileSize;
	
	mod = math.mod(self.virtCam.viewPosY,Map3DApp.DataPvd.GetLogicCellSize());
	--logic y postion of the top left cell
	local logicY = self.virtCam.viewPosY - mod - math.floor(self.tileDimension/2)*Map3DApp.DataPvd.GetLogicCellSize();
	offset = -mod / Map3DApp.DataPvd.GetLogicCellSize() * self.tileSize;
	--3D world y position of the top left cell
	local worldY = offset - math.floor(self.tileDimension/2)*self.tileSize;
	
	--the top left cell index of terrain grids;
	self.firstTileX = math.floor(math.mod(logicX,Map3DApp.DataPvd.GetLogicCellSize() * self.tileDimension)/Map3DApp.DataPvd.GetLogicCellSize());
	self.firstTileY = math.floor(math.mod(logicY,Map3DApp.DataPvd.GetLogicCellSize() * self.tileDimension)/Map3DApp.DataPvd.GetLogicCellSize());
	
	--update all tiles' position 
	local indexX,indexY;
	for i = 1,self.tileDimension do
		indexY = math.mod(self.firstTileY + i - 1,self.tileDimension) + 1;
		for j = 1,self.tileDimension do
			indexX = math.mod( self.firstTileX + j - 1,self.tileDimension)+1;
			local cell = self.cells[indexX][indexY];
			cell:SetLogicPosition(logicX+(j-1)*Map3DApp.DataPvd.GetLogicCellSize(),logicY+(i-1)*Map3DApp.DataPvd.GetLogicCellSize());
			cell:SetWorldPosition(worldX+(j-1)*self.tileSize,0,worldY+(i-1)*self.tileSize);
		end
	end
end

function Map3DLayer:Pitch(delta)
	local scene = ParaScene.GetMiniSceneGraph(self.name);
	if(scene:IsValid() == false)then
		return;
	end
	
	local yaw,pitch,dist = scene:CameraGetEyePosByAngle();
	pitch = pitch + delta;
	if(pitch > self.maxPitch)then
		pitch = self.maxPitch;
	elseif(pitch < self.minPitch)then
		pitch = self.minPitch;
	end
	scene:CameraSetEyePosByAngle(yaw,pitch,dist);
end

function Map3DLayer:Rotate(delta)
	local scene = ParaScene.GetMiniSceneGraph(self.name);
	if(scene:IsValid() == false)then
		return;
	end
	
	local yaw,pitch,dist = scene:CameraGetEyePosByAngle();
	yaw = yaw + delta;
	yaw = math.mod(yaw,math.pi*2);
	scene:CameraSetEyePosByAngle(yaw,pitch,dist);
end

function Map3DLayer:Zoom(delta)
	self.virtCam.viewPosZ = self.virtCam.viewPosZ + delta;
	self:SetViewElevation(self.virtCam.viewPosZ);
end

function Map3DLayer:SetViewElevation(elevation)
	if(elevation > 1)then
		elevation = 1;
	elseif(elevation < 0)then
		elevation = 0;
	end
	
	self.virtCam.viewPosZ = elevation;
	local realElevation = (1-self.virtCam.viewPosZ) * (self.maxCamElevation - self.minCamElevation) + self.minCamElevation;
	local scene = ParaScene.GetMiniSceneGraph(self.name);
	if(scene:IsValid())then
		local yaw,pitch = scene:CameraGetEyePosByAngle();
		scene:CameraSetEyePosByAngle(yaw,pitch,realElevation);
		
		--fire onMaxZoom event
		if(pitch > 0.785 and self.virtCam.viewPosZ <= 0)then
			self:SendMessage(Map3DApp.Msg.onMinZoom);
		end
	end
end

function Map3DLayer:ActiveRender(isActive)
	local scene = ParaScene.GetMiniSceneGraph(self.name);
	if(scene:IsValid())then
		scene:EnableActiveRendering(isActive);
	end
end

function Map3DLayer:GetPanStep()
	return (2-self.virtCam.viewPosZ) * self.panStep;
end

function Map3DLayer:GetViewParams()
	return self.virtCam.viewPosX,self.virtCam.viewPosY,self.virtCam.viewPosZ,self.virtCam.viewRegion;
end

function Map3DLayer:AddChildLayer(layerName,layer)
	self.childLayers[layerName] = layer;
	
	local scene = ParaScene.GetMiniSceneGraph(self.name);
	if(scene:IsValid() and layer.SetScene)then
		layer:SetScene(scene);
	end
end

function Map3DLayer:RemoveLayer(layerName)
	self.childLayers[layerName] = nil;
end

--set render target size
function Map3DLayer:SetResolution(width,height)
	self.resolutionX = width;
	self.resolutionY = height;
	
	local scene = ParaScene.GetMiniSceneGraph(self.name);
	local flagObject = scene:GetObject(self.name);
	if(flagObject == nil or flagObject:IsValid() == false)then
		return;
	end
	self:OnSceneRest();
end

function Map3DLayer:GetRenderTargetSize()
	return self.resolutionX,self.resolutionY;
end

function Map3DLayer:MousePick(x,y)
	local scene = ParaScene.GetMiniSceneGraph(self.name);
	if(scene:IsValid()==false)then
		return;
	end
	
	local selectItem = scene:MousePick(x,y,50,"anyobject");
	if(selectItem ~= nil and selectItem.name ~= nil)then
		return selectItem;
	end
end


function Map3DLayer:AddListener(name,listener)
	self.listeners[name] = listener;
end

function Map3DLayer:RemoveListener(name)
	self.listeners[name] = nil;
end

function Map3DLayer:SendMessage(msg)
	if(self.listeners)then
		for __,listener in pairs(self.listeners) do
			listener:SetMessage(self.name,msg);
		end
	end
end

--delete this

--only call Init once
function Map3DLayer:Init()
	self:ResetScene();
end
--]]
