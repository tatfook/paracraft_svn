--[[
Title: Exit in main bar for 3D Map system
Author(s): WangTian
Date: 2007/9/18
Desc: Show the Exit window in game UI
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Exit.lua");
------------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

local Exit = {}
commonlib.setfield("Map3DSystem.UI.Exit", Exit)

function Map3DSystem.UI.Exit.OnClick()
	
	--Map3DSystem.UI.Exit.IsShow = not Map3DSystem.UI.Exit.IsShow;
	--if(Map3DSystem.UI.Exit.IsShow) then
		--Map3DSystem.UI.Exit.ShowWnd()
	--else
		--Map3DSystem.UI.Exit.CloseWnd()
	--end
	
	if(mouse_button == "right") then
		local _this = ParaUI.GetUIObject("test_panel");
		_this.visible = not _this.visible;
		_this = ParaUI.GetUIObject("test_itemeditor");
		_this.visible = not _this.visible;
		_this = ParaUI.GetUIObject("main_window");
		_this.visible = not _this.visible;
	end
end

function Map3DSystem.UI.Exit.ShowWnd()

	local _wnd = ParaUI.GetUIObject("Exit_window");
	
	if(_wnd:IsValid() == false) then
		-- creation sub panel for the first run
		local _wnd = ParaUI.CreateUIObject("container", "Exit_window", "_lt", 100, 100, 400, 249);
		_wnd:AttachToRoot();
		-- test button
		local _temp = ParaUI.CreateUIObject("button", "testButton", "_lt", 50, 50, 128, 32);
		_temp.text = "Exit";
		_wnd:AddChild(_temp);
	else
		-- show Exit window
		_wnd.visible = true;
	end
end

function Map3DSystem.UI.Exit.CloseWnd()
	
	local _wnd = ParaUI.GetUIObject("Exit_window");
	
	if(_wnd:IsValid() == false) then
		log("Exit window container is not yet initialized.\r\n");
	else
		-- show creation sub panel
		_wnd.visible = false;
	end
end

-- program exit
function Map3DSystem.UI.Exit.OnExit()
	-- NOTE: call each OnExit function
	-- TODO: add all onexit functions that need data storing or else
	NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Chat.lua");
	Map3DSystem.UI.Chat.OnExit();
	
	ParaGlobal.ExitApp();
end

function Map3DSystem.UI.Exit.OnClickSubIconSet(subIconIndex)
	--log("Exit: SubIconIndex: "..subIconIndex.." clicked\r\n");
	if(subIconIndex == 2) then
		-- click setting window
		Map3DSystem.UI.Exit.ShowSettingWindow();
	elseif(subIconIndex == 3) then
		NPL.load("(gl)script/kids/3DMapSystemUI/InGame/saveworld.lua");
		Map3DSystem.UI.SaveWorldDialog.Show(true)
	elseif(subIconIndex == 4) then
		-- click exit
		_guihelper.MessageBox("确认要退出游戏么?", Map3DSystem.UI.Exit.OnExit);
	end
end


function Map3DSystem.UI.Exit.SettingMSGProc(window, msg)

	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		--_guihelper.MessageBox("WM_CLOSE\n");
		Map3DSystem.UI.Windows.ShowWindow(false, "Exit", msg.wndName);
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		_guihelper.MessageBox("WM_SIZE\n");
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_MINIMIZE) then
		_guihelper.MessageBox("WM_MINIMIZE\n");
	end
end

function Map3DSystem.UI.Exit.ShowSettingWindow()
	NPL.load("(gl)script/ide/os.lua");
	local _app = CommonCtrl.os.CreateGetApp("Exit");
	local _wnd = _app:RegisterWindow("SettingWindow", nil, Map3DSystem.UI.Exit.SettingMSGProc);
	
	NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");

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
			mainBarIconSetID = 19, -- or nil
			icon = "Texture/3DMapSystem/MainBarIcon/Setting_1.png",
			iconSize = 48,
			text = "ParaWorld Setting",
			style = Map3DSystem.UI.Windows.Style[1],
			maximumSizeX = 600,
			maximumSizeY = 600,
			minimumSizeX = 400,
			minimumSizeY = 400,
			isShowIcon = true,
			--opacity = 100, -- [0, 100]
			isShowMaximizeBox = false,
			isShowMinimizeBox = false,
			isShowAutoHideBox = false,
			allowDrag = true,
			allowResize = false,
			initialPosX = 250,
			initialPosY = 100,
			initialWidth = 500,
			initialHeight = 500,
			
			NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Settings.lua");
			ShowUICallback = Map3DSystem.UI.Settings.ShowSettings,
			
		};
		NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
		_appName, _wndName, _document, _frame = Map3DSystem.UI.Windows.RegisterWindowFrame(param);
	end
	
	Map3DSystem.UI.Windows.ShowWindow(true, _appName, _wndName);
	
	--NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Settings.lua");
	--Map3DSystem.UI.Settings.ShowSettings(true, _document, _frame.wnd);
	
	
