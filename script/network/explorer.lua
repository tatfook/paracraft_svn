--[[
Title: explorer window used for browsing 3D worlds via URL
Author(s): LiXizhi
Date: 2007/3/23

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/network/explorer.lua");
local ctl = CommonCtrl.explorer:new{
	name = "explorer1",
	alignment = "_lt",
	left=0, top=0,
	width = 800,
	height = 600,
	parent = nil,
};
ctl:Show();
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/network/LoginWnd.lua");
NPL.load("(gl)script/network/PersonalWorldExplorerWnd.lua");
NPL.load("(gl)script/network/MapExplorerWnd.lua");
NPL.load("(gl)script/network/explorerWnd.lua");
NPL.load("(gl)script/ide/gui_helper.lua");

local L = CommonCtrl.Locale("IDE");

-- define a new control in the common control libary

-- default member attributes
local explorer = {
	-- the top level control name
	name = "explorer1",
	-- normal window size
	alignment = "_lt",
	left = 50,
	top = 20,
	width = 900,
	height = 700, 
	togglesize = {
		[1] = {
			width = 800, -- used for toggle window size. 
			height = 600, -- used for toggle window size. 
		},
		[2] = {
			width = 900, -- used for toggle window size. 
			height = 700, -- used for toggle window size. 
		},
	},
	currentSizeIndex = 1,
	parent = nil,
	-- child windows
	maxChildCount = 5, -- max number of child windows allowed
	tabwidth = 138, -- width of the tabs
	tabheight = 26, -- height of the tabs
	tabSpacing = 2, -- spacing between tabs in pixels
	ChildWindows = {}, -- a list of explorerWnd derived control names
	ActiveWindow = nil, -- name of the active window in the ChildWindows.
	NameCount = 0, -- used for generating new window names.
	-- default member attributes of a opened child window
	explorerWndProperty = {
		-- child windows
		title = "untitled", 
		HistoryURLs = {}, -- a list of URLs that this window has visited.
		taborder = 0, -- used for ordering the tabs.
	},
	-- const members
	UrlSavePath = "config/explorer_urls.txt",
	maxtitlelength = 12,
}
CommonCtrl.explorer = explorer;

-- constructor
function explorer:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- constructor for explorerWndProperty
function explorer.explorerWndProperty:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Destroy the UI control
function explorer:Destroy ()
	ParaUI.Destroy(self.name);
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function explorer:Show(bShow)
	local _this,_parent;
	if(self.name==nil)then
		log("explorer instance name can not be nil\r\n");
		return
	end
	
	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		_this=ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
		_this.background="Texture/whitedot.png;0 0 0 0";
		--_this:SetTopLevel(true);
		_this.candrag = true;
		_parent = _this;
		
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		CommonCtrl.AddControl(self.name, self);
		
		-- Explorer
		_this = ParaUI.CreateUIObject("container", "s", "_lt", 0, 0, 173, 145)
		_this.background="Texture/kidui/explorer/tool_left.png;83 111 173 145";
		_this.enabled = false;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("container", "s", "_mt", 173, 9, 225, 136)
		_this.background="Texture/kidui/explorer/tool_mid.png;0 120 1 136";
		_this.enabled = false;
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("container", "s", "_rt", -225, 0, 225, 145)
		_this.background="Texture/kidui/explorer/tool_right.png;0 111 225 145";
		_this.enabled = false;
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("container", "s", "_fi", 0, 145, 0, 0);
		_this.background="Texture/kidui/explorer/bg.png";
		_this.enabled = false;
		_parent:AddChild(_this);

		-- right top corner buttons of the explorer
		_this = ParaUI.CreateUIObject("button", "btn_minimize", "_rt", -161, 10, 26, 26)
		_this.background="Texture/kidui/explorer/minimize.png";
		_this.tooltip =L"minimize window";
		_this.onclick=string.format([[;CommonCtrl.explorer.OnMinimizeWindow("%s");]],self.name);
		_this.animstyle = 12;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btn_togglesize", "_rt", -105, 10, 26, 26)
		_this.background="Texture/kidui/explorer/togglesize.png";
		_this.onclick=string.format([[;CommonCtrl.explorer.OnToggleWindowSize("%s");]],self.name);
		_this.animstyle = 12;
		_this.tooltip = L"toggle window size";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btn_close", "_rt", -49, 10, 26, 26)
		_this.background="Texture/kidui/explorer/close3.png";
		_this.onclick=string.format([[;CommonCtrl.explorer.OnClose("%s");]],self.name);
		_this.animstyle = 12;
		_this.tooltip = L"Close";
		_parent:AddChild(_this);

		-- toolbars
		local nAnimStyle = 22;
		local left, top = 12, 30;
		local width,height = 64, 64;
		_this = ParaUI.CreateUIObject("button", self.name.."btn_new", "_lt", left, top, width,height);
		_this.background="Texture/kidui/explorer/newpage.png";
		_this.animstyle = nAnimStyle;
		_this.tooltip = L"new window";
		_this.enabled = false;
		_this.onclick=string.format([[;CommonCtrl.explorer.OnNewWindow("%s");]],self.name);
		_parent:AddChild(_this);
		left = left+width;

		_this = ParaUI.CreateUIObject("button", self.name.."btn_last", "_lt", left, top, width,height);
		_this.background="Texture/kidui/explorer/lastpage.png";
		_this.onclick=string.format([[;CommonCtrl.explorer.OnLastPage("%s");]],self.name);
		_this.animstyle = nAnimStyle;
		_this.tooltip = L"last page";
		_this.enabled = false;
		_parent:AddChild(_this);
		left = left+width;

		_this = ParaUI.CreateUIObject("button", self.name.."btn_next", "_lt", left, top, width,height);
		_this.background="Texture/kidui/explorer/nextpage.png";
		_this.onclick=string.format([[;CommonCtrl.explorer.OnNextPage("%s");]],self.name);
		_this.animstyle = nAnimStyle;
		_this.tooltip = L"next page";
		_this.enabled = false;
		_parent:AddChild(_this);
		left = left+width;
		
		_this = ParaUI.CreateUIObject("button", self.name.."btn_stop", "_lt", left, top, width,height);
		_this.background="Texture/kidui/explorer/stop.png";
		_this.onclick=string.format([[;CommonCtrl.explorer.OnStopPage("%s");]],self.name);
		_this.animstyle = nAnimStyle;
		_this.tooltip = L"stop";
		_parent:AddChild(_this);
		left = left+width;
		
		_this = ParaUI.CreateUIObject("button", self.name.."btn_refresh", "_lt", left, top, width,height);
		_this.background="Texture/kidui/explorer/refresh.png";
		_this.onclick=string.format([[;CommonCtrl.explorer.OnRefreshPage("%s");]],self.name);
		_this.animstyle = nAnimStyle;
		_this.tooltip =L"refresh page";
		_parent:AddChild(_this);
		left = left+width;

		_this = ParaUI.CreateUIObject("button", self.name.."btn_search", "_lt", left, top, width,height);
		_this.background="Texture/kidui/explorer/search.png";
		_this.tooltip = L"community map and search";
		_this.onclick=string.format([[;CommonCtrl.explorer.OnSearchPage("%s");]],self.name);
		_this.animstyle = nAnimStyle;
		_parent:AddChild(_this);
		left = left+width;

		_this = ParaUI.CreateUIObject("button", self.name.."btn_favourite", "_lt", left, top, width,height);
		_this.background="Texture/kidui/explorer/favourite.png";
		_this.onclick=string.format([[;CommonCtrl.explorer.OnFavouritePage("%s");]],self.name);
		_this.tooltip = L"favourite";
		_this.enabled = false;
		_this.animstyle = nAnimStyle;
		_parent:AddChild(_this);
		left = left+width;

		_this = ParaUI.CreateUIObject("button", self.name.."btn_homepage", "_lt", left, top, width,height);
		_this.background="Texture/kidui/explorer/homepage.png";
		_this.onclick=string.format([[;CommonCtrl.explorer.OnHomePage("%s");]],self.name);
		_this.animstyle = nAnimStyle;
		_this.tooltip = L"My home page";
		_parent:AddChild(_this);
		left = left+width;

		_this = ParaUI.CreateUIObject("button", self.name.."btn_history", "_lt", left, top, width,height);
		_this.background="Texture/kidui/explorer/history.png";
		_this.onclick=string.format([[;CommonCtrl.explorer.OnHistoryPage("%s");]],self.name);
		_this.animstyle = nAnimStyle;
		_this.tooltip = L"History";
		_this.enabled = false;
		_parent:AddChild(_this);
		left = left+width;
		
		_this = ParaUI.CreateUIObject("button", self.name.."btn_email", "_lt", left, top, width,height);
		_this.background="Texture/kidui/explorer/email.png";
		_this.onclick=string.format([[;CommonCtrl.explorer.OnEmailPage("%s");]],self.name);
		_this.tooltip = L"Email";
		_this.enabled = false;
		_this.animstyle = nAnimStyle;
		_parent:AddChild(_this);
		left = left+width;
		
		
		-- address bar
		left = 12;
		top = top + height + 10;
		height = 26;
		
		_this = ParaUI.CreateUIObject("text", "s", "_lt", left, top, 60,25);
		_this.text = L"Address:";
		_parent:AddChild(_this);

		local toright = 160;
		NPL.load("(gl)script/ide/dropdownlistbox.lua");
		local ctl = CommonCtrl.dropdownlistbox:new{
			name = self.name.."Address",
			alignment = "_mt",
			left=100, top=top,
			width = toright,
			height = height,
			buttonwidth = 20,
			dropdownheight = 100,
			parent = _parent,
			items = self:LoadURLListFromFile(self.UrlSavePath),
			container_bg = "Texture/kidui/explorer/editbox256x32.png",
			editbox_bg = "Texture/whitedot.png;0 0 0 0",
			dropdownbutton_bg = "Texture/kidui/explorer/dropdown_arrow.png",
			listbox_bg = "Texture/kidui/explorer/listbox_bg.png",
			onselect = string.format([[CommonCtrl.explorer.OnAddressTextSelected("%s");]], self.name),
		};
		ctl:Show();
		
		_this = ParaUI.CreateUIObject("button", "s", "_rt", -toright+3, top-1, height+2, height+2)
		_this.background="Texture/kidui/explorer/goto.png";
		_this.onclick=string.format([[;CommonCtrl.explorer.OnGotoAddress("%s");]],self.name); 
		_parent:AddChild(_this);

		-- tabs_cont
		left = 12;
		top = top + height + 10;
		
		_this = ParaUI.CreateUIObject("container", self.name.."tabs_cont_parent", "_mt", 4, top, 4, self.tabheight+self.tabSpacing)
		_this.background="Texture/kidui/explorer/tab_bg.png";
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("container", self.name.."tabs_cont", "_mt", self.tabSpacing, self.tabSpacing, 36, self.tabheight)
		_this.background="Texture/whitedot.png;0 0 0 0";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", self.name.."btn_tab_close", "_rb", -self.tabheight, -self.tabheight, self.tabheight, self.tabheight)
		_this.background="Texture/kidui/explorer/close2.png";
		_this.animstyle = 11;
		_this.onclick=string.format([[;CommonCtrl.explorer.OnCloseWindow("%s");]],self.name);
		_parent:AddChild(_this);
	
		-- open the mapsearch page on first use.
		self:OpenURL("mapsearch");
	else
		if(bShow == nil) then
			bShow = (_this.visible == false);
		end
		_this.visible = bShow;
	end	
	if(_this.visible == true) then
		_this:BringToFront();
	end
	
	if(bShow) then
		KidsUI.PushState({name = self.name, OnEscKey = string.format([[
			local ExpCtl = CommonCtrl.GetControl("%s");
			if(ExpCtl~=nil)then
				ExpCtl:Show(false);
			end
		]],self.name)});
	else
		KidsUI.PopState(self.name);
	end
end

-- get the active window, return nil if no active window.
-- @return winControl(not the UI object), winProperty
function explorer:GetActiveWindow()
	if(self.ActiveWindow~=nil) then
		local winProperty = self.ChildWindows[self.ActiveWindow];
		if(winProperty ~= nil) then
			return CommonCtrl.GetControl(self.ActiveWindow), winProperty;
		end	
	end
end

-- find the active window, return nil if not found.
-- @return winControl(not the UI object), winProperty
function explorer:FindWindow(sWinName)
	if(self.sWinName~=nil) then
		local winProperty = self.ChildWindows[self.sWinName];
		if(winProperty ~= nil) then
			return CommonCtrl.GetControl(self.sWinName), winProperty;
		end
	end
end
		
-- close the given control
function explorer.OnClose(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting explorer instance "..sCtrlName.."\r\n");
		return;
	end
	
	local addressCtl = CommonCtrl.GetControl(self.name.."Address");
	if(addressCtl~=nil)then
		self:SaveURLListToFile(self.UrlSavePath, addressCtl.items);
	end
	
	ParaUI.Destroy(self.name);
end

-- minimize window
function explorer.OnMinimizeWindow(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting explorer instance "..sCtrlName.."\r\n");
		return;
	end
	self:Show();
end

-- toggle window size
function explorer.OnToggleWindowSize(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting explorer instance "..sCtrlName.."\r\n");
		return;
	end
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false) then
		log("error getting explorer instance "..sCtrlName.."\r\n");
	end
	
	if(self.togglesize[self.currentSizeIndex].width == _this.width and self.togglesize[self.currentSizeIndex].height == _this.height) then
		if(self.currentSizeIndex == 1) then
			self.currentSizeIndex = 2;
		else
			self.currentSizeIndex = 1;
		end
	end
	_this.width = self.togglesize[self.currentSizeIndex].width;
	_this.height = self.togglesize[self.currentSizeIndex].height;
	
	self:OnResize();
end

-- get a new unique window name
function explorer:NewWindowName()
	self.NameCount = self.NameCount+1;
	return "untitled"..self.NameCount;
end

-- this function should be called when self.ChildWindow or self.ActiveWindow is changed.
function explorer:RefreshLayout()
	local tabContainer = ParaUI.GetUIObject(self.name.."tabs_cont");
	if(tabContainer:IsValid() == false) then
		log("tabs_cont not found\r\n");
	end
	tabContainer:RemoveAll();
	
	local nIndex = 0;
	local tabwidth = self.tabwidth;
	local tabheight = self.tabheight;
	local tabSpacing = self.tabSpacing;
	
	-- loop through each child window
	local sWindowName, sWindowProperty;
	for sWindowName, sWindowProperty in pairs(self.ChildWindows) do 
		local childWnd = ParaUI.GetUIObject(sWindowName);
		if(childWnd:IsValid() == true) then
			_this = ParaUI.CreateUIObject("button", self.name.."btn_tab"..nIndex, "_lt", nIndex*(tabwidth+tabSpacing), 0, tabwidth, tabheight);
			_this.text = sWindowProperty.title;
			_this.onclick = string.format([[;CommonCtrl.explorer.OnTabBtnClick("%s", "%s");]], self.name, sWindowName);
			if(sWindowName == self.ActiveWindow) then
				-- for active window, highlight and display it
				if(sWindowProperty.title == "mapsearch") then
					_this.background="Texture/kidui/explorer/pagetab_search_selected.png";
				elseif(sWindowProperty.title == "login") then
					_this.background="Texture/kidui/explorer/pagetab_home_selected.png";
				else
					_this.background="Texture/kidui/explorer/pagetab_selected.png";
				end	
				_guihelper.SetUIColor(_this, "255 255 255");
				childWnd.visible = true;
			else
				-- for inactive window, hide it
				if(sWindowProperty.title == "mapsearch") then
					_this.background="Texture/kidui/explorer/pagetab_search.png";
				elseif(sWindowProperty.title == "login") then
					_this.background="Texture/kidui/explorer/pagetab_home.png";
				else
					_this.background="Texture/kidui/explorer/pagetab.png";
				end	
				childWnd.visible = false;
			end	
			tabContainer:AddChild(_this);
			nIndex = nIndex+1;
		else
			-- TODO: close sWindowName	
		end	
	end
end

-- get the number of child windows opened right now.
function explorer:GetChildCount()
	local nCount = 0;
	local sWindowName, sWindowProperty;
	for sWindowName, sWindowProperty in pairs(self.ChildWindows) do 
		nCount = nCount+1;
	end
	return nCount;
end

-- called when the new window is pressed.
-- @param WindowClass: any class derived from explorerWnd
-- @param InitParams: initialization parameters.
-- @return return nil if failed, otherwise the window control is returned. 
function explorer.OnNewWindow(sCtrlName, WindowClass, InitParams)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting explorer instance "..sCtrlName.."\r\n");
		return;
	end

	if(explorer:GetChildCount()>=self.maxChildCount) then
		_guihelper.MessageBox(L"too many windows are opened");
		return;
	end
	
	local sWindowName = self:NewWindowName();
	local parentWnd = ParaUI.GetUIObject(self.name);

	if(not WindowClass) then
		WindowClass = CommonCtrl.explorerWnd;
	end
	
	-- fill default initilization parameters
	if(not InitParams)then InitParams = {} end
	if(not InitParams.name) then InitParams.name = sWindowName end
	if(not InitParams.alignment) then InitParams.alignment = "_fi" end
	if(not InitParams.left) then InitParams.left = 10 end
	if(not InitParams.top) then InitParams.top = 180 end
	if(not InitParams.width) then InitParams.width = 4 end
	if(not InitParams.height) then InitParams.height = 4 end
	if(not InitParams.parent) then InitParams.parent = parentWnd end

	local ctl = WindowClass:new(InitParams);
	ctl:Show();

	-- add to the child windows	
	self.ActiveWindow = InitParams.name;
	self.ChildWindows[self.ActiveWindow] = self.explorerWndProperty:new({title = ctl.title});

	-- refresh
	self:RefreshLayout();
	return ctl;
end

-- called when the close button is clicked. It will close the current explorer child window 
function explorer.OnCloseWindow(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting explorer instance "..sCtrlName.."\r\n");
		return;
	end
	if(self.ActiveWindow~=nil) then
		local childWnd = CommonCtrl.GetControl(self.ActiveWindow);
		if(childWnd~=nil) then
			-- let the child window close itself
			childWnd:OnClose();
		end
		
		-- remove the tab from the tab list.
		self.ChildWindows[self.ActiveWindow] = nil;
		
		-- pick a new active window at random.
		-- loop through each child window
		local sWindowName, sWindowProperty;
		for sWindowName, sWindowProperty in pairs(self.ChildWindows) do 
			local childWnd = ParaUI.GetUIObject(sWindowName);
			if(childWnd:IsValid() == true) then
				self.ActiveWindow = sWindowName;
				break;
			end
		end
		self:RefreshLayout();
	end
end

-- Called when user clicked on the tab
-- @param sCtrlName: explorer control name
-- @param sWindowName: window name that is being clicked
function explorer.OnTabBtnClick(sCtrlName, sWindowName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting explorer instance "..sCtrlName.."\r\n");
		return;
	end
	
	if(self.ActiveWindow ~= sWindowName)then
		self.ActiveWindow = sWindowName;	
		self:RefreshLayout();
	end
end

-- on last page
function explorer.OnLastPage(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting explorer instance "..sCtrlName.."\r\n");
		return;
	end
end	

-- on next page
function explorer.OnNextPage(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting explorer instance "..sCtrlName.."\r\n");
		return;
	end
end	

-- on stop page
function explorer.OnStopPage(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting explorer instance "..sCtrlName.."\r\n");
		return;
	end
	local activeWnd = self:GetActiveWindow();
	if (activeWnd~=nil) then
		activeWnd:OnStop();
	end
end	

-- on refresh page
function explorer.OnRefreshPage(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting explorer instance "..sCtrlName.."\r\n");
		return;
	end
	local activeWnd = self:GetActiveWindow();
	if (activeWnd~=nil) then
		activeWnd:OnRefresh();
	end
end	

-- on search page
function explorer.OnSearchPage(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting explorer instance "..sCtrlName.."\r\n");
		return;
	end
	self:OpenURL("mapsearch");
end	

-- on favourite page
function explorer.OnFavouritePage(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting explorer instance "..sCtrlName.."\r\n");
		return;
	end
end	

-- on home page
function explorer.OnHomePage(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting explorer instance "..sCtrlName.."\r\n");
		return;
	end
	self:OpenURL("login");
end	

-- on history page
function explorer.OnHistoryPage(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting explorer instance "..sCtrlName.."\r\n");
		return;
	end
end	

-- on email page
function explorer.OnEmailPage(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting explorer instance "..sCtrlName.."\r\n");
		return;
	end
end	

-- called when user wants to go to the current URL.
function explorer.OnGotoAddress(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting explorer instance "..sCtrlName.."\r\n");
		return;
	end
	local addressCtl = CommonCtrl.GetControl(self.name.."Address");
	if(addressCtl==nil)then
		log("error getting explorer for "..self.name.."Address".."\r\n");
		return;
	end
	local url = addressCtl:GetText();
	self:OpenURL(url);
end	

-- called when user wants to go to the current URL.
function explorer.OnAddressTextSelected(sCtrlName)
	explorer.OnGotoAddress(sCtrlName);
end	

-- read URL list from a file and return a table containing those URLs.
function explorer:LoadURLListFromFile(sFileName)
	local urls = {};
	local file = ParaIO.open(sFileName, "r");
	if(file:IsValid()) then
		local url;
		local nIndex = 1;
		while(true) do 
			url = file:readline();
			if(url~=nil) then
				urls[nIndex] = url;
				nIndex = nIndex+1;
			else
				break;
			end	
		end
	end	
	file:close();
	return urls;
end
-- write a table containing URLs to a file
function explorer:SaveURLListToFile(sFileName, items)
	local file = ParaIO.open(sFileName, "w");
	local url;
	for _, url in ipairs(items) do
		file:WriteString(url.."\r\n");
	end
	file:close();
end

--[[ get key words from url.
@param url: the URL.
@param titlelength:max length of the title.]]
function explorer.GetTitleFromURL(url, titlelength)
	-- get rid of http:// header
	if(string.find(url, "http://")~=nil) then
		url = string.sub(url, 8);
	end
	local nLength = string.len(url);
	if(nLength<=titlelength) then
		return url;
	else 
		return ".."..string.sub(url, nLength-titlelength+2);
	end
end

--[[ open the given url in window
@param url: see below
	- "local": the local game world is opened
	- "mapsearch": the map search window is opened
]]
function explorer:OpenURL(url)
	-- TODO: open the URL in the given window.
	if(url == "local") then
		
	elseif(url == "mapsearch") then
		-- this is a map search window
		local sWinName = self.name.."mapsearch";
		local childWnd = self:FindWindow(sWinName);
		if(childWnd ~=nil) then
			-- if the map search window is already opened, just bring it to front.
			self.ActiveWindow = sWinName;
			self:RefreshLayout();
			return;
		end
		-- create the map search window, here 
		self.OnNewWindow(self.name, CommonCtrl.MapExplorerWnd, {
			name = sWinName,
			title = L"map",
		});
	elseif(url == "login") then
		-- this is a map search window
		local sWinName = self.name.."login";
		local childWnd = self:FindWindow(sWinName);
		if(childWnd ~=nil) then
			-- if the map search window is already opened, just bring it to front.
			self.ActiveWindow = sWinName;
			self:RefreshLayout();
			return;
		end
		-- create the map search window, here 
		self.OnNewWindow(self.name, CommonCtrl.LoginWnd, {
			name = sWinName,
			title = L"homepage",
		});
	elseif(string.find(url, "http://")~=nil) then
		-- if this is a URL,  it means a personal world. 
		local activeWnd, WndProperty = self:GetActiveWindow();
		if(activeWnd~=nil) then
			if(activeWnd:GetType() == "PersonalWorldExplorerWnd") then
				-- reuse the current window.
				if(WndProperty~=nil) then
					WndProperty.title = self.GetTitleFromURL(url, self.maxtitlelength);
				end
				activeWnd:SetURL(url);
				self:RefreshLayout();
				return
			end
		end
		-- try open a new PersonalWorldExplorerWnd
		local ctl = self.OnNewWindow(self.name, CommonCtrl.PersonalWorldExplorerWnd, {
			title = self.GetTitleFromURL(url, self.maxtitlelength),
		});
		ctl:SetURL(url);
	end
end

--new function add by SunLingfeng 07/6/8
--this function will call all child windows' OnResize() when resize then window
function explorer:OnResize()
	for sWindowName in pairs(self.ChildWindows) do 
		local _this = CommonCtrl.GetControl(sWindowName);
		if( _this ~= nil and _this.OnResize ~= nil)then
			_this:OnResize();
		end
	end
end
	