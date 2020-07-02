--[[
Title: LinearMovieKeyFrame
Author(s): Leio
Date: 2008/12/2
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/LinearMovieKeyFrame.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/Animation/Motion/KeyFrames/TargetAnimationUsingKeyFrames.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Entity/BaseObject.lua");
--local LinearMovieKeyFrame = commonlib.multi_inherit(CommonCtrl.Animation.Motion.LinearTargetKeyFrame,Map3DSystem.App.Inventor.BaseObject)
--commonlib.setfield("Map3DSystem.App.Inventor.LinearMovieKeyFrame",LinearMovieKeyFrame);   
local LinearMovieKeyFramePool = {};
commonlib.setfield("Map3DSystem.App.Inventor.LinearMovieKeyFramePool",LinearMovieKeyFramePool); 

local KeyFrameAndEntityPool = {};
commonlib.setfield("Map3DSystem.App.Inventor.KeyFrameAndEntityPool",KeyFrameAndEntityPool); 

local LinearMovieKeyFrame = commonlib.inherit(Map3DSystem.App.Inventor.BaseObject,{
	parentProperty = "LinearKeyFrame",
	property = "LinearTargetKeyFrame",
	name = "LinearTargetKeyFrame_instance",
	mcmlTitle = "pe:linearTargetKeyFrame",
	SimpleEase = 0,
});
commonlib.setfield("Map3DSystem.App.Inventor.LinearMovieKeyFrame",LinearMovieKeyFrame); 
function LinearMovieKeyFrame:InitKeyFrame(timeLineName,keyFrame)
	if(not keyFrame)then
		keyFrame = CommonCtrl.Animation.Motion.LinearTargetKeyFrame:new();
	end
	LinearMovieKeyFramePool[self:GetID()] = keyFrame;
	self.name = self:GetID();
	keyFrame.name = self:GetID();
	
	self:SetTimeLineName(timeLineName)
end
function LinearMovieKeyFrame:SetTimeLineName(timeLineName)
	self.timeLineName = timeLineName;
end
function LinearMovieKeyFrame:GetRef()
	local id = self:GetID();
	return Map3DSystem.App.Inventor.LinearMovieKeyFramePool[id];
end
function LinearMovieKeyFrame:ChangeKeyFrame()
	local keyFrame = self:GetRef();
	keyFrame:SetValue(self:GetValue());
	keyFrame:SetKeyTime(self:GetKeyTime());
	keyFrame.SimpleEase = self.SimpleEase;
end
-------------------------------------------------------------
-- override method of parent
-------------------------------------------------------------
function LinearMovieKeyFrame:UpdateTargetParams()
	local keyFrame = self:GetRef()
	if(not keyFrame)then return; end
	local target = keyFrame:GetValue();
	local params = self:GetParams();
	if(params)then
		target:GetDefaultProperty(params);
		target:Update()
	end
end
function LinearMovieKeyFrame:ResetPosition()
	local objGraph = ParaScene.GetMiniSceneGraph("object_editor");
	local parent = self:GetParent();
	local cursorObj = objGraph:GetObject(parent.TargetName);
	if(cursorObj:IsValid()) then
		local old_obj_params = self:GetParams();
		local obj_params = ObjEditor.GetObjectParams(cursorObj)
			if( not commonlib.partialcompare(obj_params.x, old_obj_params.x, Map3DSystem.App.Inventor.GlobalInventor.minDistance) or
				not commonlib.partialcompare(obj_params.y, old_obj_params.y, Map3DSystem.App.Inventor.GlobalInventor.minDistance) or
				not commonlib.partialcompare(obj_params.z, old_obj_params.z, Map3DSystem.App.Inventor.GlobalInventor.minDistance) ) then
				--local __,child;
				--for __,child in ipairs(parent.keyframes) do
					--local child_obj_params = child:GetParams();
					--Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeleteObject, obj_params=child_obj_params});
						--
				--end
				--Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_CreateObject, obj_params=obj_params,effect = "boundingbox"});
				----Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_ModifyObject, obj_params=obj_params,effect = "boundingbox"});
				self:SetParams(obj_params);
				
				self:UpdateTargetParams();	
			end				
		
			--visuals	
			objGraph:DestroyObject(parent.TargetName);			
	end
	
