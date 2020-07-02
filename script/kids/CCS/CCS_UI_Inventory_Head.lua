--[[
Title: Character Customization System inventory for head
Author(s): WangTian
Date: 2007/7/19
Parameters:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/CCS/CCS_UI_Inventory_Head.lua");
CCS_UI_Inventory_Head.Show(_parent);
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/kids/CCS/CCS_db.lua");

NPL.load("(gl)script/kids/CCS/CCS_UI_InventorySlot.lua");

-- Debug purpose
NPL.load("(gl)script/ide/gui_helper.lua");


if(not CCS_UI_Inventory_Head) then CCS_UI_Inventory_Head = {}; end



-- create, init and display the head inventory UI control
--@param parent: ParaUIObject which is the parent container
function CCS_UI_Inventory_Head.Show(parent)
	local _this,_parent;
	
	_this=ParaUI.GetUIObject("CCS_UI_Inventory_Head_container");
	
	if(_this:IsValid() == true) then
		ParaUI.Destroy("CCS_UI_Inventory_Head_container");
	end
	
		-- CCS_UI_Inventory_Head_container
		_this=ParaUI.CreateUIObject("container","CCS_UI_Inventory_Head_container","_fi",0,0,0,0);
		_this.background="Texture/KeysHelp.png;0 0 0 0";
		if(parent == nil) then
			_this:AttachToRoot();
		else
			parent:AddChild(_this);
		end
		
		_parent = _this;
		
		
		_this = ParaUI.CreateUIObject("container", "CCS_Head_IconMatrix_Container", "_lt", 0,47,264,150)
		_this.background="Texture/whitedot.png;0 0 0 0";
		_parent:AddChild(_this);



		_this = ParaUI.CreateUIObject("button", "btnPageLeft", "_lt", 1, 0, 32, 32)
		--_this.text = "<-";
		_this.animstyle = 11;
		_this.tooltip = "向左翻页";
		_this.onclick = ";CCS_UI_Inventory_Head.PageLeft();";
		_this.background="Texture/kidui/CCS/btn_CCS_CF_Page_Left.png";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "btnPageRight", "_lt", 85, 0, 32, 32)
		--_this.text = "->";
		_this.animstyle = 11;
		_this.tooltip = "向右翻页";
		_this.onclick = ";CCS_UI_Inventory_Head.PageRight();";
		_this.background="Texture/kidui/CCS/btn_CCS_CF_Page_Right.png";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "labelPage", "_lt", 39, 11, 40, 16)
		_this.text = "0/0";
		_parent:AddChild(_this);
		
		
		_this = ParaUI.CreateUIObject("button", "btnUnmount", "_lt", 188, 0, 32, 32)
		--_this.text = "Unmount";
		_this.animstyle = 11;
		_this.tooltip = "脱掉装备";
		_this.background="Texture/kidui/CCS/btn_BCS_Reset.png";
		_this.onclick = ";CCS_UI_Inventory_Head.UnmountCurrentInventorySlot();";
		_parent:AddChild(_this);
		

		local slotInventory = CCS_UI_InventorySlot.GetInventorySlot();
		--CCS_UI_Inventory_Head.headItems = CCS_db.GetItemIdListByType(CCS_db.IT_HEAD);
		CCS_UI_Inventory_Head.headItems = CCS_db.GetItemIdListBySlotType(CCS_UI_InventorySlot.Component);
		
		local nCount = table.getn(CCS_UI_Inventory_Head.headItems);


		CCS_UI_Inventory_Head.totalPage = 5;
		CCS_UI_Inventory_Head.totalIcons = nCount;
		CCS_UI_Inventory_Head.iconsPerPage = 8;
		
		local remain = math.mod(nCount, CCS_UI_Inventory_Head.iconsPerPage);
		if(remain == 0) then
			CCS_UI_Inventory_Head.totalPage = nCount / CCS_UI_Inventory_Head.iconsPerPage;
		else
			CCS_UI_Inventory_Head.totalPage = (nCount-remain) / CCS_UI_Inventory_Head.iconsPerPage + 1;
		end
		
		if(nCount == 0) then
			CCS_UI_Inventory_Head.totalPage = 1;
		end
		
		
		CCS_UI_Inventory_Head.currentPage = 1;
		CCS_UI_Inventory_Head.PageLeft();
		

		
	
