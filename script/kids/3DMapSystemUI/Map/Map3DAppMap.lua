
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3D_3DMap.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3D_2DMap.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppAnimationPlayer.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/MapMessageDefine.lua");


Map3DApp.WorldMap = {};

Map3DApp.WorldMap.DisplayState = {};
Map3DApp.WorldMap.DisplayState.D2 = 1;
Map3DApp.WorldMap.DisplayState.D3 = 2;


local Map = {
	name = "worldMap";
	
	alignment = "_fi";
	left = 2;
	top = 2;
	width = 2;
	height =2;
	sceneWidth = 512;
	sceneHeight = 512;

	parent = nil;
	layer3D = nil;
	layer2D = nil;
	activeLayer = nil;
	displayState = Map3DApp.WorldMap.DisplayState.D2;
	
	--
	enable = true;
	inverseMouse = false;
	isLMBDown = false;
	isRMBDown = false;
	lastMousePosX = 0;
	lastMousePosY = 0;
	mouseDownPosX = 0;
	mouseDownPosY = 0;
	pitchStep = 0.02;
	rotateStep = 0.02;
	zoomStep = 0.02;
	
	listeners = {};
	selectItem = nil;
}
Map3DApp.WorldMap.Map = Map;

--============public================
function Map:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	o:Init();
	return o;
end

function Map:Destory()

end

function Map:Show(bShow)	
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		if(bShow == false)then
			return;
		end
		self:CreateUI();
		self:Reset();
	else
		if(bShow == nil)then
			_this.visible = not _this.visible;
		else
			_this.visible = bShow;
		end
		
		--reset to default state every time open the map
		if(_this.visible)then
			self:Reset();
		else
			--stop all rendering when invisible
			self.layer2D:ActiveRender(false);
			self.layer3D:ActiveRender(false);
		end
	end
end

--if allow use to drag and zoom the map
--@params isEnable:bool
function Map:SetEnable(isEnable)
	self.enable = isEnable;
end

--jump to a point on 3D map
function Map:JumpTo3D(x,y)
	self:SetDisplayState(Map3DApp.WorldMap.DisplayState.D3);
	self.activeLayer:SetViewElevation(0.1);
	self.activeLayer:SetViewPosition(x,y);
end

function Map:Pan(dx,dy)
	dx = dx * self.activeLayer:GetPanStep();
	dy = dy * self.activeLayer:GetPanStep();
	self.activeLayer:Pan(dx,dy);
	self:FireViewRegionChange();
end

function Map:Pitch(delta)
	self.activeLayer:Pitch(delta);
	self:FireViewRegionChange();
end

function Map:Rotate(delta)
	self.activeLayer:Rotate(delta);
	self:FireViewRegionChange()
end

function Map:Zoom(delta)
	self.activeLayer:Zoom(delta);
	self:FireViewRegionChange()
end

--center map to (x,y) 
--@params x:in normalized world coordinate
--@params y:in normalized world coordinate
function Map:SetViewPosition(x,y)
	if(self.activeLayer ~= nil)then
		self.activeLayer:SetViewPosition(x,y);
	end
end

--zoom map,
--@params value:rang in [0,1]
function Map:SetZoomValue(value)
	if(self.activeLayer ~= nil)then
		self.activeLayer:SetViewElevation(value);
	end
end

--set map display mode 2D or 3D
--@params displayState:Map3DApp.WorldMap.DisplayState enum
function Map:SetDisplayState(displayState)
	if(self.displayState == displayState)then
		return;
	end

	--get target map layer
	local targetLayer = nil;
	if(displayState == Map3DApp.WorldMap.DisplayState.D2)then
		targetLayer = self.layer2D;
	elseif(displayState == Map3DApp.WorldMap.DisplayState.D3)then
		targetLayer = self.layer3D;
	end
	if(targetLayer == nil)then
		return;
	end
	
	--save last map position
	local viewPosX,viewPoxY;
	self.activeLayer:ActiveRender(false);
	viewPosX,viewPosY = self.activeLayer:GetViewParams();
	
	--set new map layer,restore view position
	self.activeLayer = targetLayer;
	self.displayState = displayState;
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid())then
		_this:SetBGImage(self.activeLayer:GetMap());
		self.activeLayer:ActiveRender(true);
		self.activeLayer:ResetCamera();
		self.activeLayer:SetViewPosition(viewPosX,viewPosY);
	end
	
	--_this = ParaUI.GetUIObject(self.name.."mask");
	--if(_this:IsValid())then
		--_this.visible = true;
		--self.cloudLayer:Play(false,false);
	--end
	_this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid())then
		self.cloudLayer:SetParent(_this);
		self.cloudLayer:Show(true);
		self.cloudLayer:Play(false,false);
	end
	
	self:SendMessage(Map3DApp.Msg.onMapDisplayStateChanged);
