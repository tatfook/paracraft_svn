--[[
Title: shell game loop file
Author(s):  LiXizhi
Date: 2009/7/20
Desc: 
use the lib:
------------------------------------------------------------
command line params:
e.g. bootstrapper="script/apps/GameServer/shell_loop_gameserver.lua" config=""
e.g. bootstrapper="script/apps/GameServer/shell_loop_gameserver.lua" config="config/AriesDevLocal.GameServer.config.xml"
e.g. in win32 bat file, start ParaEngineServer.exe "bootstrapper=\"script/apps/GameServer/shell_loop_gameserver.lua\" config=\"config/AriesDevLocal.GameServer.config.xml\""
| config | can be omitted which defaults to config/gameserver.config.xml |
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");

main_state = nil;

-- init UI console
local function InitUIConsole()
	if(ParaUI and ParaUI.CreateUIObject and not ParaEngine.GetAttributeObject():GetField("IsServerMode", false)) then
		-- load game server console
		NPL.load("(gl)script/ide/Debugger/MCMLConsole.lua");
		local init_page_url = nil;
		commonlib.mcml_console.show(true, init_page_url);
	end
end

local function activate()
	-- commonlib.echo("heart beat: 30 times per sec");
	if(main_state==0) then
		-- this is the main game loop
		
	elseif(main_state==nil) then
		main_state=0;

		-- InitUIConsole();

		NPL.load("(gl)script/apps/GameServer/GameServer.lua");
		local config_file = ParaEngine.GetAppCommandLineByParam("config", "");
		if(config_file == "") then
			config_file = nil;
		end

		-- start the server
		GameServer:Start(config_file);
	end
end
NPL.this(activate);