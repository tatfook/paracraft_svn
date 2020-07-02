--[[
Title: SoundPanelPage 
Author(s): Leio
Date: 2008/10/27
Note: 
Desc: 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/PropertyPanel/SoundPanelPage.lua");
-------------------------------------------------------
--]]
local SoundPanelPage = {
	name = "SoundPanelPage_instance",
}
commonlib.setfield("Map3DSystem.Movie.SoundPanelPage",SoundPanelPage);
function SoundPanelPage.OnInit()
	local self = SoundPanelPage;
	self.page = document:GetPageCtrl();	
end
function SoundPanelPage.DataBind(bindTarget)
	local self = SoundPanelPage;
	if(not bindTarget or not self.page)then return; end
	
	self.bindTarget = bindTarget;
	self.bindingContext = commonlib.BindingContext:new();	
	self.bindingContext:AddBinding(bindTarget, "Path", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "_txt")
		
	self.bindingContext:UpdateDataToControls();
end
function SoundPanelPage.OnUpdateProperty()
	local self = SoundPanelPage;
	if(not self.bindTarget or not self.page or not self.bindingContext)then return; end	
	local _txt = self.page:FindControl("_txt");
	if(_txt)then
		_txt = _txt:GetText();
		_txt = string.gsub(_txt, "\r\n", "");
		self.bindTarget.Path = _txt;
	end
end