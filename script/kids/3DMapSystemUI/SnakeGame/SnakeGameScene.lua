--[[
Author(s): Leio
Date: 2007/12/17
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/SnakeGame/SnakeGameScene.lua");
Map3DSystem.UI.SnakeGameScene.Init(c);
------------------------------------------------------------
		
]]
if(not Map3DSystem.UI.SnakeGameScene) then Map3DSystem.UI.SnakeGameScene={}; end
Map3DSystem.UI.SnakeGameScene.Scene=nil;
Map3DSystem.UI.SnakeGameScene.SceneContainer=nil;
Map3DSystem.UI.SnakeGameScene.Player=nil;
Map3DSystem.UI.SnakeGameScene.MaxPitch = 2.8;
Map3DSystem.UI.SnakeGameScene.MinPitch = 1.6;
Map3DSystem.UI.SnakeGameScene.ModelFile = "model/common/map3D/map3D.x";
Map3DSystem.UI.SnakeGameScene.AssetModel=nil;
function Map3DSystem.UI.SnakeGameScene.Init(c)
	local self=Map3DSystem.UI.SnakeGameScene;
	local scene = ParaScene.GetMiniSceneGraph("RobotShop3DScene");
	
	------------------------------------
	-- init render target
	------------------------------------
	-- reset scene, in case this is called multiple times
	scene:Reset();
	-- set size
	scene:SetRenderTargetSize(780, 540);
	-- enable camera and create render target
	scene:EnableCamera(true);
	-- render it each frame automatically. 
	-- Note: If content is static, one should disable this, and call scene:draw() in a script timer.
	scene:EnableActiveRendering(true);
	-- If one wants an over lay, here it is.
	--scene:SetMaskTexture(ParaAsset.LoadTexture("","anything you want.dds",1));
	
	------------------------------------
	-- init camera
	------------------------------------
	-- automatically adjust the camera to watch a sphere in its integrity. 
	-- Note: Alternatively, one can call scene:CameraSetLookAtPos() and scene:CameraSetEyePos() to gain precise control.
	--[[
	local att = scene:GetAttributeObject();
		
		-- this color is shown only when no fog is specified. 
		att:SetField("BackgroundColor", {0, 0, 1});  -- blue background
		
		-- test fog
		att:SetField("EnableFog", false);
		att:SetField("FogColor", {1, 0, 0}); -- red fog
		att:SetField("FogStart", 5);
		att:SetField("FogEnd", 25);
		att:SetField("FogDensity", 0.5);
		
		-- test skybox
		att:SetField("ShowSky", true);
		scene:CreateSkyBox ("MySkybox", ParaAsset.LoadStaticMesh ("", "model/Skybox/Skybox1/Skybox1.x"), 100,100,100, 0);
		local attSky = scene:GetAttributeObjectSky();
		attSky:SetField("SkyColor", {1,1,1}); -- white sky
		--]]
	scene:CameraZoomSphere(0,0,0,1);
	scene:SetBackGroundColor("0 0 0 0");
	

	
	
	self.SetContainer(c);
	self.AssetModel = ParaAsset.LoadStaticMesh("",self.ModelFile)
	self.Scene=scene;
	local tmp = self.SceneContainer;
	if(tmp:IsValid()) then
		tmp:SetBGImage(scene:GetTexture());
	end
	
	local yaw,pitch,dist = self.Scene:CameraGetEyePosByAngle();
	dist=25;
	self.Scene:CameraSetEyePosByAngle(yaw,pitch,dist);
end
function Map3DSystem.UI.SnakeGameScene.SetContainer(c)
	local self=Map3DSystem.UI.SnakeGameScene;
		  --if(self.SceneContainer==nil) then
			  self.SceneContainer=c;
			  self.SceneContainer.onmouseup = ";Map3DSystem.UI.SnakeGameScene.OnMouseUp();";
			  self.SceneContainer.onmousewheel = ";Map3DSystem.UI.SnakeGameScene.OnMouseWheel();";
			  self.SceneContainer.onmousemove = ";Map3DSystem.UI.SnakeGameScene.OnMouseMove();";
			  self.SceneContainer.onmousedown = ";Map3DSystem.UI.SnakeGameScene.OnMouseDown();";
			  self.SceneContainer.onmouseleave = ";Map3DSystem.UI.SnakeGameScene.OnMouseLeave();";
		  --end
