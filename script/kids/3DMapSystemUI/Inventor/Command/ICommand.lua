--[[
Title: ICommand
Author(s): Leio
Date: 2008/11/24
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/ICommand.lua");
------------------------------------------------------------
]]
local ICommand = {
} 
commonlib.setfield("Map3DSystem.App.Inventor.ICommand",ICommand);
function ICommand:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	
	--o:Initialization()
	return o
end
function ICommand:Initialization()
	--self.name = ParaGlobal.GenerateUniqueID();
end
function ICommand:Undo(lite3DCanvas)

end
function ICommand:Redo(lite3DCanvas)

end