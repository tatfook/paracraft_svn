--[[
Title: The base class for a window instance in explorer
Author(s): LiXizhi
Date: 2007/3/23
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/network/explorerWnd.lua");
local ctl = CommonCtrl.explorerWnd:new{
	name = "explorerWnd1",
	alignment = "_lt",
	left=0, top=0,
	width = 512,
	height = 290,
	parent = nil,
};
ctl:Show();
-------------------------------------------------------
]]
-- common control library
NPL.load("(gl)script/ide/common_control.lua");

-- define a new control in the common control libary

-- default member attributes
local explorerWnd = {
	-- the top level control name
	name = "explorerWnd1",
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 512,
	height = 290, 
	parent = nil,
	-- attribute
	url = "",
	title = "untitled",
}
CommonCtrl.explorerWnd = explorerWnd;

-- constructor
function explorerWnd:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Destroy the UI control
function explorerWnd:Destroy ()
	ParaUI.Destroy(self.name);
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function explorerWnd:Show(bShow)
	local _this,_parent;
	if(self.name==nil)then
		log("explorerWnd instance name can not be nil\r\n");
		return
	end
	
	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false) then
	
		_this=ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
		_this.background="Texture/whitedot.png;0 0 0 0";
		_parent = _this;
		
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		CommonCtrl.AddControl(self.name, self);
		
		self.title = self.name;
		
		local left, top, width, height = 0,0, 124, 32
		_this=ParaUI.CreateUIObject("text","s","_lt",left,top,width,height);
		_this.text="this is "..self.name;
		--_this.onclick=string.format([[;CommonCtrl.explorerWnd.OnClose_Static("%s");]],self.name);
		_parent:AddChild(_this);
		_this = _parent;
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

-- close the given control
function explorerWnd.OnClose_Static(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting explorerWnd instance "..sCtrlName.."\r\n");
		return;
	end
	self:OnClose();
end

---------------------------------------------------------
-- the following methods are usually overriden by its derived class
---------------------------------------------------------

-- usually overriden by its derived class.
function explorerWnd:GetType()
	return "explorerWnd";
end

-- called by explorer when this window should be stopped (stop connecting).
function explorerWnd:OnStop()
end

-- called by explorer when this window should be closed and loses its connections
function explorerWnd:OnClose()
	self:OnStop();
	self:Destroy();
end

-- called by explorer when this window is informed of changing size. 
-- Usually only the width matters, since the parent will scroll this window if it is too long.
-- @param clientWidth: expected client size of this window 
-- @param clientHeight: expected client size of this window 
function explorerWnd:OnSize(clientWidth, clientHeight)
end

-- called by explorer when this window becomes the current active window in the explorer
function explorerWnd:OnActive()
end

-- called by explorer when this window becomes an inactive window in the explorer
function explorerWnd:OnDeActive()
end

-- called by explorer when this window needs to be refreshed
function explorerWnd:OnRefresh()
end

-- get the url of the window
function explorerWnd:GetURL()
	return self.url;
end

-- set the url of the window
function explorerWnd:SetURL(url)
	self.url = url;
end

-- get the title of the window
function explorerWnd:GetTitle()
	return self.title;
end

-- set the title of the window
function explorerWnd:SetTitle(title)
	self.title = title;
end
