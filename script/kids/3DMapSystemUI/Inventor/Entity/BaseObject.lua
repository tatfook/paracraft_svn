--[[
Title: BaseObject
Author(s): Leio
Date: 2008/11/24
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Entity/BaseObject.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Tools/TransformationBox.lua");
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/TreeView.lua");
NPL.load("(gl)script/ide/math/math3d.lua");
local BaseObject = commonlib.inherit(CommonCtrl.TreeNode,{
	EntityID = nil,
	ID = nil,
	Selected = false,
	Property = "entity",
	handleNode = nil,
	picking = false,
});  
commonlib.setfield("Map3DSystem.App.Inventor.BaseObject",BaseObject);
function BaseObject:__Initialization()
	self:SetID(ParaGlobal.GenerateUniqueID());
end
function BaseObject:GetEntityName()
	local obj = self:GetEntity();
	if(obj)then
		return obj.name
	end
	local params = self:GetParams();
	if(params and params["name"])then
		return params["name"];
	end
	return "none";
end
function BaseObject:BindEntity(obj)
	if(not obj or not obj:IsValid())then return end
	local id = obj:GetID();
	self:SetEntityID(id);
end
function BaseObject:GetEntity()
	local id = self:GetEntityID();
	local obj 
	if(id)then
		obj = ParaScene.GetObject(id);
		if(obj and obj:IsValid())then
			return obj;
		end
	end
end
function BaseObject:InitHanleSolid()
end
function BaseObject:ReSetHandleRectangle()
	
end
-- return a point
function BaseObject:GetHandle(handleNumber)
	return {x = 0,y = 0};
end
function BaseObject:SetID(v)
	self.ID = v;
end
function BaseObject:GetID()
	return self.ID;
end
function BaseObject:SetEntityID(v)
	self.EntityID = v;
end
function BaseObject:GetEntityID()
	return self.EntityID;
end
function BaseObject:HandleCount()
	return 8;
end
function BaseObject:SetParams(v)
	self.params = v;
end
function BaseObject:GetParams()
	return self.params;
end

---------------------------------------------------
function BaseObject:SetPicking(v)
	self.picking = v;
end
function BaseObject:GetPicking()
	return self.picking;
end
function BaseObject:SetSelected(v)
	self.internal_selected = v;
	local params = self:GetParams();
	if(params)then
		local obj = self:GetEntity()
		if(obj and obj:IsValid())then
			if(v == true)then
				obj:GetAttributeObject():SetField("showboundingbox", true);
			else
				
				obj:GetAttributeObject():SetField("showboundingbox", false);
			end
		end
	end
end
function BaseObject:GetSelected()
	return self.internal_selected;
end
function BaseObject:Draw()

end
function BaseObject:HitTestObject(startPoint,lastPoint)
	if(not startPoint or not lastPoint)then return end
		local _left, _top, _right, _bottom = startPoint.x,startPoint.y,lastPoint.x,lastPoint.y;
		if(not _left or not _top or not _right or not _bottom)then return end
		local left = math.min(_left,_right);
		local right = math.max(_left,_right);
		local top = math.min(_top,_bottom);
		local bottom = math.max(_top,_bottom);
	local result = {};
	if( not commonlib.partialcompare(left, right, Map3DSystem.App.Inventor.GlobalInventor.minDistance) or
			not commonlib.partialcompare(top, bottom, Map3DSystem.App.Inventor.GlobalInventor.minDistance)) then				
			ParaScene.GetObjectsByScreenRect(result, left, top, right, bottom, "4294967295", -1);
	end
	
	if(#result > 0)then
		local __,obj;
		for __,obj in ipairs(result) do
			if(self:GetEntityID() == obj:GetID())then
				return true;
			end
		end		
	end
end
function BaseObject:HitTestPoint(point)

end
function BaseObject:HitTest(point)
	-- for test
	--if(not point)then return; end
	local obj = ParaScene.MousePick(40, "4294967295");
	if(obj:IsValid()) then
		if(self:GetEntityID() == obj:GetID())then
			return 0;
		end
	end
	return -1;
	--if(not point)then return; end
    --if(self:GetSelected())then
		--local k,len =1,self:HandleCount();
		--for k = 1,len do
			--local node = self.handleNode:GetChild(i);
			--if(node)then
				--if(node:HitTestPoint(point))then
					--return k;
				--end
			--end
		--end
		--if(self:HitTestPoint(point))then
			--return 0;
		--end
    --end
	--return -1;
end
function BaseObject:MoveHandleTo(point,num)

end
function BaseObject:SaveAsTable()
	local t = {};
	t.TagProperty = self.Property;
	t.Data = self:CloneNoneID();
	return t;
end
function BaseObject.OpenFromTable(data)
	if(not data )then return end
	local clone_node = Map3DSystem.App.Inventor.BaseObject:new();
	
	clone_node:SetID(data.ID);
	clone_node:SetEntityID("");
	clone_node:SetParams(data.params)
	clone_node:SetSelected(false);
	return clone_node;
end
function BaseObject:Clone()
	local params = self:GetParams();
	params = commonlib.deepcopy(params);
	local clone_node = Map3DSystem.App.Inventor.BaseObject:new();
	clone_node:SetID(self:GetID());
	clone_node:SetEntityID(self:GetEntityID());
	clone_node:SetParams(params)
	clone_node:SetSelected(self:GetSelected());

	return clone_node;
end
function BaseObject:CloneNoneID()
	local clone_node = self:Clone();
	local params = clone_node:GetParams();
	params["homezone"]  = ""; -- clear homezone
	clone_node:SetID(ParaGlobal.GenerateUniqueID());
	clone_node:SetEntityID("");
	clone_node.params.name = clone_node:GetID(); 
	return clone_node;
end
function BaseObject:Delete(notDestroy)
	self:Detach();
	if(not notDestroy)then
		self:DestroyEntity();
	end
end
function BaseObject:UpdateEntityParams()
	local obj = self:GetEntity();
	if(obj)then
		local params = ObjEditor.GetObjectParams(obj);
		if(params)then
			params["homezone"] = obj:GetAttributeObject():GetField("homezone","")
			self:SetParams(params);		
		end
	end
end

function BaseObject:UpdateProperty()
	local params = self:GetParams();
	local x,y,z = params.x,params.y,params.z;
	self:SetPosition(x,y,z);
	if(params.rotation)then
		x,y,z,w = params.rotation.x,params.rotation.y,params.rotation.z,params.rotation.w;
		self:SetRotation(x,y,z,w);
	end
	local scaling = params.scaling;
	self:SetScale(scaling);
	local facing = params.facing;
	self:SetFacing(facing)
	self:SetHomeZone(params.homezone);	
end
function BaseObject:UpdatePropertyByParams(params)

end
function BaseObject:UpdatePropertyByDeltaParams(params)
	if(not params)then return end;
	local x,y,z = params.x,params.y,params.z;
	self:SetPositionDelta({x = x,y = y,z = z});
	x,y,z = params.rotation.x,params.rotation.y,params.rotation.z;
	self:SetRotateDelta({x = x,y = y,z = z});
	local scaling = params.scaling;
	self:SetScaleDelta(scaling);
	local facing = params.facing;
	self:SetFacingDelta(facing);
	
	-- update parsms
	self:UpdateEntityParams();
end
function BaseObject:BuildEntity()
	local params = self:GetParams();
	if(params)then
		local obj = self:GetEntity();
		if(not obj)then
			obj = self:Internal_CreateObjectByParams(params);
			self:BindEntity(obj);				
		end		
		if(obj)then
			local selected = self:GetSelected();
			obj:GetAttributeObject():SetField("showboundingbox", selected);
			ParaScene.Attach(obj);
			self:UpdateProperty();
			return true;
		end
	end
end
function BaseObject:DestroyEntity()
	local obj = self:GetEntity()
	if(obj)then
		ParaScene.Detach(obj);
		--ParaScene.Delete(obj);
		return true;
	end
end
function BaseObject:Internal_CreateObjectByParams(params)
	local obj = ObjEditor.CreateObjectByParams(params);
	--params["homezone"] = obj:GetAttributeObject():GetField("homezone","")
	return obj;
end
function BaseObject:ResetPosition()
	local objGraph = ParaScene.GetMiniSceneGraph("object_editor");
	local id = tostring(self:GetID());
	local cursorObj = objGraph:GetObject(id);
	if(cursorObj:IsValid()) then
		--local old_obj_params = self:GetParams();
		local obj_params = ObjEditor.GetObjectParams(cursorObj)
		--
			---- delete object in clipboard and create object in clipboard at the new location, if and only if any property changes	
			--if( not commonlib.partialcompare(obj_params.x, old_obj_params.x, Map3DSystem.App.Inventor.GlobalInventor.minDistance) or
				--not commonlib.partialcompare(obj_params.y, old_obj_params.y, Map3DSystem.App.Inventor.GlobalInventor.minDistance) or
				--not commonlib.partialcompare(obj_params.z, old_obj_params.z, Map3DSystem.App.Inventor.GlobalInventor.minDistance) ) then
				--
				--Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeleteObject, obj_params=old_obj_params});
				--Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_CreateObject, obj_params=obj_params,effect = "boundingbox"});
				--
				--self:SetParams(obj_params);
			--end	
			local x,y,z = obj_params.x,obj_params.y,obj_params.z;		
			self:SetPosition(x,y,z);
			self:UpdateEntityParams();
			--visuals	
			objGraph:DestroyObject(id);	
	end
