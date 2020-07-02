--[[
Title: Character Customization System main enterance
Author(s): LiXizhi, WangTian
Date: 2007/7/17
Parameters:
	CCS_main: it needs to be a valid name, such as MyDialog
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/CCS/CCS_main.lua");
CCS_main.Show();
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/kids/CCS/CCS_UI_Predefined.lua");
NPL.load("(gl)script/kids/CCS/CCS_UI_CartoonFace.lua");
NPL.load("(gl)script/kids/CCS/CCS_UI_Eyebrow.lua");
NPL.load("(gl)script/kids/CCS/CCS_UI_Face.lua");
NPL.load("(gl)script/kids/CCS/CCS_UI_Inventory_Head.lua");
NPL.load("(gl)script/kids/CCS/CCS_UI_CharFace.lua");

NPL.load("(gl)script/kids/CCS/CCS_UI_FaceComponent.lua");
NPL.load("(gl)script/kids/CCS/CCS_UI_InventorySlot.lua");

-- Debug purpose
NPL.load("(gl)script/ide/gui_helper.lua");
NPL.load("(gl)script/ide/headon_speech.lua");

if(not CCS_main) then CCS_main={}; end


--Function: show cartoon face control
--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function CCS_main.ShowCartoonFace(bShow)
	
	local _this,_parent;
	
	_this=ParaUI.GetUIObject("kidui_ccs_level1_cartoonface_container");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		
		local toLeft = CCS_main.ToLeft;
		local toBottom = CCS_main.ToBottom;
		local toRight = CCS_main.ToRight;
		local midHeight = CCS_main.MidHeight;
		
		_this=ParaUI.CreateUIObject("container","kidui_ccs_level1_cartoonface_container","_lt",0,0,toRight,midHeight);
		--_this:SetTopLevel(true);
		--_this:AttachToRoot();
		--_guihelper.MessageBox(toLeft.." "..toBottom.." "..toRight.." "..midHeight);
		
		local kidsUIContainer = ParaUI.GetUIObject("kidui_ccs_container");
		kidsUIContainer:AddChild(_this);
		
		_this.background="Texture/whitedot.png;0 0 0 0";
		_parent = _this;
		



_this = ParaUI.CreateUIObject("button", "btn1", "_lt", 0, 6, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/kidui/CCS/btn_CCS_CF_Face.png", 
	"Texture/kidui/CCS/btn_CCS_CF_Empty_Normal.png");
--_this.text = "Face";
_this.animstyle = 11;
_this.tooltip = "脸";
_this.onclick = ";CCS_main.OnClickFaceComponent();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn2", "_lt", 48, 6, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/kidui/CCS/btn_CCS_CF_Wrinkle.png", 
	"Texture/kidui/CCS/btn_CCS_CF_Empty_Normal.png");
--_this.text = "Wrinkle";
_this.animstyle = 11;
_this.tooltip = "皱纹";
_this.onclick = ";CCS_main.OnClickWrinkleComponent();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn3", "_lt", 96, 6, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/kidui/CCS/btn_CCS_CF_Eye.png", 
	"Texture/kidui/CCS/btn_CCS_CF_Empty_Normal.png");
--_this.text = "Eye";
_this.animstyle = 11;
_this.tooltip = "眼睛";
_this.onclick = ";CCS_main.OnClickEyeComponent();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn4", "_lt", 0, 54, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/kidui/CCS/btn_CCS_CF_Eyebrow.png", 
	"Texture/kidui/CCS/btn_CCS_CF_Empty_Normal.png");
--_this.text = "Brow";
_this.animstyle = 11;
_this.tooltip = "眉毛";
_this.onclick = ";CCS_main.OnClickEyebrowComponent();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn5", "_lt", 48, 54, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/kidui/CCS/btn_CCS_CF_Mouth.png", 
	"Texture/kidui/CCS/btn_CCS_CF_Empty_Normal.png");
--_this.text = "Mouth";
_this.animstyle = 11;
_this.tooltip = "嘴巴";
_this.onclick = ";CCS_main.OnClickMouthComponent();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn6", "_lt", 96, 54, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/kidui/CCS/btn_CCS_CF_Nose.png", 
	"Texture/kidui/CCS/btn_CCS_CF_Empty_Normal.png");
--_this.text = "Nose";
_this.animstyle = 11;
_this.tooltip = "鼻子";
_this.onclick = ";CCS_main.OnClickNoseComponent();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn7", "_lt", 0, 102, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/kidui/CCS/btn_CCS_CF_Marks.png", 
	"Texture/kidui/CCS/btn_CCS_CF_Empty_Normal.png");
--_this.text = "Marks";
_this.animstyle = 11;
_this.tooltip = "标志";
_this.onclick = ";CCS_main.OnClickMarksComponent();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn8", "_lt", 48, 102, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/kidui/CCS/btn_CCS_CF_Random.png", 
	"Texture/kidui/CCS/btn_CCS_CF_Empty_Normal.png");
--_this.text = "CartoonFaceType";
_this.animstyle = 11;
_this.tooltip = "脸形";
_this.onclick = ";CCS_UI_Predefined.NextCartoonFaceType();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btnReturn", "_lt", 96, 102, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/kidui/CCS/btn_CCS_CF_Return.png", 
	"Texture/kidui/CCS/btn_CCS_CF_Empty_Normal.png");
--_this.text = "Return";
_this.animstyle = 11;
_this.tooltip = "返回上一级";
_this.onclick = ";CCS_main.OnDestroy();ParaUI.GetUIObject(\"kidui_ccs_level0_container\").visible = true;CCS_main.UpdateCharacterInfo();";
_parent:AddChild(_this);


		--
		--_this = ParaUI.CreateUIObject("container", "InterfaceContainer", "_fi", 332, 71, 12, 14)
		--_this.background="Texture/whitedot.png;0 0 0 0";
		--_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("container", "InterfaceContainer", "_lt", 150, 5, 264, 150)
		_this.background="Texture/whitedot.png;0 0 0 0";
		_parent:AddChild(_this);


_this = ParaUI.CreateUIObject("container", "CCS_Right_IconMatrix_Container", "_rt", -160, 0, 160, 180);
_this.background="Texture/whitedot.png;0 0 0 0";
_parent:AddChild(_this);

_parent = _this;

_this = ParaUI.CreateUIObject("button", "btnRotateClockwise", "_rt", -158, 80, 40, 40)
_guihelper.SetVistaStyleButton2(_this, "Texture/kidui/CCS/btn_CCS_CF_Rotate_Clockwise.png", 
	"Texture/kidui/CCS/btn_CCS_CF_Modify_BG.png");
--_this.text = "(";
_this.animstyle = 11;
_this.tooltip = "顺时针旋转";
--_this.background="Texture/kidui/CCS/btn_CCS_CF_Rotate_Clockwise.png";
_this.onclick = ";CCS_UI_FaceComponent.SetFaceComponent(CCS_db.CFS_SUB_Rotation, 0.1);";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btnRotateAntiClockwise", "_rt", -116, 80, 40, 40)
_guihelper.SetVistaStyleButton2(_this, "Texture/kidui/CCS/btn_CCS_CF_Rotate_AntiClockwise.png", 
	"Texture/kidui/CCS/btn_CCS_CF_Modify_BG.png");
--_this.text = ")";
_this.animstyle = 11;
_this.tooltip = "逆时针旋转";
--_this.background="Texture/kidui/CCS/btn_CCS_CF_Rotate_AntiClockwise.png";
_this.onclick = ";CCS_UI_FaceComponent.SetFaceComponent(CCS_db.CFS_SUB_Rotation, -0.1);";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btnMoveUp", "_rt", -158, 0, 40, 40)
_guihelper.SetVistaStyleButton2(_this, "Texture/kidui/CCS/btn_CCS_CF_ShiftY_Up.png", 
	"Texture/kidui/CCS/btn_CCS_CF_Modify_BG.png");
