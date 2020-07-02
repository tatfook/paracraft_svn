--[[
Title: Main bar stub for new 3D Map system on ParaWorld
Author(s): WangTian
Date: 2008/1/9
Desc: Show the main bar in game UI
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Layout/MainBarStub.lua");
Map3DSystem.UI.MainBarStub.InitMainBar();
------------------------------------------------------------

------------------------------------------------------------
-- WARNING: this is a DEBUG purpose mainbar file, DON'T use it in any release
------------------------------------------------------------

]]

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

commonlib.echo("\n main bar stub loaded \n\n")

local L = CommonCtrl.Locale("Kids3DMap");

-- DEBUG purpose table: MainBarStub
if(not Map3DSystem.UI.MainBarStub) then Map3DSystem.UI.MainBarStub = {}; end

-- NOTE: groups+icons+stackitems doc refer to notebook 2008.1.9

-- Main bar is consists of serveral groups. Groups are separated by separators
-- each group has an index to tell the sequence displaying on the mainbar
-- e.x.: Map3DSystem.UI.MainBar.groups[1] = {
--		index = 1,
--		name = "apps",
--		index = ,
-- }
if(not Map3DSystem.UI.MainBarStub.groups) then Map3DSystem.UI.MainBarStub.groups = {}; end

-- Each group has a sequence of icons for clicking. Icon is a kind of integration point for applications in ParaWorld.
-- Each icon provides tooltip, iconpath, onclick, onmouseenter, onmouseleave .etc
if(not Map3DSystem.UI.MainBarStub.icons) then Map3DSystem.UI.MainBarStub.icons = {}; end

-- Icons inside a stack-typed icon
if(not Map3DSystem.UI.MainBarStub.stackitems) then Map3DSystem.UI.MainBarStub.stackitems = {}; end

-- init main bar:
function Map3DSystem.UI.MainBarStub.InitMainBar()

	------------ TODO: DEBUG PURPOSE ONLY ----------
	--Map3DSystem.User.Role = "administrator";
	------------ TODO: DEBUG PURPOSE ONLY ----------
	--
	------------------------------
	---- Note LiXizhi 2007.12.31. All former testing functions have been moved to 
	---- NPL.load("(gl)script/kids/3DMapSystemUI/InGame/TestPanel.lua");
	---- It can be accessed via the SDK menu at runtime. 
	------------------------------
	--
	---- TODO: LiXizhi 2007.12.31: shall we limit Map3DSystem.UI.MainBar.bIsInit as one time init as below?
	---- we should separate one time init, per world init and show world UI in three functions. 
	--
	------------------------------
	---- Andy 2008.1.2: i think the mainbar should be one time init function in per world init
	----		the main conflict will be chat related things that can receive at any time.
	----		And we should provide visual feed back.
	----	As for UIAnimManager.LoadUIAnimationFile, this function will check the lua table if the 
	----		animation file has been loaded. I think It's one time init to the manager, 
	----		not one time init to the main bar.
	------------------------------
	--
	--if(not Map3DSystem.UI.MainBar.bIsInit) then
		---- TODO: load UI animation files
		--NPL.load("(gl)script/ide/UIAnim/UIAnimManager.lua");
		--local fileName = "script/UIAnimation/Test_UIAnimFile.lua.table";
		--local file = UIAnimManager.LoadUIAnimationFile(fileName);
		--fileName = "script/UIAnimation/CommonIcon.lua.table";
		--file = UIAnimManager.LoadUIAnimationFile(fileName);
		--fileName = "script/UIAnimation/CommonPanel.lua.table";
		--file = UIAnimManager.LoadUIAnimationFile(fileName);
		--fileName = "script/UIAnimation/CommonBar.lua.table";
		--file = UIAnimManager.LoadUIAnimationFile(fileName);
		--fileName = "script/UIAnimation/FloatingHighlight.lua.table";
		--file = UIAnimManager.LoadUIAnimationFile(fileName);
	--end	
	--
	--
	Map3DSystem.UI.MainBarStub.InitMessageSystem();
	Map3DSystem.UI.MainBarStub.InitUI();
	--
	--NPL.load("(gl)script/kids/3DMapSystemUI/InGame/MainPanel.lua");
	--Map3DSystem.UI.MainPanel.InitMessageSystem();
	--Map3DSystem.UI.MainPanel.InitUI();
	--
	--NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Hints.lua");
	--Map3DSystem.UI.Hints.InitMessageSystem();
	--Map3DSystem.UI.Hints.InitUI();
	--
	--NPL.load("(gl)script/kids/3DMapSystemUI/CCS/DB.lua");
	--Map3DSystem.UI.CCS.DB.InitBodyParamIDSet();
	--
	--NPL.load("(gl)script/kids/3DMapSystemUI/BCS/DB.lua");
	--Map3DSystem.UI.BCS.DB.ReadBCSAssetFromDB();
	--
	--NPL.load("(gl)script/kids/3DMapSystemUI/CCS/Main.lua");
	--Map3DSystem.UI.CCS.InitMessageSystem();
	--
	--NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Chat.lua");
	--Map3DSystem.UI.Chat.EnterScene();
	--
	--NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Profile.lua");
	--Map3DSystem.UI.Profile.InitMessageSystem();
	--
	---------------------------------
	---- 
	---- 2007.12.28 LXZ: since action feed bar contains integration points, only call OnRenderBox when mcml are retrieved from server and apps for this world are all installed 
	---- 
	---------------------------------
	--NPL.load("(gl)script/kids/3DMapSystemUI/InGame/ActionFeedBar.lua");
	--local mcml = nil;
	--Map3DSystem.UI.ActionFeedBar.OnRenderBox(mcml);
	--
	--NPL.load("(gl)script/kids/3DMapSystemUI/Desktop/MainMenu.lua");
	--Map3DSystem.UI.MainMenu.InitMainMenu();
	--Map3DSystem.UI.MainMenu.SendMessage({type = Map3DSystem.UI.MainMenu.MSGTYPE.MENU_SHOW});
	--
	-------------- TODO: DEBUG PURPOSE ONLY ----------
	----Map3DSystem.UI.Chat.OnClick();
	----Map3DSystem.UI.Chat.OnClick();
	-------------- TODO: DEBUG PURPOSE ONLY ----------
	--
	--Map3DSystem.UI.MainBar.SendMeMessage({type = Map3DSystem.msg.MAINBAR_SwitchStatus, sStatus = "none"});
	--
	--Map3DSystem.UI.MainBar.bIsInit = true;
end

-- init message system: call this function at main bar initialization to init the message system for main bar
function Map3DSystem.UI.MainBar.InitMessageSystem()
	NPL.load("(gl)script/ide/os.lua");
	local _app = CommonCtrl.os.CreateGetApp("MainBar");
	Map3DSystem.UI.MainBar.App = _app;
	Map3DSystem.UI.MainBar.MainWnd = _app:RegisterWindow("MainBarWnd", nil, Map3DSystem.UI.MainBar.MSGProc);
end

