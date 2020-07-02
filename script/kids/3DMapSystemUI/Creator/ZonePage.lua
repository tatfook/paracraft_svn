--[[
Title: ZonePage code behind file
Author(s): LiXizhi
Date: 2008/9/26
Desc: for testing only
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Creator/ZonePage.lua");
Map3DSystem.App.Creator.ZonePage.UpdatePanelUI()
------------------------------------------------------------
]]
local L = CommonCtrl.Locale("IDE");

local ZonePage = {};
commonlib.setfield("Map3DSystem.App.Creator.ZonePage", ZonePage)

local curObjName = "";
function ZonePage.DataBind(node)
	local self = ZonePage;
	if(not node)then return end
	ZonePage.ZoneNode = node;
	local params = node:GetEntityParams();
	self.bindingContext = commonlib.BindingContext:new();	
	local root = self.ZoneNode:GetRoot();
	local obj = root:GetEntity(self.ZoneNode);
	local name = "";
	local temp = {};
	if(obj)then
		name = obj.name;
	end
	temp.name = name;
	self.bindingContext:AddBinding(temp, "name", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "zone_name")
	self.bindingContext:AddBinding(params, "x", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "pos_x")
	self.bindingContext:AddBinding(params, "y", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "pos_y")
	self.bindingContext:AddBinding(params, "z", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "pos_z")
	self.bindingContext:AddBinding(params, "facing", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "facing")
	
	self.bindingContext:AddBinding(params, "width", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "width")
	self.bindingContext:AddBinding(params, "height", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "height")
	self.bindingContext:AddBinding(params, "depth", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "depth")
	self.bindingContext:AddBinding(params, "zoneplanes", self.page.name, commonlib.Binding.ControlTypes.MCML_node, "planeset")	
	self.bindingContext:UpdateDataToControls();
	
end
-- init 
function ZonePage.OnInit()
	ZonePage.page = document:GetPageCtrl();
	-- enable portal rendering when up. 
	ParaScene.GetAttributeObject():SetField("ShowPortalSystem", true);
end

function ZonePage.OnTabClick()
	local self = ZonePage;
	self.DataBind(self.ZoneNode)
end
-- create a default zone at current location
function ZonePage.OnCreateZone(name, values)
	local PortalSystemPage = Map3DSystem.App.Creator.PortalSystemPage;
	local params = PortalSystemPage.ConstructParams_Zone();
	if(params)then
		PortalSystemPage.NewZoneNode(params)
	end
end
function ZonePage.OnChangePosX(value)
	ZonePage.UpdateParams("x",value)
end

function ZonePage.OnChangePosY(value)
	ZonePage.UpdateParams("y",value)
end
function ZonePage.OnChangePosZ(value)
	ZonePage.UpdateParams("z",value)
end
function ZonePage.OnFacing(value)
	ZonePage.UpdateParams("facing",value)
end
function ZonePage.OnChangeWidth(value)
	ZonePage.UpdateParams("width",value)
end

function ZonePage.OnChangeHeight(value)
	ZonePage.UpdateParams("height",value)
end

function ZonePage.OnChangeDepth(value)
	ZonePage.UpdateParams("depth",value)
end

-- update points
function ZonePage.OnUpdateZonePlanes(name, values)
	local planeset = values["planeset"];
	if(planeset) then
		planeset = string.gsub(planeset, " ", "")
		planeset = string.gsub(planeset, "\r?\n", ";")
		ZonePage.UpdateParams("zoneplanes",planeset)
	end	
end

function ZonePage.OnRefreshPortals()
	local self = ZonePage;
	if(not self.ZoneNode)then return end;
	local root = self.ZoneNode:GetRoot();
	local curObj;
	if(root)then
		curObj =  root:GetEntity(self.ZoneNode)
	end
	
	if(curObj:IsValid()) then
		local ctl = self.page:FindControl("portalset");
		if(ctl) then
			local nCount = curObj:GetRefObjNum();
			ctl:RemoveAll();
			local i;
			for i = 0, nCount-1 do 
				local obj = curObj:GetRefObject(i);
				if(obj:GetType()=="CPortalNode") then
					ctl:AddTextItem(string.format("%d:%s", obj:GetID(), obj.name));
					--ctl:AddTextItem(tostring(obj:GetID()));
				end	
			end	
		end
	end	