--_this.text = "/\\";
_this.animstyle = 11;
_this.tooltip = "向上平移";
--_this.background="Texture/kidui/CCS/btn_CCS_CF_ShiftY_Up.png";
_this.onclick = ";CCS_UI_FaceComponent.SetFaceComponent(CCS_db.CFS_SUB_Y, -2);";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btnMoveDown", "_rt", -116, 0, 40, 40)
_guihelper.SetVistaStyleButton2(_this, "Texture/kidui/CCS/btn_CCS_CF_ShiftY_Down.png", 
	"Texture/kidui/CCS/btn_CCS_CF_Modify_BG.png");
--_this.text = "\\/";
_this.animstyle = 11;
_this.tooltip = "向下平移";
--_this.background="Texture/kidui/CCS/btn_CCS_CF_ShiftY_Down.png";
_this.onclick = ";CCS_UI_FaceComponent.SetFaceComponent(CCS_db.CFS_SUB_Y, 2);";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btnMoveLeft", "_rt", -158, 120, 40, 40)
_guihelper.SetVistaStyleButton2(_this, "Texture/kidui/CCS/btn_CCS_CF_ShiftX_Left.png", 
	"Texture/kidui/CCS/btn_CCS_CF_Modify_BG.png");
--_this.text = "<";
_this.animstyle = 11;
_this.tooltip = "左移/靠近";
--_this.background="Texture/kidui/CCS/btn_CCS_CF_ShiftX_Left.png";
_this.onclick = ";CCS_UI_FaceComponent.SetFaceComponent(CCS_db.CFS_SUB_X, -1);";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btnMoveRight", "_rt", -116, 120, 40, 40)
_guihelper.SetVistaStyleButton2(_this, "Texture/kidui/CCS/btn_CCS_CF_ShiftX_Right.png", 
	"Texture/kidui/CCS/btn_CCS_CF_Modify_BG.png");
--_this.text = ">";
_this.animstyle = 11;
_this.tooltip = "右移/分开";
--_this.background="Texture/kidui/CCS/btn_CCS_CF_ShiftX_Right.png";
_this.onclick = ";CCS_UI_FaceComponent.SetFaceComponent(CCS_db.CFS_SUB_X, 1);";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btnZoomIn", "_rt", -158, 40, 40, 40)
_guihelper.SetVistaStyleButton2(_this, "Texture/kidui/CCS/btn_CCS_CF_ZoomIn.png", 
	"Texture/kidui/CCS/btn_CCS_CF_Modify_BG.png");
--_this.text = "+";
_this.animstyle = 11;
_this.tooltip = "放大";
--_this.background="Texture/kidui/CCS/btn_CCS_CF_ZoomIn.png";
_this.onclick = ";CCS_UI_FaceComponent.SetFaceComponent(CCS_db.CFS_SUB_Scale, 0.1);";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btnZoomOut", "_rt", -116, 40, 40, 40)
_guihelper.SetVistaStyleButton2(_this, "Texture/kidui/CCS/btn_CCS_CF_ZoomOut.png", 
	"Texture/kidui/CCS/btn_CCS_CF_Modify_BG.png");
--_this.text = "-";
_this.animstyle = 11;
_this.tooltip = "缩小";
--_this.background="Texture/kidui/CCS/btn_CCS_CF_ZoomOut.png";
_this.onclick = ";CCS_UI_FaceComponent.SetFaceComponent(CCS_db.CFS_SUB_Scale, -0.1);";
_parent:AddChild(_this);



-- Color Palette

_this = ParaUI.CreateUIObject("button", "btnColorPalette", "_rt", -64, 16, 64, 128)
_guihelper.SetVistaStyleButtonBright(_this, "Texture/kidui/CCS/btn_CCS_ColorPalette.png");
--_this.text = "Color Palette";
_this.tooltip = "调色板";
_this.onclick = ";CCS_main.OnClickColorPalette();";
_parent:AddChild(_this);



NPL.load("(gl)script/kids/ui/middle_container.lua");

local lvl0 = ParaUI.GetUIObject("kidui_ccs_level0_container");
lvl0.visible = false;


		
	else
		if(bShow == nil) then
			bShow = (_this.visible == false);
		end
		_this.visible = bShow;
		
		if(bShow == true) then 
			--_this:SetTopLevel(true);
		end
	end	
	
	CCS_main.OnClickFaceComponent();
	--CCS_main.ShowUIInterface(CCS_UI_Predefined);
end



--Function: show cartoon face control
--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function CCS_main.ShowInventory(bShow)
	local _this,_parent;
	
	_this=ParaUI.GetUIObject("kidui_ccs_level1_inventory_container");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		
		local toLeft = CCS_main.ToLeft;
		local toBottom = CCS_main.ToBottom;
		local toRight = CCS_main.ToRight;
		local midHeight = CCS_main.MidHeight;
		
		_this=ParaUI.CreateUIObject("container","kidui_ccs_level1_inventory_container","_lt",0,0,toRight,midHeight);
		--_this:SetTopLevel(true);
		--_this:AttachToRoot();
		--_guihelper.MessageBox(toLeft.." "..toBottom.." "..toRight.." "..midHeight);
		
		local kidsUIContainer = ParaUI.GetUIObject("kidui_ccs_container");
		kidsUIContainer:AddChild(_this);
		
		_this.background="Texture/whitedot.png;0 0 0 0";
		_parent = _this;
		
		
		
		
		

_this = ParaUI.CreateUIObject("button", "btn1", "_lt", 0, 6, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/kidui/CCS/btn_CCS_IT_Head_Fade.png", 
	"Texture/kidui/CCS/btn_CCS_IT_Empty_Normal.png");
--_this.text = "Head";
_this.animstyle = 11;
_this.tooltip = "头部";
_this.onclick = ";CCS_main.OnClickHeadInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn2", "_lt", 48, 6, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/kidui/CCS/btn_CCS_IT_Neck_Fade.png", 
	"Texture/kidui/CCS/btn_CCS_IT_Empty_Normal.png");
--_this.text = "Neck";
_this.animstyle = 11;
_this.tooltip = "颈部";
_this.onclick = ";CCS_main.OnClickNeckInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn3", "_lt", 96, 6, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/kidui/CCS/btn_CCS_IT_Shoulder_Fade.png", 
	"Texture/kidui/CCS/btn_CCS_IT_Empty_Normal.png");
--_this.text = "Shoulder";
_this.animstyle = 11;
_this.tooltip = "肩膀";
_this.onclick = ";CCS_main.OnClickShoulderInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn4", "_lt", 144, 6, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/kidui/CCS/btn_CCS_IT_Boots_Fade.png", 
	"Texture/kidui/CCS/btn_CCS_IT_Empty_Normal.png");
--_this.text = "Boots";
_this.animstyle = 11;
_this.tooltip = "鞋";
_this.onclick = ";CCS_main.OnClickBootsInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn5", "_lt", 192, 6, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/kidui/CCS/btn_CCS_IT_Belt_Fade.png", 
	"Texture/kidui/CCS/btn_CCS_IT_Empty_Normal.png");
--_this.text = "Belt";
_this.animstyle = 11;
_this.tooltip = "腰带";
_this.onclick = ";CCS_main.OnClickBeltInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn6", "_lt", 0, 54, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/kidui/CCS/btn_CCS_IT_Shirt_Fade.png", 
	"Texture/kidui/CCS/btn_CCS_IT_Empty_Normal.png");
--_this.text = "Shirt";
_this.animstyle = 11;
_this.tooltip = "衬衫";
_this.onclick = ";CCS_main.OnClickShirtInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn7", "_lt", 48, 54, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/kidui/CCS/btn_CCS_IT_Pants_Fade.png", 
	"Texture/kidui/CCS/btn_CCS_IT_Empty_Normal.png");
--_this.text = "Pants";
_this.animstyle = 11;
_this.tooltip = "裤子";
_this.onclick = ";CCS_main.OnClickPantsInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn8", "_lt", 96, 54, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/kidui/CCS/btn_CCS_IT_Chest_Fade.png", 
	"Texture/kidui/CCS/btn_CCS_IT_Empty_Normal.png");
--_this.text = "Chest";
_this.animstyle = 11;
_this.tooltip = "胸";
_this.onclick = ";CCS_main.OnClickChestInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn9", "_lt", 144, 54, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/kidui/CCS/btn_CCS_IT_Bracers_Fade.png", 
	"Texture/kidui/CCS/btn_CCS_IT_Empty_Normal.png");
