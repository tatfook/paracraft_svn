--[[
Title: BuildingPanelPage 
Author(s): Leio
Date: 2008/10/30
Note: 
Desc: 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/PropertyPanel/BuildingPanelPage.lua");
-------------------------------------------------------
--]]
local BuildingPanelPage = {
	name = "ActorPanelPage_instance",
}
commonlib.setfield("Map3DSystem.Movie.BuildingPanelPage",BuildingPanelPage);
function BuildingPanelPage.OnInit()
	local self = BuildingPanelPage;
	self.page = document:GetPageCtrl();	
end
function BuildingPanelPage.OnChangePosX(value)
	local self = BuildingPanelPage;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.bindTarget.X = value;
	self.bindTarget:Update();
end

function BuildingPanelPage.OnChangePosY(value)
	local self = BuildingPanelPage;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.bindTarget.Y = value;
	self.bindTarget:Update();
end

function BuildingPanelPage.OnChangePosZ(value)
	local self = BuildingPanelPage;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.bindTarget.Z = value;
	self.bindTarget:Update();
end

function BuildingPanelPage.OnScaling(value)
	local self = BuildingPanelPage;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.bindTarget.Scaling = value;
	self.bindTarget:Update();
end
function BuildingPanelPage.OnChangeRotX(value)
	local self = BuildingPanelPage;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.bindTarget.Rot_X = value;
	self.bindTarget:Update();
end
function BuildingPanelPage.OnChangeRotY(value)
	local self = BuildingPanelPage;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.bindTarget.Rot_Y = value;
	self.bindTarget:Update();
end
function BuildingPanelPage.OnChangeRotZ(value)
	local self = BuildingPanelPage;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.bindTarget.Rot_Z = value;
	self.bindTarget:Update();
end
function BuildingPanelPage.OnVisible(bChecked, mcmlNode)    
	local self = BuildingPanelPage;
	if(not self.bindingContext or not self.bindTarget)then return; end
	self.bindTarget.Visible = bChecked;
	self.bindTarget:Update();
end
function BuildingPanelPage.DataBind(bindTarget)
	local self = BuildingPanelPage;
	if(not bindTarget or not self.page)then return; end
	
	self.bindTarget = bindTarget;

		self.bindingContext = commonlib.BindingContext:new();	
		self.bindingContext:AddBinding(bindTarget, "X", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "pos_x")
		self.bindingContext:AddBinding(bindTarget, "Y", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "pos_y")
		self.bindingContext:AddBinding(bindTarget, "Z", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "pos_z")
		self.bindingContext:AddBinding(bindTarget, "Scaling", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "scaling")
		self.bindingContext:AddBinding(bindTarget, "Rot_X", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "rot_x")
		self.bindingContext:AddBinding(bindTarget, "Rot_Y", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "rot_y")
		self.bindingContext:AddBinding(bindTarget, "Rot_Z", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "rot_z")		
		local ctl = self.page:FindControl("isVisible");
		if(ctl)then
			--commonlib.echo(ctl.background);
		end
		self.page:SetUIValue("isVisible",bindTarget.Visible);
		
	self.bindingContext:UpdateDataToControls();
end
function BuildingPanelPage.OnGetProperty()
	local self = BuildingPanelPage;
	if(not self.bindTarget or not self.page or not self.bindingContext)then return; end
	--TODO: how to get a seleted building
	--local object = ParaScene.GetPlayer();
	local objParam = ObjEditor.GetObjectParams(object);
	if(objParam)then
		local __name = self.bindTarget.Name or self.bindTarget:GetName();
		if(__name == nil or __name == "")then
			local name = objParam.name;
			self.bindTarget:UpdatParentFrames(name,name);
			self.bindTarget:GetDefaultProperty(objParam)
			
			-- import static asset node
			if(Map3DSystem.Movie.MovieListPage.SelectedMovieManager)then
				local moviescript = Map3DSystem.Movie.MovieListPage.SelectedMovieManager.moviescript;
				if(moviescript)then
					local keyFrames = self.bindTarget:GetParentKeyFrames()
					if(keyFrames and keyFrames["ParentMcmlNode"])then 
						local id = keyFrames["ParentMcmlNode"]:GetNumber("id");
						if(id)then
							local staticAssetNode = moviescript:ConstructStaticAssetNode("pe:movie-building",id);
							if(staticAssetNode)then
								-- staticAssetNode[1] is a table
								staticAssetNode[1] = objParam;
							end
						end
					end
				end
			end
			
		else
			if(self.bindTarget.Name == objParam.name)then
				self.bindTarget:GetDefaultProperty(objParam)
			end
		end
		self.bindingContext:UpdateDataToControls();
	end
end