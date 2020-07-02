--[[
Title: Main bar panel for 3D Map system
Author(s): WangTian
Date: 2007/9/28
Desc: Show the main bar panel in game UI
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/MainPanel.lua");
Map3DSystem.UI.MainPanel.InitUI();
------------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

local L = CommonCtrl.Locale("Kids3DMap");

-- init message system: call this function at main bar initialization to init the message system for main panel
function Map3DSystem.UI.MainPanel.InitMessageSystem()
	NPL.load("(gl)script/ide/os.lua");
	local _app = CommonCtrl.os.CreateGetApp("MainPanel");
	Map3DSystem.UI.MainPanel.App = _app;
	local _mainWndName = "MainPanelWnd";
	local _wnd = _app:RegisterWindow(_mainWndName, nil, Map3DSystem.UI.MainPanel.MSGProc);
	Map3DSystem.UI.MainPanel.MainWnd = _wnd;
	
	-- init the sub panel message system
	-- TODO: init more message system, currently only creation and modify panels
	Map3DSystem.UI.Creation.InitMessageSystem(_app, _mainWndName);
	Map3DSystem.UI.Modify.InitMessageSystem(_app, _mainWndName);
	Map3DSystem.UI.Delete.InitMessageSystem(_app, _mainWndName);
	Map3DSystem.UI.Property.InitMessageSystem(_app, _mainWndName);
	Map3DSystem.UI.Possession.InitMessageSystem(_app, _mainWndName);
	Map3DSystem.UI.Sky.InitMessageSystem(_app, _mainWndName);
	Map3DSystem.UI.Water.InitMessageSystem(_app, _mainWndName);
	Map3DSystem.UI.Terrain.InitMessageSystem(_app, _mainWndName);
end

-- send a message to MainPanel:MainPanelWnd window handler
-- e.g. Map3DSystem.UI.MainPanel.SendMeMessage({type = Map3DSystem.msg.MAINPANEL_Show})
function Map3DSystem.UI.MainPanel.SendMeMessage(msg)
	msg.wndName = Map3DSystem.UI.MainPanel.MainWnd.name;
	Map3DSystem.UI.MainPanel.App:SendMessage(msg);
end

-- send a message to all window handler in "main panel" application
-- e.g. Map3DSystem.UI.MainPanel.SendMeMessage({type = Map3DSystem.msg.MAINPANEL_Show})
function Map3DSystem.UI.MainPanel.SendMeMessageToAllWnd(msg)
	msg.wndName = "*";
	Map3DSystem.UI.MainPanel.App:SendMessage(msg);
end

-- main panel: mainpanel window handler
function Map3DSystem.UI.MainPanel.MSGProc(window, msg)
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		-- Do your code
		--_guihelper.MessageBox("MainPanel recv MSG WM_CLOSE.\n");
		Map3DSystem.UI.MainPanel.ClosePanel();
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		-- Do your code
		--_guihelper.MessageBox("MainPanel recv MSG WM_SIZE.\n");
		Map3DSystem.UI.MainPanel.OnResize();
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_MINIMIZE) then
		-- Do your code
		--_guihelper.MessageBox("MainPanel recv MSG WM_MINIMIZE.\n");
		Map3DSystem.UI.MainPanel.MinimizePanel();
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_MAXIMIZE) then
		-- Do your code
		--_guihelper.MessageBox("MainPanel recv MSG WM_MAXIMIZE.\n");
		Map3DSystem.UI.MainPanel.MaximizePanel();
	elseif(msg.type == Map3DSystem.msg.MAINPANEL_SetPosX) then
		-- set the panel x position
		--_guihelper.MessageBox("MainPanel recv MSG MAINPANEL_SetPosX.\n");
		Map3DSystem.UI.MainPanel.SetPanelPosX(msg.posX);
	elseif(msg.type == Map3DSystem.msg.MAINPANEL_ClickIcon) then
		-- main bar icon onclick
		Map3DSystem.UI.MainPanel.OnClickIcon(msg.index);
	elseif(msg.type == Map3DSystem.msg.MAINPANEL_AutoHide) then
		-- autohide panel
		--_guihelper.MessageBox("MainPanel recv MSG MAINPANEL_AutoHide.\n");
		-- bAutoHiding = true or false, nil toggle current setting
		Map3DSystem.UI.MainPanel.AutoHidePanel(msg.bAutoHiding);
		
	elseif(msg.type == Map3DSystem.msg.MAINPANEL_ShowDefault) then
		-- show default panel according to the selected object
		Map3DSystem.UI.MainPanel.ShowDefault();
		
	--elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		-- Do your code
		-- TODO: recieve resolution change message
		--Map3DSystem.UI.MainPanel.SendMeMessage(
		--{
			--type = Map3DSystem.msg.MAINPANEL_SetPosX,
			--posX = 20,
		--});
	end
end

-- initiate the main bar panel, one time initiate
function Map3DSystem.UI.MainPanel.InitUI()
	
	local _panel = ParaUI.GetUIObject("MainBar_panel");
	local _this;
	if(_panel:IsValid() == false) then
		Map3DSystem.UI.MainPanel.InitPanelUI();
		Map3DSystem.UI.Creation.InitUI();
	else
		_panel.visible = false;
		log("call function Map3DSystem.UI.MainBar.InitPanel by mistake.\r\nMainBar Panel is one time initiate.\r\n");
	end	-- if(_panel:IsValid() == false) then
	
