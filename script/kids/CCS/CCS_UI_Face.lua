--[[
Title: character customization system UI plug-in for face
Author(s): WangTian
Date: 2007/7/18
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/CCS/CCS_UI_Face.lua");
CCS_UI_Face.Show(_parent);
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/kids/CCS/CCS_db.lua");

NPL.load("(gl)script/kids/CCS/CCS_UI_FaceComponent.lua");

-- Debug purpose
NPL.load("(gl)script/ide/gui_helper.lua");

if(not CCS_UI_Face) then CCS_UI_Face = {}; end


-- create, init and display the face UI control
--@param parent: ParaUIObject which is the parent container
function CCS_UI_Face.Show(parent)
	local _this,_parent;
	
	_this=ParaUI.GetUIObject("CCS_UI_Face_container");
	
	if(_this:IsValid() == false) then
		-- CCS_UI_Face_container
		_this=ParaUI.CreateUIObject("container","CCS_UI_Face_container","_fi",0,0,0,0);
		_this.background="Texture/KeysHelp.png;0 0 0 0";
		if(parent == nil) then
			_this:AttachToRoot();
		else
			parent:AddChild(_this);
		end
		
		_parent = _this;
		
		
		_this = ParaUI.CreateUIObject("container", "CCS_Face_IconMatrix_Container", "_lt", 0,47,264,150)
		_this.background="Texture/whitedot.png;0 0 0 0";
		_parent:AddChild(_this);



		_this = ParaUI.CreateUIObject("button", "btnPageLeft", "_lt", 1, 0, 32, 32)
		--_this.text = "<-";
		_this.animstyle = 11;
		_this.tooltip = "向左翻页";
		_this.onclick = ";CCS_UI_Face.PageLeft();";
		_this.background="Texture/kidui/CCS/btn_CCS_CF_Page_Left.png";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "btnPageRight", "_lt", 85, 0, 32, 32)
		--_this.text = "->";
		_this.animstyle = 11;
		_this.tooltip = "向右翻页";
		_this.background="Texture/kidui/CCS/btn_CCS_CF_Page_Right.png";
		_this.onclick = ";CCS_UI_Face.PageRight();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "labelPage", "_lt", 39, 11, 40, 16)
		_this.text = "0/0";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "buttonReset", "_lt", 196, 0, 32, 32)
		--_this.text = "Reset";
		_this.animstyle = 11;
		_this.tooltip = "重置";
		_this.background="Texture/kidui/CCS/btn_CCS_CF_Reset.png";
		_this.onclick = ";CCS_UI_Face.ResetFaceComponent();";
		_parent:AddChild(_this);
		
		
		local faceSectionType = CCS_UI_FaceComponent.GetFaceSection();
		
		CCS_UI_Face.StyleList = CCS_db.GetFaceComponentStyleList(CCS_UI_FaceComponent.Component);
		CCS_UI_Face.IconList = CCS_db.GetFaceComponentIconList(CCS_UI_FaceComponent.Component);
		local nCount = table.getn(CCS_UI_Face.StyleList);
		
		--_guihelper.MessageBox(""..temp);


		--CCS_UI_Face.totalPage = 5;
		CCS_UI_Face.totalIcons = nCount;
		CCS_UI_Face.iconsPerPage = 8;
		
		local remain = math.mod(nCount, CCS_UI_Face.iconsPerPage);
		if(remain == 0) then
			CCS_UI_Face.totalPage = nCount / CCS_UI_Face.iconsPerPage;
		else
			CCS_UI_Face.totalPage = (nCount-remain) / CCS_UI_Face.iconsPerPage + 1;
		end
		
		if(nCount == 0) then
			CCS_UI_Face.totalPage = 1;
		end
		
		CCS_UI_Face.currentPage = 1;
		CCS_UI_Face.PageLeft();

		
	end -- if(_this:IsValid() == false) then
	
end -- function CCS_UI_Face.Show(parent)


-- destroy the control
function CCS_UI_Face.OnDestroy()
	ParaUI.Destroy("CCS_UI_Face_container");
end


