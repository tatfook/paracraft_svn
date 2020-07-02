--[[
Title: Exposes the main map window to app_main.lua of the map application. 
Author(s): 
Date: 2008/1/24
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppWrapper.lua");
Map3DSystem.App.Map.ShowMapWnd(app);
Map3DSystem.App.Map.MapWnd.Show(bShow,_parent,parentWindow)
-------------------------------------------------------
]]

NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DApp.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppCommon.lua");

-- create class
commonlib.setfield("Map3DSystem.App.Map.MapWnd", {});

-- the map application's container name. 
Map3DSystem.App.Map.MapWnd.name = "map3D";

-- display the main map window
-- @param _app: the map app window object.
function Map3DSystem.App.Map.ShowMapWnd(_app)
	local _wnd = _app:FindWindow("MapWnd") or _app:RegisterWindow("MapWnd", nil, Map3DSystem.App.Map.MapWnd.MSGProc);	
	local _wndFrame = _wnd:GetWindowFrame();
	if(not _wndFrame) then
		_wndFrame = _wnd:CreateWindowFrame{
			icon = "Texture/3DMapSystem/MainBarIcon/Map.png; 0 0 48 48",
			iconSize = 24,
			text = "世界地图",
			maximumSizeX = 1024,
			maximumSizeY = 768,
			minimumSizeX = 420,
			minimumSizeY = 330,
			isShowIcon = true,
			--opacity = 100, -- [0, 100]
			isShowMaximizeBox = true,
			isShowMinimizeBox = true,
			isShowAutoHideBox = true,
			allowDrag = true,
			allowResize = true,
			initialPosX = 70,
			initialPosY = 20,
			initialWidth = 800,
			initialHeight = 600,
			ShowUICallback = Map3DSystem.App.Map.MapWnd.Show,
		};
	end
	_wnd:ShowWindowFrame(true);
end

-- @param bShow: boolean to show or hide. if nil, it will toggle current setting. 
-- @param _parent: parent window inside which the content is displayed. it can be nil.
function Map3DSystem.App.Map.MapWnd.Show(bShow,_parent,parentWindow)
	Map3DSystem.App.Map.MapWnd.parentWindow = parentWindow;
	
	local _this = CommonCtrl.GetControl(Map3DSystem.App.Map.MapWnd.name);
	if(_this == nil)then
		if(bShow == false)then
			return;
		end
		--create a new map app if it's not exist yet	
		_this = Map3DApp.MainWnd:new{
			name = Map3DSystem.App.Map.MapWnd.name;
			parent = _parent;
		};
		_this:Show(true);
	else
		if(_parent ~= nil)then
			_this:SetParentWnd(_parent);
		end
		
		_this:Show(bShow);
	end
end

-- Send WM_CLOSE message to the map window.
function Map3DSystem.App.Map.MapWnd.OnClose()
	if(Map3DSystem.App.Map.MapWnd.parentWindow ~= nil)then
		Map3DSystem.App.Map.MapWnd.parentWindow:SendMessage(nil, CommonCtrl.os.MSGTYPE.WM_CLOSE);
	else
		Map3DSystem.App.Map.MapWnd.OnDestroy();
	end
end

function Map3DSystem.App.Map.MapWnd.OnDestroy()
	CommonCtrl.DeleteControl(Map3DSystem.App.Map.MapWnd.name);
end

-- TODO: remove this at release time. 
function Map3DSystem.App.Map.MapWnd.Test()

end

function Map3DSystem.App.Map.MapWnd.MSGProc(window, msg)
	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		window:ShowWindowFrame(false);
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		
	end
end

function Map3DSystem.App.Map.MapWnd.SetMapCenter(dataType,data)
	
end

