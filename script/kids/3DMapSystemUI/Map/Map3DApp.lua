--[[
Title:the map app entry point
This is the window class that should be invoked from other UI. 
Author(s): SunLingFeng
Date: 2008/1/10
Use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DApp.lua");
local _this = Map3DApp.MainWnd:new{
	name = Map3DApp.name;
	parent = _parent;
};
_this:Show(true);
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppCommon.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppBBSMsg.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/SideBar/TileEditMediator.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/SideBar/TileEditWnd.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/MapBrowserFrame.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Controllers.lua");


if(not Map3DApp)then Map3DApp = {};end;

local MainWnd = {
	name = "Map3DApp.MainWnd",
	parent = nil,
	
	sideBarWidth = 200,
	splitWidth = 8,
	hideSizeBar = false,

	isBBSVisible = true,
	bbsBarHeight = 30,
	isSideBarVisible = true,
	
	--layout related parameters,private
	sideBarWidth = 200,
	isHideSideBar = false,
	slideTimerID = 0,
	
	activeFrame = nil,
	
	--mask
	maskTransparent = 255,
	maskFadeTimerID = 0,
	
	switchFrameController = nil;
}
Map3DApp.MainWnd = MainWnd;

--========display model enum=========
Map3DApp.MainWnd.DisplayMode = {};
Map3DApp.MainWnd.DisplayMode.normal = 0;
Map3DApp.MainWnd.DisplayMode.edit = 1;

--========public=====================
function MainWnd:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	o:Init();
	CommonCtrl.AddControl(o.name,o);
	return o;
end

function MainWnd:Show(bShow)
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		if(bShow == false)then
			return;
		end
		self:CreateUI();
		return;
	else
		if(bShow == nil)then
			_this.visible = not _this.visible;
		else
			_this.visible = bShow;
		end
		if(_this.visible)then
			self:Resize();
		end
	end
	
	--stop bbs bar update if it's invisible
	local isVisible = _this.visible;
	
	local childWnd = CommonCtrl.GetControl(self.bbsBar);
	if(childWnd ~= nil)then
		childWnd:Show(isVisible);
	end	
	
	childWnd = CommonCtrl.GetControl(self.mapBrowser);
	if(childWnd ~= nil)then
		childWnd:Show(isVisible);
	end
end

function MainWnd:SetParentWnd(parent)
	self.parent = parent;
end

function MainWnd:SetPosition(x,y,width,height)
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid())then
		if(x ~= nil)then
			_this.x = x;
		end
		if(y ~= nil)then
			_this.y = y;
		end
		if(width ~= nil)then
			_this.width = width;
		end
		if(height ~= nil)then
			_this.height = height;
		end
	end
end

function MainWnd:GetPosition()
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid())then
		return _this:GetAbsPosition();
	end
	return nil;
end
 
function MainWnd:SwitchFrame(frameName)
	local lastFrame = self.activeFrame;
	self.activeFrame = nil;
	
	--set active frame
	if(frameName == "map")then
		self.activeFrame = Map3DApp.MapBrowserFrame;
	elseif(frameName == "edit")then
		NPL.load("(gl)script/kids/3DMapSystemUI/Map/SideBar/TileEditWnd.lua");
		self.activeFrame = Map3DApp.TileEditWnd;
		NPL.load("(gl)script/kids/3DMapSystemUI/Map/SideBar/TileEditMediator.lua");
		Map3DApp.TileEditMediator.SetParentForm(self);
		Map3DApp.TileEditMediator.Init();
	end
	
	if(self.activeFrame)then
		--hide last frame
		if(lastFrame and lastFrame.Show)then
			lastFrame.Show(false);
		end
		
		--show new frame
		local parent = ParaUI.GetUIObject(self.name);
		if(parent:IsValid())then
			local __,__,width,height = parent:GetAbsPosition();
			self.activeFrame.SetParent(parent)
			self.activeFrame.Show(true);
			self.activeFrame.SetSize(width,height - self.bbsBarHeight);
		end
	else
		self.activeFrame = lastFrame;
	end
end

function MainWnd:MsgProcess(msg,data)
	if(msg == "switchFrm")then
		self.SwitchFrame(data);
	end
end

--============private================

