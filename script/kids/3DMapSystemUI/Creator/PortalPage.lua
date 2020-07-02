--[[
Title: PortalPage code behind file
Author(s): LiXizhi
Date: 2008/9/11
Desc: create and modify a portal node in the scene. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Creator/PortalPage.lua");
Map3DSystem.App.Creator.PortalPage.UpdatePanelUI()
------------------------------------------------------------
]]
local L = CommonCtrl.Locale("IDE");

local PortalPage = {};
commonlib.setfield("Map3DSystem.App.Creator.PortalPage", PortalPage)

local page;
local curObjName = "";
function PortalPage.DataBind(node)
	if(not node)then return end
	PortalPage.PortalNode = node;
	local params = node:GetEntityParams();
	local self = PortalPage;
	self.bindingContext = commonlib.BindingContext:new();	
	local root = self.PortalNode:GetRoot();
	local obj = root:GetEntity(self.PortalNode);
	local name = "";
	local temp = {};
	if(obj)then
		name = obj.name;
	end
	temp.name = name;
	self.bindingContext:AddBinding(temp, "name", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "portal_name")
	self.bindingContext:AddBinding(params, "x", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "pos_x")
	self.bindingContext:AddBinding(params, "y", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "pos_y")
	self.bindingContext:AddBinding(params, "z", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "pos_z")
	self.bindingContext:AddBinding(params, "facing", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "facing")
	
	self.bindingContext:AddBinding(params, "width", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "width")
	self.bindingContext:AddBinding(params, "height", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "height")
	self.bindingContext:AddBinding(params, "depth", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "depth")
	self.bindingContext:AddBinding(params, "portalpoints", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "pointset")	
	self.bindingContext:AddBinding(params, "homezone", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "homeZoneName")
	self.bindingContext:AddBinding(params, "targetzone", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "targetZoneName")
	self.bindingContext:UpdateDataToControls();
	
end
-- init 
function PortalPage.OnInit()
	PortalPage.page = document:GetPageCtrl();
	-- enable portal rendering when up. 
	ParaScene.GetAttributeObject():SetField("ShowPortalSystem", true);
end
function PortalPage.OnTabClick()
	local self = PortalPage;
	self.DataBind(self.PortalNode)
end
-- select portal display. 
function PortalPage.OnSelectPortal()
	Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_PickObject, 
		filter = "524288", -- "262144:zone", "524288:portal"
		-- callback. return true if allow next selection. 
		callbackFunc = function(curObj)
			if(curObj) then
				PortalPage.OnPortalNameSelected(nil, curObj.name)
			end
		end, });
end

-- create a default portal at current location
function PortalPage.OnCreatePortal(name, values)
	local PortalSystemPage = Map3DSystem.App.Creator.PortalSystemPage;
	local params = PortalSystemPage.ConstructParams_Portal();
	if(params)then
		PortalSystemPage.NewPortalNode(params)
	end
end

-- update points
function PortalPage.OnUpdatePortalPoints(name, values)
	local pointset = values["pointset"];
	if(pointset) then
		pointset = string.gsub(pointset, " ", "")
		pointset = string.gsub(pointset, "\r?\n", ";")
		PortalPage.UpdateParams("portalpoints",pointset);
	end
end
function PortalPage.OnChangePosX(value)
	PortalPage.UpdateParams("x",value)
end

function PortalPage.OnChangePosY(value)
	PortalPage.UpdateParams("y",value)
end
function PortalPage.OnChangePosZ(value)
	PortalPage.UpdateParams("z",value)
end
function PortalPage.OnFacing(value)
	PortalPage.UpdateParams("facing",value)
end
function PortalPage.OnChangeWidth(value)
	PortalPage.UpdateParams("width",value)
end

function PortalPage.OnChangeHeight(value)
	PortalPage.UpdateParams("height",value)
end

function PortalPage.OnChangeDepth(value)
	PortalPage.UpdateParams("depth",value)
end

function PortalPage.OnUpdateZones()
	local self = PortalPage;
	PortalPage.UpdateParams("homezone",self.page:GetUIValue("homeZoneName"))
	PortalPage.UpdateParams("targetzone",self.page:GetUIValue("targetZoneName"))
end

function PortalPage.OnSelectTargetZone()
	local self = PortalPage;
	Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_PickObject, 
		filter = "262144", -- "262144:zone", "524288:portal"
		callbackFunc = function (obj)
			if(obj) then
				self.page:SetUIValue("targetZoneName", obj.name);
				PortalPage.OnUpdateZones();
			end
		end, });
end

function PortalPage.OnSelectHomeZone()
	local self = PortalPage;
	Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_PickObject, 
		filter = "262144", -- "262144:zone", "524288:portal"
		callbackFunc = function (obj)
			if(obj) then
				self.page:SetUIValue("homeZoneName", obj.name);
				PortalPage.OnUpdateZones();
			end
		end, });
end
function PortalPage.ClearHomeZone()
	PortalPage.page:SetUIValue("homeZoneName", "");
	PortalPage.OnUpdateZones();
end
function PortalPage.ClearTargetZone()
	PortalPage.page:SetUIValue("targetZoneName", "");
	PortalPage.OnUpdateZones();
end
function PortalPage.UpdateParams(property,value)
	if(not property or not value)then return end
	local self = PortalPage;
	if(not self.PortalNode) then return end;
	
	--local lite3DCanvas = Map3DSystem.App.Inventor.GlobalInventor.Lite3DCanvas;
	--local commandManager =Map3DSystem.App.Inventor.GlobalInventor.commandManager;
	--local commandChangeState;
	--if(lite3DCanvas)then
		--commandChangeState=Map3DSystem.App.Inventor.CommandChangeState:new();
		--commandChangeState:Initialization(lite3DCanvas);
	--end
	local x,y,z =  self.PortalNode:GetPosition();
	local w,h,d = self.PortalNode:GetWHD();
	if(property == "width")then
		self.PortalNode:SetWHD(value,h,d)
	elseif(property == "height")then
		self.PortalNode:SetWHD(w,value,d)
	elseif(property == "depth")then
		self.PortalNode:SetWHD(w,h,value)
	elseif(property == "portalpoints")then
		self.PortalNode:SetPortalpoints(value)
	elseif(property == "homezone")then
		self.PortalNode:SetHomeZone(value)
	elseif(property == "targetzone")then
		self.PortalNode:SetTargetzone(value)
	elseif(property == "x")then
		self.PortalNode:SetPosition(value,y,z)
	elseif(property == "y")then
		self.PortalNode:SetPosition(x,value,z)
	elseif(property == "z")then
		self.PortalNode:SetPosition(x,y,value)
	elseif(property == "facing")then
		self.PortalNode:SetFacing(value)
	end
	
	--self.PortalNode:UpdateEntityParams();
	
	--if(commandChangeState)then
		--commandChangeState:NewState(lite3DCanvas);
		--commandManager:AddCommandToHistory(commandChangeState);
	--end
end