--[[
Title: StaticObjPage code behind file
Author(s): Leio
Date: 2008/12/30
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Creator/StaticObjPage.lua");
------------------------------------------------------------
]]
local L = CommonCtrl.Locale("IDE");

local StaticObjPage = {};
commonlib.setfield("Map3DSystem.App.Creator.StaticObjPage", StaticObjPage)

local page;
local curObjName = "";
function StaticObjPage.DataBind(node)
	if(not node)then return end
	StaticObjPage.StaticObjNode = node;
	local params = node:GetEntityParams();
	local self = StaticObjPage;
	self.bindingContext = commonlib.BindingContext:new();	
	local root = self.StaticObjNode:GetRoot();	
	local obj;
	if(root and root.GetEntity)then
		obj = root:GetEntity(self.StaticObjNode);
	else
		--commonlib.echo(params);
	end
	local name = "";
	local temp = {};
	if(obj)then
		name = obj.name;
	end
	temp.name = name;
	self.bindingContext:AddBinding(temp, "name", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "obj_name")
	self.bindingContext:AddBinding(params, "x", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "pos_x")
	self.bindingContext:AddBinding(params, "y", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "pos_y")
	self.bindingContext:AddBinding(params, "z", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "pos_z")
	self.bindingContext:AddBinding(params, "facing", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "facing")
	
		
	self.bindingContext:AddBinding(params, "homezone", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "homeZoneName")

	self.bindingContext:UpdateDataToControls();
	
	self.OnShowModel()
end
-- init 
function StaticObjPage.OnInit()
	StaticObjPage.page = document:GetPageCtrl();
	-- enable portal rendering when up. 
	ParaScene.GetAttributeObject():SetField("ShowPortalSystem", true);
end
function StaticObjPage.OnTabClick()
	local self = StaticObjPage;
	self.DataBind(self.StaticObjNode)
end
function StaticObjPage.OnShowModel()
	local self = StaticObjPage;
	local canvasCtl = self.page:FindControl("modelCanvas");
	if(canvasCtl and self.StaticObjNode) then
		local root = self.StaticObjNode:GetRoot();	
		local obj = root:GetEntity(self.StaticObjNode);
		if(obj)then
			local params = ObjEditor.GetObjectParams(obj);
			canvasCtl:ShowModel(params);
		end
	end
end
function StaticObjPage.OnChangePosX(value)
	StaticObjPage.UpdateParams("x",value)
end

function StaticObjPage.OnChangePosY(value)
	StaticObjPage.UpdateParams("y",value)
end
function StaticObjPage.OnChangePosZ(value)
	StaticObjPage.UpdateParams("z",value)
end
function StaticObjPage.OnFacing(value)
	StaticObjPage.UpdateParams("facing",value)
end
function StaticObjPage.OnUpdateZones()
	local self = StaticObjPage;	
	StaticObjPage.UpdateParams("homezone",self.page:GetUIValue("homeZoneName"))
end

function StaticObjPage.OnSelectHomeZone()
	local self = StaticObjPage;
	Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_PickObject, 
		filter = "262144", -- "262144:zone", "524288:portal"
		callbackFunc = function (obj)
			if(obj) then
				self.page:SetUIValue("homeZoneName", obj.name);
				StaticObjPage.OnUpdateZones();
			end
		end, });
end
function StaticObjPage.ClearHomeZone()
	StaticObjPage.page:SetUIValue("homeZoneName", "");
	StaticObjPage.OnUpdateZones();
end

function StaticObjPage.UpdateParams(property,value)
	if(not property or not value)then return end
	local self = StaticObjPage;
	if(not self.StaticObjNode) then return end;
	
	--local lite3DCanvas = Map3DSystem.App.Inventor.GlobalInventor.Lite3DCanvas;
	--local commandManager =Map3DSystem.App.Inventor.GlobalInventor.commandManager;
	--local commandChangeState;
	--if(lite3DCanvas)then
		--commandChangeState=Map3DSystem.App.Inventor.CommandChangeState:new();
		--commandChangeState:Initialization(lite3DCanvas);
	--end
	local x,y,z =  self.StaticObjNode:GetPosition();
	if(property == "homezone")then
		self.StaticObjNode:SetHomeZone(value)
	elseif(property == "x")then
		self.StaticObjNode:SetPosition(value,y,z)
	elseif(property == "y")then
		self.StaticObjNode:SetPosition(x,value,z)
	elseif(property == "z")then
		self.StaticObjNode:SetPosition(x,y,value)
	elseif(property == "facing")then
		self.StaticObjNode:SetFacing(value)
	end
	
	--self.StaticObjNode:UpdateEntityParams();
	
	--if(commandChangeState)then
		--commandChangeState:NewState(lite3DCanvas);
		--commandManager:AddCommandToHistory(commandChangeState);
	--end
end