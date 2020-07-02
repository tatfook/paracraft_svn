

local MarkGroup = {
	id = "markgp",
	marks = nil,
	mapCellService = nil,
}
Map3DApp.MarkGroup = MarkGroup;

function MarkGroup:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;
end

function MarkGroup:Destory()
	self:RemoveModels();
	marks = nil;
end

function MarkGroup:Show(bShow)
	if(self.mapCellService == nil or self.marks == nil)then
		return;
	end
	
	local scene = self.mapCellService:GetScene();
	if(scene)then
		for __,mark in pairs(self.marks) do
			local model = scene:GetObject(mark.markID);
			if(model:IsValid())then
				model:SetVisible(bShow);
			else
				if(bShow)then
					self:RefreshDisplay();
				end
			end
		end
	end
end

function MarkGroup:RemoveMarks()
	if(self.mapCellService == nil or self.marks == nil)then
		return;
	end
	
	local scene = self.mapCellService:GetScene()
	if(scene)then
		for __,mark in pairs(self.marks) do
			scene:DestroyObject(mark.markID);
		end
	end
end

function MarkGroup:OnPositionChange()
	if(self.mapCellService == nil or self.marks == nil)then
		return;
	end
	
	local scene = self.mapCellService:GetScene();
	if(scene)then
		for __,mark in pairs(self.marks) do
			local model = scene:GetObject(mark.markID);
			if(model:IsValid())then
				self:UpdateMarkPosition(model,mark);
			end
		end
	end			
end

function MarkGroup:SetMarkData(marks)
	self:RemoveMarks();
	self.marks = marks;
end

function MarkGroup:RefreshDisplay()
	self:RemoveMarks();
	self:CreateMarks();
end

function MarkGroup:CreateMarks()
	if(self.mapCellService == nil or self.marks == nil)then
		return;
	end
	
	local scene = self.mapCellService:GetScene();
	if(scene)then
		for __,mark in pairs(self.marks) do
			local asset = ParaAsset.LoadParaX("","character/map3d/littlegirl/little girl.x");
			if(asset)then
				model = ParaScene.CreateCharacter(mark.markID,asset,"",true,0.3,9,1.0);
				model:GetAttributeObject():SetDynamicField("type",Map3DApp.ModelUsage.mark);
				self:UpdateMarkPosition(model,mark);
				scene:AddChild(model);
			end
		end
	end
end

function MarkGroup:UpdateMarkPosition(markModel,mark)
	local x,y,z = self.mapCellService:GetPosition();
	local logicX,logicY = self.mapCellService:GetLogicPosition();
	x = x + (mark.x - logicX) * self.mapCellService:GetCellSize();
	y = y + 0.05;
	z = z + (mark.y - logicY) * self.mapCellService:GetCellSize();
	markModel:SetPosition(x,y,z);
end