--[[
Title: character customization system UI plug-in for cartoon face
Author(s): WangTian
Date: 2007/7/9
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/CCS/CCS_UI_CartoonFace.lua");
CCS_UI_CartoonFace.Show(_parent);
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/kids/CCS/CCS_db.lua");

-- Debug purpose
NPL.load("(gl)script/ide/gui_helper.lua");

if(not CCS_UI_CartoonFace) then CCS_UI_CartoonFace = {}; end
if(not CCS_UI_CartoonFace_SubCont) then CCS_UI_CartoonFace_SubCont = {}; end

-- create, init and display the cartoon face UI control
--@param parent: ParaUIObject which is the parent container
function CCS_UI_CartoonFace.Show(parent)
	local _this,_parent;
	
	_this=ParaUI.GetUIObject("CCS_UI_CartoonFace_cont");
	
	if(_this:IsValid() == false) then
		-- CCS_UI_CartoonFace_cont
		_this=ParaUI.CreateUIObject("container","CCS_UI_CartoonFace_cont","_fi",0,0,0,0);
		_this.background="Texture/whitedot.png;0 0 0 0";
		if(parent == nil) then
			_this:AttachToRoot();
		else
			parent:AddChild(_this);
		end
		
		_parent = _this;

		_this = ParaUI.CreateUIObject("container", "TabControl", "_fi", 0,0,0,0)
		_this.background="Texture/whitedot.png;0 0 0 0";
		_parent:AddChild(_this);
		
		CCS_UI_CartoonFace.ShowSubControl1();
		
		_this = ParaUI.CreateUIObject("button", "btnTab1", "_lt", 3, 3, 96, 28)
		_this.text = "脸型";
		_this.onclick = ";CCS_UI_CartoonFace.ShowSubControl1();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnTab2", "_lt", 116, 3, 96, 28)
		_this.text = "特征";
		_this.onclick = ";CCS_UI_CartoonFace.ShowSubControl2();";
		_parent:AddChild(_this);
		
		--_guihelper.MessageBox("CartoonFace Shown\n");
		
	end -- if(_this:IsValid() == false) then
	
end -- function CCS_UI_CartoonFace.Show(parent)


-- destroy the control
function CCS_UI_CartoonFace.OnDestroy()
	ParaUI.Destroy("CCS_UI_CartoonFace_cont");
	
	local _current = ParaUI.GetUIObject("CCS_UI_CartoonFace_subcont1");
	if(_current:IsValid()) then
		ParaUI.Destroy("CCS_UI_CartoonFace_subcont1");
	end
	
	_current = ParaUI.GetUIObject("CCS_UI_CartoonFace_subcont2");
	if(_current:IsValid()) then
		ParaUI.Destroy("CCS_UI_CartoonFace_subcont2");
	end
end


-- create, init and display the cartoon face UI sub control
--@param parent: ParaUIObject which is the parent container
function CCS_UI_CartoonFace.ShowSubControl1()
	local _this,_parent;
	
	local _this = ParaUI.GetUIObject("CCS_UI_CartoonFace_cont");
	
	if(_this:IsValid()) then
		local parent = _this:GetChild("TabControl");
		local tab2 = parent:GetChild("CCS_UI_CartoonFace_subcont2");
		
		if(tab2:IsValid()) then
			ParaUI.Destroy("CCS_UI_CartoonFace_subcont2");
		end
		
		
		_this=ParaUI.GetUIObject("CCS_UI_CartoonFace_subcont1");
		if(_this:IsValid() == false) then
			-- CCS_UI_CartoonFace_cont
			_this=ParaUI.CreateUIObject("container","CCS_UI_CartoonFace_subcont1","_fi",0,0,0,0);
			_this.background="Texture/whitedot.png;0 0 0 0";
			if(parent == nil) then
				_this:AttachToRoot();
			else
				parent:AddChild(_this);
			end
			
			_parent = _this;
			
			
			_this = ParaUI.CreateUIObject("button", "btnFace00", "_lt", 51, 74, 54, 54)
			_this.text = "Face1";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnFace01", "_lt", 111, 74, 54, 54)
			_this.text = "Face2";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnFace10", "_lt", 51, 134, 54, 54)
			_this.text = "Face3";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnFace11", "_lt", 111, 134, 54, 54)
			_this.text = "Face4";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnFace20", "_lt", 51, 194, 54, 54)
			_this.text = "Face5";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnFace21", "_lt", 111, 194, 54, 54)
			_this.text = "Face6";
			_parent:AddChild(_this);
			
			_this = ParaUI.CreateUIObject("button", "btnUp00", "_lt", 232, 68, 39, 36)
			_this.text = "Clr1";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnUp01", "_lt", 277, 68, 39, 36)
			_this.text = "Clr2";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnUp02", "_lt", 322, 68, 39, 36)
			_this.text = "Clr3";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnUp10", "_lt", 232, 110, 39, 36)
			_this.text = "Clr4";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnUp11", "_lt", 277, 110, 39, 36)
			_this.text = "Clr5";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnUp12", "_lt", 322, 110, 39, 36)
			_this.text = "Clr6";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnDown00", "_lt", 251, 168, 39, 36)
			_this.text = "Down";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnDown01", "_lt", 296, 168, 39, 36)
			_this.text = "Up";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnDown10", "_lt", 251, 210, 39, 36)
			_this.text = "ScaleY";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnDown11", "_lt", 296, 210, 39, 36)
			_this.text = "ScaleY";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnDown20", "_lt", 251, 252, 39, 36)
			_this.text = "ScaleX";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnDown21", "_lt", 296, 252, 39, 36)
			_this.text = "ScaleX";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnReset", "_lt", 251, 342, 84, 36)
			_this.text = "Reset";
			_parent:AddChild(_this);
			
		end -- if(_this:IsValid() == false) then
	
	else
		
	end
	


		

end -- function CCS_UI_CartoonFace.ShowSubControl1(parent)


		

-- create, init and display the cartoon face UI sub control
--@param parent: ParaUIObject which is the parent container
function CCS_UI_CartoonFace.ShowSubControl2()
	local _this,_parent;
	
	local _this = ParaUI.GetUIObject("CCS_UI_CartoonFace_cont");
	
	if(_this:IsValid()) then
		local parent = _this:GetChild("TabControl");
		local tab1 = parent:GetChild("CCS_UI_CartoonFace_subcont1");
		
		if(tab1:IsValid()) then
			ParaUI.Destroy("CCS_UI_CartoonFace_subcont1");
		end
		
		
		_this=ParaUI.GetUIObject("CCS_UI_CartoonFace_subcont2");
		if(_this:IsValid() == false) then
			-- CCS_UI_CartoonFace_cont
			_this=ParaUI.CreateUIObject("container","CCS_UI_CartoonFace_subcont2","_fi",0,0,0,0);
			_this.background="Texture/whitedot.png;0 0 0 0";
			if(parent == nil) then
				_this:AttachToRoot();
			else
				parent:AddChild(_this);
			end
			
			_parent = _this;
			
			_this = ParaUI.CreateUIObject("button", "btnFace00", "_lt", 23, 68, 54, 54)
			_this.text = "Face1";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnFace01", "_lt", 83, 68, 54, 54)
			_this.text = "Face2";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnFace02", "_lt", 143, 68, 54, 54)
			_this.text = "Face3";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnFace10", "_lt", 23, 128, 54, 54)
			_this.text = "Face4";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnFace11", "_lt", 83, 128, 54, 54)
			_this.text = "Face5";
			_parent:AddChild(_this);
			
			_this = ParaUI.CreateUIObject("button", "btnFace12", "_lt", 143, 128, 54, 54)
			_this.text = "Face6";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnFace20", "_lt", 23, 188, 54, 54)
			_this.text = "Face7";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnFace21", "_lt", 83, 188, 54, 54)
			_this.text = "Face8";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnFace22", "_lt", 143, 188, 54, 54)
			_this.text = "Face9";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnFace30", "_lt", 23, 248, 54, 54)
			_this.text = "Face10";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnFace31", "_lt", 83, 248, 54, 54)
			_this.text = "Face11";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnFace32", "_lt", 143, 248, 54, 54)
			_this.text = "Face12";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnDown00", "_lt", 251, 168, 39, 36)
			_this.text = "Down";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnDown01", "_lt", 296, 168, 39, 36)
			_this.text = "Up";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnDown10", "_lt", 251, 210, 39, 36)
			_this.text = "ZoomIn";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnDown11", "_lt", 296, 210, 39, 36)
			_this.text = "ZoomOut";
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button", "btnReset", "_lt", 251, 342, 84, 36)
			_this.text = "Reset";
			_parent:AddChild(_this);

		end	-- if(_this:IsValid() == false) then
		
	else
		
	end
	
end -- function CCS_UI_CartoonFace.ShowSubControl2(parent)