-- Page Left
function CCS_UI_Face.PageLeft()

	local _this,_parent;
	
	if(CCS_UI_Face.currentPage > 0) then
	
		CCS_UI_Face.currentPage = CCS_UI_Face.currentPage - 1;
		local _thisCont = ParaUI.GetUIObject("CCS_UI_Face_container");
		
		_this = _thisCont:GetChild("labelPage");
		_this.text = (CCS_UI_Face.currentPage+1).."/"..CCS_UI_Face.totalPage;
		
		if(_thisCont:IsValid()) then
			local _container = _thisCont:GetChild("CCS_Face_IconMatrix_Container");
			local _currentIconNum;
			_currentIconNum = (CCS_UI_Face.currentPage)*(CCS_UI_Face.iconsPerPage);
			ParaUI.Destroy("CCS_Face_IconMatrix_Container");
			
			_this = ParaUI.CreateUIObject("container", "CCS_Face_IconMatrix_Container", "_lt", 0,37,264,150)
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
					if(_currentIconNum < CCS_UI_Face.totalIcons) then
						posX = initialLeft + x * (initialBGSize+initialGap);
						posY = initialTop + y * (initialBGSize+initialGap);
						_this = ParaUI.CreateUIObject("button", "btnMatrixBG"..y..x, "_lt", posX, posY, initialBGSize, initialBGSize)
						_this.background="Texture/kidui/CCS/btn_BCS_Icon_Slot.png";
						_parent:AddChild(_this);
						_this = ParaUI.CreateUIObject("button", "btnMatrix"..y..x, "_lt", posX+initialIconOffset, posY+initialIconOffset, initialIconSize, initialIconSize)
						--_this.text = "F"..(_currentIconNum+1);
						if(CCS_UI_Face.IconList ~= nil) then
							local iconName = CCS_UI_Face.IconList[_currentIconNum+1];
							_this.background = CCS_UI_Face.GetDirectory()..iconName;
						end
						_this.onclick = ";CCS_UI_Face.OnIconMatrixClick"..y..x.."();";
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
		
	end -- if(CCS_UI_Face.currentPage > 1) then
	
end -- function CCS_UI_Face.PageLeft()

-- Page Right
function CCS_UI_Face.PageRight()

	local _this,_parent;
		
	if(CCS_UI_Face.currentPage < (CCS_UI_Face.totalPage-1) ) then
	
		CCS_UI_Face.currentPage = CCS_UI_Face.currentPage + 1;
		local _thisCont = ParaUI.GetUIObject("CCS_UI_Face_container");
		
		_this = _thisCont:GetChild("labelPage");
		_this.text = (CCS_UI_Face.currentPage+1).."/"..CCS_UI_Face.totalPage;
		
		
		if(_thisCont:IsValid()) then
			local _container = _thisCont:GetChild("CCS_Face_IconMatrix_Container");
			local _currentIconNum;
			_currentIconNum = (CCS_UI_Face.currentPage)*(CCS_UI_Face.iconsPerPage);
			ParaUI.Destroy("CCS_Face_IconMatrix_Container");
			
			_this = ParaUI.CreateUIObject("container", "CCS_Face_IconMatrix_Container", "_lt", 0,37,264,150)
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
					if(_currentIconNum < CCS_UI_Face.totalIcons) then
						posX = initialLeft + x * (initialBGSize+initialGap);
						posY = initialTop + y * (initialBGSize+initialGap);
						_this = ParaUI.CreateUIObject("button", "btnMatrixBG"..y..x, "_lt", posX, posY, initialBGSize, initialBGSize)
						_this.background="Texture/kidui/CCS/btn_BCS_Icon_Slot.png";
						_parent:AddChild(_this);
						_this = ParaUI.CreateUIObject("button", "btnMatrix"..y..x, "_lt", posX+initialIconOffset, posY+initialIconOffset, initialIconSize, initialIconSize)
						--_this.text = "F"..(_currentIconNum+1);
						if(CCS_UI_Face.IconList ~= nil) then
							local iconName = CCS_UI_Face.IconList[_currentIconNum+1];
							_this.background = CCS_UI_Face.GetDirectory()..iconName;
						end
						_this.onclick = ";CCS_UI_Face.OnIconMatrixClick"..y..x.."();";
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
		
	end -- if(CCS_UI_Face.currentPage < (CCS_UI_Face.totalPage-1) ) then
	
end -- function CCS_UI_Face.PageRight()

function CCS_UI_Face.GetDirectory()
	if( (CCS_UI_FaceComponent.GetFaceSection() == "Wrinkle") or 
		(CCS_UI_FaceComponent.GetFaceSection() == "Marks") ) then
		return "character/v3/CartoonFace/".."faceDeco".."/";
	else
		return "character/v3/CartoonFace/"..CCS_UI_FaceComponent.GetFaceSection().."/";
	end
end

function CCS_UI_Face.ResetFaceComponent()
	CCS_UI_FaceComponent.SetFaceComponent(nil);
end


-- function[24]: icon matrix onclick function
function CCS_UI_Face.OnIconMatrixClick00()
	local page = CCS_UI_Face.currentPage;
	local iconNum = page*(CCS_UI_Face.iconsPerPage)+1;
	local style = CCS_UI_Face.StyleList[iconNum];
	CCS_db.SetFaceComponent(CCS_UI_FaceComponent.Component, CCS_db.CFS_SUB_Style, style, nil);
end

