--[[
Title: camera of the map system for both the 2D and 3D
Author(s): SunLingFeng
Date: 2007/10/10
Revised: 2007/11/3 By LiXizhi (comments)
Use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppVirtualCamera.lua");
Map3DSystem.Map.virtualCamera:new({name="my cam"})
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppCommon.lua");

local virtualCamera = {
	name = "cam1",
	-- Camera look at position, i.e. range [0,1]
	viewPosX = 0.5,
	viewPosY = 0.5,
	viewPosZ = 0,
	
	viewRegion = 0,
	-- field of view
	fov = math.pi/6,
}
Map3DApp.VirtualCamera = virtualCamera;


function virtualCamera:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;
end

function virtualCamera:SetViewPosition(x,y,z)
	self.viewPosX = x;
	self.viewPosY = y;
	self.viewPosZ = z;
end

function virtualCamera:GetViewPosition(x,y)
	return self.viewPosX,self.viewPosY;
end

function virtualCamera:SetViewRegion()
	self.viewRegion = viewRegion;
end

function virtualCamera:GetViewRegion()
	return self.viewRegion;
end