--[[ 
Title: Object creation UI for ParaEngine
Author(s): LiXizhi
Date: 2005/11
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/demo/object/manage.lua");
------------------------------------------------------------
]]
--Require:
NPL.load("(gl)script/ide/object_editor.lua");

--[[ObjManageUI library]]
if(not ObjManageUI) then ObjManageUI={}; end

--[[save to disk file.]]
function ObjManageUI.save()
	ObjEditor.SaveNearPlayer();
end

--[[load file from disk ]]
function ObjManageUI.load()
	ObjEditor.LoadNearPlayer();
end

-- select an existing object
function ObjManageUI.SelObject()
	local tmp =ParaUI.GetUIObject("obj_manage_name");
	if(tmp:IsValid()==false) then
		return;
	end
	ObjEditor.SelObjectByName(tmp.text);
end

-- delete an object from the the movie list and the scene
function ObjManageUI.DelObject()
	if(ObjEditor.DelSeletedObject() == true) then 
		-- update the UI
		ObjManageUI.refresh();
	end
end

-- Remove an object from the movie list, but not from the scene.
function ObjManageUI.RemoveObject()
	if(ObjEditor.RemoveSelectedObject() == true) then 
		-- update the UI
		ObjManageUI.refresh();
	end
end

--[[when the user double click an object in the list box]]
function ObjManageUI.SelFromList()
	local temp = ParaUI.GetUIObject("obj_manage_text");
	if(temp:IsValid() == true) then 
		local nameObj =ParaUI.GetUIObject("obj_manage_name");
		if(nameObj:IsValid()==true) then
			-- set nameObj.text by the name of the current selection and call SelObject()
			nameObj.text = temp.text;
			if(nameObj.text~="") then
				ObjManageUI.SelObject();				
			end
		end
	end
end

--[[refresh UI ]]
function ObjManageUI.refresh()
	local __texture;
	local listbox = ParaUI.GetUIObject("obj_manage_text");
	if(listbox:IsValid() == true) then
		
		-- refill the list box of objects
		listbox:RemoveAll();
		
		local key, obj;
		local NumOfObjects=0;
		for key, obj in pairs(ObjEditor.objects) do
			listbox:AddTextItem(tostring(key));
			NumOfObjects = NumOfObjects+1;
		end
		
		-- set num of object
		local temp = ParaUI.GetUIObject("obj_manage_count");
		if(temp:IsValid()==true) then 
			temp.text=tostring(NumOfObjects);
		end
	end
end

