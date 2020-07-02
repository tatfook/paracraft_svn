--[[
Title: The base class for a window instance in explorer
Author(s): LiXizhi
Date: 2007/3/23
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/network/MapExplorerWnd.lua");
local ctl = CommonCtrl.MapExplorerWnd:new{
	name = "MapExplorerWnd1",
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
NPL.load("(gl)script/network/explorerWnd.lua");
NPL.load("(gl)script/ide/CheckBox.lua");
NPL.load("(gl)script/network/mapSet.lua");
NPL.load("(gl)script/network/mapBrowserMediator.lua");
NPL.load("(gl)script/network/mapBrowserMidBar.lua");

-- define a new control in the common control libary

-- default member attributes
local MapExplorerWnd = CommonCtrl.explorerWnd:new{
	name = "MapExplorerWnd1",
	sideBarWidth = 178,
	midBarWidth = 30,
	refSideBarWidth = nil,
	isHideSideBar = false,
	mediator = nil,
	timerID = 238,
	timeCount = 0,}
CommonCtrl.MapExplorerWnd = MapExplorerWnd;
 
-- constructor
function MapExplorerWnd:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o,self)
	self.__index = self
	return o
end

-- Destroy the UI control
function MapExplorerWnd:Destroy ()
	ParaUI.Destroy(self.name);
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function MapExplorerWnd:Show(bShow)
	local _this,_parent,_sideBar,_mapView;
	if(self.name==nil)then
		log("MapExplorerWnd instance name can not be nil\r\n");
		return
	end

	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false) then
		self.refSideBarWidth = self.sideBarWidth;
		_this=ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
		_this.background="Texture/worldMap/UI/me_bg.png";
		_this:SetTopLevel(true);
		_this.fastrender = false;
		_parent = _this;

		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		CommonCtrl.AddControl(self.name, self);	
		
		local __,__,_width,_height = _parent:GetAbsPosition();
		_width = _width - 2;
		_height = _height -4;

		--NPL.load("(gl)script/network/coordinateTranslater.lua");
		--local mbsb = CommonCtrl.mapBrowserSideBar:new{
			--name = "sideBar1";
			--parent = nil;
			--left = 0;
			--top = 0;
			--width =300;
			--height = 600;
			--isInited = false;
		--}
		--log("call show\n");
		--mbsb:Show();
	
		--mapBrowser	
		NPL.load("(gl)script/network/mapSet.lua");
		local worldMapSet = CommonCtrl.MapSet:new{
			name = "mapSet1",
			maxLayerCount = 8,
			maxMapCoord = { x = 0,y = 0},
			activeLayerIndex = 1,
			rootMapPath = "Texture/worldMap";
			filefmt = "jpg";
		}
	
		NPL.load("(gl)script/network/mapBrowser.lua");
		local _mapBrowser = CommonCtrl.mapBrowser:new{
			name = "worldMapBrowser";
			parent = _parent;
			left = 2;
			top = 2;
			width = _width - self.sideBarWidth-self.midBarWidth;
			height = _height;
			mapset = worldMapSet;
			visible = true;
			cellDimension = 2;
			cellCount = 400,
			cellSize = {x = 512,y=512},
			cellPos_lt = {x = 0,y=0},
			maxMarkCount = 30;
		}
		
		local _midBar = CommonCtrl.midBar:new{
			name = "mbMidBar",
			parent = _parent,
			left = _mapBrowser.width + 2;
			top = 2,
			width = self.midBarWidth,
			height = _height,
		}
		
		--SideBar
		NPL.load("(gl)script/network/mapBrowserSideBar.lua");
		local _mapBrowserSideBar = CommonCtrl.mapBrowserSideBar:new{
			name = "mbSideBar";
			parent = _parent;
			left = _mapBrowser.width + self.midBarWidth+2;
			top = 2;
			width = _width - _mapBrowser.width - self.midBarWidth -2;
			height = _height;
		}
		
		--mapExplorerMediator
		self.mediator = CommonCtrl.mapExplorerMediator:new{
			ctrMapBrowser = _mapBrowser,
			ctrSideBar = _mapBrowserSideBar,
			midBar = _midBar;
		}
		
		_mapBrowser:SetMediator(self.mediator);
		_mapBrowser:Show();

		_midBar:SetMediator(self.mediator);
		_midBar:Show();
		
		_mapBrowserSideBar:SetMediator(self.mediator);
		_mapBrowserSideBar:Show();
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
	if(_this.visible == true) then
		_this:SetTopLevel(true);
	end
end

-- close the given control
function MapExplorerWnd.OnClose_Static(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting explorerWnd instance "..sCtrlName.."\r\n");
		return;
	end
	self:OnClose();
end

---------------------------------------------------------
-- the following methods are  derived form explorerWnd
---------------------------------------------------------

-- usually overriden by its derived class.
function MapExplorerWnd:GetType()
	return "MapExplorerWnd";
end

-- called by explorer when this window should be stopped (stop connecting).
function MapExplorerWnd:OnStop()
end

-- called by explorer when this window should be closed and loses its connections
function MapExplorerWnd:OnClose()
	self:OnStop();
	self:Destroy();
end

-- called by explorer when this window is informed of changing size. 
-- Usually only the width matters, since the parent will scroll this window if it is too long.
-- @param clientWidth: expected client size of this window 
-- @param clientHeight: expected client size of this window 
function MapExplorerWnd:OnSize(clientWidth, clientHeight)
end

-- called by explorer when this window becomes the current active window in the explorer
function MapExplorerWnd:OnActive()
end

-- called by explorer when this window becomes an inactive window in the explorer
function MapExplorerWnd:OnDeActive()
end

-- called by explorer when this window needs to be refreshed
function MapExplorerWnd:OnRefresh()
end

-- get the url of the window
function MapExplorerWnd:GetURL()
	return self.url;
end

-- set the url of the window
function MapExplorerWnd:SetURL(url)
	self.url = url;
end

-- get the title of the window
function MapExplorerWnd:GetURL()
	return self.title;
end

-- set the title of the window
function MapExplorerWnd:SetURL(title)
	self.title = title;
end

function MapExplorerWnd:OnResize()
	local _this = ParaUI.GetUIObject(self.name)
	if(_this:IsValid() == false)then
		log("MapExplorerWnd container can not found -_-# \r\n");
		return;
	end
	
	__,__,self.width,self.height = _this:GetAbsPosition();
	self.width = self.width - 2;
	self.height = self.height - 4;
	self:RefreshLayout();
	
	--_this = CommonCtrl.GetControl("mbSideBar");
	--if(_this == nil)then
		--log("mbSideBar instance can not found -_-# \r\n");
		--return;
	--end
	--_this:OnResize();
	
	--local _this = CommonCtrl.GetControl(self.name.."mb");
	--if( _this == nil)then
		--log(" MapExplorerWnd:OnResize : err getting mapBrowser instance -_-# \r\n");
	--elseif( _this.OnResize ~= nil)then
		--_this:OnResize(self.width,self.height);
	--end
	
end

function MapExplorerWnd:ToggleLayout()
	self.isHideSideBar = (not self.isHideSideBar);
	NPL.SetTimer(self.timerID,0.01,string.format([[;CommonCtrl.MapExplorerWnd.TransitLayout("%s");]],self.name));
end

function MapExplorerWnd.TransitLayout(ctrName)
	local self = CommonCtrl.GetControl(ctrName);
	if(self == nil)then
		log("err getting MapExplorerWnd instance"..ctrName.."\r\n");
		NPL.KillTimer(self.timerID);
		return;
	end

	local _this = CommonCtrl.GetControl("mbSideBar");
	if(_this == nil)then
		log("mbSideBar instance can not found -_-# \r\n");
		return;
	end
	_this:OnResize();
	
	self.timeCount = self.timeCount + 1;	
	if( self.isHideSideBar)then
		self.sideBarWidth = self.sideBarWidth - 3 * self.timeCount;
		if( self.sideBarWidth < 5)then
			self.sideBarWidth = 5;
			self.timeCount = 0;
			NPL.KillTimer(self.timerID);
			_this:Show( false );
		end
	else
		_this:Show(true);
		self.sideBarWidth = self.sideBarWidth + 3 * self.timeCount;
		if( self.sideBarWidth > self.refSideBarWidth)then
			self.sideBarWidth = self.refSideBarWidth;
			self.timeCount = 0;
			NPL.KillTimer(self.timerID);
		end
	end	
	self:RefreshLayout();	
end

function MapExplorerWnd:RefreshLayout()
	local _this = ParaUI.GetUIObject(self.name)
	if(_this:IsValid() == false)then
		log("MapExplorerWnd container can not found -_-# \r\n");
		return;
	end

	local __,__,_width,_height = _this:GetAbsPosition();
	
	_width = _width - 2;
	_height = _height - 4;
	_this = CommonCtrl.GetControl("worldMapBrowser");
	if(_this == nil)then
		log("worldMapBrowser instance can not found -_-# \r\n");
		return;
	end
	_this:SetPos(2,2,_width - self.sideBarWidth-self.midBarWidth,_height);	
	
	_this = CommonCtrl.GetControl("mbMidBar");
	if(_this == nil)then
		log("mbMidBar instance can not found -_-# \r\n");
		return;
	end
	if( self.isHideSideBar)then
		_this:SetPosition(_width - self.sideBarWidth-self.midBarWidth+2,2,self.midBarWidth + 2,_height);
	else
		_this:SetPosition(_width - self.sideBarWidth-self.midBarWidth+2,2,self.midBarWidth,_height);
	end

		
	_this = CommonCtrl.GetControl("mbSideBar");
	if(_this == nil)then
		log("mbSideBar instance can not found -_-# \r\n");
		return;
	end
	_this:SetPosition( _width - self.sideBarWidth+2,2,self.sideBarWidth-2,_height);
end





