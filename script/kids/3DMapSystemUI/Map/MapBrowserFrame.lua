--[[
Title: Map Browser Frame
Author(s): Sun Lingfeng
Desc:world map browser frame
Date: 
Use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Map/MapBrowserFrame.lua");
--be sure to set the control size first
Map3DApp.MapBrowserFrame.x = 0;
Map3DApp.MapBrowserFrame.y = 0;
Map3DApp.MapBrowserFrame.width = 0;
Map3DApp.MapBrowserFrame.height = 0;
Map3DApp.MapBrowserFrame.parent = _parent;
Map3DApp.MapBrowserFrame.Show(true)
-------------------------------------------------------
]]

Map3DApp.MapBrowserFrame = {};
Map3DApp.MapBrowserFrame.name = "mapBrowserFrm";

Map3DApp.MapBrowserFrame.x = 0;
Map3DApp.MapBrowserFrame.y = 0;
Map3DApp.MapBrowserFrame.width = 0;
Map3DApp.MapBrowserFrame.height = 0;
Map3DApp.MapBrowserFrame.parent = nil;
Map3DApp.MapBrowserFrame.parentForm = nil;
Map3DApp.MapBrowserFrame.sideBarWidth = 200;
Map3DApp.MapBrowserFrame.splitWidth = 8;

--child control
Map3DApp.MapBrowserFrame.uiSideBar = "mb_sideBarCtn";
Map3DApp.MapBrowserFrame.uiMap = "mb_mapCtn";
Map3DApp.MapBrowserFrame.uiSplit = "mb_split";
Map3DApp.MapBrowserFrame.ctrMap = "mb_map";
Map3DApp.MapBrowserFrame.ctrSideBar = "mb_sideBar";

Map3DApp.MapBrowserFrame.uiController = nil;

Map3DApp.MapBrowserFrame.bShowSideBar = true;

function Map3DApp.MapBrowserFrame.Show(bShow)
	local self = Map3DApp.MapBrowserFrame;
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
	end
end

function Map3DApp.MapBrowserFrame.GetPosition()
	local self = Map3DApp.MapBrowserFrame;
	return self.x,self,y,self.width,self.height;
end

function Map3DApp.MapBrowserFrame.CreateUI()
	local self = Map3DApp.MapBrowserFrame;
	local _this,_parent;
	--create side bar container
	_this = ParaUI.CreateUIObject("container",self.name,"_lt",0,0,0,0);
	if(self.parent)then
		self.parent:AddChild(_this);
	else
		_this:AttachToRoot();
	end
	_parent = _this;
	
	--side bar
	_this = ParaUI.CreateUIObject("container",self.uiSideBar,"_lt",0,0,0,0);
	_this.fastrender = false;
	_parent:AddChild(_this);
	local tempParent = _this;
	
	--map
	_this = ParaUI.CreateUIObject("container",self.uiMap,"_lt",0,0,0,0);
	_parent:AddChild(_this);
	local mapCtn = _this;
	
	--create map
	local map = CommonCtrl.GetControl(self.ctrMap);
	if(map == nil)then
		NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppMap.lua");
		map = Map3DApp.WorldMap.Map:new{
			name = self.ctrMap;
		}
	end
	map:SetParentWnd(_this);
	map:SetEnable(true);
	map:Show(true);
	
	_this = ParaUI.CreateUIObject("text",self.name.."tip","_lt",4,4,0,0);
	_this.shadow = true;
	_this.text = "地球尺度的3D世界地图将在正式版时可用,测试期间,仅彩色的帕拉岛可以使用.";
	_this:GetFont("text").color = "128 128 128";
	mapCtn:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("text",self.name.."opTip","_rb",-420,-16,0,0);
	_this.text = "操作提示:鼠标滚轮缩放,鼠标左键可拖动地图,鼠标右键在三维地图可改变视角"
	_this:GetFont("text").color = "42 165 42";
	mapCtn:AddChild(_this);
	
	local sideBar = CommonCtrl.GetControl(self.ctrSideBar);
	if(sideBar == nil)then
		NPL.load("(gl)script/kids/3DMapSystemUI/Map/MapBrowserSideBar.lua");
		sideBar = Map3DApp.SideBar:new{
			name = self.ctrSideBar,
			app = self.app;
			parent = tempParent;
		}
	end
	sideBar:SetParent(tempParent);
	sideBar:Show(bShow);
	
	--TODO:delete this
	--NPL.load("(gl)script/kids/3DMapSystemUI/Map/SideBar/sidebar_main.lua");
	--Map3DApp.sidebar_main.SetParentForm(self.parentForm);
	--Map3DApp.sidebar_main.Show(tempParent,map);
	
	--splite
	_this = ParaUI.CreateUIObject("button",self.uiSplit,"_lt",0,0,0,0);
	_this.onclick = ";Map3DApp.MapBrowserFrame.ShowSideBar()";
	_parent:AddChild(_this);
	
	self.uiController:Init(map,Map3DApp.sidebar_main,Map3DApp.LandWnd);
	
	self.SetSize(self.x,self.y,self.width,self.height);
end

function Map3DApp.MapBrowserFrame.SetPosition(x,y)
	local self = Map3DApp.MapBrowserFrame;
	self.x = x;
	self.y = y;
	
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid())then
		_this.x = self.x;
		_this.y = self.y;
	end
end

function Map3DApp.MapBrowserFrame.SetSize(width,height)
	local self = Map3DApp.MapBrowserFrame;
	self.width = width;
	self.height = height;
	if(self.width < 450)then self.width = 450;end
	if(self.height < 300)then self.height = 300;end
	
	--resize container
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid())then
		_this:SetSize(self.width,self.height);	
		
		local sbWidth = 0;
		if(self.bShowSideBar)then
			sbWidth = self.sideBarWidth;
		end
	
		--resize map
		_this = ParaUI.GetUIObject(self.uiMap);
		if(_this:IsValid())then
			_this:SetSize(self.width - sbWidth - self.splitWidth,self.height);
		end
		
		local map = CommonCtrl.GetControl(self.ctrMap);
		if(map)then
			map:FireViewRegionChange();
		end
		
		--resize split
		_this = ParaUI.GetUIObject(self.uiSplit);
		if(_this:IsValid())then
			_this.x = self.width - sbWidth - self.splitWidth;
			_this:SetSize(self.splitWidth,self.height);
		end
		
		--resize side bar
		_this = ParaUI.GetUIObject(self.uiSideBar);	
		if(_this:IsValid())then
			_this.x = self.width - sbWidth;
			_this:SetSize(sbWidth,self.height);
		end		
	end
end

function Map3DApp.MapBrowserFrame.Release()
	local self = Map3DApp.MapBrowserFrame;
	ParaUI.Destroy(self.name);
end

function Map3DApp.MapBrowserFrame.ShowSideBar(bShow)
	local self = Map3DApp.MapBrowserFrame;
	if(bShow == nil)then
		self.bShowSideBar = not self.bShowSideBar;
	else
		self.bShowSideBar = bShow;
	end

	self.SetSize(self.width,self.height);
end

function Map3DApp.MapBrowserFrame.SetParent(_parent)
	Map3DApp.MapBrowserFrame.parent = _parent;
end

--set the root control name
function Map3DApp.MapBrowserFrame.SetParentForm(parentForm)
	Map3DApp.MapBrowserFrame.parentForm = parentForm;
end


---=================================
function Map3DApp.MapBrowserFrame:Init()
	NPL.load("(gl)script/kids/3DMapSystemUI/Map/MapUIController.lua");
	self.uiController = Map3DApp.MBController:new{
		name = "mbController",
	};
end

