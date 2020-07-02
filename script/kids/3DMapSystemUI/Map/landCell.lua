
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppCommon.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppAssetManager.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppDataPvd.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppMaterial.lua");

local landCell = {
	name = "cell1",
	
	pos_x = 0,
	pos_y = 0,
	pos_z = 0,
	
	logicX = 0,
	logicY = 0,
	logicTileSize = 1/32768,
	
	tileSize =4.5,
	baseSize = 4,
	scene = nil,
	tileInfo = nil,
	marks = nil,
	
	showMarks = false;
	isModelCleared = false;
	dataUpdated = false;
	delayRefreshModel = false;
	delayRefreshMark = false;
	showBase = false;
};
Map3DApp.LandCell = landCell;

function landCell:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;
end

function landCell:Destroy()
end

function landCell:Reset()
end

function landCell:Show(bShow)
	if(self.scene:IsValid())then
		self:ShowTerrain(bShow);
		self:ShowModels(bShow);
		self:ShowMarks(bShow);
	end
end

function landCell:SetLogicPosition(x,y)
	if(x > 1)then x = 1;end;
	if(x < 0)then x = 0;end;
	
	if(y > 1)then y = 1;end;
	if(y < 0)then y = 0;end;
	
	local l_x = math.floor(x / self.logicTileSize) * self.logicTileSize;
	local l_y = math.floor(y / self.logicTileSize) * self.logicTileSize;
	
	if(l_x == self.logicX and l_y == self.logicY)then
		return;
	else
		self.logicX = l_x;
		self.logicY = l_y;
		
		self:Clear()
		self:UpdateCellData();
	end
end

function landCell:UpdateCellData()
	self.dataUpdated = false;
	Map3DApp.DataPvd.GetTileByPos(self.logicX,self.logicY,self,Map3DApp.LandCell.OnReceiveTileInfo);
	
	if(delayRefreshMark)then
	
	else
		Map3DApp.DataPvd.Get3DMarkInTile(self.logicX,self.logicY,self.logicTileSize,self.logicTileSize,self,Map3DApp.LandCell.OnReceiveMarkInfo);
	end
end

function landCell:SetWorldPosition(x,y,z)
	self.pos_x = x;
	self.pos_y = y;
	self.pos_z = z;
	
	if(self.scene and self.scene:IsValid())then
		self:UpdateTerrainPos();
		self:UpdateModelPos();
		self:UpdateMarkPos();
	end
end

--private 
function landCell:SetTileInfo(tileInfo)
	if(not self.isModelCleared)then
		self:ClearAllModel()
	end
	
	if(self.tileInfo)then
		--release tileInfo to object pool
		Map3DApp.TileInfo.ReleaseTileInfo(self.tileInfo);
	end
	
	self.tileInfo = tileInfo;
	self.dataUpdated = true;
	
	self:RefreshTerrain();
	if(self.delayRefreshModel)then
	
	else
		self:RefreshModels();
	end
	isModelCleared = false;
end

function landCell:SetMarks(marks)
	self.marks = marks;
	self:RefreshMarks();
end

function landCell:ShowTerrain(bShow)
	local terrain = self.scene:GetObject(self.name);
	if(terrain:IsValid())then
		terrain:SetVisible(bShow);
		
		local base = self.scene:GetObject(self.name.."base");
		if(base:IsValid())then
			if(bShow and self.showBase)then
				base:SetVisible(true);
			else
				base:SetVisible(false);
			end
		end
	
	elseif(bShow)then		
		local asset = Map3DApp.Global.AssetManager.GetModel("model/common/map3D/map3D.x");
		if(asset)then
			local terrain = ParaScene.CreateMeshPhysicsObject(self.name,asset,1,1,1,false,"1,0,0,0,1,0,0,0,1,0,0,0");
			terrain:GetAttributeObject():SetField("progress",1);
			terrain:SetScale(self.tileSize);
			terrain:SetPosition(self.pos_x,self.pos_y,self.pos_z);
			self.scene:AddChild(terrain);
		end
		
		asset = Map3DApp.Global.AssetManager.GetModel("model/map3D/box.x");
		if(asset)then
			local base = ParaScene.CreateMeshPhysicsObject(self.name.."base",asset,1,1,1,false,"1,0,0,0,1,0,0,0,1,0,0,0");
			base:GetAttributeObject():SetField("progress",1);
			base:SetVisible(self.showBase);
			base:SetPosition(self.pos_x,self.pos_y,self.pos_z);
			self.scene:AddChild(base);
		end
	end	
