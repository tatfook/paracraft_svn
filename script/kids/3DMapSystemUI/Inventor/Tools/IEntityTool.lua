--[[
Title: IEntityTool
Author(s): Leio
Date: 2008/11/24
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Tools/IEntityTool.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Tools/ITool.lua");
local IEntityTool = commonlib.inherit(Map3DSystem.App.Inventor.ITool,{
});  
commonlib.setfield("Map3DSystem.App.Inventor.IEntityTool",IEntityTool);

function IEntityTool:SetPressedNode(node)
	self.pressedNode = node;
end
function IEntityTool:GetPressedNode()
	return self.pressedNode;
end
