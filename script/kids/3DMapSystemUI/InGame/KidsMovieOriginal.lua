--[[
Title: KidsMovieOriginal in main bar for 3D Map system
Author(s): WangTian
Date: 2007/9/18
Desc: Show the KidsMovieOriginal window in game UI
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/KidsMovieOriginal.lua");
------------------------------------------------------------
Note: for all main bar function icon:
"(gl)script/kids/3DMapSystemData/TableDef.lua": 
		TableTable defination
"(gl)script/kids/3DMapSystemData/MainBarData.lua": 
		Register the show UI and close UI callback function
]]

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

local L = CommonCtrl.Locale("Kids3DMap");

function Map3DSystem.UI.KidsMovieOriginal.OnClick()
	Map3DSystem.UI.KidsMovieOriginal.IsShow = not Map3DSystem.UI.KidsMovieOriginal.IsShow;
	if(Map3DSystem.UI.KidsMovieOriginal.IsShow) then
		Map3DSystem.UI.KidsMovieOriginal.ShowWnd()
	else
		Map3DSystem.UI.KidsMovieOriginal.CloseWnd()
	end
end

function Map3DSystem.UI.KidsMovieOriginal.ShowWnd()
--
	--local _wnd = ParaUI.GetUIObject("KidsMovieOriginal_window");
	--
	--if(_wnd:IsValid() == false) then
		---- creation sub panel for the first run
		--local _wnd = ParaUI.CreateUIObject("container", "KidsMovieOriginal_window", "_lt", 100, 100, 400, 249);
		--_wnd:AttachToRoot();
		---- test button
		--local _temp = ParaUI.CreateUIObject("button", "testButton", "_lt", 50, 50, 128, 32);
		--_temp.text = "KidsMovieOriginal";
		--_wnd:AddChild(_temp);
	--else
		---- show KidsMovieOriginal window
		--_wnd.visible = true;
	--end
end

function Map3DSystem.UI.KidsMovieOriginal.CloseWnd()
	--
	--local _wnd = ParaUI.GetUIObject("KidsMovieOriginal_window");
	--
	--if(_wnd:IsValid() == false) then
		--log("KidsMovieOriginal window container is not yet initialized.\r\n");
	--else
		---- show creation sub panel
		--_wnd.visible = false;
	--end
end

function Map3DSystem.UI.KidsMovieOriginal.OnClickSubIconSet(subIconIndex)
	log("KidsMovieOriginal(Kids Movie): SubIconIndex:"..subIconIndex.." clicked\r\n");
	
	if(subIconIndex == 1) then
		-- video recorder
		Map3DSystem.UI.KidsMovieOriginal.ShowVideoRecorderWindow();
	elseif(subIconIndex == 2) then
		-- upload works
		KidsUI.OnClickUpload();
	elseif(subIconIndex == 3) then
		-- click ebook
		Map3DSystem.UI.KidsMovieOriginal.ShowEbookWindow();
	elseif(subIconIndex == 4) then
		-- click new world
		Map3DSystem.UI.KidsMovieOriginal.ShowNewWorldWindow();
	elseif(subIconIndex == 5) then
		-- click load world
		Map3DSystem.UI.KidsMovieOriginal.ShowLoadWorldWindow();
	elseif(subIconIndex == 6) then
		-- genious
		KidsUI.OnNetworkPick();
	elseif(subIconIndex == 7) then
		-- tutorial
		Map3DSystem.UI.KidsMovieOriginal.ShowEbookWindow();
	elseif(subIconIndex == 8) then
		-- web browser
		Map3DSystem.UI.KidsMovieOriginal.ShowWebBrowserWindow();
	elseif(subIconIndex == 9) then
		-- back to main startup
		Map3DSystem.reset();
		main_state = nil;
	end
end

