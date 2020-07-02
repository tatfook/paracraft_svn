
--use this lib;
--NPL.load("(gl)script/kids/3DMapSystemUI/Map/MapDataDefine.lua");

if(not Map3DApp)then Map3DApp = {};end

Map3DApp.Data = {};
function Map3DApp.Data.GetDataField(obj,field)
	if(obj[field] ~= nil)then
		return obj[field];
	end
end

function Map3DApp.Data.SetDataField(obj,field,value)
	if(obj[field] ~= nil)then
		obj[field] = value;
	end
end

--tileInfo
local tileInfo = {
	--object id
	id = 0,
	name = nil,
	
	x = 0,
	y = 0,
	z = 0,
	shape = 0,
	terrainInfo = nil, --terrainInfo
	models = nil, --modelInstance array
	
	--logicTileInfo
	ownerUserID = nil,
	ownerUserName = nil,
	tileState = 5,
	price = 0,
	price2 = 0,
	price2StartTime = nil,
	price2EndTime = nil,
	rentPrice = 0,
	rank = 0,
	cityName = nil,
	allowEdit = false,
	userUserID = nil,
	username = nil,
	rentEndDate = nil,
	image = nil,
	community = nil,
	ageGroup = nil, 
	worldid = 0,
	worldName = nil,
}
Map3DApp.TileInfo = tileInfo;

function tileInfo:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;
end

function tileInfo:GetTitle()
	return self.name;
end

--reset tileInfo to default value
function tileInfo:Reset()
	self.id = 0;
	self.name = nil;
	self.x = 0;
	self.y = 0;
	self.z = 0;
	self.shape = 0;
	self.terrainInfo = nil;
	self.models = nil;
	self.ownerUserID = nil;
	self.ownerUserName = nil;
	self.tileState = 5;
	self.price = 0;
	self.price2 = 0;
	self.price2StartTime = nil;
	self.price2EndTime = nil;
	self.rentPrice = 0;
	self.rank = 0;
	self.cityName = nil;
	self.allowEdit = false;
	self.userUserID = nil;
	self.username = nil;
	self.rentEndDate = nil;
	self.image = nil;
	self.community = nill;
	self.ageGroup = nil; 
	self.worldid = 0;
	self.worldName = nil;
end


--tileInfo pool
tileInfo.pool = {};
tileInfo.count = 0;
tileInfo.first = 0;
tileInfo.last = 0;
function tileInfo.CreateTileInfo()
	if(tileInfo.count < 1)then
		return tileInfo:new();
	else
		local tile = tileInfo.pool[tileInfo.first];
		tileInfo.first = tileInfo.first + 1;
		tileInfo.count = tileInfo.count - 1;
		return tile;
	end
end

function tileInfo.ReleaseTileInfo(tile)
	if(tile)then
		tile:Reset();
		if(tileInfo.count < 1)then
			tileInfo.first = 1;
			tileInfo.last = 1;
		else
			tileInfo.last = tileInfo.last + 1;
		end
		tileInfo.pool[tileInfo.last] = tile;
		tileInfo.count = tileInfo.count + 1;
	end
end

function tileInfo.ReleasePool()
	tileInfo.pool = {};
	tileInfo.count = 0;
	tileInfo.first = 0;
	tileInfo.last = 0;
end


----create a tileInfo container there
--Map3DApp.TileInfo.tileInfos = {};
--
--function Map3DApp.TileInfo.GetTileInfo(id)
	--return Map3DApp.TileInfo.tileInfos[id];
--end
--
--function Map3DApp.TileInfo.AddTileInfo(id,tileInfo)
	--Map3DApp.TileInfo.tileInfos[id] = tileInfo;
--end
--
--function Map3DApp.TileInfo.RemoveTileInfo(id)
	--if(Map3DApp.TileInfo.tileInfos[id])then
		--Map3DApp.TileInfo.tileInfos[id] = nil;
	--end
--end


--terrainInfo
local terrainInfo = {
	type = 1,
	textureID0 = 0,
	texture0 = nil,
	textureID1 = nil,
	texture1 = nil,
	rotation = 0,
};
Map3DApp.TerrainInfo = terrainInfo;

function terrainInfo:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;
end


