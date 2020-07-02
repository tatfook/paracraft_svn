--[[
Title: main loop file for ParaWorld
Author(s):  LiXizhi, WangTian
Date: 2007/8/22
Desc: Entry point and game loop
---++ Command Line parameters
| *name*| *app* | *description* |
|username|| force loading as a given user|
|password|||
|chatdomain|||
|domain|||
|IP|||
|port|||
|startpage| LoginApp| The browser window will show StartPage.html by default. if the command line contains "startpage", it will be used as startup page|

use the lib:
------------------------------------------------------------
NPL.activate("(gl)script/kids/3DMapSystem_main.lua");
------------------------------------------------------------
]]
main_state="logo";
ParaGlobal.SetGameLoop("(gl)script/kids/3DMapSystem_main.lua");
application_name = "3DMapSystem";

NPL.load("(gl)script/kids/ParaWorldCore.lua"); -- ParaWorld platform includes

-- this script is activated every 0.5 sec. it uses a finite state machine (main_state). 
-- State nil is the inital game state. state 0 is idle.
local function activate()
	if(main_state==0) then
		-- this is the main game loop
	elseif(main_state==nil) then
		main_state = Map3DSystem.init();
		if(main_state~=nil) then
			-- show initial desktop window
			NPL.load("(gl)script/kids/3DMapSystemUI/Desktop/DesktopWnd.lua");
			Map3DSystem.UI.Desktop.Show();
		end	
		
	elseif(main_state=="logo") then
		NPL.load("(gl)script/kids/3DMapSystemUI/Desktop/LogoPage.lua");
		-- it will only be shown for once. subsequent calls do nothing. 
		Map3DSystem.UI.Desktop.LogoPage.Show()
		
	elseif(main_state=="shutdown") then
		-- shut down application
		NPL.load("(gl)script/kids/3DMapSystemApp/AppManager.lua");
		Map3DSystem.App.AppManager.Shutdown();
		
	elseif(main_state=="ingame") then
		-- TODO: remove this
		Map3DSystem.LoadWorld("worlds/3DMapStartup")
		main_state=0;
		
	elseif(main_state=="ingame2") then
		-- TODO: remove this
		Map3DSystem.LoadWorld("worlds/原始部落.zip")
		main_state=0;	
	end
end

NPL.this(activate);