end -- function CCS_UI_Inventory_Head.Show(parent)


-- destroy the control
function CCS_UI_Inventory_Head.OnDestroy()
	ParaUI.Destroy("CCS_UI_Inventory_Head_container");
end


-- Page Left
function CCS_UI_Inventory_Head.PageLeft()

	local _this,_parent;
	
	if(CCS_UI_Inventory_Head.currentPage > 0) then
	
		CCS_UI_Inventory_Head.currentPage = CCS_UI_Inventory_Head.currentPage - 1;
		local _thisCont = ParaUI.GetUIObject("CCS_UI_Inventory_Head_container");
		
		_this = _thisCont:GetChild("labelPage");
		_this.text = (CCS_UI_Inventory_Head.currentPage+1).."/"..CCS_UI_Inventory_Head.totalPage;
		
		if(_thisCont:IsValid()) then
			local _container = _thisCont:GetChild("CCS_Head_IconMatrix_Container");
			local _currentIconNum;
			_currentIconNum = (CCS_UI_Inventory_Head.currentPage)*(CCS_UI_Inventory_Head.iconsPerPage);
			ParaUI.Destroy("CCS_Head_IconMatrix_Container");
			
			_this = ParaUI.CreateUIObject("container", "CCS_Head_IconMatrix_Container", "_lt", 0,37,264,150)
			_this.background="Texture/whitedot.png;0 0 0 0";
			_thisCont:AddChild(_this);
			
			_parent = _this;
			
			local initialTop = 0;
			local initialLeft = 0;
			local initialIconSize = 48;
			local initialMatrixX = 4;
			local initialMatrixY = 2;
			local initialGap = 2;
			local initialBGSize = 57;
			local initialIconOffset = 3;
			local posX, posY;
			
			for y=0, initialMatrixY-1 do
				for x=0, initialMatrixX-1 do
					if(_currentIconNum < CCS_UI_Inventory_Head.totalIcons) then
						posX = initialLeft + x * (initialBGSize+initialGap);
						posY = initialTop + y * (initialBGSize+initialGap);
						_this = ParaUI.CreateUIObject("button", "btnMatrixBG"..y..x, "_lt", posX, posY, initialBGSize, initialBGSize)
						_this.background="Texture/kidui/CCS/btn_BCS_Icon_Slot.png";
						_parent:AddChild(_this);
						_this = ParaUI.CreateUIObject("button", "btnMatrix"..y..x, "_lt", posX+initialIconOffset, posY+initialIconOffset, initialIconSize, initialIconSize)
						--_this.text = "F"..(_currentIconNum+1);
						_this.animstyle = 11;
						_this.onclick = ";CCS_UI_Inventory_Head.OnIconMatrixClick"..y..x.."();";
						_parent:AddChild(_this);
						_currentIconNum = _currentIconNum + 1;
					else
						posX = initialLeft + x * (initialBGSize+initialGap);
						posY = initialTop + y * (initialBGSize+initialGap);
						_this = ParaUI.CreateUIObject("button", "btnMatrixBG"..y..x, "_lt", posX, posY, initialBGSize, initialBGSize)
						_this.background="Texture/kidui/CCS/btn_BCS_Icon_Slot_empty.png";
						_parent:AddChild(_this);
						_currentIconNum = _currentIconNum + 1;
					end
				end
			end
			
			
		end -- if(_this:IsValid()) then
		
	end -- if(CCS_UI_Inventory_Head.currentPage > 1) then
	
end -- function CCS_UI_Inventory_Head.PageLeft()

