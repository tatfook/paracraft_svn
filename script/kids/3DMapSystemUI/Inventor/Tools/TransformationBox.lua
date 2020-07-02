--[[
Title: TransformationBox
Author(s): Leio
Date: 2008/12/8
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Tools/TransformationBox.lua");
local box = Map3DSystem.App.Inventor.TransformationBox:new();
box:Show();
------------------------------------------------------------
]]
local TransformationBox = {
	name = nil,
	assets = {
	transplane_x = "model/common/editor/x.x",
	transplane_y = "model/common/editor/y.x",
	transplane_z = "model/common/editor/z.x",
	rotation = "model/common/editor/rotation.x",
	transplane = "model/common/editor/transplane.x",
	scalebox = "model/common/editor/scalebox.x",
	},
	position = {255,1,255},
	scale = 0.5,
} 
commonlib.setfield("Map3DSystem.App.Inventor.TransformationBox",TransformationBox);
function TransformationBox:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	
	o:Initialization(o.name)
	return o
end
function TransformationBox:Initialization(name)
	if(not name)then
		self.name = ParaGlobal.GenerateUniqueID();
	else
		self.name = name;
	end
	local scaleBoxes ={}
	scaleBoxes[1] = {-1,1,1};
	scaleBoxes[2] = {1,1,1};
	scaleBoxes[3] = {1,-1,1};
	scaleBoxes[4] = {-1,-1,1};
	scaleBoxes[5] = {-1,1,-1};
	scaleBoxes[6] = {1,1,-1};
	scaleBoxes[7] = {1,-1,-1};
	scaleBoxes[8] = {-1,-1,-1};
	self.scaleBoxes = scaleBoxes;
	
	self.rotation_y = {0,2.5,0};
	self.transplane_x = {0,0,0};
	self.transplane_y = {0,0,0};
	self.transplane_z = {0,0,0};
	self.transplane = {0,0,0};
end
function TransformationBox:Clear()
	local objGraph = ParaScene.GetMiniSceneGraph(self.name);
	objGraph:Reset();
end
function TransformationBox:Show()
	self:Clear();
	local k = 1;
	local objGraph = ParaScene.GetMiniSceneGraph(self.name);	
	-- scale box
	for k = 1,8 do
		local _assetName = self.assets["scalebox"];
		local _asset = ParaAsset.LoadStaticMesh("", _assetName);
		obj = ParaScene.CreateMeshPhysicsObject("scalebox"..k, _asset, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
		if(obj:IsValid()) then
			local pos = self.scaleBoxes[k];
			local x = pos[1]*self.scale + self.position[1];
			local y = pos[2]*self.scale + self.position[2];
			local z = pos[3]*self.scale + self.position[3];
			obj:SetPosition(x,y,z);
			objGraph:AddChild(obj);
		end
	end
	-- transplane
	local _assetName = self.assets["transplane"];
	local _asset = ParaAsset.LoadStaticMesh("", _assetName);
	obj = ParaScene.CreateMeshPhysicsObject("transplane", _asset, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
	if(obj:IsValid()) then
		local pos = self.transplane;
		local x = pos[1]*self.scale + self.position[1];
		local y = pos[2]*self.scale + self.position[2];
		local z = pos[3]*self.scale + self.position[3];
		obj:SetPosition(x,y,z);
		objGraph:AddChild(obj);
	end
	-- transplane_x
	local _assetName = self.assets["transplane_x"];
	local _asset = ParaAsset.LoadStaticMesh("", _assetName);
	obj = ParaScene.CreateMeshPhysicsObject("transplane_x", _asset, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
	if(obj:IsValid()) then
		local pos = self.transplane_x;
		local x = pos[1]*self.scale + self.position[1];
		local y = pos[2]*self.scale + self.position[2];
		local z = pos[3]*self.scale + self.position[3];
		obj:SetPosition(x,y,z);
		objGraph:AddChild(obj);
	end
	-- transplane_y
	local _assetName = self.assets["transplane_y"];
	local _asset = ParaAsset.LoadStaticMesh("", _assetName);
	obj = ParaScene.CreateMeshPhysicsObject("transplane_y", _asset, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
	if(obj:IsValid()) then
		local pos = self.transplane_y;
		local x = pos[1]*self.scale + self.position[1];
		local y = pos[2]*self.scale + self.position[2];
		local z = pos[3]*self.scale + self.position[3];
		obj:SetPosition(x,y,z);
		objGraph:AddChild(obj);
	end
	-- transplane_z
	local _assetName = self.assets["transplane_z"];
	local _asset = ParaAsset.LoadStaticMesh("", _assetName);
	obj = ParaScene.CreateMeshPhysicsObject("transplane_z", _asset, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
	if(obj:IsValid()) then
		local pos = self.transplane_z;
		local x = pos[1]*self.scale + self.position[1];
		local y = pos[2]*self.scale + self.position[2];
		local z = pos[3]*self.scale + self.position[3];
		obj:SetPosition(x,y,z);
		objGraph:AddChild(obj);
	end
	-- rotation_y
	local _assetName = self.assets["rotation"];
	local _asset = ParaAsset.LoadStaticMesh("", _assetName);
	obj = ParaScene.CreateMeshPhysicsObject("rotation_y", _asset, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
	if(obj:IsValid()) then
		local pos = self.rotation_y;
		local x = pos[1]*self.scale + self.position[1];
		local y = pos[2]*self.scale + self.position[2];
		local z = pos[3]*self.scale + self.position[3];
		obj:SetPosition(x,y,z);
		objGraph:AddChild(obj);
	end
end
function TransformationBox:SetPosition(point3D)
	self.position = point3D;
	self:Show();
end
function TransformationBox:GetPosition()
	return self.position;
end