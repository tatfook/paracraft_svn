

NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppCommon.lua");
NPL.load("(gl)script/ide/common_control.lua");

------------------------------------
-----------MapBBSMsgEdit--------
------------------------------------
local MapBBSMsgEdit = {
	name = "bbsMsgBox",
	parent = nil,
	
	alignment = "_lt",
	x = 100,
	y = 100,
	width = 450,
	height = 60,
	textBox = nil;
	onMsgSend = nil;
}
CommonCtrl.MapBBSMsgEdit = MapBBSMsgEdit;

function MapBBSMsgEdit:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;
end

function MapBBSMsgEdit:Destory()
	ParaUI.Destory(self.name)
end

function MapBBSMsgEdit:Show(bSHow)
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		if(bShow == false)then
			return;
		end
		self:Init();
	else
		if(bShow == nil)then
			_this.visible = not _this.visible;
		else
			_this.visible = bShow;
		end
	end
	
	if(_this.visible)then
		_this:BringToFront();
		_this:SetTopLevel(true);
	end
end

function MapBBSMsgEdit:Init()
	if(self.name == nil)then
		log("bbsMsgBox name can not be nil-_-#");
		return;
	end
	
	local _parent = ParaUI.CreateUIObject("container",self.name,self.alignment,self.x,self.y,self.width,self.height);
	if(self.parent == nil)then
		_parent:AttachToRoot();
	else
		self.parent:AddChild(_parent);
	end
	CommonCtrl.AddControl(self.name,self);
	
	self.textBox = ParaUI.CreateUIObject("imeeditbox",self.name.."msg","_lt",10,8,425,20);
	self.textBox.text = "此功能稍后可用";
	_parent:AddChild(self.textBox);
	
	local _this = ParaUI.CreateUIObject("button",self.name.."send","_rb",-105,-26,90,20);
	_this.text = "send";
	_this.tooltip = "此功能稍后可用";
	_this.onclick = string.format(";CommonCtrl.MapBBSMsgEdit.SendMsg(%q)",self.name);
	_parent:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("button",self.name.."cancel","_rb",-165,-26,50,20);
	_this.text = "cancel";
	_this.onclick = string.format(";CommonCtrl.MapBBSMsgEdit.Cancel(%q)",self.name);
	_parent:AddChild(_this);
end

function MapBBSMsgEdit:SetPosition(x,y)
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		return false;
	end
	
	_this.x = x;
	_this.y = y;
end

function MapBBSMsgEdit:IsVisible()
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		return false;
	end
	
	return _this.visible;
end

function MapBBSMsgEdit.SendMsg(ctrName)
	local self = CommonCtrl.GetControl(ctrName);
	if(self == nil)then
		return;
	end
	
	--hide control
	self:Show(false);
	
	if( self.textBox ~= nil and self.textBox:IsValid())then
		if(self.textBox.text ~= nil and self.textBox.text ~= "")then
			--fire onMsgSend event
			if(self.onMsgSend ~= nil)then
				self.onMsgSend(self.textBox.text);
			end
		end
		--reset textbox;
		self.textBox.text = "";
	end
end

function MapBBSMsgEdit.Cancel(ctrName)
	local self = CommonCtrl.GetControl(ctrName);
	if(self == nil)then
		return;
	end
		
	self:Show(false);
	if(self.textBox ~= nil and self.textBox:IsValid())then
		self.textBox.text = "";
	end
end

function MapBBSMsgEdit:GetPosition()
	local _this = ParaUI.GetUIObject(self.name)
	if(_this:IsValid() == nil)then
		return;
	end
	return _this:GetAbsPosition();
end

function MapBBSMsgEdit:SetParent(parentWnd)
	self.parent = parentWnd;
end
------------------------------------------------------


-------------------------------------------------
------------MapBBSMsgViewer------------
-------------------------------------------------
local MapBBSMsgViewer = {
	name = nil;
	parent = nil;
	
	alignment = "_lt",
	x = 0,
	y = 0,
	width = 500,
	height = 300,
	
	--event
	onItemSelect = nil;
	onShow = nil;
}
CommonCtrl.MapBBSMsgViewer = MapBBSMsgViewer;

function MapBBSMsgViewer:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;
end

function MapBBSMsgViewer:Destory()
	self.onItemSelect = nil;
	self.onShow = nil;
	self.parent = nil;
	ParaUI.Destory(self.name)
end

function MapBBSMsgViewer:Show(bSHow)
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		if(bShow == false)then
			return;
		end
		self:Init();
	else
		if(bShow == nil)then
			_this.visible = not _this.visible;
		else
			_this.visible = bShow;
		end
	end
	
	if(_this.visible)then
		--fire onShow event
		if(self.onShow ~= nil)then
			self.onShow(self);
		end
		_this:BringToFront();
		--_this:SetTopLevel(true);
	end
end

function MapBBSMsgViewer:Init()
	if(self.name == nil)then
		log("bbsMsgViewer name can not be nil\n");
		return;
	end
	
	local _parent = ParaUI.CreateUIObject("container",self.name,self.alignment,self.x,self.y,self.width,self.height);
	if(self.parent == nil)then
		_parent:AttachToRoot();
	else
		self.parent:AddChild(_parent);
	end
	CommonCtrl.AddControl(self.name,self);
	
	local _this = ParaUI.CreateUIObject("listbox",self.name.."msgs","_lt",5,5,self.width - 10,270);
	_this.ondoubleclick = string.format(";CommonCtrl.MapBBSMsgViewer.OnItemSelect(%q)",self.name);
	_this.wordbreak = true;
	_parent:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("button",self.name.."close","_rb",-30,-24,25,20);
	_this.text = "X";
	_this.onclick = string.format(";CommonCtrl.MapBBSMsgViewer:Close(%q)",self.name);
	_parent:AddChild(_this);
end

function MapBBSMsgViewer:AddMessage(newMsg)
	local _this = ParaUI.GetUIObject(self.name.."msgs");
	if(_this:IsValid())then
		_this:AddTextItem(newMsg);
		return true;
	end
	return false;
end

function MapBBSMsgViewer:RemoveAll()
	local _this = ParaUI.GetUIObject(self.name.."msgs");
	if(_this:IsValid())then
		_this:RemoveAll();
	end
end

--private,fire onMsgSelect event
function MapBBSMsgViewer.OnItemSelect(ctrName)
	local self = CommonCtrl.GetControl(ctrName);
	if(self == nil)then
		return;
	end
	
	local _this = ParaUI.GetUIObject(self.name.."msgs");
	if(_this:IsValid())then
		if(self.onMsgSelect ~= nil)then
			self.onMsgSelect(_this.text);
		end
	end	
end

function MapBBSMsgViewer:SetPosition(x,y)
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		return false;
	end
	
	_this.x = x;
	_this.y = y;
end

function MapBBSMsgViewer:GetPosition()
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		return false;
	end
	
	return _this:GetAbsPosition();
end

function MapBBSMsgViewer:IsVisible()
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		return false;
	end
	
	return _this.visible;
end

function MapBBSMsgViewer:Close(ctrName)
	local self = CommonCtrl.GetControl(ctrName);
	if(self == nil)then
		return;
	end
	
	self:Show(false);
end

function MapBBSMsgViewer:SetParent(parentWnd)
	self.parent = parentWnd;
end

