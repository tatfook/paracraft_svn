
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppCommon.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppAssetManager.lua");



Map3DApp.TileEditScene = {};
Map3DApp.TileEditScene.name = "tileEditScene";

--layout 
Map3DApp.TileEditScene.alignment = "_fi";
Map3DApp.TileEditScene.left = 2;
Map3DApp.TileEditScene.top = 2;
Map3DApp.TileEditScene.width = 2;
Map3DApp.TileEditScene.height =2;
Map3DApp.TileEditScene.parent = nil;

--render targe size
Map3DApp.TileEditScene.resolutionX = 512;
Map3DApp.TileEditScene.resolutionY = 512;

Map3DApp.TileEditScene.scene = nil;
Map3DApp.TileEditScene.tileSize = 4;
Map3DApp.TileEditScene.timerID =  Map3DApp.Timer.GetNewTimerID();

Map3DApp.TileEditScene.activeModel = nil;
Map3DApp.TileEditScene.activeCmd = nil;
Map3DApp.TileEditScene.modelData = nil;
Map3DApp.TileEditScene.editState=0;

--mouse state
Map3DApp.TileEditScene.isLMBDown = false;
Map3DApp.TileEditScene.isRMBDown = false;
Map3DApp.TileEditScene.lastMousePosX = 0;
Map3DApp.TileEditScene.lastMousePosY = 0;
Map3DApp.TileEditScene.mouseDownPosX = 0;
Map3DApp.TileEditScene.mouseDownPosY = 0;

--camera parameters
Map3DApp.TileEditScene.maxZoomValue = 15;
Map3DApp.TileEditScene.minZoomValue = 5;
Map3DApp.TileEditScene.zoomValue = 1;
Map3DApp.TileEditScene.minPitch = 0.4;
Map3DApp.TileEditScene.maxPitch = 1.57;
Map3DApp.TileEditScene.pitchValue = 0.5;
Map3DApp.TileEditScene.rotateValue = 0;
Map3DApp.TileEditScene.defaultRotate = 0;

Map3DApp.TileEditScene.Camera = {};
Map3DApp.TileEditScene.Camera.fov = math.pi/6;
Map3DApp.TileEditScene.Camera.nearPlane = 0.5;
Map3DApp.TileEditScene.Camera.farPlane = 150;
Map3DApp.TileEditScene.Camera.aspectRatio = 1; 

--release all resource 
function Map3DApp.TileEditScene.Release()
	local self = Map3DApp.TileEditScene;
	if(self.name ~= nil or self.name ~= "")then
		ParaUI.Destroy(self.name);
		ParaScene:DeleteMiniSceneGraph(self.name);
		self.scene = nil;
	end
end

--show the tile edit scene
function Map3DApp.TileEditScene.Show(bShow)
	local self = Map3DApp.TileEditScene;
	local _this = ParaUI.GetUIObject(self.name);

	if(_this:IsValid() == false)then
		if(bShow == false)then
			return;
		end
		self.CreateUI();
	else
		if(bShow == nil)then
			_this.visible = not _this.visible;
		else
			_this.visible = bShow;
		end
		if(_this.visible == false)then
			self.ClearAllModel();
		end
		local scene = ParaScene.GetMiniSceneGraph(self.name);
		if(scene:IsValid())then
			scene:EnableActiveRendering(_this.visible);
		end
	end
end

--set parent control
function  Map3DApp.TileEditScene.SetParent(pWnd)
	Map3DApp.TileEditScene.parent = pWnd;
end

--zoom camera,zoomValue is in range[0,1],0 is max zoom;
function Map3DApp.TileEditScene.Zoom(zoomValue)
	local self = Map3DApp.TileEditScene;
	if(zoomValue > 1)then
		zoomValue = 1;
	elseif(zoomValue < 0)then
		zoomValue = 0;
	end
	
	self.zoomValue = zoomValue;
	local scene = ParaScene.GetMiniSceneGraph(self.name);
	if(scene:IsValid() == false)then
		return;
	end
	
	local rotate,pitch = scene:CameraGetEyePosByAngle();
	scene:CameraSetEyePosByAngle(rotate,pitch,(self.maxZoomValue - self.minZoomValue)*self.zoomValue + self.minZoomValue);
end

