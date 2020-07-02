--[[
Title: Item editor for 3D Map system
Author(s): WangTian
Date: 2007/10/26
Desc: editor for ARTISTS to test their items
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/InGame/ItemEditor.lua");
------------------------------------------------------------

NOTE: this is NOT a main bar icon application
]]

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

if(not Map3DSystem.UI.ItemEditor) then
	Map3DSystem.UI.ItemEditor = {};
end

-- character slots
Map3DSystem.UI.ItemEditor.CS_HEAD =0;
Map3DSystem.UI.ItemEditor.CS_NECK = 1;
Map3DSystem.UI.ItemEditor.CS_SHOULDER = 2;
Map3DSystem.UI.ItemEditor.CS_BOOTS = 3;
Map3DSystem.UI.ItemEditor.CS_BELT = 4;
Map3DSystem.UI.ItemEditor.CS_SHIRT = 5;
Map3DSystem.UI.ItemEditor.CS_PANTS = 6;
Map3DSystem.UI.ItemEditor.CS_CHEST = 7;
Map3DSystem.UI.ItemEditor.CS_BRACERS = 8;
Map3DSystem.UI.ItemEditor.CS_GLOVES = 9;
Map3DSystem.UI.ItemEditor.CS_HAND_RIGHT = 10;
Map3DSystem.UI.ItemEditor.CS_HAND_LEFT = 11;
Map3DSystem.UI.ItemEditor.CS_CAPE = 12;
Map3DSystem.UI.ItemEditor.CS_TABARD = 13;

-- @param bShow: show or hide the panel 
function Map3DSystem.UI.ItemEditor.Show(bShow)
	
	local _this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_Head");
	_this.visible = false;
	_this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_Shoulder");
	_this.visible = false;
	_this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_WeaponL");
	_this.visible = false;
	_this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_WeaponR");
	_this.visible = false;
	_this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_Shirt");
	_this.visible = false;
	_this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_Glove");
	_this.visible = false;
	_this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_Pant");
	_this.visible = false;
	_this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_Boot");
	_this.visible = false;
	
	_this = ParaUI.GetUIObject("Map3DSystem_ItemEditor");
	if(_this:IsValid() == true) then
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		_this.visible = bShow;
	else
		if(bShow == false) then return	end
		
		_this = ParaUI.CreateUIObject("container", "Map3DSystem_ItemEditor", "_ctr", 
				0, 115, 48, 370);
		_this:AttachToRoot();
		
		local left = 8;
		local top = 8;
		local gap = 8;
		
		local _parent = _this;
		_this = ParaUI.CreateUIObject("button", "Head", "_lt", 
				left, top, 32, 32);
		_this.background = "Texture/kidui/CCS/btn_CCS_IT_Head.png";
		_this.onclick = ";Map3DSystem.UI.ItemEditor.ClickItemClass(\"head\");";
		_parent:AddChild(_this);
		top = top + 32 + gap;
		
		_this = ParaUI.CreateUIObject("button", "Shoulder", "_lt", 
				left, top, 32, 32);
		_this.background = "Texture/kidui/CCS/btn_CCS_IT_Shoulder.png";
		_this.onclick = ";Map3DSystem.UI.ItemEditor.ClickItemClass(\"shoulder\");";
		_parent:AddChild(_this);
		top = top + 32 + gap;
		
		_this = ParaUI.CreateUIObject("button", "WeaponL", "_lt", 
				left, top, 32, 32);
		_this.background = "Texture/kidui/CCS/btn_CCS_IT_HandLeft.png";
		_this.tooltip = "左手";
		_this.onclick = ";Map3DSystem.UI.ItemEditor.ClickItemClass(\"weaponL\");";
		_parent:AddChild(_this);
		top = top + 32 + gap;
		
		_this = ParaUI.CreateUIObject("button", "WeaponR", "_lt", 
				left, top, 32, 32);
		_this.background = "Texture/kidui/CCS/btn_CCS_IT_HandRight.png";
		_this.tooltip = "右手";
		_this.onclick = ";Map3DSystem.UI.ItemEditor.ClickItemClass(\"weaponR\");";
		_parent:AddChild(_this);
		top = top + 32 + gap;
		
		_this = ParaUI.CreateUIObject("button", "Shirt", "_lt", 
				left, top, 32, 32);
		_this.background = "Texture/kidui/CCS/btn_CCS_IT_Shirt.png";
		_this.onclick = ";Map3DSystem.UI.ItemEditor.ClickItemClass(\"shirt\");";
		_parent:AddChild(_this);
		top = top + 32 + gap;
		
		_this = ParaUI.CreateUIObject("button", "Glove", "_lt", 
				left, top, 32, 32);
		_this.background = "Texture/kidui/CCS/btn_CCS_IT_Gloves.png";
		_this.onclick = ";Map3DSystem.UI.ItemEditor.ClickItemClass(\"glove\");";
		_parent:AddChild(_this);
		top = top + 32 + gap;
		
		_this = ParaUI.CreateUIObject("button", "Pant", "_lt", 
				left, top, 32, 32);
		_this.background = "Texture/kidui/CCS/btn_CCS_IT_Pants.png";
		_this.onclick = ";Map3DSystem.UI.ItemEditor.ClickItemClass(\"pant\");";
		_parent:AddChild(_this);
		top = top + 32 + gap;
		
		_this = ParaUI.CreateUIObject("button", "Boot", "_lt", 
				left, top, 32, 32);
		_this.background = "Texture/kidui/CCS/btn_CCS_IT_Boots.png";
		_this.onclick = ";Map3DSystem.UI.ItemEditor.ClickItemClass(\"boot\");";
		_parent:AddChild(_this);
		top = top + 32 + gap;
		
		_this = ParaUI.CreateUIObject("button", "DB", "_lt", 
				left, top, 32, 24);
		_this.text = "DB";
		_this.onclick = ";Map3DSystem.UI.ItemEditor.ClickDBUpdate();";
		_parent:AddChild(_this);
		top = top + 32 + gap;
		
	end
end

function Map3DSystem.UI.ItemEditor.ClickDBUpdate()
	_guihelper.MessageBox("确认更新DB？\n\n 数据库文件的更新整理由陈亮负责。如有疑问请联系张瑜、王田。\n数据更新需要花些时间，请耐心等待\n", function ()
				Map3DSystem.UI.CCS.DB.AutoGenerateItems();
				_guihelper.CloseMessageBox();
			end);
end