-- Page Right
function CCS_UI_Inventory_Head.PageRight()

	local _this,_parent;
		
	if(CCS_UI_Inventory_Head.currentPage < (CCS_UI_Inventory_Head.totalPage-1) ) then
	
		CCS_UI_Inventory_Head.currentPage = CCS_UI_Inventory_Head.currentPage + 1;
		local _thisCont = ParaUI.GetUIObject("CCS_UI_Inventory_Head_container");
		
		_this = _thisCont:GetChild("labelPage");
		_this.text = (CCS_UI_Inventory_Head.currentPage+1).."/"..CCS_UI_Inventory_Head.totalPage;
		
		
		if(_thisCont:IsValid()) then
			local _container = _thisCont:GetChild("CCS_Head_IconMatrix_Container");
			local _currentIconNum;
			_currentIconNum = (CCS_UI_Inventory_Head.currentPage)*(CCS_UI_Inventory_Head.iconsPerPage);
			ParaUI.Destroy("CCS_Head_IconMatrix_Container");
			
			_this = ParaUI.CreateUIObject("container", "CCS_Head_IconMatrix_Container", "_lt", 0,37,264,150)
			_this.background="Texture/whitedot.png;0 0 0 0";
			_thisCont:AddChild(_this);
			
			_parent = _this;
			
			local initialTop = 0;
			local initialLeft = 0;
			local initialIconSize = 48;
			local initialMatrixX = 4;
			local initialMatrixY = 2;
			local initialGap = 2;
			local initialBGSize = 57;
			local initialIconOffset = 3;
			local posX, posY;
			
			for y=0, initialMatrixY-1 do
				for x=0, initialMatrixX-1 do
					if(_currentIconNum < CCS_UI_Inventory_Head.totalIcons) then
						posX = initialLeft + x * (initialBGSize+initialGap);
						posY = initialTop + y * (initialBGSize+initialGap);
						_this = ParaUI.CreateUIObject("button", "btnMatrixBG"..y..x, "_lt", posX, posY, initialBGSize, initialBGSize)
						_this.background="Texture/kidui/CCS/btn_BCS_Icon_Slot.png";
						_parent:AddChild(_this);
						_this = ParaUI.CreateUIObject("button", "btnMatrix"..y..x, "_lt", posX+initialIconOffset, posY+initialIconOffset, initialIconSize, initialIconSize)
						--_this.text = "F"..(_currentIconNum+1);
						_this.animstyle = 11;
						_this.onclick = ";CCS_UI_Inventory_Head.OnIconMatrixClick"..y..x.."();";
						_parent:AddChild(_this);
						_currentIconNum = _currentIconNum + 1;
					else
						posX = initialLeft + x * (initialBGSize+initialGap);
						posY = initialTop + y * (initialBGSize+initialGap);
						_this = ParaUI.CreateUIObject("button", "btnMatrixBG"..y..x, "_lt", posX, posY, initialBGSize, initialBGSize)
						_this.background="Texture/kidui/CCS/btn_BCS_Icon_Slot_empty.png";
						_parent:AddChild(_this);
						_currentIconNum = _currentIconNum + 1;
					end
				end
			end
			
			
		end -- if(_this:IsValid()) then
		
	end -- if(CCS_UI_Inventory_Head.currentPage < (CCS_UI_Inventory_Head.totalPage-1) ) then
	
end -- function CCS_UI_Inventory_Head.PageRight()

	
	
function CCS_UI_Inventory_Head.SetInventorySlot_Head(index)
	local player, playerChar = CCS_db.GetPlayerChar();
	if(playerChar~=nil) then
		index = CCS_UI_Inventory_Head.headItems[index+1];
		playerChar:SetCharacterSlot(CCS_UI_InventorySlot.Component, index);
	end
end

function CCS_UI_Inventory_Head.UnmountCurrentInventorySlot()
	local player, playerChar = CCS_db.GetPlayerChar();
	if(playerChar~=nil) then
		playerChar:SetCharacterSlot(CCS_UI_InventorySlot.Component, 0);
	end
end