-- send a message to MainBar:MainBarWnd window handler
-- e.g. Map3DSystem.UI.MainBar.SendMeMessage({type = Map3DSystem.msg.MAINBAR_Show})
function Map3DSystem.UI.MainBar.SendMeMessage(msg)
	msg.wndName = Map3DSystem.UI.MainBar.MainWnd.name;
	Map3DSystem.UI.MainBar.App:SendMessage(msg);
end

-- main bar: mainbar window handler
function Map3DSystem.UI.MainBar.MSGProc(window, msg)
	if(msg.type == Map3DSystem.msg.MAINBAR_Show) then
		-- show, hide or toggle the main bar UI
		Map3DSystem.UI.MainBar.ShowUI(msg.bShow);
	elseif(msg.type == Map3DSystem.msg.MAINBAR_NavMode) then
		-- true or false navigation mode
		-- true: switch to navmode, false switch back to edit mode
		Map3DSystem.UI.MainBar.SwitchNavigationMode(msg.bNavMode);
	elseif(msg.type == Map3DSystem.msg.MAINBAR_BounceIcon) then
		-- play animation to icon with "bounce" common animation
		Map3DSystem.UI.MainBar.BounceIcon(msg.iconID, msg.isLooping, msg.isAnimate);
	elseif(msg.type == Map3DSystem.msg.MAINBAR_SwitchStatus) then
		-- switch to main bar display status
		if(msg.sStatus == "none") then
			Map3DSystem.UI.MainBar.SwitchToStatus("none");
		elseif(msg.sStatus == "character") then
			Map3DSystem.UI.MainBar.SwitchToStatus("character");
		elseif(msg.sStatus == "model") then
			Map3DSystem.UI.MainBar.SwitchToStatus("model");
		elseif(msg.sStatus == "BCSXRef") then
			-- TODO: show the model status, and creation panel with BCS on first trigger
			-- TODO: hint of the creation point
			Map3DSystem.UI.MainBar.SwitchToStatus("BCSXRef");
		elseif(msg.sStatus == nil) then
			-- check the status according to current object selection
			Map3DSystem.UI.MainBar.SwitchToStatus();
		end
	end
end

-- play animation to icon with "bounce" common animation
function Map3DSystem.UI.MainBar.BounceIcon(iconID, isLooping, isAnimate)
	NPL.load("(gl)script/ide/UIAnim/UIAnimManager.lua");
	local _chatIcon = ParaUI.GetUIObject("MainBar_icons_"..iconID);
	local fileName = "script/UIAnimation/CommonIcon.lua.table";
	if(isAnimate == true) then
		UIAnimManager.PlayUIAnimationSequence(_chatIcon, fileName, "Bounce", isLooping);
	else
		UIAnimManager.StopLoopingUIAnimationSequence(_chatIcon, fileName, "Bounce");
	end
end

function Map3DSystem.UI.MainBar.OnSizeMainBar()
	Map3DSystem.UI.MainPanel.SendMeMessage({type = CommonCtrl.os.MSGTYPE.WM_SIZE});
	NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Hints.lua");
	Map3DSystem.UI.Hints.SendMeMessage({type = CommonCtrl.os.MSGTYPE.WM_SIZE});
end

-- init main bar UI
function Map3DSystem.UI.MainBar.InitUI()
	-- check if already init
	local _bar = ParaUI.GetUIObject("MainBar_bar");
	if(_bar:IsValid() == true) then
		log("warning: the main bar has been inited.\n");
		return;
	end
	
	-- calculate the main bar width including the main bar icons, separators and additional width of bar background
	local barAdd = Map3DSystem.UI.MainBar.BarBGWidthAdditional;
	local iconNum = table.getn(Map3DSystem.UI.MainBar.IconSet);
	local iconWidth = 0;
	
	for i = 1, iconNum do
		if(Map3DSystem.UI.MainBar.IconSet[i].Type == "Separator") then
			if(Map3DSystem.UI.MainBar.IconSet[i].ShowIcon) then
				iconWidth = iconWidth + Map3DSystem.UI.MainBar.SeparatorWidth;
			end
		else
			if(Map3DSystem.UI.MainBar.IconSet[i].ShowIcon) then
				iconWidth = iconWidth + Map3DSystem.UI.MainBar.IconSize;
			end
		end
	end
	
	local barWidth = iconWidth + barAdd * 2;
	
	-- main bar container
	local _bar = ParaUI.CreateUIObject("container", "MainBar_bar", "_ctb", 
		0, 0, 
		barWidth, Map3DSystem.UI.MainBar.BarBGHeight);
	_bar:AttachToRoot();
	_bar.onsize = ";Map3DSystem.UI.MainBar.OnSizeMainBar();";
	_bar.onmouseenter = ";Map3DSystem.UI.MainBar.OnEnterMainBar();";
	_bar.onmouseleave = ";Map3DSystem.UI.MainBar.OnLeaveMainBar();";
	_bar.background = "";
	
	-- main bar background
	local _this = ParaUI.CreateUIObject("container", "MainBar_bar_left_BG", "_lt", 
		0, 0, 
		128, Map3DSystem.UI.MainBar.BarBGHeight); -- 128*64
	_this.background = "Texture/3DMapSystem/MainBar_Left_BG.png";
	--_this.color = "255 255 255 160";
	_bar:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("container", "MainBar_bar_middle_BG", "_lt", 
		128, 0, 
		barWidth - 256, Map3DSystem.UI.MainBar.BarBGHeight); -- mid*64
	_this.background = "Texture/3DMapSystem/MainBar_Middle_BG.png";
	--_this.color = "255 255 255 160";
	_bar:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("container", "MainBar_bar_right_BG", "_rt", 
		-128, 0, 
		128, Map3DSystem.UI.MainBar.BarBGHeight); -- 128*64
	_this.background = "Texture/3DMapSystem/MainBar_Right_BG.png";
	--_this.color = "255 255 255 160";
	_bar:AddChild(_this);
	
	
	-- bottom slider
	_this = ParaUI.CreateUIObject("container", "MainBar_bar_bottomslider", "_mb", 
		25, 3, 25, 7);
	_this.background = "Texture/3DMapSystem/MainbarIcon/BottomSlider.png: 3 3 3 3";
	_this.enable = false;
	_this.visible = false;
	_bar:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("button", "MainBar_bar_floatinghighlight", "_lt", 
		41, 40, 32, 32);
	_this.background = "Texture/3DMapSystem/MainbarIcon/FloatingHighlight.png";
	_this.enable = false;
	_bar:AddChild(_this);
	
	-- TODO: dirty animation
	--Map3DSystem.UI.MainBar.AnimatableUIObjects.BarLeft = ParaUI.GetUIObject("MainBar_bar_left_BG");
	--Map3DSystem.UI.MainBar.AnimatableUIObjects.BarMiddle = ParaUI.GetUIObject("MainBar_bar_middle_BG");
	--Map3DSystem.UI.MainBar.AnimatableUIObjects.BarRight = ParaUI.GetUIObject("MainBar_bar_right_BG");
	
	-- main bar icons container
	local _icons = ParaUI.CreateUIObject("container", "MainBar_icons", "_mt",
		Map3DSystem.UI.MainBar.BarBGWidthAdditional, 0, 
		Map3DSystem.UI.MainBar.BarBGWidthAdditional, Map3DSystem.UI.MainBar.IconSize);
	_bar:AddChild(_icons);
	_icons.background = "";
	
	-- main bar icons
	local widthAccumulator = 0;
	local _this;
	for i = 1, iconNum do
		if(Map3DSystem.UI.MainBar.IconSet[i].Type == "Separator") then
			
			if(Map3DSystem.UI.MainBar.IconSet[i].ShowIcon) then
				local _this = ParaUI.CreateUIObject("container", "MainBar_icons_"..i, "_lt",
					widthAccumulator, 4, 
					Map3DSystem.UI.MainBar.SeparatorWidth, Map3DSystem.UI.MainBar.IconSize);
					
				_this.background = Map3DSystem.UI.MainBar.SeparatorBG;
				_icons:AddChild(_this);
				
				Map3DSystem.UI.MainBar.AnimatableUIObjects.IconSet[i] = _this;
				
				widthAccumulator = widthAccumulator + Map3DSystem.UI.MainBar.SeparatorWidth;
			end
		else
			if(Map3DSystem.UI.MainBar.IconSet[i].ShowIcon) then
				local _this = ParaUI.CreateUIObject("button", "MainBar_icons_"..i, "_lt",
					widthAccumulator, 4, 
					Map3DSystem.UI.MainBar.IconSize, Map3DSystem.UI.MainBar.IconSize);
				
				_this.animstyle = 12;
				
				_this.tooltip = Map3DSystem.UI.MainBar.IconSet[i].ToolTip;
				_this.background = Map3DSystem.UI.MainBar.IconSet[i].NormalIconPath;
				_this.onclick = ";Map3DSystem.UI.MainBar.OnClickIcon("..i..");";
				_this.onmouseenter = ";Map3DSystem.UI.MainBar.OnEnterIcon("..i..");";
				_this.onmouseleave = ";Map3DSystem.UI.MainBar.OnLeaveIcon("..i..");";
				_icons:AddChild(_this);
				
				Map3DSystem.UI.MainBar.AnimatableUIObjects.IconSet[i] = _this;
				
				widthAccumulator = widthAccumulator + Map3DSystem.UI.MainBar.IconSize;
			end
		end -- if(Map3DSystem.UI.MainBar.IconSet[i].Type == "Separator") then
		
	end -- for i = 1, iconNum do
