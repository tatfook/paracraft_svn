--[[
Title: Status in main bar for 3D Map system
Author(s): WangTian
Date: 2007/9/18
Desc: Show the Status window in game UI
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Status.lua");
------------------------------------------------------------
Note: for all main bar function icon:
"(gl)script/kids/3DMapSystemData/TableDef.lua": 
		TableTable defination
"(gl)script/kids/3DMapSystemData/MainBarData.lua": 
		Register the show UI and close UI callback function
]]

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

local L = CommonCtrl.Locale("Kids3DMap");

function Map3DSystem.UI.Status.OnClick()
	Map3DSystem.UI.Status.IsShow = not Map3DSystem.UI.Status.IsShow;
	if(Map3DSystem.UI.Status.IsShow) then
		Map3DSystem.UI.Status.ShowWnd()
	else
		Map3DSystem.UI.Status.CloseWnd()
	end
end

function Map3DSystem.UI.Status.ShowWnd()

	local _wnd = ParaUI.GetUIObject("Status_window");
	
	if(_wnd:IsValid() == false) then
		-- creation sub panel for the first run
		local _wnd = ParaUI.CreateUIObject("container", "Status_window", "_lt", 100, 100, 400, 249);
		_wnd:AttachToRoot();
		-- test button
		local _temp = ParaUI.CreateUIObject("button", "testButton", "_lt", 50, 50, 128, 32);
		_temp.text = "Status";
		_wnd:AddChild(_temp);
	else
		-- show Status window
		_wnd.visible = true;
	end
end

function Map3DSystem.UI.Status.CloseWnd()
	
	local _wnd = ParaUI.GetUIObject("Status_window");
	
	if(_wnd:IsValid() == false) then
		log("Status window container is not yet initialized.\r\n");
	else
		-- show creation sub panel
		_wnd.visible = false;
	end
end
