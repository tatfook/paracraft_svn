
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/network/mapMarkProvider.lua");
NPL.load("(gl)script/network/mapMarkWnd.lua");

local mapBrowser = {
	name = "mapBrowser1";
	parent = nil;
	left = 0;
	top = 0;
	width = 0;
	height = 0;
	mapset = {};
	mapMarks = {};
	maxMarkCount = 6;
	visible = true;
	mediator = nil;
	
	cellDimension = 2;
	cellCount = 4,
	refCellSize = {x = 512,y=512},
	cellSize = {x = 512,y=512},
	cellPos_lt = {x = 0,y=0},
	maxWorldPos_lt = {x = 0,y=0},
	refMaxWorldPos_lt = {x = 0,y=0},
	cellOffset = {x = 0,y = 0},
	viewRegionWidth = 512;
	viewRegionHeight = 512;
	cell2TexScale = {x = 1,y = 1},
	scale = 1,
	maxScale = 1.6,
	scaleSpan = 0.2,
	timeCount = 0,
	world2CellScale = 1,
	viewRegion = {x_min=0,x_max=0,y_min=0,y_max=0},
	
	maskAlpha = 128,
	timerID = 237,
	isMouseDown = false,
	isInvertMouse = false,
	isShowMapMark = false,
	lastMousePos = {x=0,y=0},
	mouseCoord = {x = 0,y = 0},
}
CommonCtrl.mapBrowser = mapBrowser;

function mapBrowser:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;
end

function mapBrowser:Destroy()
	ParaUI.Destroy(self.name);
end

function mapBrowser:SetPos(_x,_y,_width,_height)
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		log("mapBrowser container can not found -_-# \r\n");
		return;
	end	
	_this.x = _x;
	_this.y = _y;
	_this.width = _width;
	_this.height = _height;
	self:UpdateCellParameters();
	self:RefreshCells("cell");
	self:UpdateViewRegion();
end

function mapBrowser:Show(bShow)
	local _this,_parent;
	if( self.name == nil)then
		log(" mapBrowser instance name can not be nil -_- \r\n");
		return;
	end
	 
	_this = ParaUI.GetUIObject(self.name);
	if( _this:IsValid() == false)then
		--create container
		_this = ParaUI.CreateUIObject("container",self.name,"_lt",self.left,self.top,self.width,self.height);
		_this.fastrender = false;
		_this.receivedrag = true;
		--_this.enabled = false;
		_this.background = "Texture/whitedot.png;0 0 0 0";
		_this.onmousedown = string.format([[;CommonCtrl.mapBrowser.OnMouseDown("%s");]],self.name);
		_this.onmousemove = string.format([[;CommonCtrl.mapBrowser.OnMouseMove("%s");]],self.name);
		_this.onmouseup = string.format([[;CommonCtrl.mapBrowser.OnMouseUp("%s");]],self.name);
		_this.onmousewheel = string.format([[;CommonCtrl.mapBrowser.OnMouseWheel("%s");]],self.name);
		_this.onclick = string.format([[;CommonCtrl.mapBrowser.OnClick("%s");]],self.name);
 
		if(self.parent == nil)then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		CommonCtrl.AddControl(self.name,self);	
		_parent = _this;
		
		--create texture cell
		self:CreateCells( self.cellCount,"cell",_parent);
		self:RefreshCells("cell");
		
		--create mask texture cell
		self:CreateCells(self.cellCount,"maskCell",_parent);
		
		--create marks
		self:CreateMapMarks(_parent);
		
		--create a markDetailWnd,reuse this windows to display different mark detail.
		markDetailWnd:Initialize(_parent);
		
		--create mark label
		_this = ParaUI.CreateUIObject("button",self.name.."markLable","_lt",0,0,100,15);
		_this.background = "Texture/worldMap/bg_mid.png";
		_this:GetTexture("background").transparency = 128;
		_this.font = "System;12;norm";
		_this:GetFont("text").color = "200 20 20";
		_this.enable = false;
		_this.visible = false;
		_parent:AddChild(_this);
		
		self:UpdateViewRegion();
	else
		if(bShow == nil) then
			if(_this.visible == true) then
				_this.visible = false;
			else
				_this.visible = true;
			end
		else
			_this.visible = bShow;
		end
	end
end

