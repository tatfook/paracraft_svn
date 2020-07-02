NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/mapMarkProvider.lua");

local mapBrowserSideBar = {
	name = "mapBrowserSideBar1";
	parent = nil;
	mediator = nil;
	left = 0;
	top = 0;
	width = 0;
	height = 0;
	mediator = nil;
	activeWnd = 1;
}
CommonCtrl.mapBrowserSideBar = mapBrowserSideBar;

function mapBrowserSideBar:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

function mapBrowserSideBar:Show(bshow)
	local _this,_parent;
	if( self.name == nil)then
		log("mapBrowserSideBar instance name can not be nil -_-b \r\n");
		return;
	end
	
	_this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		self:InitUI();
	else
		if(bshow == nil)then
			if(_this.visible == true) then
				_this.visible = false;
			else
				_this.visible = true;
			end
		else
			_this.visible = bshow;
		end
	end			
end

function mapBrowserSideBar:InitUI()
	local _this;
	_this = ParaUI.GetUIObject( self.name);
	if( _this:IsValid())then
		return;
	end
	
	_this = ParaUI.CreateUIObject("container",self.name,"_lt",self.left,self.top,self.width,self.height);
		_this.background = "Texture/whitedot.png";
		if(self.parent == nil)then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		CommonCtrl.AddControl(self.name,self);
		_parent = _this;
		
		local _left,_top;
		_left = 5;
		_top = 5;
		_this = ParaUI.CreateUIObject("button",self.name.."btnWorldMap","_lt",_left,_top,60,20);
		_this.text = "搜索";
		_this.font = "System;12;norm";
		_this.background = "Texture/worldMap/bg_mid.png";
		_guihelper.SetUIColor(_this,"255 255 255");
		_this.onclick = string.format( [[;CommonCtrl.mapBrowserSideBar.ShowWorldMap("%s");]],self.name);
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button",self.name.."btnMyMap","_lt",_left + 65,5,60,20);
		_this.text = "我的地图";
		_this.font = "System;12;norm";
		_this.background = "Texture/worldMap/bg_mid.png";
		_this.onclick = string.format( [[;CommonCtrl.mapBrowserSideBar.ShowMyWorld("%s");]],self.name);
		_parent:AddChild(_this);
		
		NPL.load("(gl)script/network/mapSearchWnd.lua");
		_this = CommonCtrl.mapSearchWnd:new{
			name = self.name.."mapSearchWnd",
			parent = _parent,
			left = 0,
			top = 25,
			right = 0,
			bottom = 0,
		}
		if(self.mediator ~= nil)then
			_this:SetMediator(self.mediator);
		end
		_this:Show();

		NPL.load("(gl)script/network/myWorldWnd.lua");
		_this = CommonCtrl.myWorldWnd:new{
			name = self.name.."myWorldWnd",
			parent = _parent,
			left = 0,
			top = 25,
			right = 0,
			bottom = 0,
		}
		if(self.mediator ~= nil)then
			_this:SetMediator(self.mediator);
		end
		_this:Show();
end

function mapBrowserSideBar:Destroy()
	ParaUI.Destory(self.name);
end

function mapBrowserSideBar:SetPosition(_x,_y,_width,_height)
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		log("mapBrowser container can not found -_-# \r\n");
		return;
	end	
	_this.x = _x;
	_this.y = _y;
	_this.width = _width;
	_this.height = _height;
end
  
function mapBrowserSideBar.ShowWorldMap(ctrName)
	local self = CommonCtrl.GetControl(ctrName);
	if(self == nil)then		
		log("err getting mapBrowserSideBar instance \r\n");
		return;
	end
	
	if( self.activeWnd == 1)then
		return;
	end;	
	
	_this = ParaUI.GetUIObject(self.name.."btnWorldMap");
	_guihelper.SetUIColor(_this,"255 255 255");
	
	_this = ParaUI.GetUIObject(self.name.."btnMyMap");
	_guihelper.SetUIColor(_this,"200 200 200");
	
	_this = CommonCtrl.GetControl(self.name.."mapSearchWnd");
	if(_this == nil)then		
		log("err getting mapSearchWnd instance \r\n");
		return;
	end
	_this:Show(true);
	
	_this = CommonCtrl.GetControl(self.name.."myWorldWnd");
	if(_this == nil)then		
		log("err getting myWorldWnd instance \r\n");
		return;
	end
	_this:Show(false);
	
	if( self.mediator ~= nil)then
		self.mediator:ShowWorldMap(ctrName);
	end
	
	self.activeWnd = 1;
end

function mapBrowserSideBar.ShowMyWorld(ctrName)
	local self = CommonCtrl.GetControl(ctrName);
	if(self == nil)then		
		log("err getting mapBrowserSideBar instance \r\n");
		return;
	end
	
	if( self.activeWnd == 2)then
		return;
	end;	
	_this = ParaUI.GetUIObject(self.name.."btnMyMap");
	_guihelper.SetUIColor(_this,"255 255 255");

	_this = ParaUI.GetUIObject(self.name.."btnWorldMap");
	_guihelper.SetUIColor(_this,"200 200 200");

	_this = CommonCtrl.GetControl(self.name.."myWorldWnd");
	if(_this == nil)then		
		log("err getting mapSearchWnd instance \r\n");
		return;
	end
	_this:Show(true);

	_this = CommonCtrl.GetControl(self.name.."mapSearchWnd");
	if(_this == nil)then		
		log("err getting myWorldWnd instance \r\n");
		return;
	end
	_this:Show(false);
	
	if( self.mediator ~= nil)then
		self.mediator:ShowMyWorld(ctrName);	
	end
	self.activeWnd = 2;
end

function mapBrowserSideBar:SetMediator(_mediator)
	self.mediator = _mediator;
end

function mapBrowserSideBar:OnResize()
	local _this = CommonCtrl.GetControl( self.name.."mapSearchWnd");
	if( _this == nil)then
		return;
	end
	_this:OnResize();
end




