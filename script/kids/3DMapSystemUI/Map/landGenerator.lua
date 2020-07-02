--[[
Title:land generator
Author(s): SunLingFeng
Desc:create tileinfo for given position
we use image to record land information.
red channel of the image stands for road type,there're three type of land at present:0--normal land; 64--road; 255--water;
green channel stands for land texture index;
blue channel stands for second texture index,the texture useage may vary for different land type;

Date: 2008/1/25
Use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppDataPvd.lua");
-------------------------------------------------------
]]

Map3DApp.LandGenerator = {};
landGen = Map3DApp.LandGenerator;

landGen.terrainMap = nil;
landGen.logicTileSize = 1/32768;

function landGen.GetTileInfoByPos(norPosX,norPosY)	
	local terrain = landGen.QueryTileType(norPosX,norPosY);
	local tileInfo;

	if(terrain.type == 0)then
		tileInfo = landGen.CreateGround(terrain.tex0,norPosX,norPosY)
	elseif(terrain.type == 64)then
		tileInfo = landGen.CreateRoad(terrain.tex0,terrain.tex1,norPosX,norPosY);
	elseif(terrain.type == 255)then
		tileInfo = landGen.CreateOcean(norPosX,norPosY);
	end
	
	return tileInfo;
end

--private
function landGen.QueryTileType(norPosX,norPosY)
	if(landGen.terrainMap == nil)then
		landGen.LoadTerrainMap();
	end
	
	--find out current tile position correspond to which pixel
	--i use a 128x128 texture here,so index out of range will be mod into [1,128]
	local indexX,indexY;
	indexX = math.mod(math.ceil(norPosX/landGen.logicTileSize),landGen.terrainDimension)+1;
	indexY = math.mod(math.ceil(norPosY/landGen.logicTileSize),landGen.terrainDimension)+1;
	
	if(landGen.terrainMap == nil or landGen.terrainMap[indexX] == nil or landGen.terrainMap[indexX][indexY] == nil)then
		return {type = 0,tex0 = 0,tex1 = 0};
	else
		return landGen.terrainMap[indexX][indexY];
	end
end

function landGen.LoadTerrainMap()
	local file = ParaIO.openimage("Texture/worldMap/terrainInfo.png","a8r8g8b8");

	if(file:IsValid())then
		local nSize = file:GetFileSize();
		local nImageWidth = math.sqrt(nSize/4);
		landGen.terrainDimension = nImageWidth;
		
		--output each pixel of the image to log
		local pixel = {};
		local x,y;
		landGen.terrainMap = {};
		for x=1,nImageWidth do
			landGen.terrainMap[x] = {};
			for y = 1,nImageWidth do
				file:ReadBytes(4,pixel)
				landGen.terrainMap[x][y] = {};
				--red channel
				landGen.terrainMap[x][y].type = pixel[3];
				--green
				landGen.terrainMap[x][y].tex0 = pixel[2];
				--blue
				landGen.terrainMap[x][y].tex1 = pixel[1];
			end
		end
		pixel = nil;
	end
	file:close();	
end

function landGen.CreateGround(textureId,norPosX,norPosY)
	local tileInfo = Map3DApp.TileInfo.CreateTileInfo();
	tileInfo.id = landGen.CreateTileID(norPosX,norPosY);
	tileInfo.x = norPosX;
	tileInfo.y = norPosY;
	
	local _models = landGen.CreateRandomModels(tileInfo.id);
	local _modelCount = 0;
	if(_models)then
		_modelCount = 1;
	end
	
	local texture = Map3DApp.DataPvd.GetLandTexByID(textureId);
	tileInfo.terrainInfo = Map3DApp.TerrainInfo:new{
		type = Map3DApp.TerrainType.ground,
		textureID0 = textureId;
		texture0 = texture.file;
	};
	tileInfo.modelCount = _modelCount;
	tileInfo.models = _models;
	
	return tileInfo;
end

