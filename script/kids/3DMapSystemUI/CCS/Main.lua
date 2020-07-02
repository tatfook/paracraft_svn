--[[
Title: Character Customization System main enterance for 3D Map System
Author(s): WangTian
Date: 2007/10/29
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/CCS/Main.lua");
-------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystemUI/CCS/ccs.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/CCS/CartoonFace.lua");

local CCS = commonlib.gettable("Map3DSystem.UI.CCS");

-- the new aura user interface enhance the user experience in the column window on the side of the screen
-- categories in enlisted on the side and show as many candidates as possible
-- draw the CCS interface with the new aura design
function CCS.ShowAuraCCSInterface(bShow, parent, wnd)
	-- draw the CCS interface with the new aura design
	
	-- draw the categories
	
	local _categories_ItemSlot = {};
	local _categories_CartoonFace = {};
	
	-- the item slot category slot in the cartoon face phase
	-- create a category container for the item slots in case of changing position, e.x. left align to right align
	-- and the height is according to the slot numbers
	local _x, _y;
	local _iconWidth, _iconHeight;
	local k, v;
	for k, v in _categories_CartoonFace do
		-- for each character item slot build the icon on the side
		local _this = ParaUI.CreateUIObject("button", "btn3", "_lt", 96, 6, 48, 48);
		_this.background = nil;
		_this.text = k;
		_this.tooltip = "tooltip";
		_this.onclick = ";Map3DSystem.UI.CCS.OnClickCartoonFaceComponent("..k..");";
		_parent:AddChild(_this);
	end
	
	local _this = ParaUI.CreateUIObject("button", "btn3", "_lt", 96, 6, 48, 48)
	_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_CF_Eye.png", 
		"Texture/3DMapSystem/CCS/btn_CCS_CF_Empty_Normal.png");
	--_this.text = "Eye";
	_this.animstyle = 11;
	_this.tooltip = "Eye";
	_this.onclick = ";Map3DSystem.UI.CCS.OnClickEyeComponent();";
	_parent:AddChild(_this);
end

-- change the cartoon face component category
-- @param index: the index into the CartoonFace category table
function CCS.OnClickCartoonFaceComponent(index)
end

-- init message system: call this function at main bar initialization to init the message system for CCS
function CCS.InitMessageSystem()
	NPL.load("(gl)script/ide/os.lua");
	local _app = CommonCtrl.os.CreateGetApp("CCS");
	CCS.App = _app;
	CCS.MainWnd = _app:RegisterWindow("CCSMain", nil, CCS.MSGProc);
end

-- send a message to CCS:CCSMain window handler
-- e.g. CCS.SendMeMessage({type = Map3DSystem.msg.MAINBAR_Show})
function CCS.SendMeMessage(msg)
	msg.wndName = CCS.MainWnd.name;
	CCS.App:SendMessage(msg);
end

-- CCS: CCSMain window handler
function CCS.MSGProc()
	---- TODO: set according to CCS specification
	--
	--if(msg.type == Map3DSystem.msg.MAINBAR_Show) then
		---- show, hide or toggle the main bar UI
		--Map3DSystem.UI.MainBar.ShowUI(msg.bShow);
	--elseif(msg.type == Map3DSystem.msg.MAINBAR_NavMode) then
		---- true or false navigation mode
		---- true: switch to navmode, false switch back to edit mode
		--Map3DSystem.UI.MainBar.SwitchNavigationMode(msg.bNavMode);
	--elseif(msg.type == Map3DSystem.msg.MAINBAR_BounceIcon) then
		---- play animation to icon with "bounce" common animation
		--Map3DSystem.UI.MainBar.BounceIcon(msg.iconID, msg.isLooping, msg.isAnimate);
	--elseif(msg.type == Map3DSystem.msg.MAINBAR_SwitchStatus) then
		---- switch to main bar display status
		--if(msg.sStatus == "none") then
			--Map3DSystem.UI.MainBar.SwitchToStatus("none");
		--elseif(msg.sStatus == "character") then
			--Map3DSystem.UI.MainBar.SwitchToStatus("character");
		--elseif(msg.sStatus == "model") then
			--Map3DSystem.UI.MainBar.SwitchToStatus("model");
			--log("model\n");
		--elseif(msg.sStatus == "BCSXRef") then
			---- TODO: show the model status, and creation panel with BCS on first trigger
			---- TODO: hint of the creation point
			--Map3DSystem.UI.MainBar.SwitchToStatus("BCSXRef");
		--end
	--end
end

--Function: show cartoon face control
--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function CCS.ShowCartoonFace(bShow)
	
	local _this,_parent;
	
	_this = ParaUI.GetUIObject("map3dsystem_ccs_level1_cartoonface_container");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		
		local toLeft = CCS.ToLeft;
		local toBottom = CCS.ToBottom;
		local toRight = CCS.ToRight;
		local midHeight = CCS.MidHeight;
		
		_this = ParaUI.CreateUIObject("container","map3dsystem_ccs_level1_cartoonface_container","_lt",0,0,toRight,midHeight);
		--_this:SetTopLevel(true);
		--_this:AttachToRoot();
		--_guihelper.MessageBox(toLeft.." "..toBottom.." "..toRight.." "..midHeight);
		
		local _CCSUIContainer = ParaUI.GetUIObject("map3dsystem_ccs_container");
		_CCSUIContainer:AddChild(_this);
		
		_this.background = "Texture/whitedot.png;0 0 0 0";
		_parent = _this;
		



_this = ParaUI.CreateUIObject("button", "btn1", "_lt", 0, 6, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_CF_Face.png", 
	"Texture/3DMapSystem/CCS/btn_CCS_CF_Empty_Normal.png");
--_this.text = "Face";
_this.animstyle = 11;
_this.tooltip = "脸";
_this.onclick = ";Map3DSystem.UI.CCS.OnClickFaceComponent();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn2", "_lt", 48, 6, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_CF_Wrinkle.png", 
	"Texture/3DMapSystem/CCS/btn_CCS_CF_Empty_Normal.png");