end

--set window position
function Map:SetWndPosition(x,y)
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid())then
		_this.x = x;
		_this.y = y;
	end
end

--set window size
function Map:SetWndSize(width,height)
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid())then
		_this.width = width;
		_this.height = height;
	end
end

--get window top left point positio and window width,height
function Map:GetWndPosition()
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid())then
		return _this:GetAbsPosition();
	else
		return nil
	end
end

--get current displayer mode
function Map:GetDisplayMode()
	return self.displayState;
end

--get view parameters
function Map:GetViewParams()
	if(self.activeLayer ~= nil)then
		return self.activeLayer:GetViewParams();
	end
end

--return the map window container
--allow other object draw extra element on this map
function Map:GetWnd()
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid())then
		return _this;
	else
		return nil
	end
end

--set parent control
function Map:SetParentWnd(parentWnd)
	self.parent = parentWnd;
	
	ParaUI.Destroy(self.name);
	self:CreateUI();
	self:Reset();
end	

--do mouse pick
function Map:MousePick()
	local rtX,rtY = self.activeLayer:GetRenderTargetSize();
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		return;
	end
	local x,y,width,height = _this:GetAbsPosition()
	local dx = (mouse_x - x)/width * rtX;
	local dy = (mouse_y - y)/height * rtY;

	self.selectItem = self.activeLayer:MousePick(dx,dy);
	if(self.selectItem == nil)then
		return;
	end
	
	local type = self.selectItem:GetAttributeObject():GetDynamicField("objType",nil);
	if(type == nil)then
		return;
	elseif(type == "land")then
		local tileId = self.selectItem:GetAttributeObject():GetDynamicField("attValue",nil);
		if(tileId == nil)then
			return;
		else
			NPL.load("(gl)script/ide/WindowFrame.lua");
			Map3DSystem.App.Commands.Call("File.MCMLWindowFrame",{
				url = "script/kids/3DMapSystemUI/Map/pe_land.html?tileID="..tileId,
				name = "pe_land",
				isShowTitleBar = true,
				text = "土地信息",
				initialWidth = 400,
				initialHeight = 120,
				style = CommonCtrl.WindowFrame.DefaultStyle,
				alignment = "Free",
				allowResize = false,
			});
		end
	end
end

--fire view region changed event
function Map:FireViewRegionChange()
	self:SendMessage(Map3DApp.Msg.mapViewRegionChanged);
end

function Map:SetMessage(sender,msg)
	if(msg == Map3DApp.Msg.onMinZoom)then
		if(sender == self.layer3D.name)then
			self:SetDisplayState(Map3DApp.WorldMap.DisplayState.D2);
			self.activeLayer:SetViewElevation(0.98);
		end
	elseif(msg == Map3DApp.Msg.onMaxZoom)then
		if(sender == self.layer2D.name)then
			self:SetDisplayState(Map3DApp.WorldMap.DisplayState.D3)
		end
	elseif(msg == Map3DApp.Msg.onAnimationEnd)then
		local _this = CommonCtrl.GetControl(sender);
		if(_this)then
			_this:Show(false);
		end
	end
end

function Map:GetSelectItem()
	return self.selectItem;
end

function Map:AddListener(name,listener)
	self.listeners[name] = listener;
end

function Map:RemoveListener(name)
	if(self.listeners[name])then
		self.listeners[name] = nil;
	end
end

function Map:Reset()
	--set display mode to 2D
	self.displayState = Map3DApp.WorldMap.DisplayState.D2
	self.activeLayer = self.layer2D;
	self.layer2D:ActiveRender(true);
	self.layer3D:ActiveRender(false);
	
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid())then
		_this:SetBGImage(self.activeLayer:GetMap());
		--set view position at the center of map
		--_this.background = "Texture/testPic.jpg";
		self.activeLayer:SetViewPosition(0.5,0.5);
		self.activeLayer:SetViewElevation(0);
	end
	
	--hide mask layer
	local _this = ParaUI.GetUIObject(self.name.."mask");
	if(_this:IsValid())then
		_this.visible = false;
		_this.enable = false;
	end;
end

--============private=================
function Map:SendMessage(msg)
	if(self.listeners)then
		for __,listener in pairs(self.listeners) do
			listener:SetMessage(self.name,msg)
		end
	end
