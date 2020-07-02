--[[
Title: PortalCanvas
Author(s): Leio
Date: 2008/12/11
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Creator/PortalCanvas.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Container/LiteCanvas.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Creator/PortalSystemPage.lua");
local PortalCanvas = commonlib.inherit(Map3DSystem.App.Inventor.LiteCanvas,{
	canvasType = "PortalCanvas",
});  
commonlib.setfield("Map3DSystem.App.Creator.PortalCanvas",PortalCanvas);
