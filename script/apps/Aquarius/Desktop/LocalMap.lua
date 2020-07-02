--[[
Title: Desktop Local map for Aquarius App
Author(s): WangTian
Date: 2008/12/31
Desc:
 changed by LiXizhi: 2009.1.10. fixed a bug when map is not updated when world is changed. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aquarius/Desktop/LocalMap.lua");
MyCompany.Aquarius.Desktop.LocalMap.InitLocalMap()
------------------------------------------------------------
]]

-- create class
local libName = "AquariusDesktopLocalMap";
local LocalMap = {};
commonlib.setfield("MyCompany.Aquarius.Desktop.LocalMap", LocalMap);


-- invoked at Desktop.InitDesktop()
function LocalMap.InitLocalMap()
	
	-- init window object
	local _app = MyCompany.Aquarius.app._app;
	local _wnd = _app:FindWindow("LocalMap") or _app:RegisterWindow("LocalMap", nil, LocalMap.MSGProc);
	
	NPL.load("(gl)script/ide/WindowFrame.lua");
	
	local sampleWindowsParam = {
		wnd = _wnd, -- a CommonCtrl.os.window object
		
		text = "LocalWorldMap",
		
		isShowTitleBar = true, -- default show title bar
		isShowToolboxBar = false, -- default hide title bar
		isShowStatusBar = false, -- default show status bar
		
		initialWidth = 300, -- initial width of the window client area
		initialHeight = 400, -- initial height of the window client area
		
		initialPosX = 50,
		initialPosY = 150,
		directPosition = true,
			align = "_ct",
			x = -512/2,
			y = -600/2,
			width = 512 + 2,
			height = 512 + 16 + 36,
			bAutoSize=true,
		
		isPinned = true,
		
		maxWidth = 600,
		maxHeight = 600,
		minWidth = 300,
		minHeight = 300,
		
		style = CommonCtrl.WindowFrame.DefaultStyle,
		
		alignment = "Free", -- Free|Left|Right|Bottom
		
		ShowUICallback = function (bShow, _parent)
			-- changed by LiXizhi: 2009.1.10. fix a bug when map is not updated when world is changed. 
			Map3DSystem.UI.MiniMapWnd.OnLoadMiniMap = LocalMap.OnLoadMiniMap;
			Map3DSystem.UI.MiniMapWnd.OnUpdateMark = LocalMap.OnUpdateMark;
			
			LocalMap.UpdateWorldName();
			
			if(_parent:IsValid() == true) then
				local _localMap = ParaUI.GetUIObject("LocalMapCanvas");
				if(_localMap:IsValid()==false) then
					_localMap = ParaUI.CreateUIObject("container", "LocalMapCanvas", "_ct", -256, -256, 512, 512);
					_parent:AddChild(_localMap);
				end	
				LocalMap.minimap_filePath = Map3DSystem.UI.MiniMapWnd.minimap_filePath;
				if(LocalMap.minimap_filePath) then
					_localMap.background = LocalMap.minimap_filePath;
				end	
			end
		end,
	};
	
	--local text, icon, shortText = self:GetTextAndIcon();
	--sampleWindowsParam.text = text;
	----sampleWindowsParam.icon = icon;
	
	local frame = CommonCtrl.WindowFrame:new2(sampleWindowsParam);
	--frame:Show2(true, nil, true);
end

-- callback handler of MiniMapWnd.OnLoadMiniMap
function LocalMap.OnLoadMiniMap(MiniMapWnd)
	LocalMap.minimap_filePath = MiniMapWnd.minimap_filePath;
	local _localmapcanvas = ParaUI.GetUIObject("LocalMapCanvas");
	if(_localmapcanvas:IsValid() == true) then
		if(LocalMap.minimap_filePath) then
			_localmapcanvas.background = LocalMap.minimap_filePath;
		end
		LocalMap.UpdateWorldName();
	end
end

-- callback handler of MiniMapWnd.OnUpdateMark
-- @param MiniMapWnd: the Map3DSystem.UI.MiniMapWnd object. 
-- @param angle: character angle
function LocalMap.OnUpdateMark(MiniMapWnd, angle)
	local _localmapcanvas = ParaUI.GetUIObject("LocalMapCanvas");
	if(_localmapcanvas:IsValid() == true) then
		local _avatar = _localmapcanvas:GetChild("avatar");
		local size = 16;
		if(_avatar:IsValid() == false) then
			local arrowFile = "Texture/3DMapSystem/common/arrow_up.png";
			if(ParaIO.DoesFileExist("Texture/Aquarius/Desktop/Minimap_AvatarArrow_32bits.png", true) == true) then
				size = 32;
				arrowFile = "Texture/Aquarius/Desktop/Minimap_AvatarArrow_32bits.png";
			end
			-- using 2D UI for avatar and camera display, added by LiXizhi 2008.6.29
			_avatar = ParaUI.CreateUIObject("button", "avatar", "_lt", -size/2, -size/2, size, size);
			_avatar.background = arrowFile;
			_avatar.enabled = false;
			_guihelper.SetUIColor(_avatar, "255 255 255");
			_localmapcanvas:AddChild(_avatar);
		end
		_avatar.rotation = 1.57+angle-MiniMapWnd.mapRotation;
		
		local _, __, width, height = _localmapcanvas:GetAbsPosition();
		local x, y, z = ParaScene.GetPlayer():GetPosition();
		
		-- NOTE by andy: strange problem the avatar position is slightly different from the position in minimap3d
		-- TODO: check the position calculation
		_avatar.translationx = (x - MiniMapWnd.minimap_x) / MiniMapWnd.minimap_size * width;
		_avatar.translationy = height - ((z - MiniMapWnd.minimap_y) / MiniMapWnd.minimap_size * height);
		
		_avatar:BringToFront();
	end
end

-- shot the window
function LocalMap.Show()
	-- init window object
	local _app = MyCompany.Aquarius.app._app;
	local _wnd = _app:FindWindow("LocalMap");
	if(_wnd ~= nil) then
		_wnd:ShowWindowFrame();
	end
end

-- update the world name after world load
function LocalMap.UpdateWorldName()
	-- init window object
	local _app = MyCompany.Aquarius.app._app;
	local _wnd = _app:FindWindow("LocalMap")
	if(_wnd ~= nil) then
		local worldpath = ParaWorld.GetWorldDirectory();
		if(string.sub(worldpath, -1, -1) == "/") then
			-- remove the additional /
			worldpath = string.sub(worldpath, 1, -2)
		end
		local worldName = ParaIO.GetFileName(worldpath);
		local _frame = _wnd:GetWindowFrame();
		if(_frame ~= nil) then
			_frame:SetText(worldName);
		end
	end
end

function LocalMap.MSGProc(window, msg)
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		local _app = MyCompany.Aquarius.app._app;
		local _wnd = _app:FindWindow("LocalMap");
		if(_wnd ~= nil) then
			_wnd:ShowWindowFrame(false);
		end
	end
end