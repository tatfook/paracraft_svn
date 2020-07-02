--[[
Title: Desktop Local map for Aries App
Author(s): WangTian
Date: 2009/4/7
Desc: imported from Aquarius project
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Map/LocalMap.lua");
local LocalMap = commonlib.gettable("MyCompany.Aries.Desktop.LocalMap");
MyCompany.Aries.Desktop.LocalMap.Init()
MyCompany.Aries.Desktop.LocalMap.ShowWorldMap();
------------------------------------------------------------
]]
-- create class
local LocalMap = commonlib.gettable("MyCompany.Aries.Desktop.LocalMap");
local Dock = commonlib.gettable("MyCompany.Aries.Desktop.Dock");

-- invoked at Desktop.InitDesktop()
function LocalMap.Init()
	if(System.options.version=="teen") then
		NPL.load("(gl)script/apps/Aries/Map/LocalMap.teen.lua");
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
			if(ParaIO.DoesFileExist("Texture/Aries/Desktop/Minimap_AvatarArrow_32bits.png", true) == true) then
				size = 32;
				arrowFile = "Texture/Aries/Desktop/Minimap_AvatarArrow_32bits.png";
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

function LocalMap.ShowWorldMap()
	if(System.options.version=="kids") then
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "config/Aries/WorldMaps/WorldMap.html", 
			name = "Aries.LocalMapMCML.worldmap", 
			app_key = MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 3,
			allowDrag = false,
			bToggleShowHide = true,
			enable_esc_key = true,
			directPosition = true,
				align = "_ct",
				x = -878/2,
				y = -510/2,
				width = 878,
				height = 510,
		});
	else
		-- teen version has buildin worldmap. 
		LocalMap.Show("all_worlds");
	end
end

-- show the local map window
-- please note that only a returnable world can have a local map. 
-- when a user is inside a non-returnable world, we will display map of the last returnable world. 
-- @param tabName: default to nil. it can be "all_worlds", where the global map will be shown instead. 
function LocalMap.Show(tabName)
	local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
	
	-- local url = world_info.worldpath.."/LocalMap.html";
	local url;
	if(System.options.version=="kids") then
		url = WorldManager:GetCurrentWorld().local_map_url or WorldManager:GetReturnWorld().local_map_url;
		if(url) then
			LOG.std("", "info", "LocalMap", "%s is openning", url);
			System.App.Commands.Call("File.MCMLWindowFrame", {
				-- TODO:  Add uid to url
				url = url, 
				name = "Aries.LocalMapMCML", 
				app_key = MyCompany.Aries.app.app_key, 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				style = CommonCtrl.WindowFrame.ContainerStyle,
				zorder = 2,
				allowDrag = false,
				bToggleShowHide = true,
				enable_esc_key = true,
				directPosition = true,
					align = "_ct",
					x = -878/2,
					y = -510/2,
					width = 878,
					height = 510,
			});
		else
			_guihelper.Message("It does not have a local map for this world")
			LOG.std("", "warn", "LocalMap", "No local map found for the current world");
		end
	else
		NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
		local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
		local world_info = WorldManager:GetCurrentWorld()
		if(not world_info.local_map_settings)then
			LOG.std(nil, "debug", "LocalMap", "local map setting not available for :%s", tostring(world_info.name));
		end
		local bIsSameWorld;
		if(LocalMap.last_world_name~= world_info.name) then
			-- refresh the page if world name is different
			if(LocalMap.last_world_name) then
				Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name = "Aries.LocalMapMCML", app_key=MyCompany.Aries.app.app_key, bShow = false, bDestroy = true,});
			end
			LocalMap.last_world_name = world_info.name;
		else
			bIsSameWorld = true;
		end

		url = "script/apps/Aries/Map/LocalMap.teen.html?tab="..(tabName or "");
		local params = {
			-- TODO:  Add uid to url
			url = url, 
			name = "Aries.LocalMapMCML", 
			app_key = MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			-- DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 2,
			allowDrag = true,
			bToggleShowHide = true,
			enable_esc_key = true,
			directPosition = true,
				align = "_ct",
				x = -768/2,
				y = -558/2,
				width = 768,
				height = 558,
		}
		System.App.Commands.Call("File.MCMLWindowFrame", params);
		if(params._page and bIsSameWorld) then
			--if(params._page:GetValue("map_tabs") == "all_worlds") then
				params._page:Refresh(0);
			--end
		end
		
		if(params._page and Dock.OnClose) then
			params._page.OnClose = function(bDestroy)
				Dock.OnClose("Aries.LocalMapMCML")
			end
		end
		LocalMap.ShowNodeInMapArea();
	end
end

function LocalMap.Hide()
	System.App.Commands.Call("File.MCMLWindowFrame", {
		name = "Aries.LocalMapMCML", 
		app_key = MyCompany.Aries.app.app_key, 
		bShow = false,
	});
end

-- update the world name after world load
function LocalMap.UpdateWorldName()
	-- init window object
	local _app = MyCompany.Aries.app._app;
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
		local _app = MyCompany.Aries.app._app;
		local _wnd = _app:FindWindow("LocalMap");
		if(_wnd ~= nil) then
			_wnd:ShowWindowFrame(false);
		end
	end
end

-- virtual public API
-- @param name: the point name string
-- @param point: {x,y,text,rotation, tooltip, school, width, height, background,zorder }. if nil, it will clear the given point. 
-- @param bRefreshImmediate: true to refresh immediately. 
function LocalMap.ShowPoint(name, point, bRefreshImmediate)
end