end
function BaseObject:ResetRotation()
	local objGraph = ParaScene.GetMiniSceneGraph("object_editor");
	local id = tostring(self:GetID());
	local cursorObj = objGraph:GetObject(id);
	if(cursorObj:IsValid()) then
		--local old_obj_params = self:GetParams();
		local obj_params = ObjEditor.GetObjectParams(cursorObj)
			---- delete object in clipboard and create object in clipboard at the new location, if and only if any property changes	
			--if( not commonlib.partialcompare(obj_params.rotation.x, old_obj_params.rotation.x, Map3DSystem.App.Inventor.GlobalInventor.minDistance) or
				--not commonlib.partialcompare(obj_params.rotation.y, old_obj_params.rotation.y, Map3DSystem.App.Inventor.GlobalInventor.minDistance) or
				--not commonlib.partialcompare(obj_params.rotation.z, old_obj_params.rotation.z, Map3DSystem.App.Inventor.GlobalInventor.minDistance) ) then
				--Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeleteObject, obj_params=old_obj_params});
				--Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_CreateObject, obj_params=obj_params,effect = "boundingbox"});
				--
				--self:SetParams(obj_params);
			--end				
			local x,y,z,w = obj_params.rotation.x,obj_params.rotation.y,obj_params.rotation.z,obj_params.rotation.w;	
			self:SetRotation(x,y,z,w);
			self:UpdateEntityParams();
			--visuals	
			objGraph:DestroyObject(id);
		
	end
