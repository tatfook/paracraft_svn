--[[
Title: ToolBar3
Author(s): Leio
Date: 2009/1/15
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Gears/ToolBar3.lua");
Map3DSystem.App.Inventor.Gears.ToolBar3.Test()
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display/Objects/Actor3D.lua");
NPL.load("(gl)script/ide/Display/Objects/Building3D.lua");
local ToolBar3 = {
} 
commonlib.setfield("Map3DSystem.App.Inventor.Gears.ToolBar3",ToolBar3);
function ToolBar3.BuildEntity(commandName)

	local lite3DCanvas = Map3DSystem.App.Inventor.GlobalInventor.Lite3DCanvas;
	local commandManager =Map3DSystem.App.Inventor.GlobalInventor.commandManager;
	local baseObject
	local x,y,z = ParaScene.GetPlayer():GetPosition();
	if(lite3DCanvas)then
		if(commandName == "Creation.NormalModel" or commandName == "Creation.BuildingComponents")then
			baseObject = CommonCtrl.Display.Objects.Building3D:new()
			baseObject:Init();
			local params = baseObject:GetEntityParams();
			baseObject:SetEntityParams(params);
				
		elseif(commandName == "Creation.NormalCharacter")then
			baseObject = CommonCtrl.Display.Objects.Actor3D:new()
			baseObject:Init();
			local params = baseObject:GetEntityParams();
			baseObject:SetEntityParams(params);
		end
		lite3DCanvas:UnselectAll();
		baseObject:SetPosition(x,y,z);
		lite3DCanvas:AddChild(baseObject);
		baseObject:SetSelected(true)
		lite3DCanvas:Update();
	end
	
	if(baseObject and commandManager)then
		NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/CommandAdd.lua");
		local commandAdd = Map3DSystem.App.Inventor.CommandAdd:new();
		commandAdd:Initialization(baseObject);
		commandManager:AddCommandToHistory(commandAdd);
	end
end
function ToolBar3.Test()
	local baseObject = CommonCtrl.Display.Objects.Building3D:new()
	local params = baseObject:GetEntityParams();
	local objGraph = ParaScene.GetMiniSceneGraph("container_ToolBar3");
	local x,y,z = ParaScene.GetPlayer():GetPosition();
	params.x = x;
	params.y = y;
	params.z = z;
	baseObject:SetEntityParams(params);
	params = baseObject:GetEntityParams();
	local obj = ObjEditor.CreateObjectByParams(params)
	if(obj and obj:IsValid())then
		local id = obj:GetID();
		commonlib.echo(id);
		objGraph:AddChild(obj)
		local result = ParaScene.GetObject(id);
		--local result = objGraph:GetObject(tostring(id));
		if(result and result:IsValid())then
			commonlib.echo("finded:"..result.name);
		end
	end
end