end
function LinearMovieKeyFrame:ResetRotation()
	local objGraph = ParaScene.GetMiniSceneGraph("object_editor");
	local parent = self:GetParent();
	local cursorObj = objGraph:GetObject(parent.TargetName);
	if(cursorObj:IsValid()) then
		local old_obj_params = self:GetParams();
		local obj_params = ObjEditor.GetObjectParams(cursorObj)
			-- delete object in clipboard and create object in clipboard at the new location, if and only if any property changes	
			if( not commonlib.partialcompare(obj_params.rotation.x, old_obj_params.rotation.x, Map3DSystem.App.Inventor.GlobalInventor.minDistance) or
				not commonlib.partialcompare(obj_params.rotation.y, old_obj_params.rotation.y, Map3DSystem.App.Inventor.GlobalInventor.minDistance) or
				not commonlib.partialcompare(obj_params.rotation.z, old_obj_params.rotation.z, Map3DSystem.App.Inventor.GlobalInventor.minDistance) ) then
				
				Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeleteObject, obj_params=old_obj_params});
				Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_CreateObject, obj_params=obj_params,effect = "boundingbox"});
				
				
				self:SetParams(obj_params);
			end				
		
			--visuals	
			objGraph:DestroyObject(parent.TargetName);		
	end
	self:UpdateTargetParams();
end
function LinearMovieKeyFrame:ResetScale()
	local objGraph = ParaScene.GetMiniSceneGraph("object_editor");
	local parent = self:GetParent();
	local cursorObj = objGraph:GetObject(parent.TargetName);
	if(cursorObj:IsValid()) then
		local old_obj_params = self:GetParams();
		local obj_params = ObjEditor.GetObjectParams(cursorObj)
		
			-- delete object in clipboard and create object in clipboard at the new location, if and only if any property changes	
			if( not commonlib.partialcompare(obj_params.scaling, old_obj_params.scaling, Map3DSystem.App.Inventor.GlobalInventor.minDistance)) then
				
				Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeleteObject, obj_params=old_obj_params});
				Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_CreateObject, obj_params=obj_params,effect = "boundingbox"});
				
				
				self:SetParams(obj_params);
			end				
		
			--visuals	
			objGraph:DestroyObject(parent.TargetName);	
					
	end
	self:UpdateTargetParams();
end
function LinearMovieKeyFrame:Clone(id)
	local clone_node = commonlib.deepcopy(self);
	local keyFrame = self:GetRef()
	if(not keyFrame)then return; end
	local new_keyFrame = commonlib.deepcopy(keyFrame);
	if(id)then
		LinearMovieKeyFramePool[id] = new_keyFrame;
		new_keyFrame.name = id;
		clone_node:SetID(id);
	end
	return clone_node;