end

-- @param bShow: show or hide the main bar, nil toggle
function Map3DSystem.UI.MainBar.ShowUI(bShow)
	-- check if already init
	local _bar = ParaUI.GetUIObject("MainBar_bar");
	if(_bar:IsValid() == false) then
		log("error: the main bar not yet inited.\n");
		return;
	end
	if(bShow == nil) then
		bShow = not _bar.visible;
	end
	_bar.visible = bShow;
end

-- add a new item to the main bar
-- param ID: the target position on the main bar
-- param itemDesc: contains a complete description of the mainbar item
--	itemDesc  e.x.:
--	{
--		ShowIcon = true;
--		ToolTip = L"Sky";
--		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Sky.png; 0 0 48 48";
--		Type = "Panel";
--		ShowUICallback = Map3DSystem.UI.Sky.ShowUI;
--		CloseUICallback = Map3DSystem.UI.Sky.CloseUI;
--		MouseEnterCallback = Map3DSystem.UI.Sky.OnMouseEnter;
--		MouseLeaveCallback = Map3DSystem.UI.Sky.OnMouseLeave;
--	};
function Map3DSystem.UI.MainBar.AddItem(itemDesc, ID)

	local nCount = table.getn(Map3DSystem.UI.MainBar.IconSet);
	if(ID == nil) then
		-- insert the new item into the end of main bar
		Map3DSystem.UI.MainBar.IconSet[nCount+1] = itemDesc;
	elseif(ID > nCount) then
		-- insert the new item into the end of main bar
		Map3DSystem.UI.MainBar.IconSet[nCount+1] = itemDesc;
	elseif(ID <= nCount and ID >= 1) then
		local i;
		local newIconSet = {};
		-- insert the new item into the main bar iconset table
		for i = 1, nCount + 1 do
			if(i < ID) then
				newIconSet[i] = Map3DSystem.UI.MainBar.IconSet[i];
			elseif(i == ID) then
				newIconSet[ID] = itemDesc;
			elseif(i > ID) then
				newIconSet[i] = Map3DSystem.UI.MainBar.IconSet[i-1];
			end
		end
		-- apply the new iconset table
		Map3DSystem.UI.MainBar.IconSet = newIconSet;
	end
	
	-- TODO: add more animation to item inserting
	
	-- redraw UI
	ParaUI.Destroy("MainBar_bar");
	Map3DSystem.UI.MainBar.InitUI();
	
	-- refresh the autotips position
	Map3DSystem.UI.Hints.RefreshPosition();
end

Map3DSystem.UI.MainBar.IconSet[19] = 
	{
		ShowIcon = true;
		ToolTip = L"Exit";
		NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Exit.png; 0 0 48 48";
		--NormalIconPath = "Texture/3DMapSystem/MainBarIcon/Menu_1.png";
		--MouseoverIconPath = "Texture/3DMapSystem/MainBarIcon/exit_o.png";
		--DisableIconPath = "Texture/3DMapSystem/MainBarIcon/exit_d.png";
		Type = "Window";
		ClickCallback = Map3DSystem.UI.Exit.OnClick;
		MouseEnterCallback = Map3DSystem.UI.Exit.OnMouseEnter;
		MouseLeaveCallback = Map3DSystem.UI.Exit.OnMouseLeave;
	};

-- onclick function to main bar icons
function Map3DSystem.UI.MainBar.OnClickIcon(index)
	
	local _icon = ParaUI.GetUIObject("MainBar_icons_"..index);
	
	local _bar = ParaUI.GetUIObject("MainBar_bar");
	local _highlight = _bar:GetChild("MainBar_bar_floatinghighlight");
	local _fileName = "script/UIAnimation/FloatingHighlight.lua.table";
	UIAnimManager.PlayUIAnimationSequence(_highlight, _fileName, "Pop", false);
	
	
	if(Map3DSystem.UI.MainBar.IconSet[index].Type == "Panel") then
		
		--Map3DSystem.UI.MainPanel.OnClickIcon(index);
		Map3DSystem.UI.MainPanel.SendMeMessage({type = Map3DSystem.msg.MAINPANEL_ClickIcon, index = index});
		
		Map3DSystem.UI.MainBar.SendMeMessage({type = Map3DSystem.msg.MAINBAR_BounceIcon, iconID = index, isLooping = false, isAnimate = true});
		
	elseif(Map3DSystem.UI.MainBar.IconSet[index].Type == "Button") then
	
		Map3DSystem.UI.MainBar.IconSet[index].ClickCallback();
		
		Map3DSystem.UI.MainBar.SendMeMessage({type = Map3DSystem.msg.MAINBAR_BounceIcon, iconID = index, isLooping = false, isAnimate = true});
	
	elseif(Map3DSystem.UI.MainBar.IconSet[index].Type == "Window") then
		
		Map3DSystem.UI.MainBar.IconSet[index].ClickCallback();
		
		Map3DSystem.UI.MainBar.SendMeMessage({type = Map3DSystem.msg.MAINBAR_BounceIcon, iconID = index, isLooping = false, isAnimate = true});
		
		--Map3DSystem.UI.MainBar.IconSet[index].CloseWnd();
	end
	
