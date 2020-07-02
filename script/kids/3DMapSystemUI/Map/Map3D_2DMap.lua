--[[
Title: display 2D map
Author(s): SunLingFeng
Date: 2007/1/20
Use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3D_3DMap.lua");
local _this = Map3DApp.Map2DLayer:new{
	name = "2DMap",
}
uiContainer:SetBGImage(_this:GetMap());
-------------------------------------------------------
]]

NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppCommon.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppTile.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppVirtualCamera.lua");


local Map2DLayer = {
	name = nil,
	tiles = {},
	tileSize = 16,
	tileDimension = 2,
	
	scene = nil,
	virtCam = nil,
	minCamElevation = 15,
	maxCamElevation = 15,	
	maxZoomLvl = 4,
	zoomLvl = 1,
	defaultCamPitch = math.pi/2 - 0.001,
	
	--2d map render target size
	resolutionX = 512,
	resolutionY = 512,
	
	listeners = {};
	
	--event
	--fired when reach the max zoom state
	onMaxZoom = nil;
	onMaxZoomSubscriber = nil;
	
}
Map3DApp.Map2DLayer = Map2DLayer;

function Map2DLayer:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;
end

function Map2DLayer:GetMap()
	local _this = CommonCtrl.GetControl(self.name);
	if(_this == nil)then
		self:Init();
	end
	
	local scene = ParaScene.GetMiniSceneGraph(self.name);
	if(scene:IsValid() == false)then
		return;
	end
	
	local tile = scene:GetObject(self.name.."11");
	if(tile:IsValid() == false)then
		self:OnSceneReset();
	end
	
	return scene:GetTexture();
end

--create 2D map object
function Map2DLayer:Init()
	if(self.name == nil)then
		return;
	end
	
	self.virtCam = Map3DApp.VirtualCamera:new{
		name = "2dMapCamera",
	};
	self.maxCamElevation = self.tileSize/2/math.tan(self.virtCam.fov/2);
	CommonCtrl.AddControl(self.name,self);
	
	self:OnSceneReset();
end

--create scene and model
function Map2DLayer:OnSceneReset()
	--reset scene
	local scene = ParaScene.GetMiniSceneGraph(self.name);
	scene:Reset();
	scene:SetRenderTargetSize(self.resolutionX,self.resolutionY);
	scene:EnableCamera(true);
	scene:EnableActiveRendering(true);
	local att = scene:GetAttributeObject();
	att:SetField("EnableFog",false);
	att:SetField("EnableLight", false);
	att:SetField("EnableSunLight", false);
	att:SetField("BackgroundColor", {1, 1, 1});

	local model = Map3DApp.Global.AssetManager.GetModel("model/common/map3D/map3D.x");
	if(model ~= nil)then
		for i=1,self.tileDimension do
			for j=1,self.tileDimension do
				local tile = ParaScene.CreateMeshPhysicsObject(self.name..i..j,model,1,1,1,false,"1,0,0,0,1,0,0,0,1,0,0,0");
				if(tile:IsValid())then
					tile:GetAttributeObject():SetField("progress",1);
					tile:SetPosition((j-1)*self.tileSize,0,(1-i)*self.tileSize);
					tile:SetScale(self.tileSize);
					scene:AddChild(tile);
				end
			end
		end
	end
	
	self:ResetViewRegion();
end

--set view region to default value
function Map2DLayer:ResetViewRegion()
	local scene = ParaScene.GetMiniSceneGraph(self.name);
	if(scene:IsValid() == false)then
		return;
	end

	scene:CameraSetEyePosByAngle(0,self.defaultCamPitch,0);
	self:SetViewElevation(0);
end

function Map2DLayer:ResetCamera()
end

function Map2DLayer:Pan(dx,dy)
	self.virtCam.viewPosX = self.virtCam.viewPosX + dx;
	self.virtCam.viewPosY = self.virtCam.viewPosY - dy;
	self:SetViewPosition(self.virtCam.viewPosX,self.virtCam.viewPosY);
end

function Map2DLayer:SetViewPosition(x,y)
	self.virtCam.viewPosX = x;
	self.virtCam.viewPosY = y;
	
	self:CheckViewBound();
	self:UpdateView();
end

function Map2DLayer:Zoom(delta)
	self.virtCam.viewPosZ = self.virtCam.viewPosZ + delta;
	self:SetViewElevation(self.virtCam.viewPosZ);
end

--set zoom value
function Map2DLayer:SetViewElevation(elevation)
	local scene = ParaScene.GetMiniSceneGraph(self.name);
	if(scene:IsValid() == false)then
		return;
	end
	
	if(elevation > 1)then
		elevation = 1;
	elseif(elevation < 0)then
		elevation = 0;
	end
	self.virtCam.viewPosZ = elevation;
	
	--when look the map at max elevation,set the view position to the center of map
	if(elevation == 0)then
		self.virtCam.viewPosX = 0.5;
		self.virtCam.viewPosY = 0.5;
	end

	--update zoom level
	self.zoomLvl = math.floor(self.virtCam.viewPosZ * self.maxZoomLvl) + 1;
	if(self.zoomLvl > self.maxZoomLvl)then
		self.zoomLvl = self.maxZoomLvl;
	end
	
	--get real camara distance
	local levelStep = 1/self.maxZoomLvl;
	local norViewElevation = 1-(self.virtCam.viewPosZ - levelStep * (self.zoomLvl - 1))/levelStep;
	realViewElevation = norViewElevation * (self.maxCamElevation - self.minCamElevation) + self.minCamElevation;	
	local yaw,pitch = scene:CameraGetEyePosByAngle();
	scene:CameraSetEyePosByAngle(yaw,pitch,realViewElevation-1);
	
	--update view region size
	self.virtCam.viewRegion = ( math.tan(self.virtCam.fov/2) * realViewElevation * 2) / self:GetCurrentMapResolution();
	
	self:CheckViewBound();
	--refresh map display
	self:UpdateView();
	
	--fire onMaxZoom event
	if(self.virtCam.viewPosZ >= 1)then
		--if(self.onMaxZoom ~= nil)then
			--self.onMaxZoom(self.name,self.onMaxZoomSubscriber);
		--end
		self:SendMessage(Map3DApp.Msg.onMaxZoom);
	end
