--[[
Title: character customization system UI plug-in for oridinary model
Author(s): WangTian
Date: 2007/9/6
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/CCS/CCS_UI_Model.lua");
CCS_UI_Model.Show();
-------------------------------------------------------
]]

-------------------------------------
-- TODO: this is a STAND-ALONE UI 
--
-- CommonCtrl.CKidMiddleContainer.SwitchUI("CharacterModel");
-- CCS_UI_Model.Show();
-------------------------------------

-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/kids/CCS/CCS_db.lua");

NPL.load("(gl)script/kids/kids_db.lua");


-- Debug purpose
NPL.load("(gl)script/ide/gui_helper.lua");

if(not CCS_UI_Model) then CCS_UI_Model = {}; end

-- create, init and display the ordinary model UI control
--@param parent: ParaUIObject which is the parent container
function CCS_UI_Model.Show()


	local characterModelMainMenu = ParaUI.GetUIObject("kidui_character_container");

	ParaUI.Destroy("kidui_character_sub_container");
	
	local menuIcon=ParaUI.CreateUIObject("container","kidui_character_sub_container","_fi",0,0,0,0);
	characterModelMainMenu:AddChild(menuIcon);
	menuIcon.background="Texture/whitedot.png;0 0 0 0";
	
	_parent = menuIcon;
		
		
_this = ParaUI.CreateUIObject("button", "btnModelReset", "_rb", -64, -68, 64, 64)
_this.text = "Return";
--_this.background="Texture/kidui/CCS/btn_BCS_Reset.png";
_this.onclick = ";CCS_UI_Model.OnClickReturn();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btnModelPageRight", "_lt", 107, 3, 32, 32)
_this.text = "->";
--_this.background="Texture/kidui/CCS/btn_CCS_CF_Page_Right.png";
_this.onclick = ";CCS_UI_Model.OnClickPageRight();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btnModelPageLeft", "_lt", 23, 3, 32, 32)
_this.text = "<-";
--_this.background="Texture/kidui/CCS/btn_CCS_CF_Page_Left.png";
_this.onclick = ";CCS_UI_Model.OnClickPageLeft();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("text", "labelModelPage", "_lt", 61, 14, 40, 16)
_this.text = "0/0";
_parent:AddChild(_this);



		--local faceSectionType = CCS_UI_ModelComponent.GetFaceSection();
		
		local nCount = table.getn(kids_db.items[6]);
		
		--CCS_UI_Model.totalPage = 5;
		CCS_UI_Model.totalIcons = nCount;
		CCS_UI_Model.iconsPerPage = 16; -- 2*8 matrix
		
		local remain = math.mod(nCount, CCS_UI_Model.iconsPerPage);
		if(remain == 0) then
			CCS_UI_Model.totalPage = nCount / CCS_UI_Model.iconsPerPage;
		else
			CCS_UI_Model.totalPage = (nCount-remain) / CCS_UI_Model.iconsPerPage + 1;
		end
		
		if(nCount == 0) then
			CCS_UI_Model.totalPage = 1;
		end
		
		CCS_UI_Model.currentPage = 1;
		CCS_UI_Model.OnClickPageLeft();
		
		
		
		
end -- function CCS_UI_Model.Show(parent)

function CCS_UI_Model.OnClickReturn()
end