function Map3DSystem.UI.ItemEditor.ClickItemClass(sClass)
	if(sClass == "head") then
		Map3DSystem.UI.ItemEditor.ShowHeadEditor();
		Map3DSystem.UI.ItemEditor.ShowShoulderEditor(false);
		Map3DSystem.UI.ItemEditor.ShowWeaponLEditor(false);
		Map3DSystem.UI.ItemEditor.ShowWeaponREditor(false);
		Map3DSystem.UI.ItemEditor.ShowShirtEditor(false);
		Map3DSystem.UI.ItemEditor.ShowGloveEditor(false);
		Map3DSystem.UI.ItemEditor.ShowPantEditor(false);
		Map3DSystem.UI.ItemEditor.ShowBootEditor(false);
	elseif(sClass == "shoulder") then
		Map3DSystem.UI.ItemEditor.ShowHeadEditor(false);
		Map3DSystem.UI.ItemEditor.ShowShoulderEditor();
		Map3DSystem.UI.ItemEditor.ShowWeaponLEditor(false);
		Map3DSystem.UI.ItemEditor.ShowWeaponREditor(false);
		Map3DSystem.UI.ItemEditor.ShowShirtEditor(false);
		Map3DSystem.UI.ItemEditor.ShowGloveEditor(false);
		Map3DSystem.UI.ItemEditor.ShowPantEditor(false);
		Map3DSystem.UI.ItemEditor.ShowBootEditor(false);
	elseif(sClass == "weaponL") then
		Map3DSystem.UI.ItemEditor.ShowHeadEditor(false);
		Map3DSystem.UI.ItemEditor.ShowShoulderEditor(false);
		Map3DSystem.UI.ItemEditor.ShowWeaponLEditor();
		Map3DSystem.UI.ItemEditor.ShowWeaponREditor(false);
		Map3DSystem.UI.ItemEditor.ShowShirtEditor(false);
		Map3DSystem.UI.ItemEditor.ShowGloveEditor(false);
		Map3DSystem.UI.ItemEditor.ShowPantEditor(false);
		Map3DSystem.UI.ItemEditor.ShowBootEditor(false);
	elseif(sClass == "weaponR") then
		Map3DSystem.UI.ItemEditor.ShowHeadEditor(false);
		Map3DSystem.UI.ItemEditor.ShowShoulderEditor(false);
		Map3DSystem.UI.ItemEditor.ShowWeaponLEditor(false);
		Map3DSystem.UI.ItemEditor.ShowWeaponREditor();
		Map3DSystem.UI.ItemEditor.ShowShirtEditor(false);
		Map3DSystem.UI.ItemEditor.ShowGloveEditor(false);
		Map3DSystem.UI.ItemEditor.ShowPantEditor(false);
		Map3DSystem.UI.ItemEditor.ShowBootEditor(false);
	elseif(sClass == "shirt") then
		Map3DSystem.UI.ItemEditor.ShowHeadEditor(false);
		Map3DSystem.UI.ItemEditor.ShowShoulderEditor(false);
		Map3DSystem.UI.ItemEditor.ShowWeaponLEditor(false);
		Map3DSystem.UI.ItemEditor.ShowWeaponREditor(false);
		Map3DSystem.UI.ItemEditor.ShowShirtEditor();
		Map3DSystem.UI.ItemEditor.ShowGloveEditor(false);
		Map3DSystem.UI.ItemEditor.ShowPantEditor(false);
		Map3DSystem.UI.ItemEditor.ShowBootEditor(false);
	elseif(sClass == "glove") then
		Map3DSystem.UI.ItemEditor.ShowHeadEditor(false);
		Map3DSystem.UI.ItemEditor.ShowShoulderEditor(false);
		Map3DSystem.UI.ItemEditor.ShowWeaponLEditor(false);
		Map3DSystem.UI.ItemEditor.ShowWeaponREditor(false);
		Map3DSystem.UI.ItemEditor.ShowShirtEditor(false);
		Map3DSystem.UI.ItemEditor.ShowGloveEditor();
		Map3DSystem.UI.ItemEditor.ShowPantEditor(false);
		Map3DSystem.UI.ItemEditor.ShowBootEditor(false);
	elseif(sClass == "pant") then
		Map3DSystem.UI.ItemEditor.ShowHeadEditor(false);
		Map3DSystem.UI.ItemEditor.ShowShoulderEditor(false);
		Map3DSystem.UI.ItemEditor.ShowWeaponLEditor(false);
		Map3DSystem.UI.ItemEditor.ShowWeaponREditor(false);
		Map3DSystem.UI.ItemEditor.ShowShirtEditor(false);
		Map3DSystem.UI.ItemEditor.ShowGloveEditor(false);
		Map3DSystem.UI.ItemEditor.ShowPantEditor();
		Map3DSystem.UI.ItemEditor.ShowBootEditor(false);
	elseif(sClass == "boot") then
		Map3DSystem.UI.ItemEditor.ShowHeadEditor(false);
		Map3DSystem.UI.ItemEditor.ShowShoulderEditor(false);
		Map3DSystem.UI.ItemEditor.ShowWeaponLEditor(false);
		Map3DSystem.UI.ItemEditor.ShowWeaponREditor(false);
		Map3DSystem.UI.ItemEditor.ShowShirtEditor(false);
		Map3DSystem.UI.ItemEditor.ShowGloveEditor(false);
		Map3DSystem.UI.ItemEditor.ShowPantEditor(false);
		Map3DSystem.UI.ItemEditor.ShowBootEditor();
	end
end


-- @param bShow: show or hide the panel 
function Map3DSystem.UI.ItemEditor.ShowHeadEditor(bShow)

	local _this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_Head");
	if(_this:IsValid() == true) then
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		_this.visible = bShow;
	else
		if(bShow == false) then return	end
		
		_this = ParaUI.CreateUIObject("container", "Map3DSystem_ItemEditor_Head", "_rt", 
				-280, 320, 230, 350);
		_this:AttachToRoot();
		
		
		local _parent = _this;
		_this = ParaUI.CreateUIObject("text", "Model", "_lt", 10, 30, 120, 24);
		_this.text = "选择头部模型:";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("button", "ModelDir", "_lt", 140, 30, 64, 32);
		_this.text = "...";
		_this.onclick = ";Map3DSystem.UI.ItemEditor.ShowOpenFileDialog(\"head\", \"model\");";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("editbox", "ModelText", "_lt", 10, 70, 200, 32);
		_this.readonly = true;
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("text", "Skin", "_lt", 10, 110, 120, 24);
		_this.text = "选择头部模型贴图:";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("button", "SkinDir", "_lt", 140, 110, 64, 32);
		_this.text = "...";
		_this.onclick = ";Map3DSystem.UI.ItemEditor.ShowOpenFileDialog(\"head\", \"skin\");";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("editbox", "SkinText", "_lt", 10, 150, 200, 32);
		_this.readonly = true;
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "Test", "_lt", 50, 190, 64, 32);
		_this.text = "测试头部!";
		_this.onclick = ";Map3DSystem.UI.ItemEditor.TestItem(\"head\");";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "Test", "_lt", 130, 190, 64, 32);
		_this.text = "添加SQL";
		_parent:AddChild(_this);
		
	end