--_this.text = "Wrinkle";
_this.animstyle = 11;
_this.tooltip = "皱纹";
_this.onclick = ";Map3DSystem.UI.CCS.OnClickWrinkleComponent();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn3", "_lt", 96, 6, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_CF_Eye.png", 
	"Texture/3DMapSystem/CCS/btn_CCS_CF_Empty_Normal.png");
--_this.text = "Eye";
_this.animstyle = 11;
_this.tooltip = "眼睛";
_this.onclick = ";Map3DSystem.UI.CCS.OnClickEyeComponent();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn4", "_lt", 0, 54, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_CF_Eyebrow.png", 
	"Texture/3DMapSystem/CCS/btn_CCS_CF_Empty_Normal.png");
--_this.text = "Brow";
_this.animstyle = 11;
_this.tooltip = "眉毛";
_this.onclick = ";Map3DSystem.UI.CCS.OnClickEyebrowComponent();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn5", "_lt", 48, 54, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_CF_Mouth.png", 
	"Texture/3DMapSystem/CCS/btn_CCS_CF_Empty_Normal.png");
--_this.text = "Mouth";
_this.animstyle = 11;
_this.tooltip = "嘴巴";
_this.onclick = ";Map3DSystem.UI.CCS.OnClickMouthComponent();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn6", "_lt", 96, 54, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_CF_Nose.png", 
	"Texture/3DMapSystem/CCS/btn_CCS_CF_Empty_Normal.png");
--_this.text = "Nose";
_this.animstyle = 11;
_this.tooltip = "鼻子";
_this.onclick = ";Map3DSystem.UI.CCS.OnClickNoseComponent();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn7", "_lt", 0, 102, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_CF_Marks.png", 
	"Texture/3DMapSystem/CCS/btn_CCS_CF_Empty_Normal.png");
--_this.text = "Marks";
_this.animstyle = 11;
_this.tooltip = "标志";
_this.onclick = ";Map3DSystem.UI.CCS.OnClickMarksComponent();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn8", "_lt", 48, 102, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_CF_Random.png", 
	"Texture/3DMapSystem/CCS/btn_CCS_CF_Empty_Normal.png");
--_this.text = "CartoonFaceType";
_this.animstyle = 11;
_this.tooltip = "脸形";
_this.onclick = ";Map3DSystem.UI.CCS.Predefined.NextCartoonFaceType();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btnReturn", "_lt", 96, 102, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_CF_Return.png", 
	"Texture/3DMapSystem/CCS/btn_CCS_CF_Empty_Normal.png");
--_this.text = "Return";
_this.animstyle = 11;
_this.tooltip = "返回上一级";
_this.onclick = ";Map3DSystem.UI.CCS.OnDestroy();ParaUI.GetUIObject(\"map3dsystem_ccs_level0_container\").visible = true;"; --CCS.UpdateCharacterInfo();";
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

_this = ParaUI.CreateUIObject("button", "btnMoveUp", "_rt", -158, 0, 32, 32)
_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_CF_ShiftY_Up.png", 
	"Texture/3DMapSystem/CCS/btn_CCS_CF_Modify_BG.png");
--_this.text = "/\\";
_this.animstyle = 11;
_this.tooltip = "向上平移";
--_this.background="Texture/3DMapSystem/CCS/btn_CCS_CF_ShiftY_Up.png";
_this.onclick = ";Map3DSystem.UI.CCS.CartoonFaceComponent.SetFaceComponent(CCS.DB.CFS_SUB_Y, -2);";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btnMoveDown", "_rt", -116, 0, 32, 32)
_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_CF_ShiftY_Down.png", 
	"Texture/3DMapSystem/CCS/btn_CCS_CF_Modify_BG.png");
--_this.text = "\\/";
_this.animstyle = 11;
_this.tooltip = "向下平移";
--_this.background="Texture/3DMapSystem/CCS/btn_CCS_CF_ShiftY_Down.png";
_this.onclick = ";Map3DSystem.UI.CCS.CartoonFaceComponent.SetFaceComponent(CCS.DB.CFS_SUB_Y, 2);";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btnZoomIn", "_rt", -158, 38, 32, 32)
_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_CF_ZoomIn.png", 
	"Texture/3DMapSystem/CCS/btn_CCS_CF_Modify_BG.png");
--_this.text = "+";
_this.animstyle = 11;
_this.tooltip = "放大";
--_this.background="Texture/3DMapSystem/CCS/btn_CCS_CF_ZoomIn.png";
_this.onclick = ";Map3DSystem.UI.CCS.CartoonFaceComponent.SetFaceComponent(CCS.DB.CFS_SUB_Scale, 0.1);";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btnZoomOut", "_rt", -116, 38, 32, 32)
_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_CF_ZoomOut.png", 
	"Texture/3DMapSystem/CCS/btn_CCS_CF_Modify_BG.png");
--_this.text = "-";
_this.animstyle = 11;
_this.tooltip = "缩小";
--_this.background="Texture/3DMapSystem/CCS/btn_CCS_CF_ZoomOut.png";
_this.onclick = ";Map3DSystem.UI.CCS.CartoonFaceComponent.SetFaceComponent(CCS.DB.CFS_SUB_Scale, -0.1);";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btnRotateClockwise", "_rt", -158, 76, 32, 32)
_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_CF_Rotate_Clockwise.png", 
	"Texture/3DMapSystem/CCS/btn_CCS_CF_Modify_BG.png");
--_this.text = "(";
_this.animstyle = 11;
_this.tooltip = "顺时针旋转";
--_this.background="Texture/3DMapSystem/CCS/btn_CCS_CF_Rotate_Clockwise.png";
_this.onclick = ";Map3DSystem.UI.CCS.CartoonFaceComponent.SetFaceComponent(CCS.DB.CFS_SUB_Rotation, 0.1);";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btnRotateAntiClockwise", "_rt", -116, 76, 32, 32)
_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_CF_Rotate_AntiClockwise.png", 
	"Texture/3DMapSystem/CCS/btn_CCS_CF_Modify_BG.png");