function mapBrowser:CreateCells(cellNum,name,ctrParent)
	local _this;
	for i = 1,cellNum do
		_this = ParaUI.CreateUIObject("container",self.name..name..i,"_lt",0,0,0,0);
		_this.enabled = false;
		ctrParent:AddChild(_this);
	end	
end

function mapBrowser:CreateMapMarks(_parent)
	local _this;
	for i = 1,self.maxMarkCount do
		self.mapMarks[i] = CommonCtrl.mapMark:new{name = "mapMark"..i,parent = _parent,visible = true,};
		self.mapMarks[i]:Initialize();
		self.mapMarks[i]:SetMediator(self.mediator);
	 	self.mapMarks[i]:Show(false);
	end
end

function mapBrowser:RefreshCells(cellName)
	self:UpdateCellParameters();
	local _this;
	local _maps = self.mapset:GetMaps(self.cellPos_lt.x * self.cell2TexScale.x,self.cellPos_lt.y * self.cell2TexScale.y,
		self.viewRegionWidth/self.scale,self.viewRegionHeight/self.scale);
	for i=1,self.cellDimension do
		for j = 1,self.cellDimension do
			_this = ParaUI.GetUIObject(self.name..cellName..(i-1)*self.cellDimension+j);
			
			if(_this:IsValid() == true)then
				_this.x = -math.mod(self.cellPos_lt.x,self.cellSize.x) + (j-1)*self.cellSize.x;
				_this.y = -math.mod(self.cellPos_lt.y,self.cellSize.y) + (i-1)*self.cellSize.y;		
				if( _maps[i] ~=nil and _maps[i][j]~=nil)then
					_this.background = _maps[i][j].path;
					if(_maps[i][j].texRect ~= nil)then
						_this:GetTexture("background").rect = _maps[i][j].texRect;
					end
				else
					_this.background = "Texture/whitedot.PNG";
				end
				_this.width = self.cellSize.x;				
				_this.height = self.cellSize.y;
			end
		end
	end
end

function mapBrowser:MoveViewRegion(dx,dy)
	if( dx == nil or dy == nil)then
		log( "err..delta can not be nil..-_- \n");
		return;
	end
	self.cellPos_lt.x = math.floor(self.cellPos_lt.x + dx);
	self.cellPos_lt.y = math.floor(self.cellPos_lt.y + dy);
	self:CheckBound();
	self:UpdateViewRegion();
end

function mapBrowser:SetViewRegion(_x,_y)
	self.cellPos_lt.x = _x;
	self.cellPos_lt.y = _y;
	self:CheckBound();
	self:UpdateViewRegion()
end

function mapBrowser:ResetViewRegion()
	self:ResetTimer();	
	self:RefreshMaskCells();	
	
	self.cellPos_lt.x = 0;
	self.cellPos_lt.y = 0;
	self.mapset:SetActiveLayerIndex(1);
	self.scale = 1;
	
	self:RefreshCells("cell");	
	self:UpdateViewRegion();
end

function mapBrowser:ChangeMapLvl(zoom)
	if(self.mapset:SetActiveLayerIndex( self.mapset:GetActiveLayerCount() + zoom))then
		return true;
	end
	return false;
end

function mapBrowser:ScaleMap(deltaScale)
	self.scale = self.scale + deltaScale;
	if(self.scale > self.maxScale)then
		self.scale = self.maxScale;
		if(self:ChangeMapLvl(1))then	
			self.scale = 1;
		end
	elseif(self.scale < 1)then
		self.scale = 1;
		if(self:ChangeMapLvl(-1))then
			self.scale = self.maxScale;
		end
	end
	self:UpdateCellParameters();
	self:CaptureMouseCoord();
	self:UpdateViewRegion();
end

function mapBrowser:Zoom(_scale,bUsingMouse)
	self:ResetTimer();
	self:RefreshMaskCells();	
	self:ScaleMap(_scale,bUsingMouse)
	self:RefreshCells("cell");	
end

function mapBrowser:CaptureMouseCoord(bUsingMouse)
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		log("map view can not found -_-b \r\n");
		return;
	end
	
	local lt_x,lt_y,_width,_height = _this:GetAbsPosition();
	local lvlScale = math.pow(2,self.mapset:GetLayerCount() - self.mapset:GetActiveLayerCount());
	self.cellPos_lt.x = self.mouseCoord.x / self.cell2TexScale.x / lvlScale - mouse_x + lt_x;
	self.cellPos_lt.y = self.mouseCoord.y / self.cell2TexScale.y / lvlScale - mouse_y + lt_y;
	self:CheckBound();
