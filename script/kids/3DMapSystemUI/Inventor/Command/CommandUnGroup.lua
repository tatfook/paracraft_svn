--[[
Title: CommandUnGroup
Author(s): Leio
Date: 2008/11/27
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/CommandUnGroup.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/ICommand.lua");
local CommandUnGroup = commonlib.inherit(Map3DSystem.App.Inventor.ICommand,{
	cloneList = nil
});  
commonlib.setfield("Map3DSystem.App.Inventor.CommandUnGroup",CommandUnGroup);

function CommandUnGroup:Initialization(lite3DCanvas)
	if(not lite3DCanvas)then return end;
	self.cloneList = {};
	local k,v;
	local list = lite3DCanvas:GetSelection();
	for k,v in ipairs(list) do
		local node = v;
		if(node.CLASSTYPE == "MiniScene" or node.CLASSTYPE == "Sprite3D")then	
			table.insert(self.cloneList,node:Clone());
		end
	end
	
end
function CommandUnGroup:Undo(lite3DCanvas)
	if(not lite3DCanvas)then return end;
	self:Group(lite3DCanvas);
end
function CommandUnGroup:Redo(lite3DCanvas)
	if(not lite3DCanvas)then return end;
	self:UnGroup(lite3DCanvas);
end
function CommandUnGroup:Group(lite3DCanvas)	
	if(not lite3DCanvas)then return end;
	local container = lite3DCanvas:GetContainer();
	local k,v;
	for k,v in ipairs(self.cloneList) do
		local node = v;
		local clone_group = node:Clone();
		local len_node = node:GetNumChildren();	
		while(len_node > 0) do
			local child = node:GetChildAt(len_node);	
			container:RemoveChildByUID(child:GetUID());	
			len_node = len_node - 1;
		end	
		container:AddChild(clone_group);
		local x,y,z = container:GetPosition();
		clone_group:SetPositionDelta(-x,-y,-z);	
		clone_group:SetSelected(true);
	end
end
function CommandUnGroup:UnGroup(lite3DCanvas)	
	if(not lite3DCanvas)then return end;
	local container = lite3DCanvas:GetContainer();
	local k,v;
	for k,v in ipairs(self.cloneList) do
		local node = v;
		local len_node = node:GetNumChildren();	
		container:RemoveChildByUID(node:GetUID());	
		local x,y,z = container:GetPosition();
		while(len_node > 0) do
			local child = node:GetChildAt(len_node);	
			local child_clone = child:Clone();	
			container:AddChild(child_clone);	
			child_clone:SetPositionDelta(x,y,z);	
			child_clone:SetSelected(true);		
			len_node = len_node - 1;
		end	
	end
end