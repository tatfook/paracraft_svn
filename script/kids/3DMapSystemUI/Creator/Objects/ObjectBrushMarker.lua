--[[
Title: ObjectBrushMarker
Author(s): LiXizhi
Date: 2009/1/28
Desc: miniscenegraph for rendering Object brush. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Creator/Objects/ObjectBrushMarker.lua");
local ObjectBrushMarker = Map3DSystem.App.Creator.ObjectBrushMarker;
ObjectBrushMarker.DrawBrush({x,z,radius});
ObjectBrushMarker.Clear()
------------------------------------------------------------
]]

local ObjectBrushMarker = {};
commonlib.setfield("Map3DSystem.App.Creator.ObjectBrushMarker", ObjectBrushMarker)

ObjectBrushMarker.Assets = {
	["center"] = "model/common/editor/z.x",
	["point"] = "model/common/editor/scalebox.x",
}
-- how many point to draw for the circle 
ObjectBrushMarker.CirclePointCount = 12;
ObjectBrushMarker.MinCirclePointCount = 12;
ObjectBrushMarker.MaxCirclePointCount = 36;
-- distance between markers in meters
ObjectBrushMarker.MakerSpacing = 1.0;

local brush = {
	x=nil,
	y=nil,
	z=nil,
	radius=nil,
}
-- called to init page
-- @param brush: {x,z,radius}, all fields are optional. it will partial copy to brush struct
function ObjectBrushMarker.DrawBrush(newBrush)
	commonlib.partialcopy(brush, newBrush);
	
	local miniscene = ParaScene.GetMiniSceneGraph("ObjectBrushMarker");
	miniscene:SetVisible(true);
	if(brush.x and brush.z and brush.radius) then
		local y = ParaObject.GetElevation(brush.x, brush.z)
		local obj = miniscene:GetObject("center");
		if(obj:IsValid() == false) then
			local _asset = ParaAsset.LoadStaticMesh("", ObjectBrushMarker.Assets["center"]);
			obj = ParaScene.CreateMeshPhysicsObject("center", _asset, 1,1,1,false, "1,0,0,0,1,0,0,0,1,0,0,0");
			obj:SetFacing(0);
			obj:GetAttributeObject():SetField("progress", 1);
			obj:SetPosition(brush.x, y, brush.z);
			miniscene:AddChild(obj);
		else
			obj:SetPosition(brush.x, y, brush.z);
		end
		
		-- automatically determine how many maker to use. 
		local markerCount = math.floor(brush.radius*6.28/ObjectBrushMarker.MakerSpacing)
		if(markerCount>ObjectBrushMarker.MaxCirclePointCount) then
			markerCount = ObjectBrushMarker.MaxCirclePointCount
		elseif(markerCount<ObjectBrushMarker.MinCirclePointCount) then
			markerCount = ObjectBrushMarker.MinCirclePointCount
		end	
		ObjectBrushMarker.CirclePointCount = markerCount;
		
		local i;
		local _asset;
		for i=1,ObjectBrushMarker.CirclePointCount do
			local angle = (i/ObjectBrushMarker.CirclePointCount)*6.28;
			local x = brush.x + brush.radius * math.sin(angle);
			local z = brush.z + brush.radius * math.cos(angle);
			local y = ParaObject.GetElevation(x, z)
			
			local obj = miniscene:GetObject(tostring(i));
			if(obj:IsValid() == false) then
				_asset = _asset or ParaAsset.LoadStaticMesh("", ObjectBrushMarker.Assets["point"]);
				obj = ParaScene.CreateMeshPhysicsObject(tostring(i), _asset, 1,1,1,false, "1,0,0,0,1,0,0,0,1,0,0,0");
				obj:SetFacing(0);
				obj:GetAttributeObject():SetField("progress", 1);
				obj:SetPosition(x, y, z);
				miniscene:AddChild(obj);
			else
				obj:SetVisible(true);
				obj:SetPosition(x, y, z);
			end
		end
		if(ObjectBrushMarker.CirclePointCount < ObjectBrushMarker.MaxCirclePointCount ) then
			for i=ObjectBrushMarker.CirclePointCount+1,ObjectBrushMarker.MaxCirclePointCount do
				local obj = miniscene:GetObject(tostring(i));
				if(obj:IsValid()) then
					obj:SetVisible(false);
				else
					break;
				end
			end
		end
	end	
end

