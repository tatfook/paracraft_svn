--[[
Title: ITool
Author(s): Leio
Date: 2008/11/24
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Tools/ITool.lua");
------------------------------------------------------------
]]
local ITool = {
} 
commonlib.setfield("Map3DSystem.App.Inventor.ITool",ITool);
function ITool:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	
	o:Initialization()
	return o
end
function ITool:Initialization()
	--self.name = ParaGlobal.GenerateUniqueID();
end
function ITool:OnLeftMouseDown(lite3DCanvas,msg)
end
function ITool:OnMouseMove(lite3DCanvas,msg)
end
function ITool:OnLeftMouseUp(lite3DCanvas,msg)
end
function ITool:OnRightMouseDown(lite3DCanvas,msg)
end
function ITool:OnRightMouseUp(lite3DCanvas,msg)
end
