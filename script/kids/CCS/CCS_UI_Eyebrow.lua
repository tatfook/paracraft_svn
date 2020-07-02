--[[
Title: character customization system UI plug-in for eyebrow
Author(s): WangTian
Date: 2007/7/9
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/CCS/CCS_UI_Eyebrow.lua");
CCS_UI_Eyebrow.Show(_parent);
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/kids/CCS/CCS_db.lua");

-- Debug purpose
NPL.load("(gl)script/ide/gui_helper.lua");

if(not CCS_UI_Eyebrow) then CCS_UI_Eyebrow = {}; end

--@param section: this is solely for debugging purposes. to make this class universal to all face component sections
CCS_UI_Eyebrow.Section = CCS_db.CFS_EYEBROW;

-- create, init and display the eyebrow UI control
--@param parent: ParaUIObject which is the parent container
function CCS_UI_Eyebrow.Show(parent)
	local _this,_parent;
	
	_this=ParaUI.GetUIObject("CCS_UI_Eyebrow_cont");
	
	if(_this:IsValid() == false) then
		-- CCS_UI_Eyebrow_cont_cont
		_this=ParaUI.CreateUIObject("container","CCS_UI_Eyebrow_cont","_fi",0,0,0,0);
		_this.background="Texture/whitedot.png;0 0 0 0";
		if(parent == nil) then
			_this:AttachToRoot();
		else
			parent:AddChild(_this);
		end
		
		_parent = _this;
		
		
		_this = ParaUI.CreateUIObject("container", "EyeBrow_Icon_Container", "_lt", 0,47,200,300)
		_this.background="Texture/whitedot.png;0 0 0 0";
		_parent:AddChild(_this);


		_this = ParaUI.CreateUIObject("button", "btnUp00", "_lt", 206, 68, 39, 36)
		_this.text = "原色";
		_this.onclick = ";CCS_UI_Eyebrow.SetFaceComponent(CCS_db.CFS_SUB_Color, _guihelper.RGBA_TO_DWORD(255,255,255));";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnUp01", "_lt", 251, 68, 39, 36)
		_this.text = "红";
		_this.onclick = ";CCS_UI_Eyebrow.SetFaceComponent(CCS_db.CFS_SUB_Color, _guihelper.RGBA_TO_DWORD(255,0,0));";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnUp02", "_lt", 296, 68, 39, 36)
		_this.text = "绿";
		_this.onclick = ";CCS_UI_Eyebrow.SetFaceComponent(CCS_db.CFS_SUB_Color, _guihelper.RGBA_TO_DWORD(0,255,0));";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnUp03", "_lt", 341, 68, 39, 36)
		_this.text = "蓝";
		_this.onclick = ";CCS_UI_Eyebrow.SetFaceComponent(CCS_db.CFS_SUB_Color, _guihelper.RGBA_TO_DWORD(0,0,255));";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnUp10", "_lt", 206, 110, 39, 36)
		_this.text = "样式";
		_this.onclick = ";CCS_UI_Eyebrow.SetFaceComponent(CCS_db.CFS_SUB_Style, nil);";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnUp11", "_lt", 251, 110, 39, 36)
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnUp12", "_lt", 296, 110, 39, 36)
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "btnUp13", "_lt", 341, 110, 39, 36)
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnDown00", "_lt", 251, 168, 39, 36)
		_this.text = "上";
		_this.onclick = ";CCS_UI_Eyebrow.SetFaceComponent(CCS_db.CFS_SUB_Y, -2);";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnDown01", "_lt", 296, 168, 39, 36)
		_this.text = "下";
		_this.onclick = ";CCS_UI_Eyebrow.SetFaceComponent(CCS_db.CFS_SUB_Y, 2);";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnDown10", "_lt", 251, 210, 39, 36)
		_this.text = "左";
		_this.onclick = ";CCS_UI_Eyebrow.SetFaceComponent(CCS_db.CFS_SUB_X, -1);";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnDown11", "_lt", 296, 210, 39, 36)
		_this.text = "右";
		_this.onclick = ";CCS_UI_Eyebrow.SetFaceComponent(CCS_db.CFS_SUB_X, 1);";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnDown20", "_lt", 251, 252, 39, 36)
		_this.text = "放大";
		_this.onclick = ";CCS_UI_Eyebrow.SetFaceComponent(CCS_db.CFS_SUB_Scale, 0.1);";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnDown21", "_lt", 296, 252, 39, 36)
		_this.text = "缩小";
		_this.onclick = ";CCS_UI_Eyebrow.SetFaceComponent(CCS_db.CFS_SUB_Scale, -0.1);";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnDown30", "_lt", 251, 294, 39, 36)
		_this.text = "左转";
		_this.onclick = ";CCS_UI_Eyebrow.SetFaceComponent(CCS_db.CFS_SUB_Rotation, 0.1);";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnDown31", "_lt", 296, 294, 39, 36)
		_this.text = "右转";
		_this.onclick = ";CCS_UI_Eyebrow.SetFaceComponent(CCS_db.CFS_SUB_Rotation, -0.1);";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnReset", "_lt", 251, 342, 84, 36)
		_this.text = "重置";
		_this.onclick = ";CCS_UI_Eyebrow.SetFaceComponent(nil);";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnLeft", "_lt", 41, 17, 35, 35)
		_this.text = "<-";
		_this.onclick = ";CCS_UI_Eyebrow.PageLeft();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnRight", "_lt", 143, 17, 35, 35)
		_this.text = "->";
		_this.onclick = ";CCS_UI_Eyebrow.PageRight();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "labelPage", "_lt", 92, 27, 36, 16)
		_this.text = "1/2";
		_parent:AddChild(_this);



		CCS_UI_Eyebrow.totalPage = 2;
		CCS_UI_Eyebrow.totalIcons = 20;
		CCS_UI_Eyebrow.iconsPerPage = 12;
		
		CCS_UI_Eyebrow.currentPage = 1;
		CCS_UI_Eyebrow.PageLeft();

		
	end -- if(_this:IsValid() == false) then
	