function CCS_UI_Face.OnIconMatrixClick01()
	local page = CCS_UI_Face.currentPage;
	local iconNum = page*(CCS_UI_Face.iconsPerPage)+2;
	local style = CCS_UI_Face.StyleList[iconNum]
	CCS_db.SetFaceComponent(CCS_UI_FaceComponent.Component, CCS_db.CFS_SUB_Style, style, nil);
end

function CCS_UI_Face.OnIconMatrixClick02()
	local page = CCS_UI_Face.currentPage;
	local iconNum = page*(CCS_UI_Face.iconsPerPage) + 3;
	local style = CCS_UI_Face.StyleList[iconNum]
	CCS_db.SetFaceComponent(CCS_UI_FaceComponent.Component, CCS_db.CFS_SUB_Style, style, nil);
end

function CCS_UI_Face.OnIconMatrixClick03()
	local page = CCS_UI_Face.currentPage;
	local iconNum = page*(CCS_UI_Face.iconsPerPage) + 4;
	local style = CCS_UI_Face.StyleList[iconNum]
	CCS_db.SetFaceComponent(CCS_UI_FaceComponent.Component, CCS_db.CFS_SUB_Style, style, nil);
end

--function CCS_UI_Face.OnIconMatrixClick04()
	--local page = CCS_UI_Face.currentPage;
	--local iconNum = page*(CCS_UI_Face.iconsPerPage) + 5;
	--local style = CCS_UI_Face.StyleList[iconNum]
	--CCS_db.SetFaceComponent(CCS_UI_FaceComponent.Component, CCS_db.CFS_SUB_Style, style, nil);
--end
--
--function CCS_UI_Face.OnIconMatrixClick05()
	--local page = CCS_UI_Face.currentPage;
	--local iconNum = page*(CCS_UI_Face.iconsPerPage) + 6;
	--local style = CCS_UI_Face.StyleList[iconNum]
	--CCS_db.SetFaceComponent(CCS_UI_FaceComponent.Component, CCS_db.CFS_SUB_Style, style, nil);
--end
--
--function CCS_UI_Face.OnIconMatrixClick06()
	--local page = CCS_UI_Face.currentPage;
	--local iconNum = page*(CCS_UI_Face.iconsPerPage) + 7;
	--local style = CCS_UI_Face.StyleList[iconNum]
	--CCS_db.SetFaceComponent(CCS_UI_FaceComponent.Component, CCS_db.CFS_SUB_Style, style, nil);
--end
--
--function CCS_UI_Face.OnIconMatrixClick07()
	--local page = CCS_UI_Face.currentPage;
	--local iconNum = page*(CCS_UI_Face.iconsPerPage) + 8;
	--local style = CCS_UI_Face.StyleList[iconNum]
	--CCS_db.SetFaceComponent(CCS_UI_FaceComponent.Component, CCS_db.CFS_SUB_Style, style, nil);
--end

function CCS_UI_Face.OnIconMatrixClick10()
	local page = CCS_UI_Face.currentPage;
	local iconNum = page*(CCS_UI_Face.iconsPerPage) + 5;
	local style = CCS_UI_Face.StyleList[iconNum]
	CCS_db.SetFaceComponent(CCS_UI_FaceComponent.Component, CCS_db.CFS_SUB_Style, style, nil);
end

function CCS_UI_Face.OnIconMatrixClick11()
	local page = CCS_UI_Face.currentPage;
	local iconNum = page*(CCS_UI_Face.iconsPerPage) + 6;
	local style = CCS_UI_Face.StyleList[iconNum]
	CCS_db.SetFaceComponent(CCS_UI_FaceComponent.Component, CCS_db.CFS_SUB_Style, style, nil);
end

function CCS_UI_Face.OnIconMatrixClick12()
	local page = CCS_UI_Face.currentPage;
	local iconNum = page*(CCS_UI_Face.iconsPerPage) + 7;
	local style = CCS_UI_Face.StyleList[iconNum]
	CCS_db.SetFaceComponent(CCS_UI_FaceComponent.Component, CCS_db.CFS_SUB_Style, style, nil);
end

function CCS_UI_Face.OnIconMatrixClick13()
	local page = CCS_UI_Face.currentPage;
	local iconNum = page*(CCS_UI_Face.iconsPerPage) + 8;
	local style = CCS_UI_Face.StyleList[iconNum]
	CCS_db.SetFaceComponent(CCS_UI_FaceComponent.Component, CCS_db.CFS_SUB_Style, style, nil);
end

--function CCS_UI_Face.OnIconMatrixClick14()
	--local page = CCS_UI_Face.currentPage;
	--local iconNum = page*(CCS_UI_Face.iconsPerPage) + 10;
	--local style = CCS_UI_Face.StyleList[iconNum]
	--CCS_db.SetFaceComponent(CCS_UI_FaceComponent.Component, CCS_db.CFS_SUB_Style, style, nil);
