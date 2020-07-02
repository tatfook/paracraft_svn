--[[
Title: TransformPanel
Author(s): Leio
Date: 2008/12/20
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Gears/TransformPanel.lua");
------------------------------------------------------------
]]
local TransformPanel = {
	isRelative = true,
	center_x = 0,
	center_y = 0,
	center_z = 0,
} 
commonlib.setfield("Map3DSystem.App.Inventor.Gears.TransformPanel",TransformPanel);
function TransformPanel.OnInit()
	local self = TransformPanel;
	self.page = document:GetPageCtrl();	
	self.isRelative = true;
	self.center_x = 0;
	self.center_y = 0;
	self.center_z = 0;

	
end
function TransformPanel.OnUpdateZones()
	local self = TransformPanel;
	if(not self.bindingContext or not self.bindTarget)then return; end

	local value = self.page:GetUIValue("homeZoneName");
	if(value)then
		self.bindTarget:SetHomeZone(value)
		self.bindTarget:UpdateEntityParams();
	end
end
function TransformPanel.OnSelectHomeZone()
	local self = TransformPanel;
	Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_PickObject, 
		filter = "262144", -- "262144:zone", "524288:portal"
		callbackFunc = function (obj)
			if(obj) then
				self.page:SetUIValue("homeZoneName", obj.name);
				TransformPanel.OnUpdateZones();
			end
		end, });
end
function TransformPanel.OnShowModel()
	local self = TransformPanel;
	local canvasCtl = self.page:FindControl("modelCanvas");
	if(canvasCtl and self.bindTarget and self.bindTarget.GetEntity) then
		local obj = self.bindTarget:GetEntity();
		if(obj)then
			local params = ObjEditor.GetObjectParams(obj);
			canvasCtl:ShowModel(params);
		end
	end
end
function TransformPanel.OnChangePosX(value)
	local self = TransformPanel;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	if(self.params.x == value)then return end
	self.params.x = value;
	self.OnUpdateProperty();
end

function TransformPanel.OnChangePosY(value)
	local self = TransformPanel;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	if(self.params.y == value)then return end
	self.params.y = value;
	self.OnUpdateProperty();
end

function TransformPanel.OnChangePosZ(value)
	local self = TransformPanel;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	if(self.params.z == value)then return end
	self.params.z = value;
	self.OnUpdateProperty();
end

function TransformPanel.OnScaling(value)
	local self = TransformPanel;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	if(self.params.scaling == value)then return end
	self.params.scaling = value;
	self.OnUpdateProperty();
end
function TransformPanel.OnFacing(value)
	local self = TransformPanel;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	if(self.params.facing == value)then return end
	self.params.facing = value;
	self.OnUpdateProperty();
end
function TransformPanel.OnChangeRotX(value)
	local self = TransformPanel;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.params.rotation.x= value;
end
function TransformPanel.OnChangeRotY(value)
	local self = TransformPanel;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.params.rotation.y= value;
end
function TransformPanel.OnChangeRotZ(value)
	local self = TransformPanel;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.params.rotation.z= value;
end
function TransformPanel.OnCenterX(value)
	local self = TransformPanel;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.center_x = value;
end
function TransformPanel.OnCenterY(value)
	local self = TransformPanel;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.center_y = value;
end
function TransformPanel.OnCenterZ(value)
	local self = TransformPanel;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.center_z = value;
end
function TransformPanel.OnRelative(bChecked, mcmlNode)    
	local self = TransformPanel;
	if(not self.bindingContext or not self.bindTarget)then return; end
	self.isRelative = bChecked;
end
function TransformPanel.OnTabClick()
	local self = TransformPanel;
	self.DataBind(self.bindTarget)
end
function TransformPanel.DataBind(bindTarget)
	local self = TransformPanel;
	if(not bindTarget or not self.page)then return; end
	local property = bindTarget.Property;
	local params;
	if(property == "group")then
		params = bindTarget:GetChild(1):GetParams();
	else
		params = bindTarget:GetParams();
	end
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
		
		self.bindingContext:AddBinding(self, "center_x", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "center_x")	
		self.bindingContext:AddBinding(self, "center_y", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "center_y")	
		self.bindingContext:AddBinding(self, "center_z", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "center_z")	
		
		self.bindingContext:AddBinding(params, "homezone", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "homeZoneName")
		
	self.bindingContext:UpdateDataToControls();
	
	self.OnShowModel()
end
function TransformPanel.OnUpdateProperty()    
	local self = TransformPanel;
	if(not self.bindingContext or not self.bindTarget)then return; end
	local commandManager = Map3DSystem.App.Inventor.GlobalInventor.commandManager;
	local lite3DCanvas = Map3DSystem.App.Inventor.GlobalInventor.Lite3DCanvas;
	local commandChangeState
	if(lite3DCanvas)then
		commandChangeState=Map3DSystem.App.Inventor.CommandChangeState:new();
		commandChangeState:Initialization(lite3DCanvas);
	end
	
	local dletaParams = self.DeltaParams();
	-- update property
	self.bindTarget:SetPositionDelta({x = dletaParams.x, y = dletaParams.y, z = dletaParams.z});
	self.bindTarget:SetScaleDelta(dletaParams.scaling );
	self.bindTarget:SetFacingDelta(dletaParams.facing );
	self.bindTarget:UpdateEntityParams();
	if(commandChangeState)then
		commandChangeState:NewState(lite3DCanvas);
		commandManager:AddCommandToHistory(commandChangeState);
	end
	
end
function TransformPanel.DeltaParams()
	local self = TransformPanel;
	local params = {};
	local bindTarget_params = self.bindTarget:GetParams();
	params.x = self.params.x - bindTarget_params.x;
	params.y = self.params.y - bindTarget_params.y;
	params.z = self.params.z - bindTarget_params.z;
	
	params.scaling = self.params.scaling - bindTarget_params.scaling;
	params.facing = self.params.facing - bindTarget_params.facing;
	
	return params;
end
function TransformPanel.OnUpdateProperty_Rotation() 
	local self = TransformPanel;
	if(not self.bindingContext or not self.bindTarget)then return; end
	local commandManager = Map3DSystem.App.Inventor.GlobalInventor.commandManager;
	local lite3DCanvas = Map3DSystem.App.Inventor.GlobalInventor.Lite3DCanvas;
	local commandChangeState
	if(lite3DCanvas)then
		commandChangeState=Map3DSystem.App.Inventor.CommandChangeState:new();
		commandChangeState:Initialization(lite3DCanvas);
	end
	
	local bindTarget_params = self.bindTarget:GetParams();
	local delta_x = self.params.rotation.x - bindTarget_params.rotation.x;
	local delta_y = self.params.rotation.y - bindTarget_params.rotation.y;
	local delta_z = self.params.rotation.z - bindTarget_params.rotation.z;
	-- update property
	self.isRelative = false;
	if(self.isRelative)then
		self.bindTarget:SetRotate({x = delta_x,y = delta_y,z = delta_z});
	else
		
		self.bindTarget:vec3RotateByPoint(self.center_x,self.center_y,self.center_z, 
									delta_x,delta_y,delta_z);
	end
	self.bindTarget:UpdateEntityParams();
	if(commandChangeState)then
		commandChangeState:NewState(lite3DCanvas);
		commandManager:AddCommandToHistory(commandChangeState);
	end
	
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			name="TransformPanel", app_key = MyCompany.Apps.Inventor.app.app_key, bShow = false,bDestroy = true,});
			
end