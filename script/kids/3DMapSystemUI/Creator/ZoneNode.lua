--[[
Title: ZoneNode PortalNode StaticObjNode
Author(s): Leio
Date: 2008/12/11
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Creator/ZoneNode.lua");
------------------------------------------------------------
]]
---------------------------------------------------------------------------
-- ZoneNode node
---------------------------------------------------------------------------
NPL.load("(gl)script/ide/Display/InteractiveObject.lua");
NPL.load("(gl)script/ide/math/math3d.lua");
local ZoneNode = commonlib.inherit(CommonCtrl.Display.InteractiveObject,{
	CLASSTYPE = "ZoneNode",
	width = 1,
	height = 1,
	depth = 1,
	zoneplanes = "",
});  
commonlib.setfield("Map3DSystem.App.Creator.ZoneNode",ZoneNode);
function ZoneNode:Init()
	self:ClearEventPools();
end
------------------------------------------------------------
-- override methods:DisplayObject
------------------------------------------------------------
function ZoneNode:UpdateEntity()
	local root = self:GetRoot();
	if(root and root.GetEntity)then
		local entity = root:GetEntity(self)
		if(entity)then
			-- position
			local point3D = self:LocalToGlobal({x = 0, y = 0, z = 0})
			if(point3D)then
				entity:SetPosition(point3D.x,point3D.y,point3D.z);	-- render in the global coordinates of the scene 
			end
			-- rotation
			local x,y,z,w = self.rot_x,self.rot_y,self.rot_z,self.rot_w;
			if(x and y and z and w)then
				--entity:SetRotation({x = x,y = y,z = z,w = w});	
			end
			-- scaling
			local scaling = self.scaling;
			if(scaling)then
				entity:SetScale(scaling);
			end
			-- facing
			local facing = self.facing;
			if(facing)then
				entity:SetFacing(facing)
			end
			-- homezone
			local homezone = self.homezone
			if(homezone)then
				entity:GetAttributeObject():SetField("homezone", homezone or "");
			end	
			-- w h d
			local w,h,d = self.width,self.height,self.depth;
			if(w and h and d)then
				entity:GetAttributeObject():SetField("width", w);
				entity:GetAttributeObject():SetField("height",h);
				entity:GetAttributeObject():SetField("depth", d);
			end		
			-- zoneplanes 
			local zoneplanes = self.zoneplanes;
			if(zoneplanes)then
				entity:GetAttributeObject():SetField("zoneplanes", zoneplanes or "");
			end
			
			local root = self:GetRoot();
			if(root)then
				entity:GetAttributeObject():CallField("AutoGenZonePlanes");
				root:AddObject(entity,self)
			end
		end
	end
end
function ZoneNode:SetEntityParams(params)
	self.x = params.x or 0;
	self.y = params.y or 0;
	self.z = params.z or 0;
	self.scaling=  params.scaling or 1;
	self.facing=  params.facing or 0;
	self.visible = params.visible;
	self.isCharacter = params.IsCharacter;
	local file;
	if(self.isCharacter)then
		file = "character/v3/Human/Female/HumanFemale.xml";
	else
		file = "model/06props/shared/pops/muzhuang.x";
	end
	self.assetFile = params.AssetFile or file;
	
	local rotation = params.rotation;
	if(not rotation)then rotation = {}; end
	self.rot_x = rotation.rot_x or 0;
	self.rot_y = rotation.rot_y or 0;
	self.rot_z = rotation.rot_z or 0;
	self.rot_w = rotation.rot_w or 1;
	
	self.width,self.height,self.depth = params.width,params.height,params.depth;
	self.homezone = params.homezone or "";
	self.zoneplanes = params.zoneplanes or "";
end
function ZoneNode:GetEntityParams()
	local params = {};
	params.x = self.x;
	params.y = self.y;
	params.z = self.z;
	params.name = tostring(self:GetUID());
	params.IsCharacter = self.isCharacter;
	params.facing = self.facing;
	params.scaling = self.scaling;
	params.visible = self.visible;
	params.AssetFile = self.assetFile;
	params.homezone = self.homezone;
	
	local rotation={ w=self.rot_w, x=self.rot_x, y=self.rot_y, z=self.rot_z };
	params.rotation = rotation;
	
	params.width,params.height,params.depth = self.width,self.height,self.depth;
	params.homezone = self.homezone;
	params.zoneplanes = self.zoneplanes;
	return params;
end
function ZoneNode:Clone()
	local uid = self:GetUID();
	local entityID = self:GetEntityID();
	local parent = self:GetParent();
	local params = self:GetEntityParams();
	local clone_node = Map3DSystem.App.Creator.ZoneNode:new();
	clone_node:Init();
	clone_node:SetUID(uid);
	clone_node:SetEntityID(entityID);
	clone_node:SetParent(nil);
	clone_node:SetEntityParams(params);
	return clone_node;
