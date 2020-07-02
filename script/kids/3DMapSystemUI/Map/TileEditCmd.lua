--========================================
Map3DApp.Commands = {};

--==========================================
Map3DApp.Commands.IDGenerator = {};
Map3DApp.Commands.IDGenerator.id = 1;
Map3DApp.Commands.tileEditor = nil;
function Map3DApp.Commands.IDGenerator.GetNewID()
	Map3DApp.Commands.IDGenerator.id = Map3DApp.Commands.IDGenerator.id + 1;
	return Map3DApp.Commands.IDGenerator.id;
end



function Map3DApp.Commands.CreateCommand(cmdName,modelInstance)
	if(Map3DApp.Commands.tileEditor == nil)then
		return nil
	end
	
	if(cmdName == "addModel")then
		return Map3DApp.Commands.AddModelCmd:new{};
	elseif(cmdName == "MoveModel")then
	
	elseif(cmdName == "RotateModel")then
	
	elseif(cmdName == "DeleteModel")then
	
	end
end

-------------------------------------------------
--===========add model command===================
-------------------------------------------------
local AddModel = {
	cmdID = 0,
	
	modelID = 0,
	modelData = nil,
	
	sceneEditor = nil,
	editManager = nil,
}
Map3DApp.Commands.AddModelCmd = AddModel;

function AddModel:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;
end

function AddModel:Execute()
	self:Validate();
	self.editManager.AddModel(self.modelID,self.modelData);
	self.sceneEditor.AddModel(self.modelID,self.modelData);
end

function AddModel:Undo()
	self.editManager.RemoveModel(self.modelID);
	self.sceneEditor.RemoveModel(self.modelID);
end

function AddModel:Validate()
end

function AddModel:Dispose()
	self.cmdID = nil;
	self.modelID = nil;
	self.modelData = nil;
	self.sceneEditor = nil;
	self.editManager = nil;
end
--==================================================


local addModel = {
	id = 0,
	tileEditor = nil
}
Map3DApp.Commands.AddModelCmd = addModel;

function addModel:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;
end

function addModel:Execute()
	tileEditor:AddModel();	
end

function addModel:Undo()
end





---------------------------------------------------------
--============change model position command===============
--change model position
local MoveModelCmd = {
	cmdID = 0,
	modelID = 0,
	
	newPosX = 0,
	newPosY = 0,
	oldPosX = 0,
	oldPosY = 0,
	
	sceneEditor = nil,
	editManager = nil,
}
Map3DApp.Commands.MoveModelCmd = MoveModelCmd

function MoveModelCmd:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;	
end

function MoveModelCmd:Execute()
	local modelData = self.editManager.GetModelInfo(self.modelID);
	if(modelData)then
		self.oldPosX = modelData.offsetX;
		self.oldPosY = modelData.offsetY;
		modelData.offsetX = self.newPosX;
		modelData.offsetY = self.newPosY;
		self.editManager.SetModelInfo(self.modelID,modelData);
		self.sceneEditor.SetModelPosition(self.modelID,self.newPosX,0,self.newPosY);
	end
end

function MoveModelCmd:Undo()
	local modelData = self.editManager.GetModelInfo(self.modelID);
	if(modelData)then
		modelData.offsetX = self.oldPosX;
		modelData.offsetY = self.oldPosY;
		self.editManager.SetModelInfo(self.modelID,modelData);
		self.sceneEditor.SetModelPosition(self.modelID,self.oldPosX,0,self.oldPosY);
	end
end

function MoveModelCmd:Validate()
end

function MoveModelCmd:Dispose()	
	self.sceneEditor = nil;
	self.editManager = nil;
end

--=============change model facing command=================
local ChangeModelFacing = {
	cmdID = 0,
	modelID = 0,
	
	newFacing = 0,
	oldFacing = 0,
	
	sceneEditor = nil,
	editManager = nil,
}
Map3DApp.Commands.ChangeModelFacingCmd = ChangeModelFacing;

function ChangeModelFacing:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;	
end

function ChangeModelFacing:Execute()
	local modelData = self.editManager.GetModelInfo(self.modelID);
	if(modelData)then
		self.oldFacing = modelData.facing;
		modelData.facing = self.newFacing;
		self.editManager.SetModelInfo(self.modelID,modelData);
		self.sceneEditor.SetModelFacing(self.modelID,self.newFacing);
	end
end

function ChangeModelFacing:Undo()
	local modelData = self.editManager.GetModelInfo(self.modelID);
	if(modelData)then
		modelData.facing = self.oldFacing;
		self.editManager.SetModelInfo(self.modelID,modelData);
		self.sceneEditor.SetModelFacing(self.modelID,self.oldFacing);
	end
end

function ChangeModelFacing:Validate()
end

function ChangeModelFacing:Dispose()
	self.sceneEditor = nil;
	self.editManager = nil;
end

--=================delete model command====================
local DeleteModel = {
	cmdID = 0,
	modelID = 0,
	modelData = nil,
	sceneEditor = nil,
	eidtManager = nil,
}
Map3DApp.Commands.DeleteModelCmd = DeleteModel

function DeleteModel:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;
end

function DeleteModel:Execute()
	self.modelData = self.editManager.GetModelInfo(self.modelID);
	self.editManager.RemoveModel(self.modelID);
	self.sceneEditor.RemoveModel(self.modelID);
end

function DeleteModel:Validata()
end

function DeleteModel:Undo()
	self.editManager.AddModel(self.modelID,self.modelData)
	self.sceneEditor.AddModel(self.modelID,self.modelData);
end

function DeleteModel:Dispose()
	self.modelData = nil;
	self.sceneEditor = nil;
	self.eidtManager = nil;
end