end

-- initiate the main panel UI
-- including: main panel frame, category icon(same as the main bar icon),
--			min, max, toggle autohide and close button
--			right alignment resizer
function Map3DSystem.UI.MainPanel.InitPanelUI()

	local _panel = ParaUI.GetUIObject("MainBar_panel");
	local _this;
	if(_panel:IsValid() == false) then
		_panel = ParaUI.CreateUIObject("container", "MainBar_panel", "_lb", 
			0, 
			- Map3DSystem.UI.MainBar.IconHeightOffset - Map3DSystem.UI.MainBar.IconSize - Map3DSystem.UI.MainPanel.PanelBGHeight,
			Map3DSystem.UI.MainPanel.PanelBGWidth, Map3DSystem.UI.MainPanel.PanelBGHeight);
		--_panel.background = "Texture/3DMapSystem/WindowFrameStyle/1/frame.png: 4 25 4 24";
		_panel.background = "";
		_panel:AttachToRoot();
		_panel.onmouseenter = ";Map3DSystem.UI.MainPanel.OnMouseEnter();";
		_panel.onmouseleave = ";Map3DSystem.UI.MainPanel.OnMouseLeave();";
		_panel.visible = false;
		
		-- spit the panel background to upper and lower part for autohide operation
		local _this = ParaUI.CreateUIObject("container", "MainBar_panel_upper", "_mt", 0, 0, 0, 24);
		--_this.background = "Texture/3DMapSystem/WindowFrameStyle/1/frame.png; 0 0 64 32: 4 24 4 0";
		_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/container_bg.png; 0 0 32 16: 12 12 12 1";
		_this.enable = false;
		_panel:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("container", "MainBar_panel_lower", "_fi", 0, 24, 0, 0);
		--_this.background = "Texture/3DMapSystem/WindowFrameStyle/1/framemid.png: 4 0 4 0";
		_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/container_bg.png; 0 16 0 0: 4 0 4 24";
		_this.enable = false;
		_panel:AddChild(_this);
		
		-- this container is the bottom most part of the main panel always displayed behind the main bar(icons)
		_panel_behind = ParaUI.CreateUIObject("container", "MainBar_panel_behindMainBarIcons", "_lb", 
			200, 
			- Map3DSystem.UI.MainBar.IconHeightOffset - Map3DSystem.UI.MainBar.IconSize, 
			Map3DSystem.UI.MainPanel.PanelBGWidth, Map3DSystem.UI.MainBar.IconSize/2);
		--_panel.background = "Texture/3DMapSystem/Panel_BG.png";
		----_panel_behind.background = "Texture/3DMapSystem/WindowFrameStyle/1/frame.png; 0 32 0 0: 4 0 4 24";
		--_panel_behind.background = "Texture/3DMapSystem/common/ThemeLightBlue/container_bg.png; 0 32 0 0: 4 0 4 24";
		_panel_behind.background = "";
		_panel_behind:BringToBack();
		_panel_behind:AttachToRoot();
		_panel_behind.visible = false;
		
		-- category icon, this icon will be replaced by the main bar icon that trigger the main panel
		_this = ParaUI.CreateUIObject("container", "CategoryIcon", "_lt", 4, -24, 48, 48);
		_this.background = "";
		_panel:AddChild(_this);
		
		-- min, max, toggle autohide and close button
		_this = ParaUI.CreateUIObject("button", "MinButton", "_rt", -108, 0, 24, 24);
		_this.animstyle = 12;
		_this.background = "Texture/3DMapSystem/MainPanel/Minimize.png";
		_this.onclick = ";Map3DSystem.UI.MainPanel.OnClickMinimize();";
		_panel:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "MaxButton", "_rt", -81, 0, 24, 24);
		_this.animstyle = 12;
		_this.background = "Texture/3DMapSystem/MainPanel/Maximize.png";
		_this.onclick = ";Map3DSystem.UI.MainPanel.OnClickMaximize();";
		_panel:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "AutoHideButton", "_rt", -54, 0, 24, 24);
		_this.animstyle = 12;
		_this.background = "Texture/3DMapSystem/MainPanel/AutoHide.png";
		_this.onclick = ";Map3DSystem.UI.MainPanel.OnClickAutoHide();";
		Map3DSystem.UI.MainPanel.IsEnableAutoHide = false;
		_panel:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "CloseButton", "_rt", -27, 0, 24, 24);
		_this.animstyle = 12;
		_this.background = "Texture/3DMapSystem/MainPanel/Close.png";
		_this.onclick = ";Map3DSystem.UI.MainPanel.OnClickClose();";
		_panel:AddChild(_this);
		
		-- right aligned resizer
		local _resizerWidth = Map3DSystem.UI.MainPanel.ResizerWidth;
		local _resizerHeight = Map3DSystem.UI.MainPanel.ResizerHeight;
		-- reziser container
		local _resizer_BG = ParaUI.CreateUIObject("button", "Resizer_BG", "_ctr", 0, 0, _resizerWidth, _resizerHeight);
		_resizer_BG.background = Map3DSystem.UI.MainPanel.ResizerBG;
		_panel:AddChild(_resizer_BG);
	
		local _resizer = ParaUI.CreateUIObject("container", "Resizer_panel", "_ctr", 0, 0, _resizerWidth, _resizerHeight);
		_resizer.background = "";
		_resizer.candrag = true;
		_resizer.ondragbegin = ";Map3DSystem.UI.MainPanel.OnDragBegin();";
		_resizer.ondragmove = ";Map3DSystem.UI.MainPanel.OnDragMove();";
		_resizer.ondragend = ";Map3DSystem.UI.MainPanel.OnDragEnd();";
		_panel:AddChild(_resizer);
		
	end	-- if(_panel:IsValid() == false) then
	
