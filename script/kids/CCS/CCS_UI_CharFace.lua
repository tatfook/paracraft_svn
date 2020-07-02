--[[
Title: character customization system UI plug-in for character face
Author(s): WangTian
Date: 2007/7/20
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/CCS/CCS_UI_CharFace.lua");
CCS_UI_CharFace.Show(_parent);
-------------------------------------------------------

NOTE: CharFace is different from cartoon face. TODO: more comment
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/kids/CCS/CCS_db.lua");
NPL.load("(gl)script/kids/CCS/CCS_UI_FaceComponent.lua");

-- Debug purpose
NPL.load("(gl)script/ide/gui_helper.lua");

if(not CCS_UI_CharFace) then CCS_UI_CharFace = {}; end


-- create, init and display the face UI control
--@param parent: ParaUIObject which is the parent container
function CCS_UI_CharFace.Show(parent)
	local _this = ParaUI.GetUIObject("CCS_Right_IconMatrix_Container");
	_this.visible = false;
	_this = ParaUI.GetUIObject("CCS_UI_Face_container");
	_this.visible = false;
	
	if(_this:IsValid() == false) then
		-- CCS_UI_CharFace_container
		_this = ParaUI.CreateUIObject("container", "CCS_UI_CharFace_container", "_lt", 15, 12, 200, 150)
		_this.background="Texture/KeysHelp.png;0 0 0 0";
		
		if(parent == nil) then
			_this:AttachToRoot();
		else
			parent:AddChild(_this);
		end
		
		_parent = _this;


		_this = ParaUI.CreateUIObject("button", "button00", "_lt", 18, 32, 48, 48)
		_this.text = "2";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button01", "_lt", 66, 32, 48, 48)
		_this.text = "3";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button10", "_lt", 18, 80, 48, 48)
		_this.text = "5";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "button11", "_lt", 66, 80, 48, 48)
		_this.text = "6";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "buttonMatrix", "_lt", 133, 32, 264, 118)
		_this.text = "Icon Matrix";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "buttonL", "_lt", 134, 0, 32, 32)
		_this.text = "<-";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "labelPage", "_lt", 172, 11, 40, 16)
		_this.text = "0/0";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "buttonR", "_lt", 218, 0, 32, 32)
		_this.text = "->";
		_parent:AddChild(_this);

	end -- if(_this:IsValid() == false) then

end -- function CCS_UI_CharFace.Show(parent)