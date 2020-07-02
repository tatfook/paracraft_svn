--[[
Title: SelectTool
Author(s): Leio
Date: 2008/12/19
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Tools/SelectTool.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Util/GlobalInventor.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/CommandChangeState.lua");
local SelectTool = commonlib.inherit(Map3DSystem.App.Inventor.IEntityTool,{
	selectMode = nil,
	resizedObject = nil,
	resizedObjectHandle = nil,
	lastPoint = nil,
	startPoint = nil,
	commandManager = nil,
	press = nil,
	wasMove = nil,
	commandChangeState = nil,
});  
commonlib.setfield("Map3DSystem.App.Inventor.SelectTool",SelectTool);
function SelectTool:Initialization(commandManager)
	self.commandManager=commandManager;
	self.selectMode = "None"; ------------------------------mode is "None" now
	self.press = false;
	self.wasMove = false;
	self.lastPoint = {x = 0,y = 0};
	self.startPoint = {x = 0,y = 0};
	
	self.lastPoint3D = {x = 0,y = 0,z = 0};
	self.startPoint3D = {x = 0,y = 0,z = 0};
end
function SelectTool:OnLeftMouseDown(lite3DCanvas,msg)
	if(not lite3DCanvas or not msg)then return; end
	if(msg.mouse_button ~= "left")then return; end
	self.press = true;
	self.wasMove = false;
	self.selectMode = "None"; ------------------------------mode is "None" now
	local mouse_x = msg.mouse_x;
	local mouse_y = msg.mouse_y;
	local point = {x = mouse_x,y = mouse_y};
	local k,v;
	
	-- Test for move 
	if(self.selectMode == "None")then		
		local baseObject;	
		--local container = lite3DCanvas:GetContainer();
		--local nSize = container:GetNumChildren();	
		--local i, node;
		--for i=1, nSize do
			--node = container:GetChildAt(i);
			--local handleNumber= node:HitTest();
			--if(handleNumber == 0)then
				--baseObject = node;			
				--break;
			--end
		--end	
		baseObject = lite3DCanvas:FindHitNode();
		if(not baseObject and lite3DCanvas:GetAutoPick())then
			local obj = ParaScene.MousePick(40, "4294967295");
			if(obj:IsValid()) then	
				baseObject = lite3DCanvas:FindEntityNode(obj);
			end	
		end
		if(baseObject)then
			self.selectMode = "Move"; ------------------------------mode is "Move" now
			local ctrl_pressed = ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_LCONTROL) or ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_RCONTROL)
			local selected = baseObject:GetSelected()
			if(not selected and not ctrl_pressed)then
				lite3DCanvas:UnselectAll();
			end
			
			if(not selected)then
				baseObject:SetSelected(true);
				self.commandChangeState=Map3DSystem.App.Inventor.CommandChangeState:new();
				self.commandChangeState:Initialization(lite3DCanvas);
			else
				if(ctrl_pressed)then
					baseObject:SetSelected(false);
				end
			end
		end
	end
	-- Net selection
	if(self.selectMode == "None")then
		lite3DCanvas:UnselectAll();
		self.selectMode = "NetSelection"; ------------------------------mode is "NetSelection" now
	end
	
    self.lastPoint.x = mouse_x;
    self.lastPoint.y = mouse_y;
    self.startPoint.x = mouse_x;
    self.startPoint.y = mouse_y;
    
    --local pt = ParaScene.MousePick(70, "point"); -- pick a object
	--if(pt:IsValid())then
		--local x,y,z = pt:GetPosition();
		--self.lastPoint3D.x = x;
		--self.lastPoint3D.y = y;
		--self.lastPoint3D.z = z;
		--self.startPoint3D.x = x;
		--self.startPoint3D.y = y;
		--self.startPoint3D.z = z;		
	--end
end
function SelectTool:OnLeftMouseUp(lite3DCanvas,msg)
	if(not lite3DCanvas or not msg)then return; end
	if(msg.mouse_button ~= "left")then return; end
	local mouse_x = msg.mouse_x;
	local mouse_y = msg.mouse_y;
	self.press = false;
	if(self.selectMode == "NetSelection")then
		-- make group selection
		Map3DSystem.App.Inventor.GlobalInventor.DrawArea(self.startPoint,self.lastPoint);
		lite3DCanvas:SelectInRectangle(self.startPoint,self.lastPoint);
		Map3DSystem.App.Inventor.GlobalInventor.ClearArea();
		self.selectMode = "None"; ------------------------------mode is "None" now
	end
	if(self.resizedObject ~= nil)then
		self.resizedObject = nil;
	end
	if(self.wasMove and self.commandChangeState ~= nil)then
		if(self.commandManager)then
			self.commandChangeState:NewState(lite3DCanvas);
			self.commandManager:AddCommandToHistory(self.commandChangeState);
		end
		self.commandChangeState=nil;	
	end
	Map3DSystem.App.Inventor.GlobalInventor.commandCallBack();
end	
function SelectTool:OnMouseMove(lite3DCanvas,msg)
	if(not lite3DCanvas or not msg)then return; end
	if(not self.press)then
		return;
	end	
	local mouse_x = msg.mouse_x;
	local mouse_y = msg.mouse_y;	
	
	local point = {x = mouse_x,y = mouse_y};
	local oldPoint =  self.lastPoint;

	if( not commonlib.partialcompare(mouse_x, self.lastPoint.x, 0.1) or
		not commonlib.partialcompare(mouse_y, self.lastPoint.y, 0.1) ) then
		self.wasMove = true;	
	end
	self.lastPoint["x"] = mouse_x;
	self.lastPoint["y"] = mouse_y;
	-- draw area
	if(self.selectMode == "NetSelection")then
		Map3DSystem.App.Inventor.GlobalInventor.DrawArea(self.startPoint,self.lastPoint);
		return;
	end
end