end

--update tile position and texture
function Map2DLayer:UpdateView()
	local scene = ParaScene.GetMiniSceneGraph(self.name);
	if(scene:IsValid() == false)then
		return;
	end
	
	local worldViewPosX = self.virtCam.viewPosX * self:GetCurrentMapResolution();
	local worldViewPosY = self.virtCam.viewPosY * self:GetCurrentMapResolution();
	
	--left,top are the world position of the very left top tile
	--norLeft,norTop are normalized map position of the very left top tile
	local left,top,norLeft,norTop;
	local halfTileSize = self.tileSize / 2;
	local norViewRegion = 1 / math.pow(2,self.zoomLvl - 1);
	
	local offset = math.mod(worldViewPosX,self.tileSize);
	if(offset < halfTileSize)then
		left = -halfTileSize - offset;
		norLeft = self.virtCam.viewPosX - norViewRegion;
	else
		left = halfTileSize - offset;
		norLeft = self.virtCam.viewPosX;
	end
	
	offset = math.mod(worldViewPosY,self.tileSize);
	if(offset < halfTileSize)then
		top = halfTileSize + offset;
		norTop = self.virtCam.viewPosY - norViewRegion;
	else
		top = offset - halfTileSize;
		norTop = self.virtCam.viewPosY;
	end
	
	--update tile position and texture
	for i = 1,self.tileDimension do
		for j = 1,self.tileDimension do
			local tile = scene:GetObject(self.name..i..j);
			if(tile:IsValid())then
				tile:SetPosition(left+(j-1)*self.tileSize,0,top-(i-1)*self.tileSize);
				local texture = Map3DApp.DataPvd.GetMap(norLeft+(j-1)*norViewRegion,norTop+(i-1)*norViewRegion,self.zoomLvl);
				
				--uncomment the following code to use fixed function pipline
				--you also need to modify the Map3DApp.DataPvd.GetMap() method in Map3dAppDataPvd.lua,to return
				--a texture object instead of texture file name.
				
				--if(texture ~= nil)then
					--tile:SetReplaceableTexture(1,texture);
				--end
				
				--Note:I use a shader to render the 2D tile,set texture address mode to clamp to
				--avoide the seam between tiles. if you can turn on clamp address mode in fixed function pipline
				--then you can delete the code below
				local effect,effectHandle =  Map3DApp.Global.Material.GetSimpleTextured();
				tile:GetAttributeObject():SetField("render_tech",effectHandle);
				local params = tile:GetEffectParamBlock();
				params:SetTexture(0,texture);
			end
		end
	end
end

function Map2DLayer:Rotate(delta)
end

function Map2DLayer:Pitch(delta)
end

function Map2DLayer:CheckViewBound()
	local halfViewRegion = self.virtCam.viewRegion/2;
	if(self.virtCam.viewPosX + halfViewRegion > 1)then
		self.virtCam.viewPosX = 1 - halfViewRegion;
	elseif(self.virtCam.viewPosX - halfViewRegion < 0)then
		self.virtCam.viewPosX = halfViewRegion;
	end
	
	if(self.virtCam.viewPosY + halfViewRegion > 1)then
		self.virtCam.viewPosY = 1 - halfViewRegion;
	elseif(self.virtCam.viewPosY - halfViewRegion < 0)then
		self.virtCam.viewPosY = halfViewRegion;
	end
end

function Map2DLayer:ActiveRender(isActive)
	local scene = ParaScene.GetMiniSceneGraph(self.name);
	if(scene:IsValid())then
		scene:EnableActiveRendering(isActive);
	end
end

--get the current 2D map Resolution
function Map2DLayer:GetCurrentMapResolution()
	return self.tileSize * math.pow(2,self.zoomLvl - 1);
end

function Map2DLayer:GetPanStep()
	return 0.015/self:GetCurrentMapResolution();
end

function Map2DLayer:GetRenderTargetSize()
	return self.resolutionX,self.resolutionY;
end

--get current view params,including center point of view region
--zoom value and view region width
function Map2DLayer:GetViewParams()
	return self.virtCam.viewPosX,self.virtCam.viewPosY,self.virtCam.viewPosZ,self.virtCam.viewRegion;
end

function Map2DLayer:AddListener(name,listener)
	self.listeners[name] = listener;
end

function Map2DLayer:RemoveListener(name)
	self.listeners[name] = nil;
end

function Map2DLayer:SendMessage(msg)
	if(self.listeners)then
		for name,listener in pairs(self.listeners) do
			listener:SetMessage(self.name,msg);
		end
	end
end

function Map2DLayer:MousePick()
	return nil;
end