--_this.text = "Bracers";
_this.animstyle = 11;
_this.tooltip = "手腕";
_this.onclick = ";CCS_main.OnClickBracersInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn10", "_lt", 192, 54, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/kidui/CCS/btn_CCS_IT_Gloves_Fade.png", 
	"Texture/kidui/CCS/btn_CCS_IT_Empty_Normal.png");
--_this.text = "Gloves";
_this.animstyle = 11;
_this.tooltip = "手套";
_this.onclick = ";CCS_main.OnClickGlovesInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn11", "_lt", 0, 102, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/kidui/CCS/btn_CCS_IT_HandRight_Fade.png", 
	"Texture/kidui/CCS/btn_CCS_IT_Empty_Normal.png");
--_this.text = "HandRight";
_this.animstyle = 11;
_this.tooltip = "右手";
_this.onclick = ";CCS_main.OnClickHandRightInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn12", "_lt", 48, 102, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/kidui/CCS/btn_CCS_IT_HandLeft_Fade.png", 
	"Texture/kidui/CCS/btn_CCS_IT_Empty_Normal.png");
--_this.text = "HandLeft";
_this.animstyle = 11;
_this.tooltip = "左手";
_this.onclick = ";CCS_main.OnClickHandLeftInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn13", "_lt", 96, 102, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/kidui/CCS/btn_CCS_IT_Cape_Fade.png", 
	"Texture/kidui/CCS/btn_CCS_IT_Empty_Normal.png");
--_this.text = "Cape";
_this.animstyle = 11;
_this.tooltip = "披风";
_this.onclick = ";CCS_main.OnClickCapeInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn14", "_lt", 144, 102, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/kidui/CCS/btn_CCS_IT_Tabard_Fade.png", 
	"Texture/kidui/CCS/btn_CCS_IT_Empty_Normal.png");
--_this.text = "Tabard";
_this.animstyle = 11;
_this.tooltip = "大衣";
_this.onclick = ";CCS_main.OnClickTabardInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn_Inv_Return", "_lt", 192, 102, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/kidui/CCS/btn_CCS_IT_Return.png", 
	"Texture/kidui/CCS/btn_CCS_IT_Empty_Normal.png");
--_this.text = "Return";
_this.animstyle = 11;
_this.tooltip = "返回上一级";
_this.onclick = ";CCS_main.OnDestroy();ParaUI.GetUIObject(\"kidui_ccs_level0_container\").visible = true; CCS_main.UpdateCharacterInfo(); CCS_main.PreviousActiveInventorySlot = nil;";
_parent:AddChild(_this);

		
		
		
NPL.load("(gl)script/kids/ui/middle_container.lua");

local lvl0 = ParaUI.GetUIObject("kidui_ccs_level0_container");
lvl0.visible = false;
		
		--
		--_this = ParaUI.CreateUIObject("container", "InterfaceContainer", "_fi", 332, 71, 12, 14)
		--_this.background="Texture/whitedot.png;0 0 0 0";
		--_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("container", "CCS_UI_Inventory_level2_container", "_lt", 258, 0, 264, 150)
		_this.background="Texture/whitedot.png;0 0 0 0";
		_parent:AddChild(_this);
		
	else
		if(bShow == nil) then
			bShow = (_this.visible == false);
		end
		_this.visible = bShow;
		
		if(bShow == true) then 
			--_this:SetTopLevel(true);
		end
	end	
	
	CCS_main.OnClickHeadInventory();
	--CCS_main.ShowUIInterface(CCS_UI_Predefined);
end

function CCS_main.PleaseSelectRaceOrGender()
	local obj = ObjEditor.GetCurrentObj();
	headon_speech.Speek(obj.name, "请选择种族和性别,看看有什么反应:-)", 2);
end