function Map3DSystem.UI.KidsMovieOriginal.WebBrowserMSGProc(window, msg)
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		--_guihelper.MessageBox("WebBrowserMSGProc recv WM_CLOSE\n");
		Map3DSystem.UI.Windows.ShowWindow(false, "WebBrowser", "WebBrowserMain");
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		--_guihelper.MessageBox("WebBrowserMSGProc recv WM_SIZE\n");
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_MINIMIZE) then
		--_guihelper.MessageBox("WebBrowserMSGProc recv WM_MINIMIZE\n");
	end
end

function Map3DSystem.UI.KidsMovieOriginal.ShowWebBrowserWindow()
	NPL.load("(gl)script/ide/os.lua");
	local _app = CommonCtrl.os.CreateGetApp("WebBrowser");
	local _wnd = _app:RegisterWindow("WebBrowserMain", nil, Map3DSystem.UI.KidsMovieOriginal.WebBrowserMSGProc);
	
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
			mainBarIconSetID = 17, -- or nil
			icon = "Texture/3DMapSystem/MainBarIcon/SubIcon/WebBrowser.png; 0 0 48 48",
			iconSize = 48,
			text = "ParaWorld WebBrowser",
			style = Map3DSystem.UI.Windows.Style[1],
			maximumSizeX = 800,
			maximumSizeY = 600,
			minimumSizeX = 600,
			minimumSizeY = 500,
			isShowIcon = true,
			--opacity = 100, -- [0, 100]
			isShowMaximizeBox = true,
			isShowMinimizeBox = true,
			isShowAutoHideBox = true,
			allowDrag = true,
			allowResize = true,
			initialPosX = 150,
			initialPosY = 100,
			initialWidth = 800,
			initialHeight = 600,
			
			NPL.load("(gl)script/kids/3DMapSystemUI/InGame/WebBrowser.lua");
			ShowUICallback = Map3DSystem.UI.WebBrowser.Show,
			
		};
		NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
		_appName, _wndName, _document, _frame = Map3DSystem.UI.Windows.RegisterWindowFrame(param);
	end
	
	Map3DSystem.UI.Windows.ShowWindow(true, _appName, _wndName);
	
	--NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Settings.lua");
	--Map3DSystem.UI.Settings.ShowSettings(true, _document, _frame.wnd);
	
	
end


function Map3DSystem.UI.KidsMovieOriginal.MSGProc(window, msg)

	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		--_guihelper.MessageBox("WM_CLOSE\n");
		Map3DSystem.UI.Windows.ShowWindow(false, "KidsMovieOriginal", msg.wndName);
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		_guihelper.MessageBox("WM_SIZE\n");
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_MINIMIZE) then
		_guihelper.MessageBox("WM_MINIMIZE\n");
	end
end

-- added 2007.11.13. LXZ
function Map3DSystem.UI.KidsMovieOriginal.ShowVideoRecorderWindow()
	NPL.load("(gl)script/kids/3DMapSystemUI/Movie/VideoRecorder.lua");
	NPL.load("(gl)script/ide/os.lua");
	local _app = CommonCtrl.os.CreateGetApp("KidsMovieOriginal");
	local _wnd = _app:RegisterWindow("VideoRecorder", nil, Map3DSystem.UI.KidsMovieOriginal.MSGProc);
	
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
			mainBarIconSetID = 17, -- or nil
			icon = "Texture/3DMapSystem/MainBarIcon/SubIcon/Movie.png; 0 0 48 48",
			iconSize = 48,
			text = "视频录像",
			style = Map3DSystem.UI.Windows.Style[1],
			maximumSizeX = 396,
			maximumSizeY = 400,
			minimumSizeX = 396,
			minimumSizeY = 400,
			isShowIcon = true,
			opacity = 70, -- [0, 100]
			isShowMaximizeBox = false,
			isShowMinimizeBox = false,
			isShowAutoHideBox = false,
			allowDrag = true,
			allowResize = false,
			initialPosX = 100,
			initialPosY = 50,
			initialWidth = 400,
			initialHeight = 460,
			
			ShowUICallback = Map3DSystem.Movie.VideoRecorder.Show,
			
		};
		NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
		_appName, _wndName, _document, _frame = Map3DSystem.UI.Windows.RegisterWindowFrame(param);
	end
	
	Map3DSystem.UI.Windows.ShowWindow(true, _appName, _wndName);