end

Map3DSystem.UI.Exit.SubIconSet = {
	[1] = {
		Name = "状态";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/SubIcon/Status.png; 0 0 48 48";
		},
	[2] = {
		Name = "设置";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/SubIcon/Setting.png; 0 0 48 48";
		},
	[3] = {
		Name = "保存世界";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/SubIcon/Save.png; 0 0 48 48";
		},
	[4] = {
		Name = "退出";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/SubIcon/Exit.png; 0 0 48 48";
		},
	}
			
function Map3DSystem.UI.Exit.OnMouseEnter()
	local index = 19;
	
	if( Map3DSystem.UI.KidsMovieOriginal.SubIconSet ) then
		local _subicon_cont = ParaUI.GetUIObject("Exit_mouseover_cont");
		if(_subicon_cont:IsValid() == true) then
			--local _mainicon = ParaUI.GetUIObject("MainBar_icons_"..index);
			local _mainicon = Map3DSystem.UI.MainBar.GetItemUIContainer("apps", "Creator.Exit");
			local x, y = _mainicon:GetAbsPosition();
			_subicon_cont.x = x + Map3DSystem.UI.MainBar.IconSize/2 - 172/2;
			_subicon_cont.y = y - 188;
			_subicon_cont.visible = true;
			return;
		end
	
		local iconNum = 4;
		--local _mainicon = ParaUI.GetUIObject("MainBar_icons_"..index);
		local _mainicon = Map3DSystem.UI.MainBar.GetItemUIContainer("apps", "Creator.Exit");
		local x, y = _mainicon:GetAbsPosition();
		
		local _sizeX = 64;
		local _sizeY = 72;
		--local _nameHeight = Map3DSystem.UI.MainBar.SubIconNameHeight;
		local _width = 172; -- = Map3DSystem.UI.MainBar.SubIconSize;
		local _height = 188; -- = Map3DSystem.UI.MainBar.SubIconSize * iconNum;
		local pos = {};
		local _matrixCornerX = 20;
		local _matrixCornerY = 20;
		local _matrixIconSizeX = _sizeX;
		local _matrixIconSizeY = _sizeY;
		local _matrixIconGap = 4;
		pos[1] = {_matrixCornerX, _matrixCornerY};
		pos[2] = {_matrixCornerX + (_matrixIconSizeX + _matrixIconGap), _matrixCornerY};
		pos[3] = {_matrixCornerX, _matrixCornerY + (_matrixIconSizeY + _matrixIconGap)};
		pos[4] = {_matrixCornerX + (_matrixIconSizeX + _matrixIconGap), _matrixCornerY + (_matrixIconSizeY + _matrixIconGap)};
		
		local _posX = x + Map3DSystem.UI.MainBar.IconSize/2 - _width/2;
		local _posY = y - _height;
		
		local _temp_cont = ParaUI.CreateUIObject("container", "Exit_mouseover_cont", "_lt", 
				_posX, _posY, _width, _height);
				--x, _posY, Map3DSystem.UI.MainBar.IconSize, _height + Map3DSystem.UI.MainBar.IconSize);
		_temp_cont.background = "Texture/3DMapSystem/CategoryBox/BG.png: 4 4 4 4";
		_temp_cont.onmouseleave = ";Map3DSystem.UI.Exit.OnMouseLeave();";
		_temp_cont:AttachToRoot();
		
		-- TODO: BUT: if set to "fi", 10, 10, 10, 10) application will crash!
		local _subicon_cont = ParaUI.CreateUIObject("container", "_subicon_cont", "_fi", 0, 0, 0, 0);
				--Map3DSystem.UI.MainBar.IconSize/2 - _width/2, 0, _width, _height);
		_subicon_cont.background = "";
		_temp_cont:AddChild(_subicon_cont);
		
		local _this;
		for i = 1, iconNum do
			_this = ParaUI.CreateUIObject("button", "subicon"..i.."bar", "_lt", pos[i][1], pos[i][2], 64, 72);
			--_this.tooltip = Map3DSystem.UI.Exit.SubIconSet[i].Name; -- ToolTip;
			--_this.background = Map3DSystem.UI.Exit.SubIconSet[i].NormalIconPath;
			
			--local foreImage = "Texture/3DMapSystem/CategoryBox/TextBar_Normal.png; 0 0 32 72 : 11 59 11 11";
			--local backImage = "Texture/3DMapSystem/CategoryBox/TextBar_Highlight.png; 0 0 32 72 : 11 59 11 11";
			local foreImage = "";
			local backImage = "Texture/3DMapSystem/CategoryBox/TextBar_Back.png; 0 0 32 72 : 11 59 11 11";
			_guihelper.SetVistaStyleButton(_this, foreImage, backImage);
			_subicon_cont:AddChild(_this);
			
			_this = ParaUI.CreateUIObject("button", "subicon"..i, "_lt", pos[i][1] + 8, pos[i][2], 48, 48);
			--_this.tooltip = Map3DSystem.UI.Exit.SubIconSet[i].Name; -- ToolTip;
			_this.background = Map3DSystem.UI.Exit.SubIconSet[i].NormalIconPath;
			_this.animstyle = 12;
			_this.onclick = ";Map3DSystem.UI.Exit.OnClickSubIconSet("..i..");";
			_subicon_cont:AddChild(_this);
			
			_this = ParaUI.CreateUIObject("button", "subicon"..i.."textfield", "_lt", pos[i][1], pos[i][2] + 48, 64, 24);
			_this.background = "";
			_this.text = Map3DSystem.UI.Exit.SubIconSet[i].Name;
			
			_this:SetCurrentState("highlight");
			_this:GetFont("text").color = "255 255 255";
			_this:SetCurrentState("pressed");
			_this:GetFont("text").color = "255 255 255";
			_this:SetCurrentState("disabled");
			_this:GetFont("text").color = "255 255 255";
			_this:SetCurrentState("normal");
			_this:GetFont("text").color = "255 255 255";
			
			_this.onclick = ";Map3DSystem.UI.Exit.OnClickSubIconSet("..i..");";
			_subicon_cont:AddChild(_this);
			
			--local _this = ParaUI.CreateUIObject("text", "widthTester", "_lt", 0, 0, 200, 50);
			--_this.visible = false;
			--_this.text = _iconSet[index].SubIconSet[i].Name;
			--local width, height = _this:GetTextLineSize();
			--_subicon_cont:AddChild(_this);
			--
			--width = width + Map3DSystem.UI.MainBar.SubIconNameSideWidth * 2;
			--local x = width + Map3DSystem.UI.MainBar.SubIconNameWidthToSubIcon;
			----_this:GetTextLineSize();
			--
			--_this = ParaUI.CreateUIObject("button", "subicon"..i, "_lt", 
					---x, _size*(i-1) + (_size - _nameHeight)/2, width, _nameHeight);
			--_this:SetText(_iconSet[index].SubIconSet[i].Name, "255 255 255", "");
			--_this.background = Map3DSystem.UI.MainBar.SubIconNameBG..": 2 2 2 2";
			--_subicon_cont:AddChild(_this);
		end
	end
end

-- onmouseleave function to Exit icon
function Map3DSystem.UI.Exit.OnMouseLeave()
	local _subicon_cont = ParaUI.GetUIObject("Exit_mouseover_cont");
	local x, y, width, height = _subicon_cont:GetAbsPosition();
	local mouseX, mouseY = ParaUI.GetMousePosition();
	if(mouseX >= x and mouseY >= y) then
		if( (mouseX <= x + width) and (mouseY <= y + height) ) then
			return;
		end
	end
	
	if(_subicon_cont:IsValid() == true) then
		_subicon_cont.visible = false;
	end
end