end -- function Map3DSystem.UI.MainPanel.InitPanelUI()

-- TODO: attach to message system
-- NOTE: this function is NOT used in current version
-- @param bShow: show or hide the main panel, nil toggle
function Map3DSystem.UI.MainPanel.ShowUI(bShow)
	-- check if already init
	local _panel = ParaUI.GetUIObject("MainBar_panel");
	local _panel_behind = ParaUI.GetUIObject("MainBar_panel_behindMainBarIcons");
	if(_panel:IsValid() == false or _panel_behind == false) then
		log("error: the main bar not yet inited.\n");
		return;
	end
	
	if(bShow == nil) then
		bShow = not _panel.visible;
	end
	_panel.visible = bShow;
	_panel_behind.visible = bShow;
	
end

-- pre show UI function
-- called before the actual main panel is shown
-- including: check if show the resizer according to the WidthSet table
--			set the current width according to the WidthSet table
--			change the catogory icon in main panel to the current active main bar icon
-- NOTE: WidthSet table stored the data including the width and min & max widths to each panel display
function Map3DSystem.UI.MainPanel.PreShowPanelUI(index)

	local _panel = ParaUI.GetUIObject("MainBar_panel");
	local _resizer_BG = _panel:GetChild("Resizer_BG");
	local _resizer = _panel:GetChild("Resizer_panel");
	local _icon = _panel:GetChild("CategoryIcon");
	
	-- TODO: dirty un-autohide
	Map3DSystem.UI.MainPanel.IsEnableAutoHide = true;
	Map3DSystem.UI.MainPanel.OnMouseEnter();
	Map3DSystem.UI.MainPanel.OnClickAutoHide();
	
	-- change the catogory icon in main panel to the current active main bar icon
	_icon.background = Map3DSystem.UI.MainBar.IconSet[index].NormalIconPath;
	
	-- check if show the resizer according to the WidthSet table
	if(Map3DSystem.UI.MainPanel.WidthSet[index].allowDrag) then
		_resizer_BG.visible = true;
		_resizer.visible = true;
	else
		_resizer_BG.visible = false;
		_resizer.visible = false;
	end
	
	-- set the current width according to the WidthSet table
	local width = Map3DSystem.UI.MainPanel.WidthSet[index].currentWidth;
	Map3DSystem.UI.MainPanel.SetPanelWidth(width);
end

-- pre close UI function
-- called after the actual main panel is closed(hiden)
function Map3DSystem.UI.MainPanel.PreClosePanelUI(index)
	-- TODO: dirty un-autohide
	Map3DSystem.UI.MainPanel.IsEnableAutoHide = true;
	Map3DSystem.UI.MainPanel.OnMouseEnter();
	Map3DSystem.UI.MainPanel.OnClickAutoHide();
end

-- on click main bar icon
function Map3DSystem.UI.MainPanel.OnClickIcon(index)
	-- check if it is a main panel object index
	if(Map3DSystem.UI.MainBar.IconSet[index].Type ~= "Panel") then
		log("error: click a non panel object in MainPanel.OnClickIcon() call.\n");
		return;
	end
	
	Map3DSystem.UI.MainPanel.ShowPanel(index, nil);
end