-- update the character information including gender and race
function CCS_main.UpdateCharacterInfo(from)

	local obj = ObjEditor.GetCurrentObj();
	
	if(obj ~= nil and obj:IsValid()==true) then
		if(obj:IsCharacter()==true and obj:ToCharacter():IsCustomModel()==true) then
			
			
			if(from == "HumanClick") then
				local r = obj:ToCharacter():GetRaceID();
				local g = obj:ToCharacter():GetGender();
				
				if(r == 1 and g == 0) then
					-- male, human
					headon_speech.Speek(obj.name, "我已经是成人了", 2);
				elseif(r == 1 and g == 1) then
					-- female, human
					headon_speech.Speek(obj.name, "我已经是成人了", 2);
				elseif(r == 2 and g == 0) then
					-- male, child
					CCS_UI_Predefined.ResetBaseModel("character/v3/Human2/", "Male");
					headon_speech.Speek(obj.name, "我变成成人了", 2);
				elseif(r == 2 and g == 1) then
					-- female, child
					CCS_UI_Predefined.ResetBaseModel("character/v3/Human2/", "Female");
					headon_speech.Speek(obj.name, "我变成成人了", 2);
				end
				
				--return;
			elseif(from == "ChildClick") then
				local r = obj:ToCharacter():GetRaceID();
				local g = obj:ToCharacter():GetGender();
				
				if(r == 1 and g == 0) then
					-- male, human
					CCS_UI_Predefined.ResetBaseModel("character/v3/Child/", "Male");
					headon_speech.Speek(obj.name, "我变成小孩了", 2);
				elseif(r == 1 and g == 1) then
					-- female, human
					CCS_UI_Predefined.ResetBaseModel("character/v3/Child/", "Female");
					headon_speech.Speek(obj.name, "我变成小孩了", 2);
				elseif(r == 2 and g == 0) then
					-- male, child
					headon_speech.Speek(obj.name, "我已经是小孩了", 2);
				elseif(r == 2 and g == 1) then
					-- female, child
					headon_speech.Speek(obj.name, "我已经是小孩了", 2);
				end
				
				--return;
			elseif(from == "MaleClick") then
				local r = obj:ToCharacter():GetRaceID();
				local g = obj:ToCharacter():GetGender();
				
				if(r == 1 and g == 0) then
					-- male, human
					headon_speech.Speek(obj.name, "我已经是男人了", 2);
				elseif(r == 1 and g == 1) then
					-- female, human
					CCS_UI_Predefined.ResetBaseModel("character/v3/Human2/", "Male");
					headon_speech.Speek(obj.name, "我变成男人了", 2);
				elseif(r == 2 and g == 0) then
					-- male, child
					headon_speech.Speek(obj.name, "我已经是男孩了", 2);
				elseif(r == 2 and g == 1) then
					-- female, child
					CCS_UI_Predefined.ResetBaseModel("character/v3/Child/", "Male");
					headon_speech.Speek(obj.name, "我变成男孩了", 2);
				end
				
			elseif(from == "FemaleClick") then
				local r = obj:ToCharacter():GetRaceID();
				local g = obj:ToCharacter():GetGender();
				
				if(r == 1 and g == 0) then
					-- male, human
					CCS_UI_Predefined.ResetBaseModel("character/v3/Human2/", "Female");
					headon_speech.Speek(obj.name, "我变成女人了", 2);
				elseif(r == 1 and g == 1) then
					-- female, human
					headon_speech.Speek(obj.name, "我已经是女人了", 2);
				elseif(r == 2 and g == 0) then
					-- male, child
					CCS_UI_Predefined.ResetBaseModel("character/v3/Child/", "Female");
					headon_speech.Speek(obj.name, "我变成女孩了", 2);
				elseif(r == 2 and g == 1) then
					-- female, child
					headon_speech.Speek(obj.name, "我已经是女孩了", 2);
				end
				
			end
			
			local gender = obj:ToCharacter():GetGender();
			local race = obj:ToCharacter():GetRaceID();
			
			if(gender == 0) then
				local radiobuttons = {"buttonFemale","buttonMale"};
				_guihelper.CheckRadioButtons( radiobuttons, "buttonMale", "255 181 181");
			elseif(gender == 1) then
				local radiobuttons = {"buttonFemale","buttonMale"};
				_guihelper.CheckRadioButtons( radiobuttons, "buttonFemale", "255 181 181");
			end
			
			
			if(race == 1) then
				local radiobuttons = {"btnRaceHuman","btnRaceChild"};
				_guihelper.CheckRadioButtons( radiobuttons, "btnRaceHuman", "255 181 181");
			elseif(race == 2) then
				local radiobuttons = {"btnRaceHuman","btnRaceChild"};
				_guihelper.CheckRadioButtons( radiobuttons, "btnRaceChild", "255 181 181");
			end
			
			local charFaceType = obj:ToCharacter():GetBodyParams(1);
			local cartoonFaceType = obj:ToCharacter():GetBodyParams(4);
			if(charFaceType == -1 and cartoonFaceType > 0) then
				if (CCS_UI_Predefined.CurrentFaceType == "CharacterFace") then
					CCS_UI_Predefined.ToggleFace();
				end
			elseif(charFaceType > 0 and cartoonFaceType == -1) then
				if (CCS_UI_Predefined.CurrentFaceType == "CartoonFace") then
					CCS_UI_Predefined.ToggleFace();
				end
			end
			
		else
			-- not customizable character
			if(from == "HumanClick") then
				CCS_UI_Predefined.ResetBaseModel("character/v3/Human/", "Male");
				local radiobuttons = {"buttonFemale","buttonMale"};
				_guihelper.CheckRadioButtons( radiobuttons, "buttonMale", "255 181 181");
				local radiobuttons = {"btnRaceHuman","btnRaceChild"};
				_guihelper.CheckRadioButtons( radiobuttons, "btnRaceHuman", "255 181 181");
				headon_speech.Speek(obj.name, "我变成男人了", 2);
			elseif(from == "ChildClick") then
				CCS_UI_Predefined.ResetBaseModel("character/v3/Child/", "Female");
				local radiobuttons = {"buttonFemale","buttonMale"};
				_guihelper.CheckRadioButtons( radiobuttons, "buttonFemale", "255 181 181");
				local radiobuttons = {"btnRaceHuman","btnRaceChild"};
				_guihelper.CheckRadioButtons( radiobuttons, "btnRaceChild", "255 181 181");
				headon_speech.Speek(obj.name, "我变成女孩了", 2);
			elseif(from == "MaleClick") then
				CCS_UI_Predefined.ResetBaseModel("character/v3/Child/", "Male");
				local radiobuttons = {"buttonFemale","buttonMale"};
				_guihelper.CheckRadioButtons( radiobuttons, "buttonMale", "255 181 181");
				local radiobuttons = {"btnRaceHuman","btnRaceChild"};
				_guihelper.CheckRadioButtons( radiobuttons, "btnRaceChild", "255 181 181");
				headon_speech.Speek(obj.name, "我变成男孩了", 2);
			elseif(from == "FemaleClick") then
				CCS_UI_Predefined.ResetBaseModel("character/v3/Child/", "Female");
				local radiobuttons = {"buttonFemale","buttonMale"};
				_guihelper.CheckRadioButtons( radiobuttons, "buttonFemale", "255 181 181");
				local radiobuttons = {"btnRaceHuman","btnRaceChild"};
				_guihelper.CheckRadioButtons( radiobuttons, "btnRaceChild", "255 181 181");
				headon_speech.Speek(obj.name, "我变成女孩了", 2);
			else
			
				local texture = nil;
				local objUI = nil;
				objUI = ParaUI.GetUIObject("buttonFemale");
					objUI:SetCurrentState("normal");
					texture=objUI:GetTexture("background");
					texture.color="200 200 200";		
					objUI:SetCurrentState("highlight");
					texture=objUI:GetTexture("background");
					texture.color="255 255 255";		
					objUI:SetCurrentState("pressed");
					texture=objUI:GetTexture("background");
					texture.color="160 160 160";
				objUI = ParaUI.GetUIObject("buttonMale");
					objUI:SetCurrentState("normal");
					texture=objUI:GetTexture("background");
					texture.color="200 200 200";		
					objUI:SetCurrentState("highlight");
					texture=objUI:GetTexture("background");
					texture.color="255 255 255";		
					objUI:SetCurrentState("pressed");
					texture=objUI:GetTexture("background");
					texture.color="160 160 160";
				objUI = ParaUI.GetUIObject("btnRaceHuman");
					objUI:SetCurrentState("normal");
					texture=objUI:GetTexture("background");
					texture.color="200 200 200";		
					objUI:SetCurrentState("highlight");
					texture=objUI:GetTexture("background");
					texture.color="255 255 255";		
					objUI:SetCurrentState("pressed");
					texture=objUI:GetTexture("background");
					texture.color="160 160 160";
				objUI = ParaUI.GetUIObject("btnRaceChild");
					objUI:SetCurrentState("normal");
					texture=objUI:GetTexture("background");
					texture.color="200 200 200";		
					objUI:SetCurrentState("highlight");
					texture=objUI:GetTexture("background");
					texture.color="255 255 255";		
					objUI:SetCurrentState("pressed");
					texture=objUI:GetTexture("background");
					texture.color="160 160 160";
			end
		end
	end 
end


-- show a given UI in the Interface container and remove the old one
-- e.g. CCS_main.ShowUIInterface(CCS_UI_Predefined);
function CCS_main.ShowUIInterface(componentName)
	local _this = ParaUI.GetUIObject("kidui_ccs_level1_cartoonface_container");
	if(_this:IsValid()) then
		local parent = _this:GetChild("InterfaceContainer");
		if(CCS_main.CurrentUIInterface~=nil) then
			-- remove old one
			CCS_main.CurrentUIInterface.OnDestroy();
		end
		
		
		if(componentName == "CCS_UI_Predefined") then
			parent = _this:GetChild("OriginalInterfaceContainer");
			UIClassPtr = CCS_UI_Predefined;
		elseif(componentName == "CartoonFace") then
			UIClassPtr = CCS_UI_Face;
			UIClassPtr.Show(parent);
			CCS_main.CurrentUIInterface = UIClassPtr;
		elseif(componentName == "Inventory") then
			UIClassPtr = CCS_UI_Inventory_Head;
			UIClassPtr.Show(parent);
			CCS_main.CurrentUIInterface = UIClassPtr;
		end
	end	
end

CCS_main.Matrix = {};
CCS_main.Matrix["00"] = {0, 0, 255};
CCS_main.Matrix["01"] = {0, 255, 0};
CCS_main.Matrix["02"] = {255, 0, 0};
CCS_main.Matrix["10"] = {0, 255, 255};
CCS_main.Matrix["11"] = {255, 0, 255};
CCS_main.Matrix["12"] = {255, 255, 0};
CCS_main.Matrix["20"] = {127, 0, 255};
CCS_main.Matrix["21"] = {127, 255, 0};
CCS_main.Matrix["22"] = {255, 127, 0};
CCS_main.Matrix["30"] = {0, 127, 255};
CCS_main.Matrix["31"] = {0, 255, 127};
CCS_main.Matrix["32"] = {255, 0, 127};
CCS_main.Matrix["40"] = {127, 127, 255};
CCS_main.Matrix["41"] = {127, 255, 127};
CCS_main.Matrix["42"] = {255, 127, 127};
CCS_main.Matrix["50"] = {255, 255, 127};
CCS_main.Matrix["51"] = {255, 127, 255};
CCS_main.Matrix["52"] = {127, 255, 255};
CCS_main.Matrix["60"] = {0, 0, 127};
CCS_main.Matrix["61"] = {0, 127, 0};
CCS_main.Matrix["62"] = {127, 0, 0};
CCS_main.Matrix["70"] = {0, 127, 127};
CCS_main.Matrix["71"] = {127, 0, 127};
CCS_main.Matrix["72"] = {127, 127, 0};
CCS_main.Matrix["03"] = {0, 0, 0};
CCS_main.Matrix["13"] = {32, 32, 32};
CCS_main.Matrix["23"] = {64, 64, 64};
CCS_main.Matrix["33"] = {96, 96, 96};
CCS_main.Matrix["43"] = {128, 128, 128};
CCS_main.Matrix["53"] = {160, 160, 160};
CCS_main.Matrix["63"] = {192, 192, 192};
CCS_main.Matrix["73"] = {224, 224, 224};

