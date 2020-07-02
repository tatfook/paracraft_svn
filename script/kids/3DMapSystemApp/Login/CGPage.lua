--[[
Title: CG page: displaying paraworld CG movie in a panel or window. 
Author(s): LiXizhi
Date: 2008/1/28
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/Login/CGPage.lua");
Map3DSystem.App.Login.CGPage.ShowWnd(app);
Map3DSystem.App.Login.CGPage.Show(bShow, _parent, parentWindow)
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");

commonlib.setfield("Map3DSystem.App.Login.CGPage", {});

local VideoFilePath = "Texture/3DMapSystem/Startup/paraworldCG_320_240.flv";

-- display the main inventory window for the current user.
function Map3DSystem.App.Login.CGPage.ShowWnd(_app)
	NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
	local _wnd = _app:FindWindow("CGPage") or _app:RegisterWindow("CGPage", nil, Map3DSystem.App.Login.CGPage.MSGProc);
	
	local _appName, _wndName, _document, _frame;
	_frame = Map3DSystem.UI.Windows.GetWindowFrame(_wnd.app.name, _wnd.name);
	if(_frame) then
		_appName = _frame.wnd.app.name;
		_wndName = _frame.wnd.name;
		_document = ParaUI.GetUIObject(_appName.."_".._wndName.."_window_document");
	else
		local param = {
			wnd = _wnd,
			--isUseUI = true,
			icon = "Texture/3DMapSystem/MainBarIcon/Modify.png",
			iconSize = 48,
			text = "ParaWorld CG",
			style = Map3DSystem.UI.Windows.Style[1],
			maximumSizeX = 800,
			maximumSizeY = 650,
			minimumSizeX = 400,
			minimumSizeY = 250,
			isShowIcon = true,
			--opacity = 100, -- [0, 100]
			isShowMaximizeBox = false,
			isShowMinimizeBox = false,
			isShowAutoHideBox = false,
			allowDrag = true,
			allowResize = true,
			initialPosX = 150,
			initialPosY = 100,
			initialWidth = 600,
			initialHeight = 400,
			
			ShowUICallback =Map3DSystem.App.Login.CGPage.Show,
		};
		_appName, _wndName, _document, _frame = Map3DSystem.UI.Windows.RegisterWindowFrame(param);
	end
	Map3DSystem.UI.Windows.ShowWindow(true, _appName, _wndName);
end


--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
-- @param _parent: parent window inside which the content is displayed. it can be nil.
function Map3DSystem.App.Login.CGPage.Show(bShow, _parent, parentWindow)
	local _this;
	Map3DSystem.App.Login.CGPage.parentWindow = parentWindow;
	
	_this=ParaUI.GetUIObject("Login.CGPage_cont");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		
		if(_parent==nil) then
			_this=ParaUI.CreateUIObject("container","Login.CGPage_cont","_lt",100,50, 606, 390);
			_this:AttachToRoot();
		else
			_this = ParaUI.CreateUIObject("container", "Login.CGPage_cont", "_fi",0,0,0,0);
			_this.background = ""
			_parent:AddChild(_this);
		end	
		_parent = _this;
		
		_this = ParaUI.CreateUIObject("button", "video", "_fi", 0, 0, 0, 0);
		CommonCtrl.OneTimeAsset.Add("ParaworldCG", VideoFilePath);
		_this.background = VideoFilePath;
		_guihelper.SetUIColor(_this, "255 255 255");
		_parent:AddChild(_this);

	else
		if(not bShow) then
			Map3DSystem.App.Login.CGPage.OnDestory()
		end
	end	
end

-- destory the control
function Map3DSystem.App.Login.CGPage.OnDestory()
	ParaUI.Destroy("Login.CGPage_cont");
	CommonCtrl.OneTimeAsset.Add("ParaworldCG", nil);
end

function Map3DSystem.App.Login.CGPage.MSGProc(window, msg)
	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		Map3DSystem.UI.Windows.ShowWindow(false, Map3DSystem.App.Login.CGPage.parentWindow.app.name, msg.wndName);
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		
	end
end