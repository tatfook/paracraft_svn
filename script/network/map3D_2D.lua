
--[[

*****this file is deprecated******


NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/network/map3D.lua");

local map2DLayer = {
	name = "2dlayer",
	positionX = 0,
	positionY = 0,
	positionZ = 0,
	tileSize = 0,
	tileCountV = 0,
	tileCountH = 0,
	sceneGraph = nil,
	virtCam = nil,	
	mapTiles = {},
	modelFilePath ="model/common/map3D/map3D.x";
	tileTexturePath = "Texture/worldMap/default.jpg";
	tileModel;
	tileTextures,
	level = 1,
	mapSet = nil;
	isVisible = true;
	isInited = false;
	isAssetLoaded = false;
	enabled = true;
	
	maxZoomLevel = 5;
	
	maxCamMapDist,
	minCamMapDist = 14,
	zoomSpan = 0.4;
	maxViewPos = 0;
}
MapSystem.map2DLayer = map2DLayer;

function map2DLayer:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;
end

function map2DLayer:Destroy()
end

function map2DLayer:Initialization()
	if(self.isInited)then
		return;
	end
	
	if( self.name == nil)then
		log("map2DLayer:layer name can not be nil -_-\r\n");
		return;
	end
	
	if( self.sceneGraph == nil)then
		log("map2DLayer:need a scene to initialize layer");
		return;
	end
	
	self:LoadAsset();
	--create map tiles in xy plan
	for i = 1,self.tileCountV do
		self.mapTiles[i] = {};
		for j = 1,self.tileCountH do
			self.mapTiles[i][j] = ParaScene.CreateMeshPhysicsObject("cell_0_0",self.tileModel,1,1,1,false,"1,0,0,0,1,0,0,0,1,0,0,0");
			if( self.mapTiles[i][j]:IsValid())then
				self.mapTiles[i][j]:SetPosition((j-1)*self.tileSize,(i-1)*self.tileSize,self.positionZ);
				self.mapTiles[i][j]:Rotate(-math.pi/2,math.pi/2,0);
				self.mapTiles[i][j]:SetScale(self.tileSize);
				self.mapTiles[i][j].tag = nil;
				self.mapTiles[i][j]:SetReplaceableTexture(1,self.tileTextures);
				self.sceneGraph:AddChild(self.mapTiles[i][j]);
			end
		end
	end	
	
	NPL.load("(gl)script/network/map3d_mapSet.lua");
	self.mapSet = MapSystem.mapSet:new{
		name = "ms",
		mapFilePath = "Texture/worldMap",
		fileFMT = "jpg";
	};
	self.isInited = true;	
end

function map2DLayer:LoadAsset()
	self.tileModel = ParaAsset.LoadStaticMesh("", self.modelFilePath);
	self.tileTextures = ParaAsset.LoadTexture("",self.tileTexturePath,1);
	
	if( self.tileModel:IsValid() and self.tileTextures:IsValid())then
		return true;
	else
		return false;
	end
end

function map2DLayer:Show(bshow)
	if( self.isInited == false)then
		self:Initialization();
	end
	
	if( bshow == nil)then
		self.isVisible = (self.isVisible and false) or true;
	else
		self.isVisible = bshow;
	end
	
	for i = 1,self.tileCountV do
		for j = 1,self.tileCountH do
			self.mapTiles[i][j]:SetVisible(self.isVisible);
		end
	end
end

function map2DLayer:Reset()
	if( self.sceneGraph == nil)then
		log("map2DLayer:sceneGraph can not be nil -_-\r\n");
		return;
	end

	self.sceneGraph:CameraSetLookAtPos(0,0,0);
	self.maxCamMapDist = self.tileSize/2/math.tan( math.pi/12);
	self.sceneGraph:CameraSetEyePos(0,0,-self.maxCamMapDist);
	
	if( self.virtCam == nil)then
		log("map2DLayer:virtual camera is nil -_-#\r\n");
		return false;
	end
	
	self.virtCam.viewPosX = self.tileSize/2;
	self.virtCam.viewPosY = self.tileSize/2;
	self.virtCam.worldPosX = 0.5;
	self.virtCam.worldPosY = 0.5;
	self.virtCam.viewRegion = self.tileSize;
	
	self.maxViewPos = self.tileSize / 2;
	self.level = 1;
	
	self:SetLookAtPosition(self.virtCam.viewPosX,self.virtCam.viewPosY,0);
	self:Refresh();
end

function map2DLayer:Update()
end

--Refresh the map texture
function map2DLayer:Refresh()
	if( self.isInited == false or self.enabled == false)then
		return;
	end
	
	local viewRegion = self.virtCam.viewRegion / self:GetMapSize(self.level);
	local textures = self.mapSet:GetMaps(self.virtCam.worldPosX - viewRegion/2,self.virtCam.worldPosY - viewRegion/2,viewRegion,self.level);
	
	for i = 0,self.tileCountV do
		if(self.mapTiles[i] ~= nil)then
			for j=1,self.tileCountH do
				if(self.mapTiles[i][j] ~= nil and textures[ j+(i-1)*self.tileCountH] ~= nil)then
					self.mapTiles[i][j]:SetReplaceableTexture(1,textures[ j+(i-1)*self.tileCountH]);
				end
			end
		end
	end
end

function map2DLayer:Zoom(deltaZoom)
	if( self.sceneGraph == nil or self.enabled == false)then
		return;
	end
	
	local yaw,pitch,distance = self.sceneGraph:CameraGetEyePosByAngle();
	distance = distance + deltaZoom * self.zoomSpan;
	
	if( distance > self.maxCamMapDist)then
		if( self.level > 1)then
			self.level = self.level - 1;
			distance = self.minCamMapDist;
		else
			distance = self.maxCamMapDist;
		end
	elseif( distance < self.minCamMapDist)then
		if( self.level < 5)then
			self.level = self.level + 1;
			distance = self.maxCamMapDist;
		else
			distance = self.minCamMapDist;
		end
	end

	self.sceneGraph:CameraSetEyePosByAngle(yaw,pitch,distance);
	self.virtCam.viewRegion = math.tan( MapSystem.fovOver2) * distance * 2;
	self.maxViewPos = self:GetMapSize(self.level) - self.virtCam.viewRegion/2;
	if(self.maxViewPos < 0)then
		self.maxViewPos = 0;
	end
	
	self:CheckBound();
	self:SetLookAtPosition(self.virtCam.viewPosX,self.virtCam.viewPosY,0);
	self:Refresh();
end

function map2DLayer:Move( dx,dy)
	if( self.sceneGraph == nil or self.enabled == false)then
		return;
	end
	
	local lastX = self.virtCam.viewPosX;
	local lastY = self.virtCam.viewPosY;
	
	self.virtCam.viewPosX = self.virtCam.viewPosX - dx * self:S2W();
	self.virtCam.viewPosY = self.virtCam.viewPosY - dy * self:S2W();
	self:CheckBound();
	
	if( self.virtCam.viewPosX == lastX and self.virtCam.viewPosY == lastY)then
		return;
	end

	self:SetLookAtPosition(self.virtCam.viewPosX,self.virtCam.viewPosY,0);
	self:Refresh();
end

function map2DLayer:CheckBound()
	local offset = self.virtCam.viewRegion/2;
	
	if( self.virtCam.viewPosX > self.maxViewPos)then
		self.virtCam.viewPosX = self.maxViewPos;
	elseif( self.virtCam.viewPosX - offset < 0)then
		self.virtCam.viewPosX = offset;
	end

	if( self.virtCam.viewPosY  > self.maxViewPos)then
		self.virtCam.viewPosY  = self.maxViewPos;
	elseif( self.virtCam.viewPosY - offset < 0)then
		self.virtCam.viewPosY = offset;
	end
	
	self.virtCam.worldPosX = self.virtCam.viewPosX / self:GetMapSize(self.level);
	self.virtCam.worldPosY = self.virtCam.viewPosY / self:GetMapSize(self.level);
end

--x,y,z are the in map screen coordinate
function map2DLayer:SetLookAtPosition(x,y,z)
	if( self.enabled == false)then
		return;
	end
	
	x = - math.mod(x - self.tileSize/2,self.tileSize);
	y = math.mod(y - self.tileSize/2,self.tileSize);
	for i = 1,self.tileCountV do
		if( self.mapTiles[i] ~= nil)then
			for j=1,self.tileCountH do
				if( self.mapTiles[i][i] ~= nil)then
					self.mapTiles[i][j]:SetPosition( x + (j-1)*self.tileSize,y - (i-1)*self.tileSize,z);
				end
			end
		end
	end
end

--get the map size of specific level
function map2DLayer:GetMapSize(level)
	if( level < 0)then
		return 0;
	end
	if( level > self.maxZoomLevel)then
		level = self.maxZoomLevel;
	end
	return	self.tileSize * math.pow( 2,level - 1); 
end

--set zoom level
function map2DLayer:SetLevel(lvl)
	if( lvl > self.maxZoomLevel)then
		self.level = self.maxZoomLevel;
	elseif( lvl < 1)then
		self.level = 1;
	else
		self.level = lvl;
	end
end

function map2DLayer:SetEnable(isEnabled)
	self.enabled = isEnabled;
end

function map2DLayer:S2W()	
	if( self.sceneGraph == nil)then
		return 0;
	end
	
	local __,__,camHeight = self.sceneGraph:CameraGetEyePos();
	return 0.001*camHeight;
end

--]]