function CCS_main.OnClickColorPalette()

	local x,y = ParaUI.GetMousePosition();
	local temp = ParaUI.GetUIObjectAtPoint(x,y);
	local abs_x,abs_y = temp:GetAbsPosition();
	local r_x,r_y = x - abs_x, y - abs_y;
	
	local indexX, indexY = 0, 0;
	indexX = (r_x - math.mod(r_x, 16))/16;
	indexY = (r_y - math.mod(r_y, 16))/16;
	--_guihelper.MessageBox("x:"..indexX.." y:"..indexY);
	
	local R, G, B;
	R = CCS_main.Matrix[""..indexY..indexX][1];
	G = CCS_main.Matrix[""..indexY..indexX][2];
	B = CCS_main.Matrix[""..indexY..indexX][3];
	
	--_guihelper.MessageBox("R:"..R.." G:"..G.." B:"..B);
	
	CCS_db.SetFaceComponent(CCS_UI_FaceComponent.Component, 
		CCS_db.CFS_SUB_Color, _guihelper.RGBA_TO_DWORD(R,G,B));
	
	
end

-- destroy the control
function CCS_main.OnDestroy()
	ParaUI.Destroy("kidui_ccs_level1_cartoonface_container");
	ParaUI.Destroy("kidui_ccs_level1_inventory_container");
	CCS_main.CurrentUIInterface = nil;
end

CCS_main.FacialHairType = 0;
CCS_main.MaxFacialHairType = 2;
function CCS_main.NextFacialHairType()
	local player, playerChar = CCS_db.GetPlayerChar();
	if(playerChar~=nil and playerChar:IsSupportCartoonFace()) then
		CCS_main.FacialHairType = math.mod(CCS_main.FacialHairType+1, CCS_main.MaxFacialHairType);
		playerChar:SetBodyParams(-1, -1,-1, -1, CCS_main.FacialHairType);
		log(CCS_main.FacialHairType.." is done.\n")
	end
end

-- OnClick face component matrix
function CCS_main.OnClickFaceComponent()
	CCS_UI_FaceComponent.SetFaceSection("Face");
	CCS_main.ShowUIInterface("CartoonFace");
	local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8"};
	_guihelper.CheckRadioButtons2(radiobuttons, "btn1", nil,
		"Texture/kidui/CCS/btn_CCS_CF_Empty_Highlight.png",
		"Texture/kidui/CCS/btn_CCS_CF_Empty_Normal.png");
	ParaUI.GetUIObject("CCS_Right_IconMatrix_Container").visible = true;
end
function CCS_main.OnClickWrinkleComponent()
	CCS_UI_FaceComponent.SetFaceSection("Wrinkle");
	CCS_main.ShowUIInterface("CartoonFace");
	local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8"};
	_guihelper.CheckRadioButtons2(radiobuttons, "btn2", nil,
		"Texture/kidui/CCS/btn_CCS_CF_Empty_Highlight.png",
		"Texture/kidui/CCS/btn_CCS_CF_Empty_Normal.png");
	ParaUI.GetUIObject("CCS_Right_IconMatrix_Container").visible = true;
end
function CCS_main.OnClickEyeComponent()
	CCS_UI_FaceComponent.SetFaceSection("Eye");
	CCS_main.ShowUIInterface("CartoonFace");
	local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8"};
	_guihelper.CheckRadioButtons2(radiobuttons, "btn3", nil,
		"Texture/kidui/CCS/btn_CCS_CF_Empty_Highlight.png",
		"Texture/kidui/CCS/btn_CCS_CF_Empty_Normal.png");
	ParaUI.GetUIObject("CCS_Right_IconMatrix_Container").visible = true;
end
function CCS_main.OnClickEyebrowComponent()
	CCS_UI_FaceComponent.SetFaceSection("Eyebrow");
	CCS_main.ShowUIInterface("CartoonFace");
	local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8"};
	_guihelper.CheckRadioButtons2(radiobuttons, "btn4", nil,
		"Texture/kidui/CCS/btn_CCS_CF_Empty_Highlight.png",
		"Texture/kidui/CCS/btn_CCS_CF_Empty_Normal.png");
	ParaUI.GetUIObject("CCS_Right_IconMatrix_Container").visible = true;
end
function CCS_main.OnClickMouthComponent()
	CCS_UI_FaceComponent.SetFaceSection("Mouth");
	CCS_main.ShowUIInterface("CartoonFace");
	local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8"};
	_guihelper.CheckRadioButtons2(radiobuttons, "btn5", nil,
		"Texture/kidui/CCS/btn_CCS_CF_Empty_Highlight.png",
		"Texture/kidui/CCS/btn_CCS_CF_Empty_Normal.png");
	ParaUI.GetUIObject("CCS_Right_IconMatrix_Container").visible = true;
end
function CCS_main.OnClickNoseComponent()
	CCS_UI_FaceComponent.SetFaceSection("Nose");
	CCS_main.ShowUIInterface("CartoonFace");
	local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8"};
	_guihelper.CheckRadioButtons2(radiobuttons, "btn6", nil,
		"Texture/kidui/CCS/btn_CCS_CF_Empty_Highlight.png",
		"Texture/kidui/CCS/btn_CCS_CF_Empty_Normal.png");
	ParaUI.GetUIObject("CCS_Right_IconMatrix_Container").visible = true;
end
function CCS_main.OnClickMarksComponent()
	CCS_UI_FaceComponent.SetFaceSection("Marks");
	CCS_main.ShowUIInterface("CartoonFace");
	local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8"};
	_guihelper.CheckRadioButtons2(radiobuttons, "btn7", nil,
		"Texture/kidui/CCS/btn_CCS_CF_Empty_Highlight.png",
		"Texture/kidui/CCS/btn_CCS_CF_Empty_Normal.png");
	ParaUI.GetUIObject("CCS_Right_IconMatrix_Container").visible = true;
end
function CCS_main.OnClickRandomComponent()
	--CCS_UI_FaceComponent.SetFaceSection("Wrinkle");
	--CCS_main.ShowUIInterface("CartoonFace");
	--local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8"};
	--_guihelper.CheckRadioButtons2(radiobuttons, "btn8", nil,
		--"Texture/kidui/CCS/btn_CCS_CF_Empty_Highlight.png",
		--"Texture/kidui/CCS/btn_CCS_CF_Empty_Normal.png");
	--ParaUI.GetUIObject("CCS_Right_IconMatrix_Container").visible = true;
end


CCS_main.PreviousActiveInventorySlot = nil;


