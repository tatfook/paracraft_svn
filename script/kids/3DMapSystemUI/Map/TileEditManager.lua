
NPL.load("(gl)script/kids/3DMapSystemUI/Map/TileEditCmdHolder.lua");


Map3DApp.TileEditManager = {};
Map3DApp.TileEditManager.cmdHolder = Map3DApp.CommandHolder;
Map3DApp.TileEditManager.tileInfo = nil;
Map3DApp.TileEditManager.tempModels = {};
Map3DApp.TileEditManager.tempTerrain = nil;
Map3DApp.TileEditManager.activeModelID = nil;
Map3DApp.TileEditManager.activeModelInfo = nil;
Map3DApp.TileEditManager.modelID = 0;
Map3DApp.TileEditManager.msgHandle = nil;

--=============public=========================
function Map3DApp.TileEditManager.GetNewModelID()
	Map3DApp.TileEditManager.modelID = Map3DApp.TileEditManager.modelID + 1;
	--return tostring(Map3DApp.TileEditManager.modelID);
	return "model_"..Map3DApp.TileEditManager.modelID;
end

function Map3DApp.TileEditManager.AddModel(modelID,modelData)
	local self = Map3DApp.TileEditManager;
	self.tempModels[modelID] = modelData;
end

function Map3DApp.TileEditManager.RemoveModel(modelID)
	if(Map3DApp.TileEditManager.tempModels[modelID] ~= nil)then
		Map3DApp.TileEditManager.tempModels[modelID] = nil;
	end
end

function Map3DApp.TileEditManager.SetTileInfo(tileInfo)
	local self = Map3DApp.TileEditManager;
	
	self.Reset();
	self.tileInfo = tileInfo;
	
	if(self.tileInfo and  self.tileInfo.modelCount)then
		for i = 1,self.tileInfo.modelCount do
			self.tempModels[self.GetNewModelID()] = self.self.tileInfo.models[i];
		end
	end
end

function Map3DApp.TileEditManager.SetModelInfo(modelID,modelData)
	local self = Map3DApp.TileEditManager;
	if(self.tempModels[modelID])then
		self.tempModels[modelID] = modelData;
	end
end

function Map3DApp.TileEditManager.SaveTileInfo()
end

function Map3DApp.TileEditManager.SetTerrainInfo(terrainInfo)
end

function Map3DApp.TileEditManager.SetTileInfoField(field,value)

end

function Map3DApp.TileEditManager.SetActiveModel(modelID)
	local self = Map3DApp.TileEditManager;
	if(self.tempModels[modelID])then
		self.activeModelID = modelID;
	else
		self.activeModelID = nil;
	end
	self.SendMessage(self.Msg.onModelSelect,self.activeModelID);
end

function Map3DApp.TileEditManager.GetActiveModelID()
	return Map3DApp.TileEditManager.activeModelID;
end

function Map3DApp.TileEditManager.GetModelInfo(modelID)
	return Map3DApp.TileEditManager.tempModels[modelID];
end

--release all resource
function Map3DApp.TileEditManager.Reset()
	local self = Map3DApp.TileEditManager;
	
	self.cmdHolder.ClearAllCommand();
	self.tileInfo = {};
	self.tempModels = {};
	self.tempTerrain = {};
end

function Map3DApp.TileEditManager.SetMsgCallback(callback)
	Map3DApp.TileEditManager.msgHandle = callback;
end

--================private=====================
function Map3DApp.TileEditManager.SendMessage(msg,data)
	local self = Map3DApp.TileEditManager;
	if(self.msgHandle)then
		self.msgHandle(msg,data);
	end
end

--msg enum
Map3DApp.TileEditManager.Msg = {};
Map3DApp.TileEditManager.Msg.onModelSelect = 1;
