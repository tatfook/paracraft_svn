--[[
Title: CaptionPanelPage 
Author(s): Leio
Date: 2008/10/27
Note: 
Desc: 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/PropertyPanel/CaptionPanelPage.lua");
-------------------------------------------------------
--]]
local CaptionPanelPage = {
	name = "CameraPanelPage_instance",
}
commonlib.setfield("Map3DSystem.Movie.CaptionPanelPage",CaptionPanelPage);
function CaptionPanelPage.OnInit()
	local self = CaptionPanelPage;
	self.page = document:GetPageCtrl();	
end
function CaptionPanelPage.DataBind(bindTarget)
	local self = CaptionPanelPage;
	if(not bindTarget or not self.page)then return; end
	
	self.bindTarget = bindTarget;
	self.bindingContext = commonlib.BindingContext:new();	
	self.bindingContext:AddBinding(bindTarget, "Text", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "_txt")
		
	self.bindingContext:UpdateDataToControls();
end
function CaptionPanelPage.OnUpdateProperty()
	local self = CaptionPanelPage;
	if(not self.bindTarget or not self.page or not self.bindingContext)then return; end	
	local _txt = self.page:FindControl("_txt");
	if(_txt)then
		_txt = _txt:GetText();
		self.bindTarget.Text = _txt;
	end	
	--self.bindingContext:UpdateDataToControls();
end