--pitch camera
function Map3DApp.TileEditScene.Pitch(pitchValue)
	local self = Map3DApp.TileEditScene;
	if(pitchValue > 1)then
		pitchValue = 1;
	elseif(pitchValue < 0)then
		pitchValue = 0;
	end
	
	self.pitchValue = pitchValue;
	
	local scene = ParaScene.GetMiniSceneGraph(self.name);
	if(scene:IsValid() == false)then
		return;
	end
	
	local rotate,__,zoom = scene:CameraGetEyePosByAngle();
	scene:CameraSetEyePosByAngle(rotate,(self.maxPitch - self.minPitch)*self.pitchValue+self.minPitch,zoom);
end

--add new model to scene
function Map3DApp.TileEditScene.AddModel(modelName,modelData)
	if(modelData == nil)then
		return;
	end

	local self = Map3DApp.TileEditScene;
	local scene = ParaScene.GetMiniSceneGraph(self.name);
	if(scene:IsValid())then
		modelData:Draw(scene,modelName,self.tileSize)
	end
end

function Map3DApp.TileEditScene.AddModel(modelName,modelInstance)
	
end

--set model position by model ID
function Map3DApp.TileEditScene.SetModelPosition(modelID,x,y,z)
	local self = Map3DApp.TileEditScene;
	if(modelID)then
		local scene = ParaScene.GetMiniSceneGraph(self.name);
		if(scene:IsValid())then
			local model = scene:GetObject(modelID);
			model:SetPosition(x*self.tileSize/2 ,y,z*self.tileSize/2);
		end
	end
end

--set model facing by ID
function Map3DApp.TileEditScene.SetModelFacing(modelID,facing)
	local self = Map3DApp.TileEditScene;
	if(modelID)then
		local scene = ParaScene.GetMiniSceneGraph(self.name);
		if(scene:IsValid())then
			local model = scene:GetObject(modelID);
			model:SetFacing(facing);
		end
	end
end

--show the model by ID
function Map3DApp.TileEditScene.ShowModel(modelID,bShow)
	local self = Map3DApp.TileEditScene;
	if(modelID)then
		local scene = ParaScene.GetMiniSceneGraph(self.name);
		if(scene:IsValid())then
			local model = scene:GetObject(modelID);
			if(model:IsValid())then
				model:SetVisible(bShow);
			end
		end
	end
end

--remove model
function Map3DApp.TileEditScene.RemoveModel(modelName)
	local self = Map3DApp.TileEditScene;
	if(modelName ~= nil and modelName ~= "")then
		local scene = ParaScene.GetMiniSceneGraph(self.name);
		if(scene:IsValid())then
			scene:DestroyObject(modelName);
		end
	end
end

--clear all model in scene
function Map3DApp.TileEditScene.ClearAllModel()
	local self = Map3DApp.TileEditScene;
	local scene = ParaScene.GetMiniSceneGraph(self.name);
	scene:DestroyChildren();
	self.ResetScene();
end

--get model position,the reture model position is in range[-1,1]
function Map3DApp.TileEditScene.GetModelPosition(modelName)
	if(modelName == nil or modelName == "")then
		return;
	end
	
	local self = Map3DApp.TileEditScene;
	local scene = ParaScene.GetMiniSceneGraph(self.name);
	if(scene:IsValid()== false)then
		return;
	end
	
	local obj = scene:GetObject(modelName);
	if(obj == nil)then
		return;
	end
	
	local x,__,y = obj:GetPosition();
	
	x  = x / self.tileSize * 2;
	y = y / self.tileSize * 2;
	
	return x,0,y;
end

function Map3DApp.TileEditScene.SetTerrainInfo(terrainInfo)
end

--set current active model
function Map3DApp.TileEditScene.SetActiveModel(modelName)
	Map3DApp.TileEditScene.activeModel = modelName;
end

--set tile edit scene message handle
function Map3DApp.TileEditScene.SetMsgCallback(callback)
	Map3DApp.TileEditScene.msgHandle = callback;
end

--set a command object 
function Map3DApp.TileEditScene.SetCommand(cmd)
	Map3DApp.TileEditScene.activeCmd = cmd;
end

function Map3DApp.TileEditScene.SetEditState(editState)
	Map3DApp.TileEditScene.editState = editState;
end