end

-- onmouseenter function to main bar sub icons
function Map3DSystem.UI.MainBar.OnEnterIcon(index)
	
	local _icon = ParaUI.GetUIObject("MainBar_icons_"..index);
	
	local _bar = ParaUI.GetUIObject("MainBar_bar");
	local _highlight = _bar:GetChild("MainBar_bar_floatinghighlight");
	--if(_highlight.visible == false) then
		--local _fileName = "script/UIAnimation/FloatingHighlight.lua.table";
		--UIAnimManager.PlayUIAnimationSequence(_highlight, _fileName, "Show", false);
	--end
	_highlight.visible = true;
	_highlight.x = _icon.x + 40;
	
	if(Map3DSystem.UI.MainBar.IconSet[index].Type == "Panel") then
		
		Map3DSystem.UI.MainPanel.OnMouseEnterIcon(index);
		
	elseif(Map3DSystem.UI.MainBar.IconSet[index].Type == "Button") then
	
		Map3DSystem.UI.MainBar.IconSet[index].MouseEnterCallback();
	
	elseif(Map3DSystem.UI.MainBar.IconSet[index].Type == "Window") then
		
		Map3DSystem.UI.MainBar.IconSet[index].MouseEnterCallback();
	end
end

-- onmouseleave function to main bar sub icons containter
function Map3DSystem.UI.MainBar.OnLeaveIcon(index)
	
	local _icon = ParaUI.GetUIObject("MainBar_icons_"..index);
	
	local _bar = ParaUI.GetUIObject("MainBar_bar");
	local _highlight = _bar:GetChild("MainBar_bar_floatinghighlight");
	--if(_highlight.visible == true) then
		--local _fileName = "script/UIAnimation/FloatingHighlight.lua.table";
		--UIAnimManager.PlayUIAnimationSequence(_highlight, _fileName, "Hide", false);
	--end
	_highlight.visible = false;
	_highlight.x = _icon.x + 40;
	
	if(Map3DSystem.UI.MainBar.IconSet[index].Type == "Panel") then
		
		Map3DSystem.UI.MainPanel.OnMouseLeaveIcon(index);
		
	elseif(Map3DSystem.UI.MainBar.IconSet[index].Type == "Button") then
	
		Map3DSystem.UI.MainBar.IconSet[index].MouseLeaveCallback();
	
	elseif(Map3DSystem.UI.MainBar.IconSet[index].Type == "Window") then
		
		Map3DSystem.UI.MainBar.IconSet[index].MouseLeaveCallback();
	end
end

function Map3DSystem.UI.MainBar.OnEnterMainBar()
	Map3DSystem.UI.MainBar.FadeInMainbarBG();
end

function Map3DSystem.UI.MainBar.OnLeaveMainBar()
	Map3DSystem.UI.MainBar.FadeOutMainbarBG();
end

function Map3DSystem.UI.MainBar.FadeInMainbarBG()

	local _bar = ParaUI.GetUIObject("MainBar_bar");
	local _left = _bar:GetChild("MainBar_bar_left_BG");
	local _middle = _bar:GetChild("MainBar_bar_middle_BG");
	local _right = _bar:GetChild("MainBar_bar_right_BG");
	local _slider = _bar:GetChild("MainBar_bar_bottomslider");
	_slider.visible = true;
	
	local _fileName = "script/UIAnimation/CommonBar.lua.table";
	--UIAnimManager.PlayUIAnimationSequence(_left, _fileName, "FadeIn", false);
	--UIAnimManager.PlayUIAnimationSequence(_middle, _fileName, "FadeIn", false);
	--UIAnimManager.PlayUIAnimationSequence(_right, _fileName, "FadeIn", false);
	UIAnimManager.PlayUIAnimationSequence(_slider, _fileName, "SliderFadeIn", false);
	
end

function Map3DSystem.UI.MainBar.FadeOutMainbarBG()

	local _bar = ParaUI.GetUIObject("MainBar_bar");
	local _left = _bar:GetChild("MainBar_bar_left_BG");
	local _middle = _bar:GetChild("MainBar_bar_middle_BG");
	local _right = _bar:GetChild("MainBar_bar_right_BG");
	local _slider = _bar:GetChild("MainBar_bar_bottomslider");
	_slider.visible = false;
	
	local _fileName = "script/UIAnimation/CommonBar.lua.table";
	--UIAnimManager.PlayUIAnimationSequence(_left, _fileName, "FadeOut", false);
	--UIAnimManager.PlayUIAnimationSequence(_middle, _fileName, "FadeOut", false);
	--UIAnimManager.PlayUIAnimationSequence(_right, _fileName, "FadeOut", false);
	UIAnimManager.PlayUIAnimationSequence(_slider, _fileName, "SliderFadeOut", false);
	
end

-- Set the main bar icon enable
function Map3DSystem.UI.MainBar.SetIconsEnable(enableTable)

	local iconNum = table.getn(Map3DSystem.UI.MainBar.IconSet);
	local _this;
	
	if(Map3DSystem.UI.MainPanel.CurrentActivePanelIndex == nil) then
		-- no panel is shown
	else
		-- hide panel
		local _panel = ParaUI.GetUIObject("MainBar_panel");
		local _panel_behind = ParaUI.GetUIObject("MainBar_panel_behindMainBarIcons");
		
		local index = Map3DSystem.UI.MainPanel.CurrentActivePanelIndex;
		Map3DSystem.UI.MainPanel.CurrentActivePanelIndex = nil;
		_panel.visible = false;
		_panel_behind.visible = false;
		if(Map3DSystem.UI.MainBar.IconSet[index].Type == "Panel") then
			Map3DSystem.UI.MainBar.IconSet[index].CloseUICallback();
		end
	end
	
	-- apply the enableTable
	for i = 1, iconNum do
		local _this = ParaUI.GetUIObject("MainBar_icons_"..i);
		_this.enabled = enableTable[i];
	end
end

