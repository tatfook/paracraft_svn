--[[
Title: CommandGroup
Author(s): Leio
Date: 2008/11/27
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/CommandGroup.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/ICommand.lua");
local CommandGroup = commonlib.inherit(Map3DSystem.App.Inventor.ICommand,{
	cloneList = nil,
	groupNodeID = nil,
});  
commonlib.setfield("Map3DSystem.App.Inventor.CommandGroup",CommandGroup);

function CommandGroup:Initialization(lite3DCanvas)
	if(not lite3DCanvas)then return end;
	self.cloneList = {};
	local k,v;
	local list = lite3DCanvas:GetSelection();
	for k,v in ipairs(list) do
		local node = v;
		table.insert(self.cloneList,node:Clone());
	end
end
function CommandGroup:SetGroupNode(node)
	if(not node)then return end
	self.cloneGroupNode = node:Clone();
end
function CommandGroup:Undo(lite3DCanvas)
	if(not lite3DCanvas)then return end;
	self:UnGroup(lite3DCanvas);
end

function CommandGroup:Redo(lite3DCanvas)
	if(not lite3DCanvas)then return end;
	self:Group(lite3DCanvas);
end
function CommandGroup:Group(lite3DCanvas)
	if(not lite3DCanvas)then return end;
	local container = lite3DCanvas:GetContainer();
	local len = #self.cloneList;
	
	local canAdd = false;
	while(len > 0)do
		local node = self.cloneList[len];
		if(node)then
			container:RemoveChildByUID(node:GetUID());
			canAdd = true;
		end
		len = len -1;
	end
	if(canAdd)then
		local groupNode = self.cloneGroupNode:Clone();
		container:AddChild(groupNode);
		local x,y,z = container:GetPosition();
		groupNode:SetPositionDelta(-x,-y,-z);
		groupNode:SetSelected(true);
	end
end
function CommandGroup:UnGroup(lite3DCanvas)
	if(not lite3DCanvas)then return end;
	local container = lite3DCanvas:GetContainer();
	local node = self.cloneGroupNode;
	if((node.CLASSTYPE == "MiniScene" or node.CLASSTYPE == "Sprite3D"))then			
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