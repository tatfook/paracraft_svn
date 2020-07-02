--[[
Title: Painter App wrapper. 
Author(s): LiXizhi
Date: 2008/1/28
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Painter/Painter.lua");
Map3DSystem.App.Painter.PainterAppWnd.ShowWnd(app);
Map3DSystem.App.Painter.PainterAppWnd.Show(bShow, _parent, parentWindow)
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");

NPL.load("(gl)script/kids/3DMapSystemUI/Painter/PainterManager.lua");

commonlib.setfield("Map3DSystem.App.Painter.PainterAppWnd", {});

-- display the main inventory window for the current user.
function Map3DSystem.App.Painter.PainterAppWnd.ShowWnd(_app)
	local _wnd = _app:FindWindow("PainterAppWnd") or _app:RegisterWindow("PainterAppWnd", nil, Map3DSystem.App.Painter.PainterAppWnd.MSGProc);
	
	_wnd:DestroyWindowFrame();
	local _wndFrame = _wnd:GetWindowFrame();
	if(not _wndFrame) then
		_wndFrame = _wnd:CreateWindowFrame{
			icon = "Texture/3DMapSystem/common/color_wheel.png",
			text = "画板",
			initialPosX = 696, 
			initialPosY = 175, 
			initialWidth = 320, -- initial width of the window client area
			initialHeight = 440, -- initial height of the window client area
			allowDrag = true,
			--isShowTitleBar = true, 
			--isShowMinimizeBox = false,
			--allowDrag = false,
			--opacity = 90,
				--style = {
					--window_bg = "Texture/3DMapSystem/Creator/container.png:7 7 7 7",
					--titleBarHeight = 32,
					--iconSize = 24,
					--iconTextDistance = 16, -- distance between icon and text on the title bar
					--CloseBox = {alignment = "_rt",
								--x = -32, y = 0, size = 32,
								--icon = "Texture/3DMapSystem/Creator/close.png",},
					--borderLeft = 8,
					--borderRight = 0,
					--resizerSize = 24,
					--resizer_bg = "",
				--},
			--alignment = "Free", 
			ShowUICallback = Map3DSystem.App.Painter.PainterAppWnd.Show,
		};
	end
	_wnd:ShowWindowFrame(); -- toggle visible. 
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
-- @param _parent: parent window inside which the content is displayed. it can be nil.
function Map3DSystem.App.Painter.PainterAppWnd.Show(bShow,_parent,parentWindow)
	local this;
	local left,top,width,heiht;

	Map3DSystem.App.Painter.PainterAppWnd.parentWindow = parentWindow;

	_this = ParaUI.GetUIObject("Map3DSystem.App.Painter.PainterAppWnd");
	if(_this:IsValid())then
		_this.visible = bShow;
		if( not bShow)then
			Map3DSystem.App.Painter.PainterAppWnd.OnDestroy();
		end
	else
		if( bShow == false)then
			return;
		end
		
		_this = ParaUI.CreateUIObject("container","Map3DSystem.App.Painter.PainterAppWnd","_fi",0,0,0,50);
		if( _parent == nil)then
			_this:AttachToRoot();
		else
			_parent:AddChild(_this);
			_this.background = "";
		end
		local _btn=ParaUI.CreateUIObject("button","b", "_rb",-90, -50, 85, 24);
		_btn.text = "不保存并关闭";
		_btn.onclick = ";Map3DSystem.App.Painter.PainterAppWnd.CloseWindow();";
		_parent:AddChild(_btn);
		
		_parent = _this;
			
		NPL.load("(gl)script/kids/3DMapSystemUI/Painter/PainterManager.lua");
		Map3DSystem.UI.PainterManager.ShowPainter(true,"_lt",0,0, _parent);
	end
end

function Map3DSystem.App.Painter.PainterAppWnd.CloseWindow()
	if(Map3DSystem.App.Painter.PainterAppWnd.parentWindow) then
		Map3DSystem.App.Painter.PainterAppWnd.parentWindow:CloseWindow();
	end
end

function Map3DSystem.App.Painter.PainterAppWnd.OnDestroy()
	Map3DSystem.UI.PainterManager.OnClose()
	ParaUI.Destroy("Map3DSystem.App.Painter.PainterAppWnd");
end

function Map3DSystem.App.Painter.PainterAppWnd.MSGProc(window, msg)
	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		Map3DSystem.App.Painter.PainterAppWnd.OnDestroy()
		window:DestroyWindowFrame();
	end
end
