--[[
Title: Aquarius Main login window
Author(s):  WangTian
Date: 2008/12/2
Desc: The login window that shows at startup not the login window in game
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aquarius/MainLogin.lua");
MyCompany.Aquarius.MainLogin.Show();
------------------------------------------------------------
]]

-- NOTE: suggest the offline mode COMPLETELY DEPRECATED in Aquarius

-- create class
local MainLogin = {};
commonlib.setfield("MyCompany.Aquarius.MainLogin", MainLogin);

function MainLogin.Show()
	
	-- don't use animation during main login process
	_guihelper.MessageBox_PopupStyle = nil;
	
	-- main login screen
	local _mainlogin = ParaUI.CreateUIObject("container", "MainLogin", "_fi", 0, 0, 0, 0);
	_mainlogin.background = "";
	_mainlogin.zorder = 1;
	_mainlogin:AttachToRoot();
		local _BG = ParaUI.CreateUIObject("container", "BG", "_fi", 0, 0, 0, 0);
		--_BG.background = "Texture/3DMapSystem/Desktop/TopFrameBG.png: 10 200 10 90";
		_BG.background = "Texture/Aquarius/Login/BG_32bits.png";
		_mainlogin:AddChild(_BG);
	
	
	local _logo = ParaUI.CreateUIObject("container", "Logo", "_ct", -128, -185, 256, 128);
	_logo.background = "Texture/Aquarius/Login/Logo_32bits.png";
	_mainlogin:AddChild(_logo);
	
	local _url = ParaUI.CreateUIObject("container", "Logo", "_ct", -128, -80, 256, 64);
	_url.background = "Texture/Aquarius/Login/URL_pala5_32bits.png";
	_mainlogin:AddChild(_url);
	
	local _loginarea = ParaUI.CreateUIObject("container", "LoginArea", "_ct", -128, -25, 256, 150);
	_loginarea.background = "";
	_mainlogin:AddChild(_loginarea);
	
	--MainLogin.MainLoginPage = Map3DSystem.mcml.PageCtrl:new({url="script/apps/Aquarius/Login/MainLoginPage.html"});
	--MainLogin.MainLoginPage:Create("MainLoginPage", _loginarea, "_fi", 0, 0, 0, 0);
	
		local _inputbox = ParaUI.CreateUIObject("container", "InputBox", "_mt", 0, 0, 0, 94);
		_inputbox.background = "Texture/Aquarius/Login/LoginBox_32bits.png: 6 6 6 6";
		_loginarea:AddChild(_inputbox);
		local _text = ParaUI.CreateUIObject("button", "BG", "_lt", 0, 16, 78, 26);
		_text.background = "";
		_text.text = "用户名:";
		_text.enabled = false;
		_text.font = System.DefaultLargeBoldFontString;
		_guihelper.SetFontColor(_text, "#359aa9");
		_inputbox:AddChild(_text);
		local _name = ParaUI.CreateUIObject("imeeditbox", "Name", "_lt", 78, 16, 170, 26);
		_guihelper.SetFontColor(_name, "#359aa9");
		_name.font = System.DefaultBoldFontString;
		_name.background = "Texture/Aquarius/Login/TextBox_32bits.png: 8 8 5 5";
		_name.spacing = 3;
		_name.text = Map3DSystem.User.Name;
		_inputbox:AddChild(_name);
		
		local _text = ParaUI.CreateUIObject("button", "BG", "_lt", 0, 52, 78, 26);
		_text.background = "";
		_text.text = "密  码:";
		_text.enabled= false;
		_text.font = System.DefaultLargeBoldFontString;
		_guihelper.SetFontColor(_text, "#359aa9");
		_inputbox:AddChild(_text);
		local _pw = ParaUI.CreateUIObject("editbox", "PW", "_lt", 78, 52, 170, 26);
		_guihelper.SetFontColor(_pw, "#359aa9");
		_pw.font = System.DefaultBoldFontString;
		_pw.background = "Texture/Aquarius/Login/TextBox_32bits.png: 8 8 5 5";
		_pw.spacing = 4;
		_pw.text = Map3DSystem.User.Password;
		_pw.PasswordChar = "*";
		_inputbox:AddChild(_pw);
		
		local _fakeLogin = ParaUI.CreateUIObject("button", "FakeLogin", "_lt", 78, 52, 170, 26);
		_fakeLogin.onclick = ";MyCompany.Aquarius.MainLogin.OnClickLogin();";
		_fakeLogin.visible = false;
		_fakeLogin:SetDefault(true);
		_inputbox:AddChild(_fakeLogin);
		
	local _login = ParaUI.CreateUIObject("button", "Login", "_lt", 22, 104, 108, 35);
	_guihelper.SetVistaStyleButton3(_login, 
			"Texture/Aquarius/Login/Buttons_Norm_32bits.png; 0 0 108 35", 
			"Texture/Aquarius/Login/Buttons_HighLight_32bits.png; 0 0 108 35", 
			"Texture/Aquarius/Login/Buttons_Norm_32bits.png; 0 0 108 35", 
			"Texture/Aquarius/Login/Buttons_Pressed_32bits.png; 0 0 108 35");
	_login.onclick = ";MyCompany.Aquarius.MainLogin.OnClickLogin();";
	_loginarea:AddChild(_login);
	
	local _register = ParaUI.CreateUIObject("button", "Register", "_lt", 140, 104, 108, 35);
	_guihelper.SetVistaStyleButton3(_register, 
			"Texture/Aquarius/Login/Buttons_Norm_32bits.png; 0 35 108 35", 
			"Texture/Aquarius/Login/Buttons_HighLight_32bits.png; 0 35 108 35", 
			"Texture/Aquarius/Login/Buttons_Norm_32bits.png; 0 35 108 35", 
			"Texture/Aquarius/Login/Buttons_Pressed_32bits.png; 0 35 108 35");
	_register.onclick = ";_guihelper.MessageBox(\"本版本是alpha测试版，暂时不开放公共注册\");";
	_loginarea:AddChild(_register);
	
	local _leftbottomarea = ParaUI.CreateUIObject("container", "LeftBottomArea", "_lb", 0, -400, 200, 400);
	_leftbottomarea.background = "";
	_mainlogin:AddChild(_leftbottomarea);
	
	local _rightbottomarea = ParaUI.CreateUIObject("container", "RightBottomArea", "_rb", -148, -213, 148, 213);
	_rightbottomarea.background = "";
	_mainlogin:AddChild(_rightbottomarea);
		local _cinematics = ParaUI.CreateUIObject("button", "Cinematics", "_lt", 0, 0, 108, 35);
		--_cinematics.background = "Texture/3DMapSystem/Desktop/LoginButton_Norm.png: 15 15 15 15";
		--_cinematics.background = "Texture/Aquarius/Login/Buttons_32bits.png; 0 70 108 35";
		_guihelper.SetVistaStyleButton3(_cinematics, 
				"Texture/Aquarius/Login/Buttons_Norm_32bits.png; 0 70 108 35", 
				"Texture/Aquarius/Login/Buttons_HighLight_32bits.png; 0 70 108 35", 
				"Texture/Aquarius/Login/Buttons_Norm_32bits.png; 0 70 108 35", 
				"Texture/Aquarius/Login/Buttons_Pressed_32bits.png; 0 70 108 35");
		--_cinematics.text = "Cinematics";
		_rightbottomarea:AddChild(_cinematics);
		local _credits = ParaUI.CreateUIObject("button", "Credits", "_lt", 0, 38, 108, 35);
		--_credits.background = "Texture/3DMapSystem/Desktop/LoginButton_Norm.png: 15 15 15 15";
		_credits.background = "Texture/Aquarius/Login/Buttons_32bits.png; 0 105 108 35";
		_guihelper.SetVistaStyleButton3(_credits, 
				"Texture/Aquarius/Login/Buttons_Norm_32bits.png; 0 105 108 35", 
				"Texture/Aquarius/Login/Buttons_HighLight_32bits.png; 0 105 108 35", 
				"Texture/Aquarius/Login/Buttons_Norm_32bits.png; 0 105 108 35", 
				"Texture/Aquarius/Login/Buttons_Pressed_32bits.png; 0 105 108 35");
		--_credits.text = "Credits";
		_rightbottomarea:AddChild(_credits);
		local _pedn = ParaUI.CreateUIObject("button", "PEDN", "_lt", 0, 38 * 2, 108, 35);
		--_pedn.background = "Texture/3DMapSystem/Desktop/LoginButton_Norm.png: 15 15 15 15";
		_pedn.background = "Texture/Aquarius/Login/Buttons_32bits.png; 0 140 108 35";
		_guihelper.SetVistaStyleButton3(_pedn, 
				"Texture/Aquarius/Login/Buttons_Norm_32bits.png; 0 140 108 35", 
				"Texture/Aquarius/Login/Buttons_HighLight_32bits.png; 0 140 108 35", 
				"Texture/Aquarius/Login/Buttons_Norm_32bits.png; 0 140 108 35", 
				"Texture/Aquarius/Login/Buttons_Pressed_32bits.png; 0 140 108 35");
		--_pedn.text = "PEDN";
		_rightbottomarea:AddChild(_pedn);
		
		local _exit = ParaUI.CreateUIObject("button", "Exit", "_lt", 0, 147, 108, 35);
		--_exit.background = "Texture/3DMapSystem/Desktop/LoginButton_Norm.png: 15 15 15 15";
		_exit.background = "Texture/Aquarius/Login/Buttons_32bits.png; 0 175 108 35";
		_guihelper.SetVistaStyleButton3(_exit, 
				"Texture/Aquarius/Login/Buttons_Norm_32bits.png; 0 175 108 35", 
				"Texture/Aquarius/Login/Buttons_HighLight_32bits.png; 0 175 108 35", 
				"Texture/Aquarius/Login/Buttons_Norm_32bits.png; 0 175 108 35", 
				"Texture/Aquarius/Login/Buttons_Pressed_32bits.png; 0 175 108 35");
		--_exit.text = "Exit";
		_exit.onclick = ";ParaGlobal.ExitApp();";
		_rightbottomarea:AddChild(_exit);

	if(Map3DSystem.options.IsEditorMode) then
		local _editormodeBG = ParaUI.CreateUIObject("button", "_editormodeBG", "_ct", -128, -25+128+25, 256, 25);
		_guihelper.SetFontColor(_editormodeBG, "#359aa9");
		_guihelper.SetUIColor(_editormodeBG, "255 255 255")
		_editormodeBG.text="欢迎使用: 帕拉巫 -- 星球编辑器";
		_editormodeBG.background = "Texture/Aquarius/Common/Container_32bits.png: 4 4 4 4"
		_mainlogin:AddChild(_editormodeBG);
	end
		
	local _copyright = ParaUI.CreateUIObject("button", "CopyRight", "_mb", 0, 107, 0, 20);
	_copyright.background = "";
	_guihelper.SetFontColor(_copyright, "#359aa9");
	_copyright.text = "© 2009 ParaEngine Corporation. 保留所有权利.";
	_copyright.enabled = false;
	_mainlogin:AddChild(_copyright);
	
	local _copyright = ParaUI.CreateUIObject("button", "CopyRight", "_mb", 0, 84, 0, 20);
	_copyright.background = "";
	_guihelper.SetFontColor(_copyright, "#359aa9");
	_copyright.text = "版本V0.1(alpha版本) Jan 6th 2009";
	_copyright.enabled = false;
	_mainlogin:AddChild(_copyright);
