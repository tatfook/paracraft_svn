--[[
Title: CommandCopy
Author(s): Leio
Date: 2008/11/24
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/CommandCopy.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/ICommand.lua");
local CommandCopy = commonlib.inherit(Map3DSystem.App.Inventor.ICommand,{

});  
commonlib.setfield("Map3DSystem.App.Inventor.CommandCopy",CommandCopy);

function CommandCopy:Initialization(lite3DCanvas)
	if(not lite3DCanvas)then return end;
	lite3DCanvas:CopySelection();
end
function CommandCopy:Undo(lite3DCanvas)
	
end
function CommandCopy:Redo(lite3DCanvas)
	
end