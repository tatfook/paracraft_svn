
--[[

*****this file is deprecated******


NPL.load("(gl)script/network/map3D.lua");

if( not MapManager) then MapManager = {};end;
MapManager.name = "mapManager";

MapManager.allowRotation = false;
MapManager.isInited = false;
MapManager.fovOver2 = math.pi/12;
MapManager.tile2DSize = 16;
MapManager.zoomCount = 0;
MapManager.maxZoomCount = 100;
MapManager.tile3DWidth = 12;

--show the map
function MapManager.Show(bShow)
	if( MapManager.isInited == false)then
		MapManager:Initialization();
	end
	
	if(bShow == nil)then
		MapManager.map3DCanvas.Show();
	else
		MapManager.map3DCanvas.Show(bShow)
	end
end

--Initialization MapManager members
function MapManager.Initialization()
	if( MapManager.isInited)then
		return;
	end
	
	MapManager.virtCam = MapSystem.virtualCamera:new{
		name = "virCam"
	}
		
	--create map3dCanvas
	NPL.load("(gl)script/network/map3D.lua");	
	MapManager.map3DCanvas = Map3DCanvas;
	MapManager.map3DCanvas.Initialization();
	
	--create 2d map layer
	NPL.load("(gl)script/network/map3D_2D.lua");
	MapManager.map2DLayer =  MapSystem.map2DLayer:new{
		name = "layer2D",
		positionX = 0,
		positionY = 0,
		positionZ = 0,
		tileSize = MapManager.tile2DSize,
		tileCountV = 2,
		tileCountH = 2,
		sceneGraph = MapManager.map3DCanvas.GetScene(),
		virtCam = MapManager.virtCam;
	}

	
	NPL.load("(gl)script/network/map3D_3D.lua");
	MapManager.map3DLayer = MapSystem.map3DLayer:new{
		name = "layer3D",
		tileSize = 4,
		sceneGraph = MapManager.map3DCanvas.GetScene(),
		virtCam = MapManager.virtCam,
		width = MapManager.tile3DWidth,
	}
	
	MapManager.isInited = true;
	--set map to default state
	MapManager.Reset();
end

--reset map to default state
function MapManager.Reset()
	if(MapManager.isInited == false)then
		return;
	end

	MapManager.zoomCount = 0;
	MapManager.map3DLayer:Show(false);
	MapManager.map3DLayer:SetEnable(false);	
	MapManager.map2DLayer:Show(true);
	MapManager.map2DLayer:SetEnable(true);	
	MapManager.activeLayer = MapManager.map2DLayer;		
	MapManager.activeLayer:Reset();
	MapManager.mapState = 1;
end

--called when map3dcanvas receive mouse zoom event
function MapManager.OnZoom(deltaZoom)
	if( MapManager.map2DLayer == nil or MapManager.map3DLayer == nil)then
		return;
	end
	
	MapManager.zoomCount = MapManager.zoomCount + (-deltaZoom);
	if( MapManager.zoomCount < 0)then
		MapManager.zoomCount = 0;
	end
	
	if( MapManager.zoomCount < MapManager.maxZoomCount and MapManager.acitveLayer ~= MapManager.map2DLayer)then
		MapManager.map3DLayer:SetEnable(false);
		MapManager.map3DLayer:Show(false);
		MapManager.acitveLayer = MapManager.map2DLayer;
	elseif( MapManager.zoomCount > MapManager.maxZoomCount -1 and MapManager.acitveLayer ~= MapManager.map3DLayer)then
		MapManager.map2DLayer:SetEnable(false);
		MapManager.map2DLayer:Show(false);
		MapManager.map3DLayer:SetEnable(true);
		MapManager.map3DLayer:Show(true);
		MapManager.activeLayer = MapManager.map3DLayer;
		MapManager.activeLayer:Reset();
	end
	
	--TODO delete this
	--MapManager.activeLayer = MapManager.map2DLayer;
	MapManager.activeLayer:Zoom( deltaZoom);
end  

--dx,dy is the mouse position delta
function MapManager.Move(dx,dy)
	if( MapManager.activeLayer == nil)then
		return;
	end
	log("call move\n");
	MapManager.activeLayer:Move(dx,dy);
end

function MapManager.Pitch(delta)
	if(MapManager.activeLayer.Pitch ~= nil)then
		MapManager.activeLayer:Pitch(delta);
	end
end

function MapManager.Rotate(delta)
	if(MapManager.activeLayer.Rotate ~= nil)then
		MapManager.activeLayer:Rotate(delta);
	end
end

function MapManager.SetActiveLayer(layer)
	MapManager.activeLayer = layer;
end

---------------------------------------------------------
local virtualCamera = {
	name = "cam1",
	viewPosX = 0,
	viewPosY = 0,
	viewPosZ = 0,
	worldPosX = 0,
	worldPosY = 0,
	viewRegion = 0;
}
MapSystem.virtualCamera = virtualCamera;


function virtualCamera:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;
end

function virtualCamera:SetViewPosition(x,y,z)
	self.viewPosX = x;
	self.viewPosY = y;
	self.viewPosZ = z;
end

function virtualCamera:GetViewPosition(x,y)
	return self.viewPosX,self.viewPosY;
end

function virtualCamera:SetViewRegion()
	self.viewRegion = viewRegion;
end

function virtualCamera:GetViewRegion()
	return self.viewRegion;
end

--]]