end

-- @param bShow: show or hide the panel 
function Map3DSystem.UI.ItemEditor.ShowShoulderEditor(bShow)

	local _this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_Shoulder");
	if(_this:IsValid() == true) then
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		_this.visible = bShow;
	else
		if(bShow == false) then return	end
		
		_this = ParaUI.CreateUIObject("container", "Map3DSystem_ItemEditor_Shoulder", "_rt", 
				-280, 320, 230, 350);
		_this:AttachToRoot();
		
		
		local _parent = _this;
		_this = ParaUI.CreateUIObject("text", "Model", "_lt", 10, 20, 120, 24);
		_this.text = "选择左肩膀模型:";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("button", "ModelDir", "_lt", 140, 20, 32, 16);
		_this.text = "...";
		_this.onclick = ";Map3DSystem.UI.ItemEditor.ShowOpenFileDialog(\"shoulder\", \"model\");";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("editbox", "ModelText", "_lt", 10, 40, 200, 32);
		_this.readonly = true;
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("text", "Skin", "_lt", 10, 80, 120, 24);
		_this.text = "选择左肩膀模型贴图:";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("button", "SkinDir", "_lt", 140, 80, 32, 16);
		_this.text = "...";
		_this.onclick = ";Map3DSystem.UI.ItemEditor.ShowOpenFileDialog(\"shoulder\", \"skin\");";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("editbox", "SkinText", "_lt", 10, 100, 200, 32);
		_this.readonly = true;
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("text", "Model2", "_lt", 10, 140, 120, 24);
		_this.text = "选择右肩膀模型:";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("button", "Model2Dir", "_lt", 140, 140, 32, 16);
		_this.text = "...";
		_this.onclick = ";Map3DSystem.UI.ItemEditor.ShowOpenFileDialog(\"shoulder\", \"model2\");";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("editbox", "Model2Text", "_lt", 10, 160, 200, 32);
		_this.readonly = true;
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("text", "Skin2", "_lt", 10, 200, 120, 24);
		_this.text = "选择右肩膀模型贴图:";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("button", "Skin2Dir", "_lt", 140, 200, 32, 16);
		_this.text = "...";
		_this.onclick = ";Map3DSystem.UI.ItemEditor.ShowOpenFileDialog(\"shoulder\", \"skin2\");";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("editbox", "Skin2Text", "_lt", 10, 220, 200, 32);
		_this.readonly = true;
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "Test", "_lt", 50, 260, 64, 32);
		_this.text = "测试肩膀!";
		_this.onclick = ";Map3DSystem.UI.ItemEditor.TestItem(\"shoulder\");";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "Test", "_lt", 130, 260, 64, 32);
		_this.text = "添加SQL";
		_parent:AddChild(_this);
		
	end
end

-- @param bShow: show or hide the panel 
function Map3DSystem.UI.ItemEditor.ShowWeaponLEditor(bShow)

	local _this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_WeaponL");
	if(_this:IsValid() == true) then
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		_this.visible = bShow;
	else
		if(bShow == false) then return	end
		
		_this = ParaUI.CreateUIObject("container", "Map3DSystem_ItemEditor_WeaponL", "_rt", 
				-280, 320, 230, 350);
		_this:AttachToRoot();
		
		
		local _parent = _this;
		_this = ParaUI.CreateUIObject("text", "Model", "_lt", 10, 30, 120, 24);
		_this.text = "选择左手武器模型:";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("button", "ModelDir", "_lt", 140, 30, 64, 32);
		_this.text = "...";
		_this.onclick = ";Map3DSystem.UI.ItemEditor.ShowOpenFileDialog(\"weaponL\", \"model\");";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("editbox", "ModelText", "_lt", 10, 70, 200, 32);
		_this.readonly = true;
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("text", "Skin", "_lt", 10, 110, 120, 24);
		_this.text = "选择左手武器模型贴图:";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("button", "SkinDir", "_lt", 140, 110, 64, 32);
		_this.text = "...";
		_this.onclick = ";Map3DSystem.UI.ItemEditor.ShowOpenFileDialog(\"weaponL\", \"skin\");";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("editbox", "SkinText", "_lt", 10, 150, 200, 32);
		_this.readonly = true;
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "Test", "_lt", 50, 190, 64, 32);
		_this.text = "测试左手武器!";
		_this.onclick = ";Map3DSystem.UI.ItemEditor.TestItem(\"weaponL\");";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "Test", "_lt", 130, 190, 64, 32);
		_this.text = "添加SQL";
		_parent:AddChild(_this);
		
	end
end

-- @param bShow: show or hide the panel 
function Map3DSystem.UI.ItemEditor.ShowWeaponREditor(bShow)

	local _this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_WeaponR");
	if(_this:IsValid() == true) then
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		_this.visible = bShow;
	else
		if(bShow == false) then return	end
		
		_this = ParaUI.CreateUIObject("container", "Map3DSystem_ItemEditor_WeaponR", "_rt", 
				-280, 320, 230, 350);
		_this:AttachToRoot();
		
		
		local _parent = _this;
		_this = ParaUI.CreateUIObject("text", "Model", "_lt", 10, 30, 120, 24);
		_this.text = "选择右手武器模型:";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("button", "ModelDir", "_lt", 140, 30, 64, 32);
		_this.text = "...";
		_this.onclick = ";Map3DSystem.UI.ItemEditor.ShowOpenFileDialog(\"weaponR\", \"model\");";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("editbox", "ModelText", "_lt", 10, 70, 200, 32);
		_this.readonly = true;
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("text", "Skin", "_lt", 10, 110, 120, 24);
		_this.text = "选择右手武器模型贴图:";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("button", "SkinDir", "_lt", 140, 110, 64, 32);
		_this.text = "...";
		_this.onclick = ";Map3DSystem.UI.ItemEditor.ShowOpenFileDialog(\"weaponR\", \"skin\");";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("editbox", "SkinText", "_lt", 10, 150, 200, 32);
		_this.readonly = true;
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "Test", "_lt", 50, 190, 64, 32);
		_this.text = "测试右手武器!";
		_this.onclick = ";Map3DSystem.UI.ItemEditor.TestItem(\"weaponR\");";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "Test", "_lt", 130, 190, 64, 32);
		_this.text = "添加SQL";
		_parent:AddChild(_this);
		
	end