function MainWnd:CreateUI()
	if(self.name == nil or self.name == "")then
		return;
	end
	
	--create main container
	local _parent = ParaUI.CreateUIObject("container",self.name,"_fi",2,2,2,2);
	_parent.onsize = string.format(";local this=CommonCtrl.GetControl(%q);if(this~=nil and this.Resize~=nil)then this:Resize();end;",self.name);
	if(self.parent == nil)then
		_parent:AttachToRoot();
	else
		self.parent:AddChild(_parent);
		_parent.background = "";
	end
	
	--a mask layer,showed when switch frame
	local _this;
	_this =ParaUI.CreateUIObject("container",self.name.."mask","_lt",0,0,0,0);
	--_this.background = "Texture/whitedot.PNG";
	_this.enabled = false;
	_this.visible = false;
	_parent:AddChild(_this);
	
	--create map browser frame
	self.activeFrame = Map3DApp.MapBrowserFrame;
	self.activeFrame.SetParentForm(self);
	self.activeFrame.SetParent(_parent);
	self.activeFrame.Show(true);
	
	--create bbs container
	_this = ParaUI.CreateUIObject("container",self.name.."bbsCtn","_lt",0,0,0,0);
	_this.background = "";
	_parent:AddChild(_this);
	local tempParent = _this;
	
	--create bbs bar
	NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppBBSBar.lua");
	self.bbsBar = self.name.."billboard";
	_this = CommonCtrl.GetControl(self.bbsBar);
	if(_this == nil)then 
		_this = CommonCtrl.MapBBSBar:new{
			name = self.bbsBar;
			alignment = "_lt";
		};
	end
	_this:SetParent(tempParent);
	_this:Show(true);
	--TODO:delete this
	CommonCtrl.MapBBSBar.Test(_this);
	
	--create send bbs msg button
	_this = ParaUI.CreateUIObject("button",self.name.."btnMsgWnd","_rt",-150,3,110,24);
	_this.text = "发消息";
	_this.onclick = string.format(";local this=CommonCtrl.GetControl(%q);if(this~=nil and this.ShowMsgEditBox~=nil)then this:ShowMsgEditBox();end;",self.name);
	tempParent:AddChild(_this);
	
	--create show history message window button
	_this = ParaUI.CreateUIObject("button",self.name.."BtnBbsHis","_rt",-34,3,26,24);
	_this.text = "△";
	_this.tooltip = "显示消息历史纪录";
	_this.onclick = string.format(";local this=CommonCtrl.GetControl(%q);if(this~=nil and this.ShowMsgHistory~=nil)then this:ShowMsgHistory();end;",self.name);
	tempParent:AddChild(_this);
	
	self.msgHistoryWnd = self.name.."msgHistory";
	self.msgEditWnd = self.name.."msgEdit";
	
	self:Resize();
end

function MainWnd:Resize()
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		log("Map3DApp.MainWnd.Resize: can not find control,resize failed -_-# \n");
		return;
	end
	
	local __,__,pWndWidth,pWndHeight = _this:GetAbsPosition();
	
	--resize bbs bar
	if(self.isBBSVisible)then
		local bbsCtn = ParaUI.GetUIObject(self.name.."bbsCtn");
		if(bbsCtn:IsValid())then
			self.bbsBarHeight = 30;
			bbsCtn.x = 0;
			bbsCtn.y = pWndHeight - self.bbsBarHeight;
			bbsCtn:SetSize(pWndWidth, self.bbsBarHeight)
		
			local bbsBar = CommonCtrl.GetControl(self.bbsBar);
			if(bbsBar ~= nil)then
				bbsBar:SetPosition(4,3,pWndWidth - 160,24);
			end
		else
			self.bbsBarHeight = 0;
		end
	else
		self.bbsBarHeight = 0;	
	end
	
	--resize mask
	_this = ParaUI.GetUIObject(self.name.."mask");
	if(_this:IsValid())then
		_this.width = pWndWidth;
		_this.height = pWndHeight - self.bbsBarHeight;
	end
	
	--resize main frame
	if(self.activeFrame ~= nil)then
		self.activeFrame.SetSize(pWndWidth,pWndHeight - self.bbsBarHeight);
	end
	
	--resize message edit box if it's visible 
	local msgEditWnd = CommonCtrl.GetControl(self.msgEditWnd);
	if(msgEditWnd ~= nil)then
		if(msgEditWnd:IsVisible())then
			local __,__,width,height = msgEditWnd:GetPosition();
			if(width ~= nil and height ~= nil)then
				msgEditWnd:SetPosition(pWndWidth - width - 10,pWndHeight - height - self.bbsBarHeight - 10);
			end
		end
	end
	
	--resize msg history wnd if it's visible
	local msgHistoryWnd = CommonCtrl.GetControl(self.msgHistoryWnd);
	if(msgHistoryWnd ~= nil)then
		if(msgHistoryWnd:IsVisible())then
			local __,__,width,height = msgHistoryWnd:GetAbsPosition();
			if( width ~= nil and height ~= nil)then
				msgHistoryWnd:SetPosition( (pWndWidth-width)/2,(pWndHeight - height)/2);
			end
		end
	end
	
