--[[
Title: Possession in main bar for 3D Map system
Author(s): WangTian
Date: 2007/9/18
Desc: Possession function
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Possession.lua");
------------------------------------------------------------
Note: for all main bar function icon:
"(gl)script/kids/3DMapSystemData/TableDef.lua": 
		TableTable defination
"(gl)script/kids/3DMapSystemData/MainBarData.lua": 
		Register the onclick callback function
]]

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

local L = CommonCtrl.Locale("Kids3DMap");

function Map3DSystem.UI.Possession.OnClick()

	CommonCtrl.CKidLeftContainer.OnSwitchToObject();
	
end


function Map3DSystem.UI.Possession.InitMessageSystem(app, mainWndName)

	Map3DSystem.UI.Modify.WndObject = app:RegisterWindow(
		"PossessionWnd", mainWndName, Map3DSystem.UI.Modify.MSGProc);
	
	-- !TODO: unhook the status change hook
	
	-- hook into the "mouse_move" window in "input" application, and detect the mouse to 
	-- translate the object icon position
	CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC, 
		callback = function(nCode, appName, msg)
			-- return the nCode to be passed to the next hook procedure in the hook chain. 
			-- in most cases, if nCode is nil, the hook procedure should do nothing. 
			if(nCode == nil) then return end
			-- TODO: do your code here
			if(msg.status ~= nil) then
				--_guihelper.MessageBox("change to status: "..msg.status.."\n");
				local _item = Map3DSystem.UI.MainBar.GetItemUIContainer("apps", "Creator.Possession");
				
				if(_item == nil) then
					return;
				end
				if(msg.status == "BCSXRef" or msg.status == "none" or msg.status == "model") then
					_item.enabled = false;
					local nCount = _item:GetChildCount();
					for i = 0, nCount - 1 do
						local _ui = _item:GetChildAt(i);
						_ui.enabled = false;
					end
				elseif(msg.status == "character") then
					_item.enabled = true;
					local nCount = _item:GetChildCount();
					for i = 0, nCount - 1 do
						local _ui = _item:GetChildAt(i);
						_ui.enabled = true;
					end
				end
			end
			return nCode;
		end, 
		hookName = "PossessionChangeStatusHook", appName = "MainBar", wndName = "MainBarWnd"});
end

function Map3DSystem.UI.Possession.OnMouseEnter()
end

function Map3DSystem.UI.Possession.OnMouseLeave()
end