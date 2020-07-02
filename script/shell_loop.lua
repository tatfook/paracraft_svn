--[[
Title: Empty shell game loop file
Author(s):  LiXizhi
Date: 2009/5/3
Desc: this is mostly used to test modules by server. 
This loop file can be activated by bootstrapper file "config/bootstrapper_emptyshell.xml"
For server build, the command line to use this shell_loop is below. 
- under windows, it is "bootstrapper=\"config/bootstrapper_emptyshell.xml\"". 
- under linux shell script, it is 'bootstrapper="config/bootstrapper_emptyshell.xml"'
use the lib:
------------------------------------------------------------
For server build, the command line to use this shell_loop is below. 
- under windows, it is "bootstrapper=\"config/bootstrapper_emptyshell.xml\"". 
- under linux shell script, it is 'bootstrapper="config/bootstrapper_emptyshell.xml"'
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");

main_state = nil;


local function activate()
	-- commonlib.echo("heart beat: 30 times per sec");
	if(main_state==0) then
		-- this is the main game loop
	elseif(main_state==nil) then
		main_state=0;
		log("Hello World from script/shell_loop.lua\n")
		
		--NPL.load("(gl)script/test/network/TestServer.lua");
		--test_start_server({threadcount=2});
		
		-- NPL.activate("NPLMono.dll", nil);
		-- NPL.activate("NPLMonoInterface.dll/NPLMonoInterface.cs", {data = "C# mono dll test1"});
		--NPL.activate("NPLMonoInterface.dll/NPLMonoInterface.cs", {data = "C# mono dll test2"});
		--NPL.activate("NPLMonoInterface.dll/ParaMono.NPLMonoInterface.cs", {data = "C# mono dll test3"});
		-- NPL.activate("NPLMonoInterface.dll/NPLMonoInterface.cs", {test_name = 1, _name=2, ["1abc"]=3});
		
		-- push the first message to server
		--local thread_count = 1;
		--local i, nCount = nil, thread_count
		--for i=1, nCount do
			--local rts_name = "p"..i;
			--local producer = NPL.CreateRuntimeState(rts_name, 0);
			--producer:Start();
		--end
		--
		--local k, kSize = nil, 1; -- math.floor(20/nCount);
		--for k=1, kSize do
			--local i, nCount = nil, thread_count
			--for i=1, nCount do
				--local rts_name = "p"..i;
				--NPL.activate(string.format("(%s)NPLMonoInterface.dll/NPLMonoInterface.cs", rts_name), {rts_name=rts_name, counter=k});
			--end	
		--end	
	
		-- NPL.activate("DBServer.dll/DBServer.DBServer.cs", {root_dir = ParaIO.GetCurDirectory(0)});
		
		--NPL.load("(gl)script/apps/DBServer/DBServer.lua");
		--DBServer:Start();
		
		-- NPL.activate("NPLRouter.dll", nil);
		
		--NPL.load("(gl)script/apps/GameServer/test/test_client_rest.lua");
		--GameServer.test_client:start("script/apps/GameServer/test/local.GameClient.config.xml");
		--GameServer.test_client:start();
		
		--GameServer.test_client:test_AuthUser();
		--GameServer.test_client:test_Home_Get();
		--GameServer.test_client:test_Home_Get_async_many();
		-- GameServer.test_client:test_Home_Get_sync_many();
		-- GameServer.test_client:test_Ping_async_many();
		
		--NPL.StartNetServer("127.0.0.1", "60002");
		--NPL.LoadPublicFilesFromXML();
		--local worker = NPL.CreateRuntimeState("world1", 0);
		--worker:Start();
		--NPL.activate("(world1)script/apps/GameServer/GSL_system.lua", {type="restart", config={nid="localhost", ws_id="world1"}});
		
		--NPL.CompileFiles("script/config.lua");
		--NPL.CompileFiles("script/ide/*.lua", nil, 2);
		
		-- NPL.load("(gl)script/installer/BuildParaWorld.lua");
		-- commonlib.BuildParaWorld.CompileNPLFiles()
		
		--commonlib.echo("testing jabber client in linux")
		--NPL.load("(gl)script/apps/GameServer/jabber_client.lua");
		--local jabber_client = GameServer.jabber.client:new({})
		--jabber_client:AddEventListener("OnAuthenticate", commonlib.echo);
		--jabber_client:AddEventListener("OnMessage", commonlib.echo);
		--jabber_client:start("20527@test.pala5.cn", "8488103559808");
	end	
end
NPL.this(activate);