end

function MainWnd:Init()
	self.slideTimerID = Map3DApp.Timer.GetNewTimerID();
	self.maskFadeTimerID = Map3DApp.Timer.GetNewTimerID();
	Map3DApp.MapBrowserFrame:Init();
	Map3DApp.MapBrowserFrame.app = self;
	
	self.switchFrameController = Map3DApp.SwitchFrameController:new{
		name = self.name.."swtFrmCtlr",
		mainWnd = self,
	};
end

function MainWnd:ShowBBS(isVisible)
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		return
	end
	
	if(isVisible == nil)then
		self.isBBSVisible = not self.isBBSVisible;
	else
		self.isBBSVisible = isVisible;
	end
	
	local _this = ParaUI.GetUIObject(self.name.."bbsCtn");
	if(_this:IsValid())then
		_this.visible = self.isBBSVisible;
	end
	
	self:Resize();
end

function MainWnd:ShowMsgEditBox(bShow)
	local msgEdit = CommonCtrl.GetControl(self.msgEditWnd);
	if(msgEdit == nil)then
		msgEdit = CommonCtrl.MapBBSMsgEdit:new{
			name = self.msgEditWnd,
		}
	end
	msgEdit:SetParent(ParaUI.GetUIObject(self.name));
	msgEdit:Show(bShow);
	
	if(msgEdit:IsVisible())then
		local _this = ParaUI.GetUIObject(self.name);
		if(_this:IsValid() == false)then
			return;
		end

		local __,__,pWndWidth,pWndHeight = _this:GetAbsPosition();
		local __,__,width,height = msgEdit:GetPosition();
		if(width == nil)then
			return;
		end

		msgEdit:SetPosition(pWndWidth - width-10,pWndHeight - height - self.bbsBarHeight-10);
	end
end

function MainWnd:ShowMsgHistory(bShow)
	local msgWnd = CommonCtrl.GetControl(self.msgHistoryWnd);
	if(msgWnd == nil)then
		msgWnd = CommonCtrl.MapBBSMsgViewer:new{
			name = self.msgHistoryWnd,
		};
	end
	msgWnd:SetParent(ParaUI.GetUIObject(self.name));
	msgWnd:Show(bShow);	
	
	if(msgWnd:IsVisible())then
		local mainWnd = ParaUI.GetUIObject(self.name);
		if(mainWnd:IsValid() == false)then
			return;
		end
		
		local __,__,pWndWidth,pWndHeight = mainWnd:GetAbsPosition()
		local __,__,width,height = msgWnd:GetPosition();
		msgWnd:SetPosition((pWndWidth - width)/2,(pWndHeight - height)/2);
	end
end

function MainWnd:OnClose()

end

function MainWnd:OnDestroy()
	if(self.bbsBar ~= nil)then
		CommonCtrl.DeleteControl(self.bbsBar);
	end
	ParaUI.Destroy(self.name);
end

function MainWnd:StartMask()
	self.maskTransparent = 255;
	NPL.SetTimer(self.maskFadeTimerID,0.01,string.format(";Map3DApp.MainWnd.Fading(%q,%d)",self.name,self.maskFadeTimerID));
end

function MainWnd.Fading(ctrName,timerID)
	local self = CommonCtrl.GetControl(ctrName);
	if(self == nil)then
		NPL.KillTimer(timerID);
		return;
	end
	
	local _this = ParaUI.GetUIObject(self.name.."mask")
	if(_this:IsValid() == false)then
		NPL.KillTimer(timerID);
		return;
	end
	
	_this:GetTexture("background").transparency = self.maskTransparent;
	if(self.maskTransparent <= 0)then
		NPL.KillTimer(timerID);
		_this:BringToBack();
		_this.visible = false;
	end
	
	if(self.maskTransparent >0)then
		self.maskTransparent = self.maskTransparent - 15;
	end
	if(self.maskTransparent < 0)then
		self.maskTransparent = 0;
	end
end

function MainWnd.OnLoad()
end