end

function landCell:ShowModels(bShow)
	
end

function landCell:ShowMarks(bShow)
end

--private,update terrain position
function landCell:UpdateTerrainPos()
	local terrain = self.scene:GetObject(self.name);
	if(terrain:IsValid())then
		terrain:SetPosition(self.pos_x,self.pos_y,self.pos_z);
	end
	
	local base = self.scene:GetObject(self.name.."base");
	if(base:IsValid() and base:IsVisible())then
		base:SetPosition(self.pos_x,self.pos_y,self.pos_z);
	end
end

--private,update model position
function landCell:UpdateModelPos()
	if(self.tileInfo and self.tileInfo.models)then
		local modelInstances = self.tileInfo.models;
		for __,instance in pairs(modelInstances)do
			local model = self.scene:GetObject(instance.id);
			if(model:IsValid())then
				model:SetPosition(self.pos_x + instance.offsetX * self.baseSize,self.pos_y + 0.15,self.pos_z + instance.offsetY * self.baseSize);
			end
		end
	end
end

--private,update mark position
function landCell:UpdateMarkPos()
	if(self.marks)then
		for __,mark in pairs(self.marks) do
			local model = self.scene:GetObject(mark.markID);
			if(model:IsValid())then
				model:SetPosition(self.pos_x,self.pos_y + 0.15,self.pos_z);
			end
		end
	end
end

function landCell:RefreshTerrain()
	if(self.scene==nil or self.scene:IsValid() == false)then
		return;
	end

	if(self.tileInfo and self.tileInfo.terrainInfo)then
		local terrain = self.scene:GetObject(self.name);
		local base = self.scene:GetObject(self.name.."base");
		local terrainInfo = self.tileInfo.terrainInfo;
		
		if(terrain:IsValid() and base:IsValid())then
			--normal land 
			if(terrainInfo.type == Map3DApp.TerrainType.ground)then
				terrain:GetAttributeObject():SetField("render_tech",3);
				terrain:GetEffectParamBlock():Clear();
				terrain:SetFacing(terrainInfo.rotation);
				terrain:GetAttributeObject():SetDynamicField("objType","land");
				terrain:GetAttributeObject():SetDynamicField("attValue",self.tileInfo.id);
				local texture = Map3DApp.Global.AssetManager.GetTexture(terrainInfo.texture0);
				if(texture ~= nil)then
					terrain:SetReplaceableTexture(1,texture);
					base:SetReplaceableTexture(1,texture);
				end
				self.showBase = (self.tileInfo.models and true) or false;
				base:SetVisible(self.showBase);
				base:GetAttributeObject():SetDynamicField("objType","land");
				base:GetAttributeObject():SetDynamicField("attValue",self.tileInfo.id);
				
				
			--render road
			elseif(terrainInfo.type == Map3DApp.TerrainType.road)then
				local __,effectHandle = Map3DApp.Global.Material.GetMapRoad();
				terrain:GetAttributeObject():SetField("render_tech",effectHandle);
				terrain:GetAttributeObject():SetDynamicField("objType","road");
				terrain:SetFacing(terrainInfo.rotation);
				
				local params = terrain:GetEffectParamBlock();
				params:SetTexture(0,terrainInfo.texture0);
				params:SetTexture(1,terrainInfo.texture1);
				self.showBase = false;
				base:SetVisible(self.showBase);
			
			--render water	
			elseif(terrainInfo.type == Map3DApp.TerrainType.water)then
				local effect,effectHandle = Map3DApp.Global.Material.GetOceanWater();
				terrain:GetAttributeObject():SetField("render_tech",effectHandle);
				terrain:GetAttributeObject():SetDynamicField("objType","water");
				terrain:SetFacing(terrainInfo.rotation);
				local params = terrain:GetEffectParamBlock();
				params:Clear();
				local texcoordOffset_x = math.mod(math.floor(self.logicX/self.logicTileSize),8);
				local texcoordOffset_y = math.mod(math.floor((1-self.logicY)/self.logicTileSize),8);
				params:SetVector3("texCoordOffset",0.25,texcoordOffset_x,texcoordOffset_y);
				self.showBase = false;
				base:SetVisible(self.showBase);
			end
		end
	end
end

