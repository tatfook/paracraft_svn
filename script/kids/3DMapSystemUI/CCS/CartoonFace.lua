--[[
Title: character customization system UI plug-in for 3D Map System
Author(s): WangTian
Date: 2007/10/29
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/CCS/CartoonFace.lua");
local CartoonFace = Map3DSystem.UI.CCS.CartoonFace;
-------------------------------------------------------
]]

local CartoonFace = commonlib.gettable("Map3DSystem.UI.CCS.CartoonFace")

-- create, init and display the cartoon face UI control
--@param parent: ParaUIObject which is the parent container
function CartoonFace.Show(parent)

	local _this,_parent;
	
	_this = ParaUI.GetUIObject("CCS_CartoonFace_container");
	
	if(_this:IsValid() == false) then
		-- CCS_CartoonFace_container
		_this = ParaUI.CreateUIObject("container", "CCS_CartoonFace_container", "_fi", 0, 0, 0, 0);
		--_this.background = "Texture/KeysHelp.png;0 0 0 0";
		_this.background = "";
		if(parent == nil) then
			_this:AttachToRoot();
		else
			parent:AddChild(_this);
		end
		
		_parent = _this;
		
		_this = ParaUI.CreateUIObject("container", "CCS_CartoonFace_IconMatrix_Container", "_lt", 0, 47, 264, 150)
		--_this.background = "Texture/whitedot.png;0 0 0 0";
		_this.background = "";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "btnPageLeft", "_lt", 1, 0, 32, 32)
		--_this.text = "<-";
		_this.animstyle = 11;
		_this.tooltip = "向左翻页";
		_this.background="Texture/3DMapSystem/common/leftarrow.png";
		_this.onclick = ";Map3DSystem.UI.CCS.CartoonFace.PageLeft();";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "btnPageRight", "_lt", 85, 0, 32, 32)
		--_this.text = "->";
		_this.animstyle = 11;
		_this.tooltip = "向右翻页";
		_this.background="Texture/3DMapSystem/common/rightarrow.png";
		_this.onclick = ";Map3DSystem.UI.CCS.CartoonFace.PageRight();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "labelPage", "_lt", 39, 11, 40, 16)
		_this.text = "0/0";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "buttonReset", "_lt", 196, 0, 32, 32)
		--_this.text = "Reset";
		_this.animstyle = 11;
		_this.tooltip = "重置";
		_this.background="Texture/3DMapSystem/common/reset.png";
		_this.onclick = ";Map3DSystem.UI.CCS.CartoonFace.ResetFaceComponent();";
		_parent:AddChild(_this);
		
		
		local faceComponentType = Map3DSystem.UI.CCS.CartoonFaceComponent.GetFaceComponentSection();
		
		CartoonFace.StyleList = 
				Map3DSystem.UI.CCS.DB.GetFaceComponentStyleList(Map3DSystem.UI.CCS.CartoonFaceComponent.Component);
		CartoonFace.IconList = 
				Map3DSystem.UI.CCS.DB.GetFaceComponentIconList(Map3DSystem.UI.CCS.CartoonFaceComponent.Component);
		local nCount = table.getn(CartoonFace.StyleList);
		

		--CartoonFace.totalPage = 5;
		CartoonFace.TotalIcons = nCount;
		CartoonFace.iconsPerPage = 8;
		
		local remain = math.mod(nCount, CartoonFace.iconsPerPage);
		if(remain == 0) then
			CartoonFace.totalPage = nCount / CartoonFace.iconsPerPage;
		else
			CartoonFace.totalPage = (nCount-remain) / CartoonFace.iconsPerPage + 1;
		end
		
		if(nCount == 0) then
			CartoonFace.totalPage = 1;
		end
		
		CartoonFace.currentPage = 1;
		CartoonFace.PageLeft();

		
	end -- if(_this:IsValid() == false) then
	
end -- function CartoonFace.Show()


-- destroy the control
function CartoonFace.OnDestroy()
	ParaUI.Destroy("CCS_CartoonFace_container");
end


-- Page Left
function CartoonFace.PageLeft()

	local _this,_parent;
	
	if(CartoonFace.currentPage > 0) then
	
		CartoonFace.currentPage = CartoonFace.currentPage - 1;
		local _thisCont = ParaUI.GetUIObject("CCS_CartoonFace_container");
		
		_this = _thisCont:GetChild("labelPage");
		_this.text = (CartoonFace.currentPage+1).."/"..CartoonFace.totalPage;
		
		if(_thisCont:IsValid()) then
			local _container = _thisCont:GetChild("CCS_CartoonFace_IconMatrix_Container");
			local _currentIconNum;
			_currentIconNum = (CartoonFace.currentPage)*(CartoonFace.iconsPerPage);
			ParaUI.Destroy("CCS_CartoonFace_IconMatrix_Container");
			
			_this = ParaUI.CreateUIObject("container", "CCS_CartoonFace_IconMatrix_Container", "_lt", 0,37,264,150)
			_this.background="Texture/whitedot.png;0 0 0 0";
			_thisCont:AddChild(_this);
			
			_parent = _this;
			
			local initialTop = 0;
			local initialLeft = 10;
			local initialIconSize = 48;
			local initialMatrixX = 4;
			local initialMatrixY = 2;
			local initialGap = 2;
			local initialBGSize = 57;
			local initialIconOffset = 3;
			local posX, posY;
			
			for y=0, initialMatrixY-1 do
				for x=0, initialMatrixX-1 do
					if(_currentIconNum < CartoonFace.TotalIcons) then
						posX = initialLeft + x * (initialBGSize+initialGap);
						posY = initialTop + y * (initialBGSize+initialGap);
						_this = ParaUI.CreateUIObject("button", "btnMatrixBG"..y..x, "_lt", posX, posY, initialBGSize, initialBGSize)
						_this.background="Texture/kidui/CCS/btn_BCS_Icon_Slot.png";
						_parent:AddChild(_this);
						_this = ParaUI.CreateUIObject("button", "btnMatrix"..y..x, "_lt", posX+initialIconOffset, posY+initialIconOffset, initialIconSize, initialIconSize)
						--_this.text = "F"..(_currentIconNum+1);
						if(CartoonFace.IconList ~= nil) then
							local iconName = CartoonFace.IconList[_currentIconNum+1];
							_this.background = CartoonFace.GetDirectory()..iconName;
						end
						_this.onclick = ";Map3DSystem.UI.CCS.CartoonFace.OnIconMatrixClick("..y..", "..x..");";
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
		
	end -- if(CartoonFace.currentPage > 1) then
	