function CCS_main.ChangeToInventorySlot(name)

	if(CCS_main.PreviousActiveInventorySlot == nil) then
		local btn1 =ParaUI.GetUIObject("btn1");
		-- Currently the first inventory slot invoke this field is inventory head slot
		btn1.background = "Texture/kidui/CCS/btn_CCS_IT_Head.png";
	elseif(CCS_main.PreviousActiveInventorySlot ~= name) then
		local prevBtn = ParaUI.GetUIObject(CCS_main.PreviousActiveInventorySlot);
		local currentBtn = ParaUI.GetUIObject(name);
		
		if(CCS_main.PreviousActiveInventorySlot == "btn1") then
			prevBtn.background = "Texture/kidui/CCS/btn_CCS_IT_Head_Fade.png";
		elseif(CCS_main.PreviousActiveInventorySlot == "btn2") then
			prevBtn.background = "Texture/kidui/CCS/btn_CCS_IT_Neck_Fade.png";
		elseif(CCS_main.PreviousActiveInventorySlot == "btn3") then
			prevBtn.background = "Texture/kidui/CCS/btn_CCS_IT_Shoulder_Fade.png";
		elseif(CCS_main.PreviousActiveInventorySlot == "btn4") then
			prevBtn.background = "Texture/kidui/CCS/btn_CCS_IT_Boots_Fade.png";
		elseif(CCS_main.PreviousActiveInventorySlot == "btn5") then
			prevBtn.background = "Texture/kidui/CCS/btn_CCS_IT_Belt_Fade.png";
		elseif(CCS_main.PreviousActiveInventorySlot == "btn6") then
			prevBtn.background = "Texture/kidui/CCS/btn_CCS_IT_Shirt_Fade.png";
		elseif(CCS_main.PreviousActiveInventorySlot == "btn7") then
			prevBtn.background = "Texture/kidui/CCS/btn_CCS_IT_Pants_Fade.png";
		elseif(CCS_main.PreviousActiveInventorySlot == "btn8") then
			prevBtn.background = "Texture/kidui/CCS/btn_CCS_IT_Chest_Fade.png";
		elseif(CCS_main.PreviousActiveInventorySlot == "btn9") then
			prevBtn.background = "Texture/kidui/CCS/btn_CCS_IT_Bracers_Fade.png";
		elseif(CCS_main.PreviousActiveInventorySlot == "btn10") then
			prevBtn.background = "Texture/kidui/CCS/btn_CCS_IT_Gloves_Fade.png";
		elseif(CCS_main.PreviousActiveInventorySlot == "btn11") then
			prevBtn.background = "Texture/kidui/CCS/btn_CCS_IT_HandRight_Fade.png";
		elseif(CCS_main.PreviousActiveInventorySlot == "btn12") then
			prevBtn.background = "Texture/kidui/CCS/btn_CCS_IT_HandLeft_Fade.png";
		elseif(CCS_main.PreviousActiveInventorySlot == "btn13") then
			prevBtn.background = "Texture/kidui/CCS/btn_CCS_IT_Cape_Fade.png";
		elseif(CCS_main.PreviousActiveInventorySlot == "btn14") then
			prevBtn.background = "Texture/kidui/CCS/btn_CCS_IT_Tabard_Fade.png";
		end
		
		if(name == "btn1") then
			currentBtn.background = "Texture/kidui/CCS/btn_CCS_IT_Head.png";
		elseif(name == "btn2") then
			currentBtn.background = "Texture/kidui/CCS/btn_CCS_IT_Neck.png";
		elseif(name == "btn3") then
			currentBtn.background = "Texture/kidui/CCS/btn_CCS_IT_Shoulder.png";
		elseif(name == "btn4") then
			currentBtn.background = "Texture/kidui/CCS/btn_CCS_IT_Boots.png";
		elseif(name == "btn5") then
			currentBtn.background = "Texture/kidui/CCS/btn_CCS_IT_Belt.png";
		elseif(name == "btn6") then
			currentBtn.background = "Texture/kidui/CCS/btn_CCS_IT_Shirt.png";
		elseif(name == "btn7") then
			currentBtn.background = "Texture/kidui/CCS/btn_CCS_IT_Pants.png";
		elseif(name == "btn8") then
			currentBtn.background = "Texture/kidui/CCS/btn_CCS_IT_Chest.png";
		elseif(name == "btn9") then
			currentBtn.background = "Texture/kidui/CCS/btn_CCS_IT_Bracers.png";
		elseif(name == "btn10") then
			currentBtn.background = "Texture/kidui/CCS/btn_CCS_IT_Gloves.png";
		elseif(name == "btn11") then
			currentBtn.background = "Texture/kidui/CCS/btn_CCS_IT_HandRight.png";
		elseif(name == "btn12") then
			currentBtn.background = "Texture/kidui/CCS/btn_CCS_IT_HandLeft.png";
		elseif(name == "btn13") then
			currentBtn.background = "Texture/kidui/CCS/btn_CCS_IT_Cape.png";
		elseif(name == "btn14") then
			currentBtn.background = "Texture/kidui/CCS/btn_CCS_IT_Tabard.png";
		end
		
	end
	CCS_main.PreviousActiveInventorySlot = name;
	
end

-- OnClick item inventory matrix
function CCS_main.OnClickHeadInventory()
	CCS_UI_InventorySlot.SetInventorySlot("Head");
	--CCS_main.ShowUIInterface("Inventory");
	local cont =ParaUI.GetUIObject("CCS_UI_Inventory_level2_container");
	CCS_UI_Inventory_Head.Show(cont);
	
	CCS_main.ChangeToInventorySlot("btn1");
	
	--local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8","btn9","btn10","btn11","btn12","btn13","btn14"};
	--_guihelper.CheckRadioButtons2(radiobuttons, "btn1", nil,
		--"Texture/kidui/CCS/btn_CCS_IT_Empty_Highlight.png",
		--"Texture/kidui/CCS/btn_CCS_IT_Empty_Normal.png");
end
function CCS_main.OnClickNeckInventory()
	CCS_UI_InventorySlot.SetInventorySlot("Neck");
	CCS_main.ShowUIInterface("Inventory");
	local cont =ParaUI.GetUIObject("CCS_UI_Inventory_level2_container");
	CCS_UI_Inventory_Head.Show(cont);
	
	CCS_main.ChangeToInventorySlot("btn2");
	
	--local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8","btn9","btn10","btn11","btn12","btn13","btn14"};
	--_guihelper.CheckRadioButtons2(radiobuttons, "btn2", nil,
		--"Texture/kidui/CCS/btn_CCS_IT_Empty_Highlight.png",
		--"Texture/kidui/CCS/btn_CCS_IT_Empty_Normal.png");
end
function CCS_main.OnClickShoulderInventory()
	CCS_UI_InventorySlot.SetInventorySlot("Shoulder");
	CCS_main.ShowUIInterface("Inventory");
	local cont =ParaUI.GetUIObject("CCS_UI_Inventory_level2_container");
	CCS_UI_Inventory_Head.Show(cont);
	
	CCS_main.ChangeToInventorySlot("btn3");
	
	--local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8","btn9","btn10","btn11","btn12","btn13","btn14"};
	--_guihelper.CheckRadioButtons2(radiobuttons, "btn3", nil,
		--"Texture/kidui/CCS/btn_CCS_IT_Empty_Highlight.png",
		--"Texture/kidui/CCS/btn_CCS_IT_Empty_Normal.png");
end
function CCS_main.OnClickBootsInventory()
	CCS_UI_InventorySlot.SetInventorySlot("Boots");
	CCS_main.ShowUIInterface("Inventory");
	local cont =ParaUI.GetUIObject("CCS_UI_Inventory_level2_container");
	CCS_UI_Inventory_Head.Show(cont);
	
	CCS_main.ChangeToInventorySlot("btn4");
	
	--local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8","btn9","btn10","btn11","btn12","btn13","btn14"};
	--_guihelper.CheckRadioButtons2(radiobuttons, "btn4", nil,
		--"Texture/kidui/CCS/btn_CCS_IT_Empty_Highlight.png",
		--"Texture/kidui/CCS/btn_CCS_IT_Empty_Normal.png");
end
function CCS_main.OnClickBeltInventory()
	CCS_UI_InventorySlot.SetInventorySlot("Belt");
	CCS_main.ShowUIInterface("Inventory");
	local cont =ParaUI.GetUIObject("CCS_UI_Inventory_level2_container");
	CCS_UI_Inventory_Head.Show(cont);
	
	CCS_main.ChangeToInventorySlot("btn5");
	
	--local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8","btn9","btn10","btn11","btn12","btn13","btn14"};
	--_guihelper.CheckRadioButtons2(radiobuttons, "btn5", nil,
		--"Texture/kidui/CCS/btn_CCS_IT_Empty_Highlight.png",
		--"Texture/kidui/CCS/btn_CCS_IT_Empty_Normal.png");
end
function CCS_main.OnClickShirtInventory()
	CCS_UI_InventorySlot.SetInventorySlot("Shirt");
	CCS_main.ShowUIInterface("Inventory");
	local cont =ParaUI.GetUIObject("CCS_UI_Inventory_level2_container");
	CCS_UI_Inventory_Head.Show(cont);
	
	CCS_main.ChangeToInventorySlot("btn6");
	
	--local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8","btn9","btn10","btn11","btn12","btn13","btn14"};
	--_guihelper.CheckRadioButtons2(radiobuttons, "btn6", nil,
		--"Texture/kidui/CCS/btn_CCS_IT_Empty_Highlight.png",
		--"Texture/kidui/CCS/btn_CCS_IT_Empty_Normal.png");
