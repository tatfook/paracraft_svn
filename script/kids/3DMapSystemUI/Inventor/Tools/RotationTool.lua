--[[
Title: RotationTool
Author(s): Leio
Date: 2008/12/1
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Tools/RotationTool.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Util/GlobalInventor.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Command/CommandChangeState.lua");
local RotationTool = commonlib.inherit(Map3DSystem.App.Inventor.IEntityTool,{
	lastPoint = nil,
	commandManager = nil,
	press = nil,
	wasMove = nil,
	commandChangeState = nil,
});  
commonlib.setfield("Map3DSystem.App.Inventor.RotationTool",RotationTool);
function RotationTool:Initialization(commandManager,commandManagerEnabled)
	self.commandManager=commandManager;
	self.commandManagerEnabled = commandManagerEnabled;
	self.press = false;
	self.wasMove = false;
	self.lastPoint = {x = 0,y = 0};
	self.startPoint = {x = 0,y = 0};	

end
function RotationTool:OnLeftMouseDown(lite3DCanvas,msg)
	if(not lite3DCanvas or not msg)then return; end
	if(msg.mouse_button ~= "left")then return; end
	self.press = true;
	self.wasMove = false;
	local mouse_x = msg.mouse_x;
	local mouse_y = msg.mouse_y;
	
	self.commandChangeState=Map3DSystem.App.Inventor.CommandChangeState:new();
	self.commandChangeState:Initialization(lite3DCanvas);
	
    self.lastPoint.x = mouse_x;
    self.lastPoint.y = mouse_y;
    self.startPoint.x = mouse_x;
    self.startPoint.y = mouse_y;
end
function RotationTool:OnLeftMouseUp(lite3DCanvas,msg)
	if(not lite3DCanvas or not msg)then return; end
	if(msg.mouse_button ~= "left")then return; end
	local mouse_x = msg.mouse_x;
	local mouse_y = msg.mouse_y;
	self.press = false;
	
	if(self.wasMove and self.commandChangeState ~= nil)then
		lite3DCanvas:ResetRotation();
		if(self.commandManagerEnabled)then
			self.commandChangeState:NewState(lite3DCanvas);
			self.commandManager:AddCommandToHistory(self.commandChangeState);
		end
		self.commandChangeState=nil;	
	end
end	
function RotationTool:OnLeftMouseMove(lite3DCanvas,msg)
	if(not lite3DCanvas or not msg)then return; end
	if(msg.mouse_button ~= "left")then return; end
	if(not self.press)then
		return;
	end	
	local mouse_x = msg.mouse_x;
	local mouse_y = msg.mouse_y;	
	
	local dx = mouse_x - self.lastPoint.x;
	local dy = mouse_y - self.lastPoint.y;
	local point3D = {x = 0, y = dx, z = 0};
	if( not commonlib.partialcompare(mouse_x, self.lastPoint.x, 0.1) or
		not commonlib.partialcompare(mouse_y, self.lastPoint.y, 0.1) ) then
		self.wasMove = true;	
	end
	if(not self.wasMove)then return end
	for k,v in ipairs(lite3DCanvas.Nodes) do
			local node = v;
			if(node and node:GetSelected())then
				node:Rotate(point3D);			
			end
	end
		
	self.lastPoint.x = mouse_x;
    self.lastPoint.y = mouse_y;
end