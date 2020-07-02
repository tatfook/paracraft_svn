--[[
Title: CommandAdd
Author(s): Leio
Date: 2008/11/24
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/CommandAdd.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/ICommand.lua");
local CommandAdd = commonlib.inherit(Map3DSystem.App.Inventor.ICommand,{
	baseObject = nil,
});  
commonlib.setfield("Map3DSystem.App.Inventor.CommandAdd",CommandAdd);

function CommandAdd:Initialization(baseObject)
	if(not baseObject)then return end;
	self.baseObject = baseObject:Clone();
end
function CommandAdd:Undo(lite3DCanvas)
	if(not lite3DCanvas or not self.baseObject)then return end;
	lite3DCanvas:DeleteLastAddedObject();
end
function CommandAdd:Redo(lite3DCanvas)
	if(not lite3DCanvas or not self.baseObject)then return end;
	lite3DCanvas:UnselectAll();
	local clone_node = self.baseObject:Clone()
	lite3DCanvas:AddChild(clone_node);
	clone_node:SetSelected(true);
end