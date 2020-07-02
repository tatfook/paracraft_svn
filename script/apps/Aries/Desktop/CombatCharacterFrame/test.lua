--[[
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Desktop/CombatCharacterFrame/test.lua");
MyCompany.Aries.Desktop.test.show();
------------------------------------------------------------
]]

local test = commonlib.gettable("MyCompany.Aries.Desktop.test");

function test.show()
	local params = {
		url = "script/apps/Aries/Desktop/CombatCharacterFrame/test.htm", 
		app_key = MyCompany.Aries.app.app_key, 
		name = "CYF", 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		bToggleShowHide = not bForceShow,
		cancelShowAnimation = true,
		style = style,
		zorder = 2,
		allowDrag = true,
		isTopLevel = true,
		enable_esc_key = true,
		directPosition = true,
		align = "_ct",
		x = -690/2,
		y = -443/2,
		width = 690,
		height = 443
	};
    System.App.Commands.Call("File.MCMLWindowFrame", params);

	--_guihelper.MessageBox("AAA");
	--_guihelper.MessageBox(document:GetPageCtrl():GetNode("divA"):GetInnerText());
	--_guihelper.MessageBox("BBB");
end