end
function BaseObject:ResetScale()
	local objGraph = ParaScene.GetMiniSceneGraph("object_editor");
	local id = tostring(self:GetID());
	local cursorObj = objGraph:GetObject(id);
	if(cursorObj:IsValid()) then
		--local old_obj_params = self:GetParams();
		local obj_params = ObjEditor.GetObjectParams(cursorObj)
		
			---- delete object in clipboard and create object in clipboard at the new location, if and only if any property changes	
			--if( not commonlib.partialcompare(obj_params.scaling, old_obj_params.scaling, Map3DSystem.App.Inventor.GlobalInventor.minDistance)) then
				--Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeleteObject, obj_params=old_obj_params});
				--Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_CreateObject, obj_params=obj_params,effect = "boundingbox"});
				--
				--self:SetParams(obj_params);
			--end				
			local scaling = obj_params.scaling;
			self:SetScale(scaling);
			self:UpdateEntityParams();
			--visuals	
			objGraph:DestroyObject(id);		
	end
end
function BaseObject:Move(point3D)
	if(not point3D)then return; end
	-- visuals
	local objGraph = ParaScene.GetMiniSceneGraph("object_editor");
	local id = tostring(self:GetID());
	local cursorObj = objGraph:GetObject(id);
	if(cursorObj and cursorObj:IsValid())then
		local params = ObjEditor.GetObjectParams(cursorObj)
		local x = params.x + point3D.x;
		local y = params.y + point3D.y;
		local z = params.z + point3D.z;
		cursorObj:SetPosition(x, y, z);
	else	
		local obj_params = self:GetParams();	
		if(obj_params)then
			obj_params = commonlib.deepcopy(self:GetParams());
			obj_params.name = id;
			cursorObj = ObjEditor.CreateObjectByParams(obj_params);
			if(cursorObj and cursorObj:IsValid())then
				objGraph:AddChild(cursorObj);
			end
		end
	end
