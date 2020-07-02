--[[
Title: code behind for page EscPage.html
Author(s): LiXizhi
Date: 2009/1/4
Desc:  script/apps/Aquarius/Desktop/EscPage.html
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aquarius/Desktop/EscPage.lua");
MyCompany.Aquarius.EscPage.Proc_Authentication(values, funcCallBack, bSkipAppRegistration)
-------------------------------------------------------
]]

local EscPage = {};
commonlib.setfield("MyCompany.Aquarius.EscPage", EscPage)

---------------------------------
-- page event handlers
---------------------------------
local page;
-- init
function EscPage.OnInit()
	page = document:GetPageCtrl();
end

function EscPage.OnSettings()
    EscPage.OnClose()
    System.App.Commands.Call("Profile.Aquarius.Settings");
end
function EscPage.OnExit()
    EscPage.OnClose()
    _guihelper.MessageBox("你确定要退出么?", function()
		ParaGlobal.ExitApp()
    end);
end
function EscPage.OnClose()
    page:CloseWindow();
end