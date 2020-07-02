--[[
Title: LiteCanvas
Author(s): Leio
Date: 2009/1/15
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Container/LiteCanvas.lua");

local canvas = Map3DSystem.App.Inventor.LiteCanvas:new{
	type = "MiniScene", -- "MiniScene" or "Scene"
	autoPick = false,
}
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display/Containers/MiniScene.lua");
NPL.load("(gl)script/ide/Display/Containers/Scene.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Creator/ZoneNode.lua");
local LiteCanvas = {
	px = 255,
	py = 0,
	pz = 0,
	sceneType = "MiniScene", -- "MiniScene" or "Scene"
	copyList = nil,
	storeCopyList = nil,
	pasteState = nil,
	autoPick = false,
	
	canvasType = "LiteCanvas",
}
commonlib.setfield("Map3DSystem.App.Inventor.LiteCanvas",LiteCanvas);
function LiteCanvas:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	local type = o.sceneType;
	o:Initialization(type)
	return o
end
------------------------------------------------------------
-- private methods
------------------------------------------------------------
function LiteCanvas:Initialization(type)
	--self.name = ParaGlobal.GenerateUniqueID();
	self.copyList = nil;
	self.storeCopyList = nil;
	self.pasteState = nil;
	
	if(not type or type == "MiniScene")then
		self.miniScene = CommonCtrl.Display.Containers.MiniScene:new();
	else
		self.miniScene = CommonCtrl.Display.Containers.Scene:new();
	end
	self.miniScene:Init();
end
function LiteCanvas:SetMiniScene(miniScene)
	self.miniScene = miniScene;
end
-- only enabled in Scene
function LiteCanvas:FindEntityNode(obj)
	if(obj and obj:IsValid())then
		local container = self:GetContainer();
		local child = container:GetChildByEntityID(obj:GetID());
		if(child) then return child end;
		local type = obj:GetType();
		local params;
		if(type == "CBaseObject")then						
			 params = ObjEditor.GetObjectParams(obj);
			 child = CommonCtrl.Display.Objects.Building3D:new();
			 child:Init();
			 child:SetEntityID(obj:GetID());
			 child:SetEntityParams(params);
			 child:SetBuilded(true);
			 container:AddChild(child);
		elseif(type == "RPG Character")then
			 params = ObjEditor.GetObjectParams(obj);
			 child = CommonCtrl.Display.Objects.Actor3D:new();
			 child:Init();
			 child:SetEntityID(obj:GetID());
			 child:SetEntityParams(params);
			 child:SetBuilded(true);
			 container:AddChild(child);		 
		elseif(type == "CZoneNode" or type == "CPortalNode")then		
			params = ObjEditor.GetObjectParams(obj);
			params["width"] = obj:GetAttributeObject():GetField("width",1)
			params["height"] = obj:GetAttributeObject():GetField("height",1)
			params["depth"] = obj:GetAttributeObject():GetField("depth",1)
			params["zoneplanes"] = obj:GetAttributeObject():GetField("zoneplanes","")
			
			params["portalpoints"] = obj:GetAttributeObject():GetField("portalpoints","")
			params["homezone"] = obj:GetAttributeObject():GetField("homezone","")
			params["targetzone"] = obj:GetAttributeObject():GetField("targetzone","")
			
			if(type == "CZoneNode")then
				child = Map3DSystem.App.Creator.ZoneNode:new();
			else
				child = Map3DSystem.App.Creator.PortalNode:new();
			end			
			child:Init();
			child:SetEntityID(obj:GetID());
			child:SetEntityParams(params);
			child:SetBuilded(true);
			container:AddChild(child);			
		end
		local lite3DCanvas = Map3DSystem.App.Inventor.GlobalInventor.Lite3DCanvas;
		local commandManager =Map3DSystem.App.Inventor.GlobalInventor.commandManager;
		if(child and commandManager)then
		NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/CommandAdd.lua");
		local commandAdd = Map3DSystem.App.Inventor.CommandAdd:new();
		commandAdd:Initialization(child);
		commandManager:AddCommandToHistory(commandAdd);
		return child;
	end
	end
end
------------------------------------------------------------
-- public methods
------------------------------------------------------------
function LiteCanvas:SetPlayerPos(x,y,z)
	self.px,self.py,self.pz = x,y,z;
end
function LiteCanvas:GetPlayerPos()
	return self.px,self.py,self.pz;
end
function LiteCanvas:GetAutoPick()
	if(self.sceneType == "Scene")then
		return self.autoPick;
	end
	return false;
end
function LiteCanvas:GetContainer()
	return self.miniScene;
end
function LiteCanvas:SetPasteState(v)
	self.pasteState = v;
end
function LiteCanvas:GetPasteState()
	return self.pasteState;
end
function LiteCanvas:GetCopyList()
	return self.copyList;
end
function LiteCanvas:ClearCopyList()
	self.copyList = nil;
end
function LiteCanvas:SelectInRectangle(startPoint,lastPoint)
	if(startPoint and lastPoint)then
		self:UnselectAll();
		local _left, _top, _right, _bottom = startPoint.x,startPoint.y,lastPoint.x,lastPoint.y;
		if(not _left or not _top or not _right or not _bottom)then return end
		local left = math.min(_left,_right);
		local right = math.max(_left,_right);
		local top = math.min(_top,_bottom);
		local bottom = math.max(_top,_bottom);
		local result = {}; 
		if( not commonlib.partialcompare(left, right, Map3DSystem.App.Inventor.GlobalInventor.minDistance) or
			not commonlib.partialcompare(top, bottom, Map3DSystem.App.Inventor.GlobalInventor.minDistance)) then				
			ParaScene.GetObjectsByScreenRect(result, left, top, right, bottom, "4294967295", -1);
		end
		if(#result == 0)then
			return;
		end
		if(self:GetAutoPick())then
			for __,obj in ipairs(result) do
				self:FindEntityNode(obj)
			end
		end
		local container = self:GetContainer();
		local nSize = container:GetNumChildren();
		local i, node;
		for i=1, nSize do
			node = container:GetChildAt(i);
			if(node~=nil and node:HitTestObject(startPoint,lastPoint))then
				node:SetSelected(true);
			end
		end
	end
end
function LiteCanvas:AddChild(node)
	if(not node)then return end
	local parent = node:GetParent();
	if(parent)then
		parent:AddChild(node);
	else
		local container = self:GetContainer();	
		container:AddChild(node);
	end
end
function LiteCanvas:Update()
	local container = self:GetContainer();
	container:UpdateEntity();
end
function LiteCanvas:CanCut()
	local arr = self:GetSelection()
	local len = #arr;
	if(len > 0)then
		return true;
	else
		return false;
	end
	return result;
end
function LiteCanvas:CanCopy()
	return self:CanCut();
end    
function LiteCanvas:CanPaste()
	if(self.copyList == nil)then
		return false;
	end
	if(#self.copyList>0)then
		return true;
	else
		return false;
	end
end     
function LiteCanvas:PasteCopyList()
	if(self:CanPaste())then
		self:UnselectAll();
		local container = self:GetContainer();
		local k,v;
		for k,v in ipairs(self.copyList) do
			local node = v;
			container:AddChild(node);
			node:SetSelected(true);
		end
		if(self.pasteState == "cut")then
			self.copyList = nil;
			self.storeCopyList = nil;
		end
	end
end  
function LiteCanvas:PasteCopyListRelative(x,y,z)
	if(self:CanPaste())then
		x = x or 0;
		y = y or 0;
		z = z or 0;
		local delta_x,delta_y,delta_z;
		self:UnselectAll();
		local container = self:GetContainer();
		local k,v;
		for k,v in ipairs(self.copyList) do
			local node = v;
			local point3D = node:LocalToGlobal({x = 0, y = 0, z = 0})
			delta_x = x - point3D.x;
			delta_y = y - point3D.y;
			delta_z = z - point3D.z;
			break;
		end
		for k,v in ipairs(self.copyList) do
			local node = v;
			container:AddChild(node);
			node:SetPositionDelta(delta_x,delta_y,delta_z);
			node:SetSelected(true);
		end
		if(self.pasteState == "cut")then
			self.copyList = nil;
			self.storeCopyList = nil;
		end
		return delta_x,delta_y,delta_z;
	end
end  
function LiteCanvas:CutSelection()
	if(self:CanCut())then
		local list = {};
		local arr = self:GetSelection()
		local nSize = #arr;
		local i, node;
		for i=1, nSize do
			node = arr[i];
			if(node)then
				local clone_node = node:Clone();
				table.insert(list,clone_node);
			end
		end	
		self:DeleteSelection();
		self.copyList = list;
	end
end
function LiteCanvas:CloneCopyList()
	if(self:CanPaste())then
		local list = {};
		for k,v in ipairs(self.storeCopyList) do
			local node = v;
			local clone_node = node:CloneNoneID();
			table.insert(list,clone_node);
		end	
		self.copyList = list;
	end
end
function LiteCanvas:CopySelection()
	if(self:CanCopy())then
		local list = {};
		local storeList = {};
		local arr = self:GetSelection()
		local nSize = #arr;
		local i, node;
		for i=1, nSize do
			node = arr[i];
			if(node)then
				local clone_node = node:CloneNoneID();
				table.insert(list,clone_node);
				table.insert(storeList,clone_node);
			end
		end	
		self.storeCopyList=storeList;
	    self.copyList=list;
	end
end 
function LiteCanvas:CanDelete()
	return self:CanCut();
end
function LiteCanvas:DeleteSelection()
	local container = self:GetContainer();
	self:__DeleteSelection(container)
end 
function LiteCanvas:__DeleteSelection(parent)
	if(not parent or not parent.GetNumChildren)then return end
	local len = parent:GetNumChildren();
	while(len>0)do
		local node = parent:GetChildAt(len);
		if(node:GetSelected())then
			parent:RemoveChild(node);
		else
			self:__DeleteSelection(node)
		end
		len = len - 1;
	end
end 
function LiteCanvas:GetNextSelection()
	local index = 1;
	local container = self:GetContainer();
	local nSize = container:GetNumChildren();
	local i, node;
	for i=1, nSize do
		node = container:GetChildAt(i);
		if(node:GetSelected())then
			index = node.index + 1;
		end
	end	
	local container = self:GetContainer();
	local len = container:GetNumChildren();
	if(index < 1 or index > len)then
		index = 1;
	end
	local node = container:GetChildAt(index);
	if(node)then
		self:UnselectAll()
		node:SetSelected(true);
	end
end
function LiteCanvas:GetLastSelection()
	local container = self:GetContainer();
	local len = container:GetNumChildren();
	if(len>0)then
		local node = container:GetChildAt(len);
		if(node)then
			node:SetSelected(true);
		end
	end
end
function LiteCanvas:DeleteLastAddedObject()
	local container = self:GetContainer();
	local len = container:GetNumChildren();
	local node = container:GetChildAt(len);
	if(node)then
		container:RemoveChild(node);
	end
end   
function LiteCanvas:Replace(index,node)
	if(not index or not node)then return; end
	local container = self:GetContainer();
	local before = container:GetChildAt(index);
	if(before)then
		container:RemoveChild(before);
		container:AddChildAt(node,index);	
	end
end 
function LiteCanvas:SelectAll()
	self:UnselectAll()
	local container = self:GetContainer();
	local nSize = container:GetNumChildren();
	local i, node;
	for i=1, nSize do
		node = container:GetChildAt(i);
		node:SetSelected(true);
	end
end
function LiteCanvas:UnselectAll()
	local arr = self:GetSelection()
	local nSize = #arr;
	local i, node;
	for i=1, nSize do
		node = arr[i];
		if(node)then
			node:SetSelected(false);
		end
	end	
end
function LiteCanvas:GetSelection()
	local arr = {};
	local container = self:GetContainer();
	self:__GetSelection(container,arr)
	return arr;
end
function LiteCanvas:__GetSelection(parent,arr)
	if(not parent or not parent.GetNumChildren or not arr)then return end
	local nSize = parent:GetNumChildren();
	local i, node;
	for i=1, nSize do
		node = parent:GetChildAt(i);
		if(node:GetSelected())then
			table.insert(arr,node);
		else
			self:__GetSelection(node,arr)
		end
	end
end
function LiteCanvas:CanGroup()
	local container = self:GetContainer();
	local len = container:GetNumChildren();
	if(len == 1)then
		local node = container:GetChildAt(len);
		if(node.CLASSTYPE == "MiniScene" or node.CLASSTYPE == "Sprite3D")then 
			return false;
		end
	end
	
	local container = self:GetContainer();
	local nSize = container:GetNumChildren();
	local k,v;
	len = 0;
	for i=1, nSize do
		local node =  container:GetChildAt(i);
		if(node:GetSelected())then
			len = len + 1;
			if(len > 1)then
				return true;
			end
		end
	end
	return false;
end
function LiteCanvas:CanUnGroup()
	local container = self:GetContainer();
	local nSize = container:GetNumChildren();
	local k,v;
	for i=1, nSize do
		local node =  container:GetChildAt(i);
		if(node:GetSelected())then
			if(node.CLASSTYPE == "MiniScene" or node.CLASSTYPE == "Sprite3D")then 
				return true;
			end
		end
	end
	return false;
end
function LiteCanvas:UnGroup()	
	if(not self:CanUnGroup())then return; end
	commonlib.echo("ungroup");
	--local container = self:GetContainer();
	--local len = container:GetNumChildren();
	--while(len > 0) do
		--local node = container:GetChildAt(len);	
		--if(node:GetSelected() and (node.CLASSTYPE == "MiniScene" or node.CLASSTYPE == "Sprite3D"))then			
			--local len_node = node:GetNumChildren();		
			--while(len_node > 0) do
				--local child = node:GetChildAt(len_node);	
				--local child_clone = child:Clone();	
				--node:RemoveChild(child);	
				--container:AddChild(child_clone);
				--local x,y,z = node:GetPosition();
				--child_clone:SetPositionDelta(x,y,z);
				--child_clone:SetSelected(true);			
				--len_node = len_node - 1;
			--end	
			--container:RemoveChild(node);		
		--end		
		--len = len - 1;		
	--end
	local arr = self:GetSelection()
	local nSize = #arr;
	local i, node;
	for i=1, nSize do
		node = arr[i];
		if(node)then
			local parent = node:GetParent();
			local parent_parent;		
			if(parent)then
				parent_parent = parent:GetParent();
				if(parent_parent)then
					parent:DetachChild(node);
					parent_parent:AttachChild(node);
					local x,y,z = parent_parent:GetPosition();
					node:SetPositionDelta(-x,-y,-z);
				end
			end	
		end
	end	
end
function LiteCanvas:Group()
	if(not self:CanGroup())then return; end
	local sprite3D = CommonCtrl.Display.Containers.Sprite3D:new();
	sprite3D:Init()
	local container = self:GetContainer();
	--local len = container:GetNumChildren();
	--
	--local canAdd = false;
	--while(len > 0)do
		--local node = container:GetChildAt(len);
		--if(node:GetSelected())then
			--local child_clone = node:Clone();
			--container:RemoveChild(node);
			--sprite3D:AddChild(child_clone);
			--local x,y,z = sprite3D:GetPosition();
			--child_clone:SetPositionDelta(-x,-y,-z);
			--canAdd = true;
		--end
		--len = len -1;
	--end
	local arr = self:GetSelection()
	local nSize = #arr;
	local i, node;
	for i=1, nSize do
		node = arr[i];
		if(node)then
			local parent = node:GetParent();
			parent:DetachChild(node);
			sprite3D:AttachChild(node);
			local x,y,z = sprite3D:GetPosition();
			node:SetPositionDelta(-x,-y,-z);
		end
	end	
	container:AddChild(sprite3D);
	--if(canAdd)then
		--container:AddChild(sprite3D);
		--sprite3D:SetSelected(true);
	--end
	return sprite3D;
end
-- directly pick a node by mouse
-- result: node must be a uncontainer object like "Actor3D" "Building3D"
function LiteCanvas:PickNode()
	local container = self:GetContainer();
	local obj = ParaScene.MousePick(40, "4294967295");	
	if(obj:IsValid()) then	
		local id = tostring(obj:GetID());
		local node = container:GetChildByEntityID(id);
		return node;
	end	
end
-- node type maybe is container
function LiteCanvas:FindHitNode()
	local result = {};
	local container = self:GetContainer();
	self:__FindHitNode(container,result);
	local node = result.node;
	return node;
end
function LiteCanvas:__FindHitNode(parent,result)
	if(not parent or not parent.GetNumChildren or not result)then return end
	local nSize = parent:GetNumChildren();
	local i, node;
	for i=1, nSize do
		node = parent:GetChildAt(i);
		local handleNumber= node:HitTest();
		if(handleNumber == 0)then
			result.node = node;	
			return;
		else
			self:__FindHitNode(node,result)	
		end
	end
end
function LiteCanvas:Clear()
	local container = self:GetContainer();
	container:Clear();
end
function LiteCanvas:ToMcml()
	local container = self:GetContainer();
	local result = container:ClassToMcml();
	local type = self.canvasType;
	local player = ParaScene.GetPlayer()
	local px,py,pz;
	if(player:IsValid() == true) then 	
		px,py,pz = player:GetPosition();	
	else
		px,py,pz = 255,0,255
	end
	px = tonumber(px);
	py = tonumber(py);
	pz = tonumber(pz);
	self:SetPlayerPos(px,py,pz);
	result = string.format('<Room><%s x="%f" y="%f" z="%f">%s</%s></Room>',type,px,py,pz,result,type);
	return result;
end
------------------------------------------------------------
-- old methods
------------------------------------------------------------
--function LiteCanvas:AddNode(node, index)
	--if(not node)then return end
	--local container = self:GetContainer();
	--container:AddChildAt(node,index);
--end
--function LiteCanvas:RemoveNode(node)
	--if(not node)then return end
	--local container = self:GetContainer();
	--container:RemoveChild(node);
--end
--function LiteCanvas:GetChildCount()
	--local container = self:GetContainer();
	--local nSize = container:GetNumChildren();
	--return nSize;
--end
--function LiteCanvas:GetChild(index)
	--if(not index)then return end;
	--local container = self:GetContainer();
	--return container:GetChildAt(index);
--end