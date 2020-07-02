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
NPL.load("(gl)script/ide/UnitTest/luaunit.lua");

main_state = nil;

local function activate()
	-- commonlib.echo("heart beat: 30 times per sec");
	if(main_state==0) then
		-- this is the main game loop
	elseif(main_state==nil) then
		main_state=0;
		log("Hello World from script/shell_loop_encryptzipfiles.lua,to load MyTestServer\n")
		
		--NPL.load("(gl)script/test/network/MyTestServer.lua");
		--test_start_server();
		--NPL.load("(gl)script/test/network/MyTestServer.lua");
		--test_start_server();
		NPL.load("(gl)script/installer/BuildParaWorld.lua");
		commonlib.BuildParaWorld.EncryptZipFiles({"main"})
		commonlib.echo("encrypt end!");
		--commonlib.echo(__rts__:GetName())
		--local worker = NPL.CreateRuntimeState("im", 0);
		--worker:Start();
		--NPL.AddNPLRuntimeAddress({host="192.168.0.228", port="60001", nid="routerserver"})
		--NPL.activate("(im)routerserver:script/apps/NPLRouter/IMDispatcher.lua", {type="test"});
		-- NPL.activate("(im)script/apps/NPLRouter/IMDispatcher.lua", {nid="78975924", content="hello world!"});
		ParaGlobal.Exit(0);
	end	
end
NPL.this(activate);