--[[
Title: CommandDelete
Author(s): Leio
Date: 2008/11/24
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/CommandDelete.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/ICommand.lua");
local CommandDelete = commonlib.inherit(Map3DSystem.App.Inventor.ICommand,{
	cloneList = nil,
});  
commonlib.setfield("Map3DSystem.App.Inventor.CommandDelete",CommandDelete);

function CommandDelete:Initialization(lite3DCanvas)
	if(not lite3DCanvas)then return end;
	self.cloneList = {};
	local k,v;
	local list = lite3DCanvas:GetSelection();
	for k,v in ipairs(list) do
		local node = v;
		table.insert(self.cloneList,node:Clone());
	end
	
end
function CommandDelete:Undo(lite3DCanvas)
	if(not lite3DCanvas or not self.cloneList)then return end;
	lite3DCanvas:UnselectAll();
	local k,v;
	for k,v in ipairs(self.cloneList) do
		local clone_node = v:Clone();
		lite3DCanvas:AddChild(clone_node);
		clone_node:SetSelected(true);
	end
end
function CommandDelete:Redo(lite3DCanvas)
	if(not lite3DCanvas or not self.cloneList)then return end;
	lite3DCanvas:UnselectAll();
	local container = lite3DCanvas:GetContainer();
	local k,v;
	for k,v in ipairs(self.cloneList) do
		container:RemoveChildByUID(v:GetUID());	
	end
end