end

function MainLogin.Proc_Complete_Callback()
	-- set message box popup style with animation
	_guihelper.MessageBox_PopupStyle = 1;
	paraworld.ShowMessage();
	
	-- directly login to public world
	local params = {
		worldpath = "worlds/MyWorlds/AlphaWorld",
		-- only give the guest right, to prevent switching character and editing. 
		role = "guest",
	}
	if(Map3DSystem.options.IsEditorMode) then
		-- the world to login when running in editor mode. 
		params.worldpath = "worlds/MyWorlds/ParaEngine";
		params.role = "friend";
	end
	
	-- destroy the main login manually, aquarius uses perserve user interface for all world loading
	ParaUI.Destroy("MainLogin");
	
	if(ParaWorld.GetWorldDirectory() ~= params.worldpath) then
		System.App.Commands.Call(System.App.Commands.GetLoadWorldCommand(), params);
	else
		log("world is already loaded.\n")	
	end	
end

function MainLogin.OnClickLogin()
	local _mainlogin = ParaUI.GetUIObject("MainLogin");
	if(_mainlogin:IsValid() == true) then
		local _loginarea = _mainlogin:GetChild("LoginArea");
		local _inputbox = _loginarea:GetChild("InputBox");
		local _name = _inputbox:GetChild("Name");
		local _pw = _inputbox:GetChild("PW");
		
		local username = _name.text;
		local password = _pw.text;
		NPL.load("(gl)script/apps/Aquarius/Login/MainLoginPage.lua");
		local values = {
			username = username, 
			password = password,
			rememberpassword = System.options.IsEditorMode,
		}
		MyCompany.Aquarius.LoginPage.Proc_Start(values, MyCompany.Aquarius.MainLogin.Proc_Complete_Callback, true);
	end
end