end
function BaseObject:Rotate(point3D)
	if(not point3D)then return; end
	-- visuals
	local objGraph = ParaScene.GetMiniSceneGraph("object_editor");
	local id = tostring(self:GetID());
	local cursorObj = objGraph:GetObject(id);
	if(cursorObj and cursorObj:IsValid())then
		local params = ObjEditor.GetObjectParams(cursorObj)
		local x = params.rotation.x + point3D.x;
		local y = params.rotation.y + point3D.y;
		local z = params.rotation.z + point3D.z;
		local w = params.rotation.w;
		cursorObj:Rotate(x,y,z);
	else	
		local obj_params = self:GetParams();
		if(obj_params)then
			obj_params = commonlib.deepcopy(self:GetParams());
			obj_params.name = id;
			cursorObj = ObjEditor.CreateObjectByParams(obj_params);
			if(cursorObj and cursorObj:IsValid())then
				objGraph:AddChild(cursorObj);
			end
		end
	end
end
function BaseObject:Scale(scale)
	if(not scale)then return; end
	-- visuals
	local objGraph = ParaScene.GetMiniSceneGraph("object_editor");
	local id = tostring(self:GetID());
	local cursorObj = objGraph:GetObject(id);
	if(cursorObj and cursorObj:IsValid())then
		local params = ObjEditor.GetObjectParams(cursorObj)
		scale = params.scaling + scale;
		cursorObj:SetScale(scale);
	else	
		local obj_params = self:GetParams();
		if(obj_params)then
			obj_params = commonlib.deepcopy(self:GetParams());
			obj_params.name = id;
			cursorObj = ObjEditor.CreateObjectByParams(obj_params);
			if(cursorObj and cursorObj:IsValid())then
				objGraph:AddChild(cursorObj);
			end
		end
	end
end
-- rotate input vector3 around a given point.
-- @param ox, oy, oz: around which point to rotate the input. 
-- @param a,b,c: radian around the X, Y, Z axis, such as 0, 1.57, 0
function BaseObject:vec3RotateByPoint(ox, oy, oz, a, b, c)
	local x,y,z = self.params.x,self.params.y,self.params.z;
	NPL.load("(gl)script/ide/math/math3d.lua");
	x,y,z = mathlib.math3d.vec3RotateByPoint(ox, oy, oz, x, y, z, a, b, c);

	local obj = self:GetEntity()
	if(obj)then
		obj:SetPosition(x,y,z);	
		NPL.load("(gl)script/ide/mathlib.lua");
		local q1 = obj:GetRotation({})
		local q2;
		if(a~=0) then
			q2 = mathlib.QuatFromAxisAngle(1, 0, 0, a)
			q1 = mathlib.QuaternionMultiply(q1,q2);
		end
		if(b~=0) then
			q2 = mathlib.QuatFromAxisAngle(0, 1, 0, b)
			q1 = mathlib.QuaternionMultiply(q1,q2);
		end
		if(c~=0) then
			q2 = mathlib.QuatFromAxisAngle(0, 0, 1, c)
			q1 = mathlib.QuaternionMultiply(q1,q2);
		end
		obj:SetRotation(q1)
	end
end
-- it is a absolute value
function BaseObject:SetPosition(x,y,z)
	local obj = self:GetEntity()
	if(obj)then
		obj:SetPosition(x,y,z);	
	end
