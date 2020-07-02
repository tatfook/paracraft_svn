--[[
Title: ObjectPropertyPanel
Author(s): Leio
Date: 2008/12/20
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Gears/ObjectPropertyPanel.lua");
------------------------------------------------------------
]]
local ObjectPropertyPanel = {
	isRelative = true,
	center_x = 0,
	center_y = 0,
	center_z = 0,
} 
commonlib.setfield("Map3DSystem.App.Inventor.Gears.ObjectPropertyPanel",ObjectPropertyPanel);
function ObjectPropertyPanel.OnInit()
	local self = ObjectPropertyPanel;
	self.page = document:GetPageCtrl();	
	self.isRelative = true;
	self.center_x = 0;
	self.center_y = 0;
	self.center_z = 0;
end
function ObjectPropertyPanel.OnShowModel()
	local self = ObjectPropertyPanel;
	local canvasCtl = self.page:FindControl("modelCanvas");
	if(canvasCtl and self.bindTarget) then
		local params = self.bindTarget:GetEntityParams();
		canvasCtl:ShowModel(params);
	end
end
function ObjectPropertyPanel.OnChangePosX(value)
	local self = ObjectPropertyPanel;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	if(self.params.x == value)then return end
	self.params.x = value;
	self.OnUpdateProperty();
end

function ObjectPropertyPanel.OnChangePosY(value)
	local self = ObjectPropertyPanel;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	if(self.params.y == value)then return end
	self.params.y = value;
	self.OnUpdateProperty();
end

function ObjectPropertyPanel.OnChangePosZ(value)
	local self = ObjectPropertyPanel;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	if(self.params.z == value)then return end
	self.params.z = value;
	self.OnUpdateProperty();
end

function ObjectPropertyPanel.OnScaling(value)
	local self = ObjectPropertyPanel;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	if(self.params.scaling == value)then return end
	self.params.scaling = value;
	self.OnUpdateProperty();
end
function ObjectPropertyPanel.OnFacing(value)
	local self = ObjectPropertyPanel;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	if(self.params.facing == value)then return end
	self.params.facing = value;
	self.OnUpdateProperty();
end
function ObjectPropertyPanel.OnChangeRotX(value)
	local self = ObjectPropertyPanel;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.params.rotation.x= value;
end
function ObjectPropertyPanel.OnChangeRotY(value)
	local self = ObjectPropertyPanel;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.params.rotation.y= value;
end
function ObjectPropertyPanel.OnChangeRotZ(value)
	local self = ObjectPropertyPanel;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.params.rotation.z= value;
end
function ObjectPropertyPanel.OnChangeRotW(value)
	local self = ObjectPropertyPanel;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.params.rotation.w= value;
end
function ObjectPropertyPanel.OnCenterX(value)
	local self = ObjectPropertyPanel;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.center_x = value;
end
function ObjectPropertyPanel.OnCenterY(value)
	local self = ObjectPropertyPanel;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.center_y = value;
end
function ObjectPropertyPanel.OnCenterZ(value)
	local self = ObjectPropertyPanel;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.center_z = value;
end

function ObjectPropertyPanel.OnRelative(bChecked, mcmlNode)    
	local self = ObjectPropertyPanel;
	if(not self.bindingContext or not self.bindTarget)then return; end
	self.isRelative = bChecked;
end
function ObjectPropertyPanel.OnTabClick()
	local self = ObjectPropertyPanel;
	self.DataBind(self.bindTarget)