end
function ZoneNode:CloneNoneID()
	local params = self:GetEntityParams();
	local clone_node = Map3DSystem.App.Creator.ZoneNode:new();
	clone_node:Init();
	clone_node:SetEntityID("");
	clone_node:SetParent(nil);
	clone_node:SetEntityParams(params);
	return clone_node;
end
function ZoneNode:SetSelected(v)
	self.internal_selected = v;
	local root = self:GetRoot();
	if(root and root.GetEntity)then
		local entity = root:GetEntity(self)
		if(entity)then
			if(v)then
				local fromX, fromY, fromZ = ParaScene.GetPlayer():GetPosition();
				fromY = fromY+1.0;
				local toX, toY, toZ = entity:GetViewCenter();
				-- using missile type 2, with a speed of 5.0
				ParaScene.FireMissile(2, 5, fromX, fromY, fromZ, toX, toY, toZ);
			end
		end
	end
end
function ZoneNode:GetSelected()
	return self.internal_selected;
end
function ZoneNode:SetWHD(w,h,d)
	if(not w or not h or not d) then return end
	self.width,self.height,self.depth = w,h,d;
	self:UpdateEntity();
end
function ZoneNode:GetWHD()
	return self.width,self.height,self.depth;
end
function ZoneNode:SetWHDDelta(w_delta,h_delta,d_delta)
	if(not w_delta or not h_delta or not d_delta)then return end
	local w,h,d = self:GetWHD();
	w = w + w_delta;
	h = h + h_delta;
	d = d + d_delta;
	self:SetWHD(w,h,d)
	self:UpdateEntity();
end
function ZoneNode:SetZoneplanes(s)
	if(not s)then s = "" end;
	self.zoneplanes = s;
	self:UpdateEntity();
end
function ZoneNode:GetZoneplanes()
	return self.zoneplanes;
end
-- do nothing
function ZoneNode:SetHomeZone(s)
end
---------------------------------------------------------------------------
-- PortalNode node
---------------------------------------------------------------------------
NPL.load("(gl)script/ide/Display/InteractiveObject.lua");
NPL.load("(gl)script/ide/math/math3d.lua");
local PortalNode = commonlib.inherit(CommonCtrl.Display.InteractiveObject,{
	CLASSTYPE = "PortalNode",
	width = 1,
	height = 1,
	depth = 1,
	homezone = "",
	targetzone = "",
	portalpoints = "",
});  
commonlib.setfield("Map3DSystem.App.Creator.PortalNode",PortalNode);
function PortalNode:Init()
	self:ClearEventPools();
end
------------------------------------------------------------
-- override methods:DisplayObject
------------------------------------------------------------
function PortalNode:UpdateEntity()
	local root = self:GetRoot();
	if(root and root.GetEntity)then
		local entity = root:GetEntity(self)
		if(entity)then
			-- position
			local point3D = self:LocalToGlobal({x = 0, y = 0, z = 0})
			if(point3D)then
				entity:SetPosition(point3D.x,point3D.y,point3D.z);	-- render in the global coordinates of the scene 
			end
			-- rotation
			local x,y,z,w = self.rot_x,self.rot_y,self.rot_z,self.rot_w;
			if(x and y and z and w)then
				entity:SetRotation({x = x,y = y,z = z,w = w});	
			end
			-- scaling
			local scaling = self.scaling;
			if(scaling)then
				entity:SetScale(scaling);
			end
			-- facing
			local facing = self.facing;
			if(facing)then
				entity:SetFacing(facing)
				
			end
			-- homezone
			local homezone = self.homezone
			if(homezone)then
				entity:GetAttributeObject():SetField("homezone", homezone or "");
			end	
			-- targetzone
			local targetzone = self.targetzone
			if(targetzone)then
				entity:GetAttributeObject():SetField("targetzone", targetzone or "");
			end	
			
			-- w h d
			local w,h,d = self.width,self.height,self.depth;
			if(w and h and d)then
				entity:GetAttributeObject():SetField("width", w);
				entity:GetAttributeObject():SetField("height",h);
				entity:GetAttributeObject():SetField("depth", d);
			end		
			-- portalpoints 
			local portalpoints = self.portalpoints;
			if(portalpoints)then
				entity:GetAttributeObject():SetField("portalpoints", portalpoints or "");
			end
			
			local root = self:GetRoot();
			if(root)then
				entity:GetAttributeObject():CallField("AutoGenZonePlanes");
				root:AddObject(entity,self)
			end
		end
	end
end
function PortalNode:SetEntityParams(params)
	self.x = params.x or 0;
	self.y = params.y or 0;
	self.z = params.z or 0;
	self.scaling=  params.scaling or 1;
	self.facing=  params.facing or 0;
	self.visible = params.visible;
	self.isCharacter = params.IsCharacter;
	local file;
	if(self.isCharacter)then
		file = "character/v3/Human/Female/HumanFemale.xml";
	else
		file = "model/06props/shared/pops/muzhuang.x";
	end
	self.assetFile = params.AssetFile or file;
	
	local rotation = params.rotation;
	if(not rotation)then rotation = {}; end
	self.rot_x = rotation.rot_x or 0;
	self.rot_y = rotation.rot_y or 0;
	self.rot_z = rotation.rot_z or 0;
	self.rot_w = rotation.rot_w or 1;
	
	self.width,self.height,self.depth = params.width,params.height,params.depth;
	self.homezone = params.homezone or "";
	self.targetzone = params.targetzone or "";
	self.portalpoints = params.portalpoints or "";
