--[[
Title: Objects Add page
Author(s): LiXizhi
Date: 2009/2/8
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Creator/Objects/ObjectAttributePage.lua");
Map3DSystem.App.Creator.ObjectAttributePage.HookSelectedMsg()
------------------------------------------------------------
]]

local ObjectAttributePage = {
	selectedObj = nil,
};
commonlib.setfield("Map3DSystem.App.Creator.ObjectAttributePage", ObjectAttributePage)

-- singleton page instance. 
local page;

-- called to init page
function ObjectAttributePage.OnInit()
	page = document:GetPageCtrl();
	ObjectAttributePage.HookSelectedMsg()
end
------------------------
-- page events
------------------------
function ObjectAttributePage.HookSelectedMsg()
	local o = {
				hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC, 		 
				hookName = Map3DSystem.msg.OBJ_SelectObject, 
				appName = "scene", 
				wndName = "object",
				callback = Map3DSystem.App.Creator.ObjectAttributePage.Selected,
		}
	CommonCtrl.os.hook.SetWindowsHook(o);
	
	o = {
				hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC, 		 
				hookName = Map3DSystem.msg.OBJ_DeselectObject, 
				appName = "scene", 
				wndName = "object",
				callback = Map3DSystem.App.Creator.ObjectAttributePage.UnSelected,
		}
	CommonCtrl.os.hook.SetWindowsHook(o);
end

function ObjectAttributePage.Selected(nCode, appName, msg)
	local obj = Map3DSystem.obj.GetObjectInMsg(msg);
	if(obj~=nil and obj:IsValid()) then
		ObjectAttributePage.selectedObj = obj;
		local id_txt = page:FindControl("id_txt");
		local id = tostring(obj:GetID());
		if(id_txt)then
			page:SetValue("id_txt",id);
		end
			
		page:SetValue("physics_group", tostring(obj:GetPhysicsGroup()));
			
		local IsPhysicsEnabled = obj:IsPhysicsEnabled();
		if(IsPhysicsEnabled) then
			page:SetValue("attvalue_physics", "1");
		else
			page:SetValue("attvalue_physics", "0");
		end
			
		page:SetValue("IsBigObject", obj:CheckAttribute(8192));
		page:SetValue("PhysicsRadius", obj:GetPhysicsRadius());

		page:SetValue("ShadowCaster", obj:GetField("ShadowCaster", true));
		page:SetValue("ShadowReceiver", obj:GetField("ShadowReceiver", false));
		page:SetValue("render_tech", tostring(obj:GetField("render_tech", 0)));

		page:SetValue("result", "点击设置,保存更改")
	end
	return nCode;
end

function ObjectAttributePage.UnSelected(nCode, appName, msg)
	local id_txt = page:FindControl("id_txt");
	if(id_txt)then
		page:SetValue("id_txt",0);
		page:SetValue("result", "请选择物体")
	end
	ObjectAttributePage.selectedObj = nil;
	return nCode;
end

function ObjectAttributePage.Save(name, values)
	local id = values["id_txt"];
	local obj = ObjectAttributePage.selectedObj
	if(obj and obj:IsValid())then
		local enable_physics = tonumber(values["attvalue_physics"]);
		obj:EnablePhysics(enable_physics == 1)
			
		local physics_group =  tonumber(values["physics_group"]);
		if(physics_group) then
			obj:SetPhysicsGroup(physics_group);
		end

		if(values["IsBigObject"]) then
			obj:SetAttribute(8192, true);
		else
			obj:SetAttribute(8192, false);
		end	
			
		if(values["PhysicsRadius"]) then
			obj:SetPhysicsRadius(tonumber(values["PhysicsRadius"]));
		end
			
		obj:SetField("ShadowCaster", values["ShadowCaster"] == true)
		obj:SetField("ShadowReceiver", values["ShadowReceiver"] == true)

		local render_tech = tonumber(values["render_tech"])
		if(render_tech and render_tech > 0 ) then
			obj:SetField("render_tech", render_tech);
		end
		page:SetValue("result", "设置成功！")
	else
		_guihelper.MessageBox("请先选择一个物体！");
	end
end