end

-- @param bShow: show or hide the panel 
function Map3DSystem.UI.ItemEditor.ShowShirtEditor(bShow)

	local _this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_Shirt");
	if(_this:IsValid() == true) then
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		_this.visible = bShow;
	else
		if(bShow == false) then return	end
		
		_this = ParaUI.CreateUIObject("container", "Map3DSystem_ItemEditor_Shirt", "_rt", 
				-280, 320, 230, 350);
		_this:AttachToRoot();
		
		
		local _parent = _this;
		_this = ParaUI.CreateUIObject("text", "SkinAU", "_lt", 10, 20, 120, 24);
		_this.text = "选择手臂上部贴图:";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("button", "SkinAUDir", "_lt", 140, 20, 32, 16);
		_this.text = "...";
		_this.onclick = ";Map3DSystem.UI.ItemEditor.ShowOpenFileDialog(\"shirt\", \"skinAU\");";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("editbox", "SkinAUText", "_lt", 10, 40, 200, 32);
		_this.readonly = true;
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("text", "SkinAL", "_lt", 10, 80, 120, 24);
		_this.text = "选择手臂下部贴图:";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("button", "SkinALDir", "_lt", 140, 80, 32, 16);
		_this.text = "...";
		_this.onclick = ";Map3DSystem.UI.ItemEditor.ShowOpenFileDialog(\"shirt\", \"skinAL\");";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("editbox", "SkinALText", "_lt", 10, 100, 200, 32);
		_this.readonly = true;
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("text", "SkinTU", "_lt", 10, 140, 120, 24);
		_this.text = "选择身体上部贴图:";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("button", "SkinTUDir", "_lt", 140, 140, 32, 16);
		_this.text = "...";
		_this.onclick = ";Map3DSystem.UI.ItemEditor.ShowOpenFileDialog(\"shirt\", \"skinTU\");";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("editbox", "SkinTUText", "_lt", 10, 160, 200, 32);
		_this.readonly = true;
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("text", "SkinTL", "_lt", 10, 200, 120, 24);
		_this.text = "选择身体下部贴图:";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("button", "SkinTLDir", "_lt", 140, 200, 32, 16);
		_this.text = "...";
		_this.onclick = ";Map3DSystem.UI.ItemEditor.ShowOpenFileDialog(\"shirt\", \"skinTL\");";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("editbox", "SkinTLText", "_lt", 10, 220, 200, 32);
		_this.readonly = true;
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("text", "ModelID", "_lt", 10, 260, 120, 24);
		_this.text = "选择上衣模型号:";
		_parent:AddChild(_this);
		--_this = ParaUI.CreateUIObject("button", "SkinDir", "_lt", 140, 260, 32, 16);
		--_this.text = "...";
		--_this.onclick = ";Map3DSystem.UI.ItemEditor.ShowOpenFileDialog(\"shirt\", \"skin\");";
		--_parent:AddChild(_this);
		--_this = ParaUI.CreateUIObject("editbox", "SkinText", "_lt", 10, 280, 200, 32);
		--_parent:AddChild(_this);
		
		NPL.load("(gl)script/ide/dropdownlistbox.lua");
		local ctl = CommonCtrl.dropdownlistbox:new{
			name = "ItemEditor_ShirtModelID",
			alignment = "_lt",
			left = 140,
			top = 260,
			width = 60,
			height = 24,
			dropdownheight = 120,
 			parent = _parent,
			text = "",
			items = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9",},
		};
		ctl:Show();
		
		_this = ParaUI.CreateUIObject("button", "Test", "_lt", 50, 290, 64, 32);
		_this.text = "测试上衣!";
		_this.onclick = ";Map3DSystem.UI.ItemEditor.TestItem(\"shirt\");";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "Test", "_lt", 130, 290, 64, 32);
		_this.text = "添加SQL";
		_parent:AddChild(_this);
		
	end
end

-- @param bShow: show or hide the panel 
function Map3DSystem.UI.ItemEditor.ShowGloveEditor(bShow)

	local _this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_Glove");
	if(_this:IsValid() == true) then
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		_this.visible = bShow;
	else
		if(bShow == false) then return	end
		
		_this = ParaUI.CreateUIObject("container", "Map3DSystem_ItemEditor_Glove", "_rt", 
				-280, 320, 230, 350);
		_this:AttachToRoot();
		
		
		local _parent = _this;
		_this = ParaUI.CreateUIObject("text", "Model", "_lt", 10, 30, 120, 24);
		_this.text = "选择手套模型号:";
		_parent:AddChild(_this);
		
		NPL.load("(gl)script/ide/dropdownlistbox.lua");
		local ctl = CommonCtrl.dropdownlistbox:new{
			name = "ItemEditor_GloveModelID",
			alignment = "_lt",
			left = 140,
			top = 30,
			width = 60,
			height = 24,
			dropdownheight = 120,
 			parent = _parent,
			text = "",
			items = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9",},
		};
		ctl:Show();
		
		_this = ParaUI.CreateUIObject("text", "Skin", "_lt", 10, 110, 120, 24);
		_this.text = "选择手套贴图:";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("button", "SkinDir", "_lt", 140, 110, 64, 32);
		_this.text = "...";
		_this.onclick = ";Map3DSystem.UI.ItemEditor.ShowOpenFileDialog(\"glove\", \"skin\");";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("editbox", "SkinText", "_lt", 10, 150, 200, 32);
		_this.readonly = true;
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "Test", "_lt", 50, 190, 64, 32);
		_this.text = "测试手套!";
		_this.onclick = ";Map3DSystem.UI.ItemEditor.TestItem(\"glove\");";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "Test", "_lt", 130, 190, 64, 32);
		_this.text = "添加SQL";
		_parent:AddChild(_this);
		
	end
end

