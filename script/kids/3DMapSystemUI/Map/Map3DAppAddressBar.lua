--[[

Use the lib:
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppAddressBar.lua");
--]]

NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppCommon.lua");

local AddressBar = {
	name = "address1";
	parent = nil;
	
	--layout
	alignment = "_lt";
	x = 0;
	y = 0;
	width = 600;
	height = 24;
}
CommonCtrl.MapAddressBar = AddressBar;



function AddressBar:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;
end

function AddressBar:Show(bShow)
	local _this;
	_this = ParaUI.GetUIObject(self.name);
	
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
end

function AddressBar:Init()
	if( self.name == nil)then
		log("map address bar name can not be nil -_-#\n");
		return;
	end
	
	local _parent;
	
	_parent = ParaUI.CreateUIObject("container",self.name,self.alignment,self.x,self.y,self.width,self.height);
	if(self.parent == nil)then
		_parent:AttachToRoot();
	else
		self.parent:AddChild(_parent);
	end
	CommonCtrl.AddControl(self.name,self);
	
	local _this;
	_this = ParaUI.CreateUIObject("text","s","_lt",13,8,73,16);
	_this.text = "地址";
	_this:GetFont("text").color = "128 128 128";
	_parent:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("button", "navTo", "_rt", -264, 3, 24, 24)
	_this.background = "Texture/3DMapSystem/webbrowser/goto.png"
	--_this.onclick = string.format(";Map3DSystem.UI.WebBrowser.OnClickNavTo(%q);", wndName);
	_parent:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("button", "MCML", "_rt", -224, 3, 48, 24)
	_this.text = "MCML";
	--_this.background = "Texture/3DMapSystem/webbrowser/goto.png"
	--_this.onclick = string.format(";Map3DSystem.UI.WebBrowser.OnClickNavTo(%q);", wndName);
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("button", "navBack", "_rt", -154, 3, 24, 24)
	_this.background = "Texture/3DMapSystem/webbrowser/lastpage.png"
	--_this.onclick = string.format(";Map3DSystem.UI.WebBrowser.OnClickNavBack(%q);", wndName);
	_this.animstyle = 12;
	_parent:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("button", "navForward", "_rt", -124, 3, 24, 24)
	_this.background = "Texture/3DMapSystem/webbrowser/nextpage.png"
	--_this.onclick = string.format(";Map3DSystem.UI.WebBrowser.OnClickNavForward(%q);", wndName);
	_this.animstyle = 12;
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("button", "Stop", "_rt", -94, 3, 24, 24)
	_this.background = "Texture/3DMapSystem/webbrowser/stop.png"
	--_this.onclick = string.format(";Map3DSystem.UI.WebBrowser.OnClickNavStop(%q);", wndName);
	_this.animstyle = 12;
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("button", "RefreshBtn", "_rt", -64, 3, 24, 24)
	_this.background = "Texture/3DMapSystem/webbrowser/refresh.png"
	--_this.onclick = string.format(";Map3DSystem.UI.WebBrowser.OnClickNavRefresh(%q);", wndName);
	_this.animstyle = 12;
	_parent:AddChild(_this);

	_this = ParaUI.CreateUIObject("button", "homeBtn", "_rt", -34, 3, 24, 24)
	_this.background = "Texture/3DMapSystem/webbrowser/homepage.png"
	--_this.onclick = string.format(";Map3DSystem.UI.WebBrowser.OnClickHomePage(%q);", wndName);
	_this.animstyle = 12;
	_parent:AddChild(_this);
	
	NPL.load("(gl)script/ide/dropdownlistbox.lua");
	local ctl = CommonCtrl.dropdownlistbox:new{
		name = self.name.."comboBoxAddress",
		alignment = "_mt",
		left = 80,
		top = 3,
		width = 280,
		height = 24,
		dropdownheight = 106,
		parent = _parent,
		text = "",
		items = {"KidsMovie", "Maya Island", "Wonderland",},
		--onselect = string.format("Map3DSystem.UI.WebBrowser.OnClickNavTo(%q);", wndName),
	};
	ctl:Show();
end