--_this.text = ")";
_this.animstyle = 11;
_this.tooltip = "逆时针旋转";
--_this.background="Texture/3DMapSystem/CCS/btn_CCS_CF_Rotate_AntiClockwise.png";
_this.onclick = ";Map3DSystem.UI.CCS.CartoonFaceComponent.SetFaceComponent(CCS.DB.CFS_SUB_Rotation, -0.1);";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btnMoveLeft", "_rt", -158, 114, 32, 32)
_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_CF_ShiftX_Left.png", 
	"Texture/3DMapSystem/CCS/btn_CCS_CF_Modify_BG.png");
--_this.text = "<";
_this.animstyle = 11;
_this.tooltip = "左移/靠近";
--_this.background="Texture/3DMapSystem/CCS/btn_CCS_CF_ShiftX_Left.png";
_this.onclick = ";Map3DSystem.UI.CCS.CartoonFaceComponent.SetFaceComponent(CCS.DB.CFS_SUB_X, -1);";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btnMoveRight", "_rt", -116, 114, 32, 32)
_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_CF_ShiftX_Right.png", 
	"Texture/3DMapSystem/CCS/btn_CCS_CF_Modify_BG.png");
--_this.text = ">";
_this.animstyle = 11;
_this.tooltip = "右移/分开";
--_this.background="Texture/3DMapSystem/CCS/btn_CCS_CF_ShiftX_Right.png";
_this.onclick = ";Map3DSystem.UI.CCS.CartoonFaceComponent.SetFaceComponent(CCS.DB.CFS_SUB_X, 1);";
_parent:AddChild(_this);



-- Color Palette

_this = ParaUI.CreateUIObject("button", "btnColorPalette", "_rt", -64, 16, 64, 128)
_guihelper.SetVistaStyleButtonBright(_this, "Texture/3DMapSystem/CCS/btn_CCS_ColorPalette.png");
--_this.text = "Color Palette";
_this.tooltip = "调色板";
_this.onclick = ";Map3DSystem.UI.CCS.OnClickColorPalette();";
_parent:AddChild(_this);



		local _lvl0 = ParaUI.GetUIObject("map3dsystem_ccs_level0_container");
		_lvl0.visible = false;
		
	else
		if(bShow == nil) then
			bShow = (_this.visible == false);
		end
		_this.visible = bShow;
		
		if(bShow == true) then 
			--_this:SetTopLevel(true);
		end
	end	
	
	CCS.OnClickFaceComponent();
	--CCS.ShowUIInterface(CCS_UI_Predefined);
end

--Function: show cartoon face control
--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function CCS.ShowInventory(bShow)
	local _this,_parent;
	
	_this=ParaUI.GetUIObject("map3dsystem_ccs_level1_inventory_container");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		
		local toLeft = CCS.ToLeft;
		local toBottom = CCS.ToBottom;
		local toRight = CCS.ToRight;
		local midHeight = CCS.MidHeight;
		
		_this=ParaUI.CreateUIObject("container","map3dsystem_ccs_level1_inventory_container","_lt",0,0,toRight,midHeight);
		--_this:SetTopLevel(true);
		--_this:AttachToRoot();
		--_guihelper.MessageBox(toLeft.." "..toBottom.." "..toRight.." "..midHeight);
		
		local _CCSUIContainer = ParaUI.GetUIObject("map3dsystem_ccs_container");
		_CCSUIContainer:AddChild(_this);
		
		_this.background="Texture/whitedot.png;0 0 0 0";
		_parent = _this;
		
		
		
		
		

_this = ParaUI.CreateUIObject("button", "btn1", "_lt", 0, 6, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_IT_Head_Fade.png", 
	"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Normal.png");
--_this.text = "Head";
_this.animstyle = 11;
_this.tooltip = "头部";
_this.onclick = ";Map3DSystem.UI.CCS.OnClickHeadInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn2", "_lt", 48, 6, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_IT_Neck_Fade.png", 
	"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Normal.png");
--_this.text = "Neck";
_this.animstyle = 11;
_this.tooltip = "颈部";
_this.onclick = ";Map3DSystem.UI.CCS.OnClickNeckInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn3", "_lt", 96, 6, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_IT_Shoulder_Fade.png", 
	"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Normal.png");
--_this.text = "Shoulder";
_this.animstyle = 11;
_this.tooltip = "肩膀";
_this.onclick = ";Map3DSystem.UI.CCS.OnClickShoulderInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn4", "_lt", 144, 6, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_IT_Boots_Fade.png", 
	"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Normal.png");
--_this.text = "Boots";
_this.animstyle = 11;
_this.tooltip = "鞋";
_this.onclick = ";Map3DSystem.UI.CCS.OnClickBootsInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn5", "_lt", 192, 6, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_IT_Belt_Fade.png", 
	"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Normal.png");
--_this.text = "Belt";
_this.animstyle = 11;
_this.tooltip = "腰带";
_this.onclick = ";Map3DSystem.UI.CCS.OnClickBeltInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn6", "_lt", 0, 54, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_IT_Shirt_Fade.png", 
	"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Normal.png");
--_this.text = "Shirt";
_this.animstyle = 11;
_this.tooltip = "衬衫";
_this.onclick = ";Map3DSystem.UI.CCS.OnClickShirtInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn7", "_lt", 48, 54, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_IT_Pants_Fade.png", 
	"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Normal.png");
--_this.text = "Pants";
_this.animstyle = 11;
_this.tooltip = "裤子";
_this.onclick = ";Map3DSystem.UI.CCS.OnClickPantsInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn8", "_lt", 96, 54, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_IT_Chest_Fade.png", 
	"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Normal.png");
