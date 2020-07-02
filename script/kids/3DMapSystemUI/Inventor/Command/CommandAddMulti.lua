--[[
Title: CommandAddMulti
Author(s): Leio
Date: 2008/11/24
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/CommandAddMulti.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/ICommand.lua");
local CommandAddMulti = commonlib.inherit(Map3DSystem.App.Inventor.ICommand,{
	cloneList = nil,
});  
commonlib.setfield("Map3DSystem.App.Inventor.CommandAddMulti",CommandAddMulti);

function CommandAddMulti:Initialization(list)
	if(not list)then return end;
	self.cloneList = {};
	local k,v;
	for k,v in ipairs(list) do
		local node = v;
		table.insert(self.cloneList,node:Clone());
	end
end
function CommandAddMulti:Undo(lite3DCanvas)
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
function CommandAddMulti:Redo(lite3DCanvas)
	if(not lite3DCanvas or not self.cloneList)then return end;
	lite3DCanvas:UnselectAll();
	local k,v;
	for k,v in ipairs(self.cloneList) do
		local clone_node = v:Clone();
		lite3DCanvas:AddChild(clone_node);
		clone_node:SetSelected(true);
	end
end