--[[
Title: Delete in main bar for 3D Map system
Author(s): WangTian, LiXizhi
Date: 2007/9/18
Desc: delete function
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/Delete.lua");
------------------------------------------------------------
Note: for all main bar function icon:
"(gl)script/kids/3DMapSystemData/TableDef.lua": 
		TableTable defination
"(gl)script/kids/3DMapSystemData/MainBarData.lua": 
		Register the onclick callback function
]]

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

local L = CommonCtrl.Locale("Kids3DMap");

function Map3DSystem.UI.Delete.OnClick()
	-- delete the object on BCSXRef
	if(Map3DSystem.UI.Creation.isBCSActive == true) then
		local obj = ParaScene.GetObject(
				Map3DSystem.UI.Creation.CurrentMarkerPosX, 
				Map3DSystem.UI.Creation.CurrentMarkerPosY, 
				Map3DSystem.UI.Creation.CurrentMarkerPosZ);
				
		if(obj:IsValid() == true) then
			Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeleteObject, obj = obj});
		end
		return;
	end
	
	-- delete the current selection
	local curObj = Map3DSystem.obj.GetObject("selection");
	if(curObj~=nil) then
		if(curObj:IsCharacter()) then
			-- ask user for confirmation
			_guihelper.MessageBox("您确定要删除当前选择的人物么?", Map3DSystem.UI.Delete.OnDeleteSelectionImmediate);
		else
			-- delete immediately for message object
			Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeleteObject, obj = curObj});
		end
	end	
end

function Map3DSystem.UI.Delete.OnDeleteSelectionImmediate()
	local curObj = Map3DSystem.obj.GetObject("selection");
	if(curObj~=nil) then
		Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeleteObject, obj = curObj});
	end
end


function Map3DSystem.UI.Delete.InitMessageSystem(app, mainWndName)

	Map3DSystem.UI.Modify.WndObject = app:RegisterWindow(
		"DeleteWnd", mainWndName, Map3DSystem.UI.Modify.MSGProc);
	
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
				local _item = Map3DSystem.UI.MainBar.GetItemUIContainer("apps", "Creator.Delete");
				
				if(_item == nil) then
					return;
				end
				if(msg.status == "none") then
					_item.enabled = false;
					local nCount = _item:GetChildCount();
					for i = 0, nCount - 1 do
						local _ui = _item:GetChildAt(i);
						_ui.enabled = false;
					end
				elseif(msg.status == "model" or msg.status == "character" or msg.status == "BCSXRef") then
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
		hookName = "DeleteChangeStatusHook", appName = "MainBar", wndName = "MainBarWnd"});
end

function Map3DSystem.UI.Delete.OnMouseEnter()
end

function Map3DSystem.UI.Delete.OnMouseLeave()
end