end

function mapBrowser:UpdateMouseCoord()
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		log("map view can not found -_-b \r\n");
		return;
	end	
	local lt_x,lt_y,width,height = _this:GetAbsPosition();
	local lvlScale = math.pow(2,self.mapset:GetLayerCount() - self.mapset:GetActiveLayerCount());
	self.mouseCoord.x = math.floor((mouse_x - lt_x + self.cellPos_lt.x) * self.cell2TexScale.x * lvlScale);
	self.mouseCoord.y = math.floor((mouse_y - lt_y + self.cellPos_lt.y) * self.cell2TexScale.y * lvlScale);
end

function mapBrowser:CheckBound()
	if(self.cellPos_lt.x < 0)then
		self.cellPos_lt.x = 0;
	elseif( self.cellPos_lt.x > self.maxWorldPos_lt.x)then
		self.cellPos_lt.x = self.maxWorldPos_lt.x;
	end
	if(self.cellPos_lt.y < 0)then
		self.cellPos_lt.y = 0;
	elseif( self.cellPos_lt.y > self.maxWorldPos_lt.y)then
		self.cellPos_lt.y = self.maxWorldPos_lt.y;
	end
end

function mapBrowser:UpdateCellParameters()
	local _this = ParaUI.GetUIObject(self.name);
	if( _this:IsValid() == false)then
		log( " map browers container can not found -_- \r\n");
		return;
	end;
	
	__,__,self.refCellSize.x,self.refCellSize.y = _this:GetAbsPosition();
	self.cellSize.x = math.floor(self.refCellSize.x * self.scale);
	self.cellSize.y = math.floor(self.refCellSize.y * self.scale);

	self.cell2TexScale.x = self.mapset:GetTexSize() / self.cellSize.x + 0.0000001;
	self.cell2TexScale.y = self.mapset:GetTexSize() / self.cellSize.y + 0.0000001;
	
	self.refMaxWorldPos_lt.x = (self.mapset:GetDimension() - 1) *  self.refCellSize.x;
	self.refMaxWorldPos_lt.y = (self.mapset:GetDimension() - 1) *  self.refCellSize.y;
	
	self.maxWorldPos_lt.x = self.refMaxWorldPos_lt.x + (self.cellSize.x - self.refCellSize.x)*self.mapset:GetDimension();
	self.maxWorldPos_lt.y = self.refMaxWorldPos_lt.y + (self.cellSize.y - self.refCellSize.y)*self.mapset:GetDimension();
end

function mapBrowser:UpdateViewRegion()
	local lvlScale = math.pow(2,self.mapset:GetLayerCount() - self.mapset:GetActiveLayerCount());
	self.viewRegion.x_min = math.floor(self.cellPos_lt.x * self.cell2TexScale.x *  lvlScale);
	self.viewRegion.y_min = math.floor(self.cellPos_lt.y * self.cell2TexScale.y * lvlScale);
	self.viewRegion.x_max = math.floor(self.refCellSize.x * self.cell2TexScale.x * lvlScale) + self.viewRegion.x_min;
	self.viewRegion.y_max = math.floor(self.refCellSize.y * self.cell2TexScale.y * lvlScale)+ self.viewRegion.y_min;
	
	if( self.mediator ~= nil)then
		self.mediator:OnViewRegionChange(self.name);
	end
end

function mapBrowser:UpdateMapMarks(_markInfos)
	for i = 1,self.maxMarkCount do
		self.mapMarks[i]:Show(false)
	end
	
	if(_markInfos ~= nil)then
		local i = 1;
		while(i<self.maxMarkCount and _markInfos[i] ~= nil and self.mapMarks[i] ~= nil)do
			self.mapMarks[i]:SetPlayerInfo(_markInfos[i]);
			
			local x,y = _markInfos[i]:GetCoordinate();
			x = x / math.pow(2,self.mapset:GetLayerCount() - self.mapset:GetActiveLayerCount()) / self.cell2TexScale.x - 16;
			y = y / math.pow(2,self.mapset:GetLayerCount() - self.mapset:GetActiveLayerCount()) / self.cell2TexScale.y - 32;
			self.mapMarks[i]:SetPosition(x - self.cellPos_lt.x, y - self.cellPos_lt.y);
			
			self.mapMarks[i]:Show(true);
			i = i + 1;
		end
	end