-- Page Left
function CCS_UI_Model.OnClickPageLeft()

	local _this,_parent;
	
	if(CCS_UI_Model.currentPage > 0) then
	
		CCS_UI_Model.currentPage = CCS_UI_Model.currentPage - 1;
		local _thisCont = ParaUI.GetUIObject("kidui_character_sub_container");
		
		_this = _thisCont:GetChild("labelModelPage");
		_this.text = (CCS_UI_Model.currentPage+1).."/"..CCS_UI_Model.totalPage;
		
		if(_thisCont:IsValid()) then
			local _container = _thisCont:GetChild("CCS_UI_Model_iconmatrix_container");
			local _currentIconNum;
			_currentIconNum = (CCS_UI_Model.currentPage)*(CCS_UI_Model.iconsPerPage);
			ParaUI.Destroy("CCS_UI_Model_iconmatrix_container");
			
			_this = ParaUI.CreateUIObject("container", "CCS_UI_Model_iconmatrix_container", "_lt", 0,47,500,150)
			_this.background="Texture/whitedot.png;0 0 0 0";
			_thisCont:AddChild(_this);
			
			_parent = _this;
			
			local initialTop = 0;
			local initialLeft = 20;
			local initialIconSize = 48;
			local initialMatrixX = 8;
			local initialMatrixY = 2;
			local initialGap = 3;
			local initialBGSize = 57;
			local initialIconOffset = 3;
			local posX, posY;
			
			for y=0, initialMatrixY-1 do
				for x=0, initialMatrixX-1 do
					if(_currentIconNum < CCS_UI_Model.totalIcons) then
						posX = initialLeft + x * (initialBGSize+initialGap);
						posY = initialTop + y * (initialBGSize+initialGap);
						_this = ParaUI.CreateUIObject("button", "btnMatrixBG"..y..x, "_lt", posX, posY, initialBGSize, initialBGSize)
						_this.background="Texture/kidui/CCS/btn_BCS_Icon_Slot.png";
						_parent:AddChild(_this);
						_this = ParaUI.CreateUIObject("button", "btnMatrix"..y..x, "_lt", posX+initialIconOffset, posY+initialIconOffset, initialIconSize, initialIconSize)
						--_this.text = "F"..(_currentIconNum+1);
						local page = CCS_UI_Model.currentPage;
						local pathNum = page*(CCS_UI_Model.iconsPerPage)+y*initialMatrixX+x+1;
						_this.background = kids_db.items[6][pathNum].IconFilePath;
						_this.animstyle = 22;
						_this.onclick = ";CCS_UI_Model.OnIconMatrixClick("..pathNum..");";
						_parent:AddChild(_this);
						_currentIconNum = _currentIconNum + 1;
					else
						posX = initialLeft + x * (initialBGSize+initialGap);
						posY = initialTop + y * (initialBGSize+initialGap);
						--_this = ParaUI.CreateUIObject("button", "btnMatrix"..y..x, "_lt", posX, posY, initialIconSize, initialIconSize)
						----_this.text = "F"..(_currentIconNum+1);
						--_this.background="Texture/kidui/CCS/btn_CCS_CF_CartoonSlot_Empty.png";
						_this = ParaUI.CreateUIObject("button", "btnMatrixBG"..y..x, "_lt", posX, posY, initialBGSize, initialBGSize)
						_this.background="Texture/kidui/CCS/btn_BCS_Icon_Slot_empty.png";
						_parent:AddChild(_this);
						_currentIconNum = _currentIconNum + 1;
					end
				end
			end
			
			
		end -- if(_this:IsValid()) then
		
	end -- if(CCS_UI_Model.currentPage > 1) then
	
end -- function CCS_UI_Model.PageLeft()


