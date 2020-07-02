--[[
Title: CommandPaste
Author(s): Leio
Date: 2008/11/24
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/CommandPaste.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/ICommand.lua");
local CommandPaste = commonlib.inherit(Map3DSystem.App.Inventor.ICommand,{
	cloneList = nil,
});  
commonlib.setfield("Map3DSystem.App.Inventor.CommandPaste",CommandPaste);

function CommandPaste:Initialization(lite3DCanvas)
	if(not lite3DCanvas)then return end;
	local copyList = lite3DCanvas:GetCopyList();
	if(not copyList)then return end;
	self.cloneList = {};
	local k,v;
	for k,v in ipairs(copyList) do
		local node = v;
		table.insert(self.cloneList,node:Clone());
	end
end
function CommandPaste:Offset(x,y,z)
	if(not x or not y or not z or not self.cloneList)then return end;
	local k,v;
	for k,v in ipairs(self.cloneList) do
		local node = v;
		if(node)then
			node:SetPositionDelta(x,y,z);
		end
	end
end
function CommandPaste:Undo(lite3DCanvas)
	if(not lite3DCanvas or not self.cloneList)then return end;
	local container = lite3DCanvas:GetContainer();
	local k,v;
	for k,v in ipairs(self.cloneList) do
		local node = v;
		if(node)then
			container:RemoveChildByUID(node:GetUID());	
		end
	end
end
function CommandPaste:Redo(lite3DCanvas)
	if(not lite3DCanvas or not self.cloneList)then return end;
	lite3DCanvas:UnselectAll();
	local k,v;
	for k,v in ipairs(self.cloneList) do
		local clone_node = v:Clone();
		lite3DCanvas:AddChild(clone_node);
		clone_node:SetSelected(true);
	end
end