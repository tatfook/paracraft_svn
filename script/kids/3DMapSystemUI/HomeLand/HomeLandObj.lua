--[[
Title: HomeLandObj
Author(s): Leio
Date: 2009/6/16
Desc: ��԰�������壨���ǽ�ɫ��ͨ���࣬��ʵ������ʱ��ͨ������HomeLandObj�����ֲ�ͬ������
HomeLandObj --> Building3D --> InteractiveObject --> DisplayObject --> EventDispatcher --> Object
HomeLandObj can be instance
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandObj.lua");
local obj = Map3DSystem.App.HomeLand.HomeLandObj_A:new()
obj.HomeLandObj = Map3DSystem.App.HomeLand.ObjEnum.PetE;
obj:Init();
------------------------------------------------------------
]]
------------------------------------------------------------
-- HomeLandObj_A
------------------------------------------------------------
NPL.load("(gl)script/ide/Display/Objects/Actor3D.lua");
local HomeLandObj_A = commonlib.inherit(CommonCtrl.Display.Objects.Actor3D,{
	CLASSTYPE = "HomeLandObj_A"
});  
commonlib.setfield("Map3DSystem.App.HomeLand.HomeLandObj_A",HomeLandObj_A);
function HomeLandObj_A:Init()
	self:ClearEventPools();
end
function HomeLandObj_A:__Clone()
	return Map3DSystem.App.HomeLand.HomeLandObj_A:new();
end
function HomeLandObj_A:SetGrid(info)
	
end
function HomeLandObj_A:GetGrid()
	
end
function HomeLandObj_A:SetGUID(guid)
	self.guid = guid;
end
function HomeLandObj_A:GetGUID()
	return tonumber(self.guid);
end
--	����HomeLandObj_A�������ĸ����ݵ�,����Ϊ��
function HomeLandObj_A:SetDoorPlate(roomUID)
	
end
function HomeLandObj_A:GetDoorPlate()
	
end
-- ����������ʲô���͵���Ʒ
function HomeLandObj_A:SetObjType(type)
	self.HomeLandObj = type;
end
function HomeLandObj_A:GetObjType()
	return self.HomeLandObj;
end
function HomeLandObj_A:ClassToMcml()
	local params = self:GetEntityParams();
	local k,v;
	local result = "";
	for k,v in pairs(params) do
			if(type(v)~="table")then
				v = tostring(v) or "";
				local s = string.format('%s="%s" ',k,v);
				result = result .. s;
			end
	end
	local title = self.CLASSTYPE;
	local HomeLandObj = string.format('%s="%s" ',"HomeLandObj",self.HomeLandObj);
	result =  string.format('<%s %s %s/>',title,HomeLandObj,result);
	return result;
end
------------------------------------------------------------
-- HomeLandObj_B
------------------------------------------------------------
NPL.load("(gl)script/ide/Display/Objects/Building3D.lua");
local HomeLandObj_B = commonlib.inherit(CommonCtrl.Display.Objects.Building3D,{
	CLASSTYPE = "HomeLandObj_B"
});  
commonlib.setfield("Map3DSystem.App.HomeLand.HomeLandObj_B",HomeLandObj_B);
function HomeLandObj_B:Init()
	self:ClearEventPools();
end
function HomeLandObj_B:Clone()
	local uid = self:GetUID();
	local entityID = self:GetEntityID();
	local parent = self:GetParent();
	local params = self:GetEntityParams();
	local clone_node = self:__Clone()
	clone_node:Init();
	clone_node:SetUID(uid);
	clone_node:SetEntityID(entityID);
	clone_node:SetParent(parent);
	clone_node:SetEntityParams(params);
	clone_node:SetBuilded(false);
	if(params.rotation)then
		clone_node.rot_x = params.rotation.x;
		clone_node.rot_y = params.rotation.y;
		clone_node.rot_z = params.rotation.z;
		clone_node.rot_w = params.rotation.w;
	end
	
	local gridInfo = self:GetGrid()
	clone_node:SetGrid(gridInfo);
	local roomUID = self:GetDoorPlate()
	clone_node:SetDoorPlate(roomUID);
	local guid = self:GetGUID()
	clone_node:SetGUID(guid);
	local objType = self:GetObjType()
	clone_node:SetObjType(objType);
	return clone_node;
end
function HomeLandObj_B:CloneNoneID()
	local uid = self:GetUID();
	local clone_node = self:Clone();
	clone_node:SetEntityID("");
	clone_node:SetParent(nil);
	return clone_node;
