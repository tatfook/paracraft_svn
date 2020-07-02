--[[
Title: ToolBar
Author(s): Leio
Date: 2008/11/25
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Inventor/Gears/ToolBar.lua");
------------------------------------------------------------
]]
local ToolBar = {
} 
commonlib.setfield("Map3DSystem.App.Inventor.Gears.ToolBar",ToolBar);
function ToolBar.Show()
local _, _, screenWidth, screenHeight = ParaUI.GetUIObject("root"):GetAbsPosition();
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url=System.localserver.UrlHelper.BuildURLQuery("script/kids/3DMapSystemUI/Inventor/Gears/ToolBar3.html", {cmdredirect=cmdredirect}), 
			name="ToolBar.Wnd", 
			app_key=MyCompany.Apps.Inventor.app_key, 
			text = "工具条",
			icon = "Texture/3DMapSystem/common/lock.png",
			isShowTitleBar = false, 
			isShowToolboxBar = false, 
			isShowStatusBar = false, 
			isShowMinimizeBox = false,
			bToggleShowHide = false,
			DestroyOnClose = true,
			directPosition = true,
				align = "_lt",
				x = 0,
				y = 0,
				width = screenWidth,
				height = 100,
				bAutoSize=false,
			zorder=3,
		});
end
