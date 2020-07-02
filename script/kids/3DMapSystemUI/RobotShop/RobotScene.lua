--[[
Author(s): Leio
Date: 2007/12/11
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/RobotShop/RobotScene.lua");
Map3DSystem.UI.RobotScene.Init();
Map3DSystem.UI.RobotScene.SetContainer(c);
Map3DSystem.UI.RobotScene.SetAssetChar(path);
------------------------------------------------------------
		
]]
if(not Map3DSystem.UI.RobotScene) then Map3DSystem.UI.RobotScene={}; end
Map3DSystem.UI.RobotScene.Scene=nil;
Map3DSystem.UI.RobotScene.SceneContainer=nil;
Map3DSystem.UI.RobotScene.Player=nil;
Map3DSystem.UI.RobotScene.maxPitch = 2.8;
Map3DSystem.UI.RobotScene.minPitch = 1.6;
function Map3DSystem.UI.RobotScene.Init()
	local self=Map3DSystem.UI.RobotScene
	local scene = ParaScene.GetMiniSceneGraph("RobotShop3DScene");
	
	------------------------------------
	-- init render target
	------------------------------------
	-- reset scene, in case this is called multiple times
	scene:Reset();
	-- set size
	scene:SetRenderTargetSize(256, 256);
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
	
	scene:CameraZoomSphere(0,0,0,1);
	


	self.Scene=scene;
end
function Map3DSystem.UI.RobotScene.SetContainer(c)
	local self=Map3DSystem.UI.RobotScene;
		  if(self.SceneContainer==nil) then
			  self.SceneContainer=c;
			  self.SceneContainer.onmouseup = ";Map3DSystem.UI.RobotScene.OnMouseUp();";
			  self.SceneContainer.onmousewheel = ";Map3DSystem.UI.RobotScene.OnMouseWheel();";
			  self.SceneContainer.onmousemove = ";Map3DSystem.UI.RobotScene.OnMouseMove();";
			  self.SceneContainer.onmousedown = ";Map3DSystem.UI.RobotScene.OnMouseDown();";
			  self.SceneContainer.onmouseleave = ";Map3DSystem.UI.RobotScene.OnMouseLeave();";
		  end
end
function Map3DSystem.UI.RobotScene.SetAssetChar(path)
	local self=Map3DSystem.UI.RobotScene;
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
	local tmp = self.SceneContainer;
	if(tmp:IsValid()) then
		tmp:SetBGImage(scene:GetTexture());
	end
	
	self.Player=player;
end

function Map3DSystem.UI.RobotScene.RemovePlayer()
	local self=Map3DSystem.UI.RobotScene;
	if (self.Scene~=nil and self.Player~=nil) then
		--self.Scene:RemoveObject(self.Player);
		self.Scene:DestroyObject("assetChar");
	end
end
-----------------------------------mouse event
function Map3DSystem.UI.RobotScene.OnMouseDown()
	local self=Map3DSystem.UI.RobotScene;
	self.lastMousePosX = mouse_x;
	self.lastMousePosY = mouse_y;
	
	if(mouse_button=="left")then
		self.isLMBDown = true;
	elseif( mouse_button == "right")then
		self.isRMBDown = true;
	end
end
function Map3DSystem.UI.RobotScene.OnMouseUp()
	local self = Map3DSystem.UI.RobotScene;
	self.isLMBDown = false;
	self.isRMBDown = false;
end

function Map3DSystem.UI.RobotScene.OnMouseMove()
	local self = Map3DSystem.UI.RobotScene;
		
	if( self.isLMBDown)then
		local dx,dy;
		dx = self.lastMousePosX - mouse_x;
		dy = self.lastMousePosY - mouse_y;
		self.Rotate(-dx*0.1);
		self.Pitch(dy*0.1);
		self.lastMousePosX = mouse_x;
		self.lastMousePosY = mouse_y;
	end
	
end

function Map3DSystem.UI.RobotScene.OnMouseWheel()
	local self = Map3DSystem.UI.RobotScene;
	self.OnZoom(-mouse_wheel);
end

function Map3DSystem.UI.RobotScene.OnMouseLeave()
	local self = Map3DSystem.UI.RobotScene;
	self.isLMBDown = false;
	self.isRMBDown = false;
end

function Map3DSystem.UI.RobotScene.Pitch(delta)
	local self = Map3DSystem.UI.RobotScene;
	if(self.Scene == nil)then
		return;
	end
	
	local yaw,pitch,dist = self.Scene:CameraGetEyePosByAngle();
	pitch = pitch + delta * 0.05;
	
	self.Scene:CameraSetEyePosByAngle(yaw,pitch,dist);
end

function Map3DSystem.UI.RobotScene.Rotate(delta)
	local self = Map3DSystem.UI.RobotScene;
	if(self.Scene == nil)then
		return;
	end
	
	local yaw,pitch,dist = self.Scene:CameraGetEyePosByAngle();
	yaw = yaw + delta * 0.5;
	
	self.Scene:CameraSetEyePosByAngle(yaw,pitch,dist);
end
function Map3DSystem.UI.RobotScene.OnZoom(delta)
	local self = Map3DSystem.UI.RobotScene;
	if(self.Scene == nil)then
		return;
	end
	local yaw,pitch,dist = self.Scene:CameraGetEyePosByAngle();
	dist=dist+delta*0.5;
	self.Scene:CameraSetEyePosByAngle(yaw,pitch,dist);
end