--modelInfo
local modelInfo = {
	--object id
	id = 0,
	name = "mm_0_0", --mm means map model
	--geometry data
	model = nil,
	image = nil,
	tex0 = nil,	
	tex1 = nil,
	type = 1,
	--x = 0,
	--y = 0,
	--facing = 0,
	--logic data
	manufacturerType = 0,
	manufacturerID = "1",
	manufacturerName = "ParaEngine",
	price = 0,
	price2 = 0,
	price2StartTime = "00-00-00",
	price2EndTime = "00-00-00",
	adddate = "00-00-00",
	--OwnerUserID = nil,
	--OwnerUserName = nil,
	version = nil,
}
Map3DApp.ModelInfo = modelInfo;

function modelInfo:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;
end

function modelInfo:GetImage()
	return self.image;
end

function modelInfo:GetName()
	return self.name;
end
 

------------------------------
--world
------------------------------
local world = {
	id = 0,
	name = "",
	desc = "",
	version = nil,
	ownerID = 0,
	ownerName = "",
	spaceServer = nil,
	jabberGSL = nil,
	GSL = nil,
	gameServer = nil,
	visits = 0,
	rank = 1,
	ageGroup = 4,
	gameData = nil,
}
Map3DApp.World = world;

function world:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;
end


-----------------------------
---model instance--------
-----------------------------
local modelInstance = { 
	id = 0,
	modelID = 0,
	model = nil,
	texture = nil,
	facing = 0,
	offsetX = 0,
	offsetY = 0,
}
Map3DApp.ModelInstance = modelInstance;

function modelInstance:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;
end

function modelInstance:Reset()
	self.id = 0;
	self.modelID = 0;
	self.model = nil;
	self.texture = nil;
	self.facing = 0;
	offsetX = 0;
	offsetY = 0;
end

--model instance pool
modelInstance.pool = {};
modelInstance.count = 0;
modelInstance.first = 0;
modelInstance.last = 0;

function modelInstance.CreateModelInst()
	if(modelInstance.count < 1)then
		return modelInstance:new();
	else
		local modelInst = modelInstance.pool[modelInstance.first];
		modelInstance.first = modelInstance.first + 1;
		modelInstance.count = modelInstance.count - 1;
		return modelInst;
	end
end

function modelInstance.ReleaseModelInst(modelInst)
	modelInst:Reset();
	if(modelInstance.count < 1)then
		modelInstance.first = 1;
		modelInstance.last = 1;
	else
		modelInstance.last = modelInstance.last + 1;
	end
	modelInstance.pool[modelInstance.last] = modelInst;
	modelInstance.count = modelInstance.count + 1;
end

function modelInstance.ReleasePool()
	modelInstance.pool = {};
	modelInstance.count = 0;
	modelInstance.first = 0;
	modelInstance.last = 0;
end


-------------------------------
----mark3DInfo
-------------------------------
local mark3DInfo = {
	id = 0,
	markStyle = 1,
	type = 0,
	x,
	y,
	
	markTitle = "pe",
	cityName = "city of rock",
	rank = 0,
	startTime = "00-00-00",
	endTime = "00-00-00",
	image = nil,
	signature = nil,
	desc = nil,
	ageGroup = 0,
	isApproved = false,
	version = nil,
	ownerUserID = nil,
	clickCnt = 0,
	worldid = 0,
	allowEdit = nil,	
}
Map3DApp.Mark3DInfo = mark3DInfo;

function mark3DInfo:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;
end

function mark3DInfo:GetTitle()
	return self.markTitle;
end

----------enum------------
Map3DApp.MarkType = {};
Map3DApp.MarkType.player = 1;
Map3DApp.MarkType.event = 2;
Map3DApp.MarkType.city = 3;	
Map3DApp.MarkType.ad = 4;


Map3DApp.TerrainType = {};
Map3DApp.TerrainType.ground = 1;
Map3DApp.TerrainType.road = 2;
Map3DApp.TerrainType.water = 3;

Map3DApp.TileState = {};
Map3DApp.TileState.sale = 1;
Map3DApp.TileState.sold = 2;
Map3DApp.TileState.rent = 3;
Map3DApp.TileState.pubic = 4;
Map3DApp.TileState.unopened = 5;
Map3DApp.TileState.rented = 6;

Map3DApp.ModelUsage = {};
Map3DApp.ModelUsage.tile = 1;
Map3DApp.ModelUsage.mark = 2;
Map3DApp.ModelUsage.model = 3;