function landGen.CreateRoad(texID0,textureID1,norPosX,norPosY)
	local tileInfo = Map3DApp.TileInfo.CreateTileInfo();
	tileInfo.id = landGen.CreateTileID(norPosX,norPosY);
	tileInfo.x = norPosX;
	tileInfo.y = norPosY;
	
	local baseTexture = Map3DApp.DataPvd.GetLandTexByID(texID0);
	

	local linkId = 0;
	local left = norPosX - landGen.logicTileSize;
	local leftTile = landGen.QueryTileType(left,norPosY);
	local temp = ((leftTile.type == 64) and 1) or 0;
	linkId = linkId + temp;
	
	local right = norPosX + landGen.logicTileSize;
	local rightTile = landGen.QueryTileType(right,norPosY);
	temp = ((rightTile.type == 64) and 2) or 0;
	linkId = linkId + temp;
	
	local up = norPosY - landGen.logicTileSize;
	local upTile = landGen.QueryTileType(norPosX,up);
	temp = ((upTile.type == 64) and 4) or 0;
	linkId = linkId +  temp;
	
	local down = norPosY + landGen.logicTileSize;
	local downTile = landGen.QueryTileType(norPosX,down);
	temp = ((downTile.type == 64) and 8) or 0;
	linkId = linkId +  temp;

	local linkInfo = landGen.GetLinkInfo(linkId);
	local roadTexture;
	if(linkInfo)then
		roadTexture = Map3DApp.DataPvd.GetRoadTexture(textureID1,linkInfo.shape);
		if(roadTexture == nil)then
			 roadTexture = "Model/Map3D/Texture/asphalt_straight.dds";
		end
	else
		raodTexture = "Model/Map3D/Texture/asphalt_straight.dds";
	end
	
	tileInfo.terrainInfo = Map3DApp.TerrainInfo:new{
		type = Map3DApp.TerrainType.road,
		textureID0 = texID0;
		texture0 = baseTexture.file;
		texture1Id = textureID1;
		texture1 = roadTexture;
		rotation = linkInfo.rotation;
	};
	
	return tileInfo;
end

function landGen.CreateOcean(norPosX,norPosY)
	local tileInfo = Map3DApp.TileInfo.CreateTileInfo();
	tileInfo.id = landGen.CreateTileID(norPosX,norPosY);
	tileInfo.x = norPosX;
	tileInfo.y = norPosY;
	tileInfo.terrainInfo = Map3DApp.TerrainInfo:new{
		type = Map3DApp.TerrainType.water,
		texture0 = "Model/Map3D/Texture/texture11.dds",
	};
	return tileInfo;
end

function landGen.CreateRandomModels(landID)
	local seed = math.abs(landID);
	local hasModel = ( landGen.Random(seed) > 0.8 and true) or false;
	if(hasModel)then
		local models = {};
		local dataPvd = Map3DApp.DataPvd;
		local modelIndex = math.floor(math.random() * dataPvd.GetModelCount());
		modelIndex = math.mod(seed,dataPvd.GetModelCount()) + 1;
		
		if(dataPvd.modelList[modelIndex])then
			models[1] = Map3DApp.ModelInstance.CreateModelInst();
			models[1].id = Map3DApp.DataPvdHelper.CreateModelInstanceID();
			models[1].modelID = modelIndex;
			models[1].model = dataPvd.modelList[modelIndex].model;
			models[1].offsetX = 0;
			models[1].offsetY = 0;
			return models;
		end
	end
end

function landGen.CreateTileID(norPosX,norPosY)
	local x = norPosX * 32768;
	local y = norPosY * 32768;
	return tostring(-y * 32768 + x);
end

function landGen.GetLinkInfo(linkID)
	if(landGen.roadLinkList == nil)then
		landGen.InitRoadLinkList()
	end
	
	if(landGen.roadLinkList and landGen.roadLinkList[linkID])then
		return landGen.roadLinkList[linkID];
	else
		return nil;
	end
end

function landGen.InitRoadLinkList()
	--shape:0 straight road; 1 road corner; 2 cross
	--3 road end; 4 T-shape cross; 
	landGen.roadLinkList = {};
	landGen.roadLinkList[0] = {rotation = 0,shape = 2};
	--left
	landGen.roadLinkList[1] = {rotation = math.pi/2,shape = 3};
	--right
	landGen.roadLinkList[2] = {rotation = -math.pi/2,shape = 3};
	--left right
	landGen.roadLinkList[3] = {rotation = math.pi/2,shape = 0};
	--up
	landGen.roadLinkList[4] = {rotation = 0,shape = 3};
	--up left
	landGen.roadLinkList[5] = {rotation = -math.pi/2,shape = 1};
	--up right
	landGen.roadLinkList[6] = {rotation = math.pi,shape = 1};
	--up right left
	landGen.roadLinkList[7] = {rotation = 0,shape = 4};
	--down
	landGen.roadLinkList[8] = {rotation = math.pi,shape = 3};
	--down,left
	landGen.roadLinkList[9] = {rotation = 0,shape = 1};
	--down,right
	landGen.roadLinkList[10] = {rotation = math.pi/2,shape = 1};
	--down,right,left
	landGen.roadLinkList[11] = {rotation = math.pi,shape = 4};
	--down,up
	landGen.roadLinkList[12] = {rotation = 0,shape = 0};
	--down,up,left
	landGen.roadLinkList[13] = {rotation = math.pi/2,shape = 4};
	--down,up,right
	landGen.roadLinkList[14] = {rotation = -math.pi/2,shape = 4};
	--down,up,right,left
	landGen.roadLinkList[15] = {rotation = 0,shape = 2};
end

function landGen.Random(seed)
	return math.mod((23 * seed + 11),51)/51;
end