end
function CCS_main.OnClickPantsInventory()
	CCS_UI_InventorySlot.SetInventorySlot("Pants");
	CCS_main.ShowUIInterface("Inventory");
	local cont =ParaUI.GetUIObject("CCS_UI_Inventory_level2_container");
	CCS_UI_Inventory_Head.Show(cont);
	
	CCS_main.ChangeToInventorySlot("btn7");
	
	--local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8","btn9","btn10","btn11","btn12","btn13","btn14"};
	--_guihelper.CheckRadioButtons2(radiobuttons, "btn7", nil,
		--"Texture/kidui/CCS/btn_CCS_IT_Empty_Highlight.png",
		--"Texture/kidui/CCS/btn_CCS_IT_Empty_Normal.png");
end
function CCS_main.OnClickChestInventory()
	CCS_UI_InventorySlot.SetInventorySlot("Chest");
	CCS_main.ShowUIInterface("Inventory");
	local cont =ParaUI.GetUIObject("CCS_UI_Inventory_level2_container");
	CCS_UI_Inventory_Head.Show(cont);
	
	CCS_main.ChangeToInventorySlot("btn8");
	
	--local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8","btn9","btn10","btn11","btn12","btn13","btn14"};
	--_guihelper.CheckRadioButtons2(radiobuttons, "btn8", nil,
		--"Texture/kidui/CCS/btn_CCS_IT_Empty_Highlight.png",
		--"Texture/kidui/CCS/btn_CCS_IT_Empty_Normal.png");
end
function CCS_main.OnClickBracersInventory()
	CCS_UI_InventorySlot.SetInventorySlot("Bracers");
	CCS_main.ShowUIInterface("Inventory");
	local cont =ParaUI.GetUIObject("CCS_UI_Inventory_level2_container");
	CCS_UI_Inventory_Head.Show(cont);
	
	CCS_main.ChangeToInventorySlot("btn9");
	
	--local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8","btn9","btn10","btn11","btn12","btn13","btn14"};
	--_guihelper.CheckRadioButtons2(radiobuttons, "btn9", nil,
		--"Texture/kidui/CCS/btn_CCS_IT_Empty_Highlight.png",
		--"Texture/kidui/CCS/btn_CCS_IT_Empty_Normal.png");
end
function CCS_main.OnClickGlovesInventory()
	CCS_UI_InventorySlot.SetInventorySlot("Gloves");
	CCS_main.ShowUIInterface("Inventory");
	local cont =ParaUI.GetUIObject("CCS_UI_Inventory_level2_container");
	CCS_UI_Inventory_Head.Show(cont);
	
	CCS_main.ChangeToInventorySlot("btn10");
	
	--local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8","btn9","btn10","btn11","btn12","btn13","btn14"};
	--_guihelper.CheckRadioButtons2(radiobuttons, "btn10", nil,
		--"Texture/kidui/CCS/btn_CCS_IT_Empty_Highlight.png",
		--"Texture/kidui/CCS/btn_CCS_IT_Empty_Normal.png");
end
function CCS_main.OnClickHandRightInventory()
	CCS_UI_InventorySlot.SetInventorySlot("HandRight");
	CCS_main.ShowUIInterface("Inventory");
	local cont =ParaUI.GetUIObject("CCS_UI_Inventory_level2_container");
	CCS_UI_Inventory_Head.Show(cont);
	
	CCS_main.ChangeToInventorySlot("btn11");
	
	--local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8","btn9","btn10","btn11","btn12","btn13","btn14"};
	--_guihelper.CheckRadioButtons2(radiobuttons, "btn11", nil,
		--"Texture/kidui/CCS/btn_CCS_IT_Empty_Highlight.png",
		--"Texture/kidui/CCS/btn_CCS_IT_Empty_Normal.png");
end
function CCS_main.OnClickHandLeftInventory()
	CCS_UI_InventorySlot.SetInventorySlot("HandLeft");
	CCS_main.ShowUIInterface("Inventory");
	local cont =ParaUI.GetUIObject("CCS_UI_Inventory_level2_container");
	CCS_UI_Inventory_Head.Show(cont);
	
	CCS_main.ChangeToInventorySlot("btn12");
	
	--local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8","btn9","btn10","btn11","btn12","btn13","btn14"};
	--_guihelper.CheckRadioButtons2(radiobuttons, "btn12", nil,
		--"Texture/kidui/CCS/btn_CCS_IT_Empty_Highlight.png",
		--"Texture/kidui/CCS/btn_CCS_IT_Empty_Normal.png");
end
function CCS_main.OnClickCapeInventory()
	CCS_UI_InventorySlot.SetInventorySlot("Cape");
	CCS_main.ShowUIInterface("Inventory");
	local cont =ParaUI.GetUIObject("CCS_UI_Inventory_level2_container");
	CCS_UI_Inventory_Head.Show(cont);
	
	CCS_main.ChangeToInventorySlot("btn13");
	
	--local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8","btn9","btn10","btn11","btn12","btn13","btn14"};
	--_guihelper.CheckRadioButtons2(radiobuttons, "btn13", nil,
		--"Texture/kidui/CCS/btn_CCS_IT_Empty_Highlight.png",
		--"Texture/kidui/CCS/btn_CCS_IT_Empty_Normal.png");
end
function CCS_main.OnClickTabardInventory()
	CCS_UI_InventorySlot.SetInventorySlot("Tabard");
	CCS_main.ShowUIInterface("Inventory");
	local cont =ParaUI.GetUIObject("CCS_UI_Inventory_level2_container");
	CCS_UI_Inventory_Head.Show(cont);
	
	CCS_main.ChangeToInventorySlot("btn14");
	
	--local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8","btn9","btn10","btn11","btn12","btn13","btn14"};
	--_guihelper.CheckRadioButtons2(radiobuttons, "btn14", nil,
		--"Texture/kidui/CCS/btn_CCS_IT_Empty_Highlight.png",
		--"Texture/kidui/CCS/btn_CCS_IT_Empty_Normal.png");
end



