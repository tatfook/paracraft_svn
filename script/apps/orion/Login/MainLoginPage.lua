--[[
Title: Orion Main login page
Author(s):  WangTian
Date: 2008/11/26
Desc: The login page that shows at startup not the login window in game
]]

-- NOTE: suggest the offline mode COMPLETELY DEPRECATED in Orion

function MyCompany.Orion.MainLogin.OnClickNewAccount()
	System.UI.Desktop.GotoDesktopPage(System.App.Login.RegPageUrl, 
			System.localserver.CachePolicy:new("access plus 1 day"))
	--pp:test the click event of NewAccount button control
	--_guihelper.MessageBox("你确定要退出程序么?") 
end

function MyCompany.Orion.MainLogin.OnLoginOfflineMode()
	local params = {worldpath = "worlds/MyWorlds/1111111111111"}
	System.App.Commands.Call(System.App.Commands.GetLoadWorldCommand(), params);
	if(params.res) then
		-- succeed loading
	end
end

function MyCompany.Orion.MainLogin.OnClickConnect()
	local params = {worldpath = "worlds/MyWorlds/1111111111111"}
	System.App.Commands.Call(System.App.Commands.GetLoadWorldCommand(), params);
	if(params.res) then
		-- succeed loading
	end
end

function MyCompany.Orion.MainLogin.OnClickCallback_ExitApp()
	--pp:test BBSChatWnd.lua
	 --NPL.load("(gl)script/apps/Orion/BBSChat/BBSChatWnd.lua");
    --MyCompany.Orion.ChatWnd.Show(bShow);
	
	_guihelper.MessageBox("你确定要退出程序么?", System.UI.Main_Startup.OnExitApp);
end