-- Set the main bar status
function Map3DSystem.UI.MainBar.SwitchToStatus(status)
	
	local enableTable = {};
	
	if(status == "none") then
		enableTable[1] = true; -- creation
		enableTable[3] = false; -- modify
		enableTable[5] = false; -- property
		enableTable[8] = true; -- sky
		enableTable[9] = true; -- water
		enableTable[10] = true; -- terrain
		enableTable[6] = false; -- possession
		enableTable[4] = false; -- delete
		enableTable[12] = true; -- navigation mode
		enableTable[13] = true; -- chat
		enableTable[14] = true; -- map
		enableTable[15] = true; -- profile
		enableTable[16] = true; -- hints
		enableTable[17] = true; -- status
		enableTable[19] = true; -- menu
		enableTable[2] = true; -- separator
		enableTable[7] = true; -- separator
		enableTable[11] = true; -- separator
		enableTable[18] = true; -- separator
		Map3DSystem.UI.Creation.isBCSActive = false;
	elseif(status == "character") then
		enableTable[1] = true; -- creation
		enableTable[3] = true; -- modify
		enableTable[5] = true; -- property
		enableTable[8] = true; -- sky
		enableTable[9] = true; -- water
		enableTable[10] = true; -- terrain
		enableTable[6] = true; -- possession
		enableTable[4] = true; -- delete
		enableTable[12] = true; -- navigation mode
		enableTable[13] = true; -- chat
		enableTable[14] = true; -- map
		enableTable[15] = true; -- profile
		enableTable[16] = true; -- hints
		enableTable[17] = true; -- status
		enableTable[19] = true; -- menu
		enableTable[2] = true; -- separator
		enableTable[7] = true; -- separator
		enableTable[11] = true; -- separator
		enableTable[18] = true; -- separator
		Map3DSystem.UI.Creation.isBCSActive = false;
	elseif(status == "model") then
		enableTable[1] = true; -- creation
		enableTable[3] = true; -- modify
		
		local _obj = Map3DSystem.obj.GetObject("selection");
		if(_obj == nil or _obj:IsValid() == false) then
			return;
		end	
		local curBG = _obj:GetReplaceableTexture(1);
		if(curBG:IsValid()==false) then
			enableTable[5] = false; -- property
		else
			enableTable[5] = true; -- property
		end
		--enableTable[5] = false; -- property
		
		enableTable[8] = true; -- sky
		enableTable[9] = true; -- water
		enableTable[10] = true; -- terrain
		enableTable[6] = false; -- possession
		enableTable[4] = true; -- delete
		enableTable[12] = true; -- navigation mode
		enableTable[13] = true; -- chat
		enableTable[14] = true; -- map
		enableTable[15] = true; -- profile
		enableTable[16] = true; -- hints
		enableTable[17] = true; -- status
		enableTable[19] = true; -- menu
		enableTable[2] = true; -- separator
		enableTable[7] = true; -- separator
		enableTable[11] = true; -- separator
		enableTable[18] = true; -- separator
		Map3DSystem.UI.Creation.isBCSActive = false;
	elseif(status == "BCSXRef") then
		enableTable[1] = true; -- creation
		enableTable[3] = false; -- modify
		enableTable[5] = false; -- property
		enableTable[8] = true; -- sky
		enableTable[9] = true; -- water
		enableTable[10] = true; -- terrain
		enableTable[6] = false; -- possession
		enableTable[4] = true; -- delete
		enableTable[12] = true; -- navigation mode
		enableTable[13] = true; -- chat
		enableTable[14] = true; -- map
		enableTable[15] = true; -- profile
		enableTable[16] = true; -- hints
		enableTable[17] = true; -- status
		enableTable[19] = true; -- menu
		enableTable[2] = true; -- separator
		enableTable[7] = true; -- separator
		enableTable[11] = true; -- separator
		enableTable[18] = true; -- separator
		Map3DSystem.UI.Creation.isBCSActive = true;
	elseif(status == nil or status == "") then
		
		local selectObj = Map3DSystem.obj.GetObject("selection");
		
		if(selectObj ~= nil and selectObj:IsValid()) then
			if(selectObj:IsCharacter()) then
				-- character
				Map3DSystem.UI.MainBar.SwitchToStatus("character");
				return;
			else
				-- model
				Map3DSystem.UI.MainBar.SwitchToStatus("model");
				return;
			end
		else
			---- TODO: can be XRef object
			--if(false) then
				--Map3DSystem.UI.MainBar.SwitchToStatus("BCSXRef");
			--end
			-- none
			Map3DSystem.UI.MainBar.SwitchToStatus("none");
			return;
		end
	end
	
	local BCSMarkerGraph = ParaScene.GetMiniSceneGraph("BCSMarker");
	BCSMarkerGraph:Reset();
	
	Map3DSystem.UI.MainBar.SetIconsEnable(enableTable);
	
	Map3DSystem.UI.MainBar.Status = status;
end

-- switching navigation mode
-- true: switch to navmode, false switch back to edit mode
function Map3DSystem.UI.MainBar.SwitchNavigationMode(bNavMode)
	
	-- TODO: add more animation to navigation mode switching
	local i;
	for i = 1, 11 do
		Map3DSystem.UI.MainBar.IconSet[i].ShowIcon = not bNavMode;
	end
	
	-- redraw UI
	ParaUI.Destroy("MainBar_bar");
	Map3DSystem.UI.MainBar.InitUI();
	
	-- refresh the autotips position
	Map3DSystem.UI.Hints.RefreshPosition();
end



function Map3DSystem.UI.MainBar.TestToggle()

	local _btn = ParaUI.GetUIObject("btnAutoHideTest");
	
	Map3DSystem.UI.MainBar.autoHideToggle = not Map3DSystem.UI.MainBar.autoHideToggle;
	
	if(Map3DSystem.UI.MainBar.autoHideToggle) then
		_btn.text = "on";
	else
		_btn.text = "off";
	end
end

function Map3DSystem.UI.MainBar.TestEnter()

	if(Map3DSystem.UI.MainBar.autoHideToggle) then
		local _testAutoHide = ParaUI.GetUIObject("testautohide");
		_testAutoHide.y = 200;
		_testAutoHide.height = 200;
	end
end

