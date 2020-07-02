--[[
Title: CommandCut
Author(s): Leio
Date: 2008/11/24
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/CommandCut.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/CommandDelete.lua");
local CommandCut = commonlib.inherit(Map3DSystem.App.Inventor.CommandDelete,{
});  
commonlib.setfield("Map3DSystem.App.Inventor.CommandCut",CommandCut);

