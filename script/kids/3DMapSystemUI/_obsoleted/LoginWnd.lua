--[[
Title: Login window for 3d map system
Author(s): LiXizhi
Date: 2007/9/26
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/LoginWnd.lua");
Map3DSystem.UI.Login.Show();
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/kids/3DMapSystem_Data.lua");


--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function Map3DSystem.UI.Login.Show(bShow)
	local _this,_parent;
	
	_this=ParaUI.GetUIObject("MapLoginWnd_cont");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		_this=ParaUI.CreateUIObject("container","MapLoginWnd_cont","_ctt",0,0,700,600);
		_this.background = "Texture/uncheckbox.png:10 10 10 10";
		_this:AttachToRoot();
		_parent = _this;

		_this = ParaUI.CreateUIObject("text", "label32", "_lb", 56, -29, 456, 16)
		_this.text = "2004-2007 @ ParaEngine Corporation. All Rights Reserved.";
		_this:GetFont("text").color = "105 105 105";
		_parent:AddChild(_this);

		-- LoginPanel
		_this = ParaUI.CreateUIObject("container", "LoginPanel", "_rt", -391, 20, 361, 394)
		_this.background = "Texture/uncheckbox.png:10 10 10 10";
		_this.rotation = 0.1;
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("editbox", "editboxUserName", "_lt", 127, 66, 139, 26)
		_this.background = "Texture/uncheckbox.png:4 4 4 4";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("text", "label2", "_lt", 26, 109, 80, 16)
		_this.text = "Password:";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("editbox", "textBoxPassWord", "_lt", 127, 106, 139, 26)
		_this.background = "Texture/uncheckbox.png:4 4 4 4";
		_this.PasswordChar = "*";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label7", "_lt", 26, 150, 64, 16)
		_this.text = "Domain:";
		_this.background = "Texture/uncheckbox.png:4 4 4 4";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button1", "_lt", 29, 298, 101, 28)
		_this.text = "离线浏览";
		_this.tooltip = "离线浏览";
		_this.rotation = -0.2;
		_guihelper.SetVistaStyleButton(_this, "", "Texture/uncheckbox.png:4 4 4 4");
		_this.onclick= ";Map3DSystem.UI.Login.OnLoginOfflineMode()";
		_parent:AddChild(_this);
		

		_this = ParaUI.CreateUIObject("button", "btnLogin", "_lt", 29, 235, 101, 28)
		_this.text = "Login";
		_this.rotation = -0.2;
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "btnRegister", "_lt", 165, 235, 101, 28)
		_this.rotation = -0.2;
		_this.animstyle= 12;
		--_this.scalingx = 2;
		--_this.scalingy = 2;
		--_this.translationx = 50;
		--_this.translationy = 50;
		_this.text = "Register";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "LoginMessage", "_lt", 26, 16, 256, 16)
		_this.text = "Please login using your account";
		_this:GetFont("text").color = "165 42 42";
		_parent:AddChild(_this);

		NPL.load("(gl)script/ide/CheckBox.lua");
		local ctl = CommonCtrl.checkbox:new{
			name = "checkboxRememberUserNamePassword",
			alignment = "_lt",
			left = 29,
			top = 193,
			width = 275,
			height = 20,
			parent = _parent,
			isChecked = true,
			text = "Remember user name and password",
		};
		ctl:Show();

		_this = ParaUI.CreateUIObject("text", "label1", "_lt", 26, 69, 88, 16)
		_this.text = "User Name:";
		_parent:AddChild(_this);

		NPL.load("(gl)script/ide/dropdownlistbox.lua");
		local ctl = CommonCtrl.dropdownlistbox:new{
			name = "comboBoxDomain",
			alignment = "_lt",
			left = 127,
			top = 151,
			width = 177,
			height = 24,
			dropdownheight = 106,
 			parent = _parent,
			text = "",
			listbox_bg = "Texture/uncheckbox.png:4 4 4 4", -- list box background texture
			editbox_bg = "Texture/uncheckbox.png:4 4 4 4", -- edit box background texture
			items = {"www.kids3dmovie.com", "www.paraengine.com",},
		};
		ctl:Show();
	
	else
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		_this.visible = bShow;
	end	
end

-- destory the control
function Map3DSystem.UI.Login.OnDestory()
	ParaUI.Destroy("MapLoginWnd_cont");
end

function Map3DSystem.UI.Login.OnLoginOfflineMode()
	Map3DSystem.UI.Login.OnDestory();
	main_state="ingame";
end