function Map3DSystem.UI.MainBar.TestLeave()

	if(Map3DSystem.UI.MainBar.autoHideToggle) then
		local _testAutoHide = ParaUI.GetUIObject("testautohide");
		_testAutoHide.y = 300;
		_testAutoHide.height = 100;
		
	end
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting.
function Map3DSystem.UI.MainBar.ShowBar(bShow)

	local _left = Map3DSystem.UI.MainBar.AnimatableUIObjects.BarLeft;
	local _middle = Map3DSystem.UI.MainBar.AnimatableUIObjects.BarMiddle;
	local _right = Map3DSystem.UI.MainBar.AnimatableUIObjects.BarRight;
	
	if(_left:IsValid() == true and _middle:IsValid() == true and _right:IsValid() == true) then
		if(bShow == nil) then
			bShow = not _left.visible;
			bShow = not _middle.visible;
			bShow = not _right.visible;
		end
		_left.visible = bShow;
		_middle.visible = bShow;
		_right.visible = bShow;
	end
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting.
function Map3DSystem.UI.MainBar.ShowBarWithAnimation(bShow)
	local _seq = Map3DSystem.UI.MainBar.AnimationBarSequence;
	
	if(_seq.IsReady == false) then
		
		local _left = Map3DSystem.UI.MainBar.AnimatableUIObjects.BarLeft;
		local _middle = Map3DSystem.UI.MainBar.AnimatableUIObjects.BarMiddle;
		local _right = Map3DSystem.UI.MainBar.AnimatableUIObjects.BarRight;
		
		
		if(_left:IsValid() == true and _middle:IsValid() == true and _right:IsValid() == true) then
			
			if(bShow == _left.visible and bShow == _middle.visible and bShow == _right.visible) then
				return;
			end
			
			local _tobeShow = not _left.visible;
			
			_seq.FrameNum = 16;
			
			local _originalHeight = Map3DSystem.UI.MainBar.BarBGHeight;
			local _slice = _originalHeight / _seq.FrameNum;
			
			for i = 1, _seq.FrameNum - 1 do
				if(not _seq[i]) then _seq[i] = {} end
				if(not _seq[i].left) then _seq[i].left = {} end
				if(not _seq[i].middle) then _seq[i].middle = {} end
				if(not _seq[i].right) then _seq[i].right = {} end
				
				if(_tobeShow == true) then
					_seq[i].left.x = nil;
					_seq[i].left.y = _originalHeight - _slice*i;
					_seq[i].left.width = nil;
					_seq[i].left.height = _slice*i;
					_seq[i].left.alpha = nil;
					_seq[i].left.visible = true;
					_seq[i].left.enabled = nil;
					_seq[i].middle.x = nil;
					_seq[i].middle.y = _originalHeight - _slice*i;
					_seq[i].middle.width = nil;
					_seq[i].middle.height = _slice*i;
					_seq[i].middle.alpha = nil;
					_seq[i].middle.visible = true;
					_seq[i].middle.enabled = nil;
					_seq[i].right.x = nil;
					_seq[i].right.y = _originalHeight - _slice*i;
					_seq[i].right.width = nil;
					_seq[i].right.height = _slice*i;
					_seq[i].right.alpha = nil;
					_seq[i].right.visible = true;
					_seq[i].right.enabled = nil;
				else
					_seq[i].left.x = nil;
					_seq[i].left.y = _slice*i;
					_seq[i].left.width = nil;
					_seq[i].left.height = _originalHeight - _slice*i;
					_seq[i].left.alpha = nil;
					_seq[i].left.visible = true;
					_seq[i].left.enabled = nil;
					_seq[i].middle.x = nil;
					_seq[i].middle.y = _slice*i;
					_seq[i].middle.width = nil;
					_seq[i].middle.height = _originalHeight - _slice*i;
					_seq[i].middle.alpha = nil;
					_seq[i].middle.visible = true;
					_seq[i].middle.enabled = nil;
					_seq[i].right.x = nil;
					_seq[i].right.y = _slice*i;
					_seq[i].right.width = nil;
					_seq[i].right.height = _originalHeight - _slice*i;
					_seq[i].right.alpha = nil;
					_seq[i].right.visible = true;
					_seq[i].right.enabled = nil;
				end
			end -- for i = 1, _seq.FrameNum - 1 do
			
			if(not _seq[_seq.FrameNum]) then _seq[_seq.FrameNum] = {} end
			if(not _seq[_seq.FrameNum].left) then _seq[_seq.FrameNum].left = {} end
			_seq[_seq.FrameNum].left.x = nil;
			_seq[_seq.FrameNum].left.y = 0;
			_seq[_seq.FrameNum].left.width = nil;
			_seq[_seq.FrameNum].left.height = _originalHeight;
			_seq[_seq.FrameNum].left.alpha = nil;
			_seq[_seq.FrameNum].left.visible = nil;
			_seq[_seq.FrameNum].left.enabled = nil;
			if(not _seq[_seq.FrameNum].middle) then _seq[_seq.FrameNum].middle = {} end
			_seq[_seq.FrameNum].middle.x = nil;
			_seq[_seq.FrameNum].middle.y = 0;
			_seq[_seq.FrameNum].middle.width = nil;
			_seq[_seq.FrameNum].middle.height = _originalHeight;
			_seq[_seq.FrameNum].middle.alpha = nil;
			_seq[_seq.FrameNum].middle.visible = nil;
			_seq[_seq.FrameNum].middle.enabled = nil;
			if(not _seq[_seq.FrameNum].right) then _seq[_seq.FrameNum].right = {} end
			_seq[_seq.FrameNum].right.x = nil;
			_seq[_seq.FrameNum].right.y = 0;
			_seq[_seq.FrameNum].right.width = nil;
			_seq[_seq.FrameNum].right.height = _originalHeight;
			_seq[_seq.FrameNum].right.alpha = nil;
			_seq[_seq.FrameNum].right.visible = nil;
			_seq[_seq.FrameNum].right.enabled = nil;
				
			if(bShow == nil) then
				bShow = not _left.visible;
				bShow = not _middle.visible;
				bShow = not _right.visible;
			end
			_seq[_seq.FrameNum].left.visible = bShow;
			_seq[_seq.FrameNum].middle.visible = bShow;
			_seq[_seq.FrameNum].right.visible = bShow;
				
			_seq.CurrentFrame = 1;
			_seq.IsReady = true;
			
		end
		
	end
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting.
function Map3DSystem.UI.MainBar.ShowAllBarIcons(bShow)
	
	local iconNum = table.getn(Map3DSystem.UI.MainBar.IconSet);
	local _this = Map3DSystem.UI.MainBar.AnimatableUIObjects.IconSet[iconNum];
	if(_this:IsValid() == true) then
		local _icon;
		local i;
		log(""..iconNum.."\r\n");
		for i = 1, iconNum do
			_icon = Map3DSystem.UI.MainBar.AnimatableUIObjects.IconSet[i];
			if(bShow == nil) then
				bShow = not _icon.visible;
			end
			_icon.visible = bShow;
		end
	end
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting.
function Map3DSystem.UI.MainBar.ShowBarIcon(index, bShow)

	local _this = Map3DSystem.UI.MainBar.AnimatableUIObjects.IconSet[index];
	if(_this:IsValid() == true) then
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		_this.visible = bShow;
	end
	
	Map3DSystem.UI.MainBar.RefreshMainBar()
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting.
function Map3DSystem.UI.MainBar.ShowBarIconWithAnimation(index, bShow, style, frameNum)

	local _seq = Map3DSystem.UI.MainBar.AnimationIconSetSequence;
	if(_seq["IconSet"..index].IsReady == true) then
		Map3DSystem.UI.MainBar.ShowBarIcon(index, bShow);
		return;
	end
	
	local _this;
	local _style = style;
	
	local iconNum = table.getn(Map3DSystem.UI.MainBar.IconSet);
	local iconWidth = 0;
	
	for i = 1, index do
		_this = Map3DSystem.UI.MainBar.AnimatableUIObjects.IconSet[i];
		if(_this.visible == true) then
			if(Map3DSystem.UI.MainBar.IconSet[i].Type == "Separator") then
				iconWidth = iconWidth + Map3DSystem.UI.MainBar.SeparatorWidth;
			else
				iconWidth = iconWidth + Map3DSystem.UI.MainBar.IconSize;
			end
		end
	end
	
	_this = Map3DSystem.UI.MainBar.AnimatableUIObjects.IconSet[index];
	local x, y, width, height = _this:GetAbsPosition();
	
	local iconWidth;
	local iconHeight;
	local multiplierX;
	local multiplierY;
	local multiplierWidth;
	local multiplierHeight;
	
	if(Map3DSystem.UI.MainBar.IconSet[index].Type == "Separator") then
		iconWidth = Map3DSystem.UI.MainBar.SeparatorWidth;
		iconHeight = Map3DSystem.UI.MainBar.IconSize;
		multiplierX = Map3DSystem.UI.MainBar.SeparatorWidth / (frameNum * 2);
		multiplierY = Map3DSystem.UI.MainBar.IconSize / (frameNum * 2);
		multiplierWidth = Map3DSystem.UI.MainBar.SeparatorWidth / (frameNum * 2);
		multiplierHeight = Map3DSystem.UI.MainBar.IconSize / (frameNum * 2);
	else
		iconWidth = Map3DSystem.UI.MainBar.IconSize;
		iconHeight = Map3DSystem.UI.MainBar.IconSize;
		multiplierX = Map3DSystem.UI.MainBar.IconSize / (frameNum * 2);
		multiplierY = Map3DSystem.UI.MainBar.IconSize / (frameNum * 2);
		multiplierWidth = Map3DSystem.UI.MainBar.IconSize / (frameNum * 2);
		multiplierHeight = Map3DSystem.UI.MainBar.IconSize / (frameNum * 2);
	end
	
	_seq["IconSet"..index].FrameNum = frameNum;
	for i = 1, frameNum - 1 do
		_seq["IconSet"..index][i].x = x + _style.HideOut.x[i] * multiplierX;
		_seq["IconSet"..index][i].y = _style.HideOut.y[i] * multiplierY;
		_seq["IconSet"..index][i].width = _style.HideOut.width[i] * multiplierWidth;
		_seq["IconSet"..index][i].height = _style.HideOut.height[i] * multiplierHeight;
		_seq["IconSet"..index][i].alpha = _style.HideOut.alpha[i];
		_seq["IconSet"..index][i].visible = true;
		_seq["IconSet"..index][i].enabled = nil;
	end
	
	_seq["IconSet"..index][frameNum].x = x + _style.HideOut.x[i] * multiplierX;
	_seq["IconSet"..index][frameNum].y = y;
	_seq["IconSet"..index][frameNum].width = width;
	_seq["IconSet"..index][frameNum].height = height;
	_seq["IconSet"..index][frameNum].alpha = 200;
	_seq["IconSet"..index][frameNum].visible = false;
	_seq["IconSet"..index][frameNum].enabled = nil;
		
	_seq["IconSet"..index].CurrentFrame = 1;
	_seq["IconSet"..index].IsReady = true;
	
