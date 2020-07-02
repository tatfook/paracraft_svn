

--[[

*****this file is deprecated******


NPL.load("(gl)script/ide/common_control.lua");

local midBar = {
	name = "midBar",
	parent = nil,
	left = 10,
	top = 0,
	width = 20,
	height = 100,
	spliterState = 1;
	mediator = nil,
}
CommonCtrl.midBar = midBar;

function midBar:new(o)
	o = o or {}  
	setmetatable(o, self)
	self.__index = self
	return o
end

function midBar:Destroy()
	ParaUI.Destroy(self.name);
end

function midBar:Show(bshow)
	local _this,_parent;
	if( self.name == nil)then
		log(" midBar instance name can not be nil -_-#\r\n");
		return;
	end
	
	_this = ParaUI.GetUIObject(self.name);
	if( _this:IsValid() == false)then
		self:InitUI(_parent);
	else
		if(bshow == nil)then
			if(_this.visible == true)then
				_this.visible = false;
			else
				_this.visible = true;
			end
		else
			_this.visible = bshow;
		end
	end
end

function midBar:InitUI()
	local _this,_parent;
	_this = ParaUI.CreateUIObject("container",self.name,"_lt",self.left,self.top,self.width,self.height);
	_this.background = "Texture/worldMap/UI/midBar_bg.png";
	if(self.parent == nil)then
		_this:AttachToRoot();
	else
		self.parent:AddChild(_this);
	end
	CommonCtrl.AddControl(self.name,self);
	_parent = _this;
	
	local left = 3;
	local top = 10;
	_this = ParaUI.CreateUIObject("button",self.name.."ZoomIn","_lt",left,top,25,25);
	_this.tooltip = "zoom in";
	_this.background = "Texture/worldMap/UI/zoomIn.png";
	_this.onclick = string.format(";CommonCtrl.midBar.OnZoomInBtnClick(%q);",self.name);
	_parent:AddChild(_this);
	
	top = top + 35;
	_this = ParaUI.CreateUIObject("button",self.name.."ZoomOut","_lt",left,top,25,25);
	_this.tooltip = "zoom out";
	_this.background = "Texture/worldMap/UI/zoomOut.png";
	_this.onclick = string.format(";CommonCtrl.midBar.OnZoomOutBtnClick(%q);",self.name);
	_parent:AddChild(_this);

	top = top + 35;
	_this = ParaUI.CreateUIObject("button",self.name.."refresh","_lt",left,top,25,25);
	_this.background = "Texture/worldMap/UI/refresh.png";
	_this.tooltip = "refresh map";
	_parent:AddChild(_this);
	
	top = top + 35;
	_this = ParaUI.CreateUIObject("button",self.name.."reset","_lt",left,top,25,25);
	_this.tooltip = "reset map";
	_this.background = "Texture/worldMap/UI/reset.png";
	_this.onclick = string.format(";CommonCtrl.midBar.OnResetBtnClick(%q);",self.name);
	_parent:AddChild(_this);
	
	top = top + 35;
	_this = ParaUI.CreateUIObject("button",self.name.."spliter","_rt",left,top,-12,110);
	_this.tooltip = "Hide Side Bar";
	_this.background = "Texture/worldMap/UI/hide.png";
	_this.onclick = string.format(";CommonCtrl.midBar.OnSpliterBtnClick(%q);",self.name);
	_parent:AddChild(_this);
	
	
	_this = ParaUI.CreateUIObject("button",self.name.."help","_lb",left,-35,25,25);
	_this.background = "Texture/worldMap/UI/help.png";
	_this.tooltip = "show help";
	_parent:AddChild(_this);
end
 
function midBar:SetPosition(_left,_top,_width,_height)
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		log("mapBrowser midbar can not found-_-#\r\n");
		return;
	end
	
	_this.x = _left;
	_this.y = _top;
	_this.width = _width;
	_this.height = _height;
end

function midBar:SetMediator(_mediator)
	self.mediator = _mediator;
end

function midBar.OnSpliterBtnClick(ctrName)
	local self = CommonCtrl.GetControl(ctrName);
	if( self == nil)then
		return;
	end
	
	local _this = CommonCtrl.GetControl(self.parent.name);
	if( _this == nil)then
		return;
	end
	_this:ToggleLayout();
		
	_this = ParaUI.GetUIObject(self.name.."spliter");
	if( _this:IsValid() == true)then
		if( self.spliterState ==  1)then
			_this.background = "Texture/worldMap/UI/show.png";
			self.spliterState = 2;
		else
			_this.background =  "Texture/worldMap/UI/hide.png";
			self.spliterState = 1;
		end
	end
	

end

function midBar.OnZoomInBtnClick(ctrName)
	local self = CommonCtrl.GetControl(ctrName);
	if( self == nil)then
		return;
	end
	
	if( self.mediator ~= nil)then
		self.mediator:OnZoomInBtnClick();
	end
end

function midBar.OnZoomOutBtnClick(ctrName)
	local self = CommonCtrl.GetControl(ctrName);
	if( self == nil)then
		return;
	end
	
	if( self.mediator ~= nil)then
		self.mediator:OnZoomOutBtnClick();
	end
end

function midBar.OnResetBtnClick(ctrName)
	local self = CommonCtrl.GetControl(ctrName);
	if( self == nil)then
		return;
	end
	
	if( self.mediator ~= nil)then
		self.mediator:OnResetBtnClick();
	end
end
	
function midBar.OnRefreshBtnClick(ctrName)
end

]] 