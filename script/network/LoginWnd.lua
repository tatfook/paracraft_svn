--[[
Title: a login window in explorer
Author(s): LiXizhi
Date: 2007/4/3
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/network/LoginWnd.lua");
local ctl = CommonCtrl.LoginWnd:new{
	name = "LoginWnd1",
	alignment = "_lt",
	left=0, top=0,
	width = 512,
	height = 290,
	parent = nil,
};
ctl:Show();
-------------------------------------------------------
]]
-- common control library
NPL.load("(gl)script/kids/loadworld.lua");
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/ide/CheckBox.lua");
NPL.load("(gl)script/ide/dropdownlistbox.lua");
NPL.load("(gl)script/ide/gui_helper.lua");

local L = CommonCtrl.Locale("IDE");

-- define a new control in the common control libary

-- default member attributes
local LoginWnd = {
	-- the top level control name
	name = "LoginWnd1",
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 512,
	height = 290, 
	parent = nil,
	-- attribute
	url = "",
	title = "untitled",
	username = "LiXizhi",
	password = "",
	domainname = "www.kids3dmovie.com",
	Authenticated = false, -- whether the user is authenticated.
	-- appearance
	pagetab_bg = "Texture/kidui/explorer/pagetab.png",
	pagetab_selected_bg = "Texture/kidui/explorer/pagetab_selected.png",
	panel_bg = "Texture/kidui/explorer/panel_bg.png",
	panel_sub_bg = "Texture/kidui/explorer/panel_sub_bg.png",
	button_bg = "Texture/kidui/explorer/button.png",
	listbox_bg = "Texture/kidui/explorer/listbox_bg.png",
	dropdownarrow_bg = "Texture/kidui/explorer/dropdown_arrow.png",
	dropdownlist_cont_bg = "Texture/kidui/explorer/editbox256x32.png",
	editbox_bg = "Texture/kidui/explorer/editbox128x32.png",
	editbox_long_bg = "Texture/kidui/explorer/editbox256x32.png",
}
CommonCtrl.LoginWnd = LoginWnd;

-- web service
LoginWnd.webservice_AuthUser  = CommonCtrl.Locale("KidsUI")("AuthUser.asmx");
LoginWnd.CommunitySite = CommonCtrl.Locale("KidsUI")("community.aspx");