end

function Map3DSystem.UI.MainBar.RefreshMainBar()

	local barAdd = Map3DSystem.UI.MainBar.BarBGWidthAdditional;
	local _this;
	local iconNum = table.getn(Map3DSystem.UI.MainBar.IconSet);
	local iconWidth = 0;
	
	for i = 1, iconNum do
		_this = Map3DSystem.UI.MainBar.AnimatableUIObjects.IconSet[i];
		_this.x = iconWidth;
		if(_this.visible == true) then
			if(Map3DSystem.UI.MainBar.IconSet[i].Type == "Separator") then
				iconWidth = iconWidth + Map3DSystem.UI.MainBar.SeparatorWidth;
			else
				iconWidth = iconWidth + Map3DSystem.UI.MainBar.IconSize;
			end
		end
	end
	
	local barWidth = iconWidth + barAdd * 2;
	
	local _bar = ParaUI.GetUIObject("MainBar_bar");
	
	if( _bar.width == barWidth ) then
		return;
	else
		_bar.width = barWidth;
		local _middle = _bar:GetChild("MainBar_bar_middle_BG");
		_middle.width = barWidth - 256;
	end
	
end

function Map3DSystem.UI.MainBar.RefreshMainBarWithAnimation()
	
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting.
function Map3DSystem.UI.MainBar.ShowAllBarIconsWithAnimation(bShow, style, frameNum)

	local _seq = Map3DSystem.UI.MainBar.AnimationIconSetSequence;
	
	local iconNum = table.getn(Map3DSystem.UI.MainBar.IconSet);
	
	local _this;
	
	local _style = style;
	
	local iconUINum = table.getn(Map3DSystem.UI.MainBar.AnimatableUIObjects.IconSet);
	local anyInValid = false;
	for i = 1, iconUINum do
		_this = Map3DSystem.UI.MainBar.AnimatableUIObjects.IconSet[i];
		if(_this:IsValid() == false) then
			anyInValid = true;
		end
	end
	if(iconNum ~= iconUINum) then
		anyInValid = true;
	end
	
	if(anyInValid == false) then
		
		local anyDifference = false;
		local i;
		for i = 1, iconNum do
			if(bShow ~= Map3DSystem.UI.MainBar.AnimatableUIObjects.IconSet[i].visible) then
				anyDifference = true;
			end
		end
		if(anyDifference == false) then
			return;
		end
		
		local _totalWidth = 0;
		local _height;
			
		for i = 1, iconNum do
			
			if(not _seq["IconSet"..i]) then
				_seq["IconSet"..i] = {}
				_seq["IconSet"..i].IsReady = false;
			end
			
			if(_seq["IconSet"..i].IsReady == false) then
			
				_seq["IconSet"..i].FrameNum = frameNum;
				
				local _frameNum = _seq["IconSet"..i].FrameNum;
				
				_this = Map3DSystem.UI.MainBar.AnimatableUIObjects.IconSet[i];
				_tobeShow = not _this.visible;
				
				local iconWidth;
				local iconHeight;
				local multiplierX;
				local multiplierY;
				local multiplierWidth;
				local multiplierHeight;
				
				if(Map3DSystem.UI.MainBar.IconSet[i].Type == "Separator") then
					iconWidth = Map3DSystem.UI.MainBar.SeparatorWidth;
					iconHeight = Map3DSystem.UI.MainBar.IconSize;
					multiplierX = Map3DSystem.UI.MainBar.SeparatorWidth / (_frameNum * 2);
					multiplierY = Map3DSystem.UI.MainBar.IconSize / (_frameNum * 2);
					multiplierWidth = Map3DSystem.UI.MainBar.SeparatorWidth / (_frameNum * 2);
					multiplierHeight = Map3DSystem.UI.MainBar.IconSize / (_frameNum * 2);
				else
					iconWidth = Map3DSystem.UI.MainBar.IconSize;
					iconHeight = Map3DSystem.UI.MainBar.IconSize;
					multiplierX = Map3DSystem.UI.MainBar.IconSize / (_frameNum * 2);
					multiplierY = Map3DSystem.UI.MainBar.IconSize / (_frameNum * 2);
					multiplierWidth = Map3DSystem.UI.MainBar.IconSize / (_frameNum * 2);
					multiplierHeight = Map3DSystem.UI.MainBar.IconSize / (_frameNum * 2);
				end
				
				_totalWidth = _totalWidth + iconWidth;
				_height = iconHeight;
				
				local j;
				
				for j = 1, _frameNum - 1 do
					
					if(not _seq["IconSet"..i][j]) then _seq["IconSet"..i][j] = {} end
					
					
					if(_tobeShow == true) then
						_seq["IconSet"..i][j].x = _totalWidth - iconWidth + _style.ShowIn.x[j] * multiplierX;
						_seq["IconSet"..i][j].y = _style.ShowIn.y[j] * multiplierY;
						_seq["IconSet"..i][j].width = _style.ShowIn.width[j] * multiplierWidth;
						_seq["IconSet"..i][j].height = _style.ShowIn.height[j] * multiplierHeight;
						_seq["IconSet"..i][j].alpha = _style.ShowIn.alpha[j];
						_seq["IconSet"..i][j].visible = true;
						_seq["IconSet"..i][j].enabled = nil;
					else
						_seq["IconSet"..i][j].x = _totalWidth - iconWidth + _style.HideOut.x[j] * multiplierX;
						_seq["IconSet"..i][j].y = _style.HideOut.y[j] * multiplierY;
						_seq["IconSet"..i][j].width = _style.HideOut.width[j] * multiplierWidth;
						_seq["IconSet"..i][j].height = _style.HideOut.height[j] * multiplierHeight;
						_seq["IconSet"..i][j].alpha = _style.HideOut.alpha[j];
						_seq["IconSet"..i][j].visible = true;
						_seq["IconSet"..i][j].enabled = nil;
					end
					
				end -- for j = 1, _frameNum - 1 do
				
				if(not _seq["IconSet"..i][_frameNum]) then
					_seq["IconSet"..i][_frameNum] = {}
				end
				
				_seq["IconSet"..i][_frameNum].x = _totalWidth - iconWidth;
				_seq["IconSet"..i][_frameNum].y = 0;
				_seq["IconSet"..i][_frameNum].width = iconWidth;
				_seq["IconSet"..i][_frameNum].height = iconHeight;
				_seq["IconSet"..i][_frameNum].alpha = nil;
				_seq["IconSet"..i][_frameNum].visible = true;
				_seq["IconSet"..i][_frameNum].enabled = nil;
				
				if(bShow == nil) then
					bShow = not _this.visible;
				end
				_seq["IconSet"..i][_frameNum].visible = bShow;
				
				
				_seq["IconSet"..i].CurrentFrame = 1;
				_seq["IconSet"..i].IsReady = true;
				
			end --if(_seq["IconSet"..i].IsReady == false) then
			
		end -- for i = 1, iconNum do
		
	end -- if(anyInValid == false) then
		
	--Map3DSystem.Misc.SaveTableToFile(_seq, "TestTable/Seq.ini");