-- Page Right
function CCS_UI_Model.OnClickPageRight()

	local _this,_parent;
		
	if(CCS_UI_Model.currentPage < (CCS_UI_Model.totalPage-1) ) then
	
		CCS_UI_Model.currentPage = CCS_UI_Model.currentPage + 1;
		local _thisCont = ParaUI.GetUIObject("kidui_character_sub_container");
		
		_this = _thisCont:GetChild("labelModelPage");
		_this.text = (CCS_UI_Model.currentPage+1).."/"..CCS_UI_Model.totalPage;
		
		
		if(_thisCont:IsValid()) then
			local _container = _thisCont:GetChild("CCS_UI_Model_iconmatrix_container");
			local _currentIconNum;
			_currentIconNum = (CCS_UI_Model.currentPage)*(CCS_UI_Model.iconsPerPage);
			ParaUI.Destroy("CCS_UI_Model_iconmatrix_container");
			
			_this = ParaUI.CreateUIObject("container", "CCS_UI_Model_iconmatrix_container", "_lt", 0,47,500,150)
			_this.background="Texture/whitedot.png;0 0 0 0";
			_thisCont:AddChild(_this);
			
			_parent = _this;
			
			local initialTop = 0;
			local initialLeft = 20;
			local initialIconSize = 48;
			local initialMatrixX = 8;
			local initialMatrixY = 2;
			local initialGap = 3;
			local initialBGSize = 57;
			local initialIconOffset = 3;
			local posX, posY;
			local posX, posY;
			
			for y=0, initialMatrixY-1 do
				for x=0, initialMatrixX-1 do
					if(_currentIconNum < CCS_UI_Model.totalIcons) then
						posX = initialLeft + x * (initialBGSize+initialGap);
						posY = initialTop + y * (initialBGSize+initialGap);
						_this = ParaUI.CreateUIObject("button", "btnMatrixBG"..y..x, "_lt", posX, posY, initialBGSize, initialBGSize)
						_this.background="Texture/kidui/CCS/btn_BCS_Icon_Slot.png";
						_parent:AddChild(_this);
						_this = ParaUI.CreateUIObject("button", "btnMatrix"..y..x, "_lt", posX+initialIconOffset, posY+initialIconOffset, initialIconSize, initialIconSize);
						--_this.text = "F"..(_currentIconNum+1);
						local page = CCS_UI_Model.currentPage;
						local pathNum = page*(CCS_UI_Model.iconsPerPage)+y*initialMatrixX+x+1;
						_this.background = kids_db.items[6][pathNum].IconFilePath;
						_this.animstyle = 22;
						--_this.onclick = ";CCS_UI_Model.OnIconMatrixClick"..y..x.."();";
						_this.onclick = ";CCS_UI_Model.OnIconMatrixClick("..pathNum..");";
						_parent:AddChild(_this);
						_currentIconNum = _currentIconNum + 1;
					else
						posX = initialLeft + x * (initialBGSize+initialGap);
						posY = initialTop + y * (initialBGSize+initialGap);
						--_this = ParaUI.CreateUIObject("button", "btnMatrix"..y..x, "_lt", posX, posY, initialIconSize, initialIconSize)
						----_this.text = "F"..(_currentIconNum+1);
						--_this.background="Texture/kidui/CCS/btn_CCS_CF_CartoonSlot_Empty.png";
						
						_this = ParaUI.CreateUIObject("button", "btnMatrixBG"..y..x, "_lt", posX, posY, initialBGSize, initialBGSize)
						_this.background="Texture/kidui/CCS/btn_BCS_Icon_Slot_empty.png";
						_parent:AddChild(_this);
						_currentIconNum = _currentIconNum + 1;
					end
				end
			end
			
			
		end -- if(_this:IsValid()) then
		
	end -- if(CCS_UI_Model.currentPage < (CCS_UI_Model.totalPage-1) ) then
	
end -- function CCS_UI_Model.PageRight()

function CCS_UI_Model.OnIconMatrixClick(num)
	--_guihelper.MessageBox("IconClick:"..num);
	
	if(application_name == "3DMapSystem" and State_3DMapSystem == "MainMenu") then
		NPL.load("(gl)script/kids/3DMapSystemUI/MainMenu.lua");
		Map3DSystem.UI.MainMenu.ChangeCharacterModelByIndex(num);
	end
	
	--local _cont = CommonCtrl.GetControl("kiditembarcontainer");
	--local typeBuf = _cont.ItemType;
	--local pageBuf = _cont.ItemPage;
	--_cont.ItemType = 6;
		--
	--local remain = math.mod(num-1, _cont.ItemPageSize);
	--if(remain == 0) then
		--_cont.ItemPage = num / _cont.ItemPageSize;
	--else
		--_cont.ItemPage = (num-remain) / _cont.ItemPageSize;
	--end
	--local index = num - _cont.ItemPage * _cont.ItemPageSize -1;
		--
		--
--NPL.load("(gl)script/kids/ui/itembar_container.lua");
	--CommonCtrl.CKidItemsContainer.OnItemClick(index);
	--
	--
	--local path = kids_db.items[_cont.ItemType][_cont.ItemPage*_cont.ItemPageSize+index+1].IconFilePath;
	--_guihelper.MessageBox(path.."\r\n");
	--
	--_cont.ItemType = typeBuf;
	--_cont.ItemPage = pageBuf;
end