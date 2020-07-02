--[[
Title: ObjectBrush
Author(s): LiXizhi
Date: 2009/1/31
Desc: Object form brush data structure only. Keeping the dafault brush settings. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Creator/Objects/ObjectBrush.lua");
brush = Map3DSystem.App.Creator.ObjectBrush:new({})
-- well known brushes
brush = Map3DSystem.App.Creator.ObjectBrush.Brushes["GaussionHill"]
brush = Map3DSystem.App.Creator.ObjectBrush.Brushes["Flatten"]
brush = Map3DSystem.App.Creator.ObjectBrush.Brushes["RadialScale"]
brush = Map3DSystem.App.Creator.ObjectBrush.Brushes["Roughen_Smooth"]
brush = Map3DSystem.App.Creator.ObjectBrush.Brushes["SetHole"]
brush = Map3DSystem.App.Creator.ObjectBrush.Brushes["Ramp"]
------------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemUI/Creator/Objects/ObjectBrushMarker.lua");
local ObjectBrushMarker = Map3DSystem.App.Creator.ObjectBrushMarker;

local ObjectBrush = {
	filtername = nil,
	BrushSize = 10, 
	BrushStrength = 0.1,
	BrushSoftness = 0.5,
	
	FlattenOperation = 2,
	Elevation = 0,
	gaussian_deviation = 0.9,
	HeightScale = 3,
};
commonlib.setfield("Map3DSystem.App.Creator.ObjectBrush", ObjectBrush)

function ObjectBrush:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- refresh the Object marker
function ObjectBrush:RefreshMarker()
	if(self.filtername ~= nil) then
		ObjectBrushMarker.DrawBrush({x=self.x,y=self.y,z=self.z,radius=self.BrushSize});
	end	
end

-- clear the Object marker
function ObjectBrush:ClearMarker()
	ObjectBrushMarker.Clear();
end

-- some known brushes
ObjectBrush.Brushes= {
	["GaussionHill"] = ObjectBrush:new({
			filtername = "GaussianHill",
			BrushSize = 10, 
			BrushStrength = 0.1,
			BrushSoftness = 0.5,
			gaussian_deviation = 0.9,
			HeightScale = 3,
		}),
	["Flatten"] = ObjectBrush:new({
			filtername = "Flatten",
			BrushSize = 5, 
			BrushStrength = 0.1,
			BrushSoftness = 0.5,
			
			FlattenOperation = 2,
			Elevation = 0,
		}),
	["Roughen_Smooth"] = ObjectBrush:new({
			filtername = "Roughen_Smooth",
			BrushSize = 4, 
			BrushStrength = 0.1,
			BrushSoftness = 0.5,
		}),
	["RadialScale"] = ObjectBrush:new({
			filtername = "RadialScale",
			BrushSize = 20, 
			BrushStrength = 0.1,
			BrushSoftness = 0.5,
			HeightScale = 3,
		}),
	["SetHole"] = ObjectBrush:new({
			filtername = "SetHole",
			BrushSize = 2, 
			BrushStrength = 0.1,
			BrushSoftness = 0.5,
		}),
	["Ramp"] = ObjectBrush:new({
			filtername = "SetHole",
			filtername = "Ramp",
			BrushSize = 5, 
			BrushStrength = 0.3,
			BrushSoftness = 0.1,
		}),	
}

-- overwrite the marker function
function ObjectBrush.Brushes.Ramp:RefreshMarker()
	if(self.filtername ~= nil) then
		ObjectBrushMarker.DrawRamp({x1=self.x1,z1=self.z1,x=self.x,z=self.z,radius=self.BrushSize});
	end	
end