end


function Map3DSystem.UI.KidsMovieOriginal.ShowEbookWindow()
	NPL.load("(gl)script/ide/os.lua");
	local _app = CommonCtrl.os.CreateGetApp("KidsMovieOriginal");
	local _wnd = _app:RegisterWindow("EbookWindow", nil, Map3DSystem.UI.KidsMovieOriginal.MSGProc);
	
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
			mainBarIconSetID = 17, -- or nil
			icon = "Texture/3DMapSystem/MainBarIcon/Ebook_2.png",
			iconSize = 48,
			text = "Ebook",
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
			initialPosX = 50,
			initialPosY = 50,
			initialWidth = 800,
			initialHeight = 600,
			
			ShowUICallback = EBook.Show,
			
		};
		NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
		_appName, _wndName, _document, _frame = Map3DSystem.UI.Windows.RegisterWindowFrame(param);
	end
	
	Map3DSystem.UI.Windows.ShowWindow(true, _appName, _wndName);
	
	--NPL.load("(gl)script/kids/3DMapSystemUI/EBook/EBook.lua");
	--EBook.Show(true, _document, _frame.wnd);
end

function Map3DSystem.UI.KidsMovieOriginal.ShowNewWorldWindow()
	NPL.load("(gl)script/ide/os.lua");
	local _app = CommonCtrl.os.CreateGetApp("KidsMovieOriginal");
	local _wnd = _app:RegisterWindow("NewWorldWindow", nil, Map3DSystem.UI.KidsMovieOriginal.MSGProc);
	
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
			mainBarIconSetID = 17, -- or nil
			icon = "Texture/3DMapSystem/MainBarIcon/NewWorld_1.png",
			iconSize = 48,
			text = "New World",
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
			initialPosY = 50,
			initialWidth = 530,
			initialHeight = 590,
			
			NPL.load("(gl)script/kids/3DMapSystemUI/InGame/CreateWorldWnd.lua");
			ShowUICallback = Map3DSystem.UI.CreateWorldWnd.Show,
			
		};
		NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
		_appName, _wndName, _document, _frame = Map3DSystem.UI.Windows.RegisterWindowFrame(param);
	end
	
	Map3DSystem.UI.Windows.ShowWindow(true, _appName, _wndName);
	
	--NPL.load("(gl)script/kids/3DMapSystemUI/InGame/CreateWorldWnd.lua");
	--Map3DSystem.UI.CreateWorldWnd.Show(true, _document, _frame.wnd);
end

function Map3DSystem.UI.KidsMovieOriginal.ShowLoadWorldWindow()
	NPL.load("(gl)script/ide/os.lua");
	local _app = CommonCtrl.os.CreateGetApp("KidsMovieOriginal");
	local _wnd = _app:RegisterWindow("LoadWorldWindow", nil, Map3DSystem.UI.KidsMovieOriginal.MSGProc);
	
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
			mainBarIconSetID = 17, -- or nil
			icon = "Texture/3DMapSystem/MainBarIcon/LoadWorld_1.png",
			iconSize = 48,
			text = "Load World",
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
			initialPosY = 50,
			initialWidth = 530,
			initialHeight = 600,
			
			ShowUICallback = Map3DSystem.UI.LoadWorldWnd.Show,
			
		};
		NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
		_appName, _wndName, _document, _frame = Map3DSystem.UI.Windows.RegisterWindowFrame(param);
	end
	
	Map3DSystem.UI.Windows.ShowWindow(true, _appName, _wndName);
	
	--NPL.load("(gl)script/kids/3DMapSystemUI/InGame/LoadWorldWnd.lua");
	--Map3DSystem.UI.LoadWorldWnd.Show(true, _document, _frame.wnd);