-- brush line and circle from (x1,z1) to (x,z)
function ObjectBrushMarker.DrawRamp(brush)
	local miniscene = ParaScene.GetMiniSceneGraph("ObjectBrushMarker");
	miniscene:SetVisible(true);
	if(brush.x1 and brush.z1 and brush.x and brush.z and brush.radius) then
		local y = ParaObject.GetElevation(brush.x, brush.z)
		local obj = miniscene:GetObject("center");
		if(obj:IsValid() == false) then
			local _asset = ParaAsset.LoadStaticMesh("", ObjectBrushMarker.Assets["center"]);
			obj = ParaScene.CreateMeshPhysicsObject("center", _asset, 1,1,1,false, "1,0,0,0,1,0,0,0,1,0,0,0");
			obj:SetFacing(0);
			obj:GetAttributeObject():SetField("progress", 1);
			obj:SetPosition(brush.x, y, brush.z);
			miniscene:AddChild(obj);
		else
			obj:SetPosition(brush.x, y, brush.z);
		end
		
		-- automatically determine how many maker to use. 
		local markerCount = math.floor(brush.radius*6.28/ObjectBrushMarker.MakerSpacing)
		if(markerCount>ObjectBrushMarker.MaxCirclePointCount/2) then
			markerCount = ObjectBrushMarker.MaxCirclePointCount/2
		elseif(markerCount<ObjectBrushMarker.MinCirclePointCount) then
			markerCount = ObjectBrushMarker.MinCirclePointCount
		end	
		ObjectBrushMarker.CirclePointCount = markerCount;
		
		local i;
		local _asset;
		for i=1,markerCount do
			local angle = (i/markerCount)*6.28;
			local x = brush.x + brush.radius * math.sin(angle);
			local z = brush.z + brush.radius * math.cos(angle);
			local y = ParaObject.GetElevation(x, z)
			
			local obj = miniscene:GetObject(tostring(i));
			if(obj:IsValid() == false) then
				_asset = _asset or ParaAsset.LoadStaticMesh("", ObjectBrushMarker.Assets["point"]);
				obj = ParaScene.CreateMeshPhysicsObject(tostring(i), _asset, 1,1,1,false, "1,0,0,0,1,0,0,0,1,0,0,0");
				obj:SetFacing(0);
				obj:GetAttributeObject():SetField("progress", 1);
				obj:SetPosition(x, y, z);
				miniscene:AddChild(obj);
			else
				obj:SetVisible(true);
				obj:SetPosition(x, y, z);
			end
		end
		if(ObjectBrushMarker.CirclePointCount < ObjectBrushMarker.MaxCirclePointCount ) then
			if(brush.x1~=brush.x or brush.z1~=brush.z) then
				-- now draw a line
				local lineLength = math.sqrt((brush.x1-brush.x)*(brush.x1-brush.x)+(brush.z1-brush.z)*(brush.z1-brush.z))
				
				local markerLeftCount = ObjectBrushMarker.MaxCirclePointCount - ObjectBrushMarker.CirclePointCount-1;
				local markerCount = math.floor(lineLength/ObjectBrushMarker.MakerSpacing)
				if(markerCount>markerLeftCount) then
					markerCount = markerLeftCount
				end	
				for i=1,markerCount do
					local k = (i-1)/markerCount;
					local x = brush.x1 + (brush.x-brush.x1) * k;
					local z = brush.z1 + (brush.z-brush.z1) * k;
					local y = ParaObject.GetElevation(x, z)
			
					local objname = tostring(i+ObjectBrushMarker.CirclePointCount);
					local obj = miniscene:GetObject(objname);
					if(obj:IsValid() == false) then
						_asset = _asset or ParaAsset.LoadStaticMesh("", ObjectBrushMarker.Assets["point"]);
						obj = ParaScene.CreateMeshPhysicsObject(objname, _asset, 1,1,1,false, "1,0,0,0,1,0,0,0,1,0,0,0");
						obj:SetFacing(0);
						obj:GetAttributeObject():SetField("progress", 1);
						obj:SetPosition(x, y, z);
						miniscene:AddChild(obj);
					else
						obj:SetVisible(true);
						obj:SetPosition(x, y, z);
					end
				end
				ObjectBrushMarker.CirclePointCount = ObjectBrushMarker.CirclePointCount + markerCount;
			end
			
			-- make remaining invisible
			for i=ObjectBrushMarker.CirclePointCount+1,ObjectBrushMarker.MaxCirclePointCount do
				local obj = miniscene:GetObject(tostring(i));
				if(obj:IsValid()) then
					obj:SetVisible(false);
				else
					break;
				end
			end
		end
	else
		ObjectBrushMarker.DrawBrush(brush);
	end	
end

-- clear everything. 
function ObjectBrushMarker.Clear()
	local miniscene = ParaScene.GetMiniSceneGraph("ObjectBrushMarker");
	miniscene:SetVisible(false);
end