-- show or hide the creation panel, bShow == nil, toggle current setting
function Map3DSystem.UI.MainPanel.ShowPanel(index, bShow)

	--local _icon = ParaUI.GetUIObject("MainBar_icons_"..index);
	--local x, y, width, height = _icon:GetAbsPosition();
	--local offset = 0;
	--
	
	-- bring the MainBar_panel_behindMainBarIcons container to back (behind the main bar icons)
	local _panel = ParaUI.GetUIObject("MainBar_panel");
	local _panel_behind = ParaUI.GetUIObject("MainBar_panel_behindMainBarIcons");
	_panel_behind:BringToBack();
	
	--if(index == 9) then
		---- water panel move to the same position of sky
		--_panel.x = x - offset - 48;
		--_panel_behind.x = x - offset - 48;
	--elseif(index == 10) then
		---- terrain panel move to the same position of sky
		--_panel.x = x - offset - 96;
		--_panel_behind.x = x - offset - 96;
	--else
		--_panel.x = x - offset;
		--_panel_behind.x = x - offset;
	--end
	
	-- show, hide or change the current active main panel
	if(Map3DSystem.UI.MainPanel.CurrentActivePanelIndex == nil) then
		if(bShow == false) then
			-- not show any panel object
		else
			Map3DSystem.UI.MainPanel.CurrentActivePanelIndex = index;
			_panel.visible = true;
			_panel:BringToFront();
			_panel_behind.visible = true;
			-- show index panel
			Map3DSystem.UI.MainPanel.PreShowPanelUI(index);
			Map3DSystem.UI.MainBar.IconSet[index].ShowUICallback();
			NPL.load("(gl)script/ide/UIAnim/UIAnimManager.lua");
			local fileName = "script/UIAnimation/CommonPanel.lua.table";
			--UIAnimManager.PlayUIAnimationSequence(_panel, fileName, "Show", false);
			----UIAnimManager.PlayUIAnimationSequence(_panel:GetChild("MainBar_panel_upper"), fileName, "Show", false);
			----UIAnimManager.PlayUIAnimationSequence(_panel:GetChild("MainBar_panel_lower"), fileName, "Show", false);
			--UIAnimManager.PlayUIAnimationSequence(_panel_behind, fileName, "Show", false);
		end
		
	elseif(Map3DSystem.UI.MainPanel.CurrentActivePanelIndex == index) then
		if(bShow == true) then
			-- already show panel object
		else
			Map3DSystem.UI.MainPanel.CurrentActivePanelIndex = nil;
			
			_panel.visible = false;
			_panel_behind.visible = false;
			
			-- unshow index panel
			Map3DSystem.UI.MainBar.IconSet[index].CloseUICallback();
			
			NPL.load("(gl)script/ide/UIAnim/UIAnimManager.lua");
			local fileName = "script/UIAnimation/CommonPanel.lua.table";
			--UIAnimManager.PlayUIAnimationSequence(_panel, fileName, "Hide", false);
			----UIAnimManager.PlayUIAnimationSequence(_panel:GetChild("MainBar_panel_upper"), fileName, "Hide", false);
			----UIAnimManager.PlayUIAnimationSequence(_panel:GetChild("MainBar_panel_lower"), fileName, "Hide", false);
			--UIAnimManager.PlayUIAnimationSequence(_panel_behind, fileName, "Hide", false);
		end
		
	else
		_panel:BringToFront();
		
		-- unshow Map3DSystem.UI.MainPanel.CurrentActivePanelIndex panel
		Map3DSystem.UI.MainBar.IconSet[Map3DSystem.UI.MainPanel.CurrentActivePanelIndex].CloseUICallback();
		
		if(bShow == false) then
			-- not show any panel object
			Map3DSystem.UI.MainPanel.CurrentActivePanelIndex = nil;
			_panel.visible = false;
			_panel_behind.visible = false;
		elseif(bShow == true) then
			-- show index panel
			Map3DSystem.UI.MainPanel.CurrentActivePanelIndex = index;
			Map3DSystem.UI.MainPanel.PreShowPanelUI(index);
			Map3DSystem.UI.MainBar.IconSet[index].ShowUICallback();
		elseif(bShow == nil) then
			-- NOTE: this bShow is a little tricky, another panel showing instead of "index", 
			--		but will toggle the "index" panel
			-- show index panel
			Map3DSystem.UI.MainPanel.CurrentActivePanelIndex = index;
			Map3DSystem.UI.MainPanel.PreShowPanelUI(index);
			Map3DSystem.UI.MainBar.IconSet[index].ShowUICallback();
		end
	end
end

-- show default panel according to the selected object
function Map3DSystem.UI.MainPanel.ShowDefault()
	
	local selectObj = Map3DSystem.obj.GetObject("selection");
	
	if(selectObj ~= nil and selectObj:IsValid()) then
		if(selectObj:IsCharacter()) then
			-- character
			local player = ParaScene.GetObject("<player>");
			if(player:equals(selectObj) == true) then
				-- modify
				--local _icon = ParaUI.GetUIObject("MainBar_icons_3");
				local _icon = Map3DSystem.UI.MainBar.GetItemUIContainer("apps", "Creator.Modify");
				if(_icon.enabled == true) then
					Map3DSystem.UI.Modify.SendMeMessage(
						{type = Map3DSystem.msg.MAINPANEL_Modify_Show,
						bShow = true});
				end
			else
				-- property
				--local _icon = ParaUI.GetUIObject("MainBar_icons_5");
				local _icon = Map3DSystem.UI.MainBar.GetItemUIContainer("apps", "Creator.Property");
				if(_icon.enabled == true) then
					Map3DSystem.UI.Property.SendMeMessage(
						{type = Map3DSystem.msg.MAINPANEL_Property_Show,
						bShow = true});
				end
			end
			
			return;
		else
			-- model
			if(selectObj:GetNumReplaceableTextures() > 0) then
				-- with r2
				-- property
				--local _icon = ParaUI.GetUIObject("MainBar_icons_5");
				local _icon = Map3DSystem.UI.MainBar.GetItemUIContainer("apps", "Creator.Property");
				if(_icon.enabled == true) then
					Map3DSystem.UI.Property.SendMeMessage(
						{type = Map3DSystem.msg.MAINPANEL_Property_Show,
						bShow = true});
				end
			else
				-- without r2
				-- modify
				--local _icon = ParaUI.GetUIObject("MainBar_icons_3");
				local _icon = Map3DSystem.UI.MainBar.GetItemUIContainer("apps", "Creator.Modify");
				if(_icon.enabled == true) then
					Map3DSystem.UI.Modify.SendMeMessage(
						{type = Map3DSystem.msg.MAINPANEL_Modify_Show,
						bShow = true});
				end
			end
			return;
		end
	else
		-- TODO: can be XRef object
		if(Map3DSystem.UI.Creation.isBCSActive == true) then
			-- BCS XRef script call will initiate the creation panel by default
			Map3DSystem.UI.MainBar.SwitchToStatus("BCSXRef");
		else
			-- none, close the panel
			Map3DSystem.UI.MainBar.SwitchToStatus("none");
		end
		return;
	end