end -- function CartoonFace.PageLeft()

-- Page Right
function CartoonFace.PageRight()

	local _this,_parent;
		
	if(CartoonFace.currentPage < (CartoonFace.totalPage-1) ) then
	
		CartoonFace.currentPage = CartoonFace.currentPage + 1;
		local _thisCont = ParaUI.GetUIObject("CCS_CartoonFace_container");
		
		_this = _thisCont:GetChild("labelPage");
		_this.text = (CartoonFace.currentPage+1).."/"..CartoonFace.totalPage;
		
		
		if(_thisCont:IsValid()) then
			local _container = _thisCont:GetChild("CCS_CartoonFace_IconMatrix_Container");
			local _currentIconNum;
			_currentIconNum = (CartoonFace.currentPage)*(CartoonFace.iconsPerPage);
			ParaUI.Destroy("CCS_CartoonFace_IconMatrix_Container");
			
			_this = ParaUI.CreateUIObject("container", "CCS_CartoonFace_IconMatrix_Container", "_lt", 0,37,264,150)
			_this.background="Texture/whitedot.png;0 0 0 0";
			_thisCont:AddChild(_this);
			
			_parent = _this;
			
			local initialTop = 0;
			local initialLeft = 10;
			local initialIconSize = 48;
			local initialMatrixX = 4;
			local initialMatrixY = 2;
			local initialGap = 2;
			local initialBGSize = 57;
			local initialIconOffset = 3;
			local posX, posY;
			
			for y=0, initialMatrixY-1 do
				for x=0, initialMatrixX-1 do
					if(_currentIconNum < CartoonFace.TotalIcons) then
						posX = initialLeft + x * (initialBGSize+initialGap);
						posY = initialTop + y * (initialBGSize+initialGap);
						_this = ParaUI.CreateUIObject("button", "btnMatrixBG"..y..x, "_lt", posX, posY, initialBGSize, initialBGSize)
						_this.background="Texture/kidui/CCS/btn_BCS_Icon_Slot.png";
						_parent:AddChild(_this);
						_this = ParaUI.CreateUIObject("button", "btnMatrix"..y..x, "_lt", posX+initialIconOffset, posY+initialIconOffset, initialIconSize, initialIconSize)
						--_this.text = "F"..(_currentIconNum+1);
						if(CartoonFace.IconList ~= nil) then
							local iconName = CartoonFace.IconList[_currentIconNum+1];
							_this.background = CartoonFace.GetDirectory()..iconName;
						end
						_this.onclick = ";Map3DSystem.UI.CCS.CartoonFace.OnIconMatrixClick("..y..", "..x..");";
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
		
	end -- if(CartoonFace.currentPage < (CartoonFace.totalPage-1) ) then
	
end -- function CartoonFace.PageRight()

-- get the face directory according to current face component section
function CartoonFace.GetDirectory()
	if(Map3DSystem.UI.CCS.CartoonFaceComponent.GetFaceComponentSection() == "Wrinkle") then
		return "character/v3/CartoonFace/".."faceDeco".."/";
	elseif(Map3DSystem.UI.CCS.CartoonFaceComponent.GetFaceComponentSection() == "Marks") then
		return "character/v3/CartoonFace/".."Mark".."/";
	else
		return "character/v3/CartoonFace/"..Map3DSystem.UI.CCS.CartoonFaceComponent.GetFaceComponentSection().."/";
	end
end

-- reset face component section
function CartoonFace.ResetFaceComponent()
	Map3DSystem.UI.CCS.CartoonFaceComponent.SetFaceComponent(nil);
end

-- click on cartoon face icon matrix
-- set the cartoon face component according to the click
function CartoonFace.OnIconMatrixClick(x, y)
	local page = CartoonFace.currentPage;
	local iconNum = page*(CartoonFace.iconsPerPage) + x * 4 + y + 1;
	local style = CartoonFace.StyleList[iconNum];
	Map3DSystem.UI.CCS.DB.SetFaceComponent(
			Map3DSystem.UI.CCS.CartoonFaceComponent.Component, 
			Map3DSystem.UI.CCS.DB.CFS_SUB_Style, 
			style, nil);
end