end

Map3DSystem.UI.KidsMovieOriginal.SubIconSet = {
	[1] = {
		Name = "视频录像";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/SubIcon/Movie.png; 0 0 48 48";
		},
	[2] = {
		Name = "上传世界";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/SubIcon/Upload.png; 0 0 48 48";
		},
	[3] = {
		Name = "超级书吧";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/SubIcon/Ebook.png; 0 0 48 48";
		},
	[4] = {
		Name = "新建世界";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/SubIcon/NewWorld.png; 0 0 48 48";
		},
	[5] = {
		Name = "装载世界";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/SubIcon/LoadWorld.png; 0 0 48 48";
		},
	[6] = {
		Name = "天才作品秀";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/SubIcon/Genious.png; 0 0 48 48";
		},
	[7] = {
		Name = "教程";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/SubIcon/Tutorial.png; 0 0 48 48";
		},
	[8] = {
		Name = "浏览器";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/SubIcon/WebBrowser.png; 0 0 48 48";
		},
	[9] = {
		Name = "返回主界面";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/SubIcon/OriginalTreeView.png; 0 0 48 48";
		},
	}

function Map3DSystem.UI.KidsMovieOriginal.OnMouseEnter()
	local index = 17;
	
	if( Map3DSystem.UI.KidsMovieOriginal.SubIconSet ) then
		local _subicon_cont = ParaUI.GetUIObject("KidsMovieOriginal_mouseover_cont");
		if(_subicon_cont:IsValid() == true) then
			--local _mainicon = ParaUI.GetUIObject("MainBar_icons_"..index);
			local _mainicon = Map3DSystem.UI.MainBar.GetItemUIContainer("apps", "Creator.KidsMovieOriginal");
			local x, y = _mainicon:GetAbsPosition();
			_subicon_cont.x = x + Map3DSystem.UI.MainBar.IconSize/2 - 240/2;
			_subicon_cont.y = y - 264;
			_subicon_cont.visible = true;
			_subicon_cont.visible = true;
			return;
		end
		
		local iconNum = 9;
		--local _mainicon = ParaUI.GetUIObject("MainBar_icons_"..index);
		local _mainicon = Map3DSystem.UI.MainBar.GetItemUIContainer("apps", "Creator.KidsMovieOriginal");
		local x, y = _mainicon:GetAbsPosition();
		
		local _sizeX = 64;
		local _sizeY = 72;
		--local _nameHeight = Map3DSystem.UI.MainBar.SubIconNameHeight;
		local _width = 240; -- = Map3DSystem.UI.MainBar.SubIconSize;
		local _height = 264; -- = Map3DSystem.UI.MainBar.SubIconSize * iconNum;
		local pos = {};
		local _matrixCornerX = 20;
		local _matrixCornerY = 20;
		local _matrixIconSizeX = _sizeX;
		local _matrixIconSizeY = _sizeY;
		local _matrixIconGap = 4;
		pos[1] = {_matrixCornerX, _matrixCornerY};
		pos[2] = {_matrixCornerX + (_matrixIconSizeX + _matrixIconGap), _matrixCornerY};
		pos[3] = {_matrixCornerX + (_matrixIconSizeX + _matrixIconGap) * 2, _matrixCornerY};
		pos[4] = {_matrixCornerX, _matrixCornerY + (_matrixIconSizeY + _matrixIconGap)};
		pos[5] = {_matrixCornerX + (_matrixIconSizeX + _matrixIconGap), _matrixCornerY + (_matrixIconSizeY + _matrixIconGap)};
		pos[6] = {_matrixCornerX + (_matrixIconSizeX + _matrixIconGap) * 2, _matrixCornerY + (_matrixIconSizeY + _matrixIconGap)};
		pos[7] = {_matrixCornerX, _matrixCornerY + (_matrixIconSizeY + _matrixIconGap) * 2};
		pos[8] = {_matrixCornerX + (_matrixIconSizeX + _matrixIconGap), _matrixCornerY + (_matrixIconSizeY + _matrixIconGap) * 2};
		pos[9] = {_matrixCornerX + (_matrixIconSizeX + _matrixIconGap) * 2, _matrixCornerY + (_matrixIconSizeY + _matrixIconGap) * 2};
		
		local _posX = x + Map3DSystem.UI.MainBar.IconSize/2 - _width/2;
		local _posY = y - _height;
		
		local _temp_cont = ParaUI.CreateUIObject("container", "KidsMovieOriginal_mouseover_cont", "_lt", 
				_posX, _posY, _width, _height);
				--x, _posY, Map3DSystem.UI.MainBar.IconSize, _height + Map3DSystem.UI.MainBar.IconSize);				
		_temp_cont.background = "Texture/3DMapSystem/CategoryBox/BG.png: 4 4 4 4";
		_temp_cont.onmouseleave = ";Map3DSystem.UI.KidsMovieOriginal.OnMouseLeave();";
		_temp_cont:AttachToRoot();
		
		-- TODO: BUT: if set to "fi", 10, 10, 10, 10) application will crash!
		local _subicon_cont = ParaUI.CreateUIObject("container", "_subicon_cont", "_fi", 0, 0, 0, 0);
				--Map3DSystem.UI.MainBar.IconSize/2 - _width/2, 0, _width, _height);
		_subicon_cont.background = "";
		_temp_cont:AddChild(_subicon_cont);
		
		local _this;
		for i = 1, iconNum do
			_this = ParaUI.CreateUIObject("button", "subicon"..i.."bar", "_lt", pos[i][1], pos[i][2], 64, 72);
			local foreImage = "";
			local backImage = "Texture/3DMapSystem/CategoryBox/TextBar_Back.png; 0 0 32 72 : 11 59 11 11";
			_guihelper.SetVistaStyleButton(_this, foreImage, backImage);
			_subicon_cont:AddChild(_this);
			
			_this = ParaUI.CreateUIObject("button", "subicon"..i, "_lt", pos[i][1] + 8, pos[i][2], 48, 48);
			--_this.tooltip = Map3DSystem.UI.KidsMovieOriginal.SubIconSet[i].Name; -- ToolTip;
			_this.background = Map3DSystem.UI.KidsMovieOriginal.SubIconSet[i].NormalIconPath;
			_this.animstyle = 12;
			_this.onclick = ";Map3DSystem.UI.KidsMovieOriginal.OnClickSubIconSet("..i..");";
			_subicon_cont:AddChild(_this);
			
			_this = ParaUI.CreateUIObject("button", "subicon"..i.."textfield", "_lt", pos[i][1], pos[i][2] + 48, 64, 24);
			_this.background = "";
			_this.text = Map3DSystem.UI.KidsMovieOriginal.SubIconSet[i].Name;
			
			_this:SetCurrentState("highlight");
			_this:GetFont("text").color = "255 255 255";
			_this:SetCurrentState("pressed");
			_this:GetFont("text").color = "255 255 255";
			_this:SetCurrentState("disabled");
			_this:GetFont("text").color = "255 255 255";
			_this:SetCurrentState("normal");
			_this:GetFont("text").color = "255 255 255";
			
			_this.onclick = ";Map3DSystem.UI.KidsMovieOriginal.OnClickSubIconSet("..i..");";
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

-- onmouseleave function to KidsMovieOriginal icon
function Map3DSystem.UI.KidsMovieOriginal.OnMouseLeave()
	local _subicon_cont = ParaUI.GetUIObject("KidsMovieOriginal_mouseover_cont");
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