end

-- on mouse enter icon
-- dispatch the mouse enter event according to main bar icon index
function Map3DSystem.UI.MainPanel.OnMouseEnterIcon(index)

	if(Map3DSystem.UI.MainBar.IconSet[index].Type ~= "Panel") then
		log("error: mouse enter a non panel object in MainPanel.OnMouseEnterIcon() call.\n");
		return;
	end
	
	-- dispatch the mouse enter event according to main bar icon index
	if(index == 1) then
		-- Creation panel
		Map3DSystem.UI.Creation.OnMouseEnter();
	elseif(index == 3) then
		-- Modify panel
		Map3DSystem.UI.Modify.OnMouseEnter();
	elseif(index == 5) then
		-- Property panel
		Map3DSystem.UI.Property.OnMouseEnter();
	elseif(index == 8) then
		-- Sky panel
		Map3DSystem.UI.Sky.OnMouseEnter();
	elseif(index == 9) then
		-- Water panel
		Map3DSystem.UI.Water.OnMouseEnter();
	elseif(index == 10) then
		-- Terrain panel
		Map3DSystem.UI.Terrain.OnMouseEnter();
	end
	
end

-- on mouse leave icon
-- dispatch the mouse leave event according to main bar icon index
function Map3DSystem.UI.MainPanel.OnMouseLeaveIcon(index)
	if(Map3DSystem.UI.MainBar.IconSet[index].Type ~= "Panel") then
		log("error: mouse leave a non panel object in MainPanel.OnMouseLeaveIcon() call.\n");
		return;
	end
	
	-- dispatch the mouse leave event according to main bar icon index
	if(index == 1) then
		-- creation panel
		Map3DSystem.UI.Creation.OnMouseLeave();
	elseif(index == 3) then
		-- Modify panel
		Map3DSystem.UI.Modify.OnMouseLeave();
	elseif(index == 5) then
		-- Property panel
		Map3DSystem.UI.Property.OnMouseLeave();
	elseif(index == 8) then
		-- Sky panel
		Map3DSystem.UI.Sky.OnMouseLeave();
	elseif(index == 9) then
		-- Water panel
		Map3DSystem.UI.Water.OnMouseLeave();
	elseif(index == 10) then
		-- Terrain panel
		Map3DSystem.UI.Terrain.OnMouseLeave();
	end
end

-- NOTE: this function is DEPRECATED
--		the funciton's original purpose is to trigger the sub icon on click function in each main panel subobjects
--		now the sub click UI and functions is in each main panel subobjects
-- onclick function to main bar sub icons
function Map3DSystem.UI.MainPanel.OnClickSubIcon(iconIndex, subiconIndex)
	local _iconSet = Map3DSystem.UI.MainBar.IconSet;
	if( _iconSet[iconIndex].SubIconSet ) then
		if(_iconSet[iconIndex].SubIconSet[subiconIndex]) then
			_iconSet[iconIndex].SubIconSet[subiconIndex].ClickCallback(subiconIndex);
		end
	end
end

-- ondragbegin function of main panel resizer
function Map3DSystem.UI.MainPanel.OnDragBegin()
	local _panel = ParaUI.GetUIObject("MainBar_panel");
	local _resizer = ParaUI.GetUIObject("Resizer_panel");
	
	-- store the resizer and panel UI object for resizing operation
	Map3DSystem.UI.MainPanel.DraggingPanel = _panel;
	Map3DSystem.UI.MainPanel.DraggingResizer = _resizer;
end

-- ondragmove function of main panel resizer
function Map3DSystem.UI.MainPanel.OnDragMove()
	local _panel = Map3DSystem.UI.MainPanel.DraggingPanel;
	local _resizer = Map3DSystem.UI.MainPanel.DraggingResizer;
	local x_panel, y_panel, width_panel, height_panel;
	local x_resizer, y_resizer, width_resizer, height_resizer;
	local newWidth;
	
	if(_panel:IsValid() == true and _resizer:IsValid() == true) then
		-- get the absolute position of the panel and resizer and calculate the new panel width
		x_panel, y_panel, width_panel, height_panel = _panel:GetAbsPosition();
		x_resizer, y_resizer, width_resizer, height_resizer = _resizer:GetAbsPosition();
		newWidth = x_resizer - x_panel + width_resizer;
	else
		-- panel and resizer object not valid, get the UI object directly
		_panel = ParaUI.GetUIObject("MainBar_panel");
		_resizer = ParaUI.GetUIObject("Resizer_panel");
	end
	
	-- set the new length according to the resize process
	Map3DSystem.UI.MainPanel.SetPanelWidth(newWidth);
