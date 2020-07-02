--[[ 
Title: Object creation UI for ParaEngine
Author(s): LiXizhi
Date: 2005/11
use the lib:
------------------------------------------------------------
NPL.activate("(gl)script/demo/object/main.lua");
------------------------------------------------------------
]]

NPL.load("(gl)script/ide/visibilityGroup.lua");
NPL.load("(gl)script/ide/object_editor.lua");

_demo_obj_pages = {"obj_create", "obj_modify", "obj_manage"};

if(not ObjManageUI) then ObjManageUI={}; end

function ObjManageUI.MousePickEvent()
	if(mouse_button == "left") then
		local obj = ParaScene.MousePick(20, "");
		-- Fire a missile from the current player to the picked object.
		local player = ParaScene.GetObject("<player>");
		if(obj:IsValid()==true and player:IsValid()==true) then
			local fromX, fromY, fromZ = player:GetPosition();
			fromY = fromY+1.0;
			local toX, toY, toZ = obj:GetViewCenter();
			-- using missile type 2, with a speed of 5.0
			ParaScene.FireMissile(2, 5, fromX, fromY, fromZ, toX, toY, toZ);
			
			ObjEditor.SetCurrentObj(obj);
			local temp = ParaUI.GetUIObject("obj_change_objName");
			if(temp:IsValid()==true) then
				temp.text = obj.name;
			end
			temp =ParaUI.GetUIObject("obj_manage_name");
			if(temp:IsValid()==true) then
				temp.text = obj.name;
			end
			
			ObjEditor.ShowObjProperty(obj, true);
		end
	end
end

function ObjManageUI.DestroyMe()
	ParaUI.Destroy("obj_main");
	-- unregister mouse handler
	ParaScene.UnregisterEvent("_m_obj_manage");
end

local function activate()
local __this,__parent,__font,__texture;

local temp = ParaUI.GetUIObject("obj_main");
if (temp:IsValid() == true) then
	CommonCtrl.VizGroup.Show("group1", not temp.visible, "obj_main");
	if(temp.visible == false) then
		ParaScene.UnregisterEvent("_m_obj_manage");
		ParaScene.GetAttributeObject():SetField("ShowLights", false);
	else
		-- register mouse picking event
		ParaScene.RegisterEvent("_m_obj_manage", ";ObjManageUI.MousePickEvent();");
		ParaScene.GetAttributeObject():SetField("ShowLights", true);
	end
else
CommonCtrl.VizGroup.Show("group1", false);
CommonCtrl.VizGroup.AddToGroup("group1", "obj_main");

__this=ParaUI.CreateUIObject("container","obj_main", "_lt",50,80,360,540);
__this:AttachToRoot();
__this.scrollable=false;
__this.background="Texture/user_bro.png";
__this.candrag=true;
__texture=__this:GetTexture("background");
__texture.transparency=255;--[0-255]

__this=ParaUI.CreateUIObject("button","obj_create", "_lt",50,30,80,30);
__parent=ParaUI.GetUIObject("obj_main");__parent:AddChild(__this);
__this.text="创建物体";
__this.background="Texture/b_up.png;";
__this.onclick="(gl)script/demo/object/create.lua";

__this=ParaUI.CreateUIObject("button","obj_modify", "_lt",135,30,80,30);
__parent=ParaUI.GetUIObject("obj_main");__parent:AddChild(__this);
__this.text="修改物体";
__this.background="Texture/b_up.png;";
__this.onclick="(gl)script/demo/object/change.lua";

__this=ParaUI.CreateUIObject("button","obj_manage", "_lt",220,30,80,30);
__parent=ParaUI.GetUIObject("obj_main");__parent:AddChild(__this);
__this.text="分组管理";
__this.background="Texture/b_up.png;";
__this.onclick="(gl)script/demo/object/manage.lua";

__this=ParaUI.CreateUIObject("button","close_button", "_lt",240,460,60,30);
__parent=ParaUI.GetUIObject("obj_main");__parent:AddChild(__this);
__this.text="关闭";
__this.background="Texture/b_up.png;";
--__this.onclick=";ObjManageUI.DestroyMe();";
__this.onclick="(gl)script/demo/object/main.lua";

-- register mouse picking event
ParaScene.RegisterEvent("_m_obj_manage", ";ObjManageUI.MousePickEvent();");
ParaScene.GetAttributeObject():SetField("ShowLights", true);

NPL.activate("(gl)script/demo/object/create.lua", "");	

end
end
NPL.this(activate);
