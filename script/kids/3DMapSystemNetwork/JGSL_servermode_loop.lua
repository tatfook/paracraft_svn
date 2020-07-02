--[[
Title: main loop file for dedicated server mode
Author(s): LiXizhi
Date: 2008.9.13
Desc: in ParaWorldCore.lua, if the command line contains servemode="true", then the main game loop is automatically set this file
and main_state is set to "JGSL_servermode". The server mode will periodically keep the server connection alive. 
One can also set the main game loop to this file in bootstrapper
use the lib:
------------------------------------------------------------
ParaGlobal.SetGameLoop("(gl)script/kids/3DMapSystemNetwork/JGSL_servermode_loop.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/ParaWorldCore.lua"); -- ParaWorld platform includes
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL.lua");
NPL.load("(gl)script/kids/3DMapSystemNetwork/JGSL_servermode.lua");

local function activate()
	if(main_state==0) then
		-- this is the main server loop
		Map3DSystem.JGSL.servermode.StayAlive();
	elseif(main_state==nil or main_state=="JGSL_servermode") then
		-- startup all applications
		NPL.load("(gl)script/kids/3DMapSystemApp/AppManager.lua");
		Map3DSystem.App.AppManager.Startup();
		
		-- start server mode now.
		Map3DSystem.JGSL.servermode.EnterServerMode();
		
		main_state=0;
	end
end
NPL.this(activate);