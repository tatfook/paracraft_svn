--[[
Title: PlantPanelPage 
Author(s): Leio
Date: 2008/10/30
Note: 
Desc: 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/PropertyPanel/PlantPanelPage.lua");
-------------------------------------------------------
--]]
local PlantPanelPage = {
	name = "ActorPanelPage_instance",
}
commonlib.setfield("Map3DSystem.Movie.PlantPanelPage",PlantPanelPage);
function PlantPanelPage.OnInit()
	local self = PlantPanelPage;
	self.page = document:GetPageCtrl();	
end
function PlantPanelPage.OnChangePosX(value)
	local self = PlantPanelPage;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.bindTarget.X = value;
	self.bindTarget:Update();
end

function PlantPanelPage.OnChangePosY(value)
	local self = PlantPanelPage;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.bindTarget.Y = value;
	self.bindTarget:Update();
end

function PlantPanelPage.OnChangePosZ(value)
	local self = PlantPanelPage;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.bindTarget.Z = value;
	self.bindTarget:Update();
end

function PlantPanelPage.OnScaling(value)
	local self = PlantPanelPage;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.bindTarget.Scaling = value;
	self.bindTarget:Update();
end
function PlantPanelPage.OnChangeRotX(value)
	local self = PlantPanelPage;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.bindTarget.Rot_X = value;
	self.bindTarget:Update();
end
function PlantPanelPage.OnChangeRotY(value)
	local self = PlantPanelPage;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.bindTarget.Rot_Y = value;
	self.bindTarget:Update();
end
function PlantPanelPage.OnChangeRotZ(value)
	local self = PlantPanelPage;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.bindTarget.Rot_Z = value;
	self.bindTarget:Update();
end
function PlantPanelPage.OnVisible(bChecked, mcmlNode)    
	local self = PlantPanelPage;
	if(not self.bindingContext or not self.bindTarget)then return; end
	self.bindTarget.Visible = bChecked;
	self.bindTarget:Update();
end
function PlantPanelPage.DataBind(bindTarget)
	local self = PlantPanelPage;
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
		self.page:SetUIValue("isVisible",bindTarget.Visible);
	self.bindingContext:UpdateDataToControls();
end
function PlantPanelPage.OnGetProperty()
	local self = PlantPanelPage;
	if(not self.bindTarget or not self.page or not self.bindingContext)then return; end
	--local objParam = Map3DSystem.obj.GetObjectParams("selection");
	--TODO: how to get a seleted plant
	local object = ParaScene.GetPlayer();
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