end

function Map:Init()
	CommonCtrl.AddControl(self.name,self);
	
	--create 3D map
	self.layer3D = Map3DApp.Map3DLayer:new{
		--name = self.name.."_L3";
		name = "map";
	};
	self.layer3D:AddListener(self.name,self);
	
	--create 2D map
	self.layer2D = Map3DApp.Map2DLayer:new{
		name = self.name.."_L2";
	};
	self.layer2D:AddListener(self.name,self);
	
	--create cloud layer
	self.cloudLayer = Map3DApp.SpriteAnimationPlayer:new{
		name = self.name.."_Cloud";
		totalFrame = 16,
		defaultFrame = 1,
		frameSize = 256,
		spriteSheet = "model/map3D/texture/clouds.dds",
	};
	self.cloudLayer:AddListener(self.name,self);
end

--Create ui controls
function Map:CreateUI()
	--create map container
	local _this;
	_this = ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
	_this.onmousedown = string.format(";Map3DApp.WorldMap.Map.OnMouseDown(%q)",self.name);
	_this.onmousemove = string.format(";Map3DApp.WorldMap.Map.OnMouseMove(%q)",self.name);
	_this.onmouseup = string.format(";Map3DApp.WorldMap.Map.OnMouseUp(%q)",self.name);
	_this.onmouseleave = string.format(";Map3DApp.WorldMap.Map.OnMouseLeave(%q)",self.name);
	_this.onmousewheel = string.format(";Map3DApp.WorldMap.Map.OnMouseWheel(%q)",self.name);
	_this.onclick = string.format(";Map3DApp.WorldMap.Map.OnClick(%q)",self.name);
	if(self.parent == nil)then
		_this:AttachToRoot();
	else
		self.parent:AddChild(_this);
	end
	local _parent = _this;
	
	_this = ParaUI.CreateUIObject("container",self.name.."mask","_fi",0,0,self.width,self.height);
	_this.visible = false;
	_this.enable = false;
	_parent:AddChild(_this);
end

function Map.OnMouseDown(ctrName)
	local self = CommonCtrl.GetControl(ctrName);
	if(self == nil)then
		return;
	end
	
	self.isMouseDown = true;
	self.lastMousePosX = mouse_x;
	self.lastMousePosY = mouse_y;
	
	if(mouse_button == "left")then
		self.isLMBDown = true;
		self.mouseDownPosX = mouse_x;
		self.mouseDownPosY = mouse_y;
	elseif(mouse_button == "right")then
		self.isRMBDown = true;
	end
end

function Map.OnMouseUp(ctrName)
	local self = CommonCtrl.GetControl(ctrName);
	if(self == nil)then
		return;
	end

	if(self.isLMBDown)then
		if( math.abs(self.mouseDownPosX - mouse_x)< 5 and
			math.abs(self.mouseDownPosY - mouse_y)< 5)then
			self:MousePick();
		end
	end
	self.isLMBDown = false;
	self.isRMBDown = false;
end

function Map.OnMouseMove(ctrName)
	local self = CommonCtrl.GetControl(ctrName);
	if(self == nil)then
		return;
	end
	
	local dx,dy;
	dx = self.lastMousePosX - mouse_x;
	dy = self.lastMousePosY - mouse_y;
	self.lastMousePosX = mouse_x;
	self.lastMousePosY = mouse_y;
	
	if(math.abs(dx) < 1 and math.abs(dy) < 1)then
		--return if the delta movement too small
		return;
	end
	
	--mouse left button drag
	if(self.isLMBDown)then		
		if(self.enable)then
			if(	self.inverseMouse)then
				self:Pan(-dx,dy);
			else
				self:Pan(dx,-dy);	
			end
		end
	end
	
	--mouse right button drag
	if(self.isRMBDown)then
		if(self.enable)then
			if(self.inverseMouse)then
				self:Rotate(dx * self.rotateStep);
				self:Pitch(dy * self.pitchStep);
			else
				self:Rotate(-dx * self.rotateStep);
				self:Pitch(-dy * self.pitchStep);
			end
		end
	end
end

function Map.OnMouseLeave(ctrName)
	local self = CommonCtrl.GetControl(ctrName);
	if(self == nil)then
		return;
	end
	
	self.isLMBDown = false;
	self.isRMBDown = false;
end

function Map.OnMouseWheel(ctrName)
	local self = CommonCtrl.GetControl(ctrName);
	if(self == nil)then
		return;
	end
	
	if(self.enable)then
		self:Zoom(mouse_wheel * self.zoomStep);	
	end
end
