--[[
Title: Orion Main login window
Author(s):  WangTian
Date: 2008/11/26
Desc: The login window that shows at startup not the login window in game
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Orion/MainLogin.lua");
MyCompany.Orion.MainLogin.Show();
------------------------------------------------------------
]]

-- NOTE: suggest the offline mode COMPLETELY DEPRECATED in Orion

-- create class
local MainLogin = {};
commonlib.setfield("MyCompany.Orion.MainLogin", MainLogin);

function MainLogin.Show()
	
	local _mainlogin = ParaUI.CreateUIObject("container", "LoginArea", "_fi", 0, 0, 0, 0);
	_mainlogin.background = "";
	_mainlogin.zorder = 10;
	_mainlogin:AttachToRoot();
	
	local _logo = ParaUI.CreateUIObject("container", "Logo", "_lt", 32, 16, 256, 128);
	--_logo.background = "Texture/3DMapSystem/brand/paraworld_text_256X128.png;0 0 102 128";
	_logo.background = "Texture/3DMapSystem/brand/paraworld_text_256X128.png";
	_mainlogin:AddChild(_logo);
	
	local _loginarea = ParaUI.CreateUIObject("container", "LoginArea", "_ctb", 0, 0, 542, 88);
	--_loginarea.background = "Texture/Orion/Dock_BG.png:15 15 15 15";
	_loginarea.background = "Texture/Orion/Dock_BG.png";
	_mainlogin:AddChild(_loginarea);
	
	local _bg = ParaUI.CreateUIObject("container", "BG", "_fi", 4, 4, 4, 4);
	_bg.background = "Texture/Orion/ProfileCharItem_BG.png:7 7 7 7";
	_bg.color= "255 255 255 150";
	_loginarea:AddChild(_bg);
	
	MainLogin.MainLoginPage = Map3DSystem.mcml.PageCtrl:new({url="script/apps/Orion/Login/MainLoginPage.html"});
	MainLogin.MainLoginPage:Create("MainLoginPage", _loginarea, "_fi", 0, 0, 0, 0);
end