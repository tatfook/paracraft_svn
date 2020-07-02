--[[
Title: EntityTool
Author(s): Leio
Date: 2008/11/24
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Tools/EntityTool.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Util/GlobalInventor.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/CommandChangeState.lua");
local EntityTool = commonlib.inherit(Map3DSystem.App.Inventor.IEntityTool,{
	commandManager = nil,
	name = "EntityTool",
	lastPoint = {x = 0 ,y = 0 ,z = 0},
});  
commonlib.setfield("Map3DSystem.App.Inventor.EntityTool",EntityTool);
function EntityTool:Initialization(commandManager)
	self.commandManager=commandManager;
end
function EntityTool:SetEntityParams(obj_params)
	if(not obj_params)then return end
	obj_params.name = self.name;
	local objGraph = ParaScene.GetMiniSceneGraph("object_editor"..self.name);
	objGraph:DestroyObject(self.name);			
	obj_params.name = self.name;
	local obj = ObjEditor.CreateObjectByParams(obj_params);
	if(obj~=nil and obj:IsValid()) then
		obj:GetAttributeObject():SetField("progress", 1);
		objGraph:AddChild(obj);			
	end	
	self.wasMove = false;
	self.lastPoint = {x = 0 ,y = 0 ,z = 0};
end
function EntityTool:OnLeftMouseDown(lite3DCanvas,msg)
	self.wasMove = false;
	self.lastPoint = {x = 0 ,y = 0 ,z = 0};
end
function EntityTool:OnLeftMouseUp(lite3DCanvas,msg)
	if(not lite3DCanvas or not msg)then return; end
	local objGraph = ParaScene.GetMiniSceneGraph("object_editor"..self.name);
	local cursorObj = objGraph:GetObject(self.name);
	if(cursorObj:IsValid()) then	
		local params = ObjEditor.GetObjectParams(cursorObj);
		if(params)then
			local type = params.IsCharacter;
			local baseObject;
			if(type)then
				baseObject = CommonCtrl.Display.Objects.Actor3D:new()
			else
				baseObject = CommonCtrl.Display.Objects.Building3D:new()
			end
			baseObject:Init();
			baseObject:SetEntityParams(params);
			
			lite3DCanvas:AddChild(baseObject);
			lite3DCanvas:Update();
			
			if(self.commandManager)then
				NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/CommandAdd.lua");
				local commandAdd = Map3DSystem.App.Inventor.CommandAdd:new();
				commandAdd:Initialization(baseObject);
				self.commandManager:AddCommandToHistory(commandAdd);
			end
		end
	end	
end	
function EntityTool:OnMouseMove(lite3DCanvas,msg)
	if(not lite3DCanvas or not msg)then return; end	
	local obj = ParaScene.MousePick(70, "point");
	if(obj:IsValid())then
		local x,y,z = obj:GetPosition();
		local objGraph = ParaScene.GetMiniSceneGraph("object_editor"..self.name);
		local cursorObj = objGraph:GetObject(self.name);
		if(cursorObj:IsValid()) then
			cursorObj:SetPosition(x,y,z);
		end	
		if( not commonlib.partialcompare(x, self.lastPoint.x, 0.1) or
			not commonlib.partialcompare(y, self.lastPoint.y, 0.1) or
			not commonlib.partialcompare(z, self.lastPoint.z, 0.1) ) then
			if(not self.wasMove)then
				self.wasMove = true;	
			end		
		end
		self.lastPoint = {x = x ,y = y ,z = z};	
	end
end
function EntityTool:OnRightMouseDown(lite3DCanvas,msg)
	self.wasMove = false;
	self.lastPoint = {x = 0 ,y = 0 ,z = 0};
end
function EntityTool:OnRightMouseUp(lite3DCanvas,msg)
	if(not lite3DCanvas or not msg)then return; end
	commonlib.echo(self.wasMove);
	if(not self.wasMove)then
		local objGraph = ParaScene.GetMiniSceneGraph("object_editor"..self.name);
		objGraph:DestroyObject(self.name);	
	end
end
