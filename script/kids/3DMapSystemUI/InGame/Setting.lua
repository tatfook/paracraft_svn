--[[
Title: Setting in main bar for 3D Map system
Author(s): WangTian
Date: 2007/9/18
Desc: Show the Setting window in game UI
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Setting.lua");
------------------------------------------------------------
Note: for all main bar function icon:
"(gl)script/kids/3DMapSystemData/TableDef.lua": 
		TableTable defination
"(gl)script/kids/3DMapSystemData/MainBarData.lua": 
		Register the show UI and close UI callback function
]]

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

local L = CommonCtrl.Locale("Kids3DMap");

function Map3DSystem.UI.Setting.OnClick()

	NPL.load("(gl)script/test/TestTreeView.lua");
	TestTreeView();
--
	--Map3DSystem.UI.Setting.IsShow = not Map3DSystem.UI.Setting.IsShow;
	--if(Map3DSystem.UI.Setting.IsShow) then
		--Map3DSystem.UI.Setting.ShowWnd()
	--else
		--Map3DSystem.UI.Setting.CloseWnd()
	--end
end

function Map3DSystem.UI.Setting.ShowWnd()

	local _wnd = ParaUI.GetUIObject("Setting_window");
	
	if(_wnd:IsValid() == false) then
		-- creation sub panel for the first run
		local _wnd = ParaUI.CreateUIObject("container", "Setting_window", "_lt", 100, 100, 400, 249);
		_wnd:AttachToRoot();
		-- test button
		local _temp = ParaUI.CreateUIObject("button", "testButton", "_lt", 50, 50, 128, 32);
		_temp.text = "Setting";
		_wnd:AddChild(_temp);
	else
		-- show Setting window
		_wnd.visible = true;
	end
end

function Map3DSystem.UI.Setting.CloseWnd()
	
	local _wnd = ParaUI.GetUIObject("Setting_window");
	
	if(_wnd:IsValid() == false) then
		log("Setting window container is not yet initialized.\r\n");
	else
		-- show creation sub panel
		_wnd.visible = false;
	end
end