end

function mapBrowser:RefreshMaskCells()
	self:RefreshCells("maskCell");
	self:UpdateMaskAlpha();
end

function mapBrowser:UpdateMaskAlpha()
	for i = 1,self.cellCount do
		local _this = ParaUI.GetUIObject(self.name.."maskCell"..i);
		if(_this:IsValid() == true)then
			if(self.maskAlpha > 0)then
				_this:GetTexture("background").transparency = self.maskAlpha;
				_this.visible = true;
			else
				_this.visible = false;
			end
		end
	end
end

function mapBrowser:ResetTimer()
	self.maskAlpha = 255;
	self.timeCount = 0;
	NPL.SetTimer(self.timerID, 0.06, string.format( [[;CommonCtrl.mapBrowser.Fade("%s");]],self.name));
end

function mapBrowser.Fade(ctrName)
	local self = CommonCtrl.GetControl(ctrName);
	if(self == nil)then
		log("err getting mapVisualizer instance"..ctrName.."\r\n");
		NPL.KillTimer(self.timerID);
		return;
	end

	if( self.maskAlpha == 0)then
		NPL.KillTimer(self.timerID);
		return;
	end
	
	self.timeCount = self.timeCount + 1;
	self.maskAlpha = 255 - self.timeCount * 25;
	if(self.maskAlpha < 0 ) then
		self.maskAlpha = 0;
	end
	self:UpdateMaskAlpha();
end

function mapBrowser:GetMaxMarkCount()
	return self.maxMarkCount;
end

function mapBrowser:GetMarkByID(_markID)
	for i in self.mapMarks do
		if( self.mapMarks[i]:GetMarkInfo():GetMarkID() == _markID )then
			return self.mapMarks[i];
		end
	end
end

--mapBrowser event
function mapBrowser.OnMouseDown(ctrName)
	local self = CommonCtrl.GetControl(ctrName);
	if(self == nil)then
		log("err getting mapBrowser instance"..ctrName.."\r\n");
		return;
	end

	if(self.isMouseDown == false)then
		self.isMouseDown = true;
		self.lastMousePos.x = mouse_x;
		self.lastMousePos.y = mouse_y;
	end
	markDetailWnd:Show(false);
end

function mapBrowser.OnMouseMove(ctrName)
	local self = CommonCtrl.GetControl(ctrName);
	if(self == nil)then
		log("err getting mapVisualizer instance"..ctrName.."\r\n");
		return;
	end
	self:UpdateMouseCoord();
	if(self.isMouseDown == true)then
		if( self.isInvertMouse)then
			self:MoveViewRegion((mouse_x - self.lastMousePos.x)/cell2TexScale.x  ,mouse_y - self.lastMousePos.y/cell2TexScale.x);		
		else
			self:MoveViewRegion(self.lastMousePos.x - mouse_x  ,self.lastMousePos.y - mouse_y);		
		end
		self.lastMousePos.x = mouse_x;
		self.lastMousePos.y = mouse_y;
		self:RefreshCells("cell");
	end
end

function mapBrowser.OnMouseUp(ctrName)
	local self = CommonCtrl.GetControl(ctrName);
	if(self == nil)then
		log("err getting mapVisualizer instance"..ctrName.."\r\n");
		return;
	end

	if(self.isMouseDown == true)then
		self.isMouseDown = false;
	end
end

function mapBrowser.OnMouseWheel(ctrName)
	local self = CommonCtrl.GetControl(ctrName);
	if(self == nil)then		
		log("err getting mapVisualizer instance \r\n");
		return;
	end	
	
	self:Zoom(self.scaleSpan * mouse_wheel)
end

function mapBrowser:SetMediator(_mediator)
	self.mediator = _mediator;
end

function mapBrowser:GetViewRegion()
	return self.viewRegion.x_min,self.viewRegion.x_max,self.viewRegion.y_min,self.viewRegion.y_max;
end

function mapBrowser:IsInViewRegion(_x,_y)
	return (_x > self.viewRegion.x_min) and (_x < self.viewRegion.x_max) and (_y > self.viewRegion.y_min) and ( _y < self.viewRegion.y_max);
end

function mapBrowser:GetZoomSpan()
	return self.scaleSpan;
end