end
function Map3DSystem.UI.SnakeGameScene.SetAssetChar(path)
	local self=Map3DSystem.UI.SnakeGameScene;
		  self.RemovePlayer();
	local scene=self.Scene;
	local assetChar = ParaAsset.LoadParaX("", path);
	local player = ParaScene.CreateCharacter ("assetChar", assetChar, "", true, 0.0, 1.0, 1.0);
	if( player:IsValid()) then
		player:SetPosition(0, 0, 0);
		scene:AddChild(player);
	end	
	------------------------------------
	-- assign the texture to UI
	------------------------------------
	
	
	self.Player=player;
end

function Map3DSystem.UI.SnakeGameScene.RemovePlayer()
	local self=Map3DSystem.UI.SnakeGameScene;
	if (self.Scene~=nil and self.Player~=nil) then
		--self.Scene:RemoveObject(self.Player);
		self.Scene:DestroyObject("assetChar");
	end
end
-----------------------------------mouse event
function Map3DSystem.UI.SnakeGameScene.OnMouseDown()
	local self=Map3DSystem.UI.SnakeGameScene;
	self.lastMousePosX = mouse_x;
	self.lastMousePosY = mouse_y;
	
	if(mouse_button=="left")then
		self.isLMBDown = true;
	elseif( mouse_button == "right")then
		self.isRMBDown = true;
	end
end
function Map3DSystem.UI.SnakeGameScene.OnMouseUp()
	local self = Map3DSystem.UI.SnakeGameScene;
	self.isLMBDown = false;
	self.isRMBDown = false;
end

function Map3DSystem.UI.SnakeGameScene.OnMouseMove()
	local self = Map3DSystem.UI.SnakeGameScene;
		
	if( self.isLMBDown)then
		local dx,dy;
		dx = self.lastMousePosX - mouse_x;
		dy = self.lastMousePosY - mouse_y;
		--self.Rotate(-dx*0.1);
		self.Pitch(dy*0.1);
		self.lastMousePosX = mouse_x;
		self.lastMousePosY = mouse_y;
	end
	
end

function Map3DSystem.UI.SnakeGameScene.OnMouseWheel()
	local self = Map3DSystem.UI.SnakeGameScene;
	self.OnZoom(-mouse_wheel);
end

function Map3DSystem.UI.SnakeGameScene.OnMouseLeave()
	local self = Map3DSystem.UI.SnakeGameScene;
	self.isLMBDown = false;
	self.isRMBDown = false;
end

function Map3DSystem.UI.SnakeGameScene.Pitch(delta)
	local self = Map3DSystem.UI.SnakeGameScene;
	if(self.Scene == nil)then
		return;
	end
	
	local yaw,pitch,dist = self.Scene:CameraGetEyePosByAngle();
	pitch = pitch + delta * 0.05;
	
	self.Scene:CameraSetEyePosByAngle(yaw,pitch,dist);
end

function Map3DSystem.UI.SnakeGameScene.Rotate(delta)
	local self = Map3DSystem.UI.SnakeGameScene;
	if(self.Scene == nil)then
		return;
	end
	
	local yaw,pitch,dist = self.Scene:CameraGetEyePosByAngle();
	yaw = yaw + delta * 0.5;
	
	self.Scene:CameraSetEyePosByAngle(yaw,pitch,dist);
end
function Map3DSystem.UI.SnakeGameScene.OnZoom(delta)
	local self = Map3DSystem.UI.SnakeGameScene;
	if(self.Scene == nil)then
		return;
	end
	local yaw,pitch,dist = self.Scene:CameraGetEyePosByAngle();
	dist=dist+delta*0.5;
	self.Scene:CameraSetEyePosByAngle(yaw,pitch,dist);
end