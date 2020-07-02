--[[
Title: code behind for page MyHomelandIndoor.html
Author(s): Leio
Date: 2009/7/23
Desc:  script/kids/3DMapSystemUI/HomeLand/Pages/MyHomelandIndoor.html
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/Pages/MyHomelandIndoor.lua");
-------------------------------------------------------
]]
local MyHomelandIndoorPage = {
	
};
commonlib.setfield("MyCompany.Aries.Inventory.MyHomelandIndoorPage", MyHomelandIndoorPage);

function MyHomelandIndoorPage.ShowPage()
	NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandConfig.lua");
	local pos = Map3DSystem.App.HomeLand.HomeLandConfig.Panel_ShowPos_ItemLibs;
	local self = MyHomelandIndoorPage;
	self.ClosePage();
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/kids/3DMapSystemUI/HomeLand/Pages/MyHomelandIndoor.html", 
			name = "MyHomelandIndoorPage.ShowPage", 
			app_key=MyCompany.Aries.app.app_key, 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			allowDrag = false,
			directPosition = true,
				align = pos.align,
				x = pos.left,
				y = pos.top,
				width = pos.width,
				height = pos.height,
		});
end
function MyHomelandIndoorPage.ClosePage()
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="MyHomelandIndoorPage.ShowPage", 
		app_key=MyCompany.Aries.app.app_key, 
		bShow = false,bDestroy = true,});
end