end

-- ondragend function of main panel resizer
function Map3DSystem.UI.MainPanel.OnDragEnd()
	local _panel = Map3DSystem.UI.MainPanel.DraggingPanel;
	local _resizer = Map3DSystem.UI.MainPanel.DraggingResizer;
	
	local _resizerWidth = Map3DSystem.UI.MainPanel.ResizerWidth;
	local _resizerHeight = Map3DSystem.UI.MainPanel.ResizerHeight;
	
	-------------------------------------------------------------------
	-- NOTE: the dragging process is now improved
	--			dragging object no longer needs destroy and recreation process
	--			ParaUI.AddDragReceiver logics is implemented by ParaUIObject, (only one object is dragging at any time)
	--			which allows dragable objects to specify which UI receiver can receive it.
	-------------------------------------------------------------------
	
	--ParaUI.Destroy("Resizer_panel");
	--local _resizer = ParaUI.CreateUIObject("container", "Resizer_panel", "_ctr", 0, 0, _resizerWidth, _resizerHeight);
	--_resizer.background = "";
	--_resizer.candrag = true;
	--_resizer.ondragbegin = ";Map3DSystem.UI.MainPanel.OnDragBegin();";
	--_resizer.ondragmove = ";Map3DSystem.UI.MainPanel.OnDragMove();";
	--_resizer.ondragend = ";Map3DSystem.UI.MainPanel.OnDragEnd();";
	--_panel:AddChild(_resizer);
	
	-- reset the resizing UI objects to nil
	Map3DSystem.UI.MainPanel.DraggingPanel = nil;
	Map3DSystem.UI.MainPanel.DraggingResizer = nil;
end

-- onclick funtion of panel minimize button
function Map3DSystem.UI.MainPanel.OnClickMinimize()
	Map3DSystem.UI.MainPanel.SendMeMessageToAllWnd({type = CommonCtrl.os.MSGTYPE.WM_MINIMIZE});
end

-- onclick funtion of panel maximize button
function Map3DSystem.UI.MainPanel.OnClickMaximize()
	Map3DSystem.UI.MainPanel.SendMeMessageToAllWnd({type = CommonCtrl.os.MSGTYPE.WM_MAXIMIZE});
end

-- onclick funtion of panel toggle autohide button
function Map3DSystem.UI.MainPanel.OnClickAutoHide()
	Map3DSystem.UI.MainPanel.SendMeMessageToAllWnd({type = Map3DSystem.msg.MAINPANEL_AutoHide, bAutoHiding = nil});
end

-- onclick funtion of panel close button
function Map3DSystem.UI.MainPanel.OnClickClose()
	Map3DSystem.UI.MainPanel.SendMeMessageToAllWnd({type = CommonCtrl.os.MSGTYPE.WM_CLOSE});
end

-- minimize main panel to minimize size recorded in Map3DSystem.UI.MainPanel.WidthSet
function Map3DSystem.UI.MainPanel.MinimizePanel()
	--TODO: minimize
	--Map3DSystem.UI.MainPanel.ClosePanel();
	local index = Map3DSystem.UI.MainPanel.CurrentActivePanelIndex;
	local width = Map3DSystem.UI.MainPanel.WidthSet[index].minWidth;
	Map3DSystem.UI.MainPanel.SetPanelWidth(width);
end

-- maximize main panel to maximize size recorded in Map3DSystem.UI.MainPanel.WidthSet
function Map3DSystem.UI.MainPanel.MaximizePanel()
	--TODO: maximize
	local index = Map3DSystem.UI.MainPanel.CurrentActivePanelIndex;
	local width = Map3DSystem.UI.MainPanel.WidthSet[index].maxWidth;
	Map3DSystem.UI.MainPanel.SetPanelWidth(width);
end

-- toggle autohide mode in main panel
-- bAutoHiding: true or false, nil toggle current status
function Map3DSystem.UI.MainPanel.AutoHidePanel(bAutoHiding)
	local _panel = ParaUI.GetUIObject("MainBar_panel");
	local _autohide = _panel:GetChild("AutoHideButton");
	
	-- set/unset autohide mode
	if(bAutoHiding == nil) then
		Map3DSystem.UI.MainPanel.IsEnableAutoHide = not Map3DSystem.UI.MainPanel.IsEnableAutoHide;
	else
		Map3DSystem.UI.MainPanel.IsEnableAutoHide = bAutoHiding;
	end
	
	-- change the toggle autohide button background
	if(Map3DSystem.UI.MainPanel.IsEnableAutoHide) then
		_autohide.background = "Texture/3DMapSystem/MainPanel/AutoHidePin.png";
	else
		_autohide.background = "Texture/3DMapSystem/MainPanel/AutoHide.png";
	end
