--[[
Title: code behind for page EnterUserIDPage.html
Author(s): LiXizhi
Date: 2010/1/5
Desc: display a dialog for user to enter nid. a callback function is provided. 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Dialog/EnterUserIDPage.lua");
MyCompany.Aries.Dialogs.EnterUserIDPage.Show(function(result, nid)
	if(result == "ok") then
		_guihelper.MessageBox("you entered "..tostring(nid))
	end
end)
-------------------------------------------------------
]]
local EnterUserIDPage = commonlib.gettable("MyCompany.Aries.Dialogs.EnterUserIDPage");

EnterUserIDPage.callbackFunc = nil;

-- show a page for user nid. it does not verify user nid existence.
-- @param callbackFunc: function(result, nid) if(result=="ok") then end end
function EnterUserIDPage.Show(callbackFunc)
	EnterUserIDPage.callbackFunc = callbackFunc;
	
	-- show the panel
	System.App.Commands.Call("File.MCMLWindowFrame", {
		url = "script/apps/Aries/Dialog/EnterUserIDPage.html", 
		name = "EnterUserIDPage", 
		isShowTitleBar = false,
		DestroyOnClose = true,
		zorder = 3,
		allowDrag = false,
		style = CommonCtrl.WindowFrame.ContainerStyle,
		isTopLevel = true,
		directPosition = true,
			align = "_ct",
			x = -322/2,
			y = -216/2,
			width = 322,
			height = 216,
	});
end