-- @param bShow: show or hide the panel 
function Map3DSystem.UI.ItemEditor.ShowPantEditor(bShow)

	local _this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_Pant");
	if(_this:IsValid() == true) then
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		_this.visible = bShow;
	else
		if(bShow == false) then return	end
		
		_this = ParaUI.CreateUIObject("container", "Map3DSystem_ItemEditor_Pant", "_rt", 
				-280, 320, 230, 350);
		_this:AttachToRoot();
		
		
		local _parent = _this;
		_this = ParaUI.CreateUIObject("text", "Model", "_lt", 10, 30, 120, 24);
		_this.text = "选择裤子模型号:";
		_parent:AddChild(_this);
		
		NPL.load("(gl)script/ide/dropdownlistbox.lua");
		local ctl = CommonCtrl.dropdownlistbox:new{
			name = "ItemEditor_PantModelID",
			alignment = "_lt",
			left = 140,
			top = 30,
			width = 60,
			height = 24,
			dropdownheight = 120,
 			parent = _parent,
			text = "",
			items = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9",},
		};
		ctl:Show();
		
		_this = ParaUI.CreateUIObject("text", "Skin", "_lt", 10, 110, 120, 24);
		_this.text = "选择裤子上部贴图:";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("button", "SkinDir", "_lt", 140, 110, 64, 32);
		_this.text = "...";
		_this.onclick = ";Map3DSystem.UI.ItemEditor.ShowOpenFileDialog(\"pant\", \"skinLU\");";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("editbox", "SkinLUText", "_lt", 10, 150, 200, 32);
		_this.readonly = true;
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("text", "Skin", "_lt", 10, 190, 120, 24);
		_this.text = "选择裤子下部贴图:";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("button", "SkinDir", "_lt", 140, 190, 64, 32);
		_this.text = "...";
		_this.onclick = ";Map3DSystem.UI.ItemEditor.ShowOpenFileDialog(\"pant\", \"skinLL\");";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("editbox", "SkinLLText", "_lt", 10, 230, 200, 32);
		_this.readonly = true;
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "Test", "_lt", 50, 270, 64, 32);
		_this.text = "测试裤子!";
		_this.onclick = ";Map3DSystem.UI.ItemEditor.TestItem(\"pant\");";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "Test", "_lt", 130, 270, 64, 32);
		_this.text = "添加SQL";
		_parent:AddChild(_this);
		
	end
end

-- @param bShow: show or hide the panel 
function Map3DSystem.UI.ItemEditor.ShowBootEditor(bShow)

	local _this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_Boot");
	if(_this:IsValid() == true) then
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		_this.visible = bShow;
	else
		if(bShow == false) then return	end
		
		_this = ParaUI.CreateUIObject("container", "Map3DSystem_ItemEditor_Boot", "_rt", 
				-280, 320, 230, 350);
		_this:AttachToRoot();
		
		
		local _parent = _this;
		_this = ParaUI.CreateUIObject("text", "Model", "_lt", 10, 30, 120, 24);
		_this.text = "选择靴子模型号:";
		_parent:AddChild(_this);
		
		NPL.load("(gl)script/ide/dropdownlistbox.lua");
		local ctl = CommonCtrl.dropdownlistbox:new{
			name = "ItemEditor_BootModelID",
			alignment = "_lt",
			left = 140,
			top = 30,
			width = 60,
			height = 24,
			dropdownheight = 120,
 			parent = _parent,
			text = "",
			items = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9",},
		};
		ctl:Show();
		
		_this = ParaUI.CreateUIObject("text", "Skin", "_lt", 10, 110, 120, 24);
		_this.text = "选择靴子模型贴图:";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("button", "SkinDir", "_lt", 140, 110, 64, 32);
		_this.text = "...";
		_this.onclick = ";Map3DSystem.UI.ItemEditor.ShowOpenFileDialog(\"boot\", \"skin\");";
		_parent:AddChild(_this);
		_this = ParaUI.CreateUIObject("editbox", "SkinText", "_lt", 10, 150, 200, 32);
		_this.readonly = true;
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "Test", "_lt", 50, 190, 64, 32);
		_this.text = "测试靴子!";
		_this.onclick = ";Map3DSystem.UI.ItemEditor.TestItem(\"boot\");";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "Test", "_lt", 130, 190, 64, 32);
		_this.text = "添加SQL";
		_parent:AddChild(_this);
		
	end
end

function Map3DSystem.UI.ItemEditor.ShowOpenFileDialog(sClass, sType)
	
	Map3DSystem.UI.ItemEditor.Class = sClass;
	Map3DSystem.UI.ItemEditor.Type = sType;
	
	local _extension;
	local _rootpath;
	if(sClass == "head" and sType == "model") then
		_extension = "x";
		_rootpath = "character/v3/Item/ObjectComponents/Head/";
	elseif(sClass == "head" and sType == "skin") then
		_extension = "dds";
		_rootpath = "character/v3/Item/ObjectComponents/Head/";
		
	elseif(sClass == "shoulder" and sType == "model") then
		_extension = "x";
		_rootpath = "character/v3/Item/ObjectComponents/Shoulder/";
	elseif(sClass == "shoulder" and sType == "model2") then
		_extension = "x";
		_rootpath = "character/v3/Item/ObjectComponents/Shoulder/";
	elseif(sClass == "shoulder" and sType == "skin") then
		_extension = "dds";
		_rootpath = "character/v3/Item/ObjectComponents/Shoulder/";
	elseif(sClass == "shoulder" and sType == "skin2") then
		_extension = "dds";
		_rootpath = "character/v3/Item/ObjectComponents/Shoulder/";
		
	elseif(sClass == "weaponL" and sType == "model") then
		_extension = "x";
		_rootpath = "character/v3/Item/ObjectComponents/Weapon/";
	elseif(sClass == "weaponL" and sType == "skin") then
		_extension = "dds";
		_rootpath = "character/v3/Item/ObjectComponents/Weapon/";
		
	elseif(sClass == "weaponR" and sType == "model") then
		_extension = "x";
		_rootpath = "character/v3/Item/ObjectComponents/Weapon/";
	elseif(sClass == "weaponR" and sType == "skin") then
		_extension = "dds";
		_rootpath = "character/v3/Item/ObjectComponents/Weapon/";
		
	elseif(sClass == "shirt" and sType == "skinAU") then
		_extension = "dds";
		_rootpath = "character/v3/Item/TextureComponents/ArmUpperTexture/";
	elseif(sClass == "shirt" and sType == "skinAL") then
		_extension = "dds";
		_rootpath = "character/v3/Item/TextureComponents/ArmLowerTexture/";
	elseif(sClass == "shirt" and sType == "skinTU") then
		_extension = "dds";
		_rootpath = "character/v3/Item/TextureComponents/TorsoUpperTexture/";
	elseif(sClass == "shirt" and sType == "skinTL") then
		_extension = "dds";
		_rootpath = "character/v3/Item/TextureComponents/TorsoLowerTexture/";
		
	elseif(sClass == "glove" and sType == "skin") then
		_extension = "dds";
		_rootpath = "character/v3/Item/TextureComponents/HandTexture/";
		
	elseif(sClass == "pant" and sType == "skinLU") then
		_extension = "dds";
		_rootpath = "character/v3/Item/TextureComponents/LegUpperTexture/";
	elseif(sClass == "pant" and sType == "skinLL") then
		_extension = "dds";
		_rootpath = "character/v3/Item/TextureComponents/LegLowerTexture/";
		
	elseif(sClass == "boot" and sType == "skin") then
		_extension = "dds";
		_rootpath = "character/v3/Item/TextureComponents/FootTexture/";
	end
	
	NPL.load("(gl)script/ide/action_table.lua");
	NPL.load("(gl)script/ide/OpenFileDialog.lua");
	local ctl = CommonCtrl.OpenFileDialog:new{
		name = "OpenFileDialogHead",
		alignment = "_lt",
		left = 100, top = 100,
		width = 500,
		height = 500,
		parent = nil,
		fileextensions = {"all files(*.".._extension..")" },
		folderlinks = {
			{path = _rootpath, text = sClass},
		},
		showSubDirLevels = 1,
		onopen = Map3DSystem.UI.ItemEditor.FileSelect,
	};
	ctl:Show(true);