--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
--Original Show function
function CCS_main.Show(bShow)
	local _this,_parent;
	
	_this=ParaUI.GetUIObject("CCS_main_cont");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		
		_this=ParaUI.CreateUIObject("container","CCS_main_cont","_lt",12, 12, 790, 558);
		--_this:SetTopLevel(true);
		_this:AttachToRoot();
		_parent = _this;

		_this = ParaUI.CreateUIObject("button", "button1", "_lt", 13, 12, 48, 48)
		_this.text = "人物";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button2", "_lt", 78, 12, 48, 48)
		_this.text = "卡童脸";
		_this.onclick = ";CCS_main.NextFacialHairType();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button15", "_lt", 16, 412, 48, 48)
		_this.text = "头";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button17", "_lt", 16, 479, 93, 30)
		_this.text = "上传";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button18", "_lt", 115, 479, 93, 30)
		_this.text = "下载";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button16", "_lt", 70, 412, 48, 48)
		_this.text = "身";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button9", "_lt", 16, 374, 32, 32)
		_this.text = "＋";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button10", "_lt", 54, 374, 32, 32)
		_this.text = "－";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button11", "_lt", 110, 374, 32, 32)
		_this.text = "<-";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button12", "_lt", 148, 374, 32, 32)
		_this.text = "->";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button13", "_lt", 186, 374, 32, 32)
		_this.text = "Up";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button14", "_lt", 224, 374, 32, 32)
		_this.text = "Dn";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button3", "_lt", 132, 12, 48, 48)
		_this.text = "脸型";
		_this.onclick = ";CCS_main.ShowUIInterface(CCS_UI_CartoonFace);CCS_UI_Eyebrow.Section=CCS_db.CFS_FACE;";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button4", "_lt", 186, 12, 48, 48)
		_this.text = "眉毛";
		_this.onclick = ";CCS_main.ShowUIInterface(CCS_UI_Eyebrow);CCS_UI_Eyebrow.Section=CCS_db.CFS_EYEBROW;";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button5", "_lt", 240, 12, 48, 48)
		_this.text = "眼睛";
		_this.onclick = ";CCS_main.ShowUIInterface(CCS_UI_Eyebrow);CCS_UI_Eyebrow.Section=CCS_db.CFS_EYE;";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button6", "_lt", 294, 12, 48, 48)
		_this.text = "鼻子";
		_this.onclick = ";CCS_main.ShowUIInterface(CCS_UI_Eyebrow);CCS_UI_Eyebrow.Section=CCS_db.CFS_NOSE;";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button7", "_lt", 348, 12, 48, 48)
		_this.text = "嘴巴";
		_this.onclick = ";CCS_main.ShowUIInterface(CCS_UI_Eyebrow);CCS_UI_Eyebrow.Section=CCS_db.CFS_MOUTH;";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button8", "_lt", 402, 12, 48, 48)
		_this.text = "胡子";
		_this.onclick = ";CCS_main.ShowUIInterface(CCS_UI_Eyebrow);CCS_UI_Eyebrow.Section=CCS_db.CFS_WRINKLE;";
		_parent:AddChild(_this);


		_this = ParaUI.CreateUIObject("button", "random", "_lt", 278, 71, 48, 48)
		_this.text = "随机";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button20", "_lt", 278, 125, 48, 48)
		_this.text = "头部";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button21", "_lt", 278, 179, 48, 48)
		_this.text = "脸部";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button22", "_lt", 278, 233, 48, 48)
		_this.text = "衣服";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button23", "_lt", 278, 287, 48, 48)
		_this.text = "裤子";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button24", "_lt", 278, 341, 48, 48)
		_this.text = "手";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button25", "_lt", 278, 395, 48, 48)
		_this.text = "披风";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button26", "_lt", 278, 449, 48, 48)
		_this.text = "套装";
		_this.onclick=";CCS_main.ShowUIInterface(CCS_UI_Predefined);";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("text", "label1", "_lt", 10, 74, 48, 16)
		_this.text = "名字:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("editbox", "textBox1", "_lt", 64, 71, 170, 26)
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnClose", "_rt", -60, 12, 48, 48)
		_this.text = "关闭";
		_this.onclick=";ParaUI.Destroy(\"CCS_main_cont\");";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("3dcanvas", "CharCanvas", "_lt", 16, 103, 256, 256)
		_parent:AddChild(_this);
		_this.canvasindex=0;
		_this.background="Texture/whitedot.png;0 0 0 0";
		--_texture=_this:GetTexture("background");
		--_texture.color="255 255 255";
		
		_this = ParaUI.CreateUIObject("container", "OriginalInterfaceContainer", "_lt", 332, 71, 400, 450)
		_this.background="Texture/whitedot.png;0 0 0 0";
		_parent:AddChild(_this);
	else
		if(bShow == nil) then
			bShow = (_this.visible == false);
		end
		_this.visible = bShow;
		
		--if(bShow == true) then 
			--_this:SetTopLevel(true);
		--end
	end	
	CCS_UI_Predefined.Show(_this);
	--CCS_main.ShowUIInterface("CCS_UI_Predefined");
	
end



--Function: show cface control
--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function CCS_main.ShowHairFace(bShow)
	local _this,_parent;
	
	_this=ParaUI.GetUIObject("kidui_ccs_level1_inventory_container");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		
		local toLeft = CCS_main.ToLeft;
		local toBottom = CCS_main.ToBottom;
		local toRight = CCS_main.ToRight;
		local midHeight = CCS_main.MidHeight;
		
		_this=ParaUI.CreateUIObject("container","kidui_ccs_level1_inventory_container","_lt",0,0,toRight,midHeight);
		--_this:SetTopLevel(true);
		--_this:AttachToRoot();
		--_guihelper.MessageBox(toLeft.." "..toBottom.." "..toRight.." "..midHeight);
		
		local kidsUIContainer = ParaUI.GetUIObject("kidui_ccs_container");
		kidsUIContainer:AddChild(_this);
		
		_this.background="Texture/whitedot.png;0 0 0 0";
		_parent = _this;
		
		

_this = ParaUI.CreateUIObject("button", "btn1", "_lt", 0, 6, 48, 48)
_this.text = "Head";
_this.background="Texture/kidui/CCS/btn_CCS_IT_Head.png";
_this.onclick = ";CCS_main.OnClickHeadInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn2", "_lt", 48, 6, 48, 48)
_this.text = "Neck";
_this.background="Texture/kidui/CCS/btn_CCS_IT_Neck.png";
_this.onclick = ";CCS_main.OnClickNeckInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn3", "_lt", 96, 6, 48, 48)
_this.text = "Shoulder";
_this.background="Texture/kidui/CCS/btn_CCS_IT_Shoulder.png";
_this.onclick = ";CCS_main.OnClickShoulderInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn4", "_lt", 144, 6, 48, 48)
_this.text = "Boots";
_this.background="Texture/kidui/CCS/btn_CCS_IT_Boots.png";
_this.onclick = ";CCS_main.OnClickBootsInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn5", "_lt", 192, 6, 48, 48)
_this.text = "Belt";
_this.background="Texture/kidui/CCS/btn_CCS_IT_Belt.png";
_this.onclick = ";CCS_main.OnClickBeltInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn6", "_lt", 0, 54, 48, 48)
_this.text = "Shirt";
_this.background="Texture/kidui/CCS/btn_CCS_IT_Shirt.png";
_this.onclick = ";CCS_main.OnClickShirtInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn7", "_lt", 48, 54, 48, 48)
_this.text = "Pants";
_this.background="Texture/kidui/CCS/btn_CCS_IT_Pants.png";
_this.onclick = ";CCS_main.OnClickPantsInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn8", "_lt", 96, 54, 48, 48)
_this.text = "Chest";
_this.background="Texture/kidui/CCS/btn_CCS_IT_Chest.png";
_this.onclick = ";CCS_main.OnClickChestInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn9", "_lt", 144, 54, 48, 48)
_this.text = "Bracers";
_this.background="Texture/kidui/CCS/btn_CCS_IT_Bracers.png";
_this.onclick = ";CCS_main.OnClickBracersInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn10", "_lt", 192, 54, 48, 48)
_this.text = "Gloves";
_this.background="Texture/kidui/CCS/btn_CCS_IT_Gloves.png";
_this.onclick = ";CCS_main.OnClickGlovesInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn11", "_lt", 0, 102, 48, 48)
_this.text = "HandRight";
_this.background="Texture/kidui/CCS/btn_CCS_IT_HandRight.png";
_this.onclick = ";CCS_main.OnClickHandRightInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn12", "_lt", 48, 102, 48, 48)
_this.text = "HandLeft";
_this.background="Texture/kidui/CCS/btn_CCS_IT_HandLeft.png";
_this.onclick = ";CCS_main.OnClickHandLeftInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn13", "_lt", 96, 102, 48, 48)
_this.text = "Cape";
_this.background="Texture/kidui/CCS/btn_CCS_IT_Cape.png";
_this.onclick = ";CCS_main.OnClickCapeInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn14", "_lt", 144, 102, 48, 48)
_this.text = "Tabard";
_this.background="Texture/kidui/CCS/btn_CCS_IT_Tabard.png";
_this.onclick = ";CCS_main.OnClickTabardInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn_Inv_Return", "_lt", 192, 102, 48, 48)
_this.text = "Return";
_this.background="Texture/kidui/CCS/btn_CCS_IT_Return.png";
_this.onclick = ";CCS_main.OnDestroy();ParaUI.GetUIObject(\"kidui_ccs_level0_container\").visible = true; CCS_main.UpdateCharacterInfo();";
_parent:AddChild(_this);

		
		
		
NPL.load("(gl)script/kids/ui/middle_container.lua");

local lvl0 = ParaUI.GetUIObject("kidui_ccs_level0_container");
lvl0.visible = false;
		
		--
		--_this = ParaUI.CreateUIObject("container", "InterfaceContainer", "_fi", 332, 71, 12, 14)
		--_this.background="Texture/whitedot.png;0 0 0 0";
		--_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("container", "CCS_UI_Inventory_level2_container", "_lt", 258, 0, 264, 150)
		_this.background="Texture/whitedot.png;0 0 0 0";
		_parent:AddChild(_this);
		
	else
		if(bShow == nil) then
			bShow = (_this.visible == false);
		end
		_this.visible = bShow;
		
		if(bShow == true) then 
			--_this:SetTopLevel(true);
		end
	end	
	
	CCS_main.OnClickHeadInventory();
	--CCS_main.ShowUIInterface(CCS_UI_Predefined);
end