

NPL.load("(gl)script/kids/3DLMapSystemUI/Map/TileEditCmdHolder.lua");

local tileEditor = {
	name = "tileEditor",
	tileEditScene = nil,
	cmds = nil,
	tileInfo = nil,
	
	id = 0;
}
Map3DApp.TileEditor = tileEditor;

function tileEditor:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	
	o.cmds = Map3DApp.CommandHolder:new();
	
	return o;
end

function tileEditor:SetTileInfo(tileInfo)
	self.tileInfo = tileInfo;
	
	if(tileInfo.models)then
		for __,v in paris(tileInfo.models)do
			local id = self:GenerateInstanceID();
			self.models[id] = {};
			self.models[id].data = commonlib.deepcopy(v);
			self.models[id].id = id; 
		end
	end
end

function tileEditor:AddModel()
	local id = self:GenerateInstanceID();
	self.models[id] = {};
	self.models[id].data = modelInstance;
	self.models[id].id = id;
	
	if(self.onAddModel)then
		self.onAddModel(id,modelInstance,"model");
	end
end

function tileEditor:MoveModel()

end

function tileEditor:RotateModel()

end

--public,prepare to add a model
function tileEditor:ChooseModel()

end

function tileEditor:SelectModel()

end

function tileEditor:DeleteModel()
	
end

function tileEditor:Redo()
	if(self.cmds:CanRedo())then
		self.cmds:Redo();
	end
end

function tileEditor:Undo()
	if(self.cmds:CanUndo())then
		self.cmds:Undo();
	end
end

function tileEditor:SaveTileInfo()
end

function tileEditor:Reset()
	self.cmds = {};
	self.id = 0;
end

function tileEditor:GenerateInstanceID()
	self.id = self.id + 1;
	return self.id;
end







