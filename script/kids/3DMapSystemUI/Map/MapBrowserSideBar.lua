--[[
Title: map browser side bar
Author(s): Sun Lingfeng
Date: 2008/4/22
Desc: this control contains 3 tab page:search page,land page,mark page.
	See file SideBarSearchWnd.lua,SideBarLandWnd.lua for detail;
Use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Map/MapBrowserSideBar.lua");
sideBar = Map3DApp.SideBar:new{
	name = self.ctrSideBar,
	parent = parentControl,
}
sideBar:Show(bShow);
------------------------------------------------------]]
NPL.load("(gl)script/ide/MainMenu.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/SideBarLandWnd.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/SideBarSearchWnd.lua");

NPL.load("(gl)script/kids/3DMapSystemUI/Map/SideBar/LandWnd.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/SideBar/Map2DMarkInfo.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/SideBar/MarkProvider.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/SideBar/MarkUILayer.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/SideBar/MyMapWnd.lua");


SideBar = {
	name = "mbSideBar",
	searchPage = nil,
	myMapPage = nil,
	landPage = nil,
	parent = nil,
	app = nil,
	isVisible = false,
}
Map3DApp.SideBar = SideBar;

function SideBar:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	o:Init();
	CommonCtrl.AddControl(o.name,o);
	return o;
end

function SideBar:Show(bShow)
	if(bShow == nil)then
		self.isVisible = not self.isVisible;
	else
		isVisible = bShow;
	end
	
	local _this = CommonCtrl.GetControl(self.name.."tabMenu");
	if(_this)then
		_this:Show(self.isVisible);
		CommonCtrl.MainMenu.OnClickTopLevelMenuItem(self.name.."tabMenu",3);
	end
	
	if(self.landPage)then
		self.landPage:Show(self.isVisible);
	end
end

function SideBar:SetParent(parent)
	self.parent = parent;
	local _this = CommonCtrl.GetControl(self.name.."tabMenu");
	_this.parent = parent;
	
	self.landPage:SetParentWnd(parent);
	if(self.searchPage)then
		self.searchPage:SetParentWnd(parent);
	end
end

function SideBar:SetTabPage(pageName)
	if(pageName == "landPage")then
		if(self.landPage)then self.landPage:Show(true);end
		if(self.searchPage)then self.searchPage:Show(false);end
		Map3DApp.MyMapWnd.Show(false,self.parent);
	elseif(pageName == "searchPage")then
		if(self.searchPage)then self.searchPage:Show(true);end
		if(self.landPage)then self.landPage:Show(false);end
		Map3DApp.MyMapWnd.Show(false,self.parent);
		
		self.searchPage:SetCommendWorld(Map3DApp.SideBarSearchWnd.GetCommendWorld());
		self.searchPage:SetSearchResult(Map3DApp.SideBarSearchWnd.GetSearchResult());
	elseif(pageName == "myMap")then
		if(self.searchPage)then self.searchPage:Show(false);end
		if(self.landPage)then self.landPage:Show(false);end
		Map3DApp.MyMapWnd.Show(true,self.parent);
	end
end

---==========private=================
function SideBar:Init()
	--create tab page menu
	local _this = CommonCtrl.MainMenu:new{
		name = self.name.."tabMenu",
		alignment = "_lt",
		left = 5,
		top = 3,
		width = 200,
		height = 20,
		parent = self.parent,
		SelectedTextColor = "0 0 0",
		MouseOverItemBG = "",
		UnSelectedMenuItemBG = "Texture/3DMapSystem/common/ThemeLightBlue/tabitem_unselected.png: 6 6 6 2",
		SelectedMenuItemBG = "Texture/3DMapSystem/common/ThemeLightBlue/tabitem_selected.png: 6 6 6 2",
	};
	local node = _this.RootNode;
	node:AddChild(CommonCtrl.TreeNode:new({Text = "搜索", Name = "search", parentCtr = self.name,onclick = Map3DApp.SideBar.OnClick}));
	node:AddChild(CommonCtrl.TreeNode:new({Text = "我的地图", Name = "myMap",parentCtr = self.name, onclick = Map3DApp.SideBar.OnClick}));
	node:AddChild(CommonCtrl.TreeNode:new({Text = "我的土地", Name = "myLand",parentCtr = self.name, onclick = Map3DApp.SideBar.OnClick}));

	--land page
	--npl land page control
	self.landPage = Map3DApp.SideBarLandWnd:new{
		name = self.name.."landPage",
		parent = self.parent,
		app = self.app,
	};
	if(self.app)then
		self.app.switchFrameController:AddTrigger(self.landPage);
	end
	
	--[[
	--mcml land page control
	NPL.load("(gl)script/kids/3DMapSystemUI/Map/SideBarLandPage.lua");
	Map3DApp.LandPage:Create("testPage",self.parent,"_fi",2,25,2,2);
	--]]


	--search page
	self.searchPage = Map3DApp.SideBarSearchWnd:new{
		name = self.name.."searchPage",
		parent = self.parent,
	}

	--TODO:refactor code here
	--my map page
	Map3DApp.MarkProvider.Init();
	local map = CommonCtrl.GetControl("mb_map");
	Map3DApp.MarkUILayer.Init("mb_map");
	self.myMapPage = Map3DApp.MyMapWnd;
end

function Map3DApp.SideBar.OnClick(node)
	local self;
	if(node and node.parentCtr)then
		self = CommonCtrl.GetControl(node.parentCtr);
		if(self == nil)then
			return;
		end
	end

	if(node.Name == "search")then
		self:SetTabPage("searchPage");
	elseif(node.Name == "myMap")then
		self:SetTabPage("myMap");
	elseif(node.Name == "myLand")then
		self:SetTabPage("landPage");
	end
end


