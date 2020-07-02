
--[[
Title:render group models of a tile 
Author(s): Sun Lingfeng
Date: 2008/4/9
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/API/MapModelGroup.lua");
local modelGroup = Map3DApp.ModelGroup:new{
	id = "modelgp",
};
-------------------------------------------------------
]]
local ModelGroup = {
	id = "modelgp",
	scene = nil,
	scale = 1,
	--an array of model data
	modelInstances = nil,
	lastModelInstances = nil,
	mapCellService = nil,
	parentTile = nil,
}
Map3DApp.ModelGroup = ModelGroup;


function ModelGroup:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;
end

function ModelGroup:Destory()
	self:RemoveModels();
	mapCellService = nil;
	modelInstances = nil;
end

function ModelGroup:Show(bShow)
	if(self.mapCellService == nil or self.modelInstances ==nil)then
		return;
	end
	
	local scene = self.mapCellService:GetScene();
	if(scene)then
		for __,modelInst in pairs(self.modelInstances) do
			local model = scene:GetObject(modelInst.id);
			if(model:IsValid())then
				model:SetVisible(bShow);
			else
				if(bShow)then
					self:RefreshDisplay();
					break
				end
			end
		end
	end
end

--remove all models
function ModelGroup:RemoveModels()
	if(self.mapCellService == nil or self.lastModelInstances ==nil)then
		return;
	end
	
	local scene = self.mapCellService:GetScene();
	if(scene)then
		for __,modelInst in pairs(self.lastModelInstances) do
			scene:DestroyObject(modelInst.id);
			Map3DApp.ModelInstance.ReleaseModelInst(modelInst);
		end
	end
end

function ModelGroup:OnPositionChange()
	if(self.mapCellService == nil or self.modelInstances == nil)then
		return;
	end
	
	local scene = self.mapCellService:GetScene();
	if(scene)then
		local x,y,z = self.mapCellService:GetPosition();
		for __,modelInst in pairs(self.modelInstances)do
			local model = scene:GetObject(modelInst.id);
			if(model:IsValid())then
				model:SetPosition(x + modelInst.offsetX * self.scale,y + 0.05,z + modelInst.offsetY * self.scale);
			end
		end
	end
end

--call RefreshDisplay after SetModelData to show new models
function ModelGroup:SetModelData(modelInstances)	
	self.lastModelInstances = self.modelInstances;
	self.modelInstances = modelInstances;
end

--set model scale value
function ModelGroup:SetScale(scale)
	self.scale = scale;
end

function ModelGroup:SetParentTile(parentTile)
	self.parentTile = parentTile;
end

function ModelGroup:RefreshDisplay()
	self:RemoveModels();
	self:CreateModels();
end

--==========private==============
function ModelGroup:CreateModels()
	if(self.mapCellService == nil or self.modelInstances ==nil)then
		return;
	end
	
	local scene = self.mapCellService:GetScene();
	if(scene)then
		local x,y,z = self.mapCellService:GetPosition();
		for __,modelInst in pairs(self.modelInstances)do
			local asset = Map3DApp.Global.AssetManager.GetModel(modelInst.model);
			if(asset)then
				model = ParaScene.CreateMeshPhysicsObject(modelInst.id,asset,1,1,1,true,"1,0,0,0,1,0,0,0,1");
				model:GetAttributeObject():SetDynamicField("tileID",self.parentTile);
				model:SetPosition(x + modelInst.offsetX * self.scale,y + 0.05,z + modelInst.offsetY * self.scale);
				scene:AddChild(model);
			end
		end	
	end
end
