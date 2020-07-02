--[[
Title: Hints in main bar for 3D Map system
Author(s): WangTian
Date: 2007/9/18
Desc: Show the Hints window in game UI
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Hints.lua");
------------------------------------------------------------
Note: for all main bar function icon:
"(gl)script/kids/3DMapSystemData/TableDef.lua": 
		TableTable defination
"(gl)script/kids/3DMapSystemData/MainBarData.lua": 
		Register the show UI and close UI callback function
]]

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

local L = CommonCtrl.Locale("Kids3DMap");

function Map3DSystem.UI.Hints.OnClick()
	Map3DSystem.UI.Hints.IsShow = not Map3DSystem.UI.Hints.IsShow;
	
	if(mouse_button == "left") then
		if(Map3DSystem.UI.Hints.IsShow) then
			Map3DSystem.UI.Hints.ShowWnd();
		else
			Map3DSystem.UI.Hints.CloseWnd();
		end
	elseif(mouse_button == "right") then
		local _quickLaunch = ParaUI.GetUIObject("CreationQuickLaunchBar");
		if(_quickLaunch:IsValid() == true) then
			_quickLaunch.visible = not _quickLaunch.visible;
		end
		local _quickLaunchAnimation = ParaUI.GetUIObject("AnimationQuickLaunchBar");
		if(_quickLaunchAnimation:IsValid() == true) then
			_quickLaunchAnimation.visible = not _quickLaunchAnimation.visible;
		end
	end
end

function Map3DSystem.UI.Hints.MSGProc(window, msg)
end

-- autotips: autotips window handler
function Map3DSystem.UI.Hints.MSGProc(window, msg)
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		-- on size, solely the main bar onsize
		Map3DSystem.UI.Hints.RefreshPosition();
	end
end

-- init message system: call this function at main bar initialization to init the message system for autotips
function Map3DSystem.UI.Hints.InitMessageSystem()
	local _app = CommonCtrl.os.CreateGetApp("Autotips");
	Map3DSystem.UI.Hints.App = _app;
	Map3DSystem.UI.Hints.MainWnd = _app:RegisterWindow("AutotipsWnd", nil, Map3DSystem.UI.Hints.MSGProc);
end

-- send a message to Autotips:AutotipsWnd window handler
-- e.g. Map3DSystem.UI.Hints.SendMeMessage({type = Map3DSystem.msg.***})
function Map3DSystem.UI.Hints.SendMeMessage(msg)
	msg.wndName = Map3DSystem.UI.Hints.MainWnd.name;
	Map3DSystem.UI.Hints.App:SendMessage(msg);
end

function Map3DSystem.UI.Hints.InitUI()
	NPL.load("(gl)script/kids/3DMapSystemUI/InGame/autotips.lua");
	autotips.Show();
	Map3DSystem.UI.Hints.RefreshPosition();
end

function Map3DSystem.UI.Hints.RefreshPosition()
	local _icon = ParaUI.GetUIObject("MainBar_icons_16");
	local _x = _icon:GetAbsPosition();
	local _autotip = ParaUI.GetUIObject("autotips_cont");
	_autotip.y = - Map3DSystem.UI.MainBar.IconSize - Map3DSystem.UI.MainBar.IconHeightOffset;
	_autotip.height = - Map3DSystem.UI.MainBar.IconSize - Map3DSystem.UI.MainBar.IconHeightOffset;
	_autotip.x = _x - 120;
end

function Map3DSystem.UI.Hints.ShowWnd()
	
	NPL.load("(gl)script/kids/3DMapSystemUI/InGame/autotips.lua");
	autotips.Show(true);
	Map3DSystem.UI.Hints.RefreshPosition();
	
	local _icon = ParaUI.GetUIObject("MainBar_icons_16");
	_icon.background = "Texture/3DMapSystem/MainBarIcon/TipsOn.png; 0 0 48 48";
	Map3DSystem.UI.MainBar.IconSet[16].NormalIconPath = "Texture/3DMapSystem/MainBarIcon/TipsOn.png; 0 0 48 48";
	

	--local _wnd = ParaUI.GetUIObject("Hints_window");
	--
	--if(_wnd:IsValid() == false) then
		---- creation sub panel for the first run
		--local _wnd = ParaUI.CreateUIObject("container", "Hints_window", "_lt", 100, 100, 400, 249);
		--_wnd:AttachToRoot();
		--
		--local _this = ParaUI.CreateUIObject("text", "Hints_window", "_lt", 0, 0, 200, 50);
		--_this.text = "any text here"
		--local width, height = _this:GetTextLineSize();
		--_guihelper.MessageBox(string.format("%d, %d is size\n", width, height));
		--_wnd:AddChild(_this);
		--
		---- test button
		--local _temp = ParaUI.CreateUIObject("button", "testButton", "_lt", 50, 50, 128, 32);
		--_temp.text = "Hints";
		--_wnd:AddChild(_temp);
		--
		--
	--else
		---- show Hints window
		--_wnd.visible = true;
	--end
end

function Map3DSystem.UI.Hints.CloseWnd()
	
	NPL.load("(gl)script/kids/3DMapSystemUI/InGame/autotips.lua");
	autotips.Show(false);
	
	local _icon = ParaUI.GetUIObject("MainBar_icons_16");
	_icon.background = "Texture/3DMapSystem/MainBarIcon/TipsOff.png; 0 0 48 48";
	Map3DSystem.UI.MainBar.IconSet[16].NormalIconPath = "Texture/3DMapSystem/MainBarIcon/TipsOff.png; 0 0 48 48";
	
	--local _wnd = ParaUI.GetUIObject("Hints_window");
	--
	--if(_wnd:IsValid() == false) then
		--log("Hints window container is not yet initialized.\r\n");
	--else
		---- show creation sub panel
		--_wnd.visible = false;
	--end
end

function Map3DSystem.UI.Hints.OnMouseEnter()
end

function Map3DSystem.UI.Hints.OnMouseLeave()
end