--[[
Title: template: windows form or modeless dialog
Author(s): SunLingfeng
Date: 2007/4/24
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/EBook/ImageViewer.lua");
local ctl = CommonCtrl.ImageViewer:new{
	name = "ImageViewer1",
	alignment = "_lt",
	left=0, top=0,
	width = 512,
	height = 400,
	parent = _parent,
	imagefile = nil;
};
ctl:Show();

call CommonCtrl.ImageViewer.Scale(sCtrlName, deltaScale) to scale the texture size,
deltaScale = 0,no scale; deltaScale = positive number, zoom in; deltaScale = negative number,zoom out

call CommonCtrl.ImageViewer.MoveImg(sCtrlName, deltaX, deltaY) to move the view region when the texture size is bigger
than then window size. deltaX,deltaY is the offset alone x and y axis.

use CommonCtrl.ImageViewer.inverse_mouse to inverse the navigation direction.
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");

-- define a new control in the common control libary

-- default member attributes
local ImageViewer = {
	-- the top level control name
	name = "ImageViewer1",
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 400,
	height = 400, 
	parent = nil,
	-- data
	imagefile = nil,
	texture = nil,
	minScale = 1,
	maxScale = 4,
	scaleDelta = 0.1,
	totalScale = 1,
	inverse_mouse = false,
	
	tex2WndScale = {x=0,y=0},
	texSize = {x=0,y = 0},
	refTexSize =  {x=0,y = 0},
	texPos_lt = {x = 0,y = 0},
	maxTexPos_lt = {x = 0, y = 0},
	isMouseDown = false,
	lastMousePos = {x = 0,y=0},
	aspect;
}
CommonCtrl.ImageViewer = ImageViewer;

-- constructor
function ImageViewer:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Destroy the UI control
function ImageViewer:Destroy ()
	ParaUI.Destroy(self.name);
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function ImageViewer:Show(bShow)
	local _this,_parent;
	if(self.name==nil)then
		log("ImageViewer instance name can not be nil\r\n");
		return;
	end
	
	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false) then
	
		_this = ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);	
		_this.background="Texture/whitedot.png;0 0 0 0";
		
		_this.onmousewheel = string.format([[;CommonCtrl.ImageViewer.OnMouseWheel("%s");]],self.name);
		_this.onmousedown = string.format([[;CommonCtrl.ImageViewer.OnMouseDown("%s");]],self.name);
		_this.onmouseup = string.format([[;CommonCtrl.ImageViewer.OnMouseUp("%s");]],self.name);
		_this.onmousemove = string.format([[;CommonCtrl.ImageViewer.OnMouseMove("%s");]],self.name);
		_this.onmouseleave = string.format([[;CommonCtrl.ImageViewer.OnMouseLeave("%s");]],self.name);
		
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		CommonCtrl.AddControl(self.name, self);
		
		-- set image
		self:SetImage(self.imagefile);
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

-- call this function to set the image
function ImageViewer:SetImage(imagefile)
	local ctl = ParaUI.GetUIObject(self.name);
	if(imagefile==nil or imagefile=="" or (ParaIO.DoesFileExist(imagefile, true)==false)) then
		ctl.background = "Texture/whitedot.png;0 0 0 0";
		ctl.enabled = false;
		return
	else
		ctl.enabled = true;
	end
	
	ctl.background = imagefile;	
	
	-- this will remove the paramters after the semicolon	
	local nSemicolon = string.find(imagefile, ";");
	if(nSemicolon~=nil and nSemicolon>1) then
		imagefile = string.sub(imagefile, 1, nSemicolon-1);
	end
	
	self.imagefile = imagefile;
	self.texture = ParaAsset.LoadTexture("",self.imagefile,1);		
	self.texSize.x = self.texture:GetWidth();
	self.texSize.y = self.texture:GetHeight();
	self.refTexSize.x = self.texSize.x;
	self.refTexSize.y = self.texSize.y;
	
	self.totalScale = 1
	self.tex2WndScale = {x=0,y=0}
	self.texPos_lt = {x = 0,y = 0}
	self.maxTexPos_lt = {x = 0, y = 0}
	self:UpdateView();
end

-- close the given control
function ImageViewer.OnClose(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting ImageViewer instance "..sCtrlName.."\r\n");
		return;
	end
	ParaUI.Destroy(self.name);
end

function ImageViewer.Scale(sCtrlName, deltaScale)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self == nil)then
		log("error getting ImageViewer instance "..sCtrlName.."\r\n");
		return;
	end
	
	local _this = ParaUI.GetUIObject(self.name);
	if( _this:IsValid() == false)then
		log("err....\n");
		return;
	end

	local tempScale = self.totalScale;
	self.totalScale = self.totalScale + deltaScale;

	if( self.totalScale >= self.maxScale)then
		self.totalScale = self.maxScale;
	end
	
	if( self.totalScale < self.minScale)then
		self.totalScale = self.minScale;
	end
	
	self.texSize.x = math.floor(self.refTexSize.x / self.totalScale);
	self.texSize.y = math.floor(self.refTexSize.y / self.totalScale);
	self.maxTexPos_lt.x = math.floor((self.totalScale - 1)  * self.texSize.x);
	self.maxTexPos_lt.y = math.floor((self.totalScale - 1)  * self.texSize.y);
	
	if( tempScale ~= self.totalScale)then
		self:Recenter(deltaScale);
	end
	self:UpdateView();