end
function ObjectPropertyPanel.DataBind(bindTarget)
	local self = ObjectPropertyPanel;
	if(not bindTarget or not self.page)then return; end
	local property = bindTarget.Property;
	local params	= bindTarget:GetEntityParams();
	if(not params)then return end
	params = commonlib.deepcopy(params);
	self.params = params
	self.center_x,self.center_y,self.center_z = ParaScene.GetPlayer():GetPosition();
	self.bindTarget = bindTarget;
		self.bindingContext = commonlib.BindingContext:new();	
		self.bindingContext:AddBinding(params, "x", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "pos_x")
		self.bindingContext:AddBinding(params, "y", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "pos_y")
		self.bindingContext:AddBinding(params, "z", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "pos_z")
		self.bindingContext:AddBinding(params, "scaling", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "scaling")
		self.bindingContext:AddBinding(params, "facing", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "facing")
		
		self.bindingContext:AddBinding(params, "rotation.x", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "rot_x")
		self.bindingContext:AddBinding(params, "rotation.y", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "rot_y")
		self.bindingContext:AddBinding(params, "rotation.z", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "rot_z")	
		self.bindingContext:AddBinding(params, "rotation.w", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "rot_w")	
		
		self.bindingContext:AddBinding(self, "center_x", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "center_x")	
		self.bindingContext:AddBinding(self, "center_y", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "center_y")	
		self.bindingContext:AddBinding(self, "center_z", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "center_z")	
		
		
	self.bindingContext:UpdateDataToControls();
	
	self.OnShowModel()
end
function ObjectPropertyPanel.OnUpdateProperty()    
	local self = ObjectPropertyPanel;
	if(not self.bindingContext or not self.bindTarget)then return; end
	local commandManager = Map3DSystem.App.Inventor.GlobalInventor.commandManager;
	local lite3DCanvas = Map3DSystem.App.Inventor.GlobalInventor.Lite3DCanvas;
	local commandChangeState
	if(lite3DCanvas)then
		commandChangeState=Map3DSystem.App.Inventor.CommandChangeState:new();
		commandChangeState:Initialization(lite3DCanvas);
	end
	
	-- update property
	--self.bindTarget:SetPosition(self.params.x, self.params.y, self.params.z);
	self.bindTarget:SetScaling(self.params.scaling );
	self.bindTarget:SetFacing(self.params.facing);
	
	if(commandChangeState and commandManager)then
		commandChangeState:NewState(lite3DCanvas);
		commandManager:AddCommandToHistory(commandChangeState);
	end
	
end
--function ObjectPropertyPanel.DeltaParams()
	--local self = ObjectPropertyPanel;
	--local params = {};
	--local bindTarget_params = self.bindTarget:GetParams();
	--params.x = self.params.x - bindTarget_params.x;
	--params.y = self.params.y - bindTarget_params.y;
	--params.z = self.params.z - bindTarget_params.z;
	--
	--params.scaling = self.params.scaling - bindTarget_params.scaling;
	--params.facing = self.params.facing - bindTarget_params.facing;
	--
	--return params;
--end
function ObjectPropertyPanel.OnUpdateProperty_Rotation() 
	local self = ObjectPropertyPanel;
	if(not self.bindingContext or not self.bindTarget)then return; end
	local commandManager = Map3DSystem.App.Inventor.GlobalInventor.commandManager;
	local lite3DCanvas = Map3DSystem.App.Inventor.GlobalInventor.Lite3DCanvas;
	local commandChangeState
	if(lite3DCanvas)then
		commandChangeState=Map3DSystem.App.Inventor.CommandChangeState:new();
		commandChangeState:Initialization(lite3DCanvas);
	end
	
	local bindTarget_params = self.bindTarget:GetEntityParams();
	local delta_x = self.params.rotation.x - bindTarget_params.rotation.x;
	local delta_y = self.params.rotation.y - bindTarget_params.rotation.y;
	local delta_z = self.params.rotation.z - bindTarget_params.rotation.z;
	self.bindTarget:vec3RotateByPoint(self.center_x,self.center_y,self.center_z, 
									delta_x,delta_y,delta_z);
	
	if(commandChangeState and commandManager)then
		commandChangeState:NewState(lite3DCanvas);
		commandManager:AddCommandToHistory(commandChangeState);
	end
	
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			name="ObjectPropertyPanel", app_key = MyCompany.Apps.Inventor.app.app_key, bShow = false,bDestroy = true,});
			
end