end

-- close the main panel
function Map3DSystem.UI.MainPanel.ClosePanel()
	if(Map3DSystem.UI.MainPanel.CurrentActivePanelIndex ~= nil) then
		local _panel = ParaUI.GetUIObject("MainBar_panel");
		local _panel_behind = ParaUI.GetUIObject("MainBar_panel_behindMainBarIcons");
		local _index = Map3DSystem.UI.MainPanel.CurrentActivePanelIndex;
		Map3DSystem.UI.MainPanel.CurrentActivePanelIndex = nil;
		_panel.visible = false;
		_panel_behind.visible = false;
		-- unshow index panel
		Map3DSystem.UI.MainBar.IconSet[_index].CloseUICallback();
	end
	
	if(Map3DSystem.UI.Creation.isBCSActive == true) then
		-- clear the BCSMarker mini scene graph
		Map3DSystem.UI.Creation.isBCSActive = false;
		local BCSMarkerGraph = ParaScene.GetMiniSceneGraph("BCSMarker");
		BCSMarkerGraph:Reset();
	end
end

function Map3DSystem.UI.MainPanel.ShowResizer(bShow)
	local _panel = ParaUI.GetUIObject("MainBar_panel");
	local _resizer_BG = _panel:GetChild("Resizer_BG");
	local _resizer = _panel:GetChild("Resizer_panel");
	_resizer_BG.visible = bShow;
	_resizer.visible = bShow;
end

function Map3DSystem.UI.MainPanel.OnMouseEnter()
	if(Map3DSystem.UI.MainPanel.IsEnableAutoHide) then
		local _panel = ParaUI.GetUIObject("MainBar_panel");
		_panel.y = - Map3DSystem.UI.MainBar.IconHeightOffset - Map3DSystem.UI.MainBar.IconSize - Map3DSystem.UI.MainPanel.PanelBGHeight;
		_panel.height = Map3DSystem.UI.MainPanel.PanelBGHeight;
		local _this = _panel:GetChild("MainBar_panel_lower");
		_this.visible = true;
		-- auto hiding show resizer
		Map3DSystem.UI.MainPanel.ShowResizer(true);
		-- show sub container
		if(Map3DSystem.UI.MainPanel.CurrentActivePanelIndex == 1) then
			Map3DSystem.UI.MainPanel.MainWnd:SendMessage(
				Map3DSystem.UI.Creation.WndObject.name, CommonCtrl.os.MSGTYPE.WM_SHOW);
		elseif(Map3DSystem.UI.MainPanel.CurrentActivePanelIndex == 3) then
			Map3DSystem.UI.MainPanel.MainWnd:SendMessage(
				Map3DSystem.UI.Modify.WndObject.name, CommonCtrl.os.MSGTYPE.WM_SHOW);
		elseif(Map3DSystem.UI.MainPanel.CurrentActivePanelIndex == 5) then
			Map3DSystem.UI.MainPanel.MainWnd:SendMessage(
				Map3DSystem.UI.Property.WndObject.name, CommonCtrl.os.MSGTYPE.WM_SHOW);
		elseif(Map3DSystem.UI.MainPanel.CurrentActivePanelIndex == 8) then
			Map3DSystem.UI.MainPanel.MainWnd:SendMessage(
				Map3DSystem.UI.Sky.WndObject.name, CommonCtrl.os.MSGTYPE.WM_SHOW);
		elseif(Map3DSystem.UI.MainPanel.CurrentActivePanelIndex == 9) then
			Map3DSystem.UI.MainPanel.MainWnd:SendMessage(
				Map3DSystem.UI.Water.WndObject.name, CommonCtrl.os.MSGTYPE.WM_SHOW);
		elseif(Map3DSystem.UI.MainPanel.CurrentActivePanelIndex == 10) then
			Map3DSystem.UI.MainPanel.MainWnd:SendMessage(
				Map3DSystem.UI.Terrain.WndObject.name, CommonCtrl.os.MSGTYPE.WM_SHOW);
		end
	end
end