-- function[24]: icon matrix onclick function
function CCS_UI_Inventory_Head.OnIconMatrixClick00()
	local page = CCS_UI_Inventory_Head.currentPage;
	local iconNum = page*(CCS_UI_Inventory_Head.iconsPerPage);
	CCS_UI_Inventory_Head.SetInventorySlot_Head(iconNum);
end

function CCS_UI_Inventory_Head.OnIconMatrixClick01()
	local page = CCS_UI_Inventory_Head.currentPage;
	local iconNum = page*(CCS_UI_Inventory_Head.iconsPerPage)+1;
	CCS_UI_Inventory_Head.SetInventorySlot_Head(iconNum);
end

function CCS_UI_Inventory_Head.OnIconMatrixClick02()
	local page = CCS_UI_Inventory_Head.currentPage;
	local iconNum = page*(CCS_UI_Inventory_Head.iconsPerPage)+2;
	CCS_UI_Inventory_Head.SetInventorySlot_Head(iconNum);
end

function CCS_UI_Inventory_Head.OnIconMatrixClick03()
	local page = CCS_UI_Inventory_Head.currentPage;
	local iconNum = page*(CCS_UI_Inventory_Head.iconsPerPage)+3;
	CCS_UI_Inventory_Head.SetInventorySlot_Head(iconNum);
end

--function CCS_UI_Inventory_Head.OnIconMatrixClick04()
	--local page = CCS_UI_Inventory_Head.currentPage;
	--local iconNum = page*(CCS_UI_Inventory_Head.iconsPerPage)+4;
	--CCS_UI_Inventory_Head.SetInventorySlot_Head(iconNum);
--end
--
--function CCS_UI_Inventory_Head.OnIconMatrixClick05()
	--local page = CCS_UI_Inventory_Head.currentPage;
	--local iconNum = page*(CCS_UI_Inventory_Head.iconsPerPage)+5;
	--CCS_UI_Inventory_Head.SetInventorySlot_Head(iconNum);
--end
--
--function CCS_UI_Inventory_Head.OnIconMatrixClick06()
	--local page = CCS_UI_Inventory_Head.currentPage;
	--local iconNum = page*(CCS_UI_Inventory_Head.iconsPerPage)+6;
	--CCS_UI_Inventory_Head.SetInventorySlot_Head(iconNum);
--end
--
--function CCS_UI_Inventory_Head.OnIconMatrixClick07()
	--local page = CCS_UI_Inventory_Head.currentPage;
	--local iconNum = page*(CCS_UI_Inventory_Head.iconsPerPage)+7;
	--CCS_UI_Inventory_Head.SetInventorySlot_Head(iconNum);
--end

function CCS_UI_Inventory_Head.OnIconMatrixClick10()
	local page = CCS_UI_Inventory_Head.currentPage;
	local iconNum = page*(CCS_UI_Inventory_Head.iconsPerPage)+4;
	CCS_UI_Inventory_Head.SetInventorySlot_Head(iconNum);
end

function CCS_UI_Inventory_Head.OnIconMatrixClick11()
	local page = CCS_UI_Inventory_Head.currentPage;
	local iconNum = page*(CCS_UI_Inventory_Head.iconsPerPage)+5;
	CCS_UI_Inventory_Head.SetInventorySlot_Head(iconNum);
end

function CCS_UI_Inventory_Head.OnIconMatrixClick12()
	local page = CCS_UI_Inventory_Head.currentPage;
	local iconNum = page*(CCS_UI_Inventory_Head.iconsPerPage)+6;
	CCS_UI_Inventory_Head.SetInventorySlot_Head(iconNum);
end

function CCS_UI_Inventory_Head.OnIconMatrixClick13()
	local page = CCS_UI_Inventory_Head.currentPage;
	local iconNum = page*(CCS_UI_Inventory_Head.iconsPerPage)+7;
	CCS_UI_Inventory_Head.SetInventorySlot_Head(iconNum);
end