--private,create new models
function landCell:RefreshModels()
	if(self.tileInfo and self.tileInfo.models)then
		local modelInstances = self.tileInfo.models;
		for __,instance in pairs(modelInstances)do
			local asset = Map3DApp.Global.AssetManager.GetModel(instance.model);
			if(asset)then
				model = ParaScene.CreateMeshPhysicsObject(instance.id,asset,1,1,1,true,"1,0,0,0,1,0,0,0,1");
				model:SetPosition(self.pos_x + instance.offsetX * self.baseSize,self.pos_y + 0.05,self.pos_z + instance.offsetY * self.baseSize);
				model:GetAttributeObject():SetDynamicField("objType","land");
				model:GetAttributeObject():SetDynamicField("attValue",self.tileInfo.id);
				
				self.scene:AddChild(model);
			end
		end
	end
end

function landCell:RefreshMarks()
	if(self.marks)then
		for __,mark in pairs(self.marks)do
			local asset = ParaAsset.LoadParaX("","character/map3d/littlegirl/little girl.x");
			if(asset)then
				model = ParaScene.CreateCharacter(mark.markID,asset,"",true,0.3,9,1.0);
				model:SetPosition(self.pos_x,self.pos_y + 0.15,self.pos_z);
				self.scene:AddChild(model);
			end
		end
	end
end

--clear all models,marks,reset terrain to default state
function landCell:Clear()
	if(self.scene and self.scene:IsValid())then
		self:ResetTerrain();
		self:RemoveModels();
		self:RemoveMarks();
	end
	self.isModelCleared = true;
end

--private,reset terrain to default state
function landCell:ResetTerrain()
	if(self.scene:IsValid())then
		local terrain = self.scene:GetObject(self.name);
		if(terrain)then
			terrain:SetFacing(0);
		end
		
		self.showBase = false;
		local base = self.scene:GetObject(self.name.."base");
		if(base)then
			base:SetVisible(self.showBase);
		end
	end
end

--private,clear all building models
function landCell:RemoveModels()
	if(self.tileInfo and self.tileInfo.models)then
		local modelInstances = self.tileInfo.models;
		for __,instance in pairs(modelInstances)do
			self.scene:DestroyObject(instance.id);
			Map3DApp.ModelInstance.ReleaseModelInst(instance);
		end
	end
end

--private,clear all marks on this tile
function landCell:RemoveMarks(bShow)
	if(self.marks)then
		for __,mark in pairs(self.marks)do
			self.scene:DestroyObject(mark.markID);
		end
	end
end

function landCell:IsDataUpdated()
	return self.dataUpdated;
end

--data privder GetTileInfo() callback function
function landCell.OnReceiveTileInfo(receiver,tileInfo)
	if(receiver == nil or tileInfo == nil)then
		return;
	end
	
	--check if return tileInfo is out of date,if so,discard it,release to object pool
	if(receiver.logicX ~= tileInfo.x or receiver.logicY ~= tileInfo.y)then
		Map3DApp.TileInfo.ReleaseTileInfo(tileInfo);
		return;
	end
	
	--since we use asynchronous call to get tileInfo,
	--make sure real tileInfo will not be replaced by random data
	--tielInfo id less than 0 are random tileInfo;
	if(tonumber(tileInfo.id) < 0)then
		--check if we already get real tileInfo
		if(receiver.tileInfo and tonumber(receiver.tileInfo.id) > 0 and receiver:IsDataUpdated())then
			return;
		end
	end

	receiver:SetTileInfo(tileInfo);
end

function landCell.OnReceiveMarkInfo(receiver,markInfo,markPos_x,markPos_y)
	if(receiver == nil or markInfo == nil)then		
		return;
	end
	
	if(cellPos_x ~= nil and cellpos_y ~= nil)then
		if(receiver.logicX ~= markPos_x or receiver.logicY ~= markPos_y)then
			return;
		end
	end
	
	receiver:SetMarks(markInfo);
end

function landCell:GetPosition()
	log("landCell:GetPosition() not implement\n");
end

function landCell:GetLogicPosition()
	log("landCell:GetLogicPosition() not implement\n");
end

function landCell:SetCellSize()
	log("landCell:SetCellSize() not implement\n");
end

function landCell:GetCellSize()
	log("landCell:GetCellSize() not implement\n");
end

function landCell:SetScene(scene)
	self.scene = scene;
end