end -- function CCS_UI_Eyebrow.Show(parent)


-- destroy the control
function CCS_UI_Eyebrow.OnDestroy()
	ParaUI.Destroy("CCS_UI_Eyebrow_cont");
end


-- Page Left
function CCS_UI_Eyebrow.PageLeft()

	local _this,_parent;
	
	if(CCS_UI_Eyebrow.currentPage > 0) then
	
		CCS_UI_Eyebrow.currentPage = CCS_UI_Eyebrow.currentPage - 1;
		local _thisCont = ParaUI.GetUIObject("CCS_UI_Eyebrow_cont");
		
		_this = _thisCont:GetChild("labelPage");
		_this.text = (CCS_UI_Eyebrow.currentPage+1).."/"..CCS_UI_Eyebrow.totalPage;
		
		if(_thisCont:IsValid()) then
			local _container = _thisCont:GetChild("EyeBrow_Icon_Container");
			local _currentIconNum;
			_currentIconNum = (CCS_UI_Eyebrow.currentPage)*(CCS_UI_Eyebrow.iconsPerPage);
			ParaUI.Destroy("EyeBrow_Icon_Container");
			
			_this = ParaUI.CreateUIObject("container", "EyeBrow_Icon_Container", "_lt", 0,47,200,300)
			_this.background="Texture/whitedot.png;0 0 0 0";
			_thisCont:AddChild(_this);
			
			_parent = _this;
			
			
			
			if(_currentIconNum < CCS_UI_Eyebrow.totalIcons) then
				_this = ParaUI.CreateUIObject("button", "btnBrow00", "_lt", 23, 68, 54, 54)
				_this.text = "Brow"..(_currentIconNum+1);
				_parent:AddChild(_this);
				_currentIconNum = _currentIconNum + 1;
			end

			if(_currentIconNum < CCS_UI_Eyebrow.totalIcons) then
				_this = ParaUI.CreateUIObject("button", "btnBrow01", "_lt", 83, 68, 54, 54)
				_this.text = "Brow"..(_currentIconNum+1);
				_parent:AddChild(_this);
				_currentIconNum = _currentIconNum + 1;
			end

			if(_currentIconNum < CCS_UI_Eyebrow.totalIcons) then
				_this = ParaUI.CreateUIObject("button", "btnBrow02", "_lt", 143, 68, 54, 54)
				_this.text = "Brow"..(_currentIconNum+1);
				_parent:AddChild(_this);
				_currentIconNum = _currentIconNum + 1;
			end

			if(_currentIconNum < CCS_UI_Eyebrow.totalIcons) then
				_this = ParaUI.CreateUIObject("button", "btnBrow10", "_lt", 23, 128, 54, 54)
				_this.text = "Brow"..(_currentIconNum+1);
				_parent:AddChild(_this);
				_currentIconNum = _currentIconNum + 1;
			end

			if(_currentIconNum < CCS_UI_Eyebrow.totalIcons) then
				_this = ParaUI.CreateUIObject("button", "btnBrow11", "_lt", 83, 128, 54, 54)
				_this.text = "Brow"..(_currentIconNum+1);
				_parent:AddChild(_this);
				_currentIconNum = _currentIconNum + 1;
			end

			if(_currentIconNum < CCS_UI_Eyebrow.totalIcons) then
				_this = ParaUI.CreateUIObject("button", "btnBrow12", "_lt", 143, 128, 54, 54)
				_this.text = "Brow"..(_currentIconNum+1);
				_parent:AddChild(_this);
				_currentIconNum = _currentIconNum + 1;
			end
			
			if(_currentIconNum < CCS_UI_Eyebrow.totalIcons) then
				_this = ParaUI.CreateUIObject("button", "btnBrow20", "_lt", 23, 188, 54, 54)
				_this.text = "Brow"..(_currentIconNum+1);
				_parent:AddChild(_this);
				_currentIconNum = _currentIconNum + 1;
			end

			if(_currentIconNum < CCS_UI_Eyebrow.totalIcons) then
				_this = ParaUI.CreateUIObject("button", "btnBrow21", "_lt", 83, 188, 54, 54)
				_this.text = "Brow"..(_currentIconNum+1);
				_parent:AddChild(_this);
				_currentIconNum = _currentIconNum + 1;
			end

			if(_currentIconNum < CCS_UI_Eyebrow.totalIcons) then
				_this = ParaUI.CreateUIObject("button", "btnBrow22", "_lt", 143, 188, 54, 54)
				_this.text = "Brow"..(_currentIconNum+1);
				_parent:AddChild(_this);
				_currentIconNum = _currentIconNum + 1;
			end

			if(_currentIconNum < CCS_UI_Eyebrow.totalIcons) then
				_this = ParaUI.CreateUIObject("button", "btnBrow30", "_lt", 23, 248, 54, 54)
				_this.text = "Brow"..(_currentIconNum+1);
				_parent:AddChild(_this);
				_currentIconNum = _currentIconNum + 1;
			end

			if(_currentIconNum < CCS_UI_Eyebrow.totalIcons) then
				_this = ParaUI.CreateUIObject("button", "btnBrow31", "_lt", 83, 248, 54, 54)
				_this.text = "Brow"..(_currentIconNum+1);
				_parent:AddChild(_this);
				_currentIconNum = _currentIconNum + 1;
			end

			if(_currentIconNum < CCS_UI_Eyebrow.totalIcons) then
				_this = ParaUI.CreateUIObject("button", "btnBrow32", "_lt", 143, 248, 54, 54)
				_this.text = "Brow"..(_currentIconNum+1);
				_parent:AddChild(_this);
				_currentIconNum = _currentIconNum + 1;
			end
			
		end -- if(_this:IsValid()) then
		
	end -- if(CCS_UI_Eyebrow.currentPage > 1) then
	
