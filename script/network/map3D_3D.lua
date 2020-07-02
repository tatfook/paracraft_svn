
--[[

*****this file is deprecated******

NPL.load("gl)script/ide/common_control.lua");
NPL.load("(gl)script/network/map3D.lua");

local map3DLayer = {
	name = "3dlayer",
	width = 8,
	tileSize = 4,
	sceneGraph = nil,
	virtCam = nil,
	mapTiles = {},
	skybox = nil,
	worldPosX = 0,
	worldPosY = 0,
	worldPosZ = 0,

	minWorldPos = 0,
	maxWorldPos = 0,

	worldPosOffsetX = 0,
	worldPosOffsetY = 0,
		
	visible,
	enabled = false,
	isInited = false,
	maxCamMapDist = 36,
	--maxCamMapDist = 100,
	minCamMapDist = 3,
	maxPitch = 2.8,
	minPitch = 1.6; -- ~pi/2
	defaultYaw = math.pi;
	frontTileX = 0;
	frontTileY = 0;
	enabled = true;
}
MapSystem.map3DLayer = map3DLayer;

function map3DLayer:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;
end

function map3DLayer:Destroy()
end

function map3DLayer:Initialization()
	if( self.IsInited)then
		return;
	end
	
	if( self.name == nil)then
		log("map3DLayer:layer name can not be nil -_-\r\n");
		return;
	end
	
	if( self.sceneGraph == nil)then
		log("map3DLayer:need a scene to initialization layer -_-\r\n");
		return;
	end
	
	if( math.mod( self.width,2) > 0)then
		self.maxWorldPos = (self.width - 1)/2*self.tileSize;	
		self.minWorldPos = -maxWorldPos;
	else
		self.maxWorldPos = (self.width/2 - 0.5) * self.tileSize;
		self.minWorldPos = -self.maxWorldPos;
	end
	
	--local skyboxModel = ParaAsset.LoadStaticMesh("","/model/Skybox/skybox3/skybox3.x");
	--self.skybox = ParaScene.CreateMeshPhysicsObject("mp_skybox",skyboxModel,1,1,1,false,"1,0,0,0,1,0,0,0,1,0,0,0");
	--ParaScene.CreateSkyBox("mp_skybox",skyboxModel, self.width*self.tileSize,self.width*self.tileSize,self.width*self.tileSize, 0);
	
	for i = 1,self.width do
		self.mapTiles[i] = {};
		for j = 1,self.width do
			self.mapTiles[i][j] = MapSystem.map3DTile:new{
				name=self.name..i.."_"..j,
				sceneGraph = self.sceneGraph,
				tileSize = self.tileSize,
				positionX = self.minWorldPos + (j - 1) * self.tileSize;
				positionZ = self.minWorldPos + (i - 1) * self.tileSize;
			}
			self.mapTiles[i][j]:Initialization();
		end
	end
	self.isInited = true;
end

function map3DLayer:Reset()
	if( self.sceneGraph == nil or self.isInited == false)then
		log("map3DLayer:sceneGraph can not be nil -_-#\r\n");
		return;
	end
	
	--set camera to default position
	self.sceneGraph:CameraSetEyePosByAngle(self.defaultYaw,self.minPitch,self.maxCamMapDist);
	self.sceneGraph:CameraSetLookAtPos(0,0,0);

	for i=1,self.width do
		for j=1,self.width do
			self:SetTileLod(self.mapTiles[i][j]);
		end
	end
end

function map3DLayer:Show(bshow)
	if( self.isInited == false)then
		self:Initialization();
	end

	if( bshow == nil)then
		self.isVisible = (self.isVisible and false) or true;
	else
		self.isVisible = bshow;
	end
	
	
	for i = 1,self.width do
		for j=1,self.width do
			if( self.mapTiles[i][j] ~= nil)then
				self.mapTiles[i][j]:Show(self.isVisible);
			end
		end
	end
end

function map3DLayer:Zoom(deltaZoom)
	if( self.sceneGraph == nil or self.enabled == false)then
		return;
	end

	local yaw,pitch,distance = self.sceneGraph:CameraGetEyePosByAngle();
	log( string.format("distance:%s\n",distance));
	distance = distance + deltaZoom * 0.4;
	log( string.format("distance:%s\n",distance));
	if( distance > self.maxCamMapDist)then
		distance = self.maxCamMapDist;
	elseif( distance < self.minCamMapDist)then
		distance = self.minCamMapDist;
	end
	log( string.format("distance:%s\n",distance));
	log("~~~~~~~~~~~~~~~~~\n");
	self.sceneGraph:CameraSetEyePosByAngle(yaw,pitch,distance);
	
	for i=1,self.width do
		for j=1,self.width do
			self:SetTileLod(self.mapTiles[i][j]);
		end
	end
end

function map3DLayer:Pitch( delta )
	if( self.sceneGraph == nil and self.enabled == false)then
		return;
	end
	
	local yaw,pitch,distance = self.sceneGraph:CameraGetEyePosByAngle();
	pitch = pitch + delta * 0.1;

	if( pitch > self.maxPitch)then
		pitch = self.maxPitch;
	elseif( pitch < self.minPitch)then
		pitch = self.minPitch;
	end
	
	self.sceneGraph:CameraSetEyePosByAngle(yaw,pitch,distance); 
	
	for i=1,self.width do
		for j=1,self.width do
			self:SetTileLod(self.mapTiles[i][j]);
		end
	end
end

function map3DLayer:Rotate(delta)
	if( self.sceneGraph == nil and self.enabled == false)then
		return;
	end
	
	local yaw,pitch,distance = self.sceneGraph:CameraGetEyePosByAngle();
	yaw = yaw + delta * 0.1;
	
	self.sceneGraph:CameraSetEyePosByAngle(yaw,pitch,distance);
	
	for i=1,self.width do
		for j=1,self.width do
			self:SetTileLod(self.mapTiles[i][j]);
		end
	end
end

function map3DLayer:SetEnable(isEnable)
	self.enabled = isEnable;
end

function map3DLayer:Move(dx,dy)
	if( self.IsInited or self.enabled == false)then
		return;
	end
	
	--how much we should move along x,y axis after rotation
	local deltaYaw = self.defaultYaw - self.sceneGraph:CameraGetEyePosByAngle();
	local d_x = (math.cos(deltaYaw)*dx + math.sin(deltaYaw)*dy)*0.02;
	local d_y = (math.cos(deltaYaw)*dy - math.sin(deltaYaw)*dx)*0.02;
	--make sure the map won't move too fast when drag
	if( d_x > self.tileSize)then
		d_x = self.tileSize;
	end
	if( d_y > self.tileSize)then
		d_y = self.tileSize;
	end
	
	--move all tiles
	for i=1,self.width do
		for j=1,self.width do
			self.mapTiles[i][j]:Move(-d_x,0,d_y);	
			self:SetTileLod(self.mapTiles[i][j]);
		end
	end

	--wrap tile position when reach the grid bound
	local x,__,z = self.mapTiles[self.frontTileY + 1][self.frontTileX+1]:GetPosition();
	local min = self.minWorldPos - self.tileSize;
	local max = self.minWorldPos + self.tileSize;
	local lastFront = self.frontTileX;

	if( x < min)then
		self.frontTileX = math.mod(self.frontTileX + 1,self.width);
		for i = 1,self.width do
			local tx,ty,tz = self.mapTiles[i][lastFront+1]:GetPosition();
			self.mapTiles[i][lastFront+1]:SetPosition(tx + self.width*self.tileSize,ty,tz);
		end
	end
	
	if( x > max)then
		self.frontTileX = math.mod( self.frontTileX-1+self.width,self.width);
		for i = 1,self.width do
			local tx,ty,tz = self.mapTiles[i][self.frontTileX+1]:GetPosition();
			self.mapTiles[i][self.frontTileX+1]:SetPosition(tx - self.width*self.tileSize,ty,tz);
		end
	end
	
	lastFront = self.frontTileY;
	if( z < min)then
		self.frontTileY = math.mod(self.frontTileY + 1,self.width);
		for i = 1,self.width do
			local tx,ty,tz = self.mapTiles[lastFront+1][i]:GetPosition();
			self.mapTiles[lastFront+1][i]:SetPosition(tx,ty,tz + self.width*self.tileSize);
		end
	end
	
	if( z > max)then
		self.frontTileY = math.mod(self.frontTileY-1+self.width,self.width);
		for i = 1,self.width do
			local tx,ty,tz = self.mapTiles[self.frontTileY+1][i]:GetPosition();
			self.mapTiles[self.frontTileY+1][i]:SetPosition(tx,ty,tz - self.width*self.tileSize);
		end
	end
end

function map3DLayer:Update(x,y,z,viewRegion,level)
end

function map3DLayer:Refresh()
end

function map3DLayer:SetTileLod(tile)
	if( self.sceneGraph == nil or tile == nil)then
		return;
	end

	local tilePosX,__,tilePosZ = tile:GetPosition();
	
	tilePosX = math.abs(tilePosX);
	tilePosZ = math.abs(tilePosZ);
	
	local span = self.tileSize * 3;
	tile:SetLod(math.floor(math.max( tilePosX / span, tilePosZ / span))*2);
end

function map3DLayer:GetPosition()
end

function map3DLayer:SetMapPosition()

end

--------------------------------------------------------------------
local map3DTile = {
	name = "tile1",
	positionX = 0,
	positionY = 0,
	positionZ = 0,
	sceneGraph = nil,
	tile = nil,
	models = nil,
	modelCount = 0,
	maxModelCount = 16,
	tileSize = 0,
	
	tileModelFile = "model/common/map3D/map3D.x";
	isVisible = true,
	isInited = false,
	visibleModelCount = 0,
	lodLevel = 0,
}
MapSystem.map3DTile = map3DTile;

function map3DTile:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;
end

function map3DTile:Destroy()

end

function map3DTile:Initialization()
	if(self.isInited)then
		return;
	end
	
	if( self.name == nil)then
		log("map3DTile:tile name can not be  nil -_-#\r\n");
		return;
	end
	
	if( self.sceneGraph == nil)then
		log("map3DLayer:need a scene to initialize tile -_-#\r\n");
		return;
	end
	
	--create tile
	local texture =  ParaAsset.LoadTexture("","model/map3D/bg_"..math.random(4)..".dds",1);
	local model = ParaAsset.LoadStaticMesh("",self.tileModelFile);	
	self.tile = ParaScene.CreateMeshPhysicsObject(self.name.."tile",model,1,1,1,false,"1,0,0,0,1,0,0,0,1,0,0,0");
	self.tile:GetAttributeObject():SetField("progress",1);
	self.tile:SetScale(self.tileSize);
	self.tile:SetPosition(self.positionX,self.positionY,self.positionZ);
	self.tile:SetReplaceableTexture(1,texture)
	self.sceneGraph:AddChild(self.tile);
	
	self.models = {};
	--get some random model info to fill the tile
	local tempModels = MapTest.CreateModels();
	self.modelCount = tempModels.modelCount;
	self.visibleModelCount = self.modelCount;
	--create all model in a tile
	for i = 1,self.modelCount do
		self.models[i] = {};
		self.models[i].modelData = tempModels.modelInfos[i];
		self.models[i].model = ParaScene.CreateMeshPhysicsObject("1",self.models[i].modelData.model,1,1,1,false,"1,0,0,0,1,0,0,0,1,0,0,0");
		self.models[i].model:SetPosition( self.positionX + self.models[i].modelData.offsetX, self.positionY + 0.08,self.positionZ + self.models[i].modelData.offsetY);
		self.models[i].model:SetFacing( self.models[i].modelData.facing);
		self.sceneGraph:AddChild( self.models[i].model);
	end
	
	--self.player = ParaScene.CreateCharacter("",MapTest.character,"",true, 0.2, 3.9, 1.0);
	--if( self.player:IsValid())then
		--self.player:SetPosition( self.positionX,self.positionY + 0.08,self.positionZ);
		--self.sceneGraph:AddChild(self.player);
	--end
	self.isInited = true;
end

function map3DTile:Show(bshow)
	if( self.isInited == false)then
		self:Initialization();
	end
	
	if( bshow == nil)then
		self.isVisible = (self.isVisible and false) or true;
	else
		self.isVisible = bshow;
	end
	
	self.tile:SetVisible(self.isVisible);
	for i = 1,self.modelCount do
		self.models[i].model:SetVisible(self.isVisible);
	end
end

function map3DTile:Refresh()
end

function map3DTile:SetPosition(x,y,z)
	self.positionX = x;
	self.positionY = y;
	self.positionZ = z;
	if( self.tile ~= nil)then
		self.tile:SetPosition( self.positionX,self.positionY,self.positionZ);
	end
end

function map3DTile:Move(dx,dy,dz)
	self.positionX = self.positionX + dx;
	self.positionY = self.positionY + dy;
	self.positionZ = self.positionZ + dz;
	
	if( self.tile ~= nil)then
		self.tile:SetPosition( self.positionX,self.positionY,self.positionZ);
	end
	
	--only update visible building
	for i=1,self.visibleModelCount do
		local x,y,z = self.models[i].model:GetPosition();
		self.models[i].model:SetPosition( self.positionX + self.models[i].modelData.offsetX, self.positionY + 0.08,self.positionZ + self.models[i].modelData.offsetY);
		x,y,z = self.models[i].model:GetPosition();
	end
	
	--self.player:SetPosition( self.positionX,self.positionY + 0.08,self.positionZ);
end

function map3DTile:ReleaseModel()
	if( self.sceneGraph == nil)then
		return;
	end
	
	for i = 0,modelCount do
		self.sceneGraph:RemoveObject( models[i]);
	end
end

function map3DTile:GetPosition()
	return self.positionX,self.positionY,self.positionZ;
end

function map3DTile:SetLod(level)
	if( self.isVisible == false)then
		return;
	end
	
	if( level < 0)then
		level = 0;
	end
	
	if( self.lodLevel == level)then
		return;
	end
	
	self.lodLevel = level;
	
	--decide how many building to show in a tile:16/8/4/2/1/0
	self.visibleModelCount = math.floor(math.min( self.modelCount, self.maxModelCount/math.pow(2,level)));

	for i = 1,self.modelCount do
		self.models[i].model:SetVisible(true);
	end
	
	for i = self.visibleModelCount + 1, self.modelCount do
		self.models[i].model:SetVisible(false);
	end
end


----------------------------------------------------------------------
--modelData records model info for a tile
--we'll get this data from database
local modelData = { 
	model = nil,
	texture = nil,
	facing = nil,
	offsetX = 0,
	offsetY = 0,
}
MapSystem.modelData = modelData;

function modelData:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;
end


------------------------------------------------------------------------
if( not MapTest)then MapTest = {};end;

MapTest.models = {};
MapTest.models[1] = ParaAsset.LoadStaticMesh("","model/map3D/building/villa3/villa3.x");
MapTest.models[2] = ParaAsset.LoadStaticMesh("","model/map3D/building/Tower/Tower.x");
MapTest.models[3] = ParaAsset.LoadStaticMesh("","model/map3D/building/tree/tree2.x");
MapTest.models[4] = ParaAsset.LoadStaticMesh("","model/map3D/building/tree2/tree2.x");
MapTest.models[5] = ParaAsset.LoadStaticMesh("","model/map3D/building/highrice/highrice.x");
MapTest.models[6] = ParaAsset.LoadStaticMesh("","model/map3D/building/house/house.x");
MapTest.models[7] = ParaAsset.LoadStaticMesh("","model/map3D/building/fengche/fengche.x");
MapTest.models[8] = ParaAsset.LoadStaticMesh("","model/map3D/building/Memorialhall/Memorialhall.x");
MapTest.models[9] = ParaAsset.LoadStaticMesh("","model/map3D/building/youlechang/youlechang.x");
MapTest.models[10] = ParaAsset.LoadStaticMesh("","model/map3D/building/bank/bank.x");
MapTest.models[11] = ParaAsset.LoadStaticMesh("","model/map3D/building/Centersquare1/Centersquare1.x");
MapTest.models[12] = ParaAsset.LoadStaticMesh("","model/map3D/building/Centersquare2/Centersquare2.x");
MapTest.models[13] = ParaAsset.LoadStaticMesh("","model/map3D/building/highrice1/highrice1.x");

MapTest.character = ParaAsset.LoadParaX("","character/map3d/man/man.x");

MapTest.offsets = {};
MapTest.offsets[1] = { x = -1.5,z = -1.5};
MapTest.offsets[2] = { x = -0.5,z = -1.5};
MapTest.offsets[3] = { x = 0.5,z = -1.5};
MapTest.offsets[4] = { x = 1.5,z = -1.5};
MapTest.offsets[5] = { x = -1.5,z = -0.5};
MapTest.offsets[6] = { x = -0.5,z = -0.5};
MapTest.offsets[7] = { x = 0.5,z = -0.5};
MapTest.offsets[8] = { x = 1.5,z = -0.5};
MapTest.offsets[9] = { x = -1.5,z = 0.5};
MapTest.offsets[10] = { x = -0.5,z = 0.5};
MapTest.offsets[11] = { x = 0.5,z = 0.5};
MapTest.offsets[12] = { x = 1.5,z = 0.5};
MapTest.offsets[13] = { x = -1.5,z = 1.5};
MapTest.offsets[14] = { x = -0.5,z = 1.5};
MapTest.offsets[15] = { x = 0.5,z = 1.5};
MapTest.offsets[16] = { x = 1.5,z = 1.5};

MapTest.facing = {};
MapTest.facing[1] = math.pi;
MapTest.facing[2] = math.pi/2;
MapTest.facing[3] = math.pi*3/2;
MapTest.facing[4] = 0;

function MapTest:CreateModels()
	--modelSet include model count and model details for a tile
	local modelSet = {};
	
	--the model number in a tile
	modelSet.modelCount = math.random(16);
	--modelSet.modelCount = 0;
	
	local pos = {};
	for i=1,16 do
		pos[i] = {};
		pos[i].isOccupied = false;
		pos[i].position = MapTest.offsets[i];
	end
	
	modelSet.modelInfos = {};
	for i =1,modelSet.modelCount do
		--choose a subtile to put the model in
		local index = math.random(16);
		while( pos[index].isOccupied == true) do
			index = math.random(16);
		end
		pos[index].isOccupied = true;
		
		modelSet.modelInfos[i] = MapSystem.modelData:new{
			model = MapTest.models[ math.random(13)];
			--model = MapTest.models[ math.random(4)];
			facing = MapTest.facing[ math.random(4)];
			offsetX = pos[index].position.x;
			offsetY = pos[index].position.z;
		}
	end
	return modelSet;
end


--self.tile:CheckAttribute(3);
--self.tile:CheckAttribute(2);
--self.tile:SetAttribute(2,true);
--self.tile:SetAttribute(3,true);
--]]