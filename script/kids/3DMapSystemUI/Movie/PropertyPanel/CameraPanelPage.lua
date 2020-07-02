--[[
Title: CameraPanelPage 
Author(s): Leio
Date: 2008/10/25
Note: 
Desc: 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/PropertyPanel/CameraPanelPage.lua");
-------------------------------------------------------
--]]
local CameraPanelPage = {
	name = "CameraPanelPage_instance",
}
commonlib.setfield("Map3DSystem.Movie.CameraPanelPage",CameraPanelPage);
function CameraPanelPage.OnInit()
	local self = CameraPanelPage;
	self.page = document:GetPageCtrl();	
end
function CameraPanelPage.OnChangePosX(value)
	local self = CameraPanelPage;
	if(not value or not self.bindingContext or not self.cameraTarget)then return; end
	self.cameraTarget.X = value;
	self.cameraTarget:Update();
end

function CameraPanelPage.OnChangePosY(value)
	local self = CameraPanelPage;
	if(not value or not self.bindingContext or not self.cameraTarget)then return; end
	self.cameraTarget.Y = value;
	self.cameraTarget:Update();
end

function CameraPanelPage.OnChangePosZ(value)
	local self = CameraPanelPage;
	if(not value or not self.bindingContext or not self.cameraTarget)then return; end
	self.cameraTarget.Z = value;
	self.cameraTarget:Update();
end

function CameraPanelPage.OnCamobjDist(value)
	local self = CameraPanelPage;
	if(not value or not self.bindingContext or not self.cameraTarget)then return; end
	self.cameraTarget.Dist = value;
	self.cameraTarget:Update();
end
function CameraPanelPage.OnLifeupAngle(value)
	local self = CameraPanelPage;
	if(not value or not self.bindingContext or not self.cameraTarget)then return; end
	self.cameraTarget.Angle = value;
	self.cameraTarget:Update();
end
function CameraPanelPage.OnCameraRotY(value)
	local self = CameraPanelPage;
	if(not value or not self.bindingContext or not self.cameraTarget)then return; end
	self.cameraTarget.RotY = value;
	self.cameraTarget:Update();
end
function CameraPanelPage.DataBind(cameraTarget)
	local self = CameraPanelPage;
	if(not cameraTarget or not self.page)then return; end
	
	self.cameraTarget = cameraTarget;

		self.bindingContext = commonlib.BindingContext:new();	
		self.bindingContext:AddBinding(cameraTarget, "X", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "pos_x")
		self.bindingContext:AddBinding(cameraTarget, "Y", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "pos_y")
		self.bindingContext:AddBinding(cameraTarget, "Z", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "pos_z")
		self.bindingContext:AddBinding(cameraTarget, "Dist", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "dist")
		self.bindingContext:AddBinding(cameraTarget, "Angle", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "angle")
		self.bindingContext:AddBinding(cameraTarget, "RotY", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "rot_y")

	self.bindingContext:UpdateDataToControls();
end
function CameraPanelPage.OnGetProperty()
	local self = CameraPanelPage;
	if(not self.cameraTarget or not self.page or not self.bindingContext)then return; end
	self.cameraTarget:GetDefaultProperty();
	self.bindingContext:UpdateDataToControls();
end