--_this.text = "Chest";
_this.animstyle = 11;
_this.tooltip = "胸";
_this.onclick = ";Map3DSystem.UI.CCS.OnClickChestInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn9", "_lt", 144, 54, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_IT_Bracers_Fade.png", 
	"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Normal.png");
--_this.text = "Bracers";
_this.animstyle = 11;
_this.tooltip = "手腕";
_this.onclick = ";Map3DSystem.UI.CCS.OnClickBracersInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn10", "_lt", 192, 54, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_IT_Gloves_Fade.png", 
	"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Normal.png");
--_this.text = "Gloves";
_this.animstyle = 11;
_this.tooltip = "手套";
_this.onclick = ";Map3DSystem.UI.CCS.OnClickGlovesInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn11", "_lt", 0, 102, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_IT_HandRight_Fade.png", 
	"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Normal.png");
--_this.text = "HandRight";
_this.animstyle = 11;
_this.tooltip = "右手";
_this.onclick = ";Map3DSystem.UI.CCS.OnClickHandRightInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn12", "_lt", 48, 102, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_IT_HandLeft_Fade.png", 
	"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Normal.png");
--_this.text = "HandLeft";
_this.animstyle = 11;
_this.tooltip = "左手";
_this.onclick = ";Map3DSystem.UI.CCS.OnClickHandLeftInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn13", "_lt", 96, 102, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_IT_Cape_Fade.png", 
	"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Normal.png");
--_this.text = "Cape";
_this.animstyle = 11;
_this.tooltip = "披风";
_this.onclick = ";Map3DSystem.UI.CCS.OnClickCapeInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn14", "_lt", 144, 102, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_IT_Tabard_Fade.png", 
	"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Normal.png");
--_this.text = "Tabard";
_this.animstyle = 11;
_this.tooltip = "大衣";
_this.onclick = ";Map3DSystem.UI.CCS.OnClickTabardInventory();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btn_Inv_Return", "_lt", 192, 102, 48, 48)
_guihelper.SetVistaStyleButton2(_this, "Texture/3DMapSystem/CCS/btn_CCS_IT_Return.png", 
	"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Normal.png");
--_this.text = "Return";
_this.animstyle = 11;
_this.tooltip = "返回上一级";
_this.onclick = ";Map3DSystem.UI.CCS.OnClickInventoryReturn();";
_parent:AddChild(_this);

		
		

local _lvl0 = ParaUI.GetUIObject("map3dsystem_ccs_level0_container");
_lvl0.visible = false;
		
		--
		--_this = ParaUI.CreateUIObject("container", "InterfaceContainer", "_fi", 332, 71, 12, 14)
		--_this.background="Texture/whitedot.png;0 0 0 0";
		--_parent:AddChild(_this);
		
		--_this = ParaUI.CreateUIObject("container", "CCS_UI_Inventory_level2_container", "_lt", 258, 0, 264, 150);
		_this = ParaUI.CreateUIObject("container", "CCS_UI_Inventory_level2_container", "_fi", 245, 0, 0, 0);
		_this.background = "Texture/whitedot.png;0 0 0 0";
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
	
	CCS.OnClickHeadInventory();
	--CCS.ShowUIInterface(CCS_UI_Predefined);
end

-- update the character information including gender and race
function CCS.OnClickInventoryReturn()
	CCS.OnDestroy();
	ParaUI.GetUIObject("map3dsystem_ccs_level0_container").visible = true;
	
	-- play animation CCS end
	Map3DSystem.Animation.SendMeMessage({
			type = Map3DSystem.msg.ANIMATION_Character,
			obj_params = nil, --  <player>
			animationName = "CCSEnd",
			});
end

--function CCS.PleaseSelectRaceOrGender()
	--local obj = ObjEditor.GetCurrentObj();
	--headon_speech.Speek(obj.name, "请选择种族和性别,看看有什么反应:-)", 2);
--end


