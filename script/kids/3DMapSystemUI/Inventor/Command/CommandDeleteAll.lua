--[[
Title: CommandDeleteAll
Author(s): Leio
Date: 2008/11/24
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/CommandDeleteAll.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/ICommand.lua");
local CommandDeleteAll = commonlib.inherit(Map3DSystem.App.Inventor.ICommand,{
	cloneList = nil,
});  
commonlib.setfield("Map3DSystem.App.Inventor.CommandDeleteAll",CommandDeleteAll);

function CommandDeleteAll:Initialization(lite3DCanvas)
	if(not lite3DCanvas)then return end;
	self.cloneList = {};
	local k,v;
	for k,v in ipairs(lite3DCanvas.Nodes) do
		local node = v;
		table.insert(self.cloneList,node:Clone());
	end
	
end
function CommandDeleteAll:Undo(lite3DCanvas)
	if(not lite3DCanvas or not self.cloneList)then return end;
	local k,v;
	for k,v in ipairs(self.cloneList) do
		lite3DCanvas:AddNode(v);
	end
end
function CommandDeleteAll:Redo(lite3DCanvas)
	if(not lite3DCanvas or not self.cloneList)then return end;
	lite3DCanvas:Clear();
end