end
-- it is a absolute value
function BaseObject:SetRotation(x,y,z,w)
	local obj = self:GetEntity()
	if(obj)then
		obj:SetRotation({x = x,y = y,z = z,w = w});	
	end
end
function BaseObject:GetPosition()
	local obj = self:GetEntity()
	if(obj)then
		return obj:GetPosition();	
	end
end
-- it is a absolute value
function BaseObject:SetScale(v)
	local obj = self:GetEntity()
	if(obj)then
		obj:SetScale(v);	
	end
end
-- it is a absolute value
function BaseObject:SetFacing(v)
	if(not v)then return end
	local obj = self:GetEntity()
	if(obj)then
		obj:SetFacing(v);
	end
end
-- it is a absolute value
function BaseObject:SetRotate(point3D)
	if(not point3D)then return end
	local obj = self:GetEntity()
	if(obj)then
		obj:Rotate(point3D.x,point3D.y,point3D.z);	
	end
end
function BaseObject:SetPositionDelta(point3D)
	if(not point3D)then return end
	local obj = self:GetEntity()
	if(obj)then
		local x,y,z = obj:GetPosition();	
		x = x + point3D.x;
		y = y + point3D.y;
		z = z + point3D.z;
		self:SetPosition(x,y,z)
	end
end
function BaseObject:SetRotationDelta(point3D)
	if(not point3D)then return end
	local obj = self:GetEntity()
	if(obj)then
		local x,y,z = obj:GetRotation();	
		x = x + point3D.x;
		y = y + point3D.y;
		z = z + point3D.z;
		w = w + point3D.w;
		self:SetRotation(x,y,z,w)
	end
end
function BaseObject:SetScaleDelta(v)
	if(not v)then return end
	local obj = self:GetEntity()
	if(obj)then
		local s = obj:GetScale();	
		s = s + v;
		self:SetScale(s);
	end
end
function BaseObject:SetRotateDelta(v)
	if(not v)then return end
	local obj = self:GetEntity()
	if(obj)then
		local s = obj:GetRotate();	
		s = s + v;
		self:SetRotate(s);
	end
end
function BaseObject:SetFacingDelta(v)
	if(not v)then return end
	local obj = self:GetEntity()
	if(obj)then
		local s = obj:GetFacing();	
		s = s + v;
		self:SetFacing(s);
	end
end
function BaseObject:SetHomeZone(s)
	local obj = self:GetEntity()
	if(obj)then
		obj:GetAttributeObject():SetField("homezone", s or "");
	end
end
function BaseObject:SetPositionParamsDelta(point3D)
	if(not point3D)then return end
	local params = self:GetParams();
	if(params)then
		local x,y,z = params.x,params.y,params.z;	
		params.x = x + point3D.x;
		params.y = y + point3D.y;
		params.z = z + point3D.z;
	end
end
function BaseObject:SetPositionParams(point3D)
	if(not point3D)then return end
	local params = self:GetParams();
	if(params)then
		local x,y,z = params.x,params.y,params.z;	
		params.x = point3D.x;
		params.y = point3D.y;
		params.z = point3D.z;
	end
end
function BaseObject:SetRotationParamsDelta(point3D)
	if(not point3D)then return end
	local params = self:GetParams();
	if(params  and params.rotation)then
		local x,y,z,w = params.rotation.x,params.rotation.y,params.rotation.z,params.rotation.w;	
		params.rotation.x = x + point3D.x;
		params.rotation.y = y + point3D.y;
		params.rotation.z = z + point3D.z;
		params.rotation.w = w + point3D.w;
	end
end
function BaseObject:SetRotationParams(point3D)
	if(not point3D)then return end
	local params = self:GetParams();
	if(params and params.rotation)then
		params.rotation.x = point3D.x;
		params.rotation.y = point3D.y;
		params.rotation.z = point3D.z;
		params.rotation.w = point3D.w;
	end
end
function BaseObject:SetFacingParams(facing)
	if(not facing)then return end
	local params = self:GetParams();
	if(params)then
		params.facing = facing;
	end
end
-- do nothing
function BaseObject:UpdatePlanesParam(facing)

end