-- update the character information including gender and race
function CCS.UpdateCharacterInfo(from)
	if(true) then
		return;
	end
	
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
					CCS.Predefined.ResetBaseModel("character/v3/Human2/", "Male");
					headon_speech.Speek(obj.name, "我变成成人了", 2);
				elseif(r == 2 and g == 1) then
					-- female, child
					CCS.Predefined.ResetBaseModel("character/v3/Human2/", "Female");
					headon_speech.Speek(obj.name, "我变成成人了", 2);
				end
				
				--return;
			elseif(from == "ChildClick") then
				local r = obj:ToCharacter():GetRaceID();
				local g = obj:ToCharacter():GetGender();
				
				if(r == 1 and g == 0) then
					-- male, human
					CCS.Predefined.ResetBaseModel("character/v3/Child/", "Male");
					headon_speech.Speek(obj.name, "我变成小孩了", 2);
				elseif(r == 1 and g == 1) then
					-- female, human
					CCS.Predefined.ResetBaseModel("character/v3/Child/", "Female");
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
					CCS.Predefined.ResetBaseModel("character/v3/Human2/", "Male");
					headon_speech.Speek(obj.name, "我变成男人了", 2);
				elseif(r == 2 and g == 0) then
					-- male, child
					headon_speech.Speek(obj.name, "我已经是男孩了", 2);
				elseif(r == 2 and g == 1) then
					-- female, child
					CCS.Predefined.ResetBaseModel("character/v3/Child/", "Male");
					headon_speech.Speek(obj.name, "我变成男孩了", 2);
				end
				
			elseif(from == "FemaleClick") then
				local r = obj:ToCharacter():GetRaceID();
				local g = obj:ToCharacter():GetGender();
				
				if(r == 1 and g == 0) then
					-- male, human
					CCS.Predefined.ResetBaseModel("character/v3/Human2/", "Female");
					headon_speech.Speek(obj.name, "我变成女人了", 2);
				elseif(r == 1 and g == 1) then
					-- female, human
					headon_speech.Speek(obj.name, "我已经是女人了", 2);
				elseif(r == 2 and g == 0) then
					-- male, child
					CCS.Predefined.ResetBaseModel("character/v3/Child/", "Female");
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
				if (CCS.Predefined.CurrentFaceType == "CharacterFace") then
					CCS.Predefined.ToggleFace();
				end
			elseif(charFaceType > 0 and cartoonFaceType == -1) then
				if (CCS.Predefined.CurrentFaceType == "CartoonFace") then
					CCS.Predefined.ToggleFace();
				end
			end
			
		else
			-- not customizable character
			if(from == "HumanClick") then
				CCS.Predefined.ResetBaseModel("character/v3/Human/", "Male");
				local radiobuttons = {"buttonFemale","buttonMale"};
				_guihelper.CheckRadioButtons( radiobuttons, "buttonMale", "255 181 181");
				local radiobuttons = {"btnRaceHuman","btnRaceChild"};
				_guihelper.CheckRadioButtons( radiobuttons, "btnRaceHuman", "255 181 181");
				headon_speech.Speek(obj.name, "我变成男人了", 2);
			elseif(from == "ChildClick") then
				CCS.Predefined.ResetBaseModel("character/v3/Child/", "Female");
				local radiobuttons = {"buttonFemale","buttonMale"};
				_guihelper.CheckRadioButtons( radiobuttons, "buttonFemale", "255 181 181");
				local radiobuttons = {"btnRaceHuman","btnRaceChild"};
				_guihelper.CheckRadioButtons( radiobuttons, "btnRaceChild", "255 181 181");
				headon_speech.Speek(obj.name, "我变成女孩了", 2);
			elseif(from == "MaleClick") then
				CCS.Predefined.ResetBaseModel("character/v3/Child/", "Male");
				local radiobuttons = {"buttonFemale","buttonMale"};
				_guihelper.CheckRadioButtons( radiobuttons, "buttonMale", "255 181 181");
				local radiobuttons = {"btnRaceHuman","btnRaceChild"};
				_guihelper.CheckRadioButtons( radiobuttons, "btnRaceChild", "255 181 181");
				headon_speech.Speek(obj.name, "我变成男孩了", 2);
			elseif(from == "FemaleClick") then
				CCS.Predefined.ResetBaseModel("character/v3/Child/", "Female");
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
-- e.g. CCS.ShowUIInterface(CCS_UI_Predefined);
function CCS.ShowUIInterface(componentName)
	local _this = ParaUI.GetUIObject("map3dsystem_ccs_level1_cartoonface_container");
	if(_this:IsValid()) then
		local parent = _this:GetChild("InterfaceContainer");
		if(CCS.CurrentUIInterface~=nil) then
			-- remove old one
			CCS.CurrentUIInterface.OnDestroy();
		end
		
		
		if(componentName == "CCS_UI_Predefined") then
			--parent = _this:GetChild("OriginalInterfaceContainer");
			--UIClassPtr = CCS_UI_Predefined;
		elseif(componentName == "CartoonFace") then
			UIClassPtr = CCS.CartoonFace;
			UIClassPtr.Show(parent);
			CCS.CurrentUIInterface = UIClassPtr;
		elseif(componentName == "Inventory") then
			UIClassPtr = CCS.Inventory;
			UIClassPtr.Show(parent);
			CCS.CurrentUIInterface = UIClassPtr;
		end
	end	
end

function CCS.OnClickColorPalette()

	local x,y = ParaUI.GetMousePosition();
	local temp = ParaUI.GetUIObjectAtPoint(x,y);
	local abs_x,abs_y = temp:GetAbsPosition();
	local r_x,r_y = x - abs_x, y - abs_y;
	
	local indexX, indexY = 0, 0;
	indexX = (r_x - math.mod(r_x, 16))/16;
	indexY = (r_y - math.mod(r_y, 16))/16;
	--_guihelper.MessageBox("x:"..indexX.." y:"..indexY);
	
	local R, G, B;
	R = CCS.Matrix[""..indexY..indexX][1];
	G = CCS.Matrix[""..indexY..indexX][2];
	B = CCS.Matrix[""..indexY..indexX][3];
	
	--_guihelper.MessageBox("R:"..R.." G:"..G.." B:"..B);
	
	CCS.DB.SetFaceComponent(CCS.CartoonFaceComponent.Component, 
		CCS.DB.CFS_SUB_Color, _guihelper.RGBA_TO_DWORD(R,G,B));
	
	
end

-- destroy the control
function CCS.OnDestroy()
	ParaUI.Destroy("map3dsystem_ccs_level1_cartoonface_container");
	ParaUI.Destroy("map3dsystem_ccs_level1_inventory_container");
	CCS.CurrentUIInterface = nil;
end

CCS.FacialHairType = 0;
CCS.MaxFacialHairType = 2;
function CCS.NextFacialHairType()
	local player, playerChar = CCS.DB.GetPlayerChar();
	if(playerChar~=nil and playerChar:IsSupportCartoonFace()) then
		CCS.FacialHairType = math.mod(CCS.FacialHairType+1, CCS.MaxFacialHairType);
		playerChar:SetBodyParams(-1, -1,-1, -1, CCS.FacialHairType);
		log(CCS.FacialHairType.." is done.\n")
	end
end

-- OnClick face component matrix
function CCS.OnClickFaceComponent()
	CCS.CartoonFaceComponent.SetFaceSection("Face");
	CCS.ShowUIInterface("CartoonFace");
	local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8"};
	_guihelper.CheckRadioButtons2(radiobuttons, "btn1", nil,
		"Texture/3DMapSystem/CCS/btn_CCS_CF_Empty_Highlight.png",
		"Texture/3DMapSystem/CCS/btn_CCS_CF_Empty_Normal.png");
	ParaUI.GetUIObject("CCS_Right_IconMatrix_Container").visible = true;
