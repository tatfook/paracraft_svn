--[[
Title: CommandChangeState
Author(s): Leio
Date: 2008/11/24
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/CommandChangeState.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/ICommand.lua");
local CommandChangeState = commonlib.inherit(Map3DSystem.App.Inventor.ICommand,{
	listBefore = nil,
	listAfter = nil,
});  
commonlib.setfield("Map3DSystem.App.Inventor.CommandChangeState",CommandChangeState);

function CommandChangeState:Initialization(lite3DCanvas)
	if(not lite3DCanvas)then return end;
	self.listBefore = {};
	self:FillList(lite3DCanvas,self.listBefore);		
end
function CommandChangeState:NewState(lite3DCanvas)
	if(not lite3DCanvas)then return end;
	self.listAfter = {};
	self:FillList(lite3DCanvas,self.listAfter);
end
function CommandChangeState:Undo(lite3DCanvas)
	 self:ReplaceObjects(lite3DCanvas, self.listBefore);
end
function CommandChangeState:Redo(lite3DCanvas)
	 self:ReplaceObjects(lite3DCanvas, self.listAfter);
end
function CommandChangeState:ReplaceObjects(lite3DCanvas,list)
	if(not lite3DCanvas or not list)then return end;
	local container = lite3DCanvas:GetContainer();
	local nSize = container:GetNumChildren();
	local i, node;
	lite3DCanvas:UnselectAll();
	for i=1, nSize do
		node = container:GetChildAt(i);
		local baseObject = node;
		local replacement;
		local kk,vv;
		for kk,vv in ipairs(list) do
			if(vv:GetUID() == baseObject:GetUID())then
				replacement = vv;
				break;
			end
		end
		if(replacement ~= nil)then
			local clone_node = replacement:Clone();
			lite3DCanvas:Replace(i,clone_node);
			clone_node:SetSelected(true);
		end
	end	

end
function CommandChangeState:FillList(lite3DCanvas,listToFill)
	if(not lite3DCanvas or not listToFill)then return end;
	local container = lite3DCanvas:GetContainer();
	local nSize = container:GetNumChildren();
	local i, node;
	for i=1, nSize do
		node = container:GetChildAt(i);
		if(node:GetSelected())then
			local clone_node = node:Clone();
			table.insert(listToFill,clone_node);
		end
	end	
end	