--=============private method===================
function Map3DApp.TileEditScene.CreateUI()
	local self = Map3DApp.TileEditScene;
	local _this,_parent;
	_this = ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
	_this.onmousedown = ";Map3DApp.TileEditScene.OnMouseDown()";
	_this.onmousemove = ";Map3DApp.TileEditScene.OnMouseMove()";
	_this.onmouseleave =";Map3DApp.TileEditScene.OnMouseLeave()";
	_this.onmousewheel =";Map3DApp.TileEditScene.OnMouseWheel()";
	_this.onmouseenter =";Map3DApp.TileEditScene.OnMouseEnter()";
	_this.onmouseup = ";Map3DApp.TileEditScene.OnMouseUp()";
	_this.onsize = ";Map3DApp.TileEditScene.OnResize()";
	if(self.parent == nil)then
		_this:AttachToRoot();
	else
		self.parent:AddChild(_this);
	end
	_parent = _this;
	
	local scene = ParaScene.GetMiniSceneGraph(self.name);
	local obj = scene:GetObject(self.name);
	if(obj:IsValid() == false)then
		self.ResetScene();
	end
	_this:SetBGImage(scene:GetTexture());
	
	NPL.load("(gl)script/kids/3DMapSystemUI/Map/SideBar/TileEditPanel.lua");
	Map3DApp.TileEditPanel.SetParent(_parent);
	Map3DApp.TileEditPanel.Show(true);
end

function Map3DApp.TileEditScene.ResetScene()
	local self = Map3DApp.TileEditScene;
	local scene = ParaScene.GetMiniSceneGraph(self.name);
	scene:Reset();
	scene:SetRenderTargetSize(self.resolutionX,self.resolutionY);
	scene:EnableCamera(true);
	scene:EnableActiveRendering(true);

	local att = scene:GetAttributeObject();
	att:SetField("BackgroundColor", {0.937, 0.968, 1}); 
	
	local initPitch;
	self.defaultRotate,initPitch = scene:CameraGetEyePosByAngle();
	self.pitchValue = (initPitch - self.minPitch)/(self.maxPitch - self.minPitch);
	self.Zoom(1);
	
	local model = Map3DApp.Global.AssetManager.GetModel("model/common/map3D/map3D.x");
	if(model ~= nil)then
		local plane = ParaScene.CreateMeshPhysicsObject(self.name,model,1,1,1,false,"1,0,0,0,1,0,0,0,1,0,0,0");
		local texture = Map3DApp.Global.AssetManager.GetTexture("model/map3D/grid.dds");
		if(texture ~= nil)then
			plane:SetReplaceableTexture(1,texture);
		end
		plane:SetScale(self.tileSize);
		plane:GetAttributeObject():SetField("progress",1);
		scene:AddChild(plane);
	end
end

function Map3DApp.TileEditScene.DragModel()
	local self = Map3DApp.TileEditScene;
	
	if(self.activeModel == nil or self.activeModel == "")then
		return;
	end

	local scene = ParaScene.GetMiniSceneGraph(self.name);
	if(scene:IsValid() == fasle)then
		return;
	end
	
	local ctr = ParaUI.GetUIObject(self.name);
	if(ctr:IsValid() == false)then
		return;
	end
	
	local x,y,width,height = ctr:GetAbsPosition();
	local halfWidth = width/2;
	local halfHeight = height/2;
	
	local dx = (mouse_x - x - halfWidth)/halfWidth;
	local dy = -(mouse_y - y - halfHeight)/halfHeight;
	
	x,y = self.ProjectPointTo3D(dx,dy);
	x = x * 2 / self.tileSize;
	y = y * 2 / self.tileSize;
	self.SetModelPosition(self.activeModel,x,0,y);
	
	if(self.onCollisionDetect ~= nil)then
		if(self.onCollisionDetect())then
			
		else 
		
		end
	end
end

function Map3DApp.TileEditScene.ProjectPointTo3D(x,y)
	local self = Map3DApp.TileEditScene;
	local scene = ParaScene.GetMiniSceneGraph(self.name);
	if(scene:IsValid() == false)then
		return;
	end
	
	local __,pitch,distance = scene:CameraGetEyePosByAngle();
	local camProjY = distance * math.cos(pitch);
	local camElev = distance * math.sin(pitch);
	
	local camera = self.Camera;
	local viewPlaneWidth = math.tan(camera.fov / 2) * camera.nearPlane;
	local viewPlaneHeight = viewPlaneWidth / camera.aspectRatio;
	
	--project y position
	local theta = math.atan(math.abs(y) * viewPlaneHeight/camera.nearPlane);
	local alpha = math.pi/2 - pitch;
	local delta;
	if(y < 0)then
		delta = alpha - theta;
	else
		delta=  alpha + theta;
	end
	local projection = camElev * math.tan(delta);
	local resultY = projection - camProjY;

	--project x position
	local dist = camElev / math.cos(delta);
	theta = math.atan(math.abs(x) * viewPlaneWidth / camera.nearPlane);
	local resultX = dist * math.tan(theta);
	if(x < 0)then
		resultX = - resultX;
	end

	return resultX,resultY;
