--[[
Title: PointerTool
Author(s): Leio
Date: 2008/11/24
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Tools/PointerTool.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Util/GlobalInventor.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/CommandChangeState.lua");
local PointerTool = commonlib.inherit(Map3DSystem.App.Inventor.IEntityTool,{
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
commonlib.setfield("Map3DSystem.App.Inventor.PointerTool",PointerTool);
function PointerTool:Initialization(commandManager,commandManagerEnabled)
	self.commandManager=commandManager;
	self.commandManagerEnabled = commandManagerEnabled;
	self.selectMode = "None"; ------------------------------mode is "None" now
	self.press = false;
	self.wasMove = false;
	self.lastPoint = {x = 0,y = 0};
	self.startPoint = {x = 0,y = 0};
	
	self.lastPoint3D = {x = 0,y = 0,z = 0};
	self.startPoint3D = {x = 0,y = 0,z = 0};
end
function PointerTool:OnLeftMouseDown(lite3DCanvas,msg)
	if(not lite3DCanvas or not msg)then return; end
	if(msg.mouse_button ~= "left")then return; end
	self.press = true;
	self.wasMove = false;
	self.selectMode = "None"; ------------------------------mode is "None" now
	local mouse_x = msg.mouse_x;
	local mouse_y = msg.mouse_y;
	local point = {x = mouse_x,y = mouse_y};
	local k,v;
	---- Test for resizing
	--for k,v in ipairs(lite3DCanvas.Nodes) do
		--local node = v;
		--local handleNumber = node:HitTest(point);
		--if(handleNumber > 0)then
			--self.selectMode = "Size"; ------------------------------mode is "Size" now
			--self.resizedObject = node;
			--self.resizedObjectHandle = handleNumber;
			--lite3DCanvas:UnselectAll();
			--node:SetSelected(true);
			--self.commandChangeState=Map3DSystem.App.Inventor.CommandChangeState:new();
			--self.commandChangeState:Initialization(lite3DCanvas);
            --break;
		--end
	--end
	-- Test for move 
	if(self.selectMode == "None")then
		local baseObject;
		local k,v;
		for k,v in ipairs(lite3DCanvas.Nodes) do
			local node = v;
			local handleNumber= node:HitTest(point);
			if(handleNumber == 0)then
				baseObject = node;			
				lite3DCanvas:UnPickAll();	
				break;
			end
		end
		if(baseObject)then
			self.selectMode = "Move"; ------------------------------mode is "Move" now
			local ctrl_pressed = ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_LCONTROL) or ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_RCONTROL)
			if(not baseObject:GetSelected() and not ctrl_pressed)then
				lite3DCanvas:UnselectAll();
			end
			baseObject:SetSelected(true);
			baseObject:SetPicking(true);
			self.commandChangeState=Map3DSystem.App.Inventor.CommandChangeState:new();
			self.commandChangeState:Initialization(lite3DCanvas);
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
    
    local pt = ParaScene.MousePick(70, "point"); -- pick a object
	if(pt:IsValid())then
		local x,y,z = pt:GetPosition();
		self.lastPoint3D.x = x;
		self.lastPoint3D.y = y;
		self.lastPoint3D.z = z;
		self.startPoint3D.x = x;
		self.startPoint3D.y = y;
		self.startPoint3D.z = z;		
	end
end
function PointerTool:OnLeftMouseUp(lite3DCanvas,msg)
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
		lite3DCanvas:ResetPosition();
		if(self.commandManagerEnabled)then
			self.commandChangeState:NewState(lite3DCanvas);
			self.commandManager:AddCommandToHistory(self.commandChangeState);
		end
		self.commandChangeState=nil;	
	end
	Map3DSystem.App.Inventor.GlobalInventor.commandCallBack();
end	
function PointerTool:OnLeftMouseMove(lite3DCanvas,msg)
	if(not lite3DCanvas or not msg)then return; end
	if(msg.mouse_button ~= "left")then return; end
	if(not self.press)then
		return;
	end	
	local mouse_x = msg.mouse_x;
	local mouse_y = msg.mouse_y;	
	
	local point = {x = mouse_x,y = mouse_y};
	local oldPoint =  self.lastPoint;
	-- find difference between previous and current position
	--local dx = mouse_x - self.lastPoint.x;
	--local dy = mouse_y - self.lastPoint.y;
	if( not commonlib.partialcompare(mouse_x, self.lastPoint.x, 0.1) or
		not commonlib.partialcompare(mouse_y, self.lastPoint.y, 0.1) ) then
		self.wasMove = true;	
	end
	self.lastPoint["x"] = mouse_x;
	self.lastPoint["y"] = mouse_y;
	-- resize
	if(self.selectMode == "Size" and self.resizedObject)then
		point=self.resizedObject:globalToLocal(point);
        self.resizedObject:MoveHandleTo(point, self.resizedObjectHandle);
	end
	-- move
	if(self.selectMode == "Move")then
		local point3D;			
		local k,v;
		for k,v in ipairs(lite3DCanvas.Nodes) do
			local node = v;
			if(node:GetPicking())then
				local pt = ParaScene.MousePick(70, "point"); -- pick a object
				if(pt:IsValid())then
					point3D = {};
					point3D.x, point3D.y, point3D.z = pt:GetPosition();
					break;
				end
			end
		end
		if(not point3D) then return; end
		local d_point3D = {};
		d_point3D.x = point3D.x - self.lastPoint3D.x;
		d_point3D.y = point3D.y - self.lastPoint3D.y;
		d_point3D.z = point3D.z - self.lastPoint3D.z;
		for k,v in ipairs(lite3DCanvas.Nodes) do
			local node = v;
			if(node and node:GetSelected())then
				node:Move(d_point3D);			
			end
		end
		self.lastPoint3D = point3D;
	end
	-- draw area
	if(self.selectMode == "NetSelection")then
		Map3DSystem.App.Inventor.GlobalInventor.DrawArea(self.startPoint,self.lastPoint);
		return;
	end
end