end
function LinearMovieKeyFrame:HitTestObject(startPoint,lastPoint)
	if(not startPoint or not lastPoint)then return end
	local left, top, right, bottom = startPoint.x,startPoint.y,lastPoint.x,lastPoint.y;
	if(not left or not top or not right or not bottom)then return end
	local result = {};
	if( not commonlib.partialcompare(left, right, Map3DSystem.App.Inventor.GlobalInventor.minDistance) or
			not commonlib.partialcompare(top, bottom, Map3DSystem.App.Inventor.GlobalInventor.minDistance)) then				
			ParaScene.GetObjectsByScreenRect(result, left, top, right, bottom, "anyobject", -1);
	end
	if(#result > 0)then
		local __,obj;
		for __,obj in ipairs(result) do
			local parent = self:GetParent();
			if(parent)then
				if(parent.TargetName == obj.name)then
					local timeLine = CommonCtrl.GetControl(self.timeLineName);
					if(timeLine)then						
						local curframe = parent:getCurrentKeyframe(timeLine:GetFrame());
						if(curframe and curframe:GetID() == self:GetID())then
							return true;
						end
					end
				end
			end
		end		
	end
end
function LinearMovieKeyFrame:HitTest(point)
	local obj = ParaScene.MousePick(40, "anyobject");
	if(obj:IsValid()) then
		local parent = self:GetParent();
		if(parent)then
			if(parent.TargetName == obj.name)then
				local timeLine = CommonCtrl.GetControl(self.timeLineName);
				if(timeLine)then						
					local curframe = parent:getCurrentKeyframe(timeLine:GetFrame());					
					if(curframe and curframe:GetID() == self:GetID())then
						--commonlib.echo({curframe.KeyTime,timeLine:GetFrame(),curframe:GetID(),self:GetID(),self.KeyTime});
						return 0;
					end
				end
			end
		end
	end
	return -1;
end
function LinearMovieKeyFrame:Move(point3D)
	if(not point3D)then return; end
	-- visuals
	local objGraph = ParaScene.GetMiniSceneGraph("object_editor");
	local parent = self:GetParent();
	local cursorObj = objGraph:GetObject(parent.TargetName);
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
			obj_params.name = parent.TargetName;
			cursorObj = ObjEditor.CreateObjectByParams(obj_params);
			if(cursorObj and cursorObj:IsValid())then
				objGraph:AddChild(cursorObj);
			end
		end
	end
end
-------------------------------------------------------------
-- implement interface of LinearTargetKeyFrame
-------------------------------------------------------------
function LinearMovieKeyFrame:SetParent(v)
	local keyFrame = self:GetRef()
	if(not keyFrame)then return; end
	keyFrame:SetParent(v)
end
function LinearMovieKeyFrame:GetParent()
	local keyFrame = self:GetRef()
	if(not keyFrame)then return; end
	return keyFrame:GetParent();
end
function LinearMovieKeyFrame:SetActivate(v)
	local keyFrame = self:GetRef()
	if(not keyFrame)then return; end
	keyFrame:SetActivate(v)
end
function LinearMovieKeyFrame:GetActivate(v)
	local keyFrame = self:GetRef()
	if(not keyFrame)then return; end
	return keyFrame:GetActivate(v)
end
function LinearMovieKeyFrame:SetValue(v)
	local keyFrame = self:GetRef()
	if(not keyFrame)then return; end
	keyFrame:SetValue(v)
end
function LinearMovieKeyFrame:GetValue()
	local keyFrame = self:GetRef()
	if(not keyFrame)then return; end
	return keyFrame:GetValue()
end
function LinearMovieKeyFrame:SetKeyTime(v)
	if(not v)then return; end
	local keyFrame = self:GetRef()
	if(not keyFrame)then return; end
	keyFrame:SetKeyTime(v)
	self.KeyTime = v;
	self.ToFrame = self:GetFrames();
end
function LinearMovieKeyFrame:SetKeyFrame(v)
	if(not v)then return; end	
	local keyFrame = self:GetRef()
	if(not keyFrame)then return; end
	keyFrame:SetKeyFrame(v)
	self.ToFrame = v;
	self.KeyTime = CommonCtrl.Animation.Motion.TimeSpan.GetTime(v);
end
function LinearMovieKeyFrame:GetKeyFrame()
	local keyFrame = self:GetRef()
	if(not keyFrame)then return; end
	return keyFrame:GetKeyFrame()
end
function LinearMovieKeyFrame:GetKeyTime()
	local keyFrame = self:GetRef()
	if(not keyFrame)then return; end
	return keyFrame:GetKeyTime()
end
function LinearMovieKeyFrame:GetFrames()
	local keyFrame = self:GetRef()
	if(not keyFrame)then return; end
	return keyFrame:GetFrames()
end

function LinearMovieKeyFrame:ReverseToMcml()
	local keyFrame = self:GetRef()
	if(not keyFrame)then return; end
	return keyFrame:ReverseToMcml();
end   