end
-- fire a missile to a give portal to highlight it. 
function ZonePage.OnHighlightPortal(name, value)
	local id = tonumber(string.match(value, "^%d+"));
	local portalObj = ParaScene.GetObject(id);
	if(portalObj:IsValid()) then
		local fromX, fromY, fromZ = ParaScene.GetPlayer():GetPosition();
		fromY = fromY+1.0;
		local toX, toY, toZ = portalObj:GetViewCenter();
		-- using missile type 2, with a speed of 5.0
		ParaScene.FireMissile(2, 5, fromX, fromY, fromZ, toX, toY, toZ);
	end
end
-- refresh zone objects
function ZonePage.OnRefreshZoneObject()
	local self = ZonePage;
	if(not self.ZoneNode)then return end;
	local root = self.ZoneNode:GetRoot();
	local curObj;
	if(root)then
		curObj =  root:GetEntity(self.ZoneNode)
	end
	if(curObj:IsValid()) then
		local ctl = self.page:FindControl("objectset");
		if(ctl) then
			local nCount = curObj:GetRefObjNum();
			ctl:RemoveAll();
			local i;
			for i = 0, nCount-1 do 
				local obj = curObj:GetRefObject(i);
				if(obj:GetType()~="CPortalNode") then
					local id = obj:GetID();
					ctl:AddTextItem(string.format("%d:%s", id, obj.name));
					--ctl:AddTextItem(tostring(id));
				end	
			end	
		end
	end
end
-- @param value: it must be a string beginning with the index number, such as "0: asset name"
function ZonePage.OnSelectObject(name, value)
	local self = ZonePage;
	if(not self.ZoneNode)then return end;
	local id = tonumber(string.match(value, "^%d+"));
	local root = self.ZoneNode:GetRoot();
	local zoneObj;
	if(root)then
		zoneObj =  root:GetEntity(self.ZoneNode)
	end
	local nCount = zoneObj:GetRefObjNum();
	local index;
	for index = 1,nCount do
		local _obj = zoneObj:GetRefObject(index-1);
		if(_obj:IsValid()) then
			if(_obj:GetID() == id)then
				local fromX, fromY, fromZ = ParaScene.GetPlayer():GetPosition();
				fromY = fromY+1.0;
				local toX, toY, toZ = _obj:GetViewCenter();
				-- using missile type 2, with a speed of 5.0
				ParaScene.FireMissile(2, 5, fromX, fromY, fromZ, toX, toY, toZ);
			end
		end
	end					
end
function ZonePage.UpdateParams(property,value)
	if(not property or not value)then return end
	local self = ZonePage;
	if(not self.ZoneNode) then return end;
	
	--local lite3DCanvas = Map3DSystem.App.Inventor.GlobalInventor.Lite3DCanvas;
	--local commandManager =Map3DSystem.App.Inventor.GlobalInventor.commandManager;
	--local commandChangeState;
	--if(lite3DCanvas)then
		--commandChangeState=Map3DSystem.App.Inventor.CommandChangeState:new();
		--commandChangeState:Initialization(lite3DCanvas);
	--end
	local x,y,z =  self.ZoneNode:GetPosition();
	local w,h,d = self.ZoneNode:GetWHD();
	if(property == "width")then
		self.ZoneNode:SetWHD(value,h,d)
	elseif(property == "height")then
		self.ZoneNode:SetWHD(w,value,d)
	elseif(property == "depth")then
		self.ZoneNode:SetWHD(w,h,value)
	elseif(property == "zoneplanes")then
		self.ZoneNode:SetZoneplanes(value)
	elseif(property == "x")then
		self.ZoneNode:SetPosition(value,y,z)
	elseif(property == "y")then
		self.ZoneNode:SetPosition(x,value,z)
	elseif(property == "z")then
		self.ZoneNode:SetPosition(x,y,value)
	elseif(property == "facing")then
		self.ZoneNode:SetFacing(value)
	end
	
	
	--self.ZoneNode:UpdateEntityParams();
	
	--if(commandChangeState)then
		--commandChangeState:NewState(lite3DCanvas);
		--commandManager:AddCommandToHistory(commandChangeState);
	--end
end