end
function CCS.OnClickWrinkleComponent()
	CCS.CartoonFaceComponent.SetFaceSection("Wrinkle");
	CCS.ShowUIInterface("CartoonFace");
	local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8"};
	_guihelper.CheckRadioButtons2(radiobuttons, "btn2", nil,
		"Texture/3DMapSystem/CCS/btn_CCS_CF_Empty_Highlight.png",
		"Texture/3DMapSystem/CCS/btn_CCS_CF_Empty_Normal.png");
	ParaUI.GetUIObject("CCS_Right_IconMatrix_Container").visible = true;
end
function CCS.OnClickEyeComponent()
	CCS.CartoonFaceComponent.SetFaceSection("Eye");
	CCS.ShowUIInterface("CartoonFace");
	local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8"};
	_guihelper.CheckRadioButtons2(radiobuttons, "btn3", nil,
		"Texture/3DMapSystem/CCS/btn_CCS_CF_Empty_Highlight.png",
		"Texture/3DMapSystem/CCS/btn_CCS_CF_Empty_Normal.png");
	ParaUI.GetUIObject("CCS_Right_IconMatrix_Container").visible = true;
end
function CCS.OnClickEyebrowComponent()
	CCS.CartoonFaceComponent.SetFaceSection("Eyebrow");
	CCS.ShowUIInterface("CartoonFace");
	local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8"};
	_guihelper.CheckRadioButtons2(radiobuttons, "btn4", nil,
		"Texture/3DMapSystem/CCS/btn_CCS_CF_Empty_Highlight.png",
		"Texture/3DMapSystem/CCS/btn_CCS_CF_Empty_Normal.png");
	ParaUI.GetUIObject("CCS_Right_IconMatrix_Container").visible = true;
end
function CCS.OnClickMouthComponent()
	CCS.CartoonFaceComponent.SetFaceSection("Mouth");
	CCS.ShowUIInterface("CartoonFace");
	local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8"};
	_guihelper.CheckRadioButtons2(radiobuttons, "btn5", nil,
		"Texture/3DMapSystem/CCS/btn_CCS_CF_Empty_Highlight.png",
		"Texture/3DMapSystem/CCS/btn_CCS_CF_Empty_Normal.png");
	ParaUI.GetUIObject("CCS_Right_IconMatrix_Container").visible = true;
end
function CCS.OnClickNoseComponent()
	CCS.CartoonFaceComponent.SetFaceSection("Nose");
	CCS.ShowUIInterface("CartoonFace");
	local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8"};
	_guihelper.CheckRadioButtons2(radiobuttons, "btn6", nil,
		"Texture/3DMapSystem/CCS/btn_CCS_CF_Empty_Highlight.png",
		"Texture/3DMapSystem/CCS/btn_CCS_CF_Empty_Normal.png");
	ParaUI.GetUIObject("CCS_Right_IconMatrix_Container").visible = true;
end
function CCS.OnClickMarksComponent()
	CCS.CartoonFaceComponent.SetFaceSection("Marks");
	CCS.ShowUIInterface("CartoonFace");
	local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8"};
	_guihelper.CheckRadioButtons2(radiobuttons, "btn7", nil,
		"Texture/3DMapSystem/CCS/btn_CCS_CF_Empty_Highlight.png",
		"Texture/3DMapSystem/CCS/btn_CCS_CF_Empty_Normal.png");
	ParaUI.GetUIObject("CCS_Right_IconMatrix_Container").visible = true;
end
function CCS.OnClickRandomComponent()
	--CCS.CartoonFaceComponent.SetFaceSection("Wrinkle");
	--CCS.ShowUIInterface("CartoonFace");
	--local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8"};
	--_guihelper.CheckRadioButtons2(radiobuttons, "btn8", nil,
		--"Texture/3DMapSystem/CCS/btn_CCS_CF_Empty_Highlight.png",
		--"Texture/3DMapSystem/CCS/btn_CCS_CF_Empty_Normal.png");
	--ParaUI.GetUIObject("CCS_Right_IconMatrix_Container").visible = true;
end


CCS.PreviousActiveInventorySlot = nil;