-- constructor
function LoginWnd:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Destroy the UI control
function LoginWnd:Destroy ()
	ParaUI.Destroy(self.name);
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function LoginWnd:Show(bShow)
	local _this,_parent;
	local left, top, width, height;
	if(self.name==nil)then
		log("LoginWnd instance name can not be nil\r\n");
		return
	end
	
	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		
		_this=ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
		_this.background="Texture/whitedot.png;0 0 0 0";
		_this.zorder = 5;
		_parent = _this;
		
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		CommonCtrl.AddControl(self.name, self);
		
		-- tabControl1
		_this = ParaUI.CreateUIObject("container", "tabControl1", "_fi", 0, 0, 0, 0)
		_this.background="Texture/whitedot.png;0 0 0 0";
		_parent:AddChild(_this);
		_parent = _this;

		self.tabpages = {[1] = self.name.."tabPageLogin", [2] = self.name.."tabPageRegister", [3] = self.name.."tabPageServers", [4] = self.name.."tabPageGameServer", [5] = self.name.."tabPageSpaceServer", };
		self.tabbuttons = {[1] = self.name.."tabPageLogin_TabBtn", [2] = self.name.."tabPageRegister_TabBtn", [3] = self.name.."tabPageServers_TabBtn", [4] = self.name.."tabPageGameServer_TabBtn", [5] = self.name.."tabPageSpaceServer_TabBtn", };
		
		left, top, width, height = 0,0,120,26
		_this = ParaUI.CreateUIObject("button", self.name.."tabPageLogin_TabBtn", "_lt", left, top, width, height)
		_this.text = L"Login";
		_this.onclick=string.format([[;CommonCtrl.LoginWnd.SwitchTabWindow("%s", 1);]],self.name);
		_this.background=self.pagetab_bg;
		_parent:AddChild(_this);
		left = left + width;
		_this = ParaUI.CreateUIObject("button", self.name.."tabPageRegister_TabBtn", "_lt", left, top, width, height)
		_this.text = L"Register";
		_this.onclick=string.format([[;CommonCtrl.LoginWnd.SwitchTabWindow("%s", 2);]],self.name);
		_this.background=self.pagetab_bg;
		_parent:AddChild(_this);
		left = left + width;
		_this = ParaUI.CreateUIObject("button", self.name.."tabPageServers_TabBtn", "_lt", left, top, width, height)
		_this.text = L"Servers";
		_this.onclick=string.format([[;CommonCtrl.LoginWnd.SwitchTabWindow("%s", 3);]],self.name);
		_this.background=self.pagetab_bg;
		_parent:AddChild(_this);
		left = left + width;
		_this = ParaUI.CreateUIObject("button", self.name.."tabPageGameServer_TabBtn", "_lt", left, top, width, height)
		_this.text = L"My Game Server";
		_this.onclick=string.format([[;CommonCtrl.LoginWnd.SwitchTabWindow("%s", 4);]],self.name);
		_this.background=self.pagetab_bg;
		_parent:AddChild(_this);
		left = left + width;
		_this = ParaUI.CreateUIObject("button", self.name.."tabPageSpaceServer_TabBtn", "_lt", left, top, width, height)
		_this.text = L"My Space Server";
		_this.onclick=string.format([[;CommonCtrl.LoginWnd.SwitchTabWindow("%s", 5);]],self.name);
		_this.background=self.pagetab_bg;
		_parent:AddChild(_this);

		_parent = ParaUI.GetUIObject("tabControl1");
		-- tabPageLogin
		_this = ParaUI.CreateUIObject("container", self.name.."tabPageLogin", "_fi", 0, 28, 4, 4)
		_this.background=self.panel_bg;
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("text", "label1", "_lt", 24, 84, 88, 16)
		_this.text = L"User name:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", self.name.."LoginMessage", "_mt", 24, 31, 10, 16)
		_this.text = L"Please login using your account";
		_this:GetFont("text").color = "165 42 42";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label2", "_lt", 24, 124, 80, 16)
		_this.text = L"Password:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("editbox", self.name.."editboxUserName", "_lt", 125, 81, 139, 26)
		_this.background=self.editbox_bg;
		_this.text = kids_db.User.Name;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("editbox", self.name.."editBoxPassWord", "_lt", 125, 121, 139, 26)
		_this.PasswordChar = "*";
		_this.text = kids_db.User.Password;
		_this.background=self.editbox_bg;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnLogin", "_lt",  27, 250, 101, 28)
		_this.text = L"Login";
		_this.background=self.button_bg;
		_this.onclick=string.format([[;CommonCtrl.LoginWnd.OnClickBtnLogin("%s");]],self.name);
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnHostWorld", "_lt", 163, 250, 101, 28)
		_this.text = L"Host World";
		_this.onclick=string.format([[;CommonCtrl.LoginWnd.OnClickHostWorld("%s");]], self.name);
		_this.background=self.button_bg;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "s", "_lt", 24, 165, 64, 16)
		_this.text = L"Domain:";
		_parent:AddChild(_this);

		local ctl = CommonCtrl.checkbox:new{
			name = self.name.."checkboxRememberUserNamePassword",
			alignment = "_lt",
			left = 27,
			top = 208,
			width = 350,
			height = 20,
			parent = _parent,
			isChecked = true,
			text = L"Remember user name and password",
		};
		ctl:Show();

		local ctl = CommonCtrl.dropdownlistbox:new{
			name = self.name.."comboBoxDomain",
			alignment = "_lt",
			left = 125,
			top = 166,
			width = 200,
			height = 26,
			buttonwidth = 20,
			dropdownheight = 70,
 			parent = _parent,
 			container_bg = self.dropdownlist_cont_bg,
			editbox_bg = "Texture/whitedot.png;0 0 0 0",
			dropdownbutton_bg = self.dropdownarrow_bg,
			listbox_bg = self.listbox_bg,
			text = "www.kids3dmovie.com",
			items = {"www.kids3dmovie.com", "www.paraengine.com", },
		};
		ctl:Show();

		_this = ParaUI.CreateUIObject("button", "logo", "_rt", -262, 22, 256, 256)
		_this.background="Texture/kidui/explorer/logo.png";
		_guihelper.SetUIColor(_this, "255 255 255");
		_this.tooltip = LoginWnd.CommunitySite;
		_this.onclick = string.format([[;ParaGlobal.ShellExecute("open", "iexplore.exe", "%s", nil, 1);]], LoginWnd.CommunitySite);
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "s", "_lb", 24, -31, 500, 16)
		_this.text = "2004-2007 @ ParaEngine Corporation. All Rights Reserved.";
		_this:GetFont("text").color = "105 105 105";
		_parent:AddChild(_this);

		-- tabPageRegister
		_this = ParaUI.CreateUIObject("container", self.name.."tabPageRegister", "_fi", 0, 28, 4, 4)
		_this.background=self.panel_bg;
		_parent = ParaUI.GetUIObject("tabControl1");
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("text", "label4", "_lt", 24, 28, 88, 16)
		_this.text = L"User name:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label3", "_lt", 24, 68, 80, 16)
		_this.text = L"Password:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label5", "_lt", 24, 105, 144, 16)
		_this.text = "Password Confirm:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label6", "_lt", 24, 144, 56, 16)
		_this.text = "Email:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label8", "_lt", 24, 182, 104, 16)
		_this.text = "Product Key:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("editbox", "RegUserName", "_lt", 180, 25, 191, 26)
		_this.background=self.editbox_long_bg;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("editbox", "RegPassword", "_lt", 180, 65, 191, 26)
		_this.background=self.editbox_long_bg;
		_this.PasswordChar = "*";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("editbox", "RegEmail", "_lt", 180, 141, 191, 26)
		_this.background=self.editbox_long_bg;
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("editbox", "RegPasswordConfirm", "_lt", 180, 102, 191, 26)
		_this.background=self.editbox_long_bg;
		_this.PasswordChar = "*";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("editbox", "RegProductKey", "_lt", 180, 179, 191, 26)
		_this.background=self.editbox_long_bg;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnSubmit", "_lt", 27, 230, 101, 28)
		_this.text = "Submit";
		_this.background=self.button_bg;
		_parent:AddChild(_this);


		-- tabPageServers
		_this = ParaUI.CreateUIObject("container", self.name.."tabPageServers", "_fi", 0, 28, 4, 4)
		_this.background=self.panel_bg;
		_parent = ParaUI.GetUIObject("tabControl1");
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("button", "btnUploadServerInfo", "_lt", 164, 172, 103, 29)
		_this.text = "Upload";
		_this.background=self.button_bg;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnRefreshServerInfo", "_lt", 292, 172, 103, 29)
		_this.text = "Refresh";
		_this.background=self.button_bg;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnOpenWebPage", "_lt", 401, 9, 97, 26)
		_this.text = "open web";
		_this.background=self.button_bg;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnManageGameServer", "_lt", 401, 68, 97, 26)
		_this.text = "Manage";
		_this.background=self.button_bg;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button1", "_lt", 401, 99, 97, 26)
		_this.text = "Manage";
		_this.background=self.button_bg;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button2", "_lt", 401, 131, 97, 26)
		_this.text = "Manage";
		_this.background=self.button_bg;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label13", "_lt", 6, 12, 120, 16)
		_this.text = "Management for";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("editbox", "editboxURL", "_lt", 130, 9, 265, 26)
		_this.background=self.editbox_long_bg;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label11", "_lt", 36, 102, 112, 16)
		_this.text = "Space Server:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("editbox", "editboxSpaceServer", "_lt", 164, 99, 231, 26)
		_this.background=self.editbox_long_bg;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label10", "_lt", 38, 71, 104, 16)
		_this.text = "Game Server:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label12", "_lt", 6, 41, 136, 16)
		_this.text = "Server Computers";
		_this:GetFont("text").color = "65 105 225";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label14", "_lt", 6, 211, 144, 16)
		_this.text = "Server Statistics";
		_this:GetFont("text").color = "65 105 225";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("editbox", "editboxGameServer", "_lt", 164, 68, 231, 26)
		_this.background=self.editbox_long_bg;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label9", "_lt", 36, 134, 112, 16)
		_this.text = "Lobby Server:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label15", "_lt", 36, 245, 192, 16)
		_this.text = "Total number of visits:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label21", "_lt", 36, 273, 256, 16)
		_this.text = "Total number of object created:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label23", "_lt", 38, 300, 96, 16)
		_this.text = "Popularity:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label25", "_lt", 38, 328, 96, 16)
		_this.text = "Activities:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label20", "_lt", 342, 245, 16, 16)
		_this.text = "0";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label22", "_lt", 342, 273, 16, 16)
		_this.text = "0";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label24", "_lt", 342, 300, 16, 16)
		_this.text = "0";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label26", "_lt", 342, 328, 16, 16)
		_this.text = "0";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("editbox", "editboxLobbyServer", "_lt", 164, 131, 231, 26)
		_this.background=self.editbox_long_bg;
		_parent:AddChild(_this);

		-- tabPageGameServer
		_this = ParaUI.CreateUIObject("container", self.name.."tabPageGameServer", "_fi", 0, 28, 4, 4)
		_this.background=self.panel_bg;
		_this.scrollable = true;
		_parent = ParaUI.GetUIObject("tabControl1");
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("button", "button6", "_lt", 47, 49, 97, 26)
		_this.text = "Restart";
		_this.onclick=string.format([[;CommonCtrl.LoginWnd.OnClickRestartGameserver("%s");]],self.name);
		_this.background=self.button_bg;
		_parent:AddChild(_this);

		-- panel1
		_this = ParaUI.CreateUIObject("container", self.name.."LoginWnd", "_lt", 14, 81, 524, 269)
		_this.background=self.panel_sub_bg;
		_parent:AddChild(_this);
		_parent = _this;

		NPL.load("(gl)script/ide/RadioBox.lua");
		local ctl = CommonCtrl.radiobox:new{
			name = "radioButton2",
			alignment = "_lt",
			left = 47,
			top = 102,
			width = 226,
			height = 20,
			parent = _parent,
			isChecked = false,
			text = "Use custom editing rights",
		};
		ctl:Show();

		NPL.load("(gl)script/ide/RadioBox.lua");
		local ctl = CommonCtrl.radiobox:new{
			name = "radioButtonDisableAll",
			alignment = "_lt",
			left = 47,
			top = 76,
			width = 234,
			height = 20,
			parent = _parent,
			isChecked = true,
			text = "Disable all editing rights",
		};
		ctl:Show();

		_this = ParaUI.CreateUIObject("text", "label16", "_lt", 18, 49, 48, 16)
		_this.text = "Role:";
		_parent:AddChild(_this);

		NPL.load("(gl)script/ide/dropdownlistbox.lua");
		local ctl = CommonCtrl.dropdownlistbox:new{
			name = "comboBox1",
			alignment = "_lt",
			left = 95,
			top = 46,
			width = 186,
			height = 24,
			dropdownheight = 80,
 			parent = _parent,
			text = "guest",
			container_bg = self.dropdownlist_cont_bg,
			editbox_bg = "Texture/whitedot.png;0 0 0 0",
			dropdownbutton_bg = self.dropdownarrow_bg,
			listbox_bg = self.listbox_bg,
			items = {"owner", "friend", "guest", },
		};
		ctl:Show();

		_this = ParaUI.CreateUIObject("text", "label17", "_lt", 3, 11, 232, 16)
		_this.text = "User Access Right Management";
		_this:GetFont("text").color = "65 105 225";
		_parent:AddChild(_this);

		NPL.load("(gl)script/ide/CheckBox.lua");
		local ctl = CommonCtrl.checkbox:new{
			name = "checkBox1",
			alignment = "_lt",
			left = 78,
			top = 137,
			width = 347,
			height = 20,
			parent = _parent,
			isChecked = true,
			text = "Terrain height field and texture editing",
		};
		ctl:Show();

		NPL.load("(gl)script/ide/CheckBox.lua");
		local ctl = CommonCtrl.checkbox:new{
			name = "checkBox2",
			alignment = "_lt",
			left = 78,
			top = 163,
			width = 235,
			height = 20,
			parent = _parent,
			isChecked = false,
			text = "Ocean, time of day editing",
		};
		ctl:Show();

		NPL.load("(gl)script/ide/CheckBox.lua");
		local ctl = CommonCtrl.checkbox:new{
			name = "checkBox3",
			alignment = "_lt",
			left = 78,
			top = 189,
			width = 363,
			height = 20,
			parent = _parent,
			isChecked = true,
			text = "Object creation, deletion and modification",
		};
		ctl:Show();

		NPL.load("(gl)script/ide/CheckBox.lua");
		local ctl = CommonCtrl.checkbox:new{
			name = "checkBox4",
			alignment = "_lt",
			left = 78,
			top = 215,
			width = 387,
			height = 20,
			parent = _parent,
			isChecked = true,
			text = "Character creation, deletion and modification",
		};
		ctl:Show();

		NPL.load("(gl)script/ide/CheckBox.lua");
		local ctl = CommonCtrl.checkbox:new{
			name = "checkBox5",
			alignment = "_lt",
			left = 78,
			top = 241,
			width = 195,
			height = 20,
			parent = _parent,
			isChecked = false,
			text = "Server side scripting",
		};
		ctl:Show();

		_this = ParaUI.CreateUIObject("text", "label18", "_lt", 17, 16, 160, 16)
		_this.text = "Game Server Actions";
		_this:GetFont("text").color = "65 105 225";
		_parent = ParaUI.GetUIObject(self.name.."tabPageGameServer");
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label19", "_lt", 17, 370, 104, 16)
		_this.text = "Online Users";
		_this:GetFont("text").color = "65 105 225";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button9", "_lt", 27, 496, 73, 29)
		_this.text = "Refresh";
		_this.background=self.button_bg;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button8", "_lt", 105, 496, 73, 29)
		_this.text = "Kick";
		_this.background=self.button_bg;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button7", "_lt", 182, 496, 73, 29)
		_this.text = "Ban";
		_this.background=self.button_bg;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("listbox", "listBox1", "_lt", 27, 402, 228, 88)
		_this.background = self.listbox_bg;
		_this.scrollable = true;
		_this.wordbreak = false;
		_this.itemheight = 12;
		--_this.onselect = ";";
		--_this.ondoubleclick = ";";
		_this.font = "System;11;norm";
		_this.scrollbarwidth = 20;
		_parent:AddChild(_this);

		-- tabPageSpaceServer
		_this = ParaUI.CreateUIObject("container", self.name.."tabPageSpaceServer", "_fi", 0, 28, 4, 4)
		_this.background=self.panel_bg;
		_parent = ParaUI.GetUIObject("tabControl1");
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("button", "button3", "_lt", 41, 44, 97, 26)
		_this.text = "Restart";
		_this.background=self.button_bg;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button4", "_lt", 41, 88, 97, 26)
		_this.text = "Upload";
		_this.background=self.button_bg;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button5", "_lt", 41, 135, 97, 26)
		_this.text = "Download";
		_this.background=self.button_bg;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label27", "_lt", 165, 47, 384, 16)
		_this.text = "automatically synchronize with the space server";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label28", "_lt", 165, 91, 336, 16)
		_this.text = "upload the game world to the space server";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label29", "_lt", 165, 138, 368, 16)
		_this.text = "download the game world from the space server";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label30", "_lt", 31, 186, 80, 16)
		_this.text = "My Stuffs";
		_this:GetFont("text").color = "65 105 225";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label31", "_lt", 31, 14, 168, 16)
		_this.text = "Space Server Actions";
		_this:GetFont("text").color = "65 105 225";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button12", "_lt", 41, 312, 73, 29)
		_this.text = "buy";
		_this.background=self.button_bg;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button11", "_lt", 119, 312, 73, 29)
		_this.text = "Wish List";
		_this.background=self.button_bg;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button10", "_lt", 196, 312, 73, 29)
		_this.text = "Sell";
		_this.background=self.button_bg;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("listbox", "listBox2", "_lt", 41, 218, 228, 88)
		_this.background = self.listbox_bg;
		_this.scrollable = true;
		_this.wordbreak = false;
		_this.itemheight = 12;
		--_this.onselect = ";";
		--_this.ondoubleclick = ";";
		_this.font = "System;11;norm";
		_this.scrollbarwidth = 20;
		_this:AddTextItem([[car]]);
		_this:AddTextItem([[dog]]);
		_this:AddTextItem([[character]]);
		_this:AddTextItem([[trees]]);
		_this:AddTextItem([[vehicles]]);
		_this:AddTextItem([[scripts]]);
		_this:AddTextItem([[game worlds]]);
		_this:AddTextItem([[others]]);
		_parent:AddChild(_this);

		-- switch to a tab page
		self.SwitchTabWindow(self.name, 1);
	else
		if(bShow == nil) then
			bShow = (_this.visible == false);
		end
		_this.visible = bShow;
	end	
	
	if(bShow) then
		self:UpdateLoginStatus(true);
	end
