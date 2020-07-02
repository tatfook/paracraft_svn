--[[
Title:
Author(s): SunLingFeng
Desc:
Date: 2008/4/7
Use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Map/TerrainTile.lua");
-------------------------------------------------------
]]

local TerrainTile = {
	name = "terrainTile",
	defaultTex = "model/map3D/texture/texture18.dds",
	terrainInfo = nil,
	parentTile = nil,
	mapCellService = nil,
}
Map3DApp.TerrainTile = TerrainTile;

function TerrainTile:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;
end

function TerrainTile:Show(bShow)
	if(self.mapCellService == nil or self.terrainInfo == nil)then
		return;
	end
	
	local scene = self.mapCellService:GetScene()
	if(scene)then
		local terrain = scene:GetObject(self.name);
		if(terrain:IsValid())then
			terrain:SetVisible(bShow);
		else
			if(bShow)then
				self:CreateTerrain();
				self:RefreshDisplay();
			end
		end
	end
end

--destory object
function TerrainTile:Destory()
	if(self.mapCellService)then
		local scene = self.mapCellService:GetScene();
		if(scene)then
			scene:DestroyObject(self.name);
		end
		self.mapCellService = nil;
	end
end

--update terrain display
function TerrainTile:RefreshDisplay()
	if(self.mapCellService == nil)then
		return;
	end
	
	local scene = self.mapCellService:GetScene();
	if(scene == nil)then
		return;
	end
	
	local terrain = scene:GetObject(self.name);
	if(terrain:IsValid() == false)then
		terrain = self:CreateTerrain(scene);
		if(terrain == nil)then
			return;
		end
	end
	
	if(self.terrainInfo)then
		--for normal terrain
		if(self.terrainInfo.type == Map3DApp.TerrainType.ground)then
			--use normal render approach
			terrain:GetAttributeObject():SetField("render_tech",3);
			terrain:GetEffectParamBlock():Clear();
			terrain:SetFacing(self.terrainInfo.rotation);

			--update base texture
			local texture = Map3DApp.Global.AssetManager.GetTexture(self.terrainInfo.texture0);
			if(texture ~= nil)then
				terrain:SetReplaceableTexture(1,texture);
			end
			
		--for road
		elseif(self.terrainInfo.type == Map3DApp.TerrainType.road)then
			local __,effectHandle = Map3DApp.Global.Material.GetMapRoad();
			terrain:GetAttributeObject():SetField("render_tech",effectHandle);
			terrain:SetFacing(self.terrainInfo.rotation);
			
			--BUG fixed: if all texture are replaced by params:SetTexture(0,self.tileInfo.terrainInfo.texture0);
			-- call tile:GetEffectParamBlock():Clear(); if we want to reuse tile models. 
			local params = terrain:GetEffectParamBlock();
			params:SetTexture(0,self.terrainInfo.texture0);
			params:SetTexture(1,self.terrainInfo.texture1);
			
		--for water
		elseif(self.terrainInfo.type == Map3DApp.TerrainType.water)then
			local effect,effectHandle = Map3DApp.Global.Material.GetOceanWater();
			terrain:GetAttributeObject():SetField("render_tech",effectHandle);
			terrain:SetFacing(self.terrainInfo.rotation);
			
			local params = terrain:GetEffectParamBlock();
			params:Clear();
			local logicX,logicY = self.mapCellService:GetLogicPosition();
			local x = math.mod(math.floor(logicX/self.mapCellService:GetLogicCellSize()),8);
			local y = math.mod(math.floor((1-logicY)/self.mapCellService:GetLogicCellSize()),8);
			params:SetVector3("texCoordOffset",0.25,x,y);
		end
		
		if(self.parentTile ~= nil)then
			terrain:GetAttributeObject():SetDynamicField("tileID",self.parentTile);
		end
	end
end

--reset terrain to initial state
function TerrainTile:Reset()
	if(self.mapCellService)then
		local scene = self.mapCellService:GetScene();
		if(scene)then
			local terrain = scene:GetObject(self.name);
			if(terrain == nil)then
				self:CreateTerrain();
			else
				self:ResetTerrain(terrain);
			end
		end
	end
end

function TerrainTile:OnPositionChange()
	if(self.mapCellService == nil)then
		return;
	end
	
	local scene = self.mapCellService:GetScene();
	if(scene)then
		local x,y,z = self.mapCellService:GetPosition();
		local terrain = scene:GetObject(self.name);
		if(terrain:IsValid())then
			terrain:SetPosition(x,y,z);
		end
	end
end

function TerrainTile:SetTerrainInfo(terrainInfo)
	self.terrainInfo = terrainInfo;
end

function TerrainTile:SetParentTile(parentTile)
	self.parentTile = parentTile;
end

function TerrainTile:SetDefaultTexture(textureName)
	self.defaultTex = textureName;
end

--=========private method==============
function TerrainTile:CreateTerrain()
	if(self.mapCellService == nil or self.terrainInfo == nil)then
		return;
	end
	
	local scene = self.mapCellService:GetScene();
	if(scene)then
		local asset = Map3DApp.Global.AssetManager.GetModel("model/common/map3D/map3D.x");
		if(asset ~= nil)then
			local terrain = ParaScene.CreateMeshPhysicsObject(self.name,asset,1,1,1,false,"1,0,0,0,1,0,0,0,1,0,0,0");
			terrain:GetAttributeObject():SetField("progress",1);
			self:ResetTerrain(terrain);
			scene:AddChild(terrain);
			return terrain;
		end
		
	end
end

function TerrainTile:ResetTerrain(terrain)
	terrain:SetFacing(0);
	terrain:SetScale(self.mapCellService:GetCellSize());
	local texture = Map3DApp.Global.AssetManager.GetTexture(self.defaultTex);
	if(texture)then
		terrain:SetReplaceableTexture(1,texture);
	end
end