--end
--
--function CCS_UI_Face.OnIconMatrixClick15()
	--local page = CCS_UI_Face.currentPage;
	--local iconNum = page*(CCS_UI_Face.iconsPerPage) + 14;
	--local style = CCS_UI_Face.StyleList[iconNum]
	--CCS_db.SetFaceComponent(CCS_UI_FaceComponent.Component, CCS_db.CFS_SUB_Style, style, nil);
--end
--
--function CCS_UI_Face.OnIconMatrixClick16()
	--local page = CCS_UI_Face.currentPage;
	--local iconNum = page*(CCS_UI_Face.iconsPerPage) + 15;
	--local style = CCS_UI_Face.StyleList[iconNum]
	--CCS_db.SetFaceComponent(CCS_UI_FaceComponent.Component, CCS_db.CFS_SUB_Style, style, nil);
--end
--
--function CCS_UI_Face.OnIconMatrixClick17()
	--local page = CCS_UI_Face.currentPage;
	--local iconNum = page*(CCS_UI_Face.iconsPerPage) + 16;
	--local style = CCS_UI_Face.StyleList[iconNum]
	--CCS_db.SetFaceComponent(CCS_UI_FaceComponent.Component, CCS_db.CFS_SUB_Style, style, nil);
--end
--
--function CCS_UI_Face.OnIconMatrixClick20()
	--local page = CCS_UI_Face.currentPage;
	--local iconNum = page*(CCS_UI_Face.iconsPerPage) + 17;
	--local style = CCS_UI_Face.StyleList[iconNum]
	--CCS_db.SetFaceComponent(CCS_UI_FaceComponent.Component, CCS_db.CFS_SUB_Style, style, nil);
--end
--
--function CCS_UI_Face.OnIconMatrixClick21()
	--local page = CCS_UI_Face.currentPage;
	--local iconNum = page*(CCS_UI_Face.iconsPerPage) + 18;
	--local style = CCS_UI_Face.StyleList[iconNum]
	--CCS_db.SetFaceComponent(CCS_UI_FaceComponent.Component, CCS_db.CFS_SUB_Style, style, nil);
--end
--
--function CCS_UI_Face.OnIconMatrixClick22()
	--local page = CCS_UI_Face.currentPage;
	--local iconNum = page*(CCS_UI_Face.iconsPerPage) + 19;
	--local style = CCS_UI_Face.StyleList[iconNum]
	--CCS_db.SetFaceComponent(CCS_UI_FaceComponent.Component, CCS_db.CFS_SUB_Style, style, nil);
--end
--
--function CCS_UI_Face.OnIconMatrixClick23()
	--local page = CCS_UI_Face.currentPage;
	--local iconNum = page*(CCS_UI_Face.iconsPerPage) + 20;
	--local style = CCS_UI_Face.StyleList[iconNum]
	--CCS_db.SetFaceComponent(CCS_UI_FaceComponent.Component, CCS_db.CFS_SUB_Style, style, nil);
--end
--
--function CCS_UI_Face.OnIconMatrixClick24()
	--local page = CCS_UI_Face.currentPage;
	--local iconNum = page*(CCS_UI_Face.iconsPerPage) + 21;
	--local style = CCS_UI_Face.StyleList[iconNum]
	--CCS_db.SetFaceComponent(CCS_UI_FaceComponent.Component, CCS_db.CFS_SUB_Style, style, nil);
--end
--
--function CCS_UI_Face.OnIconMatrixClick25()
	--local page = CCS_UI_Face.currentPage;
	--local iconNum = page*(CCS_UI_Face.iconsPerPage) + 22;
	--local style = CCS_UI_Face.StyleList[iconNum]
	--CCS_db.SetFaceComponent(CCS_UI_FaceComponent.Component, CCS_db.CFS_SUB_Style, style, nil);
--end
--
--function CCS_UI_Face.OnIconMatrixClick26()
	--local page = CCS_UI_Face.currentPage;
	--local iconNum = page*(CCS_UI_Face.iconsPerPage) + 23;
	--local style = CCS_UI_Face.StyleList[iconNum]
	--CCS_db.SetFaceComponent(CCS_UI_FaceComponent.Component, CCS_db.CFS_SUB_Style, style, nil);
--end
--
--function CCS_UI_Face.OnIconMatrixClick27()
	--local page = CCS_UI_Face.currentPage;
	--local iconNum = page*(CCS_UI_Face.iconsPerPage) + 24;
	--local style = CCS_UI_Face.StyleList[iconNum]
	--CCS_db.SetFaceComponent(CCS_UI_FaceComponent.Component, CCS_db.CFS_SUB_Style, style, nil);
--end