end

function Map3DApp.TileEditScene.MousePick()
	local self = Map3DApp.TileEditScene;
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		return;
	end
	
	local x,y,width,height = _this:GetAbsPosition();
	local dx = (mouse_x - x)/width * self.resolutionX;
	local dy = (mouse_y - y)/height * self.resolutionY;

	local scene = ParaScene.GetMiniSceneGraph(self.name);
	if(scene:IsValid() == false)then
		return
	end
	
	local selectItem = scene:MousePick(dx,dy,50,"mesh");
	if(selectItem:IsValid() and selectItem.name ~= self.name)then
		self.SetActiveModel(selectItem.name);
		self.SetEditState(self.EditState.modify);
	else
		self.SetActiveModel();
		self.SetEditState(self.EditState.none);
	end
	
	return selectItem;
end

function Map3DApp.TileEditScene.RotateCam(rotateValue)
	local self = Map3DApp.TileEditScene;
	
	local scene = ParaScene.GetMiniSceneGraph(self.name);
	if(scene:IsValid() == false)then
		return;
	end
	
	self.rotateValue = math.mod(rotateValue,math.pi*2);
	
	local __,pitch,zoom = scene:CameraGetEyePosByAngle();
	scene:CameraSetEyePosByAngle(rotateValue,pitch,zoom);
end

function Map3DApp.TileEditScene.SetToDefaultRotate()
	if(Map3DApp.TileEditScene.rotateValue ~= Map3DApp.TileEditScene.defaultRotate)then
		NPL.SetTimer(Map3DApp.TileEditScene.timerID,0.01,";Map3DApp.TileEditScene.ResetCamRotate()");
	end
end

function Map3DApp.TileEditScene.ResetCamRotate()
	local self = Map3DApp.TileEditScene;
	local killTimer = false;
	local deltaRotate = self.defaultRotate - self.rotateValue;
	local rotatStep = 0.2;
	if(deltaRotate >= 0)then
		if(deltaRotate > rotatStep)then
			self.rotateValue = self.rotateValue + rotatStep;
		else
			self.rotateValue = self.defaultRotate;
			killTimer = true;
		end
	elseif(deltaRotate< 0)then
		if(deltaRotate > -rotatStep)then
			self.rotateValue = self.defaultRotate;
			killTimer = true;
		else
			self.rotateValue = self.rotateValue - rotatStep;
		end
	end
	
	local scene = ParaScene.GetMiniSceneGraph(self.name);
	if(scene:IsValid() == false)then
		return;
	end
	
	local __,pitch,zoom = scene:CameraGetEyePosByAngle();
	scene:CameraSetEyePosByAngle(self.rotateValue,pitch,zoom);
	
	if(killTimer)then
		NPL.KillTimer(self.timerID);
	end
end

function Map3DApp.TileEditScene.OnResize()
	local self = Map3DApp.TileEditScene;
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid()==false)then
		return;
	end
	
	local x,y,width,height = _this:GetAbsPosition();
	local __,__,_width,_height = Map3DApp.TileEditPanel.GetAbsPosition();
	
	if(_width ~= nil and _height ~= nil)then
		Map3DApp.TileEditPanel.SetPosition((width - _width)/2,height - _height);
	end
end

function Map3DApp.TileEditScene.SendMessage(msg,data)
	local self = Map3DApp.TileEditScene;
	if(self.msgHandle)then
		self.msgHandle(msg,data);
	end
end

