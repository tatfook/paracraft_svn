--[[
Title: a MCML browser window
Author(s): LiXizhi
Date: 2008/4/28
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/WebBrowser/MCMLBrowserWnd.lua");
Map3DSystem.App.WebBrowser.MCMLBrowserWnd.ShowWnd();
Map3DSystem.App.WebBrowser.MCMLBrowserWnd.ShowWnd(_app, {url="...", forcerefresh, name, title, zorder, DisplayNavBar, x,y, width, height, icon, iconsize, })
------------------------------------------------------------
]]

-- create
local MCMLBrowserWnd = commonlib.gettable("Map3DSystem.App.WebBrowser.MCMLBrowserWnd");
MCMLBrowserWnd.InitParams = {};

local _defaultApp;
-- display a MCML browser window and goto its url. 
-- @param _app: the host app object or nil to use default internal app
-- @param params: nil or a table containing following field {name, title, url, zorder, DisplayNavBar, x,y, width, height, icon, iconsize, DestroyOnClose=nil}
-- @return the window object.
function MCMLBrowserWnd.ShowWnd(_app, params)
	params = params or {url="", name="MyBrowser", title="My browser", DisplayNavBar = true}
	params.name = params.name or "MCMLBrowserWnd";
	if(params.x == nil) then params.x = 32 end
	if(params.y == nil) then params.y = 32 end
	if(params.width == nil) then params.width = 900 end
	if(params.height == nil) then params.height = 600 end
	if(params.icon == nil) then params.icon = "Texture/3DMapSystem/common/Home.png" end
	if(params.iconsize == nil) then params.iconsize = 16 end
	MCMLBrowserWnd.InitParams[params.name] = commonlib.clone(params);
	
	-- create window
	if(not _app) then
		_defaultApp = _defaultApp or CommonCtrl.os.CreateApp("DefaultMCMLBrowserWndApp");
		_app = _defaultApp;
	end
	local _wnd = _app:FindWindow(params.name) or _app:RegisterWindow(params.name, nil, MCMLBrowserWnd.MSGProc);	
	local _wndFrame = _wnd:GetWindowFrame();
	if(not _wndFrame) then
		_wndFrame = _wnd:CreateWindowFrame{
			icon = params.icon,
			iconSize = params.iconsize,
			text = params.title or params.name,
			maximumSizeX = 1024, -- make this bigger?
			maximumSizeY = 768,
			minimumSizeX = 200,
			minimumSizeY = 100,
			isShowIcon = true,
			isShowMaximizeBox = false,
			isShowMinimizeBox = false,
			isShowAutoHideBox = false,
			allowDrag = true,
			allowResize = false,
			
			
			initialPosX = params.x,
			initialPosY = params.y,
			initialWidth = params.width,
			initialHeight = params.height,
			zorder = params.zorder;
			alignment = nil, -- Free|Left|Right|Bottom
			ShowUICallback = MCMLBrowserWnd.Show,
		};
	else
		if(params.x or params.y or params.width or params.height) then
			_wnd:MoveWindow(params.x, params.y, params.width, params.height)
		end
		if(params.text or params.title) then
			_wnd:SetWindowText(params.text or params.title)
		end	
	end	
	_wnd:ShowWindowFrame(true);
	_wnd.DestroyOnClose = params.DestroyOnClose;
	
	-- goto url if it has changed. 
	local ctl = CommonCtrl.GetControl("MCMLBrowserWnd."..params.name);
	if(ctl) then
		if(params.url) then
			if(ctl:GetUrl() ~= params.url or params.forcerefresh) then
				ctl:Goto(params.url);
			end	
		end
		if(params.DisplayNavBar~=nil) then
			ctl:ShowNavBar(params.DisplayNavBar)
		end
	end	
	
	return _wnd;
end

-- normal windows messages here
function MCMLBrowserWnd.MSGProc(window, msg)
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		local ctl = CommonCtrl.GetControl("MCMLBrowserWnd."..window.name);
		if(ctl) then
			ctl:OnClose(window.DestroyOnClose or msg.bDestroy);
		end
		if(window.DestroyOnClose or msg.bDestroy) then
			window:DestroyWindowFrame();
		else
			window:ShowWindowFrame(false);
		end	
	end
end

function MCMLBrowserWnd.Show(bShow,_parent,parentWindow)
	local windowName
	if(parentWindow) then
		windowName = parentWindow.name;
	end	
	windowName = (windowName or "");
	local params = MCMLBrowserWnd.InitParams[windowName] or {};

	local ctl = CommonCtrl.GetControl("MCMLBrowserWnd."..windowName);
	if(not ctl) then
		NPL.load("(gl)script/kids/3DMapSystemApp/mcml/BrowserWnd.lua");
		ctl = Map3DSystem.mcml.BrowserWnd:new{
			name = "MCMLBrowserWnd."..windowName,
			alignment = "_fi",
			left=0, top=0,
			width = 0,
			height = 0,
			parent = _parent,
			DisplayNavBar = params.DisplayNavBar,
			window = parentWindow,
		};
	else
		ctl.parent = _parent;
	end
	local CreatedUI = ctl:Show(bShow)
end