local function activate()
	_guihelper.CheckRadioButtons( _demo_obj_pages, "obj_manage", "255 0 0");
	local __this,__parent,__font,__texture;
	
	__this = ParaUI.GetUIObject("obj_creation_win");
	if(__this:IsValid() == true) then
		__this.visible = false;
	end
	__this = ParaUI.GetUIObject("obj_change_con");
	if(__this:IsValid() == true) then
		__this.visible = false;
	end
	__this = ParaUI.GetUIObject("obj_manage_con");
	
	if(__this:IsValid() == true) then
		__this.visible=true;
	else		
		__this=ParaUI.CreateUIObject("container","obj_manage_con", "_lt",30,60,299,390);
		__parent=ParaUI.GetUIObject("obj_main");__parent:AddChild(__this);
		__this.scrollable=false;
		__this.background="Texture/item.png;";
		__texture=__this:GetTexture("background");
		__texture.transparency=0;--[0-255]
		
		__this=ParaUI.CreateUIObject("imeeditbox","obj_manage_name", "_lt",10,20,105,30);
		__parent=ParaUI.GetUIObject("obj_manage_con");__parent:AddChild(__this);
		if(ObjEditor.GetCurrentObj() ~= nil) then
			__this.text=ObjEditor.GetCurrentObj().name;
		end
		
		-----------------------------------------------------------------------------------
		__this.background="Texture/box.png;";
		
		__this.readonly=false;
		
		__this=ParaUI.CreateUIObject("button","obj_add_", "_lt",115,20,60,30);
		__parent=ParaUI.GetUIObject("obj_manage_con");__parent:AddChild(__this);
		__this.text="选择";
		__this.background="Texture/b_up.png;";
		__this.onclick=";ObjManageUI.SelObject()";
		
		
		__this=ParaUI.CreateUIObject("button","obj_del_", "_lt",175,20,60,30);
		__parent=ParaUI.GetUIObject("obj_manage_con");__parent:AddChild(__this);
		__this.text="删除";
		__this.background="Texture/b_up.png;";
		__this.onclick=";ObjManageUI.DelObject()";
		
		
		__this=ParaUI.CreateUIObject("text","text1", "_lt",10,55,100,22);
		__parent=ParaUI.GetUIObject("obj_manage_con");__parent:AddChild(__this);
		__this.text="物体数量：";
		__this.autosize=true;
		
		__this=ParaUI.CreateUIObject("text","obj_manage_count", "_lt",115,55,100,22);
		__parent=ParaUI.GetUIObject("obj_manage_con");__parent:AddChild(__this);
		__this.text="";
		__this.autosize=true;
		
		__this=ParaUI.CreateUIObject("text","text1", "_lt",10,75,100,22);
		__parent=ParaUI.GetUIObject("obj_manage_con");__parent:AddChild(__this);
		__this.text="组列表：";
		__this.autosize=true;	
		
		__this=ParaUI.CreateUIObject("listbox","g_list", "_lt",10,95,270,90);
		__parent=ParaUI.GetUIObject("obj_manage_con");__parent:AddChild(__this);
		__this.scrollable=true;
		__this.background="Texture/player/outputbox.png;";
		__this.ondoubleclick = "";
		
		
		__this=ParaUI.CreateUIObject("text","text1", "_lt",10,190,100,22);
		__parent=ParaUI.GetUIObject("obj_manage_con");__parent:AddChild(__this);
		__this.text="物体列表：";
		__this.autosize=true;	

		__this=ParaUI.CreateUIObject("listbox","obj_manage_text", "_lt",10,210,270,120);
		__parent=ParaUI.GetUIObject("obj_manage_con");__parent:AddChild(__this);
		__this.scrollable=true;
		__this.background="Texture/player/outputbox.png;";
		__this.ondoubleclick = ";ObjManageUI.SelFromList();";
		
		
		__this=ParaUI.CreateUIObject("button","static", "_lt",10,330,60,30);
		__parent=ParaUI.GetUIObject("obj_manage_con");__parent:AddChild(__this);
		__this.text="设为组";
		__this.background="Texture/b_up.png;";
		__this.onclick="";
		
		
		__this=ParaUI.CreateUIObject("button","static", "_lt",70,330,60,30);
		__parent=ParaUI.GetUIObject("obj_manage_con");__parent:AddChild(__this);
		__this.text="撤销";
		__this.background="Texture/b_up.png;";
		__this.onclick="";
		
		
		__this=ParaUI.CreateUIObject("button","static", "_lt",130,330,60,30);
		__parent=ParaUI.GetUIObject("obj_manage_con");__parent:AddChild(__this);
		__this.text="平移";
		__this.background="Texture/b_up.png;";
		__this.onclick=[[(gl)script/demo/object/change.lua;obj_change_onclick = "obj_moveto_player";]];
		
		
		__this=ParaUI.CreateUIObject("button","obj_manage_update", "_lt",190,330,60,30);
		__parent=ParaUI.GetUIObject("obj_manage_con");__parent:AddChild(__this);
		__this.text="刷新";
		__this.background="Texture/b_up.png;";
		__this.onclick=";ObjManageUI.refresh()";
	end
	-- update the object list	
	ObjManageUI.refresh();
end
NPL.this(activate);
