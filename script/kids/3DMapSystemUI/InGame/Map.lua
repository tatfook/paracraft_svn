--[[
Title: Map for 3D Map system, it also contains map related message handlers.
App name is "Map"
Author(s): WangTian
Date: 2007/9/18
Revised: 2007/11/3 By LiXizhi (comments)
Desc: Show the Map window in game UI
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Map.lua");
------------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

local L = CommonCtrl.Locale("Kids3DMap");

function Map3DSystem.UI.Map.OnClick()
	if(not Map3DSystem.UI.Map.IsInitWnd) then 
		-- init window if it has not been done before.
		local _appName, _wndName, _document, _frame;
		_appName, _wndName, _document, _frame = Map3DSystem.UI.Map.InitMainWndObject();
		
		Map3DSystem.UI.Map._appName = _appName;
		
		-- TODO: the current window logic needs to be improved 
		--NPL.load("(gl)script/kids/3DMapSystemUI/Map/MapMainWnd.lua");
		--Map3DSystem.UI.MapMainWnd.Show(true,  _document, _frame.wnd);
	end
	
	Map3DSystem.UI.Map.IsShow = not Map3DSystem.UI.Map.IsShow;
	if(Map3DSystem.UI.Map.IsShow) then
		Map3DSystem.UI.Map.ShowWnd()
	else
		Map3DSystem.UI.Map.CloseWnd()
	end
end

-- init the main window object
-- including:
--		1. create main window "MainWindow" to app "Chat"
--		2. register window frame for "MainWindow"
function Map3DSystem.UI.Map.InitMainWndObject()
	if(Map3DSystem.UI.Map.IsInitWnd) then return end
	Map3DSystem.UI.Map.IsInitWnd = true;
	NPL.load("(gl)script/ide/os.lua");
	local _app = CommonCtrl.os.CreateGetApp("Map");
	local _wnd = _app:RegisterWindow("MapMainWnd", nil, Map3DSystem.UI.Map.MSGProc);
	
	Map3DSystem.UI.Map.MainWnd = _wnd;
	
	NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
	local param = {
		wnd = _wnd,
		--isUseUI = true,
		mainBarIconSetID = 14, -- or nil
		icon = Map3DSystem.UI.MainBar.IconSet[14].NormalIconPath,
		iconSize = 48,
		text = "World Map", -- naming
		style = Map3DSystem.UI.Windows.Style[1],
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
		
		NPL.load("(gl)script/kids/3DMapSystemUI/Map/Map3DAppWrapper.lua");
		ShowUICallback = Map3DSystem.App.Map.MapWnd.Show,
	};
	NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
	return Map3DSystem.UI.Windows.RegisterWindowFrame(param);
end

function Map3DSystem.UI.Map.ShowWnd()
	NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
	Map3DSystem.UI.Windows.ShowApplication(Map3DSystem.UI.Map._appName);
end

function Map3DSystem.UI.Map.CloseWnd()
	NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
	Map3DSystem.UI.Windows.HideApplication(Map3DSystem.UI.Map._appName);
end

function Map3DSystem.UI.Map.OnMouseEnter()
end

function Map3DSystem.UI.Map.OnMouseLeave()
end

------------------------------------------
-- all map related global messages
------------------------------------------
function Map3DSystem.UI.Map.MSGProc(window, msg)
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		Map3DSystem.UI.Map.CloseWnd();
		Map3DSystem.UI.Map.IsShow = false;
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		Map3DSystem.UI.Map.CloseWnd();
		Map3DSystem.UI.Map.IsShow = false;
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		Map3DSystem.UI.Map.ShowWnd();
		Map3DSystem.UI.Map.IsShow = true;
		
	elseif(msg.type == Map3DSystem.msg.MAP_GOTO) then
		-- TODO by LXZ for SLF
		-- Map3DSystem.msg.MAP_GOTO needs to be defined in NPL.load("(gl)script/kids/3DMapSystemUI/Msg_Def.lua");
	end
end