end
function PortalNode:GetEntityParams()
	local params = {};
	params.x = self.x;
	params.y = self.y;
	params.z = self.z;
	params.name = tostring(self:GetUID());
	params.IsCharacter = self.isCharacter;
	params.facing = self.facing;
	params.scaling = self.scaling;
	params.visible = self.visible;
	params.AssetFile = self.assetFile;
	params.homezone = self.homezone;
	
	local rotation={ w=self.rot_w, x=self.rot_x, y=self.rot_y, z=self.rot_z };
	params.rotation = rotation;
	
	params.width,params.height,params.depth = self.width,self.height,self.depth;
	params.homezone = self.homezone;
	params.targetzone = self.targetzone;
	params.portalpoints = self.portalpoints;
	return params;
end
function PortalNode:Clone()
	local uid = self:GetUID();
	local entityID = self:GetEntityID();
	local parent = self:GetParent();
	local params = self:GetEntityParams();
	local clone_node = Map3DSystem.App.Creator.PortalNode:new();
	clone_node:Init();
	clone_node:SetUID(uid);
	clone_node:SetEntityID(entityID);
	clone_node:SetParent(nil);
	clone_node:SetEntityParams(params);
	return clone_node;
end
function PortalNode:CloneNoneID()
	local params = self:GetEntityParams();
	local clone_node = Map3DSystem.App.Creator.PortalNode:new();
	clone_node:Init();
	clone_node:SetEntityID("");
	clone_node:SetParent(nil);
	params["homezone"] = "";
	params["targetzone"] = "";
	clone_node:SetEntityParams(params);
	return clone_node;
end
function PortalNode:SetSelected(v)
	self.internal_selected = v;
	local root = self:GetRoot();
	if(root and root.GetEntity)then
		local entity = root:GetEntity(self)
		if(entity)then
			if(v)then
				local fromX, fromY, fromZ = ParaScene.GetPlayer():GetPosition();
				fromY = fromY+1.0;
				local toX, toY, toZ = entity:GetViewCenter();
				-- using missile type 2, with a speed of 5.0
				ParaScene.FireMissile(2, 5, fromX, fromY, fromZ, toX, toY, toZ);
			end
		end
	end
end
function PortalNode:GetSelected()
	return self.internal_selected;
end
function PortalNode:SetWHD(w,h,d)
	if(not w or not h or not d) then return end
	self.width,self.height,self.depth = w,h,d;
	self:UpdateEntity();
end
function PortalNode:GetWHD()
	return self.width,self.height,self.depth;
end
function PortalNode:SetWHDDelta(w_delta,h_delta,d_delta)
	if(not w_delta or not h_delta or not d_delta)then return end
	local w,h,d = self:GetWHD();
	w = w + w_delta;
	h = h + h_delta;
	d = d + d_delta;
	self:SetWHD(w,h,d)
	self:UpdateEntity();
end
function PortalNode:SetPortalpoints(s)
	if(not s)then s = "" end;
	self.portalpoints = s;
	self:UpdateEntity();
end
function PortalNode:GetPortalpoints()
	return self.portalpoints;
end
function PortalNode:SetTargetzone(s)
	if(not s)then s = "" end;
	self.targetzone = s;
	self:UpdateEntity();
end
function PortalNode:GetTargetzone()
	return self.targetzone;
end
function PortalNode:UpdatePlanesParam(facing)
	if(not facing)then return end
	local params = self:GetEntityParams();
	local planes = params["portalpoints"]; --0.000000,0.000000,-1.945829;0.000000,0.000000,1.945829;0.000000,6.156483,1.945829;0.000000,6.156483,-1.945829;
	local result_x,result_y,result_z
	local result = "";
	--commonlib.echo("-----------");
	--commonlib.echo(planes);
	if(planes)then
		for t in string.gfind(planes, "([^%s;]+)") do
			local s = "";
			if(t)then
				local __,__,x,y,z = string.find(t,"(.+),(.+),(.+)");
				x = tonumber(x);
				y = tonumber(y);
				z = tonumber(z);
				if(x and y and z)then
					result_x,result_y,result_z = mathlib.math3d.vec3RotateByPoint(0, 0, 0, x, y, z, 0, facing+3.1415926535897, 0)
					 s = string.format("%f,%f,%f",result_x,result_y,result_z);
				end
			end
			result = result .. s ..";"
		end
		--commonlib.echo(result);
		params["portalpoints"] = result;
		self:SetPortalpoints(result)
	end
end

