

local MBController = {
	name = "uiController",
	map = nil;
	sideBar = nil;
	landWnd = nil;
}
Map3DApp.MBController = MBController;

function MBController:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;
end

function MBController:Init(map,sideBar,landWnd)
	self.map = map;
	self.sideBar = sideBar;
	self.landWnd = landWnd;
	
	self.map:AddListener(self.name,self);
end

function MBController:SetMessage(sender,message)
	if(message == Map3DApp.Msg.onMapItemSelect)then
		self:OnItemSelectInMap(sender);
	end	
end

--=============private===================
function MBController:OnItemSelectInMap(mapName)
	local map = CommonCtrl.GetControl(mapName);
	if(map == nil)then
		return;
	end
	
	local selectItem = map:GetSelectItem();
	if(selectItem == nil)then
		return;
	end

	local tileInfoID = selectItem:GetAttributeObject():GetDynamicField("tileID","");
	--local tileInfo = Map3DApp.TileInfo.GetTileInfo(tileInfoID);
	if(tileInfo == nil)then
		return;
	end
	
	if(self.sideBar)then
		self.sideBar.SetTabPage("MyLand");
	end
	
	if(self.landWnd)then
		self.landWnd.SetTileInfoData(tileInfo);
	end
end
