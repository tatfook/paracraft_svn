
NPL.load("(gl)script/kids/3DMapSystemUI/Map/MapMessageDefine.lua");

SideBarMarkWnd = {
	name = "sbMarkWnd",
	parent = nil,
	app = nil,
	isVisible = nil,
	listeners = {},
}

function SideBarMarkWnd:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	o:Init();
	CommonCtrl.AddControl(o.name,o);
	return o;	
end

function SideBarMarkWnd:Show(bShow)
end

function SideBarMarkWnd:Destroy()
end

function SideBarMarkWnd:Init()
	self.maps = CommonCtrl.TreeView:new{
		name = "maplist",
		alignment = "_fi",
		left = 2,
		top = 2,
		width = 2,
		height = 2,
		parent = self.parent,
		DefaultIconSize = 18,
		DefaultIndentation = 15,
		DefaultNodeHeight = 25,
	}
	local node = ctl.RootNode;
	node:AddChild( CommonCtrl.TreeNode:new({Text = "我的家", Name = "Home", Type = "Home", Icon = "Texture/3DMapSystem/common/Home.png"}));
	
end

function SideBarMarkWnd:CreateUI()
	local _this = ParaUI.CreateUIObject("container",self.name,"_fi",2,25,2,2);
	_this.background = "";
	_this.onsize = string.format(";Map3DApp.SideBarMarkWnd.OnResize(%q)",self.name);
	if(self.parent)then
		self.parent:AddChild(_this);
	else
		_this:AttachToRoot();
	end
	
	if(self.maps)then
		self.maps.parent = self.parent;
	end	
end

function SideBarMarkWnd.OnResize(ctrName)
	
end

function SideBarMarkWnd:Temp()
end

function SideBarMarkWnd:Temp()
end

function SideBarMarkWnd:Temp()
end