end

---------------------------------------------------------
-- private functions
---------------------------------------------------------
-- @param nIndex: 0 or 1
function LoginWnd.SwitchTabWindow(sCtrlName, nIndex)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting LoginWnd instance "..sCtrlName.."\r\n");
		return;
	end
	if(self.tabpages~=nil and self.tabbuttons~=nil) then
		_guihelper.SwitchVizGroupByIndex(self.tabpages, nIndex);
		_guihelper.CheckRadioButtonsByIndex(self.tabbuttons, nIndex, "255 255 255", self.pagetab_selected_bg, self.pagetab_bg);
	end	
end

-- called when user logs in.
function LoginWnd.OnClickBtnLogin(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting LoginWnd instance "..sCtrlName.."\r\n");
		return;
	end
	
	-- get the following input from the UI
	local username, password, domainname;
	
	tmp = ParaUI.GetUIObject(self.name.."editboxUserName");
	if(tmp:IsValid() == true) then 
		username = tmp.text;
		if(user == "") then
			_guihelper.MessageBox(L"Please enter your user name\r\n");
			return;
		end
	end
	tmp = ParaUI.GetUIObject(self.name.."editBoxPassWord");
	if(tmp:IsValid() == true) then 
		password = tmp.text;
	end
	
	tmp = CommonCtrl.GetControl(self.name.."comboBoxDomain");
	if(tmp~=nil) then 
		domainname = tmp:GetText();
	end
	-- (re)start the NPL runtime
	if(username~=nil and password~=nil) then
	
		local checkBox = CommonCtrl.GetControl(self.name.."checkboxRememberUserNamePassword");
		if (checkBox~=nil and checkBox.isChecked) then
			self.SaveCredential(username, password);
		else
			-- TODO: delete the config/npl_credential.txt file	
		end
		ParaNetwork.EnableNetwork(true, self.username, self.password);
		-- update the login message
		-- TODO: we should validate with the domainname server for the username and password, before displaying this message.
		self.Authenticated = true;
		self.username = username;
		self.password = password;
		self.domainname = domainname;
		
		self:UpdateLoginStatus();
	end
end

function LoginWnd:UpdateLoginStatus(bUseKidsDB)
	if(bUseKidsDB) then
		self.Authenticated = kids_db.User.IsAuthenticated;
		self.username = kids_db.User.Name;
		self.password = kids_db.User.Password;
		self.domainname = "www.kids3dmovie.com";
	end	
	
	local tmp = ParaUI.GetUIObject(self.name.."LoginMessage");
	
	if(not kids_db.User.IsAuthenticated) then
		tmp.text = L"Please login using your account";	
	else
		-- if the networklayer is not enabled, enable it here
		if(not ParaNetwork.IsNetworkLayerRunning()) then
			-- TODO: also enable it, if the user name and password has changed.
			ParaNetwork.EnableNetwork(true, self.username, self.password);
		end	
	
		tmp.text = string.format(L"Welcome %s! Your URL is:\r\nhttp://%s/%s", self.username, tostring(self.domainname), self.username);	
	end
end

-- save username and password to local file
function LoginWnd.SaveCredential(username, password)
	-- write credential to file
	local file = ParaIO.open("config/npl_credential.txt", "w");
	file:WriteString(username.."\r\n");
	file:WriteString(password.."\r\n");
	file:close();
end

-- load the personal world associated with the user and make it a server. 
function LoginWnd.OnClickHostWorld(sCtrlName)
	NPL.load("(gl)script/network/KM_HostAndJoinWorld.lua");
	KM_HostAndJoinWorld.OnClickHostWorld();	
end

-- to restart the game server.This function is only functional when this engine is the game server
-- it will display a dialog asking for confirmation, and then restart the game server. 
-- Once a game server is restarted, the server world is reloaded losing all unsaved changes, all connected clients
-- also restarted to synchronous with the new game world on the game server. 
function LoginWnd.OnClickRestartGameserver(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting LoginWnd instance "..sCtrlName.."\r\n");
		return;
	end
	if(ParaWorld.GetServerState() ~= 1) then
		_guihelper.MessageBox("You need to host a game server first in order to restart it");
		return
	end
	_guihelper.MessageBox("Are you sure that you want to restart the server? \r\nNote: Once a game server is restarted, the server world is reloaded losing all unsaved changes.", function()
		if(server.RestartGameServer()) then
		else
			log("error: failed to restart\r\n");
		end
	end);
end

---------------------------------------------------------
-- the following methods are usually overriden by its derived class
---------------------------------------------------------

-- usually overriden by its derived class.
function LoginWnd:GetType()
	return "LoginWnd";
end

-- called by explorer when this window should be stopped (stop connecting).
function LoginWnd:OnStop()
end

-- called by explorer when this window should be closed and loses its connections
function LoginWnd:OnClose()
	self:OnStop();
	self:Destroy();
end

-- called by explorer when this window is informed of changing size. 
-- Usually only the width matters, since the parent will scroll this window if it is too long.
-- @param clientWidth: expected client size of this window 
-- @param clientHeight: expected client size of this window 
function LoginWnd:OnSize(clientWidth, clientHeight)
end

-- called by explorer when this window becomes the current active window in the explorer
function LoginWnd:OnActive()
end

-- called by explorer when this window becomes an inactive window in the explorer
function LoginWnd:OnDeActive()
end

-- called by explorer when this window needs to be refreshed
function LoginWnd:OnRefresh()
end

-- get the url of the window
function LoginWnd:GetURL()
	return self.url;
end

-- set the url of the window
function LoginWnd:SetURL(url)
	self.url = url;
end

-- get the title of the window
function LoginWnd:GetURL()
	return self.title;
end

-- set the title of the window
function LoginWnd:SetURL(title)
	self.title = title;
end

--
function LoginWnd:OnResize()
end