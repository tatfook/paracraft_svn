--[[
Title: ActorPanelPage 
Author(s): Leio
Date: 2008/10/30
Note: 
Desc: 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Movie/PropertyPanel/ActorPanelPage.lua");
-------------------------------------------------------
--]]
local ActorPanelPage = {
	name = "ActorPanelPage_instance",
}
commonlib.setfield("Map3DSystem.Movie.ActorPanelPage",ActorPanelPage);
function ActorPanelPage.OnInit()
	local self = ActorPanelPage;
	self.page = document:GetPageCtrl();	
end
function ActorPanelPage.OnFacing(value)
	local self = ActorPanelPage;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.bindTarget.Facing= value;
	self.bindTarget:Update();
end
function ActorPanelPage.OnChangePosX(value)
	local self = ActorPanelPage;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.bindTarget.X = value;
	self.bindTarget:Update();
end

function ActorPanelPage.OnChangePosY(value)
	local self = ActorPanelPage;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.bindTarget.Y = value;
	self.bindTarget:Update();
end

function ActorPanelPage.OnChangePosZ(value)
	local self = ActorPanelPage;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.bindTarget.Z = value;
	self.bindTarget:Update();
end

function ActorPanelPage.OnScaling(value)
	local self = ActorPanelPage;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.bindTarget.Scaling = value;
	self.bindTarget:Update();
end
function ActorPanelPage.OnChangeRotX(value)
	local self = ActorPanelPage;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.bindTarget.Rot_X = value;
	self.bindTarget:Update();
end
function ActorPanelPage.OnChangeRotY(value)
	local self = ActorPanelPage;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.bindTarget.Rot_Y = value;
	self.bindTarget:Update();
end
function ActorPanelPage.OnChangeRotZ(value)
	local self = ActorPanelPage;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.bindTarget.Rot_Z = value;
	self.bindTarget:Update();
end
function ActorPanelPage.OnChangeRunToX(value)
	local self = ActorPanelPage;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.bindTarget.RunTo_X = value;
	self.bindTarget:Update();
end
function ActorPanelPage.OnChangeRunToY(value)
	local self = ActorPanelPage;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.bindTarget.RunTo_Y = value;
	self.bindTarget:Update();
end
function ActorPanelPage.OnChangeRunToZ(value)
	local self = ActorPanelPage;
	if(not value or not self.bindingContext or not self.bindTarget)then return; end
	self.bindTarget.RunTo_Z = value;
	self.bindTarget:Update();
end
function ActorPanelPage.OnDoubleClickAnimFile(name, filepath)
	ActorPanelPage.PlayAnimFile(filepath);
end
function ActorPanelPage.PlayAnimFile(filepath)
	if(filepath == nil or filepath == "") then
		_guihelper.MessageBox("请选择一个文件");
	elseif(not ParaIO.DoesFileExist(filepath, true)) then
		_guihelper.MessageBox(string.format("文件 %s 不存在", filepath));
	else
		local self = ActorPanelPage;
		if(not self.bindingContext or not self.bindTarget)then return; end
		local name = self.bindTarget.Name or self.bindTarget:GetName();
		if(name)then
			self.bindTarget.Animation = filepath;			
			local object = ParaScene.GetCharacter(name);
			if(object and object:IsValid())then
				Map3DSystem.Animation.PlayAnimationFile(self.bindTarget.Animation, object);
				-- this is a discrete property so don't need to update by self.bindTarget:Update()
			end
		end
	end	
end
function ActorPanelPage.OnUpdateProperty()
	local self = ActorPanelPage;
	if(not self.bindTarget or not self.page or not self.bindingContext)then return; end	
	local _txt = self.page:FindControl("_txt");
	if(_txt)then
		_txt = _txt:GetText();
		self.bindTarget.Dialog = _txt;
		headon_speech.Speek(self.bindTarget.Name, self.bindTarget.Dialog, math.random(4));
		-- this is a discrete property so don't need to update by self.bindTarget
	end	
end
function ActorPanelPage.OnCheckBoxClicked(bChecked, mcmlNode)    
	local self = ActorPanelPage;
	if(not self.bindingContext or not self.bindTarget)then return; end
	self.bindTarget.IsRunTo = bChecked;
	self.bindTarget:Update();
end
function ActorPanelPage.OnVisible(bChecked, mcmlNode)    
	local self = ActorPanelPage;
	if(not self.bindingContext or not self.bindTarget)then return; end
	self.bindTarget.Visible = bChecked;
	self.bindTarget:Update();
end
function ActorPanelPage.DataBind(bindTarget)
	local self = ActorPanelPage;
	if(not bindTarget or not self.page)then return; end
	
	self.bindTarget = bindTarget;

		self.bindingContext = commonlib.BindingContext:new();	
		--self.bindingContext:AddBinding(bindTarget, "X", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "pos_x")
		--self.bindingContext:AddBinding(bindTarget, "Y", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "pos_y")
		--self.bindingContext:AddBinding(bindTarget, "Z", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "pos_z")
		self.bindingContext:AddBinding(bindTarget, "Facing", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "facing")
		self.bindingContext:AddBinding(bindTarget, "Scaling", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "scaling")
		self.bindingContext:AddBinding(bindTarget, "Rot_X", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "rot_x")
		self.bindingContext:AddBinding(bindTarget, "Rot_Y", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "rot_y")
		self.bindingContext:AddBinding(bindTarget, "Rot_Z", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "rot_z")
		self.bindingContext:AddBinding(bindTarget, "RunTo_X", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "runto_x")
		self.bindingContext:AddBinding(bindTarget, "RunTo_Y", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "runto_y")
		self.bindingContext:AddBinding(bindTarget, "RunTo_Z", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "runto_z")
		local targetNode = self.page:GetNode("isRunTo");
		if(targetNode)then
			local UICtrlName = targetNode:GetInstanceName(self.page.name);
			if(UICtrlName)then
				--self.bindingContext:AddBinding(bindTarget, "IsRunTo", UICtrlName, commonlib.Binding.ControlTypes.IDE_checkbox, "value")
			end
		end
		self.page:SetUIValue("isVisible",bindTarget.Visible);
		self.bindingContext:AddBinding(bindTarget, "Dialog", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "_txt")

	self.bindingContext:UpdateDataToControls();
end
function ActorPanelPage.OnGetProperty()
	local self = ActorPanelPage;
	if(not self.bindTarget or not self.page or not self.bindingContext)then return; end
	--local objParam = Map3DSystem.obj.GetObjectParams("selection");
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
							local staticAssetNode = moviescript:ConstructStaticAssetNode("pe:movie-actor",id);
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