function CCS.ChangeToInventorySlot(name)

	if(CCS.PreviousActiveInventorySlot == nil) then
		local btn1 =ParaUI.GetUIObject("btn1");
		-- Currently the first inventory slot invoke this field is inventory head slot
		btn1.background = "Texture/3DMapSystem/CCS/btn_CCS_IT_Head.png";
	elseif(CCS.PreviousActiveInventorySlot ~= name) then
		local prevBtn = ParaUI.GetUIObject(CCS.PreviousActiveInventorySlot);
		local currentBtn = ParaUI.GetUIObject(name);
		
		if(CCS.PreviousActiveInventorySlot == "btn1") then
			prevBtn.background = "Texture/3DMapSystem/CCS/btn_CCS_IT_Head_Fade.png";
		elseif(CCS.PreviousActiveInventorySlot == "btn2") then
			prevBtn.background = "Texture/3DMapSystem/CCS/btn_CCS_IT_Neck_Fade.png";
		elseif(CCS.PreviousActiveInventorySlot == "btn3") then
			prevBtn.background = "Texture/3DMapSystem/CCS/btn_CCS_IT_Shoulder_Fade.png";
		elseif(CCS.PreviousActiveInventorySlot == "btn4") then
			prevBtn.background = "Texture/3DMapSystem/CCS/btn_CCS_IT_Boots_Fade.png";
		elseif(CCS.PreviousActiveInventorySlot == "btn5") then
			prevBtn.background = "Texture/3DMapSystem/CCS/btn_CCS_IT_Belt_Fade.png";
		elseif(CCS.PreviousActiveInventorySlot == "btn6") then
			prevBtn.background = "Texture/3DMapSystem/CCS/btn_CCS_IT_Shirt_Fade.png";
		elseif(CCS.PreviousActiveInventorySlot == "btn7") then
			prevBtn.background = "Texture/3DMapSystem/CCS/btn_CCS_IT_Pants_Fade.png";
		elseif(CCS.PreviousActiveInventorySlot == "btn8") then
			prevBtn.background = "Texture/3DMapSystem/CCS/btn_CCS_IT_Chest_Fade.png";
		elseif(CCS.PreviousActiveInventorySlot == "btn9") then
			prevBtn.background = "Texture/3DMapSystem/CCS/btn_CCS_IT_Bracers_Fade.png";
		elseif(CCS.PreviousActiveInventorySlot == "btn10") then
			prevBtn.background = "Texture/3DMapSystem/CCS/btn_CCS_IT_Gloves_Fade.png";
		elseif(CCS.PreviousActiveInventorySlot == "btn11") then
			prevBtn.background = "Texture/3DMapSystem/CCS/btn_CCS_IT_HandRight_Fade.png";
		elseif(CCS.PreviousActiveInventorySlot == "btn12") then
			prevBtn.background = "Texture/3DMapSystem/CCS/btn_CCS_IT_HandLeft_Fade.png";
		elseif(CCS.PreviousActiveInventorySlot == "btn13") then
			prevBtn.background = "Texture/3DMapSystem/CCS/btn_CCS_IT_Cape_Fade.png";
		elseif(CCS.PreviousActiveInventorySlot == "btn14") then
			prevBtn.background = "Texture/3DMapSystem/CCS/btn_CCS_IT_Tabard_Fade.png";
		end
		
		if(name == "btn1") then
			currentBtn.background = "Texture/3DMapSystem/CCS/btn_CCS_IT_Head.png";
		elseif(name == "btn2") then
			currentBtn.background = "Texture/3DMapSystem/CCS/btn_CCS_IT_Neck.png";
		elseif(name == "btn3") then
			currentBtn.background = "Texture/3DMapSystem/CCS/btn_CCS_IT_Shoulder.png";
		elseif(name == "btn4") then
			currentBtn.background = "Texture/3DMapSystem/CCS/btn_CCS_IT_Boots.png";
		elseif(name == "btn5") then
			currentBtn.background = "Texture/3DMapSystem/CCS/btn_CCS_IT_Belt.png";
		elseif(name == "btn6") then
			currentBtn.background = "Texture/3DMapSystem/CCS/btn_CCS_IT_Shirt.png";
		elseif(name == "btn7") then
			currentBtn.background = "Texture/3DMapSystem/CCS/btn_CCS_IT_Pants.png";
		elseif(name == "btn8") then
			currentBtn.background = "Texture/3DMapSystem/CCS/btn_CCS_IT_Chest.png";
		elseif(name == "btn9") then
			currentBtn.background = "Texture/3DMapSystem/CCS/btn_CCS_IT_Bracers.png";
		elseif(name == "btn10") then
			currentBtn.background = "Texture/3DMapSystem/CCS/btn_CCS_IT_Gloves.png";
		elseif(name == "btn11") then
			currentBtn.background = "Texture/3DMapSystem/CCS/btn_CCS_IT_HandRight.png";
		elseif(name == "btn12") then
			currentBtn.background = "Texture/3DMapSystem/CCS/btn_CCS_IT_HandLeft.png";
		elseif(name == "btn13") then
			currentBtn.background = "Texture/3DMapSystem/CCS/btn_CCS_IT_Cape.png";
		elseif(name == "btn14") then
			currentBtn.background = "Texture/3DMapSystem/CCS/btn_CCS_IT_Tabard.png";
		end
		
	end
	CCS.PreviousActiveInventorySlot = name;
	
end

-- OnClick item inventory matrix
function CCS.OnClickHeadInventory()
	CCS.InventorySlot.SetInventorySlot("Head");
	--CCS.ShowUIInterface("Inventory");
	local cont =ParaUI.GetUIObject("CCS_UI_Inventory_level2_container");
	CCS.Inventory.Show(cont);
	
	CCS.ChangeToInventorySlot("btn1");
	
	--local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8","btn9","btn10","btn11","btn12","btn13","btn14"};
	--_guihelper.CheckRadioButtons2(radiobuttons, "btn1", nil,
		--"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Highlight.png",
		--"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Normal.png");
end
function CCS.OnClickNeckInventory()
	CCS.InventorySlot.SetInventorySlot("Neck");
	CCS.ShowUIInterface("Inventory");
	local cont =ParaUI.GetUIObject("CCS_UI_Inventory_level2_container");
	CCS.Inventory.Show(cont);
	
	CCS.ChangeToInventorySlot("btn2");
	
	--local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8","btn9","btn10","btn11","btn12","btn13","btn14"};
	--_guihelper.CheckRadioButtons2(radiobuttons, "btn2", nil,
		--"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Highlight.png",
		--"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Normal.png");
end
function CCS.OnClickShoulderInventory()
	CCS.InventorySlot.SetInventorySlot("Shoulder");
	CCS.ShowUIInterface("Inventory");
	local cont =ParaUI.GetUIObject("CCS_UI_Inventory_level2_container");
	CCS.Inventory.Show(cont);
	
	CCS.ChangeToInventorySlot("btn3");
	
	--local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8","btn9","btn10","btn11","btn12","btn13","btn14"};
	--_guihelper.CheckRadioButtons2(radiobuttons, "btn3", nil,
		--"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Highlight.png",
		--"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Normal.png");
end
function CCS.OnClickBootsInventory()
	CCS.InventorySlot.SetInventorySlot("Boots");
	CCS.ShowUIInterface("Inventory");
	local cont =ParaUI.GetUIObject("CCS_UI_Inventory_level2_container");
	CCS.Inventory.Show(cont);
	
	CCS.ChangeToInventorySlot("btn4");
	
	--local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8","btn9","btn10","btn11","btn12","btn13","btn14"};
	--_guihelper.CheckRadioButtons2(radiobuttons, "btn4", nil,
		--"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Highlight.png",
		--"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Normal.png");
