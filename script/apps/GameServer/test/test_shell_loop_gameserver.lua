--[[
Title: shell game loop file
Author(s):  LiXizhi
Date: 2009/10/5
Desc: use the bootstrapper command line to start a pure game server cluster locally() 

bootstrapper="script/apps/GameServer/test/test_bootstrapper_gameserver.lua"
"bootstrapper=\"script/apps/GameServer/test/test_bootstrapper_gameserver.lua\""

use the lib:
------------------------------------------------------------
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/apps/GameServer/GameServer.lua");

main_state = nil;

local function activate()
	-- commonlib.echo("heart beat: 30 times per sec");
	if(main_state==0) then
		-- this is the main game loop
		
	elseif(main_state==nil) then
		main_state=0;
		
		-- start the server
		GameServer:Start("script/apps/GameServer/test/test.GameServer.config.xml");
		
		--NPL.StartNetServer("127.0.0.1", "60002");
		--NPL.LoadPublicFilesFromXML();
		--local worker = NPL.CreateRuntimeState("world1", 0);
		--worker:Start();
		--NPL.activate("(world1)script/apps/GameServer/GSL_system.lua", {type="restart", config={nid="localhost", ws_id="world1"}});
	end
end
NPL.this(activate);