end

function Map3DSystem.UI.ItemEditor.FileSelect(sCtrlName, filename)

	local _sClass = Map3DSystem.UI.ItemEditor.Class;
	local _sType = Map3DSystem.UI.ItemEditor.Type;
	
	if(_sClass == "head" and _sType == "model") then
		local _this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_Head");
		local _text = _this:GetChild("ModelText");
		_text.text = ParaIO.GetFileName(filename);
	elseif(_sClass == "head" and _sType == "skin") then
		local _this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_Head");
		local _text = _this:GetChild("SkinText");
		_text.text = ParaIO.GetFileName(filename);
		
	elseif(_sClass == "shoulder" and _sType == "model") then
		local _this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_Shoulder");
		local _text = _this:GetChild("ModelText");
		_text.text = ParaIO.GetFileName(filename);
	elseif(_sClass == "shoulder" and _sType == "model2") then
		local _this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_Shoulder");
		local _text = _this:GetChild("Model2Text");
		_text.text = ParaIO.GetFileName(filename);
	elseif(_sClass == "shoulder" and _sType == "skin") then
		local _this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_Shoulder");
		local _text = _this:GetChild("SkinText");
		_text.text = ParaIO.GetFileName(filename);
	elseif(_sClass == "shoulder" and _sType == "skin2") then
		local _this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_Shoulder");
		local _text = _this:GetChild("Skin2Text");
		_text.text = ParaIO.GetFileName(filename);
		
	elseif(_sClass == "weaponL" and _sType == "model") then
		local _this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_WeaponL");
		local _text = _this:GetChild("ModelText");
		_text.text = ParaIO.GetFileName(filename);
	elseif(_sClass == "weaponL" and _sType == "skin") then
		local _this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_WeaponL");
		local _text = _this:GetChild("SkinText");
		_text.text = ParaIO.GetFileName(filename);
		
	elseif(_sClass == "weaponR" and _sType == "model") then
		local _this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_WeaponR");
		local _text = _this:GetChild("ModelText");
		_text.text = ParaIO.GetFileName(filename);
	elseif(_sClass == "weaponR" and _sType == "skin") then
		local _this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_WeaponR");
		local _text = _this:GetChild("SkinText");
		_text.text = ParaIO.GetFileName(filename);
		
	elseif(_sClass == "shirt" and _sType == "skinAU") then
		local _this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_Shirt");
		local _text = _this:GetChild("SkinAUText");
		_text.text = ParaIO.GetFileName(filename);
	elseif(_sClass == "shirt" and _sType == "skinAL") then
		local _this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_Shirt");
		local _text = _this:GetChild("SkinALText");
		_text.text = ParaIO.GetFileName(filename);
	elseif(_sClass == "shirt" and _sType == "skinTL") then
		local _this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_Shirt");
		local _text = _this:GetChild("SkinTLText");
		_text.text = ParaIO.GetFileName(filename);
	elseif(_sClass == "shirt" and _sType == "skinTU") then
		local _this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_Shirt");
		local _text = _this:GetChild("SkinTUText");
		_text.text = ParaIO.GetFileName(filename);
		
	elseif(_sClass == "glove" and _sType == "skin") then
		local _this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_Glove");
		local _text = _this:GetChild("SkinText");
		_text.text = ParaIO.GetFileName(filename);
		
	elseif(_sClass == "pant" and _sType == "skinLU") then
		local _this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_Pant");
		local _text = _this:GetChild("SkinLUText");
		_text.text = ParaIO.GetFileName(filename);
	elseif(_sClass == "pant" and _sType == "skinLL") then
		local _this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_Pant");
		local _text = _this:GetChild("SkinLLText");
		_text.text = ParaIO.GetFileName(filename);
		
	elseif(_sClass == "boot" and _sType == "skin") then
		local _this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_Boot");
		local _text = _this:GetChild("SkinText");
		_text.text = ParaIO.GetFileName(filename);
	end
	
	--log("sCtrlName:"..sCtrlName.."  filename:"..filename.."\n");
end