--function CCS_UI_Inventory_Head.OnIconMatrixClick14()
	--local page = CCS_UI_Inventory_Head.currentPage;
	--local iconNum = page*(CCS_UI_Inventory_Head.iconsPerPage)+9;
	--CCS_UI_Inventory_Head.SetInventorySlot_Head(iconNum);
--end
--
--function CCS_UI_Inventory_Head.OnIconMatrixClick15()
	--local page = CCS_UI_Inventory_Head.currentPage;
	--local iconNum = page*(CCS_UI_Inventory_Head.iconsPerPage)+13;
	--CCS_UI_Inventory_Head.SetInventorySlot_Head(iconNum);
--end
--
--function CCS_UI_Inventory_Head.OnIconMatrixClick16()
	--local page = CCS_UI_Inventory_Head.currentPage;
	--local iconNum = page*(CCS_UI_Inventory_Head.iconsPerPage)+14;
	--CCS_UI_Inventory_Head.SetInventorySlot_Head(iconNum);
--end
--
--function CCS_UI_Inventory_Head.OnIconMatrixClick17()
	--local page = CCS_UI_Inventory_Head.currentPage;
	--local iconNum = page*(CCS_UI_Inventory_Head.iconsPerPage)+15;
	--CCS_UI_Inventory_Head.SetInventorySlot_Head(iconNum);
--end
--
--function CCS_UI_Inventory_Head.OnIconMatrixClick20()
	--local page = CCS_UI_Inventory_Head.currentPage;
	--local iconNum = page*(CCS_UI_Inventory_Head.iconsPerPage)+16;
	--CCS_UI_Inventory_Head.SetInventorySlot_Head(iconNum);
--end
--
--function CCS_UI_Inventory_Head.OnIconMatrixClick21()
	--local page = CCS_UI_Inventory_Head.currentPage;
	--local iconNum = page*(CCS_UI_Inventory_Head.iconsPerPage)+17;
	--CCS_UI_Inventory_Head.SetInventorySlot_Head(iconNum);
--end
--
--function CCS_UI_Inventory_Head.OnIconMatrixClick22()
	--local page = CCS_UI_Inventory_Head.currentPage;
	--local iconNum = page*(CCS_UI_Inventory_Head.iconsPerPage)+18;
	--CCS_UI_Inventory_Head.SetInventorySlot_Head(iconNum);
--end
--
--function CCS_UI_Inventory_Head.OnIconMatrixClick23()
	--local page = CCS_UI_Inventory_Head.currentPage;
	--local iconNum = page*(CCS_UI_Inventory_Head.iconsPerPage)+19;
	--CCS_UI_Inventory_Head.SetInventorySlot_Head(iconNum);
--end
--
--function CCS_UI_Inventory_Head.OnIconMatrixClick24()
	--local page = CCS_UI_Inventory_Head.currentPage;
	--local iconNum = page*(CCS_UI_Inventory_Head.iconsPerPage)+20;
	--CCS_UI_Inventory_Head.SetInventorySlot_Head(iconNum);
--end
--
--function CCS_UI_Inventory_Head.OnIconMatrixClick25()
	--local page = CCS_UI_Inventory_Head.currentPage;
	--local iconNum = page*(CCS_UI_Inventory_Head.iconsPerPage)+21;
	--CCS_UI_Inventory_Head.SetInventorySlot_Head(iconNum);
--end
--
--function CCS_UI_Inventory_Head.OnIconMatrixClick26()
	--local page = CCS_UI_Inventory_Head.currentPage;
	--local iconNum = page*(CCS_UI_Inventory_Head.iconsPerPage)+22;
	--CCS_UI_Inventory_Head.SetInventorySlot_Head(iconNum);
--end
--
--function CCS_UI_Inventory_Head.OnIconMatrixClick27()
	--local page = CCS_UI_Inventory_Head.currentPage;
	--local iconNum = page*(CCS_UI_Inventory_Head.iconsPerPage)+23;
	--CCS_UI_Inventory_Head.SetInventorySlot_Head(iconNum);
--end