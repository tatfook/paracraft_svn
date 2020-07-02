--[[
Title: Group
Author(s): Leio
Date: 2008/11/26
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Entity/Group.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/TreeView.lua");
local Group = commonlib.inherit(CommonCtrl.TreeNode,{
	ID = nil,
	Selected = false,
	Property = "group",
});  
commonlib.setfield("Map3DSystem.App.Inventor.Group",Group);
function Group:__Initialization()
	self:SetID(ParaGlobal.GenerateUniqueID());
end
function Group:SetParams(v)

end
function Group:GetParams()
	local node = self:GetChild(1);
	if(node)then
		return node:GetParams();
	end
end
function Group:SetID(v)
	self.ID = v;
end
function Group:GetID()
	return self.ID;
end
function Group:SetEntityID(v)

end
function Group:GetEntityID()

end
function Group:SetPicking(v)
	self.picking = v;
end
function Group:GetPicking()
	return self.picking;
end
function Group:SetSelected(v)
	self.internal_selected = v;
	local k,node;
	for k,node in ipairs(self.Nodes) do
		node:SetSelected(v);
	end
end
function Group:GetSelected()
	return self.internal_selected;
end
function Group:Draw()

end
function Group:HitTestObject(startPoint,lastPoint)
	if(not startPoint or not lastPoint)then return end
	local left, top, right, bottom = startPoint.x,startPoint.y,lastPoint.x,lastPoint.y;
	if(not left or not top or not right or not bottom)then return end
	if( not commonlib.partialcompare(left, right, Map3DSystem.App.Inventor.GlobalInventor.minDistance) or
			not commonlib.partialcompare(top, bottom, Map3DSystem.App.Inventor.GlobalInventor.minDistance)) then	
		local k,node;
		for k,node in ipairs(self.Nodes) do
			local r = node:HitTestObject(startPoint,lastPoint);
			if(r == true)then
				return true;
			end
		end		
	end
end
function Group:HitTest(point)
	local obj = ParaScene.MousePick(40, "anyobject");
	if(obj:IsValid()) then
		local k,node;
		for k,node in ipairs(self.Nodes) do
				local result = node:HitTest();
				if(result == 0)then
					return result;
				end
		end	
	end
	return -1;
end
function Group:MoveHandleTo(point,num)

end
function Group:SaveAsTable()
	local t = {};
	t.TagProperty = self.Property;
	t.ID = self.ID;
	t.Data = {};
	local k,node;
	for k,node in ipairs(self.Nodes) do
		table.insert(t.Data,node:SaveAsTable());
	end
	return t;
end
function Group:Clone()
	local clone_node = commonlib.deepcopy(self);
	clone_node:ClearAllChildren();
	local k,node;
	for k,node in ipairs(self.Nodes) do
		clone_node:AddChild(node:Clone());
	end
	return clone_node;
end
function Group:CloneNoneID()
	local clone_node = commonlib.deepcopy(self);
	clone_node:SetID(ParaGlobal.GenerateUniqueID());
	clone_node:ClearAllChildren();
	local k,node;
	for k,node in ipairs(self.Nodes) do
		clone_node:AddChild(node:CloneNoneID());
	end
	return clone_node;
end
function Group:BuildEntity()
	local k,node;
	for k,node in ipairs(self.Nodes) do
		node:BuildEntity();
	end
end
function Group:Delete(notDestroy)
	local k,node;
	while(len > 0) do
		local node = self.Nodes[len];
		if(node)then
			node:Delete(notDestroy);
		end
		len = len - 1;
	end
	self:Detach();
end
function Group:DestroyEntity()
	local k,node;
	for k,node in ipairs(self.Nodes) do
		node:DestroyEntity();
	end
end

--function Group:UpdateEntity(params)
	--if(not params)then return end
	--local firstNode;
	--local firstNodeParams;
	--local point3D = {};
	--local k,node;
	--for k,node in ipairs(self.Nodes) do
		--if(k == 1)then
			--firstNode = node;
			--firstNodeParams = node:GetParams();
			--point3D.x = params.x - firstNodeParams.x;
			--point3D.y = params.y - firstNodeParams.y;
			--point3D.z = params.z - firstNodeParams.z;
			--node:UpdateEntity(params)
		--else
			--local new_params = commonlib.deepcopy(node:GetParams());
			--new_params.x = new_params.x + point3D.x;
			--new_params.y = new_params.y + point3D.y;
			--new_params.z = new_params.z + point3D.z;
			--node:UpdateEntity(new_params)
		--end
	--end
--end
function Group:MoveDelta(point3D)
	local k,node;
	for k,node in ipairs(self.Nodes) do
		node:MoveDelta(point3D);
	end
end
function Group:ResetPosition()
	local k,node;
	for k,node in ipairs(self.Nodes) do
		node:ResetPosition();
	end
end
function Group:ResetRotation()
	local k,node;
	for k,node in ipairs(self.Nodes) do
		node:ResetRotation();
	end
end
function Group:ResetScale()
	local k,node;
	for k,node in ipairs(self.Nodes) do
		node:ResetScale();
	end
end
function Group:Move(point3D)
	local k,node;
	for k,node in ipairs(self.Nodes) do
		node:Move(point3D);
	end
end
function Group:Rotate(point3D)
	local k,node;
	for k,node in ipairs(self.Nodes) do
		node:Rotate(point3D);
	end
end
function Group:Scale(scale)
	local k,node;
	for k,node in ipairs(self.Nodes) do
		node:Scale(scale);
	end
end
-- rotate input vector3 around a given point.
-- @param ox, oy, oz: around which point to rotate the input. 
-- @param a,b,c: radian around the X, Y, Z axis, such as 0, 1.57, 0
function Group:vec3RotateByPoint(ox, oy, oz, a, b, c)
	local k,node;
	for k,node in ipairs(self.Nodes) do
		node:vec3RotateByPoint(ox, oy, oz, a, b, c)
	end
end

-- it is a absolute value
function Group:SetPosition(x,y,z)
	local k,node;
	for k,node in ipairs(self.Nodes) do
		node:SetPosition(x,y,z)
	end
end
-- it is a absolute value
function Group:SetRotation(x,y,z,w)
	local k,node;
	for k,node in ipairs(self.Nodes) do
		node:SetRotation(x,y,z,w)
	end
end
-- it is a absolute value
function Group:SetScale(v)
	local k,node;
	for k,node in ipairs(self.Nodes) do
		node:SetScale(v)
	end
end
-- it is a absolute value
function Group:SetFacing(v)
	local k,node;
	for k,node in ipairs(self.Nodes) do
		node:SetFacing(v)
	end
end
-- it is a absolute value
function Group:SetRotate(point3D)
	local k,node;
	for k,node in ipairs(self.Nodes) do
		node:SetRotate(point3D)
	end
end
function Group:SetPositionDelta(point3D)
	local k,node;
	for k,node in ipairs(self.Nodes) do
		node:SetPositionDelta(point3D)
	end
end
function Group:SetRotationDelta(point3D)
	local k,node;
	for k,node in ipairs(self.Nodes) do
		node:SetRotationDelta(point3D)
	end
end
function Group:SetScaleDelta(v)
	local k,node;
	for k,node in ipairs(self.Nodes) do
		node:SetScaleDelta(v)
	end
end
function Group:SetRotateDelta(v)
	local k,node;
	for k,node in ipairs(self.Nodes) do
		node:SetRotateDelta(v)
	end
end
function Group:SetFacingDelta(v)
	local k,node;
	for k,node in ipairs(self.Nodes) do
		node:SetFacingDelta(v)
	end
end
function Group:UpdateEntityParams()
	local k,node;
	for k,node in ipairs(self.Nodes) do
		node:UpdateEntityParams()
	end
end
function Group:UpdatePropertyByDeltaParams(params)
	if(not params)then return end;
	local k,node;
	for k,node in ipairs(self.Nodes) do
		node:UpdatePropertyByDeltaParams(params);
	end
end
function Group:SetPositionParams(point3D)
	if(not point3D)then return end
	local k,node;
	for k,node in ipairs(self.Nodes) do
		node:SetPositionParams(point3D);
	end
end
function Group:SetPositionParamsDelta(point3D)
	if(not point3D)then return end
	local k,node;
	for k,node in ipairs(self.Nodes) do
		node:SetPositionParamsDelta(point3D);
	end
end
function Group:SetRotationParams(point3D)
	if(not point3D)then return end
	local k,node;
	for k,node in ipairs(self.Nodes) do
		node:SetRotationParams(point3D);
	end
end
function Group:SetRotationParamsDelta(point3D)
	if(not point3D)then return end
	local k,node;
	for k,node in ipairs(self.Nodes) do
		node:SetRotationParamsDelta(point3D);
	end
end
function Group:SetFacingParams(facing)
	if(not facing)then return end
	local k,node;
	for k,node in ipairs(self.Nodes) do
		node:SetFacingParams(facing);
	end
end
function Group:SetHomeZone(s)
	if(not s)then return end
	local k,node;
	for k,node in ipairs(self.Nodes) do
		node:SetHomeZone(s);
	end
end
function Group:UpdatePlanesParam(facing)
	if(not facing)then return end
	local k,node;
	for k,node in ipairs(self.Nodes) do
		node:UpdatePlanesParam(facing);
	end
end