function Map3DSystem.UI.ItemEditor.TestItem(sClass)

	NPL.load("(gl)script/sqlite/sqlite3.lua");
	
	local _dbfile = "Database/characters.db";
	local db = sqlite3.open(_dbfile);
	if(db == nil) then
		log("error: open database file: ".._dbfile.."\n");
		return;
	end
	local row;
	local typeStr;
	
	local player = Map3DSystem.obj.GetObject("selection");
	local playerChar;
	
	if(player==nil or player:IsValid()==false) then
		player = ParaScene.GetPlayer();
	end
	
	if(player~=nil and player:IsValid()==true) then
		if(player:IsCharacter()) then
			playerChar = player:ToCharacter();
			if(playerChar:IsCustomModel() == true) then
				
				if(sClass == "head") then
					playerChar:SetCharacterSlot(Map3DSystem.UI.ItemEditor.CS_HEAD, 0);
				elseif(sClass == "shoulder") then
					playerChar:SetCharacterSlot(Map3DSystem.UI.ItemEditor.CS_SHOULDER, 0);
				elseif(sClass == "weaponL") then
					playerChar:SetCharacterSlot(Map3DSystem.UI.ItemEditor.CS_HAND_LEFT, 0);
				elseif(sClass == "weaponR") then
					playerChar:SetCharacterSlot(Map3DSystem.UI.ItemEditor.CS_HAND_RIGHT, 0);
				elseif(sClass == "shirt") then
					playerChar:SetCharacterSlot(Map3DSystem.UI.ItemEditor.CS_SHIRT, 0);
				elseif(sClass == "glove") then
					playerChar:SetCharacterSlot(Map3DSystem.UI.ItemEditor.CS_GLOVES, 0);
				elseif(sClass == "pant") then
					playerChar:SetCharacterSlot(Map3DSystem.UI.ItemEditor.CS_PANTS, 0);
				elseif(sClass == "boot") then
					playerChar:SetCharacterSlot(Map3DSystem.UI.ItemEditor.CS_BOOTS, 0);
				end
			end
		else
			_guihelper.MessageBox("请选中你要测试的人物");
			db:close();
			return;
		end
	end
	
	if(sClass == "head") then
		Map3DSystem.UI.ItemEditor.ResetItemDisplayDBRecord(db, 1);
		local _this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_Head");
		local _modeltext = _this:GetChild("ModelText").text;
		local _skintext = _this:GetChild("SkinText").text;
		db:exec("UPDATE ItemDisplayDB SET Model = '".._modeltext.."' WHERE ItemDisplayID = 1;");
		db:exec("UPDATE ItemDisplayDB SET Skin = '".._skintext.."' WHERE ItemDisplayID = 1;");
		db:exec("UPDATE ItemDatabase SET type = 1 WHERE id = 1;");
	elseif(sClass == "shoulder") then
		Map3DSystem.UI.ItemEditor.ResetItemDisplayDBRecord(db, 2);
		local _this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_Shoulder");
		local _modeltext = _this:GetChild("ModelText").text;
		local _skintext = _this:GetChild("SkinText").text;
		local _model2text = _this:GetChild("Model2Text").text;
		local _skin2text = _this:GetChild("Skin2Text").text;
		db:exec("UPDATE ItemDisplayDB SET Model = '".._modeltext.."' WHERE ItemDisplayID = 2;");
		db:exec("UPDATE ItemDisplayDB SET Skin = '".._skintext.."' WHERE ItemDisplayID = 2;");
		db:exec("UPDATE ItemDisplayDB SET Model2 = '".._model2text.."' WHERE ItemDisplayID = 2;");
		db:exec("UPDATE ItemDisplayDB SET Skin2 = '".._skin2text.."' WHERE ItemDisplayID = 2;");
		db:exec("UPDATE ItemDatabase SET type = 7 WHERE id = 2;");
	elseif(sClass == "weaponL") then
		Map3DSystem.UI.ItemEditor.ResetItemDisplayDBRecord(db, 3);
		local _this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_WeaponL");
		local _modeltext = _this:GetChild("ModelText").text;
		local _skintext = _this:GetChild("SkinText").text;
		db:exec("UPDATE ItemDisplayDB SET Model = '".._modeltext.."' WHERE ItemDisplayID = 3;");
		db:exec("UPDATE ItemDisplayDB SET Skin = '".._skintext.."' WHERE ItemDisplayID = 3;");
		db:exec("UPDATE ItemDatabase SET type = 21 WHERE id = 3;");
	elseif(sClass == "weaponR") then
		Map3DSystem.UI.ItemEditor.ResetItemDisplayDBRecord(db, 4);
		local _this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_WeaponR");
		local _modeltext = _this:GetChild("ModelText").text;
		local _skintext = _this:GetChild("SkinText").text;
		db:exec("UPDATE ItemDisplayDB SET Model = '".._modeltext.."' WHERE ItemDisplayID = 4;");
		db:exec("UPDATE ItemDisplayDB SET Skin = '".._skintext.."' WHERE ItemDisplayID = 4;");
		db:exec("UPDATE ItemDatabase SET type = 21 WHERE id = 4;");
	elseif(sClass == "shirt") then
		Map3DSystem.UI.ItemEditor.ResetItemDisplayDBRecord(db, 5);
		local _this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_Shirt");
		local _skinAU = _this:GetChild("SkinAUText").text;
		local _skinAL = _this:GetChild("SkinALText").text;
		local _skinTU = _this:GetChild("SkinTUText").text;
		local _skinTL = _this:GetChild("SkinTLText").text;
		local _modelID = CommonCtrl.GetControl("ItemEditor_ShirtModelID"):GetText();
		db:exec("UPDATE ItemDisplayDB SET TexArmUpper = '".._skinAU.."' WHERE ItemDisplayID = 5;");
		db:exec("UPDATE ItemDisplayDB SET TexArmLower = '".._skinAL.."' WHERE ItemDisplayID = 5;");
		db:exec("UPDATE ItemDisplayDB SET TexChestUpper = '".._skinTU.."' WHERE ItemDisplayID = 5;");
		db:exec("UPDATE ItemDisplayDB SET TexChestLower = '".._skinTL.."' WHERE ItemDisplayID = 5;");
		db:exec("UPDATE ItemDisplayDB SET GeoSetA = '".._modelID.."' WHERE ItemDisplayID = 5;");
		db:exec("UPDATE ItemDatabase SET type = 4 WHERE id = 5;");
	elseif(sClass == "glove") then
		Map3DSystem.UI.ItemEditor.ResetItemDisplayDBRecord(db, 6);
		local _this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_Glove");
		local _skin = _this:GetChild("SkinText").text;
		local _modelID = CommonCtrl.GetControl("ItemEditor_GloveModelID"):GetText();
		db:exec("UPDATE ItemDisplayDB SET TexHands = '".._skin.."' WHERE ItemDisplayID = 6;");
		db:exec("UPDATE ItemDisplayDB SET GeoSetA = '".._modelID.."' WHERE ItemDisplayID = 6;");
		db:exec("UPDATE ItemDatabase SET type = 10 WHERE id = 6;");
	elseif(sClass == "pant") then
		Map3DSystem.UI.ItemEditor.ResetItemDisplayDBRecord(db, 7);
		local _this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_Pant");
		local _skinLU = _this:GetChild("SkinLUText").text;
		local _skinLL = _this:GetChild("SkinLLText").text;
		local _modelID = CommonCtrl.GetControl("ItemEditor_PantModelID"):GetText();
		db:exec("UPDATE ItemDisplayDB SET TexLegUpper = '".._skinLU.."' WHERE ItemDisplayID = 7;");
		db:exec("UPDATE ItemDisplayDB SET TexLegLower = '".._skinLL.."' WHERE ItemDisplayID = 7;");
		db:exec("UPDATE ItemDisplayDB SET GeoSetB = '".._modelID.."' WHERE ItemDisplayID = 7;");
		db:exec("UPDATE ItemDatabase SET type = 7 WHERE id = 7;");
	elseif(sClass == "boot") then
		Map3DSystem.UI.ItemEditor.ResetItemDisplayDBRecord(db, 8);
		local _this = ParaUI.GetUIObject("Map3DSystem_ItemEditor_Boot");
		local _skin = _this:GetChild("SkinText").text;
		local _modelID = CommonCtrl.GetControl("ItemEditor_BootModelID"):GetText();
		db:exec("UPDATE ItemDisplayDB SET TexFeet = '".._skin.."' WHERE ItemDisplayID = 8;");
		db:exec("UPDATE ItemDisplayDB SET GeoSetA = '".._modelID.."' WHERE ItemDisplayID = 8;");
		db:exec("UPDATE ItemDatabase SET type = 8 WHERE id = 8;");
	end
	
	if(player~=nil and player:IsValid()==true) then
		if(player:IsCharacter()) then
			playerChar = player:ToCharacter();
			if(playerChar:IsCustomModel() == true) then
				
				if(sClass == "head") then
					playerChar:SetCharacterSlot(Map3DSystem.UI.ItemEditor.CS_HEAD, 1);
				elseif(sClass == "shoulder") then
					playerChar:SetCharacterSlot(Map3DSystem.UI.ItemEditor.CS_SHOULDER, 2);
				elseif(sClass == "weaponL") then
					playerChar:SetCharacterSlot(Map3DSystem.UI.ItemEditor.CS_HAND_LEFT, 3);
				elseif(sClass == "weaponR") then
					playerChar:SetCharacterSlot(Map3DSystem.UI.ItemEditor.CS_HAND_RIGHT, 4);
				elseif(sClass == "shirt") then
					playerChar:SetCharacterSlot(Map3DSystem.UI.ItemEditor.CS_SHIRT, 5);
				elseif(sClass == "glove") then
					playerChar:SetCharacterSlot(Map3DSystem.UI.ItemEditor.CS_GLOVES, 6);
				elseif(sClass == "pant") then
					playerChar:SetCharacterSlot(Map3DSystem.UI.ItemEditor.CS_PANTS, 7);
				elseif(sClass == "boot") then
					playerChar:SetCharacterSlot(Map3DSystem.UI.ItemEditor.CS_BOOTS, 8);
				end
			end
		else
			_guihelper.MessageBox("请选中你要测试的人物");
			db:close();
			return;
		end
	end
	
	--if(type == BCS_db.MARKER_FREE_POINT) then
		--typeStr = "0 or type= 1 or type = 2 or type = 3 or type = 4 or type = 5 or type = 6";
	--elseif(type == BCS_db.MARKER_WALL_POINT) then
		--typeStr = "2 or type = 3 or type = 4";
	--elseif(type == BCS_db.MARKER_BLOCKTOP_POINT) then
		--typeStr = "1 or type = 4 or type = 5";
	--elseif(type == BCS_db.MARKER_GROUND_POINT) then
		--typeStr = "1 or type = 6";
	--end
	--
	--for row in db:rows(string.format("select Path from BuildingBlockDB where Type= %s",typeStr)) do
		--result[i] = tostring(row.Path);
		--i = i+1;
	--end
	
	
	db:close();
