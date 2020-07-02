--[[
Title: 
Author(s): Leio
Date: 2007/12/7
Desc: Show the RobotShop window in game UI
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/RobotShop/RobotShop.lua");
------------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

local L = CommonCtrl.Locale("Kids3DMap");
if (not Map3DSystem.UI.RobotShop) then Map3DSystem.UI.RobotShop={}; end;
function Map3DSystem.UI.RobotShop.OnClick()
	
	
	if(not Map3DSystem.UI.RobotShop.IsInitWnd) then 
		-- init window if it has not been done before.
		local _appName, _wndName, _document, _frame;
		_appName, _wndName, _document, _frame = Map3DSystem.UI.RobotShop.InitMainWndObject();
		
		Map3DSystem.UI.RobotShop._appName = _appName;
		--NPL.load("(gl)script/kids/3DMapSystemUI/InGame/PainterWnd.lua");
		--Map3DSystem.UI.PainterWnd.Show(true,  _document, _frame.wnd);
	end
	
	Map3DSystem.UI.RobotShop.IsShow = not Map3DSystem.UI.RobotShop.IsShow;
	if(Map3DSystem.UI.RobotShop.IsShow) then
		Map3DSystem.UI.RobotShop.ShowWnd()
	else
		Map3DSystem.UI.RobotShop.CloseWnd()
	end
	
end


function Map3DSystem.UI.RobotShop.InitMainWndObject()
	if(Map3DSystem.UI.RobotShop.IsInitWnd) then return end
	Map3DSystem.UI.RobotShop.IsInitWnd = true;
	NPL.load("(gl)script/ide/os.lua");
	local _app = CommonCtrl.os.CreateGetApp("RobotShop");
	local _wnd = _app:RegisterWindow("RobotShopMainWnd", nil, Map3DSystem.UI.RobotShop.MSGProc);
	
	Map3DSystem.UI.RobotShop.MainWnd = _wnd;
	
	NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
	local param = {
		wnd = _wnd,
		--isUseUI = true,
		mainBarIconSetID = nil, -- or nil
		icon = "Texture/3dMapSystem/Painter/painter.png; 0 0 48 48",
		iconSize = 48,
		text = "RobotShop", -- naming
		style = Map3DSystem.UI.Windows.Style[1],
		maximumSizeX = 1024,
		maximumSizeY = 768,
		minimumSizeX = 800,
		minimumSizeY = 600,
		isShowIcon = true,
		--opacity = 100, -- [0, 100]
		isShowMaximizeBox = true,
		isShowMinimizeBox = true,
		isShowAutoHideBox = true,
		allowDrag = true,
		allowResize = false,
		initialPosX = 70,
		initialPosY = 20,
		initialWidth = 800,
		initialHeight = 600,
		
		NPL.load("(gl)script/kids/3DMapSystemUI/RobotShop/RobotShopWnd.lua");
		
		ShowUICallback = Map3DSystem.UI.RobotShopWnd.Show,
	};
	NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
	return Map3DSystem.UI.Windows.RegisterWindowFrame(param);
end

function Map3DSystem.UI.RobotShop.ShowWnd()
	NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
	Map3DSystem.UI.Windows.ShowApplication(Map3DSystem.UI.RobotShop._appName);
end

function Map3DSystem.UI.RobotShop.CloseWnd()
	NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
	Map3DSystem.UI.Windows.HideApplication(Map3DSystem.UI.RobotShop._appName);
end

function Map3DSystem.UI.RobotShop.OnMouseEnter()
end

function Map3DSystem.UI.RobotShop.OnMouseLeave()
end

------------------------------------------
-- all map related global messages
------------------------------------------
function Map3DSystem.UI.RobotShop.MSGProc(window, msg)
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		Map3DSystem.UI.RobotShop.CloseWnd();
		Map3DSystem.UI.RobotShop.IsShow = false;
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		Map3DSystem.UI.RobotShop.CloseWnd();
		Map3DSystem.UI.RobotShop.IsShow = false;
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		Map3DSystem.UI.RobotShop.ShowWnd();
		Map3DSystem.UI.RobotShop.IsShow = true;
		
	elseif(msg.type == Map3DSystem.msg.MAP_GOTO) then
		-- TODO by LXZ for SLF
		-- Map3DSystem.msg.MAP_GOTO needs to be defined in NPL.load("(gl)script/kids/3DMapSystemUI/Msg_Def.lua");
	end
end