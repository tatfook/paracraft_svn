--[[
Title: SelectorTool
Author(s): Leio
Date: 2008/12/19
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Tools/SelectorTool.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Util/GlobalInventor.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/CommandChangeState.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Tools/IEntityTool.lua");
local SelectorTool = commonlib.inherit(Map3DSystem.App.Inventor.IEntityTool,{
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
commonlib.setfield("Map3DSystem.App.Inventor.SelectorTool",SelectorTool);
function SelectorTool:Initialization(commandManager)
	self.commandManager=commandManager;
	self.selectMode = "None"; ------------------------------mode is "None" now
	self.press = false;
	self.wasMove = false;
	self.lastPoint = {x = 0,y = 0};
	self.startPoint = {x = 0,y = 0};
	self.lastPoint3D = {x = 0,y = 0,z = 0};
end
function SelectorTool:OnLeftMouseDown(lite3DCanvas,msg)
if(not lite3DCanvas or not msg)then return; end
	if(msg.mouse_button ~= "left")then return; end
	self.press = true;
	self.wasMove = false;
	self.selectMode = "None"; ------------------------------mode is "None" now
	local mouse_x = msg.mouse_x;
	local mouse_y = msg.mouse_y;
	local point = {x = mouse_x,y = mouse_y};
	local k,v;
	self.SelectionNodes = nil;
	self:SetPressedNode(nil)
	-- Test for move 
	if(self.selectMode == "None")then		
		local baseObject;	
		baseObject = lite3DCanvas:PickNode()
		--baseObject = lite3DCanvas:FindHitNode();
		if(not baseObject and lite3DCanvas:GetAutoPick())then
			local obj = ParaScene.MousePick(40, "4294967295");
			if(obj:IsValid()) then	
				baseObject = lite3DCanvas:FindEntityNode(obj);
			end	
		end
		if(baseObject)then
			self.selectMode = "Move"; ------------------------------mode is "Move" now
			local ctrl_pressed = ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_LCONTROL) or ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_RCONTROL);
			local alt_pressed = ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_LMENU) or ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_RMENU);
			local shift_pressed = ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_LSHIFT) or ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_RSHIFT);
			local selected = baseObject:GetSelected()
			if(not alt_pressed)then
				if(not ctrl_pressed)then
					if(not shift_pressed)then
						lite3DCanvas:UnselectAll();
					end
					baseObject:SetSelected(true);
					self:SetPressedNode(baseObject)				
				else		
					if(not selected)then
						baseObject:SetSelected(true);
						self:SetPressedNode(baseObject)
						
					else
						baseObject:SetSelected(false);
						self:SetPressedNode(nil)
					end
				end
			end
			
			if(alt_pressed and ctrl_pressed)then	
				baseObject:SetSelected(true);
				self:SetPressedNode(baseObject)
			end
			selected = baseObject:GetSelected()
			if(selected)then
				local x,y,z = baseObject:GetPosition();
				self.lastPoint3D.x = x;
				self.lastPoint3D.y = y;
				self.lastPoint3D.z = z;
				
				self.commandChangeState=Map3DSystem.App.Inventor.CommandChangeState:new();
				self.commandChangeState:Initialization(lite3DCanvas);
			end
		end
	end
	
	-- Net selection
	if(self.selectMode == "None")then
		lite3DCanvas:UnselectAll();
		self.selectMode = "NetSelection"; ------------------------------mode is "NetSelection" now
	end
	self.SelectionNodes = lite3DCanvas:GetSelection();
    self.lastPoint.x = mouse_x;
    self.lastPoint.y = mouse_y;
    self.startPoint.x = mouse_x;
    self.startPoint.y = mouse_y;
    Map3DSystem.App.Inventor.GlobalInventor.DrawMirrorOfSelectedNodes(self.SelectionNodes)
