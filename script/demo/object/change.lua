--[[
Title: the object modifier for ParaEngine 3D environment development library
Dest: it can change an object's position, orientation and scale.
Author(s): LiXizhi(code&logic)
Date: 2005/11
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/demo/object/change.lua");
------------------------------------------------------------
]]

-- requires:
NPL.load("(gl)script/ide/object_editor.lua");
NPL.load("(gl)script/demo/object/manage.lua");

-- global variables:
obj_change_onclick = nil;

local function activate()
	local nMoveStep, nRotStep= 0.2, 0.1;
	if(obj_change_onclick==nil) then
		_guihelper.CheckRadioButtons( _demo_obj_pages, "obj_modify", "255 0 0");
			
		local __this,__parent,__font,__texture;
		
		__this = ParaUI.GetUIObject("obj_creation_win");
		if(__this:IsValid() == true) then
			__this.visible = false;
		end
		__this = ParaUI.GetUIObject("obj_manage_con");
		if(__this:IsValid() == true) then
			__this.visible = false;
		end
		
		__this = ParaUI.GetUIObject("obj_change_con");
		if(__this:IsValid() == true) then
			__this.visible=true;
		else
			__this=ParaUI.CreateUIObject("container","obj_change_con", "_lt",30,60,299,390);
			__parent=ParaUI.GetUIObject("obj_main");__parent:AddChild(__this);
			__this.scrollable=false;
			__this.background="Texture/item.png;";
			
			__texture=__this:GetTexture("background");
			__texture.transparency=0;--[0-255]
			
			__this=ParaUI.CreateUIObject("text","text1", "_lt",10,55,105,22);
			__parent=ParaUI.GetUIObject("obj_change_con");__parent:AddChild(__this);
			__this.text="物体名称：";
			__this.autosize=true;
			__this.background="Texture/dxutcontrols.dds;0 0 0 0";
			
			
			__this=ParaUI.CreateUIObject("imeeditbox","obj_change_objName", "_lt",105,50,120,30);
			__parent=ParaUI.GetUIObject("obj_change_con");__parent:AddChild(__this);
			local obj = ObjEditor.GetCurrentObj();
			if(obj~=nil and obj:IsValid()==true) then
				__this.text=obj.name;
			end
			__this.background="Texture/box.png;";
			
			__this.readonly=false;
			
			__this=ParaUI.CreateUIObject("button","obj_change_objName_btn", "_lt",225,50,50,30);
			__parent=ParaUI.GetUIObject("obj_change_con");__parent:AddChild(__this);
			__this.text="修改";
			__this.background="Texture/b_up.png;";
			__this.onclick="(gl)script/demo/object/change.lua;obj_change_onclick = \"changename\";";
			
			
			__this=ParaUI.CreateUIObject("container","con1", "_lt",10,100,270,260);
			__parent=ParaUI.GetUIObject("obj_change_con");__parent:AddChild(__this);
			__this.scrollable=false;
			__this.background="Texture/object_change.png;";
		

			--[[ 
			scale and physics
			]]
			__this=ParaUI.CreateUIObject("button","obj_scale_down", "_lt",0,0,20,20);
			__parent=ParaUI.GetUIObject("con1");__parent:AddChild(__this);
			__this.text=""; -- -
			__this.background="Texture/down.png;";
			__this.onclick=";ObjEditor.ScaleCurrentObj(0.9);";
			
			
			__this=ParaUI.CreateUIObject("button","obj_scale_up", "_lt",20,0,20,20);
			__parent=ParaUI.GetUIObject("con1");__parent:AddChild(__this);
			__this.text="";-- +
			__this.background="Texture/up.png;";
			__this.onclick=";ObjEditor.ScaleCurrentObj(1.1);";
			
			
			__this=ParaUI.CreateUIObject("button","obj_enable_phy", "_lt",0,30,80,20);
			__parent=ParaUI.GetUIObject("con1");__parent:AddChild(__this);
			__this.text="添加物理";
			__this.background="Texture/b_up.png;";
			__this.onclick=";ObjEditor.EnablePhysics(true);";
			
			__this=ParaUI.CreateUIObject("button","obj_disable_phy", "_lt",0,55,80,20);
			__parent=ParaUI.GetUIObject("con1");__parent:AddChild(__this);
			__this.text="取消物理"; 
			__this.background="Texture/b_up.png;";
			__this.onclick=";ObjEditor.EnablePhysics(false);";
			
			
			--[[ 
			position
			]]
			__this=ParaUI.CreateUIObject("button","obj_y_pos", "_lt",123,30,20,50);
			__parent=ParaUI.GetUIObject("con1");__parent:AddChild(__this);
			__this.text=""; -- 1
			__this.background="Texture/b_up.png;0 0 0 0";
			__this.onclick=";ObjEditor.MoveCurrentObj(0,0.2,0);";
			__this.tooltip = "上移";
			
			__this=ParaUI.CreateUIObject("button","obj_y_neg", "_lt",123,170,20,70);
			__parent=ParaUI.GetUIObject("con1");__parent:AddChild(__this);
			__this.text=""; -- 2
			__this.background="Texture/b_up.png;0 0 0 0";
			__this.onclick=";ObjEditor.MoveCurrentObj(0,-0.2,0);";
			__this.tooltip = "下移";
			
			__this=ParaUI.CreateUIObject("button","obj_x_neg", "_lt",25,120,60,20);
			__parent=ParaUI.GetUIObject("con1");__parent:AddChild(__this);
			__this.text=""; -- 3
			__this.background="Texture/b_up.png;0 0 0 0";
			__this.tooltip = "左移";
			__this.onclick=";ObjEditor.MoveCurrentObj(-0.2,0,0);";
			
			__this=ParaUI.CreateUIObject("button","obj_x_pos", "_lt",180,120,60,20);
			__parent=ParaUI.GetUIObject("con1");__parent:AddChild(__this);
			__this.text=""; -- 4
			__this.background="Texture/b_up.png;0 0 0 0";
			__this.tooltip = "右移";
			__this.onclick=";ObjEditor.MoveCurrentObj(0.2,0,0);";
			
			__this=ParaUI.CreateUIObject("button","obj_z_neg", "_lt",60,160,30,30);
			__parent=ParaUI.GetUIObject("con1");__parent:AddChild(__this);
			__this.text=""; -- 5
			__this.background="Texture/b_up.png;0 0 0 0";
			__this.onclick=";ObjEditor.MoveCurrentObj(0,0,-0.2);";
			__this.tooltip = "移近";
			
			__this=ParaUI.CreateUIObject("button","obj_z_pos", "_lt",170,60,30,30);
			__parent=ParaUI.GetUIObject("con1");__parent:AddChild(__this);
			__this.text=""; -- 6
			__this.background="Texture/b_up.png;0 0 0 0";
			__this.onclick=";ObjEditor.MoveCurrentObj(0,0,0.2);";
			__this.tooltip = "移远";
			
			__this=ParaUI.CreateUIObject("button","obj_z_pos", "_lt",200,10,65,30);
			__parent=ParaUI.GetUIObject("con1");__parent:AddChild(__this);
			__this.text="平移"; -- 6
			__this.background="Texture/b_up.png;";
			__this.onclick=[[(gl)script/demo/object/change.lua;obj_change_onclick = "obj_moveto_player";]];
			
			__this=ParaUI.CreateUIObject("button","static", "_lt",0,200,100,30);
			__parent=ParaUI.GetUIObject("con1");__parent:AddChild(__this);
			__this.text="顺时针90度"; -- 6
			__this.background="Texture/b_up.png;";
			__this.onclick=";ObjEditor.RotateCurrentObj(0,1.5708,0);";
			
			__this=ParaUI.CreateUIObject("button","static", "_lt",200,200,65,30);
			__parent=ParaUI.GetUIObject("con1");__parent:AddChild(__this);
			__this.text="还原"; -- 6
			__this.background="Texture/b_up.png;";
			__this.onclick=";ObjEditor.ResetCurrentObj();";
			
			__this=ParaUI.CreateUIObject("button","static", "_lt",0,230,100,30);
			__parent=ParaUI.GetUIObject("con1");__parent:AddChild(__this);
			__this.text="逆时针90度"; -- 6
			__this.background="Texture/b_up.png;";
			__this.onclick=";ObjEditor.RotateCurrentObj(0,1.5708,0);";
			
			__this=ParaUI.CreateUIObject("button","static", "_lt",200,230,65,30);
			__parent=ParaUI.GetUIObject("con1");__parent:AddChild(__this);
			__this.text="删除"; -- 6
			__this.background="Texture/b_up.png;";
			__this.onclick=";ObjManageUI.DelObject();";
			
			__this=ParaUI.CreateUIObject("button","obj_rotY_pos", "_lt",0,100,20,60);
			__parent=ParaUI.GetUIObject("con1");__parent:AddChild(__this);
			__this.text=""; --7
			__this.background="Texture/b_up.png;0 0 0 0";
			__this.onclick=";ObjEditor.RotateCurrentObj(0,0.1,0);";
			
			
			__this=ParaUI.CreateUIObject("button","obj_rotY_neg", "_lt",245,100,20,60);
			__parent=ParaUI.GetUIObject("con1");__parent:AddChild(__this);
			__this.text=""; -- 8
			__this.background="Texture/b_up.png;0 0 0 0";
			__this.onclick=";ObjEditor.RotateCurrentObj(0,-0.1,0);";
			
			
			__this=ParaUI.CreateUIObject("button","obj_rotZ_pos", "_lt",110,0,50,20);
			__parent=ParaUI.GetUIObject("con1");__parent:AddChild(__this);
			__this.text=""; -- 9
			__this.background="Texture/b_up.png;0 0 0 0";
			__this.onclick=";ObjEditor.RotateCurrentObj(0,0,0.1);";
			
			
			__this=ParaUI.CreateUIObject("button","obj_rotZ_neg", "_lt",110,240,50,20);
			__parent=ParaUI.GetUIObject("con1");__parent:AddChild(__this);
			__this.text=""; -- 10
			__this.background="Texture/b_up.png;0 0 0 0";
			__this.onclick=";ObjEditor.RotateCurrentObj(0,0,-0.1);";
			
			ObjEditor.ShowObjProperty(nil, true);
		end
	elseif(obj_change_onclick=="obj_moveto_player") then
		local obj = ObjEditor.GetCurrentObj();
		if(obj~=nil) then
			local x,y,z = obj:GetPosition();
			local player = ParaScene.GetObject("<player>");
			if(player:IsValid()==true) then
				local px,py,pz = player:GetPosition();
				ObjEditor.OffsetObj(obj, px-x,py-y,pz-z);
			end
		end
	elseif(obj_change_onclick=="changename") then
		local nameUI=ParaUI.GetUIObject("obj_change_objName");
		local obj = ObjEditor.GetCurrentObj();
		if(nameUI:IsValid()==true and obj~=nil) then
			ObjEditor.ReName(obj.name, nameUI.text);
		end
	end
	obj_change_onclick = nil;
end
NPL.this(activate);
