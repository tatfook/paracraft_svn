--[[
Title: BaiduTestPage
Author(s): leio
Date: 2014/12/3
Desc: test baidu yun api
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/mobile/paracraft/Login/BaiduTestPage.lua");
local BaiduTestPage = commonlib.gettable("ParaCraft.Mobile.Login.BaiduTestPage")
BaiduTestPage.ShowPage()
-------------------------------------------------------
]]
NPL.load("(gl)script/mobile/paracraft/Login/BaiduTestPage.lua");
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic");
local MainLogin = commonlib.gettable("ParaCraft.Mobile.MainLogin");

local BaiduTestPage = commonlib.gettable("ParaCraft.Mobile.Login.BaiduTestPage")
local page;

function BaiduTestPage.ShowPage()
	System.App.Commands.Call("File.MCMLWindowFrame", {
		url = "script/mobile/paracraft/Login/BaiduTestPage.html", 
		name = "CreateMCNewWorld", 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		style = CommonCtrl.WindowFrame.ContainerStyle,
		zorder = 0,
		allowDrag = false,
		directPosition = true,
			align = "_fi",
			x = 0,
			y = 0,
			width = 0,
			height = 0,
		cancelShowAnimation = true,
	});
end

function BaiduTestPage.OnInit()
	page = document:GetPageCtrl();
end

function BaiduTestPage.ReturnLastStep()
	if(page) then
		page:CloseWindow();
	end
    if(not GameLogic.IsStarted) then
        MainLogin:next_step({IsLoginModeSelected = false});
    end
end