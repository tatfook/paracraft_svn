--[[
Title: SceneNode 
Author(s): leio
Date: 2021/1/7
Desc: 
use the lib:
------------------------------------------------------------
local SceneNode = NPL.load("(gl)script/apps/Aries/Creator/Tasks/VisualScene/SceneNode.lua");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/System/Core/ToolBase.lua");
local SceneNode = commonlib.inherit(commonlib.gettable("System.Core.ToolBase"), NPL.export());