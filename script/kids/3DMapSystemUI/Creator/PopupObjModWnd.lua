--[[
Title: Popup Obj modify window
Author(s): LiXizhi
Date: 2008/6/14
Desc: The UI is on mcml page PopupObjModPage.html
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Creator/PopupObjModWnd.lua");
Map3DSystem.UI.Creator.PopupModWnd.ShowPopupEdit(obj_params)
------------------------------------------------------------
]]

NPL.load("(gl)script/ide/mathlib.lua");

local PopupModWnd = {};
commonlib.setfield("Map3DSystem.UI.Creator.PopupModWnd", PopupModWnd);

---------------------------------------------------
-- show a top level popup window for a mouse cursor 3D mesh object
---------------------------------------------------
PopupModWnd.Name = "PopupEdit";
-- function(bIsCancel) or string, -- function to call when edit window closes.
PopupModWnd.PopupEditor_onclose = nil;

-- @param obj_params: a valid object params. More info see objeditor.lua
-- @param x,y: position at which to display the window
-- @param onclose: function(bIsCancel) or string, -- function to call when edit window closes.
function PopupModWnd.ShowPopupEdit(obj_params, x, y, onclose)
	if(not obj_params) then
		return
	end
	
	PopupModWnd.popupedit_obj_params = obj_params;
	PopupModWnd.PopupEditor_onclose = onclose;
	x = x or mouse_x or 100;
	y = y or mouse_y or 100;
	-- TODO: ensure x,y is inside window area. 
	local _this,_parent;
	_this=ParaUI.GetUIObject(PopupModWnd.Name);
	
	if(_this:IsValid() == false) then
		
		_this = ParaUI.CreateUIObject("container", PopupModWnd.Name, "_lt", x, y, 190, 130)
		_this.background = "Texture/3DMapSystem/Desktop/ExtensionMenu.png:8 8 8 8";
		_this:AttachToRoot();
		_this.onmouseup=";Map3DSystem.UI.Creator.PopupModWnd.OnMouseUp();";
		_parent = _this;
		
		if(PopupModWnd.MyPage == nil) then
			PopupModWnd.MyPage = Map3DSystem.mcml.PageCtrl:new({url="script/kids/3DMapSystemUI/Creator/PopupObjModPage.html"});
		end	
		PopupModWnd.MyPage:Create("PopupObjModPage", _parent, "_fi", 0, 0, 0, 0)
		_this = _parent;
	else
		_this.x = x;
		_this.y = y;
	end
	
	-- Update Value
	if(obj_params.rotation~=nil) then
		local heading, attitude, bank = mathlib.QuatToEuler(obj_params.rotation);
		
		PopupModWnd.MyPage:SetUIValue("rot_x", heading);
		PopupModWnd.MyPage:SetUIValue("rot_y", attitude);
		PopupModWnd.MyPage:SetUIValue("rot_z", bank);
	end	
	PopupModWnd.MyPage:SetUIValue("scale", 0);
	
	_this.visible = true;
	_this:SetTopLevel(true);
	CommonCtrl.WindowFrame.MoveContainerInScreenArea(_this);
end


function PopupModWnd.OnClickReset()
	Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_MoveCursorObject, reset = true});
	PopupModWnd.MyPage:SetUIValue("rot_x", 0);
	PopupModWnd.MyPage:SetUIValue("rot_y", 0);
	PopupModWnd.MyPage:SetUIValue("rot_z", 0);
	PopupModWnd.MyPage:SetUIValue("scale", 0);
end

function PopupModWnd.OnRotationChange(value)
	local heading, attitude, bank = 0,0,0;
	
	heading = PopupModWnd.MyPage:GetUIValue("rot_x");
	attitude = PopupModWnd.MyPage:GetUIValue("rot_y");
	bank = PopupModWnd.MyPage:GetUIValue("rot_z");
	
	local x,y,z,w = mathlib.EulerToQuat(heading, attitude, bank);
	Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_MoveCursorObject, quat={x=x, y=y, z=z, w=w}});
end

function PopupModWnd.OnScaleChange(value)
	local scale = math.pow(0.9, PopupModWnd.MyPage:GetUIValue("scale"));
	Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_MoveCursorObject, scale=scale});
end

function PopupModWnd.HidePopupEdit()
	_this=ParaUI.GetUIObject(PopupModWnd.Name);
	if(_this:IsValid()) then
		_this.visible = false;
	end
end

function PopupModWnd.OnClickOK()
	PopupModWnd.HidePopupEdit()
	if(type(PopupModWnd.PopupEditor_onclose)=="function") then
		PopupModWnd.PopupEditor_onclose(false);
	end
end

function PopupModWnd.OnMouseUp()
	PopupModWnd.HidePopupEdit()
	if(type(PopupModWnd.PopupEditor_onclose)=="function") then
		PopupModWnd.PopupEditor_onclose(true);
	end
end