end
function SelectorTool:OnLeftMouseUp(lite3DCanvas,msg)
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
	local ctrl_pressed = ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_LCONTROL) or ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_RCONTROL);
	local alt_pressed = ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_LMENU) or ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_RMENU);
	local shift_pressed = ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_LSHIFT) or ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_RSHIFT);
	
	
	if(self.wasMove)then
		if(self.SelectionNodes and shift_pressed and not ctrl_pressed and not alt_pressed)then
			-- create new objectes	
			Map3DSystem.App.Inventor.GlobalInventor.Create_DrawMirrorOfSelectedNodes(self.SelectionNodes,lite3DCanvas,self.commandManager)							
		else
			-- update property of objectes
			Map3DSystem.App.Inventor.GlobalInventor.Update_DrawMirrorOfSelectedNodes(self.SelectionNodes)
			if(self.commandChangeState ~= nil)then	
				if(self.commandManager)then
					self.commandChangeState:NewState(lite3DCanvas);
					self.commandManager:AddCommandToHistory(self.commandChangeState);
				end					
			end
		end	
		self.commandChangeState=nil;	
	end
	Map3DSystem.App.Inventor.GlobalInventor.commandCallBack();
	self.SelectionNodes = nil;
	self:SetPressedNode(nil)
	Map3DSystem.App.Inventor.GlobalInventor.Destroy_DrawMirrorOfSelectedNodes()
end	
function SelectorTool:OnMouseMove(lite3DCanvas,msg)
	if(not lite3DCanvas or not msg)then return; end
	if(not self.press or not self.SelectionNodes)then
		return;
	end	
	local mouse_x = msg.mouse_x;
	local mouse_y = msg.mouse_y;	
	
	if( not commonlib.partialcompare(mouse_x, self.lastPoint.x, 0.1) or
		not commonlib.partialcompare(mouse_y, self.lastPoint.y, 0.1) ) then
		if(not self.wasMove)then
			self.wasMove = true;	
		end		
	end
	local ctrl_pressed = ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_LCONTROL) or ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_RCONTROL);
	local alt_pressed = ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_LMENU) or ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_RMENU);
	local shift_pressed = ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_LSHIFT) or ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_RSHIFT);
	local deltaX = mouse_x - self.lastPoint.x;
	local deltaY = mouse_y - self.lastPoint.y;
	local position;
	-- move x and z	
	local node = Map3DSystem.App.Inventor.GlobalInventor.GetPressedNode_DrawMirrorOfSelectedNodes(self:GetPressedNode())
	if(node and not ctrl_pressed and not alt_pressed)then
		position = {};
		local x,y,z = node:GetPosition();
		local pt = ParaScene.MousePick(70, "point"); -- pick a object
		if(pt:IsValid())then
			_x,_y,_z = pt:GetPosition();
			position.x = _x - x;
			position.y = _y - y;
			position.z = _z - z;
		end	
		Map3DSystem.App.Inventor.GlobalInventor.DrawMirrorOfSelectedNodes(self.SelectionNodes,position,nil,nil)
	end
	-- facing
	if(not ctrl_pressed and alt_pressed)then
		local facing = deltaX/10;
		Map3DSystem.App.Inventor.GlobalInventor.DrawMirrorOfSelectedNodes(self.SelectionNodes,nil,facing,nil)
	end
	---- y
	--if(node and alt_pressed and not ctrl_pressed)then
		--position = {};
		--local x,y,z = node:GetPosition();
		--local pt = ParaScene.MousePick(70, "point"); -- pick a object
		--if(pt:IsValid())then
			--if(deltaY == 0)then deltaY = 1 end
			--position.x = 0;
			--position.y = -deltaY/(math.abs(deltaY) * 10);
			--position.z = 0;
		--end	
		--Map3DSystem.App.Inventor.GlobalInventor.DrawMirrorOfSelectedNodes(self.SelectionNodes,position,nil,nil)
	--end
	if(node and ctrl_pressed and alt_pressed)then
		local advRotation = {};
		advRotation.center_x,advRotation.center_y,advRotation.center_z = node:GetPosition();
		if(deltaX == 0)then
			deltaX = 1;
		end
		local value = 0.05 * deltaX/math.abs(deltaX);
		advRotation.delta_x,advRotation.delta_y,advRotation.delta_z = 0,value,0;
		Map3DSystem.App.Inventor.GlobalInventor.DrawMirrorOfSelectedNodes(self.SelectionNodes,nil,nil,nil,advRotation)
	end
	self.lastPoint["x"] = mouse_x;
	self.lastPoint["y"] = mouse_y;
	-- draw area
	if(self.selectMode == "NetSelection")then
		Map3DSystem.App.Inventor.GlobalInventor.DrawArea(self.startPoint,self.lastPoint);
		return;
	end
end