function Map3DSystem.UI.MainPanel.OnMouseLeave()
	if(Map3DSystem.UI.MainPanel.IsEnableAutoHide) then
		local _panel = ParaUI.GetUIObject("MainBar_panel");
		_panel.y = - Map3DSystem.UI.MainBar.IconHeightOffset - Map3DSystem.UI.MainBar.IconSize - Map3DSystem.UI.MainPanel.SubPanelOffsetY;
		_panel.height = Map3DSystem.UI.MainPanel.SubPanelOffsetY;
		local _this = _panel:GetChild("MainBar_panel_lower");
		_this.visible = false;
		-- auto hiding hide resizer
		Map3DSystem.UI.MainPanel.ShowResizer(false);
		-- hide sub container
		if(Map3DSystem.UI.MainPanel.CurrentActivePanelIndex == 1) then
			Map3DSystem.UI.MainPanel.MainWnd:SendMessage(
				Map3DSystem.UI.Creation.WndObject.name, CommonCtrl.os.MSGTYPE.WM_HIDE);
		elseif(Map3DSystem.UI.MainPanel.CurrentActivePanelIndex == 3) then
			Map3DSystem.UI.MainPanel.MainWnd:SendMessage(
				Map3DSystem.UI.Modify.WndObject.name, CommonCtrl.os.MSGTYPE.WM_HIDE);
		elseif(Map3DSystem.UI.MainPanel.CurrentActivePanelIndex == 5) then
			Map3DSystem.UI.MainPanel.MainWnd:SendMessage(
				Map3DSystem.UI.Property.WndObject.name, CommonCtrl.os.MSGTYPE.WM_HIDE);
		elseif(Map3DSystem.UI.MainPanel.CurrentActivePanelIndex == 8) then
			Map3DSystem.UI.MainPanel.MainWnd:SendMessage(
				Map3DSystem.UI.Sky.WndObject.name, CommonCtrl.os.MSGTYPE.WM_HIDE);
		elseif(Map3DSystem.UI.MainPanel.CurrentActivePanelIndex == 9) then
			Map3DSystem.UI.MainPanel.MainWnd:SendMessage(
				Map3DSystem.UI.Water.WndObject.name, CommonCtrl.os.MSGTYPE.WM_HIDE);
		elseif(Map3DSystem.UI.MainPanel.CurrentActivePanelIndex == 10) then
			Map3DSystem.UI.MainPanel.MainWnd:SendMessage(
				Map3DSystem.UI.Terrain.WndObject.name, CommonCtrl.os.MSGTYPE.WM_HIDE);
		end
	end
end

function Map3DSystem.UI.MainPanel.OnResize()
	-- sub container showUI will resize the panel by default
	if(Map3DSystem.UI.MainPanel.CurrentActivePanelIndex == 1) then
		Map3DSystem.UI.MainPanel.MainWnd:SendMessage(
			Map3DSystem.UI.Creation.WndObject.name, CommonCtrl.os.MSGTYPE.WM_SHOW);
	elseif(Map3DSystem.UI.MainPanel.CurrentActivePanelIndex == 3) then
		Map3DSystem.UI.MainPanel.MainWnd:SendMessage(
			Map3DSystem.UI.Modify.WndObject.name, CommonCtrl.os.MSGTYPE.WM_SHOW);
	elseif(Map3DSystem.UI.MainPanel.CurrentActivePanelIndex == 5) then
		Map3DSystem.UI.MainPanel.MainWnd:SendMessage(
			Map3DSystem.UI.Property.WndObject.name, CommonCtrl.os.MSGTYPE.WM_SHOW);
	elseif(Map3DSystem.UI.MainPanel.CurrentActivePanelIndex == 8) then
		Map3DSystem.UI.MainPanel.MainWnd:SendMessage(
			Map3DSystem.UI.Sky.WndObject.name, CommonCtrl.os.MSGTYPE.WM_SHOW);
	elseif(Map3DSystem.UI.MainPanel.CurrentActivePanelIndex == 9) then
		Map3DSystem.UI.MainPanel.MainWnd:SendMessage(
			Map3DSystem.UI.Water.WndObject.name, CommonCtrl.os.MSGTYPE.WM_SHOW);
	elseif(Map3DSystem.UI.MainPanel.CurrentActivePanelIndex == 10) then
		Map3DSystem.UI.MainPanel.MainWnd:SendMessage(
			Map3DSystem.UI.Terrain.WndObject.name, CommonCtrl.os.MSGTYPE.WM_SHOW);
	end
end

function Map3DSystem.UI.MainPanel.SetPanelPosX(posX)
	local _panel = ParaUI.GetUIObject("MainBar_panel");
	local _panel_behind = ParaUI.GetUIObject("MainBar_panel_behindMainBarIcons");
	
	_panel.x = posX;
	_panel_behind.x = posX;
end

function Map3DSystem.UI.MainPanel.SetPanelWidth(width)
	local _panel = ParaUI.GetUIObject("MainBar_panel");
	local _panel_behind = ParaUI.GetUIObject("MainBar_panel_behindMainBarIcons");
	local x_panel, y_panel, width_panel, height_panel = _panel:GetAbsPosition();
	
	local _widthSet = Map3DSystem.UI.MainPanel.WidthSet;
	if(Map3DSystem.UI.MainPanel.CurrentActivePanelIndex ~= nil) then
		local _index = Map3DSystem.UI.MainPanel.CurrentActivePanelIndex;
		
		if(Map3DSystem.UI.MainBar.IconSet[_index].Type == "Panel") then
			local _minWidth = _widthSet[_index].minWidth;
			local _maxWidth = _widthSet[_index].maxWidth;
			if(width <= _minWidth) then
				width = _minWidth;
			end
			if(width >= _maxWidth) then
				width = _maxWidth;
			end
			_panel.width = width;
			_panel_behind.width = width;
			_widthSet[_index].currentWidth = width;
			
			if(_index == 1) then
				Map3DSystem.UI.MainPanel.MainWnd:SendMessage(
					Map3DSystem.UI.Creation.WndObject.name, CommonCtrl.os.MSGTYPE.WM_SIZE, width);
			end
		end
	end
	
	-- TODO: Post set new width to panel child object
end