end
function CCS.OnClickBeltInventory()
	CCS.InventorySlot.SetInventorySlot("Belt");
	CCS.ShowUIInterface("Inventory");
	local cont =ParaUI.GetUIObject("CCS_UI_Inventory_level2_container");
	CCS.Inventory.Show(cont);
	
	CCS.ChangeToInventorySlot("btn5");
	
	--local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8","btn9","btn10","btn11","btn12","btn13","btn14"};
	--_guihelper.CheckRadioButtons2(radiobuttons, "btn5", nil,
		--"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Highlight.png",
		--"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Normal.png");
end
function CCS.OnClickShirtInventory()
	CCS.InventorySlot.SetInventorySlot("Shirt");
	CCS.ShowUIInterface("Inventory");
	local cont =ParaUI.GetUIObject("CCS_UI_Inventory_level2_container");
	CCS.Inventory.Show(cont);
	
	CCS.ChangeToInventorySlot("btn6");
	
	--local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8","btn9","btn10","btn11","btn12","btn13","btn14"};
	--_guihelper.CheckRadioButtons2(radiobuttons, "btn6", nil,
		--"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Highlight.png",
		--"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Normal.png");
end
function CCS.OnClickPantsInventory()
	CCS.InventorySlot.SetInventorySlot("Pants");
	CCS.ShowUIInterface("Inventory");
	local cont =ParaUI.GetUIObject("CCS_UI_Inventory_level2_container");
	CCS.Inventory.Show(cont);
	
	CCS.ChangeToInventorySlot("btn7");
	
	--local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8","btn9","btn10","btn11","btn12","btn13","btn14"};
	--_guihelper.CheckRadioButtons2(radiobuttons, "btn7", nil,
		--"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Highlight.png",
		--"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Normal.png");
end
function CCS.OnClickChestInventory()
	CCS.InventorySlot.SetInventorySlot("Chest");
	CCS.ShowUIInterface("Inventory");
	local cont =ParaUI.GetUIObject("CCS_UI_Inventory_level2_container");
	CCS.Inventory.Show(cont);
	
	CCS.ChangeToInventorySlot("btn8");
	
	--local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8","btn9","btn10","btn11","btn12","btn13","btn14"};
	--_guihelper.CheckRadioButtons2(radiobuttons, "btn8", nil,
		--"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Highlight.png",
		--"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Normal.png");
end
function CCS.OnClickBracersInventory()
	CCS.InventorySlot.SetInventorySlot("Bracers");
	CCS.ShowUIInterface("Inventory");
	local cont =ParaUI.GetUIObject("CCS_UI_Inventory_level2_container");
	CCS.Inventory.Show(cont);
	
	CCS.ChangeToInventorySlot("btn9");
	
	--local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8","btn9","btn10","btn11","btn12","btn13","btn14"};
	--_guihelper.CheckRadioButtons2(radiobuttons, "btn9", nil,
		--"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Highlight.png",
		--"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Normal.png");
end
function CCS.OnClickGlovesInventory()
	CCS.InventorySlot.SetInventorySlot("Gloves");
	CCS.ShowUIInterface("Inventory");
	local cont =ParaUI.GetUIObject("CCS_UI_Inventory_level2_container");
	CCS.Inventory.Show(cont);
	
	CCS.ChangeToInventorySlot("btn10");
	
	--local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8","btn9","btn10","btn11","btn12","btn13","btn14"};
	--_guihelper.CheckRadioButtons2(radiobuttons, "btn10", nil,
		--"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Highlight.png",
		--"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Normal.png");
end
function CCS.OnClickHandRightInventory()
	CCS.InventorySlot.SetInventorySlot("HandRight");
	CCS.ShowUIInterface("Inventory");
	local cont =ParaUI.GetUIObject("CCS_UI_Inventory_level2_container");
	CCS.Inventory.Show(cont);
	
	CCS.ChangeToInventorySlot("btn11");
	
	--local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8","btn9","btn10","btn11","btn12","btn13","btn14"};
	--_guihelper.CheckRadioButtons2(radiobuttons, "btn11", nil,
		--"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Highlight.png",
		--"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Normal.png");
end
function CCS.OnClickHandLeftInventory()
	CCS.InventorySlot.SetInventorySlot("HandLeft");
	CCS.ShowUIInterface("Inventory");
	local cont =ParaUI.GetUIObject("CCS_UI_Inventory_level2_container");
	CCS.Inventory.Show(cont);
	
	CCS.ChangeToInventorySlot("btn12");
	
	--local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8","btn9","btn10","btn11","btn12","btn13","btn14"};
	--_guihelper.CheckRadioButtons2(radiobuttons, "btn12", nil,
		--"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Highlight.png",
		--"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Normal.png");
end
function CCS.OnClickCapeInventory()
	CCS.InventorySlot.SetInventorySlot("Cape");
	CCS.ShowUIInterface("Inventory");
	local cont =ParaUI.GetUIObject("CCS_UI_Inventory_level2_container");
	CCS.Inventory.Show(cont);
	
	CCS.ChangeToInventorySlot("btn13");
	
	--local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8","btn9","btn10","btn11","btn12","btn13","btn14"};
	--_guihelper.CheckRadioButtons2(radiobuttons, "btn13", nil,
		--"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Highlight.png",
		--"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Normal.png");
end
function CCS.OnClickTabardInventory()
	CCS.InventorySlot.SetInventorySlot("Tabard");
	CCS.ShowUIInterface("Inventory");
	local cont =ParaUI.GetUIObject("CCS_UI_Inventory_level2_container");
	CCS.Inventory.Show(cont);
	
	CCS.ChangeToInventorySlot("btn14");
	
	--local radiobuttons = {"btn1","btn2","btn3","btn4","btn5","btn6","btn7","btn8","btn9","btn10","btn11","btn12","btn13","btn14"};
	--_guihelper.CheckRadioButtons2(radiobuttons, "btn14", nil,
		--"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Highlight.png",
		--"Texture/3DMapSystem/CCS/btn_CCS_IT_Empty_Normal.png");
end