end

function Map3DSystem.UI.ItemEditor.ResetItemDisplayDBRecord(db, ID)
	db:exec("UPDATE ItemDatabase SET itemclass = 0 WHERE id = "..ID..";");
	db:exec("UPDATE ItemDatabase SET subclass = 0 WHERE id = "..ID..";");
	db:exec("UPDATE ItemDatabase SET type = -1 WHERE id = "..ID..";");
	db:exec("UPDATE ItemDatabase SET model = "..ID.." WHERE id = "..ID..";");
	db:exec("UPDATE ItemDatabase SET name = 'TEST Reserve' WHERE id = "..ID..";");
	
	db:exec("UPDATE ItemDisplayDB SET Model = '' WHERE ItemDisplayID = "..ID..";");
	db:exec("UPDATE ItemDisplayDB SET Model2 = '' WHERE ItemDisplayID = "..ID..";");
	db:exec("UPDATE ItemDisplayDB SET Skin = '' WHERE ItemDisplayID = "..ID..";");
	db:exec("UPDATE ItemDisplayDB SET Skin2 = '' WHERE ItemDisplayID = "..ID..";");
	db:exec("UPDATE ItemDisplayDB SET Icon = 'TEST Reserve' WHERE ItemDisplayID = "..ID..";");
	db:exec("UPDATE ItemDisplayDB SET GeosetA = 0 WHERE ItemDisplayID = "..ID..";");
	db:exec("UPDATE ItemDisplayDB SET GeosetB = 0 WHERE ItemDisplayID = "..ID..";");
	db:exec("UPDATE ItemDisplayDB SET GeosetC = 0 WHERE ItemDisplayID = "..ID..";");
	db:exec("UPDATE ItemDisplayDB SET GeosetD = 0 WHERE ItemDisplayID = "..ID..";");
	db:exec("UPDATE ItemDisplayDB SET GeosetE = 0 WHERE ItemDisplayID = "..ID..";");
	db:exec("UPDATE ItemDisplayDB SET Flags = 0 WHERE ItemDisplayID = "..ID..";");
	db:exec("UPDATE ItemDisplayDB SET GeosetVisID1 = 0 WHERE ItemDisplayID = "..ID..";");
	db:exec("UPDATE ItemDisplayDB SET GeosetVisID2 = 0 WHERE ItemDisplayID = "..ID..";");
	db:exec("UPDATE ItemDisplayDB SET TexArmUpper = '' WHERE ItemDisplayID = "..ID..";");
	db:exec("UPDATE ItemDisplayDB SET TexArmLower = '' WHERE ItemDisplayID = "..ID..";");
	db:exec("UPDATE ItemDisplayDB SET TexHands = '' WHERE ItemDisplayID = "..ID..";");
	db:exec("UPDATE ItemDisplayDB SET TexChestUpper = '' WHERE ItemDisplayID = "..ID..";");
	db:exec("UPDATE ItemDisplayDB SET TexChestLower = '' WHERE ItemDisplayID = "..ID..";");
	db:exec("UPDATE ItemDisplayDB SET TexLegUpper = '' WHERE ItemDisplayID = "..ID..";");
	db:exec("UPDATE ItemDisplayDB SET TexLegLower = '' WHERE ItemDisplayID = "..ID..";");
	db:exec("UPDATE ItemDisplayDB SET TexFeet = '' WHERE ItemDisplayID = "..ID..";");
	db:exec("UPDATE ItemDisplayDB SET Visuals = 0 WHERE ItemDisplayID = "..ID..";");
end