--==========mouse event handler================
function Map3DApp.TileEditScene.OnMouseDown()
	local self = Map3DApp.TileEditScene;
	
	self.lastMousePosX = mouse_x;
	self.lastMousePosY = mouse_y;
	
	if(mouse_button == "left")then
		self.isLMBDown = true;
		if(self.editState == self.EditState.none)then
			self.mouseDownPosX = mouse_x;
			self.mouseDownPosY = mouse_y;
			
		elseif(self.editState == self.EditState.add)then
			local x,y,z = self.GetModelPosition(self.activeModel);
			local data = {};
			data.modelID = self.activeModel;
			data.x = x * 2 / self.tileSize;
			data.y = z * 2 / self.tileSize;
			self.SendMessage(self.Msg.addModel,data);
			self.SetActiveModel();
			self.SetEditState(self.EditState.reserved);
			
		elseif(self.editState == self.EditState.modify)then
			--local lastActiveModel = self.activeModel;
			self.MousePick();
			self.mouseDownPosX = mouse_x;
			self.mouseDownPosY = mouse_y;
			--if(lastActiveModel ~= self.activeModel or self.activeModel == nil)then
				--self.SetEditState(self.EditState.reserved);
			--end
			
			--local selectItem = self.MousePick();
			
		end
	elseif(mouse_button == "right")then
		self.isRMBDown = true;
		if(self.editState == self.EditState.none)then
			self.SetEditState(self.EditState.adjustCamPos);
		elseif(self.editState == self.EditState.add)then
			if(self.activeCmd ~= nil)then
				self.activeCmd:Undo();
			end
			self.SetActiveModel();
			self.SetEditState(self.EditState.reserved);
		elseif(self.editState == self.EditState.modify)then
			self.SetEditState(self.EditState.adjustCamPos);
			self.SendMessage(self.Msg.modelSelect,nil)
			self.SetActiveModel();
		end
	end
end

function Map3DApp.TileEditScene.OnMouseMove()
	local self = Map3DApp.TileEditScene;
	
	local dx,dy;
	dx = self.lastMousePosX - mouse_x;
	dy = self.lastMousePosY - mouse_y;
	
	if(self.isRMBDown == true)then
		if(self.editState == self.EditState.adjustCamPos)then
			self.Pitch(self.pitchValue - dy * 0.01);
			self.RotateCam(self.rotateValue - dx * 0.01);
		end
	end
	
	if(self.editState == self.EditState.add)then
		self.DragModel();
	end
	
	if(self.isLMBDown)then
		if(self.editState == self.EditState.modify)then
			self.DragModel();
		end
	end

	self.lastMousePosX = mouse_x;
	self.lastMousePosY = mouse_y;
end

function Map3DApp.TileEditScene.OnMouseUp()
	local self = Map3DApp.TileEditScene;

	if(self.isLMBDown)then
		if(self.editState == self.EditState.none)then
			if(math.abs(self.mouseDownPosX - mouse_x)<5 and
				math.abs(self.mouseDownPosY - mouse_y)<5)then
				self.OnMouseClick();
			end
		elseif(self.editState == self.EditState.modify)then
			local x,y,z = self.GetModelPosition(self.activeModel);
			local data = {};
			data.modelID = self.activeModel;
			data.x = x;
			data.y = z;
			self.SendMessage(self.Msg.modelPosChange,data);
		end
	elseif(self.isRMBDown)then
		if(self.editState == self.EditState.adjustCamPos)then
			self.SetEditState(self.EditState.none);
			self.SetToDefaultRotate();
		end
	end
	
	self.isLMBDown = false;
	self.isRMBDown = false;

	if(self.editState == self.EditState.reserved)then
		self.SetEditState(self.EditState.none);
	end
	
end

function Map3DApp.TileEditScene.OnMouseClick()
	local selectItem = Map3DApp.TileEditScene.MousePick();
	Map3DApp.TileEditScene.SendMessage(Map3DApp.TileEditScene.Msg.modelSelect,selectItem)
end

function Map3DApp.TileEditScene.OnMouseLeave()
	local self = Map3DApp.TileEditScene;

	if(self.editState == self.EditState.add)then
		self.ShowModel(self.activeModel,false);
	end
end

function Map3DApp.TileEditScene.OnMouseWheel()
	local self = Map3DApp.TileEditScene;
	self.Zoom(self.zoomValue - mouse_wheel * 0.1);
end

function Map3DApp.TileEditScene.OnMouseEnter()
	local self = Map3DApp.TileEditScene;

	if(self.editState == self.EditState.add)then
		self.ShowModel(self.activeModel,true);
	end
end



----msg enum
Map3DApp.TileEditScene.Msg = {};
Map3DApp.TileEditScene.Msg.addModel = 0;
Map3DApp.TileEditScene.Msg.modelPosChange = 1;
Map3DApp.TileEditScene.Msg.modelSelect = 2;


--edit state enum
Map3DApp.TileEditScene.EditState = {};
Map3DApp.TileEditScene.EditState.none = 0;
Map3DApp.TileEditScene.EditState.add = 1;
Map3DApp.TileEditScene.EditState.modify = 2;
Map3DApp.TileEditScene.EditState.adjustCamPos = 3;
Map3DApp.TileEditScene.EditState.reserved = 4;