end

function ImageViewer.MoveImg(sCtrlName, deltaX, deltaY)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self == nil)then
		log("error getting ImageViewer instance "..sCtrlName.."\r\n");
		return;
	end
	
	if( deltaX == nil)then
		log( "err..delta x can not be nil..-_- \n");
		return;
	end
	
	if( deltaY == nil)then
		log( " err..delta y can not be nil..-_-b \n");
		return;
	end

	self.texPos_lt.x = math.floor(self.texPos_lt.x - deltaX);
	self.texPos_lt.y = math.floor(self.texPos_lt.y - deltaY);
	
	self:CheckBound();
	self:UpdateView();	
end

function ImageViewer:UpdateView()
	local _this = ParaUI.GetUIObject(self.name);
	if( _this:IsValid() == false)then
		log("err img container can not found... \n");
		return;
	end
	
	local texture = _this:GetTexture("background");
	texture.rect = string.format( [[%s %s %s %s]],self.texPos_lt.x,self.texPos_lt.y,self.texSize.x,self.texSize.y);
end

function ImageViewer.OnMouseWheel(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self == nil)then
		log("error getting ImageViewer instance "..sCtrlName.."\r\n");
		return;
	end
	
	if( mouse_wheel == 1)then
		self.Scale(self.name , self.scaleDelta);
	elseif( mouse_wheel == -1)then
		self.Scale(sCtrlName , -self.scaleDelta);
	end

end

function ImageViewer.OnMouseDown(sCtrlName,delta)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting ImageViewer instance "..sCtrlName.."\r\n");
		return;
	end
	
	if(self.isMouseDown == false)then
		self.isMouseDown = true;
		self.lastMousePos.x = mouse_x;
		self.lastMousePos.y = mouse_y;
		return;
	end	
end

function ImageViewer.OnMouseMove(sCtrlName,delta)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting ImageViewer instance "..sCtrlName.."\r\n");
		return;
	end
	
	if(self.isMouseDown == true)then
		local dx,dy;
		dx = mouse_x - self.lastMousePos.x;
		dy = mouse_y - self.lastMousePos.y;
		if( self.inverse_mouse == true)then
			dy = -dy;
			dx = -dx;
		end
		self.MoveImg(sCtrlName, dx, dy);
		self.lastMousePos.x = mouse_x;
		self.lastMousePos.y = mouse_y;
	end
end

function ImageViewer.OnMouseUp(sCtrlName,delta)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting ImageViewer instance "..sCtrlName.."\r\n");
		return;
	end
	
	if(self.isMouseDown == true)then
		self.isMouseDown = false;
	end
end

function ImageViewer.OnMouseLeave(sCtrlName,delta)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting ImageViewer instance "..sCtrlName.."\r\n");
		return;
	end
	if(self.isMouseDown == true)then
		self.isMouseDown = false;
	end
end


function ImageViewer:Recenter(deltaScale)
	local _this = ParaUI.GetUIObject(self.name);
	if( _this:IsValid() == false)then
		log(" err...."..self.name.."Img can not found...-_-\n");
		return;
	end
	local wndX,wndY,width,height = _this:GetAbsPosition();
	local dx = mouse_x - wndX;
	local dy = mouse_y - wndY;
	if(dx < 0)then
		dx = 0;
	end
	if(dy < 0)then
		dy = 0;
	end

	self.texPos_lt.x = math.floor( self.texPos_lt.x + self.texSize.x * deltaScale * dx / width / (self.totalScale - 0.1));
	self.texPos_lt.y = math.floor( self.texPos_lt.y + self.texSize.y * deltaScale * dy / height / (self.totalScale - 0.1));
	self:CheckBound();
	
end

function ImageViewer:CheckBound()
	if(self.texPos_lt.x < 0)then
		self.texPos_lt.x = 0;
	elseif( self.texPos_lt.x > self.maxTexPos_lt.x)then
		self.texPos_lt.x = self.maxTexPos_lt.x;
	end
	
	if(self.texPos_lt.y < 0)then
		self.texPos_lt.y = 0;
	elseif( self.texPos_lt.y > self.maxTexPos_lt.y)then
		self.texPos_lt.y = self.maxTexPos_lt.y;
	end
end