end -- function CCS_UI_Eyebrow.PageLeft()


-- Page Right
function CCS_UI_Eyebrow.PageRight()

	local _this,_parent;
		
	if(CCS_UI_Eyebrow.currentPage < (CCS_UI_Eyebrow.totalPage-1) ) then
	
		CCS_UI_Eyebrow.currentPage = CCS_UI_Eyebrow.currentPage + 1;
		local _thisCont = ParaUI.GetUIObject("CCS_UI_Eyebrow_cont");
		
		_this = _thisCont:GetChild("labelPage");
		_this.text = (CCS_UI_Eyebrow.currentPage+1).."/"..CCS_UI_Eyebrow.totalPage;
		
		
		if(_thisCont:IsValid()) then
			local _container = _thisCont:GetChild("EyeBrow_Icon_Container");
			local _currentIconNum;
			_currentIconNum = (CCS_UI_Eyebrow.currentPage)*(CCS_UI_Eyebrow.iconsPerPage);
			ParaUI.Destroy("EyeBrow_Icon_Container");
			
			_this = ParaUI.CreateUIObject("container", "EyeBrow_Icon_Container", "_lt", 0,47,200,300)
			_this.background="Texture/whitedot.png;0 0 0 0";
			_thisCont:AddChild(_this);
			
			_parent = _this;
			
			if(_currentIconNum < CCS_UI_Eyebrow.totalIcons) then
				_this = ParaUI.CreateUIObject("button", "btnBrow00", "_lt", 23, 68, 54, 54)
				_this.text = "Brow"..(_currentIconNum+1);
				_parent:AddChild(_this);
				_currentIconNum = _currentIconNum + 1;
			end

			if(_currentIconNum < CCS_UI_Eyebrow.totalIcons) then
				_this = ParaUI.CreateUIObject("button", "btnBrow01", "_lt", 83, 68, 54, 54)
				_this.text = "Brow"..(_currentIconNum+1);
				_parent:AddChild(_this);
				_currentIconNum = _currentIconNum + 1;
			end

			if(_currentIconNum < CCS_UI_Eyebrow.totalIcons) then
				_this = ParaUI.CreateUIObject("button", "btnBrow02", "_lt", 143, 68, 54, 54)
				_this.text = "Brow"..(_currentIconNum+1);
				_parent:AddChild(_this);
				_currentIconNum = _currentIconNum + 1;
			end

			if(_currentIconNum < CCS_UI_Eyebrow.totalIcons) then
				_this = ParaUI.CreateUIObject("button", "btnBrow10", "_lt", 23, 128, 54, 54)
				_this.text = "Brow"..(_currentIconNum+1);
				_parent:AddChild(_this);
				_currentIconNum = _currentIconNum + 1;
			end

			if(_currentIconNum < CCS_UI_Eyebrow.totalIcons) then
				_this = ParaUI.CreateUIObject("button", "btnBrow11", "_lt", 83, 128, 54, 54)
				_this.text = "Brow"..(_currentIconNum+1);
				_parent:AddChild(_this);
				_currentIconNum = _currentIconNum + 1;
			end

			if(_currentIconNum < CCS_UI_Eyebrow.totalIcons) then
				_this = ParaUI.CreateUIObject("button", "btnBrow12", "_lt", 143, 128, 54, 54)
				_this.text = "Brow"..(_currentIconNum+1);
				_parent:AddChild(_this);
				_currentIconNum = _currentIconNum + 1;
			end
			
			if(_currentIconNum < CCS_UI_Eyebrow.totalIcons) then
				_this = ParaUI.CreateUIObject("button", "btnBrow20", "_lt", 23, 188, 54, 54)
				_this.text = "Brow"..(_currentIconNum+1);
				_parent:AddChild(_this);
				_currentIconNum = _currentIconNum + 1;
			end

			if(_currentIconNum < CCS_UI_Eyebrow.totalIcons) then
				_this = ParaUI.CreateUIObject("button", "btnBrow21", "_lt", 83, 188, 54, 54)
				_this.text = "Brow"..(_currentIconNum+1);
				_parent:AddChild(_this);
				_currentIconNum = _currentIconNum + 1;
			end

			if(_currentIconNum < CCS_UI_Eyebrow.totalIcons) then
				_this = ParaUI.CreateUIObject("button", "btnBrow22", "_lt", 143, 188, 54, 54)
				_this.text = "Brow"..(_currentIconNum+1);
				_parent:AddChild(_this);
				_currentIconNum = _currentIconNum + 1;
			end

			if(_currentIconNum < CCS_UI_Eyebrow.totalIcons) then
				_this = ParaUI.CreateUIObject("button", "btnBrow30", "_lt", 23, 248, 54, 54)
				_this.text = "Brow"..(_currentIconNum+1);
				_parent:AddChild(_this);
				_currentIconNum = _currentIconNum + 1;
			end

			if(_currentIconNum < CCS_UI_Eyebrow.totalIcons) then
				_this = ParaUI.CreateUIObject("button", "btnBrow31", "_lt", 83, 248, 54, 54)
				_this.text = "Brow"..(_currentIconNum+1);
				_parent:AddChild(_this);
				_currentIconNum = _currentIconNum + 1;
			end

			if(_currentIconNum < CCS_UI_Eyebrow.totalIcons) then
				_this = ParaUI.CreateUIObject("button", "btnBrow32", "_lt", 143, 248, 54, 54)
				_this.text = "Brow"..(_currentIconNum+1);
				_parent:AddChild(_this);
				_currentIconNum = _currentIconNum + 1;
			end
			
		end -- if(_this:IsValid()) then
		
	end -- if(CCS_UI_Eyebrow.currentPage < (CCS_UI_Eyebrow.totalPage-1) ) then
	
end -- function CCS_UI_Eyebrow.PageRight()

function CCS_UI_Eyebrow.SetFaceComponent(SubType, value, donot_refresh)
	CCS_db.SetFaceComponent(CCS_UI_Eyebrow.Section, SubType, value, donot_refresh);
end