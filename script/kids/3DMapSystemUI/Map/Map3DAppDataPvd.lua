
--[[
Title: Map data provider
Author(s): SunLingFeng
Desc:Map data provider connect database,send web service or create random info and finally 
return proper data to its clinet.
Date: 2008/1/25
Use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppDataPvd.lua");
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppCommon.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppTerrainTexture.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppModelTable.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/DataPvdHelper.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/MapDataDefine.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/landGenerator.lua");


if(not Map3DApp.DataPvd) then Map3DApp.DataPvd = {};end
Map3DApp.DataPvd.name = "mapDataPvd";
-- TODO:replace real url with paraworld.TranslateURL;
--NPL.load("(gl)script/kids/3DMapSystemApp/API/webservice_constants.lua")
--Map3DApp.DataPvd.serverURL = paraworld.TranslateURL("%%MAP%%")
Map3DApp.DataPvd.serverURL = "http://202.104.149.47";


--set remote server url
function Map3DApp.DataPvd.SetServerURL(url)
	Map3DApp.DataPvd.serverURL = paraworld.Translate(url);
end

--total map cell count
Map3DApp.DataPvd.totalCellCount = 32768;
Map3DApp.DataPvd.logicCellSize = 1/32768;

function Map3DApp.DataPvd.GetTotalCellCount()
	return Map3DApp.DataPvd.totalCellCount;
end

function Map3DApp.DataPvd.GetLogicCellSize()
	return Map3DApp.DataPvd.logicCellSize;
end

-------------------------------------------
----tile
-------------------------------------------
--client call this method to get tile data
--sender is this client object
--callback data privde will call this function when data is prepared
function Map3DApp.DataPvd.GetTileByPos(posX,posY,objSender,callbackFun)
	local self = Map3DApp.DataPvd;
	posX = math.floor(posX/self.GetLogicCellSize()) * self.GetLogicCellSize();
	posY = math.floor(posY/self.GetLogicCellSize()) * self.GetLogicCellSize();
	
	local msg = {
		x = posX,
		y = posY,
		width = self.GetLogicCellSize(),
		height = self.GetLogicCellSize(),
	};
	
	local args = {
		sender = objSender,
		callback = callbackFun,
		x = posX,
		y = posY,
	};
	Map3DApp.DataPvd.MockGetTilesInRegion(msg,args)
	paraworld.map.GetTilesInRegion(msg,self.name..objSender.name,self.GetTileByPosSucceed,args);
end
 
function Map3DApp.DataPvd.GetTileByPosSucceed(msg,args)
	if(msg == nil)then
		return;
	end

	local tile;
	if(msg.resultCount ~= nil and msg.resultCount > 0)then
		if(msg.tiles and msg.tiles[1])then
			tile = msg.tiles[1];
			
			if(args.sender and args.callback)then
				args.callback(args.sender,tile);
			end
		end
	end
	msg = nil;
end

function Map3DApp.DataPvd.GetTileByID(tileId,sender,callback)
	if(tileId == nil or callback == nil)then
		return nil;
	end
	
	local msg = {
		tileID = tostring(tileId);
	};
		
	local args = {
		_sender = sender,
		_callback = callback,
	};
	
	if(tonumber(tileId) > 0)then	
		paraworld.map.GetTileByID(msg,"mapApp",Map3DApp.DataPvd.GetTileByIDSucceed,args);
	else
		Map3DApp.DataPvd.GetTileByIDSucceed(nil,args)
	end
end

function Map3DApp.DataPvd.GetTileByIDSucceed(msg,args)
	local tileInfo = Map3DApp.DataPvdHelper.ParseTileInfo(msg);
	
	if(args._callback ~= nil and args._sender ~= nil)then
		args._callback(args._sender,tileInfo);
	end
end

function Map3DApp.DataPvd.UpdateTile(tile)
end

function Map3DApp.DataPvd.RemoveTile(tileID)

end

--buy tile with given id or position
--@params tileID:tile id you want to buy,can be nil
--@params x,y:tile position you want to buy,can be nil
--@params terrainType, can be nil
--@params:terrain texture,can be nil
--@params:callback function when remote call return
function Map3DApp.DataPvd.BuytTile(userSession,tileID,_x,_y,_terrainType,_texture,sender,callback)
	local self = Map3DApp.DataPvd;
	local msg = {
		sessionkey = userSession,
		id = tileID,
		x = _x,
		y = _y,
		terrainType = _terrainType or 1,
		texture = _texture or "Model/Map3D/Texture/texture11.dds",
	};
	
	local args = {
		_sender = sender,
		_callback = callback,
	}
	
	paraworld.map.BuyTile(msg,"mapApp",self.BuyTileSucceed,args)
end

function Map3DApp.DataPvd.BuyTileSucceed(msg,args)
	if(msg == nil)then
		return;
	end
	
	local issuccess;
	if(msg.issuccess == "true")then
		issuccess = true;
	else
		issuccess = false;
	end
	
	if(args._sender ~= nil and args._callback ~= nil)then
		args._sender[args._callback](args._sender,msg.tileID,msg.issuccess);
	end
end

--mock RPC for testing
function Map3DApp.DataPvd.MockGetTilesInRegion(msg,args)
	local tileInfo = Map3DApp.LandGenerator.GetTileInfoByPos(msg.x,msg.y);
	local result = {};
	result.resultCount = 1;
	result.tiles = {};
	result.tiles[1] = tileInfo;
	
	Map3DApp.DataPvd.GetTileByPosSucceed(result,args);
end


--get a random tile in reagion
--@params x:center point x in normalized world coordinate
--@params y:center point y in normalized world coordinate
--@params radius:region width,in normalized world coordinate
function Map3DApp.DataPvd.GetRandomTilePosInRegion(x,y,radius)
	local offsetX = (math.random()*2 - 1)*radius;
	local offsetY = (math.random()*2 - 1)*radius;
	local tileX = offsetX + x;
	local tileY = offsetY + y;
	 
	local tileSize = Map3DApp.DataPvd.logicCellSize;
	if(tileX > 1)then
		tileX = 1 - tileSize;
	elseif(tileX < 0)then
		tileX = 0;
	end
	
	if(tileY > 1)then
		tileY = 1 - tileSize;
	elseif(tileX < 0)then
		tileY = 0;
	end
	
	tileX = math.floor(tileX / tileSize) * tileSize;
	tileY = math.floor(tileY / tileSize) * tileSize;
	
	return tileX,tileY;
end



--------------------------------------------
--world
--------------------------------------------
function Map3DApp.DataPvd.GetWorldByID(id,sender,callback)
	local msg = {
		worldid = id,
	}

	local args = {
		_sender = sender,
		_callback = callback,
	};
	
	paraworld.map.GetWorldByID(msg,"mapApp",Map3DApp.DataPvd.GetWorldByIDSucceed,args);
end

function Map3DApp.DataPvd.GetWorldByIDSucceed(msg,args)
	if(msg == nil)then
		return;
	end
	
	if(msg.errorcode)then
		--TODO:record err msg...;
	end
	
	local worldInfo = Map3DApp.World:new();
	if(msg.worldid)then
		worldInfo.id = tonumber(msg.worldid);
	end
	if(msg.name)then
		worldInfo.name = msg.name;
	end
	if(msg.desc)then
		worldInfo.desc = msg.desc;
	end
	if(msg.ownerID)then
		worldInfo.ownerID = msg.ownerID;
	end
	if(msg.ownerUserName)then
		worldInfo.ownerName = msg.ownerUserName;
	end
	if(msg.spaceServer)then
		worldInfo.spaceServer = msg.spaceServer
	end
	
	if(args._callback ~= nil and args._sender ~= nil)then		
		args._callback(args._sender,worldInfo);
	end
end


--------------------------------------------
--land texture
function Map3DApp.DataPvd.GetLandTexByID(id)
	local self = Map3DApp.DataPvd;		
	if(self.landIdTexMapping == nil)then
		self.LoadLandTextures();
	end
	
	if(self.landIdTexMapping and self.landIdTexMapping[id])then
		return self.landIdTexMapping[id];
	else
		return "Model/Map3D/Texture/texture11.dds";
	end
end

function Map3DApp.DataPvd.LoadLandTextures()
	local self = Map3DApp.DataPvd;
	self.landTextureCount = 0;
	local file = ParaIO.open("script/kids/3DMapSystemUI/Map/landTextureDB.txt","r");
	if(file:IsValid())then
		self.landTextures = {};
		self.landIdTexMapping = {};
		local record = file:readline();
		while(record)do
			local data = commonlib.LoadTableFromString(record);
			if(data)then
				self.landTextureCount = self.landTextureCount + 1;
				self.landTextures[self.landTextureCount] = data;
				if(data.id)then
					self.landIdTexMapping[data.id] = self.landTextures[self.landTextureCount];
				end
			end
			record = file:readline();
		end
	end
	file:close();
end

function Map3DApp.DataPvd.GetRoadTexture(roadType,shape)
	local self = Map3DApp.DataPvd;
	if(self.roadTextures == nil)then
		self.LoadRoadTextures();
	end
	
	local index = roadType * 5 + shape;
	if(self.roadTextures and self.roadTextures[index])then
		return self.roadTextures[index].file;
	else
		return nil;
	end
end

function Map3DApp.DataPvd.LoadRoadTextures()
	local self = Map3DApp.DataPvd;
	self.roadTextureCount = 0;
	local file = ParaIO.open("script/kids/3DMapSystemUI/Map/roadTextureDB.txt","r");
	if(file:IsValid())then
		self.roadTextures = {};
		local item = file:readline();
		while(item)do
			local data = commonlib.LoadTableFromString(item);
			if(data)then
				self.roadTextures[data.id] = data;
			end
			item = file:readline();
		end
	end
	file:close();
end

function Map3DApp.DataPvd.GetRoadName(roadType)
	
end

function Map3DApp.DataPvd.GetRoadTextureCount()
end

function Map3DApp.DataPvd.GetLandTextureCount()
	if(Map3DApp.DataPvd.landTextureCount)then
		return Map3DApp.DataPvd.landTextureCount
	else
		return 0;
	end
end

---------------------------------------------
----for model
---------------------------------------------
Map3DApp.DataPvd.pagecount = 0;
Map3DApp.DataPvd.modelCount = 0;
Map3DApp.DataPvd.modelList = {};
Map3DApp.DataPvd.modelIDMappingList = {};

--public 
function Map3DApp.DataPvd.GetModelByID(modelID)
	return Map3DApp.DataPvd.modelIDMappingList[modelID];
end

--result is type of modelInfo[]
function Map3DApp.DataPvd.GetModelOfPage(pageNum,pageindex)
	local self = Map3DApp.DataPvd;
	local index = (pageindex - 1)*pageNum + 1;
	local result = {};
	local count = 0;
	while((count<pageNum) and (index <= self.modelCount))do
		count = count + 1;
		result[count] = self.modelList[index];
		index = index + 1;
	end
	return result,count;
end

function Map3DApp.DataPvd.GetModelOfPageSucceed(msg,callback)
	if(msg == nil)then
		return;
	end
	
	if(msg["pagecount"])then
		Map3DApp.DataPvd.pagecount = msg["pagecount"];
	end
	
	local i = 1;
	local modelInfos = {};
	while (msg["models"][i]) do
		modelInfos[i] = Map3DApp.DataPvd.ConvertToModelInfo(msg["models"][i])
		i = i + 1;
	end
	msg = nil;
	callback(modelInfos);
end

function Map3DApp.DataPvd.GetModelPageCount()
	return Map3DApp.DataPvd.pagecount;
end

function Map3DApp.DataPvd.ConvertToModelInfo(dbData)
	local modelInfo = Map3DApp.ModelInfo:new();
	
	if(dbData["modelID"])then
		modelInfo.id = dbData["modelID"];
	end
	if(dbData["modelType"])then
		modelInfo.modelType = dbData["modelType"];
	end
	if(dbData["picURL"])then
		modelInfo.thumbnail = Map3DApp.DataPvd.serverURL..dbData["picURL"];
	end
	if(dbData["manufacturerType"])then
		modelInfo.manufacturerType  = dbData["manufacturerType"];
	end
	if(dbData["manufacturerID"])then
		modelInfo.manufacturerID  = dbData["manufacturerID"];
	end
	if(dbData["manufacturerName"])then
		modelInfo.manufacturerName  = dbData["manufacturerName"];
	end
	if(dbData["price"])then
		modelInfo.price  = dbData["price"];
	end
	if(dbData["price2"])then
		modelInfo.price2  = dbData["price2"];
	end
	if(dbData["price2StartTime"])then
		modelInfo.price2StartTime  = dbData["price2StartTime"];
	end
	if(dbData["price2EndTime"])then
		modelInfo.price2EndTime  = dbData["price2EndTime"];
	end
	if(dbData["adddate"])then
		modelInfo.adddate  = dbData["adddate"];
	end
	if(dbData["version"])then
		modelInfo.version  = dbData["version"];
	end
	if(dbData["modelPath"])then
		modelInfo.modelPath  = dbData["modelPath"];
	end
	if(dbData["texturePath"])then
		modelInfo.texturePath  = dbData["texturePath"];
	end
	if(dbData["package"])then
		modelInfo.package  = dbData["package"];
	end
	if(dbData["allowEidt"])then
		modelInfo.allowEidt  = dbData["allowEidt"];
	end
	return modelInfo;
end

function Map3DApp.DataPvd.GetModelCount()
	return Map3DApp.DataPvd.modelCount;
end
 
--private 
function Map3DApp.DataPvd.LoadModelTable()
	local self = Map3DApp.DataPvd;
	local file = ParaIO.open("script/kids/3DMapSystemUI/Map/ModelDB.txt","r");
	if(file:IsValid())then
		local record = file:readline();
		while(record)do
			local data = commonlib.LoadTableFromString(record);
			data = Map3DApp.DataPvdHelper.ConvertModel2RunType(data);
			if(data ~= nil)then
				self.modelCount = self.modelCount + 1;
				self.modelList[self.modelCount] = data;
			end
			record = file:readline();
		end
	end
	file:close();
	self.InitModelIDMapping();
end
 
function Map3DApp.DataPvd.InitModelIDMapping()
	local self = Map3DApp.DataPvd;
	for i = 1,self.modelCount do
		if(self.modelList and self.modelList[i].id)then
			self.modelIDMappingList[self.modelList[i].id] = self.modelList[i];
		end
	end
end

Map3DApp.DataPvd.LoadModelTable();

------------------------------------------------
-----3d mark manipulation
------------------------------------------------
function Map3DApp.DataPvd.Get3DMark(markID)

end

function Map3DApp.DataPvd.Get3DMarkInTile(left,top,viewWidth,viewHeight,sendObj,callbackFun)
	local msg = {
		operation = "get",
		x = left,
		y = top,
		width = viewWidth,
		view = viewHeight,
		markType = 0,
		markNum = 0,
		isApproved = nil,
	};
	
	if(sendObj == nil or callbackFun == nil)then
		log"ws params is nil..\n";
		return;
	end
	
	local arg = {
		sender = sendObj,
		callback = callbackFun,
		x = left,
		y = top,
	};

	Map3DApp.DataPvd.MockGet3DMarkInRegion(msg,arg);
	
	--paraworld.map.GetMapMarksInRegion(msg,Map3DApp.DataPvd.name,Map3DApp.DataPvd.Get3DMarkInRegionSucceed);
end

function Map3DApp.DataPvd.Update3DMark(markID,mark)
end

function Map3DApp.DataPvd.Remove3DMark(markID)
end

function Map3DApp.DataPvd.Get3DMarkInRegionSucceed(msg,arg)
	arg.callback(arg.sender,msg,x,y);
end

function Map3DApp.DataPvd.MockGet3DMarkInRegion(msg,arg)
	local marks = {};
	if(math.random()>0.5)then
		marks[1] = Map3DApp.Mark3DInfo:new{
			markID = Map3DApp.DataPvd.GetMarkID();
			markModel = "character/map3d/littlegirl/little girl.x",
			x = msg.x + msg.width/4;
			y = msg.y + msg.width/3;
		};
	end

	Map3DApp.DataPvd.Get3DMarkInRegionSucceed(marks,arg)
end

Map3DApp.DataPvd.markID = 0;

function Map3DApp.DataPvd.GetMarkID()
	Map3DApp.DataPvd.markID  = Map3DApp.DataPvd.markID + 1;
	return "3DMark"..Map3DApp.DataPvd.markID;
end

-------------------------------------------------
-------2d mark manipulation
-------------------------------------------------
--create or updata a mcml map
function Map3DApp.DataPvd.UpdataMCMLMap(map)
end

--deleta a MCML map
function Map3DApp.DataPvd.DeleteMCMLMap(mapName)
end

function Map3DApp.DataPvd.Get2DMarksInRegion(mapName,x,y,width,height)
end

function Map3DApp.DataPvd.Get2DMarkByName(mapName,markName)
end

function Map3DApp.DataPvd.Update2DMark(mapName,mark)
end

function Map3DApp.DataPvd.Delete2DMark(mapName,markName)
end


--==================2d map texture====================
Map3DApp.DataPvd.MapTexture = {};
Map3DApp.DataPvd.MapTexture.root = "Texture/worldMap";
Map3DApp.DataPvd.MapTexture.files = {};
Map3DApp.DataPvd.MapTexture.fileFmt = "jpg";
Map3DApp.DataPvd.MapTexture.textures = {};
Map3DApp.DataPvd.MapTexture.defaultTexture = "Texture/whitedot.png";

--return 2D map texture
function Map3DApp.DataPvd.GetMap(x,y,level)
	local texWidth = 1 / math.pow(2,level-1);
	local textureFile = Map3DApp.DataPvd.GetMapPath(math.floor(x/texWidth)+1,math.floor(y/texWidth)+1,level)
	--uncomment this line to return a texture object instead of texture file name.
	--return Map3DApp.Global.AssetManager.GetMapTex(textureFile);
	return textureFile;
end

function Map3DApp.DataPvd.GetMapPath(indexX,indexY,level)
	local self = Map3DApp.DataPvd.MapTexture;
	if(self.files[level] == nil)then
		self.files[level] = {};
	end
	
	if(self.files[level][indexY] == nil)then
		self.files[level][indexY] = {};
	end
	
	if(self.files[level][indexY][indexX] == nil)then
		local filename = self.root.."/"..level.."_"..indexY.."_"..indexX.."."..self.fileFmt;
		if(ParaIO.DoesFileExist(filename,true))then
			self.files[level][indexY][indexX] = filename;
		else
			self.files[level][indexY][indexX] = self.defaultTexture;
		end
	end
	return self.files[level][indexY][indexX]
end

---------------------------------------------------- 
--Helper
-----------------------------------------------------

Map3DApp.DataPvd.mapTileModel = 0;
function Map3DApp.DataPvd.GetMapTileModelID()
	Map3DApp.DataPvd.mapTileModel = Map3DApp.DataPvd.mapTileModel + 1;
	return "MTM"..Map3DApp.DataPvd.mapTileModel;
end


function Map3DApp.DataPvd.TranslateTileState(tileState)
	if(tileState == 1)then
		return "热卖中";
	elseif(tileState == 2)then
		return "私人土地";
	elseif(tileState == 3)then
		return "出租中";
	elseif(tileState == 4)then
		return "公共土地";
	elseif(tileState == 6)then
		return "租用中";
	else
		return "未开放土地";
	end
end