end
function HomeLandObj_B:__Clone()
	return Map3DSystem.App.HomeLand.HomeLandObj_B:new();
end
-- ��ֲ�����ã���¼ֲ���Ƿ����ĸ�����(seedgrid)�ĵڼ�����������
-- gridInfo:"gridID|index"
function HomeLandObj_B:SetGrid(info)
	if(not info)then return end
	self.GridInfo = info;
end
function HomeLandObj_B:GetGrid()
	return self.GridInfo;
end
-- �����node�󶨵���Ʒ��guid
function HomeLandObj_B:SetGUID(guid)
	self.guid = guid;
end
function HomeLandObj_B:GetGUID()
	return tonumber(self.guid);
end
--	����HomeLandObj_B�������ĸ����ݵ�,����Ϊ��
function HomeLandObj_B:SetDoorPlate(roomUID)
	self.DoorPlate = roomUID;
end
function HomeLandObj_B:GetDoorPlate()
	return self.DoorPlate;
end
-- ����������ʲô���͵���Ʒ
function HomeLandObj_B:SetObjType(type)
	self.HomeLandObj = type;
end
function HomeLandObj_B:GetObjType()
	return self.HomeLandObj;
end
function HomeLandObj_B:ClassToMcml()
	local params = self:GetEntityParams();
	local k,v;
	local result = "";
	for k,v in pairs(params) do
			if(type(v)~="table")then
				v = tostring(v) or "";
				local s = string.format('%s="%s" ',k,v);
				result = result .. s;
			end
	end
	local title = self.CLASSTYPE;
	local HomeLandObj = string.format('%s="%s" ',"HomeLandObj",self.HomeLandObj or title);
	result =  result..HomeLandObj;
	local gridInfo = "";
		gridInfo = string.format('%s="%s" ',"GridInfo",self.GridInfo or "");
		result =  result..gridInfo;
	local roomUID = "";
	roomUID = string.format('%s="%s" ',"DoorPlate",self.DoorPlate or "");
	result =  result..roomUID;
	local guid = string.format('%s="%s" ',"guid",self.guid or "");
	result =  result..guid;
	result =  string.format('<%s %s/>',title,result);
	return result;
end
------------------------------------------------------------
-- HomeLandEnum
------------------------------------------------------------
local ObjEnum = {
	PetE = "PetE",
	Pet = "Pet",
	PlantE = "PlantE",
	RoomEntry = "RoomEntry",
	Grid = "Grid",
	OutdoorOther = "OutdoorOther",
	-- ����
	Furniture = "Furniture",
}
commonlib.setfield("Map3DSystem.App.HomeLand.ObjEnum",ObjEnum);
------------------------------------------------------------
-- OutdoorObj �����������Ʒ
------------------------------------------------------------
local OutdoorObj = {
	PetE = true,
	Pet = true,
	PlantE = true,
	RoomEntry = true,
	Grid = true,
	OutdoorOther = true,
}
commonlib.setfield("Map3DSystem.App.HomeLand.OutdoorObj",OutdoorObj);
------------------------------------------------------------
-- IndoorObj �������ڵ���Ʒ
------------------------------------------------------------
local IndoorObj = {
	Furniture = true,
}
commonlib.setfield("Map3DSystem.App.HomeLand.IndoorObj",IndoorObj);
------------------------------------------------------------
-- CanSelectedAtView ��԰�������״̬���Ա�ѡ�������
------------------------------------------------------------
local ObjCanSelectedAtView = {
	PlantE = true,
	Grid = true,
	RoomEntry = true,
}
commonlib.setfield("Map3DSystem.App.HomeLand.ObjCanSelectedAtView",ObjCanSelectedAtView);
------------------------------------------------------------
-- CanSelectedAtEidt ��԰���ڱ༭״̬���Ա�ѡ�������
------------------------------------------------------------
local ObjCanSelectedAtEdit = {
	Grid = true,
	RoomEntry = true,
	OutdoorOther = true,
	Furniture = true,
}
commonlib.setfield("Map3DSystem.App.HomeLand.ObjCanSelectedAtEdit",ObjCanSelectedAtEdit);
--[[
CanGridItems
������Ʒͨ���ڴ�����ʱ�����ֱ����ק
�ڷ���grid�󣬲������ƶ�
--]]
------------------------------------------------------------
local CanGridItems = {
	PlantE = true,
}
commonlib.setfield("Map3DSystem.App.HomeLand.CanGridItems",CanGridItems);

