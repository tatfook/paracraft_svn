--[[
Title: ControlPanelPage 
Author(s): Leio
Date: 2008/10/30
Note: 
Desc: 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/PropertyPanel/ControlPanelPage.lua");
-------------------------------------------------------
--]]
local ControlPanelPage = {
	name = "ActorPanelPage_instance",
}
commonlib.setfield("Map3DSystem.Movie.ControlPanelPage",ControlPanelPage);
function ControlPanelPage.OnInit()
	local self = ControlPanelPage;
	self.page = document:GetPageCtrl();	
end
function ControlPanelPage.OnChangePosX(value)
	local self = ControlPanelPage;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.bindTarget.X = value;
	self.bindTarget:Update();
end

function ControlPanelPage.OnChangePosY(value)
	local self = ControlPanelPage;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.bindTarget.Y = value;
	self.bindTarget:Update();
end

function ControlPanelPage.OnScaleX(value)
	local self = ControlPanelPage;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.bindTarget.ScaleX = value;
	self.bindTarget:Update();
end
function ControlPanelPage.OnScaleY(value)
	local self = ControlPanelPage;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.bindTarget.ScaleY = value;
	self.bindTarget:Update();
end
function ControlPanelPage.OnRot(value)
	local self = ControlPanelPage;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.bindTarget.Rot = value;
	self.bindTarget:Update();
end
function ControlPanelPage.OnAlpha(value)
	local self = ControlPanelPage;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.bindTarget.Alpha = value;
	self.bindTarget:Update();
end
function ControlPanelPage.OnVisible(bChecked, mcmlNode)    
	local self = ControlPanelPage;
	if(not self.bindingContext or not self.bindTarget)then return; end
	self.bindTarget.Visible = bChecked;
	self.bindTarget:Update();
end
function ControlPanelPage.DataBind(bindTarget)
	local self = ControlPanelPage;
	if(not bindTarget or not self.page)then return; end
	
	self.bindTarget = bindTarget;

	self.bindingContext = commonlib.BindingContext:new();	
	self.bindingContext:AddBinding(bindTarget, "X", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "pos_x")
	self.bindingContext:AddBinding(bindTarget, "Y", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "pos_y")
	self.bindingContext:AddBinding(bindTarget, "ScaleX", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "scalex")
	self.bindingContext:AddBinding(bindTarget, "ScaleX", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "scalex")
	self.bindingContext:AddBinding(bindTarget, "Rot", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "rot")
	self.bindingContext:AddBinding(bindTarget, "Alpha", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "alpha")
	self.bindingContext:AddBinding(bindTarget, "Bg", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "bg_txt")
	self.bindingContext:AddBinding(bindTarget, "Text", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "info_txt")

	self.bindingContext:UpdateDataToControls();
end
function ControlPanelPage.OnUpdateProperty()
	local self = ControlPanelPage;
	if(not self.bindTarget or not self.page or not self.bindingContext)then return; end	
	local _txt = self.page:FindControl("bg_txt");
	if(_txt)then
		_txt = _txt:GetText();
		self.bindTarget.Bg = _txt;
	end	
	_txt = self.page:FindControl("Info_txt");
	if(_txt)then
		_txt = _txt:GetText();
		self.bindTarget.Text = _txt;
	end	
end