end

function Map3DSystem.UI.MainBar.DoAnimateBarIcon()
	
	local _seq = Map3DSystem.UI.MainBar.AnimationIconSetSequence;
	
	local iconNum = table.getn(Map3DSystem.UI.MainBar.IconSet);
	
	for i = 1, iconNum do
	
		if(not _seq["IconSet"..i]) then
			_seq["IconSet"..i] = {};
			_seq["IconSet"..i].IsReady = false;
		end
			
		if(_seq["IconSet"..i].IsReady == true) then
			local _this = Map3DSystem.UI.MainBar.AnimatableUIObjects.IconSet[i];
			
			if(_this:IsValid() == true) then
			
				local _frame = _seq["IconSet"..i][_seq["IconSet"..i].CurrentFrame];
				
				if(_frame.x ~= nil) then _this.x = _frame.x; end
				if(_frame.y ~= nil) then _this.y = _frame.y; end
				if(_frame.width ~= nil) then _this.width = _frame.width; end
				if(_frame.height ~= nil) then _this.height = _frame.height; end
				if(_frame.visible ~= nil) then _this.visible = _frame.visible; end
				if(_frame.enabled ~= nil) then _this.enabled = _frame.enabled; end
				if(_frame.alpha ~= nil) then
					local _tex = _this:GetTexture("background");
					_tex.transparency = _frame.alpha;
				end
				
				if(_seq["IconSet"..i].CurrentFrame ~= _seq["IconSet"..i].FrameNum) then
					_seq["IconSet"..i].CurrentFrame = _seq["IconSet"..i].CurrentFrame + 1;
				else
					_seq["IconSet"..i].IsReady = false;
				end
			
			end
		end
	end
	
	
end

function Map3DSystem.UI.MainBar.DoAnimateBar()

	local _seq = Map3DSystem.UI.MainBar.AnimationBarSequence;
	
	if(_seq.IsReady == true) then
	
		local _left = Map3DSystem.UI.MainBar.AnimatableUIObjects.BarLeft;
		local _middle = Map3DSystem.UI.MainBar.AnimatableUIObjects.BarMiddle;
		local _right = Map3DSystem.UI.MainBar.AnimatableUIObjects.BarRight;
		
		
		if(_left:IsValid() == true and _middle:IsValid() == true and _right:IsValid() == true) then
			
			local _frame = _seq[_seq.CurrentFrame];
	
			if(_frame.left.visible ~= nil) then _left.visible = _frame.left.visible; end
			if(_frame.left.enabled ~= nil) then _left.enabled = _frame.left.enabled; end
			if(_frame.left.x ~= nil) then _left.x = _frame.left.x; end
			if(_frame.left.y ~= nil) then _left.y = _frame.left.y; end
			if(_frame.left.width ~= nil) then _left.width = _frame.left.width; end
			if(_frame.left.height ~= nil) then _left.height = _frame.left.height; end
			if(_frame.left.alpha ~= nil) then
				local _tex = _left:GetTexture("background");
				_tex.transparency = _frame.left.alpha;
			end
			if(_frame.middle.visible ~= nil) then _middle.visible = _frame.middle.visible; end
			if(_frame.middle.enabled ~= nil) then _middle.enabled = _frame.middle.enabled; end
			if(_frame.middle.x ~= nil) then _middle.x = _frame.middle.x; end
			if(_frame.middle.y ~= nil) then _middle.y = _frame.middle.y; end
			if(_frame.middle.width ~= nil) then _middle.width = _frame.middle.width; end
			if(_frame.middle.height ~= nil) then _middle.height = _frame.middle.height; end
			if(_frame.middle.alpha ~= nil) then
				local _tex = _middle:GetTexture("background");
				_tex.transparency = _frame.middle.alpha;
			end
			if(_frame.right.visible ~= nil) then _right.visible = _frame.right.visible; end
			if(_frame.right.enabled ~= nil) then _right.enabled = _frame.right.enabled; end
			if(_frame.right.x ~= nil) then _right.x = _frame.right.x; end
			if(_frame.right.y ~= nil) then _right.y = _frame.right.y; end
			if(_frame.right.width ~= nil) then _right.width = _frame.right.width; end
			if(_frame.right.height ~= nil) then _right.height = _frame.right.height; end
			if(_frame.right.alpha ~= nil) then
				local _tex = _right:GetTexture("background");
				_tex.transparency = _frame.right.alpha;
			end
			
			if(_seq.CurrentFrame ~= _seq.FrameNum) then
				_seq.CurrentFrame = _seq.CurrentFrame + 1;
			else
				_seq.IsReady = false;
			end
		end
	end


	
end
